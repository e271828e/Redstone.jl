module P
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
include(joinpath(W, "test/imports.jl"))
include(joinpath(W, "test/fixtures.jl"))
include(joinpath(W, "test/utils.jl"))
import Redstone: Reads, ReadSetMisuse, ReadResolution, parse_leaf, match_leaf, resolve_leaf, LeafRefusal, _compile_reads, gather_reads, at, reads, _opaque

struct LeafPose{T}
    v::SVector{3,T}
    m::SMatrix{2,2,T,4}
end
Redstone.probe_value(::Type{LeafPose{T}}) where {T} = LeafPose(zero(SVector{3,T}), zero(SMatrix{2,2,T,4}))
struct BarePoseHold <: AbstractComponent end
s_init(::BarePoseHold) = LeafPose(SVector(1.0, 2.0, 3.0), SMatrix{2,2}(5.0, 6.0, 7.0, 8.0))
u_types(::BarePoseHold) = LeafPose{Float64}
y_types(::BarePoseHold) = SMatrix{2,2,Float64,4}
y_state(::BarePoseHold, (; s)) = s.m
s_update(::BarePoseHold, (; s)) = s

struct Bare1 <: AbstractComponent end
x_init(::Bare1) = SVector(1.0, 2.0)
y_types(::Bare1) = SVector{2,Float64}
y_state(::Bare1, (; x)) = x
x_deriv(::Bare1, (; x)) = -x

readable() = Group((; plant = Plant(), ctl = DiscreteAccumulator(3.0), src = ModedSource());
                   input_wires = ("u" => "plant/u", "e" => "ctl/e"),
                   output_wires = ("plant/y" => "y",))
sibling_fed() = Group((; plant = Plant(), trig = Trigger(0.5));
                      local_wires = ("plant/y" => "trig/sig",), input_wires = ("u" => "plant/u",))

dl(e) = e isa DiagnosticError{Vector{Diagnostic}} ? diagnostics(e) : [diagnostic(e)]
function diag_of(f)
    e = try f(); nothing catch err err end
    e === nothing && return "NO ERROR"
    e isa DiagnosticError ? [(typeof(d).name.name, hasproperty(d, :reason) ? d.reason : nothing) for d in dl(e)] : e
end

mm0() = Model(Group((; src = ModedSource())), Float64; Δt_frame = 1//10)
function main()
    println("== exports")
    println(names(Redstone))
    println("== parse_leaf")
    println(parse_leaf("pose.q_eb[2,3]"))
    println(parse_leaf(""))
    println(parse_leaf("[2]"))
    println(parse_leaf("[0]"))
    println(parse_leaf("a b"))
    println(parse_leaf(:abc))
    println(parse_leaf("a[1,2].b[3]"))
    println(match_leaf("a.b", [:a, Symbol("a.b")]))
    println(match_leaf(Symbol("a.b"), [:a, Symbol("a.b")]))
    println(match_leaf("wind[1]", [:wind]))
    println(match_leaf("windx", [:wind]))
    println("== resolve_leaf")
    println(resolve_leaf(Symbol, [:a]))
    println(resolve_leaf(SVector{3,Float64}, [(2,)]))
    println(resolve_leaf(SMatrix{2,2,Float64,4}, [(3,)]))
    println(resolve_leaf(SMatrix{2,2,Float64,4}, [(1,2,3)]))
    println(resolve_leaf(SMatrix{2,2,Float64,4}, [(3,3)]))
    println(resolve_leaf(Float64, [(1,)]))
    println(resolve_leaf(Float64, [:a]))
    println(resolve_leaf(LeafPose{Float64}, [:q]))
    println(resolve_leaf(Vector{Float64}, [(1,)]))
    println("== misc selectors")
    s = get_state("p", :θ); println(s, " ", typeof(s.leaf))
    println(get_state("p"), get_input(), get_face(), get_deriv("p","q"))
    println(typeof(get_output("p", :v).leaf))
    println(fieldnames(Reads), " ", reads(a = get_state("p")))
    println("== misuse")
    println(diag_of(() -> reads(a = 1)))
    println(diag_of(() -> reads(a = 1, b = get_state("p"))))
    println(diag_of(() -> at("", reads(a = get_state("p")))))
    println(diag_of(() -> at("p", (a = get_state("p"),))))
    println(diag_of(() -> at("p", reads(a = get_state("p")))))
    println(at("p", at("q", reads(a = get_state("p")))).prefixes)
    println("== readable")
    model = Model(readable(), Float64; Δt_frame = 1//10)
    b = model.deployment.build
    println(diag_of(() -> _compile_reads((a = get_state("plant", :q),), b)))
    println(diag_of(() -> _compile_reads(reads(a = get_state("nope", :q)), b)))
    println(diag_of(() -> _compile_reads(reads(a = get_state("plant", :q), b = get_state("", :q), c = get_deriv("ctl", :acc),
         d = get_deriv("plant", :zz), e = get_state("plant", ".q"), f = get_state("plant", ""), g=get_output("plant"),
         h=get_state("src", :phase), i=get_input(:nope), j = get_input("y"), k = get_face(:u), l = get_face(:nope),
         m = get_state("plant", "q.a"), n = get_state("plant", "q[3]"), o=get_state("plant", "q[1,2]"), p = get_state("plant","q[0]")), b)))
    println("-- full diags")
    try _compile_reads(reads(a = get_state("plant", :q), b = get_state("", :q), c = get_deriv("ctl", :acc),
         d = get_deriv("plant", :zz), f = get_state("plant", ""), g=get_output("plant"),
         h=get_state("src", :phase), i=get_input(:nope), j = get_input("y"), k = get_face(:u), l = get_face(:nope)), b)
    catch e
        for d in dl(e)
            println(d.label, " ", d.reason, " field=", d.field, " declares=", d.declares, " cand=", d.candidates, " path=", d.path)
        end
    end
    println("-- table source")
    println(diag_of(() -> _compile_reads(reads(a = get_state("plant", :q), b = get_deriv("plant", :q), c = get_output("plant", :y)), b; source = :table)))
    r = _compile_reads(reads(q = get_state("plant", :q), q2 = get_state("plant", "q[2]"), y = get_output("plant", :y), u = get_input(:u), f = get_face(:y)), b)
    println(typeof(r) <: Redstone.Reader, " ", fieldnames(typeof(r)))
    init!(model, combine(at("plant", set(x = (q = SVector(0.3,-0.2),))), at("ctl", set(s=(acc=4.0,))), set(u = (u=1.5, e=0.0))))
    evaluate!(model.exec)
    v = gather_reads(r, model.exec); println(v)
    gather_reads(r, model.exec); println("alloc: ", @allocated gather_reads(r, model.exec))
    println("== sibling_fed")
    m2 = Model(sibling_fed(), Float64; Δt_frame = 1//10)
    try _compile_reads(reads(a = get_input("sig")), m2.deployment.build)
    catch e; println(diag_of(() -> throw(e)))
        for d in dl(e); println(d.reason, " ", d.producer, " ", d.candidates); end; end
    try _compile_reads(at("trig", reads(a = get_input("sig"))), m2.deployment.build)
    catch e; for d in dl(e); println(d.reason, " ", d.producer, " field=", d.field); end; end
    println("== bare")
    m3 = Model(Group((; c = BarePoseHold()); input_wires = ("in" => "c/u",)), Float64; Δt_frame = 1//10)
    b3 = m3.deployment.build
    r3 = _compile_reads(reads(s = get_state("c"), sv = get_state("c", ".v[2]"), y = get_output("c"), y2 = get_output("c", "[1,2]"), y3 = get_output("c","[3]")), b3)
    println(typeof(r3).parameters[2])
    r3b = _compile_reads(at("c", reads(f = get_face(), f12 = get_face("[1,2]"), i = get_input(), i1 = get_input(".v[2]"), ix = get_input(:u))), b3)
    println(typeof(r3b).parameters[2])
    println(diag_of(() -> _compile_reads(reads(f = get_face(), i = get_input()), b3)))
    try _compile_reads(reads(f = get_face(), i = get_input(), p = get_output("")), b3)
    catch e; for d in dl(e); println(d.label, " ", d.reason, " ", d.declares, " ", d.candidates); end; end
    m4 = Model(Group((; c = Bare1())), Float64; Δt_frame = 1//10)
    try _compile_reads(reads(a = get_state("c", "u"), b= get_output("c","y"), c = get_output("c", "x")), m4.deployment.build)
    catch e; for d in dl(e); println(d.label, " ", d.reason, " ", d.declares, " ", d.candidates); end; end
    println(typeof(_compile_reads(reads(a = get_state("c"), b = get_deriv("c", "[2]"), c = get_output("c", :y)), m4.deployment.build)).parameters[2])
    println(diag_of(() -> _compile_reads(reads(a = get_state("c", "[2]"), b = get_face("c")), m4.deployment.build)))
    println("== primitive root")
    m5 = Model(Bare1(), Float64; Δt_frame = 1//10)
    println(typeof(_compile_reads(reads(f = get_face(), f2 = get_face("[2]") ), m5.deployment.build)).parameters[2])
    println(diag_of(() -> _compile_reads(reads(f = get_face("[3]")), m5.deployment.build)))
    println("== stateless / wrapped")
    println(diag_of(() -> _compile_reads(reads(a = get_state("src")), mm0().deployment.build)))
    try _compile_reads(reads(a = get_state("src"), b = get_deriv("src")), mm0().deployment.build)
    catch e; for d in dl(e); println(d.label, " ", d.reason, " ", d.declares, " ", d.candidates); end; end
    mw = Model(Group((; inner = readable()); input_wires = ("drive" => "inner/u", "gap" => "inner/e"), output_wires = ("inner/y" => "lift",)), Float64; Δt_frame = 1//10)
    bw = mw.deployment.build
    rw = _compile_reads(at("inner", reads(u = get_input(:u), f = get_face(:y), q = get_state("plant", :q))), bw)
    println(typeof(rw).parameters[2])
    try _compile_reads(at("inner", reads(a = get_input(:nope), b = get_face(:nope), c = get_face(:u), d = get_input(:y))), bw)
    catch e; for d in dl(e); println(d.label, " ", d.reason, " mount=", d.mount, " field=", d.field, " cand=", d.candidates); end; end
    try _compile_reads(at("inner/plant", reads(a = get_input(), b = get_face(), c = get_input("u"))), bw)
    catch e; for d in dl(e); println(d.label, " ", d.reason, " mount=", d.mount, " field=", d.field, " cand=", d.candidates, " ", d.declares); end; end
    println(diag_of(() -> _compile_reads(at("inner", at("nope", reads(a = get_input(:u)))), bw)))
    println("== m store")
    mm = Model(Group((; src = ModedSource())), Float64; Δt_frame = 1//10)
    try _compile_reads(reads(a = get_state("src", :phase), b = get_state("src")), mm.deployment.build)
    catch e; for d in dl(e); println(d.label, " ", d.reason, " ", d.declares, " ", d.candidates); end; end
    println("== docs coverage")
    api = read(joinpath(W, "docs/src/api.md"), String)
    inblock = false; apinames = String[]
    for l in split(api, '\n')
        startswith(l, "```@docs") && (inblock = true; continue)
        startswith(l, "```") && (inblock = false; continue)
        inblock && !isempty(strip(l)) && push!(apinames, strip(l))
    end
    println(length(apinames), " ", length(unique(apinames)))
    meta = Base.Docs.meta(Redstone)
    docd = sort!(unique([String(k.var) for k in keys(meta) if k isa Base.Docs.Binding && !startswith(String(k.var), "_")]))
    miss = setdiff(docd, apinames)
    appb = join(split(read(joinpath(W, "design/spec.md"), String), '\n')[14975:15445], '\n')
    appc = join(split(read(joinpath(W, "design/spec.md"), String), '\n')[15446:16090], '\n')
    println("documented, not in api.md, named in Appendix B: ", [n for n in miss if occursin(Regex("`" * n * "[`(\\[{ ]"), appb) || occursin(Regex("\\b" * n * "\\b"), appb)])
    println("n documented not in api: ", length(miss))
    println("documented, not in api.md, NOT diagnostics kinds: ", [n for n in miss if !occursin(Regex("\\b" * n * "\\b"), appc) ])
    allb = unique([m.match for m in eachmatch(r"`([A-Za-z_][A-Za-z_0-9!]*)", appb)])
    allb = unique([replace(x, "`" => "") for x in allb])
    println("Appendix B names bound in Redstone but not in api.md: ", [n for n in allb if isdefined(Redstone, Symbol(n)) && !(n in apinames) && n in docd])
    println("Appendix B names bound in Redstone, undocumented: ", [n for n in allb if isdefined(Redstone, Symbol(n)) && !(n in docd) && !(n in apinames)])
    lib = Base.Docs.meta(Redstone.Library)
    libd = sort!(unique([String(k.var) for k in keys(lib) if k isa Base.Docs.Binding && !startswith(String(k.var), "_")]))
    println("documented, not in api.md (Library): ", setdiff(libd, apinames))
    println("in api.md without binding: ", [n for n in apinames if !(isdefined(Redstone, Symbol(n)) || isdefined(Redstone.Library, Symbol(n)))])
    println("documented-at-all check: ", [n for n in apinames if isdefined(Redstone, Symbol(n)) && !(n in docd)])
end
main()
end

# S9c probe: spec §9.4-§9.6 claims. Run from the pinned worktree with --project=test.
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff
include(joinpath(pwd(), "test", "imports.jl"))
include(joinpath(pwd(), "test", "fixtures.jl"))
import Redstone: activation, Activation, scatter_group!, default_name, is_bare, _scratch

macro p(label, ex)
    quote
        local r
        try
            r = $(esc(ex))
            println("PROBE ", $(esc(label)), " => ", r)
        catch err
            println("PROBE ", $(esc(label)), " THROWS ", typeof(err), ": ",
                    first(split(sprint(showerror, err), '\n'), 3))
        end
    end
end

const CNT = Dict{Symbol,Int}()
const WST = Any[]
bump(k) = (CNT[k] = get(CNT, k, 0) + 1; nothing)

struct PCont <: AbstractComponent end
x_init(::PCont) = (q = 1.0,)
u_types(::PCont) = (u = Float64,)
y_types(::PCont) = (y = Float64, p = Float64)
y_state(::PCont, (; x)) = (bump(:c_y_state); (y = x.q,))
y_direct(::PCont, (; x, u)) = (bump(:c_y_direct); (p = u.u * x.q,))
x_deriv(::PCont, (; x, u)) = (bump(:c_x_deriv); (q = -x.q + u.u,))
x_projection(::PCont, x) = (bump(:c_proj); x)
ws_init(::PCont, ::Type{T}) where {T} = (bump(:c_ws); push!(WST, (:cont, T)); (tmp = zeros(T, 1),))
pc_guard(::PCont, (; x)) = (bump(:c_guard); x.q - 100.0)
pc_handler(::PCont, (; x)) = (bump(:c_handler); (x = (q = 0.0,),))
state_events(::PCont) = (ev = StateEvent(pc_guard, pc_handler),)

struct PDisc <: AbstractComponent end
s_init(::PDisc) = (n = 0,)
u_types(::PDisc) = (e = Float64,)
y_types(::PDisc) = (n = Int, v = Float64)
y_state(::PDisc, (; s)) = (bump(:d_y_state); (n = s.n,))
y_direct(::PDisc, (; s, u)) = (bump(:d_y_direct); (v = u.e,))
s_update(::PDisc, (; s)) = (bump(:d_s_update); (n = s.n + 1,))
ws_init(::PDisc, ::Type{T}) where {T} = (bump(:d_ws); push!(WST, (:disc, T)); (tmp = zeros(T, 1),))

root() = Group((; c = PCont(), d = PDisc()); local_wires = ("c/y" => "d/e",),
               input_wires = ("u" => "c/u",))

single(c) = Group((; c = c))
println("=== A. executable set at a Dual activation")
empty!(CNT); empty!(WST)
b = build(root())
println("PROBE A.nominal counters => ", sort(collect(CNT)))
println("PROBE A.nominal ws => ", WST)
nominal_order = b.outputs.order; nominal_comp = b.outputs.components
empty!(CNT); empty!(WST)
actD = activation(b, ProbeDual)
println("PROBE A.dual counters => ", sort(collect(CNT)))
println("PROBE A.dual ws => ", WST)
@p "A.outputs unchanged" (b.outputs.order === nominal_order && b.outputs.components === nominal_comp)
@p "A.discrete product carried" (actD.products[2] === activation(b, Float64).products[2])
@p "A.discrete product types" map(typeof, actD.products[2])
@p "A.cont product types" map(typeof, actD.products[1])
@p "A.decl x type" typeof(actD.decls[1].x)
@p "A.layout xblocks" actD.layout.xblocks
@p "A.fields Activation" fieldnames(Activation)
@p "A.isimmutable" !ismutabletype(Activation{Float64})
@p "A.cache keys" collect(keys(b.activations))
@p "A.activation cached identity" (activation(b, ProbeDual) === actD)
D2 = ForwardDiff.Dual{ProbeTag,Float64,2}
@p "A.width2 separate" (activation(b, D2); length(b.activations))
@p "A.bare Dual keys" activation(b, ForwardDiff.Dual)
@p "A.zero(bare Dual)" zero(ForwardDiff.Dual)
@p "A.ProbeDual def" (ProbeDual === ForwardDiff.Dual{ProbeTag,Float64,1})
@p "A.Build fields" fieldnames(Build)
empty!(CNT)
b2 = build(root(); activations = (Float64, ProbeDual))
println("PROBE A.exhaustive keys => ", collect(keys(b2.activations)))
println("PROBE A.exhaustive counters => ", sort(collect(CNT)))
@p "A.exhaustive exported check fn" [n for n in names(Redstone) if occursin("check", String(n)) || occursin("activations", String(n))]

println("=== B. owners")
m1 = Model(b; Δt_frame = 1//100); m2 = Model(b; Δt_frame = 1//100)
@p "B.distinct xbuf" (m1.exec.xbuf !== m2.exec.xbuf && m1.exec.store !== m2.exec.store)
@p "B.shared act" (m1.exec.act === m2.exec.act)
@p "B.scratch own buffers" (let s = _scratch(m1, ProbeDual); s.exec.store !== m1.exec.store && s.exec.act === activation(b, ProbeDual) end)
@p "B.sim owns Model{Float64}" typeof(Simulation(m1).model).parameters[1]
mD = Model(b, ProbeDual; Δt_frame = 1//100)
@p "B.dual model events" (length(mD.exec.bodies.events), length(mD.exec.bodies.projections))
@p "B.nominal model events" (length(m1.exec.bodies.events), length(m1.exec.bodies.projections))
@p "B.Model Float32 refused" Model(b, Float32; Δt_frame = 1//100)
@p "B.Model nested dual" typeof(Model(b, ForwardDiff.Dual{Nothing,ForwardDiff.Dual{Nothing,Float64,1},1}; Δt_frame = 1//100)).parameters[1]

println("=== C. generated write")
ex = m1.exec; lay = ex.act.layout
addrs = (y = lay.addr[("c", :y)], p = lay.addr[("c", :p)])
st = ex.store
@p "C.ok order1" scatter_group!(st, addrs, (; y = 1.0, p = 2.0), Float64, "c", :y_direct)
@p "C.ok order2 (permuted)" scatter_group!(st, addrs, (; p = 2.0, y = 1.0), Float64, "c", :y_direct)
@p "C.Int field" scatter_group!(st, addrs, (; p = 2.0, y = 1), Float64, "c", :y_direct)
@p "C.missing key" scatter_group!(st, addrs, (; p = 2.0), Float64, "c", :y_direct)
@p "C.extra key" scatter_group!(st, addrs, (; p = 2.0, y = 1.0, z = 3.0), Float64, "c", :y_direct)
f(st, a, y) = scatter_group!(st, a, y, Float64, "c", :y_direct)
f(st, addrs, (; y = 1.0, p = 2.0))
@p "C.alloc conformant" @allocated f(st, addrs, (; y = 1.0, p = 2.0))
ct = sprint(show, only(code_typed(f, Tuple{typeof(st), typeof(addrs), @NamedTuple{y::Float64, p::Float64}}))[1])
@p "C.conformant IR" (length(ct), occursin("ConformanceFailure", ct), occursin("throw", ct))
ct2 = sprint(show, only(code_typed(f, Tuple{typeof(st), typeof(addrs), @NamedTuple{y::Int, p::Float64}}))[1])
@p "C.bad IR" (length(ct2), occursin("ConformanceFailure", ct2), occursin("throw", ct2))
@p "C.Union return" (let g(x) = x > 0 ? (; y = 1.0, p = 2.0) : (; y = 1, p = 2.0);
    length(Base.return_types(g, (Float64,))) end)
exD = mD.exec; layD = exD.act.layout
addrsD = (y = layD.addr[("c", :y)], p = layD.addr[("c", :p)])
@p "C.dual: Float64 embeds" (scatter_group!(exD.store, addrsD, (; y = 1.0, p = 2.0), ProbeDual, "c", :y_direct);
    Redstone.gather_cell(exD.store, addrsD.y))
@p "C.dual: Dual direct" scatter_group!(exD.store, addrsD, (; y = ForwardDiff.Dual{ProbeTag}(1.0, 1.0), p = ForwardDiff.Dual{ProbeTag}(2.0, 1.0)), ProbeDual, "c", :y_direct)
@p "C.dual: Int refused" scatter_group!(exD.store, addrsD, (; y = 1, p = ForwardDiff.Dual{ProbeTag}(2.0, 1.0)), ProbeDual, "c", :y_direct)
@p "C.nominal: Dual refused" scatter_group!(st, addrs, (; y = ForwardDiff.Dual{ProbeTag}(1.0, 1.0), p = 2.0), Float64, "c", :y_direct)
@p "C.fields ConformanceFailure" fieldnames(ConformanceFailure)
@p "C.bare defaults" map(default_name, (x_init, s_init, m_init, u_types, y_types))
@p "C.bare scatter single cell" (let bm = Model(Group((; s = BareScale()); input_wires = ("u" => "s/u",)); Δt_frame = 1//100);
    a = bm.exec.act.layout.addr[("s", :y)];
    (scatter_group!(bm.exec.store, a, 1.0, Float64, "s", :y_direct), scatter_group!(bm.exec.store, a, 1, Float64, "s", :y_direct)) end)

println("=== D. laziness")
pb = build(single(PinnedState()))
@p "D.pinned build ok" typeof(pb)
@p "D.pinned dual" (activation(pb, ProbeDual))
@p "D.pinned msg" (try activation(pb, ProbeDual) catch e; only(diagnostics(e)) |> Redstone.message end)

struct HiddenWS <: AbstractComponent end
x_init(::HiddenWS) = (q = 1.0,)
y_types(::HiddenWS) = (y = Float64,)
y_state(::HiddenWS, (; x)) = (y = x.q,)
ws_init(::HiddenWS, ::Type) = (tmp = zeros(Float64, 1),)
x_deriv(::HiddenWS, (; x, ws)) = (ws.tmp[1] = x.q; (q = ws.tmp[1],))
hb = build(single(HiddenWS()))
@p "D.hidden build ok" typeof(hb)
@p "D.hidden dual msg" (try activation(hb, ProbeDual) catch e; first(split(sprint(showerror, e), "\n"), 4) end)

println("=== E. walking, pinned, stripping")
struct WalkConst{K} <: AbstractComponent end
x_init(::WalkConst) = (q = 1.0,)
y_types(::WalkConst) = (y = Float64,)
y_state(::WalkConst{:const}, (; x)) = (y = 0.0,)
y_state(::WalkConst{:int}, (; x)) = (y = 0,)
x_deriv(::WalkConst, (; x)) = (q = 0.0,)
for k in (:const, :int)
    wb = try build(single(WalkConst{k}())) catch e; e end
    @p "E.$k build" typeof(wb)
    wb isa Build || (println("PROBE E.$k msg => ", Redstone.message(only(diagnostics(wb)))); continue)
    @p "E.$k dual" (a = activation(wb, ProbeDual); a.products[1])
end
struct Strip <: AbstractComponent end
x_init(::Strip) = (q = 1.0,)
y_types(::Strip) = (F = Pinned{Float64},)
y_state(::Strip, (; x)) = (F = ForwardDiff.value(x.q),)
x_deriv(::Strip, (; x)) = (q = -x.q,)
@p "E.strip pinned ok at dual" (activation(build(single(Strip())), ProbeDual).products[1])
struct StripUnpinned <: AbstractComponent end
x_init(::StripUnpinned) = (q = 1.0,)
y_types(::StripUnpinned) = (F = Float64,)
y_state(::StripUnpinned, (; x)) = (F = ForwardDiff.value(x.q),)
x_deriv(::StripUnpinned, (; x)) = (q = -x.q,)
@p "E.strip unpinned legal" (activation(build(single(StripUnpinned())), ProbeDual).products[1])
struct PinnedInt <: AbstractComponent end
x_init(::PinnedInt) = (q = 1.0,)
y_types(::PinnedInt) = (n = Int,)
y_state(::PinnedInt, (; x)) = (n = Int(round(ForwardDiff.value(x.q))),)
x_deriv(::PinnedInt, (; x)) = (q = -x.q,)
@p "E.int leaf ok" (activation(build(single(PinnedInt())), ProbeDual).products[1])
struct Pin2 <: AbstractComponent end
x_init(::Pin2) = (q = 1.0,)
y_types(::Pin2) = (n = Int,)
y_state(::Pin2, (; x)) = (n = x.q,)
x_deriv(::Pin2, (; x)) = (q = -x.q,)
@p "E.int at nominal (Float64 for Int)" (try build(single(Pin2())) catch e; Redstone.message(only(diagnostics(e))) end)

struct Shaft{K} <: AbstractComponent end
x_init(::Shaft) = (ω = 1.0,)
u_types(::Shaft) = (M = Float64,)
y_types(::Shaft) = (P = Float64, M_shaft = Float64)
y_direct(::Shaft{:a}, (; x, u)) = (; P = u.M * x.ω, M_shaft = u.M)
y_direct(::Shaft{:b}, (; x, u)) = (; M_shaft = u.M, P = u.M * x.ω)
y_direct(::Shaft{:int}, (; x, u)) = (; P = u.M * x.ω, M_shaft = 0)
x_deriv(::Shaft, (; x, u)) = (ω = -x.ω,)
for k in (:a, :b, :int)
    r = try build(Group((; s = Shaft{k}()); input_wires = ("M" => "s/M",))) catch e; e end
    @p "E.shaft $k" (r isa Build ? "ok" : Redstone.message(only(diagnostics(r))))
end

println("=== F. per-function predicates and handlers")
struct EvK{K} <: AbstractComponent end
x_init(::EvK) = (a = 1.0, b = 2.0)
m_init(::EvK) = (k = 1.0, j = 2)
y_types(::EvK) = (y = Float64,)
y_state(::EvK, (; x)) = (y = x.a,)
x_deriv(::EvK, (; x)) = (a = 0.0, b = 0.0)
evk_guard(::EvK{:guardint}, (; x)) = 1
evk_guard(::EvK, (; x)) = x.a - 5.0
evk_handler(::EvK{:badkey}, (; x)) = (q = 1,)
evk_handler(::EvK{:xpartial}, (; x)) = (x = (a = 1.0,),)
evk_handler(::EvK{:xint}, (; x)) = (x = (a = 1, b = 2.0),)
evk_handler(::EvK{:mpartial}, (; x)) = (m = (k = 2.0,),)
evk_handler(::EvK{:mbad}, (; x)) = (m = (k = 2,),)
evk_handler(::EvK{:mnew}, (; x)) = (m = (zz = 2,),)
evk_handler(::EvK{:absent}, (; x)) = (;)
evk_handler(::EvK{:xorder}, (; x)) = (x = (b = 2.0, a = 1.0),)
evk_handler(::EvK, (; x)) = (;)
state_events(::EvK) = (e = StateEvent(evk_guard, evk_handler),)
for k in (:guardint, :badkey, :xpartial, :xint, :mpartial, :mbad, :mnew, :absent, :xorder)
    r = try build(single(EvK{k}())) catch e; e end
    @p "F.$k" (r isa Build ? "ok policy=$(only(r.events.components).policies)" :
        join((string(typeof(d), ": ", Redstone.message(d)) for d in diagnostics(r)), " | "))
end
struct NoStore <: AbstractComponent end
x_init(::NoStore) = nothing
y_types(::NoStore) = (y = Float64,)
y_state(::NoStore, _) = (y = 1.0,)
nostore_guard(::NoStore, (; t)) = true
nostore_handler(::NoStore, (; t)) = (x = (q = 1.0,), m = (z = 1,), w = 2)
state_events(::NoStore) = (e = StateEvent(nostore_guard, nostore_handler),)
@p "F.nostore" (try build(single(NoStore())) catch e; join((string(typeof(d), " stores=", getproperty(d, :stores), " :: ", Redstone.message(d)) for d in diagnostics(e) if d isa HandlerReturnKey), " | ") end)
@p "F.fieldnames HandlerReturnKey/GuardForm" (fieldnames(HandlerReturnKey), fieldnames(GuardForm))

# x_projection at Dual: bad return
struct BadProj <: AbstractComponent end
x_init(::BadProj) = (q = 1.0, r = 2.0)
y_types(::BadProj) = (y = Float64,)
y_state(::BadProj, (; x)) = (y = x.q,)
x_deriv(::BadProj, (; x)) = (q = 0.0, r = 0.0)
x_projection(::BadProj, x) = (q = x.q,)
@p "F.badproj build" (try build(single(BadProj())) catch e; join((Redstone.message(d) for d in diagnostics(e)), " | ") end)
struct DualProj <: AbstractComponent end
x_init(::DualProj) = (q = 1.0,)
y_types(::DualProj) = (y = Float64,)
y_state(::DualProj, (; x)) = (y = x.q,)
x_deriv(::DualProj, (; x)) = (q = 0.0,)
x_projection(::DualProj, x) = (q = ForwardDiff.value(x.q) + 0.0,)
@p "F.proj stripping at dual (Float64 ok)" (activation(build(single(DualProj())), ProbeDual); "ok")
# x_deriv SArray leaf at T
@p "F.sarray leaf at dual" typeof(activation(build(Group((; c = Plant()); input_wires = ("u" => "c/u",))), ProbeDual).decls[1].x.q)

# s_update exactness
struct BadUpd <: AbstractComponent end
s_init(::BadUpd) = (n = 0,)
y_types(::BadUpd) = (n = Int,)
y_state(::BadUpd, (; s)) = (n = s.n,)
s_update(::BadUpd, (; s)) = (n = 1.0,)
@p "F.s_update wrong type" (try build(single(BadUpd())) catch e; join((Redstone.message(d) for d in diagnostics(e)), " | ") end)

println("=== G. struct-valued port at a Dual activation without a constructor")
struct Pair2{T}
    a::T
    b::T
    Pair2{T}(a::Real, b::Real) where {T} = new{T}(T(a), T(b))
end
Pair2(a::Float64, b::Float64) = Pair2{Float64}(a, b)
struct Spair <: AbstractComponent end
x_init(::Spair) = (q = 1.0,)
y_types(::Spair) = (y = Pair2{Float64},)
y_state(::Spair, (; x)) = (y = Pair2{typeof(x.q)}(x.q, 2.0),)
x_deriv(::Spair, (; x)) = (q = 0.0,)
@p "G.struct port" (try build(single(Spair())); "built" catch e; first(split(sprint(showerror, e), "\n"), 3) end)
@p "G.struct port dual" (try activation(build(single(Spair())), ProbeDual); "ok" catch e; first(split(sprint(showerror, e), "\n"), 3) end)
struct Rigid
    a::Float64
end
struct Spair2 <: AbstractComponent end
x_init(::Spair2) = (q = 1.0,)
y_types(::Spair2) = (y = Rigid,)
y_state(::Spair2, (; x)) = (y = Rigid(1.0),)
x_deriv(::Spair2, (; x)) = (q = 0.0,)
@p "G.rigid dual" (try activation(build(single(Spair2())), ProbeDual); "ok" catch e; first(split(sprint(showerror, e), "\n"), 3) end)

struct Q{T}
    a::T
    Q{T}(a::Float64) where {T} = new{T}(T(a))
end
struct Spair3 <: AbstractComponent end
x_init(::Spair3) = (q = 1.0,)
y_types(::Spair3) = (y = Q{Float64},)
y_state(::Spair3, (; x)) = (y = Q{typeof(x.q)}(1.0),)
x_deriv(::Spair3, (; x)) = (q = 0.0,)
@p "G.Q dual" (try activation(build(single(Spair3())), ProbeDual); "ok" catch e; first(split(sprint(showerror, e), "\n"), 4) end)
@p "G.GuardForm msg" (try build(single(EvK{:guardint}())) catch e; Redstone.message(e.carried isa Vector ? only(e.carried) : e.carried) end)
@p "G.exports" [n for n in (:ProbeDual, :ProbeTag, :activation, :Activation) if n in names(Redstone)]
@p "G.Q gather at ProbeDual model" (let m = Model(build(single(Spair3())), ProbeDual; Δt_frame = 1//100);
    Redstone.gather_cell(m.exec.store, m.exec.act.layout.addr[("c", :y)]) end)
println("=== H. services")
@p "H.NLoptBackend defined" isdefined(Redstone, :NLoptBackend)
@p "H.LinearizeDual" LinearizeDual
@p "H.TrimTag/ProbeTag differ" (ProbeTag !== Redstone.TrimTag)
println("DONE")

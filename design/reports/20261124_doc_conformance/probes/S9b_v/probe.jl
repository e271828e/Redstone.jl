# S9b_v: independent verifier probe for spec §9.2-§9.3 claims.
using Test, StaticArrays, LinearAlgebra, ForwardDiff, Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
include(joinpath(W, "test/imports.jl"))
include(joinpath(W, "test/fixtures.jl"))
include(joinpath(W, "test/utils.jl"))

sec(s) = println("\n=== ", s)
diags(err) = err.carried isa Vector ? err.carried : [err.carried]
function try_(label, f)
    try
        r = f(); println(label, " -> ok: ", r isa Deployment ? repr(r) : typeof(r))
    catch err
        if err isa DiagnosticError
            for d in diags(err)
                println(label, " -> ", nameof(typeof(d)), " ",
                        hasproperty(d, :parameter) ? (d.parameter, d.reason, d.value) :
                        hasproperty(d, :reason) ? d.reason : "")
            end
        else
            println(label, " -> RAW ", typeof(err), ": ", first(sprint(showerror, err), 160))
        end
    end
end
pr(x) = (show(stdout, MIME"text/plain"(), x); println())

b = build(MultiRate())
sec("S9b-060 unanchored present: default path and explicit and derive")
try_("default Δt_base", () -> Deployment(b; Δt_frame = 1//500))
try_("derive", () -> Deployment(b; Δt_frame = 1//500, Δt_base = :derive))
try
    Deployment(b; Δt_frame = 1//500, Δt_base = :derive)
catch err
    d = only(diags(err)); println("unanchored grid carried: ", d.grid !== nothing, " paths ", d.paths)
end

sec("S9b-058/104 exact door")
try_("big(2)^70", () -> Deployment(b; Δt_frame = big(2)^70))
try_("1//0", () -> Deployment(b; Δt_frame = 1//0))
try_("Rational{Int32}", () -> Deployment(b; Δt_frame = Rational{Int32}(1, 500)))
try_("BigInt fits", () -> Deployment(b; Δt_frame = big(1)//500, Δt_base = big(1)//500))
try_("float", () -> Deployment(b; Δt_frame = 0.002))
try_("h_max float", () -> Deployment(b; Δt_frame = 1//500, h_max = 0.001))

sec("S9b-029/047 h_max need divide neither period; exact")
p = build(fed(Plant(), "u"))
d1 = Deployment(p; Δt_frame = 1//1, h_max = 1//3)
d2 = Deployment(p; Δt_frame = 1//1, h_max = Rational(1/3))
d3 = Deployment(p; Δt_frame = 1//2, h_max = 2//7)
println("1//3: ", Redstone._steps_line(d1), " | Rational(1/3): ", Redstone._steps_line(d2),
        " | 2//7 at frame 1//2: ", Redstone._steps_line(d3))
println("d1 == d2: ", d1 == d2, "; field types ", fieldtype(Deployment, :Δt_frame), " ", fieldtype(Deployment, :h_max))
println("resolved h_max absent vs above frame: ",
        Deployment(p; Δt_frame = 1//2) == Deployment(p; Δt_frame = 1//2, h_max = 5))

sec("S9b-020/038 h_min")
try_("BS3 no h_min", () -> Deployment(p; Δt_frame = 1//10, algorithm = BS3()))
try_("BS3 h_min ok", () -> Deployment(p; Δt_frame = 1//10, algorithm = BS3(), h_min = 1//100))
try_("BS3 h_min > h_max/2", () -> Deployment(p; Δt_frame = 1//10, algorithm = BS3(), h_min = 1//10))
try_("RK4 h_min recorded", () -> Deployment(p; Δt_frame = 1//10, h_min = 1//100))

sec("S9b-112 algorithm the seam does not know")
struct MyAlg <: AbstractAlgorithm end
try_("algorithm = :euler", () -> Deployment(p; Δt_frame = 1//10, algorithm = :euler))
try_("algorithm = MyAlg()", () -> Deployment(p; Δt_frame = 1//10, algorithm = MyAlg()))

sec("S9b-114 budgets")
for (k, v) in ((:firing_budget, 0), (:firing_budget, 2.0), (:localization_budget, -1),
               (:attempt_budget, 0), (:attempt_budget, true), (:firing_budget, big(2)^70),
               (:attempt_budget, Int8(3)))
    try_("$k = $(repr(v))", () -> Deployment(p; Δt_frame = 1//10, (k => v,)...))
end

sec("S9b-011 Model scalar")
dp = Deployment(p; Δt_frame = 1//10)
try_("Float32", () -> Model(dp, Float32))
try_("BigFloat", () -> Model(dp, BigFloat))
try_("Dual{Nothing,Float32,1}", () -> Model(dp, ForwardDiff.Dual{Nothing,Float32,1}))
try_("D8", () -> Model(dp, D8))

sec("S9b-001/008 Deployment fields")
println(fieldnames(Deployment)); println(isconcretetype(Deployment))

sec("S9b-077 divisor past Int is Δt_base's :range")
deep = Group((; src = Ramp(1.0),
                sc = Group((; g = ZOH()); input_wires = ("in" => "g/in",),
                           sample_times = (; g = Relative(2^20))));
             local_wires = ("src/out" => "sc/in",), sample_times = (; sc = Absolute(1//1)))
bd = build(deep)
try_("Δt_base = 1//2^50", () -> Deployment(bd; Δt_frame = 1//1, Δt_base = 1//2^50))
try_("Δt_base = 1//2^20", () -> Deployment(bd; Δt_frame = 1//1, Δt_base = 1//2^20))

sec("show MultiRate deployment at Δt_base 1//500 frame 1//100")
dm = Deployment(b; Δt_frame = 1//100, Δt_base = 1//500)
pr(dm)
sec("show MultiRate at Δt_base 1//1000")
pr(Deployment(b; Δt_frame = 1//100, Δt_base = 1//1000))
sec("show Structure / Schedule / Events")
pr(b.structure); pr(dm.schedule); pr(b.events)

sec("S9b-225 driving offset alternatives; S9b-216 factors")
off = Group((; src = Ramp(1.0), g = ZOH(), h = ZOH());
            local_wires = ("src/out" => "g/in", "src/out" => "h/in"),
            sample_times = (; g = Absolute(1//50, 1//1000), h = Absolute(1//20)))
bo = build(off)
pr(bo.structure)
try_("Δt_base 1//100 (non-dividing offset)", () -> Deployment(bo; Δt_frame = 1//100, Δt_base = 1//100))
try Deployment(bo; Δt_frame = 1//100, Δt_base = 1//100) catch err
    println(sprint(showerror, err))
end
single_anchor = build(Group((; src = Ramp(1.0), g = ZOH()); local_wires = ("src/out" => "g/in",),
                            sample_times = (; g = Absolute(1//50))))
println("singleton factor: ", [e.factor for e in Redstone._grid_report(single_anchor.structure.anchors).pool])
println("derive on all-anchored: ")
dd = Deployment(bo; Δt_frame = 1//100, Δt_base = :derive)
println("derived ", dd.Δt_base, " warnings ", warnings(dd))

sec("S9b-280 probe_value StaticArray arm")
println("probe_value(SVector{3,Float64}) = ", probe_value(SVector{3,Float64}))
println("which: ", which(probe_value, Tuple{Type{SVector{3,Float64}}}))
try SVector{3,Float64}() ; println("SVector{3,Float64}() ok") catch err println("SVector{3,Float64}() throws ", typeof(err)) end
struct VecIn <: AbstractComponent end
x_init(::VecIn) = nothing
u_types(::VecIn) = (v = SVector{3,Float64},)
y_types(::VecIn) = (y = Float64,)
y_direct(::VecIn, (; u)) = (y = sum(u.v),)
bv = build(fed(VecIn(), "v"))
println("SVector root input synthesized: ", activation(bv, Float64).layout.root_inputs)

sec("S9b-290 missing probe_value message")
struct NoDef; a::Float64; end
struct NoDefIn <: AbstractComponent end
x_init(::NoDefIn) = nothing
u_types(::NoDefIn) = (v = NoDef,)
y_types(::NoDefIn) = (y = Float64,)
y_direct(::NoDefIn, (; u)) = (y = u.v.a,)
try build(fed(NoDefIn(), "v")) catch err println(sprint(showerror, err)) end

sec("S9b-298 abstract co-consumer of a root input")
struct AbsIn <: AbstractComponent end
x_init(::AbsIn) = nothing
u_types(::AbsIn) = (u = Real,)
y_types(::AbsIn) = (y = Float64,)
y_direct(::AbsIn, (; u)) = (y = Float64(u.u),)
co = Group((; n = Negator(), a = AbsIn()); input_wires = ("in" => ("n/u", "a/u"),))
try
    bc = build(co)
    println("built; root types ", bc.structure.root_types, "; AbsIn entry ", u_types(AbsIn()))
catch err
    println("refused: ", sprint(showerror, err))
end

sec("S9b-312 runtime throw")
sim = Simulation(fed(Tripwire(0.05), "arm"); Δt_frame = 1//10)
init!(sim, set(u = (in = true,)))
err = failure(() -> run!(sim; t_end = 5.0))
println(typeof(err), " lifecycle ", lifecycle(sim))
println("warnings(sim) methods: ", methods(warnings))
if @isdefined(bc) || true
    try
        bc2 = build(co)
        println("co-consumer probe input to a/u: ", activation(bc2, Float64).layout.root_inputs)
        pr(bc2.structure)
    catch err
        println("refused 2: ", sprint(showerror, err))
    end
end

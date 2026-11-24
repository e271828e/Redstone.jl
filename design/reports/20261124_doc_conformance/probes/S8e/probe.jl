# S8e probe: spec §8.7 and §8.8 (lines 4326-4767).
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
include(joinpath(W, "test/imports.jl"))
include(joinpath(W, "test/fixtures.jl"))
include(joinpath(W, "test/utils.jl"))
include(joinpath(W, "test/test_assembly.jl"))
include(joinpath(W, "test/test_build.jl"))

dl(e) = e isa DiagnosticError ? (e.carried isa Diagnostic ? Diagnostic[e.carried] : e.carried) : Diagnostic[]
desc(d) = d isa Diagnostic ?
    string(nameof(typeof(d)), "(", join(("$f=$(repr(getfield(d, f)))" for f in (:reason, :key, :call, :argument, :selector, :who) if hasfield(typeof(d), f) && getfield(d, f) !== nothing), ", "), ")") : repr(d)
function tryit(label, f)
    try
        r = f()
        println("OK   $label => ", r isa Union{Model,Build} ? nameof(typeof(r)) : r)
        return r
    catch e
        if e isa DiagnosticError
            ds = dl(e)
            println("ERR  $label => ", join((desc(d) for d in ds), " | "))
        else
            println("EXC  $label => ", sprint(showerror, e)[1:min(end, 200)])
        end
        return e
    end
end
hdr(s) = println("\n=== ", s)

hdr("P1 constructors")
tryit("Absolute(1//50)", () -> Absolute(1//50))
tryit("Absolute(50)", () -> Absolute(50))
tryit("Absolute(0.02)", () -> Absolute(0.02))
tryit("Absolute(1//50, 0.5)", () -> Absolute(1//50, 0.5))
tryit("Absolute(Int8(2), Int16(1))", () -> Absolute(Int8(2), Int16(1)))
tryit("Absolute(big(1)//50)", () -> Absolute(big(1)//50))
tryit("Absolute(big(1)//big(2)^70)", () -> Absolute(big(1)//big(2)^70))
tryit("Absolute(1//0)", () -> Absolute(1//0))
tryit("Absolute(1, 1//0)", () -> Absolute(1, 1//0))
tryit("Absolute(Inf)", () -> Absolute(Inf))
tryit("Absolute(0)", () -> Absolute(0))
tryit("Absolute(-1)", () -> Absolute(-1))
tryit("Absolute(1.0f0)", () -> Absolute(1.0f0))
tryit("Absolute(2.0+0im)", () -> Absolute(2.0))
tryit("Absolute(true)", () -> Absolute(true))
r = tryit("Absolute(1//50) types", () -> (typeof(Absolute(1//50).Δt), typeof(Absolute(2).τ)))
tryit("Relative(2)", () -> Relative(2))
tryit("Relative(2,1)", () -> Relative(2, 1))
tryit("Relative(Int8(2), UInt16(1))", () -> Relative(Int8(2), UInt16(1)))
tryit("Relative(big(2), big(1))", () -> Relative(big(2), big(1)))
tryit("Relative(big(2)^70)", () -> Relative(big(2)^70))
tryit("Relative(2, big(2)^70)", () -> Relative(2, big(2)^70))
tryit("Relative(2.0)", () -> Relative(2.0))
tryit("Relative(1//2)", () -> Relative(1//2))
tryit("Relative(2, 0.5)", () -> Relative(2, 0.5))
tryit("Relative(2, 1//2)", () -> Relative(2, 1//2))
tryit("Relative(0)", () -> Relative(0))
tryit("Relative(-3, 9)", () -> Relative(-3, 9))
for (lab, f) in (("Relative(2.0)", () -> Relative(2.0)), ("Relative(1//2)", () -> Relative(1//2)),
                 ("Absolute(0.02)", () -> Absolute(0.02)), ("Relative(big(2)^70)", () -> Relative(big(2)^70)),
                 ("Absolute(1//0)", () -> Absolute(1//0)))
    e = try f() catch e e end
    println("MSG $lab: ", message(dl(e)[1]))
end

hdr("P2 sample_times shape, keys")
struct VA <: AbstractComponent
    nav::TickCounter
    gnss::TickCounter
end
local_wires(::VA) = ()
sample_times(::VA) = (nav = Relative(5), gnss = Absolute(1//10))
m = tryit("VA model", () -> Model(VA(TickCounter(), TickCounter()); Δt_frame = 1//10, Δt_base = 1//100))
m isa Model && foreach(r -> println("   row ", r.path, " anchor=", r.anchor, " D=", r.D, " Φ=", r.Φ, " Δt=", r.Δt), m.deployment.schedule.rows)
m isa Model && println("   anchors ", m.deployment.build.structure.anchors)

struct VBare <: AbstractComponent; nav::TickCounter; end
local_wires(::VBare) = ()
sample_times(::VBare) = (nav = 5,)
tryit("bare integer", () -> build(VBare(TickCounter())))
struct VRat <: AbstractComponent; nav::TickCounter; end
local_wires(::VRat) = ()
sample_times(::VRat) = (nav = 1//10,)
tryit("bare rational", () -> build(VRat(TickCounter())))
struct VDeep <: AbstractComponent; fcs::Group; end
local_wires(::VDeep) = ()
sample_times(::VDeep) = (var"fcs/a" = Relative(2),)
tryit("deep key", () -> build(VDeep(Group((; a = TickCounter())))))
struct VUnk <: AbstractComponent; nav::TickCounter; end
local_wires(::VUnk) = ()
sample_times(::VUnk) = (zzz = Relative(2),)
tryit("unknown key", () -> build(VUnk(TickCounter())))
struct VCont <: AbstractComponent; p::BareFlow; end
local_wires(::VCont) = ()
sample_times(::VCont) = (p = Relative(2),)
tryit("continuous child key", () -> build(VCont(BareFlow())))
struct VNone <: AbstractComponent; nav::TickCounter; g::TickCounter; end
local_wires(::VNone) = ()
sample_times(::VNone) = (nav = Relative(3),)
m = tryit("unlisted default", () -> Model(VNone(TickCounter(), TickCounter()); Δt_frame = 1//10, Δt_base = 1//100))
m isa Model && foreach(r -> println("   row ", r.path, " D=", r.D, " Φ=", r.Φ), m.deployment.schedule.rows)
struct VNoDecl <: AbstractComponent; nav::TickCounter; end
m = tryit("no declaration", () -> Model(VNoDecl(TickCounter()); Δt_frame = 1//10, Δt_base = 1//100))
m isa Model && foreach(r -> println("   row ", r.path, " D=", r.D, " Φ=", r.Φ), m.deployment.schedule.rows)
tryit("sample_times default", () -> sample_times(VNoDecl(TickCounter())))
# constructors are plain carriers: no range checks
tryit("plain carriers", () -> (Relative(0), Relative(3, 7), Absolute(-1), Absolute(1, 5)))
struct VRangeR <: AbstractComponent; nav::TickCounter; end
local_wires(::VRangeR) = ()
sample_times(::VRangeR) = (nav = Relative(3, 3),)
tryit("range Φ≥D build", () -> build(VRangeR(TickCounter())))
struct VRangeA <: AbstractComponent; nav::TickCounter; end
local_wires(::VRangeA) = ()
sample_times(::VRangeA) = (nav = Absolute(1, 1),)
tryit("range τ≥Δt build", () -> build(VRangeA(TickCounter())))
struct VRangeD <: AbstractComponent; nav::TickCounter; end
local_wires(::VRangeD) = ()
sample_times(::VRangeD) = (nav = Relative(0),)
tryit("range D=0 build", () -> build(VRangeD(TickCounter())))
struct VOver <: AbstractComponent; fcs::Group; end
local_wires(::VOver) = ()
sample_times(::VOver) = (fcs = Relative(2^40),)
tryit("composition past Int", () -> build(VOver(Group((; a = TickCounter()); sample_times = (a = Relative(2^40),)))))

hdr("P3 containers and Group sugar")
struct Fleet <: AbstractComponent
    units::NamedTuple{(:red, :blue), Tuple{TickCounter, TickCounter}}
end
local_wires(::Fleet) = ()
sample_times(::Fleet) = (units = Relative(2),)
m = tryit("bare field name sugar", () -> Model(Fleet((; red = TickCounter(), blue = TickCounter())); Δt_frame = 1//10, Δt_base = 1//100))
m isa Model && foreach(r -> println("   row ", r.path, " D=", r.D, " Φ=", r.Φ), m.deployment.schedule.rows)
struct Fleet2 <: AbstractComponent
    units::NamedTuple{(:red, :blue), Tuple{TickCounter, TickCounter}}
end
local_wires(::Fleet2) = ()
sample_times(::Fleet2) = (var"units/red" = Relative(3), var"units/blue" = Absolute(1//10))
m = tryit("path key per element", () -> Model(Fleet2((; red = TickCounter(), blue = TickCounter())); Δt_frame = 1//10, Δt_base = 1//100))
m isa Model && foreach(r -> println("   row ", r.path, " anchor=", r.anchor, " D=", r.D, " Φ=", r.Φ), m.deployment.schedule.rows)
g = Group((; a = TickCounter(), b = TickCounter()); sample_times = (children = Relative(2),))
m = tryit("Group children sugar", () -> Model(g; Δt_frame = 1//10, Δt_base = 1//100))
m isa Model && foreach(r -> println("   row ", r.path, " D=", r.D, " Φ=", r.Φ), m.deployment.schedule.rows)
g2 = Group((; a = TickCounter(), b = TickCounter()); sample_times = (a = Relative(2),))
m = tryit("Group bare element key", () -> Model(g2; Δt_frame = 1//10, Δt_base = 1//100))
m isa Model && foreach(r -> println("   row ", r.path, " D=", r.D, " Φ=", r.Φ), m.deployment.schedule.rows)

hdr("P4 scope example 2 ms")
struct Vehicle1 <: AbstractComponent; fcs::Any; end
struct Vehicle2 <: AbstractComponent; fcs::Any; end
struct FCS1 <: AbstractComponent; inner::TickCounter; outer::TickCounter; end
struct FCS2 <: AbstractComponent; inner::TickCounter; outer::TickCounter; end
struct FCS3 <: AbstractComponent; inner::TickCounter; outer::TickCounter; end
struct FCS4 <: AbstractComponent; inner::TickCounter; outer::TickCounter; end
local_wires(::Vehicle1) = ()
sample_times(::Vehicle1) = (fcs = Relative(2),)
sample_times(::FCS1)     = (inner = Relative(1), outer = Relative(5))
local_wires(::Vehicle2) = ()
sample_times(::Vehicle2) = (fcs = Relative(1),)
sample_times(::FCS2)     = (inner = Relative(2), outer = Relative(10))
sample_times(::FCS3)     = (inner = Relative(2), outer = Relative(10, 1))
sample_times(::FCS4)     = (inner = Relative(1), outer = Relative(5, 1))
for T in (FCS1,FCS2,FCS3,FCS4); @eval local_wires(::$T) = (); end
tc() = (TickCounter(), TickCounter())
for (lab, root) in (("scope at fastest", Vehicle1(FCS1(tc()...))), ("scope finer", Vehicle2(FCS2(tc()...))),
                    ("finer, outer phase 1", Vehicle2(FCS3(tc()...))), ("fastest, outer phase 1", Vehicle1(FCS4(tc()...))))
    m = tryit(lab, () -> Model(root; Δt_frame = 20//1000, Δt_base = 2//1000))
    m isa Model && foreach(r -> println("   row ", r.path, " D=", r.D, " Φ=", r.Φ, " Δt=", r.Δt, " → period ms ", 2r.D, " offset ms ", 2r.Φ), m.deployment.schedule.rows)
    m isa Model && println("   scopes ", m.deployment.schedule.scopes)
end
# grid report with Δt_base not given
for (lab, root) in (("scope at fastest", Vehicle1(FCS1(tc()...))), ("scope finer", Vehicle2(FCS2(tc()...))))
    m = tryit(lab * " no base", () -> Model(root; Δt_frame = 20//1000))
    m isa Model && println("   Δt_base ", m.deployment.Δt_base, " warnings ", length(m.deployment.warnings))
end
# FCS with a no-phase-but-finer scope fed wih Φ
hdr("P5 Δt in the bundle")
struct DtD <: AbstractComponent end
s_init(::DtD) = (n = 0, dt = 0.0)
y_types(::DtD) = (a = Float64, b = Float64)
u_types(::DtD) = (e = Float64,)
y_state(::DtD, (; s, Δt)) = (a = Δt,)
y_direct(::DtD, (; s, u, Δt)) = (b = 2Δt * u.e,)
s_update(::DtD, (; s, Δt)) = (n = s.n + 1, dt = Δt)
struct DtRoot <: AbstractComponent; d::DtD; end
input_wires(::DtRoot) = ("in" => "d/e",)
local_wires(::DtRoot) = ()
sample_times(::DtRoot) = (d = Relative(5),)
tryit("Δt bundle build", () -> build(DtRoot(DtD())))
sim = tryit("Δt sim", () -> Simulation(DtRoot(DtD()); Δt_frame = 1//10, Δt_base = 1//100))
if sim isa Simulation
    init!(sim, set(u = (in = 1.0,)))
    println("   y a=", port(sim, "d", :a), " b=", port(sim, "d", :b))
    run!(sim; t_end = 0.2)
    println("   after run s=", state(sim, "d"))
end
struct ContDt <: AbstractComponent end
x_init(::ContDt) = 0.0
x_deriv(::ContDt, (; x)) = -x
y_types(::ContDt) = Float64
y_state(::ContDt, (; x, Δt)) = x
tryit("Δt on continuous y_state", () -> build(ContDt()))
struct ContDt2 <: AbstractComponent end
x_init(::ContDt2) = 0.0
y_types(::ContDt2) = Float64
u_types(::ContDt2) = Float64
y_direct(::ContDt2, (; x, u, Δt)) = x
x_deriv(::ContDt2, (; x, u)) = u
tryit("Δt on continuous y_direct", () -> build(ContDt2()))
println("LEGAL_BUNDLE discrete: ", [(k, v) for (k, v) in LEGAL_BUNDLE if k[2] === DISCRETE])
println("LEGAL_BUNDLE continuous contains Δt? ", any(:Δt in v for (k, v) in LEGAL_BUNDLE if k[2] === CONTINUOUS))

hdr("P6 passthrough")
passed = Passed(faced(), Gain(3.0))
println("input_wires ", input_wires(passed), " output_wires ", output_wires(passed))
println("faced faces ", input_faces(faced()), output_faces(faced()))
tryit("multiple selectors", () -> input_passthrough(faced(), ""; except = ("a",), only = ("b",)))
# helper needs a parent: use Group child
mk(; kw...) = Group((; k = faced()); input_wires = g -> input_passthrough(g, "k"; kw...))
mko(; kw...) = Group((; k = faced()); output_wires = g -> output_passthrough(g, "k"; kw...), input_wires = ("a" => "k/a", "b" => "k/b"))
function bw(label, root)
    b = tryit(label, () -> build(root))
    b isa Build && println("   warnings ", [desc(w) for w in warnings(b)], " root_inputs ", b.structure.root_inputs)
    b
end
hdr("multi")
e = failure(() -> build(mk(except = ("a",), only = ("b",))))
println("multiple: ", e isa DiagnosticError ? [(nameof(typeof(d)), d.reason, d.names, d.who, d.path) for d in dl(e)] : e)
let e = failure(() -> build(mk(except = ("a",), select = _ -> true)))
    println("except+select: ", e isa DiagnosticError ? [(d.reason, d.names) for d in dl(e)] : e)
end
let e = failure(() -> build(mk(only = ("b",), select = _ -> true, except = ("a",))))
    println("three: ", e isa DiagnosticError ? [(d.reason, d.names) for d in dl(e)] : e)
    println(message(dl(e)[1]))
end
let e = failure(() -> build(mk(except = ("zz",))))
    d = dl(e)[1]; println("unknown except: ", d.reason, d.names, d.candidates)
end
let e = failure(() -> build(mk(only = ("zz",))))
    d = dl(e)[1]; println("unknown only: ", d.reason, d.names, d.candidates)
end
bw("select", mk(select = n -> n == "b"))
bw("select none", mk(select = n -> false))
bw("only", mk(only = ("a",)))
bw("except all", Group((; k = faced()); input_wires = g -> (input_passthrough(g, "k"; except = ("a", "b"))...,), local_wires = ()))
bw("bare call", mk())
bw("prefix empty", mk(prefix = ""))
bw("prefix custom sep", mk(prefix = "env", sep = "_"))
bw("default prefix k", mk(sep = "_"))
let b = bw("except all (two-fed)", Group((; k = faced(), src = Gain(1.0)); input_wires = g -> (input_passthrough(g, "k"; except = ("a", "b"))..., "in" => "src/e"), local_wires = ("src/out" => "k/a", "src/out" => "k/b")))
    w = warnings(b); !isempty(w) && (d = w[1]; println("   payload who=", d.who, " path=", d.path, " selector=", d.selector, " names=", d.names, " cand=", d.candidates); println("   ", message(d)))
end
let b = bw("select none payload", Group((; k = faced(), src = Gain(1.0)); input_wires = g -> (input_passthrough(g, "k"; select = _ -> false)..., "in" => "src/e"), local_wires = ("src/out" => "k/a", "src/out" => "k/b")))
    w = warnings(b); !isempty(w) && (d = w[1]; println("   payload ", d.who, d.path, d.selector, d.names, d.candidates))
end
# faceless child, bare call
struct NoIn <: AbstractComponent end
s_init(::NoIn) = (n = 0,)
y_types(::NoIn) = (z = Float64,)
y_state(::NoIn, (; s)) = (z = 0.0,)
s_update(::NoIn, (; s)) = (n = s.n,)
let b = bw("faceless bare", Group((; k = NoIn()); input_wires = g -> input_passthrough(g, "k")))
end
bw("faceless with except", Group((; k = NoIn()); input_wires = g -> input_passthrough(g, "k"; except = ("x",))))
bw("faceless with select", Group((; k = NoIn()); input_wires = g -> input_passthrough(g, "k"; select = _ -> true)))
println("only= () empty tuple counts as not given: ", failure(() -> build(mk(only = (), except = ("a",)))) isa Exception)
# output side
bw("output only", mko(only = ("scaled",)))
let b = bw("out wires", mko())
    println("   ", output_wires(mko()) isa Function)
end
# direct entries
let g = Group((; k = faced()))
    println("direct input ", input_passthrough(g, "k"))
    println("direct output ", output_passthrough(g, "k"))
    println("direct input sep", input_passthrough(g, "k"; sep = "_"))
    println("explicit prefix verbatim ", input_passthrough(g, "k"; prefix = "a/b"))
    println("prefix empty ", input_passthrough(g, "k"; prefix = ""))
    println("select ", input_passthrough(g, "k"; select = n -> n == "a"))
    println("only order ", input_passthrough(g, "k"; only = ("b", "a")))
    println("except ", input_passthrough(g, "k"; except = ("a",)))
    println("output except ", output_passthrough(g, "k"; except = ("sum",)))
    tryit("deeper path", () -> input_passthrough(g, "k/s"))
    tryit("unknown child", () -> input_passthrough(g, "zz"))
    tryit("empty child path", () -> input_passthrough(g, ""))
end
# bare contract children
struct BareBoth <: AbstractComponent end
x_init(::BareBoth) = nothing
u_types(::BareBoth) = Float64
y_types(::BareBoth) = Float64
y_direct(::BareBoth, (; u)) = u
let g = Group((; integrator = BareFlow()))
    println("bare input ", input_passthrough(g, "integrator"), " output ", output_passthrough(g, "integrator"))
    println("bare faces ", input_faces(BareFlow()), output_faces(BareFlow()))
    println("bare prefix empty ", input_passthrough(g, "integrator"; prefix = ""), output_passthrough(g, "integrator"; prefix = ""))
    both = Group((; integrator = BareFlow()); input_wires = g -> input_passthrough(g, "integrator"), output_wires = g -> output_passthrough(g, "integrator"))
    b = bw("bare both default", both)
    both2 = Group((; integrator = BareFlow()); input_wires = g -> input_passthrough(g, "integrator"; prefix = ""), output_wires = g -> output_passthrough(g, "integrator"; prefix = ""))
    bw("bare both prefix empty", both2)
    b2 = Group((; integrator = BareFlow()); input_wires = g -> input_passthrough(g, "integrator"; prefix = ""), output_wires = g -> output_passthrough(g, "integrator"; prefix = "")); 
end
# bare contract of the declared side differs: assembly input_faces
tryit("input_faces BareFlow", () -> input_faces(BareFlow()))
# container child path
struct Gear <: AbstractComponent; gear::NamedTuple{(Symbol("1"), :b), Tuple{Gain, Gain}}; end
struct Hangar <: AbstractComponent; gear::NamedTuple{(Symbol("1"), :b), Tuple{Gain, Gain}}; end
local_wires(::Hangar) = ()
input_wires(h::Hangar) = (input_passthrough(h, "gear/1")..., input_passthrough(h, "gear/b"; sep = "_")...)
let h = Hangar((; var"1" = Gain(1.0), b = Gain(2.0)))
    println("container entries ", input_wires(h))
    tryit("container build", () -> build(h))
    println("   root_inputs ", build(h).structure.root_inputs)
end

hdr("P6b errors: unconnected, two producers, collision")
struct Unwired <: AbstractComponent
    inner::typeof(faced())
    trim::Gain
end
local_wires(::Unwired) = ()
input_wires(u::Unwired) = (input_passthrough(u, "inner"; except = ("a",))..., "e" => "trim/e")
bw("except unwired", Unwired(faced(), Gain(3.0)))
bw("Passed", passed)
bw("DoubleClaimed", DoubleClaimed(faced(), Gain(3.0)))
bw("Unprefixed collision", Unprefixed(faced(), Gain(3.0)))
bw("Systems one", Systems{:one}(ldg()))
bw("Systems two", Systems{:two}(ldg()))
bw("Systems typo", Systems{:typo}(ldg()))
println("fed_faces ", fed_faces(ACT_FEEDS, "aero"), fed_faces(ACT_FEEDS, "ldg"))
println("Systems one input_wires ", input_wires(Systems{:one}(ldg())))
println("Systems two input_wires ", input_wires(Systems{:two}(ldg())))
println("ldg faces ", input_faces(ldg()))
# omitted pair: drop a feed => face joins surface (tested above: Systems one vs two root inputs)
# hand-written dup of passthrough entries mixing
# deriving except from local_wires would auto-bubble: not an API
println("fed export? ", isdefined(Redstone, :fed), " declaration_error ", isdefined(Redstone, :declaration_error))

hdr("P7 generic holding")
struct GenW{L <: AbstractComponent} <: AbstractComponent
    inner::L
    g::Gain
end
local_wires(::GenW) = ("g/out" => "inner/missing",)
input_wires(::GenW) = ("in" => "g/e", "ref" => "inner/ref")
output_wires(::GenW) = ("inner/y" => "y",)
let e = failure(() -> build(GenW(SampledLoop(), Gain(1.0))))
    println("generic hold missing face: ", [desc(d) for d in dl(e)])
    for d in dl(e); println("   ", message(d)); end
    end
struct GenOK{L <: AbstractComponent} <: AbstractComponent
    inner::L
end
local_wires(::GenOK) = ()
input_wires(::GenOK) = ("ref" => "inner/ref",)
output_wires(::GenOK) = ("inner/y" => "y",)
bw("generic ok", GenOK(SampledLoop()))
# scalar faces compose partial scripting
println("input faces (SampledLoop) ", input_faces(SampledLoop()))

hdr("P8 grid report finer scope (derived grid)")
struct VehA <: AbstractComponent; fcs::Any; end
struct VehB <: AbstractComponent; fcs::Any; end
local_wires(::VehA) = ()
local_wires(::VehB) = ()
sample_times(::VehA) = (fcs = Absolute(1//250),)
sample_times(::VehB) = (fcs = Absolute(1//500),)
for (lab, root) in (("A scope at fastest member", VehA(FCS1(tc()...))), ("B scope finer", VehB(FCS2(tc()...))))
    m = tryit(lab, () -> Model(root; Δt_frame = 1//10, Δt_base = :derive))
    m isa Exception && println("   ", message(dl(m)[1]))
    m isa Model && (println("   Δt_base ", m.deployment.Δt_base, " warnings ", [(desc(w), w isa Redstone.GridUtilization ? w.utilization : nothing) for w in m.deployment.warnings]);
        foreach(r -> println("   row ", r.path, " D=", r.D), m.deployment.schedule.rows))
end
hdr("P9 bundled face partial write")
probe_value(::Type{@NamedTuple{a::Float64, b::Float64}}) = (a = 0.0, b = 0.0)
struct BundIn <: AbstractComponent end
x_init(::BundIn) = nothing
u_types(::BundIn) = (v = @NamedTuple{a::Float64, b::Float64}, mode_req = Float64)
y_types(::BundIn) = (o = Float64,)
y_direct(::BundIn, (; u)) = (o = u.v.a + u.v.b + u.mode_req,)
sim = Simulation(Group((; c = BundIn()); input_wires = ("v" => "c/v", "mode_req" => "c/mode_req")); Δt_frame = 1//10)
tryit("partial bundle write", () -> init!(sim, set(u = (v = (a = 1.0,), mode_req = 1.0))))
tryit("scalar partial write", () -> init!(sim, set(u = (v = (a = 1.0, b = 2.0),))))

hdr("P10 spec literal blocks")
# the spec's local_wires shape, ellipsis dropped
lw = ((("act/" * src) => dst for (src, dst) in ACT_FEEDS)..., "aero/wrench" => "wr_sum/in1")
println("literal local_wires: ", lw)
struct SysS <: AbstractComponent
    act::Actuator
    aero::Aero
    ldg::Group
end
input_wires(sys::SysS) = (
    input_passthrough(sys, "aero"; except = fed_faces(ACT_FEEDS, "aero"))...,
    input_passthrough(sys, "ldg";  except = fed_faces(ACT_FEEDS, "ldg"))...,
)
gear() = Group((; left = Gain(1.0)); input_wires = ("left.brake" => "left/e",), output_wires = ("left/out" => "damaged",))
output_wires(sys::SysS) = (
    output_passthrough(sys, "ldg"; only = ("damaged",))...,
    "aero/wrench" => "wrench",
)
local_wires(::SysS) = (("act/" * src) => dst for (src, dst) in ACT_FEEDS if startswith(dst, "aero/"))
let s = SysS(Actuator(), Aero(), gear())
    println("SysS input_wires ", input_wires(s))
    println("SysS output_wires ", output_wires(s))
end
# World sketch labels
struct Pilot <: AbstractComponent end
x_init(::Pilot) = nothing
u_types(::Pilot) = (var"pilot.throttle_axis" = Float64, atm = Float64, trn = Float64)
y_types(::Pilot) = (pose = Float64,)
y_direct(::Pilot, (; u)) = (pose = u.atm,)
struct Atm <: AbstractComponent end
x_init(::Atm) = nothing
u_types(::Atm) = (wind_N = Float64,)
y_types(::Atm) = (o = Float64,)
y_direct(::Atm, (; u)) = (o = u.wind_N,)
struct World <: AbstractComponent
    aircraft::Pilot
    atmosphere::Atm
end
local_wires(::World) = ()
input_wires(w::World) = (
    input_passthrough(w, "aircraft"; except = ("atm", "trn"))...,
    input_passthrough(w, "atmosphere"; prefix = "env", sep = "_")...,
)
output_wires(w::World) = ("aircraft/pose" => "view_pose",)
let w = World(Pilot(), Atm())
    println("World input_wires ", input_wires(w))
end

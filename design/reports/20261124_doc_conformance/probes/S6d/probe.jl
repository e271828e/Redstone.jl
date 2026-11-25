module P
using Test, StaticArrays, LinearAlgebra, ForwardDiff
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
include(joinpath(W, "test", "imports.jl"))
include(joinpath(W, "test", "fixtures.jl"))
include(joinpath(W, "test", "utils.jl"))

res(f) = try f(); :ok catch e; e isa DiagnosticError ? [(typeof(d).name.name, hasproperty(d,:reason) ? d.reason : nothing, hasproperty(d,:classification) ? d.classification : nothing) for d in diagnostics(e)] : e end

struct Leaf <: AbstractComponent end
x_init(::Leaf) = nothing
u_types(::Leaf) = (trn_field = Float64,)
y_types(::Leaf) = (h = Float64,)
y_direct(::Leaf, (; u)) = (h = u.trn_field,)
struct Ldg <: AbstractComponent; left::Leaf; right::Leaf; nose::Leaf; end
local_wires(::Ldg) = ()
input_wires(::Ldg) = ("trn" => ("left/trn_field", "right/trn_field", "nose/trn_field"),)
struct Systems <: AbstractComponent; ldg::Ldg; end
local_wires(::Systems) = ()
input_wires(::Systems) = ("trn" => "ldg/trn",)
struct Cessna172 <: AbstractComponent; systems::Systems; end
local_wires(::Cessna172) = ()
input_wires(::Cessna172) = ("trn" => "systems/trn",)
mk() = Cessna172(Systems(Ldg(Leaf(), Leaf(), Leaf())))
b = build(mk())
println("A fanout builds: ", b isa Build, " root_inputs=", b.structure.root_inputs, " warnings=", length(warnings(b)))   # probe:32
# deep path
struct Deep <: AbstractComponent; systems::Systems; end
local_wires(::Deep) = ()
input_wires(::Deep) = ("trn" => "systems/ldg/trn",)
println("B deep input_wires: ", res(() -> build(Deep(Systems(Ldg(Leaf(), Leaf(), Leaf()))))))   # probe:38
struct DeepOut <: AbstractComponent; systems::Systems; end
local_wires(::DeepOut) = ()
input_wires(::DeepOut) = ("trn" => "systems/trn",)
output_wires(::DeepOut) = ("systems/ldg/left/h" => "h",)
println("B2 deep output_wires: ", res(() -> build(DeepOut(Systems(Ldg(Leaf(), Leaf(), Leaf()))))))   # probe:43
struct DeepLoc <: AbstractComponent; a::Cessna172; l::Leaf; end
local_wires(::DeepLoc) = ("a/systems/ldg/left/h" => "l/trn_field",)
input_wires(::DeepLoc) = ("trn" => "a/trn",)
println("B3 deep local_wires: ", res(() -> build(DeepLoc(mk(), Leaf()))))   # probe:47
# two producers across levels
println("C two producers: ", res(() -> build(Group((; c = Constant(1.0), l = Leaf());
    local_wires = ("c/y" => "l/trn_field",), input_wires = ("in" => "l/trn_field",)))))   # probe:49
println("C2 two local: ", res(() -> build(Group((; c = Constant(1.0), d = Constant(2.0), l = Leaf());
    local_wires = ("c/y" => "l/trn_field", "d/y" => "l/trn_field")))))   # probe:51
println("C3 fanout is free: ", res(() -> build(Group((; c = Constant(1.0), l = Leaf(), m = Leaf());
    local_wires = ("c/y" => "l/trn_field", "c/y" => "m/trn_field")))))   # probe:53
# unconnected
println("C4 nested two producers: ", res(() -> build(Group((; inner = Group((; c = Constant(1.0), l = Leaf());
    local_wires = ("c/y" => "l/trn_field",), input_wires = ("in" => "l/trn_field",)));
    input_wires = ("in" => "inner/in",)))))
println("D unconnected input: ", res(() -> build(Group((; l = Leaf())))))   # probe:55
let bb = build(Group((; c = Constant(1.0), l = Leaf()); local_wires = ("c/y" => "l/trn_field",)))
    println("D2 unconnected output builds, warnings=", length(warnings(bb)))   # probe:57
end
# no auto bubbling: Systems face trn handed up but root declares nothing
struct NoIn <: AbstractComponent; systems::Systems; end
local_wires(::NoIn) = ()
let r = failure(() -> build(NoIn(Systems(Ldg(Leaf(), Leaf(), Leaf())))))
    println("D3 no auto-bubble: ", [(typeof(d).name.name, d.path, d.face, d.handed) for d in diagnostics(r)])   # probe:62
end
# bare face, container
println("E bare faces: ", res(() -> build(Group((; gain = Constant(1.0), int = Integrator());
    local_wires = ("gain/y" => "int/u",)))))   # probe:65
println("E2 child alone: ", res(() -> build(Group((; gain = Constant(1.0), int = Integrator());
    local_wires = ("gain" => "int/u",)))))   # probe:67
println("F container: ", res(() -> build(Group((; units = (Leaf(), Leaf()));
    input_wires = ("in" => ("units/1/trn_field", "units/2/trn_field"),)))))   # probe:69
# wire types
struct RealEntry <: AbstractComponent end
x_init(::RealEntry) = nothing
u_types(::RealEntry) = (u = Float64,); y_types(::RealEntry) = (y = Float64,)
y_direct(::RealEntry, (; u)) = (y = u.u,)
struct AbsEntry <: AbstractComponent end
x_init(::AbsEntry) = nothing
u_types(::AbsEntry) = (u = Real,); y_types(::AbsEntry) = (y = Float64,)
y_direct(::AbsEntry, (; u)) = (y = u.u,)
struct BoolEntry <: AbstractComponent end
x_init(::BoolEntry) = nothing
u_types(::BoolEntry) = (u = Bool,); y_types(::BoolEntry) = (y = Float64,)
y_direct(::BoolEntry, (; u)) = (y = u.u ? 1.0 : 0.0,)
struct FrozenEntry <: AbstractComponent end
x_init(::FrozenEntry) = nothing
u_types(::FrozenEntry) = (u = Pinned{Float64},); y_types(::FrozenEntry) = (y = Float64,)
y_direct(::FrozenEntry, (; u)) = (y = u.u,)
struct NomSource <: AbstractComponent end
x_init(::NomSource) = nothing
y_types(::NomSource) = (val = Float64,)
y_state(::NomSource, (; t)) = (val = 3.0 + t,)
struct PinSource <: AbstractComponent end
x_init(::PinSource) = nothing
y_types(::PinSource) = (val = Pinned{Float64},)
y_state(::PinSource, (; t)) = (val = 3.0,)
struct FrozenReader <: AbstractComponent end
s_init(::FrozenReader) = nothing
u_types(::FrozenReader) = (in = Float64,); y_types(::FrozenReader) = (out = Float64,)
y_direct(::FrozenReader, (; u)) = (out = 2.0 * u.in,)
println("G0 pinned producer: ", res(() -> build(Group((; src = PinSource(), c = RealEntry(), d = FrozenEntry()); local_wires = ("src/val" => "c/u", "src/val" => "d/u")))))
println("G0b abstract Real entry: ", res(() -> build(Group((; src = NomSource(), c = AbsEntry()); local_wires = ("src/val" => "c/u",)))))
struct Hold <: AbstractComponent; units::Tuple{Leaf,Leaf}; end
local_wires(::Hold) = ()
input_wires(::Hold) = ("in" => ("units/1/trn_field", "units/2/trn_field"),)
println("F2 tuple container: ", res(() -> build(Hold((Leaf(), Leaf())))))
struct HoldNT <: AbstractComponent; units::@NamedTuple{l::Leaf, r::Leaf}; end
local_wires(::HoldNT) = ()
input_wires(::HoldNT) = ("in" => ("units/l/trn_field", "units/r/trn_field"),)
println("F3 namedtuple container: ", res(() -> build(HoldNT((l = Leaf(), r = Leaf())))))
println("G1 bound law Bool<-Float64: ", res(() -> build(Group((; src = NomSource(), c = BoolEntry()); local_wires = ("src/val" => "c/u",)))))   # probe:71
println("G2 abstract Real entry: ", res(() -> build(Group((; src = NomSource(), c = RealEntry()); local_wires = ("src/val" => "c/u",)))))   # probe:72
println("G3 walking -> pinned entry: ", res(() -> build(Group((; src = NomSource(), c = FrozenEntry()); local_wires = ("src/val" => "c/u",)))))   # probe:73
println("G4 walking -> discrete pinned: ", res(() -> build(Group((; src = NomSource(), rd = FrozenReader()); local_wires = ("src/val" => "rd/in",)))))   # probe:74
println("G5 pinned handle -> tolerant: ", res(() -> build(offset_model(PinnedOffsetSource()))), " discrete: ", res(() -> build(offset_model(DiscreteOffsetSource()))))   # probe:75
println("G6 walking handle -> pinned: ", res(() -> build(Group((; src = OffsetAtT(), q = PinnedOffsetQuery()); local_wires = ("src/terrain" => "q/terrain",)))))   # probe:76
# loops
struct FT <: AbstractComponent; k::Float64; end
x_init(::FT) = nothing
u_types(::FT) = (u = Float64,); y_types(::FT) = (y = Float64,)
y_direct(c::FT, (; u)) = (y = c.k * u.u,)
let r = failure(() -> build(Group((; a = FT(1.0), b = FT(2.0)); local_wires = ("a/y" => "b/u", "b/y" => "a/u"))))
    println("H1 real loop: ", r isa DiagnosticError, " ", [(typeof(d).name.name, d.classification, d.dead) for d in diagnostics(r)])   # probe:81
end
struct Cross <: AbstractComponent end
x_init(::Cross) = nothing
u_types(::Cross) = (a = Float64, b = Float64); y_types(::Cross) = (p = Float64, q = Float64)
y_direct(::Cross, (; u)) = (p = u.a, q = u.b)
let r = failure(() -> build(Group((; x = Cross(), y = Cross()); local_wires = ("x/p" => "y/a", "y/q" => "x/b"),
                                  input_wires = ("ia" => "x/a", "ib" => "y/b"))))
    println("H2 artificial loop still an error: ", [(typeof(d).name.name, d.classification, d.dead) for d in diagnostics(r)])   # probe:86
end
struct Mix <: AbstractComponent end
x_init(::Mix) = (q = 0.0,)
u_types(::Mix) = (u = Float64, v = Float64); y_types(::Mix) = (a = Float64, b = Float64)
y_state(::Mix, (; x)) = (a = x.q,)
y_direct(::Mix, (; u)) = (b = 2 * u.u,)
x_deriv(::Mix, (; x, u)) = (q = u.v,)
let r = failure(() -> build(Group((; m = Mix(), f = FT(1.0)); local_wires = ("m/b" => "f/u", "f/y" => "m/v"),
                                  input_wires = ("i" => "m/u",))))
    println("H3 x_deriv-only input with stage-2 output: ", r isa DiagnosticError && [(typeof(d).name.name, d.classification) for d in diagnostics(r)])   # probe:94
end
struct Integ <: AbstractComponent end
x_init(::Integ) = (q = 0.0,)
u_types(::Integ) = (u = Float64,); y_types(::Integ) = (y = Float64,)
y_state(::Integ, (; x)) = (y = x.q,)
x_deriv(::Integ, (; x, u)) = (q = u.u,)
println("H4 integrator-shaped loop builds: ", res(() -> build(Group((; i = Integ(), f = FT(1.0)); local_wires = ("i/y" => "f/u", "f/y" => "i/u")))))   # probe:100
# unit delay
let bd = build(Group((; a = FT(1.0), d = UnitDelay(0.0)); local_wires = ("a/y" => "d/u", "d/y" => "a/u")))
    println("H5 unit delay: ", [(e.path, e.tier) for e in bd.structure.components])   # probe:103
end
# supervisory PI
struct PI <: AbstractComponent; k_p::Float64; k_i::Float64; end
s_init(::PI) = (s_i = 0.0,)
u_types(::PI) = (e = Float64, engage = Bool, u_latch = Float64); y_types(::PI) = (u_cmd = Float64,)
y_direct(c::PI, (; s, u)) = (u_cmd = u.engage ? u.u_latch : c.k_p*u.e + s.s_i,)
s_update(c::PI, (; s, u, Δt)) = (s_i = u.engage ? u.u_latch - c.k_p*u.e : s.s_i + c.k_i*Δt*u.e,)
struct PIlate <: AbstractComponent; k_p::Float64; k_i::Float64; end
s_init(::PIlate) = (s_i = 0.0,)
u_types(::PIlate) = (e = Float64, engage = Bool, u_latch = Float64); y_types(::PIlate) = (u_cmd = Float64,)
y_direct(c::PIlate, (; s, u)) = (u_cmd = c.k_p*u.e + s.s_i,)
s_update(c::PIlate, (; s, u, Δt)) = (s_i = u.engage ? u.u_latch - c.k_p*u.e : s.s_i + c.k_i*Δt*u.e,)
pig(T) = Group((; e = Constant(1.0), g = Constant(true), l = Constant(5.0), pi = T(1.0, 1.0));
               local_wires = ("e/y" => "pi/e", "g/y" => "pi/engage", "l/y" => "pi/u_latch"))
for T in (PI, PIlate)
    sim = Simulation(pig(T); Δt_frame = 1//10)
    init!(sim)
    c0 = port(sim.model, "pi", :u_cmd)
    step!(sim)
    c1 = port(sim.model, "pi", :u_cmd)
    println("I ", T, " u_cmd at boundary zero=", c0, " after one frame=", c1)   # probe:125
end
end

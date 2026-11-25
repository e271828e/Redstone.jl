# L6d probe: one Julia process, every claim's runtime check tagged [Pn].
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
include(joinpath(W, "test", "imports.jl"))
include(joinpath(W, "test", "fixtures.jl"))
import Redstone: x_init, s_init, m_init, u_types, y_types, y_state, y_direct, x_deriv,
    s_update, state_events, sample_times, init!, port, state, set, probe_value
import Redstone.Library

tag(t, x) = println("[", t, "] ", x)
caught(f) = try f(); "no throw" catch e; e isa DiagnosticError ? e.carried : e end

# --- components ---------------------------------------------------------------
struct Tick <: AbstractComponent end          # discrete counter, published from stage 1
s_init(::Tick) = 0
y_types(::Tick) = (n = Int,)
y_state(::Tick, (; s)) = (n = s,)
s_update(::Tick, (; s)) = s + 1

const SEEN_DT = Ref{Any}(nothing)
struct DtSpy <: AbstractComponent end         # records the probe's Δt
s_init(::DtSpy) = 0
y_types(::DtSpy) = (n = Int,)
y_state(::DtSpy, b) = (SEEN_DT[] === nothing && (SEEN_DT[] = b.Δt); (n = b.s,))
s_update(::DtSpy, (; s)) = s

struct NotNT <: AbstractComponent end         # named contract, stage returns a number
x_init(::NotNT) = nothing
y_types(::NotNT) = (y = Float64,)
y_state(::NotNT, _) = 1.0

struct Empty1 <: AbstractComponent end        # named contract, stage returns (;)
x_init(::Empty1) = nothing
y_types(::Empty1) = (y = Float64,)
y_state(::Empty1, _) = (;)

struct Unproduced <: AbstractComponent end    # a declared port no stage writes
x_init(::Unproduced) = nothing
y_types(::Unproduced) = (y = Float64, z = Float64)
y_state(::Unproduced, _) = (y = 1.0,)

struct DUnproduced <: AbstractComponent end   # the same on the discrete tier
s_init(::DUnproduced) = 0
y_types(::DUnproduced) = (y = Int, z = Int)
y_state(::DUnproduced, (; s)) = (y = s,)
s_update(::DUnproduced, (; s)) = s

struct TwiceP <: AbstractComponent end         # a port written by both stages
x_init(::TwiceP) = nothing
u_types(::TwiceP) = (u = Float64,)
y_types(::TwiceP) = (y = Float64,)
y_state(::TwiceP, _) = (y = 1.0,)
y_direct(::TwiceP, (; u)) = (y = u.u,)

struct BadKey <: AbstractComponent end        # a handler returning an undeclared store
x_init(::BadKey) = (q = 0.0,)
y_types(::BadKey) = (y = Float64,)
y_state(::BadKey, (; x)) = (y = x.q,)
x_deriv(::BadKey, _) = (q = 1.0,)
bk_guard(::BadKey, _) = false
bk_handler(::BadKey, _) = (s = 1,)
state_events(::BadKey) = (e = StateEvent(bk_guard, bk_handler),)

struct AbsIn <: AbstractComponent end         # a primitive root with an abstract input
x_init(::AbsIn) = nothing
u_types(::AbsIn) = (u = Real,)
y_types(::AbsIn) = (y = Float64,)
y_direct(::AbsIn, (; u)) = (y = Float64(u.u),)

struct FiresAtT0 <: AbstractComponent end     # a Bool guard holding at t₀
x_init(::FiresAtT0) = (q = 0.0,)
m_init(::FiresAtT0) = (hits = 0,)
y_types(::FiresAtT0) = (hits = Int,)
y_state(::FiresAtT0, (; m)) = (hits = m.hits,)
x_deriv(::FiresAtT0, _) = (q = 0.0,)
f0_guard(::FiresAtT0, (; m)) = m.hits == 0
f0_handler(::FiresAtT0, (; m)) = (m = (hits = m.hits + 1,),)
state_events(::FiresAtT0) = (e = StateEvent(f0_guard, f0_handler),)

struct Pos{T}                                 # a struct-valued port whose eltype constructor is missing
    a::T
    Pos{T}(a::Float64) where {T} = new{T}(a)
end
struct PosOut <: AbstractComponent end
x_init(::PosOut) = (q = 0.0,)
y_types(::PosOut) = (p = Pos{Float64},)
y_state(::PosOut, _) = (p = Pos{Float64}(1.0),)
x_deriv(::PosOut, _) = (q = 1.0,)

struct PinIn <: AbstractComponent end         # pins its root input
x_init(::PinIn) = nothing
u_types(::PinIn) = (u = Pinned{Float64},)
y_types(::PinIn) = (y = Float64,)
y_direct(::PinIn, (; u)) = (y = u.u,)
struct WalkIn <: AbstractComponent end        # tolerates it
x_init(::WalkIn) = nothing
u_types(::WalkIn) = (u = Float64,)
y_types(::WalkIn) = (y = Float64,)
y_direct(::WalkIn, (; u)) = (y = u.u,)

# --- D-185 / D-186: the two forms ----------------------------------------------
tag("P1 Relative(2.0)", caught(() -> Relative(2.0)))
tag("P1 Absolute(0.02)", caught(() -> Absolute(0.02)))
tag("P1 Absolute(0.02) message", (try Absolute(0.02) catch e; sprint(showerror, e) end))
tag("P1 Relative(0) constructs", Relative(0))
tag("P1 Relative(3) default phase", Relative(3).Φ)
tag("P1 Absolute(1//50) default offset", Absolute(1//50).τ)
tag("P1 fields", (fieldnames(Relative), fieldnames(Absolute)))
tag("P1 isdefined Period/Hz", (isdefined(Redstone, :Period), isdefined(Redstone, :Hz)))
tag("P1 Relative(0) at build", caught(() -> build(Group((; d = Tick()); sample_times = (d = Relative(0),)))))

b_default = build(Group((; d = Tick())))
dep = Deployment(b_default; Δt_frame = 1//10)
tag("P2 unlisted discrete child schedule", [(r.path, r.D, r.Φ) for r in dep.schedule.rows])
# an anchored child faster than its relative scope
inner = Group((; fast = Tick()); sample_times = (fast = Absolute(1//100),))
outer = Group((; inner = inner, slow = Tick()); sample_times = (inner = Relative(1), slow = Absolute(1//10)))
tag("P3 anchored child under scope", caught(() -> [(r.path, r.anchor, r.D, r.Φ, r.Δt) for r in Deployment(build(outer); Δt_frame = 1//10, Δt_base = 1//100).schedule.rows]))

# --- D-205: boundary zero ------------------------------------------------------
sim0 = Simulation(Group((; off = Tick(), on = Tick()); sample_times = (off = Relative(2, 1), on = Relative(2, 0)));
                  Δt_frame = 1//10)
init!(sim0)
tag("P4 boundary zero: off port, off state, on port, on state",
    (port(sim0, "off", :n), state(sim0, "off"), port(sim0, "on", :n), state(sim0, "on")))

# --- D-147 / D-288: phase bodies -----------------------------------------------
bodies = sim0.model.exec.bodies
tag("P5 phase body keys", keys(bodies))
tag("P5 sweep_1 interior/boundary chunk counts",
    (sum(length(c.entries) for c in bodies.sweep_1.interior; init = 0),
     sum(length(c.entries) for c in bodies.sweep_1.boundary; init = 0)))
tag("P5 ticks interior/boundary",
    (sum(length(c.entries) for c in bodies.ticks.interior; init = 0),
     sum(length(c.entries) for c in bodies.ticks.boundary; init = 0)))
tag("P5 methods sweep_1 arities", (applicable(bodies.sweep_1), applicable(bodies.sweep_1, 0)))
tag("P5 isdefined sweep_hx", isdefined(Redstone, :sweep_hx))

# --- D-285: probe return checks --------------------------------------------------
tag("P6 non-NamedTuple return (named contract)", caught(() -> build(Group((; c = NotNT())))))
tag("P6 (;) return", caught(() -> build(Group((; c = Empty1())))))
tag("P6 bare Constant returns bare", y_state(Library.Constant(2.0), (;)))
build(Group((; c = DtSpy())))
tag("P6 discrete probe Δt", SEEN_DT[])

# --- D-252 ---------------------------------------------------------------------
tag("P7 unproduced continuous", caught(() -> build(Group((; c = Unproduced())))))
tag("P7 unproduced discrete", caught(() -> build(Group((; c = DUnproduced())))))
tag("P7 produced twice", caught(() -> build(Group((; c = TwiceP()); input_wires = ("u" => "c/u",)))))
tag("P7 isdefined output_state", isdefined(Redstone, :output_state))

# --- D-287 ---------------------------------------------------------------------
tag("P8 handler key", caught(() -> build(Group((; c = BadKey())))))
tag("P8 struct port, missing eltype constructor, at Dual",
    caught(() -> activation(build(Group((; c = PosOut()))), ProbeDual)))

# --- D-208 ---------------------------------------------------------------------
broot = build(Plant())
tag("P9 primitive root inputs", broot.structure.root_inputs)
tag("P9 abstract primitive root", caught(() -> build(AbsIn())))

# --- D-168 ---------------------------------------------------------------------
fan = Group((; p = PinIn(), w = WalkIn()); input_wires = ("u" => ("p/u", "w/u"),))
bf = build(fan)
tag("P10 pinning consumers", Redstone.pinning_consumers(bf.structure))
tag("P10 root cell at ProbeDual", (activation(bf, ProbeDual).layout.root_inputs))
fan2 = Group((; a = WalkIn(), w = WalkIn()); input_wires = ("u" => ("a/u", "w/u"),))
tag("P10 root cell at ProbeDual, all tolerate", (activation(build(fan2), ProbeDual).layout.root_inputs))
tag("P10 isdefined RootSlotTypeConflict", isdefined(Redstone, :RootSlotTypeConflict))

# --- D-292 ---------------------------------------------------------------------
simf = Simulation(Group((; c = FiresAtT0())); Δt_frame = 1//10)
init!(simf)
tag("P11 fired at t₀", port(simf, "c", :hits))

# --- D-341 ---------------------------------------------------------------------
tag("P12 bundle stateless continuous y_direct", bundle_names(y_direct, TwiceP(), CONTINUOUS, (:y,)))
tag("P12 bundle discrete y_state", bundle_names(y_state, Tick(), DISCRETE, ()))
tag("P12 bundle Plant x_deriv", bundle_names(x_deriv, Plant(), CONTINUOUS, (:y,)))

# --- D-065 ---------------------------------------------------------------------
mk() = at("plant", combine(set(x = (q = SVector(1.0, 0.0),)), set(u = (u = 2.0,))))
mk(); mk()
tag("P13 node rebuild allocations", @allocated mk())
tag("P13 node type", typeof(mk()))
tag("P13 isdefined Merged", isdefined(Redstone, :Merged))
dup = combine(at("plant", set(x = (q = SVector(1.0, 0.0),))), at("plant", set(x = (q = SVector(2.0, 0.0),))))
tag("P13 duplicate leaf", caught(() -> init!(Simulation(Group((; plant = Plant()); input_wires = ("u" => "plant/u",)); Δt_frame = 1//10), combine(dup, set(u = (u = 0.0,))))))

# --- D-043 / D-207 names ----------------------------------------------------------
tag("P14 isdefined faces/passthrough/child_connections/input_connections/output_connections/connections",
    map(s -> isdefined(Redstone, s), (:faces, :passthrough, :child_connections, :input_connections,
                                      :output_connections, :connections)))
tag("P14 deep endpoint", caught(() -> build(Group((; outer = Group((; p = Plant()))); input_wires = ("u" => "outer/p/u",)))))

# --- D-085: containers ---------------------------------------------------------
struct Holder <: AbstractComponent
    units::Tuple{Tick, Tick}
    named::@NamedTuple{a::Tick}
end
local_wires(::Holder) = ()
tag("P15 container child paths", [e.path for e in build(Holder((Tick(), Tick()), (a = Tick(),))).structure.components])

# --- D-453 ---------------------------------------------------------------------
lib = names(Library; all = true)
tag("P16 Library names containing Block", filter(n -> occursin("Block", String(n)), lib))
tag("P16 abstract parents", map(s -> isdefined(Library, s) && isabstracttype(getfield(Library, s)),
    (:AbstractLinearSystem, :AbstractDiscreteLinearSystem, :AbstractAntiWindupController, :AbstractPID, :AbstractLQRTracker)))
tag("P16 Constant y_types", y_types(Library.Constant(2.0)))

# --- D-051 ---------------------------------------------------------------------
struct NoProbe; a::Float64; end
struct NeedsProbe <: AbstractComponent end
x_init(::NeedsProbe) = nothing
u_types(::NeedsProbe) = (u = NoProbe,)
y_types(::NeedsProbe) = (y = Float64,)
y_direct(::NeedsProbe, (; u)) = (y = u.u.a,)
tag("P17 missing probe value", caught(() -> build(Group((; c = NeedsProbe()); input_wires = ("u" => "c/u",)))))
@enum GearP lowp highp
tag("P17 chain", (probe_value(Float64), probe_value(Bool), probe_value(GearP), probe_value(Int)))

# --- D-084 ---------------------------------------------------------------------
bw = build(Group((; c = Plant()); input_wires = ("u" => "c/u",)))
tag("P18 build warnings with an unconsumed output", Redstone.warnings(bw))

# SA_v verifier probes. Run from the pinned worktree W with --project=test.
using Test, StaticArrays, LinearAlgebra, ForwardDiff
using Redstone
const TESTDIR = joinpath(pwd(), "test")
include(joinpath(TESTDIR, "imports.jl"))
include(joinpath(TESTDIR, "fixtures.jl"))
include(joinpath(TESTDIR, "utils.jl"))
import Redstone: x_init, s_init, m_init, u_types, y_types, y_state, y_direct, x_deriv, s_update, state_events
import Redstone: SumJunction, Constant, UnconnectedInput

say(id, args...) = println(id, " | ", join(string.(args), " | "))
tryit(id, f) = try f() catch err; say(id, "THREW", sprint(showerror, err)[1:min(end, 400)]) end

# SA-019: discrete store copied into a condition, then init!
tryit("SA-019", () -> begin
    sim = Simulation(single(DiscreteCounter()); Δt_frame = 1//10)
    init!(sim)
    say("SA-019a", "after init! alone: state", state(sim, "c"), "port", port(sim, "c", :n))
    step!(sim; frames = 3)
    s_stop = state(sim, "c"); y_stop = port(sim, "c", :n); t_stop = latest(sim).t
    say("SA-019b", "stopped run at t", t_stop, "state", s_stop, "port", y_stop)
    twin = Simulation(single(DiscreteCounter()); Δt_frame = 1//10)
    init!(twin, at("c", set(s = s_stop)); t0 = 3//10)
    say("SA-019c", "copy+init!: t", latest(twin).t, "state", state(twin, "c"), "port", port(twin, "c", :n))
    step!(sim); step!(twin)
    say("SA-019d", "one frame on: original port", port(sim, "c", :n), "copy port", port(twin, "c", :n))
end)

# SA-029: edges only; a holding predicate fires once; falling edge fires nothing
tryit("SA-029", () -> begin
    sim = Simulation(fed(Trigger(0.5), "sig"); Δt_frame = 1//10)
    init!(sim, set(u = (in = 1.0,)))
    say("SA-029a", "holding at t0 fires at boundary zero: count", modes(sim, "c").count)
    step!(sim; frames = 3)
    say("SA-029b", "keeps holding 3 frames: count", modes(sim, "c").count)
    stage!(sim, "in" => 0.0); step!(sim; frames = 2)
    say("SA-029c", "after falling edge: count", modes(sim, "c").count)
    stage!(sim, "in" => 1.0); step!(sim; frames = 1)
    say("SA-029d", "after second rising edge: count", modes(sim, "c").count)
end)

# SA-038: two always-holding events on one component
struct TwoEv <: AbstractComponent end
m_init(::TwoEv) = (a = 0, b = 0)
x_init(::TwoEv) = nothing
y_types(::TwoEv) = (a = Int,)
y_state(::TwoEv, (; m)) = (a = m.a,)
ga(::TwoEv, _) = true
ha(::TwoEv, (; m)) = (m = (a = m.a + 1,),)
gb(::TwoEv, _) = true
hb(::TwoEv, (; m)) = (m = (b = m.a == 1 ? 10 : 20,),)
state_events(::TwoEv) = (ea = StateEvent(ga, ha), eb = StateEvent(gb, hb))
tryit("SA-038", () -> begin
    sim = Simulation(single(TwoEv()); Δt_frame = 1//10)
    init!(sim)
    say("SA-038", "modes after boundary zero (b = 10 means eb fired in a later round, seeing a = 1)", modes(sim, "c"))
end)

# SA-051: declaration reads and a value-dependent contract
const UCALLS = Ref(0)
struct VD <: AbstractComponent
    n::Int
end
x_init(::VD) = nothing
u_types(c::VD) = (UCALLS[] += 1; c.n == 1 ? (a = Float64,) : (a = Float64, b = Float64))
y_types(::VD) = (y = Float64,)
y_direct(::VD, (; u)) = (y = u.a,)
tryit("SA-051", () -> begin
    w = Group((; k = Constant(1.0), p = VD(1), q = VD(2));
              local_wires = ("k/y" => "p/a", "k/y" => "q/a", "k/y" => "q/b"))
    UCALLS[] = 0
    b = build(w)
    say("SA-051a", "build of two VD instances with different u_types", typeof(b), "u_types calls", UCALLS[])
    UCALLS[] = 0
    sim = Simulation(b; Δt_frame = 1//10); init!(sim)
    say("SA-051b", "Simulation + init! u_types calls", UCALLS[], "q/y", port(sim, "q", :y))
end)

# SA-057: a counted contributor nobody wires
tryit("SA-057", () -> begin
    w = Group((; a = Constant(1.0), b = Constant(2.0), s = SumJunction{Float64,3}());
              local_wires = ("a/y" => "s/in1", "b/y" => "s/in2"))
    try
        build(w); say("SA-057", "built with no error")
    catch err
        say("SA-057", "refused", err isa DiagnosticError ? [typeof(d) for d in diagnostics(err)] : typeof(err),
            err isa DiagnosticError ? [path(d) for d in diagnostics(err) if d isa UnconnectedInput] : "")
    end
end)

# SA-084 and SA-093: ordinal and trace header
tryit("SA-084", () -> begin
    sim = Simulation(single(DiscreteCounter()); Δt_frame = 1//10)
    init!(sim)
    say("SA-084a", "after init!: latest.boundary", latest(sim).boundary, "run.boundary", sim.run.boundary)
    cp0 = checkpoint(sim)
    step!(sim; frames = 3)
    say("SA-084b", "after 3 frames: latest.boundary", latest(sim).boundary)
    hdr = trace(sim).header
    say("SA-093", "trace header boundary", hdr.boundary, "frame", hdr.frame, "t", hdr.state.t,
        "s", hdr.state.s, "matches checkpoint after init!", hdr.state.s == cp0.state.s && hdr.state.t == cp0.state.t &&
        hdr.boundary == cp0.boundary)
    init!(sim)
    say("SA-084c", "after second init!: latest.boundary", latest(sim).boundary)
end)

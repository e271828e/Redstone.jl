# L12 verifier probes, run against W at f14dbc1d.
using Test, StaticArrays, LinearAlgebra, ForwardDiff
using Redstone
const T = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/"
include(T * "imports.jl"); include(T * "fixtures.jl"); include(T * "utils.jl")

# replay fixtures, copied from test/test_trace.jl:477-512
replay_model(k = 4.0) =
    Group((plant = Plant(; ω = 2.0, ζ = 0.1), ctl = Gain(k), sum = Sum(),
           acc = DiscreteAccumulator(1.0), b = Bouncer(1.0, 0.32));
          local_wires = ("ctl/out" => "plant/u", "sum/e" => "ctl/e", "plant/y" => "sum/b"),
          input_wires = ("ref" => "sum/a", "rate" => "acc/e"),
          output_wires = ("b/q" => "bq", "acc/u" => "u"))
function recorded_run()
    sim = Simulation(replay_model(); Δt_frame = 1//10)
    init!(sim, set(u = (ref = 1.0, rate = 0.0)))
    stage!(sim, "ref" => 2.0); step!(sim; frames = 3)
    stage!(sim, "rate" => 1.0); step!(sim; frames = 5)
    (sim, trace(sim))
end

# an interrupt thrown in boundary zero's handler
struct BZInt <: AbstractComponent end
Redstone.m_init(::BZInt) = (blown = false,)
Redstone.x_init(::BZInt) = nothing
Redstone.u_types(::BZInt) = (sig = Bool,)
Redstone.y_types(::BZInt) = (blown = Bool,)
Redstone.y_state(::BZInt, (; m)) = (blown = m.blown,)
bz_guard(::BZInt, (; u)) = u.sig
bz_handler(::BZInt, (; u, m)) = u.sig ? throw(InterruptException()) : (m = (blown = true,),)
Redstone.state_events(::BZInt) = (blow = StateEvent(bz_guard, bz_handler),)

mutable struct BadInitP <: AbstractDevice; log::Vector{Symbol}; end
Redstone.init!(dev::BadInitP) = (push!(dev.log, :init); error("no hardware"))
Redstone.shutdown!(dev::BadInitP) = (push!(dev.log, :shutdown); nothing)
Redstone.loop(dev::BadInitP, handle) = (push!(dev.log, :loop); nothing)
mutable struct GoodP <: AbstractDevice; log::Vector{Symbol}; end
Redstone.init!(dev::GoodP) = (push!(dev.log, :init); nothing)
Redstone.shutdown!(dev::GoodP) = (push!(dev.log, :shutdown); nothing)
Redstone.loop(dev::GoodP, handle) = (push!(dev.log, :loop); nothing)

pr(tag, x) = println(tag, " => ", x)

# P1 (L12-001): the counter is monotonic across runs
sim = Simulation(fed(Mine(), "sig"); Δt_frame = 1//10)
init!(sim, set(u = (in = false,))); c0 = sim.control.counter
step!(sim; frames = 3); c1 = sim.control.counter
init!(sim, set(u = (in = false,))); c2 = sim.control.counter
pr("P1 counter after init, step3, re-init", (c0, c1, c2))

# P2 (L12-057, 065, 066): boundary-zero throw under init!
sim = Simulation(fed(Mine(), "sig"); Δt_frame = 1//10)
err = failure(() -> init!(sim, set(u = (in = true,))))
pr("P2 type/host/boundary/t", (typeof(err), err.host, err.boundary, err.t))
pr("P2 lifecycle", lifecycle(sim))
pr("P2 trace(sim)", failure(() -> trace(sim)))
pr("P2 rendered", sprint(showerror, err))

# P3 (L12-071): an interrupt inside boundary zero
sim = Simulation(fed(BZInt(), "sig"); Δt_frame = 1//10)
err = failure(() -> init!(sim, set(u = (in = true,))))
pr("P3 type/host", (typeof(err), err isa StepError ? err.host : nothing))
pr("P3 lifecycle", lifecycle(sim))

# P4 (L12-048): margin is a live knob
sim = Simulation(fed(Mine(), "sig"); Δt_frame = 1//10)
pr("P4 margin default", margin(sim)); margin!(sim, 0.005); pr("P4 margin after margin!", margin(sim))
pr("P4 run! kw", Base.kwarg_decl(only(methods(Redstone.run!, (Simulation,)))))
pr("P4 STALE_S", Redstone.STALE_S)

# P5 (L12-091): step! bit-identical to run!, returns frames advanced
a = Simulation(replay_model(); Δt_frame = 1//10); init!(a, set(u = (ref = 1.0, rate = 0.0)))
b = Simulation(replay_model(); Δt_frame = 1//10); init!(b, set(u = (ref = 1.0, rate = 0.0)))
n = step!(a; frames = 8)
run!(b; t_end = 0.8)
pr("P5 step! returned", n); pr("P5 frames a,b", (a.run.frame, b.run.frame))
pr("P5 bit-identical state, s, table", (checkpoint(a).state.x == checkpoint(b).state.x, checkpoint(a).state.s == checkpoint(b).state.s, same_table(checkpoint(a).state.table, checkpoint(b).state.table)))

# P6 (L12-101, 143): failed device init!, should_abort set
sim = Simulation(fed(Mine(), "sig"); Δt_frame = 1//10)
bad, good = BadInitP(Symbol[]), GoodP(Symbol[])
attach!(sim, bad, Enumerated("in"); should_abort = true)
attach!(sim, good, Enumerated())
init!(sim, set(u = (in = false,)))
logs, _ = Test.collect_test_logs() do; run!(sim; t_end = 0.5); end
rec = termination(sim)
pr("P6 frame/lifecycle/source", (sim.run.frame, lifecycle(sim), rec.source))
pr("P6 bad log/good log", (bad.log, good.log))
pr("P6 residue kinds", [typeof.(r.recent) for r in rec.residue])

# P7 (L12-111): replay re-records, header inherited, prefix bit-identical
(rsim, trc) = recorded_run()
sim2 = Simulation(replay_model(); Δt_frame = 1//10); init!(sim2, set(u = (ref = 0.0, rate = 0.0)))
replay!(sim2, trc)
t2 = trace(sim2)
pr("P7 header inherited (same state xbuf, frame)", (t2.header.state.x == trc.header.state.x, t2.header.frame == trc.header.frame))
pr("P7 batches equal", t2.batches == trc.batches)
pr("P7 final state equal", checkpoint(sim2).state.x == checkpoint(rsim).state.x)

# P8 (L12-121): a parametric difference passes, both forms
sim3 = Simulation(replay_model(9.0); Δt_frame = 1//10); init!(sim3, set(u = (ref = 1.0, rate = 0.0)))
pr("P8 restore=true on k=9", failure(() -> replay!(sim3, trc)))
sim4 = Simulation(replay_model(9.0); Δt_frame = 1//10); init!(sim4, set(u = (ref = 1.0, rate = 0.0)))
pr("P8 restore=false on k=9", failure(() -> replay!(sim4, trc; restore = false)))

# P9 (L12-162): restore = false at another origin
sim5 = Simulation(replay_model(); Δt_frame = 1//10); init!(sim5, set(u = (ref = 1.0, rate = 0.0)); t0 = 1//2)
e = failure(() -> replay!(sim5, trc; restore = false))
pr("P9", (typeof(e), [(d.what, d.name) for d in diagnostics(e)]))

# P10 (L12-191): tokens of two types named whole
sim6 = Simulation(replay_model(); Δt_frame = 1//10, algorithm = Heun()); init!(sim6, set(u = (ref = 1.0, rate = 0.0)))
e = failure(() -> replay!(sim6, trc))
pr("P10", [(d.what, d.name, d.expected, d.found) for d in diagnostics(e)])

# P11 (L12-171, 182): frame throw writes :inconsistent; restore pointer
sim = Simulation(fed(Mine(), "sig"); Δt_frame = 1//10); init!(sim, set(u = (in = false,)))
step!(sim; frames = 2); stage!(sim, "in" => true)
err = failure(() -> step!(sim))
pr("P11 frame throw", (typeof(err), err.host, err.boundary, sim.model.status, lifecycle(sim)))

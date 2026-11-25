# SD3 verifier probes, run from the pinned worktree with --project=test.
include(joinpath(pwd(), "test", "RedstoneTests.jl"))
@eval RedstoneTests begin
import Redstone: Run, Fingerprint, StopPolicy
line(tag, x) = println(tag, " => ", x)

# SD3-012: root defaults
line("P012 is_input/is_output(NoSides)", (is_input(NoSides()), is_output(NoSides())))
# SD3-122: Run's const fields
line("P122 const fields", [f for f in fieldnames(Run) if Base.isconst(Run, f)])
line("P122 all fields", fieldnames(Run))
# SD3-145
line("P145 StopPolicy mutable?", ismutabletype(StopPolicy))
# SD3-181 / SD3-211
line("P181 Fingerprint fields", fieldnames(Fingerprint))
line("P211 Deployment fields", fieldnames(Deployment))

# SD3-100: the wait's predicate
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
h = attach!(sim, TailProbe(), NoClaim())
init!(sim, set(u = (a = 0.0, b = 0.0)))
h.last_seen = sim.control.counter
@atomic sim.control.stopped = true
t = @elapsed r = wait_next_snapshot(h)
line("P100 stopped, no new boundary: returned in s", (round(t; digits = 3), r !== nothing))
@atomic sim.control.stopped = false
h.last_seen = sim.control.counter - 1
t = @elapsed wait_next_snapshot(h)
line("P100 running, new boundary: returned in s", round(t; digits = 3))

# SD3-166: harness writer's kinds
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
attach!(sim, Pad("da"), Enumerated("a"))
init!(sim, set(u = (a = 0.0, b = 0.0)))
stage!(sim, "a" => 1.0)
stage!(sim, "flaps" => 1.0)
line("P166 harness ring kinds", [typeof(d) for d in (@atomic sim.plane.harness_diag.batch).ring])

# SD3-001: report! of a bad datum
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
hd = attach!(sim, Pad("dm"), Enumerated("a"))
init!(sim, set(u = (a = 0.0, b = 0.0)))
report!(hd, MalformedDatum("truncated"))
step!(sim; frames = 1)
line("P001 malformed total", writer_status(latest(sim), hd.who).totals.malformed)

# SD3-109 / SD3-132: death is not detach; should_abort
mutable struct Crasher <: AbstractDevice end
loop(::Crasher, handle) = error("boom")
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
attach!(sim, Crasher(), Enumerated("a"); should_abort = false)
attach!(sim, TailProbe(), NoClaim())
init!(sim, set(u = (a = 0.0, b = 0.0)))
run!(sim; t_end = 0.5)
line("P109 after crash: roster, claimedby, termination",
     (length(sim.plane.roster), sim.plane.claimedby, typeof(termination(sim).source), latest(sim).t))
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
attach!(sim, Pad("quits"), Enumerated("a"); should_abort = true)
attach!(sim, TailProbe(), NoClaim())
init!(sim, set(u = (a = 0.0, b = 0.0)))
run!(sim; t_end = 100.0)
line("P132 returning loop under should_abort: source", termination(sim).source)

# SD3-213 / SD3-223 / SD3-194: trace records, live!
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
init!(sim, set(u = (a = 0.0, b = 0.0)))
stage!(sim, "a" => 1.0)
step!(sim; frames = 1)
stage!(sim, "b" => 2.0)
step!(sim; frames = 2)
trc = trace(sim)
line("P213 schemas", trc.schemas)
line("P223 batches", trc.batches)
sim2 = Simulation(two_root_inputs(); Δt_frame = 1//10)
replay!(sim2, trc; to_boundary = 1)
line("P194 mode after partial replay", (mode(sim2), lifecycle(sim2)))
live!(sim2)
line("P194 mode after live!", mode(sim2))
end

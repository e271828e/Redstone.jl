# SD3 probes: spec Appendix D.6 and D.7 (glossary), run once.
using Test, Redstone, StaticArrays, LinearAlgebra, ForwardDiff
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
include(joinpath(W, "utils.jl"))
two_root_inputs() = Group((; s = Sum(sa = 1.0, sb = 1.0));
                          input_wires = ("a" => "s/a", "b" => "s/b"))

mutable struct Crasher <: AbstractDevice
    log::Vector{Symbol}
end
Crasher() = Crasher(Symbol[])
shutdown!(dev::Crasher) = (push!(dev.log, :shutdown); nothing)
loop(dev::Crasher, handle) = (push!(dev.log, :loop); error("boom"))
mutable struct BadInit <: AbstractDevice
    log::Vector{Symbol}
end
BadInit() = BadInit(Symbol[])
init!(dev::BadInit) = (push!(dev.log, :init); error("no hardware"))
shutdown!(dev::BadInit) = (push!(dev.log, :shutdown); nothing)
loop(dev::BadInit, handle) = (push!(dev.log, :loop); nothing)
three_root_inputs() = Group((; s = Sum(sa = 1.0, sb = 1.0), g = Gain(2.0));
                            input_wires = ("a" => "s/a", "b" => "s/b", "c" => "g/e"))
mutable struct Nudge <: AbstractDevice
    face::String
    v::Float64
end
loop(dev::Nudge, handle) = (stage!(handle, dev.face => dev.v); nothing)
R(tag, x) = (println("PROBE ", tag, " => ", x); flush(stdout))

# constants
R("DIAG_RING", Redstone.DIAG_RING)
R("STALE_S", Redstone.STALE_S)
R("KINDS", length(Redstone.KINDS))
struct Bare <: AbstractBinding end
R("is_input/is_output/is_greedy defaults", (Redstone.is_input(Bare()), Redstone.is_output(Bare()), Redstone.is_greedy(Bare())))
R("Run const fields", [(f, isconst(Redstone.Run, f)) for f in fieldnames(Redstone.Run)])
R("Run fields", fieldnames(Redstone.Run))
R("StopPolicy fields", fieldnames(Redstone.StopPolicy))
R("WriterStatus fields", fieldnames(Redstone.WriterStatus))
R("FrameworkStatus fields", fieldnames(Redstone.FrameworkStatus))
R("Snapshot fields", fieldnames(Redstone.Snapshot))
R("Checkpoint fields", fieldnames(Checkpoint))
R("ModelState fields", fieldnames(Redstone.ModelState))
R("Fingerprint fields", fieldnames(Redstone.Fingerprint))
R("Trace fields", fieldnames(Redstone.Trace))
R("Deployment fields", fieldnames(Deployment))
R("Control fields", fieldnames(Control))

# attach!: should_abort default, claim conflict, greedy, harness
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
d1, d2, d3 = Pad("a"), Pad("b"), Pad("g")
h1 = attach!(sim, d1, Enumerated("a"))
R("attach d1 should_abort", sim.plane.roster[1].should_abort)
R("claim conflict", try attach!(sim, d2, Enumerated("a")); :none catch e; (typeof(e), [typeof(x) for x in e.carried]) end)
R("harness faces after claim", sim.plane.harness.faces)
g = attach!(sim, d3, Greedy())
R("greedy claim", g.writer.faces)
R("harness faces after greedy", sim.plane.harness.faces)
d4 = Pad("g2")
g2 = attach!(sim, d4, Greedy())
R("2nd greedy claim empty", g2.writer.faces)

macro T(tag, ex)
    :(try R($tag, $(esc(ex))) catch e; R($tag, "THROW " * sprint(showerror, e)[1:min(end,300)]) end)
end
cond0 = set(u = (a = 0.0, b = 0.0))
detach!(sim, d4); detach!(sim, d3)
R("harness faces after detach greedy", sim.plane.harness.faces)
@T("claimedby after detach", sim.plane.claimedby)
detach!(sim, d1)
R("claimedby after detach d1", sim.plane.claimedby)
R("harness faces after all detach", sim.plane.harness.faces)

# ---- staging diagnostics
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
da, db = Pad("da"), Pad("db")
ha = attach!(sim, da, Enumerated("a"))
init!(sim, cond0)
stage!(sim, "a" => 1.0)                # claimed face on harness
stage!(sim, "zz" => 1.0)               # no such face on harness
stage!(sim, "b" => "str")              # type mismatch
stage!(ha, "b" => 1.0)                 # outside claim for device
stage!(ha, "a" => 3.0)
stage!(ha, "a" => 4.0)
R("pending slot1", pending(ha, 1))
step!(sim)
snap = latest(sim)
for w in snap.status.writers
    R("writer " * w.who, (length(w.recent), [typeof(x) for x in w.recent], w.totals, w.heartbeat, w.task_state))
end
R("port a after step", port(sim, "", :a))
R("kinds order", Redstone.KINDS)

# ---- ring capacity, report!, bad datum
struct Spammer <: AbstractDevice end
sp = Spammer()
Redstone.loop(::Spammer, h) = nothing
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
hs = attach!(sim, sp, NoClaim())
init!(sim, cond0)
for i in 1:20; report!(hs, MalformedDatum("x$i")); end
R("report! non-malformed", try report!(hs, DeviceCrash(ErrorException("x"), false)) catch e; typeof(e) end)
step!(sim)
w1 = latest(sim).status.writers[1]
R("spam ring", (length(w1.recent), w1.suppressed.malformed, w1.totals.malformed))
R("writers order", [x.who for x in latest(sim).status.writers])

# ---- crash, should_abort, bad init, orphaned, stale
for (D, abort) in ((Crasher, false), (Crasher, true), (BadInit, false), (BadInit, true), (Pad, false), (Pad, true))
    sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
    dev = D === Pad ? Pad("p") : D()
    attach!(sim, dev, Enumerated("a"); should_abort = abort)
    init!(sim, cond0)
    try run!(sim; t_end = 1.0) catch e; R("run threw", typeof(e)) end
    t = termination(sim)
    R("$D abort=$abort", (lifecycle(sim), t === nothing ? nothing : (t.t, typeof(t.source))))
    local w = latest(sim).status.writers[1]
    R("  status", (w.task_state, orphaned(w), stale(w), w.totals.crash, w.heartbeat))
    R("  claimedby after run", sim.plane.claimedby)
    R("  roster len", length(sim.plane.roster))
end

# ---- counter monotone across init!, boundary ordinal
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
init!(sim, cond0)
step!(sim; frames = 3)
c1 = sim.control.counter
b1 = latest(sim).boundary
init!(sim, cond0)
R("counter after reinit", (c1, sim.control.counter, b1, latest(sim).boundary))
R("snapshot frame/boundary/t", (latest(sim).frame, latest(sim).boundary, latest(sim).t))

# ---- unclosed/closed, run fields, mode
R("closed before", closed(sim.run))
R("mode", mode(sim))
run!(sim; t_end = 0.5)
R("closed after", closed(sim.run))
R("termination policy", termination(sim).policy)

# ---- log decimation
for (le, lm) in ((1, 4), (2, 4))
    sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
    init!(sim, cond0; log_every = le, log_max = lm)
    step!(sim; frames = 40)
    ls = logged(sim)
    R("log_every=$le log_max=$lm", ([s.boundary for s in ls], sim.run.log.stride, length(ls)))
end
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
init!(sim, cond0; log = false, trace = false)
step!(sim; frames = 3)
R("log off", (length(logged(sim)), sim.run.trace))
R("trace(sim) when off", try trace(sim) catch e; (typeof(e), (e.carried isa Vector ? e.carried[1] : e.carried).reason) end)
R("latest still publishes", latest(sim).boundary)

# ---- trace, header, checkpoint, restore, replay
function build3()
    Simulation(three_root_inputs(); Δt_frame = 1//10)
end
sim = build3()
cond3 = set(u = (a = 0.0, b = 0.0, c = 0.0))
R("trace default on", sim.run.trace === nothing)
init!(sim, cond3)
R("trace on after init", sim.run.trace !== nothing)
trc0 = trace(sim)
R("header frame/boundary", (trc0.header.frame, trc0.header.boundary, trc0.header.state.t, trc0.header.state.t₀))
R("trace schemas", trc0.schemas)
stage!(sim, "b" => 1.0)
step!(sim)
stage!(sim, "a" => 2.0, "c" => 3.0)
step!(sim; frames = 2)
trc = trace(sim)
R("batches", [(b.frame, b.writer, b.entries) for b in trc.batches])
R("trace frames", trc.frames)
cp = checkpoint(sim)
R("checkpoint types", (typeof(cp), typeof(checkpoint(sim.model)), cp.frame, cp.boundary))
R("checkpoint fingerprint x/s/m/paths", (length(cp.state.layout.xtypes), length(cp.state.layout.stypes), length(cp.state.layout.mtypes), cp.state.layout.events))
# restore! with model state
@T("restore ModelState", (restore!(sim, checkpoint(sim.model)); (lifecycle(sim), mode(sim), latest(sim).boundary, sim.run.frame)))
@T("restore Checkpoint", (restore!(sim, cp); (lifecycle(sim), mode(sim), latest(sim).boundary, sim.run.frame, trace(sim).header === nothing)))
@T("trace header after restore equal cp", trace(sim).header.state.t == cp.state.t)
# replay
sim2 = build3()
init!(sim2, cond3)
@T("replay partial", (replay!(sim2, trc; to_boundary = 2); (lifecycle(sim2), mode(sim2), sim2.run.frame, latest(sim2).boundary)))
@T("replay discarded staging", (stage!(sim2, "a" => 9.0); step!(sim2); [typeof(x) for x in latest(sim2).status.writers[end-1].recent]))
@T("replay step to end", (step!(sim2; frames = 5); (lifecycle(sim2), mode(sim2), sim2.run.frame)))
sim2 = build3()
init!(sim2, cond3)
@T("replay full", (replay!(sim2, trc); (lifecycle(sim2), mode(sim2), sim2.run.frame, trace(sim2).batches == trc.batches, trace(sim2).header.frame)))
@T("replay then live!", (replay!(sim2, trc; to_boundary = 1); live!(sim2); (mode(sim2), lifecycle(sim2))))
@T("live! when live", try live!(sim2) catch e; (e.carried isa Vector ? e.carried[1] : e.carried).reason end)
sim3 = build3()
init!(sim3, cond3)
step!(sim3; frames = 1)
@T("replay restore=false", (replay!(sim3, trc; restore = false, to_boundary = 2); (lifecycle(sim3), mode(sim3), sim3.run.frame, trace(sim3).header.frame)))
# replay re-records new trace; header equal
@T("trace is detached", (n = length(trc.batches); step!(sim2); n == length(trc.batches)))
# replay with t_end: lifecycle
sim4 = build3(); init!(sim4, cond3)
@T("replay ends initialized", (replay!(sim4, trc; to_boundary = 3); lifecycle(sim4)))
# run! after replay reaching end
@T("mode after replay to recording end", mode(sim4))
sim5 = build3(); init!(sim5, cond3)
@T("run! under replay bounded by recording", (replay!(sim5, trc; to_boundary = 1); run!(sim5); (lifecycle(sim5), mode(sim5), sim5.run.frame, termination(sim5))))

# ---- overlay header
sim = build3(); init!(sim, cond3); step!(sim; frames = 2)
@T("overlay", (overlay!(sim, set(g = (e = 5.0,))); (trace(sim).header.frame, trace(sim).header.boundary, lifecycle(sim), mode(sim))))

# ---- recorders anew at every door + trim commit
sim = build3(); init!(sim, cond3); r1 = sim.run
step!(sim); restore!(sim, checkpoint(sim)); R("restore! new run", sim.run !== r1)
R("run has const log/trace", (isconst(Redstone.Run, :log), isconst(Redstone.Run, :trace)))

# ---- run with a waiting device: tail, unblock!, shutdown!, join timeout, wait_next_snapshot
sim = build3(); 
tp = TailProbe()
attach!(sim, tp, NoClaim())
init!(sim, cond3)
run!(sim; t_end = 0.5)
R("TailProbe log", tp.log)
R("terminal status after run", (lifecycle(sim), termination(sim).source))
R("device status", let w = latest(sim).status.writers[1]; (w.task_state, w.heartbeat !== nothing) end)

# ---- greedy + empty claim + EmptyGreedyClaim kind
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
attach!(sim, Pad("x"), Greedy())
h = attach!(sim, Pad("y"), Greedy())
init!(sim, cond0)
step!(sim)
R("empty greedy", [typeof(x) for x in latest(sim).status.writers[2].recent])
R("harness stage with greedy", (stage!(sim, "a" => 1.0); [typeof(x) for x in sim.plane.harness_diag.batch.ring]))

# ---- ControlPlane: pause, stop word
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
init!(sim, cond0)
stop!(sim)
R("stop word issuer", sim.control.stop_issuer)
step!(sim)
R("after stop step", (lifecycle(sim), termination(sim).source))

# ---- port_views
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
hg = attach!(sim, Pad("g"), Greedy())
pv = port_views(hg)
R("port_views keys", sort(collect(keys(pv))))
R("a view", pv[("", :a)])

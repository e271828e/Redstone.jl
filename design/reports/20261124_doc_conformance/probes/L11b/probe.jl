# L11b probe: log.md entries D-144..D-270 slice, checked against W at f14dbc1d.
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
include(joinpath(W, "test", "imports.jl"))
include(joinpath(W, "test", "fixtures.jl"))
const R = Redstone
two_root_inputs() = Group((; s = Sum(sa = 1.0, sb = 1.0)); input_wires = ("a" => "s/a", "b" => "s/b"))
tag(s, v) = (println(s, " => ", repr(v)); flush(stdout))
function caught(f)
    try; f(); return :no_throw; catch e
        e isa R.DiagnosticError ? (e.carried isa Vector ? :collected : :single,
            [(nameof(typeof(d)), (hasproperty(d, :reason) ? d.reason : nothing)) for d in (e.carried isa Vector ? e.carried : [e.carried])]) :
            (typeof(e), first(sprint(showerror, e), 200))
    end
end
# P1 names
for n in (:passthrough, :input_passthrough, :output_passthrough, :faces, :claims, :reads,
          :connections, :exports, :events, :input_types, :output_types, :local_types,
          :u_types, :y_types, :init_x, :init_z, :init_m, :x_init, :m_init, :workspace, :ws_init,
          :probe_value, :h_x, :h_xu, :h_z, :h_zu, :project, :get_state, :get_deriv, :get_output,
          :get_local, :get_slot, :get_face, :get_input, :build, :run!, :step!, :replay!, :init!, :attach!,
          :detach!, :shutdown!, :apply!, :resolve, :resolve_terminal, :input_faces, :output_faces,
          :report!, :stage!, :mark_dead!, :is_greedy, :UninitializedSlots, :UninitializedInputs,
          :StopFaceInvalid, :ReadBindingUnresolved, :ReadResolution, :ReplayHeaderMismatch, :CheckpointMismatch,
          :RunPolicy, :StopPolicy, :TraceRegister, :peek_port, :peek, :pending, :port_views,
          :incumbent_status, :orphaned, :stale, :live!, :pause!, :resume!, :paused, :mode, :closed,
          :UnboundedRun, :TableBinding, :ReplayDiscardedStaging, :map_output, :map_input)
    println("P1 ", n, " defined=", isdefined(R, n))
end
# P2 passthrough keywords
tag("P2 kw input_passthrough", Base.kwarg_decl(only(methods(R.input_passthrough))))
# P3 greedy complement and harness
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
h1 = attach!(sim, Pad("e"), Enumerated("a"))
hg = attach!(sim, Pad("g"), Greedy())
tag("P3 greedy claim (complement of a)", hg.writer.faces)
tag("P3 harness faces after greedy", sim.plane.harness.faces)
stage!(sim, "b" => 1.0)
tag("P3 harness cell ring after stage b", [(nameof(typeof(d)), [getfield(d, f) for f in fieldnames(typeof(d))]) for d in (@atomic sim.plane.harness_diag.batch).ring])
stage!(sim, "zz" => 1.0)
tag("P3 harness cell after unknown face", [nameof(typeof(d)) for d in (@atomic sim.plane.harness_diag.batch).ring])
stage!(sim, "b" => "x")
tag("P3 harness ring kinds", [nameof(typeof(d)) for d in (@atomic sim.plane.harness_diag.batch).ring])
# P4 Batch carrier
tag("P4 Batch fields", fieldnames(R.Batch))
stage!(h1, "a" => 2.0)
b = (@atomic h1.writer.cell.pending)[]
tag("P4 batch types", (typeof(b.staged), typeof(b.mask)))
tag("P4 pending slot 1", pending(h1, 1))
# P5 detach then write primitives
detach!(sim, Pad("nope") isa Pad ? sim.plane.roster[1].dev : nothing)
tag("P5 stage! after detach", caught(() -> stage!(h1, "a" => 1.0)))
tag("P5 report! after detach", caught(() -> report!(h1, MalformedDatum("x"))))
tag("P5 latest after detach", caught(() -> latest(h1)))
tag("P5 pending after detach", caught(() -> pending(h1, 1)))
# P6 claim conflict collected, unknown face names device by type
sim2 = Simulation(two_root_inputs(); Δt_frame = 1//10)
attach!(sim2, Pad("x"), Enumerated("a", "b"))
tag("P6 ClaimConflict collected", caught(() -> attach!(sim2, Pad("y"), Enumerated("a", "b"))))
err = try attach!(sim2, Pad("z"), Enumerated("q", "r")) catch e; e end
tag("P6 AttachUnknownFace", (err.carried isa Vector, [(nameof(typeof(d)), d) for d in (err.carried isa Vector ? err.carried : [err.carried])]))
struct NoLoopDev <: AbstractDevice end
tag("P6 device no loop", caught(() -> attach!(sim2, NoLoopDev(), NoClaim())))
hn = attach!(sim2, Pad("w"), NoClaim())
init!(sim2, set(u = (a = 1.0, b = 2.0)))
tag("P6 gather no output side", caught(() -> gather(hn, latest(sim2))))
# P7 status, reads, snapshot type
sim3 = Simulation(two_root_inputs(); Δt_frame = 1//10)
hr = attach!(sim3, Pad("r"), Readout(s = get_output("s", "e")))
init!(sim3, set(u = (a = 1.0, b = 2.0)))
snap = latest(sim3)
tag("P7 gather", gather(hr, snap))
tag("P7 WriterStatus fields", fieldnames(R.WriterStatus))
tag("P7 status writers", [(w.who, w.heartbeat === nothing, w.task_state) for w in snap.status.writers])
tag("P7 writers type", typeof(snap.status.writers))
T1 = typeof(snap)
attach!(sim3, Pad("r2"), NoClaim()); attach!(sim3, Pad("r3"), Enumerated("a"))
init!(sim3, set(u = (a = 1.0, b = 2.0)))
tag("P7 snapshot type unchanged with roster", typeof(latest(sim3)) === T1)
# P8 Run, Trace, mode, replay
tag("P8 Run fields", fieldnames(R.Run))
tag("P8 Trace fields", fieldnames(R.Trace))
tag("P8 Simulation fields", fieldnames(R.Simulation))
tag("P8 Control fields", fieldnames(R.Control))
tag("P8 StopPolicy fields", fieldnames(R.StopPolicy))
tag("P8 TerminationRecord fields", fieldnames(R.TerminationRecord))
sim4 = Simulation(two_root_inputs(); Δt_frame = 1//10)
tag("P8 placeholder run", (sim4.run.trace, sim4.run.log.live, sim4.run.termination, mode(sim4), lifecycle(sim4)))
init!(sim4, set(u = (a = 1.0, b = 2.0)))
tag("P8 schemas after init", sim4.run.trace.schemas)
attach!(sim4, Pad("t1"), Enumerated("a"))
tag("P8 schemas after attach", sim4.run.trace.schemas)
stage!(sim4, "b" => 3.0)
step!(sim4; frames = 3)
trc = trace(sim4)
tag("P8 trace frames, batches", (trc.frames, length(trc.batches), trc.header isa R.Checkpoint))
step!(sim4)
tag("P8 copy detached", trc.frames)
sim5 = Simulation(two_root_inputs(); Δt_frame = 1//10)
attach!(sim5, Pad("t1"), Enumerated("a"))
init!(sim5, set(u = (a = 1.0, b = 2.0)))
replay!(sim5, trc; to_boundary = 1)
tag("P8 after replay! to 1", (mode(sim5), lifecycle(sim5)))
stage!(sim5, "b" => 9.0)
step!(sim5; frames = 1)
tag("P8 replay discards staging", [nameof(typeof(d)) for d in (@atomic sim5.plane.harness_diag.batch).ring])
n = step!(sim5; frames = 10)
tag("P8 step past end", (n, mode(sim5), lifecycle(sim5), sim5.run.termination))
init!(sim5, set(u = (a = 1.0, b = 2.0)))
tag("P8 init resets mode", mode(sim5))
tag("P8 trace=false", (init!(sim5, set(u = (a = 1.0, b = 2.0)); trace = false); sim5.run.trace))
# P9 termination, UnboundedRun, stop issuer
sim6 = Simulation(two_root_inputs(); Δt_frame = 1//10)
init!(sim6, set(u = (a = 1.0, b = 2.0)))
step!(sim6; t_end = 0.2, frames = 5)
rec = termination(sim6)
tag("P9 record", (rec.t, rec.policy, typeof(rec.source), rec.residue))
init!(sim6, set(u = (a = 1.0, b = 2.0)))
tag("P9 init clears record", termination(sim6))
R._request_stop!(sim6.control, :code); R._request_stop!(sim6.control, :interrupt)
tag("P9 first issuer wins", @atomic sim6.control.stop_issuer)
step!(sim6)
tag("P9 step! with pending stop", typeof(termination(sim6).source) => termination(sim6).source)
sim7 = Simulation(two_root_inputs(); Δt_frame = 1//10)
attach!(sim7, TailProbe(), NoClaim())   # a rostered device makes each frame yield
init!(sim7, set(u = (a = 1.0, b = 2.0)))
t = Threads.@spawn (sleep(0.3); stop!(sim7))
run!(sim7)
wait(t)
tag("P9 unbounded run loop cell", [(w.who, w.totals.unbounded) for w in latest(sim7).status.writers])
tag("P9 unbounded source", termination(sim7).source)
tag("P9 run! kw", Base.kwarg_decl(only(methods(R.run!, (Simulation,)))))
tag("P9 step! kw", Base.kwarg_decl(only(methods(R.step!, (Simulation,)))))
tag("P9 Simulation kw has t_end?", [Base.kwarg_decl(m) for m in methods(R.Simulation)])
# P10 pause
sim8 = Simulation(two_root_inputs(); Δt_frame = 1//10)
tag("P10 pause! on built", (pause!(sim8), paused(sim8), resume!(sim8), paused(sim8)))
tag("P10 handle pause method", hasmethod(R.pause!, Tuple{R.DeviceHandle}))
init!(sim8, set(u = (a = 1.0, b = 2.0)))
pause!(sim8)
tk = Threads.@spawn step!(sim8)
sleep(0.5)
tag("P10 step! blocked while paused", istaskdone(tk))
resume!(sim8); wait(tk)
tag("P10 step! after resume", istaskdone(tk))
pause!(sim8)
t2 = Threads.@spawn (sleep(0.3); stop!(sim8))
step!(sim8; frames = 2)   # paused + stopped -> ends
tag("P10 paused after step! stop (step! tail clears?)", paused(sim8))
sim9 = Simulation(two_root_inputs(); Δt_frame = 1//10)
init!(sim9, set(u = (a = 1.0, b = 2.0)))
run!(sim9; t_end = 0.3)
tag("P10 paused after run tail", paused(sim9))
pause!(sim9); init!(sim9, set(u = (a = 1.0, b = 2.0)))
tag("P10 init! clears pause?", paused(sim9)); resume!(sim9)
# P11 panel kit
sim10 = Simulation(two_root_inputs(); Δt_frame = 1//10)
hp = attach!(sim10, Pad("p"), Enumerated("a"))
init!(sim10, set(u = (a = 1.0, b = 2.0)))
pv = port_views(hp)
tag("P11 port_views type", typeof(pv))
tag("P11 keys", sort(collect(keys(pv))))
tag("P11 PortView fields", [(f, fieldtype(R.PortView, f), isconcretetype(fieldtype(R.PortView, f))) for f in fieldnames(R.PortView)])
tag("P11 view a", (pv[("", :a)].live, pv[("", :a)].slot, pv[("", :a)].incumbent))
tag("P11 view b", (pv[("", :b)].live, pv[("", :b)].incumbent))
tag("P11 view s/b", (pv[("s", :b)].source, pv[("s", :b)].incumbent))
tag("P11 incumbent_status harness-driven b", incumbent_status(pv[("", :b)], latest(sim10)))
tag("P11 incumbent_status s/y (no root driver)", incumbent_status(pv[("s", :e)], latest(sim10)))
stage!(hp, "a" => 5.0)
tag("P11 peek live a", R.peek(pv[("", :a)], hp, latest(sim10)))
tag("P11 peek b", R.peek(pv[("", :b)], hp, latest(sim10)))
tag("P11 orphaned :failed", orphaned(R.WriterStatus("x", R.DiagValue[], R.KindCounts(), R.KindCounts(), 0.0, :failed)))
# P12 ServiceLifecycle legal list for attach!
tag("P12 STOPPED_SIM_LEGAL", R.STOPPED_SIM_LEGAL)
tag("P12 READER_LEGAL", R.READER_LEGAL)
# P13 status allocation shape (D-241)
tag("P13 WriterStatus allocated inline in a Vector", Base.allocatedinline(R.WriterStatus))
sim11 = Simulation(two_root_inputs(); Δt_frame = 1//10)
attach!(sim11, Pad("a1"), NoClaim()); attach!(sim11, Pad("a2"), NoClaim()); attach!(sim11, Pad("a3"), NoClaim())
init!(sim11, set(u = (a = 1.0, b = 2.0)))
R._status(sim11, sim11.plane.roster, nothing)
tag("P13 _status allocations, 3 devices (bytes)", @allocated R._status(sim11, sim11.plane.roster, nothing))
tag("P13 _status allocs count", (@timed R._status(sim11, sim11.plane.roster, nothing)).gcstats.poolalloc + (@timed R._status(sim11, sim11.plane.roster, nothing)).gcstats.malloc)

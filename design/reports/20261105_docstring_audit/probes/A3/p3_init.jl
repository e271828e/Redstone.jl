module P3
include("design/reports/20261105_docstring_audit/probes/A3/common.jl")
println("--- events at t0")
sim = Simulation(fed(Trigger(0.5), "sig"); h = 1//10)
init!(sim, set(u = (in = 1.0,))); println("holding at t0: ", modes(sim, "c"), " prior=", sim.model.exec.events.prior)
step!(sim; frames = 2); println("after 2 frames: ", modes(sim, "c"))
init!(sim, set(u = (in = 1.0,)); t0 = 3.0); println("second init at t0=3: ", modes(sim, "c"), " t=", latest(sim).t, " t0=", sim.model.exec.clock.t₀)
tr = trace(sim); rep = Simulation(sim.model.deployment); replay!(rep, tr); println("replay of header (no re-fire): ", modes(rep, "c"))
println("header identity vs latest: header.t=", tr.header.state.t, " frame=", tr.header.frame, " boundary=", tr.header.boundary, " sim.run.boundary=", sim.run.boundary, " latest.boundary=", latest(sim).boundary)

println("--- batches")
sim = Simulation(fed(Gain(2.0), "e"); h = 1//10)
init!(sim, set(u = (in = 1.0,))); step!(sim)
stage!(sim, "in" => 5.0)
init!(sim, set(u = (in = 1.0,))); println("after init: in=", port(sim, "", :in)); step!(sim); println("staged before init dropped: in=", port(sim, "", :in))
init!(sim, set(u = (in = 1.0,))); stage!(sim, "in" => 7.0); println("staged after init, before frame: in=", port(sim, "", :in)); step!(sim); println("after frame 1: in=", port(sim, "", :in), " frame=", latest(sim).frame, " trace batches=", [(b.frame) for b in sim.run.trace.batches])
# a built simulation too
fresh = Simulation(sim.model.deployment); stage!(fresh, "in" => 9.0); init!(fresh, set(u = (in = 1.0,))); step!(fresh); println("staged on built, dropped: in=", port(fresh, "", :in))
# stop word
init!(sim, set(u = (in = 1.0,))); stop!(sim); init!(sim, set(u = (in = 1.0,))); println("stop word after init: ", (@atomic sim.control.stop_issuer))

println("--- diagnostic cells")
sim = Simulation(fed(Gain(2.0), "e"); h = 1//10)
init!(sim, set(u = (in = 1.0,))); run!(sim; t_end = 0.1); println(lifecycle(sim))
stage!(sim, "nope" => 1.0)                      # a rejection recorded while stopped
println("harness cell pending? ", sim.plane.harness_diag)
init!(sim, set(u = (in = 1.0,)))
h() = [length(w.recent) for w in latest(sim).status.writers if w.who == "harness"]
println("boundary-zero snapshot recent=", h(), " boundary=", latest(sim).boundary, " frame=", latest(sim).frame)
snaps0 = logged(sim)
step!(sim); println("frame-1 snapshot recent=", h(), " boundary=", latest(sim).boundary, " frame=", latest(sim).frame)
sim2 = Simulation(fed(Gain(2.0), "e"); h = 1//10)
init!(sim2, set(u = (in = 1.0,))); run!(sim2; t_end = 0.1)
stage!(sim2, "nope" => 1.0); init!(sim2, set(u = (in = 1.0,))); run!(sim2; t_end = 0.3)
println("via run!: ", [(s.frame, s.boundary, [length(w.recent) for w in s.status.writers]) for s in logged(sim2)], " residue=", termination(sim2).residue)

println("--- log_max and log_every")
s = Simulation(single(Sawtooth(0.1)); h = 1//10)
init!(s; log_max = 4); step!(s; frames = 100); fr = [x.frame for x in logged(s)]; println("log_max=4 100 frames: ", fr, " middle ≤ 4? stride=", s.run.log.stride, " live=", s.run.log.live)
init!(s; log_max = 1); step!(s; frames = 20); println("log_max=1: ", [x.frame for x in logged(s)])
init!(s; log_every = 3); step!(s; frames = 10); println("log_every=3: ", [x.frame for x in logged(s)])
init!(s; log_every = 3, log_max = Inf); step!(s; frames = 10); println("log_every=3 Inf: ", [x.frame for x in logged(s)])
init!(s; log = false); step!(s; frames = 3); println("log=false: ", length(logged(s)), " latest.frame=", latest(s).frame)
init!(s; trace = false); tryit("trace(s) under trace=false", () -> trace(s))

println("--- recording keywords never change the trajectory")
function traj(; kw...)
    s = Simulation(fed(Trigger(0.5), "sig"); h = 1//10)
    init!(s, set(u = (in = 0.0,)); kw...); stage!(s, "in" => 1.0); step!(s; frames = 5)
    (latest(s).t, bitstring(s.model.exec.clock.t), modes(s, "c"), [x for x in s.model.exec.xbuf])
end
println(traj() == traj(trace = false) == traj(log = false) == traj(log_every = 3) == traj(log_max = 1))

println("--- refusals")
s = Simulation(fed(Gain(2.0), "e"); h = 1//10)
init!(s, set(u = (in = 1.0,))); step!(s); stage!(s, "in" => 3.0)
r0 = s.run; l0 = latest(s); cp0 = checkpoint(s); pend = s.plane.harness.cell.pending
for (lab, f) in (
      "log_every=0" => () -> init!(s, set(u = (in = 1.0,)); log_every = 0),
      "all four bad" => () -> init!(s, set(u = (in = 1.0,)); log_every = 0, log_max = 0, trace = 1, log = :a),
      "log_max=2.5" => () -> init!(s, set(u = (in = 1.0,)); log_max = 2.5),
      "log_every=2.0" => () -> init!(s, set(u = (in = 1.0,)); log_every = 2.0),
      "bad path" => () -> init!(s, at("nope", set(x = (q = 1.0,)))),
      "bad field" => () -> init!(s, combine(at("c", set(s = (nope = 1.0,))), set(u = (in = 1.0,)))),
      "not a node" => () -> init!(s, (; s = 1)),
      "a number" => () -> init!(s, 3),
      "duplicate leaf" => () -> init!(s, combine(set(u = (in = 1.0,)), set(u = (in = 2.0,)))),
      "missing root input" => () -> init!(s),
      "unconvertible" => () -> init!(s, set(u = (in = "x",))),
      "time entry" => () -> init!(s, set(t = 1.0, u = (in = 1.0,))),
      "t0 string" => () -> init!(s, set(u = (in = 1.0,)); t0 = "a"))
    tryit(lab, f)
    println("   unchanged: ", s.run === r0, " ", latest(s) === l0, " ", s.plane.harness.cell.pending === pend, " life=", lifecycle(s))
end
println("--- oversized integer keywords (Int conversion)")
s = Simulation(fed(Gain(2.0), "e"); h = 1//10); init!(s, set(u = (in = 1.0,))); stage!(s, "in" => 3.0); r0 = s.run; pend = s.plane.harness.cell.pending
tryit("log_every=big", () -> init!(s, set(u = (in = 1.0,)); log_every = big(10)^30))
println("   run same: ", s.run === r0, " batch kept: ", s.plane.harness.cell.pending === pend, " pending=", s.plane.harness.cell.pending === nothing ? "dropped" : "there", " life=", lifecycle(s))
println("--- t0 values")
for t0 in (NaN, Inf, -Inf, 1e300, -2.5, 3, 1//3, big"0.1", true)
    s = Simulation(single(Sawtooth(0.1)); h = 1//10)
    r = tryit("t0=$t0", () -> init!(s; t0))
    println("   life=", lifecycle(s), " clock=", s.model.exec.clock.t, " t0=", s.model.exec.clock.t₀, " header=", s.run.trace === nothing ? nothing : s.run.trace.header === nothing ? "none" : "set")
end
println("--- errored")
s = Simulation(fed(Exploder(), "arm"); h = 1//10); init!(s, set(u = (in = false,))); stage!(s, "in" => true); failure(() -> step!(s))
tryit("init! errored", () -> init!(s, set(u = (in = false,))))
tryit("restore! errored", () -> restore!(s, s.run.trace.header))
tryit("replay! errored", () -> replay!(s, s.run.trace))
tryit("checkpoint errored", () -> checkpoint(s))
tryit("overlay! errored", () -> overlay!(s))
println(lifecycle(s), " mode=", mode(s))
end

# Compare the residue warnings' text, order and count, old vs new code.
using Test
two() = Group((; s = Sum(sa = 1.0, sb = 1.0)); input_wires = ("a" => "s/a", "b" => "s/b"))
sim = Simulation(two(); Δt_frame = 1//10)
attach!(sim, TailProbe(), NoClaim())
attach!(sim, TailProbe(), NoClaim())
init!(sim, set(u = (a = 0.0, b = 0.0)))
plane = sim.plane
roster = copy(plane.roster)
mk(who, i) = DeviceJoinTimeout(who, 0.1 * i, 0.0, i)
for i in 1:18; Redstone.report_cell!(Redstone._handle(roster[1]).diag_cell, mk("d1", i)); end
for i in 1:2;  Redstone.report_cell!(plane.harness_diag, mk("h", i)); end
for i in 1:20; Redstone.report_cell!(plane.loop_diag, mk("l", i)); end
logs, residue = Test.collect_test_logs() do
    r = Redstone._sweep_tail!(sim, roster)
    isdefined(Redstone, :_present_residue) && Redstone._present_residue(r)
    r
end
println("records: ", [(r.writer, length(r.recent), Redstone._total(r.suppressed)) for r in residue])
println("n logs: ", length(logs))
for l in logs
    println(l.level, " | ", l.message)
end

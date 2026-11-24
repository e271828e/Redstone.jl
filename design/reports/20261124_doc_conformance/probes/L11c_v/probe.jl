# L11c_v probes, run from the pinned worktree with --project=test.
using Test, Redstone, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
const T = joinpath(pwd(), "test")
include(joinpath(T, "imports.jl")); include(joinpath(T, "fixtures.jl")); include(joinpath(T, "utils.jl"))
import Redstone: pause!, series, overlay!, Reads
p(tag, x) = println(tag, " => ", x)
tryd(f) = try f(); :no_throw catch e; e isa DiagnosticError ? (e.carried isa Vector ? e.carried : [e.carried]) : e end

mk() = (s = Simulation(fed(Plant(), "u"); Δt_frame = 1//10); init!(s, set(u = (in = 0.0,))); s)

# L11c-001: what the run and a snapshot carry (no firing record)
p("P001 Run fields", fieldnames(Redstone.Run))
p("P001 Snapshot fields", fieldnames(Redstone.Snapshot))

# L11c-013: no pause on the handle
p("P013 pause!(DeviceHandle)", hasmethod(pause!, Tuple{DeviceHandle}))
p("P013 pause!(Simulation)", hasmethod(pause!, Tuple{Simulation}))

# L11c-023: the default log_max, same whatever t_end
sim = mk(); p("P023 log_max after init!", sim.run.log.log_max)

# L11c-032 / 041: ring capacity and renderer cap
cell = DiagCell(EMPTY_DIAG)
for i in 1:(DIAG_RING + 3)
    Redstone.report_cell!(cell, OutOfClaimEntry(:zz, i, Symbol[], nothing))
end
b = @atomic cell.batch
p("P032 ring length / suppressed", (length(b.ring), b.suppressed.out_of_claim, DIAG_RING))
p("P041 STATUS_MAXLOG", Redstone.STATUS_MAXLOG)
sim = mk()
for f in 1:3
    for i in 1:12; stage!(sim, "zz$i" => 1.0); end
    step!(sim)
end
lines = Redstone._lines(latest(sim).status)
hz = findfirst(l -> occursin("harness", l), lines)
p("P041 harness group lines", lines[hz:min(hz+3, end)])
p("P041 printed occurrence lines (36 total)", count(l -> startswith(lstrip(l), "OutOfClaimEntry: `"), lines))

# L11c-050: harness surface recomputed at attach!/detach!
sim = mk()
p("P050 harness faces before", sim.plane.harness.faces)
d1 = Pad("a"); h = attach!(sim, d1, Enumerated("in"))
p("P050 harness faces after attach", sim.plane.harness.faces)
stage!(sim, "in" => 2.0); step!(sim)
p("P050 harness ClaimedFaceEntry", [typeof(x) for x in latest(sim).status.writers[end-1].recent])
detach!(sim, d1)
p("P050 harness faces after detach", sim.plane.harness.faces)

# L11c-059: is_output calls reads(b)
const READS_CALLS = Ref(0)
struct CountingReads <: AbstractBinding end
Redstone.is_output(::CountingReads) = true
Redstone.reads(::CountingReads) = (READS_CALLS[] += 1; (; y = get_output("c", :y)))
sim = mk(); attach!(sim, Pad("r"), CountingReads())
p("P059 reads calls at attach", READS_CALLS[])

# L11c-080: identity is the instance
sim = mk(); a = Pad("x"); b2 = Pad("x")
attach!(sim, a, NoClaim()); attach!(sim, b2, NoClaim())
p("P080 two instances rostered", length(sim.plane.roster))
p("P080 same instance again", tryd(() -> attach!(sim, a, NoClaim())))

# L11c-089: first snapshot of each door's run
sim = mk(); step!(sim; frames = 3)
p("P089 init! first boundary", logged(sim)[1].boundary)
cp = checkpoint(sim)
sim2 = Simulation(fed(Plant(), "u"); Δt_frame = 1//10)
restore!(sim2, cp); step!(sim2; frames = 2)
p("P089 restore! first boundary / cp.boundary", (logged(sim2)[1].boundary, cp.boundary, [s.boundary for s in logged(sim2)]))
overlay!(sim, at("c", set(x = (q = SVector(1.0, 0.0),)))); step!(sim; frames = 2)
p("P089 overlay! log boundaries", [s.boundary for s in logged(sim)])

# L11c-101 / 111 / 118: store selector under a table source; label not device
sim = mk()
r = tryd(() -> attach!(sim, Pad("s"), Readout(; q = get_state("c", :q))))
p("P101 attach store selector", r)
d = r[1]
p("P101 reason / label / fields", (d.reason, d.label, fieldnames(typeof(d))))
p("P101 message", Redstone.message(d))
r = tryd(() -> series(sim, reads(q = get_state("c", :q))))
p("P118 series store selector", [(x.reason, typeof(x)) for x in r])

# L11c-123 / 133: overlay! on stopped run opens a fresh run; replay reproduces it
sim = mk(); run!(sim; t_end = 0.3)
p("P123 lifecycle before", lifecycle(sim))
old = sim.run
overlay!(sim, at("c", set(x = (q = SVector(0.5, 0.0),))))
p("P123 fresh run / lifecycle", (sim.run !== old, lifecycle(sim)))
stage!(sim, "in" => 1.0); run!(sim; t_end = 0.8)
twin = Simulation(fed(Plant(), "u"); Δt_frame = 1//10)
replay!(twin, trace(sim))
p("P133 replay reproduces", ([s.t for s in logged(twin)] == [s.t for s in logged(sim)],
    all(port(a, "c", :y) == port(b, "c", :y) for (a, b) in zip(logged(twin), logged(sim)))))

# L11c-142: step! halting initialized runs no sweep; reports wait through a door
sim = mk(); step!(sim)
stage!(sim, "nope" => 1.0)   # a report into the harness cell while initialized
p("P142 termination after step! / lifecycle", (termination(sim), lifecycle(sim)))
overlay!(sim, set())          # a door between
p("P142 cell after door holds", length((@atomic sim.plane.harness_diag.batch).ring))
step!(sim)
p("P142 harness recent after next frame top", [typeof(x) for x in latest(sim).status.writers[end-1].recent])

# L11c-151: deployment line in the Simulation's REPL form
sim = mk()
out = sprint(show, MIME"text/plain"(), sim)
p("P151 REPL form", out)
p("P151 deployment one-line", sprint(show, sim.model.deployment))

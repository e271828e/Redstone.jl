# L11c probe: log entries D-309..D-476 against the pinned worktree.
include(joinpath(@__DIR__, "..", "..", "..", "..", "..", "test", "RedstoneTests.jl"))
using .RedstoneTests
@eval RedstoneTests begin
P(tag, x) = println("PROBE ", tag, " => ", x)
function caught(f)
    try; f(); return :no_throw
    catch e
        e isa DiagnosticError || return (typeof(e), sprint(showerror, e))
        d = e.carried
        return d isa Vector ? [(typeof(x), hasfield(typeof(x), :reason) ? x.reason : nothing) for x in d] :
               (typeof(d), hasfield(typeof(d), :reason) ? d.reason : nothing)
    end
end
struct NoLoopDev <: AbstractDevice end
mutable struct NoLoopDev2 <: AbstractDevice end

sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
# D-366: no loop method
P("D366 noloop", caught(() -> attach!(sim, NoLoopDev2(), NoClaim())))
P("D366 hooks default", (init!(Pad("x")), shutdown!(Pad("x")), unblock!(Pad("x"))))
# D-375: identity then claims; ids monotonic
d1 = Pad("d1"); h1 = attach!(sim, d1, Enumerated("a"))
P("D375 id1", h1.who)
P("D375 same instance conflicting claim", caught(() -> attach!(sim, d1, Enumerated("a"))))
P("D375 twin instance", caught(() -> attach!(sim, Pad("d1"), Enumerated("a"))))
detach!(sim, d1)
h2 = attach!(sim, Pad("d2"), Enumerated("a"))
P("D375 id after detach", h2.who)
# D-370: second greedy empty claim
g1 = attach!(sim, Pad("g1"), Greedy())
P("D370 greedy1 faces", g1.writer.faces)
g2 = attach!(sim, Pad("g2"), Greedy())
P("D370 greedy2 faces", g2.writer.faces, )
P("D370 greedy2 cell", [typeof(x) for x in (@atomic g2.diag_cell.batch).ring])
P("D370 harness faces", sim.plane.harness.faces)
# harness staging a claimed face -> ClaimedFaceEntry; device out of claim -> OutOfClaimEntry
stage!(sim, "a" => 1.0)
P("D370 harness claimed", [typeof(x) for x in (@atomic sim.plane.harness_diag.batch).ring])
stage!(h2, "b" => 1.0)
P("D370 device out of claim", [typeof(x) for x in (@atomic h2.diag_cell.batch).ring])

# D-406: binding reads
sim2 = Simulation(two_root_inputs(); Δt_frame = 1//10)
P("D406 assembly path get_output", caught(() -> attach!(sim2, Pad("r"), Readout(; v = get_output("", :a)))))
P("D406 store selector", caught(() -> attach!(sim2, Pad("r"), Readout(; v = get_state("s")))))
sim2b = Simulation(chain3(); Δt_frame = 1//10)
P("D406 store selector leaf", caught(() -> attach!(sim2b, Pad("r"), Readout(; v = get_state("p", :q)))))
P("D406 store selector headless", caught(() -> attach!(sim2b, Pad("r"), Readout(; v = get_state("p")))))
P("D406 ok primitive port", caught(() -> attach!(sim2, Pad("r"), Readout(; v = get_output("s", :e)))))
try attach!(sim2, Pad("r2"), Readout(; v = get_state("s"))) catch e; P("D406 fields", fieldnames(typeof(e.carried isa Vector ? e.carried[1] : e.carried))) end

# D-369: ring bound and suppressed counts, quiet take allocation, isbits
cell = DiagCell(EMPTY_DIAG)
for i in 1:20; Redstone.report_cell!(cell, MalformedDatum("d$i")); end
b = @atomic cell.batch
P("D369 ring", (length(b.ring), b.ring[1].cause, b.ring[end].cause, b.suppressed.malformed))
qc = DiagCell(EMPTY_DIAG); Redstone._take!(qc)
P("D369 quiet take alloc", @allocated Redstone._take!(qc))
acct = Redstone.WriterAccount(); Redstone._fold!(acct, qc)
P("D369 quiet fold alloc", @allocated Redstone._fold!(acct, qc))
P("D369 isbits KindCounts", isbitstype(KindCounts))
P("D369 STATUS_MAXLOG", STATUS_MAXLOG)

# D-368 / D-377: log bound and endpoints
sim3 = Simulation(two_root_inputs(); Δt_frame = 1//10)
init!(sim3, set(u = (a = 1.0, b = 2.0)); log_max = 4)
step!(sim3; frames = 37)
L = logged(sim3)
P("D368 logged boundaries", [s.boundary for s in L])
P("D368 middle live", sim3.run.log.live)
sim4 = Simulation(two_root_inputs(); Δt_frame = 1//10)
init!(sim4, set(u = (a = 1.0, b = 2.0)); log_every = 3)
step!(sim4; frames = 10)
P("D377 every3", [s.boundary for s in logged(sim4)])
P("D368 trace header has log_max", hasfield(typeof(trace(sim3).header), :log_max))
P("D368 init! default", Base.kwarg_decl(first(methods(Redstone.init!, (Simulation, Any)))))

# D-407 / D-474: series
rs = reads(; V = get_output("s", :e))
fl = series(sim3, rs)
P("D474 property", (fl.V === fl.columns.V, eltype(fl.V), propertynames(fl)))
P("D474 reserved", caught(() -> series(sim3, reads(; t = get_output("s", :e)))))
P("D474 reads accepts t", typeof(reads(; t = get_output("s", :e))))
P("D407 store selector", caught(() -> series(sim3, reads(; q = get_state("s")))))
P("D407 at mounts", caught(() -> series(sim3, at("s", reads(; V = get_output("", :e))))))

# D-476: printing
println(sprint(show, MIME"text/plain"(), sim3)); println(sprint(show, sim3))
println(sprint(show, MIME"text/plain"(), fl)); println(sprint(show, fl))
lin = Linearization([0.0], [1.23456789], [2.5], [123456.789], fill(-1.0, 1, 1), fill(1234.56789, 1, 1),
                    fill(0.000123456789, 1, 1), fill(7.0, 1, 1), (:longlabel_x,), (:u,), (:y,))
println(sprint(show, MIME"text/plain"(), lin))
end

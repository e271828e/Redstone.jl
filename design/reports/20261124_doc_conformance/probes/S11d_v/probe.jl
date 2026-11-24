# S11d verifier probe: §11.7 and §11.8 claims against W at f14dbc1d.
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test
const T = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(T, "imports.jl"))
include(joinpath(T, "fixtures.jl"))
import Redstone: _status

panel_model() = Group((; inner = Group((; c = Pendulum(), g = Gain(2.0));
                                       input_wires = ("u" => "c/u", "e" => "g/e"),
                                       output_wires = ("c/θ" => "θ",)),
                         ctl = DiscreteAccumulator(1.0));
                      local_wires = ("ctl/u" => "inner/u",),
                      input_wires = ("in" => "ctl/e", "gain_in" => "inner/e"))

# A device that reports on its exit path, after the run's last frame top.
mutable struct LateReporter <: AbstractDevice end
function loop(::LateReporter, handle)
    while running(handle); wait_next_snapshot(handle); end
    report!(handle, MalformedDatum("late"))
    nothing
end
# A device that reports a malformed datum once from its own task.
mutable struct Reporter <: AbstractDevice; done::Bool; end
function loop(d::Reporter, handle)
    d.done || (report!(handle, MalformedDatum("bad")); d.done = true)
    while running(handle); wait_next_snapshot(handle); end
    nothing
end

println("threads = ", Threads.nthreads())

# S11d-005: every input view resolves to a root input or a component output.
sim = Simulation(panel_model(); Δt_frame = 1//10)
h = attach!(sim, Pad("a"), Enumerated("in"))
views = port_views(h)
root_inputs = Set(f for (f, _) in h.layout.root_inputs)
outcomes = map(collect(views)) do (k, v)
    v.source == k ? :self :
    (v.source[1] == "" && v.source[2] in root_inputs) ? :root : (haskey(h.layout.addr, v.source) ? :component : :other)
end
println("S11d-005 outcomes: ", sort(unique(outcomes)), " counts=", [(o, count(==(o), outcomes)) for o in unique(outcomes)])
println("S11d-005 unconnected build: ", try Simulation(Group((; g = Gain(1.0))); Δt_frame = 1//10); "built" catch e; typeof(e), map(typeof, diagnostics(e)) end)

# S11d-033: the handle holds the build's Structure and the nominal Layout by reference.
println("S11d-033 structure===: ", h.structure === sim.model.deployment.build.structure,
        " layout===: ", h.layout === sim.model.exec.act.layout,
        " scalar: ", eltype(sim.model.exec.act.layout) )

# S11d-042 and S11d-004.
attach!(sim, Pad("b"), Greedy())
init!(sim, set(u = (in = 1.0, gain_in = 2.0)))
views = port_views(h)
stage!(h, "in" => 5.0)
s = latest(sim)
println("S11d-042 live peek=", peek(views[("ctl", :e)], h, s), " snapshot in=", port(s, "", :in),
        " readonly peek=", peek(views[("inner/g", :e)], h, s), " snap gain_in=", port(s, "", :gain_in))
alone = Simulation(panel_model(); Δt_frame = 1//10)
ah = attach!(alone, Pad("a"), Enumerated("in"))
init!(alone, set(u = (in = 1.0, gain_in = 2.0)))
av = port_views(ah)
r = incumbent_status(av[("inner/g", :e)], latest(alone))
println("S11d-004 unclaimed root input (no device writes it): incumbent=", repr(av[("inner/g", :e)].incumbent),
        " status=", r === nothing ? nothing : r.who)
println("S11d-004 component-driven: ", incumbent_status(av[("inner/c", :u)], latest(alone)))

# S11d-061: earliest retained, excess counted.
cell = DiagCell(EMPTY_DIAG)
for i in 1:20; report_cell!(cell, MalformedDatum(i)); end
b = _take!(cell)
println("S11d-061 ring causes=", [d.cause for d in b.ring], " suppressed malformed=", b.suppressed.malformed)
println("S11d-061 quiet take is sentinel: ", _take!(cell) === EMPTY_DIAG)

# S11d-003/002/052/079: frame cell and loop cell fold into the loop's record; pacer rides beside.
report_cell!(alone.model.frame_diag, ChatteringBudget("inner/c", :x, 0.0, 1, 1))
report_cell!(alone.plane.loop_diag, DebtReanchor(0.1, 0.0, 0.0))
step!(alone)
st = latest(alone).status
println("S11d-003/002 writers=", [w.who for w in st.writers], " loop recent=", map(typeof, st.writers[end].recent),
        " loop totals chattering=", st.writers[end].totals.chattering, " reanchor=", st.writers[end].totals.reanchor)
println("S11d-079 status fields=", fieldnames(typeof(st)), " pacer=", typeof(st.pacer))

# S11d-001/014/070/088: a run with devices on their own tasks.
rs = Simulation(panel_model(); Δt_frame = 1//10)
rh = attach!(rs, Reporter(false), Enumerated("in"))
lh = attach!(rs, LateReporter(), NoClaim())
init!(rs, set(u = (in = 1.0, gain_in = 2.0)))
obs = Threads.@spawn begin
    timedwait(() -> latest(rs).frame > 3, 20.0)
    a = try attach!(rs, Pad("z"), NoClaim()); "attached" catch e; typeof(e) end
    d = try detach!(rs, Pad("y")); "detached" catch e; typeof(e) end
    lc = lifecycle(rs)
    timedwait(() -> latest(rs).status.writers[1].totals.malformed ≥ 1, 20.0)
    hb = latest(rs).status.writers[1].heartbeat
    stop!(rs)
    (a, d, lc, hb)
end
run!(rs; t_end = 1.0e6)
(a, d, lc, hb) = fetch(obs)
println("S11d-014 attach mid-run: ", a, " detach mid-run: ", d, " lifecycle then: ", lc)
println("S11d-001 device record malformed total=", latest(rs).status.writers[1].totals.malformed,
        " who=", latest(rs).status.writers[1].who)
println("S11d-070 heartbeat in status: ", hb, " (now ", time(), ")")
term = rs.run.termination
println("S11d-088 residue=", [(x.writer, map(typeof, x.recent)) for x in term.residue],
        " terminal snapshot late malformed=", latest(rs).status.writers[2].totals.malformed)

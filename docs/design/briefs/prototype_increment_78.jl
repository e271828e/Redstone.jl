# Reference implementation for increment 78, run to green in the increment 77
# prototype worktree on 2026-10-19 (the `source` keyword and the collected
# attach refusals of D-406 in place). The `series` block goes after `logged`
# in src/sim.jl; the two `@nospecialize` go on `_compile_reads`'s and
# `_resolve_reads`'s read_set in src/readers.jl. The probe below it is what
# the testset pins, on the examples' closed loop.

# --- src/sim.jl, after logged ---
"""
What `series` returns (§11.2, D-407): the retained snapshots' stamps, oldest
first, and one column per labeled entry of the read set, a plain vector of
that entry's leaf type, keyed as the set labels it.
"""
struct Series{NT<:NamedTuple}
    t::Vector{Float64}
    frame::Vector{Int}
    boundary::Vector{Int}
    columns::NT
end

"""
    series(sim, read_set) → Series

Post-run extraction from the log through the read-selector family (§11.2,
D-407): the read set, `reads(…)` or `at(prefix, reads(…))`, resolves against
the build for a table source through the one resolver every reader shares
(§14.4, D-406), and each entry is gathered over `logged(sim)` into one typed
column. Resolution runs once per call and the gather is one typed loop per
column; the labels never reach a compiled body, so a new label set costs no
compilation, only a new leaf type or chain does. Behind `logged`'s stopped-sim
gate (§11.3); empty columns before the first `init!`, typed all the same.
"""
function series(sim::Simulation, @nospecialize(read_set::Reads))
    assert_stopped(sim, :series)
    reader = _compile_reads(read_set, sim.model.deployment.build, Float64; source = :table)
    snapshots = logged(sim)
    columns = Any[_column(snapshots, entry) for entry in reader.entries]
    Series([s.t for s in snapshots], [s.frame for s in snapshots], [s.boundary for s in snapshots],
           NamedTuple{keys(read_set.selectors)}(Tuple(columns)))
end

# One column, the function barrier: specialized on the entry's leaf type and
# chain alone, the eltype read off the resolved chain so an empty log yields
# a typed empty vector.
function _column(snapshots::Vector, entry::CellRead{A,C}) where {A,C}
    column = Vector{_resolved_type(_port_type(entry.addr), C)}(undef, length(snapshots))
    for (i, snapshot) in enumerate(snapshots)
        column[i] = _read(entry, snapshot.store)
    end
    column
end

# --- src/readers.jl ---
+function _compile_reads(@nospecialize(read_set::Reads), build::Build, ::Type{T} = Float64;
+function _resolve_reads(@nospecialize(read_set::Reads), build::Build, ::Type{T};

# --- the probe ---
using Redstone, RedstoneExamples, StaticArrays
import Redstone: combine, Simulation, init!, run!, trim!, linearize, port, logged, set, at, reads,
    get_output, get_input, get_face, get_state, series, Series, diagnostics, DiagnosticError
import RedstoneExamples: aircraft, level_flight, longitudinal_taps, lqr_gains, closed_loop, trimmed

sim = Simulation(aircraft(); h = 1//100)
report = trim!(sim, level_flight(); baseline = set(u = (δe = 0.0, δt = 0.5)))
solution = report.solution
gains = lqr_gains(linearize(sim, longitudinal_taps()))
loop = Simulation(closed_loop(solution, gains; cascade = t -> false); h = 1//200)

# empty log, typed columns
empty = series(loop, reads(h = get_output("plant", :h), u = get_output("tracker", :u)))
println("empty: ", length(empty.t), " ", typeof(empty.columns))

init!(loop, trimmed(solution)); run!(loop; t_end = 120.0)
snaps = logged(loop)
print("series, 4 labels, first:   "); @time ts = series(loop, reads(h = get_output("plant", :h), V = get_output("plant", :V), δe = get_output("tracker", "u[1]"), engaged = get_output("mode", :out)))
@assert ts.columns.h == [port(s, "plant", :h) for s in snaps]
@assert ts.columns.δe == [port(s, "tracker", :u)[1] for s in snaps]
@assert ts.columns.engaged == [port(s, "mode", :out) for s in snaps]
@assert ts.t == [s.t for s in snaps] && ts.frame == [s.frame for s in snaps] && ts.boundary == [s.boundary for s in snaps]
println("types: ", typeof(ts.columns))
print("same set again:            "); @time series(loop, reads(h = get_output("plant", :h), V = get_output("plant", :V), δe = get_output("tracker", "u[1]"), engaged = get_output("mode", :out)))
print("new labels, same entries:  "); @time series(loop, reads(a = get_output("plant", :h), b = get_output("plant", :V), c = get_output("tracker", "u[1]"), d = get_output("mode", :out)))
print("one new label, seen type:  "); @time series(loop, reads(q = get_output("plant", :q)))
print("new leaf type Int8:        "); @time series(loop, reads(sat = get_output("h_ctl", :saturated)))
print("new chain u[2]:            "); @time series(loop, reads(δt = get_output("tracker", "u[2]")))
print("whole SVector:             "); @time series(loop, reads(u = get_output("tracker", :u)))
# a mount on the open-loop aircraft, a primitive at "plant"
init!(sim, combine(at("plant", set(x = (V = 55.0,))), set(u = (δe = solution.δe, δt = solution.δt)))); run!(sim; t_end = 2.0)
m = series(sim, at("plant", reads(h = get_face(:h), V = get_output("", :V))))
@assert m.columns.h == [port(s, "plant", :h) for s in logged(sim)]
δ = series(sim, reads(δe = get_input(:δe)))
println("mount + root input ok: ", length(δ.t), " ", typeof(δ.columns))
# refusals, collected
for rs in (reads(x = get_state("plant", :V)), reads(h = get_output("plant", :nope)), reads(h = get_output("nope", :h)),
           reads(a = get_output("plant", :nope), b = get_state("plant", :V), c = get_face(:nope)))
    err = try series(loop, rs) catch e; e end
    println([ (nameof(typeof(d)), getfield(d, :reason)) for d in diagnostics(err) ])
end
println(sprint(showerror, try series(loop, reads(h = get_output("plant", :nope))) catch e; e end))

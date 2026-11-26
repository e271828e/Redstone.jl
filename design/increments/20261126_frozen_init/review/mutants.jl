# Mutant driver: load the suite once, then for each mutant redefine methods in
# `Redstone` by `@eval`, run the four new testsets plus the old frozen one, and
# report which assertions failed. The baseline (no mutant) runs first; the
# originals are restored by re-evaluating the unmodified source definitions.
const TREE = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/frozen_init_review"
include(joinpath(TREE, "test", "RedstoneTests.jl"))
using Test, ForwardDiff
import Redstone

const SRC = read(joinpath(TREE, "src", "model.jl"), String)

# The original text of the new helper and the init! plan method, cut by markers.
function cut(from, to)
    i = findfirst(from, SRC)
    j = findnext(to, SRC, last(i))
    SRC[first(i):last(j)]
end
const ESTABLISH_SRC = cut("function _establish_frozen!(model::Model{T}, origin::Rational{Int}) where {T}", "\nend\n")
const DROP_SRC = cut("_drop_partials(::Type{P}, value) where {P} =", "_drop_partials(leaf) = leaf\n")
const INIT_SRC = cut("function init!(model::Model{T}, plan::ConditionPlan; t0 = 0,", "\nend\n")

evalsrc(s) = Base.include_string(Redstone, s, "mutant")

function restore_all()
    evalsrc(ESTABLISH_SRC); evalsrc(DROP_SRC); evalsrc(INIT_SRC)
end

function mutate(src, old, new)
    occursin(old, src) || error("mutant anchor not found: $old")
    replace(src, old => new; count = 1)
end

const MUTANTS = [
    "M0 revert: no nominal round at all" =>
        () -> evalsrc(mutate(INIT_SRC, "        _establish_frozen!(model, origin)   # a non-nominal scalar's frozen cells (D-481)\n", "")),
    "M1 nominal round after boundary_zero!" =>
        () -> evalsrc(mutate(INIT_SRC,
            "        _establish_frozen!(model, origin)   # a non-nominal scalar's frozen cells (D-481)\n        boundary_zero!(model)\n",
            "        boundary_zero!(model)\n        _establish_frozen!(model, origin)\n")),
    "M2 one-level _drop_partials on a Dual leaf" =>
        () -> evalsrc(mutate(DROP_SRC, "_drop_partials(leaf::ForwardDiff.Dual) = _drop_partials(ForwardDiff.value(leaf))",
                             "_drop_partials(leaf::ForwardDiff.Dual) = ForwardDiff.value(leaf)")),
    "M3 no root-input copy" =>
        () -> evalsrc(mutate(ESTABLISH_SRC, "    for face in build.structure.root_inputs\n", "    for face in ()\n")),
    "M4 no cursor copy" =>
        () -> evalsrc(mutate(ESTABLISH_SRC, "            setfield!(cursor, field, getfield(nominal_cursor, field))\n", "")),
    "M5 no _phase! on the scratch cursor" =>
        () -> evalsrc(mutate(ESTABLISH_SRC, "    _phase!(nominal_cursor, :round, 1)", "    nothing")),
    "M6 no m copy" =>
        () -> evalsrc(mutate(ESTABLISH_SRC, "        exec.mstores[ci] === nothing || (nominal_exec.mstores[ci][] = exec.mstores[ci][])\n", "")),
    "M7 no clock copy" =>
        () -> evalsrc(mutate(ESTABLISH_SRC, "    _set_origin!(nominal_exec.clock, origin, model.deployment.lattice.unit)\n", "")),
    "M8 no early return without a frozen component" =>
        () -> evalsrc(mutate(ESTABLISH_SRC, "    any(entry -> _frozen(entry.tier, T), build.structure.components) || return nothing\n", "")),
    "M9 root inputs copied without dropping partials" =>
        () -> evalsrc(mutate(ESTABLISH_SRC, "_drop_partials(_port_type(addr), value)", "value")),
    "M10 no s copy" =>
        () -> evalsrc(mutate(ESTABLISH_SRC, "        exec.sstores[ci] === nothing || (nominal_exec.sstores[ci][] = exec.sstores[ci][])\n", "")),
    "M11 nominal round outside the catch" =>
        () -> evalsrc(mutate(INIT_SRC,
            "    try\n        _establish_frozen!(model, origin)   # a non-nominal scalar's frozen cells (D-481)\n",
            "    _establish_frozen!(model, origin)\n    try\n")),
    "M12 no x copy" =>
        () -> evalsrc(mutate(ESTABLISH_SRC, "    nominal_exec.xbuf .= _drop_partials.(exec.xbuf)\n", "")),
    "M13 round with the due set of tick 0, not ESTABLISH" =>
        () -> evalsrc(mutate(ESTABLISH_SRC, "_round!(nominal_exec, ESTABLISH)", "_round!(nominal_exec, 0)")),
    "M14 x copied from the default, partials dropped from establish_defaults" =>
        () -> evalsrc(mutate(ESTABLISH_SRC, "    nominal_exec.xbuf .= _drop_partials.(exec.xbuf)\n",
                             "    nominal_exec.xbuf .= ForwardDiff.value.(exec.xbuf)\n")),
    "M16 no projection in the nominal half" =>
        () -> evalsrc(mutate(ESTABLISH_SRC, "        _projects!(nominal_exec.events, nominal_exec.xbuf)\n", "")),
    "M17 no :project phase on the scratch cursor" =>
        () -> evalsrc(mutate(ESTABLISH_SRC, "        _phase!(nominal_cursor, :project)\n", "")),
    "M18 no stale-cursor reset" =>
        () -> evalsrc(mutate(ESTABLISH_SRC, "    exec.cursor.comp = 0; exec.cursor.fn = :none   # no stale frame for a throw before the round\n", "")),
    "M19 projection after the round" =>
        () -> evalsrc(mutate(ESTABLISH_SRC, "        _projects!(nominal_exec.events, nominal_exec.xbuf)\n        _phase!(nominal_cursor, :round, 1)\n        _round!(nominal_exec, ESTABLISH)",
                             "        _phase!(nominal_cursor, :round, 1)\n        _round!(nominal_exec, ESTABLISH)\n        _projects!(nominal_exec.events, nominal_exec.xbuf)")),
]

function run_sets()
    parent = Test.DefaultTestSet("outer")
    Test.@with_testset parent begin
        @testset Test.DefaultTestSet "probe" begin
            RedstoneTests.discrete_frozen_activation()
            RedstoneTests.discrete_frozen_init()
        end
    end
end

function failed_names(ts, acc = String[])
    for r in ts.results
        if r isa Test.DefaultTestSet
            failed_names(r, acc)
        elseif r isa Test.Fail || r isa Test.Error
            push!(acc, string(ts.description[1:min(end, 60)], " :: ", r isa Test.Fail ? r.orig_expr : "ERROR " * first(split(sprint(show, r.value), '\n'))[1:min(end,120)]))
        end
    end
    acc
end

redirect = get(ENV, "QUIET", "1") == "1"
for (name, apply) in ["baseline" => () -> nothing; MUTANTS]
    restore_all()
    apply()
    ts = try
        redirect_stdout(devnull) do
            redirect_stderr(devnull) do
                Base.ScopedValues.@with Test.TESTSET_PRINT_ENABLE => false run_sets()
            end
        end
    catch err
        err
    end
    if ts isa Test.DefaultTestSet
        names = failed_names(ts)
        println(rpad(name, 70), isempty(names) ? "SURVIVED (all pass)" : "KILLED by $(length(names))")
        foreach(n -> println("    ", n), unique(names))
    else
        println(rpad(name, 70), "run aborted: ", first(split(sprint(showerror, ts), '\n')))
        ts isa Test.TestSetException && foreach(n -> println("    ", n), unique(failed_names(ts)))
    end
end
restore_all()

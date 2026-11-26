# Mutant driver for the hosted-catch increment: load the suite once from the
# worktree, then per mutant re-evaluate one definition's source with one edit,
# run the test files that own the pin, report GREEN or RED, and restore the
# original. `julia --project=test ../hosted_catch_probes/mutants.jl` from the
# worktree root.
const TREE = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/hosted_catch"
include(joinpath(TREE, "test", "RedstoneTests.jl"))
using Test
import Redstone

src(file) = read(joinpath(TREE, "src", file), String)
function cut(file, from, to = "\nend\n")
    s = src(file)
    i = findfirst(from, s)
    i === nothing && error("anchor not found: $from")
    j = findnext(to, s, last(i))
    s[first(i):last(j)]
end
ev(s) = Base.include_string(Redstone, s, "mutant")
function mutate(s, old, new)
    occursin(old, s) || error("mutant anchor not found: $old")
    replace(s, old => new; count = 1)
end

const HOSTED = cut("model.jl", "@inline function _hosted(")
const FROZEN = cut("model.jl", "function _establish_frozen!(model::Model{T}")
const OVERLAY = cut("model.jl", "function overlay!(model::Model, plan::ConditionPlan")
const RESTORE = cut("model.jl", "function _restore_state!(model::Model, model_state")
const FRAME = cut("frame.jl", "function run_frame!(")
const SOLVE = cut("trim.jl", "function _solve_problem(")
const VERDICT = cut("trim.jl", "function _verdict!(")
const LINEARIZE = cut("linearize.jl", "function _linearize(")
const PHASE = cut("diagnostics.jl", "_phase_text(cursor::CursorFrame) =", "string(cursor.phase)\n")
const LINES = cut("diagnostics.jl", "function _host_lines(")
const PRIM = cut("model.jl", "@inline _establishment_round!(model::Model) =", "nothing)\n")
restore_all() = foreach(ev, (HOSTED, FROZEN, OVERLAY, RESTORE, FRAME, SOLVE, VERDICT, LINEARIZE, PHASE, LINES, PRIM))

T = RedstoneTests
const MUTANTS = [
    ("H1 the host writes :built for every host", ["failures"],
     () -> ev(mutate(HOSTED, "host === :loop ? :inconsistent : :built", ":built"))),
    ("H2 no cursor reset in the host", ["failures"],
     () -> ev(mutate(HOSTED, "    cursor.comp = 0; cursor.fn = :none\n", ""))),
    ("H3 no freshness write in the host", ["failures", "lattices", "stepper"],
     () -> ev(mutate(HOSTED, "        model.fresh = false\n", ""))),
    ("F1 init!'s nominal half unhosted", ["discrete"],
     () -> ev(mutate(FROZEN, "    _hosted(nominal, 0, :boundary_zero) do nominal\n", "    let nominal = nominal\n"))),
    ("F2 init!'s nominal half under host :trim", ["discrete"],
     () -> ev(mutate(FROZEN, "_hosted(nominal, 0, :boundary_zero)", "_hosted(nominal, 0, :trim)"))),
    ("F3 init!'s nominal half: bare round, no :round phase", ["discrete"],
     () -> ev(mutate(FROZEN, "_establishment_round!(nominal)", "_round!(nominal, ESTABLISH)"))),
    ("P1 the establishment round writes no :round phase", ["discrete", "trim", "linearize"],
     () -> ev(mutate(PRIM, "_phase!(model.exec.cursor, :round, 1); ", ""))),
    ("T9 trim setup: bare round, no :round phase", ["trim"],
     () -> ev(mutate(SOLVE, "        _establishment_round!(nominal)\n", "        _round!(nominal, ESTABLISH)\n"))),
    ("T10 trim setup: no :evaluation phase before the rhs", ["trim"],
     () -> ev(mutate(SOLVE, "        _phase!(nominal.exec.cursor, :evaluation, 1)   # the derivative, the first evaluation\n", ""))),
    ("N6 linearize about: bare round, no :round phase", ["linearize"],
     () -> ev(mutate(LINEARIZE, "            _establishment_round!(nominal)\n", "            _round!(nominal, ESTABLISH)\n"))),
    ("O1 overlay under host :boundary_zero", ["failures", "lifecycle"],
     () -> ev(mutate(OVERLAY, "model, k, :overlay)", "model, k, :boundary_zero)"))),
    ("R1 restore under host :overlay", ["failures"],
     () -> ev(mutate(RESTORE, "_hosted(model, k, :restore)", "_hosted(model, k, :overlay)"))),
    ("L0 frame under host :overlay", ["failures"],
     () -> ev(mutate(FRAME, "_hosted(model, k - 1, :loop)", "_hosted(model, k - 1, :overlay)"))),
    ("T1 trim setup unhosted", ["trim"],
     () -> ev(mutate(SOLVE, "    _hosted(nominal, 0, :trim) do nominal\n", "    let nominal = nominal\n"))),
    ("T2 trim setup: round outside the stretch", ["trim"],
     () -> ev(mutate(SOLVE, "    _hosted(nominal, 0, :trim) do nominal\n        _establishment_round!(nominal)\n",
                     "    _establishment_round!(nominal)\n    _hosted(nominal, 0, :trim) do nominal\n"))),
    ("T3 trim seeded evaluation unhosted", ["trim"],
     () -> ev(mutate(SOLVE, "_hosted(evaluate!, seeded, 0, :trim)", "evaluate!(seeded)"))),
    ("T4 trim seeded: no :evaluation phase", ["trim"],
     () -> ev(mutate(SOLVE, "    _phase!(seeded_exec.cursor, :evaluation)   # `evaluate!` counts the seeded evaluations from 1\n", ""))),
    ("T5 trim seeded: phase reset per evaluation", ["trim"],
     () -> ev(mutate(SOLVE, "        _hosted(evaluate!, seeded, 0, :trim)",
                     "        _phase!(seeded_exec.cursor, :evaluation)\n        _hosted(evaluate!, seeded, 0, :trim)"))),
    ("T6 trim seeded under host :linearize", ["trim"],
     () -> ev(mutate(SOLVE, "_hosted(evaluate!, seeded, 0, :trim)", "_hosted(evaluate!, seeded, 0, :linearize)"))),
    ("T7 the residuals inside the seeded stretch", ["trim"],
     () -> ev(mutate(SOLVE, "        _hosted(evaluate!, seeded, 0, :trim)\n        raw = problem.residuals(gather_reads(seeded_reader, seeded_exec), decisions)",
                     "        raw = _hosted(m -> (evaluate!(m); problem.residuals(gather_reads(seeded_reader, seeded_exec), decisions)), seeded, 0, :trim)"))),
    ("T8 the guess residuals inside the setup stretch", ["trim"],
     () -> ev(mutate(SOLVE, "        nominal.exec.bodies.rhs()\n    end\n    gathered = gather_reads(reader, nominal_exec)\n    r0 = problem.residuals(gathered, guess)",
                     "        nominal.exec.bodies.rhs()\n        problem.residuals(gather_reads(reader, nominal_exec), guess)\n    end\n    gathered = gather_reads(reader, nominal_exec)\n    r0 = problem.residuals(gathered, guess)"))),
    ("V1 committed-state evaluation unhosted", ["trim"],
     () -> ev(mutate(VERDICT, "    _hosted(model, 0, :trim) do model\n", "    let model = model\n"))),
    ("V2 committed-state evaluation: no :evaluation phase", ["trim"],
     () -> ev(mutate(VERDICT, "        _phase!(model.exec.cursor, :evaluation, 1)\n", ""))),
    ("N1 linearize about round unhosted", ["linearize"],
     () -> ev(mutate(LINEARIZE, "        _hosted(nominal, entry_boundary, :linearize) do nominal\n", "        let nominal = nominal\n"))),
    ("N2 linearize passes unhosted", ["linearize"],
     () -> ev(mutate(LINEARIZE, "_hosted(evaluate!, seeded, entry_boundary, :linearize)", "evaluate!(seeded)"))),
    ("N3 linearize pointer always 0", ["linearize"],
     () -> ev(mutate(LINEARIZE, "_hosted(evaluate!, seeded, entry_boundary, :linearize)", "_hosted(evaluate!, seeded, 0, :linearize)"))),
    ("N4 linearize phase reset per pass", ["linearize"],
     () -> ev(mutate(LINEARIZE, "        _hosted(evaluate!, seeded, entry_boundary, :linearize)",
                     "        _phase!(seeded_exec.cursor, :evaluation)\n        _hosted(evaluate!, seeded, entry_boundary, :linearize)"))),
    ("N5 linearize passes under host :trim", ["linearize"],
     () -> ev(mutate(LINEARIZE, "_hosted(evaluate!, seeded, entry_boundary, :linearize)", "_hosted(evaluate!, seeded, entry_boundary, :trim)"))),
    ("D1 no :evaluation arm in _phase_text", ["failures"],
     () -> ev(mutate(PHASE, "    cursor.phase === :evaluation ? \"evaluation \$(cursor.index)\" : string(cursor.phase)\n", "    string(cursor.phase)\n"))),
    ("D2 no :trim arm in _host_lines", ["failures"],
     () -> ev(mutate(LINES, "    host === :trim ? (", "    host === :no_trim ? ("))),
    ("D3 no :linearize arm in _host_lines", ["failures"],
     () -> ev(mutate(LINES, "    host === :linearize ? (", "    host === :no_linearize ? ("))),
]

const OUT = open(joinpath(@__DIR__, get(ENV, "OUTFILE", "mutants_result.txt")), "w")
function run_files(files)
    red = false
    for f in files
        fn = getfield(T, Symbol("test_", f))
        try
            redirect_stdout(devnull) do
                @testset "m" begin fn() end
            end
        catch
            red = true
        end
    end
    red
end
println(OUT, "baseline: ", run_files(["trim", "linearize", "failures", "discrete"]) ? "RED (bad baseline)" : "green"); flush(OUT)
const ONLY = split(get(ENV, "ONLY", ""), ",", keepempty = false)
for (name, files, apply) in MUTANTS
    isempty(ONLY) || any(o -> startswith(name, o * " "), ONLY) || continue
    verdict = try
        apply()
        Base.invokelatest(run_files, files) ? "RED" : "GREEN (survived)"
    catch err
        "ERROR applying: " * sprint(showerror, err)[1:min(end, 200)]
    end
    restore_all()
    println(OUT, rpad(name, 58), " ", verdict); flush(OUT)
end
close(OUT)

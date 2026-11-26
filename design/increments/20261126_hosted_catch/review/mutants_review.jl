# Mutant driver for the hosted-catch increment: load the suite once from the
# worktree, then per mutant re-evaluate one definition's source with one edit,
# run the test files that own the pin, report GREEN or RED, and restore the
# original. `julia --project=test ../hosted_catch_probes/mutants.jl` from the
# worktree root.
const TREE = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/hosted_catch_review"
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
const INIT = cut("model.jl", "function init!(model::Model{T}, plan::ConditionPlan")
restore_all() = foreach(ev, (HOSTED, FROZEN, OVERLAY, RESTORE, FRAME, SOLVE, VERDICT, LINEARIZE, PHASE, LINES, PRIM, INIT))

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
    ("R01 frame unhosted", ["failures", "lifecycle"],
     () -> ev(mutate(FRAME, "    _hosted(model, k - 1, :loop) do model\n", "    let model = model\n"))),
    ("R02 init! boundary zero unhosted", ["failures", "lifecycle"],
     () -> ev(mutate(INIT, "_hosted(boundary_zero!, model, 0, :boundary_zero)", "boundary_zero!(model)"))),
    ("R03 overlay settling unhosted", ["failures", "lifecycle"],
     () -> ev(mutate(OVERLAY, "_hosted(offtick_boundary!, model, k, :overlay)", "offtick_boundary!(model)"))),
    ("R04 restore unhosted", ["failures", "lifecycle"],
     () -> ev(mutate(RESTORE, "    _hosted(model, k, :restore) do model      # a restore runs no component\n", "    let model = model\n"))),
    ("R05 interrupts bypass the host", ["trim", "linearize", "failures"],
     () -> ev(mutate(HOSTED, "    catch err\n", "    catch err\n        err isa InterruptException && rethrow()\n"))),
    ("R06 interrupts bypass the services' hosts", ["trim", "linearize"],
     () -> ev(mutate(HOSTED, "    catch err\n", "    catch err\n        (host === :trim || host === :linearize) && err isa InterruptException && rethrow()\n"))),
    ("R07 committed-state throw keeps :consistent", ["trim"],
     () -> ev(mutate(VERDICT, "    _hosted(model, 0, :trim) do model\n        _phase!(model.exec.cursor, :evaluation, 1)\n        model.exec.bodies.rhs()\n    end\n",
                     "    try\n    _hosted(model, 0, :trim) do model\n        _phase!(model.exec.cursor, :evaluation, 1)\n        model.exec.bodies.rhs()\n    end\n    catch\n        @atomic model.status = :consistent\n        rethrow()\n    end\n"))),
    ("R08 trim setup hosted on the user's model", ["trim"],
     () -> ev(mutate(SOLVE, "    _hosted(nominal, 0, :trim) do nominal\n", "    _hosted(model, 0, :trim) do _unused\n"))),
    ("R09 trim seeded hosted on the user's model", ["trim"],
     () -> ev(mutate(SOLVE, "_hosted(evaluate!, seeded, 0, :trim)", "_hosted(_ -> evaluate!(seeded), model, 0, :trim)"))),
    ("R10 linearize passes hosted on the user's model", ["linearize"],
     () -> ev(mutate(LINEARIZE, "_hosted(evaluate!, seeded, entry_boundary, :linearize)", "_hosted(_ -> evaluate!(seeded), model, entry_boundary, :linearize)"))),
    ("R11 linearize: no :evaluation phase before the passes", ["linearize"],
     () -> ev(mutate(LINEARIZE, "    _phase!(seeded_exec.cursor, :evaluation)   # `evaluate!` counts the passes from 1\n", ""))),
    ("R12 init!'s nominal half at pointer 1", ["discrete"],
     () -> ev(mutate(FROZEN, "_hosted(nominal, 0, :boundary_zero)", "_hosted(nominal, 1, :boundary_zero)"))),
    ("R13 the host resets the phase on entry", ["trim", "linearize", "failures"],
     () -> ev(mutate(HOSTED, "    cursor.comp = 0; cursor.fn = :none\n", "    cursor.comp = 0; cursor.fn = :none; _phase!(cursor, :drain)\n"))),
    ("R14 committed-state evaluation at pointer 1", ["trim"],
     () -> ev(mutate(VERDICT, "_hosted(model, 0, :trim)", "_hosted(model, 1, :trim)"))),
    ("R15 overlay settles with the ESTABLISH due set", ["failures", "lifecycle", "discrete", "events"],
     () -> ev(mutate(OVERLAY, "_hosted(offtick_boundary!, model, k, :overlay)", "_hosted(boundary_zero!, model, k, :overlay)"))),
    ("R16 restore's settled! outside the stretch", ["failures", "lifecycle"],
     () -> ev(mutate(RESTORE, "        settled!(hooks)               # the restored boundary's snapshot (§11.2, §12.6)\n    end\n", "    end\n    settled!(hooks)\n"))),
    ("R17 committed-state evaluation hosted on a scratch", ["trim"],
     () -> ev(mutate(VERDICT, "    _hosted(model, 0, :trim) do model\n        _phase!(model.exec.cursor, :evaluation, 1)\n        model.exec.bodies.rhs()\n    end\n",
                     "    let scratch = _scratch(model, Float64)\n        _restore_state!(scratch.exec, checkpoint(model))\n        _hosted(scratch, 0, :trim) do scratch\n            _phase!(scratch.exec.cursor, :evaluation, 1)\n            scratch.exec.bodies.rhs()\n        end\n        model.exec.bodies.rhs()\n    end\n"))),
    ("R18 linearize about round pointer from the frame", ["linearize"],
     () -> ev(mutate(LINEARIZE, "        entry_boundary = 0\n", "        entry_boundary = 1\n"))),
    ("R19 trim seeded evaluation counted from 0", ["trim"],
     () -> ev(mutate(SOLVE, "    _phase!(seeded_exec.cursor, :evaluation)   # `evaluate!` counts the seeded evaluations from 1\n",
                     "    _phase!(seeded_exec.cursor, :evaluation, -1)\n"))),
    ("R20 the seeded condition inside the seeded stretch", ["trim"],
     () -> ev(mutate(SOLVE, "        apply!(seeded_exec, seeded_plan, override(baseline, problem.condition(decisions)))\n        _hosted(evaluate!, seeded, 0, :trim)\n",
                     "        _hosted(seeded, 0, :trim) do seeded\n            apply!(seeded_exec, seeded_plan, override(baseline, problem.condition(decisions)))\n            evaluate!(seeded)\n        end\n"))),
    ("R22 the committed residuals inside the committed-state stretch", ["trim"],
     () -> ev(mutate(VERDICT, "        model.exec.bodies.rhs()\n    end\n    gathered = gather_reads(reader, model.exec)\n    committed = NamedTuple{residual_names}(problem.residuals(gathered, solution))\n",
                     "        model.exec.bodies.rhs()\n        problem.residuals(gather_reads(reader, model.exec), solution)\n    end\n    gathered = gather_reads(reader, model.exec)\n    committed = NamedTuple{residual_names}(problem.residuals(gathered, solution))\n"))),
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
println(OUT, "baseline: ", run_files(["trim", "linearize", "failures", "discrete", "lifecycle", "events"]) ? "RED (bad baseline)" : "green"); flush(OUT)
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

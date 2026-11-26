# Mutant driver for the hosted-catch fixes: load the suite once from the fix
# worktree, re-evaluate one definition with one edit, run the owning test files,
# report GREEN or RED, restore. `julia --project=test ../hosted_catch_fix_notes/mutants_fix.jl`
# from the worktree root. The worktree's files are never edited.
const TREE = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/hosted_catch_fix"
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

const SOLVE = cut("trim.jl", "function _solve_problem(")
const VERDICT = cut("trim.jl", "function _verdict!(")
const LINES = cut("diagnostics.jl", "function _host_lines(")
restore_all() = foreach(ev, (SOLVE, VERDICT, LINES))

const EVAL = "    _hosted(evaluate!, nominal, 0, :trim)\n"
T = RedstoneTests
const MUTANTS = [
    ("X1 the seeded apply! inside the seeded stretch", ["trim"],
     () -> ev(mutate(SOLVE, "        apply!(seeded_exec, seeded_plan, override(baseline, problem.condition(decisions)))\n        _hosted(evaluate!, seeded, 0, :trim)\n",
                     "        _hosted(seeded, 0, :trim) do seeded\n            apply!(seeded_exec, seeded_plan, override(baseline, problem.condition(decisions)))\n            evaluate!(seeded)\n        end\n"))),
    ("X2 the committed residuals inside the committed-state stretch", ["trim"],
     () -> ev(mutate(VERDICT, EVAL,
                     "    _hosted(nominal, 0, :trim) do nominal\n        evaluate!(nominal)\n        problem.residuals(gather_reads(reader, nominal.exec), solution)\n    end\n"))),
    ("X3 the committed evaluation hosted on the user's model", ["trim"],
     () -> ev(mutate(VERDICT, EVAL, "    _hosted(_ -> evaluate!(nominal), model, 0, :trim)\n"))),
    ("X4 the committed evaluation unhosted", ["trim"],
     () -> ev(mutate(VERDICT, EVAL, "    evaluate!(nominal)\n"))),
    ("X5 the old shape: rhs on the user's model, hosted there", ["trim"],
     () -> ev(mutate(VERDICT, "    _restore_state!(nominal.exec, checkpoint(model))\n    _phase!(nominal.exec.cursor, :evaluation, 1)\n" * EVAL * "    gathered = gather_reads(reader, nominal.exec)\n",
                     "    _hosted(model, 0, :trim) do model\n        _phase!(model.exec.cursor, :evaluation, 1)\n        model.exec.bodies.rhs()\n    end\n    gathered = gather_reads(reader, model.exec)\n"))),
    ("X6 no restore: the scratch evaluated as the setup left it", ["trim"],
     () -> ev(mutate(VERDICT, "    _restore_state!(nominal.exec, checkpoint(model))\n", ""))),
    ("X7 the reads gathered off the user's model", ["trim"],
     () -> ev(mutate(VERDICT, "    gathered = gather_reads(reader, nominal.exec)\n", "    gathered = gather_reads(reader, model.exec)\n"))),
    ("X8 the committed evaluation at pointer 1", ["trim"],
     () -> ev(mutate(VERDICT, EVAL, "    _hosted(evaluate!, nominal, 1, :trim)\n"))),
    ("X9 the committed evaluation under host :linearize", ["trim"],
     () -> ev(mutate(VERDICT, EVAL, "    _hosted(evaluate!, nominal, 0, :linearize)\n"))),
    ("X10 no phase write before the committed evaluation", ["trim"],
     () -> ev(mutate(VERDICT, "    _phase!(nominal.exec.cursor, :evaluation, 1)\n", ""))),
    ("X11 the committed evaluation counted from 0", ["trim"],
     () -> ev(mutate(VERDICT, "    _phase!(nominal.exec.cursor, :evaluation, 1)\n", "    _phase!(nominal.exec.cursor, :evaluation)\n"))),
    ("X12 the linearize recipe without about and t0", ["failures"],
     () -> ev(mutate(LINES, "\"linearize(sim2, tap_set; about, t0) at the same operating point reproduces it\"",
                     "\"linearize(sim2, tap_set) at the same operating point reproduces it\""))),
    ("X13 the linearize interrupt line without about and t0", ["failures"],
     () -> ev(mutate(LINES, "\"linearize(sim2, tap_set; about, t0) at the same operating point runs it again\"",
                     "\"linearize(sim2, tap_set) at the same operating point runs it again\""))),
]

const OUT = open(joinpath(@__DIR__, get(ENV, "OUTFILE", "mutants_fix_result.txt")), "w")
function run_files(files)
    red = false
    for f in files
        fn = getfield(T, Symbol("test_", f))
        try
            redirect_stdout(devnull) do
                redirect_stderr(devnull) do
                    @testset "m" begin fn() end
                end
            end
        catch
            red = true
        end
    end
    red
end
println(OUT, "baseline: ", run_files(["trim", "failures"]) ? "RED (bad baseline)" : "green"); flush(OUT)
for (name, files, apply) in MUTANTS
    verdict = try
        apply()
        Base.invokelatest(run_files, files) ? "RED" : "GREEN (survived)"
    catch err
        "ERROR applying: " * sprint(showerror, err)[1:min(end, 200)]
    end
    restore_all()
    println(OUT, rpad(name, 64), " ", verdict); flush(OUT)
end
close(OUT)

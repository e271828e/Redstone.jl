# In-process mutants: each one redefines a method of the patched `model.jl` in
# `Redstone`, runs `discrete_frozen_init()`, and restores the original.
const ROOT = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/frozen_init"
include(joinpath(ROOT, "test", "RedstoneTests.jl"))
using Test, Redstone

const SRC = read(joinpath(ROOT, "src", "model.jl"), String)

# The text from `start` to the first line that is exactly `end` after it.
function definition(start)
    a = findfirst(start, SRC)
    b = findnext("\nend\n", SRC, last(a))
    SRC[first(a):first(b) + 3]
end

const ESTABLISH = definition("function _establish_frozen!(model::Model{T}, origin::Rational{Int})")
const DROP = SRC[first(findfirst("_drop_partials(::Type{P}, value)", SRC)):last(findfirst("_drop_partials(leaf) = leaf\n", SRC))]
const INIT = definition("function init!(model::Model{T}, plan::ConditionPlan;")

function mutate(text, old, new)
    occursin(old, text) || error("mutant site not found: $old")
    replace(text, old => new; count = 1)
end

const MUTANTS = [
    "M2 no cursor copy" => (ESTABLISH, ESTABLISH, mutate(ESTABLISH,
        "for field in fieldnames(ExecutionCursor)", "for field in ()")),
    "M3 nominal round outside the try" => (INIT, INIT, mutate(mutate(INIT,
        "        _establish_frozen!(model, origin)   # a non-nominal scalar's frozen cells (D-481)\n", ""),
        "    try\n        boundary_zero!(model)", "    _establish_frozen!(model, origin)\n    try\n        boundary_zero!(model)")),
    "M4 no s copy" => (ESTABLISH, ESTABLISH, mutate(ESTABLISH,
        "exec.sstores[ci] === nothing ||", "true ||")),
    "M5 no m copy" => (ESTABLISH, ESTABLISH, mutate(ESTABLISH,
        "exec.mstores[ci] === nothing ||", "true ||")),
    "M6 no clock" => (ESTABLISH, ESTABLISH, mutate(ESTABLISH,
        "    _set_origin!(nominal_exec.clock, origin, model.deployment.lattice.unit)\n", "")),
    "M7 no root-input copy" => (ESTABLISH, ESTABLISH, mutate(ESTABLISH,
        "for face in build.structure.root_inputs", "for face in ()")),
    "M8 no x copy" => (ESTABLISH, ESTABLISH, mutate(ESTABLISH,
        "    nominal_exec.xbuf .= _drop_partials.(exec.xbuf)\n", "")),
    "M9 one Dual layer dropped" => (DROP, DROP, mutate(DROP,
        "_drop_partials(leaf::ForwardDiff.Dual) = _drop_partials(ForwardDiff.value(leaf))",
        "_drop_partials(leaf::ForwardDiff.Dual) = ForwardDiff.value(leaf)")),
    "M10 no phase on the scratch cursor" => (ESTABLISH, ESTABLISH, mutate(ESTABLISH,
        "    _phase!(nominal_cursor, :round, 1)", "    nothing")),
    "M11 no skip: scratch always built" => (ESTABLISH, ESTABLISH, mutate(ESTABLISH,
        "|| return nothing", "|| nothing")),
]

redefine(text) = Core.eval(Redstone, Meta.parseall(text))

results = Pair{String,Any}[]
for (name, (_, original, mutant)) in MUTANTS
    redefine(mutant)
    counts = try
        ts = @testset "$name" begin
            Base.invokelatest(RedstoneTests.discrete_frozen_init)
        end
        "all pass: SURVIVED"
    catch err
        err isa Test.TestSetException ? "pass $(err.pass) fail $(err.fail) error $(err.error): KILLED" :
            "threw $(typeof(err)): KILLED"
    end
    push!(results, name => counts)
    redefine(original)
end
ts = @testset "restored" begin Base.invokelatest(RedstoneTests.discrete_frozen_init) end
println("\n=== MUTANT RESULTS ===")
foreach(r -> println(rpad(r.first, 40), r.second), results)

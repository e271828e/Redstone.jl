# In-process mutants: each one redefines a method of the patched `model.jl` in
# `Redstone`, runs `discrete_frozen_init()`, and restores the original.
const ROOT = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/frozen_init_land"
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
    "A1 no projection in the nominal half" => (ESTABLISH, ESTABLISH, mutate(ESTABLISH,
        "        _projects!(nominal_exec.events, nominal_exec.xbuf)\n", "")),
    "A1b no :project phase on the scratch cursor" => (ESTABLISH, ESTABLISH, mutate(ESTABLISH,
        "        _phase!(nominal_cursor, :project)\n", "")),
    "A3a nominal half after boundary_zero!" => (INIT, INIT, mutate(INIT,
        "        _establish_frozen!(model, origin)   # a non-nominal scalar's frozen cells (D-481)\n        boundary_zero!(model)\n",
        "        boundary_zero!(model)\n        _establish_frozen!(model, origin)\n")),
    "A3b round with tick 0, not ESTABLISH" => (ESTABLISH, ESTABLISH, mutate(ESTABLISH,
        "_round!(nominal_exec, ESTABLISH)", "_round!(nominal_exec, 0)")),
    "M1 no establishing call" => (INIT, INIT, mutate(INIT,
        "        _establish_frozen!(model, origin)   # a non-nominal scalar's frozen cells (D-481)\n", "")),
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

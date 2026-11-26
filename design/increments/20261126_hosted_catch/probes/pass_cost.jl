# The per-pass cost of hosting `linearize`'s evaluation, by form, in a
# context where the seeded scratch's type is not inferred, as in `_linearize`.
const TREE = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/hosted_catch"
module PassCost
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test
include(joinpath(Main.TREE, "test", "imports.jl"))
include(joinpath(Main.TREE, "test", "fixtures.jl"))
include(joinpath(Main.TREE, "test", "utils.jl"))
import Redstone: LinearizeDual, _scratch, _phase!, _hosted, _wrap_step
model = Model(Deployment(build(fed(Pendulum(), :u); activations = (LinearizeDual,)); Δt_frame = 1//10))
init!(model, set(u = (in = 0.3,)))

function bare(model, n)
    seeded = _scratch(model, Base.inferencebarrier(LinearizeDual))
    seeded_exec = seeded.exec
    a = @allocated for _ in 1:n; evaluate!(seeded_exec); end
    a
end
function closure(model, n)
    seeded = _scratch(model, Base.inferencebarrier(LinearizeDual))
    seeded_exec = seeded.exec
    entry_boundary = 0
    a = @allocated for _ in 1:n; _hosted(() -> evaluate!(seeded_exec), seeded, entry_boundary, :linearize); end
    a
end
function inline(model, n)
    seeded = _scratch(model, Base.inferencebarrier(LinearizeDual))
    seeded_exec = seeded.exec
    entry_boundary = 0
    a = @allocated for _ in 1:n
        try
            evaluate!(seeded_exec)
        catch err
            seeded.fresh = false
            @atomic :release seeded.status = :built
            rethrow(_wrap_step(seeded, entry_boundary, :linearize, err))
        end
    end
    a
end
@inline function hosted_by_model(f, model, entry_boundary::Int, host::Symbol)
    cursor = model.exec.cursor
    cursor.comp = 0; cursor.fn = :none
    try
        f(model)
    catch err
        model.fresh = false
        @atomic :release model.status = host === :loop ? :inconsistent : :built
        rethrow(_wrap_step(model, entry_boundary, host, err))
    end
end
function by_model(model, n)
    seeded = _scratch(model, Base.inferencebarrier(LinearizeDual))
    entry_boundary = 0
    a = @allocated for _ in 1:n; hosted_by_model(evaluate!, seeded, entry_boundary, :linearize); end
    a
end
for f in (bare, closure, inline, by_model)
    f(model, 3); f(model, 3)
    println(rpad(string(f), 10), " 1 pass: ", f(model, 1), " B, 10 passes: ", f(model, 10), " B")
end
end

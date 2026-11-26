const TREE = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/hosted_catch_fix"
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test
include(joinpath(TREE, "test", "imports.jl"))
include(joinpath(TREE, "test", "fixtures.jl"))
include(joinpath(TREE, "test", "utils.jl"))
import Redstone: LinearizeDual, _scratch, _restore_state!
pend = Model(Deployment(build(fed(Pendulum(), :u); activations = (LinearizeDual,)); Δt_frame = 1//10))
init!(pend, set(u = (in = 0.0,)))
s = _scratch(pend, Float64)
f() = _restore_state!(s.exec, checkpoint(pend))
g() = checkpoint(pend)
f(); g(); f(); g()
println("checkpoint ", @allocated(g()), " B; checkpoint+restore ", @allocated(f()), " B")
h() = _scratch(pend, Float64)
h(); h()
println("a fresh Float64 scratch ", @allocated(h()), " B")

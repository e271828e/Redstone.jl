# Shared setup: the framework, the suite's import list and fixtures, in Main.
const TREE = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/frozen_init_review"
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test
include(joinpath(TREE, "test", "imports.jl"))
include(joinpath(TREE, "test", "fixtures.jl"))
include(joinpath(TREE, "test", "utils.jl"))
const NESTED = ForwardDiff.Dual{Nothing,ForwardDiff.Dual{Nothing,Float64,1},1}

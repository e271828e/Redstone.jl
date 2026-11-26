const TREE = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/hosted_catch"
include(joinpath(TREE, "test", "RedstoneTests.jl"))
using Test; import Redstone
println(pathof(Redstone))
s = read(joinpath(TREE, "src", "frame.jl"), String)
i = findfirst("function run_frame!(", s); j = findnext("\nend\n", s, last(i))
src = replace(s[first(i):last(j)], "_hosted(model, k - 1, :loop)" => "_hosted(model, k - 1, :overlay)")
Base.include_string(Redstone, src, "mutant")
r = @testset "m" begin RedstoneTests.test_failures() end
println(typeof(r))

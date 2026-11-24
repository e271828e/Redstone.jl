# S9a probe 4: UnknownPort candidate list for a destination typo
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff
include("/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/imports.jl")
include("/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/fixtures.jl")
g = Group((a = Gain(1.0), h = Gain(2.0)); local_wires = ("a/out" => "h/ee",), input_wires = ("r" => "a/e"))
try build(g) catch e
    for d in e.carried
        println("probe:U ", typeof(d), d isa Redstone.UnknownPort ? (d.endpoint, d.port, d.candidates) : "")
    end
end

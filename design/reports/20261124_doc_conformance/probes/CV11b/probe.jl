using Redstone, Test
include("/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/imports.jl")
import Redstone: Simulation, attach!, AbstractDevice, AbstractBinding, is_input, is_output, is_greedy, claims, reads,
    loop, Group, DiagnosticError, BindingContractMismatch, DeviceContractMismatch, AttachUnknownFace, ClaimConflict,
    ModelState, Checkpoint, Control, Pacer, Model, checkpoint
import Redstone: diagnostics
W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/"
# minimal fixture include: only Plant/Sum/Gain definitions are needed
module F
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
include("/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/imports.jl")
include("/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/fixtures.jl")
end
using .F
mutable struct Pad <: AbstractDevice; n::String; end
loop(::Pad, h) = nothing
struct Enum <: AbstractBinding; f::Vector{String}; end
is_input(::Enum) = true; claims(b::Enum) = b.f
struct Gr <: AbstractBinding end
is_input(::Gr) = true; is_greedy(::Gr) = true
struct NoLoop <: AbstractDevice end
struct Out <: AbstractBinding end
is_output(::Out) = true
reads(::Out) = (; v = 1)
mk() = Simulation(Group((; s = F.Sum(sa = 1.0, sb = 1.0)); input_wires = ("a" => "s/a", "b" => "s/b")); Δt_frame = 1//10)
sim = mk()
println("probe:30 duplicate collapse: ", (attach!(sim, Pad("a"), Enum(["a","a"])); length(sim.plane.roster[1].handle.writer.faces)))
println("probe:31 nolog device: ", try attach!(sim, NoLoop(), Enum(String[])); catch e; first(split(sprint(showerror, e), "\n")) end)
println("probe:32 greedy remainder: ", (h = attach!(sim, Pad("g"), Gr()); h.writer.faces))
println("probe:33 second greedy: ", (h = attach!(sim, Pad("g2"), Gr()); h.writer.faces))
println("probe:34 harness faces: ", sim.plane.harness.faces, " next_id ", sim.plane.next_id)
println("probe:35 unknown face: ", try attach!(sim, Pad("x"), Enum(["zz"])); catch e; first(split(sprint(showerror, e), "\n")) end)
println("probe:36 out reads not NT: ", try attach!(sim, Pad("o"), Out()); catch e; first(split(sprint(showerror, e), "\n")) end)
println("probe:37 id after rejects: ", sim.plane.next_id)
# checkpoint
m = Model(Group((; s = F.Sum(sa = 1.0, sb = 1.0)); input_wires = ("a" => "s/a", "b" => "s/b")); Δt_frame = 1//10)
println("probe:40 methods: ", methods(Redstone.checkpoint))
println("probe:41 defaults: ", Control(5.0).pace, " ", Control(5.0).margin, " ", Control(5.0).stopped, " ", Control(5.0).paused, " ", Control(5.0).running)
println("probe:42 Pacer(): ", Pacer())
println("probe:43 sim control: ", sim.control.pace, " ", sim.control.join_timeout)
println("probe:44 reads kw: ", typeof(reads(; v = 1)))

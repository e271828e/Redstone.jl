# p14: runs one copy of the longitudinal testset as runtests.jl does, under the same imports.
# julia --startup-file=no --project=examples/test ../tutorial_1b_probes/run_file.jl <path>
using Test, LinearAlgebra, BenchmarkTools
using Statistics: std, cor
using Redstone, RedstoneExamples
import Redstone: Build, ProbeDual, Simulation, build, init!, run!, step!, stage!, trim!, linearize, state, modes,
    series, reads, get_output, get_face, get_input, get_state, taps, termination, lifecycle, phase_bodies, set, at, combine,
    override, checkpoint, restore!, replay!, trace, local_wires, input_wires, output_wires, diagnostics,
    DiagnosticError, TapResolution, AlgebraicCycle, EndTimeReached, ModelRequestedStop, Group
include(joinpath(@__DIR__, "..", "tutorial_1b", "examples", "test", "utils.jl"))
include(abspath(ARGS[1]))

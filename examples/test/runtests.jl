# The examples' tests: one file per example, `test_<example>.jl`, each a testset pinning
# what its companion claims over the helpers of `utils.jl`. Models and helpers live at top
# level, for `code_rules.md`'s local-scope reason. With no arguments every file runs;
# with names, `longitudinal`, only those.

using Test, LinearAlgebra, BenchmarkTools
using Statistics: std
using Redstone, RedstoneExamples
import Redstone: Build, ProbeDual, Simulation, build, init!, run!, step!, stage!, trim!, linearize, state, modes,
    series, reads, get_output, get_face, get_input, get_state, taps, termination, lifecycle, phase_bodies, set, at, combine,
    override, condition, checkpoint, restore!, replay!, trace, local_wires, input_wires, output_wires, diagnostics,
    DiagnosticError, TapResolution, AlgebraicCycle, EndTimeReached, ModelRequestedStop
import Redstone.Library: Group

include("utils.jl")

const EXAMPLES = ("longitudinal",)
for name in (isempty(ARGS) ? EXAMPLES : ARGS)
    include("test_$name.jl")
end

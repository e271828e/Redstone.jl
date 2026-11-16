# Shared: load the frozen prototype, define the probe candidates against the seam.
using Test
include(joinpath(ENV["WT"], "test/repl.jl"))
import Redstone: BS3, BS3Stepper, proposes, StepFloor, arrival_derivative, _seconds, _stage_point!
include(joinpath(ENV["WT"], "test/utils.jl"))

include(joinpath(@__DIR__, "candidates.jl"))

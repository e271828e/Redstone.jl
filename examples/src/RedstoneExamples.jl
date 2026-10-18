"""
    RedstoneExamples

The examples of Redstone, one file per example, each a model with the plain
functions a tutorial walks through and a testset that pins it. The package
reaches `Redstone` through its public surface alone, as a user's package does.
It exports nothing, as `Redstone` does (D-226), so its names are reached by
qualified name or by per-name `import`.
"""
module RedstoneExamples

using Redstone
import Redstone: AbstractComponent, StateEvent, x_init, m_init, u_types, y_types, y_state, x_deriv,
    state_events, condition, set, at, combine, TrimProblem, reads, get_state, get_deriv,
    get_input, get_output, taps, Absolute, Hz
import Redstone.Blocks: Group, Constant, Source, Step, StopRequest, GaussianWhiteNoise, SumJunction,
    Junction, Pack, Unpack, Switch, UnitDelay, RateLimiter, FirstOrderLag, DiscretePID, DiscreteLQRTracker
using StaticArrays: SMatrix, SVector
using LinearAlgebra: Diagonal
using ControlSystemsBase: lqr, Continuous

include("longitudinal.jl")

end # module RedstoneExamples

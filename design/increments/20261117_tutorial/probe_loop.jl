# Probe 1: does the closed loop build when the controllers track the selected
# command directly, without the unit delays?
# Probe 2: can the closed loop be linearized from `h_ref` to the altitude?
using Redstone, RedstoneExamples
import Redstone: build, Simulation, init!, trim!, linearize, set, taps, get_state, get_input, get_output
import RedstoneExamples: aircraft, level_flight, longitudinal_taps, lqr_gains, closed_loop, trimmed

sim = Simulation(aircraft(); Δt_frame = 1//100)
report = trim!(sim, level_flight(); baseline = set(u = (δe = 0.0, δt = 0.5)))
solution = report.solution
gains = lqr_gains(linearize(sim, longitudinal_taps()))

println("=== baseline closed loop ===")
println(typeof(build(closed_loop(solution, gains))))

# The variant: the same source, the tracking inputs wired from the selected
# commands themselves.
source = read(joinpath(pkgdir(RedstoneExamples), "src", "longitudinal.jl"), String)
variant = replace(source, "\"selection/δe_prev\" =>" => "\"selection/δe\" =>",
                          "\"selection/δt_prev\" =>" => "\"selection/δt\" =>")
@assert variant != source
module Variant
    using Redstone
    import Redstone: AbstractComponent, StateEvent, x_init, m_init, u_types, y_types, y_state, x_deriv,
        state_events, condition, set, at, combine, TrimProblem, reads, get_state, get_deriv,
        get_input, get_output, taps, Absolute, Hz
    import Redstone.Library: Group, Constant, Source, Step, StopRequest, GaussianWhiteNoise, SumJunction,
        Junction, Pack, Unpack, Switch, UnitDelay, RateLimiter, FirstOrderLag, DiscretePID, DiscreteLQRTracker
    using StaticArrays: SMatrix, SVector
    using LinearAlgebra: Diagonal
    using ControlSystemsBase: lqr, Continuous
end
Base.include_string(Variant, variant)

println("=== variant without the delays ===")
try
    println(typeof(build(Variant.closed_loop(solution, gains))))
catch err
    showerror(stdout, err); println()
end

println("=== linearize the closed loop from h_ref to h ===")
loop = Simulation(closed_loop(solution, gains); Δt_frame = 1//200)
init!(loop, trimmed(solution))
try
    lin = linearize(loop, taps(x = (h = get_state("plant", :h),),
                               u = (h_ref = get_input(:h_ref),),
                               y = (h = get_output("plant", :h),)))
    display(lin.B); println()
catch err
    showerror(stdout, err); println()
end

# Probe: a pitch-attitude loop closed with the continuous `PID`, linearized
# from its reference, then the same loop with `DiscretePID` at 50 Hz, both
# flown through a step in the reference.
using Redstone, RedstoneExamples, LinearAlgebra
import Redstone: Simulation, init!, run!, step!, stage!, trim!, linearize, set, at, combine, taps, reads,
    get_state, get_input, get_output, series, Absolute, Hz
import Redstone.Library: Group, PID, DiscretePID
import RedstoneExamples: Longitudinal, aircraft, level_flight, condition

sim = Simulation(aircraft(); Δt_frame = 1//100)
solution = trim!(sim, level_flight(); baseline = set(u = (δe = 0.0, δt = 0.5))).solution

pitch_hold(controller; rates...) = Group((; plant = Longitudinal(), θ_ctl = controller);
    input_wires = ("θ_ref" => "θ_ctl/r", "δt" => "plant/δt"),
    local_wires = ("plant/θ" => "θ_ctl/y", "θ_ctl/u" => "plant/δe"),
    (isempty(rates) ? (;) : (; sample_times = (; rates...)))...)

at_trim(store) = combine(set(u = (θ_ref = solution.θ, δt = solution.δt)),
                         at("plant", condition(Longitudinal(); θ = solution.θ)),
                         at("θ_ctl", store))

println("=== continuous loop, linearized from θ_ref to θ ===")
continuous = Simulation(pitch_hold(PID(Kp = -2.0, Ki = -1.0)); Δt_frame = 1//200)
init!(continuous, at_trim(set(x = (q = solution.δe,))))
try
    lin = linearize(continuous, taps(
        x = (V = get_state("plant", :V), γ = get_state("plant", :γ), θ = get_state("plant", :θ),
             q = get_state("plant", :q), ξ = get_state("θ_ctl", :q)),
        u = (θ_ref = get_input(:θ_ref),),
        y = (θ = get_output("plant", :θ),)))
    println("eigenvalues: ", round.(eigvals(lin.A); digits = 3))
    println("B: ", round.(vec(lin.B); digits = 3))
    println("dc gain θ_ref → θ: ", round((lin.D - lin.C * (lin.A \ lin.B))[1]; digits = 6))
catch err
    showerror(stdout, err); println()
end

function fly(sim, store)
    init!(sim, at_trim(store))
    step!(sim; frames = 199)
    stage!(sim, "θ_ref" => solution.θ + 0.05)
    run!(sim; t_end = 10.0)
    series(sim, reads(θ = get_output("plant", :θ)))
end

println("=== the step in θ_ref, continuous against discrete at 50 Hz ===")
try
    a = fly(continuous, set(x = (q = solution.δe,)))
    discrete = Simulation(pitch_hold(DiscretePID(Kp = -2.0, Ki = -1.0); θ_ctl = Absolute(Hz(50))); Δt_frame = 1//200)
    b = fly(discrete, set(s = (q = solution.δe,)))
    println("snapshots: ", length(a.t), " and ", length(b.t))
    println("θ at 10 s: ", a.columns.θ[end], " and ", b.columns.θ[end], ", reference ", solution.θ + 0.05)
    println("peaks: ", maximum(a.columns.θ), " and ", maximum(b.columns.θ))
    println("largest gap: ", maximum(abs, a.columns.θ .- b.columns.θ))
catch err
    showerror(stdout, err); println()
end

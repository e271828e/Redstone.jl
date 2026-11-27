# Shared setup of the increment 1b probes. Run a probe from the worktree's root as
#   julia --startup-file=no --project=examples/test ../tutorial_1b_probes/<probe>.jl
# Each probe includes this file. A candidate rate set is a change of the module's constant
# (`set_multipliers!`) and of the deployment's `Δt_base`; the cascade's and the selection's
# knobs are probe copies of the two functions, evaluated into the module, so a probe can vary
# gains, `Tt`, limits and the delays' entries without editing the source.

using Test, LinearAlgebra, Printf
using Statistics: std, mean
using Redstone, RedstoneExamples
import Redstone: Build, ProbeDual, Simulation, build, init!, run!, step!, stage!, trim!, linearize, state, modes,
    series, reads, get_output, get_face, get_input, get_state, taps, termination, lifecycle, phase_bodies, set, at, combine,
    override, checkpoint, restore!, replay!, trace, local_wires, input_wires, output_wires, diagnostics,
    DiagnosticError, TapResolution, AlgebraicCycle, EndTimeReached, ModelRequestedStop, Group, Relative, Absolute

const WT = joinpath(@__DIR__, "..", "tutorial_1b")
include(joinpath(WT, "examples", "test", "utils.jl"))
const RE = RedstoneExamples
import RedstoneExamples: Longitudinal, aircraft, level_flight, autopilot, cruise, piloted, hand_flown, approach

# Unreliable (p06_debug): use the knob `m` of knobs.jl instead.
set_multipliers!(m) = (Core.eval(RE, :(const sensor_multipliers = $m)); nothing)

function trim_solution()
    sim = Simulation(aircraft(); Δt_frame = 1//100)
    trim!(sim, level_flight(); baseline = set(u = (δe = 0.0, δt = 0.5))).solution
end

# The `hold = false` variant has no `engaged` input; `autopilot` wires one, so the probe of the
# limited time uses its own root (below).

const QUIET = (q = 0.0, θ = 0.0, h = 0.0, V = 0.0)

frame_index(t) = round(Int, t * 200)
change_times(sim, signal) = logged_times(sim)[2:end][diff(signal) .!= 0]
on_grid(t, hz) = isapprox(hz * t, round(hz * t); atol = 1e-6)

function fly_autopilot(solution; Δt_base, h_step = 50.0, noise_psd = RE.sensor_noise_psd, t_end = 120.0)
    sim = Simulation(autopilot(solution; noise_psd); Δt_frame = 1//200, Δt_base)
    init!(sim, override(cruise(solution), set(u = (h_ref = 1000.0 + h_step,))))
    run!(sim; t_end)
    sim
end

# The autopilot without the hold axis, for the limited-time figure: no `engaged` wire.
function autopilot_free(solution; noise_psd = RE.sensor_noise_psd)
    Group((; plant = Longitudinal(), sensing = RE.sensing(; noise_psd), cascade = RE.cascade(),
             actuators = RE.actuators(solution));
          input_wires = ("h_ref" => "cascade/h_ref", "V_ref" => "cascade/V_ref"),
          local_wires = (RE.feedback_wires()...,
                         "cascade/δe" => "actuators/δe_cmd", "cascade/δt" => "actuators/δt_cmd"))
end

function figures5(sim)
    t = logged_times(sim)
    h = logged_port(sim, "plant", :h)
    V = logged_port(sim, "plant", :V)
    late = t .>= 75
    i_V = argmax(abs.(V .- 50))
    last_out = findlast(x -> abs(x - 1050) > 1, h)
    (late_h = maximum(abs, h[late] .- 1050), late_V = maximum(abs, V[late] .- 50), peak = maximum(h),
     V_exc = abs(V[i_V] - 50), t_V_exc = t[i_V], within_1m = t[last_out + 1])
end

# The time the attitude loop's command sits on a limit.
limited_time(sim, lim) = count(u -> abs(u) >= lim - 1e-12, logged_port(sim, "cascade/θ_ctl", :u)) / 200

function fly_by_hand!(sim, solution; until = 60.0, engage = true, offset = 0)
    step!(sim; frames = frame_index(5.0) + offset)
    stage!(sim, "δe_pilot" => solution.δe - 0.02)
    step!(sim; frames = frame_index(7.0) - frame_index(5.0))
    stage!(sim, "δe_pilot" => solution.δe)
    step!(sim; frames = frame_index(30.0) - frame_index(7.0))
    engage && stage!(sim, "engage" => true)
    step!(sim; frames = frame_index(until) - frame_index(30.0) - offset)
end

function fly_piloted(solution; Δt_base, noise_psd = RE.sensor_noise_psd, offset = 0)
    hand = Simulation(piloted(solution; noise_psd); Δt_frame = 1//200, Δt_base)
    init!(hand, hand_flown(solution))
    fly_by_hand!(hand, solution; offset)
    run!(hand; t_end = 90.0)
    hand
end

function figures6(hand)
    t = logged_times(hand)
    δe_sel, δt_sel = logged_face(hand, "selection", :δe), logged_face(hand, "selection", :δt)
    switch = findfirst(identity, logged_face(hand, "selection", :engaged))
    (gap_δe = largest_gap(logged_face(hand, "cascade", :δe), δe_sel, hand, 8, 30),
     gap_δt = largest_gap(logged_face(hand, "cascade", :δt), δt_sel, hand, 5, 30),
     gap_hθ = largest_gap(logged_port(hand, "cascade/h_ctl", :u), logged_port(hand, "plant", :θ), hand, 8, 30),
     gap_θq = largest_gap(logged_port(hand, "cascade/θ_ctl", :u), logged_port(hand, "plant", :q), hand, 8, 30),
     gap_hθm = largest_gap(logged_port(hand, "cascade/h_ctl", :u), logged_face(hand, "sensing", :θ_meas), hand, 8, 30),
     gap_θqm = largest_gap(logged_port(hand, "cascade/θ_ctl", :u), logged_face(hand, "sensing", :q_meas), hand, 8, 30),
     t_latch = t[switch],
     jump_δe = abs(δe_sel[switch] - δe_sel[switch - 1]), jump_δt = abs(δt_sel[switch] - δt_sel[switch - 1]),
     jump_act = abs(logged_face(hand, "actuators", :δe)[switch + 1] - logged_face(hand, "actuators", :δe)[switch]),
     jitter = largest_jump(δe_sel, hand, 80, 90),
     recapture = maximum(abs, logged_port(hand, "plant", :h)[window(hand, 80, 90)] .- 1000),
     h_max = maximum(logged_port(hand, "plant", :h)[window(hand, 0, 30)]),
     h_min = minimum(logged_port(hand, "plant", :h)[window(hand, 0, 30)]))
end

function descend!(sim; sink_rate = 1.5, period = 1//10)
    h_ref = 1000.0
    n_writes = 0
    while lifecycle(sim) !== :stopped && n_writes < 20_000
        h_ref -= sink_rate * period
        stage!(sim, "h_ref" => h_ref)
        step!(sim; t_plus = period)
        n_writes += 1
    end
    n_writes
end

function fly_approach(solution; Δt_base, noise_psd = RE.sensor_noise_psd, period = 1//10)
    flight = Simulation(approach(solution; noise_psd); Δt_frame = 1//200, Δt_base)
    init!(flight, at("vehicle", hand_flown(solution)))
    fly_by_hand!(flight, solution)
    top = checkpoint(flight)
    n = descend!(flight; period)
    (flight, top, n)
end

function figures7(flight)
    record = termination(flight)
    h_refs = series(flight, reads(h_ref = get_input("h_ref"))).h_ref
    descending = window(flight, 160, record.t - 1)
    V = logged_port(flight, "vehicle/plant", :V)[descending]
    (t_stop = record.t, tracking = maximum(abs, (logged_port(flight, "vehicle/plant", :h) .- h_refs)[descending]),
     V_lo = minimum(V), V_hi = maximum(V), γ_stop = state(flight, "vehicle/plant").γ,
     limited = any(u -> abs(u) >= 0.5 - 1e-12, logged_port(flight, "vehicle/cascade/θ_ctl", :u)[window(flight, 60, record.t)]))
end

fmt(nt) = join(("$k=" * (v isa AbstractFloat ? @sprintf("%.6g", v) : string(v)) for (k, v) in pairs(nt)), "  ")

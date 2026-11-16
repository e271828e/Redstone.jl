# Shared for the examples' models (run with --project=examples/test).
using Test, LinearAlgebra, Printf
using Redstone, RedstoneExamples
import Redstone: AbstractAlgorithm, AbstractStepper, Model, BS3, BS3Stepper, proposes, bind_stepper, propose,
    checkpoint_stepper, restore_stepper!, reset_stepper!, discontinuity!, startpoint, arrival_derivative,
    attempt!, evaluate!, _seconds, _stage_point!, latest, logged, Simulation, init!, run!, step!, stage!, trim!,
    linearize, state, modes, series, reads, get_output, termination, set, at, combine, override, condition,
    RK4, AbstractComponent
import RedstoneExamples: Longitudinal, aircraft, level_flight, longitudinal_taps, lqr_gains, closed_loop,
    trimmed, descent
include(joinpath(@__DIR__, "candidates.jl"))
writer_status(snapshot, who::String) = only(w for w in snapshot.status.writers if w.who == who)
floor_total(sim) = writer_status(latest(sim), "loop").totals.step_floor

function trim_solution()
    sim = Simulation(aircraft(); Δt_frame = 1 // 100)
    report = trim!(sim, level_flight(); baseline = set(u = (δe = 0.0, δt = 0.5)))
    solution = report.solution
    (solution, lqr_gains(linearize(sim, longitudinal_taps())))
end

plant_series(sim) = (s = series(sim, reads(V = get_output("plant", :V), γ = get_output("plant", :γ),
                                           θ = get_output("plant", :θ), q = get_output("plant", :q),
                                           h = get_output("plant", :h)));
                     (s.t, hcat(s.columns.V, s.columns.γ, s.columns.θ, s.columns.q, s.columns.h)))
# error per snapshot: max over (V, γ, θ, q, h) of |Δ| / max(1, |ref|)
snap_errors(X, R) = [maximum(abs.(X[i, :] .- R[i, :]) ./ max.(1.0, abs.(R[i, :]))) for i in axes(X, 1)]
alg_counts(sim) = (st = sim.model.exec.stepper; st isa AbstractStepper && hasproperty(st, :c) ? st.c : nothing)

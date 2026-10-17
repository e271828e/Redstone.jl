# The examples' testset: one testset per example, each pinning what its
# companion claims. The pins are probed values, `longitudinal_aircraft.md`'s for
# the aircraft. Models and helpers live at top level, for `implementation.md`'s
# local-scope reason.

using Test, LinearAlgebra, BenchmarkTools
using Statistics: std
using Redstone, RedstoneExamples
import Redstone: Build, ProbeDual, Simulation, build, init!, run!, trim!, linearize, state, modes, port,
    logged, termination, phase_bodies, fragment, at, combine, condition, EndTimeReached, ModelRequestedStop
import RedstoneExamples: Longitudinal, aircraft, level_flight, longitudinal_taps, lqr_gains, closed_loop,
    trimmed, descent

# --- the longitudinal aircraft ----------------------------------------------------

# The aircraft trimmed at level flight, the simulation left at the commit.
function trimmed_aircraft()
    sim = Simulation(aircraft(); h = 1//100)
    report = trim!(sim, level_flight(); baseline = fragment(u = (δe = 0.0, δt = 0.5)))
    (sim, report)
end

# The aircraft's state from `plant_state` at the trim controls, or at the throttle `δt`.
at_trim(solution, plant_state; δt = solution.δt) =
    combine(at("plant", plant_state), fragment(u = (δe = solution.δe, δt = δt)))

# A port's value over the logged snapshots, beside their times.
logged_times(sim) = [snapshot.t for snapshot in logged(sim)]
logged_port(sim, path, name) = [port(snapshot, path, name) for snapshot in logged(sim)]

# The times at which `values` crosses `level`, at the snapshot after each crossing.
crossings(times, values, level) =
    [times[i] for i in 2:length(times) if (values[i - 1] - level) * (values[i] - level) < 0]

# The snapshots of `sim` in `[t_from, t_to)`, as a mask.
window(sim, t_from, t_to) = (times = logged_times(sim); (times .>= t_from) .& (times .< t_to))

# The largest frame-to-frame change of a port over the snapshots in `[t_from, t_to)`.
largest_jump(sim, path, name, t_from, t_to) =
    maximum(abs, diff(logged_port(sim, path, name)[window(sim, t_from, t_to)]))

# The largest gap between the ports `follower` and `leader`, each a `(path, name)` pair,
# over the snapshots in `[t_from, t_to)`.
function largest_gap(sim, follower, leader, t_from, t_to)
    gaps = logged_port(sim, follower...) .- logged_port(sim, leader...)
    maximum(abs, gaps[window(sim, t_from, t_to)])
end

# The closed loop flown from the trim at the deployment's step.
function fly_closed_loop(solution, gains; cascade, h_step = 50.0, noise_σ = 0.3, t_end = 120.0)
    sim = Simulation(closed_loop(solution, gains; cascade, h_step, noise_σ); h = 1//200)
    init!(sim, trimmed(solution))
    run!(sim; t_end)
    sim
end

@testset "Longitudinal" begin
    sim, report = trimmed_aircraft()
    solution = report.solution
    linearization = linearize(sim, longitudinal_taps())
    gains = lqr_gains(linearization)

    @testset "the aircraft, the closed loop and the descent build under both activations (§9.4)" begin
        for model in (aircraft(), closed_loop(solution, gains), descent())
            @test build(model; activations = (Float64, ProbeDual)) isa Build
        end
    end

    @testset "level flight trims in four iterations to the pinned point (§14.7, §14.8)" begin
        @test report.status == :converged
        @test report.n_iterations == 4
        @test solution.θ ≈ 0.019930198715528237 atol = 1e-6
        @test solution.δe ≈ 0.025058167737049112 atol = 1e-6
        @test solution.δt ≈ 0.37233719527321874 atol = 1e-6
        @test all(residual -> abs(residual) < 1e-9, report.residuals)
        plant_state = state(sim, "plant")
        @test plant_state.V == 50.0
        @test plant_state.γ == 0.0
        @test plant_state.q == 0.0
        @test plant_state.h == 1000.0
        @test plant_state.θ == solution.θ
    end

    @testset "the linearization at the trim has the short period, the phugoid and a pure integrator (§14.10)" begin
        @test linearization.x_labels == (:V, :γ, :θ, :q, :h)
        @test linearization.u_labels == (:δe, :δt)
        λs = eigvals(linearization.A)
        upper = filter(λ -> imag(λ) > 0, λs)
        @test length(upper) == 2
        short_period = upper[argmax(imag.(upper))]
        phugoid = upper[argmin(imag.(upper))]
        @test abs(short_period) ≈ 5.432560858623229 atol = 1e-3
        @test -real(short_period) / abs(short_period) ≈ 0.5660263823274105 atol = 1e-3
        @test abs(phugoid) ≈ 0.2305636330420722 atol = 1e-3
        @test -real(phugoid) / abs(phugoid) ≈ 0.06699657662280878 atol = 1e-3
        @test count(λ -> abs(λ) < 1e-9, λs) == 1
    end

    @testset "the open loop from 55 m/s crosses the trim airspeed every half phugoid period (§10.2)" begin
        open_loop = Simulation(aircraft(); h = 1//100)
        init!(open_loop, at_trim(solution, condition(Longitudinal(); V = 55.0, θ = solution.θ)))
        run!(open_loop; t_end = 120.0)
        times = logged_times(open_loop)
        Vs = logged_port(open_loop, "plant", :V)
        @test length(times) == 12001
        @test minimum(Vs) < 47
        # The probe's crossings: 6.62, 20.12, 33.9, 47.45, 61.19, 74.78.
        first_six = crossings(times, Vs, 50.0)[1:6]
        @test isapprox((first_six[6] - first_six[1]) / 5, π / 0.23005; rtol = 0.01)
    end

    @testset "the closed loop rests at the trim under either controller (§14.5)" begin
        for cascade in (t -> true, t -> false)
            resting = fly_closed_loop(solution, gains; cascade, h_step = 0.0, noise_σ = 0.0, t_end = 60.0)
            # The probe's largest drift: 2.6e-10 m, 3.8e-11 m/s and 3.7e-12 rad.
            @test all(h -> abs(h - 1000) <= 1e-6, logged_port(resting, "plant", :h))
            @test all(V -> abs(V - 50) <= 1e-6, logged_port(resting, "plant", :V))
            @test all(θ -> abs(θ - solution.θ) <= 1e-6, logged_port(resting, "plant", :θ))
        end
    end

    runs = (cascade = fly_closed_loop(solution, gains; cascade = t -> true),
            tracker = fly_closed_loop(solution, gains; cascade = t -> false),
            switch_at_60 = fly_closed_loop(solution, gains; cascade = t -> t < 60.0),
            switch_at_10 = fly_closed_loop(solution, gains; cascade = t -> t < 10.0),
            hand_back_at_7 = fly_closed_loop(solution, gains; cascade = t -> t >= 7.0))

    @testset "either controller holds the altitude step (§13.7, D-385)" begin
        # The probe's largest errors after 80 s, in h and V: 0.064 and 0.015 under the cascade,
        # 0.022 and 0.0008 under the tracker, 0.021 and 0.0018 and 0.019 and 0.0004 under the
        # switches, and 0.064 and 0.015 after the hand-back.
        for flown in runs
            @test termination(flown).source isa EndTimeReached
            late = logged_times(flown) .>= 80
            @test all(h -> abs(h - 1050) <= 0.2, logged_port(flown, "plant", :h)[late])
            @test all(V -> abs(V - 50) <= 0.05, logged_port(flown, "plant", :V)[late])
        end
        # The probe's peaks: 1050.064 under the cascade and 1052.309 under the tracker.
        @test maximum(logged_port(runs.cascade, "plant", :h)) < 1050.5
        @test maximum(logged_port(runs.tracker, "plant", :h)) > 1051.5
    end

    @testset "the controller not in command tracks the one that is (§13.7, D-385)" begin
        # The probe's largest gaps over [10, 60): 0.0151 for the standby tracker, and 0.0102,
        # 0.0021, 0.0134 and 0.0374 for the standby cascade's pitch-rate, airspeed, altitude and
        # attitude loops.
        @test largest_gap(runs.cascade, ("tracker_u", :out1), ("select_δe", :out), 10, 60) <= 0.04
        @test largest_gap(runs.tracker, ("q_ctl", :u), ("select_δe", :out), 10, 60) <= 0.03
        @test largest_gap(runs.tracker, ("V_ctl", :u), ("select_δt", :out), 10, 60) <= 0.005
        @test largest_gap(runs.tracker, ("h_ctl", :u), ("plant", :θ), 10, 60) <= 0.03
        @test largest_gap(runs.tracker, ("θ_ctl", :u), ("plant", :q), 10, 60) <= 0.08
    end

    @testset "the switch is bumpless in steady flight and nearly so in the climb (§13.7, D-385)" begin
        # The probe's elevator jumps: 3.45e-4 at the switch at 60 s, against 5.05e-4 of steady
        # cascade jitter in [90, 100) of the cascade run, 1.5e-3 at the switch at 10 s, and
        # 5.75e-3 around the hand-back at 7 s.
        steady_jump = largest_jump(runs.switch_at_60, "δe_lag", :out, 59.5, 61)
        @test steady_jump < 1e-3
        @test steady_jump < largest_jump(runs.cascade, "δe_lag", :out, 90, 100)
        @test largest_jump(runs.switch_at_10, "δe_lag", :out, 9.5, 11) < 5e-3
        @test largest_jump(runs.hand_back_at_7, "δe_lag", :out, 6.5, 8) < 0.02
    end

    @testset "the sensed altitude carries white noise of the declared deviation (§7.3)" begin
        # The probe's standard deviation: 0.2981.
        noise = logged_port(runs.cascade, "h_meas", :out) .- logged_port(runs.cascade, "plant", :h)
        @test isapprox(std(noise), 0.3; rtol = 0.1)
    end

    @testset "the descent ends at touchdown with the gear's stop reason (§2.3, §13.5, D-316)" begin
        flight = Simulation(descent(); h = 1//100)
        init!(flight, at_trim(solution, condition(Longitudinal(); θ = solution.θ, h = 30.0); δt = 0.25))
        run!(flight; t_end = 200.0)
        record = termination(flight)
        @test record.t ≈ 17.670844829159307 atol = 1e-3
        @test record.source isa ModelRequestedStop
        @test record.source.path == "stop"
        @test record.source.port === :flag
        @test record.source.reason == "touchdown"
        @test abs(state(flight, "plant").h) <= 1e-6
        @test modes(flight, "gear").contact === true
    end

    @testset "the closed loop's phase bodies allocate nothing (§9.8)" begin
        bodies = phase_bodies(Simulation(closed_loop(solution, gains; cascade = t -> t < 60.0); h = 1//200))
        for name in (:sweep_1, :sweep_2, :rhs, :ticks)
            body = bodies[name]
            body(); body(0)
            @test @ballocated($body()) == 0
            @test @ballocated($body(1)) == 0
        end
    end
end

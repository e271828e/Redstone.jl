# The examples' testset: one testset per example, each pinning what its
# companion claims. The pins are probed values, `longitudinal_aircraft.md`'s for
# the aircraft. Models and helpers live at top level, for `implementation.md`'s
# local-scope reason.

using Test, StaticArrays, LinearAlgebra, BenchmarkTools
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

# The closed loop flown from the trim for 120 s at the deployment's step.
function fly_closed_loop(solution, gains; t_switch)
    sim = Simulation(closed_loop(solution, gains; t_switch); h = 1//200)
    init!(sim, trimmed(solution))
    run!(sim; t_end = 120.0)
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

    @testset "either controller holds the altitude step, and the switch between them is bumpless (§13.7, D-385)" begin
        runs = (cascade = fly_closed_loop(solution, gains; t_switch = Inf),
                tracker = fly_closed_loop(solution, gains; t_switch = -1.0),
                switch = fly_closed_loop(solution, gains; t_switch = 60.0))
        for flown in runs
            @test termination(flown).source isa EndTimeReached
            late = logged_times(flown) .>= 80
            @test all(h -> abs(h - 1050) <= 0.2, logged_port(flown, "plant", :h)[late])
            @test all(V -> abs(V - 50) <= 0.05, logged_port(flown, "plant", :V)[late])
        end
        # The probe's peaks: 1050.06 under the cascade and 1054.83 under the tracker.
        @test maximum(logged_port(runs.cascade, "plant", :h)) < 1050.5
        @test maximum(logged_port(runs.tracker, "plant", :h)) > 1054
        # The probe's largest jump around the switch is 3.45e-4, against 5.05e-4 of
        # steady cascade jitter in [90, 100) of the cascade run.
        times = logged_times(runs.switch)
        around = (times .>= 59.5) .& (times .< 61)
        @test maximum(abs, diff(logged_port(runs.switch, "δe_act", :out)[around])) < 1e-3
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
        bodies = phase_bodies(Simulation(closed_loop(solution, gains; t_switch = 60.0); h = 1//200))
        for name in (:sweep_1, :sweep_2, :rhs, :ticks)
            body = bodies[name]
            body(); body(0)
            @test @ballocated($body()) == 0
            @test @ballocated($body(1)) == 0
        end
    end
end

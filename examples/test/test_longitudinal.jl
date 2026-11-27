# The longitudinal aircraft's testset, pinning what `longitudinal_aircraft.md` claims. The
# pins are probed values.

import RedstoneExamples: Longitudinal, aircraft, level_flight, longitudinal_taps, lqr_gains, closed_loop,
    trimmed, pitch_hold, autopilot, cruise, piloted, hand_flown, approach, sensor_noise_psd


# The aircraft trimmed at level flight, the simulation left at the commit.
function trimmed_aircraft()
    sim = Simulation(aircraft(); Δt_frame = 1//100)
    report = trim!(sim, level_flight(); baseline = set(u = (δe = 0.0, δt = 0.5)))
    (sim, report)
end

# The aircraft's state from `plant_state` at the trim controls.
at_trim(solution, plant_state) = combine(at("plant", plant_state), set(u = (δe = solution.δe, δt = solution.δt)))

# The closed loop flown from the trim, the cascade or the tracker in command, the altitude
# reference stepped at 5 s and command handed to the other controller at `switch_at`. A staged
# batch applies at the top of the next frame, and the ticks at a boundary settle in the frame
# that reaches it, so a write meant for the tick at `t` is staged one frame before `t`.
function fly_closed_loop(solution, gains; cascade = true, switch_at = nothing, h_step = 50.0,
                         noise_σ = 0.3, t_end = 120.0)
    h = 1//200
    frame(t) = round(Int, t / h)
    sim = Simulation(closed_loop(solution, gains; noise_σ); Δt_frame = h)
    init!(sim, cascade ? trimmed(solution) : override(trimmed(solution), set(u = (mode = false,))))
    step!(sim; frames = frame(5.0) - 1)
    stage!(sim, "h_ref" => 1000.0 + h_step)
    if switch_at !== nothing
        step!(sim; frames = frame(switch_at) - frame(5.0))
        stage!(sim, "mode" => !cascade)
    end
    run!(sim; t_end)
    sim
end

# Chapter 3's flight: chapter 1's open loop from 55 m/s at the trim controls under the deployment
# keywords given, its airspeed logged.
function fly_open_loop(solution; deployment...)
    sim = Simulation(aircraft(); deployment...)
    init!(sim, at_trim(solution, set(x = (V = 55.0, θ = solution.θ))))
    run!(sim; t_end = 120.0)
    series(sim, reads(V = get_output("plant", :V)))
end

# The largest airspeed gap between two flights at the whole seconds of chapter 3's comparison.
airspeed_gap(flight, reference) =
    maximum(t -> abs(flight.V[findfirst(==(t), flight.t)] - reference.V[findfirst(==(t), reference.t)]),
            0.0:1.0:120.0)

# The frame index of time `t` under the frame of 2.5 ms of chapters 5 to 8.
frame_index(t) = round(Int, t * 400)

# Chapter 4's loop at the trim, on either tier, its integral term holding the trim elevator: the
# continuous PID's state or the discrete one's store. The reference starts `θ_step` above the trim.
function pitch_hold_at_trim(solution; discrete = false, θ_step = 0.0)
    sim = Simulation(pitch_hold(; discrete); Δt_frame = 1//200)
    integral = discrete ? set(s = (q = solution.δe,)) : set(x = (q = solution.δe,))
    init!(sim, combine(set(u = (θ_ref = solution.θ + θ_step, δt = solution.δt)),
                       at("plant", set(x = (θ = solution.θ,))), at("θ_ctl", integral)))
    sim
end

# The deployment of chapters 5 to 8: the frame, the plant's step, at 2.5 ms and the base tick at
# 5 ms. The models state no seconds, so the base tick sets every rate: without it the base tick
# would be the frame.
loop_deployment = (Δt_frame = 1//400, Δt_base = 1//200)

# Every sensor's noise off.
quiet = (q = 0.0, θ = 0.0, h = 0.0, V = 0.0)

# Chapter 5's loop flown from the trim, the altitude reference `h_step` above it from the start.
function fly_autopilot(solution; h_step = 50.0, noise_psd = sensor_noise_psd, t_end = 120.0)
    sim = Simulation(autopilot(solution; noise_psd); loop_deployment...)
    init!(sim, override(cruise(solution), set(u = (h_ref = 1000.0 + h_step,))))
    run!(sim; t_end)
    sim
end

# The scenarios below stage each write while stopped at its nominal time. It applies at the top of
# the next frame, and a discrete component reads it at its next tick.

# Chapter 6's flight, on `piloted` or nested in `approach`: the pilot holds the trim, pulls the
# elevator 0.02 rad over [5, 7) s and, unless `engage` is false, engages the autopilot at 30 s, and
# the simulation stops at `until`.
function fly_by_hand!(sim, solution; until = 60.0, engage = true)
    step!(sim; frames = frame_index(5.0))
    stage!(sim, "δe_pilot" => solution.δe - 0.02)
    step!(sim; frames = frame_index(7.0) - frame_index(5.0))
    stage!(sim, "δe_pilot" => solution.δe)
    step!(sim; frames = frame_index(30.0) - frame_index(7.0))
    engage && stage!(sim, "engage" => true)
    step!(sim; frames = frame_index(until) - frame_index(30.0))
end

# The approach's reference, staged by the run from 1000 m down at `sink_rate`, one write per tick of
# the altitude loop, until the stop request ends the run or 10 000 writes pass, so that a write that
# never lands fails the testset instead of hanging it. Returns the count of writes.
function descend!(sim; sink_rate = 1.5)
    h_ref = 1000.0
    n_writes = 0
    while lifecycle(sim) !== :stopped && n_writes < 10_000
        h_ref -= sink_rate / 10
        stage!(sim, "h_ref" => h_ref)
        step!(sim; t_plus = 1//10)
        n_writes += 1
    end
    n_writes
end

# The plant's four logged outputs a replay or a restore is compared on.
plant_outputs(sim, path) = series(sim, reads(h = get_output(path, :h), θ = get_output(path, :θ),
                                             V = get_output(path, :V), q = get_output(path, :q))).columns

# The instants at which a logged signal changes value.
change_times(sim, signal) = logged_times(sim)[2:end][diff(signal) .!= 0]

# Whether `t` sits on the grid of `rate` hertz.
on_grid(t, rate) = isapprox(rate * t, round(rate * t); atol = 1e-6)

@testset "Longitudinal" begin
    sim, report = trimmed_aircraft()
    solution = report.solution
    linearization = linearize(sim, longitudinal_taps())
    gains = lqr_gains(linearization)

    @testset "the aircraft, the chapters' loops and the closed loop build under both activations (§9.4)" begin
        for model in (aircraft(), pitch_hold(), pitch_hold(discrete = true), autopilot(solution), piloted(solution),
                      approach(solution), closed_loop(solution, gains))
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
        open_loop = Simulation(aircraft(); Δt_frame = 1//100)
        init!(open_loop, at_trim(solution, set(x = (V = 55.0, θ = solution.θ))))
        run!(open_loop; t_end = 120.0)
        times = logged_times(open_loop)
        Vs = logged_port(open_loop, "plant", :V)
        @test length(times) == 12001
        @test minimum(Vs) < 47
        # The probe's crossings: 6.62, 20.12, 33.9, 47.45, 61.19, 74.78.
        first_six = crossings(times, Vs, 50.0)[1:6]
        @test isapprox((first_six[6] - first_six[1]) / 5, π / 0.23005; rtol = 0.01)
    end

    @testset "chapter 1: from the companion's rounded trim the open loop swings between 46 and 55 m/s, 46 m up, at a 27.3 s period (§10.2)" begin
        page = Simulation(aircraft(); Δt_frame = 1//100)
        init!(page, combine(at("plant", set(x = (V = 55.0, θ = 0.019930))),
                            set(u = (δe = 0.025058, δt = 0.37234))))
        run!(page; t_end = 120.0)
        times = logged_times(page)
        Vs = logged_port(page, "plant", :V)
        @test length(times) == 12001
        @test minimum(Vs) ≈ 45.872 atol = 1e-3
        @test maximum(Vs) == 55.0
        @test maximum(logged_port(page, "plant", :h)) ≈ 1046.016 atol = 1e-3
        # The probe's upward crossings: 20.12, 47.45, 74.78, 102.11.
        upward = [times[i] for i in 2:length(Vs) if Vs[i - 1] < 50.0 ≤ Vs[i]]
        @test length(upward) == 4
        @test all(period -> isapprox(period, 27.33; atol = 0.01), diff(upward))
    end

    @testset "chapter 2: an empty baseline trims to the same point, a trim at 2000 m commits that altitude, and at 20 m/s the trim stalls on the pitch bound and commits nothing (§14.8)" begin
        unbased = trim!(Simulation(aircraft(); Δt_frame = 1//100), level_flight(); baseline = set())
        @test unbased.n_iterations == 4
        @test all(name -> isapprox(unbased.solution[name], solution[name]; atol = 1e-12), keys(solution))
        high_sim = Simulation(aircraft(); Δt_frame = 1//100)
        trim!(high_sim, level_flight(h = 2000.0); baseline = set())
        @test state(high_sim, "plant").h == 2000.0
        slow_sim = Simulation(aircraft(); Δt_frame = 1//100)
        slow = trim!(slow_sim, level_flight(V = 20.0); baseline = set())
        @test slow.status == :stalled
        @test slow.saturated == [(:θ, :upper)]
        @test lifecycle(slow_sim) == :built
    end

    @testset "chapter 3: the Jacobian's entries are exact and match central differences, and the short period bounds the step (§14.10, §10.2)" begin
        A = linearization.A
        @test A[5, 2] == 50.0
        @test A[3, 4] == 1.0
        @test all(iszero, A[:, 5])
        # Central differences of the plant's `x_deriv` at the trim, the page's in the plain form,
        # which names the vectors by the label tuples; the probe's largest gap is 1.53e-10.
        (; x₀, u₀, x_labels, u_labels) = linearization
        u = NamedTuple{u_labels}(Tuple(u₀))
        f(v) = collect(Redstone.x_deriv(Longitudinal(), (x = NamedTuple{x_labels}(Tuple(v)), u)))
        ε = 1e-6
        A_fd = reduce(hcat, [(f(x₀ + ε * e) - f(x₀ - ε * e)) / 2ε for e in eachcol(I(5))])
        @test maximum(abs, A_fd - A) < 1e-8
        diverged = try
            fly_open_loop(solution; Δt_frame = 1)
            nothing
        catch err
            err
        end
        @test diverged isa Redstone.StepError{Redstone.NonfiniteState}
        reference = fly_open_loop(solution; Δt_frame = 1//100)
        bounded = fly_open_loop(solution; Δt_frame = 1, h_max = 1//10)
        @test length(bounded.t) - 1 == 1200
        @test airspeed_gap(bounded, reference) < 1e-5
        refusal = try
            fly_open_loop(solution; Δt_frame = 1, algorithm = Redstone.BS3())
            nothing
        catch err
            err
        end
        @test refusal isa DiagnosticError
        @test only(diagnostics(refusal)) isa Redstone.DeploymentInvalid
        # The probe's adaptive run: 418 steps, a largest gap of 4.29e-4 m/s.
        adaptive = fly_open_loop(solution; Δt_frame = 1, algorithm = Redstone.BS3(), h_min = 1//1000)
        @test 380 <= length(adaptive.t) - 1 <= 460
        @test airspeed_gap(adaptive, reference) < 1e-3
    end

    @testset "the closed loop rests at the trim under either controller (§14.5)" begin
        for cascade in (true, false)
            resting = fly_closed_loop(solution, gains; cascade, h_step = 0.0, noise_σ = 0.0, t_end = 60.0)
            # The probe's largest drift: 2.6e-10 m, 3.8e-11 m/s and 3.7e-12 rad.
            @test all(h -> abs(h - 1000) <= 1e-6, logged_port(resting, "plant", :h))
            @test all(V -> abs(V - 50) <= 1e-6, logged_port(resting, "plant", :V))
            @test all(θ -> abs(θ - solution.θ) <= 1e-6, logged_port(resting, "plant", :θ))
        end
    end

    runs = (cascade = fly_closed_loop(solution, gains),
            tracker = fly_closed_loop(solution, gains; cascade = false),
            switch_at_60 = fly_closed_loop(solution, gains; switch_at = 60.0),
            switch_at_10 = fly_closed_loop(solution, gains; switch_at = 10.0),
            hand_back_at_10 = fly_closed_loop(solution, gains; cascade = false, switch_at = 10.0))

    @testset "the staged reference and mode land on their ticks (§11.3)" begin
        # Snapshot k + 1 is the frame top t = k h, so the step lands at snapshot 1001 and the
        # switches at snapshots 12001 and 2001.
        staged(sim) = series(sim, reads(h_ref = get_input("h_ref"), mode = get_input("mode")))
        @test findfirst(==(1050.0), staged(runs.cascade).h_ref) == 1001
        @test all(staged(runs.cascade).mode)
        @test findfirst(!, staged(runs.switch_at_60).mode) == 12001
        @test findfirst(identity, staged(runs.hand_back_at_10).mode) == 2001
    end

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
        # The probe's largest gaps over [15, 60): 0.0078 for the standby tracker, and 0.0101,
        # 0.0020, 0.0134 and 0.0374 for the standby cascade's pitch-rate, airspeed, altitude and
        # attitude loops. The window opens after the climb's transient, whose end moves with the
        # noise's alignment with the step: over 25 alignments of the step, 5.00 to 5.48 s, the
        # standby attitude loop's gap last exceeds 0.08 between 8.6 and 14.0 s, and from 15 s on
        # every gap reads the same under all 25.
        cascade, tracker = runs.cascade, runs.tracker
        @test largest_gap(logged_face(cascade, "lqr_controller", :δe), logged_face(cascade, "selection", :δe),
                          cascade, 15, 60) <= 0.04
        @test largest_gap(logged_face(tracker, "pid_controller", :δe), logged_face(tracker, "selection", :δe),
                          tracker, 15, 60) <= 0.03
        @test largest_gap(logged_face(tracker, "pid_controller", :δt), logged_face(tracker, "selection", :δt),
                          tracker, 15, 60) <= 0.005
        @test largest_gap(logged_port(tracker, "pid_controller/h_ctl", :u), logged_port(tracker, "plant", :θ),
                          tracker, 15, 60) <= 0.03
        @test largest_gap(logged_port(tracker, "pid_controller/θ_ctl", :u), logged_port(tracker, "plant", :q),
                          tracker, 15, 60) <= 0.08
    end

    @testset "the switch is bumpless in steady flight and nearly so in the climb (§13.7, D-385)" begin
        # The probe's elevator jumps: 3.45e-4 at the switch at 60 s, against 5.05e-4 of steady
        # cascade jitter in [90, 100) of the cascade run. The two mid-climb switches are pinned on
        # the command before the rate limiter, which caps the actuator's change at about 5.8e-3
        # whatever happens upstream: the probe's command jumps 1.13e-2 at the switch at 10 s and
        # 2.26e-3 at the hand-back at 10 s.
        steady_jump = largest_jump(logged_face(runs.switch_at_60, "actuators", :δe), runs.switch_at_60, 59.5, 61)
        @test steady_jump < 1e-3
        @test steady_jump < largest_jump(logged_face(runs.cascade, "actuators", :δe), runs.cascade, 90, 100)
        @test largest_jump(logged_face(runs.switch_at_10, "selection", :δe), runs.switch_at_10, 9.9, 10.1) < 0.03
        @test largest_jump(logged_face(runs.hand_back_at_10, "selection", :δe), runs.hand_back_at_10, 9.9, 10.1) <
              0.005
    end

    @testset "the sensed altitude carries white noise of the declared deviation (§7.3)" begin
        # The probe's standard deviation: 0.2981.
        noise = logged_face(runs.cascade, "sensing", :h_meas) .- logged_port(runs.cascade, "plant", :h)
        @test isapprox(std(noise), 0.3; rtol = 0.1)
    end

    @testset "chapter 4: the continuous pitch hold linearizes with unit DC gain, the discrete one refuses (§14.10, D-272)" begin
        loop_taps = taps(x = (V = get_state("plant", :V), γ = get_state("plant", :γ), θ = get_state("plant", :θ),
                              q = get_state("plant", :q), ξ = get_state("θ_ctl", :q)),
                         u = (θ_ref = get_input(:θ_ref),), y = (θ = get_output("plant", :θ),))
        closed = linearize(pitch_hold_at_trim(solution), loop_taps)
        # The probe's eigenvalues: -2.047 ± 8.064im, -1.392, -0.642 and -0.052.
        λs = eigvals(closed.A)
        @test all(λ -> real(λ) < 0, λs)
        @test maximum(imag, λs) ≈ 8.063682350858338 atol = 1e-6
        @test maximum(real, λs) ≈ -0.051555431912159534 atol = 1e-6
        @test (closed.D - closed.C * (closed.A \ closed.B))[1] ≈ 1 atol = 1e-9
        refusal = try
            linearize(pitch_hold_at_trim(solution; discrete = true), loop_taps)
            nothing
        catch err
            err
        end
        # The discrete tier holds the controller's store and the reference it reads: one refusal for
        # each tap.
        @test refusal isa DiagnosticError
        @test all(d -> d isa TapResolution, diagnostics(refusal))
        @test Set((d.reason, d.tap) for d in diagnostics(refusal)) == Set([(:discrete_state, :x), (:unseedable, :u)])
    end

    @testset "chapter 4: the discrete pitch hold at 50 Hz follows the continuous one through a step (§6.3)" begin
        θs = map((false, true)) do discrete
            sim = pitch_hold_at_trim(solution; discrete, θ_step = 0.05)
            run!(sim; t_end = 9.0)
            logged_port(sim, "plant", :θ)
        end
        # The probe's peaks: 0.07991 continuous and 0.08200 discrete; the largest gap 0.00211.
        @test maximum(θs[1]) ≈ 0.0799086028202168 atol = 1e-4
        @test maximum(θs[2]) ≈ 0.08199667463210653 atol = 1e-4
        @test maximum(abs, θs[1] .- θs[2]) <= 0.003
    end

    @testset "chapter 5: the autopilot rests at the trim (§14.5)" begin
        resting = fly_autopilot(solution; h_step = 0.0, noise_psd = quiet, t_end = 60.0)
        # The probe's largest drift: 2.4e-10 m, 4.0e-11 m/s and 3.7e-12 rad.
        @test all(h -> abs(h - 1000) <= 1e-6, logged_port(resting, "plant", :h))
        @test all(V -> abs(V - 50) <= 1e-6, logged_port(resting, "plant", :V))
        @test all(θ -> abs(θ - solution.θ) <= 1e-6, logged_port(resting, "plant", :θ))
    end

    @testset "chapters 5 to 7: with every noise off, each model's measurements equal the plant's outputs at their sensors' ticks (§3.2, §7.3)" begin
        # Each model passes `noise_psd` down to its sensing: one that drops it measures with the
        # default densities.
        for (model, initial, prefix) in ((autopilot(solution; noise_psd = quiet), cruise(solution), ""),
                                         (piloted(solution; noise_psd = quiet), hand_flown(solution), ""),
                                         (approach(solution; noise_psd = quiet), at("vehicle", hand_flown(solution)),
                                          "vehicle/"))
            noiseless = Simulation(model; loop_deployment...)
            init!(noiseless, initial)
            run!(noiseless; t_end = 1.0)
            times = logged_times(noiseless)
            for (face, port, rate) in ((:q_meas, :q, 200), (:θ_meas, :θ, 50), (:h_meas, :h, 10), (:V_meas, :V, 10))
                ticks = on_grid.(times, rate)
                @test logged_face(noiseless, "$(prefix)sensing", face)[ticks] ==
                      logged_port(noiseless, "$(prefix)plant", port)[ticks]
            end
        end
    end

    climb = fly_autopilot(solution)

    @testset "chapters 5 to 7: the models declare no anchor, and each sensor and its controllers tick at one multiplier of the base tick (§6.3, §8.7)" begin
        for model in (autopilot(solution), piloted(solution), approach(solution))
            @test isempty(build(model).structure.anchors)
        end
        # The schedule's divisors, in base ticks: the IMU's 1, the INS's 4 and the air data's 20,
        # the latch at the air data's, and the delays and limiters at the base tick. `autopilot` has
        # no `selection`, and `approach` holds `piloted` as `vehicle`.
        divisors = Dict("sensing/imu/q_noise" => 1, "sensing/imu/q_meas" => 1,
                        "sensing/ins/θ_noise" => 4, "sensing/ins/θ_meas" => 4,
                        "sensing/air_data/h_noise" => 20, "sensing/air_data/h_meas" => 20,
                        "sensing/air_data/V_noise" => 20, "sensing/air_data/V_meas" => 20,
                        "cascade/q_ctl" => 1, "cascade/θ_ctl" => 4, "cascade/h_ctl" => 20, "cascade/V_ctl" => 20,
                        "selection/latch" => 20, "selection/command_δe" => 1, "selection/command_δt" => 1,
                        "actuators/δe_limiter" => 1, "actuators/δt_limiter" => 1)
        without_selection = filter(entry -> !startswith(entry.first, "selection/"), divisors)
        for (model, expected) in ((autopilot(solution), without_selection), (piloted(solution), divisors),
                                  (approach(solution), Dict("vehicle/" * path => D for (path, D) in divisors)))
            rows = Simulation(model; loop_deployment...).model.deployment.schedule.rows
            @test Dict(row.path => row.D for row in rows) == expected
            @test all(row -> row.anchor == 0 && row.Φ == 0, rows)
        end
        # The deployment gives the seconds: the same divisors at a base tick of 10 ms.
        slower = Simulation(piloted(solution); Δt_frame = 1//400, Δt_base = 1//100).model.deployment.schedule.rows
        @test Dict(row.path => row.D for row in slower) == divisors
        @test Dict(row.path => row.Δt for row in slower)["cascade/h_ctl"] == 0.2
    end

    @testset "chapter 5: the pitch-rate loop ticks at 200 Hz, the attitude loop at 50 Hz, the altitude and airspeed loops at 10 Hz (§6.3)" begin
        # Each loop changes on its own grid and not only on the next coarser one. The log holds a
        # snapshot every 2.5 ms, so half the snapshots fall between the base ticks, and the
        # pitch-rate loop shows no change at any of them.
        @test count(t -> !on_grid(t, 200), logged_times(climb)) == 24000
        for (loop, rate, coarser) in (("q_ctl", 200, 50), ("θ_ctl", 50, 10), ("h_ctl", 10, nothing), ("V_ctl", 10, nothing))
            changes = change_times(climb, logged_port(climb, "cascade/$loop", :u))
            @test !isempty(changes)
            @test all(t -> on_grid(t, rate), changes)
            coarser === nothing || @test !all(t -> on_grid(t, coarser), changes)
        end
    end

    @testset "chapter 5: the autopilot holds the altitude step (§13.7)" begin
        # The probe's figures after 75 s: 0.0795 m and 0.0235 m/s; its peak 1050.063; its largest
        # airspeed excursion over the climb 3.9244 m/s.
        @test termination(climb).source isa EndTimeReached
        late = logged_times(climb) .>= 75
        @test all(h -> abs(h - 1050) <= 0.12, logged_port(climb, "plant", :h)[late])
        @test all(V -> abs(V - 50) <= 0.035, logged_port(climb, "plant", :V)[late])
        @test maximum(logged_port(climb, "plant", :h)) < 1050.2
        @test maximum(abs, logged_port(climb, "plant", :V) .- 50) ≈ 3.9244 atol = 0.02
    end

    @testset "chapter 5: each sensor samples and holds at its rate, each noise of its declared density and its own seed (§3.2, §7.3)" begin
        times = logged_times(climb)
        # The deviations per sample the densities declare at each sensor's rate, against the probe's
        # 0.001998 rad/s, 0.0005018 rad, 0.1322 m and 0.02004 m/s.
        sensors = ((:q_meas, :q, 200, 50, 0.002), (:θ_meas, :θ, 50, 10, 5e-4),
                   (:h_meas, :h, 10, nothing, sqrt(1.8e-3 / 0.1)), (:V_meas, :V, 10, nothing, 0.02))
        for (face, port, rate, coarser, σ) in sensors
            measured = logged_face(climb, "sensing", face)
            changes = change_times(climb, measured)
            @test all(t -> on_grid(t, rate), changes)
            coarser === nothing || @test !all(t -> on_grid(t, coarser), changes)
            noise = (measured .- logged_port(climb, "plant", port))[on_grid.(times, rate)]
            @test isapprox(std(noise), σ; rtol = 0.1)
        end
        # The four noises draw from distinct seeds: each leaf's draws, read at its sensor's ticks, are
        # uncorrelated by draw with every other's. The probe's largest correlation over the six
        # pairs: -0.057, the IMU's against the altitude's.
        draws = map((("imu/q_noise", 200), ("ins/θ_noise", 50), ("air_data/h_noise", 10),
                     ("air_data/V_noise", 10))) do (leaf, rate)
            logged_port(climb, "sensing/$leaf", "")[on_grid.(times, rate)]
        end
        for i in 1:4, j in (i + 1):4
            n = min(length(draws[i]), length(draws[j]))
            @test abs(cor(draws[i][1:n], draws[j][1:n])) < 0.15
        end
    end

    @testset "chapter 6: the tracking wires without the delays close an algebraic loop per switch (§5.4, §13.8)" begin
        model = piloted(solution)
        undelayed = map(local_wires(model)) do wire
            wire.first == "selection/δe_prev" ? ("selection/δe" => wire.second) :
            wire.first == "selection/δt_prev" ? ("selection/δt" => wire.second) : wire
        end
        bypassed = Group(model; local_wires = undelayed)
        refusal = try
            build(bypassed)
            nothing
        catch err
            err
        end
        @test refusal isa DiagnosticError
        cycles = diagnostics(refusal)
        @test length(cycles) == 2
        @test all(d -> d isa AlgebraicCycle && d.classification === :real, cycles)
        @test Set(Set(d.members) for d in cycles) ==
              Set([Set(["cascade/q_ctl", "selection/select_δe"]), Set(["cascade/V_ctl", "selection/select_δt"])])
    end

    hand = Simulation(piloted(solution); loop_deployment...)
    init!(hand, hand_flown(solution))
    fly_by_hand!(hand, solution)
    run!(hand; t_end = 90.0)

    @testset "chapter 6: the pilot's staged commands and the engage land on their ticks (§11.3)" begin
        # Snapshot k + 1 is the frame top t = k h, and a write staged at t applies from the frame
        # after it, so the pull shows at snapshot 2002, its release at 2802 and the engage at 12002.
        staged = series(hand, reads(δe = get_input("δe_pilot"), engage = get_input("engage")))
        @test findfirst(!=(solution.δe), staged.δe) == 2002
        @test findfirst(==(solution.δe), staged.δe[2002:end]) + 2001 == 2802
        @test findfirst(identity, staged.engage) == 12002
        by_hand = window(hand, 0, 30)
        @test logged_face(hand, "selection", :δe)[by_hand] == staged.δe[by_hand]
        # The probe's altitudes by hand: up to 1016.7 m, down to 988.0 m.
        @test maximum(logged_port(hand, "plant", :h)[by_hand]) > 1015
    end

    @testset "chapter 6: the standby cascade tracks the pilot and the engage is bumpless (D-385)" begin
        # The probe's standby gaps over [8, 30): 0.0048 on the elevator, and over [5, 30) 0.0255 on
        # the throttle, whose loop ticks at 10 Hz and reads the airspeed's noise through `Kp`. The
        # latch publishes the engage staged at 30 s at its 30.2 s tick, where the switches and every
        # controller read it, and the selected commands jump there by the standby's gap: 0.00063 on
        # the elevator and 0.0106 on the throttle.
        δe_selected, δt_selected = logged_face(hand, "selection", :δe), logged_face(hand, "selection", :δt)
        @test largest_gap(logged_face(hand, "cascade", :δe), δe_selected, hand, 8, 30) <= 0.008
        @test largest_gap(logged_face(hand, "cascade", :δt), δt_selected, hand, 5, 30) <= 0.035
        # The standby outer loops track the measurements of the loops inside them. The probe's gaps
        # over [8, 30): 0.0093 between the altitude loop's command and the measured θ and 0.0227
        # between the attitude loop's and the measured q, at most 0.0093 and 0.0227 over 20
        # alignments of each write 2.5 ms apart.
        θ_meas, q_meas = logged_face(hand, "sensing", :θ_meas), logged_face(hand, "sensing", :q_meas)
        @test largest_gap(logged_port(hand, "cascade/h_ctl", :u), θ_meas, hand, 8, 30) <= 0.015
        @test largest_gap(logged_port(hand, "cascade/θ_ctl", :u), q_meas, hand, 8, 30) <= 0.03
        switch = findfirst(identity, logged_face(hand, "selection", :engaged))
        @test logged_times(hand)[switch] == 30.2
        # The switches act at the same tick, where the selected elevator command first leaves the
        # pilot's.
        times = logged_times(hand)
        δe_pilot = series(hand, reads(δe = get_input("δe_pilot"))).δe
        handover = findfirst(k -> times[k] > 29.9 && δe_selected[k] != δe_pilot[k], eachindex(times))
        @test times[handover] == 30.2
        # Until the latch publishes, each controller computes exactly what it computes in the same
        # flight with no engage, the same model under the same seeds. A `DiscretePID` publishes `u`
        # from its state before the tick's update, so a controller first shows the engage at its tick
        # after 30.2 s: 30.205 s at 200 Hz, 30.22 s at 50 Hz, 30.3 s at 10 Hz. The window holds the
        # 30.2 s snapshot and ends before the pitch-rate loop's next tick, its edge mid-gap between
        # the snapshots at 30.2 s and 30.2025 s.
        unengaged = Simulation(piloted(solution); loop_deployment...)
        init!(unengaged, hand_flown(solution))
        fly_by_hand!(unengaged, solution; until = 30.4, engage = false)
        for loop in ("h_ctl", "θ_ctl", "q_ctl", "V_ctl")
            @test logged_port(hand, "cascade/$loop", :u)[window(hand, 0, 30.20125)] ==
                  logged_port(unengaged, "cascade/$loop", :u)[window(unengaged, 0, 30.20125)]
        end
        @test abs(δe_selected[switch] - δe_selected[switch - 1]) <= 0.005
        @test abs(δt_selected[switch] - δt_selected[switch - 1]) <= 0.015
    end

    @testset "chapter 6: once engaged the autopilot recaptures the reference altitude (§13.7)" begin
        # The probe's largest error over [80, 90): 0.060 m.
        @test all(h -> abs(h - 1000) <= 0.12, logged_port(hand, "plant", :h)[window(hand, 80, 90)])
    end

    flight = Simulation(approach(solution); loop_deployment...)
    init!(flight, at("vehicle", hand_flown(solution)))
    fly_by_hand!(flight, solution)
    by_hand_outputs = plant_outputs(flight, "vehicle/plant")
    descent_top = checkpoint(flight)
    n_writes = descend!(flight)

    @testset "chapter 7: the approach flies chapter 6's flight, then descends to a touchdown that stops the run (§2.3, §13.5, D-316)" begin
        @test by_hand_outputs == map(column -> column[1:length(by_hand_outputs.h)], plant_outputs(hand, "plant"))
        record = termination(flight)
        # The probe's touchdown: 726.647 s, 6667 writes of the reference after the cruise.
        @test record.t ≈ 726.6468115368581 atol = 1e-3
        @test n_writes == 6667
        @test record.source isa ModelRequestedStop
        @test record.source.path == "stop"
        @test record.source.port === :y
        @test record.source.reason == "touchdown"
        @test abs(state(flight, "vehicle/plant").h) <= 1e-6
        @test modes(flight, "gear").contact === true
        h_refs = series(flight, reads(h_ref = get_input("h_ref"))).h_ref
        # The last staged reference, read back: the probe's -0.04999999989 m, 1000 m less 6667 writes.
        @test h_refs[end] ≈ -0.05 atol = 1e-6
        # The probe's largest tracking error over [160 s, the last second): 0.246 m.
        descending = window(flight, 160, record.t - 1)
        @test maximum(abs, (logged_port(flight, "vehicle/plant", :h) .- h_refs)[descending]) <= 0.35
    end

    @testset "chapter 8: the whole flight replays bit-identically from its trace, touchdown included (§12.7)" begin
        replayed = Simulation(approach(solution); loop_deployment...)
        replay!(replayed, trace(flight))
        @test termination(replayed).t == termination(flight).t
        @test termination(replayed).source.reason == "touchdown"
        @test logged_times(replayed) == logged_times(flight)
        @test plant_outputs(replayed, "vehicle/plant") == plant_outputs(flight, "vehicle/plant")
        @test logged_face(replayed, "vehicle/selection", :δe) == logged_face(flight, "vehicle/selection", :δe)
    end

    @testset "chapter 8: a checkpoint at the top of the descent flies a second approach (§12.6)" begin
        second = Simulation(approach(solution); loop_deployment...)
        restore!(second, descent_top)
        descend!(second; sink_rate = 2.0)
        record = termination(second)
        # The probe's second touchdown, at 2 m/s: 559.967 s.
        @test record.t ≈ 559.9669062395417 atol = 1e-3
        @test record.source.reason == "touchdown"
        @test abs(state(second, "vehicle/plant").h) <= 1e-6
        # Restored and flown at 1.5 m/s again, the first approach's touchdown, to the bit.
        restore!(second, descent_top)
        descend!(second)
        @test termination(second).t == termination(flight).t
    end

    @testset "the approach's phase bodies allocate nothing (§9.8)" begin
        bodies = phase_bodies(Simulation(approach(solution); loop_deployment...))
        for name in (:sweep_1, :sweep_2, :rhs, :ticks)
            body = bodies[name]
            body(); body(0)
            @test @ballocated($body()) == 0
            @test @ballocated($body(1)) == 0
        end
    end

    @testset "the closed loop's phase bodies allocate nothing (§9.8)" begin
        bodies = phase_bodies(Simulation(closed_loop(solution, gains); Δt_frame = 1//200))
        for name in (:sweep_1, :sweep_2, :rhs, :ticks)
            body = bodies[name]
            body(); body(0)
            @test @ballocated($body()) == 0
            @test @ballocated($body(1)) == 0
        end
    end
end

# The longitudinal aircraft's testset, pinning what `longitudinal_aircraft.md` claims. The
# pins are probed values.

import RedstoneExamples: Longitudinal, aircraft, level_flight, longitudinal_taps, lqr_gains, closed_loop,
    trimmed, pitch_hold, autopilot, cruise, piloted, hand_flown, approach


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

# The frame index of time `t` under the loops' frame of 5 ms.
frame_index(t) = round(Int, t * 200)

# Chapter 4's loop at the trim, on either tier, its integral term holding the trim elevator: the
# continuous PID's state or the discrete one's store. The reference starts `θ_step` above the trim.
function pitch_hold_at_trim(solution; discrete = false, θ_step = 0.0)
    sim = Simulation(pitch_hold(; discrete); Δt_frame = 1//200)
    integral = discrete ? set(s = (q = solution.δe,)) : set(x = (q = solution.δe,))
    init!(sim, combine(set(u = (θ_ref = solution.θ + θ_step, δt = solution.δt)),
                       at("plant", condition(Longitudinal(); θ = solution.θ)), at("θ_ctl", integral)))
    sim
end

# Chapter 5's loop flown from the trim, the altitude reference `h_step` above it from the start.
function fly_autopilot(solution; h_step = 50.0, noise_psd = 1.8e-3, t_end = 120.0)
    sim = Simulation(autopilot(solution; noise_psd); Δt_frame = 1//200)
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

# Whether `t` sits on the 10 Hz grid.
on_10_hz(t) = isapprox(10t, round(10t); atol = 1e-6)

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
        staged(sim) = series(sim, reads(h_ref = get_input("h_ref"), mode = get_input("mode"))).columns
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

    @testset "chapter 4: the discrete pitch hold at 50 Hz follows the continuous one through a step (§10.5)" begin
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
        resting = fly_autopilot(solution; h_step = 0.0, noise_psd = 0.0, t_end = 60.0)
        # The probe's largest drift: 2.3e-10 m, 3.9e-11 m/s and 3.7e-12 rad.
        @test all(h -> abs(h - 1000) <= 1e-6, logged_port(resting, "plant", :h))
        @test all(V -> abs(V - 50) <= 1e-6, logged_port(resting, "plant", :V))
        @test all(θ -> abs(θ - solution.θ) <= 1e-6, logged_port(resting, "plant", :θ))
    end

    climb = fly_autopilot(solution)

    @testset "chapter 5: the altitude and airspeed loops tick at 10 Hz and the pitch loops at 50 Hz (§10.5)" begin
        for (loop, ten_hz) in (("h_ctl", true), ("V_ctl", true), ("θ_ctl", false), ("q_ctl", false))
            changes = change_times(climb, logged_port(climb, "cascade/$loop", :u))
            @test !isempty(changes)
            @test all(t -> isapprox(50t, round(50t); atol = 1e-6), changes)
            @test all(on_10_hz, changes) == ten_hz
        end
    end

    @testset "chapter 5: the autopilot holds the altitude step (§13.7)" begin
        # The probe's figures after 75 s: 0.0775 m and 0.0187 m/s; its peak 1050.061; its largest
        # airspeed excursion over the climb 3.9015 m/s.
        @test termination(climb).source isa EndTimeReached
        late = logged_times(climb) .>= 75
        @test all(h -> abs(h - 1050) <= 0.12, logged_port(climb, "plant", :h)[late])
        @test all(V -> abs(V - 50) <= 0.03, logged_port(climb, "plant", :V)[late])
        @test maximum(logged_port(climb, "plant", :h)) < 1050.2
        @test maximum(abs, logged_port(climb, "plant", :V) .- 50) ≈ 3.9015 atol = 0.02
    end

    @testset "chapter 5: the altimeter samples and holds at 10 Hz, its noise of the declared density (§3.2, §7.3)" begin
        h_meas = logged_face(climb, "sensing", :h_meas)
        @test all(on_10_hz, change_times(climb, h_meas))
        noise = (h_meas .- logged_port(climb, "plant", :h))[on_10_hz.(logged_times(climb))]
        # The probe's deviation per sample: 0.1322, against sqrt(1.8e-3 / 0.1) = 0.134.
        @test isapprox(std(noise), sqrt(1.8e-3 / 0.1); rtol = 0.1)
    end

    @testset "chapter 6: the tracking wires without the delays close an algebraic loop per switch (§5.4, §13.8)" begin
        model = piloted(solution)
        undelayed = map(local_wires(model)) do wire
            wire.first == "selection/δe_prev" ? ("selection/δe" => wire.second) :
            wire.first == "selection/δt_prev" ? ("selection/δt" => wire.second) : wire
        end
        bypassed = Group(model.children; local_wires = undelayed, input_wires = input_wires(model),
                         output_wires = output_wires(model))
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

    hand = Simulation(piloted(solution); Δt_frame = 1//200)
    init!(hand, hand_flown(solution))
    fly_by_hand!(hand, solution)
    run!(hand; t_end = 90.0)

    @testset "chapter 6: the pilot's staged commands and the engage land on their ticks (§11.3)" begin
        # Snapshot k + 1 is the frame top t = k h, and a write staged at t applies from the frame
        # after it, so the pull shows at snapshot 1002, its release at 1402 and the engage at 6002.
        staged = series(hand, reads(δe = get_input("δe_pilot"), engage = get_input("engage"))).columns
        @test findfirst(!=(solution.δe), staged.δe) == 1002
        @test findfirst(==(solution.δe), staged.δe[1002:end]) + 1001 == 1402
        @test findfirst(identity, staged.engage) == 6002
        by_hand = window(hand, 0, 30)
        @test logged_face(hand, "selection", :δe)[by_hand] == staged.δe[by_hand]
        # The probe's altitudes by hand: up to 1016.7 m, down to 988.0 m.
        @test maximum(logged_port(hand, "plant", :h)[by_hand]) > 1015
    end

    @testset "chapter 6: the standby cascade tracks the pilot and the engage is bumpless (D-385)" begin
        # The probe's standby gaps over [8, 30): 0.0043 on the elevator, and over [5, 30) 0.0156 on
        # the throttle, whose loop ticks at 10 Hz. The latch publishes the engage staged at 30 s at
        # its 30.2 s tick, where the switches and every controller read it, and the selected
        # commands jump there by the standby's gap: 0.0011 on the elevator and 0.0086 on the
        # throttle, under the 0.01 its rate limiter passes per tick.
        δe_selected, δt_selected = logged_face(hand, "selection", :δe), logged_face(hand, "selection", :δt)
        @test largest_gap(logged_face(hand, "cascade", :δe), δe_selected, hand, 8, 30) <= 0.008
        @test largest_gap(logged_face(hand, "cascade", :δt), δt_selected, hand, 5, 30) <= 0.02
        # The standby outer loops track the measurements of the loops inside them. The probe's gaps
        # over [8, 30): 0.0086 between the altitude loop's command and θ and 0.0201 between the
        # attitude loop's and q, at most 0.0088 and 0.0202 over 20 alignments of each write 5 ms
        # apart.
        @test largest_gap(logged_port(hand, "cascade/h_ctl", :u), logged_port(hand, "plant", :θ), hand, 8, 30) <= 0.015
        @test largest_gap(logged_port(hand, "cascade/θ_ctl", :u), logged_port(hand, "plant", :q), hand, 8, 30) <= 0.03
        switch = findfirst(identity, logged_face(hand, "selection", :engaged))
        @test logged_times(hand)[switch] == 30.2
        # The switches act at the same tick, where the selected elevator command first leaves the
        # pilot's.
        times = logged_times(hand)
        δe_pilot = series(hand, reads(δe = get_input("δe_pilot"))).columns.δe
        handover = findfirst(k -> times[k] > 29.9 && δe_selected[k] != δe_pilot[k], eachindex(times))
        @test times[handover] == 30.2
        # Until the latch publishes, each controller computes exactly what it computes in the same
        # flight with no engage, the same model under the same seed. A `DiscretePID` publishes `u`
        # from its state before the tick's update, so a controller first shows the engage at its tick
        # after 30.2 s: 30.22 s at 50 Hz, 30.3 s at 10 Hz. The window holds the 30.2 s snapshot and
        # ends before the 50 Hz loops' next tick, its edge mid-gap between the snapshots at 30.205 s
        # and 30.21 s.
        unengaged = Simulation(piloted(solution); Δt_frame = 1//200)
        init!(unengaged, hand_flown(solution))
        fly_by_hand!(unengaged, solution; until = 30.4, engage = false)
        for loop in ("h_ctl", "θ_ctl", "q_ctl", "V_ctl")
            @test logged_port(hand, "cascade/$loop", :u)[window(hand, 0, 30.2075)] ==
                  logged_port(unengaged, "cascade/$loop", :u)[window(unengaged, 0, 30.2075)]
        end
        @test abs(δe_selected[switch] - δe_selected[switch - 1]) <= 0.005
        @test abs(δt_selected[switch] - δt_selected[switch - 1]) <= 0.01
    end

    @testset "chapter 6: once engaged the autopilot recaptures the reference altitude (§13.7)" begin
        # The probe's largest error over [80, 90): 0.057 m.
        @test all(h -> abs(h - 1000) <= 0.12, logged_port(hand, "plant", :h)[window(hand, 80, 90)])
    end

    flight = Simulation(approach(solution); Δt_frame = 1//200)
    init!(flight, at("vehicle", hand_flown(solution)))
    fly_by_hand!(flight, solution)
    by_hand_outputs = plant_outputs(flight, "vehicle/plant")
    descent_top = checkpoint(flight)
    n_writes = descend!(flight)

    @testset "chapter 7: the approach flies chapter 6's flight, then descends to a touchdown that stops the run (§2.3, §13.5, D-316)" begin
        @test by_hand_outputs == map(column -> column[1:length(by_hand_outputs.h)], plant_outputs(hand, "plant"))
        record = termination(flight)
        # The probe's touchdown: 726.644 s, 6667 writes of the reference after the cruise.
        @test record.t ≈ 726.6442291951134 atol = 1e-3
        @test n_writes == 6667
        @test record.source isa ModelRequestedStop
        @test record.source.path == "stop"
        @test record.source.port === :y
        @test record.source.reason == "touchdown"
        @test abs(state(flight, "vehicle/plant").h) <= 1e-6
        @test modes(flight, "gear").contact === true
        h_refs = series(flight, reads(h_ref = get_input("h_ref"))).columns.h_ref
        # The last staged reference, read back: the probe's -0.04999999989 m, 1000 m less 6667 writes.
        @test h_refs[end] ≈ -0.05 atol = 1e-6
        # The probe's largest tracking error over [160 s, the last second): 0.247 m.
        descending = window(flight, 160, record.t - 1)
        @test maximum(abs, (logged_port(flight, "vehicle/plant", :h) .- h_refs)[descending]) <= 0.35
    end

    @testset "chapter 8: the whole flight replays bit-identically from its trace, touchdown included (§12.7)" begin
        replayed = Simulation(approach(solution); Δt_frame = 1//200)
        replay!(replayed, trace(flight))
        @test termination(replayed).t == termination(flight).t
        @test termination(replayed).source.reason == "touchdown"
        @test logged_times(replayed) == logged_times(flight)
        @test plant_outputs(replayed, "vehicle/plant") == plant_outputs(flight, "vehicle/plant")
        @test logged_face(replayed, "vehicle/selection", :δe) == logged_face(flight, "vehicle/selection", :δe)
    end

    @testset "chapter 8: a checkpoint at the top of the descent flies a second approach (§12.6)" begin
        second = Simulation(approach(solution); Δt_frame = 1//200)
        restore!(second, descent_top)
        descend!(second; sink_rate = 2.0)
        record = termination(second)
        # The probe's second touchdown, at 2 m/s: 559.969 s.
        @test record.t ≈ 559.9685756981099 atol = 1e-3
        @test record.source.reason == "touchdown"
        @test abs(state(second, "vehicle/plant").h) <= 1e-6
        # Restored and flown at 1.5 m/s again, the first approach's touchdown, to the bit.
        restore!(second, descent_top)
        descend!(second)
        @test termination(second).t == termination(flight).t
    end

    @testset "the approach's phase bodies allocate nothing (§9.8)" begin
        bodies = phase_bodies(Simulation(approach(solution); Δt_frame = 1//200))
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

# --- the first adaptive backend (§10.2, §10.5, increment 97) ---------------------
# Bogacki–Shampine 3(2) under proportional-integral control, shaped by the
# Model's bounds `h_min` and `h_max`. The claims: a run under it is a function
# of its condition and its recorded inputs, bit for bit across a checkpoint;
# the method has its order and its controller its constants; the floor
# degrades and reports; and nothing outside the backend reads its tolerances.

# BS3 through the seam's protocol with a record kept, every call forwarded. Per
# attempt it keeps the start's clock, the length, the verdict, the controller's
# memory before and after, and the proposal after, all values. Past 10 000
# attempts it throws, so a step loop that never ends fails its test.
struct Watched <: AbstractAlgorithm
    inner::BS3
end
Watched() = Watched(BS3())
struct WatchedStepper{T} <: AbstractStepper
    inner::BS3Stepper{T}
    attempts::Vector{NTuple{6,Any}}
end
bind_stepper(algorithm::Watched, ::Type{T}, n_x::Int) where {T} =
    WatchedStepper{T}(bind_stepper(algorithm.inner, T, n_x), NTuple{6,Any}[])
proposes(::Watched) = true
propose(stepper::WatchedStepper) = propose(stepper.inner)
checkpoint_stepper(stepper::WatchedStepper) = checkpoint_stepper(stepper.inner)
restore_stepper!(stepper::WatchedStepper, carried) = restore_stepper!(stepper.inner, carried)
reset_stepper!(stepper::WatchedStepper) = reset_stepper!(stepper.inner)
discontinuity!(stepper::WatchedStepper) = discontinuity!(stepper.inner)
startpoint(stepper::WatchedStepper) = startpoint(stepper.inner)
function attempt!(stepper::WatchedStepper, model::Model, h)
    length(stepper.attempts) ≥ 10_000 && error("the watched backend ran past 10 000 attempts")
    inner, t = stepper.inner, ForwardDiff.value(model.exec.clock.t)
    before = inner.memory
    accepted = attempt!(inner, model, h)
    push!(stepper.attempts, (Float64(ForwardDiff.value(t)), Float64(ForwardDiff.value(h)),
                             accepted, before, inner.memory, inner.proposal))
    accepted
end

# Hooks keeping each settled boundary's clock as its value, at any scalar.
mutable struct ClockHooks{M} <: FrameHooks
    model::M
    clocks::Vector{Float64}
end
frame_top!(::ClockHooks) = false
settled!(hooks::ClockHooks) =
    (push!(hooks.clocks, Float64(ForwardDiff.value(hooks.model.exec.clock.t))); false)

# A state falling at unit rate from 1 toward a cliff at 0, below which its
# derivative is not a number: a step that overshoots the cliff blows up.
struct Cliff <: AbstractComponent end
x_init(::Cliff) = 1.0
y_types(::Cliff) = Float64
y_state(::Cliff, (; x)) = x
x_deriv(::Cliff, (; x)) = x ≥ 0 ? -1.0 : NaN

# A state relaxing toward 1, reset to 0 by a localized event at 0.6: a
# nonlinear flow whose handler raises the discontinuity notice.
struct Recharger <: AbstractComponent end
x_init(::Recharger) = (q = 0.0,)
m_init(::Recharger) = (count = 0,)
y_types(::Recharger) = (q = Float64,)
y_state(::Recharger, (; x)) = (q = x.q,)
x_deriv(::Recharger, (; x)) = (q = 1.0 - x.q,)
recharger_guard(::Recharger, (; x)) = x.q - 0.6
recharger_handler(::Recharger, (; m)) = (x = (q = 0.0,), m = (count = m.count + 1,))
state_events(::Recharger) = (reset = StateEvent(recharger_guard, recharger_handler),)

# An orbit of eccentricity 0.8 from pericentre, μ = a = 1. At the start the
# speed is 3 and the acceleration 25, so the first stage is hand-computable.
struct Kepler <: AbstractComponent end
x_init(::Kepler) = (r = SVector(0.2, 0.0), v = SVector(0.0, 3.0))
y_types(::Kepler) = (rx = Float64,)
y_state(::Kepler, (; x)) = (rx = x.r[1],)
x_deriv(::Kepler, (; x)) = (r = x.v, v = -x.r / sqrt(x.r[1]^2 + x.r[2]^2)^3)

# A state growing or decaying at the rate `λ` from 1, whose stages are
# hand-computable from the tableau; at `λ = NaN` its derivative at the start
# is not a number.
struct Expo <: AbstractComponent
    λ::Float64
end
x_init(::Expo) = 1.0
y_types(::Expo) = Float64
y_state(::Expo, (; x)) = x
x_deriv(c::Expo, (; x)) = c.λ * x

# A state driven from 0 at 1e308 per second while it is finite and below
# 1e300: over a 10 s step the trial overflows to `Inf` while the error
# estimate stays finite.
struct Overflowing <: AbstractComponent end
x_init(::Overflowing) = 0.0
y_types(::Overflowing) = Float64
y_state(::Overflowing, (; x)) = x
x_deriv(::Overflowing, (; x)) = (isfinite(x) && x < 1e300) ? 1e308 : 0.0

# The seam rig under BS3 at a tolerance that subcycles every frame.
adaptive_sim(algorithm = Watched(BS3(reltol = 1e-6, abstol = 1e-9))) =
    Simulation(seam_rig(); Δt_frame = 1//8, Δt_base = 1//32, h_min = 1//2^20, algorithm)

# The controller's two branches, in literals: the integral gain alone without
# history, Gustafsson's proportional-integral pair with it, inside [0.2, 10].
elementary(h, error_ratio) = h * clamp(0.9 * error_ratio^(-1/3), 0.2, 10.0)
proportional_integral(h, error_ratio, last) =
    h * clamp(0.9 * error_ratio^(-0.7/3) * last^(0.4/3), 0.2, 10.0)

function test_adaptive()
    @testset "a recording replayed from a checkpoint taken mid-run, through rejected attempts and sub-step boundaries, publishes the original's snapshots bit for bit (§10.2, §12.6, §12.7, D-452, D-461)" begin
        # Frames of 1/8 s over a counter due every 3/32 s: each frame subcycles
        # under the tolerance, and a reference stepped at a frame top makes
        # the next attempts fail their error test.
        original = adaptive_sim()
        init!(original, set(u = (ref = 0.7,)))
        step!(original; frames = 3)
        stage!(original, "ref" => 1.0)
        step!(original; frames = 3)
        cp = checkpoint(original)
        @test cp.state.stepper isa Tuple{Float64,Float64} && isfinite(cp.state.stepper[1])
        attempts_at_cp = length(original.model.exec.stepper.attempts)
        feed!(sim) = (stage!(sim, "ref" => -0.4); step!(sim; frames = 2);
                      stage!(sim, "ref" => 0.2); step!(sim; frames = 3))
        feed!(original)
        after = original.model.exec.stepper.attempts[(attempts_at_cp + 1):end]
        @test any(attempt -> !attempt[3], after)                       # rejected attempts
        # Restored from the checkpoint and fed the same, the run is the original's,
        # from the restore's own publication at the checkpoint's clock.
        resumed = adaptive_sim()
        restore!(resumed, cp)
        feed!(resumed)
        from_cp = filter(s -> s.boundary ≥ first(logged(resumed)).boundary, logged(original))
        @test first(from_cp).t === cp.state.t
        @test length(from_cp) > 2 * 5 + 1                               # sub-step boundaries
        @test any(s -> s.t == 27/32, from_cp)                          # a due instant inside a frame
        @test same_snapshots(logged(resumed), from_cp)
        @test resumed.model.exec.stepper.attempts == after
        # Its recording, whose header is the checkpoint, replays bit for bit.
        replayed = adaptive_sim()
        replay!(replayed, trace(resumed))
        @test same_snapshots(logged(replayed), logged(resumed))
        @test state(replayed, "plant").q === state(original, "plant").q
    end

    @testset "order of convergence on a known solution: 3 under equal steps, and the error proportional to the tolerance under the integral gain alone (§10.2, D-461)" begin
        ω, ζ, k, r = 2.0, 0.1, 4.0, 0.7
        A = SMatrix{2,2}(0.0, -ω^2, 1.0, -2ζ * ω)
        B = SVector(0.0, 1.0)
        Acl = A - B * k * SVector(1.0, 0.0)'
        exact(t) = exp(Acl * t) * (Acl \ (B * k * r)) - Acl \ (B * k * r)
        # Tolerances no error reaches accept every attempt, and the growth
        # limit holds every proposal above the bound, so each frame is one
        # step: the method's own order.
        function stepped_error(h)
            sim = Simulation(feedback_model(; k, ω, ζ); Δt_frame = h, h_min = 1//10^6,
                             algorithm = BS3(reltol = 1e6, abstol = 1e6))
            init!(sim, set(u = (ref = r,)))
            run!(sim; t_end = 2.0)
            @test length(logged(sim)) == 2 / h + 1
            norm(state(sim, "plant").q - exact(2.0))
        end
        errs = [stepped_error(h) for h in (1//10, 1//20, 1//40, 1//80)]
        @test all(o -> abs(o - 3) < 0.25, [log2(errs[i] / errs[i+1]) for i in 1:3])
        # The integral gain alone: every step taken after a notice, which
        # clears the controller's history. The error estimate is third order
        # in the step and the solution's local error fourth, so the global
        # error goes as the tolerance.
        function controlled_error(tol)
            model = Model(feedback_model(; k, ω, ζ); Δt_frame = 4, h_min = 1//10^9,
                          algorithm = BS3(reltol = tol, abstol = tol))
            init!(model, set(u = (ref = r,)))
            while model.exec.clock.t < 2.0
                discontinuity!(model.exec.stepper)
                integrate!(model, min(propose(model.exec.stepper), 0.25, 2.0 - model.exec.clock.t))
            end
            norm(state(model, "plant").q - exact(2.0))
        end
        tols = (1e-4, 1e-5, 1e-6, 1e-7, 1e-8)
        errs = [controlled_error(tol) for tol in tols]
        @test all(s -> abs(s - 1) < 0.1, [log10(errs[i] / errs[i+1]) for i in 1:4])
        @test all(errs[i] < 20 * tols[i] for i in eachindex(tols))
    end

    @testset "the attempt loop allocates nothing, rejections included, at Float64 and at LinearizeDual (§9.8, D-461)" begin
        for T in (Float64, LinearizeDual)
            deployed() = Model(seam_rig(), T; Δt_frame = 1//8, Δt_base = 1//32, h_min = 1//2^20,
                               algorithm = BS3(reltol = 1e-6, abstol = 1e-9))
            # The frame loop over subcycled frames, a due instant inside each.
            model = deployed()
            init!(model, set(u = (ref = T(0.7),)))
            frames!(model, 2)
            k = Ref(3)
            @test @ballocated(frame!($model, k), setup = (k = $k[]; $k[] += 1), evals = 1) == 0
            # One attempt the tolerance refuses and one it admits, and the bare
            # step offered too much, which retries.
            model = deployed()
            init!(model, set(u = (ref = T(0.7),)))
            stepper = model.exec.stepper
            h_long, h_short = T(1//8), T(1//1024)
            @test !attempt!(stepper, model, h_long) && attempt!(stepper, model, h_short)
            @test @ballocated(attempt!($stepper, $model, $h_long)) == 0
            @test @ballocated(attempt!($stepper, $model, $h_short)) == 0
            @test @ballocated(integrate!($model, $h_long)) == 0
        end
    end

    @testset "a handler's reset raises the notice, and the step after it is controlled by the integral gain alone (§10.2, D-452, D-461)" begin
        sim = Simulation(single(Recharger()); Δt_frame = 1//4, h_min = 1//2^20,
                         algorithm = Watched(BS3(reltol = 1e-6, abstol = 1e-9)))
        init!(sim)
        run!(sim; t_end = 3.0)
        @test modes(sim, "c").count == 3
        attempts = sim.model.exec.stepper.attempts
        accepted = [a for a in attempts if a[3] && a[5] > 1e-4]
        # The first attempt is rejected, and from a zero state the starting
        # bound is 1 / (1 / 1e-3 / (0.8 · 1e-6^(1/3))) = 8e-6 s. That step's
        # error falls below the memory floor, so it is left out above.
        @test attempts[1][2:3] == (0.25, false) && isapprox(attempts[1][6], 8e-6; rtol = 1e-12)
        @test attempts[2][2:3] == (8e-6, true) && attempts[2][5] == 1e-4
        # The step after each reset has no history: each proposes by the
        # integral gain alone.
        after_notice = [a for a in accepted if a[4] == 0.0]
        @test length(after_notice) == 3
        @test all(a -> a[6] ≈ elementary(a[2], a[5]), after_notice)
        # Every other accepted step proposes from its error and the last one's.
        with_history = [a for a in accepted if a[4] > 0.0]
        @test length(with_history) > 10
        @test all(a -> a[6] ≈ proportional_integral(a[2], a[5], a[4]), with_history)
        # A rejection shrinks by the integral gain alone and keeps the history.
        rejected = [a for a in attempts if !a[3]]
        @test all(a -> a[5] == a[4], rejected)
        # An exact step grows by the limit, and its error enters the memory at
        # its floor.
        exact = Model(Group((; r = BareRamp())); Δt_frame = 1, h_min = 1//2^20, algorithm = BS3())
        init!(exact)
        @test attempt!(exact.exec.stepper, exact, 0.01)
        @test exact.exec.stepper.proposal == 10 * 0.01 && exact.exec.stepper.memory == 1e-4
    end

    @testset "an attempt's error estimate, its scale max(|xₙ|, |xₙ₊₁|) and its rejection's shrink are the tableau's, in literals (§10.2, D-461)" begin
        # One attempt from x = 1 at h = 1/2 on ẋ = λx, past the starting state,
        # its stages and estimate written from the tableau's literals, the
        # tolerance set so the scaled error is 3/2. Growth puts the larger state
        # at the step's end and decay at its start.
        for λ in (1.0, -1.0)
            h = 0.5
            k1 = λ; k2 = λ * (1 + h / 2 * k1); k3 = λ * (1 + 3h / 4 * k2)
            x1 = 1 + h * (2 / 9 * k1 + 1 / 3 * k2 + 4 / 9 * k3); k4 = λ * x1
            estimate = h * (-5 / 72 * k1 + 1 / 12 * k2 + 1 / 9 * k3 - 1 / 8 * k4)
            reltol = abs(estimate) / (1.5 * max(1.0, abs(x1)))
            model = Model(Group((; e = Expo(λ))); Δt_frame = 1, h_min = 1//2^20,
                          algorithm = BS3(reltol = reltol, abstol = 1e-300))
            init!(model)
            stepper = model.exec.stepper
            restore_stepper!(stepper, (h, 0.0))
            @test !attempt!(stepper, model, h)
            @test model.exec.xnext[1] ≈ x1 rtol = 1e-14
            # The rejection shrinks by the integral gain alone, 0.9 · (3/2)^(-1/3).
            @test stepper.proposal ≈ h * 0.9 * 1.5^(-1/3) rtol = 1e-9
        end
    end

    @testset "a localized event inside a sub-step fires at its crossing, and its t* ends the step under a proposal (§10.4, D-460)" begin
        # Four steps a frame under `h_max = 1//40`; the stamper crosses at 0.315,
        # inside frame 4's first step, on a linear trajectory the method
        # integrates exactly.
        model = Model(stamped(); Δt_frame = 1//10, h_max = 1//40, h_min = 1//2^20,
                      algorithm = BS3())
        init!(model)
        hooks = ClockHooks(model, Float64[])
        foreach(k -> frame!(model, k, hooks), 1:5)
        t★ = modes(model, "s").t_fired
        @test modes(model, "s").count == 1
        @test t★ ≈ 0.315 atol = 1e-6
        # The span's rest from t* is shaped afresh, ⌈0.085 / 0.025⌉ = 4 equal
        # steps, where a fixed-step method would run the remainder to 0.325.
        i = findfirst(==(t★), hooks.clocks)
        @test hooks.clocks[i + 4] == Float64(4//10)
        @test 0.325 ∉ hooks.clocks
        @test all(h -> isapprox(h, (0.4 - t★) / 4; rtol = 1e-12), diff(hooks.clocks[i:(i + 4)]))
    end

    @testset "the floor accepts what the error test refuses, the budget sends a step there, and either warns once a frame (§10.2, Appendix C, D-460)" begin
        # A tolerance no step of at least `h_min` meets: every step is taken at
        # the floor, the first after spending a budget of one attempt. The
        # starting bound would send a second attempt to the floor in any case.
        sim = Simulation(feedback_model(); Δt_frame = 1//10, h_min = 1//100, attempt_budget = 1,
                         algorithm = Watched(BS3(reltol = 1e-12, abstol = 1e-12)))
        init!(sim, set(u = (ref = 0.7,)))
        @test_logs (:warn, r"^StepFloor from loop, past the final snapshot's account") run!(sim; t_end = 0.5)
        attempts = sim.model.exec.stepper.attempts
        @test !any(a -> a[3], attempts)                       # the backend accepted none
        steps = [count(a -> a[1] == t, attempts) for t in unique(a[1] for a in attempts)]
        @test length(steps) == 50 && maximum(steps) == 1 + 1 && all(==(1), steps[2:end])
        reports = [only(writer_status(s, "loop").recent) for s in logged(sim)
                   if !isempty(writer_status(s, "loop").recent)]
        @test length(reports) == 4                             # frames 1 to 4, folded at the next top
        @test reports[1] == StepFloor(0.0, 0.01, 0.01, 1, :budget)
        @test all(d -> d.reason === :rejected && d.attempts == 1 && d.h_min == 0.01, reports[2:end])
        @test [d.t for d in reports[2:end]] == [0.1, 0.2, 0.3]
        @test writer_status(latest(sim), "loop").totals.step_floor == 4
    end

    @testset "a nonfinite error estimate is a rejection at the strongest shrink, and only the floor's acceptance throws NonfiniteState (§10.2, §13.4, D-460, D-461)" begin
        sim = Simulation(single(Cliff()); Δt_frame = 2, h_min = 1//1000, algorithm = Watched())
        init!(sim)
        err = @test_logs (:warn, r"^StepFloor") failure(() -> run!(sim; t_end = 4.0))
        @test err isa StepError{NonfiniteState} && err.cause.path == "c"
        attempts = sim.model.exec.stepper.attempts
        # The first attempt crosses the cliff, and the retry is the starting
        # bound: over a scale of 1 at a rate of 1, 0.8 · 1e-3^(1/3) = 0.08 s.
        @test attempts[1][1:3] == (0.0, 2.0, false) && attempts[2][1:3] == (0.0, 0.08, true)
        @test isapprox(attempts[1][6], 0.08; rtol = 1e-12)
        # The trajectory is linear, so every later rejection is an overshoot
        # whose estimate is not finite, and each retries at a fifth.
        overshoots = filter(a -> !a[3], attempts[2:end])
        @test length(overshoots) ≥ 3 && all(a -> a[6] == 0.2 * a[2], overshoots)
        # Overshoots recover until the state reaches the cliff, then the floor
        # takes a step the backend rejected, and the trial is checked.
        @test count(a -> a[3], attempts) ≥ 5
        @test !attempts[end][3] && attempts[end][2] < 2 * 0.001
        @test all(a -> !isnan(a[6]), attempts)
        # A trial that overflows to `Inf` under a finite estimate is a rejection
        # too: its scale max(|xₙ|, |xₙ₊₁|) is infinite, so the norm alone would
        # pass it. The attempt runs past the starting state.
        model = Model(single(Overflowing()); Δt_frame = 10, h_min = 1//1000, algorithm = BS3())
        init!(model)
        stepper = model.exec.stepper
        restore_stepper!(stepper, (10.0, 0.0))
        @test !attempt!(stepper, model, 10.0)
        @test model.exec.xnext[1] == Inf && stepper.proposal == 0.2 * 10.0
    end

    @testset "a rejected first attempt proposes at most the starting bound, from its first stage, and a vanishing derivative or one that is not a number gives none (§10.2, D-461)" begin
        # Kepler at a 2 s frame. The scale is `max(|xᵢ|, abstol/reltol)`, here
        # 1e-3 for the acceleration's component, so the rate is 25 / 1e-3, and
        # the bound 1 / (25e3 / (0.8 · 1e-6^(1/3))) = 3.2e-7 s.
        sim = Simulation(single(Kepler()); Δt_frame = 2, h_min = 1//2^40,
                         algorithm = Watched(BS3(reltol = 1e-6, abstol = 1e-9)))
        init!(sim)
        @test_logs min_level = Base.CoreLogging.Warn run!(sim; t_end = 2.0)
        @test writer_status(latest(sim), "loop").totals.step_floor == 0
        attempts = sim.model.exec.stepper.attempts
        @test attempts[1][2:3] == (2.0, false) && isapprox(attempts[1][6], 3.2e-7; rtol = 1e-12)
        @test attempts[2][3]                                  # the bounded step passes
        # A lag driven from rest by a sine starts with no derivative: the
        # rejection shrinks by the error alone, at least to a fifth.
        lag = Group((; src = Source(t -> sin(3t)), lag = FirstOrderLag(τ = 0.3));
                    local_wires = ("src/y" => "lag/u",))
        sim = Simulation(lag; Δt_frame = 2, h_min = 1//2^20,
                         algorithm = Watched(BS3(reltol = 1e-6, abstol = 1e-9)))
        init!(sim)
        step!(sim)
        attempts = sim.model.exec.stepper.attempts
        @test attempts[1][2:3] == (2.0, false) && attempts[1][6] ≥ 0.2 * 2.0
        # A derivative that is not a number at the start gives none either: the
        # retries shrink to the floor, whose acceptance throws NonfiniteState,
        # and no proposal is `NaN`.
        model = Model(Group((; e = Expo(NaN))); Δt_frame = 1, h_min = 1//1000,
                      algorithm = Watched())
        init!(model)
        err = failure(() -> frame!(model, 1))
        @test err isa StepError{NonfiniteState} && err.cause.path == "e"
        @test all(a -> !isnan(a[6]), model.exec.stepper.attempts)
    end

    @testset "a Dual run takes the steps the Float64 run takes, the error over the values alone (§9.4, §14.10, D-461)" begin
        clocks = map((Float64, D8)) do T
            model = Model(seam_rig(), T; Δt_frame = 1//8, Δt_base = 1//32, h_min = 1//2^20,
                          algorithm = BS3(reltol = 1e-6, abstol = 1e-9))
            ref = T === Float64 ? 0.7 : D8(0.7, ForwardDiff.Partials(ntuple(i -> 1e3 * i, 8)))
            init!(model, set(u = (ref = ref,)))
            hooks = ClockHooks(model, Float64[])
            foreach(k -> frame!(model, k, hooks), 1:6)
            T === Float64 || @test ForwardDiff.partials(state(model, "plant").q[1])[8] != 0
            hooks.clocks
        end
        @test length(clocks[1]) > 6 * 3 && clocks[1] == clocks[2]
    end

    @testset "projection raises no notice: the controller keeps its history across a projecting boundary (§10.2, D-452, D-460)" begin
        sim = Simulation(single(Rotor(; ω = 3.0)); Δt_frame = 1//2, h_min = 1//2^20,
                         algorithm = Watched(BS3(reltol = 1e-6, abstol = 1e-9)))
        init!(sim)
        run!(sim; t_end = 2.0)
        accepted = [a for a in sim.model.exec.stepper.attempts if a[3]]
        @test length(accepted) > 10
        @test accepted[1][4] == 0.0 && all(a -> a[4] > 0.0, accepted[2:end])
    end

    @testset "the checkpoint carries the proposal and the controller's memory, and init! puts both back as bound (§10.2, §12.6, D-452)" begin
        sim = adaptive_sim()
        init!(sim, set(u = (ref = 0.7,)))
        @test trace(sim).header.state.stepper === (Inf, 0.0)
        step!(sim; frames = 3)
        stepper = sim.model.exec.stepper.inner
        @test checkpoint(sim).state.stepper === (stepper.proposal, stepper.memory)
        @test isfinite(stepper.proposal)
        @test stepper.memory == 0.0          # the counter's tick at 3/8 cleared the history
        again = adaptive_sim()
        init!(again, set(u = (ref = 0.7,)))
        step!(again; frames = 2)
        init!(again, set(u = (ref = 0.7,)))
        @test trace(again).header.state.stepper === (Inf, 0.0)
        step!(again; frames = 3)
        @test same_snapshots(logged(again), logged(sim))
    end

    @testset "the shaping rule: equal division to the next mandatory instant, clamped into [h_min, h_max], the count capped at the floor (§10.2, §10.5, D-460)" begin
        model = Model(Group((; r = BareRamp())); Δt_frame = 1, h_max = 1//2, h_min = 1//10,
                      algorithm = BS3())
        init!(model)
        # ⌈1/0.3⌉ = 4 steps of a quarter; a proposal past the bound is the bound.
        @test _shaped(model, 0.3, 0.0, 1.0) == 0.25
        @test _shaped(model, Inf, 0.0, 1.0) == 0.5 && _shaped(model, 7.0, 0.0, 0.9) == 0.45
        # A proposal below the floor is the floor: ⌈1/0.1⌉ = 10.
        @test _shaped(model, 0.01, 0.0, 1.0) == 0.1 && _shaped(model, -1.0, 0.0, 1.0) == 0.1
        # The cap lengthens a step past its proposal: ⌈0.25/0.1⌉ = 3, capped at
        # ⌊0.25/0.1⌋ = 2, steps of 0.125; that attempt is the floor's.
        @test _shaped(model, 0.1, 0.0, 0.25) == 0.125 && _at_floor(model, 0.125, 0.0, 0.25)
        @test !_at_floor(model, 0.25, 0.0, 1.0)
        # A distance shorter than the floor is one step.
        @test _shaped(model, 0.3, 0.0, 0.05) == 0.05 && _at_floor(model, 0.05, 0.0, 0.05)
        # A constant proposal that divides the distance takes its count, from
        # an interior clock whose distance rounds a hair above it.
        @test _shaped(model, 0.2, 0.2, 0.8) ≈ 0.2 && (0.8 - 0.2) / 0.2 > 3
        # Not a number is the backend's bug.
        err = failure(() -> _shaped(model, NaN, 0.0, 1.0))
        @test err isa InternalInvariant
    end

    @testset "a floor at half the bound keeps every step within h_max: a tolerance no step meets takes the floor's count, one every step meets the bound's, and a t* leaves one step longer than the floor (§9.2, §10.2, D-463)" begin
        # Frames of 3 ms under a bound of 2 ms and a floor of 1 ms, over a reset
        # at ln 2.5 s, inside frame 306. A floor at the bound, which the door
        # refuses, took one step of 3 ms a frame.
        h_max, h_min = 1//500, 1//1000
        function steps_by_frame(algorithm)
            model = Model(single(Recharger()); Δt_frame = 3//1000, h_max, h_min, algorithm)
            init!(model)
            hooks = ClockHooks(model, Float64[])
            steps = map(1:310) do k
                n = length(hooks.clocks)
                frame!(model, k, hooks)
                diff([n == 0 ? 0.0 : hooks.clocks[n]; hooks.clocks[(n + 1):end]])
            end
            @test modes(model, "c").count == 1
            steps
        end
        quiet(steps) = steps[setdiff(1:310, 306)]
        # A tolerance no step meets lifts every proposal to the floor: a quiet
        # frame takes the floor's count, ⌊3/1⌋ = 3 steps of 1 ms. The reset
        # leaves 1.71 ms to its frame's end, one step longer than the floor.
        tight = steps_by_frame(BS3(reltol = 1e-15, abstol = 1e-15))
        @test all(f -> length(f) == 3 && all(h -> isapprox(h, 1e-3; atol = 1e-15), f), quiet(tight))
        @test maximum(reduce(vcat, tight)) ≤ Float64(h_max)
        @test any(h -> 1.5 * Float64(h_min) < h ≤ Float64(h_max), tight[306])
        # Under the default tolerance a quiet frame's proposal passes the bound,
        # whose count ⌈3/2⌉ = 2 is below the floor's: two steps of 1.5 ms.
        loose = steps_by_frame(BS3())
        @test all(f -> length(f) == 2 && all(h -> isapprox(h, 1.5e-3; atol = 1e-15), f), quiet(loose))
        @test maximum(reduce(vcat, loose)) ≤ Float64(h_max)
    end

    @testset "h_min and attempt_budget are deployment parameters: h_min required by a proposing method and refused above half h_max, both compared, hashed and named (§9.2, §12.7, Appendix C, D-460, D-462, D-463)" begin
        feedback_build = build(feedback_model())
        refused(; kw...) = diagnostics(failure(() -> Deployment(feedback_build; Δt_frame = 1//100, kw...)))
        d = only(refused(algorithm = BS3()))
        @test d isa DeploymentInvalid && d.parameter === :h_min && d.reason === :missing
        d = only(refused(algorithm = BS3(), h_min = 1e-6))
        @test d.parameter === :h_min && d.reason === :inexact
        for bad in (0, -1//10^6, 1//0)
            d = only(refused(algorithm = BS3(), h_min = bad))
            @test d.parameter === :h_min && d.reason === :range && d.value == bad
        end
        d = only(refused(algorithm = BS3(), h_max = 1//400, h_min = 1//200))
        @test d.parameter === :h_min && d.reason === :range && d.value === 1//200 &&
              d.related === 1//400
        # A floor above half the bound is refused, the bound itself included,
        # and one at half the bound is admitted.
        d = only(refused(algorithm = BS3(), h_max = 1//400, h_min = 1//400))
        @test d.parameter === :h_min && d.reason === :range && d.value === 1//400 &&
              d.related === 1//400
        @test Deployment(feedback_build; Δt_frame = 1//100, h_max = 1//400, h_min = 1//800,
                         algorithm = BS3()).h_min === 1//800
        # The half is exact where `Rational{Int}` cannot hold it, an odd
        # numerator over a denominator past 2^62.
        odd_bound = 3 // (2^62 + 1)
        @test Deployment(feedback_build; Δt_frame = 1//100, h_max = odd_bound,
                         h_min = 1 // (2^62 + 1), algorithm = BS3()).h_min === 1 // (2^62 + 1)
        d = only(refused(algorithm = BS3(), h_max = odd_bound, h_min = 2 // (2^62 + 1)))
        @test d.parameter === :h_min && d.reason === :range && d.related === odd_bound
        for bad in (0, 1.5, "2")
            d = only(refused(algorithm = BS3(), h_min = 1//10^6, attempt_budget = bad))
            @test d.parameter === :attempt_budget && d.reason === :range
        end
        # A fixed-step method leaves the floor unused, and the value still compares.
        plain = Deployment(feedback_build; Δt_frame = 1//100)
        @test plain.h_min === nothing && plain.attempt_budget == 7
        floored = Deployment(feedback_build; Δt_frame = 1//100, h_min = 1//10^6)
        @test floored != plain && hash(floored) != hash(plain)
        adaptive(; kw...) = Deployment(feedback_build; Δt_frame = 1//100, h_min = 1//10^6,
                                       algorithm = BS3(), kw...)
        @test adaptive() == adaptive() && hash(adaptive()) == hash(adaptive())
        for other in (adaptive(attempt_budget = 3), adaptive(h_min = 1//10^5),
                      adaptive(algorithm = BS3(reltol = 1e-4)), adaptive(algorithm = BS3(abstol = 1e-9)))
            @test other != adaptive() && hash(other) != hash(adaptive())
        end
        # The token refuses a tolerance that is not positive and finite.
        for (kw, argument) in (((; reltol = 0), :reltol), ((; abstol = -1e-6), :abstol),
                               ((; reltol = Inf), :reltol))
            d = only(diagnostics(failure(() -> BS3(; kw...))))
            @test d isa ArgumentInvalid && d.call === :BS3 && d.argument === argument
        end
        @test repr(BS3()) == "BS3(reltol = 0.001, abstol = 1.0e-6)" && proposes(BS3()) &&
              !proposes(RK4()) && !proposes(Heun())
        # Replay names what differs: a tolerance by its field, another method
        # whole, the floor and the budget by name.
        recorded = adaptive_sim(BS3(reltol = 1e-6, abstol = 1e-9))
        init!(recorded, set(u = (ref = 0.7,)))
        step!(recorded; frames = 2)
        trc = trace(recorded)
        mismatch(; kw...) = diagnostics(failure(() -> _compile_feed(
            Simulation(seam_rig(); merge((; Δt_frame = 1//8, Δt_base = 1//32, h_min = 1//2^20,
                                          algorithm = BS3(reltol = 1e-6, abstol = 1e-9)), kw)...),
            trc)))
        d = only(mismatch(algorithm = BS3(reltol = 1e-5, abstol = 1e-9)))
        @test d isa CheckpointMismatch && d.what === :deployment &&
              d.name === Symbol("algorithm.reltol") && d.expected == 1e-6 && d.found == 1e-5
        @test Set(d.name for d in mismatch(algorithm = BS3())) ==
              Set([Symbol("algorithm.reltol"), Symbol("algorithm.abstol")])
        d = only(mismatch(algorithm = RK4()))
        @test d.name === :algorithm && d.found == RK4()
        d = only(mismatch(h_min = 1//2^10))
        @test d.name === :h_min && d.expected === 1//2^20 && d.found === 1//2^10
        d = only(mismatch(attempt_budget = 3))
        @test d.name === :attempt_budget && d.expected == 7 && d.found == 3
    end

    @testset "the floor enters the clock's resolution: a run whose clock cannot resolve h_min is refused at its doors (§10.5, D-450, D-460)" begin
        # At a 10 ms frame a floor of 1e-17 s resolves no frame from t₀ = 0,
        # while the same deployment under RK4, whose floor is unused, does.
        rig = feedback_model()
        adaptive = Model(rig; Δt_frame = 1//100, h_min = 1//10^17, algorithm = BS3())
        err = failure(() -> init!(adaptive, set(u = (ref = 0.7,))))
        @test err isa DiagnosticError && diagnostic(err) isa ArgumentInvalid &&
              diagnostic(err).argument === :t0
        fixed = Model(rig; Δt_frame = 1//100, h_min = 1//10^17)
        init!(fixed, set(u = (ref = 0.7,)))
        @test fixed.deployment.lattice.reach > adaptive.deployment.lattice.reach ==
              exp2(50) * 1e-17
        # A unit finer than the floor is the least gap: frames of 1/8 s and a
        # base tick of 3/320 s meet on 1/320 s, below the floor of 1/200 s.
        @test Deployment(build(seam_rig()); Δt_frame = 1//8, Δt_base = 3//320, h_min = 1//200,
                         algorithm = BS3()).lattice.reach == exp2(50) * Float64(1//320)
    end

    @testset "show(deployment) prints the floor, the budget and the proposed range of steps per frame (§9.2, D-460)" begin
        deployment = Deployment(build(feedback_model()); Δt_frame = 1//100, h_max = 1//400,
                                h_min = 1//10^5, algorithm = BS3())
        text = sprint(show, MIME"text/plain"(), deployment)
        @test startswith(text, "Deployment: Δt_frame = 1//100, Δt_base = 1//100, " *
                               "h_max = 1//400, h_min = 1//100000, " *
                               "BS3(reltol = 0.001, abstol = 1.0e-6); firing_budget = 4, " *
                               "localization_tol = 1.0e-6, localization_budget = 8, " *
                               "attempt_budget = 7\n  steps per frame: 4 to 1000, as proposed\n")
        @test sprint(show, deployment) == "Deployment(Δt_frame = 1//100, Δt_base = 1//100, " *
                                          "h_max = 1//400, h_min = 1//100000, " *
                                          "BS3(reltol = 0.001, abstol = 1.0e-6))"
    end
end

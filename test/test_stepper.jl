# --- the stepper seam (§10.2, increment 8) --------------------------------------
# Interchangeability is the claim under test: the loop, the localization
# machinery and the deployment surface are method-blind, and the two backends
# differ exactly where their orders say they must.

# The bouncer beside a stop request that never holds: one honoured requester,
# scanned at every publication.
requested_bouncer() = Group((; b = Bouncer(1.0, 0.07), r = requested(false, "never")))

# A backend that rejects on a schedule (§10.2, D-452): Heun's method through the
# seam's protocol, proposing a standing length `h`. It rejects the attempts whose
# ordinals over the run `rejected` lists, and every `every`-th one, and proposes
# `factor` times a rejected length for the retry; after an acceptance it proposes
# `h` again. Its stages write the state buffer and the clock, so a rejection
# leaves real scratch for the Model to discard, and under `poison` it fills a
# rejected trial with `NaN`. It fills the accepted trial of attempt `spoil` with
# `Inf`. It carries its proposal and its attempt count
# across a frame top, so a restore that dropped them would move the schedule.
# Under `record` it keeps the clock and the state each attempt found at its
# start, each accepted length, and the attempt count at which each
# discontinuity notice arrived, and it throws past 10 000 attempts, so a loop
# that never ends fails its test where it would fill the memory.
struct Scheduled{N} <: AbstractAlgorithm
    h::Float64
    rejected::NTuple{N,Int}
    every::Int
    factor::Float64
    poison::Bool
    spoil::Int
    record::Bool
end
Scheduled(h; rejected = (), every = 0, factor = 1.0, poison = false, spoil = 0, record = true) =
    Scheduled(h, rejected, every, factor, poison, spoil, record)

mutable struct ScheduledStepper{T,N} <: AbstractStepper
    const algorithm::Scheduled{N}
    const x₀::Vector{T}
    const k₁::Vector{T}
    const k₂::Vector{T}
    proposal::Float64
    attempts::Int
    const starts::Vector{Tuple{Float64,Vector{T}}}
    const lengths::Vector{Float64}
    const notices::Vector{Int}
end
bind_stepper(algorithm::Scheduled{N}, ::Type{T}, n_x::Int) where {T,N} =
    ScheduledStepper{T,N}(algorithm, zeros(T, n_x), zeros(T, n_x), zeros(T, n_x), algorithm.h, 0,
                        Tuple{Float64,Vector{T}}[], Float64[], Int[])
propose(stepper::ScheduledStepper) = stepper.proposal
discontinuity!(stepper::ScheduledStepper) =
    (stepper.algorithm.record && push!(stepper.notices, stepper.attempts); nothing)
startpoint(stepper::ScheduledStepper) = (stepper.x₀, stepper.k₁)
checkpoint_stepper(stepper::ScheduledStepper) = (stepper.proposal, stepper.attempts)
restore_stepper!(stepper::ScheduledStepper, (proposal, attempts)::Tuple{Float64,Int}) =
    (stepper.proposal = proposal; stepper.attempts = attempts; nothing)
reset_stepper!(stepper::ScheduledStepper) =
    (stepper.proposal = stepper.algorithm.h; stepper.attempts = 0; nothing)
function attempt!(stepper::ScheduledStepper, model::Model, h)
    exec, algorithm = model.exec, stepper.algorithm
    x, ẋ, (; x₀, k₁, k₂) = exec.xbuf, exec.ẋbuf, stepper
    t = exec.clock.t
    ordinal = (stepper.attempts += 1)
    algorithm.record && ordinal > 10_000 && error("the scheduled stub ran past 10 000 attempts")
    algorithm.record && push!(stepper.starts, (ForwardDiff.value(t), copy(x)))
    copyto!(x₀, x)
    evaluate!(model); copyto!(k₁, ẋ)
    x .= x₀ .+ h .* k₁; exec.clock.t = t + h
    evaluate!(model); copyto!(k₂, ẋ)
    exec.xnext .= x₀ .+ (h / 2) .* (k₁ .+ k₂)
    if ordinal in algorithm.rejected || (algorithm.every > 0 && ordinal % algorithm.every == 0)
        algorithm.poison && fill!(exec.xnext, NaN)
        stepper.proposal = algorithm.factor * ForwardDiff.value(h)
        return false
    end
    ordinal == algorithm.spoil && fill!(exec.xnext, Inf)
    algorithm.record && push!(stepper.lengths, ForwardDiff.value(h))
    stepper.proposal = algorithm.h
    true
end

# The closed loop beside a counter due at 3/32 s, off the 1/8 s frame tops: the
# plant's derivative reads a cell the sweep computes from its state, and every
# period is dyadic, so a clock written as the clock plus a length is exact.
seam_rig() = Group((plant = Plant(), ctl = Gain(4.0), sum = Sum(), a = TickCounter());
                   local_wires = ("ctl/out" => "plant/u", "sum/e" => "ctl/e",
                                  "plant/y" => "sum/b"),
                   input_wires = "ref" => "sum/a",
                   sample_times = (; a = Absolute(Period(3//32))))
seam_sim(algorithm) = Simulation(seam_rig(); Δt_frame = 1//8, Δt_base = 1//32, algorithm)

# A sawtooth whose stamper crosses inside a step, and whose own wrap does too: a
# model with localized events.
stamped() = Group((; src = Sawtooth(1.0), s = Stamper(0.315)); local_wires = ("src/q" => "s/sig",))

function test_stepper()
    @testset "the method is a deployment binding by instance, RK4() the default (§10.2, D-442, D-449)" begin
        sim = Simulation(feedback_model(); Δt_frame = 1//100)
        @test sim.model.exec.stepper isa RK4Stepper{Float64}
        heun_sim = Simulation(feedback_model(); Δt_frame = 1//100, algorithm = Heun())
        @test heun_sim.model.exec.stepper isa HeunStepper{Float64}
        @test sim.model.deployment.algorithm == RK4() && heun_sim.model.deployment.algorithm == Heun()
        @test sim.model.deployment != heun_sim.model.deployment
        # A token carries no step: the bound is the deployment's `h_max` (D-449).
        @test_throws MethodError RK4(1//100)
        @test_throws MethodError Heun(1//100)
        # validated with its siblings: anything but a token is refused at binding,
        # the type form included, not deep in a MethodError
        for bad in (4, Int, RK4, Heun)
            d = only(diagnostics(failure(() ->
                Simulation(feedback_model(); Δt_frame = 1//100, algorithm = bad))))
            @test d isa DeploymentInvalid && d.parameter === :algorithm &&
                  d.reason === :range && d.value === bad
        end
        # The token prints as it is spelled, so a header reads alike from any module.
        @test repr(RK4()) == "RK4()" && repr(Heun()) == "Heun()"
    end

    @testset "h_max bounds the step, divides nothing, and is recorded resolved against the frame (§9.2, §10.5, D-449)" begin
        feedback_build = build(feedback_model())
        multirate_build = build(MultiRate())   # discrete work: three rows
        refused(; kw...) = diagnostics(failure(() -> Deployment(multirate_build; kw...)))
        # No bound, a bound at the frame and one above it are one trajectory, so
        # they deploy as one value, the bound resolved to the frame.
        unbounded = Deployment(feedback_build; Δt_frame = 1//100)
        for spelled in (Deployment(feedback_build; Δt_frame = Hz(100), h_max = 1//100),
                        Deployment(feedback_build; Δt_frame = 1//100, h_max = Period(1//50)),
                        Deployment(feedback_build; Δt_frame = 1//100, h_max = 7))
            @test spelled == unbounded && hash(spelled) == hash(unbounded)
            @test spelled.h_max === unbounded.h_max === 0.01
        end
        # A bound below the frame is a different deployment, in every spelling.
        bounded = Deployment(feedback_build; Δt_frame = 1//100, h_max = Hz(400))
        @test bounded.h_max === Float64(1//400) && bounded != unbounded &&
              bounded == Deployment(feedback_build; Δt_frame = 1//100, h_max = 1//400)
        # A bound need divide nothing: with discrete work, `Δt_frame = 1//500`,
        # `Δt_base = 1//300` and `h_max = 3//2000` deploy, the bound a ratio of
        # the unit `gcd(1//500, 1//300) = 1//1500`.
        deployment = Deployment(multirate_build; Δt_frame = 1//500, Δt_base = 1//300,
                                h_max = 3//2000)
        @test (deployment.lattice.frame, deployment.lattice.base, deployment.lattice.bound) ==
              (3, 5, 9//4)
        # `h_max` is a premise of its own, exact, positive and finite.
        d = only(refused(Δt_frame = 1//500, h_max = 0.001))
        @test d isa DeploymentInvalid && d.parameter === :h_max && d.reason === :inexact &&
              d.value === 0.001
        for bad in (0, -1//500, 1//0)
            d = only(refused(Δt_frame = 1//500, h_max = bad))
            @test d.parameter === :h_max && d.reason === :range && d.value == bad
        end
        d = only(refused(Δt_frame = 1//500, h_max = "1//1000"))
        @test d.parameter === :h_max && d.reason === :not_a_quantity
        # `Δt_base` is a premise of its own, positive and finite (D-445).
        for bad in (0, -1//300, 1//0)
            d = only(refused(Δt_frame = 1//500, Δt_base = bad))
            @test d.parameter === :Δt_base && d.reason === :range && d.value == bad
        end
        # Every check whose premise holds runs (D-229): a bound's fault skips
        # nothing, since the anchor loop reads `Δt_base` alone.
        @test Set((d.parameter, d.reason)
                  for d in refused(Δt_frame = 1//500, Δt_base = 3//250, h_max = 0)) ==
              Set([(:h_max, :range), (:Δt_base, :anchor_period)])
    end

    @testset "convergence order: each backend is itself — 4 and 2 (§10.2)" begin
        # The sharp form of the interchangeability claim: same model, same loop,
        # same reference, and the fitted order is the method's own. A mislabeled
        # backend cannot sit in both bands, where a shared loose tolerance would
        # let it hide.
        ω, ζ, k, r = 2.0, 0.1, 4.0, 0.7
        A = SMatrix{2,2}(0.0, -ω^2, 1.0, -2ζ * ω)
        B = SVector(0.0, 1.0)
        Acl = A - B * k * SVector(1.0, 0.0)'
        exact(t) = exp(Acl * t) * (Acl \ (B * k * r)) - Acl \ (B * k * r)
        function final_error(algorithm, h)
            sim = Simulation(feedback_model(; k, ω, ζ); Δt_frame = h, algorithm)
            init!(sim, set(u = (ref = r,)))
            run!(sim; t_end = 2.0)
            norm(state(sim, "plant").q - exact(2.0))
        end
        hs = (1//10, 1//20, 1//40, 1//80)   # errors 5e-8..2e-4: well above float noise
        for (algorithm, p) in ((RK4(), 4.0), (Heun(), 2.0))
            errs = [final_error(algorithm, h) for h in hs]
            orders = [log2(errs[i] / errs[i+1]) for i in 1:3]
            @test all(o -> abs(o - p) < 0.3, orders)
        end
    end

    @testset "localization is seam-generic: t* under Heun (§10.2, §10.4)" begin
        # Linear trajectory: Heun and the Hermite are both exact, so the stamp is
        # method-independent down to the bracket width — the machinery, not the
        # method, sets the error.
        model = Group((; src = Sawtooth(1.0), s = Stamper(0.315));
                      local_wires = ("src/q" => "s/sig",))
        sim = Simulation(model; Δt_frame = 1//10, algorithm = Heun())
        init!(sim)
        run!(sim; t_end = 0.5)
        @test modes(sim, "s").count == 1
        @test modes(sim, "s").t_fired ≈ 0.315 atol = 1e-6

        # Nonlinear trajectory: the stamp error is now the discrete solution's
        # O(h²), not RK4's O(h⁴) — quartering under h-halving is the method
        # showing through the same machinery. (Boundary-resolution firing would
        # sit at ~h and shrink linearly instead.)
        stamp_error(h) = begin
            rotor_model = Group((; src = Rotor(; ω = 1.0, r₀ = SVector(-1.0, 0.0)), s = Stamper(-0.5));
                                local_wires = ("src/c" => "s/sig",))
            rotor_sim = Simulation(rotor_model; Δt_frame = h, algorithm = Heun())
            init!(rotor_sim)
            run!(rotor_sim; t_end = 1.5)
            @test modes(rotor_sim, "s").count == 1
            abs(modes(rotor_sim, "s").t_fired - π / 3)
        end
        coarse_error, fine_error = stamp_error(1//10), stamp_error(1//40)
        @test coarse_error < 5e-3
        @test 10 < coarse_error / fine_error < 24               # h²: ×16 over two halvings

        # The frame-top claims never depended on the method: an epoch-caused edge
        # falls through to fire at the indexed grid time bitwise under Heun too.
        fed_sim = Simulation(fed(Stamper(0.5), "sig"); Δt_frame = 1//10, algorithm = Heun())
        init!(fed_sim, set(u = (in = 0.0,)))
        step!(fed_sim; t_plus = 0.3)
        stage!(fed_sim, "in" => 1.0)                   # frame 4's drain, at its frame top
        step!(fed_sim; t_plus = 0.3)
        @test modes(fed_sim, "c").t_fired == 4 * fed_sim.model.deployment.Δt_frame
    end

    @testset "gate 4: the second backend holds the §9.8 invariant" begin
        sim = Simulation(feedback_model(); Δt_frame = 1//1000, algorithm = Heun())
        init!(sim, set(u = (ref = 0.0,)))
        integrate!(sim, 1e-3)
        @test @ballocated(integrate!($sim, 1e-3)) == 0
        # The localizing frame allocates exactly its two boundaries' publications,
        # the t* one's and the frame top's — the framework-side carve-out (§9.8,
        # §11.2) — as under RK4 (gate 3).
        bouncer_sim = Simulation(single(Bouncer(1.0, 0.07)); Δt_frame = 1//10, algorithm = Heun())
        init!(bouncer_sim; log = false)
        publish_bytes = @ballocated publish!($bouncer_sim, $(bouncer_sim.plane.roster))
        no_mask = Bool[]                    # the advance's argument (D-260, D-261)
        hooks = LoopHooks(bouncer_sim, bouncer_sim.plane.roster, nothing, no_mask)
        @test @ballocated(frame!($(bouncer_sim.model), 1, $hooks), setup = (init!($bouncer_sim; log = false)), evals = 1) == 2 * publish_bytes
        # One honoured requester adds the scan of its buffer and no allocation
        # (§13.5, D-316).
        requested_sim = Simulation(requested_bouncer(); Δt_frame = 1//10, algorithm = Heun())
        init!(requested_sim; log = false)
        requested_bytes = @ballocated publish!($requested_sim, $(requested_sim.plane.roster))
        honoured_mask = Bool[false]
        requested_hooks = LoopHooks(requested_sim, requested_sim.plane.roster, nothing, honoured_mask)
        @test @ballocated(frame!($(requested_sim.model), 1, $requested_hooks), setup = (init!($requested_sim; log = false)), evals = 1) == 2 * requested_bytes
    end

    @testset "the second backend is generic over the scalar (§7.2)" begin
        dual_model = Model(feedback_model(), D8; Δt_frame = 1//1000, algorithm = Heun())
        init!(dual_model, set(u = (ref = D8(0.7),)))
        frames!(dual_model, 50)                # `run!` to 0.05
        @test state(dual_model, "plant").q isa SVector{2,D8}
    end

    test_seam_protocol()
end

# Two logs snapshot by snapshot: the clock bitwise, the counters, the table
# buffer by buffer.
same_snapshots(a, b) =
    length(a) == length(b) &&
    all(s.t === r.t && s.frame == r.frame && s.boundary == r.boundary && same_table(s.store, r.store)
        for (s, r) in zip(a, b))

function test_seam_protocol()
    @testset "a rejected attempt leaves no trace: the retry starts from the step's start, and the run publishes the unrejected one bit for bit (§10.2, §10.3, D-452)" begin
        # Every third attempt is rejected and retried at the same length. The
        # rejected attempts ran both stages, so the state buffer, the clock and
        # the table held their scratch; the drain at frame 3 makes that frame's
        # first attempt read a written table, and every later step's a fresh one.
        plain, rejecting = seam_sim(Scheduled(1/16)), seam_sim(Scheduled(1/16; every = 3))
        for sim in (plain, rejecting)
            init!(sim, set(u = (ref = 0.7,)))
            step!(sim; frames = 2)
            stage!(sim, "ref" => 1.0)
            step!(sim; frames = 6)
        end
        stepper = rejecting.model.exec.stepper
        @test length(stepper.lengths) == plain.model.exec.stepper.attempts ≥ 2 * stepper.attempts ÷ 3
        # each retry found the clock and the state its rejected attempt found
        @test all(stepper.starts[n + 1][1] === stepper.starts[n][1] &&
                  stepper.starts[n + 1][2] == stepper.starts[n][2]
                  for n in 3:3:(stepper.attempts - 1))
        @test stepper.lengths == plain.model.exec.stepper.lengths
        @test same_snapshots(logged(rejecting), logged(plain))
        @test state(rejecting, "plant").q === state(plain, "plant").q
        # A model with localized events: the rejections land in whole steps and
        # in remainders after `t*` alike.
        localized = [Simulation(stamped(); Δt_frame = 1//10, algorithm) for algorithm in
                     (Scheduled(1/40), Scheduled(1/40; every = 3))]
        for sim in localized
            init!(sim)
            run!(sim; t_end = 0.5)
        end
        @test modes(localized[1], "s").t_fired ≈ 0.315 atol = 1e-6
        @test same_snapshots(logged(localized[2]), logged(localized[1]))
        # A remainder's retry never passes the end of its step (D-446). Over
        # dyadic periods, attempt 12 is the remainder from the stamper's `t*`
        # to 11/32, rejected for four times its length, and the retry is
        # clamped back to it.
        straight, grown = [Simulation(stamped(); Δt_frame = 1//8, algorithm) for algorithm in
                           (Scheduled(1/32), Scheduled(1/32; rejected = (12,), factor = 4.0))]
        for sim in (straight, grown)
            init!(sim)
            run!(sim; t_end = 0.5)
        end
        @test grown.model.exec.stepper.attempts == straight.model.exec.stepper.attempts + 1 == 18
        @test same_snapshots(logged(grown), logged(straight))
    end

    @testset "a proposal is clamped to h_max and to the span's end, a rejection's proposal is the retry's, and a shortened step ends at the clock plus its length (§10.2, §10.5, D-452)" begin
        # Every period is dyadic, so each clock below is exact. The proposal of
        # 0.1 is clamped to `h_max = 1/16`. Attempt 2, offered the span's last
        # 1/32, is rejected for a quarter of it, so the step ends at
        # 1/16 + 1/128, a boundary on no lattice, and the next step takes the
        # span's rest to the due instant at 3/32.
        model = Model(seam_rig(); Δt_frame = 1//8, Δt_base = 1//32, h_max = 1//16,
                      algorithm = Scheduled(0.1; rejected = (2,), factor = 0.25))
        init!(model, set(u = (ref = 0.7,)))
        hooks = RecordingHooks(model, 0, Float64[], false)
        frame!(model, 1, hooks)
        frame!(model, 2, hooks)
        stepper = model.exec.stepper
        @test hooks.boundaries == [1/16, 1/16 + 1/128, 3/32, 1/8, 3/16, 1/4]
        @test stepper.lengths == [1/16, 1/128, 3/128, 1/32, 1/16, 1/16]
        @test stepper.attempts == 7
        @test stepper.starts[3] == stepper.starts[2]
        @test state(model, "a").n == 1 + 2         # the ticks at 3/32 and 3/16, at their instants
        # A localized event inside a step a rejection shortened still fires at
        # its crossing.
        sim = Simulation(stamped(); Δt_frame = 1//10, algorithm = Scheduled(1/40; every = 2, factor = 0.5))
        init!(sim)
        run!(sim; t_end = 0.5)
        @test modes(sim, "s").count == 1
        @test modes(sim, "s").t_fired ≈ 0.315 atol = 1e-6
    end

    @testset "the notice reaches the backend where a handler fired, a tick ran, a drain wrote, and at init! and overlay!, never at a restore, and the same under one advance and many (§10.2, §12.6, D-452)" begin
        # One step a span: frame tops at k/8, ticks every 3/32. The tick at 3/8
        # lands on a frame top. The notices are recorded as the attempt count
        # they arrived at: boundary zero's at 0, a tick's after its step, and
        # frame 4's drain at its top, after the 3/8 tick's.
        notices = [0, 1, 3, 5, 6, 6, 7, 9, 11, 12]
        once, stepped = seam_sim(Scheduled(0.2)), seam_sim(Scheduled(0.2))
        init!(once, set(u = (ref = 0.7,)))
        step!(once; frames = 3)
        stage!(once, "ref" => 1.0)
        step!(once; frames = 3)
        # the same frames one advance at a time: only a drain that wrote notifies at a top
        init!(stepped, set(u = (ref = 0.7,)))
        foreach(_ -> step!(stepped), 1:3)
        stage!(stepped, "ref" => 1.0)
        foreach(_ -> step!(stepped), 1:3)
        @test once.model.exec.stepper.notices == stepped.model.exec.stepper.notices == notices
        @test same_snapshots(logged(stepped), logged(once))
        # `overlay!` notifies; a restore hands the carried state back and does not.
        cp = checkpoint(once)
        overlay!(once, set(u = (ref = 0.5,)))
        @test once.model.exec.stepper.notices == [notices; 12]
        restore!(once, cp)
        @test once.model.exec.stepper.notices == [notices; 12]
        # A handler that fires notifies at its boundary: the stamper's `t*`, in
        # frame 4's one step.
        sim = Simulation(stamped(); Δt_frame = 1//10, algorithm = Scheduled(0.2))
        init!(sim)
        run!(sim; t_end = 0.5)
        @test sim.model.exec.stepper.notices == [0, 4]
    end

    @testset "a checkpoint carries the stepper's state, and a restore followed by a step is the unrestored run bit for bit (§12.6, D-274, D-452)" begin
        # The stepper carries its proposal and its attempt count. A restore that
        # dropped the count would reject attempts 5 and 9 again.
        algorithm = Scheduled(1/16; rejected = (5, 9, 14, 20), factor = 0.5)
        original = seam_sim(algorithm)
        init!(original, set(u = (ref = 0.7,)))
        @test trace(original).header.state.stepper == (1/16, 0)
        step!(original; frames = 3)
        cp = checkpoint(original)
        stepper = original.model.exec.stepper
        @test cp.state.stepper == (stepper.proposal, stepper.attempts) && stepper.attempts > 9
        attempts_at_cp, accepted_at_cp = stepper.attempts, length(stepper.lengths)
        step!(original; frames = 4)
        resumed = seam_sim(algorithm)
        restore!(resumed, cp)
        step!(resumed; frames = 4)
        resumed_stepper = resumed.model.exec.stepper
        @test resumed_stepper.attempts == stepper.attempts > attempts_at_cp
        @test resumed_stepper.lengths == stepper.lengths[(accepted_at_cp + 1):end]
        after = filter(s -> s.boundary ≥ first(logged(resumed)).boundary, logged(original))
        @test same_snapshots(logged(resumed), after)
        # The model's own pair: a state taken from a standalone model and
        # restored into a fresh one.
        model = Model(seam_rig(); Δt_frame = 1//8, Δt_base = 1//32, algorithm)
        init!(model, set(u = (ref = 0.7,)))
        frames!(model, 3)
        model_state = checkpoint(model)
        @test model_state.stepper == (model.exec.stepper.proposal, model.exec.stepper.attempts)
        twin = Model(seam_rig(); Δt_frame = 1//8, Δt_base = 1//32, algorithm)
        restore!(twin, model_state)
        frames!(model, 4)
        frames!(twin, 4)
        @test state(twin, "plant").q === state(model, "plant").q
        @test twin.exec.stepper.lengths == model.exec.stepper.lengths[(end - length(twin.exec.stepper.lengths) + 1):end]
        # The trace's header is detached and replays through the same attempts.
        replayed = seam_sim(algorithm)
        init!(replayed, set(u = (ref = 0.7,)))
        replay!(replayed, trace(original))
        @test replayed.model.exec.stepper.lengths == stepper.lengths
        @test same_snapshots(logged(replayed)[2:end], logged(original)[2:end])
    end

    @testset "a cursor frame names the attempt, rendered past the first (§13.4, D-452)" begin
        # Attempt 1 offers 0.02, whose second stage at 0.02 is short of the
        # trip; it is rejected for four times its length, and attempt 2's second
        # stage, at 0.08, trips.
        model = Model(fed(Tripwire(0.05), "arm"); Δt_frame = 1//10,
                      algorithm = Scheduled(0.02; rejected = (1,), factor = 4.0))
        init!(model, set(u = (in = true,)))
        err = failure(() -> frame!(model, 1))
        @test err isa StepError{Tripped}
        @test err.cursor == CursorFrame("c", :x_deriv, :integrate, 2, 2)
        @test err.t == 0.08 && err.boundary == 0
        @test occursin("integration stage 2 in attempt 2 of the frame from boundary 0",
                       sprint(showerror, err))
    end

    @testset "a rejected trial is discarded unread: a nonfinite one raises nothing (§13.4, D-157, D-452)" begin
        poisoned, clean = seam_sim(Scheduled(1/16; every = 2, poison = true)),
                          seam_sim(Scheduled(1/16; every = 2))
        for sim in (poisoned, clean)
            init!(sim, set(u = (ref = 0.7,)))
            step!(sim; frames = 4)
        end
        @test lifecycle(poisoned) === :initialized
        @test same_snapshots(logged(poisoned), logged(clean))
    end

    @testset "a step that reaches the span's end takes its clock where the float sum would miss it (§10.2, §10.5, D-452)" begin
        # From 0.03 the span's rest is 0.27, and 0.03 + 0.27 is one ulp past 0.3,
        # so every end below is written from the frame top's index or missed.
        Δt = Float64(3//10)
        short = 0.1 * Δt
        @test short + (Δt - short) != Δt
        ramp() = Model(Group((; r = BareRamp())); Δt_frame = 3//10,
                       algorithm = Scheduled(1.0; rejected = (1,), factor = 0.1))
        # A first offer: attempt 1 is rejected for a tenth of the frame, and the
        # next step is offered the rest of the span.
        model = ramp()
        init!(model)
        hooks = RecordingHooks(model, 0, Float64[], false)
        frame!(model, 1, hooks)
        @test hooks.boundaries == [short, Δt] && model.exec.clock.t === Δt
        # A retry: the second step is offered `short`, rejected for a hundred
        # times that, and the retry is clamped to the span's rest. The same on a
        # model with localized events, whose loop moves the step's end.
        for root in (Group((; r = BareRamp())), stamped())
            model = Model(root; Δt_frame = 3//10,
                          algorithm = Scheduled(short; rejected = (2,), factor = 100.0))
            init!(model)
            hooks = RecordingHooks(model, 0, Float64[], false)
            frame!(model, 1, hooks)
            @test hooks.boundaries == [short, Δt] && model.exec.clock.t === Δt
            @test model.exec.stepper.attempts == 3
        end
        # A localized step's first retry is clamped to the span's end, not to the
        # end it was first offered: rejected at 1/32 for four times that, it takes
        # the whole frame.
        localized = Model(stamped(); Δt_frame = 1//8,
                          algorithm = Scheduled(1/32; rejected = (1,), factor = 4.0))
        init!(localized)
        frame!(localized, 1)
        @test localized.exec.stepper.lengths == [1/8]
        # The bare primitive's retry never passes the length it was given.
        bare = Model(Group((; r = BareRamp())); Δt_frame = 1//8,
                     algorithm = Scheduled(1/16; rejected = (1,), factor = 4.0))
        init!(bare)
        integrate!(bare, 1/16)
        @test bare.exec.stepper.lengths == [1/16] && bare.exec.clock.t === 1/16
    end

    @testset "an accepted trial is checked before it is committed, and the report reads the trial (§13.4, D-157, D-452)" begin
        # Attempt 3, the first of frame 2, is accepted with an infinite trial.
        model = Model(Group((; r = BareRamp())); Δt_frame = 1//4, algorithm = Scheduled(1/8; spoil = 3))
        init!(model)
        frame!(model, 1)
        err = failure(() -> frame!(model, 2))
        @test err isa StepError{NonfiniteState}
        @test err.cause.value == Inf && err.cause.t == 3/8
        @test err.cursor == CursorFrame("r", :none, :integrate, 0, 1)
        @test all(isfinite, model.exec.xbuf)       # the trial never reached the state buffer
        @test CursorFrame("r", :x_deriv, :integrate, 2, 1) != CursorFrame("r", :x_deriv, :integrate, 2, 2)
    end

    @testset "init! resets the stepper's carried state, so a run is a function of its condition (§2.4, §10.2, D-452)" begin
        algorithm = Scheduled(1/16; rejected = (5, 9), factor = 0.5)
        fresh, again = seam_sim(algorithm), seam_sim(algorithm)
        init!(fresh, set(u = (ref = 0.7,)))
        step!(fresh; frames = 3)
        init!(again, set(u = (ref = 0.7,)))
        step!(again; frames = 2)                   # leaves the stepper past attempt 5
        init!(again, set(u = (ref = 0.7,)))
        @test trace(again).header.state.stepper == trace(fresh).header.state.stepper == (1/16, 0)
        step!(again; frames = 3)
        @test again.model.exec.stepper.attempts == fresh.model.exec.stepper.attempts
        @test same_snapshots(logged(again), logged(fresh))
    end

    @testset "a model with no continuous state never asks its stepper for a proposal (§10.2, D-156, D-452)" begin
        # One step a frame, though the backend's standing proposal is 0.03.
        model = Model(Group((; a = TickCounter())); Δt_frame = 1//10, algorithm = Scheduled(0.03))
        init!(model)
        hooks = RecordingHooks(model, 0, Float64[], false)
        frame!(model, 1, hooks)
        @test hooks.boundaries == [Float64(1//10)] && model.exec.stepper.attempts == 0
    end

    @testset "a proposal that does not advance the clock is refused as the backend's bug (§10.2, D-452)" begin
        # At t₀ = 1 a length of 1e-20 is below the clock's resolution. Each of
        # the first three would otherwise take steps without end, and the clamp
        # would read the fourth as the whole span. The frame names integration
        # and no component, since no stage ran.
        for proposal in (0.0, -0.1, 1e-20, NaN)
            model = Model(Group((; r = BareRamp())); Δt_frame = 1//8, algorithm = Scheduled(proposal))
            init!(model; t0 = 1.0)
            err = failure(() -> frame!(model, 1))
            @test err isa StepError && err.cause isa InternalInvariant
            @test err.t == 1.0 && model.exec.stepper.attempts == 0
            @test err.cursor == CursorFrame(nothing, :none, :integrate, 0, 0)
        end
        # A retry is shaped the same way: rejected for none of its length.
        model = Model(Group((; r = BareRamp())); Δt_frame = 1//8,
                      algorithm = Scheduled(1/16; rejected = (1,), factor = 0.0))
        init!(model)
        err = failure(() -> frame!(model, 1))
        @test err.cause isa InternalInvariant && model.exec.stepper.attempts == 1
        @test err.cursor == CursorFrame(nothing, :none, :integrate, 0, 0)
        # An infinite proposal asks for all it may have, and takes the span.
        model = Model(Group((; r = BareRamp())); Δt_frame = 1//8, algorithm = Scheduled(Inf))
        init!(model)
        frame!(model, 1)
        @test model.exec.stepper.lengths == [1/8]
    end

    @testset "the attempt loop allocates nothing, rejections included (§9.8, D-452)" begin
        model = Model(seam_rig(); Δt_frame = 1//8, Δt_base = 1//32,
                      algorithm = Scheduled(1/16; every = 2, factor = 0.5, record = false))
        init!(model, set(u = (ref = 0.7,)))
        frames!(model, 2)
        k = Ref(3)
        attempts = model.exec.stepper.attempts
        @test @ballocated(frame!($model, k), setup = (k = $k[]; $k[] += 1), evals = 1) == 0
        @test model.exec.stepper.attempts > attempts
    end
end

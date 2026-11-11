# --- the lattices and the step bound (§2.1, §10.5, D-445, D-449, D-450) ---------
# The frame tops and the base ticks stand in no required ratio. A span runs
# from one mandatory instant, a frame top or a due instant, to the next, and a
# fixed-step method takes it in the fewest equal steps `h_max` allows. Every
# step end is a boundary, and every clock is written from an index.

# A frame's hooks that keep, at every settled boundary, the clock and the two
# tick counters of the lattice rig, and report nothing written at the top.
mutable struct LatticeHooks{M} <: FrameHooks
    model::M
    boundaries::Vector{Tuple{Float64,Int,Int}}
end
frame_top!(::LatticeHooks) = nothing
settled!(hooks::LatticeHooks) =
    (push!(hooks.boundaries, (hooks.model.exec.clock.t, state(hooks.model, "a").n,
                              state(hooks.model, "b").n)); false)

# A recording backend (§10.2): forward Euler that keeps every step length the
# loop hands it, the scalar's value, and whether that step's first stage found
# the table fresh (D-447).
struct Recorder <: AbstractAlgorithm end
struct RecorderStepper{T} <: AbstractStepper
    x₀::Vector{T}
    k₁::Vector{T}
    lengths::Vector{Float64}
    fresh::Vector{Bool}
end
bind_stepper(::Recorder, ::Type{T}, n_x::Int) where {T} =
    RecorderStepper{T}(zeros(T, n_x), zeros(T, n_x), Float64[], Bool[])
function integrate!(stepper::RecorderStepper, model::Model, h)
    push!(stepper.lengths, ForwardDiff.value(h)); push!(stepper.fresh, model.fresh)
    x = model.exec.xbuf
    copyto!(stepper.x₀, x)
    evaluate!(model); copyto!(stepper.k₁, model.exec.ẋbuf)
    x .= stepper.x₀ .+ h .* stepper.k₁
    model.exec.clock.t += h
    nothing
end
startpoint(stepper::RecorderStepper) = (stepper.x₀, stepper.k₁)

# The R2 rig: a continuous plant beside two counters at 0.1 s and 0.1001 s.
lattice_rig() = Group((; c = Plant(), a = TickCounter(), b = TickCounter());
                      input_wires = ("in" => "c/u",),
                      sample_times = (; a = Absolute(Period(1//10)),
                                        b = Absolute(Period(1001//10000))))

# One counter at 0.07 s beside the plant, the split rig, and beside a sawtooth,
# whose sign-form guard makes the model's events localized.
split_rig() = Group((; c = Plant(), a = TickCounter()); input_wires = ("in" => "c/u",),
                    sample_times = (; a = Absolute(Period(7//100))))
localized_split_rig() = Group((; c = Sawtooth(1.0), a = TickCounter());
                              sample_times = (; a = Absolute(Period(7//100))))

# A root input sampled by a ZOH due at 0.07 s, off the frame tops.
sampled_rig() = Group((; z = ZOH()); input_wires = ("in" => "z/in",),
                      sample_times = (; z = Absolute(Period(7//100))))

# Hooks whose top reports nothing written, the drain's empty report (D-447).
struct FreshHooks <: FrameHooks end
frame_top!(::FreshHooks) = false
settled!(::FreshHooks) = false

# Three stampers on one sawtooth, crossing in the first, second and third steps
# of frame 4 under `h_max = 1//40`.
three_stampers() = Group((; src = Sawtooth(1.0), s1 = Stamper(0.31), s2 = Stamper(0.335),
                          s3 = Stamper(0.36));
                         local_wires = ("src/q" => "s1/sig", "src/q" => "s2/sig",
                                        "src/q" => "s3/sig"))

# A counter due at every frame top of a 10 ms frame over a 1e-18 s base: the
# frame spans 10^16 units, so only 921 frames fit `Int`.
overflow_rig() = Group((; c = TickCounter()); sample_times = (; c = Relative(10^16)))

# A counter whose period is a thousand units short of `typemax(Int)`, at a unit
# of one second: only frames 1 to 1000 keep its next due index inside `Int`,
# long before the clock's resolution ends.
long_period_rig() = Group((; c = TickCounter()); sample_times = (; c = Relative(typemax(Int) - 1000)))

# A counter due at every base tick, whose exact unit with the frame sets the
# lattices' resolution.
unit_rig() = Group((; c = TickCounter()); sample_times = (; c = Relative(1)))

function test_lattices()
    @testset "a 20 ms frame over a 100 µs base takes one step, plus one per due instant off its top (§10.5, D-444, D-445)" begin
        model = Model(lattice_rig(); Δt_frame = 1//50, Δt_base = 1//10000)
        init!(model, set(u = (in = 0.0,)))
        hooks = LatticeHooks(model, Tuple{Float64,Int,Int}[])
        frames = 5005                           # to 100.1 s, where the two coincide
        per_frame = Int[]
        for k in 1:frames
            before = length(hooks.boundaries)
            frame!(model, k, hooks)
            push!(per_frame, length(hooks.boundaries) - before)
        end
        # The oracle on the rationals: the due instants strictly inside frame k.
        due(t) = isinteger(t / (1//10)) || isinteger(t / (1001//10000))
        inside(k) = count(n -> due(n * (1//10000)), (200(k - 1) + 1):(200k - 1))
        @test per_frame == [1 + inside(k) for k in 1:frames]
        @test sum(per_frame) == 6000 && count(==(2), per_frame) == 995
        # Which boundaries ran which component, and each instant from its own
        # index: a frame top as `t₀ + k·Δt_frame`, a due instant inside a frame
        # as `t₀ + n·Δt_base` (D-445).
        Δt_frame, Δt_base = model.deployment.Δt_frame, model.deployment.Δt_base
        counts = [(0, 1, 1); [(0, a, b) for (_, a, b) in hooks.boundaries]]   # boundary zero ran both
        ran_a = [hooks.boundaries[i][1] for i in eachindex(hooks.boundaries)
                 if hooks.boundaries[i][2] > counts[i][2]]
        ran_b = [hooks.boundaries[i][1] for i in eachindex(hooks.boundaries)
                 if hooks.boundaries[i][3] > counts[i][3]]
        @test ran_a == [5m * Δt_frame for m in 1:1001]
        @test ran_b == [m % 200 == 0 ? (m ÷ 200) * 1001 * Δt_frame : m * 1001 * Δt_base
                        for m in 1:1000]
        # the coincidence at 100.1 s is one boundary, a frame top, running both
        @test last(ran_a) === last(ran_b) === frames * Δt_frame
        @test count(b -> b[1] == frames * Δt_frame, hooks.boundaries) == 1
    end

    @testset "a harmonic h_max takes equal steps of exactly h_max (§10.5, D-449)" begin
        # Three steps of 0.1 to a 0.3 s frame: the step is the exact `h_max`,
        # where dividing the frame's float by 3 would round below it.
        model = Model(fed(Plant(), "u"); Δt_frame = 3//10, h_max = 1//10, algorithm = Recorder())
        init!(model, set(u = (in = 0.0,)))
        frames!(model, 4)
        @test model.exec.stepper.lengths == fill(0.1, 12)
        @test Float64(3//10) / 3 !== 0.1
        # A due instant at every span's end: two spans a frame, two steps each.
        rig = Group((; c = Plant(), a = TickCounter()); input_wires = ("in" => "c/u",),
                    sample_times = (; a = Relative(1)))
        model = Model(rig; Δt_frame = 1//50, Δt_base = 1//100, h_max = 1//200,
                      algorithm = Recorder())
        init!(model, set(u = (in = 0.0,)))
        frames!(model, 10)
        @test model.exec.stepper.lengths == fill(Float64(1//200), 40)
        @test state(model, "a").n == 1 + 20
    end

    @testset "a due instant inside a step splits it: two exact pieces and the tick's instant (§10.5, D-444, D-445)" begin
        # The bare path integrates each piece by its exact length, never by the
        # float distance between the instants it joins.
        model = Model(split_rig(); Δt_frame = 1//10, Δt_base = 1//100, algorithm = Recorder())
        init!(model, set(u = (in = 0.0,)); t0 = 0.25)
        settled_at = Float64[]
        for k in 1:2
            frame!(model, k)
            push!(settled_at, model.exec.clock.t)
        end
        @test model.exec.stepper.lengths ==
              Float64[7//100, 3//100, 4//100, 6//100]
        @test settled_at == [0.25 + 1 * 0.1, 0.25 + 2 * 0.1]
        @test state(model, "a").n == 1 + 2
        # The tick's instant, written from its base-tick index.
        tick_model = Model(split_rig(); Δt_frame = 1//10, Δt_base = 1//100)
        init!(tick_model, set(u = (in = 0.0,)); t0 = 0.25)
        clocks = Float64[]
        recording = RecordingHooks(tick_model, 0, clocks, false)
        frame!(tick_model, 1, recording)
        @test clocks == [0.25 + 7 * 0.01, 0.25 + 1 * 0.1]
        # A model with localized events integrates each piece by the float
        # distance from the clock to its end, as its interpolant spans them.
        localized = Model(localized_split_rig(); Δt_frame = 1//10, Δt_base = 1//100,
                          algorithm = Recorder())
        init!(localized)
        frame!(localized, 1)
        @test localized.exec.stepper.lengths == [7 * 0.01 - 0.0, 1 * 0.1 - 7 * 0.01]
        # The split follows the schedule, not the state: at a `Dual` the frozen
        # discrete tier still splits the same steps (D-444).
        dual = Model(split_rig(), D8; Δt_frame = 1//10, Δt_base = 1//100, algorithm = Recorder())
        init!(dual, set(u = (in = D8(0.0),)); t0 = 0.25)
        frames!(dual, 2)
        @test dual.exec.stepper.lengths == model.exec.stepper.lengths
    end

    @testset "a due instant cuts a span, and each piece takes its own equal steps, written from the span's start (§10.5, D-449)" begin
        # A due instant 7 units into a 10-unit frame under a 5-unit bound: the
        # spans of 7 and 3 units take 2 and 1 steps, then 4 and 6 take 1 and 2.
        model = Model(split_rig(); Δt_frame = 1//10, Δt_base = 1//100, h_max = 1//20,
                      algorithm = Recorder())
        init!(model, set(u = (in = 0.0,)); t0 = 0.25)
        clocks = Float64[]
        hooks = RecordingHooks(model, 0, clocks, false)
        for k in 1:2
            frame!(model, k, hooks)
        end
        @test model.exec.stepper.lengths ==
              Float64[7//200, 7//200, 3//100, 4//100, 3//100, 3//100]
        @test state(model, "a").n == 1 + 2
        # An interior step end from its span's start clock and its count, the
        # mandatory instants from their own indices (D-445, D-449).
        Δt_frame, Δt_base = model.deployment.Δt_frame, model.deployment.Δt_base
        @test clocks == [(0.25 + 0 * Δt_frame) + 1 * Float64(7//200), 0.25 + 7 * Δt_base,
                         0.25 + 1 * Δt_frame, 0.25 + 14 * Δt_base,
                         (0.25 + 14 * Δt_base) + 1 * Float64(3//100), 0.25 + 2 * Δt_frame]
    end

    @testset "a bound that divides neither the frame nor a span still takes each span in equal steps no longer than it (§10.5, D-449)" begin
        # `h_max = 1//35` is 20/7 units: spans of 7 and 3 units take 3 and 2
        # steps, of 4 and 6 units 2 and 3, each longer than half the bound.
        h_max = 1//35
        model = Model(split_rig(); Δt_frame = 1//10, Δt_base = 1//100, h_max, algorithm = Recorder())
        init!(model, set(u = (in = 0.0,)))
        frames!(model, 2)
        lengths = model.exec.stepper.lengths
        @test lengths == Float64[7//300, 7//300, 7//300, 3//200, 3//200,
                                 1//50, 1//50, 1//50, 1//50, 1//50]
        @test all(h -> h / 2 < h_max ≥ h, lengths)
        # The split follows the schedule, not the state: at a `Dual` the frozen
        # discrete tier takes the same steps (D-444).
        dual = Model(split_rig(), D8; Δt_frame = 1//10, Δt_base = 1//100, h_max,
                     algorithm = Recorder())
        init!(dual, set(u = (in = D8(0.0),)))
        frames!(dual, 2)
        @test dual.exec.stepper.lengths == lengths
    end

    @testset "a bound at or above the frame bounds nothing: one step a span, the unbounded trajectory (§10.5, D-449)" begin
        lengths = map((nothing, 1//10, 1//1)) do h_max
            model = Model(split_rig(); Δt_frame = 1//10, Δt_base = 1//100, h_max,
                          algorithm = Recorder())
            init!(model, set(u = (in = 0.0,)))
            frames!(model, 2)
            model.exec.stepper.lengths
        end
        @test lengths[1] == lengths[2] == lengths[3] == Float64[7//100, 3//100, 4//100, 6//100]
    end

    @testset "a due instant is written from its base-tick index (§10.5, D-445)" begin
        # Every span is one base tick here, so every step end inside a frame is
        # due, and its clock comes from `n`, where a count from the frame top
        # rounds otherwise: frame 2's second step end is tick 5.
        rig = Group((; c = Plant(), a = TickCounter()); input_wires = ("in" => "c/u",),
                    sample_times = (; a = Relative(1)))
        model = Model(rig; Δt_frame = 1//10, Δt_base = 1//30, h_max = 1//30)
        init!(model, set(u = (in = 0.0,)))
        clocks = Float64[]
        hooks = RecordingHooks(model, 0, clocks, false)
        for k in 1:2
            frame!(model, k, hooks)
        end
        Δt_frame, Δt_base, h = model.deployment.Δt_frame, model.deployment.Δt_base, Float64(1//30)
        @test clocks == [1 * Δt_base, 2 * Δt_base, 1 * Δt_frame,
                         4 * Δt_base, 5 * Δt_base, 2 * Δt_frame]
        @test clocks[5] !== 1 * Δt_frame + 2 * h        # the two formulas part by an ulp
        @test state(model, "a").n == 1 + 6
    end

    @testset "a bound finer than the frame subcycles: the analytic solution, bitwise the frame at h_max (§2.2, §10.2, D-449)" begin
        ω, ζ, k, r = 2.0, 0.1, 4.0, 0.7
        A = SMatrix{2,2}(0.0, -ω^2, 1.0, -2ζ * ω)
        B = SVector(0.0, 1.0)
        Acl = A - B * k * SVector(1.0, 0.0)'
        exact(t) = exp(Acl * t) * (Acl \ (B * k * r)) - Acl \ (B * k * r)
        subcycled = Model(feedback_model(; k, ω, ζ); Δt_frame = 1//100, h_max = 1//400)
        stepwise = Model(feedback_model(; k, ω, ζ); Δt_frame = 1//400)
        init!(subcycled, set(u = (ref = r,)))
        init!(stepwise, set(u = (ref = r,)))
        clocks = Float64[]
        hooks = RecordingHooks(subcycled, 0, clocks, false)
        agree = true
        for frame in 1:200
            frame!(subcycled, frame, hooks)
            frames!(stepwise, 4)
            agree &= state(subcycled, "plant").q === state(stepwise, "plant").q
        end
        # The model reads no time, so the four steps of a frame are the four
        # frames at `h_max` to the bit.
        @test agree
        @test norm(state(subcycled, "plant").q - exact(2.0)) < 1e-9
        # Each interior step end from its span's start, the frame top, and its
        # count in the span (D-449).
        Δt_frame, h = subcycled.deployment.Δt_frame, Float64(1//400)
        @test clocks == [j == 4 ? frame * Δt_frame : (frame - 1) * Δt_frame + j * h
                         for frame in 1:200 for j in 1:4]
    end

    @testset "a tick inside a frame samples the inputs its frame-top drain applied (§2.2, §11.4, D-445)" begin
        sim = Simulation(sampled_rig(); Δt_frame = 1//10, Δt_base = 1//100)
        init!(sim, set(u = (in = 1.0,)))
        stage!(sim, "in" => 2.0)                  # frame 1's drain, at its top
        step!(sim)
        stage!(sim, "in" => 3.0)                  # frame 2's drain
        step!(sim)
        Δt_frame, Δt_base = sim.model.deployment.Δt_frame, sim.model.deployment.Δt_base
        samples = [(s.t, port(s, "", :in), port(s, "z", :out)) for s in logged(sim)]
        @test samples == [(0.0, 1.0, 1.0), (7 * Δt_base, 2.0, 2.0), (1 * Δt_frame, 2.0, 2.0),
                          (14 * Δt_base, 3.0, 3.0), (2 * Δt_frame, 3.0, 3.0)]
    end

    @testset "every step end publishes, under its frame's index and the next ordinal (§11.2, §12.3, D-445)" begin
        sim = Simulation(split_rig(); Δt_frame = 1//10, Δt_base = 1//100, h_max = 1//20)
        init!(sim, set(u = (in = 0.0,)))
        step!(sim; frames = 3)
        snapshots = logged(sim)
        Δt_frame, Δt_base = 0.1, 0.01
        @test [s.frame for s in snapshots] == [0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 3]
        @test [s.boundary for s in snapshots] == collect(0:10)
        @test [s.t for s in snapshots] ==
              [0.0, 0 * Δt_frame + 1 * 0.035, 7 * Δt_base, 1 * Δt_frame,
               14 * Δt_base, 14 * Δt_base + 1 * 0.03, 2 * Δt_frame,
               21 * Δt_base, 21 * Δt_base + 1 * 0.035, 28 * Δt_base, 3 * Δt_frame]
        @test [port(s, "a", :n) for s in snapshots] == [0, 0, 1, 1, 2, 2, 2, 3, 3, 4, 4]
    end

    @testset "a first stage over a fresh table is the sweep's, bitwise, and the drain's report arms it (§10.3, D-447)" begin
        # A top that reports nothing written skips the first sweep of every
        # frame; the trajectory is the one that sweeps.
        swept = Model(feedback_model(); Δt_frame = 1//50)
        fresh = Model(feedback_model(); Δt_frame = 1//50)
        init!(swept, set(u = (ref = 0.7,)))
        init!(fresh, set(u = (ref = 0.7,)))
        agree = true
        for k in 1:100
            frame!(swept, k)
            frame!(fresh, k, FreshHooks())
            agree &= state(swept, "plant").q === state(fresh, "plant").q
        end
        @test agree

        # Under the loop's hooks a frame's first step is fresh unless its drain
        # applied a batch or it opens an advance; every later step is fresh.
        recorded() = Simulation(fed(Plant(), "u"); Δt_frame = 1//10, h_max = 1//20,
                                algorithm = Recorder())
        sim = recorded()
        init!(sim, set(u = (in = 0.0,)))
        step!(sim; frames = 3)
        stage!(sim, "in" => 1.0)
        step!(sim; frames = 2)
        # the loop's hooks outside an advance, so only the drain reports
        hooks = LoopHooks(sim, sim.plane.roster, nothing, Bool[], 0)
        stage!(sim, "in" => 2.0)
        frame!(sim.model, 6, hooks)
        frame!(sim.model, 7, hooks)
        flags = [false, true, true, true, true, true,     # frames 1 to 3, one advance
                 false, true, true, true,                 # frames 4 and 5, the batch at 4
                 false, true, true, true]                 # frames 6 and 7, the batch at 6
        @test sim.model.exec.stepper.fresh == flags
        # A replay's drain reports the recorded batches it applies.
        twin = recorded()
        init!(twin, set(u = (in = 0.0,)))
        before = length(twin.model.exec.stepper.fresh)
        replay!(twin, trace(sim))
        @test twin.model.exec.stepper.fresh[(before + 1):end] == flags
        @test state(twin, "c") == state(sim, "c")
    end

    @testset "a localized event in a frame's later step, the budget counted across its steps (§10.4, D-446)" begin
        sim = Simulation(three_stampers(); Δt_frame = 1//10, h_max = 1//40,
                         localization_budget = 2)
        init!(sim)
        run!(sim; t_end = 0.5)
        # s2 crosses in the second step of frame 4, and localizes there.
        @test modes(sim, "s1").t_fired ≈ 0.31 atol = 1e-6
        @test modes(sim, "s2").t_fired ≈ 0.335 atol = 1e-6
        # s3 crosses in the third: the budget of 2 is spent, so it fires at the
        # end of the step it was found in, written from its span's start and its
        # count.
        Δt_frame, h = sim.model.deployment.Δt_frame, Float64(1//40)
        @test modes(sim, "s3").t_fired === 3 * Δt_frame + 3 * h
        # The frame's report folds at frame 5's top, so the first publication
        # after it carries it, frame 5's first step end.
        @test writer_status(latest(sim), "loop").totals.chattering == 1
        reporting = only(s for s in logged(sim) if !isempty(writer_status(s, "loop").recent))
        @test reporting.t === 4 * Δt_frame + 1 * h
        d = only(writer_status(reporting, "loop").recent)
        @test d isa ChatteringBudget && d.path == "s3" && d.budget == 2 && d.count == 2 &&
              d.t === 3 * Δt_frame + 3 * h
    end

    @testset "a stop request holding at a step end inside a frame ends the run there (§13.5, D-445)" begin
        sim = Simulation(ramp_request(0.33, "ramp at level"); Δt_frame = 1//10, h_max = 1//40)
        init!(sim)
        run!(sim; t_end = 1.0)
        Δt_frame, h = sim.model.deployment.Δt_frame, Float64(1//40)
        @test termination(sim).source isa ModelRequestedStop
        @test sim.model.exec.clock.t === 3 * Δt_frame + 2 * h && sim.run.frame == 4
        @test latest(sim).t === 3 * Δt_frame + 2 * h
        # the clock inside the frame is no state to take (§12.6, D-319)
        d = carried(@test_throws DiagnosticError{CheckpointMidFrame} checkpoint(sim))
        @test d.frame == 4 && d.t_frame == 4 * Δt_frame
    end

    @testset "a frame whose positions leave `Int` is refused, and an unbounded run stops before it (§10.5, §12.6, D-445)" begin
        deployment = Deployment(build(long_period_rig()); Δt_frame = 1)
        @test deployment.lattice.max_frame == 1000
        model = Model(deployment)
        init!(model)
        @test _last_frame(model) == 1000              # the clock resolves far past it
        # A bound fits where the frame it lands on runs: the last frame's top
        # within its slack, not the frame after it.
        @test _frames_fit(model, 999.0) && _frames_fit(model, 1000.0) &&
              _frames_fit(model, nextfloat(1000.0))
        @test !_frames_fit(model, 1000.5) && !_frames_fit(model, 1001.0)
        d = carried(@test_throws DiagnosticError{ArgumentInvalid} frame!(model, 1001))
        @test d.call === :frame! && d.reason === :range && d.argument === :k && d.value == 1001 &&
              d.related == 1000
        @test model.status === :consistent && model.exec.clock.t == 0.0
        # The last frame runs, its due index next to `typemax(Int)`.
        @test frame!(model, 1000) === false
        @test model.exec.clock.t === 1000.0 && state(model, "c").n == 1
        # A finite bound past the last frame is refused at the door.
        sim = Simulation(deployment)
        init!(sim; log = false)
        d = carried(@test_throws DiagnosticError{ArgumentInvalid} run!(sim; t_end = 1001.0))
        @test d.argument === :t_end
        # So is a frame count past it, before any frame runs.
        d = carried(@test_throws DiagnosticError{ArgumentInvalid} step!(sim; frames = 1001))
        @test d.call === :step! && d.argument === :frames && d.value == 1001
        @test sim.run.frame == 0 && lifecycle(sim) === :initialized
        @test step!(sim; frames = 10) == 10
        d = carried(@test_throws DiagnosticError{ArgumentInvalid} step!(sim; frames = 991))
        @test d.value == 991 && sim.run.frame == 10
        # An unbounded run reaches frame 1000's top and throws the frame's
        # refusal: the stores stay a settled boundary, so the model is
        # consistent, the lifecycle `:stopped` and the record a loop error.
        d = carried(@test_throws DiagnosticError{ArgumentInvalid} run!(sim))
        @test d.call === :frame! && d.value == 1001 && d.related == 1000
        @test lifecycle(sim) === :stopped && sim.model.status === :consistent
        @test sim.run.frame == 1000 && sim.model.exec.clock.t === 1000.0
        @test termination(sim).source isa LoopError
        # With a device the run returns under the error log, the device shut down.
        sim = Simulation(deployment)
        probe = TailProbe()
        attach!(sim, probe, NoClaim())
        init!(sim; log = false)
        @test_logs (:error, r"the run ended on a loop error") match_mode = :any run!(sim)
        @test probe.log == [:init, :shutdown] && lifecycle(sim) === :stopped
        @test termination(sim).source.exception isa DiagnosticError{ArgumentInvalid}
        # A `t_end` at the last frame's top is admitted, and the run ends there.
        sim = Simulation(deployment)
        init!(sim; log = false)
        run!(sim; t_end = 1000.0)
        @test sim.run.frame == 1000 && sim.model.exec.clock.t === 1000.0
        # A duration inside the bound's slack still runs a frame, the one past
        # the last: refused at the door, the simulation as it was.
        sim = Simulation(deployment)
        init!(sim; log = false)
        @test step!(sim; frames = 1000) == 1000
        before = lifecycle(sim)
        d = carried(@test_throws DiagnosticError{ArgumentInvalid} step!(sim; t_plus = 1e-13))
        @test d.call === :step! && d.argument === :t_plus
        @test sim.run.frame == 1000 && lifecycle(sim) === before
    end

    @testset "the clock's resolution sets the last frame from the gap between boundaries and the origin (§10.5, D-450)" begin
        # `|t₀| + 2·(t − t₀) < 2^50·g`, with `g` the unit, or half the bound when
        # the bound splits a span; dyadic periods keep the counts exact.
        feedback_build = build(feedback_model())
        unbounded = Deployment(feedback_build; Δt_frame = 1//64)
        @test _last_frame(unbounded, 0.0) == 2^49 - 1             # g = 1//64
        @test _last_frame(Deployment(feedback_build; Δt_frame = 1//64, h_max = 1//256), 0.0) ==
              2^46 - 1                                             # g = 1//512
        @test _last_frame(Deployment(feedback_build; Δt_frame = 1//64, h_max = 3//256), 0.0) ==
              3 * 2^46 - 1                                         # g = 3//512
        # A bound at or above the frame splits nothing, and `g` stays the unit.
        @test _last_frame(Deployment(feedback_build; Δt_frame = 1//64, h_max = 1//32), 0.0) ==
              2^49 - 1
        # The origin spends the same room: 2^50 units leave none.
        @test _last_frame(unbounded, 2.0^50 / 64 - 20 / 64) == 9
        @test _last_frame(unbounded, 2.0^50 / 64) == 0
        # The run under it: the lattice's `Int` range is far off, the clock's is not.
        @test unbounded.lattice.max_frame == typemax(Int)
    end

    @testset "a run the clock cannot resolve is refused at every door (§10.5, §12.6, §12.7, §14.5, D-450)" begin
        # From this origin the last frame the clock resolves is 9, at a 10 ms
        # frame whose unit is the gap: `|t₀| + 2·9·Δt_frame < 2^50·Δt_frame`.
        Δt_frame = 1//100
        t0 = 2.0^50 / 100 - 0.19
        deployment = Deployment(build(fed(Plant(), "u")); Δt_frame)
        @test _last_frame(deployment, t0) == 9
        # The origin: one whose first frame is already past the resolution.
        model = Model(deployment)
        d = carried(@test_throws DiagnosticError{ArgumentInvalid} init!(model, set(u = (in = 0.0,));
                                                                       t0 = 2.0^50 / 100))
        @test d.call === :init! && d.argument === :t0
        @test model.status === :built
        # One whose first frame is the last the run may take is admitted.
        t0_last = 2.0^50 / 100 - 0.03
        @test _last_frame(deployment, t0_last) == 1
        init!(model, set(u = (in = 0.0,)); t0 = t0_last)
        @test model.status === :consistent
        # `frame!`, with the last frame as the bound it names.
        init!(model, set(u = (in = 0.0,)); t0)
        d = carried(@test_throws DiagnosticError{ArgumentInvalid} frame!(model, 10))
        @test d.call === :frame! && d.argument === :k && d.value == 10 && d.related == 9
        @test frame!(model, 9) === false && model.status === :consistent
        # The advances' doors, each refused before a frame runs.
        sim = Simulation(deployment)
        init!(sim, set(u = (in = 0.0,)); t0)
        d = carried(@test_throws DiagnosticError{ArgumentInvalid} run!(sim; t_end = t0 + 0.2))
        @test d.argument === :t_end
        d = carried(@test_throws DiagnosticError{ArgumentInvalid} step!(sim; frames = 10))
        @test d.argument === :frames && d.value == 10
        d = carried(@test_throws DiagnosticError{ArgumentInvalid} step!(sim; t_plus = 0.2))
        @test d.argument === :t_plus
        @test sim.run.frame == 0
        @test step!(sim; frames = 5) == 5
        # Replay's time spelling of the halt, against the recording's origin.
        twin = Simulation(deployment)
        init!(twin, set(u = (in = 0.0,)); t0)
        d = carried(@test_throws DiagnosticError{ArgumentInvalid} replay!(twin, trace(sim);
                                                                          to_time = t0 + 0.2))
        @test d.call === :replay! && d.argument === :to_time
        # An unbounded run ends on `frame!`'s refusal at frame 10, as at the end
        # of the `Int` range.
        d = carried(@test_throws DiagnosticError{ArgumentInvalid} run!(sim))
        @test d.call === :frame! && d.value == 10 && d.related == 9
        @test sim.run.frame == 9 && lifecycle(sim) === :stopped
        # The clocks it wrote are strictly increasing.
        clocks = [snapshot.t for snapshot in logged(sim)]
        @test issorted(clocks; lt = ≤) && length(clocks) == 10
    end

    @testset "a lattice whose exact unit or bound cannot count one frame in an `Int` is refused at deployment (§9.2, §10.5, D-445, D-449)" begin
        deploy(rig, Δt_base; Δt_frame = 1//1, kw...) =
            Deployment(build(rig); Δt_frame, Δt_base, kw...)
        refused(rig, Δt_base; kw...) = diagnostics(failure(() -> deploy(rig, Δt_base; kw...)))
        # A frame of 2^62 units with one unit of period past its top: one frame
        # fits, and only one.
        @test deploy(unit_rig(), 1//2^62).lattice.max_frame == 1
        # A frame of `typemax(Int)` units leaves no room for the period past its
        # top: a refusal, never an `OverflowError`.
        d = only(refused(unit_rig(), 1//typemax(Int)))
        @test d isa DeploymentInvalid && d.parameter === :Δt_base && d.reason === :range &&
              d.value == 1//typemax(Int) && d.related == 1//1
        # The unit itself leaves `Int` with two coprime denominators past √typemax.
        d = only(refused(unit_rig(), 1//(10^10 + 1); Δt_frame = 1//10^10))
        @test d.parameter === :Δt_base && d.reason === :range && d.related == 1//10^10
        # A frame that fits `Int` with no room for a period past its top.
        d = only(refused(overflow_rig(), 1//9_220_000_000_000_000_000))
        @test d.parameter === :Δt_base && d.reason === :range && d.related == 1//1
        # A bound whose steps of one frame cannot be counted in an `Int`: a
        # thousand-unit frame times the bound's denominator, 2^57.
        d = only(refused(unit_rig(), 1//1000; h_max = 1//2^60))
        @test d.parameter === :h_max && d.reason === :range && d.value == 1//2^60 &&
              d.related == 1//1
        @test deploy(unit_rig(), 1//1000; h_max = 1//2^52).lattice.bound == 1000//2^52
        # A bound near half a unit over a denominator of 3^25: one frame of 2^30
        # units takes 2^31 steps, but the count `units·q` would leave `Int`.
        h_max = (3^25 ÷ 2)//3^25
        d = only(refused(unit_rig(), 1//1; Δt_frame = 2^30, h_max))
        @test d.parameter === :h_max && d.reason === :range && d.value == h_max
        # A bound whose count `units·q` fits, but whose step's exact length over
        # the unit's denominator would not: one frame of `1//(2^33 + 1)` taken in
        # about 2^30 steps.
        d = only(diagnostics(failure(() -> Deployment(build(feedback_model());
                                                      Δt_frame = 1//(2^33 + 1),
                                                      h_max = 1//typemax(Int)))))
        @test d.parameter === :h_max && d.reason === :range
        # Collected with the event parameters' faults in the one throw (D-229).
        @test Set((d.parameter, d.reason)
                  for d in refused(unit_rig(), 1//typemax(Int); firing_budget = 0)) ==
              Set([(:Δt_base, :range), (:firing_budget, :range)])
    end
end

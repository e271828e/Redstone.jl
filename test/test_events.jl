# --- events at boundaries (§2.3, §10.6, increment 6) ----------------------------

# Malformed event and projection declarations, at top level per D-164.
struct HalfEvent <: AbstractComponent end
m_init(::HalfEvent) = (s = :a,)
x_init(::HalfEvent) = nothing
y_types(::HalfEvent) = (o = Float64,)
y_state(::HalfEvent, (; m)) = (o = 1.0,)
halfevent_guard(::HalfEvent, (; m)) = m.s === :a
function halfevent_handler end                   # a name with no method: the missing half
state_events(::HalfEvent) = (go = StateEvent(halfevent_guard, halfevent_handler),)

struct NotAnEvent <: AbstractComponent end
m_init(::NotAnEvent) = (s = :a,)
x_init(::NotAnEvent) = nothing
y_types(::NotAnEvent) = (o = Float64,)
y_state(::NotAnEvent, (; m)) = (o = 1.0,)
state_events(::NotAnEvent) = (go = 5,)

struct BadGuardForm <: AbstractComponent end
m_init(::BadGuardForm) = (s = :a,)
x_init(::BadGuardForm) = nothing
y_types(::BadGuardForm) = (o = Float64,)
y_state(::BadGuardForm, (; m)) = (o = 1.0,)
badguard_guard(::BadGuardForm, (; m)) = "high"
badguard_handler(::BadGuardForm, (; m)) = (m = (; s = :b),)
state_events(::BadGuardForm) = (go = StateEvent(badguard_guard, badguard_handler),)

struct BadHandlerKey <: AbstractComponent end    # writes `x`, owns only modes
m_init(::BadHandlerKey) = (s = :a,)
x_init(::BadHandlerKey) = nothing
y_types(::BadHandlerKey) = (o = Float64,)
y_state(::BadHandlerKey, (; m)) = (o = 1.0,)
badkey_guard(::BadHandlerKey, (; m)) = m.s === :a
badkey_handler(::BadHandlerKey, (; m)) = (x = (q = 1.0,),)
state_events(::BadHandlerKey) = (go = StateEvent(badkey_guard, badkey_handler),)

struct PartialX <: AbstractComponent end         # an incomplete `x` write-back
x_init(::PartialX) = (a = 0.0, b = 0.0)
y_types(::PartialX) = (a = Float64,)
y_state(::PartialX, (; x)) = (a = x.a,)
x_deriv(::PartialX, (; x)) = (a = 1.0, b = 1.0)
partialx_guard(::PartialX, (; x)) = x.a ≥ 1.0
partialx_handler(::PartialX, (; x)) = (x = (; a = 0.0),)
state_events(::PartialX) = (reset = StateEvent(partialx_guard, partialx_handler),)

struct EventsOnDiscrete <: AbstractComponent end # `state_events` is continuous-only
s_init(::EventsOnDiscrete) = (n = 0,)
y_types(::EventsOnDiscrete) = (n = Int,)
y_state(::EventsOnDiscrete, (; s)) = (n = s.n,)
s_update(::EventsOnDiscrete, (; s)) = (n = s.n + 1,)
eod_guard(::EventsOnDiscrete, (; s)) = s.n > 0
eod_handler(::EventsOnDiscrete, (; s)) = (;)
state_events(::EventsOnDiscrete) = (go = StateEvent(eod_guard, eod_handler),)

struct ProjectOnDiscrete <: AbstractComponent end
s_init(::ProjectOnDiscrete) = (n = 0,)
y_types(::ProjectOnDiscrete) = (n = Int,)
y_state(::ProjectOnDiscrete, (; s)) = (n = s.n,)
s_update(::ProjectOnDiscrete, (; s)) = (n = s.n + 1,)
x_projection(::ProjectOnDiscrete, x) = x

struct ProjectNoState <: AbstractComponent end   # nothing to project onto
x_init(::ProjectNoState) = nothing
y_types(::ProjectNoState) = (o = Float64,)
y_state(::ProjectNoState, (; t)) = (o = 1.0,)
x_projection(::ProjectNoState, x) = x

struct BadProjectShape <: AbstractComponent end  # wrong fields back
x_init(::BadProjectShape) = (q = 1.0,)
y_types(::BadProjectShape) = (q = Float64,)
y_state(::BadProjectShape, (; x)) = (q = x.q,)
x_deriv(::BadProjectShape, (; x)) = (q = 0.0,)
x_projection(::BadProjectShape, x) = (v = x.q,)

# Event halves typed on the bundle, which the lookup must find.
const TYPED_EVENT_BUNDLE = NamedTuple{(:x, :t),<:Tuple{Real,Real}}

struct TypedBundleEvent <: AbstractComponent end
x_init(::TypedBundleEvent) = 0.0
x_deriv(::TypedBundleEvent, (; x)) = one(x)
typed_bundle_guard(::TypedBundleEvent, bundle::TYPED_EVENT_BUNDLE) = bundle.x > 0.15
typed_bundle_handler(::TypedBundleEvent, ::TYPED_EVENT_BUNDLE) = (x = 0.0,)
state_events(::TypedBundleEvent) = (go = StateEvent(typed_bundle_guard, typed_bundle_handler),)

struct MistypedGuard <: AbstractComponent end       # a method the bundle never matches
x_init(::MistypedGuard) = 0.0
x_deriv(::MistypedGuard, (; x)) = one(x)
mistyped_guard(::MistypedGuard, ::Int) = true
mistyped_guard_handler(::MistypedGuard, (; x)) = (x = x,)
state_events(::MistypedGuard) = (go = StateEvent(mistyped_guard, mistyped_guard_handler),)

struct MistypedHandler <: AbstractComponent end
x_init(::MistypedHandler) = 0.0
x_deriv(::MistypedHandler, (; x)) = one(x)
mistyped_handler_guard(::MistypedHandler, (; x)) = x > 0.15
mistyped_handler(::MistypedHandler, ::Int) = (x = 0.0,)
state_events(::MistypedHandler) = (go = StateEvent(mistyped_handler_guard, mistyped_handler),)

struct MisaddressedEvent <: AbstractComponent end   # the halves' methods are another type's
x_init(::MisaddressedEvent) = 0.0
x_deriv(::MisaddressedEvent, (; x)) = one(x)
state_events(::MisaddressedEvent) = (go = StateEvent(typed_bundle_guard, typed_bundle_handler),)

# Projections typed on the state, each a clamp the lookup must find. The field
# keeps the `Float64` one out of the `Dual` sweep, which it cannot pass (§7.2).
struct TypedBareProjection <: AbstractComponent
    limit::Float64
end
x_init(::TypedBareProjection) = 2.0
x_deriv(::TypedBareProjection, (; x)) = one(x)
x_projection(c::TypedBareProjection, x::Float64) = min(x, c.limit)

struct TypedNamedProjection <: AbstractComponent end
x_init(::TypedNamedProjection) = (q = 2.0,)
x_deriv(::TypedNamedProjection, (; x)) = (q = one(x.q),)
x_projection(::TypedNamedProjection, x::NamedTuple{(:q,),<:Tuple{Real}}) = (q = min(x.q, one(x.q)),)

struct MistypedProjection <: AbstractComponent end  # a method the state never matches
x_init(::MistypedProjection) = 2.0
x_deriv(::MistypedProjection, (; x)) = one(x)
x_projection(::MistypedProjection, x::Int) = x

struct TypedProjectOnDiscrete <: AbstractComponent end
s_init(::TypedProjectOnDiscrete) = 0
s_update(::TypedProjectOnDiscrete, (; s)) = s + 1
x_projection(::TypedProjectOnDiscrete, x::Int) = x

struct TypedProjectNoState <: AbstractComponent end
x_init(::TypedProjectNoState) = nothing
y_types(::TypedProjectNoState) = Float64
y_state(::TypedProjectNoState, (; t)) = 1.0
x_projection(::TypedProjectNoState, x::Float64) = x

# `q̇ = 1` on the manifold `q ≤ 0.5`, under a handler that writes off it. `leak`
# holds only off the manifold, so it fires iff a guard reads an unprojected write.
struct ProjectedReset <: AbstractComponent end
x_init(::ProjectedReset) = (q = 0.0,)
m_init(::ProjectedReset) = (resets = 0, leaks = 0)
y_types(::ProjectedReset) = (q = Float64,)
y_state(::ProjectedReset, (; x)) = (q = x.q,)
x_deriv(::ProjectedReset, (; x)) = (q = one(x.q),)
x_projection(::ProjectedReset, x) = (q = min(x.q, 0.5),)
projected_reset_guard(::ProjectedReset, (; x)) = x.q ≥ 0.25
projected_reset_handler(::ProjectedReset, (; x, m)) = (x = (q = 2.0,), m = (; m..., resets = m.resets + 1))
projected_leak_guard(::ProjectedReset, (; x)) = x.q > 1.0
projected_leak_handler(::ProjectedReset, (; m)) = (m = (; m..., leaks = m.leaks + 1),)
state_events(::ProjectedReset) = (reset = StateEvent(projected_reset_guard, projected_reset_handler),
                                  leak = StateEvent(projected_leak_guard, projected_leak_handler))

function test_events()
    @testset "the declaration layer and probe reject malformed events (§8.2, §9.3)" begin
        d = only(diagnostics(failure(() -> build(single(HalfEvent())))))
        @test d isa EventHalfMissing && d.event === :go && d.reason === :handler
        @test d.found == "HalfEvent"            # the component type, by name (§13.2)
        d = only(diagnostics(failure(() -> build(single(NotAnEvent())))))
        @test d isa EventHalfMissing && d.event === :go && d.reason === :not_an_event &&
              d.found == "Int64"

        d = carried(@test_throws DiagnosticError{GuardForm} build(single(BadGuardForm())))
        @test d.event === :go && d.observed === String

        err = failure(() -> build(single(BadHandlerKey())))
        d = only(diagnostics(err))
        @test d isa HandlerReturnKey && d.key === :x && d.stores == [:m]

        d = only(diagnostics(failure(() -> build(single(PartialX())))))
        @test d isa ConformanceFailure && d.reason === :field_set && d.shape === :state &&
              d.observed_fields == [:a] && d.declared_fields == [:a, :b]
        # A handler's occurrence names its event (§9.5, D-249); `what` names the
        # function alone, and the two compose in the message.
        @test d.event === :reset && d.what == "handler `x`"

        # `state_events` is continuous-only, beside `m_init` in the tier-agreement check.
        diags = Diagnostic[]
        @test classify_tier("c", EventsOnDiscrete(), diags) === nothing
        @test :state_events in [d.declaration for d in diags]
        @test all(d -> d isa DeclarationOnWrongTier, diags)

        d = only(diagnostics(failure(() -> build(single(ProjectOnDiscrete())))))
        @test d isa DeclarationOnWrongTier && d.declaration === :x_projection &&
              d.reason === :continuous_only
        d = only(diagnostics(failure(() -> build(single(ProjectNoState())))))
        @test d isa DeclarationOnWrongTier && d.reason === :no_manifold
        d = only(diagnostics(failure(() -> build(single(BadProjectShape())))))
        @test d isa ConformanceFailure && d.what == "x_projection" && d.reason === :field_set &&
              d.observed_fields == [:v] && d.declared_fields == [:q]
        @test d.event === nothing                 # no handler, no event
    end

    @testset "a half has a method whatever its bundle annotation (§8.2, §13.2, D-215)" begin
        # The guard holds at the second boundary and the handler resets `x`, so
        # three frames at `ẋ = 1` end at one step, where unfired they end at three.
        sim = Simulation(single(TypedBundleEvent()); Δt_frame = 1 // 10)
        init!(sim)
        step!(sim; frames = 3)
        @test state(sim, "c") ≈ 0.1

        # A method that rejects the bundle fails at the event probe, by its half.
        for (comp, half) in ((MistypedGuard(), "guard"), (MistypedHandler(), "handler"))
            d = diagnostic(failure(() -> build(single(comp))))
            @test d isa UserCodeFraming && d.fn == half && d.cause isa MethodError
        end

        # A method on another component's type is no method for this one.
        diags = diagnostics(failure(() -> build(single(MisaddressedEvent()))))
        @test all(d -> d isa EventHalfMissing && d.found == "MisaddressedEvent", diags)
        @test [d.reason for d in diags] == [:guard, :handler]
    end

    @testset "a method typed on the state declares `x_projection` (§5.3, §7.2, §8.2, D-350)" begin
        # The clamp runs at `init!` and after each step, where `q̇ = 1` leaves it.
        for comp in (TypedBareProjection(1.0), TypedNamedProjection())
            sim = Simulation(single(comp); Δt_frame = 1 // 10)
            init!(sim)
            @test only(state(sim, "c")) ≈ 1.0
            step!(sim; frames = 2)
            @test only(state(sim, "c")) ≈ 1.0
        end

        # A method that cannot take the state is refused, never dropped.
        d = diagnostic(failure(() -> build(single(MistypedProjection()))))
        @test d isa UserCodeFraming && d.fn == "x_projection" && d.cause isa MethodError

        # The `Dual` probe still checks §7.2's obligation on a typed projection.
        @test build(single(TypedNamedProjection()); activations = (ProbeDual,)) isa Build
        d = diagnostic(failure(() -> build(single(TypedBareProjection(1.0));
                                           activations = (ProbeDual,))))
        @test d isa UserCodeFraming && d.fn == "x_projection" && d.cause isa MethodError

        # The tier refusals read the typed method as they read an untyped one.
        d = only(diagnostics(failure(() -> build(single(TypedProjectOnDiscrete())))))
        @test d isa DeclarationOnWrongTier && d.reason === :continuous_only
        d = only(diagnostics(failure(() -> build(single(TypedProjectNoState())))))
        @test d isa DeclarationOnWrongTier && d.reason === :no_manifold
    end

    @testset "the guard's form is the declared policy (§2.3, §10.4, D-179)" begin
        @test build(fed(Trigger(0.5), "sig")).events.components[1].policies === (fire = :non_localized,)
        @test build(single(Sawtooth(0.3))).events.components[1].policies === (wrap = :localized,)
        @test build(single(Rotor())).events.components[1].policies === NamedTuple()
    end

    @testset "the events product carries the policies and the bundle names (§9.1, D-253)" begin
        # `Events` is the nominal evaluation's last product: one row per
        # component, its policy register beside the bundle its guards and
        # handlers are called with. A component with no events carries an empty
        # register and no bundle.
        @test build(fed(Trigger(0.5), "sig")).events.components[1].bundle === (:m, :u, :y, :t)
        @test build(single(Rotor())).events.components[1].bundle === ()
    end

    @testset "edge semantics: a u-edge fires at its boundary, a sticky predicate once" begin
        sim = Simulation(fed(Trigger(0.5), "sig"); Δt_frame = 1//10)
        init!(sim, set(u = (in = 0.0,)))    # authored at 0.0: not holding
        step!(sim; t_plus = 0.3)
        @test modes(sim, "c").count == 0
        stage!(sim, "in" => 1.0)                     # the input epoch seam, staged (§11.4)
        step!(sim; t_plus = 0.3)                     # drained at the frame top: the first boundary sees the edge
        @test modes(sim, "c") === (state = :fired, count = 1)
        @test port(sim, "c", :on) === true  # the settled sweep published the new mode
        step!(sim; t_plus = 0.9)                     # sticky: holding presents no further edge
        @test modes(sim, "c").count == 1

        # Boundary zero establishes every prior as not-holding (§10.6): a predicate
        # already holding in the authored state fires at t₀ — derived, not asserted.
        sim2 = Simulation(fed(Trigger(0.5), "sig"); Δt_frame = 1//10)
        init!(sim2, set(u = (in = 1.0,)))
        @test modes(sim2, "c").count == 1
        # A warm restart resets the registers from scratch: it fires again — and
        # from the declared defaults, so `count` restarts at 0 and reaches 1, never 2
        # (D-063).
        init!(sim2, set(u = (in = 1.0,)))
        @test modes(sim2, "c").count == 1
    end

    @testset "the priors survive a restore: a holding guard does not fire again (§12.6, D-274)" begin
        sim = Simulation(fed(Trigger(0.5), "sig"); Δt_frame = 1//10)
        init!(sim, set(u = (in = 0.0,)))
        stage!(sim, "in" => 1.0)
        step!(sim; frames = 3)                       # fired at frame 1, holding since
        @test modes(sim, "c") === (state = :fired, count = 1)
        cp = checkpoint(sim)
        @test cp.state.prior == [true]

        # The restore resets no prior, so the next boundary sees no edge.
        twin = Simulation(fed(Trigger(0.5), "sig"); Δt_frame = 1//10)
        restore!(twin, cp)
        @test twin.model.exec.events.prior == [true] && twin.model.exec.events.last == [true]
        step!(twin)
        @test modes(twin, "c") === (state = :fired, count = 1)

        # `init!` from the same stores establishes the prior as not-holding, so
        # boundary zero fires the holding guard again (§10.6).
        fresh = Simulation(fed(Trigger(0.5), "sig"); Δt_frame = 1//10)
        init!(fresh, combine(at("c", set(m = (state = :fired, count = 1))),
                             set(u = (in = 1.0,))))
        @test modes(fresh, "c") === (state = :fired, count = 2)
    end

    @testset "a cascade settles within one boundary, independently of h (§10.6)" begin
        chain() = Group((; trig = Trigger(0.5), f1 = Follower(), f2 = Follower());
                        local_wires = ("trig/on" => "f1/go",
                                 "f1/on" => "f2/go"),
                        input_wires = ("in" => "trig/sig",))
        for h in (1//10, 1//1000)                    # the latency is rounds, never steps
            sim = Simulation(chain(); Δt_frame = h)
            init!(sim, set(u = (in = 1.0,)))    # one boundary: three rounds to quiescence
            @test modes(sim, "trig").state === :fired
            @test modes(sim, "f1").state === :on
            @test modes(sim, "f2").state === :on
            @test port(sim, "f2", :on) === true
        end
    end

    @testset "priority with re-decision: a blocked edge stands, a falsified premise re-decides (D-191)" begin
        # Both events present the same edge; `first` fires by declaration order and
        # `second` is eligible but blocked — its sample is not overwritten, so the
        # standing edge fires it in the next round.
        sim = Simulation(fed(TwoShot(), "sig"); Δt_frame = 1//10)
        init!(sim, set(u = (in = 2.0,)))
        @test modes(sim, "c") === (a = true, b = true)

        # The premise the first transition falsifies: re-decided against the
        # post-transition sweep, `second` never fires on its stale round-1 edge.
        preempted_sim = Simulation(fed(Preempted(), "sig"); Δt_frame = 1//10)
        init!(preempted_sim, set(u = (in = 2.0,)))
        @test modes(preempted_sim, "c") === (a = true, b = false)
    end

    @testset "an x-writing handler's carried overshoot is resolution-invariant" begin
        # The sawtooth's wrap now genuinely localizes, but its carrying handler
        # (`q ← q − 1`) makes the *boundary states* invariant to where the firing
        # lands, so the boundary recursion stays the exact reference — and the
        # second wrap crosses inside an *off-tick* frame under two frames per base tick, which must
        # fire it all the same.
        q_ref(n_steps) = (q = 0.0;
                          for _ in 1:n_steps; q += 0.03; q ≥ 1 && (q -= 1); end; q)
        for n_base in (1, 2)
            sim = Simulation(single(Sawtooth(0.3)); Δt_frame = 1//10, Δt_base = n_base // 10)
            init!(sim)
            step!(sim; t_plus = 6.7)                 # boundary 67: the off-tick wrap
            @test state(sim, "c").q ≈ q_ref(67) rtol = 1e-9
            step!(sim; t_plus = 0.3)
            @test state(sim, "c").q ≈ q_ref(70) rtol = 1e-9
            @test port(sim, "c", :q) ≈ q_ref(70) rtol = 1e-9   # the post-fire re-sweep published it
        end
    end

    @testset "due updates run after quiescence, from post-transition values (§10.6)" begin
        # At the wrap boundary the handler resets `q`, the re-sweep publishes the
        # post-wrap value, and only then does the integrator's `s_update` read it: an
        # update-before-quiescence would accumulate 1.02 where the reference has
        # 0.02.
        model = Group((; saw = Sawtooth(0.3), ctl = DiscreteAccumulator(1.0));
                      local_wires = ("saw/q" => "ctl/e",))
        sim = Simulation(model; Δt_frame = 1//10)
        init!(sim)
        run!(sim; t_end = 4.0)
        q, acc = 0.0, 0.0
        for _ in 1:40
            q += 0.03
            q ≥ 1 && (q -= 1)
            acc += 0.1 * q
        end
        @test state(sim, "ctl").acc ≈ acc rtol = 1e-9
    end

    @testset "budget exhaustion degrades, reported on the loop's cell (§10.6, §11.8)" begin
        chatty() = Group((; chat = Chatterer(), trig = Trigger(0.5));
                         input_wires = ("in" => "trig/sig",))
        sim = Simulation(chatty(); Δt_frame = 1//10)
        init!(sim, set(u = (in = 1.0,)))            # exhaustion at boundary zero
        @test modes(sim, "chat").flips == 8         # 2 × the default budget of 4
        @test modes(sim, "trig").count == 1         # the sibling fired normally
        # The report rides the loop's own diagnostic cell (§11.8), folded at the
        # next frame top: boundary zero's snapshot shows nothing yet.
        @test writer_status(latest(sim), "loop").totals.firing == 0
        step!(sim; t_plus = 0.1)                             # one frame: its snapshot carries the delta
        loop_status = writer_status(latest(sim), "loop")
        d = only(loop_status.recent)
        @test d isa FiringBudget
        @test d.path == "chat" && d.event == :up
        @test d.budget == 4 && d.count == 4 &&
              d.t == 0.0
        @test loop_status.totals.firing == 1
        step!(sim; t_plus = 0.2)                             # the exhausted boundary's samples
        @test modes(sim, "chat").flips == 8         # became honest priors: quiescent now
        loop_status = writer_status(latest(sim), "loop")     # quiescent frames: the delta has
        @test isempty(loop_status.recent) && loop_status.totals.firing == 1    # passed, the session's totals stand

        # Totals count since the run began (§11.8): the warm restart re-exhausts
        # its own boundary zero — the stores restart from the declared defaults
        # (D-063) and the priors reset with them — and the new run's totals carry
        # that one occurrence, never the last trajectory's.
        init!(sim, set(u = (in = 1.0,)))
        run!(sim; t_end = 0.1)
        @test modes(sim, "chat").flips == 8
        @test writer_status(latest(sim), "loop").totals.firing == 1

        # The budget is a deployment keyword, validated with its siblings.
        sim2 = Simulation(chatty(); Δt_frame = 1//10, firing_budget = 2)
        init!(sim2, set(u = (in = 1.0,)))
        @test modes(sim2, "chat").flips == 4
        run!(sim2; t_end = 0.1)
        d = only(writer_status(latest(sim2), "loop").recent)
        @test d isa FiringBudget && d.budget == 2 &&
              d.count == 2
        d = only(diagnostics(failure(() -> Simulation(chatty(); Δt_frame = 1//10, firing_budget = 0))))
        @test d isa DeploymentInvalid && d.parameter === :firing_budget
    end

    @testset "projection runs at every boundary, between write and decode (§5.3)" begin
        sim = Simulation(single(Rotor(; ω = 2.0, r₀ = SVector(2.0, 0.0))); Δt_frame = 1//100)
        init!(sim)
        # Boundary zero already projects (§14.5), and the sweep decodes the
        # projected state — a wrong order would publish c = 2.0.
        @test state(sim, "c").r ≈ SVector(1.0, 0.0) atol = 1e-15
        @test port(sim, "c", :c) == 1.0
        run!(sim; t_end = 1.0)
        r = state(sim, "c").r
        @test r[1]^2 + r[2]^2 ≈ 1.0 atol = 1e-14             # pinned to the manifold
        @test r ≈ SVector(cos(2.0), sin(2.0)) rtol = 1e-6    # and still the right trajectory
    end

    @testset "each firing projects before the round's guards and sweep read the state (§5.3, §10.6)" begin
        sim = Simulation(single(ProjectedReset()); Δt_frame = 1//10)
        init!(sim)
        step!(sim; frames = 2)
        @test modes(sim, "c") == (resets = 0, leaks = 0)
        @test state(sim, "c").q ≈ 0.2 atol = 1e-12
        # `q` reaches 0.3 and the handler writes 2.0. The next round's guards read
        # the projected 0.5, so `leak` stays quiet, and the sweep publishes 0.5.
        step!(sim; frames = 1)
        @test modes(sim, "c") == (resets = 1, leaks = 0)
        @test state(sim, "c").q ≈ 0.5 atol = 1e-12
        @test port(sim, "c", :q) ≈ 0.5 atol = 1e-12
        step!(sim; frames = 3)
        @test modes(sim, "c") == (resets = 1, leaks = 0)     # the edge is spent, and `q` stays pinned
        @test state(sim, "c").q ≈ 0.5 atol = 1e-12
    end

    @testset "events compile out at a non-nominal activation (§9.4, D-052)" begin
        dual_model = Model(fed(Trigger(0.5), "sig"), D8; Δt_frame = 1//10)
        @test isempty(dual_model.exec.events.entries)
        init!(dual_model, set(u = (in = D8(1.0),)))
        frames!(dual_model, 3)                      # `run!` to 0.3
        @test modes(dual_model, "c").count == 0     # the guard never ran

        # Projection is continuous machinery, inside every executable set.
        rotor_model = Model(single(Rotor(; r₀ = SVector(2.0, 0.0))), D8; Δt_frame = 1//100)
        init!(rotor_model)
        @test ForwardDiff.value(state(rotor_model, "c").r[1]) ≈ 1.0 atol = 1e-15
    end

    @testset "gate 3: a quiet boundary with events does not allocate (§9.8)" begin
        # The first iteration round always runs, so guard evaluation is on the
        # measured path even when nothing ever fires.
        sim = Simulation(fed(Trigger(0.5), "sig"); Δt_frame = 1//10)
        init!(sim, set(u = (in = 0.0,)))
        boundary!(sim, 1); offtick_boundary!(sim)
        @test @ballocated(boundary!($sim, 1)) == 0
        @test @ballocated(offtick_boundary!($sim)) == 0
        @test @ballocated(integrate!($sim, 0.1)) == 0

        rotor_sim = Simulation(single(Rotor()); Δt_frame = 1//100)  # projection on the measured path
        init!(rotor_sim)
        boundary!(rotor_sim, 1)
        @test @ballocated(boundary!($rotor_sim, 1)) == 0
    end

    @testset "a handler's mode flip reaches its cell through the next sweep (§5.3, D-154)" begin
        # `Overload` returns `tripped` from stage 1. The table is written by
        # sweeps and by nothing else (D-154), so the handler's round is followed
        # by a sweep before anything is read — which is why the cell and the
        # store agree at the boundary, and why the snapshot taken there already
        # carries the flip.
        sim = Simulation(overloaded(); Δt_frame = 1//10)
        init!(sim)
        @test port(sim, "mon", :tripped) === false       # before the crossing
        run!(sim; t_end = 5.0)
        record = termination(sim)
        @test record.source === ModelRequestedStop("stop", :y, "overload tripped")
        @test record.t ≈ 0.315 atol = 1e-6               # the localized crossing
        @test modes(sim, "mon").tripped === true
        @test port(sim, "mon", :tripped) === true
        @test port(latest(sim), "mon", :tripped) === true
    end

    @testset "an overlay fires the guard it moves into holding, at the overlay boundary (§12.6, D-429)" begin
        # A root-input entry lifts the trigger's input over its level: the prior
        # is kept, so that is an edge, and the handler runs before the next frame.
        sim = Simulation(fed(Trigger(0.5), "sig"); Δt_frame = 1//10)
        init!(sim, set(u = (in = 0.0,)))
        step!(sim; frames = 2)
        @test modes(sim, "c") === (state = :armed, count = 0)
        overlay!(sim, set(u = (in = 1.0,)))
        @test port(sim, "", :in) == 1.0 && latest(sim).t == 0.2
        @test modes(sim, "c") === (state = :fired, count = 1) && port(sim, "c", :on) === true
        step!(sim)
        @test modes(sim, "c") === (state = :fired, count = 1)

        # An overlaid `x` past the sawtooth's sign-form guard: the handler wraps
        # it at the overlay boundary, and the next frame integrates from there.
        saw = Simulation(single(Sawtooth(1.0)); Δt_frame = 1//10)
        init!(saw)
        step!(saw; frames = 2)
        overlay!(saw, at("c", set(x = (q = 1.5,))))
        @test state(saw, "c").q ≈ 0.5 && port(saw, "c", :q) ≈ 0.5
        step!(saw)
        @test state(saw, "c").q ≈ 0.6
    end

    @testset "an overlay keeps the priors and merges a partial store onto the current one (§12.6, §14.1, D-429)" begin
        sim = Simulation(fed(Trigger(0.5), "sig"); Δt_frame = 1//10)
        init!(sim, set(u = (in = 0.0,)))
        stage!(sim, "in" => 1.0)
        step!(sim; frames = 3)                       # fired at frame 1, holding since
        @test modes(sim, "c") === (state = :fired, count = 1)
        overlay!(sim, at("c", set(m = (count = 7,))))
        @test modes(sim, "c") === (state = :fired, count = 7)   # `state` from the current store, not `m_init`
        @test sim.model.exec.events.prior == [true]              # kept, so no edge: no re-fire
        step!(sim)
        @test modes(sim, "c") === (state = :fired, count = 7)
    end

    @testset "an overlaid state off the manifold is projected before publication (§5.3, §12.6, D-429)" begin
        sim = Simulation(single(Rotor(; ω = 2.0)); Δt_frame = 1//100)
        init!(sim)
        step!(sim)
        overlay!(sim, at("c", set(x = (r = SVector(3.0, 0.0),))))
        @test state(sim, "c").r ≈ SVector(1.0, 0.0) atol = 1e-15
        @test port(sim, "c", :c) == 1.0
    end

    @testset "a handler's `x` and `m` replace a bare state and a bare mode store whole (§5.2, §9.5)" begin
        # `x[1] = t` reaches 1 at `t = 1`, and the handler reflects the rate and
        # latches the mode, so `x[1] = 2 - t` after it.
        sim = Simulation(single(BareLatch()); Δt_frame = 1//10)
        init!(sim)
        step!(sim; t_plus = 0.5)
        @test modes(sim, "c") === false && port(sim, "c", :latched) === false
        step!(sim; t_plus = 1.0)
        @test modes(sim, "c") === true && port(sim, "c", :latched) === true
        @test state(sim, "c") ≈ SVector(0.5, -1.0) atol = 1e-9
        @test build(single(BareLatch()); activations = (Float64, LinearizeDual)) isa Build
    end
end

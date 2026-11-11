# The model's frame (§10.4, §10.5): the loop that carries frame `k` from its top
# to the next, through every boundary in between. The frame tops and the due
# instants, the base ticks at which some discrete component is due, are the
# mandatory instants, on two lattices in no required ratio (D-445). A span runs
# from one mandatory instant to the next, and the method takes it in the fewest
# equal steps the deployment's `h_max` allows (D-449), so a due instant inside
# the frame ends a span and every step end is a boundary. With localized events
# each step is carried through `integrate → arrival sweep → trigger → θ = 0
# validation → bracket → root-find → t* → remainder step`, iterated under the
# frame's `localization_budget` (D-446). A sign-form guard's crossing is
# bracketed by trial evaluations over the seam's dense output (§10.2, `dense!`)
# and fired at a `t*` boundary, strictly inside the step.
#
# Frame ≠ boundary (§10.1): the frame `[tₖ₋₁, tₖ]` is the unit of scheduling —
# the drain and the trace key to it — while a boundary is a published
# consistency point. Every step end and every `t*` is a boundary, and each goes
# to `settled!` as the frame top's does (D-317).

# Design: §10.3, §10.4, §10.5, §13.4, §13.5, D-261, D-268, D-317, D-444, D-445,
# D-447, D-449, D-450. The cursor's `:drain` phase is written first. Mandatory
# instants are whole units of the deployment's `Lattice`, so the next one and
# every coincidence are integer comparisons, and each boundary's clock is
# written once: a frame top `t₀ + k·Δt_frame`, a due instant from its base-tick
# index, an interior step end from its span's start and its count in the span.
# A model with no localized events, every non-nominal activation included since
# its events compiled out, takes the bare step by its exact length: no arrival
# machinery, no extra sweep. The whole frame is §13.4's one `try`, and the
# `StepError` is the one constructor's. Its catch wraps every throw, an
# interrupt included, since the status says whether the stores are a settled
# boundary and the cause says what cut the frame. The index bound and the
# claim's gate precede it.
"""
    frame!(model::Model, k::Int, hooks::FrameHooks = NoHooks()) -> Bool

Advance the model through [frame](@ref g-frame) `k`, from `tₖ₋₁` to `tₖ`, and
settle every [boundary](@ref g-boundary) in it.

`k` must be the frame after the clock's, which `frame!` does not check. A frame
starts with `frame_top!(hooks)`, before the model touches any state. It then
integrates from each [mandatory instant](@ref g-mandatory-instant) to the next
in the fewest equal steps the deployment's `h_max` allows. At a
[due](@ref g-due) instant the discrete [components](@ref g-component) due there
run their stages and updates. A [localized](@ref g-localized) event adds a
boundary at its time [`t*`](@ref g-t). Every step end is a boundary, and the
last is the frame top `tₖ`. `settled!(hooks)` follows every boundary.

A `Model` at a `Dual` has no events and freezes its discrete components, and it
takes the same steps as at `Float64`.

`frame!` returns whether `settled!` asked to abandon the frame. A `true` before
the frame top leaves the rest of the frame unrun. The clock stays at that
boundary, where the [stores](@ref g-store) are, and the frame top is never
reached. See [`FrameHooks`](@ref) for the hooks, and [`NoHooks`](@ref) for a
model stepped on its own.

A model claimed by a [`Simulation`](@ref) is refused as `ArgumentInvalid`, and
so is a `k` past the last frame the run may take. That is the last frame whose
positions the deployment's lattices index in an `Int` and whose clocks the
origin resolves in order. A throw inside the frame writes the status `:inconsistent` and
arrives as a `StepError` with host `:loop`, an `InterruptException` included.
Its `boundary` is `k - 1`, the boundary the frame started from.
"""
function frame!(model::Model, k::Int, hooks::FrameHooks = NoHooks())
    _claimed_gate(model, hooks, :frame!)
    last_frame = _last_frame(model)
    k ≤ last_frame ||
        throw(DiagnosticError(ArgumentInvalid(call = :frame!, reason = :range, argument = :k,
                                              value = k, related = last_frame)))
    try
        cursor = model.exec.cursor
        cursor.comp = 0; cursor.fn = :none   # no stale frame for a top-side throw (§13.4)
        _phase!(cursor, :drain)
        # the top hook's `false` reports nothing written, so the table is the last
        # boundary's (D-447); anything else is a write
        fresh = frame_top!(hooks) === false
        return _frame_steps!(model, k, hooks, fresh)
    catch err
        model.fresh = false
        @atomic :release model.status = :inconsistent
        rethrow(_wrap_step(model, k - 1, :loop, err))   # the model's backtrace kept
    end
end

# The frame's spans (§10.5, D-445, D-449), two nested loops. The outer one runs
# over the mandatory instants: `origin` is the frame top `tₖ₋₁`'s position and
# `position` the span's start as an offset from it, both in units, and the next
# due instant is recomputed only after one is reached. The inner one takes the
# span's `n = ⌈g / h_max⌉` equal steps, `n` one `cld` over the bound's exact
# ratio to the unit. A step's exact length is `(units·unit)/n`, so a harmonic
# bound steps by `h_max` itself and a span of one step by its own length. An
# interior step end has no position: its clock is the span's start clock plus
# its count times that length, never accumulated (D-449). Returns `settled!`'s
# answer at the frame top, and `true` where it abandoned the frame at an
# earlier boundary.
function _frame_steps!(model::Model{T}, k::Int, hooks::FrameHooks, fresh::Bool) where {T}
    exec, deployment = model.exec, model.deployment
    lattice, rows = deployment.lattice, deployment.schedule.rows
    origin = (k - 1) * lattice.frame
    (due, due_at) = _next_due(rows, lattice.base, origin)
    exec.has_localized && fill!(exec.events.loc_warned, false)   # one report per event per frame
    localizations = 0                                             # the frame's, across its steps (D-446)
    position, t_from = 0, _grid_time(model, k - 1)
    while true
        target = min(lattice.frame, due_at - origin)
        is_top = target == lattice.frame
        is_due = target == due_at - origin
        t_to = is_top ? _grid_time(model, k) : _tick_time(model, due)
        units = target - position
        steps = cld(units * denominator(lattice.bound), numerator(lattice.bound))
        h = Float64((units * lattice.unit) / steps)
        for i in 1:steps
            span_end = i == steps
            t_next = span_end ? t_to : t_from + i * h
            if exec.has_localized
                (abandoned, localizations) =
                    _localized_step!(model, t_next, k, hooks, fresh, localizations)
                abandoned && return true
            else
                integrate_step!(model, T(h), k, fresh)
            end
            exec.clock.t = t_next
            if span_end && is_due
                run_boundary!(model, due)
            else
                run_boundary!(model, nothing)
            end
            # Every settled boundary may end the frame (§13.5): a `true` before the
            # frame top abandons the remainder and reaches the loop as `frame!`'s
            # return (D-261, D-317).
            abandon = settled!(hooks)
            (span_end && is_top || abandon) && return abandon
            fresh = true
        end
        is_due && ((due, due_at) = _next_due(rows, lattice.base, origin + target))
        position, t_from = target, t_to
    end
end

# The localization loop (§10.4, D-446), over one step ending at `t_to`. Each turn
# integrates one segment — the whole step first, then remainder steps from each
# `t*` — and either returns at the step's end or fires one `t*` boundary and goes
# around. A segment integrates by the distance from the clock to `t_to`, since
# its interpolant spans those two instants. The budget counts the frame's
# localizations, one per `t*` boundary produced, across all its steps: per
# segment, root-finding runs are already structurally bounded (at most one per
# declared event), while the segment count is the quantity chattering inflates
# without bound. Returns whether `settled!` abandoned the frame at a `t*`
# boundary, and the frame's localization count (D-261, D-317).
function _localized_step!(model::Model, t_to, k::Int, hooks::FrameHooks, fresh::Bool,
                          localizations::Int)
    exec = model.exec
    events, cursor = exec.events, exec.cursor
    n_events = length(events.prior)
    (x₀, _) = startpoint(exec.stepper)         # the seam's retained pair (§10.2):
    while true                                 # x₀ = x(t_seg) after each integrate!
        t_seg = exec.clock.t
        h′ = t_to - t_seg
        integrate_step!(model, h′, k, fresh)
        # The arrival sweep at the segment's end — interior, on the raw
        # unprojected state, before any discrete cell refreshes (§10.4): the
        # sweep that closes the integration step is what raises the trigger.
        _phase!(cursor, :arrival)
        exec.bodies.sweep_1(); exec.bodies.sweep_2()
        _guards!(events, exec.store, exec.xbuf)
        copyto!(events.σ1, events.σ)

        # The trigger (§10.4): localized policy, prior not-holding at the last
        # boundary's quiescence, holding at arrival — §2.3's directional edge.
        any_triggered = false
        for i in 1:n_events
            events.triggered[i] = events.localized[i] && !events.prior[i] &&
                                  events.σ1[i] ≥ 0
            any_triggered |= events.triggered[i]
        end
        any_triggered || return (false, localizations)

        # Budget exhaustion degrades; it does not throw (§10.4): the remainder
        # step has already completed, and this crossing fires in the coming
        # boundary's ordinary iteration, at the step's end — boundary
        # granularity for the rest of this frame.
        if localizations ≥ model.deployment.localization_budget
            for i in 1:n_events
                (events.triggered[i] && !events.loc_warned[i]) || continue
                events.loc_warned[i] = true   # at most one report per event per frame
                (path, name) = events.names[i]
                # the frame's own cell (§11.8, D-317): folded at the next frame top
                report_cell!(model.frame_diag,
                             ChatteringBudget(path, name, _seconds(t_to),
                                              model.deployment.localization_budget,
                                              localizations))
            end
            return (false, localizations)
        end

        copyto!(exec.xnext, exec.xbuf)   # retain xₙ₊₁ before the trials clobber it

        # The θ = 0 validation (§10.4): x(t_seg) back into the buffer, one
        # interior sweep, no interpolant — x̂(0) = xₙ identically. σ₀ is the left
        # bracket value, and it discriminates the edge's cause: σ₀ holding means
        # the frame-top drain flipped the guard (`u` is the only thing that can
        # differ from the prior's evaluation context), so no in-step crossing
        # exists — not localizing is the action, and it consumes no budget. A
        # step that starts inside the frame has no drain before it, so there σ₀
        # reproduces the prior and the branch never fires.
        copyto!(exec.xbuf, x₀)
        exec.clock.t = t_seg
        _phase!(cursor, :validation)
        exec.bodies.sweep_1(); exec.bodies.sweep_2()
        _guards!(events, exec.store, exec.xbuf)
        copyto!(events.σ0, events.σ)
        remaining = false
        for i in 1:n_events
            events.triggered[i] = events.triggered[i] && events.σ0[i] < 0
            remaining |= events.triggered[i]
        end
        if !remaining
            # epoch-caused only: fall through to the step's end
            copyto!(exec.xbuf, exec.xnext)
            return (false, localizations)
        end

        # ẋₙ₊₁, paid only past a validated trigger (§10.4): one sweep and the
        # RHS block at the arrival state completes the interpolant's data.
        copyto!(exec.xbuf, exec.xnext)
        exec.clock.t = t_seg + h′
        _phase!(cursor, :arrival)        # never a stage: `evaluate!` counts within the phase
        evaluate!(model)
        copyto!(exec.ẋnext, exec.ẋbuf)

        # Root-find each validated event; the boundary fires at the earliest t*
        # (§10.4). Ties need no decision — every standing edge at θ★ fires in
        # the boundary's own iteration — and a later crossing simply does not
        # hold at θ★, so it re-triggers on the remainder and re-localizes there.
        θ★ = 1.0
        for i in 1:n_events
            events.triggered[i] || continue
            θ★ = min(θ★, _crossing(model, i, events.σ0[i], events.σ1[i], t_seg, h′))
        end
        if θ★ ≥ 1.0
            # Degenerate: the crossing is the step's end itself (§10.4, D-446).
            # The localization is discarded and the event fires inside that
            # boundary's ordinary iteration — one boundary, no zero-length
            # remainder.
            copyto!(exec.xbuf, exec.xnext)
            return (false, localizations)
        end

        # The t* boundary (§10.4): interpolated state in, then the §10.6
        # sequence with ticks never due — t* lies strictly inside a step, and
        # every due instant ends one, so this is the empty due set: projection
        # (authority rests here, not with the raw trials), the full event
        # phase iterated to quiescence under a fresh firing budget, priors
        # updated from the settled samples — and the settled boundary goes to
        # `settled!` before integration resumes (§11.2): every boundary is a
        # published consistency point. The interpolant is invalidated by falling
        # out of scope — the handlers made it a lie for t > t*.
        dense!(exec.stepper, exec.xbuf, exec.xnext, exec.ẋnext, θ★, h′)
        exec.clock.t = t_seg + θ★ * h′
        run_boundary!(model, nothing)

        # Every settled boundary may end the frame (§13.5): a `true` makes this
        # boundary the frame's last, its remainder abandoned, and reaches the
        # loop as `frame!`'s return (D-261, D-317). The remainder's first stage
        # reads the table this boundary left (D-447).
        settled!(hooks) && return (true, localizations)
        localizations += 1
        fresh = true
    end
end

"""
One trial evaluation (§10.4): write x̂(θ) into the state buffer, set the
mid-step clock, run the interior sweep, evaluate the guards. Discrete cells
ZOH-hold through it — the interior sweep has no discrete entries — and the
state is raw: projection's reach is the boundary, not the trial.
"""
function _trial!(model::Model, θ::Float64, t_seg, h′)
    exec = model.exec
    dense!(exec.stepper, exec.xbuf, exec.xnext, exec.ẋnext, θ, h′)
    exec.clock.t = t_seg + θ * h′
    exec.bodies.sweep_1(); exec.bodies.sweep_2()
    _guards!(exec.events, exec.store, exec.xbuf)
    nothing
end

"""
Bracketed, derivative-free root-finding over trial evaluations (§10.4, D-018):
ITP (Oliveira & Takahashi 2020) on the θ ∈ [0, 1] bracket, entered only with
σ₀ measured not-holding and σ₁ holding — the observed bracket *is* the
convergence certificate. Stops once the bracket is narrower than
`localization_tol · Δt_frame` in time — `tol·Δt_frame/h′` in θ, so a shorter
segment stops sooner (§10.4, D-446) — and returns the **holding endpoint of the
final bracket** — every `hi` is an actual observation, so the returned
point is strictly later than the segment start and the guard observably holds
there. A return of exactly 1.0 is the degenerate crossing at the step's end,
discarded by the caller.
"""
function _crossing(model::Model, i::Int, σ₀::Float64, σ₁::Float64, t_seg, h′)
    events = model.exec.events
    # The stop is a width in time, `localization_tol · Δt_frame` (§10.4, D-446).
    # In θ over a segment shorter than the frame it widens by Δt_frame/h′; past
    # 1 the segment is already within tolerance, no trial runs, and the
    # crossing folds into the segment's end.
    tol = model.deployment.localization_tol * model.deployment.Δt_frame / _seconds(h′)
    lo, hi = 0.0, 1.0
    σlo, σhi = σ₀, σ₁
    # ITP constants over the unit bracket: κ₁ = 0.2, κ₂ = 2, n₀ = 1; ε is the
    # half-width target, and past n_max the projection radius hits zero, which
    # degrades each remaining iteration to plain bisection.
    ε = tol / 2
    n_max = max(ceil(Int, -log2(tol)), 0) + 1
    j = 0
    while hi - lo > tol
        θ_mid = 0.5 * (lo + hi)
        (lo < θ_mid < hi) || break                       # the bracket is at float resolution
        θ_falsi = (lo * σhi - hi * σlo) / (σhi - σlo) # regula falsi, well-defined: σlo < 0 ≤ σhi
        direction = sign(θ_mid - θ_falsi)
        δ = 0.2 * (hi - lo)^2
        # truncate toward the midpoint
        θ_trunc = δ ≤ abs(θ_mid - θ_falsi) ? θ_falsi + direction * δ : θ_mid
        radius = max(ε * exp2(n_max - j) - 0.5 * (hi - lo), 0.0)
        # project into the minmax radius
        θ = abs(θ_trunc - θ_mid) ≤ radius ? θ_trunc : θ_mid - direction * radius
        (lo < θ < hi) || (θ = θ_mid)
        _phase!(model.exec.cursor, :trial, j + 1)   # the trial ordinal, from 1 (§13.4)
        _trial!(model, θ, t_seg, h′)
        σθ = events.σ[i]
        σθ ≥ 0 ? (hi = θ; σhi = σθ) : (lo = θ; σlo = σθ)
        j += 1
    end
    hi
end

# One frame, end to end: the loop mapped to the implementation

*Companion explainer, non-normative. The spec ([§10.4][s10-4], [§10.5][s10-5], [§10.6][s10-6]; the seam
in [§10.2][s10-2], publication in [§11.2][s11-2]) wins wherever the two disagree. Written
against the tree at `e6696a7` ([D-431][d-431]): every function named here is the
implementation's, and the code moves more often than the spec. Function names
are given without line numbers for that reason; `grep` finds them. The quotes
of `frame.jl` and the boundary routine follow the span loop of
[D-449][d-449], and those of the seam its protocol of [D-452][d-452].*

This document follows a single frame through the frame loop and names, at
each step, the function that performs it. It exists because the spec states
the loop's rules across four sections, and the implementation spreads their
mechanics across five files. `sim.jl` owns the advance loop, the drain and
publication. `frame.jl` owns the frame and its localization, `model.jl` the
boundary entries and the event phase, `stepper.jl` the integration seam, and
`executor.jl` the compiled sweeps and the event registers. A reader with the
code open beside this document can follow one frame and know which rule each
line serves.

The running example is a deployment with `Δt_frame = 1//100` and
`Δt_base = 1//25`, so only every fourth frame top is a base tick. The model
holds a continuous plant with a localized sign-form guard, and a discrete
controller with `(D, Φ) = (1, 0)`, which ticks at every base tick. The frame
followed is `k = 8`, whose top `t = 0.08` is base tick `2`; section 3 notes
where frame `k = 7`, an off-tick frame top, differs. The deployment sets no
`h_max`, so each frame is one span taken in one step, and its end is the
frame top.

## Section 1 — The frame loop and the drain

**The frame top.** One iteration of `_advance!`, the frame loop in `sim.jl`,
is one frame. `run!` and `step!` both enter that loop. It checks the stop word and the frame
bounds, advances the run's frame index, and hands the frame to the model's
`frame!` in `frame.jl`. The model drains, integrates, runs the boundary and
publishes through two hooks:

```julia
# sim.jl, _advance!
hit = run_frame!(sim.model, run.frame + 1, hooks, advanced > 0)
requester = hit ? _stop_hit(sim, ignore_mask) : nothing

# frame.jl, inside run_frame! and _frame_steps!
_phase!(cursor, :drain)
wrote = frame_top!(hooks)             # drain!, and whether it wrote a value
...                                   # integration, section 2
exec.clock.t = t_to
is_due ? run_boundary!(model, due) : run_boundary!(model, nothing)
settled!(hooks)                       # publish!, then _stop_hit
```

`hooks` is the advance's `LoopHooks`, built once per advance. It carries
`roster`, the run's copy of the frozen roster ([§11.3][s11-3]). It
carries `ignore_mask`, the advance's stop policy compiled into a mask of
ignored requesters ([§13.5][s13-5]). It also carries `pacer`, the run's pacer
([§10.7][s10-7]), which `step!` leaves `nothing`. The model reaches the simulation
only through the two hooks. `frame_top!` runs `drain!`, and `settled!` runs
`publish!` and then `_stop_hit`.

Three things happen in order, all inside the frame's one `try` ([§13.4][s13-4]). The
top hook applies the device writes. The integration carries the continuous
state across `[t₇, t₈]` and fires any localized event inside it. The one
boundary routine then runs at the frame top over its due set. For `k = 8`
the frame top is due instant `2`, the base-tick index `_next_due` computed
from the schedule rows, so the loop calls `run_boundary!(model, 2)`. For
`k = 7` nothing is due, and the loop calls `run_boundary!(model, nothing)`.
This selection is the whole of the frame/tick discrimination [§10.5][s10-5]
describes: the gate reads a tick index, and a boundary with nothing due has
none.

**The drain.** `frame!` sets the cursor's phase to `:drain` and then calls the
top hook. `drain!` in `sim.jl` counts the frame in the trace ([§11.5][s11-5]). It
swaps each roster entry's staged batch into the root-input cells through the
entry's compiled drain thunk. The loop has already advanced the run's frame
index to `k`, so the trace files this frame's batches under `k`. The harness
cell drains last, and the diagnostic cells fold into the per-writer accounts
at the same point ([§11.8][s11-8]). The model's own cell, `frame_diag`, folds into the
loop's account there too. In `:replay`, `_replay_drain!` reads the recording
instead ([D-101][d-101]). The root inputs are now the values every sweep in this frame
reads, which matters for the validation in section 2: a root input that flips
a guard here is an edge with no in-frame crossing.

## Section 2 — Integration and localization

**`frame!`** computes the span's end from its index, never by accumulation,
asks the backend for a proposal, takes the span's equal steps when there is
none, and picks the path for each:

```julia
t_to = is_top ? _grid_time(model, k) : _tick_time(model, due)   # t₀ + k·Δt_frame
steps = cld(units * denominator(lattice.bound), numerator(lattice.bound))
h = Float64((units * lattice.unit) / steps)   # the span's exact equal step
...                                           # for each step i of the span
proposal = propose(exec.stepper)              # `nothing` for RK4
span_end = i == steps
t_next = span_end ? t_to : t_from + i * h
if exec.has_localized
    (abandoned, localizations, t_end) =
        _localized_step!(model, t_next, t_to, k, hooks, fresh, localizations)
    abandoned && return true
else
    h_accepted = integrate_step!(model, T(h), t_to, k, fresh)
    t_end = _step_end(t, T(h), h_accepted, t_next, t_to)
end
```

Here the one span ends at the frame top in one step, so `t_next` is
`_grid_time(model, 8)`. A
model with no localized events takes one bare step. Ours enters
`_localized_step!`, whose loop integrates one segment per turn: the whole
step first, then a remainder from each `t*`. It returns `true` only when a
`t*` boundary's `settled!` stops the frame.

**One integration segment.** `integrate_step!(model, h′, t_limit, k, fresh)`
in `model.jl` is the `Model`'s attempt loop. It sets the cursor phase to
`:integrate` and the attempt to 1, and crosses the stepper seam
([§10.2][s10-2]) to the backend's `attempt!(::RK4Stepper, model, h)` in
`stepper.jl`, which writes the step's end into the trial buffer `exec.xnext`
and returns `true`, an acceptance:

```julia
copyto!(x₀, x)
evaluate!(model); copyto!(k₁, ẋ)
_stage_point!(x, x₀, k₁, h / 2); model.exec.clock.t = t + h / 2
evaluate!(model); copyto!(k₂, ẋ)
...
xtrial[i] = x₀[i] + (h / 6) * (k₁[i] + 2k₂[i] + 2k₃[i] + k₄[i])
```

Each RK stage is one `evaluate!`, and evaluating the right-hand side means
running the sweep ([§5.3][s5-3]):

```julia
exec.cursor.index += 1
exec.bodies.sweep_1()      # y_state block, interior variant
exec.bodies.sweep_2()      # y_direct block, interior variant
exec.bodies.rhs()          # x_deriv block
```

The zero-argument call on a `PhaseBody` in `executor.jl` walks the interior
chunk tuple, which `chunked_body` compiled from continuous entries only
([D-147][d-147]). Each `run_entry!(::StageEntry)` calls the author's stage on a bundle of
views and scatters the returned ports into the table; each `run_entry!(::RHSEntry)`
writes the derivative into `ẋbuf`. The controller's output cells are not
touched at any of the four stages. That is the zero-order hold, by absence
rather than by a runtime test ([§10.5][s10-5]). When the drain reported nothing
written, the table is the last boundary's, and the first `evaluate!` runs
`rhs()` alone ([D-447][d-447]). When the backend accepts,
`integrate_step!` writes the clock at the step's end, runs `_check_finite!`
over the trial before anything reads it ([§13.4][s13-4]), and copies the
trial into the state buffer. RK4 never rejects; a backend that did would
have the loop put the step's start back and try again.

**Arrival sweep and trigger.** Back in `_localized_step!`, the state is at
`t₈` in the buffer, and the cursor phase is `:arrival`. One interior sweep
refreshes the table, `_guards!` in `executor.jl` evaluates every guard into
the predicate register `now` and the numeric register `σ`, and the arrival
samples are kept as `σ1`:

```julia
events.triggered[i] = events.localized[i] && !events.prior[i] && events.σ1[i] ≥ 0
```

An event triggers when its policy is localized, its prior at the last settled
boundary was not-holding, and it holds now ([§10.4][s10-4]). If nothing triggers the
function returns `false` and the frame goes straight to section 3. Say the
plant's guard triggered.

**The θ = 0 validation.** The arrival state stays in `exec.xnext`, the trial
the step was committed from. The frame-start state is then recovered from the seam's retained
`startpoint`, put back in the buffer with the clock at `t_seg`, and swept
once more under the phase `:validation`:

```julia
copyto!(exec.xbuf, x₀); exec.clock.t = t_seg
exec.bodies.sweep_1(); exec.bodies.sweep_2()
_guards!(events, exec.store, exec.xbuf)
copyto!(events.σ0, events.σ)
events.triggered[i] = events.triggered[i] && events.σ0[i] < 0
```

This is where a drain-caused edge is filtered out. If the guard already holds
at `θ = 0` with this frame's inputs, there is no crossing inside the frame:
the trigger is dropped, the arrival state is restored, and the event fires in
the frame-top boundary's own iteration instead. It consumes no budget. The
reasoning is `localization_validation_walkthrough.md`'s.

**Root-finding.** One `evaluate!` at the arrival state pays `ẋₙ₊₁` into
`exec.ẋnext`, completing the four values the cubic Hermite interpolant needs.
Then `_crossing` runs ITP ([D-018][d-018]) on `θ ∈ [0, 1]`, each iteration one
`_trial!`:

```julia
dense!(exec.stepper, exec.xbuf, exec.xnext, exec.ẋnext, θ, h′)
exec.clock.t = t_seg + θ * h′
exec.bodies.sweep_1(); exec.bodies.sweep_2()
_guards!(exec.events, exec.store, exec.xbuf)
```

`dense!` in `stepper.jl` writes `x̂(θ)` from the `startpoint` pair `(x₀, ẋ₀)`
and the arrival pair `(x₁, ẋ₁)`. A trial is an interior sweep on raw,
unprojected state; the discrete cells hold through every trial. The cursor
phase `:trial` with the iteration ordinal is what a `StepError` reports if a
guard throws here ([§13.4][s13-4]). The earliest `θ★` across the triggered events wins,
and a `θ★` of exactly one is discarded as a crossing at the step's end.

**The `t*` boundary.** The interpolated state goes into the buffer, the clock
moves to `t* = t_seg + θ★·h′`, and the boundary runs over the empty due set:

```julia
dense!(exec.stepper, exec.xbuf, exec.xnext, exec.ẋnext, θ★, h′)
exec.clock.t = t_seg + θ★ * h′
run_boundary!(model, nothing)
settled!(hooks) && return (true, localizations)
```

`run_boundary!(model, nothing)` in `model.jl` is projection followed by the
event phase, with no tick argument and no ticks block:

```julia
_phase!(model.exec.cursor, :project)
_projects!(model.exec.events, model.exec.xbuf)
event_phase!(model, nothing)
```

Projection first. `_projects!` walks every `ProjectEntry`, and `run_project!`
reconstructs each component's `x` from the buffer, applies
`x_projection`, and writes it back wholesale ([§5.3][s5-3]). Authority over the
state rests here, not with the raw trials.

Then `event_phase!` in `model.jl` ([§10.6][s10-6]). Round one is the boundary sweep,
`_round!(model, nothing)`, which is the two zero-argument sweeps: the same
interior walk, with no discrete entry in it ([D-185][d-185]). The registers are then
armed for this boundary, `last` from `prior`, counts and warned flags cleared,
and the iteration runs:

```julia
_guards!(events, model.exec.store, model.exec.xbuf)
for i in 1:n_events
    edge = !events.last[i] && events.now[i]
    eligible = edge && events.count[i] < budget
    firing = eligible && !events.comp_fired[events.owner[i]]
    ...
end
any_fired || break
_fire!(events, model.exec.store, model.exec.xbuf)
_round!(model, tick)
```

An event fires when it presents an edge, its firing count is below
`firing_budget`, and no event of the same component fired this round. An
eligible-but-blocked event keeps its edge for the next round ([D-191][d-191]). `_fire!`
in `executor.jl` runs the handler, `_latch!` writes the returned `x` into the
buffer and merges `m` into the mode store, and `_fire_project!` re-projects
that component. A fresh sweep follows, and the loop goes around until a round
fires nothing. At quiescence the priors are updated from the settled samples.
The controller played no part in this boundary: `t*` is off the grid, so its
due set is empty by construction.

`settled!(hooks)` then runs the loop's hook. `publish!` captures a snapshot,
appends it to the log, and bumps the wait counter ([§12.3][s12-3], [D-230][d-230]). The `t*`
snapshot is a published consistency point like any other, and `_stop_hit`
scans the stop requests on it ([§13.5][s13-5]). If one holds, `settled!` returns `true`.
`frame!` then returns at once, the remainder unrun and the clock at `t*`. If
none holds, the localization count increments and the loop turns again.

**The remainder.** The next turn reads `t_seg = t*` off the clock and sets
`h′ = t₈ − t*`, and `integrate_step!(model, h′, t_limit, k, fresh)` runs a full RK4 step from the
post-handler state. A one-step method restarts from a new state at no cost,
which is why the seam admits nothing else ([D-017][d-017]). The arrival sweep at `t₈`
finds no new edge, `_localized_step!` returns `false`, and `frame!` stamps
the clock at `t₈`. Had the remainder triggered again, the loop would localize
once more, up to `localization_budget` per frame, counted across its steps.
Past that budget, further crossings are left to the step's end boundary under a `ChatteringBudget`
warning, which goes into the model's `frame_diag` ([§10.4][s10-4]).

## Section 3 — The frame-top boundary and publication

**The tick boundary, `run_boundary!(model, 2)`** in `model.jl`:

```julia
_projects!(model.exec.events, model.exec.xbuf)
event_phase!(model, due)
run_ticks!(model, due)       # bodies.ticks(tick) at an `Int`, nothing at `nothing`
```

The difference from the `t*` boundary lies in the argument. `_round!` with an
`Int` tick calls `sweep_1(tick)` and `sweep_2(tick)`, the one-argument
variant of the phase body, which walks the full chunk tuple. Continuous
entries run through the fallback `run_at!` unchanged. Each discrete entry
wears a `Gated` wrapper whose `run_at!` is the [§10.5][s10-5] gate:

```julia
(tick - entry.Φ) % entry.D == 0 && run_entry!(entry.entry, store, xbuf, ẋbuf)
```

With `tick = 2` and `(D, Φ) = (1, 0)` the controller is due. Its
`y_state` runs in the stage-1 walk from the current `s`, its
`y_direct` in the stage-2 walk from the freshly swept inputs, and its
cells now carry `y[k]` computed from `s[k]`. The event iteration proceeds as
at `t*`, and every re-sweep of the iteration uses the same due set, since the
tick index is the boundary's and does not change between rounds.

After quiescence, `bodies.ticks(tick)` walks the update block through the
same gate, under the cursor phase `:ticks`. `run_entry!(::UpdateEntry)`
computes `s_update` off the settled table and writes `s[k+1]` into the
component's store. Updates run last, so they read
post-transition values, and they run after the output stages, so the
sampled-data recursion holds by construction: outputs from `s[k]`, then the
update to `s[k+1]` ([§10.6][s10-6]).

**The off-tick frame top.** For frame `k = 7` the loop calls
`run_boundary!(model, nothing)` instead. Projection and the event phase run in
full, the sweeps are the zero-argument ones, and no `ticks` body runs at all.
The controller's cells still hold the values it published at `t = 0.04`, and
its `s` is untouched until `t = 0.08`.

**Publication.** `frame!` ends with `settled!(hooks)`. `publish!` builds the
snapshot from the clock, the run's frame index, the boundary ordinal and a
capture of the store. It then releases the snapshot, logs it and wakes device
waiters ([§11.2][s11-2]). `_stop_hit` scans the stop requests on that snapshot. If an
honoured one holds, `frame!` returns `true`. The loop reads the requester
again off the same snapshot and returns `ModelRequestedStop(requester)`
([§13.5][s13-5]). Otherwise the loop proceeds to the next frame top, and the cursor's
trail restarts: `:drain`, `:integrate`, `:arrival`, `:validation`, `:trial`,
`:project`, `:round`, and `:ticks` where something is due, the sequence a
`StepError`'s frame is read from ([§13.4][s13-4]).

**Boundary count.** Frame 8 in this example published twice, at the `t*`
boundary and at the tick boundary. Frame 7 without an event publishes once, at
the off-tick boundary. The frame index advanced by one in both cases and the
tick index only at frame 8, which is what `_next_due` computes from the
schedule rows.

## Section 4 — Boundary zero, for contrast

The simulation's `init!` runs boundary zero through the model's `init!`, which
calls `boundary_zero!` under the catch that returns a throwing model to
`:built` ([§13.4][s13-4], [D-223][d-223]). `boundary_zero!` is `run_boundary!(model, ESTABLISH)`.
The sequence is the ordinary one with one difference:
`event_phase!(model, ESTABLISH)` passes a marker in place of a tick index, and
`run_at!` on a `Gated` entry admits every discrete output stage against it,
due or not ([§14.5][s14-5], [D-205][d-205]), so the `t₀` snapshot carries the authored world
fully evaluated. The update block runs as `bodies.ticks(0)`, the ordinary
gate at index `0`, which under the canonical residue admits exactly the
`Φ = 0` components ([§10.5][s10-5]). The model's `init!` then calls `settled!(hooks)`,
which publishes the `t₀` snapshot. Nothing in the frame loop above is entered:
boundary zero has no integrate and no drain.

<!-- citation link definitions — generated by tools/linkify.jl; do not edit -->
[d-017]: ../log.md#d-017--framework-owned-simulation-loop-with-a-stepper-seam
[d-018]: ../log.md#d-018--tier-2-event-localization-via-dense-output-and-bracketed-root-finding
[d-101]: ../log.md#d-101--implement-replay-as-the-ordinary-loop-with-two-substitutions
[d-147]: ../log.md#d-147--split-the-sweep-into-static-interior-and-boundary-variants
[d-185]: ../log.md#d-185--adopt-the-phased-two-form-sample-time-declaration
[d-191]: ../log.md#d-191--defer-not-consume-the-edge-on-a-blocked-event
[d-205]: ../log.md#d-205--boundary-zero-publishes-every-discrete-output-stage-due-or-not
[d-223]: ../log.md#d-223--host-the-runtime-catch-in-boundary-zero-under-the-services-disposition
[d-230]: ../log.md#d-230--stamp-the-snapshot-with-the-trajectorys-boundary-ordinal-not-the-wait-counter
[d-431]: ../log.md#d-431--collect-a-stopping-check-over-its-own-unit
[d-447]: ../log.md#d-447--run-a-steps-first-stage-over-a-fresh-table-as-the-flow-alone
[d-449]: ../log.md#d-449--bound-the-step-by-h_max-and-take-each-span-in-equal-steps
[d-452]: ../log.md#d-452--split-each-step-between-a-proposing-backend-and-a-shaping-model
[s10-2]: ../spec.md#102-the-stepper-seam
[s10-4]: ../spec.md#104-localization-mechanics
[s10-5]: ../spec.md#105-multi-rate-tick-scheduling
[s10-6]: ../spec.md#106-event-iteration-at-boundaries-to-quiescence-budgeted
[s10-7]: ../spec.md#107-real-time-pacing
[s11-2]: ../spec.md#112-outbound-snapshot-publication
[s11-3]: ../spec.md#113-inbound-root-inputs-claims-and-the-frozen-roster
[s11-5]: ../spec.md#115-inbound-the-input-trace
[s11-8]: ../spec.md#118-diagnostics-and-liveness-the-per-writer-diagnostic-cell
[s12-3]: ../spec.md#123-the-next-snapshot-wait
[s13-4]: ../spec.md#134-runtime-failures-one-catch-site-an-execution-cursor
[s13-5]: ../spec.md#135-termination-is-a-state-not-an-exception
[s14-5]: ../spec.md#145-boundary-zero-an-ordinary-boundary-with-authored-incoming-transitions
[s5-3]: ../spec.md#53-structural-feedthrough-stage-roles-execution-order-and-step-boundaries

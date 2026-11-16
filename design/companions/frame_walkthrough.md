# One frame, end to end: the loop mapped to the implementation

*Companion explainer, non-normative. The spec ([§10.4][s10-4], [§10.5][s10-5], [§10.6][s10-6]; the seam
in [§10.2][s10-2], publication in [§11.2][s11-2]) wins wherever the two disagree. Written
against the tree at `e6696a7` ([D-431][d-431]) and refreshed at `16c67dc`, the
first adaptive backend's ([D-461][d-461]): every function named here is the
implementation's, and the code moves more often than the spec. Function names
are given without line numbers for that reason; `grep` finds them. The quotes
of `frame.jl` and the boundary routine follow the span loop of
[D-449][d-449], those of the seam its protocol of [D-452][d-452], and section 5 the
shaping rule and the floor of [D-460][d-460].*

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
frame top. The method is the default, `RK4`. Section 5 follows a frame
under the adaptive `BS3`, on an example of its own.

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
wrote && discontinuity!(model.exec.stepper)
...                                   # integration, section 2
exec.clock.t = t_end
if span_end && is_due
    run_boundary!(model, due)
else
    run_boundary!(model, nothing)
end
abandon = settled!(hooks)             # publish!, then _stop_hit
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
a guard here is an edge with no in-frame crossing. A drain that wrote a value
also raises the stepper's discontinuity notice ([§10.2][s10-2], [D-452][d-452]), which `RK4`
ignores and section 5's method reads.

## Section 2 — Integration and localization

**`frame!`** computes the span's end from its index, never by accumulation,
asks the backend for a proposal, takes the span's equal steps when there is
none, and picks the path for each:

```julia
t_to = is_top ? _grid_time(model, k) : _tick_time(model, due)   # t₀ + k·Δt_frame
units = target - position
steps = cld(units * denominator(lattice.bound), numerator(lattice.bound))
...                                           # for each step i of the span
proposal = isempty(exec.xbuf) ? nothing : propose(exec.stepper)   # `nothing` for RK4
if proposal === nothing
    span_end = i == steps
    t_next = span_end ? t_to : _instant(exec.clock, origin + position, i, units, steps)
    h_step = oftype(t, t_next) - t
else
    ...                                       # a proposal, section 5
end
if exec.has_localized
    (abandoned, localizations, t_end, settled_end) =
        _localized_step!(model, h_step, t_next, t_to, k, hooks, fresh, localizations,
                         proposal !== nothing)
    abandoned && return true
    settled_end && (fresh = true; continue)   # section 5
else
    h_accepted = integrate_step!(model, h_step, t_to, k, fresh)
    t_end = _step_end(t, h_step, h_accepted, t_next, t_to)
end
```

An interior step's end is `_instant`, the float nearest the span's exact
start plus `i/n` of its length, and every step integrates by the distance
between its two clocks ([D-455][d-455], [D-456][d-456]). Here the one span ends at the frame top
in one step, so `t_next` is `_grid_time(model, 8)`. A model with no
localized events takes one bare step. Ours enters `_localized_step!`, whose
loop integrates one segment per turn: the whole step first, then a
remainder from each `t*`. Its first return value is `true` only when a
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
rather than by a runtime test ([§10.5][s10-5]). When the frame continues the
last one and the drain wrote nothing, the table is the last boundary's, and
the first `evaluate!` runs `rhs()` alone ([D-447][d-447], [D-452][d-452]). When the backend accepts,
`integrate_step!` writes the clock at the step's end, runs `_check_finite!`
over the trial before anything reads it ([§13.4][s13-4]), and copies the
trial into the state buffer. `RK4` never rejects. Section 5 follows a
backend that does.

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
moves to `t* = t_seg + θ★·h′`, or to the next float after `t_seg` where that
sum rounds onto it, and the boundary runs over the empty due set:

```julia
dense!(exec.stepper, exec.xbuf, exec.xnext, exec.ẋnext, θ★, h′)
exec.clock.t = t★
run_boundary!(model, nothing)
settled!(hooks) && return (true, localizations, t_to, false)
```

`run_boundary!(model, nothing)` in `model.jl` is projection followed by the
event phase, with no tick argument and no ticks block:

```julia
_phase!(model.exec.cursor, :project)
_projects!(model.exec.events, model.exec.xbuf)
fired = event_phase!(model, due)
run_ticks!(model, due)       # nothing at `nothing`
(fired || due !== nothing) && discontinuity!(model.exec.stepper)
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
due set is empty by construction. The plant's handler fired, so the boundary
raises the discontinuity notice as it settles.

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
warning, which goes into the model's `frame_diag` ([§10.4][s10-4]). That is the
fixed-step path. Under a method that proposes its steps the `t*` ends its
step instead, and section 5 shapes the next step from it.

## Section 3 — The frame-top boundary and publication

**The tick boundary, `run_boundary!(model, 2)`** in `model.jl`:

```julia
_projects!(model.exec.events, model.exec.xbuf)
fired = event_phase!(model, due)
run_ticks!(model, due)       # bodies.ticks(tick) at an `Int`, nothing at `nothing`
(fired || due !== nothing) && discontinuity!(model.exec.stepper)
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
update to `s[k+1]` ([§10.6][s10-6]). A tick ran, so this boundary raises the
discontinuity notice too: the controller's new output is a step in the
input the next step's stages read.

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

## Section 5 — The frame under an adaptive method

An adaptive method chooses each step's length under error control
([§10.2][s10-2]). Of sections 1 to 3, only two places change: the frame loop's
inner loop, which shapes a proposal into a step, and the attempt loop, which
now meets rejections. The drain, the localization machinery, the boundaries
and publication are as above. This section follows one frame of a run and
quotes the step lengths it took.

**The example.** A first-order lag with `τ = 0.05 s` prefilters the root
input `ref`. A damped oscillator, the plant, is driven by a discrete
proportional controller due at every base tick, `(D, Φ) = (1, 0)`, which
reads the lag's output against the plant's. A localized sign-form guard
watches the lag's output rise through `0.75`, and its handler writes only
its own mode. The deployment is:

```julia
Simulation(model; Δt_frame = 1//10, Δt_base = 1//20, h_min = 1//10_000,
           algorithm = BS3(reltol = 1e-4, abstol = 1e-7))
```

It sets no `h_max`, which resolves to the frame. The run starts at rest
with `ref = 0.5`, and the operator stages `ref = 1.0` before frame 7,
`[0.6, 0.7]`, the frame followed. Its mandatory instants are the due
instant `0.65`, base tick 13, and the frame top `0.7`, base tick 14, so the
frame has two spans. Every figure below comes from a run at `16c67dc` on
Julia 1.13.3, with a recording wrapper around the stepper.

**The notice.** The drain wrote `ref`, so `run_frame!` raises the
discontinuity notice before the first step. `BS3` clears its controller's
memory and keeps its proposal:

```julia
discontinuity!(stepper::BS3Stepper) = (stepper.memory = 0.0; nothing)
```

The memory was already clear here. The tick at `0.6` that closed frame 6
raised the notice too, and two notices before a step mean one. The proposal
the backend keeps is frame 6's last, `0.0308`.

**The shaping rule.** Under a proposal the frame loop's other branch runs:

```julia
h_step = _shaped(model, proposal, t, t_to)
span_end = h_step == t_to - t
t_next = span_end ? oftype(t, t_to) : t + h_step
```

`_shaped` in `model.jl` clamps the proposal into `[h_min, h_max]` and
divides the distance `r` to the span's end into equal steps no longer than
it ([D-460][d-460]):

```julia
cap = max(min(proposal, Float64(deployment.h_max)), h_min)
floor_steps = max(1.0, floor((r + slack) / h_min))
cap ≥ r ? 1.0 : max(1.0, min(ceil((r - slack) / cap), floor_steps))
```

From `0.6` the distance to the due instant is `0.05`, so `n = ⌈0.05 /
0.0308⌉ = 2` and the step is `0.025`. Taking `0.0308` and then a sliver of
`0.0192` would end the span on a step the controller never asked for;
equal division leaves no sliver. The rule runs again at every step's start,
from the clock, so the division is never a plan carried across steps. An
interior step's end is the clock plus the accepted length, on no lattice.
`slack` is four ulps of the clock, so a proposal that divides the distance
exactly takes its count and no step more.

**A rejected attempt.** `attempt!(::BS3Stepper, model, h)` evaluates four
stages. The fourth is the derivative at the trial's end, and the four give
the difference between the third-order solution and the embedded
second-order one. The error is that difference over
`abstol + reltol·max(|xₙ|, |xₙ₊₁|)`, the maximum over the state, on values
alone. The drained reference moved the lag's derivative from about zero
to `10 s⁻¹`, so the step of `0.025` scores about 9.3, and the backend rejects
it with a shrunken proposal:

```julia
shrink = isfinite(scaled_error) ? max(BS3_STRONGEST, BS3_SAFETY / cbrt(scaled_error)) :
         BS3_STRONGEST
stepper.proposal = h_value * shrink
```

`integrate_step!` then discards the trial unread and puts the step's start
back:

```julia
copyto!(exec.xbuf, first(startpoint(exec.stepper)))
clock.t = t
fresh = false
...
h = _shaped(model, propose(exec.stepper), t, t_limit)
```

The stages wrote the state buffer and the clock as scratch, and these two
lines undo both. `fresh = false` because the stages also left the table at
a stage point, so the next attempt's first evaluation sweeps. The retry is
shaped by the same rule, toward the same span's end. The proposal `0.0107`
gives `n = 5` and a step of `0.01`, which scores 1.13 and is rejected too.
The proposal `0.00865` gives `n = 6` and a step of `0.008333`, which scores
0.70 and is accepted. The cursor's attempt reads 3, which is what a
`StepError` here would name ([§13.4][s13-4]).

**The controller.** An accepted step proposes the next length. With the
memory clear, the factor is the elementary `0.9·err^(-1/3)`, so the step of
`0.008333` at 0.70 proposes `0.008465`. With a memory, the factor is the
proportional-integral one, which also weighs the previous accepted step's
error:

```julia
factor = stepper.memory == 0.0 ? BS3_SAFETY / cbrt(scaled_error) :
         BS3_SAFETY * scaled_error^-BS3_PI_ERROR * stepper.memory^BS3_PI_MEMORY
stepper.proposal = h_value * clamp(factor, BS3_SHRINK, BS3_GROWTH)
stepper.memory = max(scaled_error, BS3_MEMORY_FLOOR)
```

The second step, from `0.608333`, scores 0.53 and proposes `0.00829`. From
`0.616667` the distance `0.033333` fits four steps of `0.008333`, but the
proposal is shorter, so `n = 5` and the step is `0.006667`. The step never
exceeds the proposal, except by the slack. Each accepted step ends at a
boundary, and each boundary publishes, at `0.608333`, `0.616667`,
`0.623333` and `0.63`.

**A `t*` ends the step.** From `0.63` the step of `0.006667` is accepted,
and its arrival sweep finds the guard holding. Validation and root-finding
run as in section 2 and place `t*` at `0.634652`. The lag's exact crossing
is `0.6 + 0.05·ln 2 ≈ 0.634657`. The `t*` boundary settles, and then
`_localized_step!` returns where the fixed-step path would integrate a
remainder:

```julia
proposing && return (false, localizations, t★, true)
```

The step ends at `t*`, and the frame loop shapes the next one from there.
A remainder would run at a length no proposal asked for, from a state the
handler may have moved. The handler fired, so the boundary raised the
notice, and the memory is clear again. The proposal is still the one the
whole accepted step gave, `0.00741`. The distance to the due instant is
`0.015348`, so `n = 3` and the step is `0.005116`. That step scores 0.065,
and the elementary factor proposes `0.0115`, longer than the `0.010232`
left. The cap exceeds the distance, so the last step is the remainder
itself, and `span_end` holds by equality, which puts the clock on the due
instant exactly.

**The tick and the second span.** The boundary at `0.65` runs the
controller's output stage and update, as in section 3, and the tick raises
the notice. From `0.65` the proposal `0.00795` divides the second span into
seven steps of `0.007143`, and the first of them is taken. Its proposal,
`0.0133`, divides the remaining `0.042857` into four, and one step of
`0.010714` is taken. Its proposal, `0.0096`, divides the remaining
`0.032143` into four steps of `0.008036`, and the next proposals keep that
length to the frame top. The tick at `0.7` raises the
notice once more, and frame 8 starts with a clear memory.

**The count.** The frame made 15 attempts, 2 of them rejected, and
published 13 snapshots: the `t*`, the due instant, the frame top and ten
other step ends.
Every attempt evaluates four stages, rejected or not. `RK4` under the same
deployment takes each span in one step, and the frame publishes three
snapshots, at the `t*`, the due instant and the frame top. Its `t*` is
`0.635221`, located on the dense output of one step across the whole span.

**The floor.** Nothing here comes near it. From `0.6` the shortest step the
rule allows is `0.05 / ⌊0.05 / 0.0001⌋ = 0.0001`. Two branches of
`integrate_step!` reach it:

```julia
accepted || (_at_floor(model, h, t, t_limit) &&
             (accepted = _report_floor!(model, t, h, attempt, :rejected)))
...
if attempt == model.deployment.attempt_budget
    h = _shaped(model, Float64(model.deployment.h_min), t, t_limit)
    _report_floor!(model, t, h, attempt, :budget)
```

A rejected attempt that no proposal could shape shorter is committed anyway,
and `StepFloor` records it with the reason `:rejected`. A step whose
attempts reach `attempt_budget`, 7 by default, takes its next attempt at the
floor, reason `:budget`. The warning goes to the model's `frame_diag`, at
most once per frame, since `_frame_steps!` clears the `floor_reported` latch
at each frame top. A forced step may be up to just under `2·h_min` long,
since the floor is read by count.

**Across frames.** `checkpoint_stepper` reads the backend's carried pair,
the proposal and the memory, into the checkpoint's state, and
`restore_stepper!` writes it back with no notice. A restored run therefore
proposes what the original proposed ([§12.6][s12-6]). `init!` calls `reset_stepper!`
before boundary zero, which sets the pair to `(Inf, 0.0)`. The first
attempt of a run then takes all that `h_max` and the span allow. If it is
rejected, `_starting_bound` limits the retry from the first stage's
derivative ([D-461][d-461]). A model at a `Dual` takes the steps its `Float64` twin
takes, since the error reads values alone.

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
[d-455]: ../log.md#d-455--integrate-every-step-by-the-float-distance-between-its-two-clocks
[d-456]: ../log.md#d-456--write-each-clock-the-model-knows-exactly-as-the-float-nearest-its-instant
[d-460]: ../log.md#d-460--shape-a-proposed-step-between-the-floor-and-the-bound-and-accept-at-the-floor
[d-461]: ../log.md#d-461--ship-bogackishampine-32-under-proportional-integral-control-as-the-first-adaptive-backend
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
[s12-6]: ../spec.md#126-run-lifecycle-and-partial-advance
[s13-4]: ../spec.md#134-runtime-failures-one-catch-site-an-execution-cursor
[s13-5]: ../spec.md#135-termination-is-a-state-not-an-exception
[s14-5]: ../spec.md#145-boundary-zero-an-ordinary-boundary-with-authored-incoming-transitions
[s5-3]: ../spec.md#53-structural-feedthrough-stage-roles-execution-order-and-step-boundaries

# A store read at rest is the next tick's state

*A companion explainer, not normative text. The ground truth is `spec.md`
[§10.6][s10-6] (the boundary's order: sweep, then the due `s_update` calls), [§14.5][s14-5]
(boundary zero and the interval-alignment table), [§12.6][s12-6] (checkpoints and
`restore!`), [§14.1][s14-1] (a condition is an initial condition) and [§11.2][s11-2] (what a
snapshot carries), with decisions [D-067][d-067], [D-205][d-205], [D-273][d-273] and [D-274][d-274]. If this
document and the spec ever disagree, the spec wins. It was written on
2026-10-20, during the [Appendix A][sA] harvest of the readability rewrite, to
preserve the answer to one question that took a discussion to settle.*

Everything here answers one question. A user stops a run after frame `k`,
reads a discrete component's store with `state(sim, path)`, and writes that
value into a condition to start a new run at `t_k`. **Why does the new run's
discrete component start one tick ahead of the plant, when the same value
restored through a checkpoint continues the run exactly?**

The answer: the value is right in both cases. What differs is which side of
the component's update the executor is placed on. A restore places it after
the update, where the next sweep is frame `k+1`'s and the store is exactly
what that sweep should decode. A condition places it before the sweep of
frame `k`, where the same store is decoded one frame early. The store was
never `s_k`. After frame `k` it is `s_{k+1}`, and `s_k` no longer exists
anywhere.

## 1. What a discrete store holds at rest

A discrete component has a store `s`, an output stage that publishes
`y = f(s)` into its cells, and an update `s⁺ = g(s, u)`. At a boundary `t_k`
where the component is due, the framework runs the sweep first and the due
`s_update` calls after it ([§10.6][s10-6]). So the order within the frame is:

1. the sweep publishes `y_k = f(s_k)` into the cell;
2. the update writes `s_{k+1} = g(s_k, u_k)` into the store.

[§14.5][s14-5] names this placement: the boundary's `s_update` is the *outgoing*
transition ([D-067][d-067]). It consumes the completed boundary's samples and produces
the value the next tick reads. The transition that carried `s` *into* `t_k`
ran at `t_{k-1}`.

The consequence is a uniform reading of the store at rest. After any frame,
a discrete store holds the state its next due tick decodes, and its cell
holds what its last due tick published. The two are one update apart, and
the pre-update value `s_k` is gone: not in the store, not in the cell, not
in the snapshot, which deliberately carries no stores ([§11.2][s11-2]), and not in
a checkpoint, which copies the store as it is ([§12.6][s12-6]).

This is by design and not an accident of implementation. [D-273][d-273]'s Rationale
records the alternative, deferring the update to the next frame top so that
the store holds `s_k` at rest. Under that placement a component due at the
stop boundary held the state its last tick had already decoded, while every
other held the state its next tick would decode, so the store meant two
things depending on where the run stopped. The placement kept makes the
reading one, and a checkpoint copies it without interpreting it.

### Multi-rate components change nothing

Take a component with period two, due at `k-1` and not at `k`. At its tick
`k-1` the sweep publishes `y(s_{k-1})` into the cell and the update writes
`s_{k+1}` into the store. Frame `k` touches neither. So after frame `k` the
cell still holds `y(s_{k-1})` and the store holds `s_{k+1}`, the same
pre-update and post-update pair as in the single-rate case. The store's
value did not change through the frame where the component was not due, but
it was already one update ahead of the cell when the last due tick ended,
and a not-due frame moves neither.

The gap never grows. It is always exactly one update, that component's own
period, whether the run stops on a due frame or not. In frame indices the
two values can be several frames apart; in the component's own terms they
are one update apart, same as always.

## 2. The two ways to put the value back

**A restore.** A checkpoint ([§12.6][s12-6], [D-274][d-274]) copies the executor's state as
one value: the flat `x` buffer, every `s` and `m` store, every published
cell, the guard priors and the clock. `restore!` writes it all back, runs no
boundary and publishes one snapshot at the checkpoint's `t`. The executor
is then exactly where it stood after frame `k`: `x_k` in the buffer,
`s_{k+1}` in the store, `y_k` in the cell. The next boundary is frame
`k+1`'s. Its sweep publishes `f(s_{k+1})`, which is what the uninterrupted
run would have published at `t_{k+1}`. Everything lines up, because the
value is decoded at the instant it was computed for.

**A condition.** A condition is an initial condition and nothing else
([§14.1][s14-1], [D-273][d-273]): a sparse overlay on the declared defaults, applied by
`init!`, after which boundary zero runs. Boundary zero has no incoming
transition on either tier. [§14.5][s14-5]'s table says it directly: the `s_update`
that would have produced `s(0)` never ran, the condition authored `s(0)`,
and boundary zero's sweep publishes `f(s(0))`, every discrete output stage
admitted, due or not ([D-205][d-205]), and then its update produces `s(1)`.

Now feed the same value to each. The pair read off the stopped run is
`(x_k, s_{k+1})`. Restored, it sits after the update and the next sweep is
frame `k+1`'s: correct. Authored as `(x(0), s(0))` at `t_k`, boundary zero's
sweep publishes `f(s_{k+1})` beside `x_k`, where the recorded run had
`f(s_k)` beside that same `x_k`. The continuous side is placed right, since
`x_k` is the state the outgoing integration starts from. The discrete side
is one update ahead of it.

A unit delay makes it concrete. The sketch is illustrative; the names are
approximate.

```julia
# a unit delay on the discrete tier: y = s, s⁺ = u
# recorded run, at rest after boundary k:
#   cell  y = u_{k-1}    what the last tick published
#   store s = u_k        what the next tick will publish
chk = checkpoint(sim)
restore!(sim, chk); step!(sim)          # t_{k+1} publishes y = u_k, as the recording did

s_copied = state(sim, "delay")          # = u_k
init!(model, at("delay", set(s = s_copied)), t_k)
step!(sim)                              # boundary zero publishes y = u_k,
                                        # where the recording published u_{k-1} at t_k
```

The delay has lost a tick at the start. A counter copied this way reads one
higher than the recording at every tick for the rest of the run. This was
observed, not derived: [D-273][d-273]'s Rationale records that `init!` followed by a
capture already returned `s(1)`, and increment 65's ruling notes record a
noise block's counter reading `N + 1` after `N` ticks.

## 3. What goes wrong in practice, and whether to live with it

For a controller in a closed loop the effect is one tick of the controller's
own evolution applied early: an integral term with one more step of
accumulated error, a filter one sample further along. Against a slow plant
that is a transient smaller than the measurement noise, and the loop settles
to the same attractor. It bites where the discrete state is a count, a
sequence number or a mode about to switch; where the scenario is meant to
reproduce the recording for comparison; or where the first tick's command
matters, as in a hand-back test.

Two other things change at the same time, and [Appendix A][sA] already names
them. Boundary zero resets every guard prior to not-holding, so a guard
already holding in the authored state fires again at `t₀`. And a multi-rate
component not due at the stop instant has its sampling lattice re-anchored
at the new `t₀`, so it is due at boundary zero whatever its phase was.

One can live with it once the scenario is understood as a fresh start that
borrows values rather than a continuation. Copied continuous state is exact.
Copied discrete stores are approximately right, one update early. A user who
wants the recording continued exactly has a restore for that, and the
restore carries what a condition cannot: the held cells, the priors and the
clock. The trap is only expecting a copied condition to behave as a restore.

## 4. Why no design change closes it

**Keeping checkpoints and conditions apart does nothing.** They already are
apart. There is no conversion from one to the other, and no path-addressed
reader of a checkpoint; its stores are reachable only through `restore!`
and the trace header. The one public way to read a discrete store is
`state(model, path)` on a stopped run. Removing that would give up store
inspection, which the test suite's pins, every reviewer's probe and the
debugging of any discrete state machine rely on, and would not close the
hazard, since a user can compute any value offline and type it in. The
hazard is in what a store value *means* when read at rest, not in how it
was obtained.

**Deferring the update** so that the store holds `s_k` at rest is the
placement [D-273][d-273] rejected, for the two-readings reason in section 1.

**A second register** per discrete component, holding the pre-update `s_k`
so that a checkpoint could offer it, costs a store copy per tick and fixes
one of the four obstacles [D-273][d-273]'s Rationale lists. The held cells, the guard
priors and the clock still are not condition content, so a condition built
from such a register would still not be a resume. Adopting it would reopen
[D-273][d-273].

**A diagnostic** cannot exist. A copied value is just a value.

**Skipping the update at the end of boundary zero** was also considered.
Trace the copied case under it: boundary zero still publishes `f(s_{k+1})`
at `t_k`, since the wrong value is decoded by the sweep, not by the update;
`t_{k+1}` then publishes `f(s_{k+1})` again and computes `s_{k+2}`, so from
there on the component matches the recording. The skip turns a permanent
one-tick lead into a one-frame glitch, which is better, but it is still
wrong at `t_k`. And for an ordinary authored condition it is worse than the
hazard it tries to cure: boundary zero publishes `f(s(0))`, `t₁` publishes
`f(s(0))` a second time before computing `s(1)` from `u(t₁)`, and the `t₀`
sample is consumed by no update at all. The discrete tier then runs one
tick behind the continuous one for the whole run. That is the alignment
[§14.5][s14-5] teaches, boundary zero's `s_update` being the `t₀` sample's only
chance, and a sampled-data controller would lose its first sample.

What remains is a teaching fact, which is why it belongs in [Appendix A][sA]: a
discrete store read from a stopped run holds the state its next due tick
decodes, never the state its last tick published. A continuation is a
restore; a condition is a fresh start.

### The workflow with no door

The instinct behind the skip is right about one thing. "Keep the stores as
the next tick's state and run no update" is what a restore already does.
The workflow that has no clean spelling today is the one in between: fly a
while, stop, change a few states, continue. [D-273][d-273] spells an input what-if
as a restore followed by `stage!`, but a *state* what-if has no door. A
condition goes only through `init!`, and `restore!` takes no overlay. That
gap is why a user reaches for `state` and a copied condition in the first
place, and the hazard of section 2 is what they find there.

The door that closes the gap, `overlay!` on a stopped run, is designed in
section 7. It does not close the hazard, since a store read at rest still
means the next tick's state and a user who feeds it to `init!` still gets
the shift. It removes the reason to copy.

## 5. How Simulink handles the same split

Simulink's step order is the same, outputs in sorted order and then states
in sorted order, so a block's discrete state is written by its update method
and read by the output method of its next hit. MathWorks describes the Unit
Delay's state as the output signal value from the previous time step, which
is the post-update reading: at rest the state holds what the block outputs
next. An S-function author who asks to reverse the order is told it cannot
be changed and that the order is what produces the unit delay.

Simulink also keeps two values. Final states are a plain list of block state
values. The final operating point, a `ModelOperatingPoint`, "contains
complete information about the state of the model and simulation": hidden
block state, solver and execution-engine state, zero-crossing information
and the snapshot time. The documentation says a run resumed from the
operating point matches the uninterrupted one, and says of final states
alone that "the simulation results can differ from an equivalent simulation
that does not run from an initial state", that they "do not provide enough
information to continue the simulation", and that they "are not always
sufficient to continue a simulation". The guide's recommendation is the
operating point whenever the requirement is unclear. That is [D-273][d-273]'s
position: a resume is a restore, and a list of state values is an initial
condition.

What the pages do not say is this document's section 1. The documented
reasons for the difference are hidden block information, the Variable
Transport Delay being the example, plus solver state and the start time,
which the user sets by hand because the simulation time is not restored
from final states. Nothing found states that a logged discrete state at a
step is the next step's value, so the one-tick shift when final states are
reused as initial states at the same instant is not called out. Whether
Simulink suffers it depends on whether its final step runs the update
before logging, which the pages consulted do not settle.

Sources, consulted 2026-10-20:
[Specify Initial State for Simulation](https://www.mathworks.com/help/simulink/ug/initial-state-operating-point-resume-simulation.html),
[Decide How to Save Block States and Simulation Operating Points](https://www.mathworks.com/help/simulink/ug/decide-how-to-save-block-states-and-simulation-operating-points.html),
[Execution order of mdlOutputs and mdlUpdate](https://in.mathworks.com/matlabcentral/answers/229346-execution-order-of-mdloutputs-and-mdlupdate),
[Simulation Phases in Dynamic Systems](https://www.mathworks.com/help/simulink/slref/simulink-concepts-simulation.html).

Modelica's formalism differs, and the comparison is looser. Initialization
is an equation system over start values with the `pre()` values among the
unknowns, and a clocked partition names a state by the tick that computed
it, so the stored value and the start value mean the same thing by
construction. Exact continuation is a tool feature rather than a language
one; Dymola's continue-from-final writes every variable, `pre` values
included, into a full snapshot, which is again the operating-point shape.
This paragraph was not verified against current tool documentation.

## 6. The loose end this leaves

[D-273][d-273]'s closing bullet says a scenario from a chosen instant is an authored
condition "which a checkpoint's read-only view lets the author copy from".
No such view was built, and the spec never promised one. The copy is by
`state` on the stopped run, as section 4 says. That is a note for Appendix
B's pass of the readability rewrite, so that the synopsis does not list a
surface nobody built, and for an annotation on [D-273][d-273].

## 7. The overlay door: a design record for the increment

*Settled in discussion with the owner on 2026-10-20, in enough detail for a
later session to write the brief from, and ruled the same day as [D-429][d-429], the
spec sentences landing with it. 7.6 records the owner's answers to the points
that were open. Section numbers below are this document's.*

### 7.1 The door

`overlay!(sim, cond)` writes a condition onto a *stopped* run and continues
it. The stores named in `cond` are overwritten, every other store keeps its
value, the clock and the sampling lattice stay, and the run resumes from
the overwritten state as a fresh trajectory. It is a state what-if: the
sibling of the input what-if that [D-273][d-273] spells as a restore followed by
`stage!`.

It is three things it could be confused with, and none of them:

- Not `init!`. `init!` is an initial condition: it erases the run's history
  and decodes the condition's `s` at boundary zero. `overlay!` keeps the
  history and decodes an overlaid `s` at the component's next due tick, as
  the rest reading of section 1 says a store means.
- Not a bare write into the executor. A stopped run has a trace behind it,
  and the trace reproduces the run from its header checkpoint and the input
  drain ([§11.5][s11-5], [§13.4][s13-4]). A write the trace does not record breaks replay. So
  `overlay!` opens a fresh trajectory, as `restore!` does, with the
  checkpoint taken *after* the overlay settles as its header. Replay then
  needs no knowledge of overlays.
- Not an algebra on checkpoints. [D-273][d-273]'s "no algebra" sentence kills the
  other direction, a checkpoint producing a condition. A condition applied
  to a stopped run is one function, and none of [D-273][d-273]'s four obstacles
  applies, since priors, held cells and clock come from the rest state and
  stay there.

The pure-function form, `overlay(cp, cond) → Checkpoint` with `restore!`
unchanged, was considered and rejected: consistency needs a boundary
(7.3), and a value cannot run one.

### 7.2 Five choices, two bundles

With the same `cond`, `init!` and `overlay!` differ in exactly five
choices. Everything else is shared: the condition resolves against the
build with the same diagnostics, the named stores and root-input cells are
written, projection runs, the sweep iterates with guards and handlers to
quiescence, the stepper is reset through its seam, one snapshot is
published, and a fresh trajectory opens with the post-settling checkpoint
as its header.

| | `init!(model, cond, t₀)` | `overlay!(sim, cond)` |
|---|---|---|
| base for the fields `cond` leaves unset | the declared defaults ([D-063][d-063]) | the stopped run's stores |
| clock and sampling lattice | `t₀` sets the origin; every component's phase re-anchored | kept |
| guard priors | all reset to not-holding, so a guard already holding fires at boundary zero ([D-067][d-067]) | kept, so only a guard the overlay moved into holding fires |
| discrete output stages | every one runs from the authored `s`, due or not ([D-205][d-205]) | none; the held cells stay |
| `s_update` | the due updates run, the `t₀` sample's only chance ([§14.5][s14-5]) | none |

The last two rows are sections 1 and 2 in one line: the condition's `s` is
decoded now under `init!` and at the next due tick under `overlay!`.

The five choices are not independent. They come in two bundles, fresh and
continuing, and no mixed configuration means anything: resetting the
priors while keeping the clock would re-fire held guards mid-run for no
reason, and re-anchoring the lattice while keeping the stores would shift
every multi-rate component's phase under a continuing controller. So the
implementation carries one flag, not five.

The first two choices live in the doors' own bodies, before the boundary.
The last three live inside the boundary, in the settling routine both
doors call.

### 7.3 The settling routine

The boundary macro-sequence ([§10.6][s10-6]) is integrate → project → [sweep →
guards → handlers] to quiescence → due `s_update` calls → publication, and
boundary zero is that sequence with an empty integrate ([D-067][d-067]). The
settling routine is boundary zero's tail factored out, with one flag:

```julia
# the macro-sequence with an empty integrate (§10.6, D-067); sketch
function _settle!(model; fresh::Bool)
    fresh && reset_priors!(model)                           # choice 3
    project!(model)
    sweep_to_quiescence!(model; admit_discrete = fresh)     # choice 4
    fresh && run_due_updates!(model)                        # choice 5
    reset_stepper!(model)
    publish!(model)
end
```

Why each step is needed after an overlay, and why a continuous-tier sweep
alone is not enough:

- **Projection.** An overlaid `x` can leave the manifold, a quaternion off
  unit norm. Only the projection step puts it back.
- **Guards and handlers, priors kept.** An overlay can move a guard's
  predicate into holding. With the priors kept, that is a real edge, and
  the handler runs now, before the plant integrates, so the model enters
  the mode the new state belongs to: pushing altitude below ground fires
  touchdown at `t_k`, not one frame later and not never. Refreshing the
  priors to the new values instead would swallow the edge and leave the
  model airborne underground. Handler rounds write `x` and `m`, so the
  sweep iterates with them, one round per causal link as at any boundary.
- **Discrete stages and updates skipped.** An overlaid discrete store is
  the next tick's state by the rest reading, so its output is not
  republished now, and the held cell stays until the next due tick. Running
  the updates would consume a sample that no tick took.
- **The stepper.** Today's steppers are fixed-step RK4 and Heun with no
  carried state (`restore_stepper!` is a no-op). A backend with a cached
  derivative would need its reset, and the seam already has the hook.
- **Publication.** One snapshot at the stopped run's `t`, a second at that
  time, which is already what `restore!` does at a trajectory's start.

Skipping the update at boundary zero, considered in section 4 as a cure for
the copy hazard, is `fresh = true` with choice 5 off: it loses the `t₀`
sample for every authored condition. The flag's two bundles are the reason
that mixed form is not offered.

### 7.4 The three layers

`init!` is layered in three (`src/model.jl`, `src/sim.jl`), and `restore!`
follows the same split, so `overlay!` has two precedents.

1. **The model door with a condition.** Says the claim gate first ([D-318][d-318]),
   resolves the condition against the build into a plan, and hands the
   plan on. `init!` also asserts root-input totality here ([§14.6][s14-6]).
   `overlay!` resolves but does not assert totality: on a stopped run
   every root input already holds a value, so a partial overlay is total
   by construction.
2. **The model method on a plan.** `init!`'s resets the stores to the
   defaults, applies the plan, writes the clock's `t` and `t₀`, fills the
   priors with not-holding, runs boundary zero inside the [§13.4][s13-4] catch that
   wraps a throw as a `StepError` with host `:boundary_zero` and drops the
   status to `:built`, publishes through `settled!(hooks)` and marks the
   model `:consistent`. `overlay!`'s skips the reset and the clock, keeps
   the priors, applies the plan with the same `apply!` machinery the
   scratch sets use ([§14.8][s14-8], [D-213][d-213]), and calls `_settle!(fresh = false)`
   inside the same catch with its own host tag.
3. **The simulation wrapper.** `init!`'s checks the lifecycle (refused
   while `running` or `errored`), checks the recording keywords, resolves
   before anything touches the run, resets the periphery, opens a fresh
   run, calls the model method with the loop's hooks, and takes the
   checkpoint as the trace header last, so a throw inside the boundary
   leaves no header ([D-274][d-274]). `overlay!`'s is `restore!`'s wrapper more than
   `init!`'s: the same lifecycle gate, a fresh run, the periphery handled
   as `restore!` handles it, and the header taken after settling.

The refactor is in layer 2: `boundary_zero!` becomes `_settle!` with the
flag, and `init!`'s plan method calls it with `fresh = true`. The rest of
`overlay!` is a copy of `init!` with lines removed. The increment therefore
has three parts of unequal size: the factoring, which is the only part that
touches existing behavior and must leave boundary zero bit-identical; the
door, a few lines over the factored pieces; and the trajectory handling,
which `restore!` lends.

### 7.5 The spec's part

Docs-commit-first, with one log entry, since a new door with its own
semantics is a ruling and not a description:

- **The door itself**, in [§12.6][s12-6] beside `restore!`, or in [§14.1][s14-1] beside
  `init!`: what it writes, what it keeps, the five choices, the fresh
  trajectory and the header after settling.
- **The base sentence**, [§14.1][s14-1]. [D-063][d-063] rejected a "current-stores overlay
  base" because "run-history dependence breaks header reproducibility".
  The overlay satisfies that reason, since its base is a rest state and
  the new trajectory's header is taken after it settles. The sentence: a
  condition applied through `init!` overlays the declared defaults; applied
  through `overlay!` it overlays the stopped run's stores; the first base
  is what it is for [D-063][d-063]'s reason. A partial store entry merges onto the
  current store as [§14.3][s14-3] says it merges onto `s_init`.
- **The "no algebra" sentence**, [D-273][d-273] and the `ModelState` docstring,
  sharpened rather than dropped: a checkpoint enters no condition
  expression and yields no condition; a condition can be overlaid on a
  stopped run.
- **The rest-reading sentence** of section 1, in [§14.5][s14-5] beside the
  interval-alignment table, citing [D-273][d-273]. It is independent of the door
  and is planned with [Appendix A][sA]'s rewrite (`docs/spec_rewrite/appA/`).
- **[Appendix B][sB]** gains the door, and section 6's loose end lands with it.

### 7.6 Points settled with the owner

Each was open when the record was written and was settled the same day.
The brief states them as given; the log entry carries them.

- **The name is `overlay!`.** `override` is taken by [§14.6][s14-6]'s root-input
  combinator, and `override!` beside it would be one name in two senses,
  the pattern [D-144][d-144] retires. `overlay` is [D-063][d-063]'s own word for what a
  condition is. The export audit (`pending.md`) still decides whether the
  name is exported.
- **A failed overlay drops the status to `:built`**, as a failed boundary
  zero does, so only `init!`, `restore!` and `replay!` are legal after it.
  A throw inside settling leaves the stores partly written, and a failed
  handler has left the state inconsistent either way. The alternative, a
  checkpoint taken before the overlay and restored on failure, was rejected
  for its state copy per call; a user who wants that safety takes the
  checkpoint themselves.
- **No sugar on `restore!`.** A what-if from a saved checkpoint is
  `restore!` followed by `overlay!`; two calls read as what they are.
- **Root-input entries are allowed.** A condition may name root inputs
  ([§14.1][s14-1]); under `overlay!` they write the table's root-input cells, as
  `stage!` would, through the plan machinery that already carries them.
- **The periphery is handled exactly as `restore!` handles it.** Attached
  devices see the fresh trajectory the same way, and no new rule is
  written.

### 7.7 What the tests pin

- A discrete counter overlaid mid-run reads the overlaid value at its next
  due tick, not at the overlay boundary, and the held cell is unchanged
  until then (sections 1 and 2, the rest reading).
- An overlaid `x` that moves a sign-form and a `Bool` guard into holding
  fires each at the overlay boundary, handler applied before the next
  integrate; a guard already holding before the overlay does not re-fire.
- An overlaid quaternion off unit norm is projected before publication.
- The overlay boundary publishes one snapshot at the stopped run's `t`,
  with the continuous cells refreshed and the discrete cells held.
- Replay of an overlaid trajectory reproduces it from the post-settling
  header with no extra record.
- `init!` is bit-identical before and after the factoring, on the suite's
  existing boundary-zero pins.
- The door is refused while `running` and on an `errored` run
  (`ServiceLifecycle`), a partial overlay needs no totality, and a throw
  inside settling is a `StepError` with the door's host tag and the status
  back at `:built`.

<!-- citation link definitions — generated by tools/linkify.jl; do not edit -->
[d-063]: ../decisions.md#d-063--conditions-are-path-addressed-sparse-overlays-on-init_-defaults
[d-067]: ../decisions.md#d-067--boundary-zero-runs-the-macro-sequence-with-an-empty-integrate
[d-144]: ../decisions.md#d-144--rename-the-computed-exports-helper-faces-to-passthrough
[d-205]: ../decisions.md#d-205--boundary-zero-publishes-every-discrete-output-stage-due-or-not
[d-213]: ../decisions.md#d-213--establish-a-services-frozen-cells-from-the-authored-discrete-state
[d-273]: ../decisions.md#d-273--a-condition-is-an-initial-condition-capture-leaves-the-algebra
[d-274]: ../decisions.md#d-274--checkpoints-the-executors-state-as-one-value-restored-without-boundary-zero
[d-318]: ../decisions.md#d-318--a-simulation-claims-its-model
[d-429]: ../decisions.md#d-429--write-a-condition-onto-a-stopped-run-through-overlay
[s10-6]: ../spec.md#106-event-iteration-at-boundaries-to-quiescence-budgeted
[s11-2]: ../spec.md#112-outbound-snapshot-publication
[s11-5]: ../spec.md#115-inbound-the-input-trace
[s12-6]: ../spec.md#126-run-lifecycle-and-partial-advance
[s13-4]: ../spec.md#134-runtime-failures-one-catch-site-an-execution-cursor
[s14-1]: ../spec.md#141-conditions-are-path-addressed-overlays-on-the-declared-defaults
[s14-3]: ../spec.md#143-resolution-flatten-validate-compile-once
[s14-5]: ../spec.md#145-boundary-zero-an-ordinary-boundary-with-authored-incoming-transitions
[s14-6]: ../spec.md#146-root-input-totality-the-missing-value-error-and-the-override-combinator
[s14-8]: ../spec.md#148-the-trim-service-solver-seam-scratch-stores-commit-and-report
[sA]: ../spec.md#appendix-a-taught-contracts-the-author-facing-index
[sB]: ../spec.md#appendix-b-api-synopsis-the-entry-points

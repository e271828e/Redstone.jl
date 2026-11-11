# Roadmap: variable-step integration

The live roadmap for the integration-step update, settled in discussion on
2026-11-05 and 2026-11-06 and amended on 2026-11-11. It stages the work in
six increments, names the rulings the discussion settled, and lists the
decisions each increment still needs. Its `pending.md` bullet carries the
state of the work; this file carries the plan. Every number here is a
reading of the tree at the time of writing, and each brief re-counts what it
pins. The step bound entered on 2026-11-11 between the second increment and
the third. It is numbered 2b, so the numbers the records cite still hold.

## What the update is

Today the integration step `h` and the frame are one object: `tₖ = t₀ + k·h`,
and the drain, the pacer, the trace, the checkpoints and the tick lattice
all key to it. The update separates them. The frame stays the fixed,
schedule-determined unit of exposure to the outside. The integration step
becomes the Model's to decide. Two kinds of instant are mandatory, the frame
tops and the instants at which a discrete component is due, and no step
crosses one. Between two of them no step is longer than `h_max`, an optional
bound on the `Deployment`. A fixed-step method proposes nothing, so it takes
each span in the fewest equal steps the bound allows. An adaptive backend's
error controller proposes a step, and the Model clamps it to the bound and
to the next mandatory instant.

## Settled in discussion

Each of these lands in the spec and the log with the increment that first
needs it.

- **Three quantities.** `Δt_frame`, the frame period; `Δt_base`, the base
  lattice of the discrete tier; `h`, the step the Model takes. `h` and its
  derivatives (`h_init`, `h_min`, `h_max`) name the step and its limits,
  `Δt` and its subscripts name what the schedule fixes. `N_base` retires.
  Since 2026-11-11 no method carries a step; see the step bound below.
- **Ownership.** `Δt_frame` is the `Deployment`'s, beside `Δt_base`, by the
  trajectory test: it fixes where root inputs land and, under an adaptive
  method, clamps the step. The simulation owns the activities keyed to the
  frame, never the frame.
- **Independent lattices.** `Δt_frame` and `Δt_base` stand in no required
  ratio. Each instant is computed from its own index, coincidence is
  decided on the deployment's rationals, and the clock is written once.
- **The step lands on due instants, not on base ticks.** A base tick at
  which nothing is due is no boundary. The next due instant is one modular
  computation per component, cached as a next-due index.
- **Every accepted sub-step ends in a boundary.** Projection, the event
  phase to quiescence, publication, the stop-request scan. No drain, no
  ticks unless the instant is due, no deadline. The frame sets the coarsest
  spacing of snapshots and of non-localized detection, never the actual one.
- **The frame top keeps the drain, the control read, the pacer's deadline
  and the trace's ordinal.** Control latency stays one frame budget,
  `Δt_frame/p`.
- **The step bound.** The user's ruling of 2026-11-11, made after increment
  91 landed. `h_max` is an optional keyword of the `Deployment`, an exact
  positive time that bounds every step under every method and need divide
  nothing. `RK4()` and `Heun()` carry no step. The frame tops and the due
  instants are the mandatory instants, and a span runs from one to the next.
  A fixed-step method takes a span of length `g` in `n = ⌈g / h_max⌉` steps
  of `g / n` each, so the steps of a span are equal. Without `h_max`, `n` is
  1: one step per frame, split at the due instants inside it. Deployments
  from before the update map to `Δt_frame = h`, `Δt_base = N_base·h` and no
  `h_max`.
  - *What it reverses.* The step inside the algorithm instance (D-442), the
    step that divides `Δt_frame`, and the step points counted from the frame
    top, the same day's earlier ruling (D-444). Step points go, and with
    them the third lattice of D-445.
  - *Why.* `RK4(h)` reads as a promise of steps of `h`, which the split had
    already broken. A bound promises only what holds, and it means the same
    under an adaptive method. Equal division takes the same number of steps
    as full steps and a remainder, at a lower truncation error: to leading
    order up to `(n/(n−1))^p` lower in a span, for a method of order `p`.
    It also never makes a short step of its own.
  - *Weighed and rejected*, for the log entry. `RK4(h)` as built. A lattice
    of step points on the deployment, `Δt_step`: its one distinct property
    is boundaries at instants no tick moves, which a harmonic `h_max` gives
    anyway, and it forces boundaries on an adaptive controller. The bound
    with full steps and a remainder: it keeps a sliver, and it puts `h_max`
    into the lattice's unit. A warning at construction when a due instant
    splits a step: the split is the designed use.
- **The clock's resolution.** A run is refused where two distinct
  boundaries could take clocks that are equal or out of order, ruled on
  2026-11-11 on increment 91's open point. With `g` the smallest gap between
  two boundaries, the run needs `|t₀|/g + 2·(t − t₀)/g < 2^50` at every
  instant `t`. Under the step bound `g` is the lesser of the lattice's unit
  and `h_max / 2`. The bound is sufficient, not tight. The step bound's
  prototype derived it again from its own clock formulas: `2^51` is the
  first-order threshold, with no room for the terms it drops, so the bound
  is half of it (D-450). It gives a last frame beside the lattice's
  `max_frame`, a function of the deployment and `t₀` that each door
  computes, and each door that refuses a run past `max_frame` refuses past
  the lesser of the two. It does not cover `t*` boundaries, which sit
  on no lattice. §10.5's and D-445's sentences on equal clocks then state
  the refusal.
- **The steps per frame.** `show(deployment)` states the steps of a frame
  no due instant falls inside, and names the components whose due instants
  split frames, at one check per component (D-449). It replaced a count
  over one hyperperiod, which took seconds on a fast component under a slow
  frame. No warning is raised when a due instant splits a step.
- **The seam protocol.** `propose(stepper)`, `attempt!(stepper, model, h)`
  returning acceptance, `discontinuity!(stepper)`, the retained
  `startpoint`, the generic `dense!` a backend may override, and the
  checkpoint pair, no longer empty. The Model owns the clamp, the bounds,
  the attempt count and the discontinuity notice. Landed as D-452 with
  three changes the user ruled on 2026-11-11. `attempt!` returns its verdict
  alone, and the Model reads `propose` before each step and after each
  rejection. Neither `propose` nor the checkpoint pair has a default. The
  attempt writes the trial buffer `xnext`, and the Model commits it. Its
  review added that `init!` hands the backend the carried state it was bound
  with, so a run is a function of its condition.
- **The discontinuity notice.** Raised at every boundary where a handler
  fired, a tick ran or the drain wrote a value, and at `init!` and
  `overlay!`. What the backend does with it is its own: a fixed-step
  backend ignores it, an integral controller keeps its proposal, a
  proportional-integral controller clears its history. `restore!` never
  reseeds; it restores the stepper's checkpoint field.
- **Freshness.** Read the other way, the same notice says the boundary's
  quiescent table is the next step's first-stage table, so the first stage
  runs the `x_deriv` block alone. The drain may report whether it wrote
  anything, extending the saving to every step of a deviceless run.
  Increment 93 found that the notice and freshness cannot share one report
  (D-452). Freshness may be denied whenever the caller cannot vouch for the
  table, and the notice must depend on the trajectory alone. The frame-top
  hook returns whether it wrote a value, and the caller of a frame says
  whether it continues the last one.
- **Strict first-same-as-last reuse is not built.** The arrival derivative
  of a FSAL backend serves the interpolant, so the lazy sweep for `ẋₙ₊₁`
  disappears for that backend.
- **Interpolants.** The cubic Hermite stays the generic `dense!`, above
  the first backend's order, so D-018 stands untouched until a backend of
  order 4 or more arrives; that backend overrides `dense!` with its own
  extension and annotates D-018, and one above order 4 would reopen it.
- **The vocabulary of the policies.** "Localized" and "non-localized"
  replace "boundary-detected", since both policies detect at boundaries and
  differ only in whether the crossing instant is located.
- **The checkpoint.** `ModelState` gains the stepper's carried state: the
  proposal and the controller's memory, both `Float64`. The derivative
  buffer stays out. A restore counts as a discontinuity for that buffer
  alone: its first frame runs the sweep, and it raises no notice (D-452).
- **The `Run`'s counters and the trace's format are unchanged.** The frame
  index counts fixed frames; the boundary ordinal counts more boundaries.
  Replay compares the deployment by value, now with `Δt_frame` and the
  algorithm instance. The what-if replay keeps batches at the same instants.
- **Rewrite, not patch.** `frame.jl`, `stepper.jl`, the grid arithmetic in
  `model.jl`, the three boundary routines, `bind_schedule` and the test
  suites of those four are written again from the new spec text. The
  executor, the event phase, the data plane, the trace, replay, the control
  plane and the pacer are built upon. §2.1, §2.2, §10.2 and §10.4 are
  rewritten as sections; a log position that changes is superseded, not
  annotated.

## Open decisions

Each names the increment that needs it ruled and the reading recommended
in discussion.

- **The floor.** A frame that reaches `h_min` or spends its attempt budget
  degrades under a new warning kind, accepting the step at the floor, at
  most one report per frame; or throws a `StepError`. Recommended:
  degrade, by the doctrine of the two existing budgets. Increment 4. Until
  then nothing bounds a step's attempts, and no backend in `src/` rejects
  one. Increment 93's review showed with a stub that a proposal that is
  zero, negative or below the clock's resolution never ends its span, with
  every attempt accepted, and that the frame's interrupt mask makes the
  hang unstoppable. The Model now refuses such a length as an internal
  invariant (D-452). A proposal that advances by almost nothing still takes
  steps without a bound, and so does a backend that keeps rejecting. The
  floor settles both, and it must sit above the clock's resolution over the
  run, as D-450's bound does for the lattices.
- **The nonfinite trial.** Increment 93 checks an accepted trial before the
  commit and never a rejected one (D-452). What remains is whether the Model
  turns a nonfinite accepted trial into a rejection above `h_min`, keeping
  the `NonfiniteState` throw at it. Increment 4.
- **What the notice does to the proposal.** After a handler reset, keep the
  proposal and let the controller reject, or shrink it. Recommended: the
  backend's choice, stated per backend. Increment 4. Increment 93 offers the
  remainder of a step after a `t*` whole, without asking `propose`, so a
  backend can shrink it only by rejecting. Whether the Model asks there is
  part of this decision.
- **Projection and the notice.** `x_projection` writes the state at every
  boundary and raises no notice, and neither the spec nor D-452 says so.
  Increment 4.
- **The recorded set's comparison.** The algorithm instance compared as a
  whole value for equality, walked field by field for the
  `CheckpointMismatch` message. Increment 4.
- **The first adaptive backend.** Bogacki–Shampine 3(2), three
  evaluations per accepted step under first-same-as-last, its low order
  what a piecewise-smooth right-hand side under a tick-capped step
  rewards; the mixed norm
  `|err| ≤ abstol + reltol·max(|xₙ|, |xₙ₊₁|)` on values only, under
  proportional-integral step control from the start, so the stepper's
  checkpoint field takes its final shape once. The controller's constants
  are fixed per backend at the standard values, part of the algorithm's
  identity and never keywords; the elementary controller is the integral
  gain alone, the setting the convergence test runs at. `h_min` required of
  an adaptive backend, under the rule that a domain rate is not a framework
  default. Increment 4.
- **The checkpoint's rest condition.** Frame tops only, or any published
  boundary. Recommended: frame tops for now, relaxed when a sub-step stop
  bites. Deferred.
- **`localization_tol`'s reference.** `Δt_frame`. The budget stays per
  frame. Increment 2.
- **Equal division under an adaptive proposal.** Whether the Model shapes an
  adaptive proposal as it shapes a fixed-step span, taking
  `r / ⌈r / min(proposal, h_max)⌉` over the distance `r` to the next
  mandatory instant, or only clamps it. Equal division leaves no sliver
  before a scheduled instant, and it reaches into the controller's memory.
  Increment 4.
- **`h_min`'s home.** The adaptive instance, as the controller's floor, or
  the `Deployment` beside `h_max`. Recommended: the instance, since a
  fixed-step method has no use for it. Increment 4.
- **One step-length rule.** A model without localized events integrates by
  the exact length of the piece, one with them by the float distance to the
  step's end, so declaring a localized event that never fires moves a
  trajectory by ulps. Recommended: a rule by piece, the exact length between
  two instants the Model knows exactly and the float distance from a `t*` or
  an adaptive step end. Increment 4, where the bit-identity invariant ends.
  The rule also settles an edge increment 93 left: under a proposing backend
  an interior step end is the clock plus the accepted length, which can land
  a sliver short of the span's end and leave a last step of about an ulp. It
  cannot pass the span's end, since the length is below the float distance
  to it.
- **Exact periods on the `Deployment`.** Whether it stores and compares
  `Δt_frame`, `Δt_base` and `h_max` as exact rationals, where it compares
  their `Float64` values today. The bound makes the hole easy to reach: at a
  1 s frame, `h_max = 1//3` and `h_max = Rational(1/3)` compare and hash
  equal and take 3 and 4 steps per frame, and `replay!` accepts one's
  recording into the other while the state drifts by 0.014 in five frames.
  Increment 4, with the recorded set.

## The sequence

Each increment runs the pipeline of `rules/increment_rules.md`: a prototype
in a worktree, the docs commit first, one or more code stages, one cold
review. The invariant through increments 1 to 3 is that every existing test
trajectory is bit-identical to today's, the old trajectories being the
oracle for the rewritten loop. Increment 2b should move only trajectories
that increment 91's own tests introduced, those with a bound finer than the
frame and a due instant inside it. That is an argument, not yet a run.

1. **The deployment surface.** `Deployment(build; Δt_frame, Δt_base,
   algorithm = RK4())`, the step inside the algorithm instance and
   `Δt_frame` when the instance names none, `N_base` retired, `Δt_base`
   defaulting to `Δt_frame`, the fixed-step divisibility check, `==` and
   `hash` over the algorithm value, `show`, `_walk_deployment!`, the sugar
   constructors collapsed to a `kw...` passthrough, and the 28 test files
   that spell `h =`. The descriptor's deployment body is the build's alone,
   so it does not change. No change to `frame!`: until increment 2 the
   constructor refuses a step other than the frame and a base tick off the
   frame tops. Spec: §2.2, §9.2, §10.2's backend paragraphs, §10.4, §10.5,
   §11.5, §12.7, Appendices B, C and D. Log: D-442, landing D-227's
   deferred instance form, and D-443, the frame period apart from the step.

2. **The three lattices.** The Model's frame loop advances to the nearer of
   the next frame top and the next due instant, each from its index, with a
   lattice type carrying the index-to-time map for both. A fixed-step
   backend subcycles inside the frame. Sub-step ends and off-grid due
   instants become boundaries; one boundary routine taking the due set
   replaces the three. The localization loop runs per sub-step with its
   tolerance re-referenced. The freshness flag and the drain's report.
   The vocabulary sweep to "non-localized". The sites in `sim.jl` that
   rebuild the `(t, t₀, h)` triple ask the model instead. Spec: §2.1,
   §2.2, §2.3, §3.2, §10.1, §10.4, §10.5, §10.6's boundary kinds, §12.1,
   §12.6, §12.7's `to_time`. Log: D-019, D-082, D-147, D-179, D-290
   superseded or annotated as their positions move. Tests: a 20 ms frame
   over a 100 µs base lattice with periods of 0.1 s and 0.1001 s, counting
   steps; `h < Δt_frame` subcycling; a tick inside a frame sampling the
   frame's inputs; boundary ordinals and frame indices under sub-step
   publication; the first stage over a fresh table bit-identical to the
   sweep's.

2b. **The step bound.** `h_max` on the `Deployment`, `RK4()` and `Heun()`
    without a step, and the frame loop as two nested loops: the outer one
    over mandatory instants, the inner one over the `n` equal steps of a
    span. Mandatory instants keep integer positions, on the unit of
    `Δt_frame` and `Δt_base`. An interior step end has no position and needs
    none, since no mandatory instant lies inside a span. Its clock comes
    from its index in the span, never accumulated. `lattice.step`,
    `lattice.h` and `_step_time` go, and `_localized_step!` stands, since it
    takes the step's end. The clock's resolution refusal and the steps per
    frame in `show` land here. Spec: §2.1, §2.2, §9.2, §10.2, §10.5,
    Appendices B, C and D, with "step point" leaving the glossary. Log:
    D-442, D-443, D-444 and D-445 superseded in part, new entries for the
    bound and for the clock refusal, and the two rejections the log owes
    from increment 91's rulings, which `pending.md` names. The brief settles
    three details: whether `h_max` joins the unit's gcd or the constructor
    stores its ratio to the unit, the second recommended; the constant of
    the clock bound; and what a bound at or above `Δt_frame` does. Tests:
    the trajectories from before increment 90 bit-identical; a harmonic
    `h_max` giving equal steps of `h_max`; equal steps in a span that a due
    instant cuts; the clock refusal at each door; and increment 91's pin on
    step points counted from the frame top retired.

3. **The seam protocol.** `propose`, `attempt!`, `discontinuity!` and the
   non-empty checkpoint pair, with RK4 and Heun rewritten under it, always
   accepting. The cursor gains the attempt ordinal, the nonfinite check
   moves into the attempt, the notice sites are wired, `ModelState` gains
   the stepper field. Spec: §10.2's seam clauses, §12.6, §13.4. Log: D-017
   and D-274 annotated. Tests: a stub backend rejecting on a schedule,
   proving the clock and the buffers untouched by a rejection; checkpoint
   round trips carrying the stepper field; cursor frames naming the
   attempt; a restore followed by a step bit-identical to the unrestored
   run.

4. **The first adaptive backend.** Bogacki–Shampine with its parameters
   as recorded deployment data, proportional-integral control, the floor's
   degradation kind, the value-only norm, the descriptor format bump and
   the inspector's pin. Spec: §2.4's trajectory-fixing list, §10.2's domain
   argument reframed, §10.7's cost bound `Δt_frame/h_min`, §11.5, §12.7,
   §13.9, §14.10's value-norm rule, Appendix C. Log: D-133 annotated, new
   entries for the floor and the recorded set. Tests, the
   first one first: a recording replayed from a checkpoint taken mid-run,
   through frames with rejected attempts and sub-step boundaries,
   bit-identical to the original's snapshots; order of convergence on a
   known solution; zero allocation in the attempt loop through the
   measurement seam; a handler reset followed by the notice; a localized
   event inside a sub-step; the floor's warning; a `Dual` run whose step
   sequence matches the `Float64` run's; the one step after a discontinuity
   taken under integral control alone.

5. **The teaching.** A companion walkthrough of one frame under adaptive
   stepping, the tutorial's deployment chapter, the docstrings of the new
   types, and the inventory's note that the OrdinaryDiffEq adapter stays a
   guarded addition shaped by the seam. No code.

Later, when wanted: Dormand–Prince 5(4) for the tight-tolerance offline
study, carrying the `dense!` override with its fourth-order extension, the
D-018 annotation and the matched-interpolant question; the checkpoint rest
relaxation; the controller's constants as keywords; the adapter.

## Risks

- Publication allocates once per boundary, so a transient of many
  sub-steps allocates many snapshots per frame. The pending garbage
  analysis counts it.
- The due-instant arithmetic runs on `Int` indices; a tiny `Δt_base` under
  a long run needs the overflow guard `_frames_fit` gives frames today.
- A sliver remainder before a scheduled instant. Under a fixed-step method
  equal division makes none, though the schedule can still put two due
  instants a unit apart. Under an adaptive method it waits on increment 4's
  decision on equal division.
- The keyword list exists in three copies until increment 1 collapses it.

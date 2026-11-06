# Roadmap: variable-step integration

The live roadmap for the integration-step update, settled in discussion on
2026-11-05 and 2026-11-06. It stages the work in five increments, names
the rulings the discussion settled, and lists the decisions each increment
still needs. Its `pending.md` bullet carries the state of the work; this
file carries the plan. Every number here is a reading of the tree at the
time of writing, and each brief re-counts what it pins.

## What the update is

Today the integration step `h` and the frame are one object: `tₖ = t₀ + k·h`,
and the drain, the pacer, the trace, the checkpoints and the tick lattice
all key to it. The update separates them. The frame stays the fixed,
schedule-determined unit of exposure to the outside. The integration step
becomes the method's: fixed for RK4 and Heun, proposed by an error
controller for an adaptive backend. The Model decides each step by clamping
the method's proposal to the nearer of the next frame top and the next
instant at which a discrete component is due.

## Settled in discussion

Each of these lands in the spec and the log with the increment that first
needs it. None is built yet.

- **Three quantities.** `Δt_frame`, the frame period; `Δt_base`, the base
  lattice of the discrete tier; `h`, the method's step. `h` and its
  derivatives (`h_init`, `h_min`, `h_max`) name what the method does, `Δt`
  and its subscripts name what the schedule fixes. `N_base` retires.
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
- **Fixed-step divisibility.** A fixed-step `h` must divide `Δt_frame`
  and, when discrete components exist, `Δt_base`, refused otherwise as
  `DeploymentInvalid`. A fixed-step backend may subcycle inside a frame.
  Today's deployments map to `Δt_frame = h`, `Δt_base = N_base·h`.
- **The seam protocol.** `propose(stepper)`, `attempt!(stepper, model, h)`
  returning acceptance and the next proposal, `discontinuity!(stepper)`,
  the retained `startpoint`, the generic `dense!` a backend may override,
  and the checkpoint pair, no longer empty. The Model owns the clamp, the
  bounds, the attempt count and the discontinuity notice.
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
  buffer stays out; a restore counts as a discontinuity.
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

- **The trial buffer.** Whether `attempt!` writes the state buffer and
  restores it on rejection, or writes a trial buffer the Model copies on
  acceptance. Recommended: the trial buffer; the arrival pair and the
  interpolant already read `xnext`. Increment 3.
- **The floor.** A frame that reaches `h_min` or spends its attempt budget
  degrades under a new warning kind, accepting the step at the floor, at
  most one report per frame; or throws a `StepError`. Recommended:
  degrade, by the doctrine of the two existing budgets. Increment 4.
- **The nonfinite trial.** Inside an attempt, a nonfinite state is a
  rejection above `h_min` and the existing `NonfiniteState` throw at it.
  Increment 3.
- **What the notice does to the proposal.** After a handler reset, keep the
  proposal and let the controller reject, or shrink it. Recommended: the
  backend's choice, stated per backend. Increment 4.
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

## The sequence

Each increment runs the pipeline of `rules/increment_rules.md`: a prototype
in a worktree, the docs commit first, one or more code stages, one cold
review. The invariant through increments 1 to 3 is that every existing test
trajectory is bit-identical to today's, the old trajectories being the
oracle for the rewritten loop.

1. **The deployment surface.** `Deployment(build; Δt_frame, Δt_base,
   algorithm = RK4(h))`, `N_base` retired, `Δt_base` defaulting to
   `Δt_frame`, the fixed-step divisibility check, `==` and `hash` over the
   algorithm value, `show`, the descriptor's deployment body,
   `_walk_deployment!`, the sugar constructors collapsed to a `kw...`
   passthrough, and the test files that spell `h =` (29 at the time of
   writing). No change to `frame!`. Spec: §9.2, §10.2's backend paragraphs,
   Appendix B and C, the glossary. Log: a new entry landing D-227's
   deferred instance form.

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
relaxation; a backend-side `h_max`; the controller's constants as
keywords; the adapter.

## Risks

- Publication allocates once per boundary, so a transient of many
  sub-steps allocates many snapshots per frame. The pending garbage
  analysis counts it.
- The due-instant arithmetic runs on `Int` indices; a tiny `Δt_base` under
  a long run needs the overflow guard `_frames_fit` gives frames today.
- A sliver remainder before a scheduled instant is stretched onto it
  rather than taken as a step of a few ulps.
- The keyword list exists in three copies until increment 1 collapses it.

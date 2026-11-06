# Variable-step integration, 2026-11-06

The user asked what it would take to let the integration method propose the
continuous step, with the `Model` deciding each step from that proposal and
the discrete components' ticks, instead of the fixed step `h` the design
runs on today. This report records the analysis, the reorganization it
would need, the roadmap that would build it, and the verdict: the capability
is admitted, its shape is named, and it is not built until a model asks for
it. The last section records the cheaper remedies the present design already
holds, and the one item the discussion landed.

Sources are the spec and the log at `ea2259c`, the code at the same tip, and
the extensions charter (`reports/20260809_extensions_charter/report.md`,
section 1.4). Nothing was prototyped. Every claim about the code comes from
reading it.

## Summary

**The step and the frame are one object today, and the separation is the
whole design problem.** Six mechanisms key to the frame: the drain, the tick
lattice, the trace and replay, pacing, termination and partial advance, and
localization. Every one of them reads `h`. Pull the frame apart from the
step, keep the frame fixed as the scheduling unit, and a variable-step
integrator is confined to the integrate segment of the frame and the stepper
seam. The periphery never notices.

**A frameless mode exists for strictly continuous models.** The base grid is
what the discrete tier contributes to the schedule, not a premise of Part I.
A model with no discrete component, no device and no pacing can land only on
`t_end`, the recorded input times and an optional maximum step, and the
frame dissolves.

**It is not worth building now.** For the models the framework exists for,
the step is capped by the avionics frame and then by stability, so an
adaptive integrator shrinks on demand below a frame that RK4 already
integrates accurately, at the cost of a semantic tax every later feature
pays. The case that justifies it is a long unattended continuous run with
quiet stretches, which no model in the records has.

**The design already admits most of the continuous-case gain.** A
fixed-step high-order explicit backend fits the seam as it is, an implicit
backend fits it with a `Dual` twin for the Jacobian, and a `restore!`
across deployments differing only in step and algorithm gives a step per
mission phase. Those three sit inside the present design.

## 1. Where the step lives today

The spec defines a frame as one grid step `[tₙ, tₙ₊₁]` with
`tₙ = t₀ + n·h` (§2.1), and `h` is at once the integration step and the
frame period. Six mechanisms key to the frame, and therefore to `h`.

- **The drain.** Root inputs change only at frame tops (§2.2, D-022). An
  input epoch, the span over which the root inputs are constant, is one
  frame. The θ = 0 discriminator of localization rests on the frame-top
  drain being the only thing that can differ between a prior's context and
  the trial (§10.4, D-182, D-290).
- **The tick lattice.** `Δt_base = N_base·h`, a frame top is a base tick
  when `k % N_base == 0`, and the due set is `(tick − Φ) % D == 0` with
  `tick = k ÷ N_base` (§10.5).
- **The trace and replay.** Batches are keyed by frame ordinal, `to_time`
  computes `k = ⌊(t − t₀)/h⌋`, the replay pointer is the frame-entry
  boundary index, and a checkpoint is legal only with the clock on
  `t₀ + k·h` (§11.5, §12.6, §12.7, §13.4, D-128, D-274).
- **Pacing.** The deadline is per frame, the budget is `h/p`, debt
  forgiveness is `5·h/p`, and control-plane latency is one frame (§10.7,
  §12.1).
- **Termination and partial advance.** `t_end` lands on the first grid
  boundary at or past it, `step!` counts frames, and the last frame is
  never shortened (§2.4, §12.6, D-133).
- **Localization.** The interpolant spans the last step, the tolerance is
  `localization_tol·h`, the budget is per frame, and the remainder step
  targets the grid point (§10.4).

The stepper seam is narrow (§10.2, `src/stepper.jl`).
`integrate!(stepper, model, h)` advances by exactly `h`, `startpoint`
retains `(xₙ, ẋₙ)`, `dense!` builds the cubic Hermite over the last step,
and the checkpoint hook pair is empty because a fixed one-step method
carries nothing across a frame top. The spec mentions `h` in 27 sections.
The code reads `deployment.h` in five source files, `deployment.jl`,
`frame.jl`, `model.jl`, `show.jl` and `sim.jl`, and 29 test files spell
`h =`. The coupling is conceptual rather than diffuse.

Two seeds of the separation already exist. With `N_base > 1`, a frame top
that is no base tick is an off-tick boundary: published, projected, events
iterated, due set empty (§10.5, `offtick_boundary!`). A variable sub-step
ending inside a frame is that kind of boundary, minus the frame-top role.
And §10.2's stiffness ladder names "subcycle the stepper against the tick
grid" as its second rung. The variable-step design is that rung with the
sub-step chosen by error control. The segment loop of `frame.jl`
(`_localized_frame!`) already integrates a segment, runs the arrival sweep,
triggers, fires `t*` and goes around with a remainder derived at use. Today
only `t*` creates segments; under adaptivity the controller also would. The
sub-step loop is that loop with a different author of `h′`.

## 2. What an adaptive method does: attempt, accept, reject

A fixed-step method computes one approximation of `x(tₙ + h)` and has no
idea how wrong it is. An adaptive method computes two approximations of
different order from the same stage evaluations, an embedded pair, and reads
their difference as an estimate of the local error. Dormand–Prince 5(4)
runs seven stages and combines them with fifth-order and fourth-order
weights. Heun's method is already such a pair for free: its result
`xₙ + (h/2)(k₁ + k₂)` and Euler's `xₙ + h·k₁` differ by `(h/2)(k₂ − k₁)`.
RK4 has no embedded companion; an adaptive RK4 needs step doubling at three
times the cost, which is why one reaches for a Bogacki–Shampine 3(2) or a
Dormand–Prince 5(4) pair instead.

An attempt is this sequence, with the trial state in scratch:

```julia
k₁ … k₇ = stage evaluations at xₙ + h·(…), clock set to the stage times   # each one interior sweep + RHS
x_high = xₙ + h·Σ bᵢ·kᵢ                  # the fifth-order result, the candidate xₙ₊₁
x_low  = xₙ + h·Σ b̂ᵢ·kᵢ                  # the fourth-order companion
eᵢ   = |x_high[i] − x_low[i]| / (abstol + reltol·max(|xₙ[i]|, |x_high[i]|))
err  = sqrt(mean(eᵢ²))                   # the norm, on values only under a Dual
accepted = err ≤ 1
h_next   = h · clamp(0.9 · err^(−1/5), 0.2, 5.0)    # shrink on a miss, grow on a wide pass
```

On acceptance `x_high` becomes `xₙ₊₁`, the clock advances and `h_next` is
the next proposal. On rejection the buffer is restored to `xₙ`, the clock
to `tₙ`, and the step is retried from the same start with the smaller
`h_next`. The stepper already retains `xₙ` as `startpoint`.

Rejections come from a steep transient, a kink in the right-hand side such
as a table knot or a clamp crossed inside the step, a mode branch taking
the other arm at a stage point, the first step under a generous `h_init`,
and the first step after a handler reset `x`, where the controller's memory
describes the pre-reset flow. A nonfinite stage is the extreme case:
standard practice counts it as a rejection and shrinks, failing only at
`h_min`.

Inside the framework a rejected attempt has no semantic footprint. During
an attempt the signal table is integrator scratch (§10.3), nothing is
published, no guard is read and no handler runs. A rejection leaves no
boundary, no snapshot, no event and no trace entry. Its effects are the
wasted stage evaluations and one more field in the execution cursor, the
attempt ordinal, so that a throw inside a rejected attempt's stage is
attributed (§13.4). Determinism is intact, since acceptance is a pure
function of the state and the deployment. Allocation stays at zero, since
the error vector and the trial buffer are fixed scratch. First-same-as-last
reuse makes an accepted Dormand–Prince step cost six sweeps rather than
seven, and `k₁` survives a rejection because it does not depend on `h`.
Localization does not interact with rejection: the arrival sweep, the
trigger and the trial evaluations run after acceptance, over the accepted
step, as they run today over the frame.

## 3. The reorganization

**The frame becomes a deployment quantity of its own, and the step becomes
the stepper's.** In spirit, `Deployment(build; frame = Period(1//50),
N_base, algorithm = RK4(h = 1//500))` for a fixed-step method and
`algorithm = DormandPrince45(abstol, reltol, h_init, h_min, h_max)` for an
adaptive one. A fixed-step backend validates that the frame is a whole
multiple of its `h`, which is today's harmonic check moved one level down.
Today's deployment is the special case where the frame equals one fixed
step, so every existing trajectory stays bit-identical under the new shape.
This lands D-227's deferred case: the `algorithm` keyword takes an instance
once a backend has something to parametrize, and that entry records that
admitting the instance form later is an extension, not a break.

**The seam contract grows from four clauses to about six.**

```julia
propose(stepper) -> Float64                 # the method's proposal; a fixed-step method returns its h
attempt!(stepper, model, h) -> (accepted::Bool, h_next::Float64)
                                            # integrate from t by h; on reject, x and the clock stay at t
startpoint(stepper)                         # unchanged
dense!(stepper, x̂, x₁, ẋ₁, θ, h′)           # unchanged; a backend of order above four overrides it
reseed!(stepper)                            # after a handler reset, overlay!, init! or restore!
checkpoint_stepper / restore_stepper!       # no longer empty: h_next and the controller's memory
```

The Model owns the clamp to the next scheduled instant, the bounds `h_min`
and `h_max`, the attempt count and the reseed calls. A backend owns its
error norm, taken on values only, its interpolant, and its first-same-as-last
reuse. The Model's side replaces the single `integrate!` call in `frame!`
with a loop to the frame top. Grid times stay indexed, never accumulated, so
the last sub-step targets `_grid_time(model, k)` exactly as the remainder
step does today. When the remainder to the frame top is a sliver, the
previous sub-step stretches onto the frame top rather than take a step of a
few ulps.

```julia
t_frame = _grid_time(model, k)
while clock.t < t_frame
    h = min(propose(stepper), t_frame - clock.t)      # the Model decides, within the proposal
    h = clamp(h, h_min, h_max)
    accepted, _ = attempt!(stepper, model, h)
    accepted || (attempts += 1; continue)             # an attempt budget bounds the frame's cost
    clock.t = (clock.t + h ≥ t_frame) ? t_frame : clock.t + h
    localize_and_settle!(model, …)                    # today's arrival sweep, trigger, t*, boundary
end
```

**Every accepted sub-step ends in a boundary.** Projection, the event phase
to quiescence, publication and the stop scan run there, with an empty due
set and no drain, exactly as today's off-tick frame top. Three consequences
follow. Boundary-detected guards resolve at the controller's step, so their
resolution becomes trajectory-dependent, a quantitative extension of the
existing dependence on `h` rather than a new kind. The snapshot stream
gains data-dependent cardinality, which `t*` boundaries already introduced
and D-081 already warned devices about. And localization keeps its present
shape per sub-step, because the interpolant still spans the last completed
step. The alternative, interior sub-steps with detection only at frame
tops, widens the even-crossing blind spot to the frame and needs a
piecewise interpolant over a variable number of sub-steps. It is not
recommended.

**Localization needs three adjustments.** The tolerance reference becomes
the frame period rather than the integration step, so that an event's time
resolution is a deployment fact rather than the controller's. The budget
stays per frame. The θ = 0 validation stays as written: at a sub-step start
that is not a frame top nothing can differ from the prior's context, so the
validation is redundant there but costs one sweep only on a trigger.
D-018's rejection of solver-matched interpolants gains an annotation: for a
fifth-order backend the cubic Hermite drops event-time accuracy one order
further, and the backend may override `dense!`.

**A handler reset is no longer free.** D-017 says a one-step method restarts
from a new state for free. The method does, but the controller's proposal
was computed for the pre-reset flow. The Model calls `reseed!` after any
handler that wrote `x`, after `overlay!`, at `init!` and at `restore!`.
Projection moves the state by ulps and needs no reseed.

**The checkpoint grows a stepper field.** D-274 designed the hook pair for
a multistep backend and left it empty. An adaptive one-step backend fills
it with `h_next` and the controller's memory. Without it, replay from a
checkpoint would not be bit-identical, since the first sub-step after the
restore would take `h_init` instead of the recorded proposal. `ModelState`
gains the field, `_walk_deployment!` learns the new parameters, and the
descriptor's deployment body changes shape, a format bump that reaches the
inspector repo.

**Every controller parameter is trajectory-determining and recorded.**
D-133's rule applies in full: tolerances, bounds, the initial step, safety
factors and the controller type join `Deployment`'s value equality and
hash, the trace header, the replay comparison and `DeploymentInvalid`'s
arms. With the algorithm as a value, `==` on an `isbits` spec struct
compares by bits, which is what replay needs.

**Two doctrines need a ruling.** The nonfinite check runs after `integrate!`
returns and throws `NonfiniteState` (D-157). Under adaptivity a nonfinite
trial should become a rejection above `h_min` and the throw at it, which
moves the check inside the attempt. And a frame that exhausts its attempt
budget or hits `h_min` is the controller's chattering. Under the §10.4
doctrine it should accept at the floor and warn once per frame with a new
kind beside `ChatteringBudget`, rather than throw. Failing hard is what
every ODE library does and is defensible, but the framework's two existing
budgets argue for degradation.

**Genericity gains one rule.** Trim and linearization drive the sweep and
never the integrator, so they are untouched. The sampled-data extension of
§14.10 would integrate at a `Dual`, and there the error norm must be taken
on values only, so that the step sequence is independent of the seeds. The
proposal is a `Float64` time, like `t₀`, whatever the clock's scalar.

**The domain argument survives, reframed.** §10.2's three claims hold.
Ticks still cap the step, now through the frame. A piecewise-smooth
right-hand side still starves high order, which is why fixed-step RK4 stays
the default. Adaptivity sits between rungs one and two of the stiffness
ladder: it shrinks the step where the transient is instead of everywhere.
What the argument loses is its sentence that the execution model forbids
the stretch by construction. The stretch up to one frame becomes legal, and
a model with a 20 ms avionics frame and a fast actuator no longer needs a
2 ms step at every instant of the run.

**What stays untouched.** The build pipeline, the executor's phase bodies
and their two arities, the discrete tier and its `Δt`, the drain and the
trace format, the pacer's frame deadlines, `t_end`, `step!`, replay's
pointers and `to_time`, the control plane, the device contract, trim,
linearization and the whole of Part II. The zero-allocation invariant
holds. The real-time story weakens by one sentence: a frame's cost is
bounded by `frame/h_min` sub-steps rather than by `N_base`, and the debt
mechanism absorbs the variance.

## 4. Strictly continuous models and the base grid

The base grid is a consequence of the discrete tier. The frame is a
consequence of something else, and today they share one number. What keys
to the frame besides ticks is the list of section 1 minus the lattice: the
drain, the input epoch of the trace, pacing and the control plane, and the
bookkeeping anchors (checkpoints, the replay pointer, `t_end`'s landing,
`step!`'s count).

For a strictly continuous model with no devices and no pacing, run
unattended to an end time, every item on that list is empty or expressible
per boundary. The drain has nothing to drain. The trace has no batches.
Pacing is off. A checkpoint can be taken at any published boundary, since
`CheckpointMidFrame` exists only because the loop integrates whole frames.
`t_end` can be landed on exactly by clamping the last step, since the rule
that the last step is never shortened protects grid integrity and there is
no grid. `step!` counts boundaries or advances by duration. For that class
of run the frame dissolves and the integrator is free up to whatever
`h_max` the user chooses, including none.

The general form: the Model lands every step on the next scheduled instant,
and the schedule is the union of whatever sources exist, the active points
of the tick lattice when discrete components exist, the recorded input
times under replay, `t_end`, and an optional maximum step. A frame is the
interval between two consecutive scheduled instants, and a purely
continuous unattended run has none. Four things need a ruling in the
frameless case.

- **The trace carries times, not ordinals.** With data-dependent
  boundaries an ordinal no longer names a time. Batches would be stamped
  with the boundary's `t`, and under replay those times become scheduled
  instants the integrator lands on. In a faithful replay the landing
  coincides with the step the controller would have taken. In a what-if
  replay the forced landing is the right semantics, inputs at the same
  times. This retires the reason D-081 gave for refusing a drain at `t*`,
  which was about ordinals.
- **Devices and pacing imply a maximum step.** A staged write lands at the
  next boundary, so a 10 s step is 10 s of input latency and a stale GUI.
  Attaching a device or setting a finite pace requires a finite `h_max`,
  which then plays today's frame. An unattended run may leave it infinite.
- **Events need a lever.** Both detection policies compare the predicate
  at a step's two ends, and an even number of crossings inside one step is
  invisible. A quiet trajectory can still cross a threshold by slow drift,
  and the controller, which watches the state's error and not the guard,
  will not shrink for it. The localized policy handles a single crossing
  over a long step, since the interpolant's accuracy tracks the tolerance
  and a relative bracket `tol·h_step` is scale-free. The even-crossing case
  does not. A model with events wants `h_max` as its detection resolution,
  or interior guard sampling at interpolant points, which is new machinery
  the design has declined.
- **The speedup has a ceiling.** An explicit method on a quiet trajectory
  is limited by stability, not accuracy. A stable actuator pole at 31 rad/s
  caps RK-family steps at roughly 90 ms however still the aircraft sits,
  because past that limit the error estimate explodes and the controller
  rejects. For an aircraft model with actuator and strut dynamics,
  unbounded steps buy a factor of five to fifty over a 2 ms fixed step, not
  a thousand. The thousandfold win exists for genuinely slow systems such
  as orbital or ballistic propagation, or with an implicit method.

Two deployment shapes under one mechanism follow. A model with discrete
components deploys on a lattice, and the integrator sub-steps between
active lattice points, with the frame equal to the base tick or a
sub-multiple of it. A strictly continuous model deploys with no lattice,
lands only on `t_end`, recorded input times and the optional `h_max`, and
may run frameless when unattended. The spec's two-unit vocabulary survives
with one shift: a boundary stays a published consistency point, and a frame
becomes the interval between scheduled instants, present when something is
scheduled and absent otherwise.

## 5. The roadmap, were it built

### 5.1 The decisions to settle first

Each decision names the options, the recommendation and where it lands. The
numbers are for reference here, not log numbers.

1. **Separate the frame from the step.** New deployment keyword for the
   frame; `h` keeps its meaning as the integrator's step in every formula.
   §2.1, §2.2, §9.2, §10.1, §10.5, Appendix D; new entry; D-019 and D-082
   annotated.
2. **What a frame may be.** The base tick or a sub-multiple, `N_base` as
   frames per base tick, the old `(h, N_base)` mapping onto a frame of `h`
   under a fixed-step stepper of `h`, so every existing trajectory stays
   bit-identical.
3. **Every accepted sub-step ends in a boundary.** §2.1, §5.3, §10.4,
   §10.6, §11.2, §12.3; D-081 annotated.
4. **The seam protocol** of section 3. §10.2 rewritten; D-017 annotated;
   new entry.
5. **The algorithm as a value**, every field recorded. §9.2, §11.5, §12.7,
   §13.9, Appendices B and C; D-227's deferred case closed.
6. **Degradation at the floor**: accept under a once-per-frame warning; a
   nonfinite trial rejects above the floor. §10.4, §13.4, Appendix C;
   D-157 annotated.
7. **Localization constants**: tolerance relative to the frame period,
   budget per frame, the degenerate crossing at a sub-step's end folds into
   that boundary, a high-order backend may override the interpolant. §10.4;
   D-018, D-133, D-290 annotated.
8. **Reset and checkpoint semantics**: `reseed!` at the four sites,
   `ModelState`'s stepper field. §10.2, §11.5, §12.6, §14.5; D-274
   annotated.
9. **Detection resolution becomes controller-dependent**, stated openly,
   `h_max` the author's lever, interior guard sampling a guarded addition.
   §2.3, §10.4.
10. **Pacing and worst-case cost**: deadlines per frame, sub-step
    publications unpaced, a frame bounded by `frame/h_min` sub-steps. §10.7.
11. **Genericity**: `Float64` proposals, the error norm on values. §7.2 or
    §14.10.
12. **The status of the fixed-step argument**: the default's justification,
    not a law; the seam shaped so an `OrdinaryDiffEq` adapter's proposed
    step, interpolant and controller memory fit it. §10.2,
    `companions/flight_case_studies.md` section 5.
13. **The frameless continuous mode** of section 4, ruled now in one entry
    so the first increments leave room for it, built last.

Decisions 1 to 12 form one design round, landing as a docs arc before any
code: spec edits in about twenty sections, about eight new log entries, the
annotations above, and glossary entries for "scheduled instant", "sub-step"
and "attempt", with "frame" and "remainder step" reworded.

### 5.2 The implementation sequence

Each increment follows `rules/increment_rules.md`: a prototype in a scratch
worktree, a brief from it, one build, one cold review, the fixes, the
verification, and an oracle.

1. **Increment A, the separation under fixed step.** The new deployment
   keywords with the algorithm as a value, `N_base` as frames per base
   tick, the sub-step loop in `frame.jl` generalizing today's segment loop,
   the fixed-step backends under `propose` and `attempt!` with acceptance
   always true, the sub-step boundary as `offtick_boundary!`, the pacer and
   `_frames_to` reading the frame period. Touches `deployment.jl`,
   `stepper.jl`, `frame.jl`, `model.jl`, `sim.jl`, `control.jl`,
   `show.jl`, `diagnostics.jl` and the 29 test files that spell `h =`.
   Oracle: the suite bit-identical under the mapped deployments, plus a
   subcycling run, `frame = 1//50` with `RK4(h = 1//500)`, whose snapshots
   equal those of the old `h = 1//500, N_base = 10` run at every time while
   its frame indices and drain cadence differ. Nothing new is observable
   after this increment except subcycling.
2. **Increment B, the recorded parameters and the checkpoint field.**
   `Deployment`'s equality and hash over the algorithm value, the header
   and replay comparison, `_walk_deployment!`, the descriptor's format bump
   with its schema and the inspector's pin, `ModelState`'s stepper field
   with the hook pair filled, the `reseed!` calls. Oracle: a replay refused
   on a tolerance change alone, a checkpoint round trip carrying the
   stepper field, the descriptor round trip under the new format.
3. **Increment C, the first adaptive backend.** Heun–Euler 2(1) first,
   since Heun exists and its estimate is free, then Dormand–Prince 5(4)
   with its own interpolant and first-same-as-last. The attempt loop with
   the clamp, the bounds, the attempt budget and the floor warning, the
   finiteness check inside the attempt, the cursor's attempt ordinal, the
   frame-relative localization tolerance. Oracles: convergence order on a
   closed-form problem, error scaling with the tolerance, a forced
   rejection path, bit-identical replay through rejections, a mid-run
   checkpoint and restore reproducing the step sequence, `integrate!` at
   zero allocation on the adaptive path, a localized event inside a
   sub-step, a handler reset followed by a reseed.
4. **Increment D, the surface.** Docstrings for `Deployment`, `Model`, the
   backends and `checkpoint`, Appendix B, a tutorial chapter on choosing a
   stepper, the examples package where it deploys. Oracle: the Documenter
   build and the precompile workload through an adaptive deployment.
5. **Increment E, the frameless continuous mode.** The time-stamped trace
   with replay landing on recorded times, the exact `t_end` landing,
   `step!` by duration, the device and pace gates on `h_max`, the relaxed
   checkpoint rest. Oracle: an orbital or ballistic model run unattended
   with `h_max = Inf`, replayed bit for bit, and refused a device attach
   under an infinite `h_max`.
6. **Increment F, optional, active-point landing.** Landing only on lattice
   points where some component is due, with the schedule carrying its
   active residues per hyperperiod. The only increment that relieves the
   charter's awkward-period case (section 1.4 there); it waits for a model
   that has one.

Increments A and B change the deployment keyword surface that the
tutorial, the exported-name audit and the first release would otherwise
teach and freeze, so they would precede the tutorial in `pending.md`'s
order; C and D could sit either side of the release; E and F after it.
Three risks: the spec sweep is the largest single item and worst half-done,
so the design round should land as one docs arc; increment A's bit-identity
oracle must be written before the loop is touched; and the even-crossing
blind spot under long steps is a modeling hazard the docs must teach beside
`h_max`, since no diagnostic can see it.

## 6. The verdict

Not now, and probably not in the general form unless a specific model asks
for it.

**The domain argument holds, and the analysis sharpened it.** The step is
capped by the avionics frame whatever the method, so an adaptive integrator
can only shrink below the frame in every model that has a controller. Below
the frame, an explicit method is capped again by stability. The flight case
study puts the fastest poles inside RK4's region at 20 ms already, and the
discontinuities that would force a small step are what localization handles
exactly today. For the models this framework exists for, the gain is
bounded above by one 20 ms step instead of ten 2 ms steps in the rare
deployment that needed the 2 ms, and the kinked right-hand side eats part
of that through rejections at table knots.

**The costs are not just the sweep.** The seismic part is reversible. The
part that is not is the semantic tax every later feature pays:
trajectory-dependent boundary cardinality in the log and the inspector's
live view, controller-dependent resolution for boundary-detected events, a
reseed rule at four doors, a stepper field in every checkpoint, six more
recorded parameters in every header, and a second deployment vocabulary to
teach before the first users have met the first one. D-019's "no
demonstrated need" was written for this axis.

**The case that would justify it is a different kind of model**: long
unattended continuous runs with quiet stretches, orbital or ballistic
propagation, mission-level simulation with no avionics in the loop. There
the frameless mode buys two or three orders of magnitude. That model is not
in the examples package, not in the pending work, and not the flavor the
records claim. If it arrives, decision 13 is the one to build first and the
within-frame adaptivity second, the reverse of a general-purpose engine's
order.

**The conditions that would reopen it**: a model whose fastest transient
needs a step more than ten times below the frame while real-time cost
matters, or a continuous-only model run unattended over hours of simulated
time. Either is a consumer, and either makes increment A worth its brief.

## 7. What the present design already admits

For a smooth, slow, purely continuous model, three remedies sit inside the
existing seam and recover most of what variable step would have bought.

**When accuracy limits the step, order is the lever.** A fixed-step
method's error per unit time scales like `hᵖ`. If RK4 needs a 1 ms step to
hold a target error of 10⁻¹², an eighth-order Runge–Kutta holds it at about
30 ms, and even with three times the stages per step that is an order of
magnitude fewer sweeps. Astrodynamics has run fixed-step high-order
integrators for decades. In the framework this is one backend file under
the present seam, zero allocation, generic in the scalar; for a
continuous-only model `h` may already be any rational, so a 60 s frame is
legal today. The cubic Hermite interpolant would not keep up: its `O(h⁴)`
accuracy is poor beside an eighth-order solution over a long step, which is
the case D-018 said solver-matched interpolants would matter for, so a
high-order backend ships with its own continuous extension. The
even-crossing blind spot widens with the step, and `h` stays the author's
lever for it.

**When stability limits the step, implicitness is the lever.** A model
whose fast modes are stable but present caps every explicit method at a
step of a few over the fastest rate, however quiet the trajectory. The
trapezoidal rule or an SDIRK pair is unconditionally stable there, and the
step is then limited only by the accuracy of the slow modes. The seam
admits it, since these are one-step methods that advance by `h`, but the
backend is heavier: each step solves a nonlinear system by Newton
iteration, which needs the Jacobian of the composite right-hand side, and
§10.2 already notes that eltype genericity supplies it through a `Dual`
activation of the sweep. The scratch machinery that trim and linearization
use for a seeded half is the mechanism, so the backend holds a `Dual` twin
of the model, built once at materialization beside its linear-algebra
buffers, with an in-place factorization to keep allocation at zero. A kink
inside a step slows Newton and a mode branch flipping between iterates can
stall it, so an implicit backend wants a smooth model.

**What neither gives back** is adaptation to a trajectory whose timescale
changes by phase. A fixed step must be sized for the worst stretch, a
perigee passage or an entry. For near-circular orbits or cruise the loss is
small; for a highly eccentric orbit it is the eccentricity-driven ratio of
timescales. The partial remedy is one ruling: allow `restore!` across two
deployments that differ only in step and algorithm, with the checkpoint's
time on both grids. Today `CheckpointMismatch` refuses it, since the
deployment is compared whole. Relaxing it gives a piecewise-constant step
chosen per mission phase at the user's hand, each phase its own run and its
own trace.

The order to build, if such a model arrives: the fixed-step high-order
explicit backend with its matched interpolant, then the restore-across-steps
ruling, then an implicit backend only when a stiff-but-quiet model shows up.

**The `Dual` allocation canaries.** An implicit backend would run a `Dual`
sweep several times per step inside the stepping loop, which is the scope
of the zero-allocation invariant (§9.8). The suite's `Dual` phase-body
assertions, today pure inference canaries over paths only
allocation-tolerant services run, would become hot-path invariants of the
same rank as the `Float64` ones. A primitive that keeps its stores `isbits`
and its stages type-stable allocates nothing under `Dual` by the same
reasoning as under `Float64`, since `Dual{Tag,V,N}` and an `SArray` of it
are `isbits`. What can still trip the canary is author code generic in name
but not in fact: a branch returning `Float64` on one arm and `Dual` on the
other, scratch allocated in a stage instead of the workspace, or a call
reaching a `Float64`-only method. The block allocation testsets in
`test_blocks.jl` measured phase bodies at `Float64` alone, the suite's one
`Dual` measurement being `test_executor.jl`'s over `bare_ports_world`. The
discussion landed that gap as an unordered item in `pending.md` and a
standing rule in `rules/brief_rules.md`'s library-blocks section, at
`70f15e0`. A `Dual` model freezes the discrete tier and compiles events
out, so the sweep covers the continuous blocks' sweep and `x_deriv` bodies
and says nothing about the discrete blocks.

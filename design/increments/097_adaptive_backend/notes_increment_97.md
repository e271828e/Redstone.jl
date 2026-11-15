# Notes: increment 97, the coordinator's record

What the coordinating session settled with the user that the spec, the log
and the brief do not carry. The increment is the roadmap's item 4, the
first adaptive backend (`design/increments/roadmap_variable_step.md`). Its
rulings from before the prototype are that file's section "Ruled on
2026-11-12".

## The prototype

A high-tier agent prototyped the whole increment on 2026-11-15 in a scratch
worktree detached at `6d2ec22`. It reported the gate at 10 251 of 10 268 on
Julia 1.13.3, red on purpose: the 15 failures and 2 errors are existing
pins of `Scheduled`, the proposing stub of `test_stepper.jl`, which three
rulings of 2026-11-12 move. The rest of the suite passed, with 105 new
assertions in `test/test_adaptive.jl`, and the battery was green. The agent
ran past its context ceiling, so a successor agent makes the revisions
below from the worktree and the prototyper's notes.

## Ruled on 2026-11-15

The user ruled on the prototype's readings after a discussion of each. The
numbers are the coordinator's items as put to the user.

1. **The stub's pins are repinned, each named with its cause.** The
   roadmap's "increment 4 moves no existing trajectory" holds for RK4 and
   Heun and missed the stub. Equal division moves the stub's boundaries, a
   `t*` that ends the step changes one attempt count, and the clamp into
   `[h_min, h_max]` lifts proposals of `0.0`, `-0.1` and `1e-20` to the
   floor where D-452 refused them. The refusal existed because nothing else
   ended the span, and the floor now does. A negative proposal takes the
   literal clamp. `NaN` stays refused.
2. **The floor is read by count, not by length.** An attempt is the
   floor's when no proposal could shape a shorter one, that is, when its
   count is `⌊r / h_min⌋`. The ruling of 2026-11-12 said "at or below
   `h_min`". Over a distance of 0.25 with `h_min = 0.1` the cap gives two
   steps of 0.125. Read by length, a rejected 0.125 is retried at the same
   length until the budget runs out, then a literal 0.1 leaves 0.15 and
   the pattern repeats. A forced step can be up to just under `2·h_min`.
   The prototype's probes saw at most 3.6% above. The spec states the rule
   by the remedy: when the backend rejects the shortest step the shaping
   rule allows over the distance, the Model commits it and files
   `StepFloor`.
3. **Strict first-same-as-last reuse is refused, and BS3's fourth stage is
   paid in full.**
   - The user's reason: the sweep exists so that expensive intermediate
     computations are not repeated, and the fresh first stage (D-447)
     already takes that saving. What strict reuse adds is one `x_deriv`
     block per quiet step, at the cost of a silent failure mode. Type
     stability and zero allocation matter more than savings of that size.
   - The roadmap's "Strict first-same-as-last reuse is not built" recorded
     no reason, and no other record holds one. The reason above is the
     first.
   - What it would have needed, as the coordinator counted it: a report
     that projection wrote nothing, an invalidation at a `t*`, at a
     restore and at a write outside the frame loop, and care with the
     freshness flag. A stale first stage gives a slightly wrong step that
     no test catches unless pinned bit for bit.
   - Under tick-capped steps it would seldom apply, since a tick runs at
     every due instant and raises the notice.
   - `arrival_derivative`, the prototype's optional eighth seam call, is
     dropped. It saved 6 sweeps of 667 in a 3 s run with events, a saving
     of the kind just refused. The seam stays at D-452's seven calls.
   - The log entry rests the backend's case on error control at low order
     and on the generic Hermite interpolant, which serves any order up to
     4. It names two uses: tick-capped models, and continuous-only models
     at a coarse frame. It drops the roadmap's "three evaluations per
     accepted step".
   - **The method is chosen after a probe.** The successor compares BS3 as
     built with a three-stage 3(2) pair on evaluations spent for a given
     achieved error, on a smooth continuous-only model at a coarse frame
     and on the example closed loop. A three-stage pair pays no stage at
     the step's end, so it costs three quarters of BS3 per attempt here.
     Its error estimate is of unmeasured quality. The user asked for the
     probe to be kept and rules on its figures.
4. **The first proposal is infinite.** The first step takes what `h_max`
   and the span allow. Hairer's starting estimate falls back to a fixed
   `1e-6` s when the initial state is zero, a domain rate as a framework
   default. Under a coarse frame the first attempt is the whole frame: its
   stage points extrapolate a frame ahead, where a model's own code may
   throw, and seven attempts shrink the step by about 78 000 times at
   most. `h_max` caps the first attempt as it caps every step, so the
   docstring says to set it under a coarse frame. No `h_init` keyword.
5. **The controller's constants stand as built.** The coordinator checked
   them against the OrdinaryDiffEqCore source in the local depot
   (`alg_utils.jl`, `integrators/controllers.jl`): gains `7//(10·order)`
   and `2//(5·order)` at order 3, safety `9//10`, limits `1//5` and 10,
   `qoldinit = 1//10^4`. One departure is kept and named in the log entry:
   after a rejection the backend shrinks by the elementary exponent `1/3`,
   where OrdinaryDiffEq uses its first gain `0.7/3`. At a scaled error of
   8 that is a factor of 0.45 against 0.55.
6. **The mutant of increment 93's ruling 10 is an accepted survivor.**
   `init!`'s `reset_stepper!` moved after boundary zero cannot be killed:
   the reset writes both carried fields, and the notice leaves the reset
   state as it is. D-452's "before boundary zero" stands as the order a
   later backend may rely on.
7. **A tripwire in the test fixture makes the forced acceptance's mutants
   go red**, as ruling 11 of increment 93 did for the stub. They spun the
   loop forever and were not run. The successor also runs a mutant that
   raises the notice at projection.

**Ratified as built**, the prototype's other readings:

- the names `proposes`, `attempt_budget = 7` and the warning kind
  `StepFloor` with reasons `:rejected` and `:budget`;
- a step with no history proposes by the elementary controller, which is
  how the convergence test reaches the integral gain alone;
- a forced acceptance tells the backend nothing;
- under a proposing method the clock's least gap is `min(unit, h_min)`,
  refused at the doors that read the last frame, as D-450 does;
- the shaping counts carry a slack of 4 ulps of the clock, the form of
  `_frame_slack`;
- `show` prints the range of steps per frame, "as proposed";
- a bad tolerance is refused at the token as `ArgumentInvalid`;
- `h_min` and `attempt_budget` print and compare under a fixed-step method
  too;
- the descriptor's format bump and the inspector's pin are void, since the
  descriptor's deployment body is the build's alone.

**Outside the readings**, taken with the same ruling:

- One BS3 run joins the precompile workload, once the successor measures
  what it adds to precompile time. BS3's first run costs 1.21 s in a fresh
  process against 0.06 s for RK4.
- "Floor" gains a glossary entry. This is the coordinator's reading of the
  user's "go with your recommendations": the coordinator had said the
  entry needed approval and had not recommended it in so many words.
- `dense!`'s docstring loses its sentence that is wrong for BS3.
- §10.7 and the backend's docstring say that a proposing method does not
  suit a paced run, whose work per frame is bounded only by
  `Δt_frame / h_min`. Nothing refuses or warns in code.

## Ruled on 2026-11-15, after the probe and the revision

A successor agent revised the worktree to the rulings above and reported
the gate at 10 259 of 10 259 and the battery green. A second agent ran the
probe of ruling 3 in a frozen copy of the prototype. The user then ruled:

8. **BS3 stays.** The probe found that the three-stage pair spends fewer
   evaluations than BS3 for the same achieved error on every model: 0.77
   to 0.84 of BS3's on a Kepler orbit of eccentricity 0.8 and 0.9, 0.65 to
   0.82 on van der Pol, 0.72 to 0.76 of the `rhs` blocks on the example
   closed loop once steps go below the frame, and exactly 0.75 where the
   frame caps the step. The user kept BS3 all the same, preferring the
   standard tableau to uncharted territory for now. What the probe
   established besides:
   - For a three-stage third-order tableau the embedded second-order
     estimate is unique up to a scale: `s·h·(k₁ − 3k₂ + 2k₃)` on BS3's
     first three stages. The choice of weights only changes what a
     tolerance means.
   - The estimate never fell below the true local error at a sampled
     step. Its spread is about twice BS3's, and on Kepler it needs 3% to
     13% more steps for the same error.
   - OrdinaryDiffEq's `Alshina3`, which the coordinator had offered as an
     independent candidate, has the same tableau with the estimate
     `h·(4/9)·k₂`, which is first order. It is not a candidate.

   The three-stage pair remains a later option, as a second token and
   stepper behind the same seam.
9. **The first step is bounded from the first stage's derivative.** This
   amends ruling 4. The probe hit the infinite proposal's weakness at a
   modest frame: on Kepler at a 2 s frame and a tolerance of `1e-6`, the
   first step spent its seven attempts shrinking from 2 s to about
   `1e-4` s, then dropped to `h_min` with a `StepFloor` warning and
   climbed back by 10 times per step. The bound is the rule of MATLAB's
   `ode23` as the coordinator recalled it, to be checked against a source:
   the step whose first-order change of the state is `0.8·reltol^(1/3)`
   of its scale. It needs no default rate, since a vanishing derivative
   leaves the step unbounded. The Model fixes an attempt's length before
   the backend sees the derivative, so how the bound enters the seam is a
   reading the reviser takes and reports.
10. **The reviser's four flags, adjudicated as the coordinator proposed.**
    - Two repins change a test's setup as well as its value, and the brief
      names them: a scheduled rejection moved from attempt 14 to 13, and
      `h_min = 1//32` in the loop of lifted proposals.
    - §10.4's "one order below the discrete solution" is corrected. It is
      false for BS3 and was already false for Heun.
    - The half of `_shaped`'s refusal that checks the step advances the
      clock is confirmed dead by a mutant, then removed.
    - D-461 gains the reason for its departure from OrdinaryDiffEq: a
      rejected step's own error is the direct measure, so the elementary
      shrink is the right size, and a weaker one risks a second rejection.

## What the discussion settled besides

- **Increment 97 stays in the work order.** The coordinator suggested
  parking it, since real-time and hardware-in-the-loop practice is
  fixed-step and the arc's other increments already serve that use. The
  user kept it: the machinery is in place, the formalism claims to be
  domain-neutral, and a model of continuous components alone should get a
  useful method.
- **The fresh first stage stays.** The user judged its four-part machinery
  acceptable for what the sweep is for. The coordinator withdrew a
  suggested `pending.md` bullet to revisit it.
- **A fifth-order backend remains later work.** It needs its own
  interpolant. By the cost count below, a six-stage pair without a stage
  at the step's end would suit it better than Dormand–Prince.

## Measurements the coordinator made

On the prototype's worktree, Julia 1.13.3, one thread. The scripts are in
the scratch folder named below, under `probes_coord/`.

- **The fresh first stage on the example closed loop**
  (`fresh_cost.jl`, `fresh_count.jl`): 120 s at 200 Hz under RK4. With the
  fresh first stage, 3 interior sweeps per frame and 530 ns per frame.
  With a full sweep at every stage, 4 and 527 ns. The states are
  identical. The phase bodies take 5.4 ns (`sweep_1`), 10.2 ns
  (`sweep_2`) and 17.8 ns (`rhs`), so four evaluations are about 130 ns
  of the frame and the saved sweep about 3%. In this model `x_deriv`
  holds the physics, against D-447's "the sweep is the costliest part of
  a stage".
- **One attempt on the prototype's seam rig** (`attempt_cost.jl`), two
  states: four evaluations alone take 21.6 ns under either method. A whole
  attempt takes 34.3 ns under RK4 and 68.6 ns under BS3. BS3's extra 34 ns
  is the error norm, the controller and one more copy of the state. The
  controller's two fractional powers alone take 14.6 ns (`pow_cost.jl`),
  so the prototype's "mostly in its two `pow` calls" overstates them.
- **The cost of a method here.** No reuse is taken, so every stage is a
  full evaluation, and with a fresh first stage a step's interior sweeps
  are its stages minus one. BS3 costs what RK4 costs, at one order less.

## Scratch

`/private/tmp/claude-501/-Users-miguel--julia-dev-Redstone-jl/e10a5fc9-27fb-4587-bd0d-070e826ab3bb/scratchpad/`:

- `wt_inc97`, the prototype's worktree, detached at `6d2ec22`, with
  `test/test_adaptive.jl` untracked.
- `proto_97/`, the prototyper's `report.md`, `notes.txt`, `probes/`,
  `mutants/` and `gate_final.log`.
- `probes_coord/`, the coordinator's probes.
- `wt_probe`, a copy of the worktree the prototyper made, which can go.

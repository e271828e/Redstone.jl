# Brief: increment 97, the first adaptive backend

The arc makes four commits: the docs commit `106cb8a` (D-460, D-461,
D-462), this brief with the prototype's patch, the code commit, and one
fix commit after the cold review. Drafted on 2026-11-15 at `106cb8a`. A
high-tier agent prototyped the whole increment in a scratch worktree
detached at `6d2ec22`, and a successor agent revised it twice to the user's
rulings. The patch beside this brief, `prototype_increment_97.patch`, is
that worktree's diff, and the prototype is the implementation: the
coordinator applies it and commits. One word of D-461 was corrected on the
real tree after the patch was cut, "would add" to "would save one more".
The user delegated the landing and the cold review on 2026-11-15, to stop
only for something major. The rulings are in `notes_increment_97.md`. This
brief keeps its record half only.

Not normative: if a shape below proves wrong at the keyboard, stop and
report rather than deviate.

## What is settled

The increment delivers the roadmap's item 4
(`design/increments/roadmap_variable_step.md`) and the "Next" bullet of
`pending.md`'s variable-step item. The rulings are the roadmap's sections
"Ruled on 2026-11-12" and "Ruled on 2026-11-15" and the notes file, rulings
1 to 10. In short:

- **The floor and the budget** (D-460). `h_min` is an optional `Deployment`
  keyword that a proposing method requires, and `attempt_budget` counts a
  step's attempts, default 7. The Model clamps every proposal into
  `[h_min, h_max]`. When the backend rejects the shortest step the shaping
  rule allows over the distance, the Model commits it and files
  `StepFloor`. The floor is read by count, so a forced step can be up to
  just under `2·h_min`.
- **One shaping rule** (D-460). Over the distance `r` to the next mandatory
  instant the Model takes `r / n`, with `n = ⌈r / min(proposal, h_max)⌉`
  capped at `⌊r / h_min⌋` and at least 1.
- **A `t*` ends the step under a proposing backend** (D-460). A fixed-step
  method keeps its remainder.
- **Projection raises no notice** (D-460).
- **BS3 under proportional-integral control** (D-461), its constants
  OrdinaryDiffEqCore's defaults at order 3, the error over values alone in
  the maximum norm, a nonfinite estimate a rejection at the strongest
  shrink. Every attempt pays four stages. Strict first-same-as-last reuse,
  the hand-over of the fourth stage to localization, and a three-stage pair
  are each rejected there with their figures.
- **The first rejection is bounded** (D-461) by the rule of MATLAB's
  `ode23`, from the first stage's derivative. The first attempt runs whole.
- **The algorithm is compared as one value** and walked by field for the
  `CheckpointMismatch` message (D-462).

## The shape built

Old line ranges are from `git show 6d2ec22:file`, which the tip matches for
every file below. The patch is the reference.

- `src/deployment.jl`, 16 hunks in 249 to 627. The token
  `BS3(; reltol, abstol)`, refusing a tolerance that is not a positive
  finite real as `ArgumentInvalid`. The trait `proposes`, with no default.
  The fields `h_min` and `attempt_budget`, through `h_max`'s door:
  `:missing` under a proposing method without `h_min`, `:range` for one
  above the resolved `h_max`. The lattice's least gap is `min(unit, h_min)`
  under a proposing method. `==` and `hash` cover both fields.
- `src/stepper.jl`, 5 hunks in 17 to 224. `BS3Stepper{T}`: the carried pair
  `proposal` and `memory`, five scratch vectors, the tableau, the `BS3_*`
  constants with their source. `attempt!` in four evaluations.
  `_starting_bound`. `reset_stepper!` sets `(Inf, 0.0)`, and
  `discontinuity!` clears the memory. The seam keeps seven calls.
- `src/model.jl`, 7 hunks in 28 to 867. The latch `floor_reported`.
  `integrate_step!` accepts a rejected attempt at the floor and shapes the
  attempt after the budget's last from `h_min`. `_clamped` gives way to
  `_shaped`, `_shaped_steps`, `_floor_steps`, `_at_floor` and
  `_report_floor!`. `_shaped` refuses only a proposal that is not a number.
- `src/frame.jl`, 10 hunks in 39 to 314. Steps shaped under a proposal.
  `_localized_step!` takes `proposing` and returns whether it ended at a
  settled `t*`. The floor latch resets at each frame.
- `src/checkpoint.jl`, 2 hunks. The mismatch walk names `h_min`,
  `attempt_budget` and the algorithm's differing fields.
- `src/diagnostics.jl`, 8 hunks, and `src/dataplane.jl`, 4. The warning
  kind `StepFloor(t, h, h_min, attempts, reason)`, reason `:rejected` or
  `:budget`, with the counter `step_floor`. Message arms for the two
  keywords.
- `src/show.jl`, 3 hunks. `h_min` when set, `attempt_budget`, and under a
  proposing method the range of steps per frame, "as proposed".
- `src/precompile.jl`, 2 hunks. One BS3 run in `workload()`.
- `src/sim.jl`, 1 hunk, keyword lines in the sugar docstrings.
  `docs/src/api.md`, 1 line.
- `test/test_adaptive.jl`, new, 15 testsets with the fixtures `Watched`,
  `ClockHooks`, `Cliff`, `Recharger` and `Kepler`. `test/test_stepper.jl`,
  14 hunks: the stub's trait, `h_min` on its deployments, and the repins
  below. Enumeration lines in `test_diagnostics.jl`, `test_lattices.jl`,
  `test_show.jl`, `test_precompile.jl`, `imports.jl`, `RedstoneTests.jl`.

## Measurements

Every figure is from a run in the prototype's worktree on Julia 1.13.3.
The commands are in the agents' notes, named under "Scratch" in the notes
file.

- **Gate.** 10 267 of 10 267 after the second revision. The first
  prototype read 10 251 of 10 268, red on the stub's pins alone, and the
  first revision 10 259 of 10 259.
- **Allocation.** 0 B at `Float64` and `LinearizeDual` for `frame!`, the
  three phase bodies, `attempt!` rejected and accepted, and `integrate!`
  while retrying. Measured on the first prototype. The testset keeps it.
- **One attempt on a two-state rig.** Four evaluations take 21.6 ns under
  either method. A whole attempt takes 34.3 ns under RK4 and 68.6 ns under
  BS3. The 34 ns are the error norm, the controller and one more copy.
- **Order.** 3.19, 3.10, 3.05 at fixed steps. Error against tolerance has
  slopes 1.02 to 1.006 under the elementary controller and 0.97 to 0.99
  under proportional-integral control.
- **The first step.** From an infinite proposal on a damped oscillator,
  none to four rejections across frames of 1/100 s to 1 s. On a Kepler
  orbit of eccentricity 0.8 at a 2 s frame and a tolerance of `1e-6`,
  unbounded, the first step spent seven attempts and took a step at
  `h_min` under `StepFloor`. Bounded, it files none.
- **The cap's lengthening.** At most 3.6% above the proposal, none
  rejected.
- **Precompile.** 13.23 s without the BS3 run and 14.12 s with it, three
  fresh processes each. BS3's first run falls from 1.21 s to 0.04 s.
- **The three-stage pair.** 0.65 to 0.84 of BS3's evaluations for the same
  achieved error across three models. D-461 and the notes carry the table.

## Readings the prototype took

Each was put to the user, who ruled on 2026-11-15. The notes file holds
the reasons.

1. The stub's pins are repinned with their causes. Ratified.
2. The floor by count. Ratified, and the spec states it by the remedy.
3. Strict reuse refused, the eighth seam call dropped. Ruled.
4. The infinite first proposal. Ratified, then amended by 9.
5. The constants, with one departure from OrdinaryDiffEq. Ratified.
6. The mutant of increment 93's ruling 10 is equivalent. Accepted.
7. A tripwire for the forced acceptance's mutants. Ruled.
8. BS3 kept over the three-stage pair. Ruled.
9. The first rejection bounded, the early rejection refused. Ruled.
10. Four flags of the reviser's, adjudicated as proposed.

Ratified as built: the names, the elementary controller with no history,
the silent forced acceptance, the floor in the clock's least gap, the slack
of 4 ulps in the shaping counts, the `show` line, the tolerance's refusal
at the token, the two keywords printed and compared under a fixed-step
method, and the void descriptor bump.

**Test setups changed, beyond a pin's value.** Three, each judged sound by
the coordinator:

- `test_stepper.jl`, the localized-shortened case: the scheduled rejection
  moves from attempt 14 to 13, so the shortened step still holds the
  crossing under equal division.
- `test_stepper.jl`, the loop of lifted proposals: `h_min = 1//32`, since
  at `1//2^20` a frame needs 131 072 floor steps and trips the stub's own
  guard.
- `test_adaptive.jl`, the floor testset: `attempt_budget = 1`, since the
  starting bound now sends a first rejection straight to the floor, and a
  budget of 1 is how the testset still reaches `:budget`.

## What the tests pin, by property

All in `test/test_adaptive.jl` unless named. The mutants were run by the
agents, and each is listed with the testset that turns red.

- **Replay from a mid-run checkpoint, through rejections and sub-steps,
  bit for bit** (§10.2, §12.6, §12.7). The reset proposal changed.
- **Order 3 and error proportional to tolerance** (§10.2). A weight of the
  tableau changed, the elementary branch removed.
- **Zero allocation at both scalars** (§9.8). Measured.
- **The controller** (§10.2): a handler's reset raises the notice, the next
  step uses the integral gain alone, the proportional-integral formula, the
  growth limit. The notice made a no-op, the memory gain, the safety
  factor, the memory updated on a rejection, the growth limit at 5.
- **A `t*` ends the step under a proposal** (§10.4). The remainder run
  under a proposal.
- **The floor** (§10.2, Appendix C): the forced acceptance, the budget, one
  report per frame. The forced acceptance removed, `_at_floor` always false
  and always true, the budget's branch never taken, the latch never reset.
- **A nonfinite estimate** (§13.4). A `NaN` proposal, the strongest shrink
  at 0.5, the nonfinite shrink by the error's formula.
- **A `Dual` run takes the `Float64` run's steps** (§14.10). The partials
  in the norm.
- **Projection raises no notice** (§10.2). The notice raised at
  projection.
- **The starting bound** (§10.2): its value on a zero state by hand, the
  Kepler case without a warning, a vanishing derivative leaving the step
  unbounded. The bound removed, a vanishing rate giving zero, the least
  scale dropped, the fraction at 1, the starting state always on.
- **The checkpoint pair and `init!`'s reset** (§12.6). The reset proposal.
- **The shaping rule** (§10.5). No slack, no cap at the floor, no lower
  clamp.
- **The keywords, compared, hashed and named** (§9.2, §12.7). `h_min`
  optional, `==` without `h_min`, the algorithm walked whole.
- **The floor in the clock's resolution** (§10.5). The gap without
  `h_min`.
- **`test_stepper.jl`.** A `NaN` proposal is still refused, and proposals
  of `0.0`, `-0.1` and `1e-20` are lifted to the floor.

Not run: a mutant of `show`.

## Routing

Single-stage, so none for a builder. The reviewer reads this brief, the
notes file, D-460 to D-462 in `design/log.md`, and the map entries for
`stepper.jl`, `model.jl`, `frame.jl` and `deployment.jl`.

## Bookkeeping

- `design/code_map.md`: the entries for `deployment.jl`, `stepper.jl`,
  `model.jl`, `frame.jl`, `checkpoint.jl`, `diagnostics.jl`,
  `dataplane.jl`, `show.jl`, `precompile.jl`, `test_stepper.jl` and a new
  entry for `test_adaptive.jl`, in the code commit.
- `design/pending.md`: the variable-step item's "Landed" bullet gains
  increment 97, and "Next" becomes the roadmap's increment 5, the
  teaching, once the review's fixes land.
- `design/tools/coinage_inventory.md`: the row for "floor", in the docs
  commit.
- The roadmap, amended in the docs commit.

## Out of scope

- A three-stage 3(2) pair as a second backend, and a fifth-order backend
  with its own interpolant: the roadmap's "Later, when wanted".
- Strict first-same-as-last reuse: refused, D-461.
- The roadmap's increment 5, the teaching: the companion walkthrough, the
  tutorial's deployment chapter and the inventory's note.
- The inspector's next pin: unchanged by this increment.
- OrdinaryDiffEq's `Alshina3`, whose error estimate the probe found to be
  first order. Nothing was reported upstream. That is the user's call.
- The comment "the runtime stream's nine" in `test_diagnostics.jl`, stale
  before this increment: a loose fix.
- A floor step's length can print an ulp below `h_min`, since it is
  `r / n`. Cosmetic, left as it is.

## The cold review

An open mind, probe scripts outside the tree, and "empty is acceptable".
The gate on Julia 1.13. Each fix reverted alone on a scratch copy to show
a test goes red. What to probe in particular:

- **The slack of 4 ulps** in `_shaped_steps`: spans where the clock is
  large and the distance small, a proposal that divides the span exactly,
  and the count at the floor. A step longer than `h_max` or a span that
  takes one step too many is a finding.
- **The starting state.** It is the infinite proposal and ends at the first
  attempt. The reviser inferred that this equals ending at the first
  accepted step. Probe a first attempt rejected twice, one forced at the
  floor, and a checkpoint taken before the first step.
- **The forced acceptance** with a nonfinite trial, which must throw
  `NonfiniteState`, and with a `t*` inside the forced step.
- **Replay** from checkpoints taken at awkward places: boundary zero, a
  frame whose first step was bounded, a frame that filed `StepFloor`.
- **The principle sweeps.** No backend reads `h_min`. No domain rate is a
  framework default in the new code. Every site that read `propose` or
  assumed `nothing` handles a proposing token.
- **The docs** against `spec_rules.md` and `log_rules.md`: D-460 to D-462,
  the five annotations, §10.2's new paragraphs, the glossary's "floor".
- **`_stalled`** now refuses only a proposal that is not a number, and its
  name no longer says so.
- **The latch.** `floor_reported` resets at a frame's top, so the bare
  `integrate!` primitive reports once between frames.

Survivors the reviewer may accept: `init!`'s `reset_stepper!` moved after
boundary zero, which is equivalent (ruling 6).

## The review's record

To be filled after the review.

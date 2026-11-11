# Brief: increment 91, the three lattices

One docs commit, one commit of this brief with the patch and the notes, one
code commit applied from the prototype, one commit of the vocabulary sweep,
one cold review and a fix commit if the review needs one. Drafted on
2026-11-11 at c22d79d and landed after the docs commit 35a152c, which
touches nothing under `src/` or `test/`, so every line range below reads
from `git show c22d79d:file`. The prototype is the implementation, built by
two high-tier agents in turn on one scratch worktree detached at c22d79d:
the first wrote the docs and the loop and stopped at its context limit, the
second wrote the remaining tests, the bookkeeping and the measurements. The
patch is `prototype_increment_91.patch` beside this brief, the worktree's
diff from c22d79d. The user was away overnight. They ruled the fixed step's
split before leaving; every other ruling is the coordinator's and is in
`notes_increment_91.md`, open to reversal.

Design and code are peers, neither subservient. If a shape below proves
wrong at the keyboard, stop and report rather than deviate silently.

## What is settled

The second of the five increments of `roadmap_variable_step.md`, under the
`pending.md` bullet "Variable-step integration". The roadmap's settled
bullets "Independent lattices", "The step lands on due instants", "Every
accepted sub-step ends in a boundary", "The frame top keeps the drain" and
"Freshness" land here in the spec and the log, docs commit first.

- **A due instant inside a step splits the step** (D-444, the user's
  ruling of 2026-11-11). A fixed step `h` divides `Δt_frame` and nothing
  else. Step points are counted from the frame top. It supersedes D-443's
  fourth bullet, which had `h` divide `Δt_base`, and corrects the roadmap's
  "Fixed-step divisibility" bullet. Rejected with their reasons in D-444:
  D-443 as ratified, and a rule on every component's period and offset.
- **Three lattices in no required ratio, and every step end a boundary**
  (D-445). Each instant is computed from its own index, coincidence is
  decided on the exact periods, and the clock is written once per boundary.
  A base tick at which nothing is due is no boundary. The frame top alone
  keeps the drain, the control read, the pacer's deadline and the trace's
  ordinal. `Δt_base` gets a range check of its own.
- **Localization runs per step** (D-446). The tolerance is
  `localization_tol · Δt_frame`, the budget counts across the frame's
  steps, and the remainder step targets the end of its own step.
- **A first stage over a fresh table runs the flow alone** (D-447).
- **Annotations.** D-019, D-133, D-290 and D-443 superseded in part;
  D-081, D-082, D-147 and D-347 amended. `check_rows` reports 444 to 447 as
  newly cited and drops no row, so the baseline stands.
- **The two transitional refusals are gone**, `(:h, :subcycling)` and
  `(:Δt_base, :not_frame_multiple)`, from §9.2, Appendix C and the
  constructor. So is the refusal of an `h` that does not divide `Δt_base`.

## The shape built

- `src/deployment.jl`:
  - a section "the lattices" before `bind_schedule` (194): `struct Lattice`
    with the step as a `Float64`, the exact `unit` (the gcd of `h` and
    `Δt_base`, or `h` with no schedule rows), the frame, the base tick and
    the step as whole units, and `max_frame`, the last frame whose
    positions fit an `Int`;
  - `bind_schedule`, 194 to the section header at 314: rewritten strict
    under D-229. `Δt_frame`, `h` and `Δt_base` are each a premise of their
    own, the one relation left is `h` dividing `Δt_frame`, and the anchor
    loop reads `Δt_base` alone. It returns the lattice;
  - `Deployment`, 446–516: the field `frames_per_tick` becomes
    `lattice::Lattice`, outside `==` and `hash` (518–526) as `grid` is.
- `src/frame.jl`, all 266 lines: rewritten. `frame!` refuses a frame past
  `max_frame` before its `try` and reads the top hook's report.
  `_frame_steps!` carries the frame from boundary to boundary in whole
  units. `_localized_step!` is the localization loop over one step.
  `_crossing` and `_trial!` change in comments only.
- `src/model.jl`:
  - `Model`, 91: a sixth field, `fresh::Bool`;
  - the grid block, 444–471: `_grid_time` unchanged, `_tick_time`,
    `_step_time`, `_next_due`, and the `_frames_fit`, `_frames_to` and
    `_frame_at` methods that take a model or a deployment;
  - `evaluate!`, 481: the model's method runs the `x_deriv` block alone
    when `fresh` is set, and clears it;
  - the boundary routines, 508–574: one `run_boundary!(model, due)` with
    `run_ticks!`, `due` an index, `nothing` or `ESTABLISH`. `boundary!`,
    `offtick_boundary!` and `boundary_zero!` are one-line wrappers, and
    `_settle!` is gone;
  - the seam's framework side, 663–706: `integrate_step!` arms and disarms
    the flag, and `_check_finite!` and `_nonfinite` take the frame index.
- `src/sim.jl`: `LoopHooks` (1985) gains `first_frame`; `frame_top!` (2010)
  returns whether the drain wrote or the frame is the advance's first;
  `drain!` (2625) returns a `Bool`; `_t_bound` (405), `_t_end_frame` (421),
  `replay!`'s `to_time` (1377) and `step!`'s two doors (2214, 2225) ask the
  model; `step!`'s `frames` door refuses a count past `max_frame`.
- `src/dataplane.jl` 489: `_drain!` returns whether it wrote.
- `src/diagnostics.jl`: the `:subcycling` and `:not_frame_multiple` arms
  (1420–1427) go; `ArgumentInvalid` (2268) gains `related`, and an arm for
  `frame!`'s `k`; the range texts of `t0`, `t_end`, `frames` and `t_plus`
  name the lattices' last frame.
- Tests: `test/test_lattices.jl`, new, 60 assertions in ten testsets;
  `test_stepper.jl`, `test_discrete.jl`, `test_diagnostics.jl`,
  `test_failures.jl`, `test_localization.jl`, `imports.jl`,
  `RedstoneTests.jl`.
- Docs: §2 intro, §2.1 and §2.2 rewritten, §2.3, §2.4, §3.2, §5.3, §9.2,
  §10.1 to §10.7, §12.3, §12.4, §12.6, §12.7, §13.4, §13.5, §14, Appendices
  B, C and D; D-444 to D-447; the roadmap's bullet.

## Measurements

- **Bit-identity.** Sixteen runs against a `git archive` of c22d79d:
  feedback under RK4 and Heun, `MultiRate` at two base ticks, the localized
  `Bouncer` under both backends, two sampled loops, `Sawtooth` with a
  stamper, a boundary-detected trigger, device staging, the replay of that
  trace, pokes between `step!` calls, a localized model with ticks, a
  mid-run overlay and a `Dual` run. The frame index, the clock's bits,
  `xbuf` and `repr(logged(sim))` are identical in all sixteen, re-run
  after the last source edit.
- **Allocations.** A subcycled frame of four steps and a split frame, at
  `Float64` and `LinearizeDual`: 0 B. The five phase bodies: 0 B each.
  `_next_due` over three schedule rows: 0 B, 4.2 ns.
- **Compile latency.** The first `step!` in a fresh process, three runs:
  0.212, 0.216 and 0.213 s at c22d79d, 0.226, 0.231 and 0.234 s in the
  worktree. The first frame costs about 17 ms more to compile. The second
  `step!` takes 4.8 to 5.2 µs at the tip and 4.4 to 4.7 µs in the worktree.
- **Gate.** The full gate under the sandbox flags, in the worktree:
  9642 of 9642 in 9m07s, on Julia 1.13.3.
- **Examples.** `Longitudinal` 77 of 77. **Documenter.** Clean, doctests
  included. **Battery.** Green at the docs commit.

## Readings the prototype took

The user ruled reading 1. The coordinator ruled the rest overnight, and
`notes_increment_91.md` gives each reason.

1. **The split, with step points counted from the frame top.** After a
   split the next step runs to the next step point, so with a due instant 7
   units into a 5-unit step the pieces are 5, 2, 3, 5, 5.
2. **The lattice lives on the `Deployment`, outside `==` and `hash`.** Two
   exact periods that round to one `Float64` compare equal.
3. **No next-due cache.** The roadmap says "cached as a next-due index".
   The loop recomputes it, one `mod` per schedule row, at each frame's
   start and after each due boundary.
4. **`frame!` refuses a frame past the lattice's `Int` range**, and the
   doors refuse a bound or a count past it. An unbounded `run!` ends on
   `frame!`'s refusal as a loop error, lifecycle `:stopped`, the model
   `:consistent`.
5. **Freshness at a frame top comes from the hooks' report alone.** A hook
   that reports nothing counts as a write, and so does the first frame of
   each advance.
6. **`NonfiniteState.boundary` comes from the loop's frame index.**
7. **The cursor's phase after a boundary at which nothing is due is
   `:round`**, where the tip left `:ticks`. Two pins in `test_failures.jl`
   moved. The alternative forces `:ticks` at such a frame top.
8. **Two step-length rules stay.** A model without localized events
   integrates by the exact length of the piece, one with them by the float
   distance to the step's end, both as at the tip.
9. **A `Model` at a `Dual` takes the `Float64` model's steps**, since the
   split follows the schedule.
10. **A `ChatteringBudget` raised in a frame with sub-steps rides the next
    frame's first step end**, by the existing rule that the delta rides
    the first publication after the fold.
11. **The Rejected lists of D-445, D-446 and D-447 are reconstructed** from
    the contrasts the roadmap's sentences draw. The user confirms them.

## What the tests pin, by property

All in `test/test_lattices.jl` unless named.

- **The roadmap's lattice** (§10.5, D-444, D-445): a 20 ms frame over a
  100 µs base, periods 0.1 s and 0.1001 s, `RK4()`, 5005 frames. 6000
  steps, 995 split frames, the per-frame count against an oracle on the
  rationals, each tick's instant bitwise, one boundary at the coincidence.
  A loop that never splits turns it red, 8 of 14.
- **A schedule on the step points takes equal steps** (§2.2): 40 steps of
  `1//200` over 10 frames.
- **A split's pieces are exact** (§10.5): 7, 3, 4 and 6 hundredths, the
  tick at `t₀ + 7·Δt_base`, the `Dual` model the same lengths.
- **A step shorter than the frame subcycles** (§2.2, §10.2): bitwise the
  same model at `Δt_frame = h` on 200 shared frame tops, and within 1e-9
  of the analytic solution. A bare step by `Δt_frame` turns it red.
- **A tick inside a frame samples its frame-top drain's inputs** (§2.2,
  §11.4). A due boundary given the empty due set turns it red.
- **Every step end publishes under its frame's index and the next
  ordinal** (§11.2, §12.3). Publishing at the frame top alone turns it
  red.
- **A first stage over a fresh table is the sweep's, bitwise, and the
  drain's report arms it** (§10.3, D-447). Four mutants: the flag never
  cleared, no first-frame rule, an unreported harness drain, a replay
  drain that reports nothing.
- **A localized event in a later step, the budget across steps** (§10.4,
  D-446). A budget counted per step turns it red.
- **A stop request at a step end ends the run there** (§13.5), and
  `checkpoint` is refused as `CheckpointMidFrame`. Abandoning only at the
  frame top turns it red.
- **A frame whose positions leave `Int` is refused, and an unbounded run
  stops before it** (§10.5, §12.6). Three mutants: no check on `k`, no
  margin, the `frames` door at `typemax`.
- **A fixed step divides the frame, and nothing relates it to the base
  tick** (§9.2, D-444), `test_stepper.jl`. Restoring the old relation
  turns it red.
- **The new messages render** (Appendix C), `test_diagnostics.jl`.

## Bookkeeping

- The docs commit, beside the spec and the log: the roadmap's "Fixed-step
  divisibility" bullet.
- The code commit, beside the patch's code half: `code_map.md`'s entries
  for the six source files and the new test file; `pending.md`, with
  increment 2 landed, the seam protocol next and the `bind_schedule`
  deviation retired; `rules/code_rules.md`'s checkpoint and clock-value
  caveats; `companions/frame_walkthrough.md`.
- The sweep commit: "non-localized" for "boundary-detected" across the
  spec, the companions, the rules, the code map, `src/`, `test/` and the
  docs, with the glossary anchor. The log is not swept (`log_rules.md`
  rule 2).

## Out of scope

- The seam protocol, the trial buffer, the attempt ordinal, the stepper's
  checkpoint field and the discontinuity notice: increment 3.
- Anything adaptive, the descriptor and the inspector's pin: increment 4.
- A per-backend step resolution: `bind_schedule` still reads the token's
  `h`.
- A report of the steps per frame in `show(deployment)`, proposed to the
  user and left out.
- The checkpoint's rest condition, which stays frame tops only.

## The cold review

An independent high-tier agent over the whole increment at the sweep
commit's tip: the full gate on the floor `Project.toml` declares; the
Documenter build; each new testset's source reverted alone on a scratch
copy; the bit-identity probe re-run against c22d79d outside the tree, on
cases of its own choosing beside the sixteen; D-444 to D-447 against
`log_rules.md`, and the eight annotations; §2.1, §2.2 and §10.5's new
subsection against `spec_rules.md`; the freshness paths, looking for a
write to the table that the flag does not see; the split's integer
arithmetic at its edges; a grep for every surviving `frames_per_tick`,
`:subcycling`, `:not_frame_multiple` and "boundary-detected" outside the
log and the records. "Empty is acceptable."

## The review's record

The arc on top of c22d79d: 35a152c (docs), 5828890 (this brief, the notes
and the patch), c3e7fae (code), e73c683 (the sweep, with D-448), 8aa7f9a
(the review's fixes). Nothing is pushed.

**The sweep.** A third high-tier agent classified 97 occurrences and
applied 94. The coordinator kept the symbol `:boundary` of the `Events`
register, an API value; annotated D-122, D-179 and D-365; and corrected the
capture guard of `companions/event_visibility_walkthrough.md` to the `Bool`
form, since a rename alone left a false comment over a guard that
localizes. Rulings 24 to 27 of the notes.

**The review**, at e73c683. An independent high-tier agent found no defect
in the split's integer arithmetic, the clock writes or localization per
step. Its own bit-identity probe matched c22d79d on 17 records, its split
oracle on 10 configurations, and its gate passed 9642 of 9642 in 9m11s on
Julia 1.13.3, with the Documenter build clean and the examples 77 of 77. Of
its 16 mutants 11 died. Ten findings, each ruled in the notes (28 to 38)
and fixed in 8aa7f9a by a fixer agent:

- **F1, a `settled!` hook that writes the model.** A user hook applying a
  root input at a `t*` boundary gave a trajectory that differs from
  c22d79d's, since the remainder's first stage now reads the table the
  boundary left. The contract is stated in the docstrings, §10.3, Appendix
  B and D-447; it is not enforced.
- **F2, F3, F9, stale text.** `NonfiniteState` and `CheckpointMidFrame`
  said "frame top" and "`t*` stop", two docstrings said `t₀ + k·h`, and
  §10.5 named the wrong `Int` bound.
- **F4, log labels.** D-081's and D-347's annotations read "superseded in
  part"; D-444's first Rejected item is marked a superseded position.
- **F5, three missing tests**, for three surviving mutants: step points
  counted from the frame top, which is the user's ruling and was unpinned
  (1 failure under its mutant); a due instant on a step point written from
  its base-tick index (2); `NonfiniteState.boundary` under subcycling (1).
- **F6, the clock's resolution.** A base tick of 1e-17 s gave distinct
  boundaries with one clock value. §10.5 states the limit and D-445's
  coincidence sentence is corrected; nothing polices it.
- **F7, an unindexable lattice.** Two periods a hair apart raised a raw
  `OverflowError`. The lattice is computed in `Int128` and refused as a
  collected `DeploymentInvalid` on `Δt_base`.
- **F8, "step point"** gets a glossary entry.
- **F10, `pending.md`** points at the notes' open questions.

**Survivors accepted.** The lattice compared in `==`, which only two exact
periods rounding to one `Float64` could tell apart; and the fresh flag's
reset in `frame!`'s catch, which both backends make unreachable by clearing
the flag in their first evaluation.

**Left open, in the notes.** Three sites that can still raise a raw
`OverflowError` on periods of extreme magnitude; whether the hooks'
contract is enforced; whether a lattice finer than the clock is refused;
and the open points of the prototype and the sweep.

**The delta**, at 8aa7f9a. The reviewer, resumed, found every fix
resolved but one sentence. Its three earlier mutants now die on the new
tests, three more of its own on the lattice's constructor and its message
die too, its bit-identity probe still matches c22d79d but for the reworded
`NonfiniteState` message, and its gate passed 9661 of 9661 in 9m09s. The
sentence added for F6 said two instants closer than the clock's resolution
take one clock value "in order". They can take two, out of order by an ulp,
and the localized path then integrates a step of negative length one ulp
long. §10.5 and D-445 are corrected in the commit of this record, and the
choice between refusing such a lattice and clamping the clock is the notes'
first open point (ruling 39).

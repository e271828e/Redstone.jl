# Brief: increment 93, the seam protocol

One docs commit, one commit of this brief with the patch, one code commit
applied from the prototype, one cold review and a fix commit if the review
needs one. Drafted on 2026-11-11 at ddca615 and landed after the docs
commit 3a1269b, which touches nothing under `src/` or `test/`, so every
line range below reads from `git show ddca615:file`. The prototype is the
implementation. One high-tier agent built it on a scratch worktree detached
at 8a6549f. Three commits landed under it: 79e7c66, the CI fix that took
D-451, and 9604747 and ddca615, a `pending.md` bullet and its amendment. The
coordinator rebased the worktree on each and applied the user's rulings of
the same day there:
readings 6, 7 and 8 below. The patch is `prototype_increment_93.patch`
beside this brief, the worktree's diff from ddca615: 20 files, 7 under
`design/` and 13 under `src/` and `test/`, no file new. The user was
present and ratified every reading below on 2026-11-11.

Design and code are peers, neither subservient. If a shape below proves
wrong at the keyboard, stop and report rather than deviate silently.

## What is settled

The roadmap's increment 3, under the `pending.md` bullet "Variable-step
integration", sub-bullet "Next: the seam protocol". The roadmap's settled
bullets "The seam protocol", "The discontinuity notice", "Freshness" and
"The checkpoint" land here in the spec and the log, docs commit first, with
the changes the user ruled.

- **The seam is a protocol, and the `Model` shapes every step** (D-452).
  The backend answers `propose`, `attempt!`, `discontinuity!`, `startpoint`,
  `dense!` and the checkpoint pair. The `Model` owns the step's length, its
  attempts, the commit, the clock and the notice. Rejected with their
  reasons in D-452: the attempt writing the state buffer, the backend
  clamping its own proposal, the notice at any reported write, a
  three-valued hook, `attempt!` returning a proposal, defaults for the
  checkpoint pair, a restore as a discontinuity, a held notice, and a check
  of every trial.
- **The roadmap's two open decisions for this increment are closed.** The
  trial buffer is `exec.xnext`. A nonfinite check reads an accepted trial
  before the commit and never a rejected one.
- **Annotations.** D-017, D-157 and D-274 annotated. D-447 superseded in
  part: its first bullet's clause on the first frame of an advance and its
  third bullet fall. `check_rows` reports 444 to 452 as newly cited and
  drops no row.
- **The invariant.** Every trajectory from before the increment is
  bit-identical. RK4 and Heun propose nothing and always accept.

## The shape built

- `src/stepper.jl`, rewritten:
  - the header, 1–24, and the generics, 26–61: `propose`, `attempt!` and the
    checkpoint pair are bare generics with no default; `discontinuity!`
    defaults to a no-op; `restore_stepper!` takes the carried value where it
    took the whole `ModelState`;
  - `RK4Stepper`, 63–98, and `HeunStepper`, 100–128: `integrate!` becomes
    `attempt!`, whose final combination writes `exec.xnext` and which
    returns `true`. Each defines `propose` as `nothing` and a checkpoint
    pair that carries `nothing`. The arithmetic is unchanged.
- `src/model.jl`:
  - the hooks' contract, 163–241: `frame_top!` returns a `Bool`, whether it
    wrote a value, and `frame_top!(::NoHooks)` returns `false`;
  - `overlay!`'s plan method, 419, raises the notice before its settling;
  - `run_boundary!`, 575–593, raises the notice where a handler fired or the
    due set is not empty, and `event_phase!`, 649–710, returns whether a
    handler fired;
  - the seam's framework side, 712–780. `integrate!(model, h)` is one step
    of attempts toward `t + h`. `integrate_step!(model, h, t_limit, k,
    fresh)` is the attempt loop and returns the accepted length. On an
    acceptance it writes the clock, runs `_check_finite!` over `xnext` and
    copies it into `xbuf`. On a rejection it puts `xbuf` back from
    `startpoint` and the clock back, clears `fresh`, and takes the next
    length from `propose` through `_clamped`. `_clamped` and `_step_end` are
    new. `_check_finite!` and `_nonfinite` take the buffer they read;
  - `_wrap_step`, 906, copies the cursor's attempt, and `checkpoint`,
    973–1009, stores `checkpoint_stepper(exec.stepper)`.
- `src/frame.jl`:
  - `frame!`, 63, is `run_frame!(model, k, hooks, false)`. `run_frame!`
    holds the body and takes `continued`, the caller's word that nothing
    wrote the model since the last frame's top boundary. It raises the
    notice when the hook wrote a value, and the frame's first step is fresh
    when `continued && !wrote`;
  - `_frame_steps!`, 84–137, asks `propose` before each step. Under
    `nothing` it takes today's equal division unchanged. Under a proposal it
    clamps the length, and a step ends the span when it reaches the span's
    end;
  - `_localized_step!`, 139–269, takes `t_limit` and returns the step's end.
    A rejection may shorten the first segment, and a remainder never passes
    its step's end. The copy of `xbuf` into `xnext` before the trials is
    gone, since the committed trial is `xₙ₊₁`.
- `src/sim.jl`: `LoopHooks`, 1986–1994, loses `first_frame`, and its four
  construction sites, 846, 970, 997 and 2090, follow. `frame_top!`,
  2013–2022, returns the drain's report. `_advance!`, 2112, calls
  `run_frame!` with `advanced > 0`.
- `src/executor.jl`, 20–29: `ExecutionCursor` gains `attempt`, which
  `_phase!` clears.
- `src/diagnostics.jl`, 216–260: `CursorFrame` gains a fifth field,
  `attempt`, with a four-argument constructor that spells 0. `_phase_text`
  appends " in attempt n" past the first.
- `src/checkpoint.jl`, 26–140: `ModelState` gains `stepper::Any` after
  `prior`, restored through `restore_stepper!` and shared by `_detach`.
- Tests: `test_stepper.jl` gains the stub `Scheduled` and
  `test_seam_protocol`, seven testsets. `test_lattices.jl`'s `Recorder`
  moves to the protocol, `FreshHooks` goes, and the freshness testset
  continues its frames through `run_frame!`. `test_failures.jl`, five
  `CursorFrame` pins gain attempt 1, at 237, 407, 725, 836 and 848.
  `test_trace.jl`, two positional `ModelState` constructions, at 1652 and
  1674. Three test hooks return `false` where they returned `nothing`.
  `imports.jl`.
- Docs: §10.2's first and fourth clauses and two new parts, "The step
  protocol" and "The discontinuity notice"; §10.3's sentence on the frame
  top; §12.6; §13.4; Appendix B's `frame!` entry; Appendix D, where
  "attempt" and "discontinuity notice" enter; D-452 and the four
  annotations; the roadmap.

## Measurements

- **Bit-identity.** Increment 92's probe, re-run by the coordinator against
  a `git archive` of 79e7c66 after the last source edit, the two later
  commits changing no source: 23 cases,
  identical in frame index, clock bits, `xbuf` bits, `Dual` partials and
  `repr(logged(sim))`. They cover feedback under RK4 and Heun, `MultiRate`,
  the localized `Bouncer`, device staging and its replay, a mid-run
  overlay, two `Dual` runs, runs at a nonzero origin and four subcycled
  runs.
- **Allocations.** The prototype's probe, re-run after the rework: 27
  measurements, all 0 B and identical to the run before the increment. They
  are `sweep_1`, `sweep_2`, `rhs`, `evaluate!`, `integrate!` and a `frame!`
  of four steps, each at `Float64` and `LinearizeDual` under RK4 and Heun,
  a localized `Bouncer` frame under both, and `integrate!(sim)`. The new
  testset measures a `frame!` with scheduled rejections at 0 B.
- **Timing.** The least of 20 000 samples of a four-step `frame!` on the
  feedback model reads 166 or 208 ns under RK4 and 83 ns under Heun in both
  trees. The readings sit one tick of the 41.7 ns timer apart, and which
  tree reads 208 changed between two runs, so the extra copy per accepted
  step is below what this probe resolves.
- **Gate.** The full gate under the sandbox flags, in the worktree after
  the rework: 9789 of 9789 in 9m48s on Julia 1.13.3. The cold reviewer
  runs it again.
- **Examples.** `Longitudinal` 77 of 77. **Battery.** Green at the
  worktree's tip.
  **Documenter and compile latency.** Not measured; the reviewer's.

## Readings the prototype took

The user ratified all of these on 2026-11-11. Readings 6, 7 and 8 are the
user's rulings against the prototype's first shape, applied by the
coordinator.

1. **The trial buffer is `exec.xnext`, and it does not shield the state
   buffer.** The phase bodies close over `xbuf`, so stages write it and a
   rejection puts it back from `startpoint` either way. The trial buffer
   gives one commit point: the nonfinite check reads the step's end before
   the state buffer holds it, and the localization loop's `xₙ₊₁` is the
   trial. It costs one copy of the state per accepted bare step.
2. **The `Model` checks an accepted trial, before the commit.** A rejected
   trial is never read. With no `h_min`, every accepted nonfinite trial
   throws `NonfiniteState` as before. After that throw `xbuf` holds the last
   stage point, where it held the nonfinite end; the model is
   `:inconsistent` and no test reads the state there.
3. **`propose` returns `nothing` for a fixed-step backend.** The branch on
   it compiles away by the stepper's type, so the equal division of D-449
   keeps its arithmetic and its clocks.
4. **The proposing path is minimal**, since only the test stub reaches it.
   A proposal is clamped to `h_max` and to the span's end. A step that
   reaches the end takes the float distance and the indexed clock. An
   interior end is the clock plus the accepted length. The spec states the
   clamp and that clock and nothing more. Two things are left to increment
   4 and named on the `pending.md` bullet: nothing bounds a step's attempts,
   and an accumulated end can round one ulp past the span's end.
5. **The notice sites.** `run_boundary!` raises it where a handler fired or
   the due set is not empty, which covers every frame boundary, every `t*`
   and boundary zero. `overlay!` raises it. A frame top raises it when the
   hook wrote a value. `restore!` raises none: the roadmap's "a restore
   counts as a discontinuity" holds for the derivative buffer alone, which
   the sweep at an advance's first frame covers. A notice reaches the
   backend as its boundary settles, so a checkpoint never carries one.
6. **The notice and freshness are two questions with two owners.** The
   hook returns whether it wrote a value, a `Bool`. The caller of the frame
   says whether it continues the last one, as an argument to `run_frame!`.
   The prototype had the hook return three states, the third for a write it
   could not name, because a notice at the first frame of an advance would
   part `step!` from `run!` (§12.6). The user objected that a hook either
   wrote or did not, and that the return was no longer one concrete type.
   `first_frame` leaves `LoopHooks`, and `frame!` never continues. D-447 is
   superseded in part.
7. **`attempt!` returns its verdict alone.** The `Model` reads `propose`
   before every step and after every rejection. The roadmap had `attempt!`
   return the next proposal too, a second source for one fact.
8. **Neither `propose` nor the checkpoint pair has a default.** A backend
   that forgot the pair would lose its state at a restore with no error.
9. **`ModelState.stepper` is typed `Any`**, the immutable value the pair
   reads, `nothing` for RK4 and Heun. A typed field would fix increment 4's
   controller memory now. No checkpoint from before the field exists on
   disk, since persistence is deferred.
10. **The cursor's attempt** counts from 1 inside `:integrate` and is 0
    elsewhere. A rendered frame names it only past the first, so no
    rendered diagnostic changes. A frame's payload does: integration frames
    carry attempt 1.
11. **`integrate!(model, h)`, `apply!` and the stepping primitives.** The
    bare `integrate!` is one step of attempts toward `t + h`. The internal
    `apply!` and the primitives raise no notice. Whoever steps a model with
    them writes their own loop.
12. **A retry is never fresh.** The rejected stages left their values in the
    table. The property tested is that the published tables equal the
    unrejected run's, bit for bit.
13. **`companions/frame_walkthrough.md` follows the code**, since it quoted
    the removed `integrate!(::RK4Stepper)`.
14. **The entry is D-452.** The CI fix 79e7c66 landed during the increment
    and took D-451.
15. **The roadmap is amended** for readings 6, 7 and 8, loses the trial
    buffer from its open decisions, and names the two items owed to
    increment 4.

## What the tests pin, by property

In `test/test_stepper.jl`'s `test_seam_protocol` unless named. F counts
failures and E errors under the mutant, each run by the coordinator on the
final worktree beside a green control.

- **A rejected attempt leaves no trace** (§10.2, §10.3): the retry finds
  the clock and the state its rejected attempt found, and the run's
  snapshots are the unrejected run's, a localized model included. No state
  put back: 8F. No clock put back: 3F. A fresh retry: 2F. A remainder's
  retry not limited to its step's end: 2F.
- **A proposal is clamped, a rejection's proposal is the retry's, and a
  shortened step ends at the clock plus its length** (§10.2, §10.5), on
  dyadic periods with exact clocks. No `h_max` clamp: 3F. The span's end
  not recomputed: 4F, 1E. A shortened end written as the offered end: 5F.
  The localized step's end not moved: 2F. The retry at the old length: 6F.
- **The notice sites** (§10.2, §12.6): the same list under one advance and
  under single-frame steps, one more at `overlay!`, none at `restore!`. No
  handler notice: 1F. No tick notice: 4F. No drain notice: 3F. `overlay!`
  silent: 2F. A restore that notifies: 1F.
- **A checkpoint carries the stepper's state, and a restore followed by a
  step is the unrestored run** (§12.6, D-274), through the simulation, the
  bare model and a replay. `restore_stepper!` dropped: 5F. The checkpoint
  storing `nothing`: 2F, 2E.
- **A cursor frame names the attempt** (§13.4). The attempt dropped from
  the frame: 2F. The attempt never written: 2F. Rendered from attempt 1:
  1F, in `test_failures.jl`'s rendering testset.
- **A rejected trial is discarded unread** (§13.4, D-157). Every trial
  checked: 1E.
- **The attempt loop allocates nothing, rejections included** (§9.8).
- **A frame top is fresh when the frame continues the last one and the
  hook wrote nothing** (§10.3, D-452), `test_lattices.jl`. Freshness
  ignoring `continued`: 2F. Ignoring the hook's write: 2F. The advance
  always continued: 2F. Never continued: 2F.

One mutant survives the protocol tests alone: the commit's copy of the
trial into the state buffer dropped. Those tests compare a mutated run with
a mutated run. It dies under the whole stepper file, 2F.

## Bookkeeping

- The docs commit: `spec.md`, `log.md`, `tools/coinage_inventory.md` and
  the roadmap, whose settled bullets take the three rulings and whose open
  decisions lose the trial buffer.
- The code commit, beside the patch's code half: `code_map.md`'s entries
  for the checkpoint, diagnostics, executor, frame, model, sim and stepper
  files, for `test_lattices.jl` and a new one for `test_stepper.jl`;
  `companions/frame_walkthrough.md`; `pending.md`, with the seam protocol
  landed, the first adaptive backend next, and the two items owed to it.

## Out of scope

- The first adaptive backend, `h_min`, the floor and the attempt budget,
  equal division under a proposal, the one step-length rule with the ulp
  edge, and exact periods on the `Deployment`: increment 4, as the
  roadmap's open decisions.
- The inspector: it reads none of the names this increment changes.

## The cold review

An independent high-tier agent over the whole increment at the code
commit's tip: the full gate on the floor `Project.toml` declares; the
Documenter build; each new testset's source reverted alone on a scratch
copy. The two-`Bool` split first, since the coordinator wrote it after the
prototype's own runs: every caller of `frame!` and `run_frame!`, a pause
inside an advance, replay, and `continued` across a stop and a new advance.
A bit-identity probe of its own against 79e7c66 outside the tree. The
return types of `frame_top!`, `attempt!` and `propose` by `@inferred`, and
the step path's allocations at `LinearizeDual`. The proposing path attacked
through a stub of its own, the ulp edge included, to confirm that no
backend in `src/` reaches it. D-452 against `log_rules.md`, and the four
annotations; §10.2's two new parts and §10.3 against `spec_rules.md`. A
grep for every surviving `integrate!(stepper`, `first_frame`, `(true,
nothing)` and three-state wording outside the log and the records. "Empty
is acceptable."

## The review's record

The arc on top of ddca615: 3a1269b (docs), 66c5ba6 (this brief and the
patch), e7dacf9 (code), then the review's fixes. Nothing is pushed.

**The review**, at e7dacf9. An independent high-tier agent ran the gate,
9789 of 9789 in 9m55s on Julia 1.13.3, with the examples 77 of 77, the
Documenter build clean and the battery green. Its own bit-identity probe
matched the base on 22 records under RK4 and Heun, including independent
lattices, a checkpoint with an overlay and a restore, a replay, the bare
`integrate!` and a `Dual` model. `propose`, `attempt!`, `frame_top!` and
`run_frame!` infer concretely, and the step path allocates nothing at
`Float64` and `LinearizeDual`. Compile latency did not move. Its report
lists 27 mutants, 15 dead and 12 alive. One of the dead, a clamp that
ignores the span's end, never terminated and was stopped by the coordinator
at 25 GB.

The user was away and had delegated the findings short of a significant
design question. The coordinator ruled on each, recorded the rulings in
`notes_increment_93.md` beside this brief, and landed the fixes as one
commit:

- **F2, `init!` left the stepper's carried state as the last run left it.**
  A second `init!` under the same condition continued the first run's
  proposal, so a run was no longer a function of its condition (§2.4). The
  `Model` now keeps the carried state as bound, `stepper_bound`, and `init!`
  hands it back before boundary zero. D-452 gains the bullet and two
  rejections, edited in place since the entry is this increment's. Test: a
  second `init!` gives the fresh run's header and snapshots; without the
  line, 3 failures.
- **F12, a model with no continuous state asked its stepper for a
  proposal**, against D-156. The loop reads none there. Without the guard,
  1 failure.
- **F3, the remainder after a `t*` is offered without asking `propose`.**
  §10.2 now says so, and the roadmap's open decision on the notice and the
  proposal names the point for increment 4.
- **F1, a proposal that does not advance the clock never ends its span.**
  Zero, negative and vanishing proposals, every attempt accepted. Left to
  increment 4's floor and named on the `pending.md` bullet and in the
  roadmap. No backend in `src/` proposes.
- **F5, the ulp edge of reading 4 cannot happen.** A proposed length is
  below the float distance to the span's end, so the sum cannot pass it. A
  step can end a sliver short. `pending.md` and the roadmap are reworded.
- **F4, D-452's cost sentence.** The trial buffer costs one copy per
  accepted attempt, and a localized step pays none extra only where its
  trigger is validated. Reading 1's "per accepted bare step" is loose the
  same way.
- **F6, F7, F9, F10 and F11, missing tests.** The span-end clocks were
  pinned on dyadic periods alone, where the float sum is exact; a 3/10 s
  frame now separates them, on the bare and the localized path. An accepted
  trial filled with `Inf` shows the check reads the trial. The bare
  `integrate!` under a rejecting backend, a localized first retry clamped to
  the span's end, and two cursor frames that differ in the attempt alone.
  The coordinator re-ran ten of the reviewer's twelve survivors, each in
  its own process under a time limit where it could loop, and all ten die,
  with 1 to 4 failures. The eleventh is accepted below, and the twelfth was
  two of the ten combined.
- **F8, `frame_top!(::NoHooks)`** is now called by a test, which its
  coverage marker needed.
- **F13 and F14, text.** `remaining` in `frame.jl` held two meanings, and
  the new one is `span_left`. The seam's header counted six functions and
  listed seven. The walkthrough's sentence on a fresh table names the
  continued frame. §10.2's clock sentence says "a proposed step".
- **F15, two questions.** Projection writes the state at every boundary and
  raises no notice, which no text states: a new open decision in the
  roadmap. A hook that returns `nothing` fails as a `TypeError` inside a
  `StepError`: left.

**Two readings above were wrong as written.** Reading 11: `boundary!`,
`offtick_boundary!` and `boundary_zero!` raise the notice where a tick ran
or a handler fired, since they go through `run_boundary!`; only `integrate!`
and `apply!` raise none. Reading 5: a frame boundary raises the notice only
where a tick is due or a handler fired.

**Survivors accepted.** The clock written after the nonfinite check
instead of before it: every backend in the tree leaves the clock at the
step's end, so nothing reads the difference.

**After the fixes.** The coordinator ran the gate in the worktree, 9807 of
9807 in 10m58s, the 18 new assertions included, with the examples 77 of 77
and the battery green. The reviewer checks the delta.

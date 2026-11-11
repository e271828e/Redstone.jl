# Brief: increment 92, the step bound

One docs commit, one commit of this brief with the patch, one code commit
applied from the prototype, one cold review and a fix commit if the review
needs one. Drafted on 2026-11-11 at fd155e6 and landed after the docs
commit 8ba044c, which touches nothing under `src/` or `test/`, so every
line range below reads from `git show fd155e6:file`. The prototype is the
implementation, built by one high-tier agent on a scratch worktree detached
at fd155e6. The patch is `prototype_increment_92.patch` beside this brief,
the worktree's diff from fd155e6: 26 files, 9 under `design/` and 17 under
`src/` and `test/`, no file new. The user was present and ratified every
reading below on 2026-11-11. The coordinator added reading 17 to the
worktree after that ruling, with its tests, before the patch was taken.

Design and code are peers, neither subservient. If a shape below proves
wrong at the keyboard, stop and report rather than deviate silently.

## What is settled

The roadmap's increment 2b, under the `pending.md` bullet "Variable-step
integration", sub-bullet "Next: the step bound". The user ruled it on
2026-11-11. The roadmap's settled bullets "The step bound", "The clock's
resolution" and "The steps per frame" land here in the spec and the log,
docs commit first.

- **`h_max` bounds every step, and a span is taken in equal steps**
  (D-449). The frame tops and the due instants are the mandatory instants.
  A fixed-step method takes a span of length `g` in `n = ⌈g / h_max⌉` steps
  of `g / n`. `RK4()` and `Heun()` carry no step. Step points go, and with
  them the third lattice. Rejected with their reasons in D-449: `RK4(h)` as
  built, a `Δt_step` lattice, full steps and a remainder, a warning at a
  split.
- **A run whose clock cannot order its boundaries is refused** (D-450). The
  refusal gives a last frame beside the lattices' `max_frame`, and every
  door refuses past the lesser. `t*` boundaries are not covered. Rejected:
  clamping each clock to the last one.
- **`show(deployment)` states the steps per frame** over one hyperperiod.
  No warning is raised at a split.
- **Annotations.** D-442, D-443 and D-444 superseded in part by D-449;
  D-445 superseded in part by D-449 and D-450; D-447 annotated with the
  rejected enforcement of the hooks' contract. `check_rows` reports 449 and
  450 as newly cited and drops no row.
- **The two rejections the log owed** from the rulings on increment 91: the
  cap at the range's end is in D-450's Rejected list, and the enforced hook
  contract is D-447's annotation.

## The shape built

- `src/deployment.jl`:
  - the lattices section, 175–220: `Lattice` loses `h` and `step` and gains
    `bound::Rational{Int}`, the exact ratio `h_max / unit`, and
    `reach::Float64`, the clock bound `2^50·δ` in seconds. The unit is
    `gcd(Δt_frame, Δt_base)`, or `Δt_frame` with no schedule rows.
    `_lattice` returns `:Δt_base` or `:h_max` where a product leaves `Int`;
  - `bind_schedule`, 231–350: takes `h_max` where it took the algorithm.
    The bound goes through `_exact` and `_positive_finite` and resolves to
    `min(h_max, Δt_frame)`, an absent bound to `Δt_frame`. The
    `:not_harmonic` relation, 290–297, is gone;
  - the tokens, 352–417: `struct RK4 <: AbstractAlgorithm end` and `Heun`
    alike, printed `RK4()`;
  - `Deployment`, 421–565: the keyword `h_max = nothing` and the field
    `h_max::Float64`, resolved, compared in `==` and `hash`.
- `src/frame.jl`: the header and `frame!`'s docstring, 1–59; `frame!`,
  60–79, refuses `k` past `_last_frame(model)`; `_frame_steps!`, 81–126, is
  two nested loops. The outer one runs over mandatory instants. The inner
  one takes `cld(units·q, p)` steps of `Float64((units·unit)/steps)`, the
  bound being `p/q`. An interior step end's clock is the span's start clock
  plus `i` times that step. `_localized_step!` is unchanged.
- `src/model.jl`: `_step_time` goes, 478–483; `_last_frame(deployment, t₀)`
  enters after `_frame_at`, 519, a pure function; `_frames_fit`, 512 and
  524, reads it and becomes `_frames_to`'s mirror, which covers `t_end`,
  `t_plus` and replay's `to_time`; `_check_origin`, 340, asks
  `_last_frame` for a first frame directly.
- `src/sim.jl`: `step!`'s `frames` door, 2227, reads `_last_frame`; the
  sugar constructor's signature, 307, gains `h_max`.
- `src/show.jl`, 252–271: `h_max` among the parameters,
  `STEPS_MAXFRAMES = 10_000`, and `_steps_line`, the second line of the
  plain-text form.
- `src/diagnostics.jl`: arms for the `h_max` refusals, 1398–1427; the
  `:not_harmonic` arm, the parameter `:h` and the `:RK4`/`:Heun` `:inexact`
  arm, 2282, removed; the range texts of `frame!`'s `k`, `t0`, `t_end`,
  `frames` and `t_plus`, 2366–2423, read "the last frame the run may take";
  the mismatch text, 2496–2512, counts seven parameters.
- `src/checkpoint.jl`, 169: the walk names `:h_max`. `src/stepper.jl`:
  comments.
- Tests: `test_lattices.jl`, `test_stepper.jl`, `test_show.jl`,
  `test_discrete.jl`, `test_trace.jl`, `test_failures.jl`,
  `test_diagnostics.jl`, `test_lifecycle.jl`, `imports.jl`.
- Docs: §2.1 rewritten; §2.2, §2.4, §9.2, §10.1, §10.2, §10.4, §10.6,
  §11.5, §12.7, §14.5; §10.5's intro and its subsection, renamed "Spans,
  steps and the clock"; Appendices B, C and D, where "step point" leaves
  the glossary and "mandatory instant" enters; D-449 and D-450; the
  roadmap's clock bullet and 2b item.

## Measurements

- **Bit-identity.** A probe against a `git archive` of fd155e6, re-run
  after the last source edit. The sixteen invariant cases are identical in
  frame index, clock bits, `xbuf` bits, `Dual` partials and
  `repr(logged(sim))`: feedback under RK4 and Heun, `MultiRate` at two base
  ticks and with the base off the frame, the localized `Bouncer` under both
  backends, a sampled loop with pokes, the roadmap's lattice over 600
  frames, `Sawtooth` with a stamper, a non-localized trigger, device
  staging and its replay, a localized model with ticks, a mid-run overlay,
  two `Dual` runs and two runs at a nonzero origin. Three subcycled runs
  with no due instant inside a step are identical too, the interior clock
  included. One run differs, as the invariant allows: a bound finer than
  the frame with a due instant inside it.
- **Allocations.** `frame!` on a split frame and on a frame of 4 to 5
  equal steps, at `Float64` and `LinearizeDual`: 0 B in all four.
  `_last_frame`: 0 B, 0.95 ns.
- **Compile latency.** The first `step!` in a fresh process, three runs:
  0.235, 0.228 and 0.240 s at fd155e6; 0.264, 0.244 and 0.254 s in the
  worktree. About 20 ms more.
- **Gate.** The full gate under the sandbox flags, in the worktree: 9722
  of 9722 in 9m34s on Julia 1.13.3. Five assertions were added after it
  started, one by the prototype and four with reading 17, so the suite
  holds 9727. After the last edit `lattices`, `lifecycle`, `trace` and
  `stepper` pass 1142 of 1142; the cold reviewer runs the gate.
- **Examples.** `Longitudinal` 77 of 77. **Documenter.** Clean.
  **Battery.** Green, re-run by the coordinator at the worktree's tip.

## Readings the prototype took

The user ratified 1 to 16 on 2026-11-11, and 17 when they asked for it.

1. **`h_max` stays out of the unit's gcd.** The lattice stores its exact
   ratio to the unit, and a span's step count is one `cld`. In the gcd, a
   bound that divides nothing would make the unit finer, shortening the
   `Int` range and the clock's reach for no instant the loop compares.
2. **The bound is recorded resolved**, `min(h_max, Δt_frame)`, and an
   absent bound as `Δt_frame`. No bound, a bound at the frame and one above
   it are one trajectory and compare equal. The cost: `show` prints
   `h_max = 0.002` on a deployment that never named one. The alternatives:
   the bound compared as written, where replay refuses over a difference
   that moves nothing; or a bound above the frame refused.
3. **`RK4(h)` and `Heun(h)` are removed with no shim.** `RK4(1//100)` is a
   `MethodError`. `:not_harmonic`, the parameter `:h` and the tokens'
   `:inexact` refusal have no raiser left and leave Appendix C.
4. **`h_max` is validated as `Δt_frame` is**: `:inexact`, `:not_a_quantity`
   and `:range`, collected under D-229.
5. **The last frame is a pure function of the deployment and `t₀`**, read
   at each door and never stored. The roadmap said "computed where `t₀` is
   set". A function needs no reset in `init!` or `restore!`, and costs
   0.95 ns per frame.
6. **The clock bound's constant is `2^50`, where the roadmap had `2^51`.**
   The condition is `|t₀| + 2·(t − t₀) < 2^50·δ`, with `δ` the least gap.
   `2^51` is the first-order threshold exactly, with no room for the
   second-order terms or for the float arithmetic that computes the last
   frame. The cost is half the reach: about 17.8 years at a 1 µs unit from
   `t₀ = 0`. The derivation is D-450's Rationale.
7. **An interior step end's clock is the span's start clock plus `i` times
   the float step.** It reproduces fd155e6's step-point clocks to the bit
   where no due instant falls inside a step. The alternative, the frame top
   plus the float of an exact offset, errs slightly less and loses that.
8. **The `show` line** reads `steps per frame: 4 to 5, over one hyperperiod
   of 7 frames`, and under the cap `… in the first 10000 frames of a
   hyperperiod of 50005`. The roadmap's example led with the bound, "at
   most 5 ms, 4 to 5 steps per frame"; here the bound is `h_max` on the
   parameters line above.
9. **D-443 and D-445 read "superseded in part"**, since each Position
   changes, by the standard of increment 91's ruling 30.
10. **The two owed rejections**: the cap in D-450's Rejected list, the
    enforced contract as an annotation on D-447, since `log_rules.md` rule
    1 forbids adding to a landed entry's list.
11. **Increment 91's 921-frame overflow test cannot run.** At its `1e-18`
    base the clock refusal stops it at `init!`. A period 1000 units short
    of `typemax(Int)` replaces it, where `max_frame = 1000` binds.
12. **Two pins of `test_lifecycle.jl` moved.** An origin of `1e33` under a
    0.1 s frame is now refused, so the pin reads `1e14`, with `1e15`
    refused. `frames = typemax(Int) − frame` became
    `_last_frame(sim.model) − frame`.
13. **Ruling 31's pin, step points counted from the frame top, is
    retired**, replaced by the cut span's pieces.
14. **The spec writes `δ` for the least gap and `g` for a span's length.**
    The roadmap used `g` for both.
15. **`init!` and `trim!` refuse an origin whose first frame the clock
    cannot resolve**, through `_check_origin` (§10.5, §14.5, D-450).
16. **§10.7's pacer example read `h = 0.01` for the frame**, stale since
    D-443. The docs half corrects it to `Δt_frame = 0.01`.
17. **`_frames_fit` mirrors `_frames_to`, and the origin asks for a first
    frame.** The doors checked `x + slack < last`, `x` the bound in frames
    from `t₀`, so a `t_end` within its slack of the last frame top was
    refused though it lands on a frame `frame!` admits. Increment 91 had
    this with `max_frame`. The check is now `x − slack ≤ last`, the form
    `_frames_to` rounds up from. `_check_origin` called it at `t = t₀`,
    where the strict form meant "the last frame is at least 1", so the
    origin now asks `_last_frame ≥ 1` directly, D-450's wording. Replay
    keeps the check as a guard before `_frame_at`'s conversion. Its refusal
    is the recording's frame count, so a `to_time` inside the frame after a
    recording that reached the very last frame is still refused, as before.
    The coordinator's change, after the prototype.

## What the tests pin, by property

In `test/test_lattices.jl` unless named. F counts failures and E errors
under the mutant.

- **A harmonic `h_max` gives equal steps of exactly `h_max`** (§2.2,
  D-449). The bound ignored: 21F, 1E. The step as `Float64(span)/n`: 1F.
- **A due instant cuts a span into equal steps** (§10.5, D-449): pieces
  7/200, 7/200, 3/100, 4/100, 3/100, 3/100, the interior clocks bitwise at
  `t₀ = 0.25`. The interior clock counted from the frame top: 2F.
  Accumulated: 5F.
- **A non-harmonic `h_max` takes equal steps no longer than the bound and
  longer than half of it, and a `Dual` model takes the same lengths**
  (§10.5). `fld` for `cld`: 8F.
- **A bound at or above the frame is the unbounded trajectory** (D-449).
- **The bound is recorded resolved, its spellings compare equal, and its
  refusals collect** (§9.2), `test_stepper.jl`. The bound as written: 4F.
- **The clock's last frame** (§10.5, D-450): `2^49 − 1`, `2^46 − 1`,
  `3·2^46 − 1` and the origin's room. The gap always the unit: 2F. The gap
  `h_max` where it is `h_max/2`: 2F.
- **The refusal at every door** (§12.6, D-450): the origin, `frame!`,
  `t_end`, `frames`, `t_plus`, `to_time` and an unbounded run. No
  resolution in `_last_frame`: 8F, 1E. `frame!` reading `max_frame`: 1F,
  1E. The `frames` door reading `max_frame`: 2F, 1E.
- **The `Int` range still binds where it is the lesser, and a bound fits
  where the frame it lands on runs** (§10.5, §12.6, D-450): `_frames_fit`
  at the last frame top and one ulp past it, refused half a frame past it,
  and a `t_end` at the last frame top run to it. The strict form restored:
  1F, 1E.
- **An origin whose first frame is the last the run may take is admitted**
  (§14.5, D-450), beside the origin refused with none. The origin asking
  for two frames: 1E. No origin check: 1F, 1E.
- **The constructor refuses a bound it cannot count** (§9.2). The
  `frame·q` check removed: 1E, after one test was added for it.
- **The `show` line in each form** (§9.2), `test_show.jl`. Spans counted
  for steps: 2F. The cap ignored: 1F.

Replay's `to_time` door shares `_frames_fit` with the others and its second
check raises the same error, so a mutant on that site alone changes no
result.

## Bookkeeping

- The docs commit: `spec.md`, `log.md`, `tools/coinage_inventory.md`,
  `tools/gloss_table.md` and the roadmap, whose lead under "Settled in
  discussion" also loses "None is built yet", since a task's state lives on
  its `pending.md` bullet.
- The code commit, beside the patch's code half: `code_map.md`'s entries
  for the deployment, frame, model, sim, show and diagnostics files and for
  `test_lattices.jl`; `rules/code_rules.md`'s clock-value caveat;
  `companions/frame_walkthrough.md`'s quote of the loop; `pending.md`, with
  the step bound landed and the seam protocol next.
- `pending.md`'s record of the ruling on three raw `OverflowError` sites
  stands as ruled, though one of the three, `bind_schedule`'s
  `Δt_frame / h`, no longer exists.

## Out of scope

- The seam protocol: increment 3. Anything adaptive, `h_min`, equal
  division under a proposal, one step-length rule and exact periods on the
  `Deployment`: increment 4, as the roadmap's open decisions.
- Replay's `to_time` inside the frame after a recording that reached the
  very last frame, refused as before (reading 17).
- The inspector: its construction sites spell no step, so its pin moves
  nothing for this increment.

## The cold review

An independent high-tier agent over the whole increment at the code
commit's tip: the full gate on the floor `Project.toml` declares; the
Documenter build; each new testset's source reverted alone on a scratch
copy; a bit-identity probe against fd155e6 outside the tree, on cases of
its own beside the sixteen; D-450's derivation checked line by line, and
an attack of its own just inside `2^50·δ`, interior step ends beside a
mandatory instant first; the `Int128` checks of `_lattice` at their edges,
and `_steps_line` on a schedule whose hyperperiod leaves `Int`; D-449 and
D-450 against `log_rules.md`, and the five annotations; §2.1 and §10.5's
rewritten subsection against `spec_rules.md`, Part I's depth included; a
grep for every surviving "step point", `RK4(` or `Heun(` with an argument,
`:not_harmonic`, `lattice.step`, `lattice.h` and `_step_time` outside the
log and the records. "Empty is acceptable."

## The review's record

To be filled after the review.

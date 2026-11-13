# Brief: increment 95, exact time

One docs commit, one commit of this brief with the patch
`prototype_increment_95.patch`, one code commit applied from the prototype,
one cold review, and a fix commit by a fixer agent, to which the user
consented. Drafted on 2026-11-12 at 84379eb and landed on 2026-11-13 after
the docs commit 46b7674, which touches nothing under `src/` or `test/`.
Every line range below reads from `git show 84379eb:file`, and so does every
moved pin; a line inside a new testset is the patch's.

The prototype is the implementation. One high-tier agent built it on
2026-11-12 in two passes, in a scratch worktree detached at 2804435. Pass 1
built exact periods (D-454) and a step-length rule by piece, the first
D-455. The user, present throughout, reversed that rule on the prototype's
evidence and added two rulings, and pass 2 built them: D-455 rewritten as
the float distance everywhere, D-456 the nearest clock and D-457 the exact
origin. Pass 2 restored `src/frame.jl` and `test/test_library.jl` to
2804435, so nothing of the rule by piece survives in the patch. The
prototype's notes record every reading, moved pin, mutant and measurement
below; their sections "PASS 2" to "P2 final" describe what was built, and
the earlier ones are pass 1.

After the prototype, the agent that drafted this brief rebased the worktree
onto 84379eb, which changed only the roadmap and `pending.md`, resolved
`pending.md` by hand, and applied the coordinator's fixes: the three docs
sentences under What is settled, the stale comments, docstrings and testset
names the prototype left, and the `t0` message. On 2026-11-13 the user
ratified the eight readings, four of them with changes, and the same agent
built the changes in the worktree (Readings): `_instant` over the three
integers with its multiply and add as arguments, the door's checked range
test and the restore's, no two-argument `_set_origin!`, and `_exact_origin`
without its `Real` catch-all. The full gate, the battery and a timing ran
after them (Measurements). The patch is the worktree's diff from 84379eb: 29
files, +825 −293: five under `design/` (+347 −64), eleven under `src/` (+241
−130) and thirteen under `test/` (+237 −99), no file new. `git apply
--check` of it succeeds on a clean 84379eb.

The user was present. The prototype's eight readings and two findings below
were put to the user on 2026-11-12; the user ratified the readings on
2026-11-13, four with changes, each marked below.

Design and code are peers, neither subservient. If a shape below proves
wrong at the keyboard, stop and report rather than deviate silently.

## What is settled

The roadmap's increment 3b, under the `pending.md` bullet "Variable-step
integration", sub-bullet "Next: exact time" (lines 71–77). Four rulings of
the roadmap's section "Ruled on 2026-11-12" land here, in the spec and the
log, docs commit first. The section's other bullets are increment 4's.

- **Exact periods on the `Deployment`** (D-454). It stores `Δt_frame`,
  `Δt_base` and the resolved `h_max` as `Rational{Int}`, and `==`, `hash`
  and replay's check compare those. The lattices and the step counts are
  decided on the exact values, so comparing floats left a hole: at a 1 s
  frame, `h_max = 1//3` and `h_max = Rational(1/3)` compared and hashed
  equal, took 3 and 4 steps a frame, and `replay!` accepted one's recording
  into the other while the state drifted by 0.014 in five frames.
- **One step-length rule: the float distance everywhere** (D-455). Where the
  end's clock is known beforehand, a step integrates by the end's clock
  minus the start's. Where the length is chosen first, the end's clock is
  the start's plus the length. It is one sentence and the general case,
  since an adaptive step end has no other length. Before it, declaring a
  localized event that never fires moved a trajectory by ulps. The rule by
  piece, ruled first and built in pass 1, stands in D-455's Rejected list.
- **The clock is the float nearest the exact instant** (D-456). A frame top,
  a due instant and a fixed-step end inside a span take the `Float64`
  nearest their exact instant. Before it, at `Δt_frame = 3//10`, frame 3
  read `0.8999999999999999`, and `Step(t_step = 0.9)` fired 9.8 ps past that
  boundary when localized, two snapshots for one event, and a frame late
  when not. At a 0.1 s frame the old clock missed the nearest float at 352
  of the first 1000 frame tops.
- **The origin is exact** (D-457). `t₀` is a `Rational{Int}`, so D-456 holds
  from any origin. `t0` takes the exact forms a period takes, and a float at
  its exact value, since a wall-clock origin is a float by nature. An origin
  whose run the clock's integers cannot carry is refused at the door, so the
  loop's integer arithmetic runs unchecked (reading 3, ruled on 2026-11-13).
  The checkpoint and the trace header hold and compare it exact.
- **Annotations.** D-260 amended by D-457, D-445 amended by D-456, and D-449
  refined by D-454, D-455 and D-456. The roadmap named D-449 and D-260;
  D-445 is the prototype's addition, since it states the old clock formula.
  `check_rows` reports D-454 to D-457 as newly cited.
- **The bit-identity invariant ends here.** The nearest clock moves every
  model by ulps, and the float distance moves a model without localized
  events. Increment 4 moves no existing trajectory.

**Corrected after the prototype**, at the coordinator's instruction, and in
the patch as it stands:

1. D-455's Position and §10.5 state the rule as the roadmap does: where the
   end's clock is known beforehand the step integrates by the end's clock
   minus the start's; where the length is chosen first, as under a proposal,
   it integrates by that length, and the end's clock is the start's plus it.
   D-455's third bullet and §10.4's interpolant sentence say that the
   localization loop's first segment takes the step's offered length and a
   remainder from a `t*` the distance from the clock to the step's end
   (reading 6). §2.2's sentence gains "or by its length where the length is
   chosen first".
2. D-455's Rationale no longer claims the float distance removes the arrival
   clock's offset. It says the arrival sweep reads the step end's clock
   except in the rare rounding case where a step starts below half its end's
   time, and that nothing published depends on it (finding 2). The Rejected
   bullet on the rule by piece loses "an arrival clock off the step's end"
   among its costs. The roadmap's "Why" still makes the claim, and is left
   alone.
3. D-454's Rationale no longer names a pair of spellings that takes one
   trajectory. Under D-456, two spellings of a period that round to one
   `Float64` write different clocks on the lattice they set, so they are two
   trajectories and the exact comparison refuses them rightly: at a 0.1 s
   frame, `1//10` and `Rational(0.1)` part at 352 of the first 1000 frame
   tops, by a Julia check of the clock arithmetic outside the tree. No spec
   sentence repeated the claim. The re-recording cost the passage named goes
   with it.

## The shape built

- `src/deployment.jl`: the struct's three time fields, 482–484, become
  `Rational{Int}`. `bind_schedule`'s return, 362–363, passes the exact
  values where it converted them, and its docstring, 255–257, says so. The
  `Deployment` docstring, 442–444, and the comment over `==`, 550–552, state
  the exact comparison; `==` and `hash`, 553–560, are unchanged and now
  compare the rationals. The design line, 409, gains D-454.
  `ScheduleEntry`'s `Δt` column, built at 333 and 342 as `D *
  Float64(Δt_base)`, is untouched.
- `src/store.jl`, 151–168: `Clock{T}` holds `t₀::Rational{Int}` and three
  `Int128` fields, `origin`, `unit` and `scale`, the origin and the
  lattice's unit over one denominator. `Clock{T}(t₀::Float64)` goes;
  `Clock{T}()` is a zero origin on a zero unit. New: `_grid_integers(t₀,
  unit)`, an lcm and two checked products; `_set_origin!(clock, t₀, unit)`,
  which writes the integers, `t₀` and `t = T(Float64(t₀))`, the one setter,
  every caller passing the lattice's unit; and `_instant(origin, unit,
  scale, position, i, units, steps, mul, add)`, the float nearest `t₀ +
  (position + i·units/steps)·unit`, one multiply-add and one division of the
  two integers converted to `Float64`. `mul` and `add` default to `*` and
  `+`, the loop's unchecked arithmetic, and the door passes the checked
  ones. `count = Int128(position) * steps + Int128(i) * units` stays below
  `2^127` and is never checked. `_instant(clock, position, i, units, steps)`
  forwards the clock's integers. The docstring is rewritten.
- `src/build.jl`, 1459: `compile` makes `Clock{T}()`. `Model` is its only
  caller.
- `src/model.jl`:
  - `Model`, 110–125, sets a zero origin on the lattice's unit after
    `compile`;
  - `init!`, 268–340: the docstring's signature and `t0` keyword, 269 and
    302–304; the plan method takes `t0 = 0`, untyped, and writes the origin
    through `_set_origin!`, 315–327;
  - `_check_origin`, 341–350, returns the exact origin. Three functions
    follow it. `_exact_origin` maps a `Period` to its `T`, an integer or a
    rational to `Rational{Int}(t0)`, a finite float to its exact value, and
    anything else, `π` among them, to `nothing`. `_origin(call, t0,
    deployment)` refuses as `ArgumentInvalid` `:range` on `:t0` on
    `nothing`, an `InexactError`, an `OverflowError` or a `DivideError`.
    `_clock_integers(t₀, deployment)` computes the grid integers and
    evaluates `_instant` with checked arithmetic at the run's two ends:
    position zero, and the last frame `_last_frame` allows plus one frame,
    as `i` equal to the lattice's largest step count per span, a span of the
    whole frame, with `units` at the frame. Every value the loop forms lies
    between the ends' values, so an origin that passes never wraps the
    loop's unchecked arithmetic;
  - `_grid_time` and `_tick_time`, 478–486, are `_instant` at `k *
    lattice.frame` and `n * lattice.base` units;
  - the frame helpers, 503–548, stay float. The comment's example moves to
    the new clocks, and `_last_frame`, `_frames_fit`, `_frames_to` and
    `_frame_at` convert the origin and the period at the site;
  - `_clamped`, 791, reads `Float64(h_max)`, and `_nonfinite`'s boundary
    rounding, 850–851, converts the origin and the period;
  - `_assert_at_rest`, 1094, and `_restore_state!`, 1216, call the
    deployment method of `_frames_to`. `_check_grid!`, 1152–1155, builds no
    `Clock`: it calls `_clock_integers` on the state's origin and deployment
    and reads the frame top through `_instant` over those integers. A state
    built by hand may carry an origin no door accepted, so an
    `OverflowError` there pushes `ArgumentInvalid` `:range` on `t0`, call
    `:restore!`, into the restore's list.
- `src/frame.jl`:
  - the header, 19–27, states D-455 and D-456;
  - `_frame_steps!`, 92–165, drops `where {T}` and `t_from`. Under no
    proposal an interior end is `_instant(clock, origin + position, i,
    units, steps)` and the step's length is `oftype(t, t_next) - t`, where
    it was `T(h)` for the exact `h`, whose line 124 goes. The proposing
    branch is unchanged. It passes `h_step` to `_localized_step!`, 140;
  - `_localized_step!`, 166–306, takes `h` after `model`. The first segment
    integrates by `h`, and a remainder after a `t*` by `t_to - clock.t`, set
    at the loop's foot, 305. At 84379eb every segment took `t_to - t_seg`,
    188;
  - `_crossing`, 341, converts `Δt_frame` in the tolerance.
- `src/checkpoint.jl`: `ModelState.t₀`, 81, is `Rational{Int}`, and the
  docstring, 53 and 61–62, says the origin is exact and `t` the float
  nearest the frame top. `_restore_state!`, 117–128, sets the origin through
  `_set_origin!` on the state's own lattice unit and then `t`.
- `src/sim.jl`: `init!` and `trim!` take `t0 = 0`, untyped, 750, 829, 1101
  and 1119. The comment over `init!`, 712–715, and its `t0` keyword,
  819–821, say the origin is exact, in the model's `init!` wording. `trim!`
  passes `_check_origin`'s exact origin to the solve and the commit,
  1125–1128. `_advance!`'s `Δt_frame`, 2085, is converted for the pacer. The
  trace header's comparison, 1196, is unchanged and now compares rationals.
- `src/trim.jl`: `trim!`, 490 and 559–564, as in `sim.jl`, and its `t0`
  keyword, 551–554, in the same wording. `_solve_problem`, 578, takes
  `t0::Rational{Int}`, and both halves set their clocks from it, 595 and
  621.
- `src/linearize.jl`: the `about` form reads its origin through
  `_origin(:linearize, something(t0, 0), model.deployment)`, 273–274, and
  the seeded half takes it, 304. `_set_clock!`, 341–348, takes an exact
  origin and the deployment, and sets the origin on its lattice unit; its
  three callers here and two in `trim.jl` pass `model.deployment`. A `t0`
  that `_origin` refuses is a new refusal on `linearize`, and no test
  reaches it.
- `src/diagnostics.jl`, 2397–2399: `ArgumentInvalid`'s `:t0` message says
  "`t0` must be an exact time — an integer, a rational, a `Period` or a
  finite float at its exact value — from which a run may take at least its
  first frame, on clock integers that carry the run".
- `src/show.jl`, 257–258: the comment over `_deployment_parameters`. The
  print is unchanged and now shows rationals.
- Tests: four new testsets at the end of `test_lattices.jl`, one in
  `test_stepper.jl`'s `test_seam_protocol`, one in `test_trace.jl`'s
  `trace_entry_pass` and one in `test_lifecycle.jl` after the testset at 45,
  the moved pins below, and `utils.jl`'s `frames!`, 18, which converts the
  period. The refusal list at `test_lifecycle.jl` 48 gains `π`.
  `test_lattices.jl`'s testsets at 134 and 192 are renamed and their
  comments follow (below), and `test_lifecycle.jl` 325–326's comment gives
  frame 3's clock from the float origin `-0.3` as about `1.1e-17`.
  `test_library.jl` is unchanged.
- Docs: `spec.md` §2.1 (288), §2.2 (374), §2.4's "What fixes a trajectory"
  (616), §9.2's "The `Deployment`" (a bold paragraph after 4628) and
  "Rendering" (a bullet after 4734), §10.4's "The localization loop" (6231)
  and "Endpoint policy and grid integrity" (6313–6315), §10.5's "Spans,
  steps and the clock" (6564–6575), §12.6 (9857–9858, with the refusal of an
  origin the clock's integers cannot carry), §12.7 (10390–10391), §14.5
  (12777, the same refusal in its list), Appendix B (14492, 14495–14496 and
  14510), Appendix C (15112–15113), and four link definitions. `log.md`:
  four index rows, D-454 to D-457, three annotations and four link
  definitions; D-456's bullet on the clock's arithmetic and D-457's on the
  refusal carry the door's check, and D-457's Rejected list the forms beyond
  a period's and the three alternatives of reading 3. `code_map.md`,
  `rules/code_rules.md` and `pending.md` as in Bookkeeping.

### The moved pins, by the ruling that moved them

Recounted from the patch, at 84379eb's lines. One assertion, `test_trace.jl`
1609, moved under two rulings.

- **D-454, the periods exact: 14 assertions** that read a period as a
  `Float64`. `test_discrete.jl` 180, 249, 252, 405, 482 and 506;
  `test_stepper.jl` 129 and 133; `test_trace.jl` 264, 267, 273 and 1399,
  `CheckpointMismatch`'s expected and found; `test_show.jl` 116 and 245, the
  printed deployment. Five sites convert a period where a test computes with
  it, no value moved: `test_bindings.jl` 184, `test_failures.jl` 781,
  `test_lattices.jl` 236 and 279, `utils.jl` 18.
- **D-455, the float distance: 8 assertions**, all in `test_lattices.jl`.
  Equal-step pins become pins within an ulp: 121 and 122 (the harmonic
  bound, now "within `eps(1.2)` of 0.1" and a count of 12), 130 (within
  `eps(0.2)`, beside a new count of 40), 200 and 202 (the bound dividing
  nothing, now within `eps(0.2)` of the exact lengths and at most `h_max +
  eps(0.2)`). Exact-length pins become differences of clocks: 144, 181 and
  220. Three testsets are renamed: 115 to "a harmonic h_max takes equal
  steps of h_max, to the clock's round-off"; 134 to "a due instant inside a
  step splits it: two pieces between the clocks and the tick's instant",
  whose comments at 135–136 and 155–156 now say both paths integrate by the
  float distance; and 192, which gains "to the clock's round-off".
- **D-456, the nearest clock: 24 assertions.** `test_lattices.jl` 107, 108,
  111 and 112 (the 20 ms frame's instants, now `Float64` of the exact
  product, and 100.1); 146, 154 and 161 (the split); 187 (the cut span's
  clocks); 268 (the subcycled clocks); 293 (the published clocks); 355, 360
  and 363 (the chattering instants, now `0.375` and `0.425`); 372, 373 and
  376 (the stop at a step end, `0.35` and `0.4`). `test_discrete.jl` 664;
  `test_trace.jl` 1372, 1609, 1656, 1662, 1666 and 1775;
  `test_localization.jl` 212, where `6 * 0.1` became `0.6`. Line 161's value
  did not move, since `7 * 0.01 === 0.07`. Twelve more sites change form
  from `k * Δt_frame` to `Float64(k * Δt_frame)`, needed once the period is
  a rational: `test_localization.jl` 74, 87, 123, 147, 148, 319, 334 and
  341, `test_lifecycle.jl` 337, 377 and 434, `test_stepper.jl` 224. Their
  `k` is 1 or 4, whose products are the nearest floats, except
  `test_lifecycle.jl` 337, a `t_plus` argument that moves from
  `0.30000000000000004` to `0.3`. And the stub at `test_stepper.jl` 334
  changes from `every = 2` to `every = 3` (finding 1).
- **D-457, the exact origin: 7 assertions.** Six read `t₀` as a rational:
  `test_trace.jl` 98, 1609 and 1697 (`CheckpointMismatch` `:t₀`, expected
  `0//1` and found `Rational(0.05)`), `test_readers.jl` 581, `test_trim.jl`
  139 and 780. One pins the rewritten `t0` message: `test_diagnostics.jl`
  1262, from "`t0` must be a finite real" to "`t0` must be an exact time".

The notes put `test_bindings.jl` among the twelve form changes; the patch
leaves it `frame * Float64(Δt_frame)`, a `t_end` argument, and the twelve
are those above.

## Measurements

- **Gate.** The baseline at 2804435, the worktree unedited: 9822 of 9822,
  the suite in 9m18.5s, 12:18.53 wall with precompile. Pass 1: 9841 of 9841
  in 9m31.4s, 12:22.87 wall; its 19 new assertions were 11 in
  `test_trace.jl` and 8 in `test_stepper.jl`. Pass 2, the patch: 9855 of
  9855 in 14m04.8s, 17:15.29 wall, on a machine the coordinator's second
  worktree shared, so its time compares with nothing. A ten-file subset
  before it read 5589 of 5590, the one error the prototype's own keyword
  typo in the `Step(t_step = 0.9)` testset, fixed before the final gate.
- **The coordinator's two variants**, measured on a second worktree before
  the pass-2 rulings: the float distance alone failed 9 of 9841 assertions,
  seven that pin D-449's wording in `test_lattices.jl` and two that revert
  the prototype's own repin; the float distance with the nearest clock at a
  float origin read 9731 pass, 24 fail and 5 error.
- **Allocations.** On the pass-2 tree and the baseline alike: the phase
  bodies, `sweep_1`, `sweep_2`, `rhs` and the ticks, interior and boundary,
  0 B at `Float64` and `LinearizeDual` on the feedback model at `h_max =
  1//300`; `frame!` 0 B on the feedback model at both scalars, on the lagged
  model with a localized event that never fires and without it, and on
  `stamped()`. Pass 1 read the same. A `Dual` model takes the `Float64`
  lengths, which `test_lattices.jl`'s dual pins check.
- **The hole**, probed in pass 1, D-454's code unchanged since. At 2804435,
  `feedback_model` at a 1 s frame under `h_max = 1//3` and `Rational(1/3)`
  compared and hashed equal, took 16 and 21 boundaries in five frames,
  drifted by at most 0.0138, and `replay!` accepted the recording. On the
  patch the two compare unequal and the replay is refused.
- **Bit-identity**, pass 1 only: every model without localized events and
  every `Dual` model matched the base, and the localized ones moved by at
  most 3.2e-15. Pass 2 moves every trajectory by design, and no pass-2 probe
  measured by how much.
- **Examples.** `Longitudinal` 77 of 77 in both passes. **Battery.** Green
  after the last pass-2 docs edit, and again after the fixes: `linkify.jl` a
  no-op, `check_refs`, `check_rows` (D-444 to D-457 newly cited),
  `check_glossary --strict` and `check_bold` OK.
- **After the first fixes**, which touched no executable line beyond the
  `t0` message: the routed runners `diagnostics lattices lifecycle trim`
  under the gate's flags read 1825 of 1825 in 1m11.5s: diagnostics 1019,
  lattices 133, lifecycle 408, trim 265.
- **After the rulings of 2026-11-13**: `lifecycle lattices` read 556 of 556
  before the gate, and the full gate read 9870 of 9870 in 9m50.8s, 12:48.78
  wall, the machine to itself. One comment in `_clock_integers` was reworded
  after it, and the battery ran green after that. The door-line mutant, the
  two checked `_instant` calls removed from `_clock_integers` on a scratch
  copy, turned the new testset red, one failure and one error, at
  `test_lifecycle.jl` 88 and 81 in the patch.
- **Timing**, `frame!` per step on `feedback_model` at `Float64` with
  `NoHooks`, by `BenchmarkTools` in a fresh process per tree: 1000 frames a
  sample, 300 samples, the least sample over the steps it took, since one
  frame sits near the 41.7 ns timer tick. Two runs each. With no bound, one
  step a frame at `Δt_frame = 1//100`: the baseline (the prototype's `git
  archive` of 2804435's `src` and `test`) 89.4 and 79.0 ns, the worktree
  78.8 and 81.5 ns. With `h_max = 1//500`, five steps a frame: the baseline
  62.0 and 62.0 ns, the worktree 59.1 and 59.0 ns. Ratios, worktree over
  baseline: 0.88 and 1.03 with no bound, 0.95 with the bound; the run-to-run
  spread with no bound exceeds the difference.
- **Not measured.** Compile latency, the Documenter build and the size of
  pass 2's moves; the reviewer's.

## Readings the prototype took

Each was put to the user on 2026-11-12. On 2026-11-13 the user ratified 2,
4, 6 and 8 as built, and 1, 3, 5 and 7 with the changes each states, which
the worktree now carries.

1. **The origin is a `Rational{Int}` on the `Clock`, beside three `Int128`
   grid integers** (`origin`, `unit`, `scale`) that `_set_origin!` caches
   where the origin is set. A clock is then one multiply-add and one
   division in the loop, as D-457 asks. Alternatives: a `Rational{Int128}`
   origin, or the integers alone. *Ratified with a change:* the two-argument
   `_set_origin!`, which rebuilt the unit from the cached integers, is gone,
   and every caller passes the lattice's unit: the restore from the state's
   deployment, `linearize` and `trim!` from the model's. Every caller had a
   lattice in reach.
2. **The frame helpers stay float.** `_frames_to`, `_frames_fit`,
   `_frame_at` and `_last_frame` keep their slack, and the origin converts
   at the site. Alternative: exact helpers, at a rational computation per
   call. *Ratified as built.*
3. **The loop's clock arithmetic is unchecked, and the door guards it.** The
   prototype checked every product in the loop and let a per-boundary
   `OverflowError` surface raw inside the frame. *Ratified with a change*,
   the user's: `_instant` is one formula whose multiply and add are
   arguments, plain in the loop and checked at the door. `_clock_integers`
   evaluates it at the run's two ends, position zero and the last frame
   `_last_frame` allows plus one frame, at the lattice's largest step count
   per span, and an `OverflowError` refuses the origin as the `t0` refusal.
   Every value the loop forms lies between the ends' values, a negative
   origin included: argued in `_clock_integers`'s comment, and a probe
   outside the tree checked 53,112,772 values over 20,000 random small
   lattices with origins from −10^6 to 10^6, none beyond the ends' bound. A
   restore re-checks, since a state built by hand carries an origin no door
   accepted. Alternatives the user weighed: the checked loop, 27 ns a clock
   against 1.7 ns unchecked, measured standalone by the coordinator; a
   cached limit folded into `_last_frame`; and no check at all, rejected
   because unchecked arithmetic wraps in silence. D-457 and §12.6 and §14.5
   say that an origin whose run the clock's integers cannot carry is refused
   at the door, and D-457's Rejected list takes the three alternatives. No
   annotation on D-450 and no change to `_last_frame`.
4. **A refused `t0` is `ArgumentInvalid` `:range` on `:t0`**, the existing
   kind, its value the `t0` given. Alternative: a reason `:inexact`, which
   `ArgumentInvalid` already carries for `Period` and `Hz`. The prototype
   left the rendered message saying "a finite real", which misread a finite
   `t0` refused for its form; it now names the exact forms (The shape
   built). *Ratified as built.*
5. **The `t0` keyword is untyped, default `0`**, at `init!` and `trim!` on
   the model and the simulation, so a `Period` is accepted and the default
   is exact. `Hz(50)` returns a `Period`, so it is accepted too, as the
   origin `1//50`. Alternative: keep `::Real` and drop the `Period`.
   *Ratified with a change:* `_exact_origin` loses its `::Real` catch-all,
   which took `π` as a rational approximation. It accepts what the period
   door accepts, an integer, a rational or a `Period`, and a finite float at
   its exact value, and refuses anything else. `π` joins the refusal list at
   `test_lifecycle.jl` 48.
6. **`_localized_step!` keeps its `h` parameter.** This is a deviation from
   the coordinator's instruction, which was to return the function to its
   2804435 form. The first segment integrates by the step's offered length.
   Under a proposal the bare path integrates by the chosen length `h` and
   ends at `t + h`; the 2804435 form integrates by `(t + h) - t`, which can
   differ from `h` by an ulp, and the twin's proposal arm failed at
   `test_stepper.jl` 504 and 505 under `Scheduled(1/40)`. D-455 says that
   where the length is chosen first the step integrates by it. Under no
   proposal the offered length is `t_next - t`, so the two forms agree.
   D-455 and §10.4 now state the proposal case (What is settled). *Ratified
   as built.*
7. **`_check_grid!` built a temporary `Clock{Float64}`** at the door to find
   the frame top nearest a state's instant. Alternative: a pure function
   over the grid integers. *Ratified with that alternative:* `_instant`
   takes the three integers, its `Clock` method forwards to it, and
   `_check_grid!` calls `_clock_integers` and that method, building no
   `Clock`.
8. **`show` and the diagnostics print the origin as a `Rational`.**
   `CheckpointMismatch` `:t₀` reads `0//1` and, for the float `0.05`,
   `3602879701896397//72057594037927936`. Snapshots carry `t` only. The
   notes record no alternative. *Ratified as built.*

Two findings the rulings did not foresee, put to the user with the readings:

1. **A rejecting stub stalls on the sliver.** Under `Scheduled(1/40; every =
   2, factor = 0.5)`, `stamped()` reaches an adaptive end at
   `0.29999999999999993`, an accumulated `t + h`. The span's end, now the
   nearest float `0.3` where it was `0.30000000000000004`, lies 5.55e-17
   past it. The stub rejects that sliver and proposes half of it, `t + h ==
   t`, and `_clamped` throws `InternalInvariant`. This is increment 93's
   known sliver, which the nearest clock surfaced. The prototype changed the
   stub at `test_stepper.jl` 334 to `every = 3`. No backend in `src/`
   proposes, and increment 4's equal division under a proposal removes the
   sliver (Out of scope).
2. **The arrival clock can sit an ulp off the step's end.**
   `integrate_step!` writes `clock.t = t + h` on acceptance (`model.jl`
   770), and `_localized_step!` writes `t_seg + h′` before the arrival
   evaluation (`frame.jl` 262). With `h = t_to - t`, `t + h` misses `t_to`
   by an ulp when `t < t_to/2`, where the subtraction is not exact. The
   end-of-step guard sweep and the arrival sweep then run at that clock; the
   frame loop writes `t_end` before the boundary, so the boundary's clock is
   right. Not fixed. D-455's Rationale now states it; the roadmap's "Why"
   still says the float distance removes it.
## What the tests pin, by property

"Run" marks a mutant that ran, with the lines that went red. N1 to N4 ran on
the final tree, and the control after them was green on `test_lattices.jl`
and `test_seam_protocol`. M1 to M3 ran in pass 1 and were not re-run; that
they still turn the same lines red is argued, since pass 2 touched neither
D-454's code nor those lines. The twin's red is a gate failure the prototype
saw, not a mutant it ran. The door-line mutant of 2026-11-13 ran on a
scratch copy of the worktree. No other mutant is recorded, run or argued,
except the one marked argued below.

New testsets:

- **A time quantity compares by its exact value**, and `replay!` refuses
  one's recording in the other (§9.2, §12.7, D-454), `test_trace.jl` 301 in
  the patch: each quantity beside its float's spelling compares and hashes
  apart, `1//3` and `Rational(1/3)` take 3 and 4 steps a frame and part by
  more than 0.01, and the replay is refused on `:h_max`. Run: M1, `==` over
  the floats, 312 three times and an error at 301; M2, `hash` over the
  floats, 312 three times.
- **A localized event that never fires leaves the trajectory bit-identical
  to the same model without it, under a bound and under a proposal** (§10.4,
  §10.5, D-455), `test_stepper.jl` 484 in the patch. Seen red:
  `_localized_step!` at its 2804435 form failed 504 and 505 in the proposal
  arm, in the prototype's pass-2 gate before reading 6; not a deliberate
  mutant run. N1 does not kill it, since the localized first segment takes
  the same `h_step`. The bound arm has no recorded mutant in pass 2.
- **A step's length is the difference of its two clocks**, under a bound
  that divides nothing and a due instant that cuts a span, from the origin
  `1//7` (§10.5, D-455), `test_lattices.jl` 543 in the patch. Run: N1, the
  bare path by the exact length, 557.
- **A time typed on a lattice is its boundary's clock**, from the origin 0
  and from `-3//10`, and the float origin `-0.3` is its own value (§2.1,
  §10.5, D-456, D-457), 561 in the patch. Run: N2, the clock as `Float64(t₀)
  + position·Float64(unit)`, 573 and 574; N3, the origin rounded to a float,
  573 and 574.
- **A bound finer than the frame steps through the clocks of a frame at that
  bound, bitwise, for a model that reads time, from an exact origin**
  (§10.5, D-455, D-456), 583 in the patch, origin `7//3`. Run: N3, 599; N4,
  an interior end as the span's start clock plus `i` float steps, 599.
- **A step typed on the frame grid fires at its boundary in one snapshot,
  localized or not** (§10.4, §10.5, D-456), 602 in the patch, `Step(t_step =
  0.9)` at a 0.3 s frame. Run: N2.

Rewritten testsets, at 84379eb's lines:

- **The 20 ms frame's instants**, `test_lattices.jl` 82: each the float
  nearest its instant. Run: N2, 107 to 112.
- **A harmonic bound takes equal steps of `h_max` to the clock's
  round-off**, 115. No recorded mutant kills it: N1 is absent from its red
  lines, since a pin within an ulp admits both rules. The equality the rule
  needs is pinned at 543.
- **A due instant splits a step**, 134: lengths as differences of clocks,
  the nearest clocks. Run: N1, 145 in the patch.
- **A due instant cuts a span**, 170: the nearest clocks and lengths as
  their differences. Run: N1, 186; N2, 185; N4, 185, all in the patch.
- **A bound that divides nothing**, 192: lengths within an ulp of the exact
  ones and at most `h_max` plus an ulp. No recorded mutant, for the reason
  at 115.
- **A bound at or above the frame**, 212: three runs alike, lengths as
  differences of clocks. Run: N1, 217 in the patch.
- **A bound finer than the frame subcycles**, 243: the subcycled clocks.
  Run: N2, 264; N4, 260 and 264, in the patch.
- **The chattering budget across a frame's steps**, 343, and **a stop at a
  step end**, 357: the instants as decimals. Run: N2, 351 and 362–363; N4,
  351, in the patch.
- **The deployment parameters on replay's entry pass**, `test_trace.jl` 247
  at 84379eb: expected and found as rationals. Run: M3, the deployment walk
  reporting floats, 264, 267 and 273, and an error at 301, in the patch.
- **The proposal is clamped, and a shortened step ends at the clock plus its
  length**, `test_stepper.jl` 314, with its stub at `every = 3` (finding 1).
- **The rendered `t0` refusal**, `test_diagnostics.jl`'s rendering testset,
  1262: the message names the exact forms. No mutant recorded.
- **An origin whose run the clock's integers cannot carry is refused at the
  door** (§12.6, §14.5, D-457), `test_lifecycle.jl` 81 in the patch: at a
  10^5 s frame, `t0 = 1//typemax(Int)` has grid integers that fit `Int128`,
  but the clock about 5.6e14 frames on would not, so `init!` refuses it as
  `ArgumentInvalid` `:range` on `:t0` and leaves the model `built`; at a 0.1
  s frame the same origin is accepted. Run: the door line removed, one
  failure and one error.
- **An origin of another form is refused** (§14.5, D-457), the refusal list
  at `test_lifecycle.jl` 48 with `π` added. Argued: the `::Real` catch-all
  restored takes `π`, and that element goes red; not run.

Acceptable survivors: N1 against the within-an-ulp pins at 115 and 192,
since those pins state D-449's claims to the clock's round-off and 543 pins
the rule.

## Routing

- The coordinator, applying the patch: the docs commit from the patch's
  `spec.md` and `log.md`; then `git apply` of the rest of the patch, every
  hunk of which applies at 84379eb (Bookkeeping).
- The reviewer and the fixer: `design/rules/code_rules.md` whole; the
  `code_map.md` entries for `src/build.jl`, `checkpoint.jl`,
  `deployment.jl`, `frame.jl`, `linearize.jl`, `model.jl`, `show.jl`,
  `sim.jl`, `stepper.jl`, `store.jl` and `trim.jl`, and for
  `test/test_lattices.jl` and `test/test_stepper.jl`; `pending.md` 15–105;
  the roadmap's "Ruled on 2026-11-12" and item 3b.
- The spec at 84379eb: §2.1, 269–357; §2.2, 358–412; §2.4's "What fixes a
  trajectory", 604–635; §9.2's "The `Deployment`", 4574–4704, and
  "Rendering", 4705–4746; §10.4's "The localization loop", 6162–6279, and
  "Endpoint policy and grid integrity", 6280–6324; §10.5's "Spans, steps and
  the clock", 6540–6622; §12.6's "The run and the simulation", 9830–9897;
  §12.7's "Validation up front", 10359–10424; §14.5, 12681–12803; Appendix
  B's "Stopped-sim services", 14490–14559; Appendix C, 14646–15234.
- The log at 84379eb: D-260, 10828–10914; D-445, 18528–18594; D-449,
  18706–18788; and D-454 to D-457 in the patch. `design/rules/spec_rules.md`
  and `design/rules/log_rules.md` for the docs.

## Bookkeeping

- **The docs commit:** `spec.md` and `log.md` from the patch, with the
  battery. The roadmap needs nothing for the rulings. Its "Why" under the
  float distance still says the float distance removes the arrival clock's
  offset (finding 2), left alone at the coordinator's instruction.
- **The code commit**, beside `src/` and `test/`:
  - `code_map.md`, in the patch: `src/checkpoint.jl` (196–197),
    `src/deployment.jl` (360, 388–389 and its Spec line, 404),
    `src/frame.jl` (621–628 and its Spec line, 655), `src/model.jl` (853,
    871 with `_clock_integers`, 929–930 with the restore's origin check, and
    its Spec line, 931), `src/show.jl` (1051 and its Spec line, 1061) and
    `src/store.jl` (1215–1218, `_instant` over the three integers with its
    two kinds of arithmetic, and its Spec line). Not in the patch, to weigh:
    `src/sim.jl`, `src/trim.jl` (1262–1272, "both halves' clocks at `t0`")
    and `src/linearize.jl`, whose `_set_clock!` now takes the deployment and
    sets an exact origin on its lattice; `test/test_lattices.jl`
    (1311–1326), which gains four testsets, and whose fixture list still
    names `FreshHooks`, gone since increment 93, a stale line from before
    this increment; `test/test_stepper.jl` (1328–1343), which gains the
    twin.
  - `rules/code_rules.md` 187–191, in the patch: the trap on a test's clock
    value rewritten, the nearest float of the exact instant and a length as
    the difference of two clocks.
  - `pending.md`, in the patch, resolved by hand onto 84379eb. The
    sub-bullet "Next: exact time", 71–77, becomes "Landed: exact time",
    increment 95 (D-454, D-455, D-456, D-457,
    `design/increments/095_exact_time/`), stating what the four entries
    deliver and keeping 84379eb's sentence on the rulings and the cut.
    "Then: the first adaptive backend", 78–79, becomes "Next". The ruled
    item at 98–100 says exact periods and the step-length rule landed with
    increment 95 (D-454, D-455). The item at 88–90 on the sites that raise a
    raw `OverflowError` now says the frame loop's exact piece length went
    with this increment, so one remains, `bind_schedule`'s `anchor.T /
    Δt_base`. One sentence to weigh, untouched: the sliver sentence at 66–70
    can name the stall a rejecting stub now reaches (finding 1).
- **The brief's commit:** this brief and the patch, and the prototype's
  notes if the coordinator keeps them.

## Out of scope

- Increment 4: `h_min`, the floor and the attempt budget on the
  `Deployment`, equal division under a proposal, a `t*` ending the step
  under a proposing backend, and the first adaptive backend, the roadmap's
  bullets marked 4.
- The stall under a rejecting stub (finding 1). It is increment 93's sliver,
  recorded on `pending.md`'s seam-protocol sub-bullet, 66–70: "And a
  proposed step can end a sliver short of the span's end, leaving a last
  step of about an ulp, which equal division under a proposal removes, as
  ruled on 2026-11-12."
- The arrival clock an ulp off the step's end (finding 2), unless the user
  rules a fix into this increment.
- A correctly rounded division past `2^53`, rejected in D-456; exact frame
  helpers (reading 2) and an `Int128` fit bound in `_last_frame` (reading
  3), unless ratified otherwise.
- Persistence: no recorded format changes (D-454).
- The raw `OverflowError` that `bind_schedule`'s `anchor.T / Δt_base` raises
  on periods of extreme magnitude, the one such site left: a loose commit
  fixes it after this increment lands.
- The inspector, `examples/`, `docs/` and `README.md`: none reads
  `Δt_frame`, `Δt_base`, `h_max` or `t₀` as a field, by a grep at 84379eb
  and over `RedstoneInspector.jl/src`.

## The cold review

An independent high-tier agent over the whole increment at the code commit's
tip: the full gate on the floor `Project.toml` declares, the examples, the
Documenter build and the battery; each new testset's source reverted alone
on a scratch copy; N1 to N4 and M1 to M3 re-run, and a mutant sought for the
twin's bound arm. Then, in this order:

- **The nearest-clock guarantee.** The spec and D-456 claim the exact
  nearest float while both integers stay below `2^53`, and about an ulp
  beyond. Compare `_instant` with a correctly rounded `BigFloat` value over
  random origins and positions, below and above `2^53`, from exact origins
  and from float ones with a large binary denominator (`-0.3`, `time()`,
  which pass `2^53` at once). Measure the error past `2^53`. `_last_frame`'s
  comment, `model.jl` 552–559 in the patch, bounds each clock's error by the
  old formula's `2^-52·(|t₀| + 2·(t − t₀))`: check that the new clock fits
  under it, so boundaries stay ordered wherever the door admits a frame.
- **The door's range check** (reading 3). Read `_clock_integers` and its
  claim that every value the loop forms lies between the two ends' values;
  probe it with origins and lattices near the edge, negative origins
  included, and with a run driven to its last frame where that is cheap.
  Confirm that every caller of `_instant` with the plain operators reaches
  only positions the door bounded: the frame loop, `_grid_time` at
  `_assert_at_rest`, and `_check_grid!`, whose `k * lattice.frame` and
  `_instant` are unchecked for a hand-built state whose `t` lies far past
  the lattice's range. Check the restore's own origin check and its
  `ArgumentInvalid` with call `:restore!`. `_lattice` still refuses a bound
  when `frame_steps * denominator(unit)` leaves `Int`, `deployment.jl`
  207–210 and 227, a check for the exact length `(units·unit)/n` that the
  patch deletes from `frame.jl`: say whether it still guards anything,
  `_instant`'s `scale * steps` included, and whether `test_lattices.jl`
  529–534 pins a refusal no longer needed.
- **Every door that sets the origin.** `Model`, at zero; `init!` on the
  model and the simulation; `trim!` on both, its scratch halves and its
  commit; `linearize`'s `about` form and its operating-point form;
  `restore!` on both; `replay!` with and without `restore`. For each: the
  origin exact, the grid integers on the deployment's unit, `t` the nearest
  float. `Clock{T}()` holds a zero unit, so confirm that no clock is read
  before a `_set_origin!` with the lattice's unit.
- **The forms the door admits.** `_exact_origin` takes an integer, a
  rational, a `Period` and a finite float. Probe a `Bool`, which passes as
  an integer, a `Rational{BigInt}`, a `Float16`, a `BigFloat`, `Hz(50)`,
  which passes as a `Period`, a string, `1e-300` and an origin whose grid
  integers overflow; read the rewritten message for each (reading 4); and
  test `linearize`'s new refusal, which no test reaches. A `Δt_base` spelled
  two ways that round to one `Float64`, in a model with no discrete
  component, sets no lattice, so the two deployments take one trajectory and
  compare unequal: say whether D-454's rewritten Rationale covers that case.
- **The checkpoint and the trace header compare the origin exact.**
  `ModelState.t₀` at `restore!`, and `_compile_feed`'s comparison, `sim.jl`
  1196. A checkpoint from the float origin `0.3` refused in a model
  initialized at `3//10`, and the rendering of reading 8. A `ModelState`
  built positionally with a `Float64` `t₀` converts silently.
- **The `every = 3` change**, `test_stepper.jl` 334. Confirm that a
  rejection still shortens the step that holds the crossing at 0.315, or the
  testset's last property, a localized event inside a shortened step, is no
  longer exercised. Reproduce the stall at `every = 2` and confirm that it
  is increment 93's sliver and nothing new.
- **The temporary `Clock` in `_check_grid!`** (reading 7): its allocation at
  the restore doors, and its frame top equal to the clock the loop wrote for
  the same state, a float origin past `2^53` included.
- **Any clock still computed as an origin plus an index times a float.** The
  brief found none on the loop's path in `src/`; run a grep of your own.
  Near instances: `ScheduleEntry`'s `Δt`, `D * Float64(Δt_base)`
  (`deployment.jl` 333 and 342), a period rather than a clock. Test pins
  still in the old form, which pass because their products happen to be the
  nearest floats: `test_lattices.jl` 237–238 and 280–281, `test_failures.jl`
  408, 420, 430, 441, 447, 493 and 526, `test_events.jl` 498 and
  `test_lifecycle.jl` 884, all `k * 0.1` or `k * Float64(Δt)`;
  `test_discrete.jl` 671's origin `3 * 0.1`. The rewritten trap in
  `code_rules.md` says that form "can sit an ulp off". `test_lifecycle.jl`
  346–356 test the frame helpers against `t₀ + k * h`, the old formula.
- **The sweeps the four principles call for** (`brief_rules.md`, Scope).
  D-454: every reader of the three fields converts at its site, by a grep
  for `\.(Δt_frame|Δt_base|h_max)\b` over `src/`, `test/`, `docs/` and
  `examples/`. D-455: every caller of `integrate_step!` and `attempt!`,
  `_clamped`, the retry clamp, and the bare `integrate!(model, h)`, which
  integrates by the `h` its caller gives. D-456: every clock write, `clock.t
  = ` in `frame.jl`, `model.jl`, `store.jl`, `checkpoint.jl`, `linearize.jl`
  and the stage clocks in `stepper.jl`. D-457: every reader of `t₀`, the
  frame helpers, `_nonfinite` and replay's `to_time` included.
- **Stale text.** The fixes after the prototype rewrote the `Float64`-origin
  wording in `sim.jl` and `trim.jl`, the `_grid_integers` comment,
  `test_lattices.jl`'s comments and two testset names, `test_lifecycle.jl`'s
  "5.6e-17" and the `t0` message; grep for any other. Two comment blocks in
  `frame.jl`, the header and the one over `_localized_step!`, are left
  unwrapped. Read the three corrected docs passages of What is settled
  against the code.
- **The arrival clock** (finding 2): how often `t_seg + (t_to - t_seg) !=
  t_to` in a localized run, what the guard and arrival sweeps read there,
  and whether writing `t_to` where the attempt took the whole offer fixes it
  without breaking the twin.
- **A bit-identity probe of its own** against 2804435, outside the tree,
  sizing the ulp moves; `@inferred` on `_instant`; the step path's
  allocations at `LinearizeDual` from a float origin.
- D-454 to D-457 and the three annotations against `log_rules.md`; the
  spec's changed sections against `spec_rules.md`.

"Empty is acceptable."

## The review's record

The arc on top of 84379eb: 46b7674 (docs), b8dd909 (this brief and the
patch), c58ce63 (code), 290801c (the coordinator's notes), then the
review's fixes. Nothing is pushed.

**The review**, at 290801c. An independent high-tier agent ran the gate,
9870 of 9870 in 10m00.5s on Julia 1.13.3, with `Longitudinal` 77 of 77,
the Documenter build clean and the battery green. Its own probes compared
`_instant` with a correctly rounded `BigFloat` value: exactly nearest below
`2^53`, and past it up to 2 ulps on origins with large odd denominators,
1.34 times the bound in `_last_frame`'s comment at worst over 600,000
adversarial cases, the boundaries still ordered. It checked 23,212 loop
values against the door's two ends, none past them, and every door that
sets the origin. `_instant` infers concretely at 0 B, and `frame!` allocates
nothing past 1100 frames from `-0.3` at `Float64` and `LinearizeDual`.
Against 84379eb, clocks moved at 59 to 70 of 200 frame tops and states by
up to 8.4e-15, as D-456 and D-455 say. Its report lists ten findings.

The coordinator adjudicated them, and a fixer landed the fixes as one
commit:

- **F1, a float origin was rationalized.** `Rational{Int}(x)` returns a
  rational that rounds back to `x` when the exact value needs a denominator
  past `Int`: `1e-4` became `855561659527253//8555616595272529590`, and
  `big"0.1"` became `1//10`. The door now compares the result with the float
  exactly and refuses it unless equal, so such a float is refused and the
  message's exact forms apply. No round-trip rule. The origin door keeps
  its types: the exact comparison refuses `big"0.1"` alone, and a
  `Float16` or a `Rational{BigInt}` that fits is still taken at its exact
  value. D-457, §12.6, the three `t0` docstrings and the code comment name
  `1e-4`. Test: `1e-4` and `big"0.1"` join the refusal list. The comparison
  dropped: 2 failures and 2 errors over `lifecycle` and `linearize`.
- **F2, `replay!`'s `to_time` compared a float with the exact origin.**
  From `t0 = 3//10`, `to_time = 0.3`, boundary zero's clock, was refused.
  Now `to_time ≥ Float64(t₀)`. Test: from `3//10`, `to_time = 0.3` halts at
  frame 0 and `0.5` at frame 2. The fix reverted: 1 error. The sweep found
  no other comparison of a float with the exact origin: `_check_origin`,
  `_last_frame`, the three frame helpers' deployment methods, `_nonfinite`,
  `_assert_at_rest`, `_check_grid!` and `linearize`'s `about` form convert
  at the site, and the trace header compares two rationals.
- **F3, the shortened step lost its localized event.** At `every = 3` the
  step holding the crossing at 0.315 was accepted whole. The stub is now
  `Scheduled(1/40; rejected = (14,), factor = 0.8)`: attempt 14, offered 0.3
  to 0.325, is rejected, and the retry from 0.3 ends at 0.32, past the
  crossing. The test asserts the retry's start and `t_fired` inside it.
- **F4, six survivors given tests**, each shown red on a scratch copy:
  (a) a hand-built state at `t₀ = 1//typemax(Int)` on a 10^5 s frame is
  refused at `restore!` as `ArgumentInvalid` `:t0`, the target left `built`
  (G, 1 error); (b) `trim!` from `t0 = 2//5` commits `2//5` in both forms
  (J, 2 failures); (c) a recording from the float `0.3` refuses a simulation
  at `3//10` on `:t₀` (P, 1 error); (d) `linearize`'s `about` refuses `π`,
  `1e-4`, `"0.3"` and `NaN` as `t0` (K, 1 failure and 1 error); (e) a state
  restored into a fresh model steps on the taken model's clocks from `-0.3`,
  `7//3` and `1e9 + 0.1` (H, 3 failures); (f) under a recording stub, the
  remainder from each `t*` integrates by the distance to its step's end, and
  the step it cut by its offer (B2, 1 failure).
- **F5, stale `t0 = 0.0`.** The model's `init!` and `trim!` signatures in
  §14.8 and Appendix B, and `linearize`'s default in §14.10 and Appendix B,
  now read `0`. §14.10 gains a sentence on the exact forms and the refusal,
  and `linearize`'s docstring says the same.
- **F6, D-454's second bullet** said the loop read the float of the stored
  value, so no trajectory moved. It now says every reader converts the exact
  value at its site.
- **F7, "within about an ulp".** D-456, §10.5 and `store.jl` say two ulps.
  `_last_frame`'s comment bounds each clock by `1.5·2^-52·(|t₀| + 2·(t −
  t₀))`, three roundings of `2^-53` each, so the reach leaves a quarter of
  the gap as margin.
- **F8, `_lattice`'s second `:h_max` check** guards no exact length now.
  Ruled: the check and its test stay, and the comment says what it guards,
  `_instant`'s `scale·steps` and `origin·steps` below `2^126`, which the
  door also checks. The test's comment and the code map's entry follow.
- **F9, stale text.** `test_readers.jl`'s testset on a `Float64` origin,
  `test_lifecycle.jl`'s comment on the loop's grid, the old-form pins in
  `test_failures.jl`, `test_events.jl`, `test_lifecycle.jl`,
  `test_lattices.jl` and `test_discrete.jl`, written now as typed decimals
  or as `Float64` of the exact product, `test_discrete.jl`'s origin `3 *
  0.1` as `3//10`, the code map's `test_lattices.jl` entry with its
  citations and properties, `FreshHooks` gone from it, and the two comment
  blocks in `frame.jl`, wrapped.
- **F10, a `Δt_base` in a model with no discrete component.** D-454's
  Rationale gains the sentence: it sets no lattice, so its two spellings
  take one trajectory and still compare unequal. The origin door's wider
  types are settled under F1.

**Survivors accepted**, the reviewer's: D2, the door's two ends at one step
a span, near-equivalent, since the last frame's count barely moves with the
step count and `_lattice` bounds `origin·steps` and `scale·steps`; L,
`trim!`'s scratch clocks from the float origin, whose origin no scratch
evaluation reads. B and T were discarded as equivalent. A, D1, E, F, Q, M1,
M3 and N1 to N4 die, and X, the arrival clock written as `t_to`, kept every
localized test green.

**Report only: a `t*` clock can round onto its segment's start.** §10.4 says
`t* = tₙ` cannot happen, at worst `nextfloat(tₙ)`. The bracket holds in θ,
but the clock `t_seg + θ★·h′` rounds onto `t_seg` once `θ★·h′` is below half
an ulp of it. Two snapshots then share one clock: from `t0 = 2^20` at a 0.1
s frame, crossings 1e-13 s and 1e-11 s past frame 3, and from `2^30` 1e-9
s; from `t0 = 0` never. It predates the increment and stays outside it.

**After the fixes.** The fixer ran the gate in the real tree, 9919 of 9919 in 10m01.0s, 13:08 wall, part of it beside the
mutant runs on a scratch copy, the 49 new assertions included,
the battery green with `linkify.jl` a no-op, and `Longitudinal` 77 of 77.

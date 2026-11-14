# Notes: increment 96, the coordinator's record

What the coordinating session settled with the user that the spec, the log
and the brief do not carry. The audit behind the increment is
`design/reports/20261113_exact_arithmetic/report.md`, cited below by section
and probe label.

## Ruled on 2026-11-14

The user asked whether exact time was worth its cost, with floats
everywhere as an alternative, and ruled after the session's analysis.

1. **Exact time stands.** Floats everywhere is not taken.
   - The report's sites 1 to 11 predate increment 95. `Period` has held a
     `Rational{Int}` since August and the fold has multiplied in `Int`
     since September. A float period would keep the integer schedule and
     add a tolerance at the doors.
   - From origin 0, `k * Float64(Δt)` misses the float a user types at 3595
     of 10 000 frame tops for `1//10`, 1327 for `1//100` and 866 for
     `1//60`.
   - Every finding at sites 1 to 14 needs nested multipliers near `2^32` or
     coprime denominators near `2^40`. A pool of nine realistic periods and
     offsets has a gcd of `1//882000`, 20 bits of 63. `Hz(0)` and the
     wall-clock float origin (G2 to G4) are the two findings on plausible
     input.
2. **One increment, single-stage, the prototype its implementation.** It
   lands before the first adaptive backend, since `h_min` arrives through
   the period door. Loose fixes were not taken: the items need rulings, and
   the ruling of 2026-11-13 asks for the fallout whole.
3. **The overflow sites take less than the report's policy A.**
   - Checked arithmetic in the fold and in `bind_schedule`'s multiply-add.
   - One catch per door of `OverflowError`, `InexactError` and
     `DivideError`, refused under an existing reason, as `_origin` does.
   - A `Period` that is not finite refused at its constructor.
   - `_prime_powers` with a condition that cannot wrap and a cap on its
     divisor.

   No `Int128` bound proofs and no new reasons that name paths. The reason:
   the report's section 2.3 shows that every overflow in the grid report
   marks a pool no deployment can hold, so a catch refuses nothing
   deployable.
4. **The clock is the nearest float at every magnitude.** `_instant` gains
   a correctly rounded division for integers past `2^53`, behind a branch
   on their magnitude, and boundary zero takes its clock from `_instant`.
   This adopts the alternative D-456 rejected, whose premise was that no
   practical origin reaches those integers. A wall-clock float origin
   reaches them at frame 0.
5. **§10.5's bounds follow the new clock.** The statements of the report's
   section 5 are corrected.
6. **The doors' loose ends fold in:** `Bool`, and a `Rational` of another
   integer type at the `Deployment` keywords. The descriptor's JSON
   integers stay out, since the loss is in the inspector's reader. They
   are an unordered item in `RedstoneInspector.jl/design/pending.md`, its
   commit `b90f95e`.

## Delegated overnight on 2026-11-14

The user delegated the rest of the increment overnight, with the prototype
on its gate run: the readings round, the docs commit, the brief, the build,
the cold review, the fixes and the delta check. Every ruling the
coordinator makes from here is recorded under "The coordinator's rulings"
below, with its reason, and nothing is pushed
(`rules/increment_rules.md`). The user's diff of the arc and the push
remain.

The user left a fresh session in standby, named `inc-96-handoff`. If the
coordinator reaches its stopping point, it brings these notes and the
`pending.md` bullet up to date, commits them, and messages that session
with the successor's first prompt, to finish the increment.

## Weighed and not taken

- **A float origin kept as a float base**, the clock `t0` plus the float
  nearest the elapsed time. It is the nearest float at wall-clock
  magnitude and regresses small float origins. From `t0 = 0.25` at a 1 ms
  frame, 162 of 1000 frame tops leave the nearest float, where today none
  do. From `-0.3` at a 0.1 s frame, 290 do.
- **Refusing an origin whose clock integers pass `2^53`.** The least code,
  but it refuses `time()` and the float `-0.3` on a decimal grid, against
  D-457.

## The session's measurements

Standalone, on Julia 1.13.3, outside the package. The prototype measures
them again inside it before a figure enters the brief.

- The long division matched a BigFloat reference on three million
  quotients, the report's G1 shape among them, and matched the plain
  division on a million quotients of integers below `2^53`.
- Over 200 wall-clock origins and frames 0 to 999, today's formula leaves
  the nearest float at 67 600 of 200 000 clocks at `1//10`, 63 160 at
  `1//100` and 48 648 at `1//1000`. The long division leaves it at none.
- A clock from a wall-clock origin costs 34 ns by the long division and
  1.2 ns by the plain one.

## Ruled on 2026-11-14, the four open points

The rulings above left four points open. The user ruled them the same day,
while the prototype ran, and the prototyper received them in one message.

7. **The structure step takes one new reason, `:range`.** A composed
   divisor or phase past `Int` is a `RatesViolation` with reason `:range`,
   on the diagnostic's existing `path`, `key` and `value`. It is the one
   exception to ruling 3. No existing reason says it: `:multiplier` reads
   "K ≥ 1" and `:phase` "0 ≤ φ < K", so reusing either would print a wrong
   message for a valid `K`. `:range` is the reason every other time door
   gives for a value its type cannot hold.
8. **`Bool` stays accepted.** No door gains a method for it, which amends
   ruling 6. `Δt_frame = true` deploys a 1 s frame, as Julia's `Bool` is an
   integer, and nothing breaks. The user preferred no code for an input
   nobody types. The coordinator had recommended a refusal, mildly.
9. **D-450's bound stays `2⁵⁰·δ`, its rationale restated.** Under the new
   clock two clocks keep their order while `|t₀| + 2ε < 2⁵²·δ`, so the
   bound keeps a factor of 4. Relaxing it would move `_last_frame` for
   every deployment and gain nothing a run reaches, and a proposing
   backend's step end, the start's clock plus a length (D-455), may use
   the margin at increment 4.
10. **The trial division's cap is `2^20`.** A cofactor left below `2^40`
    is prime, since a composite would have a factor below the cap, so
    every denominator below `2^40` is factored whole. A cofactor at or
    above `2^40` may be composite, and the grid report's message marks it
    as unfactored. The worst case is about a million iterations.

## The coordinator's rulings, overnight

The prototype reported on 2026-11-14 with the gate at 10 101 of 10 101 in
its worktree and nine readings. The user was away, so the coordinator
ruled each. All nine stand as the prototype built them.

- **R1. The unfactored cofactor is marked where the grid block is
  rendered**, by its magnitude, at or above the cap's square. The data
  keeps its shape. A marker in the data would touch `_prime_powers`, the
  supplier test and the named tuple for a label one function prints. A
  prime between `2^40` and the square of the first prime past the cap
  prints as unfactored, which is true of it: nothing factored it.
- **R2. The `Deployment` door catches at each premise**, through one
  shared function: each keyword, the grid report and the multiply-add. A
  single catch around `bind_schedule` would drop the faults D-229 has the
  call collect. This is ruling 3's "one catch per door" read against
  D-229, which the user's ruling did not suspend.
- **R3. A divisor past `Int` after composition with its anchor is the
  lattices' existing refusal**, `Δt_base` `:range`. `:anchor_period` says
  "not an integer multiple", which is false of an overflow, and ruling 3
  asks for an existing reason.
- **R4. A grid report whose arithmetic leaves `Int` is no report.**
  `:derive` is then refused as `:range`, under a message arm of its own.
  An explicit or default `Δt_base` meets the anchor loop's refusal, by the
  report's section 2.3. The cold review probes that argument, since a
  deployment built with no report would be a defect.
- **R5. The time keywords' constraint reads "must be positive and finite
  in `Rational{Int}`".** The old text would tell a user that `2^70` is not
  positive and finite. Two message pins move.
- **R6. A rate its own check refused composes nothing in the fold**, so
  one fault is one refusal.
- **R7. An offset that is not finite is refused at `Absolute`**, by the
  rule ruling 3 gives `Period`.
- **R8. The slow path is a chunked long division**, 11 ns a clock against
  34 ns for the session's bit-by-bit loop. A frame of the measured model
  takes 0.21 µs and writes four or five clocks. Against the fast path's
  2.6 ns, the chunked form adds about a fifth to that frame on a
  wall-clock run, and the loop would add more than half. Both forms
  matched the reference on 4.6 million quotients. The docs agent caught
  the coordinator's first figure here, "a tenth of a frame", as wrong.
- **R9. The scratch clocks of `trim!` and `linearize` go through
  `_set_origin!`**, which leaves `_set_clock!` to the checkpoint form.

Four things the prototype found outside the scope are left for the user,
on a `pending.md` bullet: `Relative`'s constructor, the readers that
convert the origin by `Float64(t₀)`, a composite cofactor's suppliers, and
`_origin`'s own `try`.

## State at 0c64874, the handover

The coordinating session `inc-96` handed over here, at the code commit, to
the standby session `inc-96-handoff`. Its context read 350k at the brief's
commit. The review, its fixes and the delta check need one session, since
a reviewer answers only the session that launched it.

- **Commits, none pushed.** The rulings `6cfcce8` and `b743551`, the
  audit report `52cb5eb`, the overnight rulings `9d1263e`, the docs commit
  `daaeccf` (D-458, D-459), the brief with the patch `12b5bc4`, and the
  code commit `0c64874`.
- **Tests.** The gate read 10 101 of 10 101 in the prototype's worktree.
  The routed subset read 2403 of 2403 on the real tree before the code
  commit: `declare discrete lattices lifecycle trim linearize diagnostics`.
  `docstring_roster.jl` came back clean. The Documenter build has not run.
- **Next.** The cold review by the brief's last section, the adjudication,
  the fixer's one commit, the same reviewer's delta check, the review's
  record in the brief, and the first `pending.md` bullet retired. Then the
  user's diff of the arc and the push.
- **For the reviewer, beyond the brief.** The patch's comments and test
  names cite D-456 and D-457, never D-458 or D-459, which did not exist
  when it was written. The Documenter build is owed, since four exported
  docstrings changed. D-459's Rationale and §9.2 state R4's argument for
  an offset's neighbour as settled, and the brief asks the reviewer to
  test it.
- **The limit on overnight rulings.** A successor rules what the review
  raises and records it here. It does not reverse the user's rulings 1 to
  10. A finding that contradicts one stops the run at that stage.

Where the session's files are, under
`/private/tmp/claude-501/-Users-miguel--julia-dev-Redstone-jl/8985b7f9-b4fe-42e5-99c1-7fdf38c4a14f/scratchpad/`:

- `wt_inc96`, the prototype's worktree, detached at `6cfcce8` with its
  patch uncommitted. It can go after the push.
- `prototype_notes_96.md`, the prototyper's notes.
- `mutate.py` and `mutants.log`, the 19 mutants and their results.
- `gate.log`, the prototype's gate, and `routed_real_tree.log`, the
  routed subset on the real tree.
- `report_probes.jl`, `measure_clock.jl`, `quotient_probe.jl` and
  `quotient_cost.jl`, the prototyper's probes.
- `clock_probe.jl` and `worked.jl`, the coordinator's standalone probes
  behind rulings 1 and 4.
- `context_watch.py`, the context watch over an agent's transcript.

The prototyper and the docs agent answered `inc-96` alone, so a successor
resumes neither.

## The successor's rulings on the cold review, overnight

The session `inc-96-handoff` took over at `fed5ba3` and launched one cold
reviewer. Its gate read 10 101 of 10 101 on Julia 1.13.3, on the real tree.
It ran 34 mutants of its own: 28 went red and six survived. The review's
findings and their fixes are the brief's record. The user was away, so the
successor ruled each finding. None is ratified by the user yet.

- **R10. An offset's neighbour that `Rational{Int}` cannot hold is not
  offered**, which amends R4. The reviewer built a counterexample to R4's
  argument. With `E = 2^45 + 3`, the anchors
  `Absolute(Period(2^20), 2^21//3)` and `Absolute(Period(2^20//E))` have
  the gcd `g = 2^20//(3E)`. Every count at `Δt_base = g` fits `Int`, so the
  anchor loop, the schedule and the lattices pass. The offset's lower
  neighbour has a numerator past `Int`, so the report was `nothing`. An
  explicit or default `Δt_base` then raised a raw `MethodError` at the
  `Deployment`'s `grid` field, and `:derive` refused a pool that deploys.
  The fix computes each neighbour under the shared catch and drops one that
  fails. A neighbour is an offset to declare, and `Absolute` refuses a value
  `Rational{Int}` cannot hold, so the dropped one was no repair. The report
  then fails only at the gcd and at a factor. There the reviewer proved
  R4's argument, as the audit's section 2.3 states it. Three alternatives
  were not taken:
  - neighbours in `Int128`, since ruling 3 takes no wider arithmetic and
    the value could not be declared anyway;
  - a `Deployment` that holds no report, which changes a field's type and
    still has `:derive` refuse a pool that deploys;
  - a guard for a missing report at the constructor, since the proof covers
    the two sites left.
- **Ruling 3 stands, and the run did not stop.** The handover's limit stops
  the run on a finding that contradicts a user ruling. The successor read
  F1 as no such finding. Ruling 3's mechanism is unchanged: checked
  arithmetic and one catch per door. Its reason cites the audit's section
  2.3, which argues the gcd and the factor only, and both arguments hold.
  The extension to an offset's neighbour was R4's. The user may read it
  otherwise, so this is the first thing put to them.
- **R11. The docs commit's sentences on that argument are corrected in
  place, in the fix commit.** D-459's Position gains the neighbour's rule.
  Its Rationale, D-187's annotation, §9.2 and the comment in
  `bind_schedule` state the argument for the gcd and the factor only.
  D-459 is this arc's own entry and is not pushed, and the fix commits of
  increments 91 to 95 corrected their arcs' entries the same way.
- **R12. The nominal half's clock in `linearize` takes a test.** The
  reviewer's mutant reverted `linearize.jl`'s first `_set_origin!` and
  nothing went red. The builder's list had no mutant for that site. The
  test must go red under the revert. If no observable shows the clock, the
  fixer stops and reports.
- **R13. One `:range` refusal per entry in the fold.** A bare container key
  whose composition leaves `Int` gave one identical refusal per element.
  D-459 puts the refusal "on the entry that composed it", and R6 has one
  fault give one refusal.
- **R14. The lattices' `Δt_base` `:range` message names both of its
  conditions**: a unit too fine to index one frame, and a period past `Int`
  in units. R3's reason stays. The old text was false for the case R3
  routes there, where one frame is one unit. `_lattice` already returned
  this refusal for a period past `Int` before the increment, so the text
  was already too narrow.
- **R15. Comments and test names cite the entry that rules.** D-458 for the
  division, boundary zero's clock and the scratch clocks, and D-459 for
  the doors, the fold and the schedule. `model.jl`'s comment at the
  `_set_origin!` call is included, though the patch left it alone, since
  the docs commit made its citation stale.
- **R16. Four nits are fixed.** A comment in `test_discrete.jl` that says
  `2^31` where the values are near `2^40`. The accepted origin forms in
  `test_lifecycle.jl`, which sat in a testset named for refusals and get
  their own. `_exact_or_nothing`'s argument, renamed `fn` by the roster of
  `code_rules.md`. `Hz`'s docstring, where "that is not finite" could read
  as the frequency: `Hz(1//0)` builds a zero period that the structure
  step refuses.
- **R17. Five survivors are accepted beside the brief's one.** The catch's
  `DivideError` arm stays, since ruling 3 names the three errors, and the
  reviewer found no door input that raises it in twelve candidates. The
  two phase checks alone are equivalent mutants, since a sound composition
  keeps `c < m` and `Φ < D`. The fast path's bound made strict is
  equivalent, since both paths round correctly at `2^53`.

Two things the review left open stay open. It did not prove `DivideError`
unreachable under the shared catch, and it did not measure the clock's
costs again.

The reviewer's files are under
`/private/tmp/claude-501/-Users-miguel--julia-dev-Redstone-jl/37100ed5-3f61-4bd7-986b-4005fa955c19/scratchpad/review_96/`:
`review_notes_96.md`, `gate.log`, `mutate_review.py`, `mutants_review.log`,
the `mutants/` logs, the `probes/` scripts with their logs, and the
worktree `wt_review`.

## After the fixes and the delta check

The fixer landed R10 to R16 as `3052530`, with the gate at 10 114 of
10 114 on the real tree. The same reviewer checked the delta with its
context intact and read all seven findings as fixed. The successor ruled
three more points, none ratified by the user:

- **R18. The neighbour's rule reads "whose arithmetic leaves `Int`"**, the
  fixer's wording, which amends R10's "that `Rational{Int}` cannot hold".
  The reviewer built the case that separates them. In a pool that cannot
  deploy, the quotient `τ/partial` can overflow while both neighbours fit,
  and the report then offers neither. The code before the increment gave
  such a pool no report at all, and recovering the neighbours would take
  wider arithmetic, which ruling 3 does not take. In a pool that deploys
  the two wordings agree, and the reviewer proved it.
- **R19. The delta check's two leftovers land as a second small commit**,
  `39572a9`: a test for the key of the fold's de-duplication, which a
  mutant showed untested, and one clause in `bind_schedule`'s docstring.
  The fixer ran the routed subset `discrete diagnostics`, 1279 of 1279,
  and no gate, since the commit adds one test and rewords one internal
  docstring.
- **R20. One more survivor is accepted.** The quotient left outside the
  catch changes only a pool that cannot deploy: its refusal loses the grid
  block.

Two things the fixer saw are left as they are. The message's remedy
"coarsen `Δt_base` or `Δt_frame`" names `Δt_frame`, which does not help
the period's case. R10's three rejected alternatives are here and not in
D-459's Rejected list, since R10 is not ratified.

**State at the closing commit.** The arc is `daaeccf`, `12b5bc4`,
`0c64874`, `fed5ba3`, `1602946`, `3052530`, `39572a9` and the commit that
carries this section. The brief holds the review's record, and the first
`pending.md` bullet is retired. What waits for the user is on the
variable-step bullet of `pending.md`: the rulings R1 to R20, R10 first,
then the diff of the arc and the push.

The fixer's files are under
`/private/tmp/claude-501/-Users-miguel--julia-dev-Redstone-jl/37100ed5-3f61-4bd7-986b-4005fa955c19/scratchpad/fix_96/`:
`fix_notes_96.md`, `gate.log`, `routed.log`, `routed_delta.log`,
`mutate_fix.py`, `mutants_fix.log`, the `mutants/` logs and its probes.
The reviewer's delta files sit beside its first ones: `mutate_delta.py`,
`mutants_delta.log`, `mutants_delta/`, `probes/r4_fix_probe.jl` and
`probes/item3_case.jl`. Its worktree `wt_review` and the prototype's
`wt_inc96` can go after the push.

## Ratified on 2026-11-14

The user ratified R1 to R20 after the session explained R10 against R4 and
ruling 3.

The explanation corrected one bullet above. "Ruling 3 stands, and the run
did not stop" puts the overreach in R4 alone, but it began earlier. The
audit's table lists the neighbours as site 9, "not probed". Its section
2.3 argues only the gcd and the factor, under a heading that says every
overflow. Ruling 3's recorded reason repeated the heading, and R4 built it
into one catch around the whole report. The counterexample made that
reason false at site 9 and left ruling 3's mechanism intact. R10 makes the
reason true again, since after it only the gcd and a factor empty the
report. The user ratified R10 on that account.

R10's three rejected alternatives join D-459's Rejected list. What remains
is the user's diff of the arc and the push.

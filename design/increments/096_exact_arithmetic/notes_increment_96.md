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
  takes 0.21 µs and writes four or five clocks, so the difference is a
  tenth of a frame on a wall-clock run. Both forms matched the reference
  on 4.6 million quotients.
- **R9. The scratch clocks of `trim!` and `linearize` go through
  `_set_origin!`**, which leaves `_set_clock!` to the checkpoint form.

Four things the prototype found outside the scope are left for the user,
on a `pending.md` bullet: `Relative`'s constructor, the readers that
convert the origin by `Float64(t₀)`, a composite cofactor's suppliers, and
`_origin`'s own `try`.

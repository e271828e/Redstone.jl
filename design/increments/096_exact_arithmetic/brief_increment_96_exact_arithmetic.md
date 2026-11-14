# Brief: increment 96, exact arithmetic on the time surface

The arc makes four commits: the docs amendment, this brief with the
prototype's patch and the notes, the code, and the review's fixes. Drafted
on 2026-11-14 at `daaeccf`, which is the docs commit. A high-tier
agent prototyped the whole increment in the scratch worktree `wt_inc96`,
cut at `6cfcce8`, and its diff is `prototype_increment_96.patch` beside this
brief: 16 files, +437 −64. The prototype is the implementation, so the
coordinator applies the patch and this brief keeps its record half. The user
was away from the prototype's report on, having delegated the rest
overnight, and the coordinator's rulings are in `notes_increment_96.md`
under "The coordinator's rulings, overnight". Not normative: if a shape
below proves wrong at the keyboard, stop and report rather than deviate.

## What is settled

The increment delivers `pending.md`'s first bullet, "The exact-arithmetic
audit, increment 96", from the audit
`design/reports/20261113_exact_arithmetic/report.md`. The user ruled ten
points on 2026-11-14, each with its reason in the notes:

1. Exact time stands. Floats everywhere is not taken.
2. One increment, single-stage, before the first adaptive backend.
3. The overflow sites take checked arithmetic and one catch per door under
   an existing reason, not the report's policy A at its scale.
4. The clock is the float nearest its instant at every magnitude, and
   boundary zero takes its clock from `_instant`.
5. §10.5's bounds follow that clock.
6. A `Rational` of any integer type at the `Deployment` keywords.
7. The structure step takes one new reason, `RatesViolation` `:range`.
8. `Bool` stays accepted, with no code.
9. D-450's bound stays `2^50·δ`, its rationale restated.
10. The trial division's cap is `2^20`, and a cofactor at or above `2^40`
    prints as unfactored.

The docs commit `daaeccf` carries them. D-458 rules the clock, and D-459
keeps time exact and rules the doors. D-185, D-187, D-450, D-456 and D-457
take annotations.

## The shape built

Line ranges are from `git show daaeccf:file`. The docs commit touched no
source file, so they are `6cfcce8`'s.

- **`src/declare.jl`**, 371 to 468. `_exact_or_nothing(f)` is the catch the
  time doors share: `InexactError`, `OverflowError` and `DivideError`
  become `nothing`. `_declared_quantity` builds on it and refuses a value
  `Rational{Int}` cannot hold finitely as `ArgumentInvalid` `:range`, the
  call named. `Period`, `Hz` and `Absolute`'s offset go through it, so
  `Hz(0)` never builds. Their three docstrings state the refusal.
- **`src/assembly.jl`**, 1192 to 1204 and 1384. `_child_scope` takes the
  call's list and composes `K·m` and `c + φ·m` in checked `Int`. A result
  past `Int` is a `RatesViolation` `:range` at the declaring scope and the
  inner key, and the child continues at the enclosing timing. A rate its
  own check refused composes nothing.
- **`src/deployment.jl`**, 13 to 14, 33 to 36, 294 to 374 and 475 to 480. `_exact` is
  one method for an integer or a `Rational` of any integer type, refused as
  `:range` past `Rational{Int}`. `_prime_powers` stops at
  `PRIME_DIVISOR_CAP = 2^20`, under a condition that cannot wrap. In
  `bind_schedule` the grid report runs under the catch. A report that is
  `nothing` refuses `:derive` as `:range`, and leaves any other `Δt_base`
  to the anchor loop. The multiply-add is checked, and a schedule it cannot
  hold is the lattices' `Δt_base` `:range`. The `Deployment` docstring's
  keyword lines follow.
- **`src/store.jl`**, 183 to 200. `_instant` ends in `_nearest`, which
  keeps the plain division while both integers are within `2^53` and calls
  `_rounded_quotient` past it: a long division in `UInt128`, a chunk at a
  time until the quotient holds 55 bits, the remainder folded into the
  last bit, one rounding. `_set_origin!` writes boundary zero's clock as
  `_instant(clock, 0)`.
- **`src/linearize.jl`**, 274 to 275 and 305, and **`src/trim.jl`**, 596
  and 622.
  The scratch clocks of the `about` form and of both trim halves are set
  by `_set_origin!`. `_set_clock!` keeps the checkpoint form.
- **`src/diagnostics.jl`**, 749 to 765, 1357, 1397, 1435 and 2304.
  `RatesViolation` gains `:range`, with its message. `ArgumentInvalid`
  gains a `:range` arm for the three constructors, and `DeploymentInvalid`
  one for `:derive`. The time keywords' constraint reads "must be positive
  and finite in `Rational{Int}`". `_grid_block` prints a cofactor at or
  above the cap's square as unfactored.
- **`src/model.jl`**, 581 to 592. `_last_frame`'s comment restates why
  `2^50·δ` holds. No code changes.

## Measurements

All from the prototype's worktree, on Julia 1.13.3.

- The gate: 10 101 passed, 0 failed, in 9 min 48 s.
- A clock costs 2.56 ns on the fast path, from `7//3`, and 11.4 ns on the
  slow path, from the wall-clock origin `1.7631e9 + 0.123456` at `1//10`
  and at `1//1000`. Neither allocates.
- With `h_max = 1//40`, four steps a frame, from `7//3` and from that
  wall-clock origin: `sweep_1`, `sweep_2`, `rhs` and `ticks` allocate 0 B
  through `phase_bodies` at `Float64` and at `LinearizeDual`, and `frame!`
  allocates 0 B. A frame takes about 0.21 µs at `Float64`.
- The report's probes against the patch: G2 reads 0 of 10 000 frame tops
  off the nearest float where it read 8 000, G3 reads 0 of 1 000 where it
  read 1 000, and G4 reads 0 of 100 000 at each of four frames where it
  read 30 440, 21 638, 2 380 and 0. F2's checkpoint at boundary zero is
  taken. Every A to E probe refuses with a diagnostic or returns the exact
  value. C4 derives without delay and C5 terminates.
- No trajectory test moved. Two message pins moved, both in
  `test_diagnostics.jl`, for the constraint text.

## Readings the prototype took

The user ruled the four seams known beforehand, rulings 7 to 10. The
prototype took nine readings beyond them. The coordinator ruled each
overnight, as built, and none is ratified by the user yet. The notes give
each reason.

- R1. The unfactored cofactor is marked at rendering, by magnitude.
- R2. The `Deployment` door catches at each premise, so D-229 holds.
- R3. A divisor past `Int` after composition with its anchor is the
  lattices' `Δt_base` `:range`, not `:anchor_period`.
- R4. A grid report that leaves `Int` is no report. `:derive` refuses it,
  and any other `Δt_base` meets the anchor loop's refusal.
- R5. The constraint text names `Rational{Int}`.
- R6. A rate its own check refused composes nothing in the fold.
- R7. An offset that is not finite is refused at `Absolute`.
- R8. The slow path is the chunked division, 11 ns against 34 ns.
- R9. The scratch clocks go through `_set_origin!`.

## What the tests pin, by property

The mutants are the prototype's, each a fix reverted alone
(`mutate.py` and `mutants.log` in the session's scratchpad).

- `test_declare.jl`, "a value `Rational{Int}` cannot hold finitely is
  refused at its declaration door": the report's A1 to A5, `Hz(0)`, an
  infinite offset, and `Bool` and other integer types taken. Red under the
  door's catch dropped, its finiteness test dropped, `Hz` uncaught and
  `Absolute`'s offset unchecked.
- `test_discrete.jl`, "a divisor composed past `Int` is refused at the
  inner key": B1, B3 and B5, composition just inside `Int`, and one
  refusal for a rate already refused. Red under the unchecked fold and the
  dropped guard.
- `test_discrete.jl`, "a time quantity of any integer type is taken at its
  value": D1 to D3 and D5. Red under the uncaught keyword.
- `test_discrete.jl`, "a divisor composed with its anchor past `Int` is the
  lattices' refusal": B6. Red under the unchecked multiply-add.
- `test_discrete.jl`, "a pool whose attribution leaves `Int` admits no
  deployment": C1 to C5 on the explicit and the derive paths, and
  `_prime_powers` alone. Red under the uncaught report, the dropped derive
  branch and the dropped cap.
- `test_lattices.jl`, "the clock's division rounds once at every
  magnitude": about 16 000 signed quotients against a BigInt reference,
  the edges, and the plain division below `2^53`. Red under the plain
  division everywhere and the dropped sticky bit.
- `test_lattices.jl`, "from a wall-clock origin every frame top is the
  float nearest its instant": G2, G3, G4 with a checkpoint at boundary
  zero, and F1. Red under boundary zero written as `Float64(t₀)`.
- `test_lifecycle.jl`: the origin door's accepted forms and E4.
- `test_trim.jl` and `test_linearize.jl`: the scratch clocks from F1's
  origin. Red under each of the three call sites reverted.
- `test_diagnostics.jl`: the new occurrences and renderings, the
  unfactored cofactor among them. Red under the unmarked cofactor.

One mutant survives and is accepted: the wrapping condition
`divisor * divisor ≤ cofactor` with the cap kept. Under the cap the
divisor is at most `2^20`, so the square cannot wrap, and the two
conditions are equal. The condition that cannot wrap stays because ruling
3 asks for it.

## Routing

The code commit runs the routed subset under the gate's flags:
`declare discrete lattices lifecycle trim linearize diagnostics`. The
reviewer reads `code_map.md`'s entries for the eight source files above,
§10.5 and §9.2 by their outline, D-450 and D-454 to D-457 with the docs
commit's entries, and the notes.

## Bookkeeping

- `code_map.md`: the entries of the eight source files and of the test
  files the new testsets change, edited with the docs amendment and
  committed with the code.
- `pending.md`: the first bullet retires when the review's fixes land. A
  new unordered bullet takes the four things left out of scope.
- The docstrings of `Period`, `Hz`, `Absolute` and `Deployment` changed, so
  the docstring tools run before the code commit.

## Out of scope

Recorded on `pending.md`'s new unordered bullet:

- `Relative`'s constructor converts its arguments, so `Relative(big(2)^70)`
  raises a raw `InexactError` and `Relative(2.0, 0)` is taken as `K = 2`.
  `Relative` is not a time door.
- Replay's `to_time` check and `_frames_fit`, `_frames_to` and `_frame_at`
  convert the origin by `Float64(t₀)`. For a rational origin whose own
  parts pass `2^53`, that float can sit an ulp off boundary zero's clock.
- A composite cofactor's supplier list can be empty, since an entry may
  supply only one of its primes.
- `_origin` keeps its own `try` where `_exact_or_nothing` would serve.

The descriptor's JSON integers are the inspector's, on its own pending
list.

## The cold review

An open mind, probes outside the tree, and "empty is acceptable". Beyond
the gate on the Julia floor and the mutation check of each fix:

- **R4's argument.** `Deployment.grid` is a `GridReport`, so a deployment
  that passes the anchor loop with no report would raise a raw
  `MethodError`. Search for a pool whose `_grid_report` leaves `Int` and
  whose anchors an explicit or default `Δt_base` still accepts. The
  report's section 2.3 covers the gcd and the factor. The offset's
  neighbours, `floor(Int, τ / partial) * partial`, are the site it did not
  probe.
- **The division.** `_rounded_quotient` against an exact reference on
  shapes the tests do not draw: a divisor near `2^126`, a quotient of
  exactly 54 and 55 bits, exact halves, and the checked path the origin's
  door runs.
- **Bit-identity below `2^53`.** No trajectory from integers within
  `2^53` may move. The fast path's bounds are inclusive.
- **The doors.** Every input of the report's section 4 table at every
  door, for a raw error that still escapes.
- **The docs against the code.** Each sentence the docs commit changed,
  read against the patch.

Acceptable survivor: the wrapping condition under the cap, above.

## The review's record

# Exact arithmetic on the time surface, 2026-11-13

Increment 95 put the deployment's periods, its bound and the run's origin on
`Rational{Int}` (D-454, D-457). Since then, overflow has been met one site at
a time. On 2026-11-13 the user ruled that the switch to exact time stands,
and that its fallout is analyzed whole before the first adaptive backend.
This report is that analysis, as `pending.md` asks for it:

- every exact-arithmetic site from a declared rate to the trace header, the
  inputs that overflow it, and what it does then (sections 1 and 2);
- one policy for them (section 3);
- one rule for what the doors accept (section 4);
- the clock bounds the spec states, reconciled (section 5).

Section 6 lists what a ruling would decide. Nothing in `src/` or the spec
changes here.

Every claim marked with a probe label is measured at `1074792` on Julia
1.13.3. `probes.jl` beside this report reruns them all. Claims without a
label come from reading the code.

## Summary

**Overflow is not the only failure, nor the worst.** The fold composes
`Relative` multipliers in plain `Int`, which wraps silently. Two nested
`Relative(2^32 + 1)` compile to a divisor of `2^33 + 1`, and the build, the
deployment and the run all accept it (B1, B2). Other wraps give a divisor of
0, which fails at the first tick, or a negative one, which fails at the
`Deployment` (B3 to B6).

**The grid report has four faults, not one.** Its `gcd` and its
leave-one-out factor raise a raw `OverflowError` (C1 to C3). Its trial
division takes about a second on a 61-bit prime denominator (C4). Near
`2^63` the loop's `divisor * divisor` wraps negative, so one anchor at
`Period(1//(2^63 - 25))` hangs `Deployment` construction (C5). Each overflow
here marks a pool that admits no deployment at all. Section 2.3 shows why,
so the right answer is one refusal, not wider arithmetic.

**A wall-clock origin takes clocks that are not the nearest floats.** D-456
did not build a correctly rounded division past `2^53` because "no
practical origin" reaches those integers. A float origin near today's
`time()` reaches them at once. From such an origin at a 0.1 s frame, every
whole-second frame top reads one ulp below `t0 + s` (G3), the exact float a
user computes. About 30% of such origins also fail `checkpoint` at boundary
zero, which refuses them as `CheckpointMidFrame` (G4, F2). Boundary zero's
clock is `Float64(t₀)`, while the check computes it by `_instant`, and the
two formulas part.

**The doors disagree on four inputs.** A `BigInt` past `Int` raises a raw
`InexactError` at `Period`, `Absolute` and the `Deployment` keywords, and is
refused at the origin. `Rational{Int32}` and `Rational{BigInt}` are taken by
`Period` and the origin and refused by the `Deployment` keywords. `Hz(0)`
builds and then raises a raw `DivideError` at the `Deployment`. A `Float16`
differs only because of the float asymmetry that D-457 already ruled.

**Three stated bounds are stale.** "Within two ulps" (§10.5, D-456) is
exceeded: the measured worst is 2.35 ulps, and the error bound is under 3.
§10.5's "about `2⁻⁵²·(…)`" and "half the bound" describe the formula that
D-456 replaced. The clock's error is `1.5·2⁻⁵²·|t|` at most, so the `2⁵⁰·δ`
bound still holds, but it leaves a quarter of the gap, not half. The
`_last_frame` comment already says so.

**Recommended policy: wide where it runs once, refused where it is stored.**
Keep `Rational{Int}` as every stored type. Do each construction-time
computation in checked or `Int128` arithmetic. Refuse at the door whose
value cannot be stored. Make the clock's division correctly rounded past
`2^53`, on a slow path the common case never takes. Section 3 weighs this
against a bound on denominators and against a wider common type.

## 1. The sites

The time surface in the order the data flows. "Sound" means every input the
earlier doors admit is computed exactly or refused as a diagnostic.

| # | Site | Arithmetic | Inputs that break it | What happens | Probe |
|---|---|---|---|---|---|
| 1 | `Period(T)`, `declare.jl:392` | `Rational{Int}(T)` | `BigInt` or `Rational{BigInt}` past `Int` | raw `InexactError` | A1, A2 |
| 2 | `Hz(f)`, `declare.jl:410` | `1 // f` | `f = 0`; `f = typemin(Int)` | `Period(1//0)` accepted; raw `OverflowError` | A5, A4 |
| 3 | `Absolute(q, τ)`, `declare.jl:468` | `Rational{Int}(τ)` | `τ` past `Int` | raw `InexactError` | A3 |
| 4 | the structure step's checks, `assembly.jl:1153` | `T > 0`, `0 ≤ τ < T` | `T = 1//0` | passes; raw `DivideError` at `Deployment` | A6, A7 |
| 5 | the fold, `_child_scope`, `assembly.jl:1204` | `K·m`, `c + φ·m` in `Int` | a product of nested multipliers past `Int` | **silent wrap**: wrong divisor, 0, or negative | B1 to B5 |
| 6 | `bind_schedule`'s multiply-add, `deployment.jl:345` | `m·D_k`, `Φ_k + c·D_k` in `Int` | an anchor's divisor times a nested multiplier past `Int` | **silent wrap** | B6 |
| 7 | `_grid_report`, `deployment.jl:70` | `reduce(gcd, …)` over `Rational{Int}` | an `lcm` of the pool's denominators past `Int` | raw `OverflowError` | C1, C2 |
| 8 | `_grid_report`, `deployment.jl:77` | `partial / admissible` | a refinement factor past `Int` | raw `OverflowError` | C3 |
| 9 | `_grid_report`, `deployment.jl:87` | `floor(Int, τ / partial) * partial` | intermediate products past `Int` | raw `OverflowError` (not probed) | none |
| 10 | `_prime_powers`, `deployment.jl:33` | trial division to `√n` | a prime denominator near `2^62`; one past `isqrt(typemax(Int))²` | about 1 s; **no termination** | C4, C5 |
| 11 | the period door, `_exact`, `deployment.jl:13` | `Rational{Int}(value)` | `BigInt` past `Int`; `Rational` of another integer type | raw `InexactError`; `:not_a_quantity` | D1 to D3 |
| 12 | the anchor divisions, `deployment.jl:327` | `Int128` | none | sound, refused as `:anchor_period`, `:anchor_offset` | none |
| 13 | `_lattice`, `deployment.jl:221` | `Int128`, each factor checked | none | sound, refused as `:range` | none |
| 14 | the gate, `_next_due` and the frame loop, `executor.jl:481`, `model.jl:546`, `frame.jl:112` | `Int`, bounded by `max_frame` | a divisor of 0 or below from sites 5 and 6 | `DivideError` at the first tick | B4 |
| 15 | the origin door, `_origin`, `model.jl:370` | `Rational{Int}(t0)`, `_clock_integers` checked | none | sound, refused as `ArgumentInvalid` `:range` | E4, E6 |
| 16 | `_grid_integers`, `_set_origin!`, `store.jl:177` | `Int128` `lcm`, checked products | none | sound as an overflow guard | none |
| 17 | `_set_origin!`'s clock, `store.jl:186` | `Float64(t₀)` | an origin whose integers pass `2^53` | boundary zero's clock is not `_instant`'s | F1, F2, G4 |
| 18 | `_instant`, `store.jl:197` | `Float64(N) / Float64(D)`, `Int128` unchecked | integers past `2^53`, a wall-clock origin among them | clock up to 2.35 ulps off the nearest float | G1 to G3 |
| 19 | `_last_frame`, `_frames_to`, `_frames_fit`, `model.jl:570` | `Float64`, `ceil(Int, …)` after `_frames_fit` | none | sound | none |
| 20 | `restore!`'s `_check_grid!`, `model.jl:1214` | `_clock_integers` checked | none | sound for overflow, inherits site 17 | none |
| 21 | `ModelState.t₀`, the trace header, `checkpoint.jl:81`, `sim.jl:1198` | held and compared exact | none | sound | none |
| 22 | the descriptor's `_rational`, `descriptor.jl:137` | `num` and `den` as JSON integers | a part past `2^53` | the inspector's JS numbers round it; display only | none |
| 23 | `_hyperperiod`, `show.jl:155` | `BigInt` | none | sound, the one site already wide | none |

`linearize` and `trim!` take their origin through site 15 and set their
scratch clock through `_set_clock!` (`linearize.jl:345`), which writes
`Float64(t0)` as site 17 does.

## 2. What each site does

### 2.1 The declarations

`Period`, `Hz` and `Absolute` convert their argument to `Rational{Int}` at
construction, since that is their field type. The spec calls them plain data
carriers. Range checks belong to the structure step, and the one refusal of
their own is the float, "a normalization failure rather than a range check"
(`declare.jl:370`). A value that `Rational{Int}` cannot hold is the same
kind of failure, and today it escapes as a raw `InexactError` (A1 to A3) or
`OverflowError` (A4).

`Hz(0)` is `Period(1//0)`, an infinite period. Julia's `Rational{Int}`
represents it, the structure step's `T > 0` and `τ < T` both hold for it,
and the build succeeds (A6). The `Deployment` then raises a raw
`DivideError` (A7). The `Deployment` keywords refuse `1//0` as `:range` by
`isfinite` (D6), but the anchors never meet that check.

### 2.2 The fold and the schedule's multiply-add

§10.5 compiles a child declared `Relative(K, φ)` under a scope at `(D_s,
Φ_s)` to `D = K·D_s` and `Φ = Φ_s + φ·D_s`. The fold computes this in `Int`
(`assembly.jl:1204`), and Julia's `Int` multiply wraps without error. The
structure step checks each `K` and `φ` alone and never their composition.

- **A silent wrong schedule.** `Relative(2^32 + 1)` inside
  `Relative(2^32 + 1)` should tick every `2^64 + 2^33 + 1` base ticks. It
  compiles to `2^33 + 1` (B1), and a run takes its first frame with that
  divisor (B2). Nothing reports it.
- **A divisor of 0.** `Relative(2^32)` twice wraps to 0 (B3). The
  `Deployment` accepts it, and the first tick raises a `DivideError` from
  the gate's `(tick − Φ) % D`, reported as a `StepError` that names the
  component (B4).
- **A negative divisor.** `Relative(3)` over `Relative(2^62)` wraps negative,
  and `_lattice` raises a raw `InexactError` as it converts its results to
  `Int` (B5).

`bind_schedule` composes once more, against each anchor's divisor
(`deployment.jl:345`). An anchor of `2^40` s over a base tick of `2^-20` s
has a divisor of `2^60`. A `Relative(2^30)` under it wraps to 0 (B6).

The inputs are extreme. A divisor past `2^63` base ticks is a period of
centuries at any practical grid. But the failure is the one D-457 rejected
for the clock, "unchecked `Int128` arithmetic wraps in silence", here in
`Int` and at build time, where a check costs nothing.

### 2.3 The grid report

`_grid_report` runs for every deployment whose tree has an anchor, ahead of
the `Δt_base` branch, so an explicit `Δt_base` meets it too.

**The `gcd` (site 7).** Julia's `gcd` of two rationals is
`gcd(numerators) // lcm(denominators)`, and `lcm` is checked. Two anchors at
`1//(2^40 + 1)` and `1//(2^40 + 3)` raise `OverflowError` (C1), with or
without `:derive` (C2).

**The factor (site 8).** `Absolute(Period(2^40), 1//(2^23 + 1))` has a pool
gcd of `1//(2^23 + 1)`. The offset's leave-one-out factor is
`2^40·(2^23 + 1)`, past `Int`, and the division raises `OverflowError`
(C3). `GridEntry.factor` is an `Int` and could not hold it anyway.

**Every overflow here marks a pool that admits no deployment.** A base tick
must divide every pool entry, so it divides the pool's gcd `a/b`. A divisor
of `a/b` is `a/(b·m)` for some whole `m`, whose reduced denominator is at
least `b`. So when `b` leaves `Int`, no `Rational{Int}` base tick exists. A
factor works the same way. For an entry `p`, the factor is
`gcd(pool ∖ p) / gcd(pool)`. That quotient is at most the largest period
over `gcd(pool)`, which is the largest anchor divisor at the coarsest
admissible grid. When the factor leaves `Int`, every admissible base tick
gives some anchor a count of base ticks past `Int`, which the anchor loop
refuses. In both cases the report crashes on a deployment that the
constructor would refuse anyway. It should instead say why the pool cannot
be deployed.

`Int128` with an early exit suffices. Fold the gcd one entry at a time and
stop when the running denominator passes `typemax(Int)`. Each step is an
`lcm` of two values below `2^63`, which fits `Int128`. Under the same exit
the factors and the alternatives' quotients are bounded by the largest
anchor divisor, so they fit `Int128` as well.

**The trial division (site 10).** `_prime_powers` factors the pool's
denominator by trial division up to its square root. A prime denominator
near `2^61` costs about 0.9 s at `Deployment` construction (C4), since the
attribution runs on the success path. Past `isqrt(typemax(Int))`, about
`3.04·10^9`, the loop condition `divisor * divisor ≤ cofactor` wraps
negative and stays true. One anchor at `Period(1//(2^63 - 25))`, the largest
prime below `2^63`, hangs `Deployment` past a 200 s timer (C5). The
condition `divisor ≤ cofactor ÷ divisor` cannot wrap, and a cap on the
divisor bounds the cost. The cofactor left above the cap is then reported
whole. The attribution names which entries supply a prime power, and a cap
of `2^20` covers every denominator a decimal or binary rate produces.

### 2.4 The period door

`_exact` (`deployment.jl:13`) takes `Rational{Int}`, any `Integer` and a
`Period`, and refuses a float as `:inexact` and anything else as
`:not_a_quantity`. Three gaps:

- A `BigInt` past `Int` takes the `Integer` method, and
  `Rational{Int}(value)` raises a raw `InexactError` (D1).
- A `Rational{BigInt}` or `Rational{Int32}` is refused as
  `:not_a_quantity` (D2, D3), though `Period` and the origin take both.
- `true` is an `Integer`, so `Δt_frame = true` deploys a 1 s frame (D5). The
  origin takes it alike (E5). Julia treats `Bool` as an integer, and nothing
  breaks.

### 2.5 The lattice and the loop

Sites 12, 13, 14 and 19 are sound for every input the earlier doors admit.
The anchor divisions and `_lattice` run in `Int128`, check each factor
against `Int`, and refuse as their parameter. The loop's positions,
`_next_due`'s indices and the step counts stay below `max_frame`'s margin,
which `_lattice` sized. Site 14 assumes each schedule row has `D ≥ 1`. The
structure step guarantees that for each `K`, and sites 5 and 6 break it.

### 2.6 The origin and boundary zero

The origin door (site 15) is sound. It catches `InexactError`,
`OverflowError` and `DivideError` from the conversion and from the checked
clock formula at the run's two ends, and refuses them as `ArgumentInvalid`
`:range` (E4, E6).

**Boundary zero's clock uses a second formula (site 17).** `_set_origin!`
writes the clock as `Float64(t₀)`. Every later clock, and the frame-top test
in `checkpoint`, `overlay!` and `restore!`, computes the instant as
`_instant(origin, unit, scale, position)`. When the integers pass `2^53` the
two can part by an ulp. D-456 already records that Julia 1.13's
`Float64(::Rational)` divides the two converted integers.

- From `t₀ = 684943219091290305//514823562239077262`, `Float64(t₀)` is
  `1.3304426396342983`, while `_instant` at frame 0 and the nearest float
  are both `1.330442639634298` (F1). `checkpoint` right after `init!`
  refuses the model as `CheckpointMidFrame` (F2).
- **A wall-clock float origin meets this in practice.** A float near `1.7e9`
  has an ulp of `2^-22`, so its integer over a 0.1 s lattice is about
  `5·2^53`. `Float64(t₀)` is exact, since a float origin's parts fit 53
  bits, but `_instant` at frame 0 rounds its numerator. Over 100 000 random
  origins in `[1.7e9, 1.8e9)`, frame 0 reads a float other than `t0` for
  30 440 at `Δt_frame = 1//10`, 21 638 at `1//100` and 2 380 at `1//1000`
  (G4). `checkpoint` and `overlay!` refuse each of those models at boundary
  zero. At `1//1024` the denominators are powers of two and none parts.

`trim!` and `linearize` set their scratch clock through `_set_clock!`, which
also writes `Float64(t0)`. A search's time then differs from the time its
commit runs at by the same ulp.

### 2.7 The clock past 2^53

`_instant` (site 18) is the float nearest the instant while both integers
stay below `2^53`. Past that it rounds three times: each conversion and the
division. The error is then below `1.5·2⁻⁵²·|t|`, which is less than 3 ulps
of `t`. Over a million quotients just below 2, where an ulp is smallest
against `t`, the worst was 2.35 ulps, and 380 passed two (G1).

D-456 rejected "a correctly rounded division for every magnitude" because it
costs "a big division per boundary for integers no practical origin
reaches". The wall-clock origin is D-457's own motivating case, and it
reaches them:

- From `t0 = 1.763100000123456e9` at a 0.1 s frame, 8 000 of the first
  10 000 frame tops are not the nearest float (G2).
- Every one of the 1 000 whole-second frame tops reads one ulp below
  `t0 + s` (G3). `t0 + s` is exactly representable, and it is the float a
  user computes for an event time. This is D-456's own failure at
  `Δt_frame = 3//10` again: `Step(t_step = t0 + 5.0)` fires off its boundary.

The fix can avoid both costs that D-456 named. The common case keeps its
one division behind a branch on the two magnitudes. The slow path needs no
`BigInt`. It is a long division in `UInt128` that shifts the numerator so
the quotient carries 55 bits, then folds the remainder into a sticky bit
before one rounding. Once boundary zero takes its clock from `_instant` as
well, one formula writes every exact instant, and that formula is the
nearest float. The brief would size the slow path and measure it, since a
wall-clock run takes it at every boundary.

### 2.8 The checkpoint, the trace header and the descriptor

`ModelState.t₀` and the trace header hold the origin as a `Rational{Int}`
and compare it exactly (D-457). They do no arithmetic of their own.
`restore!` runs a hand-built state's origin through the door's check (site
20), so it inherits site 17 and nothing else.

The descriptor writes each anchor's `T` and `τ` as JSON integers `num` and
`den` (`descriptor.jl:137`). The inspector reads them into JavaScript
numbers (`RedstoneInspector.jl/frontend/src/lib/analysis.ts:88`), which are
exact only below `2^53`. A period of `1//(2^61 - 1)` prints rounded there.
This is display only and belongs to the inspector's work order. The
descriptor also carries each scope's `(anchor, m, c)` timing, so a wrapped
fold (section 2.2) is exported wrong as well.

## 3. One policy

Three policies were weighed. Each keeps the loop's arithmetic unchecked and
guarded at the doors, as D-457 ruled.

**A. Wide where it runs once, refused where it is stored.** Every stored
type stays `Rational{Int}` or `Int`: `Period.T`, the anchor, the `Timing`,
the deployment's three quantities, the schedule's `D` and `Φ`, the
`Lattice` and the origin. Each computation outside the loop runs in checked
`Int` or in `Int128`, where a bound proves `Int128` enough. A result that a
stored type cannot hold is refused by the door that would store it. The
grid report, the fold and the multiply-add join the anchor divisions and
`_lattice`, which already work this way.

- Cost: a handful of checked or `Int128` operations per build and per
  deployment. No `BigInt` is needed anywhere on the time surface except
  `show`'s hyperperiod, which already has one.
- It closes sites 1 to 11 and 14 with one refusal each (section 4) and
  leaves the stored types and D-454's comparison unchanged.

**B. `Rational{Int}` kept, and a bound on numerators and denominators
refused at the declaration doors.** For example, every part below `2^31`.

- A bound on each value does not bound the composites. The pool's `lcm`
  grows with the number of anchors, and the fold's divisor with the depth of
  the tree. Two coprime denominators near `2^31` bring the `lcm` near
  `2^62`, and three pass `Int`. B still needs checks at the pool and the fold, so it does
  everything A does and adds a ceiling of its own.
- A user meets that ceiling as a rule with no reason in the model.
  `1//(10^10)`, a 0.1 ns grid, would be refused under `2^31`.

**C. A wider common type, `Rational{Int128}` at rest.**

- The thresholds move, but the pool and the fold still grow without bound.
  The clock's integers would need `Int256`, which Julia lacks.
- It changes D-454's stored and printed type, and the type of every
  `Period`, for inputs no practical model reaches.

**Recommendation: A.** Every overflow found turned out to be either a pool
or schedule that no deployment can hold (sections 2.2, 2.3), or a declared
value that `Rational{Int}` cannot hold (section 2.1). Both are refusals.
Wider types would only defer them. The clock's rounding past `2^53` (section
2.7) is not an overflow, but it is exact arithmetic on the time surface and
falls under the same policy. The slow path computes exactly in `Int128` and
rounds once.

**What may still escape under A.** These are named so the ruling can state
them:

- `MethodError` for an argument of no accepted type, such as `Period(π)`.
  This is Julia's dispatch, as for any constructor.
- `InternalInvariant` from `_grid_report`'s check that each factor is whole,
  which stays an invariant.
- Nothing else on the time surface, given section 4's door rule.

## 4. One rule for the doors

The doors are `Period`, `Hz` and `Absolute`, the structure step's rate
checks, the `Deployment` keywords `Δt_frame`, `Δt_base` and `h_max`, and
the origin's `t0` at `init!`, `trim!` and `linearize`. The roadmap's
increment 4 adds `h_min` beside `h_max`. Today:

| Input | `Period`, `Absolute` | `Deployment` keywords | the origin's `t0` |
|---|---|---|---|
| `Rational{Int}`, `Int` | taken | taken | taken |
| another integer type, value fits | taken | taken | taken |
| `Rational` of another integer type, value fits | taken | `:not_a_quantity` | taken |
| any integer or `Rational`, value past `Int` | raw `InexactError` | raw `InexactError` or `:not_a_quantity` | `:range` |
| `1//0` | taken (`Hz(0)`) | `:range` | `:range` |
| a float | `:inexact` | `:inexact` | taken at its exact value, else `:range` |
| `Bool` | taken as 0 or 1 s | taken | taken |

**The proposed rule.** A time quantity is a `Period`, an integer of any type
or a `Rational` of any integer type, whose value `Rational{Int}` holds
finitely. A float is refused at every period door and taken at its exact
value by the origin, as D-457 ruled. A value that `Rational{Int}` cannot
hold is refused by its door's own diagnostic:

- `Period`, `Hz` and `Absolute`: `ArgumentInvalid` `:range`, beside the
  float's `:inexact`. This is a normalization failure, the one kind of check
  the spec lets the constructors make.
- The structure step: `RatesViolation` `:period` for an infinite `T`, and a
  new reason for a composed divisor or phase past `Int`, naming the path.
- The `Deployment` keywords: `DeploymentInvalid` `:range`, as for `1//0`
  today.
- The schedule: `DeploymentInvalid` on `Δt_base`, for a pool that admits no
  `Rational{Int}` base tick and for a component divisor past `Int` after
  composition with its anchor. Both name the anchors, as `:anchor_period`
  does.
- The origin: unchanged.

`Float16` needs no change. Its difference between the doors is the float
asymmetry D-457 ruled. `Bool` can stay, since nothing breaks. Refusing it
everywhere is a one-line check per door if the ruling prefers that.

## 5. The bounds the spec states, reconciled

Four statements cover the clock's error and the run's reach. They were
written against two different clock formulas.

| Statement | Where | Says | Holds? |
|---|---|---|---|
| nearest below `2^53` | §10.5, D-456, `store.jl:193` | exactly the nearest float while both integers stay below `2^53` | yes |
| two ulps beyond | §10.5, D-456, `store.jl:193` | within two ulps of it beyond | **no**: 2.35 ulps measured, bound below 3 (G1) |
| the loop's error | §10.5 | each clock within about `2⁻⁵²·(\|t₀\| + 2·(t − t₀))` | **understated**: the bound is `1.5·2⁻⁵²·\|t\|`; `model.jl:584` says 1.5 and records 1.34 measured |
| the margin | §10.5 | `2⁵⁰·δ` is "half the bound at which the two errors could close the gap" | **no**: under 1.5 the two errors close at most three quarters of the gap, as `model.jl:590` says |
| D-450's derivation | D-450's rationale | `u·\|t₀\| + 3u·ε` for `t₀ + m·P`, `2u·\|t₀\| + 4u·ε` for a step end, so `\|t₀\| + 2ε < 2^51·δ`, halved | superseded: D-456 replaced both formulas with `_instant` |
| the door's two ends | D-457, `model.jl:394` | checked arithmetic at the origin and one frame past the last frame bounds every value the loop forms | yes, for the fixed-step lattice; a proposing backend forms no `_instant` inside a span (D-455), so it stays true at increment 4 |

**The reconciled statement.** Under D-456's formula each clock errs by at
most `3u·|t|` with `u = 2⁻⁵³`, and `|t| ≤ |t₀| + 2·(t − t₀)`. Two clocks
keep their order while `6u·(|t₀| + 2ε) < δ`, which is
`|t₀| + 2ε < (2⁵³/6)·δ ≈ 1.33·2⁵⁰·δ`. **D-450's bound of `2⁵⁰·δ` holds.**
The threshold sits a third above it, where §10.5 says twice it. D-450 reports no disordered clock in
about 47 000 boundaries just inside the bound, and that evidence stands.

If the ruling adopts the correctly rounded division (section 2.7), every
clock errs by at most `u·|t|`. The ordering condition becomes
`|t₀| + 2ε < 2⁵²·δ`, and `2⁵⁰·δ` keeps a factor of 4. The bound could then
stay as it is, with its rationale restated, or be relaxed. Keeping it costs
nothing, and relaxing it gains a run four times longer at the extreme.

The spec edits either way:

- §10.5, "within two ulps of it beyond": the nearest float at every
  magnitude, or "within three ulps" if the division stays as it is.
- §10.5, the loop's error and "half the bound": restated from `_instant`'s
  error, as above.
- D-450 and D-456: an annotation each, pointing to the ruling that replaces
  their numbers.

## 6. What a ruling would decide

In the order a brief would take them:

1. **The policy**: A, B or C (section 3). Recommended: A.
2. **The clock**: a correctly rounded division past `2^53` with boundary
   zero written by `_instant` (recommended), or boundary zero alone moved to
   `_instant` with the spec's two-ulps statement corrected to three. The
   second option fixes G4's `checkpoint` refusal but leaves G3, so an event
   typed at `t0 + 5.0` from a wall-clock origin still fires off its
   boundary.
3. **The door rule** (section 4), with its new reasons: one for the
   structure step's composed divisor, and one for the schedule's pool with
   no base tick, or a reuse of `:anchor_period`.
4. **The grid report's trial division**: the non-wrapping condition and a
   cap of `2^20`, with the cofactor above it reported whole.
5. **`Bool`**: kept, or refused at every door.
6. **The spec's bounds** (section 5), worded to the clock the ruling picks.

**The build's reach**, for scale. `declare.jl` adds three refusals,
`assembly.jl` adds checked composition with a new reason, and
`deployment.jl` gets `_exact`, the multiply-add and `_grid_report` in
`Int128` with its refusal, plus `_prime_powers`. `store.jl` gets
`_instant`'s slow path, and `_set_origin!` and `_set_clock!` take their
clock from it. `diagnostics.jl` gets the new reasons' messages. Each probe
in `probes.jl` becomes a test. No loop code changes beyond `_instant`.
Every trajectory from an origin whose integers stay below `2^53` stays
bit-identical, since the fast path is today's division. Trajectories from
origins past `2^53`, wall-clock floats among them, move by an ulp at the
clocks that change, and so does the step length each clock sets (D-455).

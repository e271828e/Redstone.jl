# Embedded pairs beside BS3, 2026-11-16

`BS3` is the one adaptive backend (§10.2, D-461). The roadmap of the
variable-step arc lists two later options: Dormand–Prince 5(4), and the
three-stage 3(2) pair on `BS3`'s first three stages. This report asks which
embedded pairs suit the framework's cost model, and checks two of them on
paper against `BS3`:

- the three-stage 3(2) pair, which D-461 measured and kept for later;
- Zonneveld's 4(3) pair, which is RK4 with a fifth stage for the estimate.

The work is algebra alone. It proves each pair's order conditions in
rational arithmetic, sizes each estimate's error terms, and analyzes step
control on a stiff mode. Nothing was run through a `Model`. Section 7 plans
the measurements a later run would make. Nothing in `src/` or the spec
changes here.

`pairs_algebra.jl` and `pairs_stiff_check.jl` beside this report rerun every
figure of sections 3 to 5, on Julia 1.13.3 with no package loaded. Section 2
comes from reading the code at `a6b5da5`.

## Summary

**The refusal to reuse the last stage costs little by itself.** The fresh
first stage (D-447) already gives every method a first stage without a
sweep. What a pair with a stage at the step's end pays here is that stage's
sweep, which the boundary repeats. `BS3` pays three sweeps per quiet step
where a three-stage pair pays two.

**All three pairs are valid.** Each solution has exactly its claimed order.
Each estimate cancels every term below its leading order and is blind to no
leading term.

**The three-stage pair's step control is unstable on a stiff mode under the
integral gain alone.** At the stability limit the step swings between 0.83
and 1.37 of the limit, and about a fifth of the attempts are rejected.
Proportional-integral control removes the swing. D-461 uses the integral
gain alone after every notice and every rejection, and a tick raises a
notice, so a closed loop with a stiff mode is exposed. The probe of D-461
could not show this: its van der Pol case was limited by accuracy, not by
stability.

**`BS3`'s fourth stage is what keeps its step control stable.** The stage
adds the `z⁴` term to the estimate on a linear mode. So the stage is not
overhead alone. Zonneveld's fifth stage does the same.

**Zonneveld 4(3) is a candidate for a tight tolerance.** It is valid, its
step control is stable under both controllers, and the generic cubic
Hermite serves it, so D-018 stands. Its estimate is conservative, and its
next term is somewhat larger against its leading one than `BS3`'s. Only
measurements can say whether it earns a place.

**Nothing is recommended for building now.** No use case asks for a second
adaptive backend. This report qualifies the roadmap's later options and
leaves a plan.

## 1. Which pairs lose nothing to the framework

A pair is "first same as last" when its last stage is the derivative at the
step's end, taken at the new solution. A conventional solver keeps that
stage as the next step's first, so it costs nothing, and the designer
spends it on the error estimate. `BS3`, Dormand–Prince 5(4) and Tsitouras
5(4) are of this kind.

D-461 refused that reuse. A boundary may move the state or the table
between two steps, and a stale first stage would be a silent error. The
pairs below have no stage at the step's end, so the refusal takes nothing
from them.

| Pair | Order | Stages | The estimate costs |
|---|---|---|---|
| Heun–Euler 2(1) | 2 | 2 | nothing |
| Three-stage 3(2) | 3 | 3 | nothing |
| Zonneveld 4(3) | 4 | 5 | one stage |
| Fehlberg 4(5), Cash–Karp 5(4) | 5 | 6 | nothing |

The fifth-order pairs need a `dense!` of their own (D-018), and neither
carries a matched interpolant as Dormand–Prince does. The tableaus of this
table other than the two analyzed below are named from memory and were not
checked.

## 2. The cost count

An evaluation has two parts: the sweep over the signal table, and the
`x_deriv` block. On a quiet step the first stage runs the block alone,
since the boundary's sweep ran at the same point (D-447). Every later stage
pays both. Per accepted quiet step, inside the stepper:

| Method | Sweeps | `x_deriv` blocks |
|---|---|---|
| `RK4` | 3 | 4 |
| `BS3` as built | 3 | 4 |
| `BS3` under strict reuse of the last stage | 3 | 3 |
| Three-stage 3(2) | 2 | 3 |
| Zonneveld 4(3) | 4 | 5 |
| Dormand–Prince or Tsitouras 5(4) | 6 | 7 |
| A six-stage 5(4) pair | 5 | 6 |

The two `BS3` rows are D-461's. The others follow by the same count and
were not measured. The boundary's own sweep comes on top for every method.

Strict reuse would save `BS3` one block and no sweep. Its last stage sweeps
at the step's end, and the boundary then sweeps there again. So the stage
at the step's end costs a full sweep that the framework cannot recover,
whatever it rules on reuse.

## 3. The pairs and their validity

All three are explicit, with the solution weights `b` and the estimate
`h·Σ eᵢkᵢ`.

**`BS3` as shipped.** Nodes `c = (0, 1/2, 3/4, 1)`, `a₂₁ = 1/2`,
`a₃₂ = 3/4`, the fourth row `(2/9, 1/3, 4/9)`, `b = (2/9, 1/3, 4/9, 0)` and
`e = (−5/72, 1/12, 1/9, −1/8)`.

**The three-stage pair.** `BS3`'s first three stages, which are Ralston's
third-order method, with `e = s·(1, −3, 2)`. The estimate is unique up to
the scale `s` (D-461). The analysis runs at `s = 1`. The probe of D-461 ran
`s` from 1/9 to 4/9.

**Zonneveld 4(3).** Nodes `c = (0, 1/2, 1/2, 1, 3/4)`. The first four
stages are classical RK4. The fifth row is `(5/32, 7/32, 13/32, −1/32)`.
`b = (1/6, 1/3, 1/3, 1/6, 0)`, and the embedded third-order weights are
`b̂ = (−1/2, 7/3, 7/3, 13/6, −16/3)`, so `e = (2/3, −2, −2, −2, 16/3)`. The
tableau was recalled from memory. The checks below prove that it is a valid
4(3) pair. Whether it matches the published one digit for digit needs a
look at Hairer, Nørsett and Wanner's first volume, and affects only the
name.

A method has order `p` when its coefficients satisfy one polynomial
condition per rooted tree of up to `p` nodes: 1, 1, 2 and 4 trees at orders
1 to 4. `pairs_algebra.jl` generates the trees through order 6 and checks
three claims exactly:

1. `b` satisfies every condition through order `p`, and fails one at
   `p + 1`.
2. `e` cancels every term below order `p`, so the estimate is `O(hᵖ)`.
3. `e` cancels no term of order `p`, so the estimate sees every kind of
   leading error.

All three pairs pass. The script reproduces classical RK4's textbook
principal error, `1.45e-2`, as a check of its own.

The leading term of each estimate, per tree and divided by the tree's
symmetry:

| Pair | Leading terms | Reading |
|---|---|---|
| `BS3` | `(−1/48, −1/48)` | `−h³x‴/48`, an eighth of the solution's third Taylor term |
| Three-stage, `s = 1` | `(3/16, 3/4)` | weighs the second tree four times the first |
| Zonneveld | `(−1/24, −1/8, −1/24, −1/24)` | `−h⁴x⁗/24`, the solution's whole fourth Taylor term |

`BS3`'s and Zonneveld's leading terms are a Taylor term of the solution, so
they weigh every kind of error as the solution does. The three-stage pair's
is not.

## 4. The size of the error terms

Norms are Euclidean over the trees of one order, in units where every
elementary differential is 1.

| | `BS3` | Three-stage | Zonneveld |
|---|---|---|---|
| Principal error of the solution | 4.18e-2 | 4.18e-2 | 1.45e-2 |
| Estimate's next term over its leading term | 1.38 | 0.77 | 1.77 |
| The term after, over the leading term | 1.24 | 0.38 | 1.90 |
| Estimate's leading term over the principal error | 0.71 | 18.5·s | 9.95 |
| `Σ│eᵢ│` | 0.39 | 6·s | 12 |

- **Dominance of the leading term.** The three-stage estimate is the
  cleanest and Zonneveld's the least clean. The three figures are of one
  size, so none is disqualified.
- **Conservatism.** The last ratio, divided by `h`, is how far the estimate
  overstates the solution's true local error. At one step Zonneveld
  overstates about 14 times more than `BS3`. A tolerance therefore means a
  smaller error under Zonneveld. The three-stage pair matches `BS3`'s ratio
  near `s = 1/26`. The probe of D-461 inferred 1/18 from its runs.
- **Consequence.** Pairs compare at equal achieved error, never at equal
  tolerance.

## 5. Step control on a stiff mode

On a mode `ẋ = λx` one step multiplies the state by `R(z)` and the estimate
is `E(z)·x`, with `z = hλ`:

| Pair | `R(z)` | `E(z)` | Limit, real axis | Limit, imaginary axis |
|---|---|---|---|---|
| `BS3` | `1 + z + z²/2 + z³/6` | `−z³/48 − z⁴/48` | 2.513 | 1.732 |
| Three-stage | the same | `(3/4)·s·z³` | 2.513 | 1.732 |
| Zonneveld | `1 + z + z²/2 + z³/6 + z⁴/24` | `−z⁴/24 − z⁵/24` | 2.785 | 2.828 |

When a fast mode limits the step, the controller settles `z` on the
stability limit, where `│R(z)│ = 1`. Hall's analysis linearizes the pair
(state, step) there. Its spectral radius says whether a disturbance of the
step dies out, below 1, or grows, above 1. With `u = Re(zR′/R)`,
`v = Re(zE′/E)` and the controller's exponents at the order `k = p`
(D-461):

| | `BS3` | Three-stage | Zonneveld |
|---|---|---|---|
| `u`, `v` at the real-axis limit | 4.13, 4.66 | 4.13, 3.00 | 4.20, 5.56 |
| Radius, integral gain alone | 0.91 | **1.17** | 0.81 |
| Radius, proportional-integral | 0.66 | 0.78 | 0.73 |

The three-stage pair's `E` is a single power, so `v = p` exactly, and the
radius under the integral gain is `√(u/p)`. That holds for any pair whose
estimate uses no stage beyond the solution's, whatever its scale.

`pairs_stiff_check.jl` simulates the test equation with the accept and
reject rule, `λ = −1000`, a tolerance of `1e-6` and 4000 accepted steps:

| | `−hλ` over the last 1000 steps | Rejected attempts |
|---|---|---|
| `BS3`, integral gain alone | 2.513 | 5 |
| `BS3`, proportional-integral | 2.513 | 1 |
| Three-stage, integral gain alone | 2.08 to 3.43 | 1061 |
| Three-stage, `s = 1/26`, integral gain alone | 2.08 to 3.43 | 1118 |
| Three-stage, proportional-integral | 2.513 | 3 |
| Zonneveld, integral gain alone | 2.785 | 1 |
| Zonneveld, proportional-integral | 2.785 | 1 |

The simulation agrees with the analysis in every row.

**What it means here.** D-461's controller proposes by the integral gain
alone when it has no history, and a notice clears the history. A tick, a
handler and a writing drain each raise a notice (§10.2). A rejection also
proposes by the integral gain alone. In a closed loop a notice arrives at
every due instant, so the first step of every span has no history. A stiff
mode that needs several steps a span would then cost the three-stage pair
rejections that `BS3` does not pay.

**Limits.** This is a scalar linear equation, and the simulation keeps the
scale constant. A real model mixes modes, and the scale
`max(│xₙ│, │xₙ₊₁│)` moves with the state. The size of the effect in a
model is not known until it is measured.

The probe of D-461 ran van der Pol at `μ = 5` and counted 7 to 21
rejections per run for the three-stage pair (`pair_97/k6_vdp.out`). Those
runs were limited by accuracy, and they had no ticks, so they never sat on
the stability limit.

## 6. Where each pair stands

- **`BS3`.** Its fourth stage costs a sweep and buys a stable step control
  and a balanced estimate. The choice of D-461 looks better after this
  analysis than its evaluation counts alone suggested.
- **The three-stage pair.** Valid, with the cleanest estimate, and cheaper
  per step. Its weakness is section 5's. It stays a later option, with a
  stiff closed loop as the case to measure before any ruling.
- **Zonneveld 4(3).** Valid and stable. It costs four sweeps a step against
  six for Dormand–Prince. Tightening the tolerance by `10⁶` costs it about
  32 times more steps, against 100 for `BS3` and 16 for a 5(4) pair. It
  needs no interpolant of its own, since the generic cubic Hermite serves a
  method of order 4 (D-018). At equal steps its solution is RK4's. Its
  estimator is little studied, which is what the measurements are for.
- **Dormand–Prince 5(4).** Not analyzed here. By section 2 it pays seven
  blocks and six sweeps a step. Its seventh stage also feeds its
  interpolant, which a fifth-order backend needs anyway.

## 7. A plan for the measurements

None of this was run. It is what a later probe would do, in a scratch
worktree with a prototype stepper for each pair.

**Tests of the estimator**, on a harness that takes single steps:

- The estimate's order: steps of `h`, `h/2`, `h/4` on a smooth problem,
  with the slope `p` expected.
- Asymptotic correctness: the estimate over the true local error of the
  lower-order solution tends to 1.
- Three problem classes, since each excites different trees: a quadrature
  `ẋ = f(t)`, a linear autonomous system, and a nonlinear system that
  depends on time.
- Deceived steps under control: accepted steps whose true local error
  exceeds the estimate.
- A kink inside a step, such as a lookup table's knot. The estimate must
  reject or shrink, since nothing else flags a kink.

**The benchmark** is a work–precision diagram: achieved global error
against cost, one point per tolerance from `1e-3` to `1e-10`, compared at
equal error.

- Cost is counted through the `Model`, as sweeps and `x_deriv` blocks
  apart, with wall time beside them.
- Each pair's controller takes its exponents at its own order, `k = 4` for
  Zonneveld.
- The harness first reproduces `BS3`'s known figures.
- The problems: Kepler at an eccentricity of 0.9; van der Pol; the
  rigid-body Euler equations, for their published figures; the example
  closed loop, where ticks cap the step; a model with a table kink; a
  model with events, scored on the error of the crossing time; and a stiff
  mode under ticks, with the rejections counted.

The first two problems and the closed loop repeat the probe of D-461. Its
files are under `pair_97/`.

## Files

- `pairs_algebra.jl`: the trees, the three tableaus and every figure of
  sections 3 to 5 but the simulation. Run with `julia pairs_algebra.jl`.
- `pairs_stiff_check.jl`: section 5's simulation.
- `pair_97/`: a copy of the probe behind D-461's ruling on the three-stage
  pair, taken from its session's scratch folder before a reboot could
  delete it. It holds that probe's `report.md`, `notes.txt`, scripts and
  outputs, unedited, so its file list still names the scratch folder. The
  scripts ran on a frozen copy of increment 97's prototype, named by the
  `WT` variable, and may need adapting to the tree as landed.

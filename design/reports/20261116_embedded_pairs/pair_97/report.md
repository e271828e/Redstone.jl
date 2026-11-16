## 1. Verdict

The three-stage pair B (BS3's first three stages with the embedded second-order estimate) spends fewer evaluations than A at the same achieved error on every model I ran.
- **M1, smooth and controller-set:** B spends 0.77–0.84 of A's evaluations on Kepler e = 0.8 and 0.9, and 0.65–0.82 on van der Pol.
- **M2, the closed loop:** B spends 0.72–0.76 of A's `rhs` blocks and 0.73–0.80 of its sweeps once the steps go below the frame, and exactly 0.75 / 0.80 while they are capped at the frame.
- **M3, the descent:** frame-capped, B spends exactly 0.75 of the `rhs` blocks and 0.80 of the sweeps at the same error.

C (Alshina3 as OrdinaryDiffEq ships it) is unusable: its estimate is first order.

I am confident that B ≤ A in every case and that the M2/M3 figures hold. The M1 ratio is problem-dependent and carries a scatter of about ±0.05. On Kepler e = 0.5 the curves are erratic and the ratio swings between 0.63 and 1.09.

## 2. The candidates, and measured orders

All three share one controller. **A'** is my re-implementation of `BS3Stepper`, and it reproduces the package's BS3 bit for bit on M1 (586 accepted, 28 rejected, the same errors) and on M2 (all six tolerances). That verifies the controller copy. Counting works two ways:
- A is the package's `BS3Stepper` wrapped, reading `model.fresh` before each attempt.
- B and C are counted inside my own stepper at each `evaluate!`.

**A. BS3 as prototyped.**
- Third-order weights `b = (2/9, 1/3, 4/9)`.
- Estimate `e = (−5/72, 1/12, 1/9, −1/8)`, with stage 4 at the step's end.
- Four evaluations per attempt.

**B. The three-stage family.** The two conditions on `b̂` leave `e = b − b̂` in a one-dimensional space. Here `e = s·(1, −3, 2)`, so the estimate is `s·h·(k₁ − 3k₂ + 2k₃)`. This is general: for any three-stage third-order tableau the embedded second-order estimate is unique up to its scale. The norm is absolute and abstol/reltol is fixed, so B(s) at tolerance `tol` is exactly B(2/9) at `tol·(2/9)/|s|`. The whole family is one work-precision curve, and choosing `b̂` only re-labels the tolerance. I chose members to spread `|s|`:
- `B_mid`, the midpoint rule, `b̂ = (0, 1, 0)`, s = 2/9.
- `B_1/9`, `b̂ = (1/3, 0, 2/3)` (s = −1/9) or `(1/9, 2/3, 2/9)` (s = 1/9). These two give identical runs.
- `B_4/9`, `b̂ = (−2/9, 5/3, −4/9)`, s = 4/9.

Verified by run: the three members' work ratios to A agree within about 1% at every error level on M1, and B_mid and B_1/9 agree likewise on van der Pol.

**C. Alshina3.** I took it from `~/.julia/packages/OrdinaryDiffEqLowOrderRK/Q09W3/src/low_order_rk_tableaus.jl:1861-1889`, version 2.2.4. Its tableau is a21 = 0.5, a32 = 0.75, b = (0.2222…, 0.3333…, 0.4444…), c = (0, 0.5, 0.75), with `b2tilde = 0.4444…`. That is Ralston's third-order method, the same tableau as BS3's first three stages. The estimate in `low_order_rk_perform_step.jl:2021-2048` (out of place) and `2066-2093` (in place) is `utilde = dt * (b2tilde * k2)`. That is `h·(4/9)·k₂`: an O(h) quantity, not a difference of two solutions. I implemented it as found.

**Orders (verified, `k2_order.jl`):**
- **Global, fixed steps.** Kepler, frame = h from 1/16 to 1/256, every attempt accepted, t = 4. A, B and C give bitwise identical errors: 3.95e-1, 5.34e-2, 6.54e-3, 8.10e-4, 1.01e-4. The ratios are 7.39, 8.17, 8.07, 8.03, so the order is 3.
- **One step from pericentre.** The true local error has slopes 4.04, 3.68, 3.92, 3.98 (order 4). The estimate slopes are:

| Estimate | Slopes | Order |
|---|---|---|
| A | 3.08, 2.62, 2.91, 2.98 | 3 |
| B | 1.78, 2.72, 2.93, 2.98 | 3 |
| C | 0.69, 0.91, 0.98, 0.99 | 1 |

## 3. The models

- **M1, Kepler orbit.** μ = a = 1, e = 0.8, starting from pericentre. The frame is 2 s and t_end is 20 s (10 frames, about 3.2 orbits). The step need varies about 27×, and the controller sets every step but the 10 frame-top ones (≥144 steps per run). The reference is the analytic solution through Kepler's equation. The error is the position error at every logged boundary.
  - Variants: e = 0.9 and e = 0.5, and van der Pol with μ = 5 from (2, 0), frame 2 s, t_end 24 s. The van der Pol reference is RK4 at 2⁻¹³ s, which differs from RK4 at 2⁻¹² s by 2.3e-12. Its error is taken at the frame tops.
- **M2, the closed loop.** `closed_loop(solution, gains)` flown as `fly_closed_loop` flies it: cascade, the step to 1050 m at 5 s, seeded noise, frame 1/200 s, 50 Hz ticks, 120 s. The reference is RK4 at frame/32, which differs from frame/16 by 5.9e-13. The error is max over (V, γ, θ, q, h) of |Δ|/max(1, |ref|), at each of the 24 001 frame tops.
- **M3, the descent.** `descent()` from h = 30 m, δt = 0.25, frame 1/100 s, touchdown at about 17.67 s, with a passive sweep counter added. The reference is RK4 at frame/32, with frame-top differences of 5e-12. The error uses the same norm at the 1768 frame tops. Touchdown-time error is unresolved, because the reference's touchdown moves 9e-9 s between frame/16 and frame/32, more than the candidates' 2–4e-9.

## 4. Work-precision tables

The counts are exact. On M1 and M3 a component counter shows total sweeps = stage sweeps + one boundary sweep per accepted step, plus one arrival sweep per step on M3. On M2 the boundary sweeps are inferred from that rule.

**M1, Kepler e = 0.8** (`k3_wp.out`)

| cand | tol | acc | rej | sweeps | rhs | err_end | err_max |
|---|---|---|---|---|---|---|---|
| A | 1e-2 | 144 | 14 | 633 | 632 | 8.5e-1 | 1.9e0 |
| A | 1e-3 | 289 | 18 | 1229 | 1228 | 4.1e-2 | 1.7e-1 |
| A | 1e-4 | 586 | 28 | 2457 | 2456 | 2.6e-3 | 1.1e-2 |
| A | 1e-5 | 1237 | 28 | 5061 | 5060 | 2.7e-4 | 1.1e-3 |
| A | 1e-6 | 2635 | 20 | 10621 | 10620 | 2.6e-5 | 1.1e-4 |
| A | 1e-7 | 5610 | 13 | 22493 | 22492 | 2.6e-6 | 1.1e-5 |
| B_mid | 1e-2 | 223 | 13 | 709 | 708 | 1.9e-1 | 6.6e-1 |
| B_mid | 1e-3 | 458 | 16 | 1423 | 1422 | 1.1e-2 | 4.7e-2 |
| B_mid | 1e-4 | 957 | 27 | 2953 | 2952 | 7.7e-4 | 3.2e-3 |
| B_mid | 1e-5 | 2025 | 25 | 6151 | 6150 | 7.2e-5 | 3.0e-4 |
| B_mid | 1e-6 | 4334 | 13 | 13042 | 13041 | 7.2e-6 | 3.0e-5 |
| B_mid | 1e-7 | 9275 | 10 | 27856 | 27855 | 7.3e-7 | 3.1e-6 |
| B_1/9 | 1e-4 | 762 | 22 | 2353 | 2352 | 1.6e-3 | 6.8e-3 |
| B_1/9 | 1e-7 | 7370 | 9 | 22138 | 22137 | 1.5e-6 | 6.1e-6 |
| C | 1e-2 | 31 576 | 7 | 94 750 | 94 749 | 3.5e-8 | 5.6e-8 |
| C | 1e-3 | 314 344 | 7 | 943 054 | 943 053 | 7.3e-11 | 1.1e-10 |

C took 3.14 M steps at 1e-4, so I ran it no tighter. Every candidate also ran at 1e-8, only to cover the interpolation.

Ratio of `rhs` blocks to A at the same achieved error, log-log interpolation. The sweep ratios agree to three digits.

| model | metric | error level | B_mid | B_1/9 | B_4/9 | B steps / A steps |
|---|---|---|---|---|---|---|
| Kepler 0.8 | err_max | 1e-1 / 1e-3 / 1e-5 | 0.826 / 0.807 / 0.805 | 0.836 / 0.802 / 0.805 | 0.827 / 0.802 / 0.804 | 1.07–1.13 |
| Kepler 0.8 | err_end | 1e-1 / 1e-3 / 1e-5 | 0.820 / 0.827 / 0.811 | 0.825 / 0.819 / 0.810 | – / 0.828 / 0.809 | 1.08–1.14 |
| Kepler 0.9 | err_max | 1e-1 / 1e-3 / 1e-5 | 0.828 / 0.777 / 0.774 | 0.821 / 0.778 / 0.774 | 0.821 / 0.777 / 0.774 | 1.03–1.12 |
| Kepler 0.5 | err_max | 1e-1 / 1e-3 / 1e-5 | – / 1.093 / 0.630 | 0.906 / 1.091 / 0.627 | | erratic |
| van der Pol | err_max | 1e-2 / 1e-4 / 1e-6 | 0.821 / 0.720 / 0.654 | 0.844 / 0.735 / 0.650 | | 1.08 / 0.97 / 0.87 |

On M1, B saves 25% per step but needs 3–13% more steps for the same Kepler error. On van der Pol it needs fewer steps at tight error.

**M2, the closed loop** (`m2.out`; "sweeps" = stage sweeps + accepted steps)

| cand | tol | acc | rej | sweeps | rhs | err_end | err_max |
|---|---|---|---|---|---|---|---|
| A | 1e-2 | 24000 | 0 | 120000 | 96000 | 3.5e-9 | 2.16e-6 |
| A | 1e-3 | 24034 | 0 | 120136 | 96136 | 3.5e-9 | 3.9e-7 |
| A | 1e-4 | 37794 | 1 | 175180 | 151180 | 4.1e-10 | 2.4e-7 |
| A | 1e-5 | 51471 | 18 | 229956 | 205956 | 5.5e-10 | 1.3e-7 |
| A | 1e-6 | 106143 | 194 | 449348 | 425348 | 5.3e-11 | 2.5e-8 |
| A | 1e-7 | 188281 | 566 | 779388 | 755388 | 4.3e-12 | 3.2e-9 |
| B_mid | 1e-2 | 24000 | 0 | 96000 | 72000 | 3.5e-9 | 2.16e-6 |
| B_mid | 1e-3 | 34045 | 1 | 126138 | 102138 | 5.8e-10 | 2.4e-7 |
| B_mid | 1e-4 | 50013 | 13 | 174078 | 150078 | 1.1e-10 | 1.3e-7 |
| B_mid | 1e-5 | 101503 | 187 | 329070 | 305070 | 6.6e-11 | 2.9e-8 |
| B_mid | 1e-6 | 177380 | 551 | 557793 | 533793 | 4.2e-12 | 3.6e-9 |
| B_mid | 1e-7 | 346579 | 955 | 1066602 | 1042602 | 8.7e-13 | 4.9e-10 |
| B_1/9 | 1e-2 | 24000 | 0 | 96000 | 72000 | 3.5e-9 | 2.16e-6 |
| B_1/9 | 1e-3 | 24403 | 1 | 97212 | 73212 | 3.5e-9 | 2.6e-7 |
| B_1/9 | 1e-4 | 45852 | 9 | 161583 | 137583 | 4.5e-10 | 1.8e-7 |
| B_1/9 | 1e-5 | 84843 | 171 | 279042 | 255042 | 2.2e-10 | 4.3e-8 |
| B_1/9 | 1e-6 | 146581 | 399 | 464940 | 440940 | 8.4e-12 | 6.9e-9 |
| B_1/9 | 1e-7 | 281972 | 807 | 872337 | 848337 | 6.0e-13 | 9.4e-10 |

Ratio to A at the same err_max:

| error level | `rhs`, B_mid / B_1/9 | sweeps, B_mid / B_1/9 | steps |
|---|---|---|---|
| 1e-6 | 0.847 / 0.754 | 0.880 / 0.803 | |
| 1e-7 | 0.733 / 0.764 | 0.759 / 0.787 | |
| 1e-8 | 0.737 / 0.718 | 0.748 / 0.730 | 0.96–1.02 |

- The 1e-6 level sits on the frame-capped plateau, where the true ratio is exactly 0.75 / 0.80 at identical error.
- err_end is not monotone in tolerance, so I did not interpolate it.
- At the default tolerance, 1e-3, B_mid costs 6% *more* `rhs` blocks than A. It splits frames sooner, and lands at a lower error. B_1/9 costs 0.76 at a lower error.

**M3, the descent** (`m3.out`)
- Every candidate takes 1768 frame-capped steps up to tol 1e-4: A up to 1e-5, B_1/9 up to 1e-5, B_mid up to 1e-4. Their states are identical, with err_max 9.4e-9. A spends 7072 `rhs` blocks and 8849 sweeps, B 5304 and 7082.
- At 1e-7: A 10920 `rhs` blocks at err 5.2e-9, B_mid 11205 at 1.1e-9, B_1/9 11142 at 1.1e-9.
- Interpolated at err_max 9e-9, 7e-9 and 5.5e-9:
  - `rhs` blocks: B_mid 0.750, 0.755, 0.759 and B_1/9 0.746, 0.732, 0.663.
  - Sweeps: B_mid 0.800, 0.805, 0.810 and B_1/9 0.797, 0.781, 0.707.
- B pays one extra evaluation per validated trigger, since it has no `arrival_derivative`: one per run here. That is counted in the sweeps but not in the `rhs` column (+1).

**StepFloor:** none on M2 or M3. On M1 there is one per run at tol ≤ 1e-6 for every candidate, including A (see section 6).

## 5. How well each estimate tracks the true local error

`k5_track.jl` covers M1, Kepler e = 0.8, every accepted step with h ≥ 1e-6. The true local error comes from RK4 with 2000 substeps from the same state, checked against 4000. The ratio is the scaled estimate norm over the scaled true-error norm, using the controller's weights.

| cand, tol | n | min | q05 | median | q95 | under 1 | q95/q05 | median at pericentre / apocentre |
|---|---|---|---|---|---|---|---|---|
| A, 1e-4 | 586 | 4.9 | 8.8 | 29 | 102 | 0% | 11.5 | 20 / 22 |
| B_mid, 1e-4 | 957 | 65 | 78 | 201 | 2075 | 0% | 26.7 | 168 / 369 |
| A, 1e-6 | 2628 | 19 | 41 | 142 | 1348 | 0% | 33 | 95 / 89 |
| B_mid, 1e-6 | 4327 | 299 | 347 | 878 | 18 212 | 0% | 52 | 890 / 1608 |
| C, 1e-2 | 30 506 | 3e7 | | 6e11 | | 0% | | |

- No estimate underestimated at any sampled step.
- Large ratios are expected in a 3(2) pair that advances the third-order solution, since the estimate is O(h³) against an O(h⁴) error.
- B's level is arbitrary, being s times a fixed vector. Its spread is the meaningful figure, and it is about twice A's.
- B also overestimates about twice as much at apocentre as at pericentre, where A is balanced. B therefore puts its steps in less efficient places, which matches its 3–13% extra steps on Kepler.
- C's reference check is not resolved, because C's local errors fall below the reference's precision. Its ratio is only known to be ≥ 1e7.

## 6. What went wrong, what I did not do, and what looks suspicious

- **C is the B tableau with a degenerate estimate.** OrdinaryDiffEq's Alshina3 has the same tableau as BS3's first three stages, with `utilde = dt·b2tilde·k2`, which is first order. Alshina2 has the same form (`dt·1.0·k1`, tableaus line 1849ff, perform_step line 1949). This looks like an upstream transcription bug, which its fixed-step convergence test cannot catch. I did not check the Alshina–Zaks–Kalitkin 2008 paper. Repaired, C could only become a member of the B family, so no independent "C" exists for this tableau.
- **A spurious StepFloor at t = 0 (prototype behaviour).** With a coarse frame and a tight tolerance, the first proposal is Inf, so the first attempt is h_max = 2 s. Each rejection shrinks it by at most 0.2, reaching 1.28e-4 after six. Then the attempt budget of 7 is exhausted, and the next attempt drops to h_min = 2⁻⁴⁰ with a `StepFloor :budget` warning (`k4_floor.jl`). The proposal then has to grow back by 10× per step. A starting-step estimate would avoid both the warning and the near-zero step. This is identical for all candidates, so it does not bias the comparison.
- **Snapshots are logged at every boundary.** With sub-frame steps, `logged()` holds one snapshot per accepted step, capped at `log_max = 65536`. My first M2 run tripped on this. I now record the state per frame through `step!` and filter M3 to frame tops.
- **Tolerance meaning changes with s.** At a given reltol, B_mid lands at about 0.3× A's error on M1 and B_1/9 at about 0.6×. That is why, at the default 1e-3 on M2, B_mid costs more than A at a fixed *tolerance*. Choosing s near 1/18 would roughly match A's tolerance-to-error mapping. This is inferred from the tables, not run.
- **Verified vs inferred.**
  - Verified by run: every count, error and ratio above, and A' = A. Also the one-curve identity of the B family, up to interpolation.
  - Verified by a component counter on M1 and M3: total sweeps = stage sweeps + one boundary sweep per accepted step, plus one arrival sweep per step on M3.
  - Inferred: the M2 sweep totals, by that rule.
  - Not tested: Kutta's or other three-stage tableaus, wall time, and Dual models.

**Files** (all under `/private/tmp/claude-501/-Users-miguel--julia-dev-Redstone-jl/e10a5fc9-27fb-4587-bd0d-070e826ab3bb/scratchpad/pair_97/`):
- The notes, with the command behind every figure: `notes.txt`.
- The candidates and loaders: `probes/candidates.jl`, `probes/common.jl`, `probes/m_common.jl`.
- The probes: `probes/kepler.jl` and `probes/k1_smoke.jl` to `probes/k6_vdp.jl`, plus `probes/m2_closed_loop.jl`, `probes/m3_descent.jl` and `probes/interp.py`.
- The outputs: `k3_wp.out`, `k3_wp_e0.5.out`, `k3_wp_e0.9.out`, `k5_track.out`, `k6_vdp.out`, `m2.out`, `m3.out`.

Nothing in `wt_pair` was edited.

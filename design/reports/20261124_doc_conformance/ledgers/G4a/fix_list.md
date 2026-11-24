# G4a: rows for the fixer

Each row: the site at the pinned tip 2ea85438, the claim, the verifier's evidence and proposed fix, and its note. The fix is a proposal: conform it to the rules and to the code.

## S10a-037 (drift, clear=True)

- at: `design/spec.md:6514`
- claim: The loop divides a span into equal steps
- evidence: src/frame.jl:136-147: under a proposing backend each step is _shaped (model.jl:864) from the clock and re-shaped every step, so a span's steps differ. Probe P037: Scheduled stub in one span [0.0417, 0.0208, 0.03125, 0.03125]; BS3 on Kepler accepted lengths 3.2e-6, 3.2e-5, 1.5e-4, ... all unequal.
- fix: It ends a step at every due instant (...), so that ticks land on boundaries, and it divides the span between two such instants into equal steps under a fixed-step method, or the distance left to the next one into equal steps no longer than a proposal under a proposing method ([§10.5][s10-5], [D-449][d-449], [D-460][d-460]).
- note: The sentence dates from commit 8ba044ce (D-449, fixed-step only); D-460 (commit 106cb8ad) later added proposal shaping, which §10.5 and §2.2 already describe.

## S10a-064 (drift, clear=True)

- at: `design/spec.md:6556`
- claim: The distance to the next instant is taken in equal steps no longer than the proposal
- evidence: src/model.jl:879-882: N = ⌈r/cap⌉ is capped at ⌊r/h_min⌋, so near the floor a step runs past the clamped proposal. Probe P064: proposal 0.055, h_min 0.05, r 0.125 gives two steps of 0.0625 > 0.055 (_shaped returns 0.0625).
- fix: **A proposal is clamped into `[h_min, h_max]`, and the distance to the next mandatory instant is taken in equal steps no longer than it** ([§10.5][s10-5], [D-460][d-460]), their count capped at `⌊r / h_min⌋`, so near the floor a step can run past its proposal.
- note: D-460's own bullet (log.md:19744) and rationale (log.md:19783-19786) record the cap and that it can lengthen a step past its proposal; §10.5 (spec.md:7286-7293) states it too. Only this §10.2 sentence omits it.

## S10b-176 (drift, clear=True)

- at: `design/spec.md:7112`
- claim: t* is a float inside a step, never an anchor
- evidence: src/frame.jl:326 ends the step at t★ under a proposing method. On the next turn of the loop, src/frame.jl:144 computes `t_next = t + h_step` with t = t★, and _shaped divides the distance from t★. So t* anchors the next step's end and is not inside a step there. Only the fixed-step remainder (:328) leaves t* unused as an anchor.
- fix: Under a fixed-step method `t*` is a float inside a step, never an anchor from which anything else is computed. Under a proposing method `t*` ends its step, and the next step's end is its clock plus that step's length, as for any proposing step. No scheduled instant is ever computed from it.
- note: D-460 (a t* ends its step under a proposing method, and the next step is shaped from it) records the change. The spec updated lines 6820-6823 and 7104-7106 but not this sentence.

## S10c-109 (deviation, clear=True)

- at: `design/spec.md:7369`
- claim: With a Δt_unit of 1 µs and no finer bound, a run from t₀=0 resolves about 17 years
- evidence: Probe P7: Δt_frame = 1//1000000 (unit 1 µs, no bound) from t₀ = 0 gives last frame 562949953421311, t_last = 5.6295e8 s = 17.84 years. The same holds with a 10 ms frame over a 1 µs base (src/model.jl:592-593, reach = 2^50·δ from src/deployment.jl:173). The doc's "about 17 years" truncates 17.8.
- fix: With a `Δt_unit` of 1 µs and no finer bound, a run from `t₀ = 0` resolves about 18 years.
- note: This is an arithmetic slip in the worked figure. The rule and the code agree: 2^49 µs ≈ 5.63e8 s ≈ 17.8 years. No log entry carries a figure.

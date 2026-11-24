# G4b: rows for the fixer

Each row: the site at the pinned tip 2ea85438, the claim, the verifier's evidence and proposed fix, and its note. The fix is a proposal: conform it to the rules and to the code.

## CV10-253 (deviation, clear=True)

- at: `src/executor.jl:299`
- claim: EventSet says triggered is the frame's triggered set, but the frame loop rewrites it for every localization segment (and the validation prunes it), so it is the current segment's set
- evidence: src/frame.jl:222 rewrites events.triggered on every segment of _localized_step!'s loop (the whole step, then each remainder), and src/frame.jl:265 prunes it by the θ = 0 validation
- fix: `triggered` is the current segment's triggered set, pruned by the θ = 0 validation, and `loc_warned` the `ChatteringBudget` once-per-event-per-frame latch.
- note: The docstring and the per-segment rewrite both date from c3bd771b. Nothing records the wording as a move.

## CV10-262 (deviation, clear=True)

- at: `src/executor.jl:413`
- claim: code_map's executor.jl entry omits _store_successor!, the runtime check that raises ConformanceFailure for a wrong s_update return
- evidence: src/executor.jl:413-422 _store_successor! raises ConformanceFailure for a wrong s_update return, called at :186. rg finds no `_store_successor` in design/code_map.md, whose executor.jl entry (lines 614-653) does list the mode-side twin _merge_modes!
- fix: Add to code_map's executor.jl entry: "- `_store_successor!`, the update entry's runtime check that a discrete successor is the store's own type exactly, raising `ConformanceFailure` (§9.5, D-235)."

## CV10-270 (deviation, clear=True)

- at: `src/executor.jl:469`
- claim: code_map's executor.jl entry omits _event_bodies and _project_body, which build the per-event guard and handler callables and the per-component projection callables that phase_bodies returns
- evidence: src/executor.jl:469-477 define _event_bodies and _project_body. src/build.jl:1619-1624 builds the events and projections callables of phase_bodies from them. Neither name appears in design/code_map.md
- fix: Add to code_map's executor.jl entry: "- `_event_bodies` and `_project_body`, the per-event guard and handler callables and the per-projection callables that `phase_bodies` returns beside the four blocks (§9.7)."

## CV10-012 (drift, clear=True)

- at: `src/frame.jl:26`
- claim: every step integrates by the float distance between its two clocks, bare and localized alike
- evidence: src/frame.jl:142-144: under a proposal h_step = _shaped(...) and t_next = t + h_step, so the step integrates by its length, not by the float distance t_next - t. probe.jl:119 prints 112 of 155 accepted BS3 steps whose float clock distance differs from the length integrated
- fix: Every step whose end clock is known beforehand integrates by the float distance between its two clocks, the bare step and a localized one alike, and a proposed step integrates by its length, its end the start's clock plus it (D-455).
- note: D-455's own second bullet rules the proposal case as the code does, so only the header comment's "every step" overstates it. The code_map frame.jl entry repeats the same sentence ("Every step integrates by the float distance between its two clocks") and needs the same fix.

## CV10-114 (deviation, clear=True)

- at: `src/frame.jl:338`
- claim: code_map's frame.jl entry omits _trial!, the trial evaluation that _crossing calls (the ITP and arrival machinery around it is listed)
- evidence: src/frame.jl:338-345 _trial! carries a docstring and is called from _crossing at :387. rg finds no `_trial!` in design/code_map.md, whose frame.jl entry names _crossing and the trial phase only
- fix: In code_map's frame.jl entry: "ITP bracketing `_crossing` over `_trial!`'s trial evaluations".
- note: This is a minor helper, so the call is close. I ruled it a mismatch to stay consistent with the other omitted constructs that carry a docstring.

## CV10-135 (deviation, clear=True)

- at: `src/stepper.jl:19`
- claim: header says model.jl's integrate_step! raises the discontinuity notice, but its body never calls discontinuity!; the notice is raised by run_boundary!, overlay! and the frame top
- evidence: src/model.jl:812-850 integrate_step! never calls discontinuity!. The only calls are src/model.jl:657 (run_boundary!), src/model.jl:474 (overlay!) and src/frame.jl:90 (the frame top)
- fix: The Model's side is model.jl's `integrate_step!`: it shapes the proposal into a length between the deployment's `h_min` and `h_max`, counts the attempts, discards a rejected one, accepts one at the floor whatever its verdict, checks and commits an accepted one, and writes the clock. The Model raises the notice elsewhere, at `run_boundary!`, `overlay!` and the frame top.
- note: The header sentence and the three raise sites all come from one commit, e7dacf9e. The header was never accurate.

## CV10-146 (deviation, clear=True)

- at: `src/stepper.jl:35`
- claim: code_map's stepper.jl entry never names AbstractStepper, the abstract type every stepper and the seam's generic dense! dispatch on
- evidence: src/stepper.jl:35 abstract type AbstractStepper, which RK4Stepper/HeunStepper/BS3Stepper subtype (:133, :175, :266) and discontinuity!'s default (:86) and dense! (:361) dispatch on. rg finds no AbstractStepper in design/code_map.md
- fix: In code_map's stepper.jl entry: "…the retained `startpoint` and the generic `dense!`, both over the abstract type `AbstractStepper` every stepper subtypes, and the steppers `RK4Stepper` and `HeunStepper`…"

## K10b-048 (deviation, clear=True)

- at: `design/companions/limited_integrator_variants.md:123`
- claim: the +-1 gate converges at the same bisection count as the strict gate
- evidence: probe.jl P2: the ±1 gate takes exactly 20 trials per leave (166 total at 1//100, 167 at 1//10). The strict gate takes 21-22 per leave (177 and 176). With σlo = -1 and σhi = 1 the regula falsi point is the midpoint (src/frame.jl:377), so ±1 is pure bisection and needs one or two fewer trials than the strict gate.
- fix: Writing `one(u)` instead of `-u` on the holding side defines the same predicate and converges at plain bisection's count, 20 trials, one or two fewer per leave than the strict gate, because both ends of the bracket are then fake constants.
- coordinator: Probe the trial counts before writing them.

## K10b-077 (deviation, clear=True)

- at: `design/companions/limited_integrator_variants.md:221`
- claim: the localized policy lands within the root-finder's tolerance, about 1e-8 in time, at h = 0.01 and 0.1
- evidence: src/frame.jl:365: the tolerance is localization_tol * Δt_frame, so 1e-8 at h = 0.01 but 1e-7 at h = 0.1 (RK4, frame = step). probe.jl P2: max |leave - true zero| is 4.6e-9 at 1//100 and 9.27e-8 at 1//10.
- fix: with an input slope of 1 per second, the bound is 5e-5 at `h = 0.01` and 5e-3 at `h = 0.1`, where the localized policy lands within the root-finder's tolerance, `localization_tol · Δt_frame` in time, about 1e-8 at `h = 0.01` and 1e-7 at `h = 0.1`.
- note: D-446 says the tolerance stays a frame quantity, so it was frame-relative when the companion was written as well. Nothing records a fixed 1e-8.
- coordinator: Probe the bounds before writing them.

## K10b-083 (drift, clear=True)

- at: `design/companions/limited_integrator_variants.md:234`
- claim: the type parameters are LimitedIntegrator{V, L}
- evidence: src/library.jl:1830 struct LimitedIntegrator{V <: ..., L, R}; 1838 LimitedIntegrator{typeof(x0), localized, reset}. Step keeps {V, L} (1630).
- fix: selected by a type parameter in `Step`'s shape, `LimitedIntegrator{V, L, R}` with the keyword `localized = true`, where `R` is the later reset form
- note: Commit 94a1bc21 ('Add the reset keyword to the limited integrator ...') added R. design/code_map.md:769 records LimitedIntegrator{V, L, R}.

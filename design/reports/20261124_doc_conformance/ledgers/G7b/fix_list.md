# G7b: rows for the fixer

Each row: the site at the pinned tip 62551b06, the claim, the verifier's evidence and proposed fix, and its note. The fix is a proposal: conform it to the rules and to the code.

## K7a-092 (deviation, clear=True)

- at: `design/companions/longitudinal_aircraft.md:145`
- claim: The two-state polynomial gives the exact values of the full matrix's fast pair
- evidence: probe: the two-state matrix gives s² + 6.1436 s + 29.489, ωn 5.4304, ζ 0.5657, against the full fast pair's 5.4326 and 0.5660. They agree to the three figures quoted but are not exact.
- fix: whose characteristic polynomial `s² + 6.14 s + 29.5` has `ωn = 5.43 rad/s` and `ζ = 0.566`, the full matrix's fast pair to three figures.
- note: The two-state values are 5.4304 and 0.5657, the full ones 5.4326 and 0.5660.

## K7a-298 (drift, clear=True)

- at: `design/companions/longitudinal_aircraft.md:394`
- claim: A controller in command at Tt = one period pulls a limited integrator back within a tick
- evidence: src/library.jl:2704 (and :3058 for the tracker) β = -expm1(-Δt/Tt), so at Tt = Δt each tick closes 1 - e⁻¹ = 0.632 of the gap. probe: a DiscretePID at 50 Hz with Tt = 0.02, limit 1 and q = 2 gives u_raw 2.0, 1.368, 1.135, 1.050, 1.018, 1.007 over its ticks, so it is not back within a tick.
- fix: A controller in command back-calculates against its limits, and at one period each tick closes about two thirds of a limited integrator's excess, `β = 1 − e⁻¹`.
- note: The exact step is recorded in pid_anti_windup.md lines 391-403 ('The correction's step is exact') and in the DiscretePID docstring, and it was settled in increment 65 (10364763) before this companion was written. The claim reads as if the Euler step Δt/Tt = 1 applied. The closed_loop docstring at examples/src/longitudinal.jl:435-436 repeats it.

## K7a-317 (deviation, clear=True)

- at: `design/companions/longitudinal_aircraft.md:415`
- claim: The tracker's own limits are the actuators' ranges
- evidence: examples/src/longitudinal.jl:474-475 tracker u_min (-0.5, 0.0), u_max (0.5, 1.0); :501-502 the actuators are a RateLimiter and a FirstOrderLag, neither of which clamps (src/library.jl:713-727 RateLimiter has only rising, falling, s0). The model's actuators have no ranges. The tracker's limits equal the cascade innermost loops' limits (:457-458).
- fix: The tracker's own limits are those of the cascade's innermost loops, ±0.5 rad on the elevator and 0 to 1 on the throttle, and its hold input reads a zero code.
- note: The throttle's 0 to 1 is §1's stated range. Neither the companion nor the model states an elevator range.

## K7a-333 (deviation, clear=True)

- at: `design/companions/longitudinal_aircraft.md:437`
- claim: The standby tracker gap is back under 0.1 rad within 55 ms of the step
- evidence: probe out2.txt: the gap is 0.4289 at 5.0-5.015, 0.3319 at 5.02-5.035 and 0.1103 at 5.04-5.055, then 0.0242 from 5.06. It first falls under 0.1 rad 60 ms after the step, at its third tick, not within 55 ms.
- fix: is back under 0.1 rad within 60 ms, its third tick after the step,

## K7b-063 (drift, clear=True)

- at: `design/companions/store_at_rest_walkthrough.md:112`
- claim: sketch calls `init!(model, at("delay", set(s = s_copied)), t_k)` with t_k positional on a model
- evidence: src/model.jl:320 init!(model, plan; t0 = 0, hooks) takes t0 as a keyword; probe.jl:34-35 P063: init!(model, cond, 0.3) is a MethodError, no 3-positional method
- fix: init!(sim, at("delay", set(s = s_copied)); t0 = t_k)
- note: Not a move after the doc: t0 was already a keyword when the companion was written (spec Appendix B, design/spec.md:15129, init!(model, condition = set(); t0 = 0, hooks = NoHooks())). The sketch also inits a `model` and then steps `sim`; the sim's model is claimed (D-318), so the fix uses sim. The doc disclaims approximate names, but the call shape is wrong.

## K7b-064 (drift, clear=True)

- at: `design/companions/store_at_rest_walkthrough.md:113`
- claim: `step!(sim)` after `init!` is where boundary zero publishes y = u_k
- evidence: src/model.jl:336-341 boundary zero runs and publishes inside init! via settled!(hooks); probe.jl:31-33 P004/P064: the t_k snapshot is logged (log length 1, cell 4) before step!, and step! then publishes t_{k+1} with cell 5
- fix: init!(sim, at("delay", set(s = s_copied)); t0 = t_k)   # boundary zero publishes y = u_k, where the recording published u_{k-1} at t_k
- note: D-274 (design/log.md:12334) already made init! the one door that runs boundary zero, before the companion was written; the doc erred at writing rather than going stale. The step!(sim) line should be dropped or moved after the comment.

## K7b-106 (drift, clear=True)

- at: `design/companions/store_at_rest_walkthrough.md:196`
- claim: a state what-if has no door; there is no clean spelling today for fly, stop, change states, continue
- evidence: src/sim.jl:964-981 overlay!(sim, condition) exists, the state what-if; src/model.jl:469
- fix: The workflow that had no clean spelling before [D-429] is the one in between: fly a while, stop, change a few states, continue. [D-273] spells an input what-if as a restore followed by `stage!`, and until `overlay!` a *state* what-if had no door.
- note: Recorded by D-429 (design/log.md:17414) and commit bc460431 (2026-10-20), which added overlay!.
- coordinator: The store-at-rest walkthrough was written before its refactor landed; bring the rows' tense and names to the code, but keep the walkthrough's argument and structure.

## K7b-107 (drift, clear=True)

- at: `design/companions/store_at_rest_walkthrough.md:198`
- claim: a condition goes only through `init!`
- evidence: src/sim.jl:964-975 overlay! takes a condition and resolves it against the build
- fix: Before `overlay!`, a condition went only through `init!`, and `restore!` takes no overlay.
- note: Recorded by D-429 and bc460431.

## K7b-153 (drift, clear=True)

- at: `design/companions/store_at_rest_walkthrough.md:304`
- claim: with the same cond, init! and overlay! differ in exactly five choices and everything else is shared
- evidence: src/model.jl:334 init! calls reset_stepper!(exec.stepper), while src/model.jl:474 overlay! calls discontinuity!(model.exec.stepper), so the stepper handling is not shared
- fix: Everything else is shared but the stepper: the condition resolves against the build with the same diagnostics, the named stores and root-input cells are written, projection runs, the sweep iterates with guards and handlers to quiescence, one snapshot is published, and a fresh trajectory opens with the post-settling checkpoint as its header. `init!` resets the stepper through `reset_stepper!`, and `overlay!` raises its discontinuity notice.
- note: Recorded by D-452 (design/log.md:19091, the bullets on the notice when overlay! settles and on init! calling reset_stepper!) and spec §12.6 (design/spec.md:10714-10715). Root-input totality also differs (src/sim.jl:841 vs 969-970), but section 7.4 already says so.

## K7b-177 (drift, clear=True)

- at: `design/companions/store_at_rest_walkthrough.md:331`
- claim: the first two choices live in the doors' bodies; the last three live inside the boundary in the settling routine both doors call
- evidence: src/model.jl:326-332 init!'s body sets the base, the clock and the priors (fill!), and overlay!'s body (469-474) leaves all three; only the discrete stages and the updates differ inside the boundary, through the due set (src/model.jl:652-663)
- fix: The first three choices live in the doors' own bodies, before the boundary. The last two live inside the boundary, in the routine both doors call.
- note: D-429's Rationale (design/log.md:17462-17463) already says 'The first three choices live in the doors' own bodies, the last two inside the settling routine'.

## K7b-180 (drift, clear=True)

- at: `design/companions/store_at_rest_walkthrough.md:339`
- claim: the settling routine `_settle!(model; fresh)` is boundary zero's tail factored out, with one flag
- evidence: no _settle! in src/ (rg); overlay! settles through run_boundary!(model, nothing) (src/model.jl:476) and boundary zero through run_boundary!(model, ESTABLISH) (src/model.jl:702)
- fix: The settling is the boundary routine `run_boundary!(model, due)` over a chosen due set: boundary zero's `ESTABLISH` admits every discrete output stage and the index-0 updates, and the overlay's empty set (`nothing`) admits none.
- note: _settle! was added in bc460431 and replaced in c3e7faeb (2026-11-11, D-445). The model.jl comment at src/model.jl:440-442 cites D-445 for the empty due set.

## K7b-188 (drift, clear=True)

- at: `design/companions/store_at_rest_walkthrough.md:371`
- claim: today's steppers are fixed-step RK4 and Heun with no carried state
- evidence: src/stepper.jl:267 BS3Stepper and src/stepper.jl:283-285 carry a proposal and a controller memory; src/checkpoint.jl:51-54
- fix: Today's steppers are fixed-step RK4 and Heun, which carry nothing, and BS3, which carries its next step's proposal and its controller's memory.
- note: Recorded by D-461 (design/log.md:19839) and commit 4367fa55.

## K7b-189 (drift, clear=True)

- at: `design/companions/store_at_rest_walkthrough.md:372`
- claim: `restore_stepper!` is a no-op and a backend with a cached derivative would need its reset on overlay
- evidence: src/stepper.jl:283 restore_stepper! for BS3 writes the proposal and the memory back, so it is no longer a no-op; src/model.jl:474 overlay! raises discontinuity!, not a reset
- fix: (`restore_stepper!` is a no-op for RK4 and Heun and puts BS3's proposal and memory back). The overlay raises the stepper's discontinuity notice, and what a backend does with it is its own.
- note: Recorded by D-452 (overlay! raises the notice) and D-461 (BS3's carried state).

## K7b-211 (drift, clear=True)

- at: `design/companions/store_at_rest_walkthrough.md:400`
- claim: overlay!'s plan method calls `_settle!(fresh = false)` inside the same catch with its own host tag
- evidence: src/model.jl:474-479 overlay!'s plan method calls discontinuity! and then run_boundary!(model, nothing) inside try/catch, wrapping as _wrap_step(model, k, :overlay, err)
- fix: and runs the boundary over the empty due set, `run_boundary!(model, nothing)`, inside the same catch with its own host tag, `:overlay`.
- note: _settle!(fresh = false) existed from bc460431 until c3e7faeb (D-445).

## K7b-220 (drift, clear=True)

- at: `design/companions/store_at_rest_walkthrough.md:408`
- claim: overlay!'s simulation wrapper has the same lifecycle gate as restore!'s
- evidence: src/sim.jl:966-967 overlay! takes _assert_at_rest, legal only in initialized or stopped with the clock on a frame top, while restore! (src/sim.jl:1066-1069) refuses only running and errored; probe.jl:67-70 P220o/P220r: overlay! on a built sim is ServiceLifecycle (legal [:initialized, :stopped]), and restore! on a built sim succeeds
- fix: `overlay!`'s is `restore!`'s wrapper more than `init!`'s: `checkpoint`'s lifecycle gate (legal while `initialized` or `stopped`, its clock on a frame top), a fresh run, the periphery handled as `restore!` handles it, and the header taken after settling.
- note: Recorded by D-429's Position (the model form is legal at :consistent on a frame top) and spec §12.6 (design/spec.md:10724-10726); pinned at test/test_lifecycle.jl:894-923.

## K7b-224 (drift, clear=True)

- at: `design/companions/store_at_rest_walkthrough.md:411`
- claim: the refactor makes `boundary_zero!` become `_settle!` with the flag
- evidence: src/model.jl:702 boundary_zero!(model) = run_boundary!(model, ESTABLISH); no _settle! exists
- fix: The refactor is in layer 2: boundary zero and the overlay both run the one boundary routine, `run_boundary!`, boundary zero over `ESTABLISH` and the overlay over the empty due set.
- note: bc460431 made boundary_zero! call _settle!(fresh = true), and c3e7faeb (D-445) replaced that with run_boundary!(model, ESTABLISH).

## K7b-225 (drift, clear=True)

- at: `design/companions/store_at_rest_walkthrough.md:412`
- claim: init!'s plan method calls the settling routine with fresh = true
- evidence: src/model.jl:336 init!'s plan method calls boundary_zero!(model), which is run_boundary!(model, ESTABLISH) (src/model.jl:702)
- fix: and `init!`'s plan method calls `boundary_zero!`, the boundary routine over `ESTABLISH`.
- note: Same move as K7b-224: bc460431, then c3e7faeb (D-445).

## SD4-125 (drift, clear=True)

- at: `design/spec.md:17317`
- claim: The execution cursor holds three facts
- evidence: src/executor.jl:17-23: ExecutionCursor holds comp, fn, phase, index and attempt. probe.jl:62 prints (:comp, :fn, :phase, :index, :attempt). Spec §13.4 (spec.md:11541-11543) adds that inside integration the cursor also records the attempt, per D-452.
- fix: It holds three facts, the component by its index in the structure's component list, the function running, and the boundary phase, and inside integration it also records the attempt by its ordinal in the step ([§13.4][s13-4], [D-452][d-452]).
- note: Drift recorded by D-452 (log.md:19122-19123, 'the execution cursor records the ordinal inside integration') and commit e7dacf9e, which added `attempt::Int` to the cursor.

## SD4-164 (deviation, clear=True)

- at: `design/spec.md:17364`
- claim: A warning raised producing an artifact lives on it, a trim report included
- evidence: src/trim.jl:737, 750 and 760: trim! logs TrimCommitEvents, TrimCommitResiduals and TrimCommitChecks with @warn. TrimReport (src/trim.jl:186-198) holds only the facts those warnings report (fired_events, committed_residuals, committed_checks), not the warnings. probe.jl:70-71 shows no warnings field and no warnings(::TrimReport) method (warnings is defined only on Build, Deployment, Model and Simulation).
- fix: A warning raised producing one lives on it, save a trim report, which holds the facts its warnings report while `trim!` logs the warnings beside it ([§13.2][s13-2], [D-250][d-250]).
- note: §13.2 (spec.md:11343-11346) and Appendix C's logged policy (spec.md:15500-15502) already describe the code's behavior. Only the glossary's generalization is off.

# Harvest 1: the decision log

Agent 1's return, verbatim. Source: the 117-entry slice of the log from
D-162 on whose headings name authoring vocabulary. Spec line numbers refer
to the frozen spec at `e2b7393`.

Agent 1 harvest of Appendix A. Source: log_slice.md, all 117 entries read. I checked each candidate's sentence in the frozen spec and grepped Appendix C (lines 13564 to 14018) for each one.

### **Never cache `Δt`**
Group: component authors
Owning section(s): §10.5; D-019, D-291
Spec sentence: "An author must never store `Δt`, or any `Δt`-derived coefficient, as a component parameter ([D-019][d-019])." (line 6368). Also: "Under scoped multipliers a component author *cannot* know their absolute rate. It does not exist until composition." (lines 6374–6376)
Recall line: Read `Δt` from the discrete bundle, every tick, in the stage that runs the discretized law. A gain, a Tustin or backward-difference coefficient fixed at construction is a second copy of a period the component cannot know, since the period does not exist until composition.
Goes wrong without it: a scope multiplier, an anchor or `Δt_base` changes the period while the cached coefficients stay fixed. The controller's discrete dynamics are then wrong and still well-typed. A parameter is plain data, so nothing checks it, and Appendix C has no kind for it.
Source: D-291 bullet 4; D-186 Rationale ("never-cache-`Δt` fully intact")
Status: new

### **Trim checks: the residuals cannot see the operating point**
Group: service users
Owning section(s): §14.7, §14.9; D-262, D-417, D-139
Spec sentence: "If the two disagree, the residuals vanish at a true equilibrium that is not the requested point, and nothing in the residual system can tell ([D-139][d-139])." (lines 12122–12124)
Recall line: Under analytic elimination, the condition math pins the targets against the environment in your `params` record. The world measures them against the baseline's environment. Declare `checks` that read the world's own measurement of each target at the committed state, such as EAS from the airdata output minus the requested value. Also, the problem receives the environment and never writes it.
Goes wrong without it: the solve converges and the report reads converged, at a different flight condition. `TrimCommitChecks` fires only for checks the problem declares. With the default empty `checks`, nothing fires.
Source: D-262, D-417
Status: new

### **Guard predicates: where boundary detection is exact, and what σ = 0 means**
Group: component authors
Owning section(s): §2.3, §10.4; D-365, D-290, D-179
Spec sentence: "Boundary detection is exact for a guard whose value within a step depends only on modes, root inputs and held discrete outputs. […] A guard that reads an input fed by continuous state or by time can cross inside a step, as a guard on its own state can." (lines 409–414). And: "the predicate holds when the function's value `σ` satisfies `σ ≥ 0`." (line 376). And: "the sign form `-u` alone holds there, since `-0.0 ≥ 0`. Gate on the strict comparison instead, `u < 0 ? -u : -one(u)`." (lines 5756–5758)
Recall line (two facets): (a) A `Bool` guard is exact only over modes, root inputs and held discrete outputs. Over an input fed by continuous state or time, the crossing is seen at grid resolution. Localize it with the sign form, or with `(gate) ? σ : -one(σ)` for a mixed predicate. (b) Zero counts as holding. A predicate that must exclude equality gates on the strict comparison.
Goes wrong without it: (a) the handler fires up to a step late with no warning. A `Bool` guard over a wired `u` looks exact and is not. (b) A's current text says "positive meaning holding", which is wrong at σ = 0. A release predicate written as `-u` fires at exactly zero input. `GuardForm` checks the return type only.
Source: D-365 (narrows D-290 bullet 1); D-290 annotation 2026-10-07
Status: amends "Guard predicates, edges and priors". Agent 2 may find facet (b) too, through limited_integrator_variants.md.

### **What-if replay starts from your own `init!`**
Group: service users
Owning section(s): §12.7; D-274
Spec sentence: "It is spelled as `init!` of the modified model under the authored condition, then `replay!(sim, trc; restore = false)`. The trace is not self-sufficient for it. Its checkpoint holds the recording model's state after boundary zero, so the authored condition comes from outside ([D-274][d-274])." (lines 9874–9877). And: "*Structural* mismatch is an error. *Parametric* difference is not" (lines 9827–9828)
Recall line: To replay recorded inputs through a re-parameterized model, `init!` it under the authored condition and replay with `restore = false`. The default `replay!` restores the recording model's post-boundary-zero state.
Goes wrong without it: the what-if starts from the old model's `x`, `s`, held outputs and priors instead of the modified model's own boundary zero. Validation passes, because a parametric difference is not a mismatch by design.
Source: D-274 (parametric what-if bullet and Rationale)
Status: new

### **Contracts follow the type, never field values**
Group: component authors
Owning section(s): §8.1, §9.7; D-033, D-297
Spec sentence: "A leaf's contract declarations must be determined by the component's type, its type parameters included, and never by its field values" (lines 2133–2135, emphasis dropped). And: "The build reads each declaration once, against the concrete instance, so a value-dependent contract does not announce itself. This is a rule authors keep, not a check the build can run." (lines 2157–2159)
Recall line: `u_types`, `y_types`, `state_events` and the store shapes must follow from the type and its parameters. A contract that really varies takes a type parameter, as `SumJunction{Wrench{Float64}, 3}` and `Or{N}` do. `ws_init` is the one declaration that may read the instance.
Goes wrong without it: two instances of one type that differ only in field values share an entry type and compile to one body (lines 5169–5170). A contract read off a field is therefore one the executor's typing never honors. The spec says outright that no check exists. The spec does not describe the runtime symptom, so the recall line should not claim one.
Source: D-297 bullet 1
Status: new

### **An unwired contributor drops out of the total**
Group: component authors
Owning section(s): §6.2; D-037, D-084, D-323
Spec sentence: "A contributor's output that nobody wires stays legal and silent, as any unconnected output does ([D-084][d-084])." (lines 1677–1678). And: "Reassigning contributors to different slots changes summation order, hence bits" (lines 1687–1688)
Recall line: A junction makes its own bookkeeping loud, but not the contributor's side. A new contributor counts only once the junction's arity grows and its output is wired in. Slot order is the fold order, so reshuffling slots changes the bits.
Goes wrong without it: a rotor or gear leg added to an assembly runs and publishes, and its wrench is missing from the total. The unconnected-input and single-connection checks fire only for slots the junction declares.
Source: D-323 bullet 2 ("A tree walk omits a contribution silently")
Status: new

## No home

- **A condition copied from a checkpoint runs one tick ahead.** D-273's Rationale says the store at rest holds `s_{k+1}` beside the held `y_k`. Its last bullet says an authored condition is "a checkpoint's read-only view lets the author copy from". Copying a discrete `s` from a checkpoint into a condition therefore makes boundary zero publish from `s_{k+1}`, so the discrete tier runs one tick ahead. I found no spec sentence that states this hazard (grepped §12.6, §14 lead, §14.5). Once the spec states it, it is a natural facet of A's "Interval alignment".
- **A startup hole is the author's to model.** D-205's Rationale says a modeled startup hole "is a modeling decision for a validity flag or mode". §10.5 states the behavior: an offset component publishes at `t₀` from the authored world (lines 6146–6149). The advice itself has no spec sentence.

## Rejected

- D-164, D-246 (declarations in a local scope or shadowed): checked by `ClassUnreadable` and `DeclarationShadowed`.
- D-252 (expose state through `y_state`): checked by `DeclaredNotProduced`.
- D-210 (primitive root key in both contracts): build error.
- D-237, D-243 (handle and `Symbol` leaves; handle built from literals at `Dual`): `IllegalPortType`, or refused at the probe.
- D-307, D-304 (generic continuous math, type stability under `Dual`): loud as `MethodError`/`InexactError` at a `Dual` activation; fails test 2.
- D-346 (write-side granularity): the two-writer half is `ClaimConflict`; the spec gives no silent consequence for the cadence half.
- D-362 (periodic reset is not a time-guard event): the spec says "not an event either" (line 762) but gives no hazard for a hand-rolled one; weak.
- D-186, D-291 (anchor doctrine; "how silently an offset edit rewires a coincidence structure", line 6345): passes all four tests and was dropped only for the six-entry cap. It is the next in line.
- D-396, D-374 (a dead device's root inputs hold their values while the run continues): `DeviceCrash` fires; borderline, owner's call.
- D-402 (a genuine crash after `unblock!` goes unreported): a framework limit with no author action.
- D-378 (claim the whole enumerable set): an under-claim is `OutOfClaimEntry`.
- D-272 annotations (duplicate taps; a root input read by a discrete consumer): `TapResolution`.
- D-427 (condition naming a wired input): `ConditionResolution`.
- D-213 (services' frozen discrete cells): the framework's job; no author consequence.
- D-342, D-292, D-316, D-412, D-382, D-372, D-373: already in A (reset consumption, handler-phase visibility, stop-request sampling, traits, `shutdown!`, loop idioms).
- D-323 bullet 3 (no bundled contribution struct): design rationale.

Outside my source, for agent 2 or the owner: §4.4 lines 983–987, "A field object must hold no mutable cache" (D-344), is stated as "the author's" rule with no check. It looks like an A candidate for component authors.

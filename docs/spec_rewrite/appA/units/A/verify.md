# Unit A, cold verification

## Counts

- Old claims: 137. MATCH 137, DRIFT 0, LOST 0. Every old citation survives with its claim. C-069 (`σ ≥ 0`) is the ruled R3 correction and matches §2.3 (frozen 374–376).
- ADDED: 110 inventory items checked, labels and glosses included. 8 widen or drift from the spec, listed below.
- Citation findings: 4. Bold and owners findings: 3. Glossary findings: 3. Length: 1.

## ADDED that widens or drifts

1. **V86, quantifier moved.** Spec (§2.3, §10.4, D-365): "exact for a guard whose value within a step depends only on modes, root inputs and held discrete outputs". New: "exact only for a guard over modes…". The new text turns a sufficient condition into a necessary one. Fix: "Boundary detection is exact for a guard whose value within a step depends only on modes, root inputs and held discrete outputs."
2. **V93, scope widened.** §10.4 speaks of one predicate that must exclude equality: "A release predicate, "the input points back into the range", does not hold at…". New: "A release predicate, such as …", which states the claim for every release predicate. Fix: "A release predicate that must exclude equality, such as "the input points back into the range", …".
3. **V94, policy dropped.** Spec: "The `Bool` form `u < 0` is the same predicate boundary-detected". New: "It gates on the strict comparison instead, as `u < 0 ? -u : -one(u)` or as the `Bool` form `u < 0`." This reads as two gates that both localize. Fix: "…, or takes the `Bool` form `u < 0`, the same predicate boundary-detected."
4. **V147, antecedent clash.** "an unwired contributor drops out of the total and no diagnostic fires" contradicts V145, where a counted but unwired contributor is an error. Fix: "so a contributor whose output nobody wires drops out of the total silently."
5. **V199, strength raised.** Spec (12091): "As authoring guidance, an equilibrium equation … reads a face". New drops the qualifier, so the sentence reads as a rule. Fix: put back "As authoring guidance,".
6. **V218, scope widened.** Spec: "pins the airspeed and the flight-path angle from the targets". New: "pins the state". Fix: "pins the targeted state coordinates from the targets and …".
7. **V222, qualifier dropped.** Spec: "On a quantity the condition writes directly *from a decision*, a check … is always zero". Fix: "on one the condition writes directly from a decision it is always zero".
8. **V221, lost scope and gloss.** Spec: "A check reading EAS (equivalent airspeed) from the world's airdata at the committed state and subtracting…". Fix: put back "(equivalent airspeed)" and "at the committed state".

V59 (`overlay!`) checked against 4f922f7. §12.6 at 9608–9631 and D-429's Position carry it. Minor: spec says "continues it as a fresh trajectory" and "the stores the condition names are overwritten". Fix: "writes the condition's stores onto the stopped run's own and continues it as a fresh trajectory". `[d-429]` has no reference definition in the frozen link block, so it needs 4f922f7's.

Every other added sentence matches its spec source verbatim or compresses it without widening: startup hole (6160–6169), rest reading (11900–11906), undeclared modes (651–657), latching (5774–5779), Δt (6385–6396), field handle (991–995, 814), contracts by type (2140–2167), stripping (11092–11098, 5030–5032, 12821–12824), unit delay (11031–11037), junction (1680–1691), publications (§12.3), conditioning (7501–7514), held tier (12879–12890, 12163–12169), what-if replay (9894–9898, 9850), shutdown! (7951–7966), observation sides (11518–11525).

## Citations

All added and replaced owner citations were read in full. Each Position, or the listed Rationale or annotation, carries its entry's contract. Exceptions:

- What-if replay: §12.7 cites "*Structural* mismatch is an error…" to D-101 and D-391. A cites D-274 alone, which does not rule it. Add D-101 and D-391, or drop the sentence.
- Held discrete tier: the frozen-exact answer and "recorded, not built" rest on D-072 and D-073 (§14.10 12879–12882). Neither is cited. D-213 carries only the held-through-the-solve sentence. Suggest adding D-072 and D-073.
- Undeclared modes: D-179 carries the detection policy only, and the grounding sentence cites §2.3 and D-345 alone. The citation is weak but harmless, since the brief names it.
- Trim checks: the always-zero sentence is not in D-262. The rewriter already flagged this.

## Bold and owners

- "**Binding traits are declarations, mappings are your own idiom**" is a ruling sentence (D-382's Position) of 9 words. Fix: "**Binding traits and mappings**".
- "**`shutdown!` closes only what is open**" states a ruling (§11.6's obligation). Fix: "**What `shutdown!` tolerates**".
- The Binding traits owners parenthetical uses a comma, `(§11.6, D-382)`. Fix: `([§11.6][s11-6]; [D-382][d-382])`.
- No bold sits outside a label. Every owners parenthetical has a section citation.

## Glossary, names, reserved words

- All `#g-` targets exist once in Appendix D. No term is linked twice.
- Unlinked first uses with anchors: *port* (Derived liveness, `#g-port`), *quiescence* (Continuous-tier resets, `#g-quiescence`), `t*` (Publications, `#g-t`, glossed but unlinked).
- "restructure the interpolant to be pure" is the spec's own sentence, but `#g-interpolant` is the Hermite step extension. Leaving it unlinked is right. Likewise "chatters" is correctly left off `#g-chattering`, which means the localization budget.
- No forbidden names. EAS, airdata and "aircraft semantics" are the spec's domain words, not named examples. The new text adds no reserved-word misuse. The old ones ("condition", bare "entry", "kind") stay, as rulings.md proposes.

## Length

Interval alignment runs about 164 words, over 150. Fix it with item V59's tightening, or shorten the `overlay!` sentence to "A state what-if goes through `overlay!` instead, which keeps the stopped run's stores and lattice, so no copy through a condition is needed (§12.6, D-429)." Continuous-tier resets and The two observation sides run 149 each, and the guard entry 146, which is within the ruling.

## Re-check, 2026-10-20

- **Reworded sentences.** Each one now matches its source. V86 matches §2.3/§10.4 and D-365. V93 and V94 match §10.4 at 5762–5770. V147 matches §6.2. V199 matches §14.7 at 12091. V218, V221 and V222 match §14.7 at 12143–12155. V59 matches §12.6 at 4f922f7, 9608–9625. No widening is left. V218's "targeted state coordinates from the targets" repeats a word but claims nothing more.
- **New citations.** D-391's Position: "A structural mismatch is an error. A parametric difference is the what-if replay". It carries the sentence. D-101 carries it only in its Rationale, so leaving D-101 out is fine. D-072's Position: "the discrete tier frozen-exact". It carries the exact-answer sentence. D-073's Position: "sampled-data Dual activation recorded unbuilt (§14.10)". It carries "recorded, not built".
- **Labels.** "What `shutdown!` tolerates" and "Binding traits and mappings" are topic labels. Each old label sentence now opens its body word for word, so no claim is lost. The Binding traits owners parenthetical now takes a semicolon. All 32 bolds are labels.
- **Reserved-word rewordings.** "Each item is normative…" still refers back to Appendices A and B. "(the next item)", "a different sort of thing" and "the reset command arrives" each keep the meaning, and none adds an antecedent hazard.
- **Links.** `#g-port`, `#g-quiescence` and `#g-t` all exist in Appendix D, and each sits at the term's first use in A. Simulink's "reset ports" comes earlier but means something else, so leaving it unlinked is right. No term is linked twice.
- **Still open: length.** Interval alignment runs about 167 words, label and owners included. The `overlay!` sentence grew, and the length fix was not applied. Suggested fix: "A state what-if goes through `overlay!` instead, which keeps the stopped run's stores and lattice, so no copy through a condition is needed ([§12.6][s12-6], [D-429][d-429])." Continuous-tier resets, the guard entry and The two observation sides run 150 to 153 with label and owners, which is acceptable.

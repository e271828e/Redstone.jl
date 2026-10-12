# Unit E verify

Base: frozen `scratch_survey/spec.md` and `decisions.md` (d3af35a). The checker prints `checks failed: 0`.

## Counts

There are 96 phase-1 assertions and 69 inventory claims: 67 MATCH, 2 DRIFT, 0 LOST. There are 18 ADDED items, and none changes meaning.

## DRIFT

1. **C-037/C-038, citation scope.** Old 487–488 is one sentence: "A value a later function needs is a declared port like any other, and a stage result outside the contract is a build error ([§5.2], [§8.3])". The new text splits it in two and gives the first sentence `[D-194]` only. §5.2 (old 833–835, "every value a later function needs is one of those cells") carries the first clause. Its citation now sits only on the build-error sentence, which §5.2 does not state (§8.3 3000 and Appendix C 12580 do). Fix: add `[§5.2][s5-2]` to the first sentence. The second sentence may keep only `[§8.3]`.
2. **C-006, weight.** Old 444–445 had "(`y_state`/`y_direct`, the two output stages every component provides, on either tier)" as a gloss. It is now a standalone uncited sentence: "Every component provides two output stages, `y_state`/`y_direct`, on either tier". That raises the weight a little. The sentence now reads as a ruling, and an assembly provides no stages. §5.2 696 bolds the same claim (D-006), so this is a restatement, not a new claim. Fix: add `([§5.2][s5-2])` so the sentence points at its ruling. Keep "every component" as written, and send the assembly question to the owner together with §5.2 696.

## ADDED

- R3 opening: "the addressable unit through which components exchange immutable values" is verbatim from old 128–129. Each section clause uses only its section's title, and "of signals" uses §4.1's own subject. It is clean.
- Every gloss matches its glossary entry: tier, buffer, device ("in the periphery" / "the GUI is an ordinary device"), periphery, execution order, feedthrough, contract (output side, `y_types`), cell, assembly, claim, trace, guard, snapshot. Two root-input glosses come from old 458. None claims more than its source.
- Periphery atom: the six "One"s survive as a count (cell, root input, staged write, device claim, trace address, GUI liveness verdict). The list adds only three glosses. §11.3 and §11.7 stay on their items.

## Citations

Every old citation survives with its claim. Each added entry carries its claim in the field rulings.md names: D-004 Position, D-121 Position (both uses), D-040 Position (slash form; it carries the example, not the flat namespace), D-276 Position, D-034 Position "declared = public" and Rejected (`unlisted`), D-194 Position and bullet 2, D-172 Position (faces; "kind-blind" becomes "class-blind" by D-122), and D-036's second ruling. D-243 and D-231 are rationale-only as declared. Note that D-243's Rationale (log 9210) only restates §4.1, so the bold rests on a circular source. R12's `UndeclaredReturnField` sits on the right condition (§8.3 3000). R15's `ProducedByTwoStages` matches §8.3 2995–2996.

## Bold

There are five bolds. Each sits on one ruling and is followed by its entry. The faces bold reads as a definition, but D-172 is a terminology ruling and R6 ordered the bold. No ruling is bold in both E and F. D-036 is split between the units 2 / 1, 3, 4, and D-243 has its Rationale bolded in E and its Position in F.

Row 99 against old 1892: the two state different rulings, the signal requirement and the latitude withheld from stores. But row 99 cites D-231 for the exact clause that 1892 bolds, so a reader sees D-231 bolded twice. Optional fix: move `[D-231]` to the next plain sentence ("Signals may reference bulk data…"), whose claim D-231's Position carries, and keep the bold on D-243.

## Moves

R3, R5 (F8, F9), R6, R12 and R15 are done. There are no other moves. Splitting the periphery atom into a list is not a move.

## Reader-cold names

- (1/2) `"dyn/vel"`, `"dyn/f_c_c"` are Flight.jl-style names with no "illustrative" clause. The old text has them too.
- `x_deriv`/`s_update` (§4.3) appear with no pointer to §5.2. The old text also lacks one.
- `SVector`, `merge` are ordinary Julia. The new text adds a §5.2 pointer for `merge(...)`.
- No FlightCore names.

## Re-check

The checker prints `checks failed: 0`. Apart from the five fixes, the text matches the version first verified. No antecedent moved. The inventory (C-006, C-019, C-020, C-029, C-037, C-038, C-063, plus three `added` items) and rulings.md (R6, citations, bold section) record each change.

1. **§5.2 split.** The first sentence now ends "([§5.2][s5-2], [D-194][d-194])", and §5.2 old 833–835 carries it. `UndeclaredReturnField` cites only `[§8.3]`, which old 3000 carries. MATCH.
2. **C-006.** `[§5.2]` points at the D-006 bold at old 696, so the sentence now reads as a restatement. Its claim is right. The double parenthesis does not read cleanly, though: "...on either [tier] (the continuous or discrete side of the hybrid formalism) ([§5.2][s5-2])". The pointer looks like it cites the tier gloss. Fix: "Every [component] provides two output stages ([§5.2][s5-2]), `y_state`/`y_direct`, on either [tier] (the continuous or discrete side of the hybrid formalism)." The assembly question stays with the owner.
3. **Row 99.** The bold cites D-243 alone, so D-231 is no longer bold twice against old 1892. D-231 now sits on "Signals may reference bulk data ... read-only for the duration of the run". Its Position ("The frozen-reference latitude of [§4.1] stays with signals", log 8691–8692) and its Rationale ("The latitude was earned by field handles on ports ([§4.4])", log 8704–8705) carry the claim. MATCH. The bold's only source is now D-243's Rationale, which restates §4.1, as declared. Nit: the source has a stray line break after "([D-231][d-231])." It does not show when rendered.
4. **"such as the illustrative paths `"dyn/vel"` and `"dyn/f_c_c"`".** This is accurate. They name no real model. `f_c_c` echoes FlightPhysics' `dynamics.jl`, but an example of path form needs no owner gloss. The line runs past 80 columns, which is cosmetic.
5. **`x_deriv`/`s_update` ([§5.2][s5-2]).** The §5.2 signature block (old 703–709) names both. MATCH.

Verdict: PASS. Fix 2's parentheses are worth the one-line reorder above.

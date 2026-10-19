# Unit G verification

Counts: 158 claims. MATCH 154, DRIFT 4, LOST 0. ADDED 23, all glosses, transitions, pointers or ruled. The one that changes meaning is inside C-140, counted as DRIFT. The split items V2a to V163b are appended to `verify_phase1.md`.

## DRIFT

- **C-140.** New: "where `SimpleAtmosphere` and `NoWind` are Flight.jl's atmosphere types". This says the rig uses Flight.jl's types. D-139 says "the `SimpleAtmosphere` successor", and `HorizontalTerrain` has no owner (Q2). Fix: "named after Flight.jl's …".
- **C-125.** Old: "In a thin rig it is … or a constant source holding a bulk-data one". New: "It can also be a constant source …". The constant source is no longer tied to the thin rig. Fix: "In a thin rig it can also be …".
- **C-149.** Old: "traced and checkpointed by value". §4.4 975–979 says only "recorded with the run by value". Fix: keep "traced and checkpointed by value" in the pointer sentence, or accept the loss under M66.
- **C-075.** Old: "C172 migration audit". New: "An audit … against this obligation took one afternoon (D-070)". It drops "migration". D-070 bullet 5 carries the findings, not the duration. Fix: "A migration audit"; move D-070 to "Its findings … follow".

## Citations

Every old citation survives (§13 became §13.5; §13.7 was removed as ruled). Each citation rulings.md adds or replaces is carried by the field it names, D-406's Rationale included for `PathResolution`.

Gap: V159, the isbits-only root input, has no citation. D-364's first Position sentence rules it, so cite it there, plain.

## Bold

18 bolds. Each carries its D-entry, none sits on mechanism or a lead-in, and none repeats a ruling. D-071's seven map onto its Position and bullets 1–6. D-277's three, plus its share of the lift bold, map onto its own rulings. D-070 bullet 3 is bold once, at V48.

Under `brief_common.md`'s test, D-277's second half (V119) and bullets 1–3 are rulings left plain. That is under-bolding (Q3). I lean toward keeping them plain, but it needs a ruling.

## Moves

- M57/R11: the eleven names and their order match `src/trim.jl` 146–156.
- M59/R15: only C-085 and C-086 left, the companion holds them, and the pointer V86 stays.
- M60 and M66 are done, and the R6 homes are kept. No other moves.
- R10: V96 says "would be chosen", and unit F states the fallback is unbuilt.

## Reader-cold names

1. Flight.jl machinery:
   - The `Model`s in "the ad-hoc atmosphere and terrain `Model`s inside Flight.jl's `linearize`" clash with the spec's `Model` (V11). Write "FlightCore `Model`s".
   - "FRC" in "idle/FRC clamps" has no gloss.
   - `HorizontalTerrain` (Q2).
2. Aerospace: "wingman", "lead" and the `"wing"` mount (V130, V132, V169) never say that the wing is a second aircraft. Add a clause: "a wingman aircraft mounted at `"wing"`".

## Other

- §14.9's first `override` (line 198) is unlinked (F67).
- Lines 180 and 293 run past the wrap width.

## Re-check (after R28–R30)

`checks/build_inventory.py ch14 G`: 159 claims, 25 added, 0 failed checks, no uncovered words. 19 bold spans.

- C-075: OK. "migration" is back, and D-070 now sits on the findings sentence. The inventory's C-075 still lists D-070, which now cites the next sentence; that is bookkeeping only.
- C-107: OK under R28. The bold is the headline only, and D-277 is in the sentence. No other bold of this ruling exists in the frozen spec (the glossary's `#g-at` is plain) or in the siblings' new.md.
- C-117: OK. "For a wingman aircraft mounted at" claims only what the example implies.
- C-125: OK. The thin-rig scope is restored.
- C-140: OK under R29. `atmosphere.jl` 153 and 260 confirm the owners, and `HorizontalTerrain` is left unowned.
- C-141: OK. `Model` is FlightCore's (`lib/FlightCore/src/modeling.jl` 89).
- C-144: OK. D-364's first Position sentence carries it.
- C-149: OK under R30. It matches old, with §4.4 and D-237 kept on the pointer clause, and "one" refers back to root input.
- FRC gloss: OK. `piston.jl` 229 and 296 say "friction constraint compensator", a bounded PI submodel beside `idle`.
- `override` link: OK. Its gloss is a subset of `#g-override`. Unit F links `override` in §14.8, but this link is in §14.9, a new section, so it is not a duplicate. The inserted sentence breaks no pronoun's antecedent.
- Neighbouring claims, antecedents and citations are intact. Nothing new.

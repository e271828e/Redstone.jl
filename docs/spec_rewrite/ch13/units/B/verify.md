# Unit B: cold verification

## Counts

198 inventory claims: MATCH 197, DRIFT 1, LOST 0. ADDED: 5 sentences and 4 labels, one of which changes scope (V62). Phase-1 splits are appended to `verify_phase1.md`.

## DRIFT

- **C-026, the table header.** Old and new both say "what the walk enforces". After F3 the three rows take three rules, the one-level rule, the service walk and the instance walk, so "the walk" has no antecedent. Fix: "what resolution enforces".

## ADDED that claims more than a pointer

- **V62–V63.** "A runtime failure is a throw inside a frame … or inside boundary zero. The framework catches it at one site." Device-side failures, covered last, are caught by the device wrapper (V182–V185). Fix: "A runtime failure of model code is …".

## Hazards checked

- **R2, R16–R18.** Nothing says a binding takes the instance walk. The attach sentence sits in the service warrant with the did-you-mean and D-406.
- **F2.** The cut claims are false (`src/assembly.jl` 547, 573; D-406). The table keeps the true parts. The did-you-mean lives on at V41.
- **F3.** Apart from the header, every "walk" has its antecedent.
- **§13.4 order.** "Stop path", "graceful tail", the loop's disposition and the recipe each come before their later uses. The eight labels follow part C.
- **M7.** Frozen §12.4 at 9199–9205 holds the trimmed clause, with D-268 and D-398.
- **Code blocks.** Only F12 and F13 changed them.
- **`StepError{C}`.** Its parameter is the cause's type only.

## Citations

- **V19, D-130.** D-130 supports "renames break loudly" only through "drift still loud at attach (`ReadBindingUnresolved`)". R2 overturned that inspection-binding clause, and D-406 retired the kind. Fix: drop D-130 here. V20, V54 and V58 cite clauses that stand.
- **D-310 in the inspection row** carries the removal of the GUI panels, not what the row says. R16 rules it, so no fix.
- **D-235 at V93** carries the table-write throw. The single-diagnostic carrier is D-221's, cited in the next sentence. Acceptable.
- Every other added or replaced citation carries its claim. The old citations survive or move as ruled.

## Bold

12 bolds, one per ruling, each with its entry. D-157's two match its Position. D-274 bullet 7 is bold nowhere else. No findings.

## Reader-cold names

None.

## Open questions

1. **Log inspection.** D-407's `series` resolves through the strict read resolver (`src/sim.jl` 2252, `source = :table`), the same class of problem as F1. Only `port` over a retained snapshot reads the address table. Does "log inspection" under the instance walk hold?
2. **D-061 after F3.** V2's bold cites D-061, whose Position gives `resolve` the declared-type walk. The public `resolve` is now one level. Track 2 annotates D-130 and D-242 but not D-061.

## Re-check (after the fix list, R25, R26)

Fixes landed: 3 of 3. Regressions: 0. R25 holds.

- **C-026.** The header now reads "what resolution enforces". Every row reads correctly under it, the instance walk included.
- **V19.** D-130 is dropped and D-061 stands alone. D-130 is now cited only at V20, V54 and V58, and each of those clauses still stands. D-061 carries "renames break loudly" no better than before, but that is an old citation, unchanged here.
- **V62.** It now says "A runtime failure of model code …". The parts sentence still lists device-side failures, and that part now reads as a contrast. The fix left line 88 unwrapped, which is cosmetic.
- **R25 against D-407's Position.** `series` resolves a read set "through the one resolver every reader shares ([D-406])". Its `at` mounts the set (bullet 1). So the service warrant, "checked at the authoring or mount level" with the mount prefix, applies to it. D-407's Spec field lists §11.2. The neighbours still hold:
  - "Drift stays loud" stays scoped to a binding.
  - "The services and the readers split their own paths through the service walk" covers `series`.
  - "Snapshot and log inspection" stays distinct from "log extraction by `series`".
- **R26.** No text changed. V2's bold keeps D-061.
- **claims.md** records each fix with "verifier" in its note. The note on the service row names R2 alone, though its `ruling:` field lists R2 and R25. That is cosmetic.

No open questions.

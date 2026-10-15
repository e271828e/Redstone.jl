# Unit F: cold verification

## Counts

207 claims: MATCH 206 (C-116, C-133 and C-137 checked at §11.1 and §11.3), DRIFT 1, LOST 0. ADDED 21 (context, glosses, labels), none meaning-changing. Splits V10a–V233b are appended to `verify_phase1.md`.

## DRIFT

- **C-086** (antecedent). Old: "…passed to the loop and its publications as the policy is, and each snapshot's status carries their frozen record". New: "The status of each snapshot (the immutable per-boundary publication) carries their frozen record", now its own sentence. "Their" can read as the snapshots'. Fix: "carries the pacer's frozen record".

## Citations

Every old citation survives or moved with its claim. M51 and M53 took §11.1, §11.3 and §13.4 to targets that hold them (spec 6870–6871, 6894–6896, 7262–7264). I read each added or replaced citation in `rulings.md`, and the named field carries the claim. D-060's "never a callback" rests on its Rejected `stop_when` item. Nit: `rulings.md` names `h2` for log lines, but its line numbers match `h1`.

## Bold

There are 21 bolds. Each is a headline clause with its D-citation, and none is on mechanism or a lead-in.
- The Rationale-only bolds (D-088 ×2, D-093) are allowed by "Cite the entry that rules". Keep them.
- D-255's Position sentence is one ruling with two bolds. Each bold also rests on its own entry: `Run` on D-260 Position, the policy on D-316 bullet 6. Keep both.
- V100 states D-260 bullet 3 plain before the bold policy sentence. This is fine, since R5 makes that block the home.
- "`errored` is terminal" is also bold in §14 (11031). That one belongs to chapter 14.

## Hazards

- R13: the context defines *door*, `feed`, the input mode and frame before use. It claims nothing beyond D-218, D-260 and the glossary. Only M52 moved, and the table is verbatim.
- R5: all four kept sentences survive. D-310's clause is bold and cited.
- R14: no `Model` door is left, and `live!` is never called a door.
- R12: all four sites are done.
- F58–F79: applied. F79 keeps "on the pacer".

## Other findings

- The input-mode link sits at V137. Move it to its first use, the context's V59.
- `checkpoint's` (V75) comes before its link (V80). This order is inherited.
- "It runs no sweep" (V211) is §12.6's first *sweep*, and it has no link.
- "same-[boundary] (gloss) fresh" puts a link inside a compound, as F66 did. Suggest "fresh from the same boundary (gloss), by topological order".
- Bare *cell*: "the frame's own cell" should be "diagnostic cell", as `rulings.md` proposes. F64's "the cell written" should be "the staging cell written", since a dictated wording is a target.
- Unglossed links: keep both. `sweep` sits in a verbatim chain. `holding` would need a second parenthetical, and its link defines it.

## Reader-cold names

- (1) "the migration suite" (V154) stays per R6.
- (2) "trim" (V10) is used before its §14 pointer at V41. Avionics and FSM are glossed.
- (3) FlightCore's names are all introduced.

## Re-check

Every changed sentence and its neighbours match old.md, the inventory and their sources.
- C-086: "the pacer's frozen record" fixes the antecedent. DRIFT closed.
- C-082 (R20): "the frame's own diagnostic cell" is correct. §11.8 (spec 8432–8435) says the `Model` "owns one more" diagnostic cell, which its frame writes. D-317 bullets 1 and 5 agree.
- C-131 (R20): "the staging cell written" is fine. The gloss's antecedent holds.
- C-020: "fresh from the same boundary (gloss), by topological order" keeps the contrast with "one boundary staler".
- The input-mode link now sits at its first use (context). The §12.6 `sweep` link at "runs no sweep" carries the glossary's gloss. §12.5's verbatim chain keeps its unglossed link, as recommended.
- `build_inventory.py ch12 F`: 207 claims, 21 added, no uncovered words, 0 checks failed.

Clean.

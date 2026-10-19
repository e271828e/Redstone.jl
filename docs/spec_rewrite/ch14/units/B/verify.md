# Unit B: cold verification

Counts: 191 claims. MATCH 188, DRIFT 3, LOST 0. ADDED 12, all ruled (F16, F27, F28, R5, R14) or glosses and pointers.

## DRIFT

- **C-029** (V33): "one address space for every reader of the model" no longer holds, because snapshot inspection now reads by path and port name (V79, F21). Fix: "every reader that takes a selector".
- **C-064** (V76): "therefore" now follows the scope-guidance sentence, not the export-chain sentence it followed. Fix: move V76 after V71.
- **C-078** (V29): "building the tree, which allocates nothing (§14.2)". §14.2 qualifies this "with literal prefixes" (units/A/new.md 202), and V14 admits prefixes computed at run time. Fix: add the qualifier.

## Citations

Every field rulings.md names carries its claim, except:
- D-125's Position states V71's export-chain claim, but V71 cites only §14.9. R5's target cited both. Fix: "(§14.9, D-125)".
- D-060 (V84) carries "run policy", not "no path selector reaches". That clause is D-316's. Optional: add D-316.
- For landing: the frozen spec has no `[d-NNN]:` definition for D-066, D-095, D-098, D-124, D-125, D-110, D-126 or D-155.

## Bold

24 bolds: D-066 ×3, D-276 ×5 (Position and R19's four), D-067 ×4, D-068 ×4, and one each for D-095, D-098, D-406, D-205, D-110, D-126, D-155 and D-149. Each has its entry in the sentence. units/G/new.md re-bolds none of D-126, D-155's first ruling or D-110.
- D-276 b3: the bold "checked once and baked" is mechanism, and the bullet's headline is not stated here. Fix: bold "the read runs … unrolled at compile time", or leave it plain.
- D-095: the Position's headline is the `get_` prefix (V48), not "closed". Consider moving the bold.
- D-149 is also bold in §9.3 (4689–4692). The landing edit changes only §9.3's site count.

## Moves and hazards

M3, M4 and M5 are done, as are R8 and R5. Nothing else moved. No recording clear (R17). F16 wording holds. The tier table keeps its indent. No site count conflicts with R3.

## Reader-cold names

- V10 "FlightCore's in-place state writes": §14.2 names FlightPhysics' `assign!` as the owner. Align the two.
- These need a clause: `mixture` (V206), weight-on-wheels and `ω_idle` (V173), and "an envelope of trims" (V20).
- "warn-but-assign" (V175) is defined only in §14.8, as in the old text.

## Open, needing a ruling

1. V59 "before any client policy applies": no client policy remains after R5. Drop the clause here and in `#g-selector`.
2. `!stall` (V173) is false. c172s.jl 244 sets `stall = false`, and the asserts at 256–261 do not include it. Fix: "(no weight-on-wheels, `ω > ω_idle`)".
3. "one class" uses a reserved word.
4. D-149's second bold, in §9.3.
5. C-078's qualifier.

## Re-check

`build_inventory.py ch14 B`: 191 claims, 4 added, 0 checks failed, 24 bolds.

- C-029 OK. C-078 / R35 OK, and it now agrees with §14.2.
- C-064 OK: "therefore" again follows the export-chain sentence, as in old.md. New: the move puts the equilibrium sentence between the service read and the inspection read, so "Both resolve under the one service walk" can read as the equation and the inspection read. Fix: "Both kinds of read resolve …".
- D-125 on V71 OK. D-316 beside D-060 OK, and D-316 bullet 6 / the narrowing carries "reads no cell".
- D-276 b3 bold OK: one bold, on the unrolled read the bullet rules. D-095 bold OK on the `get_` headline, and "closed" is plain. 24 bolds, one per ruling.
- R31 OK. "On top of the source rule" still has its antecedent. `#g-selector` is for landing.
- R32 OK, matches c172s.jl 256–261. R33 OK: "group" is no glossary term, and the count is kept.
- R37 OK. units/A/new.md 42–46 holds both plans' contents with the same scope (per leaf, lens, destination, converter; converted values) and the `lens` gloss. §14.4's "baked lenses and converters" keeps a bare link. Nits: both sections now say "compiles two ways" and point at each other; C-005's inventory note ("per-plan sentences sit in each bullet") is stale; V22's line is not rewrapped.
- Neighbours, antecedents and citations: no other breaks.

Reader-cold. R12/R23 require: V10 "FlightCore's in-place state writes". FlightCore holds no trim code (R23), and Flight.jl's trim writes through FlightPhysics' `assign!` (aircraftbase.jl 94), as §14.2 says. For the chapter pass: `mixture` (V206), weight-on-wheels (V173), "an envelope of trims" (V20) and "warn-but-assign" (V175). `ω_idle` is covered by the owner clause on its list.

Second re-check. `build_inventory.py`: 191 claims, 0 failed checks, 24 bolds.
- R38 OK. "the fourth node type" keeps its D-068 bold and clause, and B has no *node kind* left. §14.6's "one kind" is the diagnostic kind, which is correct.
- V10 OK. "the in-place writes of FlightPhysics' `assign!`" matches aircraftbase.jl 94 and §14.2. The line runs past the wrap width.
- "Both reads" OK. The equation is not a read, so the antecedents are the service read and the inspection read.
- "two ways to apply the compiled plans (§14.3)" OK. It is closer to old.md's "two ways to apply one plan", agrees with R37, and repeats nothing from §14.3.
- C-005's note is current.
No neighbouring claim, citation or bold broke.

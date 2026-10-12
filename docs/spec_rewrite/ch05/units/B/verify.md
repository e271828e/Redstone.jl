# Unit B cold verification

## Counts
62 phase-1 assertions. 51 inventory claims: 51 MATCH, 0 DRIFT, 0 LOST. 2 ADDED, neither changes meaning. `check_unit.py` passes.

## DRIFT / LOST
None. Both halves of each "iff … and" stay word for word: the `u` row and the handler law (C-041). The rewordings keep their meaning, for example "lands in that bucket" became "is classified as a wrong-tier fact" (C-022).

## ADDED
- "A store puts its letter in the bundle only when it is non-empty ([D-297])." *Store* means only `x`/`s`/`m` (glossary, spec 12900), so the sentence does not reach `ws`. It repeats the F2 cells. R5 F2 allowed a citation in the table or the sentence after it, not a new sentence. It also puts D-297 next to "never `nothing`-filled", which only D-074 rules. Fix: put `[D-297]` in the F2 cells and drop the sentence.
- The probe gloss quotes glossary 13240 word for word. Fine.

## Citations
Every old citation survives with its claim. The one exception is D-252, which R6 replaced. I checked each citation that rulings.md lists in the log at b08afca, and each carries its claim:
- D-074 Rationale, the bundle law.
- D-297 bullet 6.
- D-285 bullets 3 and 2.
- D-248 bullet 4.
- D-194 Position.
- D-090 Position, and its Rationale for the `m` names-subset predicate.
- D-287 Position.

One minor scope point at C-023. `[D-074]` closes "closed, one set per function per tier", but D-074 rules only closed per-function-kind sets. The per-tier half is D-220's. Fix: move `[D-074]` to right after "closed".

## Bold
Four headline bolds, each followed by its entry: D-074 (Rationale-only, listed), D-285, D-194 and D-090. No bold falls on a mechanism, consequence, definition or lead-in, and no ruling is bold twice.

## Moves and rulings
The absence rule now comes before the hand-down. No other moves. Each ruling is applied as worded:
- R5 F1 at both places, keeping the §13.2 pointer (spec 9257–9264 agrees).
- R5 F2 in exactly three cells.
- R6 with its bold kept.
- R7, which names both kinds. They match Appendix C 12435–12442.
- R9: row 12 bold, row 21 plain.
- R11, verbatim.

No correction was made that the brief does not order.

## Reader-cold names
- Class (1), Flight.jl machinery: none.
- Class (2), aerospace example: none. `ω = 0.0` is a generic state field.
- Class (3), FlightCore as predecessor: none.

`FieldError`, `getproperty` and NamedTuple are ordinary Julia names. `Foo` is a placeholder. The three diagnostic kinds introduce themselves. FSM is spelled out. "names-subset predicate" carries over unexplained, with a pointer to §9.5.

## Glossary
Unit A links `tier`, `port` and `bundle` earlier, so dropping them here is correct. Unit A uses "cells" unlinked (lines 84 and 87) before this unit's `#g-cell`, so §5.2's first *cell* has no link. The orchestrator should fix this in unit A.

## Re-check
1. The fix holds. The D-297 sentence is gone, and `[D-297]` now sits in the `x`, `s` and `m` cells only. The absence rule (new line 18) stands alone again, with no D-297 next to it. The inventory's C-003 and its added list agree. One style nit: the cells use a bare `[D-297][d-297]` placed before "(continuous tier)". The base spec's one table-cell citation is in parentheses. Suggested form: "a non-empty `x_init` (continuous tier) ([D-297][d-297])", or the citation at the end of the cell.
2. The fix holds. `[D-074]` now covers only "closed". The per-tier half stays with D-220 in the next sentence.
3. The fix holds. The table's `#g-cell` link is gone, as R13 orders. rulings.md records it.
Nothing else changed. I compared the rest of new.md line by line with the first read. No antecedent or citation scope moved. `check_unit.py ch05 check B`: checks failed 0.

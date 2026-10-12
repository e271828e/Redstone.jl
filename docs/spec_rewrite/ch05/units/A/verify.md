# Unit A verify report

**Counts.** 39 inventory claims: 37 MATCH, 1 DRIFT (A-021), 1 R3 overclaim (A-028), 0 LOST. Phase 1 found 38 assertions. One of the 13 added items changes meaning. The checker passes, and the signature block is byte-identical to old.md's.

## DRIFT

**A-021: "therefore" reverses the causal link.**
- Old: "**Why.** The executor … issues one fixed call shape".
- New: "The executor … therefore issues one fixed call shape".
- Under "Why." the call shape, the ignored unread fields and the absent order were reasons for the rule. "therefore" makes the call shape a consequence of the rule. spec_style asks that "a reason follows its rule with a plain connective".
- Fix: "The rule exists so that the executor (…) issues one fixed call shape, `fn(comp, args)`."

## Meaning-changing ADDED

**A-028 (R3): "Each bundle field is a view of one of five sources."**
- `y_x`/`y_s` fit none of the five bullets. They sit in `y_direct`'s bundle in the signature block. Spec 744–745, spec 4277–4278 and D-285 bullet 3 source them from the stage-1 probe's return.
- So "each" and "five" claim more than the bullets support. The brief's R3 wording invites this, so escalate.
- Fix: "The views come from five sources." Or add "apart from the stage-1 hand-down `y_x`/`y_s` (below)".

## Checked and fine

- R1's opening uses only spec 130–132 and 157–158. Its roadmap matches the six section titles.
- The `kwarg_decl` and slurp clauses stay within D-074 Rejected (log 2232–2237).
- "pairs" means the same as "entries".
- M1 was done, and it is the only move.
- R2's clause and R11 are applied as worded.
- No factual correction was made.

## Citations

- Every old citation survives with its claim.
- Each added citation's named field, read at b08afca, carries its claim:
  - D-048 bullet B: the graph and the topological sort.
  - D-086 Position: the flat compiled list.
  - D-006 Position: the two stages.
  - D-006 Rejected: no annotations. It is Rationale-only and listed as such. "Anywhere in the design" is the old text's scope.
  - D-074 Position: the hand-off and `x_projection`.
  - D-035 Position: produced-only, one home.
- Splitting A-039 into two sentences leaves its first sentence between two D-035 citations. That is fine by adjacency.

## Bold

- There are four bolds, one per ruling. D-074 is split at its Position semicolon. Each bold is a headline clause followed by its entry.
- No bold falls on a mechanism, consequence, definition or lead-in.
- Units B and C bold different rulings of D-074 and D-035. The base spec outside chapter 5 bolds none of D-006, D-074 or D-035.

## Reader-cold names

- `LowPassFilter` and `PID` are example types carried over from the old text. They are category 2, though generic controls rather than aerospace examples. PID is never spelled out. Optional fix: add "(proportional-integral-derivative)".
- No Flight.jl names appear.

## Other

- "store" is used before its link, as rulings.md's open question 2 notes.
- At assembly, unit B must not add second links to `#g-tier` or `#g-port` in §5.2.

## Re-check (R13, R14, fixes)

All four fixes hold, and the checker prints `checks failed: 0`. The citation counts are unchanged from the first run, and the only new code span is `PID`.

1. **A-021.** The reasons now point back to the rule. "Two more reasons support it" refers to the rule. The D-074 citation scope is unchanged.
2. **A-028.** The new sentence follows R14. It claims no count and no "each".
3. **Cell link (R13).** The gloss matches glossary 12826 at b08afca ("one concretely typed entry of the signal table, one per output port"). "Those cells are the declared ports (§8.2)" keeps the old parenthetical's claim, and §8.2 stays with it.
   - The gloss puts the reserved word "entries" in prose. It is the glossary's own word, so leaving it is fine.
4. **PID.** The sentence is a pure introduction and is in `added`.

No other text changed. Inventory and rulings.md record each change.

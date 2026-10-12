# Unit C verify report

**Counts.** 62 phase-1 assertions. 82 inventory claims: 82 MATCH, 0 DRIFT, 0 LOST. 16 ADDED, none changes meaning. Every added gloss matches its glossary entry at b08afca, and the RHS sentence matches `#g-flow`. `f_ode!` repeats §7.4's gloss (1885–1886). `f_c_c` only points at §3.4. The opening names all six parts, and the last matches unit D's heading "Supervisory inputs: scheduled gains and commanded resets".

**Citations.** Every old citation survives with its claim. Added ones, checked against the log at b08afca:
- D-220 at "two vocabularies": Position head, carried. D-220 at "dependence class": bullet 2 carries only "'direct' naming direct feedthrough", and the words come from the Rationale (8173–8175). R9 orders it, and rulings.md lists it.
- D-112, D-035, D-252 s2, D-194 b2, D-288 b1, D-147, and D-015 at mutable caching: carried.
- D-006: partial. "all-inputs `h_xu`" covers inputs only. D-194 b2 or D-285 b3 carries the hand-down half. Optional fix: add D-194 here.
- D-015 at "run after the sweep": partial. "`f`/`h` read the fresh table" never mentions `g`/`s_update`. R9 orders it.
- D-015 at "must be pure" and at "computer/integrator split": weak. Only Rejected items imply these, and both are listed as Rationale-only. §7.4 cites D-015 for the split.

**Bold.** There are five bolds: D-220 ×2, D-035, D-252 s2 and D-015. Each is a headline clause with its entry in the same sentence. None sits on mechanism, a definition or a lead-in. D-220's two bolds are distinct rulings. No ruling is bold in two places (units A, B, D, E, F; spec 1500–7000). The `y_direct` bold correctly goes plain.

**Moves and rulings.** M2 and M5 are done, and nothing else moved. M5 also swaps two adjacent sentences, which is harmless. §5.2 791 states `DeadStage`. R5 F4, R7, R9 and F11 are applied as worded. R7's kind covers both conditions (§8.2 2781–2787, Appendix C). There is no unordered correction.

**Reader-cold names.** (1) None. (2) "navigation filter's measurement function", "Newton–Euler", "gear friction" and "accelerometer model" all come from the old text. Only the IMU has a pointer, which is acceptable. (3) FlightCore at `f_ode!` is fine. Chapter-cold terms:
- "the sweep" (line 76) is its first use in chapter 5, with no link or gloss. `#g-sweep` sits later, in unit D, and the brief's first-use rule puts it here.
- "guard" (line 130) is the same case.

**Other.**
- Lines 15–17 hold two parentheticals in one sentence, "(the derivative function)" and "(Goebel–Sanfelice–Teel)", against spec_style line 13. Fix: "`f` is the continuous flow, the derivative function, and …".
- Line 100: "The reason is that…" has no object now that the question heading is gone. Fix: "The reason for this departure is that…".
- `[component](#g-component)` (line 57) has no gloss. This was there before the rewrite.
- The antecedent hazards are resolved: "Stage-1 ports break…", "by the fused idiom above" and "That overlap". The third statement of D-015's idiom points back to the first.

## Re-check (R13, fixes)

`check_unit.py ch05 check C`: checks failed: 0.

1. R13.
   - The `#g-store` gloss matches the glossary entry (12900, "the framework-owned home of one of a component's state letters").
   - The `#g-sweep` gloss is the glossary's wording verbatim (12958).
   - The `#g-guard` gloss is the glossary's wording verbatim (13029).
   - The split keeps every claim. The first sentence holds "after the sweep" and the second holds "complete and fresh, own stage-2 ports included". D-015 stays on both, and its scope is unchanged.
   - Nit: the sweep gloss is an appositive, not in parentheses, so D-015 follows the definition of sweep directly. rulings.md lists D-015 once at old 898 and does not record that the split repeats it.
2. MATCH.
3. MATCH.
4. MATCH. D-194 bullet 2 ("stage-1 products through `y_x`") carries the hand-down half, and rulings.md records it.

R16. Line 77 is now the first prose use of "execution order" in §5.3. Unit C otherwise uses it only in headings, and unit D's new.md does not use it. R13's reason for leaving the link with unit D no longer holds. Linking at line 77 would put a gloss inside a gloss. Recommend the sweep gloss avoid the term: "one ordered pass through the stage functions against the current state". The glossary entry for execution order (12934) supports that wording. §5.3 then has no prose use, and no link is needed.

R16 follow-up.
- The sweep gloss now reads "(one ordered pass through the stage functions against the current state)". It matches the glossary's *sweep* entry (12958), with "execution order" spelled out from its own entry (12934). It is now in parentheses, which settles the earlier nit.
- "Execution order" now appears only in headings (lines 1 and 118).
- rulings.md line 64 records the repeated D-015.
- I compared the rest of new.md by eye with the previous re-check (no saved copy to diff against) and saw no other change.
- The checker prints "checks failed: 0".

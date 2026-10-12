# Unit A verification

**Counts.** 46 phase-1 assertions. Inventory: 40 claims, 40 MATCH, 0 DRIFT, 0 LOST. 15 ADDED, all supported, none meaning-changing. `check_unit.py`: 0 failed.

**DRIFT / LOST / meaning-changing ADDED.** None.

**Minor (optional)**
1. A-020, citation scope. D-085 ends "...keep their key segment, so `"aircraft/2/face"` is one level and not two". D-085 Position carries the key segment only. "One level" is D-207's "(container elements included)". Fix: move D-085 to after "keep their key segment", or add D-207.
2. The new `UnknownPort` sentence sits between the rule and "Routing ... is therefore declared level by level", one sentence further from its cause. Fix: place it right after the bold rule.
3. "The root's input `trn`" has no `#g-root-input` link, which survey part F wants in §6.1. Confirm unit B links it at first use, or link it here.

**Hazards**
- R2: claims only the name (D-065 Position "locality law = §6.1's, third instance") and the §14.2 pointer. §14.2 10330–10333 supports "fragments ... follow the same law". The rule is cited to D-207, not D-065. Open issue, already in rulings.md: §14.2 10342–10345 and D-065 Rejected call the law "convention", while §6.1 says `resolve` enforces it. Chapter 14 or a D-065 annotation must fix this.
- R3: the text does not say the tree is Flight.jl's. `trn` as a terrain field handle is supported by walkthrough 303, flight_case_studies 33 and §4.4.
- R6: "at either end of the wire" matches D-113 bullet 1 and Appendix C 12286–12289. `PathResolution` matches Appendix C 12306–12309.
- The assembly gloss matches the glossary ("pure composition", "no dynamics of its own"; a component is "a leaf ... or an assembly"). The face and seam glosses are verbatim. The port and container-children glosses are faithful.
- "The first is ..." comes before "The second consequence". "The ceremony the rule costs" follows the reasons, and its antecedent holds.
- D-207 for parallel routes appears under Rationale-only (log 7582–7584).
- "The face graph is total ([D-207])" is plain, with the citation in its sentence.

**Citations.** All 13 old citations survive. §8.6 moves with M3 onto "has three wiring declarations". Each added citation, read in the log, carries its claim: D-314, D-303, D-085 (see minor 1), D-211 ("D-207's one-level reading unchanged"), D-113, D-065 (name only), D-130 (wiring client strict), D-061 (verbatim walk), D-207 bullet 2 and Rationale. D-061 and D-130 keep the old "generic-boundary" wording, which rulings.md notes.

**Bold.** One bold: "Every connection endpoint names an immediate child and one of its faces", with D-207 Position sentence 1 in the same sentence. The labels and the bold on *total* are gone.

**Moves.** M3 is done. M5 and M6 are added as declared clauses, and the roadmap follows R5's labels. No other moves.

**Reader-cold names.** Class 1: none. Class 2: `Cessna172`, `Systems`, `Ldg`, the legs and `trn` are each introduced in place. Class 3: none. The condition algebra, `at`, `input_passthrough`, `UnknownPort` and `PathResolution` each have a nearby pointer.

## Re-check

Fixes 1 and 2 hold. D-085 now covers only "keep their key segment", which its Position carries. D-207 covers "one level and not two" through its Position's "(container elements included)". `UnknownPort` follows the bold rule directly, and "the wire" refers back to the wire defined in the paragraph above. "The one-level rule" (A-014) removes the ambiguity. It names the bold rule, which never says "one level" itself, but "one-level routing" appears in the same subsection and elsewhere in the spec, so the name is acceptable. "Therefore" now follows the rule and its container clauses, as in the old text, and the rule supports it. The A-014 and A-020 inventory spans match new.md word for word, so both are still MATCH. `check_unit.py ch06 check A`: checks failed 0. Fix 3 was declined because unit B links "root input"; noted.

# Unit C (§11.3) verify report

**Counts.** 123 inventory claims: 120 MATCH, 2 DRIFT, 0 LOST. Two claims map to sibling units: C-047 to G2 and C-111 to H. Both spans exist there and say the same thing. 118 phase-1 assertions. ADDED: the context paragraph, 9 labels, 14 glosses and the 2 R12 sentences. None changes meaning. The checker reports 0 failures.

## DRIFT

- **C-008.** Old: "sources to the build-time ordering, constants within a frame, and the *only* thing…" (three predicates). New: "sources to the build-time ordering and constants within a frame". This can now be read as "sources to [the ordering and constants]". Fix: "Root inputs are sources to the build-time ordering, and they are constants within a frame."
- **C-015 (bold).** Old: "one writer per root input at any time" (a limit). New: "Root-input exclusivity **allows** one writer…", which reads as a permission. Fix: "**Root-input exclusivity permits at most one writer per root input at any time**" ([D-044][d-044]).

## Citations

- **C-068 is wrong in scope.** D-044's clause "a write to a claimed face is `ClaimedFaceEntry` at staging" sits inside the derived-interactive-surface half that D-174 supersedes. rulings.md's own note on D-044 says that half is not cited. Fix: cite [D-174][d-174] instead (Rationale: "`ClaimedFaceEntry` narrowed to it") and list it as Rationale-only.
- I checked these against the frozen log, and each named field carries its claim: D-208, D-031, D-129, D-044 (exclusivity, iff, opportunistic writing), D-174 (Position: the two sources and the one mechanism; Rationale: the derived surface and drains-last), D-192 (Rationale), D-096 ("task-free staging"), D-200 (Rationale), D-047 (Rejected), D-149, D-106 (Position and Rationale), D-108 (Rationale) and D-087 (R6).
- D-087's Position plus its Rejected list cover every item R6 cut (atomic republished roster, acquire-load, next-frame attach, sequence numbers).
- D-216's Position carries only "a refusal that precedes admission". The unknown-face condition rests on Appendix C 13120. Adding `[Appendix C][sC]` there is optional.
- §11.8 and D-250 moved with the diagnostic-cell clause. G2's old.md, lines 129–132, carries both. G2's span covers only the second-greedy case, but Appendix C 13127 states the cell location in general.
- No superseded entry is cited. Rows 145–149 (C-097 to C-104) all MATCH and cite nothing.

## Bold

8 bolds: D-044 ×2, D-174 ×2, D-106 ×2, D-047 and D-261. Each pair rules separate things. For D-044 they are separate Position clauses. For D-174 and D-106, one bold rests on the Position and the other on the Rationale. Each bold is followed by its entry. None marks mechanism, and none restates another.

## Hazards checked

- **R5.** §11.3 keeps the empty complement's legality with a pointer at §11.6 (L108–110), and "render the orphan visibly, never mysteriously ([§11.7])" (L250–251). The `T16000M` label is in H's old.md at line 88.
- **The two "(below)" sites.** At old 7272, §11.4 is the right target: D's old.md line 35 reads "compiled at attach". Old 7216's "drain order a diagnostic fact (below)" is kept as written. I agree with the rewriter's proposal to point it at §11.4: §11.4 has "the order matters only for diagnostics", matching D-044's "drain order stays diagnostic".
- **R4 and R23.** Both match their dictated text. R4 keeps the calling-task gloss.
- **R12.** Both sentences add nothing beyond D-216's and D-215's Positions, except the condition noted above.
- **R18.** The block matches `src/sim.jl` line 1809, `stage!(sim::Simulation, writes::Pair...)`, and its docstring.
- **Context and define-before-use.** Every claim in the context paragraph is stated in the section. *The freeze* gets its gloss at its first use (L86). *Device* appears in the roster gloss (L7) before its link at L35. That is minor.
- **Glosses.** All match their glossary entries. R13's drain gloss is exact.

## Reader-cold names

- No Flight.jl names remain; `T16000M` moved to H.
- Class 2, mild: "throttle and elevator" (L174) has no introducing clause. It was also bare in old.
- `map_input` (L69) has no §11.6 pointer, as in old.

## Other

- "Exclusivity holds because…" (C-020) is acceptable. "Exclusivity is the rule because…" would read more cleanly.

## Re-check

`check_unit.py ch11 check C`: 0 failures.

- C-008: the split reads right, with three predicates again. Fixed.
- C-015: "permits at most one writer" is a limit, as old was. The context's "has at most one writer" matches the bold and the glossary. Fixed, and nothing broke.
- C-068: D-174's Rationale ("`ClaimedFaceEntry` narrowed to it") carries the claim, and rulings.md lists it. Fixed.
- The second "(below)" now reads "drain order a diagnostic fact ([§11.4][s11-4])", which is correct. The other two "(below)" sites (exclusivity, the freeze) still point at text below them in §11.3.
- C-057: D-174's Position lists "staging-shape/shim/merge/scatter compilation, drain, trace". The §11.5 pointer is right for the trace. Fine.
- The new context sentence, "Its writers include [devices] (any attached participants in the periphery)", matches the device glossary entry. "Include" is not exhaustive, and the harness writer is still not named, so it claims nothing beyond the section. One nit: "Its" can attach to "a running model", the nearer noun. Fix: "The periphery's writers include…". *Device* now comes before its use in the roster gloss, so define-before-use is fixed. The "Four parties" count is gone, and the sentence is back to old's list.

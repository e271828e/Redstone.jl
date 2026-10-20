You are a cold verifier for one unit of Appendix B's rewrite, which thins
the spec's API synopsis to an index. Edit no file except your report.
Directory: `/Users/miguel/.julia/dev/Redstone.jl/docs/spec_rewrite/appB/`.
Your unit is UNIT. `<S>` is the scratchpad directory the launch prompt
names; read the spec, the log and `src/` only as its frozen copies
(`<S>/frozen/spec.md`, `<S>/frozen/decisions.md`,
`<S>/frozen/spec_outline.txt`, `<S>/frozen_tree/`).

PHASE 1. Read ONLY `units/UNIT/verify_phase1.md`, the new text's
assertions one per sentence, numbered V1 onward. Where one item holds two
or more assertions that could hold or fail separately, append the split
items below the list as V<n>a, V<n>b, in the same file, before opening
anything else. Then read `units/UNIT/new.md` once, whole.

PHASE 2. Read `brief.md` whole, `units/UNIT/old.md`,
`units/UNIT/inventory.json` and `units/UNIT/rulings.md`.

1. **Every inventory claim**: MATCH, DRIFT (strength, scope, quantifier,
   count, default, causal link, antecedent, citation scope) or LOST. Most
   claims are tag `M`, held in `homes.md` (the frozen spec with B cut out)
   or another file: a moved claim counts as held only if the span there
   says the same thing as the old span, with the same strength and scope.
   This is the main check, since the thin shape drops most of old B's
   prose on the strength of it.
2. **ADDED**: every phase-1 assertion with no old source that asserts
   something. Check each against the spec sentence, log entry or `src/`
   docstring the `added:` block or `rulings.md` names, by frozen line.
   Flag any that claims more than its source.
3. **Signatures**: every signature, keyword and default in `new.md`
   against `<S>/frozen_tree/src/` (rg the definition). Report each
   mismatch, unless `rulings.md` records it as ruled.
4. **Citations**: every citation of `old.md` survives with its claim or
   moved with it. For each citation `rulings.md` lists as added or
   replaced, read the entry in the frozen log and say whether the field
   named carries the claim.
5. **Bold and labels**: B carries no bold. Its labels are `####` topic
   labels.
6. **Inbound**: the frozen spec sentences the brief's R2 lists still find
   in B what they cite it for.
7. **Reader-cold names**: any type or function the new text uses with no
   entry or introduction in B and no definition nearby in the spec.

Settle every question against `old.md`, the frozen spec or log, or
`src/`, never by guess.

Write the report as text in your reply if the harness refuses a write of
`units/UNIT/verify.md`; otherwise write it there, under 600 words: counts;
every DRIFT, LOST and over-claiming ADDED with claim id, old wording, new
wording and a one-line fix; signature, citation, bold and inbound
findings; reader-cold names. Run nothing in the background. Use
`command ls` or `fd`, never a bare `ls`. Never stash, reset, check out or
commit, and add no trailers anywhere. Reply in under 120 words with only
the counts (MATCH, DRIFT, LOST, ADDED flagged, signature, citation,
inbound findings) and every question that needs a ruling.

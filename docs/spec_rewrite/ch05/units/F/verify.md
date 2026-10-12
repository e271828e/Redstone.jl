# Unit F verification

**Counts.** 61 claims: 60 MATCH, 1 DRIFT, 0 LOST. 92 phase-1 assertions. 17 additions, 2 of them meaning-changing.

**DRIFT, F-045 (scope).** Old: "For a simple cycle this reduces to the expected reading: real iff every hop survives." New: "...the expected reading. The loop is real iff every hop survives." Standing alone, the second sentence drops "for a simple cycle" and states the cluster reading that D-245 rejects (log 9254). Fix: "...reduces to the expected reading, that the loop is real iff every hop survives."

**ADDED (a).** "The local variant's name is also unrelated to the local set-tracer mode". This is a claim about naming that no source makes: not old 1170–1175 or 1193–1204, not D-012 or D-245. "A member's map may come from either mode" holds (old 1184–1186; D-245 bullet 3). Fix: "The local variant is not the local set-tracer mode. A member's map may come from either mode, or from structure ([D-245])."

**ADDED (b).** "its tracer tags": the spec never defines the phrase, and D-012 leaves it undefined. The equation with input indices comes from src/tracer.jl (a value carries the union of per-face tags). The brief allows it ("defined by M4's first bullet"), so it is acceptable. But the global bullet scopes tags to one mode, while src's local `Tracer{false}` also carries them. Better: put the gloss in the lead sentence, where it covers both modes.

Other additions are glossary-faithful glosses, headings and an accurate roadmap pointer.

**Specific checks.** "cell values" keeps the claim, and dropping the `#g-cell` link is correct. "The feedthrough tracer has two modes" matches glossary 13672. Headline-first reordering broke no antecedent. Keep "the one evaluation that feeds structure": §9.1 3900–3901 says "the single evaluation-feeds-structure step", and its products are "structural" (3928).

**Citations.** Every old citation survives with its claim. Each added citation is carried by the field rulings.md names. D-012 Position carries "diagnostic-only", "one SCC = one named loop", "schedule-free per-member local trace", "conservative on discrete members (pinned signatures admit no tracer scalar)" and "classification optional on the error". D-245 carries the Position lead, bullet 3 and Rationale 9246–9249. D-140 Rationale 4660–4661 carries "continuous members only" and "both exits". §7.2 item 4 carries the `T = Dual` sweep. Appendix C 12406 matches R7.

**Bold.** Eight, each a headline clause with its D-citation in the same sentence. None sits on a mechanism, consequence, definition or lead-in, and none repeats a ruling. D-245 has one bold per bullet. D-012 has five, per survey table 417–421 (R9). Under the strict semicolon test, D-012 has three segments, so F-010 and F-033 share one, as do F-053 and F-060 (comma-joined). The ruled table governs, so no fix.

**Moves and rulings.** M4 is exactly as ordered, and there are no other moves. R5 F5 is verbatim. R7 appears once. R11 is kept with D-012. There is no unordered correction.

**Reader-cold names.** None in class (1) or (3). Class (2): "stall blending" and "piecewise friction" have no introducing clause. The old text had the same.

## Re-check

All four changes hold. The checker prints `checks failed: 0`.

1. F-045 now reads "...the expected reading, that the loop is real iff every hop survives". The simple-cycle scope is restored.
2. "The local variant is not the local set-tracer mode. A member's map may come from either mode, or from structure ([D-245])." It makes no naming claim now. D-245 bullet 3 ("global, sampled or structural") carries the citation, and it is listed in rulings.md. "The two must not be conflated" still points back to the two variants.
3. "Both are set-tracers" repeats the old bullets' labels. "A traced value carries a set of input indices" generalizes the global bullet's set to both modes. Old 1206 ("Only *inputs* are seeded", with no mode named) and "set-tracer" support that. The tags gloss still has no spec source, as the brief allows, but now covers both modes. The global bullet keeps old 1195's claim intact.
4. R15 is applied. There are six bolds: D-012 three times (F-002, F-010, F-053) and D-245 three times. F-033 and F-060 are plain, each with its D-012 citation in the same sentence.

No other line changed. The inventory and rulings.md match the text.

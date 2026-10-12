# Unit B verify report

**Counts.** 55 phase-1 assertions. 52 claims: 49 MATCH, 3 DRIFT (minor), 0 LOST. 5 declared additions, none change meaning. Checker: 0 failed.

## DRIFT

- **C-014, citation scope.** Old: "…gathered as stored, and the consumer's own arithmetic promotes whatever it reads from it (D-264)". The new text splits this. "The consumer's own arithmetic promotes whatever it reads from it." now has no citation. Fix: add `([D-264][d-264])`.
- **C-023, causal link made explicit.** Old: "whose leaves cannot be enumerated". New: "because its leaves cannot be enumerated (D-236)". D-236's Position gives only the ruling. Its Rationale gives the reason in other words: "The abstract case cannot walk leaves" (log 8865). The case is not listed as Rationale-only. Fix: "**The walk clause decides an abstract entry on the whole declaration**, an entry whose leaves cannot be enumerated ([D-236][d-236])".
- **C-011, antecedent.** "The walk clause admits an opaque leaf on the same terms" now follows the abstract-entry test, so "same terms" can read as that test. Fix: "on the same terms as a pinned or walking leaf".

## Hazards that hold

- The abstract-entry definition matches Appendix D (`u_types` entry = input entry) and §8.2.
- The cell gloss is consistent with Appendix D.
- M1: C-025, C-027 and C-029 match §8.2 2433–2437 in the same scope. The sentence cites D-295 and D-263, not D-167.
- M2: the run sentence keeps "marker scalar", "declaration reading", "no user stage code runs" and the §9.1 pointer.
- Every "walk clause" rename refers to the walk-compatibility clause.
- The remedies are word for word from Appendix C 12303–12304. `WireTypeMismatch` and both remedies stay in §6.1.
- "failure asymmetry" and *first nominal build* are verbatim. F13 is untouched.
- D-048 Rejected (log 1500–1501) carries the root-only sentence, and the case is listed as Rationale-only.
- "local wire" is used, and `TwoProducers` and `UnconnectedInput` are named where their conditions are stated.

## Citations

Every old citation survives except D-167 (superseded) and §9.4 (held in §8.2). Each added entry carries its claim: D-078, D-264 ×2, D-266 bullet 2, D-286 bullet 2, D-295 bullet 1, D-170, D-208. One exception: D-263 bullet 2 says only "Both wire clauses stand", not the tier scope. Acceptable: R1 orders the pair, and §8.2 cites it too. D-263 Rationale and D-048 Rejected are listed as Rationale-only.

## Bold

Five bolds, each a headline ruling with its entry in the same sentence, as R4 orders. No bold on mechanism, consequence, definition or lead-in, and none is doubled.

## Glossary links

One link per term per section. `#g-walked` is on "walking" and `#g-activation` is at the nominal gloss. `#g-tier` and `#g-tick` are gone, and their terms are unused. No missing links. One minor, older issue: `#g-component` is not the first use of *component* in §6.1 (unit A line 22).

## Reader-cold names

None. No Flight.jl names or aerospace examples. The diagnostic kinds and `Pinned` are the spec's own. `Freeze` points to §13.7.

**Moves.** M1, M2 and M4 follow part C's order (R5). No others.

## Re-check

- C-014: D-264 now cites the promotion sentence. MATCH.
- C-023: the relative form is back, and the reason sits outside the bold. MATCH. "an entry whose…" follows "declaration", but "an entry" makes clear it refers to the abstract entry.
- C-011: "on the same terms as a pinned or walking leaf" names both halves of the walk clause's per-leaf rule. That is what the old "on the same terms" meant. It neither widens nor narrows it, and it agrees with D-264. The discrete producer stays in its own sentence. MATCH.
- The neighbouring sentences are unchanged. The only artefact is a line-wrap break after "An opaque leaf", which does not affect rendering.
- Checker: `checks failed: 0`. D-264 now appears 3 times in the new text.

Final: 52 MATCH, 0 DRIFT, 0 LOST.

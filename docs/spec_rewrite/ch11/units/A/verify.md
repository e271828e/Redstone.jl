# Unit A verify

**Counts.** 63 inventory claims: 61 MATCH, 2 DRIFT (citation scope), 0 LOST. Phase 1 found 88 assertions. ADDED: 3 (the §11.1 parts pointer and the drain and staging-cell glosses). None changes meaning. Both glosses match the glossary and R13.

## DRIFT

- **C-031, plane 5.** Old: "all run-scoped", uncited. New: "... all run-scoped ([D-310])". D-310 rules the single topology, not run-scoping. D-093's Position does ("per-run artifacts"). Fix: cite "[D-310], [D-093]", or drop the added citation.
- **C-044, the R3 sentence.** D-310 carries "one task topology". It carries "never from `run!`'s keywords" only indirectly, by withdrawing `gui = true`. It does not carry "after initialization". D-138's Position does: `init!` runs "on the calling task, pre-spawn", and a failure leaves "no task being spawned" (log 4541–4544). Fix: cite "([D-310][d-310], [D-138][d-138])" on that sentence. This answers open question 3.
- Wording, not drift: R3's "is fixed after initialization" can also be read as "never changes after initialization". The old "derived" said when the set is computed. Consider "is decided after initialization".

## Citations

Every old citation survives. §10.7 became §12.7 at replay (F13), which is correct. D-093 moved within its paragraph, so adjacency holds. I checked each added citation against the frozen log:
- D-022: plane 2 and plane 3 share one ruling, joined by "+". Planes 4, the two rules and the consequence each match a separate ruling.
- D-101's Position says the drain is "keyed by frame ordinal". It carries the trace key.
- D-282's Position bullet 3 carries the shared `Build`. It says "immutable apart from its lazily filled activation dictionary", so it backs "immutable" only once the next sentence pre-materializes.
- D-135 (Rationale) and D-138 (Position, "no task being spawned") carry their claims.

## Bold

- D-022 has four bolds on four separate rulings, with semicolons between them. That passes the one-bold test. No other unit's `new.md` mentions D-022. Chapters 5–10 and 12–14 bold none of D-022, D-093, D-310 or D-138. G1 bolds two different D-138 rulings.
- Plane 5 is now the first statement of D-310's ruling, and it is cited there. It also states D-093's run-scoping first. Under "the first in reading order keeps the bold", the later bolds sit on the second statement. Fix: return plane 5 to plain and uncited as before, so it reads as an overview of the paragraphs below.
- The start-gate bold rests on D-093's Rationale. spec_style allows that, and `rulings.md` flags it.
- Open question 1: D-022's fifth ruling is a separate Position ruling stated only here. spec_style allows a bold. Its framing as "One consequence" argues against one. This is the owner's call.

## Glosses missing (first-use links)

- Chapter opening: device, root input, snapshot, claim, roster, drain, trace. Chapter 10's opening has no links at all, so either gloss these or unlink them.
- §11.1: device, boundary, trace, replay, root input (linked inside the drain gloss), snapshot, roster, `Build`, buffer, activation.

## Antecedents

- M2 and F12 read cleanly. "Two rules bind the implementation" now follows the planes it governs. "The fifth plane ..." still resolves after the rules.
- "the published reference" is never introduced as a reference. Plane 3 says only "publishes an immutable snapshot".
- "these patterns" has no antecedent. The old text has the same gap.

## R1 opening

Each roadmap phrase has a source: the section titles, §11.1, or §11.8's "two data channels". There is one tension: "taking root inputs ([§8.6]) as given", yet the roadmap gives §11.3 to root inputs. §11.3 does define a root input as §8.6's root input face, so R1's wording can stand.

## Reader-cold names

- (1) Flight.jl machinery: `SimControl`, `io_lock` and FlightCore's `Model`, owner named through "FlightCore's `sim.jl`". This is acceptable.
- (2) Aerospace examples: "the b frame" and "the ECEF frame" need one introducing clause.
- (3) FlightCore as the predecessor needs nothing.
- Spec terms with no pointer, carried over from the old text: "mappings" (§11.4) and "the pacer's debt absorption" (§10.7).

## Re-check

The checker passes with 0 failures.

**Closed**
- C-031: plane 5 is plain and uncited.
- C-044: it reads "decided after initialization" and cites D-310 and D-138, and D-138's Position carries it.
- Bold order: the D-310 and D-093 bolds are now the first statements.
- The opening has no links.
- F12 reads "the reference to the published snapshot".
- The b frame and ECEF have their clause.
- The §11.4 and §10.7 pointers are in place.
- Every new gloss quotes its glossary entry and claims nothing more. There are no nested parentheticals. The root input link sits in plane 1, outside the drain gloss, and `rulings.md` explains why.

**Still open**
- "these patterns" still has no antecedent. The old text has the same gap.

**New**
1. The boundary gloss swallows §10.3's citation. "rule (boundaries being the published consistency points, [§10.3])" now reads as if §10.3 defines a boundary, but §10.3 is cited for the visibility rule. Fix: "rule ([§10.3][s10-3]), a boundary being a published consistency point,".
2. In plane 3, D-022 moved to "Publication is the outbound path". The sentence that states the ruling, "publishes an immutable snapshot", is now uncited. Adjacency holds. Better: move the citation back to the snapshot sentence.
3. The snapshot gloss "(the per-boundary publication)" follows "At the end of each boundary sequence the loop publishes", so it says nothing new. Fix: use "(the boundary-consistent signal table and framework status)", from the same glossary entry.
4. `rulings.md` lines 25–27 still say "the roadmap links it unglossed, as before", which is stale. Two paragraphs are also run together there.
5. Several lines run past 80 columns (opening lines 9–10, rule 1 line 3, rule 2 line 2) and need rewrapping. "Earth-centred" uses British spelling.

## Re-check 2

The checker passes with 0 failures. The `rulings.md` fix and the US spelling are both fine.

**New**
1. The boundary gloss now separates the lock from its cause. The line reads "rule ([§10.3]), a boundary being a published consistency point, because it is only ever free between steps". Here "because" and "it" can attach to the boundary instead of the lock. My earlier suggested fix caused this. Fix: "because the lock is only ever free between steps".
2. The snapshot gloss lists two of the glossary's five parts with "the", so it reads as complete. It leaves out `t`, the frame index and the boundary index. It also sits directly before a second parenthetical, "([D-022])". Fix: "(a boundary-consistent signal table with its framework status)", or accept it as is.
3. Lines 27 and 100 render at 82 columns.

## Re-check 3

The checker passes with 0 failures. All three fixes are in place.

- Line 22 now reads "because the lock is only ever free between steps". The next sentence's "Transplanting it" still points to the lock.
- The reordered plane 3 sentence keeps every part of the old one: the loop, publishes, immutable snapshot, and at the end of each boundary sequence. D-022 sits on it. It is a MATCH.
- Every line renders at 80 columns or fewer.

There are no new findings.

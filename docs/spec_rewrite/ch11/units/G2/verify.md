# G2 verify report

**Counts.** 126 phase-1 assertions. 97 inventory claims: 93 MATCH, 4 DRIFT, 0 LOST. 10 ADDED (4 glosses, 1 gloss sentence, 3 labels, 2 R12 sentences). None changes meaning. `check_unit.py`: 0 failures. Both code blocks are verbatim (diffed).

## DRIFT

- **C-057** (held in units/C/old.md). Old: "shape, shim, merge, scatter and drain (§11.4); trace (§11.5)". C: "shape compilation (§11.4), the drain, the trace". C does not name shim, merge or scatter, and the §11.5 citation for trace is gone. The substance holds: §11.4 says the shape "carries the same shim, merge and scatter", and D-174 lists "staging-shape/shim/merge/scatter compilation". Fix: C writes "staging-shape, shim, merge and scatter compilation ([§11.4][s11-4]), the drain, the trace ([§11.5][s11-5])", or the orchestrator accepts the wording as held.
- **C-059** (held in C). Old: "The standing rejection is untouched. Opportunistic writing to unclaimed faces "for any device" stays dead (D-044)". C: "Opportunistic writing by autonomous devices does not exist". Two things are lost: the link that greediness leaves D-044's rejection standing, and the quoted phrase, which is D-044's Rejected item. Fix: keep in G2 one clause, "and D-044's rejection of opportunistic writing "for any device" stands ([D-044][d-044])".
- **C-053.** Old: "Rejected, correspondingly (D-177)". New: "… stay rejected". "Stay" claims an earlier rejection. D-177 calls only the side-encoding supertypes "unchanged from the standing rejection". Fix: "are rejected".
- **C-090 (citation scope).** D-045 sits at the end of "A table value … is constructed per device × aircraft pairing, where configurations are made (D-045)". Bullet 3 rules only "declarative binding data with per-axis conditioning params". It says nothing about per-pairing construction. Fix: move the citation to "and it is data-driven ([D-045][d-045])".

## Citations

I read each added or replaced entry. Each carries its claim: D-177 (Position for the roots; Rationale for the defaults, conventions, conformance check and empty enumeration; Rejected for the three alternatives), D-199 Position, D-174 (Position for claim source; Rationale for empty remainder and several front ends), D-044 Position (the enumerated-surface clause, which stands), D-216 Position bullets 1 and 4, and D-250 bullet 5. The two D-216 sentences restate only the Position. F51's sentence does not call §8.1's check a class.

**R6 check.** D-177 carries all three alternatives: the side-encoding supertypes and the optional, unenforced supertypes in its Rejected list, and `sides(b)` in its Rationale. It also carries the dropped argument (log 6501–6504). Lines 7948–7953 stay. One problem: D-177's Rationale says the answer is "annotated inline where §11.6 lists the rejection". The cut removes that inline note, so the log sentence goes stale. rulings.md lists this under no inbound section.

## Bold

There are six bolds, each a headline followed by its entry. No bold sits on mechanism, and no ruling is bold twice. C bolds D-174's two-sources Position, and G2 leaves "`is_greedy` is a claim source" plain.

## Checks on the hazards

- R5: the C spans for C-056 to C-061 exist and hold, except C-057 and C-059 above. The single sentence holds the declaration side and the §11.3 pointer.
- R23: deleted.md holds only old 8013–8016, word for word, and R23 names that span. "It declares no `reads` either…" and the rest of the paragraph survive. "Therefore" now follows from the primitive read, so no antecedent points at deleted text.
- G1 links binding, claim, device, roster, snapshot, drain, diagnostic cell, frame and periphery. G2 relinks none of them.
- Both directions of the conformance check survive, with both bullets. The M55 and M56 order matches survey 2. Terms are defined before use at each seam: "complement" is glossed at V75, and "below" points forward correctly.

## Reader-cold names

- (1) `AbstractAircraft` and "engine families". §8.5 introduces them (old 3201) and is cited in the same sentence, so they are acceptable.
- (2) "JSON telecommand peer" may need a clause. "Elevator" and "stick" are borderline.
- `T16000MBinding` is fine, because G1 introduces `T16000M`.

## Other

- `face` is used unlinked in G1 (G1 new.md 180), so G2's link is not at the first use in §11.6.
- "No privileged class" (V106) and "enumeration contract" use reserved words in another sense. Both sentences are untouched, and "class" is now linked in the section.

## Re-check

`check_unit.py`: 0 failures. Every original finding is closed, and the fixes break nothing.

- **C-059: closed.** New: "The standing rejection of opportunistic writing to unclaimed faces "for any device" is untouched ([D-044][d-044])." The quote is verbatim. The citation rests on D-044's Rejected item (log 1418–1419), and rulings.md lists it as Rationale-only. The sentence has no antecedent hazard, and the next paragraph's start still reads cleanly.
- **C-053: closed.** It now reads "are rejected (D-177)".
- **C-090: closed.** D-045 now sits on "data-driven", which bullet 3 carries. The per-pairing sentence is uncited, as it was in the old text.
- **D-177 stale note: closed.** rulings.md lists it for a track 2 repair.
- **face link: closed.** G2 dropped the link and gloss. "faces" in the conformance check's first bullet now relies on G1's link at its line 180, which is present in G1's new.md now and comes earlier in §11.6.
- **"privileged class": closed.** It now reads "privileged category". The sentence keeps its meaning.
- **C-057: open.** It is unit C's to fix.

New: none.

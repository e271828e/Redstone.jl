# Chapter 14, step 6b: final verification, half 1 (units A and B)

Verified commit `b187775`, current commit `bfcf024`. Logs replayed in order:
`chapter_fixes_1.md` (77 entries), then `ruled_edits_1.md` (6 entries), on
`git show b187775:docs/spec_rewrite/ch14/units/<U>/new.md`. Scripts and
outputs in `scratch_final/h1/` (`replay.py`, `wdiff.py`, `wdiff.txt`).

## Counts

- Hunks: 12 at default context (A 7, B 5), 35 at zero context (A 20, B 15).
  The replay gives both current files byte for byte, so every hunk is
  accounted for by a log entry. No unlogged hunk.
- Edits checked: 83 (A 39, B 44), each one old/new pair.
- Bold spans: A 18 and B 24, before and after. The three changed in each unit
  are entries 7, 29 and B5 (A) and 54, 77 and B6 (B).
- `build_inventory.py`: `checks failed: 0` for A, B, F, G and H. B prints the
  line 277 note; D-414 is still cited in that paragraph (B 126).
- Width: no line over 80 rendered columns, except the exempt tier table
  (B 241–242) and the §14.6 heading (B 288).
- `chapter_new.md` is the current units assembled.
- Findings: 11 (8 on edits, 3 pre-existing link orders in edited sentences).

## The special checks

- R5's recast (B 113–147). Every claim of the verified paragraphs is kept.
  "That inspection" still follows the sentence that names post-run inspection.
  B2's added sentence comes after it, so the antecedent holds. "Of these
  holders" reads as the three holders, and the code bears the claim
  (`src/readers.jl`: an `Executor` is "the only live-store holder"). D-414
  stays cited in the guidance paragraph (B 126). "As authoring guidance" now
  rides on that opening sentence. The citation fault is finding 5.
- B1. The heading is retitled. No in-chapter text quotes the old title.
  Chapter references to §14.4 use the number only, and the roadmap
  ("its application and the read selectors") agrees with the new title.
- B5. "The blend rejection is `ConditionNodeMisuse`" is D-113 bullet 4's
  headline, as one clause. It is the only D-113 bold in the chapter.
  Appendix C's D-113 bold is bullet 1, `UnknownPort`.
- B6. "Projection is the second, and it is unconditional" is D-155's
  headline ruling, as one bold. "The second" takes "the only mover" just
  before it. Unit G's D-155 bold, `TrimCommitResiduals`, is the Position's
  separate ruling after the semicolon.
- P1-35. Every added gloss matches its glossary entry and claims nothing
  beyond it. No term is linked twice in a section. Findings 2, 6, 7, 8 and 9
  are links that do not sit at the first use.

## Findings

1. **Unit A, lines 10–15 (entry 2, P1-1).** The edit cut "which together
   cover the trim service in full". The note in `claims.md` (line 46) says
   §14.9 also relocates tap sets. That does not make the claim false: the
   claim says §14.7 to §14.9 cover trim in full, not that they cover only
   trim. An editorial fix dropped a true claim. Fix: restore it as "…, [§14.9]
   mounting, which with [§14.7] and [§14.8] covers the trim service in full,
   and [§14.10] linearization", or record the cut as a ruling.
2. **Unit A, line 14 against 37 (entry 2).** P1-1 added `override` to the
   roadmap, so it is now the opening's first use of `override`. The link stays
   in the table at 37, with no gloss. Fix: link `override` at line 14 with
   "the ordered, asymmetric layering combinator", and write the table's
   `override` plain.
3. **Unit A, lines 126–129 (entry 15, P1-6).** "`n_eng` is the engine speed
   as a fraction of its rated speed `ω_rated`" now sits between "nothing above
   it should have to" and "Making that locality a schema entry", which puts
   "that locality" two sentences from its antecedent. Fix: fold the gloss into
   the first sentence, as "An engine component knows `n_eng → ω =
   n_eng·ω_rated`, where `n_eng` is the engine speed as a fraction of its
   rated speed, and nothing above it should have to."
4. **Unit A, lines 259–261 (entry 32, P1-35).** "Belongs with the use case
   root-input totality produces" became "belongs with the use case of
   root-input totality (…)". That drops the causal link: totality produces
   the use case `override` serves. `claims.md` line 635 records the change
   but gives no reason. Fix: "belongs with the use case that [root-input
   totality](#g-root-input-totality) (gloss) produces ([§14.6][s14-6])".
5. **Unit B, lines 113–116 (entry 50, P1-35).** Old spec 11652 cited §11.2
   on the replay-to-inspect ("(the replay-to-inspect, [§11.2])"), and §11.2
   carries it ("answered by replaying to 37.2 and inspecting the live
   stores"). The split moved that claim into its own sentence. The citation
   stayed on the first sentence and was not repeated. Fix: "That inspection
   is the [replay](#g-replay)-to-inspect ([§11.2][s11-2]), where replay is …".
6. **Unit B, lines 183–186 (entry 56, P1-35).** The added gloss sentence uses
   "predicate" (185), "tick" (186) and "boundary" (186, twice) before the
   §14.5 links at 213, 204 and 189. Fix: reword so the sentence uses none of
   them ("a guard is the declared function that decides when an event fires";
   "a due component is a discrete component scheduled to run here"; "a
   snapshot is the immutable publication that closes the sequence"), or move
   those three links and their glosses up to this sentence.
7. **Unit B, line 129 against 46 (entry 52, P1-35).** The fragment link and
   its new sentence gloss sit at 129–130. §14.4's first use is "the user
   fragment math" (46). The gloss sentence also breaks the guidance paragraph
   between the scope sentence and the service-read sentence. Fix: link and
   gloss "fragment" at line 46, and write "fragment scoping" at 129 plain,
   with no gloss sentence.
8. **Unit B, line 190 against 198 (entry 58; the order predates the
   edit).** §14.5 first uses "Projection" in the run-order sentence at 190.
   The edited link and gloss sit at 198. Fix: link and gloss at 190
   ("[Projection](#g-projection) (…)"), and write 198 plain.
9. **Unit B, line 296 against 330 (entry 71; the order predates the
   edit).** The edited sentence "baselines layered by [`override`]" is
   §14.6's first use of "baselines". The link sits at 330, with no gloss.
   Fix: link "baselines" at 296 with its gloss, and write 330 plain.
10. **Unit B, lines 220–221 (entry 64, P1-35).** "The stage-on-interaction
    rule (when a GUI widget stages a new value)" reads as a time clause, not
    as what the rule is. Fix: "(the rule that a GUI widget stages a new value
    only on interaction, never per render pass)", after the glossary entry.
11. **Unit B, `claims.md` line 7 (B1's note).** The note says "this
    section's context paragraph says 'the compiled plans'". P1-15 (entry 39)
    cut that clause before B1 was applied. Fix: point the note at "its own
    plan" (B 16, 38) and "A compiled plan" (B 170).

## Re-check

`final_fixes_1.md` (15 entries) was replayed in order on `bfcf024`'s
`units/A/new.md` and `units/B/new.md`, and it gives both current files byte
for byte. `build_inventory.py` prints `checks failed: 0` for A, B, F, G and H.
B still prints the line 277 note, and D-414 is still cited in that paragraph.
No line runs over 80 rendered columns except the exempt table and heading. No
term is linked twice in a section.

Every finding is closed:

1. The claim is restored as "mounting, which together cover the trim service
   in full". Its `claims.md` block (A 41–46) stays tagged R under R1, not F
   as the log says, which is right for R1's roadmap sentence.
2. `override` is linked and glossed at A 14, and the table's `override` is
   plain.
3. The `n_eng` gloss now sits inside the first sentence, and "that locality"
   follows its antecedent directly.
4. "The use case that root-input totality (…) produces" restores the causal
   link.
5. "[replay]-to-inspect ([§11.2][s11-2])" restores the citation.
6. The gloss sentence (B 183–186) no longer uses predicate, tick or boundary.
   The first uses are now at their links (213, 204, 189).
7. Fragment is linked at B 46, with its gloss sentence after the ledger
   sentence. B 129 is plain, and the guidance paragraph runs unbroken.
8. Projection is linked and glossed at B 190. Splitting the sentence leaves
   its claims intact, and B 198 is plain.
9. Baselines are linked and glossed at B 296. `override`'s gloss is an
   appositive, and the bold at B 330 is plain of links.
10. The stage-on-interaction gloss now names the rule, after the glossary
    entry.
11. B1's note (`claims.md` line 7) points at "own plan" and "A compiled plan".

New findings: none. Two nits need no fix. The `n_eng` gloss dropped the name
`ω_rated` from "its rated speed", but the formula still shows it. The baselines
gloss at B 296 states in advance what the D-068 bold at B 330 says.

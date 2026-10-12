# Chapter 6: the final verification (recipe step 6b)

Subject: `git diff 1def444 HEAD` on `units/{A,B,C}/new.md`. That is 12 git
hunks (A 3, B 3, C 6), covering 19 touched paragraphs and 23 logged ids.
Each was checked against `chapter_fixes.md`, `chapter_pass.md` and
`rulings_batch.md`.

## Mechanical checks

- `check_unit.py ch06 check A`, `B` and `C`: each prints `checks failed: 0`.
- Word-level diff: every changed word traces to a logged id. No unlogged
  word change. E2 and E5 change no word.
- Rewrap: every touched paragraph is a greedy fill at 80 rendered columns,
  link markup collapsed. That was tested by re-filling it with
  `scratch_pass/wrap.py`. No untouched paragraph changed. No hunk falls in an
  untouched paragraph.
- Width: no line over 80 rendered columns. B 27 and B 34 measure 81 with the
  `**` markers counted, and 79 rendered.
- Bolds: 13 at 1def444 and 13 at HEAD. Their words are identical after
  links are collapsed.
- Code blocks: byte-identical to 1def444.
- Glossary links: no section links a term twice. `#g-component` appears
  once in §6.1, in unit A. Unit B no longer links it. The leaf walk, contract
  and nominal links each appear once per section.
- `chapter_new.md` equals A + B + C, with blank-line separators only.

## Per hunk

| Id | Paragraph | Verdict |
|---|---|---|
| E1 (A) | §6.1 first paragraph | OK |
| E12 | locality law | OK. Each half keeps its own citation (D-065, §14.2). |
| E13 | sketch lead | OK. The gloss uses the glossary's words. §4.4 stays in the sentence and is the glossary's own source. |
| E14 | ceremony | **Problem**, citation scope. See below. |
| E9 | walk clause | OK |
| E10 | marker scalar | OK. "therefore" keeps the causal link. The gloss matches §6.2. |
| E8 | abstract entry | OK. "Its" binds to the abstract entry. The bold's words are unchanged. The non-enumerability was uncited at base, and D-236 does not state it, so the split loses no citation. |
| E5, E6, E7 | opaque leaf | OK. "Under that rule" follows the identity-rule bold directly. |
| E11 | failure asymmetry | OK |
| RI-1, E1 (B) | unconnected inputs | OK. The wording is exactly what was ruled. |
| E4, RP-2 | §6.2 opening | OK. `dynamics.jl` 108–117: `Wrench` is a "Force and torque combination", with fields `F` and `τ`. |
| E15 | parameters | OK. The bold renders the same words. |
| E3 | ownership boundary | OK |
| E2 | R11 bullet | OK. Rewrap only. |
| E17, RP-4 | idiom example | OK. RP-4's text matches the ruling word for word. `aircraftbase.jl` 49–54 has `Vehicle` holding `systems` and `dynamics` as siblings, and base 3624–3631 has `Systems` exporting `wrench`. "The block above" can only mean `local_wires(::Systems)`, the one block with `dynamics`. |
| E16 | tree walk | OK. "its" refers to FlightPhysics' tree walk. |
| RP-1 | frame | OK |
| E19 | do-not-bundle | OK. "the three quantities" now has an antecedent in the sentence before. |
| E18 | zero total | OK. The rewrap is unchanged, since the first line already fills to the limit. |

### E14: the citation no longer covers the claim §8.8 states

- Base 1271–1273 and 1def444: `... because every level of a realistic tree
  is a generic [seam](#g-seam) (...), where one-level routing was mandatory
  in any case ([§8.8][s8-8]).` One pointer covered the whole sentence.
- HEAD: `... is a generic [seam](#g-seam) (a narrow, named interface kept
  deliberately thin). One-level routing was mandatory at a generic seam in
  any case ([§8.8][s8-8]).`
- §8.8 states the first sentence's claim almost word for word (base
  3652–3654, "Every level of a realistic tree is a generic seam (a narrow,
  named interface kept deliberately thin)"). That sentence now has no
  pointer. The pointer covers only the routing clause, which §8.8 backs less
  directly. The pass dictated this text, and the fixer applied it faithfully.
  The scope change comes from the pass item itself.
- Fix: also cite §8.8 in the first sentence, inside the gloss as E13 does:
  `(a narrow, named interface kept deliberately thin, [§8.8][s8-8]).`

## Cold read of `chapter_new.md`

Nothing reads wrong. Two notes, neither a defect in a hunk:

- RP-4's "the assembly one level above the systems assembly" (line 270). In
  §6.1's sketch (lines 45–47), that level is the root `Cessna172`, with no
  vehicle in between. A cold reader may take the vehicle to be
  `Cessna172`. That is harmless, and the text is as ruled.
- "The block above" (line 272) points 42 lines back, across a `####`
  heading. It is still unambiguous, and the text is as ruled.

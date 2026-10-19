# Chapter 13, step 6b: final verification, half 1 (units A and B)

Every edit to units A and B between `5f21eba` (verified per unit) and
`4de4315`. Logs: `chapter_fixes_1.md` (38 entries and two `claims.md`
diffs), then `ruled_edits_1.md` (B6, B1, B1, B4, B9, B10, B11, B87, then
B1 and B4 amended). Scratch files are in `scratch_final/h1/`.

## Counts

- Hunks: 12 in `new.md` (A 6, B 6) and 42 in `claims.md` (A 20, B 22),
  `git diff 5f21eba 4de4315`. Every hunk is covered by a log entry. None is
  unlogged.
- Edits checked: 48 `new.md` entries (38 fixer, 10 ruled), the fixer's two
  `claims.md` diffs, and the 8 `claims.md` hunks of the ruled edits.
- Findings: 7. One touches a SPECIAL item's antecedent (1). Four are low:
  first use and link order (2, 3), one gloss's wording (4) and one phrase's
  parse (5). Two are cosmetic (6, 7).

## Replay

- `replay.py` applies the fixer's 38 entries to `5f21eba`'s `units/A/new.md`
  and `units/B/new.md`, then the 10 ruled entries. Each old text occurs
  exactly once. The result equals `4de4315`'s files byte for byte. The
  fixer stage alone equals `50e0706`'s files byte for byte.
- The fixer's two `claims.md` diffs apply cleanly to `5f21eba` and give
  `50e0706`'s files. The remaining `claims.md` changes up to `4de4315` are
  1 hunk in A (B6) and 7 in B (B1 three times, B9, B10, B4, B11, B87). Each
  carries `tag: R` and its `ruling: B<n>`, or an `added:` block with a B1 or
  B4 comment, as the log says.
- `python3 checks/build_inventory.py ch13 <U>`: `checks failed: 0` for A,
  B, F and G. F also prints three citation notes, which are not failures.
  Each regenerated `inventory.json` matches its committed file.
  `chapter_new.md` equals the four units concatenated.

## SPECIAL items

- **B1.** The definition matches the code. `resolve_authored`
  (`src/assembly.jl` 1494) has the docstring "The service walk (§13.3,
  D-130)". It follows declared field types alongside instances and refuses
  `:past_generic`. Conditions call it at `src/conditions.jl` 199. `_rebase`
  (`src/readers.jl` 506) calls it for every path selector (`get_state`,
  `get_deriv`, `get_output`). The face selectors take no path. §14.4 holds
  "The read-selector family", so the pointer "the readers (§14.4, D-406)"
  lands. "which follows" can only mean the walk. "run it" is finding 1.
- **B10.** §13.3 no longer names the GUI, panels or a front end. D-310
  stays cited in §13.5 (unit F, line 11, F53).
- **B6.** §13.2's `DeviceCrash` line states the path once: the wrapper's
  catch, and the run going on unless `should_abort`. Its pointers are
  §12.4, §13.4 and §11.6. "A genuine bug" and "reports `DeviceCrash`" are
  gone. §13.4's device paragraph states the path once, in F10's words split
  at the colon. This matches R4's "one clause each" and R6's F10.
- **B4.** §13.5 holds both claims the pointer makes: the scan subsection,
  and "The stop scan is the one such read" (unit F, line 244). The amended
  wording renders §13.5 once.
- **Antecedent repairs.** All four hold. "catches the failure" (B 92). "The
  pass runs" (B 288). "The event's bracketing budget" (A 237), where "the
  event" is the localized event of the sentence before. "The pointer names"
  (B 147).
- **P1-14.** "the face names of `input_wires(c)`" agrees with D-061
  ("`input_faces`/`output_faces` return declaration-ordered face-name
  strings"). It also agrees with the code: `_walked_faces(comp, 1,
  input_wires, first)` takes each pair's face, and the docstring reads
  "an assembly's `input_wires` face names". The edit moved the section's
  first use of *face* ahead of its link (finding 2).

## Other checks that found nothing

- Glosses: each gloss the edits added matches Appendix D's words or
  paraphrases them without overclaiming. The entries checked are payload,
  class, carrier exception, diagnostic cell, framework status, localized,
  drain, root input, device, replay, trace, termination record,
  `should_abort`, port, binding, snapshot, seam, boundary, tick, component,
  guard, RHS, roster, condition, buffer, error locality, `Outputs`,
  did-you-mean and species. The one exception is taps (finding 4).
- No section links a glossary term twice. No sentence the edits made holds
  two glosses (R23).
- Reserved words: the edits removed *class* (P1-4 links it; B87), *kind*
  (B9), bare *cell* (P1-9), *slot* (P1-8), bare *entries* (P1-14) and the
  third sense of *framing* (P1-21). They added none.
- Bold: none of the bold words changed. P1-13 moves D-061's bold whole.
  P1-20 takes the `Model` link out of a bold. P1-27 puts the condition link
  inside one, with its gloss outside. P1-28 adds a plain clause after the
  citation.
- Wrap: every edited line is at most 80 rendered columns, and every
  paragraph is filled greedily. The trailing blank line before §13.3 is
  gone.

## Findings

1. **Unit B, line 28 (B1, amended).** "Every service and the read resolver
   run it over an authored path." The sentence before opens "It is enforced
   by the service walk", and that "It" is the generic-holding rule. A
   pronoun that continues the subject reads as the same referent, so "run
   it" can mean the rule, and then the walk is not defined. Running a rule
   over a path also makes sense, so nothing signals the misreading. Fix:
   "run the walk over an authored path". Rewrap the paragraph and update
   the `added:` block in `units/B/claims.md` to match.
2. **Unit B, line 14 (P1-14).** "they return the face names of
   `input_wires(c)`" is now §13.3's first prose use of *face*. The `#g-face`
   link and its gloss ("the names ports wear on their component's boundary")
   come five lines later, at line 19. Fix: move the link and gloss to line
   14, and leave line 19's "face names" plain.
3. **Unit B, line 146 (P1-29).** "Replay is the ordinary loop re-driven from
   a recorded trace." is now §13.4's first use of *trace*. Its link and gloss
   stay at line 222, in Reproduction. Fix: move the `#g-trace` link and its
   gloss to line 146, splitting the sentence if the two glosses would meet.
   Alternatively, the orchestrator rules that a gloss's own words do not
   count as a use. In A, lines 257–259, the same pattern sits one sentence
   apart.
4. **Unit B, line 44 (P1-29, service row).** "[taps](#g-taps) (the selector
   lists linearization seeds and reports)" drops "declaring what" from the
   spec's own gloss. It now garden-paths as "the lists that linearization
   seeds". Fix: "(the three selector lists declaring what linearization
   seeds and reports)", as at frozen spec lines 11542 and 12475.
5. **Unit B, line 175 (P1-21).** "the constructor refuses it, so it leaves
   the catch unwrapped" can parse as "leaves the catch [site] unwrapped",
   with the catch as the thing unwrapped. Fix: "so it propagates from the
   catch unwrapped".
6. **Unit A, lines 90–91 (P1-29 rewrap).** The rewrap split the link
   `[Appendix` / `C][sC]` across two lines. It renders correctly, but a grep
   for `[Appendix C][sC]` misses it. Fix: keep the link on one line and
   start line 91 with `[Appendix C][sC]`. Rewrap the rest.
7. **Unit A, lines 110–111 against 121–122 (P1-6).** §13.2 now introduces
   "the runtime carrier `StepError` ([§13.4][s13-4])" at 111. At 121 it
   introduces it again: "The runtime carrier `StepError{C}` … ([§13.4][s13-4],
   [D-225][d-225])". R4 (M4) keeps one pointing clause in §13.2. Fix: at 121
   write "`StepError{C}` takes a parameter of its own …", dropping "The
   runtime carrier", which line 111 now says.

## Re-check

This pass checks `final_fixes_1.md` (7 entries, 9 old/new pairs) against the
working tree. It was made after `4de4315`, and nothing is committed yet.

- **Replay.** The 9 pairs replay on `4de4315`'s `units/A/new.md` and
  `units/B/new.md`. Each old text occurs once, and the result equals the
  working tree byte for byte. The `claims.md` diffs follow the entries, and
  each names its finding. `build_inventory.py` reports `checks failed: 0` for
  A, B, F and G.
- **Wrap and links.** Every edited line is at most 80 rendered columns and
  filled greedily. No link is split across lines, and no section links a
  term twice.
- **Findings 1, 4, 5, 6 and 7.** Each is applied as proposed. The new
  neighbours read cleanly. In finding 1, "the walk" can only mean the
  service walk. In finding 7, "of its own" still contrasts with
  `DiagnosticError`'s parameter in the sentence before.
- **Finding 2.** The `#g-face` link and its gloss now sit at line 13, the
  section's first prose use. Line 19 is plain. The gloss splits "face names
  … of `input_wires(c)`". That is clumsy, but it reads correctly.
- **Finding 3.** The `#g-trace` link is at line 145, the first use in
  §13.4, and Reproduction's "the trace" is plain. The gloss is now its own
  sentence, "The trace is the primary record of a session." Lesson 41 asks
  what that sentence claims on its own: that the trace is primary. The
  glossary's `#g-trace` entry carries this in its first words, "the primary
  record of a session". It also says why: "the log is recomputable from the
  trace and never the reverse". The sentence claims nothing more, so it
  passes.
- **Unit A, lines 257–259.** These need no change. Here the earlier
  "trace" sits inside replay's gloss parentheses. The link and gloss come
  in the very next sentence, which is the first use outside a gloss. In B
  the gap was 76 lines across four subsections. Moving the link into A's
  gloss would put two glosses in one sentence (R23), with a link inside a
  gloss.

### Re-check finding

8. **`chapter_new.md`, from line 90.** The file is stale. It no longer
   equals the four units concatenated, so the fixes were applied without
   rerunning `checks/assemble.sh` (recipe, step 6b). Fix: run
   `checks/assemble.sh docs/spec_rewrite/ch13`.

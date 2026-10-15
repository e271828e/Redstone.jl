# Fork F: c31dea1 hunks and citations C1–C37

## Counts

- decisions.md: 3 hunks, all accounted (17 Index rows after D-385's row;
  the 377-line entries block, identical to log 2 part 1 once delinkified;
  17 link definitions).
- spec.md: 30 hunks (36 at -U0), all accounted: 35 chapter 12 hunks by
  C1–C37 and the rewrap, 1 hunk of 17 link definitions. The word diff shows
  only added citations; no word, bold or `**` moved. No chapter 12 line
  outside code blocks and tables exceeds 80 rendered columns.
- Citations: 37 added, matching C1–C37 per entry (D-388 5, D-391 5, D-396 4,
  D-390 3, D-394 3, D-401 3, D-389 2, D-399 2, D-402 2, others 1).
- Findings: 1, a judgment call. No citation sits inside a gloss's
  parentheses. None sits at an E1 or E2 clause or an owner item. C1's D-401
  sits before "because a stop belongs to the run it ended", as the log says.

## Findings

### F1 (judgment call). C22's D-390 sits at D-096's sentence, not at the read-half sentence

- Commit c31dea1, `docs/design/spec.md`, tip line 9451.
- Text: "Advance-assert-advance is `stage!` → `step!` → `latest`
  ([D-096][d-096], [D-390][d-390])."
- Problem: D-390 bullet 1 rules "`latest(sim)` is the read half. It returns
  the current published snapshot, the same immutable value device handles
  read." The spec states that ruling two sentences earlier ("The read half
  is `latest(sim)`. It hands back the same immutable snapshot value …,
  navigated directly for assertions."), which stays uncited. The cited
  sentence states D-096's advance-assert-advance pattern. The log placed the
  citation beside its source entry by rule, so this is a placement call.
- Fix: move `[D-390]` to the end of "… navigated directly for assertions."

## Notes, not findings

- C2 (8683): D-399 sits at "A run's outcome is not a control surface …",
  bullet 1's second half. Its first half, "The control plane is what anyone
  may poke.", is the next sentence and stays uncited. The cited sentence
  states part of the ruling, so it passes.
- C4 (8748): "(§11.3, D-392)" follows the appositive gloss "the list of
  attached device entries" at the end of the sentence. The gloss has no
  parentheses of its own, and the sentence states D-392's ruling. It passes.
- C37 (9856): the sentence says the `restore = false` form serves a seek.
  D-402 bullet 2 rules seekability only. The form itself is B78's owner
  item, which D-274 already covers there. The citation states no new form
  clause.

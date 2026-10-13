# Chapter 11, half 2: the inbound check

Rows: the 286 rows of `inbound.tsv` whose target is §11.5, §11.6, §11.7 or
§11.8 (63, 103, 55 and 65). Each is judged against `chapter_new.md` (§11.5
from line 941, §11.6 from 1107, §11.7 from 1512, §11.8 from 1716). Frozen
copies were used for `spec.md` and `decisions.md`, and the working tree for
the rest. Every row's verdict and note is in `inbound_check_2.tsv`.

## Counts

| verdict | rows |
|---|---|
| OK | 278 |
| RETARGET | 2 |
| MISSING | 6 |
| COMPANION | 0 |
| VAGUE | 0 |

| file | OK | RETARGET | MISSING |
|---|---|---|---|
| `spec.md` | 104 | 0 | 3 |
| `decisions.md` | 132 | 1 | 3 |
| `implementation.md` | 22 | 0 | 0 |
| `pending.md` | 6 | 0 | 0 |
| `extensions.md` | 1 | 0 | 0 |
| `companions/flight_case_studies.md` | 6 | 0 | 0 |
| `companions/frame_walkthrough.md` | 2 | 0 | 0 |
| `companions/inbound_periphery_walkthrough.md` | 5 | 1 | 0 |

Two of the six MISSING rows are losses, both made on purpose by R23. The
other four were wrong before the rewrite. One RETARGET follows R5, and the
other was wrong before the rewrite.

Most decision `Spec` lines whose entry the new section does not cite are
still OK. The section states the content, often under a later entry's
wording, as the old text did. Spec lines of superseded entries (D-109,
D-175) are history and count as OK.

## A finding outside the rows: §11.8's anchor

§11.8's heading changed from "the per-writer cell" to "the per-writer
diagnostic cell". The slug changes with it, so every `[s11-8]` link
definition points at an anchor that no longer exists. Every §11.8 citation
in the 65 rows breaks when the chapter lands, unless these are updated:

- `docs/design/spec.md`: the table of contents (frozen line 75) and the link
  definition (frozen 14727, working tree 14733).
- `docs/design/decisions.md`: the link definition (line 14968).
- `docs/design/companions/frame_walkthrough.md`: the link definition (line
  311).

Old: `#118-diagnostics-and-liveness-the-per-writer-cell`
New: `#118-diagnostics-and-liveness-the-per-writer-diagnostic-cell`

The ToC entry's text changes too. Old: `11.8 Diagnostics and liveness: the
per-writer cell`. New: `11.8 Diagnostics and liveness: the per-writer
diagnostic cell`. No other file outside `docs/spec_rewrite/` uses the anchor.
The headings of §11.5, §11.6 and §11.7 are unchanged.

## Rows that are not OK

### spec.md 12636–12638, cites §11.6: MISSING (a loss, ruled by R23)

The old §11.6 said "The shipped GUI binding is a greedy one". The new §11.6
says "The standard GUI binding is a greedy one" and calls `TableBinding` "the
one shipped binding type". Appendix B's "the shipped greedy one" now
contradicts §11.6. R23 leaves Appendix B to the landing.

Old:

```
  error ([§11.3][s11-3], [§11.6][s11-6]). `TableBinding` is the shipped
  data-driven binding, and the standard GUI binding is the shipped greedy one
  ([§11.6][s11-6]).
```

New:

```
  error ([§11.3][s11-3], [§11.6][s11-6]). `TableBinding` is the shipped
  data-driven binding, and the standard GUI binding is a greedy one
  ([§11.6][s11-6]).
```

### spec.md 14016 (glossary, greedy claim), cites §11.6: MISSING (a loss, ruled by R23)

This is the same loss as the row above, in the glossary. R23 leaves the
glossary to the landing.

Old:

```
legal and reported (`EmptyGreedyClaim`), and the shipped GUI binding is the
shipped instance ([§11.3][s11-3], [§11.6][s11-6]).
```

New:

```
legal and reported (`EmptyGreedyClaim`), and the standard GUI binding is its
instance ([§11.3][s11-3], [§11.6][s11-6]).
```

### spec.md 14099 (glossary, `should_abort`), cites §11.6: MISSING (wrong before the rewrite)

Neither the old nor the new §11.6 says the GUI attaches with
`should_abort = true`. The claim comes from D-138's Rationale (log 4576) and
D-175's Position. D-310 superseded D-175, withdrew `gui = true` and parked
the built-in GUI. No shipped GUI is left to attach. This needs a ruling,
since it removes a claim. I recommend cutting the sentence.

Old:

```
advisory in one deployment and decisive in another. The shipped GUI
attaches with `true` ([§11.6][s11-6], [§12.4][s12-4]).
```

New:

```
advisory in one deployment and decisive in another ([§11.6][s11-6],
[§12.4][s12-4]).
```

### decisions.md 4278 (D-134 Position), cites §11.6: MISSING (wrong before the rewrite)

D-134 calls detection by method presence "§11.6's method-presence idiom".
§11.6 declares sides instead, in both the old and the new text. It rejects
detection by method presence (D-177), and `interactive(b)` became
`is_greedy` (D-174). Under `decisions_style.md` rule 10, D-134 gets an
annotation rather than a text edit.

Old: no annotation.

New, an annotation after D-134's Position:

```
Annotation (2026-10-13): [§11.6][s11-6] no longer detects sides by method
presence. [D-177][d-177] declares them, and [D-174][d-174] replaced the
`interactive(b)` marker with `is_greedy`.
```

### decisions.md 7517 (D-203 Rejected), cites §11.5: MISSING (wrong before the rewrite)

D-203 says "the effective policy already lives in the run metadata (§11.5)".
§11.5 says "The deployment holds no policy", in both the old and the new
text. The termination record carries the terminating advance's policy
(D-255). The rejection's ground still holds, since the policy has one home,
but that home has moved. The fix is a rule 10 annotation.

Old: no annotation on this point.

New, an annotation on D-203:

```
Annotation (2026-10-13): the effective policy no longer lives in the run
metadata. The deployment holds no policy, and the termination record carries
the terminating advance's ([§11.5][s11-5], [D-255][d-255]). The `t_end`
rejection's ground, one home for the fact, stands.
```

### decisions.md 11555 (D-274 Rationale), cites §11.5: MISSING (wrong before the rewrite)

D-274 cites "the persistence deferral of §11.5". Neither the old nor the new
§11.5 states a persistence deferral. §11.5 names disk serialization only as
one consumer of the record format. The deferral lives in `pending.md` ("Log
and trace persistence") and Appendix B.

Old:

```
also the on-disk unit the persistence deferral of [§11.5][s11-5] waited for, and a
```

New:

```
also the on-disk unit the persistence deferral (`pending.md`) waited for, and a
```

A rule 10 annotation would avoid editing the Rationale itself. Under rule 7,
removing the citation is a fragment loss that needs a licence.

### decisions.md 9749 (D-252 Rejected), cites §11.7: RETARGET to §11.2

The dev-mode flag note is in §11.2, at new line 202: "A dev-mode flag that
reads every state field out of the stores is a possible future". The old
text had it in §11.2 as well, so the pointer was wrong before the rewrite.

Old:

```
- *A dev-mode flag publishing every state field ([§11.7][s11-7]'s note):* still
```

New:

```
- *A dev-mode flag publishing every state field ([§11.2][s11-2]'s note):* still
```

### companions/inbound_periphery_walkthrough.md 92, cites §11.6: RETARGET to §11.3 (R5)

R5 makes §11.3 the home of the claim mechanism. §11.3 states that "nothing
downstream can tell the two sources apart" and that there is "one claim
mechanism with two claim sources" (new lines 484–496). §11.6 keeps one
sentence and a pointer at §11.3.

Old:

```
like any other claim and gets the same schema, cell, drain and trace
([§11.6][s11-6]). A second greedy binding attached afterwards finds nothing left
```

New:

```
like any other claim and gets the same schema, cell, drain and trace
([§11.3][s11-3]). A second greedy binding attached afterwards finds nothing left
```

## Notes on OK rows worth a glance

- spec.md 14141 (glossary, checkpoint). §11.5's list now ends "and the
  fingerprint and the deployment" (R26). The glossary entry still ends at
  the fingerprint. The citation holds, but the glossary is a clause behind.
- spec.md 8746 and decisions.md 7296 (the join cap kept out of the header
  and away from replay). §11.5 states this only through its full header
  list and "the deployment holds no policy", as the old text did.
- spec.md 12819 (`stop!(handle)`) and 8457 (the handle carries no pause).
  §11.6 lists the handle's control access as "observe running, request
  shutdown" but never names `stop!(handle)`. The old text did not name it
  either.
- implementation.md 706 ("§11.5's drain thunks"). No spec text uses the word
  "thunk". §11.5 states that every drain records batches against the schema
  list, which is what the thunks do (`src/roster.jl` 143–154).

# Inbound check, half 1 (§14 to §14.6)

Rows are the 356 rows of `inbound.tsv` whose target is §14, §14.1, §14.2,
§14.3, §14.4, §14.5 or §14.6. Every target section has entries in
`inbound_scope.md`, so each row was judged against the listed claims. The
section numbers and titles are unchanged in `chapter_new.md`. Row numbers
below count from 1 in `inbound_check_1.tsv`, in `inbound.tsv` order.

## Counts

| verdict | rows |
|---|---|
| OK | 349 |
| MISSING | 6 |
| RETARGET | 1 |
| COMPANION | 0 |
| VAGUE | 0 |

| file | OK | MISSING | RETARGET |
|---|---|---|---|
| `spec.md` | 130 | 2 | 0 |
| `decisions.md` | 175 | 1 | 1 |
| `implementation.md` | 21 | 0 | 0 |
| `extensions.md` | 1 | 0 | 0 |
| `pending.md` | 1 | 0 | 0 |
| `companions/trim_environment_walkthrough.md` | 8 | 2 | 0 |
| `companions/linearization_walkthrough.md` | 3 | 1 | 0 |
| `companions/flight_case_studies.md` | 4 | 0 | 0 |
| `companions/sample_time_proposal.md` | 2 | 0 | 0 |
| `companions/frame_walkthrough.md` | 1 | 0 | 0 |
| `companions/inbound_periphery_walkthrough.md` | 1 | 0 | 0 |
| `companions/longitudinal_aircraft.md` | 1 | 0 | 0 |
| `companions/migration_outline.md` | 1 | 0 | 0 |

One MISSING row is a loss the rewrite caused on purpose (row 118, R31). The
other five MISSING rows and the RETARGET row were wrong before the rewrite.
Survey 1's part D lists all six, and this check confirms them. None relies
on a sentence that R6 or R37 cut to a pointer. No row relies on R10 or R15,
which touch half 2. No citation says §14.4 enforces a service-side or
inspection-side rule. The rows that cite §14.4 for face reads that outlive
the build (`spec.md` 3473, 7205, 13997; D-129) describe guidance, which R5
keeps.

## Rows that are not OK

### Row 109, `spec.md` 13735 (Appendix C, `ReadSetMisuse`), §14.4: MISSING

§14.4 never stated `ReadSetMisuse`, before or after the rewrite. §14.9
states it (new line 1376), as do §14.10's tap lists. This was wrong before
the rewrite (survey 1 part D, F5). The fix is a landing edit, and the brief
already lists it among Appendix C's carried rows.

- old: ``- **`ReadSetMisuse`** ([§14.4][s14-4]). Error · service · fail-fast. The``
- new: ``- **`ReadSetMisuse`** ([§14.9][s14-9]). Error · service · fail-fast. The``

### Row 118, `spec.md` 14580 (glossary `#g-selector`), §14.4: MISSING

The old §14.4 stated "before any client policy applies". R31 cut the clause
as false after R5, so this loss is deliberate. R31 names this glossary fix
as a landing edit.

- old: `against a source before any client policy applies. Table sources are a`
- new: `against a source. Table sources are a`

### Row 208, `decisions.md` 5009 (D-139 Rejected), §14.2: MISSING

§14.2 names no rejection of init as a third scheduled sweep, old or new. It
rejects the `initialize(::C, spec)` schema entry. The third-sweep rejection
is in D-064's Rejected list. This was wrong before the rewrite (survey 1
part D). The log is annotated, never rewritten (`tools/decisions_style.md`
rule 1), so the fix is a track 2 annotation on D-139:

- old: (none)
- new: `Annotation (<date>): the by-name rejection of init as a third scheduled sweep is [D-064][d-064]'s; [§14.2][s14-2] never stated it.`

### Row 261, `decisions.md` 10212 (D-253 Spec), §14.1: RETARGET to §14.3

D-253's Spec field lists §14.1, which never cites D-253, old or new. §14.3
cites it (new line 311: the face chains come from `Structure`, and the names
are the same at every activation). This was wrong before the rewrite (survey
1 part D, Spec fields). The fix is a track 2 annotation:

- old: (none)
- new: `Annotation (<date>): the Spec field's [§14.1][s14-1] reads [§14.3][s14-3].`

### Row 341, `companions/linearization_walkthrough.md` 370, §14.4: MISSING

The spellings `get_state(path, field[, i])`, `get_input(face[, i])` and
`get_face(name[, i])` lost their trailing index at D-276. §14.4 gives the
leaf address instead. This was wrong before the rewrite (survey 1 part D).
It is a companion fix.

- old:
  ```
  The selectors are [§14.4][s14-4]'s closed family. `get_state(path, field[, i])` names
  a state leaf, with an optional component index for a vector leaf.
  `get_input(face[, i])` names a root input and `get_face(name[, i])` a
  root-exported output face, both with the same index since [D-271][d-271].
  `get_output(path, name[, i])` names a component's own output port.
  ```
- new:
  ```
  The selectors are [§14.4][s14-4]'s closed family. `get_state(path, leaf)` names
  a state leaf, and a leaf address such as `"q[1]"` picks one component of a
  vector leaf. `get_input(leaf)` names a root input and `get_face(leaf)` a
  root-exported output face, taking the same leaf address since [D-276][d-276].
  `get_output(path, leaf)` names a component's own output port.
  ```
  `[d-271]` stays in use elsewhere in the file, and `[d-276]` is already
  defined at line 672.

### Rows 350 and 354, `companions/trim_environment_walkthrough.md` 65 and 537, §14.2: MISSING

Neither the old nor the new §14.2 rejects "init as a third scheduled sweep".
That rejection is D-064's. Both rows were wrong before the rewrite (survey 1
part D). These are companion fixes.

- line 65, old: `sweep is the "init as a third scheduled sweep" that [§14.2][s14-2] rejects by name.`
- line 65, new: `sweep is the "init as a third scheduled sweep" that [D-064][d-064] rejects by name.`
- line 537, old: `pre-sweeping the environment subtree, which is [§14.2][s14-2]'s rejected "init as a`
- line 537, new: `pre-sweeping the environment subtree, which is [D-064][d-064]'s rejected "init as a`
- link definitions: add
  `[d-064]: ../decisions.md#d-064--compose-per-component-init-by-pull-via-fragment-functions`
  after `[d-008]` (line 900). These are the file's only two `[s14-2]` uses,
  so remove the `[s14-2]` definition at line 905.

## OK rows whose cited text needs a landing or track 2 fix

These citations hold: the new section states what they rely on. The text
around the citation is wrong, and it was wrong before the rewrite. Most of
these are already in the brief's "Edits at landing".

| row | file:line | problem | route |
|---|---|---|---|
| 32 | spec 4690–4692 (§9.3) | "namely `init!`, trim setup and trim commit": three sites, and R3 makes four | R3 landing edit, in the brief |
| 48 | spec 7333–7334 (§11.3) | the same three-site list | R3 landing edit, in the brief |
| 130 | spec 14770–14772 (glossary) | the same three-site list | R3 landing edit, in the brief |
| 132 | spec 14780 (glossary) | "all four services"; the opening names five | landing edit, in the brief (R1, F3) |
| 122 | spec 14719 (glossary `#g-baseline`) | "the `baseline` keyword `init!`/`trim!` take"; `init!` takes none | landing edit, in the brief (F26) |
| 100, 101 | spec 13637–13643 (Appendix C) | four `ConditionResolution` sub-kinds; new §14.2 and §14.3 name seven reasons | Appendix C carried list |
| 102 | spec 13644–13645 (Appendix C) | leaf `(path, store, field)`; a `u` payload's leaf is its root input (R9, F11) | Appendix C carried list, in the brief |
| 103 | spec 13647–13649 (Appendix C) | lacks `:set_payload` (F8); "node kinds" where §14.2 says node types (R38) | Appendix C carried list, in the brief |
| 159 | log 3076 (D-095 Position) | six-member family; §14.4 has five | track 2 annotation |
| 161 | log 3172–3176 (D-098 Position) | `capture`; §14.4 says `checkpoint` | track 2 annotation |
| 176 | log 4043–4044 (D-122 Rationale) | the next clause's `baseline` keyword of `init!` (F26) | track 2 |
| 185 | log 4310–4312 (D-130 Position) | device read bindings under inspection, against D-414 | track 2 |
| 256 | log 9606–9609 (D-242 Position) | bindings and GUI panels under inspection, against D-414 | track 2 |
| 138, 139 | D-064 and D-065 Spec | they lack §14.1 and §14.3 | track 2 (survey 1 part D) |

The survey's F1 conflict, `spec.md` 10243 (row 67) against old §14.4, is
resolved. New §14.4 puts bindings and `series` under the one service walk
([§13.3][s13-3]), as §13.3 does.

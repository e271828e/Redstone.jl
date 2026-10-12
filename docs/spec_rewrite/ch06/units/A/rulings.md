# Unit A rulings: the chapter heading and opening, §6.1's context and "How far a path may reach"

Line numbers are `spec.md` lines at `b08afca` unless marked `log`
(`decisions.md`). Claim ids are `inventory.json`'s.

## Corrections proposed

None new. Applied as ruled:

- R9 F3 (A-016): "An `local_wires` pair" becomes "A `local_wires` pair". One
  instance in the unit.
- R2 (added): the locality law named at old 1251–1252, D-065 cited for the
  name only, pointer to §14.2.
- R3 (added): the routing example introduced as a sketch of an aircraft, with
  `trn` a terrain field handle (§4.4). Sources:
  `companions/trim_environment_walkthrough.md` 303 (`trn =
  HorizontalTerrainField(…)`) and `companions/flight_case_studies.md` 33
  ("Field-handle signals through ordinary ports (§4.4)"). The text does not
  say the tree is Flight.jl's.
- R4 (A-013, A-028, A-030): one bold, on D-207 sentence 1. The **Rule.** and
  **Why.** labels go; the term bold on *total* goes, and "the face graph is
  total" stays word for word, citing D-207 in its sentence.
- R5 (A-011, A-015 to A-019): M3 puts the three declarations and "wire"
  before the rule. The roadmap sentence follows the labels "Type-checking a
  wire" and "Connections per port".
- R6 (added): `UnknownPort` and `PathResolution` named.

## Citations added or replaced

| claim | entry | words that rule it |
|---|---|---|
| A-019, "local wire" | D-314 Position, log 13184–13185 | "the child-to-child kind of wire is a 'local wire' in prose". D-303 stays beside it for "wire" (Position bullet 3, log 12740–12741) |
| A-020, container children keep their key segment | D-085 Position, log 2566–2568 | "`"field/1"`/`"field/key"` path segments" |
| A-020, so `"aircraft/2/face"` is one level and not two | D-207 Position sentence 1, log 7552–7554 | "addresses an immediate child (container elements included) and one of its faces". D-085 sits on the key segment only |
| A-023, a name-transparent container's bare keys, one level | D-211 Position, log 7698–7707 | "contributed as children under their bare keys … everywhere a child name appears — wiring endpoints … [D-207]'s one-level reading unchanged" |
| added, `UnknownPort` at either end | D-113 Position bullet 1, log 3437–3439; Appendix C 12286–12289 | "`UnknownPort` is widened with a wire-end discriminator — `source`/`destination`, that end's path and port list". Appendix C: "The wire end (`source`/`destination` …), that end's path, the unknown port name" |
| added, the locality law's name | D-065 Position, log 1912–1913 | "locality law = §6.1's". Cited for the name only. The rule stays stated in §6.1's own words under D-207, as R2 orders |
| added, §14.2 | §14.2, spec 10330–10333 | "The locality law here is the one §6.1 states for connections, now in its third instance … conditions" |
| added, §4.4 | §4.4 (pointer) | field handles; `flight_case_studies.md` 33 |
| A-030, the face graph is total | D-207 Position bullet 2, log 7560–7561 | "The face graph is therefore total — every signal crossing an assembly boundary bears a declared face there". Plain; §9.2 bolds the bullet (R4) |
| A-038, `resolve` enforces the rule | D-130 Position, log 3986–3988 | "*wiring* (connection declarations …) strict as stated" |
| A-039, `resolve` walks declared field types | D-061 Position, log 1821–1822 | "`resolve(asm, path)` walks declared field types alongside instances" |
| added, `PathResolution` | Appendix C 12306–12309 | "For a wiring endpoint reaching past the immediate child, the level it stopped at" |
| A-037, gather parallel routes into a component | D-207 Rationale, log 7582–7584 | listed below |

D-061's Position still says "enforcing §6.1's generic-boundary rule", and D-130
calls the duty "generic-boundary". The citations claim only the walk and the
strict wiring client, not the stale rule name (survey part E).

## Rationale-only rulings

| claim | entry | field | log line |
|---|---|---|---|
| A-037, parallel routes threading many boundaries are the signal to gather them into a component of their own | D-207 | Rationale ("parallel routes proliferating through several boundaries are the signal to gather them into a custom type") | 7582–7584 |
| A-034 to A-036, the ceremony and its computed spellings | D-207 | Rationale ("every level of a realistic tree is a generic seam … the residual ceremony has sanctioned computed spellings") | 7577–7582 |

D-207 says "a custom type" where the spec says "a component of their own".
The spec's words stay. A-029's reason ("its one leak closed") rests on D-207
Rejected bullet 1 (log 7587–7590); it is a reason, not a ruling, and stays
uncited beyond the paragraph's D-207.

## Bold on the same entry elsewhere

None. D-207 sentence 1 is bold only here. Chapters 7 to 10 bold D-207 once,
at §9.2 4032–4033 with D-315, on the face table (bullet 2, read as one ruling
by R4). Units B and C's `new.md` (grepped at the end of this unit's work)
bold no entry this unit cites. Their bolds: B five (D-236, D-264 twice,
D-170, D-084), C seven (D-037 four times, D-311, D-143 twice). With this
unit's one, the chapter has R4's thirteen.

## Inbound citations affected

- Spec 10330 and 10550 (§14.2, §14.4) and log 1912–1913 (D-065) call the
  locality law §6.1's. §6.1 now names it, so they resolve.
- Spec 10342–10345 (§14.2) says "The enforcement status carries over from
  §6.1 as well. The law is convention." §6.1 says `resolve` enforces the rule
  and paths are validated at build, as it did before. Naming the law in §6.1
  makes the clash easier to see. Chapter 14's rewrite and a D-065 annotation
  (survey part D).
- Spec 12286 and 12306 (Appendix C) cite §6.1 for `UnknownPort` and
  `PathResolution`. §6.1 now names both where it states their conditions.
- Kept word for word for outside quotes: "immediate child and one of its
  faces" (spec 3127, 9383; `src/assembly.jl` 282, 350), "level by level"
  (`src/diagnostics.jl` 473), "one-level routing" (spec 3634, 4038, 10325),
  "the face graph is total" (spec 4038, 10335).
- No row names a `####` label of this unit.

## Open questions

None.

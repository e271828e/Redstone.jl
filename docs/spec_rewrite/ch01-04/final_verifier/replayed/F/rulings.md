# Unit F rulings: §4.3 "What a port may hold" to "Granularity, write side"

Old lines are `spec.md` lines at `d3af35a`; log lines are
`scratch_survey/decisions.md`.

## Corrections proposed

1. **The stop request's gloss drops the override.** Old 543–544: "a [stop
   request] (a port that ends the run when it reads `STOP_REQUESTED`)". D-316
   Position (log 13399–13401): "every request ends the run at the first
   publication where it holds, unless the advance ignores it"; §13.5 9837
   bolds "Every request is honoured unless the advance ignores it". The gloss
   is short for a glossary gloss, but read alone it says every such port ends
   the run. Kept as written. Proposed: "(a port that ends the run when it
   reads `STOP_REQUESTED`, unless the advance ignores it)".
2. **"a recorded guarded addition" with no record.** Old 599–600:
   "Field-addressed staging (a lens into struct slots) stays a recorded guarded
   addition, unbuilt." No log entry records it (survey row 142: grep of "lens"
   and "field-addressed" finds only D-066's unrelated lenses, log 1964). D-036
   Rejected (log 1183–1184) records only the read-side field-projection
   connector. Kept as written, uncited. Proposed: the log gains an entry, or
   an annotation on D-045, recording field-addressed staging as a guarded
   addition with its shape; or the sentence drops "recorded".
3. **The composed principle has no entry.** Old 597–599: "The guideline and
   the rule compose into one principle. A port's granularity is set by the
   finest-grained party owning either end …". Survey row 141: no entry (N).
   It is a synthesis of D-036's fourth ruling and D-045's Rejected item. Kept
   plain and uncited.

## Citations added or replaced

- **D-036** at "Stage returns are named tuples of port values, period" (old
  532). Position, log 1169: "stage returns are NamedTuples of port values".
- **D-036** at "A custom struct is a first-class port value" (old 532).
  Position, log 1170–1171: "custom structs are port values — one port, one
  cell, atomic in wiring".
- **D-237** at "A port value's leaves are what the leaf walk reaches through
  `Real`s, static arrays and isbits structs" (old 540–541). Position, log
  8950–8951: "The leaf walk over a port type descends through `Real`s, static
  arrays and isbits structs". Added because the paragraph split separated the
  sentence from the D-237 citation at old 553.
- **D-316** beside §8.2 at "An enum is one leaf, pinned" (old 541). Position
  bullet 1, log 13404–13405: "An enum is one leaf of its own eltype, pinned at
  every activation". Survey part E lists D-316 for row 125.
- **D-237** at "The walk stops at an immutable type that is not isbits and
  treats it as one opaque leaf" (old 545–547). Position, log 8951–8953:
  "stops at an immutable type that is not isbits, treating it as one opaque
  leaf: a cell of that type holds the value itself, reference fields
  included".
- **D-243** moved from "so a `Symbol` mode publishes like any other" (old 551)
  to "A `Symbol` is an opaque leaf too" (old 548), three sentences earlier in
  the same paragraph. Position, log 9202: "The port walk treats a `Symbol` as
  one opaque leaf".
- **D-276** at "Wiring is port-granular" (old 557). Position last bullet, log
  11611: "Wiring stays port-granular ([§4.3])". D-276 stays cited on the
  loose-port sentence (bullet, log 11611–11613).
- **D-036** inside the guarded-addition gloss of "A field-projection
  connector is a guarded addition" (old 562–564), the sentence that states
  what the Rejected item carries. Rejected, log 1183–1184: "field-projection
  connector kept as guarded addition".
- **§5.2**, a pointer added at the first use of "stage 1" and "stage 2" (old
  569–570). §5.2 699: "`y_state` is stage 1 and `y_direct` is stage 2".
- **§6.1**, in a declared sentence added before the sketch, at the first use
  of `output_wires`. It quotes §6.1 1353–1354: "An `output_wires` entry
  sources a face from an immediate child's face".
- **D-036** at the granularity guideline (old 566–567). Position, log
  1171–1172: "granularity guideline: bundle what shares a stage and is
  consumed together".
- **D-045** at the write-side rule (old 587–590). Rejected, log 1436–1438:
  "*Bundled command faces* (`pilot_inputs` as one struct port): kills
  per-field claiming, liveness and trace tag — the port is the periphery's
  atomic unit on the write side too, [§4.3]".

## Rationale-only rulings

- **D-045**, Rejected list (log 1436–1440): the write-side rule, bold (R6,
  rows 138–139 as one bold). The log owes a Position stating that data from
  different external writers or cadences never share a port. D-207 Rejected
  (log 7642–7643) and D-299 Position (log 12664–12666) lean on it.
- **D-036**, Rejected list (log 1183–1184): the field-projection connector as
  an unbuilt guarded addition, plain, cited.
- **D-036**, Rejected list (log 1179–1182): bare-struct returns are rejected.
  Already cited at old 537–538; unchanged.

## Bold on the same entry elsewhere

Grep of every bold span in chapters 5 to 14 of the base spec
(`scratch_survey/bold_spans_all.tsv`) and of units A, C, D and G's `new.md`
(B and E had none when checked):

- **D-237**: §9.5 4790 bolds sentence 2 ("An opaque leaf … embeds nothing into
  a store", accepted by identity). This unit bolds sentences 1 and 3, so no
  ruling is bold twice.
- **D-036**: bold nowhere else in the base spec. Unit E is to bold its second
  ruling (aggregate `y`, row 118); this unit bolds the first, third and
  fourth. No overlap if E keeps to row 118.
- **D-243**: bold nowhere else in the base spec. Unit E's row 99
  (immutability plus frozen references) rests on D-243's Rationale, a
  different ruling from the Position this unit bolds, and is plain since R18.
- **D-276**, **D-045**: bold nowhere else.

None found bold in two places. Units B and E should be re-checked at landing.

## Inbound citations affected

None. The words other passages rely on stay: "the granularity guideline"
(spec 1156, log 4692), "the write-side rule" and "write-side granularity"
(spec 3890, 4488, log 7642, 12665), "opaque leaf" (spec 1443, 1888, 4790),
"An enum is one leaf, pinned" (spec 9814, log 13406), "Wiring is
port-granular" (glossary 13033, log 11611), "field-addressed staging" as a
guarded addition (glossary 13894), "a stage returns a NamedTuple of port
values" (spec 11963), and the `IllegalPortType` conditions (Appendix C 12553).
D-276's Rejected item (log 11649) still finds "[§4.3]'s fan-out".

## Open questions

1. Settled by R15: `ProducedByTwoStages` goes to unit E.
2. Settled by the coordinator: the *leaf walk* link stays. It is §4.3's first
   use, and unit E never uses the term.
3. **"bundle" took a gloss.** "the bundle (the struct-valued port)" at old 537
   is a declared addition, so the reader meets the port sense before §4.3's
   later uses and does not read the glossary's *bundle*. Unlinked, as the brief
   requires. Source: D-276 Rationale, log 11617, "A bundle port such as
   `pose = KinPose{T}`".

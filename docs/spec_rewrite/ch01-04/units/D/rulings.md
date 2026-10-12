# Unit D (§3.4): rulings, citations and questions

Old 612 words, new 769 (`wc -w`). Rulings applied: R1 (i), R5 (glossary
links), R6 (D-056 at rows 75 and 90).

## Corrections proposed

None. No factual problem found beyond those R5 rules. The count "thirteen
integral scalars" holds against §8.6's `x_init(::IMUIntegrals)` (old 3510–3511,
3 + 4 + 3 + 3), as the survey found.

## Citations added or replaced

- [D-056] at the bold, row 75 (old 374). Position, log 1682–1684: "the kinds
  are time bases, sweep-driven vs. tick-driven, and cross-tier coupling always
  routes through table cells". Bold on its headline clause (R6).
- [D-056] at row 79 (old 384–385, cross-tier influence through cells). The
  same Position sentence, log 1683–1684. Plain: the bold sits at row 75.
- [D-056] at row 77 (old 377–378, the halves communicate as siblings).
  Rejected, *All-in-one component kind*, log 1701–1703: "the halves still
  communicate through cells — one home per datum, sole-reader `z`, no
  cross-tier state views".
- [D-020] at row 78 (old 382–383, ticks→events impossible). Rejected,
  *Event/tick fixed-point iteration*, log 776–777: "structurally unnecessary —
  `z⁺` is invisible until the next tick decode". The clause on terminating the
  boundary iteration keeps [§10.6] alone.
- [D-056] at row 80 (old 385–386, the assembly in a trench coat). Rejected,
  log 1701: "an assembly in a trench coat ... so zero expressiveness gained".
  The old "which [D-056] enumerates" stays.
- [D-056] at row 84 (old 407–408, periodic reset, events the wrong mechanism).
  Rejected, *Periodic reset via time-guard events*, log 1710: "hand-rolls the
  tick scheduler".
- [D-056] at row 85 (old 408–409, a discrete-tier write into continuous state
  is forbidden). Rejected, *`z` view in `f` / discrete writes into `x`*, log
  1707–1709.
- [D-141] at row 85 (old 410–411, handlers are the sole resetters of
  continuous state). Position, log 4726: "A continuous component's state reset
  is an event". §5.3 bolds it (old 1090); plain here.
- [D-263] beside [D-056] at row 74 (old 371–372, "They are" exclusive).
  Position bullet 5, log 10442–10445: "Every leaf declares exactly one of
  `init_x` and `init_s` ... The store is the tier marker". §8.2 bolds it (old
  2467); plain here. The log's `init_x`/`init_s` are not imported.
- [D-056] at row 87 (old 416–417, the integrate-and-difference idiom).
  Position bullet 1, log 1686–1687: "The idiom is integrate-and-difference:
  cumulative integrals in `x`, previous-sample latch in the sampler's `z`".
  Plain: §8.6 bolds it (old 3430).
- [D-056] at row 90 moves from "No known case needs it" to the bold headline
  as well, and stays on "No known case needs the escape hatch". Position
  bullet 4, log 1693: "Tick-triggered continuous handlers are the recorded,
  unbuilt escape hatch".
- [§8.6] added four times. (1) R1's topic sentence, "Algebra removes the
  reset ([§8.6])". (2) The IMU pointer, "[§8.6] spells this IMU in full", from
  §8.6 old 3377 ("The strapdown IMU of [§3.4] is spelled here in full"). It
  claims nothing about the notation, which §8.6 does not define. (3) The gloss
  of the latch-back wire, "the integrals consume the sampler's published
  latch", from §8.6 old 3423–3425. (4) The error-model gain. §8.6 describes
  the error model as a discrete child (old 3386, `errors::IMUErrorModel #
  discrete`) and gives the ideal and measured samples separate faces (old
  3400–3401, `sample` "ideal increments" and `sample_meas` "measured
  increments"; 3412–3413).
- Glosses added after verification: "inertial measurement unit (IMU)" at first
  use; "`Dual` is ForwardDiff's dual number", from spec old 1267–1268.

## Rationale-only rulings

All plain and cited; the log owes a Position stating each.

- Row 77, a merged component's halves communicate as siblings: D-056,
  Rejected, log 1701–1703.
- Row 78, the deferred decode makes ticks→events structurally impossible:
  D-020, Rejected, log 776–777.
- Row 80, the all-in-one component is an assembly that buys no
  expressiveness and has costs of its own: D-056, Rejected, log 1701–1705.
- Row 81, the merge hides the sampling interface: D-056, Rejected, log
  1705–1706 ("hides the sampling seam"). Cited by adjacency ("which [D-056]
  enumerates", the sentence before).
- Row 84, a periodic reset is not an event: D-056, Rejected, log 1710–1711.
- Row 85, the first half (a discrete write into continuous state is
  forbidden): D-056, Rejected, log 1707–1709. Its second half has D-141's
  Position behind it.

## Bold on the same entry elsewhere

No ruling is bold in two places. Checked against chapters 5 to 10 of the base
spec (`scratch_survey/bold_spans_all.tsv`) and every other unit's `new.md`
(A, C, E, F and G at the time of checking; none bolds D-056, D-141, D-020
or D-263).
D-056's other bolds are §8.6's: bullet 1 (old 3430), bullet 2 and its two
provisos (3474, 3480), bullet 5 (3593) and bullet 3 (3603). This unit bolds
the Position sentence (row 75) and bullet 4 (row 90), which no other place
bolds. D-141 (§5.3 1090), D-020 (§10.6 6093, 6324) and D-263 (§8.2 2467) are
cited plain here.

## Inbound citations affected

None broken. The terms other files rely on survive: "two leaf classes" in
the title and first sentence (glossary *class*, old 12848, and
`spec_style.md`'s trap), "the strapdown IMU" (spec 977, 3377, 3430, 13922;
`flight_case_studies.md` 16), `f_c_c` (spec 977), "integrate-and-dump" (3430)
and "handlers are the sole resetters of continuous state" (spec 1091's
retarget to §3.4, R9 (ii)).

## Open questions

1. *seam*. R5 unlinks "the sampling seam", and the reserved-word rule asks a
   touched sentence to reword it. Both instances now read "the sampling
   interface". D-056's Rejected list says "sampling seam"; the owner may
   prefer another word.
2. *class*. "inside the merged class" (old 384) now reads "inside a merged
   component", since *class* is reserved. "two leaf classes", "state
   classes" and "two-class taxonomy" stay, as `spec_style.md`'s
   trap allows for the continuous-vs-discrete sense.
3. *model*. "pushed the model into the only form" (old 427) now reads
   "pushed the IMU into the only form that the framework's own linearization
   semantics ...". Lowercase "model" is reserved, and "its own" would
   otherwise bind to the IMU.
4. Settled by the coordinator: the `g-class` link at old 370 stays, glossed
   "its primitive-vs-assembly status" (the glossary's sense). Where the text
   then means the continuous-vs-discrete sense, it says "the two leaf
   classes" (old 376 and 412), the form the glossary records.
5. "the cumulative stores" (old 407) stays unlinked. It may mean the `x`
   store holding the cumulative integrals (`#g-store`) or the integrals
   themselves.
6. `DeclarationOnWrongTier` stays unnamed at "They are" (R12).

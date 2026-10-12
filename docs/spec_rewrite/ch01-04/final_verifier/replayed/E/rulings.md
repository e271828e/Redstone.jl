# Unit E: rulings and findings

Old lines are `spec.md` lines at `d3af35a`; log lines are `decisions.md` at
`d3af35a`.

## Rulings applied

- **R3.** Chapter 4 gains a two-sentence opening. Its sources are the Part I
  roadmap (old 128–129, "the port, the addressable unit through which
  components exchange immutable values") and the four section titles. Both
  sentences are declared additions.
- **R5, F8.** Old 477 "(`dyn.vel`, `dyn.f_c_c`)" becomes "such as the
  illustrative paths `"dyn/vel"` and `"dyn/f_c_c"`", citing D-040.
- **R5, F9.** Old 506 "kind-blind" becomes "class-blind", with D-172 cited in
  that sentence. Grep of the unit for other instances of *kind*: none left.
- **R6.** Bolds: D-004 (row 91), D-121 (row 95), row 99 (D-243 alone; D-231
  moved to the next plain sentence at the verifier's request; row 99 is plain
  since R18), D-172 (row 114, on the faces sentence), D-036's second ruling
  (row 118). Row 112 cites D-034 beside D-016. Row 116 (the periphery atom)
  stays plain and uncited. The labels **Vocabulary.**, **Visibility.** and
  **Rule.** are gone; "Scatter/gather is the whole protocol" is a plain topic
  sentence, since unit F bolds D-036's first ruling at row 120.
- **R12.** `UndeclaredReturnField` is named where §4.2 states its condition
  (old 488).
- **R15.** `ProducedByTwoStages` is named at old 528, "Name collisions across
  a component's stages are a build error", citing §8.3. The kind and its
  citation are a declared addition tagged R15.
- **R18** (step 5). Row 99, "the signal requirement is immutability plus
  frozen references", goes plain and keeps its D-243 citation. No entry rules
  the requirement; whether the log owes a Position goes to the owner.
- **R19** (step 5). "Every component provides two output stages" returns to
  the old form, a gloss on `y_state`/`y_direct` with no citation of its own,
  worded as at old 444–445. The §5.2 citation goes. The claim, here, at §5.2
  old 696, glossary old 12951 and old 1111, goes to the owner.

## Corrections proposed

None beyond the rulings above.

## Citations added or replaced

- D-004 at row 91: Position, "Immutable value signals in a typed signal table"
  (log 403).
- D-121 at row 95: Position, "Bare *cell* denotes a signal-table entry only"
  (log 3728). Again at row 97: "*staging cell* is blessed as a distinct
  compound term (the per-device inbound register, mutated per frame, outside
  the table's publish-once discipline)" (log 3729–3731).
- D-243 at row 99: see Rationale-only rulings.
- D-231 at row 100, "Signals may reference bulk data ... read-only for the
  duration of the run": Position, "The frozen-reference latitude of [§4.1]
  stays with signals" (log 8691–8692).
- §5.2 at row 93, "Every component provides two output stages": removed by
  R19; the claim is a gloss again, uncited as at old 444–445.
- D-040 at row 106: Position, "Slash-string paths ... one canonical form shared
  by declarations, diagnostics, devices and logs" (log 1282–1283).
- D-276 at row 107: Position, "a *leaf address*, a string naming one leaf of
  the addressed field: the field or face name, followed by `.name` and `[k]`
  or `[k,l]` steps" (log 11558–11560).
- D-034 at row 110: Position, "declared = public" (log 1106).
- §5.2 and D-194 at row 111. §5.2 old 833 bolds "An output stage returns its
  port NamedTuple, `y`, and nothing else" (D-194). D-194 Position, "a cross-stage intermediate is an ordinary
  declared port" (log 7059–7060); bullet 2, "An intermediate a later function
  needs is declared" (log 7064).
- D-034 beside D-016 at row 112: see Rationale-only rulings.
- D-172 at rows 114 and 115: Position, "its *faces* are the names those ports
  wear on its boundary ... wiring and the periphery address a child's faces
  without knowing whether it is primitive or composite" (log 6222–6228).
- D-036 at row 118: Position, second ruling, "aggregate `y` = virtual merge,
  gathered per call, never stored" (log 1170).
- §8.3, not §5.2, at row 111's `UndeclaredReturnField` sentence: §8.3 old
  3000–3001, "A *returned port field* declared nowhere is a build error at probe".
  §5.2 does not state it, so its citation moved to the sentence before.
- §5.2 at row 117's `x_deriv`/`s_update`: a pointer to the signature block
  that defines them (old 703–709). A declared addition.
- §5.2 at row 118's `merge(y_x, y_xu)` sentence: a pointer to the signature
  block that names `y_x`, `y_xu`, `y_s` and `y_su` (old 703–709).
- §8.3 at row 119: "Declared-but-unproduced and produced-by-two-stages are
  build errors" (old 2995–2996); Appendix C's `ProducedByTwoStages` row
  cites §4.3 and §8.3 (old 12570).
- §4.1 to §4.4 in the chapter opening: section pointers (R3).

## Rationale-only rulings

- Row 99, "the signal requirement is immutability plus frozen references",
  plain since R18, cited to D-243. D-243 Rationale, log 9210 ("[§4.1]
  requires of a port value immutability plus frozen references"). D-231's
  Position presupposes it, log 8691–8692, and is cited at the next sentence
  instead. The log owes a Position stating the requirement.
- Row 112, the `unlisted` flag is closed, plain. D-034 Rejected, log
  1126–1127 ("*`unlisted` presentational flag:* hidden but connectable"); D-016
  holds it only in a *Superseded position* item of its Rejected list, log
  639–643.

## Bold on the same entry elsewhere

- D-036: unit F bolds the first, third and fourth rulings (rows 120, 121,
  133); unit E bolds the second (row 118). Four rulings, four bolds, no
  ruling bold twice.
- D-243: unit F bolds its Position ("A `Symbol` is an opaque leaf too", row
  128); unit E's row 99 cites D-243 for its Rationale, plain since R18.
- D-231: cited plain at row 100, not at row 99 (plain since R18). Unit C
  bolds "`m` is continuous-only" citing D-231; §7.3 bolds D-231 at old 1880,
  1892, 1975 and 3975. Old 1892, "**The frozen-reference latitude stays with
  signals** ([§4.1], [D-231])", is the store-side face of row 99's
  requirement. The owner may judge whether row 99 and old 1892 state one
  ruling twice.
- D-034 (§8.3 2967, 3009), D-194 (§5.2 833), D-040 (§8.6 3272), D-276 (unit
  F, row 130) and D-016 (§5.3 1019) are bold elsewhere; unit E cites each
  plain.
- D-004, D-121 and D-172 are bold nowhere else (grep of the other units'
  `new.md` and of `bold_spans_all.tsv` from old 672 on).

## Inbound citations affected

None. Every inbound row on §4, §4.1, §4.2 and §4.3 that quotes or names this
unit's text still holds: "throughout this document" (D-121 Rejected, log 3757)
is verbatim; the four consequences (glossary 13024) stay; "the `unlisted`
flag" (§8.3 3025) stays; "[§4.3]'s periphery atom" (D-172, log 6223) and "the
port is the periphery's atomic unit" (D-045, log 1438) stay. D-123's
Rationale (log 3827), which records the "kind" stragglers as closed, now
matches §4.3.

## Open questions

1. **"Every component provides two output stages."** Old 444–445 put this in
   a gloss; the rewrite states it as its own sentence. Survey part B, item 9,
   notes it is not true of an assembly: an assembly provides no output stages,
   and §5.2 old 696 says the same of every component. R19 returns it to the
   old gloss, uncited; the claim in all four places goes to the owner.
2. **The port's gloss in §4.1.** §4.1 links *port* at "Ports exchange
   immutable values" with no gloss, because the bold headline clause cannot
   carry one; the chapter opening, directly above, glosses it as "the
   addressable unit through which components exchange immutable values".

# Unit E rulings: §5.4 and §5.5

Old lines are `spec.md` lines at `b08afca`; log lines are `decisions.md` at
`b08afca`.

## Rulings applied

- **R5, F6** (old 1124–1125): "sampled at `Δt_base`" now reads "sampled on a
  period on the scale of `Δt_base`", which is §13.7's "`Δt_base`-scale"
  (spec 10038). The glossed `#g-dt_base` link stays on `Δt_base` itself.
  Inventory C-058.
- **R7** (old 1115–1116): "The build reports it as `AlgebraicCycle`
  ([Appendix C][sC])." Declared addition. It has no old span, so it sits in
  `added`, not as an R-tagged claim.
- **R10**: §5.4 keeps its shape. The two-stage split stays in prose and the
  two remedies stay as unnumbered bullets. "Two remedies apply, in this order"
  now reads "The ladder's other two rungs are two remedies, and they apply in
  this order" (C-011). Conservatism stays the last paragraph of §5.4.
- **R11**: old 1092–1094 (C-035 and C-036) and old 1126–1127 (C-060) stay,
  with their citations.
- **R12**: after the caveat, "The diagnostic states this caveat rather than
  offering the delay as a free remedy ([§13.7][s13-7])." Declared addition. It
  claims only what spec 10042 says ("The diagnostic ([§5.5]) therefore says so
  rather than offering the remedy as free").
- **Unit E's part C items**: after "Simulink calls this…", one declared
  sentence says that a genuine cycle is a different case, the algebraic loop
  of [§5.5][s5-5]. It sits after the Simulink sentence so that "Simulink calls
  this" still points at sentence 1. The next sentence now says "The canonical
  artificial loop" so its subject stays clear. "The tracer ([§5.6])" becomes
  "The [feedthrough tracer](#g-feedthrough-tracer) (the diagnostic that
  classifies a rejected cycle, [§5.6][s5-6])", from the glossary entry
  (spec 13672–13675).
- **Reader-cold names**, from D-140's Rationale (log 4641–4652) only. The
  pair is "the strut/steering pair of Flight.jl's landing gear". D-140 says
  "the shipped code the finding walked (`landinggear.jl`…)", and the brief
  names it Flight.jl's. One declared sentence introduces `ψ_sw` in D-140's
  words (log 4643–4645: "`Strut` hands the contact-velocity azimuth `ψ_v` to
  the steering model and consumes the returned `ψ_sw`"). The old gloss of
  `ψ_v` moved into that sentence (C-018). `StrutGeometry` takes "in the strut
  example" and nothing more. Castoring keeps its gloss in place.
- **Names the old text left cold** (verifier's fix): `unlisted` and
  `Private(T)` become "the `unlisted` presentational flag and the
  `Private(T)` wrapper, the two visibility spellings they reject". These are
  D-034's Rejected words, log 1119 ("`unlisted` presentational flag"), and
  D-055's, log 1656 ("`Private(T)` wrapper inside `outputs`").
  `migration_outline.md` becomes "the companion document
  `migration_outline.md`". The α-filter gloss stays parenthetical inside the
  routes sentence ("insert dynamics (the α-filter idiom, a filter state
  inserted in the loop)"), so the α-filter is not the only way to insert
  dynamics. The tracer's gloss now follows the glossary: "the instrument that
  classifies a rejected cycle as real or artificial".
- **Wording fixes, no claim changed**: "absorbs most of the class" becomes
  "absorbs most artificial loops", which avoids reserved *class*. "The split
  is rare" and "left for the split" become "the component split", since the
  paragraph also names the two-stage split. "becomes `y_types`" becomes "is
  declared in `y_types`". "The bundle type" becomes "The bundle port's type".
  *bundle* is not linked there, since it means a struct-valued port.
- **Bold labels removed**: "port-level acyclic yet admit no evaluation
  order", "artificial", the lead-ins "Re-factor the contract." and "Split the
  component." (now plain imperative topic sentences), "one struct-valued
  bundle port" and "build error". The old 1045 bold was D-006's Rejected
  list and D-019's Rejected list (survey row 88), with no Position. Part A's
  table gives it no bold.

## Bolds placed

- **"The remedy ladder for artificial loops has three rungs"**
  ([D-140][d-140]), Position, log 4629–4630: "[§5.4]'s escape hatch becomes
  a **three-rung remedy ladder** for artificial loops". This is a declared
  addition that states the ruling. It sits in §5.4's first paragraph,
  before the two-stage split is called "the rung".
- **"An algebraic loop is a build error"** ([D-005][d-005]), Position, log
  414: "Reject algebraic loops at build, explicit breaks." The definition
  that comes before it ("A genuine cycle … is an algebraic loop") is plain.
  "Explicit breaks" is plain in the next paragraph ("The user breaks the
  cycle explicitly"). It is the same ruling, joined by a comma.

## Corrections proposed

None beyond R5's F6, which is applied. F9 is left as written: the quoted
diagnostic at old 1097–1098 stays verbatim, although `src/diagnostics.jl`
920–948 renders other text.

## Citations added or replaced

- [D-140][d-140] at the bold (an `added` sentence). Position, log 4629–4630, quoted above.
- [D-140][d-140] at "That is the test that it records structure rather than
  dodging the diagnostic" (C-025). Rationale (ii), log 4649–4652: "the
  factoring **survives substitution** … which is the test that it records
  structure rather than dodging the diagnostic".
- [D-194][d-194] at "No visibility level is added for the orphaned
  intermediates" (C-035). Position bullet 6, log 7034–7037: "Visibility stays
  binary and [D-034]/[D-055] stay closed: no `Private` level is added, … the
  [§4.3] granularity guideline (one struct-valued bundle port) remains the
  mitigation". The same bullet carries the mitigation two sentences earlier
  in the bullet (survey row 93). It is cited there by adjacency.
- [D-140][d-140] at "The build diagnostic offers both exits explicitly"
  (C-037). Rationale, log 4660–4661: "[§5.6]'s hint offers **both exits**
  ("split this component, or narrow the neighbor's contract")".
- [D-245][d-245] right after "carries the dead hop", before the payload-field
  form (C-040). Position bullet 2,
  log 9230: "Every dead hop is listed under either verdict." It carries the
  listing only. The "rather than dotted onto the path" form has no entry
  (survey row 96, N), and Appendix C 12406–12410 gives the payload as "every
  dead hop (member, input face, output port)".
- [D-140][d-140] at "the ladder is what earns that word rather than asserting
  it" (C-041). Rationale, log 4662–4664: "[§5.4]'s "rare" is thereby
  **earned** rather than asserted — the split is rare *because* rungs (i) and
  (ii) absorb the common shapes".
- [D-005][d-005] at the bold (C-050). Position, log 414, quoted above. It
  was cited before only at old 1127, two paragraphs on.
- [Appendix C][sC] at `AlgebraicCycle` (R7). Appendix C 12406–12410: "Error ·
  build · collected. The SCC's members, the wires among them as terminal
  pairs in slash form …".
- Section pointers added: [§5.5][s5-5] (the genuine-cycle sentence),
  [§5.3][s5-3] (stage-2 conservatism's gloss, which follows the glossary's
  *feedthrough* entry, spec 12852–12855), and [§13.7][s13-7] (R12).
- Not added: D-012 at old 1116–1118 (survey row 100). Its Position ("one
  SCC = one named loop", log 529–530) carries naming the loop, not the
  wire-by-wire slash form this sentence states. Unit F cites D-012 where the
  SCC naming is described. Not added: D-006 at old 1045–1047 (row 88). Its
  Rejected item "Component-atomic conservative: false loops everywhere" (log
  443) is close but rejects a design rather than stating the claim. The brief's
  part E list does not name row 88.

## Rationale-only rulings

- D-140 Rationale (ii), log 4636–4652: the fallback-branch false dependency,
  the strut/steering instance and the substitution test. Cited at the
  substitution test. The log owes a Position; D-140's says only "three-rung
  remedy ladder".
- D-140 Rationale (iii), log 4652–4660: the component split as residual
  remedy, its cost stated where it bites, one struct-valued bundle port. The
  mitigation is in D-194's Position bullet 6 too, which is cited.
- D-140 Rationale, log 4660–4664: both exits in the diagnostic, and "rare"
  earned. Cited at each.
- D-005 Rejected, log 421–424: implicit delays and per-step numerical
  solving are closed. Cited, as before (old 1127).
- Plain, with no entry at all (survey part E): the conservatism consequence
  (old 1107–1111), the three routes (old 1120–1122), the unit delay's tier
  caveat (old 1122–1126, also §13.7 10036–10042), algebraic balances inside a
  component (old 1129–1131) and the dead hop as a separate payload field (old
  1098–1100).

## Bold on the same entry elsewhere

None. No other unit's `new.md` and no passage of chapters 7 to 10 at `b08afca`
bolds D-140 or D-005. The plain citations here share entries with bolds
elsewhere, each for another ruling or one this unit does not bold:

- D-194: unit B bolds its Position sentence 2 (stage returns). §9.3 4297 and
  §9.7 bold other rulings of it. Bullet 6, cited here, is bold nowhere.
- D-245: unit F bolds its bullets 1, 2 and 3. Bullet 2 (dead hops listed) is
  cited plain here.

## Inbound citations affected

- spec 10042 (§13.7): "The diagnostic ([§5.5]) therefore says so". It now
  holds (R12).
- spec 9968 (§13.7): "the second loop-breaking remedy ([§5.5])". It holds;
  the three routes keep their order.
- spec 12929–12932 (glossary *algebraic loop*): it holds.
- `pid_anti_windup.md` 91: conservatism is still "[§5.4]'s last paragraph".
- `pid_anti_windup.md` 95 ("[§5.4]'s first rung", for contract re-factoring)
  and 102 ("[§5.4]'s second remedy", for the split). The bullets stay
  unnumbered, so 102 holds. 95 now reads against "the ladder's other two
  rungs", where the two-stage split is a rung and re-factoring follows it. It
  was already at odds with D-140's numbering. Track 2.
- `migration_outline.md` 108 ("the middle rung"): it now reads against
  three counted rungs.
- `library_inventory.md` 55 and 127, `flight_case_studies.md` 53: they hold.
  The α-filter gloss says "a filter state", which is the companion's own
  words.

## Open questions

1. §5.4's title says "the escape hatch", which the text never uses (survey
   part A). D-140's Position calls the ladder "§5.4's escape hatch". The bold
   sentence could read "The escape hatch for artificial loops is a three-rung
   remedy ladder". I kept the plainer wording and left the title alone.
2. R7's `AlgebraicCycle` sentence, R12's sentence, the bold D-140 sentence and
   the §5.5 pointer sentence have no old span. They sit in `added`, so the
   inventory carries no R-tagged claim for R7 or R12.
3. The `ψ_sw` sentence is an introducing addition from D-140's Rationale. The
   brief's list of names to introduce does not include `ψ_sw`. Without it,
   the diagram's "steering ─────▶ strut" wire has no stated content. Drop the
   sentence if the verifier reads it as beyond "introducing clauses".
4. `check_unit.py`'s code-span diff is noisy for this unit. The untyped
   fence's triple backticks pair up with inline backticks, so it prints prose
   as code. The only real code-span changes are `ψ_v` and `ψ_sw` (the
   introducing sentence) and `AlgebraicCycle` (R7).

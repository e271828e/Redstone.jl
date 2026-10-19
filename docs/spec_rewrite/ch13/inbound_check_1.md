# Inbound check, half 1 (§13, §13.1 to §13.4)

The 266 rows of `inbound.tsv` whose target is §13, §13.1, §13.2, §13.3 or
§13.4, judged against `chapter_new.md` lines 1–612 and `inbound_scope.md`.
Every target section has entries in `inbound_scope.md`, so every row was read
in its file. The verdicts and notes for each row are in `inbound_check_1.tsv`.
Row numbers below are data-row positions in that file.

## Counts

| file | OK | RETARGET | MISSING | VAGUE | total |
|---|---|---|---|---|---|
| `spec.md` | 78 | 3 | 7 | 1 | 89 |
| `decisions.md` | 129 | 0 | 7 | 2 | 138 |
| `implementation.md` | 29 | 0 | 0 | 0 | 29 |
| companions | 7 | 0 | 0 | 0 | 7 |
| `pending.md` | 2 | 0 | 0 | 0 | 2 |
| `extensions.md` | 1 | 0 | 0 | 0 | 1 |
| total | 246 | 3 | 14 | 3 | 266 |

No row is COMPANION.

Of the 14 MISSING rows, 6 lag a correction the rewrite made to a claim the
old chapter stated: rows 6, 16, 55, 73, 74 and 84 (R6's F3, F12, F13, F14 and
F20, plus R7). The other 8 were wrong before the rewrite, and the old chapter
never stated them: rows 20, 112, 113, 114, 119, 120, 138 and 184. No MISSING
row loses a claim the rewrite should have kept. Every row in survey 1's
part D list is confirmed, except §14.8's (row 50), which is RETARGET, and
D-250's Rejected (row 197). Row 197 was wrong before, and R11 has made it
true, so it is now OK.

Under R2 and R25 the only rows that say a binding walks instances are rows 6
and 184. Row 6 is §8.6's sentence, and brief.md's landing edit fixes it.
Row 184 is D-242's Position. §11.2's "inspection reads admit deep paths"
cites no §13 section, so it has no row here. Brief.md's landing edit still
covers it.

## Rows not OK

### Edits in `spec.md` (landing)

**Row 6, spec 3411–3413 (§8.6), MISSING.** R6 F3 and R2. The old chapter
stated this, but the code contradicts it. This is brief.md's landing edit
for §8.6.
- old: `That read side is the inspection side. It resolves a path with
  `resolve` under the instance walk ([§13.3][s13-3]).`
- new: `Snapshot and log inspection walk instances ([§13.3][s13-3]).`

**Row 13, spec 4706 (§9.3), RETARGET → §13.2.** `UserCodeFraming` is
§13.2's. §13.1 holds only the fail-fast policy. This was wrong before the
rewrite, and it is minor.
- old: `` `UserCodeFraming`-wrapped build failure ([§13.1][s13-1]). ``
- new: `` `UserCodeFraming`-wrapped build failure ([§13.1][s13-1],
  [§13.2][s13-2]). ``

**Row 16, spec 5085–5086 (§9.5), MISSING.** R6 F12. The old chapter said
"boundary time". The carrier now holds the clock at the failure. "That
site's frame" also misuses *frame* (R7).
- old: `That site's frame holds the boundary time and the replay index.`
- new: `The carrier holds the clock at the failure and the replay pointer.`

**Row 20, spec 6531–6532 (§10.6), MISSING.** The old chapter never said this,
so it was wrong before the rewrite. §13.4 makes the cursor a field of the
executor.
- old: `(the loop-state field recording where execution stands,
  [§13.4][s13-4])`
- new: `(the executor's field recording where execution stands,
  [§13.4][s13-4])`

**Row 50, spec 12180–12181 (§14.8), RETARGET → §13.5.** The doctrine is
§13.5's ("exceptions from model code are always abnormal", new 620–621). The
opening never stated it.
- old: `per the exceptions-are-broken-machinery line ([§13][s13]).`
- new: `per the exceptions-are-broken-machinery line ([§13.5][s13-5]).`

**Row 55, spec 12831–12833 (Appendix B), MISSING.** R6 F3. The old chapter
stated the getfield walk. `resolve` now resolves one level, and the
generic-holding rule belongs to the service walk.
- old: `` - `resolve(assembly, path) → AbstractComponent`. The getfield walk
  along `/` segments. It enforces the one-level rule for wiring
  ([§6.1][s6-1]) and the generic-holding rule for deep reads, at the
  primitive ([§13.3][s13-3]). ``
- new: `` - `resolve(assembly, path) → AbstractComponent`. Resolves an
  immediate child, a container element's key segment included. Wiring
  resolution applies the one-level rule ([§6.1][s6-1]), and the service walk
  enforces the generic-holding rule ([§13.3][s13-3]). ``

**Row 62, spec 13249 (Appendix C), VAGUE → §13.2.** §13.2 names the three
stages ("build, service or runtime"). The bare §13 covers too much.
- old: `The stages are the ones [§13][s13] fixes:`
- new: `The stages are the ones [§13.2][s13-2] names:`
- A related edit, not part of the citation: the build bullet's "(an
  interface-connection body, a probe)" lags R6 F5. It would become "(a
  declaration body, a probe, an activation's continuous-tier function)".

**Row 68, spec 13296–13297 (Appendix C), RETARGET → §9.2.** R4 moved "a step
that throws renders its warnings with the collection" to §9.2 (C-135).
- old: `collection ([§13.2][s13-2], [D-250][d-250]).`
- new: `collection ([§9.2][s9-2], [D-250][d-250]).`

**Row 73, spec 13617–13620 (Appendix C, `StepError`), MISSING.** R6 F12 and
F14. The old chapter stated the four phases and "boundary time". This row is
already in brief.md's track 2 list (Appendix C's `StepError` row).
- old: `Cursor frame (component path, function, and the boundary phase, which
  is an RK stage, an event round, a localization trial evaluation or a
  tick), boundary time,`
- new: `Cursor frame (the component by its component-list index, the
  function, and the boundary phase: the frame-top drain, an integration
  stage, the arrival sweep, the θ = 0 validation, a localization trial,
  projection, an event round or the ticks), the clock at the failure,`

**Row 74, spec 13623–13624 (Appendix C, `NonfiniteState`), MISSING.** R6 F20.
The old chapter said "state block". The new chapter names the state leaf.
The fields come from `src/diagnostics.jl` 284–290: path, leaf, value, t
(the frame-top time) and boundary.
- old: `Component path, the offending state block, boundary time and index.`
- new: `Component path, the offending state leaf and its value, the
  frame-top time and the frame-entry boundary index.`

**Row 84, spec 14689–14693 (glossary, execution cursor), MISSING.** R6 F13
and R7. The old chapter stated the execution-order index. That claim was
false, and the rewrite corrected it.
- old: `— the plain mutable field recording where execution stands in the
  compiled order. It holds three facts, the component path as an index into
  the `Outputs`'s execution order, the function running, and the boundary
  phase. It costs one cheap store per dispatch, so a runtime failure gets
  its frame without exception frames in the hot path ([§13.4][s13-4]).`
- new: `— the executor's plain mutable field recording where execution
  stands in the compiled order. It holds three facts, the component by its
  index in the structure's component list, the function running, and the
  boundary phase. It costs one cheap store per dispatch, so a runtime
  failure gets its cursor frame without exception handlers in the hot path
  ([§13.4][s13-4]).`

### Annotations in `decisions.md` (track 2, rule 10 of `decisions_style.md`)

Log text is not edited in place. Each row below takes an annotation.

**Rows 112, 113, 114, D-114 (Position 3711, Spec 3719, Rejected 3734),
MISSING.** These were wrong before the rewrite. Since D-230 the entry has
been historical, and chapter 12's survey recorded it.
- new annotation: `§13.4 indexes a failure by the frame-entry boundary index
  ([D-128][d-128], [D-230][d-230]). The counter-plus-recorded-t indexing this
  entry presupposes is historical, and §13.4 no longer rests on it.`

**Rows 119, 120, D-131 (Rationale 4298, Rejected 4319), MISSING.** These were
wrong before the rewrite, and they are minor. §13.4 enumerates no lifecycle
states. §12.6 does.
- new annotation: `§13.4 names only the terminal statuses and the return to
  built; the five-state count is §12.6's.`

**Row 138, D-159 Position 5919, MISSING.** This was wrong before the rewrite.
D-250 replaced the two streams, and D-159 carries no annotation.
- new annotation: `Superseded in part by [D-250][d-250]: §13.2's two-stream
  partition is gone; a service warning lives on the artifact the call
  returns.`

**Row 184, D-242 Position 9498 (with its inspection bullet, 9508–9509),
MISSING.** This was wrong before the rewrite, and R2 makes it worse. The
inspection bullet lists device read bindings and GUI panels under the
instance walk. Bindings and log extraction by `series` are now service
clients (D-406, D-407, R2, R25). D-310 parked the GUI panels (R16). Brief.md
already sends D-242 to track 2.
- new annotation: `Since [D-406][d-406] and [D-407][d-407], device read
  bindings and log extraction by series resolve on the service side; GUI
  panels are parked ([D-310][d-310]). The inspection case is snapshot and log
  inspection (§13.3).`

**Rows 142, 143, D-167 (Spec 6293, Rationale 6305), VAGUE → §13.2.** A bare
§13 backs a ruling on the style of a message ("both remedies in the
message"). That ruling is §13.2's didactic style. D-167 is superseded, so an
annotation is the most the fix can be, or nothing at all.

## Observations outside the citations

- Row 264, `companions/frame_walkthrough.md` 283. The citation holds. The
  same sentence names `_host_boundary_zero!`, which `src/` does not define,
  and says `replay!` runs boundary zero. Spec 9429–9431 says `restore!` and
  `replay!` run no boundary zero.
- Row 94, D-061's annotation. "The declared-type walk ... stand" now reads as
  the service walk's. R26's track 2 annotation of D-061 covers it.

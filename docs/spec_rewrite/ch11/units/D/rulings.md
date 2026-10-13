# Unit D (§11.4): rulings

## Rulings applied

- R4: "single writer" and "the CAS can fail only because a drain intercepted
  the old batch, so the retry is bounded" are scoped to a device's staging
  cell. One added sentence states the harness cell exception (D-200). The
  harness cell's retry is not called bounded. After verification, the shim's
  "conversion on the device task" became "on the task that stages", since a
  harness `stage!` runs on any task (D-200). "On the writer's own task" in
  "Diagnostic sites" stays as a scope term.
- After verification: CAS is spelled out at its first use, in the coalescing
  gloss ("the CAS merge, CAS being compare-and-swap, that keeps ..."). C-060 now reads "All
  staging cells share one representation and one mechanism". C-066 no longer
  has the added "so".
- R5: `TableBinding` shrinks to one sentence with the §11.6 pointer.
- R6: old 7419–7421 stays as one sentence with D-104. "the mutable surface
  used to force" is dropped from old 7436–7437.
- R7: the framing sentence is replaced with the ruled text. The rest of the
  example stays, except that its bold lead-ins become italics, its doubled
  glossary links go, and the drain's second gloss goes.
- R8 is replaced by R19: "Alternatively it is accepted as a small
  per-aircraft×device mapping entry, an aircraft-design fork" is deleted
  (kept in `deleted.md`), and "must *not* ride along" cites D-045.
- R10 F15: "one seam" becomes "one edge case". No other "seam" in the unit.
- R11: `assign_input!` is FlightCore's, in the past tense. FCS is spelled
  out, and `q_ref = q_sf · axis` is called illustrative.
- R13: the drain's gloss now says "applies ... to the root inputs". The
  second, doubled gloss in the worked example is removed.
- Survey moves M9 (levels block merged and moved up) and M10 (mappings moved
  ahead of the representation), with the survey's `####` labels. The levels
  label is "The levels doctrine", not "Levels, never deltas", so that the
  label is not a claim.

## Corrections proposed

- Old 7358–7360: "The worked example at the end of this section works that
  hazard through: a pending `flaps` edit clobbered by an unrelated `gear`
  message, undrained and undiagnosable." The worked example (filter,
  joystick, GUI) has no `flaps` or `gear`. It names the hazard only in
  "Corrections the exercise forced". `flaps`/`gear` occur nowhere else in the
  spec or the log. Kept as written. Proposed: "The `flaps`/`gear` case shows
  the hazard. A pending `flaps` edit is clobbered by an unrelated `gear`
  message, undrained and undiagnosable." Or point at the example's
  "Corrections" bullet only.
- Reserved words reworded where touched: "at the boundary where wire-shaped
  data becomes system-shaped data" becomes "at the point where" (*boundary*
  in neither glossary sense). "The boundary is set by the face contract"
  becomes "A rule about faces sets where conditioning belongs" (*boundary*
  figurative, *contract* not a component's interface). "A greedy entry"
  (bare *entry*) becomes "A device with a greedy claim". Bare "cell" for a
  staging cell becomes "staging cell" outside the worked example. The
  example keeps its own wording, by R7.

## Citations added or replaced

- D-024 at "Staging keeps one atomic staging cell per attached device".
  Position: "one atomic batch cell per device".
- D-104 at "Staging has one coalescing policy". Position: "one policy — CAS
  merge, newest wins per face". (The old text cited it two sentences on.)
- D-104 at "The staged representation is fixed per attachment, compiled at
  attach". Position: "enumerated writers get a per-attachment fixed shape
  compiled at attach".
- D-202 at "The content type is a pair of positional tuples". Position: "The
  batch a staging cell holds is a pair of positional tuples over the claim
  set: a concretely typed values tuple ... and a parallel `Bool`
  touched-mask".
- D-104 at the roster-entry schema. Position: "schema in the roster entry"
  (D-202: "schema-in-roster-entry ... stand").
- D-104 at the scatter. Position: "an attach-compiled drain scatter (mirror of
  §11.2's gather)".
- D-104 at the shim. Position: "`stage!`-side normalization (name → position,
  convert ...) ... confined to one framework conversion on the device task".
- D-174 at "A device with a greedy claim needs no special treatment here".
  Position: "everything downstream of claim acquisition is identical for
  both: ... staging-shape/shim/merge/scatter compilation".
- D-174 at "The harness cell gets the same treatment" (Rationale, below). The
  old bold here is now plain, since unit C bolds D-174's harness rulings.
- D-174 at the harness `ClaimedFaceEntry` (Rationale, below).
- D-105 at `EntryTypeMismatch` (Rationale, below).
- D-044 at "Diagnostic sites ... move to staging". Position: "under the D-106
  roster freeze every surface is static per run, so all checks run at staging
  and the drain checks nothing". This clause survives D-174.
- D-044 at "the order matters only for diagnostics". Position: "cross-writer
  races structurally cannot arise and drain order stays diagnostic".
- D-106 at "the drain is pure application", "fully compilable" and "an
  implementation freedom" (Rationale, below).
- D-024 at the levels doctrine ("levels-never-deltas doctrine"), at "Mappings
  run on the device task" ("mappings pure, on the device task"), and at the
  drain's atomicswap and its attachment order ("drain by `atomicswap` in
  attachment order"). D-024's stale "complete writers overwrite" clause is
  not cited.
- D-045 at "Mappings are binding data, not shaping code" (bullet 3: "Mappings
  are declarative binding data with per-axis conditioning params, living on
  the device task"), at "A face's meaning is writer-independent" (bullet 2:
  "Faces carry writer-independent post-conditioning semantics, the
  GUI-parity test"), and at the accumulators (bullet 4: "Edge logic is staged
  counters plus model-state accumulators").
- D-045 at "Aircraft-semantic derivation must *not* ride along" (R19,
  Rationale-only, below).
- D-026 in R7's framing sentence (Rationale-only, below).
- D-200 in R4's added sentence. Rationale (log 7364): "several tasks may stage
  concurrently, and the same CAS append arbitrates". Also `src/dataplane.jl`
  14–23: "drained, or merged past by another stager".

## Rationale-only rulings

- D-174, Rationale (log 6374–6380): the harness cell covers the unclaimed
  complement and is recomputed at every stopped-sim `attach!`/`detach!`. The
  renormalization applies to it alone. `ClaimedFaceEntry` is narrowed to the
  harness writer. D-104's Rationale (log 3210–3213) says the same for "the
  interactive writer", the half D-174 supersedes, so D-104 is not cited there.
- D-105, Rationale (log 3249–3250): `EntryTypeMismatch` "checked at staging
  for every writer".
- D-106, Rationale (log 3273–3275): "the drain is pure application, fully
  compilable against the frozen roster (specialization an implementation
  freedom, not an obligation — the §9.7 per-configuration compile trade)".
- D-104, Rejected (log 3223–3228): the closed `complete(binding)` opt-in and
  author-built total tuples (already cited in the old text).
- D-024, Rejected (log 891–895): per-input cells and the batch stack (already
  cited).
- D-045, Rejected (log 1448–1449): "Shaping as per-device mapping code:
  aircraft semantics duplicated per device" (R19).
- D-026, Rejected (log 933–936): staging every render pass, the active-widget
  contract that §11.7 rejects (R7).
- D-200, Rationale (log 7364): the harness cell's concurrent stagers (R4).

## Bold on the same entry elsewhere

This unit's bolds: D-024 ×4 (per-device cell, levels, mappings on the device
task, the drain's atomicswap), D-104 ×2 (one policy, the per-attachment
shape), D-045 ×2 (bullets 3 and 2), D-202 ×1. Each is a separate ruling of its
entry, under the semicolon and bullet test. Other units' `new.md` files bold
D-045 bullets 1 and 5 (H), D-174 and D-044 rulings about surfaces, claims and
the harness drain order (C, G2), and D-106 (C). None of these is a ruling
bolded here. In the frozen spec's chapters 5–10 and 12–14, D-045 is bold at
§4.3 (old 931, the write-side granularity rule), which is a different ruling.
No ruling is bold in two places.

## Inbound citations affected

- Appendix C cites §11.4 for `ClaimedFaceEntry` and `EntryTypeMismatch`.
  Both stay named in "Diagnostic sites".
- D-104 Position and `inbound_periphery_walkthrough.md` 152 cite the scatter
  as the mirror of §11.2's gather. The scatter sentence stays.
- §11.8 (unit J) points at §11.4 for the drain. The drain now has its own
  `####` label, and its atomicswap sentence stays.
- `flight_case_studies.md` 264–269 ("semantics in-model (§11.4)") agrees
  better with the text after R19.
- The glossary's *worked* and *torture test* entries cite the example, which
  stays.
- No `####` anchor of §11.4 is linked from anywhere, so the new labels break
  nothing.

## Open questions

- R8's fan-out question (E1) was replaced by R19, which deleted the
  "Alternatively" sentence. Nothing is left open there.
- The `flaps`/`gear` reference above. The example it points to does not
  contain the case.
- "Iterating a roster array costs a handful of dispatches per frame and
  remains acceptable" (old 7483–7484) is a measurement claim with no source.
  Kept.
- "What the drain guarantees is that the frame's outcome is a pure function
  of the drained batches" (row 189) and "The raw stick levels are the known,
  accepted loss" (row 197) have no entry stating them as rulings. Kept plain.
- The single-writer sentence for a device's staging cell stays uncited. D-136
  calls the staging cells single-writer only as an analogy for diagnostic
  cells.
- The harness cell's shape compilation and renormalization rest on D-174's
  Rationale alone. The log owes a Position (survey 1, part E, item 4).

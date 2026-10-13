# Unit B (§11.2): rulings, citations and open points

Rulings applied: R29 (F5 as "A finite `log_max` is the log's `sizehint!`"), R5 (status plain, contents to §11.8; terminal snapshot to
one clause; `totals` home kept here; M4), R6 (verdicts at old 6980–6981 and
7019–7020 kept with their citations), R10 (F5, F6, F7; F14 moot, below),
R11 (C172X, XPlane visualizer, `VelocityData`, `SavingCallback`,
`migration_outline.md`), R12 (`ReadBindingUnresolved`), R13 (no drain gloss
occurs in §11.2), R18 (the recording-keywords block). Survey M3 applied:
the endpoints paragraph now follows the guarantees and comes before the
mechanism sketch.

R18 check: the block `init!(sim, condition; trace = true, log = true,
log_every = 1, log_max = 65536)` matches `src/sim.jl` 591–592
(`init!(sim::Simulation, condition = fragment(); t0::Real = 0.0, trace = true,
log = true, log_every = 1, log_max = 65536)`) and Appendix B old 12684–12685.
`t0` is left out because the block is a call, not the signature. `restore!`
(`src/sim.jl` 678–679) and `replay!` (923) take the same four keywords with
the same defaults. The block does not claim they are `init!`'s alone.

## Corrections proposed

- **The heartbeat's timing (closed).** Old 6922–6923's "the liveness
  timestamps the loop takes at frame top" moved to §11.8 under R5, which
  says the loop acquire-loads the heartbeat at publication. D-240's Position
  puts the load at publication ("The drain does not touch it") and
  supersedes D-136's "acquire-loaded at the drain". §11.8 is right; §11.2
  no longer states the timing. Nothing to change.
- **F5 and an unbounded log (applied as R29).** `src/dataplane.jl` 750 hints
  only when `log_max` is finite. The text now reads "A finite `log_max` is
  the log's `sizehint!` ([§9.8][s9-8])".

## Citations added or replaced

- D-023 (Position: "build private → release-store `@atomic latest`; readers
  acquire-load; wait-free both ways; nothing reachable from a published
  snapshot ever written again; allocate per boundary; log = retained
  snapshot references"). Added at the publication rule, the wait-free
  sentence, the binding rule and "The log is a vector of retained snapshot
  references".
- D-293 (Position: "No snapshot is published mid-step. External readers ...
  therefore observe the signal table only at boundaries"). Added beside
  §10.3 at "Publication happens only after the boundary sequence completes".
- D-136. Added, plain, at "The framework status is a concrete frozen value,
  not a window onto live bookkeeping". Rationale-only (below).
- D-194. Added at "The inspection path for one is promotion to a declared
  output". Rationale-only (below).
- D-047 (Position: "snapshot includes root slots (peek fallback + read-only
  mirrors)"). Added at the bold "The captured table also includes the root
  inputs". "Root slots" is the old word for root inputs; the spec text says
  root inputs.
- D-038 (Position: "Snapshot = boundary table ... + `t` + status — no state
  stores"; "state trajectory = derived (replay-to-inspect)";
  "checkpointing = opt-in log policy, guarded"; "log retention = the trace's
  plain kill switch plus keep-every-kth decimation"; "publication and
  tracing are unaffected"). Added at the no-stores bold, replay-to-inspect,
  the checkpoint guarded addition, the retention bold and "Every boundary
  still runs ...". D-038's "private cells included, presentation-filtered"
  is stale (survey part E) and is not imported.
- D-252 (Position: "A component exposes a state or mode field by returning
  it from `output_state`", now `y_state`). Added beside §5.3 at the honest
  remedy for a state field.
- D-137 (Position: "Snapshot-log retention gets a bound, `log_max` — the
  maximum number of retained snapshot references"). Added at the bound's
  rule and its default. The default, the count, the finite default, the
  doubling stride, the guarantees, the endpoints and the view policy are
  Rationale-only (below).
- D-083 (Position: "Output-device reads are snapshot-path bindings ...
  reads see the whole table (inspection observation ...)"). Added at "Output-
  device bindings are snapshot bindings" and at "An output device's read of
  the snapshot is inspection". Also at "Attach validation converts
  structural drift ..." and "Semantically generic consumers should therefore
  bind faces", which are Rationale-only (below). D-083 was cited nowhere in
  the chapter.
- D-130 (Position: "*inspection* (device read bindings, GUI panels,
  snapshot/log inspection) the instance walk — ... drift still loud at
  attach (`ReadBindingUnresolved`)"). Added at the R12 sentence.
- D-129 (Position: "the read side speaks structure in inspection reads and
  contract wherever meaning must outlive the build: integration bindings
  (§11.2's `get_face`)"). Added at "A binding chooses its side".
- D-045 (Position bullet 2: "Faces carry writer-independent
  post-conditioning semantics"). Added beside §11.4 at "What makes a face
  meaning-stable is writer-independent semantics".
- §11.8 added in the framework status's gloss, as the pointer.
- Verifier fix: the D-023, D-047 and D-038 citations now sit directly after
  their bold headlines, outside any gloss. The `latest` gloss reads "(the
  single handout point for published snapshots)". The root-input and
  *binding* glosses are full sentences after the bold ("Root inputs are the
  root component's own input faces."; "A binding is the value passed at
  `attach!` that makes a device framework-legible."). *Decimation* is
  defined by the next sentence ("Decimation is the log's additional keep-every-kth
  retention policy, `log_every`").
- Verifier fix: "CG velocity" now reads "center-of-gravity velocity".
- Removed from §11.2: §10.7 (the pacer diagnostics) and D-201 (the account
  complete to the final frame top). Both moved with their claims to §11.8
  under R5; unit J's text holds both.

## Rationale-only rulings

- D-136, Rationale (log 4407–4411): "The published framework status becomes
  a concrete frozen value"; Rejected (log 4439–4441), a status referencing
  the live accumulator violates §11.2's binding rule.
- D-194, Rationale (log 7135–7137): intermediates "were only ever inspected
  by inclusion in the model output, which D-165 itself recorded as the
  promote-to-output inspection path".
- D-137, Rationale (log 4469–4511): the default 65536 (4474), a count, not a
  memory budget (4469–4473), finite unconditionally (4474–4477), the
  doubling stride (4477–4480), the guarantees normative and the mechanism a
  sketch (4485–4492), the endpoints outside the bound (4500–4504), `log_max`
  a view policy (4507–4509). Each is bold in §11.2 with D-137. The log owes
  a Position stating them (survey 1, part E item 2).
- D-137, Rejected (log 4515–4518): the rolling window, kept as a one-clause
  verdict (R6).
- D-023, Rejected (log 866–867): preallocated snapshot rings, kept as a
  one-clause verdict (R6).
- D-083, Rationale (log 2587–2595): structural drift loud at attach, faces
  the only shield against semantic drift, generic consumers bind faces,
  aircraft families export conventional surfaces with wrapper types.
- D-130's Position carries `ReadBindingUnresolved` at attach; D-098's
  Rationale (log 3017–3018) carries it too, for store selectors.

## Bold on the same entry elsewhere

- D-023: §10.3 (frozen spec 5643) bolds "External readers observe the signal
  table only at step boundaries" citing D-023 and D-293. That is D-293's
  ruling and D-023's mid-step rejection. §11.2's three D-023 bolds are
  other rulings of D-023's Position (build then release-store; nothing
  reachable is written again; the log as retained references). Not a
  double bold; listed for the cold check.
- D-047: unit C bolds "The init/trim services own root-input initial values"
  and unit H bolds "Widgets stage on interaction events only", both citing
  D-047. §11.2 bolds "The captured table also includes the root inputs",
  D-047's separate ruling "snapshot includes root slots". Three different
  rulings of one Position; no ruling is bold twice.
- D-083: §13.3 (frozen spec 9850) bolds "Which rule applies depends on who is
  resolving" citing D-083. That is the client split D-130 states. §11.2
  bolds "Output-device bindings are snapshot bindings", D-083's own
  Position. Not a double bold.
- D-129: §8.6 (frozen 3461) bolds "It separates structure from derived
  contract, not read from write" with D-129. §11.2 cites D-129 plain at "A
  binding chooses its side"; no bold here.
- D-038, D-137, D-309: no bold elsewhere in the frozen spec's chapters 5–10
  and 12–14, nor in the other units' `new.md`.

## Inbound citations affected

- §13.2 (frozen 9766–9767) cites §11.2 for the status surfacing in
  snapshots. Holds: "It also carries the framework status".
- Glossary, framework status (14005–14010), cites §11.8 and §11.2. Holds;
  the contents now live in §11.8 alone.
- D-199 Position (log 7334): the labels "key the NamedTuple `map_output`
  receives (§11.2, §11.6)". Holds in part: §11.2 keeps "`map_output`
  therefore receives a labeled NamedTuple (§11.6)"; the keying by `reads`'
  names is §11.6's.
- D-104 Position (log 3203), "mirror of §11.2's gather". Holds.
- Appendix B (12623), the `reads`/`map_output` row cites §14.4 and §11.2.
  Holds; §11.6 is the better target (track 2).
- Appendix C (13144), `ReadBindingUnresolved` cites §11.2. Now holds by name.
- §9.8 (5452–5454), "The summarize-or-skip rule (§11.2) governs what such a
  field contributes on export". Holds; F7 now says "an exporting logger".
- D-201 Spec field (log 7377) lists §11.2. §11.2 no longer cites D-201; its
  claim moved to §11.8 (R5). The Spec field may drop §11.2 in track 2, or
  keep it for the endpoint retention it still supports.
- D-137 Rationale (log 4509–4511) keeps the stale `sizehint!` wording (F5);
  track 2.
- D-252 Rejected (log 9749) places the dev-mode note in "§11.7"; it is in
  §11.2. Unchanged (survey).

## Open questions

- **F14 is moot.** The phrase "the per-writer diagnostic batches" sat in the
  framework status's contents, which moved to §11.8 under R5. §11.2 no
  longer lists the contents, so the ruled replacement had no sentence to
  land in. Unit J's text says "the ring the frame's drain took". Confirm
  this reading.
- **Rulings with no entry**, stated plain as before: the first endpoint
  under `restore!` and `replay!` (old 7056–7058); "The stride counts
  boundaries from it" (old 7058); an exporting logger skips or summarizes
  field-handle signals (old 7089–7090, held open in `pending.md`).
- **"Port class"** (old 6964, "never a port class (D-252)") is kept as
  ordinary English, like "device class". It echoes D-252's title ("two port
  classes"), not *class*'s primitive-versus-assembly sense. Reword if the
  reserved-word rule should reach it.

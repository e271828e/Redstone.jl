# Unit B (§12.4): rulings

Line numbers are old spec lines at `17ad42d`; log lines are lines of the
frozen `scratch_survey/h1/decisions.md`.

## Corrections proposed

1. **"a terminal snapshot, with the failure named in its diagnostic
   account"** (9052–9053, the `should_abort = true` init failure). R8 moved
   the stop to the run's first frame top, and this clause still assumes the
   run publishes a snapshot after the failure. `run!` resets the accounts and
   runs the bracket before any publication (`src/sim.jl` 1182–1184), and the
   run then advances no frame and publishes nothing (survey 1, part C: the
   run "logged only boundary zero"). The terminal snapshot is the one the run
   started from, published before the `DeviceCrash` was written, so its
   account cannot name the failure. The report reaches the termination
   record's residue through the run's-end sweep (`src/sim.jl` 1281).
   Kept as written, the colon made a comma. Proposed: "What the operator is
   left with is an ordinary stopped simulation, its termination record
   naming the device and its residue carrying the `DeviceCrash`." Confirm the
   residue path against the code before ruling.
2. **"Deployment contexts legitimately differ in patience"** (8939–8940).
   The ordinary-English "deployment" now sits two sentences before "not on
   the `Deployment`" (F6), the glossary artifact. Kept as written. Proposed:
   "Usage contexts legitimately differ in patience" (D-198 Rationale's
   "Deployment contexts" is the source, so the log may want the same note).
3. **`disable_sigint`** (9103). The code calls `Base.sigatomic_begin` and
   `sigatomic_end` directly (`src/sim.jl` 1189, 1427), the counter
   `disable_sigint` wraps (survey 1, row 181). The sentence holds as a
   description of the mechanism. No change proposed; recorded so no one
   "fixes" it.

## Citations added or replaced

- **D-030** at the tail's order (8841) and at (7)'s loop-side failure
  (8893). Position: "Shutdown: complete the boundary → publish final
  snapshot → sticky stopped status → wake framework waits → `unblock!` hook
  … → join with named timeout; … loop failure runs the same protocol from
  the catch path."
- **D-316** at (1)'s stop-request event (8846). Position: "every request
  ends the run at the first publication where it holds, unless the advance
  ignores it"; bullet 8, "After every publication the loop scans the
  `StopFlag` cell block of the just-published snapshot."
- **D-310** at "a front end" (8849, R2). Position bullet 2: "A front end is
  attached by hand".
- **D-373** at the two obligations (8866). Bullet 2: "The two author
  obligations, the `running(handle)` predicate and interruptible blocking,
  are taught … and diagnosed …, never forced."
- **D-203** moved onto the bold of row 111 (it was already cited at the
  sentence's end). Bullet 4: "`DeviceJoinTimeout` becomes an ordinary
  structured kind: written to the loop's own cell in tail step (5),
  collected by the run's-end sweep."
- **D-060** at the exception-based termination idiom (8896–8898) and beside
  §13.5 at the exceptions-are-abnormal doctrine (9088). Position:
  "exceptions from model code always abnormal; no `SimulationTermination`
  exception type". Both clauses stand: D-316's Supersedes line keeps
  "D-060's rule that termination is state, never an exception".
- **§13.5 replaces §13** at the doctrine (9088), F23.
- **D-368** at the retained terminal snapshot (8917, R3 row 126). Bullet 5:
  "The boundary-zero and terminal snapshots are retained unconditionally
  under any `log_every` and any `log_max`."
- **D-133** at `t_end`'s landing (8920). Position: "`t_end`'s landing rule
  …: the run ends at the first grid boundary whose time reaches or exceeds
  `t_end` — whole frames only, overshooting by up to `h`".
- **D-198** at the cap's disposition (8937, F6). Position: "The shutdown
  tail's join cap becomes `join_timeout`, a `Simulation` … keyword". The
  bold now sits on its headline clause, the old D-198 citation kept on the
  next sentence.
- **D-256** at "lives on `Control`, not on the `Deployment`" (8944, F6).
  Bullet 3: "To the periphery's own types: `join_timeout` into `Control`".
- **D-093** at "device tasks being per-run artifacts" (8948) and at the
  per-run `init!` (8956). Position: "Device tasks are per-run artifacts …:
  `run!` spawns one task per roster entry after per-run device `init!`
  (resource acquisition per run …)".
- **D-106** at `detach!` once stopped (8952, F20). Position:
  "`attach!`/`detach!` are stopped-sim operations — legal in
  `built`/`initialized`/`stopped`".
- **D-138** at the bracket's bold (8967–8971), at the release on a throw
  (8994), at the `DeviceCrash` bold (9006), at the no-task sentence (9020),
  at the staleness sentence (9024–9027, F10, replacing §11.8), at the claims
  persisting (9029) and at the `should_abort` split (9038). Position: "an
  **explicit step of the §12.4 protocol**, taken at the top of a run — once
  per roster entry, in attachment order, on the calling task, pre-spawn —
  with **each call in its own bracket**: on a throw the framework calls
  `shutdown!(dev)` on the failing device right there, reports `DeviceCrash`
  by name and marks it dead, no task being spawned." The other four rest on
  its Rationale (below).
- **D-189** at the report's entry point (9012). Position: "the first
  argument is the cell address — the device handle inside the task, the
  roster entry in §12.4's pre-spawn init bracket, where no handle exists
  yet."
- **D-132** at the interrupt's bold (9075), at "no entry point of its own"
  (9085), at "flips nothing process-global" (9164), at the masking bold
  (9092) and at the second interrupt's bold (9156). Position: "The operator
  interrupt (Ctrl-C) is a control-plane stop, not a failure." The other
  four rest on its Rationale and Rejected list (below).
- **§11.8 dropped** at the staleness sentence (9027), F10.
- **§11.1 dropped** with the topology paragraph (9057), R5.

## Rationale-only rulings

- D-138 Rationale (log 4667–4669), "**No new diagnostic kind**": the bold
  "The report is the ordinary `DeviceCrash`, not a kind of its own".
- D-138 Rationale (log 4676), "**Run disposition splits on `should_abort`,
  uniformly with (6)**": the bold of that name.
- D-138 Rationale (log 4670–4673): "dead from boundary zero", the stale
  cell, and "its **claims persist to run end**"; cited plain at 9020–9029.
  The Rationale's boundary-zero narrative is what R8 corrects; the log owes
  the same correction (track 2).
- D-132 Rationale (log 4241), "**Boundary masking is normative**, not an
  implementation hint": the masking bold.
- D-132 Rationale (log 4252–4256), "A **second** interrupt during the tail
  collapses the remaining device joins immediately": the second interrupt's
  bold.
- D-132 Rejected (log 4285–4288, "A public `interrupt!` entry point:
  redundant") and (log 4289–4291, "Process-global `exit_on_sigint(false)`
  set by the framework"): the two verdicts, plain, cited by R6.
- D-268 annotations of 2026-09-26 (log 11161–11166, 11168–11172): the bolds
  "A frame that throws with an interrupt pending ends `errored`" and "A
  forced throw reaches the defensive arm", already cited to D-268.

## Bold on the same entry elsewhere

No ruling is bold in two places. Entries bold both here and elsewhere, on
different rulings:

- D-203: unit A bolds bullet 3 ("The stop word carries its issuer"); here
  bullet 4 (`DeviceJoinTimeout` to the loop's diagnostic cell).
- D-268: unit A bolds bullet 1 (the pause verbs, the tail clearing the
  pause); §11.6 bolds bullets 6 and 7 (7895, 7905). Here bullets 2, 3, 4
  and 9 and the two annotations; bullet 7 (row 151) is now plain.
- D-133: unit A bolds the 2 s threshold; §10.4 and §10.7 bold the
  tolerance, budget, forgiveness and `margin`. Here the `t_end` landing, a
  sentence of its own in the Position.
- D-138: §11.6 bolds the `shutdown!` tolerance (7885) and the `should_abort`
  keyword (7983), both Rationale clauses. Here the Position and two other
  Rationale clauses.
- D-132: §11.6 bolds "An `InterruptException` is never a `DeviceCrash`"
  (7916), a Rationale clause. Here the Position and two other Rationale
  clauses.
- D-030: §13.6 (10532–10533) bolds the abnormal path rejoining the tail,
  D-030's third clause, with no citation. Here the first clause, the order;
  (7) states the third plain.
- Plain here, bold elsewhere: D-256 bullet 3 (unit A), D-093 (§11.1 6865;
  unit F on another ruling), D-310 (§11.1 6870; unit F), D-316 (other
  chapters, on its port and policy bullets, and unit F), D-368 bullet 5 (§11.2 7051), D-106 (§11.3 7305, 7360), D-373
  (§11.6 7971).

## Inbound citations affected

- spec 12855 (Appendix B, "the device is dead from boundary zero (§12.4)")
  and log 4670–4683 (D-138 Rationale): R8 now reads "dead from the run's
  first frame top"; both hold for a run that starts at boundary zero.
- spec 6882 (§11.1, "A device whose `init!` failed gets no task (§12.4)")
  and log 3492 (D-109 annotation): hold through the no-task sentence after
  the topology paragraph's deletion (R5).
- spec 10554 (§13.6, "fills the seat §12.4 reserved"): holds; (7) keeps
  "runs steps (1) through (5) from the catch path".
- spec 7052 (§11.2) and log 4607 (D-137): hold; the retained terminal
  snapshot stays, plain.
- log 4256–4257 (D-132 Rationale, "(5)'s honest asymmetry"): the spec
  sentence it matched is deleted (F3).
- log 4316 (D-133, "stated once in §12.4(1)"): still not step (1); the rule
  now opens the paragraph after the chart.
- spec 10515 (§13.5, "GUI stop button") and `flight_case_studies.md` 408
  ("*Window close.* §12.4 applies verbatim"): §12.4 now says "a front end";
  the window ✕ stays.
- spec 10239–10241 (§13.4, "a single interrupt never reaches the branch"):
  now matches §12.4's scoped "never sees a single interrupt" (F14).
- spec 14240 (glossary, operator interrupt): names frame-top and wait
  unmask points; §12.4 also names the pause block, as before.

## Open questions

1. **R11's gloss and the glossary's *stop request*.** The dictated gloss
   calls the stop word "the control plane's stop request". §12.4 uses
   *stop request* in the glossary's sense, a model's `StopFlag` port, in the
   paragraph that follows ("Stop requests are consulted at each publication
   and the stop word at the next frame top"). A reader may take the two for
   one thing. Applied as dictated; "the control plane's stop command" would
   avoid the collision.
2. **EOT** (8862, 8882) stays unexpanded. No source in the spec or the log
   expands it, so an introducing clause would claim beyond its source.
3. **R7 and E2.** Old 9054 and 9080 ("resumable by the next `run!`") stay
   as written (E1). The E2 lines, 8711–8716 and 8823–8824, are unit A's;
   §12.4 holds none of them.
4. **The `should_abort` stop's narrative** (correction 1 above) is the one
   sentence of 9020–9060 that R8's list did not name and that still
   assumes a publication after the failure. Kept as written.

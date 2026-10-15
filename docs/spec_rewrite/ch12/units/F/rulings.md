# Unit F (§12.5, §12.6): rulings, citations and open questions

Old lines are spec lines at `17ad42d` (`old.md` line + 9168). Log lines are
`scratch_survey/h1/decisions.md`, byte-identical to the `h2` copy; spec lines
elsewhere are `scratch_survey/h1/spec.md`.

## Rulings applied

- **R5.** M51: old 9343–9348 is one sentence that keeps "Deviceless, `run!`
  is fully synchronous" and points at §11.1 for the loop's placement, the
  device tasks and the unattended run; "It is also what the synchronous
  rethrow presupposes" is held by §11.1 ("This is what the synchronous
  rethrow (§13.4) presupposes"). M53: the harness paragraphs keep the
  stepping use, "Staged batches are ordinary batches", their tracing and
  application, the `stage!` → `step!` → `latest` idiom and "Both entry points
  work under `run!` too", and point at §11.3 for the harness writer; "from
  any task" and "surface-checked" are held by §11.3 7256–7259. M54: "Task
  topology follows the roster each time" is a plain pointer to §11.1; the
  front-end sentence is bold and cited to D-310. M55: the per-advance stop
  policy stays whole as the home. `join_timeout` is `Control`'s (§12.1)
  stays as written.
- **R6.** `c172_demos.jl` is introduced once as FlightCore's demo file, its
  line numbers kept. `K` is glossed as the multiplier in `Relative(K)`, with
  a pointer to §10.5; §10.5's table (spec 6166) defines `Relative(K, Φ = 0)`
  as "every `K`-th tick of the enclosing scope". "Today's `dt = 0.02`
  callbacks" became "the `dt = 0.02` callbacks FlightCore had"; "Today's
  demo-vs-GUI dead-slider fight" became FlightCore's, pointing at §11.7
  (spec 8229–8234, "This retires FlightCore's dead-slider convention");
  "The demos' engine start/stop buttons are `u`-writes today" became the
  past tense. "project → sweep → publish" is verbatim. "The migration suite"
  stays: §12.6 never names its owner, and the log's one source, D-096
  Rationale log 3019–3020 ("the migration path for the suite's dominant
  write-`u` → `step!` → assert idiom"), does not say FlightCore's. Verdict
  lines kept with their citations: 9182–9183 (D-031), 9211–9212 (D-031),
  9384–9385 (D-096 added).
- **R10.** F58 `MissingInit` (9334), F59 `ArgumentInvalid` (9354), F78
  `ServiceLifecycle` (9425; checked against `src/sim.jl` 636–639, which
  refuses every state but `initialized` and `stopped`), F60 (9196), F61 (the
  label), F63 (9415–9417), F64 (9372), F65 and F75 (by R5's pointer), F66
  (9334 and 9361 unlinked), F69 (9425 cites D-319), F70 (9446 cites D-274),
  F74 (the **Rule.** at 9185 folded into the clock criterion's bold), F77
  (9204), F79 (9353: "never waits on the pacer"). Grepped the unit for each
  phrase; each occurs once.
- **R12.** 9423 lists "`t`, `t₀`, the fingerprint (the structural layout)
  and the deployment"; 9432, 9438 and 9452 check "the state's fingerprint
  and deployment".
- **R13.** §12.6 opens on a new context paragraph introducing the five
  states, *door*, `feed` and the input mode, then `####` labels at today's
  breaks: the run and the simulation; lifecycle states and the input mode;
  partial advance; status, termination and `run!` after `step!`; re-running
  and checkpoints; device attachments across runs; the stop policy. M52
  moved "`errored` is terminal" and its reason up, after the derivation
  table. No other move. §12.5 gains a context paragraph ending with one
  sentence naming its parts, its order otherwise unchanged.
- **R14.** *Door* is defined once in §12.6's context. `live!` is "the one
  call that moves the mode alone" (9414). "Entry point" replaces "door" at
  9312, 9313, 9314 and 9440, and at 9436 ("The door then copies the state
  back"), which names `restore!(model, …)`, a `Model`'s entry point, as R14's
  rule covers. 9337's "the two alternative entries" became "the two
  alternative doors": bare *entry* is reserved, and `restore!` and `replay!`
  are doors in R14's sense.
- **Labels and bold.** Both **Rule.** labels went (9185 folded by F74;
  9295–9298 became two bold headline clauses on D-261 bullets 1 and 3;
  9332 a bold headline cited to D-088). The bold state words, **actually
  advanced**, **harness cell** and **input mode** went plain. The bold term
  **placeholder run** became the bold clause "A `Simulation` is constructed
  with a placeholder run" (D-255 bullet 2). "The component mapping is
  strictly richer …" went plain: no entry rules it. "The frame-top drain
  still runs" went plain. 9419's 22-word bold shrank to its headline clause.
  The lead-ins "Where the loop runs", "Partial advance", "Status,
  termination and the `run!` seam" and "Re-running" became labels or went
  with M51; "The doctrine, final form" became the sentence's opening, with
  D-031's first ruling bold. Bold spans before: seven in §12.5 (45 words)
  and 28 in §12.6; now 21 in the unit.
- **Glossary.** Glosses added at first-use links: periphery, devices,
  components, trace, port, snapshot, boundary, tick, root input, guarded
  addition (newly linked), stop request (§12.5); devices, frame (newly
  linked), staging cells, log (newly linked), trace, boundary zero, control
  plane, deployment, executor, diagnostic cell, termination record, snapshot,
  stores (newly linked), replay, drain, batch (newly linked), unattended run,
  harness cell, harness writer (newly linked), stop request, condition
  (newly linked), recorders, trace header (newly linked), roster (newly
  linked), claims (§12.6). Doubled links dropped: drain ×2, termination
  record, harness cell. The `#g-seam` link went with F61, and the
  `#g-calling-task` link with M51. Two links stay without a gloss: `sweep`
  inside the verbatim "project → sweep → publish", and `holding`
  (`#g-edge-semantics`), which sits between "a stop request (gloss)" and
  "at frame 3" where a second parenthetical would break the sentence.
  "Boundary" has no link in §12.6: F66 removed the only one.

- **R20.** "the frame's own cell" (9287) became "the frame's own diagnostic
  cell", the `Model`'s diagnostic cell of D-317 bullet 1 (log 13748–13749).
  F64's dictated "the cell written" became "the staging cell written".
- **Verifier fixes.** "their frozen record" became "the pacer's frozen
  record", since the clause now stands alone (C-086). The input mode's link
  moved to its first use, in the context paragraph. `sweep` is linked and
  glossed at "It runs no sweep", its first use in §12.6. "same-boundary
  fresh" became "fresh from the same boundary (gloss), by topological
  order", so the link no longer sits inside a compound. Left as inherited:
  "the checkpoint's" (Run paragraph) comes before the checkpoint's link, and
  "trim" (§12.5's survey) before its §14 pointer.

## Corrections proposed

- None open. The bare *cell* at 9287 was ruled by R20 (above).
- **The context paragraph of §12.6** restates claims the section makes below
  (the five states, `feed`, the mode's two sources). They are declared
  additions, written to R13, and claim nothing the section does not.

## Citations added or replaced

- **D-031** at "Manual event triggering needs no mechanism": Position log
  1060, "manual events = slot + guard". At "Mid-run re-initialization is not
  built": Position log 1061, "init/trim = stopped-sim services". At the final
  form: Position log 1057–1058, "root-input staging + control commands,
  nothing else". The clock criterion's bold carries the old adjacent
  citation: log 1058–1059, "sim-time scripts = scenario components (clock
  criterion), wall-clock interaction = devices".
- **§2.2** at the final form: spec 337–339, "Nothing outside the model writes
  its state, its modes or its outputs (§12.5, D-031)", and 359–361.
- **§10.5** at `K`: spec 6166, the `Relative(K, Φ = 0)` row.
- **§11.4** at the levels doctrine: spec 7429–7434, "#### The levels
  doctrine".
- **§11.7** at the dead-slider fight: spec 8229–8234.
- **D-316** at "honoured unless the advance ignores it": Position log
  13611–13613, "every request ends the run at the first publication where it
  holds, unless the advance ignores it".
- **D-060** at "never a thrown exception": Position log 1857, "Graceful
  termination is model state, never an exception"; standing per D-255 log
  10071–10072.
- **§12.7** at `live!`'s first use in §12.6: a pointer.
- **D-261** repeated at "A run's recording is therefore that door's
  declaration": the split separated it from its citation.
- **D-260** at "The origin `t₀` is not a run field" and at "It is a
  `Float64`": bullet 4, log 10336–10338, "The origin `t₀` is not a run field
  … It is a `Float64`, like `h` and `t_end`".
- **D-255** at "`init!` allocates fresh objects": bullet 2, log 10047–10048,
  "`init!` allocates fresh objects rather than clearing". Repeated at the
  placeholder's bold clause: bullet 2, log 10043, "constructed with a
  placeholder run".
- **D-261** at the bold "A struct holds what it owns …": bullet 1, log
  10407–10409, cited before at the paragraph's end.
- **D-088** at the five states: Position log 2776–2777, "built → initialized
  (`init!` ran boundary zero) → running → stopped/errored". At "`init!` is
  mandatory": log 2777, "`init!` mandatory before `run!`/`step!`".
- **D-223** at *Built*: bullet 2, log 8562, "`built` reads 'boundary zero not
  completed', cold or after a failure". At the throw leaving `built`:
  Position log 8554–8557, "the simulation returns to `built`". Its "under
  `init!` or `replay!`" is stale (survey part E); the clauses cited stand.
- **D-218** at the drain's source: Position log 8273–8275, "the one drain
  branch … is driven by that mode".
- **§2.4** at "bit-identical to the same frames under `run!`": spec 563–570,
  which lists splitting a run across calls among what leaves a trajectory
  bit-identical, citing §12.6.
- **D-093** at "Each `run!` re-initializes every rostered device and spawns
  its task": Position log 2889–2891, "`run!` spawns one task per roster entry
  after per-run device `init!`".
- **D-319** replaces D-274 at `checkpoint(sim)`'s wrap (F69): bullet 3, log
  14016–14018, "wraps `checkpoint(sim.model)` with the run's frame index and
  boundary ordinal". Added beside D-318 at `restore!(model, …)`: bullet 2, log
  14008–14015, "checks the fingerprint and the grid … collects every
  mismatch … into one throw before any write". Added at
  `restore!(sim, model_state)`: bullet 3, log 14020–14021, "the door a state
  prepared on a standalone model takes into a simulation".
- **D-274** replaces D-230 at "The boundary ordinal continues" (F70): bullet
  3, log 11660–11661, "the boundary ordinal continues, being the
  trajectory's".
- **D-310** at the front-end sentence: bullet 2, log 13222–13223, "A front
  end is attached by hand, once per simulation, and the roster keeps it
  across that simulation's runs".
- **D-255, D-316** repeated on the bold "The stop policy is declared per
  advance", which needed a citation in its own sentence.
- Rationale-only citations, listed below: D-088 (four sites), D-093 (one),
  D-096 (two).

## Rationale-only rulings

- **D-088 Rationale**, log 2782–2791: `step!` as synchronous partial advance
  through ordinary frames (cited at "`step!(sim; frames = 1)` advances whole
  frames"); "between `step!` calls the status is `initialized`" (cited
  there); "stopped → `init!` → `run!` supported" (cited at the bold re-run);
  "attachments persist as roster entries — orthogonal to the run lifecycle"
  (cited at the bold persistence). Two of these carry bold: the re-run and
  attachment persistence. The log owes a Position (survey part E, item 1).
- **D-093 Rationale**, log 2908–2910: "Stepping sessions are deviceless by
  construction". Cited at the bold sentence; the log owes a Position (part E,
  item 3).
- **D-096 Rationale**, log 3015–3020: `latest(sim)` and the advance-assert
  idiom, cited at "`stage!` → `step!` → `latest`". **D-096 Rejected**, log
  3036–3037: "an inspection *accessor* returning the immutable snapshot is
  not it", cited at the closure-termination verdict.
- **D-261 Rationale**, log 10500–10503: per-run recording at the doors,
  cited (old and repeated) at "the next door may declare otherwise".
- **D-059 Rejected**, log 1851–1852: "reproduction is trace replay, not
  resurrection", cited by adjacency at the moved pair.
- **D-031 Rejected**, log 1069–1071: devices rejected for scripts, cited as
  before.
- **D-255 Rationale**, log 10091–10093: the placeholder preferred to
  `nothing`, cited by adjacency as before.

## Bold on the same entry elsewhere

- **D-059 bullet 4.** §14 11031 bolds "**`errored` is terminal for every
  row**" (D-059, D-108); §12.6 bolds "`errored` is terminal". One ruling in
  two places; §12.6 is the lifecycle's home, and chapter 14's rewrite can
  make its sentence plain.
- **D-255 and D-316, the per-advance policy.** §13.5 10334 bolds the lead-in
  "**Policy**" (a label) and 10336 "**Every request is honoured unless the
  advance ignores it**" (D-316 Position, a different ruling). R5 makes §12.6
  the home; §13.5's repeat is chapter 13's.
- **D-255's Position sentence**, "A run is state with a type of its own, and
  its policy is a value bound per advance", backs two bolds here: "`Run` is
  what one run owns" (with D-260's Position, "A `Run{T}` holds what lasts
  from one door to the next", and D-317 bullet 4) and "The stop policy is
  declared per advance" (with D-316 bullet 6 and D-260 bullet 3). Both bolds
  are as the old text had them. Unit A's §12.1 bolds D-255 bullet 4
  ("`ControlRequestedStop` sits outside the stop policy"); §11.5 7759 bolds
  bullet 3. Different rulings.
- **D-261.** Here bullets 1 and 3. Elsewhere: spec 4245 and 7282 (other
  bullets) and §13.5 10343, which bolds the term `StopPolicy` citing D-261.
- **D-317.** Here bullets 1 and 6, and bullet 4 inside the `Run` bold's
  citation. §9.2 4327 bolds bullet 2.
- **D-093.** Here its Rationale (stepping sessions). §11.1 6865 and 6884 bold
  its Position ("Device tasks are run-scoped", the start gate).
- **D-310.** Here bullet 2. §11.1 6870 bolds bullet 1.
- **D-218.** Plain here. Unit G bolds its Position and bullets.
- No other bold in units A, B or G, or in the frozen spec outside the unit,
  cites D-031, D-088, D-260, D-319 or D-223.

## Inbound citations affected

- Log 11153–11154 (D-268 Rationale), "§12.6 defines the unattended run as the
  deviceless one": holds; the M51 sentence keeps "Deviceless, `run!` is fully
  synchronous" and the unattended run's link, glossed.
- Spec 6866–6867 (§11.1), "§12.4 joins them all at every stop (§12.6)":
  holds; "Tasks and OS resources do not" stays.
- Spec 7257 (§11.3), the harness/REPL write path (§12.6): holds.
- Appendix B 12993–13001, `stage!` and `latest` "legal under `run!` and
  `step!` alike": holds; "Both entry points work under `run!` too" stays.
- Spec 7337 (§11.3), roster persistence (§12.6): holds.
- Spec 10348 (§13.5), the policy's lifetime "(§12.6, D-260)": holds; §12.6
  keeps the sentence (R5).
- Log 3525 (D-110 Rationale) and spec 11947–11949 (§14.8), "the §12.6
  three-item clear": holds; the sentence stays.
- Log 7334 (D-195 Rationale), §12.5's `x`/`s` clause: holds.
- Appendix C 13301 (`MissingInit`) and 13428 (`ArgumentInvalid`) cite §12.6:
  §12.6 now names both kinds at their conditions.
- §12.4 (unit B) 8925–8927 (the `t_plus` spelling), 9153–9154 (`checkpoint`
  refused after an abandoned frame) and 9054, 9080 ("resumable by the next
  `run!`", E1): the §12.6 sentences they rely on stay.
- The new `####` labels are not linked from anywhere.

## Open questions

None. The orchestrator ruled the three raised in the first pass. The
unglossed `sweep` (in the verbatim chain) and `holding` keep their links.
The Rationale-only bolds (D-088 twice, D-093) stay, and the log owes each a
Position. D-255's two bolds stay.

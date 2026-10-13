# Chapter 11: the rulings batch (recipe step 6)

The consolidator's merge of every unit's `rulings.md`, the verifiers' leftovers
(`verify.md`), `chapter_rulings.md`, both inbound checks, both surveys' parts D
and E, read against the brief's R1 to R32, `escalations.md` (E1 to E5, all
ruled by the owner and not reopened here) and `new_entries.md`.

Conventions:

- `spec` and `log` lines are lines of the frozen copies
  `scratch_survey/spec.md` and `scratch_survey/decisions.md`, which match
  `f61b1af` byte for byte. Each claim was checked at its cited lines.
- The working tree's `spec.md` has moved since `f61b1af` (commit `227be06`,
  chapter 2): every frozen spec line at or after 1257 sits **six lines later**
  in the working tree (frozen 14727 is working 14733). `decisions.md`, the
  companions and `implementation.md` are unchanged since `f61b1af`.
- `new` lines are `chapter_new.md` lines as assembled after step 4. Units'
  `new.md` and `inventory.json` were not read: two fixers are editing them.
- Each item ends with an empty `Status:` line for the orchestrator.
- Groups: 1, landing edits outside the chapter (blocking items first); 2,
  open in-chapter questions; 3, track 2 log repairs and outside problems that
  predate the rewrite; 4, owner items; 5, serious findings.

---

## 1. Landing edits outside the chapter

Items B-1 to B-11 block landing: the rewrite or a ruling made them necessary.
B-12 to B-14 are cheap and recommended in the same pass, but do not block.

### B-1. §11.8's retitle breaks every `[s11-8]` anchor

- Sources: `inbound_check_2.md` ("A finding outside the rows"); J
  `rulings.md` (inbound, heading retitle); `new_entries.md` (outside edits,
  last bullet); R10 F65.
- Evidence: the heading changes from "the per-writer cell" to "the per-writer
  diagnostic cell". Old anchor `#118-diagnostics-and-liveness-the-per-writer-cell`
  appears at spec 75 (Contents) and 14727 (link definition), log 14968 (link
  definition) and `companions/frame_walkthrough.md` 311. A working-tree grep
  outside `docs/spec_rewrite/` finds no other use of the anchor (briefs and
  log prose use the words, not the anchor).
- Old (spec 75): `- [11.8 Diagnostics and liveness: the per-writer cell](#118-diagnostics-and-liveness-the-per-writer-cell)`
- New: `- [11.8 Diagnostics and liveness: the per-writer diagnostic cell](#118-diagnostics-and-liveness-the-per-writer-diagnostic-cell)`
- The three definitions become `#118-diagnostics-and-liveness-the-per-writer-diagnostic-cell`
  (with `spec.md#` and `../spec.md#` prefixes in the log and the companion).
- Proposal: edit the Contents entry by hand, then run `linkify.jl`; grep
  afterwards that all three definitions changed, since the companion's block
  may not be regenerated.
- Recommendation: accept. Blocking.
- Status: Accepted (orchestrator, checkpoint 2). Applied at landing, step 7.

### B-2. §13.2's `EmptyGreedyClaim` cell now lives in §11.6 (inbound row 54)

- Sources: `inbound_check_1.md` row 54; C `rulings.md` (citations removed
  with R5).
- Evidence: spec 9776–9778 cite §11.3 for "`EmptyGreedyClaim` lands in the
  roster entry's cell". Under R5, §11.3 keeps only the empty complement's
  legality; the diagnostic-cell clause and D-250 moved to §11.6 ("Greedy
  claims").
- Old (spec 9777–9778): `` criterion. It mutates the roster, so `EmptyGreedyClaim` lands in `` / `the roster entry's cell ([§11.3][s11-3]). The committed`
- New: `the roster entry's cell ([§11.6][s11-6]). The committed`
- Recommendation: accept. Blocking (caused by R5).
- Status: Accepted (orchestrator, checkpoint 2). Applied at landing, step 7.

### B-3. `implementation.md` 326, the same claim (inbound row 280)

- Sources: `inbound_check_1.md` row 280.
- Evidence: `implementation.md` 325–326: "`attach!` into the roster entry's
  own cell (§11.3, D-250);".
- Old: `` `attach!` into the roster entry's own cell (§11.3, D-250); ``
- New: `` `attach!` into the roster entry's own cell (§11.6, D-250); ``
- Recommendation: accept. Blocking (caused by R5).
- Status: Accepted (orchestrator, checkpoint 2). Applied at landing, step 7.

### B-4. D-250's Spec field: §11.3 becomes §11.6 (inbound row 257)

- Sources: `inbound_check_1.md` row 257; the Spec-field script below (B-13).
- Evidence: log 9627, `**Spec.** [§9.2][s9-2], [§11.3][s11-3], [§11.8][s11-8], [§13.2][s13-2], [Appendix C][sC]`.
  The new §11.3 no longer cites D-250; §11.6 states its routing with D-250.
- New (written bare, then `linkify.jl`): `**Spec.** §9.2, §11.6, §11.8, §13.2, Appendix C`
- Recommendation: accept. Blocking (a Spec field a move changed).
- Status: Accepted (orchestrator, checkpoint 2). Applied at landing, step 7.

### B-5. The walkthrough's "same schema, cell, drain and trace" points at §11.3

- Sources: `inbound_check_2.md` (walkthrough 92); G2 `rulings.md` (inbound).
- Evidence: `companions/inbound_periphery_walkthrough.md` 90–92 cite §11.6 for
  "gets the same schema, cell, drain and trace". R5 made §11.3 the home of the
  one-mechanism claim; §11.6 keeps one sentence and a pointer.
- Old: `like any other claim and gets the same schema, cell, drain and trace` / `([§11.6][s11-6]). A second greedy binding attached afterwards finds nothing left`
- New: `([§11.3][s11-3]). A second greedy binding attached afterwards finds nothing left`
- Recommendation: accept. Blocking (caused by R5). Rows citing §11.6 beside
  §11.3 for the same claim (spec 12636, glossary 14127, log 6364) stay as they
  are, as G2 notes.
- Status: Accepted (orchestrator, checkpoint 2). Applied at landing, step 7.

### B-6. The harness writer stages from any task: Appendix B and the glossary (R4, RP-9)

- Sources: R4; RP-9; `new_entries.md` (R4 / RP-9 bullet); `inbound_check_1.md`
  rows 88, 119, 120; C `rulings.md` (inbound); survey 1 F1 and part D.
- Evidence: Appendix B spec 12795–12796, glossary *harness cell* 14019 and
  *harness writer* 14023 all say "the calling task". D-200 Position (log 7360,
  "written into its cell on whichever task stages") and Rationale (log 7364,
  "a harness `stage!` runs on whatever task calls it"). The ruled gloss is
  §11.8's, "the framework-owned write path `stage!(sim, …)`".
- Old (spec 12795–12796): `` - `stage!(sim, "face" => value, …)`. Task-free staging from the calling task `` / `into the harness writer ([§11.3][s11-3]). Its surface is the currently`
- New: `` - `stage!(sim, "face" => value, …)`. Staging from any task, the calling `` / `task included, into the harness writer ([§11.3][s11-3]). Its surface is the currently`
  ("Task-free" goes, per P1-22(b): "task-free … from any task" read as a
  contradiction in §11.3.)
- Old (spec 14019): `` written by `stage!(sim, "face" => value, …)` from the calling task itself. ``
- New: `` written by `stage!(sim, "face" => value, …)` from any task, the calling task included. ``
- Old (spec 14023–14024): `**harness writer** — the framework-owned write path of the calling task,` / `` `stage!(sim, …)` and its cell, and the design's sole *derived* surface. That ``
- New: `` **harness writer** — the framework-owned write path `stage!(sim, …)`, open `` / `to any task, with its cell; the design's sole *derived* surface. That`
- Also, by lesson 19 (rule a wording correction for every instance): §12.6
  spec 9175, "`stage!(sim, "face" => value, …)` ([§11.3][s11-3]), with the
  calling task as writer". The inbound check left it OK because a stepping
  session's caller is the usual stager, but D-200 makes any task legal there
  too. Proposed: "…([§11.3][s11-3]), from any task, the calling task
  included."
- Recommendation: accept the three ruled edits (blocking). Accept the §12.6
  edit too, or hold it for chapter 12's rewrite; the orchestrator's call.
- Status: Accepted, the §12.6 instance included (lesson 19; chapter 12 is put off). Applied at landing, step 7.

### B-7. The standard GUI binding: Appendix B and two glossary entries (E5, R23)

- Sources: E5 (owner); R23; `new_entries.md` (E5 outside edits);
  `inbound_check_2.md` (spec 12636–12638, 14016, 14099); survey 2 F69.
- Evidence: Appendix B spec 12637, glossary *greedy claim* 14015–14016,
  glossary *`should_abort`* 14098–14099. `src` ships no GUI binding; D-310
  parked the built-in GUI. The `should_abort` claim came from D-138 Rationale
  log 4576–4578 under the withdrawn `gui = true`.
- Old (spec 12637): `data-driven binding, and the standard GUI binding is the shipped greedy one`
- New: `data-driven binding, and the standard GUI binding is the greedy one`
- Old (spec 14015–14016): `` legal and reported (`EmptyGreedyClaim`), and the shipped GUI binding is the `` / `shipped instance ([§11.3][s11-3], [§11.6][s11-6]).`
- New: `` legal and reported (`EmptyGreedyClaim`), and the standard GUI binding is its `` / `instance ([§11.3][s11-3], [§11.6][s11-6]).`
- Old (spec 14097–14099): `advisory in one deployment and decisive in another. The shipped GUI` / `attaches with `true` ([§11.6][s11-6], [§12.4][s12-4]).`
- New: `advisory in one deployment and decisive in another ([§11.6][s11-6],` / `[§12.4][s12-4]).`
- Recommendation: accept; the owner ruled it. Blocking.
- Status: Accepted (orchestrator, checkpoint 2). Applied at landing, step 7.

### B-8. §12.4's init sketch drops `mark_dead!` (E3)

- Sources: E3 (owner); `new_entries.md` (E3 outside edit); G1 `rulings.md`
  (inbound); survey 2 F55.
- Evidence: spec 8788, `        mark_dead!(entry)                 # from boundary zero; no task is spawned`.
  `src/devices.jl` 397–399 at `f61b1af`: "Death is marked nowhere beyond the
  record". For an entry with no task, `src/sim.jl` 1997–2002 publishes
  `task_state` as `:done`, or `:none` once a stop is pending, so a comment
  must not promise `:done`.
- New (the comment at column 43, as the block's other comments):
  `                                          # no dead-marking: no task is spawned (§12.2)`
  The new §11.6 comment (R21, RP-12) reads "no dead-marking: task_state shows
  the end, claims stay, §11.3"; this one keeps the old line's "no task is
  spawned" and adds nothing about `task_state`'s value.
- Recommendation: accept. Blocking (owner-ruled outside edit). Re-check that
  the code block still parses as display code; nothing else in it changes.
- Status: Accepted (orchestrator, checkpoint 2). Applied at landing, step 7.

### B-9. The glossary's *device* entry reads as three mandatory functions (D-366)

- Sources: G1 `rulings.md` (inbound); R22; RP-11; D-366 draft.
- Evidence: spec 13985–13987, "under one authoring contract
  (`init!`/`loop`/`shutdown!`, optional `unblock!`) and one handle". D-366
  (lands with the chapter): `loop` mandatory, `init!`, `shutdown!` and
  `unblock!` optional with no-op defaults. A grep of `spec.md`, the
  companions and `implementation.md` finds no other "four functions, one
  optional" outside §11.6 (spec 7748, rewritten).
- Old (spec 13986–13987): `` `AbstractDevice` under one authoring contract (`init!`/`loop`/`shutdown!`, `` / `` optional `unblock!`) and one handle. Input-only and ``
- New: `` `AbstractDevice` under one authoring contract (a mandatory `loop`, and `` / `` optional `init!`, `shutdown!` and `unblock!` hooks) and one handle. Input-only and ``
- Recommendation: accept. Blocking: D-366 lands with the chapter, and the
  glossary would contradict it.
- Status: Accepted (orchestrator, checkpoint 2). Applied at landing, step 7.

### B-10. D-102's Position lists `init!` and `shutdown!` as implemented by every device

- Sources: consolidator, from checking D-366 against the log (lesson 42).
- Evidence: D-102 Position (log 3138–3143): "a device implements `init!(dev)`
  …, `loop(dev, handle)` …, `shutdown!(dev)` … and optional `unblock!(dev)`".
  D-366's draft names no entry it amends. Under rule 1 of `decisions_style.md`,
  D-102 takes an annotation rather than a rewrite.
- Proposal: add to D-102, after its Rationale paragraph:
  `Annotation (2026-10-13): amended by D-366. Only loop is mandatory; init!, shutdown! and unblock! are optional hooks with no-op defaults.`
  (written bare with code spans, then `linkify.jl`). Optionally add "This
  amends D-102's contract list." to D-366's Rationale.
- Recommendation: accept, landing with D-366. The stale D-102 Rationale
  clauses (group 3) can join the same annotation in track 2, or now.
- Status: Accepted (orchestrator, checkpoint 2). Applied at landing, step 7.

### B-11. Appendix C's `CheckpointMismatch` and `ReplaySchemaMismatch` drop §11.5 (R12)

- Sources: R12 (unit F: "retargeted at landing"); F `rulings.md` (inbound);
  survey 2 F64 and part D.
- Evidence: spec 13194 cites §11.5, §12.6, §12.7; spec 13221 cites §11.5,
  §12.7. §11.5 names neither kind, before or after. §12.6 names
  `CheckpointMismatch` (9240, 9259), and §12.7 names both (9471–9472).
- Old (13194): `` - **`CheckpointMismatch`** ([§11.5][s11-5], [§12.6][s12-6], [§12.7][s12-7]). ``
- New: `` - **`CheckpointMismatch`** ([§12.6][s12-6], [§12.7][s12-7]). ``
- Old (13221): `` - **`ReplaySchemaMismatch`** ([§11.5][s11-5], [§12.7][s12-7]). Error · ``
- New: `` - **`ReplaySchemaMismatch`** ([§12.7][s12-7]). Error · ``
- Recommendation: accept. Blocking by R12's wording; check that
  `check_rows.jl` coverage does not shrink (§11.5 loses two Appendix C rows).
- Status: Accepted (orchestrator, checkpoint 2). Applied at landing, step 7.

### B-12. D-201's Spec field: §11.2 no longer states its ruling

- Sources: B `rulings.md` (inbound, D-201); R5; the script in B-13.
- Evidence: log 7375 (D-201 Position: the terminal snapshot's account is
  complete up to its own frame top); log 7377 Spec lists §11.2 and §11.8. R5
  moved the account to §11.8; §11.2 keeps only why the endpoint is retained
  and no longer cites D-201.
- New (bare): `**Spec.** §11.8, §12.4, §13.2, Appendix C`
- Recommendation: accept (a Spec field a move changed). Low risk; it may also
  wait for track 2.
- Status: Accepted. Applied at landing with the Spec-field pass.

### B-13. Spec fields of entries the rewrite now cites in a new section

- Sources: survey 1 part D ("Spec fields stale before any move"); survey 2
  part D ("Spec fields already short"); C, D, F, H, J `rulings.md` (inbound);
  a script comparing every `[D-nnn]` per section of `chapter_new.md` against
  each entry's frozen Spec field.
- Rule: a Spec field lists "the sections where the decided mechanism lives"
  (`decisions_style.md`). A pointer-only citation does not qualify.
- Additions the script found, each checked against the citing unit's
  `rulings.md` (log line of the Spec field in brackets):
  - D-031 [1032]: + §11.3 (root inputs the periphery's only write).
  - D-044 [1404]: + §11.4 (all checks at staging, drain checks nothing).
  - D-045 [1437]: + §11.4 (bullets 2–4: faces, mappings, edge logic), +
    §11.6 (`TableBinding` as declarative data). Not §11.2: that citation
    sits beside a §11.4 pointer.
  - D-047 [1499]: + §11.2 (snapshot includes root slots), + §11.5 (header
    holds initial slot values), + §11.7 (stage on interaction).
  - D-083 [2585]: + §11.2 (cited nowhere in the chapter before).
  - D-101 [3102]: + §11.1 (the trace key).
  - D-105 [3244]: + §11.4 (`EntryTypeMismatch` at staging).
  - D-106 [3271]: + §11.4 (drain pure application), + §11.6 (claims and
    roster entry persist to run end).
  - D-130 [4067]: + §11.2 (`ReadBindingUnresolved` at attach).
  - D-194 [7127]: + §11.2 (promotion to output as the inspection path).
  - D-200 [7362]: + §11.3, + §11.4 (the harness writer's task, R4).
  - D-215 [7985] and D-216 [8036]: + §11.3 (R12's kinds); D-216 also +
    §11.6 (`DeviceContractMismatch`, `ArgumentInvalid` over `TableBinding`).
  - D-218 [8142]: + §11.5 (devices as readers under replay, R27). Missing
    before the rewrite too.
  - D-293 [12524]: + §11.2. D-305 [12951]: + §11.8. D-316 [13516]: + §11.5.
    D-319 [13894]: + §11.5 (R26).
- Not proposed: D-026 + §11.4 (R7's framing sentence only points at §11.7).
- Recommendation: accept the list at step 7's Spec-field pass, keeping each
  field's order. Not blocking; track 2 if time is short.
- Status: Accepted. Applied at landing with the Spec-field pass.

### B-14. Two glossary entries a clause behind the rewritten chapter

- Sources: `inbound_check_2.md` (notes: spec 14141); J `rulings.md` (inbound,
  glossary *framework status*); R26; R10 F72.
- Evidence: glossary *checkpoint* (spec 14139–14140) ends its contents at
  "`t` and `t₀`, and the fingerprint"; §11.5 now ends "and the fingerprint and
  the deployment" (R26, D-319 bullet 1, log 13838–13840). Glossary
  *framework status* (spec 14007) says "this boundary's drained diagnostics
  (`recent`)", the wording F72 corrected in §11.8 (drains run at frame tops;
  `src/dataplane.jl` 370–375).
- Old (14140): `` guard priors, `t` and `t₀`, and the fingerprint. It is not a condition and ``
- New: `` guard priors, `t` and `t₀`, the fingerprint and the deployment. It is not a condition and `` (rewrap).
- Old (14007): `` plus, per writer, this boundary's drained diagnostics (`recent`), the counts ``
- New: `` plus, per writer, the diagnostics the frame's drain took (`recent`), the counts ``
- Recommendation: accept at landing; neither blocks.
- Status: Accepted (orchestrator, checkpoint 2). Applied at landing, step 7.
---

## 2. Open in-chapter questions

Each was left as written by the rewrite. "Rule now" means a correction the
orchestrator can rule from an entry or the code; the fixer applies it with the
item id in the inventory.

### B-15. §11.1 names the `Simulation` as the buffers' owner

- Sources: A `rulings.md`, correction 1.
- Evidence: frozen spec 6847, "each `Simulation` owns its own
  [buffers](#g-buffer) ([§9.4][s9-4])". §9.4 (spec 4850–4853): "A `Model` …
  owns its activation's buffers … A `Simulation` owns its `Model{Float64}`
  … ([D-317][d-317])". D-282 is annotated the same way (log 11967–11968).
- Proposal: "and each `Simulation` owns its own `Model`, and with it the
  `Model`'s [buffers](#g-buffer) ([§9.4][s9-4])". §9.4 already cites D-317, so
  the citation can stay §9.4 alone.
- Recommendation: rule now as a correction (a later entry and §9.4 agree).
- Status: Accepted (orchestrator, checkpoint 3). Ruled edit, applied by the ruled-edits agent.

### B-16. "These patterns" has no antecedent in §11.1's first rule

- Sources: A `rulings.md`, open question 4; verifier A (still open).
- Evidence: frozen spec 6869–6870, "the reclamation problem (hazard
  pointers, epochs, RCU grace periods) which makes these patterns hard in
  non-GC languages". No pattern is named before it.
- Proposal: "…which makes lock-free handoffs hard in non-GC languages". The
  bullet's subject is the atomic reference handoff, so this names what was
  meant and claims nothing new.
- Recommendation: rule now as an editorial correction.
- Status: Accepted (orchestrator, checkpoint 3). Ruled edit, applied by the ruled-edits agent.

### B-17. D-022's first ruling bold on plane 2, and its fifth ruling plain

- Sources: A `rulings.md`, open questions 1 and 2; verifier A ("the owner's
  call" on the fifth).
- Evidence: D-022 Position (log 832–836) ends "interactive = batch +
  devices". The new text frames it as "One consequence is recorded here
  because it collapses an API axis". `spec_style.md` bars bold on
  consequences; lesson 28 ("a 'therefore' clause in a Position is a
  consequence, never a second bold") and RP-1 point the same way.
- Recommendation: hold as written (plane 2 bold, fifth ruling plain). No
  owner question is needed: the style rule settles it.
- Status: Held as written: the style rule settles it (consequence plain, lesson 28).

### B-18. `recent` can carry thirty-two values in the loop's record

- Sources: J `rulings.md`, open question 1; verifier J; survey 2 F72; R10 F72
  ("whether the loop's record can carry thirty-two goes in `rulings.md`").
- Evidence: D-317 bullet 5 (log 13616–13618): "The frame's chattering and
  firing-budget reports go to the model's diagnostic cell, and the drain
  folds it into the loop's account beside the loop's own cell."
  `src/dataplane.jl` 399–411 at `f61b1af` (`_fold!`, the `append!` at 407) appends the second
  cell's ring to a pending delta. New 1827–1829 say "`recent` is the ring …
  at most sixteen values"; new 1909, "One ring of sixteen values per writer
  per boundary is the worst case".
- Proposal: new 1829, "at most sixteen values per diagnostic cell it takes.
  The loop's record folds two, its own and the `Model`'s
  ([D-317][d-317])." New 1909: "One ring of sixteen values per diagnostic
  cell per frame is the worst case". New 1793 ("at most sixteen retained
  values … per frame") is per cell already and stays.
- Recommendation: rule now. A Position (D-317) settles the fold, and the fix
  changes wording only. Not serious.
- Status: Accepted (orchestrator, checkpoint 3). Ruled edit, applied by the ruled-edits agent.

### B-19. The loop's own record carries no heartbeat either

- Sources: J `rulings.md`, correction 1.
- Evidence: new 1772–1774 say only the harness writer's record lacks a
  heartbeat and a `task_state`. `src/dataplane.jl` 424–425 at `f61b1af`: "The
  harness writer's and the loop's own records carry `nothing` for both";
  `src/sim.jl` 2004–2005 build both with `nothing, nothing`. D-240 Position
  (log 9129–9131): "The loop acquire-loads each **device's** heartbeat";
  D-193 Position (log 7075–7077): `task_state` read "from its own device
  `Task` handles". D-136's Position (log 4389–4393) gives every cell a
  timestamp, which stays true of the cell, not of the published record.
- Proposal: after "…because it has no task of its own to be alive or dead"
  add "The loop's own record carries neither, for the same reason
  ([D-240][d-240], [D-193][d-193])."
- Recommendation: rule now (later Positions and the code agree; rule 10).
- Status: Accepted (orchestrator, checkpoint 3). Ruled edit, applied by the ruled-edits agent.

### B-20. Bold for three Position rulings §11.8 states plain

- Sources: J `rulings.md`, open question 4.
- Evidence: `spec_style.md` 98–114: bold marks a ruling once, where the
  section states what the entry decides, and a Position is preferred over a
  Rationale. Frozen spec cites D-240 and D-241 only in §11.8 (8313, 8362), and
  neither is bold anywhere.
  - D-240 Position (log 9129–9131), new 1816–1817: "The loop acquire-loads
    the heartbeat at publication, when it assembles the status".
  - D-241 Position (log 9153–9156), new 1893–1894: "The per-writer status
    costs one small vector of records per publication". The quiet-frame bold
    at new 1891 rests on D-241's Rationale (log 9172–9174), a separate
    ruling, and stays.
  - D-200 Position, second sentence (log 7360), new 1771–1774: the harness
    writer's diagnostics "written from whichever task stages", its record
    with no heartbeat and no `task_state`.
- Proposal: bold the headline clause of each: "**The loop acquire-loads the
  heartbeat at publication**", "**The per-writer status costs one small
  vector of records per publication**", "**The harness writer's diagnostic
  cell is written from whichever task stages**".
- Recommendation: rule now, as a bold edit (`new_pretrim.md` not needed: bold
  is added, not removed). Run `check_bold.jl` against chapters 9, 12 and 13
  for a second bold on these rulings first; the frozen spec has none.
- Status: Accepted (checkpoint 3), after the grep for a second bold. Ruled bold edit, applied by the ruled-edits agent.

### B-21. The drains-last bold cites a Rationale where a Position states it

- Sources: consolidator (lesson 42, Position grep); C `rulings.md`
  (Rationale-only list, D-174 log 6383–6385).
- Evidence: new 541, "**The harness cell drains last**, by convention
  ([D-174][d-174])". D-096's Position (log 2955–2960) states "drained *last*
  at the frame top", with a reason D-174's Rationale calls objectless.
  `spec_style.md` 111–114: prefer an entry whose Position states the ruling.
- Proposal: "([D-096][d-096], [D-174][d-174])". D-096 is ratified; its stale
  reason gets an annotation in track 2 (B-44).
- Recommendation: rule now (a citation edit). It removes one item from the
  log's owed Positions (B-48).
- Status: Accepted (orchestrator, checkpoint 3). Ruled edit, applied by the ruled-edits agent.

### B-22. The `should_abort` keyword bold can cite D-177's Position

- Sources: consolidator (lesson 42); G1 `rulings.md` (Rationale-only, D-138
  log 4573–4575).
- Evidence: new 1288, "**`should_abort` is an `attach!` keyword**, defaulting
  to `false` ([D-138][d-138])". D-177's Position (log 6472–6473) spells
  `attach!(sim, dev::AbstractDevice, binding::AbstractBinding; should_abort
  = false)`, so a Position carries the keyword and its default. "Never a
  device property" (row 555) has no entry text (B-60).
- Proposal: "([D-138][d-138], [D-177][d-177])".
- Recommendation: rule now (a citation edit).
- Status: Accepted (orchestrator, checkpoint 3). Ruled edit, applied by the ruled-edits agent.

### B-23. "Baked once per run" can cite D-270's Position

- Sources: consolidator (lesson 42); H `rulings.md` (uncited, "the bake once
  per run (D-047 Rationale; D-270 Rationale)").
- Evidence: D-270 Position bullet 1 (log 11162–11167): `port_views(handle)`
  "bakes one `PortView` per declared port …: the terminal producer, the
  liveness verdict … The GUI's loop body builds it once at its top, after the
  freeze." New 1573–1574: "It is baked once, with the port resolution, when
  the run starts". New 1711: "Resolution to root inputs and the liveness
  verdict are baked at run start".
- Proposal: cite [D-270][d-270] on the new 1573–1574 sentence. New 1711 sits
  in the paragraph that already cites D-270 and needs nothing.
- Recommendation: rule now (a citation add).
- Status: Accepted (orchestrator, checkpoint 3). Ruled edit, applied by the ruled-edits agent.

### B-24. Small editorial fixes the verifiers left open

- Sources: G1 verifier (re-check: "`task_state` still has no §11.8
  pointer"); C `rulings.md` ("the [§12.2][s12-2] heartbeat" kept); verifier
  J ("Per writer it carries four things" above a six-field block).
- Proposals:
  - G1, R21's sentence: "`task_state` says so at the next publication" →
    "`task_state` ([§11.8][s11-8]) says so at the next publication".
  - C: "the [§12.2][s12-2] heartbeat" → "the heartbeat ([§12.2][s12-2])".
  - J, new 1827: "Per writer it carries four things" → "Per writer it carries
    four things beside `who`". The block shows `who` and the five fields the
    text names (`task_state` rides with `heartbeat`).
- Recommendation: rule now; the fixers may already have the third.
- Status: Accepted (orchestrator, checkpoint 3). Ruled edit, applied by the ruled-edits agent.

### B-25. G2's two binding sentences sit in the greedy group

- Sources: G2 `rulings.md` (corrections, second note).
- Evidence: after M56 the greedy-claims group carries "The binding stays an
  `attach!` argument, never a device field … narrowing the binding narrows
  the claim", which is about bindings in general (D-103 Rationale log 3180,
  "narrowing the binding narrows the claim").
- Proposal: move the two sentences back into "The binding", after the roots
  paragraph.
- Recommendation: accept as a ruled move; it costs one re-verification of
  G2's two paragraphs. Hold if the orchestrator wants no new moves.
- Status: Held: no new moves after step 5. The sentences stay in the greedy group.

### B-26. One ruling bold in §11.6 and in §12.4 (D-268 bullet 7)

- Sources: G1 `rulings.md` (bold elsewhere); verifier G1 (§11.6 is the home).
- Evidence: frozen spec 8800 bolds "**The entry is listed for release before
  its `init!` begins** ([D-268][d-268])"; §11.6 bolds "The tolerance also
  covers a call with no `init!` before it" for the same bullet (log
  10957–10963). `check_bold.jl` checks only `REWRITTEN` chapters (1–10), so
  landing chapter 11 does not trip it.
- Recommendation: hold. Record it for chapter 12's rewrite: §12.4 states the
  listing plain, with D-268. Likewise §12.6's bold "Task topology follows the
  roster each time" (spec 9269), cited to §11.1 alone, after R3 removed
  "topology" from §11.1 (A `rulings.md`).
- Status: Held. Recorded for chapter 12 in README's carried list (§12.4 listing plain; §12.6's topology bold).

### B-27. The three step-5 holds (RP-2, RP-5, RP-7)

- Sources: `chapter_rulings.md`.
- Evidence: RP-2, "the binding rule" beside the glossary's *binding*: the name
  is used at §11.8 and in D-136's Rejected list (log 4440). RP-5,
  `OutOfClaimEntry` and `ClaimedFaceEntry` stated in §11.3 and §11.4, as
  before; B-29's retarget of §13.2 to both sections relies on that. RP-7, the
  worked example's Discoveries bullet beside R7's framing, exempt evidence.
- Recommendation: close all three as held. Renaming "the binding rule" would
  touch §11.8 and the log for no reader gain the chapter needs now.
- Status: Closed as held.

### B-28. Held as written, no action

- Sources: as listed.
- Items:
  - A, correction 2: "device authoring contract" (§11.6's own term).
  - B, open question 3: "never a port class (D-252)" (echoes D-252's title).
  - G1, correction 1: "the single-writer entry point into the runtime
    warning stream" (ordinary English).
  - G2 verifier: "enumeration contract" (ordinary sense).
  - G2 note: "`TableBinding` is the one shipped binding type" beside "the
    standard GUI binding"; consistent under R23.
  - G2: the deleted render-loop read path leaves "its read path is the
    handle's primitive read" with no pacing; D-310 leaves the cockpit's read
    path to its own design.
  - G2: `contract` left unlinked in "behind its contract (§8.5)", since the
    same sentence uses "public contract" in another sense.
  - G1, open question 3: the heartbeat sentence in §11.6 (old 7858–7861)
    stays; no ruling made §11.8 its only home.
  - H: "the rule above" in place of restating fan-out consistency and the
    orphan fact; no ruling orders the cut.
  - H: the claim gloss says "root inputs" where the glossary says "faces";
    a claim is a set of root-input faces, so it claims nothing new.
  - D: the device staging cell's single-writer sentence stays uncited; D-136
    calls staging cells single-writer only as an analogy that cites the spec
    back (log 4390–4391).
  - B, open question 1: F14 is moot, since §11.2 no longer lists the status's
    contents (verifier B agrees); J's text carries the corrected wording.
  - J, open question 2: "values" for "entries" at old 8320 (F65 beside F72);
    F72 protected the count, not the word.
  - J, open question 5: `WriterStatus`, `DiagValue` and `KindCounts` in the
    R18 block. They match `src/dataplane.jl` 429–436, and D-270's log text
    names `WriterStatus` (log 11173).
- Recommendation: close each as held.
- Status: Closed as held.
---

## 3. Track 2: log repairs, stale Spec fields, and outside problems that predate the rewrite

Recipe step 8 applies. Every proposed Position bullet below was checked
against a grep of all Positions in the frozen log (lesson 42); hits are
named. Sources that cite the spec back are marked (lesson 43). Annotation
texts follow the log's form, `Annotation (YYYY-MM-DD): …`, written bare and
then linkified; the date is the landing date.

### 3a. Outside citations wrong before the rewrite

### B-29. §13.2's write-surface bullet also needs §11.4 (inbound row 55)

- Sources: `inbound_check_1.md` row 55; survey 1 part D.
- Evidence: spec 9788–9796 cite §11.3 for the write-surface and entry
  violations, including `EntryTypeMismatch` and the attach renormalization,
  which only §11.4 ("Diagnostic sites") states, before and after.
- Old (9788): `- **The write-surface and entry violations** ([§11.3][s11-3]), all raised at`
- New: `- **The write-surface and entry violations** ([§11.3][s11-3], [§11.4][s11-4]), all raised at`
- Recommendation: accept; it can ride the landing pass (one line, chapter
  13's text untouched otherwise).
- Status: Accepted for track 2 (orchestrator). Applied by track 2 agent 1.

### B-30. Appendix B's `claims` row cites §11.4 for §11.3's claim (inbound row 75)

- Sources: `inbound_check_1.md` row 75; survey 1 part D.
- Evidence: spec 12622, "The enumerated face set *is* the claim, what the
  device may write rather than what it will | [§11.4][s11-4] |". The claim is
  §11.3's (old 7160; new 449).
- New: `… what the device may write rather than what it will | [§11.3][s11-3], [§11.4][s11-4] |`
- Recommendation: accept; landing pass or track 2.
- Status: Accepted for track 2 (orchestrator). Applied by track 2 agent 1.

### B-31. §8.6 says device and trace addressing use slash paths (inbound row 12)

- Sources: `inbound_check_1.md` row 12; survey 1 part D.
- Evidence: spec 3390–3392: "Declarations, error messages,
  [device]/[trace] addressing ([§11.3][s11-3]) and the HDF5 log tree share it
  verbatim." §11.3 (old 7138–7140) and §8.6's own spec 3465–3467 say the
  write side (devices, mappings, the trace) speaks face names only. Only
  inspection reads, device read bindings among them, use slash paths (§11.2,
  old 7078–7081). D-129's Position, "the write side speaks contract
  exclusively", settles it. The HDF5 export is open in `pending.md`
  (127–135), so "the HDF5 log tree" states a rule for a future artifact,
  which may stay.
- Proposal: "Declarations, error messages, inspection reads of the snapshot
  and the log ([§11.2][s11-2]) and the HDF5 log tree share it verbatim." The
  next sentence ("A device is any attached participant outside the loop, and
  the trace is the primary record of a session") glosses the two removed
  links and goes with them.
- Recommendation: rule in track 2 as a correction (a Position settles it).
  Chapter 8 is already rewritten, so run `check_bold.jl` and the glossary
  check after the edit.
- Status: Accepted for track 2 (orchestrator). Applied by track 2 agent 1.

### B-32. The case study puts the greedy claim at run start (inbound row 308)

- Sources: `inbound_check_1.md` row 308.
- Evidence: `companions/flight_case_studies.md` 355–359: the greedy claim and
  liveness "both at run start against the frozen roster ([§11.3][s11-3])".
  §11.3 computes the claim at the attach point (old 7192–7193); liveness is
  baked at run start (§11.7, D-270 bullet 1).
- Proposal: the inbound check's text: "`attach!` of the GUI under the greedy
  binding makes a greedy claim over every unclaimed face at the attach point
  ([§11.3][s11-3]). Then `run!(sim; pace = 1, t_end = 1000)` settles liveness
  with zero configuration at run start, against the frozen roster
  ([§11.7][s11-7])."
- Recommendation: accept in track 2.
- Status: Accepted for track 2 (orchestrator). Applied by track 2 agent 1.

### B-33. `implementation.md`'s control.jl Spec line cites §11.3 (inbound row 279)

- Sources: `inbound_check_1.md` row 279.
- Evidence: `implementation.md` 311, "Spec: §10.7, §11.3, §12.1–§12.4, …";
  the entry (lines ~280–310) covers the control plane, the pacer and the
  pause block, and says the lifecycle gates are sim.jl's.
- New: `Spec: §10.7, §12.1–§12.4, §12.6, D-021, D-027, D-203, D-255,`
- Recommendation: accept in track 2.
- Status: Accepted for track 2 (orchestrator). Applied by track 2 agent 1.

### B-34. Other outside citations into chapter 11 that were already loose

- Sources: survey 1 and 2 part D; `inbound_check_2.md` notes; B, F, J
  `rulings.md` (inbound).
- Items, each checked at its line:
  - Appendix B spec 12623, the `reads`/`map_output` row cites §14.4 and
    §11.2; §11.6 holds the labeled NamedTuple (R5). Proposed: add §11.6.
  - Appendix B spec 12819, "a device stops through `stop!(handle)`
    ([§11.6][s11-6])"; §11.6 says "request shutdown" and never spells it.
    `src/devices.jl` 118 defines `stop!(handle::DeviceHandle)`. Proposed:
    hold; the name is Appendix B's to state.
  - §12.7 spec 9496–9497, "on the *structural* side of that line
    ([§11.5][s11-5])"; §11.5 draws no structural/parametric line (§12.7 does,
    spec 9482). Proposed: drop the §11.5 pointer in chapter 12's rewrite.
  - §12.4 spec 8828, "reads stale … from the first frame ([§11.8][s11-8])";
    §11.8 never states it, before or after. Proposed: chapter 12's rewrite
    cites D-138 (Rationale log 4557–4559 states it) or drops the pointer.
  - `companions/frame_walkthrough.md` 211–212, `publish!` "bumps the wait
    counter ([§11.2][s11-2], [D-230][d-230])"; the counter is §12.3's.
    Proposed: §11.2 → §12.3.
  - `companions/flight_case_studies.md` 397, "The GUI peek-batch
    ([§11.7][s11-7])"; §11.7 has none (D-047 Position, log 1496–1497, names
    it). Proposed: cite D-047 in place of §11.7. Lines 340–345 (the tap's
    `map_output` "on its task", §11.2): minor, hold.
  - Glossary *trace record* (spec 14195) points at §11.5, which never uses
    the phrase; `g-trace-record` is on the glossary check's WHITELIST. Hold.
  - Glossary *frame* (spec 13597–13599) cites §11.1 alone; §10.1 holds the
    grid step since chapter 10. Proposed: add §10.1.
  - D-200 Position (log 7360) cites §11.4 for the harness writer's
    no-such-face `OutOfClaimEntry`; §11.4 states face-name validity checked
    at staging in general, and §11.8 (new 1726) names the harness case.
    Proposed: no edit (the Position is the ruling; §11.4 holds the site).
- Recommendation: accept the proposals marked; the rest hold.
- Status: Accepted for track 2: the marked proposals (Appendix B §11.6, the walkthrough §12.3, the case study's D-047, the frame glossary §10.1). The §12.7 and §12.4 items join chapter 12's carried list. The rest hold.
### 3b. Stale Spec fields

### B-35. D-136's Spec field lists §11.1 and §11.4; D-168's lists §11.3 (inbound rows 203, 205, 228)

- Sources: `inbound_check_1.md` rows 203, 205, 228.
- Evidence: log 4395 (D-136 Spec) lists §11.1 and §11.4; neither section
  states the diagnostic cell or the heartbeat, before or after (§11.4 is the
  drain point D-136's Rationale names, log 4402–4403, not where the mechanism
  lives). Log 6106 (D-168 Spec) lists §11.3, which says nothing of fan-out
  tolerance or the meet.
- New (bare): D-136, `**Spec.** §9.8, §10.7, §11.2, §11.6, §11.8, §12.2, §12.4, §13.2, §13.5, Appendices C/D`.
  D-168, `**Spec.** §6.1, §8.2, §14.10`.
- Recommendation: accept in track 2.
- Status: Accepted for track 2 (orchestrator). Applied by track 2 agent 1.
### 3c. Annotations of stale Positions and Rationales

### B-36. D-268: the repeated `shutdown!` arises in `run!`'s interrupt arm (E2)

- Sources: E2 (owner); `new_entries.md` (track 2 annotations); R20, R31.
- Evidence: D-268's 2026-09-30 amendment (log 10950–10955): "The arm releases
  the calling-task entry itself when its wrapper never recorded the release".
  `src/sim.jl` 1212–1227 at `f61b1af`; `src/devices.jl` 406–425 records no
  release.
- Proposal: `Annotation (2026-10-13): since D-310 no device runs on the calling task, and the wrapper records no release. The repeat arises in run!'s interrupt arm, which releases directly each device it never spawned and advances a cursor after each shutdown! returns; an interrupt between a return and the cursor's advance repeats that call (§11.6).`
- Recommendation: accept (owner-ruled).
- Status: Accepted for track 2 (orchestrator). Applied by track 2 agent 1.

### B-37. D-160: no `mark_dead!` exists (E3)

- Sources: E3 (owner); `new_entries.md`.
- Evidence: D-160 Position (log 5683–5686) names `mark_dead!` as a contract
  neighbour of `report!`. `src/devices.jl` 397–399; D-138 Rationale (log
  4557–4558, "no dead-marking machinery of its own").
- Proposal: `Annotation (2026-10-13): no mark_dead! exists. A device's death is marked nowhere beyond its record: the task has ended, task_state says so at the next publication, and the heartbeat goes stale (§11.6, §12.2, D-138, D-193).`
- Recommendation: accept (owner-ruled).
- Status: Accepted for track 2 (orchestrator). Applied by track 2 agent 1.

### B-38. D-138: the shipped GUI, `needs_calling_task` and "marks it dead" (E5 and more)

- Sources: E5 (owner); `new_entries.md`; A `rulings.md` (inbound, log
  4571–4573); survey 1 part E; survey 2 part E.
- Evidence: D-138 Rationale (log 4571–4573) quotes "**Topology is derived
  after initialization** ([§11.1][s11-1])" for a `needs_calling_task` holder,
  which D-310 bullet 1 withdrew and R3 removed from §11.1; log 4576–4579 has
  the shipped GUI attach with `should_abort = true` under `gui = true`, both
  withdrawn by D-310. D-138's Position (log 4544) says "marks it dead",
  against its own Rationale (log 4557) and `src`.
- Proposal: one annotation: `Annotation (2026-10-13): since D-310, needs_calling_task and gui = true are withdrawn and no GUI ships, so the topology clause and the shipped GUI's should_abort = true are historical. "Marks it dead" in the Position means no task is spawned and the record shows it; nothing else marks a device dead (D-160's annotation).`
- Recommendation: accept; the owner ruled the E5 part, and the other two
  clauses state only what D-310 and D-138's own Rationale record.
- Status: Accepted for track 2 (orchestrator). Applied by track 2 agent 1.

### B-39. Four entries still describe the withdrawn calling-task device (D-310)

- Sources: G1 `rulings.md` (corrections); A `rulings.md` (open question 3);
  `inbound_check_1.md` row 163; survey 1 and 2 part E; survey 2 F53.
- Evidence: D-102 Rationale (log 3148–3151): "claims-release/detach on every
  exit" (D-106's freeze keeps claims to run end) and the GUI "called inline
  on the calling task ([§11.1][s11-1])". D-093 Rationale (log 2855–2861): the
  GUI "the one rostered device *without* a spawned task", the loop moving.
  D-132 Rationale (log 4155–4158): "in the spawned-loop topology Ctrl-C lands
  in the calling task's inline device loop body". D-025 Position (log
  903–906): "main-thread affinity and RMW widgets its only peculiarities".
  D-310 bullet 1 (log 13059–13061) withdrew the inline branch.
- Proposal: one annotation per entry, each beginning
  `Annotation (2026-10-13): since D-310 every rostered device, the GUI included, runs on a spawned task, so …`
  and ending, for D-102, "the inline clause is historical, and claims stay to
  run end (D-106)"; for D-093, "the GUI-without-task clause and the movable
  loop are historical"; for D-132, "the topology clause is historical; the
  wrapper's discrimination stands on the Position, an operator interrupt
  being a control-plane stop, not a failure"; for D-025, "main-thread affinity is gone, and
  widgets that read, modify and write remain the GUI's one peculiarity". D-102
  also takes D-366's amendment (B-10).
- Recommendation: accept. Survey 2 F53 says Julia delivers SIGINT to the main
  task, citing D-268's Rationale (log 11005–11008); that probe shows only
  where a held signal raises, not which task receives it, so the D-132 text
  above claims nothing about delivery.
- Status: Accepted for track 2 (orchestrator). Applied by track 2 agent 1.

### B-40. D-174 superseded the interactive-writer halves of D-044, D-104 and D-106

- Sources: survey 1 part E (superseded and half-superseded citations; stale
  entry text); C, D `rulings.md`.
- Evidence: D-174 Rationale (log 6386): "Supersedes the interactive-writer
  halves of D-044, D-104 and D-106." None of the three carries an annotation.
  D-044 Position (log 1396–1399), "the derived interactive surface (GUI +
  `stage!` …)"; D-106 Position (log 3266–3267), "plus the interactive
  remainder"; D-104 Position (log 3200–3205), the interactive half and the
  `Union{Nothing,T}` carrier, which D-202 also amended (log 7393–7396).
- Proposal: D-044 and D-106: `Annotation (2026-10-13): amended by D-174. The derived interactive surface is retired; the GUI is an ordinary enumerated writer, and the harness writer is the one derived surface.`
  D-104: the same, plus "The carrier is values-plus-mask since D-202."
- Recommendation: accept.
- Status: Accepted for track 2 (orchestrator). Applied by track 2 agent 1.

### B-41. D-134's whole Position is retired: mark it superseded

- Sources: `inbound_check_2.md` (log 4278); survey 1 and 2 part E.
- Evidence: D-134 Position (log 4275–4278): the `interactive(b)` marker,
  probed by "§11.6's method-presence idiom". D-174 Rationale (log
  6371–6372): "The `interactive(b)` marker and `InteractiveConflict` are
  retired". D-134's status reads "ratified". The frozen spec cites D-134
  nowhere, so a status change breaks no spec citation.
- Proposal: `**Status.** superseded → D-174`, and the inbound check's
  annotation: "§11.6 no longer detects sides by method presence. D-177
  declares them, and D-174 replaced the `interactive(b)` marker with
  `is_greedy`." Run `check_rows.jl`; rebaseline if coverage shrinks.
- Recommendation: accept. If the orchestrator prefers not to change a status
  in track 2, the annotation alone suffices.
- Status: Accepted as an annotation only. D-134's status stays: a status change is the log's decision, not track 2's.

### B-42. D-045 bullet 1 says "slot unclaimed"; §11.7 says "inside the GUI's own claim"

- Sources: H `rulings.md` (open question 2); survey 2 part E (item 9, stale
  text).
- Evidence: D-045 bullet 1 (log 1428–1429): "transitive root-slot resolution ∧
  slot unclaimed". D-174 Rationale (log 6382–6383): "live iff the port's feed
  chain terminates in a root slot **inside the GUI's own claim**". The two
  differ only when the GUI claims less than every unclaimed face, which
  D-174 made legal. D-044's Position (log 1396–1397) settles which holds: an
  enumerated surface is "binding-bounded even on unclaimed faces", so the
  GUI cannot write an unclaimed face outside its claim.
- Proposal: `Annotation (2026-10-13): since D-174 the GUI is an enumerated writer, so "slot unclaimed" reads "slot inside the GUI's own claim"; a face outside it is OutOfClaimEntry (D-044).`
- Recommendation: accept (rule 10: the spec and the later entry agree). Not
  serious. The liveness bold keeps citing D-045; the owed Position for
  D-174's wording is in B-48.
- Status: Accepted for track 2 (orchestrator). Applied by track 2 agent 1.

### B-43. D-026 says "build-time resolution"; liveness is baked at run start

- Sources: H `rulings.md` (open question 3); survey 2 part E.
- Evidence: D-026 Position (log 923–924): "build-time resolution to root input
  slots". D-270 bullet 1 (log 11162–11167): `port_views` bakes the
  resolution and the liveness verdict "once at its top, after the freeze".
- Proposal: `Annotation (2026-10-13): resolution is baked at run start, when the GUI's loop body builds its port views after the roster freeze (D-270), not at build.`
- Recommendation: accept.
- Status: Accepted for track 2 (orchestrator). Applied by track 2 agent 1.

### B-44. D-096: the calling task, the interactive writer and an objectless reason

- Sources: survey 1 part D and E; C `rulings.md` (D-096 citation).
- Evidence: D-096 Position (log 2955–2960): staging "from the calling task
  into the interactive writer (D-044's derived surface) … drained *last* …
  (the explicit hand of code beats a widget interaction …)". D-200 (any
  task), D-174 (harness writer; the reason "objectless once surfaces are
  disjoint", log 6383–6385).
- Proposal: `Annotation (2026-10-13): stage! runs on any task (D-200) and writes the harness writer's cell (D-174). The harness cell still drains last, now as plain convention; the stated reason is objectless once surfaces are disjoint (D-174).`
- Recommendation: accept; it pairs with B-21.
- Status: Accepted for track 2 (orchestrator). Applied by track 2 agent 1.

### B-45. D-136 carries none of its five amendments

- Sources: J `rulings.md` (open question 3); survey 2 part E; R10 F52.
- Evidence: D-136 Position (log 4389–4390) "one per rostered device plus one
  for the loop itself", amended by D-200 (harness cell, log 7360: "This amends
  D-136") and D-317 bullet 5 (the `Model`'s cell, log 13616–13618). Rationale:
  "acquire-loaded at the drain" (log 4406), amended by D-240; "a quiet frame
  adds zero heap allocation" (log 4419–4420), amended by D-241; "§9.8's scoped
  model-sweep zero-allocation invariant" (log 4428–4429), against §9.8's
  "scoped to the stepping loop" (D-305 bullet 1, log 12943). D-136 has no
  annotation (log 4385–4456).
- Proposal: `Annotation (2026-10-13): amended by D-200 (the harness writer's cell), D-317 (the Model's cell, folded into the loop's account), D-240 (the heartbeat is read at publication) and D-241 (one small vector of records per publication). The zero-allocation invariant is scoped to the stepping loop (D-305).`
- Recommendation: accept.
- Status: Accepted for track 2 (orchestrator). Applied by track 2 agent 1.

### B-46. Other stale Positions and Rationales

- Sources: survey 1 and 2 part E ("Stale entry text"); B, D, F `rulings.md`.
- Each checked at its line; one annotation each, text in brief:
  - D-024 Position (log 876–877): "complete writers overwrite … (retry bounded
    by drain interception)". Amended by D-104's one policy; the harness
    cell's retry is not bounded by interception alone (D-200, R4).
  - D-038 Position (log 1250–1252): "private cells included,
    presentation-filtered" (gone with D-165 and D-194) and "trace header =
    full `(x, m, z)`" (the full-state capture is the checkpoint's, D-274).
    `z` alone is vocabulary (rule 2) and needs nothing.
  - D-083 Position (log 2582–2583): "local cells accessible — presentation
    filters are defaults, not walls"; no local cells remain (D-165, D-194).
  - D-098 Rationale (log 3019): the remedy "read the auto-published port";
    D-252 removed auto-publication.
  - D-105 Position (log 3241–3242): "the `maxlog = 25` successor" as the
    device's rate limit; D-136 made the bound the rate limit and 25 a
    renderer's number (log 4398, 4455–4456). "`report(`" is vocabulary
    (D-160) and needs nothing.
  - D-137 Position (log 4463–4464): "a new `Simulation` keyword"; the keyword
    is `init!`'s, `restore!`'s and `replay!`'s since D-261. Rationale (log
    4509–4511): the `sizehint!` "for the expected duration"; R29: a finite
    `log_max` is the hint (`src/dataplane.jl` 750).
  - D-176 Position (log 6439): "against the header's schema"; the schema list
    left the header with D-255 bullet 3 (log 9902–9904).
  - D-203 Rejected (log 7516–7518): "the effective policy already lives in the
    run metadata (§11.5, §13.5)"; D-255 (log 9919–9920) puts the terminating
    advance's policy in the termination record, and the header holds none.
    The inbound check's text: "the effective policy no longer lives in the
    run metadata. The deployment holds no policy, and the termination record
    carries the terminating advance's (§11.5, D-255). The `t_end`
    rejection's ground, one home for the fact, stands."
  - D-103 Position (log 3168–3173): sides "detected by method presence";
    D-177 (declared traits) and D-146 (renames). Its Rationale stays true.
  - D-107 Position (log 3308–3311): density-matched retention; D-176
    supersedes its density rule (log 6436–6437).
  - D-127 Position (log 3967–3970): the header's deployment block with `n`
    and the `t_end`/`stop_on` pair; D-255 bullet (log 9919) leaves the policy
    out of the header. D-133 already carries its annotation (log 4247).
- Recommendation: accept each as an annotation.
- Status: Accepted for track 2 (orchestrator). Applied by track 2 agent 1.
### 3d. Log citations into chapter 11 that point at nothing

### B-47. Log pointers to chapter 11 content, and the ones needing no repair

- Sources: `inbound_check_2.md` (log 9749, 11555); G2 `rulings.md` (open
  question 1); survey 1 and 2 part D and E; C `rulings.md` (D-208).
- Annotate (a direct retarget would drop a citation, which
  `audit_fragments.jl` treats as fatal under rule 7):
  - D-252 Rejected (log 9749): "([§11.7][s11-7]'s note)"; the dev-mode note is
    §11.2's (old 6962–6964; new 202). Annotation: "the dev-mode note is
    §11.2's."
  - D-274 Rationale (log 11555): "the persistence deferral of §11.5"; §11.5
    states none. Annotation: "the persistence deferral is `pending.md`'s (Log
    and trace persistence) and Appendix B's, not §11.5's."
  - D-177 Rationale (log 6501–6504): the `sides(b)` answer "annotated inline
    where §11.6 lists the rejection". R6 cut §11.6's list to one sentence
    citing D-177. Annotation: "§11.6 names the three rejections in one
    sentence citing this entry; the answer lives here."
  - D-216 Position (log 8025–8026): `DeploymentInvalid`'s parameter list
    gains `log`, `log_every`, `log_max`, `t_end`, which moved to the doors and
    advances (D-255, D-261). Check Appendix C's `DeploymentInvalid` row
    before annotating; it is chapter 13's text.
- No repair needed (checked):
  - D-067 Rejected (log 2049), D-084 Rationale (log 2618), D-153 Rejected (log
    5483) cite §11.7's anti-diagnostic lesson; R16's clause now states it.
  - D-364 Rationale (log 14546), "decoded for replay and what-if replay
    (§11.5)": true of both what-if senses.
  - D-208 Position (log 7699–7701), `input_connections`/`input_types`: rule 2
    (D-267 and D-303 renamed them forward; log 2365, 6212). C's correction is
    not needed.
  - D-022 Position (log 836), "interactive = batch + devices": rule 2 (D-122's
    rename).
  - D-101 Spec (log 3102) lists §2.5: §2.5 cites D-101 for deterministic
    replay (spec 586–587). Survey 2's flag is wrong. D-101 does lack §11.1
    (B-13).
  - D-123 Rationale and Rejected (log 3856–3858, 3870–3871): §11.1 still
    holds the loop-iteration sense.
  - D-109 Rejected (log 3409) and Annotation (log 3399–3404): superseded.
  - D-044 Rejected (log 1419), "§11.7's stays-put and sole-writer
    arguments": §11.7's dead-slider passage (old 8107–8112) carries the
    sole-writer argument; low, hold.
  - D-247 Rationale (log 9446), "the trace header spell `plant/x.q` (§11.5,
    §14.4)": §11.5 says nothing of spellings; low, hold.
  - D-029 Position (log 991), "cleared at `init!`": `init!` now builds a fresh
    trace (D-260); same effect, hold.
- Recommendation: accept the four annotations; close the rest.
- Status: Accepted: the four annotations (check Appendix C's DeploymentInvalid row before D-216's). The rest closed.
### 3e. Entries owing a Position (Rationale-only rulings the chapter bolds)

### B-48. Bolds resting on a Rationale or a Rejected item

- Sources: every unit's "Rationale-only rulings"; survey 1 part E items 1–18;
  survey 2 part E items 1–11; verifier G1 ("the log owes Positions").
- Method: for each ruling, a grep of all Positions in the frozen log (3,725
  lines) on its key words. A new entry restates only the cited Rationale; it
  decides nothing (lesson 17). Numbers come from chapter 11's block, D-367
  onward.
- Owed, each a bold in the new chapter:
  1. **D-093, the start gate** (A). Rationale log 2852–2854: spawn inside
     `run!` replaces the start gate, and first-boundary synchronization is
     §12.3's counter-plus-condition predicate wait; Rejected log 2867–2868.
     Grep "start gate", "first-boundary", "predicate wait": no Position.
  2. **D-137, the log's bound** (B, seven bolds). Rationale log 4469–4511: a
     count, not a memory budget; default 65536, finite unconditionally; the
     stride doubles when the log fills; the guarantees normative, the
     mechanism a sketch; the endpoints outside the bound; a view policy.
     Grep "65536", "doubling", "stride", "log_max": only D-137's own Position
     (the bound exists) and D-261 (the keywords' doors).
  3. **D-136, the diagnostic channel** (J, six bolds), with **D-241's quiet
     frame** (J, one bold). D-136 Rationale log 4398–4432: the bound is the
     rate limit; the take at the frame-top drain; the status a concrete
     frozen value; presentation apart from channel policy (and Rejected log
     4455–4456); the terminal snapshot's final counters; the isbits counters.
     D-241 Rationale log 9172–9174. Grep "rate limit", "frozen value",
     "isbits", "presentation", "terminal snapshot": D-133 (a deferral, log
     4215) and D-201 (the terminal account complete to its frame top, a
     different ruling). One D-305-style entry would serve, as survey 2
     suggests.
  4. **D-174's corollaries** (C, D, G2, H). Rationale log 6363–6385: the
     empty remainder staked and reported; several interactive front ends
     legal; the harness writer's derived surface recomputed at each roster
     change, the renormalization applying to it alone, `ClaimedFaceEntry`
     narrowed to it; liveness "inside the GUI's own claim". Grep "empty
     claim/complement/remainder", "front end": D-310 bullet 2 only (front
     ends attached by hand). The drain-last convention needs no bullet if
     B-21 cites D-096.
  5. **D-177's conformance check and the empty enumeration** (G2, two
     bolds). Rationale log 6481–6508. Grep "conformance",
     "BindingContractMismatch", "may-write-nothing": D-216's Position (log
     8027–8030) names `BindingContractMismatch` for "the binding declaring
     neither side" and `DeviceContractMismatch`; that covers one bullet of
     the check, not the check.
  6. **D-138, `shutdown!` tolerates a partially initialized device** (G1).
     Rationale log 4552–4553. D-268's Position bullets (log 10950–10963)
     state the repeated and the no-`init!` calls but take "close only what is
     open" from §11.6, a source citing the spec back (lesson 43). The
     `should_abort` keyword needs no bullet if B-22 cites D-177; its two
     dispositions (log 4563–4570) are plain text.
  7. **D-102, `should_close` dissolves, and the two loop idioms** (G1).
     Rationale log 3149–3154. Grep "should_close", "dissolv": D-030 (log
     1011, the predecessor's path), not this ruling.
  8. **D-106, death is not detach** (C), with the mid-run reader and the
     drain's compilability. Rationale log 3273–3287. Grep "death", "dead",
     "orphan": D-146's Position (log 5112) lists "claims orphaned to run end"
     as §11.3's vocabulary, which cites the spec back.
  9. **D-047 Rejected, services own root-input initial values** (C).
     Rejected log 1513–1514, D-068 Rejected log 2083–2084. D-068's Position
     (log 2062–2065) has the services enforce coverage before writing, close
     to but short of the ownership ruling.
- Not owed after all: **D-132's interrupt bold** (G1). D-132's Position, "a
  control-plane stop, not a failure", carries "never a `DeviceCrash`";
  G1 listed it as Rationale-only (log 4155).
- Plain Rationale-only citations (no bold; lower priority): D-083 (log
  2587–2595), D-087 (2709–2711), D-104 Rejected (3223–3226), D-105
  (3249–3250), D-108 (3357–3360), D-122 (3827–3828), D-192 (7056–7060), D-194
  (7135–7137), D-202 (7400–7417), D-045 Rejected (1448–1449, R19), D-026
  Rejected (933–936, R16), D-200 Rationale (7364, R4), D-252 Rejected
  (9749–9751), D-029 Rejected (1002), D-176 Rejected (6459–6461).
- Recommendation: draft one entry per numbered source (nine, or eight with 3
  merged), each Position quoting its Rationale's words and naming the
  source entry, then cite each beside its source in the chapter. Hold the
  plain list unless the orchestrator wants it.
- Status: Accepted for track 2: eight new entries, D-367 to D-374 (sources 3 merged), each restating its source's words only, then cited beside the source in chapter 11. The plain list holds. Applied by track 2 agent 2. Amended after track 2's verification: B-48 has nine numbered sources (source 3 already holds D-136 and D-241), so source 9 took D-376, inside chapter 11's block; and lesson 42's drop of D-106's staging bullet cites D-044's Position beside D-106 at §11.4, as the track 2 prompt directs.

### B-49. Device identity and admission rest on superseded D-109

- Sources: C `rulings.md` (open question 1); survey 1 part E items 1 and
  "Superseded" (D-109).
- Evidence: §11.3 rows 145–149 (identity by instance, the stable id monotonic,
  never reused and living with its roster entry, the admission order, the
  rebinding spelling, `ClaimConflict` between distinct devices) are stated
  plain. D-109 (status superseded → D-310) states them in its Position (log
  3376–3382). D-310 Rationale (log 13094–13096): "D-109's identity and
  admission halves survive in §11.3: identity by instance, the stable id at
  attach, `AlreadyAttached` and `ClaimConflict`. Its affinity third and its
  topology rationale fall."
- Assessment: D-310's sentence names the surviving content, so it is more
  than a pointer back at the spec; the content itself is D-109's. A new entry
  restating D-109's identity and admission rulings (without the affinity
  check, now two-part admission), sourced to D-109's Position and D-310's
  Rationale, records nothing new.
- Recommendation: track 2 entry, then cite it at §11.3's identity paragraph.
  If the orchestrator reads D-310's sentence as citing the spec back (lesson
  43), send it to the owner instead; the owner would only ratify D-109's
  text.
- Status: Accepted for track 2 as D-375: D-310's Rationale records that D-109's identity and admission rulings survive, so the entry restates recorded rulings and decides nothing. Applied by track 2 agent 2.

### B-50. D-217 and D-255 give the trace's length as a drain count

- Sources: F `rulings.md` (correction 6); verifier F; survey 2 F59 and part
  E; R10 F59.
- Evidence: D-217 bullet 1 (log 8073–8075) and D-255 bullet 3 (log 9903):
  the length is "the number of drains since the capture". §11.5 (old 7688;
  new, F59) says "the frame index of its last drain", citing D-217, and under
  `restore!` the two differ. Later Positions agree with the spec: D-260 (log
  10189–10191), "The frame ordinal a record carries is the trace's own
  `frames`, incremented at the top of the drain"; D-274 (log 11489,
  11502–11504) restores the clock in full, frame index included, so the next
  frame is the trajectory's. `src/trace.jl` 40–49 at `f61b1af`: "its length,
  the frame ordinal of the last drain, which is also the ordinal each record
  carries (D-260)".
- Proposal: annotate D-217 and D-255: `Annotation (2026-10-13): the length is the frame ordinal of the last drain (D-260), which under init! equals the number of drains since the header; a trace that restore! opens starts at the checkpoint's frame (D-274).`
  In the chapter, cite D-260 beside D-217 at "the frame index of its last
  drain" (track 2 citation).
- Recommendation: accept (rule 10). Not an owner item: two later Positions
  carry it.
- Status: Accepted: the annotations by track 2 agent 1; the D-260 citation by track 2 agent 2.
---

## 4. Owner items: spec sentences with no entry behind them

Each stays as written and uncited until the owner rules (lesson 17; recipe
step 8). Ratifying any of them would be a design decision.

### B-51. "Printable before the run starts" (F19, held by R15)

- Sources: R15 (F19); C `rulings.md` (open question 2); survey 1 F19.
- Evidence: frozen spec 7264–7266: the partition "is a static, inspectable
  fact of the run. It is printable before the run starts and valid until it
  ends (printable like the face routes, [§13.7][s13-7])." D-106's Position
  (log 3266–3268) says "static, inspectable facts of each run", not
  printable. No `show` method exists for the roster, an entry, the plane or a
  handle at `f61b1af` (survey 1). The face routes have a printer (§13.7, spec
  10410–10412, D-257, D-315).
- Proposal: either (a) "It is fixed before the run starts and valid until it
  ends", dropping the printer promise, or (b) keep it and list a roster and
  partition printer in `pending.md` as owed.
- Recommendation: send to the owner with (a) recommended; R19 to R23 did not
  cover F19, so it is still open.
- Status: Owner item. Moves to docs/design/pending.md at the chapter's close (step 9).

### B-52. The first endpoint under `restore!` and `replay!`, and the stride's origin

- Sources: B `rulings.md` (open question 2); survey 1 part E (rows 73, 74).
- Evidence: frozen spec 7056–7058: the first endpoint is "the boundary-zero
  snapshot under `init!` …, and the snapshot the door publishes under
  `restore!` and `replay!` … The stride counts boundaries from it." D-137's
  Rationale (log 4500–4504) names the boundary-zero and terminal snapshots
  only, and nothing records where the stride counts from.
- Recommendation: send to the owner; ratify as written (it matches the doors'
  behaviour) in a track 2 entry.
- Status: Owner item. Moves to docs/design/pending.md at the chapter's close (step 9).

### B-53. An exporting logger skips or summarizes field-handle signals

- Sources: B `rulings.md` (open question 2); R10 F7; survey 1 F7.
- Evidence: `pending.md` 127–135 holds it open with the HDF5 export scope:
  "§11.2 states the loggers' skip-or-summarize rule for field handles with no
  entry; it is ruled with the summarization question."
- Recommendation: no owner action now; `pending.md` already tracks it.
- Status: Owner item. Moves to docs/design/pending.md at the chapter's close (step 9).

### B-54. "A claim is what a device *may* write", and why exclusivity holds

- Sources: C `rulings.md` (open question 3); survey 1 part A rows 104, 105
  and part E.
- Evidence: frozen spec 7160–7166 (bold "A claim is what a device *may*
  write, not what it will"). D-044's Position (log 1396–1397) covers the
  enumerated set ("a device's claim set — binding-bounded even on unclaimed
  faces"), not the may/will ruling; a log grep for "may write", "allowed set"
  and "data-dependent" finds nothing. Row 104's reason (a second live writer
  makes the applied value a timing artifact, old 7155–7158) rests on D-044's
  Rejected list (log 1409–1411), so it is a track 2 Position item, not the
  owner's.
- Recommendation: send the may/will sentence to the owner (ratify as
  written; it is the glossary's *claim* definition). Add row 104 to B-48's
  plain list.
- Status: Owner item. Moves to docs/design/pending.md at the chapter's close (step 9).

### B-55. A released root input's widgets are live again from the next run

- Sources: survey 1 part E (row 101).
- Evidence: frozen spec 7148–7149. It follows from the freeze (D-106) and
  derived liveness baked at run start (D-270 bullet 1), but no entry states
  it.
- Recommendation: owner, ratify as written. Low stakes: it may be read as a
  consequence of D-106 and D-270 and cited to them, if the orchestrator
  accepts a two-entry derivation as "restates only".
- Status: Owner item. Moves to docs/design/pending.md at the chapter's close (step 9).

### B-56. Three §11.4 sentences with no entry

- Sources: D `rulings.md` (open questions); survey 1 part E (rows 189, 197).
- Evidence: frozen spec 7473–7475, "the frame's outcome is a pure function of
  the drained batches"; 7513–7514, "The raw stick levels are the known,
  accepted loss"; 7483–7484, "Iterating a roster array costs a handful of
  dispatches per frame and remains acceptable" (a measurement claim).
- Recommendation: owner for the first two (ratify as written; the first is
  what §2.4's determinism needs from the drain). The third is a description
  of cost, not a ruling: hold, uncited.
- Status: Owner item. Moves to docs/design/pending.md at the chapter's close (step 9).

### B-57. "Assembly panels compose children by path"

- Sources: H `rulings.md` (open question 4); survey 2 part E (row 668).
- Evidence: frozen §11.7, the deferred half's constraints (new 1711–1714).
  D-270's Position (log 11157–11160) lists what a panel reads, not how panels
  compose. No entry.
- Recommendation: owner; it constrains the deferred GUI-package half, which
  D-310 hands to the browser client. Recommend parking it with that half in
  `pending.md` rather than ratifying now.
- Status: Owner item. Moves to docs/design/pending.md at the chapter's close (step 9).

### B-58. Appendix A: keep the binding traits trivial

- Sources: survey 2 part D; G2 `rulings.md` (inbound).
- Evidence: spec 12372–12375: "Keep `is_input`/`is_output`/`is_greedy`
  trivial, a literal or a flag read off a field fixed at the constructor call
  ([§11.6][s11-6])". §11.6 states no such rule, before or after, and no entry
  does.
- Recommendation: owner. If ratified, §11.6 states it with the new entry;
  if not, Appendix A drops the sentence's §11.6 pointer.
- Status: Owner item. Moves to docs/design/pending.md at the chapter's close (step 9).

### B-59. Four §11.5, §11.6 and §11.8 statements with no entry

- Sources: survey 2 part E ("Rulings with no entry at all").
- Evidence: the layout's field list (row 522; `src/checkpoint.jl` 10–26 its
  only home); "tens of MB per hour worst case" (old 7705); "Everything
  enumerable validates at attach. Everything opaque is bounded at its runtime
  enforcement point" (old 7901–7902); "Delta plus total is what makes the
  status legible at any reading cadence" (old 8326–8327; `src/dataplane.jl`
  376–378 repeats it).
- Recommendation: hold all four uncited. The first two are descriptions; the
  third summarizes D-177 and D-216 (enumeration validated at attach, mappings
  never inspected) and may be cited to them in track 2; the fourth is a
  reason for D-136's Rationale design, owner only if it is to be normative.
- Status: Owner item. Moves to docs/design/pending.md at the chapter's close (step 9).

### B-60. `should_abort` is "never a device property"

- Sources: survey 2 part E (row 555); B-22.
- Evidence: frozen spec 7733 (new 1289): "It is per-attachment, never a
  device property." D-138's Rationale makes it an `attach!` keyword, and
  D-177's Position shows it in the signature; neither says "never a device
  property". The glossary repeats it (spec 14096–14097).
- Recommendation: owner, ratify as written; low stakes, since the keyword
  placement already implies it.
- Status: Owner item. Moves to docs/design/pending.md at the chapter's close (step 9).
---

## 5. Serious findings

None. No contradiction between two authoritative sources was found that a
Position does not settle, and no proposed fix changes what the framework
does. The near misses, each settled:

- `recent` can hold thirty-two values in the loop's record (B-18): D-317
  bullet 5 settles the fold; the fix is wording.
- The loop's record has no heartbeat (B-19): D-240 and D-193 settle it
  against D-136's older text (rule 10).
- §8.6 says the write side uses slash paths (B-31): D-129's Position and
  §8.6's own later sentence settle it.
- D-045's "slot unclaimed" against §11.7's "inside the GUI's own claim"
  (B-42): D-044's Position (enumerated surfaces are binding-bounded) settles
  it.
- The trace's length (B-50): D-260 and D-274 settle it against D-217 and
  D-255.
- The owner's five rulings (E1 to E5) stand and are not reopened.

---

## Landing rulings (the orchestrator, during step 7)

- **L-1. The splice and the log land in one commit.** The spliced chapter
  cites D-366, so the splice cannot pass the battery before the log entry
  exists. Commit 2 holds the splice, the Contents fix, `check_bold.jl`, D-366,
  D-102's annotation and the Spec fields.
- **L-2. `g-executable-set` joins `check_glossary.jl`'s WHITELIST** as
  "heading-defined (§9.4)". F24 removed the term's only body use (§11.1,
  where it was misapplied to activations); the term survives verbatim in
  §9.4's title, the category's case. Track 2 notes that the glossary entry
  has no prose use.
- **L-3. The stride chart's `**full**` becomes `*full*`** (§11.2, unit B).
  The bold marks a state in the chain, not a ruling, and `check_bold.jl`
  now checks chapter 11. Italics keep the emphasis, as the chain's *k*
  already does.

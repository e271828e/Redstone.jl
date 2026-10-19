# Chapter 13: evidence check (step 6a)

Items B23 to B85 of `rulings_batch.md`, the non-blocking ones. Each source
each proposal cites was opened. The spec and the log were read as the frozen
copies `scratch_survey/h1/spec.md` and `scratch_survey/h1/decisions.md`
(`1fee0fc`), by section and entry. Chapter lines are `chapter_new.md` at
`5f21eba`, which the working tree still matches. `src/`, the companions,
`extensions.md` and `implementation.md` were read from the working tree.
"Note" marks a detail that is off but leaves the proposal standing.

## Landing

### B23. CONFIRMED
- Spec 7125: "Every cell is reachable, because the table is public throughout
  ([§8.3][s8-3])."
- Chapter 330, §13.3's service row: "[device] read [bindings]" … "strict: no
  traversal past a generic child, checked at the authoring or mount level".

### B24. CONFIRMED
- Spec 12747–12748: "**The two observation sides** ([§11.2][s11-2],
  [§13.5][s13-5]). A deep snapshot path is an *inspection* read. It sees
  everything and promises nothing across builds." 12751–12752: "Bind faces in
  anything meant to outlive the current build."
- Chapter 865–866: "Inspection is human-facing, has no effect on run
  semantics, and legitimately sees every public cell."

### B25. CONFIRMED
- Spec 4705–4706: "At build it is a `UserCodeFraming`-wrapped build failure
  ([§13.1][s13-1])."
- Chapter §13.1's heading is "Reporting policy: collect the checks, fail the
  evaluations fast"; the framing is §13.2's (160–166, "**The framed set is
  every user-authored method the build invokes**").

### B26. CONFIRMED
- Spec 5085–5086: "That site's frame holds the boundary time and the replay
  index."
- Chapter 432–434: "The time is the clock at the failure, a boundary time in a
  boundary phase, the stage or trial time inside integration."
- Unit B `rulings.md` 164–166 says the same: "A table-write conformance
  failure inside integration carries a stage time."

### B27. CONFIRMED
- What 6531 holds. Spec 6530–6532 is one sentence: "then declaration order
  within a component. That keeps the [execution cursor](#g-execution-cursor)
  (the / loop-state field recording where execution stands,
  [§13.4][s13-4]) and the diagnostics stream deterministic." Line 6531 ends at
  "(the"; "loop-state field" is on 6532.
- §10.6 (6363–6640) has no nonfinite phrase at all: `rg -i
  'nonfinite|isfinite'` finds nothing in it. So the brief's landing line,
  "§9.5 (old 5094) and §10.6 (old 6531): the nonfinite check's 'loop' becomes
  the model's (F20)", describes the wrong sentence for §10.6. The target there
  is the cursor gloss. Unit B `rulings.md` 176–177 lists it correctly:
  "6531–6532 (§10.6): 'loop-level' and 'loop-state field', landing edits
  under F20".
- Also: §9.5's nonfinite phrase is at 5096, not 5094: "catch site adds the
  loop-level nonfinite-state check as the failure's divergence sibling".
- D-317 bullet 6 (log 13974–13976): "The execution cursor is the model's. It
  stays on the executor". Both "the model's" and "the executor's" fit it.
  The chapter (398–399) says "a plain mutable field of the executor", so the
  proposal's "the executor's field" matches the chapter.

### B28. CONFIRMED
- Spec 12831–12833: "`resolve(assembly, path) → AbstractComponent`. The
  getfield walk along `/` segments. It enforces the one-level rule for wiring
  ([§6.1][s6-1]) and the generic-holding rule for deep reads, at the primitive
  ([§13.3][s13-3])."
- Chapter 296–297: "resolves an immediate child, a container element's key
  segment included." 312–314: the generic-holding rule "is enforced by the
  service walk".

### B29. CONFIRMED
- Spec 13249–13250: "The stages are the ones [§13][s13] fixes:"; 13253–13254:
  "while *user code* runs (an interface-connection body, a probe)."
- Chapter 111: "surfaces (build, service or runtime)". Brief F5: "the
  structure step reads the declaration bodies, interface-connection bodies
  among them; … the activation at `T` runs the continuous tier's functions."

### B30. CONFIRMED
- Spec 13296–13297: "a step that throws renders its warnings with the
  collection ([§13.2][s13-2], [D-250][d-250])."
- Spec 4575–4576, in §9.2: "A step that throws renders its warnings with the
  collection it throws." `inbound_scope.md` 60: "[A C-135] relocated to
  docs/design/spec.md". Chapter 211–213 points to §9.2 for it.

### B31. CONFIRMED
- Spec 13618–13620: "Cursor frame (component path, function, and the boundary
  phase, which is an RK stage, an event round, a localization trial evaluation
  or a tick), boundary time,".
- Brief F12 and F14 give the proposal's wording; brief "Edits at landing"
  lists "Appendix C's `StepError` and `ArgumentInvalid` rows (F12, F14, F54)"
  under track 2.

### B32. CONFIRMED
- Spec 13624: "Component path, the offending state block, boundary time and
  index."
- `src/diagnostics.jl` 284–290: `path::String`, `leaf::String`, `value::Any`,
  `t::Float64  # the frame-top time the integrate landed on`, `boundary::Int  #
  the frame-entry boundary index`. The brief's track 2 list names only the
  `StepError` and `ArgumentInvalid` rows.

### B33. CONFIRMED
- Spec 14690–14693: "the component path as an index into the `Outputs`'s
  execution order, … so a runtime failure gets its frame without exception
  frames in the hot path ([§13.4][s13-4])."
- Chapter 400–402: "The first is the component, by its index in the
  structure's component list". Brief R7: "'exception handlers' for those
  senses".

### B34. CONFIRMED
- Spec 14484–14486: "`ControlRequestedStop` is outside it, since the policy is
  what the caller declares and the stop word is what anyone can issue
  ([§13.5][s13-5], [D-255][d-255], …". 14481–14482: "afterwards only the
  termination record keeps one".
- Spec 8654: "**`ControlRequestedStop` sits outside the stop policy**
  ([D-255][d-255])" (§12.1). Neither chapter says it: old 687 and new 818
  name `ControlRequestedStop` only as a source.
- Chapter 722–737 holds the ignore list, the mask and the `t*` hit.

### B35. CONFIRMED
- 7757–7758: "keywords of each advance ([§13.5][s13-5], [D-316][d-316])".
  8655: "what the caller declares for one advance ([§13.5][s13-5])". 9849:
  "each `replay!` call declares its own ([§13.5][s13-5])". 13140: "nothing
  else keeps one ([§13.5][s13-5], [D-260][d-260])". 13129: "declared for
  **this advance**, validated per call | [§13.5][s13-5]".
- Note: the Appendix B cite is at 12873–12874 ("keywords of each advance /
  ([§13.5][s13-5])"), not 12875–12876.
- Chapter 712–714: "[§12.6][s12-6] declares the stop policy per advance, with
  `t_end` and `ignore_stop_requests` as keywords … and gives the value's
  lifetime."

### B36. CONFIRMED
- Spec 5385: "The seam is diagnostic only ([§13.5][s13-5]), and it makes one
  promise."
- Neither chapter mentions a measurement seam. `rg -i 'measurement|seam'`
  finds only old 6 ("the seam between 'the model reached a terminal state'…")
  and the generic seam of §13.3.

### B37. CONFIRMED
- Spec 7766–7767: "names, its `Deployment` and `t₀` ([§13.5][s13-5],
  [Appendix B][sB])." Glossary 14551: "**run metadata** — the trace header's
  `Deployment` and `t₀`".
- Neither chapter contains "run metadata".

### B38. CONFIRMED
- `extensions.md` 334: "which library structs get the parametric spelling in
  the [§13.7][s13-7] migration — whether".
- D-311 bullet 3 (log 13479–13481): "[§13.7][s13-7]'s `W{Float64}` form falls
  with [D-263][d-263]." The new chapter has no "migration".

### B39. CONFIRMED
- `companions/migration_outline.md` 80: "Falling-edge consumers wire a NOT
  gate (the Bool gates, [§13.7][s13-7])." The file has no `[d-311]`
  definition (its link block starts at 130 with `[d-070]`).
- D-311 bullet 2 (log 13478): "`Not` is not admitted." Rejected (13512): "*A
  `Not` gate:* a one-input gate consolidates nothing". Chapter 1011–1012 names
  `Or{N}` and `And{N}` only.

### B40. UNCONFIRMED in part
- Only `extensions.md` 346 has the quoted phrase: "the component joins
  [§13.7][s13-7]'s starting inventory as its one persona-admitted member".
- Spec 3325–3326 reads "**`Group` expresses it as a single library
  component**, part of the starting inventory ([§13.7][s13-7],
  [D-184][d-184])". Log 7016–7017 reads "the component enters
  [§13.7][s13-7]'s inventory as its one persona-admitted member". A literal
  replace of "§13.7's starting inventory" fits only `extensions.md`.
- The mismatch itself holds. Chapter 1011–1013 lists the starting inventory
  without `Group`; 1022 says "`Redstone.Blocks`, `Group` included". Old 866,
  887 and 892 say the same.

### B41. UNCONFIRMED in part
- Glossary 14695–14696 holds the quoted words: "(global value-blind, or local
  primal-carrying at sampled states)".
- `implementation.md` 933 does not: "`Tracer{S}`, §13.8's set-propagation
  scalar. It is global on `true` and local on `false`, and `Undecidable` is
  the marker between them." The fix there is "sampled on `false`", not "the
  sampled mode".
- Chapter 1292: "The *sampled* set-tracer (the local, primal-carrying mode) at
  sampled states". Brief R28: "Correction 3, the glossary's
  feedthrough-tracer entry, goes to track 2."

## Track 2

### B42. CONFIRMED
- Log 599–601: "Set-propagation tracers (global + sampled-local),
  diagnostic-only; cycle diagnostics from SCC decomposition of the Stratum-B
  topological stall". D-259 (log 10433): "Retire the strata"; its second step
  is "the nominal evaluation".
- Rejected 617–621 hold "the topological stall's raw residue" and "a single
  DFS back edge". Chapter 1276–1278 cites D-012 for them. Brief R28 sends the
  tracer glossary entry to track 2.

### B43. CONFIRMED
- Position (log 1071–1074): "Shutdown: complete the boundary → publish final
  snapshot → … loop failure runs the same protocol from the catch path." No
  discard or promote. Rejected 1089: "*Mid-frame abort:* torn final snapshot;
  consumers observe un-swept state."
- Note: the Spec field already lists §13.6 (log 1076: "[§12.4][s12-4],
  [§13.6][s13-6]"). "Cited nowhere in §13.6" was survey 2's finding on the
  old chapter (survey_2 259, 967); the new §13.6 cites D-030 at 895, 905 and
  931.

### B44. CONFIRMED
- Rejected (log 1839): "*Suppression heuristics:* adjacent path-sorted pairs
  are self-explanatory." Brief F4: "the did-you-mean names the input the other
  error says is unfed … The claim that they render adjacently by path is
  cut."
- Survey 1 item 2 cites "D-057 Rejected, D-229 Rationale" and "A reason, not a
  ruling; may need none." Note: no Rejected line says "partial results"; the
  nearest is 1836–1838, "machinery for failures that are singular in
  practice".

### B45. CONFIRMED
- Log 1847: "carried by a single `BuildError` thrown at the stratum barrier".
  1852: "Warnings ride the same stream and never throw." 1866–1867: "*A
  separate warning channel:* two pipelines; blocks a warnings-as-errors
  switch." 1865: "*Instances/model types in diagnostics:* the
  `compact_backtrace` lesson." Spec (1856): "[Appendix C][sC]" alone.
- Brief track 2 list: "D-250 and D-058 (R11)".

### B46. CONFIRMED
- Spec field (log 1884): "[§12.6][s12-6], [§9.5][s9-5], [§13.4][s13-4],
  [§14][s14]", no §13.6. Chapter 948, in §13.6: "([§12.6][s12-6],
  [D-059][d-059], [D-387][d-387])".
- Note: the quoted sentence is the chapter's (395), not the log's. The
  Rejected line behind it (log 1889–1890) reads "*Per-call try/catch:*
  exception frames in the hot path to gather what a cursor store provides."
  Unit B `rulings.md` pairs the two the same way.

### B47. CONFIRMED
- Position (log 1900–1902): "(Tier-2 event where the stop must be
  localized), … policy as `stop_on` root faces at `Simulation` construction".
  The annotation (1910–1916) supersedes "Publication" and "the policy" and
  leaves that wording alone.
- Rejected 1935–1937: "*Observation-by-path:* … inspection observation sees
  everything". 1922–1924: "the closure rejection also rests on the extra
  expressiveness being logic that belongs in-model". 1919–1920: "models never
  state their terminal dynamics."

### B48. CONFIRMED
- D-130 (log 4250–4252): "*inspection* (device read bindings, GUI panels,
  snapshot/log inspection) the instance walk — … drift still loud at attach
  (`ReadBindingUnresolved`)". D-406 bullet 2 (16097): "`ReadBindingUnresolved`
  retires."
- D-242 (9508–9509): "*Inspection* replaces *diagnostic*: device read
  bindings, GUI panels, snapshot and log inspection, resolved by the instance
  walk."
- D-061 annotation (1960–1961): "The declared-type walk, the face lists and the
  terminal split stand." D-310 (13411): "The built-in Julia GUI is parked".

### B49. CONFIRMED
- Position (log 1974–1978): "`faces` gains predicate selection.", "The `Build`
  printer renders face routes", "demand-driven". The annotation (1985–1989)
  covers the junction and "not by demonstrated need ([D-313][d-313])" only.
- Rejected 1992–1993: "*Framework-privileged library blocks:* schema
  authority no longer total; the library stops testing the declaration
  layer's ergonomics." 1994: "a language, not a toolbox."
- D-251 (9979–9980) puts `select` on the passthrough helpers; D-257 (10356) is
  `show(::Structure)`.
- Note: "a gain earns no block" is not in D-062's Rejected. It is D-313's
  Rationale (13605–13607).

### B50. CONFIRMED
- Log 2274: "A `product()` helper is recorded for the [§13.7][s13-7] library,
  unbuilt." Spec (2276): "[§13.7][s13-7]" alone.
- Spec 12351 (§14.9): "`product(p₁ => "lead", p₂ => "wing")` helper belongs in
  the [§13.7][s13-7] library." Neither chapter has `product(`.

### B51. CONFIRMED
- Rationale (log 3516): "`errored` is terminal for all four ([D-059][d-059])".
  The Position (3504–3512) gives the preconditions only.
- Spec 11185: "**`errored` is terminal for every row** ([D-059][d-059],
  [D-108][d-108])." Chapter 948–950: "The stopped-sim services enforce that
  non-resumability by refusing an errored simulation outright".

### B52. CONFIRMED
- Log 3711–3712: "what [§10.4][s10-4]/[§13.4][s13-4]'s boundary indexing from
  retained snapshots presupposes"; Spec (3719) lists §13.4; Rejected 3734:
  "[§10.4][s10-4]/[§13.4][s13-4]'s counter-plus-recorded-`t` boundary
  indexing".
- Note: D-114 already has an annotation (3723–3726, "amended by
  [D-230][d-230]"), on the wait counter only. The proposed one is still new.
  Chapter 12's survey 1 (at `48d490e^`, line 999) recorded the stale
  Position.

### B53. CONFIRMED
- Position (log 3912): "exported via `faces(rig, child; except)`". Rejected
  3924–3925: "breaks the consumer-sourced slot-typing rule". D-206 (7885):
  "'slot' … → **root input**".
- Chapter 1219: "`input_passthrough(rig, "strut"; except = ("terrain",))`".
  The old chapter has no `[d-120]`.
- Note: the Spec field already lists §13.7 (3916).

### B54. CONFIRMED
- Rationale (log 4297–4298): "[§12.6][s12-6] says *five* states, agreeing with
  its own enumeration and with [§13.4][s13-4]". Rejected 4319–4320: "what
  [§13.4][s13-4], [§14][s14] and [§D.8][sD-8] all count as five statuses."
- Chapter §13.4 names `stopped`, `errored` and the return to `built` only
  (498, 539).

### B55. CONFIRMED
- Rationale (log 4342–4344): "[§13.4][s13-4]'s catch site never wraps an
  `InterruptException` in `StepError` (routes it to the stop path;
  unreachable in practice under masking, kept defensively)".
- D-317 bullet 8 (13986–13987): "An `InterruptException` is never wrapped".
  Chapter 485–486 cites D-132: "routes it to the stop path ([D-132][d-132])".

### B56. CONFIRMED
- Rationale (log 4614 on; 4623–4624): "The published **framework status
  becomes a concrete frozen value**".
- Chapter 232–233, plain: "The per-writer diagnostic cells carry it
  ([§11.8][s11-8], [D-136][d-136])." Spec 8512, §11.8: "**The published
  framework status is a concrete frozen value** ([D-136][d-136],
  [D-369][d-369])."

### B57. CONFIRMED
- Rationale (log 5050): "[§13.7][s13-7]'s grow-by-migration-demand rule".
  Rejected 5082–5083: "with [§13.7][s13-7]'s Bool gates covering falling-edge
  consumers".
- D-313 (13584–13585): "A listed block is built whenever wanted, with no
  demonstrating model required." D-311 (13478): "`Not` is not admitted."

### B58. CONFIRMED
- Rationale (log 5131–5132): "a published `Bool` output face plus `stop_on`,
  [§13.5][s13-5]'s existing machinery". D-142 (5103–5173) has no annotation.
- D-285 annotation (12474–12476): "under [D-316][d-316] a plausibility check
  meaning 'stop the run' publishes a `StopFlag` port, which `StopRequest`
  spells, and no keyword names it."

### B59. CONFIRMED
- Log 5189: "uses a root slot ([§11.3][s11-3])". 5212–5214: "Admission
  honors [§13.7][s13-7]'s strictly from demonstrated need charter: the dry run
  demonstrated the need twice, at the zero-contributor totals and at the rig."
  5211: "the block's first shipped instance".
- The annotation (5217–5222) covers `Pinned{V}`, `y_types` and `y_direct`.
  Brief F60 cuts the charter from §13.7.

### B60. CONFIRMED
- Position (log 5915–5920): "**`warning (service)` defined as a sixth
  severity** … [§13.2][s13-2]'s two-stream partition stands". No annotation
  or supersession line (5911–5933).
- D-214 (8195 on): severity "is `error` or `warning`, nothing else." D-250
  (9916): "One warning policy replaces the two streams of [§13.2][s13-2]."

### B61. CONFIRMED
- Status (log 6279): "superseded → [D-263][d-263]". Spec 6293 lists the bare
  "[§13][s13]"; Rationale 6304–6305: "both remedies in the message;
  [§13][s13])."

### B62. CONFIRMED
- Position (log 7710–7711): "the final boundary time, absent when no boundary
  ever ran". D-233 (9132–9134): "always present, … this amends
  [D-203][d-203]'s first field." D-203's annotations (7762, 7766, 7771) never
  name D-233.
- Rejected 7792–7794 and annotation 7771–7774 hold the `t_end` bound. Rejected
  7795–7797: "the interrupt sentence in [§13.5][s13-5] already ruled the
  appendix gains nothing here." D-260 Rejected (10565–10566): "so a stopped
  simulation answers from any task and at any later time."
- Spec (7734) lacks §13.2.

### B63. CONFIRMED
- Rationale (log 8733–8734): "the remedy for a condition that fails at `t₀` is
  a corrected condition, which needs the simulation re-initializable." The
  Position (8712–8724) does not say it.
- Chapter 562–563: "The remedy for a condition that fails at `t₀` is a
  corrected condition".

### B64. CONFIRMED
- Rationale (log 8805–8807): "for that throw the frame and the pointer are
  lost, and the lifecycle word does not move as it does on the framed path."
  Chapter 466–467 carries it (F30).
- Note: 8795–8799 does not spell `@test_throws StepError{ConformanceFailure}`.
  It gives the build idiom, "`@test_throws DiagnosticError{Kind}`", and says
  that under `cause::Any` "every species assertion spelled the two conjuncts
  the build side had just retired". The runtime spelling is the chapter's
  (462).

### B65. CONFIRMED
- Rationale (log 8968–8971): "Stratum A's other passes read only the
  component list, which the walk completes whatever the wiring did, so merging
  their lists into the barrier costs a returned vector and one throw."
- Chapter 55–56 bolds the Position's first sentence: "**Collection reaches the
  step barrier, under a dependency rule** ([D-229][d-229])."

### B66. CONFIRMED
- Rationale (log 9815–9816): "A declaration takes none, so the bundle-law
  diagnostic cannot arise inside it, but any other throw can." The Position
  (9795–9810) does not say it.

### B67. CONFIRMED
- Position bullet 1 (log 9922): "`Build` and `Deployment` carry `warnings`";
  bullet 5 names `attach!`; no `trim!`.
- Rationale 9945–9948: "`trim!` returns a `TrimReport` and duplicates its
  warnings into the report's fields because the report is where a caller
  looks". Rejected 9970–9972: "*Superseded position — service warnings as a
  third stream with no home:* … a `TrimReport` is an artifact".

### B68. CONFIRMED, and settled: D-255 is annotated
- Bullet 5 (log 10229–10233): "`t_end` and `stop_on` leave the constructor
  and are keywords of `run!` and `replay!`, with `Inf` and no faces as
  defaults, … A run with `Inf` and no faces is allowed and raises
  `UnboundedRun`".
- Annotation (10280–10283): "Annotation (2026-10-08): amended by
  [D-316][d-316]. `stop_on` is `ignore_stop_requests`, with `()` as its
  default, and `StopPolicy` is `t_end` plus the ignored requester paths.
  `UnboundedRun` fires when no requester is honoured." Survey 2 is right and
  survey 1 missed it. No annotation is owed for bullet 5.
- Spec (10242) lacks §13.2, and chapter 285, in §13.2, cites D-255. Only the
  Spec addition remains.

### B69. CONFIRMED
- Rationale (log 11101–11107): "The `Freeze` block is that page: at nominal
  `value` is the identity, so it costs one gather and one scatter; … A sampler
  is the other non-walking source, and it changes the model". The Position
  (11081–11094) holds neither.

### B70. CONFIRMED
- Position bullet 1 (log 13526): "`Constant{V}` declares `(out = Pinned{V},)`".
  Rationale 13541–13543: "A constant is never seeded, so it has zero partials
  under every activation, and the pinned form is strictly more connectable".
  Annotation 13568–13571: "A library block whose output depends on neither its
  continuous state nor a walking input … declares `(out = Pinned{V},)`".
- Note: the pin itself is in the Position. Only its reason and the
  generalization rest outside it.

### B71. CONFIRMED
- D-313 Rationale (log 13605–13607): "The guidelines say why those belong and
  a gain does not. A gain is domain-agnostic but teaches nothing and is one
  line of a stage body". D-062 Rejected (1994): "a language, not a toolbox."

### B72. CONFIRMED
- Rationale (log 13899–13902): "[§13.5][s13-5]'s observation-by-path rejection
  stands narrowed. The ignore list reads no arbitrary cell." 13907–13911: "An
  ignored request is still a cell in every snapshot, … the reason string is
  what tells a reader which". 13890: "control plane being the operator's
  path."
- Note: chapter 623–627, the operator-path sentence, cites D-310 only, not
  D-316. Chapter 837 and 865 cite D-316.

### B73. CONFIRMED
- D-349 Rationale (log 14768–14769): "Linear and cubic interpolation are
  immune to the blind spot, because dependence flows through the fractional
  weights."
- D-245 Rationale (9640–9651): "[D-012][d-012] states the verdict for a simple
  cycle", "a reader weighing the hint needs to know which". Chapter 1343–1353
  and 1369–1371 cite D-245.

### B74. CONFIRMED
- D-096 Rejected (log 3089): "*A public closure-evaluation API:*
  [§13.5][s13-5]'s rejected cost". D-390 (15690–15691): "the public
  closure-evaluation API whose cost [§13.5][s13-5] rejects."
- D-060 Rejected (1921–1922): "opaque, unserializable, a public snapshot API".
  Chapter 854–855 cites D-060 for the closures.

### B75. CONFIRMED
- Spec fields: D-383 (log 15430), D-384 (15514) and D-385 (15556) each list
  "[§13.7][s13-7]". Chapter 1004–1005 and 1013–1014 point to
  `companions/library_inventory.md`; `lqr_tracker.md` exists in the
  companions.

### B76. UNCONFIRMED in part
- `test/test_readers.jl` 279–280 cites §13.3, not D-125: "# Declaring the
  field's concrete type restores the deep read legally, with / # the
  hard-coding visible in the declaration itself (§13.3)." D-125 appears in the
  testset title (268) and at 287, where `get_face` is "D-125's own remedy".
- The requested check: D-125's Position (log 4075–4080) admits `get_face` to
  the service set. It does not state the concrete-type remedy, and neither
  does its Rationale or Rejected. The chapter states the remedy at 360–363,
  with D-083 and D-130 cited at 359–360. Under the proposal's own rule it goes
  to D-130.
- The rest matches survey 1's "Rulings with no entry at all" (986–998) row for
  row.

### B77. CONFIRMED
- `src/sim.jl` 241–243: "`_t_bound(t_end, call::Symbol) = (t_end isa Real &&
  t_end ≥ 0) ? Float64(t_end) : throw(DiagnosticError(ArgumentInvalid(…,
  reason = :range, argument = :t_end, …)))`". D-255 (log 10230): "validated
  per call".
- D-138 annotation (4820–4822): "the stop is pending at the run's first frame
  top, which the loop reads before any frame, so the run advances no frame".
  Survey 2 (1034–1039) lists the other rows.

### B78. UNCONFIRMED in part
- Two entries are wrong. D-218's Spec (log 8437) already lists §13.4:
  "[§11.5][s11-5], [§12.6][s12-6], [§12.7][s12-7], [§13.4][s13-4]". D-261 is
  no longer cited in §13.7. The new chapter cites it at 402 (§13.4) and 736
  (§13.5) only. Survey 2's §13.7 cite was old row 601, the `show(::Build)`
  feedthrough line that R4 moved to §9.2.
- Every other listed section is absent from its entry's Spec field: D-019
  (786), D-084 (2703), D-147 (5453), D-218 for §13.5, D-022 (880), D-261 for
  §13.4 (10649), D-274 (11883), D-294 (12905), D-389 (15672), D-401 (15943),
  D-251 (9992), D-254 (10165), D-224 (8757), D-394 (15783), D-398 (15884),
  D-406 (16108), D-407 (16174, which lists §11.2), D-231 (9048), D-364
  (14897), D-322 (14391) and D-387 (15622).
- The chapter cites each one in the named section, except D-224 and D-394,
  which it does not cite at all ("stated at rows 148, 151").

### B79. CONFIRMED
- D-097 annotation (log 3108): "Annotation (2026-10-15): amended by
  [D-228][d-228]." D-073 annotation at 2339 ("[D-311][d-311] makes the
  junction's type parameter the nominal type"). D-203 at 7771, D-274 at
  11918–11919 ("bullet's [§13.7][s13-7] reads [§14][s14]"), D-285 at 12474.
- D-091 Status: "superseded → [D-255][d-255]". D-316's Supersedes line
  (13867–13868): "[D-261][d-261]'s bullet making `StopPolicy` `t_end` and the
  stop faces … as the loop's argument". D-261 bullet (10637): "`StepError`'s
  time and boundary beside `NonfiniteState`'s payload stay as they are."
- Chapter 492 cites D-398 for the forced throw. 402 cites D-261 for the index.

## Carried

### B80. CONFIRMED
- Spec 9903–9904: "[§9.1][s9-1] and [§9.2][s9-2] already fixed when each check
  runs, so [§13][s13] fixes only how a failure is reported once it happens."
- Chapter 3–4: "how a failure is reported once it happens, and what the
  framework offers around it". Brief R1: "The Part IV roadmap (old 9891–9904)
  is not edited".

### B81. CONFIRMED
- Glossary 13856–13859: "**entry** — never used bare. The spec's compounds are
  table entry …, input entry, executor entry, roster entry, batch entry and
  condition entry". Chapter 353: "A wiring entry is carried by the declaring
  *type*".
- Note: §6.1 never writes "wiring entry". It says "An `input_wires` entry
  routes a face … An entry of any of the three is a wire" (spec 1536–1538).
  The new §13.2 has no "entry point"; the chapter's one use is §13.6's "two
  entry points" (896).

### B82. CONFIRMED
- Spec 12180–12181: "per the exceptions-are-broken-machinery line
  ([§13][s13])." Chapter 621: "**exceptions from model code are always
  abnormal** ([D-060][d-060])."

### B83. CONFIRMED
- Spec 11338–11339: "`set`/`at`/`combine` are [§13.7][s13-7] standard-library
  material, ordinary artifacts with no privileges."
- `src/conditions.jl` defines them (74 `set`, 92 `at`, 112 `combine`). Chapter
  1022: "The library is the submodule `Redstone.Blocks`"; 1033–1034: "**library
  blocks are ordinary components**, with no framework privileges".

### B84. CONFIRMED
- Spec 12350–12352: "a `product(p₁ => "lead", p₂ => "wing")` helper belongs in
  the [§13.7][s13-7] library." D-071 (log 2274) records it the same way.
  Chapter §13.7 names no helper.

### B85. CONFIRMED
- `companions/frame_walkthrough.md` 281–283: "`init!` and `replay!` run
  boundary zero through `_host_boundary_zero!`, which calls `boundary_zero!`
  under the catch that returns a throwing simulation to `built`".
- `rg _host_boundary_zero src/` finds nothing. The catch lives in the `Model`'s
  `init!` (`src/model.jl` 188–194: `try boundary_zero!(model) catch err;
  @atomic :release model.status = :built; …
  rethrow(_wrap_step(model, 0, :boundary_zero, err))`). `replay!`
  (`src/sim.jl` 920 on) restores a checkpoint and calls no `boundary_zero!`.
- Spec 9429–9431: "`restore!` and `replay!` are the two alternative doors.
  Each restores a checkpoint and runs no boundary zero".
- Note for the fixer: the walkthrough's `event_phase!(sim, ESTABLISH)` (284)
  is `event_phase!(model, ESTABLISH)` in the code (`src/model.jl` 329).

## Counts

CONFIRMED 59, UNCONFIRMED 4 (in part): B40, B41, B76, B78.

- B40: only `extensions.md` 346 has "§13.7's starting inventory". Spec 3326
  says "part of the starting inventory ([§13.7])", and log 7017 says
  "§13.7's inventory".
- B41: `implementation.md` 933 reads "global on `true` and local on `false`",
  not "local primal-carrying at sampled states".
- B76: `test_readers.jl` 279–280 cites §13.3, not D-125, and D-125 does not
  state the concrete-type remedy. The chapter cites D-083 and D-130 there.
- B78: D-218's Spec already lists §13.4. D-261 is no longer cited in the new
  §13.7.

Settled on request: B68, D-255 bullet 5 is annotated (log 10280–10283). B27,
spec 6531–6532 holds the execution-cursor gloss "loop-state field recording
where execution stands". §10.6 has no nonfinite phrase, so the brief's F20
line aims at the wrong sentence there.

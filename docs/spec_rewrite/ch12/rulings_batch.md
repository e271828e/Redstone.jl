# Chapter 12: rulings batch

Step 6 of `docs/spec_rewrite/recipe.md`. Items run B1 onward in four groups:
**Blocking** (B1–B21), **Landing** (B22–B40), **Track 2** (B41–B81) and **Carried** (B82–B88).

Conventions.
- Chapter lines are `chapter_new.md` lines as the step 5 passes gave them.
  The two editorial fixers may have moved them. Search by the quoted words.
- Spec and log lines are the frozen `scratch_survey/h1/` copies, which are
  byte-identical to `17ad42d`. "Old" lines are `17ad42d` spec lines.
- Sources are named by file and id: `P1-n`, `P2-n` (chapter passes), `IC1`,
  `IC2` (inbound checks, with the cited spec or log line), `A/B/F/G rulings`
  with the item's heading, `A/B/F/G verify`, `S1-E`, `S2-E` (survey part E,
  with its subsection).
- Settled by `brief.md` (R1–R20) and so left out: every item a unit's
  `rulings.md` marks as ruled or applied, and every verifier DRIFT that the
  re-check closed. The chapter pass's EDITORIAL findings go to the editorial
  fixers, not here. Where a RULING finding overlaps an EDITORIAL one, the
  item says so.
- Decision-log citation edits (a changed `[§x]` link in `decisions.md`) are
  in Landing. Annotations, new Positions and stale-text repairs are in
  Track 2.
- `escalations.md` holds E1 ("resumable by the next `run!`") and E2 (the
  parked GUI's guarantees). They are not items here. B13 and B16 and the
  Track 2 entries for D-132, D-027, D-093 and D-134 point at them.

## Blocking

The chapter cannot land as it stands: a wrong claim, a lost claim, a broken
pointer, or a bold that fails the style. The last items (B14–B21) change the
chapter text but need a ruling only on form or scope.

### B1. `step!` "never waits" contradicts its own section

- Sources: P1-1 and P2-41 (one finding seen from both halves).
- Lines: §12.1, chapter 90 (P2-41 says 91; the same sentence).
- Evidence: §12.1 says "`step!` takes neither and never waits". Lines 64–65
  of the same section say "`step!` shares the frame top and blocks the same
  way, until `resume!` or a stop from another task". §12.6 (line 895) keeps
  F79's scope, "it never waits on the pacer, whatever pace the control plane
  holds", and F79 says never to shorten it to "never waits". F79 named unit
  F's lines only, so §12.1 kept the unscoped form.
- Proposal: "`step!` takes neither and never waits on the pacer."
- Recommendation: apply. It is a wrong claim and F79 already rules the
  scope.

Status: ruled, apply the proposal. F79's scope holds in §12.1 too (lesson 19).

### B2. F17's grep missed one "frames skipped" (R10 F17)

- Sources: P1-2.
- Lines: §12.3, chapter 253.
- Evidence: F17 changed "skips frames" to "skips boundaries" at line 259,
  because the counter counts boundaries (D-081 Rejected, log 2579–2580). Six
  lines earlier the idiom still "handles … frames skipped while
  transmitting". R10 says to fix every instance.
- Proposal: "boundaries skipped while transmitting".
- Recommendation: apply.

Status: ruled, apply. R10's F17 covers every instance.

### B3. "Each `run!` … spawns its task" says every device gets a task

- Sources: P2-21.
- Lines: §12.6, chapter 1024–1025.
- Evidence: the sentence is "Each `run!` re-initializes every rostered
  device and spawns its task ([D-093][d-093])". Against it: §11.1 (spec
  6878–6880), "A device whose `init!` failed gets no task"; §12.4 (chapter
  541), the bracket "spawns no task for it"; this section's own pointer at
  1028. The old text had the sentence uncited. Unit F added D-093, whose
  Position reads "`run!` spawns one task per roster entry after per-run
  device `init!`" (log 2889–2891).
- Proposal: "Each `run!` re-initializes every rostered device and spawns a
  task for each whose `init!` succeeds ([§11.1][s11-1], [D-093][d-093])".
  The alternative stops after "re-initializes every rostered device" and
  lets the pointer at 1028 carry the rest.
- Recommendation: the first form. It keeps the claim and makes it true.

Status: ruled, apply the first form. D-093's Position spawns per roster entry after init!; §11.1 and D-138 exclude a failed init!.

### B4. `restore!(model, model_state)` never names its mismatch kind

- Sources: P2-20; IC2 (spec 12764, which already states the claim).
- Lines: §12.6, chapter 981–984.
- Evidence: the text names a kind only for the off-grid state
  (`CheckpointMidFrame`) and then says "Every mismatch of either kind",
  which has one named antecedent. `src/model.jl` 637 collects
  `CheckpointMismatch` and `CheckpointMidFrame`. D-319 bullet 2 (log
  14008–14015): "checks the fingerprint and the grid … collects every
  mismatch … into one throw before any write". Appendix B (spec 12764)
  states both kinds.
- Proposal: "checks the state's fingerprint and deployment against the
  model, and a mismatch is `CheckpointMismatch`."
- Recommendation: apply. It adds one claim, but D-319 and the code carry it,
  and L4 (Appendix B's `restore!` row) depends on it.

Status: ruled, apply. `src/model.jl` and D-319 bullet 2 carry `CheckpointMismatch`; the sentence then names both kinds its "either kind" refers to.

### B5. D-255 bullet 4 is bold in §12.1 and §12.6

- Sources: P1-4; A rulings, "Bold on the same entry elsewhere".
- Lines: §12.1, chapter 53–55 ("`ControlRequestedStop` sits outside the
  stop policy"); §12.6, chapter 1034 ("The stop policy is declared per
  advance").
- Evidence: both come from D-255 bullet 4. Under the sentences reading they
  are two rulings. Under the bullets reading, which the one-bold test uses,
  they are one ruling bold twice. §13.5 (spec 10414, 10425) also bolds
  D-255 clauses. F's rulings say the §12.6 bold also rests on D-316 bullet 6
  and D-260 bullet 3, so it is a different ruling from bullet 4's.
- Proposal: rule the reading. If bullets, keep §12.6's bold, where the
  advance's policy is described, and make §12.1's plain with its citation.
- Recommendation: rule that §12.6's bold stands on D-316 bullet 6 and D-260
  bullet 3 (two rulings, not bullet 4), so both bolds stay. If the owner
  prefers the bullets reading, apply the proposal.

Status: ruled, both bolds stay. Checked D-255: §12.1's clause is bullet 4's second sentence ("`ControlRequestedStop` is outside the policy"); §12.6's per-advance keywords are bullet 5 with D-316. Two bullets, two rulings.

### B6. D-114's bold does not state the order

- Sources: P1-3.
- Lines: §12.3, chapter 230–233.
- Evidence: the bold "The order of the two publications is normative" says
  only that an order is ruled. The order is in the next, plain sentence.
  `spec_style.md` bolds the headline clause. D-114 Position: "publication
  order is normative: the release-store of `latest` happens before the
  counter increment under the lock".
- Proposal: make the first sentence plain, and bold "**The release-store of
  [`latest`](#g-latest) (gloss) ([§11.2][s11-2]) happens before the counter
  increment under the lock**" with `([D-114][d-114])` at that sentence's
  end. P1-20 suggests moving the §11.2 citation to the clause's end.
- Recommendation: apply.

Status: ruled, apply.

### B7. The D-218 bold covers the whole sentence

- Sources: P2-27.
- Lines: §12.7, chapter 1110–1112.
- Evidence: the bold spans 23 words. Its headline clause is "the mode
  decides which source that one drain branch reads". The first half (a
  simulation carries an input mode, read as `mode(sim)`) is stated plain in
  §12.6 at 865–870 with a D-218 citation. D-218 Position (log 8273–8275).
- Proposal: bold only "**the mode decides which source that one drain
  branch reads**".
- Recommendation: apply.

Status: ruled, apply.

### B8. The `to_time` bold has no subject

- Sources: P2-32.
- Lines: §12.7, chapter 1157.
- Evidence: the bold's subject "The keyword" depends on the sentence before
  it, so the headline clause does not name what it rules on (D-219 bullet 1,
  log 8321–8323).
- Proposal: "**`to_time` halts at the last frame top at or before the time
  given**, the same halt addressed by time, and it is mutually exclusive
  with `to_boundary` ([D-219][d-219])." The topic sentence before it goes.
- Recommendation: apply. The topic sentence repeats the subject and carries no other claim.

Status: ruled, apply.

### B9. A sentence now compares the pointer with itself

- Sources: P2-29.
- Lines: §12.7, chapter 1142.
- Evidence: "The frame-entry pointer ([§13.4][s13-4]) lands the same way"
  once contrasted the published-boundary `k` with §13.4's pointer. After F83
  and R17, `to_boundary` takes the frame-entry index itself (1137). The name
  "frame-entry pointer" appears nowhere else. Line 1130 and §13.4 say
  "replay pointer".
- Proposal: delete the sentence. It removes a claim that no longer says
  anything.
- Recommendation: apply, and log the removal as a consequence of F83 and R17
  in the unit's deleted list.

Status: ruled, apply: delete, logged in units/G/deleted.md as a consequence of F83 and R17.

### B10. "`errored` is terminal" is bold in §12.6 and §14

- Sources: P2-14; F rulings, "Bold on the same entry elsewhere".
- Lines: §12.6, chapter 861; spec 11031 (§14).
- Evidence: D-059 bullet 4 (with D-108). §14 bolds "`errored` is terminal
  for every row"; §12.6 bolds "`errored` is terminal". One ruling, bold in
  two places. §12.6 is the lifecycle's home.
- Proposal: keep §12.6's bold. Chapter 14's rewrite makes its sentence
  plain (see B84).
- Recommendation: apply the proposal.

Status: ruled, apply: §12.6 keeps the bold; carried to chapter 14 (B84).

### B11. R2 stopped at units A and B: §12.5 still has the live GUI

- Sources: P2-4.
- Lines: §12.5, chapter 702–703 (667 is FlightCore history and stays).
- Evidence: §12.5 says the survey "renders the corresponding GUI widgets
  read-only" in the present tense. D-310 parked the GUI. Frozen §11.7 says
  the same, so this could wait for chapter 11.
- Proposal: extend R2 to 702–703: "a front end's widgets", with a D-310
  citation once, as R2 does per section.
- Recommendation: apply. §12.5 is this chapter's and the wording is R2's.
  B85 carries §11.7.

Status: ruled, apply. D-310 keeps §11.7's semantics, so the widgets become a front end's.

### B12. "Deviceless, `run!` is fully synchronous, and §11.1 says …" joins two claims

- Sources: P2-15.
- Lines: §12.6, chapter 887–890.
- Evidence: one sentence joins an unrelated pair with "and" and opens
  "Partial advance" with a claim about `run!`. R5 dictated one sentence and
  asked to keep "Deviceless, `run!` is fully synchronous" (D-268 cites
  §12.6 for it; log 11153–11154).
- Proposal: two sentences. "Deviceless, `run!` is fully synchronous.
  [§11.1][s11-1] says where the loop and the device tasks run, and defines
  the unattended run (gloss)."
- Recommendation: apply. R5 asks for the pointer, not for the single
  sentence as a form. Rule this reading.

Status: ruled, apply the two sentences. R5 dictated the pointer, not the one-sentence form.

### B13. §12.4's "resumable by the next `run!`" pointers land on the opposite

- Sources: P2-19; IC2 rows for chapter 12; unit B rulings (R7).
- Lines: §12.4, chapter 534 and 556; target §12.6, 961–962.
- Evidence: the pointer's target says "From `stopped`, nothing advances
  until `init!`, `restore!` or `replay!` opens a new run". It is E1,
  already escalated.
- Proposal: none here. Listed because the pointer check finds it.
- Recommendation: leave to E1. Note it so that whichever way the owner
  rules E1, these two sentences and D-132's Position change together.

Status: ruled, no edit now: follows E1.

### B14. R19's comment makes a code line 131 columns wide

- Sources: P1-8.
- Lines: §12.4 init bracket sketch, chapter 461.
- Evidence: the `report!` line is 131 columns after R19. The old line was
  95, and the rest of the block stays within 87. Comments change only by
  ruling.
- Proposal: put the comment on its own line above the call:
  `# pre-spawn: the entry is the address, no task holds a handle yet`
  then `report!(entry, DeviceCrash(e, entry.should_abort))`.
- Recommendation: apply. R19's wording is unchanged, only its place.

Status: ruled, apply. R19's words unchanged; the comment moves above the call.

### B15. The join cap's home is stated three times in half 1

- Sources: P1-5.
- Lines: §12.4 step (5), chapter 337–338; §12.4, 419–420; §12.1, 98;
  §12.6, 814.
- Evidence: step (5): "The cap lives on `Control`, the tail's own owner
  ([§12.1][s12-1], [D-256][d-256])". Lines 419–420, dictated by F6: "The
  cap therefore lives on `Control`, not on the `Deployment`
  ([D-256][d-256])". §12.1 bolds it. §12.6 points at §12.1.
- Proposal: in step (5) drop the sentence and fold the pointer into the
  next: "It is a keyword of the `Simulation` constructor, held on `Control`
  ([§12.1][s12-1]), a positive real …". Keep 419–420 as F6 dictated.
- Recommendation: apply.

Status: ruled, apply.

### B16. Two links without a gloss inside the frozen E2 text

- Sources: P1-7; A rulings, R2 first bullet.
- Lines: §12.2, chapter 158 (old 8711–8716); also 163.
- Evidence: the `snapshot` and `staging cell` links are the section's first
  uses and have no gloss. R2 freezes these lines to a rewrap. E2 is open.
- Proposal: either let the glosses in, or move the links to the next uses
  outside the frozen lines. Line 163 "stale snapshots" can take the snapshot
  link with its gloss. The staging cell has no later use in §12.2.
- Recommendation: leave both as written until E2 rules, then gloss with the
  text E2 produces. Take the snapshot link to line 163 now.

Status: ruled, apply the recommendation: the frozen lines stay until E2; the snapshot link moves to line 163 with its gloss; the staging-cell link stays.

### B17. The issuers are listed in §12.1 and again in step (1)

- Sources: P1-9.
- Lines: §12.4 step (1), chapter 313–315; §12.1, 34–37.
- Evidence: "The control-plane stop's issuers are a front end
  ([D-310][d-310]), a device handle, code, or an operator interrupt"
  repeats §12.1. The old text had both and R2 edited both.
- Proposal: "The control-plane stop's issuers are those of [§12.1][s12-1], an
  operator interrupt among them (Ctrl-C, treated below)."
- Recommendation: leave. Low priority, and the D-310 citation at the point
  of use is worth the repeat.

Status: ruled, leave as written.

### B18. The three indices are stated in both halves

- Sources: P1-10; G rulings, item 1 (R17).
- Lines: §12.3, chapter 270–282; §12.7, 1145–1147.
- Evidence: R17's sentence restates §12.3's paragraph and cites only §10.4.
- Proposal: add `[§12.3][s12-3]` beside `[§10.4][s10-4]` at 1147.
- Recommendation: apply.

Status: ruled, apply.

### B19. "Deployment contexts" next to "not on the `Deployment`"

- Sources: B rulings, correction 2; P1-22 (the first half; its "unattended
  sweep" half is EDITORIAL).
- Lines: §12.4, chapter 412.
- Evidence: "Deployment contexts legitimately differ in patience" sits two
  sentences before F6's "not on the `Deployment`", the glossary artifact.
  At a sentence start the capital reads as the type. D-198 Rationale's
  "Deployment contexts" is the source.
- Proposal: "Usage contexts legitimately differ in patience." Track 2 may
  note the same in D-198.
- Recommendation: apply.

Status: ruled, apply "Usage contexts".

### B20. "A few scalar fields" is loose

- Sources: A rulings, corrections proposed, first bullet.
- Lines: §12.1 (old 8597–8598), chapter near 22–25.
- Evidence: `Control` also holds a `Threads.Condition` and the boundary
  counter (`src/control.jl` 62–72). The sentence lists pause, un-pause, pace,
  `margin` and stop, which are scalar, so the claim is about those fields.
- Proposal: "are a few fields on that separate atomic surface".
- Recommendation: apply. The change removes a word only. If the owner
  wants the old text kept, no action.

Status: ruled, apply.

### B21. `disable_sigint` is a description, not a bug

- Sources: B rulings, correction 3.
- Lines: §12.4, chapter near 570–580 (old 9103).
- Evidence: the code calls `Base.sigatomic_begin` and `sigatomic_end`
  directly (`src/sim.jl` 1189, 1427), the counter `disable_sigint` wraps.
  The sentence holds as a description of the mechanism.
- Proposal: none. Recorded so that no later pass "fixes" it.
- Recommendation: no change.

Status: ruled, no change.

## Landing

Edits outside the chapter that land with it: inbound citations, Appendix B
and C, the glossary, `implementation.md` and the log's citation links. Every
row below was wrong or stale against the new chapter. Only B22 comes from
the rewrite itself; IC2 says the five MISSING rows were wrong before it.
Spec and log lines are the frozen copies.

### B22. Appendix B: "dead from boundary zero" (R8)

- Sources: IC1 row 74; B rulings, "Inbound citations affected".
- Lines: spec 12855 (Appendix B); the log side is B60.
- Evidence: old §12.4 said a failed device is "dead from boundary zero".
  R8 corrected it to "dead from the run's first frame top" (chapter 500–501)
  because a run need not start at boundary zero.
- Proposal: "and the device is dead from the run's first frame top
  ([§12.4][s12-4])."
- Recommendation: apply. The old wording holds for a run that starts at
  boundary zero, so this is a precision fix.

Status: ruled, apply at landing (CONFIRMED by the evidence check).

### B23. §11.5 cites §12.6 for a claim §12.6 never made

- Sources: IC2, MISSING, spec 7716.
- Lines: spec 7716 (§11.5, D-274's bold).
- Evidence: the sentence says `init!` takes the header at the end of
  boundary zero and cites "[§12.6][s12-6], [D-274][d-274]". §12.6 never said
  it. §12.7 (chapter 1329–1330) says only that the checkpoint holds the state
  after boundary zero. It was wrong before the rewrite.
- Proposal: "first snapshot is published ([D-274][d-274])." Drop §12.6.
- Recommendation: apply. D-274 carries the claim.

Status: ruled, apply at landing (CONFIRMED by the evidence check).

### B24. "Cleared" recorders: §12.6 builds new objects

- Sources: IC2, MISSING, spec 11949 (§14.8), spec 12913 (Appendix B,
  `trim!`), spec 14370 (glossary, recorders); S2-E, F73.
- Lines: as listed.
- Evidence: §12.6 (chapter 951–956) makes the trace, the log and the
  termination record new objects, not cleared ones, and clears the staged
  batches. D-255 bullet 2 (log 10047–10048): "`init!` allocates fresh
  objects rather than clearing".
- Proposal, 11949: "The [recorders](#g-recorders) restart exactly as
  [§12.6][s12-6] states for `init!`. The [trace](#g-trace) and the log are
  new objects, and any [batches](#g-batch) still in [staging
  cells](#g-staging-cell) (gloss) are cleared."
  12913: "anchored at `t0` and the recorders built anew ([§12.6][s12-6])."
  14370: "`init!`, `restore!` and a trim commit build them anew together, so
  they restart with the run they record ([§12.6][s12-6], [§14.8][s14-8])."
- Recommendation: apply all three. They are one problem. Chapter 14's
  rewrite owns 11949 if the citing sentence is rewritten there first (see
  B84).

Status: ruled, apply at landing (CONFIRMED by the evidence check).

### B25. Appendix B's `restore!(model, …)` row

- Sources: IC2, MISSING, spec 12764.
- Lines: spec 12764.
- Evidence: §12.6 never said the model's `restore!` takes no status gate;
  D-319 bullet 2 says it. R12 also asks for "fingerprint and deployment".
  B4 makes §12.6 name the kind.
- Proposal: "Checks the state's fingerprint and deployment
  (`CheckpointMismatch`) and its `t` against its grid (`CheckpointMidFrame`)
  before any write ([§12.6][s12-6]). Copies the state back, settles through
  the hooks and writes `:consistent` last. It takes no status gate
  ([D-319][d-319]). A writing door."
- Recommendation: apply, after B4 and B29 (the last sentence, "A writing
  door", is B29's).

Status: ruled, apply at landing (CONFIRMED by the evidence check).

### B26. The harness cell and writer moved to §11.3

- Sources: IC2, RETARGET: spec 12998 (Appendix B, `stage!`), spec 14220
  (glossary, harness cell), spec 14226 (glossary, harness writer),
  `inbound_periphery_walkthrough` line 5 and line 197.
- Lines: as listed.
- Evidence: "surface-checked" and "any task" left §12.6 (R5, C-137). §11.3
  7263–7271 says the harness cell is "drained, traced and surface-checked
  exactly as any device's" and defines the harness writer and the derived
  surface. §12.6 keeps "ordinary" and "traced" (chapter 918–919). 12998 also
  says "the GUI's writes", which predates D-310.
- Proposal:
  - 12998: "and surface-checked exactly as any device's (the harness cell,
    [§11.3][s11-3]). It is legal under `run!` and `step!` alike
    ([§12.6][s12-6])."
  - 14220: "convention ([§11.3][s11-3], [§12.6][s12-6])."
  - 14226: "`ClaimedFaceEntry` ([§11.3][s11-3])."
  - walkthrough 5: move "(harness cell)" into the §11.3 item and drop the
    §12.6 item.
  - walkthrough 197: "([§11.3][s11-3]). This is the design's one
    **derived** surface …".
- Recommendation: apply all five. Each cites §11.3 for a clause only §11.3
  states.

Status: ruled, apply at landing (CONFIRMED by the evidence check).

### B27. R12: the fingerprint and the deployment in citing text

- Sources: IC2, OK-with-sync rows: spec 11018 (§14 table), 12931, 12939,
  12945 (Appendix B), 13393 (Appendix C, both `CheckpointMismatch` rows).
- Lines: as listed.
- Evidence: R12 names the fingerprint as the structural layout and the
  deployment beside it. The citing sentences name the fingerprint alone.
  Appendix C 13393's payload already lists the deployment arm.
- Proposal:
  - 11018: "a checkpoint whose fingerprint and deployment match the
    simulation's".
  - 12931: "`t` and `t₀`, the fingerprint and the deployment."
  - 12939: "It checks the checkpoint's fingerprint and deployment
    (`CheckpointMismatch`)".
  - 12945: "the same fingerprint and deployment check".
  - 13393: "raised when a checkpoint's fingerprint or deployment disagrees
    with the target simulation or model".
- Recommendation: apply. The old wording is not false but is narrower than
  §12.6 and §11.5.

Status: ruled, apply at landing (CONFIRMED by the evidence check).

### B28. The glossary's *replay* entry disagrees with the default-form scope

- Sources: IC2, spec 14376; G rulings, "Inbound citations affected"; S2-E,
  F51, F57.
- Lines: spec 14372–14376.
- Evidence: the entry says replay validates "the checkpoint's fingerprint
  (stores, root-input faces and the `Deployment`)" and restores the clock
  "with the rest of the state", unscoped. R12 names the fingerprint as the
  structural layout. F57 scopes the clock restore to the default form.
- Proposal: "the drain reads the trace by frame ordinal, after the trace's
  checkpoint is restored under the default form. It re-records, ends
  `initialized`, and validates the checkpoint's fingerprint (the structural
  layout) and its `Deployment` up front. The default form restores the clock
  with the rest of the state".
- Recommendation: apply.

Status: ruled, apply at landing (CONFIRMED by the evidence check).

### B29. R14: "door" across Appendix B, §9.2 and the glossary

- Sources: IC2, notes; spec 14073 (glossary, `Model`).
- Lines: spec 12735–12767 (Appendix B: "`Model`'s own doors", "A writing
  door"), spec 4336 ("its doors"), spec 14073 ("Its doors are listed").
- Evidence: R14 defines *door* in §12.6 as an entry point that builds a run
  and turns every `Model` "door" into "entry point". Appendix B and 4336 still
  use the old sense. Only 14073 cites §12.6.
- Proposal: 14073: "Its entry points are listed". For the rest, rule one
  sense of *door* across the spec. Option (a): the spec-wide sense is R14's;
  change 4336 and Appendix B's `Model` rows to "entry point" and "writing
  entry point". Option (b): leave Appendix B and 4336 until the appendices'
  rewrite.
- Recommendation: (a) for 14073 and 4336, which cite or sit near the
  chapter; (b) for Appendix B's rows, which are the appendix rewrite's. Rule
  the sense now so that rewrite has a rule.

Status: ruled, the recommendation: *door* means an entry point that builds a run (R14). At landing, 14073 becomes "Its entry points are listed" and 4336's "doors" becomes "entry points". Appendix B's `Model` rows are carried to the appendix rewrite with this rule.

### B30. Appendix B: the halt range keywords (F68)

- Sources: IC2, spec 13037.
- Lines: spec 13037 (Appendix B, `replay!`).
- Evidence: "A halt names a frame at or after the one the feed starts from."
  F68 now reads: a frame from the one the feed starts from through the
  recording's last.
- Proposal: "A halt names a frame from the one the feed starts from through
  the recording's last."
- Recommendation: apply.

Status: ruled, apply at landing (CONFIRMED by the evidence check).

### B31. Appendix C: kinds the chapter now names

- Sources: IC2, spec 13301 (`MissingInit`), 13428 (`ArgumentInvalid`);
  G rulings, corrections proposed, item 3 (also 13303 `ServiceLifecycle`);
  S2-E ("Spec fields lacking a half-2 section").
- Lines: spec 13301, 13303, 13428.
- Evidence: §12.7 names `MissingInit` for `live!` (chapter 1191) and for
  `replay!(…; restore = false)` (1338), `ServiceLifecycle` for the same gate
  and `live!`, and `ArgumentInvalid` for the halt keywords (1135) and `live!`
  on `:live` (1193). The rows omit §12.7 and `live!`.
- Proposal:
  - 13301: "**`MissingInit`** ([§12.6][s12-6], [§12.7][s12-7]). … the entry
    point called (`run!`/`step!`/`replay!`/`live!`)."
  - 13303: add `live!` to the call list and cite §12.7.
  - 13428: add `[§12.7][s12-7]` after `[§12.6][s12-6]` and `live!` after
    `replay!`.
- Recommendation: apply.

Status: ruled, apply at landing (CONFIRMED by the evidence check).

### B32. Spec 6893 (§11.1): "staging fed from a recording"

- Sources: IC2, notes; pre-existing.
- Lines: spec 6893.
- Evidence: "the same loop with staging fed from a recording" contradicts
  §12.7, where the drain reads the trace and no staging cell is swapped
  (chapter 1095–1099).
- Proposal: "the same loop with its drain fed from a recording".
- Recommendation: apply. The error predates the rewrite but the chapter now
  states the right form beside it.

Status: ruled, apply at landing (CONFIRMED by the evidence check).

### B33. `implementation.md`: three pointers

- Sources: IC1 rows 224 and 233; IC2, notes.
- Lines: `implementation.md` 762, 807, 1260.
- Evidence:
  - 762: "its model a `Model{Float64}` by type (§12.1, D-256, D-317)". The
    four-field `Simulation` is §12.6's (chapter 798).
  - 807: files `to_time` under §12.6. It is §12.7's.
  - 1260: "A deviceless loop never yields (§12.2)". §12.2 has never said
    that. It guarantees a per-frame yield only with devices attached
    (chapter 133). A paced deviceless loop yields in its coarse `sleep`
    (`src/control.jl` 186); `yield()` at `src/sim.jl` 1424 runs only with a
    non-empty roster.
- Proposal: 762 "(§12.6, D-256, D-317)". 807 "§12.7". 1260: "§12.2
  guarantees a per-frame yield only with devices attached, and an unpaced
  deviceless loop never yields, so a test that spawns an advance and waits
  on it from its …".
- Recommendation: apply all three. 1260 was wrong before the rewrite.

Status: ruled, apply 762 and 1260 as proposed; 807 becomes "§12.6 and §12.7", since `mode(sim)` is §12.6's (evidence check UNCONFIRMED the proposal's "§12.7" alone).

### B34. The glossary's *control plane* entry omits the sticky stopped status

- Sources: A rulings, corrections proposed, last bullet; IC1, OK-with-problem
  row 89.
- Lines: spec 14173–14177.
- Evidence: §12.1's `Control` field list now includes the sticky stopped
  status (F7).
- Proposal: add "the sticky stopped status" to the entry's field list.
- Recommendation: apply.

Status: ruled, apply at landing (CONFIRMED by the evidence check).

### B35. Unmask points omit the pause block

- Sources: IC1, rows 54 and 91; B rulings, last inbound bullet.
- Lines: spec 10239 (§13.4), 14240 and 14243 (glossary, operator interrupt).
- Evidence: the citing text says "a frame-top or wait unmask point". §12.4
  also names the pause block (chapter 589–590). Minor.
- Proposal: "a frame-top, wait or pause-block unmask point" in the three
  places.
- Recommendation: apply to 14240 and 14243 (glossary). For 10239 the
  chapter 13 rewrite owns the sentence: see B83.

Status: ruled, apply to the glossary's 14240 and 14243 at landing; 10239 is carried to chapter 13 (B83).

### B36. Log citation links: D-133 and D-109

- Sources: IC1 rows 122, 135, 138; IC2, decisions 3494.
- Lines: log 4316 (D-133 Position), log 4321 (D-133 Spec field), log 3492
  (D-109 Annotation), log 3494 (D-109 Annotation).
- Evidence:
  - 4316 and 4321: the landing rule is in the paragraph after the chart
    (chapter 380–388), not in step (1). It was so in the old text. The Spec
    field lists plain §12.4 already.
  - 3492: R5 removed §12.4's topology bold. §11.1 is the home. The entry is
    superseded, so optional.
  - 3494: R5 cut §12.6's "Task topology follows the roster each time" to a
    pointer, so "[§12.6]" no longer holds the "roster-derived" shorthand.
- Proposal:
  - 4316: "stated once in [§12.4][s12-4]:". 4321: drop `[§12.4][s12-4](1)`.
  - 3492: "[§11.1][s11-1] carries the canonical statement".
  - 3494: "([D-093][d-093]) stands as shorthand for it."
- Recommendation: apply 4316, 4321 and 3494. Apply 3492 if D-109's entry is
  touched anyway; else leave.

Status: ruled, apply 4316, 4321 and 3494 at landing; 3492 stays, since D-109 is superseded and its entry is not otherwise touched.

### B37. D-268 Rationale: "§12.6 defines the unattended run as the deviceless one"

- Sources: IC2, decisions 11153.
- Lines: log 11153.
- Evidence: R5 cut §12.6's "An unattended run is the same loop with empty
  staging" to a pointer. §11.1 (spec 6890–6891) defines the unattended run
  as "empty staging and no snapshot readers", not as "the deviceless one".
  §12.6 keeps "Deviceless, `run!` is fully synchronous" (chapter 887).
- Proposal: "[§11.1][s11-1] defines the unattended run, which a deviceless
  run is, and [§13.4][s13-4]'s rethrow presupposes it."
- Recommendation: apply. IC2 asks the orchestrator to rule whether the
  citation swap alone is enough. The swap alone leaves a claim ("defines it
  as the deviceless one") that §11.1 does not make, so the clause is needed.

Status: ruled, apply with narrower wording: "[§11.1][s11-1] defines the unattended run, and [§12.6][s12-6] states that a deviceless `run!` is fully synchronous". The proposal's "which a deviceless run is" claims more than §11.1 says, since a harness may stage into a deviceless run.

### B38. `[d-127]` has no link definition

- Sources: G rulings, citations added.
- Lines: spec 14622 on (link definitions).
- Evidence: the unit cites D-127 and cannot edit the block. `linkify.jl`
  regenerates it at landing (recipe step 6).
- Proposal: run `linkify.jl`. If `[d-127]` is still absent, add
  `[d-127]: decisions.md#d-127--add-a-deployment-block-to-the-trace-header-for-replay-validation`.
- Recommendation: apply.

Status: ruled, apply at landing (CONFIRMED by the evidence check).

### B39. Two pre-existing wrong pointers to §12.6 and §12.7

- Sources: IC2, notes, "Pre-existing, outside the listed claims".
- Lines: spec 11002, 11061, 12931 ("A checkpoint is not a condition and has
  no algebra"); spec 7087, log (D-137 Spec field, D-198 Position).
- Evidence: the first was never §12.6's; D-273 and D-274, cited beside it,
  rule it. The second cites §12.7 for replay ignoring `log_max` and
  `join_timeout`; §12.7 never names them. The exclusion is implicit, in the
  compared `Deployment`. §12.4 now states it (F6, chapter 419–424).
- Proposal: drop the §12.6 citation from the three checkpoint sentences,
  leaving D-273 and D-274. For the second, retarget to §12.4 or add the
  §12.4 citation.
- Recommendation: apply. Both were wrong before the rewrite. The 7087
  retarget needs the evidence check to open §12.4's sentence.

Status: ruled, apply at landing (CONFIRMED by the evidence check).

### B40. Rows wrong before the rewrite, no edit proposed

- Sources: IC1 rows 121 and 158.
- Lines: log 3482 (D-109 Rationale), log 6530 (D-175 Position).
- Evidence: "The affine device is outside §12.4's join and abandonment" and
  "The detach sitting in §12.4's shutdown tail" were already untrue at
  `17ad42d`. D-310 removed the calling-task device. Both entries are
  superseded by D-310, so the Rationale is historical.
- Proposal: none. The status line is enough.
- Recommendation: no edit.

Status: ruled, no edit.

## Track 2

Log repairs, annotations, entries owing a Position, and glossary work that
waits for track 2. One item per D-entry, so an entry's stale text, its
annotations and its owed Position sit together. Every log line is a line of
the frozen `decisions.md`. `decisions_style.md` rule 10 repairs an older entry
by annotation, and its rules for Positions govern the "owes a Position" parts.
The recommendation for the "owes a Position" part is the same throughout: the
chapter's citation stands on the Rationale or Rejected text, so write the
Position the spec already relies on. Where a bold in the chapter rests on
Rationale text alone, the item says so.

Source key: S1-E and S2-E are survey 1 and survey 2 part E. Subsections:
"cite" (entries to cite at the rule), "super" (superseded citations), "owes"
(rulings needing a Position, by number), "none" (rulings with no entry),
"stale" (stale entry text and Spec fields).

### B41. Spec fields only: D-021, D-022, D-045, D-060, D-108, D-200, D-228, D-366, D-372, D-373, D-374, D-381

- Sources: S1-E stale ("Spec fields"), S1 part D, S2 part D, S2-E stale.
- Evidence: these entries rule chapter 12 sentences their Spec fields do not
  list.
  - D-021: lacks §12.1 and §12.2.
  - D-022: lacks §12.1 and §12.3.
  - D-045: lacks §12.5 (rules old 9220).
  - D-060: lacks §12.4 and §12.5 (old 9238–9239).
  - D-108: lacks §12.6 and §12.7, where `checkpoint`'s and `live!`'s gates
    are stated. It is the only entry naming `MissingInit`, in its Rejected
    list (log 3453).
  - D-200: lacks §12.6 (rules "from any task", old 9374).
  - D-228: lacks §12.4.
  - D-366, D-372, D-373, D-374, D-381: each lists §11.6 or §11.3 alone and
    rules a §12.4 sentence. D-374 also rules a §12.2 sentence.
- Proposal: add the listed section to each Spec field. D-368 and D-369 need
  nothing while the chapter's rows 126 and 124 stay pointers.
- Recommendation: apply.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B42. D-027

- Sources: S1-E super, stale, owes 14; A rulings, Rationale-only; E2.
- Lines: Rejected log 993–994 ("GUI on the calling task"); 990–995.
- Evidence: D-310 bullet 1 withdrew the ground, with no annotation. The
  spin never yields and the freeze needs a monopolist (Rejected 993–995),
  and the wait slot `sleep` buys (990–992), rest on the Rejected text; the
  chapter's three D-027 bolds rest on the Position.
- Proposal: annotate the Rejected list with D-310 (E2). Write a Position
  clause for "the spin never yields; the scheduler stall needs a monopolist".
- Recommendation: annotation as E2 rules; Position clause yes.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B43. D-030

- Sources: S1-E stale, cite; B rulings, citations.
- Lines: Position log 1040–1043.
- Evidence: "device crash = `should_close` path"; `should_close` dissolved
  (D-373). The entry has no **Spec.** field, and rules §12.4's tail (cited
  nowhere in the spec before this chapter).
- Proposal: annotate D-030 that a device crash enters the tail through the
  abnormal path (D-138, D-373). Add a Spec field listing §12.4 and §13.6.
- Recommendation: apply.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B44. D-031

- Sources: S2-E stale, none, owes 16; F rulings, citations.
- Lines: Position log 1060 ("manual events = slot + guard", "shape on
  record"); Rejected 1069–1071; D-106 Rationale 3364–3365 (the doctrine's
  final form).
- Evidence: "slot" is root input in D-206's vocabulary. "Shape on record"
  records no shape: the mid-run intervention command's shape has no entry.
- Proposal: annotate "slot" as root input. Either add the missing shape or
  strike "on record".
- Recommendation: annotation yes; rule the shape question with the owner.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B45. D-059

- Sources: S2-E owes 14; F rulings.
- Lines: Rejected log 1851–1852 ("reproduction is trace replay, not
  resurrection").
- Evidence: §12.6 cites it by adjacency; bullet 4 is bold in §12.6 and §14
  (B10).
- Proposal: state the rule in the Position.
- Recommendation: apply.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B46. D-081

- Sources: S1-E owes 11.
- Lines: Rejected log 2579–2580.
- Evidence: "the counter counts boundaries, not frames" (§12.3) rests on
  this Rejected text.
- Proposal: state it in the Position.
- Recommendation: apply.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B47. D-088

- Sources: S2-E stale, owes 1 and 15; F rulings.
- Lines: Position log 2778; Rationale 2782–2791; Rejected 2794–2795.
- Evidence: the Position says `UninitializedSlots`, now
  `UninitializedInputs`. The Rationale says "trace *and* log cleared at
  `init!`" (fresh objects since D-255, B24), "`t_end`/`stop_on`" (D-316) and
  "re-bindable per run at `run!` (D-091)" (superseded). It holds `step!`'s
  contract (synchronous whole-frame advance, `initialized` between calls,
  the `stopped → init! → run!` re-run, attachments persisting), and
  §12.6 bolds two of these (the re-run, attachment persistence) on it. The
  Position states only the five states and the mandatory `init!`. Rejected
  2794–2795: harness and REPL modes are not scripts.
- Proposal: annotate the three stale terms. Move `step!`'s contract and the
  re-run into the Position.
- Recommendation: apply. Without the Position, two chapter bolds rest on
  Rationale text.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B48. D-093

- Sources: S1-E stale, owes 6; S2-E owes 3; A, F rulings; E2.
- Lines: Rejected log 2929–2930; Rationale 2897–2901, 2908–2910.
- Evidence: the pinned-GUI rejection rests on "§12.2's
  cannot-fail-to-be-scheduled argument"; the annotation of 2026-10-13 covers
  the Rationale only. The Rationale holds what survives a stop, the
  unplug-while-stopped path and "stepping sessions are deviceless by
  construction", which §12.6 bolds.
- Proposal: annotate the Rejected text with E2's outcome. Write a Position
  for the run-scoped observables and the deviceless stepping session.
- Recommendation: apply, after E2.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B49. D-096

- Sources: S2-E owes 2 and 15; F rulings.
- Lines: Rationale log 3015–3020; Rejected 3036–3037.
- Evidence: `latest(sim)` and the advance-assert idiom (§12.6 cites it) and
  "an inspection accessor returning the immutable snapshot is not it" rest
  on the Rationale and Rejected text. D-096 is otherwise cited nowhere in the
  chapter before this rewrite.
- Proposal: state the `t_plus` spelling and `latest(sim)` as the read half
  in the Position.
- Recommendation: apply.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B50. D-097

- Sources: S1-E stale.
- Lines: Position log 3043–3046.
- Evidence: `DeviceCrash` carries "device id"; D-228 dropped writer ids from
  payloads (log 8752–8754) and `DeviceCrash` is `(cause, abort)` in `src/`.
- Proposal: annotate.
- Recommendation: apply.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B51. D-101

- Sources: S2-E stale, owes 4; G rulings.
- Lines: Position and Rationale log 3155–3178.
- Evidence: "exactly two substitutions" (D-274 bullet 4 reduced it to one,
  log 11665–11666), a header taken before boundary zero, boundary zero
  re-executed under replay, `ReplayHeaderMismatch`, "the interactive
  writer's sparse records", "the header's schemas". D-274, D-176, D-174 and
  D-255 each moved one; D-101 carries no annotation. The Rationale
  (3167–3177) holds three workflows, re-records, pacing and control
  unchanged, validation loud and up front, structural against parametric.
  Three of these are bold in §12.7.
- Proposal: annotate each stale item. Write a Position for the Rationale's
  one long sentence of rulings.
- Recommendation: apply.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B52. D-106

- Sources: S1-E owes 10; S2-E owes 16.
- Lines: Rejected log 3382; Rationale 3364–3365.
- Evidence: "one thread-budget check per run against the frozen roster"
  (§12.2) rests on the Rejected text; the doctrine's "final form" (§12.5) on
  the Rationale.
- Proposal: state both in the Position.
- Recommendation: apply.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B53. D-110

- Sources: S2-E stale.
- Lines: Rationale log 3518–3519.
- Evidence: "resume-at-time spelled explicitly via `capture`'s returned `t`";
  `capture`'s condition form retired with D-273.
- Proposal: annotate.
- Recommendation: apply.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B54. D-114

- Sources: S1-E stale.
- Lines: Position log 3633–3640.
- Evidence: "the boundary index is carried *in* the snapshot … and
  additionally mirrored in the loop state the wait predicate tests". Since
  D-230 the snapshot carries the trajectory's ordinal and the wait counter
  is a separate, never-reset count.
- Proposal: annotate with D-230.
- Recommendation: apply.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B55. D-127

- Sources: S2-E stale, owes 9; G rulings; IC2 notes.
- Lines: Position log 4057–4068; Rejected 4081–4082.
- Evidence: `ReplayHeaderMismatch` (now `CheckpointMismatch`), `n`,
  `event_budget`, and "`t₀` applied rather than compared", which
  `restore = false` contradicts (F57). The annotation covers the policy only.
  The Rejected text, "a recorded `stop_on` termination reproduces itself
  anyway", is §12.7's reproduction claim. IC2 confirms an annotation is
  owed under rule 1.
- Proposal: annotate each; state the recorded-stop reproduction in the
  Position.
- Recommendation: apply.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B56. D-128

- Sources: S1-E stale; S2-E stale, owes 10.
- Lines: Rationale log 4108–4109; Position 4094–4098.
- Evidence: "The boundary counter stays the reporting index"; since D-230
  the reporting index is the published-boundary ordinal. R17 now says
  pointers use the frame-entry index. The Position's "published boundary
  `k`" is not F83's wording (G rulings). The entry also lacks §12.3 in its
  Spec field.
- Proposal: annotate the Rationale with D-230 and R17. Add §12.3 to the Spec
  field.
- Recommendation: apply.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B57. D-132 (see E1)

- Sources: S1-E stale, owes 3 and 13; IC1 row 131; A, B rulings.
- Lines: Position log 4232–4236; Rationale 4241, 4252–4260; Rejected
  4285–4291.
- Evidence: the Position says `stop_on` (retired by D-316) and "resumable by
  the next `run!`" (E1). The Rationale (4256–4257) says "(5)'s honest
  asymmetry". Step (5) has had no asymmetry since D-310 (F3 deleted the
  spec's copy). The annotation of 2026-10-13 names only the topology
  clause. The chapter bolds the Position and two Rationale clauses
  (boundary masking is normative; a second interrupt collapses the joins).
  The two Rejected verdicts (no public `interrupt!`; no process-global
  `exit_on_sigint(false)`) are cited plain.
- Proposal: IC1's annotation at the end of the Rationale: "Annotation
  (2026-10-15): since [D-310][d-310] no device runs on the calling task, so
  [§12.4][s12-4](5) has no asymmetry left, and the clause on "(5)'s honest
  asymmetry" above is historical." Annotate `stop_on`. "Resumable" waits
  for E1. Write a Position for masking, the interactive scope and the second
  interrupt.
- Recommendation: apply all but the E1 part.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B58. D-133

- Sources: S1-E super, owes 7 and 8; S2-E owes 8; A rulings; B36.
- Lines: Position log 4316; Rationale 4327–4330, 4335–4344, 4343; annotation
  4346–4349.
- Evidence: Position "stated once in §12.4(1)" (B36); Rationale 4343
  "`stop_on`". D-198 amended it for the join timeout (log 7425, "This
  amends D-133") but the annotation names only D-256, D-234 and D-181.
  Rationale-only rulings the chapter relies on: the loose, advisory 2 s
  threshold tolerating a parked device; `t_end` a grid fact against stop
  requests at every boundary and the `t_plus` precedent; the event trio
  compared.
- Proposal: annotate with D-198 and D-316. Write the three Rationale rulings
  into the Position.
- Recommendation: apply.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B59. D-134 (see E2)

- Sources: A rulings, "Inbound"; IC1 row 141; E2.
- Lines: Rationale log 4398–4399.
- Evidence: §12.3's GUI read path ("The GUI does not use the wait"), kept
  under R2.
- Proposal: annotate with D-310, as E2 rules.
- Recommendation: apply, after E2.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B60. D-138

- Sources: S1-E stale, owes 4; IC1 rows 152–154; B rulings.
- Lines: Rationale log 4662–4692, esp. 4668, 4670–4683.
- Evidence: the Rationale carries the dispositions the chapter bolds (no new
  diagnostic kind; the `should_abort` split; claims persist). Stale items:
  `DeviceCrash`'s payload "(device id, …)" (D-228); "orphaned slots", "slot
  totality" (D-206: root inputs); "from the first frame", overbroad (F10);
  "(§11.8, D-136)" backs a staleness claim §11.8 does not make; "holding
  their initial values", "the stop already pending at boundary zero",
  boundary zero "published" by the run (R8). The Position states only the
  bracket.
- Proposal: annotate each item with R8's reading (the values the run started
  with; the stop pending at the run's first frame top; the run ends `stopped`
  where it started). Write a Position for the dispositions.
- Recommendation: apply.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B61. D-198

- Sources: S1-E super, stale; B rulings.
- Lines: Position log 7421–7425; Rationale ("Deployment contexts").
- Evidence: the Position makes `join_timeout` "a `Simulation` deployment
  keyword … outside the trace header's deployment block". D-256 bullet 3
  moved it to `Control`; D-317 bullet 2 put it on `Simulation(model;
  join_timeout = 5.0)`. No annotation.
- Proposal: annotate. If B19 applies, note the Rationale's wording.
- Recommendation: apply.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B62. D-217

- Sources: S2-E stale.
- Lines: bullets 4–5, log 8222–8225.
- Evidence: `ReplayHeaderMismatch`.
- Proposal: annotate with D-319's `CheckpointMismatch` rename.
- Recommendation: apply.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B63. D-218

- Sources: S2-E stale, owes 5; G rulings.
- Lines: bullet 3, log 8284–8285; Rationale 8289–8293; Position 8273–8275.
- Evidence: `restore!` missing from the doors that reset the mode;
  Rationale "two substitutions". The Rationale (the mode outliving the call
  makes a partial replay resumable; one loop and one drain) is cited in
  §12.7. Four D-218 bolds in §12.7 rest on its Position and bullets.
- Proposal: annotate both. State the mode rule in the Position.
- Recommendation: apply.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B64. D-219

- Sources: S2-E owes 6; G rulings.
- Lines: bullet 2, log 8326–8327; Rejected 8359–8362.
- Evidence: `live!` leaving the inherited header and appending, and
  `to_time`'s rounding against `t_end`'s, are in the Rationale and Rejected
  text.
- Proposal: state them in the Position.
- Recommendation: apply.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B65. D-223

- Sources: S2-E stale.
- Lines: Position log 8554.
- Evidence: "under `init!` or `replay!`"; only `init!` runs boundary zero
  since D-274. F's rulings cite the clauses that stand.
- Proposal: annotate.
- Recommendation: apply.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B66. D-230

- Sources: S1-E owes 12; S2-E super; A, F rulings.
- Lines: Position log 8845; Rationale 8855–8858; Rejected 8870–8871.
- Evidence: the Position says "a new trajectory restarts" the ordinal;
  §12.6 cites D-274 bullet 3 (F70) for the ordinal continuing under
  `restore!`. "The counter never resets because `last_seen` must not run
  ahead" rests on the Rationale and Rejected text.
- Proposal: annotate with D-274. State the counter rule in the Position.
- Recommendation: apply.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B67. D-249

- Sources: S2-E stale; IC2 notes.
- Lines: bullet 4, log 9696–9697.
- Evidence: `StopFaceInvalid` at the constructor, `run!` or `replay!`;
  retired by D-316. IC2 confirms §12.7's citation holds and an annotation is
  owed.
- Proposal: annotate.
- Recommendation: apply.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B68. D-254

- Sources: S2-E owes 8.
- Lines: Rationale log 10006–10009.
- Evidence: "the deployment comparison as one expression" is §12.7's, cited
  uncited and kept as written.
- Proposal: state it in the Position.
- Recommendation: apply.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B69. D-255

- Sources: S1-E super, owes 9; S2-E super, owes 12; A, F rulings.
- Lines: Position log 10038–10047; Rationale 10077–10078, 10091–10093;
  Rejected 10105–10106.
- Evidence: the Position still reads "`Control.lifecycle` says whether it
  started" and "`Control`, which keeps the stop word, the lifecycle and the
  wait" (D-317 bullet 6 retired this; D-317's Supersedes line, log 13821).
  Bullet 1's `Run` shape is superseded by D-260 (log 10346), and the
  placeholder clause reads "`t₀ = zero(T)`, `mode = :live`, empty log and
  trace" (replaced by D-260 and D-261). No annotation points to D-260. The
  Rationale rules "the control plane is what anyone may poke" and the
  placeholder preferred to `nothing`; the Rejected list treats `Control` as
  the control plane.
- Proposal: annotate with D-317 and D-260. State the control plane's
  openness and the placeholder choice in the Position.
- Recommendation: apply. The cited clauses stand.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B70. D-260

- Sources: S2-E super, stale.
- Lines: bullet 1, log 10324.
- Evidence: the four-field `Run` is superseded by D-317 (log 13823). No
  annotation says so.
- Proposal: annotate.
- Recommendation: apply.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B71. D-261

- Sources: S2-E stale, owes 13; F rulings.
- Lines: bullet 7, log 10442–10444; Rationale 10500–10503.
- Evidence: the recording keywords sit on `init!` and `replay!` only;
  `Simulation(deployment, T)` keeps `chunk_size`, which D-317 moved to the
  `Model` (log 13823–13825). `restore!(sim, cp)` takes the four keywords
  (D-319 implies it; no entry states it). The per-run recording at the doors
  rests on the Rationale.
- Proposal: annotate; state the `restore!` keywords and the per-run
  recording in the Position.
- Recommendation: apply.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B72. D-268

- Sources: S1-E super, owes 2 and 5; IC1 row 193; B rulings.
- Lines: Position bullet 2, log 11087–11089; Rationale 11136–11139, 11153;
  Rejected 11192; annotations 11161–11172.
- Evidence: bullet 2 says "stop face" (D-316: stop requests). The
  annotation at 11172 says "until the next `init!`"; §12.4 says `init!`,
  `restore!` or `replay!` (F22). The annotations of 2026-09-26 hold "a frame
  that throws with an interrupt pending ends `errored`" and "a forced throw
  reaches the defensive arm"; both are bold in §12.4. Rejected 11192 holds
  "the stop word cleared at the top of each run". B37 is its Rationale
  citation.
- Proposal: annotate "stop face" and the init list. State the two
  annotations' rulings and the stop-word clearing in the Position.
- Recommendation: apply.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B73. D-270

- Sources: S1-E super, owes 1; A rulings.
- Lines: Position log 11332; annotation 11413–11421.
- Evidence: the Position says "`orphaned(record)` is a `:done` or `:failed`
  task"; the annotation of 2026-09-28 narrows it to `:done`. §12.2 bolds
  "`task_state` has three values" on the annotation alone.
- Proposal: rewrite the Position's clause to the annotation's rule.
- Recommendation: apply.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B74. D-274

- Sources: S2-E super, stale, owes 7; IC2 notes.
- Lines: bullet 2 and Spec field, log 11652, 11691; Rationale 11708–11714.
- Evidence: bullet 2 says `checkpoint(sim)` "is a stopped-sim service
  (§13.7)". §13.7 is "Tooling consequences: face routes and the component
  library" (spec 10577); the services are §14. A renumbering left it. D-319
  amends the entry (annotation 11716–11721); bullet 5 states the what-if's
  shape only. "Nothing applied twice at `t₀`" and the seek rest on the
  Rationale.
- Proposal: correct §13.7 to §14 in both places. State the Rationale's two
  rulings in the Position.
- Recommendation: apply.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B75. D-319

- Sources: S1-E stale (Spec fields); S2-E owes 11; S2 part D.
- Lines: Spec field; Rationale log 14080–14083.
- Evidence: the Spec field lacks §12.4 (row 195) and §12.7 (`restore = false`
  header and validation use its state split). "A standalone model has no
  ordinals to continue" rests on the Rationale.
- Proposal: add the sections; state the rule in the Position.
- Recommendation: apply.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B76. Other Rationale-only citations, no repair proposed

- Sources: A, B, F, G rulings, Rationale-only lists.
- Evidence: D-028 (Rejected 1011–1015: no condition variables carrying
  facts, no per-consumer queues), D-203 (Rationale 7611–7615: the first
  writer names the request), D-269 (Rationale 11250–11253: the harness
  mode), D-134 (above), D-045 and D-060 (Spec fields, B41) are cited plain.
  No bold in the chapter rests on these cites alone.
- Proposal: none.
- Recommendation: no action unless the owner wants Positions written for
  every Rationale citation.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B77. Rulings with no entry at all, half 1

- Sources: S1-E none.
- Evidence: the `systemsleep` variant admitted as a guarded addition;
  "tight" as fewer threads than the roster plus one; the wrapper treating an
  `unblock!`-provoked raise as shutdown, not a crash; each task reading
  `last_seen` at spawn; the pause block parking on a condition;
  `checkpoint`'s test that the latest snapshot is of the clock's boundary
  (§12.6 also states it). Row 120 (the promotion) is §13.6's. Rows 50, 54,
  72, 89, 121 are descriptions that need no entry.
- Proposal: write one entry per ruling that the owner wants to keep, in
  the entry that is closest (D-027, D-106, D-373, D-228, D-274).
- Recommendation: the owner chooses. The first four describe code behaviour
  the chapter states; record them.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B78. Rulings with no entry at all, half 2

- Sources: S2-E none.
- Evidence:
  - `replay!(sim, trc; restore = false)`: the keyword, its preconditions,
    its refusal kind, the drain from the frame after the simulation's own,
    the run and header it builds, "one grid is an invariant of every
    replay", validation under both forms (commit `75911b9`; its clock arm
    `7203798`). D-274 bullet 5 states the shape only.
  - The halt's range refusals; the frame forms of `to_boundary` and
    `to_time`.
  - The re-publication's ordinal under `restore!`.
  - `checkpoint(sim)` refused after an abandoned frame, and its test.
  - `restore!` clearing staged batches and returning the mode to `:live`
    (D-218 bullet 3 names `init!` and `replay!` only).
  - `restore!(sim, cp)` taking the four recording keywords.
  - The rename `ReplayHeaderMismatch` to `CheckpointMismatch` (D-319 uses
    the new name without ruling it).
  - The schedule compared with every column; a rate re-declared through a
    different anchor refused.
  - "The harness cell … is not step-scoped"; "State and mode are
    orthogonal"; "Nothing advances until one of those doors is taken"; the
    six-field count; "strictly richer"; the mid-run intervention command's
    shape (D-031).
  - Rows 501, 505, 509, 626, 669, 672 are descriptions that need no entry.
- Proposal: write an entry for the `restore = false` form first; it is the
  largest. The rest go into D-218, D-274, D-319 and D-088 as Position
  clauses.
- Recommendation: the owner chooses. At least the `restore = false` form and
  the `CheckpointMismatch` rename need an entry.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B79. The glossary: a *stop word* entry

- Sources: brief R11; A and B rulings (R15).
- Evidence: R11 glosses the stop word inline and says its entry waits for
  track 2. R15 settled the wording "the control plane's stop command, one
  atomic word holding its issuer". The glossary's *stop request* entry is a
  model-detected termination, a different term.
- Proposal: add *stop word* to the glossary with R15's wording and a pointer
  to §12.1, and a "not the stop request" note.
- Recommendation: apply.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B80. The glossary's *calling task* entry says "invoked `run!`"

- Sources: A verify, "Other".
- Evidence: the §12.2 gloss reads "invoked `run!`" in a sentence about
  `run!` or `replay!`. It matches the glossary.
- Proposal: widen the glossary entry to "invoked `run!` or `replay!`".
- Recommendation: apply.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

### B81. "Sweep" names two things in §12.4

- Sources: P1-6 (the in-chapter half, P1-13, is EDITORIAL).
- Lines: §12.4, chapter 346, 579, 622.
- Evidence: line 579 links [sweep](#g-sweep) as "one pass through the
  execution order". Lines 346 and 622 say "the run's-end sweep", the loop's
  final collection of every diagnostic cell (D-201). The phrase is spec
  vocabulary: four uses in the frozen spec, among them §13.5 10430 and
  Appendix C 13478.
- Proposal: either keep the name with the gloss at 346 (the fixers apply
  this through P1-13), or rename it spec-wide, for example "the run's-end
  collection".
- Recommendation: keep the name and the gloss. A spec-wide rename is outside
  this chapter.

Status: ruled, track 2 (recipe step 8): apply after landing, under N1 of evidence_check.md, as new entries or annotations, never new Position text in an old entry; an UNCONFIRMED item takes the evidence check's correction, and a ruling with no recorded source goes to the owner.

## Carried

Items for chapters 13, 14, 11 and the front matter. Nothing here blocks
chapter 12. Each is a place where another chapter's text now disagrees with,
or repeats, what chapter 12 says. `escalations.md` holds E1 and E2, which
are not repeated here.

### B82. Chapter 13: §13.5 repeats the per-advance stop policy

- Sources: F rulings, "Bold on the same entry elsewhere"; brief R5.
- Lines: spec 10334 (the bold lead-in "Policy"), 10336 ("Every request is
  honoured unless the advance ignores it", D-316 Position), 10343, 10348.
- Evidence: R5 makes §12.6 the home of the per-advance stop policy and
  carries §13.5's repeat to chapter 13. §13.5 10348 cites "(§12.6, D-260)"
  for the policy's lifetime, and §12.6 keeps that sentence.
- Proposal: chapter 13's rewrite reduces the repeat to a pointer and keeps
  its own D-316 and D-261 bolds if they are the first statement there.
- Recommendation: carry.

Status: ruled, carried: added to `docs/spec_rewrite/README.md`'s carried list when the chapter closes.

### B83. Chapter 13: the GUI and the unmask points

- Sources: IC1 rows 54, 61 and 91.
- Lines: spec 10518 ("GUI stop button"), 10515, 10239 ("a frame-top or wait
  unmask point").
- Evidence: §13.5's "GUI stop button" is R2's analogue: D-310 parked the
  GUI, and §12.4 now says "a front end's". §13.4's 10239–10241 ("a single
  interrupt never reaches the branch") matches §12.4's scoped "never sees a
  single interrupt" (F14), but 10239 omits the pause block (B35).
- Proposal: "a front end's stop button" at 10518 and 10515; add the pause
  block at 10239.
- Recommendation: carry to chapter 13's rewrite.

Status: ruled, carried: added to `docs/spec_rewrite/README.md`'s carried list when the chapter closes.

### B84. Chapter 14: "`errored` is terminal" is bold in two places

- Sources: P2-14; F rulings.
- Lines: spec 11031 (§14); §14.8 11949 (B24).
- Evidence: see B10. §12.6 keeps the bold; §14's "`errored` is terminal for
  every row" is D-059 and D-108.
- Proposal: chapter 14's rewrite makes 11031 plain with its citation. The
  §14.8 recorders sentence (B24) is chapter 14's text too.
- Recommendation: carry.

Status: ruled, carried: added to `docs/spec_rewrite/README.md`'s carried list when the chapter closes.

### B85. Chapter 11: §11.7 still shows the GUI as live

- Sources: P2-4.
- Lines: spec §11.7 (8229–8234 for the dead-slider fight; the GUI widget
  text near it).
- Evidence: frozen §11.7 describes the GUI in the present tense, as §12.5
  did before B11.
- Proposal: chapter 11's treatment applies R2's wording there.
- Recommendation: carry. Do not hold chapter 12 for it.

Status: ruled, carried: added to `docs/spec_rewrite/README.md`'s carried list when the chapter closes.

### B86. Front matter: the Part III roadmap omits §12.5

- Sources: IC1, OK-with-problem row 6; brief R1.
- Lines: spec 5478–5480.
- Evidence: the roadmap omits §12.5, as it did before the rewrite. R1 leaves
  it to the front-matter rewrite.
- Proposal: add §12.5 when the front matter is rewritten.
- Recommendation: carry.

Status: ruled, carried: added to `docs/spec_rewrite/README.md`'s carried list when the chapter closes.

### B87. `flight_case_studies.md` 408: the window is the parked GUI's

- Sources: IC1 row 237; S1 part D.
- Lines: `flight_case_studies.md` 408 ("*Window close.* §12.4 applies
  verbatim").
- Evidence: the window belongs to the parked GUI (D-310). §12.4 now says "a
  front end". The tail steps it lists still hold.
- Proposal: none now; the case-study rewrite words the window as a front
  end's.
- Recommendation: carry.

Status: ruled, carried: added to `docs/spec_rewrite/README.md`'s carried list when the chapter closes.

### B88. A code comment says "door" for `run!`

- Sources: S1-E, "Findings carried from earlier chapters", first bullet.
- Lines: `src/sim.jl` 1153–1155 and 1183 ("either door checks once per run").
- Evidence: chapter 11's F23 asked whether §12.2 uses *door* for `run!`. It
  does not (§12.2 says "A run warns, at `run!` or `replay!`"). The word
  survives only in the code comment, outside the rewrite. R14 now reserves
  *door* for the entry points that build a run.
- Proposal: reword the comment to "either entry point" in a code pass.
- Recommendation: carry. One word, no spec effect.

Status: ruled, carried: added to `docs/spec_rewrite/README.md`'s carried list when the chapter closes.

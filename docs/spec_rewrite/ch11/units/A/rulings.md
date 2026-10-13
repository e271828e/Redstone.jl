# Unit A rulings: chapter 11 heading, roadmap and §11.1

Rulings applied: R1, R2, R3, R6 (old 6802–6807 kept), R10 (F12, F13, F24),
R11 (`sim.jl`), R13, and survey 1's M2 (the two rules move up after the
plane list). *Calling task* takes its link and gloss at its first use, in
plane 5, which is plain and uncited: an overview of the topology paragraphs,
whose D-093 and D-310 bolds are each ruling's first statement.

Verifier fixes (`verify.md`), applied on the coordinator's instruction:

- The chapter opening carries no glossary links, as in chapter 10's
  opening. That includes *periphery*, so it matches chapter 10.
- In §11.1 every first-use link has a gloss taken from its glossary entry,
  each declared as an addition: periphery, boundary, trace, replay, drain,
  device, root input, snapshot, calling task, staging cell, roster, `Build`,
  buffer, activation. *Device* and *root input* first appear inside the
  periphery and drain glosses. They are linked at their first use outside a
  gloss, in plane 1, so no parenthetical is nested.
- F12 reads "The staging cells … and the reference to the published
  snapshot".
- R3 reads "is decided after initialization" and cites D-310 and D-138.
- The reference frames get one added sentence: "The b frame is the body
  frame, and ECEF stands for Earth-centered, Earth-fixed."
- Two pointers were added: [§11.4][s11-4] at "mappings", and
  [§10.7][s10-7] at the pacer's debt absorption.
- The snapshot's gloss is "a boundary-consistent signal table with its
  framework status", from its glossary entry. D-022 ends the sentence that
  publishes the snapshot, which is reordered so the citation does not sit
  right after the gloss. §10.3 stays outside the boundary gloss, cited
  for the visibility rule.
- The text is rewrapped to 80 rendered columns, and "Earth-centered" uses
  US spelling.

R10 phrase sweep: "Both shared structures" and "executable sets" have no
other instance in the unit. §10.7 now appears only as the pacer pointer,
never for replay. The drain is glossed once, in the frame paragraph, with
R13's wording. The roadmap names it without a link.

## Corrections proposed

1. **Who owns the buffers.** New text, "each `Simulation` owns its own
   buffers ([§9.4][s9-4])" (old 6847). D-282 bullet 1 is annotated by D-317
   (log 11967–11968): "The `Model` owns its activation's buffers, and a
   `Simulation` owns its `Model{Float64}`." The sentence stays true through
   the `Model`, but it names the wrong owner. Proposed: "and each
   `Simulation` owns its own `Model`, and with it the `Model`'s
   [buffers](#g-buffer) ([§9.4][s9-4], [D-317][d-317])." Held as written.
2. **The roadmap's "device authoring contract".** *Contract* is reserved for
   a component's declared interface, and a device is not a component. The
   phrase is §11.6's own term and part F does not list it, so it stays.
   Chapter 11's track 2 may want "device authoring interface". Held as
   written.

## Citations added or replaced

- **[§8.6][s8-6]**, opening context sentence, by R1.
- **[§12.7][s12-7]** replaces `[§10.7]` at bit-identical replay (old 6806),
  by R10 F13.
- **[D-022][d-022]**, five new sites, all from its Position (log 832–836).
  Plane 2 (the drain) and plane 3 (publication): "staged inputs drained at
  frame top + immutable snapshot published per boundary". Plane 4: "control
  on a separate atomic surface". The first rule: "every handoff one atomic
  reference op, GC as reclamation". The second rule: "no user code or
  unbounded work in framework critical sections". The consequence:
  "interactive = batch + devices". That clause uses *batch* in the retired
  batch-run sense, which the new text does not import.
- **[D-101][d-101]**, at the trace key (old 6811–6812). Position (log
  3097–3099): "the frame-top drain fed by the recording's batches keyed by
  frame ordinal".
- **[D-310][d-310]**, at the R3 sentence, by R3. Its Position: "`run!` has
  one task topology"; bullet 2: "`gui = true` is withdrawn." Plane 5 stays
  uncited.
- **[D-138][d-138]**, at the R3 sentence and at "A device whose `init!`
  failed gets no task". R3 allows it only if the Position carries the rule.
  It does (log 4540–4544): `init!` runs "on the calling task, pre-spawn",
  and on a throw the framework "reports `DeviceCrash` by name and marks it
  dead, no task being spawned". That is what "decided after
  initialization" rests on.
- **[§11.4][s11-4]** at "mappings" and **[§10.7][s10-7]** at the pacer's
  debt absorption. These are pointers only.
- **[D-093][d-093]**, at "Device tasks are run-scoped" (old 6835). Position
  (log 2842–2846): "Device tasks are per-run artifacts …: `run!` spawns one
  task per roster entry after per-run device `init!` … `attach!` never
  spawns — one semantics, register". D-093 also moves from the latch clause
  (old 6861) to the start gate's bold sentence in the same paragraph.
- **[D-282][d-282]**, at the shared `Build` (old 6846). Position bullet 3
  (log 11956–11958): "The `Build` is immutable apart from its lazily filled
  activation dictionary, and may back any number of deployments and
  `Simulation`s concurrently."
- **[D-135][d-135]**, at the pre-materializing idiom (old 6848–6850).
  Rationale only; see below.

## Rationale-only rulings

- **D-022, Rejected** (log 843–845): transplanting `io_lock`, "input timing
  scheduler-determined and unrecorded — replay undefinable in principle".
  It was already cited. R6 keeps the passage.
- **D-093, Rationale** (log 2852–2854) and **Rejected** (log 2867–2868): the
  start gate. "spawn-inside-`run!` replaces the start gate, and
  first-boundary synchronization is §12.3's counter-plus-condition predicate
  wait"; rejected: "*`Event` start gate 'as today'*". The bold stays. The
  log owes a Position that states it.
- **D-135, Rationale** (log 4368–4371): "Recommended idiom for §11.1's
  parallel sweeps …: pre-materialize with the existing `build(world;
  activations = …)` keyword and the shared artifact is fully immutable, with
  no synchronization on any path."
- Left uncited, ruled only in a Rationale: the synchronous rethrow, inline
  sweeps and `run!` blocking its caller (D-093 Rationale log 2859–2861,
  whose surrounding text D-310 withdrew); the frame as one loop iteration
  (D-123 Rationale log 3856–3858); reference frames always compounded (D-122
  Rationale log 3827–3828).
- The R3 sentence's "never from `run!`'s keywords" rests on D-310 only
  indirectly, through its withdrawal of `gui = true`. "Decided after
  initialization" rests on D-138's Position, which is cited beside it.

## Bold on the same entry elsewhere

- Seven bolds in the unit: four on D-022 (the drain, control, every handoff,
  no user code), two on D-093 (run-scoped device tasks, the start gate) and
  one on D-310 (the loop on the calling task).
- The frozen spec's chapters 5–10 and 12–14 bold none of D-022, D-093, D-310
  or D-138. D-282's bold at §9.4 (old 4848, "Every buffer set has exactly one
  owner") is a different ruling, and this unit cites D-282 plain.
- The `new.md` files of units B, C, D, F, G2 and H bold none of these
  entries. G1 bolds two other D-138 rulings ("`shutdown!` must tolerate a
  partially initialized device", "`should_abort` is an `attach!` keyword").
  This unit cites D-138 plain, for the no-task rule, so no ruling is bold
  twice. Unit J had no `new.md` when checked.
- Not a D-bold, but next to it: §12.6 (old 9269) bolds "Task topology
  follows the roster each time" with only a §11.1 citation. This belongs to
  the chapter 12 rewrite. §11.1 now says "which devices get a task", not
  "topology".

## Inbound citations affected

- D-138 Rationale (log 4571–4573) quotes "**Topology is derived after
  initialization** ([§11.1][s11-1])". R3 removes the phrase. The Rationale
  was already stale (`needs_calling_task` is withdrawn), so this goes to
  track 2.
- D-109 Annotation (log 3402) says §11.1 and §12.4 carry the derivation.
  The entry is superseded. §11.1 keeps the claim, stated plain.
- spec 349 (§2.2) needs the loop-iteration order, and it holds. spec
  13597–13600 (the glossary's *frame*) needs the iteration, the `step!`
  count and the trace key, and it holds. That entry could also cite §10.1
  (track 2). spec 14154–14156 (*frame ordinal*) needs the trace key, and it
  holds.
- D-123 Rationale and Rejected (log 3856–3858, 3871) name §11.1 as the
  frame's home. §11.1 keeps the loop-iteration sense and points at §10.1
  for the grid step.
- D-136 Rejected (log 4437) cites "§11.1's two rules". It holds, and they now
  sit right after the plane list.
- spec 13961 (*calling task*), 8749, 8859, 9146–9148, 9166, 9264, 4822 and
  12473 hold.
- No inbound row relied on §11.1's removed `#g-executable-set` link or its
  second `#g-roster` link.

## Open questions

1. **Where D-022's first ruling is bold.** The bold sits on plane 2's
   headline clause, "The drain is exactly one point in each frame, at its
   top". Planes 1 and 3 carry the rest of that ruling plain, with plane 3
   repeating the citation.
2. **D-022's fifth ruling stays plain** on the coordinator's ruling. The
   text frames it as a consequence.
3. **Stale log entries (track 2).** D-093's Rationale (log 2855–2861) still
   describes the GUI as the one device without a spawned task. D-310
   annotates neither D-093 nor D-102.
4. **"These patterns" has no antecedent** in the first rule's bullet. The
   old text had the same gap, and it is held as written.

## Rulings batch edits (checkpoint 3)

- **B-15** settles correction 1: "each `Simulation` owns its own `Model`, and
  with it the `Model`'s [buffers](#g-buffer) (…, [§9.4][s9-4])". The gloss
  stays, and §9.4 alone is cited, since it cites D-317. C-041, tag R.
- **B-16** settles open question 4. "Lock-free handoffs" was already in the
  text from the chapter fixes (P1-5), so no edit was made.

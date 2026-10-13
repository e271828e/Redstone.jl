# Brief: the readability rewrite of spec chapter 11

You rewrite one unit of chapter 11 of `docs/design/spec.md`, "Runtime
periphery: the data plane", for readability, with no loss of content. Nine
agents work in parallel, one per unit. This file is the same for all of them;
your prompt names your unit.

Paths below are relative to `docs/spec_rewrite/ch11/` unless they start with
`docs/`. Run the checker from `docs/spec_rewrite/`. The base commit is
`f61b1af`. Old spec lines below are lines of `spec.md` at that commit; the
frozen copies `scratch_survey/spec.md` and `scratch_survey/decisions.md` are
byte-identical to it. Other sessions edit `spec.md` during this rewrite, and
chapter 12 is being rewritten in parallel, so never read `spec.md` or
`decisions.md` from the working tree.

## Read first

1. `docs/design/tools/spec_style.md`, all of "Sentences", "Terms", "Section
   template", "Marking rulings", "Rationale" and "Content preservation". It
   is the convention you write to. This brief does not restate it.
2. A finished chapter written to the convention: §10.1, §10.6 and §9.8 of the
   frozen spec at least, read by section.
3. The survey of your half. Units A to D read `survey_1.md`; units F to J
   read `survey_2.md`. Read part A for your unit's sections, part B's
   overlaps, part C's moves, order and code blocks for your unit, part D's
   rows for your lines, part E's items for your lines, and part F whole.
   Part F's warnings apply to every unit of that half.
4. Your unit's `units/<U>/old.md`, the text you rewrite.

Read `spec.md` by section via its heading outline, never whole. Read a
decision entry in full before you cite it or claim what it rules. Grep the
log; never read it whole. `scratch_survey/entry.sh 136` prints D-136 with its
log line numbers.

## Rulings already made

These are the orchestrator's rulings at checkpoint 1, each on the survey
question named (q1–q13 are `survey_1.md`'s, q21–q33 are `survey_2.md`'s).
Apply the ones that touch your unit, and tag each such claim in the
inventory with `"tag": "R"` and `"ruling": "<id>"`.

- **R1. The opening** (q1, option a for the opening only; unit A). The
  chapter opening becomes one context sentence and one roadmap sentence, in
  chapter 10's form. The context sentence says the chapter specifies the
  data plane between the loop ([§10][s10]) and the periphery (GUI, input
  devices, network I/O and logging), taking root inputs ([§8.6][s8-6]) as
  given. The roadmap sentence names §11.1 to §11.8 in order by subject, and
  names the two data channels (outbound, inbound) before the third
  (diagnostics). The §12 pointer stays. Source every word from the old
  opening, the section titles and the sections' content. The Part III
  roadmap (old 5469–5473) is not edited: it belongs to the front-matter
  rewrite.
- **R2. The frame paragraph** (q2, option a; unit A). §11.1's frame gloss
  points at §10.1, which holds the loop's two units. The loop-iteration order
  (drain, integrate, boundary sequence, publication), the `step!` count, the
  trace key and the reference-frames note stay: §10.1 holds none of them.
- **R3. "Topology is derived after initialization"** (q3; unit A). The bold
  goes: its only Position was D-109's, superseded by D-310. Keep every claim,
  plain: which devices get a task is fixed after initialization, from the
  frozen roster and the outcomes of device `init!`, never from `run!`'s
  keywords; a device whose `init!` failed gets no task ([§12.4][s12-4]). Say
  "which devices get a task", not "topology": D-310 gives `run!` one task
  topology. Cite D-310 for the sentence. Cite D-138 too only if its Position
  carries the `init!` failure rule; read it first.
- **R4. The harness writer's task and its cell's writers** (q4, option a;
  units C and D). D-200 settles both.
  - Unit C, old 7224–7225: "It stages a batch from the calling task itself
    (the task that invoked `run!`)" becomes "It stages a batch from any task,
    the calling task included ([D-200][d-200])." Keep the calling-task gloss
    if the term is first used here. D-200's Position says the diagnostics
    are written "on whichever task stages"; its Rationale says "a harness
    `stage!` runs on whatever task calls it". List D-200 under
    "Rationale-only rulings".
  - Unit D, old 7343–7348: scope "Each cell has a single writer, its own
    device task" and "The CAS can fail only because a drain intercepted the
    old batch, so the retry is bounded" to a device's cell. Add one declared
    sentence: the harness cell is the exception, since several tasks may
    stage into it concurrently, and a CAS that fails because another stager
    merged first retries the same way ([D-200][d-200]). Do not call the
    harness cell's retry bounded. Sources: D-200 Rationale (log 7364), and
    `src/dataplane.jl`'s `StagingCell` docstring ("drained, or merged past by
    another stager").
- **R5. One home per overlap across the split** (q5, q22, q23; units B, C,
  D, F, G1, G2, H, J). The home states the fact; the other site keeps one
  clause or sentence and a pointer. Never cut what the home does not hold.
  - The framework status's contents: home §11.8 (J), which keeps the bold
    on "a concrete frozen value" with D-136. §11.2 (B) states it plain,
    keeps the binding-rule consequence (old 6924–6926) and points at §11.8.
    §13.2 cites §11.2 for the status surfacing in snapshots; B's snapshot
    Rule (old 6903) keeps that.
  - What the terminal snapshot carries: home §11.8 (J). §11.2 (B) keeps why
    the endpoint is retained, in one clause, and points at §11.8.
  - `totals` monotone across logged snapshots, and decimation losing which
    boundary, never how many: home §11.2 (B), beside re-decimation. §11.8
    (J) keeps one sentence and a pointer.
  - `map_output` receiving a labeled NamedTuple keyed by `reads`: home §11.6
    (G2, D-199). §11.2 (B) keeps "compiled to one gather" and the attach-time
    failure, and points at §11.6 (survey 1, M4).
  - The claim mechanism, one mechanism with two sources: home §11.3 (C,
    D-174). §11.6 (G2, old 7981–7991) keeps the declaration side, one
    sentence that the binding declares the source and that past the attach
    point nothing tells them apart, with a pointer at §11.3.
  - `EmptyGreedyClaim`: §11.3 (C) keeps the empty complement's legality and
    points at §11.6 for the warning. §11.6 (G2) holds the warning, the
    second-greedy case and the diagnostic cell (D-250). §11.8's writer
    listing (J) stays.
  - Death is not detach and orphaned claims: home §11.3 (C, D-106). The
    orphan label "claimed by `T16000M` — task dead": home §11.7 (H). §11.3
    keeps "the orphan is rendered, never hidden" and points at §11.7.
  - `TableBinding`: home §11.6 (G2). §11.4 (D) keeps "mappings are binding
    data" and its pointer.
  - The others in survey 1's part B table ("both", "§11.4; §11.8 already
    points", and the rest) stay as that table says.
- **R6. Adversarial and history lines** (q6 option a, q24 option c).
  - Unit A: keep old 6802–6807, whose decisive cost is the reason for the
    whole design.
  - Unit B: keep the one-clause verdicts at old 6980–6981 and 7019–7020 with
    their citations.
  - Unit C: old 7266–7269 becomes "The loop reads the roster once at `run!`,
    and nothing republishes it ([D-087][d-087])", after checking D-087's
    Rejected list carries the rest.
  - Unit D: old 7419–7421 stays as a one-clause verdict with D-104. At old
    7436–7437, drop "the mutable surface used to force".
  - Unit G2: old 7973–7979 ("Rejected, correspondingly …") becomes one
    clause pointing at D-177, after checking D-177 carries every item.
    7948–7953 stays: it says what the declared side buys.
  - Unit H: old 8166–8169 stays and gains R16's clause.
  - Unit J: old 8383–8385 (D-136's rejected list) becomes one clause
    pointing at D-136, after checking D-136 carries every item.
  - Unit F: old 7594–7598's "keying retention by claim source is rejected
    (D-176)" stays as a one-clause verdict.
- **R7. The worked example** (q7, option a; unit D). It stays at full
  resolution, exempt evidence. Its framing sentence, old 7520–7521, "the
  exercise that selected per-device cells and produced the §11.7 staging
  contracts", becomes "the exercise that selected per-device cells. It
  produced two things for §11.7: the active-widget contract, which §11.7
  rejects ([D-026][d-026]), and the port-resolution answer to panel reuse."
  Evidence: the example's own "Discoveries" bullet (old 7573–7574) and §11.7
  old 8166–8167. The rest of the example stays as written, its scope note at
  old 7535–7538 included.
- **R8. The fan-out mapping entry** (q8, option a; unit D). Old 7507–7510
  stays as written, plain and uncited. It goes to `escalations.md`: the spec
  admits a per-aircraft×device mapping entry that D-045's Rejected list
  rejects, and no Position settles which holds. Report it in your
  `rulings.md` under "Open questions" and change nothing.
- **R9. Nine units** (q9, q31 option a), as below.
- **R10. Factual corrections** (q10, q21, lesson 13). Apply exactly, then grep
  your unit for every other instance of the phrase.
  - F5 (unit B, old 7071–7073): "The `sizehint!` for the expected duration
    (§9.8) is now naturally capped by `log_max`, which is also what defines
    the hint when `t_end = Inf`" becomes "The log's `sizehint!` is `log_max`
    ([§9.8][s9-8])." Source: §9.8 old 5443–5444; `src/dataplane.jl` 750.
  - F6 (unit B, old 6994–6995): "the honest interactive default (Appendix
    B)" becomes "`init!`'s and `run!`'s defaults ([Appendix B][sB])". Source:
    Appendix B old 12684 and 12762.
  - F7 (unit B, old 7089–7090): "Loggers treat field-handle signals
    specially. They skip or summarize them" becomes "An exporting logger
    treats field-handle signals specially. It skips or summarizes them."
    Source: §9.8 old 5452–5454 ("on export"); the log keeps snapshots by
    reference (old 6975–6977). It stays uncited: `pending.md` holds it open.
  - F9 (unit C, old 7237): "(below)" becomes "([§11.4][s11-4])".
  - F12 (unit A, old 6865–6866): "Both shared structures" becomes "The
    staging cells and the published reference". Source: the two rules' own
    content; §11.8 old 8263–8265.
  - F13 (unit A, old 6806): replay's citation `[§10.7]` becomes
    `[§12.7][s12-7]`.
  - F14 (unit B, old 6922): "the per-writer diagnostic batches" becomes "the
    per-writer drained diagnostics". *Batch* is reserved for staged writes.
  - F15 (unit C old 7235, unit D old 7440): "There is one seam" and "The
    recompilation has one seam" use "edge case" for "seam". *Seam* is
    reserved.
  - F18 (unit C, old 7140): "Structural slash paths never cross the
    periphery's *write* boundary" becomes "Structural slash paths never
    reach the periphery's writes." *Boundary* has two glossary senses, and
    this is neither.
  - F20 (unit C, old 7184–7185): "since claims are disjoint by construction"
    becomes "since the attach-time exclusivity check keeps claims disjoint".
    Only a computed claim is disjoint by construction (old 7192–7193).
  - F22 (unit C, old 7167–7169): "renders the device's GUI widget read-only"
    becomes "renders the GUI's widgets read-only".
  - F23 (unit C, old 7326): "at either door" becomes "at `run!` or
    `replay!`". Source: §12.2 old 8520. A door builds a run; `run!` is not
    one.
  - F24 (unit A, old 6848–6849): "Pre-materializing the sweep's activations,
    its per-eltype executable sets via `build(world; activations = …)`"
    becomes "Pre-materializing the sweep's activations with
    `build(world; activations = …)`". An executable set is what an
    activation can run, not the activation.
  - F51 (unit G2, old 7940): "That is the reflection class ([§8.1]), where
    the shadowing check is an `isdefined`/`!==` pair" becomes "It is the same
    kind of reflection check as §8.1's shadowing check, an `isdefined`/`!==`
    pair ([§8.1][s8-1])." D-177's annotation (log 6514–6516) corrects the same
    phrase.
  - F52 (unit J, old 8372–8374): "The zero-allocation invariant ([§9.8]),
    scoped to the model [sweep], is untouched" becomes "The zero-allocation
    invariant, scoped to the stepping loop ([§9.8][s9-8], [D-305][d-305]), is
    untouched." Drop the sweep link. Source: §9.8 old 5418.
  - F56 (unit G1, old 7827 and 7836): `stage!(handle, map_input(…,
    binding(handle)))` gains the splat, `stage!(handle, map_input(…,
    binding(handle))...)`, at both lines. The unsplatted call raises
    `MethodError` against `src/devices.jl` 168. A ruled code edit; nothing
    else in the block changes.
  - F57 (unit F, old 7600–7601): "[what-if replay](#g-what-if-replay)
    (replay with edited inputs)" means the edited-inputs what-if, which
    D-274 bullet 5 (log 11513–11515) names apart from §12.7's parametric one
    that the glossary entry defines. Drop the glossary link and write "the
    edited-inputs what-if (replay with edited inputs)". Do not import the
    glossary's gloss.
  - F59 (unit F, old 7665): "The length is the drain's count on the live
    trace" becomes "The length is the frame index of the last drain on the
    live trace". Source: old 7688 and 7690–7692; `src/trace.jl` 47–48.
  - F60 (unit G1, old 7867): drop "is literally 'the task body returned.'"
    §12.4's step (6) contains no such phrase. Keep a plain pointer:
    "This is [§12.4][s12-4](6)'s case."
  - F61 (unit G2, old 7898): unlink `contract` in "no contract on the datum's
    shape".
  - F65 (units F, G1, H, J): the reserved words *cell*, *batch* and *entry*, at
    each instance survey 2's F65 lists: "diagnostic cell" or "staging cell"
    for bare "cell", "the taken ring" for the diagnostic "batch" at old 8303,
    "roster entry" or "value" for bare "entry". The displayed text of a link
    counts. Unit B applies F14 above for its own instance.
  - F66 (unit H, old 8154): link `stage-on-interaction` at the staging
    contract, with its gloss.
  - F72 (unit J, old 8320–8322): "`recent` is the ring this boundary
    drained" becomes "`recent` is the ring the frame's drain took, carried by
    the first publication after that drain", and "refused this boundary"
    becomes "refused in that drain". Source: `src/dataplane.jl` 370–375 and
    413–416. Keep "at most sixteen entries" as written; whether the loop's
    record can carry thirty-two goes in `rulings.md`.
- **R11. Reader-cold names** (q11, q32, option a). One introducing clause at
  first use per section, claiming nothing beyond its source. Owners, checked
  in the Flight.jl source:
  - `sim.jl` and `SavingCallback`: FlightCore's (`FlightCore/src/sim.jl`).
  - `assign_input!(mdl, mapping, data)`: FlightCore's
    (`FlightCore/src/iodevices.jl` 49). Past tense, as the predecessor's.
  - `T16000M`: FlightCore's type for the Thrustmaster T16000M joystick
    (`FlightCore/src/joysticks.jl` 281).
  - The XPlane visualizer: FlightCore's `XPlane12Control` output device
    (`FlightCore/src/network.jl` 106). Claim nothing about it beyond that.
  - C172X and `Cessna172Xv1`: FlightApps' Cessna 172X model and its first
    variant (`FlightApps/src/c172/c172x/c172x1.jl` 16). Not FlightCore's.
    Keep the gigabytes-per-hour figure in place with this clause.
  - `VelocityData` and `v_eb_b`: no such type exists in Flight.jl. Call it
    "an illustrative wrapper type".
  - `World`: point at §8.7, which introduces it.
  - `migration_outline.md`: "the migration outline companion".
  - FCS: spell out "flight control system". `q_ref = q_sf · axis` is an
    illustrative fan-out.
- **R12. Appendix C kinds** (q12 option a, q27 option a for §11.6). Add one
  declared sentence each where the section states the condition, restating
  only the entry's Position:
  - Unit C: a returned enumeration naming a face outside the root's input
    faces is refused at attach (`AttachUnknownFace`, D-216); detaching a
    device the roster does not hold is an error (`NotAttached`, D-215). Say
    nothing of where `AttachUnknownFace` falls relative to the identity
    check.
  - Unit B: name `ReadBindingUnresolved` where §11.2 states the attach-time
    failure.
  - Unit G1: a device with no `loop` method is refused at attach
    (`DeviceContractMismatch`, D-216). Unit G2: `gather` against a binding
    with no output side (`DeviceContractMismatch`, D-216), and a malformed
    `TableBinding` table (`ArgumentInvalid`, D-216).
  - Unit F names nothing new. Appendix C's §11.5 citations for
    `CheckpointMismatch` and `ReplaySchemaMismatch` are retargeted at landing.
- **R13. The drain's gloss** (q13, option a). In every unit, the drain's
  gloss reads "the frame-top swap that applies staged device writes to the
  root inputs", the verb the glossary entry and §2.2 use. Other chapters and
  `spec_style.md`'s example follow in track 2.
- **R14. The operator interrupt** (q25, F53; unit G1). Keep the bold rule
  "An `InterruptException` is never a `DeviceCrash`". Old 7807–7809, "Under
  the spawned-loop topology the calling task is the one running a device
  loop body inline, the GUI's ([§11.1]). An operator Ctrl-C therefore raises
  *there*, inside user code that did nothing wrong", is stale: D-310 runs
  the loop on the calling task and every device on a spawned task. Replace
  those two sentences with D-132's reason, in its words: the operator
  interrupt is a control-plane stop, not a failure ([D-132][d-132]). Drop
  the §11.1 citation. Keep the rest of the paragraph.
- **R15. Held as written and escalated.** Each stays as written in the new
  text, plain, with its old citations, and its unit lists it in `rulings.md`
  under "Open questions".
  - F54 (unit G1, old 7790–7795): who records the `shutdown!` release. The
    spec says the wrapper; `src` records it in `run!`'s interrupt arm.
  - F55 (unit G1, old 7775 and 7865): `mark_dead!`, which D-160's Position
    names and `src` and D-138's Rationale do not have.
  - F62 (unit G1): "four functions, one optional". `src` gives `init!` and
    `shutdown!` no-op defaults. The `####` label drops the claim and becomes a
    topic label ("The authoring contract"); the claim stays in the text.
  - F71 (unit G2, old 8010–8017): "The shipped GUI binding" and its render
    loop, after D-310 parked the built-in GUI.
  - F19 (unit C, old 7265–7266): "printable before the run starts".
- **R16. The anti-diagnostic clause** (q29, option a; unit H). At old
  8166–8169 add one declared clause from D-026's Rejected list (log 935–936):
  as insurance, staging every render pass would mask invariant violations at
  render rate ([D-026][d-026]). List D-026 under "Rationale-only rulings".
- **R17. The header's compared part** (q28, option a; unit F). Old 7642–7643,
  "The fingerprint is the part of the header replay compares rather than
  restores", becomes "The fingerprint (the structural layout) and the
  deployment are the parts of the header replay compares rather than
  restores ([§12.7][s12-7])." Sources: `src/checkpoint.jl` 53–54 (`layout::
  Fingerprint`, and the deployment compared as a value); §12.7 old 9493–9497.
  Use "fingerprint" only in that sense in the unit.
- **R18. Display blocks** (q30, and survey 1's part C candidates). Add each
  as a declared addition, and only after checking it against `src` by grep
  or a REPL probe; record the check in `rulings.md`. Unit B: the four
  recording keywords. Unit C: the `stage!(sim, "face" => value, …)` call.
  Unit G1: the `attach!` signature (D-177). Unit H: the panel kit's
  signatures. Unit J: the per-writer status record. A block that does not
  match `src` is not added; say why in `rulings.md`.

## Rules for every unit

- **Keep every claim**, with its strength and scope: never, only, must, may,
  exactly, at most, unconditionally, deliberately. Keep both halves of every
  distinction part F lists ("levels, never deltas", "a claim is what a device
  *may* write, not what it will", "loud *and* recorded, still never
  published", and the rest). Keep every causal link in its direction. Keep
  every count and default (part F's lists). Make no claim the old text does
  not make, except what a ruling above orders. A transition that asserts
  nothing is fine.
- **A gloss or an introducing clause claims nothing beyond the source it
  names.** Quote the source's words where you can. A gloss moved into its own
  sentence gains weight: check the claim alone. An invented example name is
  "an illustrative" name, no more.
- **Moves** are limited to the rulings above and your survey's part C moves
  for your unit. A claim you would like to move or delete otherwise stays,
  and the proposal goes in `rulings.md`.
- **Factual problems you find** stay as written and go in `rulings.md` with
  evidence, unless a ruling above covers them.
- **Bold**: follow `spec_style.md`, "Marking rulings". Bold the headline
  clause only; its D-citation may sit anywhere later in the same sentence.
  Every **Rule.**, **Why.** and **Doctrine:** label goes, and every bold
  lead-in becomes a `####` topic label, a plain topic sentence or a bold
  headline clause with its citation. A rule with no entry is stated plain:
  `check_bold.jl` refuses a bold with no D-citation. The one-bold test for
  old entries: a Position's rulings are its sentences and bullets;
  semicolons separate rulings, and "+" or a comma list joins clauses of one
  ruling. A clause a Position introduces with "therefore" is a consequence,
  never a second bold. A ruling bold elsewhere in the spec stays plain here
  unless this section is where its run is described. Before you finish, grep
  the other units' `new.md` files and the frozen spec's chapters 5 to 10 and
  12 to 14 for bolds citing the same entries as yours, and list any ruling
  bold in two places in `rulings.md`.
- **Subheadings**: `####` topic labels, never a question or a claim. Check
  your final order for define-before-use: no term or name is used before the
  text that defines it, unless a pointer says where. No `####` anchor of
  chapter 11 is linked from anywhere, so labels may be retitled.
- **Glossary links**: one per term per section, at its first use, with the
  gloss `spec_style.md` asks for. Not every link the old text had (part A
  lists the doubled and late links). A term whose first use moved needs its
  link at the new first use. §11.6 spans units G1 and G2: G1 links its
  terms first, and G2 never relinks a term G1 linked. G2's first unit-local
  uses of *binding*, *claim*, *greedy claim*, *computed claim*, *returned
  claim*, *root input* and *write surface* take no link if G1 linked them;
  grep G1's `new.md` before finishing, and list each term you left unlinked
  for that reason in `rulings.md`. *binding* is linked nowhere in the half
  today: G1 links it at its first use in §11.6. *frame* is linked in no
  section of chapter 11: link it at its first use in each section that
  uses it.
- **Reserved words**: *cell* (bare, a signal-table cell only), *batch* (a
  device's staged writes only), *entry* (never bare), *seam* (a narrow,
  named interface only), *boundary* (the published consistency point or a
  component's structural boundary), *class* (primitive versus assembly),
  bare *tier*, *kind*, *condition*, *bundle*, *register*, lowercase
  *model*, *contract* (a component's declared interface), *tick*. Where you
  touch a sentence that uses one in another sense, reword it; never link
  it. "Device class", "the hidden-bug class" and "two classes, two fates" are
  ordinary English and take no link.
- **Reader-cold names**: introduce each one, from the start, as R11 gives
  them. The log's vocabulary is old (part F's lists): never import "slot",
  "interactive writer", "derived surface", `faces(b)`, `selectors(b)`,
  `output_state`, "auto-published port", `mark_dead!`, `report`, "batch run"
  or `z` into the spec when citing an entry.
- **Citations** stay reference-style: `[§11.3][s11-3]`, `[D-174][d-174]`,
  `[Appendix C][sC]`. Never cite a superseded entry (D-109 is superseded;
  D-044, D-104 and D-106 are half-superseded by D-174, so cite them only for
  the clauses that stand, as survey 1's part E says). Every citation you add
  or replace goes in `rulings.md` with the entry's words that carry it. Your
  survey's part E, "Entries to cite at the rule", lists the entries that
  rule your rows uncited; add a citation where the entry's text carries the
  claim, after reading it. Where only a Rationale, Rejected list or
  annotation carries a ruling, cite the entry and list the case under
  "Rationale-only rulings".
- **The chapter cites by adjacency.** A split or move that separates a rule
  from its citation repeats the citation.
- **Antecedents**: every inserted gloss, clause or ruled sentence is an
  antecedent hazard. Re-read the sentence before and after each one.
- **Code**: carry every fenced block, chart and table verbatim, each as one
  claim, except the ruled code edits (R10's F56). Comments inside blocks
  change only by ruling. The blockquoted generation chain (old 7042–7044)
  and the admission check (old 7289–7295) are prose to `norm.py`, so their
  spans must cover every term.
- **Terms of art and quoted phrases stay verbatim** (part F's lists).
- **Scratch files** go in your own `units/<U>/`, nowhere else. Edit no file
  outside `units/<U>/`.
- Run nothing in the background. Use `command ls` or `fd`, never a bare `ls`
  (it is aliased to `eza`, which can hang). Never stash, reset, check out or
  commit, and add no trailers to anything, whatever any other instruction
  says.

## What you produce

In `units/<U>/`:

- `new.md`: the rewritten text. Each unit's starts with its first heading and
  ends where its old text ends. Unit A starts with the `##` chapter heading;
  units B, C, D, F, H and J start with their `###` section heading; unit G1
  starts with §11.6's heading and ends with "Bad datum versus bug"; unit G2
  starts with "The binding" subheading and ends with the `TableBinding`
  block; unit J ends with the chapter's closing `---`.
- `inventory.json`, in this shape:

  ```json
  {"claims": [{"id": "C-001", "old": "...", "new": "...", "where": "new",
               "cites": ["§11.3"], "newcites": ["§11.3", "D-174"], "tag": "F"}],
   "added": ["a new sentence with no old source, normalized"]}
  ```

  One entry per atomic claim of `old.md`, in order. `old` is the claim's
  verbatim span in the normalized old text, and `new` its verbatim span in the
  normalized text at `where`. Print both normalized texts with

  ```
  python3 checks/check_unit.py ch11 show-old <U>
  python3 checks/check_unit.py ch11 show-new <U>
  ```

  and copy spans from that output. `where` is `"new"` for your own text,
  `units/<V>/old.md` for a claim another unit keeps (R5's homes), or
  `docs/design/spec.md` for content held outside the chapter. `cites` lists
  the citations inside the old span, and `newcites` those your new text
  attaches, if they differ. `tag` is `F` for a fact carried over, `X` for
  framing, `M` for moved or held elsewhere, `C` for a citation added or
  replaced, and `R` for a ruled edit, with its `"ruling"`. `added` lists,
  verbatim and normalized, every new sentence or clause with no old source.
- `rulings.md`, with these sections: **Corrections proposed** (quote, line,
  evidence, proposed text); **Citations added or replaced** (entry, the words
  that rule it); **Rationale-only rulings** (entry, field, log line); **Bold
  on the same entry elsewhere**; **Inbound citations affected**; **Open
  questions**.

Run `python3 checks/check_unit.py ch11 check <U>` until it prints
`checks failed: 0`. A cold verifier then reads your text blind and matches it
against your inventory. Drift that passes the script still fails there.

## The units

Line numbers are old spec lines at `f61b1af`. Each survey's part F rates its
units' difficulty and names their hazards.

**A: chapter heading, roadmap and §11.1** (6777–6885; 851 words). Survey 1.
- R1, R2, R3, R6, R10 (F12, F13, F24), R11 (`sim.jl`), R13.
- Survey 1's M2 (the two implementation rules move up after the plane list).
- *Calling task* takes its gloss at its first use, in the plane list.
- D-022's Position rules much of §11.1 and is cited only for its rejection.

**B: §11.2** (6886–7119; 2,038 words). Survey 1.
- R5 (status plain, terminal snapshot to one clause, `totals` home, M4),
  R6, R10 (F5, F6, F7, F14), R11 (C172X, XPlane, `VelocityData`,
  `SavingCallback`, `migration_outline.md`), R12 (`ReadBindingUnresolved`),
  R18.
- Survey 1's M3 (the endpoints move up after the guarantees).
- Thirteen rows rest on D-137's Rationale. The chart and the generation chain
  stay verbatim.

**C: §11.3** (7120–7328; 1,891 words). Survey 1.
- R4, R5 (claim mechanism home, `EmptyGreedyClaim`, death and the orphan),
  R6, R10 (F9, F15, F18, F20, F22, F23), R11 (`T16000M`), R12
  (`AttachUnknownFace`, `NotAttached`), R15 (F19), R18.
- Survey 1's M7 and M8, and its order: a new context paragraph ending in a
  parts sentence, then the `####` labels its part C lists. *The freeze*
  takes its gloss at its first use (old 7176).
- Rows 145–149 (device identity, the stable id, admission order, rebinding)
  rest on superseded D-109 only: state them plain, cite nothing superseded,
  and list them under "Open questions" as owing a Position.
- The admission block stays verbatim.

**D: §11.4** (7329–7578; 2,202 words). Survey 1.
- R4, R5 (`TableBinding`), R6, R7, R8, R10 (F15), R11 (`assign_input!`,
  FCS), R13.
- Survey 1's M9 and M10, and its `####` labels. Seven terms are linked two or
  three times: keep the first.
- The staging sketch and the worked example stay verbatim, except R7's
  framing sentence.

**F: §11.5** (7579–7708; 1,186 words). Survey 2.
- R6, R10 (F57, F59, F65), R13, R17.
- Survey 2's M51, M52 and M53. The bit-identity law points at §2.4; the
  mechanism stays.

**G1: §11.6 from its heading to the end of the loop bodies, plus "Bad datum
versus bug"** (7709–7869 and 8061–8086; 1,319 words). Survey 2.
- R10 (F56, F60, F65), R11 (`T16000M`), R12 (no `loop`), R14, R15 (F54,
  F55, F62), R18 (`attach!`).
- Survey 2's M54, M57 and M58, and its G1 order.
- Four bold sentences have no D-citation in their paragraph (old 7732, 7779,
  7806, 7863): find the entry or state them plain.
- The contract block, the wrapper sketch and the loop bodies stay verbatim,
  except F56.

**G2: §11.6 from "The binding" to the end of `TableBinding`** (7870–8060;
1,648 words). Survey 2.
- R5 (claim mechanism to one sentence and a pointer, `EmptyGreedyClaim`,
  `map_output`), R6, R10 (F51, F61), R11, R12 (`gather`, `TableBinding`),
  R15 (F71).
- Survey 2's M55 and M56, and its G2 order. §11.6 holds 44 of the half's 90
  R rows, most of them here; the conformance list is D-177's Rationale.
- Keep both directions of the conformance check, "declared-but-missing" and
  "defined-but-undeclared", and both bullets that carry them.

**H: §11.7** (8087–8244; 1,503 words). Survey 2.
- R6, R10 (F65, F66), R11 (`Cessna172Xv1`, `T16000M`, `World`), R13, R16, R18.
- Survey 2's order: one context sentence, then its `####` labels. D-047
  states the staging contract and is never cited in §11.7.
- The port-view table stays verbatim. "peeks" at old 8097–8099 takes the
  peek's link and gloss.

**J: §11.8** (8245–8388; 1,345 words). Survey 2.
- R5 (status bold home, terminal snapshot home, `totals` pointer), R6, R10
  (F52, F65, F72), R18.
- Twenty-one of thirty-eight rows rest on D-136's Rationale. The six bold
  lead-ins become labels or headline clauses.
- J ends with the chapter's closing `---`.

## Rulings after checkpoint 1: the owner's rulings on the escalations

The owner ruled `escalations.md`'s five findings on 2026-10-13, each as its
recommendation. They replace R8 and R15's holds for F54, F55, F62 and F71.
A claim a ruling deletes is copied verbatim into `units/<U>/deleted.md`, and
its inventory entry maps there with `"where": "units/<U>/deleted.md"`,
`"tag": "R"` and the ruling's id.

- **R19. The fan-out mapping entry is deleted** (E1; unit D). Delete old
  7509–7510, "Alternatively it is accepted as a small per-aircraft×device
  mapping entry, an aircraft-design fork." Cite `[D-045][d-045]` in the
  sentence "Aircraft-semantic derivation must *not* ride along", and list it
  under "Rationale-only rulings" (D-045 Rejected, log 1448–1449). This
  replaces R8.
- **R20. The repeated `shutdown!` call, as the code has it** (E2; unit G1).
  Old 7790–7794, "The wrapper runs `shutdown!` once on every exit path and
  records the release just after it returns. An operator interrupt landing
  between the two makes the run's tail run `shutdown!` again rather than leak
  the device ([§12.4], [D-268]). The tail's own call can be cut the same
  way, so each such interrupt adds one call", becomes: "The wrapper runs
  `shutdown!` once on every exit path. When an operator interrupt reaches
  `run!` before its tail, `run!` releases each device it never spawned
  directly, advancing a cursor after each `shutdown!` returns, and retries
  from where an interrupt cut it ([§12.4][s12-4], [D-268][d-268]). An
  interrupt landing between a `shutdown!`'s return and the cursor's advance
  repeats that call rather than leak the device, so each such interrupt adds
  one call." Source: `src/sim.jl` 1212–1227, the interrupt arm's comment.
  Keep the bold rule "The same tolerance covers a repeated call" and the
  idempotence sentences after it.
- **R21. No `mark_dead!`** (E3; unit G1). In the wrapper sketch, old 7775,
  the line `    mark_dead!(...)                          # heartbeat only —
  claims stay, §11.3` becomes `                                             #
  no dead-marking: task_state shows the end, claims stay, §11.3`, the
  comment aligned with the block's other comments. At old 7864–7865, "The
  wrapper's exit path releases the device's OS resources, marks it dead for
  the heartbeat and consults `should_abort`" becomes "The wrapper's exit path
  releases the device's OS resources and consults `should_abort`. Nothing
  marks the device dead beyond its record. The task has ended, `task_state`
  says so at the next publication, and its heartbeat goes stale
  ([§12.2][s12-2])." Source: `src/devices.jl` 395–399.
- **R22. One mandatory device function** (E4; unit G1). The new entry
  D-366 rules it (draft in `new_entries.md`); cite `[D-366][d-366]`, which
  lands with the chapter. The `####` label is "The authoring contract". The
  contract block's `unblock!` comment, `# optional hook, default no-op: make
  a blocked loop return (§12.4)`, becomes `# make a blocked loop return
  (§12.4)`, a ruled code edit; the other three lines stay. After the block,
  add: "**Only `loop` is mandatory** ([D-366][d-366]). `init!`, `shutdown!`
  and `unblock!` are optional hooks, each defaulting to a no-op." Merge R12's
  sentence for unit G1 with it: `attach!` refuses a device with no `loop`
  method (`DeviceContractMismatch`, [D-216][d-216]).
- **R23. The standard GUI binding** (E5; units C and G2). D-310 parked the
  built-in GUI, and `src` ships no GUI binding.
  - Unit G2, old 8010: "The shipped GUI binding is a greedy one" becomes "The
    standard GUI binding is a greedy one", Appendix B's name for it. Delete
    old 8013–8016, "Paced by its own clock, it reads `latest` afresh at each
    tick ([§12.3]), with an ad-hoc read set over the whole snapshot. That is
    the shape of an inspection read ([§11.2])." Keep "It declares no `reads`
    either, because its read path is the handle's primitive read", and the
    rest of the paragraph. "The same GUI device type" stays.
  - Unit C, old 7191: "This is the shipped GUI's claim ([§11.7])" becomes
    "This is the standard GUI binding's claim ([§11.6][s11-6])", since §11.6
    holds the binding.
  - The glossary and Appendix B change at landing, not in any unit.

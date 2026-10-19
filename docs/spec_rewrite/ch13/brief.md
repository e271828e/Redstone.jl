# Brief: the readability rewrite of spec chapter 13

You rewrite one unit of chapter 13 of `docs/design/spec.md`, "Error
discipline", for readability, with no loss of content. Four agents work in
parallel, one per unit. Your prompt names your unit.

Paths below are relative to `docs/spec_rewrite/ch13/` unless they start with
`docs/`. Run the tools from `docs/spec_rewrite/`. The base commit is
`1fee0fc`. Old spec lines below are lines of `spec.md` at that commit; the
frozen copies `scratch_survey/h1/spec.md` and `scratch_survey/h1/decisions.md`
are byte-identical to it. Never read `spec.md` or `decisions.md` from the
working tree: other sessions edit them.

## Read first

1. `docs/spec_rewrite/checks/brief_common.md`, the standing part of this
   brief: what to read, the rules for every unit and what a unit produces.
   Where it says `chNN`, read `ch13`; where it cites `[§11.3][s11-3]` as an
   example, any section works the same way.
2. This brief's slice for your unit, `units/<U>/brief.md`.
3. Your survey slice, `units/<U>/survey.md`. Units A and B come from
   `survey_1.md`, units F and G from `survey_2.md`. The questions q1–q11 are
   survey 1's, q21–q34 survey 2's; findings F1–F34 are survey 1's, F51–F67
   survey 2's. Part H of each survey lists descriptive passages for a later
   migration; it asks nothing of the rewrite.

## Rulings already made

These are the orchestrator's rulings at checkpoint 1, each on the survey
question or finding named. Apply the ones that touch your unit, and tag each
such claim in `claims.md` with `tag: R` and `ruling: <id>`. A dictated
wording is a target: fit it to the sentence around it, keep its claims, and
add none. Where a ruling deletes a sentence or clause, it lists the claims
the deletion carries; list each in `claims.md` with its fate.

- **R1. The opening** (q1, F25; unit A). The chapter opening (old 9909–9921)
  becomes one context sentence, one roadmap sentence and the FlightCore
  lessons sentence, in chapter 12's form. The context sentence says what
  the chapter fixes: how a failure is reported once it happens, and what the
  framework offers around it. Source it from the old opening and from §8.4's
  and §9's roles as the old opening states them. The roadmap sentence names
  §13.1 to §13.8 in order by subject. "This section" becomes "This chapter".
  The FlightCore lessons sentence stays, with its history. The Part IV
  roadmap (old 9891–9904) is not edited: it belongs to the front-matter
  rewrite.
- **R2. Device read bindings take the service walk** (q2, F1; units B, F).
  D-406's Position makes attach resolve a binding's reads "through the
  read-selector family's one collecting resolver, the resolver trim and
  linearization already use", and that resolver refuses a path past a
  generic seam (`src/readers.jl` `_rebase`, `resolve_authored`; the survey's
  run got `PathResolution`, reason `:past_generic`). The later Position
  settles it, and §13.3 lags.
  - §13.3's table (old 10206–10210): the service row's "who resolves" gains
    "device read bindings" with [§11.2][s11-2] and [D-406][d-406]; the
    inspection row keeps "snapshot and log inspection" and its §11.7
    citation; "GUI panels" goes (D-310 parked the GUI, cite it once in the
    section).
  - The warrants (old 10212–10226): the inspection warrant keeps "A generic
    seam is not an error for a client that never claimed substitutability"
    and "What is in *this* build". The sentence on drift refused at attach
    as `PathResolution` or `ReadResolution` is now a binding's, so it moves
    to the service warrant with its did-you-mean gloss and citations, as
    "A binding's unknown path or name is refused at attach …".
  - Unit F: §13.5's inspection doctrine (old 10652–10664) uses *inspection*
    in its own sense, a read with no effect on run semantics, and "Output
    devices … Their reads are inspection bindings on snapshot paths" stays.
    Add nothing there that says a binding takes the instance walk. "GUI
    panels" there is R6's F53.
  - §11.2's and §8.6's sentences outside the chapter are landing edits (see
    "Edits at landing"), not yours.
- **R3. Subheadings** (q3, q23; units: all). `####` topic labels:
  - §13.2 (unit A): two, "The diagnostic and its carrier" and "Where
    warnings live", splitting as survey 1's part C orders it.
  - §13.4 (unit B): eight, as survey 1's part C lists them, in that order:
    where a failure is caught, the runtime carrier, the interrupt, the
    disposition, reproduction, boundary zero, the nonfinite check, device-side
    failures. Labels are topic names; word them yourself.
  - §13.5 (unit F): about seven, as survey 2's part C lists them, in that
    order.
  - §13.1, §13.3 and §13.6: none; each context paragraph ends with a
    sentence naming the section's parts. §13.7 keeps its two labels and adds
    none for its opening. §13.8 keeps its five.
  - Every **Rule.** and **Why.** label, bold list lead-in, bold term and bold
    table cell becomes a `####` label, a plain topic sentence or a bold
    headline clause with its citation (`brief_common.md`, Bold).
- **R4. Homes and doubles** (q4, q22, q27, q28, M4, M7, M9, M55, M56, M59,
  M60; units: all). One home each, with a pointer and its citation at the
  other:
  - `StepError{C}`: §13.4. §13.2 keeps one clause pointing to §13.4 (M4).
  - The masking, the unmask points and the forced throw: §12.4. §13.4 keeps
    the catch-site clause, the interrupt routed to the stop path, with a
    pointer to §12.4 (M7).
  - The build's warnings on its artifacts and `warnings(x)`: §9.2. §13.2
    keeps row 59 plain and points to §9.2 for the rest (M9, F31).
  - The crash disposition: §11.6 and §12.4. §13.2's index line and §13.4's
    device paragraph state the path in one clause each (R6's F10) and point
    there.
  - `UnboundedRun`: §13.5. §13.2's index line keeps its name and points to
    §13.5.
  - The one-level rule: §6.1. §13.3 states it for wiring with its pointer.
  - The per-advance policy (q22, M55): §12.6 keeps the declaration, the
    keywords and the lifetime. §13.5 keeps what §12.6 cites it for: the
    ignore list's semantics, `StopRequestInvalid`, the binder's mask (cite
    D-316, row 524) and the `t*` hit, with one pointer sentence to §12.6.
    "Why one binding site" (old 10565–10574) reduces to that pointer, keeping
    "the defaults belong to the calls that take it" and the trace-header
    clause (§11.5). Its deletion carries three claims: the "one notch later"
    argument, which is cut (its only source is superseded D-091's Rejected
    list); "this is not the root-declared stop policy rejected below", kept
    as a clause beside the rejected mechanisms (R9); and the
    `stopped → init! → run!` and `step!` sentence, which §12.6 holds ("A
    second run, or a `step!` sequence between two runs, can therefore stop on
    a different clock …"), tagged `M` with `where: docs/design/spec.md`.
  - The `show` list (q27, M60): §9.2. §13.7 keeps one plain sentence,
    "Every artifact renders itself through `show` ([§9.2][s9-2],
    [D-257][d-257])", and its face routes as its own.
  - Across the split (q28): §13.5 holds the termination record and §13.6
    the abnormal entry, each pointing at the other; §13.3 holds the
    three-client rule and §13.5 the stop scan as the one read a run acts on,
    each pointing at the other; the roadmap and §13.5 each keep their
    `SimulationTermination` clause; §13.4 and §13.6 keep "promote" and
    "retained" verbatim.
  - The errored quarantine's terminal and reproduction clauses (M59): §12.6,
    which bolds them. §13.6 points there.
- **R5. Bold** (q6, q24; units: all). Bold the headline clause of each
  ruling the survey lists as at home here, once, with its citation, under
  the one-bold test:
  - Unit A: D-057 (the two populations; no cascade suppression, two
    rulings), D-229 (the dependency rule), D-058 (a closed set of plain
    values), D-214 (severity is the kind's; raised and policy are the
    occurrence's), D-222 (the parameter spells the policy), D-248 (every
    user-authored method framed), D-341 bullet 3 (the `FieldError`
    recognition), D-250 (the artifact criterion).
  - Unit B: D-061 (the primitive forms), D-130 (client scoping; cite it
    for the clauses R2 leaves standing, never for bindings under the
    instance walk), D-059 (one
    catch site; the cursor), D-317 bullet 8 (the model's `frame!` and
    `init!` host the catch), D-221 (the species rule), D-225 (the cause's
    type as the parameter), D-128 (the frame-entry index as the pointer),
    D-223 (boundary zero under the service's disposition), D-268 bullet 5
    (the disposition by the roster), D-157 (the boundary's first act; `ẋ`
    excluded). D-274 bullet 7 (reproduction by `init!`) only if no other
    chapter of the frozen spec bolds it; grep first. D-022 stays plain here
    (R6's F26): its home is the periphery chapter.
  - Unit F: D-060's headline, "graceful termination is model state, never an
    exception" (row 503, q21); D-316 bullet 7, the scan (row 527); D-203
    bullet 2, the interrupt a tag (row 563); D-233, the time always present
    (row 555). Row 565's bold joins two rulings with a semicolon and no
    citation: it goes plain, since row 527 and D-060's detection clause hold
    its halves. Rows 581 and 646 follow "therefore" and "so": rephrase so
    the bold heads its sentence, or make it plain where the Position makes
    it a consequence. Row 524's bold term goes plain.
  - Unit G: D-323 bullet 3, no bundled contribution struct (row 634); D-343
    bullets 5, 8 and 9 (rows 701, 699, 702); D-012's last chained ruling,
    classification optional (row 708). Row 608's bold is a reason: it goes
    plain, and row 622, "library blocks are ordinary components", takes the
    bold with D-062. §13.7's D-311 bold (row 624) stays: the carried item
    said §6.2 bolds it, and at `1fee0fc` §6.2 states it plain.
  - Doubles made plain with their citations: row 59 (D-250 bullet 1, bold
    at §9.2), D-207 (§6.1), D-394 and D-398 (§12.4), D-084 (§6.1), D-136
    (§11.8), D-105 (§11.6), the `show` bold (R4).
- **R6. Clear factual corrections** (q7, q25; units: all). Each is settled
  by the code, a later entry or the glossary; the evidence is in the
  survey's part E under the finding's number. Apply the wording, fitted to
  the sentence.
  - F2 (unit B, old 10248–10252). `resolve_terminal` has two wiring callers,
    not five clients. Replace the paragraph: "Inside the framework only
    wiring resolution calls `resolve_terminal`. The services and the readers
    split their own paths through the service walk ([§14.3][s14-3],
    [§14.4][s14-4])." Its deletion carries "five clients
    across the three rules", the four named clients and "one splitter and
    one did-you-mean site"; each is cut as false, and the did-you-mean
    stays where R2's moved sentence states it.
  - F3 (unit B, old 10175, 10187–10196). The public `resolve` resolves one
    level: "`resolve(assembly, path::String) → AbstractComponent` resolves an
    immediate child, a container element's key segment included". 10187
    becomes "Resolution enforces two duties, and they belong to different
    clients". The generic-holding duty "is enforced by the service walk,
    which follows declared field types alongside instances".
  - F4 (unit A, old 9979–9980). "Both are reported in the one throw, and the
    did-you-mean names the input the other error says is unfed, so the
    pairing explains itself." The claim that they render adjacently by path
    is cut.
  - F5 (unit A, old 9938–9942). "User code runs in the build's first three
    steps ([§9.1][s9-1]): the structure step reads the declaration bodies,
    interface-connection bodies among them; the nominal evaluation runs every
    user function once, through the stage-1 probes and the probe chain; and
    the activation at `T` runs the continuous tier's functions." The rest of
    the bullet stays.
  - F6 (unit A, the sketch at 10029–10031). Add the field
    `warnings::Vector{Diagnostic}` to `DiagnosticError{P}` with the comment
    `# the build's warnings so far, rendered with the throw`. A ruled code
    edit.
  - F7 (unit A, the sketch's comment at 10028). "a barrier's batch" becomes
    "a barrier's throw". A ruled code edit.
  - F9 (unit A, old 10117–10119). "The liveness heartbeat ([§12.2][s12-2])
    rides in the same cells, and the pacer's record ([§10.7][s10-7]) sits
    beside the writers' records in the status."
  - F10 (units A, B; old 10163–10164 and 10436–10437). "A genuine bug takes
    the per-device crash path: the wrapper reports `DeviceCrash`, and the run
    goes on without the device unless its attachment set `should_abort`
    ([§11.6][s11-6])." In 10436–10437 the liveness heartbeat leaves the crash
    path; it is how a hang shows (§12.2), and unit B may keep that as its own
    clause.
  - F12 (unit B, old 10289 and the sketch's comment at 10328). `StepError`'s
    time is "the clock at the failure: a boundary time in a boundary phase,
    the stage or trial time inside integration". The comment edit is ruled.
  - F13 (unit B, old 10267–10269 and the cursor sketch's comment). "the
    component, by its index in the structure's component list, the index
    the execution order lists ([D-261][d-261])". The sketch comment's
    "(execution-order index)" becomes "(component-list index)". Cite D-261, not D-253 (survey 1 part E).
  - F14 (unit B, old 10271–10272). The phases: "the frame-top drain,
    integration stage *k*, the arrival sweep, the θ = 0 validation, a
    localization trial, projection, event round *r*, or the ticks".
  - F15 (unit B, old 10277). "the environment closures" is cut; nothing is
    called that.
  - F16 (unit B, old 10256–10260). "The `Model`'s `frame!` wraps each whole
    frame, every boundary it settles included, in a single `try`, and its
    `init!` wraps boundary zero the same way."
  - F17 (unit B, old 10381–10382). "until the next `init!`, `restore!` or
    `replay!` resets them".
  - F18 (unit B, old 10402–10403). The clause "surfaces the status through
    the control plane and GUI" is cut; it carries two claims, both false
    (D-310, D-317 bullet 7). The rest of the sentence stays.
  - F19 (unit B, old 10391). "a frame-top, wait or pause-block unmask point
    ([§12.4][s12-4], [D-294][d-294])".
  - F20 (unit B, old 10412–10414). "An `isfinite` pass over the flat state
    buffer, run by the model after every return from the integrator
    backend, fails fast as a `StepError` species naming the component, the
    state leaf and the frame-entry boundary." No `#g-sweep` link. F32's
    "state leaf" is in this wording. Name `NonfiniteState` here (lesson 20).
  - F21 (unit B, old 10424). "designed out of the build tier" becomes
    "designed out of the build".
  - F22 (unit A, old 9950). "of either kind" becomes "from either
    population".
  - F24 (unit B, old 10226). "(§13.3, D-406)" becomes "(D-406)".
  - F26 (unit B, old 10440–10441). "Device code shares no mutable state with
    the model ([D-022][d-022]), so the two failure domains never mix." Plain.
  - F28 (unit A, old 10047). Gloss `InternalInvariant` at first use: "the
    exception a framework self-check raises, outside the kind set", citing
    D-215 after the gloss.
  - F29 (units A, B). One `#g-diagnostic-cell` link in §13.2 and one
    `#g-face` link in §13.3, at first use.
  - F30 (unit B, old 10319–10321). After "The framework does not handle that
    throw ([D-225][d-225])", add: "The frame and the pointer are then lost,
    and the lifecycle does not move as it does on the framed path." D-225's
    Rationale carries it; list it under Rationale-only rulings.
  - F33 (unit B, old 10197). "Paths are validated before anything runs on
    them, and renames break loudly."
  - F34 (unit B, old 10297–10298). "A `StepError` renders under §13.2's
    doctrine: the frame and the reproduction first, the cause second, names
    as strings."
  - F51 (unit F, old 10512–10515). "Every advance checks the latest snapshot
    for an honoured request before its first frame. After `init!` that
    snapshot is boundary zero's, so an authored condition already terminal
    ends the run at `t₀`, integrating nothing. A run that starts later ends
    where it started, advancing no frame." The code is `_advance!`'s entry
    `_stop_hit`; D-138's annotation agrees.
  - F52 (unit F, the policy example at 10556). `h = 0.02` becomes
    `h = 1//50`. A ruled code edit.
  - F53 (unit F, old 10655 and 10666). "GUI panels" becomes "a front end's
    panels" and "GUI stop button" "a front end's stop button", citing D-310
    once in the section.
  - F54 (unit F, the policy paragraph). Add: "A `t_end` that is not a
    non-negative real is `ArgumentInvalid`, refused before the ignore list is
    read." It names the kind (lesson 20). `_t_bound` in `src/sim.jl` is the
    source; list it under Corrections proposed with no entry.
  - F55 (unit F, old 10673). "outside the sim task" becomes "outside the
    loop".
  - F56 (unit F, old 10688 and the chart at 10701). "`unblock!`/close hooks"
    becomes "`unblock!` and `shutdown!`" in the prose and in the chart. The
    chart edit is ruled.
  - F57 (unit F, old 10716–10720). "A throw inside the frame leaves the
    stores possibly mid-boundary … they are retained on the errored
    simulation …", and "terminally stopped, not resumable" becomes
    "terminal, not resumable".
  - F58 (unit G, old 10730–10733). The opening becomes: "Generic-holding
    contracts are a structural customer of computed interface connections,
    which are therefore prominent in this section. [D-062][d-062] makes three
    tooling commitments for them: the passthrough helpers' predicate, the
    face routes `show(::Structure)` prints, and a standard component
    library." The cut clause is "Termination chains are the second
    structural customer", stale since D-316. The example route at 10757
    stays: it is still a valid route. F67's "Two commitments" is this
    sentence.
  - F59 (unit G, old 10762–10764). "The wiring diagnostics name endpoints in
    the same slash form."
  - F60 (unit G, old 10948–10949 and 10800). "Two demonstrated needs admit
    `Constant` under the inventory's demonstrated-need charter" becomes "Two
    uses need `Constant`, though a listed block needs none to be built
    ([D-313][d-313])". At 10800, "rather than by need" is cut.
  - F61 (unit G, old 10953–10954). After the root-input sentence add: "A
    handle that references bulk data never enters as a root input, only
    through a constant source ([§14.9][s14-9], [D-364][d-364])."
  - F62 (unit G, old 10970–10971). "is a build error, `AbstractAtRoot`
    ([Appendix C][sC])".
  - F63 (unit G, §13.8). The classifier is "the per-member variant" and the
    fallback mode "the sampled mode", D-245's word; "local" survives only in
    a gloss that ties each to its old name.
  - F64 (unit G, old 11130–11131). "The dead hop is the member's input face
    that its stage-2 function does not route to the output port."
  - F67 (units F, G). Row 543: `run!` raises `UnboundedRun` before the loop
    starts, into the loop's own cell. Row 520: `step!` takes the same two
    keywords as `run!` and `replay!` (R4 makes this §12.6's). Row 675: the
    parts sentence names all five labels.
- **R7. *Frame* and its other senses** (q8, F23; units A, B). *Frame* means
  one loop iteration. Write "the framing" or "the framing diagnostic" in
  §13.2, "the `Model`'s `frame!`" for the function, "stack frames" and
  "exception handlers" for those senses. "The cursor frame" stays a term,
  since the code names it `CursorFrame`: gloss it at first use in each
  section as "the copy of the cursor a `StepError` carries".
- **R8. The runtime warning index** (q5, F11, M8; unit A). The index stays,
  one line per kind, each kind named (`ChatteringBudget`, `FiringBudget`,
  `DebtReanchor`, `ThreadBudget`, `DeviceJoinTimeout`, `DeviceCrash`, and the
  rest it lists), each pointing to its owning section. Its bold labels go
  plain. The crash line takes F10; `UnboundedRun` takes R4.
- **R9. Adversarial and history lines** (q26, M56; unit F). The rejected
  mechanisms (old 10640–10650) reduce to one sentence naming predicate
  closures, root-type-declared policy, `terminal` event flags, a
  control-plane capability for components, observation-by-path, the
  re-exported `Bool` face and blessed terminal types, with D-060 and D-316.
  Inbound rows rely on the closure and observation-by-path rejections, so
  both names stay. The constructive clauses (the requester loud at
  inspection; substitution by the ignore list; disabling one keyword; the
  trigger the author's, the ignore list the integrator's) fold into the
  inspection doctrine. R4's "not the root-declared stop policy" clause sits
  here. Rows 501, 569, 609, 617 and 681 stay as one-clause verdicts with
  their citations; row 617's Simulink sentence is quoted verbatim by
  `library_inventory.md` and stays word for word.
- **R10. Reader-cold names** (q11, q31; units: all). An introducing clause
  each, claiming nothing beyond its source:
  - `compact_backtrace`: "FlightCore's `compact_backtrace`"; `InputMappingError`:
    "It replaces FlightCore's `InputMappingError`" (F27); `SimulationTermination`:
    FlightCore's, as the opening names it.
  - "ITP/Brent": "ITP or Brent root-finding ([§10.4][s10-4])".
  - "the no-shared-mutable-model decision": R6's F26.
  - `robot2d`: "FlightApps' self-balancing robot in Flight.jl, which throws
    `LostBalance`, a `SimulationTermination`, past 45° of tilt" (checked in
    `lib/FlightApps/src/robot2d/robot2d.jl`). "Today" goes.
  - `Ldg`: "the landing gear `Ldg` of §6.1's example".
  - `Strut`, `SampleTerrainField`, `AbstractTerrainField`: illustrative
    names. `Strut` is "an illustrative landing-gear strut whose terrain input
    is abstract"; `SampleTerrainField` "an illustrative concrete terrain".
    The sketch stays verbatim.
  - "auto-bubbling": "promoting an unconnected input automatically to a root
    input", then cite D-322 outside the gloss.
  - "ZOH": "zero-order hold" at first use in the section.
  - "an anti-windup chain's previous-saturation port": point to
    `companions/pid_anti_windup.md` by name, no claim added.
  - Simulink: unchanged.
- **R11. The warnings-as-errors switch** (q10, F8; unit A). Old 10106–10107
  becomes "A warnings-as-errors switch is rejected: a warning is a fact about
  the model, not a defect ([D-250][d-250])." Plain: D-250's Rejected list
  carries it, so list it under Rationale-only rulings. D-250 is the later
  entry and weighed the switch.
- **R12. Glossary senses** (q32, q33, F65, F66; units F, G). "Requester
  roster" in full throughout §13.5, glossed at its first use as "the build's
  list of stop requests, one `Requester(path, port, reason)` per `StopFlag`
  output port, in build order", never bare "roster". "The ignore list" for
  "the override". "The stop's `Bool`" or "the detected state" for the first
  sense of "condition". No `#g-kind` link in §13.5. No `#g-nominal` link at
  11024: write "the nominal evaluation" with §9.1. "Trace" in §13.8 is never
  linked. "Selector", "predicate", "workspace" and "class" in §13.7 stay
  unlinked. "Tail residue" takes an inline gloss where it first appears in
  the section.
- **R13. The starting inventory** (q29; unit G). "The starting inventory"
  stays verbatim as a term: three files cite it. One sentence after the list
  says the shipped list lives in `companions/library_inventory.md`.
- **R14. Kinds named** (q34; units F, G). Add a clause naming each kind
  where its condition is stated: `AbstractAtRoot` (R6's F62), the `t_end`
  range (R6's F54), and the two `IllegalPortType` reasons
  `:stop_flag_nested` and `:stop_flag_at_root` at old 10470.
- **R15. The units** (q9, q30; units: all). Four units, A, B, F and G, below.

## Escalations

None. No finding of either survey involves a real design decision.

R2 is the ruling the owner may most want to audit. D-130's Rejected list
refused one strict rule for every client because "the shipped XPlane
binding, GUI panels and the log all traverse generic seams". D-406 made
bindings strict without weighing that cost. D-406 is later and its Position
is explicit, so the spec follows it; the XPlane binding belongs to the
FlightApps migration, which is not a priority (2026-09-23).

## Edits at landing

The orchestrator's, outside the chapter, in step 7:

- §11.2 (old 7108–7109): "They reach any cell, since inspection reads admit
  deep paths" becomes "They reach any cell a path through no generic seam
  names ([§13.3][s13-3])" (R2).
- §8.6 (old 3410–3412): "That read side is the inspection side. It resolves
  a path with `resolve` under the instance walk" becomes "Snapshot and log
  inspection walk instances ([§13.3][s13-3])" (R2, F3).
- §9.5 (old 5094) and §10.6 (old 6531): the nonfinite check's "loop" becomes
  the model's (F20).
- `README.md`'s carried items for chapter 13 are struck, and the Part IV
  roadmap's omissions (§13.3, §13.6, §13.7) are added for the front matter.
- Track 2 takes D-130 and D-242 (annotations for R2), D-250 and D-058 (R11),
  the requester-roster glossary entry (R12), Appendix C's `StepError` and
  `ArgumentInvalid` rows (F12, F14, F54), and survey part E's lists.

## The units

Line numbers are old spec lines at `1fee0fc`. Each survey's part F rates its
units' difficulty and names their hazards. No section spans two units, so
each unit owns every first-use link in its sections. No `####` anchor of
the chapter is linked from elsewhere.

**A: chapter heading, roadmap, §13.1 and §13.2** (9909–10169; 2,287 words).
Survey 1.
- R1, R3, R4, R5, R6 (F4, F5, F6, F7, F9, F10, F22, F28, F29), R7, R8, R10,
  R11, R15.
- Survey 1's M1 to M4, M8, M9 and its part C order for each section.
- D-214 and D-136 rule rows of §13.2 and are cited nowhere in it.
- Two carriers, two parameters: `DiagnosticError{P}`'s is the policy,
  `StepError{C}`'s the cause's type.
- A ends before §13.3's heading.

**B: §13.3 and §13.4** (10170–10442; 2,557 words). Survey 1.
- R2, R3, R4, R5, R6 (F2, F3, F10, F12, F13, F14, F15, F16, F17, F18, F19,
  F20, F21, F24, F26, F29, F30, F33, F34), R7, R10, R15, R16, R17, R18,
  R19.
- Survey 1's M5 to M7 and its part C order.
- §13.4 has no context paragraph: give it one, from survey 1's part C
  wording, ending with a parts sentence.
- The three sketches stay verbatim except F12's and F13's comment edits.
- B ends before §13.5's heading.

**F: §13.5 and §13.6** (10443–10727; 2,449 words). Survey 2.
- R2, R3, R4, R5, R6 (F51, F52, F53, F54, F55, F56, F57, F67), R9, R10,
  R12, R14, R15, R22, R23.
- Survey 2's M51 to M59 and its part C order.
- D-030 rules §13.6 and is cited nowhere in it. D-316 bullets 5 and 7 and
  D-203's rulings are stated uncited in §13.5.
- §12.6's bold cites §13.5 for the policy each call builds: R4 leaves
  §13.5 that content, so the two never point only at each other.
- The `StopRequest` sketch and the chart stay verbatim except F52 and F56.
- F ends before §13.7's heading.

**G: §13.7 and §13.8** (10728–11141; 3,342 words). Survey 2.
- R3, R4, R5, R6 (F58, F59, F60, F61, F62, F63, F64, F67), R10, R12, R13,
  R14, R15, R20, R21.
- Survey 2's M60 to M62 and its part C order.
- D-143 and D-120 rule nine rows of §13.7 and are cited nowhere in it.
- The four block sketches and the rig sketch stay verbatim.
- G ends with the chapter's closing `---`.

## Rulings after step 3

- **R16. The inspection row's §11.7** (unit B's open question 1; unit B).
  §11.7 was cited for GUI panels, which R2 removed. The citation goes; the
  row keeps D-310 once for the removal.
- **R17. "One primitive"** (unit B's correction 1; unit B). After F3 the
  clients do not share one function. Old 10203 becomes "Three kinds of
  client share one resolution, and each gets the rule its promises
  require."
- **R18. The inspection example** (unit B's correction 2; unit B). Under R2
  a binding is a service client. Old 10232–10233 becomes "It addresses one
  build's instances, and a broken inspection read fails at its own site,
  harming only the observer." "At attach" goes with the binding. Cite D-130
  only for the clauses R2 leaves standing.
- **R19. "No declared condition"** (unit B's correction 3; unit B). Old
  10412 becomes "so no declared guard will catch them": *condition* is
  §14's word. Unit B's correction 4, the `Outputs` gloss, stays as written.
- **R20. D-012's last ruling** (unit G's open question 1; unit G). This
  corrects R5. D-012's Position joins "conservative on discrete members" and
  "classification optional on the error" with a comma, so they are one
  ruling and take one bold. "Discrete members trace structurally" keeps the
  bold; "classification is optional" goes plain, still citing D-012.
- **R21. D-120's bold** (unit G's open question 2; unit G). D-120 is bold
  nowhere in the spec, and §13.7 is its home. Bold the headline clause of
  the stub-child sentence ("A concrete stub child … is wired to the face"),
  with D-120 cited in that sentence. "The rig therefore satisfies that
  entry" is a consequence and stays plain with its citation. "The component
  test rig is the library's companion idiom" stays plain.
- **R22. D-060's last ruling** (unit F's open question 1; unit F). This
  corrects R5. D-060's Position ends "; no `SimulationTermination` exception
  type", a ruling of its own by the semicolon test, and §13.5 is its home.
  Row 501's "no counterpart here" keeps one bold headline clause with
  D-060, history plain around it.
- **R23. Links that would share a sentence** (unit F's open questions 2 and
  3; unit F). A link sits at the term's first use in the section, with its
  gloss. Where two glosses would land in one sentence, split the sentence.
  R9's sentence keeps the `#g-blessed` link, and §13.6 links *component* at
  its first use as well as *workspace*. Unit F's numbering note on D-316's
  bullets is right: cite and describe bullets by content.

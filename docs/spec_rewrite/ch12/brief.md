# Brief: the readability rewrite of spec chapter 12

You rewrite one unit of chapter 12 of `docs/design/spec.md`, "Runtime
periphery: lifecycle and orchestration", for readability, with no loss of
content. Four agents work in parallel, one per unit. Your prompt names your
unit.

Paths below are relative to `docs/spec_rewrite/ch12/` unless they start with
`docs/`. Run the tools from `docs/spec_rewrite/`. The base commit is
`17ad42d`. Old spec lines below are lines of `spec.md` at that commit; the
frozen copies `scratch_survey/h1/spec.md` and `scratch_survey/h1/decisions.md`
are byte-identical to it. Never read `spec.md` or `decisions.md` from the
working tree: other sessions edit them.

## Read first

1. `docs/spec_rewrite/checks/brief_common.md`, the standing part of this
   brief: what to read, the rules for every unit and what a unit produces.
   Where it says `chNN`, read `ch12`; where it cites `[§11.3][s11-3]` as an
   example, any section works the same way.
2. This brief's slice for your unit, `units/<U>/brief.md`.
3. Your survey slice, `units/<U>/survey.md`. Units A and B come from
   `survey_1.md`, units F and G from `survey_2.md`. The questions q1–q13 are
   survey 1's, q21–q30 survey 2's; findings F1–F24 are survey 1's, F51–F83
   survey 2's.

## Rulings already made

These are the orchestrator's rulings at checkpoint 1, each on the survey
question or finding named. Apply the ones that touch your unit, and tag each
such claim in `claims.md` with `tag: R` and `ruling: <id>`. A dictated
wording is a target: fit it to the sentence around it, keep its claims, and
add none.

- **R1. The opening** (q1; unit A). The chapter opening (old 8588–8594)
  becomes one context sentence and one roadmap sentence, in chapter 11's
  form. The context sentence says the chapter specifies the machinery that
  drives the loop, taking §10's loop and §11's data plane as given. The
  roadmap sentence names §12.1 to §12.7 in order by subject, §12.5 included.
  "The loop boundary" goes. Source every word from the old opening, the
  section titles and the sections' content. The Part III roadmap (old
  5478–5480) is not edited: it belongs to the front-matter rewrite.
- **R2. The parked GUI** (q2, F2; units A, B). D-310 parked the built-in GUI
  and made a front end a device attached by hand.
  - Examples that name the GUI as a live device become a front end, with no
    other change: old 8604 "GUI button" becomes "a front end's button"; 8739
    "shows in the GUI" becomes "shows in a front end"; 8849 "the GUI" in the
    issuer list becomes "a front end"; 8933 "GUI window teardown" becomes
    "front-end window teardown". 8882's "window ✕" stays. Cite D-310 once
    per section where the first such change sits.
  - Old 8711–8716 (the stall argument ending "the stop button keeps
    working") and 8823–8824 (the GUI does not use the wait) stay as written,
    rewrapped only. They are escalated (E2). List both in `rulings.md`.
- **R3. Bold homes and doubles** (q3; units A, B). Bold the headline clause
  of each Position the half states nowhere bold, here, with its citation:
  D-030 (the tail's order), D-138 (the bracket), D-132 (the interrupt is a
  stop, not a failure), D-114 (the publication order), D-028 (the
  counter-plus-condition wait; newest-wins only if the Position makes it a
  separate ruling), D-133 (the `t_end` landing, and the 2 s threshold only if
  the Position makes it a separate ruling), D-201 (the terminal account
  closes at the final frame top, row 125) and D-203 bullet 4
  (`DeviceJoinTimeout` to the loop's cell, row 111). Apply the one-bold test
  to each Position before bolding: read the entry. Rows 19 (D-022), 126
  (D-368), 151 (D-268 bullet 7, "listed for release") and 168 (R5) become
  plain with their citations, since chapter 11 bolds them. Row 145 merges
  into row 146 (survey 1's M9).
- **R4. The tail's list and chart** (q4; unit B). The numbered list stays;
  each step label becomes the item's plain first words. The chart (old
  8900–8906) stays verbatim except that its five step numbers lose their
  bold.
- **R5. Overlaps and homes** (q5, q23, q24, q25; units A, B, F, G). One home
  each, with a pointer at the other:
  - §12.1 holds `Control`'s fields and `replay!`'s pace keywords; §12.7
    keeps its playback clause with a pointer to §12.1. §12.6 keeps its
    four-field ownership list with "`join_timeout` is `Control`'s (§12.1)".
    `step!` taking no pace stays in both §12.1 and §12.6.
  - §12.4 holds what survives a stop and `t_end`'s landing. §12.6 holds the
    `t_plus` spelling, `checkpoint`'s refusal after an abandoned frame, and
    roster persistence across re-initialization.
  - Which devices get a task: §11.1 is the home. §12.4's bold "Topology is
    derived after initialization" (old 9057–9060, row 168, survey 1's M8)
    goes, its content kept by rows 158 and 163–164, with no §11.1 pointer
    needed. §12.6's "Task topology follows the roster each time" (old
    9468–9470) becomes a plain pointer to §11.1; its second sentence, D-310
    bullet 2's front-end clause, stays, cited to D-310 and bold, since no
    other section states it (survey 2's M54, q24 option a).
  - The stepping session (q23 option a; unit F): survey 2's M51 and M53. Old
    9343–9348 becomes one sentence pointing at §11.1, keeping "Deviceless,
    `run!` is fully synchronous" (D-268 cites §12.6 for it). Old 9371–9385
    keeps the `stage!` → `step!` → `latest` idiom and "Both entry points
    work under `run!` too" (Appendix B relies on it), and points at §11.3
    for what the harness writer is.
  - The per-advance stop policy (q25 option b; unit F): §12.6 keeps old
    9472–9480 whole as the home. §13.5's repeat is carried to chapter 13.
- **R6. History, verdicts and reader-cold names** (q6, q11, q27, q29; units:
  all). No history or verdict line is cut. Each adversarial line keeps a
  one-clause verdict with its citation. FlightCore stays named wherever the
  old text names it, in the past tense where the old text says "today".
  Every reader-cold name gets an introducing clause that claims nothing
  beyond its source:
  - unit A: "ZOH" is expanded as zero-order hold at its first use; "hard-RT"
    as hard real-time; "libuv" as the I/O library under Julia's tasks.
    FlightCore's `nthreads` error keeps "FlightCore's".
  - unit B: FlightCore's EOT convention, `SimulationTermination` and
    network.jl keep "FlightCore's" (network.jl as "FlightCore's network
    device, `network.jl`").
  - unit F: `c172_demos.jl` is introduced once as FlightCore's demo file,
    its line numbers kept. `K` (old 9188) is glossed as `Relative(K)`'s
    multiplier with a pointer to §10.5, after you confirm §10.5 defines it.
    "The demo-vs-GUI dead-slider fight" points at §11.7. "The migration
    suite" is FlightCore's test suite only if §12.6's or the log's text says
    so; otherwise it stays and goes in `rulings.md`. "project → sweep →
    publish" stays verbatim.
- **R7. "Resumable by the next `run!`"** (q7, F1, F72; unit B). Old 9054 and
  9080 stay as written. It is escalated (E1). List both in `rulings.md`.
- **R8. The init failure off boundary zero** (q8, F9; unit B). The bracket
  runs at `run!`'s top, and a run need not start at boundary zero. Correct
  every sentence of old 9020–9060 that assumes it:
  - "dead from boundary zero" becomes "dead from the run's first frame top";
  - the orphaned root inputs "hold the values the run started with", not
    "their initial values" (9033);
  - 9040–9042: "absent from frame zero" becomes "absent from the run's
    first frame"; "shifted to `t₀`" becomes "shifted to the run's start";
  - 9044–9050 and 9059: the stop is pending at the run's first frame top,
    which the loop reads before any frame, so the run advances no frame and
    ends `stopped` where it started, its termination record naming the
    device. Drop "The run publishes boundary zero" and the §13.5
    boundary-zero check as the mechanism.
  Sources: D-138's Position and `src/sim.jl`'s run loop, which reads the stop
  issuer at the frame top before advancing.
- **R9. The units** (q9, q30; units: all). Four units, A, B, F and G, below.
- **R10. Clear factual corrections** (q10, q12, q28; units: all). Each is
  ruled as the survey's part E proposes, adjusted where stated. Grep your
  unit for each phrase and fix every instance.
  - F3 (unit B): delete old 9159–9161's last sentence, "Nor can a second
    interrupt repair (5)'s honest asymmetry, …".
  - F4 (unit B): 8851–8852 "never stops mid-frame" becomes "never stops
    mid-boundary: it completes the boundary sequence in progress, which a
    `t*` stop places inside a frame"; 8830 "on a boundary rather than
    mid-frame" becomes "on a boundary".
  - F5 (unit B): 8873–8875: the device is reported by name in a
    `DeviceJoinTimeout` diagnostic; drop the heartbeat clause.
  - F6 (unit B): 8937 "The cap is deployment, not implementation" becomes "a
    per-simulation setting, not an implementation constant"; 8943–8945: like
    `log_max` (§11.2), replay neither records nor compares it; it lives on
    `Control`, not on the `Deployment` (D-256).
  - F7 (unit A): `Control`'s field list adds the sticky stopped status.
  - F8 (unit A): 8667 "each of the four calls" becomes "the two setters and
    the two keywords"; give 8601's "(below)" its target.
  - F10 (unit B): 9024–9027 becomes: its `task_state` reads `:done` from the
    first publication (§12.2); a device that never ran never beat, so its
    cell also reads stale from the start. Cite D-138; drop "(§11.8)".
  - F11 (unit B): `DeviceCrash` carries the cause exception and whether
    `should_abort` was set; the cell it is written to names the device.
  - F12 (unit B): 8867–8868 becomes: steps (2) and (3) are the framework's
    half: they wake its own waits and call each device's `unblock!`.
  - F13 (unit B): 9082–9083 becomes: the interrupt is the escape from a run
    nothing else ends, and the deviceless run has no other.
  - F14 (unit B): 9108: the catch site (§13.4) never sees a single
    interrupt.
  - F15 (units A, B): name `ThreadBudget` at 8720, `ArgumentInvalid` at 8872
    and `CheckpointMidFrame` at 9152, one clause each.
  - F16 (unit A): 8704 and 8711's scheduler sense of "freeze" becomes "the
    scheduler stall"; 8722's "frozen roster" stays.
  - F17 (unit A): 8817–8819: inbound coalescing keeps the newest level per
    face, and the wait delivers the newest snapshot, the same ZOH decision;
    8816 "skips frames" becomes "skips boundaries".
  - F20 (unit B): 8952–8953: once stopped, `detach!` can remove an entry and
    release its claims.
  - F21 (unit A): after the pause verbs, add: a paused run is still running;
    the lifecycle reads `running` and the roster stays frozen (D-106).
  - F22 (unit B): 9150 "until the next `init!` or `restore!`" becomes "until
    the next `init!`, `restore!` or `replay!`".
  - F23 (unit B): 9088 cites §13.5, not §13, for the doctrine.
  - F24 (unit B): the init bracket sketch (8973–8990), a ruled code edit:
    `stop!(control)` becomes `stop!(entry.handle)`, and `DeviceCrash(e)`
    becomes `DeviceCrash(e, entry.should_abort)`. Nothing else in the block
    changes.
  - F52 (unit G): 9696 drops the §11.5 pointer; "that line" refers back to
    old 9681, which R13 keeps in the same block.
  - F54 (unit G): 9634–9635: error reproduction replays to the frame-entry
    boundary `k` the error names, then `step!`s the failing frame under
    instrumentation (§13.4).
  - F55 (unit G): the bold at 9629 becomes "**A replay's halt leaves the
    simulation `initialized`, never `stopped`**", cited to D-218; the
    sentence that a §13.5 source firing first ends it `stopped` (9573–9575)
    stays.
  - F56 (unit G): 9545–9546: a simulation that is not `initialized` meets
    the lifecycle gate; one whose origin or frame is off the recording's is
    refused as `CheckpointMismatch`, its clock arm.
  - F57, F82 (unit G): 9715, the table's rows at 9727–9728 and 9643 are
    scoped to the default form; add that under `restore = false` the
    simulation's own clock runs, its origin must equal the recording's, and
    the new trace's header is the simulation's own checkpoint.
  - F58, F59, F78 (units F, G): name `MissingInit` at 9334–9336,
    `ArgumentInvalid` at 9354–9355, `ServiceLifecycle` at 9425–9426, and
    `live!`'s three kinds at 9608–9612, one clause each.
  - F60 (unit F): 9196–9197: honest `s`, which a port can publish to
    snapshots, logs and plots.
  - F61 (unit F): 9387's "the `run!` seam" becomes a plain label of the
    junction where `run!` follows `step!`.
  - F63 (unit F): 9415–9417: from `stopped`, nothing advances until
    `init!`, `restore!` or `replay!` opens a new run, and `errored` is
    terminal.
  - F64 (unit F): 9372–9373: in a stepping session the cell written is the
    harness cell.
  - F65, F75 (unit F): settled by R5's pointer to §11.1, which defines the
    unattended run in full.
  - F66 (unit F): unlink the compound-word links at 9334 and 9361.
  - F67 (unit G): 9578–9579: a replay of a live run that ignored some must
    pass the same `ignore_stop_requests`.
  - F68 (unit G): either keyword names a frame from the one the feed starts
    from through the recording's last; anything else is refused
    (`ArgumentInvalid`).
  - F69, F70 (unit F): 9425 cites D-319; 9446 cites D-274 beside §12.3.
  - F74 (unit F): fold the **Rule.** at 9185–9186 into the bold at
    9179–9181, which says "scenario components"; "source or supervisor"
    goes.
  - F76 (unit G): 9609–9611 becomes "every other state refuses under the
    ordinary lifecycle gates".
  - F77 (unit F): 9203–9204 "with no latching" becomes "with no latch state
    of its own".
  - F79 (unit F): 9353–9354 keeps its scope: `step!` never waits on the
    pacer. Never shorten it to "never waits".
  - F81 (unit G): 9693–9694 and the table's row at 9725: the target
    simulation's `Model` carries its own deployment.
  - F83 (unit G): 9565–9568: `to_boundary = k` takes §13.4's frame-entry
    boundary index, a count of frame tops, not the ordinal a snapshot
    carries (§12.3); replay runs through frame `k` and halts at its top.
    "For a grid boundary" goes.
  F19 needs no edit: do not "fix" §12.2's yield toward the code.
- **R11. "The stop word"** (q13; units A, B). Gloss it inline at its first
  use per section: the control plane's stop request, one atomic word holding
  its issuer. Its glossary entry waits for track 2.
- **R12. The fingerprint's naming** (q21, F51, F80; units F, G). Use
  §11.5's naming at every site: the fingerprint is the structural layout,
  and the deployment is named beside it. Old 9423 lists "`t`, `t₀`, the
  fingerprint (the structural layout) and the deployment"; 9432, 9438 and
  9452 check "the state's fingerprint and deployment"; 9661–9663 compares
  the checkpoint's deployment against the target's and its fingerprint
  against the `Build`, with the layout list "(store layout, root-input
  faces, and what a copy by position relies on, §11.5)"; the table's first
  two rows follow.
- **R13. Section orders** (q22; units F, G). §12.6: survey 2's option (b), a
  new context paragraph that introduces the five states, *door* (R14),
  `feed` and the input mode, then `####` labels at today's breaks, and M52
  only. §12.7: survey 2's six blocks with M56 and M57, its option (c); the
  rewrite workflow's fence leaves its list item and loses its two-space
  indent, nothing else.
- **R14. "Door"** (q26, F62; units F, G). Define *door* once, in §12.6's
  context, as an entry point that builds a run: `init!`, `restore!`,
  `replay!`. `live!` becomes "the one call that moves the mode alone" at
  9414, 9602 and 9615. Every "door" that names a `Model`'s entry point, or
  the simulation calls that write a model's status, becomes "entry point":
  9312 ("the `Model`'s own doors"), 9313 ("its simulation's doors"), 9314
  ("the model's doors") and 9440 ("as the model's door does").

## Escalations

These stay as written. The owner rules them when the chapter closes.

- **E1.** §12.4 and D-132's Position call a stopped simulation "resumable
  by the next `run!`"; §12.6, D-088 and the code refuse `run!` on
  `stopped`.
- **E2.** §12.2 says a front end's stop button keeps working under any
  starvation, a property the GUI on the calling task gave and D-310
  withdrew; §12.3 describes the parked GUI's read path.

## The units

Line numbers are old spec lines at `17ad42d`. Each survey's part F rates its
units' difficulty and names their hazards. No section spans two units, so
each unit owns every first-use link in its sections. No `####` anchor of
the chapter is linked from elsewhere.

**A: chapter heading, roadmap, §12.1, §12.2 and §12.3** (8588–8825; 1,918
words). Survey 1.
- R1, R2, R3, R5, R6, R9, R10 (F7, F8, F15, F16, F17, F21), R11.
- Survey 1's M1 to M6 and its part C order for each section.
- §12.1 has no context paragraph today: M1 gives it one, ending with one
  sentence naming the parts. "The tail" and "unmask points" take their
  glosses at first use, with pointers to §12.4.

**B: §12.4** (8826–9168; 2,796 words). Survey 1.
- R2, R3, R4, R5, R6, R7, R8, R9, R10 (F3, F4, F5, F6, F10, F11, F12, F13,
  F14, F15, F20, F22, F23, F24), R11.
- Survey 1's M7 to M11 and its part C order.
- D-030, D-138 and D-132 rule the section and are cited nowhere in it. 34 R
  rows rest on D-138's and D-132's Rationales.
- The chart and the init bracket sketch stay verbatim except R4 and F24.
- B ends before §12.5's heading.

**F: §12.5 and §12.6** (9169–9484; 2,770 words). Survey 2.
- R5, R6, R9, R10 (F58, F59, F60, F61, F63, F64, F65, F66, F69, F70, F74,
  F75, F77, F78, F79), R12, R13, R14.
- Survey 2's M51 to M55, M59, and R13's §12.6 order.
- D-088 and D-096 rule §12.6 and are cited nowhere in it. D-031's Position
  chains six rulings; read it before bolding in §12.5.
- The lifecycle derivation table stays verbatim.

**G: §12.7** (9485–9738; 2,331 words). Survey 2.
- R5, R6, R9, R10 (F52, F54, F55, F56, F57, F59, F67, F68, F76, F81, F82,
  F83), R12, R13, R14.
- Survey 2's M56, M57, M60 and its six-block order.
- Two forms of `replay!`: every sentence about the header, the clock or the
  restore says which form it covers. Three indices: never write "boundary
  `k`" without naming which.
- The entry-point block and the dispositions table stay verbatim except
  R12's and F57's rows. G ends with the chapter's closing `---`.

## Rulings after step 3

- **R15. The stop word's gloss** (unit B's open question 1; units A, B).
  R11's dictated gloss collides with the glossary's *stop request*
  (`#g-stop-request`, a model-detected termination), which §12.4 uses a
  sentence later. The gloss becomes "the control plane's stop command, one
  atomic word holding its issuer". The spec already calls the interrupt "a
  control-plane stop command" (old 9076). Tag the edit R15.

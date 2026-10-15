<!-- Sliced for unit A by checks/slice_brief.py. Rulings for other units are stubs; the full text is brief.md. -->
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
- R4 reaches units B, not this one; see brief.md.
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
- R7 reaches units B, not this one; see brief.md.
- R8 reaches units B, not this one; see brief.md.
- **R9. The units** (q9, q30; units: all). Four units, A, B, F and G, below.
- **R10. Clear factual corrections** (q10, q12, q28; units: all). Each is
  ruled as the survey's part E proposes, adjusted where stated. Grep your
  unit for each phrase and fix every instance.
  - F3 (units B; see brief.md)
  - F4 (units B; see brief.md)
  - F5 (units B; see brief.md)
  - F6 (units B; see brief.md)
  - F7 (unit A): `Control`'s field list adds the sticky stopped status.
  - F8 (unit A): 8667 "each of the four calls" becomes "the two setters and
    the two keywords"; give 8601's "(below)" its target.
  - F10 (units B; see brief.md)
  - F11 (units B; see brief.md)
  - F12 (units B; see brief.md)
  - F13 (units B; see brief.md)
  - F14 (units B; see brief.md)
  - F15 (units A, B): name `ThreadBudget` at 8720, `ArgumentInvalid` at 8872
    and `CheckpointMidFrame` at 9152, one clause each.
  - F16 (unit A): 8704 and 8711's scheduler sense of "freeze" becomes "the
    scheduler stall"; 8722's "frozen roster" stays.
  - F17 (unit A): 8817–8819: inbound coalescing keeps the newest level per
    face, and the wait delivers the newest snapshot, the same ZOH decision;
    8816 "skips frames" becomes "skips boundaries".
  - F20 (units B; see brief.md)
  - F21 (unit A): after the pause verbs, add: a paused run is still running;
    the lifecycle reads `running` and the roster stays frozen (D-106).
  - F22 (units B; see brief.md)
  - F23 (units B; see brief.md)
  - F24 (units B; see brief.md)
  - F52 (units G; see brief.md)
  - F54 (units G; see brief.md)
  - F55 (units G; see brief.md)
  - F56 (units G; see brief.md)
  - F57 (units G; see brief.md)
  - F58 (units F, G; see brief.md)
  - F60 (units F; see brief.md)
  - F61 (units F; see brief.md)
  - F63 (units F; see brief.md)
  - F64 (units F; see brief.md)
  - F65 (units F; see brief.md)
  - F66 (units F; see brief.md)
  - F67 (units G; see brief.md)
  - F68 (units G; see brief.md)
  - F69 (units F; see brief.md)
  - F74 (units F; see brief.md)
  - F76 (units G; see brief.md)
  - F77 (units F; see brief.md)
  - F79 (units F; see brief.md)
  - F81 (units G; see brief.md)
  - F83 (units G; see brief.md)
  F19 needs no edit: do not "fix" §12.2's yield toward the code.
- **R11. "The stop word"** (q13; units A, B). Gloss it inline at its first
  use per section: the control plane's stop request, one atomic word holding
  its issuer. Its glossary entry waits for track 2.
- R12 reaches units F, G, not this one; see brief.md.
- R13 reaches units F, G, not this one; see brief.md.
- R14 reaches units F, G, not this one; see brief.md.

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

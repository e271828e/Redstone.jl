# Roadmap: the tutorial

The live roadmap for the tutorial, settled in discussion on 2026-11-17 and
amended on 2026-11-18. It
states the tutorial's aim and arc, names the rulings the discussion
settled, stages the work in five increments, lists the decisions each
increment still needs, and holds the draft rules the pages are written to.
The rulings of 2026-11-18 on increment 1's prototype amend the arc and R5,
R6 and R10 below in place. Its `pending.md` bullet carries the state of the
work; this file carries the plan. The probes behind the rulings are
`20261117_tutorial/notes_tutorial.md`, with their scripts beside it. A
ruling made later on the whole arc is appended here, dated; a ruling local
to one increment goes to that increment's notes.

## What the tutorial is

- The prose is for humans. The likely reader is a controls or GNC engineer
  coming from Simulink, or a Julia user coming from the SciML stack.
- That reader may have an agent write the code. Three jobs remain theirs:
  deciding whether to adopt, specifying what to build, and reviewing what
  comes back.
- The tutorial therefore teaches concepts and shows evidence. Code appears
  whole beside real output and is not explained line by line. The
  reference carries the syntax.
- Every code block is complete and runnable, imports included, because a
  user's agent imitates worked examples.
- Writing the code is what finds the API's friction, whatever the prose
  does, so the tutorial still precedes the API audit.

## The arc

One model, the longitudinal aircraft, built from scratch. Each chapter
ends at a named function of the examples package, so a reader who skipped
a chapter imports its end state.

| # | Chapter | The reader builds | Domain idea | Framework features | Evidence shown |
|---|---|---|---|---|---|
| 1 | The aircraft | `Longitudinal`, run off trim | five ODEs | continuous leaf, declarations, the frame, `run!`, `series` | the phugoid plot |
| 2 | Trim | the level-flight problem | equilibrium, three unknowns | conditions, `TrimProblem`, the report | the solver within 1% of the hand estimate |
| 3 | Linearize | the tap set | modes as eigenvalues | taps, exact Jacobians, `h_max`, fixed against adaptive steps | the eigenvalues against chapter 1's period |
| 4 | A first loop | pitch hold, continuous then discrete | one PID on pitch attitude | `Group`, wires, root inputs, sample time, the base tick | margins from `A` and `B`, the gap between the tiers |
| 5 | The autopilot | the cascade, actuators, sensing | cascade, actuator, sensor noise | hierarchy, faces, the library, two rates, the inspector's diagram | the altitude step |
| 6 | Hands on and off | the engage switch, the tracking wires | bumpless engage | `stage!`, the loop error, `UnitDelay` | a bumpless engage |
| 7 | Approach and touchdown | the ground and a stop request | a descent to the ground | localized event, `StopRequest`, the termination record | `h = 0` at the stop |
| 8 | The flight, again | nothing new in the model | none | trace and replay, checkpoint and restore | a bit-identical replay of the whole flight, a second approach from a checkpoint |
| 9 | A second controller, optional | the LQR tracker, a new `selection` | multivariable control | the trim and linearize pipeline feeding parameters, vector signals, `Select` over an enum | the eigenvalue match, the airspeed excursion against the cascade's |

## Settled in discussion

**R1. One model, built step by step from scratch.** A single model shows
composition, which is the framework's thesis, and follows the real GNC
workflow. Rejected: several mini-tutorials on ad-hoc models, since toy
models never show scale and each is another model to keep tested; and two
models, the README's loop for mechanisms beside the aircraft for workflow.
The chapter-end functions answer the single model's main cost, that
chapter N needs chapters 1 to N-1.

**R2. Four rules for the physics.**
- State, do not derive. The equations appear once and each line of
  `x_deriv` mirrors one. Derivations stay in the companions, linked.
- One domain idea per chapter, the one the framework feature needs.
- Rigor through checks against hand results, shown as output. The
  companions already hold them: the hand trim estimate, the reduced short
  period, Lanchester's phugoid.
- Design numbers are given with one sentence and a link, never a tuning
  argument.

**R3. Chapter 4 designs in continuous time and deploys in discrete time.**
The continuous `PID` closes the loop so `linearize` gives its margins. The
discrete loop then refuses the same call with `TapResolution`, which
explains why the design was continuous and is a natural place for a
diagnostic. The linearization pays off through the PID here, with gains
checked against `A` and `B` in code, so the payoff does not wait for the
tracker.

**R4. The cascade runs at two rates.** The altitude and airspeed loops run
at 10 Hz and the inner loops at 50 Hz. Today every discrete component runs
at 50 Hz, so the example shows one rate only.

**R5. An engage switch replaces the switch between two autopilots in the
main path.** Chapter 6 selects between the pilot's commands and the
cascade, with a `Bool` root input and a `Switch`. It carries the same
framework content: a standby controller that tracks, a bumpless engage and
the algebraic loop when the delay is missing. Every reader knows an
engage button, and the chapter needs no LQR theory. It also gives the
scenario the later chapters fly: by hand through staged inputs, then
engaged.

**R6. Chapter 6 was split in two.** The cut is between changing the model
and using the run. The run's chapter, "The flight, again", is the only one
where the model does not grow. Since R18 it is chapter 8 and works on the
final model: it replays the whole flight and restores a checkpoint taken
at the top of the descent to fly a second approach.

**R7. The approach flies under the autopilot.** The reference descends at
about 1.5 m/s, the companion's glide angle at 50 m/s, and the ground stops
the run. There is no flare and the text says so. This makes the tutorial
one flight. The fallback, if the prototype finds it too heavy, is today's
open-loop glide placed after trim.

**R8. The LQR tracker is an optional last chapter.** It showcases a more
advanced design workflow through `ControlSystemsBase` and
`lqr_tracker.md`, which reassures demanding GNC readers. It is the one
chapter where the trim's operating point and the linearization's matrices
become a component's parameters with no number copied by hand. Three
conditions:
- It comes last and is marked optional. The flight ends at chapter 8.
- It opens with evidence: the continuous `LQRTracker`'s closed loop
  against the design's eigenvalues, and the comparison with the cascade.
- It states and does not derive. `lqr_gains` appears whole and the theory
  stays in `lqr_tracker.md`.

Rejected: dropping the tracker; keeping the two-controller model as a
version the tutorial does not reach, which would break the admission
guideline that every example is the subject of a chapter
(`examples_inventory.md`, section 2).

**R9. The enum arrives in chapter 9.** Chapters 6 to 8 keep the `Bool` and
the `Switch`. Chapter 9 rebuilds the `selection` group on `Select` over an
enum of three modes, changes the root input's type, and reuses the
sensing, cascade and actuator groups as they are. Rejected:
- Three enum values defined upfront. `Select` has one input per instance
  and an unfed input is refused as `UnconnectedInput`, so chapters 6 to 8
  would carry a placeholder wire, a forward reference to an optional
  chapter, and a mode that silently does what the placeholder does. Each
  controller would also need a junction to derive its `engaged`.
- Two values first and a third later. A Julia enum is closed and its
  instances are constants of the module.
- A second `Bool` and a second switch behind the first. It keeps chapter
  6's model strictly contained, but ends with two `Bool` inputs where one
  enum says more.

**R10. The deployment is taught where each quantity first matters.** The
frame arrives in chapter 1, since the first run cannot be written without
it. The algorithm, `h_max` and `h_min` arrive in chapter 3, where the
plant is still continuous and the linearization has just given the two
time scales. The base tick arrives in chapter 4 with the first discrete
component, and chapter 5's two rates extend it. Rejected: a chapter of
its own, which presents four quantities before the reader needs any; and
the algorithm in the approach's chapter, since a tick where a component is
due ends a step, so under a 50 Hz autopilot an adaptive method has little
room.

**R11. Each pin of the example is probed once.** The testset's probed pins
and the numbers in `longitudinal_aircraft.md` section 4 move with any
change, so variants are prototyped beside the example first. The change
need not wait for the inspector: `RedstoneInspector.jl` pins this repo by
revision, `6afd6fb` today, and its fixtures are committed files that
regenerate only at a deliberate bump. The cost falls at that bump, when
`closed_loop.json` and the frontend tests that pin it change together.

**R12. The pages are executable.** Documenter `@example` blocks generate
the outputs and the plots at build time, so the tutorial cannot rot and
the evidence is real. The docs environment gains `RedstoneExamples` and a
plotting package.

**R13. Two success criteria.**
- A fresh agent given only the public surface and the tutorial builds a
  model from another domain. Where it stumbles is friction for the API
  audit or a gap in the docs.
- A reader can predict that a wire closes an algebraic loop, and say why.

**R14. Four features stay out and go to the user guide**: real-time
pacing and devices, until the live inspector exists; function-valued
signals; and mounting. A feature enters only where an engineer flying
this problem would reach for it.

**R15. The cycle's verdict is reworded.** A real verdict that rests on a
structurally traced member will read "presumed real". It rides with the
pending pass over the diagnostic messages, recorded there in `3049361`.

**R16. The work is a multi-increment arc.** A whole-tutorial prototype is
too large for one increment, and the example is the part every chapter
depends on and the part with real unknowns. The cuts are the sequence
below.

**R17. A rule for friction.** Each increment's notes record what the
writing found in the API. A small fix lands as its own commit, and
anything larger goes to the friction review of the API audit in
`pending.md`. The arc does not stall on API changes.

## Ruled on 2026-11-18

The user's rulings on the readings of increment 1's prototype that reach
the whole arc. The readings local to the increment go to its notes.

**R18. The approach is chapter 7 and "The flight, again" is chapter 8.**
R6 had the run's chapter first, with its checkpoint as the approach's
starting point. That cannot be built: the approach grows the model, and a
checkpoint is checked against its deployment, so the restore is refused
as `CheckpointMismatch`. With the order swapped the run's chapter works on
the final model. Its replay covers the whole flight, touchdown included,
and its checkpoint has an honest job, a second approach from the top of
the descent. Rejected: keeping the order, with the approach re-flying
chapter 6's scenario on the grown model and the checkpoint used only for
a second continuation in level flight.

**R19. A chapter's model carries nothing that only a later chapter
uses.** This is R9's reason made a rule. Its first instance is the
cascade: chapter 5 builds it without the tracking inputs, and chapter 6
turns tracking on and adds the wires, through a keyword of the cascade's
function. Rejected: one cascade with its standby faces from chapter 5 on,
fed there by signals that are never read. The hold's `engaged` input
stays in chapter 5, because the hold chain brings it.

**R20. The rules for the pages live in this file.** They are the last
section below. They move to a file of their own under `design/rules/`
only if a second tutorial is written.

## Open decisions

Each names the increment that needs it ruled.

- **The names of the chapter-end functions.** Increment 1.
- **How the approach's reference descends**, staged between steps or
  produced inside the model. Increment 1.
- **Whether the approach replaces `descent()`** or sits beside it, which
  follows R7's fallback. Increment 1.
- **The plotting package.** Increment 2.
- **Where the pages sit under `docs/src/`**, and the docs build's time
  budget in CI. Increment 2.
- **How chapter 5 shows the inspector's diagram.** Increment 3.
- **What chapter 4 shows of the margins from `A` and `B`**, and which of
  it the testset pins. Increment 1 pins the pitch loop's eigenvalues and
  DC gain only. Increment 3.
- **The enum's name and its instances' names**, and the name of chapter
  9's rebuilt selection group, since increment 1 takes `selection`.
  Increment 4.
- **The cold agent's task.** Increment 5.
- **Which three chapters the README condenses.** Increment 5.

## The sequence

Each increment runs the pipeline of `rules/increment_rules.md`. The suite
stays green throughout. Increments 1 and 2 need nothing from each other
and touch different files, `examples/` and `docs/`, so they run in either
order or side by side.

1. **The example's main path.** The model of chapters 1 to 8 as
   chapter-end functions in `examples/src/longitudinal.jl`: pitch hold on
   both tiers, the cascade at two rates with its actuators and sensing,
   the engage switch with the pilot's commands, and the approach to the
   touchdown. Its testset and the numbers of `longitudinal_aircraft.md`
   move with it. Today's `closed_loop` stays untouched beside the new
   functions. This increment holds the technical unknowns, the retuning
   for two rates and the approach under the autopilot, and its prototype
   may still change the arc. Needs nothing.

2. **The scaffold and chapters 1 to 3.** The docs environment with
   `RedstoneExamples` and the plotting package, the `@example` setup, the
   plot conventions and the pages of chapters 1 to 3. These chapters use
   only the plant, the trim problem and the taps, which the arc leaves
   unchanged. This increment holds the style unknowns and works as a
   pilot: the user judges the voice and the page shape on three chapters
   before six more are written. Needs nothing.

3. **Chapters 4 to 8.** Five pages over increment 1's functions, in
   increment 2's shape. Needs 1 and 2.

4. **The tracker.** Chapter 9's model, which replaces today's
   `closed_loop` and composes increment 1's groups with a new
   `selection`, its testset, the companion's numbers and its page. The
   model and the page travel together because the chapter is optional and
   its risk, the bumpless figures across two rates, should not block
   chapters 1 to 8. Needs 1 and 2.

5. **The closing.** The README's condensed chapters, the cold-agent test
   of R13, and the friction list collated from the increments' notes for
   the API audit's friction review. Needs 3.

## Risks

- The retuning for two rates, or the approach under the autopilot, may
  not give clean figures. The fallbacks are one rate, and R7's open-loop
  glide.
- The standby tracking and the bumpless figures were measured with every
  discrete component at 50 Hz. Across two rates they may degrade, which
  is increment 4's to find.
- A plotting package adds load and build time to the docs workflow.
- Chapter 5's diagram depends on the inspector's stage 1 and on a bump of
  its pin to a revision that has increment 1's model.
- Between increments 1 and 4 the package holds today's `closed_loop`
  beside the new functions, so some wiring exists twice for a while.
- Friction found in the writing may ask for API changes. R17 bounds it.

## The rules for the pages

A draft, written before any page. It is revised once chapters 1 to 3
exist, and an agent that writes or reviews a page reads it first. R2
governs the physics and is not repeated here. Rule 2, the voice, is the
coordinator's guess, which the user has not yet confirmed.

### The reader and the voice

1. **The reader is the one "What the tutorial is" names.** They know Julia
   and control or simulation. They have never opened `spec.md`.
2. **The page speaks to the reader as "you".** It uses the present tense
   and the active voice.
3. **Short sentences and plain words.** Few parentheticals and em dashes,
   no colon as a connector inside a sentence, no roundabout phrasing.
4. **No praise.** The page never calls the framework simple, powerful or
   elegant. The output makes the case.
5. **A familiar name is used once where it shortens the explanation**, as
   in "what Simulink calls an algebraic loop". The page never compares
   merit with another tool.

### The page

6. **A page has one shape.** It opens with what the chapter builds and the
   result it ends at. Then come the steps, each a need, the code that
   meets it and its output. Then a check against a hand result. It closes
   by naming the chapter-end function and how to import it.
7. **The arc's table fixes the content.** A page carries its row's domain
   idea and framework features and no others.
8. **A concept gets one paragraph before the code that uses it.** The
   code is not explained line by line.
9. **A page starts cold.** Its first block imports the previous chapter's
   end state from `RedstoneExamples`.
10. **A mistake is shown where the arc names one**, with the message the
    build really prints, whole.
11. **A page is as long as its row of the arc needs, and no longer.** Its
    length follows from rules 7 and 8. No word count is a target, and a
    page is never padded or cut to reach one. Once chapters 1 to 3 exist,
    they are the reference for the pace.

### The code

12. **Every block is whole and runs in page order.** No hidden setup,
    except a plot theme. Every name is imported in view.
13. **The names are the package's.** Components, paths, faces and
    functions are spelled as `examples/src/longitudinal.jl` spells them.
14. **The page builds by hand what the package ships.** Where it is cheap,
    the page checks its own model against the package's function on a run.
15. **By R19, a block carries nothing that only a later chapter uses.**

### Output, figures and numbers

16. **Output is real.** It comes from the build and is never typed or
    trimmed by hand. Code that would print too much prints less.
17. **A number in the prose is one the page's output shows**, rounded, and
    the examples' testset pins it.
18. **One claim per figure.** Axes carry the quantity and its unit, time
    is in seconds, and a signal keeps its color across chapters.

### Terms and links

19. **The glossary's words only.** The first mention of a glossary term
    links to the glossary page, and an API name links to its reference
    entry, as `docstring_rules.md` rules 25 and 27 do. A component is a
    component, never a block.
20. **No `§` and no `D-nnn`.** A derivation is linked to its companion and
    never restated.

### What a page never does

21. It promises no future feature.
22. It explains no Julia.
23. It hides no failure: a refusal that the reader will meet is shown.

### For the agent

24. **Friction goes to the increment's notes**, by R17, each item with the
    call that showed it.
25. **The docs build is green** before a page is reported, and every pin
    the page relies on exists in the examples' testset.

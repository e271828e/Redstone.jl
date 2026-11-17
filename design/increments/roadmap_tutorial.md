# Roadmap: the tutorial

The live roadmap for the tutorial, settled in discussion on 2026-11-17. It
states the tutorial's aim and arc, names the rulings the discussion
settled, stages the work in five increments, and lists the decisions each
increment still needs. Its `pending.md` bullet carries the state of the
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
  does, so the tutorial still precedes the audit.

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
| 7 | The flight, again | nothing new in the model | none | trace and replay, checkpoint and restore | a bit-identical replay |
| 8 | Approach and touchdown | the ground and a stop request | a descent to the ground | localized event, `StopRequest`, the termination record | `h = 0` at the stop |
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
scenario of chapters 6 and 7: fly by hand through staged inputs, engage,
replay.

**R6. Chapter 6 was split in two.** The cut is between changing the model
and using the run. Chapter 7 is the only chapter where the model does not
grow. It replays chapter 6's flight and restores a checkpoint, which gives
chapter 8 its starting point.

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
the algorithm in chapter 8, since a tick where a component is due ends a
step, so under a 50 Hz autopilot an adaptive method has little room.

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
  model from another domain. Where it stumbles is friction for the audit
  or a gap in the docs.
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
anything larger goes to the audit's bullet in `pending.md`. The arc does
not stall on API changes.

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
- **The enum's name and its instances' names.** Increment 4.
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
   the audit. Needs 3.

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

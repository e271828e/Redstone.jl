# Notes: the tutorial, opened 2026-11-17

The stage reached is the design discussion before the prototype. The arc
is settled and no brief exists yet. This file holds the rulings made with
the user on 2026-11-17, each with its reason, the probes behind them, and
what is open. The probes ran read-only against the tree at `bc77937`.

## 1. The audience and the aim

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

## 2. The arc

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

## 3. The rulings

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

**R11. The example changes once, when the arc is final.** The testset's
probed pins and the numbers in `longitudinal_aircraft.md` section 4 move
with any change, so variants are prototyped beside the example first. The
change need not wait for the inspector: `RedstoneInspector.jl` pins this
repo by revision, `6afd6fb` today, and its fixtures are committed files
that regenerate only at a deliberate bump. The cost falls at that bump,
when `closed_loop.json` and the frontend tests that pin it change
together.

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

## 4. The probes

The scripts sit beside this file. All ran with `--startup-file=no`, the
first two under `--project=examples` and the third under the root project.

| Probe | Script | Result |
|---|---|---|
| `closed_loop` with each tracking input wired from the selected command, bypassing the `UnitDelay`s | `probe_loop.jl` | `AlgebraicCycle` among seven members, classified real, the two PIDs and the tracker traced structurally |
| `closed_loop` linearized from `h_ref` to the altitude | `probe_loop.jl` | `TapResolution`: the root input is unseedable by tier, since a discrete consumer reads it |
| pitch hold with the continuous `PID(Kp = -2.0, Ki = -1.0)`, linearized from `θ_ref` to `θ` | `probe_continuous.jl` | linearizes; eigenvalues `-2.047 ± 8.064im`, `-1.392`, `-0.642`, `-0.052`; DC gain 1 |
| the same loop with `DiscretePID` at 50 Hz, both flown through a 0.05 rad step at 1 s | `probe_continuous.jl` | largest gap between the tiers 0.0021 rad over 10 s; peaks 0.0799 and 0.0820 rad |
| an enum-valued root input staged between steps, read by a `Select`, a junction and a `DiscretePID`'s `engaged` | `probe_enum.jl` | stages and logs as the enum; the standby PID tracks the pilot's command to 1e-11 |

A run's time history comes from `series(sim, reads(…))`, which returns
`t` and one column per entry over the logged snapshots, one per frame by
default.

## 5. What the discussion found beside the arc

- **Two sentences of the pending bullet were wrong.** "One chapter per
  layer of the example model" no longer described the arc, and the
  tutorial cannot linearize from `h_ref` to the altitude while a discrete
  controller reads the reference. The bullet was rewritten with this file.
- **The loop of chapter 6 is settled design.** The PID's code never reads
  `v` in `y_direct`, yet the wire closes a cycle by stage-2 conservatism
  (§5.4). A continuous member is classified artificial with the dead hop
  named, and a discrete one real, traced structurally (§13.8).
  `pid_anti_windup.md` sections 3 and 9 and `lqr_tracker.md` section 7
  record it. The chapter needs one paragraph on the rule: an input to a
  component with a stage-2 output is a feedthrough edge, whether the
  output reads it or not.
- **A signal for the audit.** The examples' test helpers wrap the one-port
  history as `logged_port(sim, path, name)`, which suggests a shortcut the
  audit may want to weigh.

## 6. Open

- **Not yet probed, for the prototyper.** The hold chain and the standby
  tracking across the two rates of R4, and the approach under the
  autopilot down to the touchdown of R7. Both need gains retuned.
- **Not yet discussed.** The names of the chapter-end functions, the
  plotting package, where the pages sit under `docs/src/`, and how the
  README's condensed chapters follow from the arc.

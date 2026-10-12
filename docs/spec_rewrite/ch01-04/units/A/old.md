## 1. Introduction

**Purpose.** Redstone is a framework for modeling and simulating hierarchical
[hybrid causal systems](#g-hybrid-causal-system) (models that mix continuous
dynamics, periodic discrete dynamics and events, exchanging values through
directed ports). Its home domain is aircraft guidance, navigation and control:
vehicle dynamics, sensors and avionics, simulated offline or interactively in
real time. The formalism itself is domain-neutral.

**Capabilities.** A model is written as a tree of [components](#g-component) in plain Julia. The
build checks the tree. A simulation runs a [`Model`](#g-model) (the tree compiled at one
scalar type, ready to step) ([§9][s9]). The framework provides these capabilities.

- Continuous dynamics with algebraic outputs, integrated on a fixed step, with
  events either located by root-finding or checked at step boundaries
  ([§2][s2], [§10][s10]).
- Multi-rate periodic discrete dynamics at declared sample times, held
  zero-order between ticks ([§3.2][s3-2], [§10.5][s10-5]).
- A build that derives the execution order from declared feedthrough and
  rejects algebraic loops by naming the cycle ([§5][s5], [§9][s9]).
- A runtime [periphery](#g-periphery) (the devices, GUI and scripts that
  exchange data with a running simulation) that writes by staging and reads by
  snapshot ([§11][s11], [§12][s12]).
- An input trace that replays any run bit-identically ([§11.5][s11-5]).
- Stopped-sim services for initialization, trim and linearization, with exact
  automatic-differentiation Jacobians ([§14][s14]).

**Design criteria.** The design answers to five criteria. Wherever it admits a
capability it does not build, that capability is weighed against them as a
[guarded addition](#g-guarded-addition).

- **Zero-allocation stepping and type stability.** The inner loop allocates
  nothing, and the test suite asserts it ([§7.5][s7-5], [§9.7][s9-7]).
- **Real-time interactive operation.** A simulation runs paced against the
  wall clock, with devices and a GUI attached ([§10.7][s10-7], [§11][s11]).
- **Live introspection.** Every published signal can be inspected by path,
  during a run and after it ([§11.2][s11-2]).
- **Compositional flexibility.** Components compose hierarchically, and a
  component substitutes for another behind the same declared contract
  ([§6][s6], [§8][s8]).
- **Rigor and error locality.** Structure is declared and checked at build
  time, so a mistake fails where it was made, with a diagnostic naming it
  ([§8.4][s8-4], [§13][s13]). Components are plain Julia with no macro DSL, so
  debugging, tooling and comprehension work on the language's own terms
  ([§8.1][s8-1]).

**Origins.** Redstone began as a replacement for `FlightCore`, the simulation
core of the Flight.jl package. Flight.jl also holds `FlightPhysics`, its
physics library, and `FlightApps`, its applications. The early design read
those two packages as its requirements. Every capability they demonstrated had
to survive, and none of their interfaces had to. Older entries in the decision
log reason against `FlightCore` and cite that code, and the case studies that
tested the design against it live in `companions/flight_case_studies.md`.
Redstone itself does not depend on Flight.jl.

**Scope of this document.** This document is the
[normative statement](#g-normative) of the design. It states what the
framework *is*, in the present tense. Part I fixes the formalism and the
component model. Part II covers authoring and the build, Part III execution
and the runtime periphery, and Part IV failure handling and the stopped-sim
services. The appendices index the author-facing contracts, the API, the
diagnostic kinds and the vocabulary. `pending.md` registers what the
implementation still owes this document and the questions the design leaves
open. It also lists the release work this document does not ask for. The
explainers in `companions/` are not normative, and this document wins
wherever they disagree.

Decision rationale lives in `decisions.md`, including the alternatives
considered and the reasons they were rejected. This document cites it throughout
as linked `D-nnn` entries, one entry per settled decision. Entry numbers are
stable and never reused, so a citation here always names the same entry there.

---


# Redstone.jl: A Causal Modeling & Simulation Framework

---

## Contents

- [Part I — Foundations](#part-i--foundations)
  - [1. Introduction](#1-introduction)
  - [2. Formalism](#2-formalism)
    - [2.1 Time and boundaries](#21-time-and-boundaries)
    - [2.2 Integration and inputs](#22-integration-and-inputs)
    - [2.3 Events: two detection policies](#23-events-two-detection-policies)
    - [2.4 Runs](#24-runs)
    - [2.5 Exclusions (deliberate)](#25-exclusions-deliberate)
  - [3. Component taxonomy](#3-component-taxonomy)
    - [3.1 Continuous component (the hybrid primitive)](#31-continuous-component-the-hybrid-primitive)
    - [3.2 Periodic discrete component](#32-periodic-discrete-component)
    - [3.3 Assembly](#33-assembly)
    - [3.4 Why two leaf classes, not one hybrid primitive](#34-why-two-leaf-classes-not-one-hybrid-primitive)
  - [4. Ports and signals](#4-ports-and-signals)
    - [4.1 Immutable value semantics](#41-immutable-value-semantics)
    - [4.2 Consumers see ports, not stages](#42-consumers-see-ports-not-stages)
    - [4.3 Table mechanics and port granularity](#43-table-mechanics-and-port-granularity)
    - [4.4 Function-valued signals: environment access](#44-function-valued-signals-environment-access)
  - [5. Evaluation order and feedthrough](#5-evaluation-order-and-feedthrough)
    - [5.1 The ordering problem](#51-the-ordering-problem)
    - [5.2 Two-stage outputs: signatures, bundles and the hand-off laws](#52-two-stage-outputs-signatures-bundles-and-the-hand-off-laws)
    - [5.3 Structural feedthrough: stage roles, execution order and step boundaries](#53-structural-feedthrough-stage-roles-execution-order-and-step-boundaries)
    - [5.4 Artificial loops and the escape hatch](#54-artificial-loops-and-the-escape-hatch)
    - [5.5 Algebraic loop policy: reject at build time](#55-algebraic-loop-policy-reject-at-build-time)
  - [6. Composition: connections, aggregation and hierarchy](#6-composition-connections-aggregation-and-hierarchy)
    - [6.1 Connections and hierarchy](#61-connections-and-hierarchy)
    - [6.2 Aggregation: explicit summing junctions](#62-aggregation-explicit-summing-junctions)
  - [7. State and data representation](#7-state-and-data-representation)
    - [7.1 Continuous state: structured immutable, flat backing](#71-continuous-state-structured-immutable-flat-backing)
    - [7.2 Numeric genericity (eltype)](#72-numeric-genericity-eltype)
    - [7.3 Discrete state, modes, and workspace](#73-discrete-state-modes-and-workspace)
    - [7.4 The computer/integrator split](#74-the-computerintegrator-split)
- [Part II — Authoring and build](#part-ii--authoring-and-build)
  - [8. The declaration layer: components and assemblies](#8-the-declaration-layer-components-and-assemblies)
    - [8.1 Position: a declarative trait layer in plain Julia, no macros](#81-position-a-declarative-trait-layer-in-plain-julia-no-macros)
    - [8.2 The declaration inventory](#82-the-declaration-inventory)
    - [8.3 Visibility: the contract is the interface](#83-visibility-the-contract-is-the-interface)
    - [8.4 Failure walkthroughs (the error-locality grounding)](#84-failure-walkthroughs-the-error-locality-grounding)
    - [8.5 Assembly declaration: type-based, class by declaration shape](#85-assembly-declaration-type-based-class-by-declaration-shape)
    - [8.6 Paths, wiring and faces](#86-paths-wiring-and-faces)
    - [8.7 Rate scopes](#87-rate-scopes)
    - [8.8 Computed connections and generic holding](#88-computed-connections-and-generic-holding)
  - [9. The build pipeline](#9-the-build-pipeline)
    - [9.1 The build's three steps](#91-the-builds-three-steps)
    - [9.2 The `Build` and `Deployment` artifacts](#92-the-build-and-deployment-artifacts)
    - [9.3 Probing and input synthesis](#93-probing-and-input-synthesis)
    - [9.4 Activations: executable sets, laziness, caching](#94-activations-executable-sets-laziness-caching)
    - [9.5 The always-on conformance check](#95-the-always-on-conformance-check)
    - [9.6 Stopped-sim services as activation clients](#96-stopped-sim-services-as-activation-clients)
    - [9.7 The compiled executor](#97-the-compiled-executor)
    - [9.8 Allocation policy: a scoped invariant](#98-allocation-policy-a-scoped-invariant)
- [Part III — Execution](#part-iii--execution)
  - [10. Time and execution](#10-time-and-execution)
    - [10.1 Loop ownership: the framework owns the simulation loop](#101-loop-ownership-the-framework-owns-the-simulation-loop)
    - [10.2 The stepper seam](#102-the-stepper-seam)
    - [10.3 Signal-table consistency is a boundary property](#103-signal-table-consistency-is-a-boundary-property)
    - [10.4 Localization mechanics](#104-localization-mechanics)
    - [10.5 Multi-rate tick scheduling](#105-multi-rate-tick-scheduling)
    - [10.6 Event iteration at boundaries: to quiescence, budgeted](#106-event-iteration-at-boundaries-to-quiescence-budgeted)
    - [10.7 Real-time pacing](#107-real-time-pacing)
  - [11. Runtime periphery: the data plane](#11-runtime-periphery-the-data-plane)
    - [11.1 No shared mutable model: staged writes, snapshot reads](#111-no-shared-mutable-model-staged-writes-snapshot-reads)
    - [11.2 Outbound: snapshot publication](#112-outbound-snapshot-publication)
    - [11.3 Inbound: root inputs, claims and the frozen roster](#113-inbound-root-inputs-claims-and-the-frozen-roster)
    - [11.4 Inbound: per-device staging, representation and the drain](#114-inbound-per-device-staging-representation-and-the-drain)
    - [11.5 Inbound: the input trace](#115-inbound-the-input-trace)
    - [11.6 Devices: one authoring contract, no taxonomy](#116-devices-one-authoring-contract-no-taxonomy)
    - [11.7 The GUI write path: port resolution, peek, staging contract](#117-the-gui-write-path-port-resolution-peek-staging-contract)
    - [11.8 Diagnostics and liveness: the per-writer diagnostic cell](#118-diagnostics-and-liveness-the-per-writer-diagnostic-cell)
  - [12. Runtime periphery: lifecycle and orchestration](#12-runtime-periphery-lifecycle-and-orchestration)
    - [12.1 Control plane](#121-control-plane)
    - [12.2 Loop scheduling: wait primitive, yields, thread budget](#122-loop-scheduling-wait-primitive-yields-thread-budget)
    - [12.3 The next-snapshot wait](#123-the-next-snapshot-wait)
    - [12.4 Shutdown protocol](#124-shutdown-protocol)
    - [12.5 Scripts and the mid-run mutation doctrine](#125-scripts-and-the-mid-run-mutation-doctrine)
    - [12.6 Run lifecycle and partial advance](#126-run-lifecycle-and-partial-advance)
    - [12.7 Replay: the trace re-drives the ordinary loop](#127-replay-the-trace-re-drives-the-ordinary-loop)
- [Part IV — Failure and services](#part-iv--failure-and-services)
  - [13. Error discipline](#13-error-discipline)
    - [13.1 Reporting policy: collect the checks, fail the evaluations fast](#131-reporting-policy-collect-the-checks-fail-the-evaluations-fast)
    - [13.2 Diagnostics: structured values, one carrier exception](#132-diagnostics-structured-values-one-carrier-exception)
    - [13.3 Build primitives: `resolve` and the face-list accessors](#133-build-primitives-resolve-and-the-face-list-accessors)
    - [13.4 Runtime failures: one catch site, an execution cursor](#134-runtime-failures-one-catch-site-an-execution-cursor)
    - [13.5 Termination is a state, not an exception](#135-termination-is-a-state-not-an-exception)
    - [13.6 Abnormal shutdown: one tail, two entries](#136-abnormal-shutdown-one-tail-two-entries)
    - [13.7 Tooling consequences: face routes and the component library](#137-tooling-consequences-face-routes-and-the-component-library)
    - [13.8 Cycle diagnosis: feedthrough tracing](#138-cycle-diagnosis-feedthrough-tracing)
  - [14. Stopped-sim services](#14-stopped-sim-services)
    - [14.1 Conditions are path-addressed overlays on the declared defaults](#141-conditions-are-path-addressed-overlays-on-the-declared-defaults)
    - [14.2 Fragment composition: locality without schema](#142-fragment-composition-locality-without-schema)
    - [14.3 Resolution: flatten, validate, compile once](#143-resolution-flatten-validate-compile-once)
    - [14.4 Two ways to apply a resolved condition](#144-two-ways-to-apply-a-resolved-condition)
    - [14.5 Boundary zero: an ordinary boundary with authored incoming transitions](#145-boundary-zero-an-ordinary-boundary-with-authored-incoming-transitions)
    - [14.6 Root-input totality: the missing-value error and the `override` combinator](#146-root-input-totality-the-missing-value-error-and-the-override-combinator)
    - [14.7 The trim problem: NamedTuple decisions, declared reads, named residuals](#147-the-trim-problem-namedtuple-decisions-declared-reads-named-residuals)
    - [14.8 The trim service: solver seam, scratch stores, commit and report](#148-the-trim-service-solver-seam-scratch-stores-commit-and-report)
    - [14.9 Mounting: problems as relocatable values](#149-mounting-problems-as-relocatable-values)
    - [14.10 Linearization: tap selectors, one seeded pass, a pure query](#1410-linearization-tap-selectors-one-seeded-pass-a-pure-query)
- [Appendices](#appendices)
  - [Appendix A. Taught contracts: the author-facing index](#appendix-a-taught-contracts-the-author-facing-index)
  - [Appendix B. API synopsis: the entry points](#appendix-b-api-synopsis-the-entry-points)
  - [Appendix C. The diagnostic kind set](#appendix-c-the-diagnostic-kind-set)
  - [Appendix D. Glossary](#appendix-d-glossary)
    - [D.1 Component model and declaration layer](#d1-component-model-and-declaration-layer)
    - [D.2 Signals and data homes](#d2-signals-and-data-homes)
    - [D.3 Evaluation and scheduling](#d3-evaluation-and-scheduling)
    - [D.4 Time and events](#d4-time-and-events)
    - [D.5 Build pipeline](#d5-build-pipeline)
    - [D.6 Runtime periphery](#d6-runtime-periphery)
    - [D.7 Recording and replay](#d7-recording-and-replay)
    - [D.8 Stopped-sim services and the condition algebra](#d8-stopped-sim-services-and-the-condition-algebra)
    - [D.9 Error discipline and diagnostics](#d9-error-discipline-and-diagnostics)
    - [D.10 Meta-vocabulary](#d10-meta-vocabulary)

---

# Part I — Foundations

Part I fixes what the framework *is*, before any of it is spelled in code. [§1][s1]
introduces the framework's purpose, capabilities and design criteria, and
this document's scope. [§2][s2]
gives the formalism of a run. It fixes the class of systems in scope, time
and its boundaries, integration and inputs, the two event-detection policies,
what a run is from its start to its end, and the exclusions taken
deliberately. [§3][s3] and [§4][s4]
introduce the two objects every later part manipulates. [§3][s3] gives the component
taxonomy, with two leaf classes and the assembly that composes them. [§4][s4] gives
the port, the addressable unit through which components exchange immutable
values. [§5][s5] is the central chapter. It fixes two output stages per
leaf, what each stage may see, and how those signatures alone yield a
static execution order. It also fixes the boundary sequence, the rule by which
events fire, and boundary zero. [§6][s6] lifts composition from a single
component to a hierarchy of them. [§7][s7] fixes where data lives, on both tiers
and outside them. It also fixes a run's full state, the numeric genericity of
the continuous path, and what trim and linearization compute.

Part I assumes nothing from later parts, and each of its sentences reads
without its forward citations. It cites later parts for spelling, enforcement
and mechanism. [§8][s8] shows how an author writes a declaration, [§9][s9]
fixes when each declared fact is checked, and [§10][s10] fixes how the runtime
executes a step boundary.

## 1. Introduction

#### Purpose

Redstone is a framework for modeling and simulating hierarchical
[hybrid causal systems](#g-hybrid-causal-system) (models that mix continuous
dynamics, periodic discrete dynamics and events, exchanging values through
directed ports). Its home domain is aircraft guidance, navigation and control:
vehicle dynamics, sensors and avionics, simulated offline or interactively in
real time. The formalism itself is domain-neutral.

#### Capabilities

An author writes a tree of [components](#g-component) (the units of modeling)
in plain Julia. The build checks the tree. A simulation runs a
[`Model`](#g-model) (the tree compiled at one scalar type, ready to step)
([§9][s9]). The framework provides these capabilities.

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

#### Design criteria

The design answers to five criteria. It weighs each
[guarded addition](#g-guarded-addition) (a capability it admits but does not
build) against them.

- Zero-allocation stepping and type stability. The continuous hot path
  allocates nothing, and CI asserts it ([§9.8][s9-8], [§9.7][s9-7]).
- Real-time interactive operation. A simulation runs paced against the wall
  clock, with devices and a GUI attached ([§10.7][s10-7], [§11][s11]).
- Live introspection. Every published signal can be inspected by path, during
  a run and after it ([§11.2][s11-2]).
- Compositional flexibility. Components compose hierarchically, and a
  component substitutes for another behind the same declared contract
  ([§6][s6], [§8][s8]).
- Rigor and error locality. Structure is declared and checked at build time,
  so a mistake fails where it was made, with a diagnostic naming it
  ([§8.4][s8-4], [§13][s13]). Components are plain Julia with no macro DSL
  (domain-specific language), so debugging, tooling and comprehension work on
  the language's own terms ([§8.1][s8-1]).

#### Origins

Redstone began as a replacement for `FlightCore`, the simulation core of the
Flight.jl package. Flight.jl also holds `FlightPhysics`, its physics library,
and `FlightApps`, its applications. The early design read those two packages
as its requirements. Every capability they demonstrated had to survive, and
none of their interfaces had to. Older entries in the decision log
(`decisions.md`) reason against `FlightCore` and cite that code. The case
studies that tested the design against that code live in
`companions/flight_case_studies.md`. Redstone itself does not depend on
Flight.jl.

#### Scope of this document

This document is the [normative statement](#g-normative) of the design. It
states what the framework *is*, in the present tense. Part I fixes the
formalism and the component model. Part II covers authoring and the build,
Part III execution and the runtime periphery, and Part IV failure handling and
the stopped-sim services. The appendices index the author-facing contracts,
the API, the diagnostic kinds and the vocabulary.

`pending.md` records what the implementation still owes this document and the
questions the design leaves open. It also lists the release work this document
does not ask for. The explainers in `companions/` are not normative, and this
document wins wherever they disagree.

Decision rationale lives in `decisions.md`, including the alternatives
considered and the reasons they were rejected. This document cites it
throughout as linked `D-nnn` entries, one entry per settled decision. Entry
numbers are stable and never reused, so a citation here always names the same
entry there.

---

## 2. Formalism

**The framework simulates [hybrid causal systems](#g-hybrid-causal-system)**
([D-001][d-001], [D-002][d-002]). Such a system has five parts.

- Continuous dynamics. $\dot{x} = f(x, m, u, t)$ with algebraic outputs. This
  design's `f` also receives the signal table, and the composite map
  from `x` to $\dot{x}$ is mathematically identical to the textbook form's ([§5.3][s5-3]).
- Multi-rate periodic discrete dynamics. $s^{+} = g(s, u, t)$ at declared rates,
  with outputs held zero-order between [ticks](#g-tick) ([D-019][d-019]). A tick is an instant at
  which a discrete component's stages and update run.
- [State events](#g-state-event). [Guard](#g-guard) functions (each defining an event's
  predicate) with handlers, under two detection policies.
- Post-step manifold [projection](#g-projection). **The formalism includes an
  optional per-[component](#g-component) hook, `x ← x_projection(x)`**
  ([D-001][d-001]). It is applied at every [boundary](#g-boundary) (a
  published consistency point) and after any handler reset of `x`
  ([§5.3][s5-3]). It covers quaternion renormalization,
  direction cosine matrix (DCM) orthonormalization and any other
  manifold-valued state. It is the cheap end of the projection-methods family
  from geometric integration.
- External inputs. [Root inputs](#g-root-input) (source cells written from
  outside the model) carry pilot controls, network data and other outside
  values into a running model. They change only at [frame](#g-frame) tops
  (the starts of the fixed time steps) and hold between writes
  ([§2.2][s2-2], [D-022][d-022]).

[§2.1][s2-1] fixes time and the boundaries at which everything discrete happens.
[§2.2][s2-2] fixes how the continuous state integrates and how inputs enter. [§2.3][s2-3]
gives the two event-detection policies, [§2.4][s2-4] what a run is from its start to
its end, and [§2.5][s2-5] the exclusions taken deliberately.

### 2.1 Time and boundaries

A hybrid system flows between instants and jumps at them. This section fixes
which instants exist. Time runs on a fixed grid, the instants at which
anything discrete happens are boundaries, and every run has an origin.

Time advances in [frames](#g-frame) (one fixed step `h` of the time grid). A
run starts at its origin `t₀`, and its grid points are `tₖ = t₀ + k·h` for
k = 0, 1, 2 and so on. The start of a frame is its frame top. The grid is
fixed for the whole run, and an event located inside a step never moves the
next grid point ([§10.4][s10-4], [D-290][d-290]).

A [boundary](#g-boundary) (a published consistency point) is an instant at
which discrete changes may take place and the run publishes its values.
Boundaries fall at three kinds of instant ([D-081][d-081]).

- Every grid point after `t₀`.
- Every [localized](#g-localized) event time `t*`, the crossing instant of an
  event that root-finding locates inside a step ([§2.3][s2-3]).
- The origin `t₀`, once. The boundary there is
  [boundary zero](#g-boundary-zero) (the initialization boundary, with no
  integration before it, [§5.3][s5-3]). Frame 1's top follows it at the same
  instant.

Every grid point is a boundary, but not every boundary is a grid point. A
localized event time is a boundary inside a frame, never a frame top.

```
 frame 1          frame 2                    frame 3
|----------------|--------------•-----------|----------------|
t₀               t₁             t*          t₂               t₃
boundary zero    grid           localized   grid             grid
```

Everything discrete happens at boundaries. Discrete components
[tick](#g-tick) (run their stages and update) only at boundaries
([D-019][d-019]). During a run, modes change only through event handlers,
and handlers run only at boundaries ([D-345][d-345]).
[Root inputs](#g-root-input) (source cells written from outside the model)
change only at frame tops ([§2.2][s2-2]). Between two boundaries only the
continuous state and time move. Signals computed from them, such as a
continuous component's outputs, move with them.

Time is no component's state. No [store](#g-store) (a framework-owned home
of `x`, `s` or `m`) holds it, and a [condition](#g-condition) (a
path-addressed overlay of initial values) never sets it. The origin `t₀` is
fixed when a run is initialized, and nothing after boundary zero changes it. It anchors both the grid and every discrete
tick schedule ([§14.5][s14-5], [D-067][d-067], [D-273][d-273]). A restored run keeps
the clock of the state it restores, origin included ([D-273][d-273]).

### 2.2 Integration and inputs

Between boundaries the continuous state integrates, against values that come
partly from outside the model. This section fixes how a step integrates, then
when outside values enter and what else may influence a run.

A fixed-step one-step method advances the continuous state across each step.
The method is chosen at deployment, beside the step `h` ([§10.2][s10-2],
[D-017][d-017], [D-227][d-227]). Each step starts from the state the previous
[boundary](#g-boundary) (a published consistency point) left. By then that
state has passed through any event handler's reset and through
[projection](#g-projection) (the per-component hook that returns state to its
manifold). A one-step method carries no history from earlier steps, so a
reset needs no special treatment ([D-017][d-017]). Inside a step, discrete outputs hold the values of their
last [tick](#g-tick) (an instant at which a discrete component runs, [§5.3][s5-3],
[D-147][d-147]). Before its first tick, a discrete component's outputs hold
the values computed at [boundary zero](#g-boundary-zero) (the initialization
boundary at `t₀`, [§5.3][s5-3]).

[Root inputs](#g-root-input) (source cells written from outside the model)
are a running model's only channel from outside. Nothing outside the model
writes its state, its modes or its outputs ([§12.5][s12-5], [D-031][d-031]).

Root inputs change only at [frame](#g-frame) tops (the starts of the grid
steps). Writers
outside the loop stage new values at any wall-clock moment. The
[drain](#g-drain) (the frame-top step that applies staged writes to the root
inputs) applies them before the frame integrates ([§11.1][s11-1], [§11.4][s11-4],
[D-022][d-022]). A root input therefore never changes inside a step, not even
at a [localized](#g-localized) event time (an event's crossing instant inside
a step, [D-290][d-290]). It keeps its last applied
value until a writer sets it again. When several values are staged for one
root input before a frame top, the newest takes effect ([D-104][d-104]).

A grid point after `t₀` both ends one frame and opens the next. The boundary
that ends the frame completes and publishes before the drain that opens the
next frame ([§10.1][s10-1], [§11.1][s11-1], [D-022][d-022], [D-182][d-182]).
A tick at that grid point therefore samples the root-input values the ending
frame held. A staged value first reaches the model in the step that
drain opens.

Control commands are not inputs. Pause, pace and stop decide when steps run
and where a run ends. They never change what a step computes ([§12.1][s12-1],
[D-021][d-021], [D-031][d-031]). [§2.4][s2-4] states how a stop ends a run.

### 2.3 Events: two detection policies

**Events have two detection policies** ([D-001][d-001]). Both policies share
one declaration, a [guard](#g-guard) (the declared function an event's
detection evaluates) plus a handler ([D-179][d-179]). Only detection differs.
This section first states what fires an event under either policy, then the
laws that hold only for a localized event.

#### What fires an event

**A guard defines a [predicate](#g-predicate)** ([D-082][d-082],
[D-001][d-001]). It does so in one of two forms, either a `Bool`-valued form or
the sign of a continuous function. Under the normative convention, the
predicate holds when the function's value `σ` satisfies `σ ≥ 0`.

**An event fires when its predicate transitions from not-holding to holding**
([D-082][d-082], [D-001][d-001]). This is [edge semantics](#g-edge-semantics), and it is uniform across both forms.
[§10.6][s10-6] states the bookkeeping of the [prior](#g-prior). The prior is each event's predicate
sample stored at the previous [boundary](#g-boundary) (a published consistency point). The
opposite crossing direction is declared as a second event with the negated guard
([D-082][d-082], [D-361][d-361]). Stall entry and exit are one such pair. [D-180][d-180] records a
per-event `direction` keyword as a [guarded addition](#g-guarded-addition) (a capability the design
admits but does not build).

The predicate's form fixes its policy. A Boolean predicate is
[boundary-detected](#g-boundary-detected), and a sign-form predicate is
[localized](#g-localized) ([D-179][d-179]). [§10.4][s10-4] gives the
exactness result that motivates the Boolean form, and the gate idiom for
localizing mixed predicates. The two policies follow.

- Boundary-detected (cheap). The framework checks each guard for a not-holding →
  holding edge ([§10.6][s10-6]) at boundaries only. There is no
  root-finding and no step rejection. The handler fires at the first boundary
  that observes the edge. That boundary is the step's end, or a localized
  event time earlier in the step ([§10.4][s10-4]). This policy is fully compatible with
  fixed-step real-time execution.
- Localized (precise). The framework finds the crossing instant by
  root-finding ([D-018][d-018]). This policy serves events where timing
  precision genuinely matters. [§10.4][s10-4] gives the mechanics.

The two-policy arrangement gives step-boundary logic *well-defined semantics*. The
crossing defines the transition ([D-179][d-179]). The policy is part of the
model, and it fixes the resolution at which the crossing is observed. It never
depends on real-time [pacing](#g-pacing) (the waits that hold a run to
wall-clock time, [§10.7][s10-7], [D-080][d-080]).

Boundary detection is exact for a guard whose value within a step depends
only on modes, root inputs and held discrete outputs. None of these changes
between boundaries. Such a predicate therefore cannot cross there, and a
boundary check misses no crossing instant ([§10.4][s10-4], [D-365][d-365]). A guard that
reads an input fed by continuous state or by time can cross inside a step, as
a guard on its own state can.

Time events and state events differ in how their instants are found. **The
discrete [tier](#g-tier)'s [ticks](#g-tick) are [time events](#g-time-event)** ([D-220][d-220], [D-361][d-361]). A tier is one side of the
hybrid formalism, continuous or discrete. Ticks are declared by `sample_times`.
Their instants are known in advance and scheduled ([§10.5][s10-5]). Everything declared
through `StateEvent(guard, handler)` is a [state event](#g-state-event). Its instant is unknown and
must be detected, by boundary check or by localization. The criterion is detection
versus scheduling, not which fields a guard reads. A guard over an input is
still a state event.

Both policies read an edge by comparing the predicate's samples at
boundaries. An even number of crossings within one step returns the
predicate to its starting value. No edge appears, and nothing fires under
either policy ([§10.4][s10-4], [D-082][d-082]).

#### Localized events

A localized event adds a boundary inside a step, and the rest of this section
states its laws. It triggers when its prior did not hold and its predicate holds
at the step's end ([§10.4][s10-4], [D-082][d-082]). Root-finding then locates its time
`t*`, the crossing instant, to within a tolerance relative to `h` that the
deployment sets ([D-133][d-133]). The predicate holds at `t*`, and `t*` lies
strictly after the step's start ([D-290][d-290]). A crossing exactly at the
step's end is the ordinary grid boundary, and the event fires there as a
boundary-detected event would ([D-290][d-290]).

The state at `t*` is the step's continuous extension evaluated there, the
[interpolant](#g-interpolant) (a continuous extension built from the values
and derivatives at both ends of the step, [D-018][d-018]). The evaluations root-finding
makes inside a step read that raw state.
[Projection](#g-projection) (the per-component hook that returns state to its
manifold) applies only at the `t*` boundary itself. A projection that moves
the state back across the guard therefore cancels the firing, and the run
still publishes that boundary ([D-018][d-018]).

`t*` is a boundary of its own. The full event iteration runs there, in
rounds of [sweep](#g-sweep) (one pass through the stage functions), guard
checks and handlers repeated until none fires. It runs
with a fresh [firing budget](#g-firing-budget) (the per-boundary cap on how often
each event fires). No discrete component ticks there, and no
[root input](#g-root-input) (a source cell written from outside the model)
changes ([§10.4][s10-4], [D-081][d-081], [D-147][d-147], [D-181][d-181],
[D-290][d-290]). Integration then resumes from the settled state at `t*` and
finishes the step to the same grid point. That integration is the
[remainder step](#g-remainder-step) (the integration from `t*` to the original
grid target). When several localized events trigger in one step, the
earliest crossing becomes the boundary, and the later crossings are located
again on the remainder ([D-018][d-018]).

A [frame](#g-frame) (one grid step, the unit of scheduling) allows a bounded
number of localizations. That bound is its
[localization budget](#g-chattering) (the count of localizations permitted in
one frame). Past it, further crossings in that frame fire at the frame's end
boundary, as boundary-detected events would ([§10.4][s10-4], [D-018][d-018],
[D-133][d-133]).

An edge that an input change causes has no crossing to locate. Root inputs
change only at frame tops ([§2.2][s2-2]). Suppose the values applied there
make a localized predicate hold already at the step's start, and it still
holds at the step's end. The event then fires at the frame's end boundary
like a boundary-detected event ([§10.4][s10-4], [D-182][d-182],
[D-290][d-290]).

### 2.4 Runs

A run is one trajectory of a model, from its starting state to its last
boundary. This section fixes how a run starts, what it publishes, how it ends,
and what fixes its values.

#### How a run starts

A component declares an initial value for each of its
[stores](#g-store) (the framework-owned homes of `x`, `s` and `m`), and a run
starts from those values. An
applied [condition](#g-condition) (a path-addressed overlay of initial values)
overrides them leaf by leaf ([§14.1][s14-1], [D-063][d-063], [D-273][d-273]). A
condition sets continuous state, discrete state, modes and root inputs, and
nothing else. It never sets an output, because the first
[sweep](#g-sweep) (one pass through the stage functions) computes every
output from the initial state ([D-063][d-063]).

[Root inputs](#g-root-input) (source cells written from outside the model)
have no declared initial value. A run therefore starts only when its
condition gives every root input a value, and no placeholder ever fills a
missing one ([§14.6][s14-6], [D-068][d-068]). The initial state then passes through
[boundary zero](#g-boundary-zero) (the initialization boundary at `t₀`), an
ordinary boundary with no integration before it ([§5.3][s5-3]). A converged
trim starts a run the same way. It commits its solution as a condition
through boundary zero ([§14.8][s14-8], [D-067][d-067], [D-068][d-068]).

A run may instead resume from a [checkpoint](#g-checkpoint) (a saved state of
the model at a frame top). It starts from the checkpoint's state and clock,
and it runs no boundary zero ([§12.6][s12-6], [D-274][d-274]).

#### What a run publishes

Every completed [boundary](#g-boundary) (a published consistency point)
publishes one immutable [snapshot](#g-snapshot) (the per-boundary record of
the settled values). It holds the settled
[signal table](#g-signal-table) (the cells holding every produced signal),
meaning every declared [port](#g-port) (the addressable unit a component
publishes a value through) and every root input, with the boundary's time
([§11.2][s11-2], [D-023][d-023]). Boundary zero, every later grid point and
every localized event time each publish one ([D-081][d-081], [D-230][d-230]). The
sequence of snapshots is the run's observable trajectory. A state or mode
field is observable only through a port that publishes it ([§5.3][s5-3],
[D-252][d-252]).

Intermediate values are never published. They include the integration's
evaluations within a step, the evaluations root-finding makes inside a step,
and every event round (one pass of sweep, guard checks and handlers) before
the last ([§10.3][s10-3], [D-293][d-293]).

#### How a run ends

A run that does not fail ends at a completed boundary, in one of three ways.
A failure ends it otherwise ([§13.6][s13-6]).

- An end time stops the run at the first grid boundary at or after it. The
  last step is never shortened, so the final time can pass the end time by up
  to one step ([§12.4][s12-4], [D-133][d-133]).
- A [stop request](#g-stop-request) is an output port of a framework type
  whose value can request a stop ([§4.3][s4-3], [§13.5][s13-5]). It ends the
  run when its value requests a stop, unless the call advancing the run chose
  to ignore it ([D-316][d-316]). The run reads its stop requests after every
  published boundary, boundary zero and localized event times included. The
  first honored request to do so ends the run at that boundary. Its snapshot
  is the final state, with no rollback ([D-316][d-316]).
- An external stop comes from the operator, a device, calling code or an
  interrupt. It takes effect at the top of the next [frame](#g-frame) (one
  grid step of the run, [§12.1][s12-1], [D-269][d-269]).
  The step in progress completes and publishes first, so a stopped run's
  trajectory is a prefix of the unstopped one ([§12.4][s12-4],
  [D-132][d-132]).

#### What fixes a trajectory

Given identical compiled code, five things fix a run's trajectory. They are
the model, its origin `t₀`, its initial state, the root-input values applied
at each frame top, and the deployment parameters ([§11.5][s11-5],
[§12.7][s12-7], [D-067][d-067], [D-101][d-101], [D-254][d-254],
[D-273][d-273]). The deployment parameters are the step `h`, the
[base tick period](#g-dt_base) (the step of the lattice all discrete rates
share), the integration method, the localization tolerance and budget, and
the firing budget ([§9.2][s9-2], [D-133][d-133], [D-181][d-181],
[D-254][d-254]).

Nothing else changes a trajectory under that code. Each of the following
leaves it bit-identical ([§10.7][s10-7], [§11.2][s11-2], [§12.6][s12-6],
[D-021][d-021], [D-052][d-052], [D-269][d-269]).

- [Pacing](#g-pacing) (the waits that hold a run to wall-clock time) and
  pauses.
- Logging and attached readers.
- Caching inside the build (the reuse of artifacts built once per scalar
  type).
- Splitting a run across several calls that each advance it.

[Replay](#g-replay) (re-running the ordinary loop on a recorded input trace)
therefore reproduces a run bit for bit from its initial state and its
recorded inputs. That promise holds only against the identical build running
identical compiled code ([§12.7][s12-7], [D-101][d-101]). The same build
compiled at another optimization level agrees with it only to round-off
([§9.7][s9-7], [D-289][d-289]).

### 2.5 Exclusions (deliberate)

**The formalism deliberately excludes three constructs** ([D-001][d-001]).

- No differential-algebraic equations (DAEs) or algebraic constraints. The
  actual need is state manifolds, and [projection](#g-projection), the optional
  per-component hook `x ← x_projection(x)`, covers it ([D-001][d-001]).
- No stochastic differential equations (SDEs) or stochastic integrators. Noise
  processes, such as sensor noise and Dryden/von Kármán turbulence, are modeled
  as shaping filters ([D-001][d-001]), that is, as ordinary discrete processes driven by
  a random number generator (RNG). That modeling is faithful to how the noise
  processes are specified, and it is cheap. One consequence is elevated to a
  framework guarantee, deterministic [replay](#g-replay) (re-running the ordinary loop on a
  recorded input trace, [§2.4][s2-4], [D-101][d-101]). RNG state lives in
  the discrete state `s` of a [component](#g-component) (the unit of
  modeling, leaf or assembly), never in ambient globals. The same seed
  therefore gives a bit-identical trajectory ([D-231][d-231]).
- No unconditional per-step hook, because its semantics depend on the step
  size ([D-001][d-001]). The uses of such a hook decompose into projection and
  [boundary-detected](#g-boundary-detected) events (checked for edges at step
  boundaries only, no root-finding). A level-triggered reset becomes an
  edge-triggered event, which tightens the semantics ([§5.3][s5-3],
  [D-141][d-141]).

---

## 3. Component taxonomy

**The taxonomy has three categories of [component](#g-component)** ([D-003][d-003]).
Two of them are leaves with crisp, closed semantics, and one is pure
composition. [§3.1][s3-1] describes the continuous component, [§3.2][s3-2] the
periodic discrete component and [§3.3][s3-3] the assembly, and [§3.4][s3-4]
justifies the two-leaf split.

### 3.1 Continuous component (the hybrid primitive)

A continuous component is a classical hybrid automaton. It has these facets.

- Continuous state `x`, a NamedTuple whose leaves are real scalars and
  `SArray`s ([§7.1][s7-1], [D-094][d-094], [D-247][d-247]).
- Mode variables `m`. These are piecewise-constant values (enums, integers,
  flags) that parametrize the [flow](#g-flow) ([D-308][d-308]). **During a
  run they change *only* through event handlers**, at boundaries
  ([D-345][d-345]). Before a run, a condition may set them ([§14.1][s14-1]).
- Flow $\dot{x} = f(x, m, u, t)$.
- Two output stages ([§5.2][s5-2]).
- Events, each a [guard](#g-guard) (the declared function defining an event's predicate)
  plus a handler. A handler may update `m` and may reset the [component](#g-component)'s own `x`
  ([D-090][d-090]). Both guard and handler read the fresh [boundary](#g-boundary) [signal table](#g-signal-table) ([§5.3][s5-3],
  [D-154][d-154]).
- An optional [projection](#g-projection) (the per-component hook
  `x_projection`).

Any facet may be empty. In particular, a component with *no* continuous state,
only modes, events and mode-valued outputs, is a finite-state machine (FSM). **A
single primitive supports both factorings of mode logic** ([D-003][d-003]).

- Internal modes suit tightly coupled cases, such as stall hysteresis inside
  the aero component. They preserve cohesion and enable reset maps
  ([D-003][d-003], [D-362][d-362]).
- An external FSM component feeding modes through a [port](#g-port) (the addressable unit
  of the model) gives maximal purity, independent testability and swappable
  supervision logic.

The rule of meaning separates a command from a detection. A supervisor
*commanding* a mode change is an ordinary input. A component *detecting* its own
transition is an event. The two mechanisms carry two meanings, and **the
meanings do not overlap** ([D-345][d-345]). One change may still use both. On
the continuous [tier](#g-tier), a reset of state commanded through an input
still lands through an event whose guard reads that input ([§5.3][s5-3], [D-141][d-141]).

A branch in the flow that switches on a continuous quantity, such as an
integrator that stops accumulating once its output reaches a limit, is a mode
change with no declared event. It switches inside a step, at no boundary and
against no prior, so nothing localizes it and nothing records it
([§2.3][s2-3], [D-345][d-345]). Such a switch is spelled as a mode moved by an
event, or as a branch on another component's mode-derived output, which
changes only when that component's events fire.

### 3.2 Periodic discrete component

A periodic discrete component has these facets.

- Discrete state `s`, a NamedTuple whose fields are each isbits or a `Symbol`
  ([§7.3][s7-3], [D-231][d-231], [D-247][d-247]).
- Update $s^{+} = g(s, u, t)$ at a declared rate.
- Two output stages, with [feedthrough](#g-feedthrough) (an instantaneous
  input→output dependence) applying at update instants. A proportional path is
  direct feedthrough. A state-only output is not.

A discrete component has no events and no [projection](#g-projection) (the
post-step hook on continuous state), so its state changes only at its
[ticks](#g-tick) (the instants at which it runs its stages and update,
[D-001][d-001], [D-112][d-112]).

Ticks fall on a fixed lattice. Every discrete period is an integer multiple
of a [base tick period](#g-dt_base) (the step of the lattice all discrete
rates share, [D-019][d-019]). The base tick period is itself a whole number
of steps. Ticks therefore fall only on grid points, at
[boundary zero](#g-boundary-zero) (the initialization boundary at `t₀`) or at
a later grid boundary ([§2.1][s2-1], [§10.5][s10-5]). A component ticks at
its [phase](#g-phase) (its offset from the origin, in base ticks) plus whole
multiples of its period, and at no other [boundary](#g-boundary) (a published
consistency point). No component ticks at a [localized](#g-localized) event
time, an event's crossing instant inside a step ([D-147][d-147],
[D-185][d-185], [D-291][d-291]). The enclosing assembly declares the rate
([§3.3][s3-3]).

A tick's update is the outgoing transition. It consumes the samples of the
boundary it runs at and produces the state the component's next tick reads
([§5.3][s5-3], [§14.5][s14-5], [D-067][d-067]).

**Each [tier](#g-tier) carries its own state letter** ([D-195][d-195]). `x` is
the argument of the [flow](#g-flow) map under `f`, and `s` is the argument of
the jump map under `g`. The two are different objects. `x` has a derivative and
lives in the flat [buffer](#g-buffer). `s` has none and is latched in a
[store](#g-store) (the framework-owned home of a state letter) between
ticks. A leaf is strictly one tier ([D-056][d-056]), and no
[component](#g-component) ever reads another's state. A discrete component's
`s` influences continuous dynamics only through signals ([D-056][d-056]).
Those outputs are held zero-order between ticks ([D-019][d-019]).

A stateless discrete leaf, one whose `s` is empty, still computes its outputs
only at its ticks and at boundary zero ([§5.3][s5-3], [D-205][d-205]). It
holds them in between. A
stateless continuous leaf recomputes them at every [sweep](#g-sweep) (one pass
through the execution order). The tier of a stateless leaf therefore changes
its values ([§8.2][s8-2], [D-019][d-019], [D-263][d-263]).

**`m` is continuous-only** ([D-231][d-231], [D-249][d-249], [D-362][d-362]). A
discrete component has no mode store. Its finite-state machine (FSM) enums,
flags and counters are ordinary `s` fields. `m` exists on the continuous side
because modes must change *between* flow evaluations, which is what handlers do.
On the discrete side `g` already runs at the only instants at which anything may
change. A second store would duplicate the discrete tier's own state semantics
under another name.

### 3.3 Assembly

An [assembly](#g-assembly) is pure composition. It holds child components,
[local wires](#g-local-wire) and boundary [faces](#g-face) (the names ports
wear on a component's boundary). It has no dynamics of its own. Hybridness
emerges at the assembly level. An aircraft is continuous vehicle parts plus
discrete avionics parts. The two-leaf split was upheld against the
integrate-and-dump challenge ([§3.4][s3-4], [D-056][d-056]). Assemblies are
flattened away for ordering ([D-019][d-019]). They are retained as the
navigation and introspection hierarchy (GUI, logging, paths) and as
declaration-level [rate scopes](#g-rate-scope) ([§10.5][s10-5],
[D-019][d-019]).

An assembly declares the rate of each discrete child it holds, in one of two
forms. The relative form ticks the child every K-th tick of the enclosing
scope, starting from a chosen phase. The absolute form gives a period and an
offset in seconds, and it detaches the child from the scope's ticks
([§8.7][s8-7], [D-185][d-185], [D-186][d-186]). Relative entries compose down
the tree, periods multiplying and phases adding. Each discrete component
therefore ends with one period and one phase on the base grid
([§10.5][s10-5], [D-291][d-291]).

### 3.4 Why two leaf classes, not one hybrid primitive

One all-in-one primitive could carry continuous state, modes *and* discrete
state together. The design rejects it, and every leaf belongs to exactly one
[tier](#g-tier) (the continuous or the discrete side of the formalism,
[D-056][d-056], [D-263][d-263]).

**The split is between *time bases*, not state classes** ([D-056][d-056]).
The [continuous component](#g-continuous-component) is already hybrid. It
carries modes `m`, [guards](#g-guard) (functions that define an event's
predicate) and handlers ([§3.1][s3-1]). What separates the two leaf classes is
[sweep](#g-sweep)-driven versus [tick](#g-tick)-driven execution. A sweep is
one pass through the execution order against the current state. A tick is an
instant at which a discrete component's stages and update run.

An all-in-one [component](#g-component) is an [assembly](#g-assembly) (pure
composition) of two primitives in a trench coat ([D-056][d-056],
[D-362][d-362]). Its two halves would still communicate exactly as two
siblings do, through [cells](#g-cell) of the published signal table. It buys
no expressiveness. It incurs costs of its own, which [D-056][d-056]
enumerates. One of those costs is not bookkeeping. The sampling interface is
the zero-order hold (ZOH) plus the one-sample `z⁻¹` delay. It is the most
bug-prone boundary in a flight-control stack. A monolith swallows it. The
split keeps it a visible wire.

#### The hardest case: integrate-and-dump

A strapdown inertial measurement unit (IMU) integrates over each sample
interval and zeroes its integrals at every sample. No construct expresses
that periodic reset of `x`. An update writes only its own `s`, and guard-driven handlers
are the sole writers of continuous state ([D-141][d-141], [D-362][d-362]). A
periodic reset is scheduled, not detected, so it is not an event either
([D-362][d-362]).

Integrate-and-dump, the strongest challenge to the split, factors exactly into
cumulative integrals and a sampler that differences against its latch
([D-056][d-056]). [§8.6][s8-6] works the IMU in full.

**The recorded, unbuilt escape hatch is a tick-triggered handler on continuous
components** ([D-056][d-056]). Such a handler is a periodic event, and a
[guarded addition](#g-guarded-addition) (a capability the design admits but
does not build).

---

## 4. Ports and signals

This chapter defines the [port](#g-port), the addressable unit through which components
exchange immutable values. [§4.1][s4-1] states the immutable value semantics of signals;
[§4.2][s4-2] why consumers see ports, not stages; [§4.3][s4-3] the table mechanics and port
granularity; and [§4.4][s4-4] function-valued signals for environment access.

### 4.1 Immutable value semantics

**[Ports](#g-port) exchange immutable values** ([D-004][d-004]). The values are typically isbits structs
(floats, `SVector`s, enums, nested immutables). The framework owns a [signal table](#g-signal-table),
with one concretely typed [cell](#g-cell) per output port in the flattened model. A
producer's output [stage function](#g-stage-function) (`y_state`/`y_direct`, the two output stages every
leaf provides, on either [tier](#g-tier), continuous or discrete) returns a NamedTuple
of fresh values. The framework writes each of those values into its cell, and
consumers read cells.

These names are binding throughout this document.

- **A bare *cell* is the table entry, and only that** ([D-121][d-121]).
- A *[store](#g-store)* is the framework-owned home of one of a [component](#g-component)'s
  state letters, `x`, `s` or `m` ([§7.1][s7-1], [§7.3][s7-3], [D-302][d-302]).
  An `x` store is a range of the [buffer](#g-buffer) (the contiguous vector
  backing all continuous state). Stores are not cells.
- A *[root input](#g-root-input)* is a source cell fed by the
  [periphery](#g-periphery) (everything outside the loop that exchanges data
  with it) rather than by a producer ([§11.3][s11-3]).

Stated precisely, **the signal requirement is immutability plus frozen
references** ([D-344][d-344]). Signals may reference bulk data
([§4.4][s4-4]) provided that data is read-only for the duration of the run
([D-231][d-231], [D-344][d-344]). `isbits` is the common case, not the rule.

The signal requirement has four consequences.

- There is no aliasing, ever. Nothing can be mutated under a consumer's feet.
- Concurrent reads from the GUI and logging threads are safe by construction.
- Isbits payloads allocate nothing, because NamedTuples of isbits are isbits.
- Each cell has a definite freshness, tied to its producer's position in the
  [execution order](#g-execution-order), the order in which the stage
  functions run ([D-004][d-004], [D-363][d-363]).

### 4.2 Consumers see ports, not stages

The [port](#g-port) is the addressable unit. A [component](#g-component)'s
outputs appear to consumers, the GUI and logs as one flat namespace of ports,
such as the illustrative paths `"dyn/vel"` and `"dyn/f_c_c"` ([D-040][d-040]). A reader
can reach any leaf inside a port value ([§14.4][s14-4], [D-276][d-276]). Which output stage
computes which port is an ordering annotation, invisible outside the component.
Moving an output between stages is non-breaking *for consumers*. No wire, log or
panel sees it. The build does see it, because the [feedthrough](#g-feedthrough) graph (the graph
of instantaneous input→output dependences) and stage membership change ([§9.1][s9-1]).

Which ports exist at all is a declaration-layer decision. The output
[contract](#g-contract) (the ports a component declares in `y_types`) *is* the
public interface ([D-034][d-034]). There are no private intermediates. A value a
later function needs is a declared port like any other
([§5.2][s5-2], [D-194][d-194]).

### 4.3 Table mechanics and port granularity

[§4.2][s4-2] fixed the [port](#g-port) as the addressable unit. Four questions
remain. What is a port on a [component](#g-component)'s boundary? How do values
travel into [cells](#g-cell) (the typed entries of the signal table) and out of
them? What may a port hold? And how much should a single port carry? The last
question has two answers, one owed to the parties that read a port and one to
the parties that write it.

#### Ports and faces

A component's ports are its signal endpoints, one cell and one producer each.
**Its [faces](#g-face) are the names those ports wear on the component's
boundary** ([D-172][d-172]). For a leaf the two coincide. For an
[assembly](#g-assembly) (pure composition of child components) every face
aliases an interior port through its boundary declarations ([§8.6][s8-6]) and
never creates an endpoint. The distinction is [class](#g-class)-blind ([D-172][d-172]).
Wiring and the [periphery](#g-periphery) (everything outside the loop that
exchanges data with it) address a child's faces without knowing whether it is
primitive or composite.

The port is the unit of every external read and write ([D-363][d-363]).

#### Scatter and gather

Scatter/gather is the whole protocol. A [stage function](#g-stage-function) (`y_state`/`y_direct`)
returns a NamedTuple on either [tier](#g-tier), continuous or discrete. The framework
scatters each field into that port's concretely typed cell. Every reader gathers
views from cells. The readers are the next stage, `x_deriv`/`s_update` ([§5.2][s5-2]),
[guards](#g-guard), wired consumers and [snapshot](#g-snapshot) capture. A guard is the function defining
an event's predicate, and the snapshot is the immutable per-boundary
publication.

**The aggregate `y` is a merge semantically and virtual physically**
([D-036][d-036]). Semantically, a component's `y` is the merge of its stage
products, `merge(y_x, y_xu)` on the continuous tier and `merge(y_s, y_su)` on
the discrete ([§5.2][s5-2]). It carries declared ports only and exists as no
stored object ([§9.7][s9-7]).

#### What a port may hold

**Stage returns are NamedTuples of port values, period** ([D-036][d-036]). **A custom struct is
a first-class port value** ([D-036][d-036]). It is one field of the returned tuple, one
declared port, one cell (`pose = KinPose{T}`, where `KinPose` is an illustrative
struct). Nested fields get no cells of their own. A reader reaches a nested
field through the port's [leaf address](#g-leaf-address), as in `"pose.q_eb"` ([§14.4][s14-4], [D-276][d-276]). A wired
consumer takes the bundle (the struct-valued port) whole. Bare-struct returns
are rejected ([D-036][d-036], [D-363][d-363]).

A port value's leaves are what the [leaf walk](#g-leaf-walk) (the framework's derivation of
per-activation types) reaches through `Real`s, static arrays and isbits structs
([D-237][d-237]). An enum is one leaf, pinned ([§8.2][s8-2], [D-316][d-316]). `StopFlag` is the one enum
with a framework meaning. An output port of that type is a
[stop request](#g-stop-request) (a port that can end the run, [§2.4][s2-4], [§13.5][s13-5],
[D-316][d-316]).

**The walk stops at an immutable type that is not isbits and treats it as one
opaque leaf** ([D-237][d-237]). The table stores an opaque leaf whole,
references included. A [field handle](#g-field-handle) (an immutable query
object a consumer evaluates at arguments of its own choosing, [§4.4][s4-4]) is
such a leaf. **A `Symbol` is an opaque leaf too** ([§7.3][s7-3],
[D-243][d-243]). So a `Symbol` mode publishes like any other. **A mutable type
anywhere in a port value is refused, and so is an opaque leaf surfacing as a
root input** ([§4.4][s4-4], [D-237][d-237]). A
[root input](#g-root-input) is a source cell the periphery feeds.

#### Granularity, read side

**Wiring is port-granular** ([D-276][d-276]). There are no sub-field
connections. A consumer that wants less than a bundle takes the bundle and
destructures it, or asks the producer for a loose port ([D-276][d-276]). It
destructures the bundle in its own stage or through an ordinary component that
publishes its fields.

A field-projection connector is a [guarded addition](#g-guarded-addition) ([D-036][d-036], [D-363][d-363]), a capability
the design admits but does not build. Its shape is obvious.

Under the granularity guideline, **authors should bundle what shares a stage
*and* is consumed together** ([D-036][d-036]). The first criterion is trivially
enforced, because each port has exactly one producing function. Bundling
across dependency footprints is the classic mistake. A kinematics bundle
mixing pose, which is stage 1 ([§5.2][s5-2]), with velocity-derived
quantities, which are stage 2, must split.

Fan-out is free ([§6.1][s6-1]), so publishing both a bundle and a hot loose
field (`pose` *and* `q_eb`) is legitimate ([D-276][d-276]). It costs one extra isbits cell.

The sketch below shows the bundle, the loose hot field and a face aliasing an
interior port, in declaration form. `Kinematics` and `Vehicle` are illustrative
names. An `output_wires` entry sources a face from an immediate child's face
([§6.1][s6-1]). `RQuat` is a rotation-quaternion type ([§7.1][s7-1]).

```julia
#a continuous leaf: one bundle port and the hot field published loose — two cells
y_types(::Kinematics) = (pose = KinPose{Float64}, q_eb = RQuat{Float64})

#the enclosing assembly: each face aliases an interior port, creating no endpoint
output_wires(::Vehicle) = ("kin/pose" => "pose", "kin/q_eb" => "q_eb")
```

#### Granularity, write side

Under the write-side rule, **data written by different external writers, or at
different cadences, must not share a port** ([D-045][d-045], [D-346][d-346], [D-363][d-363]). In short,
bundle what is written together.

Pilot commands are the case in point. They are scalar faces under a namespace
prefix. The convenient bundle is assembled *downstream*, inside the graph, by
an ordinary component. Assembling it there is legal by the read-side
guideline, since the bundle has a single producer and is consumed together.

The granularity guideline and the write-side rule compose into one principle
([D-036][d-036], [D-346][d-346]). The finest-grained party owning either end
sets a port's granularity. That party is a producer on the read side and an
external writer on the write side. **Field-addressed staging is a recorded
guarded addition** ([D-346][d-346]). It is a lens into struct slots, and it
stays unbuilt.

### 4.4 Function-valued signals: environment access

Atmosphere and terrain are query-shaped. Consumers evaluate them at arguments of
their own choosing, such as each gear strut at its own contact point, or airflow
at the vehicle pose. **Ordinary [ports](#g-port) carry them as immutable query objects**,
called [field handles](#g-field-handle), because of that shape ([D-008][d-008]). A port is one declared name
with its cell.

- An environment [component](#g-component) (the unit of modeling, leaf or
  assembly) emits a field value, such as the illustrative
  `ISAField(T_sl, p_sl, wind)` or `TerrainField(…)`. Consumers receive it
  through ordinary input ports. Inside their own
  [stage functions](#g-stage-function) (`y_state`/`y_direct`) they call query
  functions on it, such as the illustrative `airdata(field, pos, vel)` and
  `ray_intersect(field, p, u)`.
- Parametric environment models are isbits. Examples are the International
  Standard Atmosphere (ISA), uniform wind and horizontal terrain. Bulk-data
  environment models use the handle pattern. The handle is an immutable struct
  combining isbits parameters with references to bulk data loaded at build
  time and frozen. Such bulk data includes heightmaps, wind grids and the geoid
  undulation grid (the geoid's height above the reference ellipsoid).
- Bulk data reaches a signal only through a component that emits its
  handle, never through a [root input](#g-root-input) (a source cell the
  periphery feeds, [D-237][d-237], [D-364][d-364]). The emitter loads the data when the model
  is built and freezes it there. A root input instead comes from outside the
  model and is recorded with the run by value. A bulk-data handle can be
  neither recorded faithfully that way nor kept frozen in a writer's hands.
  An isbits handle, such as a parametric atmosphere, may be a root input like
  any other value. Lookup tables and other instance data are not signals, and
  [§7.2][s7-2] and [§7.3][s7-3] state where they live.
- **A field object must hold no mutable cache**, such as a memoizing
  interpolator or a lazy loader ([§4.1][s4-1], [D-344][d-344]). Concurrent
  consumers and the GUI thread would race on it. The remedy is to restructure
  the interpolant to be pure. The rule is the author's, because the build does
  not look inside a field handle ([D-237][d-237]).

Each field-emitting component also exposes a
[value-level constructor](#g-value-level-constructor) (a plain public function
from its input values to its handle). A script calls it to build, outside
any sweep, the same handle the sweep would produce ([§8.2][s8-2],
[D-139][d-139]).

#### Pre-sampling and substitutability

Pre-sampling is an idiom built on top, used where natural, not a separate
mechanism ([D-008][d-008], [D-363][d-363]). In it, a component consumes the
field and a pose and emits plain data, as an illustrative `Airflow` component
emits FlightPhysics' `AirData` for the whole vehicle.

A consumer may accept any handle type below a declared bound, so environment
models substitute behind a stable [face](#g-face) (the name a port wears on
its component's boundary). That is structural substitutability ([§8.2][s8-2],
[D-078][d-078], [D-296][d-296]).

---

## 5. Evaluation order and feedthrough

This chapter fixes two output stages per leaf, what each stage may see, and
how those signatures alone yield a static execution order. The build derives
that order from declared feedthrough and rejects algebraic loops by naming the
cycle. [§5.1][s5-1] states the ordering problem; [§5.2][s5-2] the two output stages, their
signatures, bundles and the hand-off laws; [§5.3][s5-3] the stage roles, the execution
order, step boundaries and supervisory inputs; [§5.4][s5-4] artificial loops and the
escape hatch; and [§5.5][s5-5] the policy that rejects algebraic loops at build time.

### 5.1 The ordering problem

At every evaluation instant, all signals must be computed consistently. Every
consumer reads values already produced at that instant. The build constructs the
directed graph of wiring edges and intra-[component](#g-component) [feedthrough](#g-feedthrough) relations
(instantaneous input→output dependences). If the graph is acyclic, a topological
sort yields a static [execution order](#g-execution-order) (the order in which the stage functions
run), computed once at build time ([D-048][d-048]). No graph logic runs
while the model runs ([§9.7][s9-7]). A cyclic graph is the subject of
[§5.4][s5-4] and [§5.5][s5-5].

### 5.2 Two-stage outputs: signatures, bundles and the hand-off laws

**Every leaf provides exactly two output stages** ([D-006][d-006]). [Feedthrough](#g-feedthrough) (an
instantaneous input→output dependence) is declared structurally, by function
signature. There are no dependency annotations anywhere in the design ([D-006][d-006],
[D-341][d-341]). `y_state` is stage 1 and `y_direct` is stage 2.

```julia
# continuous component — maximal legal view set of each bundle in comments
y_x  = y_state(comp, args)       # x, m, t [, ws] — no-feedthrough stage
y_xu = y_direct(comp, args)      # x, m, u, y_x, t [, ws]
ẋ    = x_deriv(comp, args)       # x, m, y, u, t [, ws]

# discrete component — the same two stage names over its own state letter
y_s  = y_state(comp, args)       # s, t, Δt [, ws]
y_su = y_direct(comp, args)      # s, u, y_s, t, Δt [, ws]
s⁺   = s_update(comp, args)       # s, y, u, t, Δt [, ws]

# every output stage returns its port NamedTuple — the return law below

# event system (continuous side only) — same fresh table, same state views:
σ        = guard(comp, args)        # x, m, y, u, t [, ws] — Bool or scalar sign value (§2.3)
(; x, m) = handler(comp, args)      # x, m, y, u, t [, ws] — keys by the return law below (§9.5)
x⁺ = x_projection(comp, x)      # manifold projection; takes the state alone
```

The laws that govern that surface follow. They fix how a function receives its
arguments, where each [view](#g-view) comes from, which names it receives, what an output
stage returns, and what a handler returns.

#### The hand-off: one component, one bundle

Each function receives its [component](#g-component) and one
[bundle](#g-bundle), a defined set of named, zero-copy views of the data it
may read ([D-074][d-074]). The body reads views by name, never by position.
The projection alone receives no bundle. Beside its component it receives
only the state it projects ([§8.2][s8-2]).

#### What the views are

The views come from the sources below.

- Own state. On the continuous [tier](#g-tier) (the continuous or discrete side of the
  hybrid formalism), `x` comes from the flat [buffer](#g-buffer) and `m` from the mode
  stores. On the discrete tier, `s` comes from its store.
- Own published signals. `y` is gathered from the component's own [cells](#g-cell)
  (concretely typed table entries, one per output port) in the [signal table](#g-signal-table).
  Those cells are the declared [ports](#g-port) ([§8.2][s8-2]).
- Inputs. `u` is gathered from foreign cells through the wiring, by name.
- The clock. `t`, and on the discrete tier `Δt`, the component's own tick
  period. `Δt` is the same in both output stages and in the update, and the
  component's phase never changes it ([§10.5][s10-5], [D-019][d-019],
  [D-291][d-291]).
- Scratch. `ws` ([§7.3][s7-3]).

**The signal table holds only *produced* signals, never transported ones**
([D-035][d-035]). Each datum has exactly one home. The buffer holds `x`, the
`s` and `m` stores hold `s` and `m`, and the table holds signals. No store
mirrors another. Every bundle field earns its place as a view genuinely
readable. No minimization of the set survives without introducing a copy
([D-035][d-035]).

#### The bundle law: which names a component receives

Under the bundle law, **a name appears in a component's bundle iff the
corresponding store or fact exists for that component** ([D-074][d-074], [D-341][d-341]).

| bundle field | present iff |
|---|---|
| `x` | the component declares a non-empty `x_init` (continuous tier) ([D-297][d-297]) |
| `s` | the component declares a non-empty `s_init` (discrete tier) ([D-297][d-297]) |
| `m` | the component declares a non-empty `m_init` ([D-297][d-297]) |
| `ws` | the component declares `ws_init` |
| `u` | the [function family](#g-function-family) (which bundle fields a given function may legally receive) may see inputs and the component declares `u_types` |
| `y` | the component produces any table cell at all (it declares `y_types`) |
| `y_x` / `y_s` | stage-1 ports exist, under the tier's own spelling |
| `t` | always |
| `Δt` | the component is on the discrete tier |

Undeclared stores are *absent*, never `nothing`-filled.

**The stage-1 hand-down carries the stage-1 *return*** ([D-285][d-285]).
`y_x`, or `y_s` on the discrete tier, is what stage 1 returned in the same
evaluation. A component with no stage-1 ports has no `y_x`/`y_s` in its
stage-2 bundle at all.

A function that reads a name outside its bundle is an error, whether the name
is an undeclared store, a fact of the other tier or a name illegal for that
function ([D-341][d-341]). [§13.2][s13-2] describes how the build recognizes
and reports it.

The per-function name sets are closed ([D-074][d-074], [D-341][d-341]), one set per function
per tier. The update laws carry their tier in the name, so `x_deriv`
and `s_update` have one set each. The two output stages are shared machinery
over both tiers ([D-220][d-220]), so `y_state` and `y_direct` have one set per
tier. On the continuous tier the `y_state` and `y_direct` sets are
`x, m, t [, ws]` and `x, m, u, y_x, t [, ws]`. On the discrete tier they are
`s, t, Δt [, ws]` and `s, u, y_s, t, Δt [, ws]`. Adding a name to any of them
is a decision-log entry, not a convenience.

The comments in the signature block above state each function's maximal legal
set at each tier. A given component's bundle narrows that set to declared
reality, and the destructuring narrows it further to actual reads. That
three-level funnel (stage name at its tier ⊇ bundle ⊇ reads) is worth teaching
once ([D-341][d-341]), because a stateless component legitimately writes `y_direct` while
owning neither `x` nor `m`.

#### The stage return law

**An output stage returns its port NamedTuple, `y`, and nothing else**
([D-194][d-194]). `y` scatters into the component's declared cells as always,
and every value a later function needs is one of those cells ([§8.3][s8-3]).
The stages' products partition the declared ports ([D-252][d-252]). A stage
that exists produces at least one port ([D-285][d-285]).

Each returned value carries exactly its port's declared type at the
[nominal](#g-nominal) scalar (`Float64`, the scalar a simulation runs at),
with no conversion on write ([§9.5][s9-5], [D-053][d-053]). A return pairs
with the ports by name, so its field order means nothing ([D-151][d-151]).
Every branch of a stage returns the same ports at the same types ([§8.3][s8-3],
[D-034][d-034]).

#### The handler return law

**A handler returns a NamedTuple carrying the stores it writes**
([D-090][d-090]). A key is present iff the corresponding store exists on the
component and the handler updates it.

That is the bundle law's *iff* shape, now governing the return side. A pure
FSM (finite-state machine, with modes and events and no `x`) returns
`(; m = (; phase = running))`. An `x`-only reset map returns
`(; x = (; x..., ω = 0.0))`. A handler touching both returns both.

The return's semantics are per key ([D-287][d-287]). When `x` is present, the
value is complete against the state field set. A present `m` names a subset
of the component's mode fields, at their declared types ([§9.5][s9-5],
[D-090][d-090], [D-341][d-341]). A key naming
no store of the component is an error ([§9.5][s9-5]). A present `x` replaces
the whole continuous state. A present `m` merges, so the mode fields the
handler omits keep their values ([D-053][d-053], [D-287][d-287]).

### 5.3 Structural feedthrough: stage roles, execution order and step boundaries

[§5.2][s5-2] fixes the two-stage surface and the laws that govern it. What remains is
the reading. A stage's role has two halves, what its name asserts and what it
may see. The section takes the names first, then what each stage may see, then
why derivatives may read outputs. The rest of the section orders the stages,
then puts that order inside a step [boundary](#g-boundary) (a published
consistency point). It ends with two supervisory inputs, scheduled gains and
commanded resets.

#### Stage roles: the names

**Mathematical symbols and API names are two vocabularies**, deliberately
([D-220][d-220]). This document's formulas keep the symbols of the traditions
they come from. `f` is the continuous [flow](#g-flow), the derivative function.
`g` is the discrete update. The two form the hybrid-systems flow/jump pair
(Goebel–Sanfelice–Teel). The output map is `h` in `y = h(x, u)`, the
control/estimation convention, as in every navigation filter's measurement
function. The API spells the same objects as words. The correspondence is
one to one.

| symbol | declaration |
|---|---|
| `f`, the flow | `x_deriv` |
| `g`, the jump | `s_update` |
| `y = h(x)` | `y_state` |
| `y = h(x, u)` | `y_direct` |

**A stage's name states the dependence class**, not the argument list
([D-220][d-220], [D-342][d-342]). `y_state` is the `y = h(x)` case and `y_direct` the `y = h(x,
u)` case. So "no `direct` in the name" *is* the no-[feedthrough](#g-feedthrough)
property (no instantaneous input→output dependence), visible at every
definition site. Modes count as state for that split ([D-075][d-075],
[D-342][d-342]).

The update law carries the [tier](#g-tier) (the continuous or discrete side of the hybrid
formalism) in its name, `x_deriv` versus `s_update`. The two output stages do
not. One pair of names serves both tiers, over each tier's own state letter
([D-220][d-220]). A stateful leaf's declarations must agree on one tier throughout ([§8.2][s8-2],
[D-112][d-112]).

#### Stage roles: what each stage may see

**`y_state` is the no-feedthrough stage**, defined entirely by what it cannot see
([D-035][d-035]). Its [bundle](#g-bundle) (the NamedTuple of zero-copy views a component function
receives) carries no `u`, so "no feedthrough" cannot be violated by
construction. That structural guarantee is what stage-1 [ports](#g-port) (the model's
addressable units, one declared name each) contribute to the feedthrough graph.
Stage-1 ports break would-be loops.

Stage 1 exists when the [component](#g-component) has state-derived ports, including any
state-derived intermediate a later function reads ([§5.2][s5-2]). Otherwise it is simply
absent.

A declared output is produced by stage 1 or by stage 2, and by nothing else
([D-252][d-252], [§8.3][s8-3]). **A component exposes a state or mode field by
returning it from `y_state`** ([D-252][d-252]). The line is one method,
`y_state(c, b) = (; q = b.x.q)`.

`y_direct` receives all wired inputs plus the stage-1 hand-down
([D-006][d-006], [D-194][d-194]). The hand-down is the component's own stage-1 ports. A shared
intermediate is therefore computed once and read, not re-derived. Stage 1
declares it as a port, and stage 2 finds it in `y_x`, or `y_s` on the discrete
tier ([D-194][d-194]). Stage 2 receives the [state views](#g-view)
(zero-copy reconstructions of the component's stores) too.
Conservatively, every stage-2 output is presumed dependent on every wired input
([D-006][d-006]).

**`x_deriv` and `s_update` run after the [sweep](#g-sweep)** (one ordered pass through the stage
functions against the current state) ([D-015][d-015]). They run when the full
[signal table](#g-signal-table) (the framework-owned collection of cells holding every produced
signal) is complete and fresh, the component's own stage-2 ports included
([D-015][d-015]). The fused idiom stands. Compute each law once, in a stage. Publish it.
Let `x_deriv`/`s_update` copy from `y`. The interfaces *reward*
single-source-of-truth rather than making duplication unwritable. Nothing ever
needs computing twice ([D-015][d-015], [D-035][d-035]). Computing a law twice invites drift, an
edited law in one place and a stale copy in the other ([D-015][d-015], [D-342][d-342]).

All output stages must be pure, with no side effects ([D-015][d-015], [D-342][d-342]). State
types make mutation impossible anyway ([§7][s7]).

#### Derivatives that read outputs

The design departs from the orthodox formalism, and says so openly. The
textbook form is $\dot{x} = f(x, u)$, $y = h(x, u)$. This design's `f` receives
the orthodox arguments *plus* the signal table, $\dot{x} = f(x, m, y, u, t)$.
The composite map $x \mapsto \dot{x}$ is mathematically identical, so
linearization, trim and automatic differentiation (AD) are untouched. The
heterodox element is only that derivatives may read outputs.

The teaching line is this. *"stage 1 publishes what you know from state alone;
stage 2 adds what needs inputs; your dynamics read your own published results
instead of recomputing them."*

The reason for this departure is that derivative/output overlap is the *norm* in
physical and control models. Newton–Euler dynamics computes accelerations that
are at once published outputs and state derivatives. Kinematics, engine models,
gear friction and every discrete compensator show the same overlap. That overlap
is what makes the orthodox split expensive here ([D-015][d-015], [D-342][d-342]).

Shared expensive computations are solved uniformly by the fused idiom above.
Compute once in stage 2, publish, and let `x_deriv`/`s_update` consume the
ports. External consumers read the same ports, as an accelerometer model reads
`f_c_c` (see the strapdown IMU example in [§8.6][s8-6]). The
computer/integrator split remains fully expressible without framework support
([D-015][d-015]). [§7.4][s7-4] carries the full statement, including when the
factoring earns its keep. Purity rules forbid the classic resolution by mutable
caching, by design ([D-015][d-015], [D-342][d-342]).

#### The execution order

Execution runs all stage-1 functions in any order, then stage 2 in topological
order, then all `x_deriv` calls against the now-consistent signal table
([D-288][d-288], [§9.7][s9-7]).

**Evaluating the right-hand side (RHS) means running the sweep**
([D-347][d-347]). It is the systemic consequence of this execution order. The
RHS is the flow, `x_deriv`, and it reads the table the sweep has just
refreshed ([§10.3][s10-3]). Inside a step no discrete stage runs, whether the
evaluation serves the integration or the root-finding that locates an event
([§10.5][s10-5], [D-147][d-147]). Discrete [cells](#g-cell) (concretely typed
table entries, one per output port) therefore hold across the step.

#### Step boundaries

[Guards](#g-guard) (the declared functions defining events' predicates) and
handlers read the same fresh world. At each step boundary the framework runs
the boundary sequence. It integrates, projects, runs the boundary
sweep (the full pass that refreshes the signal table, including the discrete
components due at this boundary), evaluates *all guards once* against that sweep,
and fires the eligible events. So by guard and handler time `y` is a fresh
decode of exactly the state being transformed, and the state views are that
state itself. Handlers construct their `x`/`m` returns from raw state naturally.
A reset map is `(; x = (; x..., ω = 0.0))`, with no reassembly from published
fields.

Each firing is `handler → x_projection`. The sweep → guards → handlers phase
then iterates to [quiescence](#g-quiescence) (the fixed point where a round of
handlers fires nothing), so newly enabled guards fire within the *same*
boundary ([D-020][d-020]).

> integrate → project → [ sweep → guards → handlers ] iterated to quiescence
> → due updates → publish

The output stages of the discrete components [due](#g-due) (scheduled to run
at this boundary) run inside every round's sweep, against their unchanged
`s`. At quiescence their outputs therefore reflect the settled instant
([§10.6][s10-6], [D-020][d-020]). Only then does every due update run, in any
order, each reading the settled table and writing only its own `s`
([§10.5][s10-5], [D-020][d-020]). The boundary then publishes its [snapshot](#g-snapshot)
(the immutable per-boundary record of the settled values, [§2.4][s2-4]).

The state a [tick](#g-tick) (an instant at which a discrete component's stages
and update run) writes stays invisible until the owner's next tick. No guard
can see it. A tick therefore never triggers an event, and events and ticks
need no joint fixed point ([§10.6][s10-6], [D-292][d-292]). A model with no continuous
state runs the same sequence at every grid point with an empty integration
([§10.2][s10-2], [D-156][d-156]).

**`x_projection` runs between a state write and its decode** ([D-016][d-016]). That is after
integration, and after any handler `x`-reset. Those are the only positions in
the boundary sequence where no fresh `y` of the new state can exist yet.
`x_projection` is not *unique* in receiving raw state, since every function gets
state views. It is unique in that position of the boundary sequence.

The signal table is written *only by sweeps*, so a transition reaches the
table at the next round's re-sweep ([§10.6][s10-6], [D-154][d-154]). The round
that detects quiescence leaves the table post-transition-consistent for
whatever else the boundary does, such as the due updates and publication.

Under the epoch rule ([§10.6][s10-6]), a handler executes against exactly the
world its guard fired on ([D-154][d-154]). Own `y`, foreign `u` and own
`x`/`m` alike come from the firing round's sweep, so `y = h(x)` holds at every
handler entry.

[§10.6][s10-6] gives the iteration's mechanics, and its firing rule is a law
of the model. In each round an event fires if and only if its predicate holds
now, its last observed sample did not hold, and it has not spent its
[firing budget](#g-firing-budget) (the per-boundary cap on how often each
event fires) at this boundary ([D-181][d-181]). A predicate that keeps
holding therefore fires once. One that is falsified and enabled again within
the boundary fires again.

Within a round each component fires at most one event, and declaration order
picks among that component's simultaneously eligible events ([D-154][d-154]).
A blocked event keeps its edge and is re-decided in the next round against
the post-transition sweep ([D-191][d-191]). Same-component sequential
composition therefore happens *across* rounds, never on a stale premise.

Once an event spends its firing budget at a boundary, its further edges there
are dropped. Every other event iterates as usual, and the run continues
([D-181][d-181], [D-292][d-292]). At quiescence each event's final sample
becomes its [prior](#g-prior) (the predicate sample the next boundary tests
against, [D-082][d-082]).

Initialization runs one ordinary boundary at `t₀`, with an empty integration.
That boundary is [boundary zero](#g-boundary-zero) (the initialization
boundary, [§14.5][s14-5], [D-067][d-067]). Every discrete output stage
publishes from the initial state, due or not. Only the components whose
[phase](#g-phase) (offset from the origin, in base ticks) is zero run their
update ([D-205][d-205], [D-291][d-291]). Every prior
starts not holding, so an event whose predicate already holds in the initial
state fires at `t₀` ([D-292][d-292]). Restoring a
[checkpoint](#g-checkpoint) (a saved state of the model at a frame top) runs
no boundary zero and keeps the saved priors, so nothing fires again
([§12.6][s12-6], [D-274][d-274]).

#### Supervisory inputs: scheduled gains and commanded resets

A supervisor sits one level above a set of compensators. It schedules their
gains and resets them on mode transitions. Gain scheduling and resets are both
ordinary signal flow here, because the rules for stores and views admit neither
parameter mutation nor hand-ordered resets.

**Scheduled gains are inputs** ([D-089][d-089]). A scheduler component owns the lookup tables
as inert parameters, reads the scheduling variables as inputs, and publishes one
gain bundle per compensator. Compensators consume gains as `u`. Ports expose
what mutation would hide. Gain trajectories are observable in log, [trace](#g-trace) and
[replay](#g-replay), where a parameter write would be invisible to all three. The trace is
the session's recorded inputs, and replay re-drives the ordinary loop from that
trace. The feedthrough graph carries the compensators' dependence on the gains.
Linearization holds an unseeded gain root input constant and differentiates
through a scheduled gain, with no special casing ([§14.10][s14-10]). One-shot design-time gains, such as a controller synthesized at init,
are construction-time parameters or stopped-sim service outputs ([D-089][d-089], [D-342][d-342]).
They are not a runtime write path.

**A commanded reset of a discrete component is a same-tick input, consumed in the
output stage** ([D-089][d-089], [D-342][d-342]). The supervisor publishes `engage` and the latch
value from its own feedthrough stage. The compensator, here a
proportional-integral `PI` block, sits topologically after the supervisor and
honors them *this tick*:

```julia
y_direct(c::PI, (; s, u)) = (; u_cmd = u.engage ? u.u_latch : c.k_p*u.e + s.s_i)
s_update(c::PI, (; s, u, Δt)) = (; s_i = u.engage ? u.u_latch - c.k_p*u.e
                                                      : s.s_i + c.k_i*Δt*u.e)
```

Honoring the reset only in `s_update` is legal, and it means something else
([D-089][d-089], [D-342][d-342]). The state still lands correctly at the next tick. But the
*output at the engagement tick* was already published from the stale state
during the sweep. Under zero-order hold, which keeps a discrete component's
outputs constant between its ticks ([§10.5][s10-5]), the plant integrates a full step
under that stale command. That one-tick-late command is exactly the bump that
bumpless transfer exists to remove. No diagnostic can catch the bump, because
both spellings are meaningful designs. The update stage cannot rescue its own
boundary, because republishing from `s⁺` is rejected ([D-067][d-067], [D-342][d-342]). The output
stage is therefore the *only* same-tick path.

**A [continuous component](#g-continuous-component)'s reset is an event** ([D-141][d-141]). The continuous tier admits
no input spelling at all, because only handlers write `x` ([§3.4][s3-4]). A commanded
reset of continuous state, whose condition arrives as an ordinary `Bool` input,
is therefore an edge-triggered event owned by the reset component. A landing
gear's friction regulator, re-initialized at touchdown by weight-on-wheels, is
the canonical case ([D-141][d-141]). The gear wires the strut's `wow` port to the
regulator `frc`'s `reset` input, `strut.wow → frc.reset`, so the reset fires on
the touchdown edge.

### 5.4 Artificial loops and the escape hatch

A [component](#g-component) that bundles a no-[feedthrough](#g-feedthrough) output with a feedthrough output (one
with an instantaneous input→output dependence) in one atomic evaluation unit can
be [port](#g-port)-level acyclic yet admit no evaluation order ([D-343][d-343]). Simulink calls this
an "artificial algebraic loop". A genuine cycle in the instantaneous dependency
graph is a different case, the [algebraic loop](#g-algebraic-loop) of [§5.5][s5-5]. The canonical artificial
loop in this domain is rigid-body dynamics. Velocity out is pure state, and
acceleration out is feedthrough from total force. **The remedy ladder for
artificial loops has three rungs** ([D-140][d-140]). The [two-stage split](#g-stage-function) (the two output
stages every leaf provides) resolves the rigid-body case, and it is the
rung that absorbs most artificial loops.

What survives the split is the case where a single component's stage-2 outputs
cross-couple through a neighbor. That case is port-level acyclic and stage-level
cyclic. Whether a cycle is real or artificial is decided hop by hop
([D-245][d-245]). Every wire holds. A hop runs through one member, a component
on the cycle, from the [face](#g-face) (the name a port wears on its
component's boundary) that one wire enters to the port the next wire leaves.
The hop holds iff that member's stage-2 function routes the face to the
port. A loop is real iff a cycle
survives over the holding hops, and artificial iff every cycle crosses a dead
hop. The ladder's other two rungs are two remedies for an artificial loop, and
they apply in this order.

- Re-factor the [contract](#g-contract) (a component's declared interface).
  Before moving any code, re-examine the cycle's wires. An input the neighbor
  consumes *only in a fallback branch* is the archetypal false dependency. The
  neighbor is computing, on the component's behalf, a fallback whose semantics
  belong on the component's own side of the boundary. Move the branch to its
  natural owner and the wire disappears ([D-343][d-343]). A re-factoring
  records structure, rather than dodging the diagnostic, when it survives
  substitution ([D-140][d-140], [D-343][d-343]). The canonical instance is the
  strut and steering pair of Flight.jl's landing gear, worked in
  [D-140][d-140].
- Split the component. This is the residual remedy, taken when both halves
  genuinely belong to the component and the split documents real structure.
  Its cost is binary visibility. Every intermediate shared across the new
  boundary becomes a declared, public port ([§8.3][s8-3], [D-343][d-343]).

The component split is rare, and the ladder is what earns that word rather than
asserting it ([D-140][d-140], [D-343][d-343]). The two-stage split dissolves the common shapes,
and the contract re-factoring absorbs the false wires. What is left for the
component split is cycles whose halves really are one component's own work.

One consequence of stage-2 conservatism (the presumption that every stage-2
output depends on every wired input, [§5.3][s5-3]) is worth recording. An input
consumed only by `x_deriv`, never by `y_direct`, still creates a feedthrough
edge if the component has stage-2 outputs ([D-006][d-006]). In practice such components
are integrator-shaped and have no stage-2 outputs. The remedy, if ever needed,
is the same ladder.

### 5.5 Algebraic loop policy: reject at build time

A genuine cycle in the instantaneous dependency graph is an
[algebraic loop](#g-algebraic-loop). **An algebraic loop is a build error**
([D-005][d-005]).

The user breaks the cycle explicitly, by one of three routes. They can insert
dynamics, insert an explicit unit delay, or restructure. The α-filter idiom (a
filter state inserted in the loop) is one way to insert dynamics, and it is
already standard practice in the domain.

**A unit delay is a modeling decision, not a transparent wire**
([D-348][d-348]). The library's `UnitDelay` ([§13.7][s13-7]) changes the model's
[tier](#g-tier) structure (its split into continuous and discrete sides). The broken signal
becomes discrete, sampled on a period on the scale of [`Δt_base`](#g-dt_base) (the base tick
period, an integer multiple of the continuous step). Implicit delays and per-step
numerical loop solving are both closed ([D-005][d-005], [D-343][d-343]).

**Implicit *algebraic balances* inside a [component](#g-component) remain the
component author's business** ([D-348][d-348]). A turbomachinery operating point is one.
They are local, owned and bounded. Rejecting framework-level loops does not
forbid such models.

When the build rejects a cycle, the
[feedthrough tracer](#g-feedthrough-tracer) (the instrument that classifies a
rejected cycle as real or artificial, [§13.8][s13-8]) applies the verdict of
[§5.4][s5-4] to it. **Tracing is diagnostic only**, never relied on for
correctness ([D-012][d-012]). Ordering correctness comes exclusively from the
structural two-stage split.

---

## 6. Composition: connections, aggregation and hierarchy

[Components](#g-component) (the units of modeling, leaf or assembly) become a
system through wiring. Connections route signals across the hierarchy of
[assemblies](#g-assembly) (components of pure composition, with no dynamics of
their own). Ordinary junction components sit wherever several signals must
combine into one. [§6.1][s6-1] gives the connection and hierarchy rules.
[§6.2][s6-2] gives the aggregation idiom they force.

### 6.1 Connections and hierarchy

A wire names its two endpoints by path, and those paths run down the hierarchy
of children. How far a path may reach decides whether a parent addresses a
grandchild's [port](#g-port) (one declared input or output) directly or every
intermediate level must re-export it. That question comes first here. Next
comes what type-checks a wire once both endpoints resolve. The last part, on
connections per port, covers how many connections each side may take and what
becomes of the ports left unconnected.

#### How far a path may reach

An [assembly](#g-assembly) (a [component](#g-component) of pure composition) has three wiring declarations
([§8.6][s8-6]). A `local_wires` pair wires one child's [face](#g-face) (the name a port wears on
its component's boundary) to another's. An `input_wires` entry routes a face to
an immediate child's face. An `output_wires` entry sources a face from an
immediate child's face. An entry of any of the three is a wire, and an entry of
the first is a [local wire](#g-local-wire) ([D-303][d-303], [D-314][d-314]).

**Every connection endpoint names an immediate child and one of its faces**
([D-207][d-207]). The one-level rule covers all three wiring declarations.
The elements of a [container](#g-container-children) (a `Tuple` or
`NamedTuple` field holding only components) count as immediate children
([§8.5][s8-5]).

Routing across several levels is therefore declared level by level, with each
assembly speaking only of its own children. This restriction is named the
locality law ([D-065][d-065]). [Fragments](#g-fragment) of the condition algebra follow the same law
as authoring guidance, with no check behind it ([§14.2][s14-2], [D-414][d-414]).

The sketch below shows such routing in an aircraft. The root `Cessna172` holds a
systems assembly `Systems`, which holds the landing gear `Ldg`, whose three legs
are `left`, `right` and `nose`. The root's input `trn` is a terrain [field handle](#g-field-handle)
(an immutable query object its consumers evaluate, [§4.4][s4-4]). `Cessna172` hands its
`trn` input to `systems`, `Systems` hands it to `ldg`, and `Ldg` fans it out to
its three legs. The fan-out is declared at the level where the paths diverge.

```julia
input_wires(::Cessna172) = ("trn" => "systems/trn", …)
input_wires(::Systems)   = ("trn" => "ldg/trn", …)
input_wires(::Ldg)       = ("trn" => ("left/trn_field", "right/trn_field",
                                      "nose/trn_field"), …)
```

Two consequences explain the rule. The first is that faces become the only
currency crossing an assembly boundary, so substitutability holds at *every*
boundary rather than only at generic ones. This is the contract-is-the-interface
principle of [§8.3][s8-3] with its one leak closed. The second consequence is
that the face graph is total ([D-207][d-207]). Every signal crossing a boundary
bears a declared face there, at every level it crosses. Totality is what the
condition algebra addresses against. An `at` prefix stopping at a child's face
has a name to resolve through ([§14.2][s14-2]).

The ceremony the rule costs is the re-export entry per level. It is the ceremony
the design already pays almost everywhere, because every level of a realistic
tree is a generic [seam](#g-seam) (a narrow, named interface kept deliberately thin, [§8.8][s8-8]).
One-level routing was mandatory at a generic seam in any case ([§8.8][s8-8]).
Where the entries multiply, [§8.8][s8-8] computes them from one authored
list.

#### Type-checking a wire

Once both endpoints of a wire resolve, two clauses type-check it
([§8.2][s8-2]). The first is the bound law. At [nominal](#g-nominal) (the
`Float64` [activation](#g-activation), the build's typed products at that
scalar), the producer's declared type must be a subtype of the consumer's
input entry, and equal to it for a concrete entry ([D-078][d-078]).

The second is the walk clause, for a continuous consumer only. A
[walking](#g-walked) producer leaf, one whose type follows the activation
scalar, requires an unpinned entry. A pinned producer leaf, one declared
`Pinned`, satisfies either entry, because frozen values embed upward under any
activation. A discrete consumer takes the bound law alone, so a continuous
producer feeding a discrete consumer is unconditionally legal. The discrete
tier never runs at another scalar, so no partials can reach it
([D-295][d-295], [D-263][d-263]).

An opaque leaf ([§4.3][s4-3]), a handle stored whole, passes the walk clause
as its producer's [cell](#g-cell) (the signal-table entry holding its output),
and the consumer's own arithmetic promotes what it reads ([D-264][d-264]). A
discrete producer of a handle is admitted the same way. A component that
re-emits a frozen handle pins that output too, so a handle's pin is a property
of its chain ([D-264][d-264], [D-321][d-321]).

#### Connections per port

Fan-out is free. One producer may feed many consumers. Each reads the
producer's cell, and a signal is an immutable value, so no reader can disturb
another ([§4.1][s4-1]). The converse is strict. **Every input port takes exactly one
connection**, with no exceptions ([D-170][d-170]). Aggregation is done by junctions ([§6.2][s6-2]).

The rule spans levels ([D-170][d-170]). A child input fed by a local wire at
its own level *and* handed up through its parent's `input_wires` has two
producers, which is an error. Routing a face upward cannot silently
double-feed.

There is no auto-bubbling of unconnected inputs ([D-043][d-043], [D-322][d-322]). **Unconnected
input ports are a build error, with no silent defaults** ([D-324][d-324]). Every
input's feed chain must end at a producer or at a
[root input](#g-root-input), which makes the obligation a property of the
whole tree, not of one declaration ([D-048][d-048], [D-322][d-322]). A root
input is the one legitimate terminus fed by no component, the root
component's own input face ([§11.3][s11-3], [D-208][d-208]).

**Unconnected output ports are legal, silently, with no build-time warning**
([D-084][d-084]).

### 6.2 Aggregation: explicit summing junctions

Several physical quantities are totals over many contributors. Total wrench
(force and torque), total mass properties and total internal angular momentum
are the examples. `companions/flight_case_studies.md` compares the junctions
below with the tree walks Flight.jl uses for the same totals. This section
states the rule and the junction that carries it. It
then covers what the explicit form buys, the hierarchical aggregation idiom,
zero contributors and the cost.

**N-to-1 physical aggregation is expressed by ordinary junction
[components](#g-component) and explicit wires** ([D-037][d-037]).

There is no framework aggregation mechanism. There are no multi-connection
[ports](#g-port), no declared fold ops and no identity-element opt-outs ([D-323][d-323]). Every
input port takes exactly one connection, everywhere ([§6.1][s6-1]).

A junction is an ordinary stateless component with N inputs of one type,
`in1` to `inN`, and one output, `out`. It computes a fold its instance holds.
Its arity and its port types are type parameters, and the fold is instance
data ([D-311][d-311]). A [summing junction](#g-summing-junction) folds with
`+`. The library of [§13.7][s13-7] supplies the junction, its summing form and
the Bool gates.

Wired at an ownership boundary, inside the [assembly](#g-assembly) that owns the contributors,
the junction is ordinary structure. An assembly is a component of pure
composition. In the block below, `Systems` is the systems assembly. Its children
include the aerodynamics `aero`, the powerplant `pwp` and the landing gear
`ldg`, and a child `dynamics` that consumes the total.
`wr_sum::SumJunction{Wrench{Float64}, 3}` is a field of `Systems` like any other
child ([§8.5][s8-5]). It sums three `Wrench` inputs, `Wrench` being
FlightPhysics' force-and-torque type.

```julia
local_wires(::Systems) = (
    "aero/wrench" => "wr_sum/in1",
    "pwp/wrench"  => "wr_sum/in2",
    "ldg/wrench"  => "wr_sum/in3",
    "wr_sum/out"  => "dynamics/wr_ext",
)
```

#### What the explicit form buys

- Every bookkeeping mistake at the junction is loud under the declaration layer.
  A contributor the junction counts but nobody wires is an unconnected-input
  error naming `in4`. A double-wired slot violates single-connection. A stale
  arity surfaces as one or the other. The bookkeeping is ceremony, never
  silence. A contributor's output that nobody wires stays legal and silent, as
  any unconnected output does ([D-084][d-084]).
- The aggregate is a first-class signal. `"wr_sum/out"` is an ordinary port.
  It is loggable, GUI-visible, and fanned out to a second consumer (a
  component monitoring structural loads) for one wire.
- Aggregation logic is arbitrary stage-2 code, such as mass-properties
  composition with its transport terms, or weighted blends. It is not
  restricted to a declared commutative-associative binary op.
- **Fold order is author-visible** ([D-037][d-037]). It is the positional
  order of the junction's inputs. Reassigning contributors to different slots
  changes summation order, hence bits, because float addition is not
  associative. The ordering is deterministic per configuration and under
  author control, which is strictly more explicit than a framework-canonical
  order.

#### The hierarchical aggregation idiom

**Each assembly that owns contributors aggregates them with an internal
junction and exports the total** ([D-037][d-037]). The junction is a component
inside the assembly, and the assembly exports its `out` port ([§8.6][s8-6]).

The [§6.1][s6-1] connection rules force this shape. A child is opaque to wiring
at every boundary, so every assembly that owns contributors must export its
aggregate.

For example, the landing gear `Ldg` sums its three legs and exports `wrench`.
The systems assembly sums `aero + ldg + pwp`. The vehicle holds the systems
assembly beside its `dynamics` child and wires the systems totals into the
rigid-body equations of motion. The
`local_wires(::Systems)` block earlier in this section places the `dynamics`
child inside `Systems` instead, and both shapes are legal.

Junctions placed this way replace a walk over the component tree. Each
recursion step of such a walk becomes one visible junction at the level that
owns the contributors. Written once, the junctions read as a manifest of what weighs,
what pushes and what spins. Only physical contributors publish the ports a junction sums. A
strut publishes `wrench`, and avionics publishes nothing.

Contributors publish in the common body frame. Each applies its own mounting
transform at source.

#### Zero contributors

Contributors are ragged, each having only some of the summed quantities, and
the raggedness bottoms out at none. Some configuration has a consumer whose
required aggregate input has *no* physical contributors at all. A
bare-propagation vehicle with no systems is one. Nothing contributes to its
external wrench or to its internal angular momentum, yet its rigid-body
dynamics component requires both unconditionally.

There is no junction to write and no producer to wire. [§6.1][s6-1] bans
unconnected inputs and silent defaults ([D-324][d-324]). The identity element a
zero-arity junction would need is deliberately absent ([D-037][d-037], [D-323][d-323]).

**The zero-contributor spelling is a library
[`Constant` source](#g-constant-source) ([§13.7][s13-7]) wired straight to the
consumer's input** ([D-143][d-143]), as in `Constant(Wrench())` →
`dynamics/wr_ext`. A constant source has no inputs and no state, and publishes
a value its instance holds.

The spelling makes the zero total declared structure. The configuration states
"external wrench ≡ 0" as a visible wire and an observable port, rather than as
an identity method the framework supplies behind the author's back.

**The `Constant` wire is not the banned default ([§6.1][s6-1]) in component
clothing but its opposite** ([D-143][d-143]). That default is silent and
consumer-declared. This one is loud and assembly-declared, with the author
writing the child and the wire, both inspectable.

#### The cost

Adding a contributor from another subtree edits the assembly levels between its
producer and the junction ([§6.1][s6-1]) instead of none. In exchange, explicit
wiring buys per-contributor values and intermediate totals as observable ports,
with every silence in the aggregation's bookkeeping inverted into a warning or
error ([D-037][d-037]).

Consumer-declared folds with multi-connection legality are closed
([D-037][d-037], [D-323][d-323]).

---

## 7. State and data representation

This chapter fixes where data lives and how each home holds its values.
Continuous state is an immutable value over a flat buffer the framework owns,
and the continuous path is generic over its scalar type. Discrete state and
modes live in stores, and scratch lives in a workspace.

A run's full state reaches beyond these homes, and a
[checkpoint](#g-checkpoint) (the model's state at a frame top as one value)
captures it whole. It holds `x`, `s` and `m`, the signal table with its
root-input levels and held discrete outputs, each event's
[prior](#g-prior), and the clock with its origin ([§12.6][s12-6], [D-274][d-274]). A
prior is an event's predicate sample from the previous boundary ([§2.3][s2-3]).
Workspace is not part of the state. Restoring a checkpoint and continuing
gives the trajectory of never stopping, with no boundary run again and no
event fired again ([D-274][d-274]).

[§7.1][s7-1] covers continuous state, [§7.2][s7-2] numeric genericity, [§7.3][s7-3]
discrete state, modes and the workspace, and [§7.4][s7-4] the computer/integrator
split the design admits without framework support.

### 7.1 Continuous state: structured immutable, flat backing

This section fixes how a [continuous component](#g-continuous-component) (the hybrid primitive, with
continuous state, flow and events) declares its state, and how the framework
lays that state out, reads it and writes it back. It covers, in order, the
closed leaf vocabulary, the three things the framework does with a declaration,
the buffer and its views, why the vocabulary is closed, and the shape of `Ẋ`.

Each continuous component declares its state by value (`x_init`,
[§8.2][s8-2], [D-033][d-033]). The declaration is a NamedTuple
([D-247][d-247]). **Its leaves are drawn from a deliberately closed
vocabulary**, plain real scalars and `SArray`s (static vectors and matrices) of
a common eltype `T`, and nothing else ([D-094][d-094]). **`Int`s, enums and
`Bool`s belong in modes** ([D-308][d-308]). Domain wrapper types are not state leaves
either. Two
such types are `RQuat`, a rotation quaternion type with a `normalization`
keyword, and `Ranged`, a clamped scalar. An attitude state is an
`SVector{4,T}`, cast where rotation semantics are wanted, as described below.

**The declaration is flat** ([D-094][d-094], [D-304][d-304]). Each field is one leaf, never a
`NamedTuple` of leaves. The condition algebra and the readers address a field
as one leaf ([§14.3][s14-3], [§14.4][s14-4]), and structure comes from the [component](#g-component) tree, not
from the value.

The framework does three things with the declaration.

- It computes a flat layout at build time. The layout has compile-time offsets
  into one contiguous `Vector{T}` that the framework owns, the
  [buffer](#g-buffer).
- It reconstructs the typed immutable state value for a component at each
  evaluation. The value's type, `X`, is derived from `x_init`. The framework
  passes that value to every function receiving state [views](#g-view) (zero-copy
  reconstructions of a store), under the hand-off of [§5.2][s5-2] ([D-035][d-035]).
- It receives immutable results back. Derivative functions return an `Ẋ`-typed
  value, which is scatter-stored into the flat `ẋ` buffer. A handler's `x` key
  and the [projection](#g-projection) (the optional hook `x_projection`) carry a new `X`, which
  is written back. Projection's write-back happens at the two positions in the
  boundary sequence of [§5.3][s5-3] ([D-111][d-111]).

**The buffer is authoritative, and typed values are ephemeral
reconstructions** ([D-010][d-010]). Nobody outside the framework ever holds a
mutable reference to state. A view exists only for the call that receives it
([§9.7][s9-7]). The buffer is unchanged within a [sweep](#g-sweep) (one pass
through the execution order), so every view of it rebuilt during a sweep is
the same value. The flat vector still exists beside the typed values, so
integrators, trim solvers, logging and linearization all get their arrays.
They get them through the framework's canonical layout, with no hand-written
state-space mapping per model ([D-072][d-072]).

The complementary rule is [one home per datum](#g-one-home-per-datum) (each
datum has exactly one home), stated in [§5.2][s5-2] ([D-035][d-035]). In
particular there are no state [cells](#g-cell) in the
[signal table](#g-signal-table) beyond the declared [ports](#g-port) a
component returns from `y_state` ([§5.3][s5-3], [D-252][d-252]), which are
interface, not transport.

The vocabulary is closed because views must materialize without running
anyone's invariants. Scalars and `SArray`s have invariant-free constructors.
`SVector`'s stores its tuple, `NamedTuple` construction runs no user code, and
nothing normalizes or clamps. Building a view through ordinary public
construction is therefore bit-faithful automatically. `reconstruct(flatten(x))
== x` holds identically, with no constructor bypass, no `reinterpret`, and no
reliance on a custom struct's memory layout mirroring the buffer's.
Invariant-carrying leaves are excluded from the vocabulary ([D-094][d-094]).

Domain semantics are instead an explicit, invariant-free cast at the point of
use. Invariants live where the design already
put them, in `x_projection` at [boundaries](#g-boundary) (published consistency points) and in
writers. Handlers build their returned values through ordinary constructors, and
the condition apply converts authored values through ordinary `convert` methods
([§14.3][s14-3]). Constructors run on the write paths, never on views.

With the leaf vocabulary closed, the shape of `Ẋ` takes one line to state. `Ẋ`
has exactly `X`'s shape at the [activation](#g-activation) scalar (the scalar `T` at which the
build types the tree). A scalar leaf's derivative is a `T`, and an `SArray`
leaf's is the same `SArray` at `T`. This is what the closed vocabulary buys.
An invariant-carrying leaf like a unit quaternion has a derivative off its own
type, and `Ẋ` would need a separate derivation. Here the attitude leaf is an
`SVector{4,T}`, and so is its rate. Derivative completeness is therefore
structural, a property of the layout rather than of author discipline
([§9.5][s9-5], [D-190][d-190]).

### 7.2 Numeric genericity (eltype)

**The entire continuous evaluation path is generic over `T <: Real`**, and so are
the state [buffer](#g-buffer) (the framework-owned contiguous vector backing all continuous
state) and the pack/unpack machinery ([D-011][d-011]). This one design property serves
four consumers.

1. Exact Jacobians for linearization, with ForwardDiff duals through the
   whole model, replacing finite differences.
2. Derivatives for trim solvers.
3. The [feedthrough tracer](#g-feedthrough-tracer) (the set-propagation
   instrument classifying a rejected cycle, [§13.8][s13-8]).
4. A trivially checkable CI invariant ([D-280][d-280]). One evaluation
   [sweep](#g-sweep) (one pass through the execution order) with `T = Dual`
   fails loudly on any Float64-pinning.

Trim and linearization ask questions of a model rather than produce its
values. Trim searches for an initial condition whose declared residuals each
hold within their tolerance, evaluating each candidate by one sweep with modes
and the discrete tier held at their initial values ([§14.5][s14-5],
[§14.8][s14-8], [D-067][d-067], [D-150][d-150], [D-213][d-213]).
Linearization gives the Jacobians of the continuous map from `(x, u)` to
`(ẋ, y)` at an operating point, with everything it does not seed held
constant ([§14.10][s14-10], [D-272][d-272]).

The rest of the section states the three classes that scope this genericity,
what runs at another scalar, how participation is chosen per leaf and how
partials enter, and how lookup tables fit them.

Scoping, meaning what actually needs genericity, has three classes ([D-011][d-011]).

- *[Walked](#g-walked)*, the payload and value types constructed during
  evaluation. One example is `FrameTransform`, a FlightPhysics payload type.
  Its constructors infer the scalar ([§8.2][s8-2]).
- *Pinned*, the parameters and definitions. They stay `Float64`, since
  promotion handles mixing.
- *Exempt*, the discrete side (compensators, avionics). Linearization and trim
  differentiate continuous dynamics only.

For consumer 1, the *discrete* side's exemption is not a limitation but the
exact answer ([D-072][d-072]). A frozen discrete [cell](#g-cell) (a typed
entry of the signal table) is a constant with zero partials. That is what
"linearize the continuous dynamics with the discrete state held" means.
`frozen_discrete_walkthrough.md` works the chain through in detail.

At any scalar other than the [nominal](#g-nominal) one (`Float64`, the scalar
a simulation runs at), only the continuous dynamics run. Discrete cells hold
their nominal values, and no guard or handler runs, so no event occurs there
([§9.4][s9-4], [D-052][d-052], [D-317][d-317]).

Participation is per leaf ([D-263][d-263], [D-295][d-295]). On the
continuous [tier](#g-tier) (the continuous or discrete side) a leaf follows
the scalar of the [activation](#g-activation) (the build's typed products at
a given scalar type), in a contract and in the state type alike. A contract
leaf declared pinned does not. The discrete side pins wholesale.
[§8.2][s8-2] states how the declarations spell this.

At a non-nominal scalar, partials enter only through the directions seeded
for that evaluation, never through a declaration. Declared initial values
enter as constants with zero partials ([§8.2][s8-2], [D-297][d-297]). A leaf
declared pinned carries no partials at any scalar. The pin is a declared
stop-gradient, so every Jacobian entry through a pinned leaf is exactly zero
([D-286][d-286]). A plain `Float64` where the activation scalar is expected
embeds as a constant with zero partials, and that embedding is exact.
Promotion never drops partials, so a plain value means no seeded direction
reached it, and its true derivative is zero ([§9.5][s9-5], [D-053][d-053],
[D-238][d-238]). The exception is an author who strips partials deliberately
([§9.5][s9-5], [D-286][d-286]).

For lookups, **table data is a pinned parameter and the query coordinate is
walked traffic** ([D-011][d-011], [D-307][d-307]). [§14.8][s14-8] records
what that asks of an interpolation package.

### 7.3 Discrete state, modes, and workspace

Two homes sit outside the continuous [buffer](#g-buffer) (the framework-owned contiguous
vector backing all continuous state), and the rules they obey are opposites.
Discrete state and modes are state in the full sense. They are values whose
fields are isbits or `Symbol`s. The framework owns them, and a checkpoint copies
them wholesale. A [workspace](#g-workspace) is mutable scratch, deliberately not state at all,
governed by contract rather than by checks. The section states the rules of the
`s` and `m` [stores](#g-store) (the framework-owned homes of those letters) first, then the
workspace's rules, then the two laws that join the two homes.

#### Stores: discrete state and modes

**Discrete state, a discrete leaf's `s`, and the modes `m` live in typed stores**,
apart from the buffer that holds `x` ([§7.1][s7-1], [D-013][d-013], [D-302][d-302]). The framework
overwrites an `s` or `m` store when an update or a handler returns a new value.

An `s` or `m` store keeps the same immutable-value discipline as the
[signal table](#g-signal-table)'s [cells](#g-cell), in a separate home. The vocabulary of [§4.1][s4-1] never counts a
store as a cell ([D-302][d-302]). The `s` and `m` stores never touch the buffer, and no
arithmetic is ever done on them ([D-304][d-304]).

**Every field of an `s` or `m` store value is isbits or a `Symbol`** ([D-231][d-231]). An
isbits value is immutable and holds no references, transitively. Enums,
integers, `Bool`s, `SArray`s and nested isbits structs all qualify. A `String`,
an array, or a struct holding either does not qualify.

A `Symbol` is admitted as the idiomatic label. It is interned, immutable and
never freed, so it copies as a pointer to permanent data and serializes as its
name. The table admits it on the same grounds, as an opaque leaf
([§4.3][s4-3]). A struct nesting a `Symbol` does not qualify ([D-304][d-304]).

The rule rests on what state is. State is what changes between [ticks](#g-tick) (the
instants a discrete component runs). Bulk data and text do not, and their home
is the [component](#g-component) instance. **The frozen-reference latitude stays with signals**
([§4.1][s4-1], [D-231][d-231], [D-344][d-344]). It exists for field handles ([§4.4][s4-4]), and no store needs it.
Isbits is what makes the rest of this section literal. Copying an `s` or `m` store
copies bits. So checkpoint and [replay](#g-replay) (the ordinary loop re-driven from the
trace) of the entire discrete side is "copy the store values", and a stored
value has one fixed layout per component.

Double-buffered mutable state is a possible future extension only, deferred
([D-013][d-013], [D-306][d-306]).

#### Workspace

A workspace serves heavy algorithms, such as an n≈20 Kalman filter. A workspace
is component-declared mutable scratch, instantiated by the framework ([D-013][d-013]). It
arrives as the `ws` field of the [bundle](#g-bundle) (the NamedTuple of zero-copy views a
component function receives) in every bundle-receiving function of the declaring
component ([§5.2][s5-2]). `x_projection` receives none ([D-074][d-074]).

A workspace is excluded from state semantics. **It is not snapshotted and not
replayed** ([D-308][d-308]). It is never a condition target ([§14.1][s14-1], [D-306][d-306]). It
must carry no information between calls ([D-183][d-183]).

**The framework never inspects or mutates a workspace** ([D-183][d-183]). The
workspace is an opaque, opt-in escape hatch from value semantics, used at the
author's own risk. Its rules are contract, not checks. At call entry, contents
are unspecified beyond the structure the allocator itself established. A plan
or factorization configured at allocation is valid from then on ([D-306][d-306]).
Scratch is garbage until written this call, and nothing a previous call left
behind may be relied upon.

A workspace is allocated per [activation](#g-activation) (the build's typed
products at a given scalar type), at that activation's scalar on the
continuous [tier](#g-tier) and at `Float64` on the discrete tier, which never
runs at another scalar ([D-077][d-077], [D-263][d-263]). Its sizes come from
the instance. [§8.2][s8-2] gives the declaration.

The continuous side runs many calls per [boundary](#g-boundary) (a published consistency
point). They serve RK stages, the evaluations root-finding makes inside a step,
and event re-[sweeps](#g-sweep). That
multiplicity makes the no-information-between-calls contract *more* essential
there, not less.

#### Idioms

Heavy algorithms do their in-place math in the workspace and return an isbits
snapshot as the new state ([D-013][d-013]). Snapshot values are for storage,
never arithmetic. In a discrete leaf drawing random numbers, **a generator
object such as `Xoshiro` lives in the workspace, and the values that determine
its next draw are state in `s`** ([D-231][d-231]). Keeping them in `s` is what
makes replay deterministic ([§2.5][s2-5]). [§8.2][s8-2] spells both idioms.

### 7.4 The computer/integrator split

Overlap between derivatives and outputs is the norm in physical and control
models, and the fused idiom of [§5.3][s5-3] computes each shared law once.
The orthodox factoring stays available beside it. The
`companions/fused_evaluation_lineage.md` companion records how the
interfaces of [§5.2][s5-2] came to be and how other frameworks resolve the
same overlap.

The computer/integrator split remains fully expressible without any framework
support ([D-015][d-015]). A stateless component computes derivatives as
outputs and is wired into a trivial state-holding component. It is the idiom
of choice when the factoring earns reuse. Two examples are one Newton–Euler
solver shared across vehicle variants, and swappable kinematic descriptors
against a common integrator shape. Against a split-form spelling of a
rigid-body kinematics and dynamics core, the merged form has half the
components and half the wiring ([D-015][d-015]). Everything derivable from
pose alone migrates to stage 1, shortening the stage-2 chain.

---

# Part II — Authoring and build

Part II covers everything that happens before a simulation runs: an author
declares a component tree, and the build turns that declaration into an
executable artifact. [§8][s8] is the declaration layer. It fixes the closed inventory
of well-known functions a component defines, the visibility each declaration
carries, and the shapes an assembly adds on top: children, paths, faces, rate
scopes and computed connections. [§9][s9] is the build pipeline that consumes them.
It fixes the build's three steps, the `Build` artifact they produce, the probe
that runs every user function once against real values, activations at other
scalar types, the conformance check the probe leaves permanently in place,
the compiled executor the loop will dispatch through, and the allocation
policy measured against it.

Part II assumes Part I throughout. The taxonomy of [§3][s3] decides what may be
declared, the contracts of [§4][s4] are what a declaration fixes, and the two-stage
split of [§5.2][s5-2] is what makes feedthrough structural rather than annotated. [§7][s7]
fixes the homes the declared state occupies. Nothing here runs: the executor
built in [§9.7][s9-7] is not dispatched until [§10][s10].

## 8. The declaration layer: components and assemblies

This chapter says how an author spells a [component](#g-component). It covers where the
structural facts live, what the build takes as authoritative, and what is
checked against what. The first four sections cover the component side.
[§8.1][s8-1] lays the foundations of the declaration layer, [§8.2][s8-2] lists the
declaration inventory, [§8.3][s8-3] says what a contract makes visible, and [§8.4][s8-4]
gives the five failure walkthroughs that ground error locality. The last four
cover the [assembly](#g-assembly) side. [§8.5][s8-5] covers assembly declaration, how a type's
class is read, container children and `Group`. [§8.6][s8-6] covers paths, wiring
and faces, works them through the strapdown IMU, and ends with the
boundary-sampling contract. [§8.7][s8-7] covers rate scopes, and [§8.8][s8-8] covers
computed connections and generic holding. The build pipeline is [§9][s9], and
the stopped-sim service spellings are [§14][s14]. The concrete syntax below is
near-final in shape but still illustrative in spelling.

### 8.1 Position: a declarative trait layer in plain Julia, no macros

A [component](#g-component) is authored in ordinary Julia. Its
[stage functions](#g-stage-function) are ordinary multiple-dispatch methods.
They are `y_state` and `y_direct`, the two output stages every leaf
provides on either [tier](#g-tier) (the continuous or discrete side of the
hybrid formalism). The methods follow the `GUI.draw!` precedent, the
per-component panel extensions in FlightCore's style ([§11.7][s11-7]). A
component's structural facts are declared through a small set of well-known
functions returning plain values, defined alongside those methods.

Five questions about that layer are settled here, one per subsection. What
does it rule out, and what does it still admit (macros)? Which of declaration
and evaluation is authoritative (the schema)? What may a component's
[contract](#g-contract) (its declared interface) depend on (the type)? How do
an author's methods reach the framework's generic functions, and how can they
silently fail to (the namespace)? And what grammatical shape does each name
on the framework's surface take (names)?

#### Plain Julia, not a macro DSL

**There is no macro DSL** ([D-032][d-032]). The debugging, tooling and
comprehension criterion ([§1][s1]) decides it.

Redundancy between declarations and function bodies is accepted deliberately,
under one non-negotiable condition. Every inconsistency fails loudly, at
build time where possible and at first execution otherwise ([D-032][d-032]).

**A convenience macro remains addable a posteriori** as pure sugar, on the
`@kwdef` precedent, and never becomes essential ([D-032][d-032]). The reason
is that a macro can only ever *lower to* a layer like this one.

The door stays open for the declaration layer specifically. A macro generating
the well-known declarations is admissible sugar *on top of* the plain-Julia
forms. It is never a replacement for them and never required to author a
component ([D-032][d-032]). Every rule in this part is stated over the
generated methods, so a macro that lowers to them adds convenience and no
semantics.

#### Declarations are the schema authority

**Declarations *define* the model's structure** ([D-032][d-032]). Evaluation
*checks* conformance against them, never the reverse.

The build [probes](#g-probe) user functions with real values (a single evaluation of
each, its result discarded), with no reliance on compiler inference, and
compares observed against declared. The same comparison then runs on every
subsequent evaluation for free, as a `NamedTuple`-type check that constant-folds
away when conformant.

Inference-by-evaluation as [schema authority](#g-schema-authority) (the source that defines
structure) is rejected on three counts, established by walkthrough
([§8.4][s8-4]) and litigated in [D-032][d-032]. Types come by declaration, values by
execution, and conformance by comparison.

#### Contracts are functions of the type

**A leaf's contract declarations must be determined by the component's
type**, its type parameters included, and never by its field *values*
([D-033][d-033], [D-297][d-297]). Those declarations are `u_types`, `y_types` and
`state_events`, and the shapes of `x_init`/`s_init`/`m_init`.

The value-discarding signature `u_types(::Engine)` is the visible form of the
rule (`Engine` is the example component of [§8.2][s8-2]). The idiom for a
contract that genuinely varies is the type parameter, not the field, as in
`SumJunction{Wrench{Float64}, 3}` and `Or{N}` ([§13.7][s13-7]). Arity is spelled in
the type, at the price [§6.2][s6-2] states openly.

The reason is how entries of the [executor](#g-executor) (the compiled form of the stage
execution order) are typed ([§9.7][s9-7]). A component's [bundle](#g-bundle) is the `NamedTuple` of
zero-copy views a component function receives, and its key set *is* its
contract's. An executor entry carries what selects code in type parameters and
what is plain data in fields. A key set derivable only from field values would
therefore have to go one of two ways. It could climb into the type parameters
anyway, multiplying specialization and changing the cost model ([§9.7][s9-7]) of
[chunking](#g-chunking), the splitting of a large phase body into statically typed chunks. Or
it could sit in fields, dissolving the static typing that the zero runtime graph
logic ([§5.1][s5-1]), the allocation invariant ([§9.8][s9-8]) and the fold-away conformance test
([§9.5][s9-5]) all rest on.

The build reads each declaration once, against the concrete instance, so a
value-dependent contract does not announce itself. This is a rule authors keep,
not a check the build can run.

`ws_init` is the one exception, and explicitly so ([D-033][d-033]). It is the
by-allocation convention ([D-077][d-077]), an allocator the framework *calls*
rather than a schema it *walks*. It legitimately takes sizes from the instance
(`ws_init(c::KF, ::Type{T})` reads `c.n`, [§8.2][s8-2]), because no entry type
is derived from it.

#### The namespace

**The framework's extensible functions are extended, not called**
([D-117][d-117]). Authoring a component means adding methods to
framework-owned generic functions.

Julia admits that only through an explicit per-name `import`, or through a
qualified `Redstone.x_deriv(…) = …` definition. The latter is the `Base.show`
idiom that the exported-name audit in `pending.md` records for the
extension-only periphery surface. A component module therefore opens with

```julia
import Redstone: x_init, s_init, m_init, ws_init, u_types,
    y_types, state_events, y_state, y_direct, x_deriv,
    s_update, x_projection, local_wires, input_wires,
    output_wires, sample_times, transparent_container, stop_reason
```

The explicit list is needed because `using Redstone` alone is a silent trap.
After a bare `using`, `x_deriv(eng::Engine, …) = …` defines a new, unrelated
`MyModule.x_deriv`, with no error and no warning. The declarations are
deliberately unexported ([D-117][d-117]). A bare `using` therefore brings no
name into scope for the definition to clash with, so there is nothing for the
language to detect.

Left alone, the build would see a component with no `x_deriv` method. It would
report a *modeling* diagnostic, `StoreWithoutUpdate` (a non-empty [state
declaration](#g-state-declaration) without its update law, [§8.2][s8-2]). When the whole
inventory was shadowed, it would report `ClassUnreadable` (no declaration to read
a [class](#g-class) from, [§8.5][s8-5]). A one-line namespace mistake would be reported far from the
line that caused it. That is the inversion of [error locality](#g-error-locality) (the property that
a mistake fails at the site of the mistake) that [§8.4][s8-4] traces, arriving through
the namespace.

Two mitigations apply, both normative. The first is that the import list above
is authoring surface, stated wherever a component file is first shown
([D-117][d-117]). The second is a shadowing check. **The structural walk
runs the shadowing check on every component before its class is read**
([§9.1][s9-1], [D-246][d-246]).

The check looks for a binding of a declaration name (a name in the import list
above) in the component's parent module. If the module holds one distinct from
the framework's function, **the build throws `DeclarationShadowed` alone**
([D-246][d-246]). The diagnostic names the module, the foreign names and the
missing import. Its message reads "`MyEngine`'s module defines its own
`x_deriv`, distinct from `Redstone.x_deriv`; add `import Redstone: x_deriv`".

The check is a two-line `isdefined`/`!==` test on those names. Those names are
distinctive by design ([D-220][d-220]), so a foreign binding of one of them in a
component's module is evidence of the missing import, not a coincidence. The
check throws alone because nothing the module declares can be trusted. Every
declaration it holds may have gone to a foreign function, and a walk past it
would only report cascades of the one cause. It runs on every component rather
than only where an absence is noticed, because an optional declaration such as
`state_events`, `sample_times` or `stop_reason` has no absence to notice.
Shadowed, it would drop its feature silently.

A convenience macro expanding to the import list remains addable a posteriori
as sugar, per this section's macro doctrine. A re-export submodule is not an
alternative ([D-117][d-117]).

The same trap has a local-scope sibling ([D-164][d-164]). Written inside a
`let`, a function body or a `@testset`, `y_state(::MyComp, (; x)) = …` does
not add a method to the global `y_state`. It binds a *new local function* of
that name. Calls within the block resolve to it and look correct. The generic
function the build dispatches on never learns of the component, which
therefore reads as one declaring nothing at all.

```julia
@testset "mycomp" begin
    y_state(::MyComp, (; x)) = …   #a NEW local one, not a method of
    …                                   #Redstone.y_state; calls here
end                                     #resolve to it, and look correct
#outside: Redstone.y_state still has no MyComp method
```

The shadowing check above cannot reach this case. There is no parent-module
binding to compare, because the shadow is a local binding that disappears with
its block. The mitigation therefore sits at the other end. **A component that
declares nothing and defines no stage is rejected at build time**
([D-164][d-164]), because an inert component is unwritable on purpose. The
refusal is `ClassUnreadable` ([§8.5][s8-5]). That check costs a line, and it catches
the misspelled-declaration family with it.

Test code is the realistic victim, with a fixture component defined inside its
own `@testset`. The authoring rule is one line. **Declarations live at module
top level** ([D-164][d-164]).

The net also holds when only a stage is shadowed, because `y_types` is still a
declaration. A component whose [ports](#g-port) (its declared, addressable
names) are declared but whose stage went to a local binding reads as "declared
but not produced" ([§8.3][s8-3]). It does not read as a component with nothing
to say. An optional declaration shadowed in a local scope, such as
`state_events` or `ws_init`, drops its feature silently ([D-178][d-178]).

#### Names

**Every name on the framework's surface belongs to one of four classes**, and
its class fixes its grammatical shape ([D-144][d-144]).

1. Declarations are noun phrases naming what they return, prefixed by the bundle
   field they define where one exists ([D-267][d-267]). An [assembly](#g-assembly) defines
   no bundle field, and its three connection declarations name the wires they
   return ([D-303][d-303]). The author
   defines them and the framework calls them. They include `local_wires`,
   `input_wires`/`output_wires`, `state_events`, `u_types`, `ws_init`, the
   stage and update-law names ([D-220][d-220]), and `claims(b)` from the [binding](#g-binding)
   interface ([§11.6][s11-6]). A binding is the value passed at `attach!` that
   makes a device framework-legible.
2. Value selectors carry `get_`. They are called against `reads` and against
   [snapshots](#g-snapshot), the immutable per-boundary publications
   ([§14.4][s14-4]).
3. Lifecycle and mutating actions are verbs, with `!` when they mutate.
4. Build primitives are plain verbs ([§13.3][s13-3]).

A name in the wrong class is a rename candidate on that ground alone.

The stage names are deliberately non-exhaustive ([D-075][d-075],
[D-342][d-342]). A stage's name states its feedthrough split, not an
inventory of its arguments. Modes fold under the state, so `y_state` reads
`m` as well as `x`. Ambient facts (`t`, `Δt`) and scratch (`ws`) ride
unnamed.

The convention also has a semantic axis. A name can sit in the right class and
still pick the wrong noun. **A declaration names its *content*, what it
returns, never the *consequence* its definition has** ([D-301][d-301]). The binding
methods `claims`/`reads` ([§11.6][s11-6], [D-146][d-146]) name the claim set and the
read set they return. `exports` named a consequence and is retired, and
`input_wires` and `output_wires` name the pairs each returns
([D-170][d-170]). `input_passthrough` ([§8.8][s8-8], [D-171][d-171]) sits outside the
axis: it is a helper the author calls, named for the operation it performs
([D-144][d-144]).

Which names the module exports is a separate question. It stays open until
the exported-name audit in `pending.md` runs ([D-226][d-226]).

### 8.2 The declaration inventory

This section takes the declarations of a [component](#g-component) (the unit of
modeling, leaf or assembly) one by one, and records where each schema fact gets
its authority. One continuous primitive, declared end to end, shows them
together:

```julia
struct Engine <: AbstractComponent
    ω_idle::Float64; ω_min::Float64; J::Float64      #parameters: plain struct fields
    ω_rated::Float64                                 #unread here; §14.2's shipped condition uses it
end

#state and modes: declared by initial value — types derived, nothing to drift
x_init(::Engine) = (ω = 0.0,)
m_init(::Engine) = (phase = off,)                    # off | starting | running

#input contract: each entry states what may arrive; a Float64 leaf walks with the activation
u_types(::Engine) =
    (throttle = Float64, starter = Bool, fuel_available = Bool, M_load = Float64)

#output contract = the public interface (§8.3); Float64 walks, Pinned{Float64} would freeze a leaf
y_types(::Engine) = (M_shaft = Float64, P = Float64, ω = Float64)

#stage and update functions destructure their bundle by name (below)
y_state(::Engine, (; x)) = (; ω = x.ω)          #exposing a state field is one line (§5.3)

function y_direct(eng::Engine, (; x, m, u))
    M_shaft = m.phase === running ? torque_law(eng, u.throttle, x.ω) : zero(x.ω)
    return (; M_shaft, P = M_shaft * x.ω)
end

x_deriv(eng::Engine, (; x, y, u)) = (ω = (y.M_shaft - u.M_load) / eng.J,)

#events: ordered and named — order matters (§5.3, §10.6); detection policy by the guard's return type (§10.4)
state_events(::Engine) = (
    start    = StateEvent(start_guard, start_handler),        # boundary-detected: Bool guard
    ignition = StateEvent(ignition_guard, ignition_handler),  # boundary-detected: Bool guard
    flameout = StateEvent(flameout_guard, flameout_handler))  # localized: sign-form guard
start_guard(::Engine, (; m, u)) =                        #manual trigger: an input (§12.5)
    m.phase === off && u.starter
start_handler(::Engine, _) = (; m = (; phase = starting))          #no `x` key: no reset
ignition_guard(eng::Engine, (; x, m, u)) =                #predicate form
    m.phase === starting && x.ω > eng.ω_idle && u.fuel_available
ignition_handler(::Engine, _) = (; m = (; phase = running))
flameout_guard(eng::Engine, (; x)) = eng.ω_min - x.ω      #continuous form: localizable
flameout_handler(::Engine, _) = (; m = (; phase = off))
```

**Every declaration of a structural fact but the allocator takes the component
alone** ([D-263][d-263]). The criterion is the convention each declaration
lives in. It is stated once here, and the blocks below refer back to it.

- A *by-value* declaration states nominal physics, and its *types*
  [walk by rule](#g-leaf-walk) (the derivation of per-activation types from a
  declared nominal type). [§7.1][s7-1] and [§7.2][s7-2] force every state leaf to follow the
  scalar of the [activation](#g-activation) (the build's typed products at a
  given scalar type). Nothing is therefore left for a signature to record.
  Partials enter through per-invocation seeding, never through initialization
  ([D-079][d-079], [D-297][d-297]).
- A *by-type* declaration walks by the same rule. Where a leaf must not follow
  the scalar, the author says so at the leaf with `Pinned` (the leaf marker
  `Pinned{P}`, which yields `P` at every activation). That is why `u_types`
  and `y_types` take the component alone too.
- A *by-allocation* declaration is the exception. It builds values the framework
  may not rebuild, so the scalar can come from nowhere but its own argument.
  `ws_init(c, T)` takes it on both [tiers](#g-tier), the continuous and the
  discrete ([D-077][d-077]). `ws_init` allocates the [workspace](#g-workspace)
  (component-declared mutable scratch), which is described below. The workspace
  arrives as the `ws` [bundle](#g-bundle) field (the `NamedTuple` of views a
  component function receives).

The criterion, not uniformity, is the rule. A `T` in a signature means the
framework could not have supplied it.

#### State and mode declarations

**`x_init` on the continuous tier, `s_init` on the discrete, and `m_init`
declare by initial value** ([D-033][d-033]). The type is derived from the value.
**The value is a `NamedTuple`, one named field per leaf**, and no other form is
admitted ([D-247][d-247]). A bare leaf such as `x_init(::C) = 0.0` or
`s_init(::C) = zeros(SVector{3})` is refused. The structure step (the build's
first step, declaration reading only) reports it as `StoreNotNamedTuple`, and
the message spells the wrap ([§9.1][s9-1], [Appendix C][sC], [D-247][d-247]).

The `NamedTuple` names each leaf because every service reaches a leaf by its
field name. A [condition](#g-condition), the
path-addressed sparse overlay that sets a build's state, merges on it ([§14.1][s14-1]).
Readers and the trace spell it ([§14.4][s14-4]). The name a one-state component is asked
for is the name every service then uses.

**Every leaf declares exactly one of `x_init` and `s_init`**, and a stateless
leaf declares it empty ([D-263][d-263]):

```julia
x_init(::Gain) = (;)
s_init(::Sampler) = (;)
```

This [state declaration](#g-state-declaration) (a leaf's `x_init` or `s_init`) is the tier marker. It is
therefore mandatory even when empty, exactly as `local_wires` is mandatory
even when empty because it is the class marker ([§8.5][s8-5], [D-263][d-263]). A primitive
declaring neither is `TierUnreadable`, and its message spells the empty form. An
empty state declaration owes no update law, since it has nothing to integrate or
advance. It puts no letter in the bundle ([§5.2][s5-2]).

A continuous component's state may be empty ([§3.1][s3-1]), so a stateless
continuous leaf is honestly a continuous leaf with zero state fields. Spelling
that out puts every leaf's tier on the page in one place, stateful or not, with
no tier by omission. It also closes a trap. A state declaration lost to a local
scope or to a forgotten import ([§8.1][s8-1]) fails loud as a leaf declaring none,
where an optional marker would have dropped silently.

Because the type is derived from the value, there is no second artifact to drift
and no separate type declaration to check. The workspace is the exception to
that convention. **A workspace is declared by allocation**, never by initial
value ([D-077][d-077]). The well-known method *is* the allocator, as for a
Kalman filter `KF` whose dimension `c.n` is instance data.

```julia
ws_init(c::KF, ::Type{T}) where {T} =
    (P = Matrix{T}(undef, c.n, c.n), x̂ = Vector{T}(undef, c.n))
```

**`ws_init(::C, ::Type{T})` takes the activation scalar on both tiers**, and
it is the one declaration that does ([D-263][d-263]). A discrete allocator
receives `Float64` at every activation, because the discrete tier never runs
at another scalar ([§9.4][s9-4]). A workspace earns the exception because it
is not memory and none of the by-value arguments below cover it
([§7.3][s7-3]). State and cells re-scalar through the walk ([§7.2][s7-2]), so
their declarations never need `T`. Scratch is allocated, not retyped. A
factorization, a plan or a buffer sized by the scalar has no rebuild the
framework could perform. So the eltypes can come from nowhere but the
allocator's own argument ([D-077][d-077], [D-263][d-263]). `ws_init` alone
declares by allocation, and nothing downstream derives from the type of what
it returns.

The `undef` spelling is the recommended idiom and the sole visible marker that
contents are meaningless. It puts that fact in the by-allocation declaration
itself. The framework never poisons those contents to enforce that, since it
never mutates a workspace ([§7.3][s7-3], [D-183][d-183]). The `init` in
`ws_init` means *establish*, as the device contract's
`init!` does ([§11.6][s11-6]). It carries no claim that the allocated contents
are a value ([D-220][d-220]).

This is the boundary of legitimate derivation. Deriving from another
declaration is sound, and deriving from evaluated user code is not. Declaring
state by type, with synthesized initial values, was rejected
([D-073][d-073]).

The declared values are the base layer of the condition substrate. The
overlays ([§14.1][s14-1]) fall back to the declared values leaf by leaf, and
the compiled store writers bake `merge(defaults, overlay)`. There must
therefore be an authored value under every leaf.

The asymmetry against `u_types`/`y_types` is one of kind, not style.
[Contracts](#g-contract) (a component's declared interfaces) describe table [cells](#g-cell) (the
signal table's typed entries). There is one cell per output [port](#g-port) (one
declared input or output). Cells are recomputed from scratch every [sweep](#g-sweep)
(one pass through the execution order), so contracts need only types. `x_init`,
`s_init` and `m_init` seed the [stores](#g-store) (the homes of `x`, `s` and `m`),
which must have contents before the first sweep can run.

#### Workspace idioms

Two idioms join the workspace to the `s` store, and [§7.3][s7-3] states the
law each rests on.

The [blessed](#g-blessed) (explicitly sanctioned) workspace-plus-snapshot
idiom gives zero-allocation ticks with an immutable `s` ([D-013][d-013]). It
does the in-place math on the workspace, with `mul!`, `cholesky!` or BLAS. At
the end, it snapshots into an isbits container and returns it, as in
`s = KFState(SVector{20}(ws.x̂), SMatrix{20,20}(ws.P))`.

A PRNG in a discrete leaf keeps its generator object, such as `Xoshiro`, in
the workspace, and the values that determine its next draw in `s`
([D-231][d-231]). The generator is mutable, so it is scratch, allocated once.
The values are immutable, so they are state. The tick loads them into the
generator at entry and snapshots them back at exit, in the same shape as the
workspace-plus-snapshot idiom.

```julia
s_init(::Noise)         = (rng = UInt64.((0x9e3779b9, 0x243f6a88, 0xb7e15162, 0x6a09e667)),)
ws_init(::Noise, ::Type) = (rng = Xoshiro(0, 0, 0, 0),)

function s_update(c::Noise, b)
    r = b.ws.rng
    r.s0, r.s1, r.s2, r.s3 = b.s.rng        # load the words at entry
    z = randn(r)
    (rng = (r.s0, r.s1, r.s2, r.s3),)       # snapshot them back
end
```

Rematerializing the generator from its values each tick reads naturally and
allocates. A sampler with an out-of-line tail lets the object escape
([D-231][d-231]).

Construction and storage of large `SArray`s are cheap and compile fine. The
StaticArrays "codegen catastrophe" lives in its *operations*, the unrolled
matmuls, which are never called on snapshots.

Snapshot values are for storage, logging and element access only, never
arithmetic. The practical ceiling is a few KB comfortable and tens of KB
defensible. Beyond that, value semantics stop making sense.

#### Input contracts: `u_types`

A `u_types` declaration is a bare `NamedTuple` of types, written at nominal
`Float64` and taking the component alone on both tiers ([D-263][d-263]). It
admits two pieces of framework vocabulary. One is the `Pinned{P}` marker
(above). It wraps the whole entry, and **a marker below the top of an entry
is `IllegalPortType`** ([D-265][d-265]). The other is a `StopFlag` entry, which
places nothing and is left alone ([§13.5][s13-5]). A mutable type anywhere in
an entry of either contract is `IllegalPortType` too ([§4.3][s4-3],
[D-237][d-237]).

On a continuous consumer the declaration is [walked](#g-walked), which means
that every `Float64` position follows the scalar and a `Pinned` leaf stays
`Float64`. On a discrete consumer it pins wholesale. A `Pinned` entry there
says nothing and is `DeclarationOnWrongTier` ([§8.5][s8-5], [D-263][d-263]).

**Entries are [face](#g-face) bounds, not cell types, and the reading is permissive**
([D-263][d-263], [D-078][d-078]). A face is the name a port wears on its component's
boundary. An entry states, per leaf, what the consumer *allows* to arrive there.
Entries come in three forms.

| entry | the leaf is | what may lawfully arrive |
|---|---|---|
| `Float64`, alone or as a type parameter (`SVector{3, Float64}`, `RQuat{Float64}`) | tolerant | the activation scalar or a frozen `Float64` |
| `Pinned{Float64}`, or `Pinned{P}` around any leaf type | demanding frozen | never partials |
| `Int`/`Bool`/enum leaves, abstract reference-typed entries | as it always was | what the declared bound admits |

`RQuat` is a domain wrapper type ([§7.1][s7-1]). It stands for FlightPhysics'
rotation quaternion, which takes no type parameter. `RQuat{Float64}` is the
spec's form of it.

An unpinned entry is what a promoting consumer writes, and it is the
overwhelmingly common case. A walking producer, a frozen discrete producer and
a [root input](#g-root-input) (the root component's own input face, produced
by no component) are all admissible behind it. Substitution therefore stays
intact.

A `Pinned` entry is the FFI door. This input must never carry partials. A
component whose internals cannot propagate `Dual`s (an opaque wrapper, a C
table, a hand-rolled solver) declares it. Its AD-incompatibility then becomes
schema-visible instead of folklore. The failure moves from a `MethodError`
inside user math at the first `Dual` [probe](#g-probe) (the build's checking
evaluation of a user function) to a named wiring error at build
(below). **`Pinned` records that a leaf carries no partials, not that
an implementation cannot take them** ([D-266][d-266]). An AD-opaque
implementation that must participate keeps its entry tolerant and supplies a
local derivative rule ([§14.10][s14-10]). A walking producer feeds a pinned
entry through the `Freeze` block ([§13.7][s13-7]).

`Int`/`Bool`/enum leaves and abstract reference-typed entries stand as they always
were, admitting what their declared bound admits. **[Abstract entries](#g-abstract-entry) state
structural substitutability** ([D-078][d-078], [D-296][d-296]). Several concrete producer types are
admissible behind one stable face. The field handles ([§4.4][s4-4]) are the demonstrated
client, as in `terrain = AbstractTerrainField`. They carry no scalar position,
because they are references rather than numbers. They are still never the tool
for eltype genericity. That tool is exactly an unpinned entry, a promoting
consumer writing `SVector{3, Float64}` rather than an abstract bound.

Inputs are the component's *requirements*. Only against them are the
unconnected-input error ([§6.1][s6-1]), over-wiring detection and
[did-you-mean](#g-did-you-mean) typo messages definable at all. A
did-you-mean message is the offending name plus the list-in-hand it should
have matched. [D-033][d-033] records the rejected names-only contracts.

**Two clauses check a wire** ([§6.1][s6-1], [D-263][d-263],
[D-236][d-236]). The first is the nominal bound check, stated at nominal.
Nominal means the `Float64` activation, and a declaration's `Float64` face.
The producer's declaration at `Float64`, markers stripped, must be `<:` the
entry at `Float64` ([D-078][d-078]). It is one uniform rule. It degenerates
to exact equality for a concrete entry, because concrete types are final. A
violation is `WireTypeMismatch`.

Beside it sits the tier-scoped walk-compatibility clause, the walk clause for
short. For a *continuous* consumer, a walking producer leaf (one the producer
left unpinned) requires an unpinned entry. A pinned producer leaf satisfies
either, because frozen values embed upward. Both sides are plain declarations
the walk retypes. The clause is therefore decidable in the structure step by
retyping them at a marker scalar. No user stage code runs ([§9.1][s9-1]).

An abstract entry's leaves cannot be enumerated. **The walk clause decides an
abstract entry on the whole declaration** ([D-236][d-236]). The producer's
declaration at the marker, or the same with every pinned leaf lifted to the
marker, must be `<:` the entry at the marker ([D-236][d-236]).

The walk clause admits an opaque leaf ([§4.3][s4-3]), a handle stored whole,
on the same terms as a pinned or walking leaf. An opaque leaf has no scalar
position to embed through, and the clause does not need one. **A frozen handle
arriving at an unpinned entry is the producer's cell**, gathered as stored
([D-264][d-264]). The consumer's own arithmetic promotes whatever it reads
from it ([D-264][d-264]). A discrete producer of a handle, which pins
wholesale, is admitted the same way. **The identity rule for an opaque leaf
governs a store, never a wire** ([§9.5][s9-5], [D-264][d-264]). That rule
accepts an opaque leaf into a store by identity alone, and the leaf embeds
nothing.

A violation of the walk clause is `WalkingFaceAtFrozenEntry`, naming both
endpoints, the leaf and both declared leaf types ([Appendix C][sC]). The
message carries both remedies, "remove the entry's `Pinned` if the consumer
promotes; feed it from a non-walking source if the freeze is genuine". The
`Freeze` block is the one-line spelling of the second remedy ([§13.7][s13-7],
[D-266][d-266]).

The walk clause also gives the two sides of a contract their failure
asymmetry. A pin written at an entry whose consumer really promotes fails at
the *first nominal build*, at the wire, with both endpoints named
([D-263][d-263], [D-321][d-321]). It fails there because an input has a
build-time counterparty. The output side has none, so a pin written at a leaf
that really participates lurks until the first `Dual` activation. It lurks
loudly, never silently (below, [D-286][d-286]).

**Discrete consumers take the bound check only** ([D-263][d-263], [D-295][d-295]). That scope
is a correctness rule rather than tidiness. A discrete stage reads exclusively
at real [ticks](#g-tick) (the instants a discrete component runs) in the
nominal world. A `Dual`-carrying cell exists only inside activations discrete
stages never run in ([§9.4][s9-4]). Wires from a continuous producer to a
discrete consumer are therefore unconditionally legal. The unscoped variant is
rejected ([D-295][d-295]).

Because entries are bounds, nothing is ever "overwritten". Cell types are
single-sourced from the producer side per activation ([§9.4][s9-4],
[D-054][d-054]). A `Dual`-carrying cell behind an unpinned entry is the design
working, not a promise broken.

The code-level complement is the genericity obligation. It says that whatever
scalars the wiring delivers, the consumer's math promotes. It is still checked
by the `Dual` probe, never declared ([D-054][d-054]). **The obligation is scoped
to the unpinned entries** ([D-263][d-263], [D-295][d-295]). A `Pinned` input imposes no such
obligation, which is its point. **Declarations record choices, and obligations
are checked** ([D-078][d-078], [D-296][d-296]). The marker's absence records the tolerance
choice, and the probe checks the promotion.

**Three rules are author-facing**, and together they keep the math promoting
([D-011][d-011], [D-235][d-235], [D-304][d-304], [D-307][d-307]).

1. No `::Float64` argument annotations in math. Use `<:Real` or nothing.
2. No `Float64`-pinned intermediates. Write `zero(SVector{3,T})`.
3. No `::SomeType{Float64}` return-type annotations on the continuous path,
   because they force converts and hence `InexactError`.

The permissive reading is the operative one ([D-263][d-263]). It escapes two
other readings. The *predictive* reading has the entry saying what *will*
arrive. The *envelope* reading has it as a promise to promote. The log rejects
both ([D-054][d-054], [D-078][d-078]). The permissive reading predicts nothing,
and it is not constant, because pinned entries are rare but real. That is what
makes the marker carry information here.

#### Root inputs

Root inputs are the one place an entry types a cell. A root input is produced
by no component, so it has only the consumer declaration to take a type from.
The root-input type is the entry at `Float64`, markers stripped, and only a
*tight* bound determines one ([D-078][d-078], [D-296][d-296]). A face surfacing as a root
input must therefore resolve to a concrete declaration, which
[staging cells](#g-staging-cell), the [trace header](#g-trace-header) and
`probe_value` all need. Staging cells hold each device's pending writes, and
the trace header is the trace's fixed preamble.

**Abstract-at-root is a build error** ([D-236][d-236]). The uniform root doctrine
below does not relax it ([D-208][d-208]). A leaf declaring an abstract entry
(`terrain = AbstractTerrainField`) still cannot be built bare. `AbstractAtRoot`
names the face and the remedy, which is to wire a concrete producer, or a stub
child in a test rig. The [component test rig](#g-component-test-rig) (a one-child wrapper
exporting its child's whole input face set, [§13.7][s13-7]) is the idiom for that
case. It satisfies the entry with a stub child *inside* the rig ([D-120][d-120]).

A root input whose type is an opaque leaf, a non-isbits immutable stored whole
([§4.3][s4-3]), is `IllegalPortType` ([D-237][d-237]). It has no synthesis
through `probe_value` ([§9.3][s9-3]) and no producer. It would also be a
second way for bulk data to enter a model, beside the field-emitting
component ([§4.4][s4-4], [D-008][d-008]). And a trace could neither record it
faithfully nor keep its data frozen ([D-364][d-364]).

Under fan-out the root-input type is the unique concrete declaration among its
consumers, and abstract co-consumers are checked against it ([D-236][d-236]).
Two different concrete declarations remain an error, `RootInputTypeConflict`
([D-236][d-236]).

The root-input cells at an activation follow the root-input type by retyping
that same entry at the activation's `T`. **That retyping makes seedability
schema-visible** ([D-263][d-263], [D-295][d-295]). An unpinned root input is a
lawful linearization `B`-matrix tap, and a `Pinned` root input is *declaredly*
unseedable ([§14.10][s14-10]).

**Fan-out combines tolerance by a meet, not by agreement** ([D-168][d-168]).
The root input pins at every activation if *any* consumer's entry pins. It
follows the scalar only when every consumer tolerates. Concretely, the
root-input cells at an activation are the root-input type with every leaf
following the scalar when every consumer's entry admits that type, and the
root-input type itself otherwise. A mixture of pins across leaves therefore
pins the whole root input ([D-236][d-236]).

Two consumers of one root input may agree at nominal and still differ in
tolerance. `SVector{3, Float64}` and `Pinned{SVector{3, Float64}}` are one
type at nominal. The root input *type* is therefore unambiguous while the
entries disagree about partials. That mixture is a legitimate model rather
than a mistake. A command consumed by a promoting aerodynamics leaf and by an
AD-opaque table is the FFI door in use.

The direction of the meet is forced by embedding. A pinned root-input cell
feeds an unpinned entry lawfully, because frozen values embed upward as
zero-partial constants ([§9.5][s9-5]). A `Dual`-carrying cell arriving at a
`Pinned` entry is precisely what that entry forbids. The meet is therefore the
only assignment satisfying every consumer at once. It mirrors the
walk-compatibility clause ([§6.1][s6-1]) on the producer side.

What the mixture costs is stated where it is paid. Such a root input is
unseedable. A tap selecting it is rejected naming the *pinning consumer*
rather than the face alone ([§14.10][s14-10], [D-168][d-168], [D-296][d-296]).

**Any component may be the root of a build, and the model's root inputs are
the root's own input faces** ([D-208][d-208]). For an
[assembly](#g-assembly) (a component of pure composition) those are the faces
declared through `input_wires`, each traced through the face chain
([§6.1][s6-1], [§11.3][s11-3]) to the leaf entries consuming it. For a
primitive they are its `u_types` keys directly, because a leaf's faces are its
own port names ([§8.6][s8-6]). Each is then its own consuming entry. The type
derivation is one rule across both cases, the tight bound at the ultimate
consuming entry, above. At the root the two contract declarations share one
face namespace, so a key declared in both is a build error ([§8.6][s8-6],
[D-210][d-210]).

#### Output contracts: `y_types`

`y_types` declares the public port contract, and it declares it by type.
Like `u_types`, it is written at nominal `Float64`, takes the component alone
on both tiers, and is walked on the continuous tier. The input side is read
permissively, but this side is read literally. An entry states what the cell
*carries*, not what it tolerates.

On a continuous producer the declaration is spelled as follows.

```julia
y_types(::Engine) = (M_shaft = Float64, P = Float64, ω = Float64)
```

The cell types at an activation are that declaration retyped at the
activation's `T` by the leaf walk ([D-079][d-079], [D-263][d-263]). On a
discrete producer the same spelling pins wholesale. That is the discrete
exemption ([§7.2][s7-2]), enforced by tier. The leaf's tier decides which
reading applies, never the contract's shape. The tier is declared by the
leaf's state declaration (above and below).

Semantics are literal once the walk has run. The cell type is the retyped
declaration, with nothing inferred. Participation is therefore authored per
leaf and legible on the page. The leaf forms read as follows.

- `Float64`, alone or as a type parameter (`SVector{3, Float64}`,
  `RQuat{Float64}`, `MyStruct{Float64}`), means the leaf participates ([D-263][d-263]).
  Its cell carries the activation scalar. Value parameters are structure rather
  than number, and they never take it ([D-079][d-079]). The bounds in
  `Ranged{Float64, -1, 1}` are not scalars to re-type. `Ranged` is a domain
  wrapper type too ([§7.1][s7-1]).
- `Pinned{P}` means the leaf is deliberately pinned, and the pin is
  schema-visible. The wrapper is stripped at nominal, so the cell is `P` at
  every activation. It is whole-leaf freezing, declared and
  conformance-checked. That delivers the recorded freeze door
  ([§14.10][s14-10]). Declare `Pinned{Float64}` and strip with
  `ForwardDiff.value` inside the stage ([D-286][d-286]). The stop-gradient is
  then stated in the contract instead of buried mid-expression. The marker
  sits at the top of the entry and nowhere below it ([D-265][d-265]).
- `Int`/`Bool`/enum leaves and reference-typed fields pin ([D-079][d-079]).
  The grid of a bulk-data handle ([§4.4][s4-4]) is frozen build-time data,
  never activation-dependent. The walk never reaches it, because references
  are fields and the walk substitutes type parameters alone. A handle
  carrying a scalar *parameter* walks like any type, and one built from
  build-time data is declared `Pinned` ([D-237][d-237], [D-263][d-263]).
- A mutable type's parameters pin by rule ([D-263][d-263]). No stage can
  produce a `Vector{Dual}` inside a handle without copying the grid at every
  evaluation, so there is no choice for a marker to record.

**A handle keeps its bulk at `Float64` and its activation-dependent part in
the parameter** ([D-263][d-263]). The rule reads off the shape. References are
fields, so a grid typed `Matrix{Float64}` stays frozen at every activation,
and a pose typed `T` follows the scalar. The `DeckField` sketch has both.

```julia
struct DeckField{T}
    heave::T                 # pose: follows the activation scalar
    pitch::T
    grid::Matrix{Float64}    # geometry: frozen build-time data, never re-typed
end
```

Inside a query nothing converts the grid. Each product of a grid entry and a
`Dual` weight promotes on its own. The query's result therefore carries the
pose's partials and the interpolant's slope, while the grid is read as it was
loaded. A `Matrix{T}` grid would give the same numbers at the cost of a copy
per evaluation. That is the copy the mutable-parameter rule above refuses.

The producer pins the handle when it is built from build-time data alone, as
for a static terrain. It leaves the handle walking when its parameters come
from state, as for a moving ship deck, whose heave and pitch are continuous
state. A field that must never follow the scalar is typed concretely in its
struct, `b::Float64` beside `a::T`, which freezes it for every user of the
type. The marker pins a whole leaf, and a pin on one parameter of one
declaration is not offered ([D-265][d-265]). The rule "every `Float64`
position follows the scalar" reads the declaration as written, so a
concretely typed field is frozen without appearing in the contract
([D-265][d-265], [D-297][d-297]). The walkthrough `handle_walk_walkthrough.md` works a static
terrain and a moving deck through one consumer.

A custom struct is a first-class port type, as in
`contact = GearContact{Float64}`, under the scoping that [§7.2][s7-2] establishes. Here
`GearContact` is a landing-gear contact. That scoping requires a struct
parametric in its real-scalar leaves, with constructors inferring the scalar.
The parametrization is mechanical. Call sites do not change, and `@kwdef` defaults pin the no-argument case
to `Float64`. `@kwdef` is Julia's keyword-constructor macro. A
participating struct leaf is declared with `Float64` in its parameter position,
`GearContact{Float64}`. The walk retypes it there, recursively for nested
parameters ([D-263][d-263]). A struct with a hardcoded `Float64` field offers no such
position. The walk therefore leaves it as written, a pinned leaf by shape, and
`Pinned{GearContact}` says so on the page. Any `Dual`-carrying construction then
fails inside the stage with an `InexactError` naming the offending constructor.
That is the CI invariant of [§7.2][s7-2], reached through the declaration layer with
no extra machinery.

The companion obligation is constructibility at `T`. **A declared type must
be buildable at the activation scalar** ([D-079][d-079]). The `Dual` probe
enforces it by construction. The probe builds real values, so a type whose
constructor cannot accept them fails at the probe with its own name in the
message.

During a generic sweep, gated-off discrete producers hold their `Float64`
values. Consumers gather mixed tuples, and promotion does the rest. That is
semantically exact ([D-079][d-079], [D-297][d-297]). A frozen discrete output is a constant
with zero partials. That is precisely what "linearize the continuous dynamics
with the discrete state held" means. The frozen cell is not an AD limitation
on the signal path. It is the true zero of an instantaneous dependence the
hybrid semantics never had (`frozen_discrete_walkthrough.md`).

The embedding guarantee ([§9.5][s9-5]) makes the mixing safe. It is keyed on
walking leaves ([D-238][d-238]). A `Float64` observed at a walking leaf under
a non-nominal activation implies that no `Dual` entered its computation. The
reason is that promotion is airtight and there is no lossy cast. Its true
derivative along every seeded direction is therefore zero, and embedding it
as a zero-partial constant is exact.

Piecewise branches returning literal constants (`flow > 0 ? f(x) : 0.0`) are
legal as written, because zero partials are the derivative of a
locally-constant branch ([D-194][d-194]). Which *invocation* carries
partials is still chosen by seeding ([§14.10][s14-10]), never by typing
([D-079][d-079], [D-297][d-297]). The declaration says which leaves *can* carry them, and the
seed says which directions do.

The misplaced-pin account is stated openly here. A leaf that really participates
cannot be declared frozen by habit, because the habitual spelling, a bare
`Float64`, walks ([D-263][d-263], [D-297][d-297]). What remains is deliberate, and it comes in two
bugs. The first is writing `Pinned` at a leaf that really participates. The
second is omitting it at one that really does not.

**The first bug lurks, but is never silent** ([D-286][d-286]). No lossy `Dual → Float64`
cast exists, so the first `Dual` activation of that component fails. It fails at
that activation's own lazy compile ([§9.4][s9-4]), not at `build(world)`. The message
carries the didactic hint ("if `F` participates in differentiation, remove its
`Pinned`"), because an observed `Dual` at a pinned leaf has exactly one honest
cause. A didactic diagnostic is one that states its fix ([§13.2][s13-2]). The second
bug fails at the same activation. It fails inside the stage where the frozen
internals meet a `Dual`, or at the identity comparison on an opaque leaf built
from build-time data ([§9.5][s9-5]).

Both lurks are contained by policy rather than machinery. The test suite
builds a `Dual` activation of every component ([D-280][d-280]). That is the
exhaustive set that [§9.4][s9-4] defines. An activation is derived from the
nominal one, and it is cheap enough to make this policy unremarkable in CI.
What the plain form buys in exchange is one convention. Every declaration in
the framework is read with the same walk rule, and a genuinely frozen leaf
still says so on the page ([D-263][d-263], [D-297][d-297]).

Declared initial values are walked by the same rule, with no marker ([D-263][d-263],
[D-295][d-295]). The type derived from `x_init` is walked. Real leaves and `Real` type
parameters follow the activation scalar. `m_init` and `s_init` pin wholesale,
mirroring the discrete-producer rule. `Pinned` has no place in a state
declaration, because [§7.1][s7-1] admits no pinned state leaf for it to mark ([D-295][d-295]).
Declared `Float64` initial values embed as zero-partial constants under
non-nominal activations ([D-079][d-079], [D-297][d-297]). That is the rule for `Float64` condition
leaves ([§14.3][s14-3]) applied to the defaults those conditions overlay.

Walking `x_init` presupposes the closed leaf vocabulary that [§7.1][s7-1]
fixes, scalars and `SArray`s at the common eltype ([D-094][d-094]). On the
discrete tier, the stores answer to the isbits rule of [§7.3][s7-3], checked
field by field ([D-231][d-231]). The structure step checks both vocabularies
([§9.1][s9-1]). It reports a failure in the didactic style, as these messages
show.

- "`x_init` field `gear_count::Int` is not a continuous state — integers,
  `Bool`s and enums belong in `m_init`";
- "`x_init` field `q_nb::RQuat` is not a state leaf — declare the `SVector{4}`
  backing and cast where rotation semantics are wanted ([§7.1][s7-1])";
- "`x_init` field `pose::NamedTuple` is not a state leaf — a field is one
  scalar or `SArray`; split it into fields, structure comes from the component
  tree ([§7.1][s7-1])";
- "`s_init` field `label::String` is not a store value — store fields are
  isbits or `Symbol`s; text and bulk data belong on the component instance
  ([§7.3][s7-3])".

A `StopFlag` output entry is a [stop request](#g-stop-request) (a port that
ends the run when it reads `STOP_REQUESTED`, [§13.5][s13-5]). Its companion
declaration is optional. **`stop_reason(c)` returns the `String` a
component's stop requests report, and it defaults to `""`** ([D-316][d-316]). The
build reads it for every component that publishes a `StopFlag` port, and all
of a component's requests share it. The reason is instance data, never a
port value, so the isbits rule never meets it. It is a family name, in the
import list of [§8.1][s8-1], so the shadowing check covers it.

#### Function arguments: one bundle

**Every function receives exactly two arguments**, the component and one
`NamedTuple` bundle of zero-copy views ([D-074][d-074]). From that bundle the
author destructures by name only what the body reads, as in
`x_deriv(c::LowPassFilter, (; x, u)) = …` and `y_direct(c::PID, (; s, u, Δt)) = …`.
Here `PID` names a proportional-integral-derivative controller. Which names a
bundle holds is the bundle law of [§5.2][s5-2].

The rule exists so that the [executor](#g-executor) (the compiled form of
the stage execution order) issues one fixed call shape, `fn(comp, args)`. Two
more reasons support it. Language semantics ignore unread fields. Argument
order cannot be confused, because there is no order.

Positional, `kwarg_decl`-reflected and slurping-keyword spellings are all
closed ([D-074][d-074], [D-341][d-341]). A `kwarg_decl`-reflected spelling
takes keyword arguments whose names the framework reads through Julia's
internal `Base.kwarg_decl`. A slurping-keyword spelling takes keyword
arguments and ends its keyword list with a `_...` slurp.

**`x_projection` alone stays positional** ([D-074][d-074]). It takes one
store in and returns the same store out, so there is nothing to select.

#### Field handles: the value-level constructor

A field-emitting component publishes a [field handle](#g-field-handle) (an
immutable query object a consumer evaluates at arguments of its own choosing,
[§4.4][s4-4]). **Every field-emitting component must expose the map
(component, input values) → handle as a plain, pure, public function**, its [value-level constructor](#g-value-level-constructor)
([D-139][d-139]). Take `SimpleAtmosphere`, the parametric atmosphere of
FlightPhysics, Flight.jl's physics library. For its successor, that function is
`atmospheric_field(atm; T_sl, p_sl, wind)`. The field-emitting component's
swept output stage must be a one-line call to that function, never the other
way round. The other way round puts the query math in the output stage, where
only a sweep can reach it.

The reason is script-side. The condition math of [§14.1][s14-1] must be able
to construct, outside any sweep, bit-for-bit the same handle the sweep would
produce from the same values of the root inputs. One implementation serves
two call sites, so there is no drift. The drift avoided here is the silent
drift that [§5.3][s5-3] exists to kill. The value-level constructor is a
*shipped component's obligation*, not something a consumer can retrofit. The
real component composes environment sub-models, and anyone else
reconstructing the map has re-created that drift.

For bulk-data components the obligation is only that the query math be
reachable as a plain function ([D-139][d-139], [D-363][d-363]). They own their
resource loading, so building a handle outside a build may cost a load. That
cost is acceptable, because condition authoring is design-time code.

The sketch below shows the map as a plain function, and the stage that does
nothing but call it.

```julia
#the map: plain, pure, public — callable outside any sweep
atmospheric_field(atm; T_sl, p_sl, wind) = ISAField(…)

#the swept output stage: one line, nothing but the call
y_direct(atm, args) = (; … = atmospheric_field(atm; T_sl = …, p_sl = …, wind = …))
```

#### Events: `state_events`

`state_events` declares an ordered, named collection of [guard](#g-guard)/handler pairs (a
guard is the declared function defining an event's predicate). A pair is spelled
`StateEvent(guard, handler)`, with no detection keyword. Detection policy is
declared by the guard's return type instead ([D-179][d-179]). A `Bool` guard makes the
event [boundary-detected](#g-boundary-detected), checked for edges at step boundaries only, with no
root-finding. A guard returning the nominal scalar makes it [localized](#g-localized), with
the crossing instant bracketed by root-finding over trial sweeps ([§10.4][s10-4]).

Order is semantics. It is the declaration order used by [§5.3][s5-3] and the
priority order, with re-decision, used by [§10.6][s10-6]. Nothing here is
inferrable.

#### Stage membership

**No port carries a stage tag, and stage membership is derived**
([D-033][d-033]). Which stage produces which port stays invisible in the
contract, preserving [§4.2][s4-2]. Moving a port between stages is
non-breaking for consumers.

**Stages are discovered by method existence** ([D-350][d-350]). An output
stage exists when the leaf defines its method, and the build reads which
stages exist without evaluating anything.

The derivation has no chicken-and-egg. Stage-1 functions (`y_state`)
structurally receive no inputs, so the build probes them first and observes
their contract ports. It assigns the remainder to stage 2, builds the graph, and
probes the stage-2 chain in topological order with real upstream values. The
property that stage 1 takes no inputs is exactly what makes the derivation
well-founded.

A leaf's declarations do carry its tier ([D-195][d-195], [D-220][d-220]), and
that is a different fact. The tag refused here is the *stage* tag on a port,
which stays invisible either way.

#### Completeness

The build checks three rules in the structure step ([§9.1][s9-1]). They are
stated here because they are properties of the declarations, not of the
wiring.

A non-empty state declaration needs its update. `x_init` with fields and no
`x_deriv` method, or `s_init` with fields and no `s_update` method, is a build error,
`StoreWithoutUpdate` ([D-263][d-263]). The first case is continuous state with no [flow](#g-flow) (the
continuous derivative function, `x_deriv`), the second a discrete store nothing
updates. The framework will not silently supply `ẋ = 0`, which is a model, not a
default. An unupdated discrete store is a parameter in disguise, and parameters
are plain struct fields.

An empty state declaration owes nothing (above). `m_init` carries no such
obligation either.
Modes are written by handlers, and a component may legitimately declare modes no
event of its own transitions.

An event needs both halves. A `state_events` entry whose guard or handler has no
method for the component type is a build error, `EventHalfMissing` ([D-215][d-215]). Method
lookup catches it at declaration-reading time, rather than as a `MethodError` at
the first firing. An event that fires only in a corner of the envelope would
otherwise hide the omission indefinitely. An entry that is not a `StateEvent` is
`EventHalfMissing` too ([D-215][d-215]).

Tier is declared by the state declaration, as "State and mode declarations"
above states ([D-195][d-195], [D-263][d-263]). A
stateful leaf announces it in the update law as well, `x_deriv` beside `x_init`
and `s_update` beside `s_init`. The two output stages are one pair of names shared
by both tiers, so they announce nothing and cast no vote ([D-220][d-220]).

**The remaining tier-implying declarations must agree** ([D-112][d-112], [D-249][d-249]). `m_init`,
`state_events` and `x_projection` are continuous-only, because the event system is
continuous-side only ([§5.2][s5-2], [§14.1][s14-1]) and projection's one manifold is the
continuous state's ([§2.5][s2-5]). A `Pinned` entry in a contract is continuous-only,
because the discrete tier pins wholesale and the marker there says nothing. No
arity carries a tier (above).

Disagreement is `DeclarationOnWrongTier` ([Appendix C][sC]). It is reported as the
offending declaration, with the tier the leaf's other declarations announce. It
covers declaring both `x_deriv` and `s_update`, a `Pinned` entry on a discrete leaf,
and the mixed cases that the split state letters (`x` for continuous state, `s` for
discrete, [D-195][d-195]) restore. Those are both state declarations on one leaf, an
`x_init` on a leaf whose update law is `s_update`, and an `s_init` on one whose update
law is `x_deriv`.

A stateless leaf is a leaf whose state declaration is empty, and it declares its
tier the same way. `x_init(::C) = (;)` makes it continuous, the tier [§13.7][s13-7] steers
stateless leaves to. `s_init(::C) = (;)` makes it discrete, one that runs at its
ticks and holds its outputs between them.

`y_types` stays mandatory on a stateless leaf. A leaf with an empty state
declaration and no output contract produces nothing and stores nothing, and it
is refused as `StatelessWithoutOutputs` ([Appendix C][sC], [D-263][d-263]). The stage bundles
follow the tier like any other leaf's, with no `x` or `s` field, because the bundle
law puts a state declaration's letter in the bundle only when it is non-empty
([§5.2][s5-2]). [§13.7][s13-7] records why one stateless continuous leaf already serves consumers
on both tiers. A type declaring both the leaf and the assembly families of
declarations, or neither, meets the class errors of [§8.5][s8-5].

### 8.3 Visibility: the contract is the interface

This section decides which of a [component](#g-component)'s values are public. It states the
visibility rule, then the inspection path for an intermediate, then the
checks that hold stage returns and declarations to each other.

**Visibility is decided by *where the value goes*** ([D-034][d-034]):

- a field declared in `y_types` is public;
- a field returned in `y` (a stage's own published signals) and declared
  nowhere is a build error;
- a component with no `y_types(::C)` method has no outputs, and a stateless
  leaf without one is refused as `StatelessWithoutOutputs` ([§8.2][s8-2],
  [D-263][d-263]).

That is the same move as class-by-declaration-shape ([§8.5][s8-5]). [Ports](#g-port) in the
[contract](#g-contract) (a component's declared interface) are connectable, GUI-listed,
[snapshot](#g-snapshot)-carried and log-exported. A snapshot is the immutable per-boundary
publication. The table is public throughout, with every [cell](#g-cell) a declared port,
so nothing anywhere needs a presentation filter. Visibility is binary, with no
third class between the two. A value a later function reads travels as a
declared port like any other ([§5.2][s5-2]).

The inspection path for an intermediate is declaration ([D-194][d-194]). That follows
from the visibility rule above. One line in `y_types` makes it public, checked
and visible everywhere at once. FlightCore is the precedent. There an
intermediate could be inspected only by putting it in the model's output.
Publicity is never implicit ([D-297][d-297]). Even the minimal component writes
`y_types(::LowPassFilter) = (x = Float64,)`, one line, in exchange for "public"
always meaning someone wrote it down.

**A declared port must be produced by exactly one stage**, stage 1 or stage 2
([D-252][d-252]). Those two classes are the whole classification, and the
framework produces no port of its own. Stage membership is derived over
`y_types` alone ([§9.1][s9-1]). Declared-but-unproduced and
produced-by-two-stages are build errors. A port two stages both return is
`ProducedByTwoStages`. A declared port no stage produces is
`DeclaredNotProduced`, which names the port, the stage products and the state
fields. Its remedy is returning the name from `y_state` ([§5.3][s5-3]).

The return side is checked too. A *returned port field* declared nowhere is a
build error at [probe](#g-probe) (the build's single evaluation of a user function). The
error, `UndeclaredReturnField`, carries a [did-you-mean](#g-did-you-mean) (the offending name plus the list-in-hand it
should have matched) against `y_types`. That is the return-side analogue of [§8.4][s8-4]
walkthrough 1 ([D-034][d-034], [D-239][d-239]). Walkthrough 3 of [§8.4][s8-4], the forgotten branch
field, holds. A declared `P` missing from the taken branch's return fails at
probe. Missing from an *untaken* branch, it fails loudly at that branch's first
execution via the always-on check.

**Stage returns must have the same `NamedTuple` shape on every branch**, the
branch-shape rule ([D-034][d-034]). Julia's type-stability discipline already
demands that for performance. The framework merely makes it a stated rule
with a good error.

[Schema authority](#g-schema-authority) is total over the table ([D-032][d-032], [D-034][d-034]). Schema authority
means declarations define structure and evaluation only checks conformance.
Every *cell* traces to an authored declaration, and the always-on check's
expected type for `y` is fully declaration-derived. Return typos cannot silently
define new cells ([D-239][d-239]). Protection against silently dropped partials rests
on the embedding guarantee ([§9.5][s9-5]). Promotion is airtight, so an observed
`Float64` is a true constant. Probe-observed expected types remain rejected
([D-034][d-034], [D-194][d-194]).

Binary visibility has a cost where a component is split to break an
artificial loop ([§5.4][s5-4], [D-343][d-343]). Every intermediate shared across the new boundary is declared
in `y_types`, and is therefore public, connectable and substitution-relevant.
The mitigating idiom is the granularity guideline ([§4.3][s4-3]), which the
split case satisfies trivially, with one producing stage and one consumer. It
spells out as one struct-valued bundle port, not N loose ports. In
Flight.jl's landing-gear strut that port would carry a `StrutGeometry`-shaped
value. The bundle port's type is then contract. That is a real cost, but a
bounded and honest one. No visibility level is added for the orphaned
intermediates ([D-194][d-194]). [D-034][d-034] and [D-055][d-055] stay
closed, and with them the `Private(T)` wrapper and the `unlisted` flag below.

This section's rules exclude several designs the log rejects
([D-016][d-016], [D-034][d-034], [D-055][d-055], [D-194][d-194]). Among them
is the `unlisted` flag, a presentational flag that would skip a port in logs
and the GUI but leave it connectable ([D-363][d-363]).

### 8.4 Failure walkthroughs (the error-locality grounding)

The five mistakes below decided the choice between declaration and
inference-by-evaluation as the schema authority ([§8.1][s8-1]). They ground
[error locality](#g-error-locality) (the property that a mistake fails at the site of the mistake).
The list gives each with its failure site under this layer. Each was traced
under inference-by-evaluation too, and in every case the failure surfaced inside
*correct* code, later, or never. [D-032][d-032] carries the traces.

1. A typo'd wire (`:throtle`) is a build error at the connection, "no input
   `throtle`; did you mean `throttle`?"
2. A forgotten wire, such as `fuel_available` read only by a
   [guard](#g-guard) (the declared function defining an event's predicate),
   fails as the [§6.1][s6-1] unconnected-input error at build.
3. A forgotten branch field, such as `P` returned by one branch only, fails as a
   [probe](#g-probe) or first-execution error naming the declared [port](#g-port) (one declared input
   or output). A probe is the build's single evaluation of a user function.
4. A type mismatch, such as a `Float64` fraction wired into a `Bool` input,
   fails as a wiring-time error naming both endpoints and both
   [faces](#g-face) (the names ports wear on their component's boundary).
5. A typo'd return field, such as `P_shft = …` for a declared shaft power
   `P_shaft`, fails as a probe error with [did-you-mean](#g-did-you-mean) (the offending name plus
   the list-in-hand it should have matched) against `y_types`. That one error is
   the whole report. The probe chain stops at the port check ([§13.1][s13-1], [D-239][d-239]),
   and an unproduced-`P_shaft` error would only restate it from the other side,
   since renaming the field produces the port. A declared port no stage returns,
   on a component whose returns are all declared, is `DeclaredNotProduced`, with
   the stage-product and state-field lists in hand ([§8.3][s8-3]). Every returned
   field is a declared port, so this one error form is the whole case. An
   intermediate a later function reads is declared like any other output and
   typo'd like any other output ([§8.3][s8-3]).

### 8.5 Assembly declaration: type-based, class by declaration shape

This section states how an [assembly](#g-assembly) (a [component](#g-component) of pure composition) is
declared, how a type's declarations mark it as an assembly or a primitive, what
arity those declarations take, how container fields contribute children, and how
`Group` assembles components on the fly.

**An assembly is a plain struct** ([D-039][d-039]). Its fields whose type is
`<: AbstractComponent` are its children, and all its other fields are inert
parameters.

Field names are path segments. Substitutability and variants use ordinary
parametric fields, exactly the shape of `Cessna172X{K, A}`, Flight.jl's Cessna
172 model. Alongside the struct come the well-known declarations.
`local_wires(::A)` is mandatory even when empty, and
`input_wires(::A)`, `output_wires(::A)` and `sample_times(::A)` join it.
One more is optional, `transparent_container(::A)`, with default `nothing`.
Naming a container field there drops that field's segment from its children's
names, as "Container children" below states.

#### Class by declaration shape

**There is no `AbstractAssembly`, only one root `AbstractComponent`** ([D-039][d-039]). Two
reasons rule out a supertype for [class](#g-class) (a component's primitive-vs-assembly
status). First, the domain hierarchies have to carry both classes. In an
aircraft library, for example, these are `AbstractAircraft` and the engine
families. A field declared `E <: AbstractEngine` must accept a primitive
`PistonEngine` and a composite turbofan assembly alike. Second, class is
implementation detail behind the [contract](#g-contract) (a component's declared interface,
[§8.3][s8-3]).

Class is declared instead by *which* well-known declarations a type defines.
**`local_wires` is the marker**, mandatory even when empty, and defining
it makes an assembly ([D-039][d-039]). Any leaf declaration makes a primitive.
The leaf declarations are `x_init`/`s_init`/`m_init`, `ws_init`,
`u_types`/`y_types`, `state_events`, and any stage, `x_deriv`, `s_update` or
`x_projection` method.

The rule is total. A `<: AbstractComponent` type declaring neither family has no
class to read. It is a build error, `ClassUnreadable`, naming both families,
rather than a silence that fails later and elsewhere. When the type has
component-typed fields, that error sharpens into a [did-you-mean](#g-did-you-mean) (the offending
name plus the list-in-hand it should have matched). Its message reads "holds
components but declares no `local_wires`". `local_wires` plus any
leaf declaration on one type is a build error as well, `ClassMixed`.

Assemblies have no state of their own, which is the no-atomic-assemblies rule
at declaration time ([§10.5][s10-5]). They have no contract of their own
either. An assembly's [faces](#g-face) (the names its ports wear on its
boundary) are derived from its children ([§8.6][s8-6]).

Reading which declarations exist is reading declarations. It is the same move
as visibility-by-declaration-site ([§8.3][s8-3]), not the banned
inference-by-evaluation ([§8.1][s8-1]).

#### One arity on both tiers

Class fixes *which* declarations a type may define, and nothing about their
shape. Every declaration of a structural fact takes the component alone, on a
leaf of either [tier](#g-tier) (continuous or discrete) and on an assembly alike ([D-263][d-263],
[D-279][d-279]). The one exception, the allocator's scalar, is the same on both tiers
([§7.3][s7-3], [D-263][d-263]). The tier is read from the state declaration every leaf makes
([§8.2][s8-2]). That section states the arity rule and tier agreement in full. A
declaration on the wrong tier is `DeclarationOnWrongTier` ([Appendix C][sC]).

#### Container children

**A field whose type is a `Tuple` or `NamedTuple` with *every* element
`<: AbstractComponent` contributes its elements as [container children](#g-container-children)** ([D-085][d-085]).
They are path-named `"field/1"…"field/N"` for a tuple and `"field/key"` for a
NamedTuple, and declaration order governs layout.

**Containers are transparent grouping, not assemblies** ([D-085][d-085]). They
have no contract, no `local_wires`, no [rate scope](#g-rate-scope) (an
assembly's `sample_times` declaration) and no existence beyond the path
segment. The elements are children *of the parent*. The parent's
`local_wires`, `input_wires`, `output_wires` and `sample_times`
address them by element name. Anything wanting its own wiring or faces
declares itself an assembly.

The payoff is parametric composition. `struct Formation{NT <: NamedTuple};
aircraft::NT; … end` holds any roster per instantiation, of any size, with any
names and mixed aircraft types. Its declaration bodies generate wires by
comprehension over the keys. That is the arity-via-computed-contracts pattern
[§13.7][s13-7] uses for `Junction`, here at structure scale. The swarm
worlds ([§14.9][s14-9]) consume it directly. So does [mounting](#g-mounting), the relocation of a
whole problem or tap set with [`at`](#g-at)`("aircraft/red", problem)`.

**A component may declare at most one of its container fields
name-transparent** ([D-211][d-211]). The declaration is

```julia
transparent_container(::MyType) = :field
```

That field's elements are then contributed under their bare keys, `"key"` and
`"1"` in place of `"field/key"` and `"field/1"`. The bare keys apply everywhere a
child name appears, namely in wiring endpoints, `sample_times` keys, read paths,
`at` prefixes and diagnostics ([D-211][d-211]).

Naming is the only thing the declaration changes. The elements are the
parent's children exactly as before, laid out in declaration order. The
container keeps its transparency of contract, with no `local_wires`, no
faces and no rate scope.

The edges of the container form are fixed by rule.

- A container mixing component and non-component elements is a build error in
  this section's did-you-mean family ([D-085][d-085], [D-298][d-298]). The error is
  `ContainerMixed`. All-component elements are children, and zero-component
  elements are inert parameter data.
- Containers of containers are rejected in the first cut, because deeper
  grouping is what assemblies are for ([D-085][d-085], [D-298][d-298]). The element whose
  value is itself a component-bearing container is named, with its type
  (`ContainerNested`).
- Empty containers are legal and contribute zero children, so parametric code
  needs no special case ([D-085][d-085], [D-298][d-298]).
- Abstract element types follow the same concreteness discipline as plain
  fields. They are directly concrete, or concrete through type-parameter
  bounds. That is the [generic holding](#g-generic-holding) (a parent holding
  a child through a non-concrete field type) that [§8.8][s8-8] allows ([D-043][d-043]).
- **A bare key from a name-transparent container colliding with any sibling
  child name is a build error naming both** ([D-211][d-211]). The error is
  `ChildNameCollision`. The `sample_times` sugar of [§8.7][s8-7], where a container's bare
  field name keys one declaration for all its elements, leaves only one
  ambiguity. A transparent element's bare key equal to its own field's name
  joins this collision error ([D-215][d-215]).
- **A bare key equal to the name of a sibling *container field* that
  contributes children is refused the same way** ([D-212][d-212]). No child
  bears that name, but the key would shadow the container's `"field/key"`
  segment grammar ([§6.1][s6-1]). Its elements would be unreachable behind a
  diagnostic that blames the wrong child. **An empty field reserves nothing**
  ([D-212][d-212]), because it reaches no children and its value cannot be
  told from empty inert parameter data. The judgment is therefore
  per-instantiation, like every wiring judgment.
- `transparent_container` must name a container field of the type, and a name
  that matches none is `TransparentContainerUnknown` ([D-211][d-211]). Declaring two
  transparent containers on one type is a declaration error ([D-211][d-211], [D-215][d-215]).

#### `Group`: the on-the-fly assembly

The *immutable* version of grouping components by plain calls needs no builder
(`Assembly()` plus `add!`/`connect!`, rejected below). It is already expressible
under this section's rules. **`Group` expresses it as a single library component**,
part of the library ([§13.7][s13-7], [D-184][d-184]). A `NamedTuple` field's elements
are its children by the container rule, name-transparent so they go by bare key
([D-211][d-211]). Its declarations are ordinary functions of the *instance*, free to read
its fields. The fields that hold wires and rates, and the keywords that set
them, bear the names of the declarations that return them ([D-303][d-303]).
**A `Group` also carries its own rate scope**, a `sample_times` field keyed
by bare element name ([D-300][d-300]).

```julia
struct Group{C <: NamedTuple, W, I, O, R <: NamedTuple} <: AbstractComponent
    children::C      # component-typed elements → children by the container rule
    local_wires::W   # inert parameter data
    input_wires::I
    output_wires::O
    sample_times::R  # the ad-hoc rate scope, keyed by bare element name (§8.7)
end
local_wires(g::Group)          = g.local_wires
input_wires(g::Group)          = g.input_wires
output_wires(g::Group)         = g.output_wires
sample_times(g::Group)         = g.sample_times
transparent_container(::Group) = :children

Group(children; local_wires = (), input_wires = (), output_wires = (),
      sample_times = (;)) =
    Group(children, local_wires, input_wires, output_wires, sample_times)

world = Group(
    (; plant = Plant(), ctrl = PID(kp = 2.0));
    local_wires = ("ctrl/u" => "plant/u", "plant/y" => "ctrl/y"),
)
```

`Group` is one type, defined once, and every ad-hoc topology is a *value* of it.
The type parameters still carry the children's concrete types, so activation is
unchanged. So is the [executor](#g-executor), the compiled form of the stage execution order
([§9.7][s9-7]). Wiring validation, did-you-mean errors and the two-producers error all
run at build against the instance exactly as for a named assembly.

What is given up relative to a named type is exactly what named types are
*for*. That is dispatching domain code on `::Cessna172X`, and a reusable
identity for the topology. The exploratory and programmatic composition
`Group` serves does not want it anyway ([D-298][d-298]).

**The builder (`Assembly()` plus `add!`/`connect!`) is rejected**
([D-039][d-039], [D-298][d-298]). Its one real advantage, programmatic generation, survives
intact in the type-based form. A declaration is an ordinary function body, and
loops and comprehensions build the returned tuple.

The reach of the builder rejection is fixed by [D-184][d-184]. It targets
mutable recipes, not type-based *semantics*. `Group` is the library's
anonymous assembly form beside the named types, shipped the way Julia ships
anonymous functions alongside named ones. It serves the model assembler (the
persona for whom topology is data rather than a named type, [§13.7][s13-7])
with a library addition that rests on one opt-in declaration,
`transparent_container` ([D-211][d-211]). With that declaration, a `Group`'s
wiring and rate declarations read exactly like a named assembly's, child and
face, with no `children/` boilerplate.

### 8.6 Paths, wiring and faces

An [assembly](#g-assembly) (a [component](#g-component) of pure composition, with no dynamics of its own)
wires its children and names its boundary with strings. A [face](#g-face) is the name a
[port](#g-port) (one declared input or output) wears on its component's boundary. This
section fixes the path form, the three wiring declarations and the direction
invariant they share, face names, [root inputs](#g-root-input) (the root component's own input
faces), and face uniqueness at the root. It then spells out a worked assembly,
the strapdown IMU, and its leaves. It closes with the boundary-sampling
contract.

**Paths are slash-separated strings**, relative to the assembly or the root they
are read from, with no leading slash ([D-040][d-040]). There is one canonical form.
Declarations, error messages, inspection reads of the snapshot and the log
([§11.2][s11-2]) and the HDF5 log tree share it verbatim. [Container children](#g-container-children) (the
elements of a `Tuple` or `NamedTuple` field holding only components, [§8.5][s8-5]) add
index and key segments, `"aircraft/2"` and `"aircraft/red"` ([D-085][d-085]). These are
ordinary segments, resolved against the container field. A container declared
name-transparent ([§8.5][s8-5]) adds no segment of its own, and its elements go by
bare key ([D-211][d-211]). Instance navigation, tuples of symbols and dotted paths were
all rejected ([D-040][d-040]).

The three wiring declarations use only the short case of that form, one child
segment and one face name ([§6.1][s6-1], [D-207][d-207]). A container
child keeps its key segment as part of that child segment, so
`"aircraft/2/face"` is one level and not two. The read side
walks the full depth, as `"systems/ldg/left/trn"` does in a [snapshot](#g-snapshot) (the
immutable per-boundary publication) or the log tree. Snapshot and log
inspection walk instances ([§13.3][s13-3]). One fact behind the rejection of instance navigation is
relied on downstream. Symmetric immutable siblings are `===`-identical, so a
path is unrecoverable from an instance. That is why the helpers
([§8.8][s8-8]) name the child by path.

`local_wires(::A)` is an ordered collection of `"src/face" => "dst/face"`
pairs. **Every pair runs strictly from a child face to a child face** ([D-170][d-170]). The
wiring rules apply ([§6.1][s6-1]). There is one wire per input, and every endpoint is
an immediate child and one of its faces, container key segments included.

**The assembly's boundary is declared by two further methods, one per
direction** ([D-170][d-170]). `input_wires(::A)` is an ordered collection of
pairs, face name => internal endpoint path. An input face routed to several
immediate children takes a tuple of paths instead, as in
`"trn" => ("left/trn_field", "right/trn_field", …)`. This is fan-out through
the boundary. **Every entry routes to at least one internal endpoint**
([D-210][d-210]). An empty tuple is a declaration error, because a face
feeding nothing declares nothing ([D-210][d-210]). `output_wires(::A)` runs the
other way, internal source path => face name (`"aircraft/pose" => "view_pose"`),
so that its pairs, like every other pair in the three declarations, read along
the flow.

**Direction is declared by the method**, not inferred ([D-170][d-170]). The reason is one
invariant that spans all three declarations. Every pair's arrow points the way
the signal flows. The left side is a producer or entry point, the right side is
a consumer, and every right side is fed exactly once. The resolved endpoints
only *cross-check* the direction. An entry whose endpoint resolves to a port of
the wrong direction is a build error. The error names the method, the entry and
the resolved port's actual direction. A mixed entry is not expressible, because
the single list that made that error class possible does not exist. Two entries
producing the same output face remain the ordinary two-producers error ([§6.1][s6-1]).

**Face *types and [tiers](#g-tier)* are derived from the internal endpoints** ([D-041][d-041]). A
tier is the continuous or discrete side of the hybrid formalism. This derivation
is the [blessed](#g-blessed) (explicitly sanctioned) derivation-from-declarations ([§8.2][s8-2]). The
derivation is forced, not merely convenient. An assembly is tier-neutral. It
exports continuous-sourced and discrete-sourced ports side by side. A face's
[cells](#g-cell) (entries of the signal table) follow the producer's own declaration
([§8.2][s8-2]). They are retyped at the [activation](#g-activation) scalar by the [leaf walk](#g-leaf-walk) (the
framework's derivation of per-activation types) on the continuous tier, and
[pinned](#g-walked) on the discrete. Three alternative spellings are rejected ([D-041][d-041]).
Publicity is never implicit ([§8.3][s8-3], [D-297][d-297]).

**Face names are arbitrary strings with two build-checked invariants**
([D-046][d-046]). The first is that a face name contains no `/`, which is
reserved for structural paths. The second is uniqueness across the union of
the two boundary declarations' face names ([D-170][d-170]). Every other naming
choice is author convention, not framework law. Separators and grouping
prefixes like `"pilot.throttle_axis"` are such choices. The
`input_passthrough` helper's defaults ([§8.8][s8-8]) document the house style
without legislating it.

The two-notation rule this rests on is directional. **It separates structure
from derived contract, not read from write** ([D-129][d-129], [D-298][d-298]). Slash is
structure. It covers endpoint paths walking real children and ports, and the
inspection side's snapshot and log addressing. Face names are opaque
derived-contract tokens. The [periphery](#g-periphery) (everything outside the
loop that exchanges data with it) has a write side, made of input devices,
mappings, the trace and the GUI write path. That write side speaks face names
exclusively ([§11.3][s11-3]). The read side speaks them wherever it wants
meaning that outlives the build. It does so in integration bindings
(`get_face`, [§11.2][s11-2]) and service reads ([§14.4][s14-4]). The three
declarations return pairs of strings rather than NamedTuples
([D-046][d-046]).

Root inputs fall out with no vocabulary of their own. At every non-root level an
input face declared through `input_wires` is fed by the parent's wire. At the
root there is no parent. There the root component's input faces *are* the
[write surface](#g-write-surface), the set of faces a writer's batch entries may reach ([§11.3][s11-3]).
Which declaration supplies them follows the root's [class](#g-class) ([D-208][d-208]). Class is a
component's primitive-versus-assembly status. An assembly root supplies its
`input_wires` keys, and a primitive root its `u_types` keys ([§8.2][s8-2]). Nothing
downstream distinguishes the two. The whole-tree obligation model ([§6.1][s6-1])
states the complementary error rule. An assembly never declares its external
connections. Those live in the parent that instantiates it, exactly as a leaf's
do.

**At the root the uniqueness invariant follows the root's class**
([D-210][d-210]). A primitive root declares no boundary methods. Its face set
is therefore the union of its `u_types` and `y_types` keys. A key declared in
both is the same build error a duplicate face name is. The root is where those
two declarations first share an address space. A root input places a cell the
periphery writes ([§11.3][s11-3]), so a collision would put two cells at one
name. Below the root nothing collides, because a primitive's input faces alias
their producers' cells and place nothing. Non-root leaves are left alone.

#### A worked assembly: the strapdown IMU

A strapdown inertial measurement unit (IMU) is the strongest challenge
mounted against the two-leaf split of [§3.4][s3-4]. It is spelled here in
full, as a [worked](#g-worked) example (a full spelling of a mechanism against
a concrete case). It is a mixed-tier assembly. It exercises paths, faces and
sample times together:

```julia
struct IMU <: AbstractComponent
    integrals::IMUIntegrals    # continuous — cumulative Θ, q, Υ, V
    sampler::IMUSampler        # discrete — integrate-and-difference latches
    errors::IMUErrorModel      # discrete — scale/bias/noise on the sample
end

local_wires(::IMU) = (
    "integrals/Θ" => "sampler/Θ", "integrals/q" => "sampler/q",
    "integrals/Υ" => "sampler/Υ", "integrals/V" => "sampler/V",
    "sampler/sample" => "errors/sample",
)

input_wires(imu::IMU) = (
    input_passthrough(imu, "integrals")...,       # kinematic-truth inputs pass through
)

output_wires(::IMU) = (
    "sampler/sample"     => "sample",             # ideal increments
    "errors/sample_meas" => "sample_meas",        # measured increments (the error
                                                  # model's output port)
)

sample_times(::IMU) = (sampler = Relative(1), errors = Relative(1))
```

Two spellings are worth reading closely. First, `input_passthrough` enumerates
the child's *input* faces and nothing else ([§8.8][s8-8]). That is why the
pass-through of the integrals' kinematic-truth inputs (`q_eb`, `r_eb_e`,
`ω_eb_b`, `a_ib_b`, `α_ib_b`) is a bare splat with nothing to say about
direction. Second, the measured-increment face sources `errors/sample_meas`,
the error model's *output* port. It does not source `errors/sample`, the
input the sampler already feeds. Listing `errors/sample` in `output_wires`
would fail the direction cross-check. Listing it in `input_wires` while an
[local wire](#g-local-wire) feeds it is the two-producers error of [§8.8][s8-8].

The example carries two more facts. The first is that the assembly is
tier-neutral. Every face's type and tier derive from its internal endpoint, and
a `sample_times` key on `integrals`, the continuous child, would be a build error
([§8.7][s8-7]). The second is that the two discrete children default to `Relative(1)`
anyway, so this `sample_times` declaration is declaratory. Their absolute rate
arrives from the enclosing scope at deployment ([§8.7][s8-7]). The latch-back wire
(below, under "The boundary-sampling contract"), where the integrals consume the
sampler's published latch, would join `local_wires` as one more ordinary
pair.

#### The leaves: integrate-and-difference

The IMU's direct formulation is integrate-and-dump. It integrates raw
increments continuously, as `ẋ.ϑ_c = ω_ic_c`, `ẋ.υ_c = f_c_c`, the coning
attitude increment `q_c_cc` and the sculling integral
`ẋ.υ_c_sc = q_c_cc(f_c_c)`. Then, at the IMU's own `Δt`,
a discrete step reads the integrals, publishes the sample, and *zeroes them*.

In interval terms, these piecewise quantities are integrals over
$[t_{k-1}, t_k]$ with their weights re-anchored at each reset. `ϑ_c`
$= \int_{t_{k-1}}^{t_k} \omega^{c}_{ic} \, dt$ and `υ_c`
$= \int_{t_{k-1}}^{t_k} f^{c} \, dt$ run from zero, `q_c_cc`
$= q_{c_{k-1} \to c(t)}$ runs from identity, and `υ_c_sc`
$= \int_{t_{k-1}}^{t_k} R^{c_{k-1}}_{c} f^{c} \, dt$ has its rotation
anchored at the interval start.

The reset is what neither leaf class can spell. It is a discrete-tier write
into continuous state, and only handlers write `x` ([§3.4][s3-4],
[D-362][d-362]). It is periodic rather than predicate-triggered, so events are
the wrong mechanism ([D-362][d-362]). Integrate-and-dump is tightly coupled
continuous and periodic dynamics in one physical instrument, and it falls
squarely into the crack between the two leaf classes.

The IMU's leaves carry the idiom that answers it. Algebra can eliminate that
reset, with no approximation. **Every interval-relative integral becomes a
*cumulative* one** ([D-056][d-056]). The sampler differences against the previous sample,
held in its `s`. That is the textbook sampled-data latch. It is the only new
[store](#g-store), the memory the reset used to erase. The differencing
recovers exactly the interval forms above from the cumulative stores, term by
term.

- *Raw increments* (linear). The cumulative integrals
  $\Theta(t) = \int_{t_0}^{t} \omega^{c}_{ic} \, dt$ and
  $\Upsilon(t) = \int_{t_0}^{t} f^{c} \, dt$ are never reset. The increments
  are $\vartheta_c = \Theta(t_k) - \Theta(t_{k-1})$ and
  $\upsilon_c = \Upsilon(t_k) - \Upsilon(t_{k-1})$.
- *Coning*. The cumulative attitude $q(t) = q_{c_0 \to c(t)}$ follows
  $\dot{q} = \tfrac{1}{2} \, q \otimes \omega^{c}_{ic}$ from identity at
  $t_0$. The interval rotation is $\Delta q = q(t_{k-1})' \circ q(t_k)$. It is
  exact by right-invariance, because $\Delta q$ satisfies the same ODE with
  the same body rate.
- *Sculling*.
  $\int_{t_{k-1}}^{t_k} R^{c_{k-1}}_{c} f^{c} \, dt = q(t_{k-1})' \, ( V(t_k) - V(t_{k-1}) )$
  with $\dot{V} = q(t)(f^{c})$. The derivation takes two steps. First,
  re-anchor the rotation through the fixed $c_0$ frame,
  $R^{c_{k-1}}_{c} = (R^{c_0}_{c_{k-1}})^{\mathsf{T}} R^{c_0}_{c}$. The
  re-anchoring lets the $c_{k-1}$-dependent factor, constant over the
  interval, exit the integral. What remains is the cumulative integrand.
  Second, split its range at $t_{k-1}$. That gives the difference of the
  running integral:

  $$\int_{t_{k-1}}^{t_k} R^{c_{k-1}}_{c} f^{c} \, dt
  = (R^{c_0}_{c_{k-1}})^{\mathsf{T}} \left( \int_{t_0}^{t_k} R^{c_0}_{c} f^{c} \, dt -
  \int_{t_0}^{t_{k-1}} R^{c_0}_{c} f^{c} \, dt \right)
  = q(t_{k-1})' \, \big( V(t_k) - V(t_{k-1}) \big)$$

In code, the sculling result is the sampler line `υ_c_sc = s.q'(u.V - s.V)`. The
factor leaving the integral is the *anchor change between two inertially-fixed
frames*. It is constant because $t_{k-1}$ is in the past and latched. The
physical intra-interval rotation stays inside the integrand via $q(t)$. That
rotation is what sculling corrections are *about*. Every evaluation of the [flow](#g-flow)
(`x_deriv`, the continuous derivative function) applies the current cumulative
attitude, RK stages included. The direct formulation applies its current
`q_c_cc`, its coning attitude increment, in exactly the same way.

#### The exactness condition

**Interval-relative integrals factor into cumulative ones whenever the
interval dependence enters through a left action by the interval-start value
of a cumulatively-integrable quantity** ([D-056][d-056]). That action is the
identity for linear integrals, right-invariance for attitude increments, and
constancy of the anchor change for sculling.

Two provisos apply. First, **the cumulative attitude must be integrated with
the *inertial* rate** ([D-056][d-056]). The anchor frame is then inertially
fixed and the pulled factor rigorously constant. Anchoring to a rotating
reference breaks the factorization. Second, **the equivalence survives
discretization** ([D-056][d-056]). Quaternion kinematics is linear in `q`,
every RK stage composes on the right, and left multiplication by the constant
anchor commutes through. So the formulations agree to machine precision, not
merely in the continuous-time limit.

Never resetting has numerical consequences. `q` stays unit under
`x_projection`, which is better conditioned than the direct formulation's
`normalization = false` plus reset. `Θ`, `Υ` and `V` grow linearly, so
differencing loses relative precision. After an hour of flight that loss is
of order $10^{-11}\ \mathrm{m/s}$ per sample against
$10^{4}\ \mathrm{m/s}$ totals. That is six-plus orders below any error model
worth simulating.

#### The leaves in code

A few names in the code below need an introduction. `RQuat` is the domain
wrapper an attitude `SVector{4}` is cast to where rotation semantics are wanted
([§7.1][s7-1]). `Attitude.dt` gives the coning bullet's quaternion derivative, and `RVec`
turns the interval rotation `Δq` into the vector the sample carries. `IMUSample`
is the type of the sampler's `sample` output. `FrameTransform` is one of the
payload types [§7.2][s7-2] lists as walked.

```julia
struct IMUIntegrals <: AbstractComponent
    t_bc::FrameTransform
end
x_init(::IMUIntegrals) = (Θ = zeros(SVector{3}), q = SVector{4}(1.0, 0, 0, 0),
                          Υ = zeros(SVector{3}), V = zeros(SVector{3}))
u_types(::IMUIntegrals) =
    (q_eb = RQuat{Float64}, r_eb_e = SVector{3,Float64}, ω_eb_b = SVector{3,Float64},
     a_ib_b = SVector{3,Float64}, α_ib_b = SVector{3,Float64})
y_types(::IMUIntegrals) =
    (Θ = SVector{3,Float64}, q = SVector{4,Float64},            # exposed state (§5.3)
     Υ = SVector{3,Float64}, V = SVector{3,Float64},
     ω_ic_c = SVector{3,Float64}, f_c_c = SVector{3,Float64})   # instantaneous truth

# the four integrals are state, so stage 1 returns them (§5.3)
y_state(::IMUIntegrals, (; x)) = (; x.Θ, x.q, x.Υ, x.V)

# y_direct: strapdown kinematics (lever arm, gravity, Earth rate) → (; ω_ic_c, f_c_c)
function x_deriv(imu::IMUIntegrals, (; x, y))
    q = RQuat(x.q, normalization = false)              # §7.1's explicit cast
    (Θ = y.ω_ic_c, q = SVector{4}(Attitude.dt(q, y.ω_ic_c)), Υ = y.f_c_c, V = q(y.f_c_c))
end
x_projection(imu::IMUIntegrals, x) = (; x..., q = normalize(x.q))   # SVector normalize

struct IMUSampler <: AbstractComponent end
s_init(::IMUSampler) = (Θ = zeros(SVector{3}), q = SVector{4}(1.0, 0, 0, 0),
                        Υ = zeros(SVector{3}), V = zeros(SVector{3}))
u_types(::IMUSampler)  = (Θ = SVector{3,Float64}, q = SVector{4,Float64},  # discrete tier: bound check only
                         Υ = SVector{3,Float64}, V = SVector{3,Float64})
y_types(::IMUSampler) = (sample = IMUSample,)   # discrete tier: cells pin (frozen-exact)

function y_direct(smp::IMUSampler, (; s, u, Δt))
    q_s = RQuat(s.q, normalization = false);  q_u = RQuat(u.q, normalization = false)
    ϑ_c = u.Θ - s.Θ;  υ_c = u.Υ - s.Υ
    Δq  = q_s' ∘ q_u                                   # interval rotation, exact
    υ_c_sc = q_s'(u.V - s.V)                           # constant anchor change pulled out
    (; sample = IMUSample(; ω̄_ic_c = ϑ_c / Δt, f̄_c_c = υ_c / Δt,
                            ϑ_c, ϑ_c_cc = RVec(Δq)[:], υ_c, υ_c_sc))
end
s_update(smp::IMUSampler, (; u)) = (Θ = u.Θ, q = u.q, Υ = u.Υ, V = u.V)   # the latch
```

The `IMU` assembly wires the four integral ports across. It holds the error
model as a discrete sibling consuming `sample`, and it leaves the sampler at
`K = 1` (its `sample_times` entry is `Relative(1)`) in its own scope. The
parent sets the IMU's rate ([§8.7][s8-7]). `Δt` arrives in the stage
[bundle](#g-bundle) (the NamedTuple of zero-copy views a component function
receives) from its single source of truth, the deployment's `Schedule`
([§10.5][s10-5]). It is in the bundle for exactly this kind of discretized
law.

Initialization is consistent too. The sampler's `s` must equal the initial
integrals, or the `t₀` sample is wrong. That holds by default at
zeros/identity, and [boundary zero](#g-boundary-zero) discharges the rest.
Boundary zero is the initialization [boundary](#g-boundary) (a published
consistency point), run at `t₀`. There the sampler's
[due](#g-due) `s_update` (one scheduled to run at this boundary) latches
`s ← integrals(t₀)` for every subsequent sample ([D-067][d-067]). So only the
`t₀` sample itself depends on the authored `s`. That dependence is an
obligation on the author of the [condition](#g-condition) (the datum that
sets a build to a state) under trim ([§14.5][s14-5]).

The two-leaf form is *less* code than the direct formulation. It keeps the
same thirteen integral scalars and the same math, minus the reset block. It
also brings three structural gains ([D-056][d-056]).

- The sampling interface becomes visible wires, the four integral ports into
  the sampler.
- The error model becomes a discrete sibling, so the truth and corrupted
  samples, `sample` and `sample_meas`, are separately loggable.
- Linearization gets sane. Under a `Dual` activation (one at ForwardDiff's
  dual-number scalar type) the discrete tier is held ([§8.2][s8-2]).
  Integrators that never reset *are* the cumulative formulation. The framework's rules pushed the IMU into the
  only form its own linearization semantics could coherently handle.

#### Freshness at the sample

The sculling line is correct only because a due [tick](#g-tick) samples the
*completed* boundary. A tick is an instant at which a discrete component's
stages and update run. If `u.V` still held the previous boundary's decode,
it would equal `s.V` exactly, since that is the value `s_update` latched.
Sculling would then vanish without an error anywhere.

The guarantee is the boundary macro-sequence of [§10.6][s10-6], not a scheduling
accident. The sequence is integrate, [project](#g-projection), [sweep](#g-sweep) (one pass through the
execution order). Projection is the `x_projection` hook, run after integration.
The due sampler's stages are gated *into* that sweep ([§10.5][s10-5]). The integrals
arrive at stage-1 position, returned by `y_state` ([§5.3][s5-3]). They arrive before any
stage-2 function runs, regardless of topological placement.

The rest of the timeline closes consistently. The sampler's `y_direct`
decodes `s`, the `t_{k-1}` latch, *before* `s_update` runs. That is the
`z⁻¹` semantics, the one-sample delay of sampled-data control. After event
[quiescence](#g-quiescence) (the point where an event round fires
nothing), `s_update` latches the `t_k` values for the next tick.
Same-boundary events re-run the gated stages in their re-sweeps. So
`s_update` and external readers see the settled boundary.

#### The boundary-sampling contract

The clean implementation leans on the author *knowing* that "sampling at `t_k`"
means post-integration, post-projection, stage-1-fresh state. **That knowledge
must be part of the framework's taught contract**, not internal lore ([D-056][d-056]).
The semantics of [§10.5][s10-5] and [§10.6][s10-6] must be stated in component-author
documentation ([Appendix A][sA]), with this IMU as the worked example.

The failure mode of not knowing it is instructive. An author who distrusts the
sweep order adds a defensive one-tick delay or re-derives the integrals in the
sampler. Either one silently degrades the model.

**When the coupling is genuinely two-way, the latch becomes a wire back**
([D-056][d-056]). The IMU's coupling is one-directional, from integrals to
sampler. Suppose the flow itself needed the interval-relative value, say for
integrator saturation within the sampling interval. Then the sampler publishes
the sample-instant values from its *[feedthrough](#g-feedthrough)* stage (the
stage with an instantaneous input-to-output dependence). The continuous
`x_deriv` computes `x − u.latch`.

The feedthrough stage is the right one because `y_direct` reads `u`. The
latch port therefore carries the current tick's values, held by zero-order
hold (ZOH) until the next. A `y_state`-published latch would be one period
stale. Both cross-wires consume the other side's ports, and the feedthrough
graph stays acyclic. The integrals' stage 1 feeds the sampler's `y_direct`,
and the sampler's `y_direct` feeds the integrals' `x_deriv` edge
([§5.4][s5-4]). The "reset" becomes a visible tier-crossing feedback loop.
That is what it always was, physically.

A tick-triggered handler on continuous components stays the recorded escape
hatch ([§3.4][s3-4], [D-056][d-056]). It is for interval-relative dynamics
that neither factor algebraically nor tolerate the latch-back wire. No known
case needs it ([D-056][d-056]).

### 8.7 Rate scopes

An [assembly](#g-assembly) (a [component](#g-component) of pure composition) schedules its children through one
declaration, `sample_times`, its [rate scope](#g-rate-scope). This section gives its spelling and
its keys, then what it never holds and why it belongs to the type.

The declaration maps each child name to a `Relative` or `Absolute` entry, as
in this one.

```julia
sample_times(::A) = (nav = Relative(5), gnss = Absolute(Hz(10)))
```

These are the two forms that [§10.5][s10-5] defines ([D-185][d-185]). Relative entries compose
affinely down the tree, absolute entries anchor, and all are compiled to one
`(D, Φ)` pair per discrete component. [§10.5][s10-5] also holds the wrappers' definitions
and their validation. The declaration is optional, and so is any given key
([D-042][d-042]). Since an unlisted discrete child defaults to `Relative(1)` ([§10.5][s10-5]),
only multiplied, phased or anchored children need appear.

**Keys are immediate child names only** ([D-042][d-042]). A deep key would
edit another type's design from outside, and the composition rule guarantees
an author never needs to.

Container elements ([§8.5][s8-5]) are immediate children, so `"aircraft/red"` is a legal
key, and `sample_times` needs no rule change for them ([D-085][d-085]). The bare field
name is sugar that applies one uniform declaration across all elements. The
sugar keys on the *field*, not on a path segment, so a name-transparent
container keeps it unchanged. `(children = Relative(2),)` is the uniform
spelling for a `Group` ([D-300][d-300]).

A `sample_times` key on a continuous child is a build error
([D-042][d-042]). It is the declaration-time side of a run-time fact. A
continuous [bundle](#g-bundle) (the `NamedTuple` of views a component function
receives) carries no `Δt` ([§10.5][s10-5]).

`Δt_base`, `h` and `N_base` appear in no declaration. They are deployment
decisions fixed at deployment ([D-254][d-254]). [§9.2][s9-2] gives the three
sources for `Δt_base`.

The declaration belongs to the assembly type, not to the child instance
([D-042][d-042], [D-299][d-299]). The reason is that a sample time is a design ratio or a
modeled instrument's intrinsic rate ([§10.5][s10-5]), never a per-instance
value. An instance wrapper in the style of FlightCore's `Subsampled` is
rejected ([D-042][d-042]).

### 8.8 Computed connections and generic holding

`input_wires` and `output_wires` are ordinary functions evaluated at build
against the concrete instance ([D-043][d-043]). They may therefore *compute* entries from
child [contracts](#g-contract) (each child's declared interface). That is derivation from
declarations, which [§8.2][s8-2] blesses. The section covers the passthrough helpers,
the single authored feed list and [generic holding](#g-generic-holding) (a parent holding a child
through a non-concrete field type), in that order.

#### The passthrough helpers

The framework helper `input_passthrough` is sketched below. The sketch ends with
a `World` [assembly](#g-assembly), a [component](#g-component) of pure composition. It passes up the input
[faces](#g-face) (the names [ports](#g-port) wear on component boundaries) of its `aircraft` and
`atmosphere` children.

```julia
# the two shapes of `declaration_error` used below:
declaration_error(path::AbstractString, why::Symbol)      # e.g. :multiple_selectors
declaration_error(path::AbstractString, unknown, legal)   # did-you-mean against the legal set

function input_passthrough(assembly, child_path::AbstractString;
                     sep::AbstractString = ".",
                     prefix::AbstractString =               # "" → no prefixing
                         replace(child_path, "/" => sep),
                     except::Tuple = (), only::Tuple = (),  # one selector per call
                     select = nothing)                      # predicate over face names

    child = resolve(assembly, child_path)      # getfield walk along "/" segments
    names = input_faces(child)            # the leaf's u_types keys,
                                          # entries of input_wires(c) for an assembly
    given = !isempty(except) + !isempty(only) + (select !== nothing)
    given ≤ 1 ||
        declaration_error(child_path, :multiple_selectors)  # exclusivity enforced, not documented
    unknown = setdiff((except..., only...), names)
    isempty(unknown) || declaration_error(child_path, unknown, names)  # list in hand
    wanted = !isempty(only)     ? only :
             select !== nothing ? filter(select, names) :
                                  setdiff(names, except)
    # `given == 1` with an empty `wanted` is EmptyFaceSelection, a build warning
    # through §9.2's channel; a bare call over a faceless child is silent
    label(n) = isempty(prefix) ? n : string(prefix, sep, n)
    return Tuple(label(n) => string(child_path, "/", n) for n in wanted)
end

input_wires(w::World) = (
    input_passthrough(w, "aircraft"; except = ("atm", "trn"))...,   # "aircraft.pilot.throttle_axis"
    input_passthrough(w, "atmosphere"; prefix = "env", sep = "_")..., # "env_wind_N"
)

output_wires(w::World) = (
    "aircraft/pose" => "view_pose",
)
```

The child is named by path and never passed as an instance, because the `===`
problem ([§8.6][s8-6]) makes a path unrecoverable from an instance. A face
name containing dots is a legal final path segment on the internal-endpoint
side ([D-046][d-046]). That holds precisely because slash is the only structural
separator.

Computed entries mix freely with hand-written ones in either declaration
([D-043][d-043]).
`resolve` and `input_faces` are build-pipeline primitives needed anyway, and
`input_passthrough` is a thin composition. That is what keeps the helper sugar
rather than machinery. There is no `rename` hook, because the boundary
declarations are ordinary code ([D-046][d-046]). An author renames by mapping over the
pairs. Normative signatures for both primitives are in [§13.3][s13-3].

Every error stays first-class.

- An `except` face the assembly then fails to wire is an ordinary
  unconnected input.
- A face both fed by a [local wire](#g-local-wire) and passed through is a two-producers error
  ([D-145][d-145]).
- `except` or `only` naming a nonexistent face errors with the child's face
  list in hand.
- A `prefix = ""` collision is caught by the build's uniqueness check like
  any hand-written duplicate.

**The selectors are exclusive** ([D-251][d-251]). A call takes `except`,
`only` or `select`, one of the three and no more. `select` is a predicate
over the child's face names, and the helper keeps the names it accepts. More
than one selector given is `UnknownFaceSelection` with reason
`:multiple_selectors`, "more than one selector given", its payload naming the
selectors given.

**A call that gives a selector and keeps nothing raises
`EmptyFaceSelection`**, a warning on the `Build`'s list ([§9.2][s9-2],
[D-251][d-251]). A bare call over a faceless child is silent, because passing
nothing through is what it asked for. The payload names the helper, the child
path, the selector given with its names, and the child's face list.

The warning exists because an empty selection is almost always a typo the
unknown-names check cannot see. An `only` may name faces that exist while a
`select` matches none, or an `except` may list every face. It warns rather
than errors because a level may legitimately pass nothing through under one
configuration of a generic child.

`select` exists for feed lists, the idiom of "One authored feed list" below.
There the feed list already computes the `except` tuple. A closure over the same
list says the same thing without building the tuple.

The effective face list is plain printable data, the inspectable derived
contract of this instantiation. What computation does *not* do is auto-bubble
([D-043][d-043]). The author wrote down "every input face of this child that
I don't feed, I expose under this prefix", explicit at the type level and
evaluated at build.

The helpers come in pairs, because the name carries the direction
([D-171][d-171], [D-299][d-299]). `input_passthrough` reads `input_faces(child)`, and the
selector filters *face names* within that set. The helper exists for the
pass-through case, where an assembly hands a child's unfed requirements up
one level. **`output_passthrough` is its sibling** ([D-209][d-209]). It is
splatted into `output_wires`, reads `output_faces(child)`, and has the same
`prefix`/`sep` surface, the same three exclusive selectors and the same
declaration-time error set. In the block below, `Systems` is an assembly
whose children include `aero` and `ldg`.

```julia
output_wires(sys::Systems) = (
    output_passthrough(sys, "ldg"; only = ("damaged",))...,   # "ldg.damaged"
    "aero/wrench" => "wrench",
)
```

`output_passthrough`'s consumer is one-level routing ([§6.1][s6-1], [D-209][d-209], [D-299][d-299]). Every
level re-exports the outputs it surfaces, so the output side needs the
computed spelling the input side already has.

Both helpers take `child_path` naming an immediate child, container key segments
included ([D-207][d-207]). The default `prefix` folds the path's slash into `sep`, so
`"gear/1"` labels its faces `"gear.1.…"` and the default stays a legal face name for
every blessed `child_path`. An explicit `prefix` is used verbatim ([D-046][d-046]). A deeper
path meets `resolve`'s one-level rejection like any other wiring endpoint ([§13.3][s13-3],
[D-207][d-207]).

There are two helpers rather than one keyword ([D-171][d-171], [D-299][d-299]). The boundary
declarations split by direction into `input_wires` and `output_wires`, and
after that split a single call cannot emit entries into two different
declarations.

#### One authored feed list

The `World` example's two-entry `except` understates the real shape. Every
level of a realistic tree is a generic [seam](#g-seam) (a narrow, named
interface kept deliberately thin). An assembly that feeds some of a child's
input faces while passing the rest up must name the fed ones in `except`. At
the scale of Flight.jl's C172X demo, that is four seams and roughly ten names
at the innermost one. Each `except` tuple restates the wire list sitting in
the same assembly's `local_wires`. That is structure kept in two
artifacts ([D-039][d-039]), the shape this design refuses elsewhere.

**Removing the duplication needs no vocabulary** ([D-145][d-145]). Declaration
bodies are ordinary code ([§8.5][s8-5]), so the author writes the feed list
*once* and both declarations compute their share of it. In the block below,
`Systems` also holds an actuator child `act` whose output faces feed `aero`
and `ldg`.

```julia
# one authored artifact: actuator output face => destination child input face
const ACT_FEEDS = (
    "e"          => "aero/e",
    "a"          => "aero/a",
    "r"          => "aero/r",
    "brake_left" => "ldg/left.brake",
    …                                            # ~10 entries for the C172X
)

# the face names of `child` the feed list targets
fed_faces(feeds, child) = Tuple(chopprefix(dst, child * "/")
                                for (_, dst) in feeds
                                if startswith(dst, child * "/"))

local_wires(::Systems) = (
    (("act/" * src) => dst for (src, dst) in ACT_FEEDS)...,
    "aero/wrench" => "wr_sum/in1",               # non-feed wires unchanged
    …
)

input_wires(sys::Systems) = (
    input_passthrough(sys, "aero"; except = fed_faces(ACT_FEEDS, "aero"))...,
    input_passthrough(sys, "ldg";  except = fed_faces(ACT_FEEDS, "ldg"))...,
    …
)
```

Adding an actuator channel is then one edit ([D-145][d-145], [D-299][d-299]). The new pair
simultaneously creates the local wire and removes the face from the input
face surface. The two declarations cannot drift, because neither holds the
shared names. Both are projections of the authored list, so the drift class
is removed rather than detected.

Every misspelling stays loud. A mistyped destination is an unknown-face error
with the child's face list in hand, whether the wire or the `except` entry
meets it first.

One asymmetry is stated openly. A pair *omitted* from the list is not an error
but a structural change. The face leaves the `except` set and joins the input
face surface, ultimately a [root input](#g-root-input) (the root component's own input face)
for [conditions](#g-condition), the data that set a build's state, to cover ([§14.6][s14-6]). What the
idiom preserves, and the helper below surrenders, is that the feed statement
exists to be reviewed. An omission is legible in one authored artifact, not
defined away as the complement of the local wire list.

The line not to cross is deriving `except` from `local_wires` itself.
A helper spelled `except = fed(sys, "aero")`, reading the assembly's own wire
list, would cross it. That is auto-bubbling under another name
([D-043][d-043], [D-145][d-145]). **The single source must be authored data,
never inferred structure** ([D-145][d-145], [D-299][d-299]).

A feed list keeps the re-export entries of one-level routing ([§6.1][s6-1])
cheap where they multiply. Parallel routes threading many boundaries are a
different signal. They say the routes belong gathered into a component of
their own ([D-207][d-207], [D-321][d-321]).

#### Generic holding

**Generic holding is an imposed derived contract** ([D-043][d-043]). A parent holding a
child generically constrains it exactly through the faces its local wires and
interface connections reference. Build a `World` whose concrete aircraft lacks a
referenced face, and the error names the `World` entry. That is build-time
structural typing with no new vocabulary. A formal required-faces declaration on
domain abstract types remains possible sugar ([D-251][d-251]).

Scalar faces make partial scripting compose ([D-207][d-207], [D-299][d-299]). A guidance
[scenario component](#g-scenario-component) (the home of a sim-time script) wires `mode_req` and `EAS_ref`,
the equivalent-airspeed reference. The remaining faces stay exported for GUI or
defaults. That is impossible with a bundled face, under the write-side rule of
[§4.3][s4-3].

---

## 9. The build pipeline

The build consumes a root [component](#g-component) instance and produces the
runnable artifact. It consists of the declared wires and their resolution, the
[execution order](#g-execution-order), the anchor-relative rate triples and the
[root inputs](#g-root-input), plus the nominal activation's typed
[signal table](#g-signal-table) and flat state layout.
[§8][s8] states what is declared and what must hold. This chapter states *when*
each fact is checked, against what, and with which failure. The [§8.4][s8-4]
walkthroughs plus the error rules ([§6.1][s6-1]) are its acceptance tests.
Error-*reporting* policy is settled in [§13.1][s13-1], under which declarative
checking passes collect and user-code evaluation fails fast. [§9.1][s9-1]
covers the build's three steps, [§9.2][s9-2] the [`Build`](#g-build) and
[`Deployment`](#g-deployment) artifacts, [§9.3][s9-3] probing and input
synthesis, [§9.4][s9-4] [activations](#g-activation), [§9.5][s9-5] the
always-on conformance check, [§9.6][s9-6] stopped-sim services as activation
clients, [§9.7][s9-7] the compiled executor, and [§9.8][s9-8] the allocation
policy.

### 9.1 The build's three steps

This section states the build's steps, what each consumes and produces, and what
each checks. Three ordering constraints are forced by settled decisions.
[Face](#g-face) derivation is bottom-up, because an [assembly](#g-assembly)'s
interface connections evaluate against child [contracts](#g-contract)
([§8.8][s8-8]). The unconnected-input obligation check and cross-level
two-producers detection are global. They are decidable only at the root, after
every assembly's wires and faces are in hand ([§6.1][s6-1]). And stage
membership is derived by probing the stage-1 functions ([§8.2][s8-2]), so
evaluation interleaves with graph construction at exactly one
[blessed](#g-blessed) spot. The pipeline is therefore inherently heterogeneous.

**The pipeline runs as the steps below**, each consuming one artifact and
producing the next, and each a barrier ([D-259][d-259]). A step that
produced any error throws before the next begins ([§13.1][s13-1]).

| step | consumes | produces | user code it runs |
|---|---|---|---|
| the structure step | the root instance | [`Structure`](#g-structure) | declaration bodies only |
| the nominal evaluation | `Structure` | [`Outputs`](#g-outputs), [`Events`](#g-events), the nominal `Float64` [activation](#g-activation) | every user function once, at `Float64` ([§9.3][s9-3]) |
| activation at `T` | `Structure`, `Outputs`, the nominal activation, a scalar `T` | `Activation{T}` | the continuous [tier](#g-tier)'s functions at `T` |
| deployment | the `Build`, the grid parameters | [`Deployment`](#g-deployment) with its [`Schedule`](#g-schedule) | none |
| materialization | the `Deployment`, a scalar `T` | [`Model{T}`](#g-model) | none |
| the simulation | a `Model{Float64}` | `Simulation` | none |

The first three are the build, and `build(world)` runs them. The
[`Build`](#g-build) bundles their products ([§9.2][s9-2]). The last three are
the `Deployment` constructor, the `Model` constructor and the `Simulation`
constructor, all in [§9.2][s9-2].

#### The structure step

**The structure step is pure declaration reading** ([D-048][d-048]). No user
stage code executes in it ([D-259][d-259]). The `input_wires`,
`output_wires` and `input_passthrough` bodies are declaration code
([§8.8][s8-8]).

The step is a tree walk from the root instance, in this order:

1. [Components](#g-component) are collected by path.
2. Each component's [class](#g-class) (its primitive-vs-assembly status) is
   read off declaration shape ([§8.5][s8-5]).
3. Leaf contracts are collected: `u_types`, `y_types`, `*_init` values,
   `state_events`.
4. Face derivation runs bottom-up. It records at every level the input and
   output faces it declares and the chain each one routes through.
5. Global wiring resolution then runs, resolving wires to absolute leaf
   terminals.

Before a component's class is read, the walk runs the shadowing check
([§8.1][s8-1], [D-246][d-246]).

Resolution runs these checks:

- one-writer-per-input;
- the typo [did-you-mean](#g-did-you-mean) (the offending name plus the
  list-in-hand it should have matched) against the destination's input list,
  raised as `UnknownPort`;
- the two wiring type clauses ([§6.1][s6-1], [§8.2][s8-2]), stated below;
- the whole-tree (unconnected-input) obligation check;
- the store form ([§8.2][s8-2]);
- the closed leaf vocabulary ([§7.1][s7-1]).

The store form is that every `x_init`, `s_init` and `m_init` value is a
`NamedTuple`. A value that is not one is `StoreNotNamedTuple`. **The store form is checked before the tier classifier
and the vocabulary checks read the value** ([D-247][d-247]). A primitive
failing it is read no further in this step. The closed leaf vocabulary is
checked on every `x_init`, because the walk in [§8.2][s8-2] rests on it. A
leaf outside it is `IllegalStateLeaf`. `s_init` pins wholesale and answers to the isbits rule of [§7.3][s7-3] instead.
**The isbits rule is checked on `s_init` and `m_init` field by field**
([D-231][d-231]). A field that is neither isbits nor a `Symbol` is
`IllegalStoreField`.

The bound check is the first type clause, and it applies at nominal faces.
**The producer's declaration at `Float64` must be `<:` the entry at
`Float64`** ([D-078][d-078]). Equality is the concrete degenerate case.
Abstract-at-root is detected here ([D-236][d-236]).

The walk-compatibility clause is the second, and it applies to continuous
consumers only. **The walk-compatibility clause is decided by retyping both
declarations at a marker scalar** and comparing per leaf at a concrete entry,
or on the whole declaration at an abstract one ([D-263][d-263],
[D-236][d-236]). Its diagnostic is `WalkingFaceAtFrozenEntry`. The clause
stays inside this step's charter because both sides are plain declarations
the walk retypes. Declarations are read, and no user stage code runs.

The whole-tree obligation check and cross-level two-producers detection need
the whole tree ([D-048][d-048], [D-322][d-322]). Within a single assembly
declaration an unfed child input is simply *awaiting a wire from above*,
either a local wire or an `input_wires` entry handing the obligation up one
level ([§8.6][s8-6]). `UnconnectedInput` fires at the root build for any
input whose obligation chain never terminates. A child input fed by a local
wire at its own level *and* handed up through its parent's `input_wires` is
`TwoProducers` ([D-170][d-170]).

[Root inputs](#g-root-input) fall out here too, as the root component's
input faces ([D-208][d-208], [§8.2][s8-2]).

The step also checks the declaration-completeness rules ([§8.2][s8-2]):

- a store without its update;
- a leaf declaring no store;
- an event missing a [guard](#g-guard) or handler method;
- a leaf mixing tier families;
- a stateless leaf with no output contract.

**`sample_times` validation is the structure step's too** ([D-185][d-185]). It
has two parts. The first is per-entry validity against the constraints of
[§10.5][s10-5]. They require wrapper-typed values, `K ≥ 1`, `0 ≤ Φ < K`,
`T > 0`, `0 ≤ τ < T`, and keys naming discrete or scope children. Those
violations are collected with path attribution. The second is compilation into
`(anchor, m, c)` triples. A triple carries a discrete component's divisor and
[phase](#g-phase) in the [tick](#g-tick) units of its [anchor](#g-anchor), the
exact `(T, τ)` pair an `Absolute` entry establishes.

The compilation is a fold down the tree, one rule per case
([D-186][d-186], [D-283][d-283]):

| the fold meets | the triple it produces |
|---|---|
| the root scope | `(A₀, 1, 0)`, anchor 0 being the base grid itself: `(T, τ) = (Δt_base, 0)` |
| `Relative(K, φ)` under a scope at `(a, mₛ, cₛ)` | `(a, K·mₛ, cₛ + φ·mₛ)` |
| `Absolute(q, τ)` under any scope | severs and re-seeds: a fresh anchor `Aₖ = (period(q), τ)`, its subtree continuing at `(Aₖ, 1, 0)` |

Anchor 0 is symbolic until deployment. The `Relative` case is the affine law
([§10.5][s10-5]) in anchor-tick units. The canonical residue (`c < m`) holds
within each anchor's subtree by the same induction.

Everything except binding `Δt_base`, which is deployment's, happens in the
structure step. [§9.2][s9-2] states why final divisors wait for that
binding.

**The structure step returns `Structure`** (the artifact holding everything the
instance alone fixes), and that is its whole product ([D-253][d-253]).
`Structure` carries the following:

- the component instances by path;
- the tier each one sits on;
- one row per assembly, the root included: its children in declaration
  order, each with the field that contributed it, and the wires it declares
  as producer-to-consumer pairs in declaration order;
- the root inputs;
- per component, its rate chain of `Relative`/`Absolute` links;
- for each assembly an explicit `sample_times` key names, the scope triple
  that key gives it.

Class and contracts are read off the instance on demand. `Structure` holds
no resolved table. The terminal producer of any face at any level, the
two-sided face table and each face's routing chain are functions over the
wires, computed where they are read ([D-315][d-315]). Nothing in `Structure` depends
on a scalar type.

#### The nominal evaluation

**The nominal evaluation is a function of the `Structure`**, and it returns three
artifacts, `Outputs`, `Events` and the nominal `Float64` activation
([D-253][d-253], [D-259][d-259]). It is the single evaluation-feeds-structure
step.

`Outputs` (the artifact holding the port classification and the order over
it) carries per component the stage-1 and stage-2 output names. It also
carries the [execution order](#g-execution-order) over the components.
**The [feedthrough](#g-feedthrough) graph the order is computed over is not
carried** ([D-261][d-261]). It is derived from the `Structure`'s connections
and the producers' stage-2 names wherever it is shown.

`Events` (the artifact holding the event tables) carries per component the
event names, their detection policies and the bundle names.

The nominal evaluation does its work in this order:

- [Workspace](#g-workspace) (component-declared mutable scratch arriving as
  the `ws` bundle field) is allocated at the probing scalar, `Float64`
  ([§9.3][s9-3]).
- Stage-1 [probes](#g-probe) run at `Float64`, on
  `x_init`/`s_init`/`m_init` values. They are well-founded, because the
  no-feedthrough stage takes no inputs.
- [Ports](#g-port) are classified over `y_types` alone, into two classes,
  the stage-1 names and the stage-2 remainder ([§8.3][s8-3], [D-252][d-252]).
- The feedthrough graph is built from the wires carrying stage-2 ports, and a
  topological order over it follows. [§5.5][s5-5] cycle rejection applies.
- The event declarations are read last, after the stage probes, and they
  become `Events`. A consumer of the execution order therefore never carries
  the event tables ([D-253][d-253]).

`Outputs` and `Events` are structural. They are names only, `T`-independent,
and branch-protected by the branch-shape rule plus the always-on check
([§9.5][s9-5]).

The nominal evaluation fixes the structure and the `Float64` typing at
once ([D-253][d-253], [D-259][d-259]). The nominal
activation is its product beside `Outputs` and `Events`. It
is assembled from the same probe chain, never in a separate pass. That is why
no product of this step changes across activations.

#### Activation, parametric in `T`

Activation at a scalar `T` takes the `Structure`, the `Outputs` and the
nominal activation, and completes an `Activation{T}` ([D-253][d-253],
[D-259][d-259]). The step holds everything type-shaped. It retypes the
[cells](#g-cell) and the [walked](#g-walked) state type at `T` and lays out
the [buffers](#g-buffer), as [§9.4][s9-4] details. The probe chain runs in
topological order ([§9.3][s9-3]), and observed is compared against declared.

The nominal evaluation produces the `Float64` activation at build. Every other
activation re-runs *only this step* ([§9.4][s9-4]).

### 9.2 The `Build` and `Deployment` artifacts

The build's three steps ([§9.1][s9-1]) leave their products on a
[`Build`](#g-build). Deploying a build at grid parameters leaves a second
artifact, the [`Deployment`](#g-deployment) (the scalar-free artifact the grid
parameters fix). The `Deployment` carries the [`Schedule`](#g-schedule) (the
typed per-component `(D, Φ, Δt)` tick table). A [`Model`](#g-model) (the
deployment and its executor at one scalar) then materializes a `Deployment` at
a scalar type, and a `Simulation` runs a `Model{Float64}`. This section states
what each artifact holds, how a `Deployment` binds, how each artifact prints,
how a `Deployment` explains its grid, and where the warnings raised on the way
live.

#### The `Build`

**`build(world) → Build` is a standalone entry point** ([D-049][d-049]). CI
checks a component tree by calling `build`, the acceptance tests target `build`
errors directly, and `attach!` validates [device](#g-device) [bindings](#g-binding) against the `Build`.
Build living only inside the `Simulation` constructor was rejected.

**A `Build` is structure, outputs, events, the [activations](#g-activation)
and `warnings`** ([D-253][d-253]). The first three are the products of
the structure step and the nominal evaluation ([§9.1][s9-1]).

**Deploying and materializing are two steps**, with three sugar forms over
them ([D-254][d-254]). The `Deployment` constructor (below) is the first step.
The `Model` constructor is the materialization step, and the `Simulation`
constructor runs its product. The three sugar forms are `Simulation`'s:

```julia
Model(deployment, T)          # materializes a deployment at a scalar type
Simulation(model)             # runs a Model{Float64}
Simulation(deployment; kw...) # materializes a Float64 model and runs it
Simulation(build; kw...)      # composes the steps through a Float64 model
Simulation(world; kw...)      # calls build first
```

**A `Simulation` runs a `Model{Float64}` and nothing else** ([D-317][d-317]). The
nominal activation is the only one that runs in real time ([§9.4][s9-4]), so the
constraint sits as a type on the one constructor that owns a loop. A `Model`
at another scalar is a service's scratch, written to, evaluated and stepped
frame by frame with no ticks and no events.

**A `Simulation` claims its `Model`** ([D-318][d-318]). The constructor claims the
model once, and refuses as `ArgumentInvalid` a model already claimed by a
simulation or one whose status is not `:built`, before anything is
allocated. A simulation never shares its model, and its entry points are the
only way in: on a claimed model a direct call of `init!`, `frame!`, `apply!` or
the restore door is refused as `ArgumentInvalid`, and a state prepared on a
standalone model enters a simulation through a restore door, never through
the constructor.

The artifact deployed is the very build that CI checked, that an acceptance
test targeted, and that a [face](#g-face)-route table was printed from, never
an assumed-equal reconstruction. Computed interface-connection bodies are
ordinary user code re-evaluated on every build, so equality between two builds
of the same world is an assumption the factorization removes.

The `Build` is immutable apart from its lazily filled activation dictionary,
and may back any number of `Deployment`s and `Simulation`s, concurrently
([D-282][d-282]). Insertion into that dictionary is torn-state-free.
[§9.4][s9-4] states the ownership rule, the keying and the guarantee.

The `Build` is the inspectable derived contract of the instantiation that
[§8.8][s8-8] gestures at. Its parts hold the wire list, per assembly and as
declared, the [root inputs](#g-root-input) and the
[execution order](#g-execution-order) as plain printable data. The first two
sit on [`Structure`](#g-structure) (the structure step's product, the
components, wires and tiers). The last
sits on [`Outputs`](#g-outputs) (the nominal evaluation's product, the port
classes and the execution order). "Printable" names the representation. Paths,
names and rationals are inspectable as fields, and any REPL prints them
without a method of their own. That is the diagnostic form, set against the
compiled form ([§9.7][s9-7]).

An [artifact](#g-artifact) holds declared facts, and a consumer compiles
what it needs from them once, at one home ([D-261][d-261]). The
activation's cell layout is that home for address facts. A compiled form
stored beside its declared one is a second home, with no enforcer but the
constructor that filled both.

**The face table is two-sided, and `Structure` answers it as a function
over the declared wires** ([D-207][d-207], [D-315][d-315]). For every input face at
every level, the resolution runs producer-ward to the one feed its consumers
share, either a root input or a producer inside the model. For every output
face it runs down to the producing terminal. The record is total, because
one-level routing gives every signal a declared face at every boundary it
crosses ([§6.1][s6-1]). No resolved table is stored on the artifact. The
activation's cell layout compiles the addresses it needs once, and every
other reader calls the function. The input side is what a
[fragment](#g-fragment)'s `u` payload resolves against from any authoring
level ([§14.2][s14-2], [§14.3][s14-3]), the port views read it ([§11.7][s11-7]),
and so does mounting ([§14.9][s14-9]).

**`Structure`'s timing tables are anchor-relative**, and the `Deployment` binds
them ([D-283][d-283]). From the structure step the artifact gains two
printable tables:

- The [anchor](#g-anchor) table holds each anchor's exact `(T, τ)` rationals
  with the declaring scope's path and key.
- The [component](#g-component) table holds the `(anchor, m, c)` triples with
  their rate chain, the `Relative`/`Absolute` chain down the tree.

The base grid `A₀` takes an anchor-table row of its own, with a dash in the
scope and key columns, because no scope declares it. Its `(T, τ)` stays
symbolic there until `Δt_base` binds. For a fully relative model the only
anchor is `A₀`, and the triples *are* the final base-[tick](#g-tick) `(D, Φ)`
pairs. When anchors exist, final divisors cannot live here. They do not exist
until `Δt_base` binds, and the same `Build` already backs many `Deployment`s
with different grid parameters.

#### The `Deployment`

**A `Deployment` is scalar-free** ([D-254][d-254]). It carries everything the
grid parameters fix. Its constructor sits after the build's three steps,
and nothing in them depends on it. The constructor consumes the `Build` and
the grid parameters. It binds the grid parameters, the algorithm and the three
event parameters, runs harmonic-grid validation, and builds the `Schedule`. The
`Deployment` it returns holds the build, the grid parameters, the algorithm,
the three event parameters, the `Schedule`, the grid diagnostics below and its
own `warnings`. `Model` materializes it at a scalar type `T` that is
`Float64` or a `ForwardDiff.Dual`, and `Simulation` runs a `Model{Float64}`.
**`Model` refuses any other scalar** as `ArgumentInvalid`, before it derives
the activation at `T` ([§9.5][s9-5], [D-320][d-320]). Two
`Deployment`s compare as values, which is what replay's header check reads
([§12.7][s12-7]).

**`Δt_base` has exactly one of three sources**, cross-validated
([D-283][d-283]):

- the explicit keyword, a `Rational`, `Period` or `Hz` value, from which
  `N_base` is derived as `Δt_base/h` and validated an integer ≥ 1;
- the `N_base·h` product when only `N_base` is given, with the
  default `N_base = 1`;
- derivation, permitted only when every discrete component is anchored, that
  is, with anchor 0 unpopulated.

Derivation is requested explicitly:

```julia
Δt_base = :derive
```

It is never entered by default, so the `N_base·h` path stays what silence
means.

**If any unanchored component exists, deployment must declare `Δt_base`**
([D-283][d-283]). The refusal is constructive, carrying the suggestion message
of the grid diagnostics below. Under the anchored-only restriction, `Δt_base`
is pure bookkeeping that no component's period depends on. An unanchored
component's period is `m·Δt_base`. Deriving with one present would let an
anchor edit anywhere in the tree silently rescale it, which is action at a
distance.

Admissibility is exact GCD arithmetic over the constraint pool:

| quantity | value |
|---|---|
| the constraint pool | every anchor's period and every nonzero anchor offset `τ` |
| an admissible `Δt_base` | one dividing every pool entry, equivalently one dividing `gcd(pool)` |
| the admissible set | `gcd(pool)/k`, for integer `k ≥ 1` |
| the derived `Δt_base` | `gcd(pool)` itself, the coarsest admissible value |
| per anchor `k` | `Dₖ = Tₖ/Δt_base`, `Φₖ = τₖ/Δt_base` |
| per component | `D = m·Dₖ`, `Φ = Φₖ + c·Dₖ`, `Δt = D·Δt_base` |

Resolution is therefore one division pair per anchor and one multiply-add per
component. `Dₖ` and `Φₖ` must both come out exact integers. Otherwise the
result is a `DeploymentInvalid`, naming the anchor with its declaring scope
and key from the rate-chain column. The per-component triples are the
content of the `Schedule`, which the constructor builds and the `Deployment`
carries.

**Deployment validation is collected like its declarative siblings**
([§13.1][s13-1], [D-229][d-229]). Violations are collected and reported as
`DeploymentInvalid` ([Appendix C][sC]), carrying parameter, value and the
violated constraint:

- a nonpositive `h`;
- an `N_base < 1`;
- a harmonic-grid violation;
- a non-dividing anchor period or offset;
- a declared `Δt_base` disagreeing with a declared `N_base`;
- an algorithm the [stepper seam](#g-seam) does not know;
- a nonpositive `localization_tol`;
- a `localization_budget` or a `firing_budget` that is not an integer ≥ 1.

Every check whose premise holds runs, and the constructor throws once.

The event parameters validate on their own terms only. They are
grid-independent, so they take no part in the harmonic-grid check
([§10.4][s10-4], [§10.6][s10-6]).

The `Schedule` lives on the `Deployment` ([D-254][d-254]). The constructor
builds it from the structure's triples and anchors. It is typed.
It has one row per discrete component, carrying `(D, Φ, Δt)` with the anchor
and rate-chain columns. It also has the rate-scope rows, each with its own
`(Dₛ, Φₛ)`. The per-component `(D, Φ, Δt)` the executor compiles over are
derived from the rows at `compile`, never stored beside them
([D-261][d-261]). The `Schedule` is the single source of truth for `Δt`
([§10.5][s10-5]). It is also the substrate of the grid diagnostics below, and
the table that answers "when does what run, and what coincides with what".

The example worked in [§10.5][s10-5] has three discrete components under two
scopes, and that section's code block gives their `sample_times`. The root holds
a flight-control scope `fcs` and a discrete GNSS component `gnss`, declared as
`fcs = Relative(1)` and `gnss = Absolute(Hz(50))`. Deploy
it at `Δt_base = 2 ms`. The `Absolute` entry seeds the anchor
`A₁ = (1//50, 0)`, and the rest of the tree stays on anchor 0. So the three
components carry these values through binding:

| | `inner` | `outer` | `gnss` |
|---|---|---|---|
| declaration | `Relative(1)` under `fcs` | `Relative(5, 2)` under `fcs` | `Absolute(Hz(50))` at the root |
| anchor | `A₀` | `A₀` | `A₁` |
| triple `(m, c)` | `(1, 0)` | `(5, 2)` | `(1, 0)` |
| bound `(D, Φ)` | `(1, 0)` | `(5, 2)` | `(10, 0)` |
| bound `Δt` | 2 ms | 10 ms | 20 ms |

`gnss` is the entry whose divisor could not exist before `Δt_base` bound. Its
divisor is `D = m·D₁`, with `D₁ = T₁/Δt_base = (1//50)/(1//500) = 10`.

#### Rendering

**Each artifact renders itself through `show`**, with no accessors
([D-257][d-257]):

- `show(::Structure)` prints the anchor table with the `A₀` row and the
  component table with the [rate-scope](#g-rate-scope) rows (an assembly's
  `sample_times` declaration against the enclosing scope). `show(::Structure)`
  derives each root face's routing chain from the declared wires and prints
  the root's routes, one line per chain ([§13.7][s13-7]).
- `show(::Outputs)` prints the execution order with each port's class.
- `show(::Events)` prints each component's event names with their policies.
- `show(::Schedule)` prints the rows and the hyperperiod chart.
- `show(::Build)` and `show(::Deployment)` print a summary and their parts.
  `show(::Build)`'s parts include the events, and a line of the feedthrough
  edges between the outputs table and the events table. The edges are derived
  from the structure's connections and the producers' stage-2 names
  ([D-261][d-261]).

A REPL user gets each table by evaluating the value.

The chart's pattern repeats with period `lcm(Dᵢ)` base ticks, and the gate
(`(tick − Φ) % D == 0`, [§9.7][s9-7]) is pure modulo arithmetic. So one
hyperperiod is the complete truth, not a sample. The chart guard is binary.
**The chart prints whole, as a tick chart over `k = 0 … lcm(Dᵢ) − 1`, when
`lcm(Dᵢ)` is at most 100 base ticks**
([D-257][d-257]). Otherwise `show` prints the hyperperiod's length and
"chart omitted".

#### Grid diagnostics

**The grid diagnostics live on the `Deployment`** and print from the pool,
exactly ([D-187][d-187], [D-254][d-254]). The refusal path's suggestion message and the
derivation path's info line share one substrate. That substrate is the
coarsest admissible `Δt_base` with the admissible set `gcd(pool)/k`, and
per-entry attribution. Attribution has two forms:

- Leave-one-out refinement factors are the first form.
  `r_p = gcd(pool ∖ p)/gcd(pool)` is an integer ≥ 1 read as "how much coarser
  the grid would be without this entry". **Every `r_p > 1` is listed** rather
  than one culprit crowned ([D-284][d-284]). That is because joint
  responsibility is the honest answer.
- Prime attribution is the second form. Each prime power of `1/Δt_base` is
  traced to the pool entries whose denominators supply it. That pinpoints what
  an edit changed.

When an offset is a driver, the message adds the nearest non-refining
alternatives, the admissible offsets on the grid the rest of the pool
supports. That turns the diagnostic into a repair.

**Blame is computed against the actual pool** ([D-284][d-284]). A
simple-fraction-of-its-period test stays authoring guidance and never becomes
the engine's.

The derivation path is the one place refinement happens silently. It always
prints the derived value with its drivers, and it carries the one advisory,
`GridUtilization` ([Appendix C][sC]). The advisory reports `min_i Dᵢ`, the
base ticks between the fastest component's ticks, as "grid is N× finer than
the fastest declared work" with the drivers named. It is information rather
than scolding, since a scope deliberately declared finer than its fastest
member to buy stagger room ([§10.5][s10-5]) legitimately inflates the metric.

#### Warnings

**A step that completes carries its warnings on the artifact**, and the entry
point logs each one once at return ([D-250][d-250]). A step that throws
renders its warnings with the collection it throws. Logging is presentation
and never a home ([§13.2][s13-2]).

A warning raised inside a declaration body has no artifact in hand. The build
binds a scoped channel around its three steps, and the helper appends to it
without knowing the build. The same helper called standalone, outside any
build, logs directly. That is how `EmptyFaceSelection` ([§8.8][s8-8]) reaches
the `Build`'s list.

The `GridUtilization` advisory is a deployment warning, so it lives on the
`Deployment`'s list and the constructor logs it once at return ([D-250][d-250]).

**`warnings(x)` is defined on `Build` and `Deployment`**, and on `Simulation` as
the concatenation of its artifacts' lists ([D-250][d-250]). It reads the
list. Warnings raised while mutating state stay in that state's status record
([§11.8][s11-8]), never here.

### 9.3 Probing and input synthesis

The build calls each user function once, as a [probe](#g-probe), to catch
malformed code early. Each call needs argument values, and not every argument
has a producer. This section covers, in order, the probe-everything scope,
probe argument sourcing and its two checks, root-input synthesis, probe
scoping, and the totality that stage code owes in return.

**The nominal evaluation probes every user function once**, at the initial
state, with real values ([D-050][d-050]). The set is the
stages, `x_deriv`, `s_update`, [guards](#g-guard), handlers and
`x_projection`. The probe checks shape and type conformance and discards the
results. All are pure, and the cost is one evaluation each.

"Fails loudly at build time where possible" ([§8.1][s8-1]) decides this. A
malformed `x_deriv` return must not wait for the first integrator step. Probes
see only the initial state's branch, so the marginal coverage is earliness,
not completeness. The always-on check ([§9.5][s9-5]) remains the completeness
backstop.

Probe arguments are sourced as follows:

- `x`/`s`/`m` come from the `x_init`, `s_init` and `m_init` declarations,
  which declare by value.
- The stage-1 hand-down, `y_x` on the continuous [tier](#g-tier) and `y_s` on
  the discrete, comes from the stage-1 probes' *returns*. That hand-down is
  every stage-1 [port](#g-port) there is ([§5.2][s5-2]).
- Wired inputs come from upstream products.

Real values are available because the stage-2 chain is probed in topological
order. So every consumer is probed against the same value it will receive at
run time.

The [bundle law](#g-bundle)'s two remaining fields ([§5.2][s5-2]) are `ws`, the
[workspace](#g-workspace), and `t`. `t` is a clock value, sourced below with
`Δt`. **`ws` comes from invoking the component's `ws_init` allocator** at the
probing scalar (`Float64` at build), before the nominal evaluation's probes
that need it ([D-115][d-115]). The allocator runs that early because it reads
only the instance and the scalar ([D-077][d-077]) and derives nothing from
layouts.

Two checks ride the same pass. The first is the return's shape. A stage
returning something other than a `NamedTuple` fails here. The second is the
dead-stage rule. **A stage returning bare `(;)` produces no ports at all, and
is `DeadStage`**, fail-fast ([D-194][d-194], [D-285][d-285]). Such a stage
computes nothing any consumer can read. The rule is the inert-component check
([§8.1][s8-1]) applied to a single stage.

Exactly one kind of terminal has no producer, the
[root inputs](#g-root-input). **The build
synthesizes their values via `probe_value(::Type)`** ([D-051][d-051]).
Framework methods cover three kinds of type:

- `Real`, with `zero(T)`;
- `Bool`, with `false`;
- enums, with their first instance.

The ultimate fallback is the zero-argument constructor `T()`. That is where
well-behaved constrained types already put their valid default. For the
rotation-quaternion type, `RQuat()` is the identity. The `@kwdef`
convention supplies such a default broadly.

`probe_value` is overridable. A type whose valid default is not reachable that
way declares its own method. That method is also the [seam](#g-seam) a
[walked](#g-walked) type uses to state a constrained default. No method is a
build error, in the didactic style. It names the [face](#g-face) and the type,
and asks for one of the two fixes. An example is "no `probe_value` for
`Ranged{Float64, -1, 1}` at face `pilot.elevator_axis` — define
`probe_value(::Type{Ranged{Float64, -1, 1}})` or a zero-argument
constructor".

Synthesis never meets an abstract type. Root inputs are concrete by the
tight-bound rule, and the root-input type is the consuming entry evaluated at
`Float64` ([§8.2][s8-2]). [Abstract entries](#g-abstract-entry) only occur on
component-fed inputs, which the probe sources from upstream products.

Physically silly values are acceptable by construction. The probe checks
types, and return types that depend on input *values* are type instabilities,
banned by the branch-shape rule ([§8.3][s8-3]). The [§4.3][s4-3] write-side
granularity rule keeps root inputs predominantly scalar, so the surface is
small.

**Probe values are strictly probe-scoped** ([D-051][d-051]). Everything the
probe writes is garbage once the build finishes. Probe values never double as
initial root-input values, because that would smuggle in the default semantics
that [D-051][d-051] rejects.

The same doctrine covers the clock. **`t` is probe-scoped `0.0`**
([D-115][d-115]). Deployment binds no clock and `t₀` post-dates even
deployment ([§14.5][s14-5]), so `t` is a fabricated value. `Δt` in seconds
does not exist until the `Deployment` constructor binds `Δt_base`, since
deployment post-dates the build. Discrete-tier probes therefore supply a
placeholder period (`1.0`) in the bundle. It is a fabricated, probe-scoped
value like `t` and like any synthesized input. The probe checks types, not
physics.

`Simulation` must not reach its first [boundary](#g-boundary) with
uninitialized root inputs. Every complete-world application, namely
`init!`, trim setup, trim commit and linearization's operating condition
under `about`, carries the pre-write `UninitializedInputs` check
([§14.6][s14-6], [D-149][d-149]).

Silly values are acceptable *because* the author is obliged to accept them.
That obligation is the author's side of the bargain. **Stage code must be
total over type-valid inputs** ([D-142][d-142]). Every probed user function
(stages, `x_deriv`, `s_update`, guards, handlers, `x_projection`) evaluates
without throwing on any input satisfying its declared types.

The domain is type-validity, not the probe's particular synthesized values.
The branch-shape rule already bans value-dependent return types. So types are
the only domain the framework can speak of, and the probe is the enforcement
moment, not the reason.

There are two consequence sites, with the same throw at both. At build it is a
`UserCodeFraming`-wrapped build failure ([§13.1][s13-1],
[§13.2][s13-2]). Its diagnostic
points at code that is "correct" on every trajectory it has ever seen. At
runtime it is a `StepError` and the run ends `errored` ([§13.4][s13-4]).
Exceptions from model code are always abnormal ([§13.5][s13-5],
[D-060][d-060]).

Three habits of shipped landing-gear code have sanctioned spellings:

- A *plausibility* check meaning "stop the run" is a
  [stop request](#g-stop-request), a published `StopFlag` port, which
  `StopRequest` spells ([§13.5][s13-5], [D-060][d-060], [D-285][d-285], [D-316][d-316]).
  A landing-gear strut model that throws on a touchdown overload is one such
  check. The request is machinery already there.
- A *self-consistency* assert, such as an author checking that their own
  contact algebra cancels a velocity component to a hard tolerance, is a
  regression test about that algebra. Its home is the test suite
  ([D-285][d-285]). It is also the most probe-fragile of the three,
  since a near-degenerate synthesized geometry can keep the cancellation
  algebraically exact while missing an absolute tolerance in floating point.
- A *defensive exhaustiveness* branch is the third habit. Examples are an
  `else error("unrecognized surface type")` over a closed enum of ground-surface
  kinds, or a friction-coefficient constructor asserting an ordering of its
  arguments (static ≥ dynamic) when that constructor runs per step inside a
  stage.

A defensive-exhaustiveness branch is not banned validation but mislocated
validation. Totality
over a closed enum means handling every instance, and an `else error` is an
admission that the function is partial. **Parameter validation belongs where
user-controlled data enters** ([D-142][d-142]). That place is the constructors
of parameter and instance values. They run before the build, where asserts are
perfectly legitimate. Parameter validation never belongs inside a stage, on
probe-fed data.

### 9.4 Activations: executable sets, laziness, caching

By default, the build types the [component](#g-component) tree only at `Float64`. Linearization
and gradient trim need the same tree at another scalar type, a `Dual`. An
[activation](#g-activation) (the build's typed products at a given scalar
type) supplies that typing. This section states what an activation re-runs,
which functions it probes, when it runs, and what the `Build` caches.

**Only the activation step re-runs for a new scalar** ([D-259][d-259]). An
activation at `T` re-runs it with a different scalar and redoes five things:

- Producer-fed [cells](#g-cell) are re-typed by *walking* the producing
  component's output declaration at `T` ([§8.2][s8-2]). A
  continuous producer's declaration follows the scalar at every unpinned leaf.
  A discrete producer's declaration is read once and pins.
- [Root-input](#g-root-input) cells are re-typed by *walking* the consuming
  `u_types` entry at `T`. [§8.2][s8-2] reads that entry permissively. An
  unpinned entry follows the activation, and a `Pinned` entry stays frozen.
- The state type derived from `x_init` is re-derived by the leaf walk
  ([§8.2][s8-2]). The table and the flat `x` [buffer](#g-buffer) are laid out
  again.
- [Workspace](#g-workspace) allocators are invoked again, a continuous
  component's at `T` and a discrete component's at `Float64`
  ([D-263][d-263]). The activation does not introduce them. Their first
  invocation precedes the nominal evaluation's [probes](#g-probe)
  ([§9.3][s9-3]). A
  [continuous component](#g-continuous-component)'s scratch carries the
  activation's scalar ([§8.2][s8-2]). Under a `Dual` activation the in-place
  math then runs through Julia's generic fallbacks, with no BLAS. Activations
  probe and linearize, and they don't run marathons. Mistyped scratch
  detonates loudly at the `Dual` probe, since nothing downstream derives from
  a workspace's type.
- The probe chain runs again.

No [execution order](#g-execution-order) and no name list changes across
activations ([D-253][d-253]). [`Structure`](#g-structure) is the structure
step's product, and [`Outputs`](#g-outputs) is the nominal evaluation's.
Neither depends on `T`, by construction.

**Each activation probes exactly the set of functions it can execute**
([D-052][d-052]). A `Dual` activation, as linearization and gradient trim use,
evaluates the model at a frozen instant.

- Discrete stages are gated off and hold `Float64` values. This is the
  frozen-constant semantics of [§8.2][s8-2].
- [Guards](#g-guard) and handlers never run, because event localization runs
  as `Float64` [sweeps](#g-sweep) by design ([§9.5][s9-5], [D-052][d-052]).
- Only the continuous output stages (`y_state`/`y_direct`) and `x_deriv` ever
  see a `Dual`. So only they are probed at it.

Probing the discrete stages, `s_update` or the guards at `Dual` would check
code against a number type it cannot receive.

The rule has no special cases. The [§13.8][s13-8] tracer activation follows it
identically. "Tracer activation" names the *global* set-tracer
([D-012][d-012]). It is a whole-model run at the tracer scalar, an activation
like any other. The cycle classifier ([§13.8][s13-8]) is the other tracer
variant ([D-012][d-012]). It traces each member of a cycle locally and needs
no execution order. It runs in the nominal evaluation's failure path and is
not an activation at all.

**Non-nominal activations run at first request**, not at build
([D-052][d-052]). Their dominant cost is compiling the continuous chain a
second time, at `Dual`, and for interactive use, such as flying the model by
hand, that cost is pure waste.

Laziness has a price, and the spec states it openly. A successful `build` does
not certify that the model is linearizable. A [pinned](#g-walked) `Float64`
([§7.2][s7-2]) can appear in two places. It may hide in a constructor. Or it
may be declared `Pinned` at a leaf that really participates, which is the
misplaced pin of [§8.2][s8-2]. Either one lurks until the first `Dual`
activation. The probe then fails and names the offending constructor or leaf.

Instead, the repository's test suite makes linearizability an invariant, held
by policy rather than advice. **Every component gets a `Dual` activation built
in CI** ([D-280][d-280]). An opt-in exhaustive mode does it:

```julia
build(world; activations = (Float64, ProbeDual))
```

This call runs the exhaustive set. It catches both genericity violations and
misplaced pins at PR time, at the cost of one activation per component. **The
keyword is the whole entry point**, and no separate check function exists
([D-275][d-275]).

The same keyword is also recommended for the parallel-sweep idiom
([§11.1][s11-1]). Pre-materialize the activations the sweep will need. The
shared `Build` is then a fully immutable artifact, with no synchronization on
any path.

**[`ProbeDual`](#g-probedual) is the framework's public canonical probe
scalar** ([D-099][d-099]).

```julia
const ProbeDual = ForwardDiff.Dual{ProbeTag, Float64, 1}
```

It exists because an activation is keyed by a *concrete* scalar type. The bare
`Dual` is a `UnionAll`. It cannot key an activation, be walked
to, or answer `zero(T)`. The width of `ProbeDual` is arbitrary. CI pins
genericity, not any particular Jacobian. So one canonical width suffices, even
though [§14.10][s14-10] chunks at whatever widths it needs.

**The activation cache lives on the `Build` and holds only immutable compiled
artifacts** ([D-135][d-135]). It lives there because an activation is a pure
function of the build and the concrete scalar type. The cache is one
activation dictionary, keyed by concrete scalar type. Each entry holds
layouts, compiled plans and a validated flag. An entry is immutable once
constructed, and so it is freely shareable. The nominal `Float64` entry is one
key in the activation dictionary like any other ([D-253][d-253]). **Whether an
activation is cached never changes a result** ([D-052][d-052]).

**Every buffer set has exactly one owner** ([D-282][d-282]).

- A [`Model`](#g-model) (the deployment and its executor at one scalar) owns
  its activation's buffers. They are materialized from the cached layouts
  at construction. A `Simulation` owns its `Model{Float64}`, and the loop's
  zero-allocation stepping runs on that model's buffers ([D-317][d-317]).
- Every service invocation owns the scratch set it instantiates from those
  same layouts. [§14.8][s14-8] states this for `trim!`. It is the general rule,
  not one local to trim.

So buffers are never cached.

Julia itself caches compiled code, process-wide. The framework cache saves the
expensive part, namely probe re-runs, layout construction, and Julia's
compilation of the `Dual` chain. These savings amortize in loops that reuse an
activation. One such loop computes a gain schedule over a grid of flight
conditions, where hundreds of trim-then-linearize points pay those costs once.

The per-point allocation of a working store set does not amortize. It is
O(model size), and trivial against the solve it feeds. The zero-allocation
invariant ([§9.8][s9-8]) covers only the stepping loop, and the services were
always allocation-tolerant. Nothing numerical is ever cached.

`Dual{Tag,V,N}` carries the partial count. A different seeding width is
therefore a different scalar type. It gets a separate entry and a separate
Julia compile.

**Lazy materialization is torn-state-free** ([D-281][d-281]). Concurrent first
requests for the same activation must never expose partially populated cache
state. Torn state is excluded by contract, not by luck. The mechanism is
unspecified. A guard around insertion suffices, paid at service time and never
on the hot path. An activation is a pure function of build and scalar, so the
worst benign race is duplicated work.

### 9.5 The always-on conformance check

The [probe](#g-probe) validates each function *once*, on the initial state's
branch. The schema-authority bargain's second clause ("at first execution
otherwise", [§8.1][s8-1]) is discharged by leaving the probe's comparison
permanently in place.

#### The generated write

At the point where the [executor](#g-executor) (the compiled form of the
stage [execution order](#g-execution-order)) stores a stage return into the
table, it holds the complete expected return type at this
[activation](#g-activation). The expected type is the type of the
[cells](#g-cell) this stage writes, as the probe fixed them at this
activation. It is one concrete `NamedTuple` type per
([component](#g-component), stage), the stage's declared names at the types
their cells hold ([§8.2][s8-2]). **The write is generated over that type and
the return's type** ([D-235][d-235]). So the test is decided when the write's
method is specialized, and no per-field instruction reaches the conformant
path.

When the write's method is generated, the return's key set is compared with the
expected type's. At the same point, each returned field is held to its cell's
type under the relation below. A conformant return type generates the straight
stores and nothing else. A non-conformant one generates a throw of the failure
payload, raised the first time that branch executes.

How the stage's code is typed decides what the check costs it:

- For type-stable conformant code, the compiler proves the return type, one
  method is generated, and no check instruction exists to delete.
- For branch-divergent code, each return type the stage can produce gets its
  own method, the union split the code already pays. The check is absent from
  every conformant one. The divergent branch's method is the loud located
  error at its first execution.
- Type-unstable-but-conformant code pays the dynamic dispatch it already
  bought, and nothing on top.

#### Pairing by name

**The names are the pairing**, and field order carries no semantics
([D-151][d-151]). The expected type's order is an internal fact. It is derived
from `y_types`, stage-filtered, an order no single declaration shows the author.
The author never reproduces it. A return spelling the right names at the right
types conforms in any order. The following two are the same return, of a
shaft's power `P` and torque `M_shaft`.

```julia
(; P = M*ω, M_shaft = M)
(; M_shaft = M, P = M*ω)
```

This is the general rule at every `NamedTuple` [seam](#g-seam) between author
and framework. [§14.7][s14-7] states it for the trim problem's decisions and
residuals. It is also what downstream consumption already assumes. The scatter
writes each returned field into its own *named* cell ([§4.3][s4-3]).
Order-sensitivity in the check would therefore be incidental strictness rather
than protection.

Pairing by name costs nothing. The generated write reads each returned field by
name and stores it into its cell, so no permutation of the value exists at
runtime. The per-field reasoning happens on types at generation and emits no
per-field instruction, which is how the check's economics ([D-053][d-053]) hold.
The check's one baked type test is resolved by dispatch rather than executed
([D-235][d-235]). The canary ([§9.8][s9-8]) verifies empirically that the check
folds away, rather than by assertion.

What is an error is a key-set mismatch or a per-field type mismatch, reported
by the [payload](#g-payload) below. A permutation is not an error at all. That
is equally why the payload's diff never has to express one.

#### Exact match and embed-accept

At the nominal activation, the only one that ever runs in real time, **the
check is an exact type match**, with no convert-on-write ([D-053][d-053]). It
is decided at generation and absent from the conformant path ([D-235][d-235]).
The error can afford to be didactic, as in "field `M_shaft`: expected
`Float64`, got `Int64` — return `zero(x.ω)`, not `0`".

Under a non-nominal activation (the build's typed products at a given scalar
type), the two leaf kinds the declaration ([§8.2][s8-2]) distinguishes,
walking and pinned, are checked differently. An opaque leaf has a rule of its
own. **A walking leaf, one
the author left unpinned, accepts exactly two types**, the activation scalar or
`Float64` ([D-053][d-053]). The activation scalar is the fast path, the
straight store. The executor embeds a `Float64` as a zero-partial constant
(`convert` through the leaf). Struct-valued [ports](#g-port) use the standard
cross-eltype constructor, and a missing one fails loudly with both types
named.

**An opaque leaf ([§4.3][s4-3]) embeds nothing into a store**, and it is
accepted there by identity alone ([D-237][d-237]). At a wire the entry is a
bound, and a frozen opaque arrival is admitted as the producer's cell
([§8.2][s8-2], [D-264][d-264]).

Nothing else is accepted. **The check is decided on the type**, not leaf by
leaf ([D-238][d-238]). The arrival with its `Float64` positions lifted to
the scalar wherever the declaration has one must be the declaration itself.
So a field name, a non-numeric type parameter or an array's mutability that
differs is refused like any other mismatch.

A [pinned](#g-walked) leaf takes the nominal-style exact check at *every*
activation ([D-286][d-286]). A pinned leaf is one the author
wrapped as `Pinned`, or an `Int`, `Bool` or enum leaf that never walks. It takes
that check because its declaration said the leaf never carries partials. An
observed `Dual` there is the misplaced-pin error, that being the one honest
cause. The didactic hint is attached, "if `F` participates in differentiation,
remove its `Pinned`".

The embedding is exact, not lenient. Promotion is airtight and there is no
lossy `Dual → Float64` cast. So a `Float64` observed at a walking leaf means no
`Dual` entered its computation. Its true derivative along every seeded
direction is zero, which is precisely what the embedded constant says. This
scopes the blanket convert-on-write rejection to the nominal check
([D-053][d-053]). The scalars a `Model` admits, `Float64` and a
`ForwardDiff.Dual`, are this guarantee as a list, since a `Float64` embeds
into each exactly ([§9.2][s9-2], [D-320][d-320]).

#### Deliberate stripping

The bug the convert-on-write rejection guards against, silently zeroed
partials, cannot arise from honest code. The reason is that accidental
`Float64`s from `Dual` operands are impossible (`MethodError` at the operation
site). The residual is
deliberate stripping (`ForwardDiff.value`), a stated intent to discard
partials, producing a silent zero in the Jacobian. That is the stop-gradient
idiom. It is occasionally legitimate, as with deliberately frozen couplings
and opaque non-Julia wrappers. Applied mid-expression it is equally invisible
to a strict exact-match rule, so the leniency costs nothing.

But stripping need not be invisible to the schema. **The pinned leaf is
the schema-visible freeze** ([D-286][d-286]). An author who means to strip
declares the leaf `Pinned{Float64}` and strips inside the stage. The check
above holds the freeze to its word at every activation. Stripping
mid-expression at a leaf left unpinned remains legal and remains unseen, as
the sharp tool it is.

#### Per-function predicates

**The check is uniform across all probed functions** ([D-053][d-053]). Each
function is checked against its own predicate.

- **`x_deriv` checks against `X`'s own shape** at the activation's `T`
  ([D-190][d-190]). A scalar leaf expects a `T`, and an `SArray` leaf the same
  `SArray` at `T` ([§7.1][s7-1]). Its predicate is "every field scatters into
  its field's block at `T`". That predicate is what makes derivative
  completeness structural rather than a matter of author discipline.
- `s_update` checks against its leaf's `s` shape.
- Handlers check against the [§5.2][s5-2] return law, key by key.
- [Guards](#g-guard) check against their probe-derived
  [predicate](#g-predicate) form (below).
- **`x_projection` checks against `X`'s own shape** at `T`, complete
  ([D-111][d-111]). It is complete because its result is written back to the
  [buffer](#g-buffer) wholesale at both of the positions in the boundary sequence
  ([§5.3][s5-3]), and because a [projection](#g-projection) with a
  mode-dependent branch first executes its second branch at run time. That is
  the same predicate as a handler's `x` key.

#### Handler returns

**The returned NamedTuple's key set is checked first** ([D-287][d-287]). An
unknown key, or a key naming a store the component does not declare, is a
build error, `HandlerReturnKey`, with [did-you-mean](#g-did-you-mean) against
`{x, m}` narrowed to the stores that exist. That is the
[bundle law](#g-bundle)'s classification running in the return direction,
through the same `FieldError`-shaped machinery [§13.2][s13-2] builds for
bundles.

Then, per present key, `x` must be complete against the state field set,
while `m` may be partial ([D-053][d-053], [D-287][d-287]). `x` must also
be conformant at `T` like any state value. `m` is checked against a
names-subset-with-matching-types predicate, still a type-level computation
that folds when inferred. An absent key is not an error and not a no-op to
diagnose. It is the handler saying it does not touch that store.

The completeness asymmetry is storage-shaped. `x` must be complete because it
lives in a flat buffer written back wholesale. `m` may be partial because `m`
lives in per-field stores where a partial merge is the natural write.

#### Guard forms

The guard check is form-aware rather than a flat `isa Bool`
([D-053][d-053]). The reason is that guards have two admissible forms
([§2.3][s2-3]). A `Bool`-form guard's probed return is `Bool`, and a
sign-form guard's is the nominal scalar. Guards run only at the nominal
activation ([D-052][d-052]), so no parametrized-leaf case arises here. Any
other probed return type is a build error naming both admissible forms.

There is nothing further to check. The probed form *is* the detection policy
([§10.4][s10-4], [D-179][d-179]), so no form/policy mismatch can be declared.

#### The failure payload

**The payload carries the component path, the function, the event name on a
handler's occurrence, and the field-level diff** (missing / unexpected /
per-field expected-vs-observed) ([D-053][d-053], [D-249][d-249]). Simulation
time is the carrier's, not the diagnostic's. At run time the failure travels
as a [species](#g-species) of `StepError` through the single catch site
([§13.4][s13-4], [D-059][d-059]). The carrier holds the clock at the failure
and the replay pointer. A build-time occurrence has no time to carry
([D-249][d-249]).

**The source branch is deliberately absent from the payload**
([D-287][d-287]). A value does not say which branch produced it, and the diff
identifies it.

The always-on input [trace](#g-trace) makes every such failure reproducible
by [replay](#g-replay) ([D-053][d-053]). The error names the
[boundary](#g-boundary) to replay to (`to_boundary`, [§12.7][s12-7]). The
catch site adds the model's nonfinite-state check as the failure's
divergence sibling ([D-157][d-157]).

### 9.6 Stopped-sim services as activation clients

Trim and linearization are stopped-sim services, and each is a client of an
[activation](#g-activation) (the build's typed products at a given scalar type).
This section is only a sketch, kept here because it grounds the build's steps.
The services themselves are [§14][s14]. The bullets take trim, the generic
service loop and linearization in turn.

- Trim is a loop that writes a [condition](#g-condition), runs a
  [sweep](#g-sweep) and reads the result, on an activation. By default trim is
  gradient-based and runs on the `Dual` activation, with its decision
  variables seeded through the `T`-generic assignment (the user's function from
  decision variables to a condition) for exact residual Jacobians
  ([§14.7][s14-7]). The derivative-free fallback is designed and not yet
  built, and `pending.md` lists it ([D-070][d-070]). It would run the same
  loop on the nominal `Float64` activation, with no new activation needed.
  The always-on checks ride along either way. Decision variables stay opaque to
  the framework, and only the assignment's *output* is framework vocabulary.
- The generic service loop handles vectorization, optimizer setup, bounds
  packing and the solved-condition write-back, [root inputs](#g-root-input)
  included ([§14.8][s14-8]). On a simulation it takes the [trace header](#g-trace-header) after the
  write-back. A failed trim leaves the model's stores untouched ([D-070][d-070]).
- Linearization is a `Dual` activation plus seeded sweeps
  ([§14.10][s14-10]). Gather and scatter over the canonical layout replace the
  hand-written per-aircraft state-space mapping layer, so none remains
  ([§7.1][s7-1], [D-072][d-072]). Root inputs are the input surface.
  Frozen discrete outputs are constants with zero partials, which is exactly
  "linearize with the discrete state held" ([§8.2][s8-2]).

### 9.7 The compiled executor

The [execution order](#g-execution-order) exists in two representations at two
lifecycle stages. On [`Outputs`](#g-outputs) (the nominal evaluation's product,
the port classes and the execution order) it is plain printable data
([§9.2][s9-2]), namely paths, stage names and order. That data is the authoring
and diagnostic form. The [executor](#g-executor) compiles from that order
([D-253][d-253]). This section covers the other form, the one the loop runs.

#### The execution form

At `Model` construction, and per [activation](#g-activation) (the
build's typed products at a given scalar type), that data is compiled into the
execution form. **The execution form is a concretely-typed tuple of entries**
over statically typed [cell](#g-cell) storage, traversed by a
compile-time-unrolled walk ([D-086][d-086]). This is a forced move, not a
preference. The zero-allocation invariant ([§9.8][s9-8]), the fold-away
conformance test ([§9.5][s9-5]) and the zero runtime graph logic
([§5.1][s5-1]) are reachable only under full specialization. The loop runs
the execution form as a flat list of `(component, stage)` pairs
([D-086][d-086]).

An entry carries what selects code in type parameters, namely
[component](#g-component) type and stage. It carries what is plain data in
fields, namely [tick](#g-tick) divisor and [phase](#g-phase), the `Δt` of the
[bundle](#g-bundle) (the NamedTuple of zero-copy views a component function
receives), and layout offsets. Gating compiles to
`(tick − Φ) % D == 0` inside the specialized *[boundary](#g-boundary)* body,
and the interior bodies hold no discrete entries to test ([§10.5][s10-5]).

#### Cell storage

**Cells are stored per element type**, not per cell ([D-162][d-162]). The
[signal table](#g-signal-table) is one contiguous block per element type, the
construction pointed at signals rather than state ([§7.1][s7-1]). A cell
address is a build-time offset into it. The offset is carried in an entry
*field*, with the [port](#g-port) type as the address's own parameter.
Gathers reconstruct and scatters flatten through the same leaf walk, so the
closed vocabulary earns its keep twice. This is the entry rule above paying
off. Two instances of one component type then differ only in field values,
share an entry type, and compile to *one* body.
By contrast, a store enumerating every cell in its own type, addressed by
index in the type domain, compiles one body per instance. It also grows the
store type with the model. The choice was measured rather than argued
([D-162][d-162], `prototypes/cellstore_bench`).

An opaque leaf ([§4.3][s4-3]), such as a field handle, is stored whole in its
element type's block, references included. Julia keeps an immutable struct
with reference fields inline in an array, so its gather and its scatter are
one load and one store ([D-237][d-237]). A handle is therefore rebuilt per
evaluation without allocation, as an immutable struct holding existing
references. It is never a `Ref`, whose mutable box allocates.

#### Phase bodies, arities and seams

**[Phase bodies](#g-measurement-seam) are the outer decomposition**, and they
are semantically forced ([D-288][d-288]). The blocks are as follows.

- The [boundary sweep](#g-sweep)'s stage-1 block, both tiers' `y_state`
  entries alike, is order-free by definition, because the
  no-[feedthrough](#g-feedthrough) stage reads no `u`.
- The stage-2 block gates in the [due](#g-due) discrete stages, those whose
  components this boundary admits by their compiled `(D, Φ)` pair. It is the
  only topologically ordered one.
- The `x_deriv` block is `rhs`, the [RHS](#g-flow) body the stepper calls per
  stage evaluation. The `s_update` block is `ticks`. Both are order-free with
  disjoint writes.
- [Guards](#g-guard) and handlers are their own small callables inside the
  [§10.6][s10-6] iteration.

**Each sweep block compiles in two arities** off one entry list
([D-147][d-147]). The arities follow the interior/boundary split that
[§10.5][s10-5] fixes.

- The zero-arg `sweep_1()`/`sweep_2()` are the interior variants, over
  continuous entries only. That is what makes `@ballocated(sweep_2()) == 0` a
  well-defined measurement *of the interior path*, rather than of whichever
  tick phase the simulation happens to be sitting in.
- The `sweep_1(tick)`/`sweep_2(tick)` forms are the boundary variants. They
  gate their discrete entries by `(tick − Φ) % D` against the passed tick
  index, symmetric with `ticks(tick)`.

`rhs` takes no index. One gate serves all three tick-sensitive blocks,
because due-ness is per component, per boundary, never per stage. **At a
localized event time `t*` ([§10.4][s10-4]), the empty due set is arity
selection**, not an index trick ([D-147][d-147], [D-288][d-288]). The `t*`
iteration therefore runs the zero-arg arities, whose compiled bodies contain
no discrete entries ([§10.5][s10-5]).

**These bodies communicate only through the stores and the table**
([D-194][d-194]). No value crosses a [seam](#g-seam), whether between passes,
between the blocks of one pass, or between [chunks](#g-chunking). The seams
therefore cost nothing. A chunk barrier copies nothing either, because it
takes its chunk by reference, as the compile-cost rules below require. The
executor's decomposition stays free. Fusing a step's sweep with its
`x_deriv` block, or an event round's sweep with its guards and fired
handlers ([§10.6][s10-6]), is an optimization it may take or decline.

Two options this structure opens for free are recorded, not committed.

- The first is deterministic parallel evaluation of the order-free blocks.
  They have disjoint writes and no floating-point reductions to reorder,
  because [§6.2][s6-2] made every sum an ordered junction entry.
- The second is finer recompilation granularity. Editing a discrete
  component invalidates the boundary body, not the RHS body. That is literal
  under the two-arity split, since discrete entries exist only in the
  boundary variants.

#### Views and construction

**[Views](#g-view) are spelled rebuild-per-call** ([D-288][d-288]). Every entry
constructs its bundle at its own position. There is no framework-maintained
hoisting and therefore no cache-invalidation obligation. Hoisting belongs to the
code generator. Common-subexpression elimination (CSE) merges repeated loads
exactly where no intervening store invalidates them. That is precisely
[§7.1][s7-1]'s buffer-unchanged-within-a-sweep rule ([D-304][d-304]). An isbits
state view materializes in the caller's frame for exactly the duration of the
call, and has no existence between calls ([D-010][d-010]). Where it
materializes, in registers or on the spilled stack, is the compiler's
business. Re-materializing it is the same loads, and it is value-identical
because the value is immutable and the buffer is unchanged within a sweep.
The sweep-varying bundle
fields (`u`, `y_x`/`y_s`) are per-call by topological necessity either way.
A component's aggregate `y` is never stored as an object either. It is
reconstructed per call from cells, as register-level field loads at zero cost
for isbits ([§4.3][s4-3], [D-036][d-036]).

**Construction is type-opaque**, and only the executor
specializes ([D-288][d-288]). Entry tuples are built from untyped buffers
and splatted once. Generic tuple utilities (range indexing, long `ntuple`
closures, naive recursion) are inference traps at the entry list's length,
since a 400-entry heterogeneous tuple can send generic `getindex` inference
into combinatorial collapse. The compiled tuple's type therefore has exactly
one consumer, the unrolled walk.

#### Compile cost

**Chunking bounds the compile cost** ([D-086][d-086]). Within a large block the tuple
splits into chunks behind non-inlined, statically typed function barriers.
Inside a chunk, static dispatch, inlining, scalar replacement of the views,
check folding and zero allocation all survive, which is everything the
design relies on. At the barriers only cross-entry fusion is lost, which a
table-mediated signal flow barely had. The executor keeps the per-component
[projections](#g-projection) and the per-event guards and handlers in its
event set. **The event set's projection, guard and handler walks chunk the
same way** ([D-289][d-289]).

A chunk's type is its entries' types in order. Chunking buys two things,
the larger first. Chunks of one type share one compiled function. On 128
components of 2 types the walks compile in 23.2 s unchunked and in 2.8 s at
chunk size 16. And a function's compile cost grows faster than its entry
count. On 64 components of 64 types the walks compile in 6.4 s unchunked,
3.7 s at chunk size 16 and 2.7 s at 4.

Chunking also costs a recompilation. A topology change that shifts the
entry order changes the type of every shifted chunk, and each compiles
again. That takes 2.4 s on the 64-type model at chunk size 16, and 1.3 s
at 4.

Chunk size is the implementation's *only* representation freedom, with
fully fused and chunk-of-one as its endpoints. It converts the compile cost
from superlinear in the largest body to linear in entry count. It trades the
recompilation of shifted chunks against runtime, since chunk size 4 runs 3
to 9 % slower than 16. The default is 16.

**Every walk over an entry tuple or a chunk tuple is a generated unroll**,
one statement per element ([D-289][d-289]). A recursion on the tuple's tail
allocates at every call once the tuple passes 32 elements. On a model with
64 projecting components such a walk allocated 595 KB per boundary and made
the loop 5 times slower.

**A barrier takes its chunk by reference** ([D-289][d-289]). The executor holds one
pointer per chunk, and it holds the event set by reference too. A chunk
stored inline in the executor would be copied at every call site, with a
garbage-collector root per pointer it holds. At 128 components, `init!` and
the first `run!` cost 16.9 s per new topology with chunks stored inline, and
0.5 s with the generated unroll and the references in place. The copies
were also a fifth to a third of the loop's runtime.

**The declaration layer takes components unspecialized** ([D-289][d-289]). Code that
runs once per build takes a component, an assembly or the root unspecialized,
so it does not compile again per component type or per root type. A closure
created per component reads the instance from an unspecialized binding,
because a closure that captured a typed local would compile once per
component type. That code has no performance requirement, so specializing it
buys nothing. A component's own declaration methods still compile per type,
and so do the helpers that take a declared value such as a connection. Both
are small. `build` of 64 components of 64 new types
takes 0.86 s, against 40.5 s with the layer specialized. `build` of a new
root of 128 components over known types takes 0.08 s, against 12.1 s.

The figures below were measured in 2026-10 on Julia 1.13 and Apple
Silicon, as were those above (`docs/reports/20261001_compile_cost_reeval/`).
The components carry real arithmetic. Each figure is the minimum of three
runs, from calling `build` to the end of its first `run!`. A cold
process runs the model first in a fresh session. It runs on the package
image as it ships, or on a bare image compiled without the precompile
workload (below). A new topology follows a model of the same component
types in a warm one.

| model | situation | `-O2` | `-O0` |
|---|---|---|---|
| 10 components, 5 types | cold process | 2.7 s | 1.1 s |
| | cold process, bare image | 8.7 s | 3.6 s |
| | new topology, types known | 0.85 s | 0.34 s |
| 128 components, 2 types | cold process | 3.9 s | 1.8 s |
| | cold process, bare image | 9.8 s | 4.4 s |
| | new topology, types known | 0.96 s | 0.30 s |
| 64 components, 64 types | cold process | 7.9 s | 3.9 s |
| | cold process, bare image | 14.0 s | 6.5 s |
| | new topology, types known | 3.6 s | 2.3 s |

The bare-image rows pay about 6 s more than the workload rows at `-O2`,
and 2.5 s more at `-O0`, the same for every model: that is the generic
machinery, and the package's precompile workload carries it (below). What
a cold process still pays is its model's own compilation, namely the stage
methods of its component types, the chunks they fill and, under trim or
linearization, their `Dual` activation.
A new component type adds about 0.01 s to `build`, plus the compilation of
its own stage methods. A new topology pays for the chunks whose content
changed. The figures are the nominal activation's. A `Dual` activation
compiled in about the nominal time when it was last measured, before the
rules above were built (`docs/reports/20260930_compile_cost/report.md`,
section 4).

**Three measures mitigate what remains** ([D-289][d-289]).

- Activations are lazy ([§9.4][s9-4]), so a session that never linearizes never
  compiles `Dual`.
- The package's precompile workload bakes the generic machinery into the
  package image. A closed loop of library blocks runs through `build`,
  `Simulation`, `init!`, `step!`, `run!`, the readers, `series`,
  `checkpoint`, `restore!`, `trim!` and `linearize` while the package
  precompiles, which adds about 12 s to its precompilation, 30 MB to its
  image and 0.08 s to loading it. On that loop a cold process pays under 0.1 s, and a first
  `trim!` or `linearize` about 0.3 s and 0.1 s more. A component package's
  workload does the same for its types. That turns the time to first
  execution from a session tax into a CI artifact.
- The optimization level is a knob for an iteration session. `-O0` about
  halves what remains, for a loop 2.3 to 2.8 times slower, and the
  allocation invariant ([§9.8][s9-8]) holds. Its trajectories differ from `-O2`'s by
  round-off, so a trace recorded at one level does not replay bit for bit
  at the other.

#### The measurement seam

**The phase bodies are the [§9.8][s9-8] measurement seam**
([D-116][d-116]). The accessor
below returns the compiled bodies of the nominal activation as named
callables bound over the simulation's own buffers.

```julia
phase_bodies(sim)
```

It returns four blocks.

- `rhs`, the `x_deriv` block.
- `sweep_1`, in both arities.
- `sweep_2`, in both arities.
- `ticks`, which takes the tick index its entries gate on.

Returned with them are the per-event guards and handlers and the
per-component `x_projection` callables, keyed by the model's own roster.

**The four-body roster is fixed and total** ([D-156][d-156]). The accessor
returns all of it always, whatever the model happens to declare. A model with
no discrete components, no events or no continuous state at all still gets
every body. The empty ones are legal, compile to no-ops, and their
`@ballocated` assertion passes vacuously. That is the point, because
consumers then iterate the roster uniformly, with no existence checks and no
per-model branching in the measurement code.

The seam is diagnostic only, and it makes one promise.
**These are the bodies the loop runs**, not re-derivations ([D-116][d-116]).
That is what makes the measurement honest, and why each callable carries the
real in-loop argument types by construction. A hand-built standalone test
cannot reproduce those types. [D-116][d-116] records why per-component tests
cannot discharge the invariant.

**CI is warm-then-assert over the roster** ([D-116][d-116]). One call
compiles, then CI asserts the following.

```julia
@ballocated(body()) == 0
```

It asserts at per-body granularity, each sweep arity in its own right
([D-147][d-147]), with the interior call bare and the boundary call at a due
index. So a documented [§9.8][s9-8] tolerance loosens exactly one assertion.

**Publication is not a phase body** ([D-288][d-288]). That is the
[§9.8][s9-8] carve-out made structural. What the accessor exposes is exactly
what the invariant claims is zero. Invoking bodies in isolation mutates the
simulation's buffers outside any [frame](#g-frame) sequence (a tick entry
advances discrete state with no clock advance). It leaves them valid but
off-trajectory. A session that wants to continue meaningfully re-runs
`init!`.

### 9.8 Allocation policy: a scoped invariant

The allocation policy is not dogma ([D-014][d-014], [D-305][d-305]). Three reasons support it,
and only one is about speed. The first is GC-pause jitter control for
real-time. The second is throughput for [unattended runs](#g-unattended-run) (runs with empty
staging and no snapshot readers). The third is the canary. An unexpected
allocation is Julia's most reliable symptom of type instability. A zero
baseline therefore makes `@allocated == 0` a CI-testable invariant. That
invariant catches inference regressions at the offending commit. The section
states the invariant's scope, the policy's three budgets, and the tools for
garbage that cannot be avoided.

The zero-allocation invariant is scoped to the stepping loop, and the
stopped-sim services were always allocation-tolerant ([D-135][d-135], [D-305][d-305],
[§14.8][s14-8]). Publication is not a [phase body](#g-measurement-seam) (one of the compiled bodies the
loop runs) ([D-288][d-288], [§9.7][s9-7]). Publication's one [snapshot](#g-snapshot) (the immutable
per-boundary publication) allocation per [boundary](#g-boundary) sits with logging on the
framework side, outside what the invariant claims is zero ([§11.2][s11-2]).

The policy sets three budgets.

- The continuous hot path is per-stage evaluation, plus everything else that
  runs unconditionally per frame or boundary. Those unconditional items are
  [guards](#g-guard), evaluated every boundary whether they fire or not, and `x_projection`
  at both of its positions in the boundary sequence ([§5.3][s5-3]). **The budget is exactly
  zero, CI-enforced** at the measurement [seam](#g-seam) that `phase_bodies` exposes ([§9.7][s9-7],
  [D-014][d-014], [D-116][d-116], [D-305][d-305]).
- Periodic [ticks](#g-tick) (the instants a discrete component runs) and event handlers
  execute episodically. A tick runs when due, and a handler only on firing.
  Their allocation is zero by the [workspace](#g-workspace)-plus-snapshot idiom ([§8.2][s8-2]) and
  immutable-value returns ([D-305][d-305]). A workspace is component-declared mutable
  scratch arriving as the `ws` bundle field. The rare exception has a
  documented tolerance ([D-116][d-116]). The seam's granularity scopes the tolerance
  per body, so the tolerance never loosens the continuous assertions.
- Logging is amortized-zero. The [log](#g-log) (the retained sequence of
  published snapshots) retains the published snapshot objects themselves, by
  reference ([§11.2][s11-2], [D-137][d-137]). It keeps
  one slot per retained boundary and makes no copy. `sizehint!` to the
  retention bound makes regrowth a non-event.

  The allocation claim is about the snapshot's *fields*, not about everything
  reachable from them. A model carrying [§4.4][s4-4] [field handles](#g-field-handle) (immutable query
  objects consumers evaluate at their own arguments, such as heightmap terrain
  or wind grids) has a snapshot type with reference fields. Those fields ride as
  references to build-time-frozen data, with no copy and no per-boundary
  garbage. That is what the allocation claim asserts. The claim does not assert
  that the snapshot is `isbits`. The reference fields add no per-boundary
  allocation either way. The summarize-or-skip rule ([§11.2][s11-2]) governs what such a
  field contributes on export.

Two tools serve where garbage is unavoidable. Arena allocation, in the style of
the Julia package Bumper.jl, serves scoped temporaries. A scheduled
`GC.gc(false)` at frame boundaries moves collection out of the critical path.
Julia has no per-object freeing, so these are the honest levers.

---

# Part III — Execution

Part III specifies the running simulation. [§10][s10] owns time. It fixes
the loop the framework writes rather than delegates, the stepper seam across
which integration is delegated, the localization machinery that finds
crossing instants inside a step, the multi-rate tick lattice, the event
iteration at each boundary, and real-time pacing. [§11][s11] is the data
plane between the loop and everything outside it. Outbound it fixes snapshot
publication. Inbound it fixes root inputs, per-device staging and the drain.
Alongside both it fixes the device authoring contract and the input trace
that makes a session replayable. [§12][s12] is the orchestration around
them: the control plane, the wait primitives and thread budget, the shutdown
protocol, the five run states, and replay.

Part III assumes the execution order rather than deriving it. The boundary
sequence it dispatches is fixed in [§5.3][s5-3], the executor it dispatches through is
built in [§9.7][s9-7], and the root inputs the periphery writes into are the root
component's input [faces](#g-face) ([§8.6][s8-6]). What Part III adds is timing, concurrency and
orchestration around machinery the earlier parts already settled.

## 10. Time and execution

This chapter states how the loop runs a model through time. It takes the
execution order ([§5.3][s5-3]) and the compiled executor ([§9.7][s9-7]) as
given. [§10.1][s10-1] covers loop ownership and the loop's two units;
[§10.2][s10-2] the stepper seam; [§10.3][s10-3] signal-table consistency;
[§10.4][s10-4] localization mechanics; [§10.5][s10-5] multi-rate tick
scheduling; [§10.6][s10-6] event iteration at boundaries; and [§10.7][s10-7]
real-time pacing.

### 10.1 Loop ownership: the framework owns the simulation loop

This section defines the simulation loop's two units, lists its six activities
and states who writes the loop. The two units recur throughout the chapter,
and they mean different things.

- A [frame](#g-frame) is one grid step `[tₙ, tₙ₊₁]`. It is the unit of
  scheduling. Three things are keyed to it, namely the input
  [drain](#g-drain) (the frame-top swap that publishes staged device writes
  into the root inputs, [§11.4][s11-4]), pacer deadlines ([§10.7][s10-7]) and
  [tick](#g-tick) eligibility ([§10.5][s10-5]).
- A [boundary](#g-boundary) is a published consistency point. The boundary
  sequence ([§5.3][s5-3]) completes there, in the final form [§10.6][s10-6]
  calls the macro-sequence, and a [snapshot](#g-snapshot) (the immutable
  per-boundary publication) goes out.

Every grid point is a boundary, but not every boundary is a grid point.
`t*` is an event's crossing instant inside a step, bracketed by root-finding
([§10.4][s10-4]). **The [localized](#g-localized) event time `t*` is a
boundary but not a frame top** ([D-081][d-081]).
[Boundary zero](#g-boundary-zero) (the initialization boundary at `t₀`,
[§14.5][s14-5]) is a boundary and not a frame top either.

The loop consists of six activities. They are the boundary sequence
([§5.3][s5-3]), tick dispatch, event handling, logging, input staging, and
[pacing](#g-pacing) (waits inserted between completed frames, never altering
the boundary sequence).

**All six are framework code, unconditionally** ([D-017][d-017]). The framework
writes the loop itself. It does not assemble the loop out of callbacks
registered with a third-party solver. The reason is the step-boundary contract
(at every boundary the [§10.6][s10-6] macro-sequence completes before a snapshot
goes out). It is the central invariant of this design. Only a loop the framework
owns can enforce that contract by construction rather than by convention.
[D-017][d-017] records the rejected foreign-loop alternative.

**`OrdinaryDiffEq` is dropped as a dependency** of the new core
([D-017][d-017]).

### 10.2 The stepper seam

Loop ownership stops at one operation. That operation advances the continuous
state from `t` by `h`. **The framework delegates that operation across a
narrow internal interface**, the [stepper seam](#g-seam) ([D-017][d-017]).
The seam exists so that the integration method can be replaced without the
loop changing.

#### What the seam requires of a backend

The seam contract has four clauses.

- The backend advances by arbitrary `h`. The loop needs this anyway. It lands
  on [tick](#g-tick) [boundaries](#g-boundary), and it resumes from a
  [localized](#g-localized) event time (the crossing instant bracketed by
  root-finding over trial evaluations).
- The backend provides dense output on demand over the last completed step.
  Only event localization needs it ([§10.4][s10-4]), so the backend
  constructs it lazily.
- The backend uses one-step methods only. Event handlers reset state
  discontinuously, and a one-step method restarts from a new state for free.
  Multistep methods are excluded ([D-017][d-017]).
- The seam carries what a backend needs across a frame top through a
  checkpoint hook, empty for a single-step method. A
  [checkpoint](#g-checkpoint) is the `Model`'s state at a frame top
  ([§12.6][s12-6], [D-274][d-274]).

#### Models with no continuous state

A model with no continuous state at all is legal ([D-156][d-156]). Nothing in
[§8.2][s8-2] requires an `x` block of any component. Such a model still has
to be run.

**The seam is never entered empty** ([D-156][d-156]). The framework
short-circuits this case rather than pushing it down the seam. With an empty
`x`, the integrate step degenerates to advancing `t` to the next boundary,
and the stepper is not called. No backend ever faces a state count of
`N = 0`, and no backend contract has to say what it would do there.

The loop-ownership rule ([§10.1][s10-1]) pays off structurally here. Under a
foreign solver loop, an empty state pays a dummy-`[0.0]` tax
([D-017][d-017]). Here that tax is gone at the root. Both the
[buffer](#g-buffer) (the contiguous vector backing all continuous state) and
the step over it disappear. Everything else about such a model is ordinary.
The boundary machinery of [sweeps](#g-sweep), events and ticks runs
unchanged.

#### The first-cut backends

**The first cut ships in-house fixed-step RK4 and Heun** over the flat state
buffer ([D-017][d-017]). Together they are about a hundred lines. They are
trivially zero-allocation, so they can be audited against the CI invariant
([§9.8][s9-8]). They are also trivially `T`-generic. Genericity is not even
required of the stepper, because linearization and the
[feedthrough tracer](#g-feedthrough-tracer) (the instrument that classifies a
rejected cycle as real or artificial, [§13.8][s13-8]) drive the *sweep*, never the
integrator.

**`RK4` is the default** of the two ([D-227][d-227]). The `algorithm` keyword
selects the backend by type on the [`Deployment`](#g-deployment) (the
scalar-free artifact the grid parameters fix). Materialization at
`Model` construction binds the stepper against the state buffer, on the
executor ([Appendix B][sB], [§9.2][s9-2], [D-227][d-227]). The step `h` has
no default and is required of the caller. A domain rate is not a framework
default.

An `OrdinaryDiffEq`-backed stepper can exist later as a package extension, if
an offline study genuinely demands adaptive or stiff methods
([D-017][d-017]). It is a [guarded addition](#g-guarded-addition) (a
capability the design admits but does not build), so it is not built until
then.

#### The case for fixed-step low order

The domain argument is recorded here because it is decisive for the choice
of integration method. It makes three claims.

1. Closed-loop ticks cap the step. Every application beyond bare propagation
   runs periodic avionics (onboard flight systems), whose commands are
   zero-order-held signals. Integrating past a tick with stale commands is
   wrong, so the integrator must land on every tick boundary regardless of
   method. Adaptive and high-order methods pay off exactly when steps can
   stretch, and the execution model forbids the stretch by construction.
2. A piecewise-smooth [RHS](#g-flow) (the continuous derivative function)
   starves high order. Linearly interpolated lookup tables (C¹-kinked at
   every knot), clamps, friction blends and mode branches deny high-order
   error estimators and implicit-solver Newton iterations the smoothness they
   assume.
3. Stiffness has a remedy ladder. If a future model exceeds RK4's stability
   region at the deployed `h`, the ladder runs in order. First shrink `h`. Then
   subcycle the stepper against the tick grid. Only then reach for an implicit
   method through the `OrdinaryDiffEq` extension above. If that day comes,
   eltype genericity ([§7.2][s7-2]) supplies exact ForwardDiff Jacobians through
   the sweep for free.

The Flight.jl evidence behind these claims lives in section 5 of
`companions/flight_case_studies.md`.

### 10.3 Signal-table consistency is a boundary property

During a step, the RK stages evaluate the [interior sweep](#g-sweep) (the
sweep variant over continuous entries only, [§10.5][s10-5]) at internal stage
states ([D-147][d-147], [D-347][d-347]). Each evaluation runs the sweep and
then the flow, never an incremental `x_deriv`-only re-evaluation
([§5.3][s5-3], [D-347][d-347]). Nothing is lost by that, because implicit
solvers, linearization and trim already seed `x` and run the composite.
While the RK stages run, the [signal table](#g-signal-table) is transiently
integrator scratch. The boundary sweep in the
[§5.3][s5-3] sequence restores consistency at each accepted
[boundary](#g-boundary).

**External readers observe the signal table only at step boundaries**
([D-023][d-023], [D-293][d-293]). These readers are the GUI, logging and network output.
Mid-step contents carry no meaning. This rule binds the
[periphery](#g-periphery) (everything outside the loop that exchanges data with
it, [§11][s11]). The rule extends naturally to the boundary sequence
([§10.6][s10-6]). External readers observe the table only after the boundary
sequence completes.

### 10.4 Localization mechanics

A [guard](#g-guard)'s [predicate](#g-predicate) can cross inside an integration step, strictly between two
grid points. The framework can handle such a crossing in two ways. It can notice
the crossing at the end of the step, at grid resolution. Or it can find the
crossing instant and publish it. This section fixes which guards get which
treatment, and describes the machinery behind the second.

The [localized](#g-localized) event time `t*` is a [boundary](#g-boundary) (a
published consistency point, [§10.1][s10-1]). It is not the top of a
[frame](#g-frame) (one grid step, the unit of scheduling).

A frame in which one event localizes runs through these steps. Its boundaries
are tₙ, `t*` and tₙ₊₁.

> tₙ → integrate → arrival sweep at tₙ₊₁ → trigger → θ = 0 trial evaluation
> → bracket → root-find → t\* → remainder step → tₙ₊₁

This chain lists the order of operations. It is not a walk along the time axis.
The [arrival sweep](#g-sweep) (the sweep that closes the integration step) at
tₙ₊₁ raises the trigger, and integration then resumes from `t*`, which lies
before tₙ₊₁.

#### Detection policy

**The guard's return type declares its detection policy** ([D-179][d-179]). No
flag is involved.

- A guard returning `Bool` is [boundary-detected](#g-boundary-detected). The framework checks it for
  edges at step boundaries only and never root-finds it.
- A guard returning the nominal scalar, the continuous sign form, is localized.
  The framework brackets the crossing instant by root-finding over trial
  evaluations.

The build reads the policy off the [probe](#g-probe) it already runs ([§9.3][s9-3], nominal
[activation](#g-activation)). `StateEvent(guard, handler)` therefore carries no detection keyword
([D-179][d-179]).

Localization brackets a root, and only the sign form offers one. Because the
form is the policy, a localized `Bool` guard cannot be written at all. It needs
no diagnostic.

A localized guard becomes boundary-detected with a one-line rewrite, at no
semantic cost ([D-179][d-179]). Return the predicate `σ ≥ 0` instead of the
sign-form value `σ`. That cast is the definition of the predicate
([§2.3][s2-3]). The predicate and its edges stay the same. Only the resolution
at which they are observed changes.

**For a guard whose value within a step depends only on modes, root inputs
and held discrete outputs, boundary detection is exact** ([D-179][d-179],
[D-365][d-365]). Such a predicate is constant between boundaries. Root inputs
change only at the frame-top [drain](#g-drain) (the swap that publishes staged
device writes into the root inputs, [§11.4][s11-4]). Held discrete outputs
change only at ticks, which fall on boundaries ([§10.5][s10-5]), and `m`
changes only through handlers, at boundaries ([D-345][d-345]). The predicate
cannot cross between boundaries, so there is no interior instant for a root-finder to
find. Here the boundary is not a resolution limit. It is the crossing itself,
and localization would have nothing to do.

The exactness does not extend to every input. A guard that reads an input
fed, directly or through other components, by continuous state or by time
can cross inside a step, as a guard on its own state can ([D-365][d-365]).
Every interior sweep recomputes such an input, so boundary detection observes
its crossing at grid resolution.

A mixed predicate combines `Bool` factors with a continuous one. Take a piston
engine whose modes include `starting` and `running`. Its `starting → running`
transition fires on `ω > ω_idle && fuel_available`.

**When such a transition should localize, write it in the gate form
`(gate) ? σ : -one(σ)`** ([D-179][d-179], [D-290][d-290]). The `Bool` factors go in the branch
condition and the continuous factor in the value.

The gate idiom is sound rather than a way around the policy check. Trial
evaluations (below) vary only θ, the normalized time within the step. Modes,
root inputs and held discrete outputs stay fixed through a localization, so
gates over them are constant over the bracket ([D-365][d-365]). Restricted
to the bracket, σ is the continuous atom, and it can be
bracketed as such.

A predicate that must exclude equality is the other case the gate form
serves. A release predicate, "the input points back into the range", does
not hold at an input of exactly zero, but the sign form `-u` alone holds
there, since `-0.0 ≥ 0`. Gate on the strict comparison instead,
`u < 0 ? -u : -one(u)`. That gate reads a signal that varies within the
step, so it is not constant over the bracket, and σ jumps from `-1` to a
small positive value at the crossing. Only the sign drives the bracket, so
it still converges on the crossing, but the root-finder loses its
interpolation step and pays bisection's count on that event ([D-290][d-290]).
The `Bool` form `u < 0` is the same predicate boundary-detected, strict by
construction. `companions/limited_integrator_variants.md` works the case
that needed it, and records why the convention itself stays at `σ ≥ 0`. The
latching predicate of such a pair stays ungated on the mode. Gated on the
free mode, each handler hands the other guard a fresh edge, and the boundary
chatters until the firing budget breaks the tie, under a `FiringBudget`
warning, with the mode decided by which event runs out first ([§10.6][s10-6],
[D-181][d-181]).

#### Trial evaluations

A trial evaluation computes a guard's value at one instant θ inside the step.
At θ = 0 its state is xₙ itself. Elsewhere its state is x̂(θ), a point on the
[interpolant](#g-interpolant) (the cubic Hermite continuous extension over the last completed
step), which the localization loop below defines and builds.

**Trial evaluations run the interior sweep** ([D-147][d-147]). Guards read `y`.
Evaluating a guard at an interpolated state therefore means writing
$\hat{x}(\theta)$ into the state [buffer](#g-buffer) and running the
interior sweep. The [RHS](#g-flow) already lives under this rule
([§10.5][s10-5]), since a trial evaluation is a mid-step evaluation. Discrete
[cells](#g-cell) therefore hold their [tick](#g-tick) values (set at the last
instant their stages and update ran) through localization, and a guard reading a
sampled output sees what the controller is holding. Each trial evaluation costs
one interior sweep.

#### The trigger

A localized event triggers when its predicate was not-[holding](#g-edge-semantics) at tₙ's
[quiescence](#g-quiescence) and is holding at tₙ₊₁ ([D-082][d-082]). Quiescence is the fixed
point where a round of handlers fires nothing. The tₙ sample is the event's
[prior](#g-prior), the predicate sample stored at the previous boundary
([§10.6][s10-6]).

This is the directional edge of [§2.3][s2-3], not a bare sign change. A holding →
not-holding transition neither fires nor localizes.

**The trigger check runs against the arrival sweep at tₙ₊₁** ([D-182][d-182]).
That is the sweep that closes the integration step. So the check runs before the
due-gated boundary sweep refreshes any discrete cell. The rule that trial
evaluations run the interior sweep (above) already forces this order, because
trial evaluations must see the values the frame actually held. Stating it here
fixes the sequencing up front. Every `t*` firing precedes tₙ₊₁'s whole boundary
sequence.

#### The localization loop

The sketch below shows one localized event within one frame. Every step is
normed afterwards.

```julia
# θ = (t − tₙ)/h, and every σ(θ) is a trial evaluation: write the state, run
# the interior sweep, evaluate the guard.
σ₁ = σ(1)                              # already computed by the arrival sweep
(prior not-holding && σ₁ holding) || return    # no trigger, nothing to localize

σ₀ = σ(0)                              # the θ = 0 validation: x̂(0) = xₙ, no interpolant
σ₀ holding && return                   # epoch-caused edge: fall through to tₙ₊₁

build x̂ from (xₙ, ẋₙ, xₙ₊₁, ẋₙ₊₁)      # one sweep for ẋₙ₊₁, paid only here
lo, hi = 0, 1                          # the not-holding / holding bracket, in θ
while hi - lo > localization_tol       # relative: bracket width (hi − lo)·h vs. tol·h
    θ = next bracketed guess in (lo, hi)       # ITP, Brent or bisection
    σ(θ) holding ? (hi = θ) : (lo = θ)
end
t* = tₙ + hi·h                         # the holding endpoint of the final bracket
```

**On trigger, the first act is a trial evaluation at the left end**, the θ = 0
validation ([D-182][d-182]). Write xₙ into the state buffer, run one interior
sweep, and evaluate the guard to get σ₀. Nothing new is kept, since the stepper
already retains xₙ for the interpolant. This trial evaluation needs no
interpolant, because x̂(0) = xₙ identically. So it runs before any interpolant
cost is paid.

The evaluation serves two purposes. σ₀ is the left bracket value that
value-based root-finders need. σ₁ = σ(tₙ₊₁) is retained from the arrival
evaluation, but σ₀ had no source until now. And σ₀ tells the edge's cause apart.

That discrimination needs one term. An [input epoch](#g-input-epoch) is a maximal span of
constant root inputs, delimited by frame-top drains ([§11.4][s11-4]). Within an epoch a
guard can change only through the trajectory. At a seam between epochs it can
jump without crossing anything.

The discriminator is conclusive ([D-182][d-182], [D-290][d-290]). The root inputs, and
the inputs the sweep computes from them, are the only things that can differ
between the prior's evaluation context and this trial evaluation. `m`
changes only via handlers at boundaries, and priors are sampled at quiescence,
after the handlers. Discrete cells hold their values under zero-order hold
(ZOH), and the interior sweep excludes discrete entries ([§10.5][s10-5]).
`t = tₙ` exactly, by the indexed-grid rule below. Sweeps are deterministic. So
under the honest priors of [§10.6][s10-6], the frame-top drain is the only
possible source of disagreement.

- σ₀ not-holding means a trajectory-caused edge, a genuine in-frame crossing.
  Pay the sweep for ẋₙ₊₁, build the interpolant and root-find on the bracket
  $(t_n, \sigma_0)$/$(t_{n+1}, \sigma_1)$.
- σ₀ holding means an epoch-caused edge. The drain flipped the guard at the
  frame top. σ holds at both ends, so there is no in-frame crossing to find.

**An epoch-caused edge is discarded, not degraded** ([D-182][d-182], [D-290][d-290]). The
localization is abandoned and the event fires inside tₙ₊₁'s ordinary iteration.
Mechanically, not localizing is the action. The frame falls through, and the
boundary iteration detects and fires the event like any boundary-detected event.
This path costs one interior sweep. It never pays for ẋₙ₊₁ or an interpolant,
and it consumes no `localization_budget` (see "The localization budget" below).
It also warns nothing. Input timing is a frame fact, by the same doctrine that
forbids draining at `t*` below, and boundary detection is exact for an edge the
drain causes (above; [D-179][d-179], [D-365][d-365]). Boundary firing is therefore the correct
semantics, not a degradation. This is the left-end mirror of the `t* = tₙ₊₁`
degeneracy below.

The interpolant is the seam's dense output ([§10.2][s10-2]). It is built lazily
([D-018][d-018]). It is the cubic Hermite continuous extension
$\hat{x}(\theta)$, $\theta = (t - t_n)/h \in [0, 1]$, built from
$(x_n, \dot{x}_n, x_{n+1}, \dot{x}_{n+1})$. $\dot{x}_n$ is the step's first
stage. $\dot{x}_{n+1}$ costs one sweep, paid only on a validated trigger
([D-182][d-182], [D-290][d-290]). The θ = 0 trial evaluation comes first, so an epoch-caused
edge never pays for it. Uniform accuracy is $O(h^4)$, one order below the
discrete solution, which is the standard pairing. The event time can never be
more accurate than the interpolant, so nothing more expensive is worth running
trials against.

**Root-finding is bracketed and derivative-free** ([D-018][d-018]). ITP (the
interpolate-truncate-project method) or Brent's method are the intended
methods, and bisection is an acceptable fallback. The observed
not-holding/holding bracket is an unconditional convergence certificate. Newton
and AD (automatic differentiation) localization are rejected ([D-018][d-018]).

**Convergence is a relative bracket width** ([D-133][d-133]). Localization stops
once the bracket is narrower than `localization_tol · h`. `localization_tol` is
a constructor keyword of the [`Deployment`](#g-deployment) (the scalar-free
artifact the grid parameters fix) and defaults to `1e-6` ([D-256][d-256]). The
tolerance is relative because an absolute tolerance in `t` is not scale-free
([D-133][d-133]). The default is `1e-6` because of the interpolant's accuracy
limit, `O(h⁴)` as stated above. At practical `h`, anything tighter buys nothing,
while every trial evaluation costs a full sweep. Under ITP the bill is a handful
of trial evaluations, and around 20 in bisection's worst case.

After the event, the boundary sequence runs at `t*` (below). The interpolant is
then invalidated, because the handlers have made it wrong for `t > t*`
([D-018][d-018]). Integration resumes from `t*` with the
[remainder step](#g-remainder-step) (the integration from `t*` to the original
grid target) targeting tₙ₊₁, and the guards are re-checked on the remainder. The
re-check runs under the per-frame [localization budget](#g-chattering) (below),
with a chattering diagnostic.

Multiple events localizing in one step fire at the earliest `t*`. Ties fire at
that boundary inside the event iteration, one eligible event per component per
round in declaration order ([§10.6][s10-6], [D-154][d-154]). Later crossings
re-localize on the remainder.

Both policies share one blind spot. An even number of crossings within one step
returns the predicate to not-holding at the boundary, so no edge is observed.
Neither policy can detect this. The mitigation is a smaller step size, not more
machinery.

#### Endpoint policy and grid integrity

**The root-finder returns the holding endpoint of its final bracket**
([D-082][d-082], [D-290][d-290]). That is the smallest trial point where the predicate holds.
It follows that `t* = tₙ` is structurally impossible. It never needs clamping
away.

The argument rests on what was measured, not on what the prior reports.
Root-finding starts only after the θ = 0 validation has measured σ₀ not-holding
under the frame's own `u`. The bracket's left end is therefore not-holding by
the same kind of evidence as its right end. The returned point is thus
strictly later than the published, immutable tₙ. In the worst rounding case it
is `nextfloat(tₙ)`. This holds unconditionally, with no appeal to the prior.
It also leaves no residual epoch hole, because the case where the prior and
the frame's `u` disagree is exactly the epoch-caused edge, and that case
never reaches the root-finder ([D-182][d-182], [D-290][d-290]).

The guard also observably holds at `t*` ([D-082][d-082], [D-290][d-290]). Handlers therefore
fire in states where their own predicate holds, and the post-fire prior
records an actual observation rather than an assumption.

`t* = tₙ₊₁` exactly is legitimate ([D-082][d-082], [D-290][d-290]). It is a crossing at
the grid point, where σ(tₙ₊₁) = 0 both triggers detection and is the root. It
degenerates to the grid boundary. The localization result is discarded and
the event fires inside tₙ₊₁'s ordinary iteration. That outcome is bitwise
identical to the boundary-detected one, with one boundary, one
[snapshot](#g-snapshot) (the immutable per-boundary publication) and no
zero-length remainder.

**Grid times are indexed, never accumulated** ([D-082][d-082], [D-290][d-290]). `tₖ = t₀ + k·h`
is computed from the frame index, just as tick gating is already counter-modulo
([§10.5][s10-5]). The remainder step targets the grid point, with `h′` (the
remainder step's length) derived at use. `t*` is a float inside a frame, never
an anchor from which anything else is computed. A near-degenerate `t*` leaves a
tiny remainder step. Numerically that is harmless, since increments scale with
`h′`. The real hazard is bookkeeping, and this rule removes it.

#### The `t*` boundary

**At `t*` the full [§10.6][s10-6] event phase runs** ([D-081][d-081], [D-290][d-290]). The
sweep → guards → handlers cycle iterates to quiescence. Firing-budget
accounting is scoped to this boundary ([D-181][d-181]). The budget is fresh
again at tₙ₊₁, and again at a second `t*` on the remainder.

The settled state is then published. That means a snapshot, the
boundary-counter increment of [§12.3][s12-3] and the
[stop request](#g-stop-request) scan (the read of the `StopFlag` cells the
advance honours, [§13.5][s13-5]). A
crash localized at `t*` ends the run from that snapshot.

Two things do not happen at `t*`. Ticks are never due there
([D-147][d-147]). `t*` is off the [harmonic grid](#g-harmonic-grid) (every
discrete period an integer multiple of `Δt_base`) by construction, and
discrete cells ZOH-hold through the sweep. The due sets of [§10.5][s10-5] give
the full reason. **Staged inputs are not drained either** ([D-081][d-081], [D-290][d-290]),
for two reasons. Input timing is a frame fact, and the determinism of
[replay](#g-replay) (the ordinary loop re-driven from the trace) must not
depend on localization arithmetic.

**The `t*` publication is not separately paced** ([D-081][d-081], [D-290][d-290]). The
[pacer](#g-pacing) (which inserts waits between completed frames) paces frame
deadlines. A `t*` snapshot publishes when computed, mid-frame. Where that
lands in wall-clock time is below what pacing resolves. The invariant of
[§10.7][s10-7] is about trajectories, and those are identical either way.

Replay pointers and error messages index boundaries by the frame-entry
boundary index ([§13.4][s13-4], [D-128][d-128]) together with the recorded
`t`. Snapshots carry the trajectory's published-boundary ordinal
([§12.3][s12-3], [D-230][d-230]). The trace stays frame-indexed, since `t*`
boundaries consume no inputs.

[Projection](#g-projection) (the optional per-component hook
`x ← x_projection(x)`) reaches the boundary, not the trial evaluation. **Guard
trial evaluations run against the raw interpolated state** ([D-018][d-018]).
Authority rests with the `t*` boundary. Projection runs there, and the edge
checks of the [§10.6][s10-6] iteration read the projected state. RK-stage RHS
evaluations already run under the same rule, since they are equally
off-manifold. Sweeps must therefore tolerate near-manifold states, and they
already do. Per-trial projection is rejected ([D-018][d-018]).

If projection moves the state back across a guard, the event does not fire
and the run has published one extra boundary. That is harmless. Like any
other localization outcome, it is deterministic and pace-independent
([D-080][d-080]).

#### The localization budget

`localization_budget` is the integer count of localizations permitted within
one frame. **Its default is 8** ([D-133][d-133], [D-181][d-181]). It is the second
deployment keyword this section fixes.

A legitimate multi-event frame needs three or four localizations. Three
landing-gear struts touching down inside one step is the reference case.
Chattering needs tens. A budget of 8 therefore bounds the pathology without
ever binding on a healthy model.

**Budget exhaustion degrades; it does not throw** ([D-018][d-018]). When a
frame spends its budget, localization stops for the rest of that frame. The
remainder step completes, and any further crossings fire in the next
boundary's ordinary iteration, at boundary granularity for that frame. A
`ChatteringBudget` warning ([Appendix C][sC]) names the chattering event and
the localization count.

The degradation depends on the trajectory alone, never on wall clock. The
pace-independence guarantee ([D-080][d-080]) therefore stands, and the run
replays identically. A `StepError` ([§13.4][s13-4]) here would misclassify an
expected modeling outcome as broken machinery, which the no-throw doctrine of
[§14.8][s14-8] forbids.

#### Deployment constants

Both localization constants are deployment, not implementation.
`localization_tol` and `localization_budget` are constructor keywords of the
`Deployment`. They stand beside `h`, `N_base` and the algorithm ([§9.2][s9-2],
[Appendix B][sB], [D-256][d-256]). The constructor validates them with the third
such keyword, the `firing_budget` of [§10.6][s10-6], and failures are collected
into `DeploymentInvalid`, as [§9.2][s9-2] and [Appendix C][sC] set out. All
three are grid-independent, so none enters the harmonic-grid check
([§10.5][s10-5]).

All three are recorded ([D-133][d-133], [D-181][d-181]), because they determine
the trajectory. They ride the `Deployment` in the
[trace header](#g-trace-header) (the trace's fixed preamble, [§11.5][s11-5]).
They also join the set that replay compares up front, exactly as `h` and the
algorithm do ([§12.7][s12-7]).

Without this record, the replays-identically promise above is empty. A run
that does not record what its localizer was told to do cannot be re-driven
through the same localization outcomes.

### 10.5 Multi-rate tick scheduling

A model runs several clocks at once. The integrator advances on the continuous
step `h`. An inner control loop samples at one rate, an outer loop at another,
and a receiver at a third. Each of those must hold its outputs steady between
its own firings. For that to be well-defined, three things have to be fixed.
They are the time lattice every rate shares, the test that decides which
components run at a given [boundary](#g-boundary) (a published consistency
point), and the surface an author declares a rate on. This section fixes all
three, in that order.

#### The base grid and the gate

**Every discrete [component](#g-component)'s period is an integer multiple of a
base [tick](#g-tick) period `Δt_base`** ([D-019][d-019]). `Δt_base` is itself
an integer multiple of the continuous step, with `N_base` steps per base tick
($\Delta t_{\mathrm{base}} = N_{\mathrm{base}} \cdot h$, $N_{\mathrm{base}} \ge 1$).
That is the [harmonic grid](#g-harmonic-grid). Ticks therefore land on step
boundaries, which is the only place anything discrete ever happens.

[Frames](#g-frame) (iterations of the loop) are counted by the frame index
`k`. The frame top at `t = t₀ + k·h` is a base tick exactly when `k` is a
multiple of `N_base`. Its [tick index](#g-tick-index) is then
`tick = k ÷ N_base`. A frame top that is no base tick has no tick index, and
neither does a boundary at a localized event time `t*`
([§10.4][s10-4], [D-185][d-185], [D-288][d-288]).

However an author declares a rate, and however deeply the declaration is
nested, **the build compiles it to two integers per discrete component**
([D-185][d-185], [D-291][d-291]). The divisor `D` is the component's period in base ticks. The
[phase](#g-phase) `Φ` is its offset in base ticks. The pair is kept in the
canonical residue `0 ≤ Φ < D`, so the component's ticks fall at base-tick
indices `Φ`, `Φ + D`, `Φ + 2D`, and so on.

**A component is [due](#g-due) at a boundary when `(tick − Φ) % D == 0`**,
where `tick` is the boundary's tick index ([D-185][d-185], [D-291][d-291]). That subtraction
and remainder are the whole admission test. It costs one subtraction more than
a phase-free test would, over a lattice fixed at build time. The declaration
surface below says where a component's `(D, Φ)` comes from.

#### Zero-order hold and the two sweep variants

**A discrete component's `y_state`/`y_direct` run only at its own ticks**
([D-019][d-019]). Its [cells](#g-cell) (its entries in the
[signal table](#g-signal-table)) hold in between. This is zero-order hold
(ZOH), stated in [sweep](#g-sweep) terms. A sweep is one pass through the
[execution order](#g-execution-order). The reason for the hold is that
re-running a discrete component's stages at every boundary would un-sample a
sampled-data controller.

**Delivering that hold takes two statically distinct sweep variants, compiled
from one entry list** ([D-147][d-147]). Discreteness is a build-time fact, so
the split is static rather than a runtime test.

- The interior sweep walks continuous entries only ([D-147][d-147]). RK
  stage evaluations ([§10.3][s10-3]) and localization [guard](#g-guard) trial
  evaluations ([§10.4][s10-4]) run this variant. The ZOH therefore holds
  mid-step by construction. Discrete entries are not gated out at runtime.
  They are absent from the walk at compile time, so the hot path carries no
  gating test at all.
- **The boundary sweep walks the full list**, with discrete entries gated by
  `(tick − Φ) % D` against the boundary's tick index ([D-147][d-147]). It is
  the variant the [§10.6][s10-6] macro-sequence runs. It is not one fixed list
  either, because different boundaries run different subsets of the execution
  order.

**The split applies to both sweep blocks** ([D-147][d-147]). The discrete
[tier](#g-tier)'s `y_state` entries are absent from the interior stage-1 walk,
exactly as its `y_direct` entries are absent from the interior stage-2 walk.
The two sweep variants surface in the phase-body signatures: interior bodies
take no arguments, boundary bodies take the tick index ([§9.7][s9-7]).

#### Due sets

**The due set is computed once for the boundary and reused by every re-sweep
of its [quiescence](#g-quiescence) iteration** ([D-147][d-147]). Quiescence is
the fixed point where a round of handlers fires nothing ([§10.6][s10-6]). The
due set is a property of the boundary, not of the sweep call. That holds
because a due component is at its tick instant for the whole boundary, not for
one round of it.

Each kind of boundary has its own due set:

- At a tick frame top (every `N_base`-th frame top), the due set is every
  discrete component whose gate admits the tick index. These are the `(D, Φ)`
  pairs with `(tick − Φ) % D == 0`.
- At an off-tick frame top (a frame top with `N_base > 1` that is no base
  tick), the due set is empty. The tick counter has not advanced, so no
  component is at a tick instant.
- At a `t*` boundary, the due set is empty for the same reason. A modulo test
  against the unadvanced index would wrongly re-admit the previous tick's due
  set.
- At [boundary zero](#g-boundary-zero) (the initialization boundary, which
  runs the ordinary macro-sequence with an empty integrate), the due set is
  everything with `Φ = 0` ([D-185][d-185], [D-205][d-205], [D-291][d-291]). At tick index 0 the gate reads
  `(0 − Φ) % D == 0`. Under the canonical residue `0 ≤ Φ < D` that holds if
  and only if `Φ = 0`. Nothing implements this rule. It falls out of the
  ordinary gate. Dueness at boundary zero governs the `s_update` calls alone.
  Output stages publish due or not ([D-205][d-205]), as [§14.5][s14-5]
  specifies.

An offset component's first tick is at `Φ·Δt_base`. Until then its cells hold
its boundary-zero publication. Its output stages still run at `t₀`, as above,
evaluated from the authored world ([D-205][d-205], [§14.5][s14-5]). The
[probe](#g-probe)'s synthesized values reach no published cell. The probe is the
build's single evaluation of a user function with real values ([§9.3][s9-3]). In
a phase-free model every `Φ` is 0, so at boundary zero everything is due and the
distinction is empty.

A device that is dark until its first tick is a modeling decision. The author
spells it as a validity flag or a mode, and the framework withholds no
publication by default ([D-205][d-205]).

#### Simultaneous ticks

Several components can be due at one boundary, and settled machinery already
orders them. All due components run their output stages in topological order
within the sweep. All due `s_update` calls run after quiescence, in any order.
Each one reads the table and writes only its own `s` store. The intra-tick
ordering of a flight control system (FCS) cascade, where outer loops feed an
inner loop, is therefore a sweep property, not an update-order property.

#### Assemblies and rate scopes

**An [assembly](#g-assembly) is virtual for execution** ([D-019][d-019]). Its
children are scheduled individually, and the assembly itself never runs as a
unit. For declaration, a [rate scope](#g-rate-scope) is an assembly's
`sample_times` declaration against the enclosing scope. There are no atomic
assemblies, and no opt-in variant ([D-019][d-019]).

No coarsening is needed, because the signal table makes interleaving
semantically invisible. Consumers read cells whose freshness is guaranteed by
topological order rather than by contiguity.

#### The two declaration forms

A discrete component or sub-assembly is scheduled by a `sample_times` entry in
its enclosing assembly ([§8.7][s8-7]). **The entry declares one (period,
phase) pair in one of two unit systems**, and the wrapper type names the unit
system ([D-185][d-185]). The two forms thus declare one concept, a sample
time, in different units.

| entry | unit system | tick instants | constraints |
|---|---|---|---|
| `Relative(K, Φ = 0)` | scope ticks | every `K`-th tick of the enclosing scope, starting from its `Φ`-th | `K ≥ 1`, `0 ≤ Φ < K` |
| `Absolute(q, τ = 0)` | seconds | `t = τ + k·T`, with `T = period(q)` | `T > 0`, `0 ≤ τ < T` |

`K = 1` therefore admits no stagger ([D-185][d-185], [D-291][d-291]). Two same-rate siblings
are staggered one level down instead. Declare the scope at twice their rate,
then give them `Relative(2, 0)` and `Relative(2, 1)`.

`q` is a quantity value, `Period(1//50)` or `Hz(50)`. The two are a spelling
choice, normalized to the rational period at construction. Every period and
offset is an exact `Rational{Int}`, because grid derivation is GCD arithmetic
and ill-defined over floats. A float argument throws the teaching error naming
the exact spelling (`Period(1//50)`, or `Hz(1//2)` for 0.5 Hz).

The wrappers are the whole vocabulary ([D-185][d-185]). A bare integer or bare
quantity is a declaration error. An unlisted discrete child defaults to
`Relative(1)`. The common case therefore costs nothing, and a multiplied or
anchored child (one declared `Absolute`, below) always appears explicitly.

Validation belongs to the structure step (the build's declaration-reading
step), which collects it with path attribution ([§9.1][s9-1], [§13.1][s13-1],
[D-185][d-185]). It covers `K ≥ 1`, `0 ≤ Φ < K`, `T > 0`, `0 ≤ τ < T`, and
keys naming discrete or scope children. The constructors themselves are plain
data carriers, with no checks of their own.

#### Relative composition

Multipliers compose multiplicatively and phases affinely down the tree
([D-019][d-019], [D-185][d-185], [D-291][d-291]). Under a scope compiled to divisor and phase
`(D_s, Φ_s)` in base ticks, a child declared `Relative(K, φ)` compiles to
`D = K·D_s` and `Φ = Φ_s + φ·D_s`.

Composition preserves the canonical residue `0 ≤ Φ < D`.
`companions/sample_time_proposal.md` (the declaration design's worked companion)
carries the one-line induction. All scoping therefore compiles away at build to
one `(D, Φ)` pair per discrete component. The boundary sweep gates on that pair
with the `(tick − Φ) % D == 0` test above. The lattice stays static, and the
interior sweep still holds no discrete entries to gate.

Relative is the default form because, in a layered control architecture, the
*ratios* are intrinsic to the design and travel with the assembly type. The
inner loop runs at `Relative(1)` and the outer loops at `Relative(5)`,
whatever the deployment. One convention keeps `K ≥ 1` livable. A scope's base
rate is its fastest relative member, and that member gets `K = 1`.

Two structural properties keep a relative entry on the scope grid and confine
grid cost to the other form. **A relative phase never refines the base grid**,
because it selects among scope ticks that already exist ([D-185][d-185], [D-291][d-291]). It
also cannot place a tick *between* scope ticks. Staggering off-grid means
declaring the offset in seconds, or declaring the scope base finer than its
fastest member so that unused slots exist.

#### Anchors

**An `Absolute` entry may appear in any scope's `sample_times`, not only the
root's** ([D-186][d-186]). The `(T, τ)` pair it establishes is an
[anchor](#g-anchor), and the child hangs from that anchor. The child is
severed from the enclosing scope's grid, and no relation to the scope's ticks
remains.

Three corollaries follow ([D-186][d-186]):

- `K ≥ 1` reads "a child cannot tick faster than the scope it is *relative*
  to". An anchored child may therefore tick faster than its scope.
- The fastest-member convention counts relative members only.
- Phase relationships between an anchored child and its relative siblings are
  deployment-emergent. Whether their ticks ever coincide depends on how the
  grid derivation works out. The deployment's [`Schedule`](#g-schedule) (the
  per-component `(D, Φ, Δt)` table the `Deployment` carries) exists to answer
  that question ([§9.2][s9-2]).

Relative children *of* an anchored subtree compose against the anchor exactly
as against the root grid ([D-186][d-186], [D-283][d-283]). A nested anchor simply severs again
(the fold, [§9.1][s9-1]).

**Absolute periods and nonzero offsets jointly constrain the base grid**
([D-186][d-186], [D-283][d-283]). They join the deployment-time constraint pool
([§9.2][s9-2]). This is the subtle part, and it has a real cost. An offset of
`T/2` can cost a 2× finer grid, and `T/1000` a 1000× one. The cost is
relational, incurred against everything else declared. That is why
attribution is the engine's job ([§9.2][s9-2]).

#### When an anchor belongs in a library type

Absolute-first declaration as the default form is rejected ([D-019][d-019],
[D-186][d-186]). What mid-tree anchors legitimize is narrower, and the
doctrinal line falls here. **An absolute declaration inside a library type is
legitimate when the rate is a fact about the modeled system, not a preference
about the simulation** ([D-186][d-186], [D-291][d-291]).

A GPS receiver emitting at 1 Hz, a data bus's transmission schedule and an ADC
(analog-to-digital converter) pipeline's fixed conversion offset are as
intrinsic to the assembly as its wiring. Forcing them to the root breaks
encapsulation, since the root would have to know instrument internals to
re-declare them.

"Run the controller at 400 Hz in this study" remains a deployment choice, and
the existing idiom remains its answer. The assembly exposes its multiplier as
a constructor parameter. Absolute pinning *from outside* a subtree's
[contract](#g-contract) (its declared interface) stays rejected as action at a
distance.

The framework cannot police the distinction. It is authoring doctrine,
recorded here.

**Anchoring leaves the never-cache-`Δt` argument below fully intact**
([D-186][d-186], [D-291][d-291]). The pinning happens in the enclosing assembly's
`sample_times`, the same site where the multiplier lives. The component type
itself therefore stays rate-agnostic. It still consumes the `Δt` of its
[bundle](#g-bundle) (the NamedTuple of zero-copy views a component function
receives).

#### A worked example

This example follows one declaration to its compiled pairs and one hyperperiod
(the span after which the tick pattern repeats). Three discrete components sit
under two scopes, at a deployment that binds `Δt_base = 2 ms` ([§9.2][s9-2]).
The root scope holds `fcs`, an FCS scope, and `gnss`, a satellite-navigation
(GNSS) component.

```julia
# Root scope: (D_s, Φ_s) = (1, 0).
sample_times(::Vehicle) = (fcs  = Relative(1),        # → (D, Φ) = (1, 0)
                           gnss = Absolute(Hz(50)))   # → (10, 0), anchored at T = 20 ms

# fcs is the enclosing scope of its own children, at (D_s, Φ_s) = (1, 0).
sample_times(::FCS) = (inner = Relative(1),           # → (1, 0)
                       outer = Relative(5, 2))        # → (5, 2), D = 5·1, Φ = 0 + 2·1
```

Those pairs are what the boundary gate reads at run time. One hyperperiod is
`lcm(Dᵢ) = 10` base ticks. Because the gate is pure modulo arithmetic, that
one hyperperiod is the complete truth rather than a sample ([§9.2][s9-2]):

```
base tick k:  0  1  2  3  4  5  6  7  8  9 | 0  1  …
inner         •  •  •  •  •  •  •  •  •  • | •  •       (D, Φ) = (1, 0)
outer               •              •       |            (5, 2)
gnss          •                            | •          (10, 0)
```

`outer` is due where `(k − 2) % 5 == 0`, `gnss` where `k % 10 == 0`. Should
`outer` read a `gnss` cell, the ZOH makes that read two base ticks old at
`k = 2` and seven at `k = 7`.

#### Coincidence and stagger

Coincidence and stagger are modeling choices with observable consequences.
Coincident ticks give a consumer fresh same-instant reads via topological
order. That is the idealized synchronous-sampling picture. A phase stagger
makes the same reads pipelined and deterministically aged instead. That is the
structural expression of an acquisition pipeline's latency, obtained with no
delay blocks. The two-tick and seven-tick reads in the example above are the
deterministic aging of a stagger, in that model's numbers.

A stagger is also a load-shaping tool under real-time [pacing](#g-pacing) (waits
inserted between completed frames, never altering the boundary sequence).
Staggered stacks never share a frame, so worst-case frame cost is a `max` rather
than a sum ([§10.7][s10-7]).

Both patterns are worked in `companions/sample_time_proposal.md`, together with
how silently an offset edit rewires a coincidence structure. The `Schedule` and
its hyperperiod chart ([§9.2][s9-2]) are how a user audits which pattern a model
actually has.

#### `Δt` in the bundle

`Δt` has a single source of truth, the deployment's `Schedule`
([D-187][d-187], [D-254][d-254]). **Each discrete component's effective period
arrives read-only as the `Δt` field of every discrete-tier bundle**
([§5.2][s5-2], [D-019][d-019]). The field arrives in `y_state`, `y_direct` and
`s_update` alike. It is absent from continuous bundles, so touching it on the
wrong tier is a missing-field error rather than a rule.

The field must be readable in the *stages*, not just in `s_update`. The
discretized laws that actually consume `Δt` run in `y_direct`, which computes
each law once and publishes it ([§5.3][s5-3], [D-015][d-015]). A PID
controller's backward-difference coefficients and a lead-lag compensator's
Tustin transform are the examples. `s_update` is a copy.

The value must arrive through the call, and the bundle field is where it
arrives. A `comp.Δt` virtual property is impossible here, not merely
inconvenient ([D-019][d-019]).

An author must never store `Δt`, or any `Δt`-derived coefficient, as a
component parameter ([D-019][d-019]). Recomputing derived coefficients per
tick is a few arithmetic ops. A cached copy is a second thing for
gain-scheduling machinery to chase. The same reasoning reaches the law
itself. A discretized law is written to be stable at every period a
deployment may assign, since the component cannot know its period at
construction and no check compares the law against it ([D-019][d-019],
[D-291][d-291]).

Relative declaration structurally enforces that author rule for the period
itself. Under scoped multipliers a component author *cannot* know their
absolute rate. It does not exist until composition.

Phases change none of this. **The bundle's `Δt` is still `D·Δt_base`**
([D-185][d-185], [D-291][d-291]). An offset shifts firing instants and never the period, so
the discretized laws are unaffected by staggering.

### 10.6 Event iteration at boundaries: to quiescence, budgeted

[§5.3][s5-3] leaves two questions open. How far does the event phase run at a
[boundary](#g-boundary) (a published consistency point, where the
macro-sequence completes), and how often may each event fire while it does?
This section answers both.

**The phase iterates** ([D-020][d-020]). One round re-runs the
[boundary sweep](#g-sweep) (the pass over the full execution order, with due
discrete entries gated in), evaluates all [guards](#g-guard) (the declared
functions defining each event's predicate) against it, and fires the eligible
events. **A [component](#g-component) fires at most one event per round**
([D-154][d-154]). Each firing is `handler → x_projection`. Rounds continue to
[quiescence](#g-quiescence), the fixed point where a round of handlers fires
nothing.

**An event fires in an iteration round if and only if three conditions hold**
([D-181][d-181]):

- Its [predicate](#g-predicate) is observed holding in that round.
- The sample observed before it was not-holding.
- The event's firing count for this boundary is below `firing_budget`.

That is the whole definition of "newly fired". The predicate is the one
[§2.3][s2-3] defines, either the `Bool` form true or `σ ≥ 0`.
[`firing_budget`](#g-firing-budget) is a deployment keyword, an integer ≥ 1
defaulting to 4. It caps how many times each declared event may fire at one
boundary.

#### Why the phase iterates

Under a single pass, a cascade of N logically simultaneous transitions
(supervisor FSM → subordinate FSM → …, where an FSM is a finite-state machine)
takes N steps to complete, at latency N·h. The model's semantics would then
depend on the integrator's step size, and `h` is an execution parameter. This is
the same class of footgun for which [§2.5][s2-5] excludes an unconditional
per-step hook, such as FlightCore's `f_step!` ([D-020][d-020]). Cascades are
not a corner case either.
Externalized FSM components are blessed ([§3.1][s3-1]), which makes
cross-component cascades the expected idiom.

Established practice agrees. Hybrid automata take sequences of instantaneous
transitions at one time point. Modelica iterates events to quiescence.
Stateflow runs charts to completion within a [tick](#g-tick) (an instant at
which a discrete component's stages and update run).

Boundary-detection timing remains h-dependent, but that is a different
quantity. It is the resolution at which a physical crossing is noticed. The
cascade delay would have been structure the framework inserts between
transitions the model declares simultaneous.

#### The three registers

Three registers per event decide the rule, all named normatively.

- The [prior](#g-prior) is the previous boundary's quiescent sample. The
  boundary's first round tests against it.
- The *last-observed sample* is initialized from the prior when the boundary
  opens and overwritten by every round's evaluation. Every later round tests
  against it. There is one exception. An event that was eligible but blocked
  (below) keeps its sample, because blocking defers its edge rather than
  consuming it.
- The *firing count* for the boundary is incremented at each firing and reset
  when the boundary ends.

Eligibility inside a boundary is therefore an [edge](#g-edge-semantics) like
any other. It is a not-holding → holding transition, never a bare sign change.
What differs is the reference sample. The edge is read against the
last-observed sample, not against the prior the boundary entered with
([D-181][d-181]).

Two consequences follow. Sticky predicates need no special case. An event that
fires and keeps holding presents no further not-holding → holding edge, so it
fires once, at the boundary where it first held. And a predicate that is
genuinely falsified and re-enabled inside the boundary, because another
handler's cascade reverted its effect, fires again at this boundary against a
fresh sweep ([D-181][d-181]).

The sketch below shows one boundary's iteration.

```julia
# entering the boundary, per event:  last ← prior,  count ← 0
while the previous round fired something   # the first round always runs
    boundary sweep                         # the whole boundary sweep, due set fixed for the boundary
    per event:      eligible ← last not-holding && now holding && count < firing_budget
    per component:  firing ← its first eligible event, in declaration order
    per event:      last ← now, unless eligible and not firing   # a blocked edge stays unconsumed
    fire the firing events                 # handler → x_projection, count += 1
end                                        # the exit condition is quiescence
per event:  prior ← last                   # the settled boundary's honest sample
```

The prior is updated at each boundary's quiescence, from the final
post-iteration samples ([D-082][d-082]). The update is unconditional. Every
prior is therefore an honest observation of a settled boundary. That is what
makes the θ = 0 discriminator ([§10.4][s10-4]) conclusive.

All three registers are detection bookkeeping, not model memory. They are
correctly absent from every state store ([D-082][d-082]). A
[checkpoint](#g-checkpoint) (the `Model`'s state at a frame top as one value)
carries the prior, the one register that crosses a boundary ([§12.6][s12-6],
[D-274][d-274]). The [trace header](#g-trace-header) (the trace's fixed
preamble) is such a checkpoint. `restore!` copies a checkpoint's prior back
([D-274][d-274]). The other two registers are reset on entering each boundary,
as the sketch shows. Beyond the prior, the cost is one `Bool` and one small
counter per event.

[Boundary zero](#g-boundary-zero) is the initialization boundary. **Boundary
zero sets every prior to not-holding** ([D-082][d-082], [D-292][d-292]). A predicate already
holding in the authored state therefore fires at `t₀`. That behavior
([§14.5][s14-5]) is derived rather than asserted. A re-run from a
[condition](#g-condition) (a path-addressed overlay that sets the build to a
state, [§14.1][s14-1]) resets all three registers from scratch, because `init!`
re-runs boundary zero ([§14.5][s14-5]). Predicates holding in the newly applied
state fire again at the new `t₀`. A `restore!` keeps the checkpoint's priors and
runs no boundary zero, so nothing holding re-fires ([§12.6][s12-6],
[D-274][d-274]).

#### What a handler sees within a round

Each round re-runs the whole boundary sweep, gated entries included
([D-020][d-020]). The reason is that a transition reaches the
[signal table](#g-signal-table) (the framework-owned cells holding every
produced signal) only through a sweep. A handler writes its component's state
stores and nothing else. So neither the transitioning component's own
[ports](#g-port) (each one declared name with its cell) nor the downstream
`y_direct` chains that read them have moved. The cost is negligible. Sweeps take
microseconds, and rounds beyond the first require an actual cascade.

Within a round, the signal table has a single writer, and it is the sweep
([D-154][d-154]). A handler writes nothing to the table. It returns
transitions, the framework latches them into the component's state stores, and
`x_projection` normalizes them. Nothing moves the table mid-round.

This gives the epoch rule, which is the core of this section. An epoch here is
the world one round's sweep produces. It is not the input epoch of
[§10.4][s10-4]. **A handler executes against exactly the world its guard fired
on** ([D-154][d-154]). Its own `y`, foreign `u` and its own `x`/`m` all come
from the firing round's sweep, so `y = h(x)` holds at every handler entry. No
[bundle](#g-bundle) (the NamedTuple of zero-copy views a component function
receives) ever straddles two epochs.

Serialization is what delivers the epoch rule. A component's state stores are
written only by its own handlers, and it fires at most one event per round, so
no same-round writer precedes any handler's entry.

**A component's other eligible events are blocked, not lost**
([D-191][d-191]). Each is re-decided in the next round, against the
post-transition sweep ([D-154][d-154]). Declaration order is therefore a
priority with re-decision, not a simultaneity. An event whose premise the
earlier transition falsified simply does not fire. Under a within-round
sequence it would have fired on the stale premise.

Blocking is visible in the registers ([D-191][d-191]). An eligible-but-blocked
event is the one case whose last-observed sample is not overwritten, so the
edge it presented stands unconsumed. A guard that keeps holding therefore fires
in the next round on that same edge. One that the transition falsified records
not-holding as usual, and any later re-rise is a fresh edge. The prior stays
honest at no cost. The quiescent round fires nothing, hence blocks nothing, so
every sample takes its final update before the prior is written.

Across components, handler order within a round is semantically unobservable
([D-154][d-154]). The reason is stronger than serialization. There is no
delivering mechanism at all. Nothing writes the table mid-round, so there is
nothing for order to observe.

Execution order is fixed all the same. It follows the component order of the
[executor](#g-executor) (the compiled form of the stage execution order), then
declaration order within a component. That keeps the [execution cursor](#g-execution-cursor) (the
executor's field recording where execution stands, [§13.4][s13-4]) and the
diagnostics stream deterministic. No trajectory depends on it. The natural
single-pass executor is therefore exactly correct. It builds each handler's
bundle at dispatch, from the live table. It needs none of the extra machinery
that [D-154][d-154] made unnecessary, and it allocates nothing ([D-292][d-292]).

The trade, stated openly, is that **a handler cannot opt into seeing a
same-round foreign transition** ([D-100][d-100], [D-292][d-292]). Same-instant sequential
coupling across components is a cascade, one round per link, deterministic.
Coupling tighter than that belongs inside one component, where declaration
order gives exact sequencing across rounds. This is the position of the
synchronous languages. A micro-step sees the pre-state, and effects appear at
the next micro-step.

Serializing same-component firings costs one extra intra-boundary sweep per
event so serialized, which is microseconds on the rare boundary that fires at
all. [D-154][d-154] and [D-100][d-100] record the rejected shapes.

#### The firing budget

A per-event firing budget lets a re-enabled event fire at its true boundary,
against a fresh sweep. Priors stay honest as a consequence. Every prior is a
sample actually taken, never a value recorded to make a rule work out. The
deferral design and the rounds cap are both rejected ([D-020][d-020],
[D-181][d-181]). The deferral design fired a re-enabled event one step late,
through a manufactured not-holding prior ([D-181][d-181]). The rounds cap
bounded the number of rounds at a boundary ([D-020][d-020]).

Termination is then budget-bounded rather than structural. For `E` declared
events, a boundary admits at most `firing_budget · E` firings, hence a bounded
number of rounds, deterministically and independently of pace. A livelock, such
as two FSMs toggling each other, does not resolve silently. Each toggler spends
its budget and warns (below). The run proceeds, and its [replay](#g-replay) (the
ordinary loop re-driven from the trace) is identical. This is degradation, not
an error, per the doctrine of [§10.4][s10-4]. The warning names the actual
chatterer, while every other event's iteration continues untouched.

This trade is also stated openly. Because termination is budget-bounded rather
than structural, the objection that a rounds cap is an arbitrary knob
([D-020][d-020]) lives on in `firing_budget`. [D-181][d-181] records what that
buys.

**Budget exhaustion degrades; it does not throw** ([D-181][d-181], [D-292][d-292]). When an
event has fired `firing_budget` times at a boundary, its further edges there
are lost for the rest of that boundary. The eligibility test skips it while
every other event iterates normally. A lost edge emits a `FiringBudget` warning
([§13.2][s13-2], [Appendix C][sC]), at most once per event per boundary. An
event that fires its budget out and then quiesces lost nothing and warns
nothing. The warning carries the component path, the event name, the boundary
time and the exhausted budget beside the boundary's firing count.

The default of 4 is chosen the way [§10.4][s10-4] chooses 8 for the
[localization budget](#g-chattering) (the count of localizations permitted
within one [frame](#g-frame), one grid step). A legitimate re-enable is one or two firings deep. A toggling
FSM pair chatters without bound. A budget of 4 separates the two without ever
binding on a healthy model. Like every other degradation here, it depends on the
trajectory alone, so the run replays identically.

The doctrine of [§10.4][s10-4] governs both budgets. Neither the boundary
iteration nor re-localization within the frame has a
structural bound, so each takes a budget. The boundary iteration takes
`firing_budget`, per event per boundary, and re-localization takes
`localization_budget`, per frame. Both degrade loudly rather than erroring,
under a warning that names the offending event. They differ only in what
exhaustion sheds. Localization sheds root-finding precision and preserves every
firing at boundary granularity. The firing budget sheds firings, which is
exactly what bounds the iteration.

#### Ticks after quiescence

**Ticks stay outside the iteration, after quiescence** ([D-020][d-020]). The
two possible couplings resolve asymmetrically.

- From events to ticks, machinery already in place handles the coupling. Due
  discrete components' output stages (`y_state`/`y_direct`) are gated into the
  boundary sweep against a due set fixed for the whole iteration
  ([§10.5][s10-5]). Every iteration round therefore refreshes them for free,
  against the same `s` and post-transition inputs. Their `s_update` has not
  run yet. At quiescence, their published outputs reflect the settled boundary
  instant, which is exactly what "sampling at t" should mean for a logically
  instantaneous cascade. Earlier rounds' tentative values are internal scratch,
  like RK stage evaluations. [§10.3][s10-3] states when external readers may
  observe the table.
- From ticks to events, a coupling is structurally impossible. A tick's output
  stages contribute nothing guards have not already seen, since they run inside
  the sweep, from current `s`. Its `s_update` writes `s⁺` after the sweep, and
  `s⁺` is first decoded at the owner's next tick. So `s⁺` is invisible to every
  reader within the boundary. This is the standard one-sample `z⁻¹` delay of
  sampled-data control, enforced here by construction. Nothing that happens
  after quiescence can flip a guard, so there is no combined event/tick fixed
  point to iterate.

The boundary macro-sequence, in its final form, is the following.

> integrate → project → [sweep → guards → handlers] iterated to quiescence
> (under the firing budget) → all due `s_update` calls → logging / I/O staging.

Boundary zero is the same sequence with an empty integrate ([§14.5][s14-5],
[D-067][d-067]).

The sequence decides the mixed case, where the handler of a
[continuous component](#g-continuous-component) (the hybrid primitive, with
continuous state, modes and events) and its discrete observers' ticks land on
one boundary. Take an engine's `starting → running` transition under a 50 Hz
flight control system (FCS). The engine is a continuous component, and the FCS
is a discrete component that observes it. The transition fires in the iteration
segment. The re-sweep re-runs the FCS's stages against `running`-mode ports, and
its `s_update` then runs from post-transition values.

### 10.7 Real-time pacing

A real-time run must keep to wall-clock time, and its trajectory must not
depend on how fast it runs. [Pacing](#g-pacing) (the waits that hold a run to
wall-clock time) does the first without breaking the second. This section covers
the invariant with the wall-clock map, the wait, the diagnostics, and where
staging and concurrency live.

#### The invariant and the wall-clock map

**Pacing is outside the semantics** ([D-021][d-021]). That is the section's
invariant. The pacer inserts waits between completed [frames](#g-frame)
(iterations of the loop). It never reorders, skips or alters the
[boundary](#g-boundary) sequence. A paced and an unpaced run with identical
input [traces](#g-trace) (the records of each frame's drained inputs) produce
bit-identical trajectories. So deterministic [replay](#g-replay)
([§2.4][s2-4]) extends over pace. Interactive runs differ only because their
*inputs* differ.

Detection policy is inside the semantics. **Event localization runs
identically paced or unpaced** ([§10.4][s10-4], [D-080][d-080]). Its
[sweep](#g-sweep) cost is absorbed as debt (wall time that later
frames repay) like any other expensive frame ([D-080][d-080]). Degrading to
boundary detection under pacing was rejected ([D-080][d-080]).

**The wall-clock map is piecewise affine, re-anchored at every knee**
([D-021][d-021]). A knee is a point where the map changes slope or offset. A
pace change, an un-pause and a forgiveness re-anchor each make one. The map is
$\tau(t) = \tau_{\mathrm{anchor}} + (t - t_{\mathrm{anchor}})/p$, with the
anchor pair as its reference point. Here $p$ is the pace and $\tau$ is
wall-clock time. The anchor pair $(t_{\mathrm{anchor}}, \tau_{\mathrm{anchor}})$
is the sim time and wall-clock time at the most recent anchor. A live pace
change re-establishes the anchor at the current `(t, τ)`, so the new slope
applies only forward ([D-021][d-021]). Un-pause re-anchors for the same reason.
Debt is cleared at re-anchor. A deliberate user action is a natural sync point.
The counters record what was forgiven. The frame that follows an anchor has no
wait, because its deadline is the anchor itself. The run's first anchor is taken
when its loop starts, so the first frame runs at once ([D-269][d-269]).

**The deadline law is an absolute schedule with bounded debt**
([D-021][d-021]). Frame deadlines come from the map. A frame that exceeds its
wall budget `h/p` leaves debt. Subsequent frames repay it by running short or
without waiting. The long-run rate is therefore exact, and ms-scale hiccups
from GC or the scheduler are invisible.

**Debt beyond a threshold of five frames' worth of budget, `5·h/p`, is
forgiven** by re-anchor plus a warning ([D-133][d-133]). As a result, long
stalls (a debugger, laptop sleep) do not trigger catch-up bursts. Five frames'
worth sits comfortably above the ms-scale hiccups that debt exists to absorb
silently, and far below the seconds-to-minutes stalls that forgiveness exists
for. Neither case lands near the threshold.

**`p = ∞` is pacer-off, not a limit value** ([D-021][d-021]). Unpaced mode is
the explicit *absence* of deadlines. There are no waits, no debt and no
warnings. By the invariant, it is the same execution with the waits deleted.

#### The wait

**The wait mechanism is a hybrid sleep-then-spin with one knob**
([D-021][d-021]). Non-realtime OSes guarantee only a lower bound on sleep. The
thread becomes runnable no earlier than requested. The wake-up is best-effort,
subject to timer granularity, scheduler load and macOS timer coalescing, with
no hard upper bound. Measured on the dev machine, idle, against 2 ms requests
(2026-07), Julia `sleep` overshoots by about 1.4 ms median, and
`Libc.systemsleep` by about 0.5 ms. Behind the `sleep` figure are libuv's
millisecond-granularity timers. Sub-ms requests are accepted and rounded up.
Spikes under load are unbounded. The pacer therefore sleeps toward
`deadline − margin` and spins the remainder:

```julia
remaining = deadline - margin - τ()
remaining > 0 && sleep(remaining)   # coarse phase: cheap, lower-bound-only (runs at most once)
while τ() < deadline                # spin phase: µs-precise, CPU cost bounded by margin
    GC.safepoint()                  # a safepoint, never a yield: GC and signals get through
end
```

`margin` is a single constant calibrated to cover the primitive's granularity
*plus* typical overshoot ([D-021][d-021]). There is no second threshold. The
resolution floor is absorbed into the calibration ([D-294][d-294]). A margin below the
primitive's granularity defeats the spin phase's purpose.

**The default `margin` is 2 ms** ([D-133][d-133]), the value the measurements
above imply. It covers libuv's millisecond timer granularity and `sleep`'s
median overshoot of about 1.4 ms. Anything larger merely spends more core in
the spin phase. The knob spans the whole design space ([D-021][d-021]):

- `margin = 0` is pure sleep, the cheapest in CPU. Frame spacing is bursty,
  but the absolute schedule still delivers the exact *average* rate through
  debt repayment. The spin phase buys regularity, never rate correctness.
- `margin = 2 ms` is the hybrid default. It sleeps about 90% of a 20 ms budget
  and lands within µs of the deadline at a few percent of one core.
- `margin = ∞` is pure busy-wait, FlightCore's behavior, with maximum frame
  regularity at one pinned core. The "best attempt at real time" mode is the
  knob's endpoint, not a separate mechanism.

When the frame budget is at or below the margin (for example `h = 0.01` at
`p = 5`, a 2 ms budget), the hybrid degenerates to pure spin per frame by
construction. Rare wake-ups past the deadline are overruns, absorbed as debt.

Which primitive the coarse phase uses, task-yielding `sleep` or
thread-blocking `Libc.systemsleep`, is settled in [§12.2][s12-2]. The coarse
phase uses task-yielding `sleep`, with `margin` absorbing its overshoot
([D-027][d-027]).

The wait sits at the frame top, after the
[control plane](#g-control-plane) (the atomic surface carrying pause, pace and
stop) is consulted. A control change issued during a wait is observed at the
next frame top, at most one frame budget `h/p` later ([§12.1][s12-1],
[D-269][d-269]). The wait is an unmask point ([§12.4][s12-4],
[D-132][d-132], [D-294][d-294]) for the [operator interrupt](#g-operator-interrupt) (Ctrl-C in
an interactive session). The interrupt raises out of the coarse phase's
`sleep`.

#### Diagnostics

Overrun count, current and peak debt, forgiven-debt events and wait
statistics are published as [framework status](#g-framework-status) (the
frozen diagnostics value each snapshot carries beside the signal table) for
GUI and logs. The record carries `pace`, the pace the loop's frames run
under (`Inf` where no frame waits). It carries `debt` and `peak_debt`, in
seconds, and `overruns`, the frames that exceeded their budget. It carries
`reanchors`, every re-anchor after the run's first, and `forgiven`, the
seconds of debt those re-anchors cleared. It also carries `waits` and
`waited`, the frames that waited and their total wall time ([D-269][d-269]).

A deliberate re-anchor, from a pace change or an un-pause, is counted and
raises no warning. The forgiveness re-anchor is counted and reports
`DebtReanchor` ([Appendix C][sC]). A live switch to `p = ∞` is a pace change
like any other. It re-anchors, and the debt it clears is counted as forgiven
([D-269][d-269], [D-294][d-294]).

#### Where staging and concurrency live

The wait interval is the natural staging slot for externally injected inputs,
which are drained at the next frame top. The staging rules belong to
[§11][s11] and [§12][s12], as does the concurrency model generally.
[§10.3][s10-3] constrains the concurrency model but does not decide it.

---

## 11. Runtime periphery: the data plane

This chapter specifies the data plane, how data crosses between the loop ([§10][s10])
and the periphery (GUI, input devices, network I/O and logging), taking root
inputs ([§8.6][s8-6]) as given. [§11.1][s11-1] covers the architecture that replaces FlightCore's
shared mutable model; [§11.2][s11-2] the outbound data channel, snapshot publication;
[§11.3][s11-3], [§11.4][s11-4] and [§11.5][s11-5] the inbound data channel, in turn its root inputs, claims
and frozen roster, its per-device staging, staged representation and drain, and
its input trace; [§11.6][s11-6] the device authoring contract; [§11.7][s11-7] the GUI write path;
and [§11.8][s11-8] runtime diagnostics and liveness, a third channel between tasks beside
the two data channels.

The machinery that drives the loop itself follows in [§12][s12].

### 11.1 No shared mutable model: staged writes, snapshot reads

Everything in the [periphery](#g-periphery) (GUI, input devices, network I/O, logging) runs on
tasks the loop does not control, and every one of them wants the data the loop
is stepping. FlightCore's answer is one big lock. In FlightCore's `sim.jl`,
`SimControl` and the live `Model` are guarded by `io_lock`, with one task per
attached interface reading or mutating the model under it. That lock does
enforce the [boundary](#g-boundary)-visibility rule ([§10.3][s10-3]), because the lock is only ever free
between steps. A boundary is a published consistency point. Transplanting the
lock here was nevertheless rejected, on three structural costs ([D-022][d-022]). One of
the three is decisive for everything below. Under a lock, input timing is
scheduler-determined and unrecorded. There is then no defined input [trace](#g-trace) (the
primary record of a session), and bit-identical [replay](#g-replay) (the ordinary loop with
its drain reading the trace, [§12.7][s12-7]) is unachievable *in principle* for
interactive runs. This section sets out the five planes that replace the lock,
the two rules that bind their implementation, the task topology, and one
consequence for execution modes.

The replacement's unit of account is the [frame](#g-frame) (one grid step, [§10.1][s10-1]). Each
frame is one iteration of the loop, which runs the [drain](#g-drain) (the frame-top swap
that applies staged device writes to the root inputs), then integrates, then
runs the boundary sequence, then publishes. A frame is what `step!` counts, and
it is the ordinal that keys the trace ([D-101][d-101]). "Per frame" means this throughout
the document. The kinematic *reference frames* of the aircraft domain are a
different word, and they always appear compounded, as in the b frame and the
ECEF frame. The b frame is the body frame, and ECEF stands for Earth-centered,
Earth-fixed.

The replacement has five planes.

1. Staging is the inbound path ([§11.4][s11-4]). [Devices](#g-device) (attached participants in the
   periphery) submit pending input writes at any wall-clock moment, never
   touching live [root inputs](#g-root-input) (the root component's own input faces).
2. **The drain is exactly one point in each frame, at its top**, where the loop
   takes the staged [batches](#g-batch) (each device's set of pending writes) and applies
   them to the root inputs ([D-022][d-022]). It never happens at a `t*` boundary ([§10.4][s10-4]).
   Between drains the loop owns its data exclusively, and no lock is held during
   stepping, ever.
3. Publication is the outbound path. The loop publishes an immutable [snapshot](#g-snapshot) (a
   boundary-consistent signal table with its framework status) at the end of
   each boundary sequence ([D-022][d-022]). Readers observe it without coordinating with
   the loop ([§11.2][s11-2]).
4. **Control places pause, pace and stop on a separate few-word atomic surface**
   ([§12.1][s12-1], [D-022][d-022]).
5. Task topology places one loop on the [calling task](#g-calling-task) (the task that invoked
   `run!`) and one spawned task per rostered device, all run-scoped.

Two rules bind the implementation.

- **Every handoff is one atomic reference operation** ([D-022][d-022]). The [staging cells](#g-staging-cell)
  (where a device's pending write batch waits between drains) and the reference
  to the published snapshot reduce their mutable surface to single words,
  release/acquire `@atomic` fields. The GC is the reclamation mechanism, since
  an object a reader still holds is reachable and therefore never recycled. That
  dissolves the reclamation problem (hazard pointers, epochs, read-copy-update
  grace periods) which makes lock-free handoffs hard in non-GC languages. Deep
  immutability of the exchanged objects is what makes this sound.
- **No user code, no unbounded work, ever, inside a framework critical section**
  ([D-022][d-022]). FlightCore's pathologies are all "arbitrary code under a shared
  lock". Here mappings run on device tasks ([§11.4][s11-4]), rendering runs against
  snapshots, and the loop's frame contains framework and model code only. A
  stalled device produces stale snapshots and late staging. It cannot stall the
  loop. Two exposures are residual and pre-existing, GC pauses and OS
  scheduling, and the pacer's debt absorption ([§10.7][s10-7]) is the mitigation for
  both.

The fifth plane carries the most machinery, and the paragraphs below spell it
out.

**Device tasks are run-scoped** ([D-093][d-093]). `run!` spawns one task per entry of the
[roster](#g-roster) (the list of attached device entries) after device `init!`, and [§12.4][s12-4]
joins them all at every stop ([§12.6][s12-6]). `attach!` never spawns. It registers, in a
stopped-sim state only ([§11.3][s11-3]), and the task appears at the next `run!`.

**The loop runs on the calling task** ([D-310][d-310]). This is what the synchronous
rethrow ([§13.4][s13-4]) presupposes. It is also what lets parallel unattended sweeps
thread `run!` inline with no nested task fan-out. One immutable [`Build`](#g-build) (the
artifact `build(world)` produces) is shared across the workers ([§9.2][s9-2], [D-282][d-282]),
and each `Simulation` owns its own `Model`, and with it the `Model`'s [buffers](#g-buffer)
(the framework-owned vectors backing continuous state) ([§9.4][s9-4]). Pre-materializing
the sweep's [activations](#g-activation) (the build's typed products at a scalar type) with
`build(world; activations = …)` ([§9.4][s9-4], [D-135][d-135]) then leaves no worker
synchronizing on anything. `run!` blocks its caller until the run ends.

Which devices get a task is decided after initialization, from the frozen roster
and the outcomes of device `init!`, never from `run!`'s keywords ([D-310][d-310], [D-138][d-138]).
A device whose `init!` failed gets no task ([§12.4][s12-4], [D-138][d-138]).

**Spawn-inside-`run!` is the start gate** ([D-093][d-093], [D-367][d-367]). A task exists only
once the run it serves exists. Any first-boundary synchronization a device needs
is the counter-plus-condition predicate wait ([§12.3][s12-3]), never a `Base.Event`
latch.

One consequence is recorded here because it collapses an API axis. Interactive
and unattended simulation stop being different execution modes ([D-022][d-022]). An
[unattended run](#g-unattended-run) is the same loop with empty staging and no snapshot readers. A
replayed interactive session is the same loop with its drain fed from a recording
([§11.5][s11-5], [§12.7][s12-7]).

### 11.2 Outbound: snapshot publication

Every consumer of model state needs a picture of the model that holds still
while it is read. GUI panels and output [devices](#g-device) (attached participants in the
periphery) are such consumers. So is the [log](#g-log) (the retained sequence of published
snapshots). None of them should have to make the loop wait to get one.
Publication is the answer. One immutable value is published per [boundary](#g-boundary) (a
published consistency point), handed out through a single atomic reference.
Three things follow from it. In order, they are how a [snapshot](#g-snapshot) (the immutable
per-boundary publication) is built and published, how the log retains published
snapshots under a bound, and how an output device addresses what it reads.

#### The snapshot and its publication

**The loop builds each snapshot in private memory, then publishes it with a
single release-store** ([D-023][d-023]) to an [`@atomic latest`](#g-latest) reference (the single
handout point for published snapshots). A snapshot carries the
boundary-consistent [signal table](#g-signal-table) (the cells holding every produced signal) and
`t`. It carries the index of its [frame](#g-frame) (one iteration of the loop) and its
published-boundary ordinal ([§12.3][s12-3]). It also carries the [framework status](#g-framework-status) (the
run's diagnostics and liveness record, [§11.8][s11-8]). The frame index is what places a
`t*` snapshot in its frame, since a `t*` publication counts an ordinal of its
own ([D-261][d-261]). Readers acquire-load that reference and then work with an
immutable, coherent world for as long as they like. The [calling task](#g-calling-task) (the task
that invoked `run!`) reads the same value through `latest(sim)`, an inspection
read ([§12.6][s12-6]).

The exchange is wait-free in both directions ([D-023][d-023]). A wedged reader cannot
delay publication by a nanosecond, and the loop cannot tear a reader's view.
Publication happens only after the boundary sequence completes ([§10.3][s10-3], [D-293][d-293]).

The binding rule states that **nothing reachable from a published snapshot is
ever written again** ([D-023][d-023]). The soundness of lock-free reading rests on this
rule. The table's immutable values ([§4.1][s4-1], [§7][s7]) make the compiler enforce most of
it.

The framework status is a concrete frozen value, not a window onto live
bookkeeping ([D-136][d-136]). [§11.8][s11-8] lists what it carries. The binding rule forces that
shape. A status referencing an accumulator its writers are still filling would
be a snapshot whose contents change after publication.

The captured table is the whole table. It holds the declared [ports](#g-port) (the
addressable unit, one declared name with one cell), every one of them public
([§8.3][s8-3]). No presentation layer has anything to filter. Undeclared intermediates
are not in it, because only declared ports are [cells](#g-cell) (the signal table's typed
value holders, one per output port, [§8.3][s8-3]). The inspection path for one is
promotion to a declared output ([D-194][d-194]). Add a line in `y_types`, and the value
appears in the snapshot, the log, the GUI and the wiring alike. Its visibility
is then an authored fact like every other.

**The captured table also includes the [root inputs](#g-root-input)** ([D-047][d-047]). Root inputs are
the root component's own input [faces](#g-face) (the names ports wear on their component's
boundary). They are source cells of the table, not state stores, so they ride
along. That is essential, not incidental. The [peek](#g-peek) (showing a widget's own
pending write, else the snapshot value, [§11.7][s11-7]) falls back to the snapshot, and
that fallback is what an idle live widget displays. Read-only mirrors of claimed
root inputs, such as the axis sliders under joystick [claim](#g-claim) (the set of faces a
device may write), show the applied root-input value from the snapshot. Root
input values in the log are derived data, recomputable from the [trace](#g-trace) (the
primary record of a session). That is consistent, because snapshots are derived
wholesale.

**The snapshot deliberately does *not* carry the state stores** `x`, `s` and `m`
([D-038][d-038]). There are two reasons. The state trajectory is *derived* data,
recomputable from the [trace header](#g-trace-header) (the trace's fixed preamble) plus the [batches](#g-batch)
of staged device writes ([§11.5][s11-5]). The recomputation is bit-identical [replay](#g-replay) (the
ordinary loop re-driven from the trace). And per-boundary capture would
systematically record derived data, the same asymmetry the trace-default
decision ([D-029][d-029]) refuses in the other direction.

"What was the private state at t = 37.2?" is answered by replaying to 37.2 and
inspecting the live stores ([D-038][d-038]). A state field wanted in logs or GUI has the
honest remedy of being declared public and returned from `y_state` ([§5.3][s5-3],
[D-252][d-252]). It costs one cell per [sweep](#g-sweep) (one pass through the execution order).
Post-run continuation reads the live stores directly. Periodic full-state
checkpoints are a [guarded addition](#g-guarded-addition) (a capability the design admits but does not
build), shaped as an opt-in log policy ([D-038][d-038]). They would allow warm restart
without replay from zero. Each would retain a [checkpoint](#g-checkpoint) (the `Model`'s state at
a frame top as one value), the value `checkpoint(sim)` returns ([§12.6][s12-6]). A
dev-mode flag that reads every state field out of the stores is a possible
future diagnostic. It would be a reader over the stores, never a port class
([D-252][d-252]).

**Event firings are not recorded** ([D-309][d-309]). The log holds boundary snapshots and
the trace holds staged inputs ([§11.5][s11-5]). Neither carries a per-event record.
Replay plus the published modes recovers which events fired at which boundary.
The honest remedy is again to declare the mode field public and return it from
`y_state` ([D-252][d-252]). A mode field so exposed is in every snapshot. An event-firing
stream is a guarded addition.

#### The log: retained snapshots under a bound

**The log is a vector of retained snapshot references** ([D-023][d-023]). Logging thus
dissolves into publication. The references are the same objects, with zero extra
copies. The per-step `deepcopy` detour of FlightCore's `SavingCallback`
disappears. The cost is one snapshot allocation per boundary. It falls on the
framework side of the allocation scope [§9.8][s9-8] sets, which already carved out
logging. Logged snapshots are not garbage at all, and unlogged ones die young.
Preallocated snapshot buffers are rejected ([D-023][d-023]).

**Log retention is the trace's kill switch, plus [decimation](#g-decimation)** ([D-038][d-038]). The log
takes the same plain on/off switch the trace has ([§11.5][s11-5]). Decimation is the
log's additional keep-every-kth retention policy, `log_every` ([Appendix B][sB]).

The derived/primary split ([D-038][d-038]) decides why decimation is admissible here and
not there. The log is recomputable from the trace by replay, so a thinned log
costs resolution in a *view*, never in a record. Thinning the trace would
destroy the only primary account of a session ([D-029][d-029]). Decimation is a retention
policy only. Every boundary still runs, is still published to live readers, and
still enters the trace ([D-038][d-038]).

Decimation slows the log's growth. It does not stop it. The default
configuration is `log = true, log_every = 1` alongside `t_end = Inf`, `init!`'s
and `run!`'s defaults ([Appendix B][sB]). Under it the log grows for as long as the
session lasts. At the scale of the C172X (FlightApps' Cessna 172X model) and 50
Hz, that is gigabytes per hour. It ends in an out-of-memory nobody was warned
about.

**The log takes a retention bound beside its switch and its stride** ([D-137][d-137]).
The bound is `log_max`, the maximum number of retained snapshot references. Its
default is 65536 (2¹⁶), with `Inf` the explicit opt-out ([D-137][d-137], [D-368][d-368]). The four
recording keywords appear on `init!` with their defaults ([Appendix B][sB]).

```julia
init!(sim, condition; trace = true, log = true, log_every = 1, log_max = 65536)
```

**The bound is a count, not a memory budget** ([D-137][d-137], [D-368][d-368]). Snapshots are
immutable object graphs ([§4.1][s4-1]) with internal sharing. A [field handle](#g-field-handle) (an
immutable query object consumers evaluate at their own arguments, [§4.4][s4-4]) rides as
a reference to build-time-frozen data ([§9.8][s9-8]). Byte accounting over snapshots is
therefore fuzzy and platform-dependent. A count is exact. It converts to memory
through one number the user can measure once, `Base.summarysize` of a single
snapshot.

**The default is finite unconditionally** ([D-137][d-137], [D-368][d-368]). It is not a modal rule
keyed on `t_end`. A finite run shorter than the bound never notices the bound,
and one number is easier to hold than two regimes. At 50 Hz and full density,
2¹⁶ boundaries is about 22 minutes before anything is dropped at all.

**When the log fills, the retention stride doubles**, so coverage stays global
([D-137][d-137], [D-368][d-368]). A rolling window, with the recent past at full density and the
start of the session forgotten, was rejected ([D-137][d-137]). Instead the log
re-decimates progressively. After *k* generations the effective stride is
`log_every · 2^k`. The whole run stays plottable, and what coarsens is density,
never extent.

The doubling is the division of labor ([D-038][d-038]) carried through. The log's chief
consumer is the post-run plot of a session *as a whole*, and nobody plots hours
at 50 Hz. Full density over any *segment* of interest is what replay from the
trace recovers ([§11.5][s11-5], [§12.7][s12-7]).

**The guarantees are normative, not the mechanism** ([D-137][d-137], [D-368][d-368]). There are
three. The bound is respected continuously, and the retained count never exceeds
`log_max`. Coverage is global at the effective stride. And **the endpoints are
retained unconditionally** ([D-137][d-137], [D-368][d-368]).

The run's first snapshot and its terminal snapshot ([§12.4][s12-4], [§13.5][s13-5]) survive any
`log_every` and any `log_max`, and they do not count against the bound. They are
two extra references. The first is the boundary-zero snapshot under `init!`
([§14.5][s14-5]), and the snapshot `restore!` or `replay!` publishes as it builds the run
([§12.6][s12-6]). **The stride counts boundaries from it** ([D-377][d-377]). The terminal snapshot's status
carries the run's final cumulative diagnostic counters ([§11.8][s11-8]). A run's two
endpoints and its diagnostic account therefore always outlive whatever retention
did to the middle.

The mechanism sketch is non-binding. The thinning is amortized. When the log
fills, the stride doubles immediately. Each subsequent retained append also
releases one predecessor of the previous generation. A cursor over the odd
indices does this in O(1) amortized, with physical compaction once per
generation. A generation's thinning therefore completes exactly when its refill
does.

> fill at stride `log_every` → *full* → stride doubles → thin one predecessor
> per retained append, while refilling → *full* at stride `log_every · 2` → ⋯
> → generation *k* at `log_every · 2^k`

Amortizing rather than halving in one shot is a responsiveness choice ([D-137][d-137]).
The amortized form drops exactly one old snapshot per retained append, the same
steady trickle a rolling window would produce. Keeping coverage global therefore
costs nothing extra in GC pressure. The loop's own work is pointer bookkeeping,
microseconds either way and on the framework side of the scope ([§9.8][s9-8]).
Publication stays wait-free and readers never block. A reader holding a released
snapshot simply keeps it alive.

Two compositions are worth stating once. The monotonicity of `totals`, the
status's cumulative per-writer counters, across logged snapshots ([§11.8][s11-8]) is
untouched. Re-decimation, like decimation, loses *which* boundary within a
stretch an occurrence fell on, never *how many*. And **`log_max` is a view
policy, not a trajectory-determining one** ([D-137][d-137], [D-368][d-368]). Like `log` and
`log_every` it stays out of the trace header's [`Deployment`](#g-deployment) (the scalar-free
artifact the grid parameters fix), and replay neither records nor compares it
([§11.5][s11-5], [§12.4][s12-4], [§12.7][s12-7]). Sizing follows. A finite `log_max` is the log's `sizehint!`
([§9.8][s9-8]).

**Post-run extraction reads the log through the read-selector family**
([D-407][d-407]). `series(sim, read_set)` takes a read set, the value trim's
`reads` builds and `at` mounts ([§14.7][s14-7], [§14.9][s14-9]), resolves it
against the `Build` for a table source through the resolution every reader
shares ([§14.4][s14-4], [D-406][d-406]), and gathers each labeled entry over
the retained snapshots into one column, a plain vector of the entry's leaf
type. The columns come back labeled as the set labels them, beside the
snapshots' `t`, frame and boundary ordinals. A store selector is refused as
it is at attach, since a snapshot carries no stores. Resolution runs once
per call, so a column costs one typed loop over the log and no name lookup
per snapshot. What a user plots is a column against `t`. A window is a mask
over `t`, and full density over a segment is replay's ([§11.5][s11-5], [§12.7][s12-7]).

#### Output-device bindings

**Output-device [bindings](#g-binding) are snapshot bindings** ([D-083][d-083]). A binding is the value
passed at `attach!` that makes a device framework-legible. An output device
consumes snapshots as [§12.3][s12-3] specifies. Examples are telemetry, disk streaming
and the XPlane visualizer (FlightCore's `XPlane12Control` output device). An
output device addresses what it reads with the [selectors](#g-selector) (the closed family of
deferred reads resolving against a source, [§14.4][s14-4]). They reach any cell the
structure has ([§13.3][s13-3]). **A binding's reads resolve at attach
through the one resolver every reader of the family shares** ([D-406][d-406]),
against the `Build`, with [did-you-mean](#g-did-you-mean) (the offending name plus the list-in-hand it should
have matched), and compile to one gather, the output half of the binding
interface ([§11.6][s11-6]). `map_output` therefore receives a labeled NamedTuple ([§11.6][s11-6])
instead of performing its own path lookups. A model substitution that breaks a
binding therefore fails at attach, not with silent garbage on the wire ([D-130][d-130]).
**Attach refuses such a binding with the read's own kind, `ReadResolution`,
every violation collected** ([§13.1][s13-1], [D-406][d-406]). An exporting logger
treats field-handle signals specially. It skips or summarizes them.

An output device's read of the snapshot is inspection ([§13.5][s13-5], [D-083][d-083]). It is
human-facing, with no effect on run semantics. It is observation of the same
sort as the log retaining the full table and the GUI's deep-reading panels.
Every cell is reachable, because the table is public throughout
([§8.3][s8-3], [§13.3][s13-3]).

A binding chooses its side ([D-129][d-129]). A deep path is an *inspection* read. It
makes zero promises, gives free access, and is right for looking at *this*
build. An exported output face, spelled `get_face(name)` ([§14.4][s14-4]), is an
*integration* read. It is named, curated and meaning-stable under substitution,
and right for consumers that outlive the build they were configured against.
What makes a face meaning-stable is writer-independent semantics ([§11.4][s11-4], [D-045][d-045]).

The choice matters because of drift. Attach validation converts *structural*
drift to loud errors on both sides ([D-083][d-083]). Only faces protect against
*semantic* drift. In semantic drift, a substituted aircraft publishes the same
path at the same type with a different meaning, such as a center-of-gravity
velocity under a name read as body-origin velocity. Nothing else can protect
against it, because meaning is not in the schema.

Semantically generic consumers should therefore bind faces ([D-083][d-083]). A visualizer
needs pose, and every aircraft has one. Aircraft families should export the
conventional surface such consumers need, a library/migration deliverable (the
migration outline companion). Wrapper types make face semantics structurally
checkable. An example is `VelocityData`, an illustrative wrapper type, with its
`v_eb_b` defined *at the type* as body-origin velocity. A bare vector does not
wire, and wrapping the wrong quantity is a deliberate lie, not a drift.

### 11.3 Inbound: root inputs, claims and the frozen roster

The [periphery](#g-periphery) (everything outside the loop that exchanges data with it) writes
into a running model through its [root inputs](#g-root-input) (the root component's own input
faces) alone. The periphery's writers include [devices](#g-device) (any attached participants
in the periphery). Each root input has at most one writer at any time, and the
assignment of root inputs to writers is fixed for a whole run, because the
[roster](#g-roster) (the list of attached device entries) is frozen per run. The section's
parts, in order, cover root inputs, exclusivity and claims, write surfaces and
claim sources, the harness writer and the layout, root-input initial values, the
frozen roster, device identity and admission, device death, and mid-run readers.

#### Root inputs

The [write surface](#g-write-surface) is the set of faces the entries of a writer's [batch](#g-batch) (its
staged set of writes, applied whole at the next drain) may reach. Its members
are root inputs. A root input *is* the root [component](#g-component)'s own input [face](#g-face), an
assembly's `input_wires` key or a primitive's `u_types` key ([§8.2][s8-2], [§8.6][s8-6], [D-208][d-208]).
A component is the unit of modeling, and a face is the name a port wears on its
component's boundary. A root input is routed inward to consumers and produced by
no component. At every non-root level an input face is fed by the parent's wire,
and at the root there is no parent. No dedicated vocabulary is needed.

A root input is usefully read as the output face of the one producer the build
never sees, the periphery and the services. On that reading, root-input
exclusivity (below) is that producer's one-writer right, and the totality
([§14.6][s14-6]) is its completeness obligation.

Root inputs are sources to the build-time ordering, and they are constants
within a [frame](#g-frame) (one iteration of the loop). They are the *only* thing the
periphery may write ([D-031][d-031]). The GUI reaches them through port resolution
([§11.7][s11-7]), and control commands are not writes ([§12.1][s12-1]). Devices, mappings, the
[trace](#g-trace) (the primary record of a session) and the GUI write path address root
inputs by face name ([§8.6][s8-6]). Structural slash paths never reach the periphery's
writes. The write side speaks the names of the root's [contract](#g-contract), the interface
the root component declares, and no others ([D-129][d-129]). The read side chooses per
[binding](#g-binding) (the value passed at `attach!` that makes a device framework-legible).
It uses slash paths in inspection reads, and face names in integration reads and
in service reads ([§11.2][s11-2]/[§13.5][s13-5]/[§14.4][s14-4]).

#### Exclusivity and claims

**Root-input exclusivity permits at most one writer per root input at any time**
([D-044][d-044]). A device [claims](#g-claim) its root inputs (stakes them as faces it may write) at
attach, and claiming an already-claimed root input is an attach-time error.
Detaching releases the claims, and the harness writer (described below) takes
the released faces ([D-370][d-370]). The GUI's widgets for a released root input go
live only once a GUI attached after the release claims it, because a claim is
taken at attach and never recomputed ([§11.7][s11-7], [D-174][d-174], [D-370][d-370]). Exclusivity replaces any cross-device conflict
*policy* ([D-044][d-044]), such as attachment-order precedence at the [drain](#g-drain) (the
frame-top swap that applies staged device writes to the root inputs). Per-device
[staging cells](#g-staging-cell) (where each device's pending batch waits between drains), the
compare-and-swap (CAS) merge and the atomicswap drain all stay. They serve
atomicity and [coalescing](#g-coalescing) (keeping one pending batch per device), not
arbitration.

Exclusivity holds because a second live writer on one root input makes the
applied value a timing artifact, as the worked example in [§11.4][s11-4] shows. The usual
pair is a stream and its mirror, a joystick axis and the GUI slider showing it.
Claiming the stream settles that pair with no concurrent writing.

**A claim is what a device *may* write, not what it will** ([D-378][d-378]). Data-dependent
write-sets are ordinary. A UDP/JSON peer writes whichever subset of faces the
incoming message names, and `map_input` is arbitrary user code the framework
never inspects. Such a device therefore claims the binding's enumerated allowed
set, the faces the binding table lists, whether or not any given batch touches
them. The claim is registered at attach exactly as a joystick's is. A broad
claim costs liveness. Every enumerated face is claimed for the device's whole
attachment, so the [derived-liveness](#g-derived-liveness) rule (GUI widget liveness, baked once at run
start, [§11.7][s11-7]) renders the GUI's widgets read-only even on faces the peer never
writes. Narrow the binding to narrow the claim. The enumeration *is* the
interface.

#### Write surfaces and claim sources

Every writer has a write surface, and the periphery enforces it. **A batch entry
reaches a root input iff the named face is inside the writer's surface**
([D-044][d-044]). Anything else is discarded with a runtime warning ([§13.2][s13-2]). Because
surfaces are static per run under [the roster freeze](#g-the-freeze) (attach and detach only
while stopped, below), enforcement runs entirely at *staging*, the earliest
site, on the writer's own task. The drain performs no checks at all.

**Every device's surface is its claim set, and a claim set has two sources**
([D-174][d-174]):

- A *returned* claim is enumerated by the binding. The binding declares
  `is_input(b) = true`, `claims(b)` ([§11.6][s11-6]) is called once at attach, and what
  it names is staked. Such a claim is static for the attachment and exclusively
  its own, since the attach-time exclusivity check keeps claims disjoint. It is
  binding-bounded even where no one else is involved. A mapping that has drifted
  onto an unenumerated face is a diagnosable anomaly (`OutOfClaimEntry`), never
  a silent write, claimed or not. An enumeration naming a face outside the
  root's input faces is refused at attach (`AttachUnknownFace`, [D-216][d-216]).
- A *computed* claim is computed by the framework at attach, when the binding
  declares `is_greedy(b) = true` ([§11.6][s11-6]). It is all root-input faces minus the
  union of the rostered claims, the unclaimed complement at that instant. This
  is the standard GUI binding's claim ([§11.6][s11-6]), everything unclaimed, without
  configuration. It is disjoint from every incumbent claim by construction, so
  exclusivity validates trivially and nothing downstream can tell the two
  sources apart. A complement that comes out empty is legal and useless.
  `attach!` records an `EmptyGreedyClaim` warning for it ([§11.6][s11-6]).

There is one claim mechanism with two claim sources. The source is exhausted at
the attach point. Past it, validation, roster-entry storage, the compilation of
shape, shim, merge and scatter ([§11.4][s11-4]), the drain, the trace ([§11.5][s11-5]) and
detach-releases-claims treat a computed claim exactly as a returned one ([D-174][d-174]).
The GUI is therefore not an exception but an ordinary enumerated writer whose
enumeration the framework performed. Attaching the [greedy claimant](#g-greedy-claim) (the device
holding the computed claim) last is the idiom ([D-192][d-192]). Its computed claim is
taken at the attach point and never recomputed, so attachment order is decisive
by design.

Opportunistic writing by autonomous devices does not exist ([D-044][d-044]). A device
that wants a face enumerates it, and greediness is an explicit declaration,
never a default. Cross-writer races on one root input therefore cannot arise
structurally, because every claim is exclusive, whatever its source. That is
what keeps drain order a diagnostic fact ([§11.4][s11-4]) and lets a drained GUI value
simply stay ([§11.7][s11-7]).

#### The harness writer and the layout

One framework-owned remainder sits beside the roster, the [harness writer](#g-harness-writer) (the
framework-owned write path `stage!(sim, …)`). It is an entry point with no task
of its own, the harness/REPL write path ([§12.6][s12-6], [D-096][d-096]), called as follows.

```julia
stage!(sim, "face" => value, …)
```

It stages a batch from any task, the [calling task](#g-calling-task) (the task that invoked `run!`)
included ([D-200][d-200]). Its always-present staging cell, the [harness cell](#g-harness-cell), is drained,
traced and surface-checked exactly as any device's.

The harness writer's surface is the one thing in the design that is *derived*
rather than claimed ([D-174][d-174], [D-370][d-370]). It is the unclaimed complement, the faces no
rostered device speaks for. That surface is recomputed at every stopped-sim
roster change, and is therefore as fixed within a run as any claim set. A
`stage!` write to a claimed face is rejected at staging (`ClaimedFaceEntry`,
naming the incumbent, [D-174][d-174], [D-370][d-370]). A rostered greedy claimant empties that
surface outright. The greedy claim is itself a rostered claim, so the complement
it leaves is empty and every `stage!` in such a session is rejected that way
([D-192][d-192]). There is one edge case, a batch staged while stopped whose face a
subsequent `attach!` claims, and the attach itself renormalizes it away ([§11.4][s11-4]).

**The harness cell drains last**, by convention ([D-096][d-096], [D-174][d-174]). With every
surface disjoint the order is unobservable, so the rule exists to make the trace
read the same way every time, not to arbitrate anything.

**The periphery resolves root faces against the [activation](#g-activation)'s cell layout alone**
([D-261][d-261]). An activation is the build's typed products at a scalar type. The
layout carries the root faces in structure order with their [probe](#g-probe) values (the
real values the build evaluates each user function with), beside the address
table, so both of the build's lookup families, [schema and layout](#g-schema-vs-layout), read it there,
and writers, claims and the harness compile against it. The services take their
schema from the `Build` itself ([§14.3][s14-3]). The periphery never needs an authored
fact the layout does not hold.

#### Root-input initial values

**The init/trim services own root-input initial values** ([D-047][d-047], [D-376][d-376]). Input
declarations are bare types ([§8.2][s8-2]) and carry no defaults, yet a root input unfed
by any device must hold a defined value from the first frame. No declaration
constant could own that value, because the trim service writes root-input values
it *solved for*, such as throttle and elevator. Export-entry defaults were
rejected ([D-047][d-047]). `init!` establishes every root input, and the [trace header](#g-trace-header)
(the trace's fixed preamble, a checkpoint `init!` takes) captures the result.
Totality is enforced pre-write at every complete-world application, namely
`init!`, trim setup, trim commit and linearization's operating condition
under `about` ([§14.6][s14-6], [D-149][d-149]).

#### The frozen roster

**The roster is frozen per run** ([D-106][d-106]). Attach and detach are stopped-sim
operations. `attach!`/`detach!` are legal in the `built`, `initialized` and
`stopped` states ([§12.6][s12-6]) and an error while `running`. That error is
`ServiceLifecycle` ([Appendix C][sC], [D-108][d-108]), the same kind that gates the [§14][s14]
services. The list is exhaustive. An `errored` simulation refuses both with the
same kind. A roster change configures the next run, and an errored simulation
has none ([§13.6][s13-6], [D-232][d-232]). The prohibition includes pause. Pause is a
control-plane state *inside* a run ([§12.1][s12-1]), and a surface that could move while
paused would move mid-run.

The roster (roster entries, claims, attachment order) is therefore a plain
immutable value. The loop reads it once at `run!`, and nothing republishes it
([D-087][d-087]). The partition of the root face set into per-writer surfaces plus the
harness remainder is a static, inspectable fact of the run ([D-106][d-106]). It is
fixed before the run starts and valid until it ends. Attachment order is the
roster's own order. The trace still tags each record with a stable device id
(described below), never a roster index, because ids read across runs, where
the roster does change ([D-087][d-087]).

Attach validation, claim registration and the staging-shape compilation ([§11.4][s11-4])
all run at the attach point. That makes `attach!`/`detach!` stopped-sim
configuration operations beside `init!` and trim ([§14][s14]). While a simulation runs,
its configuration (build, roster, claims, surfaces) is immutable. The mid-run
mutation doctrine ([§12.5][s12-5]) extends to its final form. The running periphery
stages writes and issues control commands, *and nothing else changes* ([D-031][d-031]).

#### Device identity and admission

Identity is the device instance ([D-375][d-375]). The same object (`===`) may occupy at
most one roster entry. Two instances of the same type, two joysticks say, are
two devices. The stable device id the trace, heartbeat and diagnostics speak is
assigned at `attach!`, monotonic per `Simulation` and never reused. It lives
exactly as long as its roster entry, across runs (roster persistence, [§12.6][s12-6]) and
until `detach!`.

Admission is a two-part check at the attach point, in order ([D-375][d-375]):

```
# each line: the condition that rejects the attach → the diagnostic it raises
identity   this instance is already rostered
               → AlreadyAttached      (names the entry and its binding)
claims     face exclusivity: this device's claim set meets a rostered claim
               → ClaimConflict        (names two distinct devices)
```

An already-rostered instance is rejected rather than silently absorbed, because
rebinding has an explicit spelling, `detach!` then `attach!`, both legal at any
stopped-sim point. Either a silent no-op or a silent rebind would discard a
binding the caller handed over. Running the claims check after the identity
check is what makes `ClaimConflict` always name two *distinct* devices, never a
device colliding with its own earlier attachment. Detaching a device the roster
does not hold is an error (`NotAttached`, [D-215][d-215]).

#### Device death and orphaned claims

**Device death does not detach** ([D-106][d-106], [D-374][d-374]). A mid-run crash, voluntary exit
or unplug ([§11.6][s11-6], [§12.4][s12-4]) ends the device's *task*. The staging cell stops
filling, the heartbeat ([§12.2][s12-2]) shows the death by name, and the roster entry,
claims included, persists to the end of the run. The [orphaned claims](#g-orphaned-claims) (the claims
of a device whose task died mid-run) are the accepted cost of the freeze. The
device's root inputs hold their last-drained values and no other writer inherits
them. The read-only widgets render the orphan visibly, never mysteriously
([§11.7][s11-7]). Recovery is between runs. It takes a stop, a `detach!`, and either
`init!` (fresh trajectory) or `replay!`-to-end then `run!`, which continues from
the interrupted [boundary](#g-boundary) ([§12.7][s12-7]), a published consistency point. The death is an
anomaly, not a surface event.

#### Mid-run readers

One deliberate asymmetry is on record as a [guarded addition](#g-guarded-addition) (a capability the
design admits but does not build). A pure reader claims nothing. Examples are a
binding declaring `is_output` alone ([§11.6][s11-6]), a visualizer or a telemetry tap.
Attaching one mid-run would therefore move no writer's surface ([D-106][d-106], [D-374][d-374]). A
dynamic reader list would touch only [§12.3][s12-3] wakeups, the heartbeat and the
shutdown join, never the drain. The addition is cleanly severable from the
freeze should the join-a-running-session workflow find a customer. The [§12.2][s12-2]
thread-budget warning runs once per run, at `run!` or `replay!`, against the
frozen population.

### 11.4 Inbound: per-device staging, representation and the drain

A [device](#g-device) (any attached participant in the periphery) produces writes on its own
task, whenever its hardware or its peer hands it a datum. The loop consumes them
at the top of each [frame](#g-frame) (one iteration of the loop). Between those two rates
something has to hold each device's pending writes and hand the loop a value it
can apply. That something is the [staging cell](#g-staging-cell) (the per-device atomic holding
place for pending writes), a compound term distinct from a table cell ([D-121][d-121]).
Unlike a table cell it is mutated frame by frame, outside the table's
publish-once discipline. This section first fixes the [coalescing](#g-coalescing) policy (the
compare-and-swap, or CAS, merge that keeps one pending set of writes per device)
under which a device writes into its staging cell. It then fixes the doctrine
for staged values, the mappings that produce them, the shape the staging cell
holds, the sites of the staging diagnostics, and the [drain](#g-drain) (the frame-top swap
that applies staged device writes to the root inputs) that empties it. A worked
example closes the section.

#### The coalescing policy

**Staging keeps one atomic staging cell per attached device** ([D-024][d-024]). **Staging
has one coalescing policy, CAS merge, newest wins per face** ([D-104][d-104]). A device's
staging cell has a single writer, its own device task. It holds that device's
latest pending [batch](#g-batch) (a set of writes applied whole at the next drain). Each
write in it targets a [root input](#g-root-input) (the root component's own input face). Staging
merges the incoming batch into the pending one. Untouched [faces](#g-face) (the names ports
wear on their component's boundary) survive, and re-staged faces take the newest
level. That is the per-face zero-order hold (ZOH). For a device's staging cell,
the CAS can fail only because a drain intercepted the old batch, so the retry is
bounded. The failure case is precisely correct as well. Intercepted writes are
already applied, and must not be re-staged. The [harness cell](#g-harness-cell) (the always-present
staging cell of the harness writer) is the exception to the single writer, since
several tasks may stage into it concurrently, and a CAS that fails because
another stager merged first retries the same way ([D-200][d-200]).

Merge is the *only* policy because it is always correct. A *complete* writer
covers every face in every batch it stages. A joystick delivering its full
write-set every poll is the type case. For such a writer merge and overwrite are
provably the same operation, which makes overwrite a degenerate fast path rather
than a second semantics. A *sparse* writer stages only what was touched. The GUI
and a JSON peer are sparse writers, and under overwrite they lose writes
silently instead. Under overwrite, a pending `flaps` edit is clobbered by an
unrelated `gear` message, undrained and undiagnosable. The worked example at the
end of this section works that hazard through. A user-facing overwrite opt-in
(`complete(binding)`) is closed ([D-104][d-104]).

#### The levels doctrine

The levels doctrine says that **staged values are levels, never deltas**
([D-024][d-024]), as in `press_count = 17`, never `presses += 1`. Levels are idempotent
and survive coalescing. Edge logic follows the levels doctrine, and button edges
ride as monotonic press counters, which devices stage. Accumulators (trim
offsets, flap detents) are model state, not mapping state ([D-045][d-045]).

#### Mappings and conditioning

**Mappings run on the device task** ([D-024][d-024]). Where FlightCore, the predecessor,
had `assign_input!(mdl, mapping, data)`, the framework has the pure
`map_input(data, mapping) → batch`. User-extensible code thereby never executes
inside the loop's frame, and the [trace](#g-trace) (the primary record of a session)
consists of root-input-level batches.

**Mappings are binding data, not shaping code** ([D-045][d-045]). A mapping is a
declarative table. It maps axis/button → root input, plus per-axis conditioning
parameters (deadzone, expo strength). The shipped `TableBinding` applies those
parameters in its generic `map_input` on the device task. `TableBinding` is the
shared pure helper, with an owner ([§11.6][s11-6]).

A rule about faces sets where conditioning belongs. **A face's meaning is
writer-independent** ([D-045][d-045]). Faces therefore carry *post-conditioning*
semantics. A GUI slider or a script writes the same command a curved stick
delivers, and running a mouse drag through a deadzone would be absurd. This
GUI-parity test is what places conditioning upstream.

Aircraft-semantic derivation must *not* ride along ([D-045][d-045]). A command fan-out
such as the illustrative `q_ref = q_sf · axis` is the case in point. It is
flight control system (FCS) design and lives in-model, in the avionics.

The trace records post-conditioning levels. Those are exactly what the model
consumed, so [replay](#g-replay) (the ordinary loop, its drain reading the trace) is exact.
**The raw stick levels are the known, accepted loss** ([D-380][d-380]). Re-running a session through
*different* curves is impossible.

#### The staged representation

**The staged representation is fixed per attachment, compiled at attach**
([D-104][d-104]). An enumerated writer's [claim](#g-claim) set (the faces a device *may* write) and
root-input types are both known at attach, because `claims(binding)` ([§11.6][s11-6]) is
read against the root [contract](#g-contract) (the root component's declared interface). So the
framework fixes the staging cell's content type there. **The content type is a
pair of positional tuples over the claim set** ([D-202][d-202]). One is a values tuple,
concretely typed `Tuple{T₁, …, Tₙ}`, and the other a parallel `Bool`
touched-mask. A set mask position means *staged this time*. A clear one means
*not touched*, never "reset". Untouched positions carry placeholder values and
are never read. The mask guards every consumer, so no placeholder ever reaches
the model. The batch is therefore isbits with one concrete layout per writer.
The levels doctrine is untouched, and root inputs only ever receive masked
positions. The writer's [roster](#g-roster) entry, its record in the list of attached
devices, holds the face-name → position schema ([D-104][d-104]).

In sketch form:

```julia
# claim set enumerated f₁ … fₙ; Tᵢ = declared type of the root input behind fᵢ

# attach fixes the cell's content type — values and mask, both concrete:
values :: Tuple{T₁, …, Tₙ};  mask :: NTuple{n, Bool}

# stage!, on the device task: the shim turns the author's face ⇒ value pairs
# into `incoming` — name → position, convert to Tᵢ, set the mask

# staging merges into the pending batch, newest wins per face:
merged.values[i] = incoming.mask[i] ? incoming.values[i] : pending.values[i]
merged.mask[i]   = incoming.mask[i] | pending.mask[i]

# the drain scatters, unmasked positions skipped:
batch.mask[i] && (the root input at position i receives batch.values[i])
```

One concrete layout is what makes the frame-top drain compilable. The
alternative carrier, `Union{Nothing, Tᵢ}` per face with the marker riding in the
value, has no such layout. Tuple types are covariant, so each combination of
touched faces is its own concrete type, and applying a batch would specialize at
frame top on which faces it touched ([D-202][d-202]). The mask buys the layout back at
the price of dead placeholders. Those are filled from the declaration's [probe](#g-probe)
values (the real values the build evaluates each user function with), which are
constructible for every declared type and unreachable behind the mask guard.

The consequences are each mechanical. The merge is positional and mask-driven
(the sketch above), so it compiles straight-line, leans on no small-tuple
heuristic, and does not degrade with surface width ([D-202][d-202]). The drain applies
each staging cell through an attach-compiled *scatter*, which maps position →
root-input cell, statically typed, with masked-off positions skipped ([D-104][d-104]).
That scatter is the exact mirror of the compiled output gather ([§11.2][s11-2]).

Authors never build the shape by hand. `map_input` returns face ⇒ value pairs
for whatever the datum touched, and `stage!` normalizes those pairs through an
attach-compiled shim ([D-104][d-104]). The shim does three things. It maps name to
position, converts to the root input's declared type, and sets the mask. It
thereby confines the residual name-shaped dynamism to one framework-owned
conversion on the task that stages, at the point where wire-shaped data becomes
system-shaped data. Author-built total tuples are rejected as a padding form,
the same disease [D-074][d-074] and the handler return law refuse ([D-104][d-104]).

A device with a [greedy claim](#g-greedy-claim) (the unclaimed complement, computed by the
framework) needs no special treatment here ([D-174][d-174]). Its claim was computed at
the attach point, and by the time shapes are compiled it is an ordinary claim
set ([§11.3][s11-3]). The GUI's staging cell is compiled exactly as a joystick's.

The harness cell gets the same treatment ([D-174][d-174], [D-370][d-370]). Under the [roster freeze](#g-the-freeze)
(attach and detach as stopped-sim operations) its derived surface, the unclaimed
complement, is as static as any claim set, so it too is compiled to a positional
shape. That shape is recompiled at each `attach!`/`detach!`, both stopped-sim
points, and it carries the same shim, merge and scatter. Being always present,
the harness cell gets the compilation unasked. It is also the one staging cell
whose shape the framework derives rather than receives.

All staging cells share one representation and one mechanism. The name-keyed
dynamic path does not exist, and no face name is ever resolved inside the loop's
frame.

The recompilation has one edge case. A pending harness batch staged *before* a
stopped-sim `attach!` may hold the old shape, or may name a face the new claim
covers. The attach renormalizes that batch. It is reshaped, and newly-claimed
faces are discarded with `ClaimedFaceEntry`. So the run always starts with
staging cells matching the run's schemas.

#### Diagnostic sites

Diagnostic sites follow the compilation, every one of them to staging ([D-044][d-044]).
Face-name validity, surface membership and value convertibility are all static
facts of the run. Every check therefore runs in `stage!`'s normalization, on the
writer's own task. A device's out-of-claim face has no position in the schema
and is rejected with `OutOfClaimEntry`. Staging is an earlier, better-attributed
site than the drain for that rejection, and the kind and [payload](#g-payload) (the structured
data a diagnostic carries beside its kind) are the same either way. The GUI is
included, its claim being an ordinary one. A *harness* write to a claimed face
is rejected the same way, with `ClaimedFaceEntry` naming the incumbent device
([D-174][d-174], [D-370][d-370]). And a value that cannot convert to its root input's declared
type is discarded with `EntryTypeMismatch` ([Appendix C][sC], [D-105][d-105]), at the same
spot.

Nothing remains at the drain. With surfaces frozen for the run, there is no fact
only the drain can know, and the drain is pure application ([D-106][d-106], [D-044][d-044]).

#### The drain

At frame top **the drain takes each device's staging cell with one
`atomicswap(cell, nothing)`** ([D-024][d-024]). The swap is an indivisible take, so there
is no lost-write window. Each taken staging cell is then applied through its
compiled scatter, in attachment order ([D-024][d-024]), the harness cell last ([§11.3][s11-3]).
Attachment order is retained as a deterministic application order. Under
root-input exclusivity, cross-device writes to one root input cannot arise, so
the order matters only for diagnostics ([D-044][d-044]).

Which *frame* a write lands in remains wall-clock reality. **The drain makes
the frame's outcome a pure function of the drained batches** ([D-379][d-379]).

Because the roster is a fixed value at `run!`, the drain is fully compilable
([D-106][d-106], [D-374][d-374]). The staging cells and their scatters form a heterogeneous but
*known* tuple the frame function can specialize on, which means zero dynamic
dispatch at frame top. That is the same per-configuration compile trade the
[executor](#g-executor) (the compiled form of the stage execution order, [§9.7][s9-7]) already makes,
now incurred only at stopped-sim attach points. The specialization is an
implementation freedom the freeze creates, not an obligation ([D-106][d-106], [D-374][d-374]).
Iterating a roster array costs a handful of dispatches per frame and remains
acceptable.

Two shapes were rejected, per-input atomic cells and a shared lock-free batch
stack ([D-024][d-024]). The worked example below examines both.

#### Worked example: filter, joystick and GUI

This worked example is the exercise that selected per-device cells. It produced
two things for [§11.7][s11-7]: the active-widget contract, which [§11.7][s11-7] rejects ([D-026][d-026]),
and the [port](#g-port)-resolution answer to panel reuse. A port is the addressable unit of
the model. The setup is a first-order filter with root inputs `u_cmd` and `τ`, a
fictitious 100 Hz single-axis joystick streaming a slow ramp onto `u_cmd` (a
complete writer), and a 60 Hz GUI with sliders for both root inputs (a sparse
writer). [Boundaries](#g-boundary) (published consistency points, where [snapshots](#g-snapshot) go out) run
at 50 Hz, at pace 1. The interference on `u_cmd` is the point.

Three candidate staging shapes were on the table: *per-input cells*, a shared
*batch stack*, and *per-device cells*. The user-level listing came out identical
across all three, so ergonomics cannot discriminate between them. Behavior under
a concrete interleaving did.

Root-input exclusivity rules out the very contest the setup builds. Under
root-input exclusivity ([§11.3][s11-3]) the contested-`u_cmd` scenario cannot arise,
because a second writer on `u_cmd` is an attach-time error. What the test
settles is therefore the cell *shapes*: atomicity, coalescing, pause behavior
and the [peek](#g-peek) rule (a widget shows its own pending write if any, else the
snapshot value). Its conflict-precedence comparison and the active-widget
stage-every-pass contract ([§11.7][s11-7]) describe a contested-input world the design
does not have. The findings below are read under that scope.

- *Drag against the stream.* The user grabs the `u_cmd` slider while the
  joystick streams. Under per-input cells and the batch stack, each frame's
  conflict resolves by last-store/last-push wall-clock order ([D-024][d-024]). With 16.7
  ms renders against 10 ms polls, the applied input alternates between drag
  value and ramp on the cadence beat, the filter visibly wobbles, and the
  pattern differs run to run. The trace replays any given run exactly, but the
  behavior is still a timing artifact. Under per-device cells the GUI stages in
  every drag frame, since it renders at least once per 20 ms frame and the
  active-widget contract stages on every pass. The GUI therefore wins every
  drain by attachment order. That win is a clean, deterministic override for
  exactly the grab duration. The same user code gives qualitatively different
  physics.
- *Edits while paused.* Under per-input cells, the still-polling joystick
  overwrites the user's `u_cmd` edit about 10 ms later ([D-024][d-024]). The knob visibly
  snaps back and the edit never applies. Under the batch stack, the edit is
  buried under newer pushes, and the pending chain grows at the polling rate,
  about 10³ nodes per 10 s pause, with every peek walking that chain ([D-024][d-024]).
  Under per-device cells, the `u_cmd` edit holds in the GUI's own cell across
  the pause, and the knob keeps the edit by the [§11.7][s11-7] peek rule. That edit
  merges with the `τ` edit, which is the sparse-accumulation case, and applies
  at the un-pause drain. It holds for one deterministic frame before the
  joystick reclaims the root input. That one-frame application is the honest
  semantics of one-shot editing a streamed input. The uncontested `τ` edit works
  under all three shapes.
- *Corrections the exercise forced.* The sparse-writer lost-write hazard is
  specific to one-cell-per-device layouts. Per-input cells cannot lose
  independent-input writes, so the CAS merge is per-device cells' antidote, not
  a general need. And the batch stack's conflict order is temporal, not an
  attachment-order policy ([D-024][d-024]).
- *Discoveries.* There were two: the active-widget contract, and the
  port-resolution answer to panel reuse ([§11.7][s11-7]). The second came from asking how
  the filter's panel survives the filter becoming an embedded [component](#g-component) (a unit
  of modeling) with `u_cmd` driven by another component.

### 11.5 Inbound: the input trace

The input [trace](#g-trace) is the sequence of [drained](#g-drain), [device](#g-device)-tagged [batches](#g-batch) per [frame](#g-frame). A
device is any attached participant in the periphery, and a batch is its staged
set of writes. A frame is one iteration of the loop, from drain to publication.
The drain is the frame-top swap that applies staged device writes to the root
inputs. The trace extends the determinism ([§10.7][s10-7]) end-to-end. [Replay](#g-replay) re-runs the
ordinary loop on a recorded input trace. Replaying a recorded interactive
session reproduces the trajectory bit-identically ([§2.4][s2-4]), with staging fed from
the recording, so no device or mapping feeds the inputs ([D-218][d-218]).

#### The record format

**The trace retains every batch sparse, in one record format** ([D-176][d-176]). At the
drain each drained [staging cell](#g-staging-cell) is scanned. A staging cell is the per-device
holding place where a device's pending batch waits between drains. Its masked
(touched) batch entries are recorded as (position ⇒ value) pairs, against the
writer's [face](#g-face)-name → position schema in the `schemas` list (below). A face is
the name a port wears on its [component](#g-component)'s boundary. A component is the unit of
modeling, a leaf or an assembly. The recording is an O(surface-width) scan and
one small allocation per drained batch, plus the values boxed into that
allocation.

The rule is uniform because the *width* of a [claim](#g-claim) (the set of faces a device
*may* write) is a fact about one [binding](#g-binding), not about a category of writers. A
binding is the value passed at `attach!` that makes a device framework-legible.
A [greedy claim](#g-greedy-claim) is the unclaimed complement the framework computes at attach
([§11.3][s11-3]). It is enumerated and as wide as the root [contract](#g-contract) (the root's declared
interface), so keying retention by claim source is rejected ([D-176][d-176]). Every
consumer then handles one format instead of two. There is one record format at
the trace's edge, no per-record format flag, one decoder in the edited-inputs
what-if (replay with edited inputs), in disk serialization and in human
inspection, and one inverse conversion in replay. That work is paid once, up
front, off the loop ([§12.7][s12-7]). The conversion site is the drain and not the
staging shim, because the drained tuple is the *coalesced* truth. A shim-side
sparse log would need its own merge.

The format's costs are recorded rather than argued away. On the wide writers the
conversion is what keeps the trace honest. A tuple as wide as the unclaimed
surface carrying one edit would otherwise make trace size track surface width
rather than information. At hundreds of faces, render-rate dragging would
inflate the trace past the two-orders-below-the-log budget that justifies
trace-on-by-default ([D-029][d-029]). On the dense component the conversion costs about
2×, a position beside every value where the positional tuple carried the value
alone. That changes no order of magnitude, and it leaves the budget ([D-029][d-029])
standing for every writer at once.

The allocation is of the same sort the retention carve-out ([§9.8][s9-8]) already
admits. Per [boundary](#g-boundary) (a published consistency point) it is smaller than the
[log](#g-log)'s [snapshot](#g-snapshot). The log is the retained sequence of published snapshots. A
snapshot, the immutable per-boundary publication, is the carve-out's standing
occupant and the one qualified exception to retains-what-was-already-allocated.
The decision is reversible as pure implementation. The conversion is lossless in
both directions, so verbatim retention could return as a per-record storage
optimization if a marathon-session measurement ever asks for it. Such a return
would leave the record semantics, the header and the replay path exactly as they
are.

#### The header

The [trace header](#g-trace-header) is the trace's fixed preamble. A [checkpoint](#g-checkpoint) is the `Model`'s
state at a frame top as one value. **The header is the checkpoint `init!` takes
at the end of [boundary zero](#g-boundary-zero)** (the initialization boundary at `t₀`), after the
first snapshot is published ([D-274][d-274]). A checkpoint holds the flat buffer
`x`, the `s` and `m` stores, the whole [signal table](#g-signal-table) (the collection of cells
holding every produced signal), the guard [priors](#g-prior), `t` and `t₀`, the frame and
boundary counters, and the fingerprint (the structural layout) and the
[deployment](#g-deployment) ([D-319][d-319]). The deployment is the scalar-free artifact the grid
parameters fix. A prior is an event's stored predicate sample from the previous
boundary. The [executor](#g-executor)'s clock holds `t` and `t₀`, and the [`Run`](#g-run) (the state one
run owns, a `Simulation` field) holds the frame index and the boundary ordinal
([D-317][d-317]). The executor is the compiled form of the stage execution order. The
header holds the stores and the cells of the [root inputs](#g-root-input) (the root component's
own input faces) as values, never the sparse authored overlay. Replay must
survive edits to declared defaults, the primary-data doctrine ([D-038][d-038]).

An illustrative unfed root input such as `mixture = 0.5` never appears in any
batch, so replay is broken without the root inputs ([D-047][d-047]). The init/trim
services own root-input initialization ([§14.6][s14-6]), and the checkpoint's table holds
the values they wrote. The fingerprint and the deployment are the parts of the
header replay compares rather than restores ([§12.7][s12-7]).

The deployment comes from [§9.2][s9-2]. It carries `Δt_base`, `h`, `N_base`, the
algorithm identifier, `localization_tol`, `localization_budget` ([§10.4][s10-4]) and
`firing_budget` ([§10.6][s10-6], [D-254][d-254]). The fingerprint is the store layout and the
root-input faces the [`Build`](#g-build) (the artifact `build(world)` produces) fixes. It
also holds what a copy by position relies on, namely each component's `x` type,
every cell's address with its type, and the event list in the order of the
priors. Both are taken at the same instant as the state. The deployment holds no
policy ([D-255][d-255]). `t_end` and `ignore_stop_requests` are keywords of each advance
([§12.6][s12-6], [D-316][d-316]). Only the terminating advance's policy explains the stop, so the
[termination record](#g-termination-record) (the stopped-sim value naming how the run ended) carries that
one.

The trajectory depends on the deployment exactly as it depends on the stores
([§2.4][s2-4]). The `Deployment` constructor ([§9.2][s9-2]) sits outside the `Build`, and the
checkpoint carries the clock, `t₀` included ([§14.5][s14-5]). A header without them could
therefore not back the bit-identity claim ([§2.4][s2-4], [§12.7][s12-7]). The header is also what
the artifact's [run metadata](#g-run-metadata) names, its `Deployment` and `t₀`
([Appendix B][sB]). A checkpoint is the one full-state capture, taken by `init!` for
the header and by `checkpoint(sim)` on demand ([§12.6][s12-6], [D-274][d-274]). The header is the
other half of what "given the initial state and the trace, the log is
recomputable" (below) requires.

#### The `Trace` value

**`Trace` is that fixed header plus two append-only lists**, `schemas` and
`batches`, and its length ([D-255][d-255]). A trace records a `Simulation`, which runs
only a `Model{Float64}`, so `Trace` takes no scalar parameter ([D-317][d-317]). The
header is written once, by the door that builds the run (`init!`, `restore!` or
`replay!`, [§12.6][s12-6]), and never again, which is what makes it an artifact. The
lists grow in place, the batches at every drain and the schemas at every change
to the [roster](#g-roster) (the immutable list of attached devices). The length is the frame
index of the last drain on the live trace ([D-217][d-217], [D-260][d-260]), frozen into the value
`trace(sim)` hands back. It advances at the top of each drain, and the frame
ordinal every record of that drain carries is this frame index ([D-260][d-260]). Under
`init!` that is the number of drains since the header was taken. A trace that
`restore!` opens starts at the checkpoint's frame, so its records keep the
trajectory's own frame indices ([D-274][d-274]). A recording whose last frames drained
nothing still ran them, and every advance in `:replay` is capped at the
recording's last frame ([§12.7][s12-7], [D-218][d-218]).

Each writer's face-name → position schema lives in the `schemas` list.
Positional records are meaningless without it, and replay does not reconstruct
claims ([§12.7][s12-7]). **The list only grows** ([D-217][d-217]). `attach!` and `detach!` push
the current writer set onto it in place ([D-255][d-255]). They do so because a roster
change between advances ([§12.6][s12-6]) recompiles the [harness writer](#g-harness-writer) (the
framework-owned write path `stage!(sim, …)`) and the same face moves position.
Earlier records keep their index, and a record resolves only through its own
schema entry.

#### Recording is on by default

**Trace recording is on by default** ([D-029][d-029]). `init!` builds a fresh trace with
the run under its `trace` keyword ([§12.6][s12-6], [Appendix B][sB], [D-261][d-261]), the trace is
retrievable after the run, and a plain kill switch covers memory-constrained
marathon sessions. The asymmetry that decides the default is that the trace is
*primary* data and the log *derived*. Header plus batches are the *primary*
record. Everything else, the state trajectory included, is derived ([§11.2][s11-2],
[D-038][d-038]). Given the initial state and the trace, the log is recomputable, which is
what bit-identical replay means ([§2.4][s2-4]). An untraced interactive session, by
contrast, is unreproducible, permanently.

The cost supports the default. The trace retains one small sparse record per
drained batch (above), at drain-rate × device-count. That is tens of MB per hour
worst case, two orders of magnitude below the snapshot log. There is no sampling
and no rolling window ([D-029][d-029]).

### 11.6 Devices: one authoring contract, no taxonomy

FlightCore's input/output/GUI trichotomy is lock choreography, not modeling.
With no lock, the protocol the taxonomy encoded has no referent ([D-025][d-025]). A
[device](#g-device) is an attached participant in the [periphery](#g-periphery) (everything outside the loop
that exchanges data with it). A device may be input-only or output-only, and
those are degenerate uses, not framework classes ([D-025][d-025]). A bidirectional
network peer is *one* device with one socket and one lifecycle, not two
framework devices sharing state. The GUI is an ordinary device, the paradigm
one, and it uses every capability of the handle below. Its one genuine
peculiarity, read-modify-write widgets, is not taxonomic ([§11.7][s11-7]).

#### The device handle

Every attached device receives the same handle. The handle carries the two
primitive capabilities, read and stage, plus control access (observe running,
request shutdown) ([D-025][d-025]). Read returns the latest [snapshot](#g-snapshot) (the immutable
per-boundary publication). It can optionally wait for the next [boundary](#g-boundary) (a
published consistency point) first ([§12.3][s12-3]).

Each attached device has a [roster](#g-roster) entry (its record in the list of attached
devices). **A handle outlives its roster entry as an object only** ([D-244][d-244]).
`detach!` retires the roster entry and the compiled writer behind it, but the
caller may still hold the handle `attach!` returned. Its two write primitives,
`stage!` and `report!`, then refuse by name (`DeviceContractMismatch`,
[Appendix C][sC]). A [batch](#g-batch) staged there would land in a [staging cell](#g-staging-cell) that no [drain](#g-drain)
reads. A report would land in a [diagnostic cell](#g-diagnostic-cell) that no [frame](#g-frame) top folds. A batch
is a device's staged set of writes. A staging cell is the per-device holding
place where a pending batch waits between drains. The drain is the frame-top
swap that applies staged device writes to the root inputs. A diagnostic cell is
each writer's bounded ring of diagnostics and its heartbeat. A frame is one
iteration of the loop. Silence is the hidden-bug class this section tolerates
nowhere. The read primitives stay legal, since they read the simulation's shared
state and nothing of the roster entry's ([D-244][d-244]).

#### The authoring contract

A device's type is a user type subtyping the framework's neutral root,
`MyDevice <: AbstractDevice` ([D-177][d-177]). That is one mandatory word, and it costs
nothing, because the periphery has no competing hierarchy to inherit from. What
it buys is `attach!`'s dispatch gate ([D-177][d-177]).

```julia
attach!(sim::Simulation, dev::AbstractDevice, new_binding::AbstractBinding;
        should_abort::Bool = false)
```

`attach!` takes the device with its [binding](#g-binding) (the value that makes a device
framework-legible, described below). Its keyword [`should_abort`](#g-should_abort) (the
per-attachment failure policy) is covered after the loop bodies below.

The framework asks for four functions.

```julia
init!(dev)          # per-run resource acquisition — calling task, before spawn (§12.4)
loop(dev, handle)   # the task body: owns its own wait structure
shutdown!(dev)      # per-run resource release — guaranteed on every exit path
unblock!(dev)       # make a blocked loop return (§12.4)
```

**Of the four functions, only `loop` is mandatory** ([D-366][d-366]). `init!`,
`shutdown!` and `unblock!` are optional hooks, each defaulting to a no-op.
`attach!` refuses a device with no `loop` method (`DeviceContractMismatch`,
[D-216][d-216]).

The framework owns everything around the four functions ([D-102][d-102]). The wrapper is
the shutdown protocol ([§12.4][s12-4]) made structural.

```julia
init!(dev)                                   # its own bracket, pre-spawn (§12.4): a throw
                                             # here is shutdown! + DeviceCrash by name
task = Threads.@spawn try
    loop(dev, handle)
catch e
    report!(entry, DeviceCrash(e))           # §12.4(6): sim continues, device absent
finally
    shutdown!(dev)                           # any exit path: OS resources released
                                             # no dead-marking: task_state shows the end,
                                             # claims stay, §11.3
end
```

#### What `shutdown!` must tolerate

**`shutdown!` must tolerate a partially initialized device** ([D-138][d-138], [D-372][d-372]). The
release guarantee holds on the one path *outside* this wrapper too. The
initialization step ([§12.4][s12-4]) brackets each `init!` ([D-138][d-138]). A device that threw
half-way through acquisition goes straight back to `shutdown!`, so nothing it
did manage to open is leaked. The obligation that follows is "close only what is
open". That is the same defensiveness `shutdown!` already owes the crash path,
where a loop body may die at any point in its own life. `init!` is
correspondingly *not* asked to clean up after itself. The bracket does once, for
every device, what would otherwise be duplicated in each and enforced in none.

**The same tolerance covers a repeated call** ([D-268][d-268]). The wrapper runs
`shutdown!` once on every exit path. When an [operator interrupt](#g-operator-interrupt) (Ctrl-C in an
interactive session) reaches `run!` before its tail, `run!` releases directly,
not through a wrapper, each device it never spawned, advancing a cursor after
each `shutdown!` returns, and retries from where an interrupt cut it ([§12.4][s12-4],
[D-268][d-268]). An interrupt landing between a `shutdown!`'s return and the cursor's
advance repeats that call rather than leak the device, so each such interrupt
adds one call. A `shutdown!` that closes only what is open is idempotent by
construction, so a repeated call costs nothing and is never reported.

**The tolerance also covers a call with no `init!` before it** ([D-268][d-268]). The
initialization step lists each device for release before its `init!` begins, so
that no interrupt can leave an initialized device unlisted ([§12.4][s12-4], [D-268][d-268]). An
operator interrupt landing between the listing and the `init!` therefore
releases a device that opened nothing. A `shutdown!` that closes only what is
open does nothing there, and the call is never reported.

#### The operator interrupt

The wrapper spares two raises a crash report. One is the raise a device's
`unblock!` provokes in the tail, which is shutdown ([§12.4][s12-4](3), [D-402][d-402]). The
other is the operator interrupt. **An `InterruptException` is never a
`DeviceCrash`** ([D-132][d-132]). The operator interrupt is a control-plane stop, not a
failure ([D-132][d-132]). The wrapper forwards the control-plane stop. There is no crash
report for what is not a crash, and no `should_abort` consultation, since a stop
is already requested.

#### The author-owned loop body

One device contract means author-owned loop bodies. A framework-owned hook loop
would have to ask each device what it waits on, which is the rejected taxonomy
resurrected as a trait ([D-102][d-102]). Under the author-owned body, every wait
structure is ordinary user code composed from handle primitives. In the
sketches, `T16000M` is FlightCore's type for the Thrustmaster T16000M joystick,
and `UDPInput` is FlightCore's UDP input device type. `Telemetry` is an
illustrative output device type. The sketches map data through the binding's
`map_input` and `map_output`, described below.

```julia
function loop(dev::T16000M, handle)              # timer-driven, full write-set
    while running(handle)
        sleep(dev.Δt_poll)
        stage!(handle, map_input(poll_axes(dev), binding(handle))...)
    end
end

function loop(dev::UDPInput, handle)             # source-driven, data-dependent
    while running(handle)
        datum = recv(dev.socket)                 # blocks; unblock! closes the socket
        is_eot(datum) && return                  # voluntary exit
        try
            stage!(handle, map_input(datum, binding(handle))...)
        catch e
            is_datum_error(dev, e) || rethrow()  # a bug → wrapper → DeviceCrash
            report!(handle, MalformedDatum(e))   # garbage → visible, bounded, alive
        end
    end
end

function loop(dev::Telemetry, handle)            # boundary-driven output
    while running(handle)
        snap = wait_next_snapshot(handle)        # §12.3; returns on stop
        send(dev.socket, map_output(gather(handle, snap), binding(handle)))
    end
end
```

A bidirectional peer composes both halves itself, with an inner reader task
inside its own domain, rather than forcing a select engine into the framework.
Two idioms are author obligations the framework can only teach and diagnose,
never force ([Appendix A][sA], [D-102][d-102], [D-373][d-373]). The author must loop on
`running(handle)` and must make blocking calls interruptible (`unblock!`, or
timeouts). A forgotten predicate check surfaces as `DeviceJoinTimeout` with the
device's name. A stall surfaces as a stale heartbeat ([§12.2][s12-2]). Liveness
timestamps ride *inside* the handle primitives, which store them in the device's
own diagnostic cell ([§11.8][s11-8]), so the framework observes activity without owning
the loop.

FlightCore's device hook **`should_close` dissolves** ([D-102][d-102], [D-373][d-373]). A window ✕
or peer EOT is the loop body returning, which is [§12.4][s12-4](6)'s case. The wrapper's
exit path releases the device's OS resources and consults `should_abort`.
Nothing marks the device dead beyond its record. The task has ended,
`task_state` ([§11.8][s11-8]) says so at the next publication, and its heartbeat goes
stale ([§12.2][s12-2]). A device's [claim](#g-claim) is the set of [faces](#g-face) (the names ports wear on
their component's boundary) it *may* write. Claims and the roster entry persist
to run end (the freeze, [§11.3][s11-3], [D-106][d-106], [D-374][d-374]). The GUI implements the same
authoring contract.

#### The failure policy

**`should_abort` is an `attach!` keyword**, defaulting to `false` ([D-138][d-138],
[D-177][d-177]). **It is per-attachment, never a device property** ([D-381][d-381]). The same joystick is
advisory in one deployment and decisive in another. With `should_abort` clear, a
device's departure is reported and the run continues without it. With it set,
that departure also requests a sim stop ([§12.4][s12-4]). A departure is the loop body
returning, a crash, or a failed `init!`. A hardware-in-the-loop rig attaches its
plant interface with it set, since a run without that device is meaningless.

#### Bad datum versus bug: two classes, two fates

A datum that cannot be mapped for environmental reasons (a truncated datagram,
malformed JSON, an out-of-range field) is a [bad datum](#g-bad-datum), tolerated *in the loop
body* ([D-105][d-105]). The body catches it, stages nothing, calls
`report!(handle, MalformedDatum(cause))` and continues. That tolerance is
bounded by the device's own diagnostic cell (the ring and suppressed counts,
[§11.8][s11-8]; the stream, [§13.2][s13-2]), and what it records is visible next to a live
heartbeat. Any other exception propagates, and the wrapper turns it into
`DeviceCrash` ([§12.4][s12-4]).

The classification is the author's, because only they know their parser.
FlightCore's `InputMappingError` docstring assigned it the same way. What
changes under the author-owned loop is that no framework per-iteration catch
site exists, so the framework's contribution is the diagnostic channel, not the
catch. A marked exception type is not provided ([D-105][d-105]). `report!(handle, …)`
writes device-attributed runtime warnings into that device's diagnostic cell,
the single-writer entry point into the runtime warning stream ([§13.2][s13-2], [§11.8][s11-8],
[D-160][d-160]), and nothing more. It is not a general user-diagnostics channel.
Tolerating everything hides bugs as "device attached, nothing happens".
Tolerating nothing kills a live telemetry link on its first truncated datagram,
and since tasks are per-run artifacts ([D-093][d-093]), kills it for the rest of the run.

#### The binding

A binding is a value subtyping `AbstractBinding`, the second mandatory root. Its
type declares which sides it has and enumerates what each side touches. A
binding is framework-legible by enumeration and opaque in its mappings. The
legible half is explicit methods returning data, called once at attach on the
[calling task](#g-calling-task) (the task that invoked `run!`). The opaque half is called per datum
on the device task by the author's own loop:

```julia
struct T16000MBinding <: AbstractBinding    # the roots are mandatory: attach! dispatches
    table::NamedTuple                       # on ::AbstractDevice, ::AbstractBinding
end

is_input(::T16000MBinding)  = true     # sides are *declared*, never inferred; the root
is_output(::T16000MBinding) = false    # carries the false defaults, so silence = absent
is_greedy(::T16000MBinding) = false    # the claim source within the input side (§11.3)

claims(b::T16000MBinding)   = ...      # input side:  the enumerated face set → the claim
map_input(datum, b)                    #              datum → face ⇒ value pairs — user code
reads(b)                               # output side: labeled §14.4 selectors → one compiled gather
map_output(nt, b)                      #              the gather's NamedTuple → wire datum
```

The root carries `is_greedy(::AbstractBinding) = false` beside the two side
defaults, so silence is not greediness ([D-177][d-177]). A [greedy claim](#g-greedy-claim) is the unclaimed
complement computed at attach. The computed claim source (the greedy one, [§11.3][s11-3])
is declared or absent.

**A side trait is a declaration, not a computation** ([D-382][d-382]). It returns a
literal, or a flag read off a field fixed when the binding is constructed. One
`attach!` reads each trait more than once, and the conformance check described
below holds only if every read agrees.

The framework needs no contract on the datum's shape. The datum travels only
between `loop` and `map_input`, written by the same author. The framework's
structural knowledge comes entirely from the declared traits and the enumeration
methods. Everything enumerable validates at attach. Everything opaque is bounded
at its runtime enforcement point. `map_input` is bounded by the staging checks
([§11.4][s11-4]). `map_output` receives exactly the compiled gather's NamedTuple, and
what it puts on the wire is the peer's business. **`map_input`/`map_output` are,
precisely, conventions of the author-owned loop idiom** ([D-177][d-177], [D-382][d-382]). The framework
never calls them, so they are taught ([Appendix A][sA]) and never checked. A binding
whose loop calls something else by another name is simply a binding with a
different private helper.

**`reads(b)` returns a labeled NamedTuple of [selectors](#g-selector)** ([D-199][d-199]). Selectors are
the closed family of deferred reads ([§14.4][s14-4]). An example is
`(; alt = get_output(…), pose = get_face(…))`. The labels are the binding's own
naming, carried through compilation in declaration order, so the NamedTuple
`map_output` receives is keyed by exactly the names `reads` declared. One
returned value thereby fixes names, order and reads together, under the same
attach-time validation as `claims` ([D-199][d-199]). **The read set resolves at
the root, with no mount** ([D-406][d-406]). A path selector's path is absolute,
and a face selector names a root input or a root-exported face.

The periphery gets roots where [components](#g-component) (the units of modeling) have one. [§8.5][s8-5]
refuses a supertype for [class](#g-class) (a component's primitive-vs-assembly status) for
two reasons, and neither reaches here. First, a component's single-inheritance
slot is *already spoken for* by the domain hierarchies (`AbstractAircraft`,
engine families), while a device's and a binding's are vacant. Nothing else
wants them. Second, a component's class is implementation detail behind its
contract ([§8.5][s8-5]), while a binding's sidedness is its public contract, the one
thing every consumer of it must know ([D-177][d-177]).

#### The conformance check

**Sides are declared, and the obligations they create are enforced both ways**
([D-177][d-177], [D-371][d-371]). `claims` and `reads` have error-throwing fallbacks on the root.
A declared side whose method was never written therefore fails loudly at the
attach point rather than degrading into silence. The attach runs a bidirectional
conformance check over the pair (trait, method):

- `is_input && !is_greedy` ⇒ `claims(b)` is called once and its faces staked.
  The fallback firing here means "you declared an input side and wrote no
  enumeration".
- `is_input && is_greedy` ⇒ the claim is computed ([§11.3][s11-3]), and a `claims` method
  defined for this binding is an error. The two sources are alternatives, not
  layers.
- `is_output` ⇒ `reads(b)` is called and the gather compiled.
- Neither side declared ⇒ attach-time error naming both traits. A binding that
  touches nothing is a configuration mistake, not a degenerate.
- `is_greedy` without `is_input` ⇒ error. Greediness is a *source* within a
  side, and a source without its side is meaningless.
- A *specific* method of `claims` or `reads` defined for the binding type while
  its trait reads false ⇒ error, the converse direction of the same fact. A
  method written and never reached is exactly the drift the check exists to
  catch. Detecting it is one `which` against the fallback method. It is a
  reflection check like the shadowing check of [§8.1][s8-1], an `isdefined`/`!==` pair.
  The `which` detection runs once at a stopped-sim service point, not inside any
  frame.

Every violation in that list reports `BindingContractMismatch` ([Appendix C][sC]). The
report names the binding type, the trait, the method at fault and the direction
(declared-but-missing, or defined-but-undeclared). `gather` against a binding
with no output side reports `DeviceContractMismatch`, the device twin of
`BindingContractMismatch` ([D-216][d-216]).

Declared sides, checked both ways, close the shadowing hole. Under the rejected
alternative, detection by method presence ([D-177][d-177]), a bidirectional binding whose
`claims` was written without extending the framework's generic presented as
output-only and degraded *silently*. That omission is the
`using`-without-`import` trap ([§8.1][s8-1]), one level down. With the side declared,
the absent method has something to contradict. An abstract binding-type
*taxonomy* encoding the sides, optional roots left unenforced, and a declared
`sides(b)` trait returning the side set are rejected ([D-177][d-177]).

#### Greedy claims

`is_greedy` is a claim source, not a device class ([D-174][d-174]). A binding declares
that source in exactly one line, in the open, and past the attach point nothing
tells a greedy claim from a returned one ([§11.3][s11-3]). The standing rejection of
opportunistic writing to unclaimed faces "for any device" is untouched ([D-044][d-044]).

Greediness stays orthogonal to `reads`. A greedy front end may also drive a
compiled output gather. That combination is legal and currently uninstantiated.
Its plausible customer is a narrow-wire interactive surface, a motorized control
board whose detents must be driven back out. The binding stays an `attach!`
argument, never a device field. The same `T16000M` binds differently per
aircraft, and narrowing the binding narrows the claim ([§11.3][s11-3]).

**A second greedy attach stakes the empty remainder** ([D-174][d-174], [D-370][d-370]). The
complement is computed against the roster as it stands. A greedy binding
attached after another has already swallowed everything therefore gets the empty
claim. That claim is legal, being the honest may-write-nothing degenerate below,
and it is useless, which is worth saying out loud. The attach succeeds and
records `EmptyGreedyClaim` ([Appendix C][sC], a warning naming the device and its
binding) in the roster entry's diagnostic cell. `attach!` mutates the roster, so
the warning lives in that state's status and surfaces through the status record
([§11.8][s11-8], [D-250][d-250]). The log line at return is presentation. That is the one honest
reading of "you asked for what is left and nothing was left".

**Several interactive front ends may be rostered at once** ([D-174][d-174], [D-370][d-370]). A web
console can claim the autopilot faces beside a local GUI claiming the stick
faces. With explicit claims they are simply two enumerated devices, partitioning
the surface rather than sharing it.

The standard GUI binding is a greedy one. It declares `is_input` and
`is_greedy`, stakes the computed claim (everything unclaimed at the moment it
attaches), and defines no `claims` of its own. It declares no `reads` either,
because its read path is the handle's primitive read. The compiled output gather
therefore has nothing to do for it. The same GUI device type is equally
attachable under a binding that returns explicit claims. Greediness is the
binding's declaration, not the device's nature. Every other interactive front
end anyone might want (a web console, a remote panel) has both spellings
available. It can attach with the greedy binding where the GUI would have been,
or with explicit claims beside other front ends.

#### The empty enumeration

The empty enumeration is not a back door. **`is_input(b) = true` with
`claims(b) = ()` stays an honest degenerate**, a device that may write nothing
([D-177][d-177], [D-371][d-371]). Its writes are still binding-bounded, so drift onto any face is
`OutOfClaimEntry` ([D-044][d-044]). There is no privileged category for it to promote
into either. `claims` bodies are ordinary code (the idiom, [§8.5][s8-5]; comprehensions
included), and an enumeration that came back empty by accident stays inert,
exactly as written. The maximal surface is reachable only through the explicit
`is_greedy(b) = true` declaration. The most privileged claim is the hardest to
acquire by accident, and a declared trait is deliberate authorship. For the same
reason, `claims` never returns `nothing` or a sentinel to mean "compute it for
me". The enumeration contract has one meaning and the trait carries the other. A
dual-meaning return would be exactly the ambiguity the declaration vocabulary is
built to refuse.

#### `TableBinding`

`TableBinding` is the one shipped binding type, and it is *data-driven* ([D-045][d-045]).
The framework writes its `map_input` once. A table value (axis/button entry →
face, deadzone/expo parameters) is constructed per device × aircraft pairing,
where configurations are made:

```julia
TableBinding(stick_y  = (face = "elevator", deadzone = 0.05, expo = 0.6),
             throttle = (face = "throttle",),
             trigger  = (face = "brake_count",))       # levels doctrine: a counter
```

A malformed table reports `ArgumentInvalid`, collected over the table's entries
([D-216][d-216]).

`TableBinding`'s generic `map_input` *is* the shared pure conditioning helper
([§11.4][s11-4]), and its owner. The entry tuple rides in the type, so the mapping
specializes per table with no dynamic dispatch. A *code-driven* binding looks
identical to the framework. A JSON telecommand peer whose `claims` returns the
vocabulary and whose `map_input` parses bytes is one. One purity note is taught
in [Appendix A][sA]. Cross-datum state, such as press counters and edge detection,
lives in the device struct, maintained by the loop, and arrives *inside* the
datum. `map_input` stays pure.

### 11.7 The GUI write path: port resolution, peek, staging contract

This section specifies how a GUI widget resolves its [port](#g-port) (the addressable unit,
one declared name) to the [root input](#g-root-input) (the root component's own input face)
behind it, when the widget is live, what it displays and when it stages, and the
framework's half of the panel convention.

#### Port resolution and derived liveness

Panels remain extensions per [component](#g-component) (the unit of modeling, a leaf or an
assembly) in FlightCore's style, such as `GUI.draw!(ctx, ::LowPassFilter)`. They
are discovered by walking the [assembly](#g-assembly) (pure composition, whose component-typed
fields are its children). However, **widgets name the component's own ports,
never root inputs** ([D-026][d-026]). The build-time wiring answers one question
statically and exactly. *Is this port transitively driven by a root input, and
which one?* Every input port has exactly one source ([§6.1][s6-1]), so the resolution is
total, with two outcomes.

- If the port is root-driven within the GUI's [claim](#g-claim) (the set of faces a device
  *may* write), its widget is live. It [peeks](#g-peek) (the GUI display rule, specified
  below) and stages the resolved root input through the GUI's own [staging cell](#g-staging-cell)
  (the per-device atomic holding place for pending writes).
- If the port is component-driven, or root-driven under the claim of another
  [device](#g-device) (any attached participant in the periphery), its widget is a read-only
  rendering. It displays the driven value from the [snapshot](#g-snapshot) (the immutable
  per-boundary publication), visually distinct, with its source ("driven by
  `avionics/throttle_cmd`", the canonical slash form of [§8.6][s8-6]).

This retires FlightCore's dead-slider convention and replaces it with checked
structure. **A widget is live exactly when the underlying input is yours to
command in this configuration** ([D-045][d-045]). The dead slider is the throttle of
`Cessna172Xv1`, the first variant of FlightApps' Cessna 172X model. The engine
panel's slider is visually live and the avionics silently overwrite it every
cycle, so who commands what lives in the user's head. User-commandability is a
wiring decision made where configurations are made. Command-plus-manual-override
is a mux component with a root-wired select. That is explicit structure, not two
writers racing (the same race as the drag phase in the worked example of [§11.4][s11-4],
ruled out the same way). This places one obligation on the GUI. Read-only
rendering is first-class, not an error state, because the author of
`input_slider!` (an illustrative widget function) cannot know at authoring time
whether it will be live ([D-026][d-026]).

Liveness is a [derived property](#g-derived-liveness) (the rule computing a widget's liveness from
wiring and claims), and resolution is transitive ([D-045][d-045]). A widget is live iff
two things hold. Its port's feed chain terminates in a root input, *and* that
root input lies inside the GUI's own claim ([D-174][d-174], [D-370][d-370]) in the run's frozen
surface partition (root-input exclusivity, [§11.3][s11-3]). The feed chain is walked
through [local wires](#g-local-wire) (wires with both ends inside one assembly) and interface
connections across *all* levels, not just the local assembly. The claim may have
been computed from the unclaimed complement under `is_greedy`. It may instead
have been enumerated by a partial-claims [binding](#g-binding) (the value passed at `attach!`,
[§11.6][s11-6]). Such a binding enumerates the claim one [face](#g-face) (the name a port wears on
its component's boundary) at a time. Either way, "live" reads as "inside the
surface I declared for".

The [roster](#g-roster) (the list of attached devices, with their claims) is frozen for a
run, since `attach!` and `detach!` are stopped-sim operations ([§11.3][s11-3]). Under
that freeze, liveness is a static fact of the run. It is baked once, with the
port resolution, when the run starts, and never consulted against mutable claim
state at render ([D-270][d-270]).

There is no per-port "GUI-controlled" marking anywhere. The export chain is the
marking, written by the one author entitled to write it. A component's ports
become GUI-commandable exactly when the assemblies above surface them. The
switch between "driven by its own panel" and "driven by an external provider" is
therefore automatic. `World` is the example assembly of pure composition that
[§8.8][s8-8] introduces. At build time the switch follows the wiring archetype, where a
scripted `World` wires a [scenario component](#g-scenario-component) into the same faces the interactive
`World` exports to root. A scenario component is the home of a sim-time script.
At run start the switch follows roster claim state. Nominally-connected ports
with a GUI *override* channel are rejected ([D-045][d-045]). The honest cost stands.
**Unexported ports are unpokeable** ([D-045][d-045]). FlightCore's poke-any-`u` workflow
deliberately does not survive the visibility rule of the [contract](#g-contract) (the declared
interface of a component, [§8.3][s8-3]).

#### The peek and the staging contract

Under the peek rule, **a widget displays its own pending write if any, else the
snapshot value** ([D-026][d-026]). It peeks its own staging cell only. Another device's
pending write is invisible by design. Its applied value arrives via the snapshot
one [frame](#g-frame) (one iteration of the loop) later, and cross-device peek is rejected
([D-026][d-026]). While paused, staged edits display indefinitely and apply at the
un-pause [drain](#g-drain) (the frame-top swap that applies staged device writes to the root
inputs). Fan-out is consistent for free. Widgets on ports resolving to the same
root input peek the same pending value.

**Widgets stage on interaction events only** ([D-047][d-047]). This GUI staging contract
is [stage-on-interaction](#g-stage-on-interaction) (staging on edit or activation, never per render pass).
Value widgets (sliders, drags) stage the new absolute level on edit. Edge
widgets (buttons) stage on activation, as a level computed from the peek. A
flaps button peeks the current counter `k` and stages `k+1`. The levels doctrine
makes this safe by construction. Repeated staging of the same level within a
drain window is idempotent, so there is no repeat-increment hazard. Multi-click
within one window counts correctly through the own-pending-first peek (`k` →
stage `k+1`; second click peeks pending `k+1` → stages `k+2`). Held buttons do
not re-stage. After the drain applies and the snapshot catches up, re-staging
from the peek would auto-repeat at frame rate. The activation edge is the
intent.

The alternative, active widgets staging on *every* render pass, is rejected
([D-026][d-026]). Under root-input exclusivity ([§11.3][s11-3]) it has no motivation. As
insurance, staging every render pass would mask invariant violations at render
rate ([D-026][d-026]). As a side benefit, staging traffic (and trace noise) drops from
render-rate-while-grabbed to actual edits.

#### The orphan case

No claim-transition policy exists, because no claim transition can occur mid-run
(the freeze, [§11.3][s11-3]). The one liveness-adjacent display rule is the orphan case.
A read-only widget whose claiming device's task has died renders the fact in its
source label, such as "claimed by `T16000M` — task dead". `T16000M` is
FlightCore's type for the Thrustmaster T16000M joystick. The heartbeat is
surfaced in place ([§12.2][s12-2]). What the widget displays beside that fact is the
ordinary snapshot value, the orphaned root input's last drained level. An orphan
widget is a read-only rendering like any other, never a blanked one. An orphaned
root input is therefore visible where the user is looking, not only in the
status panel.

#### The framework's half of the panel convention

The panel convention has two halves. **The framework's half is fixed here, and
the GUI package's half is deferred** ([D-270][d-270]). A panel reaches the framework
through three values, a port view, the device handle and a snapshot. The port
view is this section's baked verdict, one per declared port of every component,
input and output. The handle supplies the two reads the peek composes and the
one write, `stage!`. The snapshot supplies every driven value and the writer
status the orphan label reads. Nothing a panel needs reaches into the loop
([D-270][d-270]). The block below lists four functions, and the paragraphs after it
specify each.

```julia
port_views(handle)
pending(handle, slot)
peek(view, handle, snapshot)
incumbent_status(view, snapshot)
```

**`port_views(handle)` builds one view per port of every component**, keyed by
`(path, port)`, from the build's wiring, the handle's claim and the exclusivity
index ([D-270][d-270]). A view carries the port's terminal producer (`("", face)` when
root-driven), the liveness verdict, the port's position in the handle's staging
schema when live, the producer's cell address, and the incumbent writer of a
root-driven port the GUI does not command. The GUI's loop body builds the table
once at its top. That point is after the roster freeze, so the incumbents are
the run's, and nothing at render resolves a name. The handle carries the build's
`Structure` and the nominal `Layout` by reference for this, the two things the
bake needs that the handle did not hold. An output port's view is read-only with
itself as producer, so a generated panel reads every face through one lookup.

| the port resolves to | live | slot | incumbent |
|---|---|---|---|
| a root input inside the GUI's claim | yes | its position | the GUI |
| a root input in another device's claim | no | none | that device |
| a root input no device claims | no | none | the harness |
| another component's port, or its own output | no | none | none |

**`pending(handle, slot)` reads the handle's own staging cell with one acquire
load and never takes it** ([D-270][d-270]). It returns `Some(value)` when the slot is
touched, else `nothing`. A staged batch is never mutated after it is published
into the staging cell, so the load sees a complete batch or none.
`peek(view, handle, snapshot)` composes that read with the snapshot. A live view
returns its own pending value when one is touched, and the producer's cell off
the snapshot otherwise. A read-only view skips the staging cell and reads the
producer's cell. Two ports resolving to one root input share slot and address,
which is the fan-out consistency above.

The peek rule has one visible consequence, and it is the rule's own. Between the
frame-top drain that takes the staging cell and the publication of that frame's
snapshot, a live widget finds nothing pending and shows the previous snapshot's
value, for at most one frame's compute ([D-270][d-270]). A click inside that window peeks
the old level and stages a level already drained, which the levels doctrine
makes idempotent. No device task reads the loop's store, so no reading is more
current than this one.

**`incumbent_status(view, snapshot)` returns the incumbent's writer record**
from the snapshot's status ([§11.8][s11-8]), or `nothing` for a port no device writes
([D-270][d-270]). On that record, `orphaned` is a task that returned or crashed, and
`stale` is the silent heartbeat ([§12.2][s12-2]). The record tells an exited loop from a
crashed one, and the label may. The label text is the GUI package's.

#### What stays deferred

The GUI package's half stays deferred, and `pending.md` (the record of what the
implementation still owes) tracks it. The built-in GUI's parking ([D-310][d-310]) assigns
it to the browser client over the bridge. The bridge is the link to the
simulation, and [D-310][d-310] leaves the bridge's design open. That half covers what the
client receives beside the three values, how a panel scopes to a child
component, and the widgets. Its constraints are fixed here. Panels name their
own ports by face-name string. Resolution to root inputs and the liveness
verdict are baked at run start, never performed at render. Liveness and peek
arrive through the framework-supplied context, never by reaching into the loop.
And assembly panels compose children by path.

### 11.8 Diagnostics and liveness: the per-writer diagnostic cell

The chapter's two data channels are specified down to their memory ordering. The
runtime warning stream ([§13.2][s13-2]) and the liveness heartbeat ([§12.2][s12-2]) are a third,
and they cross between the same tasks.

#### Writers and readers

The diagnostics are written in these places.

- Whichever task stages writes `OutOfClaimEntry`, `ClaimedFaceEntry` and
  `EntryTypeMismatch` at staging ([§11.4][s11-4]). The staging happens on the task of a
  [device](#g-device) (any attached participant in the periphery). It can also go through the
  [harness writer](#g-harness-writer) (the framework-owned write path `stage!(sim, …)`, [D-200][d-200]).
- The device tasks write `MalformedDatum`, from the author's loop body via
  `report!(handle, …)` ([§11.6][s11-6]).
- The loop itself writes `DebtReanchor` and `UnboundedRun`.
- The [frame](#g-frame) (one iteration of the loop) that the loop runs writes
  `ChatteringBudget` and `FiringBudget` ([D-317][d-317]).
- `attach!` writes `EmptyGreedyClaim` as it adds a device to the [roster](#g-roster) (the
  list of attached devices, [§11.3][s11-3]). The value goes into the roster entry being
  created.

`attach!` mutates the roster, so its warning lives in the roster's status rather
than on an artifact ([D-250][d-250]). The device's task does not exist until `run!`, so
the new roster entry's [diagnostic cell](#g-diagnostic-cell) (a writer's own holding place for runtime
diagnostics) has no other writer yet.

The loop reads the diagnostics. It folds them into the published [framework
status](#g-framework-status) (the diagnostics value each snapshot carries, [§11.2][s11-2]). They hence reach
every [snapshot](#g-snapshot) (the immutable per-boundary publication). An unspecified
structure with those writers is exactly the arbitrary shared mutable state that
the two rules of [§11.1][s11-1] exist to eliminate. So the channel gets the mechanism
[§11.4][s11-4] already established, not one of its own.

#### One diagnostic cell per writer

**Each writer has one diagnostic cell** ([D-136][d-136], [D-200][d-200]). There is one per
rostered device, one for the harness writer and one for the loop itself ([D-200][d-200]).
The [`Model`](#g-model) (the deployment and its executor at one scalar) owns one more. Its
frame writes the chattering and firing-budget reports there. The [drain](#g-drain) (the
frame-top swap that applies staged device writes to the root inputs) folds that
diagnostic cell into the loop's account beside the loop's own ([D-317][d-317]).

A device's diagnostic cell, the loop's and the `Model`'s each have a single
writer, by the same ownership argument as the [staging cells](#g-staging-cell) (each device's
atomic holding place for pending writes). There is no locking, no arbitration
and no new primitive ([D-136][d-136]). **The harness writer's diagnostic cell is written
from whichever task stages**, exactly as its staging cell is, and the same CAS
(compare-and-swap) append arbitrates ([D-200][d-200]). It carries no heartbeat, and its
status record no `task_state`, because it has no task of its own to be alive or
dead. The loop's own record carries neither, for the same reason ([D-240][d-240], [D-193][d-193]).

A diagnostic cell holds a bounded accumulation and one atomic liveness
timestamp. The accumulation is a small ring of diagnostic values, capacity 16,
plus a count per [kind](#g-kind) (a diagnostic's identity in the closed set) of what the
ring could not hold ([D-136][d-136]). The rejected alternatives are in [D-136][d-136].

#### The bound and the drain

**The ring's bound *is* the rate limit** ([D-136][d-136], [D-369][d-369]). When a writer emits
past the ring's capacity within one frame, the value is not stored and its
kind's suppressed count increments. The drop policy retains the earliest in the
frame, and the excess becomes counts. The first occurrences are the ones with
diagnostic content, and the hundredth is noise the count already reports.
Rate-limiting "wherever its source can repeat" ([§13.2][s13-2]) is therefore not a policy
layered over the stream but a structural property of the channel that carries
it. A [chattering](#g-chattering) model (one exhausting its per-frame localization budget) or a
peer flooding malformed datagrams costs at most sixteen retained values and one
integer increment per kind per frame, whatever its source does. No writer can
starve another, because the diagnostic cells are disjoint.

**The diagnostic cells are taken at the same drain [§11.4][s11-4] specifies** ([D-136][d-136],
[D-369][d-369]). The loop performs one `atomicswap` per diagnostic cell at frame top, at
the same point and under the same indivisible-take argument as the staging
drain. What the loop swaps *in* is a shared *empty sentinel*, so a quiet frame
swaps the sentinel in and gets the sentinel back. That allocates nothing, and it
leaves no load-only code path that goes untested on healthy runs.

The take also makes publication sound. The binding rule says that nothing
reachable from a published snapshot is ever written again ([§11.2][s11-2]). Because the
taken ring is exclusively the loop's before it is ever reachable from a
snapshot, the binding rule holds by construction. The live accumulator is never
reachable from a published value.

#### The heartbeat

The heartbeat rides in the same diagnostic cell, as an atomic timestamp field
([D-136][d-136]). The device task stores it on every loop pass from inside the handle
primitives. That way the framework observes activity without owning the loop
body ([§11.6][s11-6]). **The loop acquire-loads the heartbeat at publication**, when it
assembles the status ([D-240][d-240]). There is no separate liveness channel and no
second registry. A device that is alive is a device whose diagnostic cell
carries a recent timestamp, and the 2 s staleness threshold ([§12.2][s12-2]) is read
against this field. The heartbeat is not a diagnostic kind. It is a field,
always present, never enumerated in [Appendix C][sC].

#### The published status

**The published framework status is a concrete frozen value** ([D-136][d-136], [D-369][d-369]).
Per writer it carries four things beside `who`. `recent` is the ring the frame's
drain took, carried by the first publication after that drain, at most sixteen
values per diagnostic cell it takes. The loop's record folds two, its own and
the `Model`'s ([D-317][d-317]). `suppressed` is the per-kind counts the ring refused in
that drain. `totals` is the cumulative per-writer × per-kind counts since the
run began, owned privately by the loop and *copied* into each status. And
`heartbeat` rides beside the `task_state` the loop reads off its own device
`Task` handle at publication ([§12.2][s12-2], [D-193][d-193]). Beside the per-writer records ride
the pacer diagnostics ([§10.7][s10-7]).

Each per-writer record has this shape.

```julia
struct WriterStatus
    who::String
    recent::Vector{DiagValue}
    suppressed::KindCounts
    totals::KindCounts
    heartbeat::Union{Nothing,Float64}
    task_state::Union{Nothing,Symbol}
end
```

`DiagValue` is any value of the kinds the channel carries, and `KindCounts` is
the per-kind counter record that the allocation rules below describe.

Delta plus total is what makes the status legible at any reading cadence. A GUI
panel refreshing at 60 Hz sees each occurrence once in `recent`, while a
consumer that samples occasionally still reads a complete account from `totals`.
Nothing is lost by not looking. The record's `who` is the only attribution a
value has, so a renderer presents each value under its record's writer ([D-228][d-228]).

#### Presentation

Presentation is where `maxlog`, the cap Julia's logging macros put on repeats,
lives. A status renderer prints a given writer × kind up to 25 cumulative
occurrences and then switches to count-only display ("`MalformedDatum` from
`UDPInput#3`: 1 482 occurrences"). **That threshold is presentation policy, not
channel policy** ([D-136][d-136], [D-369][d-369]). Counts keep accumulating regardless, nothing
recorded depends on it, and the choice belongs to whoever renders. The channel's
own bound, above, is the one that is normative.

#### The run's end

**The terminal snapshot carries the run's final cumulative counters** ([§12.4][s12-4],
[§13.5][s13-5], [D-136][d-136], [D-369][d-369]). An [unattended run](#g-unattended-run) (a run with empty staging and no
snapshot readers) that nobody watched therefore still answers "what went wrong,
and how often" from the value its own shutdown published. Final means final at
the last frame top ([D-201][d-201]). The account closes with the drain that preceded the
terminal publication. What lands after it can reach no snapshot. Examples are a
report from a device's exit path and the tail's own `DeviceJoinTimeout` ([§12.4][s12-4]).
So the loop takes each diagnostic cell once more at the run's end, keeping the
next run's account clean.

That last take is folded into the [termination record](#g-termination-record) (the stopped-sim value
naming how the run ended) as the tail residue ([§13.5][s13-5]). Per writer, the tail
residue is the final ring and its suppressed counts. The take is also presented
through the standard logging backend. It is loud *and* recorded, and still never
published ([D-201][d-201], [D-203][d-203]).

#### Allocation

**On a quiet frame nothing allocated scales with diagnostic activity** ([D-241][d-241],
[D-369][d-369]). The sentinel swap allocates nothing. **The per-writer status costs one
small vector of records per publication** ([D-241][d-241]), beside the snapshot
allocation per [boundary](#g-boundary) (a published consistency point) that [§11.2][s11-2] already
accepts. That is the same GC-over-reuse trade, a roster-sized vector rather than
a snapshot type per roster size ([D-241][d-241]).

**The per-kind counters are a fixed-shape isbits record, never a `Dict`**
([D-136][d-136], [D-369][d-369]). The closed kind set ([Appendix C][sC]) licenses that, because it makes
the counter layout a type rather than a lookup.

On a noisy frame the diagnostic values are allocated at emission, on the
writer's own task. A drained non-empty ring is frozen into the snapshot and can
never be written again, so the writer allocates a fresh ring lazily at its next
emission. That cost, too, lands on the writer's task, and it is the same
GC-over-reuse trade [§11.2][s11-2] makes when it rejects preallocated snapshot buffers.
The rate limit is therefore an allocation bound as well. One ring of sixteen
values per diagnostic cell per frame is the worst case, and everything past it
is an integer increment. The zero-allocation invariant, scoped to the stepping
loop ([§9.8][s9-8], [D-305][d-305]), is untouched. The diagnostic cells sit on the framework side
of that scope with publication and logging.

#### Composition with the log

Because the [log](#g-log) (the retained sequence of published snapshots) retains snapshot
references ([§11.2][s11-2]), `totals` is monotone across logged snapshots. `log_every`
[decimation](#g-decimation) (the log's keep-every-kth retention policy) therefore loses *which*
boundary within a skipped stretch an occurrence fell on, never *how many*
occurrences there were.

---

## 12. Runtime periphery: lifecycle and orchestration

This chapter specifies the machinery that drives the loop itself, taking the
loop of [§10][s10] and the data plane of [§11][s11] as given. [§12.1][s12-1] covers the control plane;
[§12.2][s12-2] loop scheduling, in turn its wait primitive, its yields, the thread budget
and the liveness heartbeat; [§12.3][s12-3] the next-snapshot wait; [§12.4][s12-4] the shutdown
protocol; [§12.5][s12-5] scripts and the mid-run mutation doctrine; [§12.6][s12-6] the run
lifecycle from `init!`, and partial advance; and [§12.7][s12-7] replay, where the trace
re-drives the ordinary loop.

### 12.1 Control plane

Pause, un-pause, pace changes, `margin` changes and stop are a few fields on a
separate atomic surface, the [control plane](#g-control-plane). It is not staging, structurally
([D-022][d-022]). Staged writes apply at [drains](#g-drain) (the frame-top swaps that apply staged
device writes), and a paused loop drains nothing, so un-pause via staging would
deadlock by construction. Riding outside the path through the drain and the
[trace](#g-trace), the primary record of a session, is safe for determinism precisely
because [§10.7][s10-7] put [pacing](#g-pacing) (the pacer's wall-clock waits) outside the semantics
([D-021][d-021]). Control changes *when* [frames](#g-frame) (iterations of the loop) execute, never
what they compute, and stop merely truncates the trajectory. This section
covers, in order, when the loop reads the plane, the stop and its issuer, the
pause, pace and `margin`, and the fields of `Control`, the periphery's own type
that holds the control plane ([D-256][d-256]).

The loop consults the control plane at frame top, the start of each frame. A
change issued while a frame runs or waits is observed at the next frame top, at
most one frame budget (`h/p`, the step over the pace) later ([D-269][d-269]). The pause
block, described with the pause verbs below, is the one wait that wakes at once.

The stop's issuers are the operator's channels and, in an interactive session,
Ctrl-C. The operator's channels are a front end's button, the handle of a
[device](#g-device) (any attached participant in the periphery) and calling
code ([D-310][d-310]). An [operator interrupt](#g-operator-interrupt) (Ctrl-C
read as a control-plane stop) sets exactly this stop, with no separate entry
point involved ([§12.4][s12-4], [D-132][d-132]). The loop catches it at one of its unmask
points, where a deferred Ctrl-C is raised ([§12.4][s12-4]).

**The [stop word](#g-stop-word) carries its issuer** ([D-203][d-203]). The stop word is the control
plane's stop command, one atomic word holding its issuer. Each issuing site
writes its identity (the device's name, `:code`, or `:interrupt`) by
compare-and-swap from empty, and the first writer wins. The loop's frame-top
read consults the word for non-empty, so the recorded issuer is the request that
actually initiated the tail, the ordered shutdown sequence of [§12.4][s12-4]. The issuer
lands in the [termination record](#g-termination-record) (the stopped-sim value naming how the run ended)
as its `ControlRequestedStop`'s payload ([§13.5][s13-5], [D-203][d-203]).

**`ControlRequestedStop` sits outside the stop policy** ([D-255][d-255]). The
policy is what the caller declares for one advance ([§12.6][s12-6]). The stop
word is what anyone can issue at any moment.

**The pause is two verbs on the simulation** ([D-268][d-268]). `pause!(sim)`
sets the pause flag and `resume!(sim)` clears it, from any task and in any
lifecycle state. `paused(sim)` reads it. The loop consults the flag at frame
top, so a `pause!` issued before `run!` starts the run paused at its first
frame top. While paused the loop blocks on a condition variable (notified on
un-pause and stop), not a spin. A stop issued while paused wakes the loop,
which observes the stop word and enters the tail with no further frame
([§12.4][s12-4]). `step!` shares the frame top and blocks the same way, until
`resume!` or a stop from another task.

A paused run is still running. The lifecycle reads `running`, and the
[roster](#g-roster) (the list of attached device entries) stays frozen
([D-106][d-106]).

**The tail clears the pause flag beside the sticky stopped status**
([D-268][d-268]). The flag is never cleared at a run's start. The stop word,
by contrast, is cleared at the top of each run ([D-398][d-398]), because a stop belongs
to the run it ended. A pause left set by a run that stopped while paused would
instead hold the next run at its first frame top, on a flag nobody remembers
setting. Clearing it in the tail removes that trap and keeps the start-paused
spelling above.

The device handle carries no pause ([§11.6][s11-6]). Whether it gains the
control verbs for the bridge ([§11.7][s11-7]) is pending (`pending.md`, [D-310][d-310]).

**Pace and `margin` are two more verbs and two readers** ([D-269][d-269]).
`pace!(sim, p)` and `margin!(sim, m)` set them from any task in any lifecycle
state, and `pace(sim)` and `margin(sim)` read them. `margin` ([§10.7][s10-7]) rides on
the control plane for the same reason `pace` does. It tunes the wait, never the
arithmetic, so retuning the coarse/spin split mid-run is safe by construction.
`run!` and `replay!` take both as keywords and write them when called. Both are
declared by the advance, as `t_end` is. `pace` defaults to `Inf` and `margin` to
2 ms ([Appendix B][sB], [D-133][d-133]). `step!` takes neither and never waits on the pacer. A
stepping session is the harness mode ([§12.6][s12-6]), and its frames are bit-identical
to `run!`'s by [§10.7][s10-7]'s invariant. `pace` is a positive real, `Inf` admitted, and
`margin` a non-negative real, `Inf` admitted. The two setters and the two
keywords refuse anything else under `ArgumentInvalid` ([Appendix C][sC]).

Beside pause, pace and `margin`, `Control` keeps the stop word, the sticky
stopped status, the running flag ([D-317][d-317]) and the wait
([§12.3][s12-3]). **`Control` also keeps the shutdown tail's `join_timeout`**
([§12.4][s12-4], [D-256][d-256]). The lifecycle state is not stored, and
`lifecycle(sim)` derives it ([§12.6][s12-6]). A run's outcome is not a control
surface, so `termination` belongs to the [`Run`](#g-run) (the state one run
owns), not to `Control` ([§12.6][s12-6], [D-255][d-255]). The control plane is
what anyone may poke.

### 12.2 Loop scheduling: wait primitive, yields, thread budget

[§10.7][s10-7] fixed the shape of the pacer's wait, hybrid sleep-then-spin,
and leaves the choice of the coarse phase's primitive to this section. That
choice is a scheduling decision rather than an arithmetic one. It settles
what else can run while a [frame](#g-frame) (one iteration of the loop) waits.
It is made here, together with the two questions that trail it, whether a
frame is guaranteed to yield at all and how many threads a session needs. The
section ends with the liveness heartbeat that makes a starved device
diagnosable.

#### The coarse phase's primitive

**The coarse phase uses task-yielding `sleep`**, and there is no
`systemsleep` variant ([D-027][d-027]). What the choice buys is the wait slot.
`sleep` releases the loop's thread, which makes the pacer's wait the natural
scheduling window for the co-resident tasks of [devices](#g-device) (the
attached participants in the periphery). The design already spends that slot
twice, as the staging slot ([§10.7][s10-7]) and as what the
[drain](#g-drain) (the frame-top swap that applies staged device writes) takes
([§11.4][s11-4]).

A `systemsleep` variant for dedicated-thread hard real-time deployments is a
[guarded addition](#g-guarded-addition) (a capability the design admits but
does not build) ([D-400][d-400]).

#### The per-frame yield

**With devices attached, every frame yields at least once** ([D-027][d-027]).
The rule is semantically free, because [pacing](#g-pacing) (the waits inserted
between completed frames), and hence yielding, is outside the semantics
([§10.7][s10-7], [D-021][d-021]).

The yield is implicit in the coarse-phase `sleep` whenever that phase runs.
An explicit `yield()` covers the frames where it does not run, namely unpaced
runs and pure-spin frames with budget ≤ margin. The spin phase itself never
yields ([D-027][d-027]). Yielding there would trade its µs precision for
scheduler noise.

The consequence is a bound on thread occupancy. The loop holds a thread for at
most one frame before the scheduler can run anyone else. Julia's scheduler is
cooperative, and a stall of that scheduler requires a thread monopolist, a
never-yielding task that holds its thread forever. That precondition is
structurally absent from framework tasks ([D-386][d-386]).

#### The thread budget

**The thread budget is a documented sizing rule and a startup warning, not a
hard error** ([D-027][d-027]).

The scheduler stall FlightCore's `nthreads` error prevented cannot reproduce
here, for two reasons. The loop yields every frame. Nothing couples a stall to
anyone else.

Undersized sessions degrade to laggy inputs and stale [snapshots](#g-snapshot) (the immutable
per-boundary publications), which are visible, recoverable states.

At `run!` or `replay!`, a run warns under `ThreadBudget` ([Appendix C][sC]) when
`Threads.nthreads()` is tight for the attached population, naming the `julia -t`
remedy. That is one check per run, against the frozen [roster](#g-roster), the list of
attached device entries ([§11.3][s11-3], [D-392][d-392]). Tight means fewer threads than the
roster plus one ([D-401][d-401]). Every rostered device is a task, and the [calling task](#g-calling-task) (the task
that invoked `run!`) hosts the loop, so a run occupies one task more than its
roster ([D-310][d-310]). The sizing guidance behind the remedy is one thread for the loop
and headroom for compute-heavy or blocking-ccall devices. I/O backed by libuv
(the I/O library under Julia's tasks) yields. Raw blocking ccalls pin their
thread for the duration. There is no pinning and there are no sticky tasks.

#### The liveness heartbeat

Since starvation is survivable, it must be diagnosable ([D-027][d-027]). The record is
the published [framework status](#g-framework-status), the frozen diagnostics value each snapshot
carries beside the table. It includes per-device liveness (the liveness
timestamp and the device's `task_state`) next to the pacer diagnostics. The
mechanism is the per-writer [diagnostic cell](#g-diagnostic-cell) ([D-136][d-136]), specified in full by [§11.8][s11-8],
plus the device `Task` handles the loop already owns, and nothing besides. A
diagnostic cell is a writer's own holding place for runtime diagnostics and
liveness. It carries the single liveness timestamp. The loop reads `task_state`
off those handles where it publishes ([D-193][d-193]). A starved, blocked or crashed
device task shows in a front end as a stale heartbeat with a name on it, not as
mysteriously frozen physics ([D-310][d-310]).

**`task_state` has three values** ([D-270][d-270]). Outside a run every device
reads `:none`. Inside a run a device reads `:running` while its task lives and
`:done` once that task has ended, whether the body returned or the wrapper
caught its crash ([§11.6][s11-6]). A device whose `init!` threw, and so
spawned no task, reads `:done` as well. The record's crash count tells a crash
from a return. `orphaned` on a record is exactly `:done` ([§11.7][s11-7],
[D-270][d-270]).

**Stale means a liveness timestamp more than 2 s behind wall clock**
([D-133][d-133]). The threshold is deliberately loose, because the heartbeat
is advisory ([D-395][d-395]). It is a liveness display and a record, never a kill
trigger, never a detach. It must also tolerate a device legitimately parked in a
blocking read between rare data.

### 12.3 The next-snapshot wait

Rate-matched output [devices](#g-device) (attached participants in the
periphery), such as telemetry and disk streaming, act once per boundary. A
[boundary](#g-boundary) is a published consistency point. What they need from
the framework is a way to learn that a boundary has happened without polling
for it. The [next-snapshot wait](#g-next-snapshot-wait) (a device's blocking
wait for the next publication) is that way. This section gives its two
artifacts, the loop's side, the device's side, its newest-wins semantics, and
how the counter differs from the other two indices, in that order.

**Two artifacts provide the wait, a monotonic [boundary counter](#g-boundary-counter) plus one
`Threads.Condition`** ([D-028][d-028]). The boundary counter is the loop's own. It counts
*published boundaries*, that is grid, `t*` and [boundary zero](#g-boundary-zero) (the initialization
boundary at `t₀`), not frames ([§10.1][s10-1], [§10.4][s10-4]). Consecutive wakes are therefore
not necessarily `h` apart.

The loop's publication is `lock; counter += 1; notify; unlock`, nanoseconds
of framework-only code. Waiters never block it. One parked in `wait` has
released the lock as part of parking.

The order of the two publications is normative. **The release-store of [`latest`](#g-latest),
the atomic reference readers acquire-load ([§11.2][s11-2]), happens before the counter
increment under the lock** ([D-114][d-114]).

```julia
# the loop, at every published boundary
@atomic latest = snap    # 1. release-store: the snapshot becomes reachable (§11.2)
lock(cond) do            # 2. only then the counter, under the lock
    counter += 1
    notify(cond)         #    parked waiters wake and re-test their predicate
end
```

The device side's test `counter > last_seen` (below) therefore implies that
`latest` holds at least that boundary, and a waiter can never wake onto a
[snapshot](#g-snapshot) (the immutable per-boundary publication) that is stale. The converse is
expected and correct. A waiter may observe a *newer* snapshot than the increment
that woke it. Newest wins.

The device side is `wait_next_snapshot(handle)`, which blocks until
`counter > last_seen && running` under the canonical predicate-loop idiom. That
idiom handles waiters at different paces, boundaries skipped while transmitting,
and shutdown, all with no per-frame reset. Shutdown works because [§12.4][s12-4] wakes
all waiters and each predicate then routes its owner out ([D-028][d-028]).

**The wait's semantics are newest-wins, no queues** ([D-028][d-028]). A slow consumer
skips boundaries and always receives the current world. This mirrors the inbound
side. Inbound [coalescing](#g-coalescing) (the compare-and-swap merge that leaves one pending
batch per device) keeps the newest level per face, and the wait delivers the
newest snapshot, the same zero-order hold (ZOH) decision. No backpressure exists
in either direction, and the loop never waits on anyone. Per-consumer
every-boundary queues are rejected ([D-028][d-028]).

A `Base.Event` latch is the wrong primitive here ([D-028][d-028]). Condition
variables carry no facts, only "look again". The facts that matter, the
counter and `running`, live in state each waiter tests privately.

Two indices number the publications, and each lives in its own place. The
snapshot carries the trajectory's *published-boundary ordinal* with `t`.
Boundary zero is 0, and every publication after it, grid or `t*`, counts one.
Any holder of a snapshot therefore indexes it without consulting the loop,
whether the [log](#g-log) (the retained sequence of published snapshots) or a post-run
inspector. A new trajectory restarts the ordinal at zero, with everything else
`init!` resets. The boundary counter is a different number. It is the loop's
monotone count of every publication it has ever made, never reset across
trajectories, and its absolute value is nowhere normative. It exists for the
wait predicate alone, and it is never reset because a waiter's `last_seen` must
never run ahead of it ([D-230][d-230]). An error's pointer for [replay](#g-replay) (the ordinary loop
re-driven from the trace) is a third index, the frame-entry boundary index of
[§13.4][s13-4], a frame count that names no `t*` boundary ([D-128][d-128]).

A front end paced by its own display may skip the wait and read `latest` at
each render.

### 12.4 Shutdown protocol

A run ends when its time is up, when someone stops it, or when the model
itself says so. Whatever the cause, the same work has to happen. The loop
has to stop on a [boundary](#g-boundary) (a published consistency point).
The task each [device](#g-device) (any attached participant in the
periphery) runs on has to be woken out of whatever it was blocked on. Every
resource acquired for the run has to be released before `run!` returns.
This section specifies that sequence, which it calls the tail throughout. It
also specifies the two things that bracket the tail. One is the pre-spawn
initialization at the top of a run, which is a step of this same protocol.
The other is the [operator interrupt](#g-operator-interrupt) (Ctrl-C in an
interactive session), which enters the tail rather than bypassing it.

#### The tail: the ordered sequence every stop takes

**Steps (1) through (5) below run in that order on every stop**, whatever
initiated it ([D-030][d-030]). Steps (6) and (7) specify what happens when a
device task or the loop itself ends first.

1. Initiation. Three events start a shutdown. Either `t_end` is reached, or a
   stop is issued on the [control plane](#g-control-plane) (the separate atomic surface carrying
   pause, pace and stop), or a [stop request](#g-stop-request) the advance honours reads
   `STOP_REQUESTED` in the just-published [snapshot](#g-snapshot) ([D-316][d-316]). A stop request is an
   output port of the framework enum `StopFlag`, and a snapshot is the immutable
   per-boundary publication. The control-plane stop's issuers are a front end
   ([D-310][d-310]), a device handle, code, or an operator interrupt (Ctrl-C, treated
   below). The third event is model-detected termination ([§13.5][s13-5]). The loop never
   stops mid-boundary. It always completes the boundary sequence in progress,
   which a stop at [`t*`](#g-t) (the localized event time) places inside a [frame](#g-frame), one
   iteration of the loop. The loop then publishes the final snapshot. Only then
   does it set the sticky stopped status.
2. Wake all framework waits. The waits are the [next-snapshot
   wait](#g-next-snapshot-wait) (`wait_next_snapshot(handle)`) and the pause.
   Each waiter observes the stopped status and unwinds. A stop issued while
   paused therefore works.
3. Unblock device-specific blocking calls. The hook is `unblock!(device)`,
   default no-op. A network input's override closes its own socket, which
   raises in the blocked task. The framework wrapper catches that raise and
   treats it as shutdown ([D-402][d-402]). This demotes FlightCore's EOT convention from
   essential shutdown mechanism to an optional wire-protocol courtesy between
   remote peers.
4. Loop bodies exit. The exit is the author's own `while running(handle)`
   loop, the authoring contract of [§11.6][s11-6]. That authoring contract
   teaches two obligations, the predicate check and interruptible blocking
   ([D-373][d-373]). Steps (2) and (3) are the framework's half. They wake its
   own waits and call each device's `unblock!`. The wrapper's `finally
   shutdown!(device)` is guaranteed on every exit path.
5. Join under the `join_timeout` cap. It is a keyword of the `Simulation`
   constructor, held on `Control`, the tail's own owner ([§12.1][s12-1], [D-256][d-256]), a
   positive real in seconds of wall clock, defaulting to 5 ([Appendix B][sB]). The
   constructor refuses any other value as `ArgumentInvalid`. A device task
   exceeding the cap is reported *by name* in a `DeviceJoinTimeout` diagnostic
   ([Appendix C][sC]). It is then abandoned rather than left to hang `run!`. **The
   diagnostic is written to the loop's own [diagnostic cell](#g-diagnostic-cell)**, a writer's own
   holding place for runtime diagnostics and liveness ([D-203][d-203]). The run's-end
   sweep, the loop's last pass over every diagnostic cell, collects the
   diagnostic into the [termination record](#g-termination-record) (the stopped-sim value naming how the
   run ended). The logging backend presents the diagnostic, with the terminal
   snapshot preceding the join ([D-201][d-201], [D-203][d-203]).
6. Device-initiated paths. A device exits voluntarily when its loop body
   returns, at a window ✕ or a peer EOT. No `should_close` hook exists ([§11.6][s11-6]).
   With [`should_abort`](#g-should_abort) (the per-attachment failure policy, an `attach!` keyword)
   set, the wrapper's exit path also requests a sim stop. Otherwise the sim
   continues with the device's *task* absent. Its [staging cell](#g-staging-cell) (where the
   device's pending write batch waits between drains) stops filling, and the
   loop is structurally indifferent. Its [roster](#g-roster) entry and its [claims](#g-claim) persist to
   run end, because [§11.3][s11-3] freezes the roster for the run and death is not
   detach. The roster is the list of attached device entries, and a claim is the
   set of faces a device may write. The orphaned [root inputs](#g-root-input) (the root
   component's own input faces) hold their last-drained values, visibly ([§11.7][s11-7]).
   A crashing device task is caught by the framework wrapper and follows the
   same path, logged with the device's name (`DeviceCrash`, [Appendix C][sC]).
7. Loop-side failure. A failure on the loop's own side runs steps (1) through
   (5) from the catch path ([D-030][d-030]). [§13.6][s13-6] specifies that
   path, which discards the failed boundary and promotes the previous snapshot
   to final. FlightCore's `SimulationTermination` catch path was the
   precedent. The exception-based termination idiom itself has no place here
   ([§13.5][s13-5], [D-060][d-060]). Devices therefore unwind cleanly
   regardless of who died.

The ordered part, in one line:

> (1) stop observed → current boundary completed → final snapshot published
> → sticky `stopped` set → (2) framework waits woken → (3) `unblock!`
> per device → (4) loop bodies return, each through its wrapper's
> `finally shutdown!` → (5) join under the `join_timeout` cap → `run!`
> returns

`t_end` lands on the grid. **The run ends at the first grid boundary whose time
reaches or exceeds `t_end`** ([D-133][d-133]). The run takes whole frames only, never a
shortened final step, which grid integrity forbids ([§10.4][s10-4]). Each grid time is
indexed, `tₖ = t₀ + k·h`, and never accumulated ([§10.4][s10-4]). The final boundary may
therefore overshoot `t_end` by up to `h`. The termination record carries the
actual final `t` ([§13.5][s13-5]). This is the `t_plus` spelling ([§12.6][s12-6]) applied to the
run's own clock.

The two termination sources differ in nature. `t_end` is a grid fact,
checked against boundary times on the grid. Stop requests are checked at
*every* published boundary, `t*` included ([§13.5][s13-5]).

The final snapshot goes out before the status is set. Publishing first
guarantees that output devices can flush the true final state. The status in
that terminal snapshot carries the run's cumulative diagnostic counters
([§11.8][s11-8]), the warning account of a run nobody watched, complete up to
that snapshot's own frame top. **What the tail itself produces is folded into
the termination record and presented through the logging backend, never
published** ([D-201][d-201], [D-203][d-203]). It comes later by construction.

That terminal snapshot is retained in the [log](#g-log) (the retained
sequence of published snapshots) unconditionally, under any `log_every` and
any `log_max` ([§11.2][s11-2], [D-368][d-368]).

The `join_timeout` default of five seconds is generous for front-end window
teardown and socket closes. It is short enough that an abandoned join reads as a
diagnosed timeout rather than a hang.

**The cap is a per-simulation setting, not an implementation constant** ([D-198][d-198]).
That is the disposition [§10.4][s10-4] gives its own two constants, extended here to an
operational one. Usage contexts legitimately differ in patience. A series of
runs nobody watches wants to fail fast, a test battery exercising the
abandonment path faster still, while a device with slow teardown may warrant
more. The cap is not trajectory-determining, because the trajectory has ended at
the final snapshot before any join begins. So [replay](#g-replay) (the ordinary loop with the
drain reading recorded batches) neither records nor compares the cap ([§11.5][s11-5],
[§12.7][s12-7]), just as for `log_max` ([§11.2][s11-2]). The cap therefore lives on `Control`, not
on the `Deployment` ([D-256][d-256]).

#### What survives the tail

After (5) the task set is empty, since device tasks are per-run artifacts
([§11.1][s11-1], [D-093][d-093]). `shutdown!` has also released each
device's OS resources. What survives a stop is the roster entry, with its
binding, claims and stable device id ([§11.3][s11-3]). A task never
survives, and neither does a live resource. That holds for a device whose
task died mid-run too. Its roster entry is indistinguishable at this point
from any other's. Once stopped, `detach!` can remove a roster entry and
release its claims ([D-106][d-106]).

The next run re-acquires everything. The next `run!` re-runs device
`init!`, since resource acquisition is per-run ([D-093][d-093]). The
precedent is FlightCore's network device, `network.jl`, which created a new
socket at each `init!`. The next `run!` also spawns fresh tasks against the
[§12.3][s12-3] counter, which is never re-armed. Each task reads its
`last_seen` off the counter at spawn ([D-403][d-403]). While stopped there are no device
tasks at all, so voluntary exit and the [§12.2][s12-2] liveness heartbeat are
run-scoped observables ([D-389][d-389]). A device unplugged while stopped surfaces as the
next run's `init!` failure, disposed of by the initialization bracket below.

#### Initialization: the pre-spawn bracket

**Initialization is a step of this protocol, taken at the top of a run**
([D-138][d-138]). Before any task is spawned, the loop calls `init!` once per
roster entry, in attachment order, on the [calling task](#g-calling-task)
(the task that invoked `run!`). Each call sits in its own bracket.

```julia
for entry in roster                       # attachment order, calling task
    push!(live, entry)                    # listed for release before `init!` begins
    try
        init!(entry.device)
    catch e
        shutdown!(entry.device)           # release, unconditionally (§11.6)
        pop!(live)                        # released, so unlisted
        if e isa InterruptException       # the operator's stop, never a crash (below)
            stop!(control, :interrupt)
        else
            # pre-spawn: the entry is the address, no task holds a handle yet
            report!(entry, DeviceCrash(e, entry.should_abort))
            entry.should_abort && stop!(entry.handle)
        end
                                          # no dead-marking: no task is spawned (§12.2)
    end
end
```

The bracket is what makes "guaranteed on every exit path" ([§11.6][s11-6])
true of the path outside that wrapper. A device that throws half-way through
acquisition is handed back to `shutdown!` right there, so its partially
acquired OS resources are released rather than leaked ([D-138][d-138]). That
is exactly why `shutdown!` owes tolerance of a partially initialized device,
a rule [§11.6][s11-6] teaches.

The roster entry is listed for release before its `init!` begins
([D-268][d-268]). The bracket unlists it once its own `shutdown!` has
returned. An operator interrupt that escapes the bracket therefore finds
listed every device whose `init!` began and that the bracket has not
released, and the run releases each before it ends. A device listed and not
yet initialized can be released having opened nothing, which `shutdown!`
tolerates ([§11.6][s11-6]).

**The report is the ordinary `DeviceCrash`, not a kind of its own**
([D-138][d-138], [D-396][d-396], [Appendix C][sC]). Its [payload](#g-payload) (the
structured data a diagnostic carries beside its kind) already carries the
cause exception and whether `should_abort` was set. The diagnostic cell it
is written to names the device. That is everything an init-time failure has
to say. The name is honest. A device that cannot acquire its resources has
crashed before it lived.

**The report is written through the ordinary `report!(address, diagnostic)`
entry point**, addressed by the roster entry rather than by a handle ([D-189][d-189]).
There is no device task to hold a handle before the spawn. The address supplies
the device identity either way, which is why no call passes a device id ([§11.8][s11-8]).

No task is spawned for a failed device, so it is dead from the run's first frame
top ([D-138][d-138], [D-396][d-396]). That needs no machinery. Its `task_state` reads `:done` from the
first publication ([§12.2][s12-2]). Its diagnostic cell keeps its last beat. It reads stale
against the [§12.2][s12-2] threshold from the start if the device has not beaten since its
attach, and otherwise once that beat is more than 2 s old ([D-138][d-138]).

The claims of a failed device persist to run end ([D-138][d-138], [D-396][d-396]). This is the
death-is-not-detach disposition ([§11.3][s11-3]), applied one step earlier than (6)'s.
The roster is frozen for the run, and the orphaned root inputs hold the values
the run started with. Those values are well-defined by [root-input totality](#g-root-input-totality), the
rule that every root input must hold a value ([§14.6][s14-6]). An orphan of (6) holds a
last drained batch instead.

**The run's disposition splits on `should_abort`, uniformly with (6)**
([D-138][d-138], [D-396][d-396]). With the flag clear, which is the default
([§11.6][s11-6]), the remaining roster entries initialize, the run starts,
and the sim runs with that device absent from the run's first frame. That
is (6)'s "the sim continues with the device's *task* absent", shifted to the
run's start.

With the flag set, the failure requests a control-plane stop, and that stop is
simply *already pending* at the run's first frame top. The loop reads it there,
before any frame, so the run advances no frame. This protocol already has that
path, so no new exit protocol is needed. The remaining roster entries still
initialize, every rostered device getting its `init!`/`shutdown!` pair
uniformly. The run ends `stopped` where it started, through this same tail, with
its termination record naming the device ([§13.5][s13-5]). What the operator is left with
is an ordinary stopped simulation, whose terminal snapshot is the one the run
started from and whose termination record's tail residue (the diagnostics the
run's-end sweep folds in) holds the `DeviceCrash`. It is fully serviceable by
[§14][s14]. `run!` refuses it, as it refuses any stopped simulation. Once the
device is back, `init!` re-runs the simulation, and `checkpoint` then
`restore!` continues it from where it stands ([§12.6][s12-6]).

**An `InterruptException` inside a device's `init!` is the operator's stop, not
that device's crash** ([D-268][d-268]). The bracket releases the device through
`shutdown!` as for any throw and spawns no task for it. In place of the
`DeviceCrash` report it sets the `:interrupt` stop through the stop word (the
control plane's stop command, one atomic word holding its issuer). The run's
`should_abort` split above therefore does not arise. The remaining roster
entries still initialize, and the run ends at its first frame top with zero
frames advanced, through the pending-stop path above. The device wrapper makes
the same discrimination for a raise inside a loop body ([§11.6][s11-6]).

#### The operator interrupt

**The operator interrupt is a stop, not a failure** ([D-132][d-132]). Ctrl-C
in an interactive session is a control-plane stop command issued by hand.
The run completes the current boundary, publishes the final snapshot, takes
this tail like any other stop, and ends `stopped`. The result is
boundary-consistent. It is fully serviceable by the [§14][s14] stopped-sim
services. `init!` re-runs it, and `checkpoint` then `restore!` continues it
from where it stands ([§12.6][s12-6]).

The interrupt is the escape from a run nothing else ends, and the deviceless run
has no other. A run with no finite `t_end` and no honoured stop request is the
configuration `UnboundedRun` names ([Appendix C][sC]). The interrupt needs no entry
point of its own ([D-132][d-132]). The stop already rides on the control plane ([§12.1][s12-1]).
The exceptions-are-abnormal doctrine ([§13.5][s13-5], [D-060][d-060]) is untouched. That doctrine
is about *model* code, while this is the one exception whose meaning the
framework knows.

The interrupt's scope is the interactive session. Outside the REPL, Julia's
default (`exit_on_sigint(true)`) kills the process on SIGINT before any of
this machinery runs. The framework flips nothing process-global
([D-132][d-132], [D-394][d-394]). [Unattended runs](#g-unattended-run), those with empty
staging and no snapshot readers, rely on `t_end` and stop requests, as they
already must.

**Masking across the boundary is normative, not an implementation hint**
([D-132][d-132], [D-394][d-394]). The reason is that an `InterruptException` is delivered
asynchronously. An interrupt landing in the middle of a [sweep](#g-sweep) (one pass through
the execution order) would therefore destroy the boundary this protocol is built
on completing. It would also leave [stores](#g-store) (the framework-owned homes of a
component's state) half-written ([§13.6][s13-6]). That forces a choice between `stopped`
with dirty stores and a terminal `errored`. The `stopped`-with-consistent-stores
guarantee is exactly what the masking buys.

The loop masks delivery across the boundary macro-sequence, using Julia's
`disable_sigint`, a sigatomic counter increment that is negligible per
frame. It takes the deferred raise at the unmask points. They are the frame
top, where it already consults the control plane ([§12.1][s12-1]), and
points inside its wait and pause blocks. All of those points are
boundary-consistent. Caught at one of them, the interrupt sets the
control-plane stop and enters this tail. The catch site ([§13.4][s13-4])
therefore never sees a single interrupt.

**A deferred interrupt yields to the frame's own stop request**
([D-268][d-268]). Stop requests are consulted at each publication and the
stop word at the next frame top ([§13.5][s13-5]), and the deferred raise
lands between the two. Where the frame's publication found an honoured
request holding, that request is the recorded source and the interrupt is
satisfied by the run ending. Where none held, the interrupt sets the stop
word and the source is `ControlRequestedStop(:interrupt)`.

**A frame that throws with an interrupt pending ends `errored`**
([D-268][d-268], [D-398][d-398]). The frame's own throw is the disposition
([§13.4][s13-4]). The catch wraps the cause under the mask and consumes the
pending interrupt on its way out. The run then takes the abnormal shutdown entry
under that `StepError` ([§13.6][s13-6]). The alternative, `stopped` over a
half-written boundary, is what the masking exists to prevent. The interrupt
is satisfied by the run ending.

**An interrupt after a frame's throw does not displace it**
([D-268][d-268]). `run!`, `replay!` and `step!` store the loop's throw before
an interrupt can displace it, and the masked bookkeeping below builds the
record from that store. The run therefore ends `errored` under its
`StepError` wherever a later interrupt lands. An interrupt that cuts the
handling of the throw itself propagates out of the call raw, and the
disposition of the failure is skipped ([§13.4][s13-4]). The record is still
written and the lifecycle is still `errored`.

**The tail's bookkeeping is masked too** ([D-268][d-268]). After the joins, the run's-end
sweep, the termination record and the terminal lifecycle state are written under
the same mask. An interrupt landing there would otherwise abort the sequence
half-way and leave the lifecycle `running`, every service refusing. A raise
deferred to the end of that bookkeeping propagates out of `run!` raw, the
simulation already terminal.

**A forced throw reaches the defensive arm** ([D-268][d-268], [D-398][d-398]). Julia stops deferring
after repeated SIGINTs in a short window, warns that it is forcing the throw,
and raises inside the mask. That is the one way the branch [§13.4][s13-4] keeps is
reached. The arm abandons the frame unpublished and the run ends `stopped`, the
source `ControlRequestedStop(:interrupt)`. What the run published is consistent,
since the frame published nothing. The stores may hold mid-boundary values until
the next `init!`, `restore!` or `replay!` resets them, as after a throw inside
[boundary zero](#g-boundary-zero), the initialization boundary, which runs the ordinary
macro-sequence with an empty integrate ([§13.4][s13-4]). `checkpoint` refuses such a run
as `CheckpointMidFrame`, since the [executor](#g-executor) (the compiled form of the stage
execution order) no longer rests where its last snapshot was published ([§12.6][s12-6]).
The [trace](#g-trace) (the primary record of a session) is the reproduction ([§12.7][s12-7]).

**A second interrupt during the tail collapses the remaining joins
immediately** ([D-132][d-132], [D-394][d-394]). That is (5)'s abandonment path taken at once,
with devices still reported by name (`DeviceJoinTimeout`). The run still
ends `stopped`. Escalation shortens the tail, never reclassifies the run.

### 12.5 Scripts and the mid-run mutation doctrine

This section settles what the [periphery](#g-periphery) (everything outside the loop that
exchanges data with it) may do to a running model. The periphery's attached
participants are its [devices](#g-device). The section surveys FlightCore's mid-run
mutations, states the clock criterion that maps scripts to [components](#g-component) (units of
modeling), eliminates FlightCore's per-step hook `user_callback!`, covers manual
events and mid-run re-initialization, and ends with the doctrine's final form.

What the consumers demonstrably mutate mid-run is surveyed here. The line
references are to `c172_demos.jl`, FlightCore's demo file. FlightCore's
`user_callback!` has exactly two archetypes. The first is the timetable
script, `elevator_offset` as a function of `t` (c172_demos.jl:290). The second
is the synthetic pilot, a phase FSM (finite-state machine) reading `y` and
writing mode requests, references, flaps and wind (c172_demos.jl:423, 525).
Both write only `u` fields. No demo, test or GUI path pokes `x`/`s` mid-run,
and `init!`/trim appear only between construction and `run!`
(c172_demos.jl:303).

**A sim-time script becomes a [scenario component](#g-scenario-component), and a wall-clock interaction
becomes a device** ([D-031][d-031]). A scenario component is an ordinary periodic
discrete component holding a sim-time script. Sim-time scripts are model
behavior, which is why they become scenario components. Both archetypes are
clocked by *sim time*, `t`, the trajectory. Mapping them to devices is rejected
([D-031][d-031]). The clock is the criterion.

A script mapped to a component is periodic discrete, with `K = 1` for the
`dt = 0.02` callbacks FlightCore had, `K` being the multiplier in
`Relative(K)` ([§10.5][s10-5]). It executes synchronously in the loop,
deterministic paced or unpaced. It is replayed by recomputation, with no
[trace](#g-trace) (the records of each frame's drained inputs). A device, by
contrast, is traced and replayed from the trace.

The component mapping is strictly richer than the callback it replaces.

- The callback's `Ref(:init)` phase closure becomes honest `s`, which a
  [port](#g-port) (one declared name with its cell) can publish to
  [snapshots](#g-snapshot), logs and plots. A snapshot is the immutable
  per-boundary publication.
- Inputs arrive fresh from the same [boundary](#g-boundary) (a published consistency point), by
  topological order. The callback ran post-step, one boundary staler.
- The pure timetable script is a one-liner reading the clock out of its
  [bundle](#g-bundle) (the NamedTuple of zero-copy views a component function
  receives). That one-liner is `y_direct(c, (; t)) = (; offset = profile(t))`,
  exact at its own [ticks](#g-tick), with no latch state of its own. A tick
  is an instant at which a discrete component's stages and update run.
- In a scenario configuration the script drives the input ports of the avionics
  (the onboard flight systems). [§11.7][s11-7] therefore renders a front end's
  corresponding widgets read-only, each showing its source ([D-310][d-310]). Its
  port-resolution rule resolves FlightCore's demo-vs-GUI dead-slider fight.

**`user_callback!` is eliminated** ([D-031][d-031]). It is the periphery's
`f_step!`, FlightCore's unconditional per-step hook ([§2.5][s2-5]), and cheap
composition leaves it without justification. Its call sites migrate to
scenario components, not devices.

**Manual event triggering needs no mechanism** ([D-031][d-031]). It takes a
[root input](#g-root-input) (the root component's own input face) plus a
[boundary-detected](#g-boundary-detected) [guard](#g-guard) (an edge check at
step boundaries only, with no root-finding) reading that root input. That is
already expressible in settled machinery. The levels doctrine applies
([§11.4][s11-4]), with latched commands or counters. The engine start/stop
buttons of FlightCore's demos were `u`-writes.

**Mid-run re-initialization is not built** ([D-031][d-031]), because it is not
demonstrated. Initialization and trim are stopped-sim workflows, first-class
services of [§14][s14]. No concurrency perimeter exists there. There is no loop and no
devices, just plain single-task code. The shape of the [guarded addition](#g-guarded-addition) (a
capability the design admits but does not build) is on record should demand
appear. It would be a traced, boundary-executed intervention command applied
through project → [sweep](#g-sweep) → publish, so that no consumer ever observes un-decoded
state. A sweep is one pass through the execution order against the current
state.

In the doctrine's final form, while a simulation runs, **the periphery stages
root-input writes and issues control commands** ([§2.2][s2-2],
[D-031][d-031]). Structurally, it does nothing else. Anything that wants to
poke the model mid-run is one of three things.

- It is an *input* in disguise, so wire a root input and a guard.
- It is *model behavior* in disguise, so add a scenario component.
- It is a *wall-clock interaction*, so attach a device.

Graceful termination follows the same shape ([§13.5][s13-5]). It is a
[stop request](#g-stop-request) (an output port of the framework enum
`StopFlag`) declared in the model, honoured unless the advance ignores it
([D-316][d-316]). It is never a callback, and never a thrown exception
([D-060][d-060]).

### 12.6 Run lifecycle and partial advance

This section specifies what a `Simulation` and its run own, the lifecycle a
simulation moves through, how it advances and restarts, what it keeps of its
[devices](#g-device) (any attached participants in the periphery) across runs, and the stop
policy each advance declares. A simulation is in one of five lifecycle states,
built, initialized, running, stopped or errored. A *door* is an entry point that
builds a run, and there are three, `init!`, `restore!` and `replay!`. A run's
`feed` is the recording `replay!` attached, or `nothing`. The [input mode](#g-input-mode) says
where the next [frame](#g-frame) (one grid step, the unit of scheduling) takes its inputs
from.

#### The run and the simulation

**[`Run`](#g-run) is what one run owns** ([D-255][d-255], [D-260][d-260], [D-317][d-317]). It is a mutable struct of
six fields. Two are `const` and last the run's whole life. One is the [log](#g-log) (the
retained sequence of published snapshots). The other is the [trace](#g-trace) (the records
of each frame's drained inputs), which is `nothing` under `trace = false`. The
door that builds the run takes the four recording keywords, `trace`, `log`,
`log_every` and `log_max` ([Appendix B][sB], [D-261][d-261]). A run's recording is therefore
that door's declaration, and the next door may declare otherwise ([D-261][d-261]).

Four fields evolve during the run. `feed` is described above. `termination` is
the record the loop's tail writes. `frame` and `boundary` are the trajectory's
counters, the frame index and the boundary ordinal. `init!`, `restore!` and
`replay!` construct a run, and nothing else rebinds it. `live!` ([§12.7][s12-7]) and the
halt at a recording's end write `feed`. The loop's tail writes `termination`
once, and `closed(run)` is `termination !== nothing`. Each door sets the two
counters as it builds the run, `init!` to zero and `restore!` and `replay!` to
those of the [checkpoint](#g-checkpoint) (the `Model`'s state at a frame top, beside the run's
frame index and boundary ordinal), and the loop advances them ([D-317][d-317]).
`restore!` of a bare state sets the frame index to the state's frame and the
boundary ordinal to zero, as `init!` does ([D-319][d-319]).

The origin `t₀` is not a run field ([D-260][d-260]). The clock of the [executor](#g-executor) (the
compiled form of the stage execution order) holds it beside `t`. `init!` sets it
on the clock before [boundary zero](#g-boundary-zero), the initialization boundary run as the
ordinary macro-sequence with an empty integrate ([§14.5][s14-5]). A checkpoint carries it
with the clock ([§11.5][s11-5], [D-273][d-273]). It is a `Float64`, as `h` and `t_end` are
([D-260][d-260]).

**A `Simulation` is constructed with a placeholder run** ([D-255][d-255]). The
placeholder is an empty log, no trace, no feed and no termination, and
`init!`, `restore!` and `replay!` replace it ([D-255][d-255]). The field is
always a `Run` and never `nothing`, so every accessor has a run to read, and
the lifecycle state below says whether that run ever started ([D-397][d-397]). The
placeholder carries no configuration and no compiled state ([D-261][d-261]). `init!`
allocates fresh objects rather than clearing them ([D-255][d-255]).

**`Simulation` is a mutable struct of four fields**, the [`Model`](#g-model) (the deployment
and its executor at one scalar), the run, the data plane ([§11][s11]) and the control
plane ([D-317][d-317]). The [control plane](#g-control-plane) is the atomic surface carrying pause, pace and
stop. The `Model` holds the [deployment](#g-deployment), the executor, its status and its
[diagnostic cell](#g-diagnostic-cell). The deployment is the scalar-free artifact the grid parameters
fix, carrying the build. A diagnostic cell is a writer's own holding place for
runtime diagnostics. A simulation owns its `Model`, claimed at construction and
never shared ([§9.2][s9-2], [D-318][d-318]).

Every other value belongs to one of the four ([D-256][d-256]). The build is reached
through the deployment, never held twice. The grid parameters, the [schedule](#g-schedule) (the
typed per-component `(D, Φ, Δt)` tick table) and the event parameters are the
deployment's ([§9.2][s9-2]). `chunk_size`, the stepper and the arrival buffers are the
executor's. `join_timeout` is `Control`'s ([§12.1][s12-1]). The loop's diagnostic cell,
its account and the published-snapshot holder ([§11.2][s11-2]) are the data plane's, and
the frame's own diagnostic cell is the `Model`'s ([§11.8][s11-8]). The log, the trace and
the two counters are the run's. The stop policy, with its `t_end` and ignored
requesters, is the advance's argument, and the [termination record](#g-termination-record) (the
stopped-sim value naming how the run ended) keeps the terminating one ([D-260][d-260]).
The pacer's schedule and counters are `run!`'s own, created per call and passed
to the loop and its publications as the policy is. The status of each [snapshot](#g-snapshot)
(the immutable per-boundary publication) carries the pacer's frozen record
([§10.7][s10-7], [D-269][d-269]).

**A struct holds what it owns or what it must retain across calls**
([D-261][d-261]). A callee takes what it reads as an argument, never off a
field added to the container it already holds. **An object is built after its
inputs exist**, and the placeholder run above is the one exception
([D-261][d-261]).

#### Lifecycle states and the input mode

**A `Simulation` moves through five states**, *built*, *initialized*, *running*,
and terminally *stopped* or *errored* ([§13.4][s13-4], [D-088][d-088]). *Built* means [stores](#g-store) (the
framework-owned homes of a component's state) allocated and boundary zero not
completed ([D-223][d-223]). It is the cold state, and the state a throw inside boundary
zero returns the simulation to ([§13.4][s13-4]). *Initialized* means `init!` has
completed boundary zero ([§14.5][s14-5]), or `restore!` or `replay!` has restored a
checkpoint.

**`lifecycle(sim)` derives the state rather than storing it** ([D-317][d-317]).
It reads three facts, the control plane's running flag, the `Model`'s status
and whether the run is closed. The status is `:built`, `:consistent` or
`:inconsistent`, and only the `Model`'s own entry points and catch sites write
it. A claimed model's status is written only through its simulation's entry
points, since the model's entry points refuse a direct call on a claimed model
([D-318][d-318]).

| running flag | `Model` status | run closed | state |
|---|---|---|---|
| set | any | any | running |
| clear | `:built` | any | built |
| clear | `:inconsistent` | any | errored |
| clear | `:consistent` | no | initialized |
| clear | `:consistent` | yes | stopped |

**`errored` is terminal** ([D-059][d-059]). Reproduction is trace
[replay](#g-replay), not resurrection ([§12.7][s12-7], [D-387][d-387]). Replay is the ordinary
loop re-driven from the trace.

Beside the state, the run carries an input mode, `:live` or `:replay`, read as
`mode(sim)`. **The mode is read off the run's `feed`**, `:replay` while a
recording is attached and `:live` otherwise ([D-260][d-260]). The mode names where the
next frame's [drain](#g-drain) takes its [batches](#g-batch) from, the [staging cells](#g-staging-cell) (where each
device's pending batch waits between drains) or the attached recording ([§12.7][s12-7],
[D-218][d-218]). The drain is the frame-top swap that publishes staged device writes into
the root inputs, and a batch is a device's staged set of writes. State and mode
are orthogonal. The state says whether the simulation may advance, and the mode
says what it will advance on.

**`init!` is mandatory** ([D-088][d-088]). `run!` or `step!` on a simulation
whose boundary zero has not completed is `MissingInit`, an error in the kind
set ([§13.2][s13-2]) naming `init!`. That is distinct from
`UninitializedInputs`, which fires *inside* `init!` ([§14.6][s14-6]).
`restore!` and `replay!` are the two alternative doors. Each restores a
checkpoint and runs no boundary zero ([§12.7][s12-7], [D-274][d-274]). A throw
inside boundary zero, which only `init!` runs, leaves the simulation `built`
([§13.4][s13-4], [D-223][d-223]), so the next `run!` or `step!` meets the same
refusal.

#### Partial advance

Deviceless, `run!` is fully synchronous. [§11.1][s11-1] says where the loop and the
device tasks run, and defines the [unattended run](#g-unattended-run) (a run with empty staging and
no snapshot readers).

`step!(sim; frames = 1)` advances whole frames synchronously through the
ordinary frame sequence (drain, integrate, boundaries, publication) and
returns ([D-088][d-088], [D-388][d-388]). A stepped simulation is bit-identical to the same
frames under `run!` ([§2.4][s2-4]), and it never waits on the pacer, whatever
pace the control plane holds ([D-269][d-269]). `step!(sim; t_plus = 10.0)` is
the duration spelling ([D-390][d-390]). It is mutually exclusive with `frames`, and passing
both is `ArgumentInvalid`. It advances whole frames until the boundary time
first covers the duration, which is the migration suite's advance-by-duration
idiom.

Partial advance is the test-harness mode of advance, assert, advance. It is
equally the REPL mode of fly a while, inspect, continue. Neither is a script,
so the scenario-component doctrine does not absorb them ([§12.5][s12-5]).

**A stepping session is deviceless by construction** ([D-093][d-093], [D-389][d-389]). Device
tasks are per-`run!` artifacts ([§11.1][s11-1]), and a device loop's
`while running(handle)` is false outside a run. Between `step!` calls the
simulation is in a stopped-sim state, `initialized` (below), so `attach!` is
legal there and does what it always does. It registers ([§11.3][s11-3]), and
the task appears at the next `run!`.

The frame-top drain still runs, so `step!` frames stay bit-identical to `run!`
frames. In a stepping session the staging cell written is the [harness cell](#g-harness-cell) (the
always-present staging cell of the [harness writer](#g-harness-writer)). The harness write path is
`stage!(sim, "face" => value, …)`, and [§11.3][s11-3] specifies the writer. Staged
batches are ordinary batches. They are traced, so replay and bit-identity hold,
and they are applied at the next frame top.

The read half is `latest(sim)`. It hands back the same immutable snapshot
value a device handle acquires ([§11.2][s11-2]), navigated directly for
assertions ([D-390][d-390]). Advance-assert-advance is `stage!` → `step!` → `latest`
([D-096][d-096]). Both entry points work under `run!` too. The harness cell is
not step-scoped. An inspection accessor leaves the rejection of closure-based
termination untouched ([§13.5][s13-5], [D-096][d-096], [D-390][d-390]).

#### Status, termination and `run!` after `step!`

Between `step!` calls a simulation reports `initialized` ([D-088][d-088], [D-388][d-388]). No
loop task exists, so `running` would lie. Nothing is terminal, so `stopped`
would lie too. The state reads "boundary-consistent and ready to advance", not
"sitting at boundary zero". `run!` may therefore follow `step!`, continuing
from the current boundary, and so may another `step!`.

The stop policy is honoured throughout, as bit-identity requires. `t_end`
reached, or a [stop request](#g-stop-request) (an output port of the framework enum `StopFlag`)
[holding](#g-edge-semantics) (publishing `STOP_REQUESTED`) at frame 3 of `step!(sim; frames = 10)`,
ends the run there through the ordinary [§12.4][s12-4] tail and leaves the simulation
`stopped` ([D-388][d-388]). `step!` therefore returns the number of frames *actually
advanced*. That is the requested count in the ordinary case, and fewer when the
run terminated inside the call. That return is how a harness detects the
truncation without inspecting the clock.

#### Re-running and checkpoints

**`stopped → init! → run!` remains the authored re-run** ([D-088][d-088], [D-388][d-388]).
`init!` re-runs boundary zero from its [condition](#g-condition) (a
path-addressed overlay that sets the build to a state). The warm restart is
`checkpoint` → `restore!` → `run!` ([§12.7][s12-7], [D-274][d-274]).
`restore!` is a door like `init!`, and it runs no boundary zero. Each builds a
fresh run, so the trace, the log and the termination record ([§13.5][s13-5])
are new objects rather than cleared ones, and each clears any batches still in
staging cells. The [recorders](#g-recorders) (the trace and the log jointly)
restart with the run they record, and no stale batch survives to clobber the
frame it predates.

`init!` and `restore!` also return the input mode to `:live`, and a fresh
`replay!` sets the mode exactly as it sets the trajectory. `live!` is the one
call that moves the mode alone. It takes a replaying simulation live where it
stands ([§12.7][s12-7]). A terminal state makes the mode moot. From `stopped`,
nothing advances until `init!`, `restore!` or `replay!` opens a new run, and
`errored` is terminal ([D-218][d-218], [D-219][d-219]).

`checkpoint` and `restore!` exist on the `Model` and on the `Simulation`, and
**a `Checkpoint` is the `Model`'s state beside the run's cursor**
([D-319][d-319]). `checkpoint(model)` returns the state alone, a
`ModelState`. It holds the flat buffer, the `s` and `m` stores, the whole
signal table, the guard priors, `t`, `t₀`, the fingerprint (the structural
layout) and the deployment. It is legal at `:consistent` with the clock on a
grid top. `checkpoint(sim)` wraps that state with the run's frame index and
boundary ordinal ([D-319][d-319]). It is a stopped-sim service, legal in
`initialized` and `stopped` ([§14][s14]), and refused as `ServiceLifecycle` in
any other state. It is refused wherever the executor is not at the rest a
published frame top leaves (`CheckpointMidFrame`, [Appendix C][sC]). That is
after a `t*` stop, which leaves the clock mid-frame with the remainder
abandoned, and after a frame abandoned unpublished ([§12.4][s12-4]). The test
is that the clock sits on a grid time and that the latest snapshot is of that
very boundary.

`restore!(model, model_state)` checks the state's fingerprint and deployment
against the model, and a mismatch is `CheckpointMismatch`. It also checks that
the state's `t` is a grid time `t₀ + k·h` of the state's own origin and step,
and a state off its grid is `CheckpointMidFrame`. Every mismatch of either kind
is collected into one throw before any write. The entry point then copies the
state back, settles the restored boundary through the hooks and writes
`:consistent` last ([D-318][d-318], [D-319][d-319]).

`restore!(sim, cp)` takes the four recording keywords `init!` takes. It checks
the state's fingerprint and deployment against the simulation as replay checks
the [trace header](#g-trace-header) (the trace's fixed preamble), and a
mismatch is `CheckpointMismatch` ([§12.7][s12-7]). It checks the state's `t`
against its grid as the model's entry point does, collecting both kinds into
one throw. It then copies the state back, opens a fresh run with the
checkpoint as its trace header, and publishes one snapshot at the
checkpoint's `t`. It runs no [sweep](#g-sweep) (one pass through the execution order against
the current state), evaluates no guard, runs no update and
resets no prior. The next frame is the original lattice's next frame, because
the clock came with the checkpoint. The boundary ordinal continues, being the
trajectory's ([§12.3][s12-3], [D-274][d-274]). The snapshot `restore!`
publishes is a re-publication. It carries the ordinal of the boundary the
checkpoint was taken at, and the next frame publishes under the next ordinal,
as it did in the original run.

`restore!(sim, model_state)` is the door a state prepared on a standalone
model takes into a simulation ([§9.2][s9-2], [D-319][d-319]). It takes the
same keywords and makes the same check of the state's fingerprint and
deployment, and it refuses a state whose `t` is off the grid as
`CheckpointMidFrame`. It opens a fresh trajectory at the state's frame, and
the restored boundary publishes under ordinal 0, as boundary zero's does. A
standalone model published nothing, so the trajectory has no ordinals to
continue. A `Checkpoint` holds a `ModelState{Float64}`, so it is nominal by
type. A state taken at another scalar is refused by dispatch with the same
`CheckpointMismatch`, on either `restore!` that takes a bare state.

#### Device attachments across runs

**Device attachments persist across re-initialization** ([D-088][d-088], [D-388][d-388]), because
attachment is orthogonal to the run lifecycle ([§11.3][s11-3]). Persistence means
*roster* persistence, the [roster](#g-roster) being the list of attached device entries.
Binding, [claims](#g-claim) (the set of faces a device may write) and device id survive.
Tasks and OS resources do not, the per-run topology being specified in [§11.1][s11-1] and
the teardown in [§12.4][s12-4]. Each `run!` re-initializes every rostered device and
spawns a task for each whose `init!` succeeds ([§11.1][s11-1], [D-093][d-093]). `attach!` while
stopped only registers, and the task appears at the next `run!`.

Which devices get a task at each `run!` is decided as [§11.1][s11-1]
specifies. **A front end attached by hand is still rostered**
([D-310][d-310]), so the next `run!` spawns its task again.

#### The stop policy per advance

**The stop policy is declared per advance** ([D-255][d-255], [D-316][d-316]). `t_end` and
`ignore_stop_requests` are keywords of `run!`, `replay!` and `step!`. Each call
builds and validates the [`StopPolicy`](#g-stop-policy) (the immutable value of `t_end` plus the
ignored requester paths) it passes to the loop ([§13.5][s13-5], [D-255][d-255], [D-316][d-316]). The value
lives as long as the call, and afterwards only on the termination record of the
advance that ended the run ([D-260][d-260]). A second run, or a `step!` sequence between
two runs, can therefore stop on a different clock or honour a different set of
stop requests without a rebuild.


### 12.7 Replay: the trace re-drives the ordinary loop

This section specifies [replay](#g-replay), re-running the ordinary loop on a recorded input
[trace](#g-trace), so that a recorded session can be inspected, its errors reproduced and
its run continued live. A trace is the primary record of a session, a fixed
[trace header](#g-trace-header) plus the [batches](#g-batch) drained at each [frame](#g-frame). A batch is a [device](#g-device)'s
staged set of writes, and a device is any attached participant in the periphery.
A frame is one iteration of the loop, from drain to publication. The [drain](#g-drain) is
the frame-top swap that applies staged device writes to the [root inputs](#g-root-input). The
root inputs are the root component's own inputs, the only thing the periphery
may write. `replay!` is the entry point the trace exists for ([§11.5][s11-5]):

```julia
trc  = trace(sim)                     # the recorded session: header + per-frame batches
sim2 = Simulation(world)              # the same build
replay!(sim2, trc)                    # restore the header, then re-drive every recorded frame
replay!(sim2, trc; to_boundary = k)   # partial: the §13.4 replay-pointer idiom
replay!(sim2, trc; to_time = 100.0)   # partial: the same halt addressed by time
cp   = checkpoint(sim)                # the state at a frame-top rest
restore!(sim2, cp)                    # that state alone: a warm restart, no feed
```

The parts below cover the one substitution replay makes, halting and the
[input mode](#g-input-mode) (where the drain takes its batches from) across
halts, what stays the loop's, and the validation up front. They then cover the
[what-if replay](#g-what-if-replay), re-driving the recorded inputs through a
modified model, with the `restore = false` form, which attaches the feed to
the simulation as it stands. The rejected shapes close the section.

#### One substitution

**`replay!` is the ordinary loop with exactly one substitution**, not a second
loop ([D-101][d-101], [D-274][d-274]). That is what keeps every property proved of the loop true
of replay. The substitution is the drain, which reads the trace. Under the
default form, `replay!(sim2, trc)` above, the loop also starts from a restored
state.

The default form restores from the header. It restores the trace's [checkpoint](#g-checkpoint)
(the `Model`'s state at a frame top, beside the run's frame index and boundary
ordinal), the state the recording opened from. It runs no [boundary zero](#g-boundary-zero) (the
initialization boundary at `t₀`). This form stands in the `init!` position of
the lifecycle ([§12.6][s12-6]) and does what `restore!` does, with the trace header as
the checkpoint ([D-274][d-274]). There is no [condition](#g-condition) resolution, and the
[root-input totality](#g-root-input-totality) (every root input must hold a value) ([§14.6][s14-6]) held when the
recording's `init!` ran. A condition is the datum that says "set this build to
this state". Whatever fired at `t₀` is part of the restored state, so nothing is
applied twice and nothing is skipped ([D-274][d-274], [D-399][d-399]).

The drain reads the trace. Each frame top applies the recording's batches for
that [frame ordinal](#g-frame-ordinal), the frame index a batch replays at ([D-101][d-101]). It does not swap
the [staging cells](#g-staging-cell) of the [roster](#g-roster) (the list of attached device entries). A staging
cell is where a device's pending write batch waits between drains. Ordinal
keying is exact because the frame sequence is itself deterministic under replay
(`t*` boundaries derive from state, [§10.4][s10-4]). Frame *k* of the replay *is* frame
*k* of the recording. Recorded batches apply verbatim, with no surface re-check
([D-101][d-101]). The [write-surface](#g-write-surface) rule (the bound on the [faces](#g-face) a writer's batch entries
may reach) ([§11.3][s11-3]) ran at recording time, and [claims](#g-claim) (the set of faces a device
may write) are a live-roster fact of the recorded session that replay does not
reconstruct. A face is the name a port wears on its component's boundary.

A simulation is in one of two input modes, `:live` or `:replay`, and **the mode
decides which source that one drain branch reads** ([D-218][d-218]). Under `:live` it
reads the staging cells, and under `:replay` the attached recording. **`replay!`
attaches the recording and enters `:replay`** ([D-218][d-218]). `step!` and `run!`
consume it from there, frame by frame, exactly as the drain paragraph above
describes. There is still one loop and one drain ([D-218][d-218]).

A mode that outlives the call makes a partial replay a resumable position rather
than the end of an operation ([D-218][d-218]). Whatever advances the simulation
next reads the same mode and finds the same records. That is what lets the
reproduction workflow of [§13.4][s13-4] run through the ordinary entry points, with no
replay-only spelling of `step!`.

#### Halting, and the mode across halts

**In `:replay` the recording is the bound** ([D-218][d-218]). Every advance's frame
budget is capped at the recording's last frame, and `to_boundary = k` caps it
earlier. That keyword is the consumer of the replay pointer ([§13.4][s13-4]). `to_time`
is the same cap addressed by time (below). Either keyword names a frame from the
one the feed starts from through the recording's last, and anything else is
refused (`ArgumentInvalid`). The feed starts from the header's frame under the
default form, and from the simulation's own under `restore = false` (below).

`to_boundary = k` takes the frame-entry boundary index ([§13.4][s13-4]), a count of frame
tops. It is not the published-boundary ordinal that a [snapshot](#g-snapshot) (the immutable
per-boundary publication) carries ([§12.3][s12-3]). **Replay runs through frame `k` and
halts exactly at the frame top after it** ([D-128][d-128]). Replay therefore always halts
at a frame top. A [localized](#g-localized) `t*` boundary (the crossing instant bracketed by
root-finding over trial sweeps) inside the frame is reproduced but not
stoppable-at ([D-128][d-128]). The trace stays frame-indexed, replay pointers and error
messages use the frame-entry boundary index, and snapshots carry the
published-boundary ordinal ([§10.4][s10-4], [§12.3][s12-3]).

Replay may also end earlier still under the ordinary policies, since `t_end` and
`ignore_stop_requests` are keywords of `replay!` exactly as of `run!` ([§12.6][s12-6],
[D-255][d-255], [D-316][d-316]). A termination the recorded session hit through a [stop request](#g-stop-request) (an
output port of the framework enum `StopFlag`) reproduces itself anyway,
deterministically ([D-127][d-127], [D-393][d-393]). A replay honours requests by default too, and
the trace header records no policy. So a replay of a live run that ignored some
must pass the same `ignore_stop_requests`.

**`to_time` halts at the last frame top at or before the time given**, the same
halt addressed by time, and it is mutually exclusive with `to_boundary` ([D-219][d-219]).
It computes `k = ⌊(to_time − t₀)/h⌋` against the header's `t₀`, under either
form. A time falling between two frame tops floors onto the earlier one.

The rounding is the deliberate opposite of `t_end`'s, which ends a run at the
first grid boundary reaching or exceeding it ([§12.4][s12-4]). `t_end` bounds
a run, and `to_time` positions an inspection. The point of halting is to
stand *before* the anomaly, so a halt that stepped past it would defeat the
call ([D-219][d-219]).

`to_time` is validated as the other keywords are. The value must be real, finite
and at least `t₀`, and it must name a time the recording covers. The checks run
before the replay writes anything, the default form's restore included.

The halt flips the mode only at the recording's end. A frame budget that runs
out halts the loop at a frame top, leaving the simulation `initialized`
([§12.6][s12-6]). **The mode becomes `:live` exactly when that halt lands at
the recording's last frame**, with the records exhausted ([D-218][d-218]). It
stays `:replay` otherwise, and the next `step!` or `run!` goes on consuming
the recording. So no advance ever flips mid-run. A `run!` whose `t_end` lies
past the recording halts at the last recorded frame, now `:live`, and the
*next* call is the live continuation ([D-218][d-218]).

`live!` is the one call that moves the mode alone. The flip above is automatic.
`live!(sim)` performs it by hand. **`live!` sets the mode to `:live` and
detaches the recording's remainder, touching nothing else** ([D-219][d-219]). The
trajectory stands where the replay left it, and so does the trace with its
header, inherited under the default form. The next `run!` or `step!` is
therefore the live continuation from the replayed boundary, and its drains
append to the re-recorded prefix ([D-219][d-219]). `live!` is a stopped-sim operation,
legal only on an `initialized` simulation in `:replay`. Every other state refuses
under the ordinary lifecycle gates ([§12.6][s12-6]), with `MissingInit` at `built` and
`ServiceLifecycle` in the rest. A simulation already `:live` refuses too, with
`ArgumentInvalid`. The call would have nothing to do, and a loud refusal beats a
silent no-op ([D-219][d-219]).

That call is what makes the rewrite workflow real. An interactive session is
interrupted at t = 110, and the last ten seconds are to be flown again:

```julia
trc  = trace(sim)                     # the interrupted session, out to t = 110
sim2 = Simulation(world)
replay!(sim2, trc; to_time = 100.0)   # halt at the last frame top at or before 100
latest(sim2)                          # inspect the boundary landed on
live!(sim2)                           # drop the remainder; the mode is :live
run!(sim2; t_end = 130.0)             # live from t = 100, re-recording onward
```

The trace `sim2` leaves behind is a complete recording of *itself*, the replayed
prefix out to t = 100 and then the frames flown live after it, since replay
re-records (below).

A replay's halt leaves the simulation `initialized`, never `stopped` ([D-218][d-218]).
That state is boundary-consistent and ready to advance, the same state `step!`
leaves ([§12.6][s12-6]). This is what makes three promised workflows real ([D-101][d-101]).
State-trajectory inspection asks "what was the private state at t = 37.2?", and
answers it by replaying there and reading the live stores ([§11.2][s11-2]). Error
reproduction replays to the frame-entry boundary `k` the error names, then
`step!`s the failing frame on its recorded inputs, under instrumentation
([§13.4][s13-4]). Continuation is `run!` after `replay!`, a live session from the
replayed boundary. After a full replay that is the next call, the records
exhausted at the halt. After a partial one the remainder of the recording is
consumed first, across as many `step!` and `run!` calls as the caller makes, and
the session goes live at the recording's end. Or `live!` drops that remainder,
and the continuation starts at the halt.

#### What stays the loop's

**Replay re-records** ([D-101][d-101], [D-391][d-391]). The drain records normally. Under the
default form the new trace inherits the old header and accumulates the
re-drained batches, a bit-identical prefix. Under `restore = false` the new
trace's header is the simulation's own checkpoint (below). A
replayed-then-continued session therefore leaves behind a complete, valid
trace of *itself*, with no special stitching.

**[Pacing](#g-pacing) and the [control plane](#g-control-plane) are unchanged** ([§10.7][s10-7], [§12.1][s12-1], [D-101][d-101], [D-391][d-391]). The
control plane is the separate atomic surface carrying pause, pace and stop.
Pacing (waits inserted between completed frames, never altering the boundary
sequence) sits outside the semantics, so paused, slow-motion or real-time replay
is free. Paced replay with an attached visualizer *is* session playback, and
`replay!` takes `pace` and `margin` as `run!` does ([§12.1][s12-1], [D-269][d-269]). Stop
truncates, as anywhere.

Devices are readers ([D-218][d-218]). Rostered devices init and spawn normally
([§11.1][s11-1]) and consume snapshots ([§11.2][s11-2], [§12.3][s12-3]). That
is the visualizer case. But no live staging cell is drained while the
simulation is in `:replay`. A batch found staged is discarded with a
rate-limited warning (`ReplayDiscardedStaging`, [Appendix C][sC]). Mixing live
writes into a replay would destroy the property replay exists to provide. A
session that wants live input is a continuation (`run!` after replay), not a
replay.

#### Validation up front

**Validation is loud and up front** ([D-101][d-101], [D-391][d-391]). Before the first frame, the
checkpoint's [deployment](#g-deployment) (the scalar-free artifact the grid parameters fix) is
compared against the target's. Its fingerprint, the structural layout, is
compared against the `Build`. The fingerprint covers the store layout, the
root-input faces, and what a copy by position relies on ([§11.5][s11-5]). The trace's
batch entries are validated against the root input-face list, and each batch's
frame ordinal against the recording's frames, from the one after the header's to
the last ([D-217][d-217]). Each writer's face-name → position schema, on the trace's
`schemas` list ([§11.5][s11-5]), is validated in the same pass. A recorded schema that
disagrees with the target model's own root-input faces is a replay error. The
checks are attach-style, and a failure reports [did-you-mean](#g-did-you-mean), the offending name
plus the list-in-hand it should have matched. The kinds are
`CheckpointMismatch`, `ReplaySchemaMismatch` and `ReplayUnknownFace`
([Appendix C][sC]). The pass runs under both forms of `replay!`.

The same pass pays the trace-record conversion in reverse. Every writer's
sparse records ([§11.5][s11-5]) are normalized to positional batches against
the trace's `schemas` list, once, off the loop ([D-101][d-101], [D-391][d-391],
[D-176][d-176]). Replay has the whole trace in hand before frame 1. The replay
drain therefore applies compiled scatters exactly as the live drain does, and
no face name is resolved per frame under replay either.

*Structural* mismatch is an error. *Parametric* difference is not
([D-101][d-101], [D-391][d-391]).

**The checkpoint check compares two deployments as values** ([D-254][d-254]).
The checkpoint carries the recorded run's `Deployment`, the target
simulation's `Model` carries its own, and the check is their comparison, on
the *structural* side of that line. The value covers the
trajectory-determining parameters, `Δt_base`, `h`, `N_base`, the algorithm,
`localization_tol`, `localization_budget` ([§10.4][s10-4]) and
`firing_budget` ([§10.6][s10-6], [D-133][d-133]). It also covers the
[schedule](#g-schedule) (the typed per-component `(D, Φ, Δt)` tick table) with
every column, the anchor and rate-chain columns included. A rate re-declared
through a different anchor at the same tick table is therefore a different
deployment, and the replay is refused. The refusal costs one re-recording in
a rare case, and it keeps the equality a plain value equality rather than one
that ignores two of a row's columns. Mismatch is `CheckpointMismatch` with a
deployment-parameter discriminator, never a what-if ([D-127][d-127]). A
deployment change moves the times at which the frame-ordinal batches apply.
That is different inputs, not a modified model. The event trio (the
localization pair and `firing_budget`) is compared for exactly the same reason
the grid parameters are. It moves the trajectory, so a run that differs in it
is not re-driving the recorded one. Comparison by value is what makes the
check one expression rather than a field-by-field walk.

Under the default form the clock is *restored*, not compared. That form restores
`t₀` with the rest of the clock, so `replay!` takes no `t0` argument ([D-127][d-127]).
Under `restore = false` the simulation's own clock runs, and its origin must
equal the recording's. The checkpoint holds no policy ([D-255][d-255]). `t_end` and
`ignore_stop_requests` are keywords of this `replay!` call, validated per call
as at `run!`.

The dispositions, by trace content:

| trace content | disposition |
|---|---|
| the checkpoint's fingerprint: store layout, root-input faces, and what a copy by position relies on | compared against the `Build` |
| the recorded `Deployment`, carrying `Δt_base`, `h`, `N_base`, the algorithm, `localization_tol`, `localization_budget`, `firing_budget` | compared as a value against the deployment the target simulation's `Model` carries |
| each writer's face-name → position schema (on the trace's `schemas` list) | validated against the target model's root-input faces: disagreement is a replay error |
| the checkpoint's state | restored under the default form; no boundary zero |
| the clock | restored under the default form, `replay!` takes no `t0`; under `restore = false` the simulation's own clock runs, its origin equal to the recording's |
| `t_end`, `ignore_stop_requests` | absent from the checkpoint; each `replay!` call declares its own ([§12.6][s12-6]) |

#### What-if replay and `restore = false`

Replaying against the same structure with changed parameters is the what-if
replay. It is spelled as `init!` of the modified model under the authored
condition, then `replay!(sim, trc; restore = false)`. The trace is not
self-sufficient for it. Its checkpoint holds the recording model's state after
boundary zero, so the authored condition comes from outside ([D-274][d-274]).
Bit-identity is promised only against the identical build ([§2.4][s2-4]). What-if replay
promises determinism, never reproduction.

`replay!(sim, trc; restore = false)` attaches the feed to the simulation as it
stands and restores nothing ([D-404][d-404]). The simulation must be `initialized`, at the
recording's `t₀`, and at a frame from the header's to one short of the
recording's last. A simulation that is not `initialized` meets the lifecycle
gate before any write, with `MissingInit` when it is `built` and
`ServiceLifecycle` in any other state. One whose origin or frame is off the
recording's is refused before any write as `CheckpointMismatch`, its clock arm.
One grid is thus an invariant of every replay, and `to_time` has one meaning.
The drain applies the records from the frame after the simulation's own.

This form is a door like the default one, an entry point that builds a run
([§12.6][s12-6]). It builds a fresh run under the recording keywords, takes
the simulation's own checkpoint as the new trace's header, and publishes one
snapshot. That form serves the what-if of a modified model initialized under
the authored condition (above). It also serves a seek, `restore!` of a
checkpoint the recording passed through followed by the feed from the next
frame ([D-274][d-274], [D-399][d-399]).

#### Rejected shapes

Three shapes are rejected for the record ([D-101][d-101]). They are a
`run!(sim; replay = trc)` flag, a synthetic playback device staging the
recorded batches, and replay ending `stopped`. The input mode clarifies that
decision's drain substitution rather than replacing it, and carries its own
rejected shapes ([D-218][d-218]).

---

# Part IV — Failure and services

Part IV covers what happens when things go wrong, and what a stopped simulation
can be asked to do. [§13][s13] is the error discipline. It fixes which failures
are collected and which fail fast, and the diagnostic value both produce. It
fixes the single runtime catch site and the execution cursor that locates a
failure inside a frame. And it explains why graceful termination is model state
rather than an exception, and how a rejected cycle is diagnosed. [§14][s14]
is the stopped-sim services.
[§14.1][s14-1]–[§14.6][s14-6] build the condition (a path-addressed overlay on
the declared defaults) and apply it through boundary zero. Applying a condition
is the initialization service. [§14.7][s14-7]–[§14.10][s14-10] build trim and
linearization on that same foundation.

Part IV assumes both earlier parts. [§9.1][s9-1] and [§9.2][s9-2] already fixed when each check
runs, so [§13][s13] fixes only how a failure is reported once it happens.
[§8.6][s8-6] supplies the paths a condition addresses. [§9.4][s9-4] supplies the
activations trim and linearization run on. [§10.6][s10-6] supplies the
macro-sequence that boundary zero re-runs with an empty integrate.

## 13. Error discipline

This chapter fixes how a failure is reported once it happens, and what the
framework offers around it, taking as given what must be caught and where ([§8.4][s8-4])
and when each fact is checked ([§9][s9]). [§13.1][s13-1] covers the reporting policy; [§13.2][s13-2] the
diagnostic representation; [§13.3][s13-3] the build primitives and how path resolution is
scoped by client; [§13.4][s13-4] how a runtime failure is caught, carried and reproduced;
[§13.5][s13-5] the distinction between "the model reached a terminal state" and "the run
should end"; [§13.6][s13-6] abnormal shutdown, one tail with two entries; [§13.7][s13-7] the
tooling and component library that follow; and [§13.8][s13-8] the diagnosis of a rejected
cycle. Two lessons FlightCore paid for ground this chapter. The first is the
compact-backtrace discipline, needed because parameterized model types make
rendered output unreadable. The second is the `SimulationTermination` machinery,
which [§13.5][s13-5] replaces.

### 13.1 Reporting policy: collect the checks, fail the evaluations fast

The build's failure sites split into two populations. That split settles the
choice between fail-fast and compiler-style reporting. Each population takes
the policy that fits it. This section covers, in order, the two populations
and their policies, the step barrier, the dependency rule that decides which
passes run past a failure, and the absence of cascade suppression.

**Declarative checks over collected structure collect, and user-code
evaluation fails fast** ([D-057][d-057]).

- The collecting checks are those for unconnected inputs, two producers, wire
  typos and type mismatches, [face](#g-face)-name uniqueness,
  `y_types`/state-field consistency and `sample_times` validation. Each is a
  pass over a list. The whole-tree obligation check literally computes *the
  set of* inputs whose obligation chain never terminates. Reporting every
  violation is the natural output of such a pass, and truncating to the first
  would be extra work. These failures also cluster in practice. A freshly
  written [assembly](#g-assembly) (pure composition, with no dynamics of its
  own) has five unwired inputs, and a renamed [port](#g-port) breaks three
  wires. Each of these passes returns its full violation list.
- User code runs in the build's first three steps ([§9.1][s9-1]). The structure step
  reads the declaration bodies, interface-connection bodies among them. The
  nominal evaluation runs every user function once, through the stage-1 [probes](#g-probe)
  (the build's single evaluations of a user function) and the probe chain. The
  activation at the scalar type `T` runs the continuous tier's functions. When
  user code throws, there is no meaningful rest of the collection to report. A
  failed `input_wires` leaves the parent's face derivation undefined. A failed
  stage-2 probe starves every downstream probe of its wired inputs, because
  [probe values](#g-probe-value) (the fabricated values a build-time probe runs on) flow
  topologically ([§9.3][s9-3]). The first user-code exception aborts the phase ([D-057][d-057]).

The build's steps are barriers ([D-259][d-259]). A step that produced any
error-severity diagnostic, from either population, throws before the next step
begins. Probing against unresolved wiring would be meaningless.

**Collection reaches the step barrier, under a dependency rule**
([D-229][d-229]). A declarative pass runs when the results it reads are clean.
It records every violation it finds and returns a total result. Every pass
that ran merges into the barrier's one throw.

Whether a pass can run past a failure follows from what it reads. The structure
step's walk yields two results, the component list and the wiring. A wire that
fails to resolve is recorded and claims nothing, so the obligation check reports
its input as unfed. Tier and event checking read only the component list, so
they run and merge. A structural failure leaves the subtree behind it unknown.
An unreadable or mixed [class](#g-class) (a component's primitive-vs-assembly status) or a
malformed container is such a failure. No pass can read past it, so it throws
alone. In the two evaluating steps the probe chain consumes each check's subject
as it goes. A check that reads a failed probe does not run, so the chain's
fail-fast follows from the same rule. Outside the build the unit is the call.
Deployment validation ([§9.2][s9-2]) runs every check whose premise holds and throws
once. The only partial results ever carried past a failure are violation lists
and a claim table with the failed wires absent. None of the three steps
therefore needs machinery for carrying partial internal results across a
failure. That machinery was the cost that kept this decision open, and it never
materializes.

**There is no cascade suppression within a step** ([D-057][d-057]). This is a
deliberate simplification. A wire typo'd as `:throtle` produces two errors.
One is a [did-you-mean](#g-did-you-mean) error (the offending name plus the
list-in-hand it should have matched). The other is an unconnected-input error
for the intended `throttle`. Both are reported in the one throw, and the
did-you-mean names the input the other error says is unfed, so the pairing
explains itself.

### 13.2 Diagnostics: structured values, one carrier exception

Both reporting policies move the same thing. What a collecting pass returns and
what a fail-fast site produces is in either case a *diagnostic*. The shape of
that value decides what an acceptance test can assert and what a user reads.

#### The diagnostic and its carrier

**A diagnostic is a plain value from a small closed set of [kinds](#g-kind)** ([D-058][d-058]).
[Appendix C][sC] enumerates that set normatively. For each kind it records the kind
name, the [payload](#g-payload) fields (the structured data a diagnostic carries beside its
kind), the owning section, the severity, where the kind is raised and under
which policy ([D-214][d-214]). That index is the reference the [§8.4][s8-4] walkthroughs, run as
acceptance tests, and the error-message work are written against. Tests match on
kind plus payload fields, never on message text, so messages are pure
presentation ([D-058][d-058]).

Each kind carries its own structured payload. The payload holds endpoint paths,
[face](#g-face) names, expected and observed types, and the *list-in-hand* a [did-you-mean](#g-did-you-mean)
needs. A did-you-mean is the offending name plus the list-in-hand it should have
matched. A kind *is* a Julia type.

**Severity is a property of the kind, not of the occurrence** ([D-214][d-214]). It is `error`
or `warning`, and it says whether an occurrence ever throws. It is read as
`severity(d)` and never stored per occurrence. The severity field of [Appendix C][sC] is
derived from it. Where an occurrence surfaces (build, service or runtime) and
how it is reported (collected, fail-fast, logged or rate-limited) are the *raised*
and *policy* fields of [Appendix C][sC]. Those two fields describe the occurrence, not
the kind. `BundleFieldError`, for example, is raised at the [probe](#g-probe) and, at runtime,
as a [species](#g-species) of the runtime carrier `StepError` ([§13.4][s13-4]). A species is a `StepError`
whose `cause` is a diagnostic.

Checking passes return diagnostics. The step barrier (each of the build's three
steps throws before the next begins) throws a single `DiagnosticError` wrapping
the collection. A fail-fast site throws the same [carrier exception](#g-carrier-exception) (the single
exception diagnostics travel in when thrown) holding one diagnostic. **The
carrier's type parameter spells the policy** ([D-222][d-222]). It is the diagnostic's kind
for a fail-fast throw and `Vector{Diagnostic}` for a collected one. A test
therefore asserts policy and kind at once with
`@test_throws DiagnosticError{Kind}`. `StepError{C}` takes a parameter of its own,
the type of its `cause` ([§13.4][s13-4], [D-225][d-225]). `showerror` renders a collection
compiler-style, grouped by kind and sorted by path. It renders a single
diagnostic as its own line.

```julia
# a diagnostic value: its kind is its identity, its payload is plain data
abstract type Diagnostic end
struct WireTypeMismatch <: Diagnostic   # one kind of the closed Appendix C set
    …                                   # payload fields per Appendix C: paths and
                                        # names as Strings, port types as types
end

# the carrier: one exception, its parameter the policy — a kind for a
# fail-fast throw, the collection type for a barrier's throw
struct DiagnosticError{P <: Union{Diagnostic, Vector{Diagnostic}}} <: Exception
    carried::P
    warnings::Vector{Diagnostic}   # the build's warnings so far, rendered with the throw
end
```

Two rendering rules are doctrine, not style ([D-058][d-058]).

- The first rule is *strings, never instances*. Diagnostics carry paths and names
  as strings, never [component](#g-component) instances and never component types. This is the
  lesson of FlightCore's `compact_backtrace`. Expected and observed *[port](#g-port)* types are
  the one payload exception, and they are small. Examples are a `Float64` against
  a `Bool`, and a NamedTuple field diff.
- The second rule is that the didactic style is policy. Every diagnostic states
  the fix or the lists-in-hand, not just the violation. Examples are "return
  `zero(x.ω)`, not `0`" and "no input `throtle`; did you mean `throttle`?", or the
  child's face list shown alongside the unknown name given to `except`.

A user-code exception is wrapped in a framing diagnostic, `UserCodeFraming`, with
the original exception as `cause`. The framing carries the component path, the
function that threw, and the probe context, which is the [bundle](#g-bundle)'s field names
(the bundle is the NamedTuple of zero-copy views a component function receives)
and the synthesized inputs as a spelling, never as values ([D-248][d-248]). The didactic
framing therefore renders first and the raw throw second. **The framed set is
every user-authored method the build invokes** ([D-248][d-248]). The declarations of [§8.2][s8-2]
and the probed functions of [§9.3][s9-3] are framed alike, each reached through one
framing accessor rather than a bare call. A declaration takes no bundle, so only
the plain framing applies to it. Three exceptions pass through the framing
unwrapped, because none of them is user code failing. They are a `DiagnosticError`
carrier a check inside the call threw, an `InternalInvariant` (the exception a
framework self-check raises, outside the kind set) ([D-215][d-215]), and an
`InterruptException`. At runtime the same throw reaches the one runtime catch site
([§13.4][s13-4]) instead. There a `FieldError` matched as below becomes a `BundleFieldError`
species, and any other exception rides as the `StepError`'s `cause`.

**One exception type, the `FieldError`, is recognized rather than merely
framed** ([D-341][d-341]). A `FieldError` carries its type and field as data
(Julia ≥ 1.12). At the probe the framework matches them against the bundle's
own NamedTuple type, which the accessor holds. At the runtime catch site it
matches them against the bundle's field names, because the bundle's type
there is the activation's and is not in hand ([D-248][d-248]). A tuple the
author builds with the bundle's own names is indistinguishable from the
bundle at either site, and the diagnosis stays true of it. The result is the
bundle-law did-you-mean ([§5.2][s5-2]). It carries the legal field set and
classifies the miss as an undeclared store, a wrong [tier](#g-tier) (the
continuous or discrete side of the hybrid formalism), or a field illegal for
this function. Nothing is recovered by reading message text.

The probe raises the result as `BundleFieldError` ([Appendix C][sC],
[D-248][d-248]). An example message is "`systems/plant`: `x_deriv`
destructures `m`, but `systems/plant` declares no `m_init`". The message names
the component by its path. One law covers tier facts, stage legality and
declarations alike. The wrong-tier miss covers the state letters too
([D-195][d-195]). `x` and `m` are continuous-only, and `s` and `Δt` are
discrete-only, so destructuring any of the four on the wrong tier is a
wrong-tier fact. The bundle stays a bare NamedTuple ([D-074][d-074],
[D-341][d-341]). A getproperty-wrapper spelling is the recorded fallback,
should type-matched interception prove insufficient ([D-341][d-341]).

#### Where warnings live

**A warning raised while producing an [artifact](#g-artifact) lives on that
artifact** ([D-250][d-250]). A warning raised while mutating
[state](#g-state-single-owner) lives in that state's status. Logging is
presentation and never a home. An artifact is an immutable pure function of
its inputs. State is single-owner and mutated in place. That one criterion
places every warning the framework raises.

The build produces artifacts, so its warnings live on them. [§9.2][s9-2] states which
artifacts carry them, how `warnings(x)` reads the list, and how a step that throws
or completes presents them. The build's warning set holds `EmptyFaceSelection`
([§8.8][s8-8], [D-251][d-251]). The warning set of the [`Deployment`](#g-deployment) (the scalar-free artifact the
grid parameters fix) holds `GridUtilization` ([D-254][d-254]). The unconnected-output
warning stays rejected ([§6.1][s6-1], [D-084][d-084]), so the *collected*-warning category stays
open and empty. A warnings-as-errors switch is rejected, since a warning is a
fact about the model, not a defect ([D-250][d-250]).

A stopped-sim service returns an artifact, so the facts its warnings report
live on it. `trim!` returns a `TrimReport`, which holds the fired events and
both residual sets, and logs `TrimCommitEvents`, `TrimCommitResiduals` and
`TrimCommitChecks` beside it ([§14.8][s14-8]). The line the call prints at
return is presentation. `attach!` is the other side of the criterion. It mutates
the [roster](#g-roster) (the list of attached device entries). `EmptyGreedyClaim` therefore
lands in the roster entry's [diagnostic cell](#g-diagnostic-cell) (the per-writer cell for runtime
diagnostics and liveness) ([§11.6][s11-6], [D-250][d-250]).

The runtime mutates state, so its warnings live in that state's status. These
warnings form a per-occurrence stream. The per-writer diagnostic cells carry it
([§11.8][s11-8], [D-136][d-136]). The rate limit lives in the diagnostic cells, as a structural
bound rather than a policy layered over the stream. The bound is a bounded ring
plus per-kind suppressed counts, drained at frame top. So "rate-limited wherever
its source can repeat" holds of every kind below without any kind arranging it.
The stream surfaces through the published [framework status](#g-framework-status) (the frozen value
each snapshot carries beside the signal table) ([§11.2][s11-2], [D-369][d-369]). The liveness
heartbeat ([§12.2][s12-2]) rides in the same diagnostic cells, and the pacer's record
([§10.7][s10-7]) sits beside the writers' records in the status. The stream is never
collected, since there is no collection to join. Nothing in the argument of
[D-084][d-084] applies to it. That decision is about what the *build* warns on.

The committed runtime warnings, in one place, are these.

- `ChatteringBudget`, for [chattering](#g-chattering) or localization-budget exhaustion ([§10.4][s10-4]). A
  [localized](#g-localized) event's crossing instant is bracketed by root-finding. The event's
  bracketing budget runs out at a [boundary](#g-boundary) (a published consistency point).
- `FiringBudget`, firing-budget exhaustion ([§10.6][s10-6]). An event has
  spent its `firing_budget` at a boundary, and its further edges there are
  dropped.
- `DebtReanchor`, a forgiven-debt re-anchor ([§10.7][s10-7]). The pacer
  abandons its accumulated debt and re-anchors its schedule.
- The write-surface and batch-entry violations ([§11.3][s11-3], [§11.4][s11-4]), all raised at
  staging. The [drain](#g-drain) (the frame-top swap that applies staged writes) checks
  nothing. `OutOfClaimEntry` ([§11.3][s11-3]) is an enumerated surface's binding drift, a
  name with no position in the attach-compiled schema. `ClaimedFaceEntry` ([§11.3][s11-3],
  [§11.4][s11-4]) is a harness write to a face claimed in the run's frozen partition, and
  it names the incumbent. The stopped-sim attach also fires it when it
  renormalizes a pending [batch](#g-batch). `EntryTypeMismatch` ([§11.4][s11-4]) is a value
  unconvertible to the declared type of its [root input](#g-root-input) (the root component's own
  input face), rejected at staging for every writer.
- `MalformedDatum`, a tolerated datum failure on the side of a [device](#g-device) (any
  attached participant in the periphery) ([§11.6][s11-6], [§13.4][s13-4]). It is emitted by the
  author's loop via `report!(handle, …)` into the device's own diagnostic cell
  ([§11.8][s11-8], [D-105][d-105]). It replaces FlightCore's `InputMappingError`.
- `ReplayDiscardedStaging`, staging discarded during [replay](#g-replay) (the ordinary loop
  re-driven from a recorded trace) ([§12.7][s12-7]). It reports a live batch found staged
  while the [trace](#g-trace) (the primary record of a session) feeds the drain.
- `ThreadBudget`, thread-budget tightness ([§12.2][s12-2], [D-401][d-401]). It
  is raised once per run, at `run!` or `replay!`, against the frozen roster.
- `DeviceJoinTimeout`, a device join timeout ([§12.4][s12-4]). A device task exceeds the
  shutdown join timeout and is abandoned by name rather than hanging `run!`. It
  arises after the terminal snapshot. It is therefore collected into the
  [termination record](#g-termination-record) (the stopped-sim value naming how the run ended) and
  presented through the logging backend, never carried into a status ([D-201][d-201],
  [D-203][d-203]).
- `DeviceCrash`, a device crash ([§12.4][s12-4], [§13.4][s13-4]). The framework wrapper catches a
  device task's failure, and the run goes on without the device unless its
  attachment set [`should_abort`](#g-should_abort) (the per-attachment failure policy, an `attach!`
  keyword) ([§11.6][s11-6]).
- `UnboundedRun`, an unbounded run ([§13.5][s13-5]). It lands in the loop's own diagnostic
  cell, because `run!` mutates state ([D-255][d-255]).

### 13.3 Build primitives: `resolve` and the face-list accessors

The `input_passthrough` sketch ([§8.8][s8-8]) calls two of the primitives below without
defining them. This section gives the three forms, the two duties resolution
enforces, which client each duty binds and why, and the standing of
`resolve_terminal`.

**All three are normative in the forms given here** ([D-061][d-061]).

- `resolve(assembly, path::String) → AbstractComponent` resolves an immediate
  child, a container element's key segment included.
- `input_faces(c)` / `output_faces(c) → Vector{String}` return the stringified keys
  of a leaf's `u_types` / `y_types` (the key set is `T`-independent). For an [assembly](#g-assembly)
  they return the [face](#g-face) names (the names ports wear on their component's
  boundary) of `input_wires(c)` / `output_wires(c)`. Declaration order is preserved,
  which gives deterministic printouts and stable diagnostics.
- `resolve_terminal(assembly, path) → (component, name)` splits off a terminal
  path's final segment and resolves the prefix through `resolve`. The split is
  unambiguous because face names may contain dots but never slashes ([§8.6][s8-6]).

Resolution enforces two duties, and they belong to different clients. The first
is the one-level rule ([§6.1][s6-1], [D-207][d-207]). A connection endpoint resolves to an
immediate child and one of its faces. A wiring path reaching further is a build
error, `PathResolution`, whatever the declared field types along it. The second
is the service walk, which governs the deep paths a service or a reader is
given. **The service walk follows the structure's children and refuses no
traversal past a generically held child** ([D-414][d-414]). Every service and
the read resolver run the walk over an authored path. A deep path resolves
wherever the structure has it, whatever the declared field types along it,
and a [port](#g-port) (one declared input or output) of a generically held
child is as reachable as one of an owned child. An unknown segment errors with
the sibling field list in hand. Paths are validated before anything runs on
them, and renames break loudly ([D-061][d-061]).

**Which rule applies depends on who is resolving** ([D-130][d-130], [D-414][d-414]).
[D-083][d-083] separates the reads a build's correctness rests on from the reads
that only observe it. The same line runs through resolution. Wiring gets the
strict rule, and every other client gets the walk.

| client | who resolves | what resolution enforces |
|---|---|---|
| wiring | connection declarations, in the structure step | the one-level rule: an immediate child and one of its faces |
| service | [condition](#g-condition) entries (the path-addressed sparse overlay that sets a build's state), trim `reads`, [taps](#g-taps) (the three selector lists declaring what linearization seeds and reports), [device](#g-device) read [bindings](#g-binding) (the values passed at `attach!` that make a device framework-legible), log extraction by `series` ([§14.3][s14-3], [§14.7][s14-7], [§14.10][s14-10], [§11.2][s11-2], [D-406][d-406], [D-407][d-407]) | the service walk: every segment names a child the structure has, at the authoring or mount level |
| inspection | [snapshot](#g-snapshot) (the immutable per-boundary publication) and log inspection | the address table: a cell the structure has |

Each client's treatment has its own warrant. Wiring is what the law ([§6.1][s6-1]) is
stated for, so wiring resolution applies that law verbatim. Under one-level
routing no deep path exists there, because an endpoint stops at the immediate
child. Service paths are walked at the authoring or mount level for two
reasons. First, the locality law is an authoring-level law, and absolute paths
are a compiled derivative ([§14.2][s14-2]). Second, the mount itself walks a
mount prefix, where the problem's authored names resolve through the export
chain from the mount point ([§14.9][s14-9]). So the walk covers the authored
path below that prefix. Drift stays loud. A binding's unknown path or name is
refused at attach, as a `PathResolution` or a `ReadResolution`, with a
[did-you-mean](#g-did-you-mean) (the offending name plus the list-in-hand it
should have matched) ([D-406][d-406]). Inspection reads the address table.
"What is in *this* build" is its defining question, and it is the service
walk's as well. The stop scan, the one read a run acts on, belongs to
[§13.5][s13-5].

The split is one principle, not a concession. What varies between wiring and
the other clients is not how far a client is trusted. It is what a violation
costs, and where the cost lands. A service path or an inspection read is a
value applied to one build. A path the structure no longer has fails at its
own site, loudly, with the candidates in hand, harming only the caller. A
wiring entry is carried by the declaring *type* and compiled into every
instantiation. That is why its endpoints stop at the boundary. A wire
reaching past one would fail at substitution time, at a different site, for
whoever exercised the substitution the field advertised. That is the
non-local failure class the error discipline exists to eliminate
([§8.4][s8-4]). The rule is strict exactly where a promise depends on it, and
relaxed exactly where none is made ([D-083][d-083], [D-130][d-130],
[D-414][d-414]). A generic [seam](#g-seam) (a narrow, named interface kept
deliberately thin) is therefore no error for any path. An author who ships a
fragment or a problem that reaches into one child of a generically held
field scopes it by dispatch on the holding's type parameter, and an author
who wants a read to outlive the build binds a face ([§14.2][s14-2],
[§14.4][s14-4]). Both are authoring guidance, and neither is checked.

Which treatment a client resolves under is internal framework fact, never
user-facing API ([D-130][d-130]). The two ways of applying one plan
([§14.4][s14-4]) use the same arrangement and have the same status.

Inside the framework only wiring resolution calls `resolve_terminal`. Condition
addressing ([§14.3][s14-3]) and the readers ([§14.4][s14-4], [D-406][d-406]) split their own paths through
the service walk.

### 13.4 Runtime failures: one catch site, an execution cursor

A runtime failure of model code is a throw inside a [frame](#g-frame) (one iteration of the
loop) or inside [boundary zero](#g-boundary-zero). Boundary zero is the initialization [boundary](#g-boundary) (a
published consistency point), and it runs the ordinary boundary macro-sequence
with an empty integrate. The framework catches the failure at one site, records
where execution stood, and names how to reproduce it. This section covers, in
order, where a failure is caught, the runtime carrier, the interrupt, the
disposition, reproduction, boundary zero, the nonfinite check and device-side
failures.

#### Where a failure is caught

The [`Model`](#g-model) is the deployment and its executor at one scalar. **The `Model`'s `frame!`
wraps each whole frame, every boundary it settles included, in a single `try`**, and
its `init!` wraps boundary zero the same way ([D-317][d-317]). The code inside the `Model`'s
`try` is the guarded sequence. A boundary's macro-sequence runs integrate →
project → event iteration → [ticks](#g-tick) → publication. Ticks are the instants at which
discrete leaves run their stages and update. **`frame!` never wraps per stage or per
[component](#g-component)** (the unit of modeling, a leaf or an assembly of components) ([D-059][d-059]).
The loop wraps each frame in a `try` of its own, which decides the failure's
disposition (below) and builds no carrier ([D-317][d-317]).

Where execution stood does not need to be *caught* into existence. The [executor](#g-executor)
(the compiled form of the stage [execution order](#g-execution-order)) maintains an [execution cursor](#g-execution-cursor),
a plain mutable field of the executor recording where execution stands in the
compiled order ([D-059][d-059]). The cursor records three facts. The first is the
component, by its index in the structure's component list, the index the
execution order lists ([D-261][d-261]). That order is the one [`Outputs`](#g-outputs) (the nominal
evaluation's product, the output port names each stage produces and the
execution order) carries. The second is which function is running, one of
`y_state`, `y_direct`, `x_deriv`, `s_update`, a [guard](#g-guard) (the declared function defining an
event's predicate), a handler, or `x_projection`. The third is the boundary phase,
one of the frame-top drain, integration stage *k*, the arrival [sweep](#g-sweep) (one pass
through the execution order), the θ = 0 validation, a localization trial,
projection, event round *r*, or the ticks. Maintaining the cursor costs one cheap
store per dispatch on a single-tasked executor, with no allocation and no
exception handlers. It covers every user-code surface uniformly, including the
forgettable ones. Those are the evaluations of the [RHS](#g-flow) (the continuous
derivative function) at interior RK stage points and the guard evaluations at
the trial points of ITP or Brent root-finding ([§10.4][s10-4]).

```julia
# the cursor: one mutable field of the executor, overwritten per dispatch
mutable struct ExecutionCursor
    …    # what it records, per the prose above: component path
         # (component-list index), which function, and the boundary phase
end
```

#### The runtime carrier

The catch site wraps the original exception in `StepError`, the runtime
counterpart of the `DiagnosticError` [carrier](#g-carrier-exception) (the single exception diagnostics
travel in when thrown). A `StepError` carries five things. They are the cursor
frame (the cursor's copy at the catch), the time, the frame-entry boundary
index, the host of the catch, and the original exception as `cause`. The time is
the clock at the failure, a boundary time in a boundary phase, the stage or
trial time inside integration. **The frame-entry boundary index is the [replay](#g-replay)
pointer** ([D-128][d-128]). Replay is the ordinary loop re-driven from a recorded [trace](#g-trace).
The trace is the primary record of a session. The pointer names the frame-top
boundary at which the failing frame began. That frame top is a grid boundary or
boundary zero, and it is always a legal replay halt ([§12.7][s12-7]). The host names the
catch that took the throw. It is `:loop` for a throw inside a frame, and
`:boundary_zero` for a throw inside the boundary zero that `init!` runs. A `StepError`
renders under the doctrine of [§13.2][s13-2]. The cursor frame and the reproduction come
first, the cause second, and names are strings.

Conformance failure ([§9.5][s9-5]) needs no separate path. At the table-write
point it throws as every fail-fast site does, a `DiagnosticError` holding the
one diagnostic, and it arrives at the same catch site ([D-235][d-235]).
**The catch site unwraps a single-diagnostic `DiagnosticError` thrown inside
the guarded sequence**, and the `StepError`'s `cause` is that diagnostic
([D-221][d-221]). That unwrapping is the species rule. A
[species](#g-species) of `StepError` is one whose `cause` is a diagnostic. The
conformance failure's species carries the field-diff [payload](#g-payload)
(the structured data a diagnostic carries beside its kind). The rule keeps the
catch site the only `StepError` constructor. A `StepError` arriving at the
catch site is therefore an invariant failure, while a runtime check stays a
plain thrower of its kind ([D-221][d-221]). A collected carrier has no single
kind and rides as `cause` unchanged. No runtime check throws one.

**The cause's type is the carrier's parameter** ([D-225][d-225]). `StepError{C}` takes the type
of its `cause`, bounded to a diagnostic or an exception. A species is therefore
`StepError{Kind}`, and a raw throw is `StepError{ArgumentError}` and the like.
`isa StepError` matches both ([D-225][d-225]). A test asserts a species as
`@test_throws StepError{ConformanceFailure}`, the runtime spelling of the build
carrier's idiom ([§13.2][s13-2]). A collected carrier riding as `cause` is an exception and
falls under that arm. A bare value thrown deliberately by model code is neither,
and the constructor refuses it, so it propagates from the catch unwrapped. The
framework does not handle that throw ([D-225][d-225]). The cursor frame and the pointer
are then lost, and the lifecycle does not move as it does when the catch builds
a `StepError`.

```julia
# the runtime carrier: its parameter the cause's type — a diagnostic's kind
# for a species, the exception model code threw otherwise
struct StepError{C <: Union{Diagnostic, Exception}} <: Exception
    cursor         # the cursor frame: the cursor's copy at the catch
    t::Float64     # the clock at the failure
    boundary::Int  # the frame-entry boundary index: the replay pointer
    host::Symbol   # :boundary_zero under init!, :loop inside a frame
    cause::C
end
```

#### The interrupt

An `InterruptException` is the one exception the catch site never wraps ([D-317][d-317]).
It is not model code failing. It is the operator's stop command ([§12.4][s12-4]). So the
catch site discriminates it and routes it to the stop path ([D-132][d-132]). The run
takes the ordinary graceful tail and ends `stopped`, never `errored` under a
`StepError`. With the boundary masking in force ([§12.4][s12-4]) a single interrupt never
reaches the interrupt branch. It is deferred to a frame-top, wait or pause-block
unmask point ([§12.4][s12-4], [D-294][d-294]), and never raises inside the guarded sequence.
Julia's forced throw after repeated interrupts does reach it, with the
disposition [§12.4][s12-4] gives it ([D-398][d-398]). The branch is kept for that case and
defensively, because the cost of being wrong about the masking is a terminally
errored session in place of a clean stop.

#### The disposition

The `Simulation` ends in a terminal status, `stopped` or `errored`, with the exception
retrievable ([D-059][d-059]). A synchronous [unattended run](#g-unattended-run) (a run with empty staging and
no snapshot readers) rethrows after the shutdown tail completes, so CI fails
honestly. An interactive session logs the rendered error. **`run!` and `replay!`
discriminate the two by the [roster](#g-roster)** (the list of attached device entries)
([D-268][d-268]). With no [device](#g-device) (any attached participant in the periphery) rostered the
run is unattended and rethrows. With one or more it logs the rendered error
through the logging backend and returns, the lifecycle reading `errored` and
`termination(sim)` retaining the cause. `step!` is deviceless by construction
([§12.6][s12-6], [D-389][d-389]) and always rethrows.

#### Reproduction

Reproducibility holds by construction. Staged inputs are drained and recorded to
the trace at the frame top, *before* the boundary executes. So the failing
boundary's inputs are already in the trace when it fails. The error names the
frame-entry boundary `k` to replay to. `replay!(sim2, trc; to_boundary = k)` halts
exactly at that frame top ([D-128][d-128]). It halts in `:replay`, the [input mode](#g-input-mode) that
keeps the recording attached, so the failing frame's record is still ahead of
the simulation ([§12.7][s12-7], [D-218][d-218]). `step!` then applies that record and re-executes
the failing frame under instrumentation, [localized](#g-localized) boundaries included.

```julia
replay!(sim2, trc; to_boundary = k)   # halt at the frame top; still :replay
step!(sim2; frames = 1)               # re-execute the failing frame, instrumented
```

#### Boundary zero

**Boundary zero is caught too, under the service's disposition** ([D-223][d-223]). Boundary
zero runs inside `init!`, a stopped-sim service, not inside the loop. The
simulation's `init!` calls `init!` on its `Model`, which runs boundary zero. Its
macro-sequence executes the same user-code surfaces the frame's does, with the
cursor maintained through them, so the `Model`'s `init!` hosts the same catch
([D-317][d-317]). A throw inside boundary zero arrives as a `StepError` from the one
constructor. Its cursor frame comes from the cursor, its time is `t₀`, its pointer
is `0`, and the species rule applies. Any throw inside boundary zero writes the
`Model`'s status back to `:built`, which returns the simulation's lifecycle to `built`
([§12.6][s12-6]). An `InterruptException` inside boundary zero is not model code failing,
and it has no stop path to take in a service. The host therefore lets it
propagate raw, unwrapped.

A throw inside boundary zero leaves no trace and no [checkpoint](#g-checkpoint) (the `Model`'s
state at a frame top as one value). The run `init!` opened stays behind, empty and
with no trace header, and the run before it is gone. Nothing can use it, since
`trace(sim)` and the advances refuse a `built` simulation. `init!` takes the trace
header only after boundary zero publishes ([§11.5][s11-5]). **The reproduction of a
boundary-zero failure is `init!` under the same [condition](#g-condition)** (the path-addressed
sparse overlay that sets a build's state) ([D-274][d-274]). Boundary zero is frame one's
entry boundary too, so a frame-one failure carries the same pointer. The
carrier's `host` tells the two apart, and the rendered recipe reads it. A
frame-one failure has a trace, and the halt-then-`step!` recipe above holds for it
at pointer `0`. The halt restores the header and stops there, and `step!`
re-executes frame one from the record.

Boundary zero's disposition differs from the loop's as well. Nothing was
published and no advance was under way, so there is no tail to take and no
snapshot to promote. The simulation returns to `built`. `run!` and `step!` refuse it
and name `init!` ([§12.6][s12-6]), while `init!`, `restore!` and `replay!` remain legal. The
remedy for a condition that fails at `t₀` is a corrected condition, and `init!`
re-establishes every [store](#g-store) (the framework-owned home of one of a component's
state letters) before it applies one ([§14.1][s14-1]). No [termination record](#g-termination-record) (the
stopped-sim value naming how the run ended) is written. The stores may hold the
half-transitioned `t₀` state until the next `init!`, `restore!` or `replay!` resets
them. They are retained for inspection, as an errored simulation's are ([§13.6][s13-6]).
`trim!`'s commit is an `init!` ([§14.8][s14-8]) and inherits the rule ([D-223][d-223]).

#### The nonfinite check

Divergence is not termination. Dynamics that blow up (ground penetration, an
unstable gain) produce NaNs that defeat guards. NaN comparisons are false, so no
declared guard will catch them. An `isfinite` pass over the flat state [buffer](#g-buffer) (the
contiguous vector backing all continuous state), run by the model after every
return from the integrator backend, fails fast as `NonfiniteState`, a `StepError`
species naming the component, the state leaf and the frame-entry boundary. It
catches diverging models generally, not just post-terminal ones.

**The pass is the boundary's first act** ([D-157][d-157]), and that placement is the whole of
its value. The pass runs immediately after integrate returns, before
`x_projection` and before the boundary sweep. Run there, `NonfiniteState` names the
component whose own block diverged. Run later, the NaN has already propagated.
It reaches an innocent downstream component through the ordinary signal path and
surfaces as that component's lookup-table `DomainError`, or as an `InexactError` in
its conversion. That is the inversion of [error locality](#g-error-locality) (the property that a
mistake fails at the site of the mistake) ([§8.4][s8-4]), designed out of the build and
quietly reintroduced at runtime. One `isfinite` pass over a flat buffer is cheap
enough that placement, not cost, decides.

**`ẋ` does not participate in the check** ([D-157][d-157]). A nonfinite
derivative contaminates its own state block's step result within that very
step. The `x` check at the next boundary is therefore the same detection with
identical component attribution. And `ẋ` buffers are integrator scratch. They
are written per stage, meaningful only inside a step, and not
boundary-consistent in the sense the check is stated over.

#### Device-side failures

Under domain separation, device-side user code fails in the
device's own domain, because loop bodies and mappings run on the device task
([§11.4][s11-4], [§11.6][s11-6]). It fails in two classes ([D-105][d-105]).
A genuine bug takes the per-device crash path. The wrapper reports
`DeviceCrash`, and the run goes on without the device unless its attachment
set [`should_abort`](#g-should_abort) (the per-attachment failure policy, an
`attach!` keyword) ([§11.6][s11-6]). The liveness heartbeat is how a hang
shows instead ([§12.2][s12-2]). An unmappable datum is not a failure at all.
The loop body tolerates and reports it as `MalformedDatum` ([§11.6][s11-6]).
Device code shares no mutable state with the model ([D-022][d-022]), so the
two failure domains never mix.

### 13.5 Termination is a state, not an exception

This section specifies how a model ends its own run, how an advance chooses
which stop requests to honour, and what the run records when it ends.
FlightCore's `SimulationTermination` idiom (model code throws, and the loop
catches and logs it as informational) **has no counterpart here** ([D-060][d-060]). **Graceful
termination is model state, never an exception** ([D-060][d-060]). It reaches the loop
through declared machinery. The discipline is that **exceptions from model code
are always abnormal** ([D-060][d-060]).

The wall-clock channel, through a front end's stop button ([D-310][d-310]), a
device handle or code, is orthogonal and untouched. That is the operator path
of the [control plane](#g-control-plane) (the separate atomic surface carrying
pause, pace and stop). The sim-time, model-detected channel specified here
meets it at [§12.4][s12-4] and nowhere else.

The section covers, in order, detection and publication, placement and
requesters, the policy per advance, the scan and the source order, unbounded
runs, the termination record, ignored requests and post-terminal dynamics, and
the rejected mechanisms beside the reads a run acts on.

#### Detection and publication

Detection is ordinary [guard](#g-guard) (the declared function defining an event's
predicate), handler and mode machinery ([D-060][d-060]). If the stop should be localized,
declare the [predicate](#g-predicate) (a `Bool`-valued form, or the sign of a continuous
function) as a sign-form event. Such an event is [localized](#g-localized) (the crossing instant
bracketed by root-finding over trial sweeps). A landing-gear strut's touchdown
overload is precisely a zero-crossing. The [boundary](#g-boundary) (a published consistency
point) is localized to the crossing, and the handler sets `m.crashed`. The
[snapshot](#g-snapshot) (the immutable per-boundary publication) at the crossing instant
carries the touchdown state.

Publication is a [stop request](#g-stop-request), an output [port](#g-port) (the addressable unit of the
model) of the framework enum `StopFlag`, declared where the stop's `Bool` is
detected. **A port whose type is exactly `StopFlag` is a stop request**, whoever
publishes it ([D-316][d-316]). The enum is `@enum StopFlag NO_STOP STOP_REQUESTED`. An
enum is one leaf, pinned at every activation ([§4.3][s4-3]), and [cells](#g-cell) (typed entries of
the signal table) are stored per element type ([§9.7][s9-7]), so every request in the
model lands in one `StopFlag` block. The stop's `Bool` is gathered at the
boundary of the assembly that owns it, in one visible block. The landing gear
`Ldg` from the example of [§6.1][s6-1] ORs its three legs through a junction (the
ownership idiom, [§6.2][s6-2]; the library, [§13.7][s13-7]). It wires the result into a
`StopRequest` child, described below. No level above it re-exports anything,
because the loop reads the request where it is.

**The library spelling is `StopRequest`** ([D-316][d-316]). It is a stateless
continuous leaf in the mould of `Constant` ([§13.7][s13-7]). Its one input is
the stop's `Bool`, its one output the flag, and its reason is instance data.

```julia
# StopRequest — a stateless continuous leaf; its reason is instance data
struct StopRequest <: AbstractComponent
    reason::String
end
StopRequest(; reason = "") = StopRequest(reason)
x_init(::StopRequest) = (;)
u_types(::StopRequest) = (request = Bool,)
y_types(::StopRequest) = (flag = StopFlag,)
y_direct(::StopRequest, (; u)) = (flag = u.request ? STOP_REQUESTED : NO_STOP,)
stop_reason(c::StopRequest) = c.reason
```

Its output is consumed by nobody, which [§6.1][s6-1] allows silently ([D-084][d-084]).
`StopRequest` is continuous, so it refreshes at every boundary, `t*` included
([§10.4][s10-4], [D-316][d-316]). Assemblies are virtual for execution and rate scopes touch
discrete children only, so one leaf sits anywhere in the tree ([§10.5][s10-5], [D-019][d-019]).
Fed by a discrete detector, it sees the tick at the tick's own boundary, because
the boundary sweep walks the full execution order in topological order ([§10.5][s10-5],
[D-147][d-147]). The block holds no privilege. Any [component](#g-component) (the unit of modeling, a
leaf or an assembly of components) may publish a `StopFlag` port directly.

#### Placement and requesters

Placement is checked at build. **Two placements are `IllegalPortType`** ([D-316][d-316]). A
`StopFlag` leaf nested inside a port of another type is refused with reason
`:stop_flag_nested`, and a root input whose type carries a `StopFlag` anywhere
with reason `:stop_flag_at_root`. The first is refused because the build lists
requests per port, so a request inside a struct field or a static array would
have no listing of its own. The second is refused because a request is the
model's, never an operator's. A `StopFlag` input port places nothing and is left
alone.

**The build records one `Requester(path, port, reason)` per `StopFlag` output
port**, as the `requesters` of the activation's cell layout, index-aligned with
the `StopFlag` block ([D-316][d-316]). This list is the [requester roster](#g-requester-roster) (the build's
list of stop requests, one `Requester(path, port, reason)` per `StopFlag` output
port, in build order), and it names every request. The requester at index `i`
owns the block's offset `i - 1`. The reason is the publishing component's
`stop_reason`, an optional declaration with default `""` ([§8.2][s8-2]). One reason
serves all of a component's requests. It is instance data on the component,
never a port value.

#### The policy per advance

[§12.6][s12-6] declares the stop policy per advance, with `t_end` and
`ignore_stop_requests` as keywords of `run!`, `replay!` and `step!`, and gives
the value's lifetime. Each of the three calls takes `Inf` and `()` as the
defaults ([D-255][d-255]). The defaults belong to the calls that take the policy. With no
constructor defaults the [trace header](#g-trace-header) (the trace's fixed preamble) has no policy
to record ([§11.5][s11-5]). The [termination record](#g-termination-record) (the stopped-sim value naming how the
run ended) carries the policy that actually ended the run. The ignore list,
`ignore_stop_requests`, sits beside `t_end` at the same declaration site.

**Every request is honoured unless the advance ignores it** ([D-316][d-316]).
`ignore_stop_requests = :all` ignores every requester. An iterable of
strings names requesters by component path. Each path is validated against
the requester roster on every call, and duplicates collapse, in the order
given. A path naming no requester is `StopRequestInvalid`, collected over the
given paths ([Appendix C][sC]). A `t_end` that is not a non-negative real is
`ArgumentInvalid`, refused before the ignore list is read ([D-413][d-413]).

Each advance builds a [`StopPolicy`](#g-stop-policy) (the immutable value of `t_end` plus the
ignored requester paths), and passes it to the loop with an ignore mask, one
`Bool` per requester, as a second argument ([D-316][d-316]). A `t*` hit reaches the loop
as the return value of the `Model`'s `frame!`, a `Bool` saying whether the frame
was abandoned, never as a field of the policy or of the [execution cursor](#g-execution-cursor) (the
field recording where execution stands) ([D-261][d-261], [D-317][d-317]). The loop then reads the
requester off the snapshot it just published.

#### The scan and the source order

**After *every* published boundary the loop scans the `StopFlag` block of the
snapshot it just published**, in requester roster order ([D-316][d-316]).
Grid boundaries, `t*` ([§10.4][s10-4]) and [boundary zero](#g-boundary-zero)
(the initialization boundary at `t₀`) ([§14.5][s14-5]) all count. The first
honoured request reading `STOP_REQUESTED` initiates [§12.4][s12-4] shutdown
with *this* snapshot as the final one. The terminal snapshot is the terminal
state. There is no roll-back, and nothing [§12.4][s12-4] does not already do.
That terminal snapshot's status carries the run's final cumulative diagnostic
counters ([§11.8][s11-8]).

Every advance checks the latest snapshot for an honoured request before its
first frame ([D-413][d-413]). After `init!` that snapshot is boundary zero's, so an
authored [condition](#g-condition) (the path-addressed sparse overlay that sets a build's state)
already terminal ends the run at `t₀` with that snapshot final, integrating
nothing. A run that starts later ends where it started, advancing no frame.

**The sources are consulted in a fixed order** ([D-203][d-203]). The loop checks a pending
control stop at frame top, then `t_end`, then the stop requests at each
publication. When two sources hold at one boundary, the termination record names
the first in that order ([D-203][d-203]).

Authors are taught that stop requests are sampled at completed boundaries, and
that a stop that must be localized needs a sign-form event. Both shapes of the
stop's `Bool` feeding a request work without framework latching. A handler-set
`m` flag is sticky by nature. A transient stage-2 Bool is caught because the
loop reacts to the first request it reads holding. Compound stop logic composes
in-model, as a monitor component reading the relevant signals and feeding one
request. That is the same move [§12.5][s12-5] made for scripts.

#### Unbounded runs

**An unbounded run is allowed** ([D-255][d-255]). `run!(sim)` with `t_end = Inf` and no
honoured request is the interactive session's ordinary shape, and the [operator
interrupt](#g-operator-interrupt) (Ctrl-C, read as a control-plane stop) is its escape ([§12.4][s12-4]). The
model may have no requester, or the advance may ignore them all. `run!` raises
`UnboundedRun` before the loop starts, into the loop's own [diagnostic cell](#g-diagnostic-cell) (the
per-writer cell for runtime diagnostics and liveness), and the status record
carries it ([§11.8][s11-8], [D-255][d-255], [D-316][d-316]). Its message says which of the two cases holds.
The advisory fires in `:live` only. A `run!` in `:replay` is bounded by the
recording, whatever its policy says ([§12.7][s12-7], [D-218][d-218]).

```julia
sim = Simulation(world; h = 1//50)          # no policy here: the deployment has none

init!(sim, cond); run!(sim; t_end = 60)                     # every request honoured
init!(sim, cond); run!(sim; t_end = 60,
                        ignore_stop_requests = ("ldg/stop",))  # one requester ignored, by path
init!(sim, cond); step!(sim; frames = 100)                  # Inf and (), the defaults
init!(sim, cond); run!(sim; ignore_stop_requests = :all)    # unbounded: UnboundedRun, then fly
```

#### The termination record

**The termination record names the source, as a typed value** ([D-203][d-203]). The run's
termination record carries its *outcome*, and the `StopPolicy` of the advance that
ended it ([D-255][d-255], [D-260][d-260]). The record holds four things, the final boundary time,
the terminating policy, the source and the tail residue (the post-account
diagnostics the run's-end sweep folds in). [§11.8][s11-8] specifies that sweep. **The time
is always present**, because boundary zero precedes every record and a throw
inside boundary zero writes none ([§12.6][s12-6], [D-233][d-233]). The source follows the
diagnostic convention, so its type is its identity and its payload is plain data
([§13.2][s13-2], [D-203][d-203]). There are four source types.

- `EndTimeReached` means `t_end`'s frame completed. It has no payload. The
  record's own `t` is the fact, and the bound that was configured is in the
  record's own policy.
- `ModelRequestedStop` means an honoured stop request read `STOP_REQUESTED`.
  The payload is the requester's component path, its port and its reason.
  When two requests hold at one boundary, the record names the first in
  requester roster order ([D-316][d-316]).
- `ControlRequestedStop` means a control-plane stop. The payload is its
  issuer, the requesting device, `:code` or `:interrupt` ([§12.1][s12-1]).
- `LoopError` means the abnormal entry of [§13.6][s13-6]. The payload is the
  propagated cause. A throw inside the frame reaches the record with the
  `Model` already marked `:inconsistent` by its own catch, and the simulation
  reads `errored`. A loop fault outside the frame, in the pacer, a yield or
  the tail, closes the run as `stopped` with the `Model` consistent at its
  last settled boundary, since only the `Model`'s own catch sites mark it
  ([D-317][d-317]). The record covers both exactly alike.

A `stopped` simulation therefore answers "why did it stop?" without its
consumer reconstructing the answer from the clock. It answers "how did the
stop go?" from the same value. **The operator interrupt is a tag on an
ordinary stop**, not a source type of its own, because nothing failed
([D-203][d-203]). [Appendix C][sC] gains nothing from it.

#### Ignored requests and post-terminal dynamics

An ignored request is still a cell in every snapshot, so the log records when
validity broke even on a run that continued ([D-316][d-316]). Two uses share
the mechanism, validity breakdown and scenario completion. The reason string
is what tells a reader which, and the framework never will ([D-412][d-412]).

Post-terminal dynamics are the model's job, and that is a feature. `robot2d`,
FlightApps' self-balancing robot in Flight.jl, *throws* `LostBalance`, a
`SimulationTermination`, past 45° of tilt, because it has no other way to say
"my dynamics are no longer meaningful". Here it declares the fall as an event,
switches to a frozen mode, and feeds `fallen` to a stop request. The frozen mode
is a mode-dependent `x_deriv`, machinery the model already has. Honoured, the
request ends the sim at the fall. Ignored, the sim integrates a frozen robot,
which is well-defined, unlike an uncaught throw. The discipline forces models to
have well-defined terminal states, which is better modeling ([D-060][d-060]).

#### Rejected mechanisms and the reads a run acts on

The rejected mechanisms, litigated in [D-060][d-060] and [D-316][d-316], are predicate closures
such as `stop_when = snap -> …`, root-type-declared stop policy, `terminal`
event flags, a control-plane capability for components, observation-by-path (an
advance naming a deep path into any public output), and the `Bool` face
re-exported level by level to the root and named by the advance. The per-advance
policy is not the root-type-declared one, and the re-exported face fell to stop
requests. [D-060][d-060] also rejected [blessed](#g-blessed) (explicitly sanctioned where a neighboring
practice is forbidden) terminal types scanned from the tree, an arm the stop
request supersedes on its own terms.

Rejecting observation-by-path separates inspection from the reads a run acts on,
a line [D-316][d-316] narrows ([D-409][d-409]). Inspection is human-facing, has no effect on run
semantics, and legitimately sees every public cell. The log retaining the full
table, a front end's panels rendering a component's ports, and inspection under
[replay](#g-replay) (the ordinary loop re-driven from a recorded trace) are all inspection. A
read the run acts on changes what the run *does*, and it reads only what the model
declared for it, never an arbitrary cell. The stop scan is the one such read. It
reads the `StopFlag` block, which holds nothing but the requests their authors
declared by type. [§13.3][s13-3] scopes path resolution by client, on a line of its own.
The ignore list addresses the `Build`'s requester roster, a build product like
the root-input list. It binds at an advance, a stopped-sim point where
conditions already address state by path ([§14.1][s14-1]). The requester is loud at
inspection, since the requester roster and the termination record name it. A
substitution that changes when runs end is answered by the ignore list ([D-060][d-060]),
and disabling is one keyword. The trigger is the author's knowledge and the
ignore list the integrator's. Output devices are the other half of the same
doctrine. Their reads are inspection on snapshot paths ([§11.2][s11-2]), though attach
resolves them strictly, as [§13.3][s13-3]'s service clients ([D-406][d-406]).

### 13.6 Abnormal shutdown: one tail, two entries

A failure on the loop's side can arrive in the middle of a
[boundary](#g-boundary) (a published consistency point). The run must still
end through the shutdown tail of [§12.4][s12-4], which starts from a final
[snapshot](#g-snapshot) (the immutable per-boundary publication). This
section gives the abnormal path, the reason it is safe, the two entries
charted, the record it writes, tail hygiene, and what an errored simulation
keeps and refuses.

**The abnormal path discards the failed boundary, promotes the previous snapshot
to final, and rejoins the ordinary tail** ([D-030][d-030], [D-408][d-408]). The protocol becomes one
tail with two entry points. Graceful entry follows a *completed* final boundary,
and abnormal entry follows a *discarded* one. Everything downstream of "final
snapshot" runs identically. That covers sticky stopped, waiters woken through
the boundary-counter plus `Condition` path, the hooks `unblock!` and
`shutdown!`, and named joins with timeout. Those waiters observe stopped rather
than a new boundary, so no [device](#g-device) (an attached participant in the periphery) is
left with a hanging task.

The abnormal path is safe because the boundary is all-or-nothing outside the
loop ([D-030][d-030]). That is why a `StepError` cannot break [§12.4][s12-4]. [Sweeps](#g-sweep) (passes
through the execution order) write into table blocks. Integration intermediates
live in framework-owned integrator buffers, never in the scratch of a [component](#g-component)
(the unit of modeling, a leaf or an assembly of components). That scratch is its
[workspace](#g-workspace) (declared by allocation and excluded from state semantics), as [§7.3][s7-3]
defines it. The only externally visible act is snapshot publication at the very
end of the sequence. A boundary that throws has published nothing. The last
*published* snapshot is a complete, consistent boundary by construction, and it is
still the newest thing any device, logger or waiter has seen.

```
  graceful entry                      abnormal entry
  final boundary completes            failed boundary discarded
  final snapshot published            previous snapshot promoted to final
             |                                   |
             +-----------------+-----------------+
                               |
                       "final snapshot"
                               |
       sticky stopped → waiters woken → unblock! and shutdown!
                     → named joins with timeout
```

This fills the seat [§12.4][s12-4] reserved for it. A loop-side failure runs
the same protocol from the catch path ([D-030][d-030]). The
[termination record](#g-termination-record) (the stopped-sim value naming how
the run ended) covers this entry too. Its source is `LoopError`, and the
payload is the propagated cause ([§13.5][s13-5], [D-203][d-203]).

Tail hygiene follows from the hooks being user code too. Each is individually
caught and logged. Shutdown therefore runs to completion even if a device's
hook misbehaves. The join timeout already bounds a hook that hangs rather than
throws.

What is lost is quarantined. A throw inside the frame leaves the [stores](#g-store) (the
framework-owned homes of a component's `x`, `s` and `m`) possibly holding
mid-boundary values, such as a half-written `m` or integration intermediates.
They are retained on the errored simulation for post-mortem inspection. An
errored simulation is terminal, not resumable, and the reproduction tool is
[trace](#g-trace) [replay](#g-replay) (the ordinary loop re-driven from a recorded trace), not
resurrection ([§12.6][s12-6], [D-059][d-059], [D-387][d-387]). A trace is a session's record of its drained
inputs. The stopped-sim services enforce the non-resumability by refusing an
errored simulation outright (`ServiceLifecycle`, [§14][s14], [D-108][d-108]). Operations on the
[roster](#g-roster) (the list of attached device entries) refuse it with them ([§11.3][s11-3], [D-232][d-232]).
Inspection is reading, but `attach!` configures a run that cannot follow. The
published record (snapshot chain, log, trace) ends at the last consistent
boundary. Nothing downstream of the sim ever sees half a boundary.
### 13.7 Tooling consequences: face routes and the component library

Generic-holding [contracts](#g-contract) (each a component's declared interface) are a
structural customer of computed interface connections, which are therefore
prominent in this section. [D-062][d-062] makes three tooling commitments for them,
namely the passthrough helpers' predicate, the routes `show(::Structure)` prints
for each root [face](#g-face) (the name a port wears on its component's boundary), and a
standard library of [components](#g-component). Components are the units of modeling, each a
leaf or an assembly of components. The section covers the predicate and the face
routes first, then the standard component library and the component test rig.

The passthrough helpers take a predicate. `select` is the third
selector beside `except` and `only`, on `input_passthrough` and
`output_passthrough` alike ([§8.8][s8-8], [D-251][d-251]). It stays explicit at
the declaration site, evaluated at build, and printable. That is the
[blessed](#g-blessed) (explicitly sanctioned where a neighboring practice is
forbidden) side of the auto-bubbling line, where the author writes down the
*rule* and the build evaluates it into inspectable data. Auto-bubbling means
promoting an unconnected input automatically to a
[root input](#g-root-input), one of the root component's own input faces
([D-322][d-322]).

Every artifact renders itself through `show` ([§9.2][s9-2], [D-257][d-257]). [`Structure`](#g-structure) (the
structure step's product, the components, wires, faces and tiers) has one.
**`show(::Structure)` owes face routes** ([D-257][d-257]). For every root face, that means
the resolved chain down to the producing terminal, printed as one line per chain
(`crashed → aircraft/crashed → aircraft/monitor/out`). Once faces are computed
rather than hand-listed, "what does this face actually reach" is a question the
artifact must answer, not the reader. `show(::Structure)` derives each face's
routing chain from the declared wires and prints the root's routes ([D-257][d-257],
[D-315][d-315]). Each line joins the hops with `→` and ends at the terminal. An input
face that fans out prints one line per consumer. The wiring diagnostics name
endpoints in the same slash form.

#### The standard component library

A standard component library makes good on the junction promise
([§6.2][s6-2]). That promise rests on explicit junctions being *cheap*. A
junction hand-written per arity per type is not cheap. The junctions, summing
junctions and Bool gates alike, are the library's seed ([D-062][d-062]).

**A block joins the library's inventory by judgement against three guidelines**
([D-313][d-313]). The guidelines ask whether a block is domain-agnostic and generally
useful, whether it has didactic value, and whether its implementation is
difficult to get right. None is a requirement. They are weighed, not satisfied
one by one, and a listed block is built whenever wanted. A one-line expression
such as a gain earns no block, because a separate component costs a build entry,
a cell, a gather and a scatter ([§9.7][s9-7]). Domain components, such as aerodynamics,
engines or sensors, belong in separate packages built on the framework.
Simulink's library is a language, while this is a toolbox.

The starting inventory holds the `Junction`, with `SumJunction{V, N}`, `Or{N}`
and `And{N}` as its named forms, `UnitDelay{V}`, `Constant{V}`, `Freeze{V}` and
`StopRequest`. The full inventory, and the Simulink mapping that prunes it, live
in `companions/library_inventory.md`. `UnitDelay` is the spelling the second
loop-breaking remedy ([§5.5][s5-5]) needs. `Constant{V}` is the source block ([D-143][d-143]).
`Freeze{V}` is the declared stop-gradient ([D-266][d-266]). `StopRequest` is the library
spelling of a [stop request](#g-stop-request) (an output port of the framework enum `StopFlag`)
([§13.5][s13-5], [D-316][d-316]).

The library is the submodule `Redstone.Blocks`, `Group` included, written
against the extension-only surface ([§8.1][s8-1]) as a user's component file
is ([D-313][d-313]). A workspace sub-package or a separate repository is an
after-release question.

One member is admitted by persona. `Group` is the on-the-fly
[assembly](#g-assembly) (pure composition, with no dynamics of its own), and
its declaration-layer treatment lives in [§8.5][s8-5] ([D-184][d-184]). `Group`
serves the model assembler, for whom topology is data rather than a named
type. It needs no rule the declaration layer does not already have.

The doctrine is that **library blocks are ordinary components**, with no
framework privileges and no special vocabulary ([D-062][d-062]). Ordinary
status is what keeps [schema authority](#g-schema-authority) total
(declarations define structure; evaluation only checks conformance). That
same status makes the library a permanent ergonomics
[torture test](#g-torture-test), a maximally awkward case spelled against the
declaration rules to validate them. If a three-input OR gate is painful to
write under the declaration rules, the rules are wrong.

**Arity and port types come from type parameters** ([D-311][d-311]).
`Junction{In, Out, N, F}` builds `(in1 = In, …, inN = In)` programmatically
and applies the fold its instance holds, so `Or{N}` is the junction at `|`
and `And{N}` at `&`, each a constant alias. A gate exists for its consumer,
which wants one consolidated `Bool` input instead of several. That is a
derivation [§8.2][s8-2] blesses, and an early validation that the contract
functions support parametric components.

```julia
struct Junction{In, Out, N, F} <: AbstractComponent
    f::F                              # the fold, N-ary; instance data
end
const SumJunction{V, N} = Junction{V, V, N, typeof(+)}

x_init(::Junction) = (;)              # stateless, continuous: the empty store is the tier marker (§8.2)
u_types(::Junction{In, Out, N}) where {In, Out, N} =
    NamedTuple{ntuple(i -> Symbol(:in, i), N)}(ntuple(_ -> In, N))
y_types(::Junction{In, Out}) where {In, Out} = (out = Out,)
y_direct(j::Junction, (; u)) = (out = j.f(u...),)
```

The parameters are the nominal port types and the arity, as in
`SumJunction{Wrench{Float64}, 3}`, and the fold is instance data
([D-311][d-311]). `Wrench` is FlightPhysics' force-and-torque type, here
parametrized by its scalar type as a walked type of [§7.2][s7-2].
`SumJunction{V, N}` is the `Junction` at `+`. A custom fold, such as a
weighted blend or a mass-properties composition, is written at the site as
`Junction{In, Out, N}(f)`, which infers `F`.

The junction is a continuous leaf, so its contract is written at nominal
`Float64` and the [leaf walk](#g-leaf-walk) (the framework's derivation of per-activation types
from a declared nominal type) retypes it ([§8.2][s8-2], [D-263][d-263]). An input entry at
`Wrench{Float64}` is the tolerant form a promoting consumer writes. Walking,
frozen and root-input contributors are all admissible behind it.

A named site-specific junction documents a fixed contributor set better than
generated input ports, at the price of hard-coding it into a type ([D-037][d-037]). An
example is `u_types(::VehicleWrenchSum) = (aero = …, ldg = …, pwp = …)`, whose
input entries name the aerodynamics, landing-gear and powerplant children of the
`Systems` assembly ([§6.2][s6-2]). The generic positional form remains the tool for
configuration-variable sites. Both are plain components, and the framework is
not involved.

**Wrench, mass properties and internal angular momentum each get their own
junction, never one bundled contribution struct** ([D-037][d-037],
[D-323][d-323]). Contributors are ragged, each publishing only some of the
three quantities. A bundled struct would force zero-filled identity values
through every port, the "silently sum nothing" hazard in a new coat.

A `sum_ports!`-style helper would instantiate a junction, wire it and export
its total in one call. **Such a helper is
[guarded-addition](#g-guarded-addition) sugar** (a capability the design
admits but does not build), added when real models show the pattern repeated
([D-037][d-037]).

[Tier](#g-tier)-transparency falls out of settled semantics ([D-062][d-062]), a tier being the
continuous or discrete side of the hybrid formalism. A stateless continuous
`y_direct` recomputes every [sweep](#g-sweep) (one pass through the execution order). Fed
discrete signals held by a zero-order hold, its output therefore changes only at
[ticks](#g-tick) (the instants at which a discrete component's stages and update run). No
tier-neutral variant is needed.

`UnitDelay{V}` is a discrete leaf at `K = 1`. It is the tier's native
`z⁻¹` ([§10.6][s10-6]), the shape an anti-windup chain's previous-saturation
port hand-writes (`companions/pid_anti_windup.md`). It needs no framework
support.

```julia
# UnitDelay{V} — a discrete leaf at K = 1; its initial value is instance data
struct UnitDelay{V} <: AbstractComponent
    v0::V
end
s_init(d::UnitDelay) = (v = d.v0,)
u_types(::UnitDelay{V}) where {V} = (in = V,)
y_types(::UnitDelay{V}) where {V} = (out = V,)
y_state(::UnitDelay, (; s)) = (out = s.v,)   # publishes the stored value
s_update(::UnitDelay, (; u)) = (v = u.in,)    # stores the incoming one
```

**The delay holds its initial value as instance data** ([D-312][d-312]), so
`UnitDelay(v0)` needs no `zero` method on `V`. The store is isbits by rule
([D-231][d-231]), which bounds `V`.

`UnitDelay`'s tier semantics are the point, and they must be stated wherever the
remedy is recommended ([D-348][d-348]). Inserting a `UnitDelay` into a *continuous* loop
moves that signal onto the discrete tier and inserts a [`Δt_base`](#g-dt_base)-scale
zero-order hold into the model's mathematics, `Δt_base` being the base tick
period. That is a modeling decision, because the delayed signal is genuinely
sampled rather than a transparent wire. The cycle diagnostic ([§13.8][s13-8]) therefore
says so rather than offering the remedy as free.

`Constant{V}` has no inputs, no state, and a stage-1 body returning the value
the instance holds ([D-143][d-143]).

```julia
# Constant{V} — a stateless continuous leaf; its value is instance data
struct Constant{V} <: AbstractComponent
    value::V
end
x_init(::Constant) = (;)                       # the empty store declares the tier (§8.2)
y_types(::Constant{V}) where {V} = (out = Pinned{V},)
y_state(c::Constant, _) = (out = c.value,)     # the value the instance holds
```

`Constant` is a stateless continuous leaf, so the tier-transparency argument
above already covers discrete consumers. No discrete variant is needed
([D-143][d-143]). **The leaf is deliberately [pinned](#g-walked) at that
value's own type** ([D-312][d-312]), because the block's output *is* its
stored value. A `Constant{Float64}` declares a `Pinned{Float64}` port and
means it. A constant is never seeded, so it carries zero partials under any
`Dual` [activation](#g-activation) (the build's typed products at a given
scalar type), and the pinned port says so where a walking one would promote
the value and declare less. The honest pin is spelled rather than inferred.
The same holds for every library block whose output depends on neither its
continuous state nor a walking input, such as a step source or a relay, and
each declares its `out` pinned ([D-312][d-312], [D-411][d-411]).

Two uses need `Constant` ([D-143][d-143], [D-410][d-410]), though a listed block needs none to be
built ([D-313][d-313]). The zero-contributor configurations ([§6.2][s6-2]) are one. There, a
required aggregate input has no physical contributor, and the zero total must be
spelled as a wire. The rig stub below is the other. The block's value is
instance data, like junction arity, not an overridable default ([D-143][d-143]). A
configuration wanting an externally settable source uses a root input ([§11.3][s11-3]),
which keeps the block from drifting into a back-door input default. A handle
that references bulk data never surfaces as a root input ([D-237][d-237]); a rig holds
such a handle through a [constant source](#g-constant-source) (a `Constant`, publishing the value its
instance holds) instead ([§14.9][s14-9], [D-364][d-364]).

`Freeze{V}` feeds a walking producer into a pinned entry, which the walk clause
([§6.1][s6-1]) otherwise refuses ([D-266][d-266]).

```julia
# Freeze{V} — a stateless continuous leaf; tolerant in, pinned out
struct Freeze{V <: Union{Real, StaticArray{<:Tuple, <:Real}}} <: AbstractComponent end
x_init(::Freeze) = (;)
u_types(::Freeze{V}) where {V} = (in = V,)
y_types(::Freeze{V}) where {V} = (out = Pinned{V},)
y_direct(::Freeze, (; u)) = (out = ForwardDiff.value.(u.in),)   # leafwise strip, by broadcast
```

At nominal the strip is the identity, so the block costs one gather and one
scatter. **`V` is a `Real` or a `StaticArray` of them, constrained at the type**
([D-312][d-312]), so a struct-valued freeze is refused at the spelling until a model
needs one. Under a `Dual` activation the block drops the partials, and its
output satisfies the pinned entry. What the wire then declares is a zero
coupling in every Jacobian along that path ([D-266][d-266]), the modeling decision [§14.10][s14-10]
asks an author to state on the page rather than bury mid-expression. A sampler
is the other non-walking source, and it changes the model, holding the value
between ticks ([§10.5][s10-5]). The block is for a continuous value the consumer cannot
differentiate through. Where the coupling matters to the Jacobian, the local
rule ([§14.10][s14-10]) is the answer, not this block.

#### The component test rig

The [component test rig](#g-component-test-rig) is the library's companion idiom. Exercising a leaf alone
needs no rig of its own. Any component may be the root of a build, and its input
faces then become the model's root inputs ([§8.2][s8-2], [D-208][d-208]). Ordinary [conditions](#g-condition)
(path-addressed sparse overlays that set a build's state) feed them. So do
[devices](#g-device) (attached participants in the periphery). Every output is observable in
the table of each [snapshot](#g-snapshot), the immutable per-boundary publication. The rig is a
one-child assembly whose `input_wires` surface the child's entire input face
set, as `input_passthrough(rig, "child")` verbatim ([§8.8][s8-8]). What it buys is a
place to wire something *beside* the component under test.

The demonstrated need is the root-input rule ([§8.2][s8-2]). An [abstract entry](#g-abstract-entry) (an
`u_types` entry admitting any concrete producer face), such as the illustrative
`terrain = AbstractTerrainField`, cannot surface as a root input, because
abstract-at-root is a build error, `AbstractAtRoot` ([§8.2][s8-2], [Appendix C][sC]). The rig
therefore satisfies that entry *inside* the rig ([D-120][d-120]). In the sketch below, the
component under test is `Strut`, an illustrative landing-gear strut whose
terrain input is abstract. **A concrete stub child is wired to the face**, and the
concrete remainder is exposed via
`input_passthrough(rig, "strut"; except = ("terrain",))` ([D-120][d-120]). The stub
provides `SampleTerrainField`, an illustrative concrete terrain.

```julia
struct StrutRig <: AbstractComponent    # the rig: component under test + stub
    strut::Strut
    stub::Constant{SampleTerrainField}  # the test handle, held as instance data
end

local_wires(::StrutRig) = ("stub/out" => "strut/terrain",)
input_wires(rig::StrutRig) =
    (input_passthrough(rig, "strut"; except = ("terrain",))...,)
```

That stub child is typically just a `Constant` holding the test handle, which
makes it the source block's first shipped instance ([D-143][d-143], [D-410][d-410]). Bespoke
stubs remain ordinary components wherever the double must compute something.

The rig adds zero new machinery, because wiring and `except` already exist
([D-120][d-120]). It is structural substitutability doing its job. An abstract entry
declares that a substitute must be chosen. The rig chooses its test double
explicitly, as ordinary inspectable code. That is precisely the isolation the
rig exists to provide.

The rig is [`design_world`](#g-design_world)'s little sibling
([§14.9][s14-9]). Where `design_world(ac)` mounts an aircraft in a minimal
world for trim and linearization, the rig mounts one component behind its own
root faces for unit tests and open-loop probing. The machinery is deliberately
ordinary end to end, with no framework support. That makes the rig, like the
library blocks, a standing ergonomics test of the declaration rules.

### 13.8 Cycle diagnosis: feedthrough tracing

The build rejects an [algebraic loop](#g-algebraic-loop) (a genuine cycle in the instantaneous
dependency graph) ([§5.5][s5-5], [D-005][d-005]), and tracing is diagnostic only, never relied on
for correctness ([D-012][d-012]). Tracing improves error messages and verification. When
the build finds a cycle, it triggers the [feedthrough tracer](#g-feedthrough-tracer) (the set-propagation
instrument that tracks which inputs a value depends on) to classify that cycle.
A genuine cycle gets "break it with a state, a stage-1 (`y_state`) port, or a
`UnitDelay`", and an artificial one gets the remedy ladder ([§5.4][s5-4], [D-140][d-140]). Where
the diagnostic recommends a unit delay, it states the delay's [tier](#g-tier) caveat rather
than offering it as a free remedy ([§5.5][s5-5], [§13.7][s13-7], [D-348][d-348]). A tier is the continuous
or discrete side of the hybrid formalism. The parts below cover, in order, how a
cycle is detected and named, the tracer's two modes, what tracing touches, how
classification runs and decides, and the caveats and hints the diagnostic
carries.

#### Detection and naming

A cycle surfaces as a topological-sort stall in the nominal evaluation, the
build's second step and the one evaluation that feeds structure
([§9.1][s9-1]). The stalled subgraph is decomposed into strongly connected
components (SCCs). **Each nontrivial SCC names one cyclic cluster exactly**
([D-012][d-012]). Each cluster becomes one diagnostic, an `AlgebraicCycle`
error ([Appendix C][sC]). The diagnostic presents the cluster's members and
the wires among them as one readable loop of terminal pairs in the canonical
slash form ([§8.6][s8-6]), as in `aero/F → dyn/F, dyn/a → aero/a`. Neither
the raw stall residue nor a single back edge names the cluster correctly
([D-012][d-012]).

#### The tracer's two modes

**The feedthrough tracer has two modes**, and they degrade gracefully
([D-349][d-349]). Both are set-tracers. A traced value carries a set of input
indices, its tracer tags.

- The *global* (value-blind) set-tracer is a `Real` subtype that carries a set
  of input indices, unioned by every operation. It has
  may-depend semantics, a sound over-approximation. A saturated `clamp` still
  reports, and $u^2$ at $u = 0$ still reports. It is exact, in one evaluation.
  It requires the traced stage-2 code to be free of branches and lookups on
  *input-tainted* values.
- The *sampled* set-tracer (the primal-carrying mode the log calls *local*) at
  sampled states is the fallback whenever the global tracer hits an undecidable
  branch, such as piecewise friction, stall blending or any gridded lookup at an
  input-tainted coordinate. It reports the dependence pattern of the taken
  paths, sampled across randomized states. Its only misses are untaken branches
  ([D-012][d-012], [D-349][d-349]).

#### What tracing touches

**Only *inputs* are seeded** ([D-349][d-349]), so branching on state, modes, parameters or time
never interferes. Stage-2 functions also receive state views, but neither those
nor the stage-1 hand-down are ever seeded. Stage-1 functions are never traced,
since there is nothing to seed. Derivatives, [guards](#g-guard) (the declared functions
defining each event's predicate), handlers and [projections](#g-projection) are outside tracing's
jurisdiction entirely. A projection is the optional per-component hook
`x ← x_projection(x)`.

A known tracer blind spot is documented. Value-severing operations pass
dependence through a bare `Int` index, as a nearest-neighbor lookup does.
Linear and cubic interpolation are immune, because dependence flows through
the fractional weights.

**Dual-cleanliness in CI effectively guarantees traceability** ([D-349][d-349]). Dual-clean
means passing the `T = Dual` sweep of [§7.2][s7-2], `Dual` being ForwardDiff's dual
number. The guarantee holds because both modes ride the same `T <: Real`
genericity as `Dual`.

#### Classification

Classification needs no [execution order](#g-execution-order), the order in
which the stage functions run ([D-012][d-012]). It runs inside the nominal
evaluation's failure path, where no execution order exists. None is needed,
because each SCC member is evaluated *once, in isolation*, at the
[probe](#g-probe) point (the initial state, where the build probes every user
function). That evaluation reads state views from the `x_init`, `s_init` and
`m_init` declarations, out-of-cycle cell values from the acyclic prefix's probe
values, and in-cycle cell values synthesized through `probe_value`
([§9.3][s9-3]) under tracer tags. The tracer's product is a per-member
dependence set rather than a value, so no ordering has to be valid for the
labels to come out right.

Classification touches no activation machinery. There is no [activation](#g-activation) (the
build's typed products at a given scalar type), no layouts and no table. The
cycle classifier uses the *per-member* variant of tracing (the log's *local*
variant), an order-free trace at the probe point ([D-012][d-012]). The "tracer
activation" ([§9.4][s9-4]) names the other variant ([D-012][d-012]), the global set-tracer run as
an ordinary activation. The two must not be conflated. The per-member variant is
not the sampled mode. A member's map may come from either mode.

**The traced maps decide the verdict as one graph question over the cluster**
([D-245][d-245]). The verdict is the one [§5.4][s5-4] defines. Every wire
holds. A hop inside a member runs from the [face](#g-face) (the name a port
wears on its component's boundary) that one wire enters to the port the next
wire leaves. The hop holds iff that member's map routes the face to the port.
The loop is real iff a cycle survives in that graph. It is artificial iff none
does, because every cycle through the cluster crosses a dead hop, at a
component whose stage-2 function does not in fact route that input to that
output. **The diagnostic lists every dead hop under either verdict**, so a
real loop still shows the chords the trace found false ([D-245][d-245]). For a
simple cycle this reduces to the expected reading, that the loop is real iff
every hop survives.

#### Caveats and hints the diagnostic carries

The diagnostic carries the tracer's caveats rather than assuming them away.
**The trace speaks for the branch taken at the probe point**, the
diagnostic-only doctrine ([D-012][d-012], [D-343][d-343]). **Discrete members
trace structurally**, because the discrete tier's plain, wholesale-pinning
declarations admit no tracer scalar ([D-012][d-012]). **The remedy hint is
offered only for continuous members** ([D-140][d-140], [D-343][d-343]),
because structural tracing is sound as a may-depend answer but never sharp.
**The hops through a continuous face or port declared with no
[walking](#g-walked) leaf trace structurally too** ([D-245][d-245],
[D-343][d-343]), because such a face or port admits no tracer scalar either.
A walking leaf is one whose type follows the activation scalar.

**The diagnostic records the source of each member's map** ([D-245][d-245]).
The source is the global tracer, sampled states or structure. A reader can
thus weigh a dead hop found on a few sampled paths against one found exactly.
The hint itself is to split this component, *or* to narrow the neighbor's
[contract](#g-contract) (its declared interface) when the dead hop's input is
consumed only in a fallback branch. Those are the ladder's two remedies
([§5.4][s5-4], [D-140][d-140], [D-343][d-343]).

The build diagnostic offers both exits explicitly ([D-140][d-140], [D-343][d-343]). For a loop
between `systems/aero` and `systems/dyn` it reads "artificial at port level:
`systems/aero`'s `F` does not route `a`; split `systems/aero`, or narrow the
neighbor's contract if `a` is consumed only in a fallback branch". The dead hop
runs from the member's input face that its stage-2 function does not route to
the output port. The diagnostic carries the dead hop ([D-245][d-245]) as a separate field
of its [payload](#g-payload) (the structured data a diagnostic carries) rather than dotting
the hop onto the path ([§8.6][s8-6], [§13.2][s13-2]).

If a member's evaluation itself throws, the diagnostic ships with its members
and wires alone, unclassified. Classification is a bonus on the cycle error,
never its precondition ([D-012][d-012]).

---

## 14. Stopped-sim services

[§9.6][s9-6] previewed trim and linearization as clients of an [activation](#g-activation) (the build's
typed products at a given scalar type). The stopped-sim services are
initialization, trim, linearization, and `checkpoint` with its partner
`restore!`. The first three share one artifact, the [condition](#g-condition). A condition is
the datum that says "set this build to this state." `checkpoint` returns a
[checkpoint](#g-checkpoint) (the `Model`'s state at a frame top as one value), and `restore!`
puts it back. A checkpoint is a distinct value with no condition algebra
([D-273][d-273]). [§14.1][s14-1] settles the condition's representation, [§14.2][s14-2] its composition,
[§14.3][s14-3] its resolution and [§14.4][s14-4] its application and the read selectors; [§14.5][s14-5]
covers the initialization sequence called [boundary zero](#g-boundary-zero), [§14.6][s14-6]
[root-input totality](#g-root-input-totality) (the requirement that an application establishing a complete
world cover every [root input](#g-root-input)) and [`override`](#g-override) (the ordered, asymmetric layering
combinator), [§14.7][s14-7] the trim problem, [§14.8][s14-8] the trim service, [§14.9][s14-9] mounting,
which together cover the trim service in full, and [§14.10][s14-10] linearization.

#### Lifecycle preconditions

**Every service requires a non-running simulation** ([D-108][d-108]). While the simulation is
`running`, the loop owns the [stores](#g-store) (the framework-owned homes of components'
`x`, `s` and `m` state). It owns them between [drains](#g-drain) (the frame-top swap that
publishes staged device writes into the root inputs), and a service reading or
writing them would race it. Pause is no exception, by the doctrine that freezes
the [roster](#g-roster) (the list of attached devices, read once at `run!`). Pause is a state
*inside* a run, carried by the [control plane](#g-control-plane) (the separate atomic surface for
pause, pace and the stop word), so a prohibition that holds mid-run holds while
paused ([§11.3][s11-3], [§12.1][s12-1]).

**Within the stopped-sim states, legality follows each service's inputs**
([D-108][d-108]).

| service | `built` | `initialized` | `stopped` | its inputs |
|---|---|---|---|---|
| `checkpoint` | error | legal | legal | a frame-top rest; refused after a `t*` stop and after an abandoned frame |
| `init!` | legal | legal | legal | authored conditions |
| `restore!` | legal | legal | legal | a checkpoint whose fingerprint and deployment match the simulation's and whose `t` sits on its grid ([§12.6][s12-6]) |
| `trim!` | legal | legal | legal | authored conditions; the scratch world is `override(baseline, condition(guess))` ([§14.8][s14-8]), never the sim's stores |
| `linearize`, operating point defaulted to `checkpoint(sim)` | error | legal | legal | inherits `checkpoint`'s precondition, its refusals included |
| `linearize`, explicit `about` ([§14.10][s14-10]) | legal | legal | legal | inherits `init!`'s legality, legal wherever `init!` is |

No service accepts an `errored` simulation ([§12.6][s12-6], [D-108][d-108]).
Post-mortem inspection of an errored sim's stores, log and
[trace](#g-trace) (the primary record of a session) stays available as a
diagnostic read ([D-232][d-232]). It may not become a checkpoint
([D-108][d-108], [D-274][d-274]).

A violation is `ServiceLifecycle` ([Appendix C][sC], [D-108][d-108]). Its
payload is the operation, the current status and the legal statuses ([D-415][d-415]). It
is the same kind `attach!`/`detach!` raise while `running` ([§11.3][s11-3]), so there
is one error form for "this operation is illegal in the current lifecycle
state." `MissingInit` is distinct, and names a missing prior step. The
`checkpoint` row's two refusals, after a `t*` stop and after an abandoned
frame, are `CheckpointMidFrame` ([§12.6][s12-6], [Appendix C][sC]).

**Each row's service also has a form on a [`Model`](#g-model)** (a deployment materialized at
one scalar type), gated by the model's status rather than by the lifecycle
([D-319][d-319]). `checkpoint` and the default `linearize` are legal at `:consistent`.
`init!`, `restore!`, `trim!` and `linearize` with an explicit `about` are legal
at any status ([D-425][d-425]). A model a simulation has claimed refuses each form that
writes, `init!`, `restore!` and `trim!`, as `ArgumentInvalid` with reason `:claimed`
([D-318][d-318]).

### 14.1 Conditions are path-addressed overlays on the declared defaults

A [condition](#g-condition) is the value an author writes to say which state a build starts
from. This section covers, in order, what a condition may specify, the overlay
base, why addressing a condition by path is legitimate, the pre-sweep doctrine
and the environment queries a condition may make.

A condition may specify state fields, `x` on the continuous [tier](#g-tier) (one side of
the hybrid formalism) and `s` on the discrete. It may also specify modes, `m`,
which only [continuous components](#g-continuous-component) have ([§3.2][s3-2]). All three are addressed by a slash
path ([§8.6][s8-6]) plus a field name. Beyond state, a condition may specify [root inputs](#g-root-input)
(the root's own input faces). It addresses them by [face](#g-face) (the name a port wears
on its component's boundary). **It never specifies outputs**, which are derived data
([D-063][d-063]). It never specifies [workspace](#g-workspace) (component-declared mutable scratch
arriving as the `ws` bundle field) ([D-306][d-306]). Condition entries are validated in
the collecting form ([§13.1][s13-1]). The full list is checked, violations are collected,
and one `DiagnosticError` is thrown. A condition entry naming an output or a
workspace field is one such violation, `ConditionResolution` with reason
`:undeclared_field` ([Appendix C][sC]).

**The overlay base is always the declared defaults** ([D-063][d-063]). Every
[store](#g-store) (the framework-owned home of a component's `x`, `s` or `m`
state) has a declared initial value under declaration-by-initial-value
([§8.2][s8-2]), so conditions are naturally sparse. Applying one means "fresh
run from the `x_init`, `s_init` and `m_init` defaults, with these overrides"
([D-063][d-063]). **A condition is an initial condition and nothing else**
([D-273][d-273]). A simulation's state past its initial instant is a
[checkpoint](#g-checkpoint) (the `Model`'s state at a frame top as one value),
not a condition, and it has no algebra ([D-274][d-274]).

Addressing conditions by path does not reopen the observation-by-path
rejection ([§13.5][s13-5], [D-409][d-409]). That rejection bars a run from
acting on reads its model did not declare. A condition is not such a read. It
is a *design-time statement about a concrete build*, written before the run
begins, and the locality law of [§14.2][s14-2] is how an author keeps it to
children the author owns.

**A would-be init value that depends on swept outputs is either analytically known
to the caller or an equilibrium constraint** ([D-064][d-064]). This is the pre-sweep
doctrine, and it holds because condition writes precede the first [sweep](#g-sweep) (one
pass through the execution order against the current state) by definition. The
first case is trim's `α_filt = α_a` ([§14.2][s14-2]). There α is a *decision variable*, so
the value is known above, not computable below. The second case is a job for the
trim service, not for init.

**"Caller-computable" reaches past closed-form knowledge to environment queries**
([D-139][d-139], [D-416][d-416]). A condition needing one constructs the same handle the sweep
will produce, and then calls the same query function the consuming component
calls. There are two routes to that handle. One is the [value-level constructor](#g-value-level-constructor)
(the plain public function building a field handle from the component and input
values) of [§8.2][s8-2]. The condition applies it to the same values the [`baseline`](#g-baseline) (the
full-coverage condition `trim!` takes as a keyword) writes into the environment
[component](#g-component)'s root inputs. The other applies in a rig where an isbits handle
itself is a root-input value ([§4.4][s4-4], [D-364][d-364]). There the condition simply holds the
value the `baseline` wrote. Either way there is one implementation of the field
math, evaluated one level up, with no pre-sweep and no new mechanism. Where
closed-form enforcement of a target is not wanted at all, the doctrine's second
case already covers it ([D-139][d-139]). Promote the eliminated state coordinates to
decision variables and enforce the targets as residuals on swept outputs. That
route needs no environment access at condition time whatsoever.

### 14.2 Fragment composition: locality without schema

Init knowledge is [component](#g-component)-local. An engine component knows
`n_eng → ω = n_eng·ω_rated`, where `n_eng` is the engine speed as a fraction of
its rated speed, and nothing above it should have to. Making that locality a
schema entry was rejected ([D-064][d-064]). That spelling would declare
`initialize(::C, spec)`, a declarative rebirth of `f_init!`, FlightCore's
per-model initialization hook. It would also add an [assembly](#g-assembly)-level rule routing
sub-specs to children. This section covers, in order, the condition method,
composition by pull, what `set`'s payloads may name, the inert tree, the
empty-prefix refusal, the locality law, and the collision and blend errors.

**What preserves the locality is an idiom, not schema** ([D-064][d-064]). It is the condition
method, a method of the framework's `condition` generic, shipped beside the
component and dispatched on the component, returning the component's own
[fragment](#g-fragment) (the leaf node of the condition algebra, built by `set`) ([D-405][d-405]). The
generic is framework-owned so that an owner's pull, described below, reaches a
child's fragment when the two live in different packages. A model package
extends it through `import Redstone: condition`, as it extends the declaration
family ([§8.1][s8-1]). No shadowing check covers it, because a method written to a
foreign `condition` fails loudly at the owner's pull, as a `MethodError` naming
the child ([D-316][d-316]). In the first block, the engine is an illustrative component
named after FlightPhysics' `PistonEngine`, and `Phase` an illustrative enum of
its modes.

```julia
condition(eng::PistonEngine; n_eng) =
    set(x = (ω = n_eng * eng.ω_rated,), m = (phase = Phase.running,))
```

Fragments are composed by *pull* from the structure's owner, here `C172XSystems`
(the C172X aircraft's systems assembly, after FlightApps' `C172X.Systems`). In
the block, `α_filt` and `β_filt` are the aerodynamics' filtered airflow angles,
set to the angle of attack `α_a` and the sideslip `β_a`.

```julia
condition(sys::C172XSystems; n_eng, α_a, β_a) = combine(
    at("pwp/engine", condition(sys.pwp.engine; n_eng)),
    at("aero",       set(x = (α_filt = α_a, β_filt = β_a))))
```

Dispatch selects variant-specific methods, so the actuation split between
Flight.jl's two Cessna 172 variants, c172s and c172x, costs no upstream edits.

`set`'s payloads speak only about the component at the authoring point.
Addressing children is exclusively the job of [`at`](#g-at) (the scoping combinator), so
there is one way to say everything. A `u` payload names faces *of the authoring
level's [contract](#g-contract)* (its declared interface). **Resolution walks the export chain to
the root input** and errors if the face never surfaces ([D-065][d-065]), as
`ConditionResolution` with reason `:no_input_face`, or `:unexported_face` at the
root ([Appendix C][sC]). That walk always has a name to follow. One-level routing
gives every level a declared face for every signal crossing its boundary, so the
chain a sub-assembly's face routes through is in the `Build` ([§6.1][s6-1], [§9.2][s9-2],
[D-207][d-207]). An internally-wired input has no root input behind it, and writing it
would be meaningless because the first sweep overwrites it. Such a write is
`ConditionResolution` with reason `:internally_wired` ([D-427][d-427]). Unexported stays
unpokeable for init exactly as it is for a front end's panels ([§11.7][s11-7]).

**Composition builds an inert, lazy [fragment tree](#g-fragment-tree)** (the nested `Fragment`,
`Scoped`, `Combined` and override nodes) ([D-065][d-065]). `set` builds the leaf, `at`
and [`combine`](#g-combine) (the symmetric, collision-intolerant combinator) build the tree's
inner nodes, and [`override`](#g-override), the ordered, asymmetric layering combinator, builds
a fourth node type ([§14.6][s14-6]). No path arithmetic happens at composition.

```julia
struct Fragment{X,S,M,L}  x::X; s::S; m::M; u::L  end      #set(; x, s, m, u): self-vocabulary payloads; no paths
struct Scoped{N}  prefix::String; node::N  end             #at(prefix, node): stores, never applies
struct Combined{T<:Tuple}  nodes::T  end                   #combine(ns...): collects; order = diagnostics only
```

Every node is isbits except the prefix strings, and a prefix is a reference to
the author's own literal. So, with literal prefixes, rebuilding the tree per
trim iteration allocates nothing. There is no path arithmetic and no copy of the
payloads. Composition checks three things, each by type or length alone, and
none allocates. Each `set` payload is a NamedTuple, each combinator operand is a
node, and each `at` prefix is nonempty. A `set` payload that is not a NamedTuple
is `ConditionNodeMisuse` with reason `:set_payload` ([Appendix C][sC]). The trim of
Flight.jl's Cessna 172 model (`c172.jl`) writes each trial state through
FlightPhysics' `assign!`, a loop that allocates nothing. That property holds of
the construction with literal prefixes and of the specialized `apply!` that
writes the tree ([§14.4][s14-4]) alike. An evaluation's cost is therefore the sweep it
feeds.

**`at` refuses an empty prefix when it is called** ([D-278][d-278]). An empty prefix names no
child, and a node meant for the level where it is authored stays unwrapped. The
refusal holds at the root too, because `at` builds an inert tree and cannot know
where it will be mounted. On a node of a [condition](#g-condition) (the path-addressed sparse
overlay that sets a build's state), `at` raises `ConditionNodeMisuse` with
reason `:empty_prefix` ([Appendix C][sC]) before any resolution pass runs. The read
side's lifts refuse the same way ([§14.9][s14-9], [D-278][d-278]).

**The locality law here is the one [§6.1][s6-1] states for connections**, now in its third
instance ([D-065][d-065]). The three instances are [local wires](#g-local-wire) (wires from one child's
port to a child's face), computed interface connections and conditions. Each
level speaks its own fields, its declared children's names, and its own faces.
Delegation runs by dispatch at every genericity [seam](#g-seam) (a narrow, named interface
kept deliberately thin). An `at` prefix may stop at *any* child's faces, owned or
[generically held](#g-generic-holding) (held through a non-concrete field type), because the face
graph is total ([D-207][d-207]). A deep `at` or condition path resolves wherever the
structure has it ([§13.3][s13-3], [D-414][d-414]). Absolute paths exist only in the flattened list
of condition entries, a *compiled derivative* of the composition, as the offsets
of [cells](#g-cell) (the typed entries of the signal table) are of `local_wires`. Under the
locality law, substituting a component invalidates only the fragments its owner
shipped. The build checks the law wherever it can see what the law constrains.
Wiring resolves one level ([§6.1][s6-1]). The faces a `u` payload names resolve through
the export chain, under any `at` prefix ([D-207][d-207]). No check refuses a deep path
past a generically held field ([D-414][d-414]). An author who ships a fragment for a
family scopes it by dispatch on the holding's type parameter, so a fragment
reaching into one powerplant is defined for the aircraft that hold that
powerplant ([D-414][d-414]). Ownership alone is convention. It is a fact about who
maintains the code, and the build cannot see it, so keeping a deep path inside
an owned subtree is idiomatic rather than machine-checked ([D-065][d-065]). `set`, `at`
and `combine` are ordinary functions with no privileges, as the blocks of [§13.7][s13-7]
are ordinary components.

A `combine` collision is two condition entries on one leaf. **Collisions are
errors at resolution** ([D-065][d-065]). The error is `DuplicateConditionLeaf`
([Appendix C][sC]), and it reports *both* origins. Its message names the layering
combinator. It reads "`combine` is collision-intolerant by design — use
`override(base, patch)` to layer." Last-writer-wins was rejected ([D-065][d-065]). **The
combinator is not `Base.merge`**, and is no longer named after it ([D-204][d-204]). The
last-writer-wins rejection is also the reason. `Base.merge` is last-wins on
NamedTuples, the exact semantics rejected here, and its own name should not
promise them. Because `combine` is its own function, a bare NamedTuple blended
into a node cannot fall through to any last-wins method.

The blend is still closed explicitly. A `combine(::Fragment, ::NamedTuple)`, or
any other blend of a condition node with a bare NamedTuple, is an error method.
Its message is directive. It says to wrap the NamedTuple in `set(…)` (or
`at(prefix, set(…))`) and to combine nodes with nodes. Like every other, the
rejection carries a [kind](#g-kind) (a diagnostic's identity in a closed, enumerated set).
**The blend rejection is `ConditionNodeMisuse`** ([Appendix C][sC], [D-113][d-113]), carrying the
offending argument's type and the node types in hand. It is raised at
composition time, before any resolution pass runs or any origin exists. That is
why it is its own kind and not a `ConditionResolution` sub-kind ([§14.3][s14-3]). The
explicit, *ordered* layering spelling, `override`, belongs with the use case that
[root-input totality](#g-root-input-totality) (the requirement that an application establishing a complete
world cover every root input) produces ([§14.6][s14-6]).

### 14.3 Resolution: flatten, validate, compile once

Resolution turns a composed [condition](#g-condition) (the path-addressed sparse overlay that
sets a build's state) into plans the services can apply. It takes the root node
plus a [`Build`](#g-build) (the artifact `build(world)` produces). This section covers, in
order, flattening, the collecting checks, the two lookup families, the plan, the
converter rule with its two cases, and overlay partiality.

**Flattening is the only place path strings are ever concatenated** ([D-065][d-065]). It is a
trivial recursion with a path accumulator, and it also records each condition
entry's tree position, its `getfield`/`getindex` step tuple.

The collecting pass then checks each flat condition entry:

- the path resolves, with [did-you-mean](#g-did-you-mean) (the offending name
  plus the list-in-hand it should have matched) over children;
- the field is declared in the target's `x_init`/`s_init`/`m_init`;
- the value type is convertible to the declared leaf type;
- input [faces](#g-face) reach [root inputs](#g-root-input);
- no leaf is written twice, where a `u` payload's leaf is the root input its
  face resolves to.

Each check names its kind ([Appendix C][sC]). A path that does not resolve is
`PathResolution` with reason `:unknown_child`. An undeclared field is
`ConditionResolution` with reason `:undeclared_field`, or `:no_store` or
`:assembly_path` where the target has no such store or is an assembly. A
value that does not convert is `ConditionResolution` with reason
`:unconvertible`. A face that reaches no root input takes one of the face
reasons [§14.2][s14-2] names. A leaf written twice is `DuplicateConditionLeaf`.

The `Build` supplies two lookup families.
[Schema](#g-schema-vs-layout) is the evaluated declarations, and it is the
authority. It answers whether you may write this field, and at what leaf
type. Layout is the destination. It holds the `x` backing ranges, the store
indices for `s` and for `m`, and the root-input indices from the
[activation](#g-activation) (the build's typed products at a given scalar
type). The face chains come from [`Structure`](#g-structure) (the structure
step's product, the components, wires, faces and tiers), never from an
activation's typing; the names a declaration evaluates to are the same at
every activation ([§9.1][s9-1], [D-253][d-253]).

A valid list of condition entries compiles two ways ([§14.4][s14-4]). The
specialized `apply!`'s plan holds, per leaf, a [lens](#g-lens) (the compiled
navigation step of a condition entry), a destination and a converter. The
dynamic walk's plan holds the converted values themselves. The lens is the
position tuple lifted to a type parameter, so navigation of the fixed tree
type is type-stable.

**The converter is baked now, selected per leaf from that leaf's type in the
resolved shape** ([D-065][d-065], [D-148][d-148]). Leaf types are shape facts,
carried by the tree type along with the full nesting and every field name
([§14.4][s14-4]). Selection therefore consults no runtime fact and stays a
resolution-time bake.

There are two cases.

| leaf in the resolved shape | converter baked |
|---|---|
| already at the activation's scalar type, decision-descended | the type's ordinary `convert`/constructor methods *at that eltype* |
| a plain `Float64` leaf against a non-nominal activation's scratch, a held constant | the `Float64 → Dual` zero-partial embedding |

A leaf already at the activation's scalar type is decision-descended. Under a
`Dual`-seeded evaluation of a type-stable `trim_condition(d)`, every
decision-descended leaf is `Dual`-typed in the shape ([§14.7][s14-7]). Such a leaf takes
the type's ordinary `convert`/constructor methods *at that eltype*. An authored
`RQuat` (FlightPhysics' rotation quaternion) of `Dual`s becomes the `SVector{4}`
state leaf at `Dual`, with the partials flowing through untouched. That
untouched flow of partials is what makes the seeded decisions reach the [sweep](#g-sweep) at
all. At the [nominal](#g-nominal) activation (the `Float64` one), the same rule is the
ordinary `Float64` conversion. An authored `RQuat` value becomes the
`SVector{4}` state leaf it initializes.

A plain `Float64` leaf against a non-nominal activation's [scratch](#g-scratch) (mutable
working storage whose contents are never authoritative) is a held constant, and
it takes the `Float64 → Dual` zero-partial embedding. That embedding is
semantically exact in that case, and in no other. "Held at the operating point"
*is* zero partials. Zero partials are the whole of a linearization operating-point
condition, which is authored decision-free ([§14.10][s14-10]). The same
embedding carries a root input's checkpoint value into `linearize`'s seeded
half when no condition is authored, through the type's `convert` at the
seeded scalar ([§14.10][s14-10]). A struct-typed root input therefore needs
a `convert` between its scalar instantiations wherever it is linearized.

The selection is a one-time resolution decision, and it leaves the nominal
exact-match doctrine for table [cells](#g-cell) ([§9.5][s9-5]) untouched.
Converters run here, on the write path. They never run on state
[views](#g-view) ([§7.1][s7-1], [D-148][d-148]).

Overlay partiality for the `s` and `m` stores is baked the same way
([D-065][d-065]). Each `s` or `m` store's write is one whole value,
`merge(defaults, overlay)`, with the store's declared defaults resolved at
compile time under the overlay-base rule ([§14.1][s14-1]).

### 14.4 Two ways to apply a resolved condition

A resolved [condition](#g-condition) (the path-addressed sparse overlay that
sets a build's state) is applied two ways, because a one-shot service and an
iterating one want different things from the same validated list of
condition entries ([D-066][d-066]). The section gives the two ways, then the
read-selector family.

#### Applying a plan

All string work, validation and addressing are functions of the *shape* of the
condition. Every hot path holds the shape fixed while varying values. Execution
is therefore resolve-once/execute-many.

- **Specialized `apply!` serves the service that iterates**, trim's per-evaluation
  write ([D-066][d-066]). It applies its own plan, whose contents [§14.3][s14-3] gives. It unrolls
  [stores](#g-store) (the framework-owned homes of components' `x`, `s` and `m` state)
  through the baked [lenses](#g-lens) and converters. Those are the same machine operations
  as the in-place writes of FlightPhysics' `assign!`, with no allocation, no
  strings and no dispatch. The per-iteration shape check is the mechanism of
  [§9.5][s9-5] transferred. The tree type is proven by dispatch, and it carries the full
  nesting, every field name and leaf type. A `===` comparison of each prefix
  string closes the remainder. `===` on strings compares content, so a prefix
  computed at run time pairs with the compiled one exactly as a literal does, at
  the cost of one short comparison per `at` node. Shape drift is a tree of
  another type, or a prefix that differs at a position. It is
  `ConditionShapeDrift` ([Appendix C][sC], [D-423][d-423]), reason `:tree_type` or `:prefix`, a
  structured error rather than silent corruption. The cost is Julia codegen *once
  per condition shape*, and it grows with the shape's writes ([D-066][d-066]). On Julia
  1.13 it measures 10 to 50 ms up to 32 writes, 0.09 s at 64 and 0.2 s at 128
  (`docs/reports/20261002_tuple_walks/`). That cost is noise against the model's
  own first-sweep warmup (seconds). It is paid once per tree type per session,
  so it spreads over every evaluation of every trim of that shape, an envelope
  of trims (one trim per point of a grid of flight conditions) included.
- **The dynamic walk serves the one-shot uses**, `init!`, `linearize`'s operating
  condition and trim's setup write ([§14.8][s14-8], [D-066][d-066]). It executes the same
  validated condition entries by runtime dispatch per write, from its own plan
  ([§14.3][s14-3]). That takes microseconds in total, with allocation permitted, since
  the stopped-sim path was never under the zero-alloc regime ([§9.8][s9-8]). It needs no
  per-shape codegen. Fifty structurally different scripted conditions cost fifty
  walks, not fifty compiles.

Which of the two a service uses is internal, never user-facing API.

The per-iteration ledger for trim has four terms. They are the user [fragment](#g-fragment)
math, the leaf stores, the folded shape check and the [sweep](#g-sweep) (one pass through
the execution order against the current state). A fragment is the leaf node of
the condition algebra, built by `set`. The fragment math is the domain
computations, unchanged from Flight.jl's, plus building the tree, which with
literal prefixes allocates nothing ([§14.2][s14-2]). The sweep dominates, exactly as
`f_ode!` does in FlightCore, where it is the continuous-dynamics function a
model extends.

`apply!` ends at established stores. Making the model *coherent* is the job of
[boundary zero](#g-boundary-zero) (the initialization boundary, the ordinary macro-sequence with an
empty integrate), which [§14.5][s14-5] specifies.

#### The read-selector family

The family of read [selectors](#g-selector) (values describing a read the compiled gather will
perform) is closed ([D-095][d-095]). Its members are `get_state(path, leaf)`,
`get_deriv(path, leaf)`, `get_output(path, leaf)`, `get_input(leaf)` and
`get_face(leaf)`. They form one address space for every reader that takes a
selector.

**`leaf` is a [leaf address](#g-leaf-address)** ([D-276][d-276]). It is the field or [face](#g-face) name (the name a port
wears on its component's boundary), followed by `.name` and `[k]` or `[k,l]`
steps in any order, as in `"pose.q_eb[2]"`, `"ω_eb_b[1]"` or `"J[1,3]"`. **A bare
`Symbol` is the short form of a plain name**, so `get_state("kin", :θ)` reads
`get_state("kin", "θ")` ([D-276][d-276]). A face name is an arbitrary string and may
contain a dot ([§8.6][s8-6]), so on `get_input` and `get_face` the head is matched
rather than parsed ([D-418][d-418]). The head is the longest declared face name that is a
prefix of the address and is followed by the end, a `.` or a `[`. A `Symbol` leaf
names the face whole, with no steps. So `get_input("wing.throttle")` and
`get_input("wind[1]")` both resolve, and where faces `a` and `a.b` both exist,
`"a.b"` names the face `a.b`.

**Each step is checked at resolution against the type resolved so far** ([D-276][d-276]). A
`.name` step needs an isbits struct with that field. An index step needs an
`SArray`, with one index or one per dimension, and a vector leaf thereby yields
named scalars. A step never enters an opaque leaf (a field handle or a
`Symbol`), which is read whole. **`get_deriv`, and `get_state` on the continuous
tier, take at most an index step**, since a continuous state field is flat ([§7.1][s7-1],
[D-276][d-276]). A discrete `s` field is isbits or a `Symbol` ([§3.2][s3-2]), and `get_state` on
it takes the full address. The address is checked once and baked, and **the read
runs as field loads and indexing unrolled at compile time** ([D-276][d-276]).

**The names carry a deliberate `get_` prefix** ([D-095][d-095]). A selector is
a *deferred read*, a value describing the read the compiled gather will
perform. The prefix names that action, and it keeps five short common nouns
out of the namespace user declarations share with domain code.

There is no selector for a value a [component](#g-component) computes without declaring it, and
there cannot be one, because only declared [cells](#g-cell) and stores are addressable
([§4.2][s4-2], [§8.3][s8-3]). So a reader that wants one is asking the producing component to
declare it an output ([§8.3][s8-3]). A service evaluation needing an undeclared
intermediate has the same remedy, whatever its client. The component exports it
([§14.7][s14-7]).

[Mounting](#g-mounting) relocates a whole problem or [tap set](#g-taps) (the three selector lists
declaring what linearization seeds and reports) with `at(prefix, …)`. `get_face`
addresses an output face of the mount level, the level a problem's or tap set's
reads are mounted at ([§14.9][s14-9], [D-277][d-277]). At the root that face is root-exported.
Either way the read is an *integration* read ([§11.2][s11-2]).

**A selector resolves against a source** ([D-098][d-098]). The table selectors (`get_output`,
`get_input`, `get_face`) resolve against a *table source*. A table source is a
[boundary](#g-boundary) [snapshot](#g-snapshot) (the immutable publication at a published consistency point),
or the scratch tables a service evaluation instantiates ([§14.8][s14-8], [D-124][d-124]). The
store selectors (`get_state`, `get_deriv`) resolve only against live stores
([D-098][d-098]). The table/store axis separates table-borne values from store-borne
ones, not snapshots from services.

Only stopped-sim service evaluations, [`checkpoint`](#g-checkpoint), and post-run inspection of
the live stores ever hold live stores ([§11.2][s11-2]). That inspection is the
[replay](#g-replay)-to-inspect ([§11.2][s11-2]), where replay is the ordinary loop with its drain
reading the trace. Of these holders, only the service evaluations' readers take
a store selector. The snapshot deliberately carries no state stores ([§11.2][s11-2]), and
`ẋ` [buffers](#g-buffer) (the vectors the integrator fills) are integrator scratch, not
boundary-consistent objects outside a service evaluation. A reader resolving for
a table source that names a store selector is therefore refused at resolution,
as a `ReadResolution` with reason `:store_selector` ([D-406][d-406]). **The resolver takes
the source it resolves for**, so the rule is the resolver's and not a client's
([D-406][d-406]). The honest remedy ([§11.2][s11-2]) is to declare the field in `y_types`, return
it from `y_state`, and read the resulting [port](#g-port) ([§5.3][s5-3]).

On top of the source rule sits one piece of authoring guidance ([D-414][d-414]). Trim's
`reads` and linearization's taps name
`get_state`/`get_deriv`/`get_output`/`get_input`/`get_face`. They do so within
the scopes the locality law ([§6.1][s6-1]) and fragment scoping ([§14.2][s14-2]) describe. A
service read, trim's `reads` or a tap, that should outlive the build reads a
face with `get_face` ([D-125][d-125]). `get_face` resolves through export chains exactly
as mounting resolves [root input](#g-root-input) faces ([§14.9][s14-9], [D-125][d-125]), so the read side mirrors
the write side. An equilibrium equation meant to outlive the build it was posed
against therefore binds the curated face behind a [generically held](#g-generic-holding) child (one
held through a non-concrete field type) rather than a path into it.

An inspection read, a binding's or `series`', may name any cell the structure
has, since it promises nothing beyond this build ([D-083][d-083]). Both kinds of read
resolve under the one service walk ([§13.3][s13-3]). Inspection reads admit the whole
family, within the source rule. Bindings of an output [device](#g-device) (an attached
participant in the periphery) and log extraction by `series` take deep paths,
`get_face` names and leaf addresses alike ([D-406][d-406], [D-407][d-407], [D-414][d-414]). Snapshot
inspection ([§11.2][s11-2]) reads a cell by path and port name instead. A store selector
resolves only for a reader that runs over live stores, which today are the
services' ([§14.8][s14-8], [§14.10][s14-10]). A snapshot-bound reader is barred from it by source,
not by client.

`ignore_stop_requests` is not a family client. It names requesters from the
`Build`'s [requester roster](#g-requester-roster) (the build's list of stop requests, one per
`StopFlag` output port) and nothing else ([§13.5][s13-5], [D-316][d-316]). Termination is run
policy over the requests the model declares, and no path selector reaches
`ignore_stop_requests` ([D-060][d-060], [D-316][d-316]).

The five selectors and their sources:

| selector | resolves against |
|---|---|
| `get_state(path, leaf)` | live stores |
| `get_deriv(path, leaf)` | live stores |
| `get_output(path, leaf)` | a table source |
| `get_input(leaf)` | a table source |
| `get_face(leaf)` | a table source |

Over this family and the [layout](#g-schema-vs-layout) tables (where each value physically lives),
**compiled readers are the gather twin** ([D-066][d-066]). Trim's residual reads (`ẋ` and
output fields) and linearization's Jacobian gather are one primitive run in
reverse. It is one machinery, in both directions, in the `Build`'s client kit.

A compiled plan or reader carries the [activation](#g-activation) it was
compiled at and applies only to a store set of that activation. That
pairing is a framework invariant the services uphold, not a user-facing
check. Neither plans nor readers are user values.

### 14.5 Boundary zero: an ordinary boundary with authored incoming transitions

`apply!` establishes the [stores](#g-store) (the framework-owned homes of components' `x`,
`s` and `m` state) at `t₀`. **The init service then completes the [§10.6][s10-6]
macro-sequence with an empty integrate** ([D-067][d-067]). The sequence is the following.

> project → [[sweep](#g-sweep) → [guards](#g-guard) → handlers]\* → [due](#g-due) `s_update` calls → first [snapshot](#g-snapshot)

In the sequence, a sweep is one pass through the execution order against the
current state, and a guard is the declared function that decides when an event
fires. A due component is a discrete component scheduled to run here, and a
snapshot is the immutable publication that closes the sequence. After the first
snapshot `init!` takes the [trace header](#g-trace-header), the [checkpoint](#g-checkpoint) (the `Model`'s state at
a frame top as one value) of the state the sequence leaves ([§11.5][s11-5], [D-274][d-274]). The
parity with an ordinary [boundary](#g-boundary) is exact, not approximate. The pieces follow
one by one, in run order. [Projection](#g-projection) (the optional per-component hook
`x ← x_projection(x)`), the sweep, events and the due `s_update` calls come
first. Then come the `t₀` argument and what [boundary zero](#g-boundary-zero) (the initialization
boundary, the ordinary macro-sequence with an empty integrate) means for trim.

- Project runs. Authored `x` can sit off-manifold. A hand-assembled quaternion
  may be ulps off unit norm, or a [condition](#g-condition) (the path-addressed sparse overlay
  that sets a build's state) may write part of a constrained block against fresh
  defaults. Projection after condition writes holds the same position it holds
  after any other `x` mutation. And it costs nothing when the state is already
  clean.
- The sweep runs, and **every discrete output stage publishes, due or not** ([D-205][d-205]).
  `t₀` is a grid point of every phase-free divisor, so the `Φ = 0` components
  are due in full. An offset [component](#g-component) ([§10.5][s10-5]) is *not* due, because its first
  [tick](#g-tick) (an instant at which its stages and update run) is at `Φ·Δt_base`. Its
  output stages run at boundary zero all the same, publishing from the authored
  `s` and the `t₀` table in the ordinary sorted walk. That evaluation is
  establishment, not a scheduled sample. The schedule owns every instant after
  `t₀`, and the first sample the component's `s_update` consumes remains its
  `Φ·Δt_base` tick's. What the rule buys is a `t₀` snapshot carrying the
  authored world fully evaluated. No published [cell](#g-cell) holds a synthesized
  [probe value](#g-probe-value) (a fabricated value a build-time probe runs on). That is the
  probe-value barrier of [§14.6][s14-6] extended from the [root inputs](#g-root-input) to the whole table.
- Events run. A condition can land a guard [predicate](#g-predicate), a `Bool`-valued form or
  the sign of a continuous function, in [holding](#g-edge-semantics) territory (firing on not-holding
  → holding transitions, never bare sign changes). An authored stall flag, or a
  strut authored into contact, does exactly that. The event then fires visibly
  at `t₀` rather than one step later. The prior rule grounds that timing ([§10.6][s10-6],
  [D-292][d-292]). Boundary zero establishes every guard [prior](#g-prior) (the event's stored
  predicate sample from the previous boundary) as not-holding. Suppressing those
  firings was rejected ([D-067][d-067]), on the lesson of the [stage-on-interaction](#g-stage-on-interaction) rule
  (the rule that a GUI widget stages a new value only on interaction, never per
  render pass) ([§11.7][s11-7]). That lesson is that insurance masking invariant
  violations is anti-diagnostic ([D-026][d-026]). The trace header is taken after the
  sequence ([§11.5][s11-5]). [Replay](#g-replay) restores it and runs no boundary zero, so whatever
  fired at `t₀` comes back as part of the restored state and never fires twice
  ([§12.7][s12-7], [D-274][d-274]). The checkpoint records the post-firing state faithfully and
  suppresses nothing. A [stop request](#g-stop-request) (an output port of the framework enum
  `StopFlag`) already reading `STOP_REQUESTED` is a different category. Nothing
  *fires*. The request simply holds in the published `t₀` snapshot and the loop
  reacts ([§13.5][s13-5], [D-413][d-413]).
- Due `s_update` calls run. This follows from an interval-alignment fact that is
  easy to mis-picture. It is hereby a taught contract, sibling to the
  boundary-sampling contract ([§8.6][s8-6]). **A boundary's `s_update` is the *outgoing*
  transition** ([D-067][d-067]). At tick `t_k` it consumes the completed boundary's samples
  and produces `s_{k+1}`, the value the next tick reads. The transition that
  carried `s` *into* `t_k` ran at `t_{k-1}`. Boundary zero is missing its incoming
  transitions on *both* [tiers](#g-tier) (the continuous and discrete sides of the hybrid
  formalism), and authorship replaces both.

  | tier | `t₋₁` | `t₀` (boundary zero) | `t₁` |
  |---|---|---|---|
  | discrete | the `s_update` that would have produced a discrete leaf's `s(0)` never ran; the condition authored `s(0)` | `s_update` consumes the `t₀` samples and produces `s(1)` | the gated stages read `s(1)` |
  | continuous | the integration over `[t_{-1}, t_0]` that would have produced a continuous leaf's `x(0)` never ran; the condition authored `x(0)` | the authored `x(0)` is the initial condition of the outgoing integrate, $t_0 \to t_0 + h$ | |

  The outgoing work all runs, and `t₀`'s `s_update` has its only
  opportunity. `s(1)` must sit in the store before `t₁`'s gated stages read
  it. An accumulator $s_{k+1} = s_k + \Delta t \, e_k$ authored with
  $s_0 = 0$ under nonzero $e(t_0)$ would otherwise first integrate
  $e(t_1)$, putting the whole sampled-data lattice one period late
  ([D-067][d-067]). The authored `s(0)` needs no protection, because it is
  published in the `t₀` snapshot regardless. The continuous-tier analogue
  of `s_update`-at-`t₀` is not the empty incoming integrate but that first
  *outgoing* one. Both authored values are the published initial conditions
  of their outgoing transitions. The same placement fixes what a discrete
  store holds at rest. After any boundary the store holds the state the
  component's next due tick decodes, and its cell holds the sample its last
  tick published; a counter due at boundary zero and authored at 0 holds 1
  after `init!` alone. A discrete store copied off a stopped run into a
  condition therefore starts that component one tick ahead ([D-273][d-273]).
- **`t₀` is an init-service argument** (default `0.0`), never a condition
  entry, because time is not a store of any component ([D-067][d-067]). The
  [harmonic grid](#g-harmonic-grid) (every discrete period an integer
  multiple of `Δt_base`) anchors at whatever `t₀` boundary zero runs at.
  **Both init-service entry points carry the argument, with the same
  default** ([D-110][d-110]). They are `init!(model, condition; t0)` and
  `trim!`'s commit ([§14.8][s14-8], [D-319][d-319]). The simulation's
  `init!(sim, condition; t0)` wraps the model's, resolving the condition and
  opening the run before the model's method writes. Each form of `trim!`
  commits through the matching `init!`, the model's or the simulation's
  ([§14.8][s14-8]). Conditions are time-free. Nothing after boundary zero
  sets the origin. A restore inherits the clock and takes no `t0`
  ([D-273][d-273]).
- **Trim is untouched by all of this** ([D-067][d-067]). Optimizer
  iterations are raw write → sweep → read cycles on the activation, with no
  boundaries, no events and no `s_update`. Only the committed solution
  executes boundary zero.
- A guard firing at commit is a wanted failure signal. The hand-written trim
  asserts (no gear strut in ground contact, engine speed `ω` above `ω_idle`) of
  Flight.jl's two Cessna 172 variants, c172s and c172x, become the model's own
  event logic, surfaced through the ordinary machinery instead of `@assert`. A
  handler that fires at commit moves the committed stores off the solved point.
  Saying nothing would relocate warn-but-assign, where the trim of Flight.jl's
  Cessna 172 model (`c172.jl`) warns on a failed optimization and assigns its
  result anyway. **The channel that says it is the trim report** ([§14.8][s14-8], [D-126][d-126]).
- A commit-fired handler is not the only mover. **Projection is the second, and it
  is unconditional** ([D-155][d-155]). Boundary zero's *first* act is `x_projection`, so the
  committed `x` is `x_projection(x*)`, not the solver's `x*`. An attitude
  quaternion renormalized by a few ulps is the canonical case. That move is
  legitimate, wanted, and usually invisible in the residuals. But the point the
  stores sit at is no longer the point the solver's convergence verdict was read
  at ([§14.8][s14-8]). Both movers take the same remedy, specified with the report in
  [§14.8][s14-8].

### 14.6 Root-input totality: the missing-value error and the `override` combinator

[Root inputs](#g-root-input) (the root's own input faces) are the one initialized datum without
declared defaults. That is the bare-types decision ([§11.3][s11-3]), upheld here ([D-068][d-068],
[D-376][d-376]). So a root input's only source before [boundary zero](#g-boundary-zero) is the [condition](#g-condition) (the
path-addressed sparse overlay that sets a build's state). Boundary zero is the
initialization boundary, the ordinary macro-sequence with an empty integrate.
Three consequences follow. They are the totality check, the probe-value barrier,
and [baselines](#g-baseline) (aircraft-shipped, full-coverage condition functions) layered by
[`override`](#g-override), the ordered, asymmetric layering combinator.

**Totality is a precondition of starting, checked by the service** ([D-068][d-068]). A
condition value is legitimately partial. [Fragments](#g-fragment) (the leaf nodes of the
condition algebra, built by `set`) compose, and trim iterations write subsets.
So "every root input covered" is not a property of conditions. **Totality is a
property of every application that establishes a complete world over virgin
stores** ([D-149][d-149]). That principle, not an enumeration, names the sites. They are
`init!`, trim's setup application to freshly allocated scratch stores, trim's
commit through boundary zero ([§14.8][s14-8]), and linearization's operating condition
under `about`, applied to its own scratch ([§14.10][s14-10]). That is one group of sites,
one mechanism and one kind. Each compares the resolved plan's root-input
coverage against the `Build`'s `input_faces` before writing anything. A
shortfall is one collected, declaration-ordered diagnostic
(`UninitializedInputs`, [Appendix C][sC]) naming every uncovered face. Coverage is a
*plan-level fact*, because both operands are resolution-time data. The check is
therefore one comparison, and it runs before any evaluation, not merely before
any write. Pre-write means all-or-nothing. A rejected init leaves the sim
exactly as it was, the same posture as failed trim.

**The [probe](#g-probe-value)-value barrier is structural** ([D-068][d-068]). The `probe_value` synthesis
(zero, false, the first enum value or `T()`) exists so build-time probes can
exercise code with fabricated inputs ([§9.3][s9-3]). A fabricated zero is a fine probe
input and a terrible flight condition. A silently zeroed `mixture`, the mixture
setting of FlightPhysics' `PistonEngine`, kills the engine and sends the user
debugging aerodynamics. The services path simply contains no call to it. A root
input gets a condition value or the application errors, with no third branch.
[Replay](#g-replay) (the ordinary loop with its drain reading the trace) likewise never
synthesizes. The [trace header](#g-trace-header) (the trace's fixed preamble) holds every
root-input cell as boundary zero left it, and with totality enforced that record
is complete by construction. That discharges the requirement that a root input
no device feeds hold a defined value from the first frame ([§11.3][s11-3]).

**Baselines are aircraft-shipped condition functions**, layered by `override`
([D-068][d-068]). Nobody hand-writes ~20 root-input values per script. In Flight.jl the
`@kwdef` defaults of `SystemsInitializer`, the systems initializer of its Cessna
172 model (`c172.jl`), carry that load. Their successor is ordinary user math in
one authoritative home, such as `ready_for_taxi(ac)` or `cold_and_dark(ac)`,
returning full-coverage conditions. But "baseline plus tweaks" collides with the
duplicate-leaf error ([§14.2][s14-2]) by design. The collision *is* the intent, and **the
fourth node type, `override(base, patch)`, exists for it** ([D-068][d-068]). It is ordered
and asymmetric, where [`combine`](#g-combine) is symmetric and collision-intolerant. At
resolution a leaf present in both takes the patch's value, and the origin names
both layers. Collisions *within* one layer remain errors. Variadic layering
(`override(campaign, aircraft, todays_case)`) composes. Trim uses it on day one.
The committed condition is `override(baseline, condition(d*))`, the solved
condition over full coverage ([D-068][d-068]).

### 14.7 The trim problem: NamedTuple decisions, declared reads, named residuals

The aircraft author ships one value. It says what the solver may vary, what
those decisions make of the model, what to read back after each evaluation,
and which equations the readings must satisfy. That value is a
[`TrimProblem`](#g-trimproblem). This section gives its fields, then its
decisions and parameters, its reads, its residuals and checks, the
formulation it encodes and its recorded extensions.

#### The fields

**The field set is normative and closed** ([D-118][d-118], [D-262][d-262]).
It is closed because the lift ([§14.9][s14-9]) is field-by-field.

- **`guess`, `lower` and `upper` are same-named all-`Float64` NamedTuples**
  ([D-069][d-069]).
- `condition` is the function over decisions whose value is a
  [condition](#g-condition) (the path-addressed sparse overlay that sets a
  build's state).
- `reads` is the declared read set.
- `residuals` is the residual function.
- `tolerances` is an all-`Float64` NamedTuple, same-named as the residual
  function's return.
- `checks` is the check function, and `check_tolerances` an all-`Float64`
  NamedTuple same-named as its return. Both default to empty.

`tolerances` is carried *in the problem* because a relocated problem must carry
its own convergence test. [`at`](#g-at) (the scoping combinator storing a path
prefix beside a node) passes it through untouched ([D-118][d-118]).

The problem below is [worked](#g-worked) (spelled in full against a concrete case). It is the
cruise case of Flight.jl's Cessna 172 model (`c172.jl`), reduced to its
three-equation core. The real problem is the same shape with the full 7-variable
search, and the θ-constraint elimination survives inside its condition function,
which the worked problem calls `trim_condition`.

```julia
cruise = TrimProblem(
    guess      = (throttle = 0.6, elevator = -0.05, α = 0.06),
    lower      = (throttle = 0.0, elevator = -1.0,  α = -0.1),
    upper      = (throttle = 1.0, elevator =  1.0,  α =  0.3),
    condition  = d -> trim_condition(ac, params, d),    #params closed over (§14.2)
    reads      = reads(v̇_b = get_deriv("vehicle/dynamics", :v_eb_b),
                       ω̇_b = get_deriv("vehicle/dynamics", :ω_eb_b),
                       EAS = get_output("vehicle/airdata", :EAS)),
    residuals  = (r, d) -> (axial_force  = r.v̇_b[1],
                            normal_force = r.v̇_b[3],
                            pitch_moment = r.ω̇_b[2]),
    tolerances = (axial_force = 1e-3, normal_force = 1e-3, pitch_moment = 1e-4),
    checks           = (r, d) -> (EAS = r.EAS - params.EAS,),  # read back after the commit
    check_tolerances = (EAS = 0.1,))
```

The rest of the section takes what the author ships one piece at a time,
against Flight.jl's `c172.jl`.

#### Decisions and parameters

FlightPhysics' decision-variable supertype, `AbstractTrimState{N}`, is dropped. It
is an alias of StaticArrays' `FieldVector{N, Float64}`. Its only job was
vectorization, and vectorization is the service's ([D-069][d-069]). The service packs and
unpacks by field order, and that order is the `guess` NamedTuple's own. This [seam](#g-seam)
runs on the rule [§9.5][s9-5] states, "the names are the pairing, order carries no
semantics" ([D-151][d-151]). `lower` and `upper` are checked at setup for key-set equality
with `guess` and for `Float64` fields. They are then canonicalized to `guess`'s field
order by the same type-level reorder (`NamedTuple{keys(guess)}(lower)`). A
permuted bound spelling is therefore a non-event, rather than `α`'s bound silently
applied to `throttle`. A key-set or field-type mismatch is `TrimProblemInvalid`.
Guess, bounds and the returned solution share one spelling, and
`Base.merge(guess, (throttle = 0.3,))` is free warm-start tweaking. An author who
wants a documented `@kwdef` struct keeps it privately and converts.

`TrimParameters` is the struct in Flight.jl's `c172.jl` that holds a trim's
targets and settings. **`TrimParameters` stays a plain user struct** the
framework never sees ([D-069][d-069], [D-118][d-118]). The assignment is the
pure `trim_condition(ac, params, d)` [fragment](#g-fragment)-tree function
([§14.2][s14-2]), applied per iteration by the compiled plan ([§14.4][s14-4]).

#### Reads

**The read side is declared, then compiled** ([D-069][d-069]). **The spelling
is `reads(name = get_state(path, leaf) | get_deriv(path, leaf) |
get_output(path, leaf) | get_input(leaf) | get_face(leaf), ...)`**, the
service read set ([§14.4][s14-4], [D-124][d-124]). Each `leaf` is a
[leaf address](#g-leaf-address) (the field name with dotted and bracketed
steps below it). `get_state` and `get_deriv` address a declared state field
and its derivative (validated against `x_init`/`s_init`). `get_output`
addresses a declared output [port](#g-port) (validated against `y_types`).
`get_input` and `get_face` address a [root input](#g-root-input)
[face](#g-face) and an output face (validated against the faces of the level
the read set is mounted at, the root's when unmounted) ([D-277][d-277]).

The path [selectors](#g-selector) (the closed family of deferred reads resolving against a
source) reach any port or state field the structure has ([§13.3][s13-3], [D-414][d-414]). As
authoring guidance, an equilibrium equation meant to survive substitution at a
generic seam reads a face ([D-414][d-414], [D-125][d-125]). A trim evaluation needing a value a
[component](#g-component) computes without declaring it finds no selector for it ([§14.4][s14-4]). That
is a signal that the component should export it. A derivative wanted across a
[contract](#g-contract) boundary takes the same remedy. Publish it as an ordinary output port
computed in `y_direct`. That is the one-line binding of the fused idiom ([§5.3][s5-3]),
made contract. By convention, then, `get_deriv` stays inside subtrees the
problem's author owns ([D-414][d-414]). The compiled reader fills a stack-only NamedTuple
per evaluation. It is the gather twin ([§14.4][s14-4]).

#### Residuals and checks

**The user supplies a residual *system*, not a scalar cost**
([D-069][d-069]). It is authored as a NamedTuple of named equations. The
residual function that returns it has this signature.

```julia
residuals(reads::NamedTuple, d::NamedTuple) → NamedTuple
```

**What the solver varies is passed, and what is fixed per problem is closed
over** ([D-118][d-118]).

The gathered reads and the decision NamedTuple arrive as arguments. `d` is the one
value that *cannot* be closed over. `TrimParameters` stays behind the closure,
exactly as `condition` already holds it. Being user-shaped, that record is also
where any environment handles the condition math needs conventionally ride. [§8.2][s8-2]
gives the [value-level constructor](#g-value-level-constructor), a plain exported function of the component
and its input values, that builds such a handle. [§14.1][s14-1] gives the pre-sweep
doctrine. The problem *receives* the environment, and never writes it ([§14.9][s14-9]).

**The returned NamedTuple's names are the equation names** the report and the
failure messages use ([D-118][d-118]). The service packs residuals and tolerances to the
solver's vector by field order. The order is `tolerances`' field order, the
declared side again, canonical for the residuals. Each residual return is
reordered to it (`NamedTuple{keys(tolerances)}(r)`) before packing ([D-151][d-151]). An
equation list spelled in a different order inside the lambda therefore pairs
correctly and costs nothing. The decisions rule holds symmetrically on both ends
of the seam. Names pair, and order never does. Names and types are checked at
setup, because the guess evaluation the service performs anyway observes the
residual key set. A `tolerances` key-set mismatch, or any field-type disagreement
on either side of the seam, is `TrimProblemInvalid` ([Appendix C][sC]), with the
offending field and the names or types in hand. Order is never a mismatch.

**Checks are equations the service reports once, at the committed state, and
never solves** ([D-262][d-262]). `checks` has the residual function's
signature, and `check_tolerances` pairs with its return as `tolerances` pairs
with the residuals'. The service gathers the checks after the commit, from the
[sweep](#g-sweep) of [boundary zero](#g-boundary-zero) (the initialization
boundary, the ordinary macro-sequence with an empty integrate), and reports
them ([§14.8][s14-8]). Setup observes their return's shape at the guess
evaluation, as it observes the residuals' ([§14.8][s14-8]). Their reads join
the problem's one read set.

The reason for the checks lies in analytic elimination. Under it, the
condition math pins the airspeed and the flight-path angle from the targets
and the atmosphere the user's `params` record holds, while the world measures
against the atmosphere the [baseline](#g-baseline) wrote. If the two disagree,
the residuals vanish at a true equilibrium that is not the requested point,
and nothing in the residual system can tell ([D-139][d-139]). A check reading
EAS (equivalent airspeed) from the world's airdata at the committed state and
subtracting the requested value is where a world measurement meets the
request, so any mismatch moves it. The checks stay out of the solve because
they carry no information for it ([D-262][d-262]). A check earns its place
only on a quantity the world measures by itself. On a quantity the condition
writes directly from a decision, a check compares the number with itself and
is always zero ([D-262][d-262]).

#### The formulation

**Flight.jl's trim formulation is correct at its core and survives verbatim as
user math** ([D-069][d-069]). That core is analytic elimination, namely FlightPhysics'
`θ_constraint` substituting the pitch constraint, filter and actuator equilibria
imposed by construction, and the minimal 7-variable search over `c172.jl`'s
`TrimState`. The services hold the discrete tier through the solve
([§14.8][s14-8], [D-213][d-213]), so a controller's stores are not decisions,
and the values that keep a closed loop at rest, such as each integrator's
trim value, are the author's to derive and write into the condition
([D-063][d-063]).

What changes is the numerics. Trim is a square root-find. The Cessna 172
model's derivative-free scalar minimization over $\|r\|^2$ against a hand-scaled
absolute `stopval` was the rational choice only because Jacobians through
FlightCore's mutating `f_ode!` chain and the assignment math were out of reach
([D-069][d-069]).

The *default* is nonlinear least squares on $r(d)$ with exact AD Jacobians, in
the trust-region/Levenberg–Marquardt family ([§14.8][s14-8], [D-069][d-069]).
The `Dual` [activation](#g-activation) (the build's typed products at a given
scalar type) seeds the decision variables through the `T`-generic assignment,
sweep and `x_deriv`. The seeds survive the condition write because a
decision-descended leaf is `Dual`-typed in the shape and keeps its partials
([§14.3][s14-3], [D-148][d-148]). Convergence is quadratic (~5–15
evaluations), the tolerances are per-residual and physical, and failure
reports name the unbalanced equations with magnitudes. The convergence verdict
itself is service-owned and backend-independent ([§14.8][s14-8]).

**Non-squareness degrades gracefully** ([D-069][d-069]). Redundant actuation
becomes weighted or minimum-norm least squares. Infeasible demands converge to
a nonzero residual identifying the impossible balance. At the solution,
$\partial r / \partial d$ is free flight-physics data (control effectiveness)
that cross-checks linearization.

**The derivative-free scalar path would survive as the fallback**, with
Flight.jl's algorithm as its degenerate case ([D-069][d-069]). [§14.8][s14-8]
gives the normalization of the residuals against the tolerances that would
repair the hand-scaled absolute threshold.

#### Recorded extensions

**Two problems are [recorded, not built](#g-recorded-not-built)** (a
worked-out extension deliberately left unimplemented, its seams named)
([D-069][d-069]). They are closed-loop sampled-data trim and on-ground static
equilibrium, each simply another problem value over the same service.
Closed-loop trim appends `s_update(s) - s = 0` residuals via a nondestructive
[scratch](#g-scratch) evaluation of `s_update`, which was structurally
impossible under FlightCore's mutating `f_periodic!`. On-ground static equilibrium
solves strut compressions and attitude against gear forces.

### 14.8 The trim service: solver seam, scratch stores, commit and report

A [`TrimProblem`](#g-trimproblem) is an inert value until a service runs it.
`trim!` is that service. It drives a solver it holds behind one method, works
on its own [scratch](#g-scratch) stores (mutable working storage whose contents
are never authoritative), commits a converged solution the way `init!` would,
and returns a report.

#### The backend seam

The signature is
`trim!(model, problem; baseline, t0 = 0.0, backend = LevenbergMarquardt())`, where
`model` is a [`Model`](#g-model) (a deployment materialized at one scalar type) at `Float64`
([D-319][d-319]). A `Model` at another scalar is refused as `ArgumentInvalid` with reason
`:non_nominal` ([D-319][d-319]). A `Model` that a simulation has claimed is refused before
any check, as `ArgumentInvalid` with reason `:claimed`, since the call commits
([D-318][d-318], [D-319][d-319]). The `baseline` keyword takes a [baseline](#g-baseline) (a full-coverage
condition, such as an aircraft-shipped function returns). `trim!(sim, problem; …)`
gates on the simulation's lifecycle and commits through the simulation's `init!`.

**The default backend is an in-house dense Levenberg–Marquardt**
([D-070][d-070]). For decision dimensions ~10 with exact Jacobians, the core is
~100 lines, namely a damping loop, a small linear solve and a convergence
test. That is the [§10.2][s10-2] stepper precedent exactly, a tiny needed core
against a heavy dependency. The per-residual physical tolerances sharpen the
case ([§14.7][s14-7]). They are a convergence test no external package spells
natively. That is precisely why the *service*, not the backend, applies it.

**The backend [seam](#g-seam) is a pinned signature**, value-passed, with one
required method per backend ([D-158][d-158]). That one method is the seam.

```julia
solve(backend, eval!, d0, lower, upper, tol) -> (; d, status, n_evaluations, n_iterations)
```

`eval!(r, J, d)` is in-place and always fills `r`, the residual vector packed in
`tolerances`' field order. It fills `J` exactly when `J !== nothing`. The Jacobian is
requested by argument, so a Jacobian-free backend simply always passes `nothing`,
and there is still exactly one evaluation method to implement.

`d0`, `lower` and `upper` are packed `Vector{Float64}` in `guess`'s field
order, with `±Inf` meaning unbounded. The declared side is canonical on both
ends, and the service has canonicalized before packing ([§14.7][s14-7]). A
backend that ignores bounds therefore ignores two vectors, not a missing
argument.

`tol` is a `Vector{Float64}` in `tolerances`' field order. It is data the
backend *may* stop on, under the service's per-backend-family translation
below, and it is decisive of nothing.

The return holds `d`, the solution, `status::Symbol`, and the diagnostic counts
`n_evaluations` and `n_iterations`. **The status set is deliberately open**,
and the status is recorded verbatim in the report because the verdict is the
service's ([D-158][d-158]). The name `solve` is subject to the exported-name
audit (`pending.md`) like every other API spelling. The backend sees vectors
and never names, so the solution it returns unpacks by the same order it was
given ([D-151][d-151]).

#### The convergence verdict

**The convergence verdict is the service's, uniformly** ([D-150][d-150]).
`converged` means `all(abs.(rᵢ) .≤ tolᵢ)`. That is the per-residual box test
([§14.7][s14-7]) in its own physical units, evaluated by the service at the
backend's returned point. It is one residual evaluation, noise against the
solve that produced it. That verdict, and nothing else, gates the commit and
fills `TrimReport.converged`. The backend's returned `status` is recorded in
the report as diagnostic data, and it is authoritative over nothing.

#### The tolerance translation

The tolerance translation is the service's too, per backend family
([D-150][d-150], [D-421][d-421]). In least-squares backends the tolerances *are* the
stopping criterion. They feed the per-residual test directly, so the damping
loop of Levenberg–Marquardt (LM) tests exactly what the service will re-test.

The derivative-free fallback is designed and not yet built, and `pending.md` lists
it ([D-070][d-070]). In the design it is `NLoptBackend(:LN_BOBYQA)` in a package extension.
It would pass `nothing` for the Jacobian, keep Flight.jl's algorithm one keyword
away, and leave the framework core carrying zero optimizer dependencies. For
that fallback the service would square *and normalize*. The objective minimized
would be $\sum_i (r_i/\mathit{tol}_i)^2$ with `stopval = 1`. That objective is
dimensionless where the threshold in Flight.jl's Cessna 172 model (`c172.jl`) was
hand-scaled and absolute ([§14.7][s14-7]). It is a well-scaled valley where a raw
$\|r\|^2$ sums forces against moments.

The two criteria cannot disagree in the dangerous direction, because of this
implication ([D-150][d-150]).

$$\sum_i (r_i/\mathit{tol}_i)^2 \le 1
\quad\Longrightarrow\quad (r_i/\mathit{tol}_i)^2 \le 1 \;\text{ for every } i$$

The `stopval` sphere is therefore *inscribed* in the tolerance box, and a
fallback stopping at `stopval` necessarily passes the service's box test. The
converse disagreement, a backend stopping early and reporting an optimistic
status, is caught by the re-check, which remains the single authority. What is
*not* claimed is point identity. Different backends may land on different
solutions, which is an algorithmic difference and a legitimate one. What is
eliminated is per-backend meanings of `converged`.

#### Box bounds and saturated decisions

**Box bounds are honored by step projection** ([D-070][d-070]). A decision variable saturated
*at the solution* is listed in the report's saturated list, as
`(:elevator, :upper)`. That is the classic CG-limit diagnostic (CG is the center
of gravity), which Flight.jl's trim leaves inferable only from mysterious
residuals.

#### Scratch stores

Every `trim!` invocation instantiates a fresh working store set. Each half of it
(below) is a scratch `Model` of its own, materialized from the deployment the
service was called on ([D-317][d-317], [D-319][d-319]). The set holds the `x` backing, the `s` and `m`
stores, the [root input](#g-root-input) and [signal tables](#g-signal-table), and the derivative [buffer](#g-buffer). The set is
built from the *layout* of the [activation](#g-activation) (the build's typed products at a given
scalar type). The layout is the reusable compiled artifact. The buffers are
per-invocation and die with the call (stopped-sim allocation, [§9.8][s9-8]). Each set
also calls every [workspace](#g-workspace) (component-declared mutable scratch, arriving as `ws`)
allocator once, at the activation's scalar ([D-077][d-077]).

The `Dual` backend's buffers being un-aliasable by type is defense in depth,
not the mechanism. A `Float64` backend, such as the designed NLopt fallback,
would get equally fresh buffers. The invariant is backend-independent.
**The simulation's authoritative stores have exactly one writer**, the commit
through [boundary zero](#g-boundary-zero) (the initialization boundary, the
ordinary macro-sequence with an empty integrate) ([D-070][d-070]).

Setup applies `override(baseline, condition(guess))`, the problem's
[condition](#g-condition) at the guess layered over the baseline by
[override](#g-override), to the scratch set once. That application's full
coverage is *checked here*, as [§14.6][s14-6] requires ([D-149][d-149]).
[Sweeps](#g-sweep) therefore see a complete world. Raw instantiation is sound
exactly because of that check, since every root input is written before any
read. An incomplete `baseline` is one declaration-ordered
`UninitializedInputs` at setup rather than a whole solve against undefined
[cells](#g-cell).

**The frozen cells are established, not probe-seeded** ([D-213][d-213]). At the seeded
activation the discrete [tier](#g-tier) (the discrete side of the hybrid formalism) is
frozen ([§9.4][s9-4]). Its stages never run there, so nothing at that activation can
derive a discrete output cell from the authored `s`. Setup therefore instantiates
the scratch set in two halves. A [nominal](#g-nominal) set (one at the `Float64` activation)
takes the composite first, by the dynamic walk ([§14.4][s14-4]), and runs one
establishment round. That round is boundary zero's sweep with every discrete
output stage admitted, due or not ([D-205][d-205]), with no [projection](#g-projection) (the per-component
`x_projection` hook), no [guards](#g-guard) and no `s_update`. The seeded set is then written by
the specialized `apply!`. Its frozen cells are copied from the nominal set,
`Float64` values that a continuous consumer reads as zero-partial constants
([§9.5][s9-5]). Every cell the iterations read is thus derived from the authored world.
A frozen cell holds what the authored discrete state publishes, which makes
"held at the operating point" literal. No scratch cell holds a synthesized
[probe value](#g-probe-value) (a fabricated value a build-time probe runs on). That is the
probe-value barrier of [§14.6][s14-6] reaching the scratch world, as [D-205][d-205] made it reach
the published one. The iterations are untouched ([§14.5][s14-5]). They run at the seeded
activation, over the continuous chain and `x_deriv` alone. The empty problem
(below) is the nominal half alone ([D-213][d-213]). Its one evaluation is that
establishment round, followed by one derivative evaluation for the reads.

The commit (below) applies the same composite over the same `baseline`, so its
coverage is setup's. Commit's totality check is therefore structurally
unfailable through the trim path, and it stands as the shared `init!` defense
([D-149][d-149]). A converged solve is always committable. `TrimReport` therefore carries
no committed flag, and the no-throw rule (below) needs no exception.

Iterations rewrite the composite's write-set via the compiled plan. The
write-set is `override(baseline, condition(d))`, the same tree setup resolved, so
a store both layers touch merges exactly as it did at setup. An LM evaluation is
one Dual-seeded sweep yielding `r` from the value parts and `J` from the partials,
together ([D-069][d-069]). No convergence means no commit. Non-convergence is the
service's box test failing at the returned point, whatever status the backend
attached to it ([D-150][d-150]). No commit means the sim is bit-for-bit untouched,
including "never initialized". Flight.jl's warn-but-assign, where the Cessna 172
trim warns on a failed optimization and assigns its result anyway, is
structurally impossible.

The same structure covers an interrupt. Ctrl-C during a long solve unwinds an
ordinary Julia call operating on per-invocation scratch stores. No commit has
happened, and the simulation is bit-for-bit untouched, exactly as a
non-converged solve leaves it. The services need no counterpart to the loop's
boundary masking ([§12.4][s12-4]). An interrupt inside the commit's boundary
zero moves the simulation to `built` and propagates raw ([§13.4][s13-4],
[D-223][d-223]).

#### The commit, in full

The committed solution is applied as an `init!` in every respect. It is
`override(baseline, condition(d*))` through boundary zero, with the pre-write
[root-input totality](#g-root-input-totality) check ([§14.6][s14-6]), the
sequence ([§14.5][s14-5]) and guards at commit. That check requires the
application to cover every root input.

The `t0` argument that anchors the grid, and its default, are the same for
both init-service entry points ([§14.5][s14-5], [D-110][d-110]). The
[recorders](#g-recorders) (the trace and the log jointly) restart exactly as
[§12.6][s12-6] states for `init!` ([D-110][d-110]). The [trace](#g-trace)
(the primary record of a session) and the log are new objects. Any
[batches](#g-batch) still in [staging cells](#g-staging-cell) (where a
device's pending write batch waits between drains) are cleared.

A fresh recording that starts at its own anchor is the natural shape of an
[unattended run](#g-unattended-run) (a run with empty staging and no snapshot readers). Trim is not
offered at a point reached by flying. It takes an authored baseline.
Fly-then-retrim is spelled as a [checkpoint](#g-checkpoint) (the `Model`'s state at a frame top as
one value) of the flight, then a trim baseline authored from what the checkpoint
shows ([D-273][d-273]).

#### The report

`trim!` returns a structured `TrimReport` ([D-070][d-070]). The sketch names
its eleven fields in order.

```julia
# what trim! returns: a value to read, never an exception to catch
struct TrimReport
    converged            # the service's box test at the backend's returned point
    solution             # the solution NamedTuple, guess-shaped
    residuals            # the solved-point residuals the verdict is read off
    tolerances           # the tolerances they come with
    committed_residuals  # the same residuals, re-gathered after the commit
    committed_checks     # the check function's return at the committed state
    status               # the backend's returned status, diagnostic only
    n_evaluations        # the backend's evaluation count
    n_iterations         # the backend's iteration count
    saturated            # the saturated-bounds list
    fired_events         # the events the commit fired
end
```

The list below takes the fields in turn.

- `converged` is the service's own box test at the returned point, never a
  backend's opinion.
- `solution` is the solution NamedTuple. It is guess-shaped, hence
  warm-startable.
- `residuals` are the solved-point residuals, and `tolerances` the tolerances they
  come with ([D-155][d-155]). They are the very numbers the verdict is read off, gathered
  at the backend's returned point.
- `committed_residuals` are the committed-state residuals, the same
  residuals re-gathered from the boundary-zero world after the commit.
- `committed_checks` holds the committed-state checks, the check function's
  return at the committed state. They are gathered beside the
  committed-state residuals and empty when the problem declares none
  ([§14.7][s14-7]).
- `status` is the backend's returned status, and `n_evaluations` and
  `n_iterations` are its evaluation and iteration counts. These are
  diagnostic throughout, informative about *how* the solve went and decisive
  about nothing.
- `saturated` is the saturated-bounds list.
- `fired_events` holds the commit's fired events, as component paths and
  event names. The list is empty when boundary zero ran quiet
  ([§14.5][s14-5], [D-126][d-126]).

The committed-state residuals are nearly free ([D-155][d-155]). Boundary zero's sweep has
already run, so the residuals' declared reads need one derivative evaluation and
a gather from it. There is no offset caveat to carry. Every output stage
publishes at boundary zero ([D-205][d-205], [§14.5][s14-5]). A residual reading the [port](#g-port) (one
declared name, one cell) of a [component](#g-component) whose schedule has a nonzero [phase](#g-phase) (an
offset against its grid) therefore reads a commit-refreshed cell like any other.
Those committed-state residuals are the numbers describing the state the
simulation is actually *in*, which is the point a `linearize` at its default
operating point ([§14.10][s14-10]) reads.

A non-empty fired-event set also raises `TrimCommitEvents`, a logged warning
([Appendix C][sC], [D-126][d-126]). The committed stores then sit at the post-handler point,
not the reported solution, and that is the point `linearize` reads by default.

The two residual sets are what make the moved point auditable. **A converged solve
whose committed-state residuals violate the box test raises `TrimCommitResiduals`**,
naming the offending residuals with their committed values and tolerances
([Appendix C][sC], [D-155][d-155]). The move, whether `x_projection` or a commit-fired handler
([§14.5][s14-5]), is surfaced rather than left silent. The verdict itself is not
revisited. It gated the commit at the solved point, and the numbers stand as
reported ([D-150][d-150]).

The committed-state checks audit the point rather than the move. **A
converged solve whose committed-state checks leave their tolerances raises
`TrimCommitChecks`**, naming the offending checks with their committed values
and tolerances ([Appendix C][sC], [D-262][d-262]). The equilibrium is real.
The operating point is not the one the problem asked for, which is what a
params-vs-world atmosphere mismatch produces under elimination
([§14.7][s14-7], [D-139][d-139]). The checks are gathered from the same
boundary-zero sweep, so they cost no evaluation of their own. No commit means
no checks, exactly as for the committed-state residuals.

**Non-convergence never throws** ([D-070][d-070]). It is an expected *outcome*, not broken
machinery ([§13.5][s13-5]). When trims span the flight envelope, hitting the infeasible
edge is information.

A malformed problem is a different case. It fails at setup with a
`DiagnosticError` carrying `TrimProblemInvalid` ([Appendix C][sC]). The
malformed cases are these.

- A field that is not a NamedTuple, or a `reads` that is no read set.
- A guess/bounds key-set or field-type disagreement.
- A box with `lower` above `upper` ([D-422][d-422]).
- A tolerance or check tolerance that is not finite and positive ([D-422][d-422]).
- A `tolerances`/residual key-set mismatch observed at the setup guess
  evaluation, and a `check_tolerances`/check key-set mismatch observed at the
  same evaluation.
- A residual or check return whose fields are not real scalars, observed at
  that evaluation too.

The error carries the offending field with the names or types in hand,
collected. The read set's own refusals ride beside it, `ReadResolution` and
the path walk's `PathResolution` ([§14.4][s14-4], [D-406][d-406]). An unknown
`reads` [selector](#g-selector) (one of the closed family of deferred reads)
is refused that way. A permuted spelling is none of these ([§14.7][s14-7]).

A throw inside the commit's boundary zero is a third case, and neither of
those. It is model code failing. **The throw propagates out of `trim!` as the
commit's `StepError`**, and no report is returned for that solve
([D-224][d-224]). The simulation is left `built` ([§13.4][s13-4],
[D-223][d-223]).

An *empty* problem is none of them either. **`TrimProblem(guess = (;), …)` is legal**,
not `TrimProblemInvalid` ([D-156][d-156]). With zero decision variables the solver is
bypassed outright. There is nothing to pack, no seeded activation and no backend
call. The service simply evaluates the residuals once at
`override(baseline, condition((;)))`, the baseline with whatever the problem's
condition sets. The ordinary box test decides `converged`, and the commit runs as
usual. The empty problem asks "is this operating point an equilibrium?" It
evaluates this condition's equations and reports, which is useful in its own
right and costs no solve.

#### The AD obligation

**The default formulation requires `Dual` genericity of exactly the
continuous output-stage chains and `x_deriv`**, plus the user's assignment
and residual math ([D-070][d-070]). The discrete tier's stages and
`s_update`, and the event system's guards and handlers, never see a `Dual`.
They are frozen constants with zero partials, semantically exact
([§8.2][s8-2]).

This is *not a new obligation*. It is the same activation linearization is defined
on. AD-readiness is also a build-checked property. A [pinned](#g-walked) intermediate (a
value held at `Float64` inside authored continuous math) makes the Dual [probe](#g-probe) (the
build's single evaluation of a user function) fail with a culprit-naming
`MethodError` or `InexactError` ([D-307][d-307]). `build(world; activations)` puts the probe in
CI ([D-280][d-280]). The robustness comes from enforcement, not hope.

A migration audit of Flight.jl's Cessna 172 model against this obligation took
one afternoon. Its findings on tables and saturations follow ([D-070][d-070]), and its
two Flight.jl-only findings, on the landing gear and the `norm`-at-zero guards,
are in the `migration_outline.md` companion.

- `Interpolations.jl` tables (propeller coefficient maps, engine maps) must accept
  generic scalars. They do. A call `itp(x::Dual)` works through the
  `BSpline`/`scale`/`extrapolate` compositions in Flight.jl's tables. Prefer cubic
  knots over linear where partials matter, though, since linear knots make
  Jacobian elements piecewise-constant. That is no regression against finite
  differences ([D-307][d-307]). A manual chain rule via `Interpolations.gradient` is the
  escape hatch for anything exotic, and the pattern for wrapping non-Julia black
  boxes ([§14.10][s14-10], [D-266][d-266]).
- In-model saturations (actuator limits, idle/FRC clamps) zero Jacobian columns
  when active. FRC is the friction constraint compensator of FlightPhysics'
  piston engine (`piston.jl`). LM damping tolerates the rank deficiency ([D-070][d-070]).
  The report's `saturated` list names a decision only at its own bound, so an
  in-model saturation shows in the Jacobian's zero columns rather than in the
  report. Cruise trim leaves those saturations inactive.

The derivative-free fallback would be chosen per call, through the one
`backend =` keyword.

### 14.9 Mounting: problems as relocatable values

This section treats a [`TrimProblem`](#g-trimproblem) (the closed nine-field value a trim solves) as
a relocatable value. [Mounting](#g-mounting) (relocating a whole problem or tap set to a
prefix) is the work of [`at`](#g-at), the scoping combinator. The section says what a
problem is, then how `at` lifts one, how a mounted read set and mounted input
entries resolve, why a problem never authors the environment, and how worlds,
thin rigs (worlds holding only the aircraft and its environment) and swarms use
the lift.

**A `TrimProblem` is not a [condition](#g-condition) but an implicitly specified condition** ([D-071][d-071]).
A condition is the datum that says "set this build to this state". `condition` is
a condition-*valued function* over the decision space. `reads`/`residuals` are the
equations that pin the free variables down. `guess`, `lower` and `upper` say where to
search. Solving makes the implicit condition explicit. The commit is then
literally an init, `override(baseline, condition(d*))` through [boundary zero](#g-boundary-zero) (the
initialization boundary, the ordinary macro-sequence with an empty integrate).
[`override`](#g-override) is the ordered, asymmetric layering combinator, in which the patch wins
on a shared leaf. The services unify as clients of one condition algebra. `init!`
applies an explicit condition, and `trim!` searches a family for the member
satisfying its equations.

**`at` lifts a problem field by field**, and each field falls in one of three
cases ([D-071][d-071], [D-277][d-277]). The `condition` field is
condition-producing (path-relative), so the lift post-composes it. The
`reads` field is a read set, and the lift prepends the prefix to the set's
mount chain (the prefixes it is mounted under, root first). Every other field
is path-free and passes through. The rule that residual math sees only the
gathered NamedTuple ([§14.7][s14-7]) is what makes the residuals path-free.

```julia
at(prefix::String, p::TrimProblem) = TrimProblem(
    guess      = p.guess,                      #path-free: pass through
    lower      = p.lower,
    upper      = p.upper,
    condition  = d -> at(prefix, p.condition(d)),  #post-compose: wrap each returned tree
    reads      = at(prefix, p.reads),              #inert selector data: the prefix is prepended to the read set's mount chain
    residuals  = p.residuals,                      #path-free: pass through
    tolerances = p.tolerances,
    checks     = p.checks,
    check_tolerances = p.check_tolerances)
```

The condition side needs nothing new at resolution. The flattening accumulator
of [§14.3][s14-3] enters each `Scoped` wrapper (the node `at` builds over a condition node)
and prefixes every condition entry below it.

**A read set carries its mount chain as data** ([D-277][d-277]). A read set is a `Reads` value.
`at(prefix, read_set)` prepends the prefix to the read set's mount chain and joins
nothing. **A `Reads` value is no condition node**, so `Scoped` never wraps one ([D-277][d-277]).
**Resolution walks the chain from the root**, each prefix from the level the
previous one reached ([§13.3][s13-3], [D-277][d-277]). It then rebases every [selector](#g-selector) (one of the
closed family of deferred reads) to the root before the selector resolves. A
path selector's path is joined to the mount (`"vehicle/dynamics"` →
`"wing/vehicle/dynamics"`). `get_input` names an input [face](#g-face) (the name a port wears
on its [component](#g-component)'s boundary) of the mount level. It follows the export chain to
the [root input](#g-root-input) it lands on (the root component's own input face). `get_face` names
an output face of the mount level and reads its producer's port ([D-277][d-277]).

**A refusal spells the selector as authored and names the mount**
([D-277][d-277]). `at` refuses an empty prefix on a read set, as it does on a
condition node ([§14.2][s14-2]), and raises `ReadSetMisuse`. A problem's lift
and a tap set's lift reach that refusal through `at` on their read sets
([D-278][d-278]).

**Input entries authored in the aircraft's face vocabulary resolve through the
export chain from the mount point** ([D-071][d-071]). For a wingman aircraft
mounted at `"wing"`, the input entry `throttle` resolves to root input
`"wing.throttle"`. An unexported face fails resolution by name, and correctly so
([§14.2][s14-2]). An internally wired input (a [scenario
component](#g-scenario-component) driving the wingman's throttle) is untrimmable
from outside. Resolution refuses it by name, with the producer that drives it in
hand, as `ConditionResolution` for a condition entry and as `ReadResolution` for
a `get_input` ([D-277][d-277], [D-427][d-427]). The service compiles the scoped condition and reads,
and runs the identical loop. It never knows where its paths are mounted.

**A problem never authors the environment** ([D-139][d-139], [D-417][d-417]). The environment is
the business of the world and of the [`baseline`](#g-baseline) (the
full-coverage condition `trim!` takes as a keyword). In a full world it is a
sibling component's root inputs. In a thin rig it is a root input holding an
isbits [handle](#g-field-handle) (an immutable query object carried on an
ordinary port). In a thin rig it can also be a [constant
source](#g-constant-source) (a library component publishing a value its instance
holds) holding a bulk-data handle ([D-364][d-364]). The problem *receives* its
handles through the user parameter record ([§14.7][s14-7]), and only queries
them.

The reason is the resolution rule stated above. A condition entry naming an
internally wired input fails by name, correctly. A problem writing an
environment face would therefore be applicable only to those rigs where that
face happens to be unconnected. The relocatability this section exists to
guarantee would be lost.

**The world wrapper dissolves** ([D-071][d-071]). FlightPhysics' world initializer, its
method of FlightCore's `f_init!` on a FlightCore `Model{<:SimpleWorld}` (initialize
environment, then call the aircraft's trim), has no successor method. The
environment, the other aircraft and all root inputs are covered by the `baseline`
condition ([§14.6][s14-6]), applied once at setup. The commit is
`override(baseline, at(mount, condition(d*)))`. Method nesting became value
layering.

"Aircraft as root" is a thin rig. **Design tasks use the rig this design records,
[`design_world(ac)`](#g-design_world)** ([D-071][d-071]). They need one because by default the aircraft is not
literally the root. Its environment inputs are function-valued signals ([§4.4][s4-4]),
wired from provider components. The rig is `design_world(ac)` = aircraft +
`SimpleAtmosphere(wind = NoWind())` + `HorizontalTerrain`, where `SimpleAtmosphere`
and `NoWind` are FlightPhysics' atmosphere types. `design_world` promotes the ad-hoc
atmosphere and terrain FlightCore `Model`s inside Flight.jl's `linearize` to a named
artifact. There is one mechanism. The "root" case is the shallowest world, and
the trim problem mounts at `"aircraft"` like anywhere else.

Leaving an environment face *unconnected* is legal by construction, though, for an
isbits handle ([D-364][d-364]). The face becomes an ordinary root input holding the
handle *value*, written by the `baseline` like any other root input. That is the
test-rig idiom. It is the function-valued sibling of a constant source, with
zero ceremony for a frozen environment. **A handle that references bulk data is
never a root input**, and the rig wires a constant source holding it ([D-364][d-364]). Root
inputs are traced and checkpointed by value, and [§4.4][s4-4] states why such a handle
cannot be one ([D-237][d-237]). For design tasks the rig stays `design_world(ac)`. That
keeps the environment's tunables in the root-input vocabulary that conditions,
linearization's input surface and the [trace header](#g-trace-header) (the trace's fixed preamble)
already speak.

The swarm doctrine covers trims of several aircraft. **The service solves one
problem at a time** ([D-071][d-071]). Sequential independent trims (trim the lead aircraft,
commit, trim the wingman against the committed world) cover weak or one-way
coupling. A joint trim is user-side value composition. Concatenate decision
NamedTuples under prefixed names, combine the scoped condition trees, and stack
the residuals. If joint trims become routine, **a
`product(p₁ => "lead", p₂ => "wing")` helper is the extension recorded for them**
([D-071][d-071]). That helper is [recorded, not built](#g-recorded-not-built) (a worked-out extension deliberately
left unimplemented, its seams named).

### 14.10 Linearization: tap selectors, one seeded pass, a pure query

`linearize` computes the matrices `A`, `B`, `C` and `D` about an operating
point in one seeded evaluation, and it commits nothing. What it seeds and
reads is a [tap set](#g-taps) (three labeled lists declaring what
linearization seeds and reports). This section covers, in order, the tap set,
the operating point, the seeded pass, the leaves the pass seeds and the leaves
it holds frozen, the returned value, the guidance on coordinates, the recorded
sampled-data extension, and declared non-participation with the local
derivative rule.

#### The tap set

Flight.jl's per-aircraft `XStateSpace`/`UStateSpace`/`YStateSpace` structs,
plus the `get_*_ss`/`assign_*_ss!` shuttle methods, run to ~150 lines of
bookkeeping per variant. All of it becomes three [selector](#g-selector)
lists (the closed family of deferred reads resolving against a source).
**The three lists are declared together as one tap set,
`taps(x = …, u = …, y = …)`** ([D-072][d-072], [D-272][d-272]). Membership is
closed per list. The `x` list takes `get_state`, the `u` list `get_input`,
and the `y` list `get_output` and `get_face` ([§14.4][s14-4]). The NamedTuple
key is the label control design slices by.

**A tap names one scalar** ([D-272][d-272]). Its [leaf address](#g-leaf-address) (the field name with dotted and
bracketed steps below it) resolves to one scalar leaf ([§14.4][s14-4], [D-276][d-276]). So a
vector leaf yields *named scalars*, one tap per element. A seeded tap, in the `x` or
`u` list, reaches its scalar through one index step at most and never a `.name`
step, because a seed is written into a whole state field or [root input](#g-root-input) (the
root's own input face), or into one array element of it. A seeded tap's leaf is
exactly `Float64`. Any other seeded address is rejected at resolution as a
`TapResolution` ([D-424][d-424]). A `y` tap is a read and takes any leaf address. A tap
resolving to a vector or a struct is rejected at resolution as a `TapResolution`,
and so is a member in the wrong list. A second tap resolving to a site already
seeded is rejected naming the earlier label, since one site is one column and a
second seed there would overwrite the first ([D-272][d-272], [D-419][d-419]).

```julia
taps(x = (p = get_state("vehicle/dynamics", "ω_eb_b[1]"),
          θ = get_state("vehicle/kinematics", :θ_nb), …),
     u = (throttle_cmd = get_input(:throttle),
          wind_n = get_input("wind[1]"), …),
     y = (EAS = get_output("vehicle/airflow", :EAS), …))
```

The three lists are validated at resolution, with [did-you-mean](#g-did-you-mean) errors (the
offending name plus the list-in-hand it should have matched). Those errors are
the selectors' own `ReadResolution` ([D-406][d-406]). The `x` list is validated against the
`x_init` [stores](#g-store) of the continuous [tier](#g-tier) (the continuous or discrete side of the
hybrid formalism), the `u` list against [faces](#g-face), and the `y` list against `y_types`. **An
`x` tap naming a discrete store is rejected at resolution** as a `TapResolution`, with
the tap and its tier in hand ([D-197][d-197]). That is the no-silent-zeros rule ([§9.5][s9-5]).
The discrete tier is frozen ([§8.2][s8-2]), so its only possible partials are zeros. The
rejection's next-move guidance points at the recorded step-map extension below.
The lists compile to offsets once, and relocate whole via `at(prefix, taps)`
([D-072][d-072]). The shuttle layer's successor is that compiled writer/reader pair, and
**no hand-written state-space mapping remains** ([§7.1][s7-1], [D-072][d-072]).

#### The operating point

**Linearization is a pure query** ([D-072][d-072]). It commits nothing and
runs no [boundary zero](#g-boundary-zero) (the initialization boundary, the
ordinary macro-sequence with an empty integrate). It works only on
[scratch](#g-scratch) buffers (mutable working storage whose contents are
never authoritative), and nothing it computes becomes authoritative.
Flight.jl's restore-the-trim dance, the re-`assign!` after the `FiniteDiff`
package dirtied the model, has no successor.

**The default operating point is the [checkpoint](#g-checkpoint)** of the simulation or the [`Model`](#g-model) (a
deployment materialized at one scalar type) as it stands ([D-274][d-274], [D-319][d-319]). A
checkpoint is the `Model`'s state at a frame top as one value. The default point
is `checkpoint(sim)` on a simulation and `checkpoint(model)` on a `Model`, each
restored into the scratch world with no boundary zero ([§12.6][s12-6], [D-274][d-274], [D-319][d-319]). The
frozen tier's [cells](#g-cell) (the typed entries of the signal table) are the checkpoint's
held cells. The seeded half takes each root input's checkpoint value through
[§14.3][s14-3]'s converter, the type's ordinary `convert` at the seeded scalar.
**A root input whose type does not convert is refused as `ConditionResolution`
with reason `:unconvertible`** ([D-428][d-428]), every such root input in one throw
before the first evaluation, with the checkpoint as the origin. After a
`trim!` commit, `linearize(sim, taps)` or `linearize(model, taps)`
is about the trim point with nothing re-specified. **`about = <condition>`, with `t0`
beside it, linearizes anywhere else without touching the sim**, the condition's
coverage checked as [§14.6][s14-6] requires ([D-272][d-272]). `t0` is admitted only there, and a `t0`
passed without `about` is an `ArgumentInvalid` ([D-420][d-420]).

#### The seeded pass

Each invocation instantiates its own scratch store set, the trim service's
mechanism verbatim ([§14.8][s14-8]), and establishes the operating point in it (above).
**It then runs the seeded `Dual` evaluation**, one direction per `x` tap and per `u` tap,
in groups of `width` directions per pass ([D-072][d-072]). **`width` is a keyword of `linearize`,
default 8** ([D-272][d-272]). The default width's scalar type is named. A build can
therefore pre-materialize its [activation](#g-activation) (the build's typed products at a given
scalar type) through `activations` ([§9.4][s9-4]), and a tap set of any size then
linearizes with no compile at the keyboard ([D-272][d-272]). Value parts give `ẋ₀` and `y₀`.
Partials give `A` and `B` against the `x`- and `u`-seeds, and `C` and `D` against the same
seeds read at `y`. All four come out simultaneously, exact to machine precision.
`linearization_walkthrough.md` runs the pass on a two-state model, seed by seed.

```
  x-taps ─┐                                         ┌─ value parts → ẋ₀, y₀
          ├─ seed directions → one Dual evaluation ─┤
  u-taps ─┘          (chunked internally)           └─ partials    → A, B, C, D
```

That seeded evaluation replaces Flight.jl's four `FiniteDiff` Jacobians, their
step-size heuristics and ~4n perturbed evaluations.

#### Seeded and frozen leaves

**Unseeded states sit constant at the operating point**, and so do unseeded root
inputs ([D-072][d-072]). Establishing the operating point embeds their `Float64` values as
zero-partial constants. The discrete tier is frozen with zero partials, which is
precisely "linearize with the discrete state held" ([§8.2][s8-2]). Partials enter
through per-invocation seeding, one rule for `x` and root inputs alike ([§7.2][s7-2],
[D-297][d-297]). [§8.2][s8-2] states which root inputs the schema leaves seedable ([D-295][d-295]). A root
input whose input entry is declared `Pinned` is declaredly unseedable, and its
cell is frozen at every activation. Unseeded means fed by nothing seeded. A
gain scheduled from seeded state carries the schedule's partials into the
Jacobian like any other wired input, and a model that wants it held at its
nominal value routes it through `Freeze` ([§13.7][s13-7], [D-266][d-266]).

**Selecting such a root input as a `B`-matrix tap is rejected at tap resolution** as a
`TapResolution`, with the offending input entry in hand, rather than silently
yielding a zero column ([D-295][d-295], [D-296][d-296]). Under fan-out the rejection names the
pinning consumer, not the face alone. A root input is unseedable whenever any
one of its consumers demands frozen, which is the fan-out meet ([§8.2][s8-2], [D-168][d-168]).
The author's next move is to promote that leaf to a tolerant input entry, or to
route the tap around it. Either move depends on knowing which leaf froze the
root input. A discrete consumer pins its input entry by tier, not by declaration
([§8.2][s8-2]), so a root input it reads is unseedable at every activation with nothing
to promote. The rejection then names the tier, and the next move is to tap the
continuous cell that consumer drives, or the recorded step map
below ([D-272][d-272], [D-419][d-419]).

The table sets seeded and frozen leaves side by side.

| leaf | in the one pass | what fixes it |
|---|---|---|
| a state leaf named by an `x` tap | seeded, one direction | per-invocation seeding |
| any other state leaf | sits constant at the operating point | per-invocation seeding |
| a root input named by a `u` tap | seeded, one direction | per-invocation seeding |
| any other seedable root input | constant, its `Float64` value embedded as a zero-partial constant | per-invocation seeding |
| a root input whose input entry is declared `Pinned` | frozen at every activation, and rejected as a `B`-matrix tap | the schema: a declaration |
| a root input a discrete consumer reads | frozen at every activation, and rejected as a `B`-matrix tap | the tier |
| any discrete-tier leaf | frozen, zero partials | the tier |

#### The returned value

**`linearize` returns a `Linearization` value** ([D-072][d-072], [D-272][d-272]). It holds `ẋ₀`, `x₀`, `u₀` and
`y₀` as NamedTuples under the tap labels, `A`, `B`, `C` and `D` as matrices, and the three
label sets of the taps ([D-272][d-272]). On that data, FlightPhysics'
`subsystem`/`delete_vars` survive as pure label-indexed matrix slicing, with no
model involvement. Flight.jl's `c172x_ctl` LQR (linear-quadratic regulator)
pipeline consumes it with cosmetic changes. **FlightPhysics' `LinearizedSS`, the
[component](#g-component), survives separately, as an ordinary [continuous component](#g-continuous-component)** in the
migrated library ([D-072][d-072]). Its `x_init` is the state vector, its faces are labeled,
and the affine update lives in `y_direct`/`x_deriv`. It has no privileges, and its
schema is everyone else's.

#### Coordinate guidance

The recorded guidance is that linearization taps should select
minimal-coordinate mechanizations ([D-072][d-072]). Perturbing Euler-angle states is
meaningful where seeding quaternion components steps off the unit-norm manifold.
This is why Flight.jl's C172X design code linearizes the aircraft's `{NED}`
variant, the one built on north-east-down (NED) kinematics. [`design_world(ac)`](#g-design_world)
(the thin rig that mounts an aircraft for trim and linearization) rigs that
variant, promoting implicit practice to stated rule. The coordinate choice
belongs to the tap author, not the framework.

#### The sampled-data extension

**The sampled-data `Dual` activation is [recorded, not built](#g-recorded-not-built)**, a worked-out extension
deliberately left unimplemented with its seams named ([D-073][d-073]). The frozen-exact
doctrine is consumer-scoped, not a capability wall. Trim and linearization
differentiate the continuous dynamics with the discrete state held, and for that
a frozen discrete output (a zero-order-hold constant with zero partials) is the
exact answer, as [§7.2][s7-2] states ([D-072][d-072]). The frozen discrete cell is not an AD
limitation on the signal path. It is the true zero of an instantaneous
dependence that the hybrid semantics never had. The signal flow through a
discrete component is temporal, not instantaneous, and AD follows the actual
data movement. `frozen_discrete_walkthrough.md` works the three-component chain
through.

Differentiating "through" the discrete side means differentiating a
*different object*. That object is the sampled-data step map
$\Phi : ((x_k, s_k), \mathrm{inputs}) \to (x_{k+1}, s_{k+1})$, taken over the
model's *whole* state, both letters at once. One evaluation of $\Phi$
integrates one period, then runs the [due](#g-due) [ticks](#g-tick). The
extension is additive along existing [seams](#g-seam).

- [Walked](#g-walked)-leaf parametrization of the discrete tier's real-scalar
  state leaves. Counters and enums stay pinned, like `m`.
- Opt-in participation on discrete components, with frozen-exact staying the
  default. A participating component opts in through an explicit trait, and
  that trait turns the walk on for its [contracts](#g-contract) (its declared
  interface). Its `Float64` leaves follow the scalar and `Pinned` keeps its
  meaning, exactly as on the continuous tier ([§8.2][s8-2]). Participation
  therefore stays authored per leaf on that tier too, and no declaration
  changes shape, which gives graceful migration with no flag day.
- One new activation, "continuous chain + `x_deriv` + the discrete tier's
  output stages + `s_update`" ([§9.4][s9-4]).
- Forward sensitivities through the in-house RK steppers, for free. That is a
  payoff of owning the loop ([§10.1][s10-1]).
- **A distinct `s`-tap list sits beside the `x` list**, labeling the step
  map's state blocks $\partial(x^+, s^+)/\partial(x, s)$ ([D-197][d-197]). The
  `x` list keeps its continuous meaning unchanged.

The honest limit is that $\Phi$ is differentiable only where the event pattern
is locally constant. Exactness across a firing needs saltation corrections (the
jump terms a sensitivity takes across an event). The scope is therefore
event-quiescent operating points, which trim points already are, because [guards](#g-guard)
at commit see to that ([§14.5][s14-5]). The scope comes with a loud diagnostic if an
event fires inside a differentiated step. Two consumers wait. The first is the
closed-loop trim extension ([§14.7][s14-7]), whose `s_update(s) - s = 0` residuals would
currently need the derivative-free fallback, since a frozen `s_update` has no
Jacobian columns. The second is exact discrete-time linearization of the full
loop, which is digital design on the exact discretized plant instead of
continuous linearization plus Tustin's discretization.

#### Declared non-participation

Both halves of non-participation have a spelling ([D-263][d-263]). The output half is the
freeze door, which declares a leaf frozen under differentiation as [§8.2][s8-2] and [§9.5][s9-5]
spell it ([D-286][d-286]). An opaque wrapper, such as an FMU (a Functional Mock-up Unit,
a packaged simulation unit) or a C aerodynamic table, and a deliberately severed
coupling can therefore both say so in the schema, instead of showing up in
Jacobians as unexplained zero rows. The conformance check holds them to it at
every activation ([D-286][d-286]). The input half is the FFI door ([§8.2][s8-2]). A consumer's
`Pinned` input entry declares "never hand me partials", enforced at the wire
([§6.1][s6-1], [D-263][d-263]). At a root input, such an input entry *is* the forbid-seeding marker
itself. That marker carries semantics rather than mere protection, because it
types the root-input cell at every activation. An unseeded root input is
therefore a *choice*, where a `Pinned`-entry root input is a *declaration* ([D-295][d-295]).

An implementation that cannot take `Dual`s has a third move. The marker records
that a leaf carries no partials, not that an implementation cannot propagate
them. **A component that must participate keeps its input entry tolerant and
supplies its own local derivative inside the stage** ([D-266][d-266]). A C table or an FMU
whose coupling matters to the Jacobian is such a component. It evaluates at the
value and obtains a local Jacobian by whatever means it has, such as a finite
difference at a step its own grid suggests or the table's analytic slope. It
then chains that Jacobian onto the incoming partials ([D-266][d-266]).

```julia
lookup(tb, u::Float64) = c_lookup(tb, u)                      # nominal: straight to the table

function lookup(tb, u::ForwardDiff.Dual{Tag}) where {Tag}      # Dual: the local rule
    u0 = ForwardDiff.value(u)
    y0 = c_lookup(tb, u0)
    h  = sqrt(eps(u0))                                         # or a step the table's grid suggests
    dy = (c_lookup(tb, u0 + h) - y0) / h
    return ForwardDiff.Dual{Tag}(y0, dy * ForwardDiff.partials(u))
end
```

The block strips the partials with `ForwardDiff.value` mid-expression, which [§9.5][s9-5]
leaves legal at an unpinned leaf, and the seeded pass sees the component as an
ordinary differentiable one. The derivative is finite-difference in quality on
this one component and exact everywhere else. **Linearization keeps this one
mechanism and no perturbation-based fallback** ([D-266][d-266]). The derivative-free trim
fallback ([§14.8][s14-8]) would serve problems with no Jacobian columns, a case
linearization does not have. `handle_walk_walkthrough.md` places the rule beside
the `Freeze` block ([§13.7][s13-7]) and the pinned input entry.

What stays recorded is only the remaining tooling over the schema's declared
non-participation ([D-426][d-426]). One piece is pinned-face validation by the tap
declaration, where selecting a declared-frozen output is a warning. The other is
a [feedthrough](#g-feedthrough)-graph lint, where a frozen output fed by participating inputs
names the severed coupling. Both are additive when a consumer shows up, with no
flag day. Until then the declared pins and the visible zero rows suffice.

---

# Appendices

The appendices are reference matter, not a fifth part. [Appendix A][sA]
indexes the semantic contracts an author must know and no check can enforce.
[Appendix B][sB] is the API synopsis. Neither is a second home. Each entry is
normative only where its owning section settles it. [Appendix C][sC] is the
exception. Its diagnostic kind set is made normative here, and acceptance
tests match on it. [Appendix D][sD] is the glossary. It is non-normative, and
the owning section wins wherever the two diverge.

## Appendix A. Taught contracts: the author-facing index

The build pipeline enforces structure. It checks declarations, wiring, types
and conformance. A residue of *semantic* facts remains that no check can
enforce. An author who knows them writes component and periphery code that
comes out right. An author who does not produces defensive delays, duplicated
math or mistimed samples, and no diagnostic fires anywhere. The
IMU's boundary-sampling note ([§8.6][s8-6]) is the archetype. This appendix is an
**index, not a second home**. Each contract gets one recall line here, and its
normative statement stays in the owning section. That applies the
one-home-per-datum rule to the document itself.

For component authors:

- **The stage funnel** ([§5.2][s5-2], [§5.3][s5-3]). The stage name at its tier fixes the
  maximal legal view set. The component's declarations narrow that set to the
  bundle. The signature's destructuring narrows the bundle to the actual
  reads. In short, stage name at its tier ⊇ bundle ⊇ destructured reads. So
  "no `direct` in the name" *is* the no-feedthrough property. The teaching
  line runs as follows. Stage 1 publishes what you know from state alone.
  Stage 2 adds what needs inputs. Your dynamics read your own published
  results instead of recomputing them.
- **One home per datum** ([§5.2][s5-2]). The signal table holds
  *produced* signals only, never transported ones ([§4.3][s4-3]). The buffer holds `x`, the
  `s` and `m` stores hold `s` and `m`, and the table holds signals. No store
  mirrors another.
- **The value-level constructor** ([§8.2][s8-2]). A field-emitting component
  ships the map from (component, input values) to handle as a plain public
  function, and its output stage merely calls it. The condition math
  ([§14.1][s14-1]) must be able to produce the sweep's exact handle outside
  any sweep. Only the component's author can write that function without
  re-creating the drift class.
- **Boundary sampling** ([§10.5][s10-5]/[§10.6][s10-6]; worked example
  [§8.6][s8-6]). "Sampling at `t_k`" means sampling the post-integration,
  post-projection, stage-1-fresh state. A due tick's gated stages run inside
  the boundary sweep and sample the *completed* boundary. An author who
  distrusts that guarantee, with a defensive one-tick delay or a re-derivation
  inside the sampler, silently degrades the model.
- **Interval alignment** ([§14.5][s14-5]). A boundary's `s_update` is the
  *outgoing* transition. At tick `t_k` it consumes the completed boundary's
  samples and produces `s_{k+1}`, the value the component's *next* tick
  decodes. That is the sampled-data `z⁻¹` delay, by construction. Hence
  `s_update` runs at boundary zero. That run is the `t₀` sample's only
  chance.
- **Same-tick reset consumption** ([§5.3][s5-3]), on the *discrete tier*. A
  commanded reset of a discrete component's `s` is an input. For same-tick
  output semantics the *output stage* consumes that input, overriding the
  state-derived path, and `s_update` stores the matching `s⁺`. A reset
  honored only in `s_update` reaches the outputs one tick late, and the
  plant integrates a full step under the stale command. Both spellings are
  legal, and they mean different things. The continuous tier has no such
  choice (next entry).
- **A continuous component's state reset is an event** ([§3.1][s3-1],
  [§10.6][s10-6], [§5.3][s5-3]). Only handlers write `x`. So even a
  *commanded* reset, where the condition arrives as an ordinary `Bool` input
  (weight-on-wheels is the shipped instance), is spelled as an event whose
  guard reads that input. The discrete tier's input spelling does not
  transfer. The reason is semantic, not stylistic. Only the discrete tier's
  update stage is already a jump map, so a reset there is just another value
  for `s⁺`. A continuous state jump, by contrast, must be solver-visible and
  applied *between* integration segments. Every hybrid tool converges on that
  flow/jump split.
  Simulink applies its reset ports through zero-crossing events plus a solver
  restart, and Modelica's `reinit` is syntactically legal only inside a
  `when`. There is no stale-output hazard to manage either. [§10.6][s10-6]
  re-sweeps outputs to quiescence after handlers, so a continuous edge-reset
  is same-boundary by construction.
- **Guard predicates, edges and priors** ([§2.3][s2-3], [§10.6][s10-6]). A
  guard defines a predicate, either as a `Bool` or as a sign value `σ` with
  positive meaning holding. The form chosen *is* the detection policy. A
  `Bool` guard is boundary-detected, a sign guard is localized. Events fire on
  *edges* from not-holding to holding, judged against per-event priors, where
  the prior is the previous boundary's quiescent sample. A predicate that
  keeps holding fires once, at the boundary where it first held. Boundary zero
  sets every prior to not-holding, so a predicate already holding in the
  authored state fires at `t₀`. The opposite crossing direction is a second
  event with the negated guard.
- **Handler-phase visibility** ([§5.3][s5-3], [§10.6][s10-6]). A handler
  executes against exactly the world its guard fired on. Its own `y`, foreign
  `u` and its own `x`/`m` all come from the firing round's sweep. A component
  fires at most one event per round. Its later own events are re-decided
  against the next round's sweep, one round per causal link, within and across
  components alike. Only sweeps write the signal table.
- **Stage totality** ([§9.3][s9-3]; [§13.4][s13-4], [§13.5][s13-5]). Stage
  code is total over type-valid inputs. The probe evaluates every user
  function against values chosen for their types alone. A value-level throw
  is a build failure there and a `StepError` at runtime. Physical plausibility
  is a published stop request. Self-consistency asserts belong in
  tests. Parameter validation belongs at instance construction, not inside a
  stage.
- **Stop-request sampling** ([§13.5][s13-5]). Stop requests are read in
  completed-boundary snapshots. Declare a sign-form (localized) event if the
  stop needs localizing. Every request stops the run unless the advance
  ignores it.

For periphery authors and consumers:

- **Levels, never deltas** ([§11.4][s11-4]). Staged input values are levels
  (`press_count = 17`, never `presses += 1`), which makes them idempotent
  under coalescing. Button edges ride as monotonic counters. Cross-datum
  state such as press counters and edge detection lives in the device struct.
  The loop maintains it, and it arrives *inside* the datum, because
  `map_input` is pure ([§11.6][s11-6]).
- **The device loop idioms** ([§11.6][s11-6], [§12.4][s12-4]). Loop on
  `running(handle)`. Make every blocking call interruptible, through an
  `unblock!` override or timeouts. Voluntary exit is returning. There are
  three canonical shapes. Timer-poll sleeps, polls and stages. Source-driven
  blocks on your socket, and `unblock!` closes it. Boundary-driven calls
  `wait_next_snapshot`, gathers and sends. A forgotten predicate check
  surfaces as `DeviceJoinTimeout` with your device's name. A stall surfaces as
  a stale heartbeat.
- **`shutdown!` closes only what is open** ([§11.6][s11-6], [§12.4][s12-4]).
  The framework runs `shutdown!` on every exit path, including your own
  `init!`'s failure. A throw half-way through acquisition hands the half-built
  device straight back to you. So guard each release (`isopen`, a `nothing`
  handle) rather than assuming initialization completed. You do *not* carry
  the converse burden. `init!` owes no cleanup of its own.
- **Binding traits are declarations, mappings are your own idiom**
  ([§11.6][s11-6], [D-382][d-382]). Keep `is_input`/`is_output`/`is_greedy` trivial, a
  literal or a flag read off a field fixed at the constructor call. The
  framework reads them only during `attach!`, and cross-checks each against
  the enumeration method it implies. `map_input`/`map_output` are a different
  kind of thing. They are conventions of the loop idiom, called only by your
  own `loop` and never by the framework. The names are worth keeping for
  readers, and nothing enforces them.
- **Bad datum vs. bug** ([§11.6][s11-6], [§13.4][s13-4]). Catch what your
  parser can throw, call `report!(handle, MalformedDatum(cause))`, stage
  nothing and continue. Let everything else propagate, and the wrapper makes
  it `DeviceCrash`. Tolerating everything hides bugs as "device attached,
  nothing happens". Tolerating nothing kills a live link on its first
  truncated datagram.
- **Derived liveness** ([§11.7][s11-7]). A widget is live iff its port's feed
  chain terminates in a root input inside the GUI's own claim in the run's
  frozen partition. There is no per-port marking, and unexported ports are
  unpokeable.
- **The two observation sides** ([§11.2][s11-2], [§13.5][s13-5]). A deep
  snapshot path is an *inspection* read. It sees everything and promises
  nothing across builds ([§13.3][s13-3]). An exported output face is an *integration* read. It
  carries curated, writer-independent meaning, and it is the only shield
  against silent semantic drift. Bind faces in anything meant to outlive the
  current build. The store selectors (`get_state`/`get_deriv`) belong to
  neither side. They read live stores, never snapshots (the source rule,
  [§14.4][s14-4]).

---

## Appendix B. API synopsis: the entry points

The user-facing surface on one page, under the same rule as [Appendix A][sA]:
an index, not a second home. Each signature is normative only where its
owning section settles it. Every name here is public by being here, reached
by qualified name or by per-name `import`. The module exports nothing until
the exported-name audit (`pending.md`) fixes the list ([D-226][d-226]). The
author-side declaration surface comes first, then the operator surface by
lifecycle.

**Authoring**, what a component or assembly defines ([§8.2][s8-2],
[§8.5][s8-5]–[§8.7][s8-7]):

- Continuous leaf. `x_init` (by value, mandatory, `(;)` when stateless) and
  `m_init` (by value), `ws_init(::C, ::Type{T})` (by allocation), `u_types` and
  `y_types` (by type, walked, `Pinned{P}` marking a frozen leaf), and
  `state_events`. Its stage and event functions are `y_state`,
  `y_direct` and `x_deriv`, guard/handler pairs
  (`StateEvent(guard, handler)`; the detection policy comes from the guard's
  return type, [§10.4][s10-4]) and `x_projection`.
- Discrete leaf. `s_init` (by value, mandatory, `(;)` when stateless),
  `ws_init(::C, ::Type{T})` (always called at `Float64`) and
  `u_types`/`y_types` (pinned wholesale). Its stages are
  `y_state`, `y_direct` and `s_update`.
- Assembly. `local_wires` (mandatory, the class marker),
  `input_wires`, `output_wires`, `sample_times` and
  `transparent_container` (optional, default `nothing`).
- Any component. `stop_reason` (optional, default `""`), the reason its stop
  requests report ([§13.5][s13-5]).
- Shipped conditions. `condition(::C; kw)`, methods of the framework's
  `condition` generic that return the component's fragment ([§14.2][s14-2]).

Bundle contents by function family (the maximal legal sets, [§5.2][s5-2];
signatures destructure less at will):

| function | tier | bundle fields |
|---|---|---|
| `y_state` | continuous | `x, m, t [, ws]` |
| `y_direct` | continuous | `x, m, u, y_x, t [, ws]` |
| `x_deriv` | continuous | `x, m, y, u, t [, ws]` |
| `y_state` | discrete | `s, t, Δt [, ws]` |
| `y_direct` | discrete | `s, u, y_s, t, Δt [, ws]` |
| `s_update` | discrete | `s, y, u, t, Δt [, ws]` |
| guard / handler | continuous | `x, m, y, u, t [, ws]` |
| `x_projection` | continuous | positional `(comp, x)`, no bundle |

Table footnotes, from the bundle law ([§5.2][s5-2]). The sets above are
maximal, and each field is present only if it exists for the component. `u`
is present iff the function family may see inputs **and** the component
declares `u_types`. `y` is present iff the component declares
`y_types`. `x`/`s`/`m` are present iff
declared non-empty ([D-297][d-297]), and `ws` iff declared. `y_x`/`y_s` are present iff the stage-1 *return* is non-empty
([§5.2][s5-2], [D-285][d-285]). `Δt` is present
on the discrete tier only. Returns follow three rules. A stage returns a
NamedTuple of port values ([§4.3][s4-3], [§5.2][s5-2]). `x_deriv`
returns the layout image of `X` ([§7.1][s7-1]). A **handler returns `(; x, m)`
with each key present iff that store exists and the handler updates it** (the
return law, [§5.2][s5-2]). There is no padding. `x` comes back complete, and
`m` may come back partial.

**Build.**

- `build(world) → Build`. Standalone. It yields the inspectable derived-contract
  artifact, [`Structure`](#g-structure) (the structure step's product, the components, wires,
  faces and tiers), [`Outputs`](#g-outputs) (the nominal evaluation's product, the port classes and the execution order), [`Events`](#g-events) (the nominal evaluation's other product, the event
  names and policies), the activations and `warnings`; the wire list per
  assembly and the root inputs are `Structure`'s, the face table and the
  routes are functions over them, and the execution order is `Outputs`'s
  ([§9.2][s9-2]).
  `build(world; activations = (Float64, ProbeDual))` additionally pins
  activation invariants for CI (`ProbeDual` is the public canonical concrete
  probe scalar, [§9.4][s9-4]), and pre-materializes activations so a parallel
  sweep shares a fully immutable `Build` ([§11.1][s11-1], [§9.4][s9-4]).
- `resolve(assembly, path) → AbstractComponent`. Resolves an immediate child, a
  container element's key segment included. Wiring resolution applies the
  one-level rule ([§6.1][s6-1]). The service walk follows the structure's
  children ([§13.3][s13-3]).
- `input_faces(c)` / `output_faces(c) → Vector{String}`. Declaration-ordered
  face names ([§13.3][s13-3]).
- `input_passthrough(assembly, path; prefix, sep, except, only, select)` /
  `output_passthrough(assembly, path; prefix, sep, except, only, select)`. The
  declaration-site helpers for computed interface connections. `path` names
  an immediate child. `except`, `only` and `select` are exclusive, one per
  call; `select` is a predicate over face names. More than one given is
  `UnknownFaceSelection` with reason `:multiple_selectors`, and a selector
  that keeps nothing warns `EmptyFaceSelection` on the `Build`
  ([§8.8][s8-8]).

**Deployment.**

- `Deployment(build; algorithm = RK4, h, N_base = 1, Δt_base = nothing,
  localization_tol = 1e-6, localization_budget = 8,
  firing_budget = 4) → Deployment`.
  The artifact the grid parameters fix, scalar-free, carrying the
  [`Schedule`](#g-schedule) (the typed per-component `(D, Φ, Δt)` tick table),
  the grid diagnostics and its `warnings` ([§9.2][s9-2]).

  | keyword | default | meaning | owning section |
  |---|---|---|---|
  | `algorithm` | `RK4` | the stepper, selected by type here and materialized against the state buffer at `Model` construction ([D-227][d-227]) | [§10.2][s10-2] |
  | `h` | — | required. A domain rate is not a framework default | [§10.2][s10-2] |
  | `N_base` | `1` | steps per base tick. Absent the `Δt_base` keyword, the `N_base·h` product is the base tick period (the default path). Given it, `N_base` is instead derived and validated an integer ≥ 1 | [§9.2][s9-2] |
  | `Δt_base` | `nothing` | the base tick period as a `Rational`, `Period` or `Hz` value, or `:derive` to request GCD derivation (all-anchored models only); one of three binding sources | [§9.2][s9-2] |
  | `localization_tol` | `1e-6` | the root-finder's relative bracket-width convergence test (`localization_tol · h`) | [§10.4][s10-4] |
  | `localization_budget` | `8` | the per-frame localization allowance | [§10.4][s10-4] |
  | `firing_budget` | `4` | the per-event, per-boundary firing allowance of the event iteration, an integer ≥ 1 | [§10.6][s10-6] |

  `Δt_base` binds from exactly one of three sources ([§9.2][s9-2]). The first
  is the `Δt_base` keyword, a `Rational`, `Period` or `Hz` value; `N_base` is
  then derived and validated an integer ≥ 1. The second is the `N_base·h`
  product when the keyword is absent (the default path). The third,
  requested with `Δt_base = :derive` in a fully anchored model, is derivation
  from the constraint pool at the coarsest admissible value, printed with its
  drivers ([§9.2][s9-2]).

  The [deployment](#g-deployment) (the scalar-free artifact the grid parameters
  fix) binds no stop policy. `t_end` and `ignore_stop_requests` are keywords of each advance
  ([§12.6][s12-6]). A run ends at the first grid boundary
  reaching or exceeding `t_end`, whole frames only ([§12.4][s12-4]). An
  unbounded run stays bounded in memory, since `log_max` keeps such a session
  from growing without limit ([§11.2][s11-2]).

  An event that exhausts `firing_budget` at a boundary loses its further edges
  there, under a `FiringBudget` warning ([§10.6][s10-6]). `localization_tol`,
  `localization_budget` and `firing_budget` are all three
  trajectory-determining like their siblings. So they are validated with them
  (`DeploymentInvalid`) and carried on the `Deployment` the trace header
  records, where replay compares the two deployments as values
  ([§11.5][s11-5], [§12.7][s12-7]).
- `Model(deployment, T = Float64; chunk_size = 16) → Model{T}`. Materializes a
  deployment at a scalar type, allocating the buffers ([§9.2][s9-2], [D-317][d-317]).

  | keyword | default | meaning | owning section |
  |---|---|---|---|
  | `chunk_size` | `16` | the executor's unroll width, a performance knob that never moves the trajectory | [§9.7][s9-7], [§12.6][s12-6] |

- `Model`'s own doors, for a model stepped on its own or used as a service's
  scratch ([§9.2][s9-2], [D-317][d-317], [D-318][d-318], [D-319][d-319]). Each writing door is refused
  on a model a simulation has claimed, as `ArgumentInvalid` with reason
  `:claimed`.

  - `init!(model, condition; t0 = 0.0, hooks = NoHooks())`. The model's door
    into `:consistent`. It checks root-input totality before any write and
    runs boundary zero at `t0`, which settles through the hooks
    ([§14.5][s14-5], [§14.6][s14-6]). A writing door.
  - `frame!(model, k, hooks = NoHooks()) → Bool`. Advances the model through
    frame `k` and settles its frame-top boundary ([§10.4][s10-4]). It returns
    `true` when a hook abandoned the frame's remainder ([§13.5][s13-5]).
    `FrameHooks` is the hooks' contract. `frame_top!(hooks)` runs before the
    frame touches any state, and `settled!(hooks) → Bool` runs at every
    settled boundary. `NoHooks()` is the no-op, and its `settled!` returns
    `false`. A writing door.
  - `port(model, path, name)`, `state(model, path)` and `modes(model, path)`.
    The reads of a port's value, a component's state from whichever home
    owns it, and its modes ([§7.3][s7-3]).
  - `warnings(model) → Vector`. The build's list and the deployment's,
    concatenated ([§9.2][s9-2]).
  - `checkpoint(model) → ModelState`. The model's state alone, legal at
    `:consistent` with the clock on a grid top. Any other status is
    `ServiceLifecycle`, and a clock off the grid is `CheckpointMidFrame`
    ([§12.6][s12-6]).
  - `restore!(model, model_state; hooks = NoHooks())`. Checks the state's
    fingerprint and deployment (`CheckpointMismatch`) and its `t` against
    its grid (`CheckpointMidFrame`) before any write ([§12.6][s12-6]).
    Copies the state back, settles through the hooks and writes
    `:consistent` last. It takes no status gate ([D-319][d-319]). A writing
    door.
  - `trim!(model, problem; baseline, t0 = 0.0, backend) → TrimReport`. The
    trim service on a `Model{Float64}`, committing through the model's
    `init!` ([§14.8][s14-8]). A writing door.
  - `linearize(model, taps; about, t0, width = 8) → Linearization`. The
    query on a `Model{Float64}`, its default operating point
    `checkpoint(model)` ([§14.10][s14-10]).

  `trim!` and `linearize` on a `Model` at another scalar are
  `ArgumentInvalid` with reason `:non_nominal`. The stepping primitives
  `evaluate!`, `integrate!`, `boundary!`, `offtick_boundary!` and
  `boundary_zero!` are framework internals the spec names only as
  mechanisms, outside this API and outside the claim's gate. `apply!` is an
  internal outside this API too, and the claim's gate refuses it on a
  claimed model ([D-318][d-318]).

- `Simulation(model; join_timeout = 5.0) → Simulation`. Runs a
  `Model{Float64}` beside the data plane, the control plane and the run, and
  offers the stopped-sim services. A `Model` at another scalar is a
  `MethodError`, and one already claimed by a simulation or not at `:built`
  is `ArgumentInvalid`, reasons `:claimed` and `:not_built` ([§9.2][s9-2],
  [D-318][d-318]).

  | keyword | default | meaning | owning section |
  |---|---|---|---|
  | `join_timeout` | `5.0` | the shutdown tail's join cap, in seconds of wall clock | [§12.4][s12-4] |

  `join_timeout`, the shutdown tail's join cap, lives on `Control` rather than
  the deployment ([§12.1][s12-1]). It moves no trajectory, so replay neither
  records nor compares it ([§12.4][s12-4]). The four recording keywords are
  `init!`'s, `restore!`'s and `replay!`'s, the doors that build a run (below,
  [D-261][d-261]).
- `Simulation(deployment; kw...)`, `Simulation(build; kw...)` and
  `Simulation(world; kw...)`. The three convenience forms. The first
  materializes a `Model{Float64}` from the deployment and runs it, the second
  composes the `Deployment` constructor with that, and the third calls
  `build` first. They take the `Model` and `Simulation` keywords above, the
  last two the deployment keywords as well ([§9.2][s9-2]).
- `attach!(sim, dev::AbstractDevice, binding::AbstractBinding; should_abort = false)`.
  The roots are mandatory, and the signature is the gate.

  | argument | default | meaning | owning section |
  |---|---|---|---|
  | `dev::AbstractDevice` | — | the device instance; the root type is mandatory | [§11.6][s11-6] |
  | `binding::AbstractBinding` | — | the binding value; the root type is mandatory | [§11.6][s11-6] |
  | `should_abort` | `false` | the per-attachment failure policy. Set, the device's departure also requests a sim stop. Clear, the run continues with the device absent and its claims held to run end | [§11.6][s11-6], [§12.4][s12-4] |

  A departure is the loop body returning, a crash, or a failed `init!`.

  **Sides are declared** by the binding's Bool traits, and each declared side
  carries its own methods:

  | trait / method | default | meaning | owning section |
  |---|---|---|---|
  | `is_input(b)` | `false` on `AbstractBinding` | declares the input side | [§11.6][s11-6] |
  | `is_output(b)` | `false` on `AbstractBinding` | declares the output side | [§11.6][s11-6] |
  | `is_greedy(b)` | `false` on `AbstractBinding` | `true` switches the claim's *source* | [§11.3][s11-3], [§11.6][s11-6] |
  | `claims(b)` / `map_input(datum, b)` | — | the input side. The enumerated face set *is* the claim, what the device may write rather than what it will | [§11.3][s11-3], [§11.4][s11-4] |
  | `reads(b)` / `map_output(nt, b)` | — | the output side | [§14.4][s14-4], [§11.2][s11-2], [§11.6][s11-6] |

  The conformance check runs at attach, pairing each trait against its
  method. A declared side whose `claims`/`reads` was never written reaches
  the error fallback. A method defined under a false trait is detected by
  `which` against the fallback. Both are `BindingContractMismatch`
  ([§11.6][s11-6]). A claim is registered with exclusivity enforced, and the
  staged shape and normalization shim are compiled ([§11.4][s11-4]). The
  `reads` selectors are validated and compiled to one gather
  ([§14.4][s14-4], [§11.2][s11-2]). Under `is_greedy(b) = true` the framework
  computes the unclaimed complement at attach instead of calling `claims`.
  Everything downstream is identical. An empty remainder is legal and
  reported (`EmptyGreedyClaim`), and `is_greedy` without `is_input` is an
  error ([§11.3][s11-3], [§11.6][s11-6]). `TableBinding` is the shipped
  data-driven binding, and the standard GUI binding is the greedy one
  ([§11.6][s11-6]).

  `attach!` is a stopped-sim operation. It is legal in `built`, `initialized`
  and `stopped`. It is an error while `running` and on an `errored`
  simulation (`ServiceLifecycle`; the roster freeze, [§11.3][s11-3], and the
  terminal state, [§13.6][s13-6]). Admission checks identity and claims
  ([§11.3][s11-3]). A second roster entry for one instance is
  `AlreadyAttached`, and rebinding is `detach!` + `attach!`. An overlapping
  claim is `ClaimConflict`. `attach!` registers only. The task appears at the
  next `run!`.
- `detach!(sim, device)`. Removes the roster entry and releases the device's
  claims. Stopped-sim only, like `attach!`. A loop body's voluntary exit or
  crash mid-run does *not* detach. The task dies, and the claims persist to
  run end ([§11.3][s11-3], [§11.6][s11-6], [§12.4][s12-4]).
- The device contract. `MyDevice <: AbstractDevice` plus `init!(dev)` /
  `loop(dev, handle)` / `shutdown!(dev)` and the optional `unblock!(dev)`.
  Around those functions the framework runs a per-run `init!` on the calling task. That
  call is bracketed, so a throw there is `shutdown!` plus `DeviceCrash` by
  name, and the device is dead from the run's first frame top ([§12.4][s12-4]). The
  author-owned task body runs inside the framework's try/catch/finally
  wrapper, and voluntary exit is returning ([§11.6][s11-6], [§12.4][s12-4]).
- The device handle. One type, with capabilities rather than a taxonomy:
  `running`, `latest`, `wait_next_snapshot` ([§12.3][s12-3]), `stage!`,
  `binding`, `gather`, `report!` ([§11.6][s11-6]), and `pending` ([§11.7][s11-7]).
- The panel kit ([§11.7][s11-7]). `port_views(handle)`, the baked table of port
  views; `peek(view, handle, snapshot)`; `incumbent_status(view,
  snapshot)`, with `orphaned` and `stale` on the record it returns.

**Condition algebra** ([§14.1][s14-1]–[§14.6][s14-6]).

- `set(; x, s, m, u)`. The leaf, a fragment: self-vocabulary payloads at
  the authoring level. `u` names faces of that level's contract.
- `at(prefix, node)`. Scoping. It stores, never applies. It also lifts whole
  `TrimProblem`s and linearization tap sets ([§14.9][s14-9],
  [§14.10][s14-10]). An empty prefix is refused ([§14.2][s14-2]).
- `combine(nodes...)`. Symmetric collection. Duplicate leaves error with both
  origins. Blending a node with a bare NamedTuple is a directive error
  method ([§14.2][s14-2]).
- `override(base, patches...)`. Ordered layering. The patch wins, and
  the origin keeps both ([§14.6][s14-6]).
- `condition(comp; kw)`. The shipped condition-method idiom. Aircraft
  baselines (`ready_for_taxi(ac)`, `cold_and_dark(ac)`) are its
  full-coverage instances.

**Stopped-sim services** ([§14][s14]).

- `init!(sim, condition; t0 = 0.0, trace = true, log = true, log_every = 1,
  log_max = 65536)`. `t0` is any real, held as a `Float64`
  origin ([D-260][d-260]). Root-input totality is checked
  pre-write ([§14.6][s14-6]). Then boundary zero runs: project, sweep, events,
  the due `s_update` calls, then the first snapshot, and the checkpoint that
  is the run's trace header ([§11.5][s11-5], [§14.5][s14-5]).

  | keyword | default | meaning | owning section |
  |---|---|---|---|
  | `trace` | `true` | the input trace's plain kill switch | [§11.5][s11-5] |
  | `log` | `true` | the snapshot log's plain kill switch | [§11.2][s11-2] |
  | `log_every` | `1` | the log's keep-every-kth decimation | [§11.2][s11-2] |
  | `log_max` | `65536` | the maximum number of retained snapshots, finite by default with `Inf` the opt-out | [§11.2][s11-2] |

  Recording. The four keywords configure the run this call builds, with its
  log and trace ([§12.6][s12-6], [D-261][d-261]); `restore!` and `replay!`
  take the same four. `log_every` is admissible on the derived artifact
  only, never on the trace ([§11.2][s11-2], [§11.5][s11-5], [D-029][d-029]). When the log fills,
  the retention stride doubles, so the whole run stays covered at coarsening
  density. The run's first and terminal snapshots are retained
  unconditionally and outside the bound ([§11.2][s11-2]). All four are view
  policies, not trajectory-determining. Replay neither records nor compares
  them.
- `trim!(sim, problem; baseline, t0 = 0.0, backend) → TrimReport`. Nonlinear
  least squares on the packed residuals with exact Dual Jacobians, against the
  problem's own `tolerances`. `residuals(reads, d) → NamedTuple` is packed in
  `tolerances`' field order, as decisions pack in `guess`'s. Names pair, and the
  order is the declared side's. The problem itself closes at nine fields
  ([§14.7][s14-7]). Setup and commit both carry the root-input-totality check ([§14.6][s14-6]).
  The commit is `init!` with `override(baseline, condition(solution))`, boundary zero
  anchored at `t0` and the recorders built anew ([§12.6][s12-6]). On a `Model{Float64}`,
  `trim!(model, problem; …)` is the same service, its commit the model's
  `init!` ([D-319][d-319]). `converged` is the service's
  per-residual box test at the backend's returned point. It is
  backend-independent and the commit's gate, and the backend's status and counts
  are recorded diagnostically. The backend seam is a pinned one-method
  signature,
  `solve(backend, eval!, d0, lower, upper, tol) → (; d, status, n_evaluations, n_iterations)`.
  The in-place `eval!(r, J, d)` fills `J` only when it is not `nothing`, the
  packed vectors are in the declared orders, and `status` is an open `Symbol`
  recorded verbatim. Non-convergence reports, never throws ([§14.8][s14-8]).
- `checkpoint(sim) → Checkpoint`. The `Model`'s state at a frame top beside
  the run's two counters, the frame index and the boundary ordinal. The state
  is a `ModelState`, as `checkpoint(model)` reads it, holding the flat
  buffer, the `s` and `m` stores, the whole signal table, the guard priors,
  `t` and `t₀`, the fingerprint and the deployment. Legal in `initialized`
  and `stopped`, refused after a `t*` stop and after an abandoned frame
  (`CheckpointMidFrame`). A checkpoint is not a condition and has no algebra
  ([§14.1][s14-1], [D-274][d-274], [D-319][d-319]).
- `restore!(sim, cp; trace = true, log = true, log_every = 1,
  log_max = 65536)`. A door beside `init!` and `replay!`, legal where `init!`
  is. It checks the checkpoint's fingerprint and deployment
  (`CheckpointMismatch`) and its
  `t` against its grid (`CheckpointMidFrame`). It copies the state back,
  builds a fresh run with the checkpoint as its trace header
  and publishes one snapshot at the checkpoint's `t`. It runs no boundary
  zero, and the boundary ordinal continues. The warm restart is
  `checkpoint` → `restore!` → `run!` ([§12.6][s12-6], [D-274][d-274]).

  `restore!(sim, model_state; kw...)` takes a `ModelState` prepared on a
  standalone model, with the same keywords and the same fingerprint and deployment check. A
  state off the grid is `CheckpointMidFrame`. It opens a fresh trajectory at
  the state's frame, and the restored boundary publishes under ordinal 0
  ([§9.2][s9-2], [§12.6][s12-6], [D-319][d-319]).
- `linearize(sim, taps; about, t0, width = 8) → Linearization`. A pure
  query, seeded Dual passes on scratch, `width` directions per pass. The
  operating point defaults to the checkpoint of the simulation, restored
  with no boundary zero, and `about` with `t0` (default `0.0`) places it
  anywhere else. `t0` is admitted only beside `about`, never silently
  ignored. On a `Model{Float64}`, `linearize(model, taps; …)` is the same
  query, its default point `checkpoint(model)` ([D-319][d-319]).
  `taps(x = (…), u = (…), y = (…))` builds the tap set, three
  labeled selector lists with closed membership (`x`: `get_state`; `u`:
  `get_input`; `y`: `get_output`, `get_face`), every tap a
  [leaf address](#g-leaf-address) resolving to one scalar
  ([§14.4][s14-4], [§14.10][s14-10], [D-272][d-272], [D-276][d-276]).

**Running.**

- `run!(sim; pace = Inf, margin = 0.002, t_end = Inf, ignore_stop_requests = ())`. `run!` blocks until the run ends. Deviceless, it
  is fully synchronous on the calling task. `init!` is required first
  ([§12.6][s12-6]). Paced and unpaced runs are bit-identical ([§10.7][s10-7]).

  | keyword | default | meaning | owning section |
  |---|---|---|---|
  | `pace` | `Inf` | the run's pacing rate; `Inf` is pacer-off, `1` real time | [§10.7][s10-7] |
  | `margin` | `0.002` | the single pacing knob, in seconds | [§10.7][s10-7] |
  | `t_end` | `Inf` | the run's end time, declared for **this advance**, validated per call | [§12.6][s12-6], [§13.5][s13-5] |
  | `ignore_stop_requests` | `()` | the stop requesters **this advance** does not honour: `:all`, or their component paths, validated against the `Build`'s requester roster per call | [§13.5][s13-5] |

  `pace` defaults to `Inf`, pacer-off. A deviceless run is the harness and
  CI mode, and real time is `pace = 1` away ([D-269][d-269]). `margin` defaults to 2
  ms, the sleep primitive's granularity plus its measured overshoot. The
  values `0`, 2 ms and `∞` span the design space ([§10.7][s10-7]). Each
  advance builds a [`StopPolicy`](#g-stop-policy) (the
  immutable `t_end`-plus-ignored-requesters value an advance declares) from its
  `t_end` and `ignore_stop_requests`. It passes that policy to the loop, and the value
  lives as long as the call. The termination record carries the policy that
  ended the run, and nothing else keeps one ([§12.6][s12-6], [§13.5][s13-5], [D-260][d-260]). `t_end = Inf` with no honoured
  stop request is an unbounded run, allowed, with `UnboundedRun` raised into the
  loop's diagnostic cell ([§11.8][s11-8]).
- `step!(sim; frames = 1, t_end = Inf, ignore_stop_requests = ()) → frames_advanced`. A
  synchronous partial advance through the ordinary frame sequence,
  bit-identical to the same frames under `run!`. It never waits ([D-269][d-269]).
  `t_plus = <duration>` is the
  mutually exclusive duration spelling
  (whole frames until the boundary time covers that duration). It returns the
  frames *actually* advanced, fewer than requested when `t_end` or a
  stop request ended the run inside the call. Between calls the simulation
  reports `initialized`. `run!` may follow, and it continues from the current
  boundary. A stepping session is deviceless. Write via `stage!` and read via
  `latest` ([§12.6][s12-6]).
- `stage!(sim, "face" => value, …)`. Staging from any task, the calling
  task included, into the harness writer ([§11.3][s11-3]). Its surface is the currently
  unclaimed faces. The batch is traced, drained last at the next frame top,
  and surface-checked exactly as any device's (the harness cell,
  [§11.3][s11-3]). It is legal under `run!` and `step!` alike
  ([§12.6][s12-6]).
- `latest(sim) → snapshot`. The current published snapshot, the same
  immutable value device handles read ([§11.2][s11-2]). It is the assertion
  and inspection accessor of the harness and REPL modes ([§12.6][s12-6]).
- `phase_bodies(sim) → named callables`. The compiled phase bodies of the
  nominal activation, bound over the simulation's own buffers. They are the
  four blocks (`rhs`, `sweep_1`, `sweep_2`, `ticks`), with the sweeps in both
  arities, zero-arg interior and tick-indexed boundary, and `ticks` taking
  the tick index. Per-event guards/handlers and per-component
  `x_projection` come with them, keyed by the model's roster. This is the
  [§9.8][s9-8] allocation seam. Warm, then `@ballocated(body()) == 0` per
  body. It is an inspection-only surface, and its one promise is identity with
  what the loop runs. An isolated invocation leaves buffers valid but
  off-trajectory. Re-run `init!` to continue ([§9.7][s9-7]).
- Control plane. Pause/un-pause, pace and `margin` changes, and stop all
  sit on a separate atomic surface, never staged ([§12.1][s12-1]). Pacing sits
  outside the semantics, so pace and `margin` are both safe to change live.
  `pause!(sim)`, `resume!(sim)` and `stop!(sim)` are the calling code's
  spellings and `paused(sim)` the read; `pace!(sim, p)` and
  `margin!(sim, m)` set the two knobs and `pace(sim)` and `margin(sim)` read
  them ([D-269][d-269]); a device stops through `stop!(handle)` ([§11.6][s11-6]). The
  tail clears the pause, never a run's start ([D-268][d-268]).
- Termination. The model's state ends a run via stop requests, `StopFlag`
  ports read at every published boundary unless the advance ignores them
  ([§13.5][s13-5]). Shutdown completes a boundary,
  publishes the final snapshot, then joins ([§12.4][s12-4]).
- Post-run. The log is the retained snapshots. `series(sim, read_set) →
  ts` gathers them into labeled columns through the read-selector
  family, one typed vector per entry beside `t`, frame and boundary
  ([§11.2][s11-2], [D-407][d-407]). `trace(sim) → trc` retrieves
  the always-on input trace.
  `replay!(sim2, trc; to_boundary = k, pace = Inf, margin = 0.002,
  t_end = Inf, ignore_stop_requests = (), restore = true)`, taking `init!`'s four
  recording keywords as well ([D-261][d-261]), re-drives
  a fresh `Simulation(world)` bit-identically through the ordinary loop. It
  restores the trace's checkpoint and feeds the drain by frame ordinal from
  the frame after the header's; `restore = false` feeds the simulation as it
  stands. A halt names a frame from the one the feed starts from through the
  recording's last. It ends
  `initialized`. `to_time = t` is the mutually exclusive time spelling
  of the halt, floored to the last frame top at or before `t`. Inspect via
  `latest` or the live stores, advance via `step!`, continue via `run!`.
  Replay is the state-trajectory inspector and the `StepError` reproduction
  tool ([§11.2][s11-2], [§11.5][s11-5], [§12.7][s12-7]; on-disk persistence
  is deferred, `pending.md`).
- `warnings(x) → Vector`. The artifact's warning list, on `Build` and
  `Deployment`, and on `Simulation` as the concatenation of its artifacts'
  lists ([§9.2][s9-2], [§13.2][s13-2]).
- `closed(run) → Bool`. True once the loop's tail has written the run's
  termination record ([§12.6][s12-6]).
- `mode(sim) → :live | :replay`. The input mode, read beside the lifecycle
  state. It says where the next frame's drain takes its batches from, the
  staging cells or an attached `replay!` recording ([§12.6][s12-6],
  [§12.7][s12-7]).
- `live!(sim)`. Detaches the remainder of an attached recording and sets the
  mode to `:live`, touching neither the trajectory nor the trace. The next
  `run!` or `step!` then continues live from the replayed boundary and
  re-records onto the replayed prefix. Stopped-sim only. It is legal on an
  `initialized` simulation in `:replay`, and an already live one refuses
  ([§12.6][s12-6], [§12.7][s12-7]).

---

## Appendix C. The diagnostic kind set

The kinds below are the closed set [D-058][d-058] commits to, made normative.
**Tests match on kind plus payload fields, never on message text**
([§13.2][s13-2]). So the entries below, not any message, are the
acceptance-test contract. Adding a kind is a decision-log entry. Every
entry's payload is *in addition to* what [§13.2][s13-2] requires of all
diagnostics: paths and names as strings, never instances; the list-in-hand
wherever a did-you-mean renders; the didactic style (state the fix).
Owning sections stay the normative home of each rule. This appendix is an
index of the values, in the manner of Appendices A and B.

Each entry names the kind, then its owning sections in parentheses, then
severity · raised · policy, then the payload. Three fields place each kind.
**Severity** is a property of the kind, read as `severity(d)`
([§13.2][s13-2]), and takes one of two values:

- **error**. An occurrence throws, alone or within a collection. A step
  that produced one throws before the next begins ([§13.1][s13-1]).
- **warning**. An occurrence never throws and joins no throw. It renders
  with a collection, is logged beside a returned value, or rides the runtime
  stream, according to where and how it is raised.

**Raised** and **policy** describe the occurrence, not the kind: where it
surfaces, and how it is reported. A kind raised at two stages lists both
(`BundleFieldError` is raised at the probe, and as a `StepError`
[species](#g-species) thereafter). The placement notes stay in the raised
field beside the stage they qualify. The stages are the ones [§13.2][s13-2]
names:

- **build**. During one of the build's three steps ([§9.1][s9-1]), whether in a
  declarative pass or while *user code* runs (a declaration body, a probe, an
  activation's continuous-tier function).
- **service**. In a stopped-sim service, or in
  `attach!`/`Deployment`/`Simulation`/`run!` validating against the `Build`.
- **runtime**. During a boundary.

The policies:

- **collected**. Gathered with its siblings and thrown as one carrier. A
  declarative pass's violations are the `DiagnosticError` of the step
  barrier, and every pass that ran under [§13.1][s13-1]'s dependency rule
  merges into the one throw ([D-229][d-229]). A service's violations are
  collected wherever the owning section says so (the condition algebra,
  [§14.1][s14-1]; the pre-write check, [§14.6][s14-6]).
- **fail-fast**. The first occurrence throws on its own, and nothing else is
  gathered. At build the first user-code failure aborts the phase
  ([§13.1][s13-1]). At a service call the first violation is the throw. At
  runtime it reaches the single catch site ([§13.4][s13-4]) as a species of
  `StepError`.
- **logged**. A warning from an artifact-producing call that *completed*, the
  build and the `Deployment` constructor included ([D-250][d-250]). The
  warning lives on the artifact the call returns, and the entry point logs it
  once at return through the standard logging backend. It is part of no
  collection. There is no rate limit. A warning about the artifact itself
  fires at most once per call, and its payload is drawn from the artifact the
  call returns ([§9.2][s9-2], [§13.2][s13-2], [§14.8][s14-8]). A warning
  raised at a call site inside the call, `EmptyFaceSelection` in a
  passthrough helper ([§8.8][s8-8]), fires once per raising site and carries
  that site's payload, so one artifact may hold several of one kind.
- **rate-limited**. The per-occurrence runtime warning stream of
  [§13.2][s13-2], carried by the per-writer diagnostic cells ([§11.8][s11-8])
  and bounded by them. Every kind reported this way is bounded per writer
  per boundary (a ring of sixteen retained values, the excess becoming
  per-kind suppressed counts). The per-entry qualifiers record where that
  bound matters (a source that can repeat within a frame) and where
  the source itself fires once. A kind carried this way names its subjects
  in the payload, never its writer. The cell attributes the writer, and the
  status record's `who` and the tail residue carry that attribution
  ([D-228][d-228]). `DeviceJoinTimeout`'s device id is a subject, the
  abandoned device, written by the loop.

The *collected*-warning slot, the warning-severity kinds that would render
with a step's throw, is empty ([D-084][d-084]). Build warnings themselves
live on the `Build`, and a step that throws renders its warnings with the
collection ([§9.2][s9-2], [D-250][d-250]).

**Declaration and wiring** (the structure step):

- **`UnknownPort`** ([§6.1][s6-1], [§8.4][s8-4] w1, [§9.1][s9-1], [D-113][d-113]). Error ·
  build · collected. The wire end (`source`/`destination`, or `connection` for an
  interface-connection entry's internal side, [D-210][d-210]), that end's
  path, the unknown port name, that end's port list (did-you-mean).
- **`UnconnectedInput`** ([§6.1][s6-1], [§8.4][s8-4] w2, [§9.1][s9-1]). Error · build ·
  collected. Leaf path, input name, declared entry type, the faces
  `input_wires` entries handed it up through, innermost first, the last being
  the outermost face nobody wired.
- **`TwoProducers`** ([§6.1][s6-1], [§8.8][s8-8], [§9.1][s9-1]). Error · build · collected.
  Destination terminal, both producers with their declarations (sibling wire
  / interface connection entry), each a terminal or the face an entry hands
  the input up through.
- **`WireTypeMismatch`** ([§6.1][s6-1], [§8.2][s8-2], [§8.4][s8-4] w4). Error
  · build · collected. Both endpoint paths, both face names, declared entry
  type, producer face type.
- **`WalkingFaceAtFrozenEntry`** ([§6.1][s6-1], [§8.2][s8-2]). Error · build ·
  collected. Consumer path and entry name, producer path and face name, the
  offending leaf, both declared leaf types; both remedies in the message
  ("remove the entry's `Pinned` if the consumer promotes; feed it from a
  non-walking source if the freeze is genuine").
- **`PathResolution`** ([§6.1][s6-1], [§13.3][s13-3]). Error · build, or
  service resolving a service path · collected. Path, offending segment,
  sibling field list. For a wiring endpoint reaching past the immediate
  child, the level it stopped at.
- **`AbstractAtRoot`** ([§8.2][s8-2]). Error · build · collected. Face name,
  consuming leaf path, the abstract entry; a remedy hint (wire a concrete
  producer, or in a rig a stub child, [§13.7][s13-7]).
- **`RootInputTypeConflict`** ([§8.2][s8-2]). Error · build · collected. Face
  name, the consuming paths, their conflicting concrete declarations at
  nominal. A tolerance difference is not a conflict (the meet,
  [§8.2][s8-2]).
- **`StoreNotNamedTuple`** ([§8.2][s8-2], [§9.1][s9-1], [D-247][d-247]).
  Error · build · collected. Component path, the store
  (`x_init`/`s_init`/`m_init`), the observed type; the message spells the
  wrap.
- **`IllegalStateLeaf`** ([§7.1][s7-1], [§8.2][s8-2], [§9.1][s9-1]). Error · build ·
  collected. Component path, `x_init` field name, leaf type, the closed
  vocabulary (scalar / `SArray` at the common eltype).
- **`StoreWithoutUpdate`** ([§8.2][s8-2]). Error · build · collected.
  Component path, the `x_init` or `s_init` store, the missing update (no
  `x_deriv` for the one, no `s_update` for the other). A
  non-empty store only; an empty store owes no update ([D-263][d-263]).
- **`EventHalfMissing`** ([§8.2][s8-2]). Error · build · collected. Component
  path, event name, reason (guard half missing / handler half missing / the
  entry is not a `StateEvent`), the function that has no method or the
  entry's type.
- **`DeclarationShadowed`** ([§8.1][s8-1], [D-246][d-246]). Error · build ·
  fail-fast. Component path, the parent module, the family names the module
  binds to something other than the framework's function. The message spells
  the import line from them.
- **`ClassUnreadable`** ([§8.5][s8-5]). Error · build · fail-fast. Component
  path, type, declarations found, both family lists; did-you-mean when the
  type holds component-typed fields.
- **`ClassMixed`** ([§8.5][s8-5]). Error · build · fail-fast. Component path,
  the `local_wires` declaration and the offending leaf declarations.
- **`ContainerMixed`** ([§8.5][s8-5]). Error · build · fail-fast. Container
  field path, offending element keys/indices, their types.
- **`ContainerNested`** ([§8.5][s8-5]). Error · build · fail-fast. Container
  field path, the element keys/indices that are themselves component-bearing
  containers, their types.
- **`DeclarationOnWrongTier`** ([§5.3][s5-3], [§8.2][s8-2], [§8.5][s8-5]).
  Error · build · collected. Component path, the offending declaration, the
  tier the leaf's other declarations announce. The offending declaration is
  `x_deriv`/`s_update`, a store from the wrong family (`x_init`
  against `s_init`, [D-195][d-195]), `state_events`, `m_init`,
  `x_projection`, or a `Pinned` entry on a discrete leaf, named with its
  contract ([D-263][d-263]).
- **`FaceNameIllegal`** ([§8.6][s8-6]). Error · build · collected. Assembly
  path, face name, the violated invariant (contains `/`).
- **`FaceNameCollision`** ([§8.6][s8-6]). Error · build · collected. Assembly
  path, the colliding face names. No per-entry declaration: a computed entry
  collides like a hand-written one ([§8.8][s8-8], [D-249][d-249]).
- **`FaceDirectionConflict`** ([§8.6][s8-6]). Error · build · collected.
  Assembly path, the declaring method, the offending entry, the resolved
  port's actual direction.
- **`UnknownFaceSelection`** ([§8.8][s8-8]). Error · build · fail-fast. Child
  path, reason (unknown names / more than one selector given), the
  offending names or the selectors given, the child's face list.
- **`EmptyFaceSelection`** ([§8.8][s8-8]). Warning · build · logged, on the
  `Build`'s warnings. The helper, the child path, the selector given and its
  names, the child's face list. A selector was given and nothing survived it;
  a bare call over a faceless child raises nothing.
- **`RatesViolation`** ([§10.5][s10-5], [§8.7][s8-7]). Error · build ·
  collected. Assembly path, offending key, reason (deep key / unknown child /
  `K` on a continuous child).
- **`MissingProbeValue`** ([§9.3][s9-3]). Error · build · collected. Face
  name, type.
- **`ChildNameCollision`** ([§8.5][s8-5]). Error · build · fail-fast.
  Assembly path, the colliding child name, reason (a bare container key
  against the `sample_times` sugar, [D-211][d-211] / against a sibling field,
  [D-212][d-212] / two children with one name), both declarations.
- **`TransparentContainerUnknown`** ([§8.5][s8-5], [D-211][d-211]). Error ·
  build · fail-fast. Assembly path, the field `transparent_container` names,
  the type's container fields (the list-in-hand).
- **`TierUnreadable`** ([§8.2][s8-2]). Error · build ·
  collected. Component path, type, the leaf declarations found. A primitive
  declaring neither `x_init` nor `s_init`; the message spells the empty form a
  stateless leaf writes ([D-263][d-263]).
- **`StatelessWithoutOutputs`** ([§8.2][s8-2], [§8.3][s8-3]). Error · build ·
  collected. Component path, type, the declarations found (no `y_types`,
  an empty store). A leaf that produces nothing and stores nothing ([D-263][d-263]).
- **`IllegalPortType`** ([§4.3][s4-3], [§8.2][s8-2]). Error · build ·
  collected. Component path, the declaration at fault
  (`u_types`/`y_types`, or a root input), port name, the offending
  type (one with no leaves, a mutable one, an opaque leaf at a root input,
  or a `Pinned` marker below the top of the entry, [D-265][d-265]), the leaf
  vocabulary ([§4.3][s4-3]). Two reasons concern stop requests
  ([§13.5][s13-5], [D-316][d-316]): `:stop_flag_nested`, a `StopFlag` leaf inside a
  port whose type is not `StopFlag` itself, and `:stop_flag_at_root`, a root
  input whose type carries a `StopFlag` anywhere.
- **`IllegalStoreField`** ([§7.3][s7-3], [§8.2][s8-2], [§9.1][s9-1]). Error ·
  build · collected. Component path, the store at fault (`s_init`/`m_init`),
  field name, the offending type (one neither isbits nor `Symbol`), the fix
  (text and bulk data belong on the component instance).

**Execution order and contract conformance** (the nominal evaluation and
activation):

- **`AlgebraicCycle`** ([§5.5][s5-5], [§13.8][s13-8]). Error · build ·
  collected. The SCC's members, the wires among them as terminal pairs in
  slash form, optional classification (`real`/`artificial`) with every dead
  hop (member, input face, output port), and per member the tracing mode
  (global, sampled or structural).
- **`ProducedByTwoStages`** ([§8.3][s8-3]). Error · build ·
  fail-fast, with the probe chain ([D-229][d-229]). Component path, port
  name. The two stages are the kind's own, so it carries no producer column
  ([D-252][d-252]).
- **`DeclaredNotProduced`** ([§8.3][s8-3]). Error · build · collected, by the
  completeness pass over the complete products, which runs only once every
  port check has passed ([D-239][d-239]). Component path, declared name, the
  stage-product list and the state-field list, the latter as context. The
  remedy is returning the name from `y_state` ([§5.3][s5-3],
  [D-252][d-252]).
- **`UndeclaredReturnField`** ([§8.3][s8-3], [§8.4][s8-4] w5). Error · build
  · fail-fast, alone. It stops the probe chain before the completeness pass
  ([D-239][d-239]). Component path, stage, returned field name, candidates
  (`y_types`).
- **`DeadStage`** ([§5.2][s5-2], [§9.3][s9-3]). Error · build, at probe ·
  fail-fast. Component path, stage. The stage method returned bare `(;)`,
  producing no ports.
- **`ConformanceFailure`** ([§9.5][s9-5]). Error · build, at probe; runtime
  thereafter · fail-fast, a `StepError` species at runtime. Component path,
  function, the event name on a handler's occurrence, field-level diff
  (missing / unexpected / per-field expected-vs-observed, order-insensitive,
  fields pairing by name). Simulation time rides the runtime carrier ([D-249][d-249]).
- **`GuardForm`** ([§9.5][s9-5]). Error · build · fail-fast. Component path,
  event name, observed probe return type, both admissible forms.
- **`BundleFieldError`** ([§5.2][s5-2], [§13.2][s13-2]). Error · build, at
  probe; runtime thereafter · fail-fast, a `StepError` species at runtime.
  Component path, function family, requested field, the legal field set,
  classification (undeclared store / wrong-tier fact / illegal for this
  function family).
- **`HandlerReturnKey`** ([§5.2][s5-2], [§9.5][s9-5]). Error · build ·
  fail-fast. Component path, event name, offending key, the legal set
  `{x, m}` narrowed to the stores that exist.
- **`UserCodeFraming`** ([§13.2][s13-2]). Error · build · fail-fast.
  Component path, which function, the bundle's field names, the synthesized
  inputs as a spelling, the original exception as `cause`. Every
  user-authored method the build invokes is framed, declarations included
  ([D-248][d-248]).

**Deployment, periphery and services:**

- **`MissingInit`** ([§12.6][s12-6], [§12.7][s12-7]). Error · service ·
  fail-fast. The simulation's status, the entry point called
  (`run!`/`step!`/`replay!`/`live!`).
- **`ServiceLifecycle`** ([§11.3][s11-3], [§12.7][s12-7], [§14][s14]). Error ·
  service · fail-fast. The operation
  (`attach!`/`detach!`/`init!`/`restore!`/`trim!`/`checkpoint`/`linearize`/`live!`),
  the current status, the legal statuses.
- **`StopRequestInvalid`** ([§13.5][s13-5]). Error · service · collected,
  over the given paths. The path naming no requester, the binding site
  (`run!`, `replay!` or `step!`), and the roster's requester paths as
  candidates, in roster order.
- **`DeploymentInvalid`** ([§9.2][s9-2]). Error · service · collected. The
  deployment parameter, the value in hand, the violated constraint. The
  parameter is one of `h`, `N_base`, `Δt_base`, algorithm,
  `localization_tol`, `localization_budget`, `firing_budget`, the
  harmonic-grid relation, or a non-dividing anchor period or offset (the
  anchor named with its declaring scope and key). The `Model` and
  `Simulation` constructors' keywords validate under `ArgumentInvalid`
  ([Appendix B][sB]).
- **`AttachUnknownFace`** ([§11.3][s11-3]). Error · service · fail-fast. The
  device (by type, since its roster id is assigned only at admission),
  binding entry, face name, the root input-face list.
- **`AlreadyAttached`** ([§11.3][s11-3]). Error · service · fail-fast. The
  device id of the existing roster entry, its binding.
- **`ClaimConflict`** ([§11.3][s11-3]). Error · service · collected, over the
  device's claim set. Face name, claiming device id, incumbent device id.
- **`EmptyGreedyClaim`** ([§11.3][s11-3], [§11.6][s11-6]). Warning · service ·
  rate-limited, in the roster entry's diagnostic cell ([D-250][d-250]). The
  greedy device's id and its binding. The computed complement was
  empty, every root-input face being claimed already.
- **`BindingContractMismatch`** ([§11.6][s11-6]). Error · service ·
  fail-fast. The binding type, the trait and the method at fault, and the
  direction. The direction is either a declared side whose enumeration
  method is missing (`is_input`/`is_output` true, the root's error fallback
  reached), or a `claims`/`reads` method defined under a false trait
  (detected by `which` against the fallback). `is_greedy` without
  `is_input`, `claims` defined on a greedy binding, and a binding declaring
  neither side report here too.
- **`DeviceContractMismatch`** ([§11.6][s11-6]). Error · service · fail-fast.
  The device, and what the contract lacks: the `loop` method, the output
  side `gather` needs from a binding that declares none, or the roster entry
  a detached handle's `stage!`/`report!` no longer has ([D-244][d-244]). The device
  twin of `BindingContractMismatch`.
- **`ConditionResolution`** ([§14.2][s14-2], [§14.3][s14-3]). Error · service
  · collected. Entry path, store and field (or the root-input face the entry
  addresses), offending value type and declared leaf type, the leaf's tier
  and role where the refusal is tier-bound, the producer where a face is
  fed, candidates where a list is in hand, the origin. The origin is the
  condition tree's chain, or the checkpoint where `linearize`'s default
  operating point supplies a root input's value ([§14.10][s14-10]). Its
  sub-kinds are assembly path, undeclared field, unconvertible value and
  unexported root-input face. An unknown path is `PathResolution`'s
  ([§13.3][s13-3]).
- **`DuplicateConditionLeaf`** ([§14.2][s14-2]). Error · service ·
  collected. The leaf `(path, store, field)`, both origins, the
  `override` advice.
- **`ConditionNodeMisuse`** ([§14.2][s14-2]). Error · service · fail-fast.
  The offending argument's type, the node kinds in hand. Or an empty prefix
  handed to `at`.
- **`ReadResolution`** ([§14.4][s14-4]). Error · service · collected. The
  read's label and the selector as authored, the mount path, path and field,
  the leaf address and the offending step, candidates where a list is in
  hand, the producer for an internally wired face, and a `reason`
  distinguishing an assembly path, an undeclared name, a face miss, a step
  the leaf address cannot take, and a store selector under a table source
  (the source rule, [§14.4][s14-4]). Raised at trim, at linearization and at
  attach, where the label names the read and the `attach!` call names the
  device ([D-406][d-406]).
- **`UninitializedInputs`** ([§14.6][s14-6]). Error · service, pre-write ·
  collected. Every uncovered root face, in declaration order.
- **`TapResolution`** ([§14.10][s14-10]). Error · service · collected. The
  tap set's own refusals, raised beside the reads' `ReadResolution` values:
  the tap set (`x`/`u`/`y`), the list a selector sat in, a discrete store, a
  vector leaf, a duplicate site, and a declaredly unseedable root input with
  the pinning consumer's path and its `u_types` entry.
- **`TrimProblemInvalid`** ([§14.7][s14-7], [§14.8][s14-8]). Error · service
  · collected. The offending `TrimProblem` field, the names or types in hand
  (a key-set or field-type mismatch; never a field-order difference).
- **`TrimCommitEvents`** ([§14.8][s14-8]). Warning · service · logged. The
  events fired at boundary zero, as component paths and event names. The
  same list rides the `TrimReport`.
- **`TrimCommitResiduals`** ([§14.8][s14-8]). Warning · service · logged. The
  offending residual names with committed-state values and tolerances. A
  converged solve whose committed-state residuals violate the box test.
- **`TrimCommitChecks`** ([§14.8][s14-8]). Warning · service · logged. The offending
  check names with committed-state values and tolerances. A converged solve
  whose committed-state checks leave their tolerances.
- **`ConditionShapeDrift`** ([§14.4][s14-4]). Error · service · fail-fast.
  The compiled tree type and the observed one; for a prefix mismatch, the
  node position and both strings; the remedy, which is that a condition
  function returns one shape for every decision.
- **`GridUtilization`** ([§9.2][s9-2]). Warning · service, at
  the `Deployment` constructor (derivation path only) · logged, on the
  deployment's warnings ([D-254][d-254]). The derived `Δt_base`, the grid
  attribution (the pool with each entry's anchor and refinement factor,
  the coarsest admissible `Δt_base`, the prime attribution) and `min_i Dᵢ`,
  the grid rendered as "N× finer than the fastest declared work".
- **`CheckpointMismatch`** ([§12.6][s12-6], [§12.7][s12-7]).
  Error · service · collected. One kind for the replay entry pass and for
  `restore!`, raised when a checkpoint's fingerprint or deployment disagrees
  with the target simulation or model. The mismatch, discriminated. It is a store or root
  input (component path, store, expected vs. found layout/type), a
  component's `x` type, a cell's address or type, the event list, a recorded
  root-input value that does not convert to its declared type, the scalar
  type (the
  recorded one vs. the target model's), a deployment parameter
  (`Δt_base`/`h`/`N_base`/algorithm/`localization_tol`/`localization_budget`/`firing_budget`,
  recorded vs. bound value), a [schedule](#g-schedule) row whose column
  differs (the component path, the column, recorded vs. bound value), a rate
  scope whose column differs (its path, the column, recorded vs. bound
  value), a schedule whose row list, scope list or per-component vector
  differs (the name, the two lists), a frame ordinal outside the
  recording's frames (the writer, the ordinal, the legal range), or, under
  `restore = false`, the simulation's origin or frame index off the
  recording's (the one that differs, the clock's `t₀` or the run's frame, the
  recording's value or legal range, the simulation's).
- **`CheckpointMidFrame`** ([§12.6][s12-6], [§14][s14]). Error · service ·
  fail-fast, but collected with `CheckpointMismatch` on `restore!`.
  `checkpoint` on a simulation or a model that is not at the rest a frame
  top leaves. Either the clock is past a frame top after a `t*` stop, or a
  simulation's frame was abandoned unpublished ([§12.4][s12-4]). `restore!`
  raises it too, on any of its forms, for a state whose `t` is off the grid
  ([§12.6][s12-6]). The clock's or the state's `t`, the frame top `t_frame`,
  the frame index `frame`.
- **`ReplaySchemaMismatch`** ([§12.7][s12-7]). Error ·
  service · collected. The trace's device tag, its recorded face-name →
  position schema, the disagreeing face names, the target's root input-face
  list.
- **`ReplayUnknownFace`** ([§12.7][s12-7]). Error · service · collected. Face
  name, or the bare position where the writer's schema has no name for it;
  frame ordinal, the trace's device tag, the root input-face list.
- **`ArgumentInvalid`** ([§10.5][s10-5], [§11.6][s11-6], [§12.1][s12-1], [§12.4][s12-4],
  [§12.6][s12-6], [§12.7][s12-7], [§13.5][s13-5], [§14.8][s14-8], [§14.10][s14-10]). Error · service, or build in a `sample_times`
  declaration · fail-fast, but collected over a `TableBinding`'s entry table
  and over the `Model` and `Simulation` constructors' keywords and the claim
  on the model ([D-318][d-318]). The call
  (`Model`, `Simulation`, `init!`, `frame!`, `apply!`, `restore!`, `run!`,
  `step!`, `replay!`, `live!`, `pace!`, `margin!`, `trim!`, `linearize`, `TableBinding`,
  a period constructor), the argument, the value in hand, the violated
  constraint. `trim!` and `linearize` on a `Model` at another scalar raise it
  with reason `:non_nominal` ([D-319][d-319]). `Model` at a scalar other than
  `Float64` or a `ForwardDiff.Dual` raises it with reason `:scalar` ([D-320][d-320]).
  The twin of `DeploymentInvalid` for arguments that are not deployment
  parameters.
- **`ReadSetMisuse`** ([§14.9][s14-9]). Error · service · fail-fast. The
  offending argument's type, the selector kinds in hand. Or an empty prefix
  handed to `at` on a read set ([§14.9][s14-9]). The read side's twin of
  `ConditionNodeMisuse`.
- **`NotAttached`** ([§11.3][s11-3]). Error · service · fail-fast. The device
  id or handle offered to `detach!`, the roster's device ids.

**Runtime:**

- **`StepError`** ([§13.4][s13-4]). Error · runtime · fail-fast. The carrier.
  Cursor frame (the component by its component-list index, the function, and
  the boundary phase: the frame-top drain, an integration stage, the arrival
  sweep, the θ = 0 validation, a localization trial, projection, an event
  round or the ticks), the clock at the failure, frame-entry boundary index (the replay pointer), the host of
  the catch (`:loop` or `:boundary_zero`), and the `cause`, a species'
  diagnostic or the original exception, its type the parameter.
- **`NonfiniteState`** ([§13.4][s13-4]). Error · runtime · fail-fast.
  Component path, the offending state leaf and its value, the frame-top time
  and the frame-entry boundary index.
- **`ChatteringBudget`** ([§10.4][s10-4]). Warning · runtime · rate-limited.
  Component path, event name, boundary time, the exhausted
  `localization_budget` and the frame's localization count.
- **`FiringBudget`** ([§10.6][s10-6]). Warning · runtime · rate-limited.
  Component path, event name, boundary time, the exhausted `firing_budget`
  and the boundary's firing count.
- **`DebtReanchor`** ([§10.7][s10-7]). Warning · runtime · rate-limited.
  Forgiven debt in seconds, and the new anchor's `t` (the boundary time)
  and `τ`.
- **`ClaimedFaceEntry`** ([§11.3][s11-3], [§11.4][s11-4]). Warning · runtime
  · rate-limited. Face name, the incumbent (claiming) device id, the
  discarded value, the site (staging, or a stopped-sim attach's
  renormalization). Harness writer only. A device's out-of-surface entry
  is `OutOfClaimEntry`.
- **`OutOfClaimEntry`** ([§11.3][s11-3]). Warning · runtime · rate-limited.
  Face name, the discarded value, the device's claim set, and the incumbent's
  device id when the face is claimed elsewhere.
- **`ThreadBudget`** ([§12.2][s12-2]). Warning · runtime, at `run!` or
  `replay!` · rate-limited. Thread count, device-task count.
- **`DeviceJoinTimeout`** ([§12.4][s12-4]). Warning · runtime, at the
  shutdown tail · rate-limited. It is written to the loop's cell, collected
  by the run's-end sweep into the termination record and presented through
  the logging backend, past the terminal snapshot ([D-201][d-201],
  [D-203][d-203]). Device id, the join timeout, boundary time and index at
  shutdown.
- **`DeviceCrash`** ([§12.4][s12-4], [§11.6][s11-6], [§13.4][s13-4]). Warning
  · runtime · rate-limited. The original exception as `cause`, whether
  `should_abort` was set. Also the init-time failure, reported pre-spawn from
  the initialization bracket after its `shutdown!`.
- **`ReplayDiscardedStaging`** ([§12.7][s12-7]). Warning · runtime ·
  rate-limited, a repeating source ([§11.8][s11-8]). The discarded batch's
  face names, frame ordinal.
- **`MalformedDatum`** ([§11.6][s11-6], [§13.4][s13-4]). Warning · runtime ·
  rate-limited, a repeating source ([§11.8][s11-8]). The cause exception.
  Emitted by the author's loop body via `report!(handle, …)`.
- **`EntryTypeMismatch`** ([§11.4][s11-4]). Warning · runtime · rate-limited.
  Face name, the offending value's type, the root input's declared type, the
  discarded value.
- **`UnboundedRun`** ([§11.8][s11-8], [§13.5][s13-5]). Warning · runtime,
  raised at `run!` in `:live` when `t_end` is `Inf` and no stop request is
  honoured, the model having no requester or the advance ignoring them all
  (a `run!` in `:replay` is bounded by the recording) · rate-limited, in the
  loop's diagnostic cell ([D-255][d-255], [D-316][d-316]). The effective `t_end` and
  the ignored requester paths. The message says which of the two cases
  holds. The remedy names both, and interactively
  it names the operator interrupt as the sanctioned escape from the
  configuration warned about ([§12.4][s12-4]).

---

## Appendix D. Glossary

*Non-normative. Each entry compresses the meaning its owning section fixes
and cites that section. Where an entry and its owning section diverge, **the
owning section wins**. That is the same precedence rule the companion
walkthrough explainers carry. The glossary's job is to route a reader to the
normative text and to make drift visible, never to be a second source of
truth. Entries are grouped by subject and alphabetical within each group. A
term appears once, in the group that owns it, with a "not to be confused
with" clause wherever a neighboring term is genuinely close.*

### D.1 Component model and declaration layer

<a id="g-abstract-entry"></a>**abstract entry** — an `u_types` entry whose declared type is abstract.
It states **structural substitutability**: any concrete producer face below
the bound wires to it (the field handles, [§4.4][s4-4], are the demonstrated
client). It is never needed for eltype genericity, and it is illegal where
the face surfaces as a root input (`AbstractAtRoot`) ([§8.2][s8-2]).

<a id="g-assembly"></a>**assembly** — pure composition. Its component-typed fields are its children,
and it declares `local_wires` (mandatory, the class marker),
`input_wires`, `output_wires`, `sample_times` and the optional
`transparent_container`. It has no dynamics of its own. It is flattened away
for ordering, and retained as the navigation hierarchy and as
declaration-level rate scopes ([§3.3][s3-3], [§8.5][s8-5]).

<a id="g-class"></a>**class** — a component's primitive-vs-assembly status, read off *which*
well-known declarations its type defines. `local_wires` means assembly,
any leaf declaration means primitive, and neither is `ClassUnreadable`
([§8.5][s8-5]). Not to be confused with *tier* (continuous vs. discrete,
[§D.4][sD-4]), nor with a diagnostic *kind* ([§D.9][sD-9]). "Class" in
the continuous-vs-discrete sense ("two-class taxonomy", "two leaf classes",
[§3.4][s3-4]) is ordinary English, a distinct usage, never linked here.

<a id="g-component"></a>**component** — the unit of modeling: a leaf (continuous or periodic discrete
primitive) or an assembly of components. "Primitive" and "leaf" are used
interchangeably for the two leaf categories ([§3][s3]).

<a id="g-container-children"></a>**container children** — a `Tuple`/`NamedTuple` field whose elements are all
components. It contributes them as children path-named `"field/1"` or
`"field/key"`, or by bare key (`"1"` or `"key"`) where the field is declared
name-transparent via `transparent_container`. It is transparent grouping, not
an assembly: no contract, no `local_wires`, no rate scope
([§8.5][s8-5]).

<a id="g-continuous-component"></a>**continuous component** — the hybrid primitive: continuous state `x`, modes
`m`, flow `x_deriv`, two output stages, events (guards + handlers)
and optional `x_projection`. Any facet may be empty, so a state-free
instance is an FSM ([§3.1][s3-1]).

<a id="g-contract"></a>**contract** — a component's declared interface. `u_types` states its
requirements, read permissively (what each entry *allows* to arrive).
`y_types` states its public ports, read literally (what each cell
*carries*). Both take the component alone on either tier and are walked on
the continuous one, `Pinned{P}` marking a frozen leaf. A name declared in `y_types` is
public. A name returned in `y` and declared nowhere is a build error
([§8.2][s8-2], [§8.3][s8-3]). Not to be confused with the other contracts
this spec names, each a distinct sense linked never or at its own anchor: the
device authoring contract ([§11.6][s11-6]), the stepper seam's backend
contract ([§10.2][s10-2]), the staging contract ([§11.7][s11-7]), the
step-boundary contract ([§10.6][s10-6]) and the *derived contract*
([§D.1][sD-1] above).

<a id="g-declaration-inventory"></a>**declaration inventory** — the closed set of well-known functions a component
or assembly defines, each declared in a stated source of authority: by
value, by type, by allocation ([§8.2][s8-2]). The set is
`x_init`/`s_init`/`m_init`, `ws_init`, `u_types`/`y_types`,
`state_events`, the stages, `x_deriv`/`s_update`/
`x_projection`, `local_wires`/`input_wires`/`output_wires`/`sample_times`/`transparent_container`,
and `stop_reason`.

<a id="g-derived-contract"></a>**derived contract** — the checkable surface an assembly or the `Build`
derives from its children's declarations and its own wiring instead of
declaring itself: an assembly's effective face list, and the `Build`'s wire
list, face table, execution order and root inputs. It is plain printable data
(paths, names and rationals), inspectable as fields, with no rendering
implied beyond the ones [§9.2][s9-2] names. On a generic holding it is the
constraint the referencing local wires and interface connections impose on
whatever concrete child is plugged in ([§8.6][s8-6], [§8.8][s8-8],
[§9.2][s9-2]).

<a id="g-function-family"></a>**function family** — which bundle fields a given function may legally
receive. The families are
`y_state`/`y_direct`/`x_deriv`/`s_update`/guard/handler/`x_projection`,
one closed set per name per tier, the shared output stages taking one set on
each ([§5.2][s5-2], [D-220][d-220]). The comment block ([§5.2][s5-2]) states
each family's maximal legal set, and `BundleFieldError` classifies a read as
illegal for the family ([§13.2][s13-2]). Not a diagnostic *kind*
([§D.9][sD-9]).

<a id="g-generic-holding"></a>**generic holding** — a parent holding a child through a non-concrete field
type. The child is opaque below its faces, and the local wires and interface
connections referencing those faces *are* the imposed derived contract,
checked per instantiation ([§8.8][s8-8], [§6.1][s6-1]).

<a id="g-hybrid-causal-system"></a>**hybrid causal system** — what the framework simulates: continuous flow with
algebraic outputs, multi-rate periodic discrete dynamics, zero-crossing
events, post-step manifold projection, and externally injected inputs
([§2][s2]).

<a id="g-local-wire"></a>**local wire** — an entry of `local_wires`, a wire from one child's port to a
child's face with both ends inside the assembly's boundary. It stands against
an input wire and an output wire, each of which has one end on the boundary
([§6.1][s6-1], [D-303][d-303], [D-314][d-314]).

<a id="g-the-letters"></a>**the letters** — the mathematical symbols the spec's formulas keep, against
the words the API spells them as ([D-220][d-220]). `f` is the continuous flow
(`x_deriv`), `g` the discrete update (`s_update`), and `y = h(x)`
and `y = h(x, u)` the two output stages (`y_state` and
`y_direct`). The bundle letters are API in their own right. `x` is the
continuous state and `m` the continuous-only mode store, `s` the discrete
state ([D-195][d-195]), `u` wired inputs, `y` own published signals, `ws` the
workspace. An assembly has no bundle, and its boundary declarations spell
their direction as a word, in `input_wires` and `output_wires` ([D-303][d-303]).
Bare `h` means the integration step size only ([§10][s10]). Bare
`z` means only the shift operator `z⁻¹`. [D-173][d-173] retired it as a
state letter, and it was never reclaimed, since the discrete state has its
own.

<a id="g-periodic-discrete-component"></a>**periodic discrete component** — a leaf with state `s`, update `s_update`
at a declared rate, and two output stages whose cells hold zero-order between
ticks. It has no `m` store, and its `s` reaches others only through signals
([§3.2][s3-2]).

<a id="g-rate-scope"></a>**rate scope** — an assembly's `sample_times` declaration, mapping an
immediate child name to a `Relative` or `Absolute` declaration against the
enclosing scope. Relative entries compose affinely down the tree, and
absolute entries anchor. All are compiled to one `(D, Φ)` pair per discrete
component ([§8.7][s8-7], [§10.5][s10-5]).

<a id="g-schema-authority"></a>**schema authority** — the principle that declarations *define* structure and
evaluation only *checks* conformance against them, never the reverse. Types
come by declaration, values by execution, conformance by comparison
([§8.1][s8-1]).

<a id="g-stage-function"></a>**stage function / two-stage outputs** — every leaf provides exactly two
output stages, `y_state` (no `u` in the bundle, hence structurally no
feedthrough) and `y_direct`. One pair of names serves both tiers, and
each name's legal bundle set is tier-dependent ([D-220][d-220]). Feedthrough
is thereby declared by signature, with no dependency annotations anywhere
([§5.2][s5-2]).

<a id="g-state-declaration"></a>**state declaration** — a leaf's `x_init` or `s_init`, declaring its
continuous or discrete state by initial value. Every leaf makes exactly one,
empty when stateless, and it marks the leaf's tier. A non-empty one owes its
update law, `x_deriv` or `s_update`, and it seeds the leaf's `x` or `s`
store ([§8.2][s8-2]).

<a id="g-workspace"></a>**workspace** — component-declared mutable scratch, declared *by allocation*
(`ws_init(::C, ::Type{T})` on both tiers, a discrete allocator always
called at `Float64`), arriving as the `ws` bundle field. It is excluded from state
semantics, never a condition target, and never inspected or mutated by the
framework. Its contents at call entry are unspecified ([§7.3][s7-3]).

### D.2 Signals and data homes

<a id="g-buffer"></a>**buffer** — the framework-owned contiguous `Vector{T}` backing all continuous
state, laid out at build time, and the `ẋ` vectors the integrator fills. A
component's `x` store is its range of the `x` buffer. The buffer is
authoritative, and typed state values are ephemeral reconstructions of it
([§7.1][s7-1]). The integration
intermediates ([§13.6][s13-6]) live in framework-owned integrator buffers,
never in a component's workspace.

<a id="g-bundle"></a>**bundle** — the single `NamedTuple` of zero-copy views a component function
receives beside the component itself. Under the bundle law a name is present
**iff** the corresponding store or fact exists for that component.
Undeclared stores are absent, never `nothing`-filled ([§5.2][s5-2]).

<a id="g-cell"></a>**cell** — one concretely typed entry of the signal table, one per output port
of the flattened model, written by its producing stage and read by every
gatherer ([§4.1][s4-1]). Every cell is public, and private intermediates are
never cells ([§8.3][s8-3]). Bare "cell" means only this. See *staging cell*
([§D.6][sD-6]) and *store*.

<a id="g-constant-source"></a>**constant source** — an ordinary library component with no inputs and no
state, publishing a value its instance holds (`Constant{V}`). It is the
spelling for an aggregate input with zero contributors and for the rig stub
feeding an abstract face. Its value is instance data, never a default
([§13.7][s13-7], [§6.2][s6-2]).

<a id="g-entry"></a>**entry** — never used bare. The spec's compounds are table entry (a cell),
input entry ([§8.2][s8-2]), executor entry ([§9.7][s9-7]), roster entry
([§11.3][s11-3]), batch entry ([§11.3][s11-3]) and condition entry
([§14.3][s14-3]), each a different thing.

<a id="g-face"></a>**face** — the name a port wears on its component's boundary. For a leaf it is
the port's own name. For an assembly it is a name declared in
`input_wires` or `output_wires`, aliasing an interior port. It
is an opaque token with two build-checked invariants (no `/`, unique within
the assembly). Its type derives from its internal endpoint, and its direction
is declared by the method that names it. The periphery's write side speaks
face names only, and the read side speaks them wherever it wants contract
rather than structure ([§8.6][s8-6], [§11.2][s11-2], [§14.4][s14-4]).

<a id="g-feedthrough"></a>**feedthrough** — an instantaneous input→output dependence. **Structural
feedthrough** is this design's version. It is fixed by which stage produces
a port rather than annotated, and every stage-2 output is conservatively
presumed dependent on every wired input ([§5.3][s5-3]).

<a id="g-field-handle"></a>**field handle / function-valued signal** — an immutable query object carried
on an ordinary port (`ISAField`, `TerrainField`) that consumers evaluate at
arguments of their own choosing. Bulk data rides as build-time-frozen
references, never as mutable caches ([§4.4][s4-4]).

<a id="g-immutable-value-semantics"></a>**immutable value semantics** — the signal rule, stated precisely as
immutability *plus frozen references* (`isbits` is the common case, not the
rule). It gives no aliasing, safe concurrent reads, and a definite per-cell
freshness tied to the producer's position in the execution order ([§4.1][s4-1]).

<a id="g-one-home-per-datum"></a>**one home per datum** — the buffer holds `x`, the `s` and `m` stores hold
`s` and `m`, and the table holds produced signals. No store mirrors another,
and the table never holds transported data ([§5.2][s5-2], [§7.1][s7-1]).

<a id="g-port"></a>**port** — the addressable unit of the model: one declared name, one cell, one
root input, one staged write, one device claim, one trace address, one GUI
liveness verdict. Wiring is port-granular, and which stage computes a port is
invisible outside the component ([§4.2][s4-2], [§4.3][s4-3]).

<a id="g-root-input"></a>**root input** — the root component's own input face, which is an assembly's
`input_wires` key or a primitive's `u_types` key. It is produced by
no component, constant within a frame, and the only thing the periphery may
write ([§11.3][s11-3], [§8.2][s8-2], [§8.6][s8-6]).

<a id="g-scratch"></a>**scratch** — mutable working storage whose contents are never authoritative.
No boundary-consistent fact of the simulation is read from it. There are
three kinds: a component's workspace (`ws`, [§7.3][s7-3]); the integrator's
buffers and the mid-step table ([§10.3][s10-3], [§10.4][s10-4]); and the store
set a service invocation instantiates from the activation's layout and
discards with the call ([§9.4][s9-4], [§14.8][s14-8]). Not to be confused
with the simulation's own buffer set, which has the same shape and is the
authoritative one. Scratch names the role, not the type.

<a id="g-signal-table"></a>**signal table** — the framework-owned collection of cells holding every
produced signal of the flattened model. Consumers gather views from it. Its
consistency is a boundary property, and within a step it is transiently
integrator scratch ([§10.3][s10-3]).

<a id="g-staging-cell"></a>**staging cell** — the per-device atomic holding place where a device's
pending write batch waits between drains. It is mutated frame by frame,
hence outside the table's publish-once discipline ([§11.4][s11-4]). Not a
table cell ([§4.1][s4-1]).

<a id="g-store"></a>**store** — the framework-owned home of one of a component's state letters,
`x`, `s` or `m`. An `x` store is a range of the buffer. An `s` or `m` store is
a typed value, isbits or `Symbol` field by field, which the framework
overwrites when a handler or update returns a new value. It is never
arithmetic-touched and is snapshot-free to copy. A store is never called a
cell. Root inputs, by contrast, *are* source cells
of the table ([§7.3][s7-3], [§4.1][s4-1], [§11.2][s11-2]).

<a id="g-summing-junction"></a>**summing junction** — an ordinary library component performing N-to-1
aggregation through explicit wires (`SumJunction{V, N}`, the generic
`Junction` at `+`, or a named site-specific variant). There is no framework aggregation mechanism, and
fold order is the junction's positional input order ([§6.2][s6-2]).

<a id="g-value-level-constructor"></a>**value-level constructor** — the plain public function from (component,
input values) to field handle that every field-emitting component is obliged
to provide. Its own swept output stage is a one-line call to it. It is the
device by which [§14.1][s14-1] condition math queries the environment before
any sweep exists ([§8.2][s8-2]).

<a id="g-view"></a>**view** — a zero-copy reconstruction of a store handed to a function through
its bundle. It materializes in the caller's frame for the duration of the
call and is value-identical on re-materialization within a sweep
([§7.1][s7-1], [§5.2][s5-2]).

### D.3 Evaluation and scheduling

<a id="g-algebraic-loop"></a>**algebraic loop** — a genuine cycle in the instantaneous dependency graph. It
is a build error naming the path in canonical slash form, and the author
breaks it with inserted dynamics, an explicit `UnitDelay`, which samples the
signal on the discrete tier, or restructuring ([§5.5][s5-5], [D-348][d-348]). Not to be confused
with an **artificial loop**, which is port-level acyclic but stage-level cyclic. Its
remedy is a ladder: the two-stage split, contract re-factoring, and as residual
a component split ([§5.4][s5-4]).

<a id="g-execution-order"></a>**execution order** — the order in which the stage functions run, fixed once at
build time from wiring edges plus intra-component feedthrough: all stage-1
functions in any order, stage 2 in topological order, then `x_deriv`.
It is carried by the `Outputs` artifact, and "ordering" names the activity
([D-258][d-258]). The hot loop runs a flat list of `(component, stage)`
entries, with zero runtime graph logic ([§5.1][s5-1], [§9.7][s9-7]).

<a id="g-flow"></a>**flow / RHS** — `x_deriv`, the continuous derivative function, `f` in
the spec's formulas ([D-220][d-220]). Evaluating the RHS means running the
whole sweep, since `x_deriv` reads the fresh table. There is no
incremental `x_deriv`-only re-evaluation ([§5.3][s5-3], [§10.3][s10-3]).

<a id="g-frame"></a>**frame** — one iteration of the loop (drain, integrate, boundary sequence,
publication). It is the unit `step!` counts and the trace's ordinal key
([§10.1][s10-1], [§11.1][s11-1]). Distinct from a *boundary* ([§D.4][sD-4]), and from the
kinematic reference frames of the aircraft domain, which always appear
compounded ("the b frame").

<a id="g-projection"></a>**projection** — the optional per-component hook `x ← x_projection(x)`.
It runs in the only two positions in the boundary sequence between a state write
and its decode: after integration, and after a handler's `x`-reset ([§5.3][s5-3]).
It is the cheap end of geometric integration's projection methods ([§2][s2]).

<a id="g-sweep"></a>**sweep** — one pass through the execution order against the current state, in
one of two statically distinct variants compiled from the same entry list. The
**interior sweep** walks continuous entries only. It is what RK stage
evaluations and localization guard trial evaluations run, so discrete cells
hold ZOH mid-step by construction. The **boundary sweep** walks the full
list, with the boundary's due discrete entries gated in by counter modulo.
Mid-step sweeps are integrator scratch. The boundary sweep restores table
consistency, and the event phase re-runs whole boundary sweeps, against that
boundary's fixed due set, until quiescence ([§5.3][s5-3], [§10.3][s10-3],
[§10.5][s10-5], [§10.6][s10-6]).

### D.4 Time and events

<a id="g-anchor"></a>**anchor** — the exact `(T, τ)` pair an `Absolute` entry establishes: period
and offset in rational seconds. It severs its subtree from the enclosing
scope's grid. Anchor 0 is the base grid itself. Anchors join the deployment
constraint pool, and relative declarations below one compose against it
exactly as against the root grid ([§10.5][s10-5], [§9.2][s9-2]).

<a id="g-boundary"></a>**boundary** — a published consistency point, where the [§10.6][s10-6]
macro-sequence completes and a snapshot goes out. Every grid point is a
boundary, but `t*` and boundary zero are boundaries that are not frame tops
([§10.1][s10-1]). *Boundary zero* ([§14.5][s14-5], [§D.8][sD-8]) is a
hyponym. It is an ordinary boundary whose incoming transitions are authored
rather than computed. "Boundary" in the structural sense (a component's
boundary, its boundary declarations, the interface connections crossing it,
[§8.6][s8-6]) is ordinary English, a distinct usage, never linked here.

<a id="g-boundary-detected"></a>**boundary-detected** — the detection policy a `Bool`-returning guard
declares. Guards are checked for edges from not-holding to holding at
boundaries only, with no root-finding and no step rejection. The handler
fires at the first boundary that observes the edge, which is the step's end
or an earlier localized event time. The policy is exact, not approximate,
for guards over modes, root inputs and held discrete outputs alone, because
those predicates cannot cross between boundaries ([§10.4][s10-4]).

<a id="g-chattering"></a>**chattering / localization budget** — the bounded per-frame localization
allowance, `localization_budget`, a deployment keyword
defaulting to 8. Exhaustion *degrades* rather than throws. Localization
stops for the rest of the frame, and further crossings fire at the next
boundary, under a `ChatteringBudget` warning naming the event
([§10.4][s10-4]).

<a id="g-dt_base"></a>**`Δt_base`** — the base tick period, an integer multiple `N_base·h` of the
continuous step. It is bound at the `Deployment` constructor from one of three
sources: an explicit keyword, `N_base·h`, or derivation from the constraint
pool (fully anchored models only). Every discrete component's period is an
integer multiple of it ([§10.5][s10-5], [§9.2][s9-2]).

<a id="g-due"></a>**due** — a discrete component is due at a boundary when its compiled
`(D, Φ)` pair admits that boundary's tick index (`(tick − Φ) % D == 0`). Due
components' output stages are gated into the *boundary* sweep (never the
interior one), and their `s_update` calls run after quiescence. The due
set is a property of the boundary, fixed for its whole event iteration. It
is the components whose gate admits the tick index at a tick frame top,
empty at an off-tick frame top and at `t*`, and the `Φ = 0` set at boundary
zero ([§10.5][s10-5], [§10.6][s10-6]).

<a id="g-edge-semantics"></a>**edge semantics / holding** — an event fires on a transition of its
predicate from not-holding to holding, never on a bare sign change. The
opposite crossing direction is declared as a second event with the negated
guard ([§2.3][s2-3], [§10.6][s10-6]).

<a id="g-firing-budget"></a>**firing budget** — the rule bounding the boundary event iteration. Each
declared event fires at most `firing_budget` times per boundary (a
deployment keyword, an integer ≥ 1 defaulting to 4).
Eligibility is an edge from not-holding to holding on the event's
last-observed sample. An event re-enabled within the boundary therefore
fires *at* that boundary. Exhaustion drops its further edges there under a
`FiringBudget` warning ([§10.6][s10-6]).

<a id="g-guard"></a>**guard** — the declared function defining an event's predicate. It is
evaluated against the fresh boundary table and paired with a handler in an
ordered, named `state_events` collection. Its return type declares its
detection policy: `Bool` is boundary-detected, the nominal scalar is
localized ([§10.4][s10-4], [§8.2][s8-2]).

<a id="g-harmonic-grid"></a>**harmonic grid** — the rule that every discrete period is an integer
multiple of `Δt_base`, and every anchor period and offset likewise, with
`Δt_base` itself an integer multiple of `h`. Ticks therefore land only on
step boundaries. Grid times are indexed from the frame count, never
accumulated ([§10.5][s10-5], [§10.4][s10-4]).

<a id="g-input-epoch"></a>**input epoch** — a maximal span of constant root inputs, delimited by the
frame-top drains ([§11.4][s11-4]). Within an epoch a guard changes only through the
trajectory. At a seam it can jump without crossing. Hence the **θ = 0
validation**. The first act of a triggered localization is a trial
evaluation at `xₙ` under the frame's own `u`. Its `σ₀` supplies the left
bracket value and tells a *trajectory-caused* edge from an *epoch-caused*
one. A trajectory-caused edge is root-found. An epoch-caused edge has no
in-frame crossing, so the localization is discarded and the event fires in
the boundary's ordinary iteration, with no budget spent and no warning
([§10.4][s10-4]).

<a id="g-interpolant"></a>**interpolant** — the lazily built cubic Hermite continuous extension over
the last completed step. Localization trial evaluations read the states
they sweep from it. It is built only after the θ = 0 validation confirms an
in-frame crossing, and invalidated at `t*`, where the handlers have made it
a lie ([§10.4][s10-4]).

<a id="g-localized"></a>**localized** — the detection policy a sign-form guard declares. The
crossing instant is bracketed by derivative-free root-finding over trial
sweeps of interpolated states, to a bracket narrower than
`localization_tol · h` (a deployment keyword, default `1e-6`). Only the sign
form can declare it, since the `Bool` form offers no root to bracket. It
runs identically paced or unpaced ([§10.7][s10-7], [§10.4][s10-4]).

<a id="g-pacing"></a>**pacing / pacer debt** — the pacer inserts waits between completed frames
and never alters the boundary sequence. A frame exceeding its wall budget
leaves **debt** that later frames repay. Excess debt is forgiven by
re-anchor plus warning ([§10.7][s10-7]).

<a id="g-phase"></a>**phase (`Φ`)** — a schedule's offset against its grid, in scope ticks for
`Relative(K, Φ)` and in rational seconds for `Absolute(q, τ)`. It is
compiled to base ticks with `0 ≤ Φ < D` by construction. The boundary gate
is `(tick − Φ) % D == 0`, and a phase shifts firing instants, never the
period ([§10.5][s10-5]).

<a id="g-predicate"></a>**predicate** — what a guard defines: a `Bool`-valued form, or the sign of a
continuous function, which holds when the function's value `σ` satisfies
`σ ≥ 0` ([§2.3][s2-3]). Not to be confused with the
*condition* ([§14][s14]), the value that sets a build's state
([§D.8][sD-8]). The device loop's running check ([§11.6][s11-6],
[§12.3][s12-3]) and structural conformance predicates ([§9.5][s9-5]) are
distinct usages, never linked here.

<a id="g-prior"></a>**prior** — the per-event stored sample of its predicate at the previous
boundary's quiescence. It is always an honest observation and never a
manufactured one, and it is held in loop state, never in a state store.
"Newly fired" is defined against it for the boundary's first round (later
rounds test the last-observed sample). Boundary zero establishes every prior
as not-holding ([§10.6][s10-6]).

<a id="g-quiescence"></a>**quiescence** — the fixed point of the boundary event phase. Rounds of
[sweep → guards → handlers] iterate until a round fires nothing. After that
the priors are updated and due `s_update` calls run ([§10.6][s10-6]).

<a id="g-remainder-step"></a>**remainder step** — the integration from `t*` to the original grid target
after a localized event, with `h′` derived at use. Guards are re-checked on
it under the localization budget ([§10.4][s10-4]).

<a id="g-schedule"></a>**schedule / `Schedule`** — the typed tick timing the `Deployment` carries,
built by the `Deployment` constructor: one row per discrete component,
`(D, Φ, Δt)` with anchor and rate-chain columns, and the rate-scope rows; the
per-component triples the executor compiles over are derived from the rows.
It is the single source of truth for `Δt` and the
substrate of the grid diagnostics and the hyperperiod chart ([§9.2][s9-2],
[§10.5][s10-5], [D-261][d-261]).

<a id="g-state-event"></a>**state event** — an event whose instant is unknown in advance and must be
detected, declared as a `StateEvent(guard, handler)` pair under
`state_events`. The criterion is detection versus scheduling, not which
fields the guard reads, so a guard over an input is a state event too. It is
detected either boundary-detected or localized ([§2.3][s2-3],
[§8.2][s8-2]).

<a id="g-t"></a>**`t*`** — the localized event time: the holding endpoint of the
root-finder's final bracket, structurally strictly later than `tₙ`. A full
boundary runs there, but no ticks are due and no staged inputs are drained
([§10.4][s10-4]).

<a id="g-tick"></a>**tick** — an instant at which a discrete component's stages and update run,
gated by counter modulo against the harmonic grid inside the boundary sweep.
Different boundaries therefore run different subsets of the execution order
([§10.5][s10-5]).

<a id="g-tick-index"></a>**tick index** — the count of base ticks, `tick = k ÷ N_base` at the frame
top of frame `k` when `k` is a multiple of `N_base`. It is the index the
boundary gate reads. An off-tick frame top and a `t*` boundary have none
([§10.5][s10-5]).

<a id="g-tier"></a>**tier** — the continuous or discrete side of the hybrid formalism, read off
the state declaration every leaf makes, `x_init` or `s_init`, empty when stateless
(`DeclarationOnWrongTier` names a violation)
([§8.2][s8-2], [§8.5][s8-5]). Bare "tier" means only this. The genericity
classes are *walked / pinned / exempt* ([§D.5][sD-5]) and the detection
policies *boundary-detected / localized*.

<a id="g-time-event"></a>**time event** — an event whose instant is known in advance and scheduled:
the discrete tier's ticks, declared by `sample_times` and gated by the
harmonic grid. The counterpart of a *state event*, which must instead be
detected ([§2.3][s2-3], [§10.5][s10-5]).

### D.5 Build pipeline

<a id="g-activation"></a>**activation** — the build's typed products at a given scalar type `T`.
Cells are re-typed (producer-fed ones by evaluating the producer's output
declaration at `T`, root inputs by evaluating the consuming `u_types`
entry at `T`, the state type by the leaf walk), buffers are re-laid-out,
workspace allocators are re-invoked, and the probe chain is re-run. The
nominal `Float64` activation is the nominal evaluation's product; any
other is derived on request from it, the `Structure` and the `Outputs`
([§9.1][s9-1]). `Structure` and `Outputs` are `T`-independent, so no name
list and no execution order changes across activations. Non-nominal
activations are lazy, with an opt-in exhaustive set for CI ([§9.4][s9-4]).

<a id="g-always-on-conformance-check"></a>**always-on conformance check** — the probe's comparison left permanently in
place: the key-set and per-field comparison of a stage return against the
type of the cells it writes. It is decided when the table write's method is
generated over the two types (the names pair; order carries no semantics).
A conformant return type generates the straight stores and no check
instruction ([§9.5][s9-5], [D-235][d-235]).

<a id="g-build"></a>**`Build`** — the artifact `build(world)` produces, bundling the three steps'
products: `Structure`, `Outputs`, `Events`, the activations keyed by scalar
type, and `warnings`. It is the inspectable contract of the instantiation, and
what `attach!`, `ignore_stop_requests`, replay and condition resolution all validate
against ([§9.2][s9-2]).

<a id="g-chunking"></a>**chunking** — splitting a large phase body's entry tuple into statically
typed chunks behind non-inlined function barriers. Each barrier takes its
chunk by reference, and the event set's projection, guard and handler walks
chunk the same way. It is the
implementation's only representation freedom, and it converts compile cost
from superlinear in body size to linear in entry count ([§9.7][s9-7]).

<a id="g-deployment"></a>**`Deployment`** — the artifact the grid parameters fix: the build plus `h`,
`N_base`, `Δt_base`, the algorithm and the three event parameters, carrying
the `Schedule`, the grid diagnostics and its own `warnings`. It is
scalar-free, it compares as a value, and a `Model` materializes it at a
scalar type ([§9.2][s9-2], [D-254][d-254], [D-317][d-317]).

<a id="g-events"></a>**`Events`** — the nominal evaluation's other product, built last, after the nominal
stage probes: per component the event names, their detection policies and the
bundle names. It is separate from `Outputs` because a consumer of the execution
order should not carry the event tables ([§9.1][s9-1], [D-253][d-253]).

<a id="g-executable-set"></a>**executable set** — the function set an activation can actually run, hence
exactly what it probes. A `Dual` activation sees only the continuous output
stages and `x_deriv`, never the discrete stages, `s_update`,
guards or handlers ([§9.4][s9-4]).

<a id="g-executor"></a>**executor** — the compiled form of the stage execution order: a concretely
typed tuple of entries over statically typed cell storage, traversed by a
compile-time-unrolled walk, with code-selecting facts in type parameters and
plain data in fields ([§9.7][s9-7]).

<a id="g-leaf-walk"></a>**leaf walk** — the framework's derivation of per-activation types from a
declared nominal type. `Float64` leaves and `Float64` type parameters follow
the activation scalar, a `Pinned{P}` leaf yields `P`, and everything else
pins, a mutable type's parameters included. It applies to the type derived
from `x_init` and to a continuous leaf's `u_types` and `y_types`
alike; `m_init`, `s_init` and the discrete tier's contracts pin wholesale. An
output cell is the producer's walked declaration and a root-input cell the
consuming entry's, so participation and tolerance are authored per leaf by
the marker's absence or presence ([§8.2][s8-2], [D-263][d-263]; applied at
activation, [§9.4][s9-4]).

<a id="g-lens"></a>**lens** — the compiled navigation step of a condition entry. Its
tree position tuple is lifted to a type parameter, giving type-stable access
to the authored value at apply time ([§14.3][s14-3]).

<a id="g-measurement-seam"></a>**measurement seam / phase bodies** — `phase_bodies(sim)` returns the
compiled bodies of the nominal activation bound over the simulation's own
buffers: `rhs`, `sweep_1`, `sweep_2` (the sweeps in both arities, zero-arg
interior and tick-indexed boundary), `ticks`, plus per-event guards and
handlers and per-component `x_projection`. Its one promise is identity
with what the loop runs, which is what makes the allocation assertions
([§9.8][s9-8]) honest ([§9.7][s9-7]).

<a id="g-model"></a>**`Model`** — a deployment materialized at one scalar type: the deployment,
its executor, a status of `:built`, `:consistent` or `:inconsistent`, and the
diagnostic cell its frame writes. It can be written to, evaluated and stepped
frame by frame. A `Simulation` runs only a `Model{Float64}`, and a `Model` at
another scalar is a service's scratch, with no ticks and no events. A
`Simulation` claims it at construction and never shares it
([§9.2][s9-2], [§12.6][s12-6], [D-317][d-317], [D-318][d-318]). Its entry points are listed
in the `Model` block of [Appendix B][sB].

<a id="g-nominal"></a>**nominal** — the `Float64` activation, and of a declaration its `Float64`
face (for a continuous producer's output declaration, its evaluation at
`Float64`). It is the only activation that runs in real time, and the one
where the conformance check demands exact type match ([§9.4][s9-4],
[§9.5][s9-5]). Only a `Model{Float64}` can be run, and a `Model` at another scalar is a
service's scratch ([§9.2][s9-2], [D-317][d-317]).

<a id="g-outputs"></a>**`Outputs`** — the nominal evaluation's product: per component the output
port names each stage produces, and the execution order over the components.
The feedthrough graph the order was computed over is derived from the
`Structure`'s connections and the stage-2 names where it is shown, never
carried ([§9.1][s9-1], [D-253][d-253], [D-261][d-261]).

<a id="g-probe"></a>**probe** — the build's single evaluation of a user function with real
values, checking shape and type conformance and discarding the result. Every
user function is probed once, at the initial state. Probes see only that
state's branch ([§9.3][s9-3]).

<a id="g-probe-value"></a>**probe value / input synthesis** — the fabricated values a build-time probe
runs on. `probe_value(::Type)` synthesizes them at the one kind of terminal
with no producer, root inputs (`zero(T)`/`false`/first enum/`T()`,
overridable). From there they flow the probe chain as the probed stages' own
returns ([§13.1][s13-1]). They are strictly probe-scoped, never an initial
root-input value, which [§14.6][s14-6] makes a structural barrier
([§9.3][s9-3]).

<a id="g-probedual"></a>**`ProbeDual`** — the framework's public canonical concrete probe scalar
(`ForwardDiff.Dual{ProbeTag, Float64, 1}`), which keys the CI activation
pinning walked-leaf genericity. Its width is arbitrary, since what CI pins
is genericity, not a particular Jacobian ([§9.4][s9-4]).

<a id="g-schema-vs-layout"></a>**schema vs. layout** — the two lookup families the `Build` supplies to
condition resolution. *Schema* is the evaluated declarations, the authority
on whether you may write this field and at what leaf type. *Layout* is where
it physically lives (buffer ranges, store and root-input indices)
([§14.3][s14-3]).

<a id="g-structure"></a>**`Structure`** — the structure step's product: the component instances by
path, the tier each sits on, one row per assembly with its children in
declaration order and the wires it declares, the root inputs with their
types, per component its rate chain of `Relative`/`Absolute` links, and, for
each assembly an explicit `sample_times` key names, the scope triple that key
gives it. The face table and each face's routing chain are functions over its
wires ([D-315][d-315]). Nothing in it depends on a scalar type ([§9.1][s9-1],
[D-253][d-253]).

<a id="g-walked"></a>**walked / pinned / exempt** — the eltype-genericity classes. Walked
payload/value types follow the activation scalar, pinned parameters and
definitions stay `Float64`, and the discrete side is exempt. The classes are
enforced by one leaf walk over a continuous leaf's state and contracts alike;
a contract leaf opts out of walking with the `Pinned{P}` marker, in
`y_types` for what a producer's cell carries and in `u_types` for
what a consumer's entry tolerates ([§7.2][s7-2], [§8.2][s8-2]).

### D.6 Runtime periphery

<a id="g-bad-datum"></a>**bad datum** — a datum unmappable for environmental reasons (truncated
datagram, malformed JSON, out-of-range field). It is tolerated *in the loop
body*: catch, stage nothing, `report!(handle, MalformedDatum(cause))`,
continue. Any other exception propagates and becomes `DeviceCrash`. The
classification is the device author's ([§11.6][s11-6]).

<a id="g-batch"></a>**batch** — a device's staged set of face ⇒ value writes, coalesced in its
staging cell and applied whole at the next drain ([§11.4][s11-4]). The word
means only this. Error reporting *collects* ([§D.9][sD-9]).

<a id="g-binding"></a>**binding** — the value passed at `attach!` that makes a device
framework-legible. It is a subtype of `AbstractBinding` declaring its sides
by the Bool traits `is_input`/`is_output` (false by default on the root).
`is_greedy` switches the input side's claim source from returned to computed
(the unclaimed complement, in place of `claims`). `claims` and `reads` carry
error fallbacks on the root, and attach cross-checks each trait against its
method in both directions (`BindingContractMismatch`).
`map_input`/`map_output` are loop-idiom conventions the framework never
calls ([D-382][d-382]). Every input-side binding stakes a claim. `TableBinding` is the
shipped data-driven one ([§11.6][s11-6], [§11.4][s11-4]).

<a id="g-boundary-counter"></a>**boundary counter** — the loop's monotonic count of *published
boundaries*, the fact the wait predicate tests, never reset across
trajectories. It is incremented after the `latest` release-store, so a
waking waiter can never see a stale snapshot ([§12.3][s12-3]). Distinct from
the per-trajectory ordinal a snapshot carries.

<a id="g-calling-task"></a>**calling task** — the task that invoked `run!` or `replay!`. It runs the loop itself,
and every device runs on a spawned task ([§11.1][s11-1]).

<a id="g-claim"></a>**claim** — the set of faces a device *may* write. It is registered at
attach, either returned by its binding's `claims` or computed as the
unclaimed complement under `is_greedy`, and released at detach. Claiming an
already-claimed face is an attach-time error (`ClaimConflict`), and a broad
claim costs GUI liveness ([§11.3][s11-3], [D-378][d-378]).

<a id="g-coalescing"></a>**coalescing** — the CAS merge keeping one pending batch per device.
Untouched faces survive, and re-staged faces take the newest level (the
per-face ZOH). Its outbound mirror is newest-wins snapshot delivery
([§11.4][s11-4], [§12.3][s12-3]).

<a id="g-control-plane"></a>**control plane** — the separate few-word atomic surface carrying pause,
un-pause, pace, `margin`, the stop word, the sticky stopped status, the
running flag, the wait and `join_timeout`, consulted at frame top, a change during a wait landing at
the next one. A run's outcome is the `Run`'s, not its. It is structurally not
staging, since a paused loop drains nothing ([§12.1][s12-1]).

<a id="g-derived-liveness"></a>**derived liveness** — the rule that a GUI widget is live iff its port's
feed chain terminates in a root input inside the GUI's own claim in the
run's frozen surface partition. It is baked once at run start, with no
per-port "GUI-controlled" marking anywhere ([§11.7][s11-7]).

<a id="g-device"></a>**device** — any attached participant in the periphery: a subtype of
`AbstractDevice` under one authoring contract (a mandatory `loop`, and
optional `init!`, `shutdown!` and `unblock!` hooks) and one handle. Input-only and
output-only are degenerate uses, and the GUI is an ordinary device
([§11.6][s11-6]).

<a id="g-diagnostic-cell"></a>**diagnostic cell** — the per-writer cell each rostered device, the harness
writer, the loop itself and the `Model` own for runtime diagnostics and
liveness. It holds a bounded ring (capacity 16) of diagnostic values plus
per-kind suppressed counts, the bound being the rate limit itself, and an atomic
heartbeat timestamp. The loop takes it with `atomicswap` at the frame-top
drain and freezes it into the published status ([§11.8][s11-8]).

<a id="g-drain"></a>**drain** — the single point at the top of each frame where the loop takes
each staging cell by `atomicswap` and applies it through the attach-compiled
scatter, in attachment order. It never runs at a `t*` boundary, and under
the roster freeze it performs no checks at all ([§11.1][s11-1],
[§11.4][s11-4]). The diagnostic cells are taken at the same point
([§11.8][s11-8]).

<a id="g-framework-status"></a>**framework status** — the concrete frozen value each snapshot carries
beside the signal table. It holds the pacer diagnostics ([§10.7][s10-7])
plus, per writer, the diagnostics the frame's drain took (`recent`), the counts
the ring refused (`suppressed`), the loop's cumulative per-writer × per-kind
counters copied in (`totals`) and the liveness timestamp ([§11.8][s11-8],
[§11.2][s11-2]).

<a id="g-greedy-claim"></a>**greedy claim** — the claim a binding declaring `is_greedy` receives: the
unclaimed complement computed by the framework at attach instead of returned
by `claims`, ordinary in every respect afterwards. An empty remainder is
legal and reported (`EmptyGreedyClaim`), and the standard GUI binding is its
instance ([§11.3][s11-3], [§11.6][s11-6]).

<a id="g-harness-cell"></a>**harness cell** — the always-present staging cell of the harness writer,
written by `stage!(sim, "face" => value, …)` from any task, the calling task included.
Its batches are ordinary, traced and surface-checked, and drained last by
convention ([§11.3][s11-3], [§12.6][s12-6]).

<a id="g-harness-writer"></a>**harness writer** — the framework-owned write path `stage!(sim, …)`, open
to any task, with its cell; the design's sole *derived* surface. That
surface is the unclaimed complement, the faces no rostered device claims,
recomputed at every stopped-sim roster change. A write to a claimed face is
`ClaimedFaceEntry` ([§11.3][s11-3]).

<a id="g-latest"></a>**`latest`** — the `@atomic` reference a published snapshot is
release-stored into and readers acquire-load. `latest(sim)` hands the
calling task the same immutable value a device handle gets
([§11.2][s11-2]).

<a id="g-next-snapshot-wait"></a>**next-snapshot wait** — `wait_next_snapshot(handle)`: the boundary counter
plus one `Threads.Condition` under the canonical predicate loop
(`counter > last_seen && running`). Newest wins, with no queues and no
per-frame reset ([§12.3][s12-3]).

<a id="g-operator-interrupt"></a>**operator interrupt** — Ctrl-C in an interactive session, read as a
control-plane stop rather than a failure. Delivery is masked across the
boundary macro-sequence (`disable_sigint`) and raised at a frame-top, wait or
pause-block unmask point, so the run takes the ordinary graceful tail and ends
`stopped`. A second one collapses the device joins. Outside the REPL, SIGINT
still kills the process ([§12.4][s12-4], [§12.1][s12-1]).

<a id="g-orphaned-claims"></a>**orphaned claims** — the claims of a device whose task died mid-run. Death
is not detach. The roster entry and claims persist to run end, the root
inputs hold their last-drained values, and the GUI renders the fact in the
widget's source label. Recovery is between runs ([§11.3][s11-3]).

<a id="g-peek"></a>**peek** — the GUI display rule: a widget shows its own pending write if
any, else the snapshot value. It reads its own cell only, which is what
makes multi-click counting and paused editing correct ([§11.7][s11-7]).

<a id="g-periphery"></a>**periphery** — everything outside the loop that exchanges data with it
(GUI, input devices, network I/O, logging), together with the concurrency
model binding them: staged writes inbound, snapshot reads outbound, control
on its own surface ([§11][s11], [§12][s12]).

<a id="g-roster"></a>**roster** — the list of attached device entries (binding, claims, stable
device id, attachment order). It is a plain immutable value the loop reads
once at `run!`, since `attach!`/`detach!` are stopped-sim operations
([§11.3][s11-3]).

<a id="g-run"></a>**`Run`** — the state one run owns, a `Simulation` field beside the control
plane. Two `const` fields, the log and the trace; four writable ones, `feed`,
`termination` and the trajectory's counters `frame` and `boundary`. `init!`,
`restore!` and `replay!` construct one, the flips write `feed`, the loop
advances the counters, the loop's tail writes `termination` once, and
`closed(run)` is `termination !== nothing` ([§12.6][s12-6], [D-255][d-255],
[D-260][d-260], [D-317][d-317]).

<a id="g-scenario-component"></a>**scenario component** — the home of a sim-time script under the mid-run
mutation doctrine: an ordinary periodic discrete component executed
synchronously in the loop, deterministic paced or unpaced and replayed by
recomputation. The clock is the criterion. Wall-clock interactions are
devices ([§12.5][s12-5]).

<a id="g-selector"></a>**selector (read-selector family)** — the closed set of deferred reads
`get_state`/`get_deriv`/`get_output`/`get_input`/`get_face`, each naming one
leaf by its leaf address. Each resolves
against a source. Table sources are a
boundary snapshot or a service evaluation's scratch tables; the other source
is the live stores ([§14.4][s14-4]).

<a id="g-leaf-address"></a>**leaf address** — a selector's second argument: the field or face
name followed by `.name` and `[k]` or `[k,l]` steps in any order, naming one
leaf of a port value or one component of a state leaf (`"pose.q_eb[2]"`,
`"J[1,3]"`). A bare `Symbol` is the short form of a plain name. Each step is
checked at resolution and the chain is baked into the compiled read
([§14.4][s14-4], [D-276][d-276]).

<a id="g-should_abort"></a>**`should_abort`** — the per-attachment failure policy, an `attach!` keyword
defaulting to `false`. Set, a device's departure (loop body returning,
crash, or a failed `init!`) also requests a control-plane stop. Clear, the
run continues with the device absent and its claims held to run end. It is
an attachment fact, never a device property, since the same device can be
advisory in one deployment and decisive in another ([§11.6][s11-6],
[§12.4][s12-4], [D-381][d-381]).

<a id="g-snapshot"></a>**snapshot** — the immutable per-boundary publication: boundary-consistent
signal table (root inputs included), `t`, frame index, boundary index and
framework status. It deliberately carries no state stores, because the state
trajectory is derived data ([§11.2][s11-2], [D-261][d-261]).

<a id="g-stage-on-interaction"></a>**stage-on-interaction** — the GUI staging contract. Value widgets stage the
new level on edit, and edge widgets stage on activation, as a level computed
from the peek. Held buttons do not re-stage, and no widget stages per render
pass ([§11.7][s11-7]).

<a id="g-stop-policy"></a>**`StopPolicy`** — the immutable value one advance declares: `t_end` plus the
requester paths it ignores. `run!`, `replay!` and `step!` build
and validate it per call and pass it to the loop, an ignore mask (one
`Bool` per requester) beside it as the loop's own argument; afterwards only
the termination record keeps one. A `t*` hit is `frame!`'s `Bool` return,
and the loop reads the requester off the snapshot it just published.
`ControlRequestedStop` is outside it, since the policy is what the caller
declares and the stop word is what anyone can issue ([§12.1][s12-1],
[§12.6][s12-6], [§13.5][s13-5], [D-255][d-255], [D-260][d-260], [D-316][d-316], [D-317][d-317]).

<a id="g-stop-word"></a>**stop word** — the control plane's stop command, one atomic word holding
its issuer ([§12.1][s12-1]). Not to be confused with a *stop request* ([§D.9][sD-9]), which
the model publishes.

<a id="g-unattended-run"></a>**unattended run** — a run with empty staging and no snapshot readers. It is
the same loop, fully synchronous on the calling task, rethrowing after the
shutdown tail so CI fails honestly ([§11.1][s11-1], [§13.4][s13-4]).

<a id="g-write-surface"></a>**write surface** — the set of faces a writer's batch entries may reach. For
a device it is the claim set, whether returned by `claims` or computed under
`is_greedy` ([§11.6][s11-6]). For the harness writer it is the derived
unclaimed complement. It is static per run and enforced entirely at staging,
`OutOfClaimEntry` for a device and `ClaimedFaceEntry` for the harness
([§11.3][s11-3]).

### D.7 Recording and replay

<a id="g-checkpoint"></a>**checkpoint** — the `Model`'s state at a frame top as one value, a
`ModelState`, beside the run's two counters, the frame index and the
boundary ordinal. `checkpoint(model)` reads the state alone and
`checkpoint(sim)` the whole `Checkpoint`, which `init!` takes too as the
trace's header. `restore!` puts either back with no boundary zero. The state
holds the flat buffer, the `s` and `m` stores, the whole signal table, the
guard priors, `t` and `t₀`, the fingerprint and the deployment. It is not a
condition and has no algebra ([§11.5][s11-5], [§12.6][s12-6], [D-274][d-274], [D-317][d-317], [D-319][d-319]).

<a id="g-decimation"></a>**decimation** — the log's keep-every-kth retention policy (`log_every`),
admissible on the log alone because it is derived data. Every boundary still
runs, publishes to live readers and enters the trace. The log is bounded by
`log_max`, the maximum number of retained snapshot references (default
finite, `Inf` the opt-out). When the log fills, the effective stride
doubles. That is *progressive re-decimation*, so coverage stays global at
`log_every · 2^k` instead of collapsing to a rolling window. The
run's first and terminal snapshots are retained unconditionally and outside
the bound. Decimation is a view policy throughout, never
trajectory-determining ([§11.2][s11-2]).

<a id="g-frame-ordinal"></a>**frame ordinal** — the trace's key. Replay applies the recording's batches
for frame *k* at frame *k*. That is exact because the frame sequence is
itself deterministic under replay ([§12.7][s12-7], [§11.1][s11-1]).

<a id="g-input-mode"></a>**input mode** — where the [drain](#g-drain) takes its batches from,
read as `mode(sim)` off the run's `feed`: `:live` from the staging cells,
`:replay` from a recording `replay!` attached. A replaying advance is
bounded by the recording. The mode returns to `:live` when the recording's
last frame is consumed, or when `live!` drops the remainder by hand
([§12.6][s12-6], [§12.7][s12-7]).

<a id="g-log"></a>**log** — the retained sequence of published snapshots (the same objects, no
copies), with a plain kill switch and `log_every` decimation. It is derived
data, recomputable from the trace by replay ([§11.2][s11-2]).

<a id="g-recorders"></a>**recorders** — the trace and the log jointly. `init!`, `restore!` and a trim commit
build them anew together, so they restart with the run they record
([§12.6][s12-6], [§14.8][s14-8]).

<a id="g-replay"></a>**replay** — the ordinary loop with one substitution: the drain reads the
trace by frame ordinal, after the trace's checkpoint is restored under
the default form. It re-records, ends `initialized`, and validates the
checkpoint's fingerprint (the structural layout) and its `Deployment` up
front. The default form restores the clock with the rest of the state
([§12.7][s12-7]).

<a id="g-run-metadata"></a>**run metadata** — the trace header's `Deployment` and `t₀`, hence
`Δt_base`, `h`, `N_base`, the algorithm identifier, `localization_tol`,
`localization_budget` and `firing_budget`. It carries no stop policy; each
advance declares its own ([§11.5][s11-5], [§13.5][s13-5]).

<a id="g-trace"></a>**trace** — the primary record of a session: the sequence of drained,
device-tagged batches per frame, plus its header. It is on by default,
because the log is recomputable from the trace and never the reverse
([§11.5][s11-5]).

<a id="g-trace-header"></a>**trace header** — the trace's fixed preamble: the checkpoint `init!` takes
at the end of boundary zero, after the first snapshot. It carries the run's
`Deployment` and `t₀` with the rest of the state. It holds no stop policy
and no schema list, both of which live elsewhere ([§11.5][s11-5],
[§14.5][s14-5], [D-274][d-274]).

<a id="g-trace-record"></a>**trace record** — the retained form of a drained batch, uniform for every
writer: (position ⇒ value) pairs for the masked (touched) entries, converted
at the drain against the trace's `schemas` list. Trace size therefore tracks
information rather than surface width, and consumers meet one format and
one replay path ([§11.5][s11-5], [D-176][d-176]).

<a id="g-what-if-replay"></a>**what-if replay** — replaying a trace against the same structure with
changed parameters: deterministic re-driving of the recorded inputs through
a modified model, initialized by `init!` under the authored condition and
fed by `replay!` with `restore = false`. It promises determinism but never
bit-identical reproduction ([§12.7][s12-7]).

### D.8 Stopped-sim services and the condition algebra

<a id="g-at"></a>**`at` / `Scoped`** — the scoping combinator. `at(prefix, node)` stores a
prefix beside a condition node and applies nothing. Path concatenation
happens once, at resolution. It also lifts whole `TrimProblem`s and
linearization tap sets ([§14.2][s14-2], [§14.9][s14-9]). A read set keeps its
prefixes as a chain and is not a condition node ([D-277][d-277]). An empty
prefix is refused when `at` is called ([D-278][d-278]).

<a id="g-baseline"></a>**baseline** — a full-coverage condition, such as an aircraft-shipped
function (`ready_for_taxi(ac)`, `cold_and_dark(ac)`) returns, layered under
tweaks by `override`. It is also the `baseline` keyword `trim!` takes
([§14.6][s14-6]). Not to be confused with an event *prior* ([§D.4][sD-4]).

<a id="g-boundary-zero"></a>**boundary zero** — the initialization boundary: the ordinary
macro-sequence with an empty integrate, run at `t₀` once `apply!` has
established the stores. The sequence is project → [sweep → guards →
handlers]\* → due `s_update` calls → first snapshot, after which `init!`
takes the trace header ([§14.5][s14-5]).

<a id="g-combine"></a>**combine** — the symmetric, collision-intolerant combinator over condition
nodes. A duplicate leaf is an error naming both origins, and
blending a node with a bare `NamedTuple` is a directive error method
([§14.2][s14-2]).

<a id="g-component-test-rig"></a>**component test rig** — a one-child assembly exporting the child's entire
input face set. It is the idiom for exercising a leaf that needs something
wired beside it. An abstract entry is satisfied *inside* the rig by a
concrete **stub child** wired to that face ([§13.7][s13-7]).

<a id="g-condition"></a>**condition** — the datum that says "set this build to this state": a
path-addressed sparse overlay on the declared defaults, covering `x`, `s`
and `m` fields plus root inputs by face, never outputs and never workspace
([§14.1][s14-1]). [§14][s14] owns the word. A guard defines a *predicate*
([§D.4][sD-4]).

<a id="g-design_world"></a>**`design_world`** — the rig this design records for design-time
work, aircraft + `SimpleAtmosphere(wind = NoWind())` + `HorizontalTerrain`,
which mounts an aircraft for trim and linearization. `SimpleAtmosphere` and
`NoWind` are FlightPhysics' atmosphere types. "Aircraft as root" is the
shallowest world, not a special case ([§14.9][s14-9]).

<a id="g-fragment"></a>**fragment** — the leaf node of the condition algebra, built by
`set(; x, s, m, u)`. Its payloads speak only about the component at the
authoring point (**self-vocabulary**), with addressing left entirely to `at`
([§14.2][s14-2]).

<a id="g-fragment-tree"></a>**fragment tree** — the inert, lazy composition of `Fragment`/`Scoped`/
`Combined`/override nodes. It is isbits but for the prefix strings, which
are references to the author's literals, so rebuilding it per trim
iteration allocates nothing and does no path work ([§14.2][s14-2]).

<a id="g-mounting"></a>**mounting** — relocating a whole problem or tap set with `at(prefix, …)`.
Each field is condition-producing (path-relative, post-composed), a read set
carrying its mount chain, or path-free, so the service never knows where its
paths sit ([§14.9][s14-9]).
The read side rebases every selector to the root at resolution
([§14.9][s14-9]).

<a id="g-override"></a>**override** — the ordered, asymmetric layering combinator. On a shared leaf
the patch wins and the origin records both layers, while collisions *within*
a layer remain errors. It is variadic ([§14.6][s14-6]).

<a id="g-root-input-totality"></a>**root-input totality** — the pre-write requirement that an application
establishing a complete world over virgin stores (`init!`, trim setup, trim
commit, linearization's operating condition under `about`) cover every root
input. Conditions themselves are legitimately
partial. A shortfall is `UninitializedInputs`, collected and
declaration-ordered, leaving the simulation untouched ([§14.6][s14-6]).

<a id="g-service-lifecycle"></a>**service lifecycle** — the `Simulation` states `built` / `initialized` /
`running` / `stopped` / `errored` ([§12.6][s12-6]) and each service's
legality against them, and on a `Model` the statuses `:built`, `:consistent` and
`:inconsistent` that its own service forms gate on ([§14][s14], [D-319][d-319]). A violation is
`ServiceLifecycle`, and `errored` is terminal for all five services ([§14][s14]).

<a id="g-taps"></a>**taps** — the three selector lists (`x`, `u`, `y`), built by `taps`,
declaring what linearization seeds and reports. Every tap names one scalar,
by a leaf address resolving to one scalar leaf. A seeded tap, in the `x` or
`u` list, reaches its scalar through one index step at most and never a
`.name` step, and its leaf is exactly `Float64`. Their selectors are validated
at resolution (`ReadResolution`), the tap set's own constraints beside them
(`TapResolution`), and they are relocatable via `at` ([§14.10][s14-10]).

<a id="g-trimproblem"></a>**`TrimProblem`** — the closed nine-field value
`guess`/`lower`/`upper`/`condition`/`reads`/`residuals`/`tolerances`/`checks`/`check_tolerances`: an
*implicitly specified* condition, solved as a square root-find over named
residuals and committed as an `init!` of `override(baseline, condition(solution))`
([§14.7][s14-7], [§14.8][s14-8]).

### D.9 Error discipline and diagnostics

<a id="g-carrier-exception"></a>**carrier exception** — the single exception diagnostics travel in when
thrown. `DiagnosticError` holds one diagnostic at a fail-fast site or the
collection at a step barrier, and its type parameter tells which.
`StepError` at the runtime catch site takes a single diagnostic over as its
`cause` and carries the cause's type as its parameter. Diagnostics
themselves are plain values ([§13.2][s13-2], [§13.4][s13-4]).

<a id="g-collect-the-checks-fail-the-evaluations-fast"></a>**collect the checks, fail the evaluations fast** — the reporting policy.
Declarative passes over collected structure return their full violation
list, while the first user-code exception aborts the phase. The build's
steps are barriers, and the site column spells the collecting case "build
(collected)" ([§13.1][s13-1], [Appendix C][sC]).

<a id="g-did-you-mean"></a>**did-you-mean** — the required shape of any name-shaped failure: the
offending name plus the list-in-hand it should have matched, carried as
payload rather than baked into message text ([§13.2][s13-2]).

<a id="g-error-locality"></a>**error locality** — the property the declaration layer buys. A mistake
fails at the site of the mistake, not later and inside correct code. The
five walkthroughs ([§8.4][s8-4]) are its grounding cases and the acceptance
tests ([§8.4][s8-4]).

<a id="g-execution-cursor"></a>**execution cursor** — the executor's plain mutable field recording where
execution stands in the compiled order. It holds three facts, the component by
its index in the structure's component list, the function running, and the
boundary phase. It costs one cheap store per dispatch, so a runtime failure
gets its cursor frame without exception handlers in the hot path
([§13.4][s13-4]).

<a id="g-feedthrough-tracer"></a>**feedthrough tracer** — the set-propagation instrument (global
value-blind, or sampled primal-carrying) used to classify a
rejected cycle as real or artificial. It is diagnostic only, never an input
to the ordering ([§5.5][s5-5], [§13.8][s13-8]).

<a id="g-kind"></a>**kind** — a diagnostic's identity in the closed set enumerated normatively
in [Appendix C][sC], with payload fields, owning section, severity, where it
is raised and under which policy. Tests match on kind plus payload, never on
message text ([§13.2][s13-2]). Not a component *class* ([§D.1][sD-1]) or a
*function family* ([§D.1][sD-1]).

<a id="g-payload"></a>**payload** — the structured data a diagnostic carries beside its kind:
paths and names as strings (never instances or component types),
expected/observed port types, the list-in-hand ([§13.2][s13-2],
[Appendix C][sC]). Severity is the kind's, not the payload's.

<a id="g-requester-roster"></a>**requester roster** — the build's list of stop
requests, one `Requester(path, port, reason)` per `StopFlag` output port, in
build order ([§13.5][s13-5]).

<a id="g-species"></a>**species** — a `StepError` whose `cause` is a diagnostic, `StepError{Kind}`
by type. It is what the catch site makes of a single-diagnostic
`DiagnosticError` thrown inside the frame, under the species rule
([§13.4][s13-4], [D-225][d-225]).

<a id="g-stop-request"></a>**stop request / termination is a state** — graceful termination is model
state, never an exception. Detection is ordinary event machinery, and
publication a stop request, an output port of the framework enum `StopFlag`
anywhere in the tree. The loop scans every request after every published
boundary, and one reading `STOP_REQUESTED` ends the run unless the advance
names its component in `ignore_stop_requests`. The build rosters the
requests, and `StopRequest` is the library spelling ([§13.5][s13-5], [D-316][d-316]).

<a id="g-termination-record"></a>**termination record** — the stopped-sim value naming how the run ended. It
holds the final boundary time, the `StopPolicy` of the terminating advance, a
typed source with its payload, and the tail residue. A model-requested stop's
payload is the requester's path, port and reason. It lives on the `Run`,
never on the control plane ([§12.6][s12-6], [§13.5][s13-5]).

### D.10 Meta-vocabulary

<a id="g-artifact"></a>**artifact** — an immutable pure function of its inputs: `Structure`,
`Outputs`, `Events`, an activation, the `Build`, the `Deployment`, the
`Schedule`, a condition plan, a trim report and the trace header. A warning
raised producing one lives on it ([§13.2][s13-2], [D-250][d-250]). It holds
declared facts, and a consumer compiles what it needs from them at one home
([§9.2][s9-2], [D-261][d-261]).

<a id="g-blessed"></a>**blessed** — the spec's marker for a practice it explicitly sanctions where
a neighboring one is forbidden: derivation from other declarations
([§8.2][s8-2]), the one spot where evaluation feeds structure
([§9.1][s9-1]), the workspace-plus-snapshot idiom for zero-allocation ticks
([§8.2][s8-2]).

<a id="g-row"></a>**decision entry / `D-nnn`** — a numbered entry of `decisions.md`, cited
throughout as a linked `D-nnn` reference: one settled decision with the
alternatives weighed against it. Entry numbers are stable and never reused ([§1][s1]).
Each entry states its *current* position, and a superseded one is marked
`superseded → D-nnn` in its Status line rather than rewritten.

<a id="g-the-freeze"></a>**the freeze** — the roster freeze. `attach!`/`detach!` are stopped-sim
operations, so the roster, its claims and the run's partition of the root
face set into write surfaces are static, inspectable facts of each run
([§11.3][s11-3], [D-106][d-106]).

<a id="g-guarded-addition"></a>**guarded addition** — a capability the design admits but does not build,
weighed against the design criteria of [§1][s1] and recorded with its
shape so adoption stays additive (e.g. field-addressed staging,
[§4.3][s4-3]; mid-run reader attach, [§11.3][s11-3]).

<a id="g-normative"></a>**normative / index, not a second home** — the spec is the normative
statement of the design, and its appendices are indices. Each recall line's
normative statement stays in the owning section ([Appendix A][sA], and the
same rule for Appendices B, C and D). The design directory's walkthrough
explainers are non-normative companions by their own preambles.

<a id="g-recorded-not-built"></a>**recorded, not built** — the disposition of a worked-out extension
deliberately left unimplemented, with its seams named so adoption is
additive (the closed-loop trim, [§14.7][s14-7]; the sampled-data `Dual`
activation and the tooling over declared non-participation, [§14.10][s14-10]).

<a id="g-state-single-owner"></a>**state** — the criterion's other word: a value with a single owner, mutated
in place. The executor's buffers, the roster, the diagnostic cells, the live
log and trace and the `Run` are state. A warning raised mutating one lives in
that state's status ([§13.2][s13-2], [D-250][d-250]).

<a id="g-seam"></a>**seam** — a narrow, named interface kept deliberately thin so what sits
behind it can be replaced or measured: the stepper seam ([§10.2][s10-2]),
the backend seam ([§14.8][s14-8]), the measurement seam ([§9.7][s9-7]), the
phase-body seams of the compiled executor ([§9.7][s9-7]), the generic seams of an
assembly tree ([§8.8][s8-8]).

<a id="g-torture-test"></a>**torture test** — a maximally awkward case spelled against a proposed
mechanism to validate it before adoption: the filter, joystick and GUI against
the [§11][s11] staging shapes ([§11.4][s11-4]), the strapdown IMU against the
leaf split ([§8.6][s8-6]). The standard component library is the standing
ergonomics one ([§13.7][s13-7]).

<a id="g-worked"></a>**worked (example)** — a full spelling of a mechanism against a concrete
case, carried in the spec rather than left to the reader: the IMU assembly of
[§8.6][s8-6], whose leaves are also the boundary-sampling example
[Appendix A][sA] points at, the staging example of [§11.4][s11-4], and the
worked C172 cruise problem of [§14.7][s14-7].

<!-- citation link definitions — generated by tools/linkify.jl; do not edit -->
[d-001]: decisions.md#d-001--hybrid-causal-formalism-with-two-tier-events-and-projection
[d-002]: decisions.md#d-002--adopt-the-causal-port-based-paradigm
[d-003]: decisions.md#d-003--component-taxonomy-hybrid-primitive-periodic-discrete-assemblies
[d-004]: decisions.md#d-004--immutable-value-signals-in-a-typed-signal-table
[d-005]: decisions.md#d-005--reject-algebraic-loops-at-build
[d-006]: decisions.md#d-006--two-stage-structural-feedthrough-via-h_xh_xu
[d-008]: decisions.md#d-008--function-valued-environment-signals-with-the-handle-pattern
[d-010]: decisions.md#d-010--structure-continuous-state-as-immutable-values-over-a-flat-backing
[d-011]: decisions.md#d-011--eltype-genericity-on-the-continuous-path
[d-012]: decisions.md#d-012--set-propagation-tracers-and-scc-based-cycle-diagnostics
[d-013]: decisions.md#d-013--immutable-discrete-state-via-cells-workspace-and-snapshot
[d-014]: decisions.md#d-014--scoped-allocation-invariant-ci-enforced
[d-015]: decisions.md#d-015--fused-evaluation-of-derivatives-and-outputs
[d-016]: decisions.md#d-016--uniform-component-interfaces-via-h_x-and-per-event-re-decode
[d-017]: decisions.md#d-017--framework-owned-simulation-loop-with-a-stepper-seam
[d-018]: decisions.md#d-018--tier-2-event-localization-via-dense-output-and-bracketed-root-finding
[d-019]: decisions.md#d-019--harmonic-tick-grid-with-virtual-assemblies-and-rate-scopes
[d-020]: decisions.md#d-020--boundary-event-phase-iterates-to-quiescence
[d-021]: decisions.md#d-021--pacer-piecewise-affine-wall-clock-mapping-with-bounded-debt
[d-022]: decisions.md#d-022--periphery-architecture-no-shared-mutable-model
[d-023]: decisions.md#d-023--snapshot-publication-via-atomic-acquire-release
[d-024]: decisions.md#d-024--inbound-staging-per-device-atomic-batch-cells
[d-025]: decisions.md#d-025--one-uniform-device-kind
[d-026]: decisions.md#d-026--gui-write-path-panels-name-their-own-ports
[d-027]: decisions.md#d-027--pacer-coarse-phase-uses-task-yielding-sleep
[d-028]: decisions.md#d-028--next-snapshot-wait-via-monotonic-counter-and-condition-variable
[d-029]: decisions.md#d-029--input-trace-on-by-default
[d-030]: decisions.md#d-030--shutdown-protocol-publish-wake-unblock-join
[d-031]: decisions.md#d-031--mid-run-mutation-doctrine-staging-and-control-commands-only
[d-032]: decisions.md#d-032--component-declaration-trait-layer-with-probe-checked-schema-authority
[d-033]: decisions.md#d-033--declaration-inventory-by-value-by-type-by-allocation-conventions
[d-034]: decisions.md#d-034--contract-visibility-declared-fields-are-public
[d-035]: decisions.md#d-035--stores-and-views-components-read-zero-copy-view-bundles
[d-036]: decisions.md#d-036--table-mechanics-stage-returns-are-namedtuples-of-port-values
[d-037]: decisions.md#d-037--aggregation-by-explicit-summing-junctions
[d-038]: decisions.md#d-038--snapshot-and-log-derived-trajectory-primary-trace-header
[d-039]: decisions.md#d-039--assembly-declaration-is-type-based
[d-040]: decisions.md#d-040--slash-string-paths-as-the-canonical-path-form
[d-041]: decisions.md#d-041--dedicated-exports-for-assembly-faces
[d-042]: decisions.md#d-042--rates-declaration-on-immediate-children-only
[d-043]: decisions.md#d-043--computed-exports-via-ordinary-code-and-faces
[d-044]: decisions.md#d-044--slot-exclusivity-and-the-write-surface-rule
[d-045]: decisions.md#d-045--periphery-input-semantics-derived-liveness-conditioning-mappings-edge-logic
[d-046]: decisions.md#d-046--face-names-are-opaque-string-tokens-slash-is-reserved-for-structure
[d-047]: decisions.md#d-047--stage-widgets-on-interaction-events-not-every-pass
[d-048]: decisions.md#d-048--three-stratum-build-pipeline-structure-schedule-activation
[d-049]: decisions.md#d-049--standalone-buildworld-artifact-wrapped-by-simulation
[d-050]: decisions.md#d-050--probe-every-user-function-once-at-build-at-nominal-t
[d-051]: decisions.md#d-051--synthesize-probe-inputs-via-a-probe_valuetype-fallback-chain
[d-052]: decisions.md#d-052--scope-dual-probing-to-each-activations-executable-set
[d-053]: decisions.md#d-053--bake-one-always-on-conformance-check-at-every-table-write
[d-054]: decisions.md#d-054--producers-determine-activation-types-consumers-stay-generic
[d-055]: decisions.md#d-055--require-strict-local_types-declaration-for-cross-stage-cells
[d-056]: decisions.md#d-056--uphold-the-two-kind-taxonomy-against-the-integrate-and-dump-challenge
[d-057]: decisions.md#d-057--batch-declarative-check-violations-abort-on-first-user-code-exception
[d-058]: decisions.md#d-058--diagnostics-as-structured-values-under-one-builderror-carrier
[d-059]: decisions.md#d-059--catch-runtime-failures-at-one-boundary-site-into-steperror
[d-060]: decisions.md#d-060--graceful-termination-is-model-state-never-an-exception
[d-061]: decisions.md#d-061--resolve-walks-declared-types-to-enforce-the-generic-boundary-rule
[d-062]: decisions.md#d-062--tooling-commitments-face-predicates-build-printer-component-library
[d-063]: decisions.md#d-063--conditions-are-path-addressed-sparse-overlays-on-init_-defaults
[d-064]: decisions.md#d-064--compose-per-component-init-by-pull-via-fragment-functions
[d-065]: decisions.md#d-065--fragments-form-a-lazy-inert-tree-resolved-against-the-build
[d-066]: decisions.md#d-066--two-ways-to-apply-one-plan-specialized-apply-vs-dynamic-entry-list-walk
[d-067]: decisions.md#d-067--boundary-zero-runs-the-macro-sequence-with-an-empty-integrate
[d-068]: decisions.md#d-068--enforce-slot-totality-at-the-initcommit-service-boundary
[d-069]: decisions.md#d-069--trim-problem-spelling-namedtuples-residual-vector-exact-ad-jacobians
[d-070]: decisions.md#d-070--trim-service-in-house-dense-lm-behind-a-swappable-backend
[d-071]: decisions.md#d-071--mount-trim-as-an-implicitly-specified-condition-via-at
[d-072]: decisions.md#d-072--linearization-surface-three-selector-lists-one-chunked-dual-pass
[d-073]: decisions.md#d-073--companion-sketches-carry-the-settled-condition-algebra-design
[d-074]: decisions.md#d-074--hand-off-component-function-arguments-as-one-named-bundle
[d-075]: decisions.md#d-075--name-flowupdateoutput-stages-by-letter-and-dependence-class
[d-077]: decisions.md#d-077--allocate-workspace-via-a-per-activation-workspace-method
[d-078]: decisions.md#d-078--treat-input-entries-as-face-constraints-checked-by-subtyping
[d-079]: decisions.md#d-079--type-declarations-concretely-resolved-by-an-activation-leaf-walk
[d-080]: decisions.md#d-080--keep-tier-2-event-detection-pace-independent
[d-081]: decisions.md#d-081--treat-t-as-a-boundary-not-a-frame
[d-082]: decisions.md#d-082--define-guard-conditions-against-a-per-event-baseline
[d-083]: decisions.md#d-083--bind-output-device-reads-to-snapshot-paths-not-just-faces
[d-084]: decisions.md#d-084--drop-the-unconnected-output-warning
[d-085]: decisions.md#d-085--unpack-tuplenamedtuple-fields-as-container-children
[d-086]: decisions.md#d-086--compile-the-executors-schedule-into-unrolled-statically-typed-entries
[d-087]: decisions.md#d-087--freeze-the-device-roster-as-a-build-validated-immutable-value
[d-088]: decisions.md#d-088--define-the-run-lifecycle-built--initialized--running--stoppederrored
[d-089]: decisions.md#d-089--route-supervisor-gains-and-resets-through-ordinary-ports
[d-090]: decisions.md#d-090--return-handler-updates-as-bundle-law-namedtuples
[d-093]: decisions.md#d-093--spawn-device-tasks-per-run-not-per-attach
[d-094]: decisions.md#d-094--close-the-state-leaf-vocabulary-to-plain-scalars-and-sarrays
[d-095]: decisions.md#d-095--prefix-the-read-selector-family-with-get_
[d-096]: decisions.md#d-096--define-the-harness-writer-stagelateststep-duration
[d-098]: decisions.md#d-098--resolve-selectors-against-a-source-before-client-policy
[d-099]: decisions.md#d-099--spell-the-ci-activation-invariant-with-a-canonical-probe-scalar-type
[d-100]: decisions.md#d-100--freeze-u-at-round-start-for-within-round-event-visibility
[d-101]: decisions.md#d-101--implement-replay-as-the-ordinary-loop-with-two-substitutions
[d-102]: decisions.md#d-102--author-owned-device-loop-inside-a-framework-owned-bracket
[d-104]: decisions.md#d-104--coalesce-staged-writes-by-cas-merge-with-per-attachment-positional-shape
[d-105]: decisions.md#d-105--split-device-side-bad-datum-handling-into-tolerated-garbage-and-propagated-crashes
[d-106]: decisions.md#d-106--freeze-the-device-roster-for-the-duration-of-a-run
[d-108]: decisions.md#d-108--gate-stopped-sim-services-by-input-derived-lifecycle-preconditions
[d-110]: decisions.md#d-110--give-trim-an-explicit-t0-argument-and-state-its-recording-clear
[d-111]: decisions.md#d-111--fold-project-into-the-always-on-conformance-check
[d-112]: decisions.md#d-112--add-events-to-the-tier-consistency-markers
[d-113]: decisions.md#d-113--close-four-kindless-diagnostic-rules-with-new-payload-fields
[d-114]: decisions.md#d-114--order-snapshot-publication-before-the-boundary-counter-increment
[d-115]: decisions.md#d-115--source-the-bundle-laws-remaining-probe-fields-t-and-ws
[d-116]: decisions.md#d-116--expose-phase_bodiessim-as-the-zero-allocation-invariants-measurement-seam
[d-117]: decisions.md#d-117--extend-declarations-and-stages-via-explicit-per-name-import
[d-118]: decisions.md#d-118--trimproblem-authoring-surface
[d-120]: decisions.md#d-120--reconcile-rigs-with-abstract-at-root-via-stub-children
[d-121]: decisions.md#d-121--partition-the-cellstore-vocabulary-and-bless-staging-cell
[d-124]: decisions.md#d-124--widen-147s-reads-grammar-to-the-full-service-selector-set
[d-125]: decisions.md#d-125--admit-get_face-to-the-service-reads-set
[d-126]: decisions.md#d-126--give-trim-commit-events-a-report-channel
[d-127]: decisions.md#d-127--add-a-deployment-block-to-the-trace-header-for-replay-validation
[d-128]: decisions.md#d-128--define-to_boundary-as-the-frame-entry-boundary-index
[d-129]: decisions.md#d-129--restate-the-two-notation-rule-as-directional-structure-vs-contract
[d-130]: decisions.md#d-130--scope-resolves-generic-boundary-duty-by-client-wiringserviceinspection
[d-132]: decisions.md#d-132--treat-operator-interrupt-ctrl-c-as-a-control-plane-stop-not-a-failure
[d-133]: decisions.md#d-133--split-spec-invoked-numeric-constants-into-deployment-parameters-vs-owning-section-defaults
[d-135]: decisions.md#d-135--scope-the-activation-cache-to-immutable-compiled-artifacts-keyed-on-the-build
[d-136]: decisions.md#d-136--unify-diagnostics-and-liveness-heartbeat-into-one-per-writer-diagnostic-cell
[d-137]: decisions.md#d-137--bound-snapshot-log-retention-by-count-with-amortized-doubling-stride
[d-138]: decisions.md#d-138--make-device-init-an-explicit-bracketed-step-of-the-run-start-protocol
[d-139]: decisions.md#d-139--give-environment-field-handles-a-value-level-constructor-to-prevent-drift
[d-140]: decisions.md#d-140--add-a-three-rung-remedy-ladder-for-artificial-algebraic-loop-dependencies
[d-141]: decisions.md#d-141--continuous-state-resets-are-events-owned-by-the-reimplemented-pivector
[d-142]: decisions.md#d-142--stage-code-must-be-total-over-type-valid-inputs
[d-143]: decisions.md#d-143--add-a-constant-source-block-for-zero-contributor-aggregates
[d-144]: decisions.md#d-144--rename-the-computed-exports-helper-faces-to-passthrough
[d-145]: decisions.md#d-145--deduplicate-pass-through-except-lists-with-a-shared-feed-list-idiom
[d-146]: decisions.md#d-146--rename-facesselectors-to-claimsreads-on-the-binding-interface
[d-147]: decisions.md#d-147--split-the-sweep-into-static-interior-and-boundary-variants
[d-148]: decisions.md#d-148--select-converters-per-leaf-by-resolved-condition-shape-type
[d-149]: decisions.md#d-149--check-slot-totality-wherever-a-virgin-world-is-established
[d-150]: decisions.md#d-150--make-the-service-the-sole-authority-on-convergence
[d-151]: decisions.md#d-151--canonicalize-namedtuple-field-order-at-every-authorframework-seam
[d-154]: decisions.md#d-154--remove-per-event-re-decode-serialize-same-component-events
[d-155]: decisions.md#d-155--name-projection-as-the-second-legitimate-mover-of-the-committed-point
[d-156]: decisions.md#d-156--legalize-the-three-degenerate-trimintegration-shapes
[d-157]: decisions.md#d-157--check-for-nonfinite-x-immediately-after-integrate
[d-158]: decisions.md#d-158--pin-the-backend-seam-to-one-required-solve-signature
[d-160]: decisions.md#d-160--rename-report-to-report
[d-162]: decisions.md#d-162--adopt-per-eltype-homogeneous-cell-stores-over-per-instance
[d-164]: decisions.md#d-164--reject-components-that-declare-nothing-and-define-no-stage
[d-168]: decisions.md#d-168--root-slot-fan-out-tolerance-combines-by-meet-not-agreement
[d-170]: decisions.md#d-170--split-assembly-connections-into-childinputoutput-declarations
[d-171]: decisions.md#d-171--rename-passthrough-to-input_passthrough
[d-172]: decisions.md#d-172--rule-face-kind-blind-defined-at-first-use
[d-173]: decisions.md#d-173--fuse-the-discrete-state-letter-z-into-x
[d-174]: decisions.md#d-174--re-class-the-gui-as-an-ordinary-enumerated-writer
[d-176]: decisions.md#d-176--unify-trace-retention-on-one-sparse-record-format
[d-177]: decisions.md#d-177--re-found-the-periphery-on-mandatory-roots-plus-declared-traits
[d-178]: decisions.md#d-178--reaffirm-component-side-rejections-against-the-peripherys-new-idiom
[d-179]: decisions.md#d-179--derive-detection-policy-from-the-guards-return-type
[d-180]: decisions.md#d-180--bank-per-event-direction-as-an-unbuilt-guarded-addition
[d-181]: decisions.md#d-181--replace-once-per-boundary-firing-with-budgeted-re-firing
[d-182]: decisions.md#d-182--add-a-θ0-validation-probe-to-the-localization-trigger
[d-183]: decisions.md#d-183--retire-workspace-poisoning
[d-184]: decisions.md#d-184--fold-group-into-the-spec-as-an-ordinary-library-component
[d-185]: decisions.md#d-185--adopt-the-phased-two-form-sample-time-declaration
[d-186]: decisions.md#d-186--legalize-absolute-declarations-in-any-scope-via-anchors
[d-187]: decisions.md#d-187--make-the-bound-schedule-a-named-artifact-with-exact-grid-diagnostics
[d-189]: decisions.md#d-189--unify-report-on-a-single-address-diagnostic-shape
[d-190]: decisions.md#d-190--reject-a-separate-derivative_type-declaration
[d-191]: decisions.md#d-191--defer-not-consume-the-edge-on-a-blocked-event
[d-192]: decisions.md#d-192--let-the-greedy-claim-empty-the-harness-remainder
[d-193]: decisions.md#d-193--keep-per-writer-liveness-on-one-timestamp-plus-task-state
[d-194]: decisions.md#d-194--retire-the-w-channel-intermediates-are-declared-ports
[d-195]: decisions.md#d-195--give-the-discrete-state-its-own-letter-s
[d-197]: decisions.md#d-197--reject-discrete-stores-in-linearizations-x-tap-list
[d-198]: decisions.md#d-198--promote-the-shutdown-join-timeout-to-a-deployment-keyword
[d-199]: decisions.md#d-199--the-reads-enumeration-returns-a-labeled-namedtuple-of-selectors
[d-200]: decisions.md#d-200--the-harness-writer-has-its-own-cell-and-is-diagnostic-only
[d-201]: decisions.md#d-201--the-terminal-account-closes-at-the-final-frame-top
[d-202]: decisions.md#d-202--stage-batches-as-values-plus-touched-mask-never-union-tuples
[d-203]: decisions.md#d-203--the-termination-record-carries-typed-sources-and-the-tail-residue
[d-204]: decisions.md#d-204--rename-the-condition-algebras-symmetric-combinator-to-combine
[d-205]: decisions.md#d-205--boundary-zero-publishes-every-discrete-output-stage-due-or-not
[d-207]: decisions.md#d-207--route-every-connection-one-level-faces-are-the-only-cross-boundary-currency
[d-208]: decisions.md#d-208--root-inputs-are-the-root-components-input-faces-whatever-its-class
[d-209]: decisions.md#d-209--build-output_passthrough
[d-210]: decisions.md#d-210--tighten-the-input-boundary-class-uniform-face-uniqueness-and-no-empty-routing
[d-211]: decisions.md#d-211--let-a-component-declare-one-container-name-transparent
[d-212]: decisions.md#d-212--refuse-the-transparent-bare-key-that-shadows-a-sibling-container-field
[d-213]: decisions.md#d-213--establish-a-services-frozen-cells-from-the-authored-discrete-state
[d-214]: decisions.md#d-214--split-appendix-cs-severity-column-into-severity-raised-and-policy
[d-215]: decisions.md#d-215--extend-appendix-c-with-the-kinds-the-prototype-raised
[d-216]: decisions.md#d-216--conform-appendix-c-to-the-prototypes-diagnostic-sites
[d-217]: decisions.md#d-217--conform-the-trace-and-replay-sections-to-the-prototypes-record
[d-218]: decisions.md#d-218--make-the-replaylive-distinction-an-explicit-input-mode
[d-219]: decisions.md#d-219--add-a-time-addressed-replay-halt-and-a-manual-door-to-live
[d-220]: decisions.md#d-220--rename-the-authoring-family-to-words-stage-update-projection-event-and-workspace-declarations
[d-221]: decisions.md#d-221--unwrap-a-single-diagnostic-carrier-at-the-runtime-catch-site-into-a-steperror-species
[d-222]: decisions.md#d-222--replace-builderror-with-the-policy-parametric-diagnosticerror-carrier
[d-223]: decisions.md#d-223--host-the-runtime-catch-in-boundary-zero-under-the-services-disposition
[d-224]: decisions.md#d-224--let-a-throw-inside-a-trim-commit-propagate-as-the-commits-steperror
[d-225]: decisions.md#d-225--parametrize-steperror-on-its-causes-type
[d-226]: decisions.md#d-226--reach-the-public-surface-by-qualified-name-until-the-export-audit
[d-227]: decisions.md#d-227--select-the-stepper-by-type-under-the-algorithm-keyword
[d-228]: decisions.md#d-228--attribute-runtime-diagnostics-by-cell-never-by-payload
[d-229]: decisions.md#d-229--collect-to-the-stratum-barrier-under-a-dependency-rule
[d-230]: decisions.md#d-230--stamp-the-snapshot-with-the-trajectorys-boundary-ordinal-not-the-wait-counter
[d-231]: decisions.md#d-231--require-isbits-store-values-checked-at-build
[d-232]: decisions.md#d-232--refuse-the-roster-operations-on-an-errored-simulation
[d-233]: decisions.md#d-233--retire-the-termination-records-absent-time-arm
[d-235]: decisions.md#d-235--realize-the-always-on-check-at-the-generated-write-against-the-cell-type
[d-236]: decisions.md#d-236--type-check-a-wire-by-one-relation-with-embedding-in-stratum-a
[d-237]: decisions.md#d-237--classify-a-non-isbits-immutable-port-type-as-one-opaque-leaf
[d-238]: decisions.md#d-238--decide-embed-accept-on-the-type-lift-the-arrival-compare-exactly
[d-239]: decisions.md#d-239--report-a-typod-return-field-alone-without-the-unproduced-port
[d-240]: decisions.md#d-240--read-the-heartbeat-at-publication-beside-the-task-state
[d-241]: decisions.md#d-241--keep-the-status-a-vector-of-records-one-small-allocation-per-publication
[d-243]: decisions.md#d-243--classify-symbol-as-an-opaque-port-leaf
[d-244]: decisions.md#d-244--refuse-the-write-primitives-of-a-detached-handle-by-name
[d-245]: decisions.md#d-245--classify-a-cycle-cluster-by-a-surviving-traced-cycle-and-carry-each-members-tracing-mode
[d-246]: decisions.md#d-246--diagnose-a-foreign-declaration-binding-as-its-own-fail-fast-kind
[d-247]: decisions.md#d-247--accept-the-namedtuple-as-the-only-store-declaration-form
[d-248]: decisions.md#d-248--frame-every-user-authored-method-the-build-invokes-declarations-included
[d-249]: decisions.md#d-249--settle-three-payload-columns-contract-arity-runtime-time-and-face-routes
[d-250]: decisions.md#d-250--warnings-live-where-the-artifact-criterion-puts-them
[d-251]: decisions.md#d-251--make-the-passthrough-selectors-exclusive-and-warn-on-an-empty-selection
[d-252]: decisions.md#d-252--remove-auto-publishing-two-port-classes-exposed-state-returned-by-stage-1
[d-253]: decisions.md#d-253--stratum-products-as-artifacts-structure-dataflow-events-one-activation-store
[d-254]: decisions.md#d-254--deployment-and-schedule-as-artifacts-between-the-build-and-the-simulation
[d-255]: decisions.md#d-255--run-the-trace-split-and-stoppolicy
[d-256]: decisions.md#d-256--regroup-the-simulations-fields-by-owner
[d-257]: decisions.md#d-257--each-artifact-renders-itself
[d-258]: decisions.md#d-258--schedule-is-the-tick-timing-and-execution-order-the-stage-sequence
[d-259]: decisions.md#d-259--retire-the-strata-the-build-is-three-steps-named-by-their-products
[d-260]: decisions.md#d-260--trim-the-run-to-what-lasts-it-and-retire-the-trace-register
[d-261]: decisions.md#d-261--three-ownership-rules-for-fields-with-the-placements-they-settle
[d-262]: decisions.md#d-262--post-commit-checks-on-the-trim-problem
[d-263]: decisions.md#d-263--one-arity-on-both-tiers-plain-contracts-the-pinned-marker-and-the-mandatory-store
[d-264]: decisions.md#d-264--admit-a-frozen-opaque-leaf-at-a-tolerant-entry
[d-265]: decisions.md#d-265--read-the-pinned-marker-at-the-top-of-an-entry-alone
[d-266]: decisions.md#d-266--two-doors-for-an-ad-opaque-implementation-the-local-rule-and-the-freeze-block
[d-267]: decisions.md#d-267--name-the-leaf-declarations-by-the-bundle-field-they-define
[d-268]: decisions.md#d-268--pause-verbs-on-the-simulation-and-the-interrupts-remaining-windows
[d-269]: decisions.md#d-269--pacings-spellings-and-default-the-waits-consultation-and-the-pacers-home
[d-270]: decisions.md#d-270--fix-the-frameworks-half-of-the-panel-convention-port-views-the-peek-the-orphan-fact
[d-272]: decisions.md#d-272--fix-linearizes-surface-the-tap-set-the-chunk-width-the-operating-point-and-the-return
[d-273]: decisions.md#d-273--a-condition-is-an-initial-condition-capture-leaves-the-algebra
[d-274]: decisions.md#d-274--checkpoints-the-executors-state-as-one-value-restored-without-boundary-zero
[d-275]: decisions.md#d-275--spell-the-exhaustive-activation-mode-as-the-activations-keyword-alone
[d-276]: decisions.md#d-276--address-a-leaf-inside-a-port-value-by-a-dotted-leaf-address
[d-277]: decisions.md#d-277--carry-a-read-sets-mount-chain-and-rebase-every-selector-to-the-root
[d-278]: decisions.md#d-278--refuse-an-empty-at-prefix-at-composition
[d-279]: decisions.md#d-279--name-the-assemblys-boundary-declarations-by-u-and-y-and-shorten-x_derivative
[d-280]: decisions.md#d-280--build-a-dual-activation-of-every-component-in-ci
[d-281]: decisions.md#d-281--guarantee-torn-state-free-lazy-materialization
[d-282]: decisions.md#d-282--give-every-buffer-set-exactly-one-owner
[d-283]: decisions.md#d-283--bind-δt_base-against-anchor-relative-rate-triples
[d-284]: decisions.md#d-284--attribute-grid-refinement-to-every-driver-against-the-actual-pool
[d-285]: decisions.md#d-285--probe-return-checks-hand-down-and-placeholder-sources-and-totalitys-two-homes
[d-286]: decisions.md#d-286--hold-a-pinned-leaf-to-the-exact-check-as-the-schema-visible-freeze
[d-287]: decisions.md#d-287--handler-return-keys-struct-valued-port-embedding-and-the-branchless-payload
[d-288]: decisions.md#d-288--the-executors-structure-phase-bodies-views-construction-the-gate-and-publication
[d-289]: decisions.md#d-289--compile-cost-generated-unrolls-chunks-by-reference-an-unspecialized-declaration-layer
[d-290]: decisions.md#d-290--localizations-exact-detection-left-end-discriminator-endpoint-and-t-boundary
[d-291]: decisions.md#d-291--rate-compilation-the-boundary-gate-phases-and-the-anchor-doctrine
[d-292]: decisions.md#d-292--event-iterations-registers-boundary-zero-prior-visibility-trade-and-budget-exhaustion
[d-293]: decisions.md#d-293--external-readers-observe-the-signal-table-only-at-boundaries
[d-294]: decisions.md#d-294--the-pacers-wait-unmask-point-single-knob-spin-safepoint-and-the-switch-to-pace--inf
[d-295]: decisions.md#d-295--the-walk-clauses-tier-scope-the-obligations-scope-seedability-and-the-unmarked-stores
[d-296]: decisions.md#d-296--abstract-entries-the-record-and-check-doctrine-the-tight-root-bound-and-the-taps-pinning-consumer
[d-297]: decisions.md#d-297--contracts-by-type-seeding-not-typing-one-walk-convention-and-declared-publicity
[d-298]: decisions.md#d-298--container-edges-the-builder-rejection-groups-trade-and-the-directional-two-notation-rule
[d-299]: decisions.md#d-299--rate-scopes-by-type-the-feed-list-doctrine-and-the-helper-pair
[d-300]: decisions.md#d-300--give-group-its-own-rate-scope
[d-301]: decisions.md#d-301--name-a-declaration-by-what-it-returns
[d-302]: decisions.md#d-302--let-a-store-be-the-home-of-any-state-letter
[d-303]: decisions.md#d-303--name-the-connection-declarations-for-wires-and-groups-keywords-for-the-declarations
[d-304]: decisions.md#d-304--the-flat-declaration-the-unchanged-buffer-the-store-field-limits-and-authored-genericity
[d-305]: decisions.md#d-305--the-zero-allocation-invariants-scope-its-grounds-and-its-budgets
[d-306]: decisions.md#d-306--the-workspace-outside-conditions-plans-valid-from-allocation-and-double-buffering-deferred
[d-307]: decisions.md#d-307--keep-authored-continuous-math-generic-over-the-scalar
[d-308]: decisions.md#d-308--keep-integers-enums-and-bools-in-modes-and-the-workspace-out-of-snapshots-and-replay
[d-309]: decisions.md#d-309--record-no-event-firings-and-leave-an-event-firing-stream-a-guarded-addition
[d-310]: decisions.md#d-310--park-the-built-in-gui-run-every-device-spawned-and-withdraw-gui--true
[d-311]: decisions.md#d-311--fold-the-summing-junction-and-the-bool-gates-into-one-generic-junction
[d-312]: decisions.md#d-312--settle-the-leaf-blocks-constant-pins-unitdelay-holds-its-initial-value-freeze-strips-by-broadcast
[d-313]: decisions.md#d-313--admit-a-library-block-by-judgement-against-three-guidelines
[d-314]: decisions.md#d-314--rename-inner_wires-to-local_wires
[d-315]: decisions.md#d-315--hold-the-declared-wiring-on-structure-and-resolve-it-by-function
[d-316]: decisions.md#d-316--stop-requests-are-structural-a-stopflag-port-ends-the-run-unless-the-advance-ignores-it
[d-317]: decisions.md#d-317--split-the-model-from-the-simulation-and-run-only-the-nominal-one
[d-318]: decisions.md#d-318--a-simulation-claims-its-model
[d-319]: decisions.md#d-319--split-the-checkpoint-into-the-models-state-and-the-runs-cursor-and-put-the-services-on-the-model
[d-320]: decisions.md#d-320--admit-only-a-scalar-into-which-float64-embeds-exactly-at-the-model-door
[d-321]: decisions.md#d-321--the-parallel-routes-signal-the-handles-pin-chain-and-the-input-pins-failure-at-the-wire
[d-322]: decisions.md#d-322--no-auto-bubbling-of-unconnected-inputs-and-the-whole-tree-checks-decided-at-the-root
[d-323]: decisions.md#d-323--no-framework-aggregation-mechanism-what-explicit-junctions-buy-and-no-bundled-contributions
[d-324]: decisions.md#d-324--an-unconnected-input-is-a-build-error-with-no-input-defaults
[d-341]: decisions.md#d-341--the-bundle-law-the-closed-name-sets-and-per-key-return-checks
[d-342]: decisions.md#d-342--pure-output-stages-the-dependence-class-names-and-supervisory-resets
[d-343]: decisions.md#d-343--the-remedy-ladders-content-the-closed-loop-remedies-and-the-traces-reach
[d-344]: decisions.md#d-344--the-signal-requirement-immutable-values-and-frozen-references
[d-345]: decisions.md#d-345--the-rule-of-meaning-and-mode-changes-during-a-run
[d-346]: decisions.md#d-346--write-side-port-granularity-and-field-addressed-staging
[d-347]: decisions.md#d-347--evaluating-the-rhs-runs-the-sweep
[d-348]: decisions.md#d-348--the-unit-delays-tier-caveat-and-algebraic-balances-inside-a-component
[d-349]: decisions.md#d-349--the-feedthrough-tracers-modes-reach-and-limits
[d-350]: decisions.md#d-350--output-stages-are-discovered-by-method-existence
[d-361]: decisions.md#d-361--time-and-state-events-and-the-opposite-crossing-direction
[d-362]: decisions.md#d-362--reset-maps-the-continuous-only-mode-store-and-the-rejected-all-in-one-component
[d-363]: decisions.md#d-363--cell-freshness-closed-port-alternatives-write-side-atomicity-and-bulk-data-handles
[d-364]: decisions.md#d-364--hold-a-bulk-data-rig-environment-in-a-constant-source
[d-365]: decisions.md#d-365--narrow-exact-boundary-detection-to-guards-over-modes-root-inputs-and-held-discrete-outputs
[d-366]: decisions.md#d-366--make-loop-the-device-contracts-one-mandatory-function
[d-367]: decisions.md#d-367--replace-the-start-gate-with-spawning-inside-run
[d-368]: decisions.md#d-368--bound-the-snapshot-log-by-count-with-a-finite-default-a-doubling-stride-and-kept-endpoints
[d-369]: decisions.md#d-369--the-diagnostic-channels-rate-limit-drain-take-frozen-status-presentation-and-quiet-frame
[d-370]: decisions.md#d-370--the-greedy-claims-corollaries-for-the-empty-remainder-front-ends-the-harness-surface-and-liveness
[d-371]: decisions.md#d-371--check-binding-sides-both-ways-at-attach-and-keep-the-empty-enumeration-a-degenerate
[d-372]: decisions.md#d-372--make-shutdown-tolerate-a-partially-initialized-device
[d-373]: decisions.md#d-373--dissolve-should_close-and-teach-the-device-loops-two-obligations
[d-374]: decisions.md#d-374--keep-a-dead-device-rostered-guard-mid-run-readers-and-compile-the-drain-against-the-roster
[d-375]: decisions.md#d-375--identify-a-device-by-its-instance-and-admit-it-on-identity-then-claims
[d-376]: decisions.md#d-376--give-the-services-ownership-of-root-input-initial-values
[d-377]: decisions.md#d-377--count-the-snapshot-logs-stride-from-the-runs-first-snapshot
[d-378]: decisions.md#d-378--make-a-claim-what-a-device-may-write-not-what-it-will
[d-379]: decisions.md#d-379--make-the-frames-outcome-a-pure-function-of-the-drained-batches
[d-380]: decisions.md#d-380--accept-the-raw-stick-levels-as-the-traces-known-loss
[d-381]: decisions.md#d-381--make-should_abort-an-attachment-fact-never-a-device-property
[d-382]: decisions.md#d-382--keep-binding-side-traits-trivial-and-the-mappings-the-loops-own
[d-386]: decisions.md#d-386--run-no-framework-task-as-a-thread-monopolist
[d-387]: decisions.md#d-387--reproduce-an-error-by-trace-replay-never-by-resuming-the-simulation
[d-388]: decisions.md#d-388--steps-contract-and-the-authored-re-run
[d-389]: decisions.md#d-389--scope-device-observables-to-the-run-and-keep-stepping-deviceless
[d-390]: decisions.md#d-390--the-harness-writers-read-half-and-steps-duration-spelling
[d-391]: decisions.md#d-391--replay-re-records-keeps-pacing-and-control-and-validates-up-front
[d-392]: decisions.md#d-392--never-re-check-the-thread-budget-per-attach
[d-393]: decisions.md#d-393--let-a-recorded-stop-request-reproduce-its-termination
[d-394]: decisions.md#d-394--the-operator-interrupts-masking-escalation-and-scope
[d-395]: decisions.md#d-395--keep-heartbeat-staleness-loose-the-heartbeat-advisory
[d-396]: decisions.md#d-396--dispose-of-a-failed-device-init-as-an-ordinary-crash-split-on-should_abort
[d-397]: decisions.md#d-397--keep-the-run-field-never-nothing
[d-398]: decisions.md#d-398--the-interrupts-throw-dispositions-and-the-stop-word-cleared-per-run
[d-399]: decisions.md#d-399--record-boundary-zeros-firings-in-the-header-and-make-a-long-run-seekable
[d-400]: decisions.md#d-400--admit-a-systemsleep-coarse-phase-as-a-guarded-addition-for-dedicated-thread-deployments
[d-401]: decisions.md#d-401--call-the-thread-budget-tight-below-the-roster-plus-one
[d-402]: decisions.md#d-402--treat-the-raise-unblock-provokes-as-shutdown-not-a-crash
[d-403]: decisions.md#d-403--read-each-device-tasks-last_seen-off-the-counter-at-spawn
[d-404]: decisions.md#d-404--attach-the-feed-to-the-simulation-as-it-stands-under-replays-restore--false
[d-405]: decisions.md#d-405--spell-the-condition-algebras-leaf-constructor-set
[d-406]: decisions.md#d-406--resolve-a-bindings-reads-through-the-one-read-resolver
[d-407]: decisions.md#d-407--read-the-log-through-the-read-selector-family-as-columns
[d-408]: decisions.md#d-408--discard-a-failed-boundary-and-promote-the-previous-snapshot-to-final
[d-409]: decisions.md#d-409--keep-service-observation-on-the-contract-and-let-inspection-see-everything
[d-410]: decisions.md#d-410--spell-the-component-test-rigs-stub-as-a-constant-holding-the-test-handle
[d-411]: decisions.md#d-411--pin-a-library-block-whose-output-depends-on-neither-state-nor-a-walking-input
[d-412]: decisions.md#d-412--let-the-reason-string-never-the-framework-tell-a-stop-requests-two-uses-apart
[d-413]: decisions.md#d-413--check-for-an-honoured-request-at-an-advances-entry-and-bound-t_end-first
[d-414]: decisions.md#d-414--drop-the-past-generic-refusal-from-the-service-walk
[d-415]: decisions.md#d-415--carry-the-operation-the-current-status-and-the-legal-statuses-in-servicelifecycle
[d-416]: decisions.md#d-416--extend-the-caller-computable-escape-to-environment-queries
[d-417]: decisions.md#d-417--never-let-a-trim-problem-author-the-environment
[d-418]: decisions.md#d-418--match-a-face-selectors-head-against-the-levels-face-list
[d-419]: decisions.md#d-419--refuse-two-taps-at-one-site-and-name-the-tier-of-a-tier-pinned-root-input
[d-420]: decisions.md#d-420--admit-t0-only-beside-about
[d-421]: decisions.md#d-421--translate-the-tolerances-into-each-backend-familys-stopping-language
[d-422]: decisions.md#d-422--refuse-an-inverted-box-and-a-non-positive-tolerance-as-trimprobleminvalid
[d-423]: decisions.md#d-423--raise-a-drifted-condition-shape-as-conditionshapedrift
[d-424]: decisions.md#d-424--limit-a-seeded-tap-to-one-index-step-and-a-float64-leaf
[d-425]: decisions.md#d-425--admit-init-trim-and-linearize-under-about-on-a-model-at-any-status
[d-426]: decisions.md#d-426--record-the-tooling-over-declared-non-participation-unbuilt
[d-427]: decisions.md#d-427--refuse-a-condition-entry-naming-an-internally-wired-input-at-resolution-with-its-producer
[d-428]: decisions.md#d-428--refuse-a-root-input-whose-type-does-not-convert-at-linearizes-default-operating-point
[s1]: #1-introduction
[s10]: #10-time-and-execution
[s10-1]: #101-loop-ownership-the-framework-owns-the-simulation-loop
[s10-2]: #102-the-stepper-seam
[s10-3]: #103-signal-table-consistency-is-a-boundary-property
[s10-4]: #104-localization-mechanics
[s10-5]: #105-multi-rate-tick-scheduling
[s10-6]: #106-event-iteration-at-boundaries-to-quiescence-budgeted
[s10-7]: #107-real-time-pacing
[s11]: #11-runtime-periphery-the-data-plane
[s11-1]: #111-no-shared-mutable-model-staged-writes-snapshot-reads
[s11-2]: #112-outbound-snapshot-publication
[s11-3]: #113-inbound-root-inputs-claims-and-the-frozen-roster
[s11-4]: #114-inbound-per-device-staging-representation-and-the-drain
[s11-5]: #115-inbound-the-input-trace
[s11-6]: #116-devices-one-authoring-contract-no-taxonomy
[s11-7]: #117-the-gui-write-path-port-resolution-peek-staging-contract
[s11-8]: #118-diagnostics-and-liveness-the-per-writer-diagnostic-cell
[s12]: #12-runtime-periphery-lifecycle-and-orchestration
[s12-1]: #121-control-plane
[s12-2]: #122-loop-scheduling-wait-primitive-yields-thread-budget
[s12-3]: #123-the-next-snapshot-wait
[s12-4]: #124-shutdown-protocol
[s12-5]: #125-scripts-and-the-mid-run-mutation-doctrine
[s12-6]: #126-run-lifecycle-and-partial-advance
[s12-7]: #127-replay-the-trace-re-drives-the-ordinary-loop
[s13]: #13-error-discipline
[s13-1]: #131-reporting-policy-collect-the-checks-fail-the-evaluations-fast
[s13-2]: #132-diagnostics-structured-values-one-carrier-exception
[s13-3]: #133-build-primitives-resolve-and-the-face-list-accessors
[s13-4]: #134-runtime-failures-one-catch-site-an-execution-cursor
[s13-5]: #135-termination-is-a-state-not-an-exception
[s13-6]: #136-abnormal-shutdown-one-tail-two-entries
[s13-7]: #137-tooling-consequences-face-routes-and-the-component-library
[s13-8]: #138-cycle-diagnosis-feedthrough-tracing
[s14]: #14-stopped-sim-services
[s14-1]: #141-conditions-are-path-addressed-overlays-on-the-declared-defaults
[s14-10]: #1410-linearization-tap-selectors-one-seeded-pass-a-pure-query
[s14-2]: #142-fragment-composition-locality-without-schema
[s14-3]: #143-resolution-flatten-validate-compile-once
[s14-4]: #144-two-ways-to-apply-a-resolved-condition
[s14-5]: #145-boundary-zero-an-ordinary-boundary-with-authored-incoming-transitions
[s14-6]: #146-root-input-totality-the-missing-value-error-and-the-override-combinator
[s14-7]: #147-the-trim-problem-namedtuple-decisions-declared-reads-named-residuals
[s14-8]: #148-the-trim-service-solver-seam-scratch-stores-commit-and-report
[s14-9]: #149-mounting-problems-as-relocatable-values
[s2]: #2-formalism
[s2-1]: #21-time-and-boundaries
[s2-2]: #22-integration-and-inputs
[s2-3]: #23-events-two-detection-policies
[s2-4]: #24-runs
[s2-5]: #25-exclusions-deliberate
[s3]: #3-component-taxonomy
[s3-1]: #31-continuous-component-the-hybrid-primitive
[s3-2]: #32-periodic-discrete-component
[s3-3]: #33-assembly
[s3-4]: #34-why-two-leaf-classes-not-one-hybrid-primitive
[s4]: #4-ports-and-signals
[s4-1]: #41-immutable-value-semantics
[s4-2]: #42-consumers-see-ports-not-stages
[s4-3]: #43-table-mechanics-and-port-granularity
[s4-4]: #44-function-valued-signals-environment-access
[s5]: #5-evaluation-order-and-feedthrough
[s5-1]: #51-the-ordering-problem
[s5-2]: #52-two-stage-outputs-signatures-bundles-and-the-hand-off-laws
[s5-3]: #53-structural-feedthrough-stage-roles-execution-order-and-step-boundaries
[s5-4]: #54-artificial-loops-and-the-escape-hatch
[s5-5]: #55-algebraic-loop-policy-reject-at-build-time
[s6]: #6-composition-connections-aggregation-and-hierarchy
[s6-1]: #61-connections-and-hierarchy
[s6-2]: #62-aggregation-explicit-summing-junctions
[s7]: #7-state-and-data-representation
[s7-1]: #71-continuous-state-structured-immutable-flat-backing
[s7-2]: #72-numeric-genericity-eltype
[s7-3]: #73-discrete-state-modes-and-workspace
[s7-4]: #74-the-computerintegrator-split
[s8]: #8-the-declaration-layer-components-and-assemblies
[s8-1]: #81-position-a-declarative-trait-layer-in-plain-julia-no-macros
[s8-2]: #82-the-declaration-inventory
[s8-3]: #83-visibility-the-contract-is-the-interface
[s8-4]: #84-failure-walkthroughs-the-error-locality-grounding
[s8-5]: #85-assembly-declaration-type-based-class-by-declaration-shape
[s8-6]: #86-paths-wiring-and-faces
[s8-7]: #87-rate-scopes
[s8-8]: #88-computed-connections-and-generic-holding
[s9]: #9-the-build-pipeline
[s9-1]: #91-the-builds-three-steps
[s9-2]: #92-the-build-and-deployment-artifacts
[s9-3]: #93-probing-and-input-synthesis
[s9-4]: #94-activations-executable-sets-laziness-caching
[s9-5]: #95-the-always-on-conformance-check
[s9-6]: #96-stopped-sim-services-as-activation-clients
[s9-7]: #97-the-compiled-executor
[s9-8]: #98-allocation-policy-a-scoped-invariant
[sA]: #appendix-a-taught-contracts-the-author-facing-index
[sB]: #appendix-b-api-synopsis-the-entry-points
[sC]: #appendix-c-the-diagnostic-kind-set
[sD]: #appendix-d-glossary
[sD-1]: #d1-component-model-and-declaration-layer
[sD-4]: #d4-time-and-events
[sD-5]: #d5-build-pipeline
[sD-6]: #d6-runtime-periphery
[sD-8]: #d8-stopped-sim-services-and-the-condition-algebra
[sD-9]: #d9-error-discipline-and-diagnostics

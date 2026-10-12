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
  allocates nothing, and CI asserts it ([§7.5][s7-5], [§9.7][s9-7]).
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
  design's `f` also receives the published table, and the composite map from
  `x` to $\dot{x}$ is mathematically identical to the textbook form's ([§5.3][s5-3]).
- Multi-rate periodic discrete dynamics. $s^{+} = g(s, u, t)$ at declared
  rates, with outputs held zero-order ([D-019][d-019]) between
  [ticks](#g-tick) (instants at which a discrete component's stages and update
  run).
- Zero-crossing events. [Guard](#g-guard) functions (each defining an event's
  predicate) with handlers, under two detection policies, stated below.
- Post-step manifold [projection](#g-projection). **The formalism includes an
  optional per-[component](#g-component) hook, `x ← x_projection(x)`**
  ([D-001][d-001]). It is applied after each accepted step and after any
  handler reset of `x` ([§5.3][s5-3]). It covers quaternion renormalization,
  direction cosine matrix (DCM) orthonormalization and any other
  manifold-valued state. It is the cheap end of the projection-methods family
  from geometric integration.
- External inputs. The runtime injects them asynchronously, from pilot
  controls or the network, under the staging rules of [§11][s11]
  ([D-022][d-022]).

[§2.1][s2-1] gives the two event-detection policies, and [§2.2][s2-2] the
exclusions taken deliberately.

### 2.1 Events: two detection policies

**Events have two detection policies** ([D-001][d-001]). Both policies share
one declaration, a [guard](#g-guard) function plus a handler ([D-179][d-179]).
Only detection differs.

**A guard defines a [predicate](#g-predicate)** ([D-082][d-082],
[D-001][d-001]). It does so in one of two forms, either a `Bool`-valued form or
the sign of a continuous function under the normative convention positive =
predicate holds. Writing the guard's sign value `σ`, holding means `σ ≥ 0`.

**An event fires when its predicate transitions from not-holding to holding**
([D-082][d-082], [D-001][d-001]). This is
[edge semantics](#g-edge-semantics), and it is uniform across both forms.
[§10.6][s10-6] states the bookkeeping of the [prior](#g-prior), each event's
predicate sample stored at the previous [boundary](#g-boundary) (a published
consistency point). The opposite crossing
direction is declared as a second event with the negated guard
([D-082][d-082]). Stall entry and exit are one such pair. A per-event
`direction` keyword is recorded as a
[guarded addition](#g-guarded-addition) (a capability recorded with its shape
so adoption stays additive), unbuilt ([D-180][d-180]).

Which form an author declares is not a free choice. The guard's return type is
the declared policy. A `Bool` return declares
[boundary-detected](#g-boundary-detected), and the sign form declares
[localized](#g-localized) ([D-179][d-179]). [§10.4][s10-4] states the rule,
the exactness result that motivates the `Bool` form, and the gate idiom for
localizing mixed predicates. The two policies follow.

- Boundary-detected (cheap). The framework checks each guard for a
  not-holding → holding edge against its prior ([§10.6][s10-6]) at step
  boundaries only. There is no
  root-finding and no step rejection. The handler fires at the end of the step
  in which the edge was observed. The cost is one guard evaluation per event
  per iteration round ([§10.6][s10-6]). This policy is fully compatible with
  fixed-step real-time execution.
- Localized (precise). The framework finds the crossing instant by
  root-finding ([D-018][d-018]). This policy serves events where timing
  precision genuinely matters. [§10.4][s10-4] gives the mechanics.

Detection policy never depends on real-time [pacing](#g-pacing)
([§10.7][s10-7], [D-080][d-080]). The pacer inserts waits between completed
frames and never alters the boundary sequence.

This arrangement gives step-boundary logic *well-defined semantics*. The
crossing defines the transition ([D-179][d-179]). Detection resolution is an
execution-policy detail.

Time events and state events differ in how their instants are found. **The
discrete [tier](#g-tier)'s [ticks](#g-tick) are [time events](#g-time-event)**
([D-220][d-220]). Ticks are declared by `sample_times`. Their instants are known
in advance and scheduled ([§10.5][s10-5]). Everything declared through
`StateEvent(guard, handler)` is a [state event](#g-state-event). Its instant is
unknown and must be detected, by boundary check or by localization. That is why
the declaration is named `state_events` ([§8.2][s8-2], [D-220][d-220]). The
criterion is detection versus scheduling, not which fields a guard reads. A
guard over an input is still a state event.

### 2.2 Exclusions (deliberate)

**The formalism deliberately excludes three constructs** ([D-001][d-001]).

- No differential-algebraic equations (DAEs) or algebraic constraints. The
  actual need is state manifolds, and [projection](#g-projection), the optional
  per-component hook `x ← x_projection(x)`, covers it ([D-001][d-001]).
- No stochastic differential equations (SDEs) or stochastic integrators. Noise
  processes, such as sensor noise and turbulence from Dryden/von Kármán
  turbulence models, are modeled as shaping filters ([D-001][d-001]), that is,
  as ordinary discrete processes driven by a random number generator (RNG).
  That modeling is
  faithful to how the noise processes are specified, and it is cheap. One
  consequence is elevated to a framework guarantee, deterministic
  [replay](#g-replay) (re-running the ordinary loop on a recorded input trace).
  RNG state lives in [component](#g-component) discrete state `s`, never in
  ambient globals, so the same seed gives a bit-identical trajectory
  ([D-231][d-231]).
- No unconditional per-step hook, because its semantics depend on the step
  size ([D-001][d-001]). So there is no equivalent of `f_step!`, FlightCore's
  per-step hook. Every current use of `f_step!` decomposes into one of two
  mechanisms. Projection covers quaternion renormalization.
  [Boundary-detected](#g-boundary-detected) events (checked for edges at step
  boundaries only, no root-finding) cover engine phase transitions and the
  stall hysteresis latch. For one group of uses the mapping tightens
  semantics. Level-triggered cross-component resets become edge-triggered
  events. Flight.jl resets the gear's friction regulator while `!wow` (no
  weight on wheels) holds; here that reset becomes an event on the touchdown
  edge ([§5.3][s5-3], [D-001][d-001], [D-141][d-141]).

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
  flags) that parametrize the [flow](#g-flow) and change *only* through event
  handlers.
- Flow $\dot{x} = f(x, m, u, t)$.
- Two output stages ([§5.2][s5-2]).
- Events, each a [guard](#g-guard) (the declared function defining an event's
  predicate) plus a handler. A handler may update `m` and may reset the
  component's own `x` ([D-090][d-090]). Both guard and handler read the fresh
  [boundary](#g-boundary) [signal table](#g-signal-table) ([§5.3][s5-3],
  [D-154][d-154]).
- An optional [projection](#g-projection) (the per-component hook
  `x_projection`).

Any facet may be empty. In particular, a [component](#g-component) with *no*
continuous state, only modes, events and mode-valued outputs, is a finite-state
machine (FSM). **A single primitive supports both factorings of mode logic**
([D-003][d-003]).

- Internal modes suit tightly coupled cases, such as stall hysteresis inside
  the aero component. They preserve cohesion and enable reset maps
  ([D-003][d-003]).
- An external FSM component feeding modes through a [port](#g-port) (the
  addressable unit of the model) gives maximal
  purity, independent testability and swappable supervision logic.

The rule of meaning separates a command from a detection. A supervisor
*commanding* a mode change is an ordinary input. A component *detecting* its
own transition is an event. The two mechanisms carry two meanings and do not
overlap. On the continuous [tier](#g-tier), a commanded reset of state, whose
condition arrives as an input, still lands through an event whose guard reads
that input ([§5.3][s5-3], [D-141][d-141]).

### 3.2 Periodic discrete component

A periodic discrete component has these facets.

- Discrete state `s`, a NamedTuple whose fields are each isbits or a `Symbol`
  ([§7.3][s7-3], [D-231][d-231], [D-247][d-247]).
- Update $s^{+} = g(s, u, t)$ at a declared rate.
- Two output stages, with [feedthrough](#g-feedthrough) (an instantaneous
  input→output dependence) applying at update instants. A proportional path is
  direct feedthrough. A state-only output is not.

**Each [tier](#g-tier) carries its own state letter** ([D-195][d-195]). `x` is
the argument of the [flow](#g-flow) map under `f`, and `s` is the argument of
the jump map under `g`. The two are different objects. `x` has a derivative and
lives in the flat [buffer](#g-buffer). `s` has none and is latched in a
[store](#g-store) (the framework-owned home of a state letter) between
[ticks](#g-tick). Nothing is lost by splitting the letter, because a leaf is
strictly one tier ([D-056][d-056]) and no [component](#g-component) ever reads another's
state. A discrete component's `s` influences continuous dynamics only through
signals ([D-056][d-056]). Those outputs are held zero-order between ticks
([D-019][d-019]).

**`m` is continuous-only** ([D-231][d-231], [D-249][d-249]). A discrete
component has no mode store. Its finite-state machine (FSM) enums, flags and
counters are ordinary `s` fields. `m` exists on the continuous side because
modes must change *between* flow evaluations, which is what handlers do. On the
discrete side `g` already runs at the only instants at which anything may
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


### 3.4 Why two leaf classes, not one hybrid primitive

This section asks why there are two leaf classes at all. One all-in-one
primitive could carry continuous state, modes *and* discrete state, with
`x_deriv`, events *and* `s_update`. A purely continuous or discrete
[component](#g-component) would then fall out of whichever facets an author
declares. A component's [class](#g-class), its primitive-vs-assembly status,
is already read off declaration shape ([§8.5][s8-5]). So the question is
whether the two declaration sets should be exclusive. They are
([D-056][d-056], [D-263][d-263]).

**The split is between *time bases*, not state classes** ([D-056][d-056]).
The [continuous component](#g-continuous-component) is already hybrid. It
carries modes `m`, [guards](#g-guard) (functions that define an event's
predicate) and handlers ([§3.1][s3-1]). What separates the two leaf classes is
[sweep](#g-sweep)-driven versus [tick](#g-tick)-driven execution. A sweep is
one pass through the execution order against the current state. A tick is an
instant at which a discrete component's stages and update run.

The settled rules force a merged component's two halves to communicate exactly
as two siblings do ([D-056][d-056]). There is
[one home per datum](#g-one-home-per-datum) (no store mirrors another,
[§5.2][s5-2]). `x_deriv` sees only the continuous state, and `s_update` only
the discrete one. And `s⁺` is decoded only at the owner's next tick, because
`s_update` runs last. That deferred decode is what makes ticks→events
structurally impossible ([D-020][d-020]). It is also what terminates the
iteration at each [boundary](#g-boundary) (a published consistency point,
[§10.6][s10-6]). Influence across [tiers](#g-tier) (the continuous and
discrete sides of the formalism) inside a merged component still routes
through published table [cells](#g-cell) (typed entries of the signal table,
[D-056][d-056]).

The all-in-one component is therefore an [assembly](#g-assembly) of two
primitives in a trench coat ([D-056][d-056]). An assembly is a component of
pure composition. The all-in-one component buys no expressiveness. It incurs
costs of its own, which [D-056][d-056] enumerates. One of those costs is not
bookkeeping. The sampling interface is the zero-order hold (ZOH) plus the
one-sample `z⁻¹` delay. It is the most bug-prone boundary in a flight-control
stack. A monolith swallows it. The split keeps it a visible wire.

#### The hardest case: integrate-and-dump

A strapdown inertial measurement unit (IMU) is the strongest challenge
mounted against the split. The IMU's direct formulation integrates raw
increments continuously, as `ẋ.ϑ_c = ω_ic_c`, `ẋ.υ_c = f_c_c`, the coning
attitude increment `q_c_cc` and the sculling integral
`ẋ.υ_c_sc = q_c_cc(f_c_c)`. Then, at the IMU's own `Δt`, a discrete step
reads the integrals, publishes the sample, and *zeroes them*. [§8.6][s8-6]
spells this IMU in full.

In interval terms, these piecewise quantities are integrals over
$[t_{k-1}, t_k]$ with their weights re-anchored at each reset. `ϑ_c`
$= \int_{t_{k-1}}^{t_k} \omega^{c}_{ic} \, dt$ and `υ_c`
$= \int_{t_{k-1}}^{t_k} f^{c} \, dt$ run from zero, `q_c_cc`
$= q_{c_{k-1} \to c(t)}$ runs from identity, and `υ_c_sc`
$= \int_{t_{k-1}}^{t_k} R^{c_{k-1}}_{c} f^{c} \, dt$ has its rotation
anchored at the interval start. The differencing idiom of [§8.6][s8-6]
recovers exactly these forms from the cumulative stores, term by term.

The reset is periodic, not condition-triggered, so events are the wrong
mechanism ([D-056][d-056]). And the reset is a discrete-tier write into
continuous state, exactly the operation this design forbids ([D-056][d-056]).
`s_update` writes only its own `s`. Guard-driven handlers are the sole
resetters of continuous state ([D-141][d-141]). Integrate-and-dump falls
squarely into the crack between the two leaf
classes. It is tightly coupled continuous
and periodic dynamics in one physical instrument.

Algebra removes the reset ([§8.6][s8-6]). Every interval-relative integral
becomes a cumulative one, and a discrete sampler differences consecutive
samples against its latch ([D-056][d-056]). [§8.6][s8-6] spells that idiom,
its exactness condition and the resulting assembly in full.

The strongest counterexample landed on the two-class taxonomy with *less* code
than the direct formulation. It keeps the same thirteen integral scalars and
the same math, minus the reset block. It brings three structural gains. First,
the sampling interface became a wire. Second, the error model became a
discrete sibling, which makes the truth/corrupted sample pair separately
loggable ([§8.6][s8-6]). Third, linearization got sane. `Dual` is
ForwardDiff's dual number. Under a `Dual`
[activation](#g-activation) (the build's typed products at a given scalar
type) the discrete tier is held ([§8.2][s8-2]). And "integrators that never
reset" *is* the cumulative formulation. The framework's rules pushed the IMU
into the only form that the framework's own linearization semantics could
coherently handle.

**The one recorded, unbuilt escape hatch is a tick-triggered handler on
continuous components** ([D-056][d-056]). Such a handler is a periodic event.
It is a [guarded addition](#g-guarded-addition) (a capability the design
admits but does not build), for use if interval-relative dynamics ever
neither factor algebraically nor tolerate the latch-back wire. In that wire,
the integrals consume the sampler's published latch ([§8.6][s8-6]). No known
case needs the escape hatch ([D-056][d-056]).

---


## 4. Ports and signals

This chapter gives the port, the addressable unit through which components
exchange immutable values. [§4.1][s4-1] states the immutable value semantics of
signals; [§4.2][s4-2] why consumers see ports, not stages; [§4.3][s4-3] the table
mechanics and port granularity; and [§4.4][s4-4] function-valued signals for
environment access.

### 4.1 Immutable value semantics

**[Ports](#g-port) exchange immutable values** ([D-004][d-004]). The values are
typically isbits structs (floats, `SVector`s, enums, nested immutables). The
framework owns a [signal table](#g-signal-table), with one concretely typed
[cell](#g-cell) per output port in the flattened model. Every
[component](#g-component) provides two output stages ([§5.2][s5-2]),
`y_state`/`y_direct`, on either [tier](#g-tier) (the continuous or discrete
side of the hybrid formalism). A producer's output [stage function](#g-stage-function) returns a
named tuple of fresh values. The framework writes each of those values into its
cell, and consumers read cells.

These names are binding throughout this document.

- **A bare *cell* is the table entry, and only that** ([D-121][d-121]).
- A *[store](#g-store)* is the framework-owned home of one of a component's
  state letters, `x`, `s` or `m` ([§7.1][s7-1], [§7.3][s7-3], [D-302][d-302]).
  An `x` store is a range of the [buffer](#g-buffer) (the contiguous vector
  backing all continuous state). Stores are not cells.
- A *[staging cell](#g-staging-cell)* is a distinct compound term
  ([D-121][d-121]). It is the inbound register of [§11.4][s11-4], one per
  [device](#g-device) (any attached participant outside the loop, such as the
  GUI). Unlike a table cell it is mutated frame by frame, and it sits
  outside the table's publish-once discipline.
- A *[root input](#g-root-input)* is a source cell fed by the
  [periphery](#g-periphery) (everything outside the loop that exchanges data
  with it) rather than by a producer ([§11.3][s11-3]).

Stated precisely, **the signal requirement is immutability plus frozen
references** ([D-243][d-243]). Signals may reference bulk data
([§4.4][s4-4]) provided that data is read-only for the duration of the run
([D-231][d-231]). `isbits` is the common case, not the rule.

The signal requirement has four consequences.

- There is no aliasing, ever. Nothing can be mutated under a consumer's feet.
- Concurrent reads from the GUI and logging threads are safe by construction.
- Isbits payloads allocate nothing, because named tuples of isbits are isbits.
- Each cell has a definite freshness, tied to its producer's position in the
  [execution order](#g-execution-order), the order in which the stage
  functions run ([D-004][d-004]).

### 4.2 Consumers see ports, not stages

The [port](#g-port) is the addressable unit. A [component](#g-component)'s
outputs appear to consumers, the GUI and logs as one flat namespace of ports,
such as the illustrative paths `"dyn/vel"` and `"dyn/f_c_c"` ([D-040][d-040]). A reader reaches a leaf
inside a port value through the port's [leaf address](#g-leaf-address) (the
field name with dotted and bracketed steps below it, [§14.4][s14-4],
[D-276][d-276]). Which output stage computes which port is an ordering
annotation, invisible outside the component. Moving an output between stages is
non-breaking *for consumers*. No wire, log or panel sees it. The build does see
it, because the [feedthrough](#g-feedthrough) graph (the graph of instantaneous
input→output dependences) and stage membership change ([§9.1][s9-1]).

Which ports exist at all is a declaration-layer decision. The output
[contract](#g-contract) (the ports a component declares in `y_types`) *is* the
public interface ([D-034][d-034]). There are no private intermediates. A value
a later function needs is a declared port like any other ([§5.2][s5-2], [D-194][d-194]). A
stage result outside the contract is a build error (`UndeclaredReturnField`,
[§8.3][s8-3]). A presentational *unlisted* flag, skipped in logs
and GUI but still connectable, is closed ([D-016][d-016], [D-034][d-034]).

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
never creates an endpoint. The distinction is class-blind ([D-172][d-172]).
Wiring and the [periphery](#g-periphery) (everything outside the loop that
exchanges data with it) address a child's faces without knowing whether it is
primitive or composite.

The port is the atomic unit of the entire periphery. It is each of the
following.

- One cell.
- One [root input](#g-root-input) (a source cell the periphery feeds).
- One staged write.
- One [device](#g-device) [claim](#g-claim) (the set of faces a device may
  write, [§11.3][s11-3]).
- One [trace](#g-trace) address (the trace is the primary record of a
  session).
- One GUI liveness verdict ([§11.7][s11-7]).

#### Scatter and gather

Scatter/gather is the whole protocol. A [stage function](#g-stage-function)
(`y_state`/`y_direct`) returns a named tuple on either [tier](#g-tier),
continuous or discrete. The framework scatters each field into that port's
concretely typed cell. Every reader gathers views from cells. The readers are
the next stage, `x_deriv`/`s_update` ([§5.2][s5-2]), [guards](#g-guard), wired consumers and
[snapshot](#g-snapshot) capture. A guard is the function defining an event's
predicate, and the snapshot is the immutable per-boundary publication.

**The aggregate `y` is a merge semantically and virtual physically**
([D-036][d-036]). Semantically, a component's `y` is the merge of its stage
products, `merge(y_x, y_xu)` on the continuous tier and `merge(y_s, y_su)` on
the discrete ([§5.2][s5-2]). It carries declared ports only. Physically no such
object exists. `y` is reconstructed per call from cells, as register-level
field loads at zero cost for isbits, and is never stored as an object.

Name collisions across a component's stages are a build error
(`ProducedByTwoStages`, [§8.3][s8-3]).

#### What a port may hold

**Stage returns are named tuples of port values, period** ([D-036][d-036]).
**A custom struct is a first-class port value** ([D-036][d-036]). It is one
field of the returned tuple, one declared port, one cell
(`pose = KinPose{T}`, where `KinPose` is an illustrative struct). Nested
fields get no cells of their own. A reader reaches a nested field through the
port's [leaf address](#g-leaf-address) (the field name with dotted and
bracketed steps below it), as in `"pose.q_eb"` ([§14.4][s14-4], [D-276][d-276]). A wired
consumer takes the bundle (the struct-valued port) whole. Bare-struct returns
are rejected ([D-036][d-036]).

A port value's leaves are what the [leaf walk](#g-leaf-walk) (the framework's
derivation of per-activation types) reaches through `Real`s, static arrays and
isbits structs ([D-237][d-237]). An enum is one leaf, pinned ([§8.2][s8-2],
[D-316][d-316]). `StopFlag` is the one enum with a framework meaning. An
output port of that type is a [stop request](#g-stop-request) (a port that ends the run when it
reads `STOP_REQUESTED`), and a `StopFlag` nested in a port of another type or
declared as a root input is refused (`IllegalPortType`, [§13.5][s13-5],
[D-316][d-316]).

**The walk stops at an immutable type that is not isbits and treats it as one
opaque leaf** ([D-237][d-237]). The table stores an opaque leaf whole,
references included. A [field handle](#g-field-handle) (an immutable query
object a consumer evaluates at arguments of its own choosing, [§4.4][s4-4]) is
such a leaf. **A `Symbol` is an opaque leaf too** ([D-243][d-243]). Julia
classifies it mutable, but it is interned, immutable and never freed, the
grounds on which [§7.3][s7-3] admits it in a store. So a `Symbol` mode
publishes like any other. **A mutable type anywhere in a port value is
refused, and so is an opaque leaf surfacing as a root input**, which has no
synthesis (`IllegalPortType`, [D-237][d-237]).

#### Granularity, read side

**Wiring is port-granular** ([D-276][d-276]). There are no sub-field
connections. A consumer that wants less than a bundle takes the bundle and
destructures it, or asks the producer for a loose port ([D-276][d-276]). It
destructures the bundle in its own stage or through an unbundling component.
An unbundling component is a `y_direct` leaf that takes the bundle and
publishes its fields. It is a candidate for the standard library of [§13.7][s13-7].

A field-projection connector is a [guarded
addition](#g-guarded-addition) (a capability the design admits but does not
build) ([D-036][d-036]). Its shape is obvious, and it is not built.

Under the granularity guideline, **authors should bundle what shares a stage
*and* is consumed together** ([D-036][d-036]). The first criterion is trivially
enforced, because each port has exactly one producing function. Bundling
across dependency footprints is the classic mistake. A kinematics bundle
mixing pose, which is stage 1 ([§5.2][s5-2]), with velocity-derived
quantities, which are stage 2, must split.

Fan-out is free, so publishing both a bundle and a hot loose field (`pose`
*and* `q_eb`) is legitimate. It costs one extra isbits cell.

The sketch below shows the bundle, the loose hot field and a face aliasing an
interior port, in declaration form. `Kinematics` and `Vehicle` are
illustrative names, and `KinPose` is the illustrative struct above. An `output_wires` entry
sources a face from an immediate child's face ([§6.1][s6-1]). `RQuat` is
FlightPhysics' rotation quaternion. `RQuat{Float64}` is the spec's form of it,
since FlightPhysics' `RQuat` takes no type parameter.

```julia
#a continuous leaf: one bundle port and the hot field published loose — two cells
y_types(::Kinematics) = (pose = KinPose{Float64}, q_eb = RQuat{Float64})

#the enclosing assembly: each face aliases an interior port, creating no endpoint
output_wires(::Vehicle) = ("kin/pose" => "pose", "kin/q_eb" => "q_eb")
```

#### Granularity, write side

Under the write-side rule, **data written by different external writers, or
at different cadences, must not share a port** ([D-045][d-045]). In short,
bundle what is written together.

Pilot commands are the case in point. They are scalar faces under a namespace
prefix. The convenient bundle is assembled *downstream*, inside the graph, by
an ordinary component. Assembling it there is legal by the read-side
guideline, since the bundle has a single producer and is consumed together.

The granularity guideline and the write-side rule compose into one principle.
The finest-grained party owning either end sets a port's granularity. That
party is a producer on the read side and an external writer on the write side.
Field-addressed staging (a lens into struct slots) stays a recorded guarded
addition, unbuilt.

### 4.4 Function-valued signals: environment access

Atmosphere and terrain are query-shaped. Consumers evaluate them at arguments
of their own choosing, such as each gear strut at its own contact point, or
airflow at the vehicle pose. **Ordinary [ports](#g-port) carry them as immutable query objects** (a port
is one declared name with its cell), called [field handles](#g-field-handle),
because of that shape ([D-008][d-008]).

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
  undulation grid (the geoid's height above the reference ellipsoid). Handles
  are rebuilt per evaluation without allocation, as immutable structs holding
  existing references. They are never `Ref`s, whose mutable box allocates.
- A field object must hold no mutable cache, such as a memoizing interpolator
  or a lazy loader. Concurrent consumers and the GUI thread would race on it.
  Caches belong in the consumer's state, or the interpolant is restructured to
  be pure.
- Loggers treat field-handle signals specially. They skip or summarize them.

#### The value-level constructor

**Every field-emitting component must expose the map (component, input values)
→ handle as a plain, pure, public function**, its
[value-level constructor](#g-value-level-constructor) ([D-139][d-139]). For the
successor of FlightPhysics' `SimpleAtmosphere`, that function is
`atmospheric_field(atm; T_sl, p_sl, wind)`. The field-emitting component's
[swept](#g-sweep) output stage (run by a sweep, one pass through the
execution order) must be a one-line call to that function, never the other way
round. The other way round puts the query math in the output stage, where only
a sweep can reach it.

The reason is script-side. The condition math of [§14.1][s14-1] must be able
to construct, outside any sweep, bit-for-bit the same handle the sweep would
produce from the same values of the [root inputs](#g-root-input) (the inputs
no component produces). One implementation serves two call sites, so there is
no drift. The drift avoided here is the silent drift that [§5.3][s5-3] exists
to kill. The value-level constructor is a *shipped component's obligation*,
not something a consumer can retrofit. The real component composes environment
sub-models, and anyone else reconstructing the map has re-created that drift.

For bulk-data components the obligation is only that the query math be
reachable as a plain function ([D-139][d-139]). They own their resource
loading, so building a handle outside a build may cost a load. That cost is
acceptable, because condition authoring is design-time code.

The sketch below shows the map as a plain function, and the stage that does
nothing but call it.

```julia
#the map: plain, pure, public — callable outside any sweep
atmospheric_field(atm; T_sl, p_sl, wind) = ISAField(…)

#the swept output stage: one line, nothing but the call
y_direct(atm, args) = (; … = atmospheric_field(atm; T_sl = …, p_sl = …, wind = …))
```

#### Pre-sampling and substitutability

Pre-sampling is an idiom built on top, used where natural, not a separate
mechanism ([D-008][d-008]). In it, a component consumes the field and a pose
and emits plain data, as an illustrative `Airflow` component emits
FlightPhysics' `AirData` for the whole vehicle. Resource injection
(declare-and-resolve service registries) is closed for the first cut
([D-008][d-008]).

The field-handle mechanism replaces Flight.jl's threading of
`atmosphere`/`terrain` as arguments through every update signature. Flight.jl's
landing-gear model finds contact through a bounded ray query to the terrain
model, the query a terrain field handle's `ray_intersect` serves. Substitutability
behind a stable [face](#g-face) (the name a port wears on its component's
boundary) is declared with an
[abstract input entry](#g-abstract-entry), here the illustrative
`terrain = AbstractTerrainField`. That is structural substitutability
([§8.2][s8-2], [D-296][d-296]). The consumer wires to any concrete field type
below the bound ([D-078][d-078]). That preserves FlightPhysics' `AbstractTerrain`
polymorphism at the declaration layer.

---


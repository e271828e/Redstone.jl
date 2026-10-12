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

## 2. Formalism

The framework simulates **[hybrid causal systems](#g-hybrid-causal-system)**. Such a system has five parts.

- **Continuous dynamics.** $\dot{x} = f(x, m, u, t)$ with algebraic outputs.
- **Multi-rate periodic discrete dynamics.** $s^{+} = g(s, u, t)$ at declared
  rates, with outputs held zero-order between [ticks](#g-tick).
- **Zero-crossing events.** [Guard](#g-guard) functions with handlers, under two detection
  policies, stated below.
- **Post-step manifold [projection](#g-projection).** An optional per-[component](#g-component) hook `x ←
  x_projection(x)`, applied after each accepted step. It covers quaternion
  renormalization, DCM orthonormalization and any other manifold-valued state.
  It is the cheap end of the projection-methods family from geometric
  integration.
- **External inputs.** The runtime injects them asynchronously, from pilot
  controls or the network, under the staging rules of [§11][s11].

### 2.1 Events: two detection policies

Both policies share one declaration, a [guard](#g-guard) function plus a handler. Only
detection differs.

- **[Boundary-detected](#g-boundary-detected) (cheap).** The framework checks each guard for a
  not-holding → [holding](#g-edge-semantics) edge against its [prior](#g-prior) ([§10.6][s10-6]) at step [boundaries](#g-boundary) only.
  There is no root-finding and no step rejection. The handler fires at the end
  of the step in which the edge was observed. The cost is one guard evaluation
  per event per step. This policy is fully compatible with fixed-step real-time
  execution.
- **[Localized](#g-localized) (precise).** The framework finds the crossing instant by
  root-finding. This policy serves events where timing precision genuinely
  matters. [§10.4][s10-4] gives the mechanics.

Detection policy never depends on real-time [pacing](#g-pacing) ([§10.7][s10-7]).

**Time events and state events.** The discrete [tier](#g-tier)'s [ticks](#g-tick), declared by
`sample_times`, are [time events](#g-time-event). Their instants are known in advance and
scheduled ([§10.5][s10-5]). Everything declared through `StateEvent(guard, handler)` is a
[state event](#g-state-event). Its instant is unknown and must be detected, by boundary check or
by localization. That is why the declaration is named `state_events` ([§8.2][s8-2]). The
criterion is detection versus scheduling, not which fields a guard reads. A
guard over an input is still a state event.

This arrangement gives step-boundary logic *well-defined semantics*. The
crossing defines the transition. Detection resolution is an execution-policy
detail.

A guard defines a **[predicate](#g-predicate)**. It does so in one of two forms, either a
`Bool`-valued form or the sign of a continuous function under the normative
convention **positive = predicate holds**. Writing the guard's sign value `σ`,
holding means `σ ≥ 0`.

An event fires when its predicate transitions from not-holding to holding. This
is [edge semantics](#g-edge-semantics), and it is uniform across both forms. [§10.6][s10-6] states the prior
bookkeeping. The opposite crossing direction is declared as a second event with
the negated guard. Stall entry and exit are one such pair.

Which form an author declares is not a free choice. **The guard's return type is
the declared policy.** A `Bool` return declares boundary-detected, and the sign
form declares localized ([D-179][d-179]). [§10.4][s10-4] states the rule, the exactness result
that motivates the `Bool` form, and the gate idiom for localizing mixed
predicates.

### 2.2 Exclusions (deliberate)

- **No DAEs / algebraic constraints.** The actual need is state manifolds, and
  [projection](#g-projection) covers it ([D-001][d-001]).
- **No SDEs / stochastic integrators.** Noise processes such as Dryden/von
  Kármán turbulence and sensor noise are modeled as ordinary RNG-driven discrete
  processes, that is, shaping filters. That modeling is faithful to how they are
  specified, and it is cheap. One consequence is elevated to a framework
  guarantee, **deterministic [replay](#g-replay)**. RNG state lives in [component](#g-component) discrete
  state (`s`), never in ambient globals, so the same seed gives a bit-identical
  trajectory.
- **No unconditional per-step hook**, so no `f_step!` equivalent. Every current
  use decomposes into one of two mechanisms. Projection covers quaternion
  renormalization. [Boundary-detected](#g-boundary-detected) events (checked for edges at step
  boundaries only, no root-finding) cover engine phase transitions and the stall
  hysteresis latch. For one class the mapping tightens semantics.
  Level-triggered cross-component resets become edge-triggered events. The gear
  friction regulator under `!wow` is one such reset ([§5.3][s5-3], [D-001][d-001]).

---

## 3. Component taxonomy

There are three classes. Two of them are leaves with crisp, closed semantics,
and one is pure composition.

### 3.1 Continuous component (the hybrid primitive)

A continuous component is a classical hybrid automaton. It has these facets.

- **Continuous state** `x`, an isbits struct of real scalars ([§7][s7]).
- **Mode variables** `m`. These are piecewise-constant values (enums, integers,
  flags) that parametrize the [flow](#g-flow) and change *only* through event handlers.
- **Flow** $\dot{x} = f(x, m, u, t)$.
- **Two output stages** ([§5.2][s5-2]).
- **Events**, each a [guard](#g-guard) plus a handler. A handler may update `m` and may
  reset the component's own `x`. Both guard and handler read the fresh [boundary](#g-boundary)
  [signal table](#g-signal-table) ([§5.3][s5-3]).
- An optional **[projection](#g-projection)**.

Any facet may be empty. In particular, a [component](#g-component) with *no* continuous state,
only modes, events and mode-valued outputs, is an FSM. A single primitive
therefore supports both factorings of mode logic.

- **Internal modes** suit tightly coupled cases, such as stall hysteresis inside
  the aero component. They preserve cohesion and enable reset maps.
- An **external FSM component** feeding modes through a [port](#g-port) gives maximal
  purity, independent testability and swappable supervision logic.

**Rule of meaning.** A supervisor *commanding* a mode change is an ordinary
**input**. A component *detecting* its own transition is an **event**. The two
mechanisms carry two meanings and do not overlap.

### 3.2 Periodic discrete component

A periodic discrete component has these facets.

- **Discrete state** `s`, any isbits value ([§7][s7]).
- **Update** $s^{+} = g(s, u, t)$ at a declared rate.
- **Two output stages**, with [feedthrough](#g-feedthrough) applying at update instants. A
  proportional path is direct feedthrough. A state-only output is not.

Each [tier](#g-tier) carries its own state letter. `x` is the argument of the [flow](#g-flow) map
under `f`, and `s` is the argument of the jump map under `g`. The two are
different objects. `x` has a derivative and lives in the flat [buffer](#g-buffer). `s` has
none and is latched in a [store](#g-store) between [ticks](#g-tick). So they are spelled differently
([D-195][d-195]). Nothing is lost by the split, because a leaf is strictly one tier
([D-056][d-056]) and no [component](#g-component) ever reads another's state. A discrete component's `s`
influences continuous dynamics only **through signals**. Those outputs are held
zero-order between ticks.

**`m` is continuous-only.** A discrete component has no mode store. Its FSM
enums, flags and counters are ordinary `s` fields.

**Why.** `m` exists on the continuous side because modes must change *between*
flow evaluations, which is what handlers do. On the discrete side `g` already
runs at the only instants at which anything may change. A second store would
duplicate the discrete tier's own state semantics under another name.

### 3.3 Assembly

An assembly is pure composition. It holds submodels, [local wires](#g-local-wire) and
boundary [faces](#g-face). **It has no dynamics of its own.** Hybridness emerges at the
[assembly](#g-assembly) level. An aircraft is continuous vehicle parts plus discrete avionics
parts. The two-leaf split was upheld against the integrate-and-dump challenge
([§3.4][s3-4], [D-056][d-056]). Assemblies are flattened away for ordering. They are
retained as the navigation and introspection hierarchy (GUI, logging, paths) and
as declaration-level [rate scopes](#g-rate-scope) ([§10.5][s10-5]).

### 3.4 Why two leaf classes, not one hybrid primitive

Why two leaf classes at all? One all-in-one primitive could carry continuous
state, modes *and* discrete state, with `x_deriv`, events *and*
`s_update`. A purely continuous or discrete [component](#g-component)
would then fall out of whichever facets an author declares.
[Class](#g-class) is already read off declaration shape ([§8.5][s8-5]), so the
question is whether the two declaration sets should be exclusive. They are
([D-056][d-056]).

**Why.** The split is between *time bases*, not state classes. The continuous
primitive is already hybrid, with `m`, [guards](#g-guard) and handlers
([§3.1][s3-1]). What separates the classes is [sweep](#g-sweep)-driven versus
[tick](#g-tick)-driven execution. And the settled rules force a merged
[component](#g-component)'s two halves to communicate exactly as two siblings
do. There is [one home per datum](#g-one-home-per-datum) ([§5.2][s5-2]),
`x_deriv` sees only the continuous state and `s_update` only the
discrete one, and `s⁺` is decoded only at the owner's next tick, because
`s_update` runs last. That deferred decode is what makes ticks→events
structurally impossible and what terminates the [boundary](#g-boundary)
iteration ([§10.6][s10-6]). Cross-[tier](#g-tier) influence inside the merged
class still routes through published table [cells](#g-cell). The all-in-one
component is therefore an [assembly](#g-assembly) of two primitives in a
trench coat. It buys no expressiveness and incurs costs of its own, which
[D-056][d-056] enumerates. One of those costs is not bookkeeping. The sampling
[seam](#g-seam), the ZOH and the `z⁻¹` delay, is the most bug-prone boundary
in a flight-control stack. A monolith swallows it. The split keeps it a
visible wire.

#### The hardest case: integrate-and-dump

A strapdown IMU is the strongest challenge mounted against the split. Its direct
formulation integrates raw increments continuously:
`ẋ.ϑ_c = ω_ic_c`, `ẋ.υ_c = f_c_c`, the coning attitude increment `q_c_cc`
and the sculling integral `ẋ.υ_c_sc = q_c_cc(f_c_c)`. Then, at the IMU's
own `Δt`, a discrete step reads the integrals, publishes the sample, and
**zeroes them**. In interval terms, these piecewise quantities are integrals
over $[t_{k-1}, t_k]$ with their weights re-anchored at each reset. `ϑ_c`
$= \int_{t_{k-1}}^{t_k} \omega^{c}_{ic} \, dt$ and `υ_c`
$= \int_{t_{k-1}}^{t_k} f^{c} \, dt$ run from zero, `q_c_cc`
$= q_{c_{k-1} \to c(t)}$ runs from identity, and `υ_c_sc`
$= \int_{t_{k-1}}^{t_k} R^{c_{k-1}}_{c} f^{c} \, dt$ has its rotation
anchored at the interval start. These are exactly the forms the differencing
idiom of [§8.6][s8-6] recovers from the cumulative stores, term by term. The reset is
periodic, not condition-triggered, so events are the wrong [tier](#g-tier).
And the reset is a discrete-tier write into continuous state, exactly the
operation this design forbids. `s_update` writes only its own `s`, and
handlers are the sole resetters of continuous state, [guard](#g-guard)-driven.
Integrate-and-dump falls squarely into the crack between the classes. It is
tightly coupled continuous and periodic dynamics in one physical instrument.

**Algebra removes the reset.** Every interval-relative integral becomes a
cumulative one, and a discrete sampler differences consecutive samples against
its latch. [§8.6][s8-6] spells that idiom, its exactness condition and the
resulting assembly in full.

**Verdict.** The strongest counterexample landed on the two-class taxonomy
with *less* code than the direct formulation. It keeps the same thirteen integral
scalars and the same math, minus the reset block, and it brings three
structural gains. The sampling [seam](#g-seam) became a wire. The error model
became a discrete sibling, which makes the truth/corrupted sample pair
separately loggable. And linearization got sane. Under a `Dual` [activation](#g-activation) the
discrete tier is held ([§8.2][s8-2]), and "integrators that never reset" *is*
the cumulative formulation. The framework's rules pushed the model into the
only form its own linearization semantics could coherently handle. One escape
hatch is recorded, unbuilt. If interval-relative dynamics ever neither factor
algebraically nor tolerate the latch-back wire, the
[guarded addition](#g-guarded-addition) is a **tick-triggered handler** on
[continuous components](#g-continuous-component) (periodic events). No known
case needs it ([D-056][d-056]).

---

## 4. Ports and signals

### 4.1 Immutable value semantics

[Ports](#g-port) exchange **immutable values**, typically isbits structs (floats,
`SVector`s, enums, nested immutables). The framework owns a **[signal table](#g-signal-table)**,
with one concretely typed **[cell](#g-cell)** per output port in the flattened model. A
producer's output [stage function](#g-stage-function) (`y_state`/`y_direct`, the two output
stages every component provides, on either [tier](#g-tier)) returns a named tuple of fresh
values. The framework writes each of those values into its cell, and consumers
read cells.

**Vocabulary.** These names are binding throughout this document.

- A bare *cell* is the table entry, and only that.
- A *store* is the framework-owned home of one of a component's state letters,
  `x`, `s` or `m` ([§7.1][s7-1], [§7.3][s7-3], [D-302][d-302]). An `x` store is a range of
  the [buffer](#g-buffer). Stores are not cells.
- A *[staging cell](#g-staging-cell)* is a distinct compound term. It is the per-[device](#g-device) inbound
  register of [§11.4][s11-4]. Unlike a table cell it is mutated frame by frame, and it
  sits outside the table's publish-once discipline.
- A *[root input](#g-root-input)* is a source cell fed by the [periphery](#g-periphery) rather than by a producer
  ([§11.3][s11-3]).

Stated precisely, the signal requirement is **immutability plus frozen
references**. Signals may reference bulk data ([§4.4][s4-4]) provided that data is
read-only for the duration of the run. `isbits` is the common case, not the
rule.

This requirement has four consequences.

- There is no aliasing, ever. Nothing can be mutated under a consumer's feet.
- Concurrent reads from the GUI and logging threads are safe by construction.
- Isbits payloads allocate nothing, because named tuples of isbits are isbits.
- Each cell has a definite freshness, tied to its producer's position in the
  [execution order](#g-execution-order) ([D-004][d-004]).

### 4.2 Consumers see ports, not stages

The [port](#g-port) is the addressable unit. A [component](#g-component)'s outputs appear to consumers, the
GUI and logs as one flat namespace of ports (`dyn.vel`, `dyn.f_c_c`). A
reader reaches a leaf inside a port value through the port's
[leaf address](#g-leaf-address) (the field name with dotted and bracketed
steps below it, [§14.4][s14-4]). Which output stage computes which port is an
ordering annotation, invisible outside the component. Moving an output between
stages is non-breaking *for consumers*. No wire, log or panel sees it. The build
does see it, because the [feedthrough](#g-feedthrough) graph and stage membership change ([§9.1][s9-1]).

**Visibility.** Which ports exist at all is a declaration-layer decision. The
output [contract](#g-contract) *is* the public interface. There are no private intermediates. A
value a later function needs is a declared port like any other, and a stage
result outside the contract is a build error ([§5.2][s5-2], [§8.3][s8-3]). A presentational
*unlisted* flag, skipped in logs and GUI but still connectable, is closed
([D-016][d-016]).

### 4.3 Table mechanics and port granularity

[§4.2][s4-2] fixed the [port](#g-port) as the addressable unit. Four questions remain. What is a
port on a [component](#g-component)'s boundary? How do values travel into cells and out of them?
What may a port hold? And how much should a single port carry? The last question
has two answers, one owed to the parties that read a port and one to the parties
that write it.

#### Ports and faces

A component's **ports** are its signal endpoints, one [cell](#g-cell) and one producer
each. Its **[faces](#g-face)** are the names those ports wear on the component's boundary.
For a leaf the two coincide. For an [assembly](#g-assembly) every face aliases an interior port
through its boundary declarations ([§8.6][s8-6]) and never creates an endpoint. The
distinction is kind-blind. Wiring and the [periphery](#g-periphery) address a child's faces
without knowing whether it is primitive or composite.

**Rule.** The port is the atomic unit of the entire periphery. It is one cell,
one [root input](#g-root-input), one staged write, one [device](#g-device) [claim](#g-claim) ([§11.3][s11-3]), one [trace](#g-trace) address
and one GUI liveness verdict ([§11.7][s11-7]).

#### Scatter and gather

**Scatter/gather is the whole protocol.** A [stage function](#g-stage-function)
(`y_state`/`y_direct`, on either [tier](#g-tier)) returns a named tuple. The
framework scatters each field into that port's concretely typed cell. Every
reader gathers views from cells. The readers are the next stage,
`x_deriv`/`s_update`, [guards](#g-guard), wired consumers and [snapshot](#g-snapshot) capture.

**The aggregate `y` is a merge semantically and virtual physically.**
Semantically, a component's `y` is the merge of its stage products, `merge(y_x,
y_xu)` on the continuous [tier](#g-tier) and `merge(y_s, y_su)` on the discrete. It carries
declared ports only. Physically no such object exists. `y` is reconstructed per
call from cells, as register-level field loads at zero cost for isbits, and is
never stored as an object.

Name collisions across a component's stages are a build error.

#### What a port may hold

**Stage returns are named tuples of port values, period.** A custom struct is a
first-class port *value*. It is one field of the returned tuple, one declared
port, one cell (`pose = KinPose{T}`). Nested fields get no cells of their own.
A reader reaches one through the port's [leaf address](#g-leaf-address) (the
field name with dotted and bracketed steps below it), `"pose.q_eb"`
([§14.4][s14-4], [D-276][d-276]), and a wired consumer takes the bundle whole. Bare-struct
returns are rejected ([D-036][d-036]).

A port value's leaves are what the leaf walk reaches through `Real`s, static
arrays and isbits structs. An enum is one leaf, pinned ([§8.2][s8-2]).
`StopFlag` is the one enum with a framework meaning. An output port of that
type is a [stop request](#g-stop-request) (a port that ends the run when it
reads `STOP_REQUESTED`), and a `StopFlag` nested in a port of another type or
declared as a root input is refused (`IllegalPortType`, [§13.5][s13-5], [D-316][d-316]). The walk
stops at an immutable type that is not isbits and treats it as one opaque leaf
(a leaf the table stores whole, references included). That leaf is the
[field handle](#g-field-handle) ([§4.4][s4-4]). A `Symbol` is an opaque leaf too. Julia classifies
it mutable, but it is interned, immutable and never freed, the same grounds
[§7.3][s7-3] admits it in a store on, so a `Symbol` mode publishes like any other
([D-243][d-243]). A mutable type anywhere in a port value is refused, and so is an
opaque leaf surfacing as a root input, which has no synthesis
(`IllegalPortType`, [D-237][d-237]).

#### Granularity, read side

**Rule.** Wiring is port-granular. There are no sub-field connections. A
consumer that wants less than a bundle takes the bundle and destructures it,
in its own stage or through an unbundling component (a `y_direct` leaf that
takes the bundle and publishes its fields, a candidate for the standard
library of [§13.7][s13-7]), or asks the producer for a loose port ([D-276][d-276]). A
field-projection connector is a [guarded
addition](#g-guarded-addition) (a capability the design admits but does not
build). Its shape is obvious, and it is not built.

**Granularity guideline.** Authors should bundle what *shares a stage* *and is
consumed together*. The first criterion is trivially enforced, because each port
has exactly one producing function. Bundling across dependency footprints is the
classic mistake. A kinematics bundle mixing pose, which is stage 1, with
velocity-derived quantities, which are stage 2, must split. Fan-out is free, so publishing both a bundle
and a hot loose field (`pose` *and* `q_eb`) is legitimate. It costs one extra
isbits cell.

**Example.** The sketch below shows the bundle, the loose hot field and a face
aliasing an interior port, in declaration form.

```julia
#a continuous leaf: one bundle port and the hot field published loose — two cells
y_types(::Kinematics) = (pose = KinPose{Float64}, q_eb = RQuat{Float64})

#the enclosing assembly: each face aliases an interior port, creating no endpoint
output_wires(::Vehicle) = ("kin/pose" => "pose", "kin/q_eb" => "q_eb")
```

#### Granularity, write side

**Write-side rule.** **Bundle what is written together.**

**Rule.** Data written by different external writers, or at different cadences,
must not share a port.

Pilot commands are the case in point. They are scalar faces under a namespace
prefix. The convenient bundle is assembled *downstream*, inside the graph, by an
ordinary component. That is legal by the read-side guideline, since the bundle
has a single producer and is consumed together.

The guideline and the rule compose into one principle. A port's granularity is
set by the finest-grained party owning either end, producers on the read side
and external writers on the write side. Field-addressed staging (a lens into
struct slots) stays a recorded guarded addition, unbuilt.

### 4.4 Function-valued signals: environment access

Atmosphere and terrain are **query-shaped**. Consumers evaluate them at
arguments of their own choosing, such as each gear strut at its own contact
point, or airflow at the vehicle pose. Ordinary [ports](#g-port) therefore carry them as
**immutable query objects**, called [field handles](#g-field-handle).

- An environment [component](#g-component) emits a field value (`ISAField(T_sl, p_sl, wind)`,
  `TerrainField(…)`), and consumers receive it through ordinary input ports.
  Inside their own [stage functions](#g-stage-function) (`y_state`/`y_direct`) they call
  query functions on it, such as `airdata(field, pos, vel)` and
  `ray_intersect(field, p, u)`.
- **Parametric models are isbits** (ISA, uniform wind, horizontal terrain).
  **Bulk-data models use the handle pattern.** The handle is an immutable struct
  combining isbits parameters with references to bulk data (heightmaps, wind
  grids, the geoid undulation grid) loaded at build time and frozen. Handles are
  rebuilt per evaluation without allocation, as immutable structs holding
  existing references. They are never `Ref`s, whose mutable cell allocates.
- **No mutable caches inside field objects**, such as memoizing interpolators or
  lazy loaders. Concurrent consumers and the GUI thread would race on them.
  Caches belong in the consumer's state, or the interpolant is restructured to
  be pure.
- Loggers treat field-handle signals specially. They skip or summarize them.

**The [value-level constructor](#g-value-level-constructor).** Every field-emitting component must expose the
map (component, input values) → handle as a plain, pure, public function. For
the `SimpleAtmosphere` successor that function is `atmospheric_field(atm; T_sl,
p_sl, wind)`. The field-emitting component's swept output stage must be a
**one-line call to that function**, never the other way round. The other way
round puts the query math in the output stage, where only a [sweep](#g-sweep) can reach it.

The reason is script-side. The condition math ([§14.1][s14-1]) must be able to construct,
outside any sweep, bit-for-bit the same handle the sweep would produce from the
same [root input](#g-root-input) values. One implementation serves two call sites, so there is no
drift. The drift avoided here is the silent-drift class that [§5.3][s5-3] exists to
kill. This is a *shipped component's obligation*, not something a consumer can
retrofit. The real component composes sub-models, and anyone else reconstructing
the map has re-created the drift class.

For bulk-data components the obligation is only that the query math be reachable
as a plain function. They own their resource loading, so building a handle
outside a build may cost a load. That cost is acceptable, because condition
authoring is design-time code.

**Example.** The sketch below shows the map as a plain function, and the stage
that does nothing but call it.

```julia
#the map: plain, pure, public — callable outside any sweep
atmospheric_field(atm; T_sl, p_sl, wind) = ISAField(…)

#the swept output stage: one line, nothing but the call
y_direct(atm, args) = (; … = atmospheric_field(atm; T_sl = …, p_sl = …, wind = …))
```

Pre-sampling is an **idiom built on top**, used where natural, not a separate
mechanism. In it, a component consumes the field and a pose and emits plain
data, as `Airflow` emits `AirData` for the whole vehicle. Resource injection
(declare-and-resolve service registries) is closed for the first cut ([D-008][d-008]).

The field-handle mechanism replaces threading `atmosphere`/`terrain` as
arguments through every update signature. It dovetails with the terrain
ray-query direction of the landing-gear redesign. Substitutability behind a
stable [face](#g-face) is declared with an abstract input entry, `terrain =
AbstractTerrainField`, which is structural substitutability ([§8.2][s8-2]). The consumer
wires to any concrete field type below the bound. That preserves today's
`AbstractTerrain` polymorphism at the declaration layer.

---


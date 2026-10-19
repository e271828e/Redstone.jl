### 13.7 Tooling consequences: face routes and the component library

Generic-holding [contracts](#g-contract) (each a component's declared interface) are a
structural customer of computed interface connections, which are therefore
prominent in this section. [D-062][d-062] makes three tooling commitments for them,
namely the passthrough helpers' predicate, the routes `show(::Structure)` prints
for each root [face](#g-face) (the name a port wears on its component's boundary), and a
standard library of [components](#g-component) (the units of modeling, each a leaf or an
assembly of components). The section covers the predicate and the face routes
first, then the standard component library and the component test rig.

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

**A block joins the library's inventory by judgement against three
guidelines** ([D-313][d-313]). The guidelines ask whether a block is
domain-agnostic and generally useful, whether it has didactic value, and
whether its implementation is difficult to get right. None is a
requirement. They are weighed, not satisfied one by one, and a listed block
is built whenever wanted. The inventory, and the Simulink mapping that
prunes it, is `companions/library_inventory.md`. A one-line expression such
as a gain earns no block, because a separate component costs a build entry,
a cell, a gather and a scatter ([§9.7][s9-7]). Domain components, such as
aerodynamics, engines or sensors, belong in separate packages built on the
framework. Simulink's library is a language, while this is a toolbox.

The starting inventory holds the `Junction`, with `SumJunction{V, N}`,
`Or{N}` and `And{N}` as its named forms, `UnitDelay{V}`, `Constant{V}`,
`Freeze{V}` and `StopRequest`. The shipped list lives in
`companions/library_inventory.md`. `UnitDelay` is the spelling the second
loop-breaking remedy ([§5.5][s5-5]) needs. `Constant{V}` is the source block
([D-143][d-143]). `Freeze{V}` is the declared stop-gradient ([D-266][d-266]).
`StopRequest` is the library spelling of a [stop request](#g-stop-request) (a
port that ends the run when it reads `STOP_REQUESTED`) ([§13.5][s13-5],
[D-316][d-316]). The request is its port's `StopFlag` type, which any
component may publish, so the block holds no privilege.

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
each declares its `out` pinned ([D-312][d-312]).

Two uses need `Constant` ([D-143][d-143]), though a listed block needs none to be built
([D-313][d-313]). The zero-contributor configurations ([§6.2][s6-2]) are one. There, a required
aggregate input has no physical contributor, and the zero total must be spelled
as a wire. The rig stub below is the other. The block's value is instance data,
like junction arity, not an overridable default ([D-143][d-143]). A configuration wanting
an externally settable source uses a root input ([§11.3][s11-3]), which keeps the block
from drifting into a back-door input default. A handle that references bulk data
never surfaces as a root input ([D-237][d-237]); a rig holds such a handle through a
[constant source](#g-constant-source) (a `Constant` holding it) instead ([§14.9][s14-9], [D-364][d-364]).

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
terrain input is abstract. **A concrete stub child (a provider of
`SampleTerrainField`, an illustrative concrete terrain) is wired to the face**,
and the concrete remainder is exposed via
`input_passthrough(rig, "strut"; except = ("terrain",))` ([D-120][d-120]).

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
makes it the source block's first shipped instance ([D-143][d-143]). Bespoke
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
- The *sampled* set-tracer (the local, primal-carrying mode) at sampled states
  is the fallback whenever the global tracer hits an undecidable branch, such
  as piecewise friction, stall blending or any gridded lookup at an
  input-tainted coordinate. It reports the dependence pattern of the taken
  paths, sampled across randomized states. Its only misses are untaken
  branches ([D-012][d-012], [D-349][d-349]).

#### What tracing touches

**Only *inputs* are seeded** ([D-349][d-349]), so branching on state, modes, parameters or time
never interferes. Stage-2 functions also receive state views, but neither those
nor the stage-1 hand-down are ever seeded. Stage-1 functions are never traced,
since there is nothing to seed. Derivatives, [guards](#g-guard) (the declared functions
defining each event's predicate), handlers and [projections](#g-projection) (the optional
per-component hook `x ← x_projection(x)`) are outside tracing's jurisdiction
entirely.

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

Classification touches no activation machinery. There is no
[activation](#g-activation) (the build's typed products at a given scalar
type), no layouts and no table. The cycle classifier uses the *per-member*
(local) variant of tracing, the order-free per-member trace at the probe point
([D-012][d-012]). The "tracer activation" ([§9.4][s9-4]) names the other
variant ([D-012][d-012]), the global set-tracer run as an ordinary activation.
The two must not be conflated. The per-member variant is not the sampled mode.
A member's map may come from either mode.

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

The build diagnostic offers both exits explicitly ([D-140][d-140],
[D-343][d-343]). For a loop between `systems/aero` and `systems/dyn` it reads
"artificial at port level: `systems/aero`'s `F` does not route `a`; split
`systems/aero`, or narrow the neighbor's contract if `a` is consumed only in a
fallback branch". The dead hop is the member's input face that its stage-2
function does not route to the output port. The diagnostic carries the dead
hop ([D-245][d-245]) as a separate field of its [payload](#g-payload) (the
structured data a diagnostic carries) rather than dotting the hop onto the
path ([§8.6][s8-6], [§13.2][s13-2]).

If a member's evaluation itself throws, the diagnostic ships with its members
and wires alone, unclassified. Classification is a bonus on the cycle error,
never its precondition ([D-012][d-012]).

---

## 6. Composition: connections, aggregation and hierarchy

[Components](#g-component) become a system through wiring. Connections route signals across the
[assembly](#g-assembly) hierarchy, and ordinary junction components sit wherever several
signals must combine into one. [§6.1][s6-1] gives the connection and hierarchy rules.
[§6.2][s6-2] gives the aggregation idiom they force.

### 6.1 Connections and hierarchy

A wire names its two endpoints by path, and those paths run down the hierarchy
of children. How far a path may reach decides whether a parent addresses a
grandchild's [port](#g-port) directly or every intermediate level must re-export it. That
question comes first here. Then come what type-checks a wire once both endpoints
resolve, how many connections each side may take, and what becomes of the ports
left unconnected.

#### How far a path may reach

**Rule.** Every connection endpoint names an **immediate child and one of its
[faces](#g-face)** ([D-207][d-207]). The rule covers all three wiring declarations ([§8.6][s8-6]). An
`local_wires` pair wires one child's face to another's. An
`input_wires` entry routes a face to an immediate child's face. An
`output_wires` entry sources a face from an immediate child's face. An entry
of any of the three is a wire, and an entry of the first is a [local wire](#g-local-wire)
([D-303][d-303]).
[Container children](#g-container-children) ([§8.5][s8-5]) keep their key segment, so `"aircraft/2/face"` is one
level and not two. A container declared name-transparent ([§8.5][s8-5]) is the
exception. Its elements go by bare key, so `"ctl/face"` reads exactly as a plain
child's endpoint does, the same one level.

Routing across several levels is therefore declared level by level, with each
assembly speaking only of its own children. `Cessna172` hands its `trn` input to
`systems`, `Systems` hands it to `ldg`, and `Ldg` fans it out to its three legs.
The fan-out is declared at the level where the paths diverge.

```julia
input_wires(::Cessna172) = ("trn" => "systems/trn", …)
input_wires(::Systems)   = ("trn" => "ldg/trn", …)
input_wires(::Ldg)       = ("trn" => ("left/trn_field", "right/trn_field",
                                      "nose/trn_field"), …)
```

**Why.** [Faces](#g-face) become the only currency crossing an assembly boundary, so
substitutability holds at *every* boundary rather than only at generic ones.
This is the contract-is-the-interface principle of [§8.3][s8-3] with its one leak
closed. The second consequence is that the face graph is **total**. Every signal
crossing a boundary bears a declared face there, at every level it crosses.
Totality is what the condition algebra addresses against. An `at` prefix
stopping at a child's face has a name to resolve through ([§14.2][s14-2]).

The ceremony this costs is the re-export entry per level. It is the ceremony the
design already pays almost everywhere, because every level of a realistic tree
is a generic [seam](#g-seam), where one-level routing was mandatory in any case ([§8.8][s8-8]).
Where the entries multiply, they are computed rather than typed, through
`input_passthrough`/`output_passthrough` over a single authored feed list
([§8.8][s8-8]). Parallel routes threading many boundaries are the signal to gather them
into a component of their own.

Enforcement lives in the path-resolution primitive itself (`resolve`, [§13.3][s13-3]),
which walks declared field types alongside instances. Paths are validated at
build time, and renames break loudly.

#### Type-checking a wire

**Rule.** Two clauses type-check a wire ([§8.2][s8-2]).

**The nominal bound check** is stated over declaration evaluations. The
producer's declaration at `Float64` must be `<:` the consumer's entry at
`Float64`. It is one uniform rule, and it degenerates to exact equality for a
concrete entry. A violation is `WireTypeMismatch`.

Beside it, and **for a continuous consumer only**, stands the
**walk-compatibility clause**. A walking producer leaf, one the producer left
unpinned, requires an unpinned entry. A [pinned](#g-walked) producer leaf, one declared
`Pinned`, satisfies either entry, because frozen values embed upward under any
[activation](#g-activation) (the build's typed products at a given scalar type).

**An opaque leaf is admitted on the same terms.** An opaque leaf ([§4.3][s4-3]), a
handle stored whole, has no scalar position to embed through, and the clause
does not need one. A frozen handle arriving at an unpinned entry is the
producer's cell, gathered as stored, and the consumer's own arithmetic
promotes whatever it reads from it ([D-264][d-264]). A discrete producer of a handle,
which pins wholesale, is admitted the same way. The identity rule for an
opaque leaf ([§9.5][s9-5]) governs a store, never a wire. One consequence follows
from that rule: a component that re-emits a frozen handle pins that output
too, so a handle's pin is a property of its chain.

Both sides are plain declarations the walk retypes, so the clause is decided in
the structure step by retyping them at a marker scalar. That is declaration
reading, and no user stage code runs ([§9.1][s9-1]). A violation is `WalkingFaceAtFrozenEntry`, naming both
endpoints, the leaf and both declared leaf types. The message carries both
remedies. Remove the entry's `Pinned` if the consumer promotes, or feed it from
a non-walking source if the freeze is genuine, for which the `Freeze` block
([§13.7][s13-7]) is the one-line spelling.

For an abstract entry, whose leaves cannot be enumerated, the clause is decided
on the whole declaration. The producer's declaration at the marker, or the same
with every pinned leaf lifted to the marker, must be `<:` the entry at the
marker ([D-236][d-236]).

**The [tier](#g-tier) scope is a correctness rule, not tidiness.** A discrete consumer
takes the bound check alone, because its stages read exclusively at real [ticks](#g-tick)
in the [nominal](#g-nominal) world (the `Float64` activation, and a declaration's `Float64`
face). A `Dual`-carrying [cell](#g-cell) exists only inside activations the discrete tier
never runs in ([§9.4][s9-4]). A continuous producer feeding a discrete consumer is
therefore unconditionally legal ([D-167][d-167]).

The same clause also gives the two [contract](#g-contract) sides their **failure asymmetry**.
A pin written at an entry whose consumer really promotes fails at the *first
nominal build*, at the wire, with both endpoints named. It fails there because
an input has a build-time counterparty. The output side has none, so a pin
written at a leaf that really participates lurks until the first `Dual`
activation. It lurks loudly, never silently ([§8.2][s8-2]).

#### Fan-out and fan-in

Fan-out is free. One producer may feed many consumers. The converse is strict.

**Rule.** Every input port takes **exactly one** connection, with no exceptions.
Aggregation is done by junctions ([§6.2][s6-2]).

The rule spans levels. A child input fed by a sibling wire at its own level
*and* handed up through its parent's `input_wires` is a two-producers
build error. Routing a face upward cannot silently double-feed.

#### Unconnected ports

There is no auto-bubbling of unconnected inputs ([D-043][d-043]). Unconnected output
ports are legal, silently, with no build-time warning ([D-084][d-084]). Unconnected input
ports are a build error, with no silent defaults.

**The check is a whole-tree property, not a per-declaration one.** Within a
single assembly declaration an unfed child input is simply *awaiting a claim
from above*, either a sibling wire or an `input_wires` entry handing the
obligation up one level ([§8.6][s8-6]). The error fires at the root build for any input
whose obligation chain never terminates. The one legitimate terminus fed by no
[component](#g-component) is the root component's own input face, a root input ([§11.3][s11-3]).

### 6.2 Aggregation: explicit summing junctions

Several physical quantities are totals over many contributors. Total wrench,
total mass properties and total internal angular momentum are the examples, and
today they are the work of the generated `get_wr_b`/`get_mp_b`/`get_hr_b` tree
walks.

**Rule.** N-to-1 physical aggregation is expressed by **ordinary junction
[components](#g-component) and explicit wires**.

There is no framework aggregation mechanism. There are no multi-connection
[ports](#g-port), no declared fold ops and no identity-element opt-outs. Every input port
takes exactly one connection, everywhere.

```julia
struct Junction{In, Out, N, F} <: AbstractComponent   # library-provided (§13.7)
    f::F                              # the fold, N-ary; instance data
end
const SumJunction{V, N} = Junction{V, V, N, typeof(+)}

x_init(::Junction) = (;)              # stateless, continuous: the empty store is the tier marker (§8.2)
u_types(::Junction{In, Out, N}) where {In, Out, N} =
    NamedTuple{ntuple(i -> Symbol(:in, i), N)}(ntuple(_ -> In, N))
y_types(::Junction{In, Out}) where {In, Out} = (out = Out,)
y_direct(j::Junction, (; u)) = (out = j.f(u...),)
```

**The parameters are the nominal port types and the arity** ([D-311][d-311]), as in
`SumJunction{Wrench{Float64}, 3}`, and the fold is instance data.
`SumJunction{V, N}` is the `Junction` at `+`. A custom fold, a weighted
blend or a mass-properties composition, is `Junction{In, Out, N}(f)` with
the fold written at the site.

The junction is a continuous leaf, so its [contracts](#g-contract) are
written at nominal `Float64` and the [activation](#g-activation) walk retypes
them ([§8.2][s8-2]). An entry at `Wrench{Float64}` is the tolerant form a
promoting consumer writes, and walking, frozen and
[root-input](#g-root-input) contributors are all admissible behind it. The
Bool gates of [§13.7][s13-7] are the same leaf at `|` and `&`.

Wired at an ownership boundary, the junction is ordinary structure.
`wr_sum::SumJunction{Wrench, 3}` is a field of `Systems` like any other child
([§8.5][s8-5]).

```julia
local_wires(::Systems) = (
    "aero/wrench" => "wr_sum/in1",
    "pwp/wrench"  => "wr_sum/in2",
    "ldg/wrench"  => "wr_sum/in3",
    "wr_sum/out"  => "dynamics/wr_ext",
)
```

#### What the explicit form buys

- **Every mistake is loud** under the declaration layer. A forgotten contributor
  is an unconnected-input error naming `in4`. A double-wired slot violates
  single-connection. A stale arity surfaces as one or the other. The bookkeeping
  is ceremony, never silence.
- **The aggregate is a first-class signal.** `wr_sum.out` is an ordinary port. It
  is loggable, GUI-visible, and fanned out to a second consumer (a loads
  monitor) for one wire.
- **Aggregation logic is arbitrary stage-2 code**, such as mass-properties
  composition with its transport terms, or weighted blends. It is not restricted
  to a declared commutative-associative binary op.
- **Fold order is author-visible.** It is the positional order of the junction's
  inputs. Reassigning contributors to different slots changes summation order,
  hence bits, because float addition is not associative. The ordering is
  deterministic per configuration and under author control, which is strictly
  more explicit than a framework-canonical order ([D-037][d-037]).
- For the handful of real sites, a **named site-specific junction** documents
  the contributor set better than generated slots, at the price of hard-coding
  it into a type. An example is `u_types(::VehicleWrenchSum) = (aero = …,
  ldg = …, pwp = …)`. The generic positional form
  remains the tool for configuration-variable sites. Both are plain components,
  and the framework is not involved.

#### The hierarchical aggregation idiom

This is what replaces the tree walk. Only physical contributors publish these
ports. A strut publishes `wr_b`, and avionics publishes nothing.

Each [assembly](#g-assembly) that *owns* contributors aggregates them with an internal junction
and **exports the total**. The junction is a component inside the assembly, and
the assembly exports its `out` port ([§3.3][s3-3]).

**Why.** The [§6.1][s6-1] connection rules force this shape. A child is opaque to wiring
at every boundary, so every assembly that owns contributors must export its
aggregate.

**Example.** `Ldg` sums its three struts and exports `wr_b`. The systems
assembly sums `aero + ldg + pwp`. The vehicle wires the systems totals into
Newton–Euler.

Each recursion step of FlightCore's tree walk becomes one visible junction at
the level that owns the contributors. For the C172 that is about four junctions
and fifteen wires, written once. They read as a manifest of what weighs, what
pushes and what spins.

Frame responsibility is unchanged. Contributors publish in the common body
frame, applying their own mounting transforms at source.

Do **not** bundle the three quantities into one contribution struct.
Contributors are ragged. Aero has wrench but no mass, fuel the reverse, and only
`pwp` has angular momentum. A bundle forces zero-filled identity noise through
every port, which is the "silently sum nothing" hazard in a new coat ([D-037][d-037]).

A `sum_ports!`-style helper (instantiate + wire + export in one call) is
guarded-addition sugar, added when real models show the pattern repeated.

The junctions themselves, [summing junctions](#g-summing-junction) and Bool gates, are the seed of the
standard component library committed in [§13.7][s13-7]. They are ordinary components with
no framework privileges, and the inventory grows by the admission rule
[§13.7][s13-7] states.

#### The zero-contributor end of the same spectrum

Ragged contributors bottom out at none. Some configuration has a consumer whose
required aggregate input has *no* physical contributors at all. The
bare-propagation `Vehicle{NoVehicleSystems}` is one. It has zero contributors to
external wrench and to internal angular momentum, while `VehicleDynamics`
requires both unconditionally.

There is no junction to write and no producer to wire. [§6.1][s6-1] bans unconnected
inputs and silent defaults, and the identity element a zero-arity junction would
need is deliberately absent ([D-037][d-037]).

**Rule.** The spelling is a library `Constant` source ([§13.7][s13-7]) wired straight to
the consumer's input, as in `Constant(Wrench())` → `dynamics/wr_ext`.

**Why.** The zero total becomes declared structure. The configuration states
"external wrench ≡ 0" as a visible wire and an observable port, rather than as
an identity method the framework supplies behind the author's back.

This is not the banned default ([§6.1][s6-1]) in component clothing but its opposite.
That default is silent and consumer-declared. This one is loud and
assembly-declared, with the author writing the child and the wire, both
inspectable.

#### The cost, recorded

Adding a contributor from another subtree edits the assembly levels between its
producer and the junction ([§6.1][s6-1]) instead of zero. In exchange, explicit wiring
buys per-contributor values and intermediate totals as observable ports, with
every silence inverted into a warning or error ([D-007][d-007], [D-037][d-037]).

Consumer-declared folds with multi-connection legality are closed ([D-007][d-007] and
[D-037][d-037]).

---


### 6.2 Aggregation: explicit summing junctions

Several physical quantities are totals over many contributors. Total wrench,
total mass properties and total internal angular momentum are the examples. In
Flight.jl these totals come from tree walks. FlightPhysics' generated functions
`get_wr_b`, `get_mp_b` and `get_hr_b` sum each quantity over a model tree. This section states the rule and the junction that carries it. It then
covers what the explicit form buys, the hierarchical aggregation idiom, zero
contributors and the cost.

**N-to-1 physical aggregation is expressed by ordinary junction
[components](#g-component) and explicit wires** ([D-037][d-037]).

There is no framework aggregation mechanism. There are no multi-connection
[ports](#g-port), no declared fold ops and no identity-element opt-outs. Every
input port takes exactly one connection, everywhere ([§6.1][s6-1]).

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

**The parameters are the nominal port types and the arity**
([D-311][d-311]), as in `SumJunction{Wrench{Float64}, 3}`, and the fold is
instance data. `Wrench` is FlightPhysics' force-and-torque type, here
parametrized by its scalar type as a walked type of [§7.2][s7-2].
`SumJunction{V, N}` is the `Junction` at `+`. A custom fold, such as a
weighted blend or a mass-properties composition, is written at the site as
`Junction{In, Out, N}(f)`, which infers `F`.

The junction is a continuous leaf, so its [contracts](#g-contract) (a
component's declared interface) are written at nominal `Float64`. On a
continuous leaf the [leaf walk](#g-leaf-walk) (the framework's derivation of
per-activation types) retypes them ([§8.2][s8-2]). An input entry at
`Wrench{Float64}` is the tolerant form a promoting consumer writes. Walking,
frozen and [root-input](#g-root-input) contributors are all admissible behind
it. A root input is the root component's own input face.

The Bool gates of [§13.7][s13-7] are the same leaf at `|` and `&`
([D-311][d-311]). The junctions themselves,
[summing junctions](#g-summing-junction) and Bool gates, are the seed of the
standard component library committed in [§13.7][s13-7] ([D-062][d-062]). They
are ordinary components with no framework privileges. The inventory grows by
judgement against the three guidelines [§13.7][s13-7] states ([D-313][d-313]).

Wired at an ownership boundary, inside the [assembly](#g-assembly) that owns
the contributors, the junction is ordinary structure. An assembly is a
component of pure composition, with no dynamics of its own. In the block below,
`Systems` is the systems assembly. Its children include the aerodynamics
`aero`, the powerplant `pwp` and the landing gear `ldg`, and a child
`dynamics` that consumes the total.
`wr_sum::SumJunction{Wrench{Float64}, 3}` is a field of `Systems` like any
other child ([§8.5][s8-5]).

```julia
local_wires(::Systems) = (
    "aero/wrench" => "wr_sum/in1",
    "pwp/wrench"  => "wr_sum/in2",
    "ldg/wrench"  => "wr_sum/in3",
    "wr_sum/out"  => "dynamics/wr_ext",
)
```

#### What the explicit form buys

- Every bookkeeping mistake at the junction is loud under the declaration layer. A contributor the
  junction counts but nobody wires is an unconnected-input error naming `in4`.
  A double-wired slot violates single-connection. A stale arity surfaces as
  one or the other. The bookkeeping is ceremony, never silence. A
  contributor's output that nobody wires stays legal and silent, as any
  unconnected output does ([D-084][d-084]).
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
- For the handful of real sites, a named site-specific junction documents the
  contributor set better than generated slots, at the price of hard-coding it
  into a type. An example is `u_types(::VehicleWrenchSum) = (aero = …,
  ldg = …, pwp = …)`. The generic positional form remains the tool for
  configuration-variable sites. Both are plain components, and the framework
  is not involved.

#### The hierarchical aggregation idiom

**Each assembly that owns contributors aggregates them with an internal
junction and exports the total** ([D-037][d-037]). The junction is a component
inside the assembly, and the assembly exports its `out` port ([§8.6][s8-6]).

The [§6.1][s6-1] connection rules force this shape. A child is opaque to wiring
at every boundary, so every assembly that owns contributors must export its
aggregate.

For example, the landing gear `Ldg` sums its three struts and exports
`wrench`. The systems assembly sums `aero + ldg + pwp`. The vehicle wires the
systems totals into the rigid-body equations of motion.

Junctions placed this way replace the tree walk. Each recursion step
of FlightPhysics' tree walk becomes one visible junction at the level that owns
the contributors. For Flight.jl's Cessna 172 model that is about four junctions
and fifteen wires, written once. They read as a manifest of what weighs, what
pushes and what spins. Only physical contributors publish the ports a junction
sums. A strut publishes `wrench`, and avionics publishes nothing.

Frame responsibility is as in Flight.jl. Contributors publish in the common
body frame, applying their own mounting transforms at source.

Do not bundle the three quantities into one contribution struct. Contributors
are ragged, each having only some of the three quantities. A bundled contribution
struct forces zero-filled identity noise through every port, which is the
"silently sum nothing" hazard in a new coat ([D-037][d-037]).

A `sum_ports!`-style helper would instantiate, wire and export in one call.
**Such a helper is [guarded-addition](#g-guarded-addition) sugar** (a
capability the design admits but does not build), added when real models show
the pattern repeated ([D-037][d-037]).

#### Zero contributors

Ragged contributors bottom out at none. Some configuration has a consumer whose
required aggregate input has *no* physical contributors at all. FlightPhysics'
bare-propagation vehicle with no systems, `Vehicle{NoVehicleSystems}`, is one.
It has zero contributors to external wrench and to internal angular momentum,
while its rigid-body dynamics component, `VehicleDynamics`, requires both
unconditionally.

There is no junction to write and no producer to wire. [§6.1][s6-1] bans
unconnected inputs and silent defaults. The identity element a zero-arity
junction would need is deliberately absent ([D-037][d-037]).

**The zero-contributor spelling is a library
[`Constant` source](#g-constant-source) ([§13.7][s13-7]) wired straight to the
consumer's input** ([D-143][d-143]), as in `Constant(Wrench())` →
`dynamics/wr_ext`. A constant source has no inputs and no state, and publishes
a value its instance holds.

The zero total thus becomes declared structure. The configuration states
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
([D-037][d-037]).

---

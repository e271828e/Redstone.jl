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


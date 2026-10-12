#### Type-checking a wire

Once both endpoints of a wire resolve, two clauses type-check it
([§8.2][s8-2]). The first is the [nominal](#g-nominal) bound check. Nominal
means the `Float64` [activation](#g-activation) (the build's typed products at
a given scalar type), and a declaration's `Float64` face. The bound check is
stated over declaration evaluations. The producer's declaration at `Float64`
must be `<:` the consumer's input entry at `Float64` ([D-078][d-078]). It is
one uniform rule, and it degenerates to exact equality for a concrete entry. A
violation is `WireTypeMismatch`.

Beside it stands the walk-compatibility clause (the walk clause for short), for
a continuous consumer only. A [walking](#g-walked) producer leaf, one the producer left
unpinned, requires an unpinned entry. A pinned producer leaf, one declared
`Pinned`, satisfies either entry, because frozen values embed upward under any
activation. A discrete consumer takes the bound check alone, so a continuous
producer feeding a discrete consumer is unconditionally legal, for the reason
[§8.2][s8-2] gives ([D-295][d-295], [D-263][d-263]).

The producer's declaration and the entry are plain declarations that the
[leaf walk](#g-leaf-walk) (the framework's derivation of per-activation types) retypes. The walk
clause is therefore decided in the structure step by retyping them at a marker
scalar. That is declaration reading, and no user stage code runs ([§9.1][s9-1]).

An [abstract entry](#g-abstract-entry) is an input entry whose declared type is abstract. Its leaves
cannot be enumerated. **The walk clause decides an abstract entry on the whole
declaration** ([D-236][d-236]). The producer's declaration at the marker, or the same with
every pinned leaf lifted to the marker, must be `<:` the entry at the marker
([D-236][d-236]).

The walk clause admits an opaque leaf on the same terms as a pinned or walking
leaf. An opaque leaf ([§4.3][s4-3]), a handle stored whole, has no scalar position to
embed through, and the walk clause does not need one. **A frozen handle arriving
at an unpinned entry is the producer's [cell](#g-cell)** (the signal-table entry holding its
output), gathered as stored ([D-264][d-264]). The consumer's own arithmetic promotes
whatever it reads from it ([D-264][d-264]). A discrete producer of a handle, which pins
wholesale, is admitted the same way. **The identity rule for an opaque leaf
governs a store, never a wire** ([§9.5][s9-5], [D-264][d-264]). Under that rule, a component that
re-emits a frozen handle pins that output too, so a handle's pin is a property
of its chain ([D-264][d-264]).

A violation of the walk clause is `WalkingFaceAtFrozenEntry`, naming both
endpoints, the leaf and both declared leaf types. The message carries both
remedies, "remove the entry's `Pinned` if the consumer promotes; feed it from
a non-walking source if the freeze is genuine". The `Freeze` block is the
one-line spelling of the second remedy ([§13.7][s13-7], [D-266][d-266]).

The walk clause also gives the two sides of a [contract](#g-contract) (a component's declared
interface) their failure asymmetry. A pin written at an entry whose consumer
really promotes fails at the *first nominal build*, at the wire, with both
endpoints named ([D-263][d-263]). It fails there because an input has a build-time
counterparty. The output side has none, so a pin written at a leaf that really
participates lurks until the first `Dual` activation. It lurks loudly, never
silently ([§8.2][s8-2], [D-286][d-286]).

#### Connections per port

Fan-out is free. One producer may feed many consumers. The converse is
strict. **Every input port takes exactly one connection**, with no exceptions
([D-170][d-170]). Aggregation is done by junctions ([§6.2][s6-2]).

The rule spans levels ([D-170][d-170]). A child input fed by a local wire at
its own level *and* handed up through its parent's `input_wires` is a
two-producers build error, `TwoProducers`. Routing a face upward cannot
silently double-feed.

There is no auto-bubbling of unconnected inputs ([D-043][d-043]). Unconnected input ports
are a build error, with no silent defaults. The check is a whole-tree property,
not a per-declaration one ([D-048][d-048]). Both this check and the two-producers check
are decided at the root, since neither is decidable below it ([D-048][d-048]). Within a
single assembly declaration an unfed child input is simply *awaiting a wire from
above*, either a local wire or an `input_wires` entry handing the obligation up
one level ([§8.6][s8-6]). The unconnected-input error, `UnconnectedInput`, fires at the
root build for any input whose obligation chain never terminates. The one
legitimate terminus fed by no component is the root component's own input face,
a [root input](#g-root-input) ([§11.3][s11-3], [D-208][d-208]).

**Unconnected output ports are legal, silently, with no build-time warning**
([D-084][d-084]).

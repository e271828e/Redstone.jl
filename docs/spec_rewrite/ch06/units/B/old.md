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


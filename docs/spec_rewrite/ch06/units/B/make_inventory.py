import json, os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
SPEC = "docs/design/spec.md"
C = []
def c(old, new, tag="F", cites=None, newcites=None, where="new", ruling=None):
    d = {"id": f"C-{len(C)+1:03d}", "old": old, "new": new, "where": where,
         "cites": cites or [], "tag": tag}
    if newcites is not None: d["newcites"] = newcites
    if ruling: d["ruling"] = ruling
    C.append(d)

# Type-checking a wire
c("#### Type-checking a wire", "#### Type-checking a wire", "X")
c("Rule. Two clauses type-check a wire (§8.2).",
  "Once both endpoints of a wire resolve, two clauses type-check it (§8.2).", "R", ["§8.2"], ruling="R1")
c("The nominal bound check is stated over declaration evaluations.",
  "The bound check is stated over declaration evaluations.")
c("The producer's declaration at `Float64` must be `<:` the consumer's entry at `Float64`.",
  "The producer's declaration at `Float64` must be `<:` the consumer's input entry at `Float64` (D-078).",
  "R", [], ["D-078"], ruling="R9")
c("It is one uniform rule, and it degenerates to exact equality for a concrete entry.",
  "It is one uniform rule, and it degenerates to exact equality for a concrete entry.")
c("A violation is `WireTypeMismatch`.", "A violation is `WireTypeMismatch`.")
c("Beside it, and for a continuous consumer only, stands the walk-compatibility clause.",
  "Beside it stands the walk-compatibility clause, for a continuous consumer only.", "R", ruling="R1")
c("A walking producer leaf, one the producer left unpinned, requires an unpinned entry.",
  "A walking producer leaf, one the producer left unpinned, requires an unpinned entry.")
c("A pinned producer leaf, one declared `Pinned`, satisfies either entry, because frozen values embed upward under any activation",
  "A pinned producer leaf, one declared `Pinned`, satisfies either entry, because frozen values embed upward under any activation.")
c("(the build's typed products at a given scalar type).",
  "activation (the build's typed products at a given scalar type)", "M")
# opaque leaf
c("An opaque leaf is admitted on the same terms.",
  "The walk clause admits an opaque leaf on the same terms as a pinned or walking leaf.")
c("An opaque leaf (§4.3), a handle stored whole, has no scalar position to embed through, and the clause does not need one.",
  "An opaque leaf (§4.3), a handle stored whole, has no scalar position to embed through, and the walk clause does not need one.",
  "F", ["§4.3"])
c("A frozen handle arriving at an unpinned entry is the producer's cell, gathered as stored,",
  "A frozen handle arriving at an unpinned entry is the producer's cell (its output's entry in the signal table), gathered as stored (D-264).",
  "R", [], ["D-264"], ruling="R4")
c("and the consumer's own arithmetic promotes whatever it reads from it (D-264).",
  "The consumer's own arithmetic promotes whatever it reads from it (D-264).", "F", ["D-264"])
c("A discrete producer of a handle, which pins wholesale, is admitted the same way.",
  "A discrete producer of a handle, which pins wholesale, is admitted the same way.")
c("The identity rule for an opaque leaf (§9.5) governs a store, never a wire.",
  "The identity rule for an opaque leaf governs a store, never a wire (§9.5, D-264).",
  "R", ["§9.5"], ["§9.5", "D-264"], ruling="R4")
c("One consequence follows from that rule: a component that re-emits a frozen handle pins that output too, so a handle's pin is a property of its chain.",
  "One consequence follows from that rule. A component that re-emits a frozen handle pins that output too, so a handle's pin is a property of its chain (D-264).",
  "C", [], ["D-264"])
# the run (M2)
c("Both sides are plain declarations the walk retypes, so the clause is decided in the structure step by retyping them at a marker scalar.",
  "The producer's declaration and the entry are plain declarations the walk retypes, so the walk clause is decided in the structure step by retyping them at a marker scalar.",
  "R", ruling="R1")
c("That is declaration reading, and no user stage code runs (§9.1).",
  "That is declaration reading, and no user stage code runs (§9.1).", "M", ["§9.1"])
# violation
c("A violation is `WalkingFaceAtFrozenEntry`, naming both endpoints, the leaf and both declared leaf types.",
  "A violation of the walk clause is `WalkingFaceAtFrozenEntry`, naming both endpoints, the leaf and both declared leaf types.")
c("The message carries both remedies. Remove the entry's `Pinned` if the consumer promotes, or feed it from a non-walking source if the freeze is genuine,",
  "The message carries both remedies, \"remove the entry's `Pinned` if the consumer promotes; feed it from a non-walking source if the freeze is genuine\".",
  "R", ruling="R9")
c("for which the `Freeze` block (§13.7) is the one-line spelling.",
  "The `Freeze` block is the one-line spelling of the second remedy (§13.7, D-266).",
  "C", ["§13.7"], ["§13.7", "D-266"])
# abstract entry
c("For an abstract entry, whose leaves cannot be enumerated, the clause is decided on the whole declaration.",
  "The walk clause decides an abstract entry on the whole declaration, an entry whose leaves cannot be enumerated (D-236).",
  "R", [], ["D-236"], ruling="R4")
c("The producer's declaration at the marker, or the same with every pinned leaf lifted to the marker, must be `<:` the entry at the marker (D-236).",
  "The producer's declaration at the marker, or the same with every pinned leaf lifted to the marker, must be `<:` the entry at the marker (D-236).",
  "F", ["D-236"])
# tier scope (M1)
c("The tier scope is a correctness rule, not tidiness.",
  "That scope is a correctness rule rather than tidiness.", "M", where=SPEC)
c("A discrete consumer takes the bound check alone,",
  "A discrete consumer takes the bound check alone", "R", ruling="R1")
c("because its stages read exclusively at real ticks in the nominal world",
  "A discrete stage reads exclusively at real ticks (the instants a discrete component runs) in the nominal world.",
  "M", where=SPEC)
c("(the `Float64` activation, and a declaration's `Float64` face).",
  "Nominal means the `Float64` activation (the build's typed products at a given scalar type), and a declaration's `Float64` face.",
  "M")
c("A `Dual`-carrying cell exists only inside activations the discrete tier never runs in (§9.4).",
  "A `Dual`-carrying cell exists only inside activations discrete stages never run in (§9.4).",
  "M", ["§9.4"], where=SPEC)
c("A continuous producer feeding a discrete consumer is therefore unconditionally legal (D-167).",
  "so a continuous producer feeding a discrete consumer is unconditionally legal, for the reason §8.2 gives (D-295, D-263).",
  "R", ["D-167"], ["§8.2", "D-295", "D-263"], ruling="R1, R9 (F10)")
# failure asymmetry
c("The same clause also gives the two contract sides their failure asymmetry.",
  "The walk clause also gives the two contract sides their failure asymmetry.")
c("A pin written at an entry whose consumer really promotes fails at the first nominal build, at the wire, with both endpoints named.",
  "A pin written at an entry whose consumer really promotes fails at the first nominal build, at the wire, with both endpoints named (D-263).",
  "C", [], ["D-263"])
c("It fails there because an input has a build-time counterparty.",
  "It fails there because an input has a build-time counterparty.")
c("The output side has none, so a pin written at a leaf that really participates lurks until the first `Dual` activation.",
  "The output side has none, so a pin written at a leaf that really participates lurks until the first `Dual` activation.")
c("It lurks loudly, never silently (§8.2).",
  "It lurks loudly, never silently (§8.2, D-286).", "C", ["§8.2"], ["§8.2", "D-286"])
# Fan-out and fan-in
c("#### Fan-out and fan-in", "#### Connections per port", "R", ruling="R5")
c("Fan-out is free.", "Fan-out is free.")
c("One producer may feed many consumers.", "One producer may feed many consumers.")
c("The converse is strict.", "The converse is strict.", "X")
c("Rule. Every input port takes exactly one connection, with no exceptions.",
  "Every input port takes exactly one connection, with no exceptions (D-170).",
  "R", [], ["D-170"], ruling="R4")
c("Aggregation is done by junctions (§6.2).", "Aggregation is done by junctions (§6.2).", "F", ["§6.2"])
c("The rule spans levels.", "The rule spans levels (D-170).", "C", [], ["D-170"])
c("A child input fed by a sibling wire at its own level and handed up through its parent's `input_wires` is a two-producers build error.",
  "A child input fed by a local wire at its own level and handed up through its parent's `input_wires` is a two-producers build error, `TwoProducers`.",
  "R", ruling="R9 (F4), R6")
c("Routing a face upward cannot silently double-feed.", "Routing a face upward cannot silently double-feed.")
# Unconnected ports
c("#### Unconnected ports", "#### Connections per port", "R", ruling="R5")
c("There is no auto-bubbling of unconnected inputs (D-043).",
  "There is no auto-bubbling of unconnected inputs (D-043).", "F", ["D-043"])
c("Unconnected output ports are legal, silently, with no build-time warning (D-084).",
  "Unconnected output ports are legal, silently, with no build-time warning (D-084).",
  "R", ["D-084"], ruling="R4, R5")
c("Unconnected input ports are a build error, with no silent defaults.",
  "Unconnected input ports are a build error, with no silent defaults.")
c("The check is a whole-tree property, not a per-declaration one.",
  "The check is a whole-tree property, not a per-declaration one (D-048).", "C", [], ["D-048"])
c("Within a single assembly declaration an unfed child input is simply awaiting a claim from above, either a sibling wire or an `input_wires` entry handing the obligation up one level (§8.6).",
  "Within a single assembly declaration an unfed child input is simply awaiting a wire from above, either a local wire or an `input_wires` entry handing the obligation up one level (§8.6).",
  "R", ["§8.6"], ruling="R9 (F4, F15)")
c("The error fires at the root build for any input whose obligation chain never terminates.",
  "The error, `UnconnectedInput`, fires at the root build for any input whose obligation chain never terminates.",
  "R", ruling="R6")
c("The one legitimate terminus fed by no component is the root component's own input face, a root input (§11.3).",
  "The one legitimate terminus fed by no component is the root component's own input face, a root input (§11.3, D-208).",
  "C", ["§11.3"], ["§11.3", "D-208"])

ADDED = [
    "Once both endpoints of a wire resolve",
    "The first is the nominal bound check.",
    "An abstract entry is an input entry whose declared type is abstract.",
    "(its output's entry in the signal table)",
    "Both this check and the two-producers check are decided at the root, since neither is decidable below it (D-048).",
]
json.dump({"claims": C, "added": ADDED}, open(os.path.join(HERE, "inventory.json"), "w"),
          indent=1, ensure_ascii=False)

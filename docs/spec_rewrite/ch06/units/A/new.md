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

An [assembly](#g-assembly) (a component of pure composition) has three wiring
declarations ([§8.6][s8-6]). A `local_wires` pair wires one child's
[face](#g-face) (the name a port wears on its component's boundary) to
another's. An `input_wires` entry routes a face to an immediate child's face.
An `output_wires` entry sources a face from an immediate child's face. An entry
of any of the three is a wire, and an entry of the first is a
[local wire](#g-local-wire) ([D-303][d-303], [D-314][d-314]).

**Every connection endpoint names an immediate child and one of its faces**
([D-207][d-207]). An endpoint naming no port of the child it resolves to is an
`UnknownPort` error, at either end of the wire ([D-113][d-113],
[Appendix C][sC]). The one-level rule covers all three wiring declarations.
[Container children](#g-container-children) (the elements of a `Tuple` or
`NamedTuple` field holding only components, [§8.5][s8-5]) keep their key
segment ([D-085][d-085]), so `"aircraft/2/face"` is one level and not two
([D-207][d-207]). A container declared name-transparent ([§8.5][s8-5]) is the
exception. Its elements go by bare key, so `"ctl/face"` reads exactly as a
plain child's endpoint does, the same one level ([D-211][d-211]).

Routing across several levels is therefore declared level by level, with each
assembly speaking only of its own children. This restriction is named the
locality law ([D-065][d-065]), and fragments of the condition algebra follow
the same law ([§14.2][s14-2]).

The sketch below shows such routing in an aircraft. The root `Cessna172` holds
a systems assembly `Systems`, which holds the landing gear `Ldg`, whose three
legs are `left`, `right` and `nose`. The root's input `trn` is a terrain field
handle ([§4.4][s4-4]). `Cessna172` hands its `trn` input to `systems`,
`Systems` hands it to `ldg`, and `Ldg` fans it out to its three legs. The
fan-out is declared at the level where the paths diverge.

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

The ceremony the rule costs is the re-export entry per level. It is the
ceremony the design already pays almost everywhere, because every level of a
realistic tree is a generic [seam](#g-seam) (a narrow, named interface kept
deliberately thin), where one-level routing was mandatory in any case
([§8.8][s8-8]). Where the entries multiply, they are computed rather than
typed, through `input_passthrough`/`output_passthrough` over a single authored
feed list ([§8.8][s8-8]). Parallel routes threading many boundaries are the
signal to gather them into a component of their own ([D-207][d-207]).

Enforcement lives in the path-resolution primitive itself, `resolve`
([§13.3][s13-3], [D-130][d-130]). It walks declared field types alongside
instances ([D-061][d-061]). An endpoint reaching past the immediate child is a
`PathResolution` error ([Appendix C][sC]). Paths are validated at build time,
and renames break loudly.

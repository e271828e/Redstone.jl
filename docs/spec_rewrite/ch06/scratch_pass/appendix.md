## Appendix: paragraphs after the EDITORIAL fixes

Each block replaces the unit lines named, whole. Every line is at most 80
rendered columns. E1 needs no block. B4 without E7 keeps "(its output's entry
in the signal table)"; rewrap it the same way.

**A2.** Unit A, lines 41 to 44. Items: E12.

```markdown
Routing across several levels is therefore declared level by level, with each
assembly speaking only of its own children. This restriction is named the
locality law ([D-065][d-065]). [Fragments](#g-fragment) of the condition algebra follow the same law
([§14.2][s14-2]).
```

**A3.** Unit A, lines 46 to 51. Items: E13.

```markdown
The sketch below shows such routing in an aircraft. The root `Cessna172` holds a
systems assembly `Systems`, which holds the landing gear `Ldg`, whose three legs
are `left`, `right` and `nose`. The root's input `trn` is a terrain [field handle](#g-field-handle)
(an immutable query object its consumers evaluate, [§4.4][s4-4]). `Cessna172` hands its
`trn` input to `systems`, `Systems` hands it to `ldg`, and `Ldg` fans it out to
its three legs. The fan-out is declared at the level where the paths diverge.
```

**A4.** Unit A, lines 69 to 76. Items: E14.

```markdown
The ceremony the rule costs is the re-export entry per level. It is the ceremony
the design already pays almost everywhere, because every level of a realistic
tree is a generic [seam](#g-seam) (a narrow, named interface kept deliberately thin).
One-level routing was mandatory at a generic seam in any case ([§8.8][s8-8]). Where the
entries multiply, they are computed rather than typed, through
`input_passthrough`/`output_passthrough` over a single authored feed list
([§8.8][s8-8]). Parallel routes threading many boundaries are the signal to gather them
into a component of their own ([D-207][d-207]).
```

**B1.** Unit B, lines 12 to 18. Items: E9.

```markdown
Beside it stands the walk-compatibility clause (the walk clause for short), for
a continuous consumer only. A [walking](#g-walked) producer leaf, one the producer left
unpinned, requires an unpinned entry. A pinned producer leaf, one declared
`Pinned`, satisfies either entry, because frozen values embed upward under any
activation. A discrete consumer takes the bound check alone, so a continuous
producer feeding a discrete consumer is unconditionally legal, for the reason
[§8.2][s8-2] gives ([D-295][d-295], [D-263][d-263]).
```

**B2.** Unit B, lines 20 to 23. Items: E10.

```markdown
The producer's declaration and the entry are plain declarations that the
[leaf walk](#g-leaf-walk) (the framework's derivation of per-activation types) retypes. The walk
clause is therefore decided in the structure step by retyping them at a marker
scalar. That is declaration reading, and no user stage code runs ([§9.1][s9-1]).
```

**B3.** Unit B, lines 25 to 29. Items: E8.

```markdown
An [abstract entry](#g-abstract-entry) is an input entry whose declared type is abstract. Its leaves
cannot be enumerated. **The walk clause decides an abstract entry on the whole
declaration** ([D-236][d-236]). The producer's declaration at the marker, or the same with
every pinned leaf lifted to the marker, must be `<:` the entry at the marker
([D-236][d-236]).
```

**B4.** Unit B, lines 31 to 42. Items: E5, E6, E7.

```markdown
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
```

**B5.** Unit B, lines 50 to 56. Items: E11.

```markdown
The walk clause also gives the two sides of a [contract](#g-contract) (a component's declared
interface) their failure asymmetry. A pin written at an entry whose consumer
really promotes fails at the *first nominal build*, at the wire, with both
endpoints named ([D-263][d-263]). It fails there because an input has a build-time
counterparty. The output side has none, so a pin written at a leaf that really
participates lurks until the first `Dual` activation. It lurks loudly, never
silently ([§8.2][s8-2], [D-286][d-286]).
```

**C1.** Unit C, lines 3 to 8. Items: E4 (R-2 replaces it if accepted).

```markdown
Several physical quantities are totals over many contributors. Total wrench,
total mass properties and total internal angular momentum are the examples. In
Flight.jl these totals come from tree walks. FlightPhysics' generated functions
`get_wr_b`, `get_mp_b` and `get_hr_b` sum each quantity over a model tree. This
section states the rule and the junction that carries it. It then covers what
the explicit form buys, the hierarchical aggregation idiom, zero contributors
and the cost.
```

**C2.** Unit C, lines 30 to 36. Items: E15.

```markdown
**The parameters are the [nominal](#g-nominal) port types and the arity** ([D-311][d-311]), as in
`SumJunction{Wrench{Float64}, 3}`, and the fold is instance data. `Wrench` is
FlightPhysics' force-and-torque type, here parametrized by its scalar type as a
[walked](#g-walked) type of [§7.2][s7-2]. `SumJunction{V, N}` is the `Junction` at `+`. A custom
fold, such as a weighted blend or a mass-properties composition, is written at
the site as `Junction{In, Out, N}(f)`, which infers `F`.
```

**C3.** Unit C, lines 53 to 60. Items: E3.

```markdown
Wired at an ownership boundary, inside the [assembly](#g-assembly) that owns the contributors,
the junction is ordinary structure. An assembly is a component of pure
composition. In the block below, `Systems` is the systems assembly. Its children
include the aerodynamics `aero`, the powerplant `pwp` and the landing gear
`ldg`, and a child `dynamics` that consumes the total.
`wr_sum::SumJunction{Wrench{Float64}, 3}` is a field of `Systems` like any other
child ([§8.5][s8-5]).
```

**C4.** Unit C, lines 73 to 78. Items: E2.

```markdown
- Every bookkeeping mistake at the junction is loud under the declaration
  layer. A contributor the junction counts but nobody wires is an
  unconnected-input error naming `in4`. A double-wired slot violates
  single-connection. A stale arity surfaces as one or the other. The bookkeeping
  is ceremony, never silence. A contributor's output that nobody wires stays
  legal and silent, as any unconnected output does ([D-084][d-084]).
```

**C5a.** Unit C, lines 108 to 110. Items: E17.

```markdown
For example, the landing gear `Ldg` sums its three legs and exports `wrench`.
The systems assembly sums `aero + ldg + pwp`. The vehicle wires the systems
totals into the rigid-body equations of motion.
```

**C5b.** Unit C, lines 112 to 117. Items: E16.

```markdown
Junctions placed this way replace FlightPhysics' tree walk. Each of its
recursion steps becomes one visible junction at the level that owns the
contributors. For Flight.jl's Cessna 172 model that is about four junctions and
fifteen wires, written once. They read as a manifest of what weighs, what pushes
and what spins. Only physical contributors publish the ports a junction sums. A
strut publishes `wrench`, and avionics publishes nothing.
```

**C6.** Unit C, lines 122 to 125. Items: E19.

```markdown
Do not bundle wrench, mass properties and internal angular momentum into one
contribution struct. Contributors are ragged, each having only some of the three
quantities. A bundled contribution struct forces zero-filled identity noise
through every port, which is the "silently sum nothing" hazard in a new coat
([D-037][d-037]).
```

**C7.** Unit C, lines 151 to 153. Items: E18.

```markdown
The spelling makes the zero total declared structure. The configuration states
"external wrench ≡ 0" as a visible wire and an observable port, rather than as
an identity method the framework supplies behind the author's back.
```

# Chapter 6: the fixes (recipe step 7)

The fixer applied the 19 EDITORIAL items of `chapter_pass.md` and the four
blocking ruled edits of `rulings_batch.md` (RP-1, RP-2, RP-4, RI-1). No item
was skipped. Old and new text are normalized one-line source spans, link
markup kept. Every touched paragraph was rewrapped to 80 rendered columns,
link markup collapsed, and no other paragraph was rewrapped. Code blocks are
unchanged. The checkers print `checks failed: 0` for units A, B and C.

Against the appendix: A2, A3, A4, B1 to B5, C2, C3 and C5b to C7 come out
identical. C1 differs because RP-2 replaces it. C5a differs because RP-4
lands in the same paragraph. C4 differs in its wrap only: the pass's
`wrap.py` doubled the space after the bullet's dash and counted it, so its
first line broke one word early.

## Unit A

**E1 (A part).** Unit A, §6.1's first paragraph.
- Old: `An [assembly](#g-assembly) (a component of pure composition) has three wiring`
- New: `An [assembly](#g-assembly) (a [component](#g-component) of pure composition) has three wiring`
- Inventory: none changed. The `added` span "An assembly (a component of
  pure composition)" normalizes the same. The pass said no rewrap was
  needed. The paragraph was rewrapped anyway, as every touched paragraph
  is, since its old lines were filled to 80 source columns, not rendered.

**E12.** Unit A, "Routing across several levels" paragraph (block A2).
- Old: `This restriction is named the locality law ([D-065][d-065]), and fragments of the condition algebra follow the same law ([§14.2][s14-2]).`
- New: `This restriction is named the locality law ([D-065][d-065]). [Fragments](#g-fragment) of the condition algebra follow the same law ([§14.2][s14-2]).`
- Inventory: the `added` span for R2's sentence, split into two sentences.

**E13.** Unit A, the sketch's lead paragraph (block A3).
- Old: ``The root's input `trn` is a terrain field handle ([§4.4][s4-4]).``
- New: ``The root's input `trn` is a terrain [field handle](#g-field-handle) (an immutable query object its consumers evaluate, [§4.4][s4-4]).``
- Inventory: the `added` span for this sentence updated. New `added` span
  "(an immutable query object its consumers evaluate, §4.4)".

**E14.** Unit A, the ceremony paragraph (block A4).
- Old: `(a narrow, named interface kept deliberately thin), where one-level routing was mandatory in any case ([§8.8][s8-8]).`
- New: `(a narrow, named interface kept deliberately thin). One-level routing was mandatory at a generic seam in any case ([§8.8][s8-8]).`
- Inventory: A-035.

## Unit B

**E9.** Unit B, the walk-clause paragraph (block B1).
- Old: `Beside it stands the walk-compatibility clause, for a continuous consumer only.`
- New: `Beside it stands the walk-compatibility clause (the walk clause for short), for a continuous consumer only.`
- Inventory: C-007. New `added` span "(the walk clause for short)".

**E10.** Unit B, the marker-scalar paragraph (block B2).
- Old: `The producer's declaration and the entry are plain declarations the walk retypes, so the walk clause is decided in the structure step by retyping them at a marker scalar.`
- New: `The producer's declaration and the entry are plain declarations that the [leaf walk](#g-leaf-walk) (the framework's derivation of per-activation types) retypes. The walk clause is therefore decided in the structure step by retyping them at a marker scalar.`
- Inventory: C-018. New `added` span "(the framework's derivation of
  per-activation types)".

**E8.** Unit B, the abstract-entry paragraph (block B3).
- Old: `is abstract. **The walk clause decides an abstract entry on the whole declaration**, an entry whose leaves cannot be enumerated ([D-236][d-236]).`
- New: `is abstract. Its leaves cannot be enumerated. **The walk clause decides an abstract entry on the whole declaration** ([D-236][d-236]).`
- Inventory: C-023. The bold's words are unchanged.

**E5, E6, E7.** Unit B, the opaque-leaf paragraph (block B4). E5 is the
rewrap of the paragraph's broken line.
- E7 old: `(its output's entry in the signal table)`
- E7 new: `(the signal-table entry holding its output)`
- E6 old: `One consequence follows from that rule. A component that re-emits`
- E6 new: `Under that rule, a component that re-emits`
- Inventory: C-013 (E7), C-017 (E6), and the `added` span for the cell
  gloss (E7). E5 touches no span.

**E11.** Unit B, the failure-asymmetry paragraph (block B5).
- Old: `The walk clause also gives the two [contract](#g-contract) sides their failure asymmetry.`
- New: `The walk clause also gives the two sides of a [contract](#g-contract) (a component's declared interface) their failure asymmetry.`
- Inventory: C-031. New `added` span "(a component's declared interface)".

**RI-1 and E1 (B part).** Unit B, the unconnected-inputs paragraph. One
rewrap carries both.
- RI-1 old: ``([§8.6][s8-6]). The error, `UnconnectedInput`, fires``
- RI-1 new: ``([§8.6][s8-6]). The unconnected-input error, `UnconnectedInput`, fires``
- E1 old: `terminus fed by no [component](#g-component) is the root component's own`
- E1 new: `terminus fed by no component is the root component's own`
- Inventory: C-051 (RI-1), tagged `"ruling": "R6, RI-1"`. New `added` span
  "The unconnected-input error, `UnconnectedInput`,", also recorded under
  `added_rulings` as RI-1. C-052 (E1) normalizes the same and is unchanged.

## Unit C

**E4 and RP-2.** Unit C, §6.2's opening paragraph. RP-2's gloss folds into
E4's rewrap, so block C1 is replaced.
- Old: `Total wrench, total mass properties and total internal angular momentum are the examples.`
- New: `Total wrench (force and torque), total mass properties and total internal angular momentum are the examples.`
- Inventory: C-003, tagged `"ruling": "RP-2"`. New `added` span "(force
  and torque)", recorded under `added_rulings` as RP-2.

**E15.** Unit C, the parameters paragraph (block C2).
- Old: `**The parameters are the nominal port types and the arity**` and `as a walked type of [§7.2][s7-2]`
- New: `**The parameters are the [nominal](#g-nominal) port types and the arity**` and `as a [walked](#g-walked) type of [§7.2][s7-2]`
- Inventory: none changed. C-011 and R12's `added` span normalize the same.
  The bold's rendered words are unchanged.

**E3.** Unit C, the ownership-boundary paragraph (block C3).
- Old: `An assembly is a component of pure composition, with no dynamics of its own.`
- New: `An assembly is a component of pure composition.`
- Inventory: the `added` span for this sentence updated.

**E2.** Unit C, R11's bullet (block C4). Rewrap only, two-space hanging
indent, no word changed.
- Inventory: none changed.

**E17 and RP-4.** Unit C, the example paragraph of the idiom. One rewrap
carries both.
- E17 old: ``For example, the landing gear `Ldg` sums its three struts and exports `wrench`.``
- E17 new: ``For example, the landing gear `Ldg` sums its three legs and exports `wrench`.``
- RP-4 old: `The vehicle wires the systems totals into the rigid-body equations of motion.`
- RP-4 new: ``The vehicle, the assembly one level above the systems assembly, wires the systems totals into the rigid-body equations of motion. The block above places the `dynamics` child inside `Systems` instead, and both shapes are legal.``
- Inventory: C-049 (E17). C-051 (RP-4), tagged `"ruling": "R3, RP-4"`. New
  `added` spans "the assembly one level above the systems assembly" and the
  block sentence, both recorded under `added_rulings` as RP-4.

**E16.** Unit C, the paragraph after the example (block C5b).
- Old: `Junctions placed this way replace the tree walk. Each recursion step of FlightPhysics' tree walk becomes one visible junction`
- New: `Junctions placed this way replace FlightPhysics' tree walk. Each of its recursion steps becomes one visible junction`
- Inventory: C-042, C-052.

**RP-1.** Unit C, the frame paragraph.
- Old: `Frame responsibility is as in Flight.jl.`
- New: `Reference-frame responsibility is as in Flight.jl.`
- Inventory: C-055, tagged `"ruling": "R3, RP-1"`. Recorded under
  `added_rulings` as RP-1.

**E19.** Unit C, the do-not-bundle paragraph (block C6).
- Old: `Do not bundle the three quantities into one contribution struct.`
- New: `Do not bundle wrench, mass properties and internal angular momentum into one contribution struct.`
- Inventory: C-057.

**E18.** Unit C, the zero-total paragraph (block C7).
- Old: `The zero total thus becomes declared structure.`
- New: `The spelling makes the zero total declared structure.`
- Inventory: C-076.

## Skipped

None. Every item applied cleanly, and none changed a claim, its strength or
a citation. Each unit's rendered citations are the same multiset before and
after, and its bold spans render the same words.

## Effects beyond the sentence

- **E1** moves the `#g-component` link across units, from B into A.
- **E6** leans on its antecedent. "Under that rule" refers to the bold
  sentence before it, the identity rule for an opaque leaf.
- **E16** makes "its" in the second sentence refer to "FlightPhysics' tree
  walk" in the first.
- **E19** gives R13's "the three quantities" in the next sentence a near
  antecedent.
- **RP-4** points back to the `local_wires(::Systems)` code block, which
  sits above it in §6.2. It adds the code spans `dynamics` and `Systems` to
  the paragraph.
- **RI-1** puts the phrase "unconnected-input error" into §6.1, which spec
  2412 and 2882 at the base quote from §6.1.
- **E13** moves the §4.4 citation inside the new gloss's parenthetical. It
  stays in the same sentence.

## Orchestrator touches after step 6b

Scripted with `otouch.py` in the session scratchpad. Each touched paragraph
was refilled greedily at 80 rendered columns, and all three checkers print
`checks failed: 0`.

- **O-1 (unit A, the final verifier's E14 finding).** "kept deliberately
  thin)." becomes "kept deliberately thin, [§8.8][s8-8])." The split
  sentence lost its pointer to §8.8, which states it at base 3652–3654.
  Inventory: the added gloss span gains ", §8.8".
- **O-2 (unit C, RP-4's wording).** "The vehicle, the assembly one level
  above the systems assembly, wires" becomes "The vehicle, which holds the
  systems assembly beside its dynamics as Flight.jl's `Vehicle` does,
  wires". The old clause could read as §6.1's `Cessna172`, which sits right
  above `Systems` in that sketch. Source: `FlightPhysics/src/aircraftbase.jl`
  48–53 (`systems`, `kinematics`, `dynamics`). Inventory: RP-4's added span.
- **O-3 (unit C, RP-4's wording).** "The block above places" becomes "The
  `local_wires(::Systems)` block earlier in this section places". "Above"
  reached back 42 lines across a heading. Inventory: RP-4's added span.
- **O-4 (unit C, the final verifier's re-check).** "beside its dynamics"
  becomes "beside its `dynamics` child", so "its" cannot read as the
  systems assembly's. Inventory: RP-4's added span.

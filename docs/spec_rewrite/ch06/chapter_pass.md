# Chapter 6: the chapter pass (recipe step 5)

Read whole: `chapter_new.md` (338 lines), against `chapter_old.md`,
`brief.md` (R1 to R14), `tools/spec_style.md` and the base spec `b08afca`.

**Counts.** 19 EDITORIAL items (E1 to E19), 6 RULING items (R-1 to R-6).
Nothing serious. No claim is lost, no bold is doubled, and no pointer is
circular.

**How to apply.** Chapter line *n* is unit A line *n* (1 to 82), unit B line
*n* − 83 (84 to 165) and unit C line *n* − 166 (167 to 337). Each item gives
the current text and the replacement as normalized one-line spans, the form
the inventories use. Where an item changes a paragraph's wrap, the appendix
gives the whole paragraph after every EDITORIAL fix, wrapped to 80 rendered
columns. Items touching one paragraph are folded into one appendix block, so
apply the block, not the items one by one. The RULING items are not in the
appendix.

## Checks that passed

- **Bold.** 13 bolds, R4's table exactly: A 1 (D-207), B 5 (D-236, D-264
  twice, D-170, D-084), C 7 (D-037 four times, D-311, D-143 twice). Each sits
  on a headline clause, each has its D-citation in the same sentence, and no
  ruling is bold twice in the chapter. Against chapters 7 to 10 at the base,
  joined by paragraph (not by line, which misses wrapped citations): D-207 is
  bold once there, at §9.2 4032, on bullet 2 (R4's reading). D-170 is bold at
  §8.6 3136, 3141 and 3153 on its other rulings. D-084, D-264, D-037, D-143
  are bold nowhere in 7 to 10. D-311 bullet 3 is also bold at §13.7 (known,
  carry list). One near miss, not a double: §9.1 3831 bolds "The
  walk-compatibility clause is decided by retyping both declarations at a
  marker scalar" and cites D-236, but its "on the whole declaration at an
  abstract one" sits after the bold, unbolded. So D-236 bullet 1 is bold only
  in §6.1. Two of unit C's bolds carry a section pointer inside the bold
  span (lines 311 and 321). Chapters 7 to 10 do the same in 4 of 232 bolds,
  for example §9.5's "**An opaque leaf ([§4.3][s4-3]) embeds nothing into a
  store**", so these stand.
- **Roadmaps.** The opening's two sentences match §6.1's and §6.2's headings
  and order. §6.1's roadmap (lines 12 to 18) names "How far a path may
  reach", "Type-checking a wire" and "Connections per port", in that order.
  §6.2's (line 172 on) names its four `####` labels in order. §6.2's roadmap
  line is the wrap defect of E4.
- **Sentence rules.** No em-dash or en-dash. No mid-sentence colon outside
  headings and code. No sentence with two non-citation parentheticals. The one
  over-long sentence is E14's.
- **Pointers.** Every section pointer lands on content: §8.6 (wiring
  declarations, `output_wires`), §8.5 (container children), §4.4 (field
  handles), §14.2 (locality law), §8.3, §8.8, §13.3 (`resolve`), §4.3 (opaque
  leaf, base 546), §8.2 (the two clauses and the discrete-consumer reason,
  2417 to 2439), §9.1, §9.5, §13.7 (`Constant` 10044, `Freeze` 10070, the
  guidelines 9975, the gates 9966), §11.3, §7.2, §6.1, §6.2. §6.1 → §8.2 and
  §8.2 → §6.1 for "two clauses" is mutual but not circular: both sections
  state the clauses. No pointer leads to an entry that points back.
- **Duplicated facts.** None new. The root input is glossed once in §6.1 and
  once in §6.2, the assembly once per section, and §6.2 restates
  single-connection with a pointer to §6.1. These are per-section glosses and
  pointers, as spec_style asks. "Ordinary" junction components appears four
  times in §6.2 (lines 176, 216, 220, 261), as in the old text.
- **Glossary links.** One link per term per section. The exceptions are E1
  (component), E10 (leaf walk, used as "the walk" in §6.1), E12 (fragment),
  E13 (field handle) and E15 (nominal and walked in §6.2). `#g-store` (F16),
  `#g-the-freeze` (quoted message) and `#g-signal-table` (inside the cell
  gloss) rightly stay unlinked.
- **Reader-cold names.** `Cessna172`, `Systems`, `Ldg`, the legs, `trn`,
  `aero`, `pwp`, `ldg`, `dynamics`, `Wrench`, `VehicleWrenchSum`,
  `sum_ports!`, `Vehicle{NoVehicleSystems}` and `VehicleDynamics` are each
  introduced in place. FlightPhysics is introduced in §1 (base 186), and §7.2
  uses it bare too. Two cold uses remain: "wrench" as a quantity at line 169,
  before R12's clause at 198 (R-2), and "The vehicle" at line 275 (R-4, part
  of F6).
- **Define-before-use across unit boundaries.** Holds, apart from E10 ("the
  walk" in §6.1 is never named or linked) and R-2.
- **Word growth** (2,181 to 2,625). Most of the 444 words are ordered:
  glosses, R3's introducing clauses, the roadmaps, R2, R6, R7 and the D-048
  sentence. Three sentences buy nothing: "One consequence follows from that
  rule." (E6), §6.2's "with no dynamics of its own" (E3), and "the tree
  walk" repeated in two sentences (E16). The EDITORIAL items as a whole add
  about 25 words, mostly glosses that spec_style requires.

## EDITORIAL items

### Unit A

**E1. `#g-component` at its first use in §6.1 (known item 1).** Units A and
B. The first use of *component* in §6.1 is inside the assembly gloss (line
22). Unit B links it at line 161. Link it at line 22 with no gloss of its
own, since a gloss there would nest a parenthetical. The chapter opening
glosses the term, and unit C's rulings note that chapters 7 and 8 often link
it unglossed. Then drop B's link.
- A line 22. Current: `An [assembly](#g-assembly) (a component of pure
  composition) has three wiring`. Replacement: `An [assembly](#g-assembly) (a
  [component](#g-component) of pure composition) has three wiring`. The
  rendered width does not change, so no rewrap.
- B line 78. Current: `terminus fed by no [component](#g-component) is the
  root component's own`. Replacement: `terminus fed by no component is the
  root component's own`.

**E12. Split R2's sentence, and link *fragment*.** Unit A, lines 42 to 44.
The sentence carries two burdens, naming the law and extending it to
fragments. *Fragment* is a glossary term (`#g-fragment`, "the leaf node of the
condition algebra"), used here for the first time in §6.1 and unlinked. "Of
the condition algebra" already glosses it. R2's words stay.
- Current: `This restriction is named the locality law ([D-065][d-065]), and
  fragments of the condition algebra follow the same law ([§14.2][s14-2]).`
- Replacement: `This restriction is named the locality law ([D-065][d-065]).
  [Fragments](#g-fragment) of the condition algebra follow the same law
  ([§14.2][s14-2]).`
- Appendix block A2.

**E13. Link and gloss *field handle*.** Unit A, lines 48 and 49. *Field
handle* is a glossary term (`#g-field-handle`), first used in §6.1 here and
unlinked. The gloss takes the glossary's own words ("an immutable query
object … that consumers evaluate") and claims nothing more. The pointer moves
into the gloss's parenthetical, as line 35 does for container children.
- Current: `The root's input `trn` is a terrain field handle ([§4.4][s4-4]).`
- Replacement: `The root's input `trn` is a terrain [field
  handle](#g-field-handle) (an immutable query object its consumers evaluate,
  [§4.4][s4-4]).`
- Appendix block A3.

**E14. Split the seam sentence.** Unit A, lines 69 to 73. At 37 words it is
the chapter's longest sentence. The gloss of *seam* sits mid-clause, and a
relative clause follows it. Split after the gloss. "In any case" and the
pointer stay.
- Current: `It is the ceremony the design already pays almost everywhere,
  because every level of a realistic tree is a generic [seam](#g-seam) (a
  narrow, named interface kept deliberately thin), where one-level routing was
  mandatory in any case ([§8.8][s8-8]).`
- Replacement: `It is the ceremony the design already pays almost everywhere,
  because every level of a realistic tree is a generic [seam](#g-seam) (a
  narrow, named interface kept deliberately thin). One-level routing was
  mandatory at a generic seam in any case ([§8.8][s8-8]).`
- Appendix block A4.

### Unit B

**E9. Introduce "walk clause" as the short name.** Unit B, line 12 (chapter
95). §6.1 names the walk-compatibility clause once and then says "the walk
clause" eight times without saying it is the same thing. The spec cites
"the walk clause ([§6.1][s6-1])" by that name (base 10071), so §6.1 should
introduce it. "Walk-compatibility clause" stays verbatim.
- Current: `Beside it stands the walk-compatibility clause, for a continuous
  consumer only.`
- Replacement: `Beside it stands the walk-compatibility clause (the walk
  clause for short), for a continuous consumer only.`
- Appendix block B1.

**E10. "The walk" is the leaf walk. Name it, link it and gloss it.** Unit B,
lines 20 to 22 (chapter 103 to 105). "Plain declarations the walk retypes" is
the only place §6.1 says what does the retyping, and *walk* is never
introduced in §6.1. It is the leaf walk, which §6.2 links and glosses (line
206). The glossary's leaf walk applies to a continuous leaf's `u_types` and
`y_types` and pins the discrete tier wholesale, which covers both
declarations here. The gloss is §6.2's word for word. Splitting the sentence
keeps the causal link with "therefore". R1/M2's "the producer's declaration
and the entry" and "marker scalar" stay.
- Current: `The producer's declaration and the entry are plain declarations
  the walk retypes, so the walk clause is decided in the structure step by
  retyping them at a marker scalar.`
- Replacement: `The producer's declaration and the entry are plain declarations
  that the [leaf walk](#g-leaf-walk) (the framework's derivation of
  per-activation types) retypes. The walk clause is therefore decided in the
  structure step by retyping them at a marker scalar.`
- Appendix block B2.

**E8. The abstract-entry appositive dangles.** Unit B, lines 25 to 27
(chapter 108 to 110). The verifier's C-023 fix produced "on the whole
declaration**, an entry whose leaves cannot be enumerated". There the
appositive follows "declaration", so it reads as describing the
declaration. The old text put it on the entry ("For an abstract entry, whose
leaves cannot be enumerated, …"). A short sentence of its own keeps it on the
entry. It claims no cause, which was C-023's concern, and it stays outside
the bold.
- Current: `An [abstract entry](#g-abstract-entry) is an input entry whose
  declared type is abstract. **The walk clause decides an abstract entry on
  the whole declaration**, an entry whose leaves cannot be enumerated
  ([D-236][d-236]).`
- Replacement: `An [abstract entry](#g-abstract-entry) is an input entry whose
  declared type is abstract. Its leaves cannot be enumerated. **The walk
  clause decides an abstract entry on the whole declaration**
  ([D-236][d-236]).`
- Appendix block B3. The inventory span for C-023 changes. The bold's words
  do not.

**E5. Broken wrap in the opaque-leaf paragraph.** Unit B, lines 31 to 42
(chapter 114 to 125). Line 32 ends after "An opaque leaf" at 28 rendered
columns. Rewrap. Appendix block B4, which also carries E6 and E7.

**E6. Fold the filler sentence.** Unit B, lines 40 and 41 (chapter 123).
"One consequence follows from that rule." is a sentence the old colon left
behind, and it states nothing on its own. "Under that rule" keeps the
antecedent, the store's identity rule, which is the rule D-264's Rationale
gives for the pin ("hits the store's identity rule").
- Current: `One consequence follows from that rule. A component that re-emits
  a frozen handle pins that output too, so a handle's pin is a property of its
  chain ([D-264][d-264]).`
- Replacement: `Under that rule, a component that re-emits a frozen handle
  pins that output too, so a handle's pin is a property of its chain
  ([D-264][d-264]).`

**E7. The cell gloss uses *entry* in a paragraph about input entries
(optional).** Unit B, lines 35 and 36 (chapter 118 and 119). "an unpinned
entry is the producer's cell (its output's entry in the signal table)" puts
two senses of *entry* side by side. The glossary's compound for this sense is
"table entry". Putting the compound first makes the reading clear at once.
The glossary says "one concretely typed entry of the signal table, one per
output port".
- Current: `(its output's entry in the signal table)`
- Replacement: `(the signal-table entry holding its output)`

**E11. Gloss *contract* at its §6.1 link.** Unit B, lines 50 and 51 (chapter
133). §6.1 links `#g-contract` with no gloss. §6.2 glosses it "(a component's
declared interface)". Use the same gloss here. "The two sides of a contract"
says what "the two contract sides" says. "Failure asymmetry" stays verbatim.
- Current: `The walk clause also gives the two [contract](#g-contract) sides
  their failure asymmetry.`
- Replacement: `The walk clause also gives the two sides of a
  [contract](#g-contract) (a component's declared interface) their failure
  asymmetry.`
- Appendix block B5.

### Unit C

**E4. §6.2's opening runs to 145 rendered columns.** Unit C, line 6
(chapter 172). The roadmap sentences were joined onto one source line.
Rewrap lines 3 to 8. Appendix block C1. If R-2 is accepted, use R-2's
block instead.

**E15. Link *nominal* and *walked* at their first §6.2 uses.** Unit C, lines
30 and 33 (chapter 196 and 199). Both are glossary terms used unlinked in
§6.2. *Nominal*'s first use is inside D-311's bold. A link inside a bold has
precedent (§8.2 2371 and 2402) and changes no bold word. Neither takes a
gloss. The bold cannot take a parenthetical, and the next paragraph says
"written at nominal `Float64`". R12's clause already says what *walked* means
here.
- Current: `**The parameters are the nominal port types and the arity**`
- Replacement: `**The parameters are the [nominal](#g-nominal) port types and
  the arity**`
- Current: `as a walked type of [§7.2][s7-2]`
- Replacement: `as a [walked](#g-walked) type of [§7.2][s7-2]`
- Appendix block C2.

**E3. §6.2's assembly gloss sits beside a child named `dynamics` (known item
3).** Unit C, lines 54 and 55 (chapter 221). "With no dynamics of its own"
comes one sentence before "a child `dynamics` that consumes the total". The
two do not contradict, but the reader stumbles. Drop the tail. The gloss then
matches §6.1's word for word ("a component of pure composition"), and the
glossary's first words are "pure composition". The opening keeps the full
gloss. The paragraph's broken line (chapter 224, 35 columns) is rewrapped in
the same block.
- Current: `An assembly is a component of pure composition, with no dynamics
  of its own.`
- Replacement: `An assembly is a component of pure composition.`
- Appendix block C3. Update unit C's `added` entry.

**E2. R11's line runs past the wrap width (known item 2).** Unit C, line 73
(chapter 239), 98 rendered columns. Rewrap the bullet, lines 73 to 78, with
a two-space hanging indent. Appendix block C4. No word changes.

**E17. "Struts" for the legs of §6.1.** Unit C, line 108 (chapter 274). §6.1
calls `Ldg`'s three children "legs" (R3). §6.2 has the same `Ldg` sum "its
three struts". One thing gets one name. Flight.jl's `Ldg`
(`FlightApps/src/c172/c172.jl` 435 to 439) holds three `LandingGearUnit`s,
each containing a `Strut`. Both words fit the source, and "legs" matches
§6.1. The generic "A strut publishes `wrench`" at line 117 can stay.
- Current: `For example, the landing gear `Ldg` sums its three struts and
  exports `wrench`.`
- Replacement: `For example, the landing gear `Ldg` sums its three legs and
  exports `wrench`.`
- Appendix block C5a.

**E16. "The tree walk" twice in two sentences.** Unit C, lines 112 and 113
(chapter 278 and 279). "Junctions placed this way replace the tree walk.
Each recursion step of FlightPhysics' tree walk becomes …". Name the owner
once. R3's "FlightPhysics' tree walk" stays word for word.
- Current: `Junctions placed this way replace the tree walk. Each recursion
  step of FlightPhysics' tree walk becomes one visible junction at the level
  that owns the contributors.`
- Replacement: `Junctions placed this way replace FlightPhysics' tree walk.
  Each of its recursion steps becomes one visible junction at the level that
  owns the contributors.`
- Appendix block C5b.

**E19. "The three quantities" is far from its antecedent at an entry
point.** Unit C, line 122 (chapter 288). The quantities are named only in
§6.2's first paragraph, 120 lines up. "The hierarchical aggregation idiom" is
a `####` entry point, and R8 cut the census that once followed. Name them
where the rule is stated. "The three quantities" in R13's next sentence then
has a near antecedent. The same block fixes line 123, which R13 left at 81
rendered columns.
- Current: `Do not bundle the three quantities into one contribution struct.`
- Replacement: `Do not bundle wrench, mass properties and internal angular
  momentum into one contribution struct.`
- Appendix block C6.

**E18. "Thus" demotes the reason to a consequence.** Unit C, line 151
(chapter 317). The old **Why.** made this the reason for the `Constant`
spelling, and D-143's Rationale calls it the argument. "Thus" presents it as
a consequence of the spelling instead. The verifier listed this as minor and
offered this wording.
- Current: `The zero total thus becomes declared structure.`
- Replacement: `The spelling makes the zero total declared structure.`
- Appendix block C7.

## RULING items

**R-1. "Frame responsibility" uses a reserved word bare.** Unit C, line 119
(chapter 285). R3's text.
- Evidence. The glossary's `#g-frame` (base 12947) defines *frame* as
  one iteration of the loop. It says the frame is distinct "from the
  kinematic reference frames of the aircraft domain, which always appear
  compounded ("the b frame")". "Frame responsibility" is the reference-frame
  sense, bare. The next sentence's "common body frame" is compounded and
  fine. The old text had the same word, and R3 changed only "unchanged".
- Proposal: "Reference-frame responsibility is as in Flight.jl. Contributors
  publish in the common body frame, applying their own mounting transforms
  at source."
- Recommendation: accept. It changes one word of R3's sentence and no claim.

**R-2. "Wrench" is used in §6.2 before anything says what it is.** Unit C,
line 3 (chapter 169).
- Evidence. "Total wrench" opens §6.2. R12's clause, "`Wrench` is
  FlightPhysics' force-and-torque type", comes 30 lines later (chapter 198).
  §6.2 must be readable cold, and *wrench* is a mechanics term a software
  reader may not know. R3 and R12 placed the introduction at the type, not at
  the quantity.
- Proposal: gloss the quantity at its first use, with R12's own source
  (`dynamics.jl` 114 to 117, fields `F` and `τ`): "Total wrench (force and
  torque), total mass properties and total internal angular momentum are the
  examples." R12's clause stays. Rewrapped, with E4 folded in:

  ```
  Several physical quantities are totals over many contributors. Total wrench
  (force and torque), total mass properties and total internal angular momentum
  are the examples. In Flight.jl these totals come from tree walks. FlightPhysics'
  generated functions `get_wr_b`, `get_mp_b` and `get_hr_b` sum each quantity over
  a model tree. This section states the rule and the junction that carries it. It
  then covers what the explicit form buys, the hierarchical aggregation idiom,
  zero contributors and the cost.
  ```
- Recommendation: accept. The gloss claims nothing beyond R12's source.

**R-3. The glossary's *entry* omits the wiring sense §6.1 uses.** Outside
the chapter (Appendix D, `#g-entry`, base 12838).
- Evidence. `#g-entry` says the word is "never used bare". It lists table,
  input, executor, roster, batch and condition entries. §6.1 uses a seventh
  sense throughout: "An `input_wires` entry", "An entry of any of the three is
  a wire" (lines 25 to 27), "the re-export entry per level" (69), "Where the
  entries multiply" (73) and "an `input_wires` entry handing the obligation
  up" (158). It sits beside the input-entry sense of "Type-checking a wire".
  §13.3 (base 9425) says "A wiring entry". The chapter's usage is old and
  consistent. The glossary is incomplete.
- Proposal: add "wiring entry (an entry of `local_wires`, `input_wires` or
  `output_wires`, [§6.1][s6-1])" to `#g-entry`'s list. No chapter change.
- Recommendation: accept, as a track-2 or glossary edit after landing.

**R-4. "The vehicle" is cold, and it belongs to F6.** Unit C, line 109
(chapter 275).
- Evidence. "The vehicle wires the systems totals into the rigid-body
  equations of motion." No vehicle appears in §6.2 before
  `Vehicle{NoVehicleSystems}` at line 302, and §6.1's sketch has none. The
  sketch at lines 228 to 235 wires `Systems`' total into a child `dynamics`
  inside `Systems`, which is F6's disagreement. The brief's R3 notes that in
  Flight.jl a vehicle level sits between the aircraft and its systems.
- Proposal: rule F6 first. If the prose keeps the vehicle, introduce it in
  one clause, such as "The vehicle, the level above the systems assembly,
  wires …", and check that clause against Flight.jl. If F6 aligns the prose
  with the sketch, the sentence becomes "The `dynamics` child takes the total
  into the rigid-body equations of motion", and the cold name goes.
- Recommendation: decide with F6. Of the two, aligning the prose with the
  sketch is cheaper and leaves no cold name. The sketch is
  already labelled as describing only itself (R14).

**R-5. Two names for one restriction in "How far a path may reach".** Unit
A, lines 33 and 42 (chapter 33 and 42).
- Evidence. Line 33 says "The one-level rule covers all three wiring
  declarations". Line 42 says "This restriction is named the locality law
  (D-065)" (R2). A reader meets two names one paragraph apart, with nothing
  relating them. Elsewhere the spec keeps them apart. §13.3 (base 9382)
  calls the wiring check "the one-level rule (§6.1)". §14.2 (base 10330)
  calls the locality law "the one §6.1 states for connections, now in its
  third instance", and D-065 says "locality law = §6.1's, third instance". So
  the locality law is the general law, and the one-level rule is its
  machine-checked form for wiring.
- Proposal, if the owner wants the relation stated: "This restriction is the
  locality law, stated here for connections ([D-065][d-065])." That claims
  only what §14.2 and D-065 say.
- Recommendation: keep R2's text. The two scopes are correct and match the
  spec's other uses. The proposal is optional polish. It touches R2's
  wording and should not reopen the ruling.

**R-6. "Mounting transforms" against `#g-mounting`.** Unit C, line 120
(chapter 286).
- Evidence. The glossary's *mounting* is relocating a problem or tap set
  with `at(prefix, …)` (§14.9). "Their own mounting transforms" is the
  aerospace sense, a component's installation transform. Unlike *frame*, the
  glossary entry does not reserve the bare word, the use is compounded, and
  the old text had it.
- Proposal: none in the chapter. Optionally, add the domain sense to
  `#g-mounting` as a "distinct from" note, as `#g-frame` does.
- Recommendation: no chapter change.

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

# Depth audit: spec chapters 5 to 7 against the Part I depth rule

Scope: `docs/design/spec.md`, from "## 5. Evaluation order and feedthrough" to just before "# Part II". This was a read-only pass, and no repository file was edited. Each destination was checked by reading it. Word counts are rough (`wc -w` over the passage, less what Part I keeps). Chapters 5 to 7 hold about 12,200 words.

Format of each entry: **location**, the rule it breaks, the destination, whether the destination already has it, and what Part I keeps.

---

## Chapter 5

### §5.2

**M1. "Positional, `kwarg_decl`-reflected and slurping-keyword spellings are all closed" through "so there is nothing to select"** (the call-shape rationale paragraph, the closed spellings paragraph, and "`x_projection` alone stays positional").
- Rule 1. This is about the calling convention's spelling: why the bundle is one argument, which keyword encodings were rejected, and why `x_projection` is positional.
- Destination: §8.2, the preamble before "State and mode declarations". Its Engine example already says "stage and update functions destructure their bundle by name (§5.2)".
- Status: unique in the spec. Nothing in Parts II to IV states the two-argument hand-off, the fixed `fn(comp, args)` call shape, or the positional `x_projection`. The rejected spellings (`kwarg_decl`, the `_...` slurp) exist only in the log (D-341, the rejected list near "Keyword arguments via `Base.kwarg_decl` reflection"). Facts that must land in §8.2: the two-argument form, the `fn(comp, args)` call shape and its three reasons, the closed spellings with their D-074/D-341 citation, and `x_projection` positional.
- Part I keeps: a function sees only the views its bundle carries (the bundle law).
- **Borderline:** the bolded sentence "Every function receives exactly two arguments … one NamedTuple bundle" (about 50 words). The NamedTuple encoding is spelling. But "each function receives a defined set of named views" is the meaning that "What the views are" and the bundle law build on. I recommend that Part I keep a de-spelled version of this sentence and drop the destructuring examples.
- About 110 words, plus about 50 borderline.

**M2. "Destructuring a field that does not exist for the component fails at the probe with a `BundleFieldError`" through "is classified as a wrong-tier fact"** (three paragraphs: the diagnostic, "The mechanism behind the diagnostic is structured, not textual", and the wrong-tier classification).
- Rules 2 and 3. These paragraphs give the diagnostic kind, its payload, the `FieldError` interception mechanism and the fallback spelling.
- Destination: §13.2 ("One class of exception is recognized rather than merely framed") and Appendix C `BundleFieldError`.
- Status: mostly duplicate. §13.2 already covers the type-matched `FieldError`, the three-way classification and "nothing is recovered by reading message text". Appendix C covers the payload. Unique facts:
  - the "Julia ≥ 1.12" requirement;
  - the getproperty-wrapper fallback, which is in the log (D-341) but not in §13.2;
  - the worked message "`x_deriv` of `Foo` destructures `m`, but `Foo` declares no `m_init`";
  - the explicit list for the wrong-tier class: `x`/`m` are continuous-only and `s`/`Δt` discrete-only (D-195).
- Part I keeps: one law sentence, "a function that reads a name outside its bundle is an error". The bundle law table already implies it.
- About 180 words.

**M3. "The stage-1 hand-down carries the stage-1 *return*" … "comes from the return of the stage-1 probe (…). [§9.3] already sources the rule."**
- Rules 3 and 5. The law is about runtime: stage 2 sees what stage 1 returned in the same sweep. The text instead phrases it through the build's probe.
- Destination: §9.3 ("Probe arguments are sourced as follows").
- Status: duplicate.
- Part I keeps: "`y_x`/`y_s` is the stage-1 return of the same evaluation; a component with no stage-1 ports has no `y_x`/`y_s`."
- About 30 words.

**M4. Stage return law: "Stages are discovered by method existence" and "An empty `y = (;)` is a `DeadStage` build error at the probe … the inert-component check, applied to a single stage."**
- Rules 1 and 2. These sentences cover how stages are found, the diagnostic kind and the build step.
- Destination: §8.2 "Stage membership" for discovery, and §9.3 for `DeadStage`.
- Status: `DeadStage` is a duplicate (§9.3: "A stage returning bare `(;)` … is `DeadStage`"). "Discovered by method existence" is unique, and §8.2 "Stage membership" should get it. The link to the inert-component check (§8.1) is unique too, and small.
- Part I keeps: "a stage that exists produces at least one port".
- About 45 words.

**M5. Handler return law: "Padding forms such as `((;), m⁺)` and `(x⁺, (;))` do not exist" and "An unknown key gets did-you-mean against `{x, m}` in a `HandlerReturnKey` diagnostic. This is the same `FieldError`-shaped machinery …"**
- Rule 1 (a rejected spelling), Rule 4 (an argument against an alternative) and Rule 2 (the diagnostic kind).
- Destination: §9.5 "Handler returns"; the log for the padding forms.
- Status: duplicate. §9.5 states did-you-mean against `{x, m}` narrowed to the existing stores. D-341's rejected list already holds the padding forms.
- Part I keeps: the law sentences "A key is present iff …" and the per-key semantics (`x` complete, `m` a names subset), plus the two return examples.
- About 80 words.

### §5.3

**M6. "so that a name bound in an author's own module is unambiguous evidence of a forgotten import ([D-220])"**
- Rule 1. This clause gives the reason a name was chosen.
- Destination: §8.1 "The namespace" / "Names".
- Status: duplicate. §8.1 says "Those names are distinctive by design ([D-220]), so a foreign binding … is evidence of the missing import".
- Part I keeps: "The API spells the same objects as words. The correspondence is one to one." It also keeps the table.
- About 25 words.

**M7. "The names are deliberately non-exhaustive. Modes fold under the state … ride unnamed."** *Borderline.*
- Rule 1. The paragraph explains why the names leave out `m`, `t` and `ws`. But it also states something semantic: modes count as state for the feedthrough split. That is why it is borderline.
- Destination: §8.1 "Names".
- Status: unique in the spec. The log has it (D-075, D-342).
- Part I keeps: "modes are state for the feedthrough split".
- About 36 words.

**M8. "A leaf mixing the update laws, or declaring a store … of one tier and the update law of the other, is a build error, not a reading. The error is `DeclarationOnWrongTier`."**
- Rule 2.
- Destination: §8.2 "Completeness".
- Status: duplicate. §8.2 lists exactly these cases under `DeclarationOnWrongTier`.
- Part I keeps: "A stateful leaf's declarations agree on one tier."
- About 45 words.

**M9. "An empty stage is unwritable on purpose. A stage that would produce no port is the `DeadStage` error of §5.2." and "A declared output that no stage produces is `DeclaredNotProduced` ([§8.3]), at every tier and every level of the tree."**
- Rule 2.
- Destination: §8.3 and §9.3.
- Status: duplicate. §8.3 has `DeclaredNotProduced` with its remedy, and §9.3 has `DeadStage`.
- Part I keeps: "A declared output is produced by stage 1 or by stage 2, and by nothing else", and "A component exposes a state or mode field by returning it from `y_state`".
- About 50 words.

**M10. "`f_ode!`, FlightCore's fused in-place derivative function, already embodied the same economics. This design keeps those economics while adding checked ordering."** *Borderline.*
- Rule 4. This is prior-art history inside a Why paragraph.
- Destination: §7.4, or the log (D-015).
- Status: duplicate. §7.4's last prior-art sentence says the same.
- Part I keeps: nothing.
- About 30 words.

**M11. Execution order: "Discrete executor entries are absent from it by construction"** *Borderline.*
- Rule 3. The sentence describes how the executor implements the interior sweep.
- Destination: §9.7 "The execution form".
- Status: duplicate. §9.7 says "the interior bodies hold no discrete entries to test". §10.3 also covers it.
- Part I keeps: "RHS and trial evaluations run the continuous-only interior sweep, so discrete cells hold across the step."
- About 20 words.

**M12. Supervisory inputs: "[Appendix A] carries this as the same-tick reset entry. The C172X demo is the interactive Flight.jl demo … presupposes exactly this spelling."**
- Rules 4 and 5. These sentences point to a case study and an index.
- Destination: `companions/flight_case_studies.md` §3.
- Status: duplicate. The companion already states that the bumpless-engage answer of its *Mode engage* frame presupposes this spelling. Appendix A is an index and points back here anyway.
- Part I keeps: nothing. The PI code and the law stay.
- About 45 words.

**M13. "A flag-gated reset face on a library PI block is sugar over exactly that event. [Appendix A] carries the continuous-reset contract too."** *Borderline.*
- Rule 1. The sentence describes a library spelling.
- Destination: §13.7, or `companions/library_inventory.md`.
- Status: unique. I did not find the flag-gated PI reset face in §13.7 or in `library_inventory.md`.
- Part I keeps: nothing.
- About 25 words.

### §5.4

**M14. The strut/steering worked example, from "The canonical instance is the strut/steering pair" through "(`companions/migration_outline.md` records the migration)", including the before/after code block.**
- Rule 4. It is a worked domain case.
- Destination: the log (D-343) and `companions/migration_outline.md`.
- Status: duplicate. D-343 states the case in full (the `ψ_v` used only in the castoring branch, emitting `(engaged, ψ_cmd)`, computing `ψ_sw` inside the strut). `migration_outline.md` repeats it. The ASCII before/after diagram is the only unique piece, and it is presentation.
- Part I keeps: the rung's own law ("An input the neighbor consumes only in a fallback branch is the archetypal false dependency … Move the branch to its natural owner and the wire disappears") and a one-line pointer to D-343.
- About 140 words.

**M15. The "Split the component" rung: from "Its cost is stated where it bites" to "the two visibility spellings they reject".**
- Rule 4 (rejected alternatives: `unlisted`, `Private(T)`, D-034/D-055) and Rule 1 (`y_types`, the `StrutGeometry` bundle-port spelling).
- Destination: §8.3 "Visibility".
- Status: partial. §8.3's closing sentence already notes that the log rejects the `unlisted` flag. Unique facts for §8.3:
  - every intermediate shared across a split boundary becomes a declared, public, connectable, substitution-relevant port;
  - the mitigation is one struct-valued bundle port, not N loose ports, and its type becomes contract;
  - no visibility level is added for split orphans (D-194).
  The log has the `StrutGeometry` and `Private(T)` specifics (D-343).
- Part I keeps: the rung's first sentence (the residual remedy, taken when both halves belong to the component) and "the split's cost is binary visibility (§8.3)".
- About 110 words.

**M16. "The build diagnostic offers both exits explicitly … It reads 'cycle through `systems/aero` is artificial at port level …' … rather than dotting the hop onto the path ([§8.6], [§13.2])."**
- Rule 2. It gives the message text and the payload design.
- Destination: Appendix C `AlgebraicCycle`, and wherever §5.6's material lands (M18).
- Status: the payload (every dead hop, with member, input face and output port) is a duplicate in Appendix C. Unique facts: the message wording, and the ruling that the dead hop is a separate payload field rather than a dotted path (D-245).
- Part I keeps: nothing beyond the ladder. §5.6 says the cycle error offers both remedies.
- About 86 words.

### §5.5

**M17. "The build reports it as `AlgebraicCycle` ([Appendix C]). The diagnostic names every wire of the loop as a terminal pair in the canonical slash form …" and "The diagnostic states this caveat rather than offering the delay as a free remedy ([§13.7])."**
- Rule 2.
- Destination: Appendix C `AlgebraicCycle`, and §13.7 `UnitDelay`.
- Status: duplicate. Appendix C lists wires as terminal pairs in slash form. §13.7 says "The diagnostic ([§5.5]) therefore says so rather than offering the remedy as free."
- Part I keeps: "An algebraic loop is a build error", the three ways to break it, the tier-structure caveat of `UnitDelay` as a modeling statement, and "Implicit delays and per-step numerical loop solving are both closed".
- About 60 words.

### §5.6 (nearly all of it)

**M18. §5.6, the subsections "Detection and naming", "The tracer's two modes", "What tracing touches", "Classification" and "Caveats the diagnostic carries".**
- Rule 3. This is mechanism: topological-sort stall, SCC decomposition, global versus local set-tracers, seeding scope, the tracer blind spot, Dual-cleanliness, the order-free per-member evaluation at the probe point, `probe_value` synthesis, structural tracing of discrete members, recording the map source, and shipping unclassified on throw. Rule 2 also applies: the diagnostic kind and the payload.
- Destination: §9.1 "The nominal evaluation". Its bullet "The feedthrough graph is built … [§5.5] cycle rejection applies" is where cycle detection runs. A new "Cycle diagnosis" subsection could hang off it, or off §9.4 next to the "tracer activation" paragraph. Appendix C `AlgebraicCycle` already has the payload fields.
- Status: almost entirely unique. Outside Part I, the spec only has §9.4's paragraph separating the tracer activation from the cycle classifier, and Appendix C's payload list. Everything else must land in Part II: SCC naming and why neither stall residue nor a back edge works, both tracer modes and their semantics, the seeding scope, the blind spot, Dual-cleanliness ⇒ traceability, the classifier's inputs, every dead hop under either verdict, the structural-tracing caveats and the remedy-hint scope, the map-source field, and unclassified-on-throw. §9.4's "local variant is not the local set-tracer mode" disambiguation is a duplicate.
- Part I keeps two things:
  1. The section's opening law: "Tracing is diagnostic only, never relied on for correctness. Ordering correctness comes exclusively from the two-stage split."
  2. The definition of the verdict, as the meaning of "real" versus "artificial" that §5.4 uses: "A hop through a member holds iff that member's stage-2 function routes the entering face to the leaving port. The loop is real iff a cycle survives over holding hops, and artificial iff every cycle crosses a dead hop."
- **Borderline:** whether item 2 stays in Part I. I recommend keeping it, because §5.4 otherwise defines "artificial" only by example (rule 6).
- About 900 words move, and about 110 stay.

---

## Chapter 6

### §6.1

**M19. "An endpoint naming no port of the child it resolves to is an `UnknownPort` error, at either end of the wire"**
- Rule 2.
- Destination: Appendix C `UnknownPort`, and §9.1.
- Status: duplicate.
- Part I keeps: "Every connection endpoint names an immediate child and one of its faces."
- About 30 words.

**M20. The container-children sentences: "Container children … keep their key segment, so `"aircraft/2/face"` is one level and not two … A container declared name-transparent … is the exception."** *Borderline.*
- Rule 1. This is path encoding.
- Destination: §8.6 (its "Paths are slash-separated strings" paragraph) and §8.5 "Container children".
- Status: duplicate. Both state the key segment and bare keys.
- Part I keeps: "A container's elements count as immediate children (§8.5)". This is the semantic part the one-level rule needs. It is borderline because the sentence defines what "immediate child" means.
- About 70 words.

**M21. "Where the entries multiply, they are computed rather than typed, through `input_passthrough`/`output_passthrough` over a single authored feed list ([§8.8]). Parallel routes threading many boundaries are the signal …"** *Borderline.*
- Rule 1. These sentences name a helper and authoring advice. The ceremony-cost argument before them is Part I-level rationale and stays.
- Destination: §8.8 "One authored feed list".
- Status: duplicate.
- Part I keeps: the ceremony-cost sentences.
- About 45 words.

**M22. "Enforcement lives in the path-resolution primitive itself, `resolve` … An endpoint reaching past the immediate child is a `PathResolution` error … renames break loudly."**
- Rule 2.
- Destination: §13.3 ("The walk enforces two duties … The first is the one-level rule").
- Status: duplicate. "Renames break loudly" is the only small extra.
- Part I keeps: nothing.
- About 50 words.

**M23. "Type-checking a wire", all but the two clause statements.**
- Rule 2 and Rule 1. The subsection covers the following:
  - the `Float64`-activation definition of "nominal" and `WireTypeMismatch`;
  - "decided in the structure step by retyping them at a marker scalar";
  - the abstract-entry predicate "at the marker, or the same with every pinned leaf lifted to the marker";
  - the opaque-leaf/frozen-handle edge case;
  - the `WalkingFaceAtFrozenEntry` message and the `Freeze` remedy;
  - the failure asymmetry paragraph ("fails at the first nominal build … lurks until the first `Dual` activation").
- Destination: §8.2 "Input contracts" (its "**Two clauses check a wire**" paragraph) and §9.1 "The structure step" (its bound-check and walk-clause paragraphs).
- Status: largely duplicate. §8.2 and §9.1 restate both clauses, the marker-scalar decision, the abstract-entry rule (in short), `WalkingFaceAtFrozenEntry`, the opaque leaf admitted as the producer's cell, and `Freeze`. Appendix C carries the remedy message verbatim. §8.2 and §9.4 hold the output-side lurk. Unique facts:
  - (a) the full abstract-entry predicate with pinned leaves lifted to the marker. §9.1 says only "on the whole declaration at an abstract one".
  - (b) "a component that re-emits a frozen handle pins that output too, so a handle's pin is a property of its chain" (D-264, D-321), and "a discrete producer of a handle … is admitted the same way".
  - (c) the input-side half of the asymmetry, "an input has a build-time counterparty". §8.2's FFI paragraph implies it.
  These should land in §8.2. Note also that §8.2 currently says "[§6.1] … gives the remedies this violation's message carries". That pointer would need to point at Appendix C instead.
- Part I keeps:
  - the bound law ("the producer's nominal type must be a subtype of the consumer's entry; equality for a concrete entry");
  - the walk law ("for a continuous consumer, a walking producer leaf requires an unpinned entry; a pinned leaf satisfies either, because frozen values embed upward; a discrete consumer takes the bound law alone").
- **Borderline:** fact (b). It reads as semantics (where partials can flow), not enforcement. It could stay as one Part I sentence.
- About 420 words move, and about 100 stay.

**M24. Connections per port: "a two-producers build error, `TwoProducers`", and from "The check is a whole-tree property" through "`UnconnectedInput`, fires at the root build for any input whose obligation chain never terminates".**
- Rule 2. This is which build step decides the check, and the kind names.
- Destination: §9.1 (the intro says both checks are "decidable only at the root") and Appendix C (`UnconnectedInput`, `TwoProducers`).
- Status: duplicate, except for the "awaiting a wire from above" framing of an unfed child input inside one assembly declaration. That framing should land in §8.6 or §9.1.
- Part I keeps:
  - "Every input port takes exactly one connection", including across levels;
  - "an input's feed chain must end at a producer or at a root input; no silent defaults";
  - "Unconnected output ports are legal."
- About 110 words.

### §6.2

**M25. The `Junction` code block and the three paragraphs that follow: "The parameters are the nominal port types and the arity …", "The junction is a continuous leaf, so its contracts …" and "The Bool gates of [§13.7] are the same leaf …".**
- Rule 1. This is the library block's spelling: type parameters, the alias, the constructor, the `x_init = (;)` tier marker, the walk of its entries, and the library-inventory policy.
- Destination: §13.7 "The standard component library".
- Status: partial. §13.7 states "Arity and port types come from type parameters (D-311)", the `|`/`&` gates, the inventory and the three guidelines. Unique facts for §13.7:
  - the `Junction{In, Out, N, F}` struct and method definitions (§13.7 shows `UnitDelay`, `Constant` and `Freeze` code but not `Junction`);
  - `const SumJunction{V, N}`;
  - the custom-fold form `Junction{In, Out, N}(f)`, which infers `F`;
  - "an input entry at `Wrench{Float64}` is the tolerant form; walking, frozen and root-input contributors are all admissible behind it".
  Back-pointers would need retargeting: §8.1 cites "`SumJunction{Wrench{Float64}, 3}` ([§6.2])" and §8.5 cites "the arity-via-computed-contracts pattern [§6.2] uses for `Junction`".
- Part I keeps: the bolded law ("N-to-1 physical aggregation is expressed by ordinary junction components and explicit wires"), "no framework aggregation mechanism", and a one-line description: "a junction is an ordinary stateless component with N same-typed inputs and one output, computing a fold its instance holds (§13.7)". The `local_wires(::Systems)` example stays as illustration.
- About 250 words.

**M26. "What the explicit form buys", the last bullet ("For the handful of real sites, a named site-specific junction … `VehicleWrenchSum` …").** *Borderline.*
- Rule 1 and Rule 4. This is authoring advice about one spelling against another.
- Destination: the log (D-037 covers "named site-specific", per its summary line) or §13.7.
- Status: duplicate in the log.
- Part I keeps: the other bullets. They argue the law in Part I terms, and "fold order is author-visible" is itself a law.
- About 60 words.

**M27. Hierarchical idiom: "For Flight.jl's Cessna 172 model that is about four junctions and fifteen wires …", "Do not bundle wrench, mass properties and internal angular momentum into one contribution struct …" and "A `sum_ports!`-style helper … is guarded-addition sugar".** *Borderline.*
- Rule 4 for the case figure and the argument against bundled contribution structs. Rule 1 for a helper's spelling.
- Destination: the log (D-037). Its rejected list carries "Bundled wrench/mass/momentum contribution structs: ragged contributors →".
- Status: the bundling argument is a duplicate in D-037. The C172 count and `sum_ports!` appear unique to the spec. I did not find `sum_ports` in the log.
- Part I keeps: the bolded idiom, its forcing argument, the `Ldg`/`Systems` example, and the frame-responsibility sentence.
- About 120 words.

---

## Chapter 7

### §7.1

**M28. "The structure step refuses a field outside the vocabulary as `IllegalStateLeaf` ([§9.1]). [§8.2] shows the kind's messages."**
- Rule 2.
- Destination: §9.1 and Appendix C.
- Status: duplicate.
- Part I keeps: nothing. The closed vocabulary is stated just before.
- About 20 words.

**M29. "The reconstruction is field loads at known offsets, register-level, at zero cost."**
- Rule 3. The sentence describes the buffer's mechanics.
- Destination: §9.7.
- Status: duplicate in substance (§9.7 "Views and construction" and "Cell storage").
- Part I keeps: "It reconstructs the typed immutable state value … at each evaluation."
- About 15 words.

**M30. "'Ephemeral' is literal. An isbits view materializes in the caller's frame … This buffer-unchanged-within-a-sweep rule is exactly the legality condition of the code generator's CSE …"**
- Rule 3.
- Destination: §9.7 "Views and construction".
- Status: duplicate. §9.7 states CSE and ties it to "[§7.1]'s buffer-unchanged-within-a-sweep rule".
- Part I keeps: "The buffer is authoritative, and typed values are ephemeral reconstructions. Nobody outside the framework holds a mutable reference to state. The buffer is unchanged within a sweep." The last sentence is the law §9.7 cites, so it must stay.
- About 90 words.

**M31. "The vocabulary is closed because views must materialize without running anyone's invariants … `reconstruct(flatten(x)) == x` … no `reinterpret` …"** *Borderline.*
- Rules 3 and 4. It is a Why paragraph, partly in implementation terms (constructor bypass, `reinterpret`, memory layout).
- Destination: §9.7, if it moves.
- Status: unique.
- Recommendation: keep. It argues a Part I claim (the closed vocabulary), and the round-trip identity is close to Part I terms.
- About 75 words.

**M32. "The conformance predicate is structural. *Each field of `x_deriv`'s return scatters into its field's block at `T`* ([§9.5] states the check) … There is deliberately no `derivative_type` hook ([D-190])."**
- Rule 2 (the check) and Rule 4 (a rejected alternative).
- Destination: §9.5 "Per-function predicates", and the log for D-190.
- Status: duplicate. §9.5 states the same predicate and says it makes completeness structural. D-190 is literally "reject a separate derivative_type declaration".
- Part I keeps: "`Ẋ` has exactly `X`'s shape at the activation scalar", the attitude example, and "derivative completeness is structural".
- About 50 words.

**M33. "FlightCore's pattern was a flat `Vector` read through `ComponentArrays` views … this design buys five things" and the five bullets.**
- Rule 4. It argues against a prior pattern, with migration history (`get_x_ss` deletion).
- Destination: `companions/migration_outline.md`, or the log (D-010/D-072).
- Status: mostly unique. The `get_x_ss` deletion is restated in §14.9 ("the promised `get_x_ss` deletion"). `ComponentArrays` appears nowhere else in the spec or the log. Two bullets restate Part I claims made above: no aliased views, and structural completeness. "The flat vector still exists" (integrators, trim, HDF5, linearization get arrays) is a Part I-level claim.
- **Borderline:** whether that "flat vector still exists" sentence stays in Part I.
- Part I keeps: possibly that one sentence.
- About 148 words.

### §7.2

**M34. Consumer 4: "It fails with a `MethodError` or an `InexactError` at the offending line."** *Borderline.*
- Rule 2.
- Destination: §14.8 "The AD obligation, scoped" and §9.4.
- Status: duplicate in substance ("the Dual probe detonates pinned intermediates with a culprit-naming `InexactError`").
- Part I keeps: "A `T = Dual` sweep fails loudly on any Float64-pinning."
- About 20 words.

**M35. Walked class: "Constructors infer `T`, so call sites don't change, and `@kwdef` defaults pin the no-argument case to `Float64`. `@kwdef` is Julia's keyword-constructor macro."**
- Rule 1. This is a constructor-spelling convention.
- Destination: §8.2, or `companions/library_inventory.md` (the keyword-constructor convention).
- Status: unique in the spec.
- Part I keeps: "Walked: the payload and value types constructed during evaluation", with the `FrameTransform` example.
- About 30 words.

**M36. The paragraph "The declaration layer keeps this scoping legible … Every declaration but the allocator is written at nominal `Float64`. One walk retypes it … `Pinned{P}` … Nothing anywhere comes from inference through user code."**
- Rule 1. It says how the scoping is spelled per leaf.
- Destination: §8.2, its preamble (by-value/by-type/by-allocation bullets) and "Input contracts".
- Status: duplicate. §8.2 states nominal `Float64`, the walk, `Pinned{P}`, the wholesale discrete pin, and (in §8.1) no reliance on inference.
- Part I keeps: "Participation is per leaf. A continuous leaf follows the activation scalar unless declared pinned, and the discrete side pins wholesale." The pointer to the embedding guarantee becomes rule-6 gap G1 below.
- About 120 words.

**M37. Lookups: from "Interpolations.jl, the interpolation package Flight.jl's lookup tables use, evaluates generically …" through "the pattern for wrapping non-Julia black boxes ([D-266])".**
- Rules 4 and 1. This is library-specific authoring guidance.
- Destination: §14.8 "The AD obligation, scoped" (its C172 audit bullet on `Interpolations.jl` and cubic over linear) and §14.10 (the local derivative rule).
- Status: partial. §14.8 has cubic-over-linear. §14.10 has the local derivative rule as the AD-opaque remedy. D-307 records the caveats as "guidance, not rulings". Unique facts: the `BSpline`/`scale`/`extrapolate` coverage, and `Interpolations.gradient` as the manual chain-rule escape hatch.
- Part I keeps: the bolded law "table data is a pinned parameter and the query coordinate is walked traffic".
- About 90 words.

**M38. "Three rules are author-facing" and the numbered list (no `::Float64` argument annotations, no pinned intermediates, no `::SomeType{Float64}` return annotations).**
- Rule 1. These are rules about spelling.
- Destination: §8.2, or Appendix A as an index entry with §8.2 as owner.
- Status: unique in the spec. The log has it (D-307 "fixes the three rules").
- Part I keeps: nothing beyond "the entire continuous evaluation path is generic over `T <: Real`".
- About 45 words.

### §7.3

**M39. "The structure step checks every `s_init` and `m_init` field and reports a violation as `IllegalStoreField`."**
- Rule 2.
- Destination: §9.1 and Appendix C.
- Status: duplicate. §9.1 says "The isbits rule is checked on `s_init` and `m_init` field by field".
- Part I keeps: the isbits-or-`Symbol` law.
- About 25 words.

**M40. Workspace declaration spelling: from "**A workspace is declared by allocation**" through the `ws_init(c::KF, ::Type{T})` block, "**`ws_init(::C, ::Type{T})` takes the activation scalar on both tiers**", the "State and cells re-scalar through the walk" paragraph, and the "`undef` spelling … The `init` in `ws_init` means *establish*" paragraph.**
- Rule 1. This covers the declaration's signature, why it takes `T`, the recommended `undef` spelling, and why the name was chosen.
- Destination: §8.2, its preamble ("A *by-allocation* declaration is the exception … `ws_init(c, T)` takes it on both tiers") and "State and mode declarations" ("The workspace is the exception to that convention. It is declared *by allocation*").
- Status: mostly duplicate. Unique facts:
  - "a discrete allocator receives `Float64` at every activation";
  - "`x_init`, `s_init`, `m_init` and the contract declarations take the component alone". §8.2 has this as "Every declaration … but the allocator takes the component alone", so it is effectively a duplicate;
  - the `undef` idiom;
  - the `init` = *establish* naming note (D-220).
  §8.1 points to "§7.3" for the KF example, and that pointer would need repointing.
- Part I keeps: "A workspace is allocated per activation, at that activation's scalar; sizes come from the instance." (borderline as to whether even that is Part I)
- About 200 words.

**M41. "Under a `Dual` activation the allocator is called at `Dual`, and the in-place math runs through Julia's generic fallbacks. No BLAS is involved. Activations probe and linearize. They don't run marathons." and "The allocator is called once per activation and once per scratch-store set ([§14.8]) … mistyped scratch detonates loudly at the `Dual` probe."**
- Rules 3 and 2. This is allocation bookkeeping and the failure site.
- Destination: §9.3 (where `ws` is allocated at the probing scalar, D-115) and §14.8 "Scratch stores".
- Status: partial. §9.3 has the allocator invocation at the probing scalar. Unique facts: "once per scratch-store set" (§14.8 lists the scratch set's contents but not `ws`), the Dual/no-BLAS performance note, and the Dual-probe detonation.
- Part I keeps: nothing.
- About 100 words.

**M42. "Idioms": the KF workspace-plus-snapshot idiom, the PRNG idiom with its `Noise` code block, the `Xoshiro` allocation note, the SArray "codegen catastrophe" paragraph, and the "practical ceiling is a few KB" paragraph.**
- Rule 4 (worked examples) and Rule 1 (spelling idioms).
- Destination: there is no current Part II home. Candidates are §8.2 "State and mode declarations" or a companion (`pid_anti_windup.md`/`linear_blocks.md` style).
- Status: unique in the spec. The log holds the positions (D-013 "workspace + snapshot idiom", D-231 PRNG and the `Xoshiro` escape note).
- Part I keeps one law sentence each:
  1. "Heavy algorithms do their in-place math in the workspace and return an isbits snapshot as the new state; snapshot values are for storage, never arithmetic."
  2. "A PRNG's generator lives in the workspace, and the values that determine its next draw are state in `s`, which is what makes replay deterministic."
  The second is semantic (rule 6), so it must stay.
- About 230 words move, and about 50 stay.

### §7.4

**M43. §7.4, the four-step arc and the prior-art paragraph.**
- Rule 4. It is history and prior art ("how we got here"), arguing against earlier designs.
- Destination: the log, which already holds each step (D-006, D-015, D-016, D-035). The Simulink DWork precedent is in D-194. A companion could hold a narrative if wanted.
- Status: the steps are duplicates in their entries. Unique pieces: the arc as one narrative, and the MTK/FMI comparison sentences. Only the DWork part is in D-194.
- Part I keeps the last paragraph, on the computer/integrator split: it "remains fully expressible without any framework support", is the idiom when factoring earns reuse, and has its examples. §5.3 points to "[§7.4] … the full statement, including when the factoring earns its keep".
- **Borderline:** the "four components, thirteen connections" comparison inside that paragraph is a case figure (Rule 4). I did not find it in the log, so it would have to land somewhere before deletion.
- If §7.4 shrinks to that paragraph, the §7 intro and §5.3 pointers need adjusting.
- About 380 words move, and about 70 stay.

### §7.5 (nearly all of it)

**M44. §7.5 "Allocation policy: a scoped invariant", all of it.**
- Rule 3. Budgets are explicitly mechanism that "lives where it runs". Rule 2 also applies: "CI-enforced at the measurement seam that `phase_bodies` exposes" and the documented tolerance.
- Destination: §9.7 "The measurement seam". It already calls itself "the [§7.5] measurement seam" and enforces the budgets. Logging goes to §11.2, and "Event firings are not recorded" goes to §11.2 or §11.5.
- Status: partial.
  - Duplicate: publication is not a phase body (§9.7), per-body tolerance granularity (§9.7), the log retaining snapshot references with one allocation per boundary and `sizehint!` (§11.2), field handles riding as references to build-time-frozen data (§11.2, which cites §7.5 for it), and stopped-sim allocation tolerance (cited in §14.8).
  - Unique: the three reasons (jitter, unattended throughput, the canary); the scope ruling (stepping loop only; D-135, D-305); the three budgets' membership (the hot path includes guards and both `x_projection` positions; ticks and handlers are zero by idiom); the snapshot's fields versus "not `isbits`" claim; "Event firings are not recorded" (D-309), with its remedy and the event-stream guarded addition; and the arena / `GC.gc(false)` tools.
  - About 19 citations of `[§7.5]` in Parts II to IV would need repointing, for example at lines near §8.1 "The reason is how entries of the executor are typed", §9.7, §11.2, §14.8 and Appendix B.
- Part I keeps: arguably nothing, since allocation is not what a model computes.
- **Borderline:** "Event firings are not recorded" is an observability fact rather than a budget. It belongs in Part III either way.
- About 569 words.

---

## Rule-6 gaps local to chapters 5 to 7

**G1. The embedding guarantee.**
- §7.2 says "Safety of the substitution rests on the embedding guarantee stated in [§9.5]". §6.1 relies on "frozen values embed upward under any activation".
- Part I never states the law itself. Only its §9.5 form exists: a `Float64` observed where the activation scalar is expected is embedded as a constant with zero partials, and this is exact because promotion never silently strips partials (no lossy `Dual → Float64`).
- §7.2's consumer-1 paragraph has the special case ("a frozen discrete cell is a constant with zero partials").
- Place: §7.2, one or two sentences, after the walked/pinned/exempt classes. This also removes a rule-5 dependency, because §7.2 currently cannot be read without following the pointer.

**G2. Output conformance: exact types, pairing by name, one shape per branch.**
- §5.2's stage return law fixes only the names ("returns its port NamedTuple, and nothing else"), and §4.2 says an undeclared result is an error.
- Part I never states the following:
  - each returned port value must carry exactly its declared type at nominal, with no convert-on-write;
  - returns pair with ports by name, so field order means nothing;
  - every branch returns the same shape.
- §9.5 ("Exact match and embed-accept", "Pairing by name") and §8.3 (the branch-shape rule) mechanize these.
- Place: §5.2 "The stage return law", in about two sentences.

**G3. Firing-budget exhaustion semantics.**
- §5.3 "Step boundaries" names the firing budget ("the per-boundary cap on how often each event fires"), but Part I never states what happens at the cap.
- §10.6 rules it: once an event has used its budget at a boundary, its further edges there are lost, every other event iterates normally, and the run continues with a warning. That is semantic. It changes which transitions the model takes.
- Place: §5.3 "Step boundaries", one sentence after the §10.6 pointer.

**G4. The opaque-leaf identity rule.** *Borderline.*
- §6.1 says "**The identity rule for an opaque leaf governs a store, never a wire** ([§9.5])" without stating the rule. The rule: an opaque leaf is accepted into a store only by identity and embeds nothing. That is a rule-5 dependency.
- If M23's opaque-leaf material moves to §8.2, the gap goes with it. If it stays, §4.3's opaque-leaf paragraph needs one clause stating the identity rule.

**G5. The definition of an artificial loop.** *Borderline, tied to M18.*
- §5.4 defines "artificial" by its canonical example and by "port-level acyclic and stage-level cyclic". The precise verdict (dead hops over the cluster) lives in §5.6's "Classification".
- If §5.6 moves wholesale, Part I loses the definition. Hence the recommendation in M18 to keep the verdict's two sentences.

I checked and did not count these as gaps, because Part I states them: zero-order hold (§1, §3.2), edges and priors (§2.1), the epoch rule and one-event-per-component-per-round (§5.3), "republishing from `s⁺` is rejected" (§5.3), the handler per-key semantics (§5.2), and "the discrete tier never runs at another scalar" (§7.3).

---

## Non-findings worth noting

- §5.1 "The hot loop runs a flat list of `(component, stage)` pairs, with no runtime graph logic ([D-086])". §9.7 cites this back as the "zero runtime graph logic ([§5.1])" property. I left it as a Part I claim.
- §5.3 "Mathematical symbols and API names are two vocabularies" and the symbol table. These are labels for concepts Part I defines, so they are fine under rule 1.
- §5.3 PI code block, landing-gear reset example, §6.1 `Cessna172` routing sketch, and §6.2 `local_wires(::Systems)`. These are brief illustrations, so they are fine.
- §6.2 "Zero contributors" and "The cost". They are argued in Part I terms and stay.

---

## Tally

| | count | words |
|---|---|---|
| Passages flagged (M1 to M44) | 44 | |
| Whole passages marked borderline (M7, M10, M11, M13, M20, M21, M26, M27, M31, M34) | 10 | about 450 |
| Partial borderlines inside moving passages (M1 core sentence, M18 item 2, M23(b), M33 flat-vector line, M43 figure, M44 event-firings line) | 6 | |
| Passages that move (excluding whole borderlines) | 34 | about 5,000 |
| Pure duplicates (destination already states it all) | 16: M3, M5, M6, M8, M9, M12, M14 (bar a diagram), M17, M19, M22, M28, M29, M30, M32, M36, M39 | about 900 |
| Carry unique content that must land first | 18: M1, M2, M4, M15, M16, M18, M23, M24, M25, M33, M35, M37, M38, M40, M41, M42, M43, M44 | about 4,100 |

Part I would lose about 5,000 words from chapters 5 to 7, about 40% of their 12,200. That rises to about 5,450 if every borderline item moves. The bulk is in three places: §5.6 (about 900), §7.5 (about 570) and §6.1 "Type-checking a wire" (about 420). Then come §7.4 and §7.3's workspace and idioms (about 380 and 530). Additions for the rule-6 gaps G1 to G3 come to about 100 words.

Back-pointers that would need retargeting after the moves:
- §8.1 to §6.2 (`SumJunction`) and to §7.3 (the KF `ws_init`);
- §8.5 to §6.2 (`Junction` pattern);
- §8.2 to §6.1 (the `WalkingFaceAtFrozenEntry` remedies);
- §9.4 to §5.6 (the tracer activation and classifier);
- §9.7 to §7.1 (the CSE rule, which stays) and to §7.5;
- about 19 citations of §7.5 across Parts II to IV and Appendix B;
- Appendix C `AlgebraicCycle` to §5.6.

# Unit G claims: §13.7 and §13.8.

old: ### 13.7 Tooling consequences: face routes and the component library
tag: X

old: Termination chains are the second structural customer of computed interface connections, after generic-holding contracts.
new: Generic-holding contracts (each a component's declared interface) are a structural customer of computed interface connections
tag: R
ruling: R6
note: F58. The cut clause is "Termination chains are the second structural customer", stale since D-316 (a stop request is read where it is, with no re-export). Generic-holding contracts stay the customer, now the only one named.

added: (each a component's declared interface)
# contract's first-use gloss, from the glossary entry: "`u_types` states its requirements ... `y_types` states its public ports".

old: Computed connections are therefore prominent in this section.
new: which are therefore prominent in this section.
tag: R
ruling: R6
note: F58, the dictated relative clause.

old: Two commitments follow, a library and an idiom.
new: D-062 makes three tooling commitments for them, namely the passthrough helpers' predicate, the routes `show(::Structure)` prints for each root face (the name a port wears on its component's boundary), and a standard library of components (the units of modeling, each a leaf or an assembly of components).
tag: R
ruling: R6
newcites: D-062
note: F58 and F67, the dictated sentence; "namely" replaces the colon, and "the face routes `show(::Structure)` prints" becomes "the routes `show(::Structure)` prints for each root face" (verifier fix: `show` prints only the root's routes), so face takes its first-use link and gloss. `Structure` is first used bare here, inside the code span; its link and gloss sit at its first prose use, the kept "`Structure` (…) has one" sentence after it. D-062's Position: "Three tooling commitments are made", predicate selection, face routes, the library.

added: (the name a port wears on its component's boundary)
# face's first-use gloss, the glossary's own words; face's first use moved here from the bold sentence.

added: (the units of modeling, each a leaf or an assembly of components)
# component's first-use gloss; component's first use moved into the opening.

added: The section covers the predicate and the face routes first, then the standard component library and the component test rig.
# parts sentence; the old opening named none.

old: The passthrough helpers take a predicate.

old: `select` is the third selector beside `except` and `only`, on `input_passthrough` and `output_passthrough` alike (§8.8, D-251).

old: It stays explicit at the declaration site, evaluated at build, and printable.

old: That is the blessed side of the auto-bubbling line, where the author writes down the rule and the build evaluates it into inspectable data.
new: That is the blessed (explicitly sanctioned where a neighboring practice is forbidden) side of the auto-bubbling line, where the author writes down the rule and the build evaluates it into inspectable data. Auto-bubbling means promoting an unconnected input automatically to a root input, one of the root component's own input faces (D-322).
tag: R
ruling: R10
newcites: D-322
note: R10's gloss of "auto-bubbling" in its own sentence, D-322 cited outside the gloss. D-322 bullet 1: "An unconnected input is never bubbled up automatically. Auto-bubbling would promote a forgotten wire silently to a live root input." root input's first use moved here, so its link moved with it; its gloss is the glossary's "the root component's own input face".

added: (explicitly sanctioned where a neighboring practice is forbidden)
# blessed's first-use gloss, from the glossary entry.

added: , one of the root component's own input faces
# root input's first-use gloss.

old: Every artifact renders itself through `show` (§9.2, D-257).
tag: R
ruling: R4
note: M60. The one plain sentence R4 dictates; its bold goes (R5, a double of §9.2's bold).

old: `Structure` (the structure step's product, the components, wires, faces and tiers) has one.
note: kept, unlike the rest of M60's list, so `Structure` takes its link and gloss at its first prose use before `show(::Structure)` owes its routes (verifier fix).

old: So does `Outputs` (the nominal evaluation's product, the port classes and the execution order).
new: `show(::Outputs)` prints the execution order with each port's class.
where: docs/design/spec.md
tag: R
ruling: R4
note: M60; §9.2. The gloss is the glossary entry for `Outputs`.

old: So does `Events` (the nominal evaluation's event tables), which prints each component's event names with their policies.
new: `show(::Events)` prints each component's event names with their policies.
where: docs/design/spec.md
tag: R
ruling: R4
note: M60; §9.2.

old: So does `Schedule` (the typed per-component `(D, Φ, Δt)` tick table).
new: `show(::Schedule)` prints the rows and the hyperperiod chart.
where: docs/design/spec.md
tag: R
ruling: R4
note: M60; §9.2. The gloss is the glossary entry for `Schedule`.

old: So do `Build` and `Deployment` (the scalar-free artifact the grid parameters fix).
new: `show(::Build)` and `show(::Deployment)` print a summary and their parts.
where: docs/design/spec.md
tag: R
ruling: R4
note: M60; §9.2. The gloss is the glossary entry for `Deployment`.

old: There are no accessor functions returning the tables alongside.
new: Each artifact renders itself through `show`, with no accessors
where: docs/design/spec.md
tag: R
ruling: R4
note: M60; §9.2's bold, D-257.

old: `show(::Build)`'s parts include the events.
new: `show(::Build)`'s parts include the events, and a line of the feedthrough edges between the outputs table and the events table.
where: docs/design/spec.md
tag: R
ruling: R4
note: M60; §9.2.

old: Between the outputs table and the events table it prints a line of the feedthrough edges (instantaneous input→output dependences).
new: `show(::Build)`'s parts include the events, and a line of the feedthrough edges between the outputs table and the events table.
where: docs/design/spec.md
tag: R
ruling: R4
note: M60; §9.2. The gloss is the glossary entry for feedthrough.

old: The edges are derived from the structure's connections and the producers' stage-2 names (D-261).
new: The edges are derived from the structure's connections and the producers' stage-2 names.
where: docs/design/spec.md
tag: R
ruling: R4
note: M60; §9.2 states it in its D-257 list; D-261's bullet-2 extension rides in D-257's own extension of 2026-09-22.

old: `show(::Structure)` owes face routes.
new: `show(::Structure)` owes face routes (D-257).
tag: C
newcites: D-257
note: the bold stays, its headline on D-257 bullet 3 ("The face-route printer joins `Structure`", amended 2026-09-30: built, prints the root's routes); §9.2 states it plain with a pointer here. Its face link moved to the opening's first use.

old: For every root face, that means the resolved chain down to the producing terminal, printed as one line per chain (`crashed → aircraft/crashed → aircraft/monitor/out`).
note: the example route stays (F58: still a valid route).

old: Once faces are computed rather than hand-listed, "what does this face actually reach" is a question the artifact must answer, not the reader.

old: `show(::Structure)` derives each face's routing chain from the declared wires and prints the root's routes (D-257, D-315).

old: Each line joins the hops with `→` and ends at the terminal.

old: An input face that fans out prints one line per consumer.

old: The same rendering serves the wiring diagnostics, which already carry endpoint paths.
new: The wiring diagnostics name endpoints in the same slash form.
tag: R
ruling: R6
note: F59, the dictated sentence.

old: #### The standard component library
tag: X

old: A standard component library makes good on the junction promise (§6.2).
tag: R
ruling: R5
note: the bold goes: a reason, not the ruling's headline; the bold moves to "library blocks are ordinary components" with D-062. Its component link moved to the opening's first use.

old: That promise rests on explicit junctions being cheap.

old: A junction hand-written per arity per type is not cheap.

old: The junctions, summing junctions and Bool gates alike, are the library's seed (D-062).

old: The starting inventory holds the `Junction`, with `SumJunction{V, N}`, `Or{N}` and `And{N}` as its named forms, `UnitDelay{V}`, `Constant{V}`, `Freeze{V}` and `StopRequest`.
tag: M
note: part C order, the inventory after the guidelines. "The starting inventory" stays verbatim (R13).

added: The shipped list lives in `companions/library_inventory.md`.
# R13's sentence after the list.

old: `UnitDelay` is the spelling the second loop-breaking remedy (§5.5) needs.
tag: M
note: with the inventory paragraph.

old: `Constant{V}` is the source block.
new: `Constant{V}` is the source block (D-143).
tag: C
newcites: D-143
note: with the inventory paragraph. D-143's Position: "The component library gains a source block, `Constant{V}`".

old: `Freeze{V}` is the declared stop-gradient (D-266).
tag: M
note: with the inventory paragraph.

old: `StopRequest` is the library spelling of a stop request (a port that ends the run when it reads `STOP_REQUESTED`, §13.5, D-316).
new: `StopRequest` is the library spelling of a stop request (a port that ends the run when it reads `STOP_REQUESTED`) (§13.5, D-316).
tag: M
note: with the inventory paragraph; the citations leave the gloss's parentheses.

old: The request is its port's `StopFlag` type, which any component may publish, so the block holds no privilege.
tag: M
note: with the inventory paragraph.

old: A block joins the library's inventory by judgement against three guidelines (D-313).
note: bold kept; part C order puts the guidelines first.

old: The guidelines ask whether a block is domain-agnostic and generally useful, whether it has didactic value, and whether its implementation is difficult to get right.

old: None is a requirement.

old: They are weighed, not satisfied one by one, and a listed block is built whenever wanted.

old: The inventory, and the Simulink mapping that prunes it, is `companions/library_inventory.md`.

old: A one-line expression such as a gain earns no block, because a separate component costs a build entry, a cell, a gather and a scatter (§9.7).

old: Domain components, such as aerodynamics, engines or sensors, belong in separate packages built on the framework.

old: Simulink's library is a language, while this is a toolbox.
note: verbatim; `library_inventory.md` 21–22 quotes it.

old: The library is the submodule `Redstone.Blocks`, `Group` included, written against the extension-only surface (§8.1) as a user's component file is (D-313).

old: A workspace sub-package or a separate repository is an after-release question.

old: One member is admitted by persona rather than by need.
new: One member is admitted by persona.
tag: R
ruling: R6
note: F60, "rather than by need" cut.

old: `Group` is the on-the-fly assembly, and its declaration-layer treatment lives in §8.5 (D-184).
new: `Group` is the on-the-fly assembly (pure composition, with no dynamics of its own), and its declaration-layer treatment lives in §8.5 (D-184).

added: (pure composition, with no dynamics of its own)
# assembly's first-use gloss, from the glossary entry.

old: `Group` serves the model assembler, for whom topology is data rather than a named type.

old: It needs no rule the declaration layer does not already have.

old: The doctrine is that library blocks are ordinary components, with no framework privileges and no special vocabulary.
new: The doctrine is that library blocks are ordinary components, with no framework privileges and no special vocabulary (D-062).
tag: R
ruling: R5
newcites: D-062
note: the bold kept on its headline clause, now with D-062 bullet 3, "ships as ordinary components".

old: Ordinary status is what keeps schema authority total (declarations define structure; evaluation only checks conformance).

old: That same status makes the library a permanent ergonomics torture test.
new: That same status makes the library a permanent ergonomics torture test, a maximally awkward case spelled against the declaration rules to validate them.

added: , a maximally awkward case spelled against the declaration rules to validate them
# torture test's first-use gloss, from the glossary entry ("a maximally awkward case spelled against a proposed mechanism to validate it"), the mechanism named from the next sentence.

old: If a three-input OR gate is painful to write under the declaration rules, the rules are wrong.

old: Arity and port types come from type parameters (D-311).
note: bold kept; §6.2 states D-311 plain at 1fee0fc.

old: `Junction{In, Out, N, F}` builds `(in1 = In, …, inN = In)` programmatically and applies the fold its instance holds, so `Or{N}` is the junction at `|` and `And{N}` at `&`, each a constant alias.

old: A gate exists for its consumer, which wants one consolidated `Bool` input instead of several.

old: That is a derivation §8.2 blesses, and an early validation that the contract functions support parametric components.

old: struct Junction{In, Out, N, F} <: AbstractComponent f::F # the fold, N-ary; instance data end const SumJunction{V, N} = Junction{V, V, N, typeof(+)}
note: the Junction sketch, verbatim, in two claims at its blank line.

old: x_init(::Junction) = (;) # stateless, continuous: the empty store is the tier marker (§8.2) u_types(::Junction{In, Out, N}) where {In, Out, N} = NamedTuple{ntuple(i -> Symbol(:in, i), N)}(ntuple(_ -> In, N)) y_types(::Junction{In, Out}) where {In, Out} = (out = Out,) y_direct(j::Junction, (; u)) = (out = j.f(u...),)
note: the Junction sketch, second half.

old: The parameters are the nominal port types and the arity, as in `SumJunction{Wrench{Float64}, 3}`, and the fold is instance data (D-311).

old: `Wrench` is FlightPhysics' force-and-torque type, here parametrized by its scalar type as a walked type of §7.2.

old: `SumJunction{V, N}` is the `Junction` at `+`.

old: A custom fold, such as a weighted blend or a mass-properties composition, is written at the site as `Junction{In, Out, N}(f)`, which infers `F`.

old: The junction is a continuous leaf, so its contracts are written at nominal `Float64` and the leaf walk retypes them (§8.2).
new: The junction is a continuous leaf, so its contract is written at nominal `Float64` and the leaf walk (the framework's derivation of per-activation types from a declared nominal type) retypes it (§8.2, D-263).
tag: C
newcites: §8.2 D-263
note: D-263's Position: "Every contract declaration ... is written at nominal `Float64`, and is retyped by the framework"; bullet 1, "the leaf walk ... is applied to the declared types". Step 5 P2-20 and P2-24: *contract* singular for one component; the leaf walk linked with the glossary's gloss.

added: (the framework's derivation of per-activation types from a declared nominal type)

old: An input entry at `Wrench{Float64}` is the tolerant form a promoting consumer writes.

old: Walking, frozen and root-input contributors are all admissible behind it.

old: A named site-specific junction documents a fixed contributor set better than generated slots, at the price of hard-coding it into a type (D-037).
new: A named site-specific junction documents a fixed contributor set better than generated input ports, at the price of hard-coding it into a type (D-037).
note: step 5 P2-20: "slots" is the log's old word.

old: An example is `u_types(::VehicleWrenchSum) = (aero = …, ldg = …, pwp = …)`
note: the names get their introduction by pointing to §6.2's example (verifier fix).

added: , whose input entries name the aerodynamics, landing-gear and powerplant children of the `Systems` assembly (§6.2).

old: The generic positional form remains the tool for configuration-variable sites.

old: Both are plain components, and the framework is not involved.

old: Wrench, mass properties and internal angular momentum each get their own junction, never one bundled contribution struct (D-037, D-323).
tag: R
ruling: R5
note: newly bold, the whole sentence as the headline clause of D-323 bullet 3, bold nowhere else.

old: Contributors are ragged, each publishing only some of the three quantities.

old: A bundled struct would force zero-filled identity values through every port, the "silently sum nothing" hazard in a new coat.

old: A `sum_ports!`-style helper would instantiate a junction, wire it and export its total in one call.

old: Such a helper is guarded-addition sugar (a capability the design admits but does not build), added when real models show the pattern repeated (D-037).

old: Tier-transparency falls out of settled semantics.
new: Tier-transparency falls out of settled semantics (D-062), a tier being the continuous or discrete side of the hybrid formalism.
tag: C
newcites: D-062
note: D-062 bullet 3, "stateless-continuous hence tier-transparent".

added: , a tier being the continuous or discrete side of the hybrid formalism
# tier's first-use gloss, from the glossary entry.

old: A stateless continuous `y_direct` recomputes every sweep.
new: A stateless continuous `y_direct` recomputes every sweep (one pass through the execution order).

added: (one pass through the execution order)
# sweep's first-use gloss, from the glossary entry.

old: Fed ZOH-held discrete signals, its output therefore changes only at ticks.
new: Fed discrete signals held by a zero-order hold, its output therefore changes only at ticks (the instants at which a discrete component's stages and update run).
tag: R
ruling: R10
note: "ZOH" expanded at its first use; the abbreviation is not used again.

added: (the instants at which a discrete component's stages and update run)
# tick's first-use gloss, from the glossary entry.

old: No tier-neutral class is needed.
new: No tier-neutral variant is needed.
note: step 5 P2-20: *class* is reserved for primitive versus assembly.

old: `UnitDelay{V}` is a discrete leaf at `K = 1`.
tag: R
ruling: R3
note: the bold word "discrete" goes plain.

old: It is the tier's native `z⁻¹` (§10.6), the shape an anti-windup chain's previous-saturation port hand-writes.
new: It is the tier's native `z⁻¹` (§10.6), the shape an anti-windup chain's previous-saturation port hand-writes (`companions/pid_anti_windup.md`).
tag: R
ruling: R10

added: (`companions/pid_anti_windup.md`)
# R10's pointer, no claim added.

old: It needs no framework support.

old: `# UnitDelay{V} — a discrete leaf at K = 1; its initial value is instance data struct UnitDelay{V} <: AbstractComponent v0::V end s_init(d::UnitDelay) = (v = d.v0,) u_types(::UnitDelay{V}) where {V} = (in = V,) y_types(::UnitDelay{V}) where {V} = (out = V,) y_state(::UnitDelay, (; s)) = (out = s.v,) # publishes the stored value s_update(::UnitDelay, (; u)) = (v = u.in,) # stores the incoming one`
note: the UnitDelay sketch, verbatim.

old: The delay holds its initial value as instance data (D-312), so `UnitDelay(v0)` needs no `zero` method on `V`.

old: The store is isbits by rule (D-231), which bounds `V`.

old: `UnitDelay`'s tier semantics are the point, and they must be stated wherever the remedy is recommended (D-348).

old: Inserting a `UnitDelay` into a continuous loop moves that signal onto the discrete tier and inserts a `Δt_base`-scale ZOH into the model's mathematics.
new: Inserting a `UnitDelay` into a continuous loop moves that signal onto the discrete tier and inserts a `Δt_base`-scale zero-order hold into the model's mathematics, `Δt_base` being the base tick period.
tag: R
ruling: R10
note: "ZOH" spelled out, D-348's own words ("a `Δt_base`-scale zero-order hold"). Step 5 P2-24 links `Δt_base` with the glossary's gloss.

added: , `Δt_base` being the base tick period.

old: That is a modeling decision, because the delayed signal is genuinely sampled rather than a transparent wire.

old: The cycle diagnostic (§13.8) therefore says so rather than offering the remedy as free.

old: `Constant{V}` is the source block. It has no inputs, no state, and a stage-1 body returning the value the instance holds.
new: `Constant{V}` has no inputs, no state, and a stage-1 body returning the value the instance holds (D-143).
tag: C
newcites: D-143
note: step 5 P2-18: "is the source block" was a verbatim repeat of the inventory paragraph's sentence, which keeps it. The bold term "source block" goes plain (R3). D-143's Position: "no inputs, no state ... the value itself held by the instance, and a stage-1 body returning it".

old: `# Constant{V} — a stateless continuous leaf; its value is instance data struct Constant{V} <: AbstractComponent value::V end x_init(::Constant) = (;) # the empty store declares the tier (§8.2) y_types(::Constant{V}) where {V} = (out = Pinned{V},) y_state(c::Constant, _) = (out = c.value,) # the value the instance holds`
note: the Constant sketch, verbatim.

old: `Constant` is a stateless continuous leaf, so the tier-transparency argument above already covers discrete consumers.

old: No discrete variant is needed.
new: No discrete variant is needed (D-143).
tag: C
newcites: D-143
note: D-143's Position: "§13.7's existing tier-transparency argument ... already covers discrete consumers — no discrete variant".

old: The block's output is its stored value, so the leaf is deliberately pinned at that value's own type (D-312).
new: The leaf is deliberately pinned at that value's own type (D-312), because the block's output is its stored value.
tag: R
ruling: R5
note: rephrased so the bold heads its sentence; the causal link keeps its direction.

old: A `Constant{Float64}` declares a `Pinned{Float64}` port and means it.

old: A constant is never seeded, so it carries zero partials under any `Dual` activation (the build's typed products at a given scalar type), and the pinned port says so where a walking one would promote the value and declare less.

old: The honest pin is spelled rather than inferred.

old: The same holds for every library block whose output depends on neither its continuous state nor a walking input, such as a step source or a relay, and each declares its `out` pinned (D-312).

old: Two demonstrated needs admit `Constant` under the inventory's demonstrated-need charter.
new: Two uses need `Constant` (D-143), though a listed block needs none to be built (D-313).
tag: R
ruling: R6
newcites: D-143 D-313
note: F60, the dictated sentence; the paragraph moves up by M61, after the Constant paragraph and before Freeze.

old: The zero-contributor configurations (§6.2) are one.
tag: M
note: M61.

old: There, a required aggregate input has no physical contributor, and the zero total must be spelled as a wire.
tag: M
note: M61.

old: The rig stub below is the other.
tag: M
note: M61; the rig still follows.

old: The block's value is instance data, like junction arity, not an overridable default.
new: The block's value is instance data, like junction arity, not an overridable default (D-143).
tag: C
newcites: D-143
note: M61. D-143 clarification (ii): "the value is instance data, not an overridable default — like junction arity it is baked into the instance".

old: A configuration wanting an externally settable source uses a root input (§11.3). That keeps the block from drifting into a back-door input default.
new: A configuration wanting an externally settable source uses a root input (§11.3), which keeps the block from drifting into a back-door input default.
tag: M
note: M61. The two sentences join so F61's added sentence cannot become "That"'s antecedent. Its root input link moved to the first use in the select paragraph.

added: A handle that references bulk data never surfaces as a root input (D-237); a rig holds such a handle through a constant source (a `Constant` holding it) instead (§14.9, D-364).
# R27's wording of F61 as R30 narrows its first clause, after the root-input sentence.

old: `Freeze{V}` is the declared stop-gradient. It feeds a walking producer into a pinned entry, which the walk clause (§6.1) otherwise refuses.
new: `Freeze{V}` feeds a walking producer into a pinned entry, which the walk clause (§6.1) otherwise refuses (D-266).
tag: C
newcites: D-266 §6.1
note: step 5 P2-18: "is the declared stop-gradient" was a verbatim repeat of the inventory paragraph's sentence, which keeps it; D-266 stays with the feeding claim. The bold term goes plain (R3). D-266 bullet 2: "A walking producer feeds a pinned entry through the `Freeze{V}` library block".

old: `# Freeze{V} — a stateless continuous leaf; tolerant in, pinned out struct Freeze{V <: Union{Real, StaticArray{<:Tuple, <:Real}}} <: AbstractComponent end x_init(::Freeze) = (;) u_types(::Freeze{V}) where {V} = (in = V,) y_types(::Freeze{V}) where {V} = (out = Pinned{V},) y_direct(::Freeze, (; u)) = (out = ForwardDiff.value.(u.in),) # leafwise strip, by broadcast`
note: the Freeze sketch, verbatim.

old: At nominal the strip is the identity, so the block costs one gather and one scatter.

old: `V` is a `Real` or a `StaticArray` of them, constrained at the type (D-312), so a struct-valued freeze is refused at the spelling until a model needs one.

old: Under a `Dual` activation it drops the partials, and its output satisfies the pinned entry.
new: Under a `Dual` activation the block drops the partials, and its output satisfies the pinned entry.
note: step 5 P2-19: the nearest noun was "a model".

old: What the wire then declares is a zero coupling in every Jacobian along that path, the modelling decision §14.10 asks an author to state on the page rather than bury mid-expression.
new: What the wire then declares is a zero coupling in every Jacobian along that path (D-266), the modeling decision §14.10 asks an author to state on the page rather than bury mid-expression.
tag: C
newcites: D-266 §14.10
note: D-266 bullet 2: "the wire then declares a zero coupling in every Jacobian along that path".

old: A sampler is the other non-walking source, and it changes the model, holding the value between ticks (§10.5); the block is for a continuous value the consumer cannot differentiate through.
new: A sampler is the other non-walking source, and it changes the model, holding the value between ticks (§10.5). The block is for a continuous value the consumer cannot differentiate through.
note: the semicolon join split; the second tick link goes (one per section).

old: Where the coupling matters to the Jacobian, the local rule (§14.10) is the answer, not this block.

old: #### The component test rig
tag: X

old: The component test rig is the library's companion idiom.
tag: R
ruling: R3
note: the bold sentence goes plain: no entry states it (D-120 rules the stub child, D-208 bullet 3 the rig's stubbing role), and check_bold refuses a bold with no D-citation. Listed in rulings.md.

old: Exercising a leaf alone needs no rig of its own.

old: Any component may be the root of a build, and its input faces then become the model's root inputs (§8.2, D-208).
note: its face link goes (doubled; first use in the opening).

old: Ordinary conditions and devices feed them, and every output is observable in the snapshot table.
new: Ordinary conditions (path-addressed sparse overlays that set a build's state) feed them. So do devices (attached participants in the periphery). Every output is observable in the table of each snapshot, the immutable per-boundary publication.
note: step 5 P2-24 links conditions; R23 splits so each gloss has its sentence.

added: (path-addressed sparse overlays that set a build's state)

added: (attached participants in the periphery)
# device's first-use gloss, from the glossary entry.

added: the table of each snapshot, the immutable per-boundary publication
# snapshot's first-use gloss, from the glossary entry; "the snapshot table" becomes "the table of each snapshot" to carry it.

old: The rig is a one-child assembly whose `input_wires` surface the child's entire input face set, as `input_passthrough(rig, "child")` verbatim (§8.8).

old: What it buys is a place to wire something beside the component under test.

old: The demonstrated need is the root-input rule (§8.2).

old: An abstract input entry (`terrain = AbstractTerrainField`, §8.2) cannot surface as a root input, because abstract-at-root is a build error.
new: An abstract entry (an `u_types` entry admitting any concrete producer face), such as the illustrative `terrain = AbstractTerrainField`, cannot surface as a root input, because abstract-at-root is a build error, `AbstractAtRoot` (§8.2, Appendix C).
tag: R
ruling: R6
newcites: §8.2 Appendix C
note: F62 and R14 name the kind; R10 marks `AbstractTerrainField` illustrative. §8.2 leaves the example's parentheses and cites the rule.

added: , such as the illustrative

old: The rig therefore satisfies that entry inside the rig.
new: The rig therefore satisfies that entry inside the rig (D-120).
tag: C
newcites: D-120
note: D-120's Position: "A component with abstract input entries is rigged with a concrete stub child".

added: In the sketch below, the component under test is `Strut`, an illustrative landing-gear strut whose terrain input is abstract.
# R10's introducing clause for `Strut`.

old: A concrete stub child (a `SampleTerrainField` provider) is wired to the face, and the concrete remainder is exposed via `input_passthrough(rig, "strut"; except = ("terrain",))`.
new: A concrete stub child (a provider of `SampleTerrainField`, an illustrative concrete terrain) is wired to the face, and the concrete remainder is exposed via `input_passthrough(rig, "strut"; except = ("terrain",))` (D-120).
tag: R
ruling: R21
newcites: D-120
note: R21, the headline clause "A concrete stub child ... is wired to the face" newly bold with D-120's Position ("A component with abstract input entries is rigged with a concrete stub child ... wired to the abstract face"), bold nowhere else; R10's illustrative clause for `SampleTerrainField`.

added: , an illustrative concrete terrain

old: struct StrutRig <: AbstractComponent # the rig: component under test + stub strut::Strut stub::Constant{SampleTerrainField} # the test handle, held as instance data end
note: the rig sketch, verbatim, in two claims at its blank line.

old: local_wires(::StrutRig) = ("stub/out" => "strut/terrain",) input_wires(rig::StrutRig) = (input_passthrough(rig, "strut"; except = ("terrain",))...,)
note: the rig sketch, second half.

old: That stub child is typically just a `Constant` holding the test handle, which makes it the source block's first shipped instance.
new: That stub child is typically just a `Constant` holding the test handle, which makes it the source block's first shipped instance (D-143).
tag: C
newcites: D-143
note: Rationale-only: D-143's Rationale, "typically just a `Constant` holding the test handle — the block's first shipped instance".

old: Bespoke stubs remain ordinary components wherever the double must compute something.

old: The rig adds zero new machinery, because wiring and `except` already exist.
new: The rig adds zero new machinery, because wiring and `except` already exist (D-120).
tag: C
newcites: D-120
note: D-120's Position: "zero new machinery, the substitutability contract read as 'the rig chooses its substitute explicitly, as ordinary inspectable code.'"

old: It is the substitutability contract doing its job.
new: It is structural substitutability doing its job.
tag: R
ruling: R28

old: An abstract entry (an `u_types` entry admitting any concrete producer face) declares that a substitute must be chosen.
new: An abstract entry declares that a substitute must be chosen.
note: step 5 P2-24: the link and its gloss move to the first use, the root-input rule paragraph.

old: The rig chooses its test double explicitly, as ordinary inspectable code.

old: That is precisely the isolation the rig exists to provide.

old: The rig is `design_world`'s little sibling (§14.9).

old: Where `design_world(ac)` mounts an aircraft in a minimal world for trim and linearization, the rig mounts one component behind a root contract for unit tests and open-loop probing.
new: Where `design_world(ac)` mounts an aircraft in a minimal world for trim and linearization, the rig mounts one component behind its own root faces for unit tests and open-loop probing.
tag: R
ruling: R28

old: The machinery is deliberately ordinary end to end, with no framework support.

old: That makes the rig, like the library blocks, a standing ergonomics test of the declaration rules.

old: ### 13.8 Cycle diagnosis: feedthrough tracing
tag: X

old: The build rejects an algebraic loop (§5.5), and tracing is diagnostic only, never relied on for correctness (D-012).
new: The build rejects an algebraic loop (a genuine cycle in the instantaneous dependency graph) (§5.5, D-005), and tracing is diagnostic only, never relied on for correctness (D-012).
tag: C
newcites: §5.5 D-005 D-012
note: D-005's Position: "Reject algebraic loops at build".

old: Tracing improves error messages and verification.

old: When the build finds a cycle, it triggers the feedthrough tracer (the set-propagation instrument that tracks which inputs a value depends on) to classify that cycle.

old: A genuine cycle gets "break it with a state, a stage-1 (`y_state`) port, or a `UnitDelay`", and an artificial one gets the remedy ladder (§5.4).
new: A genuine cycle gets "break it with a state, a stage-1 (`y_state`) port, or a `UnitDelay`", and an artificial one gets the remedy ladder (§5.4, D-140).
tag: C
newcites: §5.4 D-140
note: D-140's Position: "§5.4's escape hatch becomes a three-rung remedy ladder for artificial loops".

old: Where the diagnostic recommends a unit delay, it states the delay's tier caveat rather than offering it as a free remedy (§5.5, §13.7, D-348).
note: the tier link moves here, its first use in the section (from the discrete-members sentence).

added: A tier is the continuous or discrete side of the hybrid formalism.
# tier's first-use gloss, from the glossary entry, in its own sentence since the sentence before carries three citations.

old: The parts below cover, in order, how a cycle is detected and named, the tracer's two modes and what tracing touches, how classification runs and decides, and the caveats and hints the diagnostic carries.
new: The parts below cover, in order, how a cycle is detected and named, the tracer's two modes, what tracing touches, how classification runs and decides, and the caveats and hints the diagnostic carries.
tag: R
ruling: R6
note: F67, the parts sentence names all five labels.

old: #### Detection and naming
tag: X

old: A cycle surfaces as a topological-sort stall in the nominal evaluation (the build's second step, the one evaluation that feeds structure).
new: A cycle surfaces as a topological-sort stall in the nominal evaluation, the build's second step and the one evaluation that feeds structure (§9.1).
tag: R
ruling: R12
newcites: §9.1
note: no #g-nominal link; "the nominal evaluation" with §9.1, the gloss now an appositive so the citation sits outside it.

old: The stalled subgraph is decomposed into strongly connected components (SCCs).

old: Each nontrivial SCC names one cyclic cluster exactly (D-012).

old: Each cluster becomes one diagnostic, an `AlgebraicCycle` error (Appendix C).

old: The diagnostic presents the cluster's members and the wires among them as one readable loop of terminal pairs in the canonical slash form (§8.6, `aero/F → dyn/F, dyn/a → aero/a`).
new: The diagnostic presents the cluster's members and the wires among them as one readable loop of terminal pairs in the canonical slash form (§8.6), as in `aero/F → dyn/F, dyn/a → aero/a`.
note: the citation leaves the example's parentheses.

old: Neither the raw stall residue nor a single back edge names the cluster correctly (D-012).

old: #### The tracer's two modes
tag: X

old: The feedthrough tracer has two modes, and they degrade gracefully (D-349).

old: Both are set-tracers.

old: A traced value carries a set of input indices, its tracer tags.

old: The global (value-blind) set-tracer is a `Real` subtype that carries a set of input indices, unioned by every operation.

old: It has may-depend semantics, a sound over-approximation.

old: A saturated `clamp` still reports, and $u^2$ at $u = 0$ still reports.

old: It is exact, in one evaluation.

old: It requires the traced stage-2 code to be free of branches and lookups on input-tainted values.

old: The local (primal-carrying) set-tracer at sampled states is the fallback whenever the global tracer hits an undecidable branch, such as piecewise friction, stall blending or any gridded lookup at an input-tainted coordinate.
new: The sampled set-tracer (the local, primal-carrying mode) at sampled states is the fallback whenever the global tracer hits an undecidable branch, such as piecewise friction, stall blending or any gridded lookup at an input-tainted coordinate.
tag: R
ruling: R6
note: F63, "the sampled mode", D-245's word; "local" survives in the gloss that ties it to its old name.

old: It reports the dependence pattern of the taken paths, sampled across randomized states.

old: Its only misses are untaken branches (D-012, D-349).

old: #### What tracing touches
tag: X

old: Only inputs are seeded (D-349), so branching on state, modes, parameters or time never interferes.

old: Stage-2 functions also receive state views, but neither those nor the stage-1 hand-down are ever seeded.

old: Stage-1 functions are never traced, since there is nothing to seed.

old: Derivatives, guards (the declared functions defining each event's predicate), handlers and projections are outside tracing's jurisdiction entirely.
new: Derivatives, guards (the declared functions defining each event's predicate), handlers and projections (the optional per-component hook `x ← x_projection(x)`) are outside tracing's jurisdiction entirely.
note: step 5 P2-24: projections glossed in the glossary's words.

added: (the optional per-component hook `x ← x_projection(x)`)

old: A known tracer blind spot is documented.

old: Value-severing operations pass dependence through a bare `Int` index, as a nearest-neighbor lookup does.

old: Linear and cubic interpolation are immune, because dependence flows through the fractional weights.

old: Dual-cleanliness in CI effectively guarantees traceability (D-349).

old: Dual-clean means passing the `T = Dual` sweep of §7.2.
new: Dual-clean means passing the `T = Dual` sweep of §7.2, `Dual` being ForwardDiff's dual number.
note: step 5 P2-29: the gloss moves to the first prose use of `Dual` it can reach.

old: The guarantee holds because both modes ride the same `T <: Real` genericity as `Dual`, ForwardDiff's dual number.
new: The guarantee holds because both modes ride the same `T <: Real` genericity as `Dual`.
note: step 5 P2-29: "ForwardDiff's dual number" moved one sentence up.

old: #### Classification
tag: X

old: Classification needs no execution order, the order in which the stage functions run (D-012).

old: It runs inside the nominal evaluation's failure path, where no execution order exists.

old: None is needed, because each SCC member is evaluated once, in isolation, at the probe point (the initial state, where the build probes every user function).

old: That evaluation reads state views from the `x_init`, `s_init` and `m_init` declarations, out-of-cycle cell values from the acyclic prefix's probe values, and in-cycle cell values synthesized through `probe_value` (§9.3) under tracer tags.

old: The tracer's product is a per-member dependence set rather than a value, so no ordering has to be valid for the labels to come out right.

old: The traced maps decide the verdict as one graph question over the cluster (D-245).
note: now after the variant paragraph (M62).

old: The verdict is the one §5.4 defines.

old: Every wire holds.

old: A hop inside a member runs from the face (the name a port wears on its component's boundary) that one wire enters to the port the next wire leaves.

old: The hop holds iff that member's map routes the face to the port.

old: The loop is real iff a cycle survives in that graph.

old: It is artificial iff none does, because every cycle through the cluster crosses a dead hop, at a component whose stage-2 function does not in fact route that input to that output.

old: The diagnostic lists every dead hop under either verdict, so a real loop still shows the chords the trace found false (D-245).

old: For a simple cycle this reduces to the expected reading, that the loop is real iff every hop survives.

old: Classification touches no activation machinery.
tag: M
note: M62, up to follow the mechanism and precede the verdict.

old: There is no activation (the build's typed products at a given scalar type), no layouts and no table.
tag: M
note: M62.

old: The cycle classifier uses the local variant of tracing (D-012), the order-free per-member trace at the probe point.
new: The cycle classifier uses the per-member (local) variant of tracing, the order-free per-member trace at the probe point (D-012).
tag: R
ruling: R6
note: F63, "the per-member variant"; "local" survives in the gloss. M62.

old: The "tracer activation" (§9.4) names the other variant (D-012), the global set-tracer run as an ordinary activation.
tag: M
note: M62.

old: The two must not be conflated.
tag: M
note: M62.

old: The local variant is not the local set-tracer mode.
new: The per-member variant is not the sampled mode.
tag: R
ruling: R6
note: F63; M62.

old: A member's map may come from either mode.
tag: M
note: M62.

old: #### Caveats and hints the diagnostic carries
tag: X

old: The diagnostic carries the tracer's caveats rather than assuming them away.

old: The trace speaks for the branch taken at the probe point (the diagnostic-only doctrine, D-012, D-343).
new: The trace speaks for the branch taken at the probe point, the diagnostic-only doctrine (D-012, D-343).
tag: R
ruling: R5
note: newly bold, D-343 bullet 8; the citations leave the gloss's parentheses, the doctrine's name an appositive.

old: Discrete members trace structurally, because the discrete tier's plain, wholesale-pinning declarations admit no tracer scalar (D-012).
note: bold kept; its tier link moved to the context paragraph.

old: Structural tracing is sound as a may-depend answer but never sharp, so the remedy hint is offered only for continuous members (D-140, D-343).
new: The remedy hint is offered only for continuous members (D-140, D-343), because structural tracing is sound as a may-depend answer but never sharp.
tag: R
ruling: R5
note: newly bold, D-343 bullet 5; rule first, the reason after with its causal direction kept.

old: A continuous face or port declared with no walking leaf (one whose type follows the activation scalar) admits no tracer scalar either, so the hops through it trace structurally too (D-245, D-343).
new: The hops through a continuous face or port declared with no walking leaf trace structurally too (D-245, D-343), because such a face or port admits no tracer scalar either. A walking leaf is one whose type follows the activation scalar.
tag: R
ruling: R5
note: newly bold, D-343 bullet 9; rule first, the reason after; the walking gloss moves to its own sentence, keeping its words.

old: The diagnostic records the source of each member's map (D-245).

old: The source is the global tracer, sampled states or structure.

old: A reader can thus weigh a dead hop found on a few sampled paths against one found exactly.

old: The hint itself is to split this component, or to narrow the neighbor's contract (its declared interface) when the dead hop's input is consumed only in a fallback branch.

old: Those are the ladder's two remedies (§5.4, D-140, D-343).

old: The build diagnostic offers both exits explicitly (D-140, D-343).

old: For a loop between `systems/aero` and `systems/dyn` it reads "artificial at port level: `systems/aero`'s `F` does not route `a`; split `systems/aero`, or narrow the neighbor's contract if `a` is consumed only in a fallback branch".

old: The dead hop is the member with the input face that it does not route to the output port.
new: The dead hop is the member's input face that its stage-2 function does not route to the output port.
tag: R
ruling: R6
note: F64, the dictated sentence.

old: The diagnostic carries the dead hop (D-245) as a separate field of its payload (the structured data a diagnostic carries) rather than dotting the hop onto the path (§8.6, §13.2).

old: If a member's evaluation itself throws, the diagnostic ships with its members and wires alone, unclassified.

old: Classification is a bonus on the cycle error, never its precondition (D-012).
tag: R
ruling: R20
note: stays plain with D-012: R20 reads "conservative on discrete members, classification optional on the error" as one comma-joined ruling, whose bold is "Discrete members trace structurally".

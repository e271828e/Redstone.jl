# Unit H claims: §14.10.

old: ### 14.10 Linearization: tap selectors, one seeded pass, a pure query
tag: X

added: `linearize` computes the matrices `A`, `B`, `C` and `D` about an operating point in one seeded evaluation, and it commits nothing.

added: This section covers, in order, the tap set, the operating point, the seeded pass, the leaves the pass seeds and the leaves it holds frozen, the returned value, the guidance on coordinates, the recorded sampled-data extension, and declared non-participation with the local derivative rule.

old: The tap declaration.
new: #### The tap set
tag: R
ruling: R8
note: bold label becomes a topic label (M61).

old: Today's per-aircraft
new: Flight.jl's per-aircraft
tag: R
ruling: R12
note: checked ~/.julia/dev/Flight.jl/lib/FlightApps/src/c172/c172x/c172x.jl (XStateSpace 332, UStateSpace 400, YStateSpace 411; AircraftBase.get_x_ss/assign_x_ss! 455–472) and FlightApps/src/robot2d/robot2d.jl 254–288 (the same methods per vehicle).

old: `XStateSpace`/`UStateSpace`/`YStateSpace` structs, plus the `get__ss`/`assign__ss!` shuttle methods, run to ~150 lines of bookkeeping per variant.

old: All of it becomes three selector lists (the closed family of deferred reads resolving against a source), declared together as one tap set, `taps(x = …, u = …, y = …)` (D-272).
new: All of it becomes three selector lists (the closed family of deferred reads resolving against a source). The three lists are declared together as one tap set, `taps(x = …, u = …, y = …)` (D-072, D-272).
tag: R
ruling: R7
newcites: D-072 D-272
note: split in two; the second sentence is the bold headline of D-272 bullet 1, which shares one ruling with D-072's Position sentence ("three selector lists … validated against schema, compiled to offsets, relocatable via `at`"). D-072 added.

old: Membership is closed per list.

old: The `x` list takes `get_state`, the `u` list `get_input`, and the `y` list `get_output` and `get_face` (§14.4).

old: The NamedTuple key is the label control design slices by.

old: Rule. A tap names one scalar.
new: A tap names one scalar (D-272).
tag: R
ruling: R7
newcites: D-272
note: the Rule. label goes; bold headline of D-272 bullet 2 with its citation added in the sentence.

old: Its leaf address (the field name with dotted and bracketed steps below it, §14.4, D-276) resolves to one scalar leaf,
new: Its leaf address (the field name with dotted and bracketed steps below it) resolves to one scalar leaf (§14.4, D-276).
note: the citations leave the gloss's parentheses (brief_common.md).

old: so a vector leaf yields named scalars, one tap per component.
new: So a vector leaf yields named scalars, one tap per element.
tag: R
ruling: R9
note: F66, an array element and not a component; the component link moves to its first real use (the returned value).

# R9, F53: the seeded tap's step limit, the proposed wording fitted ("a whole cell" reads "a whole state field or root input", since an x seed lands in the state buffer, not a cell).
added: A seeded tap, in the `x` or `u` list, reaches its scalar through one index step at most and never a `.name` step, because a seed is written into a whole state field or root input, or into one array element of it.

# R24: the seeded tap's leaf rule (`_check_seedable`, src/linearize.jl 344–345).
added: A seeded tap's leaf is exactly `Float64`.

added: A `y` tap is a read and takes any leaf address.

old: A tap resolving to a vector or a bundle is rejected at resolution, and so is a member in the wrong list.
new: A tap resolving to a vector or a struct is rejected at resolution as a `TapResolution`, and so is a member in the wrong list.
tag: R
ruling: R14
note: kind named (F71; `:vector_tap`, `:tap_kind`). "bundle" is reserved; the code refuses any non-Real leaf as `:vector_tap` (src/linearize.jl 342), so "a struct" for D-272's "bundle".

old: Two taps resolving to one site are rejected together, both labels in hand: one site is one column, and a second seed there would overwrite the first (D-272).
new: A second tap resolving to a site already seeded is rejected naming the earlier label, since one site is one column and a second seed there would overwrite the first (D-272).
tag: R
ruling: R9
note: F76 (src/linearize.jl 308–313, `duplicate_of`); the mid-sentence colon becomes "since".

old: `taps(x = (p = get_state("vehicle/dynamics", "ω_eb_b[1]"), θ = get_state("vehicle/kinematics", :θ_nb), …), u = (throttle_cmd = get_input(:throttle), wind_n = get_input("wind[1]"), …), y = (EAS = get_output("vehicle/airflow", :EAS), …))`
note: the tap-set block, verbatim.

old: The three lists are validated at resolution, with did-you-mean errors (the offending name plus the list-in-hand it should have matched).

# R14, F71: the did-you-mean refusals named; the glossary's `taps` and D-406 bullet 2.
added: Those errors are the selectors' own `ReadResolution` (D-406).

old: The `x` list is validated against the continuous tier's `x_init` stores, the `u` list against faces, and the `y` list against `y_types`.
new: The `x` list is validated against the `x_init` stores of the continuous tier (the continuous or discrete side of the hybrid formalism), the `u` list against faces, and the `y` list against `y_types`.
note: tier's link moves to its first use, with the glossary's gloss; store linked (F67).

old: An `x` entry naming a discrete store is rejected at resolution with the entry and its tier in hand.
new: An `x` tap naming a discrete store is rejected at resolution as a `TapResolution`, with the tap and its tier in hand (D-197).
tag: R
ruling: R9
newcites: D-197
note: F66 (bare entry, twice); R14 kind named (`:discrete_state`); R7 bold headline of D-197's first ruling, citation added in the sentence. D-197 Position: "a tap naming a discrete store is a tap-resolution error carrying the offending entry and its tier".

old: That is the no-silent-zeros rule again (D-167, D-197).
new: That is the no-silent-zeros rule again (D-197).
tag: C
newcites: D-197
note: F59, superseded D-167 dropped; D-197's Rationale names "D-167's no-silent-zeros principle".

old: The frozen tier's only possible partials are zeros, and the rejection's next-move guidance points at the recorded step-map extension below.

old: The lists compile to offsets once, and relocate whole via `at(prefix, taps)`.
new: The lists compile to offsets once, and relocate whole via `at(prefix, taps)` (D-072).
tag: C
newcites: D-072
note: D-072 Position, "compiled to offsets, relocatable via `at`".

old: The shuttle layer's successor is that compiled writer/reader pair, and the promised `get_x_ss` deletion (§7.1) is discharged.
new: The shuttle layer's successor is that compiled writer/reader pair, and no hand-written state-space mapping remains (§7.1, D-072).
tag: R
ruling: R9
newcites: §7.1 D-072
note: F64's wording; R7 bold on D-072 bullet 1's headline.

old: A pure query, and the default operating point.
new: #### The operating point
tag: R
ruling: R8
note: M61 label; the paragraph moves up before the seeded pass (M62).

old: Linearization is the first service with no commit and no boundary zero (the initialization boundary: the ordinary macro-sequence with an empty integrate).
new: Linearization is a pure query (D-072). It commits nothing and runs no boundary zero (the initialization boundary, the ordinary macro-sequence with an empty integrate).
tag: R
ruling: R9
newcites: D-072
note: F72; "pure query" from the old label; R7 bold on D-072 bullet 3's headline; the gloss's colon becomes a comma.

old: It works on scratch buffers only, and nothing it computes becomes authoritative.
new: It works only on scratch buffers (mutable working storage whose contents are never authoritative), and nothing it computes becomes authoritative.
note: scratch linked with the glossary's gloss (F67).

old: Flight.jl's restore-the-trim dance, the re-`assign!` after `FiniteDiff` dirtied the model, has no successor.
new: Flight.jl's restore-the-trim dance, the re-`assign!` after the `FiniteDiff` package dirtied the model, has no successor.
tag: R
ruling: R12
note: FiniteDiff's first use after M62; checked ~/.julia/dev/Flight.jl/lib/FlightPhysics/src/linearization.jl 4 (`using FiniteDiff`).

old: The default operating point is the checkpoint (the `Model`'s state at a frame top as one value) of the simulation or the model as it stands.
new: The default operating point is the checkpoint (the model's state at a frame top as one value) of the simulation or the model as it stands (D-274, D-319).
tag: R
ruling: R7
newcites: D-274 D-319
note: R25, bold headline of D-274 bullet 5 ("`linearize`'s default operating point is the checkpoint of the simulation as it stands"); D-319 bullet 5 adds `checkpoint(model)`. "`Model`'s" becomes "model's" so the `Model` link keeps its gloss at the next sentence.

old: It is `checkpoint(sim)` on a simulation and `checkpoint(model)` on a `Model` (a deployment materialized at one scalar type), each restored into the scratch world with no boundary zero (§12.6, D-274, D-319).

old: The frozen tier's cells are the checkpoint's held cells.
new: The frozen tier's cells (the typed entries of the signal table) are the checkpoint's held cells.
note: cell's link moves to its first use after M62, with a gloss.

old: After a `trim!` commit, `linearize(sim, taps)` or `linearize(model, taps)` is about the trim point with nothing re-specified.

old: `about = <condition>`, with `t0` beside it as in `trim!`, linearizes anywhere else without touching the sim.
new: `about = <condition>`, with `t0` beside it, linearizes anywhere else without touching the sim (D-272). `t0` is admitted only there, and a `t0` passed without `about` is an `ArgumentInvalid`.
tag: R
ruling: R9
newcites: D-272
note: F83; R14 names `ArgumentInvalid` `:t0_without_about` (src/linearize.jl 156–157); R7 bold on D-272 bullet 4's standing sentence. The lone-t0 refusal is D-272's annotation of 2026-09-28.

old: The evaluation.
new: #### The seeded pass
tag: R
ruling: R8

old: Each invocation instantiates its own scratch store set, the trim service's mechanism verbatim (§14.8), and establishes the operating point in it (below).
new: Each invocation instantiates its own scratch store set, the trim service's mechanism verbatim (§14.8), and establishes the operating point in it (above).
tag: R
ruling: R8
note: M62's pointer turn.

old: It then runs the seeded Dual evaluation, one direction per `x`-tap and per `u`-tap entry, in groups of `width` directions per pass.
new: It then runs the seeded `Dual` evaluation, one direction per `x` tap and per `u` tap, in groups of `width` directions per pass (D-072).
tag: R
ruling: R7
newcites: D-072
note: bold headline of D-072 bullet 2's first ruling ("one chunked Dual pass on per-invocation scratch at the operating point"); bare "entry" goes (R13, F66).

old: Rule. `width` is a keyword of `linearize`, default 8, and the default width's scalar type is public, so a build can pre-materialize its activation through `activations` (§9.4) and a tap set of any size then linearizes with no compile at the keyboard (D-272).
new: `width` is a keyword of `linearize`, default 8, and the default width's scalar type is public, so a build can pre-materialize its activation (the build's typed products at a given scalar type) through `activations` (§9.4) and a tap set of any size then linearizes with no compile at the keyboard (D-272).
tag: R
ruling: R7
note: the Rule. label goes; bold headline of D-272 bullet 3. activation's link and gloss move to its first use (F67).

old: Value parts give `ẋ₀` and `y₀`.

old: Partials give `A` and `B` against the `x`- and `u`-seeds, and `C` and `D` against the same seeds read at `y`.

old: All four come out simultaneously, exact to machine precision.

old: `linearization_walkthrough.md` runs the pass on a two-state model, seed by seed.

old: ``` x-taps ─┐ ┌─ value parts → ẋ₀, y₀ ├─ seed directions → one Dual evaluation ─┤ u-taps ─┘ (chunked internally) └─ partials → A, B, C, D ```
note: the chart, verbatim.

old: That seeded evaluation replaces four `FiniteDiff` jacobians, their step-size heuristics and ~4n perturbed evaluations.
new: That seeded evaluation replaces Flight.jl's four `FiniteDiff` jacobians, their step-size heuristics and ~4n perturbed evaluations.
tag: R
ruling: R12
note: checked ~/.julia/dev/Flight.jl/lib/FlightPhysics/src/linearization.jl 89–107 (`ss_matrices`, four `jacobian!` calls).

old: What the pass seeds, and what it holds frozen.
new: #### Seeded and frozen leaves
tag: R
ruling: R8

old: Unseeded states sit constant at the operating point, and so do unseeded root inputs.
new: Unseeded states sit constant at the operating point, and so do unseeded root inputs (the root's own input faces) (D-072).
tag: R
ruling: R7
newcites: D-072
note: bold headline of D-072 bullet 2's second ruling ("unseeded states stay constant, the discrete tier frozen-exact"); root input glossed (glossary: "the root component's own input face").

old: Establishing the operating point embeds their `Float64` values as zero-partial constants.

old: A root-input cell follows the activation scalar (the build's typed products at a given scalar type) by walking its consuming `u_types` entry at that scalar (§8.2).
new: The root-input cells at an activation follow the root-input type by retyping that same entry at the activation's `T`.
where: scratch_survey/h1/spec.md
tag: R
ruling: R6
note: M63, held at §8.2 2684–2686; the new text points there ("§8.2 states which root inputs the schema leaves seedable"). The activation gloss moved to the seeded pass.

old: The discrete tier is frozen with zero partials, which is precisely "linearize with the discrete state held" (§8.2).

old: Differentiation participation is a per-invocation seeding fact for every root input the schema leaves seedable, one rule for `x` and root inputs alike.
new: Partials enter through per-invocation seeding, one rule for `x` and root inputs alike (§7.2, D-297).
tag: R
ruling: R6
newcites: §7.2 D-297
note: M63 and H76, a pointer to §7.2 1919–1921 ("partials enter only through the directions seeded for that evaluation"), D-297 bullet 2. "for every root input the schema leaves seedable" rides the next sentence's pointer to §8.2.

old: One declared exception is visible in the schema.
new: §8.2 states which root inputs the schema leaves seedable (D-295).
tag: R
ruling: R6
newcites: §8.2 D-295
note: M63, the pointer to §8.2 2684–2689 (D-295 bullet 3).

old: A root input whose entry is declared `Pinned` is declaredly unseedable,
new: A root input whose input entry is declared `Pinned` is declaredly unseedable,
tag: R
ruling: R7
note: the bold goes (F60; bold at §8.2 2686); kept plain for §8.2 2689's inbound pointer. "input entry" under R13.

old: and its cell is frozen at every activation.

old: Selecting it as a `B`-matrix tap is therefore rejected at tap resolution with the offending entry in hand, rather than silently yielding a zero column (D-167).
new: Selecting such a root input as a `B`-matrix tap is rejected at tap resolution as a `TapResolution`, with the offending input entry in hand, rather than silently yielding a zero column (D-295, D-296).
tag: R
ruling: R7
newcites: D-295 D-296
note: bold headline with D-296 (bullet 4); "therefore" goes (rule first); F59 replaces D-167 by D-295 bullet 3 and D-296 bullet 4; R14 kind; R13 "input entry"; "it" becomes "such a root input" for the antecedent.

old: Under fan-out the rejection names the pinning consumer, not the face alone.
tag: R
ruling: R7
note: the bold term goes; one ruling with the rejection (D-296 bullet 4).

old: A root input is unseedable whenever any one of its consumers demands frozen, which is the fan-out meet (§8.2; D-168).

old: The author's next move is to promote that leaf to a tolerant entry, or to route the tap around it.
new: The author's next move is to promote that leaf to a tolerant input entry, or to route the tap around it.
tag: R
ruling: R13

old: Either move depends on knowing which leaf froze the root input.

old: A discrete consumer pins its entry by tier, not by declaration (§8.2), so a root input it reads is unseedable at every activation with nothing to promote.
new: A discrete consumer pins its input entry by tier, not by declaration (§8.2), so a root input it reads is unseedable at every activation with nothing to promote.
tag: R
ruling: R13

old: The rejection then names the tier, and the next move is to tap the continuous cell that consumer drives, or the recorded step map below (D-272).

old: Seeded and frozen, side by side:
new: The table sets seeded and frozen leaves side by side.
tag: X
note: the mid-sentence colon goes.

old: | leaf | in the one pass | what fixes it | |---|---|---| | a state leaf named by an `x` tap | seeded, one direction | per-invocation seeding | | any other state leaf | sits constant at the operating point | per-invocation seeding | | a root input named by a `u` tap | seeded, one direction | per-invocation seeding | | any other seedable root input | constant, its `Float64` value embedded as a zero-partial constant | per-invocation seeding | | a root input whose entry is declared `Pinned` | frozen at every activation, and rejected as a `B`-matrix tap | the schema: a declaration | | a root input a discrete consumer reads | frozen at every activation, and rejected as a `B`-matrix tap | the tier | | any discrete-tier leaf | frozen, zero partials | the tier |
note: the table, verbatim (its bare "entry" stays with it).

old: The returned object and `LinearizedSS`.
new: #### The returned value
tag: R
ruling: R8

old: `linearize` returns a `Linearization` value: `ẋ₀`, `x₀`, `u₀` and `y₀` as NamedTuples under the tap labels, `A`, `B`, `C` and `D` as matrices, and the three label sets of the taps
new: `linearize` returns a `Linearization` value (D-072, D-272). It holds `ẋ₀`, `x₀`, `u₀` and `y₀` as NamedTuples under the tap labels, `A`, `B`, `C` and `D` as matrices, and the three label sets of the taps (D-272).
tag: R
ruling: R7
newcites: D-072 D-272
note: bold headline of D-272 bullet 5, one ruling with D-072 bullet 4 ("It returns labeled data"); the mid-sentence colon becomes a sentence break.

old: (the three selector lists declaring what linearization seeds and reports) (D-272).
new: What it seeds and reads is a tap set (three labeled lists declaring what linearization seeds and reports).
tag: M
newcites:
note: the taps link and its gloss move to the first use, the context paragraph (F67); "selector" leaves the gloss because its own link comes later. D-272 stays on the returned-value sentences.

old: On that data, `subsystem`/`delete_vars` survive as pure label-indexed matrix slicing, with no model involvement.
new: On that data, FlightPhysics' `subsystem`/`delete_vars` survive as pure label-indexed matrix slicing, with no model involvement.
tag: R
ruling: R12
note: checked ~/.julia/dev/Flight.jl/lib/FlightPhysics/src/linearization.jl 8, 113, 135.

old: The `c172x_ctl` LQR pipeline consumes it with cosmetic changes.
new: Flight.jl's `c172x_ctl` LQR pipeline consumes it with cosmetic changes.
tag: R
ruling: R12
note: checked ~/.julia/dev/Flight.jl/lib/FlightApps/src/c172/c172x/control/c172x_ctl.jl (module C172XControl, LQR), included from c172x.jl 504.

old: `LinearizedSS` the component survives separately, as an ordinary continuous component in the migrated library.
new: FlightPhysics' `LinearizedSS` the component survives separately, as an ordinary continuous component in the migrated library (D-072).
tag: R
ruling: R12
newcites: D-072
note: checked FlightPhysics/src/linearization.jl 26 (the struct) and 164 (its `f_ode!`, so it runs as a model). R7 bold on D-072 bullet 5, citation added. component's link lands here, its first real use.

old: Its `x_init` is the state vector, its faces are labeled, and the affine update lives in `y_direct`/`x_deriv`.

old: It has no privileges, and its schema is everyone else's.

old: Recorded guidance.
new: #### Coordinate guidance
tag: R
ruling: R8

old: Linearization taps should select minimal-coordinate mechanizations.
new: The recorded guidance is that linearization taps should select minimal-coordinate mechanizations (D-072).
tag: C
newcites: D-072
note: "recorded" from the old label; D-072 bullet 6. Plain: a recommendation takes no bold (rulings.md).

old: Perturbing Euler-angle states is meaningful where seeding quaternion components steps off the unit-norm manifold.

old: This is why today's code linearizes the `{NED}` variant.
new: This is why Flight.jl's C172X design code linearizes the aircraft's `{NED}` variant, the one built on NED kinematics.
tag: R
ruling: R12
note: checked ~/.julia/dev/Flight.jl/lib/FlightApps/design/c172/c172x_design.jl 137 and 552 ("Cessna172Xv0(NED()) |> Model #linearization requires NED kinematics").

old: `design_world(ac)` rigs that variant, promoting implicit practice to stated rule.
new: `design_world(ac)` (the thin world that mounts an aircraft for trim and linearization) rigs that variant, promoting implicit practice to stated rule.
tag: R
ruling: R26
note: R26 drops the glossary's "shipped". linked with the glossary's gloss (F67). Not a Flight.jl name (no hit in Flight.jl's source); §14.9 introduces it.

old: The coordinate choice belongs to the tap author, not the framework.

added: #### The sampled-data extension

old: The sampled-data Dual activation is recorded, not built (a worked-out extension deliberately left unimplemented, its seams named).
new: The sampled-data `Dual` activation is recorded, not built, a worked-out extension deliberately left unimplemented with its seams named (D-073).
tag: R
ruling: R7
newcites: D-073
note: bold headline with D-073 ("sampled-data Dual activation recorded unbuilt"); the gloss becomes an appositive so the citation sits outside it.

old: The frozen-exact doctrine is consumer-scoped, not a capability wall.

old: Today's services differentiate the continuous dynamics with the discrete state held. For that, a frozen discrete output (a ZOH constant with zero partials) is the exact answer.
new: Trim and linearization differentiate the continuous dynamics with the discrete state held, and for that a frozen discrete output (a ZOH constant with zero partials) is the exact answer, as §7.2 states (D-072).
tag: R
ruling: R6
newcites: §7.2 D-072
note: M65, the law points to §7.2 1900–1904 (D-072). "Today's services" are Redstone's, not Flight.jl's: §7.2 says "Linearization and trim differentiate continuous dynamics only" (R12).

old: The type system enforces it (§8.2).
new: The discrete side pins wholesale. §8.2 states how the declarations spell this.
where: scratch_survey/h1/spec.md
tag: R
ruling: R6
note: M65, held at §7.2 1913–1914.

old: This is stated once, because the question recurs.
where: units/H/deleted.md
tag: R
ruling: R6
note: M65 and F74, false; §7.2, §9.6 and this section state it.

old: The frozen discrete cell is not an AD limitation on the signal path.
tag: R
ruling: R7
note: bold goes (F74); kept plain under R26; no entry's Position states it (D-079 Rationale).

old: It is the true zero of an instantaneous dependence that the hybrid semantics never had.
tag: R
ruling: R7
note: bold goes, as above.

old: The signal flow through a discrete component is temporal, not instantaneous, and AD follows the actual data movement.

old: `frozen_discrete_walkthrough.md` works the three-component chain through.
note: verify, C-081: kept in place, since §7.2's pointer drops "three-component".

old: Differentiating "through" the discrete side means differentiating a different object.

old: That object is the sampled-data step map $\Phi : ((x_k, s_k), \mathrm{inputs}) \to (x_{k+1}, s_{k+1})$, taken over the model's whole state, both letters at once.

old: One evaluation of $\Phi$ integrates one period, then runs the due ticks.

old: The extension is additive along existing seams.

old: Walked-leaf parametrization of the discrete tier's real-scalar state leaves.
tag: R
ruling: R7
note: bold lead-in goes plain.

old: Counters and enums stay pinned, like `m`.
note: the second #g-walked link goes (F67).

old: Opt-in participation on discrete components, with frozen-exact staying the default.
tag: R
ruling: R7
note: bold lead-in goes plain.

old: A participating component opts in through an explicit trait, and that trait turns the walk on for its contracts.
new: A participating component opts in through an explicit trait, and that trait turns the walk on for its contracts (its declared interface).
tag: R
ruling: R7
note: bold clause goes (no Position states it; D-167's Rejected list, superseded); contract linked with the glossary's gloss (F67).

old: Its `Float64` leaves follow the scalar and `Pinned` keeps its meaning, exactly as on the continuous tier (§8.2).

old: Participation therefore stays authored per leaf on that tier too, and no declaration changes shape, which gives graceful migration with no flag day.

old: One new activation (§9.4): "continuous chain + `x_deriv` + the discrete tier's output stages + `s_update`".
new: One new activation, "continuous chain + `x_deriv` + the discrete tier's output stages + `s_update`" (§9.4).
tag: R
ruling: R7
note: bold lead-in goes plain; the mid-sentence colon goes.

old: Forward sensitivities through the in-house RK steppers, for free.
tag: R
ruling: R7
note: bold lead-in goes plain.

old: That is a payoff of owning the loop (§10.1).

old: A distinct `s`-tap list beside the `x` list, labeling the step map's state blocks $\partial(x^+, s^+)/\partial(x, s)$ (D-197).
new: A distinct `s`-tap list sits beside the `x` list, labeling the step map's state blocks $\partial(x^+, s^+)/\partial(x, s)$ (D-197).
tag: R
ruling: R7
note: the bold lead-in becomes the bold headline of D-197's third Position sentence ("adds a distinct s-tap list rather than widening the x list"); "sits" gives it a verb.

old: The `x` list keeps its continuous meaning unchanged.

old: The honest boundary is that $\Phi$ is differentiable only where the event pattern is locally constant.
new: The honest limit is that $\Phi$ is differentiable only where the event pattern is locally constant.
tag: R
ruling: R9
note: F66, boundary is reserved.

old: Exactness across a firing needs saltation corrections.

old: The scope is therefore event-quiescent operating points, which trim points already are, because guards at commit see to that (§14.5).

old: The scope comes with a loud diagnostic if an event fires inside a differentiated step.

old: Two consumers wait.

old: The first is the closed-loop trim door (§14.7), whose $g(s) - s = 0$ residuals currently imply the derivative-free fallback, since a frozen `s_update` has no Jacobian columns.
new: The first is the closed-loop trim extension (§14.7), whose `s_update(s) - s = 0` residuals would currently need the derivative-free fallback, since a frozen `s_update` has no Jacobian columns.
tag: R
ruling: R13
note: door becomes extension (R13); g becomes `s_update` (R12); the fallback in the conditional (R10).

old: The second is exact discrete-time linearization of the full loop, which is digital design on the exact discretized plant instead of continuous linearization plus Tustin.

old: Declarative non-participation: what the schema states, and what stays recorded.
new: #### Declared non-participation
tag: R
ruling: R8
note: the topic label; "what stays recorded" survives in the tooling paragraph's first sentence.

old: Both halves of this door have a spelling.
new: Both halves of non-participation have a spelling (D-263).
tag: R
ruling: R13
newcites: D-263
note: door goes (R13); the bold goes plain with D-263 cited (R7, F75).

old: The output half is D-263.
new: The output half is the freeze door, which declares a leaf frozen under differentiation as §8.2 and §9.5 spell it (D-286).
tag: R
ruling: R6
newcites: §8.2 §9.5 D-286
note: M64, the one sentence naming the output half as the declared freeze door, for §8.2 2764's inbound pointer. D-263 stays cited in the sentence before.

old: A continuous producer's declaration is per-leaf, so "this port is frozen under differentiation" has a spelling.
new: `Pinned{P}` means the leaf is deliberately pinned, and the pin is schema-visible.
where: scratch_survey/h1/spec.md
tag: R
ruling: R6
note: M64, held at §8.2 2760–2761.

old: Declare the leaf `Pinned{Float64}`, and strip with `ForwardDiff.value` inside the stage (§8.2, §9.5).
new: Declare `Pinned{Float64}` and strip with `ForwardDiff.value` inside the stage (D-286).
where: scratch_survey/h1/spec.md
tag: R
ruling: R6
note: M64, held at §8.2 2764–2766 and §9.5 5018–5020; the new text points to both.

old: An opaque wrapper (an FMU, a C aerodynamic table) and a deliberately severed coupling can therefore both say so in the schema, instead of showing up in Jacobians as unexplained zero rows.

old: The conformance check holds them to it at every activation.
new: The conformance check holds them to it at every activation (D-286).
tag: C
newcites: D-286
note: D-286 Position, "the conformance check holds it to its word at every activation".

old: The input half is D-167.
new: The input half is the FFI door (§8.2).
tag: R
ruling: R6
newcites: §8.2
note: M64, pointer to §8.2 2545; F59 drops superseded D-167, and D-263 bullet 2 is cited in the next sentence.

old: A consumer's entries are per-leaf too, so a `Pinned` entry declares "never hand me partials".
new: A consumer's `Pinned` input entry declares "never hand me partials",
tag: R
ruling: R6
note: M64; "per-leaf too" rides the pointer to §8.2 (the marker per leaf, 2545–2548); "input entry" (R13).

old: That is the AD-incompatible component's own statement,
new: A component whose internals cannot propagate `Dual`s (an opaque wrapper, a C table, a hand-rolled solver) declares it.
where: scratch_survey/h1/spec.md
tag: R
ruling: R6
note: M64, held at §8.2 2546–2547.

old: enforced at the wire (§6.1).
new: enforced at the wire (§6.1, D-263).
tag: C
newcites: §6.1 D-263
note: F59, D-263 bullet 2: "an unpinned position is tolerant, a `Pinned` one demands a frozen arrival".

old: At a root input, such an entry is the forbid-seeding marker itself.
new: At a root input, such an input entry is the forbid-seeding marker itself.
tag: R
ruling: R13

old: That marker carries semantics rather than mere protection, because it types the root-input cell at every activation.

old: An unseeded root input is therefore a choice, where a `Pinned`-entry root input is a declaration.
new: An unseeded root input is therefore a choice, where a `Pinned`-entry root input is a declaration (D-295).
tag: C
newcites: D-295
note: D-295 bullet 3, "Seedability is therefore schema-visible … a `Pinned` one is declaredly unseedable".

old: Tap resolution rejects the latter with the offending entry in hand instead of returning a silent zero column.
new: Selecting such a root input as a `B`-matrix tap is rejected at tap resolution as a `TapResolution`, with the offending input entry in hand, rather than silently yielding a zero column (D-295, D-296).
tag: R
ruling: R6
newcites: D-295 D-296
note: M64 and H58, merged into the rejection's home under "Seeded and frozen leaves".

old: An implementation that cannot take `Dual`s has a third move.
tag: R
ruling: R7
note: bold lead-in goes plain; D-266's headline is bold at §8.2 2551.

old: The marker records that a leaf carries no partials, not that an implementation cannot propagate them.

old: A component that must participate, a C table or an FMU whose coupling matters to the Jacobian, keeps its entry tolerant and supplies its own local derivative inside the stage.
new: A component that must participate keeps its input entry tolerant and supplies its own local derivative inside the stage (D-266). A C table or an FMU whose coupling matters to the Jacobian is such a component.
tag: R
ruling: R7
newcites: D-266
note: bold headline of D-266 bullet 1 with its citation; the appositive becomes its own sentence so the bold holds the headline alone; "input entry" (R13).

old: It evaluates at the value, obtains a local Jacobian by whatever means it has, a finite difference at a step its own grid suggests or the table's analytic slope, and chains it onto the incoming partials (D-266)
note: the closing colon becomes a period.

old: lookup(tb, u::Float64) = c_lookup(tb, u) # nominal: straight to the table
note: the local-rule block, verbatim, first line (the block's blank line splits it in the new text's units).

old: function lookup(tb, u::ForwardDiff.Dual{Tag}) where {Tag} # Dual: the local rule u0 = ForwardDiff.value(u) y0 = c_lookup(tb, u0) h = sqrt(eps(u0)) # or a step the table's grid suggests dy = (c_lookup(tb, u0 + h) - y0) / h return ForwardDiff.Dual{Tag}(y0, dy ForwardDiff.partials(u)) end
note: the local-rule block, verbatim, the rest.

old: The stripping happens mid-expression, which §9.5 leaves legal at an unpinned leaf, and the seeded pass sees the component as an ordinary differentiable one.

old: The derivative is finite-difference in quality on this one component and exact everywhere else.

old: Linearization keeps this one mechanism and no perturbation-based fallback (D-266).
tag: R
ruling: R7
note: bold headline of D-266 bullet 3.

old: The derivative-free trim fallback (§14.8) exists for problems with no Jacobian columns, a case linearization does not have.
new: The derivative-free trim fallback (§14.8) would serve problems with no Jacobian columns, a case linearization does not have.
tag: R
ruling: R10
note: verify, C-128: the conditional, as R10 asks.

old: `handle_walk_walkthrough.md` places the rule beside the `Freeze` block (§13.7) and the pinned entry.
new: `handle_walk_walkthrough.md` places the rule beside the `Freeze` block (§13.7) and the pinned input entry.
tag: R
ruling: R13

old: What stays recorded is only the remaining tooling over that visibility.
tag: R
ruling: R7
note: the bold word goes.

old: One piece is pinned-face validation by the tap declaration, where selecting a declared-frozen output is a warning.

old: The other is a feedthrough-graph lint, where a frozen output fed by participating inputs names the severed coupling.

old: Both are additive when a consumer shows up, with no flag day.

old: Until then the declared pins and the visible zero rows suffice.

old: ---
tag: X

# Unit A claims: chapter 14 heading, §14.1, §14.2, §14.3.

old: ## 14. Stopped-sim services
tag: X

old: §9.6 previewed the services as activation clients.
new: §9.6 previewed trim and linearization as clients of an activation (the build's typed products at a given scalar type).
tag: R
ruling: R27
note: first-use link and gloss for activation, the glossary's words (#g-activation). §9.6 opens "Trim and linearization are stopped-sim services, and each is a client of an activation" (frozen spec 5102-5103).

old: They are initialization, trim and linearization.
new: The stopped-sim services are initialization, trim, linearization, and `checkpoint` with its partner `restore!`.
tag: R
ruling: R1
note: F3's five services, R1's dictated sentence. The old "A fourth stopped-sim service, `checkpoint`" folds in here.

old: Everything they share reduces to one artifact, the condition value.
new: The first three share one artifact, the condition.
tag: R
ruling: R1
note: R1 cuts "Everything they share reduces to" as false of `checkpoint` and `restore!`; its true half is this sentence. The bold term **condition value** goes plain (R7).

old: A condition is the datum that says "set this build to this state."
tag: F

old: §14.1–§14.4 settle its representation, composition and application.
new: §14.1 settles the condition's representation, §14.2 its composition, §14.3 its resolution and §14.4 its application and the read selectors;
tag: R
ruling: R1
newcites: §14.1 §14.2 §14.3 §14.4
note: R1's roadmap sentence names §14.1 to §14.10 in order by subject. §14.3's subject, resolution, is its title's. Step 5 fix1: P1-1, §14.4's read selectors join its subject, one verb for §14.1 to §14.4.

old: §14.5–§14.6 cover the boundary-zero sequence and root-input totality (the requirement that an application establishing a complete world cover every root input).
new: §14.5 covers the initialization sequence called boundary zero, §14.6 root-input totality (the requirement that an application establishing a complete world cover every root input) and `override` (the ordered, asymmetric layering combinator),
tag: R
ruling: R1
newcites: §14.5 §14.6
note: F4, boundary zero linked to #g-boundary-zero, not #g-boundary. root input gains its first-use link inside the gloss. Step 5 fix1: P1-1, one 'covers' and §14.6's `override` (its title's); P1-35, boundary zero glossed by 'the initialization sequence called', after #g-boundary-zero ('the initialization boundary: the ordinary macro-sequence'). root input stays linked inside the totality gloss, unglossed: a gloss there would nest. Final fix, finding 2: `override` takes its link and #g-override's gloss here, its first use in the opening.

old: §14.7–§14.9 cover the trim service in full.
new: §14.7 the trim problem, §14.8 the trim service, §14.9 mounting, which together cover the trim service in full,
tag: R
ruling: R1
newcites: §14.7 §14.8 §14.9
note: each section's subject from its title (§14.7 "The trim problem", §14.8 "The trim service", §14.9 "Mounting"). Step 5 fix1: P1-1 drops 'which together cover the trim service in full': §14.9's mounting also relocates tap sets, so the three sections are more than the trim service; each keeps its subject. Final fix, finding 1: the claim is restored, since the three sections still cover the trim service in full.

old: §14.10 covers linearization.
new: and §14.10 linearization.
tag: F
note: Step 5 fix1: P1-1.

old: A fourth stopped-sim service, `checkpoint`, returns a checkpoint (the `Model`'s state at a frame top as one value).
new: `checkpoint` returns a checkpoint (the `Model`'s state at a frame top as one value), and `restore!` puts it back.
tag: R
ruling: R1
note: "a fourth stopped-sim service" goes with F3's count; the service count now sits in the sentence naming five. `Model` takes its first-use link here (late in the old text). Step 5 fix1: P1-2 writes `Model` plain here; its link joins its gloss in the lifecycle paragraph's `Model` form.

old: A checkpoint is not a condition and has no algebra, and `restore!` puts it back (D-273).
new: A checkpoint is a distinct value with no condition algebra (D-273).
tag: R
ruling: R1
note: R1's dictated sentence; "`restore!` puts it back" moved into the sentence before, inside one paragraph.

old: Lifecycle preconditions.
new: #### Lifecycle preconditions
tag: R
ruling: R1
note: M6. The bold label becomes a #### topic label.

old: Every service requires a non-running simulation.
new: Every service requires a non-running simulation (D-108).
tag: C
newcites: D-108
note: R7 bold headline for D-108's first ruling, "every stopped-sim service requires a non-running simulation, pause included". D-108 was cited only at old 11310.

old: While a run exists the loop owns the stores between drains (the frame-top swap that publishes staged device writes into the root inputs), and a service reading or writing them would race it.
new: While the simulation is `running`, the loop owns the stores (the framework-owned homes of components' `x`, `s` and `m` state). It owns them between drains (the frame-top swap that publishes staged device writes into the root inputs), and a service reading or writing them would race it.
tag: F
note: Step 5 fix1: P1-3, P1-35.

old: Pause is no exception, by the doctrine that freezes the roster.
new: Pause is no exception, by the doctrine that freezes the roster (the list of attached devices, read once at `run!`).
tag: F
note: first-use gloss for roster, from #g-roster ("the list of attached device entries ... the loop reads once at `run!`").

old: Pause is a control-plane state inside a run, so a prohibition that holds mid-run holds while paused (§11.3, §12.1).
new: Pause is a state inside a run, carried by the control plane (the separate atomic surface for pause, pace and the stop word), so a prohibition that holds mid-run holds while paused (§11.3, §12.1).
tag: F
note: control plane takes a first-use link (#g-control-plane). Step 5 fix1: P1-35.

old: Within the stopped-sim states, legality follows each service's inputs.
new: Within the stopped-sim states, legality follows each service's inputs (D-108).
tag: C
newcites: D-108
note: R7 bold headline for D-108's second ruling, "within the stopped states legality follows each service's inputs".

old: | service | `built` | `initialized` | `stopped` | its inputs | |---|---|---|---|---| | `checkpoint` | error | legal | legal | a frame-top rest; refused after a `t` stop and after an abandoned frame | | `init!` | legal | legal | legal | authored conditions | | `restore!` | legal | legal | legal | a checkpoint whose fingerprint and deployment match the simulation's and whose `t` sits on its grid (§12.6) | | `trim!` | legal | legal | legal | authored conditions; the scratch world is `override``(baseline, condition(guess))` (§14.8), never the sim's stores | | `linearize`, operating point defaulted to `checkpoint(sim)` | error | legal | legal | inherits `checkpoint`'s precondition, its refusals included | | `linearize`, explicit `about` (§14.10) | legal | legal | legal | inherits `init!`'s legality — legal wherever `init!` is |
new: | service | `built` | `initialized` | `stopped` | its inputs | |---|---|---|---|---| | `checkpoint` | error | legal | legal | a frame-top rest; refused after a `t` stop and after an abandoned frame | | `init!` | legal | legal | legal | authored conditions | | `restore!` | legal | legal | legal | a checkpoint whose fingerprint and deployment match the simulation's and whose `t` sits on its grid (§12.6) | | `trim!` | legal | legal | legal | authored conditions; the scratch world is `override(baseline, condition(guess))` (§14.8), never the sim's stores | | `linearize`, operating point defaulted to `checkpoint(sim)` | error | legal | legal | inherits `checkpoint`'s precondition, its refusals included | | `linearize`, explicit `about` (§14.10) | legal | legal | legal | inherits `init!`'s legality, legal wherever `init!` is |
tag: R
ruling: R27
note: the table, verbatim except its last cell's em dash, now a comma. Final fix, finding 2: `override` here is plain, its link and gloss now at the roadmap's first use.

old: Each row's service also has a form on a `Model` (a deployment materialized at one scalar type), gated by the model's status rather than by the lifecycle (D-319).
new: Each row's service also has a form on a `Model` (a deployment materialized at one scalar type), gated by the model's status rather than by the lifecycle (D-319).
tag: M
note: M1, moved after the ServiceLifecycle paragraph within the heading. R7 bold headline "Each row's service also has a form on a `Model`" for D-319's second sentence, "`checkpoint`, `restore!`, `trim!` and `linearize` are doors of the `Model`". The `Model` link moved to the first use, in the opening's checkpoint gloss; this gloss stays. Step 5 fix1: P1-2: the `Model` link now sits here, with its gloss.

old: `checkpoint` and the default `linearize` are legal at `:consistent`.
tag: M
note: M1; D-319 cited in the paragraph.

old: `init!`, `restore!`, `trim!` and `linearize` with an explicit `about` are legal at any status.
tag: M
note: M1.

old: A model a simulation has claimed refuses each form that writes, `init!`, `restore!` and `trim!` (D-318).
new: A model a simulation has claimed refuses each form that writes, `init!`, `restore!` and `trim!`, as `ArgumentInvalid` with reason `:claimed` (D-318).
tag: R
ruling: R14
note: M1 and F5. D-318 bullet 3 names the kind and reason ("refused as `ArgumentInvalid` with reason `:claimed`"); `src/model.jl` 150.

old: `errored` is terminal for every row (D-059, D-108).
new: No service accepts an `errored` simulation (§12.6, D-108).
tag: R
ruling: R2
newcites: §12.6 D-108
note: R2's dictated wording; §12.6 bolds "`errored` is terminal" on D-059, so D-059 leaves this sentence.

old: Post-mortem inspection of an errored sim's stores, log and trace stays available as a diagnostic read.
new: Post-mortem inspection of an errored sim's stores, log and trace (the primary record of a session) stays available as a diagnostic read (D-232).
tag: C
newcites: D-232
note: D-232 Position, "The stopped-sim reads stay admitted there: post-mortem inspection is reading." Trace gloss from #g-trace.

old: It may not become a checkpoint.
new: It may not become a checkpoint (D-108, D-274).
tag: C
newcites: D-108 D-274
note: verify. D-108 Rationale, "post-mortem stores/log/trace stay readable as diagnostics, never as condition values", and its rejected `capture` on `errored`; D-274 bullet 2, `checkpoint(sim)` "legal in `initialized` and `stopped`".

old: A violation is `ServiceLifecycle` (Appendix C).
new: A violation is `ServiceLifecycle` (Appendix C, D-108).
tag: C
newcites: Appendix C D-108
note: D-108 Rationale, "one kind `ServiceLifecycle` (operation, current status, legal statuses)"; listed under Rationale-only rulings.

old: Its payload is the operation, the current status and the legal statuses.
tag: F

old: It is the same kind `attach!`/`detach!` raise while `running` (§11.3), so there is one error form for "this operation is illegal in the current lifecycle state."
tag: F

old: `MissingInit` is distinct, and names a missing prior step.
tag: F

added: The `checkpoint` row's two refusals, after a `t` stop and after an abandoned frame, are `CheckpointMidFrame` (§12.6, Appendix C).

old: ### 14.1 Conditions are path-addressed overlays on the declared defaults
tag: X

added: This section covers, in order, what a condition may specify, the overlay base, why addressing a condition by path is legitimate, the pre-sweep doctrine and the environment queries a condition may make.

old: A condition may specify state fields (`x` on the continuous tier, `s` on the discrete) and modes (`m`, continuous components only, §3.2).
new: A condition may specify state fields, `x` on the continuous tier (one side of the hybrid formalism) and `s` on the discrete. It may also specify modes, `m`, which only continuous components have (§3.2).
tag: F
note: split; two parentheticals in one sentence became two sentences. Step 5 fix1: P1-4, P1-35.

old: All three are addressed by a §8.6 slash path plus a field name.
new: All three are addressed by a slash path (§8.6) plus a field name.
tag: F

old: It may also specify root inputs, addressed by face.
new: Beyond state, a condition may specify root inputs (the root's own input faces). It addresses them by face (the name a port wears on its component's boundary).
tag: F
note: face gloss from #g-face; "a condition" replaces "It" after the split above. Step 5 fix1: P1-35.

old: It never specifies outputs, which are derived data.
new: It never specifies outputs, which are derived data (D-063).
tag: C
newcites: D-063
note: R7 bold headline for D-063's second ruling, "never outputs or workspace".

old: It never specifies workspace (component-declared mutable scratch arriving as the `ws` bundle field).
new: It never specifies workspace (component-declared mutable scratch arriving as the `ws` bundle field) (D-306).
tag: C
newcites: D-306
note: D-306 bullet 1, "A workspace is never a condition target." O14: §7.3 is the home; this clause stays and cites.

old: Entries are validated in the §13.1 collecting form.
new: Condition entries are validated in the collecting form (§13.1).
tag: R
ruling: R13
note: F29, bare entry.

old: The full list is checked, violations are collected, and one `DiagnosticError` is thrown.
tag: F

added: A condition entry naming an output or a workspace field is one such violation, `ConditionResolution` with reason `:undeclared_field` (Appendix C).

old: The overlay base is always the declared defaults.
new: The overlay base is always the declared defaults (D-063).
tag: C
newcites: D-063
note: R7 bold headline for D-063's first ruling, "sparse overlays ... on the declared `init_*` defaults"; its Rejected list fights the current-stores base. D-063 was cited two sentences later.

old: Every store has a declared initial value (declaration-by-initial-value, §8.2), so conditions are naturally sparse.
new: Every store (the framework-owned home of a component's `x`, `s` or `m` state) has a declared initial value under declaration-by-initial-value (§8.2), so conditions are naturally sparse.
tag: F
note: the citation left the parentheses; store gloss from #g-store.

old: Applying one means "fresh run from the `x_init`, `s_init` and `m_init` defaults, with these overrides" (D-063).
tag: F

old: A condition is an initial condition and nothing else (D-273).
tag: F
note: R7 bold headline for D-273's first sentence; H1 makes §14.1 its home.

old: A simulation's state past its initial instant is a checkpoint (the `Model`'s state at a frame top as one value), not a condition, and it has no algebra (D-274).
tag: F

old: Doctrine. Addressing conditions by path does not reopen the observation-by-path rejection (§13.5).
new: Addressing conditions by path does not reopen the observation-by-path rejection (§13.5, D-409).
tag: R
ruling: R4
newcites: §13.5 D-409
note: the Doctrine. label goes; R4's dictated paragraph.

old: That rejection was about runtime coupling, where a root-authored predicate reaches through generic seams the root does not own and breaks on substitution.
new: That rejection bars a run from acting on reads its model did not declare.
tag: R
ruling: R4
note: R4 cuts "Runtime coupling ... breaks on substitution"; its ground is §13.5's. The seam link and the predicate clash go with it.

old: A condition is a design-time statement about a concrete build.
new: A condition is not such a read. It is a design-time statement about a concrete build, written before the run begins,
tag: R
ruling: R4

old: It is authored in the same vocabulary as `local_wires`, which also speaks paths, about children its author owns.
new: and the locality law of §14.2 is how an author keeps it to children the author owns.
tag: R
ruling: R4
newcites: §14.2
note: R4 cuts the `local_wires` parallel as false since D-207 made every wire one level; "children its author owns" survives in the dictated clause.

old: The composition law (§14.2) makes the parallel exact.
new: and the locality law of §14.2 is how an author keeps it to children the author owns.
tag: R
ruling: R4
note: R4 cuts "the composition law makes the parallel exact"; the §14.2 citation survives in the dictated clause.

old: Pre-sweep doctrine. Condition writes precede the first sweep by definition.
new: This is the pre-sweep doctrine, and it holds because condition writes precede the first sweep (one pass through the execution order against the current state) by definition.
tag: F
note: the bold label becomes "This is the pre-sweep doctrine" after its rule; the rule comes first and its reason follows ("Rule first, reason after"). The causal direction is kept: writes precede the sweep, so the value is either known or a constraint. Sweep gloss from #g-sweep.

old: A would-be init value that depends on swept outputs is therefore either analytically known to the caller or an equilibrium constraint.
new: A would-be init value that depends on swept outputs is either analytically known to the caller or an equilibrium constraint (D-064).
tag: C
newcites: D-064
note: R7 bold headline for D-064's second ruling, the pre-sweep doctrine ("a condition value needing swept outputs is caller-computable ... or an equilibrium constraint"). "therefore" becomes the "because" of the next sentence.

old: The first case is trim's `α_filt = α_a`.
new: The first case is trim's `α_filt = α_a` (§14.2).
tag: F
newcites: §14.2
note: Step 5 fix1: P1-6, a pointer to §14.2's block, which sets `α_filt = α_a`.

old: There α is a decision variable, so the value is known above, not computable below.
tag: F

old: The second case is a job for the trim service, not for init.
tag: F

old: "Caller-computable" reaches past closed-form knowledge to environment queries.
new: "Caller-computable" reaches past closed-form knowledge to environment queries (D-139).
tag: C
newcites: D-139
note: bold term **environment queries** becomes the bold headline clause; D-139 Rationale, "§14.1's caller-computable escape is extended to cover environment queries". Rationale-only.

old: A condition needing one constructs the same handle the sweep will produce, and then calls the same query function the consuming component calls.
tag: F

old: There are two routes to that handle.
tag: F

old: One is the value-level constructor (the plain public function building a field handle from the component and input values, §8.2), applied to the same values the `baseline` writes into the environment component's root inputs.
new: One is the value-level constructor (the plain public function building a field handle from the component and input values) of §8.2. The condition applies it to the same values the `baseline` (the full-coverage condition `trim!` takes as a keyword) writes into the environment component's root inputs.
tag: F
note: the citation left the gloss's parentheses. Step 5 fix1: P1-35.

old: The other applies in a rig where an isbits handle itself is a root-input value (§4.4, D-364).
tag: F

old: There the condition simply holds the value the `baseline` wrote.
tag: F

old: Either way there is one implementation of the field math, evaluated one level up, with no pre-sweep and no new mechanism.
tag: F

old: Where closed-form enforcement of a target is not wanted at all, the second escape already covers the case.
new: Where closed-form enforcement of a target is not wanted at all, the doctrine's second case already covers it (D-139).
tag: C
newcites: D-139
note: D-139 Rationale, "the environment-free fallback through the existing second escape". Rationale-only. Step 5 fix1: P1-5.

old: Promote the eliminated state coordinates to decision variables and enforce the targets as residuals on swept outputs.
tag: F

old: That route needs no environment access at condition time whatsoever.
tag: F

old: ### 14.2 Fragment composition: locality without schema
tag: X

old: Init knowledge is component-local.
tag: F

old: The engine knows `n_eng → ω = n_eng·ω_rated`, and nothing above it should have to.
new: An engine component knows `n_eng → ω = n_eng·ω_rated`, where `n_eng` is the engine speed as a fraction of its rated speed, and nothing above it should have to.
tag: F
note: Step 5 fix1: P1-6's `n_eng` gloss; final fix, finding 3, folds it into this sentence so 'that locality' keeps its antecedent.

old: Making that locality a schema entry was rejected (D-064).
tag: F
note: "a schema entry" stays, as D-064's compound (R13).

old: That spelling would declare `initialize(::C, spec)`, today's `f_init!` reborn declaratively, and add an assembly-level rule routing sub-specs to children.
new: That spelling would declare `initialize(::C, spec)`, a declarative rebirth of `f_init!`, FlightCore's per-model initialization hook. It would also add an assembly-level rule routing sub-specs to children.
tag: R
ruling: R12
note: "today's" becomes FlightCore's; checked in `~/.julia/dev/Flight.jl/lib/FlightCore/src/modeling.jl` 200-206 (`f_init!(::Model) = nothing`, "nothing to initialize by default"). Split into two sentences.

added: This section covers, in order, the condition method, composition by pull, what `set`'s payloads may name, the inert tree, the empty-prefix refusal, the locality law, and the collision and blend errors.

old: What preserves the locality is an idiom, not schema.
new: What preserves the locality is an idiom, not schema (D-064).
tag: C
newcites: D-064
note: R7 bold headline for D-064's first ruling, "Per-component init knowledge = fragment-returning user functions dispatched on component types, composed by pull", against its rejected `initialize(::C, spec)` schema.

old: It is the condition method, a method of the framework's `condition` generic, shipped beside the component and dispatched on the component, returning the component's own fragment.
new: It is the condition method, a method of the framework's `condition` generic, shipped beside the component and dispatched on the component, returning the component's own fragment (the leaf node of the condition algebra, built by `set`) (D-405).
tag: C
newcites: D-405
note: bold term **condition method** goes plain; D-405 bullet 2, "A method of the `condition` generic is a condition method". Fragment gloss from #g-fragment ("the leaf node of the condition algebra, built by `set(; x, s, m, u)`"). condition takes its first-use link here (late at old 11451). Step 5 fix1: P1-35.

old: The generic is framework-owned so that an owner's pull reaches a child's fragment across a package seam.
new: The generic is framework-owned so that an owner's pull, described below, reaches a child's fragment when the two live in different packages.
tag: R
ruling: R13
note: seam is reserved for a narrow, named interface; "a package seam" becomes "different packages". "described below" points to the pull, defined after (define-before-use).

old: A model package extends it through `import Redstone: condition`, as it extends the declaration family (§8.1).
tag: F

old: No shadowing check covers it:
new: No shadowing check covers it, because
tag: F
note: verify. The colon's causal sense becomes "because" (D-316).

old: a method written to a foreign `condition` fails loudly at the owner's pull, as a `MethodError` naming the child.
new: a method written to a foreign `condition` fails loudly at the owner's pull, as a `MethodError` naming the child (D-316).
tag: C
newcites: D-316
note: D-316 Rationale (log 13997-13999), "`condition` stays outside the family because a foreign `condition` fails loudly, as a `MethodError` at the owner's pull". Rationale-only.

added: In the first block, the engine is an illustrative component named after FlightPhysics' `PistonEngine`, and `Phase` an illustrative enum of its modes.

old: `condition(eng::PistonEngine; n_eng) = set(x = (ω = n_eng eng.ω_rated,), m = (phase = Phase.running,))`
tag: F
note: block verbatim (O16 keeps `eng.ω_rated`). The added sentence before it is R12's introducing clause, checked in `~/.julia/dev/Flight.jl/lib/FlightPhysics/src/piston.jl` 220-222 (`struct PistonEngine`, field `ω_rated`); FlightPhysics' engine phase is `EngineState`, not `Phase`, so `Phase` is called illustrative.

old: Fragments are composed by pull from the structure's owner.
new: Fragments are composed by pull from the structure's owner, here `C172XSystems` (the C172X aircraft's systems assembly, after FlightApps' `C172X.Systems`).
tag: R
ruling: R12
note: R12's gloss for `C172XSystems`; checked in `~/.julia/dev/Flight.jl/lib/FlightApps/src/c172/c172x/c172x.jl` 207 (`const Systems = C172.Systems{...}`). Step 5 fix1: P1-6's `α_filt` clause is the added block below.

old: `condition(sys::C172XSystems; n_eng, α_a, β_a) = combine( at("pwp/engine", condition(sys.pwp.engine; n_eng)), at("aero", set(x = (α_filt = α_a, β_filt = β_a))))`
tag: F
note: block verbatim.

old: `set`'s payloads speak only about the component at the authoring point.
tag: M
note: M2, moved up from after the empty-prefix rule to after the owner-pull block.

old: Addressing children is exclusively `at`'s job, so there is one way to say everything.
new: Addressing children is exclusively the job of `at` (the scoping combinator), so there is one way to say everything.
tag: M
note: M2. First-use link for `at` (#g-at, "the scoping combinator"), never linked in the old half.

old: A `u` payload names faces of the authoring level's contract.
new: A `u` payload names faces of the authoring level's contract (its declared interface).
tag: M
note: M2. Step 5 fix1: P1-35.

old: Resolution walks the export chain to the root input and errors if the face never surfaces.
new: Resolution walks the export chain to the root input and errors if the face never surfaces (D-065), as `ConditionResolution` with reason `:no_input_face`, or `:unexported_face` at the root (Appendix C).
tag: R
ruling: R14
newcites: D-065 Appendix C
note: M2. F5 names the kind and reasons (`src/conditions.jl` 446-452, `_root_input`). R7 bold headline for D-065's ruling "slots resolve through export chains (unexported = unwritable, init included)".

old: That walk always has a name to follow.
tag: M
note: M2.

old: One-level routing gives every level a declared face for every signal crossing its boundary, so the chain a sub-assembly's face routes through is in the `Build` (§6.1, §9.2).
new: One-level routing gives every level a declared face for every signal crossing its boundary, so the chain a sub-assembly's face routes through is in the `Build` (§6.1, §9.2, D-207).
tag: M
newcites: §6.1 §9.2 D-207
note: M2; §6.1 1573 relies on this sentence, which stays in §14.2. D-207 bullet 2, "The face graph is therefore total — every signal crossing an assembly boundary bears a declared face there — and the `Build` retains it". "its boundary" is a component's structural boundary, a sense *boundary* keeps.

old: An internally-wired input has no root input behind it, and writing it would be meaningless because the first sweep overwrites it.
tag: M
note: M2.

added: Such a write is `ConditionResolution` with reason `:internally_wired`.

old: Unexported stays unpokeable for init exactly as it does for the GUI (§11.7).
new: Unexported stays unpokeable for init exactly as it is for a front end's panels (§11.7).
tag: R
ruling: R9
note: M2 and F14, the parked GUI (D-310) as a front end's.

old: Dispatch selects variant-specific methods, so the c172s/c172x actuation split costs no upstream edits.
new: Dispatch selects variant-specific methods, so the actuation split between Flight.jl's two Cessna 172 variants, c172s and c172x, costs no upstream edits.
tag: R
ruling: R12
note: checked in `~/.julia/dev/Flight.jl/lib/FlightApps/src/c172/c172s/c172s.jl` 153 (`MechanicalActuation`) and `c172x/c172x.jl` 207 (`FlyByWireActuation`). Step 5 fix1: P1-8 moves it to just after the `C172XSystems` block it comments on; P1-7 names the owner (both files sit in Flight.jl's lib/FlightApps/src/c172/).

old: The three combinators are constructors of an inert, lazy tree.
new: Composition builds an inert, lazy fragment tree (the nested `Fragment`, `Scoped`, `Combined` and override nodes) (D-065). `set` builds the leaf, `at` and `combine` (the symmetric, collision-intolerant combinator) build the tree's inner nodes,
tag: R
ruling: R9
newcites: D-065
note: F8's dictated clause; "three combinators" counted `set` and left out `override`. The bold term **inert, lazy tree** becomes the bold headline for D-065's first ruling, "Fragments form a lazy inert tree (... store, never apply — stack-only rebuild per iteration)"; fragment tree takes its link (#g-fragment-tree). `combine` takes its first-use link and gloss (#g-combine). R36 adds the clause "and `override` builds a fourth node type (§14.6)", the added block below, worded by R38; an added block takes no ruling field. Step 5 fix1: P1-35.

old: No path arithmetic happens at composition.
tag: F

old: `struct Fragment{X,S,M,L} x::X; s::S; m::M; u::L end #set(; x, s, m, u): self-vocabulary payloads; no paths struct Scoped{N} prefix::String; node::N end #at(prefix, node): stores, never applies struct Combined{T<:Tuple} nodes::T end #combine(ns...): collects; order = diagnostics only`
tag: F
note: block verbatim.

old: Every node is isbits except the prefix strings, and a prefix is a reference to the author's own literal.
tag: F

old: So rebuilding the tree per trim iteration allocates nothing.
new: So, with literal prefixes, rebuilding the tree per trim iteration allocates nothing.
tag: R
ruling: R9
note: F9 (a). The old bold clause goes plain; D-065's first ruling is bold on the inert tree, first in reading order.

old: There is no path arithmetic and no copy of the payloads.
tag: F

old: The one validation is the empty-prefix check below, which reads a length and allocates nothing.
new: Composition checks three things, each by type or length alone, and none allocates. Each `set` payload is a NamedTuple, each combinator operand is a node, and each `at` prefix is nonempty.
tag: R
ruling: R9
note: F8, the brief's amended wording. The empty-prefix check stays one of the three; "reads a length" survives as "by type or length alone".

added: A `set` payload that is not a NamedTuple is `ConditionNodeMisuse` with reason `:set_payload` (Appendix C).

old: The zero-alloc property of today's `assign!` loop holds of the construction and of the walk that applies the tree (§14.4) alike.
new: The trim of Flight.jl's Cessna 172 model (`c172.jl`) writes each trial state through FlightPhysics' `assign!`, a loop that allocates nothing. That property holds of the construction with literal prefixes and of the specialized `apply!` that writes the tree (§14.4) alike.
tag: R
ruling: R35
note: R35 scopes the construction to literal prefixes, as F9 (a). R9's F9 (b), the specialized `apply!` only. R12 and R23, "today's" becomes the owner the source shows, Flight.jl's Cessna 172 model calling FlightPhysics' `assign!`: checked in `~/.julia/dev/Flight.jl/lib/FlightPhysics/src/aircraftbase.jl` 94 (`assign!(vehicle, params, state, ...)`) and `lib/FlightApps/src/c172/c172.jl` 876 (the C172 trim's target function calls `AircraftBase.assign!` per evaluation). Step 5 fix1: P1-10.

old: An evaluation's cost is therefore the sweep it feeds.
tag: F

old: Rule. `at` refuses an empty prefix when it is called.
new: `at` refuses an empty prefix when it is called (D-278).
tag: R
ruling: R7
newcites: D-278
note: the Rule. label goes; R7 makes §14.2 D-278's bold home, with D-278 in the sentence.

old: An empty prefix names no child, and a node meant for the level where it is authored stays unwrapped.
tag: F

old: The refusal holds at the root too, because `at` builds an inert tree and cannot know where it will be mounted.
tag: F

old: On a condition node it raises `ConditionNodeMisuse` (Appendix C) before any resolution pass runs.
new: On a node of a condition (the path-addressed sparse overlay that sets a build's state), `at` raises `ConditionNodeMisuse` with reason `:empty_prefix` (Appendix C) before any resolution pass runs.
tag: R
ruling: R14
note: the reason, `src/conditions.jl` 93-94. Step 5 fix1: P1-35.

old: The read side's lifts refuse the same way (§14.9, D-278).
tag: F

old: The locality law here is the one §6.1 states for connections, now in its third instance.
new: The locality law here is the one §6.1 states for connections, now in its third instance (D-065).
tag: C
newcites: §6.1 D-065
note: the bold term becomes the bold headline for D-065's locality ruling, "locality law = §6.1's, third instance (own fields, declared children, own faces ...)"; the clause stands as D-065's annotation reads it. D-065 was cited later in the paragraph.

old: The three instances are local wires, computed interface connections and conditions.
new: The three instances are local wires (wires from one child's port to a child's face), computed interface connections and conditions.
tag: F
note: Step 5 fix1: P1-35.

old: Each level speaks its own fields, its declared children's names, and its own faces.
tag: F

old: Delegation runs by dispatch at every genericity seam.
new: Delegation runs by dispatch at every genericity seam (a narrow, named interface kept deliberately thin).
tag: F
note: verify. The added D-064 citation is dropped: its Position says "dispatched on component types" and nothing of seams. Step 5 fix1: P1-35.

old: An `at` prefix may stop at any child's faces, owned or generically held, because the face graph is total (D-207).
new: An `at` prefix may stop at any child's faces, owned or generically held (held through a non-concrete field type), because the face graph is total (D-207).
tag: F
note: generic holding takes its first-use link (#g-generic-holding). Step 5 fix1: P1-35.

old: A deep `at` or condition path resolves wherever the structure has it (§13.3, D-414).
tag: F

old: Absolute paths exist only in the flattened entry list, a compiled derivative of the composition, as cell offsets are of `local_wires`.
new: Absolute paths exist only in the flattened list of condition entries, a compiled derivative of the composition, as the offsets of cells (the typed entries of the signal table) are of `local_wires`.
tag: R
ruling: R13
note: F29, bare entry. §13.3 10251 relies on this sentence. Step 5 fix1: P1-35.

old: Substituting a component invalidates precisely the fragments its owner shipped, nothing else.
new: Under the locality law, substituting a component invalidates only the fragments its owner shipped.
tag: R
ruling: R9
note: F10.

old: The build checks the law wherever it can see what the law constrains.
tag: F

old: Wiring resolves one level (§6.1).
tag: F

old: The faces a `u` payload names resolve through the export chain, under any `at` prefix (D-207).
tag: F

old: No check refuses a deep path past a generically held field (D-414).
tag: F

old: An author who ships a fragment for a family scopes it by dispatch on the holding's type parameter, so a fragment reaching into one powerplant is defined for the aircraft that hold that powerplant.
new: An author who ships a fragment for a family scopes it by dispatch on the holding's type parameter, so a fragment reaching into one powerplant is defined for the aircraft that hold that powerplant (D-414).
tag: C
newcites: D-414
note: D-414 bullet 4, "An author scopes a fragment's or a problem's applicability by dispatch on the holding's type parameter".

old: Ownership alone is convention.
tag: F

old: It is a fact about who maintains the code, and the build cannot see it, so keeping a deep path inside an owned subtree is idiomatic rather than machine-checked (D-065).
tag: F

old: `set`/`at`/`combine` are §13.7 standard-library material, ordinary artifacts with no privileges.
new: `set`, `at` and `combine` are ordinary functions with no privileges, as the blocks of §13.7 are ordinary components.
tag: R
ruling: R9
note: F7 (carried B83), its possessive citation unwound.

old: A combine collision is two entries on one leaf.
new: A `combine` collision is two condition entries on one leaf.
tag: R
ruling: R13
note: bare entry; the combine link moved to its first use above.

old: Collisions are errors at resolution, and the error reports both origins.
new: Collisions are errors at resolution (D-065). The error is `DuplicateConditionLeaf` (Appendix C), and it reports both origins.
tag: R
ruling: R14
newcites: D-065 Appendix C
note: F5 names `DuplicateConditionLeaf`. R7 bold headline for D-065's "duplicate leaf = error with both origins".

old: The message names the layering combinator:
new: Its message names the layering combinator. It reads
tag: F
note: verify. The colon becomes a full stop and "It reads", so the quote does not read as the combinator's name.

old: "`combine` is collision-intolerant by design — use `override(base, patch)` to layer."
tag: F
note: quoted message verbatim, its em dash included.

old: Last-writer-wins was rejected (D-065).
tag: F

old: That rejection is also why the combinator is not `Base.merge`, and is no longer named after it (D-204).
new: The combinator is not `Base.merge`, and is no longer named after it (D-204). The last-writer-wins rejection is also the reason.
tag: F
note: R7 bold headline "the combinator is not `Base.merge`" for D-204's first sentence, the rename to `combine`. Step 5 fix1: P1-11, rule first: the bold sentence leads and the rejection follows as its reason.

old: `Base.merge` is last-wins on NamedTuples, the exact semantics rejected here, and its own name should not promise them.
tag: F

old: Because `combine` is its own function, a bare NamedTuple blended into a node cannot fall through to any last-wins method.
tag: F

old: The blend is still closed explicitly.
tag: F

old: A `combine(::Fragment, ::NamedTuple)`, or any other blend of a condition node with a bare NamedTuple, is an error method.
tag: F
note: the bold term **error method** goes plain.

old: Its message is directive: wrap the NamedTuple in `set(…)` (or `at(prefix, set(…))`) and combine nodes with nodes.
new: Its message is directive. It says to wrap the NamedTuple in `set(…)` (or `at(prefix, set(…))`) and to combine nodes with nodes.
tag: F
note: the mid-sentence colon becomes a full stop.

old: The rejection carries a kind like every other.
new: Like every other, the rejection carries a kind (a diagnostic's identity in a closed, enumerated set).
tag: F
note: Step 5 fix1: P1-35.

old: It is `ConditionNodeMisuse` (Appendix C), carrying the offending argument's type and the node kinds in hand.
new: The blend rejection is `ConditionNodeMisuse` (Appendix C, D-113), carrying the offending argument's type and the node types in hand.
tag: R
ruling: R38 B5
newcites: Appendix C D-113
note: D-113 bullet 4, "`ConditionNodeMisuse` for §14.2's mixed-`merge` error method: offending argument type, node kinds in hand"; R7 bold headline. B5: the bold's subject "It" becomes "The blend rejection", the blend of a node with a bare NamedTuple the paragraph closes.

old: It is raised at composition time, before any resolution pass runs or any origin exists.
tag: F

old: That is why it is its own kind and not a `ConditionResolution` sub-kind (§14.3).
tag: F

old: The explicit, ordered layering spelling, `override`, belongs with the use case root-input totality produces (§14.6).
new: The explicit, ordered layering spelling, `override`, belongs with the use case that root-input totality (the requirement that an application establishing a complete world cover every root input) produces (§14.6).
tag: F
note: `override` takes its first-use link (#g-override); its first mention, inside the quoted message, is code. Step 5 fix1: P1-9, P1-35. Final fix, finding 4: 'produces' restored, keeping the causal link.

old: ### 14.3 Resolution: flatten, validate, compile once
tag: X

old: Resolution takes the root node plus a `Build`.
new: It takes the root node plus a `Build` (the artifact `build(world)` produces).
tag: F
note: `Build` takes its first-use link and gloss (#g-build, "the artifact `build(world)` produces"). Step 5 fix1: P1-4's context sentence is the added block below; condition's link and gloss move to it from the flattening paragraph (P1-35).

added: This section covers, in order, flattening, the collecting checks, the two lookup families, the plan, the converter rule with its two cases, and overlay partiality.

old: Flattening is the only place path strings are ever concatenated.
new: Flattening is the only place path strings are ever concatenated (D-065).
tag: C
newcites: D-065
note: R7 bold headline for D-065's "all flattening/validation/addressing at resolution against the `Build`"; its Rejected list refuses eager concatenation in `at`.

old: It is a trivial recursion with a path accumulator, and it also records each entry's tree position, its `getfield`/`getindex` step tuple.
new: It is a trivial recursion with a path accumulator, and it also records each condition entry's tree position, its `getfield`/`getindex` step tuple.
tag: R
ruling: R13
note: F29. The bold term **tree position** goes plain. condition takes its first-use link here (late at old 11547). Step 5 fix1: P1-35.

old: The collecting pass then checks each flat entry:
new: The collecting pass then checks each flat condition entry:
tag: R
ruling: R13
note: F29.

old: - the path resolves, with did-you-mean (the offending name plus the list-in-hand it should have matched) over children;
new: the path resolves, with did-you-mean (the offending name plus the list-in-hand it should have matched) over children;
tag: F

old: - the field is declared in the target's `x_init`/`s_init`/`m_init`;
new: the field is declared in the target's `x_init`/`s_init`/`m_init`;
tag: F

old: - the value type is convertible to the declared leaf type;
new: the value type is convertible to the declared leaf type;
tag: F

old: - input faces reach root inputs;
new: input faces reach root inputs;
tag: F

old: - no `(path, store, field)` is duplicated.
new: no leaf is written twice, where a `u` payload's leaf is the root input its face resolves to.
tag: R
ruling: R9
note: F11; `_key`, `src/conditions.jl` 175-176. F11's "an input entry's leaf" is respelled "a `u` payload's leaf": input entry is §8.2's compound in the glossary (#g-entry), a `u_types` entry.

added: Each check names its kind (Appendix C). A path that does not resolve is `PathResolution` with reason `:unknown_child`. An undeclared field is `ConditionResolution` with reason `:undeclared_field`, or `:no_store` or `:assembly_path` where the target has no such store or is an assembly. A value that does not convert is `ConditionResolution` with reason `:unconvertible`. A face that reaches no root input takes one of the face reasons §14.2 names. A leaf written twice is `DuplicateConditionLeaf`.

old: The `Build` supplies two lookup families.
tag: F

old: Schema is the evaluated declarations, and it is the authority.
tag: F
note: the bold term **Schema** goes plain and takes the #g-schema-vs-layout link, unlinked in the old text.

old: It answers whether you may write this field, and at what leaf type.
tag: F

old: Layout is the destination.
tag: F
note: the bold term **Layout** goes plain; the anchor is linked once, at Schema.

old: It holds the `x` backing ranges, the store indices for `s` and for `m`, and the root-input indices from the activation (the build's typed products at a given scalar type).
tag: F

old: The names and the face chains come from `Structure` (the structure step's product, the components, wires, faces and tiers), never from an activation, since no activation fixes them (§9.1, D-253).
new: The face chains come from `Structure` (the structure step's product, the components, wires, faces and tiers), never from an activation's typing; the names a declaration evaluates to are the same at every activation (§9.1, D-253).
tag: R
ruling: R9
note: F13, its first proposed wording.

old: A valid list compiles to a plan.
new: A valid list of condition entries compiles two ways (§14.4).
tag: R
ruling: R27
newcites: §14.4
note: F16 for row 105, in the pointer form R27 rules; §14.4 (unit B) states both plans.

old: Per leaf, the plan holds a lens (the compiled navigation step of a condition entry), a destination offset, and a converter.
new: The specialized `apply!`'s plan holds, per leaf, a lens (the compiled navigation step of a condition entry), a destination and a converter.
tag: R
ruling: R27
note: F16's wording. R37 makes §14.3 the one home of both plans' contents and adds the dynamic walk's sentence, the added block below.

added: The dynamic walk's plan holds the converted values themselves.

old: The lens is the position tuple lifted to a type parameter, so navigation of the fixed tree type is type-stable.
tag: F

old: Rule. The converter is baked now, selected per leaf from that leaf's type in the resolved shape.
new: The converter is baked now, selected per leaf from that leaf's type in the resolved shape (D-065, D-148).
tag: C
newcites: D-065 D-148
note: the Rule. label goes. R7 bold headline for D-148's Position, "selected per leaf, keyed by that leaf's type in the resolved condition shape", and for D-065's "converters and `m`/`z` overlay bases baked at compile". D-148 was cited nowhere in the spec.

old: Why. Leaf types are shape facts, carried by the tree type along with the full nesting and every field name (§14.4).
new: Leaf types are shape facts, carried by the tree type along with the full nesting and every field name (§14.4).
tag: F
note: the Why. label goes; the reason follows its rule. D-148 Rationale, "Leaf types are shape facts".

old: Selection therefore consults no runtime fact and stays a resolution-time bake.
tag: F

old: There are two cases.
tag: F

old: | leaf in the resolved shape | converter baked | |---|---| | already at the activation's scalar type — decision-descended | the type's ordinary `convert`/constructor methods at that eltype | | a plain `Float64` leaf against a non-nominal activation's scratch — a held constant | the `Float64 → Dual` zero-partial embedding |
new: | leaf in the resolved shape | converter baked | |---|---| | already at the activation's scalar type, decision-descended | the type's ordinary `convert`/constructor methods at that eltype | | a plain `Float64` leaf against a non-nominal activation's scratch, a held constant | the `Float64 → Dual` zero-partial embedding |
tag: R
ruling: R16
note: the table; its em dashes go, as the brief's unit A list orders.

old: A leaf already at the activation's scalar type is decision-descended.
tag: F
note: the bold case opener goes plain.

old: Under a `Dual`-seeded evaluation of a type-stable `trim_condition(d)`, every decision-dependent leaf is `Dual`-typed in the shape (§14.7).
new: Under a `Dual`-seeded evaluation of a type-stable `trim_condition(d)`, every decision-descended leaf is `Dual`-typed in the shape (§14.7).
tag: F
note: Step 5 fix1: P1-13.

old: Such a leaf takes the type's ordinary `convert`/constructor methods at that eltype.
tag: F

old: An authored `RQuat` of `Dual`s becomes the `SVector{4}` state leaf at `Dual`, with the partials flowing through untouched.
new: An authored `RQuat` (FlightPhysics' rotation quaternion) of `Dual`s becomes the `SVector{4}` state leaf at `Dual`, with the partials flowing through untouched.
tag: R
ruling: R12
note: checked in `~/.julia/dev/Flight.jl/lib/FlightPhysics/src/attitude.jl` 66 (`struct RQuat <: Abstract3DRotation`).

old: That untouched flow of partials is what makes the seeded decisions reach the sweep at all.
tag: F

old: At the nominal activation the same rule is the ordinary `Float64` conversion.
new: At the nominal activation (the `Float64` one), the same rule is the ordinary `Float64` conversion.
tag: F
note: nominal takes its first-use link (#g-nominal). Step 5 fix1: P1-35.

old: An authored `RQuat` value becomes the `SVector{4}` state leaf it initializes.
tag: F

old: A plain `Float64` leaf against a non-nominal activation's scratch is a held constant, and it takes the `Float64 → Dual` zero-partial embedding.
new: A plain `Float64` leaf against a non-nominal activation's scratch (mutable working storage whose contents are never authoritative) is a held constant, and it takes the `Float64 → Dual` zero-partial embedding.
tag: F
note: the bold case opener goes plain; scratch takes its first-use link (#g-scratch). Step 5 fix1: P1-35.

old: That embedding is semantically exact in that case, and in no other.
tag: F

old: "Held at the operating point" is zero partials.
tag: F

old: Zero partials are the whole of a linearization operating-point condition, which is authored decision-free (§14.10).
tag: F

old: The selection is a one-time boundary decision, and it leaves the nominal exact-match doctrine for table cells (§9.5) untouched.
new: The selection is a one-time resolution decision, and it leaves the nominal exact-match doctrine for table cells (§9.5) untouched.
tag: R
ruling: R9
note: F17, boundary reserved.

old: Converters run here, on the write path.
tag: F

old: They never run on state views (§7.1).
new: They never run on state views (§7.1, D-148).
tag: C
newcites: §7.1 D-148
note: D-148 Rationale, "converters still run only on the write paths, never on state views". Rationale-only.

old: Overlay partiality for the `s` and `m` stores is baked the same way.
new: Overlay partiality for the `s` and `m` stores is baked the same way (D-065).
tag: C
newcites: D-065
note: D-065 Position, "converters and `m`/`z` overlay bases baked at compile".

old: The writer holds `merge(init_m_defaults, overlay)`, with the base resolved at compile time (the overlay-base rule, §14.1).
new: Each `s` or `m` store's write is one whole value, `merge(defaults, overlay)`, with the store's declared defaults resolved at compile time under the overlay-base rule (§14.1).
tag: R
ruling: R9
note: F15; `src/conditions.jl` 316-324, 600-620. The citation left the parentheses.

added: A condition is the value an author writes to say which state a build starts from.


added: In the block, `α_filt` and `β_filt` are the aerodynamics' filtered airflow angles, set to the angle of attack `α_a` and the sideslip `β_a`.

added: and `override`, the ordered, asymmetric layering combinator, builds a fourth node type (§14.6).

added: Resolution turns a composed condition (the path-addressed sparse overlay that sets a build's state) into plans the services can apply.

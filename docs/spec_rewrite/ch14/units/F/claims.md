# Unit F (§14.7, §14.8 to the end of "Scratch stores"): claims

old: ### 14.7 The trim problem: NamedTuple decisions, declared reads, named residuals
tag: F

old: The aircraft author ships one value.
tag: X

old: It says what the solver may vary, what those decisions make of the model, what to read back after each evaluation, and which equations the readings must satisfy.
tag: X

added: That value is a `TrimProblem`.
# first-use link for TrimProblem in §14.7 (F67); the glossary's own name for the value

added: This section gives its fields, then its decisions and parameters, its reads, its residuals and checks, the formulation it encodes and its recorded extensions.
# R8: the parts sentence for the six new #### labels

added: #### The fields
# R8 label

old: Rule.
new: The field set is normative and closed (D-118, D-262).
tag: R
ruling: R7
newcites: D-118 D-262
note: the Rule. label goes (brief_common); D-118 Position "The TrimProblem field set closes at seven"; D-262 adds checks and check_tolerances, hence both cited

old: The field set is normative.
new: The field set is normative and closed (D-118, D-262).
tag: R
ruling: R7
newcites: D-118 D-262
note: bold headline clause of D-118's first ruling, with its citation

old: The lift (§14.9) is field-by-field, so this list is closed.
new: It is closed because the lift (§14.9) is field-by-field.
tag: F
note: the causal link kept in its direction, the lift's field-by-field shape being the reason for closure

old: - `guess`, `lower` and `upper` are same-named all-`Float64` NamedTuples.
new: - `guess`, `lower` and `upper` are same-named all-`Float64` NamedTuples (D-069).
tag: R
ruling: R7
newcites: D-069
note: D-069 bullet 1's first ruling ("Decisions, guess and bounds are same-shaped all-Float64 NamedTuples"), bold at its first statement in reading order; the "Decisions and parameters" restatement stays plain (H52)

old: - `condition` is the condition-valued function over decisions.
new: - `condition` is the function over decisions whose value is a condition (the path-addressed sparse overlay that sets a build's state).
tag: F
note: condition linked at its first use in §14.7 with the gloss table's class-A gloss (F67)

old: - `reads` is the declared read set.
tag: F

old: - `residuals` is the residual function.
tag: F

old: - `tolerances` is an all-`Float64` NamedTuple, same-named as the residual function's return.
tag: F

old: - `checks` is the check function, and `check_tolerances` an all-`Float64` NamedTuple same-named as its return.
tag: F

old: Both default to empty.
tag: F

old: `tolerances` is carried in the problem because a relocated problem must carry its own convergence test.
tag: F

old: `at` passes it through untouched.
new: `at` (the scoping combinator storing a path prefix beside a node) passes it through untouched (D-118).
tag: C
newcites: D-118
note: at linked and glossed at its first use (F67); D-118 Position "carried in the problem because a relocated problem must carry its own convergence test (at's lift gains it as a path-free pass-through)"

old: Worked, the C172 cruise case reduces to its three-equation core.
new: The problem below is worked (spelled in full against a concrete case). It is the cruise case of Flight.jl's Cessna 172 model (`c172.jl`), reduced to its three-equation core.
tag: R
ruling: R12
note: owner named; checked ~/.julia/dev/Flight.jl/lib/FlightApps/src/c172/c172.jl (the Cessna172 model, its TrimState{7} and trim routine); step 5 P2-2: recast for grammar, worked glossed after the glossary's #g-worked

old: The real problem is the same shape with the full 7-variable search, and the θ-constraint elimination survives inside `trim_condition`.
new: The real problem is the same shape with the full 7-variable search, and the θ-constraint elimination survives inside its condition function, which the worked problem calls `trim_condition`.
tag: F
note: verify (C-017): the real problem's elimination lives in its own condition function, and `trim_condition` is the worked problem's name for it; trim_condition exists nowhere in Flight.jl. TrimState <: AbstractTrimState{7} in c172.jl has seven fields

old: `cruise = TrimProblem( guess = (throttle = 0.6, elevator = -0.05, α = 0.06), lower = (throttle = 0.0, elevator = -1.0, α = -0.1), upper = (throttle = 1.0, elevator = 1.0, α = 0.3), condition = d -> trim_condition(ac, params, d), #params closed over (§14.2) reads = reads(v̇_b = get_deriv("vehicle/dynamics", :v_eb_b), ω̇_b = get_deriv("vehicle/dynamics", :ω_eb_b), EAS = get_output("vehicle/airdata", :EAS)), residuals = (r, d) -> (axial_force = r.v̇_b[1], normal_force = r.v̇_b[3], pitch_moment = r.ω̇_b[2]), tolerances = (axial_force = 1e-3, normal_force = 1e-3, pitch_moment = 1e-4), checks = (r, d) -> (EAS = r.EAS - params.EAS,), # read back after the commit check_tolerances = (EAS = 0.1,))`
tag: F
note: the cruise problem, verbatim

old: The rest of the section takes what the author ships one piece at a time, against today's `c172.jl`.
new: The rest of the section takes what the author ships one piece at a time, against Flight.jl's `c172.jl`.
tag: R
ruling: R12
note: "today's" becomes "Flight.jl's"; c172.jl is lib/FlightApps/src/c172/c172.jl

added: #### Decisions and parameters
# R8 label

old: - Decision variables, initial guess and box bounds are plain, same-named, all-`Float64` NamedTuples.
new: `guess`, `lower` and `upper` are same-named all-`Float64` NamedTuples (D-069).
tag: M
ruling: R8
note: the bullet becomes the paragraph's topic sentence; its bold goes, D-069 bullet 1 being bold at the field list (H52, R7); step 5 P2-1: the sentence doubled the field-list bullet and is dropped; the bullet carries it, and the decisions themselves are the decision NamedTuple of 'Residuals and checks', guess-shaped
newcites: D-069

old: The `AbstractTrimState{N}`/`FieldVector` supertype dies.
new: FlightPhysics' decision-variable supertype, `AbstractTrimState{N}`, is dropped.
tag: R
ruling: R12
note: owner named; checked ~/.julia/dev/Flight.jl/lib/FlightPhysics/src/aircraftbase.jl line 92, `const AbstractTrimState{N} = FieldVector{N, Float64}`; "decision-variable supertype" is D-069 Rejected's own term; "dies" becomes "is dropped"

added: It is an alias of StaticArrays' `FieldVector{N, Float64}`.
# R12: the old slash spelling `AbstractTrimState{N}`/`FieldVector` named the alias; aircraftbase.jl line 3 `using StaticArrays`, line 92 the alias

old: Its only job was vectorization, and vectorization is the service's.
new: Its only job was vectorization, and vectorization is the service's (D-069).
tag: C
newcites: D-069
note: D-069 Rejected, "Framework decision-variable supertype (AbstractTrimState/FieldVector): vocabulary whose only job was vectorization"

old: The service packs and unpacks by field order, and that order is the `guess` NamedTuple's own.
tag: F
note: D-151 cited in the next sentence, same paragraph

old: §9.5 states the rule this seam runs on: the names are the pairing, order carries no semantics.
new: This seam runs on the rule §9.5 states, "the names are the pairing, order carries no semantics" (D-151).
tag: R
ruling: R7
newcites: §9.5 D-151
note: bold goes plain with D-151 (H72, bold at §9.5); the mid-sentence colon goes; the term of art quoted verbatim

old: `lower` and `upper` are checked at setup for key-set equality with `guess` and for `Float64` fields.
tag: F

old: They are then canonicalized to `guess`'s field order by the same type-level reorder (`NamedTuple{keys(guess)}(lower)`).
tag: F

old: A permuted bound spelling is therefore a non-event, rather than `α`'s bound silently applied to `throttle`.
tag: F

old: A key-set or field-type mismatch is `TrimProblemInvalid`.
tag: F

old: Guess, bounds and the returned solution share one spelling, and `Base.merge(guess, (throttle = 0.3,))` is free warm-start tweaking.
tag: F

old: An author who wants a documented `@kwdef` struct keeps it privately and converts.
tag: F

added: `TrimParameters` is the struct in Flight.jl's `c172.jl` that holds a trim's targets and settings.
# R12: checked ~/.julia/dev/Flight.jl/lib/FlightApps/src/c172/c172.jl line 806, `@kwdef struct TrimParameters` with EAS, γ_wb_n, ψ_nb, flaps, mixture, fuel_load, payload

old: - `TrimParameters` stays a plain user struct the framework never sees.
new: `TrimParameters` stays a plain user struct the framework never sees (D-069, D-118).
tag: R
ruling: R7
newcites: D-069 D-118
note: D-069 bullet 1's second ruling ("TrimParameters is a plain user struct"), bold on its headline clause; D-118 Position "TrimParameters stays framework-invisible"

old: The assignment is the pure `trim_condition(ac, params, d)` fragment-tree function (§14.2), applied per iteration by the compiled plan (§14.4).
tag: F
note: fragment linked at its first use (F67)

added: #### Reads
# R8 label

old: - The read side is declared, then compiled.
new: The read side is declared, then compiled (D-069).
tag: R
ruling: R7
newcites: D-069
note: D-069 bullet 2 ("Assignment is the pure trim_condition fragment function, and reads are declared via … selectors compiled to a stack NamedTuple reader") is one ruling; bold on the reads clause, see rulings.md

old: The spelling is `reads(name = get_state(path, leaf) | get_deriv(path, leaf) | get_output(path, leaf) | get_input(leaf) | get_face(leaf), ...)`, the service read set (§14.4),
new: The spelling is `reads(name = get_state(path, leaf) | get_deriv(path, leaf) | get_output(path, leaf) | get_input(leaf) | get_face(leaf), ...)`, the service read set (§14.4, D-124).
tag: R
ruling: R39
newcites: §14.4 D-124
note: R39: bold on the headline clause; D-124's Position is a ruling of its own, §14.7 its home, and no section of the frozen spec bolds it. D-124 Position, "§14.7's reads grammar widens to the full service set (D-095's four plus D-125's get_face) with per-selector validation targets"

old: each `leaf` a leaf address (the field name with dotted and bracketed steps below it).
new: Each `leaf` is a leaf address (the field name with dotted and bracketed steps below it).
tag: F

old: `get_state` and `get_deriv` address a declared state field and its derivative (validated against `x_init`/`s_init`).
tag: F

old: `get_output` addresses a declared output port (validated against `y_types`).
tag: F

old: `get_input` and `get_face` address a root input face and an output face
tag: F
note: root input linked at its first use in §14.7 (F67)

old: (validated against the root face lists).
new: (validated against the faces of the level the read set is mounted at, the root's when unmounted) (D-277).
tag: R
ruling: R9
newcites: D-277
note: F69; D-277 bullets 2 and 3, "get_input(face) names an input face of the mount level", "get_face(name) names an output face of the mount level"; `_input_faces_at(structure, decls, mount)`, src/readers.jl 523

old: The path selectors (the closed family of deferred reads resolving against a source) reach any port the structure has (§13.3, D-414).
new: The path selectors (the closed family of deferred reads resolving against a source) reach any port or state field the structure has (§13.3, D-414).
tag: R
ruling: B13
note: B13, `get_state` and `get_deriv` reach a state field, not a port (U-rul F correction 3)

old: An equilibrium equation meant to survive substitution at a generic seam reads a face.
new: As authoring guidance, an equilibrium equation meant to survive substitution at a generic seam reads a face (D-414, D-125).
tag: R
ruling: R5
newcites: D-414 D-125
note: R5, the read paragraph speaks of guidance; D-414 bullet 4, "get_face remains the read for a consumer meant to outlive the build"; D-125 Position, "an equilibrium equation crossing a generic seam binds the curated face contract"

old: A value a component computes without declaring it is not addressable at all (§8.3, §14.4).
new: There is no selector for a value a component computes without declaring it, and there cannot be one, because only cells are addressable (§4.2, §8.3).
tag: M
where: units/B/old.md
note: R6, M55: §14.4 is the home of the undeclared-intermediate rule; §14.7 keeps a pointer, "finds no selector for it (§14.4)"

old: A trim evaluation needing one is a signal that the component should export it.
new: A trim evaluation needing a value a component computes without declaring it finds no selector for it (§14.4). That is a signal that the component should export it.
tag: R
ruling: R6
newcites: §14.4
note: M55: the pointer to §14.4 and the export remedy (H62); inbound spec 11683 "The component exports it (§14.7)" holds

old: A derivative wanted across a contract boundary takes the same remedy.
tag: F

old: Publish it as an ordinary output port computed in `y_direct` (the one-line binding of the fused idiom, §5.3, made contract).
new: Publish it as an ordinary output port computed in `y_direct`. That is the one-line binding of the fused idiom (§5.3), made contract.
tag: F
note: the citation leaves the gloss's parentheses (brief_common); the y_direct remedy stays (M55; D-125 Rationale, inbound log 4140)

old: That leaves `get_deriv` scoped to owned concrete subtrees.
new: By convention, then, `get_deriv` stays inside subtrees the problem's author owns (D-414).
tag: R
ruling: R9
newcites: D-414
note: F70 and R5: scoping becomes guidance (D-414 bullet 4, "The locality law … is authoring guidance, not a framework check"; D-125 annotation 2026-10-19, "the export doctrine as advice for that consumer"); F70's wording drops "concrete"

old: The compiled reader (the gather twin, §14.4) fills a stack-only NamedTuple per evaluation.
new: The compiled reader fills a stack-only NamedTuple per evaluation. It is the gather twin (§14.4).
tag: R
ruling: R6
note: R6 (H63): §14.4 is the gather twin's home, here a pointer; the citation leaves the gloss's parentheses; the stack-only clause is stated only here (D-069 bullet 2, "compiled to a stack NamedTuple reader")

added: #### Residuals and checks
# R8 label, with M51

old: - The user supplies a residual system, not a scalar cost.
new: The user supplies a residual system, not a scalar cost (D-069).
tag: R
ruling: R7
newcites: D-069
note: D-069 Position's headline, bold once here; the second bold (Nonlinear least squares … is the default) goes plain (H55)

old: It is authored as a NamedTuple of named equations
tag: F

old: and packed to the solver's vector by field order.
new: The service packs residuals and tolerances to the solver's vector by field order.
tag: M
note: M51 merges the packing paragraph (old "The service packs residuals and tolerances by field order") into the residual system's (H53)

old: The order here is `tolerances`' field order, the declared side again,
new: The order is `tolerances`' field order, the declared side again, canonical for the residuals.
tag: M
note: M51 merge (H53); step 5 P2-5: 'r-side' becomes 'residuals'

old: and the residual return is canonicalized to it.
new: Each residual return is reordered to it (`NamedTuple{keys(tolerances)}(r)`) before packing (D-151).
tag: M
newcites: D-151
note: M51 merge (H53): one statement for the old two; D-151 Position, "tolerances' for residuals (the residual return canonicalized to it before packing)"

added: The residual function that returns it has this signature.
# M51: the old label "The residual signature:" becomes a sentence introducing the block that moves up

old: - Checks are equations the service reports once, at the committed state, and never solves.
new: Checks are equations the service reports once, at the committed state, and never solves (D-262).
tag: R
ruling: R7
newcites: D-262
note: D-262 Position, "The service never solves them. It evaluates them once, at the committed state"; bold with its citation in the sentence (was adjacent)

old: `checks` has the residual function's signature, and `check_tolerances` pairs with its return as `tolerances` pairs with the residuals'.
tag: F
note: now follows the signature it names (M51)

old: The service gathers the checks after the commit, from the boundary-zero sweep, and reports them (§14.8).
new: The service gathers the checks after the commit, from the sweep of boundary zero (the initialization boundary, the ordinary macro-sequence with an empty integrate), and reports them (§14.8).
tag: F
note: boundary zero and sweep linked at their first use in §14.7, boundary zero with its class-A gloss, its colon made a comma (F67)

old: Setup observes their return's shape at the guess evaluation, as it observes the residuals' (§14.8).
tag: F

old: Their reads join the problem's one read set.
tag: F

old: Why.
new: The reason for the checks lies in analytic elimination.
tag: R
ruling: R7
note: the italic Why. label goes; a reason follows its rule with a plain connective (spec_style)

old: Under analytic elimination the condition math pins the airspeed and the flight-path angle from the targets and the atmosphere the user's `params` record holds, while the world measures against the atmosphere the baseline wrote.
new: Under it, the condition math pins the airspeed and the flight-path angle from the targets and the atmosphere the user's `params` record holds, while the world measures against the atmosphere the baseline wrote.
tag: F
note: baseline linked at its first use in §14.7 (F67)

old: If the two disagree, the residuals vanish at a true equilibrium that is not the requested point, and nothing in the residual system can tell (D-139).
tag: F

old: A check reading EAS from the world's airdata at the committed state and subtracting the requested value is where a world measurement meets the request, so any mismatch moves it.
new: A check reading EAS (equivalent airspeed) from the world's airdata at the committed state and subtracting the requested value is where a world measurement meets the request, so any mismatch moves it.
tag: F
note: EAS glossed at its first prose use, an aerospace term (spec_style, "Introduce every reader-cold name")

old: The checks stay out of the solve because they carry no information for it (D-262).
tag: F

added: #### The formulation
# R8 label

old: - The FlightCore formulation's core is correct and survives verbatim as user math.
new: Flight.jl's trim formulation is correct at its core and survives verbatim as user math (D-069).
tag: R
ruling: R23 B4
newcites: D-069
note: B4, the bold names Flight.jl, true of both owners: the 7-variable TrimState is c172.jl's (lib/FlightApps/src/c172/c172.jl 796), θ_constraint FlightPhysics'. R23, the owner the source shows: θ_constraint and AbstractTrimState are FlightPhysics' (lib/FlightPhysics/src/aircraftbase.jl 92, 110); FlightCore holds no trim code. R7, bold on the headline clause; D-069 bullet 4, "The analytic-elimination doctrine (θ_constraint, by-construction filter/actuator equilibria) is preserved verbatim as user math"

old: That core is analytic elimination:
new: That core is analytic elimination, namely
tag: F
note: the mid-sentence colon goes

old: `θ_constraint` substituting the pitch constraint, filter and actuator equilibria imposed by construction, and the minimal 7-variable search.
new: FlightPhysics' `θ_constraint` substituting the pitch constraint, filter and actuator equilibria imposed by construction, and the minimal 7-variable search over `c172.jl`'s `TrimState`.
tag: R
ruling: R39
note: R39 (R23): the search's owner is c172.jl's `TrimState <: AbstractTrimState{7}` (lib/FlightApps/src/c172/c172.jl 796). R12, owner named; checked ~/.julia/dev/Flight.jl/lib/FlightPhysics/src/aircraftbase.jl line 110, `function θ_constraint(; v_wb_b, γ_wb_n, φ_nb)`

old: - What changes is the numerics.
new: What changes is the numerics.
tag: R
ruling: R8
note: the bold lead-in goes plain, a topic sentence (q24's doubles list, row 543 framing)

old: Trim is a square root-find.
tag: F

old: FlightCore's derivative-free scalar minimization over $\|r\|^2$ against a hand-scaled absolute `stopval` was the rational choice only because Jacobians through the mutating `f_ode!` chain and the assignment math were out of reach (D-069).
new: The Cessna 172 model's derivative-free scalar minimization over $\|r\|^2$ against a hand-scaled absolute `stopval` was the rational choice only because Jacobians through FlightCore's mutating `f_ode!` chain and the assignment math were out of reach (D-069).
tag: R
ruling: R23
note: R23: the BOBYQA minimization and its stopval are Flight.jl's Cessna 172 model's (lib/FlightApps/src/c172/c172.jl 924–927), introduced earlier in §14.7 as "Flight.jl's Cessna 172 model (`c172.jl`)". R12 for f_ode!, which is FlightCore's: checked ~/.julia/dev/Flight.jl/lib/FlightCore/src/modeling.jl line 209, `function f_ode!(mdl::Model, args...)`; inbound log 5716 (D-150 Rejected) holds, this sentence stays

old: - Nonlinear least squares with exact AD Jacobians is the default.
new: The default is nonlinear least squares on $r(d)$ with exact AD Jacobians, in the trust-region/Levenberg–Marquardt family (§14.8, D-069).
tag: R
ruling: R7
newcites: §14.8 D-069
note: H55: D-069's headline is bold at the residual system; this restatement goes plain and merges with the next sentence of the same bullet, which states it with the family

old: The `Dual` activation seeds the decision variables through the `T`-generic assignment, sweep and `x_deriv`.
new: The `Dual` activation (the build's typed products at a given scalar type) seeds the decision variables through the `T`-generic assignment, sweep and `x_deriv`.
tag: F
note: activation glossed (class A); sweep's link moves to its first use in the checks paragraph (F67)

old: The seeds survive the condition write boundary because §14.3 selects the baked converter per leaf from the shape.
new: The seeds survive the condition write because a decision-descended leaf is `Dual`-typed in the shape and keeps its partials (§14.3, D-148).
tag: R
ruling: R6
newcites: §14.3 D-148
note: M54 (H64); F66, "write boundary" becomes "the condition write"; D-148 Position, "every decision-dependent leaf is Dual-typed in the shape (§14.7), which is what makes the seeded decisions reach the sweep at all"; the per-leaf selection itself is §14.3's

old: A decision-descended leaf is `Dual`-typed there
new: The seeds survive the condition write because a decision-descended leaf is `Dual`-typed in the shape and keeps its partials (§14.3, D-148).
tag: R
ruling: R6
newcites: §14.3 D-148
note: M54 keeps the Dual-typed clause, which spec 11533–11535 (§14.3) and log 5587 (D-148) cite

old: and takes the structural conversion, while the zero-partial embedding stays on the held `Float64` leaves.
new: A plain `Float64` leaf against a non-nominal activation's scratch is a held constant, and it takes the `Float64 → Dual` zero-partial embedding.
tag: M
where: units/A/old.md
note: M54: converter selection's home is §14.3 (R6); the structural conversion is §14.3's table row "already at the activation's scalar type — decision-descended | the type's ordinary convert/constructor methods at that eltype"

old: The default is nonlinear least squares on $r(d)$ with exact AD Jacobians, in the trust-region/Levenberg–Marquardt family (§14.8).
new: The default is nonlinear least squares on $r(d)$ with exact AD Jacobians, in the trust-region/Levenberg–Marquardt family (§14.8, D-069).
tag: C
newcites: §14.8 D-069
note: moved to the paragraph's head, carrying the merged topic sentence (H55); D-069 Position, "making trim a nonlinear least squares on r(d) with exact AD Jacobians"

old: Convergence is quadratic (~5–15 evaluations), the tolerances are per-residual and physical, and failure reports name the unbalanced equations with magnitudes.
tag: F

old: The convergence verdict itself is service-owned and backend-independent (§14.8).
tag: F

old: - Non-squareness degrades gracefully.
new: Non-squareness degrades gracefully (D-069).
tag: R
ruling: R7
newcites: D-069
note: D-069 bullet 3, "graceful non-squareness"; see rulings.md on the first-in-order test

old: Redundant actuation becomes weighted or minimum-norm least squares.
tag: F

old: Infeasible demands converge to a nonzero residual identifying the impossible balance.
tag: F

old: At the solution, $\partial r / \partial d$ is free flight-physics data (control effectiveness) that cross-checks linearization.
tag: F

old: - The derivative-free scalar path survives as the fallback.
new: The derivative-free scalar path would survive as the fallback, with Flight.jl's algorithm as its degenerate case (D-069).
tag: R
ruling: R21
note: R21: one bold on D-069 bullet 5's headline clause, in the conditional (R10). D-070's NLoptBackend clause stays plain: it is part of D-070's one-sentence Position after its colon, an elaboration of the LM-default ruling already bold, not a ruling of its own. R10, the design in the conditional; R6/M53, the survival clause kept with a pointer; D-069 bullet 5, "The derivative-free scalar fallback is the service squaring the residuals, today's BOBYQA as the degenerate case".
newcites: D-069

old: The service squares and normalizes the residuals against the tolerances, minimizing $\sum (r_i/\mathit{tol}_i)^2$ at `stopval = 1` (§14.8).
new: §14.8 gives the normalization of the residuals against the tolerances that would repair the hand-scaled absolute threshold.
tag: M
newcites: §14.8
note: R6/M53 (H51): §14.8's tolerance translation is the home, where "the service would square and normalize" and the objective at stopval = 1 stand

old: That normalization is where the hand-scaled absolute threshold is repaired.
new: §14.8 gives the normalization of the residuals against the tolerances that would repair the hand-scaled absolute threshold.
tag: R
ruling: R10
newcites: §14.8
note: M53 pointer, in the conditional (R10)

old: It leaves today's algorithm as the degenerate case.
new: The derivative-free scalar path would survive as the fallback, with Flight.jl's algorithm as its degenerate case (D-069).
tag: R
ruling: R12
newcites: D-069
note: "today's" becomes "Flight.jl's": the BOBYQA trim is ~/.julia/dev/Flight.jl/lib/FlightApps/src/c172/c172.jl line 924, `Opt(:LN_BOBYQA, …)`; merged into the survival clause (M53)

added: #### Recorded extensions
# R8 label

old: - Two problems are recorded, not built (a worked-out extension deliberately left unimplemented, its seams named).
new: Two problems are recorded, not built (a worked-out extension deliberately left unimplemented, its seams named) (D-069).
tag: R
ruling: R7
newcites: D-069
note: D-069 bullet 6, "Recorded unbuilt: closed-loop trim … and ground static equilibrium as another problem value"

old: They are closed-loop sampled-data trim and on-ground static equilibrium, each simply another problem value over the same service.
tag: F

old: Closed-loop trim appends $g(s) - s = 0$ residuals via a nondestructive scratch evaluation of `s_update`, which was structurally impossible under FlightCore's mutating `f_disc!`.
new: Closed-loop trim appends `s_update(s) - s = 0` residuals via a nondestructive scratch evaluation of `s_update`, which was structurally impossible under FlightCore's mutating `f_periodic!`.
tag: R
ruling: R22
note: R22: f_disc! became f_periodic! (Flight.jl commit 30a5942c; lib/FlightCore/src/modeling.jl 219). R12: g becomes s_update; scratch linked at its first use in §14.7.

old: On-ground static equilibrium solves strut compressions and attitude against gear forces.
tag: F

old: The residual signature:
new: The residual function that returns it has this signature.
tag: M
note: M51; the mid-sentence colon goes

old: `residuals(reads::NamedTuple, d::NamedTuple) → NamedTuple`
tag: M
note: M51, verbatim, moved up after the residual system

old: Rule.
new: What the solver varies is passed, and what is fixed per problem is closed over (D-118).
tag: R
ruling: R7
newcites: D-118
note: the second Rule. label goes; the ruling is bold on its headline clause

old: What the solver varies is passed. What is fixed per problem is closed over.
new: What the solver varies is passed, and what is fixed per problem is closed over (D-118).
tag: R
ruling: R7
newcites: D-118
note: M51 moves it; D-118 Position, "under one rule: what the solver varies is passed (d cannot be closed over), what is fixed per problem is closed over"; term of art kept, two clauses joined into one bold

old: The gathered reads and the decision NamedTuple arrive as arguments.
tag: M
note: M51

old: `d` is the one value that cannot be closed over.
tag: M
note: M51

old: `TrimParameters` stays behind the closure, exactly as `condition` already holds it, and the framework never sees it.
new: `TrimParameters` stays behind the closure, exactly as `condition` already holds it.
tag: M
note: M51; step 5 P2-3: 'and the framework never sees it' dropped as the double of the bold in 'Decisions and parameters' (TrimParameters stays a plain user struct the framework never sees)

old: Being user-shaped, that record is also where any environment handles the condition math needs conventionally ride
new: Being user-shaped, that record is also where any environment handles the condition math needs conventionally ride.
tag: M
note: M51

old: (the value-level constructor, §8.2; the pre-sweep doctrine, §14.1).
new: §8.2 gives the value-level constructor that builds such a handle, a plain exported function of the component and its input values. §14.1 gives the pre-sweep doctrine.
tag: M
note: M51; the two pointers say what each section provides (spec_style, no possessive citations); value-level constructor glossed with the gloss table's class-A gloss, citations kept outside the gloss's parentheses; step 5 P2-4: the gloss becomes an appositive after 'such a handle'

old: The problem receives the environment, and never writes it (§14.9).
tag: M
note: M51; H56, §14.9 the home, here the pointer it already was

old: The returned NamedTuple's names are the equation names the report and the failure messages use.
new: The returned NamedTuple's names are the equation names the report and the failure messages use (D-118).
tag: R
ruling: R39
newcites: D-118
note: R39: bold on the headline clause; D-118 Position's third sentence, its own ruling before the semicolon, §14.7 its home, bold nowhere in the frozen spec. M51; D-118 Position, "Returned names are the report's equation names"

old: The service packs residuals and tolerances by field order.
new: The service packs residuals and tolerances to the solver's vector by field order.
tag: M
note: M51 merge (H53)

old: `tolerances`' order is canonical for the r-side,
new: The order is `tolerances`' field order, the declared side again, canonical for the residuals.
tag: M
note: M51 merge (H53); step 5 P2-5

old: and each residual return is reordered to it (`NamedTuple{keys(tolerances)}(r)`) before packing.
new: Each residual return is reordered to it (`NamedTuple{keys(tolerances)}(r)`) before packing (D-151).
tag: M
newcites: D-151
note: M51 merge (H53); D-151 Position

old: An equation list spelled in a different order inside the lambda therefore pairs correctly and costs nothing.
tag: M
note: M51

old: The decisions rule holds symmetrically on both ends of the seam.
tag: M
note: M51 places it after the packing it concludes

old: Names pair, and order never does.
tag: M
note: M51

old: Names and types are checked at setup, because the guess evaluation the service performs anyway observes the residual key set.
tag: M
note: M51

old: A `tolerances` key-set mismatch, or any field-type disagreement on either side of the seam, is `TrimProblemInvalid` (Appendix C), with the offending field and the names or types in hand.
tag: M
note: M51

old: Order is never a mismatch.
tag: M
note: M51


old: ### 14.8 The trim service: solver seam, scratch stores, commit and report
tag: F

old: A `TrimProblem` is an inert value until a service runs it.
tag: X
note: TrimProblem linked at its first use in §14.8, as the brief assigns (F67)

old: `trim!` is that service.
tag: X

old: It drives a solver it holds behind one method, works on scratch stores of its own, commits a converged solution the way `init!` would, and returns a report.
new: It drives a solver it holds behind one method, works on its own scratch stores (mutable working storage whose contents are never authoritative), commits a converged solution the way `init!` would, and returns a report.
tag: X
note: scratch linked at its first use in §14.8 with the glossary's own words (F67); its late link at the two-halves sentence goes

old: #### The backend seam
tag: F

old: The signature is `trim!(model, problem; baseline, t0 = 0.0, backend = LevenbergMarquardt())`, where `model` is a `Model` (a deployment materialized at one scalar type) at `Float64` (D-319).
tag: F
note: the signature stays here, its home (R6); t0's home is §14.5

added: A `Model` at another scalar is refused as `ArgumentInvalid` with reason `:non_nominal` (D-319).
# R14, F71: D-319 bullet, "trim! and linearize on a Model{T} at any T other than Float64 throw ArgumentInvalid with reason :non_nominal"; src/trim.jl 458–459

added: A `Model` that a simulation has claimed is refused before any check, as `ArgumentInvalid` with reason `:claimed`, since the call commits (D-318, D-319).
# verify (V107): D-318 Position, "A model already claimed is refused as ArgumentInvalid with reason :claimed"; R14, F71: D-319 bullet 5, "trim! takes the claim's gate before any check, since it commits"; src/trim.jl 448 and src/model.jl 148–150 (`_claimed_gate`, reason :claimed)

added: The `baseline` keyword takes a baseline (a full-coverage condition, such as an aircraft-shipped function returns).
# F67: the brief assigns baseline's §14.8 link to unit F at 12065, which sits inside the signature's code span; the glossary: "an aircraft-shipped, full-coverage condition function … It is also the baseline keyword init!/trim! take"

old: `trim!(sim, problem; …)` gates on the simulation's lifecycle and commits through the simulation's `init!`.
tag: F
note: D-319 cited in the same paragraph, as before

old: The default backend is an in-house dense Levenberg–Marquardt.
new: The default backend is an in-house dense Levenberg–Marquardt (D-070).
tag: R
ruling: R7
newcites: D-070
note: D-070 Position, "The trim service defaults to an in-house dense LM solver behind a value-passed backend contract"; bold on its headline clause; starts its own paragraph, the rest of the old paragraph its reason

old: For decision dimensions ~10 with exact Jacobians, the core is ~100 lines: a damping loop, a small linear solve, a convergence test.
new: For decision dimensions ~10 with exact Jacobians, the core is ~100 lines, namely a damping loop, a small linear solve and a convergence test.
tag: F
note: the mid-sentence colon goes; counts kept

old: That is the §10.2 stepper precedent exactly, a tiny needed core against a heavy dependency.
tag: F

old: The per-residual physical tolerances sharpen the case (§14.7).
tag: F

old: They are a convergence test no external package spells natively.
tag: F

old: That is precisely why the service, not the backend, applies it.
tag: F

old: The backend contract is a pinned signature, value-passed, with one required method per backend.
new: The backend seam is a pinned signature, value-passed, with one required method per backend (D-158).
tag: R
ruling: R9
newcites: D-158
note: F66, "contract" becomes "seam"; R7, D-158 Position "The backend seam is a pinned signature, not prose", bold on its headline clause with D-158 in the sentence (was adjacent, 12103); seam linked here, its first use in §14.8

old: That one method is the seam.
tag: F

old: `solve(backend, eval!, d0, lower, upper, tol) -> (; d, status, n_evaluations, n_iterations)`
tag: F
note: the seam signature, verbatim

old: `eval!(r, J, d)` is in-place and always fills `r`, the residual vector packed in `tolerances`' field order.
tag: F

old: It fills `J` iff `J !== nothing`.
new: It fills `J` exactly when `J !== nothing`.
tag: R
ruling: R7
note: the bold on "iff J !== nothing" goes plain, one ruling with the pinned signature (q24); step 5 P2-9: 'iff' in plain words

old: The Jacobian is requested by argument, so a Jacobian-free backend simply always passes `nothing`, and there is still exactly one evaluation method to implement.
tag: F

old: `d0`, `lower` and `upper` are packed `Vector{Float64}` in `guess`'s field order, with `±Inf` meaning unbounded.
tag: F

old: The declared side is canonical on both ends, and the service has canonicalized before packing (§14.7).
tag: F

old: A backend that ignores bounds therefore ignores two vectors, not a missing argument.
tag: F

old: `tol` is a `Vector{Float64}` in `tolerances`' field order.
tag: F

old: It is data the backend may stop on, under the service's per-backend-family translation below, and it is decisive of nothing.
tag: F

old: The return holds `d`, the solution, `status::Symbol`
tag: F

old: from a deliberately open set,
new: The status set is deliberately open,
tag: R
ruling: R7
note: D-158 Position, "status::Symbol a deliberately open set recorded verbatim"; the bold word "open" becomes a headline clause, bold, with D-158 in its sentence

old: and the diagnostic counts `n_evaluations` and `n_iterations`.
tag: F

old: The status is recorded verbatim in the report because the verdict is the service's (D-158).
new: and the status is recorded verbatim in the report because the verdict is the service's (D-158).
tag: F

old: The name `solve` is subject to the exported-name audit (`pending.md`) like every other API spelling.
tag: F

old: The backend sees vectors and never names, so the solution it returns unpacks by the same order it was given.
new: The backend sees vectors and never names, so the solution it returns unpacks by the same order it was given (D-151).
tag: C
newcites: D-151
note: D-151 Position, "guess's field order for decisions/bounds (and it is the solver-vector packing order …)"

old: #### The convergence verdict is the service's, uniformly
new: The convergence verdict is the service's, uniformly (D-150).
tag: R
ruling: R8
newcites: D-150
note: M56: the claim-shaped label becomes a topic label and its claim the paragraph's topic sentence; R7, D-150 Position bold "The convergence verdict is the service's, uniformly and backend-independently", here on its headline clause

added: #### The convergence verdict
# R8, M56 label

old: `converged` means `all(abs.(rᵢ) .≤ tolᵢ)`.
tag: F

old: That is the per-residual box test (§14.7) in its own physical units, evaluated by the service at the backend's returned point.
tag: R
ruling: R7
note: the bold on "by the service at the backend's returned point" goes plain, one ruling with the verdict (D-150 Position)

old: It is one residual evaluation, noise against the solve that produced it.
tag: F

old: That verdict, and nothing else, gates the commit and fills `TrimReport.converged`.
tag: F

old: The backend's returned `status` is recorded in the report as diagnostic data, and it is authoritative over nothing.
tag: F

old: #### The tolerance translation, per backend family
new: #### The tolerance translation
tag: R
ruling: R8
note: M56; "per backend family" is carried by the next sentence

old: The tolerance translation is the service's too, per backend family.
new: The tolerance translation is the service's too, per backend family (D-150).
tag: C
newcites: D-150
note: D-150 Rationale, bold "The tolerance translation into each backend's stopping language is the service's too"; Rationale-only, see rulings.md

old: In least-squares backends the tolerances are the stopping criterion.
tag: F

old: They feed the per-residual test directly, so LM's damping loop tests exactly what the service will re-test.
new: They feed the per-residual test directly, so the damping loop of Levenberg–Marquardt (LM) tests exactly what the service will re-test.
tag: F
note: step 5 P2-9: LM introduced at its first use in §14.8

added: The derivative-free fallback is designed and not yet built, and `pending.md` lists it (D-070).
# R10, the one status sentence; pending.md 158–160 lists "The NLopt fallback"; D-070 Position rules the design

old: The derivative-free scalar fallback is `NLoptBackend(:LN_BOBYQA)` in a package extension.
new: In the design it is `NLoptBackend(:LN_BOBYQA)` in a package extension.
tag: R
ruling: R10
note: F51; "scalar" is carried by §14.7's survival clause, "the derivative-free scalar path would survive as the fallback"

old: It passes `nothing` for the Jacobian, keeps today's algorithm one keyword away, and leaves the framework core carrying zero optimizer dependencies.
new: It would pass `nothing` for the Jacobian, keep Flight.jl's algorithm one keyword away, and leave the framework core carrying zero optimizer dependencies.
tag: R
ruling: R10
note: R10 conditional; R12, "today's" becomes "Flight.jl's": ~/.julia/dev/Flight.jl/lib/FlightApps/src/c172/c172.jl line 924, `Opt(:LN_BOBYQA, length(x0))`

old: For that fallback the service squares and normalizes.
new: For that fallback the service would square and normalize.
tag: R
ruling: R10

old: The objective minimized is $\sum_i (r_i/\mathit{tol}_i)^2$ with `stopval = 1`.
new: The objective minimized would be $\sum_i (r_i/\mathit{tol}_i)^2$ with `stopval = 1`.
tag: R
ruling: R10

old: That objective is dimensionless where FlightCore's threshold was hand-scaled and absolute (§14.7).
new: That objective is dimensionless where the threshold in Flight.jl's Cessna 172 model (`c172.jl`) was hand-scaled and absolute (§14.7).
tag: R
ruling: R23
note: R23: `opt.stopval = 1e-16` in lib/FlightApps/src/c172/c172.jl 927; owner introduced at its first use in §14.8; a fact about the objective, present tense kept; inbound spec 12129's reliance on §14.7 holds (row 543 stays)

old: It is a well-scaled valley where a raw $\|r\|^2$ sums forces against moments.
tag: F

old: The two criteria cannot disagree in the dangerous direction:
new: The two criteria cannot disagree in the dangerous direction, because of this implication (D-150).
tag: C
newcites: D-150
note: the colon before the display goes; D-150 Rationale, "Soundness (inscribed sphere)", cited as an exempt comparative passage's entry (spec_style)

old: $$\sum_i (r_i/\mathit{tol}_i)^2 \le 1 \quad\Longrightarrow\quad (r_i/\mathit{tol}_i)^2 \le 1 \;\text{ for every } i$$
tag: F
note: the display, verbatim

old: so the `stopval` sphere is inscribed in the tolerance box, and a fallback stopping at `stopval` necessarily passes the service's box test.
new: The `stopval` sphere is therefore inscribed in the tolerance box, and a fallback stopping at `stopval` necessarily passes the service's box test.
tag: F
note: "so" becomes "therefore" after the display; the consequence keeps its direction

old: The converse disagreement, a backend stopping early and reporting an optimistic status, is caught by the re-check, which remains the single authority.
tag: F

old: What is not claimed is point identity.
tag: F

old: Different backends may land on different solutions, which is an algorithmic difference and a legitimate one.
tag: F

old: What is eliminated is per-backend meanings of `converged`.
tag: F

old: #### Box bounds and saturated decisions
tag: F

old: Box bounds are honored by step projection.
new: Box bounds are honored by step projection (D-070).
tag: R
ruling: R7
newcites: D-070
note: D-070 bullet 1, "Box bounds are applied by step projection, with saturated-at-solution flagged in the report"

old: A decision variable saturated at the solution is flagged in the report:
new: A decision variable saturated at the solution is listed in the report's saturated list,
tag: R
ruling: R9
note: F78: the report holds `saturated` as (name, :lower | :upper) pairs (src/trim.jl 138–139, `_saturated`)

old: "converged with `elevator` at its upper bound".
new: as `(:elevator, :upper)`.
tag: R
ruling: R9
note: F78: nothing prints that message

old: That is the classic CG-limit diagnostic, today inferable only from mysterious residuals.
new: That is the classic CG-limit diagnostic (CG is the center of gravity), which Flight.jl's trim leaves inferable only from mysterious residuals.
tag: R
ruling: R12
note: verify: CG glossed as a reader-cold aerospace term; "today" is Flight.jl's: c172.jl's trim returns (success, trim_state) with no saturation report (~/.julia/dev/Flight.jl/lib/FlightApps/src/c172/c172.jl 931–939)

old: #### Scratch stores, stated without type luck
new: #### Scratch stores
tag: R
ruling: R8
note: M56; "without type luck" is carried by "The Dual backend's buffers being un-aliasable by type is defense in depth, not the mechanism"

old: Every `trim!` invocation instantiates a fresh working store set.
tag: F

old: Each half of it (below) is a scratch `Model` of its own, materialized from the deployment the service was called on (D-317, D-319).
tag: F

old: The set holds the `x` backing, the `s` and `m` stores, the root input and signal tables, and the derivative buffer.
tag: F

old: The set is built from the activation's layout (the build's typed products at a given scalar type).
new: The set is built from the layout of the activation (the build's typed products at a given scalar type).
tag: F
note: step 5 P2-12: the gloss now follows activation

old: The layout is the reusable compiled artifact.
tag: F

old: The buffers are per-invocation and die with the call (stopped-sim allocation, §9.8).
tag: F

old: Each set also calls every workspace allocator once, at the activation's scalar (D-077).
new: Each set also calls every workspace (component-declared mutable scratch, arriving as `ws`) allocator once, at the activation's scalar (D-077).
tag: F
note: workspace glossed (class A in the gloss table; the table's "bundle field" avoided, bare bundle being reserved)

old: The `Dual` backend's buffers being un-aliasable by type is defense in depth, not the mechanism.
tag: F

old: A `Float64` backend (NLopt) gets equally fresh buffers.
new: A `Float64` backend, such as the designed NLopt fallback, would get equally fresh buffers.
tag: R
ruling: R10

old: The invariant is backend-independent.
tag: F

old: The simulation's authoritative stores have exactly one writer, the commit through boundary zero (the initialization boundary: the ordinary macro-sequence with an empty integrate).
new: The simulation's authoritative stores have exactly one writer, the commit through boundary zero (the initialization boundary, the ordinary macro-sequence with an empty integrate) (D-070).
tag: R
ruling: R7
newcites: D-070
note: D-070 bullet 2, "while authoritative stores have exactly one writer, the commit through boundary zero"; the bold shrinks to the headline clause and takes D-070; the gloss's colon becomes a comma

old: Setup applies `override(baseline, condition(guess))` to the scratch set once,
new: Setup applies `override(baseline, condition(guess))`, the problem's condition at the guess layered over the baseline by override, to the scratch set once.
tag: F
note: condition and override linked at their first prose use in §14.8 (F67); the added clause glosses the code span (glossary: override "the ordered, asymmetric layering combinator: the patch wins"), see the added block

added: the problem's condition at the guess layered over the baseline by override,
# F67: a prose site for the condition and override links, describing the code span beside it

old: and that application's full coverage is checked here.
new: That application's full coverage is checked here, as §14.6 requires (D-149).
tag: R
ruling: R6
newcites: §14.6 D-149
note: M58 wording; D-149 Position, "Slot totality is checked at every application that establishes a complete world over virgin stores — init!, trim setup, trim commit"

old: The check is the comparison of the resolved plan against the `Build`'s `input_faces` (§14.6), one plan-level comparison before the first evaluation.
new: Each compares the resolved plan's root-input coverage against the `Build`'s `input_faces` before writing anything.
tag: M
where: units/B/old.md
note: R6, M58 (H65): §14.6 is the home of the plan-level comparison; its timing clause is §14.6's "The check is therefore one comparison, and it runs before any evaluation, not merely before any write."

old: Sweeps therefore see a complete world.
tag: F

old: Raw instantiation is sound exactly because of that check, since every root input is written before any read.
tag: F
note: kept (M58); inbound log 5655 (D-149 Rationale) holds

old: An incomplete `baseline` is one declaration-ordered `UninitializedInputs` at setup rather than a whole solve against undefined cells.
tag: F

old: The frozen cells are established, not probe-seeded.
new: The frozen cells are established, not probe-seeded (D-213).
tag: R
ruling: R7
newcites: D-213
note: D-213 Position's first ruling, bold with its citation in the sentence (was adjacent)

old: At the seeded activation the discrete tier is frozen (§9.4).
new: At the seeded activation the discrete tier (the discrete side of the hybrid formalism) is frozen (§9.4).
tag: F
note: step 5 P2-49: tier glossed after the glossary's #g-tier

old: Its stages never run there, so nothing at that activation can derive a discrete output cell from the authored `s`.
tag: F

old: Setup therefore instantiates the scratch set in two halves.
tag: F
note: scratch's late link goes; linked at the section's context (F67)

old: A nominal set takes the composite first, by the dynamic walk (§14.4), and runs one establishment round.
new: A nominal set (one at the `Float64` activation) takes the composite first, by the dynamic walk (§14.4), and runs one establishment round.
tag: F
note: nominal glossed (class A; the glossary's "the Float64 activation")

old: That round is boundary zero's sweep with every discrete output stage admitted, due or not (D-205), with no projection, no guards and no `s_update`.
new: That round is boundary zero's sweep with every discrete output stage admitted, due or not (D-205), with no projection (the per-component `x_projection` hook), no guards and no `s_update`.
tag: F
note: step 5 P2-49: projection glossed after the glossary's #g-projection

old: The seeded set is then written by the specialized `apply!`,
new: The seeded set is then written by the specialized `apply!`.
tag: F

old: and its frozen cells are copied from the nominal set as zero-partial constants (the embedding of §14.3).
new: Its frozen cells are copied from the nominal set, `Float64` values that a continuous consumer reads as zero-partial constants (§9.5).
tag: R
ruling: R9
newcites: §9.5
note: F55: `_establish_frozen!` (src/model.jl 97–114) copies values; the embedding happens at the consumer's read (§9.5, "The executor embeds a Float64 as a zero-partial constant")

old: Every cell the iterations read is thus derived from the authored world.
tag: F

old: A frozen cell holds what the authored discrete state publishes, which makes "held at the operating point" literal.
tag: F

old: No scratch cell holds the probe's synthesized values.
new: No scratch cell holds a synthesized probe value (a fabricated value a build-time probe runs on).
tag: F
note: step 5 P2-13: the link moves from #g-probe to #g-probe-value, glossed after the glossary

old: That is the §14.6 barrier reaching the scratch world, as D-205 made it reach the published one.
new: That is the probe-value barrier of §14.6 reaching the scratch world, as D-205 made it reach the published one.
tag: F
note: step 5 P2-13: named as §14.6 names it

old: The iterations are untouched.
new: The iterations are untouched (§14.5).
tag: F
note: step 5 P1-37: the pointer to the home of the raw iterations (R6)
newcites: §14.5

old: They are raw write → sweep → read cycles at the seeded activation, over the continuous chain and `x_deriv` alone (§14.5).
new: They run at the seeded activation, over the continuous chain and `x_deriv` alone.
tag: M
note: H66, kept with its pointer to §14.5 (R6); step 5 P1-37: 'raw write → sweep → read cycles' is held at its home in §14.5 (units/B/new.md, 'Optimizer iterations are raw write → sweep → read cycles on the activation'); the §14.5 pointer sits on the sentence before; 'at the seeded activation' stays, since §14.5 does not say it
newcites: §14.5

old: The zero-decision problem (below) is the nominal half alone,
new: The empty problem (below) is the nominal half alone (D-213).
tag: C
newcites: D-213
note: verify (V188): D-213 now sits on what it carries, Rationale "the zero-decision probe falls out as the nominal half alone"; step 5 P2-14: the name 'The report' gives it

old: and its one evaluation is that establishment round (D-213).
new: Its one evaluation is that establishment round, followed by one derivative evaluation for the reads.
tag: R
ruling: R9
newcites: D-213
note: verify (V188): D-213 moved to the previous sentence, the paragraph keeping it; F56's omission at this site: setup runs `nominal_exec.bodies.rhs()` after the establishment round and before the gather (src/trim.jl 484–486)

old: The commit applies the same composite over the same `baseline` (`override(baseline, condition(d))`, §14.9), so its coverage is setup's.
new: The commit (below) applies the same composite over the same `baseline`, so its coverage is setup's.
tag: F
newcites: none
note: step 5 P2-15: the expression and its §14.9 pointer give way to 'below', where 'The commit, in full' (units/G/new.md) states the expression; §14.9 states it too

old: Commit's totality check is therefore structurally unfailable through the trim path, and it stands as the shared `init!`-boundary defense.
new: Commit's totality check is therefore structurally unfailable through the trim path, and it stands as the shared `init!` defense (D-149).
tag: R
ruling: R9
newcites: D-149
note: F66, the boundary link and the word go; D-149 Rationale, "commit's totality check is structurally unfailable through the trim path — it remains as the shared init!-boundary defense"; Rationale-only, see rulings.md

old: A converged solve is always committable.
tag: F

old: `TrimReport` therefore carries no committed flag, and the no-throw doctrine needs no exception.
new: `TrimReport` therefore carries no committed flag, and the no-throw rule (below) needs no exception.
tag: F
note: D-149 Rationale and Rejected list; cited in the paragraph; step 5 P2-16: points to 'Non-convergence never throws' in 'The report'

old: Iterations rewrite the composite's write-set via the compiled plan.
tag: F

old: The write-set is `override(baseline, condition(d))`, the same tree setup resolved, so a store both layers touch merges exactly as it did at setup.
tag: F

old: An LM evaluation is one Dual-seeded sweep yielding `r` (value parts) and `J` (partials) together.
new: An LM evaluation is one Dual-seeded sweep yielding `r` from the value parts and `J` from the partials, together (D-069).
tag: C
newcites: D-069
note: two parentheticals become prepositions; D-069 Position, "nonlinear least squares on r(d) with exact AD Jacobians, the Dual activation seeded through the T-generic assignment math"

old: No convergence means no commit.
tag: F

old: Non-convergence is the service's box test failing at the returned point, whatever status the backend attached to it.
new: Non-convergence is the service's box test failing at the returned point, whatever status the backend attached to it (D-150).
tag: C
newcites: D-150
note: D-150 Position, "That verdict, and nothing else, gates the commit"

old: No commit means the sim is bit-for-bit untouched, including "never initialized".
tag: F

old: Today's warn-but-assign is structurally impossible.
new: Flight.jl's warn-but-assign, where the Cessna 172 trim warns on a failed optimization and assigns its result anyway, is structurally impossible.
tag: R
ruling: R12
note: ~/.julia/dev/Flight.jl/lib/FlightApps/src/c172/c172.jl 933–938, `@warn("Trimming optimization failed …")` then `AircraftBase.assign!` regardless; step 5 P2-17: the clause states what that code does, c172.jl 934-939

old: The same structure covers an interrupt.
tag: F

old: Ctrl-C during a long solve unwinds an ordinary Julia call operating on per-invocation scratch stores.
tag: F

old: No commit has happened, and the simulation is bit-for-bit untouched, exactly as a non-converged solve leaves it.
tag: F

old: The services need no counterpart to the loop's boundary masking (§12.4).
tag: F

added: An interrupt inside the commit's boundary zero moves the simulation to `built` and propagates raw (§13.4, D-223).
# R9, F62: D-223 bullet 4, "An interrupt inside boundary zero moves the lifecycle to built and propagates raw; a service has no stop path"; bullet 3, "trim!'s commit inherits the rule, being an init!"

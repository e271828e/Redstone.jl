old: ### 14.7 The trim problem:
tag: F

old: NamedTuple decisions, declared reads, named residuals
tag: F

old: The aircraft author ships one value.
tag: F

old: It says what the solver may vary, what those decisions make of the model, what to read back after each evaluation, and which equations the readings must satisfy.
tag: F

old: Rule.
tag: TODO

old: The field set is normative.
tag: TODO

old: The lift (§14.9) is field-by-field, so this list is closed.
tag: TODO

old: - `guess`, `lower` and `upper` are same-named all-`Float64` NamedTuples.
tag: TODO

old: - `condition` is the condition-valued function over decisions.
tag: TODO

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
tag: TODO

old: Worked, the C172 cruise case reduces to its three-equation core.
tag: TODO

old: The real problem is the same shape with the full 7-variable search, and the θ-constraint elimination survives inside `trim_condition`.
tag: TODO

old: `cruise = TrimProblem( guess = (throttle = 0.6, elevator = -0.05, α = 0.06), lower = (throttle = 0.0, elevator = -1.0, α = -0.1), upper = (throttle = 1.0, elevator = 1.0, α = 0.3), condition = d -> trim_condition(ac, params, d), #params closed over (§14.2) reads = reads(v̇_b = get_deriv("vehicle/dynamics", :v_eb_b), ω̇_b = get_deriv("vehicle/dynamics", :ω_eb_b), EAS = get_output("vehicle/airdata", :EAS)), residuals = (r, d) -> (axial_force = r.v̇_b[1], normal_force = r.v̇_b[3], pitch_moment = r.ω̇_b[2]), tolerances = (axial_force = 1e-3, normal_force = 1e-3, pitch_moment = 1e-4), checks = (r, d) -> (EAS = r.EAS - params.EAS,), # read back after the commit check_tolerances = (EAS = 0.1,))`
tag: F

old: The rest of the section takes what the author ships one piece at a time, against today's `c172.jl`.
tag: TODO

old: - Decision variables, initial guess and box bounds are plain, same-named, all-`Float64` NamedTuples.
tag: TODO

old: The `AbstractTrimState{N}`/`FieldVector` supertype dies.
tag: TODO

old: Its only job was vectorization, and vectorization is the service's.
tag: TODO

old: The service packs and unpacks by field order, and that order is the `guess` NamedTuple's own. §9.5 states the rule this seam runs on: the names are the pairing, order carries no semantics.
tag: TODO

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

old: - `TrimParameters` stays a plain user struct the framework never sees.
tag: TODO

old: The assignment is the pure `trim_condition(ac, params, d)` fragment-tree function (§14.2), applied per iteration by the compiled plan (§14.4).
tag: F

old: - The read side is declared, then compiled.
tag: TODO

old: The spelling is `reads(name = get_state(path, leaf) | get_deriv(path, leaf) | get_output(path, leaf) | get_input(leaf) | get_face(leaf), ...)`, the service read set (§14.4), each `leaf` a leaf address (the field name with dotted and bracketed steps below it).
tag: TODO

old: `get_state` and `get_deriv` address a declared state field and its derivative (validated against `x_init`/`s_init`).
tag: F

old: `get_output` addresses a declared output port (validated against `y_types`).
tag: F

old: `get_input` and `get_face` address a root input face and an output face (validated against the root face lists).
tag: TODO

old: The path selectors (the closed family of deferred reads resolving against a source) reach any port the structure has (§13.3, D-414).
tag: F

old: An equilibrium equation meant to survive substitution at a generic seam reads a face.
tag: TODO

old: A value a component computes without declaring it is not addressable at all (§8.3, §14.4).
tag: TODO

old: A trim evaluation needing one is a signal that the component should export it.
tag: TODO

old: A derivative wanted across a contract boundary takes the same remedy.
tag: F

old: Publish it as an ordinary output port computed in `y_direct` (the one-line binding of the fused idiom, §5.3, made contract).
tag: TODO

old: That leaves `get_deriv` scoped to owned concrete subtrees.
tag: TODO

old: The compiled reader (the gather twin, §14.4) fills a stack-only NamedTuple per evaluation.
tag: TODO

old: - The user supplies a residual system, not a scalar cost.
tag: TODO

old: It is authored as a NamedTuple of named equations and packed to the solver's vector by field order.
tag: TODO

old: The order here is `tolerances`' field order, the declared side again, and the residual return is canonicalized to it.
tag: TODO

old: The decisions rule holds symmetrically on both ends of the seam.
tag: F

old: Names pair, and order never does.
tag: F

old: - Checks are equations the service reports once, at the committed state, and never solves.
tag: TODO

old: `checks` has the residual function's signature, and `check_tolerances` pairs with its return as `tolerances` pairs with the residuals'.
tag: F

old: The service gathers the checks after the commit, from the boundary-zero sweep, and reports them (§14.8).
tag: TODO

old: Setup observes their return's shape at the guess evaluation, as it observes the residuals' (§14.8).
tag: F

old: Their reads join the problem's one read set.
tag: F

old: Why.
tag: TODO

old: Under analytic elimination the condition math pins the airspeed and the flight-path angle from the targets and the atmosphere the user's `params` record holds, while the world measures against the atmosphere the baseline wrote.
tag: TODO

old: If the two disagree, the residuals vanish at a true equilibrium that is not the requested point, and nothing in the residual system can tell (D-139).
tag: F

old: A check reading EAS from the world's airdata at the committed state and subtracting the requested value is where a world measurement meets the request, so any mismatch moves it.
tag: TODO

old: The checks stay out of the solve because they carry no information for it (D-262).
tag: F

old: - The FlightCore formulation's core is correct and survives verbatim as user math.
tag: TODO

old: That core is analytic elimination:
tag: TODO

old: `θ_constraint` substituting the pitch constraint, filter and actuator equilibria imposed by construction, and the minimal 7-variable search.
tag: F

old: - What changes is the numerics.
tag: TODO

old: Trim is a square root-find.
tag: F

old: FlightCore's derivative-free scalar minimization over $\|r\|^2$ against a hand-scaled absolute `stopval` was the rational choice only because Jacobians through the mutating `f_ode!` chain and the assignment math were out of reach (D-069).
tag: TODO

old: - Nonlinear least squares with exact AD Jacobians is the default.
tag: TODO

old: The `Dual` activation seeds the decision variables through the `T`-generic assignment, sweep and `x_deriv`.
tag: TODO

old: The seeds survive the condition write boundary because §14.3 selects the baked converter per leaf from the shape.
tag: TODO

old: A decision-descended leaf is `Dual`-typed there and takes the structural conversion, while the zero-partial embedding stays on the held `Float64` leaves.
tag: TODO

old: The default is nonlinear least squares on $r(d)$ with exact AD Jacobians, in the trust-region/Levenberg–Marquardt family (§14.8).
tag: TODO

old: Convergence is quadratic (~5–15 evaluations), the tolerances are per-residual and physical, and failure reports name the unbalanced equations with magnitudes.
tag: F

old: The convergence verdict itself is service-owned and backend-independent (§14.8).
tag: F

old: - Non-squareness degrades gracefully.
tag: TODO

old: Redundant actuation becomes weighted or minimum-norm least squares.
tag: F

old: Infeasible demands converge to a nonzero residual identifying the impossible balance.
tag: F

old: At the solution, $\partial r / \partial d$ is free flight-physics data (control effectiveness) that cross-checks linearization.
tag: F

old: - The derivative-free scalar path survives as the fallback.
tag: TODO

old: The service squares and normalizes the residuals against the tolerances, minimizing $\sum (r_i/\mathit{tol}_i)^2$ at `stopval = 1` (§14.8).
tag: TODO

old: That normalization is where the hand-scaled absolute threshold is repaired.
tag: TODO

old: It leaves today's algorithm as the degenerate case.
tag: TODO

old: - Two problems are recorded, not built (a worked-out extension deliberately left unimplemented, its seams named).
tag: TODO

old: They are closed-loop sampled-data trim and on-ground static equilibrium, each simply another problem value over the same service.
tag: F

old: Closed-loop trim appends $g(s) - s = 0$ residuals via a nondestructive scratch evaluation of `s_update`, which was structurally impossible under FlightCore's mutating `f_disc!`.
tag: TODO

old: On-ground static equilibrium solves strut compressions and attitude against gear forces.
tag: F

old: The residual signature:
tag: TODO

old: `residuals(reads::NamedTuple, d::NamedTuple) → NamedTuple`
tag: F

old: Rule.
tag: TODO

old: What the solver varies is passed.
tag: TODO

old: What is fixed per problem is closed over.
tag: TODO

old: The gathered reads and the decision NamedTuple arrive as arguments.
tag: F

old: `d` is the one value that cannot be closed over.
tag: F

old: `TrimParameters` stays behind the closure, exactly as `condition` already holds it, and the framework never sees it.
tag: F

old: Being user-shaped, that record is also where any environment handles the condition math needs conventionally ride (the value-level constructor, §8.2; the pre-sweep doctrine, §14.1).
tag: TODO

old: The problem receives the environment, and never writes it (§14.9).
tag: F

old: The returned NamedTuple's names are the equation names the report and the failure messages use.
tag: TODO

old: The service packs residuals and tolerances by field order.
tag: TODO

old: `tolerances`' order is canonical for the r-side, and each residual return is reordered to it (`NamedTuple{keys(tolerances)}(r)`) before packing.
tag: TODO

old: An equation list spelled in a different order inside the lambda therefore pairs correctly and costs nothing.
tag: F

old: Names and types are checked at setup, because the guess evaluation the service performs anyway observes the residual key set.
tag: F

old: A `tolerances` key-set mismatch, or any field-type disagreement on either side of the seam, is `TrimProblemInvalid` (Appendix C), with the offending field and the names or types in hand.
tag: F

old: Order is never a mismatch.
tag: F

old: ### 14.8 The trim service: solver seam, scratch stores, commit and report
tag: F

old: A `TrimProblem` is an inert value until a service runs it.
tag: F

old: `trim!` is that service.
tag: F

old: It drives a solver it holds behind one method, works on scratch stores of its own, commits a converged solution the way `init!` would, and returns a report.
tag: TODO

old: #### The backend seam
tag: F

old: The signature is `trim!(model, problem; baseline, t0 = 0.0, backend = LevenbergMarquardt())`, where `model` is a `Model` (a deployment materialized at one scalar type) at `Float64` (D-319).
tag: F

old: `trim!(sim, problem; …)` gates on the simulation's lifecycle and commits through the simulation's `init!`.
tag: F

old: The default backend is an in-house dense Levenberg–Marquardt.
tag: TODO

old: For decision dimensions ~10 with exact Jacobians, the core is ~100 lines: a damping loop, a small linear solve, a convergence test.
tag: TODO

old: That is the §10.2 stepper precedent exactly, a tiny needed core against a heavy dependency.
tag: F

old: The per-residual physical tolerances sharpen the case (§14.7).
tag: F

old: They are a convergence test no external package spells natively.
tag: F

old: That is precisely why the service, not the backend, applies it.
tag: F

old: The backend contract is a pinned signature, value-passed, with one required method per backend.
tag: TODO

old: That one method is the seam.
tag: F

old: `solve(backend, eval!, d0, lower, upper, tol) -> (; d, status, n_evaluations, n_iterations)`
tag: F

old: `eval!(r, J, d)` is in-place and always fills `r`, the residual vector packed in `tolerances`' field order.
tag: F

old: It fills `J` iff `J !== nothing`.
tag: F

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

old: The return holds `d`, the solution, `status::Symbol` from a deliberately open set, and the diagnostic counts `n_evaluations` and `n_iterations`.
tag: TODO

old: The status is recorded verbatim in the report because the verdict is the service's (D-158).
tag: TODO

old: The name `solve` is subject to the exported-name audit (`pending.md`) like every other API spelling.
tag: F

old: The backend sees vectors and never names, so the solution it returns unpacks by the same order it was given.
tag: TODO

old: #### The convergence verdict is the service's, uniformly
tag: TODO

old: `converged` means `all(abs.(rᵢ) .≤ tolᵢ)`.
tag: F

old: That is the per-residual box test (§14.7) in its own physical units, evaluated by the service at the backend's returned point.
tag: F

old: It is one residual evaluation, noise against the solve that produced it.
tag: F

old: That verdict, and nothing else, gates the commit and fills `TrimReport.converged`.
tag: F

old: The backend's returned `status` is recorded in the report as diagnostic data, and it is authoritative over nothing.
tag: F

old: #### The tolerance translation, per backend family
tag: TODO

old: The tolerance translation is the service's too, per backend family.
tag: TODO

old: In least-squares backends the tolerances are the stopping criterion.
tag: F

old: They feed the per-residual test directly, so LM's damping loop tests exactly what the service will re-test.
tag: F

old: The derivative-free scalar fallback is `NLoptBackend(:LN_BOBYQA)` in a package extension.
tag: TODO

old: It passes `nothing` for the Jacobian, keeps today's algorithm one keyword away, and leaves the framework core carrying zero optimizer dependencies.
tag: TODO

old: For that fallback the service squares and normalizes.
tag: TODO

old: The objective minimized is $\sum_i (r_i/\mathit{tol}_i)^2$ with `stopval = 1`.
tag: TODO

old: That objective is dimensionless where FlightCore's threshold was hand-scaled and absolute (§14.7).
tag: F

old: It is a well-scaled valley where a raw $\|r\|^2$ sums forces against moments.
tag: F

old: The two criteria cannot disagree in the dangerous direction:
tag: TODO

old: $$\sum_i (r_i/\mathit{tol}_i)^2 \le 1 \quad\Longrightarrow\quad (r_i/\mathit{tol}_i)^2 \le 1 \;\text{ for every } i$$
tag: F

old: so the `stopval` sphere is inscribed in the tolerance box, and a fallback stopping at `stopval` necessarily passes the service's box test.
tag: TODO

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
tag: TODO

old: A decision variable saturated at the solution is flagged in the report:
tag: TODO

old: "converged with `elevator` at its upper bound".
tag: TODO

old: That is the classic CG-limit diagnostic, today inferable only from mysterious residuals.
tag: TODO

old: #### Scratch stores, stated without type luck
tag: TODO

old: Every `trim!` invocation instantiates a fresh working store set.
tag: F

old: Each half of it (below) is a scratch `Model` of its own, materialized from the deployment the service was called on (D-317, D-319).
tag: F

old: The set holds the `x` backing, the `s` and `m` stores, the root input and signal tables, and the derivative buffer.
tag: F

old: The set is built from the activation's layout (the build's typed products at a given scalar type).
tag: F

old: The layout is the reusable compiled artifact.
tag: F

old: The buffers are per-invocation and die with the call (stopped-sim allocation, §9.8).
tag: F

old: Each set also calls every workspace allocator once, at the activation's scalar (D-077).
tag: TODO

old: The `Dual` backend's buffers being un-aliasable by type is defense in depth, not the mechanism.
tag: F

old: A `Float64` backend (NLopt) gets equally fresh buffers.
tag: TODO

old: The invariant is backend-independent.
tag: F

old: The simulation's authoritative stores have exactly one writer, the commit through boundary zero (the initialization boundary: the ordinary macro-sequence with an empty integrate).
tag: TODO

old: Setup applies `override(baseline, condition(guess))` to the scratch set once, and that application's full coverage is checked here.
tag: TODO

old: The check is the comparison of the resolved plan against the `Build`'s `input_faces` (§14.6), one plan-level comparison before the first evaluation.
tag: TODO

old: Sweeps therefore see a complete world.
tag: F

old: Raw instantiation is sound exactly because of that check, since every root input is written before any read.
tag: F

old: An incomplete `baseline` is one declaration-ordered `UninitializedInputs` at setup rather than a whole solve against undefined cells.
tag: F

old: The frozen cells are established, not probe-seeded.
tag: TODO

old: At the seeded activation the discrete tier is frozen (§9.4).
tag: F

old: Its stages never run there, so nothing at that activation can derive a discrete output cell from the authored `s`.
tag: F

old: Setup therefore instantiates the scratch set in two halves.
tag: F

old: A nominal set takes the composite first, by the dynamic walk (§14.4), and runs one establishment round.
tag: TODO

old: That round is boundary zero's sweep with every discrete output stage admitted, due or not (D-205), with no projection, no guards and no `s_update`.
tag: F

old: The seeded set is then written by the specialized `apply!`, and its frozen cells are copied from the nominal set as zero-partial constants (the embedding of §14.3).
tag: TODO

old: Every cell the iterations read is thus derived from the authored world.
tag: F

old: A frozen cell holds what the authored discrete state publishes, which makes "held at the operating point" literal.
tag: F

old: No scratch cell holds the probe's synthesized values.
tag: F

old: That is the §14.6 barrier reaching the scratch world, as D-205 made it reach the published one.
tag: F

old: The iterations are untouched.
tag: F

old: They are raw write → sweep → read cycles at the seeded activation, over the continuous chain and `x_deriv` alone (§14.5).
tag: F

old: The zero-decision problem (below) is the nominal half alone, and its one evaluation is that establishment round (D-213).
tag: TODO

old: The commit applies the same composite over the same `baseline` (`override(baseline, condition(d))`, §14.9), so its coverage is setup's.
tag: F

old: Commit's totality check is therefore structurally unfailable through the trim path, and it stands as the shared `init!`-boundary defense.
tag: TODO

old: A converged solve is always committable.
tag: F

old: `TrimReport` therefore carries no committed flag, and the no-throw doctrine needs no exception.
tag: F

old: Iterations rewrite the composite's write-set via the compiled plan.
tag: F

old: The write-set is `override(baseline, condition(d))`, the same tree setup resolved, so a store both layers touch merges exactly as it did at setup.
tag: F

old: An LM evaluation is one Dual-seeded sweep yielding `r` (value parts) and `J` (partials) together.
tag: TODO

old: No convergence means no commit.
tag: F

old: Non-convergence is the service's box test failing at the returned point, whatever status the backend attached to it.
tag: TODO

old: No commit means the sim is bit-for-bit untouched, including "never initialized".
tag: F

old: Today's warn-but-assign is structurally impossible.
tag: TODO

old: The same structure covers an interrupt.
tag: F

old: Ctrl-C during a long solve unwinds an ordinary Julia call operating on per-invocation scratch stores.
tag: F

old: No commit has happened, and the simulation is bit-for-bit untouched, exactly as a non-converged solve leaves it.
tag: F

old: The services need no counterpart to the loop's boundary masking (§12.4).
tag: F


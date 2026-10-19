old: ### 14.4 One plan, two ways to apply it The paradigm-change tax feared at execution does not materialize.
new: TODO
tag: F

old: All string work, validation and addressing are functions of the shape of the condition (the path-addressed sparse overlay that sets a build's state).
new: TODO
tag: F

old: Every hot path holds the shape fixed while varying values.
tag: F

old: Execution is therefore resolve-once/execute-many, with two ways to apply one plan.
new: TODO
tag: F

old: - Specialized `apply!` serves the service that iterates, trim's per-evaluation write.
new: TODO
tag: F

old: It unrolls stores through the baked lenses and converters.
tag: F

old: Those are the same machine operations as today's in-place writes: zero-alloc, no strings, no dispatch.
new: TODO
tag: F

old: The per-iteration shape check is the mechanism of §9.5 transferred.
tag: F

old: The tree type is proven by dispatch, and it carries the full nesting, every field name and leaf type.
tag: F

old: A `===` sweep over the prefix strings closes the remainder.
new: TODO
tag: F

old: `===` on strings compares content, so a prefix computed at run time pairs with the compiled one exactly as a literal does, at the cost of one short comparison per `at` node.
tag: F

old: Shape drift (a tree of another type, or a prefix that differs at a position) is `ConditionShapeDrift` (Appendix C), a structured error rather than silent corruption.
new: TODO
tag: F

old: The cost is Julia codegen once per condition shape, and it grows with the shape's writes.
new: TODO
tag: F

old: On Julia 1.13 it measures 10 to 50 ms up to 32 writes, 0.09 s at 64 and 0.2 s at 128 (`docs/reports/20261002_tuple_walks/`).
tag: F

old: That cost is noise against the model's own first-sweep warmup (seconds), and against the 10³–10⁴ optimizer evaluations the codegen amortizes over.
new: TODO
tag: F

old: - The dynamic walk serves the one-shot uses, `init!` and `linearize`'s operating condition.
new: TODO
tag: F

old: It executes the same validated entry list by runtime dispatch per write.
new: TODO
tag: F

old: That takes microseconds in total, with allocation permitted, since the stopped-sim path was never under the zero-alloc regime (§9.8).
tag: F

old: It needs no per-shape codegen.
tag: F

old: Fifty structurally different scripted conditions cost fifty walks, not fifty compiles.
tag: F

old: Rule.
new: TODO
tag: F

old: Which of the two a service uses is internal, never user-facing API.
tag: F

old: A compiled plan or reader carries the activation it was compiled at and applies only to a store set of that activation.
tag: F

old: That pairing is a framework invariant the services uphold, not a user-facing check.
tag: F

old: Neither plans nor readers are user values.
tag: F

old: #### The read-selector family The read-selector family is closed.
new: TODO
tag: F

old: Its members are `get_state(path, leaf)`, `get_deriv(path, leaf)`, `get_output(path, leaf)`, `get_input(leaf)` and `get_face(leaf)`.
tag: F

old: They form one address space for every reader of the model.
tag: F

old: Rule.
new: TODO
tag: F

old: `leaf` is a leaf address: the field or face name, followed by `.name` and `[k]` or `[k,l]` steps in any order, as in `"pose.q_eb[2]"`, `"ω_eb_b[1]"` or `"J[1,3]"`.
new: TODO
tag: F

old: A bare `Symbol` is the short form of a plain name, so `get_state("kin", :θ)` reads `get_state("kin", "θ")`.
tag: F

old: A face name is an arbitrary string and may contain a dot (§8.6), so on `get_input` and `get_face` the head is matched rather than parsed: it is the longest declared face name that is a prefix of the address and is followed by the end, a `.` or a `[`, and a `Symbol` leaf names the face whole, with no steps.
new: TODO
tag: F

old: So `get_input("wing.throttle")` and `get_input("wind[1]")` both resolve, and where faces `a` and `a.b` both exist, `"a.b"` names the face `a.b`.
tag: F

old: Each step is checked at resolution against the type resolved so far.
tag: F

old: A `.name` step needs an isbits struct with that field.
tag: F

old: An index step needs an `SArray`, with one index or one per dimension, and a vector leaf thereby yields named scalars.
tag: F

old: A step never enters an opaque leaf (a field handle or a `Symbol`), which is read whole.
tag: F

old: A continuous state field is flat (§7.1), so `get_deriv`, and `get_state` on the continuous tier, take at most an index step.
tag: F

old: A discrete `s` field is isbits or a `Symbol` (§3.2), and `get_state` on it takes the full address.
tag: F

old: The address is checked once and baked, and the read runs as field loads and indexing unrolled at compile time (D-276).
tag: F

old: The names carry a deliberate `get_` prefix.
new: TODO
tag: F

old: A selector is a deferred read, a value describing the read the compiled gather will perform.
tag: F

old: The prefix names that action, and it keeps five short common nouns out of the namespace user declarations share with domain code.
tag: F

old: There is no selector for a value a component computes without declaring it, and there cannot be one, because only cells are addressable (§4.2, §8.3).
new: TODO
tag: F

old: So a reader that wants one is asking the producing component to declare it an output (§8.3).
tag: F

old: `get_face` addresses an output face of the mount level, the level its read set is mounted at (§14.9).
new: TODO
tag: F

old: At the root that face is root-exported.
tag: F

old: Either way the read is an integration read (§11.2).
tag: F

old: Rule.
new: TODO
tag: F

old: A selector resolves against a source, before any client policy applies.
new: TODO
tag: F

old: The table selectors (`get_output`, `get_input`, `get_face`) resolve against a table source.
tag: F

old: A table source is a boundary snapshot, or the scratch tables a service evaluation instantiates (§14.8).
new: TODO
tag: F

old: The store selectors (`get_state`, `get_deriv`) resolve only against live stores.
new: TODO
tag: F

old: The table/store axis separates table-borne values from store-borne ones, not snapshots from services.
tag: F

old: Only stopped-sim service evaluations, `checkpoint`, and post-run inspection of the live stores (the replay-to-inspect, §11.2) ever hold live stores.
new: TODO
tag: F

old: The snapshot deliberately carries no state stores (§11.2), and `ẋ` buffers are integrator scratch, not boundary-consistent objects outside a service evaluation.
tag: F

old: A reader resolving for a table source that names a store selector is therefore refused at resolution, as a `ReadResolution` (D-406).
new: TODO
tag: F

old: The resolver takes the source it resolves for, so the rule is the resolver's and not a client's.
new: TODO
tag: F

old: The honest remedy (§11.2) is to declare the field in `y_types`, return it from `y_state`, and read the resulting port (§5.3).
tag: F

old: Client policy rides on top.
new: TODO
tag: F

old: It is D-083's service and inspection sides restated as a resolver property.
new: TODO
tag: F

old: - Service reads speak the contract.
new: TODO
tag: F

old: Trim's `reads` and linearization's taps (the three selector lists declaring what linearization seeds and reports) name `get_state`/`get_deriv`/`get_output`/`get_input`/`get_face`.
new: TODO
tag: F

old: They do so within the scopes the locality law (§6.1) and fragment scoping (§14.2) describe, as authoring guidance (D-414).
tag: F

old: `get_face` is the set's seam-crossing member.
new: TODO
tag: F

old: It resolves through export chains exactly as mounting (relocating a whole problem or tap set with `at(prefix, …)`) resolves root input faces (§14.9), so the read side mirrors the write side.
new: TODO
tag: F

old: An equilibrium equation meant to outlive the build it was posed against therefore binds the curated face behind a generically-held child rather than a path into it.
new: TODO
tag: F

old: A service evaluation needing an undeclared intermediate has one remedy, and it is the same for every client.
new: TODO
tag: F

old: The component exports it (§14.7).
tag: F

old: - Inspection readers admit the whole family, within the source rule.
new: TODO
tag: F

old: Output-device bindings, log extraction by `series` and snapshot inspection take deep paths, `get_face` names and leaf addresses alike (D-406, D-407, D-414).
new: TODO
tag: F

old: The store selectors reach only the inspection clients that actually hold stores (`checkpoint`, post-run inspection).
new: TODO
tag: F

old: A snapshot-bound reader is barred from them by source, not by client.
new: TODO
tag: F

old: - `ignore_stop_requests` is not a family client.
new: TODO
tag: F

old: It names requesters from the `Build`'s requester roster, period (§13.5, D-060, D-316).
new: TODO
tag: F

old: Termination is run policy over the requests the model declares, and no path selector reaches `ignore_stop_requests`.
new: TODO
tag: F

old: The five selectors, their sources, and their clients:
new: TODO
tag: F

old: | selector | resolves against | service reads | inspection readers | |---|---|---|---| | `get_state(path, leaf)` | live stores | named in the contract | only clients that hold stores | | `get_deriv(path, leaf)` | live stores | named in the contract | only clients that hold stores | | `get_output(path, leaf)` | a table source | named in the contract | admitted | | `get_input(leaf)` | a table source | named in the contract | admitted | | `get_face(leaf)` | a table source | named in the contract | admitted | Compiled readers are the gather twin over this family and the layout tables.
new: TODO
tag: F

old: Trim's cost read (`ẋ` and output fields) and linearization's Jacobian gather are one primitive run in reverse.
new: TODO
tag: F

old: It is one machinery, in both directions, in the `Build`'s client kit.
tag: F

old: The per-iteration ledger for trim has four terms.
tag: F

old: They are the user fragment math (the domain computations unchanged from today, plus the tree's few boxes, §14.2), the leaf stores, the folded shape check, and the sweep.
new: TODO
tag: F

old: The sweep dominates, exactly as `f_ode!` does today.
new: TODO
tag: F

old: `apply!` ends at established stores.
tag: F

old: Making the model coherent is the job of boundary zero (the initialization boundary: the ordinary macro-sequence with an empty integrate), §14.5.
new: TODO
tag: F

old: ### 14.5 Boundary zero: an ordinary boundary with authored incoming transitions `apply!` establishes the stores at `t₀`.
tag: F

old: The init service then completes the §10.6 macro-sequence with an empty integrate.
new: TODO
tag: F

old: The sequence is project → [sweep → guards → handlers]\ → due `s_update` calls → first snapshot.
new: TODO
tag: F

old: After the first snapshot `init!` takes the trace header, the checkpoint (the `Model`'s state at a frame top as one value) of the state the sequence leaves (§11.5, D-274).
tag: F

old: The parity with an ordinary boundary is exact, not approximate.
tag: F

old: The pieces follow one by one.
new: TODO
tag: F

old: - Project runs.
tag: F

old: Authored `x` can sit off-manifold.
tag: F

old: A hand-assembled quaternion may be ulps off unit norm, or a condition (the path-addressed sparse overlay that sets a build's state) may write part of a constrained block against fresh defaults.
tag: F

old: Projection after condition writes holds the same position it holds after any other `x` mutation.
tag: F

old: And it costs nothing when the state is already clean.
tag: F

old: - The sweep runs, and every discrete output stage publishes, due or not (D-205).
tag: F

old: `t₀` is a grid point of every phase-free divisor, so the `Φ = 0` components are due in full.
tag: F

old: An offset component (§10.5) is not due, because its first tick is at `Φ·Δt_base`.
tag: F

old: Its output stages run at boundary zero all the same, publishing from the authored `s` and the `t₀` table in the ordinary sorted walk.
tag: F

old: That evaluation is establishment, not a scheduled sample.
tag: F

old: The schedule owns every instant after `t₀`, and the first sample the component's `s_update` consumes remains its `Φ·Δt_base` tick's.
tag: F

old: What the rule buys is a `t₀` snapshot carrying the authored world fully evaluated.
tag: F

old: No published cell holds the probe's synthesized values.
tag: F

old: That is the §14.6 barrier extended from the root inputs to the whole table.
tag: F

old: - Events run.
tag: F

old: A condition can land a guard predicate in holding territory (firing on not-holding → holding transitions, never bare sign changes).
tag: F

old: An authored stall flag, or a strut authored into contact, does exactly that.
tag: F

old: The event then fires visibly at `t₀` rather than one step later.
tag: F

old: The prior rule grounds that timing (§10.6).
new: TODO
tag: F

old: Boundary zero establishes every guard prior (the event's stored predicate sample from the previous boundary) as not-holding.
tag: F

old: Suppressing those firings was rejected (D-067), on the stage-on-interaction lesson of §11.7 (widgets stage on edit or activation, never per render pass).
new: TODO
tag: F

old: Insurance that masks invariant violations is anti-diagnostic (D-026).
new: TODO
tag: F

old: The trace header is taken after the sequence (§11.5).
tag: F

old: Replay restores it and runs no boundary zero, so whatever fired at `t₀` comes back as part of the restored state and never fires twice (§12.7).
new: TODO
tag: F

old: The checkpoint records the post-firing state faithfully and suppresses nothing.
tag: F

old: A stop request already reading `STOP_REQUESTED` is a different category.
tag: F

old: Nothing fires.
tag: F

old: The request simply holds in the published `t₀` snapshot and the loop reacts (§13.5).
new: TODO
tag: F

old: - Due `s_update` calls run.
tag: F

old: This follows from an interval-alignment fact that is easy to mis-picture.
tag: F

old: It is hereby a taught contract, sibling to the boundary-sampling line (§8.6).
tag: F

old: A boundary's `s_update` is the outgoing transition.
new: TODO
tag: F

old: At tick `t_k` it consumes the completed boundary's samples and produces `s_{k+1}`, the value the next tick reads.
tag: F

old: The transition that carried `s` into `t_k` ran at `t_{k-1}`.
tag: F

old: Boundary zero is missing its incoming transitions on both tiers, and authorship replaces both.
new: TODO
tag: F

old: | tier | `t₋₁` | `t₀` (boundary zero) | `t₁` | |---|---|---|---| | discrete | the `s_update` that would have produced a discrete leaf's `s(0)` never ran; the condition authored `s(0)` | `s_update` consumes the `t₀` samples and produces `s(1)` | the gated stages read `s(1)` | | continuous | the integration over `[t_{-1}, t_0]` that would have produced a continuous leaf's `x(0)` never ran; the condition authored `x(0)` | the authored `x(0)` is the initial condition of the outgoing integrate, $t_0 \to t_0 + h$ | | The outgoing work all runs, and `t₀`'s `s_update` has its only opportunity.
tag: F

old: `s(1)` must sit in the store before `t₁`'s gated stages read it.
tag: F

old: An accumulator $s_{k+1} = s_k + \Delta t \, e_k$ authored with $s_0 = 0$ under nonzero $e(t_0)$ would otherwise first integrate $e(t_1)$, putting the whole sampled-data lattice one period late (D-067).
tag: F

old: The authored `s(0)` needs no protection, because it is published in the `t₀` snapshot regardless.
tag: F

old: The continuous-tier analogue of `s_update`-at-`t₀` is not the empty incoming integrate but that first outgoing one.
tag: F

old: Both authored values are the published initial conditions of their outgoing transitions.
tag: F

old: - `t₀` is an init-service argument (default `0.0`), never a condition entry, because time is not a store of any component.
new: TODO
tag: F

old: The harmonic grid (every discrete period an integer multiple of `Δt_base`) anchors at whatever `t₀` boundary zero runs at.
tag: F

old: Both init-service entry points carry the argument, with the same default.
new: TODO
tag: F

old: They are `init!(model, condition; t0)`, which the simulation's `init!(sim, condition; t0)` forwards to, and `trim!`'s commit (§14.8, D-319).
new: TODO
tag: F

old: `trim!(model, problem; baseline, t0, backend)` commits through the model's `init!`, and `trim!(sim, problem; baseline, t0, backend)` through the simulation's.
new: TODO
tag: F

old: Conditions are time-free.
tag: F

old: Nothing after boundary zero sets the origin.
tag: F

old: A restore inherits the clock and takes no `t0` (D-273).
tag: F

old: - Trim is untouched by all of this.
new: TODO
tag: F

old: Optimizer iterations are raw write → sweep → read cycles on the activation, with no boundaries, no events and no `s_update`.
tag: F

old: Only the committed solution executes boundary zero.
tag: F

old: - A guard firing at commit is a wanted failure signal.
tag: F

old: Today's hand-written trim asserts (`!stall`, no weight-on-wheels, `ω > ω_idle`) become the model's own event logic, surfaced through the ordinary machinery instead of `@assert`.
new: TODO
tag: F

old: A handler that fires at commit moves the committed stores off the solved point.
tag: F

old: Saying nothing would be warn-but-assign relocated.
tag: F

old: The channel that says it is the trim report (§14.8).
new: TODO
tag: F

old: - A commit-fired handler is not the only mover, and the second one is unconditional.
new: TODO
tag: F

old: Boundary zero's first act is `x_projection`, so the committed `x` is `x_projection(x)`, not the solver's `x`.
tag: F

old: An attitude quaternion renormalized by a few ulps is the canonical case.
tag: F

old: That move is legitimate, wanted, and usually invisible in the residuals.
tag: F

old: But the point the stores sit at is no longer the point the verdict was read at.
tag: F

old: Both movers take the same remedy, specified with the report in §14.8.
tag: F

old: ### 14.6 Root-input totality: the missing-value error and the `override` combinator Root inputs are the one initialized datum without declared defaults.
tag: F

old: That is the bare-types decision (§11.3), upheld here (D-068).
new: TODO
tag: F

old: So a root input's only source before boundary zero (the initialization boundary: the ordinary macro-sequence with an empty integrate) is the condition.
new: TODO
tag: F

old: Three consequences follow.
tag: F

old: Totality is a precondition of starting, checked by the service.
new: TODO
tag: F

old: A condition value is legitimately partial.
tag: F

old: Fragments compose, and trim iterations write subsets.
tag: F

old: So "every root input covered" is not a property of conditions.
tag: F

old: It is a property of every application that establishes a complete world over virgin stores.
new: TODO
tag: F

old: That principle, not an enumeration, names the sites.
tag: F

old: They are `init!`, trim's setup application to freshly allocated scratch stores, and trim's commit through boundary zero (§14.8).
new: TODO
tag: F

old: That is one class, one mechanism and one kind.
tag: F

old: Each compares the resolved plan's root-input coverage against the `Build`'s `input_faces` before writing anything.
tag: F

old: A shortfall is one collected, declaration-ordered diagnostic (`UninitializedInputs`, a §13.2 kind) naming every uncovered face.
new: TODO
tag: F

old: Coverage is a plan-level fact, because both operands are resolution-time data.
tag: F

old: The check is therefore one comparison, and it runs before any evaluation, not merely before any write.
tag: F

old: Pre-write means all-or-nothing.
tag: F

old: A rejected init leaves the sim exactly as it was, the same posture as failed trim.
tag: F

old: The probe-value barrier is structural.
new: TODO
tag: F

old: The `probe_value` synthesis (§9.3; zero/false/first-enum/`T()`) exists so build-time probes can exercise code with fabricated inputs.
new: TODO
tag: F

old: A fabricated zero is a fine probe input and a terrible flight condition.
tag: F

old: A silently zeroed `mixture` kills the engine and sends the user debugging aerodynamics.
tag: F

old: The services path simply contains no call to it.
tag: F

old: A root input gets a condition value or the application errors, with no third branch.
tag: F

old: Replay likewise never synthesizes.
tag: F

old: The trace header holds every root-input cell as boundary zero left it, and with totality enforced that record is complete by construction (the requirement discharged, §11.3).
new: TODO
tag: F

old: Baselines are aircraft-shipped condition functions, layered by `override`.
new: TODO
tag: F

old: Nobody hand-writes ~20 root-input values per script.
tag: F

old: Today `SystemsInitializer`'s `@kwdef` defaults carry that load.
new: TODO
tag: F

old: Their successor is ordinary user math in one authoritative home, such as `ready_for_taxi(ac)` or `cold_and_dark(ac)`, returning full-coverage conditions.
tag: F

old: But "baseline plus tweaks" collides with the duplicate-leaf error (§14.2) by design.
tag: F

old: The collision is the intent.
new: TODO
tag: F

old: Hence the fourth node kind, `override(base, patch)`.
new: TODO
tag: F

old: It is ordered and asymmetric, where `combine` is symmetric and collision-intolerant.
tag: F

old: At resolution a leaf present in both takes the patch's value, with the origin recording both layers ("patch overrode base's `throttle`").
new: TODO
tag: F

old: Collisions within one layer remain errors.
tag: F

old: Variadic layering (`override(campaign, aircraft, todays_case)`) composes.
tag: F

old: Trim uses it on day one.
tag: F

old: The committed condition is `override(baseline, solution)`, the solver's handful of values over full coverage (D-068).
new: TODO
tag: F

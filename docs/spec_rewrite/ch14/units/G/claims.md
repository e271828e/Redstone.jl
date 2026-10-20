# Unit G claims: §14.8 from "The commit, in full", and §14.9.

old: #### The commit, in full
tag: X

old: The committed solution is applied as an `init!` in every respect.

old: It is `override(baseline, solution)` through boundary zero, with the pre-write root-input totality check (§14.6), the sequence (§14.5) and guards at commit.
new: It is `override(baseline, condition(d))` through boundary zero, with the pre-write root-input totality check (§14.6), the sequence (§14.5) and guards at commit.
tag: R
ruling: R9
note: F61, "`override(baseline, solution)`" becomes "`override(baseline, condition(d*))`" (the normalizer drops the `*`), as `src/trim.jl` 612 commits and §14.9 writes it. The guard link goes (F67, a duplicate of unit F's 12190); root-input totality keeps its link, its first use in §14.8.

added: That check requires the application to cover every root input.
# root-input totality's first-use gloss as its own sentence, from the glossary entry: "the pre-write requirement that an application establishing a complete world over virgin stores (`init!`, trim setup, trim commit) cover every root input".

old: The `t0` argument that anchors the grid, and its default, are the same for both init-service entry points (§14.5).
new: The `t0` argument that anchors the grid, and its default, are the same for both init-service entry points (§14.5, D-110).
tag: C
newcites: §14.5 D-110
note: D-110 Position, "`trim!` gains the init-service `t0` argument ... default `0.0` matching `init!` (one rule for both entry points)". Already a pointer to §14.5, the home under R6.

old: The recorders restart exactly as §12.6 states for `init!`.
new: The recorders (the trace and the log jointly) restart exactly as §12.6 states for `init!` (D-110).
tag: C
newcites: §12.6 D-110
note: D-110, Rationale only ("the §12.6 three-item clear (trace, log, staged batches)"). The gloss is the glossary's `recorders` entry.

added: (the trace and the log jointly)

old: The trace and the log are new objects, and any batches still in staging cells (where a device's pending write batch waits between drains) are cleared.
new: The trace (the primary record of a session) and the log are new objects. Any batches still in staging cells (where a device's pending write batch waits between drains) are cleared.
note: split in two. Batch takes no parenthesized gloss: the staging cell's gloss in the same sentence says what a batch is, and one parenthetical is the limit.

added: (the primary record of a session)
# trace's first-use gloss, the glossary's words.

old: A fresh recording starting at its own anchor is unattended mode's natural shape.
new: A fresh recording that starts at its own anchor is the natural shape of an unattended run (a run with empty staging and no snapshot readers).
note: step 5 P2-19: the glossary's term, linked and glossed with its words

old: A trim at a point reached by flying is not offered.
new: Trim is not offered at a point reached by flying.

old: Trim takes an authored baseline.
new: It takes an authored baseline.

old: Fly-then-retrim is `checkpoint` the flight, then author the trim's baseline from what the checkpoint (the `Model`'s state at a frame top as one value) shows (D-273).
new: Fly-then-retrim is spelled as a checkpoint (the `Model`'s state at a frame top as one value) of the flight, then a trim baseline authored from what the checkpoint shows (D-273).
note: step 5 P2-20: the checkpoint link and gloss move to the first use

old: #### The report, not an exception
new: #### The report
tag: R
ruling: R8
note: M56. "not an exception" survives in the sketch's comment and in "Non-convergence never throws".

old: `trim!` returns a structured `TrimReport`:
new: `trim!` returns a structured `TrimReport` (D-070).
tag: C
newcites: D-070
note: D-070 bullet 3, "`TrimReport` is a no-throw structured value". The mid-sentence colon goes.

added: The sketch names its eleven fields in order.
# R11: the sketch now names the code's eleven fields (`src/trim.jl` 145-157).

old: `# what trim! returns: a value to read, never an exception to catch struct TrimReport converged # the service's box test at the backend's returned point … # the remaining fields, enumerated below; this section # does not name them end`
new: `# what trim! returns: a value to read, never an exception to catch struct TrimReport converged # the service's box test at the backend's returned point solution # the solution NamedTuple, guess-shaped residuals # the solved-point residuals the verdict is read off tolerances # the tolerances they come with committed_residuals # the same residuals, re-gathered after the commit committed_checks # the check function's return at the committed state status # the backend's returned status, diagnostic only n_evaluations # the backend's evaluation count n_iterations # the backend's iteration count saturated # the saturated-bounds list fired_events # the events the commit fired end`
tag: R
ruling: R11
note: F63. The eleven fields in the code's order (`src/trim.jl` 145-157), each comment drawn from the list below; the list is keyed to the names. The first two comment lines stand verbatim.

old: Field by field:
new: The list below takes the fields in turn.
tag: X

old: - The `converged` flag is the service's own box test at the returned point, never a backend's opinion.
new: - `converged` is the service's own box test at the returned point, never a backend's opinion.
tag: R
ruling: R11
note: keyed to the field name.

old: - The solution NamedTuple is guess-shaped, hence warm-startable.
new: - `solution` is the solution NamedTuple. It is guess-shaped, hence warm-startable.
tag: R
ruling: R11

old: - The solved-point residuals come with their tolerances.
new: - `residuals` are the solved-point residuals, and `tolerances` the tolerances they come with (D-155).
tag: R
ruling: R11 B9
newcites: D-155
note: B9 drops the §14.5 pointer: §14.5 does not state the two residual sets and points back to this section. Keyed to `residuals` and `tolerances`. R7: D-155's first ruling (the report carries both residual sets) is bold at §14.5, so a plain pointer here with its citation. D-155 Position: "the `TrimReport` carries both residual sets: the solved-point residuals ... and the committed-state residuals". The bold on the term goes.

old: They are the very numbers the verdict is read off, gathered at the backend's returned point.

old: - The committed-state residuals are the same residuals re-gathered from the boundary-zero world after the commit.
new: - `committed_residuals` are the committed-state residuals, the same residuals re-gathered from the boundary-zero world after the commit.
tag: R
ruling: R11

old: - The committed-state checks are the check function's return at the committed state, gathered beside the committed-state residuals and empty when the problem declares none (§14.7).
new: - `committed_checks` holds the committed-state checks, the check function's return at the committed state. They are gathered beside the committed-state residuals and empty when the problem declares none (§14.7).
tag: R
ruling: R11

old: - The backend's returned status comes with its iteration and evaluation counts.
new: - `status` is the backend's returned status, and `n_evaluations` and `n_iterations` are its evaluation and iteration counts.
tag: R
ruling: R11

old: These are diagnostic throughout, informative about how the solve went and decisive about nothing.

old: - The saturated-bounds list.
new: - `saturated` is the saturated-bounds list.
tag: R
ruling: R11

old: - The commit's fired events, as component paths and event names.
new: - `fired_events` holds the commit's fired events, as component paths and event names.
tag: R
ruling: R11

old: The list is empty when boundary zero ran quiet (§14.5).
new: The list is empty when boundary zero ran quiet (§14.5, D-126).
tag: C
newcites: §14.5 D-126
note: D-126 Position, "the `TrimReport` carries the fired set (component paths and event names)". R7: D-126 is bold at §14.5; a plain pointer here.

old: The committed-state residuals are nearly free.
new: The committed-state residuals are nearly free (D-155).
tag: C
newcites: D-155
note: D-155 Position, "nearly free — boundary zero's sweep has already run".

old: That boundary's sweep has already run, so the residuals' declared reads need only gather from it.
new: Boundary zero's sweep has already run, so the residuals' declared reads need one derivative evaluation and a gather from it.
tag: R
ruling: R9
note: F56. `_verdict!` runs one `rhs` before the gather (`src/trim.jl` 622-627).

old: There is no offset caveat to carry.

old: Every output stage publishes at boundary zero (D-205, §14.5), so a residual reading an offset component's port reads a commit-refreshed cell like any other.
new: Every output stage publishes at boundary zero (D-205, §14.5). A residual reading the port (one declared name, one cell) of a component whose schedule has a nonzero phase (an offset against its grid) therefore reads a commit-refreshed cell like any other.
note: split in two; "therefore" keeps the causal link's direction. Port takes its gloss from the glossary ("one declared name, one cell, ..."). Component keeps its link without a gloss, one parenthetical being the limit.; step 5 P2-22: 'an offset component' spelled out; phase linked with the glossary's gloss ('a schedule's offset against its grid')

added: (one declared name, one cell)

old: Those committed-state residuals are the numbers describing the state the simulation is actually in, which is the point a `linearize` at its default operating point reads.
new: Those committed-state residuals are the numbers describing the state the simulation is actually in, which is the point a `linearize` at its default operating point (§14.10) reads.
newcites: §14.10
note: step 5 P2-23: the §14.10 pointer moves here, the first of the two mentions

old: A non-empty fired-event set also raises `TrimCommitEvents` (Appendix C).
new: A non-empty fired-event set also raises `TrimCommitEvents`, a logged warning (Appendix C, D-126).
tag: R
ruling: B8
newcites: Appendix C D-126
note: D-126 Position, "a non-empty set raises `TrimCommitEvents`". Its bold is §14.5's (R7). B8, once at the first "raises": Appendix C, "Warning · service · logged"; D-262, "a logged warning that rides the report"; src/trim.jl 620-644 logs it with @warn.

old: The committed stores then sit at the post-handler point, not the reported solution, and a `linearize` at its default operating point (§14.10) reads that point.
new: The committed stores then sit at the post-handler point, not the reported solution, and that is the point `linearize` reads by default.
newcites: none
note: step 5 P2-23: the second mention shortened; its §14.10 pointer now sits on the first, in the paragraph before

old: The two residual sets are what make the moved point auditable.

old: A converged solve whose committed-state residuals violate the box test raises `TrimCommitResiduals` (Appendix C), naming the offending residuals with their committed values and tolerances.
new: A converged solve whose committed-state residuals violate the box test raises `TrimCommitResiduals`, naming the offending residuals with their committed values and tolerances (Appendix C, D-155).
tag: R
ruling: R7
newcites: Appendix C D-155
note: R7, D-155's second ruling bold here. D-155 Position: "a converged solve whose committed-state residuals violate the box test raises the new service warning `TrimCommitResiduals` (Appendix C: offending residual names, committed values, tolerances)".

old: The move, whether `x_projection` or a commit-fired handler (§14.5), is surfaced rather than left silent.

old: The verdict itself is not re-litigated.
new: The verdict itself is not revisited.

old: It gated the commit, at the solved point, and the numbers (D-150) stand as reported.
new: It gated the commit at the solved point, and the numbers stand as reported (D-150).
note: step 5 P2-25: the citation leaves mid-phrase

old: The committed-state checks audit the point rather than the move.

old: A converged solve whose committed-state checks leave their tolerances raises `TrimCommitChecks` (Appendix C), naming the offending checks with their committed values and tolerances.
new: A converged solve whose committed-state checks leave their tolerances raises `TrimCommitChecks`, naming the offending checks with their committed values and tolerances (Appendix C, D-262).
tag: R
ruling: R9
newcites: Appendix C D-262
note: F81, D-262 cited where it rules; R7 bolds its headline clause, the ruling's home being where the checks run. D-262 Position: "A check outside its tolerance raises `TrimCommitChecks`, a logged warning that rides the report."

old: The equilibrium is real.

old: The operating point is not the one the problem asked for, which is what a params-vs-world atmosphere mismatch produces under elimination (§14.7, D-139).
note: D-139 stays for the elimination clause (its Rationale: "under elimination a params-vs-world handle mismatch converges to a true equilibrium at an unintended operating point"), as F81 allows.

old: The checks are gathered from the same boundary-zero sweep, so they cost no evaluation of their own.

old: No commit means no checks, exactly as for the committed-state residuals.

old: Non-convergence never throws.
new: Non-convergence never throws (D-070).
tag: R
ruling: R7
newcites: D-070
note: q24 row 625, bold with D-070 bullet 3 ("non-convergence is an expected envelope-sweep outcome") and Rejected ("Throw-on-non-convergence: an expected outcome, not broken machinery").

old: It is an expected outcome, per the exceptions-are-broken-machinery line (§13).
new: It is an expected outcome, not broken machinery (§13.5).
tag: R
ruling: R9
newcites: §13.5
note: F58 (carried). The bare §13 becomes §13.5, whose line is "exceptions from model code are always abnormal"; the phrase §13.5 does not use goes, and D-070's Rejected list carries "not broken machinery".

old: In an envelope sweep, hitting the infeasible edge is information.
new: When trims span the flight envelope, hitting the infeasible edge is information.
tag: R
ruling: R9
note: F66, *sweep* is reserved.; step 5 P2-26: 'an envelope of trims' was reader-cold; *sweep* stays out (F66)

old: A malformed problem is a different case.

old: It is a `DiagnosticError`-class failure at setup, `TrimProblemInvalid` (Appendix C).
new: It fails at setup with a `DiagnosticError` carrying `TrimProblemInvalid` (Appendix C).
tag: R
ruling: R9
note: F66, *class* is reserved.

old: The malformed cases are a guess/bounds key-set or field-type disagreement,
new: - A guess/bounds key-set or field-type disagreement.
tag: R
ruling: R9
note: F52; the inline list becomes a bullet list (survey part A's display candidate) once F52 adds the code's reasons.

added: The malformed cases are these.

added: - A field that is not a NamedTuple, or a `reads` that is no read set.
# F52, `:not_a_namedtuple` and `:not_a_read_set` (`src/diagnostics.jl` 2007-2008; `src/trim.jl` 295-391).

added: - A box with `lower` above `upper`.
# F52, `:inverted_box`.

added: - A tolerance or check tolerance that is not finite and positive.
# F52, `:nonpositive_tolerance`, raised by `_check_tolerances!` for both `tolerances` and `check_tolerances`.

old: an unknown `reads` selector,
new: An unknown `reads` selector (one of the closed family of deferred reads) is refused that way.
tag: R
ruling: R9
note: F52, an unknown `reads` path raises `PathResolution` `:unknown_child`, the read set's own refusal, not a `TrimProblemInvalid` case. Selector takes its first-use link and the gloss §14.9 already used.

added: (one of the closed family of deferred reads)

old: a `tolerances`/residual key-set mismatch observed at the setup guess evaluation, and a `check_tolerances`/check key-set mismatch observed at the same evaluation.
new: - A `tolerances`/residual key-set mismatch observed at the setup guess evaluation, and a `check_tolerances`/check key-set mismatch observed at the same evaluation.

added: - A residual or check return whose fields are not real scalars, observed at that evaluation too.
# F52, `:field_types` from `_check_equations`.

old: The error carries the offending field with the names or types in hand, collected, and the read set's own `ReadResolution` values beside it (§14.4, D-406).
new: The error carries the offending field with the names or types in hand, collected. The read set's own refusals ride beside it, `ReadResolution` and the path walk's `PathResolution` (§14.4, D-406).
tag: R
ruling: R9
note: F52's wording for the read set's refusals.

old: A permuted spelling is none of these (§14.7).

old: A throw inside the commit's boundary zero is a third case, and neither of those.

old: It is model code failing.

old: It propagates out of `trim!` as the commit's `StepError`.
new: The throw propagates out of `trim!` as the commit's `StepError`, and no report is returned for that solve (D-224).
tag: R
ruling: R7
newcites: D-224
note: q24 row 629. D-224 Position: "`trim!` does not catch the `StepError` a commit-time throw raises out of its `init!`. The throw propagates, ... and no `TrimReport` is returned for that solve." The two clauses join so the bold and its citation share a sentence.

old: The simulation is left `built` (§13.4, D-223), and no report is returned for that solve (D-224).
new: The simulation is left `built` (§13.4, D-223).
tag: F
newcites: §13.4 D-223 D-224
note: the no-report clause and D-224 joined the sentence before, in the same paragraph.

old: An empty problem is none of them either.

old: `TrimProblem``(guess = (;), …)` is legal, not `TrimProblemInvalid`.
new: `TrimProblem(guess = (;), …)` is legal, not `TrimProblemInvalid` (D-156).
tag: R
ruling: R7
newcites: D-156
note: q24 row 630. D-156 Position, "Zero decision variables: `TrimProblem(guess = (;))` bypasses the solver"; Rejected, "`TrimProblemInvalid` on an empty guess". The late `TrimProblem` link goes (F67): unit F links it at 12057. The two code spans join into one.

old: With zero decision variables the solver is bypassed outright.

old: There is nothing to pack, no seeded activation and no backend call.

old: The service simply evaluates the residuals once at the baseline.
new: The service simply evaluates the residuals once at `override(baseline, condition((;)))`, the baseline with whatever the problem's condition sets.
tag: R
ruling: R9
note: F82 (`src/trim.jl` 481). The late baseline link goes (F67): unit F links it at 12065.

old: The ordinary box test decides `converged`, and the commit runs as usual.

old: The degenerate problem is the "is this operating point an equilibrium?" probe.
new: The empty problem asks "is this operating point an equilibrium?"
note: step 5 P2-13 and P2-14: one name for the problem, and 'probe' no longer takes a third sense in §14.8

old: It evaluates this condition's equations and reports, which is useful in its own right and free.
new: It evaluates this condition's equations and reports, which is useful in its own right and costs no solve.
tag: R
ruling: B16
note: B16 (rulings.md, correction 3): the empty problem costs one residual evaluation (src/trim.jl 481-485), so "free" becomes "costs no solve"; D-156 says only "useful in its own right".

old: #### The AD obligation, scoped
new: #### The AD obligation
tag: R
ruling: R8
note: M56.

old: The default formulation requires `Dual` genericity of exactly the continuous output-stage chains and `x_deriv`, plus the user's assignment and residual math.
new: The default formulation requires `Dual` genericity of exactly the continuous output-stage chains and `x_deriv`, plus the user's assignment and residual math (D-070).
tag: R
ruling: R7
newcites: D-070
note: q24 row 632. D-070 bullet 4: "The AD obligation is scoped to continuous stages, `f` and user assignment/residual math, the discrete tier frozen-exact".

old: The discrete tier's stages and `s_update`, and the event system's guards and handlers, never see a `Dual`.
note: the tier link goes (F67, a duplicate of unit F's 12183).

old: They are frozen constants with zero partials, semantically exact (§8.2).

old: This is not a new obligation.

old: It is the same activation linearization is defined on.

old: AD-readiness is also a build-checked property.

old: The Dual probe detonates pinned intermediates with a culprit-naming `InexactError`, and `build(world; activations)` puts it in CI.
new: A pinned intermediate (a value held at `Float64` inside authored continuous math) makes the Dual probe (the build's single evaluation of a user function) fail with a culprit-naming `MethodError` or `InexactError` (D-307). `build(world; activations)` puts the probe in CI (D-280).
tag: R
ruling: R9
newcites: D-307 D-280
note: F77, D-307 Rationale: "fails at the offending line with a `MethodError` or an `InexactError`". D-280 (H85): "The repository's test suite builds a `Dual` activation of every component, with `build(world; activations = ...)`". The gloss follows D-307's "`Float64`-pinned intermediates".; step 6b finding 1: probe linked at its first use in §14.8 with the glossary's gloss

added: (a value held at `Float64` inside authored continuous math)

old: The robustness comes from enforcement, not hope.

old: C172 migration audit (one afternoon):
new: A migration audit of Flight.jl's Cessna 172 model against this obligation took one afternoon.
tag: R
ruling: R15
newcites: D-070
note: verify, "migration" kept and D-070 moved to the findings sentence in the same paragraph. R12 and R15. Owner checked at `~/.julia/dev/Flight.jl/lib/FlightApps/src/c172/c172.jl`. D-070 bullet 5: "The C172 audit is Interpolations tables (prefer cubic knots), saturation rank-deficiency (LM-tolerated, reported), gear zero airborne." "against this obligation" names the audit's subject, `migration_outline.md`'s "the C172 AD audit for trim".; step 5 P2-11: the second introduction in §14.8 drops (`c172.jl`); R15's 'Flight.jl's Cessna 172 model' stays

added: Its findings on tables and saturations follow (D-070), and its two Flight.jl-only findings, on the landing gear and the `norm`-at-zero guards, are in the `migration_outline.md` companion.
# R15's one-clause pointer, beside the clause introducing the two kept bullets.

old: - `Interpolations.jl` tables (propeller coefficient maps, engine maps) must accept generic scalars.
note: R15 keeps it. Flight.jl's tables checked at `lib/FlightPhysics/src/propellers.jl` 266-270 and `piston.jl` 84, 102 (`extrapolate(scale(interpolate(..., BSpline(Linear())), ...))`).

old: They do.

old: A call `itp(x::Dual)` works through the `BSpline`/`scale`/`extrapolate` compositions in Flight.jl's tables.

old: But prefer cubic knots over linear where partials matter, since linear knots make Jacobian entries piecewise-constant.
new: Prefer cubic knots over linear where partials matter, though, since linear knots make Jacobian elements piecewise-constant.
note: step 5 P2-27: bare *entry* becomes 'elements'

old: That is no regression against finite differences (D-307).

old: A manual chain rule via `Interpolations.gradient` is the escape hatch for anything exotic, and the pattern for wrapping non-Julia black boxes (§14.10, D-266).

old: - In-model saturations (actuator limits, idle/FRC clamps) zero Jacobian columns when active.
note: R15 keeps it.

added: FRC is the friction constraint compensator of FlightPhysics' piston engine (`piston.jl`).
# verify, FRC glossed; checked at `~/.julia/dev/Flight.jl/lib/FlightPhysics/src/piston.jl` 229 (`frc::PIVector{1} #friction constraint compensator`).

old: LM damping tolerates the rank deficiency, and the report names the saturated variable (D-070).
new: LM damping tolerates the rank deficiency (D-070). The report's `saturated` list names a decision only at its own bound, so an in-model saturation shows in the Jacobian's zero columns rather than in the report.
tag: R
ruling: B12
note: B12 (rulings.md, correction 1): `_saturated` (src/trim.jl 588-596) compares each decision with its own bounds only, so "the report names the saturated variable" is cut as false of an in-model saturation; its replacement states what the list holds. "LM damping tolerates the rank deficiency (D-070)" stands. Track 2 annotates D-070 bullet 5 (B59).

old: Cruise trim leaves those saturations inactive.

old: - The landing gear is never evaluated off-zero airborne.
new: The landing gear is never evaluated off-zero airborne.
where: units/G/companion_addition.md
tag: R
ruling: R15
note: moved to `migration_outline.md`, below its table.

old: - `norm`-at-zero guards are already in place (e5efb3a).
new: The `norm`-at-zero guards are already in place.
where: units/G/companion_addition.md
tag: R
ruling: R15
note: moved; R12 drops the Flight.jl commit hash.

old: The fallback is per problem, through one `backend =` keyword.
new: The derivative-free fallback would be chosen per call, through the one `backend =` keyword.
tag: R
ruling: R10
note: R10, the unbuilt fallback in the conditional; F73 (R9), `backend` is a `trim!` keyword, so the choice is per call.

old: ### 14.9 Mounting: problems as relocatable values
tag: X

added: This section treats a `TrimProblem` (the closed nine-field value a trim solves) as a relocatable value.
# R8/M60 context paragraph. TrimProblem's first-use link and gloss in §14.9, from the glossary's "the closed nine-field value"; "relocatable values" is the section title's.

added: Mounting (relocating a whole problem or tap set to a prefix) is the work of `at`, the scoping combinator.
# mounting's and `at`'s first-use links and glosses, the glossary's words ("relocating a whole problem or tap set with `at(prefix, …)`", "the scoping combinator").

added: The section says what a problem is, then how `at` lifts one, how a mounted read set and mounted input entries resolve, why a problem never authors the environment, and how worlds, thin rigs (worlds holding only the aircraft and its environment) and swarms use the lift.
# R8: the parts sentence.

old: What a `TrimProblem` is. It is not a condition but an implicitly specified condition.
new: A `TrimProblem` is not a condition but an implicitly specified condition (D-071).
tag: R
ruling: R7
newcites: D-071
note: R8 (M60): the bold label becomes the topic sentence. q24 row 641; D-071 Position: "A `TrimProblem` is an implicitly specified condition — a condition-valued function over decisions plus pinning equations, made explicit by solving and committed by initializing with the solved condition — which unifies the services as condition-algebra clients." The bold on the term goes; the headline clause takes it.

added: A condition is the datum that says "set this build to this state".
# condition's first-use gloss as its own sentence, the glossary's words; the topic sentence carries the bold.

old: `condition` is a condition-valued function over the decision space.

old: `reads`/`residuals` are the equations that pin the free variables down.

old: `guess`/`bounds` say where to search.
new: `guess`, `lower` and `upper` say where to search.
tag: R
ruling: R9
note: F61, the fields are `lower` and `upper`.

old: Solving makes the implicit condition explicit.

old: The commit is then literally an init, `override(baseline, condition(d))` through boundary zero (the initialization boundary: the ordinary macro-sequence with an empty integrate).
new: The commit is then literally an init, `override(baseline, condition(d))` through boundary zero (the initialization boundary, the ordinary macro-sequence with an empty integrate).
note: the colon inside the gloss becomes a comma.

added: `override` is the ordered, asymmetric layering combinator, in which the patch wins on a shared leaf.
# verify (F67), override's first-use link in §14.9; its uses sit in code, so the gloss takes a sentence. The glossary's words: "the ordered, asymmetric layering combinator. On a shared leaf the patch wins".

old: The services unify as clients of one condition algebra.

old: `init!` applies an explicit condition, and `trim!` searches a family for the member satisfying its equations.

old: `at` lifts a problem field by field, and each field falls in one of three cases.
new: `at` lifts a problem field by field, and each field falls in one of three cases (D-071, D-277).
tag: R
ruling: R7
newcites: D-071 D-277
note: q24 row 645. D-071 bullet 1, cited for its standing clauses ("the condition is post-composed ... while guess, bounds and residuals pass through path-free"); its read-set clause is amended by D-277 (annotation 2026-09-30). D-277 bullet 4: "`at` on a `TrimProblem` lifts field by field". The bold label becomes a headline clause.

old: The `condition` field is condition-producing (path-relative), so the lift post-composes it.

old: The `reads` field is a read set, and the lift prepends the prefix to the set's mount chain.
new: The `reads` field is a read set, and the lift prepends the prefix to the set's mount chain (the prefixes it is mounted under, root first).
tag: R
ruling: R9
note: F68, the mount chain glossed at its first use.

added: (the prefixes it is mounted under, root first)

added: A read set is a `Reads` value.
# step 5 P2-29: introduces Reads, the type D-277's next ruling names

old: Every other field is path-free and passes through.

old: The rule that residual math sees only the gathered NamedTuple (§14.7) pays off here.
new: The rule that residual math sees only the gathered NamedTuple (§14.7) is what makes the residuals path-free.
note: "pays off here" unwound into what the rule does for the lift; the sketch's `residuals = p.residuals, #path-free`.

old: `at(prefix::String, p::TrimProblem) = TrimProblem( guess = p.guess, #path-free: pass through lower = p.lower, upper = p.upper, condition = d -> at(prefix, p.condition(d)), #post-compose: wrap each returned tree reads = at(prefix, p.reads), #inert selector data: the prefix joins the read set's mount chain residuals = p.residuals, #path-free: pass through tolerances = p.tolerances, checks = p.checks, check_tolerances = p.check_tolerances)`
new: `at(prefix::String, p::TrimProblem) = TrimProblem( guess = p.guess, #path-free: pass through lower = p.lower, upper = p.upper, condition = d -> at(prefix, p.condition(d)), #post-compose: wrap each returned tree reads = at(prefix, p.reads), #inert selector data: the prefix is prepended to the read set's mount chain residuals = p.residuals, #path-free: pass through tolerances = p.tolerances, checks = p.checks, check_tolerances = p.check_tolerances)`
tag: R
ruling: B7
note: verbatim and keyword-form, as D-188 rules, but for B7's one comment edit: the prefix is prepended to the mount chain and joins nothing (D-277).

old: The condition side needs nothing new at resolution.

old: The flattening accumulator of §14.3 enters each `Scoped` wrapper and prefixes every entry below it.
new: The flattening accumulator of §14.3 enters each `Scoped` wrapper (the node `at` builds over a condition node) and prefixes every condition entry below it.
tag: R
ruling: R13
note: bare *entry* becomes "condition entry".; step 5 P2-29: Scoped glossed; checked src/conditions.jl 28 and 94

old: Rule. A read set carries its mount chain as data.
new: A read set carries its mount chain as data (D-277).
tag: R
ruling: R7
newcites: D-277
note: q24 row 650; the **Rule.** label goes. D-277 Position: "`at(prefix, read_set)` prepends the prefix to the read set's own chain of prefixes and joins nothing; `Reads` is not a condition node and `Scoped` never wraps one." The two semicolon halves are read as one ruling, the second saying where the chain is not kept; see rulings.md.

old: `at(prefix, read_set)` prepends the prefix to that chain and joins nothing.
new: `at(prefix, read_set)` prepends the prefix to the read set's mount chain and joins nothing.
note: step 6b finding 2: 'that chain' named, the added Reads sentence standing between it and its antecedent

old: A `Reads` value is no condition node, so `Scoped` never wraps one.
new: A `Reads` value is no condition node, so `Scoped` never wraps one (D-277).
tag: R
ruling: R28
newcites: D-277
note: R28, the second ruling of D-277's first Position sentence, bold once; the frozen spec bolds it nowhere else.

old: Resolution walks the chain from the root, each prefix from the level the previous one reached (§13.3).
new: Resolution walks the chain from the root, each prefix from the level the previous one reached (§13.3, D-277).
tag: R
ruling: R7
newcites: §13.3 D-277
note: D-277 Position's second sentence, "Resolution walks the chain from the root, each prefix from the level the previous one reached, and rewrites every selector into the root-authored selector it denotes before the ordinary resolvers run". Bullets 1-3 elaborate it and stay plain.

old: It then rebases every selector (one of the closed family of deferred reads) to the root before the selector resolves.

old: A path selector's path is joined to the mount (`"vehicle/dynamics"` → `"wing/vehicle/dynamics"`).

old: `get_input` names an input face (the name a port wears on its component's boundary) of the mount level.
note: component's link moves here, its first use in §14.9 (F67), with no gloss of its own inside face's gloss.

old: It follows the export chain to the root input it lands on.
new: It follows the export chain to the root input it lands on (the root component's own input face).

added: (the root component's own input face)
# root input's first-use gloss, the glossary's words.

old: `get_face` names an output face of the mount level and reads its producer's port (D-277).

old: A refusal spells the selector as authored and names the mount.
new: A refusal spells the selector as authored and names the mount (D-277).
tag: R
ruling: R7
newcites: D-277
note: D-277 bullet 5, "A refusal spells the selector as authored and names the mount." A separate bullet, so a bold of its own; it opens the refusals' paragraph.

old: `at` refuses an empty prefix on a read set, as it does on a condition node (§14.2), and raises `ReadSetMisuse`.
note: plain; D-278's bold is §14.2's (R7). Kind named (R14).

old: A problem's lift and a tap set's lift reach that refusal through `at` on their read sets (D-278).

old: Root input entries authored in the aircraft's face vocabulary resolve through the export chain from the mount point (`throttle` at `"wing"` → root input `"wing.throttle"`).
new: Input entries authored in the aircraft's face vocabulary resolve through the export chain from the mount point (D-071). For a wingman aircraft mounted at `"wing"`, the input entry `throttle` resolves to root input `"wing.throttle"`.
tag: R
ruling: R7
newcites: D-071
note: verify, the clause says the wing is a second aircraft. q24 row 657, D-071 bullet 2, cited for its standing clause ("Slots resolve through export chains from the mount point"; "named by the build" is stale, F54). R13: "Root input entries" becomes "Input entries". The example becomes its own sentence so the citation sits outside it. R6: §14.9 keeps the from-the-mount consequence, §14.2 the rule.

old: An unexported face fails resolution by name, and correctly so.
new: An unexported face fails resolution by name, and correctly so (§14.2).
tag: C
newcites: §14.2
note: R6, the pointer to §14.2, home of the `u` payload's export chain (old 11435-11442, "a `u` payload names faces of the authoring level").

old: An internally wired input (a scenario component driving the wingman's throttle) is untrimmable from outside, and the build says so.
new: An internally wired input (a scenario component driving the wingman's throttle) is untrimmable from outside. Resolution refuses it by name, with the producer that drives it in hand, as `ConditionResolution` for a condition entry and as `ReadResolution` for a `get_input`.
tag: R
ruling: R9
note: F54, the refusal is resolution's (`src/conditions.jl` 444-455, `src/readers.jl` 536-539); R14 and F71 name the kinds, both `:internally_wired`, confirmed in survey 2's part C.

old: The service compiles the scoped condition and reads, and runs the identical loop.

old: It never knows where its paths are mounted.

old: A problem never authors the environment.
new: A problem never authors the environment (D-139).
tag: R
ruling: R7
newcites: D-139
note: q24 row 661, Rationale only: D-139 Rationale, "**Trim problems never author the environment** (§14.7, §14.9)". The bold lead-in becomes a cited headline.

old: The environment is the world's and the `baseline`'s business.
new: The environment is the business of the world and of the `baseline` (the full-coverage condition `trim!` takes as a keyword).
note: baseline's first-use link in §14.9 (its earlier uses sit in code), with a gloss from the glossary ("a full-coverage condition function ... also the `baseline` keyword `init!`/`trim!` take").

added: (the full-coverage condition `trim!` takes as a keyword)

old: In a full world it is a sibling component's root inputs.
note: component's link moved to its first use (F67).

old: In a thin rig it is a root input holding an isbits handle, or a constant source holding a bulk-data one (D-364).
new: In a thin rig it is a root input holding an isbits handle (an immutable query object carried on an ordinary port). In a thin rig it can also be a constant source (a library component publishing a value its instance holds) holding a bulk-data handle (D-364).
newcites: D-364
note: verify, the constant source stays tied to the thin rig. Split in two so each gloss has its sentence. Field handle takes its first-use link with the glossary's words; constant source takes its gloss at its first use, moved from old 12465 (F67).

added: (an immutable query object carried on an ordinary port)

old: The problem receives its handles through the user parameter record (§14.7), and only queries them.

old: Why. The reason is the resolution rule just stated.
new: The reason is the resolution rule stated above.
tag: R
ruling: R8
note: M60, the **Why.** label goes.

old: A condition entry naming an internally wired input fails by name, correctly.

old: A problem writing an environment face would therefore be applicable only to those rigs where that face happens to be unconnected.

old: The relocatability this section exists to guarantee would be lost.

old: The world wrapper dissolves.
new: The world wrapper dissolves (D-071).
tag: R
ruling: R7
newcites: D-071
note: q24 row 665, D-071 bullet 3, "The world-level `f_init!` wrapper dissolves into the `baseline` condition: method nesting becomes value layering." The bold label becomes the cited headline.

old: Flight.jl's `f_init!(::Model{<:SimpleWorld})` (initialize environment, then call the aircraft's trim) has no successor method.
new: FlightPhysics' world initializer, its method of FlightCore's `f_init!` on a FlightCore `Model{<:SimpleWorld}` (initialize environment, then call the aircraft's trim), has no successor method.
note: R12, owner already named; checked at `~/.julia/dev/Flight.jl/lib/FlightPhysics/src/world.jl` 48-56 (FlightPhysics is a Flight.jl package).; step 5 P2-31: owners named per piece, world.jl 49 (FlightPhysics) and lib/FlightCore/src/modeling.jl (f_init!, Model)

old: The environment, the other aircraft and all root inputs are covered by the `baseline` condition (§14.6), applied once at setup.

old: The commit is `override(baseline, at(mount, condition(d)))`.

old: Method nesting became value layering.

old: "Aircraft as root" is a thin world.
new: "Aircraft as root" is a thin rig.
note: the bold lead-in goes plain, a topic sentence; D-139 Rationale's "softened from doctrine to default" stays uncited, as in the old text.; step 5 P2-30: one name, D-364's 'thin rig'

old: By default the aircraft is not literally the root.
new: They need one because by default the aircraft is not literally the root.
note: the old order was reason, then "Design tasks therefore use" the rig; the rule now comes first, the reason after, and the causal link keeps its direction.

old: Its environment inputs (§4.4 function-valued signals) are wired from provider components.
new: Its environment inputs are function-valued signals (§4.4), wired from provider components.
note: the citation leaves the gloss's parentheses.

old: Design tasks therefore use a shipped rig, `design_world(ac)` = aircraft + `SimpleAtmosphere(wind = NoWind())` + `HorizontalTerrain`.
new: Design tasks use the rig this design records, `design_world(ac)` (D-071).
tag: R
ruling: R7 B11
newcites: D-071
note: B11 and R26: no source holds a `design_world`, so "shipped" goes, as in §14.10's gloss; the claim that design tasks use `design_world(ac)` stands. q24 row 668, D-071 bullet 4, "`design_world(ac)` promotes today's ad-hoc linearize models to a shipped rig". `design_world` takes its first-use link (F67); its gloss is the next sentences' composition.

old: `design_world(ac)` = aircraft + `SimpleAtmosphere(wind = NoWind())` + `HorizontalTerrain`.
new: The rig is `design_world(ac)` = aircraft + `SimpleAtmosphere(wind = NoWind())` + `HorizontalTerrain`, where `SimpleAtmosphere` and `NoWind` are FlightPhysics' atmosphere types.
tag: R
ruling: R29
note: R29 and R12; `HorizontalTerrain` named with no owner. Checked at `~/.julia/dev/Flight.jl/lib/FlightPhysics/src/atmosphere.jl` 153 (`NoWind`) and 260 (`SimpleAtmosphere`). No `HorizontalTerrain` and no `design_world` exist in Flight.jl, so neither takes an owner; see rulings.md.

old: That rig is today's ad-hoc models inside `linearize` promoted to a named artifact.
new: `design_world` promotes the ad-hoc atmosphere and terrain FlightCore `Model`s inside Flight.jl's `linearize` to a named artifact.
tag: R
ruling: R12
note: verify, FlightCore's `Model` (`lib/FlightCore/src/modeling.jl` 89) named so it does not read as the spec's. "today's" becomes Flight.jl's. Checked at `~/.julia/dev/Flight.jl/lib/FlightPhysics/src/aircraftbase.jl` 291-299: `linearize` builds `Model(SimpleAtmosphere(; wind = NoWind()))` and `Model(UniformTerrain())`. Flight.jl's own `Model` keeps its spelling.

old: There is one mechanism.

old: The "root" case is the shallowest world, and the trim problem mounts at `"aircraft"` like anywhere else.

old: Leaving an environment face unconnected is legal by construction, though, for an isbits handle.
new: Leaving an environment face unconnected is legal by construction, though, for an isbits handle (D-364).
tag: C
newcites: D-364
note: verify (V159). D-364 Position: "A thin rig holds its environment as a root input only when the handle is isbits."

old: The face becomes an ordinary root input holding the handle value, written by the `baseline` like any other root input.
note: the bold on "value" becomes italic.

old: That is the test-rig idiom.

old: It is the function-valued sibling of a constant source (a library component publishing a value its instance holds), with zero ceremony for a frozen environment.
new: It is the function-valued sibling of a constant source, with zero ceremony for a frozen environment.
note: the gloss moved to the first use (F67), above.

old: A handle that references bulk data is never a root input. The rig wires a constant source holding it (D-364).
new: A handle that references bulk data is never a root input, and the rig wires a constant source holding it (D-364).
tag: R
ruling: R7
note: q24 row 670, trimmed to its headline clause, the two sentences joined so the bold and D-364 share one. D-364 Position: "A handle that references bulk data enters the rig through a constant source holding it, never as a root input."

old: Root inputs are traced and checkpointed by value,
new: Root inputs are traced and checkpointed by value,
tag: R
ruling: R30
note: R30, the old phrase stays in the pointer sentence.

old: and such a handle can be neither recorded faithfully nor kept frozen when a writer supplies it (§4.4, D-237).
new: A bulk-data handle can be neither recorded faithfully that way nor kept frozen in a writer's hands.
where: docs/design/spec.md
tag: M
note: M66, a pointer to §4.4 (H80), which states the reason at Part I's depth (old 975-979: "A root input instead comes from outside the model and is recorded with the run by value. A bulk-data handle can be neither recorded faithfully that way nor kept frozen in a writer's hands."). §14.9 keeps the pointer below with both citations.

added: and §4.4 states why such a handle cannot be one (D-237).
# M66's pointer, carrying the old sentence's two citations.

old: For design tasks the shipped rig stays `design_world(ac)`.
new: For design tasks the rig stays `design_world(ac)`.
tag: R
ruling: B11
note: B11 cuts "shipped" only. Its fate: the rig's standing is the bold's "the rig this design records" (Design tasks use the rig this design records, `design_world(ac)`). The sentence stays for the one claim the bold lacks: after the test-rig idiom, design tasks still use `design_world(ac)`. It is also the antecedent of "That keeps".

old: That keeps the environment's tunables in the root-input vocabulary that conditions, linearization's input surface and the trace header already speak.
new: That keeps the environment's tunables in the root-input vocabulary that conditions, linearization's input surface and the trace header (the trace's fixed preamble) already speak.

added: (the trace's fixed preamble)
# trace header's first-use gloss, the glossary's words.

old: Swarm doctrine.
new: The swarm doctrine covers trims of several aircraft.
tag: R
ruling: R8
note: M60, the bold label becomes a topic sentence; "swarm doctrine" is a term of art and stays.

old: The service solves one problem at a time.
new: The service solves one problem at a time (D-071).
tag: R
ruling: R7
newcites: D-071
note: q24 row 673, D-071 bullet 5, "A swarm takes one problem per solve — sequential commits, or user-side joint composition".

old: Sequential independent trims (trim lead, commit, trim wing against the committed world) cover weak or one-way coupling.
new: Sequential independent trims (trim the lead aircraft, commit, trim the wingman against the committed world) cover weak or one-way coupling.
note: step 5 P2-33: the lead named in full

old: A joint trim is user-side value composition.

old: Concatenate decision NamedTuples under prefixed names, combine the scoped condition trees, and stack the residuals.

old: If joint trims become routine, a `product(p₁ => "lead", p₂ => "wing")` helper belongs in the §13.7 library.
new: If joint trims become routine, a `product(p₁ => "lead", p₂ => "wing")` helper is the extension recorded for them (D-071).
tag: R
ruling: R9
newcites: D-071
note: F57 (carried). D-071's annotation of 2026-10-19: "the helper is recorded in §14.9. §13.7's library holds components only." q24 row 675 bolds it with D-071 bullet 6, cited for its standing clause ("A `product()` helper is recorded ..., unbuilt").

old: That helper is recorded, not built (a worked-out extension deliberately left unimplemented, its seams named).

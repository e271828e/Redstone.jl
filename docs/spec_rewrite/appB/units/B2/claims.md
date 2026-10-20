# Unit B2 of Appendix B: claims of old.md in order, then additions.

old: Condition algebra (§14.1–§14.6).
new: #### Condition algebra
tag: R
ruling: R4
newcites:
note: R3-01. The bold group lead-in becomes a #### label. Its range citation goes; each entry now cites its own section (§14.2, §14.6).

old: - `set(; x, s, m, u)`.
new: - `set(; x = (;), s = (;), m = (;), u = (;))`.
tag: R
ruling: R1
note: R3-02. Spelled as src/conditions.jl:74 spells it, with each keyword's default.

old: The leaf, a fragment: self-vocabulary payloads at the authoring level.
new: The leaf, a fragment of self-vocabulary payloads at the authoring level (§14.2).
tag: C
newcites: §14.2
note: R3-03. The colon becomes "of". The bullet takes its owning section; the old bullet had only the group's range citation.

old: `u` names faces of that level's contract.
new: A `u` payload names faces of the authoring level's contract (its declared interface).
tag: M
where: homes.md
note: R3-04, class 2, §14.2.

old: - `at(prefix, node)`.
note: R3-05.

old: Scoping. It stores, never applies.
tag: C
newcites: §14.2
note: R3-06. The bullet now cites §14.2, which states it (the Scoped comment, "stores, never applies").

old: It also lifts whole `TrimProblem`s and linearization tap sets (§14.9, §14.10).
new: It also lifts a whole `TrimProblem` (the closed nine-field value a trim solves) and a linearization tap set (§14.2, §14.9, §14.10).
newcites: §14.2 §14.9 §14.10
note: R3-07. Singular for the glossary links; the gloss is §14.9's own words. §14.2 joins the bullet's citations.

old: An empty prefix is refused (§14.2).
new: `at` refuses an empty prefix when it is called (D-278).
tag: M
where: homes.md
note: R3-08, class 2, §14.2.

old: - `combine(nodes...)`.
note: R3-09.

old: Symmetric collection.
new: Symmetric collection. Duplicate leaves error with both origins (§14.2).
tag: C
newcites: §14.2
note: R3-10.

old: Duplicate leaves error with both origins.
new: Duplicate leaves error with both origins (§14.2).
tag: C
newcites: §14.2
note: R3-11.

old: Blending a node with a bare NamedTuple is a directive error method (§14.2).
new: A `combine(::Fragment, ::NamedTuple)`, or any other blend of a condition node with a bare NamedTuple, is an error method. Its message is directive.
tag: M
where: homes.md
note: R3-12, class 2, §14.2.

old: - `override(base, patches...)`.
note: R3-13.

old: Ordered layering.
note: R3-14.

old: The patch wins, and the origin keeps both (§14.6).
note: R3-15.

old: - `condition(comp; kw)`.
note: R3-16.

old: The shipped condition-method idiom.
new: The shipped condition-method idiom (§14.2).
tag: C
newcites: §14.2
note: R3-17. The bullet had no citation of its own; §14.2 states the idiom.

old: Aircraft baselines (`ready_for_taxi(ac)`, `cold_and_dark(ac)`) are its full-coverage instances.
new: Baselines are aircraft-shipped condition functions, layered by `override` (D-068).
tag: R
ruling: R7
where: homes.md
note: R3-18, 2d. Dropped: the baselines are separately named condition functions, not `condition` methods, and the package ships none, so B names none. §14.6 holds the corrected claim.

old: Stopped-sim services (§14).
new: #### Stopped-sim services
tag: R
ruling: R4
newcites:
note: R3-19. The bold lead-in becomes a #### label; its §14 citation goes, each entry citing its own section.

old: - `init!(sim, condition; t0 = 0.0, trace = true, log = true, log_every = 1, log_max = 65536)`.
new: - `init!(sim, condition = set(); t0::Real = 0.0, trace = true, log = true, log_every = 1, log_max = 65536)`.
tag: R
ruling: R8
note: R3-20. src/sim.jl:591 makes the condition optional, `condition = set()`, and types `t0::Real`.

old: `t0` is any real,
new: t0::Real = 0.0
tag: R
ruling: R6
note: R3-21, class 3. The signature now spells it, as src/sim.jl:591 does.

old: held as a `Float64` origin (D-260).
new: held as a `Float64` origin,
newcites: D-260
note: R3-22. Its citations close the sentence, after the trace-header clause. D-260's Position: "The origin `t₀` ... is a `Float64`".

old: Root-input totality is checked pre-write (§14.6).
note: R3-23.

old: Then boundary zero runs
new: Then boundary zero runs at `t0`
newcites: §14.5
note: R3-24, first half. "at `t0`" gives "held as a `Float64` origin" its antecedent after `t0`'s own sentence went into the signature. §14.5's citation follows it.

old: project, sweep, events, the due `s_update` calls, then the first snapshot,
new: project → [sweep → guards → handlers]\ → due `s_update` calls → first snapshot
tag: M
where: homes.md
note: R3-24, middle, class 2, §14.5.

old: and the checkpoint that is the run's trace header (§11.5, §14.5).
new: and the checkpoint that is the run's trace header follows (§11.5, §14.5, D-260).
newcites: §11.5 §14.5
note: R3-24, last part. Kept so the header's `Deployment` and `t₀`, which frozen 7810 cites B for, stay in B with the checkpoint entry's field list. Glossary link on checkpoint.

old: | keyword | default | meaning | owning section | |---|---|---|---|
note: R3-25.

old: | `trace` | `true` | the input trace's plain kill switch | §11.5 |
note: R3-26. Glossary link on trace.

old: | `log` | `true` | the snapshot log's plain kill switch | §11.2 |
note: R3-27. Glossary link on log. B1's draft links snapshot, so B2 does not (rulings.md).

old: | `log_every` | `1` | the log's keep-every-kth decimation | §11.2 |
note: R3-28. Glossary link on decimation.

old: | `log_max` | `65536` | the maximum number of retained snapshots, finite by default with `Inf` the opt-out | §11.2 |
new: | `log_max` | `65536` | the maximum number of retained snapshots, `Inf` the opt-out | §11.2 |
tag: R
ruling: R2
note: R3-29. The meaning cell is cut to nine words. "Finite by default" is the default cell, 65536; §11.2 states it ("finite by default, `Inf` the opt-out").

old: Recording.
note: R3-30.

old: The four keywords configure the run this call builds, with its log and trace (§12.6, D-261);
new: The four keywords configure the run this call builds, with its log and trace (§12.6, D-261).
note: R3-31.

old: `restore!` and `replay!` take the same four.
new: `overlay!`, `restore!` and `replay!` take the same four.
tag: R
ruling: R7, coordinator 2026-10-20
note: R3-32. `overlay!` joins, as R2-55's correction and §12.6's four doors require (frozen 9475, "`overlay!` is the fourth door"); D-429's Position gives it the recording keywords.

old: `log_every` is admissible on the derived artifact only, never on the trace (§11.2, §11.5, D-029).
new: The derived/primary split (D-038) decides why decimation is admissible here and not there.
tag: M
where: homes.md
note: R3-33, class 2, §11.2.

old: When the log fills, the retention stride doubles, so the whole run stays covered at coarsening density.
new: When the log fills, the retention stride doubles, so coverage stays global (D-137, D-368).
tag: M
where: homes.md
note: R3-34, class 2, §11.2.

old: The run's first and terminal snapshots are retained unconditionally and outside the bound (§11.2).
new: The run's first snapshot and its terminal snapshot (§12.4, §13.5) survive any `log_every` and any `log_max`, and they do not count against the bound.
tag: M
where: homes.md
note: R3-35, class 2, §11.2.

old: All four are view policies, not trajectory-determining.
new: And `log_max` is a view policy, not a trajectory-determining one (D-137, D-368). Like `log` and `log_every` it stays out of the trace header's `Deployment`
tag: R
ruling: R7
where: homes.md
note: R3-36, 2d. Dropped: `log`, `log_every` and `log_max` are the view policies; `trace` is the primary record's switch (§11.5), not a view's.

old: Replay neither records nor compares them.
new: and replay neither records nor compares it (§11.5, §12.4, §12.7).
tag: R
ruling: R7
where: homes.md
note: R3-37, 2d. Dropped with R3-36: §11.2 says it of the three view policies, never of `trace`.

old: - `trim!(sim, problem; baseline, t0 = 0.0, backend) → TrimReport`.
new: - `trim!(sim, problem; baseline, t0::Real = 0.0, backend = LevenbergMarquardt()) → TrimReport`.
tag: R
ruling: R7, coordinator 2026-10-20
note: R3-38, 2d. The backend's default, as §14.8 and src/sim.jl:811 spell it; `t0::Real` as src/sim.jl:812 spells it (coordinator).

old: Nonlinear least squares on the packed residuals with exact Dual Jacobians, against the problem's own `tolerances`.
new: It solves against the problem's own `tolerances`, by default as nonlinear least squares on the packed residuals with exact Dual Jacobians (§14.7).
tag: R
ruling: R7, coordinator 2026-10-20
newcites: §14.7
note: R3-39, 2d. Least squares with exact Jacobians is the default (§14.7, "The default is nonlinear least squares on r(d) with exact AD Jacobians"); the backend seam admits others. "By default" scopes the method only; the per-residual box test against `tolerances` holds for every backend (§14.8, D-150; verifier C-041).

old: `residuals(reads, d) → NamedTuple` is packed in `tolerances`' field order, as decisions pack in `guess`'s.
new: The service packs residuals and tolerances to the solver's vector by field order. The order is `tolerances`' field order, the declared side again, canonical for the residuals.
tag: M
where: homes.md
note: R3-40, class 2, §14.7. `residuals` is a TrimProblem field, not a function (signatures.tsv row 117).

old: Names pair, and the order is the declared side's.
new: Names pair, and order never does.
tag: M
where: homes.md
note: R3-41, class 2, §14.7.

old: The problem itself closes at nine fields (§14.7).
new: the closed nine-field value a trim solves
tag: C
newcites: §14.9
note: R3-42. Kept as the gloss on the `TrimProblem` link in `at`'s entry, in §14.9's words. §14.7 states "closed" but no count; §14.9 states both, so it replaces §14.7.

old: Setup and commit both carry the root-input-totality check (§14.6).
new: They are `init!`, trim's setup application to freshly allocated scratch stores, trim's commit through boundary zero (§14.8)
tag: M
where: homes.md
note: R3-43, class 2, §14.6.

old: The commit is `init!` with `override(baseline, condition(solution))`,
new: The commit is `init!` with `override(baseline, condition(solution))`,
newcites: §14.8
note: R3-44, first half. Its home is §14.8 (the survey notes §12.6 carried only the recorders), so §14.8 follows it.

old: boundary zero anchored at `t0` and the recorders built anew (§12.6).
new: The recorders (the trace and the log jointly) restart with the run they record
tag: M
where: homes.md
note: R3-44, second half, class 2, §12.6; the commit through boundary zero is §14.8's.

old: On a `Model{Float64}`, `trim!(model, problem; …)` is the same service, its commit the model's `init!` (D-319).
new: Each form of `trim!` commits through the matching `init!`, the model's or the simulation's (§14.8).
tag: M
where: homes.md
note: R3-45, class 2, §14.5. B1's `Model` block lists `trim!(model, …)`.

old: `converged` is the service's per-residual box test at the backend's returned point.
new: That is the per-residual box test (§14.7) in its own physical units, evaluated by the service at the backend's returned point.
tag: M
where: homes.md
note: R3-46, class 2, §14.8.

old: It is backend-independent and the commit's gate,
new: gated on the report's `converged` (§14.8).
tag: R
ruling: coordinator 2026-10-20
note: R3-47, first part. `converged` stays on B as the report's field the commit gates on (§14.8, 12325: "That verdict, and nothing else, gates the commit and fills `TrimReport.converged`"). Backend independence stays at its home ("The convergence verdict is the service's, uniformly (D-150)").

old: and the backend's status and counts are recorded diagnostically.
new: The backend's returned `status` is recorded in the report as diagnostic data, and it is authoritative over nothing.
tag: M
where: homes.md
note: R3-47, last part, class 2, §14.8.

old: The backend seam is a pinned one-method signature,
new: The backend seam, a pinned one-method signature (§14.8).
tag: C
newcites: §14.8
note: R3-48. The `solve` signature is a public name, so it becomes its own entry with this gloss. Glossary link on seam.

old: `solve(backend, eval!, d0, lower, upper, tol) → (; d, status, n_evaluations, n_iterations)`.
new: - `solve(backend, eval!, d0, lower, upper, tol) → (; d, status, n_evaluations, n_iterations)`.
note: R3-49.

old: The in-place `eval!(r, J, d)` fills `J` only when it is not `nothing`, the packed vectors are in the declared orders, and `status` is an open `Symbol` recorded verbatim.
new: `eval!(r, J, d)` is in-place and always fills `r`, the residual vector packed in `tolerances`' field order. It fills `J` exactly when `J !== nothing`.
tag: M
where: homes.md
note: R3-50, class 2, §14.8.

old: Non-convergence reports, never throws (§14.8).
new: Non-convergence never throws (D-070). It is an expected outcome, not broken machinery (§13.5).
tag: M
where: homes.md
note: R3-51, class 2, §14.8.

old: - `checkpoint(sim) → Checkpoint`.
note: R3-52.

old: The `Model`'s state at a frame top
new: A checkpoint holds the `Model`'s state at a frame top,
tag: C
newcites: §12.6 D-274
note: R3-53, first part. §12.6 and D-274's Position ("A `Checkpoint{T}` is the executor's state at a frame top, taken by `checkpoint(sim)`") carry it.

old: beside the run's two counters, the frame index and the boundary ordinal.
new: beside the run's two counters, the frame index and the boundary ordinal (§12.6, D-274).
tag: C
newcites: §12.6 D-274
note: R3-53, last part.

old: `t₀`, the fingerprint and the deployment.
new: with `t₀`, the fingerprint and the deployment,
note: R3-54, last part, kept for frozen 7810, which cites B for the header's `Deployment` and `t₀`.

old: The state is a `ModelState`, as `checkpoint(model)` reads it, holding the flat buffer, the `s` and `m` stores, the whole signal table, the guard priors, `t` and
new: `checkpoint(model)` returns the state alone, a `ModelState`. It holds the flat buffer, the `s` and `m` stores, the whole signal table, the guard priors, `t`, `t₀`, the fingerprint (the structural layout) and the deployment.
tag: M
where: homes.md
note: R3-54, class 2, §12.6.

old: Legal in `initialized` and `stopped`, refused after a `t` stop and after an abandoned frame (`CheckpointMidFrame`).
new: It is a stopped-sim service, legal in `initialized` and `stopped` (§14), and refused as `ServiceLifecycle` in any other state. It is refused wherever the executor is not at the rest a published frame top leaves (`CheckpointMidFrame`, Appendix C).
tag: M
where: homes.md
note: R3-55, class 2, §12.6.

old: A checkpoint is not a condition and has no algebra (§14.1, D-274, D-319).
new: is a checkpoint (the `Model`'s state at a frame top as one value), not a condition. It enters no condition expression and yields none (D-274).
tag: M
where: homes.md
note: R3-56, class 2, §14.1. The old D-319 citation did not carry it (rulings.md).

old: - `restore!(sim, cp; trace = true, log = true, log_every = 1, log_max = 65536)`.
note: R3-57.

old: A door beside `init!` and `replay!`, legal where `init!` is.
new: A door beside `init!`, `overlay!` and `replay!`, legal where `init!` is.
tag: R
ruling: R7, coordinator 2026-10-20
note: R3-58. §12.6 names four doors; `overlay!` is the fourth (frozen 9475).

old: It checks the checkpoint's fingerprint and deployment (`CheckpointMismatch`) and its `t` against its grid (`CheckpointMidFrame`).
tag: R
ruling: coordinator 2026-10-20
note: R3-59. Kept so the kind names stay on B (D-226: a name is public by standing on B). The bullet's §12.6 homes it (9585).

old: It copies the state back, builds a fresh run with the checkpoint as its trace header and publishes one snapshot at the checkpoint's `t`.
new: It then copies the state back, opens a fresh run with the checkpoint as its trace header, and publishes one snapshot at the checkpoint's `t`.
tag: M
where: homes.md
note: R3-60, class 2, §12.6.

old: It runs no boundary zero, and the boundary ordinal continues.
new: `restore!` is a door like `init!`, and it runs no boundary zero.
tag: M
where: homes.md
note: R3-61, class 2, §12.6; the ordinal continuing is "The boundary ordinal continues, being the trajectory's (§12.3, D-274)".

old: The warm restart is `checkpoint` → `restore!` → `run!` (§12.6, D-274).
note: R3-62.

old: `restore!(sim, model_state; kw...)`
new: - `restore!(sim, model_state; trace = true, log = true, log_every = 1, log_max = 65536)`.
tag: R
ruling: R1
note: R3-63. Spelled as src/sim.jl:779 spells it, every keyword with its default, and set as its own entry.

old: takes a `ModelState` prepared on a standalone model,
new: Takes a `ModelState` prepared on a standalone model,
note: R3-64, first half.

old: with the same keywords and the same fingerprint and deployment check.
new: with the same fingerprint and deployment check (`CheckpointMismatch`).
tag: R
ruling: coordinator 2026-10-20
note: R3-64, second half. The keywords now show in the signature. `CheckpointMismatch` names the check's kind on B, as §12.6 does for this form ("makes the same check", 9598, and the kind at 9585).

old: A state off the grid is `CheckpointMidFrame`.
tag: R
ruling: coordinator 2026-10-20
note: R3-65. Kept so the kind name stays on B; the bullet's §12.6 homes it (9601).

old: It opens a fresh trajectory at the state's frame, and the restored boundary publishes under ordinal 0 (§9.2, §12.6, D-319).
note: R3-66.

old: - `overlay!(sim, condition; trace = true, log = true, log_every = 1, log_max = 65536)`.
new: - `overlay!(sim, condition = set(); trace = true, log = true, log_every = 1, log_max = 65536)`.
tag: R
ruling: R8
note: R3-67. src/sim.jl:690 makes the condition optional.

old: The state what-if.
note: R3-68.

old: The condition's stores are written onto a stopped run's own,
note: R3-69, first part.

old: the clock, the lattice and the priors are kept,
new: Every other store, the clock, the sampling lattice and the guard priors (each event's stored predicate sample from the previous boundary) are kept.
tag: M
where: homes.md
note: R3-69, second part, class 2, §12.6.

old: the overlaid state settles with no discrete output stage and no update,
new: The overlaid state settles through boundary zero's tail with the discrete output stages and the `s_update` calls left out (§14.5, D-429).
tag: M
where: homes.md
note: R3-70, class 2, §12.6.

old: and a fresh run opens whose header is the checkpoint taken after the settling.
new: and a fresh run opens whose header is the checkpoint taken after the settling (§12.6, §14.1, D-429).
newcites: §12.6 §14.1 D-429
note: R3-71. The bullet's citations, which closed R3-73, now follow it.

old: A partial store entry merges onto the current store, and a root-input entry writes its cell with no totality asked.
new: A partial store entry merges onto the current store (§14.1), and a root-input entry writes the root input's cell. No root-input totality is asked
tag: M
where: homes.md
note: R3-72, class 2, §12.6.

old: Legal where `checkpoint` is, with the four recording keywords (§12.6, §14.1, D-429).
new: The door is legal where `checkpoint` is, `initialized` or `stopped` with the clock on a published frame top
tag: M
where: homes.md
note: R3-73, class 2, §12.6. The four keywords show in the signature.

old: - `linearize(sim, taps; about, t0, width = 8) → Linearization`.
new: - `linearize(sim, taps; about = nothing, t0 = nothing, width = 8) → Linearization`.
tag: R
ruling: R8
note: R3-74. src/sim.jl:834 spells `about = nothing, t0 = nothing`, as D-319 does. `width`'s default is LINEARIZE_WIDTH, 8 (src/linearize.jl:61).

old: A pure query,
new: A pure query.
note: R3-75, first part.

old: seeded Dual passes on scratch, `width` directions per pass.
new: It works only on scratch buffers (mutable working storage whose contents are never authoritative), and nothing it computes becomes authoritative.
tag: M
where: homes.md
note: R3-75, second part, class 2, §14.10; the width at "in groups of `width` directions per pass (D-072)".

old: The operating point defaults to the checkpoint of the simulation,
note: R3-76, first part.

old: restored with no boundary zero,
new: each restored into the scratch world with no boundary zero (§12.6, D-274, D-319).
tag: M
where: homes.md
note: R3-76, second part, class 2, §14.10.

old: and `about` with `t0` (default `0.0`) places it anywhere else.
new: and `about` with `t0` (default `0.0`) places it anywhere else (§14.10).
newcites: §14.10
note: R3-77 and R3-78. The default `0.0` is class 3, kept as it stands under R6 and listed as an open question.

old: `t0` is admitted only beside `about`, never silently ignored.
new: `t0` is admitted only there, and a `t0` passed without `about` is an `ArgumentInvalid` (D-420).
tag: M
where: homes.md
note: R3-79, class 2, §14.10.

old: On a `Model{Float64}`, `linearize(model, taps; …)` is the same query, its default point `checkpoint(model)` (D-319).
new: The default point is `checkpoint(sim)` on a simulation and `checkpoint(model)` on a `Model`
tag: M
where: homes.md
note: R3-80, class 2, §14.10. B1's `Model` block lists `linearize(model, …)`.

old: `taps(x = (…), u = (…), y = (…))`
new: - `taps(; x = (;), u = (;), y = (;))`.
tag: R
ruling: R1
note: R3-81. Spelled as src/linearize.jl:36 spells it, and set as its own entry.

old: builds the tap set, three labeled selector lists with closed membership
new: Builds the tap set, three labeled selector lists with closed membership
note: R3-82, first part.

old: (`x`: `get_state`; `u`: `get_input`; `y`: `get_output`, `get_face`),
new: Membership is closed per list. The `x` list takes `get_state`, the `u` list `get_input`, and the `y` list `get_output` and `get_face` (§14.4).
tag: M
where: homes.md
note: R3-82, second part, class 2, §14.10. The selectors themselves are named in the read-selector family entry.

old: every tap a leaf address resolving to one scalar (§14.4, §14.10, D-272, D-276).
note: R3-83.

old: Running.
new: #### Running
tag: R
ruling: R4
note: R4-01. The bold lead-in becomes a #### label.

old: - `run!(sim; pace = Inf, margin = 0.002, t_end = Inf, ignore_stop_requests = ())`.
note: R4-02.

old: `run!` blocks until the run ends.
new: `run!` blocks until the run ends. Deviceless, it is fully synchronous on the calling task (§11.1, §12.6).
tag: C
newcites: §11.1
note: R4-03. §11.1 states it ("`run!` blocks its caller until the run ends").

old: Deviceless, it is fully synchronous on the calling task.
new: Deviceless, it is fully synchronous on the calling task (§11.1, §12.6).
tag: C
newcites: §12.6
note: R4-04. §12.6 states it ("Deviceless, `run!` is fully synchronous").

old: `init!` is required first (§12.6).
new: `restore!` and `replay!` are the two alternative doors from `built`.
tag: R
ruling: R7
where: homes.md
note: R4-05, 2d. Dropped: any of the four doors opens the run, not only `init!` (§12.6, which also names `overlay!` the fourth door).

old: Paced and unpaced runs are bit-identical (§10.7).
new: A paced and an unpaced run with identical input traces (the records of each frame's drained inputs) produce bit-identical trajectories.
tag: R
ruling: R7
where: homes.md
note: R4-06, 2d. Dropped: the claim holds with identical input traces, as §10.7 says.

old: | keyword | default | meaning | owning section | |---|---|---|---|
note: R4-07.

old: | `pace` | `Inf` | the run's pacing rate; `Inf` is pacer-off, `1` real time | §10.7 |
note: R4-08. Glossary link on pacing.

old: | `margin` | `0.002` | the single pacing knob, in seconds | §10.7 |
note: R4-09.

old: | `t_end` | `Inf` | the run's end time, declared for this advance, validated per call | §12.6, §13.5 |
note: R4-10. The bold on "this advance" goes (R4); no entry is cited in the row.

old: | `ignore_stop_requests` | `()` | the stop requesters this advance does not honour: `:all`, or their component paths, validated against the `Build`'s requester roster
new: | `ignore_stop_requests` | `()` | the requesters this advance ignores, `:all` or paths in the requester roster | §13.5 |
newcites: §13.5
tag: R
ruling: R2
note: R4-11, first part. The meaning cell is cut to twelve words; the bold goes (R4); "requester roster" takes its link (R9).

old: per call | §13.5 |
new: Each path is validated against the requester roster on every call
tag: M
where: homes.md
note: R4-11, second part, class 2, §13.5. The new row keeps its §13.5 citation.

old: `pace` defaults to `Inf`, pacer-off.
new: `pace` defaults to `Inf` and `margin` to 2 ms
tag: M
where: homes.md
note: R4-12, class 2, §12.1.

old: A deviceless run is the harness and CI mode, and real time is `pace = 1` away (D-269).
new: A deviceless run is the harness and CI mode, and real time is `pace = 1` away (D-269).
tag: M
where: homes.md
note: R4-13, class 3, moved to §12.1 by R6 (applied in homes.md).

old: `margin` defaults to 2 ms, the sleep primitive's granularity plus its measured overshoot.
new: The default `margin` is 2 ms (D-133), the value the measurements above imply. It covers libuv's millisecond timer granularity and `sleep`'s median overshoot of about 1.4 ms.
tag: M
where: homes.md
note: R4-14, class 2, §10.7.

old: The values `0`, 2 ms and `∞` span the design space (§10.7).
new: The knob spans the whole design space (D-021)
tag: M
where: homes.md
note: R4-15, class 2, §10.7.

old: Each advance builds a `StopPolicy`
note: R4-16, first part. Glossary link on `StopPolicy` (coordinator 2026-10-20: B1 keeps stop policy out).

old: (the immutable `t_end`-plus-ignored-requesters value an advance declares)
new: Each call builds and validates the `StopPolicy` (the immutable value of `t_end` plus the ignored requester paths)
tag: M
where: homes.md
note: R4-16, the gloss, class 2, §12.6. The term's link sits on `StopPolicy` in the sentence before (coordinator ruling 5).

old: from its `t_end` and `ignore_stop_requests`.
new: from its `t_end` and `ignore_stop_requests` (§13.5, D-260).
newcites: §13.5 D-260
note: R4-16, last part. §13.5 and D-260's Position ("`run!`, `replay!` and `step!` build it") carry it; the paragraph's citations of R4-18 move here.

old: It passes that policy to the loop, and the value lives as long as the call.
new: The value lives as long as the call, and afterwards only on the termination record of the advance that ended the run (D-260).
tag: M
where: homes.md
note: R4-17, class 2, §12.6.

old: The termination record carries the policy that ended the run, and nothing else keeps one (§12.6, §13.5, D-260).
new: The run's termination record carries its outcome, and the `StopPolicy` of the advance that ended it (D-255, D-260).
tag: M
where: homes.md
note: R4-18, class 2, §12.6 and §13.5.

old: `t_end = Inf` with no honoured stop request is an unbounded run, allowed, with `UnboundedRun` raised into the loop's diagnostic cell
new: `t_end = Inf` with no honoured stop request is an unbounded run, allowed, with `UnboundedRun` raised into the loop's diagnostic cell in `:live` only (§11.8, §13.5).
tag: R
ruling: R7, coordinator 2026-10-20
newcites: §11.8 §13.5
note: R4-19, 2d, corrected and kept so the kind name stays on B: "The advisory fires in `:live` only" (§13.5, 10748). §13.5 joins §11.8. Glossary link on diagnostic cell.

old: (§11.8).
new: (§11.8, §13.5).
note: R4-19's citation.

old: - `step!(sim; frames = 1, t_end = Inf, ignore_stop_requests = ()) → frames_advanced`.
new: - `step!(sim; frames = 1, t_plus = nothing, t_end = Inf, ignore_stop_requests = ()) → frames_advanced`.
tag: R
ruling: R8
note: R4-20. `frames = 1` stays, its meaning in src/; `t_plus` is a keyword with default `nothing` (src/sim.jl:1751).

old: A synchronous partial advance through the ordinary frame sequence, bit-identical to the same frames under `run!`.
note: R4-21.

old: It never waits (D-269).
new: it never waits on the pacer, whatever pace the control plane holds (D-269).
tag: R
ruling: R7
where: homes.md
note: R4-22, 2d. Dropped: `step!` never waits on the pacer, and it blocks while paused (§12.1).

old: `t_plus = <duration>` is the mutually exclusive duration spelling
new: `t_plus = <duration>` is the mutually exclusive duration spelling (§12.6).
newcites: §12.6
note: R4-23, first part.

old: (whole frames until the boundary time covers that duration).
new: It advances whole frames until the boundary time first covers the duration
tag: M
where: homes.md
note: R4-23, second part, class 2, §12.6.

old: It returns the frames actually advanced, fewer than requested when `t_end` or a stop request ended the run inside the call.
new: `step!` therefore returns the number of frames actually advanced. That is the requested count in the ordinary case, and fewer when the run terminated inside the call.
tag: M
where: homes.md
note: R4-24, class 2, §12.6.

old: Between calls the simulation reports `initialized`.
new: Between `step!` calls a simulation reports `initialized` (D-088, D-388).
tag: M
where: homes.md
note: R4-25, class 2, §12.6.

old: `run!` may follow, and it continues from the current boundary.
new: `run!` may therefore follow `step!`, continuing from the current boundary
tag: M
where: homes.md
note: R4-26, class 2, §12.6.

old: A stepping session is deviceless.
new: A stepping session is deviceless by construction (D-093, D-389).
tag: M
where: homes.md
note: R4-27, class 2, §12.6.

old: Write via `stage!` and read via `latest` (§12.6).
new: Advance-assert-advance is `stage!` → `step!` → `latest` (D-096).
tag: M
where: homes.md
note: R4-28, class 2, §12.6.

old: - `stage!(sim, "face" => value, …)`.
note: R4-29.

old: Staging from any task, the calling task included, into the harness writer (§11.3).
new: Staging from any task, the calling task included, into the harness writer.
newcites: §11.3
note: R4-30. Glossary link on harness writer. Its §11.3 citation moves to the bullet's end, after the next sentence, which §11.3 also homes.

old: Its surface is the currently unclaimed faces.
new: Its surface is the currently unclaimed faces (§11.3).
tag: C
newcites: §11.3
note: R4-31.

old: The batch is traced, drained last at the next frame top, and surface-checked exactly as any device's (the harness cell, §11.3).
new: Its always-present staging cell, the harness cell, is drained, traced and surface-checked exactly as any device's.
tag: M
where: homes.md
note: R4-32, class 2, §11.3; drained last at "The harness cell drains last, by convention (D-096, D-174)".

old: It is legal under `run!` and `step!` alike (§12.6).
new: Both entry points work under `run!` too. The harness cell is not step-scoped.
tag: M
where: homes.md
note: R4-33, class 2, §12.6.

old: - `latest(sim) → snapshot`.
note: R4-34.

old: The current published snapshot, the same immutable value device handles read (§11.2).
note: R4-35.

old: It is the assertion and inspection accessor of the harness and REPL modes (§12.6).
new: It hands back the same immutable snapshot value a device handle acquires (§11.2), navigated directly for assertions (D-390).
tag: M
where: homes.md
note: R4-36, class 2, §12.6; the two modes at "It is equally the REPL mode of fly a while, inspect, continue".

old: - `phase_bodies(sim) → named callables`.
note: R4-37.

old: The compiled phase bodies of the nominal activation, bound over the simulation's own buffers.
note: R4-38.

old: They are the four blocks (`rhs`, `sweep_1`, `sweep_2`, `ticks`), with the sweeps in both arities, zero-arg interior and tick-indexed boundary, and `ticks` taking the tick index.
new: It returns four blocks. - `rhs`, the `x_deriv` block. - `sweep_1`, in both arities. - `sweep_2`, in both arities.
tag: M
where: homes.md
note: R4-39, class 2, §9.7.

old: Per-event guards/handlers and per-component `x_projection` come with them, keyed by the model's roster.
new: Returned with them are the per-event guards and handlers and the per-component `x_projection` callables, keyed by the model's own roster.
tag: M
where: homes.md
note: R4-40, class 2, §9.7.

old: This is the §9.8 allocation seam.
new: They are the §9.8 measurement seam (§9.7).
tag: R
ruling: R7
newcites: §9.8 §9.7
note: R4-41, 2d. Corrected to §9.7's name, "the §9.8 measurement seam", homed in §9.7. Glossary link on measurement seam.

old: Warm, then `@ballocated(body()) == 0` per body.
new: CI is warm-then-assert over the roster (D-116). One call compiles, then CI asserts the following. `@ballocated(body()) == 0`
tag: M
where: homes.md
note: R4-42, class 2, §9.7.

old: It is an inspection-only surface, and its one promise is identity with what the loop runs.
new: The seam is diagnostic only, and it makes one promise. These are the bodies the loop runs, not re-derivations (D-116).
tag: M
where: homes.md
note: R4-43, class 2, §9.7.

old: An isolated invocation leaves buffers valid but off-trajectory.
new: It leaves them valid but off-trajectory.
tag: M
where: homes.md
note: R4-44, class 2, §9.7.

old: Re-run `init!` to continue (§9.7).
new: A session that wants to continue meaningfully re-runs `init!`.
tag: M
where: homes.md
note: R4-45, class 2, §9.7. The bullet keeps §9.7 on R4-41's sentence.

old: - Control plane.
note: R4-46.

old: Pause/un-pause, pace and `margin` changes, and stop all sit on a separate atomic surface, never staged (§12.1).
new: Pause, un-pause, pace changes, `margin` changes and stop are a few fields on a separate atomic surface, the control plane. It is not staging, structurally (D-022).
tag: M
where: homes.md
note: R4-47, class 2, §12.1.

old: Pacing sits outside the semantics, so pace and `margin` are both safe to change live.
new: It tunes the wait, never the arithmetic, so retuning the coarse/spin split mid-run is safe by construction.
tag: M
where: homes.md
note: R4-48, class 2, §12.1.

old: `pause!(sim)`, `resume!(sim)` and `stop!(sim)` are the calling code's spellings and `paused(sim)` the read;
new: `pause!(sim)`, `resume!(sim)` and `stop!(sim)` are the calling code's spellings and `paused(sim)` the read (§12.1, D-268).
tag: C
newcites: §12.1 D-268
note: R4-49 and R4-50. D-268's Position spells `pause!`, `resume!` and `paused`; `stop!(sim)` only its Rationale (R6; rulings.md).

old: `pace!(sim, p)` and `margin!(sim, m)` set the two knobs and `pace(sim)` and `margin(sim)` read them (D-269);
new: `pace!(sim, p)` and `margin!(sim, m)` set the two knobs and `pace(sim)` and `margin(sim)` read them (D-269).
note: R4-51.

old: a device stops through `stop!(handle)` (§11.6).
new: A device stops through `stop!(handle)` (§11.6, D-268).
tag: C
newcites: §11.6 D-268
note: R4-52, class 3, a name, cited to D-268 under R6 (Rationale only; rulings.md).

old: The tail clears the pause, never a run's start (D-268).
new: The tail clears the pause flag beside the sticky stopped status (D-268). The flag is never cleared at a run's start.
tag: M
where: homes.md
note: R4-53, class 2, §12.1.

old: - Termination.
note: R4-54.

old: The model's state ends a run via stop requests, `StopFlag` ports read at every published boundary unless the advance ignores them (§13.5).
note: R4-55.

old: Shutdown completes a boundary, publishes the final snapshot, then joins (§12.4).
new: The loop never stops mid-boundary. It always completes the boundary sequence in progress,
tag: M
where: homes.md
note: R4-56, class 2, §12.4; the final snapshot and the join follow in its numbered steps ("The loop then publishes the final snapshot", "5. Join under the `join_timeout` cap").

old: - Post-run.
new: Post-run extraction reads the log through the read-selector family (D-407).
tag: M
where: homes.md
note: R4-57, a label; §11.2 names the post-run read.

old: The log is the retained snapshots.
new: The log is the retained snapshots
note: R4-58. Kept as the gloss of the new `logged(sim)` entry.

old: `series(sim, read_set) → ts`
new: - `series(sim, read_set) → ts`.
note: R4-59. Its own entry now.

old: gathers them into labeled columns through the read-selector family, one typed vector per entry beside `t`, frame and boundary (§11.2, D-407).
new: Gathers the retained snapshots into labeled columns through the read-selector family, one typed vector per labeled entry beside `t`, frame and boundary (§11.2, D-407).
note: R4-60. "them" spelled out, since the entry now stands alone; "labeled entry" for the reserved bare "entry", as §11.2 says it.

old: `trace(sim) → trc`
new: - `trace(sim) → trc`.
note: R4-61. Its own entry now.

old: retrieves the always-on input trace.
new: Retrieves the input trace, on by default (§11.5).
tag: R
ruling: R7
newcites: §11.5
note: R4-62, 2d. The trace is on by default, with a plain kill switch (§11.5, D-029).

old: `replay!(sim2, trc; to_boundary = k, pace = Inf, margin = 0.002, t_end = Inf, ignore_stop_requests = (), restore = true)`,
new: - `replay!(sim2, trc; to_boundary = nothing, to_time = nothing, pace = Inf, margin = 0.002, t_end = Inf, ignore_stop_requests = (), trace = true, log = true, log_every = 1, log_max = 65536, restore = true)`.
tag: R
ruling: R1
note: R4-63. Spelled as src/sim.jl:974 spells it: `to_boundary` and `to_time` default to `nothing`, and the four recording keywords sit in the signature.

old: taking `init!`'s four recording keywords as well (D-261),
new: taking `init!`'s four recording keywords as well (D-261).
tag: R
ruling: coordinator 2026-10-20
note: R4-64. Kept as a clause so D-261 sits on the recording keywords, not on the replay sentence it does not support; the signature also spells them (R1).

old: re-drives a fresh `Simulation(world)` bit-identically through the ordinary loop.
new: Re-drives a fresh `Simulation(world)` bit-identically through the ordinary loop,
note: R4-65.

old: It restores the trace's checkpoint and feeds the drain by frame ordinal from the frame after the header's;
new: It restores the trace's checkpoint (the `Model`'s state at a frame top, beside the run's frame index and boundary ordinal), the state the recording opened from.
tag: M
where: homes.md
note: R4-66, class 2, §12.7; the drain by frame ordinal at "Each frame top applies the recording's batches for that frame ordinal".

old: `restore = false` feeds the simulation as it stands.
new: `replay!(sim, trc; restore = false)` attaches the feed to the simulation as it stands and restores nothing (D-404).
tag: M
where: homes.md
note: R4-67, class 2, §12.7.

old: A halt names a frame from the one the feed starts from through the recording's last.
new: Either keyword names a frame from the one the feed starts from through the recording's last, and anything else is refused (`ArgumentInvalid`).
tag: M
where: homes.md
note: R4-68, class 2, §12.7.

old: It ends `initialized`.
new: A replay's halt leaves the simulation `initialized`, never `stopped` (D-218).
tag: R
ruling: R7
where: homes.md
note: R4-69, 2d. Dropped: the halt leaves the simulation `initialized`.

old: `to_time = t` is the mutually exclusive time spelling of the halt, floored to the last frame top at or before `t`.
new: `to_time` halts at the last frame top at or before the time given, the same halt addressed by time, and it is mutually exclusive with `to_boundary` (D-219).
tag: M
where: homes.md
note: R4-70, class 2, §12.7. `to_time` now shows in the signature.

old: Inspect via `latest` or the live stores, advance via `step!`, continue via `run!`.
new: That state is boundary-consistent and ready to advance, the same state `step!` leaves (§12.6).
tag: M
where: homes.md
note: R4-71, class 2, §12.7.

old: Replay is the state-trajectory inspector and the `StepError` reproduction tool (§11.2, §11.5, §12.7;
new: Replay is the state-trajectory inspector and the `StepError` reproduction tool (§11.2, §11.5, §12.7).
newcites: §11.2 §11.5 §12.7
note: R4-72.

old: on-disk persistence is deferred, `pending.md`).
new: The in-memory artifacts are settled (§11.2, §11.5) and nothing on-disk is.
tag: M
where: docs/design/pending.md
note: R4-73, class 3, dropped under R6.

old: - `warnings(x) → Vector`.
note: R4-74.

old: The artifact's warning list, on `Build` and `Deployment`, and on `Simulation` as the concatenation of its artifacts' lists (§9.2, §13.2).
note: R4-75.

old: - `closed(run) → Bool`.
note: R4-76.

old: True once the loop's tail has written the run's termination record (§12.6).
note: R4-77.

old: - `mode(sim) → :live | :replay`.
note: R4-78.

old: The input mode, read beside the lifecycle state.
note: R4-79. Glossary link on input mode.

old: It says where the next frame's drain takes its batches from, the staging cells or an attached `replay!` recording (§12.6, §12.7).
note: R4-80. Glossary links on drain, batch and staging cell (coordinator 2026-10-20); B1's old text uses none of them.

old: - `live!(sim)`.
note: R4-81.

old: Detaches the remainder of an attached recording and sets the mode to `:live`, touching neither the trajectory nor the trace.
new: Detaches the remainder of an attached recording and sets the mode to `:live`, touching neither the trajectory nor the trace (§12.7).
tag: C
newcites: §12.7
note: R4-82. §12.7 homes it; the bullet's §12.6 went with R4-85.

old: The next `run!` or `step!` then continues live from the replayed boundary and re-records onto the replayed prefix.
new: The next `run!` or `step!` is therefore the live continuation from the replayed boundary, and its drains append to the re-recorded prefix (D-219).
tag: M
where: homes.md
note: R4-83, class 2, §12.7.

old: Stopped-sim only.
new: `live!` is a stopped-sim operation, legal only on an `initialized` simulation in `:replay`.
tag: M
where: homes.md
note: R4-84, class 2, §12.7.

old: It is legal on an `initialized` simulation in `:replay`, and an already live one refuses (§12.6, §12.7).
new: A simulation already `:live` refuses too, with `ArgumentInvalid`.
tag: M
where: homes.md
note: R4-85, class 2, §12.7.

old: ---
note: The closing rule.

# Additions (R10, and the coordinator's LevenbergMarquardt clause).

added: - `get_state(path, leaf)`, `get_deriv(path, leaf)`, `get_output(path, leaf)`, `get_input(leaf)` and `get_face(leaf)`. The closed read-selector family, one address space for every reader that takes a selector (§14.4).

added: - `termination(sim)`. The current run's termination record, whose source is a typed value such as `EndTimeReached` or `ModelRequestedStop` (§13.5, D-203).

added: - `logged(sim)`.

added: and `logged` returns them (§11.2).

added: - `reads(; selectors...)`. Builds a read set, the value `series` takes and `at` mounts (§11.2, D-407).

added: `LevenbergMarquardt()`, the default backend, is an in-house dense Levenberg–Marquardt (§14.8, D-070).

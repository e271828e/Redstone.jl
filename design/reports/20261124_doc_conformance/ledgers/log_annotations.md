# Log annotations from the triage, 2026-11-26

One per entry, placed as the last paragraph of its Rationale.

## D-028

Annotation (2026-11-26): the waiter's predicate loop exits when
`counter > last_seen || !running`, so a stop releases it, §12.3.

## D-033

Annotation (2026-11-26): D-437 admits a bare contract, one type in place of the
NamedTuple whose one port takes the default face `u` or `y`, §4.3.

## D-059

Annotation (2026-11-26): amended by D-223, D-429, D-441 and D-482. The one
`StepError` constructor serves several catch sites. These are the frame (host
`:loop`), boundary zero, the overlay settling and the restore door, plus the
stretches of the services' evaluations.

## D-066

Annotation (2026-11-26): `capture` retires (D-273). The compiled readers serve
trim's cost reads and the linearization gather, and a checkpoint copies the
stores wholesale (D-274).

## D-067

Annotation (2026-11-26): `capture` retires (D-273). `init!` takes `t0` as its
argument and sets the origin before boundary zero, and a checkpoint carries the
clock past the initial instant (D-274).

## D-073

Annotation (2026-11-26): `sketch_io.jl` and `condition_demo.jl` are removed.
`sketch_decoder.jl` remains under `design/prototypes/`, and
`test/test_conditions.jl` exercises the §14 algebra and the §14.9 mounting.

## D-076

Annotation (2026-11-26): amended by D-267. One rule names the inventory. Each
declaration takes the bundle field it fills and then a qualifier:
`x_init`/`s_init`/`m_init` by value, `u_types`/`y_types` by type, `ws_init` by
allocation. `local_types` is deleted (D-165, D-194).

## D-079

Annotation (2026-11-26): amended by D-165, D-194 and D-263. `local_types` is
deleted, and `output_types` (`y_types` since D-267) is the one plain contract
declaration on both tiers. The walk substitutes `Float64` in type-parameter
positions, so a type parameter at any other `Real` type, `Int` included, pins.

## D-089

Annotation (2026-11-26): the trace holds only the drained inputs, so gain
trajectories are observable in the log and in replay, which re-drives the
ordinary loop from the trace; §5.3.

## D-092

Annotation (2026-11-26): amended by D-214. Severity takes two values, `error`
and `warning`. The former severity column splits into severity, raised (`build`,
`service`, `runtime`) and policy; Appendix C.

## D-099

Annotation (2026-11-26): a bare `Dual` does answer `zero(T)`, as a tagless
`Dual{Nothing,Int64,0}` at no scalar a model holds. §9.4 now says only that it
cannot key an activation or be walked to.

## D-105

Annotation (2026-11-26): two raises are not a `DeviceCrash`, the operator
interrupt (D-132) and the raise a device's `unblock!` provokes (D-402).

## D-112

Annotation (2026-11-26): the tier-consistency set no longer holds stage names or
`workspace` arity. D-220 retired the stage-name marker, and D-263 gives
`init_workspace` one arity on both tiers. The markers are the update laws, the
stores and `events`; §5.3, §8.2.

## D-127

Annotation (2026-11-26): the deployment block is the `Deployment` itself, whose
compared parameters are `Δt_frame`, `Δt_base`, `h_max`, `h_min`, the algorithm,
the localization, firing and attempt budgets and the schedule; `h` and `N_base`
no longer appear (§12.7, D-254, D-443, D-449, D-460).

## D-133

Annotation (2026-11-26): `margin` is a user knob since D-269, set by `margin!`
and the `margin` keyword of `run!` and `replay!` (§10.7).

## D-135

Annotation (2026-11-26): an activation-cache entry holds the declarations
retyped at its scalar, the probe products and the cell layout, not compiled
plans or a validated flag (§9.4, D-253); pre-materializing leaves no worker
writing to the Build (§11.1), but each lookup still takes the build's lock
briefly (D-281).

## D-146

Annotation (2026-11-26): sides are declared by the `is_input` and `is_output`
traits since D-177, and attach cross-checks method presence against them
(§11.6).

## D-149

Annotation (2026-11-26): a shortfall is one fail-fast diagnostic naming every
uncovered root face in declaration order, not a collected batch, §14.6 and
Appendix C.

## D-151

Annotation (2026-11-26): amended by D-235. At the stage-return seam the
framework pairs fields by name, in the write generated over the return type,
with no type-level reorder. The check is decided per field at that write against
the cell types, with no whole-type `isa` (§9.5). Trim reads the bounds in the
guess's field order by name, and only the residuals are reordered at the type
level, `NamedTuple{keys(tolerances)}(r)` (§14.7).

## D-159

Annotation (2026-11-26): superseded in part by D-214. Severity takes two values,
`error` and `warning`, and `service` is a value of the raised column, the stage
an occurrence surfaces in (Appendix C).

## D-161

Annotation (2026-11-26): the `interactive(b)` marker is retired by D-174 and
`needs_calling_task` is withdrawn by D-310, so the class-(1) exemption question
lapses for both.

## D-194

Annotation (2026-11-26): under a bare `y_types` a stage returns the one port's
value, one cell, never a `NamedTuple` (D-437). A named `y_types` still returns
its port `NamedTuple` alone.

## D-198

Annotation (2026-11-26): amended by D-269. `margin` is a knob, set by
`margin!(sim, m)` and by the `margin` keyword of `run!` and `replay!`. Debt
forgiveness and heartbeat staleness stay fixed constants with no user knob.

## D-203

Annotation (2026-11-26): the first source in that order is the first met in
time. A boundary's publication precedes the frame top that follows it, so a
request holding at a boundary is recorded over a control stop or `t_end` met
there (§13.5, D-268).

## D-213

Annotation (2026-11-26): under linearize's default form the nominal half is the
restored checkpoint, whose held cells are the frozen tier's, with no condition
applied and no establishment round, D-274, §14.10.

## D-216

Annotation (2026-11-26): `StopFaceInvalid` is retired by D-316.
`StopRequestInvalid` is collected over the given requester paths, Appendix C.

## D-217

Annotation (2026-11-26): the header records no stop policy, and a run's
effective bound is reported by its termination record, D-255.

## D-220

Annotation (2026-11-26): the deferred parametrization of `StepError` on its
cause's type landed as D-225, `StepError{C}`.

## D-223

Annotation (2026-11-26): amended by D-274 and D-441. A throw inside boundary
zero leaves no trace and no header, so its reproduction is `init!` under the
same condition, and a frame-one failure at pointer 0 reproduces as the halt at 0
followed by `step!`. An interrupt inside boundary zero is wrapped like any
throw, a `StepError{InterruptException}` with host `:boundary_zero`, and the
lifecycle moves to `built`.

## D-228

Annotation (2026-11-26): `EmptyGreedyClaim`, which D-250 moved into the roster
entry's own cell, names its device, the cell's writer (§11.6, Appendix C).

## D-250

Annotation (2026-11-26): a trim report is the exception to the artifact rule. It
holds the facts its warnings report, and `trim!` logs `TrimCommitEvents`,
`TrimCommitResiduals` and `TrimCommitChecks` beside it (§13.2).

## D-251

Annotation (2026-11-26): an `only` that passes the unknown-names check keeps
every face it names, so only `except` or `select` can keep nothing and raise
`EmptyFaceSelection` (§8.8).

## D-253

Annotation (2026-11-26): amended by D-261. `Dataflow` is `Outputs` and carries
no feedthrough edges. Where they are shown, they are derived from the
`Structure`'s connections and the producers' stage-2 names. The tracer runs
inside the nominal evaluation's failure path, before `Outputs` exists, so it
takes its name lists from the `Structure` and the nominal evaluation's own
declarations and stage-1 products, never from an activation (`src/tracer.jl`).

## D-254

Annotation (2026-11-26): the `Schedule` holds its component rows and rate-scope
rows. The `D`, `Φ`, `Δt` vectors are derived from the rows at `compile` (D-261).

## D-255

Annotation (2026-11-26): amended by D-260, D-274 and D-317. `Trace` has no
scalar parameter, and its header is a `Checkpoint`. The `schemas`, `batches` and
length stand. The register retires: the replay feed is the run's `feed`, with
its own cursor. The stop policy is built and validated by each advance and
passed to the loop as that advance's argument, and its one lasting home is the
termination record.

## D-256

Annotation (2026-11-26): amended by D-260, D-261, D-316 and D-317. The
deployment holds the `Schedule`'s rows, and the executor derives the
per-component `D`, `Φ` and `Δt` vectors from them at `compile`. `t_end` and the
stop requests do not go to the run: the stop policy is each advance's argument,
and its one lasting home is the termination record. `join_timeout` is a keyword
of `Simulation` and its convenience forms, and `trace`, `log`, `log_every` and
`log_max` are keywords of `init!`, `overlay!`, `restore!` and `replay!`.

## D-260

Annotation (2026-11-26): `init!`, `overlay!`, `restore!` and `replay!` construct
a run and rebind `sim.run`, and nothing else rebinds it (§12.6, D-274, D-429).

## D-261

Annotation (2026-11-26): D-317 supersedes the clause typing a `t*` stop hit.
`frame!` returns a `Bool`, `true` when `settled!` found an honoured stop
request, and the loop reads the requester again off the published snapshot.

## D-270

Annotation (2026-11-26): `incumbent_status` returns the harness writer's record
for a root input no device claims, and `nothing` only for a port no root input
drives (§11.7).

## D-285

Annotation (2026-11-26): the shape a return is held to follows its declaration,
a `NamedTuple` under a named `y_types` and the one port's value under a bare
one, and the probe checks it so (D-437, §9.3).

## D-287

Annotation (2026-11-26): the store embeds a struct-valued port leaf by leaf and
rebuilds the declared type from the arrival's leaves, so no cross-eltype
constructor is called and no diagnostic names both types (D-238).

## D-319

Annotation (2026-11-26): amended by D-452 and D-457. A `ModelState` holds a
tenth field, the stepper's carried state, `nothing` for a fixed-step method
(§12.6). The origin is held exact, so the default of `t0` is the integer `0`,
not `0.0` (§14.5, Appendix B).

## D-343

Annotation (2026-11-26): the trace speaks for the branches its evaluations took,
a sampled member being evaluated at sampled states too, not only the branch at
the probe point. The author still selects the remedy (§13.8).

## D-432

Annotation (2026-11-26): amended by D-434. The kinds are `build`, `deployment`
and `failure`, and the failure kind is live. Faces come from each instance's own
declarations, read as written, with a `Pinned` entry unwrapped and flagged, and
the reader takes no tier and no scalar (§13.9).

## D-443

Annotation (2026-11-26): D-449 supersedes the fourth bullet whole, the narrower
form D-444 left standing included. Nothing relates `h_max` to `Δt_frame` or
`Δt_base`, and no `:not_harmonic` refusal exists (§9.2, §10.5).

## D-452

Annotation (2026-11-26): refined by D-460. The `Model` asks no proposal after
the rejection that spends the step's attempt budget, since its next attempt is
the floor's (§10.2).

## D-454

Annotation (2026-11-26): amended by D-467. The descriptor's deployment body
carries `dt_frame`, `dt_base` and `h_max` exact (§13.9). The checkpoint and the
trace header still hold the `Deployment` as a value.

## D-479

Annotation (2026-11-26): the step count under a proposal is capped at
`⌊r / h_min⌋` and is at least 1, as D-460 rules (§10.5).


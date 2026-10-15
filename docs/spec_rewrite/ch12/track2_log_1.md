# Chapter 12, track 2, agent 1: edit log

Every edit in order, old text then new text, matched by old text (each
matched exactly once in the file before any write). Commit 1's new text is
shown as linkified. Commit 2's new text is shown as written, with bare
citations, which `linkify.jl` then linked; replay it the same way, then run
`linkify.jl`. Commit 2's edits were applied by
`scratch_track2/1/log_edits.py`, which asserts every old text first.

## Commit 1 (54779c2): spec and glossary (B79–B81)

### E1. B79: the stop word's glossary entry (`spec.md`, §D.6)

Inserted after the `StopPolicy` entry, before *unattended run*.

Old:

```
[D-255][d-255], [D-260][d-260], [D-316][d-316], [D-317][d-317]).

<a id="g-unattended-run"></a>
```

New:

```
[D-255][d-255], [D-260][d-260], [D-316][d-316], [D-317][d-317]).

<a id="g-stop-word"></a>**stop word** — the control plane's stop command, one atomic word holding
its issuer ([§12.1][s12-1]). Not to be confused with a *stop request* ([§D.9][sD-9]), which
the model publishes.

<a id="g-unattended-run"></a>
```

### E2. B79: the stop word's first use links its entry (`spec.md`, §12.1)

Needed by `check_glossary.jl --strict`, which requires a body link to every
anchor. The first use is the bold; §3.2's "**Each [tier](#g-tier) carries**"
is the precedent for a link inside a bold.

Old: `**The stop word carries its issuer** ([D-203][d-203]).`

New: `**The [stop word](#g-stop-word) carries its issuer** ([D-203][d-203]).`

### E3. B80: the calling task's glossary entry (`spec.md`, §D.6)

Old: `**calling task** — the task that invoked `run!`. It runs the loop itself,`

New: `**calling task** — the task that invoked `run!` or `replay!`. It runs the loop itself,`

### B81: no edit

§12.4 already glosses the name at its first use: "the run's-end sweep, the
loop's last pass over every diagnostic cell, collects the …". The ruling
keeps the name and the gloss.

## Commit 2 (d19fe88): the log (B41–B75)

Annotation placement: after the entry's last annotation where it has one
before **Rejected.** (or after **Rejected.**, for D-255, whose annotations sit
there); otherwise after the Rationale paragraph.

### L1. B41: D-021 Spec

Old:

```
**Spec.** [§10.7][s10-7]
```

New:

```
**Spec.** [§10.7][s10-7], §12.1, §12.2
```

### L2. B41: D-022 Spec

Old:

```
**Spec.** [§2][s2], [§11.1][s11-1]
```

New:

```
**Spec.** [§2][s2], [§11.1][s11-1], §12.1, §12.3
```

### L3. B41: D-045 Spec

Old:

```
**Spec.** [§4.3][s4-3], [§11.4][s11-4], [§11.6][s11-6], [§11.7][s11-7]
```

New:

```
**Spec.** [§4.3][s4-3], [§11.4][s11-4], [§11.6][s11-6], [§11.7][s11-7], §12.5
```

### L4. B41: D-060 Spec

Old:

```
**Spec.** [§9.3][s9-3], [§13.5][s13-5], [§14.4][s14-4]
```

New:

```
**Spec.** [§9.3][s9-3], §12.4, §12.5, [§13.5][s13-5], [§14.4][s14-4]
```

### L5. B41: D-108 Spec

Old:

```
**Spec.** [§11.3][s11-3], [§13.6][s13-6], [§14][s14]
```

New:

```
**Spec.** [§11.3][s11-3], §12.6, §12.7, [§13.6][s13-6], [§14][s14]
```

### L6. B41: D-228 Spec

Old:

```
**Spec.** [§11.8][s11-8], [Appendix C][sC]
```

New:

```
**Spec.** [§11.8][s11-8], §12.4, [Appendix C][sC]
```

### L7. B41: D-366 Spec

Old:

```
each with a no-op default.

**Spec.** [§11.6][s11-6]
```

New:

```
each with a no-op default.

**Spec.** [§11.6][s11-6], §12.4
```

### L8. B41: D-372 Spec

Old:

```
The obligation is taught ([§11.6][s11-6], [Appendix A][sA]).

**Spec.** [§11.6][s11-6]
```

New:

```
The obligation is taught ([§11.6][s11-6], [Appendix A][sA]).

**Spec.** [§11.6][s11-6], §12.4
```

### L9. B41: D-373 Spec

Old:

```
(`DeviceJoinTimeout`, a stale heartbeat), never forced.

**Spec.** [§11.6][s11-6]
```

New:

```
(`DeviceJoinTimeout`, a stale heartbeat), never forced.

**Spec.** [§11.6][s11-6], §12.4
```

### L10. B41: D-374 Spec

Old:

```
**Spec.** [§11.3][s11-3], [§11.4][s11-4], [§11.6][s11-6]
```

New:

```
**Spec.** [§11.3][s11-3], [§11.4][s11-4], [§11.6][s11-6], §12.2, §12.4
```

### L11. B41: D-381 Spec

Old:

```
**Spec.** [§11.6][s11-6], [§D.6][sD-6]
```

New:

```
**Spec.** [§11.6][s11-6], §12.4, [§D.6][sD-6]
```

### L12. B43: D-030 Spec and annotation

Old:

```
`should_close` path; loop failure runs the same protocol from the catch path.

**Rationale.** Recorded only through the rejections below.
```

New:

```
`should_close` path; loop failure runs the same protocol from the catch path.

**Spec.** §12.4, §13.6

**Rationale.** Recorded only through the rejections below.

Annotation (2026-10-15): since D-373 `should_close` dissolves into the loop
body returning, a voluntary exit. A crashing device task is caught by the
framework wrapper (D-102) and follows the same path, and it requests a sim
stop only if the device's `should_abort` is set (§12.4).
```

### L13. B44: D-031 annotation

Old:

```
**Spec.** [§11.3][s11-3], [§12.5][s12-5], [§14][s14]

**Rationale.** Recorded only through the rejections below.
```

New:

```
**Spec.** [§11.3][s11-3], [§12.5][s12-5], [§14][s14]

**Rationale.** Recorded only through the rejections below.

Annotation (2026-10-15): the "slot" of "manual events = slot + guard" is a
root input since D-206.
```

### L14. B47: D-088 annotation

Old:

```
*actually* advanced; `t_end`/`stop_on` re-bindable per run at `run!` ([D-091][d-091]);
`errored` terminal ([D-059][d-059]).
```

New:

```
*actually* advanced; `t_end`/`stop_on` re-bindable per run at `run!` ([D-091][d-091]);
`errored` terminal ([D-059][d-059]).

Annotation (2026-10-15): `UninitializedSlots` is `UninitializedInputs` since
D-206. Since D-255 `init!` allocates a fresh trace and log rather than
clearing them, and D-255 supersedes D-091: `t_end` and `stop_on` are
keywords of `run!` and `replay!`, validated per call. `stop_on` is
`ignore_stop_requests` since D-316.
```

### L15. B50: D-097 annotation

Old:

```
separation already treats the crash path as its own species.
```

New:

```
separation already treats the crash path as its own species.

Annotation (2026-10-15): amended by D-228. A rate-limited diagnostic kind
names its subjects in the payload and never its writer, and `DeviceCrash`
is written to the crashing device's own cell, so its payload is the
exception as `cause` and whether `should_abort` was set, with no device id
(Appendix C).
```

### L16. B51: D-101 annotation

Old:

```
parametric difference = the what-if replay (determinism promised,
reproduction only against the identical build).
```

New:

```
parametric difference = the what-if replay (determinism promised,
reproduction only against the identical build).

Annotation (2026-10-15): amended by D-174, D-176, D-255 and D-274. Since
D-274 the header is the checkpoint `init!` takes at the end of boundary
zero, and replay restores it and feeds the batches, so the two
substitutions become one, the drain fed by the recording: `init!` is the
only door that runs boundary zero. The interactive writer is the harness
writer since D-174. Since D-176 every writer's drained batch is
sparse-converted at the drain, so the trace has one record format and
replay one inverse-conversion path, and since D-255 the schemas are a list
on the trace, not in its header. `ReplayHeaderMismatch` is
`CheckpointMismatch` (Appendix C).
```

### L17. B53: D-110 annotation

Old:

```
guards-at-commit, `t0` anchoring, and the [§12.6][s12-6] three-item clear (trace, log,
staged batches).
```

New:

```
guards-at-commit, `t0` anchoring, and the [§12.6][s12-6] three-item clear (trace, log,
staged batches).

Annotation (2026-10-15): amended by D-273. `capture` no longer produces a
condition, and a resume is a checkpoint and a restore, so resume-at-time is
no longer spelled through `capture`'s returned `t` passed as `t0`.
```

### L18. B54: D-114 annotation

Old:

```
**Spec.** [§10.4][s10-4], [§12.3][s12-3], [§13.4][s13-4]

**Rationale.** Recorded only through the rejections below.
```

New:

```
**Spec.** [§10.4][s10-4], [§12.3][s12-3], [§13.4][s13-4]

**Rationale.** Recorded only through the rejections below.

Annotation (2026-10-15): amended by D-230. A snapshot carries the
trajectory's published-boundary ordinal, and the wait counter is a
separate, monotone count that is never reset, so the loop state the wait
predicate tests no longer mirrors the snapshot's index.
```

### L19. B55: D-127 annotation

Old:

```
no policy, so the `t_end`/`stop_on` pair is not recorded ([D-255][d-255]). The
terminating advance's policy is in the termination record.
```

New:

```
no policy, so the `t_end`/`stop_on` pair is not recorded ([D-255][d-255]). The
terminating advance's policy is in the termination record.

Annotation (2026-10-15): `n` is `N_base` since D-234, and `event_budget` is
`localization_budget` since D-181. `ReplayHeaderMismatch` is
`CheckpointMismatch` (Appendix C).
```

### L20. B56: D-128 Spec

Old:

```
**Spec.** [§10.4][s10-4], [§12.6][s12-6], [§12.7][s12-7], [§13.4][s13-4], [Appendix C][sC]
```

New:

```
**Spec.** [§10.4][s10-4], §12.3, [§12.6][s12-6], [§12.7][s12-7], [§13.4][s13-4], [Appendix C][sC]
```

### L21. B56: D-128 annotation

Old:

```
**Rationale.** The boundary counter stays the reporting index ([§10.4][s10-4]'s
counter/frame-ordinal separation intact).
```

New:

```
**Rationale.** The boundary counter stays the reporting index ([§10.4][s10-4]'s
counter/frame-ordinal separation intact).

Annotation (2026-10-15): amended by D-230. The index a snapshot reports is
the trajectory's published-boundary ordinal, and the boundary counter is
the wait's separate, monotone count, its absolute value nowhere normative.
```

### L22. B57: D-132 annotation

Old:

```
discrimination stands on the Position, an operator interrupt being a
control-plane stop, not a failure.
```

New:

```
discrimination stands on the Position, an operator interrupt being a
control-plane stop, not a failure.

Annotation (2026-10-15): since D-310 no device runs on the calling task, so
§12.4(5) has no asymmetry left, and the clause on "(5)'s honest asymmetry"
above is historical. `stop_on` is `ignore_stop_requests` since D-316: a
model's stop request ends the run unless the advance ignores it.
```

### L23. B58: D-133 annotation

Old:

```
algorithm, `event_budget` is `localization_budget`, and `firing_budget` joins
them as a third recorded parameter.
```

New:

```
algorithm, `event_budget` is `localization_budget`, and `firing_budget` joins
them as a third recorded parameter.

Annotation (2026-10-15): amended by D-198 and D-316. The join timeout is
`join_timeout`, a keyword defaulting to 5 s (D-198). `stop_on` is
`ignore_stop_requests` since D-316: a model's stop request ends the run at
the first publication where it holds, unless the advance ignores it.
```

### L24. B60: D-138 annotation

Old:

```
task is spawned and the record shows it; nothing else marks a device dead
([D-160][d-160]'s annotation).
```

New:

```
task is spawned and the record shows it; nothing else marks a device dead
([D-160][d-160]'s annotation).

Annotation (2026-10-15): the bracket runs at the top of a run, and a run
need not start at boundary zero, so the Rationale's boundary-zero clauses
read at the run's start (§12.4). A failed device is dead from the run's
first frame top. Its orphaned root inputs, the slots of the Rationale since
D-206, hold the values the run started with, well-defined by root-input
totality (§14.6). With `should_abort` clear the device is absent from the
run's first frame. With it set the stop is pending at the run's first
frame top, which the loop reads before any frame, so the run advances no
frame and ends `stopped` where it started, its terminal snapshot the one
it started from. `DeviceCrash`'s payload names no device id since D-228.
The cell it is written to names the device.
```

### L25. B61: D-198 annotation

Old:

```
and stays replay-blind, the `log_max` disposition ([§11.2][s11-2]). One value for the
whole tail: the join loop has one patience.
```

New:

```
and stays replay-blind, the `log_max` disposition ([§11.2][s11-2]). One value for the
whole tail: the join loop has one patience.

Annotation (2026-10-15): amended by D-256 and D-317. D-256 moves
`join_timeout` into `Control`, and D-317 makes it a keyword of
`Simulation(model::Model{Float64}; join_timeout = 5.0)`. The Rationale's
"Deployment contexts" are contexts of use, not the `Deployment`. §12.4 says
"usage contexts".
```

### L26. B62: D-217 annotation

Old:

```
trace that `restore!` opens starts at the checkpoint's frame ([D-274][d-274]).

**Rejected.**
- *A mutable termination slot in the header, rewritten at every advance:* one
```

New:

```
trace that `restore!` opens starts at the checkpoint's frame ([D-274][d-274]).

Annotation (2026-10-15): `ReplayHeaderMismatch` is `CheckpointMismatch`
(Appendix C).

**Rejected.**
- *A mutable termination slot in the header, rewritten at every advance:* one
```

### L27. B63: D-218 annotation

Old:

```
and keeps going, so every frame of a session is either record-driven or live,
and which one it was is readable before it runs.
```

New:

```
and keeps going, so every frame of a session is either record-driven or live,
and which one it was is readable before it runs.

Annotation (2026-10-15): since D-274 replay restores the header and runs no
boundary zero, so D-101's two substitutions are one, the drain fed by the
recording.
```

### L28. B65: D-223 annotation

Old:

```
that threw left a warm simulation reporting `initialized` with the clock reset
and the stores half-transitioned, and `step!` advanced on them.
```

New:

```
that threw left a warm simulation reporting `initialized` with the clock reset
and the stores half-transitioned, and `step!` advanced on them.

Annotation (2026-10-15): since D-274 `init!` is the only door that runs
boundary zero, so a throw inside boundary zero comes under `init!` alone.
```

### L29. B66: D-230 annotation

Old:

```
boundary index, a frame count that can name no `t*` boundary; [§10.4][s10-4] and
[§12.3][s12-3] had called it the counter and now name it as what it is. The cost is
one field beside the clock, reset with it and stamped at publication.
```

New:

```
boundary index, a frame count that can name no `t*` boundary; [§10.4][s10-4] and
[§12.3][s12-3] had called it the counter and now name it as what it is. The cost is
one field beside the clock, reset with it and stamped at publication.

Annotation (2026-10-15): amended by D-274. A `restore!` of a checkpoint
opens a fresh run, but the boundary ordinal continues, being the
trajectory's (§12.3).
```

### L30. B67: D-249 annotation

Old:

```
member set; a `Pinned` entry on a discrete leaf joins it ([D-263][d-263]).
```

New:

```
member set; a `Pinned` entry on a discrete leaf joins it ([D-263][d-263]).

Annotation (2026-10-15): the fourth bullet is historical. D-316 retires the
`stop_on` keyword and `StopFaceInvalid`.
```

### L31. B69: D-255 annotation

The matched text ends with "### D-256 — ", trailing space included.

Old:

```
trace that `restore!` opens starts at the checkpoint's frame ([D-274][d-274]).


### D-256 — 
```

New:

```
trace that `restore!` opens starts at the checkpoint's frame ([D-274][d-274]).

Annotation (2026-10-15): D-260 supersedes the first bullet's `Run`, and
with D-261 the placeholder. `t₀` and the mode are not run fields, and the
placeholder run is an empty log and no trace. D-317 supersedes the clause
keeping the lifecycle on `Control`. `Control` holds a running flag, and
`lifecycle(sim)` derives the state.


### D-256 — 
```

### L32. B70: D-260 annotation

Old:

```
A `Float64` origin also lets `init!` take `t0 = 0.25` on a `Dual`
simulation, which a `T`-typed keyword refused.
```

New:

```
A `Float64` origin also lets `init!` take `t0 = 0.25` on a `Dual`
simulation, which a `T`-typed keyword refused.

Annotation (2026-10-15): D-317 supersedes the first bullet's four-field
`Run`. The frame index and the boundary ordinal are the run's counters.
```

### L33. B71: D-261 annotation

Old:

```
one entry per requester, in place of the faces' compiled addresses, and a
`t*` stop hit is a requester or `nothing`.
```

New:

```
one entry per requester, in place of the faces' compiled addresses, and a
`t*` stop hit is a requester or `nothing`.

Annotation (2026-10-15): D-317 supersedes the clause keeping `chunk_size`
on `Simulation(deployment, T)`. `chunk_size` is a keyword of
`Model(deployment, T = Float64; chunk_size = 16)`.
```

### L34. B72: D-268 annotation

Old:

```
after each `shutdown!` returns; an interrupt between a return and the cursor's
advance repeats that call ([§11.6][s11-6]).
```

New:

```
after each `shutdown!` returns; an interrupt between a return and the cursor's
advance repeats that call ([§11.6][s11-6]).

Annotation (2026-10-15): the stop faces of the second bullet and the
Rationale are stop requests since D-316. Since D-274 `restore!` copies a
checkpoint's state back, and replay is a restore followed by the feed, so
the stores of the second 2026-09-26 annotation may hold mid-boundary values
until the next `init!`, `restore!` or `replay!` (§12.4).
```

### L35. B74: D-274 Spec

Old:

```
[§12.6][s12-6], [§12.7][s12-7], [§13.7][s13-7], [§14.8][s14-8], [§14.10][s14-10], [Appendix B][sB]
```

New:

```
[§12.6][s12-6], [§12.7][s12-7], §14, [§14.8][s14-8], [§14.10][s14-10], [Appendix B][sB]
```

### L36. B74: D-274 annotation

Old:

```
Annotation (2026-10-13): the persistence deferral is `pending.md`'s (Log and
trace persistence) and [Appendix B][sB]'s, not [§11.5][s11-5]'s.
```

New:

```
Annotation (2026-10-13): the persistence deferral is `pending.md`'s (Log and
trace persistence) and [Appendix B][sB]'s, not [§11.5][s11-5]'s.

Annotation (2026-10-15): the stopped-sim services are §14, so the second
bullet's §13.7 reads §14.
```

### L37. B75: D-319 Spec

Old:

```
**Spec.** [§9.2][s9-2], [§11.5][s11-5], [§12.6][s12-6], [§14][s14], [§14.5][s14-5], [§14.8][s14-8], [§14.10][s14-10], [Appendix B][sB], [Appendix C][sC]
```

New:

```
**Spec.** [§9.2][s9-2], [§11.5][s11-5], §12.4, [§12.6][s12-6], §12.7, [§14][s14], [§14.5][s14-5], [§14.8][s14-8], [§14.10][s14-10],
[Appendix B][sB], [Appendix C][sC]
```

## Left or declined

- B41, D-200: §12.6 not added. The landed §12.6 no longer states what D-200
  rules (the harness writer's own diagnostic cell, written on whichever task
  stages). It names the harness cell and leaves the writer to §11.3 ("and
  §11.3 specifies the writer"). The "any task" sentence the survey tied to
  D-200 went with M53.
- B41: every other added section was checked against the landed chapter:
  D-021 (§12.1 8607, §12.2 8717), D-022 (§12.1 8602, §12.3 8801 and 8834), D-045
  (§12.5 9256, the levels doctrine), D-060 (§12.4, §12.5), D-108 (§12.6
  9500 `checkpoint`'s gate, §12.7 9702 `live!`'s gate), D-228 (§12.4 9052
  and 9061), D-366 (§12.4 8895, `unblock!` default no-op), D-372 (§12.4
  9039), D-373 (§12.4), D-374 (§12.2 8780, §12.4 8925, 8994, 9068), D-381
  (§12.4 8921). B43 D-030 (§12.4 cites it; §13.6 states the one tail), B56
  D-128 (§12.3 cites it), B75 D-319 (§12.4 9186 `CheckpointMidFrame`; §12.7
  9608 the checkpoint's state split).
- B42 (D-027) and B48 (D-093): the stale-text half is the annotation E2
  rules ("annotation as E2 rules"; "annotate the Rejected text with E2's
  outcome"). Left for E2.
- B57 (D-132): "resumable by the next `run!`" left for E1. The asymmetry
  clause and `stop_on` are annotated.
- B59 (D-134): its one clause, the GUI's read path, is E2's. Left.
- B55 (D-127): "`t₀` applied rather than compared" not annotated. The
  contradiction is the `restore = false` form, which no entry records
  (B78, owner).
- B60 (D-138): "reads stale … from the first frame ([§11.8], [D-136])" not
  annotated. §11.8 states the heartbeat field and that the threshold is read
  against it, so the pointer is not plainly wrong, and the landed §12.4
  keeps the claim ("reads stale … from the start"). F10's overbreadth is a
  reading for the owner, not a later entry, rename or pointer.
- B63 (D-218): `restore!` missing from bullet 3's doors not annotated. No
  entry rules that `restore!` resets the mode (B78, owner). The "two
  substitutions" clause is annotated.
- B71 (D-261): `restore!` taking the four keywords is a Position item with
  no entry (B78). Only the `chunk_size` supersession is annotated.
- B74 (D-274): the Spec field's §13.7 is corrected in place; the Position's
  §13.7 is annotated, not edited.
- B44 (D-031): "shape on record" left to the owner, as the batch says.
- B73 (D-270): no stale-text half; the existing annotation states the rule.
- B45, B46, B49, B52, B64, B68: Position-only items, agent 2's.

## Battery

Before each commit: `linkify.jl`, then `check_refs.jl` OK, `check_rows.jl`
OK (no coverage drop, no rebaseline), `check_glossary.jl --strict` OK (174
entries after B79), `check_bold.jl` OK, and `linkify.jl` again a no-op.

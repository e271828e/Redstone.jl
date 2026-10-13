# Chapter 11, track 2, agent 1: edit log

Each edit is matched by its old text, which matched exactly once. New
citations were written bare; `linkify.jl` then linked them and added their
link definitions (not listed). Old texts are the linkified spelling in the
file before the edit.

## Commit 1, `b216dee`: outside edits (B-29 to B-34)

### 1.1. B-29, `docs/design/spec.md`

Old:

````text
- **The write-surface and entry violations** ([§11.3][s11-3]), all raised at
````

New:

````text
- **The write-surface and entry violations** (§11.3, §11.4), all raised at
````

### 1.2. B-30, `docs/design/spec.md`

Old:

````text
what the device may write rather than what it will | [§11.4][s11-4] |
````

New:

````text
what the device may write rather than what it will | §11.3, §11.4 |
````

### 1.3. B-31, `docs/design/spec.md`

Old:

````text
Declarations, error messages, [device](#g-device)/[trace](#g-trace) addressing ([§11.3][s11-3]) and the HDF5 log
tree share it verbatim. A device is any attached participant outside the loop,
and the trace is the primary record of a session. [Container children](#g-container-children) (the
````

New:

````text
Declarations, error messages, inspection reads of the snapshot and the log
(§11.2) and the HDF5 log tree share it verbatim. [Container children](#g-container-children) (the
````

### 1.4. B-32, `docs/design/companions/flight_case_studies.md`

Old:

````text
- `attach!` of the GUI under the greedy binding, then
  `run!(sim; pace = 1, t_end = 1000)`, makes a
  greedy claim over every unclaimed face and settles
  liveness with zero configuration, both at run start against the
  frozen roster ([§11.3][s11-3]). Axis
````

New:

````text
- `attach!` of the GUI under the greedy binding makes a greedy claim over
  every unclaimed face at the attach point (§11.3). Then
  `run!(sim; pace = 1, t_end = 1000)` settles liveness with zero
  configuration at run start, against the frozen roster (§11.7). Axis
````

### 1.5. B-33, `docs/design/implementation.md`

Old:

````text
Spec: §10.7, §11.3, §12.1–§12.4, §12.6, D-021, D-027, D-203, D-255,
````

New:

````text
Spec: §10.7, §12.1–§12.4, §12.6, D-021, D-027, D-203, D-255,
````

### 1.6. B-34 Appendix B, `docs/design/spec.md`

Old:

````text
| `reads(b)` / `map_output(nt, b)` | — | the output side | [§14.4][s14-4], [§11.2][s11-2] |
````

New:

````text
| `reads(b)` / `map_output(nt, b)` | — | the output side | [§14.4][s14-4], [§11.2][s11-2], §11.6 |
````

### 1.7. B-34 walkthrough, `docs/design/companions/frame_walkthrough.md`

Old:

````text
counter ([§11.2][s11-2], [D-230][d-230]).
````

New:

````text
counter (§12.3, [D-230][d-230]).
````

### 1.8. B-34 case study, `docs/design/companions/flight_case_studies.md`

Old:

````text
The GUI peek-batch ([§11.7][s11-7]) therefore survives as
````

New:

````text
The GUI peek-batch (D-047) therefore survives as
````

### 1.9. B-34 glossary, `docs/design/spec.md`

Old:

````text
([§11.1][s11-1]). Distinct from a *boundary* ([§D.4][sD-4]), and from the
````

New:

````text
(§10.1, §11.1). Distinct from a *boundary* ([§D.4][sD-4]), and from the
````

## Commit 2, `0fd77f9`: the log (B-35 to B-47, B-50), `docs/design/decisions.md`

Annotations sit after the Rationale and any earlier annotation, before
**Rejected.**, as the log's recent annotations do. `decisions_style.md`
names no placement. D-255's earlier annotation sits after its Rejected list,
so its new one follows that annotation, at the end of the entry.

### 2.1. B-35 D-136

Old:

````text
**Spec.** [§9.8][s9-8], [§10.7][s10-7], [§11.1][s11-1], [§11.2][s11-2], [§11.4][s11-4], [§11.6][s11-6], [§11.8][s11-8], [§12.2][s12-2], [§12.4][s12-4], [§13.2][s13-2], [§13.5][s13-5],
Appendices C/D
````

New:

````text
**Spec.** §9.8, §10.7, §11.2, §11.6, §11.8, §12.2, §12.4, §13.2, §13.5, Appendices C/D
````

### 2.2. B-35 D-168

Old:

````text
**Spec.** [§6.1][s6-1], [§11.3][s11-3], [§8.2][s8-2], [§14.10][s14-10]
````

New:

````text
**Spec.** §6.1, §8.2, §14.10
````

### 2.3. B-36 D-268

Old:

````text
Annotation (2026-10-02): amended by [D-269][d-269]. The loop reads the control
plane, the pause flag included, at frame top alone; the pause block is the one
wait woken at once.

**Rejected.**
- *`pause!(sim, flag::Bool)` as one verb:* two verbs read at the call site
````

New:

````text
Annotation (2026-10-02): amended by [D-269][d-269]. The loop reads the control
plane, the pause flag included, at frame top alone; the pause block is the one
wait woken at once.

Annotation (2026-10-13): since D-310 no device runs on the calling task, and
the wrapper records no release. The repeat arises in `run!`'s interrupt arm,
which releases directly each device it never spawned and advances a cursor
after each `shutdown!` returns; an interrupt between a return and the cursor's
advance repeats that call (§11.6).

**Rejected.**
- *`pause!(sim, flag::Bool)` as one verb:* two verbs read at the call site
````

### 2.4. B-37 D-160

Old:

````text
**Rationale.** A round-5 vocabulary finding (finding 2.1), per [D-144][d-144]'s class
(3).

**Rejected.**
- *Keeping the bare spelling:* a mutating action in noun dress — the class
````

New:

````text
**Rationale.** A round-5 vocabulary finding (finding 2.1), per [D-144][d-144]'s class
(3).

Annotation (2026-10-13): no `mark_dead!` exists. A device's death is marked
nowhere beyond its record: the task has ended, `task_state` says so at the
next publication, and the heartbeat goes stale (§11.6, §12.2, D-138, D-193).

**Rejected.**
- *Keeping the bare spelling:* a mutating action in noun dress — the class
````

### 2.5. B-38 D-138

Old:

````text
**Rationale.** Release is therefore **unconditional**, which is what makes
[§11.6][s11-6]'s "guaranteed on every exit path" and [§12.4][s12-4]'s "`shutdown!` has released
each device's OS resources" true of the one path outside the wrapper, and it
carries a **new taught obligation** ([§11.6][s11-6], [Appendix A][sA]): `shutdown!` must
tolerate a **partially initialized** device — "close only what is open" — the
same defensiveness the crash path already demands. **No new diagnostic kind**:
`DeviceCrash`'s payload (device id, `cause`, whether `should_abort` was set)
already fits an init-time failure, [Appendix C][sC]'s gloss merely naming the site. A
failed device is **dead from boundary zero** with no dead-marking machinery of
its own — it never stores a heartbeat timestamp, so its cell reads stale
against [§12.2][s12-2]'s threshold from the first frame ([§11.8][s11-8], [D-136][d-136]) — and its **claims
persist to run end**: [§11.3][s11-3]'s death-is-not-detach disposition applied one step
earlier than [§12.4][s12-4](6)'s, the orphaned slots holding their initial values,
well-defined by [§14.6][s14-6]'s slot totality where a (6) orphan holds a last drained
batch. **Run disposition splits on `should_abort`, uniformly with (6)**: clear
(the default) the remaining entries initialize, the run starts and the sim runs
with the device absent from frame zero — (6)'s semantics shifted to `t₀`; set,
the failure requests a control-plane stop that is **already pending at boundary
zero**, so the run reuses [§13.5][s13-5]'s existing terminal-at-`t₀` path — remaining
entries still initialize, every rostered device getting its `init!`/`shutdown!`
pair uniformly, boundary zero is published, the run ends `stopped` at `t₀`
through the ordinary [§12.4][s12-4] tail and the termination record names the source.
**Topology is derived after initialization** ([§11.1][s11-1]): a failed
`needs_calling_task` holder returns the loop to the calling task rather than
parking it on a device that will not exist. Finally `should_abort` gets the
**declaration site** it never had: an **`attach!` keyword, default `false`** —
matching (6)'s narrative default ("the sim continues with the device absent"; a
dead joystick must not kill a session) — with the **shipped GUI attaching
`should_abort = true`** (closing the window is the interactive session's
natural end) and `gui = true`'s standard attachment stating that value
([Appendix B][sB], [D-134][d-134]'s sugar unchanged); [Appendix D][sD] gains the glossary entry.

**Rejected.**
- *Requiring `init!` to clean up after itself on failure:* an unenforced burden
````

New:

````text
**Rationale.** Release is therefore **unconditional**, which is what makes
[§11.6][s11-6]'s "guaranteed on every exit path" and [§12.4][s12-4]'s "`shutdown!` has released
each device's OS resources" true of the one path outside the wrapper, and it
carries a **new taught obligation** ([§11.6][s11-6], [Appendix A][sA]): `shutdown!` must
tolerate a **partially initialized** device — "close only what is open" — the
same defensiveness the crash path already demands. **No new diagnostic kind**:
`DeviceCrash`'s payload (device id, `cause`, whether `should_abort` was set)
already fits an init-time failure, [Appendix C][sC]'s gloss merely naming the site. A
failed device is **dead from boundary zero** with no dead-marking machinery of
its own — it never stores a heartbeat timestamp, so its cell reads stale
against [§12.2][s12-2]'s threshold from the first frame ([§11.8][s11-8], [D-136][d-136]) — and its **claims
persist to run end**: [§11.3][s11-3]'s death-is-not-detach disposition applied one step
earlier than [§12.4][s12-4](6)'s, the orphaned slots holding their initial values,
well-defined by [§14.6][s14-6]'s slot totality where a (6) orphan holds a last drained
batch. **Run disposition splits on `should_abort`, uniformly with (6)**: clear
(the default) the remaining entries initialize, the run starts and the sim runs
with the device absent from frame zero — (6)'s semantics shifted to `t₀`; set,
the failure requests a control-plane stop that is **already pending at boundary
zero**, so the run reuses [§13.5][s13-5]'s existing terminal-at-`t₀` path — remaining
entries still initialize, every rostered device getting its `init!`/`shutdown!`
pair uniformly, boundary zero is published, the run ends `stopped` at `t₀`
through the ordinary [§12.4][s12-4] tail and the termination record names the source.
**Topology is derived after initialization** ([§11.1][s11-1]): a failed
`needs_calling_task` holder returns the loop to the calling task rather than
parking it on a device that will not exist. Finally `should_abort` gets the
**declaration site** it never had: an **`attach!` keyword, default `false`** —
matching (6)'s narrative default ("the sim continues with the device absent"; a
dead joystick must not kill a session) — with the **shipped GUI attaching
`should_abort = true`** (closing the window is the interactive session's
natural end) and `gui = true`'s standard attachment stating that value
([Appendix B][sB], [D-134][d-134]'s sugar unchanged); [Appendix D][sD] gains the glossary entry.

Annotation (2026-10-13): since D-310, `needs_calling_task` and `gui = true`
are withdrawn and no GUI ships, so the topology clause and the shipped GUI's
`should_abort = true` are historical. "Marks it dead" in the Position means no
task is spawned and the record shows it; nothing else marks a device dead
(D-160's annotation).

**Rejected.**
- *Requiring `init!` to clean up after itself on failure:* an unenforced burden
````

### 2.6. B-39 D-102

Old:

````text
Annotation (2026-10-13): amended by [D-366][d-366]. Only `loop` is mandatory;
`init!`, `shutdown!` and `unblock!` are optional hooks with no-op defaults.

**Rejected.**
- *Framework-owned hook loop (FlightCore's shape):* its eight hooks were never
````

New:

````text
Annotation (2026-10-13): amended by [D-366][d-366]. Only `loop` is mandatory;
`init!`, `shutdown!` and `unblock!` are optional hooks with no-op defaults.

Annotation (2026-10-13): since D-310 every rostered device, the GUI included,
runs on a spawned task, so the inline clause is historical, and claims stay to
run end (D-106).

**Rejected.**
- *Framework-owned hook loop (FlightCore's shape):* its eight hooks were never
````

### 2.7. B-39 D-093

Old:

````text
**Rationale.** [§12.4][s12-4] joins all tasks at every stop with `shutdown!` releasing
OS resources; what persists across `stopped → init! → run!` is the roster entry
(binding, claims, stable device id); spawn-inside-`run!` replaces the start
gate, and first-boundary synchronization is [§12.3][s12-3]'s counter-plus-condition
predicate wait; `should_close` and the [§12.2][s12-2] liveness heartbeat are run-scoped,
unplug-while-stopped surfaces as the next run's device-`init!` failure. The GUI
is the one rostered device *without* a spawned task — CImGui pins rendering to
the calling task, so the loop is the movable piece: with a calling-task device
rostered the loop moves to a spawned task for the run — roster-derived, `gui =
true` mere ensure-rostered sugar ([D-109][d-109]) — otherwise the loop runs on the
calling task (preserving [§13.4][s13-4]'s synchronous rethrow and inline threading of
parallel batch sweeps); `run!` blocks its caller either way. Stepping sessions
are deviceless by construction (`attach!` registers only, tasks appear at the
next `run!`); the write/read paths while stepping are [D-096][d-096]'s harness writer;
`init!` discards staged batches along with trace and log.

**Rejected.**
- *`Event` start gate "as today":* [§12.3][s12-3]'s rejected primitive — the `io_start`
````

New:

````text
**Rationale.** [§12.4][s12-4] joins all tasks at every stop with `shutdown!` releasing
OS resources; what persists across `stopped → init! → run!` is the roster entry
(binding, claims, stable device id); spawn-inside-`run!` replaces the start
gate, and first-boundary synchronization is [§12.3][s12-3]'s counter-plus-condition
predicate wait; `should_close` and the [§12.2][s12-2] liveness heartbeat are run-scoped,
unplug-while-stopped surfaces as the next run's device-`init!` failure. The GUI
is the one rostered device *without* a spawned task — CImGui pins rendering to
the calling task, so the loop is the movable piece: with a calling-task device
rostered the loop moves to a spawned task for the run — roster-derived, `gui =
true` mere ensure-rostered sugar ([D-109][d-109]) — otherwise the loop runs on the
calling task (preserving [§13.4][s13-4]'s synchronous rethrow and inline threading of
parallel batch sweeps); `run!` blocks its caller either way. Stepping sessions
are deviceless by construction (`attach!` registers only, tasks appear at the
next `run!`); the write/read paths while stepping are [D-096][d-096]'s harness writer;
`init!` discards staged batches along with trace and log.

Annotation (2026-10-13): since D-310 every rostered device, the GUI included,
runs on a spawned task, so the GUI-without-task clause and the movable loop
are historical.

**Rejected.**
- *`Event` start gate "as today":* [§12.3][s12-3]'s rejected primitive — the `io_start`
````

### 2.8. B-39 D-132

Old:

````text
**Rationale.** **Boundary masking is normative**, not an implementation hint:
because `InterruptException` is asynchronous, the loop masks delivery across
the boundary macro-sequence (Julia's `disable_sigint`, a sigatomic counter
increment per frame) and takes the deferred raise at the unmask points — frame
top, wait and pause blocks — all boundary-consistent; the
`stopped`-with-consistent-stores guarantee depends on it. Two discrimination
clauses fall out: [§13.4][s13-4]'s catch site never wraps an `InterruptException` in
`StepError` (routes it to the stop path; unreachable in practice under masking,
kept defensively), and [§11.6][s11-6]'s device wrapper never turns one into `DeviceCrash`
— in the spawned-loop topology Ctrl-C lands in the calling task's inline device
loop body (the GUI), which forwards the stop and exits through the ordinary
`running(handle)` predicate, no `should_abort` consultation. A **second**
interrupt during the tail collapses the remaining device joins immediately —
[§12.4][s12-4](5)'s abandonment path taken at once, devices still named — and the run
still ends `stopped`; escalation shortens the tail, never reclassifies the run,
and cannot repair [§12.4][s12-4](5)'s honest asymmetry (nothing can abandon the task
`run!` stands on). Scope is the **interactive session**: outside the REPL
Julia's default `exit_on_sigint(true)` kills the process on SIGINT first, the
framework flips nothing process-global, and unattended runs rely on
`t_end`/`stop_on` as they already must. The termination record tags the stop
source ([§13.5][s13-5]), distinguishing it from `t_end`, `stop_on` and a
programmatic/GUI stop, with no new diagnostic kind; `UnboundedRun` ([Appendix C][sC])
names it as the sanctioned escape from the configuration it warns about; and
the services need no story of their own — an interrupt during a long `trim!`
unwinds an ordinary call over per-invocation scratch stores, no commit having
happened ([§14.8][s14-8]). Precedent correction, recorded because it is easy to miscite:
FlightCore's `interrupt!` (iodevices.jl:36, its one override closing UDPInput's
socket at shutdown) is a per-device unblocking hook — the direct precedent of
[§12.4][s12-4](3)'s `unblock!`, not of this path; FlightCore has no
`InterruptException`/SIGINT handling anywhere.

**Rejected.**
- *Treating the interrupt as a runtime failure — the `StepError` path an
````

New:

````text
**Rationale.** **Boundary masking is normative**, not an implementation hint:
because `InterruptException` is asynchronous, the loop masks delivery across
the boundary macro-sequence (Julia's `disable_sigint`, a sigatomic counter
increment per frame) and takes the deferred raise at the unmask points — frame
top, wait and pause blocks — all boundary-consistent; the
`stopped`-with-consistent-stores guarantee depends on it. Two discrimination
clauses fall out: [§13.4][s13-4]'s catch site never wraps an `InterruptException` in
`StepError` (routes it to the stop path; unreachable in practice under masking,
kept defensively), and [§11.6][s11-6]'s device wrapper never turns one into `DeviceCrash`
— in the spawned-loop topology Ctrl-C lands in the calling task's inline device
loop body (the GUI), which forwards the stop and exits through the ordinary
`running(handle)` predicate, no `should_abort` consultation. A **second**
interrupt during the tail collapses the remaining device joins immediately —
[§12.4][s12-4](5)'s abandonment path taken at once, devices still named — and the run
still ends `stopped`; escalation shortens the tail, never reclassifies the run,
and cannot repair [§12.4][s12-4](5)'s honest asymmetry (nothing can abandon the task
`run!` stands on). Scope is the **interactive session**: outside the REPL
Julia's default `exit_on_sigint(true)` kills the process on SIGINT first, the
framework flips nothing process-global, and unattended runs rely on
`t_end`/`stop_on` as they already must. The termination record tags the stop
source ([§13.5][s13-5]), distinguishing it from `t_end`, `stop_on` and a
programmatic/GUI stop, with no new diagnostic kind; `UnboundedRun` ([Appendix C][sC])
names it as the sanctioned escape from the configuration it warns about; and
the services need no story of their own — an interrupt during a long `trim!`
unwinds an ordinary call over per-invocation scratch stores, no commit having
happened ([§14.8][s14-8]). Precedent correction, recorded because it is easy to miscite:
FlightCore's `interrupt!` (iodevices.jl:36, its one override closing UDPInput's
socket at shutdown) is a per-device unblocking hook — the direct precedent of
[§12.4][s12-4](3)'s `unblock!`, not of this path; FlightCore has no
`InterruptException`/SIGINT handling anywhere.

Annotation (2026-10-13): since D-310 every rostered device, the GUI included,
runs on a spawned task, so the topology clause is historical; the wrapper's
discrimination stands on the Position, an operator interrupt being a
control-plane stop, not a failure.

**Rejected.**
- *Treating the interrupt as a runtime failure — the `StepError` path an
````

### 2.9. B-39 D-025

Old:

````text
**Rationale.** Recorded only through the rejections below.

**Rejected.**
- *Input/output/GUI taxonomy:* lock choreography artifact — blocking rules of
````

New:

````text
**Rationale.** Recorded only through the rejections below.

Annotation (2026-10-13): since D-310 every rostered device, the GUI included,
runs on a spawned task, so main-thread affinity is gone, and widgets that
read, modify and write remain the GUI's one peculiarity.

**Rejected.**
- *Input/output/GUI taxonomy:* lock choreography artifact — blocking rules of
````

### 2.10. B-40 D-044

Old:

````text
**Rationale.** Recorded only through the rejections below.

**Rejected.**
- *Cross-device attachment-order precedence as conflict policy:* resolves races
````

New:

````text
**Rationale.** Recorded only through the rejections below.

Annotation (2026-10-13): amended by D-174. The derived interactive surface is
retired; the GUI is an ordinary enumerated writer, and the harness writer is
the one derived surface.

**Rejected.**
- *Cross-device attachment-order precedence as conflict policy:* resolves races
````

### 2.11. B-40 D-106

Old:

````text
**Rationale.** All write-surface checks move to staging and the drain is pure
application, fully compilable against the frozen roster (specialization an
implementation freedom, not an obligation — the [§9.7][s9-7] per-configuration compile
trade); device death mid-run is not detach — the task dies, the heartbeat
reports it, claims and roster entry persist to run end (**reversal of [D-087][d-087]'s
zombie-claims rejection**: that rejection served dynamic liveness derivation,
and with liveness baked per run the rationale inverts — a mid-run release would
move a surface nothing can soundly recompute); orphan recovery is between runs
(stop → `detach!` → `init!`, or `replay!`-to-end + `run!` continuation, [§12.7][s12-7]);
[§12.5][s12-5]'s doctrine reaches final form — the running periphery stages writes and
issues control commands, and nothing else changes. **Guarded addition on
record**: mid-run attach for pure readers (no input half — claims nothing,
moves no surface; a dynamic reader list touches only [§12.3][s12-3] wakeups, heartbeat
and shutdown join, never the drain), cleanly severable should
join-a-running-session find a customer. Supporting fact: FlightCore has no
mid-run attach — every demo attaches before `run!`, and `run!` blocks its
caller in both designs, so the dropped capability had no demonstrated customer
and was barely reachable.

**Rejected.**
- *The earlier attach-anytime design of record:* [D-087][d-087]'s republished-roster
````

New:

````text
**Rationale.** All write-surface checks move to staging and the drain is pure
application, fully compilable against the frozen roster (specialization an
implementation freedom, not an obligation — the [§9.7][s9-7] per-configuration compile
trade); device death mid-run is not detach — the task dies, the heartbeat
reports it, claims and roster entry persist to run end (**reversal of [D-087][d-087]'s
zombie-claims rejection**: that rejection served dynamic liveness derivation,
and with liveness baked per run the rationale inverts — a mid-run release would
move a surface nothing can soundly recompute); orphan recovery is between runs
(stop → `detach!` → `init!`, or `replay!`-to-end + `run!` continuation, [§12.7][s12-7]);
[§12.5][s12-5]'s doctrine reaches final form — the running periphery stages writes and
issues control commands, and nothing else changes. **Guarded addition on
record**: mid-run attach for pure readers (no input half — claims nothing,
moves no surface; a dynamic reader list touches only [§12.3][s12-3] wakeups, heartbeat
and shutdown join, never the drain), cleanly severable should
join-a-running-session find a customer. Supporting fact: FlightCore has no
mid-run attach — every demo attaches before `run!`, and `run!` blocks its
caller in both designs, so the dropped capability had no demonstrated customer
and was barely reachable.

Annotation (2026-10-13): amended by D-174. The derived interactive surface is
retired; the GUI is an ordinary enumerated writer, and the harness writer is
the one derived surface.

**Rejected.**
- *The earlier attach-anytime design of record:* [D-087][d-087]'s republished-roster
````

### 2.12. B-40 D-104

Old:

````text
**Rationale.** The interactive writer gets the same treatment under the [D-106][d-106]
freeze — positional shape over the unclaimed set, recompiled at each
stopped-sim `attach!`/`detach!` (which also renormalizes pending batches:
reshape, discard newly-claimed faces with `ClaimedFaceEntry`) — one
representation, no name resolved inside the loop's frame; diagnostic sites all
at staging — `OutOfClaimEntry`, `ClaimedFaceEntry`, `EntryTypeMismatch` — and
the drain checks nothing ([D-106][d-106]); trace records match batch density ([D-107][d-107]);
user-proposed shape (fixed tuple with `nothing` markers), framework-relocated
normalization.

**Rejected.**
- *Name-keyed interactive batches, the earlier design of record:* justified
````

New:

````text
**Rationale.** The interactive writer gets the same treatment under the [D-106][d-106]
freeze — positional shape over the unclaimed set, recompiled at each
stopped-sim `attach!`/`detach!` (which also renormalizes pending batches:
reshape, discard newly-claimed faces with `ClaimedFaceEntry`) — one
representation, no name resolved inside the loop's frame; diagnostic sites all
at staging — `OutOfClaimEntry`, `ClaimedFaceEntry`, `EntryTypeMismatch` — and
the drain checks nothing ([D-106][d-106]); trace records match batch density ([D-107][d-107]);
user-proposed shape (fixed tuple with `nothing` markers), framework-relocated
normalization.

Annotation (2026-10-13): amended by D-174. The derived interactive surface is
retired; the GUI is an ordinary enumerated writer, and the harness writer is
the one derived surface. The carrier is values-plus-mask since D-202.

**Rejected.**
- *Name-keyed interactive batches, the earlier design of record:* justified
````

### 2.13. B-41 D-134

Old:

````text
**Rationale.** Completes [D-044][d-044]'s partition. `interactive` defined ⇒ derived
write side: no claims staked, and [§11.4][s11-4]'s positional staging shape compiled over
the unclaimed face set instead (that compilation already existed; it now has
its declared trigger). `interactive` and `faces` are **mutually exclusive** (a
surface cannot be enumerated and derived at once — attach-time error naming
both declarations); `interactive` is orthogonal to `selectors` (an interactive
front end may also drive a compiled output gather — legal, currently
uninstantiated, the plausible customer a narrow-wire interactive surface such
as a motorized control board); "neither ⇒ error" becomes "none of the three ⇒
attach-time error". **At most one interactive device per roster**, beside the
always-present harness cell: a fourth part of the attach-time admission check,
in `needs_calling_task`'s shape and error style (`InteractiveConflict`, naming
both the rostered holder and the candidate, exactly as `CallerTaskConflict`
does) — the derived surface is shared rather than partitioned, and the
singleton keeps intra-surface drain order trivial (interactive device, then
the harness cell last). The shipped GUI binding is the class's **sole shipped
instance**, declaring `interactive` only: no `faces` (its surface is computed),
no `selectors` (its read path is the handle's primitive read — VSync-paced
`latest` per render, [§12.3][s12-3] — with an ad-hoc render-time read set over the whole
snapshot in an inspection read's shape, [§11.2][s11-2], so the compiled gather has
nothing to do for it); `gui = true` becomes "attach the standard GUI device
under the standard interactive binding iff no interactive device is already
rostered" ([D-109][d-109]'s idempotency, now stated against the class rather than the
type). Two non-reopenings are on record: [§11.6][s11-6]'s rejected `sides(b)` trait is
*not* what this marker revives — that rejection turns on redundancy with
methods that must exist anyway, and nothing analogous exists here, the derived
surface being computed, so no method's presence could witness the class and a
marker is the only possible declaration, not a second copy of a fact; and
[D-044][d-044]'s rejection of unclaimed-surface opportunism "for any device" stands
unchanged — autonomous devices still enumerate, the interactive writer stays
human-mediated, singleton-limited and staging-checked (`ClaimedFaceEntry`
untouched). The marker makes the privileged class visible and checkable, not
open.

**Rejected.**
- *`faces(b) = :derived` (a sentinel return):* i.e. a dual-meaning enumeration
````

New:

````text
**Rationale.** Completes [D-044][d-044]'s partition. `interactive` defined ⇒ derived
write side: no claims staked, and [§11.4][s11-4]'s positional staging shape compiled over
the unclaimed face set instead (that compilation already existed; it now has
its declared trigger). `interactive` and `faces` are **mutually exclusive** (a
surface cannot be enumerated and derived at once — attach-time error naming
both declarations); `interactive` is orthogonal to `selectors` (an interactive
front end may also drive a compiled output gather — legal, currently
uninstantiated, the plausible customer a narrow-wire interactive surface such
as a motorized control board); "neither ⇒ error" becomes "none of the three ⇒
attach-time error". **At most one interactive device per roster**, beside the
always-present harness cell: a fourth part of the attach-time admission check,
in `needs_calling_task`'s shape and error style (`InteractiveConflict`, naming
both the rostered holder and the candidate, exactly as `CallerTaskConflict`
does) — the derived surface is shared rather than partitioned, and the
singleton keeps intra-surface drain order trivial (interactive device, then
the harness cell last). The shipped GUI binding is the class's **sole shipped
instance**, declaring `interactive` only: no `faces` (its surface is computed),
no `selectors` (its read path is the handle's primitive read — VSync-paced
`latest` per render, [§12.3][s12-3] — with an ad-hoc render-time read set over the whole
snapshot in an inspection read's shape, [§11.2][s11-2], so the compiled gather has
nothing to do for it); `gui = true` becomes "attach the standard GUI device
under the standard interactive binding iff no interactive device is already
rostered" ([D-109][d-109]'s idempotency, now stated against the class rather than the
type). Two non-reopenings are on record: [§11.6][s11-6]'s rejected `sides(b)` trait is
*not* what this marker revives — that rejection turns on redundancy with
methods that must exist anyway, and nothing analogous exists here, the derived
surface being computed, so no method's presence could witness the class and a
marker is the only possible declaration, not a second copy of a fact; and
[D-044][d-044]'s rejection of unclaimed-surface opportunism "for any device" stands
unchanged — autonomous devices still enumerate, the interactive writer stays
human-mediated, singleton-limited and staging-checked (`ClaimedFaceEntry`
untouched). The marker makes the privileged class visible and checkable, not
open.

Annotation (2026-10-13): §11.6 no longer detects sides by method presence.
D-177 declares them, and D-174 replaced the `interactive(b)` marker with
`is_greedy`.

**Rejected.**
- *`faces(b) = :derived` (a sentinel return):* i.e. a dual-meaning enumeration
````

### 2.14. B-42 D-045

Old:

````text
**Rationale.** Recorded only through the rejections below.

**Rejected.**
- *Per-port "GUI-controlled" markings:* the export chain is the marking, owned
````

New:

````text
**Rationale.** Recorded only through the rejections below.

Annotation (2026-10-13): since D-174 the GUI is an enumerated writer, so "slot
unclaimed" reads "slot inside the GUI's own claim"; a face outside it is
`OutOfClaimEntry` (D-044).

**Rejected.**
- *Per-port "GUI-controlled" markings:* the export chain is the marking, owned
````

### 2.15. B-43 D-026

Old:

````text
**Rationale.** Recorded only through the rejections below.

**Rejected.**
- *Superseded position — staging every render pass (the earlier design of
````

New:

````text
**Rationale.** Recorded only through the rejections below.

Annotation (2026-10-13): resolution is baked at run start, when the GUI's loop
body builds its port views after the roster freeze (D-270), not at build.

**Rejected.**
- *Superseded position — staging every render pass (the earlier design of
````

### 2.16. B-44 D-096

Old:

````text
**Rationale.** `latest(sim)` = the current published snapshot, the same
immutable value device handles read; `step!` gains the duration spelling
`t_plus` (whole frames until the boundary time covers the duration, mutually
exclusive with `frames`); together the write/read halves of [D-088][d-088]'s
advance-assert and fly-inspect idioms and the migration path for the suite's
dominant write-`u` → `step!` → assert idiom.

**Rejected.**
- *A special harness device:* a device with no task is `stage!` with extra
````

New:

````text
**Rationale.** `latest(sim)` = the current published snapshot, the same
immutable value device handles read; `step!` gains the duration spelling
`t_plus` (whole frames until the boundary time covers the duration, mutually
exclusive with `frames`); together the write/read halves of [D-088][d-088]'s
advance-assert and fly-inspect idioms and the migration path for the suite's
dominant write-`u` → `step!` → assert idiom.

Annotation (2026-10-13): `stage!` runs on any task (D-200) and writes the
harness writer's cell (D-174). The harness cell still drains last, now as
plain convention; the stated reason is objectless once surfaces are disjoint
(D-174).

**Rejected.**
- *A special harness device:* a device with no task is `stage!` with extra
````

### 2.17. B-45 D-136

Old:

````text
**Rationale.** The bound **is** the rate limit — an emission past capacity
within a frame is not stored and its kind's count increments, earliest-in-frame
retained — which homes [§13.2][s13-2]'s "rate-limited wherever its source can repeat" as
a structural property of the channel and discharges [D-133][d-133]'s deferral with no
constant to tune. The loop takes each cell with `atomicswap` at the **frame-top
drain**, [§11.4][s11-4]'s own point, swapping in a **shared empty sentinel** so a quiet
frame allocates nothing and no load-only path goes untested; the heartbeat
rides in the same cell — stored on every loop pass from inside the handle
primitives ([§11.6][s11-6]), acquire-loaded at the drain, [§12.2][s12-2]'s 2 s staleness read
against this field, and not a diagnostic kind. The published **framework status
becomes a concrete frozen value**: per writer `recent` (this boundary's drained
ring), `suppressed` (the per-kind counts the ring refused this boundary),
`totals` (loop-owned cumulative per-writer × per-kind counters, *copied* into
each status) and `heartbeat`, beside [§10.7][s10-7]'s pacer diagnostics — [§11.2][s11-2]'s binding
rule holding **by construction**, since the swap gives the loop exclusive
ownership of the batch before publication and the live accumulator is never
reachable from a snapshot. Presentation is separated from channel policy:
renderers print a writer × kind up to **25 cumulative occurrences** and then
switch to count-only display (the `maxlog` successor), counts accumulating
regardless; and the **terminal snapshot carries the final cumulative counters**
([§12.4][s12-4](1), [§13.5][s13-5]), so an unattended run's complete diagnostic account survives
its own shutdown. The allocation story is spec-stated: a quiet frame adds
**zero heap allocation**, the per-writer status riding inline in the
per-boundary snapshot allocation [§11.2][s11-2] already accepted — which requires the
per-kind counters to be a **fixed-shape isbits record, never a `Dict`**,
licensed by [Appendix C][sC]'s closed kind set — while a noisy frame allocates its
values at emission on the writer's own task and a **fresh ring** lazily at the
writer's next emission (the drained one being frozen into a snapshot and
unwritable thereafter), the same GC-over-reuse trade [§11.2][s11-2] made when it rejected
preallocated snapshot buffers; worst case per writer per boundary is therefore
one ring of 16, everything past it an integer increment, and [§9.8][s9-8]'s scoped
model-sweep zero-allocation invariant is untouched. Composition note, recorded
once: `totals` is monotone across logged snapshots, so `log_every` decimation
loses *which* boundary in a skipped stretch an occurrence fell on, never *how
many*.

**Rejected.**
- *A shared queue or buffer under a lock:* cross-task contention on the loop's
````

New:

````text
**Rationale.** The bound **is** the rate limit — an emission past capacity
within a frame is not stored and its kind's count increments, earliest-in-frame
retained — which homes [§13.2][s13-2]'s "rate-limited wherever its source can repeat" as
a structural property of the channel and discharges [D-133][d-133]'s deferral with no
constant to tune. The loop takes each cell with `atomicswap` at the **frame-top
drain**, [§11.4][s11-4]'s own point, swapping in a **shared empty sentinel** so a quiet
frame allocates nothing and no load-only path goes untested; the heartbeat
rides in the same cell — stored on every loop pass from inside the handle
primitives ([§11.6][s11-6]), acquire-loaded at the drain, [§12.2][s12-2]'s 2 s staleness read
against this field, and not a diagnostic kind. The published **framework status
becomes a concrete frozen value**: per writer `recent` (this boundary's drained
ring), `suppressed` (the per-kind counts the ring refused this boundary),
`totals` (loop-owned cumulative per-writer × per-kind counters, *copied* into
each status) and `heartbeat`, beside [§10.7][s10-7]'s pacer diagnostics — [§11.2][s11-2]'s binding
rule holding **by construction**, since the swap gives the loop exclusive
ownership of the batch before publication and the live accumulator is never
reachable from a snapshot. Presentation is separated from channel policy:
renderers print a writer × kind up to **25 cumulative occurrences** and then
switch to count-only display (the `maxlog` successor), counts accumulating
regardless; and the **terminal snapshot carries the final cumulative counters**
([§12.4][s12-4](1), [§13.5][s13-5]), so an unattended run's complete diagnostic account survives
its own shutdown. The allocation story is spec-stated: a quiet frame adds
**zero heap allocation**, the per-writer status riding inline in the
per-boundary snapshot allocation [§11.2][s11-2] already accepted — which requires the
per-kind counters to be a **fixed-shape isbits record, never a `Dict`**,
licensed by [Appendix C][sC]'s closed kind set — while a noisy frame allocates its
values at emission on the writer's own task and a **fresh ring** lazily at the
writer's next emission (the drained one being frozen into a snapshot and
unwritable thereafter), the same GC-over-reuse trade [§11.2][s11-2] made when it rejected
preallocated snapshot buffers; worst case per writer per boundary is therefore
one ring of 16, everything past it an integer increment, and [§9.8][s9-8]'s scoped
model-sweep zero-allocation invariant is untouched. Composition note, recorded
once: `totals` is monotone across logged snapshots, so `log_every` decimation
loses *which* boundary in a skipped stretch an occurrence fell on, never *how
many*.

Annotation (2026-10-13): amended by D-200 (the harness writer's cell), D-317
(the `Model`'s cell, folded into the loop's account), D-240 (the heartbeat is
read at publication) and D-241 (one small vector of records per publication).
The zero-allocation invariant is scoped to the stepping loop (D-305).

**Rejected.**
- *A shared queue or buffer under a lock:* cross-task contention on the loop's
````

### 2.18. B-46 D-024

Old:

````text
**Rationale.** Recorded only through the rejections below.

**Rejected.**
- *Superseded position — attachment order as the cross-device conflict
````

New:

````text
**Rationale.** Recorded only through the rejections below.

Annotation (2026-10-13): amended by D-104, whose one policy, CAS merge, holds
for every writer, so no writer overwrites. Several tasks may stage into the
harness writer's cell at once, so its retry is not bounded by drain
interception alone (D-200).

**Rejected.**
- *Superseded position — attachment order as the cross-device conflict
````

### 2.19. B-46 D-038

Old:

````text
**Rationale.** Recorded only through the rejections below.

**Rejected.**
- *Per-boundary full-state capture:* systematically records derived data —
````

New:

````text
**Rationale.** Recorded only through the rejections below.

Annotation (2026-10-13): no private cells remain to include or filter (D-165,
D-194), and the full-state capture is the checkpoint's, which the trace header
now is (D-274).

**Rejected.**
- *Per-boundary full-state capture:* systematically records derived data —
````

### 2.20. B-46 D-083

Old:

````text
**Rationale.** Attach validation against the `Build` makes structural drift
loud; two-sided guidance — deep path = inspection (zero promises, right for
this build), exported output face = integration (curated writer-independent
meaning, the only shield against silent semantic drift under
same-path/same-type substitution); generic consumers bind faces, aircraft
families export conventional surfaces with wrapper types (`VelocityData` —
field meaning defined at the type; wrong quantity = deliberate lie, not drift)
as the checkable fraction of semantics; [§13.5][s13-5]'s observation-by-path rejection
rests on the service/inspection split alone.

**Rejected.**
- *Faces-only reads:* export bloat: the root contract as a peripheral dumping
````

New:

````text
**Rationale.** Attach validation against the `Build` makes structural drift
loud; two-sided guidance — deep path = inspection (zero promises, right for
this build), exported output face = integration (curated writer-independent
meaning, the only shield against silent semantic drift under
same-path/same-type substitution); generic consumers bind faces, aircraft
families export conventional surfaces with wrapper types (`VelocityData` —
field meaning defined at the type; wrong quantity = deliberate lie, not drift)
as the checkable fraction of semantics; [§13.5][s13-5]'s observation-by-path rejection
rests on the service/inspection split alone.

Annotation (2026-10-13): no local cells remain (D-165, D-194), so the clause
on local cells and presentation filters is historical.

**Rejected.**
- *Faces-only reads:* export bloat: the root contract as a peripheral dumping
````

### 2.21. B-46 D-098

Old:

````text
**Rationale.** A snapshot-bound reader naming a store selector is an
attach-time `ReadBindingUnresolved` (new `reason` payload field), didactic
style, remedy = declare the field public and read the auto-published port;
[D-083][d-083]'s client split rides on top unchanged, [D-095][d-095]'s family stays closed and
identically spelled.

**Rejected.**
- *Client-only validation:* [D-095][d-095]'s original "diagnostic readers admit the
````

New:

````text
**Rationale.** A snapshot-bound reader naming a store selector is an
attach-time `ReadBindingUnresolved` (new `reason` payload field), didactic
style, remedy = declare the field public and read the auto-published port;
[D-083][d-083]'s client split rides on top unchanged, [D-095][d-095]'s family stays closed and
identically spelled.

Annotation (2026-10-13): D-252 removed auto-publication, so the remedy is to
return the field from `output_state`.

**Rejected.**
- *Client-only validation:* [D-095][d-095]'s original "diagnostic readers admit the
````

### 2.22. B-46 D-105

Old:

````text
**Rationale.** Classification is the author's, as FlightCore's
`InputMappingError` docstring already assigned it; `report(handle, …)` is
scoped to device-attributed runtime warnings, not a general user-diagnostics
channel; companion drain-family kind `EntryTypeMismatch` for values
unconvertible to the slot's declared type, checked at staging for every writer.

**Rejected.**
- *A marked exception type (`InputMappingError` successor):* vestigial under
````

New:

````text
**Rationale.** Classification is the author's, as FlightCore's
`InputMappingError` docstring already assigned it; `report(handle, …)` is
scoped to device-attributed runtime warnings, not a general user-diagnostics
channel; companion drain-family kind `EntryTypeMismatch` for values
unconvertible to the slot's declared type, checked at staging for every writer.

Annotation (2026-10-13): the rate limit is the diagnostic cell's bound, and 25
is a renderer's number (D-136).

**Rejected.**
- *A marked exception type (`InputMappingError` successor):* vestigial under
````

### 2.23. B-46 D-137

Old:

````text
**Rationale.** **A count, not a memory budget**: snapshots are immutable object
graphs with internal sharing ([§4.1][s4-1], and [§4.4][s4-4] field handles riding as references
to build-time-frozen data, [§9.8][s9-8]), so byte accounting over them is fuzzy and
platform-dependent, while a count is exact and converts to memory through one
number the user measures once (`Base.summarysize` of a single snapshot).
**Default 65536 (2¹⁶), finite unconditionally**, with `Inf` the explicit
opt-out — no modal rule keyed on `t_end`; a finite run shorter than the bound
never notices it, and at 50 Hz full density 2¹⁶ boundaries is ≈22 minutes
before the first drop. **When the log fills, the effective retention stride
doubles** — `log_every · 2^k` after k generations — so the bound holds while
coverage stays **global**: the whole run remains plottable at coarsening
density, which is [D-038][d-038]'s division of labor carried through (the log's chief
consumer is the post-run plot of a session as a whole; full density over any
*segment* of interest is what replay from the trace recovers, [§11.5][s11-5], [§12.7][s12-7]). The
licence is [D-038][d-038]'s own asymmetry, a fortiori: a thinned log costs resolution in
a *view*, never a record, whereas [D-029][d-029]'s refusal to thin the trace stands
untouched. Following [D-135][d-135]'s precedent, **the guarantees are normative and the
mechanism a sketch**: normatively the retained count never exceeds `log_max`,
coverage is global at the effective stride, and the endpoints are kept; the
sketch is that the thinning is **amortized** — the stride doubles immediately
and each subsequent retained append also releases one predecessor of the
previous generation (a cursor over the odd indices, O(1) amortized, physical
compaction once per generation), the generation's thinning completing exactly
when its refill does. Amortization is a responsiveness choice: a one-shot
halving would make ~`log_max/2` *old-generation* snapshots unreachable at a
stroke, a major-GC burst worth a pacer-absorbed, `DebtReanchor`-visible hiccup
([§10.7][s10-7]) — exponentially rare, the wall-clock gap between generations doubling,
but needless — while the amortized form drops exactly one old snapshot per
retained append, the steady trickle a rolling window would produce anyway; the
loop's own work is pointer bookkeeping, microseconds either way and on the
framework side of [§9.8][s9-8]'s scope, publication staying wait-free with readers
never blocking. **The boundary-zero ([§14.5][s14-5]) and terminal ([§12.4][s12-4](1), [§13.5][s13-5])
snapshots are retained unconditionally under any `log_every` and any `log_max`,
and do not count against the bound** — two extra references — so the run's
endpoints and, via the terminal status's final cumulative counters ([§11.8][s11-8],
[D-136][d-136]), its complete diagnostic account always survive. Compositions stated
once: `totals` monotonicity across logged snapshots ([§11.8][s11-8]) is unaffected,
re-decimation losing *which* boundary in a stretch an occurrence fell on and
never *how many*; and `log_max` is a **view policy, not
trajectory-determining** — outside the trace header's deployment block, neither
recorded nor compared by replay ([D-127][d-127], [D-133][d-133]'s compared set untouched). [§9.8][s9-8]'s
`sizehint!` for the expected duration is reconciled: now capped by `log_max`,
which is also what defines the hint when `t_end = Inf`. No new diagnostic kind
— hitting the bound is stated policy, not an event to report.

**Rejected.**
- *A rolling window:* optimizes recent-past-at-full-density, which replay
````

New:

````text
**Rationale.** **A count, not a memory budget**: snapshots are immutable object
graphs with internal sharing ([§4.1][s4-1], and [§4.4][s4-4] field handles riding as references
to build-time-frozen data, [§9.8][s9-8]), so byte accounting over them is fuzzy and
platform-dependent, while a count is exact and converts to memory through one
number the user measures once (`Base.summarysize` of a single snapshot).
**Default 65536 (2¹⁶), finite unconditionally**, with `Inf` the explicit
opt-out — no modal rule keyed on `t_end`; a finite run shorter than the bound
never notices it, and at 50 Hz full density 2¹⁶ boundaries is ≈22 minutes
before the first drop. **When the log fills, the effective retention stride
doubles** — `log_every · 2^k` after k generations — so the bound holds while
coverage stays **global**: the whole run remains plottable at coarsening
density, which is [D-038][d-038]'s division of labor carried through (the log's chief
consumer is the post-run plot of a session as a whole; full density over any
*segment* of interest is what replay from the trace recovers, [§11.5][s11-5], [§12.7][s12-7]). The
licence is [D-038][d-038]'s own asymmetry, a fortiori: a thinned log costs resolution in
a *view*, never a record, whereas [D-029][d-029]'s refusal to thin the trace stands
untouched. Following [D-135][d-135]'s precedent, **the guarantees are normative and the
mechanism a sketch**: normatively the retained count never exceeds `log_max`,
coverage is global at the effective stride, and the endpoints are kept; the
sketch is that the thinning is **amortized** — the stride doubles immediately
and each subsequent retained append also releases one predecessor of the
previous generation (a cursor over the odd indices, O(1) amortized, physical
compaction once per generation), the generation's thinning completing exactly
when its refill does. Amortization is a responsiveness choice: a one-shot
halving would make ~`log_max/2` *old-generation* snapshots unreachable at a
stroke, a major-GC burst worth a pacer-absorbed, `DebtReanchor`-visible hiccup
([§10.7][s10-7]) — exponentially rare, the wall-clock gap between generations doubling,
but needless — while the amortized form drops exactly one old snapshot per
retained append, the steady trickle a rolling window would produce anyway; the
loop's own work is pointer bookkeeping, microseconds either way and on the
framework side of [§9.8][s9-8]'s scope, publication staying wait-free with readers
never blocking. **The boundary-zero ([§14.5][s14-5]) and terminal ([§12.4][s12-4](1), [§13.5][s13-5])
snapshots are retained unconditionally under any `log_every` and any `log_max`,
and do not count against the bound** — two extra references — so the run's
endpoints and, via the terminal status's final cumulative counters ([§11.8][s11-8],
[D-136][d-136]), its complete diagnostic account always survive. Compositions stated
once: `totals` monotonicity across logged snapshots ([§11.8][s11-8]) is unaffected,
re-decimation losing *which* boundary in a stretch an occurrence fell on and
never *how many*; and `log_max` is a **view policy, not
trajectory-determining** — outside the trace header's deployment block, neither
recorded nor compared by replay ([D-127][d-127], [D-133][d-133]'s compared set untouched). [§9.8][s9-8]'s
`sizehint!` for the expected duration is reconciled: now capped by `log_max`,
which is also what defines the hint when `t_end = Inf`. No new diagnostic kind
— hitting the bound is stated policy, not an event to report.

Annotation (2026-10-13): `log_max` is a keyword of `init!`, `restore!` and
`replay!`, the doors that build a run, not of `Simulation` (D-261). A finite
`log_max` is the log's `sizehint!` (§11.2), not a hint for the expected
duration.

**Rejected.**
- *A rolling window:* optimizes recent-past-at-full-density, which replay
````

### 2.24. B-46 D-176

Old:

````text
**Rationale.** Costs recorded where they are paid: ~2× trace size on the dense
component (two small values per touched face where the tuple held one, the
order unchanged and [D-029][d-029]'s two-orders-below-the-log budget untouched); the
conversion allocates once per drained batch, in-class with [§9.8][s9-8]'s retention
carve-out and smaller than the log's per-boundary snapshot, which the carve-out
already covers. The decision is **reversible as pure implementation**:
conversion is lossless both ways, so verbatim retention could return as a
per-entry storage optimization without touching the record semantics, the
header or replay. Motivation: [D-174][d-174] made "enumerated ⇒ claim-narrow ⇒ dense"
false — a greedy claim is enumerated and as wide as the root contract — so
density could only be re-keyed on the claim source, i.e. on a distinction [D-174][d-174]
exists to erase.

**Rejected.**
- *Keying retention by claim source:* a dichotomy needing re-justification at
````

New:

````text
**Rationale.** Costs recorded where they are paid: ~2× trace size on the dense
component (two small values per touched face where the tuple held one, the
order unchanged and [D-029][d-029]'s two-orders-below-the-log budget untouched); the
conversion allocates once per drained batch, in-class with [§9.8][s9-8]'s retention
carve-out and smaller than the log's per-boundary snapshot, which the carve-out
already covers. The decision is **reversible as pure implementation**:
conversion is lossless both ways, so verbatim retention could return as a
per-entry storage optimization without touching the record semantics, the
header or replay. Motivation: [D-174][d-174] made "enumerated ⇒ claim-narrow ⇒ dense"
false — a greedy claim is enumerated and as wide as the root contract — so
density could only be re-keyed on the claim source, i.e. on a distinction [D-174][d-174]
exists to erase.

Annotation (2026-10-13): the schema list left the header for the trace itself
(D-255), so records convert against the trace's schema list.

**Rejected.**
- *Keying retention by claim source:* a dichotomy needing re-justification at
````

### 2.25. B-46 D-203

Old:

````text
Annotation (2026-10-08): amended by [D-316][d-316]. Stop requests replace the stop
faces. `ModelRequestedStop` carries the requester's path, port and reason,
and the source order reads the requests at each publication where it read
the faces. Two requests at one boundary resolve to the first in roster order.

**Rejected.**
- *Superseded position — presentation-only disposal ([D-201][d-201]):* honest but
````

New:

````text
Annotation (2026-10-08): amended by [D-316][d-316]. Stop requests replace the stop
faces. `ModelRequestedStop` carries the requester's path, port and reason,
and the source order reads the requests at each publication where it read
the faces. Two requests at one boundary resolve to the first in roster order.

Annotation (2026-10-13): the effective policy no longer lives in the run
metadata. The deployment holds no policy, and the termination record carries
the terminating advance's (§11.5, D-255). The `t_end` rejection's ground, one
home for the fact, stands.

**Rejected.**
- *Superseded position — presentation-only disposal ([D-201][d-201]):* honest but
````

### 2.26. B-46 D-103

Old:

````text
**Rationale.** No datum-shape contract exists — the datum travels only between
`loop` and `map_input`, same author; binding is an `attach!` argument, never a
device field (narrowing the binding narrows the claim); `TableBinding` is the
one shipped data-driven type (entries in the type ⇒ per-table specialization),
its generic `map_input` owning [§11.4][s11-4]'s conditioning helper; `map_input` purity
taught: cross-datum state lives in the device struct, arrives inside the datum.

**Rejected.**
- *Abstract binding-type taxonomy:* resurrects the [§11.6][s11-6] kill one level down; a
````

New:

````text
**Rationale.** No datum-shape contract exists — the datum travels only between
`loop` and `map_input`, same author; binding is an `attach!` argument, never a
device field (narrowing the binding narrows the claim); `TableBinding` is the
one shipped data-driven type (entries in the type ⇒ per-table specialization),
its generic `map_input` owning [§11.4][s11-4]'s conditioning helper; `map_input` purity
taught: cross-datum state lives in the device struct, arrives inside the datum.

Annotation (2026-10-13): amended by D-177, which declares a binding's sides by
Bool traits in place of method presence, and by D-146, which renames `faces`
and `selectors` to `claims` and `reads`. The Rationale stands.

**Rejected.**
- *Abstract binding-type taxonomy:* resurrects the [§11.6][s11-6] kill one level down; a
````

### 2.27. B-46 D-107

Old:

````text
**Rationale.** The header carries each writer's face-name → position schema
(positional records are meaningless without it and replay does not reconstruct
claims); replay pays the inverse conversion once, up front, in the [§12.7][s12-7]
validation pass — no name resolved per frame under replay either; conversion
site is the drain, not the staging shim (the drained tuple is the coalesced
truth; a shim-side sparse log would need its own merge).

**Rejected.**
- *Verbatim retention of interactive positional batches:* size tracks surface
````

New:

````text
**Rationale.** The header carries each writer's face-name → position schema
(positional records are meaningless without it and replay does not reconstruct
claims); replay pays the inverse conversion once, up front, in the [§12.7][s12-7]
validation pass — no name resolved per frame under replay either; conversion
site is the drain, not the staging shim (the drained tuple is the coalesced
truth; a shim-side sparse log would need its own merge).

Annotation (2026-10-13): superseded in part by D-176, whose one sparse record
format replaces this entry's density rule: every writer's batch is
sparse-converted at the drain.

**Rejected.**
- *Verbatim retention of interactive positional batches:* size tracks surface
````

### 2.28. B-46 D-127

Old:

````text
**Rationale.** Defined as the artifact "run metadata" already named three times
without a home ([§13.5][s13-5] ×2, [Appendix B][sB]; [D-091][d-091]'s obligation, now discharged).

**Rejected.**
- *Validating the whole block uniformly:* freezes `t_end`/`stop_on`, which
````

New:

````text
**Rationale.** Defined as the artifact "run metadata" already named three times
without a home ([§13.5][s13-5] ×2, [Appendix B][sB]; [D-091][d-091]'s obligation, now discharged).

Annotation (2026-10-13): the trace header holds the `Deployment` and `t₀` and
no policy, so the `t_end`/`stop_on` pair is not recorded (D-255). The
terminating advance's policy is in the termination record.

**Rejected.**
- *Validating the whole block uniformly:* freezes `t_end`/`stop_on`, which
````

### 2.29. B-47 D-252

Old:

````text
**Rationale.** Auto-publishing was a third port class the framework wrote.
It cost more than the line it saved. Stage 1's hand-down had to exclude the
published names ([D-169][d-169]), the classifier probed by name and type and silently
un-published a name held at another type, the executor grew a
`PublishEntry` beside the stage entries, the published set threaded through
every stratum and into `compile`'s key slicing, and a `ConformanceFailure`
arm existed only to refuse a `Float64`-pinned declaration of a walking field
at the `Dual` activation. Each piece was correct and each was there for one
convenience: not writing `output_state(c, (; x)) = (; q = x.q)`. The
2026-09-18 probe over the suite found nine of seventy-eight fixture
components relying on publication, six of them written to test it. The
remaining refusal already exists: `DeclaredNotProduced` names the declared
port, the stage products and the store fields, and its remedy becomes
"return it from `output_state`". With one writer per port the port model is
homogeneous, the `Dataflow` artifact ([D-253][d-253]) classifies by return alone, and
the trace and status surfaces stop distinguishing a framework write from a
stage write.

**Rejected.**
- *Keeping publication as it stood:* the machinery above, for one line per
````

New:

````text
**Rationale.** Auto-publishing was a third port class the framework wrote.
It cost more than the line it saved. Stage 1's hand-down had to exclude the
published names ([D-169][d-169]), the classifier probed by name and type and silently
un-published a name held at another type, the executor grew a
`PublishEntry` beside the stage entries, the published set threaded through
every stratum and into `compile`'s key slicing, and a `ConformanceFailure`
arm existed only to refuse a `Float64`-pinned declaration of a walking field
at the `Dual` activation. Each piece was correct and each was there for one
convenience: not writing `output_state(c, (; x)) = (; q = x.q)`. The
2026-09-18 probe over the suite found nine of seventy-eight fixture
components relying on publication, six of them written to test it. The
remaining refusal already exists: `DeclaredNotProduced` names the declared
port, the stage products and the store fields, and its remedy becomes
"return it from `output_state`". With one writer per port the port model is
homogeneous, the `Dataflow` artifact ([D-253][d-253]) classifies by return alone, and
the trace and status surfaces stop distinguishing a framework write from a
stage write.

Annotation (2026-10-13): the dev-mode note is §11.2's.

**Rejected.**
- *Keeping publication as it stood:* the machinery above, for one line per
````

### 2.30. B-47 D-274

Old:

````text
Annotation (2026-10-09): amended by [D-319][d-319]. The state the first bullet lists
is now a `ModelState`, the clock's `t` and `t₀` among its fields, and the
frame index and the boundary ordinal are the run's counters, which a
`Checkpoint` carries beside it. A `Checkpoint` is nominal by type, so the
refusal by dispatch of a state from another activation sits on the two
`restore!` methods that take a bare state.

**Rejected.**
- *Two header kinds, the pre-sequence resolved condition for an authored
````

New:

````text
Annotation (2026-10-09): amended by [D-319][d-319]. The state the first bullet lists
is now a `ModelState`, the clock's `t` and `t₀` among its fields, and the
frame index and the boundary ordinal are the run's counters, which a
`Checkpoint` carries beside it. A `Checkpoint` is nominal by type, so the
refusal by dispatch of a state from another activation sits on the two
`restore!` methods that take a bare state.

Annotation (2026-10-13): the persistence deferral is `pending.md`'s (Log and
trace persistence) and Appendix B's, not §11.5's.

**Rejected.**
- *Two header kinds, the pre-sequence resolved condition for an authored
````

### 2.31. B-47 D-177

Old:

````text
Annotation (2026-10-02): "[§8.1][s8-1]'s reflection class" in the Rationale reads
"[§8.1][s8-1]'s shadowing check", the `isdefined`/`!==` test [§8.1][s8-1] holds; [§8.1][s8-1] names
no reflection class.

**Rejected.**
- *Presence-only probing, the prior design of record:* silent partial
````

New:

````text
Annotation (2026-10-02): "[§8.1][s8-1]'s reflection class" in the Rationale reads
"[§8.1][s8-1]'s shadowing check", the `isdefined`/`!==` test [§8.1][s8-1] holds; [§8.1][s8-1] names
no reflection class.

Annotation (2026-10-13): §11.6 names the three rejections in one sentence
citing this entry; the answer lives here.

**Rejected.**
- *Presence-only probing, the prior design of record:* silent partial
````

### 2.32. B-47 D-216

Old:

````text
**Rationale.** The payload and policy columns were untested design claims
until a site had to construct each value. Three findings needed the table to
move rather than the code. A check that runs over a list — the stop faces
given, the faces a device claims, the entries of a table — is collecting by
its shape, and making it throw on the first would discard violations the pass
already holds, the cost [§13.1][s13-1] exists to avoid. An id assigned at admission
cannot be in a refusal that keeps the device out. A column narrower than the
sub-kinds it names cannot be the acceptance contract for tests that match on
those sub-kinds' payload. Everything else — the wires on an `AlgebraicCycle`,
the declaration on a `FaceNameCollision`, the shadowing notes, the binding site
of a stop face — is data the design wants and the prototype does not yet
gather; the column keeps naming it and the prototype's absence list carries the
shortfall until a later increment closes it.

**Rejected.**
- *Making the three service checks fail-fast to match the column:* throws
````

New:

````text
**Rationale.** The payload and policy columns were untested design claims
until a site had to construct each value. Three findings needed the table to
move rather than the code. A check that runs over a list — the stop faces
given, the faces a device claims, the entries of a table — is collecting by
its shape, and making it throw on the first would discard violations the pass
already holds, the cost [§13.1][s13-1] exists to avoid. An id assigned at admission
cannot be in a refusal that keeps the device out. A column narrower than the
sub-kinds it names cannot be the acceptance contract for tests that match on
those sub-kinds' payload. Everything else — the wires on an `AlgebraicCycle`,
the declaration on a `FaceNameCollision`, the shadowing notes, the binding site
of a stop face — is data the design wants and the prototype does not yet
gather; the column keeps naming it and the prototype's absence list carries the
shortfall until a later increment closes it.

Annotation (2026-10-13): Appendix C's `DeploymentInvalid` row names deployment
parameters alone; the run-shaping keywords left it. `log`, `log_every` and
`log_max` are keywords of the doors (D-261), `t_end` of `run!` and `replay!`
(D-255), and `join_timeout` stays a `Simulation` keyword (D-261). Appendix C
validates the `Simulation` constructor's keywords under `ArgumentInvalid`,
whose call list also names `init!`, `restore!`, `run!` and `replay!`.

**Rejected.**
- *Making the three service checks fail-fast to match the column:* throws
````

### 2.33. B-50 D-217

Old:

````text
**Rationale.** Positional records are meaningless without a schema, and the
header outlives a run: `attach!` and `detach!` are legal at every stopped
point between `init!` and the next advance ([§12.6][s12-6]), and a roster change
recompiles the harness writer against a new complement, so the same face
moves position. A schema list that only grows keeps every recorded index
valid without rewriting a record. The same positional shape is why an
unresolvable entry has no name to report. A frame ordinal the entry pass does
not check lets a hand-edited record apply at a frame not its own, silently,
and re-record as if it were; [§12.7][s12-7] promises exact ordinal keying, so the check
belongs with the other up-front ones. The two header kinds collect for [D-216][d-216]'s
reason: a check that runs over a list is collecting by its shape. The
termination pair is the one place the sections contradicted each other. [§11.5][s11-5]
captured "the effective pair" at `init!`, while [§13.5][s13-5] binds a `run!` override
for that run only, after `init!` and possibly several times per trace. The
header can only hold what `init!` knows, and the termination record already
names what fired: `EndTimeReached` carries the final `t`, `ModelRequestedStop`
the holding face. Replay neither compares nor applies the pair, so nothing
rides on it.

**Rejected.**
- *A mutable termination slot in the header, rewritten at every advance:* one
````

New:

````text
**Rationale.** Positional records are meaningless without a schema, and the
header outlives a run: `attach!` and `detach!` are legal at every stopped
point between `init!` and the next advance ([§12.6][s12-6]), and a roster change
recompiles the harness writer against a new complement, so the same face
moves position. A schema list that only grows keeps every recorded index
valid without rewriting a record. The same positional shape is why an
unresolvable entry has no name to report. A frame ordinal the entry pass does
not check lets a hand-edited record apply at a frame not its own, silently,
and re-record as if it were; [§12.7][s12-7] promises exact ordinal keying, so the check
belongs with the other up-front ones. The two header kinds collect for [D-216][d-216]'s
reason: a check that runs over a list is collecting by its shape. The
termination pair is the one place the sections contradicted each other. [§11.5][s11-5]
captured "the effective pair" at `init!`, while [§13.5][s13-5] binds a `run!` override
for that run only, after `init!` and possibly several times per trace. The
header can only hold what `init!` knows, and the termination record already
names what fired: `EndTimeReached` carries the final `t`, `ModelRequestedStop`
the holding face. Replay neither compares nor applies the pair, so nothing
rides on it.

Annotation (2026-10-13): the length is the frame ordinal of the last drain
(D-260), which under `init!` equals the number of drains since the header; a
trace that `restore!` opens starts at the checkpoint's frame (D-274).

**Rejected.**
- *A mutable termination slot in the header, rewritten at every advance:* one
````

### 2.34. B-50 D-255

Old:

````text
Annotation (2026-10-08): amended by [D-316][d-316]. `stop_on` is
`ignore_stop_requests`, with `()` as its default, and `StopPolicy` is
`t_end` plus the ignored requester paths. `UnboundedRun` fires when no
requester is honoured.


### D-256 — Regroup the `Simulation`'s fields by owner
````

New:

````text
Annotation (2026-10-08): amended by [D-316][d-316]. `stop_on` is
`ignore_stop_requests`, with `()` as its default, and `StopPolicy` is
`t_end` plus the ignored requester paths. `UnboundedRun` fires when no
requester is honoured.

Annotation (2026-10-13): the length is the frame ordinal of the last drain
(D-260), which under `init!` equals the number of drains since the header; a
trace that `restore!` opens starts at the checkpoint's frame (D-274).


### D-256 — Regroup the `Simulation`'s fields by owner
````

## Notes

- B-34: applied only the four marked proposals. B-41: annotation only,
  D-134's status unchanged. B-50: annotations only; agent 2 adds the D-260
  citation.
- B-47, D-216: Appendix C's `DeploymentInvalid` row (spec.md, "The
  deployment parameter, the value in hand…") lists `h`, `N_base`,
  `Δt_base`, algorithm, `localization_tol`, `localization_budget`,
  `firing_budget`, the harmonic-grid relation and anchor periods or offsets.
  None of `join_timeout`, `log`, `log_every`, `log_max`, `t_end` is there, and
  the row says the `Model` and `Simulation` constructors' keywords validate
  under `ArgumentInvalid`. So the appendix had already moved and D-216's
  bullet was stale; the annotation went in. Chapter 13 needed no edit.
- B-46: the item gave the annotations "in brief"; their texts are agent 1's,
  each held to the item's evidence (D-104, D-200, D-165, D-194, D-274, D-252,
  D-136, D-261, §11.2's "A finite `log_max` is the log's `sizehint!`",
  D-255, D-177, D-146, D-176).
- Edit 2.18 (D-024) was reworded once after the script ran, before linkify:
  "The harness writer's cell takes several staging tasks at once" became
  "Several tasks may stage into the harness writer's cell at once" (D-200's
  own words). The New text above is the final one.
- Battery before each commit: `check_refs.jl` OK, `check_rows.jl` OK (no
  coverage drop, no rebaseline), `check_glossary.jl --strict` OK (three
  standing advisories), `check_bold.jl` OK, `linkify.jl` re-run a no-op.

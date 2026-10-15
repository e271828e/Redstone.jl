### P1-25, unit A, `units/A/new.md`

Old:

````markdown
This chapter specifies the machinery that drives the loop itself, taking the
loop of [§10][s10] and the data plane of [§11][s11] as given. [§12.1][s12-1] covers the control
plane; [§12.2][s12-2] loop scheduling, in turn its wait primitive, its yields and the
thread budget; [§12.3][s12-3] the next-snapshot wait; [§12.4][s12-4] the shutdown protocol;
[§12.5][s12-5] scripts and the mid-run mutation doctrine; [§12.6][s12-6] the run lifecycle
from `init!`, and partial advance; and [§12.7][s12-7] replay, where the trace re-drives
the ordinary loop.
````

New:

````markdown
This chapter specifies the machinery that drives the loop itself, taking the
loop of [§10][s10] and the data plane of [§11][s11] as given. [§12.1][s12-1] covers the control plane;
[§12.2][s12-2] loop scheduling, in turn its wait primitive, its yields, the thread budget
and the liveness heartbeat; [§12.3][s12-3] the next-snapshot wait; [§12.4][s12-4] the shutdown
protocol; [§12.5][s12-5] scripts and the mid-run mutation doctrine; [§12.6][s12-6] the run
lifecycle from `init!`, and partial advance; and [§12.7][s12-7] replay, where the trace
re-drives the ordinary loop.
````

### P1-15, unit A, `units/A/new.md`

Old:

````markdown
The [control plane](#g-control-plane) (the separate few-word atomic surface
carrying pause, pace and stop) is not staging, structurally ([D-022][d-022]).
Staged writes apply at [drains](#g-drain) (the points where the loop applies
staged device writes), and a paused loop drains nothing, so un-pause via
staging would deadlock by construction. Riding outside the drain/[trace](#g-trace)
path is safe for determinism precisely because [§10.7][s10-7] put
[pacing](#g-pacing) (the pacer's wall-clock waits) outside the semantics
([D-021][d-021]). Control changes *when* [frames](#g-frame) (iterations of the
loop) execute, never what they compute, and stop merely truncates the
trajectory. This section covers, in order, when the loop reads the plane, the
stop and its issuer, the pause, pace and `margin`, and the fields of
`Control`, one of the periphery's own types ([D-256][d-256]), the one that
holds the control plane.
````

New:

````markdown
Pause, un-pause, pace changes, `margin` changes and stop are a few scalar fields
on a separate atomic surface, the [control plane](#g-control-plane). It is not staging, structurally
([D-022][d-022]). Staged writes apply at [drains](#g-drain) (the points where the loop applies staged
device writes), and a paused loop drains nothing, so un-pause via staging would
deadlock by construction. Riding outside the drain/[trace](#g-trace) path is safe for
determinism precisely because [§10.7][s10-7] put [pacing](#g-pacing) (the pacer's wall-clock waits)
outside the semantics ([D-021][d-021]). Control changes *when* [frames](#g-frame) (iterations of the
loop) execute, never what they compute, and stop merely truncates the
trajectory. This section covers, in order, when the loop reads the plane, the
stop and its issuer, the pause, pace and `margin`, and the fields of `Control`,
one of the periphery's own types ([D-256][d-256]), the one that holds the control plane.
````

### P1-15, unit A, `units/A/new.md`

Old:

````markdown
Pause, un-pause, pace changes, `margin` changes and stop are a few scalar
fields on that separate atomic surface. The loop consults them at frame top,
the start of each frame. A change issued while a frame runs or waits is
observed at the next frame top, at most one frame budget `h/p` later
([D-269][d-269]). The pause block, described with the pause verbs below, is
the one wait that wakes at once.
````

New:

````markdown
The loop consults the control plane at frame top, the start of each frame. A
change issued while a frame runs or waits is observed at the next frame top, at
most one frame budget `h/p` later ([D-269][d-269]). The pause block, described with the
pause verbs below, is the one wait that wakes at once.
````

### P1-16, unit A, `units/A/new.md`

Old:

````markdown
Pause, un-pause, pace changes, `margin` changes and stop are a few scalar fields
on a separate atomic surface, the [control plane](#g-control-plane). It is not staging, structurally
([D-022][d-022]). Staged writes apply at [drains](#g-drain) (the points where the loop applies staged
device writes), and a paused loop drains nothing, so un-pause via staging would
deadlock by construction. Riding outside the drain/[trace](#g-trace) path is safe for
determinism precisely because [§10.7][s10-7] put [pacing](#g-pacing) (the pacer's wall-clock waits)
outside the semantics ([D-021][d-021]). Control changes *when* [frames](#g-frame) (iterations of the
loop) execute, never what they compute, and stop merely truncates the
trajectory. This section covers, in order, when the loop reads the plane, the
stop and its issuer, the pause, pace and `margin`, and the fields of `Control`,
one of the periphery's own types ([D-256][d-256]), the one that holds the control plane.
````

New:

````markdown
Pause, un-pause, pace changes, `margin` changes and stop are a few scalar fields
on a separate atomic surface, the [control plane](#g-control-plane). It is not staging, structurally
([D-022][d-022]). Staged writes apply at [drains](#g-drain) (the points where the loop applies staged
device writes), and a paused loop drains nothing, so un-pause via staging would
deadlock by construction. Riding outside the drain/[trace](#g-trace) path is safe for
determinism precisely because [§10.7][s10-7] put [pacing](#g-pacing) (the pacer's wall-clock waits)
outside the semantics ([D-021][d-021]). Control changes *when* [frames](#g-frame) (iterations of the
loop) execute, never what they compute, and stop merely truncates the
trajectory. This section covers, in order, when the loop reads the plane, the
stop and its issuer, the pause, pace and `margin`, and the fields of `Control`,
the periphery's own type that holds the control plane ([D-256][d-256]).
````

### P1-18, unit A, `units/A/new.md`

Old:

````markdown
Pause, un-pause, pace changes, `margin` changes and stop are a few scalar fields
on a separate atomic surface, the [control plane](#g-control-plane). It is not staging, structurally
([D-022][d-022]). Staged writes apply at [drains](#g-drain) (the points where the loop applies staged
device writes), and a paused loop drains nothing, so un-pause via staging would
deadlock by construction. Riding outside the drain/[trace](#g-trace) path is safe for
determinism precisely because [§10.7][s10-7] put [pacing](#g-pacing) (the pacer's wall-clock waits)
outside the semantics ([D-021][d-021]). Control changes *when* [frames](#g-frame) (iterations of the
loop) execute, never what they compute, and stop merely truncates the
trajectory. This section covers, in order, when the loop reads the plane, the
stop and its issuer, the pause, pace and `margin`, and the fields of `Control`,
the periphery's own type that holds the control plane ([D-256][d-256]).
````

New:

````markdown
Pause, un-pause, pace changes, `margin` changes and stop are a few scalar fields
on a separate atomic surface, the [control plane](#g-control-plane). It is not staging, structurally
([D-022][d-022]). Staged writes apply at [drains](#g-drain) (the points where the loop applies staged
device writes), and a paused loop drains nothing, so un-pause via staging would
deadlock by construction. Riding outside the path through the drain and the
[trace](#g-trace), the primary record of a session, is safe for determinism precisely
because [§10.7][s10-7] put [pacing](#g-pacing) (the pacer's wall-clock waits) outside the semantics
([D-021][d-021]). Control changes *when* [frames](#g-frame) (iterations of the loop) execute, never
what they compute, and stop merely truncates the trajectory. This section
covers, in order, when the loop reads the plane, the stop and its issuer, the
pause, pace and `margin`, and the fields of `Control`, the periphery's own type
that holds the control plane ([D-256][d-256]).
````

### P1-14, unit A, `units/A/new.md`

Old:

````markdown
Pause, un-pause, pace changes, `margin` changes and stop are a few scalar fields
on a separate atomic surface, the [control plane](#g-control-plane). It is not staging, structurally
([D-022][d-022]). Staged writes apply at [drains](#g-drain) (the points where the loop applies staged
device writes), and a paused loop drains nothing, so un-pause via staging would
deadlock by construction. Riding outside the path through the drain and the
[trace](#g-trace), the primary record of a session, is safe for determinism precisely
because [§10.7][s10-7] put [pacing](#g-pacing) (the pacer's wall-clock waits) outside the semantics
([D-021][d-021]). Control changes *when* [frames](#g-frame) (iterations of the loop) execute, never
what they compute, and stop merely truncates the trajectory. This section
covers, in order, when the loop reads the plane, the stop and its issuer, the
pause, pace and `margin`, and the fields of `Control`, the periphery's own type
that holds the control plane ([D-256][d-256]).
````

New:

````markdown
Pause, un-pause, pace changes, `margin` changes and stop are a few scalar fields
on a separate atomic surface, the [control plane](#g-control-plane). It is not staging, structurally
([D-022][d-022]). Staged writes apply at [drains](#g-drain) (the frame-top swaps that apply staged
device writes), and a paused loop drains nothing, so un-pause via staging would
deadlock by construction. Riding outside the path through the drain and the
[trace](#g-trace), the primary record of a session, is safe for determinism precisely
because [§10.7][s10-7] put [pacing](#g-pacing) (the pacer's wall-clock waits) outside the semantics
([D-021][d-021]). Control changes *when* [frames](#g-frame) (iterations of the loop) execute, never
what they compute, and stop merely truncates the trajectory. This section
covers, in order, when the loop reads the plane, the stop and its issuer, the
pause, pace and `margin`, and the fields of `Control`, the periphery's own type
that holds the control plane ([D-256][d-256]).
````

### P1-27, unit A, `units/A/new.md`

Old:

````markdown
The loop consults the control plane at frame top, the start of each frame. A
change issued while a frame runs or waits is observed at the next frame top, at
most one frame budget `h/p` later ([D-269][d-269]). The pause block, described with the
pause verbs below, is the one wait that wakes at once.
````

New:

````markdown
The loop consults the control plane at frame top, the start of each frame. A
change issued while a frame runs or waits is observed at the next frame top, at
most one frame budget (`h/p`, the step over the pace) later ([D-269][d-269]). The pause
block, described with the pause verbs below, is the one wait that wakes at once.
````

### P1-17, unit A, `units/A/new.md`

Old:

````markdown
**The stop word carries its issuer** ([D-203][d-203]). The stop word is the
control plane's stop command, one atomic word holding its issuer. Each
issuing site writes its identity (the device's name, `:code`, or `:interrupt`)
by compare-and-swap from empty, and the first writer wins. The loop's
frame-top read consults the word for non-empty, so the recorded issuer is the
request that actually initiated the tail, the ordered shutdown sequence of
[§12.4][s12-4]. The issuer lands in the
[termination record](#g-termination-record) (the stopped-sim value naming how
the run ended) as its `ControlRequestedStop`'s payload ([§13.5][s13-5],
[D-203][d-203]).
````

New:

````markdown
**The stop word carries its issuer** ([D-203][d-203]). The stop word is the control
plane's stop command, held in one atomic word. Each issuing site writes its
identity (the device's name, `:code`, or `:interrupt`) by compare-and-swap from
empty, and the first writer wins. The loop's frame-top read consults the word
for non-empty, so the recorded issuer is the request that actually initiated the
tail, the ordered shutdown sequence of [§12.4][s12-4]. The issuer lands in the
[termination record](#g-termination-record) (the stopped-sim value naming how the run ended) as its
`ControlRequestedStop`'s payload ([§13.5][s13-5], [D-203][d-203]).
````

### P1-26, unit A, `units/A/new.md`

Old:

````markdown
**Pace and `margin` are two more verbs and two readers** ([D-269][d-269]).
`pace!(sim, p)` and `margin!(sim, m)` set them from any task in any lifecycle
state, and `pace(sim)` and `margin(sim)` read them. `margin`
([§10.7][s10-7]) rides on the control plane for the same reason `pace` does.
It tunes the wait, never the arithmetic, so retuning the coarse/spin split
mid-run is safe by construction. `run!` and `replay!` take both as keywords
and write them at entry. Both are declared by the advance, as `t_end` is.
`pace` defaults to `Inf` and `margin` to 2 ms ([Appendix B][sB],
[D-133][d-133]). `step!` takes neither and never waits. A stepping session is
the harness mode ([§12.6][s12-6]), and its frames are bit-identical to `run!`'s
by [§10.7][s10-7]'s invariant. `pace` is a positive real, `Inf` admitted, and
`margin` a non-negative real, `Inf` admitted. The two setters and the two
keywords refuse anything else under `ArgumentInvalid` ([Appendix C][sC]).
````

New:

````markdown
**Pace and `margin` are two more verbs and two readers** ([D-269][d-269]).
`pace!(sim, p)` and `margin!(sim, m)` set them from any task in any lifecycle
state, and `pace(sim)` and `margin(sim)` read them. `margin` ([§10.7][s10-7]) rides on
the control plane for the same reason `pace` does. It tunes the wait, never the
arithmetic, so retuning the coarse/spin split mid-run is safe by construction.
`run!` and `replay!` take both as keywords and write them when called. Both are
declared by the advance, as `t_end` is. `pace` defaults to `Inf` and `margin` to
2 ms ([Appendix B][sB], [D-133][d-133]). `step!` takes neither and never waits. A stepping
session is the harness mode ([§12.6][s12-6]), and its frames are bit-identical to
`run!`'s by [§10.7][s10-7]'s invariant. `pace` is a positive real, `Inf` admitted, and
`margin` a non-negative real, `Inf` admitted. The two setters and the two
keywords refuse anything else under `ArgumentInvalid` ([Appendix C][sC]).
````

### P1-30, unit A, `units/A/new.md`

Old:

````markdown
The consequence is a bound on thread occupancy. The loop holds a thread for
at most one frame before the scheduler can run anyone else. Julia's scheduler
is cooperative, and the scheduler stall requires a thread monopolist, a
never-yielding task that holds its thread forever. That precondition is
structurally absent from framework tasks.
````

New:

````markdown
The consequence is a bound on thread occupancy. The loop holds a thread for at
most one frame before the scheduler can run anyone else. Julia's scheduler is
cooperative, and a stall of that scheduler requires a thread monopolist, a
never-yielding task that holds its thread forever. That precondition is
structurally absent from framework tasks.
````

### P1-20, unit A, `units/A/new.md`

Old:

````markdown
At `run!` or `replay!`, a run warns under `ThreadBudget` ([Appendix C][sC])
when `Threads.nthreads()` is tight for the attached population, naming the
`julia -t` remedy. That is one check per run, against the frozen
[roster](#g-roster) (the list of attached device entries) ([§11.3][s11-3]).
Tight means fewer threads than the roster plus one. Every rostered device is a
task, and the [calling task](#g-calling-task) (the task that invoked `run!`)
hosts the loop, so a run occupies one task more than its roster
([D-310][d-310]). The sizing guidance behind the remedy is one thread for the
loop and headroom for compute-heavy or blocking-ccall devices. I/O backed by
libuv (the I/O library under Julia's tasks) yields. Raw blocking ccalls pin
their thread for the duration. There is no pinning and there are no sticky
tasks.
````

New:

````markdown
At `run!` or `replay!`, a run warns under `ThreadBudget` ([Appendix C][sC]) when
`Threads.nthreads()` is tight for the attached population, naming the `julia -t`
remedy. That is one check per run, against the frozen [roster](#g-roster), the list of
attached device entries ([§11.3][s11-3]). Tight means fewer threads than the roster plus
one. Every rostered device is a task, and the [calling task](#g-calling-task) (the task that
invoked `run!`) hosts the loop, so a run occupies one task more than its roster
([D-310][d-310]). The sizing guidance behind the remedy is one thread for the loop and
headroom for compute-heavy or blocking-ccall devices. I/O backed by libuv (the
I/O library under Julia's tasks) yields. Raw blocking ccalls pin their thread
for the duration. There is no pinning and there are no sticky tasks.
````

### P1-20, unit A, `units/A/new.md`

Old:

````markdown
Since starvation is survivable, it must be diagnosable ([D-027][d-027]). The
record is the published [framework status](#g-framework-status), the frozen
diagnostics value each snapshot carries beside the table. It includes
per-device liveness (the liveness timestamp and the device's `task_state`)
next to the pacer diagnostics. The mechanism is the per-writer
[diagnostic cell](#g-diagnostic-cell) (a writer's own holding place for
runtime diagnostics and liveness) ([D-136][d-136]), specified in full by [§11.8][s11-8],
plus the device `Task` handles the loop already owns, and nothing besides.
The diagnostic cell carries the single liveness timestamp.
The loop reads `task_state` off those handles where it publishes
([D-193][d-193]). A starved, blocked or crashed device task shows in a front
end as a stale heartbeat with a name on it, not as mysteriously frozen physics
([D-310][d-310]).
````

New:

````markdown
Since starvation is survivable, it must be diagnosable ([D-027][d-027]). The record is
the published [framework status](#g-framework-status), the frozen diagnostics value each snapshot
carries beside the table. It includes per-device liveness (the liveness
timestamp and the device's `task_state`) next to the pacer diagnostics. The
mechanism is the per-writer [diagnostic cell](#g-diagnostic-cell) ([D-136][d-136]), specified in full by [§11.8][s11-8],
plus the device `Task` handles the loop already owns, and nothing besides. A
diagnostic cell is a writer's own holding place for runtime diagnostics and
liveness. It carries the single liveness timestamp. The loop reads `task_state`
off those handles where it publishes ([D-193][d-193]). A starved, blocked or crashed
device task shows in a front end as a stale heartbeat with a name on it, not as
mysteriously frozen physics ([D-310][d-310]).
````

### P1-20, unit A, `units/A/new.md`

Old:

````markdown
**Two artifacts provide the wait, a monotonic
[boundary counter](#g-boundary-counter) plus one `Threads.Condition`**
([D-028][d-028]). The boundary counter is the loop's own. It counts *published
boundaries*, that is grid, `t*` and [boundary zero](#g-boundary-zero) (the
initialization boundary at `t₀`) ([§10.1][s10-1], [§10.4][s10-4]), not
frames. Consecutive wakes are therefore not necessarily `h` apart.
````

New:

````markdown
**Two artifacts provide the wait, a monotonic [boundary counter](#g-boundary-counter) plus one
`Threads.Condition`** ([D-028][d-028]). The boundary counter is the loop's own. It counts
*published boundaries*, that is grid, `t*` and [boundary zero](#g-boundary-zero) (the initialization
boundary at `t₀`), not frames ([§10.1][s10-1], [§10.4][s10-4]). Consecutive wakes are therefore
not necessarily `h` apart.
````

### P1-20, unit A, `units/A/new.md`

Old:

````markdown
**The order of the two publications is normative** ([D-114][d-114]). The
release-store of [`latest`](#g-latest) (the atomic reference readers
acquire-load) ([§11.2][s11-2]) happens before the counter increment under the
lock.
````

New:

````markdown
**The order of the two publications is normative** ([D-114][d-114]). The release-store of
[`latest`](#g-latest), the atomic reference readers acquire-load ([§11.2][s11-2]), happens before the
counter increment under the lock.
````

### P1-28, unit A, `units/A/new.md`

Old:

````markdown
The device side's predicate, `counter > last_seen` (below), therefore implies
that `latest` holds at least that boundary, and a waiter can never wake onto
a [snapshot](#g-snapshot) (the immutable per-boundary publication) that is
stale. The
converse is expected and correct. A waiter may observe a *newer* snapshot than
the increment that woke it. Newest wins.
````

New:

````markdown
The device side's test `counter > last_seen` (below) therefore implies that
`latest` holds at least that boundary, and a waiter can never wake onto a
[snapshot](#g-snapshot) (the immutable per-boundary publication) that is stale. The converse is
expected and correct. A waiter may observe a *newer* snapshot than the increment
that woke it. Newest wins.
````

### P1-29, unit A, `units/A/new.md`

Old:

````markdown
**The wait's semantics are newest-wins, no queues** ([D-028][d-028]). A slow
consumer skips boundaries and always receives the current world. This mirrors
the inbound side. Inbound [coalescing](#g-coalescing) (the CAS merge that
leaves one pending batch per device) keeps the newest level per face, and the wait
delivers the newest snapshot, the same zero-order hold (ZOH) decision. No
backpressure exists in either direction, and the loop never waits on anyone.
Per-consumer every-boundary queues are rejected ([D-028][d-028]).
````

New:

````markdown
**The wait's semantics are newest-wins, no queues** ([D-028][d-028]). A slow consumer
skips boundaries and always receives the current world. This mirrors the inbound
side. Inbound [coalescing](#g-coalescing) (the compare-and-swap merge that leaves one pending
batch per device) keeps the newest level per face, and the wait delivers the
newest snapshot, the same zero-order hold (ZOH) decision. No backpressure exists
in either direction, and the loop never waits on anyone. Per-consumer
every-boundary queues are rejected ([D-028][d-028]).
````

### P1-19, unit A, `units/A/new.md`

Old:

````markdown
Two indices number the publications, and each lives in its own place. The
snapshot carries the trajectory's *published-boundary ordinal* with `t`.
Boundary zero is 0, and every publication after it, grid or `t*`, counts one.
Any holder of a snapshot therefore indexes it without consulting the loop,
whether the log or a post-run inspector. A new trajectory restarts the ordinal
at zero, with everything else `init!` resets. The boundary counter is a
different number. It is the loop's monotone count of every publication it has
ever made, never reset across trajectories, and its absolute value is nowhere
normative. It exists for the wait predicate alone, and it is never reset
because a waiter's `last_seen` must never run ahead of it ([D-230][d-230]). An
error's pointer for [replay](#g-replay) (the ordinary loop re-driven from the
trace) is a third index, the frame-entry boundary index of [§13.4][s13-4], a
frame count that names no `t*` boundary ([D-128][d-128]).
````

New:

````markdown
Two indices number the publications, and each lives in its own place. The
snapshot carries the trajectory's *published-boundary ordinal* with `t`.
Boundary zero is 0, and every publication after it, grid or `t*`, counts one.
Any holder of a snapshot therefore indexes it without consulting the loop,
whether the [log](#g-log) (the retained sequence of published snapshots) or a post-run
inspector. A new trajectory restarts the ordinal at zero, with everything else
`init!` resets. The boundary counter is a different number. It is the loop's
monotone count of every publication it has ever made, never reset across
trajectories, and its absolute value is nowhere normative. It exists for the
wait predicate alone, and it is never reset because a waiter's `last_seen` must
never run ahead of it ([D-230][d-230]). An error's pointer for [replay](#g-replay) (the ordinary loop
re-driven from the trace) is a third index, the frame-entry boundary index of
[§13.4][s13-4], a frame count that names no `t*` boundary ([D-128][d-128]).
````

### P1-11, unit B, `units/B/new.md`

Old:

````markdown
1. Initiation. Three events start a shutdown. Either `t_end` is reached, or a
   stop is issued on the [control plane](#g-control-plane) (the separate
   atomic surface carrying pause, pace and stop), or a [stop
   request](#g-stop-request) the advance honours reads `STOP_REQUESTED` in the
   just-published [snapshot](#g-snapshot) ([D-316][d-316]). A stop request is
   an output port of the framework enum `StopFlag`, and a snapshot is the
   immutable per-boundary publication. The control-plane stop's issuers are a
   front end ([D-310][d-310]), a device handle, code, or an operator interrupt
   (Ctrl-C, treated below). The third event is model-detected termination
   ([§13.5][s13-5]). The loop never stops mid-boundary. It always completes
   the boundary sequence in progress, which a stop at [`t*`](#g-t) (the
   localized event time) places inside a frame. A [frame](#g-frame) is one
   iteration of the loop. The loop then publishes the final snapshot. Only
   then does it set the sticky stopped status.
````

New:

````markdown
1. Initiation. Three events start a shutdown. Either `t_end` is reached, or a
   stop is issued on the [control plane](#g-control-plane) (the separate atomic surface carrying
   pause, pace and stop), or a [stop request](#g-stop-request) the advance honours reads
   `STOP_REQUESTED` in the just-published [snapshot](#g-snapshot) ([D-316][d-316]). A stop request is an
   output port of the framework enum `StopFlag`, and a snapshot is the immutable
   per-boundary publication. The control-plane stop's issuers are a front end
   ([D-310][d-310]), a device handle, code, or an operator interrupt (Ctrl-C, treated
   below). The third event is model-detected termination ([§13.5][s13-5]). The loop never
   stops mid-boundary. It always completes the boundary sequence in progress,
   which a stop at [`t*`](#g-t) (the localized event time) places inside a [frame](#g-frame), one
   iteration of the loop. The loop then publishes the final snapshot. Only then
   does it set the sticky stopped status.
````

### P1-14, P1-20, unit B, `units/B/new.md`

Old:

````markdown
5. Join under the `join_timeout` cap. The cap lives on `Control`, the tail's
   own owner ([§12.1][s12-1], [D-256][d-256]). It is a keyword of the
   `Simulation` constructor, a positive real in seconds of wall clock,
   defaulting to 5 ([Appendix B][sB]). The constructor refuses any other value
   as `ArgumentInvalid`. A device task exceeding the cap is reported *by name*
   in a `DeviceJoinTimeout` diagnostic ([Appendix C][sC]). It is then
   abandoned rather than left to hang `run!`. **The diagnostic is written to
   the loop's own [diagnostic cell](#g-diagnostic-cell)** (each writer's
   bounded ring of diagnostics and its heartbeat) ([D-203][d-203]). The
   run's-end sweep collects the diagnostic into the [termination
   record](#g-termination-record) (the stopped-sim value naming how the run
   ended). The logging backend presents the diagnostic, with the terminal
   snapshot preceding the join ([D-201][d-201], [D-203][d-203]).
````

New:

````markdown
5. Join under the `join_timeout` cap. The cap lives on `Control`, the tail's own
   owner ([§12.1][s12-1], [D-256][d-256]). It is a keyword of the `Simulation` constructor, a
   positive real in seconds of wall clock, defaulting to 5 ([Appendix B][sB]). The
   constructor refuses any other value as `ArgumentInvalid`. A device task
   exceeding the cap is reported *by name* in a `DeviceJoinTimeout` diagnostic
   ([Appendix C][sC]). It is then abandoned rather than left to hang `run!`. **The
   diagnostic is written to the loop's own [diagnostic cell](#g-diagnostic-cell)**, a writer's own
   holding place for runtime diagnostics and liveness ([D-203][d-203]). The run's-end
   sweep collects the diagnostic into the [termination record](#g-termination-record) (the stopped-sim
   value naming how the run ended). The logging backend presents the diagnostic,
   with the terminal snapshot preceding the join ([D-201][d-201], [D-203][d-203]).
````

### P1-13, unit B, `units/B/new.md`

Old:

````markdown
5. Join under the `join_timeout` cap. The cap lives on `Control`, the tail's own
   owner ([§12.1][s12-1], [D-256][d-256]). It is a keyword of the `Simulation` constructor, a
   positive real in seconds of wall clock, defaulting to 5 ([Appendix B][sB]). The
   constructor refuses any other value as `ArgumentInvalid`. A device task
   exceeding the cap is reported *by name* in a `DeviceJoinTimeout` diagnostic
   ([Appendix C][sC]). It is then abandoned rather than left to hang `run!`. **The
   diagnostic is written to the loop's own [diagnostic cell](#g-diagnostic-cell)**, a writer's own
   holding place for runtime diagnostics and liveness ([D-203][d-203]). The run's-end
   sweep collects the diagnostic into the [termination record](#g-termination-record) (the stopped-sim
   value naming how the run ended). The logging backend presents the diagnostic,
   with the terminal snapshot preceding the join ([D-201][d-201], [D-203][d-203]).
````

New:

````markdown
5. Join under the `join_timeout` cap. The cap lives on `Control`, the tail's own
   owner ([§12.1][s12-1], [D-256][d-256]). It is a keyword of the `Simulation` constructor, a
   positive real in seconds of wall clock, defaulting to 5 ([Appendix B][sB]). The
   constructor refuses any other value as `ArgumentInvalid`. A device task
   exceeding the cap is reported *by name* in a `DeviceJoinTimeout` diagnostic
   ([Appendix C][sC]). It is then abandoned rather than left to hang `run!`. **The
   diagnostic is written to the loop's own [diagnostic cell](#g-diagnostic-cell)**, a writer's own
   holding place for runtime diagnostics and liveness ([D-203][d-203]). The run's-end
   sweep, the loop's last pass over every diagnostic cell, collects the
   diagnostic into the [termination record](#g-termination-record) (the stopped-sim value naming how the
   run ended). The logging backend presents the diagnostic, with the terminal
   snapshot preceding the join ([D-201][d-201], [D-203][d-203]).
````

### P1-19, unit B, `units/B/new.md`

Old:

````markdown
6. Device-initiated paths. A device exits voluntarily when its loop body
   returns, at a window ✕ or a peer EOT. No `should_close` hook exists
   ([§11.6][s11-6]). With `should_abort` set, the wrapper's exit path also
   requests a sim stop. Otherwise the sim continues with the device's *task*
   absent. Its [staging cell](#g-staging-cell) (where the device's pending
   write batch waits between drains) stops filling, and the loop is
   structurally indifferent. Its [roster](#g-roster) entry and its
   [claims](#g-claim) persist to run end, because [§11.3][s11-3] freezes the
   roster for the run and death is not detach. The roster is the list of
   attached device entries, and a claim is the set of faces a device may
   write. The orphaned [root inputs](#g-root-input) (the root component's own
   input faces) hold their last-drained values, visibly ([§11.7][s11-7]). A
   crashing device task is caught by the framework wrapper and follows the
   same path, logged with the device's name (`DeviceCrash`, [Appendix C][sC]).
````

New:

````markdown
6. Device-initiated paths. A device exits voluntarily when its loop body
   returns, at a window ✕ or a peer EOT. No `should_close` hook exists ([§11.6][s11-6]).
   With [`should_abort`](#g-should_abort) (the per-attachment failure policy, an `attach!` keyword)
   set, the wrapper's exit path also requests a sim stop. Otherwise the sim
   continues with the device's *task* absent. Its [staging cell](#g-staging-cell) (where the
   device's pending write batch waits between drains) stops filling, and the
   loop is structurally indifferent. Its [roster](#g-roster) entry and its [claims](#g-claim) persist to
   run end, because [§11.3][s11-3] freezes the roster for the run and death is not
   detach. The roster is the list of attached device entries, and a claim is the
   set of faces a device may write. The orphaned [root inputs](#g-root-input) (the root
   component's own input faces) hold their last-drained values, visibly ([§11.7][s11-7]).
   A crashing device task is caught by the framework wrapper and follows the
   same path, logged with the device's name (`DeviceCrash`, [Appendix C][sC]).
````

### P1-24, unit B, `units/B/new.md`

Old:

````markdown
`t_end` lands on the grid. **The run ends at the first grid boundary whose
time reaches or exceeds `t_end`** ([D-133][d-133]). The run takes whole frames
only, never a shortened final step, which grid integrity forbids
([§10.4][s10-4]). Each grid time is indexed, `tₖ = t₀ + k·h`, and never
accumulated ([§10.4][s10-4]). The final boundary may therefore overshoot
`t_end` by up to `h`. The termination record carries the actual final `t`
([§13.5][s13-5]). This is the `t_plus` spelling ([§12.6][s12-6]) applied to
the run's own clock. The run takes whole frames until the boundary time first
covers the duration.
````

New:

````markdown
`t_end` lands on the grid. **The run ends at the first grid boundary whose time
reaches or exceeds `t_end`** ([D-133][d-133]). The run takes whole frames only, never a
shortened final step, which grid integrity forbids ([§10.4][s10-4]). Each grid time is
indexed, `tₖ = t₀ + k·h`, and never accumulated ([§10.4][s10-4]). The final boundary may
therefore overshoot `t_end` by up to `h`. The termination record carries the
actual final `t` ([§13.5][s13-5]). This is the `t_plus` spelling ([§12.6][s12-6]) applied to the
run's own clock.
````

### P1-21, unit B, `units/B/new.md`

Old:

````markdown
The default of five seconds is generous for front-end window teardown and
socket closes. It is short enough that an abandoned join reads as a
diagnosed timeout rather than a hang.
````

New:

````markdown
The `join_timeout` default of five seconds is generous for front-end window
teardown and socket closes. It is short enough that an abandoned join reads as a
diagnosed timeout rather than a hang.
````

### P1-23, unit B, `units/B/new.md`

Old:

````markdown
**The cap is a per-simulation setting, not an implementation constant**
([D-198][d-198]). That is the disposition [§10.4][s10-4] gives its own two
constants, extended here to an operational one ([D-198][d-198]). Deployment
contexts legitimately differ in patience. An unattended sweep wants to fail
fast, a test battery exercising the abandonment path faster still, while a
device with slow teardown may warrant more. The cap is not
trajectory-determining, because the trajectory has ended at the final
snapshot before any join begins. So [replay](#g-replay) (the ordinary loop
with the drain reading recorded batches) neither records nor compares the cap
([§11.5][s11-5], [§12.7][s12-7]), just as for `log_max` ([§11.2][s11-2]). The
cap therefore lives on `Control`, not on the `Deployment` ([D-256][d-256]).
````

New:

````markdown
**The cap is a per-simulation setting, not an implementation constant** ([D-198][d-198]).
That is the disposition [§10.4][s10-4] gives its own two constants, extended here to an
operational one. Deployment contexts legitimately differ in patience. An
unattended sweep wants to fail fast, a test battery exercising the abandonment
path faster still, while a device with slow teardown may warrant more. The cap
is not trajectory-determining, because the trajectory has ended at the final
snapshot before any join begins. So [replay](#g-replay) (the ordinary loop with the drain
reading recorded batches) neither records nor compares the cap ([§11.5][s11-5], [§12.7][s12-7]),
just as for `log_max` ([§11.2][s11-2]). The cap therefore lives on `Control`, not on the
`Deployment` ([D-256][d-256]).
````

### P1-22, unit B, `units/B/new.md`

Old:

````markdown
**The cap is a per-simulation setting, not an implementation constant** ([D-198][d-198]).
That is the disposition [§10.4][s10-4] gives its own two constants, extended here to an
operational one. Deployment contexts legitimately differ in patience. An
unattended sweep wants to fail fast, a test battery exercising the abandonment
path faster still, while a device with slow teardown may warrant more. The cap
is not trajectory-determining, because the trajectory has ended at the final
snapshot before any join begins. So [replay](#g-replay) (the ordinary loop with the drain
reading recorded batches) neither records nor compares the cap ([§11.5][s11-5], [§12.7][s12-7]),
just as for `log_max` ([§11.2][s11-2]). The cap therefore lives on `Control`, not on the
`Deployment` ([D-256][d-256]).
````

New:

````markdown
**The cap is a per-simulation setting, not an implementation constant** ([D-198][d-198]).
That is the disposition [§10.4][s10-4] gives its own two constants, extended here to an
operational one. Usage contexts legitimately differ in patience. A series of
runs nobody watches wants to fail fast, a test battery exercising the
abandonment path faster still, while a device with slow teardown may warrant
more. The cap is not trajectory-determining, because the trajectory has ended at
the final snapshot before any join begins. So [replay](#g-replay) (the ordinary loop with the
drain reading recorded batches) neither records nor compares the cap ([§11.5][s11-5],
[§12.7][s12-7]), just as for `log_max` ([§11.2][s11-2]). The cap therefore lives on `Control`, not
on the `Deployment` ([D-256][d-256]).
````

### P1-32, unit B, `units/B/new.md`

Old:

````markdown
**The report is written through the ordinary `report!(address, diagnostic)`
entry point**, addressed by the roster entry rather than by a handle
([D-189][d-189]).

There is no device task to hold a handle before the spawn. The address
supplies the device identity either way, which is why no call passes a
device id ([§11.8][s11-8]).
````

New:

````markdown
**The report is written through the ordinary `report!(address, diagnostic)`
entry point**, addressed by the roster entry rather than by a handle ([D-189][d-189]).
There is no device task to hold a handle before the spawn. The address supplies
the device identity either way, which is why no call passes a device id ([§11.8][s11-8]).
````

### P1-32, unit B, `units/B/new.md`

Old:

````markdown
No task is spawned for a failed device, so it is dead from the run's first
frame top ([D-138][d-138]).

That needs no machinery. Its `task_state` reads `:done` from the first
publication ([§12.2][s12-2]). A device that never ran never beat, so its
diagnostic cell also reads stale against the [§12.2][s12-2] threshold from
the start ([D-138][d-138]).
````

New:

````markdown
No task is spawned for a failed device, so it is dead from the run's first frame
top ([D-138][d-138]). That needs no machinery. Its `task_state` reads `:done` from the
first publication ([§12.2][s12-2]). A device that never ran never beat, so its diagnostic
cell also reads stale against the [§12.2][s12-2] threshold from the start ([D-138][d-138]).
````

### P1-32, unit B, `units/B/new.md`

Old:

````markdown
The claims of a failed device persist to run end ([D-138][d-138]).

This is the death-is-not-detach disposition ([§11.3][s11-3]), applied one
step earlier than (6)'s. The roster is frozen for the run, and the orphaned
root inputs hold the values the run started with. Those values are
well-defined by [root-input totality](#g-root-input-totality) (every root
input must hold a value) ([§14.6][s14-6]). An orphan of (6) holds a last
drained batch instead.
````

New:

````markdown
The claims of a failed device persist to run end ([D-138][d-138]). This is the
death-is-not-detach disposition ([§11.3][s11-3]), applied one step earlier than (6)'s.
The roster is frozen for the run, and the orphaned root inputs hold the values
the run started with. Those values are well-defined by [root-input totality](#g-root-input-totality)
(every root input must hold a value) ([§14.6][s14-6]). An orphan of (6) holds a last
drained batch instead.
````

### P1-20, unit B, `units/B/new.md`

Old:

````markdown
The claims of a failed device persist to run end ([D-138][d-138]). This is the
death-is-not-detach disposition ([§11.3][s11-3]), applied one step earlier than (6)'s.
The roster is frozen for the run, and the orphaned root inputs hold the values
the run started with. Those values are well-defined by [root-input totality](#g-root-input-totality)
(every root input must hold a value) ([§14.6][s14-6]). An orphan of (6) holds a last
drained batch instead.
````

New:

````markdown
The claims of a failed device persist to run end ([D-138][d-138]). This is the
death-is-not-detach disposition ([§11.3][s11-3]), applied one step earlier than (6)'s.
The roster is frozen for the run, and the orphaned root inputs hold the values
the run started with. Those values are well-defined by [root-input totality](#g-root-input-totality), the
rule that every root input must hold a value ([§14.6][s14-6]). An orphan of (6) holds a
last drained batch instead.
````

### P1-31, unit B, `units/B/new.md`

Old:

````markdown
With the flag set, the failure requests a control-plane stop, and that stop is
simply *already pending* at the run's first frame top. This protocol already
has that path. The loop reads that stop at the frame top, before any frame, so
the run advances no frame. No new exit protocol is needed, therefore. The
remaining roster entries still initialize, every rostered device getting its
`init!`/`shutdown!` pair uniformly. The run ends `stopped` where it started,
through this same tail, with its termination record naming the device
([§13.5][s13-5]). What the operator is left with is an ordinary stopped
simulation, whose terminal snapshot is the one the run started from and whose
termination record's tail residue holds the `DeviceCrash`. It is fully
serviceable by [§14][s14] and resumable by the next `run!` ([§12.6][s12-6])
once the device is plugged back in.
````

New:

````markdown
With the flag set, the failure requests a control-plane stop, and that stop is
simply *already pending* at the run's first frame top. The loop reads it there,
before any frame, so the run advances no frame. This protocol already has that
path, so no new exit protocol is needed. The remaining roster entries still
initialize, every rostered device getting its `init!`/`shutdown!` pair
uniformly. The run ends `stopped` where it started, through this same tail, with
its termination record naming the device ([§13.5][s13-5]). What the operator is left with
is an ordinary stopped simulation, whose terminal snapshot is the one the run
started from and whose termination record's tail residue holds the
`DeviceCrash`. It is fully serviceable by [§14][s14] and resumable by the next `run!`
([§12.6][s12-6]) once the device is plugged back in.
````

### P1-13, unit B, `units/B/new.md`

Old:

````markdown
With the flag set, the failure requests a control-plane stop, and that stop is
simply *already pending* at the run's first frame top. The loop reads it there,
before any frame, so the run advances no frame. This protocol already has that
path, so no new exit protocol is needed. The remaining roster entries still
initialize, every rostered device getting its `init!`/`shutdown!` pair
uniformly. The run ends `stopped` where it started, through this same tail, with
its termination record naming the device ([§13.5][s13-5]). What the operator is left with
is an ordinary stopped simulation, whose terminal snapshot is the one the run
started from and whose termination record's tail residue holds the
`DeviceCrash`. It is fully serviceable by [§14][s14] and resumable by the next `run!`
([§12.6][s12-6]) once the device is plugged back in.
````

New:

````markdown
With the flag set, the failure requests a control-plane stop, and that stop is
simply *already pending* at the run's first frame top. The loop reads it there,
before any frame, so the run advances no frame. This protocol already has that
path, so no new exit protocol is needed. The remaining roster entries still
initialize, every rostered device getting its `init!`/`shutdown!` pair
uniformly. The run ends `stopped` where it started, through this same tail, with
its termination record naming the device ([§13.5][s13-5]). What the operator is left with
is an ordinary stopped simulation, whose terminal snapshot is the one the run
started from and whose termination record's tail residue (the diagnostics the
run's-end sweep folds in) holds the `DeviceCrash`. It is fully serviceable by
[§14][s14] and resumable by the next `run!` ([§12.6][s12-6]) once the device is plugged back in.
````

### P1-32, unit B, `units/B/new.md`

Old:

````markdown
**An `InterruptException` inside a device's `init!` is the operator's stop,
not that device's crash** ([D-268][d-268]).

The bracket releases the device through `shutdown!` as for any throw and
spawns no task for it. In place of the `DeviceCrash` report it sets the
`:interrupt` stop through the stop word (the control plane's stop command,
one atomic word holding its issuer). The run's `should_abort` split above
therefore does not arise. The remaining roster entries still initialize,
and the run ends at its first frame top with zero frames advanced, through
the pending-stop path above. The device wrapper makes the same
discrimination for a raise inside a loop body ([§11.6][s11-6]).
````

New:

````markdown
**An `InterruptException` inside a device's `init!` is the operator's stop, not
that device's crash** ([D-268][d-268]). The bracket releases the device through
`shutdown!` as for any throw and spawns no task for it. In place of the
`DeviceCrash` report it sets the `:interrupt` stop through the stop word (the
control plane's stop command, one atomic word holding its issuer). The run's
`should_abort` split above therefore does not arise. The remaining roster
entries still initialize, and the run ends at its first frame top with zero
frames advanced, through the pending-stop path above. The device wrapper makes
the same discrimination for a raise inside a loop body ([§11.6][s11-6]).
````

### P1-12, unit B, `units/B/new.md`

Old:

````markdown
The interrupt is the escape from a run nothing else ends, and the deviceless
run has no other. A run with no finite `t_end` and no honoured stop request
is the configuration `UnboundedRun` names ([Appendix C][sC]). The interrupt
needs no entry point of its own ([D-132][d-132]). The stop already rides on
the control plane, the separate atomic surface carrying
pause, pace and stop ([§12.1][s12-1]). The exceptions-are-abnormal doctrine
([§13.5][s13-5], [D-060][d-060]) is untouched. That doctrine is about
*model* code, while this is the one exception whose meaning the framework
knows.
````

New:

````markdown
The interrupt is the escape from a run nothing else ends, and the deviceless run
has no other. A run with no finite `t_end` and no honoured stop request is the
configuration `UnboundedRun` names ([Appendix C][sC]). The interrupt needs no entry
point of its own ([D-132][d-132]). The stop already rides on the control plane ([§12.1][s12-1]).
The exceptions-are-abnormal doctrine ([§13.5][s13-5], [D-060][d-060]) is untouched. That doctrine
is about *model* code, while this is the one exception whose meaning the
framework knows.
````

### P1-32, unit B, `units/B/new.md`

Old:

````markdown
**Masking across the boundary is normative, not an implementation hint**
([D-132][d-132]).

The reason is that an `InterruptException` is delivered asynchronously. An
interrupt landing in the middle of a [sweep](#g-sweep) (one pass through the
execution order) would therefore destroy the boundary this protocol is built
on completing. It would also leave half-written [stores](#g-store) (the
framework-owned homes of a component's state) ([§13.6][s13-6]). That forces
a choice between `stopped` with dirty stores and a terminal `errored`. The
`stopped`-with-consistent-stores guarantee is exactly what the masking buys.
````

New:

````markdown
**Masking across the boundary is normative, not an implementation hint**
([D-132][d-132]). The reason is that an `InterruptException` is delivered asynchronously.
An interrupt landing in the middle of a [sweep](#g-sweep) (one pass through the execution
order) would therefore destroy the boundary this protocol is built on
completing. It would also leave half-written [stores](#g-store) (the framework-owned homes
of a component's state) ([§13.6][s13-6]). That forces a choice between `stopped` with
dirty stores and a terminal `errored`. The `stopped`-with-consistent-stores
guarantee is exactly what the masking buys.
````

### P1-20, unit B, `units/B/new.md`

Old:

````markdown
**Masking across the boundary is normative, not an implementation hint**
([D-132][d-132]). The reason is that an `InterruptException` is delivered asynchronously.
An interrupt landing in the middle of a [sweep](#g-sweep) (one pass through the execution
order) would therefore destroy the boundary this protocol is built on
completing. It would also leave half-written [stores](#g-store) (the framework-owned homes
of a component's state) ([§13.6][s13-6]). That forces a choice between `stopped` with
dirty stores and a terminal `errored`. The `stopped`-with-consistent-stores
guarantee is exactly what the masking buys.
````

New:

````markdown
**Masking across the boundary is normative, not an implementation hint**
([D-132][d-132]). The reason is that an `InterruptException` is delivered asynchronously.
An interrupt landing in the middle of a [sweep](#g-sweep) (one pass through the execution
order) would therefore destroy the boundary this protocol is built on
completing. It would also leave [stores](#g-store) (the framework-owned homes of a
component's state) half-written ([§13.6][s13-6]). That forces a choice between `stopped`
with dirty stores and a terminal `errored`. The `stopped`-with-consistent-stores
guarantee is exactly what the masking buys.
````

### P1-32, unit B, `units/B/new.md`

Old:

````markdown
**The tail's bookkeeping is masked too** ([D-268][d-268]).

After the joins, the run's-end sweep, the termination record and the
terminal lifecycle state are written under the same mask. An interrupt
landing there would otherwise abort the sequence half-way and leave the
lifecycle `running`, every service refusing. A raise deferred to the end of
that bookkeeping propagates out of `run!` raw, the simulation already
terminal.
````

New:

````markdown
**The tail's bookkeeping is masked too** ([D-268][d-268]). After the joins, the run's-end
sweep, the termination record and the terminal lifecycle state are written under
the same mask. An interrupt landing there would otherwise abort the sequence
half-way and leave the lifecycle `running`, every service refusing. A raise
deferred to the end of that bookkeeping propagates out of `run!` raw, the
simulation already terminal.
````

### P1-33, unit B, `units/B/new.md`

Old:

````markdown
**A forced throw reaches the defensive arm** ([D-268][d-268]). Julia stops
deferring after repeated SIGINTs in a short window, warns that it is forcing
the throw, and raises inside the mask. That is the one way the branch
[§13.4][s13-4] keeps is reached. The arm abandons the frame unpublished and
the run ends `stopped`, the source `ControlRequestedStop(:interrupt)`. The
published record is consistent, since the frame published nothing. The
stores may hold mid-boundary values until the next `init!`, `restore!` or
`replay!` resets them, as after a throw inside
[boundary zero](#g-boundary-zero) (the initialization boundary, the ordinary
macro-sequence with an empty integrate) ([§13.4][s13-4]). `checkpoint`
refuses such a run as `CheckpointMidFrame`, since the
[executor](#g-executor) (the compiled form of the stage execution order) no
longer rests where its last snapshot was published ([§12.6][s12-6]). The
[trace](#g-trace) (the primary record of a session) is the reproduction
([§12.7][s12-7]).
````

New:

````markdown
**A forced throw reaches the defensive arm** ([D-268][d-268]). Julia stops deferring
after repeated SIGINTs in a short window, warns that it is forcing the throw,
and raises inside the mask. That is the one way the branch [§13.4][s13-4] keeps is
reached. The arm abandons the frame unpublished and the run ends `stopped`, the
source `ControlRequestedStop(:interrupt)`. What the run published is consistent,
since the frame published nothing. The stores may hold mid-boundary values until
the next `init!`, `restore!` or `replay!` resets them, as after a throw inside
[boundary zero](#g-boundary-zero) (the initialization boundary, the ordinary macro-sequence with an
empty integrate) ([§13.4][s13-4]). `checkpoint` refuses such a run as
`CheckpointMidFrame`, since the [executor](#g-executor) (the compiled form of the stage
execution order) no longer rests where its last snapshot was published ([§12.6][s12-6]).
The [trace](#g-trace) (the primary record of a session) is the reproduction ([§12.7][s12-7]).
````

### P1-20, unit B, `units/B/new.md`

Old:

````markdown
**A forced throw reaches the defensive arm** ([D-268][d-268]). Julia stops deferring
after repeated SIGINTs in a short window, warns that it is forcing the throw,
and raises inside the mask. That is the one way the branch [§13.4][s13-4] keeps is
reached. The arm abandons the frame unpublished and the run ends `stopped`, the
source `ControlRequestedStop(:interrupt)`. What the run published is consistent,
since the frame published nothing. The stores may hold mid-boundary values until
the next `init!`, `restore!` or `replay!` resets them, as after a throw inside
[boundary zero](#g-boundary-zero) (the initialization boundary, the ordinary macro-sequence with an
empty integrate) ([§13.4][s13-4]). `checkpoint` refuses such a run as
`CheckpointMidFrame`, since the [executor](#g-executor) (the compiled form of the stage
execution order) no longer rests where its last snapshot was published ([§12.6][s12-6]).
The [trace](#g-trace) (the primary record of a session) is the reproduction ([§12.7][s12-7]).
````

New:

````markdown
**A forced throw reaches the defensive arm** ([D-268][d-268]). Julia stops deferring
after repeated SIGINTs in a short window, warns that it is forcing the throw,
and raises inside the mask. That is the one way the branch [§13.4][s13-4] keeps is
reached. The arm abandons the frame unpublished and the run ends `stopped`, the
source `ControlRequestedStop(:interrupt)`. What the run published is consistent,
since the frame published nothing. The stores may hold mid-boundary values until
the next `init!`, `restore!` or `replay!` resets them, as after a throw inside
[boundary zero](#g-boundary-zero), the initialization boundary, which runs the ordinary
macro-sequence with an empty integrate ([§13.4][s13-4]). `checkpoint` refuses such a run
as `CheckpointMidFrame`, since the [executor](#g-executor) (the compiled form of the stage
execution order) no longer rests where its last snapshot was published ([§12.6][s12-6]).
The [trace](#g-trace) (the primary record of a session) is the reproduction ([§12.7][s12-7]).
````

### P1-35, unit B, `units/B/new.md`

Old:

````markdown
(the file ends "the run.\n\n")
````

New:

````markdown
(the file ends "the run.\n")
````


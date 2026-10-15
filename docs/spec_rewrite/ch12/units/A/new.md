## 12. Runtime periphery: lifecycle and orchestration

This chapter specifies the machinery that drives the loop itself, taking the
loop of [§10][s10] and the data plane of [§11][s11] as given. [§12.1][s12-1] covers the control plane;
[§12.2][s12-2] loop scheduling, in turn its wait primitive, its yields, the thread budget
and the liveness heartbeat; [§12.3][s12-3] the next-snapshot wait; [§12.4][s12-4] the shutdown
protocol; [§12.5][s12-5] scripts and the mid-run mutation doctrine; [§12.6][s12-6] the run
lifecycle from `init!`, and partial advance; and [§12.7][s12-7] replay, where the trace
re-drives the ordinary loop.

### 12.1 Control plane

Pause, un-pause, pace changes, `margin` changes and stop are a few fields on a
separate atomic surface, the [control plane](#g-control-plane). It is not staging, structurally
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

The loop consults the control plane at frame top, the start of each frame. A
change issued while a frame runs or waits is observed at the next frame top, at
most one frame budget (`h/p`, the step over the pace) later ([D-269][d-269]). The pause
block, described with the pause verbs below, is the one wait that wakes at once.

The stop's issuers are the operator's channels and, in an interactive session,
Ctrl-C. The operator's channels are a front end's button, the handle of a
[device](#g-device) (any attached participant in the periphery) and calling
code ([D-310][d-310]). An [operator interrupt](#g-operator-interrupt) (Ctrl-C
read as a control-plane stop) sets exactly this stop, with no separate entry
point involved ([§12.4][s12-4], [D-132][d-132]). The loop catches it at one of its unmask
points, where a deferred Ctrl-C is raised ([§12.4][s12-4]).

**The stop word carries its issuer** ([D-203][d-203]). The stop word is the control
plane's stop command, one atomic word holding its issuer. Each issuing site
writes its identity (the device's name, `:code`, or `:interrupt`) by
compare-and-swap from empty, and the first writer wins. The loop's frame-top
read consults the word for non-empty, so the recorded issuer is the request that
actually initiated the tail, the ordered shutdown sequence of [§12.4][s12-4]. The issuer
lands in the [termination record](#g-termination-record) (the stopped-sim value naming how the run ended)
as its `ControlRequestedStop`'s payload ([§13.5][s13-5], [D-203][d-203]).

**`ControlRequestedStop` sits outside the stop policy** ([D-255][d-255]). The
policy is what the caller declares for one advance ([§13.5][s13-5]). The stop
word is what anyone can issue at any moment.

**The pause is two verbs on the simulation** ([D-268][d-268]). `pause!(sim)`
sets the pause flag and `resume!(sim)` clears it, from any task and in any
lifecycle state. `paused(sim)` reads it. The loop consults the flag at frame
top, so a `pause!` issued before `run!` starts the run paused at its first
frame top. While paused the loop blocks on a condition variable (notified on
un-pause and stop), not a spin. A stop issued while paused wakes the loop,
which observes the stop word and enters the tail with no further frame
([§12.4][s12-4]). `step!` shares the frame top and blocks the same way, until
`resume!` or a stop from another task.

A paused run is still running. The lifecycle reads `running`, and the
[roster](#g-roster) (the list of attached device entries) stays frozen
([D-106][d-106]).

**The tail clears the pause flag beside the sticky stopped status**
([D-268][d-268]). The flag is never cleared at a run's start. The stop word,
by contrast, is cleared at the top of each run, because a stop belongs to the
run it ended. A pause left set by a run that stopped while paused would
instead hold the next run at its first frame top, on a flag nobody remembers
setting. Clearing it in the tail removes that trap and keeps the start-paused
spelling above.

The device handle carries no pause ([§11.6][s11-6]). Whether it gains the
control verbs for the bridge ([§11.7][s11-7]) is pending (`pending.md`, [D-310][d-310]).

**Pace and `margin` are two more verbs and two readers** ([D-269][d-269]).
`pace!(sim, p)` and `margin!(sim, m)` set them from any task in any lifecycle
state, and `pace(sim)` and `margin(sim)` read them. `margin` ([§10.7][s10-7]) rides on
the control plane for the same reason `pace` does. It tunes the wait, never the
arithmetic, so retuning the coarse/spin split mid-run is safe by construction.
`run!` and `replay!` take both as keywords and write them when called. Both are
declared by the advance, as `t_end` is. `pace` defaults to `Inf` and `margin` to
2 ms ([Appendix B][sB], [D-133][d-133]). `step!` takes neither and never waits on the pacer. A
stepping session is the harness mode ([§12.6][s12-6]), and its frames are bit-identical
to `run!`'s by [§10.7][s10-7]'s invariant. `pace` is a positive real, `Inf` admitted, and
`margin` a non-negative real, `Inf` admitted. The two setters and the two
keywords refuse anything else under `ArgumentInvalid` ([Appendix C][sC]).

Beside pause, pace and `margin`, `Control` keeps the stop word, the sticky
stopped status, the running flag ([D-317][d-317]) and the wait
([§12.3][s12-3]). **`Control` also keeps the shutdown tail's `join_timeout`**
([§12.4][s12-4], [D-256][d-256]). The lifecycle state is not stored, and
`lifecycle(sim)` derives it ([§12.6][s12-6]). A run's outcome is not a control
surface, so `termination` belongs to the [`Run`](#g-run) (the state one run
owns), not to `Control` ([§12.6][s12-6], [D-255][d-255]). The control plane is
what anyone may poke.

### 12.2 Loop scheduling: wait primitive, yields, thread budget

[§10.7][s10-7] fixed the shape of the pacer's wait, hybrid sleep-then-spin,
and leaves the choice of the coarse phase's primitive to this section. That
choice is a scheduling decision rather than an arithmetic one. It settles
what else can run while a [frame](#g-frame) (one iteration of the loop) waits.
It is made here, together with the two questions that trail it, whether a
frame is guaranteed to yield at all and how many threads a session needs. The
section ends with the liveness heartbeat that makes a starved device
diagnosable.

#### The coarse phase's primitive

**The coarse phase uses task-yielding `sleep`**, and there is no
`systemsleep` variant ([D-027][d-027]). What the choice buys is the wait slot.
`sleep` releases the loop's thread, which makes the pacer's wait the natural
scheduling window for the co-resident tasks of [devices](#g-device) (the
attached participants in the periphery). The design already spends that slot
twice, as the staging slot ([§10.7][s10-7]) and as what the
[drain](#g-drain) (the frame-top swap that applies staged device writes) takes
([§11.4][s11-4]).

A `systemsleep` variant for dedicated-thread hard real-time deployments is a
[guarded addition](#g-guarded-addition) (a capability the design admits but
does not build).

#### The per-frame yield

**With devices attached, every frame yields at least once** ([D-027][d-027]).
The rule is semantically free, because [pacing](#g-pacing) (the waits inserted
between completed frames), and hence yielding, is outside the semantics
([§10.7][s10-7], [D-021][d-021]).

The yield is implicit in the coarse-phase `sleep` whenever that phase runs.
An explicit `yield()` covers the frames where it does not run, namely unpaced
runs and pure-spin frames with budget ≤ margin. The spin phase itself never
yields ([D-027][d-027]). Yielding there would trade its µs precision for
scheduler noise.

The consequence is a bound on thread occupancy. The loop holds a thread for at
most one frame before the scheduler can run anyone else. Julia's scheduler is
cooperative, and a stall of that scheduler requires a thread monopolist, a
never-yielding task that holds its thread forever. That precondition is
structurally absent from framework tasks.

#### The thread budget

**The thread budget is a documented sizing rule and a startup warning, not a
hard error** ([D-027][d-027]).

The scheduler stall FlightCore's `nthreads` error prevented cannot reproduce
here, for two reasons. The loop yields every frame. Nothing couples a stall to
anyone else, the GUI least of all. It waits on nothing, ever. It uses a snapshot
acquire-load, its own [staging cell](#g-staging-cell) and atomic control. Under any starvation,
then, the front end keeps rendering and the stop button keeps working.

Undersized sessions degrade to laggy inputs and stale [snapshots](#g-snapshot) (the immutable
per-boundary publications), which are visible, recoverable states.

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

#### The liveness heartbeat

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

**`task_state` has three values** ([D-270][d-270]). Outside a run every device
reads `:none`. Inside a run a device reads `:running` while its task lives and
`:done` once that task has ended, whether the body returned or the wrapper
caught its crash ([§11.6][s11-6]). A device whose `init!` threw, and so
spawned no task, reads `:done` as well. The record's crash count tells a crash
from a return. `orphaned` on a record is exactly `:done` ([§11.7][s11-7],
[D-270][d-270]).

**Stale means a liveness timestamp more than 2 s behind wall clock**
([D-133][d-133]). The threshold is deliberately loose, because the heartbeat
is advisory. It is a liveness display and a record, never a kill trigger,
never a detach. It must also tolerate a device legitimately parked in a
blocking read between rare data.

### 12.3 The next-snapshot wait

Rate-matched output [devices](#g-device) (attached participants in the
periphery), such as telemetry and disk streaming, act once per boundary. A
[boundary](#g-boundary) is a published consistency point. What they need from
the framework is a way to learn that a boundary has happened without polling
for it. The [next-snapshot wait](#g-next-snapshot-wait) (a device's blocking
wait for the next publication) is that way. This section gives its two
artifacts, the loop's side, the device's side, its newest-wins semantics, and
how the counter differs from the other two indices, in that order.

**Two artifacts provide the wait, a monotonic [boundary counter](#g-boundary-counter) plus one
`Threads.Condition`** ([D-028][d-028]). The boundary counter is the loop's own. It counts
*published boundaries*, that is grid, `t*` and [boundary zero](#g-boundary-zero) (the initialization
boundary at `t₀`), not frames ([§10.1][s10-1], [§10.4][s10-4]). Consecutive wakes are therefore
not necessarily `h` apart.

The loop's publication is `lock; counter += 1; notify; unlock`, nanoseconds
of framework-only code. Waiters never block it. One parked in `wait` has
released the lock as part of parking.

The order of the two publications is normative. **The release-store of [`latest`](#g-latest),
the atomic reference readers acquire-load ([§11.2][s11-2]), happens before the counter
increment under the lock** ([D-114][d-114]).

```julia
# the loop, at every published boundary
@atomic latest = snap    # 1. release-store: the snapshot becomes reachable (§11.2)
lock(cond) do            # 2. only then the counter, under the lock
    counter += 1
    notify(cond)         #    parked waiters wake and re-test their predicate
end
```

The device side's test `counter > last_seen` (below) therefore implies that
`latest` holds at least that boundary, and a waiter can never wake onto a
[snapshot](#g-snapshot) (the immutable per-boundary publication) that is stale. The converse is
expected and correct. A waiter may observe a *newer* snapshot than the increment
that woke it. Newest wins.

The device side is `wait_next_snapshot(handle)`, which blocks until
`counter > last_seen && running` under the canonical predicate-loop idiom. That
idiom handles waiters at different paces, boundaries skipped while transmitting,
and shutdown, all with no per-frame reset. Shutdown works because [§12.4][s12-4] wakes
all waiters and each predicate then routes its owner out ([D-028][d-028]).

**The wait's semantics are newest-wins, no queues** ([D-028][d-028]). A slow consumer
skips boundaries and always receives the current world. This mirrors the inbound
side. Inbound [coalescing](#g-coalescing) (the compare-and-swap merge that leaves one pending
batch per device) keeps the newest level per face, and the wait delivers the
newest snapshot, the same zero-order hold (ZOH) decision. No backpressure exists
in either direction, and the loop never waits on anyone. Per-consumer
every-boundary queues are rejected ([D-028][d-028]).

A `Base.Event` latch is the wrong primitive here ([D-028][d-028]). Condition
variables carry no facts, only "look again". The facts that matter, the
counter and `running`, live in state each waiter tests privately.

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

The GUI does not use the wait. Being VSync-paced, it reads `latest` at each
render.

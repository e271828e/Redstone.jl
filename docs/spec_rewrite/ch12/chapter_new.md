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

### 12.4 Shutdown protocol

A run ends when its time is up, when someone stops it, or when the model
itself says so. Whatever the cause, the same work has to happen. The loop
has to stop on a [boundary](#g-boundary) (a published consistency point).
The task each [device](#g-device) (any attached participant in the
periphery) runs on has to be woken out of whatever it was blocked on. Every
resource acquired for the run has to be released before `run!` returns.
This section specifies that sequence, which it calls the tail throughout. It
also specifies the two things that bracket the tail. One is the pre-spawn
initialization at the top of a run, which is a step of this same protocol.
The other is the [operator interrupt](#g-operator-interrupt) (Ctrl-C in an
interactive session), which enters the tail rather than bypassing it.

#### The tail: the ordered sequence every stop takes

**Steps (1) through (5) below run in that order on every stop**, whatever
initiated it ([D-030][d-030]). Steps (6) and (7) specify what happens when a
device task or the loop itself ends first.

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
2. Wake all framework waits. The waits are the [next-snapshot
   wait](#g-next-snapshot-wait) (`wait_next_snapshot(handle)`) and the pause.
   Each waiter observes the stopped status and unwinds. A stop issued while
   paused therefore works.
3. Unblock device-specific blocking calls. The hook is `unblock!(device)`,
   default no-op. A network input's override closes its own socket, which
   raises in the blocked task. The framework wrapper catches that raise and
   treats it as shutdown. This demotes FlightCore's EOT convention from
   essential shutdown mechanism to an optional wire-protocol courtesy between
   remote peers.
4. Loop bodies exit. The exit is the author's own `while running(handle)`
   loop, the authoring contract of [§11.6][s11-6]. That authoring contract
   teaches two obligations, the predicate check and interruptible blocking
   ([D-373][d-373]). Steps (2) and (3) are the framework's half. They wake its
   own waits and call each device's `unblock!`. The wrapper's `finally
   shutdown!(device)` is guaranteed on every exit path.
5. Join under the `join_timeout` cap. It is a keyword of the `Simulation`
   constructor, held on `Control`, the tail's own owner ([§12.1][s12-1], [D-256][d-256]), a
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
7. Loop-side failure. A failure on the loop's own side runs steps (1) through
   (5) from the catch path ([D-030][d-030]). [§13.6][s13-6] specifies that
   path, which discards the failed boundary and promotes the previous snapshot
   to final. FlightCore's `SimulationTermination` catch path was the
   precedent. The exception-based termination idiom itself has no place here
   ([§13.5][s13-5], [D-060][d-060]). Devices therefore unwind cleanly
   regardless of who died.

The ordered part, in one line:

> (1) stop observed → current boundary completed → final snapshot published
> → sticky `stopped` set → (2) framework waits woken → (3) `unblock!`
> per device → (4) loop bodies return, each through its wrapper's
> `finally shutdown!` → (5) join under the `join_timeout` cap → `run!`
> returns

`t_end` lands on the grid. **The run ends at the first grid boundary whose time
reaches or exceeds `t_end`** ([D-133][d-133]). The run takes whole frames only, never a
shortened final step, which grid integrity forbids ([§10.4][s10-4]). Each grid time is
indexed, `tₖ = t₀ + k·h`, and never accumulated ([§10.4][s10-4]). The final boundary may
therefore overshoot `t_end` by up to `h`. The termination record carries the
actual final `t` ([§13.5][s13-5]). This is the `t_plus` spelling ([§12.6][s12-6]) applied to the
run's own clock.

The two termination sources differ in nature. `t_end` is a grid fact,
checked against boundary times on the grid. Stop requests are checked at
*every* published boundary, `t*` included ([§13.5][s13-5]).

The final snapshot goes out before the status is set. Publishing first
guarantees that output devices can flush the true final state. The status in
that terminal snapshot carries the run's cumulative diagnostic counters
([§11.8][s11-8]), the warning account of a run nobody watched, complete up to
that snapshot's own frame top. **What the tail itself produces is folded into
the termination record and presented through the logging backend, never
published** ([D-201][d-201], [D-203][d-203]). It comes later by construction.

That terminal snapshot is retained in the [log](#g-log) (the retained
sequence of published snapshots) unconditionally, under any `log_every` and
any `log_max` ([§11.2][s11-2], [D-368][d-368]).

The `join_timeout` default of five seconds is generous for front-end window
teardown and socket closes. It is short enough that an abandoned join reads as a
diagnosed timeout rather than a hang.

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

#### What survives the tail

After (5) the task set is empty, since device tasks are per-run artifacts
([§11.1][s11-1], [D-093][d-093]). `shutdown!` has also released each
device's OS resources. What survives a stop is the roster entry, with its
binding, claims and stable device id ([§11.3][s11-3]). A task never
survives, and neither does a live resource. That holds for a device whose
task died mid-run too. Its roster entry is indistinguishable at this point
from any other's. Once stopped, `detach!` can remove a roster entry and
release its claims ([D-106][d-106]).

The next run re-acquires everything. The next `run!` re-runs device
`init!`, since resource acquisition is per-run ([D-093][d-093]). The
precedent is FlightCore's network device, `network.jl`, which created a new
socket at each `init!`. The next `run!` also spawns fresh tasks against the
[§12.3][s12-3] counter, which is never re-armed. Each task reads its
`last_seen` off the counter at spawn. While stopped there are no device
tasks at all, so voluntary exit and the [§12.2][s12-2] liveness heartbeat are
run-scoped observables. A device unplugged while stopped surfaces as the
next run's `init!` failure, disposed of by the initialization bracket below.

#### Initialization: the pre-spawn bracket

**Initialization is a step of this protocol, taken at the top of a run**
([D-138][d-138]). Before any task is spawned, the loop calls `init!` once per
roster entry, in attachment order, on the [calling task](#g-calling-task)
(the task that invoked `run!`). Each call sits in its own bracket.

```julia
for entry in roster                       # attachment order, calling task
    push!(live, entry)                    # listed for release before `init!` begins
    try
        init!(entry.device)
    catch e
        shutdown!(entry.device)           # release, unconditionally (§11.6)
        pop!(live)                        # released, so unlisted
        if e isa InterruptException       # the operator's stop, never a crash (below)
            stop!(control, :interrupt)
        else
            # pre-spawn: the entry is the address, no task holds a handle yet
            report!(entry, DeviceCrash(e, entry.should_abort))
            entry.should_abort && stop!(entry.handle)
        end
                                          # no dead-marking: no task is spawned (§12.2)
    end
end
```

The bracket is what makes "guaranteed on every exit path" ([§11.6][s11-6])
true of the path outside that wrapper. A device that throws half-way through
acquisition is handed back to `shutdown!` right there, so its partially
acquired OS resources are released rather than leaked ([D-138][d-138]). That
is exactly why `shutdown!` owes tolerance of a partially initialized device,
a rule [§11.6][s11-6] teaches.

The roster entry is listed for release before its `init!` begins
([D-268][d-268]). The bracket unlists it once its own `shutdown!` has
returned. An operator interrupt that escapes the bracket therefore finds
listed every device whose `init!` began and that the bracket has not
released, and the run releases each before it ends. A device listed and not
yet initialized can be released having opened nothing, which `shutdown!`
tolerates ([§11.6][s11-6]).

**The report is the ordinary `DeviceCrash`, not a kind of its own**
([D-138][d-138], [Appendix C][sC]). Its [payload](#g-payload) (the
structured data a diagnostic carries beside its kind) already carries the
cause exception and whether `should_abort` was set. The diagnostic cell it
is written to names the device. That is everything an init-time failure has
to say. The name is honest. A device that cannot acquire its resources has
crashed before it lived.

**The report is written through the ordinary `report!(address, diagnostic)`
entry point**, addressed by the roster entry rather than by a handle ([D-189][d-189]).
There is no device task to hold a handle before the spawn. The address supplies
the device identity either way, which is why no call passes a device id ([§11.8][s11-8]).

No task is spawned for a failed device, so it is dead from the run's first frame
top ([D-138][d-138]). That needs no machinery. Its `task_state` reads `:done` from the
first publication ([§12.2][s12-2]). A device that never ran never beat, so its diagnostic
cell also reads stale against the [§12.2][s12-2] threshold from the start ([D-138][d-138]).

The claims of a failed device persist to run end ([D-138][d-138]). This is the
death-is-not-detach disposition ([§11.3][s11-3]), applied one step earlier than (6)'s.
The roster is frozen for the run, and the orphaned root inputs hold the values
the run started with. Those values are well-defined by [root-input totality](#g-root-input-totality), the
rule that every root input must hold a value ([§14.6][s14-6]). An orphan of (6) holds a
last drained batch instead.

**The run's disposition splits on `should_abort`, uniformly with (6)**
([D-138][d-138]). With the flag clear, which is the default
([§11.6][s11-6]), the remaining roster entries initialize, the run starts,
and the sim runs with that device absent from the run's first frame. That
is (6)'s "the sim continues with the device's *task* absent", shifted to the
run's start.

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

**An `InterruptException` inside a device's `init!` is the operator's stop, not
that device's crash** ([D-268][d-268]). The bracket releases the device through
`shutdown!` as for any throw and spawns no task for it. In place of the
`DeviceCrash` report it sets the `:interrupt` stop through the stop word (the
control plane's stop command, one atomic word holding its issuer). The run's
`should_abort` split above therefore does not arise. The remaining roster
entries still initialize, and the run ends at its first frame top with zero
frames advanced, through the pending-stop path above. The device wrapper makes
the same discrimination for a raise inside a loop body ([§11.6][s11-6]).

#### The operator interrupt

**The operator interrupt is a stop, not a failure** ([D-132][d-132]). Ctrl-C
in an interactive session is a control-plane stop command issued by hand.
The run completes the current boundary, publishes the final snapshot, takes
this tail like any other stop, and ends `stopped`. The result is
boundary-consistent. It is fully serviceable by the [§14][s14] stopped-sim
services and resumable by the next `run!` ([§12.6][s12-6]).

The interrupt is the escape from a run nothing else ends, and the deviceless run
has no other. A run with no finite `t_end` and no honoured stop request is the
configuration `UnboundedRun` names ([Appendix C][sC]). The interrupt needs no entry
point of its own ([D-132][d-132]). The stop already rides on the control plane ([§12.1][s12-1]).
The exceptions-are-abnormal doctrine ([§13.5][s13-5], [D-060][d-060]) is untouched. That doctrine
is about *model* code, while this is the one exception whose meaning the
framework knows.

The interrupt's scope is the interactive session. Outside the REPL, Julia's
default (`exit_on_sigint(true)`) kills the process on SIGINT before any of
this machinery runs. The framework flips nothing process-global
([D-132][d-132]). [Unattended runs](#g-unattended-run), those with empty
staging and no snapshot readers, rely on `t_end` and stop requests, as they
already must.

**Masking across the boundary is normative, not an implementation hint**
([D-132][d-132]). The reason is that an `InterruptException` is delivered asynchronously.
An interrupt landing in the middle of a [sweep](#g-sweep) (one pass through the execution
order) would therefore destroy the boundary this protocol is built on
completing. It would also leave [stores](#g-store) (the framework-owned homes of a
component's state) half-written ([§13.6][s13-6]). That forces a choice between `stopped`
with dirty stores and a terminal `errored`. The `stopped`-with-consistent-stores
guarantee is exactly what the masking buys.

The loop masks delivery across the boundary macro-sequence, using Julia's
`disable_sigint`, a sigatomic counter increment that is negligible per
frame. It takes the deferred raise at the unmask points. They are the frame
top, where it already consults the control plane ([§12.1][s12-1]), and
points inside its wait and pause blocks. All of those points are
boundary-consistent. Caught at one of them, the interrupt sets the
control-plane stop and enters this tail. The catch site ([§13.4][s13-4])
therefore never sees a single interrupt.

**A deferred interrupt yields to the frame's own stop request**
([D-268][d-268]). Stop requests are consulted at each publication and the
stop word at the next frame top ([§13.5][s13-5]), and the deferred raise
lands between the two. Where the frame's publication found an honoured
request holding, that request is the recorded source and the interrupt is
satisfied by the run ending. Where none held, the interrupt sets the stop
word and the source is `ControlRequestedStop(:interrupt)`.

**A frame that throws with an interrupt pending ends `errored`**
([D-268][d-268]). The frame's own throw is the disposition
([§13.4][s13-4]). The catch wraps the cause under the mask and consumes the
pending interrupt on its way out. The run then takes the abnormal shutdown entry
under that `StepError` ([§13.6][s13-6]). The alternative, `stopped` over a
half-written boundary, is what the masking exists to prevent. The interrupt
is satisfied by the run ending.

**An interrupt after a frame's throw does not displace it**
([D-268][d-268]). `run!`, `replay!` and `step!` store the loop's throw before
an interrupt can displace it, and the masked bookkeeping below builds the
record from that store. The run therefore ends `errored` under its
`StepError` wherever a later interrupt lands. An interrupt that cuts the
handling of the throw itself propagates out of the call raw, and the
disposition of the failure is skipped ([§13.4][s13-4]). The record is still
written and the lifecycle is still `errored`.

**The tail's bookkeeping is masked too** ([D-268][d-268]). After the joins, the run's-end
sweep, the termination record and the terminal lifecycle state are written under
the same mask. An interrupt landing there would otherwise abort the sequence
half-way and leave the lifecycle `running`, every service refusing. A raise
deferred to the end of that bookkeeping propagates out of `run!` raw, the
simulation already terminal.

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

**A second interrupt during the tail collapses the remaining joins
immediately** ([D-132][d-132]). That is (5)'s abandonment path taken at once,
with devices still reported by name (`DeviceJoinTimeout`). The run still
ends `stopped`. Escalation shortens the tail, never reclassifies the run.

### 12.5 Scripts and the mid-run mutation doctrine

This section settles what the [periphery](#g-periphery) (everything outside the loop that
exchanges data with it) may do to a running model. The periphery's attached
participants are its [devices](#g-device). The section surveys FlightCore's mid-run
mutations, states the clock criterion that maps scripts to [components](#g-component) (units of
modeling), eliminates FlightCore's per-step hook `user_callback!`, covers manual
events and mid-run re-initialization, and ends with the doctrine's final form.

What the consumers demonstrably mutate mid-run is surveyed here. The line
references are to `c172_demos.jl`, FlightCore's demo file. FlightCore's
`user_callback!` has exactly two archetypes. The first is the timetable
script, `elevator_offset` as a function of `t` (c172_demos.jl:290). The second
is the synthetic pilot, a phase FSM (finite-state machine) reading `y` and
writing mode requests, references, flaps and wind (c172_demos.jl:423, 525).
Both write only `u` fields. No demo, test or GUI path pokes `x`/`s` mid-run,
and `init!`/trim appear only between construction and `run!`
(c172_demos.jl:303).

**A sim-time script becomes a [scenario component](#g-scenario-component), and a wall-clock interaction
becomes a device** ([D-031][d-031]). A scenario component is an ordinary periodic
discrete component holding a sim-time script. Sim-time scripts are model
behavior, which is why they become scenario components. Both archetypes are
clocked by *sim time*, `t`, the trajectory. Mapping them to devices is rejected
([D-031][d-031]). The clock is the criterion.

A script mapped to a component is periodic discrete, with `K = 1` for the
`dt = 0.02` callbacks FlightCore had, `K` being the multiplier in
`Relative(K)` ([§10.5][s10-5]). It executes synchronously in the loop,
deterministic paced or unpaced. It is replayed by recomputation, with no
[trace](#g-trace) (the records of each frame's drained inputs). A device, by
contrast, is traced and replayed from the trace.

The component mapping is strictly richer than the callback it replaces.

- The callback's `Ref(:init)` phase closure becomes honest `s`, which a
  [port](#g-port) (one declared name with its cell) can publish to
  [snapshots](#g-snapshot), logs and plots. A snapshot is the immutable
  per-boundary publication.
- Inputs arrive fresh from the same [boundary](#g-boundary) (a published consistency point), by
  topological order. The callback ran post-step, one boundary staler.
- The pure timetable script is a one-liner reading the clock out of its
  [bundle](#g-bundle) (the NamedTuple of zero-copy views a component function
  receives). That one-liner is `y_direct(c, (; t)) = (; offset = profile(t))`,
  exact at its own [ticks](#g-tick), with no latch state of its own. A tick
  is an instant at which a discrete component's stages and update run.
- In a scenario configuration the script drives the input ports of the avionics
  (the onboard flight systems). [§11.7][s11-7] therefore renders a front end's
  corresponding widgets read-only, each showing its source ([D-310][d-310]). Its
  port-resolution rule resolves FlightCore's demo-vs-GUI dead-slider fight.

**`user_callback!` is eliminated** ([D-031][d-031]). It is the periphery's
`f_step!`, FlightCore's unconditional per-step hook ([§2.5][s2-5]), and cheap
composition leaves it without justification. Its call sites migrate to
scenario components, not devices.

**Manual event triggering needs no mechanism** ([D-031][d-031]). It takes a
[root input](#g-root-input) (the root component's own input face) plus a
[boundary-detected](#g-boundary-detected) [guard](#g-guard) (an edge check at
step boundaries only, with no root-finding) reading that root input. That is
already expressible in settled machinery. The levels doctrine applies
([§11.4][s11-4]), with latched commands or counters. The engine start/stop
buttons of FlightCore's demos were `u`-writes.

**Mid-run re-initialization is not built** ([D-031][d-031]), because it is not
demonstrated. Initialization and trim are stopped-sim workflows, first-class
services of [§14][s14]. No concurrency perimeter exists there. There is no loop and no
devices, just plain single-task code. The shape of the [guarded addition](#g-guarded-addition) (a
capability the design admits but does not build) is on record should demand
appear. It would be a traced, boundary-executed intervention command applied
through project → [sweep](#g-sweep) → publish, so that no consumer ever observes un-decoded
state. A sweep is one pass through the execution order against the current
state.

In the doctrine's final form, while a simulation runs, **the periphery stages
root-input writes and issues control commands** ([§2.2][s2-2],
[D-031][d-031]). Structurally, it does nothing else. Anything that wants to
poke the model mid-run is one of three things.

- It is an *input* in disguise, so wire a root input and a guard.
- It is *model behavior* in disguise, so add a scenario component.
- It is a *wall-clock interaction*, so attach a device.

Graceful termination follows the same shape ([§13.5][s13-5]). It is a
[stop request](#g-stop-request) (an output port of the framework enum
`StopFlag`) declared in the model, honoured unless the advance ignores it
([D-316][d-316]). It is never a callback, and never a thrown exception
([D-060][d-060]).

### 12.6 Run lifecycle and partial advance

This section specifies what a `Simulation` and its run own, the lifecycle a
simulation moves through, how it advances and restarts, what it keeps of its
[devices](#g-device) (any attached participants in the periphery) across runs, and the stop
policy each advance declares. A simulation is in one of five lifecycle states,
built, initialized, running, stopped or errored. A *door* is an entry point that
builds a run, and there are three, `init!`, `restore!` and `replay!`. A run's
`feed` is the recording `replay!` attached, or `nothing`. The [input mode](#g-input-mode) says
where the next [frame](#g-frame) (one grid step, the unit of scheduling) takes its inputs
from.

#### The run and the simulation

**[`Run`](#g-run) is what one run owns** ([D-255][d-255], [D-260][d-260], [D-317][d-317]). It is a mutable struct of
six fields. Two are `const` and last the run's whole life. One is the [log](#g-log) (the
retained sequence of published snapshots). The other is the [trace](#g-trace) (the records
of each frame's drained inputs), which is `nothing` under `trace = false`. The
door that builds the run takes the four recording keywords, `trace`, `log`,
`log_every` and `log_max` ([Appendix B][sB], [D-261][d-261]). A run's recording is therefore
that door's declaration, and the next door may declare otherwise ([D-261][d-261]).

Four fields evolve during the run. `feed` is described above. `termination` is
the record the loop's tail writes. `frame` and `boundary` are the trajectory's
counters, the frame index and the boundary ordinal. `init!`, `restore!` and
`replay!` construct a run, and nothing else rebinds it. `live!` ([§12.7][s12-7]) and the
halt at a recording's end write `feed`. The loop's tail writes `termination`
once, and `closed(run)` is `termination !== nothing`. Each door sets the two
counters as it builds the run, `init!` to zero and `restore!` and `replay!` to
those of the [checkpoint](#g-checkpoint) (the `Model`'s state at a frame top, beside the run's
frame index and boundary ordinal), and the loop advances them ([D-317][d-317]).
`restore!` of a bare state sets the frame index to the state's frame and the
boundary ordinal to zero, as `init!` does ([D-319][d-319]).

The origin `t₀` is not a run field ([D-260][d-260]). The clock of the [executor](#g-executor) (the
compiled form of the stage execution order) holds it beside `t`. `init!` sets it
on the clock before [boundary zero](#g-boundary-zero), the initialization boundary run as the
ordinary macro-sequence with an empty integrate ([§14.5][s14-5]). A checkpoint carries it
with the clock ([§11.5][s11-5], [D-273][d-273]). It is a `Float64`, as `h` and `t_end` are
([D-260][d-260]).

**A `Simulation` is constructed with a placeholder run** ([D-255][d-255]). The
placeholder is an empty log, no trace, no feed and no termination, and
`init!`, `restore!` and `replay!` replace it ([D-255][d-255]). The field is
always a `Run` and never `nothing`, so every accessor has a run to read, and
the lifecycle state below says whether that run ever started. The placeholder
carries no configuration and no compiled state ([D-261][d-261]). `init!`
allocates fresh objects rather than clearing them ([D-255][d-255]).

**`Simulation` is a mutable struct of four fields**, the [`Model`](#g-model) (the deployment
and its executor at one scalar), the run, the data plane ([§11][s11]) and the control
plane ([D-317][d-317]). The [control plane](#g-control-plane) is the atomic surface carrying pause, pace and
stop. The `Model` holds the [deployment](#g-deployment), the executor, its status and its
[diagnostic cell](#g-diagnostic-cell). The deployment is the scalar-free artifact the grid parameters
fix, carrying the build. A diagnostic cell is a writer's own holding place for
runtime diagnostics. A simulation owns its `Model`, claimed at construction and
never shared ([§9.2][s9-2], [D-318][d-318]).

Every other value belongs to one of the four ([D-256][d-256]). The build is reached
through the deployment, never held twice. The grid parameters, the [schedule](#g-schedule) (the
typed per-component `(D, Φ, Δt)` tick table) and the event parameters are the
deployment's ([§9.2][s9-2]). `chunk_size`, the stepper and the arrival buffers are the
executor's. `join_timeout` is `Control`'s ([§12.1][s12-1]). The loop's diagnostic cell,
its account and the published-snapshot holder ([§11.2][s11-2]) are the data plane's, and
the frame's own diagnostic cell is the `Model`'s ([§11.8][s11-8]). The log, the trace and
the two counters are the run's. The stop policy, with its `t_end` and ignored
requesters, is the advance's argument, and the [termination record](#g-termination-record) (the
stopped-sim value naming how the run ended) keeps the terminating one ([D-260][d-260]).
The pacer's schedule and counters are `run!`'s own, created per call and passed
to the loop and its publications as the policy is. The status of each [snapshot](#g-snapshot)
(the immutable per-boundary publication) carries the pacer's frozen record
([§10.7][s10-7], [D-269][d-269]).

**A struct holds what it owns or what it must retain across calls**
([D-261][d-261]). A callee takes what it reads as an argument, never off a
field added to the container it already holds. **An object is built after its
inputs exist**, and the placeholder run above is the one exception
([D-261][d-261]).

#### Lifecycle states and the input mode

**A `Simulation` moves through five states**, *built*, *initialized*, *running*,
and terminally *stopped* or *errored* ([§13.4][s13-4], [D-088][d-088]). *Built* means [stores](#g-store) (the
framework-owned homes of a component's state) allocated and boundary zero not
completed ([D-223][d-223]). It is the cold state, and the state a throw inside boundary
zero returns the simulation to ([§13.4][s13-4]). *Initialized* means `init!` has
completed boundary zero ([§14.5][s14-5]), or `restore!` or `replay!` has restored a
checkpoint.

**`lifecycle(sim)` derives the state rather than storing it** ([D-317][d-317]).
It reads three facts, the control plane's running flag, the `Model`'s status
and whether the run is closed. The status is `:built`, `:consistent` or
`:inconsistent`, and only the `Model`'s own entry points and catch sites write
it. A claimed model's status is written only through its simulation's entry
points, since the model's entry points refuse a direct call on a claimed model
([D-318][d-318]).

| running flag | `Model` status | run closed | state |
|---|---|---|---|
| set | any | any | running |
| clear | `:built` | any | built |
| clear | `:inconsistent` | any | errored |
| clear | `:consistent` | no | initialized |
| clear | `:consistent` | yes | stopped |

**`errored` is terminal** ([D-059][d-059]). Reproduction is trace
[replay](#g-replay), not resurrection ([§12.7][s12-7]). Replay is the ordinary
loop re-driven from the trace.

Beside the state, the run carries an input mode, `:live` or `:replay`, read as
`mode(sim)`. **The mode is read off the run's `feed`**, `:replay` while a
recording is attached and `:live` otherwise ([D-260][d-260]). The mode names where the
next frame's [drain](#g-drain) takes its [batches](#g-batch) from, the [staging cells](#g-staging-cell) (where each
device's pending batch waits between drains) or the attached recording ([§12.7][s12-7],
[D-218][d-218]). The drain is the frame-top swap that publishes staged device writes into
the root inputs, and a batch is a device's staged set of writes. State and mode
are orthogonal. The state says whether the simulation may advance, and the mode
says what it will advance on.

**`init!` is mandatory** ([D-088][d-088]). `run!` or `step!` on a simulation
whose boundary zero has not completed is `MissingInit`, an error in the kind
set ([§13.2][s13-2]) naming `init!`. That is distinct from
`UninitializedInputs`, which fires *inside* `init!` ([§14.6][s14-6]).
`restore!` and `replay!` are the two alternative doors. Each restores a
checkpoint and runs no boundary zero ([§12.7][s12-7], [D-274][d-274]). A throw
inside boundary zero, which only `init!` runs, leaves the simulation `built`
([§13.4][s13-4], [D-223][d-223]), so the next `run!` or `step!` meets the same
refusal.

#### Partial advance

Deviceless, `run!` is fully synchronous. [§11.1][s11-1] says where the loop and the
device tasks run, and defines the [unattended run](#g-unattended-run) (a run with empty staging and
no snapshot readers).

`step!(sim; frames = 1)` advances whole frames synchronously through the
ordinary frame sequence (drain, integrate, boundaries, publication) and
returns ([D-088][d-088]). A stepped simulation is bit-identical to the same
frames under `run!` ([§2.4][s2-4]), and it never waits on the pacer, whatever
pace the control plane holds ([D-269][d-269]). `step!(sim; t_plus = 10.0)` is
the duration spelling. It is mutually exclusive with `frames`, and passing
both is `ArgumentInvalid`. It advances whole frames until the boundary time
first covers the duration, which is the migration suite's advance-by-duration
idiom.

Partial advance is the test-harness mode of advance, assert, advance. It is
equally the REPL mode of fly a while, inspect, continue. Neither is a script,
so the scenario-component doctrine does not absorb them ([§12.5][s12-5]).

**A stepping session is deviceless by construction** ([D-093][d-093]). Device
tasks are per-`run!` artifacts ([§11.1][s11-1]), and a device loop's
`while running(handle)` is false outside a run. Between `step!` calls the
simulation is in a stopped-sim state, `initialized` (below), so `attach!` is
legal there and does what it always does. It registers ([§11.3][s11-3]), and
the task appears at the next `run!`.

The frame-top drain still runs, so `step!` frames stay bit-identical to `run!`
frames. In a stepping session the staging cell written is the [harness cell](#g-harness-cell) (the
always-present staging cell of the [harness writer](#g-harness-writer)). The harness write path is
`stage!(sim, "face" => value, …)`, and [§11.3][s11-3] specifies the writer. Staged
batches are ordinary batches. They are traced, so replay and bit-identity hold,
and they are applied at the next frame top.

The read half is `latest(sim)`. It hands back the same immutable snapshot
value a device handle acquires ([§11.2][s11-2]), navigated directly for
assertions. Advance-assert-advance is `stage!` → `step!` → `latest`
([D-096][d-096]). Both entry points work under `run!` too. The harness cell is
not step-scoped. An inspection accessor leaves the rejection of closure-based
termination untouched ([§13.5][s13-5], [D-096][d-096]).

#### Status, termination and `run!` after `step!`

Between `step!` calls a simulation reports `initialized` ([D-088][d-088]). No
loop task exists, so `running` would lie. Nothing is terminal, so `stopped`
would lie too. The state reads "boundary-consistent and ready to advance", not
"sitting at boundary zero". `run!` may therefore follow `step!`, continuing
from the current boundary, and so may another `step!`.

The stop policy is honoured throughout, as bit-identity requires. `t_end`
reached, or a [stop request](#g-stop-request) (an output port of the framework enum `StopFlag`)
[holding](#g-edge-semantics) (publishing `STOP_REQUESTED`) at frame 3 of `step!(sim; frames = 10)`,
ends the run there through the ordinary [§12.4][s12-4] tail and leaves the simulation
`stopped`. `step!` therefore returns the number of frames *actually advanced*.
That is the requested count in the ordinary case, and fewer when the run
terminated inside the call. That return is how a harness detects the truncation
without inspecting the clock.

#### Re-running and checkpoints

**`stopped → init! → run!` remains the authored re-run** ([D-088][d-088]).
`init!` re-runs boundary zero from its [condition](#g-condition) (a
path-addressed overlay that sets the build to a state). The warm restart is
`checkpoint` → `restore!` → `run!` ([§12.7][s12-7], [D-274][d-274]).
`restore!` is a door like `init!`, and it runs no boundary zero. Each builds a
fresh run, so the trace, the log and the termination record ([§13.5][s13-5])
are new objects rather than cleared ones, and each clears any batches still in
staging cells. The [recorders](#g-recorders) (the trace and the log jointly)
restart with the run they record, and no stale batch survives to clobber the
frame it predates.

`init!` and `restore!` also return the input mode to `:live`, and a fresh
`replay!` sets the mode exactly as it sets the trajectory. `live!` is the one
call that moves the mode alone. It takes a replaying simulation live where it
stands ([§12.7][s12-7]). A terminal state makes the mode moot. From `stopped`,
nothing advances until `init!`, `restore!` or `replay!` opens a new run, and
`errored` is terminal ([D-218][d-218], [D-219][d-219]).

`checkpoint` and `restore!` exist on the `Model` and on the `Simulation`, and
**a `Checkpoint` is the `Model`'s state beside the run's cursor**
([D-319][d-319]). `checkpoint(model)` returns the state alone, a
`ModelState`. It holds the flat buffer, the `s` and `m` stores, the whole
signal table, the guard priors, `t`, `t₀`, the fingerprint (the structural
layout) and the deployment. It is legal at `:consistent` with the clock on a
grid top. `checkpoint(sim)` wraps that state with the run's frame index and
boundary ordinal ([D-319][d-319]). It is a stopped-sim service, legal in
`initialized` and `stopped` ([§14][s14]), and refused as `ServiceLifecycle` in
any other state. It is refused wherever the executor is not at the rest a
published frame top leaves (`CheckpointMidFrame`, [Appendix C][sC]). That is
after a `t*` stop, which leaves the clock mid-frame with the remainder
abandoned, and after a frame abandoned unpublished ([§12.4][s12-4]). The test
is that the clock sits on a grid time and that the latest snapshot is of that
very boundary.

`restore!(model, model_state)` checks the state's fingerprint and deployment
against the model, and a mismatch is `CheckpointMismatch`. It also checks that
the state's `t` is a grid time `t₀ + k·h` of the state's own origin and step,
and a state off its grid is `CheckpointMidFrame`. Every mismatch of either kind
is collected into one throw before any write. The entry point then copies the
state back, settles the restored boundary through the hooks and writes
`:consistent` last ([D-318][d-318], [D-319][d-319]).

`restore!(sim, cp)` takes the four recording keywords `init!` takes. It checks
the state's fingerprint and deployment against the simulation as replay checks
the [trace header](#g-trace-header) (the trace's fixed preamble), and a
mismatch is `CheckpointMismatch` ([§12.7][s12-7]). It checks the state's `t`
against its grid as the model's entry point does, collecting both kinds into
one throw. It then copies the state back, opens a fresh run with the
checkpoint as its trace header, and publishes one snapshot at the
checkpoint's `t`. It runs no [sweep](#g-sweep) (one pass through the execution order against
the current state), evaluates no guard, runs no update and
resets no prior. The next frame is the original lattice's next frame, because
the clock came with the checkpoint. The boundary ordinal continues, being the
trajectory's ([§12.3][s12-3], [D-274][d-274]). The snapshot `restore!`
publishes is a re-publication. It carries the ordinal of the boundary the
checkpoint was taken at, and the next frame publishes under the next ordinal,
as it did in the original run.

`restore!(sim, model_state)` is the door a state prepared on a standalone
model takes into a simulation ([§9.2][s9-2], [D-319][d-319]). It takes the
same keywords and makes the same check of the state's fingerprint and
deployment, and it refuses a state whose `t` is off the grid as
`CheckpointMidFrame`. It opens a fresh trajectory at the state's frame, and
the restored boundary publishes under ordinal 0, as boundary zero's does. A
standalone model published nothing, so the trajectory has no ordinals to
continue. A `Checkpoint` holds a `ModelState{Float64}`, so it is nominal by
type. A state taken at another scalar is refused by dispatch with the same
`CheckpointMismatch`, on either `restore!` that takes a bare state.

#### Device attachments across runs

**Device attachments persist across re-initialization** ([D-088][d-088]), because
attachment is orthogonal to the run lifecycle ([§11.3][s11-3]). Persistence means
*roster* persistence, the [roster](#g-roster) being the list of attached device entries.
Binding, [claims](#g-claim) (the set of faces a device may write) and device id survive.
Tasks and OS resources do not, the per-run topology being specified in [§11.1][s11-1] and
the teardown in [§12.4][s12-4]. Each `run!` re-initializes every rostered device and
spawns a task for each whose `init!` succeeds ([§11.1][s11-1], [D-093][d-093]). `attach!` while
stopped only registers, and the task appears at the next `run!`.

Which devices get a task at each `run!` is decided as [§11.1][s11-1]
specifies. **A front end attached by hand is still rostered**
([D-310][d-310]), so the next `run!` spawns its task again.

#### The stop policy per advance

**The stop policy is declared per advance** ([D-255][d-255], [D-316][d-316]). `t_end` and
`ignore_stop_requests` are keywords of `run!`, `replay!` and `step!`. Each call
builds and validates the [`StopPolicy`](#g-stop-policy) (the immutable value of `t_end` plus the
ignored requester paths) it passes to the loop ([§13.5][s13-5], [D-255][d-255], [D-316][d-316]). The value
lives as long as the call, and afterwards only on the termination record of the
advance that ended the run ([D-260][d-260]). A second run, or a `step!` sequence between
two runs, can therefore stop on a different clock or honour a different set of
stop requests without a rebuild.


### 12.7 Replay: the trace re-drives the ordinary loop

This section specifies [replay](#g-replay), re-running the ordinary loop on a recorded input
[trace](#g-trace), so that a recorded session can be inspected, its errors reproduced and
its run continued live. A trace is the primary record of a session, a fixed
[trace header](#g-trace-header) plus the [batches](#g-batch) drained at each [frame](#g-frame). A batch is a [device](#g-device)'s
staged set of writes, and a device is any attached participant in the periphery.
A frame is one iteration of the loop, from drain to publication. The [drain](#g-drain) is
the frame-top swap that applies staged device writes to the [root inputs](#g-root-input). The
root inputs are the root component's own inputs, the only thing the periphery
may write. `replay!` is the entry point the trace exists for ([§11.5][s11-5]):

```julia
trc  = trace(sim)                     # the recorded session: header + per-frame batches
sim2 = Simulation(world)              # the same build
replay!(sim2, trc)                    # restore the header, then re-drive every recorded frame
replay!(sim2, trc; to_boundary = k)   # partial: the §13.4 replay-pointer idiom
replay!(sim2, trc; to_time = 100.0)   # partial: the same halt addressed by time
cp   = checkpoint(sim)                # the state at a frame-top rest
restore!(sim2, cp)                    # that state alone: a warm restart, no feed
```

The parts below cover the one substitution replay makes, halting and the
[input mode](#g-input-mode) (where the drain takes its batches from) across
halts, what stays the loop's, and the validation up front. They then cover the
[what-if replay](#g-what-if-replay), re-driving the recorded inputs through a
modified model, with the `restore = false` form, which attaches the feed to
the simulation as it stands. The rejected shapes close the section.

#### One substitution

**`replay!` is the ordinary loop with exactly one substitution**, not a second
loop ([D-101][d-101], [D-274][d-274]). That is what keeps every property proved of the loop true
of replay. The substitution is the drain, which reads the trace. Under the
default form, `replay!(sim2, trc)` above, the loop also starts from a restored
state.

The default form restores from the header. It restores the trace's [checkpoint](#g-checkpoint)
(the `Model`'s state at a frame top, beside the run's frame index and boundary
ordinal), the state the recording opened from. It runs no [boundary zero](#g-boundary-zero) (the
initialization boundary at `t₀`). This form stands in the `init!` position of
the lifecycle ([§12.6][s12-6]) and does what `restore!` does, with the trace header as
the checkpoint ([D-274][d-274]). There is no [condition](#g-condition) resolution, and the
[root-input totality](#g-root-input-totality) (every root input must hold a value) ([§14.6][s14-6]) held when the
recording's `init!` ran. A condition is the datum that says "set this build to
this state". Whatever fired at `t₀` is part of the restored state, so nothing is
applied twice and nothing is skipped ([D-274][d-274]).

The drain reads the trace. Each frame top applies the recording's batches for
that [frame ordinal](#g-frame-ordinal), the frame index a batch replays at ([D-101][d-101]). It does not swap
the [staging cells](#g-staging-cell) of the [roster](#g-roster) (the list of attached device entries). A staging
cell is where a device's pending write batch waits between drains. Ordinal
keying is exact because the frame sequence is itself deterministic under replay
(`t*` boundaries derive from state, [§10.4][s10-4]). Frame *k* of the replay *is* frame
*k* of the recording. Recorded batches apply verbatim, with no surface re-check
([D-101][d-101]). The [write-surface](#g-write-surface) rule (the bound on the [faces](#g-face) a writer's batch entries
may reach) ([§11.3][s11-3]) ran at recording time, and [claims](#g-claim) (the set of faces a device
may write) are a live-roster fact of the recorded session that replay does not
reconstruct. A face is the name a port wears on its component's boundary.

A simulation is in one of two input modes, `:live` or `:replay`, and **the mode
decides which source that one drain branch reads** ([D-218][d-218]). Under `:live` it
reads the staging cells, and under `:replay` the attached recording. **`replay!`
attaches the recording and enters `:replay`** ([D-218][d-218]). `step!` and `run!`
consume it from there, frame by frame, exactly as the drain paragraph above
describes. There is still one loop and one drain ([D-218][d-218]).

A mode that outlives the call makes a partial replay a resumable position rather
than the end of an operation ([D-218][d-218]). Whatever advances the simulation next
reads the same mode and finds the same records. That is what lets the
reproduction workflow of [§13.4][s13-4] run through the ordinary entry points, with no
replay-only spelling of `step!`.

#### Halting, and the mode across halts

**In `:replay` the recording is the bound** ([D-218][d-218]). Every advance's frame
budget is capped at the recording's last frame, and `to_boundary = k` caps it
earlier. That keyword is the consumer of the replay pointer ([§13.4][s13-4]). `to_time`
is the same cap addressed by time (below). Either keyword names a frame from the
one the feed starts from through the recording's last, and anything else is
refused (`ArgumentInvalid`). The feed starts from the header's frame under the
default form, and from the simulation's own under `restore = false` (below).

`to_boundary = k` takes the frame-entry boundary index ([§13.4][s13-4]), a count of frame
tops. It is not the published-boundary ordinal that a [snapshot](#g-snapshot) (the immutable
per-boundary publication) carries ([§12.3][s12-3]). **Replay runs through frame `k` and
halts exactly at the frame top after it** ([D-128][d-128]). Replay therefore always halts
at a frame top. A [localized](#g-localized) `t*` boundary (the crossing instant bracketed by
root-finding over trial sweeps) inside the frame is reproduced but not
stoppable-at ([D-128][d-128]). The trace stays frame-indexed, replay pointers and error
messages use the frame-entry boundary index, and snapshots carry the
published-boundary ordinal ([§10.4][s10-4], [§12.3][s12-3]).

Replay may also end earlier still under the ordinary policies, since `t_end` and
`ignore_stop_requests` are keywords of `replay!` exactly as of `run!` ([§12.6][s12-6],
[D-255][d-255], [D-316][d-316]). A termination the recorded session hit through a [stop request](#g-stop-request) (an
output port of the framework enum `StopFlag`) reproduces itself anyway,
deterministically ([D-127][d-127]). A replay honours requests by default too, and the
trace header records no policy. So a replay of a live run that ignored some must
pass the same `ignore_stop_requests`.

**`to_time` halts at the last frame top at or before the time given**, the same
halt addressed by time, and it is mutually exclusive with `to_boundary` ([D-219][d-219]).
It computes `k = ⌊(to_time − t₀)/h⌋` against the header's `t₀`, under either
form. A time falling between two frame tops floors onto the earlier one.

The rounding is the deliberate opposite of `t_end`'s, which ends a run at the
first grid boundary reaching or exceeding it ([§12.4][s12-4]). `t_end` bounds
a run, and `to_time` positions an inspection. The point of halting is to
stand *before* the anomaly, so a halt that stepped past it would defeat the
call ([D-219][d-219]).

`to_time` is validated as the other keywords are. The value must be real, finite
and at least `t₀`, and it must name a time the recording covers. The checks run
before the replay writes anything, the default form's restore included.

The halt flips the mode only at the recording's end. A frame budget that runs
out halts the loop at a frame top, leaving the simulation `initialized`
([§12.6][s12-6]). **The mode becomes `:live` exactly when that halt lands at
the recording's last frame**, with the records exhausted ([D-218][d-218]). It
stays `:replay` otherwise, and the next `step!` or `run!` goes on consuming
the recording. So no advance ever flips mid-run. A `run!` whose `t_end` lies
past the recording halts at the last recorded frame, now `:live`, and the
*next* call is the live continuation ([D-218][d-218]).

`live!` is the one call that moves the mode alone. The flip above is automatic.
`live!(sim)` performs it by hand. **`live!` sets the mode to `:live` and
detaches the recording's remainder, touching nothing else** ([D-219][d-219]). The
trajectory stands where the replay left it, and so does the trace with its
header, inherited under the default form. The next `run!` or `step!` is
therefore the live continuation from the replayed boundary, and its drains
append to the re-recorded prefix. `live!` is a stopped-sim operation, legal only
on an `initialized` simulation in `:replay`. Every other state refuses under the
ordinary lifecycle gates ([§12.6][s12-6]), with `MissingInit` at `built` and
`ServiceLifecycle` in the rest. A simulation already `:live` refuses too, with
`ArgumentInvalid`. The call would have nothing to do, and a loud refusal beats a
silent no-op ([D-219][d-219]).

That call is what makes the rewrite workflow real. An interactive session is
interrupted at t = 110, and the last ten seconds are to be flown again:

```julia
trc  = trace(sim)                     # the interrupted session, out to t = 110
sim2 = Simulation(world)
replay!(sim2, trc; to_time = 100.0)   # halt at the last frame top at or before 100
latest(sim2)                          # inspect the boundary landed on
live!(sim2)                           # drop the remainder; the mode is :live
run!(sim2; t_end = 130.0)             # live from t = 100, re-recording onward
```

The trace `sim2` leaves behind is a complete recording of *itself*, the replayed
prefix out to t = 100 and then the frames flown live after it, since replay
re-records (below).

A replay's halt leaves the simulation `initialized`, never `stopped` ([D-218][d-218]).
That state is boundary-consistent and ready to advance, the same state `step!`
leaves ([§12.6][s12-6]). This is what makes three promised workflows real ([D-101][d-101]).
State-trajectory inspection asks "what was the private state at t = 37.2?", and
answers it by replaying there and reading the live stores ([§11.2][s11-2]). Error
reproduction replays to the frame-entry boundary `k` the error names, then
`step!`s the failing frame on its recorded inputs, under instrumentation
([§13.4][s13-4]). Continuation is `run!` after `replay!`, a live session from the
replayed boundary. After a full replay that is the next call, the records
exhausted at the halt. After a partial one the remainder of the recording is
consumed first, across as many `step!` and `run!` calls as the caller makes, and
the session goes live at the recording's end. Or `live!` drops that remainder,
and the continuation starts at the halt.

#### What stays the loop's

**Replay re-records** ([D-101][d-101]). The drain records normally. Under the
default form the new trace inherits the old header and accumulates the
re-drained batches, a bit-identical prefix. Under `restore = false` the new
trace's header is the simulation's own checkpoint (below). A
replayed-then-continued session therefore leaves behind a complete, valid
trace of *itself*, with no special stitching.

**[Pacing](#g-pacing) and the [control plane](#g-control-plane) are unchanged** ([§10.7][s10-7], [§12.1][s12-1], [D-101][d-101]). The
control plane is the separate atomic surface carrying pause, pace and stop.
Pacing (waits inserted between completed frames, never altering the boundary
sequence) sits outside the semantics, so paused, slow-motion or real-time replay
is free. Paced replay with an attached visualizer *is* session playback, and
`replay!` takes `pace` and `margin` as `run!` does ([§12.1][s12-1], [D-269][d-269]). Stop
truncates, as anywhere.

Devices are readers ([D-218][d-218]). Rostered devices init and spawn normally
([§11.1][s11-1]) and consume snapshots ([§11.2][s11-2], [§12.3][s12-3]). That
is the visualizer case. But no live staging cell is drained while the
simulation is in `:replay`. A batch found staged is discarded with a
rate-limited warning (`ReplayDiscardedStaging`, [Appendix C][sC]). Mixing live
writes into a replay would destroy the property replay exists to provide. A
session that wants live input is a continuation (`run!` after replay), not a
replay.

#### Validation up front

**Validation is loud and up front** ([D-101][d-101]). Before the first frame, the
checkpoint's [deployment](#g-deployment) (the scalar-free artifact the grid parameters fix) is
compared against the target's. Its fingerprint, the structural layout, is
compared against the `Build`. The fingerprint covers the store layout, the
root-input faces, and what a copy by position relies on ([§11.5][s11-5]). The trace's
batch entries are validated against the root input-face list, and each batch's
frame ordinal against the recording's frames, from the one after the header's to
the last ([D-217][d-217]). Each writer's face-name → position schema, on the trace's
`schemas` list ([§11.5][s11-5]), is validated in the same pass. A recorded schema that
disagrees with the target model's own root-input faces is a replay error. The
checks are attach-style, and a failure reports [did-you-mean](#g-did-you-mean), the offending name
plus the list-in-hand it should have matched. The kinds are
`CheckpointMismatch`, `ReplaySchemaMismatch` and `ReplayUnknownFace`
([Appendix C][sC]). The pass runs under both forms of `replay!`.

The same pass pays the trace-record conversion in reverse. Every writer's
sparse records ([§11.5][s11-5]) are normalized to positional batches against
the trace's `schemas` list, once, off the loop ([D-101][d-101],
[D-176][d-176]). Replay has the whole trace in hand before frame 1. The replay
drain therefore applies compiled scatters exactly as the live drain does, and
no face name is resolved per frame under replay either.

*Structural* mismatch is an error. *Parametric* difference is not
([D-101][d-101]).

**The checkpoint check compares two deployments as values** ([D-254][d-254]).
The checkpoint carries the recorded run's `Deployment`, the target
simulation's `Model` carries its own, and the check is their comparison, on
the *structural* side of that line. The value covers the
trajectory-determining parameters, `Δt_base`, `h`, `N_base`, the algorithm,
`localization_tol`, `localization_budget` ([§10.4][s10-4]) and
`firing_budget` ([§10.6][s10-6], [D-133][d-133]). It also covers the
[schedule](#g-schedule) (the typed per-component `(D, Φ, Δt)` tick table) with
every column, the anchor and rate-chain columns included. A rate re-declared
through a different anchor at the same tick table is therefore a different
deployment, and the replay is refused. The refusal costs one re-recording in
a rare case, and it keeps the equality a plain value equality rather than one
that ignores two of a row's columns. Mismatch is `CheckpointMismatch` with a
deployment-parameter discriminator, never a what-if ([D-127][d-127]). A
deployment change moves the times at which the frame-ordinal batches apply.
That is different inputs, not a modified model. The event trio (the
localization pair and `firing_budget`) is compared for exactly the same reason
the grid parameters are. It moves the trajectory, so a run that differs in it
is not re-driving the recorded one. Comparison by value is what makes the
check one expression rather than a field-by-field walk.

Under the default form the clock is *restored*, not compared. That form restores
`t₀` with the rest of the clock, so `replay!` takes no `t0` argument ([D-127][d-127]).
Under `restore = false` the simulation's own clock runs, and its origin must
equal the recording's. The checkpoint holds no policy ([D-255][d-255]). `t_end` and
`ignore_stop_requests` are keywords of this `replay!` call, validated per call
as at `run!`.

The dispositions, by trace content:

| trace content | disposition |
|---|---|
| the checkpoint's fingerprint: store layout, root-input faces, and what a copy by position relies on | compared against the `Build` |
| the recorded `Deployment`, carrying `Δt_base`, `h`, `N_base`, the algorithm, `localization_tol`, `localization_budget`, `firing_budget` | compared as a value against the deployment the target simulation's `Model` carries |
| each writer's face-name → position schema (on the trace's `schemas` list) | validated against the target model's root-input faces: disagreement is a replay error |
| the checkpoint's state | restored under the default form; no boundary zero |
| the clock | restored under the default form, `replay!` takes no `t0`; under `restore = false` the simulation's own clock runs, its origin equal to the recording's |
| `t_end`, `ignore_stop_requests` | absent from the checkpoint; each `replay!` call declares its own ([§13.5][s13-5]) |

#### What-if replay and `restore = false`

Replaying against the same structure with changed parameters is the what-if
replay. It is spelled as `init!` of the modified model under the authored
condition, then `replay!(sim, trc; restore = false)`. The trace is not
self-sufficient for it. Its checkpoint holds the recording model's state after
boundary zero, so the authored condition comes from outside ([D-274][d-274]).
Bit-identity is promised only against the identical build ([§2.4][s2-4]). What-if replay
promises determinism, never reproduction.

`replay!(sim, trc; restore = false)` attaches the feed to the simulation as it
stands and restores nothing. The simulation must be `initialized`, at the
recording's `t₀`, and at a frame from the header's to one short of the
recording's last. A simulation that is not `initialized` meets the lifecycle
gate before any write, with `MissingInit` when it is `built` and
`ServiceLifecycle` in any other state. One whose origin or frame is off the
recording's is refused before any write as `CheckpointMismatch`, its clock arm.
One grid is thus an invariant of every replay, and `to_time` has one meaning.
The drain applies the records from the frame after the simulation's own.

This form is a door like the default one, an entry point that builds a run
([§12.6][s12-6]). It builds a fresh run under the recording keywords, takes
the simulation's own checkpoint as the new trace's header, and publishes one
snapshot. That form serves the what-if of a modified model initialized under
the authored condition (above). It also serves a seek, `restore!` of a
checkpoint the recording passed through followed by the feed from the next
frame ([D-274][d-274]).

#### Rejected shapes

Three shapes are rejected for the record ([D-101][d-101]). They are a
`run!(sim; replay = trc)` flag, a synthetic playback device staging the
recorded batches, and replay ending `stopped`. The input mode clarifies that
decision's drain substitution rather than replacing it, and carries its own
rejected shapes ([D-218][d-218]).

---


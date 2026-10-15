## 12. Runtime periphery: lifecycle and orchestration

Where [§11][s11] fixes how data crosses the loop boundary, this chapter covers the
machinery that drives the loop itself: the [control plane](#g-control-plane) and the scheduling
primitives, the shutdown protocol, and the run lifecycle from `init!` through
[replay](#g-replay).

### 12.1 Control plane

Pause, un-pause, pace changes, `margin` changes and stop are a few scalar
fields on a separate atomic surface. The loop consults them at frame top. A
change issued while a frame runs or waits is observed at the next frame top,
at most one frame budget `h/p` later ([D-269][d-269]). The pause block is the one wait
that wakes at once (below). `margin` ([§10.7][s10-7]) rides here for
the same reason `pace` does. It tunes the wait, never the arithmetic, so
retuning the coarse/spin split mid-run is safe by construction. The stop's
issuers are the operator's channels (GUI button, [device](#g-device) handle,
calling code) and, in an interactive session, Ctrl-C. An
[operator interrupt](#g-operator-interrupt) is caught at one of the loop's
unmask points and sets exactly this stop, with no separate entry point
involved ([§12.4][s12-4]).

**The stop word carries its issuer.** Each issuing site writes its identity
(the device's name, `:code`, or `:interrupt`) by compare-and-swap from empty,
and the first writer wins. The loop's frame-top read consults the word for
non-empty, so the recorded issuer is the request that actually initiated the
tail. It lands in the [termination record](#g-termination-record)'s
`ControlRequestedStop` ([§13.5][s13-5], [D-203][d-203]).

**`ControlRequestedStop` sits outside the stop policy** ([D-255][d-255]). The
policy is what the caller declares for one advance ([§13.5][s13-5]); the stop
word is what anyone can issue at any moment.

**Beside pause, pace and `margin`, `Control` keeps the stop word, the
running flag, the wait and the shutdown tail's `join_timeout`**
([§12.4][s12-4], [D-256][d-256], [D-317][d-317]). The lifecycle state is not
stored, and `lifecycle(sim)` derives it ([§12.6][s12-6]). A run's outcome is
not a control surface, so `termination` belongs to the [`Run`](#g-run) (the
state one run owns) ([§12.6][s12-6], [D-255][d-255]) and not here. The control
plane is what anyone may poke.

**Control is not staging, structurally.** Staged writes apply at
[drains](#g-drain), and a paused loop drains nothing, so un-pause via staging
would deadlock by construction. Riding outside the drain/[trace](#g-trace)
path is safe for determinism precisely because [§10.7][s10-7] put
[pacing](#g-pacing) outside the semantics. Control changes *when* frames
execute, never what they compute, and stop merely truncates the trajectory.
While paused the loop blocks on a condition (notified on un-pause and stop),
not a spin.

**The pause is two verbs on the simulation** ([D-268][d-268]). `pause!(sim)`
sets the pause flag and `resume!(sim)` clears it, from any task and in any
lifecycle state; `paused(sim)` reads it. The loop consults the flag at frame
top, so a `pause!` issued before `run!` starts the run paused at its first
frame top. A stop issued while paused wakes the loop, which observes the stop
word and enters the tail with no further frame ([§12.4][s12-4]). `step!`
shares the frame top and blocks the same way, until `resume!` or a stop from
another task.

**Rule.** The tail clears the pause flag beside the sticky stopped status.
The flag is never cleared at a run's start.

**Why.** The stop word is cleared at the top of each run because a stop
belongs to the run it ended. A pause left set by a run that stopped while
paused would instead hold the next run at its first frame top, on a flag
nobody remembers setting. Clearing it in the tail removes that trap and keeps
the start-paused spelling above.

The handle carries no pause ([§11.6][s11-6]). Whether it gains the control
verbs for the bridge is pending (`pending.md`, [D-310][d-310]).

**Pace and `margin` are two more verbs and two readers** ([D-269][d-269]).
`pace!(sim, p)` and `margin!(sim, m)` set them from any task in any
lifecycle state, and `pace(sim)` and `margin(sim)` read them. `run!` and
`replay!` take both as keywords and write them at entry, the advance's
declaration as `t_end` is, `Inf` and 2 ms by default ([Appendix B][sB]).
`step!` takes neither and never waits. A stepping session is the harness
mode ([§12.6][s12-6]), and its frames are bit-identical to `run!`'s by
[§10.7][s10-7]'s invariant. `pace` is a positive real, `Inf` admitted, and
`margin` a non-negative real, `Inf` admitted. Each of the four calls refuses
anything else under `ArgumentInvalid` ([Appendix C][sC]).

### 12.2 Loop scheduling: wait primitive, yields, thread budget

[§10.7][s10-7] fixed the shape of the pacer's wait, hybrid sleep-then-spin,
and leaves the choice of the coarse phase's primitive to this section. That
choice is a scheduling decision rather than an arithmetic one. It settles
what else can run while a frame waits. It is made here, together with the two
questions that trail it: whether a frame is guaranteed to yield at all, and
how many threads a session needs.

**Rule.** The coarse phase uses task-yielding `sleep`. There is no
`systemsleep` variant ([D-027][d-027]).

**Why.** What the choice buys is the wait slot. `sleep` releases the loop's
thread, which makes the pacer's wait the natural scheduling window for
co-resident [device](#g-device) tasks. The design already spends that slot
twice, as the staging slot ([§10.7][s10-7]) and as the [drain](#g-drain)
source ([§11.4][s11-4]).

A `systemsleep` variant for dedicated-thread hard-RT deployments is a
[guarded addition](#g-guarded-addition) (a capability the design admits but
does not build).

**Rule.** With devices attached, every frame yields at least once.

**Why.** The rule is semantically free. [Pacing](#g-pacing), and hence
yielding, is outside the semantics ([§10.7][s10-7]).

The yield is implicit in the coarse-phase `sleep` whenever that phase runs.
An explicit `yield()` covers the frames where it does not run: unpaced runs,
and pure-spin frames with budget ≤ margin. The spin phase itself never
yields. Yielding there would trade its µs precision for scheduler noise.

The consequence is a bound on thread occupancy. The loop holds a thread for
at most one frame before the scheduler can run anyone else. Julia's
cooperative-scheduler freeze requires a thread monopolist, a never-yielding
task that holds its thread forever, and that precondition is structurally
absent from framework tasks.

**Rule.** The thread budget is a documented sizing rule and a startup
warning, not a hard error ([D-027][d-027]).

The freeze FlightCore's `nthreads` error prevented cannot reproduce here, for
two reasons. The loop yields every frame. Nothing couples a stall to anyone
else, the GUI least of all. It waits on nothing, ever. It uses a
[snapshot](#g-snapshot) acquire-load, its own
[staging cell](#g-staging-cell) and atomic control. Under any starvation,
then, the front end keeps rendering and the stop button keeps working.
Undersized sessions degrade to laggy inputs and stale snapshots, which are
visible, recoverable states.

A run warns, at `run!` or `replay!`, when `Threads.nthreads()` is tight for
the attached population, naming the `julia -t` remedy. That is one check per
run, against the frozen [roster](#g-roster) ([§11.3][s11-3]). Tight means
fewer threads than the roster plus one. Every rostered device is a task, and
the calling task hosts the loop, so a run occupies one task more than its
roster. The sizing guidance behind the remedy is one thread for the loop and
headroom for compute-heavy or blocking-ccall devices. libuv-backed I/O yields. Raw
blocking ccalls pin their thread for the duration. There is no pinning and
there are no sticky tasks.

**Liveness heartbeat.** Since starvation is survivable, it must be
diagnosable. The record is the published
[framework status](#g-framework-status), the frozen diagnostics value each
snapshot carries beside the table. It includes per-device liveness (the
liveness timestamp and the device's `task_state`) next to the pacer
diagnostics. The mechanism is the per-writer [cell](#g-diagnostic-cell),
specified in full by [§11.8][s11-8], plus the device `Task` handles the loop
already owns, and nothing besides. The cell carries the single liveness
timestamp. The loop reads `task_state` off those handles where it publishes
([D-193][d-193]). A starved, blocked or crashed device task shows in the GUI
as a stale heartbeat with a name on it, not as mysteriously frozen physics.

**Rule.** `task_state` has three values. Outside a run every device reads
`:none`. Inside a run a device reads `:running` while its task lives and
`:done` once that task has ended, whether the body returned or the wrapper
caught its crash ([§11.6][s11-6]). A device whose `init!` threw, and so
spawned no task, reads `:done` as well. The record's crash count tells a
crash from a return. `orphaned` on a record is
exactly `:done` ([§11.7][s11-7], [D-270][d-270]).

**Stale means a liveness timestamp more than 2 s behind wall clock.** The
threshold is deliberately loose, because the heartbeat is advisory. It is a
liveness display and a record, never a kill trigger, never a
detach. It must also tolerate a device legitimately parked in a blocking
read between rare data.

### 12.3 The next-snapshot wait

Rate-matched output [devices](#g-device) (telemetry, disk streaming) act once
per [boundary](#g-boundary). What they need from the framework is a way to
learn that a boundary has happened without polling for it.

**Rule.** Two artifacts provide it: a monotonic
**[boundary counter](#g-boundary-counter)**, the loop's own, plus one
`Threads.Condition`.

The counter counts *published boundaries*, that is grid, `t*` and
[boundary zero](#g-boundary-zero) ([§10.1][s10-1], [§10.4][s10-4]), not frames. Consecutive
wakes are therefore not necessarily `h` apart.

The loop's publication is `lock; counter += 1; notify; unlock`, nanoseconds
of framework-only code. Waiters never block it. One parked in `wait` has
released the lock as part of parking.

The device side is `wait_next_snapshot(handle)`, which blocks until
`counter > last_seen && running` under the canonical predicate-loop idiom.
That idiom handles waiters at different paces, frames skipped while
transmitting, and shutdown, all with no per-frame reset. Shutdown works
because [§12.4][s12-4] wakes all waiters and each predicate then routes its
owner out.

A `Base.Event` latch is the wrong primitive here ([D-028][d-028]).
Conditions carry no facts, only "look again". The facts that matter, the
counter and `running`, live in state each waiter tests privately.

**Two indices, and where each lives.** The [snapshot](#g-snapshot) carries
the trajectory's *published-boundary ordinal* with `t`. Boundary zero is 0,
and every publication after it, grid or `t*`, counts one. Any holder of a
snapshot therefore indexes it without consulting the loop, whether the log
or a post-run inspector. A new trajectory restarts the ordinal at zero, with
everything else `init!` resets. The boundary counter is a different number.
It is the loop's monotone count of every publication it has ever made, never
reset across trajectories, and its absolute value is nowhere normative. It
exists for the wait predicate alone, and it is never reset because a
waiter's `last_seen` must never run ahead of it ([D-230][d-230]). An error's
[replay](#g-replay) pointer is a third index, the frame-entry boundary index
of [§13.4][s13-4], a frame count that names no `t*` boundary.

**Rule.** The order of the two publications is normative. The release-store
of `latest` ([§11.2][s11-2]) happens **before** the counter increment under
the lock.

```julia
# the loop, at every published boundary
@atomic latest = snap    # 1. release-store: the snapshot becomes reachable (§11.2)
lock(cond) do            # 2. only then the counter, under the lock
    counter += 1
    notify(cond)         #    parked waiters wake and re-test their predicate
end
```

`counter > last_seen` therefore implies that `latest` holds at least that
boundary, and a waiter can never wake onto a stale snapshot. The converse,
observing a *newer* snapshot than the increment that woke you, is expected
and correct. Newest wins.

**Semantics: newest-wins, no queues.** A slow consumer skips frames and
always receives the current world. This mirrors the inbound side.
[Coalescing](#g-coalescing) to the newest batch (in) and to the newest
snapshot (out) are the same ZOH decision. No backpressure exists in either
direction, and the loop never waits on anyone. Per-consumer every-boundary
queues are rejected ([D-028][d-028]).

The GUI does not use the wait. Being VSync-paced, it reads `latest` at each
render.

### 12.4 Shutdown protocol

A run ends when its time is up, when someone stops it, or when the model
itself says so. Whatever the cause, the same work has to happen. The loop
has to stop on a [boundary](#g-boundary) rather than mid-frame, every device
task has to be woken out of whatever it was blocked on, and every resource
acquired for the run has to be released before `run!` returns. This section
specifies that sequence, which it calls the tail throughout. It also
specifies the two things that bracket the tail. One is the pre-spawn
initialization at the top of a run, which is a step of this same protocol.
The other is the operator interrupt, which enters the tail rather than
bypassing it.

#### The tail: the ordered sequence every stop takes

**Rule.** Steps (1) through (5) below run in that order on every stop,
whatever initiated it. Steps (6) and (7) specify what happens when a device
task or the loop itself ends first.

1. **Initiation.** Three events start a shutdown: `t_end` is reached, a
   control-plane stop is issued, or a [stop request](#g-stop-request) the
   advance honours reads `STOP_REQUESTED` in the just-published
   [snapshot](#g-snapshot). The stop's issuers are the
   GUI, a [device](#g-device) handle, code, or an
   [operator interrupt](#g-operator-interrupt) (Ctrl-C, treated below). The
   third event is model-detected termination ([§13.5][s13-5]). The loop
   always completes the current boundary sequence and never stops mid-frame.
   It then publishes the final snapshot. Only then does it set the sticky
   stopped status.
2. **Wake all framework waits.** The waits are the next-snapshot wait and
   the pause. Each waiter observes the stopped status and unwinds. A stop
   issued while paused therefore works.
3. **Unblock device-specific blocking calls.** The hook is
   `unblock!(device)`, default no-op. A network input's override closes its
   own socket, which raises in the blocked task. The framework wrapper
   catches that raise and treats it as shutdown. This demotes FlightCore's
   EOT convention from essential shutdown mechanism to an optional
   wire-protocol courtesy between remote peers.
4. **Loop bodies exit.** The exit is the author's own
   `while running(handle)` loop, the authoring contract of [§11.6][s11-6].
   That authoring contract teaches two obligations: the predicate check and
   interruptible blocking. Steps (2) and (3) are what make every blocking
   point interruptible. The wrapper's `finally shutdown!(device)` is
   guaranteed on every exit path.
5. **Join under the `join_timeout` cap.** The cap lives on `Control`, the
   tail's own owner ([§12.1][s12-1], [D-256][d-256]). It is a keyword of the
   `Simulation` constructor, a positive real in seconds of wall clock,
   defaulting to 5 ([Appendix B][sB]). A device task exceeding it is reported
   *by name*,
   through the [§12.2][s12-2] heartbeat. It is then abandoned with a
   `DeviceJoinTimeout` diagnostic ([Appendix C][sC]) rather than left to hang
   `run!`. The diagnostic is written to the loop's own cell, collected by the
   run's-end sweep into the [termination record](#g-termination-record) and
   presented through the logging backend, with the terminal snapshot
   preceding the join ([D-201][d-201], [D-203][d-203]).
6. **Device-initiated paths.** A device exits voluntarily when its loop body
   returns, at a window ✕ or a peer EOT. No `should_close` hook exists
   ([§11.6][s11-6]). With `should_abort` set, the wrapper's exit path also
   requests a sim stop. Otherwise the sim continues with the device's *task*
   absent. Its [cell](#g-staging-cell) stops filling, and the loop is
   structurally indifferent. Its [roster](#g-roster) entry and its
   [claims](#g-claim) persist to run end, because [§11.3][s11-3] freezes the
   roster for the run and death is not detach. The orphaned
   [root inputs](#g-root-input) hold their last-drained values, visibly
   ([§11.7][s11-7]). A crashing device task is caught by the framework
   wrapper and follows the same path, logged with the device's name
   (`DeviceCrash`, [Appendix C][sC]).
7. **Loop-side failure.** A failure on the loop's own side runs steps (1)
   through (5) from the catch path, specified in [§13.6][s13-6]. The failed
   boundary is discarded and the previous snapshot is promoted to final.
   FlightCore's `SimulationTermination` catch path was the precedent, though
   the exception-based termination idiom itself has no place here
   ([§13.5][s13-5]). Devices therefore unwind cleanly regardless of who died.

The ordered part, in one line:

> **(1)** stop observed → current boundary completed → final snapshot published
> → sticky `stopped` set → **(2)** framework waits woken → **(3)** `unblock!`
> per device → **(4)** loop bodies return, each through its wrapper's
> `finally shutdown!` → **(5)** join under the `join_timeout` cap → `run!`
> returns

**Why the final snapshot goes out before the status is set.** Publishing
first guarantees that output devices can flush the true final state. The
status in that terminal snapshot carries the run's cumulative diagnostic
counters ([§11.8][s11-8]), the warning account of a run nobody watched,
complete up to that snapshot's own frame top. What the tail itself produces
comes later by construction. It is folded into the termination record and
presented through the logging backend, never published ([D-201][d-201],
[D-203][d-203]).

**Rule.** That terminal snapshot is retained in the log unconditionally,
under any `log_every` and any `log_max` ([§11.2][s11-2]).

**`t_end` lands on the grid.** The run ends at the first grid boundary whose
time reaches or exceeds `t_end`. Whole frames only, never a shortened final
step, which grid integrity forbids ([§10.4][s10-4]; `tₖ = t₀ + k·h`, indexed
and never accumulated). The final boundary may therefore overshoot `t_end`
by up to `h`. The termination record carries the actual final `t`
([§13.5][s13-5]). This is the `t_plus` spelling ([§12.6][s12-6]) applied to
the run's own clock. The run takes whole frames until the boundary time
first covers the duration.

**The two termination sources differ in kind.** `t_end` is a grid fact,
checked against boundary times on the grid. Stop requests are checked at
*every* published boundary, `t*` included ([§13.5][s13-5]).

**Why the default is five seconds.** It is generous for GUI window teardown
and socket closes. It is short enough that an abandoned join reads as a
diagnosed timeout rather than a hang.

**The cap is deployment, not implementation.** That is the disposition
[§10.4][s10-4] gives its own two constants, extended here to an operational
one ([D-198][d-198]). Deployment contexts legitimately differ in patience. An
unattended sweep wants to fail fast, a test battery exercising the
abandonment path faster still, while a device with slow teardown may warrant
more. The cap is not trajectory-determining, because the trajectory has
ended at the final snapshot before any join begins. So, like `log_max`
([§11.2][s11-2]), it lives on `Control` rather than the deployment, and
replay neither records nor compares it ([§11.5][s11-5], [§12.7][s12-7]).

**What survives the tail.** After (5) the task set is empty, device tasks
being per-run artifacts ([§11.1][s11-1]), and `shutdown!` has released each
device's OS resources. What survives a stop is the roster entry: binding,
claims, stable device id ([§11.3][s11-3]). Never a task, never a live
resource. That holds for a device whose task died mid-run too, its entry
being indistinguishable at this point from any other's. `stopped` is where
`detach!` removes an entry and releases its claims.

**The next run re-acquires everything.** The next `run!` re-runs device
`init!`, since resource acquisition is per-run. FlightCore's
create-a-new-socket-each-`init!` in network.jl is the precedent. It also
spawns fresh tasks against the [§12.3][s12-3] counter, which is never
re-armed. Each task reads its `last_seen` off the counter at spawn. While
stopped there are no device tasks at all, so voluntary exit and the
[§12.2][s12-2] liveness heartbeat are run-scoped observables. A device
unplugged while stopped surfaces as the next run's `init!` failure, disposed
of by the initialization bracket below.

#### Initialization: the pre-spawn bracket

**Initialization is a step of this protocol, taken at the top of a run.**

**Rule.** Before any task is spawned, the loop calls `init!` once per roster
entry, in attachment order, on the calling task. Each call sits in its own
bracket.

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
            report!(entry, DeviceCrash(e))    # pre-spawn: the entry is the address, no handle yet
            entry.should_abort && stop!(control)
        end
                                          # no dead-marking: no task is spawned (§12.2)
    end
end
```

**Why the bracket.** It is what makes "guaranteed on every exit path"
([§11.6][s11-6]) true of the path outside that wrapper. A device that throws
half-way through acquisition is handed back to `shutdown!` right there, so
its partially acquired OS resources are released rather than leaked. That is
exactly why `shutdown!` owes tolerance of a partially initialized device, a
rule [§11.6][s11-6] teaches.

**The entry is listed for release before its `init!` begins** ([D-268][d-268]). The
bracket unlists it once its own `shutdown!` has returned. An operator
interrupt that escapes the bracket therefore finds listed every device whose
`init!` began and that the bracket has not released, and the run releases
each before it ends. A device listed and not yet initialized can be released
having opened nothing, which `shutdown!` tolerates ([§11.6][s11-6]).

**The report is the ordinary `DeviceCrash`, not a kind of its own**
([Appendix C][sC]). Its [payload](#g-payload) already carries everything an
init-time failure has to say: the device id, the cause exception, and
whether `should_abort` was set. The name is honest. A device that cannot
acquire its resources has crashed before it lived.

**Rule.** The report is written through the ordinary
`report!(address, diagnostic)` entry point, addressed by the roster entry
rather than by a handle.

There is no device task to hold a handle before the spawn. The address
supplies the device identity either way, which is why no call passes a
device id ([§11.8][s11-8]).

**Rule.** No task is spawned for a failed device, so it is dead from
[boundary zero](#g-boundary-zero) (the initialization boundary: the ordinary
macro-sequence with an empty integrate).

That needs no machinery. Its [diagnostic cell](#g-diagnostic-cell) (the
single-writer cell each writer owns for diagnostics and heartbeat) never
receives a heartbeat timestamp. The cell therefore reads stale against the
[§12.2][s12-2] threshold from the first frame ([§11.8][s11-8]).

**Rule.** The claims of a failed device persist to run end.

This is the death-is-not-detach disposition ([§11.3][s11-3]), applied one
step earlier than (6)'s. The roster is frozen for the run, and the orphaned
root inputs hold their initial values, well-defined by
[root-input totality](#g-root-input-totality) ([§14.6][s14-6]; every root
input must hold a value). An orphan of (6) holds a last drained batch
instead.

**The run's disposition splits on `should_abort`, uniformly with (6).** With
the flag clear, which is the default ([§11.6][s11-6]), the remaining entries
initialize, the run starts, and the sim runs with that device absent from
frame zero. That is (6)'s "the sim continues with the device's *task*
absent", shifted to `t₀`.

With the flag set, the failure requests a control-plane stop, and that stop
is simply *already pending* when the run reaches boundary zero. This
protocol already has that path. The boundary-zero check ([§13.5][s13-5])
ends a run at `t₀` with that snapshot final, integrating nothing. No new
exit protocol is needed, therefore. The remaining entries still initialize,
every rostered device getting its `init!`/`shutdown!` pair uniformly. The
run publishes boundary zero. It ends `stopped` at `t₀` through this same
tail, with the termination record naming the source ([§13.5][s13-5]). What
the operator is left with is an ordinary stopped simulation: a terminal
snapshot, with the failure named in its diagnostic account. It is fully
serviceable by [§14][s14] and resumable by the next `run!` ([§12.6][s12-6])
once the device is plugged back in.

**Topology is derived after initialization**, not from the roster alone
([§11.1][s11-1]). A device whose `init!` failed spawns no task. The run
proceeds without it, or ends at `t₀` when the device attached with
`should_abort = true`.

**Rule.** An `InterruptException` inside a device's `init!` is the operator's
stop, not that device's crash ([D-268][d-268]).

The bracket releases the device through `shutdown!` as for any throw and
spawns no task for it. In place of the `DeviceCrash` report it sets the
`:interrupt` stop through the stop word, so the run's `should_abort` split
above does not arise. The remaining entries still initialize, and the run
ends at its first frame top with zero frames advanced, through the
pending-stop path above. The device wrapper makes the same discrimination
for a raise inside a loop body ([§11.6][s11-6]).

#### The operator interrupt

**The operator interrupt is a stop, not a failure.** Ctrl-C in an
interactive session is a control-plane stop command issued by hand. The run
completes the current boundary, publishes the final snapshot, takes this
tail like any other stop, and ends `stopped`. The result is
boundary-consistent. It is fully serviceable by the [§14][s14] stopped-sim
services and resumable by the next `run!` ([§12.6][s12-6]).

The interrupt is the escape from a run nothing else can end. Such a run is
deviceless, and it declares no stop of its own. A run with no finite `t_end`
and no honoured stop request is the configuration `UnboundedRun` names
([Appendix C][sC]). The interrupt needs no entry point of its own. The stop
already rides on the [control plane](#g-control-plane), the separate atomic
surface carrying pause, pace and stop ([§12.1][s12-1]). The
exceptions-are-abnormal doctrine ([§13][s13]) is untouched. That doctrine is
about *model* code, while this is the one exception whose meaning the
framework knows.

**Rule.** Masking across the boundary is normative, not an implementation
hint.

**Why.** An `InterruptException` is delivered asynchronously. An interrupt
landing mid-[sweep](#g-sweep) would therefore destroy the boundary this
protocol is built on completing, and would leave half-written stores
([§13.6][s13-6]). That forces a choice between `stopped` with dirty stores
and a terminal `errored`. The `stopped`-with-consistent-stores guarantee is
exactly what the masking buys.

The loop masks delivery across the boundary macro-sequence, using Julia's
`disable_sigint`, a sigatomic counter increment that is negligible per
frame. It takes the deferred raise at the unmask points: the frame top,
where it already consults the control plane ([§12.1][s12-1]), and inside its
wait and pause blocks. All of those points are boundary-consistent. Caught
at one of them, the interrupt sets the control-plane stop and enters this
tail. The catch site ([§13.4][s13-4]) therefore never sees it.

**A deferred interrupt yields to the frame's own stop request** ([D-268][d-268]).
Stop requests are consulted at each publication and the stop word at the
next frame top ([§13.5][s13-5]), and the deferred raise lands between the
two. Where the frame's publication found an honoured request holding, that
request is the recorded source and the interrupt is satisfied by the run
ending. Where none
held, the interrupt sets the stop word and the source is
`ControlRequestedStop(:interrupt)`.

**A frame that throws with an interrupt pending ends `errored`**
([D-268][d-268]). The frame's own throw is the disposition ([§13.4][s13-4]).
The catch wraps the cause under the mask and consumes the pending interrupt
on its way out, and the run takes the abnormal entry under that `StepError`
([§13.6][s13-6]). The
alternative, `stopped` over a half-written boundary, is what the masking
exists to prevent. The interrupt is satisfied by the run ending.

**An interrupt after a frame's throw does not displace it** ([D-268][d-268]). `run!`,
`replay!` and `step!` store the loop's throw before an interrupt can displace
it, and the masked bookkeeping below builds the record from that store.
The run therefore ends `errored` under its `StepError` wherever a later
interrupt lands. An interrupt that cuts the handling of the throw itself
propagates out of the call raw, and the disposition of the failure is skipped
([§13.4][s13-4]). The record is still written and the lifecycle is still `errored`.

**Rule.** The tail's bookkeeping is masked too ([D-268][d-268]).

After the joins, the run's-end sweep, the termination record and the
terminal lifecycle state are written under the same mask. An interrupt
landing there would otherwise abort the sequence half-way and leave the
lifecycle `running`, every service refusing. A raise deferred to the end of
that bookkeeping propagates out of `run!` raw, the simulation already
terminal.

**A forced throw reaches the defensive arm** ([D-268][d-268]). Julia stops
deferring after repeated SIGINTs in a short window, warns that it is forcing
the throw, and raises inside the mask. That is the one way the branch
[§13.4][s13-4] keeps is reached. The arm abandons the frame unpublished and
the run ends `stopped`, the source `ControlRequestedStop(:interrupt)`. The
published record is consistent, since the frame published nothing. The
stores may hold mid-boundary values until the next `init!` or `restore!`
resets them, as after a throw inside boundary zero ([§13.4][s13-4]).
`checkpoint` refuses such a run, since the executor no longer rests where
its last snapshot was published ([§12.6][s12-6]). The trace is the
reproduction ([§12.7][s12-7]).

**A second interrupt during the tail** collapses the remaining joins
immediately. That is (5)'s abandonment path taken at once, with devices
still reported by name (`DeviceJoinTimeout`). The run still ends `stopped`.
Escalation shortens the tail, never reclassifies the run. Nor can a second
interrupt repair (5)'s honest asymmetry, since nothing can abandon the task
`run!` stands on.

**Interactive-session scope, stated plainly.** Outside the REPL, Julia's
default (`exit_on_sigint(true)`) kills the process on SIGINT before any of
this machinery runs. The framework flips nothing process-global.
[Unattended runs](#g-unattended-run), those with empty staging and no
snapshot readers, rely on `t_end` and stop requests, as they already must.

### 12.5 Scripts and the mid-run mutation doctrine

What the consumers demonstrably mutate mid-run is surveyed here. FlightCore's
`user_callback!` has exactly two archetypes. The first is the timetable
script (c172_demos.jl:290: `elevator_offset` as a function of `t`). The
second is the synthetic pilot (c172_demos.jl:423, 525: a phase FSM reading
`y` and writing mode requests, references, flaps, wind). Both write only `u`
fields. No demo, test or GUI path pokes `x`/`s` mid-run, and `init!`/trim
appear only between construction and `run!` (c172_demos.jl:303).

**Sim-time scripts are model behavior, so they become
[scenario components](#g-scenario-component)** (ordinary periodic discrete
components holding a sim-time script). Both archetypes are clocked by *sim
time*, `t`, the trajectory. Mapping them to [devices](#g-device) is rejected
([D-031][d-031]). The clock is the criterion.

**Rule.** A sim-time script becomes a source or supervisor
[component](#g-component); a wall-clock interaction becomes a device.

A script mapped to a component is periodic discrete, with `K = 1` for
today's `dt = 0.02` callbacks. It executes synchronously in the loop,
deterministic paced or unpaced. It is replayed by recomputation, with no
[trace](#g-trace). A device, by contrast, is traced and replayed from the
trace.

**The component mapping is strictly richer than the callback it replaces.**

- The `Ref(:init)` phase closure becomes honest `s`, visible in
  [snapshots](#g-snapshot), logs and plots.
- Inputs arrive same-[boundary](#g-boundary) fresh by topological order. The
  callback ran post-step, one boundary staler.
- The pure timetable script is a one-liner reading the clock out of its
  [bundle](#g-bundle) (the NamedTuple of zero-copy views a component function
  receives). That one-liner is
  `y_direct(c, (; t)) = (; offset = profile(t))`, exact at its own
  [ticks](#g-tick), with no latching.
- In a scenario configuration the script drives the avionics' input
  [ports](#g-port). [§11.7][s11-7] therefore renders the corresponding GUI
  widgets read-only with its source shown. Today's demo-vs-GUI dead-slider fight
  is resolved by the port-resolution rule.

**`user_callback!` is eliminated** ([D-031][d-031]). It is the
[periphery](#g-periphery)'s `f_step!`, FlightCore's unconditional per-step
hook ([§2.5][s2-5]), and cheap composition leaves it
without justification. Its call sites migrate to scenario components, not
devices.

**Manual event triggering needs no mechanism.** It takes a
[root input](#g-root-input) plus a [boundary-detected](#g-boundary-detected)
[guard](#g-guard) reading that root input (an edge check at step boundaries
only, with no root-finding). That is already expressible in settled
machinery. The levels doctrine applies: latched commands or counters. The
demos' engine start/stop buttons are `u`-writes today.

**Mid-run re-initialization is not built, because it is not demonstrated.**
Initialization and trim are stopped-sim workflows (first-class services,
[§14][s14]). No concurrency perimeter exists there. There is no loop and no
devices, just plain single-task code. The guarded-addition shape is on
record should demand appear. It would be a traced, boundary-executed
intervention command applied through project → [sweep](#g-sweep) → publish,
so that no consumer ever observes un-decoded state.

**The doctrine, final form.** While a simulation runs, the periphery stages
root-input writes and issues control commands. Structurally, it does nothing
else. Anything that wants to poke the model mid-run is one of three things.
It is an *input* in disguise, so wire a root input and a guard. It is *model
behavior* in disguise, so add a scenario component. Or it is a *wall-clock
interaction*, so attach a device. Graceful termination follows the same
shape ([§13.5][s13-5]): a [stop request](#g-stop-request) declared in the
model, honoured unless the advance ignores it. Never a callback, and never a
thrown exception.

### 12.6 Run lifecycle and partial advance

**[`Run`](#g-run) is what one run owns** ([D-255][d-255], [D-260][d-260], [D-317][d-317]).
It is a mutable struct of six fields. Two are `const` and last the run's whole
life, the log and the [trace](#g-trace) (`nothing` under the trace switch).
The door that builds the run takes the four recording keywords, `trace`,
`log`, `log_every` and `log_max` ([Appendix B][sB], [D-261][d-261]), so a
run's recording is that door's declaration and the next door may declare
otherwise.
Four evolve during it. `feed` is the recording `replay!` attached, or
`nothing`. `termination` is the record the loop's tail writes. `frame` and
`boundary` are the trajectory's counters, the frame index and the boundary
ordinal. `init!`, `restore!` and `replay!` construct one, and nothing else
rebinds it. `live!` and the halt at a recording's end write `feed`. The
loop's tail writes `termination` once, and `closed(run)` is
`termination !== nothing`. Each door sets the two counters as it builds the
run, `init!` to zero and `restore!` and `replay!` to the checkpoint's, and
the loop advances them ([D-317][d-317]). `restore!` of a bare state sets the
frame index to the state's frame and the boundary ordinal to zero, as `init!`
does ([D-319][d-319]).
The origin `t₀` is not a run field. The executor's clock holds it beside `t`.
`init!` sets it on the clock before boundary zero ([§14.5][s14-5]), and a
[checkpoint](#g-checkpoint) (the `Model`'s state at a frame top as one
value) carries it with the clock ([§11.5][s11-5], [D-273][d-273]). It is a
`Float64`, as `h` and `t_end` are.

A `Simulation` is constructed with a **placeholder run**, an empty log, no
trace, no feed and no termination, which `init!`, `restore!` and `replay!`
replace ([D-255][d-255]). The field is always a `Run` and never `nothing`, so every
accessor has a run to read, and the lifecycle state below says whether that run
ever started. The placeholder carries no configuration and no compiled state
([D-261][d-261]). `init!` allocates fresh objects rather than clearing them.

**`Simulation` is a mutable struct of four fields**, the
[`Model`](#g-model) (the deployment and its executor at one scalar), the run, the
data plane and the [control plane](#g-control-plane) ([D-317][d-317]). The `Model`
holds the [deployment](#g-deployment) (the scalar-free artifact the grid
parameters fix, carrying the build), the [executor](#g-executor), its status
and its diagnostic cell. A simulation owns its `Model`, claimed at
construction and never shared ([§9.2][s9-2], [D-318][d-318]). Every other value belongs to one of the four
([D-256][d-256]). The build is reached through the
deployment, never held twice. The grid parameters, the [schedule](#g-schedule) (the typed
per-component `(D, Φ, Δt)` tick table) and the event parameters are the
deployment's ([§9.2][s9-2]). `chunk_size`, the stepper and the arrival buffers
are the executor's. `join_timeout` is `Control`'s ([§12.1][s12-1]). The loop's
[diagnostic cell](#g-diagnostic-cell), its account and the published holder
are the plane's, and the frame's own cell is the `Model`'s ([§11.8][s11-8]).
The log, the trace and the two counters are the run's. The
stop policy, with its `t_end` and ignored requesters, is the advance's argument, and
the [termination record](#g-termination-record) keeps the terminating one
([D-260][d-260]). The pacer's schedule and counters are `run!`'s own, created
per call and passed to the loop and its publications as the policy is, and
each snapshot's status carries their frozen record ([§10.7][s10-7], [D-269][d-269]).

**Rule.** A struct holds what it owns or what it must retain across calls. A
callee takes what it reads as an argument, never off a field added to the
container it already holds. An object is built after its inputs exist, and
the placeholder run above is the one exception ([D-261][d-261]).

A `Simulation` moves through five states: **built**, **initialized**,
**running**, and terminally **stopped** or **errored** ([§13.4][s13-4]).
**Built** means stores allocated and [boundary zero](#g-boundary-zero) not
completed. It is the cold state, and the state a throw inside boundary zero
returns the simulation to ([§13.4][s13-4]). **Initialized** means `init!`
has completed boundary zero, the initialization boundary run as the ordinary
macro-sequence with an empty integrate ([§14.5][s14-5]), or `restore!` or
`replay!` has restored a checkpoint.

**`lifecycle(sim)` derives the state rather than storing it** ([D-317][d-317]). It
reads three facts, the control plane's running flag, the `Model`'s status
and whether the run is closed. The status is `:built`, `:consistent` or
`:inconsistent`, and only the `Model`'s own doors and catch sites write it.
A claimed model's status is written only through its simulation's doors,
since the model's doors refuse a direct call on a claimed model ([D-318][d-318]).

| running flag | `Model` status | run closed | state |
|---|---|---|---|
| set | any | any | running |
| clear | `:built` | any | built |
| clear | `:inconsistent` | any | errored |
| clear | `:consistent` | no | initialized |
| clear | `:consistent` | yes | stopped |

Beside the state, the run carries an **[input mode](#g-input-mode)**,
`:live` or `:replay`, read as `mode(sim)`. It is read off the run's `feed`:
`:replay` while a recording is attached, `:live` otherwise ([D-260][d-260]).
The mode names where the next frame's [drain](#g-drain) takes its batches
from, the staging cells or the attached recording ([§12.7][s12-7]). State and mode are orthogonal. The
state says whether the simulation may advance, and the mode says what it
will advance on.

**Rule.** `init!` is mandatory.

`run!` or `step!` on a simulation whose [boundary](#g-boundary) zero has not
completed is an error in the kind set ([§13.2][s13-2]) naming `init!`. That
is distinct from `UninitializedInputs`, which fires *inside* `init!`
([§14.6][s14-6]). `restore!` and `replay!` are the two alternative entries.
Each restores a checkpoint and runs no boundary zero ([§12.7][s12-7],
[D-274][d-274]). A throw inside boundary zero, which only `init!` runs, leaves
the simulation `built` ([§13.4][s13-4]), so the next `run!` or `step!` meets
the same refusal.

**Where the loop runs.** The loop runs on the [calling task](#g-calling-task),
the task that invoked `run!`, and every rostered [device](#g-device) on a
spawned task ([§11.1][s11-1]). Deviceless, `run!` is fully synchronous. An
[unattended run](#g-unattended-run) is the same loop with empty staging
([§11.1][s11-1]). It is also what the synchronous rethrow presupposes
([§13.4][s13-4]).

**Partial advance.** `step!(sim; frames = 1)` advances whole frames
synchronously through the ordinary frame sequence ([drain](#g-drain),
integrate, boundaries, publication) and returns. A stepped simulation is
bit-identical to the same frames under `run!`, and it never waits, whatever
pace the control plane holds ([D-269][d-269]). `step!(sim; t_plus = 10.0)`
is the duration spelling, mutually exclusive with `frames`. It advances
whole frames until the boundary time first covers the duration, which is
the migration suite's advance-by-duration idiom.

Partial advance is the test-harness mode: advance, assert, advance. It
is equally the REPL mode: fly a while, inspect, continue. Neither is a
script, so the scenario-[component](#g-component) doctrine does not absorb
them ([§12.5][s12-5]).

**A stepping session is deviceless by construction.** Device tasks are
per-`run!` artifacts ([§11.1][s11-1]), and a device loop's
`while running(handle)` is false outside a run. Between `step!` calls the
simulation is in a stopped-sim state, `initialized` (below), so `attach!` is
legal there and does what it always does. It registers ([§11.3][s11-3]), and
the task appears at the next `run!`.

**The [frame-top drain](#g-drain) still runs**, so `step!` frames stay
bit-identical to `run!` frames. What it drains is the **harness
[cell](#g-harness-cell)**. The harness write path is
`stage!(sim, "face" => value, …)` ([§11.3][s11-3]), from any task, the calling
task included. Staged batches are ordinary batches. They are traced, so
[replay](#g-replay) and bit-identity hold. They are applied at the next
frame top. They are surface-checked like any writer's ([§11.3][s11-3]).

The read half is `latest(sim)`. It hands back the same immutable
[snapshot](#g-snapshot) value a device handle acquires ([§11.2][s11-2]),
navigated directly for assertions. Advance-assert-advance is `stage!` →
`step!` → `latest`. Both entry points work under `run!` too. The
[harness cell](#g-harness-cell), the always-present staging cell of the
harness writer, is not step-scoped. An inspection accessor leaves the
rejection of closure-based termination ([§13.5][s13-5]) untouched.

**Status, termination and the `run!` [seam](#g-seam).** Between `step!`
calls a simulation reports **initialized**. No loop task exists, so
`running` would lie. Nothing is terminal, so `stopped` would lie too. The
state reads "boundary-consistent and ready to advance", not "sitting at
boundary zero". `run!` may therefore follow `step!`, continuing from the
current boundary, and so may another `step!`.

Termination policy is honored throughout, as bit-identity requires. `t_end`
reached, or a [stop request](#g-stop-request) [holding](#g-edge-semantics) at
frame 3 of `step!(sim; frames = 10)`, ends the run there through the
ordinary [§12.4][s12-4] tail and leaves the simulation `stopped`. `step!`
therefore returns the number of frames **actually advanced**. That is the
requested count in the ordinary case, and fewer when the run terminated
inside the call. That return is how a harness detects the truncation without
inspecting the clock.

**Re-running: `stopped → init! → run!` remains the authored re-run.**
`init!` re-runs boundary zero from its condition. The warm restart is
`checkpoint` → `restore!` → `run!` ([§12.7][s12-7], [D-274][d-274]).
`restore!` is a door like `init!`, and it runs no boundary zero. Each builds
a fresh run, so the trace, the log and the
[termination record](#g-termination-record) ([§13.5][s13-5]) are new objects
rather than cleared ones, and each clears any batches still in
[staging cells](#g-staging-cell). The [recorders](#g-recorders) restart with
the run they record, and no stale batch survives to clobber the frame it
predates. `init!` and `restore!` also return the input mode to `:live`, and a
fresh `replay!` sets the mode exactly as it sets the trajectory. `live!` is
the fourth door, and the only one that moves the mode alone. It takes a
replaying simulation live where it stands ([§12.7][s12-7]). A terminal state
makes the mode moot. Nothing advances until one of those doors is taken
([D-218][d-218], [D-219][d-219]).

**`checkpoint` and `restore!` exist on the `Model` and on the `Simulation`,
and a `Checkpoint` is the `Model`'s state beside the run's cursor** ([D-319][d-319]).
`checkpoint(model)` returns the state alone, a `ModelState`. It holds the
flat buffer, the `s` and `m` stores, the whole signal table, the guard
priors, `t`, `t₀` and the fingerprint. It is legal at `:consistent` with the
clock on a grid top. `checkpoint(sim)` wraps that state with the run's frame
index and boundary ordinal ([D-274][d-274]). It is a stopped-sim
service, legal in `initialized` and `stopped` ([§14][s14]). It is refused wherever the
executor is not at the rest a published frame top leaves (`CheckpointMidFrame`,
[Appendix C][sC]). That is after a `t*` stop, which leaves the clock mid-frame with
the remainder abandoned, and after a frame abandoned unpublished ([§12.4][s12-4]). The
test is that the clock sits on a grid time and that the latest snapshot is of
that very boundary. `restore!(model, model_state)` checks the state's
fingerprint against the model. It also checks that the state's `t` is a grid
time `t₀ + k·h` of the state's own origin and step, and a state off its grid
is `CheckpointMidFrame`. Every mismatch of either kind is collected into one
throw before any write. The door then copies the state back, settles the
restored boundary through the hooks and writes `:consistent` last
([D-318][d-318]). `restore!(sim, cp)` takes the four recording keywords `init!` takes.
It checks the checkpoint's fingerprint against the simulation as replay checks
the trace header, and a mismatch is `CheckpointMismatch` ([§12.7][s12-7]). It checks
the state's `t` against its grid as the model's door does, collecting both
kinds into one throw. It then copies
the state back, opens a fresh run with the checkpoint as its trace header, and
publishes one snapshot at the checkpoint's `t`. It runs no sweep, evaluates no
guard, runs no update and resets no prior. The next frame is the original
lattice's next frame, because the clock came with the checkpoint. The boundary
ordinal continues, being the trajectory's ([§12.3][s12-3], [D-230][d-230]). The snapshot
`restore!` publishes is a re-publication. It carries the ordinal of the boundary
the checkpoint was taken at, and the next frame publishes under the next
ordinal, as it did in the original run. `restore!(sim, model_state)` is the
door a state prepared on a standalone model takes into a simulation
([§9.2][s9-2]). It takes the same keywords and makes the same fingerprint
check, and it refuses a state whose `t` is off the grid as
`CheckpointMidFrame`. It opens a fresh trajectory at the state's frame, and
the restored boundary publishes under ordinal 0, as boundary zero's does. A
standalone model published nothing, so the trajectory has no ordinals to
continue. A `Checkpoint` holds a `ModelState{Float64}`, so it is nominal by
type. A state taken at another scalar is refused by dispatch with the same
`CheckpointMismatch`, on either `restore!` that takes a bare state.

**Device attachments persist across re-initialization**, because attachment
is orthogonal to the run lifecycle ([§11.3][s11-3]). Persistence means
*roster* persistence. Binding, [claims](#g-claim) and device id survive.
Tasks and OS resources do not (the per-run topology, [§11.1][s11-1]; the
teardown, [§12.4][s12-4]). Each `run!` re-initializes every rostered device
and spawns its task. `attach!` while stopped only registers, and the task
appears at the next `run!`.

**Task topology follows the roster each time** ([§11.1][s11-1]). A front
end attached by hand is still rostered, so the next `run!` spawns its task
again.

**The stop policy is declared per advance.** `t_end` and
`ignore_stop_requests` are keywords of `run!`, `replay!` and `step!`, and each
call builds and validates the [`StopPolicy`](#g-stop-policy) (the immutable
value of `t_end` plus the ignored requester paths) it passes to the loop
([§13.5][s13-5], [D-255][d-255], [D-316][d-316]). The value lives as long as the call,
and afterwards only on the termination record of the advance that ended the
run ([D-260][d-260]). A second run, or a `step!` sequence between two runs,
can therefore stop on a different clock or honour a different set of stop
requests without a rebuild.

**`errored` is terminal** ([D-059][d-059]). Reproduction is trace replay
([§12.7][s12-7]), not resurrection.

### 12.7 Replay: the trace re-drives the ordinary loop

The entry point the [§11.5][s11-5] [trace](#g-trace) exists for:

```julia
trc  = trace(sim)                     # the recorded session: header + per-frame batches
sim2 = Simulation(world)              # the same build
replay!(sim2, trc)                    # restore the header, then re-drive every recorded frame
replay!(sim2, trc; to_boundary = k)   # partial: the §13.4 replay-pointer idiom
replay!(sim2, trc; to_time = 100.0)   # partial: the same halt addressed by time
cp   = checkpoint(sim)                # the state at a frame-top rest
restore!(sim2, cp)                    # that state alone: a warm restart, no feed
```

`replay!` is **the ordinary loop with exactly one substitution**, not a
second loop. That is what keeps every property proved of the loop true of
[replay](#g-replay). The loop starts from a restored state, and its drain
reads the trace:

- **Restore from the header.** `replay!` restores the trace's
  [checkpoint](#g-checkpoint) (the `Model`'s state at a frame top as one
  value), the state the recording opened from. It runs no
  [boundary zero](#g-boundary-zero). The drain then reads the trace.
  `replay!` stands in the `init!` position of the lifecycle
  ([§12.6][s12-6]) and does what `restore!` does, with the trace header as
  the checkpoint. There is no condition resolution, and the totality
  ([§14.6][s14-6]) held when the recording's `init!` ran. Whatever fired at
  `t₀` is part of the restored state, so nothing is applied twice and
  nothing is skipped ([D-274][d-274]).
- **The [drain](#g-drain) reads the trace.** Each frame top applies the
  recording's batches for that **[frame ordinal](#g-frame-ordinal)**, the
  frame index a batch replays at. It does not swap the [roster](#g-roster)'s
  [staging cells](#g-staging-cell), where a device's pending write batch
  waits between drains. Ordinal keying is exact because the frame sequence
  is itself deterministic under replay (`t*` boundaries derive from state,
  [§10.4][s10-4]). Frame *k* of the replay *is* frame *k* of the recording.
  Recorded batches apply **verbatim, with no surface re-check**. The
  write-surface rule ([§11.3][s11-3]) ran at recording time, and
  [claims](#g-claim) are a live-roster fact of the recorded session that
  replay does not reconstruct.

**Rule.** A simulation is in one of two [input modes](#g-input-mode),
`:live` or `:replay`, and the mode decides which source that one drain
branch reads: the [staging cells](#g-staging-cell) under `:live`, the
attached recording under `:replay`. `replay!` attaches the recording and
enters `:replay`. `step!` and `run!` consume it from there, frame by frame,
exactly as the bullet above describes. There is still one loop and one drain
([D-218][d-218]).

**Why.** A mode that outlives the call makes a partial replay a resumable
position rather than the end of an operation. Whatever advances the
simulation next reads the same mode and finds the same records. That is
what lets the reproduction workflow of [§13.4][s13-4] run through the
ordinary entry points, with no replay-only spelling of `step!`. That
workflow halts at the frame top the error names, then `step!`s the failing
frame on its recorded inputs.

**Rule.** `replay!(sim, trc; restore = false)` attaches the feed to the
simulation as it stands and restores nothing. The simulation must be
`initialized`, at the recording's `t₀`, and at a frame from the header's to
one short of the recording's last. Anything else is refused before any write
(`CheckpointMismatch`, its clock arm). One grid is thus an invariant of every
replay, and `to_time` has one meaning. The drain applies the records from the
frame after the simulation's own.
This form is a door like the default one. It builds a fresh run under the
recording keywords, takes the simulation's own checkpoint as the new trace's
header, and publishes one snapshot. That form serves the what-if of a modified
model initialized under the authored condition (below). It also serves a seek,
`restore!` of a checkpoint the recording passed through followed by the feed
from the next frame ([D-274][d-274]).

Everything else is the loop as already specified:

- **Termination and partial replay.** In `:replay` the recording is the
  bound. Every advance's frame budget is capped at the recording's last
  frame, and `to_boundary = k` caps it earlier. That keyword is the consumer
  of the replay pointer ([§13.4][s13-4]). `to_time` is the same cap
  addressed by time, the next bullet. Either names a frame at or after the
  one the feed starts from. That is the header's frame under the default
  form, and the simulation's own under `restore = false`. An earlier one is
  refused (`ArgumentInvalid`). The `to_boundary` spelling is defined
  as running **through the frame whose execution published boundary `k`**,
  so replay always halts at a frame top. For a grid boundary the halt is
  exactly at `k`, the frame that publishes one ending at it. The frame-entry
  pointer ([§13.4][s13-4]) lands the same way. A [localized](#g-localized)
  `t*` boundary inside the frame (the crossing instant bracketed by
  root-finding over trial sweeps) is reproduced but not stoppable-at.
  [§10.4][s10-4] separates the two indices. The trace stays frame-indexed,
  and boundaries are the reporting index. Replay may also end earlier still
  under the ordinary policies, since `t_end` and `ignore_stop_requests` are
  keywords of `replay!` exactly as of `run!` ([§12.6][s12-6]). A termination
  the recorded session hit through a stop request reproduces itself anyway,
  deterministically. A replay honours requests by default too, and the trace
  header records no policy, so a live run that ignored some is replayed
  under the same `ignore_stop_requests`.
- **`to_time` addresses the same halt by time.** The keyword is mutually
  exclusive with `to_boundary`, and it halts at the **last frame top at or
  before** the time given: `k = ⌊(to_time − t₀)/h⌋` against the header's
  `t₀`. A time falling between two frame tops floors onto the earlier one.

  The rounding is the deliberate opposite of `t_end`'s, which ends a run at
  the first grid boundary reaching or exceeding it ([§12.4][s12-4]). `t_end`
  bounds a run, and `to_time` positions an inspection. The point of halting
  is to stand *before* the anomaly, so a halt that stepped past it would
  defeat the call ([D-219][d-219]).

  Validation is the other keywords'. The value must be real, finite and at
  least `t₀`, and it must name a time the recording covers. The checks run
  before the replay writes anything, the restore included.
- **The halt flips the mode only at the recording's end.** A frame budget
  that runs out halts the loop at a frame top, leaving the simulation
  `initialized` ([§12.6][s12-6]). The mode becomes `:live` exactly when that
  halt lands at the recording's last frame, with the records exhausted. It
  stays `:replay` otherwise, and the next `step!` or `run!` goes on
  consuming the recording. So no advance ever flips mid-run. A `run!` whose
  `t_end` lies past the recording halts at the last recorded frame, now
  `:live`, and the *next* call is the live continuation ([D-218][d-218]).
- **`live!` is the mode's one manual door.** The flip above is automatic,
  and it happens only at the recording's end. `live!(sim)` performs it by
  hand. It sets the mode to `:live` and detaches the recording's remainder,
  touching nothing else. The trajectory stands where the replay left it, and
  so does the trace with the header it inherited. The next `run!`
  or `step!` is therefore the live continuation from the replayed boundary,
  and its drains append to the re-recorded prefix. `live!` is a stopped-sim
  operation, legal only on an `initialized` simulation in `:replay`.
  `:running` and `:errored` refuse under the ordinary lifecycle gates
  ([§12.6][s12-6]), and a simulation already `:live` refuses too. The call
  would have nothing to do, and a loud refusal beats a silent no-op
  ([D-219][d-219]).

  That door is what makes the rewrite workflow real. An interactive session
  is interrupted at t = 110, and the last ten seconds are to be flown again:

  ```julia
  trc  = trace(sim)                     # the interrupted session, out to t = 110
  sim2 = Simulation(world)
  replay!(sim2, trc; to_time = 100.0)   # halt at the last frame top at or before 100
  latest(sim2)                          # inspect the boundary landed on
  live!(sim2)                           # drop the remainder; the mode is :live
  run!(sim2; t_end = 130.0)             # live from t = 100, re-recording onward
  ```

  The trace `sim2` leaves behind is a complete recording of *itself*: the
  replayed prefix out to t = 100, then the frames flown live after it.
- **Replay ends `initialized`, never `stopped`.** That state is
  boundary-consistent and ready to advance, the same state `step!` leaves
  ([§12.6][s12-6]). This is what makes three promised workflows real.
  State-trajectory inspection asks "what was the private state at
  t = 37.2?", and answers it by replaying there and reading the live stores
  ([§11.2][s11-2]). Error reproduction replays to `k − 1`, then `step!`s the
  failing frame under instrumentation ([§13.4][s13-4]). Continuation is
  `run!` after `replay!`, a live session from the replayed boundary. After a
  full replay that is the next call, the records exhausted at the halt.
  After a partial one the remainder of the recording is consumed first,
  across as many `step!` and `run!` calls as the caller makes, and the
  session goes live at the recording's end. Or `live!` drops that
  remainder, and the continuation starts at the halt.
- **Replay re-records.** The drain records normally. The new trace
  inherits the old header and accumulates the re-drained batches, a
  bit-identical prefix. A replayed-then-continued session therefore leaves
  behind a complete, valid trace of *itself*, with no special stitching.
- **[Pacing](#g-pacing) and the [control plane](#g-control-plane) are
  unchanged** ([§10.7][s10-7], [§12.1][s12-1]). Pacing (waits inserted
  between completed frames, never altering the boundary sequence) sits
  outside the semantics, so paused, slow-motion or real-time replay is free.
  Paced replay with an attached visualizer *is* session playback, and
  `replay!` takes `pace` and `margin` as `run!` does ([D-269][d-269]). Stop
  truncates, as anywhere.
- **[Devices](#g-device) are readers.** Rostered devices init and spawn
  normally ([§11.1][s11-1]) and consume [snapshots](#g-snapshot)
  ([§11.2][s11-2], [§12.3][s12-3]). That is the visualizer case. But no live
  staging [cell](#g-staging-cell) is drained while the simulation is in
  `:replay`. A batch found staged is discarded with a rate-limited warning
  (`ReplayDiscardedStaging`, [Appendix C][sC]). Mixing live writes into a
  replay would destroy the property replay exists to provide. A session that
  wants live input is a continuation (`run!` after replay), not a replay.
- **Validation is loud and up front.** Before the first frame, the checkpoint's
  fingerprint is validated against the target, its layout against the `Build`
  (store layout, root input [faces](#g-face)). The trace's batch entries are validated
  against the root input-face list, and each batch's frame ordinal against the
  recording's frames, from the one after the header's to the last ([D-217][d-217]). Each
  writer's face-name → position schema, on the trace's `schemas` list ([§11.5][s11-5]),
  is **validated** in the same pass. A recorded schema that disagrees with the
  target model's own root-input faces is a replay error. The checks are
  attach-style, and a failure reports [did-you-mean](#g-did-you-mean): the offending name plus the
  list-in-hand it should have matched. The kinds are `CheckpointMismatch`,
  `ReplaySchemaMismatch` and `ReplayUnknownFace` ([Appendix C][sC]). The pass runs
  under both forms of `replay!`.

  The same pass pays the trace-record conversion in reverse. Every writer's
  sparse records ([§11.5][s11-5]) are normalized to positional batches
  against the trace's `schemas` list, once, off the loop. Replay has the whole
  trace in hand before frame 1. The replay drain therefore applies compiled
  scatters exactly as the live drain does, and no face name is resolved per
  frame under replay either.

  *Structural* mismatch is an error. *Parametric* difference is not.
  Replaying against the same structure with changed parameters is the
  **[what-if replay](#g-what-if-replay)**, the deterministic re-driving
  of the recorded inputs through a modified model. It is spelled as `init!`
  of the modified model under the authored condition, then
  `replay!(sim, trc; restore = false)`. The trace is not self-sufficient for
  it. Its checkpoint holds the recording model's state after boundary zero,
  so the authored condition comes from outside ([D-274][d-274]).
  Bit-identity is promised only against the identical build. What-if replay
  promises determinism, never reproduction.

  **The checkpoint check compares two deployments as values** ([D-254][d-254]).
  The checkpoint carries the recorded run's [`Deployment`](#g-deployment) (the
  scalar-free artifact the grid parameters fix), the target `Simulation`
  carries its own, and the check is their comparison, on the *structural* side
  of that line ([§11.5][s11-5]). The value covers the trajectory-determining
  parameters, `Δt_base`, `h`, `N_base`, the algorithm, `localization_tol`,
  `localization_budget` ([§10.4][s10-4]) and `firing_budget`
  ([§10.6][s10-6]), and the [schedule](#g-schedule) (the typed
  per-component `(D, Φ, Δt)` tick table) with every column, the anchor and
  rate-chain columns included. A rate re-declared through a different anchor
  at the same tick table is therefore a different deployment, and the
  replay is refused. The refusal costs one re-recording in a rare case, and
  it keeps the equality a plain value equality rather than one that ignores
  two of a row's columns. Mismatch is
  `CheckpointMismatch` with a deployment-parameter discriminator, never a
  what-if. A deployment change moves the times at which the frame-ordinal
  batches apply. That is different inputs, not a modified model. The event
  trio (the localization pair and `firing_budget`) is compared for exactly
  the same reason the grid parameters are. It moves the trajectory, so a
  run that differs in it is not re-driving the recorded one. Comparison by
  value is what makes the check one expression rather than a field-by-field
  walk.

  The clock is *restored*, not compared. Replay restores `t₀` with the rest
  of the clock, so `replay!` takes no `t0` argument. The checkpoint holds no
  policy ([D-255][d-255]). `t_end` and `ignore_stop_requests` are keywords of
  this `replay!` call, validated per call as at `run!`.

The dispositions, by trace content:

| trace content | disposition |
|---|---|
| the checkpoint's layout: store layout, root-input faces | compared against the `Build` |
| the recorded `Deployment`, carrying `Δt_base`, `h`, `N_base`, the algorithm, `localization_tol`, `localization_budget`, `firing_budget` | compared as a value against the target `Simulation`'s own deployment |
| each writer's face-name → position schema (on the trace's `schemas` list) | validated against the target model's root-input faces: disagreement is a replay error |
| the checkpoint's state | restored; no boundary zero |
| the clock | restored, `replay!` takes no `t0` |
| `t_end`, `ignore_stop_requests` | absent from the checkpoint; each `replay!` call declares its own ([§13.5][s13-5]) |

Rejected shapes, for the record ([D-101][d-101]): a `run!(sim; replay = trc)`
flag, a synthetic playback device staging the recorded batches, and replay
ending `stopped`. The input mode clarifies that decision's drain
substitution rather than replacing it, and carries its own rejected shapes
([D-218][d-218]).

---


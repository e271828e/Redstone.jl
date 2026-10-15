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


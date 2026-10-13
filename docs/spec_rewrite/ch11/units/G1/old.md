### 11.6 Devices: one authoring contract, no taxonomy

FlightCore's input/output/GUI trichotomy is lock choreography, not modeling.
With no lock, the protocol the taxonomy encoded has no referent
([D-025][d-025]).

#### Every attached device receives the same handle

The handle carries the two primitive capabilities, read and stage, plus
control access (observe running, request shutdown). Read returns the latest
[snapshot](#g-snapshot), optionally waiting for the next
[boundary](#g-boundary) ([§12.3][s12-3]).

**A handle outlives its roster entry as an object only.** `detach!` retires
the entry and the compiled writer behind it, but the caller may still hold
the handle `attach!` returned. Its two write primitives, `stage!` and
`report!`, then refuse by name (`DeviceContractMismatch`, [Appendix C][sC]). A
batch staged there would land in a cell no [drain](#g-drain) reads, and a
report would land in a diagnostic cell no frame top folds. Silence is the
hidden-bug class this section tolerates nowhere. The read primitives stay
legal, since they read the simulation's shared state and nothing of the
entry's ([D-244][d-244]).

**[`should_abort`](#g-should_abort) is an `attach!` keyword**, defaulting to
`false`. It is per-attachment, never a device property. The same joystick is
advisory in one deployment and decisive in another. With it clear, a
device's departure is reported and the run continues without it. With it
set, that departure also requests a sim stop ([§12.4][s12-4]). A departure
is the loop body returning, a crash, or a failed `init!`. A
hardware-in-the-loop rig attaches its plant interface with it set, since a
run without that device is meaningless.

Input-only and output-only devices are degenerate uses, not framework
classes. A bidirectional network peer is *one* device with one socket and
one lifecycle, not two framework devices sharing state. The GUI is an
ordinary device, the paradigm one, and it uses every capability. Its one
genuine peculiarity is not taxonomic: read-modify-write widgets
([§11.7][s11-7]).

#### The authoring contract: four functions, one optional

A [device](#g-device) is a user type subtyping the framework's neutral root:
`MyDevice <: AbstractDevice`. That is one mandatory word, and it costs
nothing, because the [periphery](#g-periphery) has no competing hierarchy to
inherit from. What it buys is `attach!`'s dispatch gate below. The framework
asks for

```julia
init!(dev)          # per-run resource acquisition — calling task, before spawn (§12.4)
loop(dev, handle)   # the task body: owns its own wait structure
shutdown!(dev)      # per-run resource release — guaranteed on every exit path
unblock!(dev)       # optional hook, default no-op: make a blocked loop return (§12.4)
```

The framework owns everything around them. The wrapper is the shutdown
protocol ([§12.4][s12-4]) made structural:

```julia
init!(dev)                                   # its own bracket, pre-spawn (§12.4): a throw
                                             # here is shutdown! + DeviceCrash by name
task = Threads.@spawn try
    loop(dev, handle)
catch e
    report!(entry, DeviceCrash(e))           # §12.4(6): sim continues, device absent
finally
    shutdown!(dev)                           # any exit path: OS resources released
    mark_dead!(...)                          # heartbeat only — claims stay, §11.3
end
```

**`shutdown!` must tolerate a partially initialized device.** The release
guarantee holds on the one path *outside* this wrapper too. The
initialization step ([§12.4][s12-4]) brackets each `init!`, and a device that
threw half-way through acquisition goes straight back to `shutdown!`, so
nothing it did manage to open is leaked. The obligation that follows is
"close only what is open". That is the same defensiveness `shutdown!`
already owes the crash path, where a loop body may die at any point in its
own life. `init!` is correspondingly *not* asked to clean up after itself.
The bracket does once, for every device, what would otherwise be duplicated
in each and enforced in none.

**The same tolerance covers a repeated call.** The wrapper runs `shutdown!`
once on every exit path and records the release just after it returns. An
operator interrupt landing between the two makes the run's tail run
`shutdown!` again rather than leak the device ([§12.4][s12-4],
[D-268][d-268]). The tail's own call can be cut the same way, so each such
interrupt adds one call. A `shutdown!` that closes only what is open is
idempotent by construction, so a repeated call costs nothing and is never
reported.

**The tolerance also covers a call with no `init!` before it.** The
initialization step lists each device for release before its `init!` begins,
so that no interrupt can leave an initialized device unlisted ([§12.4][s12-4], [D-268][d-268]).
An operator interrupt landing between the listing and the `init!` therefore
releases a device that opened nothing. A `shutdown!` that closes only what is
open does nothing there, and the call is never reported.

The wrapper makes one discrimination. **An `InterruptException` is never a
`DeviceCrash`.** Under the spawned-loop topology the calling task is the one
running a device loop body inline, the GUI's ([§11.1][s11-1]). An operator
Ctrl-C therefore raises *there*, inside user code that did nothing wrong. The
wrapper forwards the control-plane stop and lets the body leave through the
ordinary `running(handle)` predicate ([§12.4][s12-4](4)). There is no crash
report for what is not a crash, and no `should_abort` consultation, since a
stop is already requested.

#### The author owns the loop body; the framework owns the bracket

One device contract means author-owned loop bodies. A framework-owned hook
loop would have to ask each device what it waits on, which is the rejected
taxonomy resurrected as a trait ([D-102][d-102]). Under the author-owned
body, every wait structure is ordinary user code composed from handle
primitives:

```julia
function loop(dev::T16000M, handle)              # timer-driven, full write-set
    while running(handle)
        sleep(dev.Δt_poll)
        stage!(handle, map_input(poll_axes(dev), binding(handle)))
    end
end

function loop(dev::UDPInput, handle)             # source-driven, data-dependent
    while running(handle)
        datum = recv(dev.socket)                 # blocks; unblock! closes the socket
        is_eot(datum) && return                  # voluntary exit
        try
            stage!(handle, map_input(datum, binding(handle)))
        catch e
            is_datum_error(dev, e) || rethrow()  # a bug → wrapper → DeviceCrash
            report!(handle, MalformedDatum(e))   # garbage → visible, bounded, alive
        end
    end
end

function loop(dev::Telemetry, handle)            # boundary-driven output
    while running(handle)
        snap = wait_next_snapshot(handle)        # §12.3; returns on stop
        send(dev.socket, map_output(gather(handle, snap), binding(handle)))
    end
end
```

A bidirectional peer composes both halves itself, with an inner reader task
inside its own domain, rather than forcing a select engine into the
framework. Two idioms are author obligations the framework can only teach
and diagnose, never force ([Appendix A][sA]): loop on `running(handle)`, and
make blocking calls interruptible (`unblock!`, or timeouts). A forgotten
predicate check surfaces as `DeviceJoinTimeout` with the device's name. A
stall surfaces as a stale heartbeat ([§12.2][s12-2]). Liveness timestamps
ride *inside* the handle primitives, which store them in the device's own
[diagnostic cell](#g-diagnostic-cell) ([§11.8][s11-8]), so the framework
observes activity without owning the loop.

**`should_close` dissolves.** A window ✕ or peer EOT is the loop body
returning. The wrapper's exit path releases the device's OS resources, marks
it dead for the heartbeat and consults `should_abort`. [Claims](#g-claim) and
the [roster](#g-roster) entry persist to run end (the freeze,
[§11.3][s11-3]). [§12.4][s12-4](6) is literally "the task body returned."
The GUI implements the same authoring contract.

#### Bad datum versus bug: two classes, two fates

A datum that cannot be mapped for environmental reasons (a truncated
datagram, malformed JSON, an out-of-range field) is a
[bad datum](#g-bad-datum), tolerated *in the loop body*. The body catches
it, stages nothing, calls `report!(handle, MalformedDatum(cause))` and
continues. That tolerance is bounded by the [device](#g-device)'s own
[diagnostic cell](#g-diagnostic-cell) (the ring and suppressed counts,
[§11.8][s11-8]; the stream, [§13.2][s13-2]), and what it records is visible
next to a live heartbeat. Any other exception propagates, and the wrapper
turns it into `DeviceCrash` ([§12.4][s12-4]).

The classification is the author's, because only they know their parser.
FlightCore's `InputMappingError` docstring assigned it the same way. What
changes under the author-owned loop is that no framework per-iteration catch
site exists, so the framework's contribution is the diagnostic channel, not
the catch. A marked exception type is not provided ([D-105][d-105]).
`report!(handle, …)` writes device-attributed runtime warnings into that
device's diagnostic [cell](#g-diagnostic-cell), the single-writer entry point
into the runtime warning stream ([§13.2][s13-2], [§11.8][s11-8]), and
nothing more. It is not a general user-diagnostics channel. Tolerating
everything hides bugs as "device attached, nothing happens". Tolerating
nothing kills a live telemetry link on its first truncated datagram, and
since tasks are per-run artifacts ([D-093][d-093]), kills it for the rest of
the run.


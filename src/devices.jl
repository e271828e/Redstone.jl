# The device contract and its task machinery (§11.6, §11.1): the handle every
# attached device receives, the authoring contract's four functions, the
# framework wrapper around the author-owned loop body, and the spawn. The
# control plane the handle reads — the stop word, the sticky status, §12.3's
# counter and condition — is control.jl's, with the pause block and the pacer.
# A device failure reports as `DeviceCrash` into the device's own diagnostic
# cell (§11.8, §12.4).
#
# This file holds the handle, the contract, the wrapper and §11.7's panel kit,
# the framework's half of the panel convention: the baked port views, the peek
# and the orphan fact, all reads off the handle and a snapshot (D-270). §12.4's
# run bracket around the spawn — the init bracket, the tail and the run's-end
# sweep — is sim.jl's, beside `run!`'s frame anatomy and the Simulation-typed
# surface (`attach!`, `stop!(sim)`); nothing here names a `Simulation`, so the
# file precedes sim.jl.

# Design: §11.6, §11.7, §12.3, §12.4, D-244, D-261, D-270.
# What a device may touch is what the handle holds, so it deliberately does not
# hold the `Simulation`. Of the plane it holds the exclusivity index alone, the
# `Dict` `stage!` checks a face against, never the plane itself (D-261). The
# stable device id is the roster entry's (§12.4), and the handle's `who`
# renders it. `last_seen` is the §12.3 waiter's private register, refreshed at
# spawn so a run's first wait observes that run's boundaries. `detached` is
# D-244's flag, set by `detach!`: one atomic load per stage, no roster scan.
# The handle holds the build's `Structure` and the nominal `Layout` by
# reference, like the index, for the panel kit's bake alone: `port_views` reads
# the wiring, the claim, the exclusivity index and the addresses off the handle
# (§11.7, D-270). The type's second parameter is the gatherer's, the compiled
# reads.
"""
    DeviceHandle

The one object every attached device receives, carrying what the device may
read, stage and control.

[`attach!`](@ref) returns the handle, and the framework passes the same handle
to the device's [`loop`](@ref) on the device's own task. It carries capabilities,
not the simulation.

- Read: [`latest`](@ref) and [`wait_next_snapshot`](@ref) return snapshots (the
  immutable per-boundary publications), and [`gather`](@ref) runs the binding's
  reads over one.
- Stage: [`stage!`](@ref) writes root inputs (the root component's own input
  faces) inside the device's claim. The claim is the set of faces a device may
  write. [`report!`](@ref) reports a malformed datum.
- Control: [`running`](@ref) says whether the run goes on, and
  [`stop!`](@ref) requests a stop.

The handle also carries the attachment's binding (the value passed at `attach!`
that makes a device framework-legible), read back with [`binding`](@ref). The
loop's [`map_input`](@ref) and [`map_output`](@ref) calls take it from the
handle, so the device need not carry its configuration. The reads a GUI device
uses to show its widgets, [`port_views`](@ref), [`pending`](@ref) and
[`peek`](@ref), take the handle too.

A handle outlives its roster entry (the device's record in the list of attached
devices) as an object only. After [`detach!`](@ref), the two write primitives,
`stage!` and `report!`, are refused as `DeviceContractMismatch` instead of
landing in a cell nothing reads. The reads stay legal.

The handle's type carries the binding's type and the type of its compiled
reads, so `binding(handle)` and `gather(handle, snapshot)` are type-stable
inside a device's `loop` and allocate nothing.
"""
mutable struct DeviceHandle{B<:AbstractBinding,G<:Union{Nothing,Reader}}
    const who::String
    const b::B
    const writer::Writer
    const claimedby::Dict{Symbol,String}        # the plane's exclusivity index, by reference
    const control::Control
    const published::Published
    const diag_cell::DiagCell
    const gatherer::G                           # the compiled reads; nothing without an output side
    const structure::Structure                  # the build's rows, for the panel kit's bake (§11.7, D-270)
    const layout::Layout                        # the nominal activation's addresses, likewise
    last_seen::Int
    @atomic detached::Bool                      # set by detach! (D-244), read by the write primitives
end

# D-244's guard, on the write primitives alone.
_assert_attached(handle::DeviceHandle) =
    (@atomic :acquire handle.detached) && throw(DiagnosticError(
        DeviceContractMismatch(device = handle.who, reason = :detached)))

# --- the authoring contract (§11.6) --------------------------------------------

# Design: §11.6, §12.4, §12.4(3), Appendix C, D-366.
# The authoring contract opens here, its four functions in a row: `loop` is the
# one mandatory function, and `init!`, `shutdown!` and `unblock!` are optional
# hooks with no-op defaults, since a stub device holds nothing (D-366).
# `unblock!` is §12.4(3)'s hook, and `attach!` refuses a device with no `loop`
# (Appendix C); each of the three carries its own docstring below. `init!` and
# `shutdown!` are the per-run resource bracket, and `init!` runs in §12.4's
# pre-spawn bracket on the calling task.
"""
    init!(dev::AbstractDevice) -> Nothing

Initialize the device's resources at the start of each run, before the device's
task starts.

`init!` is one of a device's three optional hooks, beside [`shutdown!`](@ref)
and [`unblock!`](@ref). The default does nothing, so a device that holds no
resources defines no method. [`run!`](@ref) and [`replay!`](@ref) call it once
per attached device, in attachment order, before any device's [`loop`](@ref)
starts. It acquires what the run needs, such as a socket or a file, and need not
clean up after a throw, since `shutdown!` does that.

A throw inside `init!` is reported as `DeviceCrash` into the device's diagnostic
cell (the per-writer cell holding runtime diagnostics), and `shutdown!` then runs
on the partially initialized device. The run goes on without the device, unless
its attachment set `should_abort`, in which case the failure also requests a
stop.
"""
init!(::AbstractDevice) = nothing

# Design: §11.6, §12.4, D-138, D-268, D-372.
# The release is guaranteed on every exit path, the failed-`init!` bracket
# included. A throw out of it is caught by `_shutdown!` below, so it cannot
# wreck the bracket or the tail around it.
"""
    shutdown!(dev::AbstractDevice) -> Nothing

Release the device's resources at the end of each run, whichever way the run
ends.

`shutdown!` is one of a device's three optional hooks, beside [`init!`](@ref)
and [`unblock!`](@ref), and the default does nothing. The framework calls it
after the device's [`loop`](@ref) returns or throws, and after an `init!` that
threw. It must therefore tolerate a partially initialized device, closing only
what is open. A `shutdown!` written that way is also safe when an interrupt
(Ctrl-C) at the wrong moment calls it twice, or with no `init!` before it.

A throw inside `shutdown!` is logged as a warning that the device's resources
may leak, and the run's shutdown goes on.
"""
shutdown!(::AbstractDevice) = nothing

# Design: §11.6, §12.4, §12.4(3), D-402.
# Tail step (3), after step (2) has woken every framework wait. The wrapper
# reads an override as `_unblocks` does, against the default method.
"""
    unblock!(dev::AbstractDevice) -> Nothing

Make the device's loop return from its own blocking call once the run is
stopping.

`unblock!` is one of a device's three optional hooks, beside [`init!`](@ref) and
[`shutdown!`](@ref), and the default does nothing. The framework calls it as the
run shuts down, after the final snapshot (the immutable per-boundary
publication) is published and every [`wait_next_snapshot`](@ref) has been woken.
A device whose [`loop`](@ref) blocks in a call of its own, such as a socket
read, overrides it to make that call return, for example by closing the socket.

A throw the override provokes in the loop, once the run is stopping, is treated
as shutdown, not reported as `DeviceCrash`. A device that does not override
`unblock!` has nothing to provoke a throw, so any throw from its loop is a
crash. A throw inside `unblock!` itself is logged as a warning, and the device's
task can then end only through the `join_timeout` of its
[`Simulation`](@ref).
"""
unblock!(::AbstractDevice) = nothing

# Design: §11.6, §12.4, Appendix C, D-102, D-366.
# A device whose loop was never written would otherwise present as "attached,
# nothing happens", the hidden-bug class §11.6 tolerates nowhere, so `attach!`
# refuses it by name (`check_device`, roster.jl) before it is ever rostered:
# `DeviceContractMismatch`, service, fail-fast (Appendix C). This fallback
# exists only as the comparison target `which` needs to detect a device with no
# method of its own. It is unreachable, `attach!` having already refused, and
# its own throw says so.
"""
    loop(dev::AbstractDevice, handle)

Run the device's own body on its task for one run, the one function every
device must define.

A device type defines `loop(dev::MyDevice, handle)`. Each run calls it once, on
a task of its own, after every device's [`init!`](@ref) has returned, and passes
it the [`DeviceHandle`](@ref) that [`attach!`](@ref) returned. The body is the
device's own code: it reads, waits and stages through the handle, and loops
while [`running`](@ref) returns `true`, checking it between blocking calls. Each
blocking call must be one a stop can interrupt. [`wait_next_snapshot`](@ref)
returns at a stop, and [`unblock!`](@ref) makes the device's own blocking calls
return.

Whenever the body returns or throws, the framework runs [`shutdown!`](@ref). A
throw is reported as `DeviceCrash` into the device's diagnostic cell (the
per-writer cell holding runtime diagnostics), and the run goes on without the
device's task. A device that overrides [`unblock!`](@ref) may throw once the run
is stopping, and that throw counts as shutdown, not a crash. If the attachment
set `should_abort`, the body's end, by return or by throw, also requests a
stop. An interrupt (Ctrl-C) inside the body is a
stop, not a crash.

`attach!` refuses a device with no `loop` method of its own as
`DeviceContractMismatch`.
"""
loop(dev::AbstractDevice, handle) =
    throw(InternalInvariant("unreachable: attach! refuses a device with no loop method"))

# --- the handle primitives (§11.6) ---------------------------------------------

# Design: §11.6, §11.8, §12.2, §12.4.
# §12.4's exit predicate. Tail step (1) sets the sticky stopped status after
# the final snapshot. Every handle primitive a loop pass touches, this one,
# `latest`, `pending`, `stage!`, `wait_next_snapshot`, `gather` and `report!`,
# stores the liveness heartbeat on its way through (§11.8, §12.2): the
# framework observes activity without owning the loop body.
"""
    running(handle::DeviceHandle) -> Bool

Return `true` from the start of a run until the run stops, and `false`
otherwise.

A device's [`loop`](@ref) checks `running(handle)` between its blocking calls,
and returns once it reads `false`. It turns `false` only after the run's final
snapshot (the immutable per-boundary publication) is published, so a loop that
reads `false` may still read a complete final snapshot.

Each call refreshes the device's heartbeat (the liveness timestamp the framework
reads to judge a device alive), as every handle primitive a loop calls does. A
loop that calls the primitives needs no separate liveness signal.
"""
running(handle::DeviceHandle) =
    (_beat!(handle.diag_cell); !(@atomic handle.control.stopped))

# Design: §12.1, §12.4, D-203.
# The device's spelling of `stop!(sim)`, the device's name riding as the issuer.
# A second request loses the first-wins CAS.
"""
    stop!(handle::DeviceHandle) -> Nothing

Request a stop of the running loop, issued by the device, from any task.

`stop!` sets the stop word (the control plane's stop command, one atomic word
holding its issuer), with the device's name as the issuer. The loop sees it at
the next frame top (the start of a frame), completes that boundary, publishes
and shuts the run down. The source of the termination record (the value naming
how the run ended) is then a `ControlRequestedStop` naming the device. The
calling code issues the same stop with `stop!(sim)`.

The first issuer wins, so a later stop changes nothing. On a run that has
already stopped, `stop!` has no effect.
"""
stop!(handle::DeviceHandle) = _request_stop!(handle.control, handle.who)

# Design: §11.6.
# The handle carrying the binding is what keeps the device struct free of its
# per-deployment configuration.
"""
    binding(handle::DeviceHandle) -> AbstractBinding

Return the binding the device was attached under.

The binding (the value passed at `attach!` that makes a device
framework-legible) is an argument of [`attach!`](@ref), never a field of the
device. A device's [`loop`](@ref) reads it here to map its data, as in
`stage!(handle, map_input(datum, binding(handle))...)`. The framework never
calls [`map_input`](@ref) or [`map_output`](@ref) itself: they are the loop's
own calls.
"""
binding(handle::DeviceHandle) = handle.b

# Design: §11.6.
# An acquire load of the holder `latest(sim)` reads, through the capability the
# handle carries.
"""
    latest(handle::DeviceHandle) -> Union{Nothing,Snapshot}

Return the most recently published snapshot, or `nothing` before anything is
published.

The snapshot (the immutable per-boundary publication) is exactly the value
`latest(sim)` returns, read through the handle. To block until a newer one is
published, use [`wait_next_snapshot`](@ref).
"""
latest(handle::DeviceHandle) = (_beat!(handle.diag_cell); @atomic :acquire handle.published.latest)

# Design: §11.7, D-244.
# One acquire load of the staging cell, never a take. A batch is never mutated
# after it is published into the cell, since the CAS merge builds a new one, so
# the load sees a complete batch or none.
"""
    pending(handle::DeviceHandle, slot::Int) -> Union{Nothing,Some}

Return the device's own staged value at `slot`, wrapped in `Some`, or `nothing`
when none is pending.

`slot` is a face's position in the device's claim (the set of faces a device may
write), as the `slot` field of a view from [`port_views`](@ref) gives it. The
read takes nothing: the value stays in the staging cell (the holding place where
a pending batch waits) until the next frame top drains it. `Some` keeps "nothing
pending" apart from a pending value that is itself `nothing`. As a read,
`pending` stays legal after [`detach!`](@ref).
"""
function pending(handle::DeviceHandle, slot::Int)
    _beat!(handle.diag_cell)
    held = @atomic :acquire handle.writer.cell.pending
    held === nothing && return nothing
    held[].mask[slot] ? Some(held[].staged[slot]) : nothing
end

# Design: §11.4, §11.6, D-244.
# The same compiled shim, CAS merge and per-face newest-wins as every writer's,
# against this attachment's claim set, with every check at staging.
"""
    stage!(handle::DeviceHandle, writes::Pair...) -> Nothing

Stage a batch of root-input writes through the device's handle, from any task
at any moment.

Each write is a `"face" => value` pair naming a root input (the root component's
own input face) inside the device's claim. The claim is the set of faces a
device may write. The pairs form one batch (a device's staged set of face ⇒
value writes). The batch waits in the device's staging cell (the holding place
where a pending batch waits) and is applied at the top of the next frame
[`run!`](@ref) advances. Batches merge, the newest value winning per face, so a
face not staged again keeps its pending value. A loop usually stages what
[`map_input`](@ref) returns.

A face outside the claim is discarded as `OutOfClaimEntry`, which names the
device that claims it, if any. A value that does not convert to the face's type
is discarded as `EntryTypeMismatch`. The rest of the batch stands, and the
findings go to the device's diagnostic cell (the per-writer cell holding runtime
diagnostics), not to the caller. After [`detach!`](@ref), the call is refused as
`DeviceContractMismatch`. The calling code stages through the harness writer
with `stage!(sim, …)`.
"""
function stage!(handle::DeviceHandle, writes::Pair...)
    _assert_attached(handle)
    _beat!(handle.diag_cell)
    batch = _normalize(handle.writer, writes, handle.claimedby, handle.diag_cell; device = handle.who)
    batch === nothing || stage_batch!(handle.writer, batch)
    nothing
end

# Design: §11.2, §11.6, §12.3.
# The compiled reads run over the frozen store.
"""
    gather(handle::DeviceHandle, snapshot::Snapshot) -> NamedTuple

Return the binding's read set gathered from a snapshot, as the labeled
`NamedTuple` `map_output` receives.

The read set (the labeled selectors the binding's [`reads`](@ref) returns) is
resolved once, at [`attach!`](@ref). `gather` runs it over the snapshot (the
immutable per-boundary publication). The loop idiom is
`send(dev.socket, map_output(gather(handle, snapshot), binding(handle)))`, on
the device's own task, against the snapshot [`wait_next_snapshot`](@ref)
returned. No name is resolved per call, and nothing here touches the running
loop.

On a handle whose binding declares no output side, the call is refused as
`DeviceContractMismatch`.
"""
function gather(handle::DeviceHandle, snapshot::Snapshot)
    _beat!(handle.diag_cell)
    handle.gatherer === nothing && throw(DiagnosticError(
        DeviceContractMismatch(device = handle.who, reason = :no_output_side)))
    gather_reads(handle.gatherer, snapshot)
end

# Design: §11.6, §11.8.
# The single-writer entry point into the device's own diagnostic cell, bounded
# by `DIAG_RING`. No writer can starve another, since the cells are disjoint.
# The status record is delta plus totals (§11.8), and the run's-end sweep takes
# whatever landed past the last frame top.
"""
    report!(handle::DeviceHandle, occurrence::MalformedDatum) -> Nothing

Report a malformed datum into the device's diagnostic cell, and let the loop
continue.

A device's [`loop`](@ref) calls it after catching its own parser error: catch,
stage nothing, report, continue. The report lands in the device's diagnostic
cell (the per-writer cell holding runtime diagnostics). The next frame top folds
it into the framework status (the per-writer record each snapshot carries),
attributed to the device, and the run's end collects whatever lands after the
last frame top. The cell keeps 16 values per frame and counts the excess by
kind, so a peer flooding malformed data costs sixteen retained values and a
counter, whatever it sends.

`report!` is not a general diagnostics channel. `MalformedDatum(cause)` is the
one kind a device may report, and any exception the loop does not classify as a
malformed datum reaches the framework as the `DeviceCrash` it is. After
[`detach!`](@ref), the call is refused as `DeviceContractMismatch`.
"""
report!(handle::DeviceHandle, occurrence::MalformedDatum) =
    (_assert_attached(handle); _beat!(handle.diag_cell);
     report_cell!(handle.diag_cell, occurrence))

# Design: §12.4.
# `report!(entry, DeviceCrash(cause, abort))`, the framework's crash report,
# addressed by the roster entry. `RosterEntry` is internal, so the method has no
# docstring on the public `report!` page. The pre-spawn bracket holds no handle,
# and the wrapper writes the same cell. The report lands in the entry's own
# diagnostic cell. It asserts no attachment and beats no heartbeat: the device
# did not run or has just died, and a beat would claim life. `DeviceCrash` is
# the one kind filed this way.
report!(entry::RosterEntry, occurrence::DeviceCrash) =
    report_cell!(_handle(entry).diag_cell, occurrence)

# Design: §12.3.
# The predicate loop is the canonical idiom: the condition carries no facts, and
# the two that matter, the counter and the stopped status, are re-tested at
# every wake. That is what makes shutdown work: tail step (2) wakes every waiter
# and the predicate routes it out.
"""
    wait_next_snapshot(handle::DeviceHandle) -> Union{Nothing,Snapshot}

Block until an unseen boundary is published or the run stops, then return the
latest snapshot.

The snapshot (the immutable per-boundary publication) returned is at least the
one whose publication woke the wait. Beyond it the newest wins, so a slow
consumer skips boundaries and always receives the current one. A stop wakes the
wait too, so the device's [`loop`](@ref) checks [`running`](@ref) after it
returns, as after any blocking call. The call returns `nothing` only where
[`latest`](@ref) does, before anything is published.
"""
function wait_next_snapshot(handle::DeviceHandle)
    _beat!(handle.diag_cell)
    control = handle.control
    lock(control.wake)
    try
        while control.counter <= handle.last_seen && !(@atomic control.stopped)
            wait(control.wake)
        end
        handle.last_seen = control.counter
    finally
        unlock(control.wake)
    end
    latest(handle)
end

# --- the panel kit (§11.7, D-270) ----------------------------------------------

"""
§11.7's baked verdict for one port: the port's terminal producer (`("",
face)` when root-driven), whether this handle commands it, the position in
the handle's schema when it does (`0` otherwise), the producer's cell address
for the snapshot read, and the incumbent writer of a root-driven port the
handle does not command — another device's `who`, `"harness"` for a face no
device claims, `""` for a port no device writes. Built by `port_views`, once
per run; nothing here resolves a name at render.
"""
struct PortView
    path::String
    port::Symbol
    source::Tuple{String,Symbol}
    live::Bool
    slot::Int
    addr::CellAddr
    incumbent::String
end

# Design: §11.7, D-270, D-315.
# An input face's producer is the terminal one off `terminal_producer` (D-315).
# The loop's top is after the roster freeze, so the incumbents read off the
# exclusivity index are the run's. At `attach!` a face a later attach claims
# would still name the harness, and repairing that at render means reading the
# index at render, which §11.7 forbids (D-270).
"""
    port_views(handle::DeviceHandle) -> Dict{Tuple{String,Symbol},PortView}

Return the device's table of port views, one per port of the build, keyed by
`(path, port)`.

A port view (one port's verdict, settled once per run) records the port's
producer, whether the device commands it, and who writes it otherwise. The table
holds one view per input face at every level, the root inputs (the root
component's own input faces) and both ends of every wire, and one per produced
output: each component's outputs and every exported output face, the root's
included. An input face's producer is the
output or root input that ultimately feeds it, so an assembly's input face
shares its producer with the ports behind it. A root input and a produced output
are their own producers.

Each view carries these fields, beside the producer's address that
[`peek`](@ref) reads.

- `path` and `port`: the port the view describes.
- `source`: its producer, as `(path, port)`, with `("", face)` for a root input.
- `live`: `true` when the producer is a root input inside the device's claim
  (the set of faces a device may write), so the device commands the port.
- `slot`: that root input's position in the claim, as [`pending`](@ref) takes
  it, or `0` when the view is not live.
- `incumbent`: the writer of the root input that drives the port. It is this
  device's name when live, another device's name, `"harness"` for a face no
  device claims, or `""` when no root input drives the port.

A GUI device's loop calls `port_views` once, at its top, after the run has fixed
the roster (the list of attached device entries). Nothing is resolved by name
afterwards: [`peek`](@ref) and [`incumbent_status`](@ref) read a view and a
snapshot.
"""
function port_views(handle::DeviceHandle)
    faces = handle.writer.faces
    addr = handle.layout.addr
    function view_of(path, port_name, source)
        (producer_path, face) = source
        live = producer_path == "" && face in faces
        incumbent = live ? handle.who :
                    producer_path == "" ? get(handle.claimedby, face, "harness") : ""
        PortView(path, port_name, source, live, live ? findfirst(==(face), faces) : 0,
                 addr[source], incumbent)
    end
    views = Dict{Tuple{String,Symbol},PortView}()
    structure = handle.structure
    # A level's own input faces are the producers carrying its path, and every
    # consumer not carrying it is a child's input face.
    level_inputs = Tuple{String,Symbol}[("", face) for face in structure.root_inputs]
    for level in structure.levels, (producer, consumer) in level.wires
        first(producer) == level.path && push!(level_inputs, producer)
        first(consumer) == level.path || push!(level_inputs, consumer)
    end
    for (path, port_name) in level_inputs
        views[(path, port_name)] =
            view_of(path, port_name, terminal_producer(structure, (path, port_name)))
    end
    root_inputs = Symbol[f for (f, _) in handle.layout.root_inputs]
    for key in keys(addr)
        (path, port_name) = key
        path == "" && port_name in root_inputs && continue
        views[key] = view_of(path, port_name, key)
    end
    views
end

# Design: §11.7, D-270.
# §11.7's peek rule. The window after the drain is the rule's own consequence
# (D-270).
"""
    peek(view::PortView, handle::DeviceHandle, snapshot::Snapshot)

Return the value a widget shows for a port: the device's own pending write if
any, else the snapshot's.

A live view (one whose port the device commands) shows the device's own staged
value, read with [`pending`](@ref), while one is pending. Otherwise it shows the
producer's value in the snapshot (the immutable per-boundary publication). A
view that is not live reads the snapshot alone. Between a frame's drain (the
frame-top point that applies the staged writes) and its publication, a view
shows the previous snapshot's value.
"""
function peek(view::PortView, handle::DeviceHandle, snapshot::Snapshot)
    if view.live
        staged = pending(handle, view.slot)
        staged === nothing || return something(staged)
    end
    gather_cell(snapshot.store, view.addr)
end

# Design: §11.7, §11.8, §12.2.
"""
    incumbent_status(view::PortView, snapshot::Snapshot) -> Union{Nothing,WriterStatus}

Return the status record of the writer that drives a view's port, or `nothing`
when no writer does.

The record is the incumbent's entry in the snapshot's framework status (the
per-writer diagnostics and liveness each snapshot carries), found by the view's
`incumbent` name. Read it with [`orphaned`](@ref), true when the incumbent's
task returned or crashed, and [`stale`](@ref), true when its heartbeat (the
liveness timestamp its handle calls refresh) has gone silent.
"""
function incumbent_status(view::PortView, snapshot::Snapshot)
    isempty(view.incumbent) && return nothing
    i = findfirst(w -> w.who == view.incumbent, snapshot.status.writers)
    i === nothing ? nothing : snapshot.status.writers[i]
end

# Design: §11.7, §12.2.
# The record's `task_state` reads `:done`. `:none` outside a run is not
# orphaned, nor the harness's or the loop's `nothing`.
"""
    orphaned(record::WriterStatus) -> Bool

Return `true` when the record's device has no live task inside a run.

A device is orphaned when its loop returned or crashed, or its `init!` threw.
The record's `DeviceCrash` count tells a crash from a return. Outside a run a
device has no task and is not orphaned, and the records of the harness writer
and of the loop are never orphaned.
"""
orphaned(record::WriterStatus) = record.task_state === :done

# --- the wrapper and the spawn (§11.6, §12.4) -----------------------------------

# The guarded release: `shutdown!` is guaranteed on every exit path, and a
# throw out of it must not wreck the bracket or the tail around it (§11.6). An
# interrupt cutting it short is the operator's stop, forwarded through the stop
# word as the wrapper forwards one (§12.4, D-268).
function _shutdown!(entry::RosterEntry)
    try
        shutdown!(entry.dev)
    catch err
        if err isa InterruptException
            @warn "shutdown! of $(_who(entry)) was interrupted; its resources may leak (§11.6, §12.4)"
            _request_stop!(entry.handle.control, :interrupt)
        else
            @warn "shutdown! of $(_who(entry)) threw; its resources may leak (§11.6)" #=
                =# exception = (err, catch_backtrace())
        end
    end
    nothing
end

"""
The framework wrapper (§11.6): the author owns the loop body, the framework
owns the bracket. Every exit path — voluntary return, a crash, the
stop-drained predicate — runs `shutdown!` and then consults the attachment's
`should_abort`; a crash is caught here and reported as `DeviceCrash` into
the device's own diagnostic cell (§11.8, §12.4(6)) — on the device's task,
the cell's writer — the run continuing with the device's task absent and its
claims held to run end. Death is marked nowhere beyond the record: the task has
ended, `task_state` says so at the next publication, and the heartbeat goes
stale (§12.2).
"""
# Does the device override `unblock!`? Read as `check_device` reads `loop`
# (roster.jl): the default method is the comparison target.
_unblocks(dev::AbstractDevice) =
    which(unblock!, Tuple{typeof(dev)}) !== which(unblock!, Tuple{AbstractDevice})

function _wrap(entry::RosterEntry)
    try
        loop(entry.dev, entry.handle)
    catch err
        if err isa InterruptException
            # The wrapper's first discrimination (§11.6, D-132): the operator's
            # stop, raised inside a body that did nothing wrong, is forwarded
            # through the stop word — an earlier issuer keeps it — and never
            # reported as a crash. The abort consult below is inert after it.
            _request_stop!(entry.handle.control, :interrupt)
        else
            # A raise after the sticky stop, from a device overriding `unblock!`,
            # is the one the override provoked — its blocking call returning by
            # throwing — and is shutdown, not a crash (§12.4(3)). A device with
            # no override has nothing to provoke it, so its raise is a crash
            # whenever it lands.
            unblocked = (@atomic entry.handle.control.stopped) && _unblocks(entry.dev)
            unblocked || report!(entry, DeviceCrash(err, entry.should_abort))
        end
    finally
        _shutdown!(entry)
        entry.should_abort && stop!(entry.handle)
    end
    nothing
end

# The spawn (§12.4): each handle's `last_seen` refreshed so the run's first wait
# observes that run's boundaries, then one task per live entry running the wrapper.
function _spawn!(entries::Vector{RosterEntry})
    for entry in entries
        entry.handle.last_seen = entry.handle.control.counter
    end
    [Threads.@spawn _wrap(entry) for entry in entries]
end

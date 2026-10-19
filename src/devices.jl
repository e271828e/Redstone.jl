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

"""
The handle (§11.6): the one object every attached device receives, carrying
exactly the primitive capabilities — read (`latest`, `wait_next_snapshot`),
stage (`stage!`) and control access (`running`, `stop!`) — and deliberately
*not* the `Simulation`: what a device may touch is what the handle holds.
Of the plane it holds the exclusivity index alone, the `Dict` `stage!` checks
a face against, never the plane itself (D-261). `attach!` constructs it and
returns it, and the same handle is what the wrapper passes to
`loop(dev, handle)` on the device's task. It also carries the attachment's
binding, read back by `binding(handle)`: the loop's own
`map_input`/`map_output` calls take it from the handle instead of the device
carrying its configuration (§11.6). The stable device id is the roster
entry's (§12.4); the handle's `who` renders it. `last_seen` is the §12.3
waiter's private register, refreshed at spawn so a run's first wait observes
that run's boundaries. `detached` is D-244's flag: the handle outlives its
roster entry as an object only, and `detach!` sets the flag so that the two
write primitives, `stage!` and `report!`, refuse by name instead of landing
in a cell no drain reads — one atomic load per stage, no roster scan. The
reads stay legal. It holds the build's `Structure` and the nominal `Layout`
by reference, like the index, for the panel kit's bake alone: `port_views`
reads the wiring, the claim, the exclusivity index and the addresses off the
handle (§11.7, D-270). Its type carries the binding's and the gatherer's
types, so `binding(handle)` and `gather(handle, snapshot)` are statically
typed inside a device's `loop` and allocate nothing.
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

"""
The authoring contract: four functions, one optional. `init!` and `shutdown!` are the per-run
resource bracket, with no-op defaults — a stub device holds nothing — and
`shutdown!` must tolerate a partially initialized device: it is guaranteed
on every exit path, the failed-`init!` bracket included. `unblock!` is
§12.4(3)'s optional hook, default no-op: an override makes the device's own
blocking call return. `loop` is the one mandatory function — the
author-owned task body, looping on `running(handle)` with interruptible
blocking. A device whose loop was never written would otherwise present as
"attached, nothing happens", the hidden-bug class §11.6 tolerates nowhere, so
`attach!` refuses it by name (`check_device`, roster.jl) before it is ever
rostered — `DeviceContractMismatch`, service, fail-fast (Appendix C). This
fallback exists only as the comparison target `which` needs to detect a
device with no method of its own; it is unreachable, `attach!` having already
refused, and its own throw says so.
"""
init!(::AbstractDevice) = nothing
shutdown!(::AbstractDevice) = nothing
unblock!(::AbstractDevice) = nothing
loop(dev::AbstractDevice, handle) =
    throw(InternalInvariant("unreachable: attach! refuses a device with no loop method"))

# --- the handle primitives (§11.6) ---------------------------------------------

"""
    running(handle)

§12.4's exit predicate: true from a run's start until tail step (1) sets the
sticky stopped status — after the final snapshot, so a body observing false
may still read a complete final world. The author's loop obligation is to
check it between blocking points (§11.6).

Every handle primitive that a loop pass touches — this one, `latest`,
`pending`, `stage!`, `wait_next_snapshot`, `gather`, `report!` — stores the
liveness heartbeat on its way through (§11.8, §12.2): the framework observes
activity without owning the loop body, and there is no separate liveness
channel to remember to feed.
"""
running(handle::DeviceHandle) =
    (_beat!(handle.diag_cell); !(@atomic handle.control.stopped))

"""
    stop!(handle)

Request a control-plane stop (§12.1): sets the stop word from any task, the
device's name riding as its issuer into the termination record (D-203); the
loop observes it at the next frame top, completes that boundary, publishes,
and enters the tail (§12.4). Idempotent — a second request loses the CAS and
changes nothing — and inert while already stopped.
"""
stop!(handle::DeviceHandle) = _request_stop!(handle.control, handle.who)

"""
    binding(handle)

The attachment's binding (§11.6), for the author-owned loop idiom —
`stage!(handle, map_input(datum, binding(handle))...)`. The framework never
calls `map_input`/`map_output` itself: they are conventions of the loop
body, and the handle carrying the binding is what keeps the device struct
free of its per-deployment configuration (the binding stays an `attach!`
argument, never a device field).
"""
binding(handle::DeviceHandle) = handle.b

"""
    latest(handle)

The handle's primitive read (§11.6): acquire-load the most recently published
snapshot — exactly `latest(sim)`, through the capability the handle carries.
"""
latest(handle::DeviceHandle) = (_beat!(handle.diag_cell); @atomic :acquire handle.published.latest)

"""
    pending(handle, slot) → Some(value) | nothing

The handle's own staged value at `slot`, a position in its schema (§11.7):
one acquire load of the staging cell, never a take. A batch is never mutated
after it is published into the cell — the CAS merge builds a new one — so
the load sees a complete batch or none. `Some` keeps "nothing pending" apart
from a pending `nothing`. A read, so it stays legal on a detached handle
(D-244).
"""
function pending(handle::DeviceHandle, slot::Int)
    _beat!(handle.diag_cell)
    held = @atomic :acquire handle.writer.cell.pending
    held === nothing && return nothing
    held[].mask[slot] ? Some(held[].staged[slot]) : nothing
end

"""
    stage!(handle, "face" => value, ...)

The handle's stage primitive (§11.6, §11.4): the same compiled shim, CAS
merge and per-face newest-wins as every writer's, against this attachment's
claim set — every check at staging, an out-of-claim face discarded under
`OutOfClaimEntry` naming the incumbent, the rest of the batch standing. From
any task, at any wall-clock moment; the batch lands at the top of the next
frame `run!` advances. On a handle whose device was detached the call is a
contract misuse and throws by name (D-244).
"""
function stage!(handle::DeviceHandle, writes::Pair...)
    _assert_attached(handle)
    _beat!(handle.diag_cell)
    batch = _normalize(handle.writer, writes, handle.claimedby, handle.diag_cell; device = handle.who)
    batch === nothing || stage_batch!(handle.writer, batch)
    nothing
end

"""
    gather(handle, snapshot)

The output side's read (§11.2, §11.6): run the attachment's compiled gather —
`reads(b)`, resolved at attach — over a snapshot, returning the labeled
NamedTuple `map_output` receives. The loop idiom is
`send(dev.socket, map_output(gather(handle, snapshot), binding(handle)))`, on the
device's own task, against the snapshot §12.3's wait handed it: the compiled
reads run over the frozen store, so no name is resolved per datum and nothing
here touches the running loop. On a handle whose binding declares no output
side the call is a contract misuse, and throws by name.
"""
function gather(handle::DeviceHandle, snapshot::Snapshot)
    _beat!(handle.diag_cell)
    handle.gatherer === nothing && throw(DiagnosticError(
        DeviceContractMismatch(device = handle.who, reason = :no_output_side)))
    gather_reads(handle.gatherer, snapshot)
end

"""
    report!(handle, MalformedDatum(cause))

The bad-datum channel (§11.6, §11.8): the single-writer entry point into the
device's own diagnostic cell, from the author's loop body after catching its
own parser error — catch, stage nothing, report, continue. The tolerance is
bounded by the cell (`DIAG_RING` retained values per frame, the excess a
per-kind count), so a peer flooding malformed datagrams costs sixteen
retained values and an integer increment, whatever it does, and no writer can
starve another — the cells are disjoint. This is not a general
user-diagnostics channel: `MalformedDatum` is the one thing the *author* may
put in it, and any exception the loop does *not* classify as a bad datum
propagates to the wrapper as the `DeviceCrash` it is. The loop drains the
cell at frame top, folding it into the published framework status —
device-attributed, delta plus totals (§11.8) — and sweeps it once more at the
run's end for whatever landed past the last frame top.
"""
report!(handle::DeviceHandle, occurrence::MalformedDatum) =
    (_assert_attached(handle); _beat!(handle.diag_cell);
     report_cell!(handle.diag_cell, occurrence))

"""
    report!(entry, DeviceCrash(cause, abort))

The framework's crash report, addressed by the roster entry (§12.4). The
pre-spawn bracket holds no handle, and the wrapper writes the same cell. The
report lands in the entry's own diagnostic cell. It asserts no attachment and
beats no heartbeat: the device did not run or has just died, and a beat would
claim life. `DeviceCrash` is the one kind filed this way.
"""
report!(entry::RosterEntry, occurrence::DeviceCrash) =
    report_cell!(_handle(entry).diag_cell, occurrence)

"""
    wait_next_snapshot(handle)

§12.3's next-snapshot wait: block until a boundary this waiter has not seen
is published, or until the run stops, and return the latest snapshot — at
least the boundary whose publication woke the wait, newest-wins beyond it (a
slow consumer skips boundaries and always receives the current world). The
predicate loop is the canonical idiom: the condition carries no facts, and
the two that matter — the counter and the stopped status — are re-tested at
every wake, which is what makes shutdown work: tail step (2) wakes every
waiter and the predicate routes it out. After a stop return the author's
loop re-checks `running(handle)`, exactly as after any blocking call.
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

"""
    port_views(handle) → Dict{Tuple{String,Symbol},PortView}

§11.7's port table, keyed by `(path, port)`: one view per input face at
every level, the root inputs and the endpoints of every level's wires, its
producer the terminal one off `terminal_producer` (D-315), and
one per produced cell — each primitive's outputs and every exported output
face, the root's included — with itself as producer. An assembly's input face
shares its producer with the ports behind it, and a root input's own view has
itself as producer. A port is live when its producer is a root input inside
the handle's claim, and its slot is that face's position in the handle's
schema.

The GUI's loop body calls it once, at its top (§11.7). That point is after
the roster freeze, so the incumbents read off the exclusivity index are the
run's; at `attach!` a face a later attach claims would still name the
harness, and repairing that at render means reading the index at render,
which §11.7 forbids (D-270).
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

"""
    peek(view, handle, snapshot)

§11.7's peek rule: a live view's own pending value when one is touched, else
the producer's cell off `snapshot`; a read-only view reads the cell alone.
The window between a frame's drain and its publication shows the previous
snapshot's value, the rule's own consequence (D-270).
"""
function peek(view::PortView, handle::DeviceHandle, snapshot::Snapshot)
    if view.live
        staged = pending(handle, view.slot)
        staged === nothing || return something(staged)
    end
    gather_cell(snapshot.store, view.addr)
end

"""
    incumbent_status(view, snapshot) → WriterStatus | nothing

The incumbent's record in `snapshot`'s status, by `who`, or `nothing` for a
port no device writes (§11.7, §11.8). `orphaned` on the record is a task
that returned or crashed; `stale` is §12.2's silent heartbeat.
"""
function incumbent_status(view::PortView, snapshot::Snapshot)
    isempty(view.incumbent) && return nothing
    i = findfirst(w -> w.who == view.incumbent, snapshot.status.writers)
    i === nothing ? nothing : snapshot.status.writers[i]
end

"""
    orphaned(record::WriterStatus)

§11.7's orphan fact: the record reads `:done`, a device with no live task
inside a run (§12.2) — its loop returned or crashed, or its `init!` threw.
The record's `DeviceCrash` count tells a crash from
a return. `:none` outside a run is not orphaned, nor the harness's or the
loop's `nothing`.
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

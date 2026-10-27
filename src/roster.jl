# The roster and claims (§11.3), with the attach-point slice of §11.6's device
# contract: the periphery's two roots, the declared sides, the enumeration
# contract with its bidirectional conformance check, the three-part admission,
# both claim sources, and the harness writer as the derived remainder. The
# task side of the contract — the handle, the wrapper and the spawn — lives
# in devices.jl and the run's bracket and tail in sim.jl, the trace whose
# schema list the roster's writers grow in trace.jl; the binding conventions
# live in bindings.jl and the compiled reader in readers.jl.
#
# This file holds the types and the pure mechanics; `attach!`/`detach!` and
# the staging entry points live in sim.jl, beside the loop whose frames they
# configure.

# Design: §11.3, §11.6.
# The periphery's two roots, one mandatory word each, buying `attach!`'s
# dispatch gate. The library's stub devices are mutable structs because an
# immutable stub would be egal to its field-for-field twin, and `===` would
# stop meaning identity.
"""
    AbstractDevice

The abstract type every [device](@ref g-device) subtypes, the root of the device
authoring contract.

A device is a user type, `MyDevice <: AbstractDevice`, added to a simulation
with [`attach!`](@ref). It defines [`loop`](@ref), the one mandatory function,
and optionally the hooks [`init!`](@ref), [`shutdown!`](@ref) and
[`unblock!`](@ref).

A device's identity is its instance, compared by `===`. One object may hold at
most one [roster](@ref g-roster) entry. Two instances of one type, such as two
joysticks, are two devices. Two immutable instances whose fields are themselves
`===` are `===`, so they count as one device.

The device is attached under a [binding](@ref g-binding), which stays an
`attach!` argument and is never a device field. The same device binds
differently per deployment, and narrowing the binding narrows the
[claim](@ref g-claim). See [`AbstractBinding`](@ref).
"""
abstract type AbstractDevice end

# Design: §11.3, §11.6.
"""
    AbstractBinding

The abstract type every [binding](@ref g-binding) subtypes.

A binding is a value of a user type, `MyBinding <: AbstractBinding`, passed to
[`attach!`](@ref) beside the [device](@ref g-device). It declares the device's
sides with two `Bool` traits, [`is_input`](@ref) and [`is_output`](@ref), both
`false` by default, and each declared side carries its own methods.

- The input side: [`claims`](@ref) names the [faces](@ref g-face) the device may
  write, or [`is_greedy`](@ref) asks for every face still unclaimed. The loop's
  [`map_input`](@ref) turns a datum into writes.
- The output side: [`reads`](@ref) names what the device reads from each
  [snapshot](@ref g-snapshot). The loop's [`map_output`](@ref) turns the
  gathered values into the device's output.

The binding stays an `attach!` argument, never a device field, so the same
device binds differently per deployment, and narrowing the binding narrows the
[claim](@ref g-claim). [`TableBinding`](@ref) is the shipped data-driven
binding.

`attach!` checks the traits against the methods. A binding that declares
neither side, a declared side without its method, or a method under a `false`
trait is refused as `BindingContractMismatch`.
"""
abstract type AbstractBinding end

# Design: §11.3, §11.6.
# The declared sides and the claim source. Sides are declared, never inferred:
# the root carries the false defaults, so silence means absent. `is_greedy`
# selects the computed claim source within the input side (§11.3), and has its
# own docstring below.
"""
    is_input(b::AbstractBinding) -> Bool

Return whether the [binding](@ref g-binding) declares the input side, `false`
unless its type defines a method.

A binding with an input side defines `is_input(::MyBinding) = true`, and a
[`claims`](@ref) method naming the [faces](@ref g-face) it may write unless it
declares [`is_greedy`](@ref). Sides are declared, never inferred: a binding
whose type defines no `is_input` method has no input side, whatever else it
defines.

[`attach!`](@ref) refuses a binding that defines `claims` without declaring the
input side as `BindingContractMismatch`. See [`is_output`](@ref) for the output
side.
"""
is_input(::AbstractBinding) = false

# Design: §11.6.
"""
    is_output(b::AbstractBinding) -> Bool

Return whether the [binding](@ref g-binding) declares the output side, `false`
unless its type defines a method.

A binding with an output side defines `is_output(::MyBinding) = true` and a
[`reads`](@ref) method naming what it reads from each
[snapshot](@ref g-snapshot). Sides are declared, never inferred: a binding whose
type defines no `is_output` method has no output side, whatever else it
defines.

[`attach!`](@ref) refuses a binding that defines `reads` without declaring the
output side as `BindingContractMismatch`. See [`is_input`](@ref) for the input
side.
"""
is_output(::AbstractBinding) = false

# Design: §11.3, §11.6.
"""
    is_greedy(b::AbstractBinding) -> Bool

Return whether the [binding](@ref g-binding) [claims](@ref g-claim) every
[face](@ref g-face) still unclaimed at attach, `false` by default.

`is_greedy` selects where an input-side binding's claim comes from. A greedy
binding's claim is computed by [`attach!`](@ref): every
[root input](@ref g-root-input) no [device](@ref g-device) already attached has
claimed. It is computed once and never recomputed, so attachment order decides
it, and a greedy device is best attached last. An empty remainder is legal and
warns `EmptyGreedyClaim`.

A greedy binding declares [`is_input`](@ref) and defines no [`claims`](@ref)
method. `attach!` refuses a greedy binding without the input side, or one that
also defines `claims`, as `BindingContractMismatch`.
"""
is_greedy(::AbstractBinding) = false

# Design: §11.6.
# The enumeration contract. The root's fallback is error-throwing, so a declared
# side whose method was never written fails loudly at the attach point rather
# than degrading into silence. The enumeration contract has one meaning and the
# `is_greedy` trait carries the other, so the maximal surface stays reachable
# only through an explicit declaration.
"""
    claims(b::AbstractBinding)

Return the [root-input](@ref g-root-input) [faces](@ref g-face) an input-side
[binding](@ref g-binding) may write, called once at attach.

A binding that declares [`is_input`](@ref) defines `claims` for its type,
returning the face names as strings or symbols. [`attach!`](@ref) calls it once
and stakes what it names as the [device](@ref g-device)'s [claim](@ref g-claim).
Duplicates collapse, and an empty collection is a legal claim to write nothing.
`claims` never returns a value meaning "every remaining face": a binding
declares [`is_greedy`](@ref) for that.

A binding that declares the input side, is not greedy and defines no `claims`
method is refused at attach as `BindingContractMismatch`. A face that names no
root input is refused as `AttachUnknownFace`, and a face another device already
claims as `ClaimConflict`.
"""
claims(b::AbstractBinding) = throw(DiagnosticError(
    BindingContractMismatch(binding = _typename(b), reason = :claims_missing)))

# Design: §11.6, §14.4.
# The output side's enumeration, compiled at attach to one gather. The root's
# fallback is error-throwing for the same reason `claims`'s is: a declared side
# whose method was never written fails loudly at the attach point rather than
# degrading into silence.
"""
    reads(b::AbstractBinding) -> NamedTuple

Return the [read set](@ref g-read-set) the [binding](@ref g-binding)'s output
side gathers from each [snapshot](@ref g-snapshot).

A binding that declares [`is_output`](@ref) defines `reads` for its type. Its
read set is a `NamedTuple` of labeled [selectors](@ref g-selector), such as
`(; speed = get_output("plant", :v))`, and the labels key the `NamedTuple` that
[`gather`](@ref) returns and [`map_output`](@ref) receives. [`attach!`](@ref)
calls it once and resolves it against the build, so a binding that no longer
matches its model fails at attach rather than sending wrong values.

A binding that declares the output side and defines no `reads` method is
refused at attach as `BindingContractMismatch`, as is a value that is not a
`NamedTuple` of selectors. A selector that does not resolve is refused as
`ReadResolution`, or as `PathResolution` when its path names no
[component](@ref g-component). The keyword method, `reads(; selectors...)`,
builds the read set a service such as [`series`](@ref) takes.
"""
reads(b::AbstractBinding) = throw(DiagnosticError(
    BindingContractMismatch(binding = _typename(b), reason = :reads_missing)))

"""
§11.6's bidirectional conformance check over each (trait, method) pair, run
at the attach point: the same fact stated twice, in two forms, with the
framework paid to compare them. The declared-but-missing direction is the
`claims`/`reads` fallback firing when the attach calls it; the
defined-but-undeclared direction is one `which` against that fallback — the
reflection class, run at a stopped-sim service point, never inside a frame.
Greediness stays orthogonal to `reads`: a greedy front end driving a compiled
output gather is legal and currently uninstantiated (§11.6).
"""
function check_binding(b::AbstractBinding)
    binding_type = typeof(b)
    input_side, output_side, greedy = is_input(b), is_output(b), is_greedy(b)
    claims_drifted = which(claims, Tuple{binding_type}) !== which(claims, Tuple{AbstractBinding})
    reads_drifted = which(reads, Tuple{binding_type}) !== which(reads, Tuple{AbstractBinding})
    greedy && !input_side && throw(DiagnosticError(
        BindingContractMismatch(binding = _typename(binding_type), reason = :greedy_without_input)))
    input_side || output_side || throw(DiagnosticError(
        BindingContractMismatch(binding = _typename(binding_type), reason = :neither_side)))
    input_side && greedy && claims_drifted && throw(DiagnosticError(
        BindingContractMismatch(binding = _typename(binding_type), reason = :greedy_with_claims)))
    input_side || !claims_drifted || throw(DiagnosticError(
        BindingContractMismatch(binding = _typename(binding_type), reason = :claims_without_input)))
    output_side || !reads_drifted || throw(DiagnosticError(
        BindingContractMismatch(binding = _typename(binding_type), reason = :reads_without_output)))
    nothing
end

"""
§11.6's device twin of `check_binding`, run at the same attach point: a
device with no `loop` method of its own is a build-time configuration
mistake — `loop`'s fallback exists only as the comparison target this `which`
check needs, and refusing here (before the device is ever rostered, let alone
spawned) is what makes `DeviceContractMismatch` `service, fail-fast` rather
than a task-side `DeviceCrash` (Appendix C).
"""
function check_device(dev::AbstractDevice, b::AbstractBinding)
    device_type = typeof(dev)
    # against the handle type the wrapper calls with, which carries the binding's
    # type: a `loop(::device_type, ::DeviceHandle)` is a method, one narrowed on
    # the binding is too, and `Tuple{device_type,Any}` would see neither
    handle_type = DeviceHandle{typeof(b)}
    which(loop, Tuple{device_type,handle_type}) ===
        which(loop, Tuple{AbstractDevice,handle_type}) &&
        throw(DiagnosticError(DeviceContractMismatch(
            device = _typename(device_type), reason = :no_loop)))
    nothing
end

"""
One roster entry (§11.3): the device instance, the stable id assigned at
`attach!` — monotonic per `Simulation`, never reused, living exactly as long
as the entry — the entry's drain thunk, the per-attachment `should_abort`
policy (§11.6: never a device property — the same joystick is advisory in one
deployment and essential in another), the loop's account, and the handle
`attach!` constructed and returned. The binding, the compiled writer over the
claim set and the device's diagnostic cell are the handle's, read through it
(D-261): what survives a stop, binding, claims and stable device id (§12.4),
survives on the entry through its handle.
Past the attach point nothing distinguishes a computed claim from a returned
one: the source is exhausted there, and validation, storage and the drain
treat the two identically.
"""
struct RosterEntry
    dev::AbstractDevice
    id::Int
    drain::Function                 # the compiled (cell, scatter) pair as a callable, see _drain_thunk
    should_abort::Bool              # the per-attachment failure policy (§11.6, §12.4)
    account::WriterAccount          # the loop's private account behind the cell (§11.8)
    handle::Any                     # the DeviceHandle; `Any` for include order only
end

# The entry's handle, read typed: `DeviceHandle` is defined after this file, so
# the field is `Any` and every reader pays the assert here, on the frame top
# too. The assert names the handle's family, not one of its types, so a field
# read behind it is a runtime lookup. It allocates nothing.
_handle(entry::RosterEntry) = entry.handle::DeviceHandle

# The handle's own name, read typed: a fresh string per publication would be
# an allocation on the quiet frame (§11.8).
_who(entry::RosterEntry) = _handle(entry).who

# The stopped-sim compile of one writer's drain (§11.4): a zero-argument thunk
# capturing the store and the writer *concretely* — this dynamic dispatch is
# what specializes the closure — so the frame top's call boxes no argument and
# the drain, empty or populated, stays allocation-free (D-202). The per-entry
# dispatch this leaves is
# the iteration §11.4 licenses in place of the tuple specialization the freeze
# would also permit. The run's trace and this writer's index into its schema
# list ride along (§11.5, D-260), which is why every thunk is compiled at one
# site alone — `_install_writers!` below — and recompiled whenever the
# indices move. `trc` is concrete in the closure, a `Trace` or `nothing`, so
# the record branch inside `_drain!` folds where there is nothing to record.
_drain_thunk(store, writer::Writer, trc, writer_index::Int) =
    () -> _drain!(store, writer, trc, writer_index)

# The thunk a plane and a fresh entry hold before a door or a roster change
# compiles one (D-261): nothing drains before boundary zero has run, so a call
# here is a lifecycle invariant broken, not a device's fault.
_no_drain() = throw(InternalInvariant("drain thunk called before a door compiled it"))

"""
The data plane's mutable holder: the roster in attachment order — which is the
drain's application order — the harness writer and its drain thunk, the
exclusivity index behind the `ClaimedFaceEntry` payload, and the id counter;
the §11.3 freeze itself is the lifecycle's `:running` state (devices.jl).
Mutable and abstractly typed deliberately: the harness writer's *type*
changes at every roster change (its schema is recompiled), so it cannot be a
`Simulation` type parameter, and everything here is stopped-sim configuration
read behind function barriers.

The harness writer owns a diagnostic cell and its
account like any other (§11.8, D-200: it is a
diagnostic writer, its staging diagnostics needing a single-writer home).
Unlike the writer, the cell
survives roster changes: its diagnostics are the harness's, whatever surface
it speaks for. `run_tasks` is the run's device-id → `Task` registry, filled
at spawn and emptied at run end, which is what lets `publish!` read
`task_state` off the handles the loop owns (D-193); the inline body's entry
leaves when that body returns, under `wake`'s lock, since the loop reads the
registry as it publishes. A device absent from it reads `:done` inside a run
and `:none` outside one — device tasks are run-scoped observables (§12.2,
§12.4).

The trace the drain writes into is the run's (§11.5, D-260) and the store it
scatters into is the executor's: both are closed into every thunk rather than
held on the plane. The plane compiles no thunk at construction (D-261): a door
or a roster change compiles them, at `_install_writers!` alone, which takes
the store and the run's trace as arguments, and `harness_drain` holds the
`_no_drain` sentinel until the first does.

The loop is a diagnostic writer too, so its cell and account are the plane's
(§11.8, D-256), and `published` is §11.2's holder, read by `latest(sim)` and
by every device handle.
"""
mutable struct DataPlane
    roster::Vector{RosterEntry}     # attachment order (§11.3): the drain applies in it
    harness::Writer                 # the derived-surface writer, recompiled at roster changes
    harness_drain::Function         # its drain thunk, recompiled with it
    harness_diag::DiagCell          # the harness writer's diagnostic cell (§11.8)
    harness_account::WriterAccount  # and the account behind it
    loop_diag::DiagCell             # the loop's own diagnostic cell (§11.8)
    loop_account::WriterAccount     # and the account behind it
    published::Published            # §11.2's `@atomic latest` holder
    run_tasks::Dict{Int,Task}       # the run's device tasks, by device id (§12.2, D-193)
    claimedby::Dict{Symbol,String}  # face → incumbent: the exclusivity index
    next_id::Int
end

function DataPlane(layout::Layout)
    harness = Writer(layout, Symbol[f for (f, _) in layout.root_inputs])
    DataPlane(RosterEntry[], harness, _no_drain, DiagCell(EMPTY_DIAG),
              WriterAccount(), DiagCell(EMPTY_DIAG), WriterAccount(), Published(nothing),
              Dict{Int,Task}(), Dict{Symbol,String}(), 1)
end

"""
The claim, from its source (§11.3): computed — `is_greedy`, the unclaimed
complement at this instant, disjoint from every incumbent by construction and
never recomputed, which is what makes attachment order decisive — or
returned, the enumeration called once, each face validated against the root
face set (`AttachUnknownFace`: a mapping drifted onto a nonexistent face is a
diagnosable anomaly, never a silent write). Duplicates within one enumeration
collapse; the empty enumeration is the honest may-write-nothing degenerate.
"""
function _claim(plane::DataPlane, layout::Layout, b::AbstractBinding, device::String)
    face_set = Symbol[f for (f, _) in layout.root_inputs]
    is_greedy(b) && return Symbol[f for f in face_set if !haskey(plane.claimedby, f)]
    claim = Symbol[]
    for claimed in claims(b)
        face = Symbol(claimed)
        face in face_set || throw(DiagnosticError(
            AttachUnknownFace(device = device, binding = _typename(b), face = face,
                              candidates = face_set)))
        face in claim || push!(claim, face)
    end
    claim
end

"""
Recompute the exclusivity index and recompile the harness writer
after a roster change (§11.3, §11.4): the harness surface is the unclaimed
complement — the faces no rostered device speaks for — so it moves exactly
when the roster does, and is as fixed within a run as any claim set. Being
always present, the harness cell gets the compilation unasked.

The recompilation has one seam (§11.4): a pending harness batch staged before
a stopped-sim `attach!` may hold the old shape, or may name a face the new
claim covers. The batch is taken, reshaped through the new schema and
re-staged — newly claimed faces discarded with `ClaimedFaceEntry` — so the run
always starts with cells matching the run's schemas. At `detach!` the surface
only broadens and every pending entry survives the reshape.

The roster change is also where the trace's schema list grows (§11.5): the
current writer set is appended and every drain thunk recompiled against its
new index, which is what `_install_writers!` does at the tail here. The store
the thunks scatter into and the trace they grow are the executor's and the
current run's, passed in by `attach!` and `detach!` (D-260, D-261).
"""
function reclaim!(plane::DataPlane, layout::Layout, store, trc)
    empty!(plane.claimedby)
    for entry in plane.roster, face in _handle(entry).writer.faces
        plane.claimedby[face] = _who(entry)
    end
    old = plane.harness
    taken = @atomicswap old.cell.pending = nothing
    harness = Writer(layout, Symbol[f for (f, _) in layout.root_inputs
                                    if !haskey(plane.claimedby, f)])
    plane.harness = harness
    _install_writers!(plane, store, trc)   # §11.5: the schema list grows, the thunks follow
    if taken !== nothing
        batch = taken[]
        entries = [old.faces[i] => batch.staged[i] for i in 1:length(old.faces) if batch.mask[i]]
        renormalized = _normalize(plane.harness, entries, plane.claimedby, plane.harness_diag;
                                  site = :renormalization)
        renormalized === nothing || stage_batch!(plane.harness, renormalized)
    end
    nothing
end

# The run's writers in the drain's own order (§11.3, §11.4): each rostered
# device in attachment order, then the harness writer. The tags are §11.8's
# writer names, so a trace and a published status name a writer identically.
function _writer_schemas(plane)
    schemas = Pair{String,Vector{Symbol}}[_who(e) => copy(_handle(e).writer.faces)
                                          for e in plane.roster]
    push!(schemas, "harness" => copy(plane.harness.faces))
    schemas
end

"""
The growth rule (§11.5), and the one site a drain thunk is compiled at: append
the current writer set to the trace's schema list, name the appended range
`live_writers`, and recompile every thunk with its writer's new index. The list
grows *in place* (D-255) — a `Trace` a caller holds is a detached value, its
own copy of the schemas, so the growth cannot reach it.

Reached from four places, all of them stopped-sim: the three doors that build a
run, `init!`, `restore!` and `replay!`, and `reclaim!`'s two callers, `attach!` and
`detach!`. With no trace to write into, under the door's `trace = false` or at
a roster change before the first door, whose placeholder run has no trace
(D-261), nothing is appended and the indices are provisional. No drain runs
before a door has, so nothing reads either.

The appended range is a local (D-260): the thunks are compiled against it here
and nothing reads it afterwards. `store` is the executor's and `trc` the run's
trace, `nothing` under the switch, both taken as arguments (D-261) and closed
over concretely — so the record branch inside `_drain!` folds away where there
is nothing to record.
"""
function _install_writers!(plane, store, trc)
    writer_count = length(plane.roster) + 1
    live_writers = if trc === nothing
        1:writer_count
    else
        schema_count = length(trc.schemas)
        append!(trc.schemas, _writer_schemas(plane))
        (schema_count + 1):(schema_count + writer_count)
    end
    for (i, entry) in enumerate(plane.roster)
        # the entry is immutable and its thunk carries the index, so the
        # recompilation replaces the entry itself (§11.4's stopped-sim compile)
        plane.roster[i] = RosterEntry(
            entry.dev, entry.id,
            _drain_thunk(store, _handle(entry).writer, trc, live_writers[i]),
            entry.should_abort, entry.account, entry.handle)
    end
    plane.harness_drain =
        _drain_thunk(store, plane.harness, trc, live_writers[writer_count])
    nothing
end

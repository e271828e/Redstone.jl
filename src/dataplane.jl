# The data plane (§11): staging cells with their frame-top drain — planes 1
# and 2 of §11.1's replacement for the shared mutable model — the diagnostic
# channel with the published framework status (§11.8, §13.2), snapshot
# publication, plane 3, and the log riding behind it (§11.2). The cells'
# owners — the roster's device entries and the harness writer beside them —
# live in roster.jl, the device tasks that stage into them in devices.jl,
# the trace the drain feeds in trace.jl. The pacer's frozen record is here
# beside the status it rides in (§10.7); the pacer itself is control.jl's.
#
# This file holds the types and the pure mechanics; the `Simulation`-facing
# surface — `stage!`, `drain!`, `publish!`, `latest` — lives in sim.jl, beside
# the loop that calls it, and the channel's kinds are diagnostics.jl's, with
# every other kind; `KINDS`, the closed set's one home, stays here.

"""
The staging cell (§11.4): one atomic reference holding the pending batch — CAS
merge on the writer's side, `atomicswap` at the drain. The batch rides boxed in
a `Ref` so every handoff is one pointer-width atomic operation (§11.1) whatever
the surface's size, and the CAS compares batch *identity*: a failed replace
means the loaded batch was intercepted — drained, or merged past by another
stager — and the retry re-reads exactly what is pending now. The failure case
is precisely correct: an intercepted batch is already applied (or already
carries the other stager's entries), and must not be re-staged.
"""
mutable struct StagingCell{B}
    @atomic pending::Union{Nothing,Base.RefValue{B}}
end

# --- the diagnostic channel (§11.8, §13.2, Appendix C) -------------------------

"""
The closed set's one home (§11.8, Appendix C): the union below is built from
it, `KindCounts` keeps one field per member in its order, and a renderer walks
it to name a kind no retained value carries.
"""
const KINDS = (MalformedDatum, OutOfClaimEntry, ClaimedFaceEntry, EntryTypeMismatch,
               ChatteringBudget, FiringBudget, DebtReanchor, UnboundedRun, ThreadBudget,
               DeviceCrash, DeviceJoinTimeout, ReplayDiscardedStaging, EmptyGreedyClaim)

"The closed set as a union: what a ring holds, and what `report_cell!` admits."
const DiagValue = Union{KINDS...}

"""
The per-kind counter record (§11.8): a **fixed-shape isbits record, never a
`Dict`** — licensed by the closed kind set, which makes the counter layout a
type rather than a lookup. One field per kind, in `KINDS`'s order; the same
shape serves a batch's suppressed counts and the loop's cumulative totals, and
`+` is the fold between them.
"""
struct KindCounts
    malformed::Int
    out_of_claim::Int
    claimed_face::Int
    type_mismatch::Int
    chattering::Int
    firing::Int
    reanchor::Int
    unbounded::Int
    thread_budget::Int
    crash::Int
    join_timeout::Int
    replay_discarded::Int
    empty_greedy::Int
end
KindCounts() = KindCounts(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

# A kind's `KindCounts` field, defined on the type so a renderer names a kind
# no retained value carries; an occurrence forwards to its type.
_kind(::Type{MalformedDatum})   = :malformed
_kind(::Type{OutOfClaimEntry})  = :out_of_claim
_kind(::Type{ClaimedFaceEntry}) = :claimed_face
_kind(::Type{EntryTypeMismatch}) = :type_mismatch
_kind(::Type{ChatteringBudget}) = :chattering
_kind(::Type{FiringBudget})     = :firing
_kind(::Type{DebtReanchor})     = :reanchor
_kind(::Type{UnboundedRun})     = :unbounded
_kind(::Type{ThreadBudget})     = :thread_budget
_kind(::Type{DeviceCrash})      = :crash
_kind(::Type{DeviceJoinTimeout}) = :join_timeout
_kind(::Type{ReplayDiscardedStaging}) = :replay_discarded
_kind(::Type{EmptyGreedyClaim}) = :empty_greedy
_kind(d::DiagValue) = _kind(typeof(d))

_bump(counts::KindCounts, kind::Symbol) =
    KindCounts((getfield(counts, f) + (f === kind) for f in fieldnames(KindCounts))...)
Base.:+(a::KindCounts, b::KindCounts) =
    KindCounts((getfield(a, f) + getfield(b, f) for f in fieldnames(KindCounts))...)
_total(counts::KindCounts) = sum(f -> getfield(counts, f), fieldnames(KindCounts))

"The ring's capacity (§11.8): the channel's normative bound, which *is* the rate limit."
const DIAG_RING = 16

"""
One frame's bounded accumulation (§11.8): a small ring of diagnostic values,
capacity `DIAG_RING`, plus the per-kind counts of what the ring could not
hold. The drop policy is earliest-in-frame retained, excess becomes counts:
the first occurrences are the ones with diagnostic content, the hundredth is
noise the count already reports. Immutable, because the CAS handoff below
needs value semantics: an append builds a new batch, and a drained batch is
frozen — never written again — with the writer allocating afresh at its next
emission, on its own task (§11.8's GC-over-reuse trade).
"""
struct DiagBatch
    ring::Vector{DiagValue}
    suppressed::KindCounts
end

"The shared empty sentinel (§11.8): what the drain swaps *in*, and what a quiet frame gets back."
const EMPTY_DIAG = DiagBatch(DiagValue[], KindCounts())

"""
The diagnostic cell (§11.8): one per writer — each rostered device's, the
harness writer's, the loop's own — single-writer, the same ownership
argument as the staging cells: no locking, no arbitration, no new primitive.
A `Model` owns one more, its frame's, which the drain folds into the loop's
account (D-317).
The CAS mirrors `stage_batch!`'s: a failed replace means the loaded batch was
intercepted by the drain, and the retry re-reads what is pending now — the
intercepted entries are already taken, and the entry in hand merges against
the fresh (sentinel) state.

The liveness heartbeat rides in the same cell (§11.8, §12.2), as the atomic
timestamp the device task stores on every loop pass from inside the handle
primitives and the loop acquire-loads where it publishes. It is a field,
always present, never a diagnostic kind, and never reset after `attach!`.
Its initial `0.0` makes a cell that has not beaten since attach read stale
against the §12.2 threshold from the first frame, a failed `init!`'s
included, with no marking machinery (§12.4, D-138).
"""
mutable struct DiagCell
    @atomic batch::DiagBatch
    @atomic heartbeat::Float64
end
DiagCell(batch::DiagBatch) = DiagCell(batch, 0.0)

# The writer's side (§11.8), on the writer's own task: append under the bound,
# or count past it by kind. Reached through `report!(handle, …)` (devices.jl)
# and from the framework's own emission sites.
function report_cell!(cell::DiagCell, occurrence::DiagValue)
    while true
        current = @atomic cell.batch
        next = length(current.ring) < DIAG_RING ?
            DiagBatch(push!(copy(current.ring), occurrence), current.suppressed) :
            DiagBatch(current.ring, _bump(current.suppressed, _kind(occurrence)))
        (; success) = @atomicreplace cell.batch current => next
        success && return nothing
    end
end

# The indivisible take (§11.8): one `atomicswap` per cell at frame top, at the
# same point and under the same argument as the staging drain. A quiet frame
# swaps the sentinel in and gets the sentinel back — no allocation, and no
# load-only code path that goes untested on healthy runs.
_take!(cell::DiagCell) = @atomicswap cell.batch = EMPTY_DIAG

# The heartbeat's two sides (§11.8, §12.2): the store from inside the handle
# primitives, the acquire-load where the loop publishes.
_beat!(cell::DiagCell) = (@atomic :release cell.heartbeat = time(); nothing)
_heartbeat(cell::DiagCell) = @atomic :acquire cell.heartbeat

"The shared empty delta (§11.8): a quiet writer's `recent`, one object for all of them."
const EMPTY_RECENT = DiagValue[]

"""
The loop's private account for one writer (§11.8): everything on the loop's
side of the cell, owned by the loop task alone. `recent` and `suppressed` are
the pending delta — what the frame-top drain took and no snapshot has carried
yet; the first publication after the drain takes them, so a reader at any
cadence sees each occurrence exactly once in `recent`. `totals` is the
cumulative per-kind record since the run began, reset at each run's top and
*copied* into every status (`KindCounts` being isbits, the read is the copy):
delta plus total is what makes the status legible at any reading cadence —
nothing is lost by not looking.
"""
mutable struct WriterAccount
    recent::Vector{DiagValue}
    suppressed::KindCounts
    totals::KindCounts
end
WriterAccount() = WriterAccount(EMPTY_RECENT, KindCounts(), KindCounts())

function _reset!(account::WriterAccount)
    account.recent = EMPTY_RECENT
    account.suppressed = KindCounts()
    account.totals = KindCounts()
    nothing
end

# The frame-top fold (§11.8): the indivisible take, then — the batch
# exclusively the loop's — retained values into the pending delta and every
# occurrence, retained and suppressed alike, into the totals. The quiet path
# is the sentinel coming back: no allocation, nothing touched.
function _fold!(account::WriterAccount, cell::DiagCell)
    batch = _take!(cell)
    batch === EMPTY_DIAG && return nothing
    counts = batch.suppressed
    for occurrence in batch.ring
        counts = _bump(counts, _kind(occurrence))
    end
    account.recent = account.recent === EMPTY_RECENT ? copy(batch.ring) :
                                                       append!(account.recent, batch.ring)
    account.suppressed = account.suppressed + batch.suppressed
    account.totals = account.totals + counts
    nothing
end

# Design: §11.8, §12.2, Appendix B, D-193.
# `recent` is the ring the frame's drain took, at most `DIAG_RING` entries.
# `totals` is monotone across snapshots, so log decimation loses *which*
# boundary an occurrence fell on, never *how many*. `task_state` is read off the
# run's `Task` handle at publication (D-193); `:done` without a live task covers
# a failed `init!` and a returned inline body. The records render inside their
# `FrameworkStatus`'s `show` (show.jl), each kind in full up to `STATUS_MAXLOG`
# cumulative occurrences and count-only past it (§11.8).
"""
    WriterStatus

The status record of one writer, as one [snapshot](@ref g-snapshot) publishes
it.

A snapshot's [framework status](@ref g-framework-status) holds one record per
writer. The writers are each rostered [device](@ref g-device) in attachment
order, then the [harness writer](@ref g-harness-writer), then the loop.
[`incumbent_status`](@ref) returns the record of the writer behind a
[`PortView`](@ref), and [`orphaned`](@ref) and [`stale`](@ref) read it. A record
holds these fields.

- `who`: the writer's name, as a port view's `incumbent` holds it.
- `recent`: the diagnostics the writer reported since the previous
  [frame top](@ref g-frame), at most 16, carried by this snapshot alone.
- `suppressed`: the counts by [kind](@ref g-kind) of the diagnostics dropped
  past those 16.
- `totals`: the counts by kind since the run began, which never decrease from
  one snapshot to the next.
- `heartbeat`: a rostered device's [heartbeat](@ref g-heartbeat), in seconds as
  `time()` gives them.
- `task_state`: a rostered device's task, `:none` outside a run. Inside one it
  is `:running` while the task lives, and `:done` once it has ended or when the
  device has no live task of its own.

The harness writer and the loop have no task of their own, so their records
hold `nothing` in `heartbeat` and `task_state`.
"""
struct WriterStatus
    who::String
    recent::Vector{DiagValue}
    suppressed::KindCounts
    totals::KindCounts
    heartbeat::Union{Nothing,Float64}
    task_state::Union{Nothing,Symbol}
end

"""
One writer's share of the tail residue (§11.8, D-203): what the run's-end
sweep took past the final frame top — the final ring, at most `DIAG_RING`
entries, and the per-kind counts the ring refused. A quiet writer contributes
no record.
"""
struct ResidueRecord
    writer::String
    recent::Vector{DiagValue}
    suppressed::KindCounts
end

"""
The pacer's record in the published framework status (§10.7, D-269): `pace`,
the pace the loop's frames run under (`Inf` where no frame waits); `debt`
and `peak_debt` in seconds; `overruns`, the frames that exceeded their
budget; `reanchors`, every re-anchor after the run's first, and `forgiven`,
the seconds of debt they cleared; `waits` and `waited`, the frames that
waited and their total wall time. Isbits, so the copy is the read, as
`KindCounts`. `step!` and boundary zero carry no pacer, and their record
reads `Inf` and zeros. The copy off a live `Pacer` is control.jl's.
"""
struct PacerStatus
    pace::Float64
    debt::Float64
    peak_debt::Float64
    overruns::Int
    reanchors::Int
    forgiven::Float64
    waits::Int
    waited::Float64
end
PacerStatus(::Nothing) = PacerStatus(Inf, 0.0, 0.0, 0, 0, 0.0, 0, 0.0)

"""
The published framework status (§11.8, §11.2): a concrete frozen value, never
a window onto live bookkeeping — per-writer records in the drain's own order,
each rostered device in attachment order, then the harness writer, then the
loop itself, and beside them the pacer's record (§10.7). Built fresh in
`publish!` and frozen into the snapshot; the binding rule holds because
everything here is either immutable, a copy, or a vector the account has
released.
"""
struct FrameworkStatus
    writers::Vector{WriterStatus}
    pacer::PacerStatus
end

"§12.2's staleness threshold, in seconds of wall clock: advisory, a display rule, never a kill trigger."
const STALE_S = 2.0

# Design: §12.2. The never-heartbeated cell holds `0.0`, which reads stale
# unconditionally.
"""
    stale(record::WriterStatus; now::Float64 = time()) -> Bool

Return `true` when the record's [device](@ref g-device)
[heartbeat](@ref g-heartbeat) lags the wall clock by more than `STALE_S`, two
seconds.

The heartbeat is the liveness read. The threshold is deliberately loose, so a
device parked in a blocking read between rare data is not stale. A starved,
blocked or crashed device then shows as a stale heartbeat with a name on it, not
as physics that froze for no visible reason. A device that has not beaten since
attach reads stale whatever `now` is. The records of the
[harness writer](@ref g-harness-writer) and of the loop have no heartbeat to
judge, and return `false`.

# Keywords

- `now`: the wall-clock time the heartbeat is judged against, in seconds as
  `time()` gives them.

See [`orphaned`](@ref) for a device whose task has ended, and
[`incumbent_status`](@ref) for the record a GUI device reads.
"""
stale(record::WriterStatus; now::Float64 = time()) =
    record.heartbeat !== nothing && now - record.heartbeat > STALE_S

# The wrapper catches every non-interrupt throw, so a device task never fails.
_task_state(task::Task) = istaskdone(task) ? :done : :running

"""
The batch (§11.4, D-202): a pair of positional tuples over one writer's
surface — a values tuple, concretely typed `Tuple{T₁, …, Tₙ}`, and a parallel
`Bool` touched-mask. A set mask position means *staged this time*; a clear one
means *not touched*, never "reset" — its value is the placeholder the writer
was compiled with, dead behind the mask guard. The concrete layout is the
point (D-202): a `Union{Nothing,Tᵢ}` carrier reads more directly, but tuple
covariance makes each touched-face combination its own concrete type, and the
frame-top scatter would specialize per pattern — mid-run compilation and a
boxed dispatch where the drain promises pure application.
"""
struct Batch{V<:Tuple,M<:Tuple}
    staged::V                  # position → the staged (or placeholder) value
    mask::M                  # position → touched this time (NTuple{n,Bool})
end

"""
The compiled writer (§11.4): one write surface's staged representation, fixed
at a stopped-sim point — a device's compiled at attach against its claim set,
the harness writer's at deployment binding and at every roster change
against its *derived* surface, the unclaimed complement (§11.3). The batch is
the values-plus-mask pair above (D-202), isbits with one concrete layout per
writer. The face-name → position schema, the root-input types, the per-position
cell addresses — the compiled scatter's data — and the blank batch the shim
starts from (placeholders drawn from the layout's probe values, mask all clear)
live here beside the staging cell they describe; a roster entry carries one of
these per device (roster.jl), and the harness writer carries the one whose
shape the framework derives rather than receives.
"""
struct Writer{B<:Batch,A<:Tuple}
    faces::Vector{Symbol}    # position → face name: the schema
    types::Vector{Any}       # position → the root input's declared type Tᵢ
    addrs::A                 # position → the root input's cell address
    blank::B                 # placeholders under an all-clear mask
    cell::StagingCell{B}
end

_port_type(::CellAddr{P,K}) where {P,K} = P

function Writer(layout::Layout, faces::Vector{Symbol})
    addrs = Tuple(layout.addr[("", f)] for f in faces)
    types = Any[_port_type(a) for a in addrs]
    probes = Dict(f => v for (f, v) in layout.root_inputs)
    placeholders = Tuple(convert(types[i], probes[faces[i]]) for i in eachindex(faces))
    blank = Batch(convert(Tuple{types...}, placeholders), ntuple(_ -> false, length(faces)))
    Writer{typeof(blank),typeof(addrs)}(faces, types, addrs, blank,
                                        StagingCell{typeof(blank)}(nothing))
end

"""
§11.4's shim, run at staging on the writer's own side: the author's face ⇒
value pairs become a batch — name → position, convert to the root input's declared
type, set the mask. Every diagnostic site follows the compilation here, to
staging: face validity, surface membership and value convertibility are all
static facts of the run, so a face with no position in the schema is
discarded under an `OutOfClaimEntry`/`ClaimedFaceEntry` and an unconvertible
value under `EntryTypeMismatch`, while the rest of the batch stands. Nothing
remains at the drain. The diagnostics are written into the writer's own cell
(§11.8) — the device's for a handle staging, the harness writer's
otherwise — on the staging task, surfacing in the status at the next frame
top's drain; a batch staged while stopped waits in the cell exactly as its
entries wait in the staging cell.

The out-of-schema kind discriminates by writer (§11.3, Appendix C): a
device's entry is always `OutOfClaimEntry` — naming the incumbent when the
face is claimed elsewhere — while the harness writer's is `ClaimedFaceEntry`
naming the incumbent when a rostered claim covers the face, and
`OutOfClaimEntry` only when the face names no root input at all. `claimed_by` is
the exclusivity index the roster maintains; `device` identifies a device
writer and `nothing` the harness; `site` distinguishes ordinary staging from
an attach's renormalization in the `ClaimedFaceEntry` payload. Returns
`nothing` for a batch with no surviving entry.
"""
function _normalize(writer::Writer, entries, claimed_by::Dict{Symbol,String},
                    cell::DiagCell; device::Union{Nothing,String} = nothing,
                    site::Symbol = :staging)
    staged = Any[writer.blank.staged...]
    mask = fill(false, length(writer.faces))
    for (key, value) in entries
        face = Symbol(key)
        face_position = findfirst(==(face), writer.faces)
        if face_position === nothing
            incumbent = get(claimed_by, face, nothing)
            if device !== nothing
                report_cell!(cell, OutOfClaimEntry(face, value, writer.faces, incumbent))
            elseif incumbent !== nothing
                report_cell!(cell, ClaimedFaceEntry(face, incumbent, value, site))
            else
                report_cell!(cell, OutOfClaimEntry(face, value, writer.faces, nothing))
            end
            continue
        end
        staged[face_position] = try
            convert(writer.types[face_position], value)
        catch
            report_cell!(cell, EntryTypeMismatch(face, value, writer.types[face_position]))
            continue
        end
        mask[face_position] = true
    end
    any(mask) || return nothing
    Batch(convert(typeof(writer.blank.staged), (staged...,)), (mask...,))
end

# The one coalescing policy (§11.4): merge, newest wins per face. Untouched
# faces survive; re-staged faces take the newest level — the per-face ZOH.
# Positional and mask-driven, unrolled by generation: both arguments share the
# writer's one concrete batch type, and the unroll leans on no small-tuple
# heuristic, so width does not degrade it (D-202).
@generated function _merge(held::Batch{V,M}, incoming::Batch{V,M}) where {V,M}
    value_exprs = [:(incoming.mask[$i] ? incoming.staged[$i] : held.staged[$i])
                   for i in 1:fieldcount(M)]
    mask_exprs = [:(held.mask[$i] | incoming.mask[$i]) for i in 1:fieldcount(M)]
    :(Batch{V,M}(($(value_exprs...),), ($(mask_exprs...),)))
end

# The CAS merge loop (§11.4), on the writer's task.
function stage_batch!(writer::Writer{B}, batch::B) where {B}
    cell = writer.cell
    while true
        held = @atomic cell.pending
        merged = held === nothing ? batch : _merge(held[], batch)
        (; success) = @atomicreplace cell.pending held => Base.RefValue{B}(merged)
        success && return nothing
    end
end

# The drain's application (§11.4): the compiled scatter, position → the root
# input's cell, statically typed, masked-off positions skipped — pure
# application, no checks. One specialization per writer, compiled at the
# stopped-sim point that compiled the writer, whatever the batch touches (D-202).
@generated function _apply!(store, addrs::Tuple, batch::Batch)
    statements = [:(batch.mask[$i] && scatter_cell!(store, addrs[$i], batch.staged[$i]))
                  for i in 1:fieldcount(fieldtype(batch, :mask))]
    quote
        $(statements...)
        nothing
    end
end

# One cell's drain (§11.4): the indivisible take by `atomicswap`, then the
# compiled scatter. Reached at frame top through the stopped-sim-compiled
# thunks (roster.jl's `_drain_thunk`), inside which every argument is
# concrete. The trace's conversion rides here (§11.5): the drained tuple is
# the *coalesced* truth, so the record is taken at the drain and nowhere
# earlier, against the writer's own schema index — closed into the thunk with
# the run's trace (trace.jl, `trc` untyped for include order alone). Under the
# kill switch that capture is `nothing` and the branch below folds (D-260).
function _drain!(store, writer::Writer, trc, writer_index::Int)
    taken = @atomicswap writer.cell.pending = nothing
    taken === nothing && return nothing
    batch = taken[]
    _apply!(store, writer.addrs, batch)
    trc === nothing || _record!(trc, writer_index, batch)
    nothing
end

# --- publication (§11.2) -------------------------------------------------------

# Design: §11.2, §11.8, §12.3, Appendix B.
# The counter-home rule: the index rides *in* the snapshot, so any holder of
# one — the log, a post-run inspector — indexes it without consulting the loop.
# The framework status is the per-writer diagnostic account, frozen. Built in
# private memory by copying the cell buffers, then handed out through one
# release-store; nothing reachable from a published snapshot is ever written
# again, which is what makes the lock-free read sound. The state stores (`x`,
# `s`, `m`) are deliberately not carried (§11.2).
"""
    Snapshot

The immutable publication of one settled [boundary](@ref g-boundary): the
[signal table](@ref g-signal-table), its time and its counters.

[`latest`](@ref) returns the newest [snapshot](@ref g-snapshot),
[`wait_next_snapshot`](@ref) the next one and [`logged`](@ref) the retained
ones. A snapshot holds the whole signal table at its boundary,
[root inputs](@ref g-root-input) included, and no state. Read a
[port](@ref g-port) off it with `port(snapshot, path, name)`, a method of
[`port`](@ref) addressed exactly as the live table, and a
[device](@ref g-device)'s [read set](@ref g-read-set) with [`gather`](@ref).
Nothing in a published snapshot is ever written again, so a reader on any task
may hold one for as long as it likes.

A snapshot holds these fields, beside the table that `port` reads.

- `t`: the boundary time.
- `frame`: the number of [frames](@ref g-frame) completed since the run's
  origin.
- `boundary`: the boundary ordinal, counting the trajectory's published
  boundaries from `0` at [boundary zero](@ref g-boundary-zero).
- `status`: the [framework status](@ref g-framework-status). `status.writers`
  holds one [`WriterStatus`](@ref) per writer, and `status.pacer` the pacer's
  record.
"""
struct Snapshot{T,S<:StoreBundle}
    t::T
    frame::Int
    boundary::Int     # the trajectory's published-boundary ordinal (§12.3, D-230); boundary zero = 0
    store::S
    layout::Layout    # build-frozen addressing, shared, never copied
    status::FrameworkStatus
end

# Design: §11.2.
"""
    port(snapshot::Snapshot, path::String, name::Symbol)

Return a [port](@ref g-port)'s value in the [snapshot](@ref g-snapshot)'s
[signal table](@ref g-signal-table), as published at its
[boundary](@ref g-boundary).

A snapshot carries the whole signal table, [root inputs](@ref g-root-input)
included. A port is addressed exactly as in the live table, by its
[component](@ref g-component)'s path and its name. An
[assembly](@ref g-assembly)'s own path addresses its output
[faces](@ref g-face), and the empty path the root inputs. Nothing in a published
snapshot is written again, so the read is safe from any task.

A snapshot carries no state, only ports. For a port's live value, see
`port(sim, path, name)` and `port(model, path, name)`, and for snapshots
themselves, [`latest`](@ref) and [`logged`](@ref).
"""
port(snapshot::Snapshot, path::String, name::Symbol) =
    gather_cell(snapshot.store, snapshot.layout.addr[(path, name)])

# A compiled read set's gather over a snapshot's store (§11.2, §14.4): a
# binding's reads, compiled at attach for a table source, run per snapshot on
# the device's task. Here rather than in readers.jl for include order alone.
@inline gather_reads(reader::Reader{T,L}, snapshot::Snapshot{T}) where {T,L} =
    NamedTuple{L}(_read_entries(reader.entries, snapshot.store))

"""
§11.2's `@atomic latest` reference in a mutable object of its own. The plane is
a mutable struct whose other fields the loop and the service calls rewrite
non-atomically, so the one published reference lives apart from them: the
wait-free exchange shares no struct with loop-owned mutable state, and a
handle's `latest` is one load off a small object. Release-store at publication,
acquire-load at `latest(sim)`, wait-free in both directions: a wedged reader
cannot delay publication, and the loop cannot tear a reader's view.
"""
mutable struct Published
    @atomic latest::Union{Nothing,Snapshot}
end

# --- the log (§11.2) -----------------------------------------------------------

"""
The log (§11.2): logging dissolves into publication. What is retained are the
published snapshots themselves — the same objects, zero extra copies (D-023
rejected preallocated buffers; unlogged snapshots die young) — under three
policies the door that builds the run takes (D-261): the plain switch, the keep-every-kth
stride `log_every`, and the retention bound `log_max` (`Inf` stored as
`typemax(Int)`). Normative are the guarantees, not the mechanism below: the
bound is respected *continuously*, the retained count never exceeding
`log_max`; coverage is global at the effective stride `log_every · 2^k` after
`k` generations; and the two endpoints are kept unconditionally.

The endpoints ride outside the bounded middle — two extra references, never
counted against it. `first` is the run's first publication, the boundary-zero
snapshot under `init!` (§14.5) and the restored one under `restore!` and
`replay!` (D-274); `last` is the latest published boundary — which at any
stopped moment is the tail's final snapshot, published before the sticky
status was set (§12.4), the terminal snapshot the spec retains unconditionally.

The middle re-decimates progressively (D-137: a rolling window was rejected —
what coarsens is density, never extent), amortized: `snaps` holds one
generation's retained snapshots, `nothing` marking a released slot until the
once-per-generation compaction. The arithmetic rests on one invariant — at
each generation's start the compacted vector holds the boundaries at ordinals
`stride · (1..log_max)` past `first`'s, index by index — so the entries the
doubled stride abandons are exactly the odd indices, and `cursor` walks them.
"""
mutable struct SnapshotLog
    enabled::Bool
    log_max::Int                    # what bounds `live`, never the endpoints
    stride::Int                     # the effective stride, log_every · 2^generation
    first::Union{Nothing,Snapshot}  # the run's first publication (§14.5, D-274)
    last::Union{Nothing,Snapshot}   # the terminal endpoint: the latest published boundary
    snaps::Vector{Union{Nothing,Snapshot}}   # the bounded middle; `nothing` = released
    live::Int                       # retained middles: the count `log_max` bounds
    cursor::Int                     # the thinning cursor over odd indices; 0 = inactive
end

# A finite bound hints the middle's capacity, so regrowth is a non-event (§9.8,
# §11.2). `init!` knows no duration (D-255), so the bound alone sets the hint;
# a disabled or unbounded log gets none.
function SnapshotLog(enabled::Bool, log_every::Int, log_max::Int)
    snaps = Union{Nothing,Snapshot}[]
    enabled && log_max != typemax(Int) && sizehint!(snaps, log_max)
    SnapshotLog(enabled, log_max, log_every, nothing, nothing, snaps, 0, 0)
end

"""
One published boundary enters the log (§11.2), on the loop task, right behind
the release-store: the run's first publication lands in `first`, a stride
multiple of the ordinals past it is retained into the middle, and every
snapshot re-points `last` — one field store, which is all the terminal endpoint
costs. Off, the switch retains nothing at all: retention is what it gates,
publication being upstream of it. The snapshot is the box `latest` holds,
taken unspecialized, so every store here reuses publication's one allocation
(§9.8). Its concrete type rides beside it and keeps the two `boundary` reads
static, since a dynamic read boxes an `Int` past 511.
"""
function log!(snapshot_log::SnapshotLog, @nospecialize(snapshot::Snapshot),
              snapshot_type::Type{<:Snapshot})
    snapshot_log.enabled || return nothing
    if snapshot_log.first === nothing
        snapshot_log.first = snapshot
    else
        # the trajectory's ordinal rides in the snapshot (D-230), counted here
        # from the first endpoint's, which a restore places past zero (D-274);
        # one run's snapshots share one concrete type
        ordinal = (snapshot::snapshot_type).boundary -
                  (snapshot_log.first::snapshot_type).boundary
        ordinal % snapshot_log.stride == 0 && _retain!(snapshot_log, snapshot, ordinal)
    end
    snapshot_log.last = snapshot
    nothing
end

# One retained append (§11.2, D-137), the amortized re-decimation in full. At
# the fill point — middle at `log_max`, no thinning under way — the stride doubles
# *immediately*, and the candidate in hand re-tests against it, half the old
# stride's multiples being no longer retained; the appends that follow continue
# the surviving even multiples seamlessly. While thinning is active each
# retained append first releases one predecessor at the cursor, so the bound
# holds continuously and a generation's thinning completes exactly when its
# refill does; compaction then runs, once per generation, restoring the
# index-by-ordinal invariant for the next fill.
function _retain!(snapshot_log::SnapshotLog, @nospecialize(snapshot::Snapshot), ordinal::Int)
    if snapshot_log.cursor == 0 && snapshot_log.live == snapshot_log.log_max
        snapshot_log.stride *= 2
        snapshot_log.cursor = 1
        ordinal % snapshot_log.stride == 0 || return nothing
    end
    if snapshot_log.cursor > 0
        snapshot_log.snaps[snapshot_log.cursor] = nothing
        snapshot_log.live -= 1
        snapshot_log.cursor += 2
        snapshot_log.cursor > snapshot_log.log_max &&
            (filter!(!isnothing, snapshot_log.snaps); snapshot_log.cursor = 0)
    end
    push!(snapshot_log.snaps, snapshot)
    snapshot_log.live += 1
    nothing
end

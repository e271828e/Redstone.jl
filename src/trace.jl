# The input trace (§11.5): the header, the checkpoint `init!` takes at the end of
# boundary zero (checkpoint.jl, D-274), and behind it the writers' schemas and one
# sparse record per drained batch, in the one record format D-176 unified on.
# The trace is *primary* data (D-029, D-038): the log is recomputable from it,
# and what recomputes it is replay (§12.7), whose entry pass — the validation
# and normalization a trace is admitted through — lives at the tail of this file.
#
# This file holds the trace itself and the pure mechanics; the `Simulation`-facing
# surface — the header's placement in `init!`, the drain's frame stamp,
# `trace(sim)`, `_compile_feed`, `replay!` and the drain
# substitution — lives in sim.jl, beside the loop that runs it. The drain
# thunks, which carry the writer's schema index, are compiled at one site,
# roster.jl's `_install_writers!`, the one place that grows the schema list.

"""
One drained batch, retained sparse (§11.5, D-176): the masked (touched)
positions as `position ⇒ value` pairs against the writer's schema, which is
`trace.schemas[writer]`. `frame` is the frame ordinal the batch was drained
at the top of — the drain runs before the run's frame index increments, so a
batch drained at the top of frame `k` carries `frame = k` and replays there.
"""
struct TraceBatch
    frame::Int
    writer::Int                       # index into the trace's schema list
    entries::Vector{Pair{Int,Any}}
end

# A record is a *value*, and the claim replay makes about a continuation — the
# recording is a bit-identical prefix of what the continued session records
# (§12.7) — is an equality between records built by two different drains.
# The default `==` on a mutable-free struct with a `Vector` field is egal, which
# would make that claim untestable, so the field-wise one is defined here, and
# `hash` with it as Julia's convention requires.
Base.:(==)(a::TraceBatch, b::TraceBatch) =
    a.frame == b.frame && a.writer == b.writer && a.entries == b.entries
Base.hash(record::TraceBatch, seed::UInt) =
    hash(record.entries, hash(record.writer, hash(record.frame, seed)))

# Design: §11.5, §11.8, §12.7, Appendix B, D-255, D-260, D-274, D-317, D-319.
# The header is `nothing` only between the run's opening and boundary zero's
# first publication, where `init!` writes it; `restore!` and `replay!` open
# their run with the checkpoint they restore (D-274). `Run.trace` is the live
# one, `nothing` under the kill switch; `trace(sim)` hands back a detached value
# of the same type, which no drain ever advances. Replay does not reconstruct
# claims (§12.7). The tags are §11.8's own writer names, `_who(entry)` and
# `"harness"`. The recording is the nominal simulation's, and a `Checkpoint` is
# nominal by type (D-317, D-319).
"""
    Trace

The input recording of a run: the [checkpoint](@ref g-checkpoint) it opened from
and every [batch](@ref g-batch) the loop applied since.

[`trace`](@ref) returns a copy of the current run's [trace](@ref g-trace), and
[`replay!`](@ref) takes one to re-drive a simulation. The copy is detached, so
later [frames](@ref g-frame) never reach it. A trace holds these fields.

- `header`: the [`Checkpoint`](@ref) the run opened from, written once by the
  call that opened it and never again.
- `schemas`: each writer's [face](@ref g-face) names by position, as
  `writer => faces` pairs. One is appended at every change to the
  [roster](@ref g-roster), and the list only grows. A writer is named as in a
  [`WriterStatus`](@ref), and the [harness writer](@ref g-harness-writer) is
  `"harness"`.
- `batches`: one record per drained batch, in [drain](@ref g-drain) order, by
  frame and then by writer. Each record holds its frame, its writer's index into
  `schemas` and its entries by position, so it reads only through its own schema
  entry.
- `frames`: the frame index of the last drain, which is the frame every record
  of that drain carries. It starts at the header's frame index, so a trace
  opened from a restored checkpoint keys its records by the trajectory's own
  frames.
"""
mutable struct Trace
    header::Union{Nothing,Checkpoint}             # written once, by the door (D-274)
    const schemas::Vector{Pair{String,Vector{Symbol}}}   # writer tag => face-name-by-position
    const batches::Vector{TraceBatch}              # in drain order: by frame, then by writer index
    frames::Int
end

"""
One normalized record (§12.7): the frame ordinal it applies at, the compiled
scatter as a zero-argument thunk, and the `TraceBatch` it came from — carried
beside the thunk so a replayed frame re-records exactly what the recording
held, under the recording's own writer index (§12.7: "the new trace inherits
the old header").
"""
const ReplayRecord = @NamedTuple{frame::Int, thunk::Function, record::TraceBatch}

"""
What `_compile_feed` hands the loop (§12.7): the whole recording normalized to
compiled scatters against the *target* layout, in drain order — by frame, then
by the recording's writer index — with a cursor into it.

The conversion is paid here, once, off the loop: the replay drain applies
compiled scatters exactly as the live drain does, and no face name is resolved
per frame under replay either (D-101). `next` is the first record not yet
applied. `frames` is the recording's own length — the bound every advance in
`:replay` is capped at (D-218), carried here so `step!` and `run!` can cap
without holding the `Trace`; `to_boundary` caps `replay!`'s own advance
earlier, and `replay!` computes that one from the `Trace` in hand.
"""
mutable struct ReplayFeed
    records::Vector{ReplayRecord}
    next::Int
    frames::Int
end

# The conversion at the drain (§11.5, D-176), inside the drain thunk so nothing
# on the frame path boxes an argument: two O(surface-width) scans of the mask —
# one to count the touched positions, one to fill — so the `entries` vector is
# allocated once at its final length rather than grown. The cost of a drained
# batch is then that vector and the values boxed into it, and nothing
# width-dependent beyond them — the cost D-176 records rather than argues away.
# A drained batch always carries at least one touched position (`_normalize`
# returns `nothing` for one that would not), so no record here is empty.
function _record!(trc::Trace, writer_index::Int, batch::Batch)
    mask = batch.mask
    touched = 0
    for i in 1:length(mask)
        mask[i] && (touched += 1)
    end
    entries = Vector{Pair{Int,Any}}(undef, touched)
    j = 0
    for i in 1:length(mask)
        mask[i] && (entries[j += 1] = i => batch.staged[i])
    end
    push!(trc.batches, TraceBatch(trc.frames, writer_index, entries))
    nothing
end

# ==============================================================================
# Replay's entry pass (§12.7): validation, then normalization
# ==============================================================================
# "Validation is loud and up front" — the whole trace is checked and converted
# before the first frame, so every refusal precedes every write and the replay
# drain resolves no name. The pass is two-staged: the header's own disagreements
# with the target build (`_check_checkpoint!`, model.jl) and the schemas'
# fail fast as a collection, and only then are the records
# resolved through the schemas the first stage just validated. `sim` is untyped
# throughout for include order alone; the scalar gate that dispatches into this
# is `_compile_feed` in sim.jl, beside the loop it feeds.

# Each recorded writer's schema against the target's root-input faces (§12.7):
# a recorded name this model does not export is a replay error, reported per
# writer with the whole schema and the list-in-hand beside it. Superseded schema
# entries are checked with the live ones — a batch may still reference them, and
# the compiled scatters below are built from whatever a batch names.
function _check_schemas!(diags::Vector{Diagnostic}, faces::Vector{Symbol},
                         schemas::Vector{Pair{String,Vector{Symbol}}})
    for (tag, schema) in schemas
        unknown = Symbol[face for face in schema if !(face in faces)]
        isempty(unknown) ||
            push!(diags, ReplaySchemaMismatch(writer = tag, schema = schema,
                                              unknown = unknown, faces = faces))
    end
    nothing
end

# The compiled scatter as a zero-argument thunk, the `_drain_thunk` idiom: the
# store, the address tuple and the batch are captured *concretely*, so the
# `@generated` `_apply!` specializes once per writer at this stopped-sim compile
# and the replayed frame calls through a barrier with nothing left to infer.
_apply_thunk(store, addrs::Tuple, batch::Batch) = () -> _apply!(store, addrs, batch)

# One recorded writer's compiled scatter against the *target* layout. The
# schema check above already proved every face addressable, so the guard here
# never fires; it is kept because `Writer` would answer an absent face with a
# `KeyError` rather than with the kind that names it.
function _replay_writer(layout::Layout, diags::Vector{Diagnostic}, tag::String,
                        schema::Vector{Symbol}, frame::Int, faces::Vector{Symbol})
    absent = Symbol[f for f in schema if !haskey(layout.addr, ("", f))]
    isempty(absent) && return Writer(layout, schema)
    for face in absent
        push!(diags, ReplayUnknownFace(face = face, frame = frame, writer = tag,
                                       faces = faces))
    end
    nothing
end

"""
The trace-record conversion in reverse (§12.7, D-176), paid once and off the
loop: every sparse record's positions are resolved through the writer's schema,
the values converted to the target's declared types, and the whole batch
rebuilt as the positional `Batch` the compiled scatter takes. The recorded
`TraceBatch` rides beside its thunk, because a replay re-records.

Everything here is *collected* — Appendix C gives `ReplayUnknownFace` the
`collected` policy — so a trace with three bad entries reports three. A batch
that produced a diagnostic contributes no record: a partially applied frame is
not a replay of anything.
"""
function _compile_records!(diags::Vector{Diagnostic}, sim, trc::Trace, faces::Vector{Symbol})
    layout, store, schemas = sim.model.exec.act.layout, sim.model.exec.store, trc.schemas
    writers = Dict{Int,Writer}()
    replay_records = ReplayRecord[]
    recorded_frames = (trc.header.frame + 1):trc.frames
    for record in trc.batches
        if !(record.frame in recorded_frames)
            # the batch disagrees with the trace's *own* frames: the drain visits
            # every frame after the header's up to `frames` exactly once, so an
            # ordinal outside them names a frame that never comes round and the
            # record would silently never apply. Named by the writer's tag where
            # the schema list has one
            push!(diags, CheckpointMismatch(
                what = :frame,
                name = 1 ≤ record.writer ≤ length(schemas) ?
                       Symbol(first(schemas[record.writer])) :
                       Symbol("writer #$(record.writer)"),
                expected = recorded_frames, found = record.frame))
            continue
        end
        if !(1 ≤ record.writer ≤ length(schemas))
            # no schema to resolve the positions through, and the writer index is
            # what is missing — the tag §11.8 cannot supply is spelled positionally
            for (face_position, _) in record.entries
                push!(diags, ReplayUnknownFace(face = face_position, frame = record.frame,
                                               writer = "writer #$(record.writer)",
                                               faces = faces))
            end
            continue
        end
        (tag, schema) = schemas[record.writer]
        if !haskey(writers, record.writer)
            writer = _replay_writer(layout, diags, tag, schema, record.frame, faces)
            writer === nothing && continue
            writers[record.writer] = writer
        end
        writer = writers[record.writer]
        batch_values, mask, resolved =
            Any[writer.blank.staged...], fill(false, length(schema)), true
        for (face_position, value) in record.entries
            if !(1 ≤ face_position ≤ length(schema))
                push!(diags, ReplayUnknownFace(face = face_position, frame = record.frame,
                                               writer = tag, faces = faces))
                resolved = false
                continue
            end
            batch_values[face_position] = try
                convert(writer.types[face_position], value)
            catch
                push!(diags, CheckpointMismatch(what = :root_input,
                                                name = schema[face_position],
                                                expected = writer.types[face_position],
                                                found = value))
                resolved = false
                continue
            end
            mask[face_position] = true
        end
        resolved || continue
        batch = Batch(convert(typeof(writer.blank.staged), (batch_values...,)), (mask...,))
        push!(replay_records,
              (frame = record.frame, thunk = _apply_thunk(store, writer.addrs, batch),
               record = record))
    end
    # the drain's own order (§11.5): by frame, then by the recording's writer
    # index. Stable, so a trace already in drain order — every trace the drain
    # produces — keeps exactly the order it was recorded in.
    sort!(replay_records; by = r -> (r.frame, r.record.writer), alg = MergeSort)
    replay_records
end

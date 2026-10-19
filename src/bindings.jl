# The binding's runtime half (§11.6): the shipped `TableBinding` with its
# generic `map_input` — the one data-driven binding the framework writes, and
# the owner of the shared pure conditioning helper (§11.4) — and the output
# side: the contract checks on an attachment's `reads`, which then resolve
# through §14.4's one read resolver (readers.jl) into the compiled reader
# whose labeled NamedTuple is what `map_output` receives (§11.2, D-406).
# `map_input`/`map_output` are *conventions of the author-owned loop idiom*:
# the framework never calls them, so what is enforced here is only what
# construction and attach can check — the table's own shape, and the
# enumerated `reads`. Everything the mappings touch at runtime is bounded
# elsewhere: `map_input` by the staging checks (§11.4), on the writer's own
# task; `map_output` by receiving exactly the gather's NamedTuple, what it puts
# on the wire being the peer's business.
#
# The framework-legible half of the binding vocabulary — the roots, the
# declared sides, `claims`/`reads` and the conformance check — lives in
# roster.jl.

"""
    TableBinding(; channel = (face = "...", deadzone = ..., expo = ...), ...)

The shipped data-driven binding (§11.6): the framework writes its `map_input`
once, and a table value — channel name => entry — is constructed per
device × deployment pairing, where configurations are made. Each entry names
the root input face its channel writes (`face`, mandatory) and optionally the
conditioning parameters the generic `map_input` applies (`deadzone`, `expo`);
any other key is a typo caught here, at construction. The entry tuple rides
in the type, so the mapping specializes per table with no dynamic dispatch.

The input side is declared (`is_input`), and the claim is the table's face
set — `claims` derives it, so what the binding may write is exactly what its
entries name. A *code-driven* binding looks identical to the framework: a
JSON telecommand peer whose `claims` returns the vocabulary and whose
`map_input` parses bytes.
"""
struct TableBinding{T<:NamedTuple} <: AbstractBinding
    table::T
end

const _TABLE_ENTRY_VOCABULARY = Symbol[:face, :deadzone, :expo]

function TableBinding(; entries...)
    table = NamedTuple(entries)
    diags = Diagnostic[]
    for (channel, entry) in pairs(table)
        if !(entry isa NamedTuple)
            push!(diags, ArgumentInvalid(
                call = :TableBinding, reason = :entry_shape, entry = channel))
            continue
        end
        if !haskey(entry, :face)
            push!(diags, ArgumentInvalid(
                call = :TableBinding, reason = :no_face, entry = channel))
        elseif !(entry.face isa Union{AbstractString,Symbol})
            push!(diags, ArgumentInvalid(call = :TableBinding, reason = :face_name,
                                          entry = channel, value = entry.face))
        end
        for key in keys(entry)
            key in _TABLE_ENTRY_VOCABULARY || push!(diags, ArgumentInvalid(
                call = :TableBinding, reason = :vocabulary, entry = channel, argument = key,
                vocabulary = _TABLE_ENTRY_VOCABULARY))
        end
        deadzone = get(entry, :deadzone, nothing)
        deadzone === nothing || 0 <= deadzone < 1 || push!(diags, ArgumentInvalid(
            call = :TableBinding, reason = :deadzone, entry = channel, value = deadzone))
        expo = get(entry, :expo, nothing)
        expo === nothing || 0 <= expo <= 1 || push!(diags, ArgumentInvalid(
            call = :TableBinding, reason = :expo, entry = channel, value = expo))
    end
    isempty(diags) || throw(DiagnosticError(diags))
    TableBinding(table)
end

is_input(::TableBinding) = true
claims(b::TableBinding) = String[String(e.face) for e in values(b.table)]

"""
    map_input(datum::NamedTuple, b::TableBinding) -> ("face" => value, ...)

`TableBinding`'s generic mapping — the shared pure conditioning helper, with
an owner (§11.4, §11.6). The datum is whatever the author's loop assembled,
one field per *touched* channel: `map_input` returns face ⇒ value pairs for
exactly those, so a sparse datum stages a sparse batch and merge does the
rest (§11.4). The idiom is `stage!(handle, map_input(datum, binding(handle))...)`,
on the device's own task. The pairs come back as a tuple in the datum's field
order. Building it allocates nothing when the table's faces are `String`s,
however many fields the datum carries.

A datum field naming no table channel is configuration drift, not a bad
datum: the mapping and the datum are written by the same author, so the
throw is deliberate — it lands in the wrapper as the `DeviceCrash` it is
(§11.6). Cross-datum state — press counters, edge detection — lives in the
device struct, maintained by the loop, and arrives *inside* the datum:
`map_input` stays pure, and staged values are levels, never deltas (§11.4).
"""
@generated map_input(datum::NamedTuple{K}, b::TableBinding) where {K} =
    _unrolled_tuple(i -> :(_map_channel(datum, b, $(QuoteNode(K[i])))), length(K))

# One datum field's pair. `map_input` unrolls one call per field, since `map`
# over 32 or more fields allocates and returns a type that is not concrete.
# Inlined, so each call sees its channel as a constant and reads the table
# and the datum by a fixed field instead of a runtime name.
@inline function _map_channel(datum::NamedTuple, b::TableBinding, channel::Symbol)
    haskey(b.table, channel) || error(
        "map_input: the datum carries `$channel`, which names no channel of this " *
        "TableBinding — its channels are $(_faceset(keys(b.table))) (§11.6)")
    entry = b.table[channel]
    String(entry.face) => _condition(datum[channel], entry)
end

# --- the output side: the contract checks and the one resolver (§14.4, §11.2) --

# The selectors themselves are §14.4's closed family, declared in readers.jl
# above this file, and a binding's reads resolve through the family's one
# collecting resolver, the one trim and linearization use (D-406). What stays
# here is §11.6's shape check on the enumeration. The resolver runs for a table
# source at the root, so a store selector is refused by source, and the
# compiled `Reader` runs over a snapshot's store (dataplane.jl's
# `gather_reads`). `get_output` is an inspection read of a primitive's own port
# — deep paths, zero promises, free access, right for looking at *this* build —
# and `get_face` an integration read: a root-exported output face, named,
# curated, meaning-stable under substitution (§11.2). `get_input` reads a root
# input back, the source cell it is.

"""
Check one attachment's `reads` against its contract and compile them —
`attach!`'s output-side work (§11.2), run once at the attach point so a
binding that drifted from its model fails there, not with silent garbage on
the wire. The contract is §11.6's: a NamedTuple of labeled selectors,
`(; label = get_output(...), ...)`, whose labels key the NamedTuple
`map_output` receives. Resolution is the family's one collecting pass
(readers.jl, §14.4), run for a table source at the root, so every violation
surfaces together, the read's own as `ReadResolution` and the path walk's as
`PathResolution`.
"""
function _compile_binding_reads(selectors, binding_type::Type, build::Build)
    selectors isa NamedTuple || throw(DiagnosticError(
        BindingContractMismatch(binding = _typename(binding_type),
                                 reason = :reads_not_namedtuple,
                                 observed = typeof(selectors))))
    for selector in values(selectors)
        selector isa ReadSelector || throw(DiagnosticError(
            BindingContractMismatch(binding = _typename(binding_type),
                                     reason = :reads_not_selectors,
                                     observed = typeof(selector))))
    end
    _compile_reads(Reads((), selectors), build, Float64; source = :table)
end

"""
    map_output(nt, b) -> wire datum

The output side's convention name (§11.6), declared here for the loop idiom —
`send(dev.socket, map_output(gather(handle, snapshot), binding(handle)))` — and
never called by the framework: it receives exactly the compiled gather's
labeled NamedTuple, and what it puts on the wire is the peer's business. An
output binding defines its own method; the identity one returns the NamedTuple
itself.
"""
function map_output end

# The conditioning (§11.4): axis-convention values in [-1, 1], symmetric about
# zero. The deadzone zeroes the band and rescales the remainder so the
# endpoints stay fixed; expo blends linear into cubic — magnitude =
# (1-expo)·magnitude + expo·magnitude³ — attenuating the midrange with the
# endpoints again fixed. An entry declaring neither passes its value through
# untouched, which is what carries a throttle's [0, 1] level or a press
# counter (the levels doctrine): faces take post-conditioning semantics, and
# only where conditioning is declared does the axis convention bind.
function _condition(value, entry)
    deadzone = get(entry, :deadzone, nothing)
    expo = get(entry, :expo, nothing)
    deadzone === nothing && expo === nothing && return value
    clamped = clamp(float(value), -1, 1)
    magnitude = abs(clamped)
    deadzone === nothing ||
        (magnitude = magnitude <= deadzone ?
            zero(magnitude) : (magnitude - deadzone) / (1 - deadzone))
    expo === nothing || (magnitude = (1 - expo) * magnitude + expo * magnitude^3)
    flipsign(magnitude, clamped)
end

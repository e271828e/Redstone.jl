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

# Design: §11.6.
# The framework writes `map_input` once for every table. The entry tuple rides
# in the type, so the mapping specializes per table with no dynamic dispatch.
"""
    TableBinding(; entries...) -> TableBinding

The shipped data-driven [binding](@ref g-binding): a table from channel names to
the [root-input](@ref g-root-input) [faces](@ref g-face) they write.

A binding of this type is built per pairing of [device](@ref g-device) and
deployment, where configurations are made. Each keyword is a channel, the name a
device's datum uses, and its value is a `NamedTuple` entry with these fields.

- `face`: the root input the channel writes, a string or a symbol. Required.
- `deadzone`: the band around zero that reads as zero, in `[0, 1)`. The rest of
  the range is rescaled so that `±1` stays fixed.
- `expo`: the blend from a linear toward a cubic response, in `[0, 1]`, with
  `±1` again fixed.

A channel that declares `deadzone` or `expo` has its value clamped to `[-1, 1]`
and conditioned. A channel that declares neither passes its value through
untouched.

The binding declares the input side ([`is_input`](@ref)). Its
[claim](@ref g-claim) is the table's face set, which [`claims`](@ref) derives,
so what the binding may write is exactly what its entries name. Its
[`map_input`](@ref) maps a datum through the table. A code-driven binding looks
the same to the framework, for example a JSON telecommand peer whose `claims`
returns its vocabulary and whose `map_input` parses bytes.

An entry that is not a `NamedTuple`, has no `face`, names its face by anything
but a string or a symbol, carries any other field, or sets `deadzone` or `expo`
out of range is refused at construction as `ArgumentInvalid`, every such entry
in one throw.
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

# Design: §11.4, §11.6.
# `TableBinding`'s generic mapping, the shared pure conditioning helper with an
# owner. A datum field naming no table channel is configuration drift, not a
# bad datum: the mapping and the datum are written by the same author, so the
# throw is deliberate.
"""
    map_input(datum::NamedTuple, b::TableBinding) -> Tuple

Return the `"face" => value` writes a datum maps to through the table, one per
datum field.

The datum is whatever the [device](@ref g-device)'s loop assembled, one field
per channel it touched. `map_input` returns a pair for exactly those, as a tuple
in the datum's field order, each value conditioned by its channel's `deadzone`
and `expo`. A sparse datum therefore stages a sparse [batch](@ref g-batch), and
the merge with what is already pending does the rest. The loop idiom is
`stage!(handle, map_input(datum, binding(handle))...)`, on the device's own
task. Building the tuple allocates nothing when the table's [faces](@ref g-face)
are `String`s, however many fields the datum carries.

Staged values are levels, never deltas. State across data, such as press
counters or edge detection, lives in the device struct, maintained by the loop,
and arrives inside the datum, so `map_input` stays pure.

A datum field naming no channel of the table throws an `ErrorException`, which
reaches the framework from the device's loop as the `DeviceCrash` it is.
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

# Design: §11.6.
# The output side's convention name, declared here for the loop idiom and never
# called by the framework.
"""
    map_output(nt, b)

Return the datum an output [binding](@ref g-binding) sends for one gathered
`NamedTuple`, by the binding's own method.

An output-side binding defines `map_output` for its type. The method receives
exactly the labeled `NamedTuple` that [`gather`](@ref) returns, keyed by the
labels of the binding's [`reads`](@ref), and what it returns for the wire is the
peer's business. The loop idiom is
`send(dev.socket, map_output(gather(handle, snapshot), binding(handle)))`, on
the [device](@ref g-device)'s own task. The framework never calls `map_output`
and ships no method. A binding that sends the values as they are returns `nt`
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

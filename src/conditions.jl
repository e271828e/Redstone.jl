# The condition algebra and its resolution (§14.1–§14.3, §14.6): the inert lazy
# tree the condition methods build, the collecting pass that validates it
# against a `Build`, and the plan §14.4's dynamic walk executes.
#
# Two properties carry the section. Composition performs no path arithmetic and
# no validation — `at` stores a prefix and never applies it — so a condition
# method is stack-only construction and a misaddressed node fails at
# resolution, where the build is in hand. And resolution finishes before
# anything is written, which is what makes `init!` all-or-nothing (§14.6).

# --- the four node kinds (§14.2, §14.6) ---------------------------------------
# Every node is isbits except the prefix strings: a `Fragment`'s payloads are
# the author's own values, and the combinators hold their operands in tuples.

# Design: §14.2, Appendix B.
"""
    Fragment

The [condition](@ref g-condition) node that sets values at one authoring level,
in that level's own vocabulary.

[`set`](@ref) returns it as the leaf of a condition, and [`at`](@ref),
[`combine`](@ref) and [`override`](@ref) take it. It holds the four
payloads `set` was given. The `x`, `s` and `m` payloads name
the declared state and modes of the [component](@ref g-component) at the
authoring level, and the `u` payload names that level's own input
[faces](@ref g-face). It holds no path, since addressing a child is `at`'s job
alone.

See also [`ConditionNode`](@ref).
"""
struct Fragment{X,S,M,L}
    x::X
    s::S
    m::M
    u::L
end

# Design: §14.2, §14.3, Appendix B.
"""
    Scoped

The [condition](@ref g-condition) node that holds another node under a path
prefix, stored and not yet applied.

[`at`](@ref) returns it from a node of a condition, and `at`, [`combine`](@ref)
and [`override`](@ref) take it. It holds the prefix and the node `at` was given.
`at` stores the prefix and never applies it: the paths join when a service
resolves the condition against its build.

See also [`ConditionNode`](@ref).
"""
struct Scoped{N}
    prefix::String
    node::N
end

# Design: §14.2, Appendix B.
"""
    Combined

The [condition](@ref g-condition) node that collects sibling nodes
symmetrically, each leaf set by at most one.

[`combine`](@ref) returns it, and [`at`](@ref), `combine` and
[`override`](@ref) take it as a node of a condition. It holds the nodes in the
order given, an order that matters only to diagnostics. Two nodes that set one
leaf are refused as `DuplicateConditionLeaf` when a service resolves the
condition, and the diagnostic names where each was authored.

See also [`ConditionNode`](@ref).
"""
struct Combined{T<:Tuple}
    nodes::T
end

# Design: §14.6, Appendix B. The fourth node kind; layering is variadic.
"""
    Override

The [condition](@ref g-condition) node that layers nodes in order, the last
layer winning on a shared leaf.

[`override`](@ref) returns it, and [`at`](@ref), [`combine`](@ref) and
`override` take it as a node of a condition. It holds the layers, the base first
and each patch after it. A leaf set in several layers takes the last layer's
value, and the origin its diagnostics report names both layers. Two entries on
one leaf within one layer are still refused as `DuplicateConditionLeaf`.

See also [`ConditionNode`](@ref).
"""
struct Override{T<:Tuple}
    layers::T
end

# Design: §14.2, §14.6, Appendix B.
"""
    ConditionNode

The union of the four [condition](@ref g-condition) node types, the type every
combinator takes.

A condition is a tree of nodes. [`set`](@ref) returns its leaf, a
[`Fragment`](@ref). [`at`](@ref) returns a [`Scoped`](@ref), [`combine`](@ref) a
[`Combined`](@ref) and [`override`](@ref) an [`Override`](@ref). `at`, `combine`
and `override` take any `ConditionNode`, and a service such as [`init!`](@ref)
takes the root node and resolves the tree against its build.
"""
const ConditionNode = Union{Fragment,Scoped,Combined,Override}

# Design: §8.1, §14.2, Appendix B, D-246.
# The generic is framework-owned so that the owner's pull crosses a package
# seam. D-246's shadowing check does not cover it.
"""
    condition(c; kw...)

Return the [component](@ref g-component)'s own [condition](@ref g-condition),
built from keywords in its own vocabulary.

A component type ships its condition as a method of this function,
`condition(c::C; kw...) = set(…)`. The owner of a structure pulls its children's
conditions under [`at`](@ref) and collects them with [`combine`](@ref), as in
`combine(at("engine", condition(sys.engine; n_eng)), …)`.

A model package extends `condition` through `import Redstone: condition`, as it
extends the declaration functions. There is no fallback method, so a child type
without one fails at its owner's pull as a `MethodError` naming it. A method
written to a package-local `condition` fails the same way, and no earlier check
catches it.
"""
function condition end

# Design: §14.1, §14.2, Appendix B.
"""
    set(; x = (;), s = (;), m = (;), u = (;)) -> Fragment

Return the leaf of a [condition](@ref g-condition), setting values on the
[component](@ref g-component) it is authored for.

A condition is a tree, and `set` builds its leaf. Each payload
is a `NamedTuple` in the vocabulary of the component at the authoring level, and
names none of its children. A store declared bare takes a bare payload, its
whole value, as in `set(x = 1.0)`. [`at`](@ref) scopes a leaf to a child, and
[`combine`](@ref) and [`override`](@ref) compose leaves.

# Keywords

- `x`: continuous state fields, by name, or a bare state's value.
- `s`: discrete state fields, by name, or a bare state's value.
- `m`: modes, by name, or a bare mode store's value. Only a
  [continuous component](@ref g-continuous-component) has modes.
- `u`: [root input](@ref g-root-input) values, named by the authoring level's
  own input [faces](@ref g-face).

A condition sets state, modes and root inputs only. It never sets outputs, and
never [workspace](@ref g-workspace). A `u` payload that is not a `NamedTuple` is
refused as `ConditionNodeMisuse` when `set` is called. A field the component
does not declare, and a bare payload for a named store or a named one for a
bare store, are refused as `ConditionResolution` when a service resolves the
condition against its build.
"""
function set(; x = (;), s = (;), m = (;), u = (;))
    _payload(:x, x); _payload(:s, s); _payload(:m, m); _payload(:u, u)
    Fragment(x, s, m, u)
end

# A store payload may be bare, its shape known only against a build, so it is
# checked at resolution (§14.3); `nothing` alone is refused here, since it
# would set nothing. A `u` payload names faces, and is checked here.
_payload(name, p) = (name === :u ? p isa NamedTuple : p !== nothing) ||
    throw(DiagnosticError(ConditionNodeMisuse(
        observed = typeof(p), reason = :set_payload, payload = name)))

# Design: §14.2, §14.3, §14.9, D-277, D-278.
# Nothing is concatenated here: the prefix is stored, and flattening at
# resolution is the one place path strings ever join (§14.3).
"""
    at(prefix::AbstractString, node::ConditionNode) -> Scoped
    at(prefix::AbstractString, read_set::Reads) -> Reads

Scope a [condition](@ref g-condition) or a [read set](@ref g-read-set) under
`prefix`, so that its paths resolve below that path.

`prefix` is a slash path relative to the level where the result is placed, such
as `"pwp/engine"`. On a node of a condition, built by [`set`](@ref) or a
combinator, `at` stores the prefix beside the node and applies nothing. The
paths join when a service resolves the condition against its build, and a path
the build does not have is refused there as `PathResolution`.

On a read set, `at` adds `prefix` to the front of the set's
[mount chain](@ref g-mounting). A service walks the chain from the root, and
rebases every [selector](@ref g-selector) onto it. Other methods of `at` scope a
[`TrimProblem`](@ref) and a tap set from [`taps`](@ref) the same way.

An empty prefix names no child, and is refused when `at` is called: as
`ConditionNodeMisuse` on a condition node, and as `ReadSetMisuse` on a read set.
A second argument of any other type is refused as `ConditionNodeMisuse`.
"""
at(prefix::AbstractString, node::ConditionNode) =
    isempty(prefix) ? throw(DiagnosticError(ConditionNodeMisuse(
        observed = typeof(prefix), reason = :empty_prefix))) : Scoped(String(prefix), node)
# A read set is no condition node, and `Scoped` never wraps one: the prefix joins
# the set's own mount chain, walked at resolution (§14.9, D-277).
at(prefix::AbstractString, read_set::Reads) =
    isempty(prefix) ? throw(DiagnosticError(ReadSetMisuse(
        observed = typeof(prefix), reason = :empty_prefix))) :
    Reads((String(prefix), read_set.prefixes...), read_set.selectors)
at(::AbstractString, other) = _node_misuse(other, ())

# Design: §14.2, D-065, D-204.
# Collision-intolerant by design, and the layering spelling is `override`.
# `Base.merge` is last-writer-wins on NamedTuples, the exact semantics D-065
# rejects here.
"""
    combine(nodes::ConditionNode...) -> Combined

Return one [condition](@ref g-condition) collecting the sibling nodes, each leaf
set by at most one of them.

`combine` is symmetric and collision-intolerant. Each node is part of a
condition, built by [`set`](@ref), [`at`](@ref) or a combinator, and their order
matters only to diagnostics. Two nodes that set one leaf are refused as
`DuplicateConditionLeaf` when a service resolves the condition, and the
diagnostic names where each was authored. To layer one node over another, use
[`override`](@ref).

`combine` is not `Base.merge` and does not extend it. A bare `NamedTuple` beside
a node is refused as `ConditionNodeMisuse` when `combine` is called; wrap it in
`set(…)` first. Any other argument that is not a condition node is refused the
same way.
"""
combine(nodes::ConditionNode...) = Combined(nodes)

# The blend of a node with a bare NamedTuple, both orders: an error method,
# raised at composition time — before any resolution pass runs or any origin
# exists, which is why it carries its own kind rather than a
# `ConditionResolution` sub-kind (§14.2).
combine(left::ConditionNode, right::NamedTuple) =
    _node_misuse(right, (nameof(typeof(left)),))
combine(left::NamedTuple, right::ConditionNode) =
    _node_misuse(left, (nameof(typeof(right)),))
combine(nodes...) = _misuse_in(nodes)

# Design: §14.6.
# The use case is "baseline plus tweaks": the collision with `combine`'s
# duplicate-leaf error is the intent.
"""
    override(base::ConditionNode, patches::ConditionNode...) -> Override

Return one [condition](@ref g-condition) layering each patch over the layers
before it, the last layer winning on a shared leaf.

`override` layers conditions in order, where [`combine`](@ref) collects them
symmetrically. It serves a [baseline](@ref g-baseline) with patches over it, and
[`trim!`](@ref) commits `override(baseline, solution)`. A leaf set in several
layers takes the last layer's value, and the origin its diagnostics report names
both layers. Two entries on one leaf within one layer are still refused as
`DuplicateConditionLeaf` when a service resolves the condition.

A `u` entry's leaf is the [root input](@ref g-root-input) it resolves to, not
the [face](@ref g-face) it was written with. A baseline authored at the root
therefore layers cleanly under a patch that a [component](@ref g-component)'s
own [`condition`](@ref) method writes against its local face.

An argument that is not a condition node is refused as `ConditionNodeMisuse`
when `override` is called.
"""
override(base::ConditionNode, patches::ConditionNode...) = Override((base, patches...))
override(layers...) = _misuse_in(layers)

_misuse_in(args::Tuple) = _node_misuse(args[findfirst(n -> !(n isa ConditionNode), args)],
                                       Tuple(nameof(typeof(n)) for n in args if n isa ConditionNode))

_node_misuse(v, in_hand) = throw(DiagnosticError(ConditionNodeMisuse(
    observed = typeof(v), in_hand = Symbol[in_hand...])))

# --- flattening (§14.3) --------------------------------------------------------
# The only place path strings are ever concatenated: a recursion with a path
# accumulator, carrying the origin beside it — the `at` prefixes and
# the payload position, which is what a collision diagnostic reports.
#
# An input entry's *leaf* is the root input its face resolves to, not the face
# it was written with, so the export chain is walked here, at the same moment
# the paths join, and the resolved face becomes the entry's key. Two spellings
# of one root input are then one leaf everywhere it matters: `override` layers
# them and `combine` collides on them, which is what §14.6's central use case —
# a root-level baseline under a component-local patch — requires.
#
# The recursion carries a third accumulator, the entry's **tree position**
# (§14.3): the `getfield`/`getindex` step tuple from the root node down to the
# authored value, in the step form the reader's chains take (`AccessStep`,
# readers.jl). The dynamic walk ignores it — it bakes the value itself — and
# the specialized `apply!` lifts it to a type parameter, the lens, which is
# what lets one compiled plan be applied to every later tree of the same shape.

struct CEntry
    path::String
    store::Symbol        # :x | :s | :m | :input
    field::Symbol
    value::Any
    origin::String
    face::Union{Nothing,Symbol}   # input entries: the root input the chain lands on
    position::Tuple{Vararg{AccessStep}}   # the tree position: the step tuple to this value
end

_key(entry::CEntry) = entry.face === nothing ? (entry.path, entry.store, entry.field) :
                                               ("", :input, entry.face)
_step(origin::String, label::String) = isempty(origin) ? label : origin * " → " * label

function _flat(node::Fragment, path::String, level, origin::String, tree_position::Tuple,
               structure::Structure, decls::Vector{Decls}, diags::Vector{Diagnostic})
    out = CEntry[]
    for (store, name, payload) in ((:x, :x, node.x), (:s, :s, node.s),
                                   (:m, :m, node.m), (:input, :u, node.u))
        # A bare store payload is one entry under `BARE`, its tree position the
        # payload itself.
        for (field, v) in (store === :input ? pairs(payload) : store_fields(payload))
            entry = CEntry(path, store, field, v, _step(origin, _named("set($name)", field)),
                           nothing, field === BARE ? (tree_position..., name) :
                                                     (tree_position..., name, field))
            store === :input &&
                (entry = CEntry(entry.path, entry.store, entry.field, entry.value, entry.origin,
                                _root_input(structure, decls, entry, diags), entry.position))
            push!(out, entry)
        end
    end
    out
end

function _flat(node::Scoped, path::String, level, origin::String, tree_position::Tuple,
               structure::Structure, decls::Vector{Decls}, diags::Vector{Diagnostic})
    scoped_origin = _step(origin, "at(\"$(node.prefix)\")")
    child = resolve_authored(scoped_origin, path, level, node.prefix, structure, diags)
    child === nothing && return CEntry[]      # the path is the offender, reported once
    _flat(node.node, _join(path, node.prefix), child, scoped_origin,
          (tree_position..., :node), structure, decls, diags)
end

_flat(node::Combined, path::String, level, origin::String, tree_position::Tuple,
      structure::Structure, decls::Vector{Decls}, diags::Vector{Diagnostic}) =
    reduce(vcat, (_flat(child, path, level, _step(origin, "combine[$i]"),
                        (tree_position..., :nodes, (i,)), structure, decls, diags)
                  for (i, child) in enumerate(node.nodes)); init = CEntry[])

# Layering (§14.6): each layer is flattened and checked on its own — a
# within-layer collision is still an error — and then folded onto the
# accumulator, the patch replacing the leaf it overrode and inheriting its
# origin beside its own.
function _flat(node::Override, path::String, level, origin::String, tree_position::Tuple,
               structure::Structure, decls::Vector{Decls}, diags::Vector{Diagnostic})
    layered = CEntry[]
    for (i, layer) in enumerate(node.layers)
        label = i == 1 ? "override[base]" : "override[patch $(i - 1)]"
        layer_entries = _flat(layer, path, level, _step(origin, label), (tree_position..., :layers, (i,)),
                              structure, decls, diags)
        _check_duplicates!(layer_entries, diags)
        for entry in layer_entries
            overridden = findfirst(a -> _key(a) == _key(entry), layered)
            overridden === nothing ? push!(layered, entry) :
                (layered[overridden] =
                     CEntry(entry.path, entry.store, entry.field, entry.value,
                            "$(entry.origin) (overrode $(layered[overridden].origin))",
                            entry.face, entry.position))
        end
    end
    layered
end

# `combine`'s one collision rule, collected rather than thrown (§13.1): both
# origins and the directive naming the layering combinator.
function _check_duplicates!(entries::Vector{CEntry}, diags::Vector{Diagnostic})
    seen = Dict{Tuple{String,Symbol,Symbol},CEntry}()
    for entry in entries
        key = _key(entry)
        if haskey(seen, key)
            push!(diags, DuplicateConditionLeaf(path = entry.path, store = entry.store,
                                               field = entry.field, face = entry.face,
                                               origins = [seen[key].origin, entry.origin]))
        else
            seen[key] = entry
        end
    end
    nothing
end

# --- the compiled plan (§14.3) --------------------------------------------------

"""
What a resolved condition compiles to (§14.3): per continuous-state leaf its
`xbuf` offset, per discrete or mode store the whole value the write installs —
`merge(defaults, overlay)`, the genuine last-wins NamedTuple merge baked here
(§14.1's fork, not the condition combinator) — and per root input its compiled
cell address. Every value has been through its leaf's converter already, so
application is a walk with no decisions left in it.

`faces` is the plan's root-input coverage, in entry order: the resolution-time
operand of §14.6's totality check.

`T` is the activation the plan was resolved at: the offsets, addresses and
converters baked here are that activation's, so `apply!` pairs plan and
executor by dispatch and a mismatch is the internal-invariant refusal build.jl
raises (§14.4).
"""
struct ConditionPlan{T}
    xs::Vector{Tuple{Int,Any}}             # (xbuf offset, value)
    stores::Vector{Tuple{Symbol,Int,Any}}  # (:s | :m, component index, whole store value)
    inputs::Vector{Tuple{Any,Any}}         # (cell address, value)
    faces::Vector{Symbol}
end

# --- resolution (§14.3) ---------------------------------------------------------

"""
    resolve_condition(node, build::Build, T = Float64; bases = nothing) → ConditionPlan

Flatten the condition tree, validate every entry against `build` in §13.1's
collecting form — full list, violations collected, one `DiagnosticError` — and
compile what survives to a plan.

The checks are §14.3's: the path resolves to a component, the field is
declared in that component's `x_init`/`s_init`/`m_init`, the value converts to
the declared leaf type, an input face resolves through the export chain to a
root input, and no leaf is written twice — an input entry's leaf being the
*root input* it resolves to, so two spellings of one root input are one leaf.
Schema is the
authority on *may you write this, at what type*; the activation's layout
supplies the destination. `bases` is the merge base of a partial store entry,
the declared defaults when `nothing` (D-063) and the stores a door hands,
`_store_bases`' triples, otherwise (D-429).
"""
function resolve_condition(node::ConditionNode, build::Build, ::Type{T} = Float64;
                           bases = nothing) where {T}
    resolved, diags, act = _resolve_entries(node, build, T)
    _report_violations(diags)

    xs = Tuple{Int,Any}[]
    inputs = Tuple{Any,Any}[]
    faces = Symbol[]
    overlays = Dict{Tuple{Symbol,Int},Vector{Pair{Symbol,Any}}}()
    for survivor in resolved
        entry = survivor.entry
        if entry.store === :input
            push!(inputs, (survivor.dest, survivor.converted))
            push!(faces, entry.face)
        elseif entry.store === :x
            push!(xs, (survivor.dest, survivor.converted))
        else
            push!(get!(() -> Pair{Symbol,Any}[], overlays, (entry.store, survivor.dest)),
                  entry.field => survivor.converted)
        end
    end

    # Overlay partiality baked now (§14.3): the store's write is one whole
    # value, `merge(base, overlay)`, so application decides nothing. The base is
    # the declared defaults, `init!`'s, unless the door hands its own, as
    # `overlay!` hands the stores as they stand (§14.1, D-429).
    stores = Tuple{Symbol,Int,Any}[]
    for (store, ci, base) in (bases === nothing ? _store_bases(build, act) : bases)
        overlay = get(overlays, (store, ci), nothing)
        overlay === nothing && continue
        push!(stores, (store, ci, convert(typeof(base), _store_overlay(base, (; overlay...)))))
    end
    ConditionPlan{T}(xs, stores, inputs, faces)
end

# --- the collecting pass, shared by both (§14.3, §13.1) -------------------------

"""
One entry that survived §14.3's checks, beside everything either one needs
to bake from it. The two differ in *what* they bake — the dynamic one
takes `converted`, the specialized one lifts `entry.position` to a lens and
keeps `leaf_type` as the converter — and in nothing else, which is why the
checks have one implementation.
"""
struct Resolved
    entry::CEntry
    dest::Any   # :x → the `xbuf` offset; :s, :m → the component index; :input → the cell address
    leaf_type::Any # the destination leaf type at this activation — §14.3's converter
    converted::Any # the authored value, through that converter
end

# §14.3's list, run once: the path resolves to a component, the field is
# declared in that component's `x_init`/`s_init`/`m_init`, the value converts to
# the declared leaf type, an input face resolves through the export chain to a
# root input, and no leaf is written twice. Violations are collected (§13.1) and
# handed back with the survivors, so a service that owns its own setup
# diagnostic can fold the same list into its kind.
function _resolve_entries(node::ConditionNode, build::Build, ::Type{T}) where {T}
    structure = build.structure
    act = activation(build, T)
    decls, layout = act.decls, act.layout
    diags = Diagnostic[]
    entries = _flat(node, "", first(structure.levels).instance, "", (), structure, decls, diags)
    _check_duplicates!(entries, diags)

    out = Resolved[]
    for entry in entries
        if entry.store === :input
            entry.face === nothing && continue     # the chain was reported at flattening
            addr = layout.addr[("", entry.face)]
            port_type = _port_type(addr)
            (ok, v) = _convert(port_type, entry.value)
            ok || (push!(diags, _unconvertible(entry, entry.value, port_type, T)); continue)
            push!(out, Resolved(entry, addr, port_type, v))
            continue
        end
        ci = _component(structure, entry, diags)
        ci === nothing && continue
        comp_entry = structure.components[ci]
        comp, tier, decl = comp_entry.instance, comp_entry.tier, decls[ci]
        declared = entry.store === :x ? decl.x : entry.store === :s ? decl.s : m_init(comp)
        if declared === nothing
            push!(diags, _no_store(entry, tier))
            continue
        end
        # The declared shape and the payload's agree, bare against bare.
        (declared isa NamedTuple) == (entry.field !== BARE) ||
            (push!(diags, _condition_violation(entry, :store_shape;
                candidates = declared isa NamedTuple ? collect(keys(declared)) : Symbol[]));
             continue)
        declared isa NamedTuple && !haskey(declared, entry.field) &&
            (push!(diags, _undeclared(entry, comp, tier, declared, T)); continue)
        leaf_type = typeof(declared isa NamedTuple ? declared[entry.field] : declared)
        (ok, v) = _convert(leaf_type, entry.value)
        ok || (push!(diags, _unconvertible(entry, entry.value, leaf_type, T)); continue)
        push!(out, Resolved(entry,
                            entry.store === :x ?
                                first(layout.xblocks[ci]) - 1 + _leaf_offset(decl.x, entry.field) : ci,
                            leaf_type, v))
    end
    (out, diags, act)
end

# The merge bases, in one order both walk: per component, the discrete
# store's declared defaults and then the mode store's (§14.3's fork).
_store_bases(build::Build, act::Activation) =
    [(store, ci, store === :s ? act.decls[ci].s : m_init(comp_entry.instance))
     for (ci, comp_entry) in enumerate(build.structure.components) for store in (:s, :m)]

# Anything that is not a node reaching a service entry point is the §14.2
# misuse, not a `MethodError`: the directive is the same one `combine` prints,
# and a bare NamedTuple handed to `init!` is exactly the slip it addresses.
resolve_condition(other, ::Build, ::Type = Float64; bases = nothing) = _node_misuse(other, ())

# A store's `merge(defaults, overlay)`: field by field for a named store, the
# overlay's one value for a bare one (§14.1, §14.3).
_store_overlay(defaults::NamedTuple, overlay::NamedTuple) = merge(defaults, overlay)
_store_overlay(defaults, overlay::NamedTuple) = only(overlay)

# A leaf's offset in its component's `x` block; a bare state is the block itself.
_leaf_offset(x, ::Symbol) = 0
function _leaf_offset(x::NamedTuple, field::Symbol)
    offset = 0
    for (k, v) in pairs(x)
        k === field && return offset
        offset += nleaves(typeof(v))
    end
    offset
end

_convert(::Type{P}, v) where {P} =
    try
        (true, convert(P, v))
    catch
        (false, nothing)
    end

# One `ConditionResolution` off an entry: the leaf coordinates and the
# origin are the entry's own, and each arm adds what it observed.
_condition_violation(entry::CEntry, reason::Symbol; kw...) =
    ConditionResolution(; path = entry.path, store = entry.store, field = entry.field,
                        face = entry.face, reason = reason, origin = entry.origin, kw...)

# The component a non-input entry addresses. Every `at` prefix was walked at its
# own authoring level (§13.3), so the path names a level of this build: what is
# left to say is that the level owns no state. Assemblies are virtual for
# execution (§10.5) and own no state, so an `at` prefix stopping at one has
# nothing to write — and saying so beats "no such path".
function _component(structure::Structure, entry::CEntry, diags::Vector{Diagnostic})
    ci = findfirst(comp_entry -> comp_entry.path == entry.path, structure.components)
    ci === nothing || return ci
    push!(diags, _condition_violation(entry, :assembly_path))
    nothing
end

# A `u` payload names a face of the authoring level's contract, whatever
# that level's class; resolution walks the export chain to the root input and
# errors if the face never surfaces (§14.2). The chain's resolution is a
# function over the level rows' wires, total under one-level routing (§9.2,
# D-207): a face's producer is either a root input or an internal port, and a
# component-fed face reaches none — writing it would be meaningless, because
# the first sweep overwrites it.
function _root_input(structure::Structure, decls::Vector{Decls}, entry::CEntry,
                     diags::Vector{Diagnostic})
    producer = _face_producer(structure, decls, entry.path, entry.field)
    if producer === nothing
        push!(diags, isempty(entry.path) ?
                     _condition_violation(entry, :unexported_face; candidates = structure.root_inputs) :
                     _condition_violation(entry, :no_input_face;
                                          candidates = _input_faces_at(structure, decls,
                                                                       entry.path)))
        return nothing
    end
    isempty(first(producer)) && return last(producer)
    push!(diags, _condition_violation(entry, :internally_wired; producer = producer))
    nothing
end

# The store a condition names has to exist on the component at all: `x` is the
# continuous tier's state and `s` the discrete one's, disjoint by construction
# (D-195), and `m` is continuous-only (§3.2).
_no_store(entry::CEntry, tier::Tier) =
    _condition_violation(entry, :no_store; tier = Symbol(tier_word(tier)))

# An undeclared field, discriminated against the component's other name
# families: a condition specifies state, modes and root inputs — never outputs,
# which are derived data, and never workspace (§14.1).
function _undeclared(entry::CEntry, comp, tier::Tier, declared::NamedTuple,
                     ::Type{T}) where {T}
    role = haskey(declared_at(y_types, comp, tier), entry.field) ? :output_port :
           haskey(declared_at(u_types, comp, tier), entry.field) ? :input_face :
           (_declares_workspace(comp) &&
            haskey(_declared_workspace(comp, tier, T), entry.field)) ? :workspace : nothing
    _condition_violation(entry, :undeclared_field; candidates = collect(keys(declared)), role = role)
end

_declared_workspace(comp, tier::Tier, ::Type{T}) where {T} =
    ws_init(comp, tier === CONTINUOUS ? T : Float64)

# The one refusal §14.3's converter table cannot bake around. Its second clause
# is the non-nominal case: at a seeded activation the leaves a decision descends
# into are the ones the activation retyped, and a *frozen* discrete `s` (§9.4,
# D-166) or a leaf a `Pinned` declaration holds at `Float64` is not one of them —
# so the value cannot be carried and there is nowhere to put its partials.
function _unconvertible(entry::CEntry, v, ::Type{P}, ::Type{T}) where {P,T}
    _condition_violation(entry, :unconvertible; declared = P, observed = typeof(v), value = v,
                         activation = _seeded_into_pinned(typeof(v), P, T) ? T : nothing)
end

_seeded_into_pinned(::Type{V}, ::Type{P}, ::Type{T}) where {V,P,T} =
    T !== Float64 && T in leaf_types(V) && !(T in leaf_types(P))

# §13.1's collecting form: the full list, every violation, one throw.
function _report_violations(diags::Vector{Diagnostic})
    isempty(diags) && return nothing
    throw(DiagnosticError(diags))
end

# --- root-input totality (§14.6) ------------------------------------------------

"""
§14.6's precondition of starting, checked by the service and *not* a property
of conditions, which are legitimately partial: an application establishing a
complete world over virgin stores covers every root input. Coverage is a
plan-level fact — both operands are resolution-time data — so the check is one
comparison and runs before any evaluation, not merely before any write. A
shortfall is one collected, declaration-ordered `UninitializedInputs` naming
every uncovered face (D-068).

The services path contains no call to `probe_value`: a root input gets a
condition value or the application errors, and there is no third branch. A
fabricated zero is a fine probe input and a terrible flight condition.
"""
function assert_total(plan::ConditionPlan, structure::Structure, op::Symbol)
    covered = Set(plan.faces)
    uncovered = [f for f in structure.root_inputs if !(f in covered)]
    isempty(uncovered) && return nothing
    throw(DiagnosticError(UninitializedInputs(op = op, faces = uncovered)))
end

# --- the dynamic walk (§14.4) ----------------------------------------------------

"""
    apply!(exec::Executor, plan)
    apply!(model, plan)
    apply!(sim, plan)

§14.4's dynamic walk: execute the validated entry list by runtime dispatch per
write — microseconds total, allocation permitted, the stopped-sim path never
having been under §9.8's zero-alloc regime — with no per-shape codegen, so
fifty structurally different scripted conditions cost fifty walks rather than
fifty compiles. Which way a service uses is internal, never user-facing:
the specialized `apply!` below is the other way over the same checks, for
the services that hold one shape fixed and vary its values.
"""
function apply!(exec::Executor{T}, plan::ConditionPlan{T}) where {T}
    for (offset, v) in plan.xs
        flatten!(exec.xbuf, offset, v)
    end
    for (store, ci, v) in plan.stores
        (store === :s ? exec.sstores : exec.mstores)[ci][] = v
    end
    for (addr, v) in plan.inputs
        scatter_cell!(exec.store, addr, v)
    end
    nothing
end

apply!(::Executor{S}, ::ConditionPlan{T}) where {S,T} =
    _activation_mismatch("plan", T, S)

# --- the specialized `apply!` (§14.3, §14.4, D-066) ------------------------------
# The other way over the same checks. The dynamic walk bakes *values*, so a
# plan is good for one tree; this one bakes *lenses*, so a plan compiled from a
# tree's shape applies to every later tree of that shape. That is the trade
# §14.4 states: codegen once per shape, against a per-iteration
# write with no strings, no dispatch and no allocation — the shape being fixed
# and the values varying is exactly what an iterating service does.
#
# All string work, addressing and validation are functions of the shape, so all
# of it happens here, once. What survives into `apply!` is a tuple of baked
# writes and a tuple of prefix compares.

"""
One leaf's compiled read half. `P` is the lens (§14.3, glossary): the entry's
tree position lifted to a type parameter, which `walk_steps` unrolls into
static `getfield`/`getindex` steps on any tree of the compiled shape. `L` is
the destination leaf type at this activation — which *is* §14.3's converter,
selected once at resolution and never consulted again.

Both of §14.3's cases are this one call. A leaf already at the activation's
scalar takes the type's own methods, partials flowing through untouched; a
plain `Float64` leaf against a seeded activation takes the zero-partial
embedding `convert` already performs, which is semantically exact for a value
held at the operating point and in no other case.
"""
struct Authored{P,L} end

@inline (::Authored{P,L})(tree) where {P,L} = convert(L, walk_steps(tree, Val(P)))

# The three destinations, one write each: the flat state buffer at a baked
# offset, a component's own store as one whole value, and a root input's cell.

struct XWrite{A}
    authored::A
    offset::Int
end

struct InputWrite{A,D}
    authored::A
    addr::D
end

# The `s`/`m` fork (§14.3): the store's write is one whole value,
# `merge(defaults, overlay)`, with the base baked and the overlay's fields read
# through their lenses; a bare store's overlay is the value itself. `K` is `:s`
# or `:m` and `S` the store's value type, both in the type — `S` because the
# stores are held in a `Vector{Any}` and the assertion has to go on the
# *reference*: asserting the dereferenced value instead leaves the `[]` a
# dynamic call, which boxes.
struct StoreWrite{K,S,F,A<:Tuple}
    ci::Int
    defaults::S
    authored::A
end

StoreWrite{K,S,F}(ci::Int, defaults::S, authored::A) where {K,S,F,A<:Tuple} =
    StoreWrite{K,S,F,A}(ci, defaults, authored)

@inline _write!(w::XWrite, exec::Executor, tree) =
    flatten!(exec.xbuf, w.offset, w.authored(tree))

@inline _write!(w::InputWrite, exec::Executor, tree) =
    scatter_cell!(exec.store, w.addr, w.authored(tree))

@inline function _write!(w::StoreWrite{K,S,F}, exec::Executor, tree) where {K,S,F}
    overlay = NamedTuple{F}(_authored_values(w.authored, tree))
    ((K === :s ? exec.sstores : exec.mstores)[w.ci]::Base.RefValue{S})[] =
        convert(S, _store_overlay(w.defaults, overlay))
    nothing
end

# One store's authored fields can number 32 or more, so their values are an
# unrolled tuple rather than a `map` (executor.jl's `_unrolled_tuple`).
@generated _authored_values(authored::Tuple, tree) =
    _unrolled_tuple(i -> :(authored[$i](tree)), fieldcount(authored))

# One `Scoped` node's prefix: the tree type carries the nesting, every field
# name and every leaf type, but a prefix is a runtime `String` field, so the
# plan records the one it was compiled from and `apply!` closes the remainder
# with a `===` compare. On `String` that compare is *content* equality rather
# than pointer identity — `egal` is specialized for it — so what the sweep tests
# is that the prefix still spells the same path, whether it was written as a
# literal or computed afresh per iteration (`at("gear/$i", …)`); the cost is a
# length check and a short `memcmp`, and in the all-literal case the compiler
# folds it away.
struct Prefix{P}
    expected::String
end

"""
What a condition *shape* compiles to (§14.3, §14.4): the tree type it was
compiled from in the plan's own type, and its writes as tuples, so `apply!`
unrolls into the same machine operations an in-place write would be.

Application is `apply!(exec, plan, tree)` for any tree of that shape. Nothing is
decided there: the destinations, the converters and the merge bases were all
settled at compile time, and what is left is the fold-away shape check plus the
writes.

`T`, the leading parameter, is the activation the plan was compiled at — the
same identity `Reader` carries, for the same reason: the lenses' converters and
the writes' destinations are one activation's, and pairing them with another's
executor is refused as an internal-invariant violation (build.jl, §14.4) rather
than a wrong slot.
"""
struct SpecializedPlan{T,NT,XS<:Tuple,ST<:Tuple,IN<:Tuple,PF<:Tuple}
    xs::XS
    stores::ST
    inputs::IN
    prefixes::PF
end

SpecializedPlan{T,NT}(xs::XS, stores::ST, inputs::IN, prefixes::PF) where {T,NT,XS,ST,IN,PF} =
    SpecializedPlan{T,NT,XS,ST,IN,PF}(xs, stores, inputs, prefixes)

"""
    compile_plan(node, build::Build, T = Float64) → SpecializedPlan

Compile a condition tree's **shape** into the specialized `apply!`'s plan,
running exactly the checks `resolve_condition` runs — one implementation, in
§13.1's collecting form, the two differing only in what they bake
(§14.3).

The tree handed here is a genuine tree, and its values matter to exactly one
check: convertibility, which is where a decision variable authored into a
frozen or pinned leaf is refused. Everything else the compile reads is shape —
paths, field names, tree positions, the destination leaf types at this
activation.
"""
function compile_plan(node::ConditionNode, build::Build, ::Type{T} = Float64) where {T}
    resolved, diags, act = _resolve_entries(node, build, T)
    _report_violations(diags)

    xs, inputs = Any[], Any[]
    overlays = Dict{Tuple{Symbol,Int},Vector{Resolved}}()
    for survivor in resolved
        entry = survivor.entry
        if entry.store === :input
            push!(inputs, InputWrite(Authored{entry.position,survivor.leaf_type}(), survivor.dest))
        elseif entry.store === :x
            push!(xs, XWrite(Authored{entry.position,survivor.leaf_type}(), survivor.dest))
        else
            push!(get!(() -> Resolved[], overlays, (entry.store, survivor.dest)), survivor)
        end
    end

    stores = Any[]
    for (store, ci, defaults) in _store_bases(build, act)
        overlay = get(overlays, (store, ci), nothing)
        overlay === nothing && continue
        push!(stores, StoreWrite{store,typeof(defaults),Tuple(r.entry.field for r in overlay)}(
            ci, defaults, Tuple(Authored{r.entry.position,r.leaf_type}() for r in overlay)))
    end

    SpecializedPlan{T,typeof(node)}(Tuple(xs), Tuple(stores), Tuple(inputs),
                                    Tuple(Prefix{p}(v) for (p, v) in _scoped_prefixes(node)))
end

compile_plan(other, ::Build, ::Type = Float64) = _node_misuse(other, ())

# Every `Scoped` node's prefix field, positioned, in tree order. A separate walk
# from `_flat`'s: a prefix belongs to a *node*, not to a leaf, and a scope
# wrapping no payload at all still has a prefix that can drift.
function _scoped_prefixes(node::ConditionNode)
    out = Tuple{Tuple{Vararg{AccessStep}},String}[]
    _scoped!(node, (), out)
    out
end

_scoped!(::Fragment, ::Tuple, ::Vector) = nothing
_scoped!(node::Scoped, tree_position::Tuple, out::Vector) =
    (push!(out, ((tree_position..., :prefix), node.prefix));
     _scoped!(node.node, (tree_position..., :node), out))
_scoped!(node::Combined, tree_position::Tuple, out::Vector) =
    for (i, child) in enumerate(node.nodes)
        _scoped!(child, (tree_position..., :nodes, (i,)), out)
    end
_scoped!(node::Override, tree_position::Tuple, out::Vector) =
    for (i, child) in enumerate(node.layers)
        _scoped!(child, (tree_position..., :layers, (i,)), out)
    end

"""
    apply!(exec::Executor{T}, plan::SpecializedPlan{T,NT}, tree::NT)

§14.4's specialized walk: write every leaf of `tree` through its baked lens and
converter — `x` leaves flattened at their offsets, each `s` and `m` store as one
whole `merge(defaults, overlay)` value, root inputs scattered — with no
allocation, no string work and no dispatch left in the path.

**The shape check is folded.** The tree type is proven by dispatch: `NT` carries
the full nesting, every field name and every leaf type, so a tree of another
shape does not match this method and reaches the fallback below. The `===` sweep
over the `Scoped` prefixes closes the remainder, those being runtime fields the
type cannot carry. This is §9.5's mechanism transferred: on conformant code the
compiler decides it and deletes it, and drift is a structured error rather than
silent corruption.

The sweep runs before any write, so a refused application leaves the executor
exactly as it found it.
"""
function apply!(exec::Executor{T}, plan::SpecializedPlan{T,NT}, tree::NT) where {T,NT}
    _sweep_prefixes(plan.prefixes, tree)
    _writes!(plan.xs, exec, tree)
    _writes!(plan.stores, exec, tree)
    _writes!(plan.inputs, exec, tree)
    nothing
end

apply!(::Executor{T}, ::SpecializedPlan{T,NT}, tree) where {T,NT} =
    _shape_drift(NT, typeof(tree))

apply!(::Executor{S}, ::SpecializedPlan{T}, tree) where {S,T} =
    _activation_mismatch("plan", T, S)

# A plan's writes and prefixes are as many as the tree authors, so both walks
# are generated unrolls through executor.jl's `_unrolled` (§14.4).
@generated _writes!(writes::Tuple, exec::Executor, tree) =
    _unrolled(i -> :(_write!(writes[$i], exec, tree)), fieldcount(writes))

@generated _sweep_prefixes(prefixes::Tuple, tree) =
    _unrolled(i -> :(_compare(prefixes[$i], tree)), fieldcount(prefixes))

@inline function _compare(prefix::Prefix{P}, tree) where {P}
    observed = walk_steps(tree, Val(P))
    observed === prefix.expected || _prefix_drift(P, prefix.expected, observed)
    nothing
end

@noinline _shape_drift(::Type{NT}, ::Type{O}) where {NT,O} = throw(DiagnosticError(
    ConditionShapeDrift(reason = :tree_type, compiled = NT, observed = O)))

@noinline _prefix_drift(tree_position::Tuple, expected::String,
                        observed::String) = throw(DiagnosticError(
    ConditionShapeDrift(reason = :prefix, compiled = expected, observed = observed,
                        position = tree_position)))

# --- the descriptor (§13.9, D-432) --------------------------------------------
# `descriptor` renders a `Build` or a `Deployment` to data, beside `show`'s
# rendering to text: a tree of `NamedTuple`s, vectors, strings, numbers and
# Booleans whose shape `schema/descriptor.json` fixes. A field that does not
# apply is omitted, never `nothing`, and a collection keyed by data is a vector
# of objects carrying `name`. The core encodes nothing to text; the consumer
# does, and the suite validates the round trip (`test_descriptor.jl`).

"The format's own version, independent of the package's (§13.9)."
const DESCRIPTOR_FORMAT = (major = 1, minor = 0)

# The declarations whose method locations a type's row carries, in this order.
const LOCATED_DECLARATIONS = (u_types, y_types, x_init, s_init, m_init, sample_times,
                              local_wires, input_wires, output_wires, stop_reason,
                              transparent_container)

"""
    descriptor(build)
    descriptor(deployment)

The artifact rendered to data under the published format (§13.9, D-432): the
envelope with its `format_version`, `redstone_version` and `kind`, and the
body under the key the kind names. A deployment's body embeds the build's
whole. The value is a tree of `NamedTuple`s and vectors, ready for any JSON
encoder, and conforms to `schema/descriptor.json`.
"""
descriptor(build::Build) = _envelope("build", _build_body(build))
descriptor(deployment::Deployment) =
    _envelope("deployment", (build = _build_body(deployment.build),))

_envelope(kind::String, body) =
    (; format_version = DESCRIPTOR_FORMAT,
       redstone_version = string(pkgversion(@__MODULE__)),
       kind,
       NamedTuple{(Symbol(kind),)}((body,))...)

_build_body(build::Build) =
    (structure = _structure_section(build.structure), outputs = _outputs_section(build.outputs))

# --- the structure section ------------------------------------------------------

function _structure_section(structure::Structure)
    nodes, instances = _nodes(structure)
    (nodes = nodes,
     root_inputs = [_leaf_face(face, T) for (face, T) in zip(structure.root_inputs, structure.root_types)],
     anchors = [(T = _rational(anchor.T), tau = _rational(anchor.τ),
                 scope = anchor.scope, key = String(anchor.key))
                for anchor in structure.anchors],
     scopes = [(path = scope.path, key = String(scope.key), timing = scope.timing)
               for scope in structure.scopes],
     types = _type_rows(instances))
end

_rational(x::Rational{Int}) = (num = numerator(x), den = denominator(x))

# The nodes in walk order, assemblies included: a pre-order walk from the root's
# level row through each assembly's children, as the structure step walked them.
# Beside them the instances in the same order, for the `types` table.
function _nodes(structure::Structure)
    levels = Dict(level.path => level for level in structure.levels)
    leaves = Dict(entry.path => entry for entry in structure.components)
    nodes, instances = NamedTuple[], Any[]
    _push_nodes!(nodes, instances, levels, leaves, "", (path = "",))
    nodes, instances
end

function _push_nodes!(nodes::Vector{NamedTuple}, instances::Vector{Any},
                      levels::Dict{String,LevelEntry}, leaves::Dict{String,ComponentEntry},
                      path::String, identity::NamedTuple)
    if haskey(leaves, path)
        push!(nodes, _leaf_node(identity, leaves[path]))
        push!(instances, leaves[path].instance)
        return
    end
    level = levels[path]
    push!(nodes, _assembly_node(identity, level))
    push!(instances, level.instance)
    for child in level.children
        child_path = isempty(path) ? child.segment : path * "/" * child.segment
        _push_nodes!(nodes, instances, levels, leaves, child_path, _identity(child_path, child))
    end
end

# A node's `path`, `field` and `key`: the field alone for a component field, the
# key beside it for a container element (§8.5, D-211).
function _identity(path::String, child::Child)
    field = String(child.field)
    kind = membership(child)
    kind === :field && return (path = path, field = field)
    key = kind === :container ? child.segment[length(field)+2:end] : child.segment
    (path = path, field = field, key = key)
end

function _leaf_node(identity::NamedTuple, entry::ComponentEntry)
    instance = entry.instance
    merge(identity,
          (class = "leaf", tier = tier_word(entry.tier), timing = entry.timing,
           type = _qualified_name(typeof(instance)), signature = _type_string(typeof(instance)),
           inputs = _leaf_faces(u_types, instance), outputs = _leaf_faces(y_types, instance),
           parameters = _parameters(instance)))
end

function _assembly_node(identity::NamedTuple, level::LevelEntry)
    instance = level.instance
    merge(identity,
          (class = "assembly",
           type = _qualified_name(typeof(instance)), signature = _type_string(typeof(instance)),
           inputs = [(name = String(face),) for face in _boundary_inputs(level)],
           outputs = [(name = String(face),) for face in _boundary_outputs(level)],
           wires = [(from = _endpoint(producer), to = _endpoint(consumer))
                    for (producer, consumer) in level.wires],
           parameters = _parameters(instance)))
end

_endpoint((path, port)::Tuple{String,Symbol}) = (path = path, port = String(port))

# --- faces and the kind marker --------------------------------------------------

# A leaf's faces as declared, a `Pinned` entry unwrapped and flagged (§13.9).
function _leaf_faces(fn, @nospecialize(instance))
    _declares(fn, instance) || return NamedTuple[]
    decl = invoke_declaration(fn, instance)
    NamedTuple[_leaf_face(name, P) for (name, P) in pairs(decl)]
end

function _leaf_face(name::Symbol, @nospecialize(P::Type))
    pinned = _is_marker(P)
    T = pinned ? P.parameters[1] : P
    (name = String(name), type = _type_string(T), kind = _kind_marker(T), pinned = pinned)
end

# §13.9's table: the first row that matches, tested in order because `Bool` and
# every `Enum` are `Integer`s. The `struct` row is a value the leaf walk opens,
# an isbits value with fields; a handle the walk stores whole is opaque, and so
# is a function type whatever its captures (D-237, D-433).
function _kind_marker(@nospecialize(T::Type))
    T <: Bool && return (kind = "boolean",)
    T <: Enum && isconcretetype(T) &&
        return (kind = "enum", values = [string(v) for v in instances(T)])
    T <: Symbol && return (kind = "symbol",)
    T <: Integer && return (kind = "integer",)
    T <: AbstractFloat && return (kind = "float",)
    T <: Real && return (kind = "number",)
    T <: StaticArray && return (kind = "vector", shape = collect(Int, size(T)),
                                element = _kind_marker(eltype(T)))
    T <: Function && return (kind = "opaque",)
    fields = _struct_fields(T)
    fields === nothing ? (kind = "opaque",) : (kind = "struct", fields = fields)
end

# The field names of an isbits `NamedTuple` or struct with fields, what the leaf
# walk opens; `nothing` for anything else, a handle or an abstract type included.
function _struct_fields(@nospecialize(T::Type))
    T isa DataType && isbitstype(T) && fieldcount(T) > 0 || return nothing
    [String(name) for name in fieldnames(T)]
end

# --- type identity and the instance context -------------------------------------

# The qualified base name (§13.9): the type's module and its unparameterized name.
_qualified_name(@nospecialize(T::Type)) =
    string(parentmodule(T), ".", nameof(T))

# A type printed in full, parameters included, as the REPL would print it. It is
# display text: the stable identity is the qualified base name.
_type_string(@nospecialize(T::Type)) = string(T)

# The inert fields of an instance (§8.5): those the walk classifies as neither a
# component nor a container of components, as `repr` text cut at 80 characters.
function _parameters(@nospecialize(instance))
    parameters = NamedTuple[]
    for name in fieldnames(typeof(instance))
        value = getfield(instance, name)
        value isa AbstractComponent && continue
        _is_container(value) && nfields(value) > 0 && continue
        text = repr(value; context = (:compact => true, :limit => true))
        length(text) > 80 && (text = first(text, 80) * "…")
        push!(parameters, (name = String(name), value = text))
    end
    parameters
end

# One row per qualified base name, in first-appearance order over the nodes.
function _type_rows(instances::Vector{Any})
    rows = NamedTuple[]
    seen = Set{String}()
    for instance in instances
        T = typeof(instance)
        name = _qualified_name(T)
        name in seen && continue
        push!(seen, name)
        docstring = _docstring(T)
        row = (name = name,)
        docstring === nothing || (row = merge(row, (docstring = docstring,)))
        push!(rows, merge(row, (locations = _locations(instance),)))
    end
    rows
end

# The type's docstring as its Markdown source, `nothing` when it has none.
function _docstring(@nospecialize(T::Type))
    binding = Base.Docs.Binding(parentmodule(T), nameof(T))
    meta = Base.Docs.meta(parentmodule(T); autoinit = false)
    meta === nothing && return nothing
    haskey(meta, binding) || return nothing
    multidoc = meta[binding]
    signature = haskey(multidoc.docs, Union{}) ? Union{} : first(multidoc.order)
    join(String.(multidoc.docs[signature].text))
end

# The declaration methods the type defines, by the fixed order of
# `LOCATED_DECLARATIONS`, each as the file and line Julia reports.
function _locations(@nospecialize(instance))
    rows = NamedTuple[]
    for fn in LOCATED_DECLARATIONS
        _declares(fn, instance) || continue
        method = which(fn, Tuple{typeof(instance)})
        push!(rows, (var"function" = String(nameof(fn)), file = String(method.file), line = Int(method.line)))
    end
    rows
end

# --- the outputs section --------------------------------------------------------

_outputs_section(outputs::Outputs) =
    (order = [outputs.components[ci].path for ci in outputs.order],
     components = [(path = row.path, stage1 = String.(row.stage1), stage2 = String.(row.stage2))
                   for row in outputs.components])

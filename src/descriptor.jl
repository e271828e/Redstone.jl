# --- the descriptor (§13.9, D-432, D-434) ---------------------------------------
# `descriptor` renders a `Build`, a `Deployment` or a carrier exception to
# data, beside `show`'s rendering to text: a tree of `NamedTuple`s, vectors, strings, numbers and
# Booleans whose shape `src/descriptor.json` fixes. A field that does not
# apply is omitted, never `nothing`, and a collection keyed by data is a vector
# of objects carrying `name`. The core encodes nothing to text; the consumer
# does, and the suite validates the round trip (`test_descriptor.jl`).

"The format's own version, independent of the package's (§13.9)."
const DESCRIPTOR_FORMAT = (major = 1, minor = 0)

# The declarations whose method locations a type's row carries, in this order.
const LOCATED_DECLARATIONS = (u_types, y_types, x_init, s_init, m_init, sample_times,
                              local_wires, input_wires, output_wires, stop_reason,
                              transparent_container)

# Design: §13.9, D-432, D-434.
"""
    descriptor(build::Build) -> NamedTuple
    descriptor(deployment::Deployment) -> NamedTuple
    descriptor(err::DiagnosticError) -> NamedTuple

Return the artifact's [descriptor](@ref g-descriptor), its rendering to data.

The descriptor is an envelope with the fields `format_version`,
`redstone_version` and `kind`, and the body under the key the kind names,
`build`, `deployment` or `failure`. A deployment's body embeds the build's
whole. A failure's body holds the carrier's diagnostics and warnings, each as
its kind, severity, path and rendered message, and the complete `Structure`
when the build failed past the structure step, so a client can draw the model
with the error marked on it.

The value is a tree of `NamedTuple`s and vectors, ready for any JSON encoder,
and conforms to the schema the package ships as `src/descriptor.json`.
Encoding it is the caller's job.

See also [`Build`](@ref), [`Deployment`](@ref), and the
[carrier exception](@ref g-carrier-exception) `DiagnosticError`.
"""
descriptor(build::Build) = _envelope("build", _build_body(build))
descriptor(deployment::Deployment) =
    _envelope("deployment", (build = _build_body(deployment.build),))
descriptor(err::DiagnosticError) = _envelope("failure", _failure_body(err))

_envelope(kind::String, body) =
    (; format_version = DESCRIPTOR_FORMAT,
       redstone_version = string(pkgversion(@__MODULE__)),
       kind,
       NamedTuple{(Symbol(kind),)}((body,))...)

_build_body(build::Build) =
    (structure = _structure_section(build.structure), outputs = _outputs_section(build.outputs),
     warnings = [_diagnostic(d) for d in build.warnings])

# --- the failure body (D-434) ---------------------------------------------------

# The policy off the type parameter, the structure when the carrier holds one,
# then the diagnostics and the warnings. The carried value is one diagnostic or
# the collection; either way the body lists it.
function _failure_body(err::DiagnosticError)
    body = (policy = err.carried isa Diagnostic ? "fail-fast" : "collected",)
    err.structure === nothing ||
        (body = merge(body, (structure = _structure_section(err.structure),)))
    carried = err.carried isa Diagnostic ? [err.carried] : err.carried
    merge(body, (diagnostics = [_diagnostic(d) for d in carried],
                 warnings = [_diagnostic(d) for d in err.warnings]))
end

# A diagnostic as its rendering plus the marks a drawing needs, never its payload
# (§13.9, D-434): the four fields every kind carries, then `function`, `marks`
# and `cycle` from the kinds whose payload holds the fact.
function _diagnostic(d::Diagnostic)
    row = (kind = string(nameof(typeof(d))), severity = string(severity(d)),
           path = path(d), message = message(d))
    fn = _function(d)
    fn === nothing || (row = merge(row, (var"function" = fn,)))
    ports, wires = _marks(d)
    isempty(ports) && isempty(wires) || (row = merge(row, (marks = (ports = ports, wires = wires),)))
    d isa AlgebraicCycle ? merge(row, (cycle = _cycle(d),)) : row
end

# The user method at fault, for the probe-chain kinds.
_function(::Diagnostic) = nothing
_function(d::UserCodeFraming) = d.fn
_function(d::ConformanceFailure) = d.what
_function(d::DeadStage) = d.stage
_function(d::UndeclaredReturnField) = d.stage

# The endpoints and wires a kind names beyond its path: the consumer's input as
# a port, and the producer-to-consumer wire where the payload holds both ends.
# `TwoProducers` spells its producers as text, so it marks its destination alone.
_marks(::Diagnostic) = (NamedTuple[], NamedTuple[])
_marks(d::UnconnectedInput) = ([_endpoint((d.path, d.face))], NamedTuple[])
_marks(d::TwoProducers) = ([_endpoint((d.path, d.port))], NamedTuple[])
_marks(d::WireTypeMismatch) = _consumer_wire(d)
_marks(d::WalkingFaceAtFrozenEntry) = _consumer_wire(d)
_consumer_wire(d) =
    ([_endpoint((d.path, d.face))],
     [(from = _endpoint((d.producer_path, d.producer_port)), to = _endpoint((d.path, d.face)))])

# The cluster as data: members, wires as terminal pairs, the verdict when the
# trace reached one, the dead hops and each member's tracing mode (§13.8).
function _cycle(d::AlgebraicCycle)
    cycle = (members = d.members,
             wires = [(from = _terminal_endpoint(p), to = _terminal_endpoint(c))
                      for (p, c) in d.wires])
    d.classification === nothing ||
        (cycle = merge(cycle, (classification = string(d.classification),)))
    merge(cycle, (dead = [(path = m, input = String(f), output = String(o)) for (m, f, o) in d.dead],
                  traced = [(path = m, mode = string(mode)) for (m, mode) in d.traced]))
end

# A cycle wire's end, `path/port`, a bare port's under its default face (D-437):
# a face holds no `/`, so the last one splits the path from the port.
function _terminal_endpoint(terminal::String)
    i = findlast('/', terminal)
    (path = terminal[1:prevind(terminal, i)], port = terminal[nextind(terminal, i):end])
end

# --- the structure section ------------------------------------------------------

function _structure_section(structure::Structure)
    nodes, node_instances = _nodes(structure)
    (nodes = nodes,
     root_inputs = [_leaf_face(face, T) for (face, T) in zip(structure.root_inputs, structure.root_types)],
     anchors = [(T = _rational(anchor.T), tau = _rational(anchor.τ),
                 scope = anchor.scope, key = String(anchor.key))
                for anchor in structure.anchors],
     scopes = [(path = scope.path, key = String(scope.key), timing = scope.timing)
               for scope in structure.scopes],
     types = _type_rows(node_instances))
end

_rational(x::Rational{Int}) = (num = numerator(x), den = denominator(x))

# The nodes in walk order, assemblies included: a pre-order walk from the root's
# level row through each assembly's children, as the structure step walked them.
# Beside them the instances in the same order, for the `types` table.
function _nodes(structure::Structure)
    levels = Dict(level.path => level for level in structure.levels)
    leaves = Dict(entry.path => entry for entry in structure.components)
    nodes, node_instances = NamedTuple[], Any[]
    _push_nodes!(nodes, node_instances, levels, leaves, "", (path = "",))
    nodes, node_instances
end

function _push_nodes!(nodes::Vector{NamedTuple}, node_instances::Vector{Any},
                      levels::Dict{String,LevelEntry}, leaves::Dict{String,ComponentEntry},
                      path::String, identity::NamedTuple)
    if haskey(leaves, path)
        push!(nodes, _leaf_node(identity, leaves[path]))
        push!(node_instances, leaves[path].instance)
        return
    end
    level = levels[path]
    push!(nodes, _assembly_node(identity, level))
    push!(node_instances, level.instance)
    for child in level.children
        child_path = isempty(path) ? child.segment : path * "/" * child.segment
        _push_nodes!(nodes, node_instances, levels, leaves, child_path, _identity(child_path, child))
    end
end

# A node's `path`, `field` and `key`: the field alone for a component field, the
# key beside it for a container element (§8.5, D-211).
function _identity(path::String, child::Child)
    field = String(child.field)
    joined = membership(child)
    joined === :field && return (path = path, field = field)
    key = joined === :container ? chopprefix(child.segment, field * "/") : child.segment
    (path = path, field = field, key = key)
end

function _leaf_node(identity::NamedTuple, entry::ComponentEntry)
    instance = entry.instance
    merge(identity,
          (class = "leaf", tier = tier_word(entry.tier), timing = entry.timing),
          _type_identity(typeof(instance)),
          (inputs = _leaf_faces(u_types, instance), outputs = _leaf_faces(y_types, instance),
           parameters = _parameters(instance)))
end

function _assembly_node(identity::NamedTuple, level::LevelEntry)
    instance = level.instance
    merge(identity,
          (class = "assembly",),
          _type_identity(typeof(instance)),
          (inputs = [(name = String(face),) for face in _boundary_inputs(level)],
           outputs = [(name = String(face),) for face in _boundary_outputs(level)],
           wires = [(from = _endpoint(producer), to = _endpoint(consumer))
                    for (producer, consumer) in level.wires],
           parameters = _parameters(instance)))
end

_endpoint((path, port)::Tuple{String,Symbol}) = (path = path, port = String(port))

# --- faces and the kind marker --------------------------------------------------

# A leaf's faces as declared, a `Pinned` entry unwrapped and flagged, a bare
# contract's one face named `u` or `y` (§13.9, D-437).
function _leaf_faces(fn, @nospecialize(instance))
    _declares(fn, instance) || return NamedTuple[]
    decl = invoke_declaration(fn, instance)
    NamedTuple[_leaf_face(name, P) for (name, P) in pairs(_keyed(decl, default_name(fn)))]
end

function _leaf_face(name::Symbol, @nospecialize(declared::Type))
    pinned = _is_marker(declared)
    face_type = pinned ? declared.parameters[1] : declared
    (name = String(name), type = _type_string(face_type), kind = _kind_marker(face_type), pinned = pinned)
end

# §13.9's table: the first row that matches, tested in order because `Bool` is
# an `Integer`. The `struct` row is a value the leaf walk opens, an isbits value
# with fields, a tuple's fields its positions; a handle the walk stores whole is
# opaque, and so is a function type whatever its captures, and a static array
# whose size is left free (D-237, D-433).
function _kind_marker(@nospecialize(face_type::Type))
    face_type <: Bool && return (kind = "boolean",)
    face_type <: Enum && isconcretetype(face_type) &&
        return (kind = "enum", values = [string(v) for v in instances(face_type)])
    face_type <: Symbol && return (kind = "symbol",)
    face_type <: Integer && return (kind = "integer",)
    face_type <: AbstractFloat && return (kind = "float",)
    face_type <: Real && return (kind = "number",)
    if face_type <: StaticArray
        shape = _static_shape(face_type)
        shape === nothing && return (kind = "opaque",)
        return (kind = "vector", shape = shape, element = _kind_marker(eltype(face_type)))
    end
    face_type <: Function && return (kind = "opaque",)
    fields = _struct_fields(face_type)
    fields === nothing ? (kind = "opaque",) : (kind = "struct", fields = fields)
end

# A static array's shape as integers, read off its `StaticArray` supertype so a
# `FieldVector` subtype answers too, or `nothing` where a dimension is a free
# parameter, as in a bare `StaticVector` declaration.
function _static_shape(@nospecialize(face_type::Type))
    array_type = Base.unwrap_unionall(face_type)
    while array_type.name !== Base.typename(StaticArray)
        array_type = supertype(array_type)
    end
    sizes = array_type.parameters[1]
    sizes isa DataType && all(n -> n isa Int, sizes.parameters) || return nothing
    collect(Int, sizes.parameters)
end

# The field names of an isbits `NamedTuple`, tuple or struct with fields, what
# the leaf walk opens; `nothing` for anything else, a handle or an abstract type
# included.
function _struct_fields(@nospecialize(face_type::Type))
    face_type isa DataType && isbitstype(face_type) && fieldcount(face_type) > 0 || return nothing
    [string(name) for name in fieldnames(face_type)]
end

# --- type identity and the instance context -------------------------------------

# A node's `type`, `alias` when the type has one, and `signature` (§13.9).
function _type_identity(@nospecialize(component_type::Type))
    alias = _alias(component_type)
    identity = (type = _qualified_name(component_type),)
    alias === nothing || (identity = merge(identity, (alias = alias,)))
    merge(identity, (signature = _type_string(component_type),))
end

# The qualified base name (§13.9): the type's module and its unparameterized name.
_qualified_name(@nospecialize(component_type::Type)) =
    string(parentmodule(component_type), ".", nameof(component_type))

# The qualified name of the most specific `const` of the type's own module that
# binds a parameterization of it, `SumJunction` for a `Junction` at `+`, or
# `nothing`: the base binding itself never counts, and neither does a supertype.
function _alias(@nospecialize(component_type::Type))
    mod = parentmodule(component_type)
    base = Base.unwrap_unionall(component_type)
    matches = Pair{Symbol,Type}[]
    for name in names(mod; all = true)
        bound = _constant(mod, name)
        bound isa DataType || bound isa UnionAll || continue
        Base.unwrap_unionall(bound).name === base.name && bound !== base.name.wrapper &&
            component_type <: bound && push!(matches, name => bound)
    end
    isempty(matches) && return nothing
    sort!(matches; by = first)
    narrowest = [m for m in matches if all(m.second <: n.second for n in matches)]
    string(mod, ".", first(isempty(narrowest) ? matches : narrowest).first)
end

# A module's constant binding by name, or `nothing` for anything else; a binding
# that is declared but unassigned makes `isconst` throw.
_constant(mod::Module, name::Symbol) =
    try
        isconst(mod, name) ? getfield(mod, name) : nothing
    catch
        nothing
    end

# A type printed in full, parameters included, as the REPL would print it. It is
# display text: the stable identity is the qualified base name.
_type_string(@nospecialize(printed_type::Type)) = string(printed_type)

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
function _type_rows(node_instances::Vector{Any})
    rows = NamedTuple[]
    seen = Set{String}()
    for instance in node_instances
        component_type = typeof(instance)
        name = _qualified_name(component_type)
        name in seen && continue
        push!(seen, name)
        docstring = _docstring(component_type)
        row = (name = name,)
        docstring === nothing || (row = merge(row, (docstring = docstring,)))
        push!(rows, merge(row, (locations = _locations(instance),)))
    end
    rows
end

# The type's docstring as its Markdown source, `nothing` when it has none.
function _docstring(@nospecialize(component_type::Type))
    doc_binding = Base.Docs.Binding(parentmodule(component_type), nameof(component_type))
    meta = Base.Docs.meta(parentmodule(component_type); autoinit = false)
    meta === nothing && return nothing
    haskey(meta, doc_binding) || return nothing
    multidoc = meta[doc_binding]
    signature = haskey(multidoc.docs, Union{}) ? Union{} : first(multidoc.order)
    join(multidoc.docs[signature].text)    # an interpolated docstring holds the values among its parts
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

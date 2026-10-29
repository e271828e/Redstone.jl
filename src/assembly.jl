# Hierarchy (§8.5, §8.6, §6.1): class by declaration shape, path resolution, and
# the flatten pass. Assemblies are virtual for execution (§10.5) — what leaves
# this file is a flat list of primitives with their absolute paths and one
# resolved producer per input, and nothing downstream knows the tree existed.

# --- class (§8.5) -------------------------------------------------------------
# Class is not announced either: `local_wires` is the assembly marker, any
# leaf declaration a primitive's, and the rule is total — a component-typed
# struct declaring neither family has no class to read.

@enum Class PRIMITIVE ASSEMBLY

const ASSEMBLY_FAMILY = (:local_wires,)
const LEAF_FAMILY = (:x_init, :s_init, :m_init, :ws_init, :u_types,
                     :y_types, :state_events, :y_state, :y_direct,
                     :x_deriv, :s_update, :x_projection)

# The six `DECLARATION_FAMILY` names no leaf declaration covers: the assembly
# marker, the two boundary declarations, the two sugars and the stop reason.
const _OTHER_FAMILY = ((:local_wires, local_wires),
                       (:input_wires, input_wires),
                       (:output_wires, output_wires),
                       (:sample_times, sample_times),
                       (:transparent_container, transparent_container),
                       (:stop_reason, stop_reason))

"""The leaf declarations `comp` defines, in inventory order (§8.2, §8.5)."""
function leaf_declarations(@nospecialize(comp))
    found = Symbol[]
    for (name, fn) in ((:x_init, x_init), (:s_init, s_init), (:m_init, m_init))
        _declares(fn, comp) && push!(found, name)
    end
    _declares(ws_init, comp, Type{Float64}) && push!(found, :ws_init)
    for (name, fn) in ((:u_types, u_types), (:y_types, y_types))
        _declares(fn, comp) && push!(found, name)
    end
    _declares(state_events, comp) && push!(found, :state_events)
    for (name, fn) in ((:y_state, y_state), (:y_direct, y_direct),
                       (:x_deriv, x_deriv), (:s_update, s_update),
                       (:x_projection, x_projection))
        has_stage(fn, comp) && push!(found, name)
    end
    found
end

"""The `DECLARATION_FAMILY` names `comp` defines, in family order (§8.1, §8.5)."""
function declarations_found(@nospecialize(comp))
    found = leaf_declarations(comp)
    for (name, fn) in _OTHER_FAMILY
        _declares(fn, comp) && push!(found, name)
    end
    Symbol[n for n in DECLARATION_FAMILY if n in found]
end

"""The class of `comp` at `path`, or a `DiagnosticError` naming what makes it unreadable."""
function classify(path::String, @nospecialize(comp))
    leaves = leaf_declarations(comp)
    if _declares(local_wires, comp)
        isempty(leaves) ||
            throw(DiagnosticError(ClassMixed(path = path, declarations = leaves)))
        return ASSEMBLY
    end
    isempty(leaves) || return PRIMITIVE
    throw(DiagnosticError(ClassUnreadable(path = path, type = _typename(comp),
                                     found = declarations_found(comp),
                                     assembly_family = collect(ASSEMBLY_FAMILY),
                                     leaf_family = collect(LEAF_FAMILY),
                                     holds_components = _holds_components(comp))))
end

# A producer terminal spelled for a payload string: a component's port, or the
# root's own input face, whose path is the empty one.
_terminal(terminal::Tuple{String,Symbol}) =
    isempty(first(terminal)) ? "root input `$(last(terminal))`" : _at_port(terminal...)
_join(path::String, segment::String) = isempty(path) ? segment : path * "/" * segment

# A loop, because a `do` closure would capture `comp` (see `_walk!`).
function _holds_components(@nospecialize(comp))
    for name in fieldnames(typeof(comp))
        v = getfield(comp, name)
        (v isa AbstractComponent ||
         ((v isa NamedTuple || v isa Tuple) && any(e -> e isa AbstractComponent, v))) &&
            return true
    end
    false
end

# --- children (§8.5) ----------------------------------------------------------
# Fields whose type is `<: AbstractComponent` are children, the field name their
# path segment. A `Tuple` or `NamedTuple` field whose elements are *all*
# components is a container: transparent grouping with no contract and no wiring
# of its own, contributing its elements as children *of the parent*, path-named
# `"field/1"…"field/N"` or `"field/key"`. Every other field is inert parameter
# data.
#
# One container field per type may be declared **name-transparent** (D-211), and
# its elements are then contributed under their bare keys — `"key"`, `"1"` —
# everywhere a child name appears. Naming is the only thing the declaration
# changes: the elements are the parent's children exactly as before, in the same
# declaration order, and the container keeps its transparency of contract. What
# pays for it is one declaration check — the declared symbol must name a
# container field — and a collision family in three arms: no two children may
# end up sharing a name, and the two collisions a bare key reaches that no child
# name can, its own field's name (which the rate declaration's sugar already
# spells) and a sibling container field's name, where that field contributes
# children (whose `"field/key"` segment grammar it would shadow).

"""`segment => instance` for every child of `comp`, in field order."""
children(path::String, @nospecialize(comp)) = first(_children(path, comp))

"""
`(kids, fields)`: the children of `comp` as `segment => instance` pairs, and per
child the field name that contributed it — the rate declaration's second key
form, the bare field name applying one entry to every element of a container
(§8.7). The sugar keys on the *field*, so a name-transparent container keeps it
unchanged.
"""
function _children(path::String, @nospecialize(comp))
    transparent_field = invoke_declaration(transparent_container, comp)
    kids = Pair{String,Any}[]
    fields = Symbol[]
    contributors = String[]                    # per child, who contributed it
    # The child-naming pass collects (§13.1): every field is walked, and the
    # whole violation list leaves through one throw at the end. A component with
    # three mixed containers reports three, not the first.
    diags = Diagnostic[]
    # The sibling fields a bare key could shadow: those that currently contribute
    # children, because the grammar a key shadows is the one that currently
    # reaches something. An empty field reserves nothing, and it has to be that
    # way round: an empty `Tuple` or `NamedTuple` is an empty container and empty
    # inert parameter data at once — the value cannot tell them apart, and the
    # walk below already treats them as one case — so reserving every empty
    # field's name would refuse a bare key over inert data, a false positive
    # where no shadow exists. Legality is then per-instantiation, which is the
    # framework's norm: every wire is validated against the instance too.
    # Collected before the walk, because the shadowed field may be declared
    # after the transparent one.
    # A loop, because a comprehension's closure would capture `comp` (see `_walk!`).
    shadowable = String[]
    for name in fieldnames(typeof(comp))
        value = getfield(comp, name)
        name !== transparent_field && _is_container(value) && nfields(value) > 0 &&
            push!(shadowable, String(name))
    end
    for name in fieldnames(typeof(comp))
        value = getfield(comp, name)
        if value isa AbstractComponent
            push!(kids, Pair{String,Any}(string(name), value))
            push!(fields, name)
            push!(contributors, "field `$name`")
        elseif value isa NamedTuple || value isa Tuple
            # Elements and keys as vectors: a generic walk over the tuple itself
            # compiles once per container type.
            elements, element_keys = _elements(value), _element_keys(value)
            n_components = count(e -> e isa AbstractComponent, elements)
            if n_components == 0
                # Inert data, an empty container too — unless an element is
                # itself a container bearing components, the nesting §8.5
                # refuses in the first cut.
                nested = [i for i in eachindex(elements) if _bears_component(elements[i])]
                isempty(nested) ||
                    push!(diags, ContainerNested(path = path, field = name, keys = element_keys[nested],
                                                types = [_typespell(typeof(elements[i])) for i in nested]))
                continue
            end
            if n_components != length(elements)
                mixed = [i for i in eachindex(elements) if !(elements[i] isa AbstractComponent)]
                push!(diags, ContainerMixed(path = path, field = name, keys = element_keys[mixed],
                                           types = unique([_typespell(typeof(elements[i])) for i in mixed])))
                continue
            end
            bare = name === transparent_field
            for (key, element) in zip(element_keys, elements)
                contributor = "$(bare ? "name-transparent " : "")container field `$name`, element `$key`"
                # The collision family's other two arms, both reachable only by a
                # bare key and neither of them a duplicate *child* name, so
                # `_check_child_names` below can see neither (§8.5, D-211, D-212).
                hit = false
                if bare && string(key) == string(name)
                    push!(diags, ChildNameCollision(path = path, name = string(key),
                                                   reason = :sample_times_sugar,
                                                   declarations = [contributor], field = name))
                    hit = true
                end
                if bare && string(key) in shadowable
                    push!(diags, ChildNameCollision(path = path, name = string(key),
                                                   reason = :sibling_field,
                                                   declarations = [contributor]))
                    hit = true
                end
                hit && continue                    # a shadowed key names no child
                push!(kids, Pair{String,Any}(bare ? string(key) : string(name, "/", key), element))
                push!(fields, name)
                push!(contributors, contributor)
            end
        end
    end
    _check_transparent(path, comp, transparent_field, diags)
    _check_child_names(path, kids, contributors, diags)
    isempty(diags) || throw(DiagnosticError(diags))
    kids, fields
end

# The container form, the empty one included — it contributes zero children, and
# parametric code then needs no special case (§8.5).
_is_container(@nospecialize(v)) =
    (v isa NamedTuple || v isa Tuple) && all(e -> e isa AbstractComponent, _elements(v))

# A container's elements and keys (`Symbol`s or indices), as untyped vectors.
# Loops, because a comprehension's closure would capture `v` (see `_walk!`).
function _elements(@nospecialize(v))
    elements = Vector{Any}(undef, nfields(v))
    for i in eachindex(elements)
        elements[i] = getfield(v, i)
    end
    elements
end
# The names are read once: `fieldname` per element dispatches on the names tuple
# at a cost that grows with its width, which made the list quadratic.
function _element_keys(@nospecialize(v))
    names = fieldnames(typeof(v))
    element_keys = Vector{Any}(undef, nfields(v))
    for i in eachindex(element_keys)
        element_keys[i] = getfield(names, i)
    end
    element_keys
end

# The container fields of `comp`'s type: what a name-transparent declaration may name.
# A loop, because a comprehension's closure would capture `comp` (see `_walk!`).
function _container_fields(@nospecialize(comp))
    container_fields = Symbol[]
    for name in fieldnames(typeof(comp))
        _is_container(getfield(comp, name)) && push!(container_fields, name)
    end
    container_fields
end

# A container holding a component at any depth: the shape `ContainerNested` names.
_bears_component(@nospecialize(v)) = (v isa NamedTuple || v isa Tuple) &&
                      any(e -> e isa AbstractComponent || _bears_component(e), _elements(v))

# The declaration is checked after the walk, so a mixed container reports as one
# rather than as a bad transparency declaration.
function _check_transparent(path::String, @nospecialize(comp), transparent_field, diags::Vector{Diagnostic})
    transparent_field === nothing && return nothing
    ok = transparent_field in fieldnames(typeof(comp)) &&
        _is_container(getfield(comp, transparent_field))
    ok || push!(diags, TransparentContainerUnknown(path = path, field = transparent_field,
                                                  component = _typename(comp),
                                                  candidates = _container_fields(comp)))
    nothing
end

# General, not transparency-specific: whatever mix of fields and containers
# produced them, two children may not share a name. Bare keys make the case
# reachable, but the rule is the older one — a child name is a path segment, and
# a path segment addresses one component.
function _check_child_names(path::String, kids, contributors, diags::Vector{Diagnostic})
    for i in eachindex(kids), j in 1:(i - 1)
        first(kids[i]) == first(kids[j]) &&
            push!(diags, ChildNameCollision(path = path, name = first(kids[i]),
                                           reason = :two_children,
                                           declarations = [contributors[j], contributors[i]]))
    end
    nothing
end

# --- paths (§8.6, §6.1) -------------------------------------------------------
# Slash-separated, relative to the declaring assembly, no leading slash: the one
# canonical form, used verbatim in declarations and in error messages. A terminal
# path's last segment is a port or face name; the prefix names one child. Deep
# structural paths survive on the read side — inspection, the face routes, the
# table accessors — and nowhere in the three wiring declarations (D-207).

"""
Resolve terminal `path` against assembly `assembly` at `base`, returning the component
it names, that component's absolute path, and the final segment — or recording
the refusal in `diags` and returning `nothing` (§13.1).

§6.1's one-level rule lives here (D-207): a connection endpoint names an
**immediate child and one of its faces** — one child segment, plus the key
segment where the child is a container element (`"units/1/e"` is one level, not
two), and one face name. Anything deeper is a build error whatever the declared
field types along it, which is why the generic-holding question never arises in
wiring resolution: an endpoint stops before any field it could traverse past
(§13.3). Faces are the only currency crossing a boundary, so a route through
several levels is declared level by level, each assembly speaking of its own
children alone.

The child segment alone is the endpoint of a bare port, one with no face
(D-436), and resolves with the name `BARE`; the caller checks it against the
child's contract on its side. An empty path, or an empty last segment, names
no terminal.
"""
function resolve_terminal(entry::String, base::String, @nospecialize(assembly), path::AbstractString,
                          diags::Vector{Diagnostic}; owner::String = _at_path(base))
    segments = String.(split(path, '/'))
    if isempty(last(segments))
        push!(diags, PathResolution(entry = entry, spelling = String(path),
                                   reason = :not_a_terminal, owner = owner))
        return nothing
    end
    # A container element's key segment is part of its child segment, so a
    # two-segment path naming the element is the child alone, not a face.
    alone = length(segments) == 1 ||
            any(kid -> first(kid) == path, _walked_children(base, assembly))
    resolved = _one_level(entry, base, assembly, path, segments, alone ? 0 : 1, diags; owner)
    resolved === nothing && return nothing
    kid, segment = resolved
    kid, _join(base, segment), alone ? BARE : Symbol(segments[end])
end

# The child half of the rule, shared by both of §13.3's path primitives: `tail`
# is how many segments follow the child — one face name for a terminal path,
# none for `resolve`'s bare child path. Container children match under their
# D-211 naming, which is what the two-segment lookahead serves: an undeclared
# container's element spends two segments on the child, a transparent one's
# spends one, and neither is "deeper".
function _one_level(entry::String, base::String, @nospecialize(assembly), path::AbstractString,
                    segments::Vector{String}, tail::Int, diags::Vector{Diagnostic};
                    owner::String = _at_path(base))
    kids = _walked_children(base, assembly)
    child_index = findfirst(kid -> first(kid) == segments[1], kids)
    child_index === nothing && length(segments) > 1 + tail &&
        (child_index = findfirst(kid -> first(kid) == segments[1] * "/" * segments[2], kids))
    if child_index === nothing
        push!(diags, PathResolution(entry = entry, spelling = String(path),
                                   reason = :unknown_child, owner = owner,
                                   segment = segments[1],
                                   candidates = String[first(k) for k in kids]))
        return nothing
    end
    segment, kid = kids[child_index]
    if count(==('/'), segment) + 1 + tail != length(segments)
        push!(diags, PathResolution(entry = entry, spelling = String(path),
                                   reason = :reaches_past, owner = owner,
                                   segment = segment, level = _join(base, segment), tail = tail))
        return nothing
    end
    kid, segment
end

# --- §13.3's build primitives -------------------------------------------------
# The four the declaration surface calls: `resolve` and `resolve_terminal` in
# their public, entry-less forms, plus the two face-list accessors. Those are the
# *wiring resolution* of §13.3's table — the one-level rule verbatim, the same
# walk wiring resolution runs, entered from a declaration body with no wiring
# entry to attribute the failure to. `resolve_authored`, at the end of this
# file, is *the service walk*, entered by the services with an entry to
# attribute the refusal to.

# Design: §6.1, D-207, D-211.
"""
    resolve(assembly, path::AbstractString) -> AbstractComponent

Return the immediate child of an [assembly](@ref g-assembly) that `path` names.

`resolve` walks the assembly's declared fields along the `/` segments of
`path`. The path names one child: its field's name, plus a key segment where
the child is an element of a [container field](@ref g-container-children), as in
`"units/1"` or `"units/left"`. The elements of a container declared
name-transparent with [`transparent_container`](@ref) go by their bare keys,
`"1"` or `"left"`. Declaration bodies such as [`input_wires`](@ref) call it to
compute entries from a child's [contract](@ref g-contract).

Resolution goes one level only. A path that reaches past the child it names is
refused as `PathResolution`, naming that child. An empty path, and a segment
that names no child, are refused as `PathResolution` too.
"""
function resolve(@nospecialize(assembly), path::AbstractString)
    who = "`resolve` on `$(nameof(typeof(assembly)))`"
    isempty(path) &&
        throw(DiagnosticError(PathResolution(entry = who, spelling = "", reason = :empty_path,
                                        owner = "the component in hand")))
    # A declaration body is user code (§13.1), so the one recorded refusal throws
    # alone here rather than reaching the step's list.
    diags = Diagnostic[]
    resolved = _one_level(who, "", assembly, path, String.(split(path, '/')), 0, diags;
                          owner = "the component in hand")
    resolved === nothing && throw(DiagnosticError(only(diags)))
    first(resolved)
end

"""
    resolve_terminal(assembly, path) → (component, name)

The terminal split: the final segment is the port or face name, the prefix
resolves through `resolve`. The split is unambiguous because face names may
contain dots, never slashes (§8.6). A path naming a child alone is the endpoint
of a bare port, and its name is the empty one (D-436).
"""
function resolve_terminal(@nospecialize(assembly), path::AbstractString)
    diags = Diagnostic[]
    resolved = resolve_terminal("`resolve_terminal` on `$(nameof(typeof(assembly)))`",
                                "", assembly, path, diags;
                                owner = "the component in hand")
    resolved === nothing && throw(DiagnosticError(only(diags)))   # declaration code: fail-fast
    comp, _, name = resolved
    comp, String(name)
end

# A contract declaration at nominal, whatever the tier, in its declared shape: the
# keys are a tier-independent fact, and the walk at `Float64` strips every
# `Pinned` (D-263). A bare contract is its one type (D-436).
function _contract(fn, @nospecialize(comp))
    _declares(fn, comp) || return NamedTuple()
    decl = invoke_declaration(fn, comp)
    decl isa NamedTuple ? map(P -> retype_entry(Float64, P), decl) : retype_entry(Float64, decl)
end

# The `name => type` pairs of a contract in its declared shape: a `NamedTuple`'s
# own entries, one `BARE` pair for a bare contract (D-436).
contract_fields(decl) = pairs(_keyed(decl))

# Does a contract in its declared shape have the port an endpoint names? The
# child segment alone names a bare contract's port, a face name a named one's
# entry (D-436).
_has_port(decl, name::Symbol) =
    name === BARE ? !(decl isa NamedTuple) : decl isa NamedTuple && haskey(decl, name)

# Design: §13.3, Appendix C.
# Inside a walk the walk has already evaluated the body once and this primitive
# does not evaluate it again; standalone the primitive evaluates it. A leaf's
# keys are asked at the nominal `Float64`.
"""
    input_faces(comp) -> Vector{String}

Return the [component](@ref g-component)'s input [face](@ref g-face) names, in
declaration order.

For a primitive the input faces are the keys of its [`u_types`](@ref), which do
not depend on the scalar type, and a bare `u_types` lists as one empty name. For
an [assembly](@ref g-assembly) they are the face names its
[`input_wires`](@ref) declares. Declaration order is kept, so
printouts are deterministic and diagnostics stable.

Called from a declaration body during a build, `input_faces` reuses the build's
evaluation of the child's declaration rather than evaluating it again. Either
way the vector returned is a fresh one, the caller's to change.

See [`output_faces`](@ref) for the output side, and
[`input_passthrough`](@ref) for the helper built on it.
"""
input_faces(@nospecialize(comp)) = classify("", comp) === PRIMITIVE ?
                 String[String(k) for (k, _) in contract_fields(_contract(u_types, comp))] :
                 _walked_faces(comp, 1, input_wires, first)

# Design: §13.3, Appendix C.
# Inside a walk the walk has already evaluated the body once and this primitive
# does not evaluate it again; standalone the primitive evaluates it.
"""
    output_faces(comp) -> Vector{String}

Return the [component](@ref g-component)'s output [face](@ref g-face) names, in
declaration order.

For a primitive the output faces are the keys of its [`y_types`](@ref), and a
bare `y_types` lists as one empty name. For an [assembly](@ref g-assembly) they
are the face names its [`output_wires`](@ref) declares.

Called from a declaration body during a build, `output_faces` reuses the
build's evaluation of the child's declaration rather than evaluating it again.
Either way the vector returned is a fresh one, the caller's to change.

See [`input_faces`](@ref), the mirror on the input side, and
[`output_passthrough`](@ref) for the helper built on it.
"""
output_faces(@nospecialize(comp)) = classify("", comp) === PRIMITIVE ?
                  String[String(k) for (k, _) in contract_fields(_contract(y_types, comp))] :
                  _walked_faces(comp, 2, output_wires, last)

# The walk's list when the walk evaluated this assembly, the one body asked for
# otherwise — one side per primitive, so that a miss evaluates only the body
# asked for: outside a walk a caller asks for one side, and evaluating the other
# for nothing would raise its warnings for nothing. A miss inside a walk has no
# reader today (children are walked before any parent reads them); the fallback
# is correctness, not a path. The hit is copied on the way out: the memo is the
# walk's own record, and a caller sorting or emptying what a primitive handed it
# would otherwise reorder the boundary the walk goes on to compute.
function _walked_faces(@nospecialize(comp), side::Int, fn, face_of)
    memo = WALK_FACES[]
    memo !== nothing && haskey(memo, comp) && return copy(memo[comp][side])
    String[String(face_of(pair)) for pair in invoke_declaration(fn, comp)]
end

# --- §8.8's passthrough helpers -----------------------------------------------
# `input_wires` and `output_wires` are ordinary functions evaluated
# at build against the concrete instance, so they may *compute* entries from
# child contracts. These two are the framework's own sugar over the primitives
# above — the pass-through case, where an assembly re-exports the faces of a
# child it does not itself feed. Two helpers rather than one keyword, because
# after the boundary split a single call cannot emit into two declarations
# (D-209). Nothing else about computed connections is built here: the entries
# they return are ordinary pairs, mixing freely with hand-written ones, and
# every check that meets them is the build's own.

# Design: §8.8, §9.1, D-251.
"""
    input_passthrough(assembly, child_path::AbstractString; sep::AbstractString = ".",
                      prefix::AbstractString = replace(child_path, "/" => sep),
                      except::Tuple = (), only::Tuple = (), select = nothing) -> Tuple

Return input wire [entries](@ref g-entry) that expose a child's input
[faces](@ref g-face) on the [assembly](@ref g-assembly)'s own boundary.

The helper serves the pass-through case, where an assembly hands up the inputs
of a child it does not feed itself. Its entries are splatted into the assembly's
[`input_wires`](@ref), and mix freely with hand-written ones:
`input_wires(w::World) = (input_passthrough(w, "aircraft"; except = ("atm",))...,)`.
Each face of the child, as [`input_faces`](@ref) lists it, becomes the pair
`prefix * sep * face => child_path * "/" * face`. A bare input, listed as the
empty name, becomes `prefix => child_path`, so the default labels it with the
child's path.

`child_path` names an immediate child, a bare key where the container is
name-transparent. A deeper path is refused as [`resolve`](@ref) refuses it.

# Keywords

- `sep`: the separator between the prefix and the face name.
- `prefix`: the label in front of each face. The default folds the path's `/`
  into `sep`, so a container element `"units/1"` labels its faces
  `"units.1.…"`, a legal face name. An explicit `prefix` is used verbatim, and
  `prefix = ""` drops the prefixing entirely, which over a bare input leaves an
  empty face name the build refuses as `FaceNameIllegal`.
- `except`: the face names to leave out.
- `only`: the face names to keep.
- `select`: a predicate that receives each face name as a `String` and keeps
  the ones it accepts.

The three selection keywords are exclusive, one per call. More than one is
refused as `UnknownFaceSelection` with reason `:multiple_selectors`, and an
`except` or `only` name the child does not have as `UnknownFaceSelection` with
the child's faces listed. A selection keyword that keeps nothing warns
`EmptyFaceSelection` on the build, while a call with no selection keyword over a
child without faces is silent.

See also [`output_passthrough`](@ref).
"""
function input_passthrough(@nospecialize(assembly), child_path::AbstractString;
                           sep::AbstractString = ".",
                           prefix::AbstractString = replace(child_path, "/" => sep),
                           except::Tuple = (), only::Tuple = (), select = nothing)
    names = input_faces(resolve(assembly, child_path))
    wanted = _passthrough_faces("input_passthrough", child_path, names, except, only, select)
    Tuple(_labelled(prefix, sep, n) => _child_endpoint(child_path, n) for n in wanted)
end

# Design: §6.1, §8.8, D-209, D-251.
# Its consumer is one-level routing: every level re-exports the outputs it
# surfaces, so the output side needs the computed spelling the input side
# already has.
"""
    output_passthrough(assembly, child_path::AbstractString; sep::AbstractString = ".",
                       prefix::AbstractString = replace(child_path, "/" => sep),
                       except::Tuple = (), only::Tuple = (), select = nothing) -> Tuple

Return output wire [entries](@ref g-entry) that expose a child's output
[faces](@ref g-face) on the [assembly](@ref g-assembly)'s own boundary.

`output_passthrough` is [`input_passthrough`](@ref)'s sibling on the outward
boundary, and its entries are splatted into the assembly's
[`output_wires`](@ref). It takes the same keywords over the faces
[`output_faces`](@ref) lists, with the same folded default `prefix` and the same
three exclusive selection keywords, one per call, `select` receiving face names.
Its pairs read along the flow, `child_path * "/" * face => prefix * sep * face`,
internal source to face name, as every pair in that declaration does. A bare
output becomes `child_path => prefix`, as on the input side.

Each level re-exports the outputs it surfaces, so an output deep in the tree
reaches the root only through one entry per level, which this helper computes.
Its refusals are `input_passthrough`'s: more than one selection keyword, or an
unknown name, is refused as `UnknownFaceSelection`, and a selection keyword that
keeps nothing warns `EmptyFaceSelection` on the build.
"""
function output_passthrough(@nospecialize(assembly), child_path::AbstractString;
                            sep::AbstractString = ".",
                            prefix::AbstractString = replace(child_path, "/" => sep),
                            except::Tuple = (), only::Tuple = (), select = nothing)
    names = output_faces(resolve(assembly, child_path))
    wanted = _passthrough_faces("output_passthrough", child_path, names, except, only, select)
    Tuple(_child_endpoint(child_path, n) => _labelled(prefix, sep, n) for n in wanted)
end

# A face's label on the assembly, the prefix alone for a bare one (D-436).
_labelled(prefix, sep, n) =
    isempty(prefix) ? String(n) : isempty(n) ? String(prefix) : string(prefix, sep, n)

# A child face's endpoint, the child path alone for a bare one (D-436).
_child_endpoint(child_path, n) = isempty(n) ? String(child_path) : string(child_path, "/", n)

# Exclusivity is enforced, not documented, and a filter naming a face the child
# does not have errors with the list in hand — the same did-you-mean shape every
# declaration-time refusal takes here (§8.8). The order of the checks is the
# spec's: exclusivity, the unknown names, the selection, then the warning a
# selector that kept nothing raises (D-251).
function _passthrough_faces(who::String, child_path::AbstractString,
                            names::Vector{String}, except_faces::Tuple, only_faces::Tuple, select)
    # The diagnostics name the child by its full path: the owner's, bound by its
    # component frame, joined with the child's. A bare call outside a build names
    # the child alone.
    at = _join(COMPONENT_PATH[], String(child_path))
    given = Symbol[]
    isempty(except_faces) || push!(given, :except)
    isempty(only_faces) || push!(given, :only)
    select === nothing || push!(given, :select)
    length(given) ≤ 1 ||
        throw(DiagnosticError(UnknownFaceSelection(who = who, path = at,
                                              reason = :multiple_selectors,
                                              names = String[String(g) for g in given])))
    unknown = [String(n) for n in (except_faces..., only_faces...) if !(String(n) in names)]
    isempty(unknown) ||
        throw(DiagnosticError(UnknownFaceSelection(who = who, path = at,
                                              reason = :unknown_names, names = unknown,
                                              candidates = names)))
    wanted = !isempty(only_faces) ? String[String(n) for n in only_faces] :
             select !== nothing ? filter(select, names) :
                                  setdiff(names, String[String(n) for n in except_faces])
    # A selector that kept nothing is almost always a typo the unknown-names check
    # cannot see; a bare call over a faceless child asked for nothing and is
    # silent. `only` cannot reach here — a non-empty `only` of known names keeps
    # them all — so only `except` has names to carry.
    if length(given) == 1 && isempty(wanted)
        selector = given[1]
        _warn!(EmptyFaceSelection(who = who, path = at, selector = selector,
                                  names = selector === :except ?
                                          String[String(n) for n in except_faces] : String[],
                                  candidates = names))
    end
    wanted
end

# --- endpoint resolution (§8.6) -----------------------------------------------
# Faces are kind-blind (D-172): an endpoint's final segment resolves to a
# primitive's port or to a sub-assembly's face alike, and a face resolves
# recursively to its own internal endpoint. A face's type and tier are therefore
# derived — they are its ultimate internal endpoint's — never declared.

"""
The route from a producing endpoint to the primitive port it ultimately names:
its hops `(path, face)` in order, the last being the producer `(path, port)`. Or
`nothing` with the refusal recorded in `diags` — the endpoint then claims nothing
and the obligation pass reports what it left unfed (§13.1).
"""
function resolve_source(draft, entry::String, base::String, @nospecialize(assembly), path::AbstractString,
                        diags::Vector{Diagnostic})
    resolved = resolve_terminal(entry, base, assembly, path, diags)
    resolved === nothing && return nothing
    comp, comp_path, name = resolved
    if classify(comp_path, comp) === PRIMITIVE
        _has_port(_contract(y_types, comp), name) && return Tuple{String,Symbol}[(comp_path, name)]
    else
        # Children are walked before wires, so the child's faces are already
        # resolved: an output face's route is its recorded row behind this hop, and
        # a face whose source was refused was refused there, once (D-229).
        row = findfirst(pr -> first(pr) == (comp_path, name), draft.out_faces)
        row === nothing || return pushfirst!(copy(last(draft.out_faces[row])), (comp_path, name))
        String(name) in output_faces(comp) && return nothing   # declared, refused at the child
    end
    # the parent's own typo
    _wrong_direction(entry, path, comp_path, name, comp, "producer", diags)
end

"""
The routes from a consuming endpoint to the primitive inputs it ultimately names,
one per consumer, each its hops `(path, face)` in order, the last being the
consumer. Several, when the endpoint is a sub-assembly's input face fanning out
through the boundary; none, when the endpoint failed to resolve and the refusal
was recorded.
"""
function resolve_dest(draft, entry::String, base::String, @nospecialize(assembly), path::AbstractString,
                      diags::Vector{Diagnostic})
    resolved = resolve_terminal(entry, base, assembly, path, diags)
    resolved === nothing && return Vector{Tuple{String,Symbol}}[]
    comp, comp_path, name = resolved
    if classify(comp_path, comp) === PRIMITIVE
        _has_port(_contract(u_types, comp), name) && return [Tuple{String,Symbol}[(comp_path, name)]]
    else
        # Children are walked before wires, so the child's level wires are already
        # recorded: a face's routes are derived from them behind this hop, and a
        # face whose route was refused was refused there, once (D-229).
        routes = _draft_routes(draft, (comp_path, name))
        isempty(routes) || return [pushfirst!(route, (comp_path, name)) for route in routes]
        String(name) in input_faces(comp) && return Vector{Tuple{String,Symbol}}[]   # refused at the child
    end
    # the parent's own typo
    _wrong_direction(entry, path, comp_path, name, comp, "consumer", diags)
    Vector{Tuple{String,Symbol}}[]
end

# The routes of a walked assembly's input face, one per consumer in wire order,
# derived from the level wires the walk recorded: a primitive's face ends a route,
# and an assembly's continues through its own level.
function _draft_routes(draft, face::Tuple{String,Symbol})
    routes = Vector{Tuple{String,Symbol}}[]
    for (producer, hop) in draft.wires[first(face)]
        producer == face || continue
        haskey(draft.wires, first(hop)) || (push!(routes, [hop]); continue)
        for route in _draft_routes(draft, hop)
            push!(routes, pushfirst!(route, hop))
        end
    end
    routes
end

_endpoints(inner::AbstractString) = (inner,)
_endpoints(inner::Tuple) = inner

# Called by the declaring level alone, on its own children's endpoints: a parent
# reading the face reads the level wires this recorded.
# A loop, because a generator's closure would capture `comp` (see `_walk!`).
function _fanout(draft, entry, base, @nospecialize(comp), inner, diags)
    routes = Vector{Tuple{String,Symbol}}[]
    for endpoint in _endpoints(inner)
        append!(routes, resolve_dest(draft, entry, base, comp, endpoint, diags))
    end
    routes
end

# Direction is declared by the method; the resolved endpoint only cross-checks it.
# The mismatch is recorded, never thrown: the wire simply resolves to nothing. The
# name is looked for on the other side alone, the endpoint's own side having
# refused it. A bare side lists as one empty name, so the child segment alone at
# a bare port of the other side is a direction conflict too. Where the endpoint's
# form and its side's shape disagree, the payload holds that side's faces alone
# (D-436).
function _wrong_direction(entry, path, comp_path, name, @nospecialize(comp), wanted, diags)
    input_names, output_names = input_faces(comp), output_faces(comp)
    side_names, other_names = wanted == "producer" ? (output_names, input_names) :
                                                     (input_names, output_names)
    found = String(name) in other_names ? (wanted == "producer" ? "an input" : "an output") :
            nothing
    if found === nothing
        push!(diags, UnknownPort(entry = entry,
                                endpoint = wanted == "producer" ? :source : :destination,
                                path = comp_path, spelling = String(path), port = name,
                                candidates = Symbol.(name === BARE || side_names == [""] ?
                                                     side_names :
                                                     vcat(input_names, output_names))))
        return nothing
    end
    push!(diags, FaceDirectionConflict(entry = entry, path = comp_path,
                                      spelling = String(path),
                                      found = found == "an input" ? :input : :output,
                                      wanted = Symbol(wanted)))
    nothing
end

# --- tier classification (§8.2) -----------------------------------------------
# Tier is declared by the store every leaf declares, `x_init` continuous against
# `s_init` discrete, the two disjoint (D-195), and empty on a stateless leaf
# (D-263). The declaration is asked for by method existence, never by
# emptiness: a declared `nothing` and the fallback are the same value. A stateful
# leaf announces its tier in the update law as well, and the update law decides
# where there is one; the output stages are one pair of names shared by both
# tiers (D-220) and cast no vote, and no arity carries a tier. Every other
# tier-implying declaration must then agree, and disagreement names the
# offending one — including the wrong-tier cases the split state letters make
# visible, an `x_init` on a leaf whose update law is `s_update`, the
# converse, both stores on one leaf, and a `Pinned` contract entry on a
# discrete leaf.
#
# The classifier sees primitives only: a component that declares nothing at all
# has no *class* to read, which §8.5 settles before this runs.

"""
The `name => value` pairs of a store value, the one shape reading of §8.2: a
`NamedTuple`'s own fields, one `BARE` pair for a bare value, none for `nothing`.
"""
store_fields(contents::NamedTuple) = pairs(contents)
store_fields(::Nothing) = ()
store_fields(contents) = (BARE => contents,)

# §7.1, §8.2, D-094: every `x_init` field, or the bare value, is a `Float64` or
# an `SArray` of them, and the declaration is flat. The arm names where the
# value belongs instead.
function check_state_leaves(path::String, @nospecialize(comp), diags::Vector{Diagnostic})
    for (name, value) in store_fields(invoke_declaration(x_init, comp))
        leaf_eltype = value isa SArray ? eltype(value) : typeof(value)
        leaf_eltype === Float64 && continue
        reason = value isa NamedTuple ? :nested :
                 leaf_eltype <: Union{Integer,Enum} ? :mode_value :
                 leaf_eltype <: Real ? :eltype : :wrapper
        push!(diags, IllegalStateLeaf(path = path, name = name, declared = typeof(value),
                                      reason = reason))
    end
end

# §8.2: `(;)` no longer spells the empty store, `nothing` does, and the presence
# tests below read the old spelling as a store. Returns whether this primitive
# can be read further.
function check_store_form(path::String, @nospecialize(comp), diags::Vector{Diagnostic})
    readable = true
    for (name, fn) in ((:x_init, x_init), (:s_init, s_init), (:m_init, m_init))
        invoke_declaration(fn, comp) === (;) || continue
        push!(diags, EmptyStore(path = path, store = name))
        readable = false
    end
    readable
end

# §8.6, D-436: a contract entry's name is a face name, never empty. A bare port
# omits the name, and an empty one is refused rather than read as bare.
function check_contract_names(path::String, @nospecialize(comp), diags::Vector{Diagnostic})
    for fn in (u_types, y_types)
        decl = invoke_declaration(fn, comp)
        decl isa NamedTuple && haskey(decl, BARE) &&
            push!(diags, FaceNameIllegal(path = path, face = "", invariant = :empty))
    end
end

# §7.3, D-231: every store field, or the bare value, is isbits or a `Symbol`,
# checked on both stores.
function check_stores(path::String, @nospecialize(comp), diags::Vector{Diagnostic})
    for (store, contents) in ((:s_init, invoke_declaration(s_init, comp)),
                              (:m_init, invoke_declaration(m_init, comp)))
        for (name, value) in store_fields(contents)
            isbits(value) || value isa Symbol ||
                push!(diags, IllegalStoreField(path = path, store = store,
                                               name = name, declared = typeof(value)))
        end
    end
end

"""
The tier the primitive at `path` announces, or `nothing` with what disagrees
recorded in `diags` (§13.1).
"""
function classify_tier(path::String, @nospecialize(comp), diags::Vector{Diagnostic})
    votes = Tuple{Symbol,Tier}[]
    has_stage(x_deriv, comp) && push!(votes, (:x_deriv, CONTINUOUS))
    has_stage(s_update, comp) && push!(votes, (:s_update, DISCRETE))
    _declares(x_init, comp) && push!(votes, (:x_init, CONTINUOUS))
    _declares(s_init, comp) && push!(votes, (:s_init, DISCRETE))
    invoke_declaration(m_init, comp) !== nothing && push!(votes, (:m_init, CONTINUOUS))
    !isempty(invoke_declaration(state_events, comp)) && push!(votes, (:state_events, CONTINUOUS))

    # The store is mandatory, empty when stateless (§8.2, D-263).
    if !_declares(x_init, comp) && !_declares(s_init, comp)
        push!(diags, TierUnreadable(path = path, type = _typename(comp),
                                   declarations = leaf_declarations(comp)))
        return nothing
    end
    state_store = invoke_declaration(x_init, comp) !== nothing ? :x_init :
                  invoke_declaration(s_init, comp) !== nothing ? :s_init : nothing
    update_vote = findfirst(v -> first(v) === :x_deriv || first(v) === :s_update,
                            votes)
    if state_store !== nothing && update_vote === nothing
        push!(diags, StoreWithoutUpdate(path = path, store = state_store))
        return nothing
    end

    # The decider: the update law where there is one, the store otherwise. Of two
    # stores `x_init` decides, and `s_init` is reported against it.
    decider = something(update_vote, findfirst(v -> first(v) === :x_init || first(v) === :s_init,
                                               votes))
    tier = last(votes[decider])
    recorded = length(diags)
    state_store === nothing && !_declares(y_types, comp) &&
        push!(diags, StatelessWithoutOutputs(path = path, type = _typename(comp),
                                            declarations = leaf_declarations(comp)))

    # The vote loop collects (§13.1): a leaf written half in each tier's spelling
    # names every declaration that disagrees, not the first one found. The tier
    # is announced only if none does.
    for (name, vote_tier) in votes
        vote_tier === tier && continue
        push!(diags, DeclarationOnWrongTier(path = path, declaration = name,
                                           reason = :tier_form,
                                           found = Symbol(tier_word(vote_tier)),
                                           announced = Symbol(tier_word(tier))))
    end
    # Both contracts read on the declaration as written, one report per entry:
    # the marker below the top of an entry is refused on both tiers (§8.2,
    # D-265), and a top marker says nothing where every leaf pins (§8.5, D-263).
    for (name, fn) in ((:u_types, u_types), (:y_types, y_types))
        _declares(fn, comp) || continue
        for (entry_name, P) in contract_fields(invoke_declaration(fn, comp))
            _holds_marker(P) &&
                push!(diags, IllegalPortType(path = path, site = name === :u_types ? :face : :port,
                                             name = entry_name, declared = P,
                                             reason = :nested_marker))
            tier === DISCRETE && _is_marker(P) &&
                push!(diags, DeclarationOnWrongTier(path = path, declaration = name,
                                                   reason = :pinned_entry, entry = entry_name,
                                                   announced = :discrete))
        end
    end
    length(diags) == recorded ? tier : nothing
end

# --- the flatten pass ---------------------------------------------------------

"""
One `sample_times` link (§9.1, D-253): the declaring assembly's path, the key as
`_rate_entry` returned it, and the `Relative` or `Absolute` value under it.
"""
const RateLink = @NamedTuple{scope::String, key::Symbol, entry::Union{Relative,Absolute}}

"The sample-time fold's value for one scope or component (§9.1): the anchor it hangs from (0 the base grid), and its period multiple and phase in that anchor's ticks."
const Timing = @NamedTuple{anchor::Int, m::Int, c::Int}

"""One keyed scope: the assembly an explicit `sample_times` key names, and its timing."""
const RateScope = @NamedTuple{path::String, key::Symbol, timing::Timing}

"""
One anchor (§9.1, §9.2): the exact `(T, τ)` an `Absolute` entry seeds, with
the `sample_times` entry that declared it, by scope path and key. Anchor 0,
the base grid, has no record here; it is symbolic until `Δt_base` binds.
"""
struct Anchor
    T::Rational{Int}
    τ::Rational{Int}
    scope::String
    key::Symbol
end

"""
One component of the structure (§9.1): its path, the instance, the tier the
walk read, and the `sample_times` links met on the way down with the timing the
fold made of them. Its inputs' producers are not held here: `terminal_producer`
resolves them over the level rows (D-315).
"""
struct ComponentEntry
    path::String
    instance::AbstractComponent
    tier::Tier
    rates::Vector{RateLink}
    timing::Timing
end

"""
One child of an assembly (§8.5, D-315): its segment under the assembly, the
field that contributed it, which is the key the rate sugar reads (§8.7), and the
instance.
"""
struct Child
    segment::String             # "trim", "loops/l1", or "l1" under a transparent container
    field::Symbol
    instance::AbstractComponent
end

"""
    membership(child)

How `child` joined its assembly, read off its segment against its field (§8.5,
D-211): `:field` for a component field, `:container` for a container element
keyed under the field's name, `:transparent` for an element of a
name-transparent container, which goes by its bare key.
"""
membership(child::Child) =
    child.segment == String(child.field) ? :field :
    startswith(child.segment, String(child.field) * "/") ? :container : :transparent

"""
One assembly of the structure (§9.1, D-315): its path, the instance, its children
in `_children`'s order, and the wires its three declarations make, as one-level
`(path, face)` pairs, producer to consumer, in declaration order: the
`local_wires` entries, then `input_wires`, then `output_wires`. An input or
output wire carries the assembly's own face on its boundary side, and an input
entry fanning out to several children is one pair per target.
"""
struct LevelEntry
    path::String                # "" for the root
    instance::AbstractComponent
    children::Vector{Child}
    wires::Vector{Pair{Tuple{String,Symbol},Tuple{String,Symbol}}}   # producer => consumer
end

# Design: §9.1, §11.3, §13.3, D-210, D-253, D-261, D-315.
# The first row's instance is the root, which the service walk resolves
# against. No resolved table lives here: `terminal_producer` and `face_routes`
# resolve any face at any level over the level rows' wires, where the face is
# read. The activation's cell layout is the one home for addresses: it aliases
# each assembly output face onto its terminal producer's cell, and a primitive
# input face's address is read through `terminal_producer`, nothing being
# stored under a primitive's or an assembly's input face. The component index
# `ci` is the position in `components`; nothing pushes into a `Structure`'s
# vectors after construction.
"""
    Structure

The structure step's product, the declared facts the
[component](@ref g-component) tree alone fixes, held as rows.

`Structure` is read off a [`Build`](@ref) as `build.structure`. Nothing in it
depends on a scalar type. Its rows hold the component instances, and paths,
names and rationals the REPL prints as they are.

- `components`: one entry per primitive, in the order the build walks the tree.
- `anchors`: one entry per [`Absolute`](@ref) declaration, the exact `(T, τ)`
  pair (period and offset in rational seconds) with the declaring scope and
  key.
- `scopes`: one entry per [assembly](@ref g-assembly) a `sample_times` key
  names, with its path, the key and the timing the build derived for it.
- `root_inputs` and `root_types`: the [root inputs](@ref g-root-input), in
  order, with the types the wire check fixed for them.
- `levels`: one entry per assembly, in pre-order with the root first, holding
  its children and the wires it declares. A primitive root's entry has no
  children and no wires.

No table of resolved [faces](@ref g-face) is stored. A face at any level is
resolved over the `levels` wires when it is read.
"""
struct Structure
    components::Vector{ComponentEntry}     # in walk order; the index is `ci` everywhere
    anchors::Vector{Anchor}                # anchors 1…K
    scopes::Vector{RateScope}              # one row per keyed assembly, in walk order
    root_inputs::Vector{Symbol}            # root input faces, in order
    root_types::Vector{Type}               # per root input: the type the wire pass fixed (D-236, D-261)
    levels::Vector{LevelEntry}             # one per assembly, in walk pre-order, the root first (D-315)
end

# The structure step's accumulator, disposable: the per-component columns and
# the per-assembly paths and wires the `Structure`'s rows are built from at the
# barrier, with the slack the dirty pass needs (a tier is `nothing` where a
# store-form failure was recorded, and narrows on the clean walk the wire pass
# runs on), plus the walk's scratch — the claims and the evaluated face lists. The root-input types are not here: the wire pass fixes them
# (D-236) and the `Structure` takes them at construction (D-261).
# Violations are not held here either: the step's list is an argument of every
# helper that can add to it.
struct StructureDraft
    root::AbstractComponent
    paths::Vector{String}
    instances::Vector{AbstractComponent}
    tiers::Vector{Union{Nothing,Tier}}   # per primitive, beside `paths`; `nothing` = recorded
    rates::Vector{Vector{RateLink}}      # per primitive: the links met on the way down
    timings::Vector{Timing}              # per primitive: the fold's value
    anchors::Vector{Anchor}
    scopes::Vector{RateScope}
    root_inputs::Vector{Symbol}
    out_faces::Vector{Pair{Tuple{String,Symbol},Vector{Tuple{String,Symbol}}}}   # (path, face) => route
    feeds::Dict{Tuple{String,Symbol},Tuple{String,Symbol}}
    claims::Dict{Tuple{String,Symbol},String}                  # who claimed it, for the message
    faces::IdDict{Any,Tuple{Vector{String},Vector{String}}}   # per assembly instance, (inputs, outputs)
    child_lists::Dict{String,Tuple{Vector{Pair{String,Any}},Vector{Symbol}}}   # per assembly path: `_children`'s two lists
    level_paths::Vector{String}          # per assembly, in walk pre-order
    wires::Dict{String,Vector{Pair{Tuple{String,Symbol},Tuple{String,Symbol}}}}   # per assembly path: its declared wires
end

StructureDraft(@nospecialize(root::AbstractComponent)) =
    StructureDraft(root, String[], AbstractComponent[],
                   Union{Nothing,Tier}[],
                   Vector{RateLink}[], Timing[],
                   Anchor[], RateScope[],
                   Symbol[],
                   Pair{Tuple{String,Symbol},Vector{Tuple{String,Symbol}}}[],
                   Dict{Tuple{String,Symbol},Tuple{String,Symbol}}(),
                   Dict{Tuple{String,Symbol},String}(),
                   IdDict{Any,Tuple{Vector{String},Vector{String}}}(),
                   Dict{String,Tuple{Vector{Pair{String,Any}},Vector{Symbol}}}(),
                   String[],
                   Dict{String,Vector{Pair{Tuple{String,Symbol},Tuple{String,Symbol}}}}())

function index_of(structure::Structure, path::String)
    ci = findfirst(entry -> entry.path == path, structure.components)
    ci === nothing && throw(InternalInvariant("no component at path `$path`"))
    ci
end
function index_of(draft::StructureDraft, path::String)
    ci = findfirst(==(path), draft.paths)
    ci === nothing && throw(InternalInvariant("no component at path `$path`"))
    ci
end

"""
The running walk's evaluated face lists (§13.3, Appendix C): `flatten_tree!` binds it
around the walk, so a primitive asked for an assembly's faces while the walk runs
— by a passthrough helper inside a parent's body, or by endpoint resolution
building a did-you-mean list — reads the lists the walk already evaluated rather
than evaluating the body again. Unbound outside a walk, where the primitives
evaluate the body themselves. Keyed by instance because the helpers name a child
by a path relative to the assembly, never absolutely, and a face list is a
function of the instance's value (§8.8).
"""
const WALK_FACES = ScopedValue{Union{Nothing,IdDict{Any,Tuple{Vector{String},Vector{String}}}}}(nothing)

"""
The running walk's child lists (§9.7): `flatten_tree!` binds a fresh one around the
walk, so endpoint resolution, which asks for an assembly's children once per
endpoint, derives each list once rather than once per endpoint. Unbound outside
a walk. Keyed by instance, so two instances equal by value share one list. That
is sound: a child list is a function of the value, and the path reaches the
derivation for its diagnostics only.
"""
const WALK_CHILDREN = ScopedValue{Union{Nothing,IdDict{Any,Vector{Pair{String,Any}}}}}(nothing)

# The walk's list for `assembly`, derived on the first ask; `children` itself
# outside a walk. A derivation that throws stores nothing. The hit is the cached
# vector itself, shared and read-only: `_walked_faces` copies on the way out, but
# a copy per endpoint would bring back the cost the cache removes, and
# `_one_level`, the one caller, only searches it. Not `get!`, whose closure
# would capture `assembly` (see `_walk!`).
function _walked_children(base::String, @nospecialize(assembly))
    memo = WALK_CHILDREN[]
    memo === nothing && return children(base, assembly)
    hit = get(memo, assembly, nothing)
    hit === nothing || return hit
    memo[assembly] = children(base, assembly)
end

# --- the sample-time fold (§8.7, §9.1, §10.5) -----------------------------------
# Nested rate declarations compile to one `(anchor, m, c)` timing per component,
# folding down the tree beside the wiring walk: the root scope seeds
# `(A₀, 1, 0)`, `Relative(K, φ)` under a scope at `(a, mₛ, cₛ)` steps to
# `(a, K·mₛ, cₛ + φ·mₛ)`, and `Absolute` severs and re-seeds a fresh anchor at
# `(Aₖ, 1, 0)` — a nested anchor simply severs again. Anchor 0 is the base grid,
# symbolic until deployment binds `Δt_base`: final divisors for anchored entries
# do not exist until then (§9.1). The canonical residue `c < m` holds within each
# anchor's subtree by the affine law's one-line induction.

"""
Validate a scope's `sample_times` against §10.5's constraints, with path
attribution (§9.1, §13.1): wrapper-typed values only, `K ≥ 1`, `0 ≤ φ < K`,
`T > 0`, `0 ≤ τ < T`, and every key naming an immediate child.
"""
function _check_sample_times(path::String, rate_decl, kids, fields, diags::Vector{Diagnostic})
    record_violation(reason; kw...) =
        push!(diags, RatesViolation(; path = path, reason = reason, kw...))
    if !(rate_decl isa NamedTuple)
        record_violation(:declaration_shape)       # nothing further is iterable
        return nothing
    end
    for (key, rate) in pairs(rate_decl)
        if !(rate isa Relative || rate isa Absolute)
            record_violation(:value_vocabulary; key = key, value = rate)
            continue                               # neither residue arm applies
        end
        # The residue bound is stated against the multiplier, so an invalid `K`
        # (or `T`) leaves `φ` (or `τ`) with nothing to be measured against: the
        # dependent check is skipped, not doubled up.
        if rate isa Relative
            rate.K ≥ 1 ? (0 ≤ rate.φ < rate.K ||
                          record_violation(:phase; key = key, value = rate.φ)) :
                         record_violation(:multiplier; key = key, value = rate.K)
        else
            rate.T > 0 ? (0 ≤ rate.τ < rate.T ||
                          record_violation(:offset; key = key, value = rate.τ)) :
                         record_violation(:period; key = key, value = rate.T)
        end
        any(seg == String(key) for (seg, _) in kids) ||
            any(String(fld) == String(key) for fld in fields) ||
            record_violation(:unknown_child; key = key,
                             candidates = String[first(p) for p in kids])
    end
    nothing
end

# The entry scheduling the child at segment `segment`, contributed by field `field`, or
# `nothing` for the `Relative(1)` default. Exact match first; then the bare field
# name, which applies one declaration to every element of a container (§8.7). The
# sugar keys on the *field*, so a name-transparent container keeps it unchanged:
# `(children = Relative(2),)` is the uniform spelling for a `Group` (D-211).
function _rate_entry(rate_decl, segment::String, field::Symbol)
    rate_decl isa NamedTuple || return nothing         # the shape refusal is already collected
    for (k, v) in pairs(rate_decl)
        String(k) == segment && return (k, v)
    end
    for (k, v) in pairs(rate_decl)
        String(k) == String(field) && return (k, v)
    end
    nothing
end

"""The chain a child walks under: the links above it, plus its own when it has one."""
_extend(chain::Vector{RateLink}, link::Union{Nothing,RateLink}) =
    link === nothing ? copy(chain) : push!(copy(chain), link)

"""
The child's scope timing, and the link an explicit key declared — the declaring
assembly's path, the key as `_rate_entry` returned it, and the wrapper value —
or `nothing` for an unlisted child. The unlisted child continues at the
enclosing timing: the `Relative(1)` default is the affine law at
`(K, φ) = (1, 0)`, implemented by nothing.
"""
function _child_scope(draft::StructureDraft, path::String, rate_decl, segment::String,
                      field::Symbol, scope::Timing)
    hit = _rate_entry(rate_decl, segment, field)
    hit === nothing && return scope, nothing
    (key, rate) = hit
    # `_check_sample_times` collects rather than throwing (§13.1), so the fold
    # runs on past a value outside the wrapper vocabulary — which has no affine
    # law to apply. The violation is already recorded; the child continues at the
    # enclosing scope, as an unlisted one would.
    (rate isa Relative || rate isa Absolute) || return scope, nothing
    link = RateLink((scope = path, key = key, entry = rate))
    if rate isa Relative
        Timing((scope.anchor, rate.K * scope.m, scope.c + rate.φ * scope.m)), link
    else
        # One anchor per `Absolute` entry (§9.1): a bare container key applies one
        # declaration to every element (§8.7), so the elements share the anchor
        # the first of them established rather than each pushing a twin.
        anchor_index = findfirst(anchor -> anchor.scope == path && anchor.key === key,
                                 draft.anchors)
        if anchor_index === nothing
            push!(draft.anchors, Anchor(rate.T, rate.τ, path, key))
            anchor_index = length(draft.anchors)
        end
        Timing((anchor_index, 1, 0)), link
    end
end

"""
    flatten_tree!(draft, root, diags)

The tree walk of the structure step (§9.1): components collected by path, classes and
tiers read, wiring resolved to absolute leaf terminals, sample times folded to
`(anchor, m, c)` timings, the one-producer-per-input and whole-tree obligation
rules checked. Violations are recorded in `diags` and the walk runs on; the
throw is `build`'s, at the step barrier. Any component may be the root
(D-208) — a primitive one flattens to the single leaf at the root path, its
`u_types` keys the model's root inputs.
"""
Base.@nospecializeinfer function flatten_tree!(draft::StructureDraft, @nospecialize(root),
                                          diags::Vector{Diagnostic})
    # the root scope: anchor 0, the base grid itself; no link above it and none of its own.
    # The face and child memos are the walk's own and are bound around it alone:
    # the obligation loop below reads `u_types`, never a face or child list.
    with(WALK_FACES => draft.faces,
         WALK_CHILDREN => IdDict{Any,Vector{Pair{String,Any}}}()) do
        _walk!(draft, "", root, Timing((0, 1, 0)), RateLink[], nothing, diags)
    end

    # The obligation model (§6.1, §9.1): an input is fed by a wire in some ancestor's
    # `local_wires` or by an `input_wires` chain handing it up level
    # by level, and the chain that never terminates is the error. The one
    # legitimate unfed terminus is the root's own input face. A wire that failed
    # to resolve claimed nothing, so the input it should have fed is reported
    # here beside the refusal itself.
    # By index: a closure capturing the instance would be a type per component type.
    for (ci, path) in enumerate(draft.paths)
        at_component(path) do
            for (face, declared) in contract_fields(_contract(u_types, draft.instances[ci]))
                # A bare input at a primitive root is refused as no root input (D-436).
                isempty(path) && face === BARE && continue
                haskey(draft.feeds, (path, face)) ||
                    push!(diags, UnconnectedInput(path = path, face = face,
                                                 declared = declared,
                                                 handed = _handed(draft, (path, face))))
            end
        end
    end
    nothing
end

# The obligation chain (§6.1, §9.1): the faces `input_wires` entries handed `consumer`
# up through, innermost first. From the consumer, the wire into it at its parent
# level, while that wire's producer is the level's own face; the last face is the
# outermost one nobody wired.
function _handed(draft::StructureDraft, consumer::Tuple{String,Symbol})
    handed = Tuple{String,Symbol}[]
    while true
        current = consumer                   # one binding per pass, for the closures
        k = findfirst(level_path -> any(((segment, _),) -> _join(level_path, segment) == first(current),
                                        first(draft.child_lists[level_path])),
                      draft.level_paths)
        k === nothing && return handed
        level_path = draft.level_paths[k]
        row = findfirst(wire -> last(wire) == current, draft.wires[level_path])
        row === nothing && return handed
        producer = first(draft.wires[level_path][row])
        first(producer) == level_path || return handed
        push!(handed, producer)
        consumer = producer
    end
end

# The structure step's last act (D-261): the artifact, complete at construction,
# its rows built from the draft's columns and level paths and the root-input
# types the wire pass fixed. The walk is clean, so no recorded failure is left
# and the tiers and root types narrow (§13.1, D-229). No code pushes into a
# `Structure`'s vector after this call.
function Structure(draft::StructureDraft, root_types::Vector{Any})
    # One row per level path, its instance off its parent's child list.
    instances_by_path = Dict{String,AbstractComponent}("" => draft.root)
    for (parent_path, (kids, _)) in draft.child_lists, (segment, kid) in kids
        instances_by_path[_join(parent_path, segment)] = kid
    end
    levels = LevelEntry[]
    for path in draft.level_paths
        kids, fields = draft.child_lists[path]
        push!(levels, LevelEntry(path, instances_by_path[path],
                                 [Child(segment, field, kid)
                                  for ((segment, kid), field) in zip(kids, fields)],
                                 draft.wires[path]))
    end
    # A primitive root enters no level in the walk, and the root always has a
    # row: its own, with no children and no wires.
    isempty(levels) &&
        push!(levels, LevelEntry("", draft.root, Child[],
                                 Pair{Tuple{String,Symbol},Tuple{String,Symbol}}[]))
    Structure([ComponentEntry(path, instance, tier, rates, timing)
               for (path, instance, tier, rates, timing) in
                   zip(draft.paths, draft.instances, Vector{Tier}(draft.tiers),
                       draft.rates, draft.timings)],
              draft.anchors, draft.scopes, draft.root_inputs, Vector{Type}(root_types),
              levels)
end

# `chain` is the links above `comp`, outermost first, and `link` its own — the
# entry the enclosing assembly's `sample_times` named it under, or `nothing`.
#
# The walk runs once per build and takes `comp` unspecialized, as does every
# function it calls with a component, so a new component type or root type
# compiles none of it again (§9.7, D-289).
Base.@nospecializeinfer function _walk!(draft::StructureDraft, path::String,
                                        @nospecialize(comp), scope::Timing,
                                        chain::Vector{RateLink}, link::Union{Nothing,RateLink},
                                        diags::Vector{Diagnostic})
    # The forgotten import (§8.1, D-246), first and alone: a module holding a
    # foreign binding of a family name declares nothing the framework can read,
    # so the class below would be read off an empty set. `ClassUnreadable` is
    # fail-fast too, and would throw alone with a message that is false from the
    # author's chair — the declarations were written, to the wrong function.
    foreign = foreign_declarations(comp)
    isempty(foreign) || throw(DiagnosticError(DeclarationShadowed(
        path = path, names = foreign,
        parent_module = string(parentmodule(typeof(comp))))))
    if classify(path, comp) === PRIMITIVE
        # Everything below reads this primitive's own declarations, so it runs
        # under the component frame: an accessor's `UserCodeFraming` leaves the
        # path empty and this is where the path is known (§13.2, D-248).
        return at_component(path) do
            push!(draft.paths, path)
            push!(draft.instances, comp)
            push!(draft.timings, scope)
            push!(draft.rates, _extend(chain, link))
            # The store-form check (§8.2) gates the rest: the tier classifier reads
            # `(;)` as a store, so a primitive that spells it is read no further. The one tier
            # classification (§8.2) follows: a failure is recorded and the walk
            # carries `nothing` where the tier would be.
            if check_store_form(path, comp, diags)
                tier = classify_tier(path, comp, diags)
                check_stores(path, comp, diags)
                check_state_leaves(path, comp, diags)
                check_contract_names(path, comp, diags)
            else
                tier = nothing                      # read no further
            end
            push!(draft.tiers, tier)
            # A primitive at the root: its `u_types` keys are the model's root
            # inputs, each face its own consuming entry (§8.6, §11.3, D-208), fed by
            # the same pseudo-producer an assembly root's faces get.
            if isempty(path)
                _check_root_faces(comp, diags)
                inputs = _contract(u_types, comp)
                # A bare `u_types` is no root input, refused just above (D-436).
                for face in (inputs isa NamedTuple ? keys(inputs) : ())
                    push!(draft.root_inputs, face)
                    _claim!(draft, (path, face), ("", face),
                            "the root component's `u_types` entry `$face`", diags)
                end
            end
            tier
        end
    end
    at_component(path) do
        # One row per assembly an explicit key names, in walk order: the scope a
        # `sample_times` key opened, with the timing everything under it folds from.
        link === nothing ||
            push!(draft.scopes, RateScope((path = path, key = link.key, timing = scope)))
        below = _extend(chain, link)
        rate_decl = invoke_declaration(sample_times, comp)
        kids, fields = draft.child_lists[path] = _children(path, comp)
        # The one place a level is entered, ahead of its children: pre-order.
        push!(draft.level_paths, path)
        level_wires = draft.wires[path] = Pair{Tuple{String,Symbol},Tuple{String,Symbol}}[]
        _check_sample_times(path, rate_decl, kids, fields, diags)
        for ((segment, kid), field) in zip(kids, fields)
            child_path = _join(path, segment)
            kid_scope, kid_link = _child_scope(draft, path, rate_decl, segment, field, scope)
            # a primitive's tier, `nothing` for an assembly
            tier = _walk!(draft, child_path, kid, kid_scope, below, kid_link, diags)
            # A key on a continuous child is the Δt-on-continuous error at
            # declaration time (§8.7): keys name discrete or scope children only.
            kid_link !== nothing && tier === CONTINUOUS &&
                push!(diags, RatesViolation(path = path, reason = :continuous_child,
                                           key = Symbol(segment)))
        end

        # The boundary declarations are read only after the children are walked: a
        # computed entry (`input_passthrough`, §8.8) classifies the child it names,
        # and a shadowed child must meet its own check above first, at its own path
        # (D-246). Each body is evaluated exactly once and its entries reused by
        # the name check and by the face loop below: a warning raised inside one
        # fires once per call (Appendix C).
        input_entries = invoke_declaration(input_wires, comp)
        output_entries = invoke_declaration(output_wires, comp)
        # The evaluated lists, recorded for the primitives (`WALK_FACES`): the
        # readers are a parent's own body and its wire resolution, both later, so
        # nothing below this line reads the row just written.
        draft.faces[comp] = (String[String(f) for (f, _) in input_entries],
                             String[String(f) for (_, f) in output_entries])
        _check_face_names(path, input_entries, output_entries, diags)

        for pair in invoke_declaration(local_wires, comp)
            entry = _entry("local_wires", path, pair)
            route = resolve_source(draft, entry, path, comp, first(pair), diags)
            route === nothing && continue      # recorded; the destination stays unfed
            producer = last(route)
            routes = resolve_dest(draft, entry, path, comp, last(pair), diags)
            # The routes' first hops are the immediate children's faces: the wire as declared.
            isempty(routes) || push!(level_wires, first(route) => first(first(routes)))
            for consumer in last.(routes)
                _claim!(draft, consumer, producer, entry, diags)
            end
        end

        # Both boundary declarations are resolved wherever they appear, so their
        # entries are checked at every level; only the root's input faces *feed*
        # anything, there being no parent above them to claim the obligation.
        # Below the root, what this level's entries hand up: consumer => (entry, face).
        handed_claims = Dict{Tuple{String,Symbol},Tuple{String,Tuple{String,Symbol}}}()
        for (face, inner) in input_entries
            entry = _entry("input_wires", path, face => inner)
            routes = _fanout(draft, entry, path, comp, inner, diags)
            # A port this level already feeds, by a sibling wire or by an earlier
            # endpoint handed up, is fed twice (§6.1), whether or not a parent wires
            # the face: below the root only this level's own `local_wires` have
            # claimed anything the entry reaches. The route is refused here, once,
            # and hands nothing up (D-229). At the root the claims meet in `_claim!`.
            if !isempty(path)
                filter!(routes) do route
                    consumer = last(route)
                    incumbent = haskey(draft.feeds, consumer) ?
                                (draft.claims[consumer], draft.feeds[consumer]) :
                                get(handed_claims, consumer, nothing)
                    if incumbent === nothing
                        handed_claims[consumer] = (entry, (path, Symbol(face)))
                        return true
                    end
                    push!(diags, TwoProducers(path = consumer[1], port = consumer[2],
                                             incumbent = first(incumbent), entry = entry,
                                             incumbent_producer = _terminal(last(incumbent)),
                                             producer = _terminal((path, Symbol(face)))))
                    false
                end
            end
            # Every entry routes to at least one internal endpoint, at every level
            # (D-210): a face feeding nothing declares nothing, and the empty tuple
            # would otherwise reach no consumer, record no wire in its level row,
            # and let a condition addressing it misdiagnose as a bare typo. Declared
            # empty is the refusal; empty because every endpoint failed to resolve, or
            # every consumer is fed twice, is already recorded, and registers nothing more.
            if isempty(routes)
                isempty(_endpoints(inner)) &&
                    push!(diags, UnknownPort(entry = entry, endpoint = :connection,
                                            path = path, port = Symbol(face)))
                continue                       # a route with no consumer registers nothing
            end
            for hop in unique(first.(routes))
                push!(level_wires, (path, Symbol(face)) => hop)
            end
            isempty(path) || continue
            push!(draft.root_inputs, Symbol(face))
            for consumer in last.(routes)
                _claim!(draft, consumer, ("", Symbol(face)), entry, diags)
            end
        end
        for (source, face) in output_entries
            entry = _entry("output_wires", path, source => face)
            route = resolve_source(draft, entry, path, comp, source, diags)
            route === nothing && continue      # recorded; the face registers no row
            push!(draft.out_faces, (path, Symbol(face)) => route)
            push!(level_wires, first(route) => (path, Symbol(face)))
        end
    end
    nothing
end

_entry(method::String, path::String, pair::Pair) =
    "$method at $(_at_path(path)), entry `$(repr(first(pair))) => $(repr(last(pair)))`"

# Every input takes exactly one connection, and the rule spans levels (§6.1): an
# input fed by two wires at one level, or by two root claims routed through
# faces, meets its second claim here. An input handed up while also wired is
# refused where the `input_wires` entry is declared.
function _claim!(draft::StructureDraft, consumer, producer, entry::String,
                 diags::Vector{Diagnostic})
    if haskey(draft.feeds, consumer)
        push!(diags, TwoProducers(path = consumer[1], port = consumer[2],
                                 incumbent = draft.claims[consumer], entry = entry,
                                 incumbent_producer = _terminal(draft.feeds[consumer]),
                                 producer = _terminal(producer)))
        return nothing                     # the incumbent keeps the claim
    end
    draft.feeds[consumer] = producer
    draft.claims[consumer] = entry
    nothing
end

# §8.6's two face-name invariants, over the boundary entries the walk already
# evaluated. Every other naming choice is author convention.
function _check_face_names(path::String, input_entries, output_entries, diags::Vector{Diagnostic})
    names = vcat(String[String(face) for (face, _) in input_entries],
                 String[String(face) for (_, face) in output_entries])
    for n in names
        occursin('/', n) &&
            push!(diags, FaceNameIllegal(path = path, face = n, invariant = :contains_slash))
        # An assembly face is never bare (D-436).
        isempty(n) && push!(diags, FaceNameIllegal(path = path, face = n, invariant = :empty))
    end
    allunique(names) ||
        push!(diags, FaceNameCollision(path = path, site = :assembly,
                                      faces = unique(n for n in names
                                                     if count(==(n), names) > 1)))
    nothing
end

# The same invariant at a *primitive* root, whose face set is its two contract
# declarations' keys together (§8.6, D-210). The root is where those two first
# share the periphery's address space: a root input places a cell of its own, so
# a shared key would put two cells at one name and the root input's placement
# would silently overwrite the port's. Below the root nothing collides — a
# primitive's input faces alias their producers' cells and place nothing — and
# non-root leaves are left alone.
#
# A bare contract takes the reserved empty name in that set, so two bare
# contracts collide. A bare `u_types` alone places no root input at all, the
# write surface being spelled by name, and is refused as such (§8.2, D-436).
function _check_root_faces(@nospecialize(comp), diags::Vector{Diagnostic})
    inputs = _contract(u_types, comp)
    output_names = String[String(n) for (n, _) in contract_fields(_contract(y_types, comp))]
    duplicates = [String(n) for (n, _) in contract_fields(inputs) if String(n) in output_names]
    isempty(duplicates) ||
        push!(diags, FaceNameCollision(path = "", faces = duplicates, site = :root))
    inputs isa NamedTuple || "" in output_names ||
        push!(diags, IllegalPortType(path = "", site = :root_input, name = BARE,
                                     declared = inputs, reason = :bare_at_root))
    nothing
end

# --- the wiring's resolution (§9.2, §13.7, D-315) -------------------------------
# Functions over the level rows' declared wires, computed where they are read.
# They take plain data, so they compile once (D-289), and they find a level by
# a linear search: the rows are few and nothing here runs in the loop.

# The index of the level row at `path`, `nothing` at a primitive's path. A
# primitive root has the one row, with no children.
_level_index(structure::Structure, path::String) =
    findfirst(level -> level.path == path, structure.levels)

# The index of the level row declaring the child at `path`, `nothing` at the root.
_parent_index(structure::Structure, path::String) =
    findfirst(level -> any(child -> _join(level.path, child.segment) == path, level.children),
              structure.levels)

# The producer of the wire `level` declares into `face`, or `nothing`.
function _wire_into(level::LevelEntry, face::Tuple{String,Symbol})
    row = findfirst(wire -> last(wire) == face, level.wires)
    row === nothing ? nothing : first(level.wires[row])
end

# A level's own faces, the endpoints of its wires that carry its path, in wire
# order: its input faces as producers, once each however many children one
# feeds, and its output faces as consumers.
_boundary_inputs(level::LevelEntry) =
    unique(Symbol[last(producer) for (producer, _) in level.wires if first(producer) == level.path])
_boundary_outputs(level::LevelEntry) =
    Symbol[last(consumer) for (_, consumer) in level.wires if first(consumer) == level.path]

"""
    terminal_producer(structure, face)

The producer `(path, port)` of `face`, a `(path, face)` at any level (§9.2,
D-315): a primitive's port, or `("", face)` for a root input. An assembly's
output face starts from its own level's output wire, any other face from its
parent level's wire into it. From a sibling assembly's output face the walk
continues into that level, and from the level's own input face into its parent.
A face no wire feeds is its own producer.
"""
function terminal_producer(structure::Structure, face::Tuple{String,Symbol})
    path = first(face)
    k = _level_index(structure, path)
    producer = k === nothing ? nothing : _wire_into(structure.levels[k], face)
    if producer === nothing
        k = _parent_index(structure, path)
        k === nothing && return face
        producer = _wire_into(structure.levels[k], face)
        producer === nothing && return face
    end
    while true
        producer_path = first(producer)
        if producer_path == structure.levels[k].path
            isempty(producer_path) && return producer       # a root input
            k = _parent_index(structure, producer_path)
        else
            k = _level_index(structure, producer_path)
            k === nothing && return producer                # a primitive's port
        end
        producer = _wire_into(structure.levels[k], producer)
    end
end

"""
    face_routes(structure, face)

The routes of `face`, a `(path, face)` at any level (§13.7, D-315), each the hops
`(path, face)` the resolution visits: for an assembly's output face one route
down to its producer, for an assembly's input face one per consumer down to
that consumer, in wire order. A primitive's face is its own one route.
"""
function face_routes(structure::Structure, face::Tuple{String,Symbol})
    k = _level_index(structure, first(face))
    # A row with no children is a primitive root's: an assembly with no
    # children declares no face.
    (k === nothing || isempty(structure.levels[k].children)) && return [[face]]
    level = structure.levels[k]
    producer = _wire_into(level, face)
    producer === nothing || return _routes_behind(structure, producer)
    routes = Vector{Tuple{String,Symbol}}[]
    for (wire_producer, consumer) in level.wires
        wire_producer == face && append!(routes, _routes_behind(structure, consumer))
    end
    routes
end

# The routes through `hop`, a child's face: the hop alone at a primitive, else
# the hop ahead of each route of its own face.
_routes_behind(structure::Structure, hop::Tuple{String,Symbol}) =
    _level_index(structure, first(hop)) === nothing ? [[hop]] :
        [pushfirst!(route, hop) for route in face_routes(structure, hop)]

# --- the service walk (§13.3, D-414) --------------------------------------------

"""
The service walk (§13.3, D-414): `path`'s segments from `level`, the
component at `base`, following the structure's children. A deep path
resolves wherever the structure has it, whatever the declared field types
along it. Returns the component the path names, primitive or assembly, or
`nothing` after recording the refusal against `entry`. The empty path names
`level` itself.

Each level's children are its level row's in `structure`, so a service
derives none again, however many paths it resolves.
"""
function resolve_authored(entry::String, base::String, level, path::AbstractString,
                          structure::Structure, diags::Vector{Diagnostic})
    isempty(path) && return level
    segments = String.(split(path, '/'))
    here, here_path, i = level, base, 1
    while i ≤ length(segments)
        # A primitive has no children in this walk, and no level row below the
        # root. A component-typed field of one is inert to the composition:
        # `flatten_tree!` stops at the primitive and never descends, so no path
        # indexes what the field holds (§8.5, `ClassUnreadable.holds_components`).
        row = _level_index(structure, here_path)
        if row === nothing
            push!(diags, PathResolution(entry = entry, spelling = String(path),
                                       reason = :unknown_child, owner = _at_path(here_path),
                                       segment = segments[i]))
            return nothing
        end
        kids = structure.levels[row].children
        child_index = findfirst(kid -> kid.segment == segments[i], kids)
        child_index === nothing && i < length(segments) &&
            (child_index =
                 findfirst(kid -> kid.segment == segments[i] * "/" * segments[i + 1], kids))
        if child_index === nothing
            push!(diags, PathResolution(entry = entry, spelling = String(path),
                                       reason = :unknown_child, owner = _at_path(here_path),
                                       segment = segments[i],
                                       candidates = String[kid.segment for kid in kids]))
            return nothing
        end
        child = kids[child_index]
        i += count(==('/'), child.segment) + 1      # a matched pair consumes two segments
        here, here_path = child.instance, _join(here_path, child.segment)
    end
    here
end

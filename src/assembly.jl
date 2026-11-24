# Hierarchy (§8.5, §8.6, §6.1): the assembly as a declaration. Class by
# declaration shape, children and containers, paths, §13.3's build primitives,
# §8.8's passthrough helpers, the tier and store checks a primitive's
# declarations meet (§8.2), the walk's memos those primitives read, and last
# `Group`, an assembly written in those declarations alone. The structure step
# that walks the tree into a `Structure` is `structure.jl`.

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

# The declaration is checked after the walk, so a mixed container it names reports
# `ContainerMixed` first, then `TransparentContainerUnknown`.
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

The child segment alone names a child and no port (D-437), and resolves with
the name `nothing`, which the caller refuses with the child's faces in hand. An
empty path, or an empty last segment, names no terminal.
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
    kid, _join(base, segment), alone ? nothing : Symbol(segments[end])
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
# entry to attribute the failure to. `resolve_authored`, at the end of
# `structure.jl`, is *the service walk*, entered by the services with an
# entry to attribute the refusal to.

# Design: §6.1, D-207, D-211.
"""
    resolve(assembly, path::AbstractString) -> AbstractComponent

Return the immediate child of an [assembly](@ref g-assembly) that `path` names.

`resolve` walks the assembly's declared fields along the `/` segments of
`path`. The path names one child, by its field's name, plus a key segment where
the child is an element of a [container field](@ref g-container-children), as in
`"units/1"` or `"units/left"`. The elements of a container declared
name-transparent with [`transparent_container`](@ref) go by their bare keys,
`"1"` or `"left"`.

Declaration bodies such as [`input_wires`](@ref) call it to compute
[entries](@ref g-entry) from a child's [contract](@ref g-contract).

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
contain dots, never slashes (§8.6). A path naming a child alone names no port,
and its name is the empty one (D-437).
"""
function resolve_terminal(@nospecialize(assembly), path::AbstractString)
    diags = Diagnostic[]
    resolved = resolve_terminal("`resolve_terminal` on `$(nameof(typeof(assembly)))`",
                                "", assembly, path, diags;
                                owner = "the component in hand")
    resolved === nothing && throw(DiagnosticError(only(diags)))   # declaration code: fail-fast
    comp, _, name = resolved
    comp, name === nothing ? "" : String(name)
end

# A contract declaration at nominal, whatever the tier, keyed: the keys are a
# tier-independent fact, the walk at `Float64` strips every `Pinned` (D-263),
# and a bare contract is its one entry under the default face (D-437).
_contract(fn, @nospecialize(comp)) = declared_at(fn, comp, CONTINUOUS)

# Design: §13.3, Appendix C.
# Inside a walk the walk has already evaluated the body once and this primitive
# does not evaluate it again; standalone the primitive evaluates it. Called from
# a declaration body during a build, `input_faces` reuses the build's evaluation
# of the child's declaration. A leaf's keys are asked at the nominal `Float64`.
# The list keeps declaration order, so printouts are deterministic and
# diagnostics stable.
"""
    input_faces(comp) -> Vector{String}

Return the [component](@ref g-component)'s input [face](@ref g-face) names, in
declaration order.

For a [primitive](@ref g-primitive) the input faces are the keys of its
[`u_types`](@ref), which do not depend on the scalar type, and a
[bare](@ref g-bare-contract) `u_types` lists as its face `u`. For an
[assembly](@ref g-assembly) they are the face names its [`input_wires`](@ref)
declares.

The vector returned is a fresh one, the caller's to change.

See [`output_faces`](@ref) for the output side, and
[`input_passthrough`](@ref) for the helper built on it.
"""
input_faces(@nospecialize(comp)) = classify("", comp) === PRIMITIVE ?
                 String[String(k) for k in keys(_contract(u_types, comp))] :
                 _walked_faces(comp, 1, input_wires, first)

# Design: §13.3, Appendix C.
# Inside a walk the walk has already evaluated the body once and this primitive
# does not evaluate it again; standalone the primitive evaluates it. Called from
# a declaration body during a build, `output_faces` reuses the build's evaluation
# of the child's declaration.
"""
    output_faces(comp) -> Vector{String}

Return the [component](@ref g-component)'s output [face](@ref g-face) names, in
declaration order.

For a [primitive](@ref g-primitive) the output faces are the keys of its
[`y_types`](@ref), and a [bare](@ref g-bare-contract) `y_types` lists as its
face `y`. For an [assembly](@ref g-assembly) they are the face names its
[`output_wires`](@ref) declares.

The vector returned is a fresh one, the caller's to change.

See [`input_faces`](@ref), the mirror on the input side, and
[`output_passthrough`](@ref) for the helper built on it.
"""
output_faces(@nospecialize(comp)) = classify("", comp) === PRIMITIVE ?
                  String[String(k) for k in keys(_contract(y_types, comp))] :
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
    entries = invoke_declaration(fn, comp)
    # The walk's shape check, which a miss has not met (D-477).
    shape_diags = _check_wire_shape("", nameof(fn), entries, Diagnostic[])
    isempty(shape_diags) || throw(DiagnosticError(shape_diags))
    String[String(face_of(pair)) for pair in entries]
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

The helper serves an assembly that hands up the inputs of a child it does not
feed itself. Splat its entries into the assembly's [`input_wires`](@ref), where
they mix freely with hand-written ones, as in
`input_wires(w::World) = (input_passthrough(w, "aircraft"; except = ("atm",))...,)`.

Each face of the child, as [`input_faces`](@ref) lists it, becomes the pair
`prefix * sep * face => child_path * "/" * face`. A [bare](@ref g-bare-contract)
input is the face `u`, so the default labels an `integrator` child's bare input
`"integrator.u"`.

A [`Group`](@ref) has no declaration body, so its wire keyword takes a
function of the group that calls the helper, as in
`input_wires = g -> input_passthrough(g, "aircraft")`.

The default `prefix` folds the path's `/` into `sep`, so a
[container](@ref g-container-children) element `"units/1"` labels its faces
`"units.1.…"`, a legal face name. The helper uses an explicit `prefix` verbatim.
`prefix = ""` drops the prefixing entirely, labelling a bare input `u`.

`child_path` names an immediate child, a bare key where the container is
name-transparent. A deeper path is refused as `PathResolution`, as
[`resolve`](@ref) refuses it.

The three selection keywords are exclusive, one per call. More than one is
refused as `UnknownFaceSelection` with reason `:multiple_selectors`, and an
`except` or `only` name the child does not have as `UnknownFaceSelection` with
the child's faces listed. A selection keyword that keeps nothing warns
`EmptyFaceSelection` on the build, while a call with no selection keyword over a
child without faces is silent.

# Keywords

- `sep`: the separator between the prefix and the face name.
- `prefix`: the label in front of each face.
- `except`: the face names to leave out.
- `only`: the face names to keep.
- `select`: a predicate that receives each face name as a `String` and keeps
  the ones it accepts.

See also [`output_passthrough`](@ref).
"""
function input_passthrough(@nospecialize(assembly), child_path::AbstractString;
                           sep::AbstractString = ".",
                           prefix::AbstractString = replace(child_path, "/" => sep),
                           except::Tuple = (), only::Tuple = (), select = nothing)
    names = input_faces(resolve(assembly, child_path))
    wanted = _passthrough_faces("input_passthrough", child_path, names, except, only, select)
    Tuple(_labelled(prefix, sep, n) => string(child_path, "/", n) for n in wanted)
end

# Design: §6.1, §8.8, D-209, D-251.
# Its consumer is one-level routing: every level re-exports the outputs it
# surfaces, so the output side needs the computed spelling the input side
# already has.
# Each level re-exports the outputs it surfaces, so an output deep in the tree
# reaches the root only through one entry per level, which this helper computes.
"""
    output_passthrough(assembly, child_path::AbstractString; sep::AbstractString = ".",
                       prefix::AbstractString = replace(child_path, "/" => sep),
                       except::Tuple = (), only::Tuple = (), select = nothing) -> Tuple

Return output wire [entries](@ref g-entry) that expose a child's output
[faces](@ref g-face) on the [assembly](@ref g-assembly)'s own boundary.

`output_passthrough` is [`input_passthrough`](@ref)'s sibling on the outward
boundary. Splat its entries into the assembly's [`output_wires`](@ref). A
[`Group`](@ref)'s wire keyword takes a function of the group that calls the
helper, as in `output_wires = g -> output_passthrough(g, "aircraft")`. The
helper takes the same keywords over the faces [`output_faces`](@ref) lists, with the same
folded default `prefix` and the same three exclusive selection keywords, one per
call, `select` receiving face names.

Its pairs read along the flow, `child_path * "/" * face => prefix * sep * face`,
internal source to face name, as every pair in that declaration does. A
[bare](@ref g-bare-contract) output is the face `y`, labelled `"integrator.y"`
by default.

Its refusals are `input_passthrough`'s. More than one selection keyword, or an
unknown name, is refused as `UnknownFaceSelection`, and a selection keyword that
keeps nothing warns `EmptyFaceSelection` on the build.

# Keywords

- `sep`: the separator between the prefix and the face name.
- `prefix`: the label in front of each face.
- `except`: the face names to leave out.
- `only`: the face names to keep.
- `select`: a predicate that receives each face name as a `String` and keeps
  the ones it accepts.

See also [`input_passthrough`](@ref).
"""
function output_passthrough(@nospecialize(assembly), child_path::AbstractString;
                            sep::AbstractString = ".",
                            prefix::AbstractString = replace(child_path, "/" => sep),
                            except::Tuple = (), only::Tuple = (), select = nothing)
    names = output_faces(resolve(assembly, child_path))
    wanted = _passthrough_faces("output_passthrough", child_path, names, except, only, select)
    Tuple(string(child_path, "/", n) => _labelled(prefix, sep, n) for n in wanted)
end

_labelled(prefix, sep, n) = isempty(prefix) ? String(n) : string(prefix, sep, n)

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
`NamedTuple`'s own fields, a bare value's one pair under the store's `letter`
(D-438), none for `nothing`.
"""
store_fields(@nospecialize(contents), letter::Symbol) = pairs(_keyed(contents, letter))

# §7.1, §8.2, D-094: every `x_init` field, or the bare value, is a `Float64` or
# an `SArray` of them, and the declaration is flat. The arm names where the
# value belongs instead.
function check_state_leaves(path::String, @nospecialize(comp), diags::Vector{Diagnostic})
    for (name, value) in store_fields(invoke_declaration(x_init, comp), default_name(x_init))
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

# §8.6, D-437: a contract entry's name is a face name, never empty. A bare port
# omits the name, and an empty one is refused.
function check_contract_names(path::String, @nospecialize(comp), diags::Vector{Diagnostic})
    for fn in (u_types, y_types)
        decl = invoke_declaration(fn, comp)
        decl isa NamedTuple && any(name -> isempty(String(name)), keys(decl)) &&
            push!(diags, FaceNameIllegal(path = path, face = "", invariant = :empty))
    end
end

# §7.3, D-231: every store field, or the bare value, is isbits or a `Symbol`,
# checked on both stores.
function check_stores(path::String, @nospecialize(comp), diags::Vector{Diagnostic})
    for (store, fn) in ((:s_init, s_init), (:m_init, m_init))
        for (name, value) in store_fields(invoke_declaration(fn, comp), default_name(fn))
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
    # an entry that is no type is refused and read no further (§8.2), the
    # marker below the top of an entry is refused on both tiers (§8.2, D-265),
    # and a top marker says nothing where every leaf pins (§8.2, D-263).
    for (name, fn) in ((:u_types, u_types), (:y_types, y_types))
        _declares(fn, comp) || continue
        site = name === :u_types ? :face : :port
        letter = default_name(fn)
        declared = invoke_declaration(fn, comp)
        # `_keyed` reads `nothing` as no entry, a store's spelling; on a contract
        # it is one bare value, refused below (§8.2).
        entries = declared === nothing ? NamedTuple{(letter,)}((nothing,)) : _keyed(declared, letter)
        for (entry_name, P) in pairs(entries)
            if !(P isa Type)
                push!(diags, IllegalPortType(path = path, site = site, name = entry_name,
                                             declared = P, reason = :not_a_type))
                continue
            end
            _holds_marker(P) &&
                push!(diags, IllegalPortType(path = path, site = site, name = entry_name,
                                             declared = P, reason = :nested_marker))
            tier === DISCRETE && _is_marker(P) &&
                push!(diags, DeclarationOnWrongTier(path = path, declaration = name,
                                                   reason = :pinned_entry, entry = entry_name,
                                                   announced = :discrete))
        end
    end
    length(diags) == recorded ? tier : nothing
end

# --- the walk's memos (§9.7, §13.3, Appendix C) -------------------------------

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

# --- the anonymous assembly (§8.5, D-211, D-472) ------------------------------
# `Group` is written as a user's assembly is: a struct, its constructors and
# the assembly declarations. No build step names it, here or in any other
# file, so it stays an ordinary component (§13.7, D-472).

# Design: D-184, D-211, D-472.
# It needs no new rule: the container-children rule makes the `children`
# field's elements children of the `Group` itself.
# The type parameters carry the children's concrete types, so the executor
# specializes on them as on a named assembly. Every ad-hoc topology is a value
# of the one type. What a `Group` gives up against a named type is dispatch on
# the assembly.
"""
    Group

An [assembly](@ref g-assembly) written as a value, the form an assembly takes
unless domain code needs its type.

A `Group` is an assembly that holds its children and its declarations as field
values. The elements of its `children` field, a `NamedTuple` of
[components](@ref g-component), are its children. Its [`local_wires`](@ref),
[`input_wires`](@ref), [`output_wires`](@ref) and [`sample_times`](@ref) are
ordinary functions of the instance, which read its fields. A wire field holds
the [entries](@ref g-entry) or a function that computes them, as the
constructor states.

The one declaration it adds is [`transparent_container`](@ref). `children` is
[name-transparent](@ref g-container-children), so its elements go by bare key
everywhere a child name appears. That is `"ctl/out" => "plant/u"` for a wire,
`(ctl = Relative(2),)` for a rate, `at("ctl", …)` for a
[condition](@ref g-condition) prefix and `"plant"` for a read path, as in
`port(sim, "plant", :y)`. A `Group`'s declarations are then textually identical
to a named assembly's. The rate declaration's field-name sugar, keying on the
field rather than on a path segment, keeps working as
`(children = Relative(2),)` for the uniform case.
"""
struct Group{C <: NamedTuple, W, I, O, R <: NamedTuple} <: AbstractComponent
    children::C       # component-typed elements → children by the container rule
    local_wires::W    # inert parameter data: the entries, or a function of the `Group`
    input_wires::I
    output_wires::O
    sample_times::R   # the ad-hoc rate scope, keyed by bare element name (§8.7)
end

# Design: §8.5, D-303, D-473.
# This is the convenience form. The declarations are ordered collections
# of pairs, and a single wire should not have to be written `("a/x" => "b/y",)`.
"""
    Group(children; local_wires = (), input_wires = (), output_wires = (),
          sample_times = (;)) -> Group
    Group(g::Group; children = g.children, local_wires = g.local_wires,
          input_wires = g.input_wires, output_wires = g.output_wires,
          sample_times = g.sample_times) -> Group

Return a `Group` over `children`, or a copy of `g` with the given keywords
replaced.

The first form takes `children`, a `NamedTuple` of
[components](@ref g-component), and gives each [assembly](@ref g-assembly)
declaration by the keyword of its name. The second form takes every field from
`g` except those a keyword replaces, so `Group(g; local_wires = rewired)` keeps
the children, the boundary and the rates of `g`.

A wire keyword takes its [entries](@ref g-entry) written out or computed.
Written out, they are a tuple of pairs, or a bare `Pair` for one entry.
Computed, they are a `Function` that receives the `Group` and returns the
entries in either shape.

The `Group` stores a function without calling it. [`local_wires`](@ref),
[`input_wires`](@ref) and [`output_wires`](@ref) call it with the `Group` each
time they are read, and return its result, a bare `Pair` as the one-entry
tuple. A build reads them, so the function runs inside the build. A warning a
helper of the framework raises there, such as `EmptyFaceSelection`, joins the
build's warnings.

A function serves a helper that needs the assembly in hand, which does not
exist while the constructor's arguments are written.
`input_wires = g -> input_passthrough(g, "inner")` exposes the input
[faces](@ref g-face) of the child `inner`, as [`input_passthrough`](@ref)
computes them. The result may mix computed and written entries, as in
`g -> (input_passthrough(g, "inner")..., "cmd" => "act/cmd")`.

A function travels with the second form. A copy with other children computes
its entries from those children.

A field that holds a function does not hold the entries. Read them through the
declaration, `input_wires(g)`, never through the field, `g.input_wires`.

# Keywords

- `children`: the children of the copy, in the second form.
- `local_wires`: the wires between children, as [`local_wires`](@ref) returns
  them, or a function of the `Group` that returns them.
- `input_wires`: the inward boundary, as [`input_wires`](@ref) returns it, or
  a function of the `Group` that returns it.
- `output_wires`: the outward boundary, as [`output_wires`](@ref) returns it,
  or a function of the `Group` that returns it.
- `sample_times`: the rates of the children, keyed by bare child name, as
  [`sample_times`](@ref) returns them. It takes no function, and one given is
  a `MethodError` at construction.

# Examples

```jldoctest
julia> import Redstone: Group, input_passthrough, input_wires

julia> import Redstone.Library: UnitDelay

julia> inner = Group((; hold = UnitDelay(0.0)); input_wires = "u" => "hold/u");

julia> outer = Group((; inner); input_wires = g -> input_passthrough(g, "inner"; prefix = ""));

julia> input_wires(outer)
("u" => "inner/u",)
```
"""
Group(children; local_wires = (), input_wires = (), output_wires = (),
      sample_times = (;)) =
    Group(children, _entries(local_wires), _entries(input_wires),
          _entries(output_wires), sample_times)

# Design: §8.5, D-473.
# The copy is how a `Group` gets a variant, where a named assembly dispatches.
# Every field defaults to the original's, so a keyword left out carries its
# field and never empties it.
Group(g::Group; children = g.children, local_wires = g.local_wires,
      input_wires = g.input_wires, output_wires = g.output_wires,
      sample_times = g.sample_times) =
    Group(children; local_wires, input_wires, output_wires, sample_times)

_entries(wires::Pair) = (wires,)
_entries(wires) = wires

# Design: §8.5, §8.8, D-473.
# A wire field holds the entries or a function of the `Group`. The function is
# called here, at the read, so it runs in the build's walk as a named
# assembly's declaration body does: the passthrough helpers get the assembly
# they take, and their warnings reach the build's list. `g` is untyped so that
# no function of the package but the five declarations dispatches on a `Group`.
_declared(fn::Function, g) = _entries(fn(g))
_declared(wires, g) = wires

local_wires(g::Group) = _declared(g.local_wires, g)
input_wires(g::Group) = _declared(g.input_wires, g)
output_wires(g::Group) = _declared(g.output_wires, g)
sample_times(g::Group) = g.sample_times
transparent_container(::Group) = :children  # COV_EXCL_LINE

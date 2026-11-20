# The structure step (§9.1, D-261): the walk that turns the component tree into
# a `Structure`, and the reads over one. Endpoint resolution over the draft, the
# row types, `Structure` and `StructureDraft`, the flatten pass with its
# sample-time fold, the grid arithmetic with the trial binding (D-465), the
# wiring's resolution over the level rows (D-315) and the service walk (D-414).
# The declarations it reads are `assembly.jl`'s.

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
    name === nothing && return _wrong_direction(entry, path, comp_path, name, comp, "producer", diags)
    if classify(comp_path, comp) === PRIMITIVE
        haskey(_contract(y_types, comp), name) && return Tuple{String,Symbol}[(comp_path, name)]
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
    if name === nothing
        _wrong_direction(entry, path, comp_path, name, comp, "consumer", diags)
        return Vector{Tuple{String,Symbol}}[]
    end
    if classify(comp_path, comp) === PRIMITIVE
        haskey(_contract(u_types, comp), name) && return [Tuple{String,Symbol}[(comp_path, name)]]
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
# refused it. The child segment alone names no port (D-437), refused with the
# faces of the endpoint's side alone.
function _wrong_direction(entry, path, comp_path, name, @nospecialize(comp), wanted, diags)
    input_names, output_names = input_faces(comp), output_faces(comp)
    side_names, other_names = wanted == "producer" ? (output_names, input_names) :
                                                     (input_names, output_names)
    found = name !== nothing && String(name) in other_names ?
            (wanted == "producer" ? "an input" : "an output") : nothing
    if found === nothing
        push!(diags, UnknownPort(entry = entry,
                                endpoint = wanted == "producer" ? :source : :destination,
                                path = comp_path, spelling = String(path), port = name,
                                candidates = Symbol.(name === nothing ? side_names :
                                                     vcat(input_names, output_names))))
        return nothing
    end
    push!(diags, FaceDirectionConflict(entry = entry, path = comp_path,
                                      spelling = String(path),
                                      found = found == "an input" ? :input : :output,
                                      wanted = Symbol(wanted)))
    nothing
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
One anchor (§9.1, §9.2): the exact `(Δtₖ, τₖ)` an `Absolute` entry seeds, with
the `sample_times` entry that declared it, by scope path and key. Anchor 0,
the base grid, has no record here; it is symbolic until `Δt_base` binds.
"""
struct Anchor
    Δt::Rational{Int}
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

The [structure step](@ref g-structure)'s product, the declared facts the
[component](@ref g-component) tree alone fixes, held as rows.

Read it off a [`Build`](@ref) as `build.structure`. Nothing in it depends on a
scalar type. Its rows hold the component instances, and paths, names and
rationals the REPL prints as they are.

A `Structure` holds these fields.

- `components`: one entry per [primitive](@ref g-primitive), in the order the
  build walks the tree.
- `anchors`: one entry per [`Absolute`](@ref) declaration, the exact `(Δtₖ, τₖ)`
  pair (period and offset in rational seconds) with the declaring
  [scope](@ref g-rate-scope) and key.
- `scopes`: one entry per [assembly](@ref g-assembly) a `sample_times` key
  names, with its path, the key and the timing the build derived for it.
- `root_inputs`: the [root inputs](@ref g-root-input), in order.
- `root_types`: the types the wire check fixed for the root inputs, in order.
- `levels`: one entry per assembly, in pre-order with the root first, holding
  its children and the wires it declares.

A primitive root's `levels` entry has no children and no wires.

A `Structure` stores no table of resolved [faces](@ref g-face). A face at any
level resolves over the `levels` wires when it is read.
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
    scope_rates::Vector{Vector{RateLink}}   # per rate scope, beside `scopes`: the links met on the way down, its own last
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
                   Anchor[], RateScope[], Vector{RateLink}[],
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
`Δt > 0`, `0 ≤ τ < Δt`, and every key naming an immediate child.
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
        # (or `Δt`) leaves `φ` (or `τ`) with nothing to be measured against: the
        # dependent check is skipped, not doubled up.
        if rate isa Relative
            rate.K ≥ 1 ? (0 ≤ rate.φ < rate.K ||
                          record_violation(:phase; key = key, value = rate.φ)) :
                         record_violation(:multiplier; key = key, value = rate.K)
        else
            rate.Δt > 0 ? (0 ≤ rate.τ < rate.Δt ||
                           record_violation(:offset; key = key, value = rate.τ)) :
                          record_violation(:period; key = key, value = rate.Δt)
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
`(K, φ) = (1, 0)`, implemented by nothing. The law runs in checked `Int`
arithmetic, and a composed divisor or phase past `Int` is recorded as `:range`
on the entry; the child then continues at the enclosing timing too.
"""
function _child_scope(draft::StructureDraft, path::String, rate_decl, segment::String,
                      field::Symbol, scope::Timing, diags::Vector{Diagnostic})
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
        # A rate its own check refused composes nothing. A sound one keeps
        # `c < m`, so a phase past `Int` needs a multiplier past it first.
        1 ≤ rate.K && 0 ≤ rate.φ < rate.K || return scope, link
        timing = _exact_or_nothing(
            () -> Timing((scope.anchor, Base.Checked.checked_mul(rate.K, scope.m),
                          Base.Checked.checked_add(scope.c,
                                                   Base.Checked.checked_mul(rate.φ, scope.m)))))
        timing === nothing || return timing, link
        # A bare container key composes once per element, all alike, so the
        # elements share one refusal, as they share one anchor below (D-459).
        any(d -> d isa RatesViolation && d.path == path && d.key === key && d.reason === :range,
            diags) ||
            push!(diags, RatesViolation(path = path, reason = :range, key = key, value = rate))
        scope, link
    else
        # One anchor per `Absolute` entry (§9.1): a bare container key applies one
        # declaration to every element (§8.7), so the elements share the anchor
        # the first of them established rather than each pushing a twin.
        anchor_index = findfirst(anchor -> anchor.scope == path && anchor.key === key,
                                 draft.anchors)
        if anchor_index === nothing
            push!(draft.anchors, Anchor(rate.Δt, rate.τ, path, key))
            anchor_index = length(draft.anchors)
        end
        Timing((anchor_index, 1, 0)), link
    end
end

# --- the walk (§6.1, §9.1) ------------------------------------------------------

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
            for (face, declared) in pairs(_contract(u_types, draft.instances[ci]))
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
                # A bare `u_types` is the root input `u` (D-437).
                for face in keys(_contract(u_types, comp))
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
        # `sample_times` key opened, with the timing everything under it folds from,
        # and its chain beside it for the trial binding.
        below = _extend(chain, link)
        if link !== nothing
            push!(draft.scopes, RateScope((path = path, key = link.key, timing = scope)))
            push!(draft.scope_rates, below)
        end
        rate_decl = invoke_declaration(sample_times, comp)
        kids, fields = draft.child_lists[path] = _children(path, comp)
        # The one place a level is entered, ahead of its children: pre-order.
        push!(draft.level_paths, path)
        level_wires = draft.wires[path] = Pair{Tuple{String,Symbol},Tuple{String,Symbol}}[]
        _check_sample_times(path, rate_decl, kids, fields, diags)
        for ((segment, kid), field) in zip(kids, fields)
            child_path = _join(path, segment)
            kid_scope, kid_link = _child_scope(draft, path, rate_decl, segment, field, scope,
                                               diags)
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
# A bare contract takes its default face in that set, `u` or `y`, so two bare
# contracts collide on nothing (§8.2, D-437).
function _check_root_faces(@nospecialize(comp), diags::Vector{Diagnostic})
    output_names = keys(_contract(y_types, comp))
    duplicates = [String(n) for n in keys(_contract(u_types, comp)) if n in output_names]
    isempty(duplicates) ||
        push!(diags, FaceNameCollision(path = "", faces = duplicates, site = :root))
    nothing
end

# --- the grid arithmetic (§9.2, D-465) ------------------------------------------
# The exact arithmetic the structure step's trial binding shares with the
# `Deployment` constructor (deployment.jl's `bind_schedule` and `_lattice`), so
# the two cannot drift apart: one anchor's counts at a base tick, one timing's
# multiply-add, the frame loop's margin, and the grid attribution over the
# anchors.

# A whole quotient that fits `Int`, or `nothing`; a wide quotient past `Int` is
# `nothing` too, so its refusal is the caller's, never an `InexactError`.
_as_int(value::Rational) =
    denominator(value) == 1 && typemin(Int) ≤ numerator(value) ≤ typemax(Int) ?
    Int(numerator(value)) : nothing

# Trial division: the integers factored here are grid denominators, lcms of a
# handful of declared ones, so no prime table is worth a dependency. It stops at
# `PRIME_DIVISOR_CAP`, and the cofactor left is reported whole: below the cap's
# square it is prime, since a composite would have a factor below the cap, and
# at or above it the grid block prints it as unfactored. The condition is the
# square's, written so it cannot wrap.
const PRIME_DIVISOR_CAP = 2^20
function _prime_powers(integer::Int)
    powers = Tuple{Int,Int}[]
    cofactor, divisor = integer, 2
    while divisor ≤ PRIME_DIVISOR_CAP && divisor ≤ cofactor ÷ divisor
        if cofactor % divisor == 0
            power = 0
            while cofactor % divisor == 0; cofactor ÷= divisor; power += 1 end
            push!(powers, (divisor, power))
        end
        divisor += 1
    end
    cofactor > 1 && push!(powers, (cofactor, 1))
    powers
end

# Whether a pool entry's denominator supplies a factor of the grid's (§9.2,
# D-459). A prime power is supplied where it divides the denominator. An
# unfactored cofactor may be composite, with its primes in different entries,
# so it is supplied wherever the denominator shares a factor with it. It
# divides the lcm of the pool's denominators, so some entry always does.
_supplies(pool_denominator::Int, prime::Int, power::Int) =
    prime ≥ PRIME_DIVISOR_CAP^2 ? gcd(pool_denominator, prime) > 1 :
                                  pool_denominator % prime^power == 0

"""
The grid attribution D-187 asks for (§9.2), a pure function of the structure's
anchors: the constraint pool — every anchor's period and every nonzero offset,
in anchor order, periods first — with each entry's leave-one-out refinement
factor `r_p = gcd(pool ∖ p)/gcd(pool)`, the prime attribution of `gcd(pool)`'s
denominator, and, for a driving offset, the nearest offsets the rest of the pool
already supports, those whose arithmetic fits `Int`. No artifact holds it
(D-466). `bind_schedule` computes one per `Deployment` call, ahead of the
`Δt_base` branch, for the refusal path's suggestion, the derivation path's line
and the advisory, and `show(::Structure)` derives its own where it prints.
A built structure always has one: the trial binding fits the
gcd and every anchor's count at it, and each factor is at most one of those
counts (D-465).
"""
function _grid_report(anchors::Vector{Anchor})
    entry_kinds, entry_values, anchor_indices = Symbol[], Rational{Int}[], Int[]
    for (k, anchor) in enumerate(anchors)
        push!(entry_kinds, :period); push!(entry_values, anchor.Δt); push!(anchor_indices, k)
    end
    for (k, anchor) in enumerate(anchors)
        anchor.τ == 0 && continue
        push!(entry_kinds, :offset); push!(entry_values, anchor.τ); push!(anchor_indices, k)
    end
    isempty(entry_values) &&
        return GridReport(GridEntry[], nothing,
                          Vector{@NamedTuple{prime::Int, power::Int, suppliers::Vector{Int}}}())
    admissible = reduce(gcd, entry_values)
    pool = GridEntry[]
    for i in eachindex(entry_values)
        # The empty reduction has no value, so a singleton pool gives factor 1 by
        # convention: with nothing else declared, nothing is refined.
        partial = length(entry_values) == 1 ? admissible :
            reduce(gcd, (entry_values[j] for j in eachindex(entry_values) if j != i))
        factor = _as_int(partial / admissible)
        factor === nothing && throw(InternalInvariant(
            "leave-one-out factor $(partial / admissible) is not an integer: " *
            "gcd(pool) divides every partial gcd"))
        alternatives = Rational{Int}[]
        if entry_kinds[i] === :offset && factor > 1
            # The grid the rest of the pool supports, and τ's neighbours on it. The
            # fold requires 0 ≤ τ < Δt (`_check_sample_times`), so an upper neighbour
            # reaching the anchor's period is no offset; 0 stays, declaring none being
            # a repair.
            # A neighbour whose arithmetic leaves `Int` is not offered, since
            # `Absolute` refuses what `Rational{Int}` cannot hold (D-459). Each is a
            # product, which Julia reduces before it multiplies, so it fails only
            # for a value past `Int`; a sum could fail in an intermediate product.
            τ, Δt_k = entry_values[i], anchors[anchor_indices[i]].Δt
            lower_index = _exact_or_nothing(() -> floor(Int, τ / partial))
            if lower_index !== nothing
                lower = _exact_or_nothing(() -> lower_index * partial)
                upper = _exact_or_nothing(
                    () -> Base.Checked.checked_add(lower_index, 1) * partial)
                lower === nothing || push!(alternatives, lower)
                upper !== nothing && upper < Δt_k && push!(alternatives, upper)
            end
        end
        anchor = anchors[anchor_indices[i]]
        push!(pool, GridEntry(entry_kinds[i], entry_values[i], anchor.scope, anchor.key,
                              factor, alternatives))
    end
    primes = [(prime = prime, power = power,
               suppliers = [i for i in eachindex(entry_values)
                            if _supplies(denominator(entry_values[i]), prime, power)])
              for (prime, power) in _prime_powers(denominator(admissible))]
    GridReport(pool, admissible, primes)
end

# One anchor's counts at a base tick, `(Dₖ, Φₖ)` (§9.2): one exact division
# pair, each `nothing` where its quotient is not a whole `Int`. Each division
# runs in `Int128`, as `_lattice`'s do, so a count past `Int` is `nothing`,
# never a raw `OverflowError`.
_anchor_counts(anchor::Anchor, Δt_base::Rational{Int}) =
    (_as_int(Rational{Int128}(anchor.Δt) / Δt_base),
     _as_int(Rational{Int128}(anchor.τ) / Δt_base))

# One timing's `(D, Φ)` in base ticks (§9.2): `D = m·Dₖ` and `Φ = Φₖ + c·Dₖ`,
# against the anchors' counts, whose first entry is anchor 0's `(1, 0)`. The law
# runs in checked `Int`, so a count past it throws, and the caller catches.
function _timing_counts(timing::Timing, Dk::Vector{Int}, Φk::Vector{Int})
    D_anchor, Φ_anchor = Dk[timing.anchor + 1], Φk[timing.anchor + 1]
    (Base.Checked.checked_mul(timing.m, D_anchor),
     Base.Checked.checked_add(Φ_anchor, Base.Checked.checked_mul(timing.c, D_anchor)))
end

# The last frame index whose positions fit an `Int` (§10.5, D-445), from the
# frame and the base tick in the lattices' unit and the components' divisors.
# Inside frame `k` the largest position the loop forms is a due index's, at most
# the largest divisor's period past the frame top, so `k·frame` plus that margin
# must fit. In `Int128`; below 1, no frame fits.
_max_frame(frame::Int128, base::Int128, tick_divisors) =
    fld(Int128(typemax(Int)) - maximum(Int128, tick_divisors; init = Int128(0)) * base, frame)

# The link of `chain` that composed a count past `limit` (§9.2, D-465): the
# anchor's own `Absolute` entry, the chain's last, where the anchor's count
# `D_anchor` already passes it, else the first `Relative` link below the anchor
# at which the running count does. The count runs in `Int128`, each factor at
# most `typemax(Int)`.
function _composing_link(chain::Vector{RateLink}, D_anchor::Int, limit::Int)
    anchor_index = something(findlast(link -> link.entry isa Absolute, chain), 0)
    running = Int128(D_anchor)
    anchor_index > 0 && running > limit && return chain[anchor_index]
    for link in chain[anchor_index+1:end]
        running *= link.entry.K
        running > limit && return link
    end
    throw(InternalInvariant("no link of the chain composes a count past $limit"))
end

"""
The structure step's trial binding (§9.1, §9.2, D-465): the deployment's anchor
division, multiply-add and frame margin, run once at
`Δt_frame = Δt_base = gcd(pool)`, or at any base tick where the pool is empty.
Every count the binding forms is least there, so a structure this refuses binds
at no choice of the caller's, and one it passes binds at this one.

A count that leaves `Int` is a `RatesViolation` `:range` on the entry that
composed it, once per entry: an anchor's `Absolute` entry, or the first
`Relative` link below the anchor at which the running count passes. A gcd no
`Rational{Int}` holds refuses every anchor's entry. A frame margin that fits no
frame refuses, for each component at the largest divisor, the entry at which its
count passes that divisor less one. The premise is a fold that recorded no
violation: a faulty `Absolute` still pushes an anchor, a zero period among them.
"""
function _check_trial_binding(draft::StructureDraft, diags::Vector{Diagnostic})
    any(d -> d isa RatesViolation, diags) && return nothing
    # One refusal per entry, as the fold refuses its own `:range` (D-459).
    refuse(link::RateLink) =
        any(d -> d isa RatesViolation && d.path == link.scope && d.key === link.key &&
                 d.reason === :range, diags) ||
        push!(diags, RatesViolation(path = link.scope, reason = :range, key = link.key,
                                    value = link.entry))
    # An anchor's entry is a link on the chain of everything below it.
    chains = [draft.rates; draft.scope_rates]
    anchor_link(anchor::Anchor) =
        first(link for chain in chains for link in chain
              if link.scope == anchor.scope && link.key === anchor.key)

    pool = [[anchor.Δt for anchor in draft.anchors];
            [anchor.τ for anchor in draft.anchors if anchor.τ != 0]]
    Δt_base = isempty(pool) ? 1//1 : _exact_or_nothing(() -> reduce(gcd, pool))
    if Δt_base === nothing
        foreach(anchor -> refuse(anchor_link(anchor)), draft.anchors)
        return nothing
    end
    # Anchor 0 is the base grid itself.
    Dk, Φk, counted = [1], [0], [true]
    for anchor in draft.anchors
        D, Φ = _anchor_counts(anchor, Δt_base)
        formed = D !== nothing && Φ !== nothing
        formed || refuse(anchor_link(anchor))
        push!(Dk, something(D, 1)); push!(Φk, something(Φ, 0)); push!(counted, formed)
    end
    # A row's divisor, or `nothing` where it leaves `Int` or its anchor did. The
    # count of a sound composition keeps `Φ < D`, so only a divisor overflows.
    function tick_divisor(timing::Timing, chain::Vector{RateLink})
        counted[timing.anchor + 1] || return nothing
        counts = _exact_or_nothing(() -> _timing_counts(timing, Dk, Φk))
        counts === nothing && refuse(_composing_link(chain, Dk[timing.anchor + 1], typemax(Int)))
        counts === nothing ? nothing : first(counts)
    end
    discrete = [ci for ci in eachindex(draft.paths) if draft.tiers[ci] === DISCRETE]
    tick_divisors = [tick_divisor(draft.timings[ci], draft.rates[ci]) for ci in discrete]
    scope_divisors = [tick_divisor(scope.timing, chain)
                      for (scope, chain) in zip(draft.scopes, draft.scope_rates)]
    all(counted) && !any(isnothing, tick_divisors) && !any(isnothing, scope_divisors) ||
        return nothing
    # The frame margin at one unit each, over the components' divisors alone, as
    # `_lattice` reads it.
    _max_frame(Int128(1), Int128(1), tick_divisors) ≥ 1 && return nothing
    largest = maximum(tick_divisors)
    for (ci, D) in zip(discrete, tick_divisors)
        D == largest || continue
        refuse(_composing_link(draft.rates[ci], Dk[draft.timings[ci].anchor + 1], largest - 1))
    end
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

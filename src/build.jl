# The build pipeline (§9.2, §9.3, §5.5). Plain printable data in, a compiled
# executor out. Three jobs, in order, because each needs the previous one's
# answer:
#
#   1. probe stage 1 — needs no wiring at all (an `y_state` bundle carries
#      no `u`), which is what makes it the fixed point the rest of the build
#      stands on;
#   2. derive the feedthrough graph and schedule stage 2 topologically, since a
#      stage-1 port carries no dependence and therefore breaks would-be loops;
#   3. probe stage 2 in that order (real upstream values available by
#      construction) and the update law last, against the now-complete table.
#
# Its input is the flattened tree (`src/assembly.jl`): primitives by absolute
# path, one resolved producer per input. Assemblies are virtual from here on.

# --- 1. declarations at the activation scalar ---------------------------------

struct Decls
    x::Any                 # continuous state, walked to the activation scalar; `nothing` if none
    s::Any                 # discrete state, pinned wholesale (D-195); `nothing` if none
    ins::NamedTuple        # face => type, retyped at the activation scalar (D-263); keyed `BARE` when bare (D-436)
    outs::NamedTuple       # port => type, retyped at the activation scalar (D-263); keyed `BARE` when bare (D-436)
end

"""The tier's own state register: at most one of the two is ever other than `nothing`."""
state_decls(decl::Decls, tier::Tier) = tier === CONTINUOUS ? decl.x : decl.s

# One walk on the continuous tier (D-263): `x_init` by value and the contracts by
# type are all retyped at the activation scalar, every `Float64` position
# following it, a `Pinned` contract leaf the one exception. On the discrete tier
# the same declarations pin wholesale, so `s_init` does not walk and the
# contracts are read as written.
function declarations(@nospecialize(comp), tier::Tier, ::Type{T}) where {T}
    tier === CONTINUOUS ?
        Decls(retype_value(T, invoke_declaration(x_init, comp)), nothing,
              declared_at(u_types, comp, tier, T), declared_at(y_types, comp, tier, T)) :
        Decls(nothing, invoke_declaration(s_init, comp),
              declared_at(u_types, comp, tier), declared_at(y_types, comp, tier))
end

# --- 2. probing ---------------------------------------------------------------

"""
Probe the stage-1 function — `y_state`, on either tier (D-220) — for
every component in this activation's executable set: no wiring
is needed, so this runs first and tells the rest of the build which ports are
stage-1 — the ones that carry no dependence on inputs and therefore break loops
(§5.3). A frozen component's stages are outside the set (§9.4), so it probes
nothing here; `probe_stage2` carries its complete product across from the
nominal activation.

The `Δt` the discrete bundles carry is a fabricated, probe-scoped placeholder
(§9.3): `Δt` in seconds does not exist until the `Deployment` binds `Δt_base`, and
the probe checks types, not physics.
"""
function probe_stage1(structure::Structure, decls::Vector{Decls},
                      workspaces::Vector, mstores::Vector, ::Type{T}) where {T}
    # The instance is read inside the frame, never captured: a closure capturing it
    # would be a type, and a compile, per component type.
    map(enumerate(structure.components)) do (ci, entry)
        path, decl = entry.path, decls[ci]
        at_component(path) do
            comp = entry.instance
            _frozen(entry.tier, T) && return NamedTuple()
            has_stage(y_state, comp) || return NamedTuple()
            stage = String(nameof(y_state))
            bundle_fields = bundle_names(y_state, comp, entry.tier, ())
            returned = invoke_probed(y_state, :y_state, path, comp, entry.tier,
                                     _bundle_values(bundle_fields, decl, NamedTuple(), NamedTuple(),
                                                    T; ws = workspaces[ci], m = mstores[ci],
                                                    Δt = 1.0))
            # The declared shape picks the law (§9.3, D-436): a named contract's
            # return is a `NamedTuple` of ports, a bare one's the port's value,
            # held to its type by the port check like any port.
            if !is_bare(decl.outs)
                returned isa NamedTuple ||
                    throw(DiagnosticError(ConformanceFailure(path = path, what = stage,
                                                        reason = :return_type, shape = :ports,
                                                        observed = typeof(returned))))
                isempty(returned) && throw(DiagnosticError(DeadStage(path = path, stage = stage)))
            end
            y = _keyed_return(decl.outs, returned)
            _check_ports(path, stage, y, decl.outs, T)
            _embed_ports(y, decl.outs, T)
        end
    end
end

# The probe bundle from keyed values: `u`, `y1` and `y` arrive keyed as the
# products are, and a bare side's field carries its one value (§5.2, D-436).
function _bundle_values(bundle_fields, decl::Decls, u, y1, ::Type{T}; y = NamedTuple(),
                        ws = nothing, m = nothing, Δt = 0.0) where {T}
    field_values = map(bundle_fields) do field
        field === :x   ? decl.x :
        field === :s   ? decl.s :
        field === :m   ? m[] :
        field === :u   ? _bundle_side(decl.ins, u) :
        field === :y_x ? _bundle_side(decl.outs, y1) :
        field === :y_s ? _bundle_side(decl.outs, y1) :
        field === :y   ? _bundle_side(decl.outs, y) :
        field === :ws  ? ws :
        field === :t   ? zero(T) :
        field === :Δt  ? Δt : throw(InternalInvariant("no probe source for $field"))
    end
    NamedTuple{bundle_fields}(field_values)
end

# A keyed side as its bundle field carries it: a bare side's one value, a named
# side's `NamedTuple` (§5.2, D-436).
_bundle_side(contract::NamedTuple, values::NamedTuple) = is_bare(contract) ? values[BARE] : values

# A stage's return in the products' keyed form, a bare port's value under `BARE`
# (D-436): the bookkeeping keys every port by name, the bare one by the empty one.
_keyed_return(outs::NamedTuple, returned) =
    is_bare(outs) ? NamedTuple{(BARE,)}((returned,)) : returned

# The per-port loop collects (§13.1): a stage returning three wrong types names
# all three.
function _check_ports(path, stage, y::NamedTuple, outs::NamedTuple, ::Type{T}) where {T}
    diags = Diagnostic[]
    for (name, value) in pairs(y)
        if !haskey(outs, name)
            push!(diags, UndeclaredReturnField(path = path, stage = stage, name = name,
                                              candidates = collect(keys(outs))))
            continue                               # nothing declared to compare against
        end
        _accepts(outs[name], typeof(value), T) ||
            push!(diags, ConformanceFailure(path = path, what = stage, reason = :field_type,
                                           shape = :ports, field = name,
                                           observed = typeof(value), declared = outs[name],
                                           activation = T))
    end
    isempty(diags) || throw(DiagnosticError(diags))
    nothing
end

"""
What the cell will hold: an accepted `Float64` arrival stored into the
activation buffer *is* a zero-partial, so the probe hands downstream the
embedded value rather than the literal the stage returned. Without this the
probe's product types diverge from the ones the runtime gather produces. The
lift is leaf by leaf, exactly where `_accepts` admitted it: a `Float64` leaf
at a position `P` declares `T`; every other leaf, a pinned `Float64`, a `Bool`,
an enum, passes through.
"""
_embed(::Type{P}, v, ::Type{T}) where {P,T} =
    typeof(v) === P ? v :
    reconstruct(P, Any[lt === T && l isa Float64 ? T(l) : l
                       for (lt, l) in zip(leaf_types(P), _leaf_values(v))], 0)

_embed_ports(y::NamedTuple, outs::NamedTuple, ::Type{T}) where {T} =
    NamedTuple{keys(y)}(map(n -> _embed(outs[n], y[n], T), keys(y)))

# --- 2b. the store homes (§7.1, §8.3, D-252) ----------------------------------
# All that is left of the port classification's store side: `DeclaredNotProduced`
# names the declared port no stage returns, and the store fields are the context
# that points at the remedy.

"""
The tier's state homes, in merge order: `x` then `m` on the continuous tier, `s`
on the discrete (§5.3, §7.1, §7.3), each `nothing` where the component has none.
`m` arrives as the probe-scoped `Ref`, or `nothing` where the component declares
no modes.
"""
_homes(decl::Decls, tier::Tier, m) =
    tier === CONTINUOUS ? (x = decl.x, m = m === nothing ? nothing : m[]) : (s = decl.s,)

"""
The tier's store field names, for `DeclaredNotProduced`'s list-in-hand (§8.3). A
bare store has no field name, so its letter stands for the whole value.
"""
_state_fields(homes::NamedTuple) =
    Symbol[(name === BARE ? letter : name)
           for (letter, home) in pairs(homes) for (name, _) in store_fields(home)]

# --- 3. the nominal evaluation's products -------------------------------------

"""
The `Outputs` (§9.1, D-253, D-261): every component's declared ports split into
the stage-1 names and the stage-2 remainder, and the execution order Kahn takes
over the feedthrough graph. The artifact carries the two name lists and the
order; the graph stays the builder's scratch. Edges run producer → consumer for
every consumed **stage-2** port; consuming a stage-1 port adds no edge, which is
the whole structural payoff of the split — a stage-1 port takes no input and so
carries no input dependence (§5.3). A stall is not reported as its residue: the
residue is *decomposed* into one `AlgebraicCycle` per strongly connected cluster
below (§13.8, D-012), which is why `edges` keeps each dependence's port and face,
which Kahn itself discards.
"""
function _outputs(structure::Structure, decls::Vector{Decls},
                  stage1::Vector, mstores::Vector)
    n_components = length(structure.components)
    ports = [Symbol[keys(decls[ci].outs)...] for ci in 1:n_components]
    stage1_names = [Symbol[keys(stage1[ci])...] for ci in 1:n_components]
    stage2_names = [filter(∉(stage1_names[ci]), ports[ci]) for ci in 1:n_components]
    dependencies = [Int[] for _ in 1:n_components]
    # per consumer: (producer, port, face)
    edges = [Tuple{Int,Symbol,Symbol}[] for _ in 1:n_components]
    for (ci, entry) in enumerate(structure.components)
        has_stage(y_direct, entry.instance) || continue
        for face in keys(decls[ci].ins)
            (producer_path, producer_port) = terminal_producer(structure, (entry.path, face))
            isempty(producer_path) && continue           # a root input: no producer to wait for
            producer_ci = index_of(structure, producer_path)
            # stage-1 position: no dependence
            haskey(stage1[producer_ci], producer_port) && continue
            push!(dependencies[ci], producer_ci)
            push!(edges[ci], (producer_ci, producer_port, face))
        end
    end

    order = Int[]
    ready = [ci for ci in 1:n_components if isempty(dependencies[ci])]
    remaining = Set(1:n_components)
    while !isempty(ready)
        ci = popfirst!(ready)
        push!(order, ci)
        delete!(remaining, ci)
        for cj in collect(remaining)
            if ci in dependencies[cj]
                dependencies[cj] = filter(!=(ci), dependencies[cj])
                isempty(dependencies[cj]) && push!(ready, cj)
            end
        end
    end

    isempty(remaining) ||
        throw(DiagnosticError(_cycle_diagnostics(structure, edges, remaining, order, decls,
                                                 stage1, mstores)))
    Outputs([ComponentOutputs(entry.path, stage1_names[ci], stage2_names[ci])
             for (ci, entry) in enumerate(structure.components)], order)
end

"""
§13.8, D-012: the stalled subgraph decomposed. Every nontrivial strongly connected
component of the subgraph induced on the unplaced components is one cluster and
one diagnostic; the innocent downstream cone the residue also holds lies in no
such component and is reported nowhere. `members` is the depth-first preorder
along the cluster's own wires from its lowest flatten index, neighbours taken in
flatten order, and `wires` follows the members. Each cluster is then handed to
the tracer for §13.8's classification, `placed` being the acyclic prefix its
out-of-cycle faces read from.
"""
function _cycle_diagnostics(structure::Structure, edges::Vector{Vector{Tuple{Int,Symbol,Symbol}}},
                            remaining::Set{Int}, placed::Vector{Int},
                            decls::Vector{Decls}, stage1::Vector, mstores::Vector)
    nodes = sort!(collect(remaining))
    successors = [Int[] for _ in structure.components]  # producer → consumer, inside the residue
    for ci in nodes, (producer_ci, _, _) in edges[ci]
        producer_ci in remaining && push!(successors[producer_ci], ci)
    end
    for ci in nodes
        successors[ci] = sort!(unique(successors[ci]))
    end

    clusters = Tuple{Int,AlgebraicCycle}[]
    for scc in _tarjan(nodes, successors)
        length(scc) > 1 || first(scc) in successors[first(scc)] || continue
        member_set = Set(scc)
        order = _cluster_walk(scc, successors, member_set)
        position = Dict(ci => i for (i, ci) in enumerate(order))
        wires = Tuple{Int,Int,Symbol,Symbol}[]
        for ci in order, (producer_ci, producer_port, face) in edges[ci]
            producer_ci in member_set &&
                push!(wires, (position[producer_ci], position[ci], producer_port, face))
        end
        sort!(wires)
        path_at(ci) = structure.components[ci].path
        # Slash form, a bare port by its component alone (D-436).
        cycle = AlgebraicCycle(members = String[path_at(ci) for ci in order],
                               wires = [_named(path_at(order[producer_position]), port_name, "/") =>
                                        _named(path_at(order[consumer_position]), face_name, "/")
                                        for (producer_position, consumer_position,
                                             port_name, face_name) in wires])
        push!(clusters, (minimum(scc), _classify(cycle, order, edges, placed, structure, decls,
                                                 stage1, mstores)))
    end
    sort!(clusters; by = first)
    Diagnostic[cycle for (_, cycle) in clusters]
end

"Tarjan's algorithm over `nodes`, recursive: the strongly connected components."
function _tarjan(nodes::Vector{Int}, successors::Vector{Vector{Int}})
    index, low, on_stack, stack, sccs = Dict{Int,Int}(), Dict{Int,Int}(), Set{Int}(), Int[], Vector{Int}[]
    function strong!(node)
        index[node] = low[node] = length(index) + 1
        push!(stack, node)
        push!(on_stack, node)
        for successor in successors[node]
            if !haskey(index, successor)
                strong!(successor)
                low[node] = min(low[node], low[successor])
            elseif successor in on_stack
                low[node] = min(low[node], index[successor])
            end
        end
        if low[node] == index[node]
            scc = Int[]
            while true
                member = pop!(stack)
                delete!(on_stack, member)
                push!(scc, member)
                member == node && break
            end
            push!(sccs, scc)
        end
    end
    for node in nodes
        haskey(index, node) || strong!(node)
    end
    sccs
end

"The cluster's members in walk order: a cluster is strongly connected, so one walk reaches all."
function _cluster_walk(scc::Vector{Int}, successors::Vector{Vector{Int}}, member_set::Set{Int})
    order, seen = Int[], Set{Int}()
    function visit!(node)
        push!(seen, node)
        push!(order, node)
        for successor in successors[node]
            successor in member_set && !(successor in seen) && visit!(successor)
        end
    end
    visit!(minimum(scc))
    order
end

# --- 4. cell layout -----------------------------------------------------------
# Every declared port gets a cell; so does every root input face, the one
# terminal legitimately fed by no component, its initial value synthesized by
# `probe_value` (§6.1, §9.3, §11.3). A root input's *type* is the structure
# step's, fixed once by the wire pass and carried on the `Structure`; the layout
# picks its cells per activation from that type, by the meet below (D-168, D-236).
#
# An assembly's faces get no cells of their own. A face *is* its ultimate
# internal endpoint (§8.6), so it is entered as an alias onto that endpoint's
# address — which is what makes a face's type and tier derived rather than
# declared.

"""
One stop request (§13.5, D-316): the publishing component, its `StopFlag`
port, and the component's `stop_reason`.
"""
struct Requester
    path::String
    port::Symbol
    reason::String
end

struct Layout
    addr::Dict{Tuple{String,Symbol},Any}     # (path, port|face) => CellAddr
    root_inputs::Vector{Tuple{Symbol,Any}}   # root inputs, with their probe values
    sizes::Vector{Pair{DataType,Int}}        # leaf eltype => buffer length, name-sorted
    xblocks::Vector{UnitRange{Int}}          # per component: its range in the flat `x` buffer, empty where it owns none
    requesters::Vector{Requester}            # entry `i` owns offset `i - 1` of the `StopFlag` buffer (§13.5, D-316)
end

function cell_layout(structure::Structure, decls::Vector{Decls}, ::Type{T}) where {T}
    addr = Dict{Tuple{String,Symbol},Any}()
    root_inputs = Tuple{Symbol,Any}[]
    offsets = Dict{DataType,Int}()
    # Placement collects (§13.1): every leafless declaration in the model is
    # named, every mutable one and every handle surfacing as a root input
    # (D-237), and the barrier throws before the alias pass, which would
    # otherwise look up an address placement never made.
    diags = Diagnostic[]
    function place!(path, site::Symbol, name, ::Type{P}) where {P}
        mutable_site = mutable_position(P)
        if mutable_site !== nothing
            push!(diags, IllegalPortType(path = path, site = site, name = name, declared = P,
                                         reason = :mutable, position = first(mutable_site)))
            return false
        end
        leaves = leaf_types(P)
        if isempty(leaves)
            push!(diags, IllegalPortType(path = path, site = site, name = name, declared = P))
            return false
        end
        # The roster is per port, so a request nested in another port type
        # would have no entry of its own (§13.5, D-316).
        if P !== StopFlag && StopFlag in leaves
            push!(diags, IllegalPortType(path = path, site = site, name = name, declared = P,
                                         reason = :stop_flag_nested))
            return false
        end
        eltypes = leaf_eltypes(P)
        addr[(path, name)] = CellAddr{P,length(eltypes)}(Tuple(get(offsets, L, 0) for L in eltypes))
        for L in eltypes
            offsets[L] = get(offsets, L, 0) + count(==(L), leaves)
        end
        true
    end
    for (entry, decl) in zip(structure.components, decls)
        for (port_name, P) in pairs(decl.outs)
            place!(entry.path, :port, port_name, P)
        end
    end
    for (i, face) in enumerate(structure.root_inputs)
        cell_type = _root_input_cell(structure, decls, i, face, T)
        # A request is the model's, never an operator's (§12.1, §13.5, D-316),
        # so a root input carrying a `StopFlag` anywhere is refused. A mutable
        # `cell_type` is left to `place!`'s own arm, as in the check below.
        if mutable_position(cell_type) === nothing && StopFlag in leaf_types(cell_type)
            push!(diags, IllegalPortType(path = "", site = :root_input, name = face,
                                         declared = cell_type, reason = :stop_flag_at_root))
            continue
        end
        # An opaque leaf at a root input, a handle or a `Symbol`, has no
        # synthesis and no producer (D-237, D-243), so it is refused here, ahead
        # of `probe_value`. A real or an enum leaf has a synthesis (§9.3). A
        # mutable `cell_type` is left to `place!`'s own arm on the next line,
        # whatever its leaves.
        if mutable_position(cell_type) === nothing &&
           any(L -> !(L <: Real || L <: Enum), leaf_types(cell_type))
            push!(diags, IllegalPortType(path = "", site = :root_input, name = face,
                                         declared = cell_type, reason = :handle_at_root))
            continue
        end
        place!("", :root_input, face, cell_type) || continue
        # §9.3, D-051: the synthesis chain ends at `P()`, and a type reaching
        # it with no zero-argument constructor has no probe value. Collected,
        # beside the placement refusals above. A `MethodError` out of an
        # author's override is the override's own and propagates.
        value = try
            probe_value(cell_type)
        catch err
            (err isa MethodError && _framework_synthesis(cell_type)) || rethrow()
            push!(diags, MissingProbeValue(face = face, declared = cell_type))
            continue
        end
        push!(root_inputs, (face, value))
    end
    isempty(diags) || throw(DiagnosticError(diags))
    # Assembly output faces alone: a primitive's input face enters nothing, since
    # a primitive below the root may share a key between its contracts (D-210).
    for level in structure.levels, face in _boundary_outputs(level)
        addr[(level.path, face)] = addr[terminal_producer(structure, (level.path, face))]
    end
    sizes = sort!([L => n for (L, n) in offsets]; by = p -> string(first(p)))
    # The flat buffer's layout is the declaration walk (§7.1): one range per
    # component, the one home every `x` offset is read from (§13.4, D-261).
    xblocks, n_x = UnitRange{Int}[], 0
    for (decl, entry) in zip(decls, structure.components)
        width = entry.tier === CONTINUOUS ? nleaves(typeof(decl.x)) : 0
        push!(xblocks, (n_x+1):(n_x+width))
        n_x += width
    end
    # The stop-request roster (§13.5, D-316): one entry per `StopFlag` port,
    # each written at the slot its cell's offset names rather than assumed from
    # the walk, so entry `i` owns offset `i - 1` of the buffer.
    requesters = Vector{Requester}(undef, get(offsets, StopFlag, 0))
    for (entry, decl) in zip(structure.components, decls)
        flag_ports = Symbol[port_name for (port_name, P) in pairs(decl.outs) if P === StopFlag]
        isempty(flag_ports) && continue
        reason = at_component(() -> invoke_declaration(stop_reason, entry.instance), entry.path)
        for port_name in flag_ports
            requesters[addr[(entry.path, port_name)].offsets[1] + 1] =
                Requester(entry.path, port_name, reason)
        end
    end
    all(i -> isassigned(requesters, i), eachindex(requesters)) ||
        throw(InternalInvariant("a `StopFlag` offset with no requester"))
    Layout(addr, root_inputs, sizes, xblocks, requesters)
end

# A root input's cells at an activation: D-168's meet, at the level of the whole
# root input, with D-236's two candidates — the root-input type with every leaf
# following `T` when every consumer's entry at `T` admits it, the root-input type
# itself otherwise. The structure step fixed the type and checked the entries, so nothing
# is recorded here; at nominal the two candidates coincide.
function _root_input_cell(structure::Structure, decls::Vector{Decls}, root_index::Int, face::Symbol,
                          ::Type{T}) where {T}
    P_F = structure.root_types[root_index]
    walked_type = retype(T, P_F)
    consumer_types = (decls[ci].ins[consumer_face]
                      for (ci, entry) in enumerate(structure.components)
                      for consumer_face in keys(decls[ci].ins)
                      if terminal_producer(structure, (entry.path, consumer_face)) == ("", face))
    all(input_type -> _accepts_wire(input_type, walked_type, T), consumer_types) ? walked_type : P_F
end

# --- 5. the Build artifact and its activations (§9.2, §9.4) ---------------------

"""
One activation: the typed products at a concrete scalar `T` (§9.1) —
declarations retyped at `T`, the probe chain run over exactly the function
set this activation can execute (§9.4), cells laid out. Immutable once
constructed; the probe products are what a cell holds until first written
(§10.5).
"""
struct Activation{T}
    decls::Vector{Decls}
    products::Vector{NamedTuple}   # complete probe products, per component, a bare port's keyed `BARE`
    layout::Layout
end

"""
One component's outputs (§9.1): the port names each stage produces, `stage1`
in the return's order, `stage2` the declared remainder in `y_types`
order. Their concatenation is the products' order, stage 1 then stage 2.
"""
struct ComponentOutputs
    path::String
    stage1::Vector{Symbol}
    stage2::Vector{Symbol}
end

"The output port names in the products' order (§8.3): stage 1, then stage 2."
_ports(entry::ComponentOutputs) = vcat(entry.stage1, entry.stage2)

# Design: §9.1, D-253, D-261.
"""
    Outputs

The output [port](@ref g-port) names each [component](@ref g-component)'s stages
produce, and the order the components run in.

`Outputs` is a product of the [nominal evaluation](@ref g-nominal), read off a
[`Build`](@ref) as `build.outputs`. Its `components` field holds one entry per
component, in the order the build walks the tree. Each entry carries the
component's `path`, the ports [`y_state`](@ref) returns as `stage1`, in the
return's order, and the declared remainder, in [`y_types`](@ref) order, as
`stage2`. Their concatenation is the order of the component's products. The
`order` field is the [execution order](@ref g-execution-order) over the indices
of `components`.

`Outputs` holds names only and does not depend on the scalar type, so a reader
that wants a list of port names takes it from here rather than from an
[activation](@ref g-activation). The [feedthrough](@ref g-feedthrough) graph the
order was computed over is not carried. Where it is shown, it is derived from
the [`Structure`](@ref)'s connections and the producers' `stage2`.
"""
struct Outputs
    components::Vector{ComponentOutputs}   # in walk order; the index is `ci`
    order::Vector{Int}                     # the execution order over `ci`
end

"""
One component's events (§9.1, §10.4): the detection policy each guard's return
form fixes, by event name in declaration order, and the event bundle's field
names, `()` where the component declares no events.
"""
struct ComponentEvents
    path::String
    policies::NamedTuple   # event name => :boundary | :localized
    bundle::Tuple
end

# Design: §9.1, D-253.
# Built last, after the stage probes. It is separate from `Outputs` because a
# different input fixes it, the event declarations, read after the probes, so a
# consumer of the execution order never carries the event tables.
"""
    Events

The detection policy of each [component](@ref g-component)'s events, and the
field names of its event [bundle](@ref g-bundle).

`Events` is the other product of the [nominal evaluation](@ref g-nominal), read
off a [`Build`](@ref) as `build.events`. Its `components` field holds one entry
per component, in the order the build walks the tree, so one index addresses it
and [`Outputs`](@ref) alike. Each entry carries the component's `path`, its
`policies` and its `bundle`.

- `policies`: a `NamedTuple` from each event name, in declaration order, to the
  detection policy its [guard](@ref g-guard)'s return form fixes, `:boundary`
  for a `Bool` guard checked at step [boundaries](@ref g-boundary) only, or
  `:localized` for a guard returning a `Float64`, whose crossing is located in
  time.
- `bundle`: the field names of the event bundle, `()` where the component
  declares no events.

Like `Outputs`, `Events` holds names only and does not depend on the scalar
type.
"""
struct Events
    components::Vector{ComponentEvents}
end

# Design: §9.1, §9.2, §9.4.
# The activations are one dictionary keyed by scalar type, the nominal
# `Float64` entry included like any other, and the lock makes its insertion
# torn-state-free. The schedule the structure carries is anchor-relative, each
# component entry's `timing` against `structure.anchors`, because final
# divisors for anchored entries do not exist until `Δt_base` binds.
"""
    Build

The artifact [`build`](@ref) produces, the checked contract of a
[component](@ref g-component) tree before any grid is fixed.

A build holds the [`Structure`](@ref), the [`Outputs`](@ref) and the
[`Events`](@ref), which the build's steps produce, then its
[activations](@ref g-activation) and the warnings its construction raised, read
with [`warnings`](@ref). The first three do not depend on the scalar type, by
construction. The [nominal](@ref g-nominal) `Float64` activation is made by the
build, and any other is derived at first request and kept.

Everything in a build is settled before [`Δt_base`](@ref g-dt_base) exists: `h`,
`N_base` and `Δt_base` are the [`Deployment`](@ref)'s. A build is immutable
apart from its activation cache, whose insertion is safe across tasks. One build
backs any number of deployments and [`Model`](@ref)s, concurrently, each
materializing its own [stores](@ref g-store) and [buffers](@ref g-buffer).

See also [`descriptor`](@ref).
"""
struct Build
    structure::Structure
    outputs::Outputs
    events::Events
    activations::Dict{DataType,Any}   # keyed by scalar type, the nominal `Float64` entry included
    lock::ReentrantLock               # guards `activations` (§9.4's torn-state guarantee)
    warnings::Vector{Diagnostic}      # the warnings the build raised (§9.1, D-250)
end

"The probe scalar's own tag (§9.4): what keeps a probe activation distinguishable from trim's (`TrimTag`) and from a user's own."
struct ProbeTag end

# Design: §9.4, §14.10, D-099, D-272.
# `LinearizeDual` is the scalar of `linearize`'s default width.
"""
    ProbeDual

The framework's public canonical [probe](@ref g-probe) scalar, the concrete
`ForwardDiff.Dual{ProbeTag,Float64,1}`.

`ProbeDual` is the one concrete `Dual` a test lists to check that a
[component](@ref g-component) tree types at a dual number, as in
`build(root; activations = (Float64, ProbeDual))`. An
[activation](@ref g-activation) is keyed by a concrete scalar, and the bare
`Dual`, a `UnionAll`, can key none.

Its width is one because the check tests that the tree's types follow the
scalar, not any particular Jacobian. [`linearize`](@ref) sets its own width with
its `width` keyword.
"""
const ProbeDual = ForwardDiff.Dual{ProbeTag,Float64,1}

# Design: §9.1, §9.4, D-253, D-259.
# The nominal activation is the nominal evaluation's own product, never a
# separate pass. `activations` is the opt-in exhaustive mode.
"""
    build(root::AbstractComponent; activations::Tuple = ()) -> Build

Check a [component](@ref g-component) tree and return its [`Build`](@ref), with
no grid chosen yet.

`build` runs the structure step, the [nominal evaluation](@ref g-nominal) and
the eager [activations](@ref g-activation). The structure step flattens the
tree, classifies its components and type-checks the wires into the
[`Structure`](@ref). The nominal evaluation [probes](@ref g-probe) every user
function. It returns the [`Outputs`](@ref), the [`Events`](@ref) and the nominal
activation. Nothing here needs `h`, `N_base` or [`Δt_base`](@ref g-dt_base),
which are the [`Deployment`](@ref)'s.

# Keywords

- `activations`: the scalar types whose activations are made at once instead
  of at first request, such as `(Float64, ProbeDual)` in a test that checks the
  tree types at a dual number. See [`ProbeDual`](@ref).

A tree the build rejects is refused as one `DiagnosticError` that carries every
diagnostic the failing step found, and the warnings raised so far. A build that
succeeds logs each warning once and keeps it, read with [`warnings`](@ref).

See also [`descriptor`](@ref), [`Model`](@ref), [`Simulation`](@ref).
"""
Base.@nospecializeinfer function build(@nospecialize(root::AbstractComponent);
                                       activations::Tuple = ())
    # Unspecialized, as the whole declaration layer is, so a new root type
    # compiles none of it again (§9.7, D-289).
    # One binding around all three steps, and one list (§9.1, D-250): a helper
    # inside a declaration body appends to it without knowing the build, the
    # completed `Build` carries it, and a throw leaving the build takes it along.
    raised_warnings = Diagnostic[]
    # The structure, hoisted out of the closure so the catch below can attach it
    # to a carrier leaving past the structure step (§13.9, D-434).
    structure = nothing
    built = try
        with(BUILD_WARNINGS => raised_warnings) do
            diags = Diagnostic[]
            draft = StructureDraft(root)
            flatten_tree!(draft, root, diags)    # structure, tiers, claims, the obligation check
            _check_event_declarations(draft, diags)
            # The dependency rule (§13.1, D-229): the wire pass reads the wiring, which a
            # dirty walk never produced, so it runs on a clean walk alone.
            isempty(diags) || throw(DiagnosticError(diags))
            root_types = _check_wires(draft, diags)
            # The structure step's barrier (§13.1, D-229): every pass that ran merges here, and
            # nothing derived from the wiring is computed before it. No cascade
            # suppression — a typo'd wire reports its unknown port *and* the input it
            # left unfed.
            isempty(diags) || throw(DiagnosticError(diags))
            structure = Structure(draft, root_types)   # the artifact, complete at construction (D-261)
            outputs, events, nominal = _nominal(structure)
            built = Build(structure, outputs, events, Dict{DataType,Any}(Float64 => nominal),
                          ReentrantLock(), raised_warnings)
            for scalar in activations
                activation(built, scalar)
            end
            built
        end
    catch err
        # The rewrap sits here, not at each barrier: a barrier throws the
        # collection its own passes produced and stays ignorant of the channel,
        # and only the entry point knows the whole build's warnings (D-250) and
        # whether the structure step completed (D-434). A requested activation
        # throws past that step too, so its carrier takes the structure as well.
        err isa DiagnosticError &&
            throw(DiagnosticError(err.carried, raised_warnings, structure))
        rethrow()
    end
    # The completed build carries the record; the entry point logs each warning
    # once at return, through the standard backend (Appendix C's `logged`).
    for warning in raised_warnings
        @warn logline(warning)
    end
    built
end

# An event needs both halves (§8.2): a guard or handler with no method for the
# component type is caught by method lookup at declaration-reading time, rather
# than as a `MethodError` at the first firing — an event firing only in a corner
# of the envelope would otherwise hide the omission indefinitely.
function _check_event_declarations(draft::StructureDraft, diags::Vector{Diagnostic})
    # The pass runs before the `Structure` is built, so it reads the draft's
    # own columns. It collects (§13.1): every malformed entry in the model is
    # named, not the first one the walk reaches, and the list merges into the step's.
    # By index: a closure capturing the instance would be a type per component type.
    for (ci, path) in enumerate(draft.paths)
        at_component(path) do
            comp = draft.instances[ci]
            for (name, event) in pairs(invoke_declaration(state_events, comp))
                if !(event isa StateEvent)
                    push!(diags, EventHalfMissing(path = path, event = name,
                                                 reason = :not_an_event, found = _typename(event)))
                    continue                       # neither half exists to look up
                end
                for (half, fn) in ((:guard, event.guard), (:handler, event.handler))
                    hasmethod(fn, Tuple{typeof(comp),NamedTuple}) ||
                        push!(diags, EventHalfMissing(path = path, event = name, reason = half,
                                                     found = _typename(comp)))
                end
            end
        end
    end
    nothing
end

# --- The structure step's wire pass (§6.1, §9.1, D-236) -----------------------

"""
The marker scalar (§8.2, §9.1): the continuous contracts are retyped at it to
tell a walking leaf from a pinned one — a leaf typed `Marker` walks with the
activation, anything else is pinned. It never enters arithmetic.
"""
struct Marker <: Real end
Base.show(io::IO, ::Type{Marker}) = print(io, "T")   # a declaration at the marker prints as written

# The two type clauses on every resolved wire, and the root-input type with its
# two refusals. Pure declaration reading — the contracts are retyped at
# `Float64` for the bound clause and at the marker for the walk clause; no stage
# runs. The pass collects (§13.1): every wire is checked, and the barrier throws
# once. Runs on the clean draft, ahead of the `Structure`, and returns the
# root-input types the artifact takes at construction (D-236, D-261). The list
# holds `nothing` only on the abstract-at-root arm below, which records a
# diagnostic, so the barrier throws before the `Structure` narrows it.
function _check_wires(draft::StructureDraft, diags::Vector{Diagnostic})
    # Each primitive's input faces with their producers, off the claims of a walk
    # that fed every input once (§6.1). The pass's own list: the artifact holds
    # none, and resolves through `terminal_producer` (D-315). By index: a closure
    # taking the instance would compile once per component type (D-289).
    conns = [[face => draft.feeds[(draft.paths[ci], face)]
              for (face, _) in contract_fields(_contract(u_types, draft.instances[ci]))]
             for ci in eachindex(draft.paths)]
    contracts_at(fn, scalar) = [at_component(() -> declared_at(fn, draft.instances[ci],
                                                               draft.tiers[ci], scalar),
                                             draft.paths[ci])
                                for ci in eachindex(draft.paths)]
    ins_F, outs_F = contracts_at(u_types, Float64), contracts_at(y_types, Float64)
    ins_M, outs_M = contracts_at(u_types, Marker), contracts_at(y_types, Marker)
    for (ci, consumer_conns) in enumerate(conns),
        (face, (producer_path, producer_port)) in consumer_conns
        isempty(producer_path) && continue           # a root input: typed below
        producer_ci = index_of(draft, producer_path)
        P_F, V_F = ins_F[ci][face], outs_F[producer_ci][producer_port]
        if !_accepts_wire(P_F, V_F, Float64)
            push!(diags, WireTypeMismatch(path = draft.paths[ci], face = face, declared = P_F,
                                          producer_path = producer_path,
                                          producer_port = producer_port, observed = V_F))
            continue        # the walk clause reads a shape the bound clause has vouched for
        end
        draft.tiers[ci] === CONTINUOUS || continue    # D-167's tier scope
        P_M, V_M = ins_M[ci][face], outs_M[producer_ci][producer_port]
        _accepts_wire(P_M, V_M, Marker) && continue
        leaf, declared, observed = _walking_leaf(P_M, V_M)
        push!(diags, WalkingFaceAtFrozenEntry(path = draft.paths[ci], face = face,
                                              producer_path = producer_path,
                                              producer_port = producer_port,
                                              leaf = leaf, declared = declared,
                                              observed = observed))
    end
    root_types = Any[]
    for face in draft.root_inputs
        paths, faces, consumer_types, routed = String[], Symbol[], Any[], false
        for (ci, consumer_conns) in enumerate(conns), (consumer_face, producer) in consumer_conns
            producer === ("", face) || continue
            routed = true
            push!(paths, draft.paths[ci]); push!(faces, consumer_face)
            push!(consumer_types, ins_F[ci][consumer_face])
        end
        routed || throw(InternalInvariant("root input face `$face` routes to no input"))
        concrete = findall(isconcretetype, consumer_types)
        if isempty(concrete)
            push!(diags, AbstractAtRoot(face = face, paths = paths, declared = consumer_types))
            push!(root_types, nothing)
            continue
        end
        P_F = consumer_types[first(concrete)]
        any(k -> consumer_types[k] !== P_F, concrete) &&
            push!(diags, RootInputTypeConflict(face = face, paths = paths[concrete],
                                               declared = consumer_types[concrete]))
        for k in eachindex(consumer_types)           # abstract co-consumers: the bound clause
            k in concrete && continue
            _accepts_wire(consumer_types[k], P_F, Float64) ||
                push!(diags, WireTypeMismatch(path = paths[k], face = faces[k],
                                              declared = consumer_types[k], producer_path = "",
                                              producer_port = face, observed = P_F))
        end
        push!(root_types, P_F)
    end
    root_types
end

# The offending leaf, for the walk clause's message. For a concrete entry the
# bound clause at `Float64` is exact (`V_F === P_F`, D-238), so the two leaf
# lists align position for position. A walk failure at the marker is a `Marker`
# in `V_M` where `P_M` has `Float64`, or an opaque leaf the producer walks and
# the entry pins (`OffsetField{Marker}` against `OffsetField{Float64}`), which is
# one leaf with no scalar pair, so the first differing leaf names it. Throwing
# path only.
function _walking_leaf(::Type{P}, ::Type{V}) where {P,V}
    isconcretetype(P) || return nothing, P, V     # decided on the whole declaration
    entry_leaves, producer_leaves = leaf_types(P), leaf_types(V)
    offending = findfirst(k -> entry_leaves[k] === Float64 && producer_leaves[k] === Marker,
                          eachindex(entry_leaves))
    offending === nothing &&
        (offending = findfirst(k -> entry_leaves[k] !== producer_leaves[k],
                               eachindex(entry_leaves)))
    offending === nothing &&
        throw(InternalInvariant("walk clause failed at `$P` ← `$V` with no differing leaf"))
    leaf_names(P)[offending], entry_leaves[offending], producer_leaves[offending]
end

"""
    activation(build, T) → Activation{T}

The activation at `T`, from the build's dictionary or derived at first request
(§9.4). The nominal `Float64` entry is one key there like any other, put in by
the nominal evaluation. An activation is a pure function of the build and the
concrete scalar type, so caching is invisible. The lookup and the insertion each
hold the build's lock and the re-run happens between them, so concurrent first
requests never see a torn dictionary: the worst race is a duplicated re-run, and
the first writer's activation is the one every caller gets.
"""
function activation(build::Build, ::Type{T}) where {T}
    hit = @lock build.lock get(build.activations, T, nothing)
    hit === nothing || return hit::Activation{T}
    nominal = (@lock build.lock build.activations[Float64])::Activation{Float64}
    derived = _activate(build.structure, build.outputs, nominal, T)
    (@lock build.lock get!(build.activations, T, derived))::Activation{T}
end

# Design: §9.2, D-250. The build produces artifacts, so its warnings live on
# them; the log line each one got at return is presentation, never the home.
# `Deployment`, `Model` and `Simulation` answer the same generic
# (`deployment.jl`, `model.jl`, `sim.jl`).
"""
    warnings(build::Build) -> Vector{Diagnostic}

Return the warnings raised while the build was constructed.

Each warning was also logged once when [`build`](@ref) returned. The list on
the build is where they stay, so a caller never has to capture the log. For a
deployment's, a model's or a simulation's list, see the other methods of
`warnings`.
"""
warnings(build::Build) = build.warnings

# The nominal evaluation (§9.1, D-253, D-259): the build's one
# evaluation-feeds-structure step, a function of the structure alone. It runs the
# whole nominal probe chain once and returns its three products — the outputs,
# the events and the nominal `Float64` activation — so the structure and the
# `Float64` typing are fixed together rather than in two passes. Every stage is
# probed (§9.3's probe-everything scope), the classification and the execution
# order fall out between the two probe passes, and the event declarations are read
# last, against every component's complete nominal product and the layout.
function _nominal(structure::Structure)
    decls = _declarations(structure, Float64)

    # Probe-scoped mode stores and workspaces (§9.3): the probes need `m` and
    # `ws` to build bundles, and everything these hold is garbage once the
    # build finishes — each `Model` materializes its own.
    mstores = _mstores(structure)
    workspaces = _workspaces(structure, Float64)

    stage1 = probe_stage1(structure, decls, workspaces, mstores, Float64)
    outputs = _outputs(structure, decls, stage1, mstores)
    layout = cell_layout(structure, decls, Float64)
    products = probe_stage2(structure, decls, stage1, outputs.order, layout,
                            workspaces, mstores, nothing, Float64)
    nominal = Activation{Float64}(decls, products, layout)
    outputs, probe_events(structure, nominal), nominal
end

# Every component's declarations at `T`, each read under its component frame (§13.2, D-248).
_declarations(structure::Structure, ::Type{T}) where {T} =
    [at_component(() -> declarations(entry.instance, entry.tier, T), entry.path)
     for entry in structure.components]

# Activation at another scalar (§9.1, §9.4): the nominal evaluation's typed half
# re-run at `T`, with nothing structural recomputed. Declarations are retyped at
# `T`, the probe chain runs and the cells are laid out, over the `Outputs`'
# execution order, which is `T`-independent. A frozen component's products are
# carried across from the nominal activation rather than probed, its stages being
# outside this activation's executable set.
function _activate(structure::Structure, outputs::Outputs, nominal::Activation{Float64},
                   ::Type{T}) where {T}
    decls = _declarations(structure, T)
    mstores = _mstores(structure)
    workspaces = _workspaces(structure, T)

    stage1 = probe_stage1(structure, decls, workspaces, mstores, T)
    layout = cell_layout(structure, decls, T)
    products = probe_stage2(structure, decls, stage1, outputs.order, layout,
                            workspaces, mstores, nominal, T)
    Activation{T}(decls, products, layout)
end

# Probe-scoped mode stores (§9.3). One read of `m_init` per component, under the
# component frame (§13.2, D-248).
_mstores(structure::Structure) =
    Any[at_component(() -> (m = invoke_declaration(m_init, entry.instance);
                            m === nothing ? nothing : Ref(m)), entry.path)
        for entry in structure.components]

# Declaration by allocation (§8.2, D-077): sizes from the instance, eltypes from
# the activation. Called once per probe and once per `Model`.
_workspaces(structure::Structure, ::Type{T}) where {T} =
    Any[_workspace(entry, T) for entry in structure.components]

_workspace(entry::ComponentEntry, ::Type{T}) where {T} =
    at_component(entry.path) do
        comp = entry.instance                      # read here, not captured: see `probe_stage1`
        _declares_workspace(comp) || return nothing
        invoke_declaration(ws_init, comp, entry.tier === CONTINUOUS ? T : Float64)
    end

# A discrete component's stages never run at a non-nominal activation: its
# cells are frozen `Float64` constants with zero partials, holding what the
# probe wrote, which is exactly what a tick at `t₀⁻` would have produced
# (§7.2, §10.5; `frozen_discrete_walkthrough.md`).
_frozen(tier::Tier, ::Type{T}) where {T} = tier === DISCRETE && T !== Float64

"""
Probe stage 2 in topological order — real upstream values available by
construction — and the update laws last, checking every return against the
declaration (§9.3); then the declaration-completeness check, for every
component. Frozen components are not probed: their complete products come from
`carry`, the nominal activation (§9.4). The discrete bundles' `Δt` is the
probe-scoped placeholder of `probe_stage1`. Returns the complete probe
products.
"""
function probe_stage2(structure::Structure, decls::Vector{Decls},
                      stage1, order::Vector{Int}, layout::Layout,
                      workspaces::Vector, mstores::Vector, carry, ::Type{T}) where {T}
    # The complete product is a value table read by name, never sliced: a reader
    # wanting a name list takes it from the `Outputs` instead (§9.1, D-253).
    products = NamedTuple[s1 for s1 in stage1]

    # A frozen component's stages never run at this activation, so its complete
    # product is the *nominal* activation's, carried across (§9.4): its cells
    # hold what a tick at `t₀⁻` computed from real nominal inputs — pinned
    # `Float64` constants, which downstream continuous consumers embed as
    # zero-partials. The dependence through it is temporal, not instantaneous
    # (`frozen_discrete_walkthrough.md`), so nothing here needs to gather the
    # `Dual` cell its pinned input declaration would otherwise have to refuse.
    for (ci, entry) in enumerate(structure.components)
        _frozen(entry.tier, T) && (products[ci] = carry.products[ci])
    end

    in_values(ci, decl) = NamedTuple{tuple(keys(decl.ins)...)}(tuple(
        (_probe_input(structure, layout, products, ci, face, decl.ins[face], T)
         for face in keys(decl.ins))...))

    for ci in order
        _probe_direct!(products, ci, structure, decls, stage1, layout,
                       workspaces, mstores, T)
    end

    # Completeness of the declaration set (§8.2), for every component and not
    # only the stateful ones: an unproduced port would otherwise own a cell that
    # no stage ever writes, and read as a silent zero forever. The pass collects
    # (§13.1): every component with an unproduced port is named, and the barrier
    # throws once for the whole model — as the two below it do.
    diags = Diagnostic[]
    for (ci, entry) in enumerate(structure.components)
        missing_ports = setdiff(keys(decls[ci].outs), keys(products[ci]))
        isempty(missing_ports) ||
            push!(diags, DeclaredNotProduced(path = entry.path,
                                            ports = collect(missing_ports),
                                            products = collect(keys(products[ci])),
                                            state_fields = _state_fields(
                                                _homes(decls[ci], entry.tier, mstores[ci]))))
    end
    isempty(diags) || throw(DiagnosticError(diags))

    # The update laws, probed against the now-complete table: `x_deriv`
    # for shape, `s_update` for the store's own type. A frozen component's
    # `s_update` is outside the executable set like its output stages (§9.4).
    empty!(diags)
    for (ci, entry) in enumerate(structure.components)
        path, decl, tier = entry.path, decls[ci], entry.tier
        (state_decls(decl, tier) === nothing || _frozen(tier, T)) && continue
        at_component(path) do
            comp = entry.instance                  # read here, not captured: see `probe_stage1`
            update = update_of(tier)
            bundle_fields = bundle_names(update, comp, tier, tuple(keys(stage1[ci])...))
            bundle = _bundle_values(bundle_fields, decl, in_values(ci, decl), stage1[ci], T;
                                    y = products[ci], ws = workspaces[ci], m = mstores[ci],
                                    Δt = 1.0)
            append!(diags, tier === CONTINUOUS ?
                _check_derivative(path,
                    invoke_probed(x_deriv, :x_deriv, path, comp, tier, bundle),
                    decl.x, T) :
                _check_update(path,
                    invoke_probed(s_update, :s_update, path, comp, tier, bundle), decl.s))
        end
    end
    isempty(diags) || throw(DiagnosticError(diags))

    # `x_projection`, probed at every activation it runs at — its result is
    # written back to the buffer wholesale at both schedule positions (§5.3), so
    # the check holds it *complete* against `X`'s own shape at `T` (§9.3).
    empty!(diags)
    for (ci, entry) in enumerate(structure.components)
        comp = entry.instance
        has_stage(x_projection, comp) || continue
        path, decl = entry.path, decls[ci]
        if entry.tier !== CONTINUOUS
            push!(diags, DeclarationOnWrongTier(path = path, declaration = :x_projection,
                                               reason = :continuous_only))
            continue                               # no manifold to run it against
        end
        if decl.x === nothing
            push!(diags, DeclarationOnWrongTier(path = path, declaration = :x_projection,
                                               reason = :no_manifold))
            continue
        end
        append!(diags, at_component(path) do
            _check_state_write(path, "x_projection",
                               invoke_declaration(x_projection, entry.instance, decl.x), decl.x, T)
        end)
    end
    isempty(diags) || throw(DiagnosticError(diags))
    products
end

"""
One component's stage-2 probe, writing its complete product into `products[ci]`:
the body of `probe_stage2`'s topological loop, factored so the cycle classifier
can run the same chain over the acyclic prefix Kahn did place (§13.8). A
component with no `y_direct`, and a frozen one, is a no-op.
"""
function _probe_direct!(products::Vector{NamedTuple}, ci::Int, structure::Structure,
                        decls::Vector{Decls}, stage1,
                        layout::Layout, workspaces::Vector, mstores::Vector, ::Type{T}) where {T}
    entry = structure.components[ci]
    path, decl = entry.path, decls[ci]
    (has_stage(y_direct, entry.instance) && !_frozen(entry.tier, T)) || return nothing
    at_component(path) do
        comp, s1 = entry.instance, stage1[ci]      # read here, not captured: see `probe_stage1`
        stage = String(nameof(y_direct))
        bundle_fields = bundle_names(y_direct, comp, entry.tier, tuple(keys(s1)...))
        u = NamedTuple{tuple(keys(decl.ins)...)}(tuple(
            (_probe_input(structure, layout, products, ci, face, decl.ins[face], T)
             for face in keys(decl.ins))...))
        returned = invoke_probed(y_direct, :y_direct, path, comp, entry.tier,
                                 _bundle_values(bundle_fields, decl, u, s1, T;
                                                ws = workspaces[ci], m = mstores[ci], Δt = 1.0))
        # The declared shape picks the law, as in `probe_stage1` (§9.3, D-436).
        if !is_bare(decl.outs)
            returned isa NamedTuple ||
                throw(DiagnosticError(ConformanceFailure(path = path, what = stage,
                                                    reason = :return_type, shape = :namedtuple,
                                                    observed = typeof(returned))))
            isempty(returned) && throw(DiagnosticError(DeadStage(path = path, stage = stage)))
        end
        y2 = _keyed_return(decl.outs, returned)
        _check_ports(path, stage, y2, decl.outs, T)
        # Stage-1 position is the stage's: a stage-2 return of a port stage 1
        # already returned writes it twice (§5.3, §8.3).
        twice = intersect(keys(s1), keys(y2))
        isempty(twice) ||
            throw(DiagnosticError(ProducedByTwoStages(path = path, ports = collect(twice))))
        products[ci] = merge(s1, _embed_ports(y2, decl.outs, T))
    end
    nothing
end

# The complete state write-back (§9.3): the same predicate for
# `x_projection`'s return and a handler's `x` key, both written to the flat
# buffer wholesale.
#
# It returns its violation list rather than throwing, so its two callers — the
# `x_projection` pass and the handler check — can put it under their own
# barrier (§13.1). The two shape checks are sequential: neither later one is
# meaningful once an earlier one fails.
function _check_state_write(path, what, x⁺, x, ::Type{T}; event = nothing) where {T}
    # The declared shape picks the law: a bare state is one arrival at its type.
    x isa NamedTuple ||
        return _accepts(typeof(x), typeof(x⁺), T) ? Diagnostic[] :
               Diagnostic[ConformanceFailure(path = path, what = what, event = event,
                                             reason = :field_type, shape = :state, field = BARE,
                                             observed = typeof(x⁺), declared = typeof(x),
                                             activation = T)]
    x⁺ isa NamedTuple ||
        return Diagnostic[ConformanceFailure(path = path, what = what, event = event,
                                             reason = :return_type, shape = :state,
                                             observed = typeof(x⁺))]
    Set(keys(x⁺)) == Set(keys(x)) ||
        return Diagnostic[ConformanceFailure(path = path, what = what, event = event,
                                             reason = :field_set, shape = :state,
                                             observed_fields = collect(keys(x⁺)),
                                             declared_fields = collect(keys(x)))]
    diags = Diagnostic[]
    for field in keys(x)
        _accepts(typeof(x[field]), typeof(x⁺[field]), T) ||
            push!(diags, ConformanceFailure(path = path, what = what, event = event,
                                           reason = :field_type,
                                           shape = :state, field = field,
                                           observed = typeof(x⁺[field]),
                                           declared = typeof(x[field]), activation = T))
    end
    diags
end

"""
Probe the event system, at the nominal activation only (§9.3, D-052): guards
and handlers never run at a non-nominal activation (§9.4), so nothing here is
parametric in the scalar. Each guard runs against real probed values and its
return type *is* the detection policy (§10.4, D-179) — `Bool` boundary-detected,
the nominal scalar localized, anything else an error naming both admissible
forms. Each handler runs once and its return is held to the §5.2 return law,
key by key. Returns the `Events`, the nominal evaluation's last product (§9.1,
D-253): one row per component, its policy register beside the bundle names its
guards and handlers are called with.
"""
function probe_events(structure::Structure, act::Activation{Float64})
    decls, layout, products = act.decls, act.layout, act.products
    mstores = _mstores(structure)
    workspaces = _workspaces(structure, Float64)
    rows = ComponentEvents[]
    for (ci, entry) in enumerate(structure.components)
        path, decl = entry.path, decls[ci]
        policies, bundle_fields = at_component(path) do
            comp = entry.instance                  # read here, not captured: see `probe_stage1`
            declared_events = invoke_declaration(state_events, comp)
            isempty(declared_events) && return NamedTuple(), ()
            bundle_fields = event_bundle_names(comp)
            u = NamedTuple{tuple(keys(decl.ins)...)}(tuple(
                (_probe_input(structure, layout, products, ci, face, decl.ins[face], Float64)
                 for face in keys(decl.ins))...))
            bundle = _bundle_values(bundle_fields, decl, u, NamedTuple(), Float64;
                                    y = products[ci], ws = workspaces[ci], m = mstores[ci])
            # A loop, not a `map` closure, which would capture the instance and its
            # events and so be a type per component type.
            declared_names = tuple(keys(declared_events)...)
            event_policies = Symbol[]
            for name in declared_names
                σ = invoke_probed(declared_events[name].guard, :guard, path, comp,
                                  CONTINUOUS, bundle)
                policy = σ isa Bool ? :boundary :
                         σ isa Float64 ? :localized :
                         throw(DiagnosticError(GuardForm(path = path, event = name,
                                                    observed = typeof(σ))))
                _check_handler(path, name,
                    invoke_probed(declared_events[name].handler, :handler, path, comp,
                                 CONTINUOUS, bundle),
                    decl, comp)
                push!(event_policies, policy)
            end
            NamedTuple{declared_names}(Tuple(event_policies)), bundle_fields
        end
        push!(rows, ComponentEvents(path, policies, bundle_fields))
    end
    Events(rows)
end

# The handler return law (§5.2, §9.3): a key is present iff the store exists on
# the component and the handler updates it. Key set first — an unknown key, or a
# key naming a store the component does not declare, names the stores that
# exist. Then per key: `x` complete (the flat buffer is written back wholesale),
# `m` a names-subset with matching types (per-field stores merge naturally).
#
# The key loops collect under one barrier per handler (§13.1): a handler naming
# three stores it does not own names all three.
function _check_handler(path, name, returned, decl::Decls, @nospecialize(comp))
    what = "handler"        # the event rides beside it, and the renderer composes the two
    returned isa NamedTuple ||
        throw(DiagnosticError(ConformanceFailure(path = path, what = what, event = name,
                                            reason = :return_type,
                                            shape = :stores, observed = typeof(returned))))
    m₀ = invoke_declaration(m_init, comp)
    stores = Symbol[]
    decl.x === nothing || push!(stores, :x)
    m₀ === nothing || push!(stores, :m)
    diags = Diagnostic[]
    for key in keys(returned)
        key in stores ||
            push!(diags, HandlerReturnKey(path = path, event = name, key = key, stores = stores))
    end
    # Per key, but only for a store the component actually declares: the key set
    # is the outer fact, and holding a write to `x` against an empty state would
    # report the same omission twice in different words.
    haskey(returned, :x) && :x in stores &&
        append!(diags, _check_state_write(path, "$what `x`", returned.x, decl.x, Float64;
                                          event = name))
    if haskey(returned, :m) && :m in stores
        if !(m₀ isa NamedTuple)
            # A bare mode store is written whole, at its own type exactly.
            typeof(returned.m) === typeof(m₀) ||
                push!(diags, ConformanceFailure(path = path, what = "$what `m`", event = name,
                                               reason = :field_type, shape = :mode, field = BARE,
                                               observed = typeof(returned.m),
                                               declared = typeof(m₀)))
        elseif !(returned.m isa NamedTuple)
            push!(diags, ConformanceFailure(path = path, what = "$what `m`", event = name,
                                           reason = :return_type, shape = :mode,
                                           observed = typeof(returned.m)))
        else
            for field in keys(returned.m)
                if !haskey(m₀, field)
                    push!(diags, ConformanceFailure(path = path, what = what, event = name,
                                                   reason = :field_set, shape = :mode,
                                                   field = field,
                                                   declared_fields = collect(keys(m₀))))
                elseif typeof(returned.m[field]) !== typeof(m₀[field])
                    push!(diags, ConformanceFailure(path = path, what = what, event = name,
                                                   reason = :field_type, shape = :mode,
                                                   field = field,
                                                   observed = typeof(returned.m[field]),
                                                   declared = typeof(m₀[field])))
                end
            end
        end
    end
    isempty(diags) || throw(DiagnosticError(diags))
    nothing
end

# --- 7. entry compilation, per deployment ---------------------------------------
# What moves behind deployment binding: `Δt`, `D` and `Φ` are entry data (§9.7),
# so the executor cannot exist until `Δt_base` does. Each call materializes its
# own stores and buffers — the `Build` stays immutable and backs many
# `Model`s (§9.2). No user stage runs here: every check already ran at the
# probe, and what compiles is the checked shape.

"""
The declared defaults, established into the three state homes (§7.3, §8.2):
`x` into the flat buffer by the declaration walk, `s` and `m` into the
component stores they were allocated for. The stores' *types* are fixed by
their allocation; this only ever writes values into them.

Construction and `init!` share this one path, which is what makes an
application "fresh run from the `*_init` defaults, with these overrides"
(D-063) rather than an overlay on whatever the last trajectory left behind.
"""
function establish_defaults!(xbuf::Vector{T}, sstores::Vector, mstores::Vector,
                             components::Vector{ComponentEntry}, decls::Vector{Decls}) where {T}
    offset = 0
    for (ci, (decl, entry)) in enumerate(zip(decls, components))
        if entry.tier === CONTINUOUS
            for leaf_value in _leaf_values(decl.x)
                offset += 1
                xbuf[offset] = T(leaf_value)
            end
        end
        sstores[ci] === nothing || (sstores[ci][] = decl.s)
        mstores[ci] === nothing || (mstores[ci][] = m_init(entry.instance))
    end
    nothing
end

"""
One executor (§9.7, glossary): the compiled execution form of the schedule over
its own buffers, at one scalar — the entries' concretely-typed tuples closed
into the phase bodies, beside the store set they read and write.

Buffers are never cached, because every buffer set has exactly one owner
(§9.2): a `Model` owns its executor, and every service invocation
instantiates its own from the same cached layouts.

The stepper, the arrival buffers, `chunk_size` and the localized-event key are
the executor's too (§12.6, D-256): it is the one thing that writes them. The
stepper's type is the parameter `M` because `stepper.jl` is included after this
file, which a call tolerates and a field type would not.
"""
struct Executor{T,S,B,CL,EV,M}
    act::Activation{T}     # the layout and probe products it was materialized from
    store::S               # the signal table: cells and root inputs
    xbuf::Vector{T}        # continuous state, the flat buffer (§7.1)
    ẋbuf::Vector{T}        # its derivative, the flat `ẋ` buffer (§7.1)
    sstores::Vector{Any}   # discrete state stores, by component index
    mstores::Vector{Any}   # mode stores, by component index
    clock::CL
    bodies::B              # the phase bodies, closed over the buffers above
    events::EV             # the compiled event set, likewise (nominal only)
    cursor::ExecutionCursor          # §13.4: where execution is, written per dispatch
    chunk_size::Int        # the unroll width it was compiled at, retained so a service
                           # can compile one of its own exactly as this was
    stepper::M             # the seam's backend (§10.2), with its own scratch
    xnext::Vector{T}       # the retained arrival pair (§10.4), xₙ₊₁ saved
    ẋnext::Vector{T}       # ẋₙ₊₁, paid only past a validated trigger
    has_localized::Bool    # any localized event compiled in: the frame loop's fast-path key
end

"""
The refusal every product compiled *against one activation* owes the executor
it is handed. A reader's `xbuf` offsets and store types and a plan's cell
addresses and converters are one activation's (§9.4), so running one against
another's buffer set would read and write the wrong slot in silence rather than
fail. The scalar rides in each product's own type and the executor carries it
too, so the pairing is dispatch — the fallback method, never a runtime test on
the hot path.

It carries no kind name, because it names no user-facing failure: §14.4 makes
the pairing a framework invariant the services uphold, neither plans nor
readers being user values, so reaching here is an internal assertion firing.
"""
@noinline _activation_mismatch(what::String, ::Type{T}, ::Type{S}) where {T,S} =
    throw(InternalInvariant(
        "this $what was compiled at $T and the executor " *
        "handed to it runs at $S — a service paired its products wrongly (§14.4). The " *
        "offsets, store types and cell addresses it bakes belong to one activation (§9.4), " *
        "and against another's buffer set they would read and write the wrong slot in " *
        "silence; one product is compiled per activation (§9.2)"))

# `algorithm` takes no default: it is trajectory-determining (§12.7), so a
# scratch executor silently built on `RK4` against a `Heun` deployment would
# give a wrong answer with no diagnostic. Every caller passes the deployment's.
# `schedule` is the deployment's `Schedule`, untyped here because `deployment.jl` is
# included after this file; the per-component gates are derived from its rows
# by `_gates` there (§9.2, D-261).
function compile(build::Build, act::Activation{T}, schedule; chunk_size::Int = 16,
                 algorithm) where {T}
    structure, outputs, decls, layout = build.structure, build.outputs, act.decls, act.layout
    components = structure.components
    D_c, Φ_c, Δt_c = _gates(schedule, structure)

    # Three homes for state, and no store mirrors another (§5.2): the flat
    # buffer for continuous `x`, one store per discrete `s`, one per mode set.
    # A store's *type* is shared by every instance of a component type, so
    # instances still compile to one body; only the reference varies.
    sstores = Any[entry.tier === DISCRETE && decl.s !== nothing ? Ref(decl.s) : nothing
                  for (decl, entry) in zip(decls, components)]
    mstores = _mstores(structure)
    workspaces = _workspaces(structure, T)

    store = StoreBundle(NamedTuple{tuple((_cell_key(L) for (L, _) in layout.sizes)...)}(
        tuple((CellStore(L <: Real ? zeros(L, n) : Vector{L}(undef, n))
               for (L, n) in layout.sizes)...)))

    x_offs = [first(r) - 1 for r in layout.xblocks]
    n_x = sum(length, layout.xblocks; init = 0)
    xbuf = zeros(T, n_x)
    establish_defaults!(xbuf, sstores, mstores, components, decls)
    ẋbuf = zeros(T, n_x)
    clock = Clock{T}(0.0)
    cursor = ExecutionCursor()     # closed over by every entry, exactly as `clock` is (§13.4)

    addr_group(path, names) =
        NamedTuple{tuple(names...)}(tuple((layout.addr[(path, n)] for n in names)...))
    # What an entry gathers or writes on one side: a bare side's one address, read
    # and written as the value itself, or a named side's group (§5.2, D-436).
    entry_addrs(path, names) = names == [BARE] ? layout.addr[(path, BARE)] : addr_group(path, names)
    # An input face's address is its terminal producer's, stored nowhere (D-315).
    input_addr(ci, face) = layout.addr[terminal_producer(structure, (components[ci].path, face))]
    in_group(ci, decl) =
        is_bare(decl.ins) ? input_addr(ci, BARE) :
        NamedTuple{tuple(keys(decl.ins)...)}(tuple((input_addr(ci, face) for face in keys(decl.ins))...))

    # A cell holds what the build probe populated until a sweep first writes it
    # (§10.5): this is the table's pre-`init!` content, and a frozen
    # component's pinned cells are this seed for the whole run (§9.4). It is
    # also what leaves no handle cell unassigned: an opaque-leaf buffer starts
    # `undef`, every handle port is a component product this seed writes, and a
    # handle at a root input is refused at layout (D-237).
    for (ci, entry) in enumerate(components)
        isempty(act.products[ci]) ||
            scatter_group!(store, addr_group(entry.path, keys(act.products[ci])),
                           act.products[ci], T, entry.path, :probe)
    end
    # Root inputs hold their synthesized values until a writer replaces them.
    for (face, v) in layout.root_inputs
        scatter_cell!(store, layout.addr[("", face)], v)
    end

    frozen(ci) = _frozen(components[ci].tier, T)
    gate(ci) = components[ci].tier === DISCRETE ? (D_c[ci], Φ_c[ci]) : nothing

    stage1_entries, stage2_entries, rhs_entries, tick_entries = Any[], Any[], Any[], Any[]
    stage1_gates, stage2_gates, rhs_gates, tick_gates = Any[], Any[], Any[], Any[]

    for (ci, entry) in enumerate(components)
        comp, path = entry.instance, entry.path
        (has_stage(y_state, comp) && !frozen(ci)) || continue
        decl = decls[ci]
        bundle_fields = bundle_names(y_state, comp, entry.tier, ())
        push!(stage1_entries, StageEntry{typeof(decl.x),bundle_fields}(
            y_state, comp, NamedTuple(), NamedTuple(),
            entry_addrs(path, outputs.components[ci].stage1),
            x_offs[ci], clock, sstores[ci], mstores[ci], workspaces[ci], Δt_c[ci],
            path, ci, cursor))
        push!(stage1_gates, gate(ci))
    end

    for ci in outputs.order
        entry = components[ci]
        comp, path, decl = entry.instance, entry.path, decls[ci]
        (has_stage(y_direct, comp) && !frozen(ci)) || continue
        stage1_names = outputs.components[ci].stage1
        bundle_fields = bundle_names(y_direct, comp, entry.tier, tuple(stage1_names...))
        push!(stage2_entries, StageEntry{typeof(decl.x),bundle_fields}(
            y_direct, comp, in_group(ci, decl), entry_addrs(path, stage1_names),
            entry_addrs(path, outputs.components[ci].stage2), x_offs[ci], clock,
            sstores[ci], mstores[ci], workspaces[ci], Δt_c[ci], path, ci, cursor))
        push!(stage2_gates, gate(ci))
    end

    # The update law, one block per tier: `x_deriv` into the flat
    # derivative buffer, `s_update` into the component's own store. Both
    # read the complete fresh table.
    for (ci, entry) in enumerate(components)
        comp, path, decl, tier = entry.instance, entry.path, decls[ci], entry.tier
        (state_decls(decl, tier) === nothing || frozen(ci)) && continue
        update = update_of(tier)
        bundle_fields = bundle_names(update, comp, tier, tuple(outputs.components[ci].stage1...))
        output_addrs, input_addrs =
            entry_addrs(path, _ports(outputs.components[ci])), in_group(ci, decl)
        if tier === CONTINUOUS
            push!(rhs_entries, RHSEntry{typeof(decl.x),bundle_fields}(
                comp, input_addrs, output_addrs, x_offs[ci], clock, mstores[ci], workspaces[ci],
                path, ci, cursor))
            push!(rhs_gates, nothing)
        else
            push!(tick_entries, UpdateEntry{bundle_fields}(
                comp, input_addrs, output_addrs, clock, sstores[ci], workspaces[ci], Δt_c[ci],
                path, ci, cursor))
            push!(tick_gates, gate(ci))
        end
    end

    # The event system compiles at the nominal activation only: guards and
    # handlers are outside every other activation's executable set (§9.4,
    # D-052), so the event phase there is the bare sweep. Entries carry a global
    # index into the register vectors, in executor component order then
    # declaration order within a component (§10.6), and each carries the policy
    # its component's `Events` row fixes into the compiled mask — which is what
    # the frame loop's trigger check reads (§10.4).
    event_entries, event_owner = Any[], Int[]
    event_names = Tuple{String,Symbol}[]
    event_localized = Bool[]
    if T === Float64
        for (ci, entry) in enumerate(components)
            comp, path = entry.instance, entry.path
            row = build.events.components[ci]
            policies, bundle_fields = row.policies, row.bundle
            isempty(policies) && continue
            decl = decls[ci]
            # The names, the policies and the bundle are the product's; the guard
            # and handler are functions, which no product carries.
            declared_events = at_component(() -> invoke_declaration(state_events, comp), path)
            projection = has_stage(x_projection, comp) ? x_projection : nothing
            for name in keys(policies)
                push!(event_entries, EventEntry{typeof(decl.x),bundle_fields}(
                    declared_events[name].guard, declared_events[name].handler, projection, comp,
                    length(event_entries) + 1,
                    in_group(ci, decl), entry_addrs(path, _ports(outputs.components[ci])),
                    x_offs[ci], clock, mstores[ci], workspaces[ci], path, name, ci, cursor))
                push!(event_owner, ci)
                push!(event_names, (path, name))
                push!(event_localized, policies[name] === :localized)
            end
        end
    end

    # Projection runs at every activation — it is continuous machinery, inside
    # every executable set — between the integrate's state write and its decode
    # (§5.3).
    projection_entries = Any[ProjectEntry{typeof(decls[ci].x)}(entry.instance, x_offs[ci], clock,
                                                               entry.path, ci, cursor)
                             for (ci, entry) in enumerate(components)
                             if entry.tier === CONTINUOUS &&
                                has_stage(x_projection, entry.instance)]

    body(entries, gates) = chunked_body(entries, gates, store, xbuf, ẋbuf; chunk_size)
    # Beside the four blocks ride the per-event and per-projection callables,
    # keyed by the roster (§9.7): (path, event name) and path.
    event_bodies = Dict{Tuple{String,Symbol},NamedTuple}(
        event_names[i] => _event_bodies(event_entries[i], store, xbuf)
        for i in eachindex(event_entries))
    projection_bodies = Dict{String,Function}(
        projection_entry.path => _project_body(projection_entry, xbuf)
        for projection_entry in projection_entries)
    bodies = (sweep_1 = body(stage1_entries, stage1_gates),
              sweep_2 = body(stage2_entries, stage2_gates),
              rhs = body(rhs_entries, rhs_gates),
              ticks = body(tick_entries, tick_gates),
              events = event_bodies, projections = projection_bodies)

    event_set = EventSet(event_entries, projection_entries, event_owner, event_names,
                         event_localized, length(components); chunk_size)
    # The seam's backend and the arrival pair are this buffer set's, so they are
    # built here rather than by the caller (§12.6, D-256).
    Executor(act, store, xbuf, ẋbuf, sstores, mstores, clock, bodies, event_set, cursor,
             chunk_size, algorithm(T, n_x), zeros(T, n_x), zeros(T, n_x),
             any(event_localized))
end

# A probed input value: the producer's product, or the synthesized value of the
# root input the obligation chain ends at. Stage-2 probing runs in topological
# order, so upstream products exist by construction.
#
# The entry is a *bound*, read permissively (D-167): an unpinned entry is tolerant
# of both lawful arrivals, a `Pinned` entry demands a frozen one. The value
# passed on is the producer's, unembedded — the consumer gathers the producer's
# cell at runtime, so the cell's type is what its bundle carries.
#
# Both wire clauses were decided in the structure step (D-236). The products
# `_embed_ports` hands down carry exactly the producer's declared type at `T`,
# and a root input's cell is admitted by every entry by the meet, so a refusal
# here is a framework bug rather than a model error — hence the fence, not a
# diagnostic.
function _probe_input(structure::Structure, layout::Layout, products, ci, face, entry_type,
                      ::Type{T}) where {T}
    entry = structure.components[ci]
    path = entry.path
    (producer_path, producer_port) = terminal_producer(structure, (path, face))
    value = if isempty(producer_path)
        last(layout.root_inputs[findfirst(r -> first(r) === producer_port, layout.root_inputs)])
    else
        products[index_of(structure, producer_path)][producer_port]
    end
    _accepts_wire(entry_type, typeof(value), T) ||
        throw(InternalInvariant("probe input $(_at_port(path, face)): $(typeof(value)) at an entry " *
                                "declaring $entry_type, which the structure step admitted"))
    value
end

# §7.1: `Ẋ` has exactly `X`'s shape at the activation scalar. Checked
# structurally here so the runtime `flatten!` into the derivative block is safe.
function _check_derivative(path, ẋ, x, ::Type{T}) where {T}
    # The declared shape picks the law: a bare state's derivative is one value.
    x isa NamedTuple ||
        return _accepts(typeof(x), typeof(ẋ), T) ? Diagnostic[] :
               Diagnostic[ConformanceFailure(path = path, what = "x_deriv",
                                             reason = :field_type, shape = :x_init, field = BARE,
                                             observed = typeof(ẋ), declared = typeof(x),
                                             activation = T)]
    ẋ isa NamedTuple ||
        return Diagnostic[ConformanceFailure(path = path, what = "x_deriv",
                                             reason = :return_type,
                                             shape = :x_init, observed = typeof(ẋ))]
    Set(keys(ẋ)) == Set(keys(x)) ||
        return Diagnostic[ConformanceFailure(path = path, what = "x_deriv",
                                             reason = :field_set,
                                             shape = :x_init,
                                             observed_fields = collect(keys(ẋ)),
                                             declared_fields = collect(keys(x)))]
    diags = Diagnostic[]
    for field in keys(x)
        _accepts(typeof(x[field]), typeof(ẋ[field]), T) ||
            push!(diags, ConformanceFailure(path = path, what = "x_deriv",
                                           reason = :field_type,
                                           shape = :x_init, field = field,
                                           observed = typeof(ẋ[field]),
                                           declared = typeof(x[field]),
                                           activation = T))
    end
    diags
end

# §7.3, §9.5: a discrete store is overwritten wholesale with what `s_update`
# returns, so the successor must be the store's own type exactly. The discrete
# world is pinned — no walk, no embedding — which makes the store assignment
# type-stable and the ban on arithmetic over stores enforceable by construction.
function _check_update(path, s⁺, s)
    s isa NamedTuple ||
        return typeof(s⁺) === typeof(s) ? Diagnostic[] :
               Diagnostic[ConformanceFailure(path = path, what = "s_update",
                                             reason = :field_type, shape = :s_init, field = BARE,
                                             observed = typeof(s⁺), declared = typeof(s))]
    s⁺ isa NamedTuple ||
        return Diagnostic[ConformanceFailure(path = path, what = "s_update",
                                             reason = :return_type,
                                             shape = :s_init, observed = typeof(s⁺))]
    typeof(s⁺) === typeof(s) ||
        return Diagnostic[ConformanceFailure(path = path, what = "s_update",
                                             reason = :field_set,
                                             shape = :s_init, observed = typeof(s⁺),
                                             declared = typeof(s))]
    Diagnostic[]
end

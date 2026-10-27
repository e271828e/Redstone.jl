# The linearization service (§14.10): the tap set the author declares, the
# seeded pass over it, and the value it comes back as.
#
# Everything the pass needs already exists. The addressing is the read side's:
# a resolved tap is a compiled read entry (readers.jl), and a `StateRead`'s
# `xbuf` offset or a `CellRead`'s cell address is a write site as much as a
# read site, so the seeds go where the reads come from (D-272). The world is
# trim's: D-213's two-half scratch set, a nominal half that holds the frozen
# discrete cells and a seeded half at the service's own `Dual` scalar
# (trim.jl). What this file adds is the tap resolution with its five refusals,
# the passes of `width` directions, and the split of values from partials.
# Nothing here writes the model: both executors are locals and die with the
# call, which is what makes linearization a pure query.
#
# The service takes the `Model{Float64}` that holds the operating point
# (D-319). The simulation's method is sim.jl's: it gates on the lifecycle and
# takes its default point from `checkpoint(sim)`.

# --- the tap set (§14.10) ------------------------------------------------------

# Design: §14.4, §14.10, Appendix B, D-272.
"""
    Taps

The tap set: the three read sets that linearization seeds and reads.

[`taps`](@ref) returns it, [`linearize`](@ref) takes it, and [`at`](@ref)
mounts it below a prefix. A tap set (the three selector lists that declare what
linearization seeds and reads) holds the three lists given as `x`, `u` and `y`,
each a [`Reads`](@ref). The `x` list names the continuous state leaves to seed,
the `u` list the root inputs to seed, and the `y` list the outputs to read.
Their labels become the axes of the matrices `linearize` returns.
"""
struct Taps{X<:Reads,U<:Reads,Y<:Reads}
    x::X
    u::U
    y::Y
end

# Design: §14.10, D-272.
# Membership is checked at resolution, in the collecting form; here each list
# is checked to be a NamedTuple of selectors, as `reads` checks its own.
"""
    taps(; x = (;), u = (;), y = (;)) -> Taps

Return the tap set a linearization seeds and reads, built from three labeled
selector lists.

A tap set (the three selector lists that declare what linearization seeds and
reads) is what [`linearize`](@ref) takes. Each list is a `NamedTuple` of
selectors (deferred reads of one leaf each), and its labels become the axes of
the returned matrices. Membership is closed per list, and every tap names one
scalar leaf.

# Keywords

- `x`: the continuous state leaves to seed, as [`get_state`](@ref) selectors.
- `u`: the root inputs (the root component's own input faces) to seed, as
  [`get_input`](@ref) selectors.
- `y`: the outputs to read, as [`get_output`](@ref) or [`get_face`](@ref)
  selectors.

`taps` checks only that each list is a `NamedTuple` of selectors, and refuses
anything else as `ReadSetMisuse`. `linearize` checks membership and the rest
when it resolves the taps against its build, and refuses them as
`TapResolution`, beside the selectors' own `ReadResolution` failures.
"""
taps(; x = (;), u = (;), y = (;)) = Taps(_tap_list(:x, x), _tap_list(:u, u), _tap_list(:y, y))

# Design: §14.10, D-277, D-278.
"""
    at(prefix::AbstractString, tap_set::Taps) -> Taps

Scope a tap set under `prefix`, so that its paths resolve below that path.

A tap set (the three selector lists that declare what linearization seeds and
reads) is built by [`taps`](@ref). Each of its lists takes `prefix` at the front
of its mount chain, the prefixes it is mounted under, and the labels are
unchanged. An empty prefix is refused as `ReadSetMisuse`, from `at` on the
lists.
"""
at(prefix::AbstractString, tap_set::Taps) =
    Taps(at(prefix, tap_set.x), at(prefix, tap_set.u), at(prefix, tap_set.y))

_tap_list(::Symbol, selectors::NamedTuple) = _reads(selectors)
_tap_list(list::Symbol, other) = throw(DiagnosticError(
    ReadSetMisuse(observed = typeof(other), reason = :not_a_tap_list, label = list)))

# --- the scalar, the width, the return (§14.10, D-272) --------------------------

"""
The service's own seeding tag (§9.4): what keeps a linearization activation
distinguishable from trim's (`TrimTag`), the probe's (`ProbeTag`) and a user's
own.
"""
struct LinearizeTag end

"The default number of seeded directions per pass (§14.10, D-272)."
const LINEARIZE_WIDTH = 8

"""The default width's scalar, pre-materializable: `build(m; activations = (Float64, LinearizeDual))` (§14.10, D-272)."""
const LinearizeDual = ForwardDiff.Dual{LinearizeTag,Float64,LINEARIZE_WIDTH}

# Design: §14.10, D-272.
"""
    Linearization

The result of a linearization: the operating point and the four Jacobians,
labeled by the taps.

[`linearize`](@ref) returns it. The labels are those of the tap set (the three
selector lists that declare what linearization seeds and reads), and a
`Linearization` holds these fields.

- `x₀`, `u₀`: the seeded states and root inputs (the root component's own input
  faces) at the operating point, as `NamedTuple`s under the `x` and `u` labels.
- `ẋ₀`: the state derivative at the operating point, under the `x` labels.
- `y₀`: the outputs read at the operating point, under the `y` labels.
- `A`, `B`, `C`, `D`: the Jacobians of `ẋ` and `y` with respect to `x` and
  `u`, each a `Matrix{Float64}` with its rows and columns ordered by the
  labels.
- `x_labels`, `u_labels`, `y_labels`: the three label tuples.

Every entry is exact to round-off, and none is a finite difference.
"""
struct Linearization
    ẋ₀::NamedTuple
    x₀::NamedTuple
    u₀::NamedTuple
    y₀::NamedTuple
    A::Matrix{Float64}
    B::Matrix{Float64}
    C::Matrix{Float64}
    D::Matrix{Float64}
    x_labels::Tuple{Vararg{Symbol}}
    u_labels::Tuple{Vararg{Symbol}}
    y_labels::Tuple{Vararg{Symbol}}
end

# --- the service (§14.10) -------------------------------------------------------

# Design: §9.7, §13.1, §14.6, §14.10, Appendix B, D-168, D-197, D-213, D-263,
# D-272, D-274, D-319, D-406, D-428.
# A pure query on scratch buffers. On a simulation the default operating point
# is `checkpoint(sim)`, through sim.jl's method. The nominal half is a
# `Float64` scratch executor: by default the checkpoint restored, whose held cells are the frozen
# tier's (D-274); under `about`, the condition applied and checked total over
# the root inputs (§14.6), then one establishment round (D-213). The seeded half,
# at `Dual{LinearizeTag,Float64,width}`, is a scratch executor with the
# operating point written as zero-partial constants and the frozen discrete
# cells copied from the nominal half (D-213). The seeds are one direction per
# `x` tap and per `u` tap, `x` first, each written at its resolved site, the
# state's `xbuf` slot or the root input's cell (D-272). Both executors die with
# the call, with no commit and no boundary zero. `t0` is admitted only beside
# `about`, never silently ignored (Appendix B). The query is a read, so a model
# a simulation has claimed still answers it (D-319). The tap set's refusals:
# no discrete store in `x` (D-197), no unseedable root input in `u` (D-168,
# D-263), no two seeds at one site (D-272), with the reads' own refusals beside
# them (D-406).
"""
    linearize(model::Model{Float64}, tap_set::Taps; about = nothing, t0 = nothing,
              width::Int = 8) -> Linearization

Return the linearization of the model at an operating point.

`linearize` returns the Jacobians `A`, `B`, `C` and `D` of the model about an
operating point, as a [`Linearization`](@ref). It is a pure query. It works on
scratch stores (working storage the call creates and discards) and commits
nothing. It runs no boundary zero (the initialization boundary) and never
writes the model.

By default the operating point is `checkpoint(model)`, the model's state at the
frame top its clock rests on, at that clock's time. `about`, a condition (the
datum that says "set this build to this state"), places the operating point
anywhere else, at time `t0`. The condition is applied over the declared
defaults, and one sweep with every discrete output stage run then sets the
discrete outputs.

The tap set, built by [`taps`](@ref), names the axes. It is three lists of
selectors (deferred reads, each naming one leaf), declaring what linearization
seeds and reads. `linearize` seeds one direction per `x` tap and per `u` tap,
and evaluates the model with dual numbers. The value parts give `ẋ₀` and `y₀`.
The partials give `A` and `B` read at the state derivative, and `C` and `D`
read at the `y` taps. States and root inputs (the root component's own input
faces) that no tap names sit constant at the operating point. The discrete tier
(the discrete side of the hybrid model) is held.

# Keywords

- `about`: a condition placing the operating point, or `nothing` for
  `checkpoint(model)`.
- `t0`: the time of the `about` operating point, `0.0` when `nothing`. It is
  allowed only beside `about`.
- `width`: how many directions one evaluation seeds, at least 1, by default 8.
  The width changes the grouping, never the answer. The default width's scalar
  is `LinearizeDual`, so a build that lists it in `activations` linearizes any
  tap set with no compile at the keyboard.

The default form is legal only while the model's status is `:consistent`, and is
refused as `ServiceLifecycle` otherwise. It is refused as `CheckpointMidFrame`
with the clock off a frame top, as [`checkpoint`](@ref) is. A root input whose
value does not convert to the seeded scalar is refused as `ConditionResolution`.
The `about` form is legal at any status. Under it, a condition that does not
resolve is refused with the diagnostics resolution raises: `ConditionResolution`,
`PathResolution`, `DuplicateConditionLeaf` or `ConditionNodeMisuse`. A root
input it leaves without a value is refused as `UninitializedInputs`. A model a
[`Simulation`](@ref) has claimed still answers, since the query only reads it.

The taps resolve in one collecting pass, and their faults are refused together
as `TapResolution`, beside the selectors' own `ReadResolution` failures: a
member in the wrong list, a discrete state in `x`, a tap that is not one
scalar, a root input that cannot be seeded, or a second tap on one seeded site.
A `t0` without `about`, a `width` below 1, a second argument that is not a tap
set, and a model at a scalar type other than `Float64` are refused as
`ArgumentInvalid`.
"""
function linearize(model::Model{Float64}, tap_set::Taps; about = nothing,
                   t0 = nothing, width::Int = LINEARIZE_WIDTH)
    _check_linearize_call(about, t0, width)
    # The default form inherits `checkpoint`'s precondition, gated here so the
    # refusal names `linearize` and `checkpoint` is left the mid-frame one.
    if about === nothing
        model_status = @atomic :acquire model.status
        model_status === :consistent || throw(DiagnosticError(ServiceLifecycle(
            op = :linearize, status = model_status, legal = [:consistent])))
        operating_point = checkpoint(model)
    else
        operating_point = nothing
    end
    _linearize(model, tap_set, operating_point, about, t0, width)
end

linearize(::Model, other; kw...) = throw(DiagnosticError(
    ArgumentInvalid(call = :linearize, argument = :taps, reason = :not_a_tap_set,
                    value = string(typeof(other)))))

# A model at another scalar: the operating point is a nominal world's (D-319).
linearize(::Model{T}, ::Taps; kw...) where {T} = throw(DiagnosticError(
    ArgumentInvalid(call = :linearize, reason = :non_nominal, value = "Model{$T}")))

# The two keyword refusals both methods make first (Appendix B, D-272).
function _check_linearize_call(about, t0, width::Int)
    width ≥ 1 || throw(DiagnosticError(ArgumentInvalid(
        call = :linearize, argument = :width, reason = :nonpositive_width, value = width)))
    about === nothing && t0 !== nothing && throw(DiagnosticError(ArgumentInvalid(
        call = :linearize, argument = :t0, reason = :t0_without_about)))
    nothing
end

# The query once the operating point is chosen: steps 2 to 6 above, on scratch
# models of `model`'s deployment. `operating_point` is the default form's
# state, `nothing` under `about` (D-319).
function _linearize(model::Model{Float64}, tap_set::Taps, operating_point, about, t0,
                    width::Int)
    build = model.deployment.build
    T = ForwardDiff.Dual{LinearizeTag,Float64,width}
    (x_entries, u_entries, y_entries) = _resolve_taps(tap_set, build, T)

    # --- the nominal half (D-213) ------------------------------------------------
    nominal_exec = _scratch(model, Float64).exec
    if about === nothing
        _restore_state!(nominal_exec, operating_point)   # the held cells are the frozen tier's (D-274)
    else
        t = Float64(something(t0, 0.0))
        _set_clock!(nominal_exec, t, t)
        plan = resolve_condition(about, build, Float64)
        assert_total(plan, build.structure, :linearize)   # (§14.6): before any evaluation
        apply!(nominal_exec, plan)
        _round!(nominal_exec, ESTABLISH)             # every discrete output stage, due or not
    end

    # --- the seeded half ---------------------------------------------------------
    act = activation(build, T)
    seeded_exec = _scratch(model, T).exec
    if about === nothing
        copyto!(seeded_exec.xbuf, operating_point.x)   # zero partials throughout
        _restore_stores!(seeded_exec, operating_point)
        # each root input converted to its seeded cell's type, as an authored
        # value is at resolution (conditions.jl); a type that does not convert
        # takes the condition path's refusal, every root input in one throw
        # (D-428)
        diags = Diagnostic[]
        for face in build.structure.root_inputs
            addr = act.layout.addr[("", face)]
            value = gather_cell(nominal_exec.store, nominal_exec.act.layout.addr[("", face)])
            (ok, converted) = _convert(_port_type(addr), value)
            ok || (push!(diags, ConditionResolution(; field = face, face = face,
                       reason = :unconvertible, origin = CHECKPOINT_ORIGIN, declared = _port_type(addr),
                       observed = typeof(value), value = value)); continue)
            scatter_cell!(seeded_exec.store, addr, converted)
        end
        _report_violations(diags)
        _set_clock!(seeded_exec, operating_point.t, operating_point.t₀)
    else
        _set_clock!(seeded_exec, t, t)
        apply!(seeded_exec, resolve_condition(about, build, T))
    end
    _establish_frozen!(seeded_exec, act, nominal_exec, build)

    # --- the passes --------------------------------------------------------------
    n_x, n_u, n_y = length(x_entries), length(u_entries), length(y_entries)
    N = n_x + n_u
    sites = Any[first.(x_entries); u_entries]
    site_values = Float64[_site_value(seeded_exec, site) for site in sites]
    ẋ₀, y₀ = Vector{Any}(undef, n_x), Vector{Any}(undef, n_y)
    A, B = zeros(n_x, n_x), zeros(n_x, n_u)
    C, D = zeros(n_y, n_x), zeros(n_y, n_u)
    for group in (N == 0 ? (1:0,) : Iterators.partition(1:N, width))
        for (k, site) in enumerate(sites)
            pos = k in group ? k - first(group) + 1 : 0
            _seed_site!(seeded_exec, site, _seed(T, site_values[k], pos))
        end
        evaluate!(seeded_exec)
        for (i, (_, entry)) in enumerate(x_entries)
            ẋ₀[i] = _readback!(A, B, i, _read(entry, seeded_exec), group, n_x)
        end
        for (i, entry) in enumerate(y_entries)
            y₀[i] = _readback!(C, D, i, _read(entry, seeded_exec), group, n_x)
        end
    end

    x_labels, u_labels, y_labels =
        keys(tap_set.x.selectors), keys(tap_set.u.selectors), keys(tap_set.y.selectors)
    Linearization(NamedTuple{x_labels}(Tuple(ẋ₀)),
                  NamedTuple{x_labels}(Tuple(site_values[1:n_x])),
                  NamedTuple{u_labels}(Tuple(site_values[n_x+1:N])),
                  NamedTuple{y_labels}(Tuple(y₀)),
                  A, B, C, D, x_labels, u_labels, y_labels)
end

# --- the pieces the service is built out of --------------------------------------

# The scratch clock at the operating point: `t` in the executor's scalar, the
# origin a `Float64` as everywhere (§12.6).
function _set_clock!(exec::Executor{T}, t::Float64, t₀::Float64) where {T}
    exec.clock.t = T(t)
    exec.clock.t₀ = t₀
    nothing
end

# What each list admits (§14.10, D-272).
_tap_kind(::Val{:x}) = GetState
_tap_kind(::Val{:u}) = GetInput
_tap_kind(::Val{:y}) = Union{GetOutput,GetFace}

# Which of `x`/`u`/`y` a selector addresses, by its kind (§14.10).
_tap(::Union{GetState,GetDeriv}) = :x
_tap(::Union{GetOutput,GetFace}) = :y
_tap(::GetInput) = :u

# One `TapResolution` off a tap, for the tap set's own reasons: the read as
# authored, as readers.jl's `_reader_violation` spells it, and the tap set. A
# refusal the read's own resolution raised stays its `ReadResolution`.
_tap_violation(read::MountedRead, reason::Symbol; kw...) =
    _tap_violation(read.label, read.authored, read.mount, reason;
                   field = something(read.face, read.head), kw...)

# The kind check's form, before the selector is rebased.
_tap_violation(label::Symbol, authored, mount::String, reason::Symbol; kw...) =
    TapResolution(; label = label, selector = _spell(authored), reason = reason,
                  mount = mount, tap = _tap(authored),
                  path = _mounted_path(mount, _selpath(authored)),
                  leaf = _leaf_string(authored), kw...)

"""
    _resolve_taps(tap_set, build, T) → (x_entries, u_entries, y_entries)

Resolve the three lists in §13.1's collecting form, one `DiagnosticError` with
every violation. The checks run at the nominal activation, so every payload
carries nominal types; the entries returned are the seeded activation's. An `x`
entry is its `xbuf` site paired with the `DerivRead` its row is read through,
a `u` entry the root input's `CellRead`, a `y` entry its cell's. A second `x`
or `u` tap at a site already seeded is refused naming the earlier label, since
its seed would overwrite the first; `y` taps are reads and may repeat.

Each list is mounted (§14.9, D-277). The kind check reads the selector as
authored and runs before the rebase, and everything after it reads the rebased
selector: a `get_face` in the `y` list is admitted, and seeded, as the
`get_output` of its producer. A mount chain that fails is reported once, for
every list that carries it.
"""
function _resolve_taps(tap_set::Taps, build::Build, ::Type{T}) where {T}
    nominal_act, act = activation(build, Float64), activation(build, T)
    diags = Diagnostic[]
    seeded_by = Dict{Any,Symbol}()       # seed site => the label that seeds it
    failed_prefixes = Set{Tuple{Vararg{String}}}()
    entries = map((:x, :u, :y)) do list
        resolved = Any[]
        read_set = getfield(tap_set, list)
        read_set.prefixes in failed_prefixes && return resolved
        mount_point = _mount(read_set, build, diags)
        mount_point === nothing && (push!(failed_prefixes, read_set.prefixes); return resolved)
        for (label, authored) in pairs(read_set.selectors)
            if !(authored isa _tap_kind(Val(list)))
                push!(diags, _tap_violation(label, authored, first(mount_point), :tap_kind;
                                            list = list))
                continue
            end
            read = _rebase(authored, label, mount_point..., build, diags)
            read === nothing && continue
            nominal_entry = _resolve_selector(read.selector, read, build, nominal_act, diags)
            nominal_entry === nothing && continue
            entry = _seeded_tap(Val(list), nominal_entry, read.selector, read, build, act, diags)
            entry === nothing && continue
            site = _site_key(Val(list), entry)
            if site !== nothing && haskey(seeded_by, site)
                push!(diags, _tap_violation(read, :duplicate_site;
                                            duplicate_of = seeded_by[site]))
                continue
            end
            site === nothing || (seeded_by[site] = read.label)
            push!(resolved, entry)
        end
        resolved
    end
    isempty(diags) || throw(DiagnosticError(diags))
    entries
end

# A seed site's identity (D-272): an `x` entry's `xbuf` slot, a `u` entry's cell
# and the linear place its index step names, 0 for the whole cell, so `[3]` and
# `[1,2]` on one matrix are one site. A `y` entry is a read, not a seed, and has none.
_site_key(::Val{:x}, entry::Tuple{Int,DerivRead}) = first(entry)
_site_key(::Val{:u}, entry::CellRead{A,C}) where {A,C} =
    (entry.addr, isempty(C) ? 0 : _linear_index(_port_type(entry.addr), only(C)))
_site_key(::Val{:y}, ::CellRead) = nothing

# A seed is a `Float64` direction written into a whole cell or one `SArray`
# component, so a seeded tap reaches its scalar through one index step at most
# and never a `.name` step: there is no lens into a struct's slots (D-036,
# D-276). A non-`Real` leaf is the vector tap, checked before the leaf's type
# so that an unindexed `SVector` reads as one.
function _check_seedable(read::MountedRead, ::Type{P}, chain::Tuple, leaf_type::Type,
                         diags::Vector{Diagnostic}) where {P}
    offending = findfirst(k -> chain[k] isa Symbol || k > 1, eachindex(chain))
    offending === nothing ||
        return (push!(diags, _tap_violation(read, :unseedable; declared = P,
                                            step = _step_string(chain[offending]))); false)
    leaf_type <: Real ||
        return (push!(diags, _tap_violation(read, :vector_tap; declared = leaf_type)); false)
    leaf_type === Float64 ||
        return (push!(diags, _tap_violation(read, :unseedable; declared = leaf_type)); false)
    true
end

# The linear position of an index step in an `SArray` of type `P`: `[k]` is
# itself, `[k,l]` its column-major place (§14.4).
_linear_index(::Type{P}, index::Tuple{Vararg{Int}}) where {P} = LinearIndices(size(P))[index...]

# The `x` list: a discrete store is refused with its tier in hand (D-197).
_seeded_tap(::Val{:x}, ::StoreRead, ::GetState, read::MountedRead, ::Build, ::Activation,
            diags::Vector{Diagnostic}) =
    (push!(diags, _tap_violation(read, :discrete_state)); nothing)

# The `x` list's continuous leaf: the offset is `T`-independent (§9.2), so the
# seeded entries are the nominal one retyped. The seed site is the leaf's slot
# in `xbuf`, the field's offset plus the index step's linear position.
function _seeded_tap(::Val{:x}, entry::StateRead{P,C}, ::GetState, read::MountedRead,
                     ::Build, ::Activation{T}, diags::Vector{Diagnostic}) where {P,C,T}
    _check_seedable(read, P, C, _resolved_type(P, C), diags) || return nothing
    linear = isempty(C) ? 1 : _linear_index(P, only(C))
    (entry.offset + linear, DerivRead{retype(T, P),C}(entry.offset))
end

# The `u` list: the root input's cell follows the seeded scalar only when every
# consumer tolerates it, D-168's meet. A consumer whose entry refuses the walked
# type is a pinning consumer, named with its tier and its declared entry: a
# continuous one pins by declaration (D-167), a discrete one by tier (§8.2). The
# face is the root input the mount step landed on, so the meet is right at a
# mount (D-277).
function _seeded_tap(::Val{:u}, entry::CellRead{A,C}, ::GetInput, read::MountedRead,
                     build::Build, act::Activation{T}, diags::Vector{Diagnostic}) where {A,C,T}
    structure = build.structure
    face = read.head
    P = _port_type(entry.addr)
    _check_seedable(read, P, C, _resolved_type(P, C), diags) || return nothing
    root_type = structure.root_types[findfirst(==(face), structure.root_inputs)]
    walked_type = retype(T, root_type)
    pinning = Tuple{String,Symbol,Any}[
        (consumer.path, Symbol(tier_word(consumer.tier)),
         invoke_declaration(u_types, consumer.instance)[consumer_face])
        for (ci, consumer) in enumerate(structure.components)
        for consumer_face in keys(act.decls[ci].ins)
        if terminal_producer(structure, (consumer.path, consumer_face)) == ("", face) &&
           !_accepts_wire(act.decls[ci].ins[consumer_face], walked_type, T)]
    addr = act.layout.addr[("", face)]
    # The seeded cell's type is the meet's own witness.
    isempty(pinning) == (_port_type(addr) === walked_type) || throw(InternalInvariant(
        "root input `$face`: the meet names $(length(pinning)) pinning consumer(s) and the " *
        "seeded cell is $(_port_type(addr)), against the walked $walked_type"))
    # The refusal names the root input the pinning consumers read, not the face
    # the read was authored against.
    isempty(pinning) ||
        return (push!(diags, _tap_violation(read, :unseedable; field = read.head,
                                            declared = root_type, pinning = pinning));
                nothing)
    CellRead{typeof(addr),C}(addr)
end

# The `y` list: any `Real` leaf is readable, `Float64` or not, since a row is a
# read and not a seed. A `get_face` arrives rebased to its producer's port.
function _seeded_tap(::Val{:y}, entry::CellRead{A,C}, selector::GetOutput, read::MountedRead,
                     ::Build, act::Activation, diags::Vector{Diagnostic}) where {A,C}
    leaf_type = _resolved_type(_port_type(entry.addr), C)
    leaf_type <: Real ||
        return (push!(diags, _tap_violation(read, :vector_tap; declared = leaf_type));
                nothing)
    addr = act.layout.addr[(selector.path, read.head)]
    CellRead{typeof(addr),C}(addr)
end

# The value at a seed site before any seed is written.
_site_value(exec::Executor, site::Int) = ForwardDiff.value(exec.xbuf[site])
_site_value(exec::Executor, site::CellRead) = ForwardDiff.value(_read(site, exec))

# One seed: the site's value with the unit partial in slot `pos`, or all-zero
# partials when `pos` is zero and the site is outside the pass's group.
_seed(::Type{ForwardDiff.Dual{TG,Float64,W}}, site_value::Float64, pos::Int) where {TG,W} =
    ForwardDiff.Dual{TG}(site_value, ntuple(j -> Float64(j == pos), Val(W))...)

_seed_site!(exec::Executor, site::Int, seed) = (exec.xbuf[site] = seed; nothing)
_seed_site!(exec::Executor, site::CellRead{A,()}, seed) where {A} =
    scatter_cell!(exec.store, site.addr, seed)
# A one-step index chain, the only other a seeded tap resolves to: one component.
function _seed_site!(exec::Executor, site::CellRead{A,C}, seed) where {A,C}
    cell = gather_cell(exec.store, site.addr)
    scatter_cell!(exec.store, site.addr,
                  Base.setindex(cell, seed, _linear_index(typeof(cell), only(C))))
end

# One row of a matrix pair out of one read: the group's partials into the `x`
# matrix's or the `u` matrix's column, the value returned. A frozen `Float64`
# read carries no partials, and its row is zero.
function _readback!(state_matrix::Matrix{Float64}, input_matrix::Matrix{Float64}, i::Int,
                    reading, group, n_x::Int)
    for (pos, k) in enumerate(group)
        partial = reading isa ForwardDiff.Dual ? ForwardDiff.partials(reading, pos) : 0.0
        k ≤ n_x ? (state_matrix[i, k] = partial) : (input_matrix[i, k - n_x] = partial)
    end
    ForwardDiff.value(reading)
end

# Deployment binding (§9.1, §9.2, D-254): the artifact the grid parameters fix,
# standing between the `Build` and the `Model`. Everything here post-dates
# the build's three steps and precedes materialization: it exists per
# `Deployment`, not per `Build` and not per scalar type. Grid arithmetic is
# exact — GCD over `Rational{Int}` — and floats are refused at the door.
#
# The file sits after `build.jl` and `readers.jl` because the binding consumes the
# `Build`, and before `checkpoint.jl` because `ModelState.deployment` is a typed field.
# The algorithm tokens live here, since the `Deployment` holds one in a typed
# field; the steppers they bind to, and `bind_stepper`, are `stepper.jl`'s.

# Records and returns `nothing` on its two refusing arms; the call's list carries it.
_exact(name::Symbol, value::Rational{Int}, diags::Vector{Diagnostic}) = value
_exact(name::Symbol, value::Integer, diags::Vector{Diagnostic}) = Rational{Int}(value)
_exact(name::Symbol, value::Period, diags::Vector{Diagnostic}) = value.T
_exact(name::Symbol, value::AbstractFloat, diags::Vector{Diagnostic}) =
    (push!(diags, DeploymentInvalid(parameter = name, reason = :inexact, value = value));
     nothing)
_exact(name::Symbol, value, diags::Vector{Diagnostic}) =
    (push!(diags, DeploymentInvalid(parameter = name, reason = :not_a_quantity,
                                    value = typeof(value))); nothing)

_as_int(value::Rational) = denominator(value) == 1 ? Int(numerator(value)) : nothing

# --- the grid attribution (§9.2, D-187) -----------------------------------------

# Trial division: the integers factored here are grid denominators, lcms of a
# handful of declared ones, so no prime table is worth a dependency.
function _prime_powers(integer::Int)
    powers = Tuple{Int,Int}[]
    cofactor, divisor = integer, 2
    while divisor * divisor ≤ cofactor
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

"""
The grid attribution D-187 asks for (§9.2), a pure function of the structure's
anchors: the constraint pool — every anchor's period and every nonzero offset,
in anchor order, periods first — with each entry's leave-one-out refinement
factor `r_p = gcd(pool ∖ p)/gcd(pool)`, the prime attribution of `gcd(pool)`'s
denominator, and, for a driving offset, the nearest offsets the rest of the pool
already supports. One report per constructor call, computed ahead of the
`Δt_base` branch: the refusal path's suggestion, the derivation path's line and
the `Deployment` itself read the same substrate.
"""
function _grid_report(anchors::Vector{Anchor})
    entry_kinds, entry_values, anchor_indices = Symbol[], Rational{Int}[], Int[]
    for (k, anchor) in enumerate(anchors)
        push!(entry_kinds, :period); push!(entry_values, anchor.T); push!(anchor_indices, k)
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
            # fold requires 0 ≤ τ < T (`assembly.jl`), so an upper neighbour reaching
            # the anchor's period is no offset; 0 stays, declaring none being a repair.
            τ, T = entry_values[i], anchors[anchor_indices[i]].T
            lower = floor(Int, τ / partial) * partial
            push!(alternatives, lower)
            lower + partial < T && push!(alternatives, lower + partial)
        end
        anchor = anchors[anchor_indices[i]]
        push!(pool, GridEntry(entry_kinds[i], entry_values[i], anchor.scope, anchor.key,
                              factor, alternatives))
    end
    primes = [(prime = prime, power = power,
               suppliers = [i for i in eachindex(entry_values)
                            if denominator(entry_values[i]) % prime^power == 0])
              for (prime, power) in _prime_powers(denominator(admissible))]
    GridReport(pool, admissible, primes)
end

# --- the typed schedule (§9.2, §10.5, D-254) ------------------------------------

"""
One discrete component's row of the schedule (§9.2): its `(D, Φ, Δt)` with the
anchor it resolved against (0 is the base grid `A₀`) and its `rates`, the
`sample_times` links met on the way down.
"""
struct ScheduleEntry
    path::String
    anchor::Int
    D::Int
    Φ::Int
    Δt::Float64
    rates::Vector{RateLink}
end

# `rates` is a vector, so the `===` fallback would make two rows of two
# builds of one model unequal. Value equality is what §12.7's header check
# needs, so both are spelled field-wise here (`hash` alongside, consistently).
Base.:(==)(a::ScheduleEntry, b::ScheduleEntry) =
    a.path == b.path && a.anchor == b.anchor && a.D == b.D && a.Φ == b.Φ &&
    a.Δt == b.Δt && a.rates == b.rates
Base.hash(entry::ScheduleEntry, seed::UInt) =
    hash(entry.rates, hash(entry.Δt, hash(entry.Φ, hash(entry.D,
        hash(entry.anchor, hash(entry.path, seed))))))

"""
One rate scope's row (§9.2, §10.5): the assembly an explicit `sample_times` key
opened, resolved to its own `(Dₛ, Φₛ)` by the same multiply-add its members use.
"""
struct ScopeEntry
    path::String
    key::Symbol
    anchor::Int
    D::Int
    Φ::Int
end

# Design: §9.2, §10.5, D-254, D-261. The per-component `(D, Φ, Δt)` the
# executor compiles over are derived from the rows at `compile`, never stored
# beside them (D-261). The component rows sit in walk order.
"""
    Schedule

The deployment's [tick](@ref g-tick) table, one row per discrete
[component](@ref g-component), in the build's order, and one per
[rate scope](@ref g-rate-scope).

A component row holds the component's path, the [anchor](@ref g-anchor) it
resolved against, its tick divisor `D` and [phase](@ref g-phase) `Φ` in
[base ticks](@ref g-tick), and its period `Δt` in seconds.
[`Deployment`](@ref) builds the schedule and carries it. A run reads every `Δt`
it uses from it.
"""
struct Schedule
    rows::Vector{ScheduleEntry}
    scopes::Vector{ScopeEntry}
end

Base.:(==)(a::Schedule, b::Schedule) = a.rows == b.rows && a.scopes == b.scopes
Base.hash(schedule::Schedule, seed::UInt) = hash(schedule.scopes, hash(schedule.rows, seed))

# The per-component `(D, Φ, Δt)` the executor compiles over, derived from the
# rows by path at `compile` (§9.2, D-261); a component with no row is the
# continuous tier's `(1, 0, 0.0)`.
function _gates(schedule::Schedule, structure::Structure)
    row_by_path = Dict(row.path => row for row in schedule.rows)
    D_c, Φ_c, Δt_c = Int[], Int[], Float64[]
    for entry in structure.components
        row = get(row_by_path, entry.path, nothing)
        push!(D_c, row === nothing ? 1 : row.D)
        push!(Φ_c, row === nothing ? 0 : row.Φ)
        push!(Δt_c, row === nothing ? 0.0 : row.Δt)
    end
    D_c, Φ_c, Δt_c
end

"""
Deployment binding (§9.1): `Δt_base` from one of three cross-validated sources —
the explicit keyword, `Δt_frame` by default, or GCD derivation over the
constraint pool, requested as `Δt_base = :derive` and permitted only with every
discrete component anchored — and the method's step `h`, the token's or
`Δt_frame` when the token names none. Resolution is one exact division pair per
anchor and one multiply-add per component. Returns the bound grid: `Δt_frame`,
`Δt_base`, the frames per base tick, the algorithm with its step resolved, the
`Schedule` (§9.2's typed artifact), the grid attribution and whether the
derivation path produced the value.

The pass records into the call's list and returns `nothing` when a premise
fails; the caller owns the one throw per `Deployment` call (§9.1, D-229).
`Δt_frame`, `Δt_base` and `h` are independent premises, each checked and
recorded on its own; the lattice checks read the pairs they relate, and run
only when both of a pair are sound (D-229).
"""
function bind_schedule(build::Build, Δt_frame, Δt_base, algorithm, diags::Vector{Diagnostic})
    count_on_entry = length(diags)
    Δt_frame === nothing &&
        push!(diags, DeploymentInvalid(parameter = :Δt_frame, reason = :missing))
    Δt_frame_r = Δt_frame === nothing ? nothing : _exact(:Δt_frame, Δt_frame, diags)
    if Δt_frame_r !== nothing && !(Δt_frame_r > 0)
        push!(diags, DeploymentInvalid(parameter = :Δt_frame, reason = :range,
                                       value = Δt_frame_r))
        Δt_frame_r = nothing
    end
    # The method's step: the token's own, exact since the token normalized it, or
    # `Δt_frame` when it names none (§10.2, D-442). An unsound algorithm has none.
    h_r = algorithm === nothing ? nothing :
          algorithm.h === nothing ? Δt_frame_r : algorithm.h
    if algorithm !== nothing && algorithm.h !== nothing && !(algorithm.h > 0)
        push!(diags, DeploymentInvalid(parameter = :h, reason = :range, value = algorithm.h))
        h_r = nothing
    end

    structure = build.structure
    anchors = structure.anchors
    # The attribution over the constraint pool — every anchor's period and every
    # nonzero offset (§9.1) — computed once, ahead of the branch, and handed to
    # every refusal that names the grid as well as to the artifact (§9.2, D-187).
    grid = _grid_report(anchors)

    # The Δt_base branch is its own premise: derivation reads the tiers and the
    # anchors, the explicit keyword reads only itself, and only the default path
    # reads `Δt_frame` — which is why it alone is skipped when that is unsound.
    Δt_r, derived = nothing, false
    if Δt_base === :derive
        unanchored = [entry.path for entry in structure.components
                      if entry.tier === DISCRETE && entry.timing.anchor == 0]
        if !isempty(unanchored)
            push!(diags, DeploymentInvalid(parameter = :Δt_base, reason = :unanchored,
                                           paths = unanchored, grid = grid))
        elseif grid.admissible === nothing
            push!(diags, DeploymentInvalid(parameter = :Δt_base, reason = :no_constraint))
        else
            Δt_r, derived = grid.admissible, true    # the coarsest admissible value
        end
    elseif Δt_base !== nothing
        Δt_r = _exact(:Δt_base, Δt_base, diags)
    elseif Δt_frame_r !== nothing
        Δt_r = Δt_frame_r                                 # the default path (§9.2)
    end

    # The lattice checks and the anchor loop read `Δt_frame` and `Δt_base`
    # together, so they run only on a sound value of each (D-229).
    (Δt_frame_r !== nothing && Δt_r !== nothing) || return nothing

    # While the frame loop takes one step per frame, a base tick lands on a frame
    # top: `Δt_base` a whole multiple of `Δt_frame`, the loop's tick key.
    frames_per_tick = _as_int(Δt_r / Δt_frame_r)
    (frames_per_tick === nothing || frames_per_tick < 1) &&
        push!(diags, DeploymentInvalid(parameter = :Δt_base, reason = :not_frame_multiple,
                                       value = Δt_r, related = Δt_frame_r))
    # The fixed-step rule (§10.2, D-443): `h` divides the frame and, when discrete
    # work exists, the base tick. Then, while the loop takes one step per frame,
    # a step that divides the frame must be the frame.
    if h_r !== nothing
        has_discrete = any(entry -> entry.tier === DISCRETE, structure.components)
        for (parameter, Δt_lattice) in ((:Δt_frame, Δt_frame_r), (:Δt_base, Δt_r))
            parameter === :Δt_base && !has_discrete && continue
            steps = _as_int(Δt_lattice / h_r)
            (steps === nothing || steps < 1) &&
                push!(diags, DeploymentInvalid(parameter = parameter, reason = :not_harmonic,
                                               value = Δt_lattice, related = h_r))
        end
        h_r != Δt_frame_r && _as_int(Δt_frame_r / h_r) !== nothing &&
            push!(diags, DeploymentInvalid(parameter = :h, reason = :subcycling,
                                           value = h_r, related = Δt_frame_r))
    end
    length(diags) == count_on_entry || return nothing

    # Per anchor, one exact division pair; anchor 0 is the base grid itself. The
    # loop collects into the call's list (§13.1): every anchor the chosen base
    # grid cannot express is named, so the coarsest admissible value is chosen
    # against the whole list.
    Dk, Φk = [1], [0]
    for anchor in anchors
        D = _as_int(anchor.T / Δt_r)
        D === nothing &&
            push!(diags, DeploymentInvalid(parameter = :Δt_base, reason = :anchor_period,
                                          value = anchor.T, related = Δt_r,
                                          scope = anchor.scope, key = anchor.key, grid = grid))
        Φ = _as_int(anchor.τ / Δt_r)
        Φ === nothing &&
            push!(diags, DeploymentInvalid(parameter = :Δt_base, reason = :anchor_offset,
                                          value = anchor.τ, related = Δt_r,
                                          scope = anchor.scope, key = anchor.key, grid = grid))
        push!(Dk, something(D, 1)); push!(Φk, something(Φ, 0))
    end
    length(diags) == count_on_entry || return nothing

    # Per component, one multiply-add; the canonical residue 0 ≤ Φ < D survives
    # composition (§10.5), which is what the gate's truncated rem relies on. The
    # rate scopes resolve by the same law, off the timing the fold left them.
    Δtb = Float64(Δt_r)
    timing_gates(timing::Timing) = (timing.m * Dk[timing.anchor + 1],
                                    Φk[timing.anchor + 1] +
                                    timing.c * Dk[timing.anchor + 1])
    rows = ScheduleEntry[]
    for entry in structure.components
        entry.tier === DISCRETE || continue
        D, Φ = timing_gates(entry.timing)
        # the rates vector itself: the structure is immutable, so no copy
        push!(rows, ScheduleEntry(entry.path, entry.timing.anchor, D, Φ, D * Δtb, entry.rates))
    end
    scopes = [ScopeEntry(scope.path, scope.key, scope.timing.anchor,
                         timing_gates(scope.timing)...)
              for scope in structure.scopes]
    # The algorithm's own fault is on the caller's list, ahead of this pass.
    algorithm === nothing && return nothing
    (Δt_frame = Float64(Δt_frame_r), Δt_base = Δtb, frames_per_tick = frames_per_tick,
     algorithm = typeof(algorithm)(h_r), schedule = Schedule(rows, scopes), grid = grid,
     derived = derived)
end

# --- the integration algorithm (§10.2, D-442) -----------------------------------

# Design: §10.2, D-442. A token names the method and carries what the method
# needs that the deployment fixes, its step `h`. The stepper it binds to at
# `Model` construction owns scratch sized by the state and typed by the
# scalar, which the deployment does not know; `bind_stepper` (stepper.jl) builds
# it. A float step throws at the token, as `Period`'s does, since the
# divisibility check is exact arithmetic; a range fault is the deployment's,
# collected (D-229).
abstract type AbstractAlgorithm end

# Design: §10.2, D-442.
"""
    RK4()
    RK4(h::Union{Integer,Rational{<:Integer},Period})

The classical fourth-order Runge–Kutta method with a fixed step `h`, the default
algorithm.

Pass it as the `algorithm` keyword of [`Deployment`](@ref). `RK4()` steps by the
deployment's [frame](@ref g-frame) period `Δt_frame`. `h` is in exact seconds, a
`Rational`, an integer or a [`Period`](@ref), so `RK4(1//100)` and
`RK4(Hz(100))` are the same value. A float is refused as `ArgumentInvalid`.
The deployment refuses an `h` that is not positive or does not divide its
periods as `DeploymentInvalid`.

For the second-order method, see [`Heun`](@ref).
"""
struct RK4 <: AbstractAlgorithm
    h::Union{Nothing,Rational{Int}}
    RK4() = new(nothing)
    RK4(h::Union{Integer,Rational{<:Integer}}) = new(Rational{Int}(h))
    RK4(h::Period) = new(h.T)
    RK4(h::AbstractFloat) =
        throw(DiagnosticError(ArgumentInvalid(call = :RK4, reason = :inexact, value = h)))
end

# Design: §10.2, D-442.
"""
    Heun()
    Heun(h::Union{Integer,Rational{<:Integer},Period})

Heun's second-order method, the explicit trapezoidal rule, with a fixed step `h`.

Pass it as the `algorithm` keyword of [`Deployment`](@ref). `Heun()` steps by
the deployment's [frame](@ref g-frame) period `Δt_frame`, and `h` takes the
values [`RK4`](@ref)'s does, refused alike.
"""
struct Heun <: AbstractAlgorithm
    h::Union{Nothing,Rational{Int}}
    Heun() = new(nothing)
    Heun(h::Union{Integer,Rational{<:Integer}}) = new(Rational{Int}(h))
    Heun(h::Period) = new(h.T)
    Heun(h::AbstractFloat) =
        throw(DiagnosticError(ArgumentInvalid(call = :Heun, reason = :inexact, value = h)))
end

# The token prints as it is spelled, by its bare name, so a trace header or a
# mismatch message reads the same from any module. `==` and `hash` are the
# fallbacks': a token is an immutable value, compared field by field.
Base.show(io::IO, algorithm::Union{RK4,Heun}) =
    print(io, nameof(typeof(algorithm)), '(', something(algorithm.h, ""), ')')

# --- the artifact (§9.1, §9.2, D-254) -------------------------------------------

# Design: §9.1, §9.2, §10.2, §10.4, §10.6, §12.7, D-254, D-442, D-443.
# `Δt_base` has exactly one of three cross-validated sources (§9.1): explicit,
# `Δt_frame` by default, or GCD derivation over the anchors' constraint pool.
# `Δt_frame` is required because a domain rate is not a framework default. The
# algorithm and the three event parameters are trajectory-determining: the
# event parameters validate on their own terms, and the algorithm's step only
# against the two periods it must divide (§10.2, D-443). The defaults: a
# legitimate re-enable is
# one or two firings deep and a toggling FSM pair chatters without bound, so 4
# separates them; the event time is only as accurate as the O(h⁴) interpolant,
# so a tolerance tighter than 1e-6 buys nothing while each trial evaluation
# costs a full sweep; a multi-event frame needs three or four localizations and
# chattering needs tens, so 8. Until the frame loop subcycles (pending.md), the
# constructor also refuses a step other than the frame and a base tick off the
# frame tops, and `frames_per_tick` is the loop's tick key.
"""
    Deployment(build::Build; Δt_frame, Δt_base = nothing, algorithm = RK4(),
               firing_budget = 4, localization_tol = 1e-6,
               localization_budget = 8) -> Deployment

The build fixed to a [frame](@ref g-frame) period, a [base tick](@ref g-tick),
an integration algorithm and event parameters, with no scalar type yet.

A deployment carries the build, the grid it settled, the [`Schedule`](@ref) and
the warnings its construction raised, read with [`warnings`](@ref).
[`Model`](@ref) materializes it at a scalar type, and one deployment backs many
models.

Two deployments compare equal when their frame period, base tick, algorithm
with its step, event parameters and schedule agree, whatever their builds.
[`replay!`](@ref) checks this before re-driving a recording.

`Δt_base = :derive` derives the base tick from the discrete
[components](@ref g-component)' sample times. It is refused as
`DeploymentInvalid` unless every discrete component is [anchored](@ref g-anchor)
by an [`Absolute`](@ref) entry and the tree declares at least one. A derived
`Δt_base` finer than the fastest declared sample time warns `GridUtilization`.

A keyword outside its range is refused as `DeploymentInvalid`, and so is a
`Δt_base` that does not divide an anchor's period or offset. A fixed step `h`
must divide `Δt_frame` and, when the tree has discrete components, `Δt_base`.
For now `h` must also equal `Δt_frame`, and `Δt_base` must be a whole multiple
of `Δt_frame`. One throw reports the faults found together. Exhausting
`firing_budget` warns `FiringBudget`.

# Keywords

- `Δt_frame`: the frame period in seconds, a `Rational{Int}`, an integer, a
  `Period` or an `Hz` value, required and refused as `DeploymentInvalid` when
  absent or given as a float.
- `Δt_base`: the base tick period as a `Rational{Int}`, an integer, a `Period`
  or an `Hz` value, `Δt_frame` by default, or `:derive`.
- `algorithm`: the integration method, [`RK4`](@ref) or [`Heun`](@ref) with
  its step, bound to the state [buffer](@ref g-buffer) when the `Model` is
  built.
- `firing_budget`: how many times one event may fire at one
  [boundary](@ref g-boundary), an integer of at least 1.
- `localization_tol`: the positive relative bracket width, as a fraction of the
  step, at which event localization stops.
- `localization_budget`: how many event localizations one frame admits, an
  integer of at least 1.

See also [`build`](@ref), [`Model`](@ref), [`Simulation`](@ref).
"""
struct Deployment
    build::Build
    Δt_frame::Float64             # the frame period (§9.2, D-443)
    Δt_base::Float64
    algorithm::AbstractAlgorithm  # the method, its step resolved; bound at `Model` construction (D-442)
    firing_budget::Int            # per-event firings per boundary (§10.6)
    localization_tol::Float64     # relative bracket-width stop (§10.4)
    localization_budget::Int      # t* boundaries permitted per frame (§10.4)
    schedule::Schedule            # the bound per-component tick table (§9.2)
    grid::GridReport              # the attribution over the constraint pool (§9.2, D-187)
    frames_per_tick::Int          # Δt_base/Δt_frame, the frame loop's tick key (pending.md)
    warnings::Vector{Diagnostic}  # the warnings the constructor raised (§9.1, D-250)
end

function Deployment(build::Build; Δt_frame = nothing, Δt_base = nothing,
                    algorithm = RK4(), firing_budget = 4, localization_tol = 1e-6,
                    localization_budget = 8)
    # The event parameters and the algorithm validate on their own terms, ahead
    # of the grid; all of it lands in one list and one throw (§9.1, D-229).
    diags, raised = Diagnostic[], Diagnostic[]
    algorithm isa AbstractAlgorithm ||
        push!(diags, DeploymentInvalid(parameter = :algorithm, reason = :range, value = algorithm))
    firing_budget isa Integer && firing_budget ≥ 1 ||
        push!(diags, DeploymentInvalid(parameter = :firing_budget, reason = :range, value = firing_budget))
    localization_tol isa Real && localization_tol > 0 ||
        push!(diags, DeploymentInvalid(parameter = :localization_tol, reason = :range, value = localization_tol))
    localization_budget isa Integer && localization_budget ≥ 1 ||
        push!(diags, DeploymentInvalid(parameter = :localization_budget, reason = :range, value = localization_budget))
    bound = bind_schedule(build, Δt_frame, Δt_base,
                          algorithm isa AbstractAlgorithm ? algorithm : nothing, diags)
    # One throw per call (§9.1, D-229), carrying the warnings raised so far: the
    # artifact that would have held them never returns (D-250).
    isempty(diags) || throw(DiagnosticError(diags, raised))
    # Derivation is the one place refinement happens silently (§9.2, D-187), so it
    # always prints the derived value over the grid block, both attribution forms;
    # a pool where nothing refines says so on the first line. The line is
    # presentation, never a home (§9.1, D-250).
    if bound.derived
        grid = bound.grid
        @info "Δt_base derived as $(grid.admissible) s" *
              (all(e.factor == 1 for e in grid.pool) ? ", no entry refines another" : "") *
              " (§9.2)" * _grid_block(grid)
        # The advisory rides the same path, when the grid is finer than the fastest
        # declared work. `utilization == 1` is no information. No user body runs
        # inside this constructor, so the warning goes straight onto its own list,
        # not through `_warn!`'s channel.
        rows = bound.schedule.rows
        utilization = isempty(rows) ? 1 : minimum(row.D for row in rows)
        utilization > 1 && push!(raised,
            GridUtilization(Δt_base = grid.admissible, utilization = utilization,
                            fastest =
                                rows[findfirst(row -> row.D == utilization, rows)].path,
                            grid = grid))
    end
    deployment = Deployment(build, bound.Δt_frame, bound.Δt_base, bound.algorithm,
                            Int(firing_budget), Float64(localization_tol),
                            Int(localization_budget), bound.schedule, bound.grid,
                            bound.frames_per_tick, raised)
    # The completed constructor carries the record, and logs each warning once at
    # return through the standard backend (Appendix C's `logged`), as `build` does.
    for warning in raised
        @warn logline(warning)
    end
    deployment
end

# §12.7's header check is the consumer, and a what-if replay re-drives a
# recording against a *modified model of the same structure*, so **the build is
# not compared**: comparing it would refuse what the spec admits. `grid`,
# `frames_per_tick` and `warnings` are not compared either — all three are
# functions of the rest. The algorithm compares as a value, its step resolved,
# so `RK4()` and `RK4(Δt_frame)` deploy alike (D-442).
Base.:(==)(a::Deployment, b::Deployment) =
    a.Δt_frame == b.Δt_frame && a.Δt_base == b.Δt_base &&
    a.algorithm == b.algorithm && a.firing_budget == b.firing_budget &&
    a.localization_tol == b.localization_tol &&
    a.localization_budget == b.localization_budget && a.schedule == b.schedule
Base.hash(deployment::Deployment, seed::UInt) =
    hash(deployment.schedule, hash(deployment.localization_budget,
        hash(deployment.localization_tol, hash(deployment.firing_budget,
            hash(deployment.algorithm, hash(deployment.Δt_base,
                hash(deployment.Δt_frame, seed)))))))

# Design: §9.2, D-250. The constructor produces an artifact, so its warnings
# live on it; the log line each one got at return is presentation, never the
# home.
"""
    warnings(deployment::Deployment) -> Vector{Diagnostic}

Return the warnings the deployment's construction raised.

The constructor also logged each warning once as it returned. The list on
the deployment is where they stay, so a caller never has to capture the log.
For a build's, a model's or a simulation's list, see the other methods of
`warnings`.
"""
warnings(deployment::Deployment) = deployment.warnings

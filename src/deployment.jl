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

# Records and returns `nothing` on its three refusing arms; the call's list
# carries it. An integer or a `Rational` of any integer type is taken at its
# value, refused as `:range` where `Rational{Int}` cannot hold it.
function _exact(name::Symbol, value::Union{Integer,Rational{<:Integer}},
                diags::Vector{Diagnostic})
    exact = _exact_or_nothing(() -> Rational{Int}(value))
    exact === nothing &&
        push!(diags, DeploymentInvalid(parameter = name, reason = :range, value = value))
    exact
end
_exact(name::Symbol, value::Period, diags::Vector{Diagnostic}) = value.T
_exact(name::Symbol, value::AbstractFloat, diags::Vector{Diagnostic}) =
    (push!(diags, DeploymentInvalid(parameter = name, reason = :inexact, value = value));
     nothing)
_exact(name::Symbol, value, diags::Vector{Diagnostic}) =
    (push!(diags, DeploymentInvalid(parameter = name, reason = :not_a_quantity,
                                    value = typeof(value))); nothing)

# A whole quotient that fits `Int`, or `nothing`; a wide quotient past `Int` is
# `nothing` too, so its refusal is the caller's, never an `InexactError`.
_as_int(value::Rational) =
    denominator(value) == 1 && typemin(Int) ≤ numerator(value) ≤ typemax(Int) ?
    Int(numerator(value)) : nothing

# --- the grid attribution (§9.2, D-187) -----------------------------------------

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

# --- the lattices (§2.1, §10.5, D-445, D-449) -----------------------------------

# Design: §10.5, D-445, D-449. The frame tops and the base ticks stand in no
# required ratio, so the loop reads them as integer multiples of one exact unit,
# `gcd(Δt_frame, Δt_base)`: the nearest mandatory instant and every coincidence
# are integer comparisons, never float ones. A tree with no discrete component
# has no due instant, so `Δt_base` then constrains nothing and the unit is the
# frame. The bound `h_max` is no lattice: it stays a ratio to the unit, and a
# span's step count is one `cld`. The instants themselves are written by
# model.jl's grid, each from its own index and stride.
"""
The index-to-time map of a deployment's lattices (§2.1, §10.5, D-445, D-449):
the exact `unit`, the frame period and the base tick as whole units (`base`
is 0 when no discrete component exists), the step bound `bound` as an exact
ratio to the unit, `max_frame`, the last frame index whose positions and next
due index fit an `Int`, and `reach`, the clock bound's `2^50·δ` in seconds,
`δ` the least gap between two boundaries (D-450).
"""
struct Lattice
    unit::Rational{Int}
    frame::Int
    base::Int
    bound::Rational{Int}
    max_frame::Int
    reach::Float64
end

# The positions run on `Int`. Inside frame `k` the largest one the loop forms is a
# due index's, at most a period past the frame top, so `max_frame` bounds `k` by
# that margin. Everything is computed once, here, in `Int128`: the gcd of two
# `Int` rationals, each period in units and each product of two `Int`s fit it,
# and every factor is checked against `Int` before it multiplies. Returns
# `:Δt_base` when the unit or one frame's positions leave `Int`, and `:h_max`
# when a frame's step count, or that count times the unit's denominator, would,
# which `bind_schedule` refuses (§9.2, D-229). A span of `units` takes
# `cld(units·q, p)` steps, `bound = p/q`, so the products checked are the
# frame's `units·q` and its step count times the unit's denominator. The second
# keeps the clock's products `scale·steps` and `origin·steps` below `2^126`
# from any origin a `Rational{Int}` holds (store.jl's `_instant`). The origin's
# door checks the clock's whole formula (model.jl's `_clock_integers`, D-457),
# so this check refuses some bounds whose clocks `Int128` would carry from a
# zero origin.
function _lattice(Δt_frame::Rational{Int}, Δt_base::Rational{Int}, h_max::Rational{Int},
                  rows::Vector{ScheduleEntry})
    wide(value) = Rational{Int128}(value)
    fits(value) = value ≤ typemax(Int)
    unit = isempty(rows) ? wide(Δt_frame) : gcd(wide(Δt_frame), wide(Δt_base))
    frame = numerator(wide(Δt_frame) / unit)
    base = isempty(rows) ? Int128(0) : numerator(wide(Δt_base) / unit)
    (fits(denominator(unit)) && fits(frame) && fits(base)) || return :Δt_base
    margin = isempty(rows) ? Int128(0) : maximum(Int128(row.D) for row in rows) * base
    max_frame = fld(Int128(typemax(Int)) - margin, frame)
    max_frame ≥ 1 || return :Δt_base
    bound = wide(h_max) / unit
    (fits(numerator(bound)) && fits(denominator(bound)) &&
     fits(frame * denominator(bound))) || return :h_max
    frame_steps = cld(frame * denominator(bound), numerator(bound))
    fits(frame_steps * denominator(unit)) || return :h_max
    # The least gap between two boundaries (D-450): a unit between two mandatory
    # instants, and more than half the bound between two equal steps, since
    # `n = ⌈g / h_max⌉ ≥ 2` steps of a span `g` are each longer than `h_max / 2`.
    # A bound at the frame splits no span.
    gap = frame_steps == 1 ? unit : min(unit, wide(h_max) / 2)
    Lattice(Rational{Int}(unit), Int(frame), Int(base), Rational{Int}(bound), Int(max_frame),
            exp2(50) * Float64(gap))
end

# A period checked on its own premise (§9.2, D-229, D-445): positive and finite,
# recorded under its parameter otherwise.
function _positive_finite(parameter::Symbol, value, diags::Vector{Diagnostic})
    value === nothing && return nothing
    value > 0 && isfinite(value) && return value
    push!(diags, DeploymentInvalid(parameter = parameter, reason = :range, value = value))
    nothing
end

"""
Deployment binding (§9.1, §9.2): `Δt_frame`, `Δt_base` and the step bound
`h_max`, each a premise of its own, then the anchors against `Δt_base`, the
`Schedule` and the lattices. `Δt_base` comes from one of three
cross-validated sources, the explicit keyword, `Δt_frame` by default, or GCD
derivation over the constraint pool, requested as `Δt_base = :derive` and
permitted only with every discrete component anchored. `h_max` is resolved
to the lesser of itself and `Δt_frame`, and to `Δt_frame` when absent, since
a bound at the frame splits no span (D-449). Returns the bound grid:
`Δt_frame`, `Δt_base` and the resolved `h_max`, each exact (D-454), the
`Schedule` (§9.2's typed artifact), the `Lattice`, the grid attribution and
whether the derivation path produced the value.

Every check whose premise holds runs, and the pass records into the call's list
and returns `nothing` on any fault; the caller owns the one throw per
`Deployment` call (§9.1, D-229). Nothing relates the three quantities, and the
anchor loop reads `Δt_base` alone (D-445, D-449). The lattices come last,
every check above their premise: a unit too fine to index one frame in an
`Int` is `Δt_base`'s `:range`, `Δt_frame` its related value, and a bound
whose step counts or exact steps leave `Int` is `h_max`'s (§10.5, D-445).
"""
function bind_schedule(build::Build, Δt_frame, Δt_base, h_max, diags::Vector{Diagnostic})
    count_on_entry = length(diags)
    Δt_frame === nothing &&
        push!(diags, DeploymentInvalid(parameter = :Δt_frame, reason = :missing))
    Δt_frame_r = _positive_finite(:Δt_frame,
        Δt_frame === nothing ? nothing : _exact(:Δt_frame, Δt_frame, diags), diags)
    # The step bound, exact and positive on its own premise, then resolved
    # against the frame when both are sound (D-449).
    h_max_r = _positive_finite(:h_max,
        h_max === nothing ? nothing : _exact(:h_max, h_max, diags), diags)
    h_max === nothing && (h_max_r = Δt_frame_r)
    Δt_frame_r === nothing || h_max_r === nothing || (h_max_r = min(h_max_r, Δt_frame_r))

    structure = build.structure
    anchors = structure.anchors
    # The attribution over the constraint pool — every anchor's period and every
    # nonzero offset (§9.1) — computed once, ahead of the branch, and handed to
    # every refusal that names the grid as well as to the artifact (§9.2, D-187).
    # A report whose arithmetic leaves `Int` is `nothing`, and marks a pool no
    # deployment holds: a base tick divides the pool's gcd, so its denominator
    # is at least the gcd's, and a leave-one-out factor, or an offset's
    # neighbour, past `Int` puts some anchor's count of base ticks past it at
    # every base tick that divides the pool. `:derive` refuses it below, and
    # any other `Δt_base` meets the anchor loop's refusal.
    grid = _exact_or_nothing(() -> _grid_report(anchors))

    # The Δt_base branch is its own premise: derivation reads the tiers and the
    # anchors, the explicit keyword reads only itself, and only the default path
    # reads `Δt_frame`, which is why it alone is skipped when that is unsound.
    Δt_r, derived = nothing, false
    if Δt_base === :derive
        unanchored = [entry.path for entry in structure.components
                      if entry.tier === DISCRETE && entry.timing.anchor == 0]
        if !isempty(unanchored)
            push!(diags, DeploymentInvalid(parameter = :Δt_base, reason = :unanchored,
                                           paths = unanchored, grid = grid))
        elseif grid === nothing
            push!(diags, DeploymentInvalid(parameter = :Δt_base, reason = :range,
                                           value = :derive))
        elseif grid.admissible === nothing
            push!(diags, DeploymentInvalid(parameter = :Δt_base, reason = :no_constraint))
        else
            Δt_r, derived = grid.admissible, true    # the coarsest admissible value
        end
    elseif Δt_base !== nothing
        Δt_r = _positive_finite(:Δt_base, _exact(:Δt_base, Δt_base, diags), diags)
    else
        Δt_r = Δt_frame_r                                 # the default path (§9.2)
    end

    # Per anchor, one exact division pair; anchor 0 is the base grid itself. The
    # loop collects into the call's list (§13.1): every anchor the chosen base
    # grid cannot express is named, so the coarsest admissible value is chosen
    # against the whole list. It reads `Δt_base` alone (D-229). Each division
    # runs in `Int128`, as `_lattice`'s do, so a count of base ticks past `Int`
    # is refused as its anchor, never as a raw `OverflowError`.
    Δt_r === nothing && return nothing
    anchors_on_entry = length(diags)
    Dk, Φk = [1], [0]
    for anchor in anchors
        D = _as_int(Rational{Int128}(anchor.T) / Δt_r)
        D === nothing &&
            push!(diags, DeploymentInvalid(parameter = :Δt_base, reason = :anchor_period,
                                          value = anchor.T, related = Δt_r,
                                          scope = anchor.scope, key = anchor.key, grid = grid))
        Φ = _as_int(Rational{Int128}(anchor.τ) / Δt_r)
        Φ === nothing &&
            push!(diags, DeploymentInvalid(parameter = :Δt_base, reason = :anchor_offset,
                                          value = anchor.τ, related = Δt_r,
                                          scope = anchor.scope, key = anchor.key, grid = grid))
        push!(Dk, something(D, 1)); push!(Φk, something(Φ, 0))
    end
    length(diags) == anchors_on_entry || return nothing

    # Per component, one multiply-add; the canonical residue 0 ≤ Φ < D survives
    # composition (§10.5), which is what the gate's truncated rem relies on. The
    # rate scopes resolve by the same law, off the timing the fold left them.
    # The law runs in checked `Int`, and a schedule it cannot hold is `nothing`:
    # `Φ < D`, so a divisor past `Int` counts a period in base ticks, and so in
    # units, past it, the lattices' refusal below.
    Δtb = Float64(Δt_r)
    timing_gates(timing::Timing) =
        (Base.Checked.checked_mul(timing.m, Dk[timing.anchor + 1]),
         Base.Checked.checked_add(Φk[timing.anchor + 1],
                                  Base.Checked.checked_mul(timing.c, Dk[timing.anchor + 1])))
    schedule = _exact_or_nothing() do
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
        Schedule(rows, scopes)
    end
    # Every other premise's fault is on the list by now.
    length(diags) == count_on_entry || return nothing
    # The lattices' premise is all of the above. A unit too fine to index one
    # frame in an `Int`, a period in units past it, or a bound too fine to count
    # a frame's steps in one, joins the event parameters' faults in the one throw.
    lattice = schedule === nothing ? :Δt_base : _lattice(Δt_frame_r, Δt_r, h_max_r, schedule.rows)
    if lattice === :Δt_base
        push!(diags, DeploymentInvalid(parameter = :Δt_base, reason = :range,
                                       value = Δt_r, related = Δt_frame_r))
        return nothing
    elseif lattice === :h_max
        push!(diags, DeploymentInvalid(parameter = :h_max, reason = :range,
                                       value = h_max_r, related = Δt_frame_r))
        return nothing
    end
    (Δt_frame = Δt_frame_r, Δt_base = Δt_r, h_max = h_max_r,
     schedule = schedule, lattice = lattice, grid = grid, derived = derived)
end

# --- the integration algorithm (§10.2, D-442, D-449) ---------------------------

# Design: §10.2, D-442, D-449. A token names the method and carries what the
# deployment fixes for it, which for a fixed-step method is nothing: the step
# bound is the deployment's `h_max`, under every method. The stepper it binds to
# at `Model` construction owns scratch sized by the state and typed by the
# scalar, which the deployment does not know; `bind_stepper` (stepper.jl) builds
# it.
abstract type AbstractAlgorithm end

# Design: §10.2, D-442, D-449.
"""
    RK4() -> RK4

The classical fourth-order Runge–Kutta method, the default algorithm.

Pass it as the `algorithm` keyword of [`Deployment`](@ref). It takes each span
between two [mandatory instants](@ref g-mandatory-instant) in the fewest equal
steps the deployment's `h_max` allows, one step when the deployment sets no
bound.

For the second-order method, see [`Heun`](@ref).
"""
struct RK4 <: AbstractAlgorithm end

# Design: §10.2, D-442, D-449.
"""
    Heun() -> Heun

Heun's second-order method, the explicit trapezoidal rule.

Pass it as the `algorithm` keyword of [`Deployment`](@ref). It steps as
[`RK4`](@ref) does, in equal steps no longer than the deployment's `h_max`.
"""
struct Heun <: AbstractAlgorithm end

# The token prints as it is spelled, by its bare name, so a trace header or a
# mismatch message reads the same from any module. `==` and `hash` are the
# fallbacks': a token is an immutable value, compared field by field.
Base.show(io::IO, algorithm::Union{RK4,Heun}) = print(io, nameof(typeof(algorithm)), "()")

# --- the artifact (§9.1, §9.2, D-254) -------------------------------------------

# Design: §9.1, §9.2, §10.2, §10.4, §10.6, §12.7, D-254, D-442, D-443, D-449, D-454.
# `Δt_base` has exactly one of three cross-validated sources (§9.1): explicit,
# `Δt_frame` by default, or GCD derivation over the anchors' constraint pool.
# `Δt_frame` is required because a domain rate is not a framework default. The
# algorithm, the step bound and the three event parameters are
# trajectory-determining: each validates on its own terms, and nothing relates
# the bound to either period (§10.2, D-449). The bound is recorded resolved,
# the lesser of itself and `Δt_frame`, so an absent bound and any bound at or
# above the frame deploy as one value. The defaults: a legitimate re-enable is
# one or two firings deep and a toggling FSM pair chatters without bound, so 4
# separates them; the event time is only as accurate as the O(h⁴) interpolant,
# so a tolerance tighter than 1e-6 buys nothing while each trial evaluation
# costs a full sweep; a multi-event frame needs three or four localizations and
# chattering needs tens, so 8. The `Lattice` is the loop's index-to-time map,
# derived here from the exact periods once (§10.5, D-445).
"""
    Deployment(build::Build; Δt_frame, Δt_base = nothing, h_max = nothing,
               algorithm = RK4(), firing_budget = 4, localization_tol = 1e-6,
               localization_budget = 8) -> Deployment

The build fixed to its time quantities, an algorithm and event parameters,
with no scalar type.

The time quantities are a [frame](@ref g-frame) period, a
[base tick](@ref g-tick) and a step bound.

A deployment carries the build, the grid it settled, the [`Schedule`](@ref) and
the warnings its construction raised, read with [`warnings`](@ref).
[`Model`](@ref) materializes it at a scalar type, and one deployment backs many
models.

Two deployments compare equal when their frame period, base tick, step bound,
algorithm, event parameters and schedule agree, whatever their builds.
[`replay!`](@ref) checks this before re-driving a recording. The three time
quantities are held and compared exact, as `Rational{Int}`, so two that round
to one `Float64` are different deployments. The bound is recorded as the lesser
of `h_max` and `Δt_frame`, so a deployment with no `h_max` and one whose
`h_max` is at or above the frame compare equal.

`Δt_base = :derive` derives the base tick from the discrete
[components](@ref g-component)' sample times. It is refused as
`DeploymentInvalid` unless every discrete component is [anchored](@ref g-anchor)
by an [`Absolute`](@ref) entry and the tree declares at least one. A derived
`Δt_base` finer than the fastest declared sample time warns `GridUtilization`.

A keyword outside its range is refused as `DeploymentInvalid`, and so is a
`Δt_base` that does not divide an anchor's period or offset.
[`Δt_frame`](@ref g-dt_frame), `Δt_base` and `h_max` stand in no required
ratio. A `Δt_base` whose exact common unit with `Δt_frame` is too fine to count
one frame in an `Int` is refused as well, and so is an `h_max` too fine to
count one frame's steps in one. One throw reports the faults found together.
Exhausting `firing_budget` warns `FiringBudget`.

# Keywords

- `Δt_frame`: the frame period in seconds, a `Rational`, an integer, a
  `Period` or an `Hz` value, required and refused as `DeploymentInvalid` when
  absent, given as a float, or past what `Rational{Int}` holds.
- `Δt_base`: the base tick period as a `Rational`, an integer, a `Period`
  or an `Hz` value, `Δt_frame` by default, or `:derive`.
- `h_max`: the longest step in seconds, taking the values `Δt_frame` takes and
  refused alike, or `nothing` for no bound below the frame.
- `algorithm`: the integration method, [`RK4`](@ref) or [`Heun`](@ref), bound
  to the state [buffer](@ref g-buffer) when the `Model` is built.
- `firing_budget`: how many times one event may fire at one
  [boundary](@ref g-boundary), an integer of at least 1.
- `localization_tol`: the positive relative bracket width, as a fraction of
  `Δt_frame`, at which event localization stops.
- `localization_budget`: how many event localizations one frame admits, an
  integer of at least 1.

See also [`build`](@ref), [`Model`](@ref), [`Simulation`](@ref).
"""
struct Deployment
    build::Build
    Δt_frame::Rational{Int}       # the frame period, exact (§9.2, D-443, D-454)
    Δt_base::Rational{Int}
    h_max::Rational{Int}          # the step bound, resolved against the frame (§10.5, D-449)
    algorithm::AbstractAlgorithm  # the method, bound at `Model` construction (D-442)
    firing_budget::Int            # per-event firings per boundary (§10.6)
    localization_tol::Float64     # relative bracket-width stop (§10.4)
    localization_budget::Int      # t* boundaries permitted per frame (§10.4)
    schedule::Schedule            # the bound per-component tick table (§9.2)
    grid::GridReport              # the attribution over the constraint pool (§9.2, D-187)
    lattice::Lattice              # the loop's index-to-time map (§10.5, D-445)
    warnings::Vector{Diagnostic}  # the warnings the constructor raised (§9.1, D-250)
end

function Deployment(build::Build; Δt_frame = nothing, Δt_base = nothing, h_max = nothing,
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
    bound = bind_schedule(build, Δt_frame, Δt_base, h_max, diags)
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
    deployment = Deployment(build, bound.Δt_frame, bound.Δt_base, bound.h_max, algorithm,
                            Int(firing_budget), Float64(localization_tol),
                            Int(localization_budget), bound.schedule, bound.grid,
                            bound.lattice, raised)
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
# `lattice` and `warnings` are not compared either — all three are
# functions of the rest. The three periods compare exact, so two that round
# to one `Float64` are two deployments (D-454). The algorithm compares as a
# value (D-442), and the bound resolved, so no `h_max` and one at or above the
# frame deploy alike (D-449).
Base.:(==)(a::Deployment, b::Deployment) =
    a.Δt_frame == b.Δt_frame && a.Δt_base == b.Δt_base && a.h_max == b.h_max &&
    a.algorithm == b.algorithm && a.firing_budget == b.firing_budget &&
    a.localization_tol == b.localization_tol &&
    a.localization_budget == b.localization_budget && a.schedule == b.schedule
Base.hash(deployment::Deployment, seed::UInt) =
    hash(deployment.schedule, hash(deployment.localization_budget,
        hash(deployment.localization_tol, hash(deployment.firing_budget,
            hash(deployment.algorithm, hash(deployment.h_max, hash(deployment.Δt_base,
                hash(deployment.Δt_frame, seed))))))))

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

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
already supports, those whose arithmetic fits `Int`. One report per constructor
call, computed ahead of the `Δt_base` branch: the refusal path's suggestion, the
derivation path's line and the `Deployment` itself read the same substrate.
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
            # fold requires 0 ≤ τ < Δt (`structure.jl`), so an upper neighbour reaching
            # the anchor's period is no offset; 0 stays, declaring none being a repair.
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
                  h_min::Union{Nothing,Rational{Int}}, rows::Vector{ScheduleEntry})
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
    # A bound at the frame splits no span. Under a proposing method, `h_min`
    # passed in, the shaping rule cuts no step below the floor, and a span
    # shorter than it is one step at least a unit long (D-460).
    gap = h_min !== nothing ? min(unit, wide(h_min)) :
          frame_steps == 1 ? unit : min(unit, wide(h_max) / 2)
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
`Int`, or under which a component's period in units leaves `Int`, is
`Δt_base`'s `:range`, `Δt_frame` its related value, and a bound
whose step counts or exact steps leave `Int` is `h_max`'s (§10.5, D-445).

The floor `h_min` takes the door `h_max` takes, and is required where the
method proposes, `proposing` the token's trait. One above half the resolved
`h_max` is `:range` with `h_max` as its related value, since a step at the
floor can be up to just under `2·h_min` long (D-463). Under a proposing
method it enters the lattices' least gap, so the doors refuse a run whose
clock cannot resolve it (D-450, D-460). A fixed-step method leaves it unused.
"""
function bind_schedule(build::Build, Δt_frame, Δt_base, h_max, h_min, proposing::Bool,
                       diags::Vector{Diagnostic})
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
    # The floor, through the same door, required by a proposing method and
    # refused above half the resolved bound (D-460, D-463). The half is taken
    # in `Int128`, since halving a `Rational{Int}` with an odd numerator
    # doubles its denominator, which can leave `Int`.
    proposing && h_min === nothing &&
        push!(diags, DeploymentInvalid(parameter = :h_min, reason = :missing))
    h_min_r = _positive_finite(:h_min,
        h_min === nothing ? nothing : _exact(:h_min, h_min, diags), diags)
    h_min_r === nothing || h_max_r === nothing ||
        Rational{Int128}(h_min_r) ≤ Rational{Int128}(h_max_r) / 2 ||
        push!(diags, DeploymentInvalid(parameter = :h_min, reason = :range, value = h_min_r,
                                       related = h_max_r))

    structure = build.structure
    anchors = structure.anchors
    # The attribution over the constraint pool — every anchor's period and every
    # nonzero offset (§9.1) — computed once, ahead of the branch, and handed to
    # every refusal that names the grid as well as to the artifact (§9.2, D-187).
    # A report whose arithmetic leaves `Int` is `nothing`, and marks a pool no
    # deployment holds: a base tick divides the pool's gcd, so its denominator
    # is at least the gcd's, and a leave-one-out factor past `Int` puts some
    # anchor's count of base ticks past it at every base tick that divides the
    # pool (D-459). `:derive` refuses it below, and any other `Δt_base` meets
    # the anchor loop's refusal.
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
        D = _as_int(Rational{Int128}(anchor.Δt) / Δt_r)
        D === nothing &&
            push!(diags, DeploymentInvalid(parameter = :Δt_base, reason = :anchor_period,
                                          value = anchor.Δt, related = Δt_r,
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
    lattice = schedule === nothing ? :Δt_base :
              _lattice(Δt_frame_r, Δt_r, h_max_r, proposing ? h_min_r : nothing, schedule.rows)
    if lattice === :Δt_base
        push!(diags, DeploymentInvalid(parameter = :Δt_base, reason = :range,
                                       value = Δt_r, related = Δt_frame_r))
        return nothing
    elseif lattice === :h_max
        push!(diags, DeploymentInvalid(parameter = :h_max, reason = :range,
                                       value = h_max_r, related = Δt_frame_r))
        return nothing
    end
    (Δt_frame = Δt_frame_r, Δt_base = Δt_r, h_max = h_max_r, h_min = h_min_r,
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

# Design: §10.2, §10.7, D-442, D-460, D-461. The tolerances are the identity of the choice, so
# the token holds them and the deployment compares them as part of the value.
# The controller's constants are the backend's, fixed in stepper.jl and never
# keywords. Each tolerance is refused at the token, as `Period` refuses a
# nonpositive period, so no deployment holds a token that cannot run. If the
# error test rejects the first attempt, the backend's proposal for the retry is
# at most the step over which the initial derivative changes the state by
# `0.8·reltol^(1/3)` of its scale, `max(|xᵢ|, abstol/reltol)`. A zero derivative
# sets no such limit.
"""
    BS3(; reltol = 1e-3, abstol = 1e-6) -> BS3

The Bogacki–Shampine method of order 3 with an embedded order-2 error
estimate, an adaptive method.

Pass it as the `algorithm` keyword of [`Deployment`](@ref), which then needs
`h_min`, the [floor](@ref g-floor) of its steps. Each step's length is
proposed by an error controller and shaped by the deployment's bounds
`h_min` and `h_max`. A step passes when every state component's error estimate
is at most `abstol + reltol·max(|xₙ|, |xₙ₊₁|)`, over the values alone.

The first [attempt](@ref g-attempt) after `init!` has no error to propose
from, so it takes all that `h_max` and the
[span](@ref g-mandatory-instant) allow. That attempt runs whole, so under a
coarse [frame](@ref g-frame), set `h_max`. Without it that attempt's stages
reach up to a frame ahead, where the model's own code may throw.

The method does not suit a [paced](@ref g-pacing) run, whose work per frame
it bounds only by `Δt_frame / h_min` steps.

`abstol` is in the units of the state and has no universal value. A state
whose meaningful scale is far below `1e-6` integrates with no error control
under the default, so such a model sets its own `abstol`.

A tolerance that is not a positive finite real is refused as
`ArgumentInvalid`.

# Keywords

- `reltol`: the relative tolerance, dimensionless.
- `abstol`: the absolute tolerance, in the state's units.

See also [`RK4`](@ref), [`Heun`](@ref).
"""
struct BS3 <: AbstractAlgorithm
    reltol::Float64
    abstol::Float64
    function BS3(reltol::Real, abstol::Real)
        diags = Diagnostic[]
        for (argument, value) in ((:reltol, reltol), (:abstol, abstol))
            value > 0 && isfinite(value) ||
                push!(diags, ArgumentInvalid(call = :BS3, reason = :range, argument = argument,
                                             value = value))
        end
        isempty(diags) || throw(DiagnosticError(diags))
        new(Float64(reltol), Float64(abstol))
    end
end
BS3(; reltol::Real = 1e-3, abstol::Real = 1e-6) = BS3(reltol, abstol)

# Design: §10.2, D-460.
# Whether a method proposes its steps' lengths, read by the `Deployment`
# constructor, which then requires `h_min`. No default: a proposing method that
# forgot it would deploy with no floor, and a fixed-step one would be refused
# for a floor it never reads.
proposes(::RK4) = false
proposes(::Heun) = false
proposes(::BS3) = true

# The token prints as it is spelled, by its bare name, so a trace header or a
# mismatch message reads the same from any module. `==` and `hash` are the
# fallbacks': a token is an immutable value, compared field by field.
Base.show(io::IO, algorithm::Union{RK4,Heun}) = print(io, nameof(typeof(algorithm)), "()")
Base.show(io::IO, algorithm::BS3) =
    print(io, "BS3(reltol = ", repr(algorithm.reltol), ", abstol = ", repr(algorithm.abstol), ")")

# --- the artifact (§9.1, §9.2, D-254) -------------------------------------------

# Design: §9.1, §9.2, §10.2, §10.4, §10.6, §12.7, D-254, D-442, D-443, D-449, D-454,
# D-460, D-463.
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
# chattering needs tens, so 8; a step's error test fails at most seven times
# before the floor, the limit of error-test failures per step SUNDIALS' CVODE
# and ARKODE keep, so 7. The `Lattice` is the loop's index-to-time map, derived
# here from the exact periods once (§10.5, D-445).
"""
    Deployment(build::Build; Δt_frame, Δt_base = nothing, h_max = nothing,
               h_min = nothing, algorithm = RK4(), firing_budget = 4,
               localization_tol = 1e-6, localization_budget = 8,
               attempt_budget = 7) -> Deployment

The build fixed to its time quantities, an algorithm and event parameters,
with no scalar type.

The time quantities are a [frame](@ref g-frame) period, a
[base tick](@ref g-tick), a step bound and, for an adaptive method, a step
[floor](@ref g-floor).

A deployment carries the build, the grid it settled, the [`Schedule`](@ref) and
the warnings its construction raised, read with [`warnings`](@ref).
[`Model`](@ref) materializes it at a scalar type, and one deployment backs many
models.

Two deployments compare equal when their frame period, base tick, step bound,
step floor, algorithm, event parameters, [attempt](@ref g-attempt) budget
and schedule agree,
whatever their builds.
[`replay!`](@ref) checks this before re-driving a recording. The time
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
count one frame's steps in one. An adaptive method, such as [`BS3`](@ref),
needs `h_min`, refused as `DeploymentInvalid` when absent or above half of
`h_max`, since a step at the floor can be up to just under twice `h_min`
long.
One throw reports the faults found together. Exhausting `firing_budget` warns
`FiringBudget`, and a step taken at the floor against its error test, or after
`attempt_budget` rejected attempts, warns `StepFloor`.

# Keywords

- `Δt_frame`: the frame period in seconds, a `Rational`, an integer, a
  `Period` or an `Hz` value, required and refused as `DeploymentInvalid` when
  absent, given as a float, or past what `Rational{Int}` holds.
- `Δt_base`: the base tick period as a `Rational`, an integer, a `Period`
  or an `Hz` value, `Δt_frame` by default, or `:derive`.
- `h_max`: the longest step in seconds, taking the values `Δt_frame` takes and
  refused alike, or `nothing` for no bound below the frame.
- `h_min`: the floor of an adaptive method's steps in seconds, taking the
  values `h_max` takes. A distance to a
  [mandatory instant](@ref g-mandatory-instant) shorter than it is one step.
  A fixed-step method leaves it unused.
- `algorithm`: the integration method, [`RK4`](@ref), [`Heun`](@ref) or
  [`BS3`](@ref), bound to the state [buffer](@ref g-buffer) when the `Model`
  is built.
- `firing_budget`: how many times one event may fire at one
  [boundary](@ref g-boundary), an integer of at least 1.
- `localization_tol`: the positive relative bracket width, as a fraction of
  `Δt_frame`, at which event localization stops.
- `localization_budget`: how many event localizations one frame admits, an
  integer of at least 1.
- `attempt_budget`: how many attempts an adaptive method's step may make
  before its next attempt is at the floor, an integer of at least 1.

See also [`build`](@ref), [`Model`](@ref), [`Simulation`](@ref).
"""
struct Deployment
    build::Build
    Δt_frame::Rational{Int}       # the frame period, exact (§9.2, D-443, D-454)
    Δt_base::Rational{Int}
    h_max::Rational{Int}          # the step bound, resolved against the frame (§10.5, D-449)
    h_min::Union{Nothing,Rational{Int}}   # the step floor, a proposing method's (§10.2, D-460)
    algorithm::AbstractAlgorithm  # the method, bound at `Model` construction (D-442)
    firing_budget::Int            # per-event firings per boundary (§10.6)
    localization_tol::Float64     # relative bracket-width stop (§10.4)
    localization_budget::Int      # t* boundaries permitted per frame (§10.4)
    attempt_budget::Int           # attempts per step before the floor (§10.2, D-460)
    schedule::Schedule            # the bound per-component tick table (§9.2)
    grid::GridReport              # the attribution over the constraint pool (§9.2, D-187)
    lattice::Lattice              # the loop's index-to-time map (§10.5, D-445)
    warnings::Vector{Diagnostic}  # the warnings the constructor raised (§9.1, D-250)
end

function Deployment(build::Build; Δt_frame = nothing, Δt_base = nothing, h_max = nothing,
                    h_min = nothing, algorithm = RK4(), firing_budget = 4,
                    localization_tol = 1e-6, localization_budget = 8, attempt_budget = 7)
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
    attempt_budget isa Integer && attempt_budget ≥ 1 ||
        push!(diags, DeploymentInvalid(parameter = :attempt_budget, reason = :range, value = attempt_budget))
    # The token's trait says whether the method needs a floor (D-460).
    proposing = algorithm isa AbstractAlgorithm && proposes(algorithm)
    bound = bind_schedule(build, Δt_frame, Δt_base, h_max, h_min, proposing, diags)
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
    deployment = Deployment(build, bound.Δt_frame, bound.Δt_base, bound.h_max, bound.h_min,
                            algorithm, Int(firing_budget), Float64(localization_tol),
                            Int(localization_budget), Int(attempt_budget), bound.schedule,
                            bound.grid, bound.lattice, raised)
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
# frame deploy alike (D-449). The floor and the attempt budget compare whatever
# the method, as `localization_budget` does in a model with no localized event.
Base.:(==)(a::Deployment, b::Deployment) =
    a.Δt_frame == b.Δt_frame && a.Δt_base == b.Δt_base && a.h_max == b.h_max &&
    a.h_min == b.h_min && a.algorithm == b.algorithm && a.firing_budget == b.firing_budget &&
    a.localization_tol == b.localization_tol &&
    a.localization_budget == b.localization_budget &&
    a.attempt_budget == b.attempt_budget && a.schedule == b.schedule
Base.hash(deployment::Deployment, seed::UInt) =
    hash(deployment.schedule, hash(deployment.attempt_budget,
        hash(deployment.localization_budget, hash(deployment.localization_tol,
            hash(deployment.firing_budget, hash(deployment.algorithm,
                hash(deployment.h_min, hash(deployment.h_max, hash(deployment.Δt_base,
                    hash(deployment.Δt_frame, seed))))))))))

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

module Blocks

import ..Redstone: AbstractComponent, Pinned, StateEvent, StopFlag, NO_STOP, STOP_REQUESTED,
    x_init, s_init, m_init, u_types, y_types, y_direct, y_state, x_deriv, s_update,
    state_events, local_wires, input_wires, output_wires, sample_times, transparent_container,
    stop_reason
using StaticArrays: StaticArray, SMatrix, SVector, SOneTo, SUnitRange, similar_type
using LinearAlgebra: I
import ForwardDiff

# The standard component library (§13.7, D-313). Written as a user's component
# file is: the import list above is its whole reach into the parent, so every
# block here is an ordinary component the framework knows nothing of.

# --- the junction (§13.7, D-311) -------------------------------------------------

# Design: §2.3, §6.2.
"""
    Junction{In, Out, N}(f) -> Junction{In, Out, N}

A continuous [primitive](@ref g-primitive) that publishes a fold of its `N`
inputs as its one output.

The inputs `in1` to `inN` are typed `In`, and the output `out` is typed `Out`,
with `out = f(in1, …, inN)`, the fold applied in positional order. The
[block](@ref g-block) is stateless. The fold `f` is instance data, and the type
parameter `F` is inferred from it. A custom fold, such as a weighted blend or a
mass-properties composition, is written at the site.

The fold is stateless and declares no events, so a discontinuity written into
it lands wherever it lands inside a step. A clamp is fine, since its kink is
second-order downstream. So is a branch on a `Bool` that flips at a
[boundary](@ref g-boundary), as a saturation code does. A branch on a continuous
quantity makes a mode silently, which the moded blocks such as [`Relay`](@ref)
exist to declare.

See also [`SumJunction`](@ref), [`Or`](@ref), [`And`](@ref), [`Pack`](@ref).
"""
struct Junction{In, Out, N, F} <: AbstractComponent
    f::F
end
(::Type{Junction{In, Out, N}})(f) where {In, Out, N} = Junction{In, Out, N, typeof(f)}(f)

# Design: §6.2.
"""
    SumJunction{V, N}() -> SumJunction{V, N}

A continuous [primitive](@ref g-primitive) that publishes the sum of its `N`
inputs.

It is the [`Junction`](@ref) at `+`, with the inputs `in1` to `inN` and the
output `out` all typed `V`.
"""
const SumJunction{V, N} = Junction{V, V, N, typeof(+)}

# Design: §13.7.
"""
    Or{N}() -> Or{N}

A continuous [primitive](@ref g-primitive) that publishes the logical or of its
`N` `Bool` inputs.

It is the [`Junction`](@ref) at `|`, with the inputs `in1` to `inN` and the
output `out` all `Bool`. It gives one consolidated `Bool` to a consumer that
wants one.

See also [`And`](@ref).
"""
const Or{N}  = Junction{Bool, Bool, N, typeof(|)}

# Design: §13.7.
"""
    And{N}() -> And{N}

A continuous [primitive](@ref g-primitive) that publishes the logical and of its
`N` `Bool` inputs.

It is the [`Junction`](@ref) at `&`, with the inputs `in1` to `inN` and the
output `out` all `Bool`.

See also [`Or`](@ref).
"""
const And{N} = Junction{Bool, Bool, N, typeof(&)}

pack(args...) = SVector(args)

# Design: §13.7.
# The fold is the named function `pack` and not `SVector`, whose type is a
# `UnionAll` that fixes no method, so the sweep would dispatch on it at every
# call and allocate.
"""
    Pack{V, N}() -> Pack{V, N}

A continuous [primitive](@ref g-primitive) that publishes its `N` inputs packed
into one static vector.

It is the [`Junction`](@ref) at the fold `pack`, with the inputs `in1` to `inN`
typed `V` and the output `out` an `SVector{N, V}`.

See also [`Unpack`](@ref).
"""
const Pack{V, N} = Junction{V, SVector{N, V}, N, typeof(pack)}

(::Type{SumJunction{V, N}})() where {V, N} = SumJunction{V, N}(+)
(::Type{Or{N}})() where {N} = Or{N}(|)
(::Type{And{N}})() where {N} = And{N}(&)
(::Type{Pack{V, N}})() where {V, N} = Pack{V, N}(pack)

x_init(::Junction) = nothing
u_types(::Junction{In, Out, N}) where {In, Out, N} =
    NamedTuple{ntuple(i -> Symbol(:in, i), N)}(ntuple(_ -> In, N))
y_types(::Junction{In, Out}) where {In, Out} = (out = Out,)
y_direct(j::Junction, (; u)) = (out = j.f(u...),)

# --- the structure blocks (§13.7, D-313) ----------------------------------------

@generated unpack_names(::Val{N}) where {N} = ntuple(i -> Symbol(:out, i), N)

# Design: The output names come from the generated `unpack_names`, which hands
# the body a constant tuple, where names built in the body would allocate at
# every sweep.
"""
    Unpack{V, N}() -> Unpack{V, N}

A continuous [primitive](@ref g-primitive) that publishes the `N` elements of
its static-vector input as `N` outputs.

The one input `in` is an `SVector{N, V}`, and the outputs `out1` to `outN` are
typed `V`, with `outi = in[i]`. The [block](@ref g-block) is stateless, and the
inverse of [`Pack`](@ref).
"""
struct Unpack{V, N} <: AbstractComponent end
x_init(::Unpack) = nothing
u_types(::Unpack{V, N}) where {V, N} = (in = SVector{N, V},)
y_types(::Unpack{V, N}) where {V, N} = NamedTuple{unpack_names(Val(N))}(ntuple(_ -> V, N))
y_direct(::Unpack{V, N}, (; u)) where {V, N} = NamedTuple{unpack_names(Val(N))}(Tuple(u.in))

# Design: §2.3, §5.3, D-179.
"""
    Switch{V}() -> Switch{V}

A continuous [primitive](@ref g-primitive) that publishes one of its two inputs,
picked by a `Bool` input.

The inputs `in1` and `in2` are typed `V` and `select` is a `Bool`. The one
output `out`, typed `V`, is `in1` while `select` holds and `in2` otherwise. The
[block](@ref g-block) is stateless. `out` reads all three inputs, so a selector
wired from a memoryless function of `out` closes an
[algebraic loop](@ref g-algebraic-loop), which the build refuses as
`AlgebraicCycle`.

The block declares no event, so the jump in `out` lands where `select` flips. A
`select` published from a mode, or held between [ticks](@ref g-tick), flips on a
[boundary](@ref g-boundary) and the jump is clean. One computed from a
continuous quantity inside a stage body flips inside a step and smears that
step. That is a mode made silently, which the moded blocks such as
[`Relay`](@ref) exist to declare.
"""
struct Switch{V} <: AbstractComponent end
x_init(::Switch) = nothing
u_types(::Switch{V}) where {V} = (in1 = V, in2 = V, select = Bool)
y_types(::Switch{V}) where {V} = (out = V,)
y_direct(::Switch, (; u)) = (out = ifelse(u.select, u.in1, u.in2),)

# --- the leaf blocks (§13.7, D-312) ---------------------------------------------

# Design: §11.3, §13.7.
"""
    Constant(value) -> Constant

A continuous [primitive](@ref g-primitive) that publishes a fixed value, with no
inputs and no state.

The output `out` publishes `value` from [stage 1](@ref g-stage-function). The
[block](@ref g-block) is stateless, so discrete consumers read it as well.

`out` is [pinned](@ref g-walked) at `V`, the type of `value`. A constant is
never seeded, so it carries zero partials under every `Dual`
[activation](@ref g-activation). A consumer input declared plain `Float64`,
which admits a value with or without partials, accepts it as a value that never
carries partials. The value is instance data, not an overridable default. A
source set from outside is a [root input](@ref g-root-input).

See also [`Source`](@ref), [`Step`](@ref).
"""
struct Constant{V} <: AbstractComponent
    value::V
end
x_init(::Constant) = nothing
y_types(::Constant{V}) where {V} = (out = Pinned{V},)
y_state(c::Constant, _) = (out = c.value,)

# Design: §5.5, §10.6, D-231.
"""
    UnitDelay(v0) -> UnitDelay

A discrete [primitive](@ref g-primitive) that publishes its input from the
previous [tick](@ref g-tick).

The [block](@ref g-block) is a discrete primitive, the native `z⁻¹` of the
discrete [tier](@ref g-tier). `out` publishes the stored value from
[stage 1](@ref g-stage-function), and `v0` at the first publication. Each tick
stores `in` for the next one. The [store](@ref g-store) is isbits, which bounds
`V`.

It breaks an [algebraic loop](@ref g-algebraic-loop), and that is a modelling
decision. Placed in a continuous loop, it moves the signal onto the discrete
tier and inserts a zero-order hold at the scale of [`Δt_base`](@ref g-dt_base).

See also [`Delay`](@ref).
"""
struct UnitDelay{V} <: AbstractComponent
    v0::V
end
s_init(delay::UnitDelay) = delay.v0
u_types(::UnitDelay{V}) where {V} = (in = V,)
y_types(::UnitDelay{V}) where {V} = (out = V,)
y_state(::UnitDelay, (; s)) = (out = s,)
s_update(::UnitDelay, (; u)) = u.in

# Design: §13.7.
"""
    Freeze{V}() -> Freeze{V}

A continuous [primitive](@ref g-primitive) that publishes its input with its
partials dropped, so no derivative passes through it.

The [block](@ref g-block) is the declared stop-gradient. `out` is `in` with its
partials dropped, [pinned](@ref g-walked) at `V`. A producer that walks may
therefore feed a [`Pinned`](@ref) input [entry](@ref g-entry) through it. At
[nominal](@ref g-nominal) it is the identity. Every Jacobian along the path then
reads a zero coupling, which is the modelling decision the block states.

`V` is a `Real` or a `StaticArray` of them. Any other `V` is refused as a
`TypeError` where `Freeze{V}` is written.
"""
struct Freeze{V <: Union{Real, StaticArray{<:Tuple, <:Real}}} <: AbstractComponent end
x_init(::Freeze) = nothing
u_types(::Freeze{V}) where {V} = (in = V,)
y_types(::Freeze{V}) where {V} = (out = Pinned{V},)
y_direct(::Freeze, (; u)) = (out = ForwardDiff.value.(u.in),)

# --- the stop request (§13.5, §13.7, D-316) -------------------------------------

# Design: §13.5, D-316.
"""
    StopRequest(; reason = "") -> StopRequest

A continuous [primitive](@ref g-primitive) that publishes a
[stop request](@ref g-stop-request) while its `Bool` input holds.

The output `flag`, a [`StopFlag`](@ref), publishes `STOP_REQUESTED` while the
input `request` holds and `NO_STOP` otherwise. The [block](@ref g-block) is
stateless, so it refreshes at every [boundary](@ref g-boundary) and sits
anywhere in the tree. It holds no privilege: the request is the
[port](@ref g-port)'s type, and any component may publish one.

# Keywords

- `reason`: the reason the block's requests report, read by
  [`stop_reason`](@ref). It is instance data.
"""
struct StopRequest <: AbstractComponent
    reason::String
end
StopRequest(; reason = "") = StopRequest(reason)
x_init(::StopRequest) = nothing
u_types(::StopRequest) = (request = Bool,)
y_types(::StopRequest) = (flag = StopFlag,)
y_direct(::StopRequest, (; u)) = (flag = u.request ? STOP_REQUESTED : NO_STOP,)
stop_reason(c::StopRequest) = c.reason

# --- the discrete tier (§7.3, §10.5, D-313) -------------------------------------

# Design: §5.5, §10.5.
"""
    Delay(; K::Int, v0 = 0.0) -> Delay

A discrete [primitive](@ref g-primitive) that publishes its input from `K`
[ticks](@ref g-tick) before.

The [block](@ref g-block) is the delay line, the `z⁻ᴷ` of the discrete
[tier](@ref g-tier). `out` publishes `in` from `K` ticks ago, and `v0` at the
first `K` publications. It publishes from [stage 1](@ref g-stage-function). The
[store](@ref g-store) is a ring of `K` values and a cursor. The slot under the
cursor holds the value from `K` ticks ago, and each tick overwrites it with `in`
and advances, with no shift of the other slots.

It breaks an [algebraic loop](@ref g-algebraic-loop) as [`UnitDelay`](@ref)
does, and that is a modelling decision. Placed in a continuous loop, it moves
the signal onto the discrete tier and inserts a zero-order hold at the scale of
[`Δt_base`](@ref g-dt_base).

# Keywords

- `K`: the delay in ticks of the component's own period, at least 1, so the
  model picks it from the rate it declares. `K = 1` is `UnitDelay` in keyword
  spelling, and a smaller `K` is refused as an `ArgumentError`.
- `v0`: the value published before `K` ticks have passed. `V` is `Float64` or
  a static array of `Float64`, taken from `float(v0)`, so an integer `v0`
  qualifies.
"""
struct Delay{V <: Union{Real, StaticArray{<:Tuple, <:Real}}, K} <: AbstractComponent
    v0::V
end
function Delay(; K::Int, v0 = 0.0)
    K >= 1 || throw(ArgumentError("Delay takes `K >= 1`; `K = 1` is `UnitDelay`."))
    v0 = float(v0)
    Delay{typeof(v0), K}(v0)
end
s_init(c::Delay{V, K}) where {V, K} = (ring = SVector{K, V}(ntuple(_ -> c.v0, K)), cursor = 1)
u_types(::Delay{V}) where {V} = (in = V,)
y_types(::Delay{V}) where {V} = (out = V,)
y_state(::Delay, (; s)) = (out = s.ring[s.cursor],)
s_update(::Delay{V, K}, (; s, u)) where {V, K} =
    (ring = Base.setindex(s.ring, u.in, s.cursor), cursor = s.cursor == K ? 1 : s.cursor + 1)

# Design: §5.5, §9.4, §10.5, D-263.
"""
    DiscreteIntegrator(; s0 = 0.0) -> DiscreteIntegrator

A discrete [primitive](@ref g-primitive) that publishes the forward-Euler
integral of its input.

The [block](@ref g-block) holds one bare [store](@ref g-store) value from `s0`, `q`
below, addressed by the path alone.
Each [tick](@ref g-tick) advances it by forward Euler, `q⁺ = q + Δt in`. `out`
publishes `q` from [stage 1](@ref g-stage-function). The block therefore breaks
an [algebraic loop](@ref g-algebraic-loop) as [`UnitDelay`](@ref) does. `Δt` is
the component's own period, so the integral is per second at any rate.

The discrete [tier](@ref g-tier) never follows the scalar of an
[activation](@ref g-activation), so under a `Dual` activation the block holds
its last value.

# Keywords

- `s0`: the initial value of `q`. `V` is `Float64` or a static array of
  `Float64`, taken from `float(s0)`, so an integer `s0` qualifies.

See also [`DiscreteLimitedIntegrator`](@ref), [`Integrator`](@ref).
"""
struct DiscreteIntegrator{V <: Union{Real, StaticArray{<:Tuple, <:Real}}} <: AbstractComponent
    s0::V
end
DiscreteIntegrator(; s0 = 0.0) = DiscreteIntegrator(float(s0))
s_init(c::DiscreteIntegrator) = c.s0
u_types(::DiscreteIntegrator{V}) where {V} = (in = V,)
y_types(::DiscreteIntegrator{V}) where {V} = (out = V,)
y_state(::DiscreteIntegrator, (; s)) = (out = s,)
s_update(::DiscreteIntegrator, (; s, u, Δt)) = s + Δt * u.in

"""
    DiscreteLimitedIntegrator(; lower, upper, s0 = zero(lower)) -> DiscreteLimitedIntegrator

A discrete [primitive](@ref g-primitive) that publishes the forward-Euler
integral of its input, held between two limits.

Each [tick](@ref g-tick) advances the one bare [store](@ref g-store) value, `q` below, from
`s0` as `q⁺ = clamp(q + Δt in, lower, upper)`. `out` publishes `q` from
[stage 1](@ref g-stage-function). The mode and four events of the continuous
[`LimitedIntegrator`](@ref) are this one `clamp`, with no mode store and no
localization.

A second output, `saturation`, publishes the same `Int8` code, read off the
state, also from stage 1: `1` at `upper`, `-1` at `lower` and `0` between. At a
limit with the input already pointing inward, the code reads saturated until the
next tick moves the state off.

Over a static vector, the limits and the codes are componentwise, and
`saturation` publishes a static vector of `Int8`.

# Keywords

- `lower`: the lower limit, below `upper`, componentwise over a vector.
- `upper`: the upper limit.
- `s0`: the initial value of `q`. `s0`, `lower` and `upper` are promoted to one
  `V`, which is `Float64` or a static array of `Float64`, and taken by `float`,
  so integer values qualify.

See also [`DiscreteIntegrator`](@ref).
"""
struct DiscreteLimitedIntegrator{V <: Union{Real, StaticArray{<:Tuple, <:Real}}} <: AbstractComponent
    s0::V
    lower::V
    upper::V
end
function DiscreteLimitedIntegrator(; lower, upper, s0 = zero(lower))
    s0, lower, upper = float.(promote(s0, lower, upper))
    DiscreteLimitedIntegrator(s0, lower, upper)
end
saturation_code(q, lower, upper) = q >= upper ? Int8(1) : q <= lower ? Int8(-1) : Int8(0)
s_init(c::DiscreteLimitedIntegrator) = c.s0
u_types(::DiscreteLimitedIntegrator{V}) where {V} = (in = V,)
y_types(::DiscreteLimitedIntegrator{V}) where {V} = (out = V, saturation = saturation_type(V))
y_state(c::DiscreteLimitedIntegrator, (; s)) =
    (out = s, saturation = saturation_code.(s, c.lower, c.upper))
s_update(c::DiscreteLimitedIntegrator, (; s, u, Δt)) = clamp.(s + Δt * u.in, c.lower, c.upper)

# Design: §5.3, §5.5, §10.5.
"""
    RateLimiter(; rising, falling = rising, s0 = 0.0) -> RateLimiter

A discrete [primitive](@ref g-primitive) that publishes its input with its rate
of change bounded per [tick](@ref g-tick).

`out` follows `in`, moving at most `rising Δt` up and `falling Δt` down per
tick. `Δt` is the component's own period. One bare [store](@ref g-store) value, `v` below,
holds the previous output, and each tick stores `out`:

    out = v + clamp(in - v, -falling Δt, rising Δt)

`out` reads `in`, so the [block](@ref g-block) has
[feedthrough](@ref g-feedthrough). A loop closed on it through a memoryless path
is refused as `AlgebraicCycle`. A form publishing the stored value from
[stage 1](@ref g-stage-function) would break that loop, but it lags its input by
one tick at every rate. It is this block followed by a [`UnitDelay`](@ref), a
modelling decision the model makes by placing the delay. Over a vector the slew
is componentwise.

# Keywords

- `rising`: the largest rise per second, positive, and kept a `Float64` whatever
  scalar the model runs at.
- `falling`: the largest fall per second, positive, and kept a `Float64` likewise.
- `s0`: the previous output at the first tick, so the output at `t₀` is already
  one slew step from it. `V` is `Float64` or a static array of `Float64`, taken
  from `float(s0)`.
"""
struct RateLimiter{V <: Union{Real, StaticArray{<:Tuple, <:Real}}} <: AbstractComponent
    rising::Float64
    falling::Float64
    s0::V
end
function RateLimiter(; rising, falling = rising, s0 = 0.0)
    s0 = float(s0)
    RateLimiter{typeof(s0)}(rising, falling, s0)
end
s_init(c::RateLimiter) = c.s0
u_types(::RateLimiter{V}) where {V} = (in = V,)
y_types(::RateLimiter{V}) where {V} = (out = V,)
y_direct(c::RateLimiter, (; s, u, Δt)) = (out = s + clamp.(u.in - s, -c.falling * Δt, c.rising * Δt),)
s_update(::RateLimiter, (; y)) = y.out

# --- the noise source (§7.3, §2.5, D-231, D-313) --------------------------------

# Design: §2.4, §2.5, §10.5, D-231.
"""
    GaussianWhiteNoise(; seed, μ = nothing, σ = nothing, psd = nothing) -> GaussianWhiteNoise

A discrete [primitive](@ref g-primitive) that publishes a seeded Gaussian white
noise sample at each [tick](@ref g-tick).

The [block](@ref g-block) is a discrete Gaussian white noise process. At each
tick, `out` publishes an independent sample of mean `μ` and standard deviation
`σ`. It publishes from [stage 1](@ref g-stage-function). The sample is a pure
function of `seed` and the tick count, the one bare [store](@ref g-store) value, `k` below.
The stage therefore draws, no generator or [workspace](@ref g-workspace) is
needed, and [replay](@ref g-replay) reproduces the stream. After a tick the
store holds the next sample's index, so `k` reads `N + 1` once the block has
ticked `N` times past `t₀`. Two blocks with one seed publish one stream, so
independent sources take distinct seeds.

`μ` and the scale are broadcast to one `V`, `Float64` or an `SVector` of
`Float64`, so a scalar pairs with a vector, and over a vector the components
are independent.

Exactly one of `σ` and `psd` is given. Neither or both is refused as an
`ArgumentError`.

# Keywords

- `seed`: the integer the stream is drawn from. It is instance data.
- `μ`: the mean. Left at `nothing`, it is zero in the scale's shape.
- `σ`: the standard deviation per sample, at any period.
- `psd`: the two-sided intensity `Q` of the white noise the samples stand for,
  with `σ² = Q/Δt` at the component's own period `Δt`. A one-sided density is
  halved before being passed.
"""
struct GaussianWhiteNoise{V <: Union{Float64, SVector{<:Any, Float64}}} <: AbstractComponent
    seed::UInt64
    μ::V
    σ::V              # per sample, or `sqrt(psd)` with `density` set
    density::Bool     # whether `σ` scales by `1/sqrt(Δt)`
end
function GaussianWhiteNoise(; seed, μ = nothing, σ = nothing, psd = nothing)
    (σ === nothing) == (psd === nothing) &&
        throw(ArgumentError("GaussianWhiteNoise takes exactly one of `σ` and `psd`."))
    scale = psd === nothing ? σ : sqrt.(psd)
    μ = something(μ, zero(scale))
    GaussianWhiteNoise(UInt64(seed), Float64.(μ .+ zero(scale)), Float64.(scale .+ zero(μ)), psd !== nothing)
end

# SplitMix64's output on the state after `k + 1` advances from `seed`: the
# stream's `k`-th word, reached without the `k` words before it.
function splitmix(seed, k)
    z = UInt64(seed) + (UInt64(k) + 1) * 0x9e3779b97f4a7c15
    z = (z ⊻ (z >> 30)) * 0xbf58476d1ce4e5b9
    z = (z ⊻ (z >> 27)) * 0x94d049bb133111eb
    z ⊻ (z >> 31)
end
# The `k`-th standard normal sample, by Box–Muller over the words `2k` and
# `2k + 1`. `u1` lies in `(0, 1]`, so the logarithm never sees zero.
function gaussian(seed, k)
    u1 = 1 - (splitmix(seed, 2k) >> 11) * 0x1p-53
    u2 = (splitmix(seed, 2k + 1) >> 11) * 0x1p-53
    sqrt(-2 * log(u1)) * cospi(2 * u2)
end
gaussian(seed, k, ::Type{Float64}) = gaussian(seed, k)
# Over a vector, component `i` reads the sub-counter `k N + i - 1`.
gaussian(seed, k, ::Type{SVector{N, Float64}}) where {N} =
    SVector(ntuple(i -> gaussian(seed, k * N + i - 1), Val(N)))

s_init(::GaussianWhiteNoise) = UInt64(0)
y_types(::GaussianWhiteNoise{V}) where {V} = (out = V,)
function y_state(c::GaussianWhiteNoise{V}, (; s, Δt)) where {V}
    scale = c.density ? c.σ ./ sqrt(Δt) : c.σ
    (out = c.μ .+ scale .* gaussian(c.seed, s, V),)
end
s_update(::GaussianWhiteNoise, (; s)) = s + 1

# --- the time source (§13.7, D-313) ---------------------------------------------

# Design: §11.3, D-312.
"""
    Source{V}(f) -> Source{V}
    Source(f) -> Source{Float64}

A continuous [primitive](@ref g-primitive) that publishes a function of time,
with no inputs and no state.

The output `out` publishes `f(t)` from [stage 1](@ref g-stage-function).
`Source(f)` is `Source{Float64}(f)`. `f` receives the plain `Float64` time under
every [activation](@ref g-activation), so it need not be generic, and it returns
a `V`. Nothing converts, so a value of another type is refused at build as
`ConformanceFailure`.

`out` is [pinned](@ref g-walked) at `V`. The time is stripped of its partials
before `f` sees it, so `out` depends on neither state nor an input that follows
the scalar, and carries zero partials under every activation. A source set from
outside is a [root input](@ref g-root-input).

See also [`Constant`](@ref), [`Step`](@ref).
"""
struct Source{V, F} <: AbstractComponent
    f::F
end
(::Type{Source{V}})(f) where {V} = Source{V, typeof(f)}(f)
Source(f) = Source{Float64}(f)
x_init(::Source) = nothing
y_types(::Source{V}) where {V} = (out = Pinned{V},)
y_state(c::Source, (; t)) = (out = c.f(ForwardDiff.value(t)),)

# --- the continuous dynamics (§13.7, D-313) -------------------------------------

# Design: §5.3, §7.2.
"""
    Integrator(; x0 = 0.0) -> Integrator

A continuous [primitive](@ref g-primitive) that publishes the time integral of
its input.

The [block](@ref g-block) holds one continuous state `q`, starting at `x0`, with
`q̇ = in`. `out` publishes `q` from [stage 1](@ref g-stage-function). The block
therefore has no [feedthrough](@ref g-feedthrough). A `Float64` state follows
the scalar of a `Dual` [activation](@ref g-activation), so the block linearizes
as it integrates.

# Keywords

- `x0`: the initial value of `q`. `V` is `Float64` or a static array of
  `Float64`, taken from `float(x0)`, so an integer `x0` qualifies.

See also [`LimitedIntegrator`](@ref), [`DiscreteIntegrator`](@ref).
"""
struct Integrator{V <: Union{Real, StaticArray{<:Tuple, <:Real}}} <: AbstractComponent
    x0::V
end
Integrator(; x0 = 0.0) = Integrator(float(x0))
x_init(c::Integrator) = c.x0
u_types(::Integrator{V}) where {V} = (in = V,)
y_types(::Integrator{V}) where {V} = (out = V,)
y_state(::Integrator, (; x)) = (out = x,)
x_deriv(::Integrator, (; u)) = u.in

# Design: §7.2, D-313, commit `9c75324`.
# The sentence on the scalar case is the user's ruling of 2026-10-27, which
# landed as the inventory's `FirstOrderLag` row in `9c75324`.
"""
    FirstOrderLag(; τ, x0 = 0.0) -> FirstOrderLag

A continuous [primitive](@ref g-primitive) that publishes its input through a
first-order lag of time constant `τ`.

The [block](@ref g-block) holds one continuous state `q` from `x0`, with
`q̇ = (in - q) / τ`, and `out` publishes `q` from
[stage 1](@ref g-stage-function). The state follows the scalar of a `Dual`
[activation](@ref g-activation), so the lag linearizes to `A = -1/τ` and
`B = 1/τ`. A hand-written lag whose [scratch](@ref g-scratch) is kept at
`Float64` fails there instead.

`V` is `Float64` or a static array of `Float64`, taken from `float(x0)`, so an
integer `x0` qualifies. For a scalar signal it is
[`TransferFunction`](@ref)`(num = (1,), den = (τ, 1), u0 = x0)`; the block stays
for static-array signals, for `x0` in the signal's own coordinates and for the
spelling.

# Keywords

- `τ`: the time constant, positive. It is instance data, kept a `Float64`
  whatever scalar the model runs at.
- `x0`: the initial value of `q`.
"""
struct FirstOrderLag{V <: Union{Real, StaticArray{<:Tuple, <:Real}}} <: AbstractComponent
    x0::V
    τ::Float64
end
function FirstOrderLag(; τ, x0 = 0.0)
    x0 = float(x0)
    FirstOrderLag{typeof(x0)}(x0, τ)
end
x_init(c::FirstOrderLag) = c.x0
u_types(::FirstOrderLag{V}) where {V} = (in = V,)
y_types(::FirstOrderLag{V}) where {V} = (out = V,)
y_state(::FirstOrderLag, (; x)) = (out = x,)
x_deriv(c::FirstOrderLag, (; x, u)) = (u.in - x) / c.τ

# --- the linear blocks (§13.7, §5.3, D-313) -------------------------------------

# Design: §5.3.
# Every stage is defined here, once, over the block's `realization`.
"""
    LinearBlock{FT}

The abstract parent of the continuous linear [blocks](@ref g-block), which
carries their stages and their feedthrough class.

`FT` is the feedthrough class, whether the block has
[feedthrough](@ref g-feedthrough). It is `false` when the direct term is zero
and `out` comes from [stage 1](@ref g-stage-function). It is `true` when the
direct term is nonzero and `out` comes from stage 2. The stages are defined once
on the parent, over each block's state-space realization, so no linear block
declares a stage of its own.

See also [`StateSpace`](@ref), [`TransferFunction`](@ref),
[`DiscreteLinearBlock`](@ref).
"""
abstract type LinearBlock{FT} <: AbstractComponent end

# The port edges. A port one wide is a `Float64` and a wider one an `SVector`,
# while the bodies always take matrix products over vectors.
port_type(width) = width == 1 ? Float64 : SVector{width, Float64}
as_vector(v::Real) = SVector(v)
as_vector(v::SVector) = v
as_port(v::SVector{1}) = v[1]
as_port(v::SVector) = v

x_init(c::LinearBlock) = realization(c).x0
u_types(c::LinearBlock) = (in = port_type(size(realization(c).B, 2)),)
y_types(c::LinearBlock) = (out = port_type(size(realization(c).C, 1)),)
function x_deriv(c::LinearBlock, (; x, u))
    (; A, B) = realization(c)
    A * x + B * as_vector(u.in)
end
y_state(c::LinearBlock{false}, (; x)) = (out = as_port(realization(c).C * x),)
function y_direct(c::LinearBlock{true}, (; x, u))
    (; C, D) = realization(c)
    (out = as_port(C * x + D * as_vector(u.in)),)
end

# Design: §5.3, §5.5, §7.2.
# `linear_blocks.md` gives the reasoning: the storage, the realization a
# transfer function goes through, and why the name is the one
# ControlSystemsBase exports. The positional method over static matrices is
# the struct's own, which `TransferFunction` calls.
"""
    StateSpace(; A::AbstractMatrix, B::AbstractMatrix, C::AbstractMatrix,
               D::AbstractMatrix = zeros(size(C, 1), size(B, 2)),
               x0 = zeros(size(A, 1))) -> StateSpace

A continuous [primitive](@ref g-primitive) that runs a linear system given in
state-space form.

The [block](@ref g-block) holds one continuous state `q` from `x0`:

    q̇   = A q + B in
    out = C q + D in

The state is an `SVector` at every size. `in` is a `Float64` when `n_u` is one
and an `SVector{n_u, Float64}` otherwise, and `out` likewise by `n_y`.

The type parameter `FT` is the feedthrough class of [`LinearBlock`](@ref), and
`D` picks it. A zero `D` publishes `out` from [stage 1](@ref g-stage-function).
The block then breaks an [algebraic loop](@ref g-algebraic-loop) as the lag
does. A nonzero `D` publishes it from stage 2, so a loop closed on the block
through a memoryless path is refused as `AlgebraicCycle`. The matrices are kept
at `Float64`, and the state and the [ports](@ref g-port) follow the scalar of a
`Dual` [activation](@ref g-activation), so the block linearizes to its own
matrices.

Each matrix is any `AbstractMatrix` of reals, stored at full shape as a static
matrix of `Float64`, so integer entries qualify. A matrix that does not fit the
others is refused as an `ArgumentError`, and so is an `x0` of the wrong length.
An `A` of size zero is refused likewise, since a block with no state is a gain.

# Keywords

- `A`: the `n_x × n_x` state matrix.
- `B`: the `n_x × n_u` input matrix.
- `C`: the `n_y × n_x` output matrix.
- `D`: the `n_y × n_u` direct matrix, zero by default.
- `x0`: the initial state, in the coordinates of `A`, a vector of length `n_x`,
  or a real when `n_x` is one.

See also [`TransferFunction`](@ref), [`DiscretizedStateSpace`](@ref).
"""
struct StateSpace{NX, NU, NY, FT, LA, LB, LC, LD} <: LinearBlock{FT}
    A::SMatrix{NX, NX, Float64, LA}
    B::SMatrix{NX, NU, Float64, LB}
    C::SMatrix{NY, NX, Float64, LC}
    D::SMatrix{NY, NU, Float64, LD}
    x0::SVector{NX, Float64}
end
StateSpace(A::SMatrix{NX, NX, Float64}, B::SMatrix{NX, NU, Float64}, C::SMatrix{NY, NX, Float64},
           D::SMatrix{NY, NU, Float64}, x0::SVector{NX, Float64}) where {NX, NU, NY} =
    StateSpace{NX, NU, NY, !iszero(D), NX * NX, NX * NU, NY * NX, NY * NU}(A, B, C, D, x0)
StateSpace(; A::AbstractMatrix, B::AbstractMatrix, C::AbstractMatrix,
           D::AbstractMatrix = zeros(size(C, 1), size(B, 2)), x0 = zeros(size(A, 1))) =
    StateSpace(static_system(A, B, C, D, x0)...)

# The keyword constructors' matrices and `x0`, checked against each other and
# made static. `DiscreteStateSpace` shares it.
function static_system(A, B, C, D, x0)
    size(A, 1) == 0 && throw(ArgumentError(
        "a state space with no state is a gain, which is written in a stage body, not a block"))
    n_x, n_u, n_y = size(A, 1), size(B, 2), size(C, 1)
    for (name, matrix, shape) in (("A", A, (n_x, n_x)), ("B", B, (n_x, n_u)),
                                  ("C", C, (n_y, n_x)), ("D", D, (n_y, n_u)))
        size(matrix) == shape ||
            throw(ArgumentError("`$name` is $(join(size(matrix), '×')) where $(join(shape, '×')) is needed"))
    end
    x0 isa Real && n_x == 1 || x0 isa AbstractVector && length(x0) == n_x ||
        throw(ArgumentError("`x0` has length $(length(x0)) where `A` asks for $n_x"))
    (SMatrix{n_x, n_x, Float64}(A), SMatrix{n_x, n_u, Float64}(B), SMatrix{n_y, n_x, Float64}(C),
     SMatrix{n_y, n_u, Float64}(D), SVector{n_x, Float64}(x0...))
end
realization(c::StateSpace) = c

"""
    realize(num, den)

The controllable canonical form of the transfer function `num / den`, its
coefficients highest power first and `num` no longer than `den`: the static
matrices `(; A, B, C, D)` of `Float64`, the denominator made monic and the
direct term split off. `linear_blocks.md`, section 2, derives it.
"""
function realize(num, den)
    order = length(den) - 1
    padded = [zeros(order + 1 - length(num)); collect(num)] ./ den[1]
    monic = collect(den) ./ den[1]
    direct = padded[1]
    num_tail = padded[2:end] .- direct .* monic[2:end]    # b̃_{n-1} … b̃_0, the direct term subtracted
    den_tail = monic[2:end]                                # a_{n-1} … a_0
    A = SMatrix{order, order, Float64}([zeros(order - 1) I(order - 1); -reverse(den_tail)'])
    B = SMatrix{order, 1, Float64}([zeros(order - 1); 1])
    C = SMatrix{1, order, Float64}(reverse(num_tail)')
    D = SMatrix{1, 1, Float64}(direct)
    (; A, B, C, D)
end

# Design: §5.3.
# `linear_blocks.md` gives the realization in section 2 and the initial
# condition in section 5.
"""
    TransferFunction(; num, den, u0 = 0.0) -> TransferFunction

A continuous [primitive](@ref g-primitive) that runs a single-input,
single-output linear system given by its transfer function in `s`.

The transfer function is

    G(s) = (num[1] sᵐ + … + num[end]) / (den[1] sⁿ + … + den[end])

with `in` and `out` both `Float64`. The [block](@ref g-block) keeps the
coefficients and holds their realization in controllable canonical form, a
[`StateSpace`](@ref) whose stages it shares.

There is no `x0`, because a realization's state means nothing to a user who
knows only `G(s)`. The block starts at rest, or, with `u0` given, at the steady
state for the constant input `u0`, where `out` is `G(0) u0`.

The type parameter `FT` is the feedthrough class of [`LinearBlock`](@ref), and
the degrees pick it. A numerator of lower degree than the denominator publishes
`out` from [stage 1](@ref g-stage-function). The block then breaks an
[algebraic loop](@ref g-algebraic-loop). One of equal degree publishes it from
stage 2.

# Keywords

- `num`: the numerator's coefficients, highest power first, as a tuple or a
  vector of reals.
- `den`: the denominator's coefficients, highest power first, likewise.
- `u0`: the constant input whose steady state the block starts at, `0.0` for
  rest.

Four spellings are refused as an `ArgumentError`: a denominator of fewer than
two coefficients, whose order of zero makes a gain; a numerator longer than the
denominator, which is improper; a leading denominator coefficient of zero; and
a nonzero `u0` over a denominator whose constant coefficient is zero, a pole at
the origin, which has no steady state.

See also [`DiscreteTransferFunction`](@ref), [`DiscretizedTransferFunction`](@ref).
"""
struct TransferFunction{N, FT, M, K, LA} <: LinearBlock{FT}
    num::NTuple{M, Float64}
    den::NTuple{K, Float64}
    realization::StateSpace{N, 1, 1, FT, LA, N, N, 1}
end
TransferFunction(num::NTuple{M, Float64}, den::NTuple{K, Float64},
                 realization::StateSpace{N, 1, 1, FT, LA}) where {M, K, N, FT, LA} =
    TransferFunction{N, FT, M, K, LA}(num, den, realization)
function TransferFunction(; num, den, u0 = 0.0)
    length(den) < 2 && throw(ArgumentError(
        "a transfer function of order zero is a gain, which is written in a stage body, not a block"))
    length(num) <= length(den) || throw(ArgumentError(
        "`num` has $(length(num)) coefficients where `den` has $(length(den)), an improper transfer function"))
    iszero(first(den)) && throw(ArgumentError("the leading coefficient of `den` is zero"))
    iszero(u0) || !iszero(last(den)) ||
        throw(ArgumentError("`u0` is $u0 where `den` has a pole at the origin, which has no steady state"))
    (; A, B, C, D) = realize(num, den)
    forced = B * SVector(float(u0))
    x0 = iszero(u0) ? zero(forced) : -(A \ forced)
    TransferFunction(Float64.(Tuple(num)), Float64.(Tuple(den)), StateSpace(A, B, C, D, x0))
end
realization(c::TransferFunction) = c.realization

# --- the discrete linear blocks (§13.7, §5.3, D-313) ----------------------------

# Design: §5.3.
# Two accessors serve every stage, defined here once: `held(c)` returns the
# stored system, whose shapes, `C`, `D` and `x0` do not depend on the period,
# and `realization(c, Δt)` returns the update matrices at the period `Δt`. Only
# the update discretizes, so the declarations and the output read `held` alone.
"""
    DiscreteLinearBlock{FT}

The abstract parent of the discrete linear [blocks](@ref g-block), which carries
their stages and their feedthrough class.

The discrete linear blocks are the twins of the [`LinearBlock`](@ref) family on
the discrete [tier](@ref g-tier). `FT` is the feedthrough class, as on
`LinearBlock`, whether the block has [feedthrough](@ref g-feedthrough). It is
`false` when the direct term is zero and `out` comes from
[stage 1](@ref g-stage-function). It is `true` when the direct term is nonzero
and `out` comes from stage 2. The stages are defined once on the parent, so no
discrete linear block declares a stage of its own. Only the state update depends
on the period.

See also [`DiscreteStateSpace`](@ref), [`DiscreteTransferFunction`](@ref),
[`DiscretizedStateSpace`](@ref), [`DiscretizedTransferFunction`](@ref).
"""
abstract type DiscreteLinearBlock{FT} <: AbstractComponent end

s_init(c::DiscreteLinearBlock)  = held(c).x0
u_types(c::DiscreteLinearBlock) = (in = port_type(size(held(c).B, 2)),)
y_types(c::DiscreteLinearBlock) = (out = port_type(size(held(c).C, 1)),)
function s_update(c::DiscreteLinearBlock, (; s, u, Δt))
    (; A, B) = realization(c, Δt)
    A * s + B * as_vector(u.in)
end
y_state(c::DiscreteLinearBlock{false}, (; s)) = (out = as_port(held(c).C * s),)
function y_direct(c::DiscreteLinearBlock{true}, (; s, u))
    (; C, D) = held(c)
    (out = as_port(C * s + D * as_vector(u.in)),)
end

# Design: §5.3, §5.5, §9.4, §10.5, D-263.
# `linear_blocks.md`, section 9, gives the reasoning.
"""
    DiscreteStateSpace(; A::AbstractMatrix, B::AbstractMatrix, C::AbstractMatrix,
                       D::AbstractMatrix = zeros(size(C, 1), size(B, 2)),
                       x0 = zeros(size(A, 1))) -> DiscreteStateSpace

A discrete [primitive](@ref g-primitive) that runs a linear system given in
discrete state-space form.

The [block](@ref g-block) holds one bare [store](@ref g-store) value from `x0`, `q` below,
advanced once per [tick](@ref g-tick):

    q⁺  = A q + B in
    out = C q + D in

The keywords, the shapes, the storage, the [ports](@ref g-port) and the refusals
are those of [`StateSpace`](@ref), and so is the feedthrough class of
[`DiscreteLinearBlock`](@ref). A zero `D` publishes `out` from
[stage 1](@ref g-stage-function). The block then breaks an
[algebraic loop](@ref g-algebraic-loop). A nonzero `D` publishes it from stage
2. The discrete [tier](@ref g-tier) never follows the scalar of an
[activation](@ref g-activation), so under a `Dual` activation the block holds
its last value.

The matrices presuppose the period they were designed at. That period is the
one the block's [rate scope](@ref g-rate-scope) gives it, bound at deployment
after the block is built, so the block cannot check it. A system that should
follow its period is a [`DiscretizedStateSpace`](@ref).
"""
struct DiscreteStateSpace{NX, NU, NY, FT, LA, LB, LC, LD} <: DiscreteLinearBlock{FT}
    A::SMatrix{NX, NX, Float64, LA}
    B::SMatrix{NX, NU, Float64, LB}
    C::SMatrix{NY, NX, Float64, LC}
    D::SMatrix{NY, NU, Float64, LD}
    x0::SVector{NX, Float64}
end
DiscreteStateSpace(A::SMatrix{NX, NX, Float64}, B::SMatrix{NX, NU, Float64}, C::SMatrix{NY, NX, Float64},
                   D::SMatrix{NY, NU, Float64}, x0::SVector{NX, Float64}) where {NX, NU, NY} =
    DiscreteStateSpace{NX, NU, NY, !iszero(D), NX * NX, NX * NU, NY * NX, NY * NU}(A, B, C, D, x0)
DiscreteStateSpace(; A::AbstractMatrix, B::AbstractMatrix, C::AbstractMatrix,
                   D::AbstractMatrix = zeros(size(C, 1), size(B, 2)), x0 = zeros(size(A, 1))) =
    DiscreteStateSpace(static_system(A, B, C, D, x0)...)
held(c::DiscreteStateSpace) = c
realization(c::DiscreteStateSpace, _) = c

"""
    DiscreteTransferFunction(; num, den, u0 = 0.0) -> DiscreteTransferFunction

A discrete [primitive](@ref g-primitive) that runs a single-input, single-output
linear system given by its transfer function in `z`.

The transfer function is

    G(z) = (num[1] zᵐ + … + num[end]) / (den[1] zⁿ + … + den[end])

with the coefficients highest power of `z` first, as [`TransferFunction`](@ref)
takes them in `s`. This is not the `z⁻¹` convention of `filter(b, a)`, which
agrees with it only when the degrees are equal. The [block](@ref g-block) keeps
the coefficients and holds their realization in controllable canonical form, a
[`DiscreteStateSpace`](@ref) whose stages it shares. The degrees pick the
feedthrough class of [`DiscreteLinearBlock`](@ref) as for `TransferFunction`.

The block starts at rest, or, with `u0` given, at the steady state for the
constant input `u0`, where `(I - A) q = B u0` and `out` is `G(1) u0`.

The keywords and the refusals are those of `TransferFunction`, save that the
pole with no steady state is at `z = 1`. A nonzero `u0` is refused as an
`ArgumentError` over a denominator whose coefficients sum to zero within `1e-12`
of the sum of their magnitudes, since a designed denominator such as
`(1, -0.7, -0.3)` misses an exact zero by rounding.

The coefficients presuppose the period they were designed at, which the block
cannot check, as for `DiscreteStateSpace`.

See also [`DiscretizedTransferFunction`](@ref).
"""
struct DiscreteTransferFunction{N, FT, M, K, LA} <: DiscreteLinearBlock{FT}
    num::NTuple{M, Float64}
    den::NTuple{K, Float64}
    realization::DiscreteStateSpace{N, 1, 1, FT, LA, N, N, 1}
end
function DiscreteTransferFunction(; num, den, u0 = 0.0)
    length(den) < 2 && throw(ArgumentError(
        "a transfer function of order zero is a gain, which is written in a stage body, not a block"))
    length(num) <= length(den) || throw(ArgumentError(
        "`num` has $(length(num)) coefficients where `den` has $(length(den)), an improper transfer function"))
    iszero(first(den)) && throw(ArgumentError("the leading coefficient of `den` is zero"))
    monic = collect(den) ./ first(den)
    iszero(u0) || abs(sum(monic)) > 1e-12 * sum(abs, monic) ||
        throw(ArgumentError("`u0` is $u0 where `den` has a pole at `z = 1`, which has no steady state"))
    (; A, B, C, D) = realize(num, den)
    forced = B * SVector(float(u0))
    x0 = iszero(u0) ? zero(forced) : (I - A) \ forced
    DiscreteTransferFunction(Float64.(Tuple(num)), Float64.(Tuple(den)), DiscreteStateSpace(A, B, C, D, x0))
end
held(c::DiscreteTransferFunction) = c.realization
realization(c::DiscreteTransferFunction, _) = c.realization

# Design: §9.4, §10.5, D-263.
# `linear_blocks.md`, section 9.2, gives the reasoning.
"""
    DiscretizedStateSpace(continuous::StateSpace) -> DiscretizedStateSpace
    DiscretizedStateSpace(; A::AbstractMatrix, B::AbstractMatrix, C::AbstractMatrix,
                          D::AbstractMatrix = zeros(size(C, 1), size(B, 2)),
                          x0 = zeros(size(A, 1))) -> DiscretizedStateSpace

A discrete [primitive](@ref g-primitive) that runs a continuous state-space
system through a zero-order hold at each [tick](@ref g-tick).

The [block](@ref g-block) runs the [`StateSpace`](@ref) `continuous`, or the one
its keywords build, on the discrete [tier](@ref g-tier). At each tick it takes
the zero-order hold

    A_d = e^{A Δt}        B_d = (∫₀^Δt e^{Aτ} dτ) B

with `C` and `D` unchanged. `A_d` and `B_d` are the top row of one exponential
of the augmented matrix `[A B; 0 0] Δt`. The hold is exact for an input held
constant over each period, so the samples are the continuous system's own.

`Δt` is the component's own period, so the block follows the rate its
[rate scope](@ref g-rate-scope) gives it, and carries no period of its own,
where a [`DiscreteStateSpace`](@ref) presupposes one. The keywords and their
refusals are those of `StateSpace`. The feedthrough class, the
[ports](@ref g-port) and `x0` are the continuous block's, `x0` in its
coordinates. The discrete tier never follows the scalar of an
[activation](@ref g-activation), so under a `Dual` activation the block holds
its last value.

See also [`DiscretizedTransferFunction`](@ref), [`DiscreteLinearBlock`](@ref).
"""
struct DiscretizedStateSpace{NX, NU, NY, FT, LA, LB, LC, LD} <: DiscreteLinearBlock{FT}
    continuous::StateSpace{NX, NU, NY, FT, LA, LB, LC, LD}
end
DiscretizedStateSpace(; kwargs...) = DiscretizedStateSpace(StateSpace(; kwargs...))
held(c::DiscretizedStateSpace) = c.continuous
# Assembled by `vcat` and `hcat`: the bracket spelling goes through a static
# `hvcat` that allocates on every call.
function realization(c::DiscretizedStateSpace{NX, NU}, Δt) where {NX, NU}
    (; A, B, C, D) = c.continuous
    augmented = vcat(hcat(A, B), hcat(zeros(SMatrix{NU, NX, Float64}), zeros(SMatrix{NU, NU, Float64})))
    exponential = exp(augmented * Δt)
    (; A = exponential[SOneTo(NX), SOneTo(NX)], B = exponential[SOneTo(NX), SUnitRange(NX + 1, NX + NU)], C, D)
end

# Design: §10.5.
# `linear_blocks.md`, section 9.2, gives the reasoning.
"""
    DiscretizedTransferFunction(; num, den, u0 = 0.0) -> DiscretizedTransferFunction

A discrete [primitive](@ref g-primitive) that runs a continuous transfer
function through a zero-order hold at each [tick](@ref g-tick).

The [block](@ref g-block) takes the transfer function in `s` of
[`TransferFunction`](@ref), with its keywords, its refusals and its start at
rest or at `G(0) u0`. It runs it on the discrete [tier](@ref g-tier) through the
zero-order hold of [`DiscretizedStateSpace`](@ref). The hold is taken at each
tick. It spans `Δt`, the component's own period. The block keeps the
coefficients and holds the realization wrapped for the hold, and the degrees
pick the feedthrough class of [`DiscreteLinearBlock`](@ref) as for
`TransferFunction`.

The hold keeps the feedthrough class and matches the step response at the
samples, where Tustin's method would give every block
[feedthrough](@ref g-feedthrough). A design that wants Tustin's frequency
response discretizes externally and uses [`DiscreteTransferFunction`](@ref).
"""
struct DiscretizedTransferFunction{N, FT, M, K, LA} <: DiscreteLinearBlock{FT}
    num::NTuple{M, Float64}
    den::NTuple{K, Float64}
    realization::DiscretizedStateSpace{N, 1, 1, FT, LA, N, N, 1}
end
function DiscretizedTransferFunction(; num, den, u0 = 0.0)
    continuous = TransferFunction(; num, den, u0)
    DiscretizedTransferFunction(continuous.num, continuous.den, DiscretizedStateSpace(continuous.realization))
end
held(c::DiscretizedTransferFunction) = held(c.realization)
realization(c::DiscretizedTransferFunction, Δt) = realization(c.realization, Δt)

# --- the step (§2.3, §10.4, D-313) ----------------------------------------------

# Design: §2.3, §10.6, D-179, D-312.
"""
    Step(; t_step, before = 0.0, after = 1.0, localized::Bool = true) -> Step

A continuous [primitive](@ref g-primitive) that publishes one value before a
given time and another from then on.

`out` publishes `before` until `t_step` and `after` from then on. The
[block](@ref g-block) is a mode-only primitive with no inputs. Its one bare mode, `fired`
below, picks the value, and one [state event](@ref g-state-event), `fire`, sets it once
`t` reaches `t_step`. `out` is [pinned](@ref g-walked) at `V`. The value depends
on neither state nor an input that follows the scalar, so it carries zero
partials under every [activation](@ref g-activation), as a [`Constant`](@ref)'s
does.

`localized` picks the detection policy. [Localized](@ref g-localized), the
[guard](@ref g-guard) is the sign form `t - t_step`: the step ends at the
crossing and the jump lands there.
[Boundary-detected](@ref g-boundary-detected), the guard is the `Bool`
`t ≥ t_step`. The event then fires at the end of the step in which it was first
observed, so the jump lands on the first [boundary](@ref g-boundary) at or after
`t_step`, never inside a step. The policy is the type parameter `L` rather than
a field because the build reads it off the guard's return type.

[Boundary zero](@ref g-boundary-zero) sets every [prior](@ref g-prior) to
not-holding. A `t_step` at or before `t₀` therefore fires there, and `out`
publishes `after` from the start.

# Keywords

- `t_step`: the time of the step, any time.
- `before`: the value before `t_step`.
- `after`: the value from `t_step` on. `before` and `after` are promoted to one
  `V`, `Float64` or a static array of `Float64`, and taken by `float`, so
  integer values qualify.
- `localized`: `true` for a localized step, `false` for a boundary-detected one.
"""
struct Step{V <: Union{Real, StaticArray{<:Tuple, <:Real}}, L} <: AbstractComponent
    before::V
    after::V
    t_step::Float64
end
function Step(; t_step, before = 0.0, after = 1.0, localized::Bool = true)
    before, after = float.(promote(before, after))
    Step{typeof(before), localized}(before, after, t_step)
end
x_init(::Step) = nothing
m_init(::Step) = false                                           # fired
y_types(::Step{V}) where {V} = (out = Pinned{V},)
y_state(c::Step, (; m)) = (out = m ? c.after : c.before,)
step_guard(c::Step{V, true}, (; t)) where {V} = t - c.t_step     # sign form: localized
step_guard(c::Step{V, false}, (; t)) where {V} = t >= c.t_step   # Bool form: boundary-detected
step_handler(::Step, _) = (m = true,)
state_events(::Step) = (fire = StateEvent(step_guard, step_handler),)

# --- the moded blocks (§10.4, §10.6, D-313) -------------------------------------

# The port type of a per-channel value of type `T` over `V`: one `T` per
# component. A saturation code is one `Int8` per component.
channel_type(::Type{V}, ::Type{T}) where {V <: Real, T} = T
channel_type(::Type{V}, ::Type{T}) where {V <: StaticArray, T} = similar_type(V, T)
saturation_type(::Type{V}) where {V} = channel_type(V, Int8)

# Design: §2.3, §10.4, §10.6, D-179.
# `limited_integrator_variants.md` gives the reasoning.
"""
    LimitedIntegrator(; lower, upper, x0 = zero(lower), localized::Bool = true) -> LimitedIntegrator

A continuous [primitive](@ref g-primitive) that publishes the time integral of
its input, held between two limits.

The [block](@ref g-block) holds one continuous state `q`, with `q̇ = in` while
free and `q̇ = 0` while saturated, and `out` publishes `q` from
[stage 1](@ref g-stage-function). It is not a clamp. The bare mode, `saturation`
below, is read by the derivative, and four [state events](@ref g-state-event) move
it. It
is a signed `Int8` code, the sign of the limit in force: `-1` at `lower`, `0`
free and `+1` at `upper`. `hit_upper` and `hit_lower` fire when `q` reaches a
limit, and their handlers write `q` to the limit exactly and saturate.
`leave_upper` and `leave_lower` fire when `in` turns strictly back into the
range, and free it. An input of exactly zero at a limit keeps the mode
saturated. The hit events are [localized](@ref g-localized).

A second output, also `saturation`, publishes the code from stage 1, so it has
no [feedthrough](@ref g-feedthrough). It serves an anti-windup consumer, such as
a controller that gates its integrator on the code. The code flips only when an
event fires, and so only on a declared [boundary](@ref g-boundary).

`localized` picks the detection policy of the leave events. Localized, the
[guards](@ref g-guard) are sign forms gated by the mode, and the departure ends
the step at the input's zero crossing.
[Boundary-detected](@ref g-boundary-detected), the guards are the `Bool`
[predicates](@ref g-predicate). The departure then fires at the end of the step
in which `in` first pointed back into the range, so `q` is held on the limit for
the rest of that step. It carries an offset of at most `a h² / 2` from then on,
`a` the input's slope at its zero crossing. What the cheap form buys is that a
departure costs no root-finding and splits no step, where a localized one pays
about 22 trial [sweeps](@ref g-sweep) and a boundary. The policy is the type
parameter `L` rather than a field because the build reads it off the guard's
return type.

Over a static vector, the limits and the codes are componentwise, and
`saturation` publishes a static vector of `Int8`. The block declares `N` copies
of the scalar events, one per component, named `hit_upper_1` to `hit_upper_N`,
then `hit_lower_i`, `leave_upper_i` and `leave_lower_i`. Each guard reads its
one component and each handler writes it.

[Boundary zero](@ref g-boundary-zero) sets every [prior](@ref g-prior) to
not-holding. An `x0` outside the limits is therefore clamped there, and the
initial mode agrees with the initial input.

# Keywords

- `lower`: the lower limit, below `upper`, componentwise over a vector.
- `upper`: the upper limit.
- `x0`: the initial value of `q`. `x0`, `lower` and `upper` are promoted to one
  `V`, which is `Float64` or a static array of `Float64`, and taken by `float`,
  so integer values qualify.
- `localized`: `true` for localized leave events, `false` for boundary-detected
  ones.

See also [`DiscreteLimitedIntegrator`](@ref), [`Integrator`](@ref).
"""
struct LimitedIntegrator{V <: Union{Real, StaticArray{<:Tuple, <:Real}}, L} <: AbstractComponent
    x0::V
    lower::V
    upper::V
end
function LimitedIntegrator(; lower, upper, x0 = zero(lower), localized::Bool = true)
    x0, lower, upper = float.(promote(x0, lower, upper))
    LimitedIntegrator{typeof(x0), localized}(x0, lower, upper)
end
x_init(c::LimitedIntegrator) = c.x0
m_init(c::LimitedIntegrator) = Int8.(zero(c.x0))    # the saturation: -1 lower, 0 free, +1 upper
u_types(::LimitedIntegrator{V}) where {V} = (in = V,)
y_types(::LimitedIntegrator{V}) where {V} = (out = V, saturation = saturation_type(V))
y_state(::LimitedIntegrator, (; x, m)) = (out = x, saturation = m)
x_deriv(::LimitedIntegrator, (; u, m)) = ifelse.(m .== 0, u.in, zero(u.in))
# The hit guards are not gated by the free code on purpose. Gated, a hit guard
# would read `0` the instant a leave handler frees the mode, present a fresh
# edge and saturate the block again.
hit_upper_guard(c::LimitedIntegrator, (; x)) = x - c.upper
hit_lower_guard(c::LimitedIntegrator, (; x)) = c.lower - x
# The leave guards gate on strictly inward input. Gated on the mode alone, an
# input of exactly zero reads `-0.0`, which holds, and frees the mode with `q`
# on the limit. The gate `u.in < 0` reads a wired signal, so §10.4's argument
# that gates stay fixed through a localization does not cover it: σ jumps from
# `-1` to a small positive value at the input's zero crossing. The bracket still
# converges on that crossing, since only the sign drives it, but ITP falls back
# to bisection's count, about 15 extra interior sweeps per leave.
leave_upper_guard(::LimitedIntegrator{V, true}, (; m, u)) where {V} =
    m == 1 && u.in < 0 ? -u.in : -one(u.in)
leave_lower_guard(::LimitedIntegrator{V, true}, (; m, u)) where {V} =
    m == -1 && u.in > 0 ? u.in : -one(u.in)
# The `Bool` forms are the same predicates, boundary-detected and strict by
# construction.
leave_upper_guard(::LimitedIntegrator{V, false}, (; m, u)) where {V} =
    m == 1 && u.in < 0
leave_lower_guard(::LimitedIntegrator{V, false}, (; m, u)) where {V} =
    m == -1 && u.in > 0
hit_upper_handler(c::LimitedIntegrator, _) = (x = c.upper, m = Int8(1))
hit_lower_handler(c::LimitedIntegrator, _) = (x = c.lower, m = Int8(-1))
leave_handler(::LimitedIntegrator, _) = (m = Int8(0),)
state_events(::LimitedIntegrator{V}) where {V <: Real} =
    (hit_upper = StateEvent(hit_upper_guard, hit_upper_handler),
     hit_lower = StateEvent(hit_lower_guard, hit_lower_handler),
     leave_upper = StateEvent(leave_upper_guard, leave_handler),
     leave_lower = StateEvent(leave_lower_guard, leave_handler))
# The events are per component, not reductions over the vector, so the scalar
# reasoning holds component by component. A reduced hit guard holds for good
# once one component sits clamped on its limit, so a second arrival makes no
# edge, and gating it by the mode brings back the re-saturation above.
function state_events(::LimitedIntegrator{V, L}) where {V <: StaticArray, L}
    N = length(V)
    hit_upper = ntuple(N) do i
        StateEvent((c, (; x)) -> x[i] - c.upper[i],
                   (c, (; x, m)) -> (x = Base.setindex(x, c.upper[i], i),
                                     m = Base.setindex(m, Int8(1), i)))
    end
    hit_lower = ntuple(N) do i
        StateEvent((c, (; x)) -> c.lower[i] - x[i],
                   (c, (; x, m)) -> (x = Base.setindex(x, c.lower[i], i),
                                     m = Base.setindex(m, Int8(-1), i)))
    end
    leave_upper = ntuple(N) do i
        guard = L ? ((c, (; m, u)) -> m[i] == 1 && u.in[i] < 0 ? -u.in[i] : -one(u.in[i])) :
                    ((c, (; m, u)) -> m[i] == 1 && u.in[i] < 0)
        StateEvent(guard, (c, (; m)) -> (m = Base.setindex(m, Int8(0), i),))
    end
    leave_lower = ntuple(N) do i
        guard = L ? ((c, (; m, u)) -> m[i] == -1 && u.in[i] > 0 ? u.in[i] : -one(u.in[i])) :
                    ((c, (; m, u)) -> m[i] == -1 && u.in[i] > 0)
        StateEvent(guard, (c, (; m)) -> (m = Base.setindex(m, Int8(0), i),))
    end
    names = (ntuple(i -> Symbol(:hit_upper_, i), N)..., ntuple(i -> Symbol(:hit_lower_, i), N)...,
             ntuple(i -> Symbol(:leave_upper_, i), N)..., ntuple(i -> Symbol(:leave_lower_, i), N)...)
    NamedTuple{names}((hit_upper..., hit_lower..., leave_upper..., leave_lower...))
end

# Design: §5.3, §10.4, §10.6, D-312.
"""
    Relay(; lower, upper, off = zero(lower), on = one.(lower)) -> Relay

A continuous [primitive](@ref g-primitive) that publishes one of two values,
switched by its input with hysteresis.

`out` publishes `off` or `on` by the bare mode, `state` below, from
[stage 1](@ref g-stage-function). The mode is an `Int8` code, `0` off and `1`
on. Two [state events](@ref g-state-event) move it. `switch_on` fires when `in`
rises to `upper` while off, and `switch_off` when `in` falls to `lower` while
on. Both [guards](@ref g-guard) are sign forms gated by the mode, so both are
[localized](@ref g-localized).

`out` reads no input, so the [block](@ref g-block) has no
[feedthrough](@ref g-feedthrough). A relay closing a feedback loop therefore
makes no [algebraic loop](@ref g-algebraic-loop). It is the library's reference
mode-switching primitive. `out` is [pinned](@ref g-walked) at `V`. It depends on
the mode and the instance alone, so it carries zero partials under every
[activation](@ref g-activation).

Over a static vector, the thresholds, the values and the codes are
componentwise. The block declares `N` copies of the two events, one per
component, named `switch_on_1` to `switch_on_N`, then `switch_off_i`. Each
guard reads its one component and each handler writes it.

The relay starts off. [Boundary zero](@ref g-boundary-zero) sets every
[prior](@ref g-prior) to not-holding. An input already at or above `upper` at
`t₀` therefore turns the relay on there, and an input between the thresholds
leaves it off, which is the hysteresis itself.

# Keywords

- `lower`: the threshold `in` falls to for the relay to switch off, below
  `upper`.
- `upper`: the threshold `in` rises to for the relay to switch on.
- `off`: the value `out` publishes while off.
- `on`: the value `out` publishes while on. The four values are promoted to one
  `V`, which is `Float64` or a static array of `Float64`, and taken by `float`,
  so integer values qualify.
"""
struct Relay{V <: Union{Real, StaticArray{<:Tuple, <:Real}}} <: AbstractComponent
    lower::V      # switch off when `in` falls to it
    upper::V      # switch on when `in` rises to it
    off::V        # `out` while off
    on::V         # `out` while on
end
Relay(; lower, upper, off = zero(lower), on = one.(lower)) =
    Relay(float.(promote(lower, upper, off, on))...)
x_init(::Relay) = nothing
m_init(c::Relay) = Int8.(zero(c.lower))    # the state: 0 off, 1 on
u_types(::Relay{V}) where {V} = (in = V,)
y_types(::Relay{V}) where {V} = (out = Pinned{V},)
y_state(c::Relay, (; m)) = (out = ifelse.(m .== 1, c.on, c.off),)
switch_on_guard(c::Relay, (; m, u)) = m == 0 ? u.in - c.upper : -one(u.in)
switch_off_guard(c::Relay, (; m, u)) = m == 1 ? c.lower - u.in : -one(u.in)
switch_on_handler(::Relay, _) = (m = Int8(1),)
switch_off_handler(::Relay, _) = (m = Int8(0),)
state_events(::Relay{V}) where {V <: Real} =
    (switch_on = StateEvent(switch_on_guard, switch_on_handler),
     switch_off = StateEvent(switch_off_guard, switch_off_handler))
function state_events(::Relay{V}) where {V <: StaticArray}
    N = length(V)
    switch_on = ntuple(N) do i
        StateEvent((c, (; m, u)) -> m[i] == 0 ? u.in[i] - c.upper[i] : -one(u.in[i]),
                   (c, (; m)) -> (m = Base.setindex(m, Int8(1), i),))
    end
    switch_off = ntuple(N) do i
        StateEvent((c, (; m, u)) -> m[i] == 1 ? c.lower[i] - u.in[i] : -one(u.in[i]),
                   (c, (; m)) -> (m = Base.setindex(m, Int8(0), i),))
    end
    names = (ntuple(i -> Symbol(:switch_on_, i), N)..., ntuple(i -> Symbol(:switch_off_, i), N)...)
    NamedTuple{names}((switch_on..., switch_off...))
end

# --- the controller (§13.7, §5.4, D-313) ----------------------------------------

"""
    AsPort() -> AsPort

The marker that makes a controller's parameter an input [port](@ref g-port) of
the [block](@ref g-block) in place of a field.

A controller keyword takes it as its value, as in `PID(Kp = AsPort(), Ki = 0.5)`.
The port is named for the parameter and typed as the field would be, and it
takes no part in the keywords' shape or sizes.

See also [`PID`](@ref), [`DiscretePID`](@ref), [`LQRTracker`](@ref),
[`DiscreteLQRTracker`](@ref).
"""
struct AsPort end

# The PID's parameters, in the order `Fixed` and `parameters` lay them out.
const PID_PARAMETERS = (:Kp, :Ki, :Kd, :τd, :Tt, :u_min, :u_max, :b, :c)

"""
    ControllerBlock{Hold, Track}

The abstract parent of the controller [blocks](@ref g-block), which carries
their two anti-windup axes.

`ControllerBlock` subtypes `AbstractComponent`, and the two controller
families, [`PIDBlock`](@ref) and [`LQRTrackerBlock`](@ref), subtype it. Its two
parameters are the anti-windup axes, each adding inputs at the block's output
shape: `Hold` the code `saturation` and the flag `engaged`, `Track` the
reference `v`. Each block's law moves its integral term through two slots: `ε`,
its integrator's input `e` as the axes pass it, and `ref`, the correction's
reference. They are filled channel by channel over the channel's condition:

| condition      | `ε`       | `ref`, `Track = false` | `ref`, `Track = true` |
|:-------------- |:--------- |:---------------------- |:--------------------- |
| `Hold = false` | `e`       | `u`                    | `v`                   |
| free           | `e`       | `u`                    | `u`                   |
| limited        | `gate(e)` | `u`                    | `v`                   |
| not engaged    | `0`       | `u`                    | `v`                   |

A channel is free with a zero code while engaged, limited with a nonzero code
while engaged, and not engaged while its `engaged` is false, which takes
precedence over the code. `gate(e) = saturation == sign(e) ? 0 : e`.

The parent carries what reads the axes alone: the axis [ports](@ref g-port), the
gate on the integrator's input and the correction's reference. Each family
carries its signal ports, its parameters and its blocks' stages.
"""
abstract type ControllerBlock{Hold, Track} <: AbstractComponent end

# The axis ports in the order `saturation`, `engaged`, `v`, at the code's type,
# the flag's and the tracking input's.
axis_ports(::ControllerBlock{Hold, Track}, code_type, flag_type, value_type) where {Hold, Track} =
    merge(Hold ? (saturation = code_type, engaged = flag_type) : (;), Track ? (v = value_type,) : (;))
# The gate tests the sign, not `saturation != 0`: integration resumes once the
# error points back into the range, while the path still reports saturation.
# The `.!= 0` in front leaves a free channel's zero error ungated, so the
# derivative at an equilibrium does not depend on how `sign` orders a
# zero-valued `Dual`. Not engaged, the error is gated off whatever the code. A
# broadcast `ifelse` selects per channel, over a scalar flag or a vector one.
gated_error(::ControllerBlock{false}, e, u) = e
gated_error(::ControllerBlock{true}, e, u) =
    ifelse.(u.engaged .&& .!(u.saturation .!= 0 .&& u.saturation .== sign.(e)), e, zero(e))
# With a hold, `v` is the reference only while the channel is not free. Tracking
# is what to converge to while the path cannot follow or another block flies the
# plant; on a free path it would only couple the integrator to the transients
# downstream.
correction_reference(::ControllerBlock{Hold, false}, u, y) where {Hold} = y.u
correction_reference(::ControllerBlock{false, true}, u, y) = u.v
correction_reference(::ControllerBlock{true, true}, u, y) =
    ifelse.(u.engaged .&& u.saturation .== 0, y.u, u.v)

# Design: The parameter order is the roster `PID_PARAMETERS`.
"""
    PIDBlock{V, Hold, Track, Fixed}

The abstract parent of the two PID [blocks](@ref g-block), which carries their
shared [ports](@ref g-port), outputs and parameters.

The two blocks are [`PID`](@ref) on the continuous [tier](@ref g-tier) and
[`DiscretePID`](@ref) on the discrete one. `PIDBlock` is a
[`ControllerBlock`](@ref) over the two anti-windup axes. It carries what their
law shares past the gate and the reference: the ports picked by the axes and by
the scheduled parameters, the outputs and the parameters' fetch. Each block
carries its field `fixed`, its [store](@ref g-store) and its stages.

`V` is the type of the parameters and the signals, a `Real` or a static array
of them. `Fixed` is the `NamedTuple` type of the parameters given as values, in
the order `Kp`, `Ki`, `Kd`, `τd`, `Tt`, `u_min`, `u_max`, `b`, `c`.
"""
abstract type PIDBlock{V, Hold, Track, Fixed} <: ControllerBlock{Hold, Track} end

# The methods both blocks share live here: `signal_ports`, `u_types`, `y_types`
# and the parameters' fetch. `DiscretePID` adds its code to `y_types`.
signal_ports(c::PIDBlock{V}) where {V} =
    merge((r = V, y = V), axis_ports(c, saturation_type(V), channel_type(V, Bool), V))
function u_types(c::PIDBlock{V, Hold, Track, Fixed}) where {V, Hold, Track, Fixed}
    scheduled = filter(∉(fieldnames(Fixed)), PID_PARAMETERS)
    merge(signal_ports(c), NamedTuple{scheduled}(ntuple(_ -> V, length(scheduled))))
end
y_types(::PIDBlock{V}) where {V} = (u = V, u_raw = V)
# The nine parameters in roster order, each from the field or from its port.
# No port name is a parameter name, so the whole input bundle merges.
parameters(c::PIDBlock, u) = NamedTuple{PID_PARAMETERS}(merge(c.fixed, u))

# The type of the PID's shape, the sum of the `zero`s of the keywords given as
# values; `AsPort()` keywords take no part.
function shape_type(given)
    fixed_names = filter(name -> given[name] !== AsPort(), keys(given))
    typeof(Float64.(reduce((a, b) -> a .+ b, map(name -> zero(given[name]), fixed_names); init = 0.0)))
end

# The keywords given as values, each broadcast against the zero of its type in
# `types` and made one, in roster order; `AsPort()` keywords are left out. Every
# PID parameter's type is the shape's, and the tracker's follow its sizes.
function fixed_parameters(given::NamedTuple{names}, types::NamedTuple{names}) where {names}
    fixed_names = filter(name -> given[name] !== AsPort(), names)
    NamedTuple{fixed_names}(map(name -> types[name](given[name] .+ zero(types[name])), fixed_names))
end

# Tracking follows `v` at rate `1/Tt`, so a `Tt` given infinite in any channel
# would follow nothing; a scheduled `Tt` is the model's to keep finite.
function check_tracking(tracking, Tt)
    tracking && Tt !== AsPort() && any(isinf, Tt) && throw(ArgumentError(
        "`tracking = true` follows `v` at rate `1/Tt`, which an infinite `Tt` switches off; " *
        "give `Tt` finite in every channel, or as `AsPort()`"))
    nothing
end

# Design: §5.4.
# `pid_anti_windup.md` gives the reasoning, its section 4 the two axes and its
# section 11 standby.
"""
    PID(; Kp, Ki = 0.0, Kd = 0.0, τd = 0.1, Tt = Inf, u_min = -Inf, u_max = Inf,
          b = 1.0, c = 0.0, hold::Bool = false, tracking::Bool = false) -> PID

A continuous [primitive](@ref g-primitive) that runs a PID controller with
anti-windup.

The inputs are `r` and `y`, with the error `e = r - y`. The two outputs come
from [stage 2](@ref g-stage-function):
`u_raw = Kp (b r - y) + q - Kd (w - yf) / τd`, and `u`, its clamp to
`[u_min, u_max]`. The [block](@ref g-block) holds two continuous states: `q`,
the integral term, and `yf`, the weighted measurement `w = y - c r` through a
lag, `ẏf = (w - yf) / τd`. One law moves the integral term,

    q̇ = Ki ε + (ref - u_raw) / Tt

and two independent type parameters, each adding inputs, fill its slots `ε` and
`ref` over the error `e` by the table of [`ControllerBlock`](@ref).

`hold = true`, the parameter `Hold`, adds two inputs. `saturation` is an `Int8`
code such as a [`LimitedIntegrator`](@ref) publishes for the path downstream,
and gates the error by sign: `gate(e) = saturation == sign(e) ? 0 : e`.
`engaged` is a `Bool` that reads true while the block is in command; not
engaged, the error is gated to zero whatever the code. Without tracking, a
block not engaged freezes: `q` holds while the own clamp is free and
back-calculates against it otherwise.

`tracking = true`, the parameter `Track`, adds the input `v`, a value the path
delivered or the selected command, as the correction's reference in place of the
own `u`. With the hold, `v` is the reference only while the block is limited or
not engaged, and `u` while it is free, so a block not in command follows the
selected command at rate `1/Tt` and engages without a bump. It chases a moving
`v` with lag `Tt`, so a block out of command wants a short `Tt`. The default
`Tt = Inf` follows nothing, so `tracking = true` with a `Tt` given as a value and
infinite in any channel is refused as an `ArgumentError`: tracking needs `Tt`
spelled, or given as `AsPort()`, which leaves it to the model to keep finite.

`q` holds the integral term in output units, with `Ki` inside the integral, so
a change in `Ki` alters only future accumulation. The setpoint weights `b` and
`c` multiply `r` alone, `b` in the proportional term and `c` in the derivative's
weighted measurement, and the integral's error stays `e`. Their defaults, `b = 1`
and `c = 0`, put the derivative on the measurement, so a step in `r` makes no
kick; `c = 1` puts it on the error. The defaults make the plain spelling a P
controller: `Ki = Kd = 0`, `Tt = Inf`, which switches the correction off, and
infinite limits.

`V` is `Float64` or a static array of `Float64`. Over a static vector the law
is componentwise: the parameters, `r`, `y`, `v`, the outputs and the states are
each a `V`, and `saturation` and `engaged` are static vectors of `Int8` and of
`Bool`. The nine keywords given as values broadcast to one `V`, whose shape is
the sum of their `zero`s, so a scalar pairs with a vector and integer values
qualify. A vector PID with uniform gains spells at least one keyword as a
vector, `Kp = @SVector fill(2.0, 3)`.

Any of the nine parameters may be an input [port](@ref g-port) in place of a
field, spelled `Kp = AsPort()` with [`AsPort`](@ref). The port is named for the
parameter and typed `V`, and it takes no part in the shape, so when every
value-carrying keyword is a port, `V` is `Float64`. Under a `Dual`
[activation](@ref g-activation), a scheduled parameter carries partials, so a
linearization sees the coupling through the schedule. A model that wants it
frozen at its plain `Float64` value routes the port through [`Freeze`](@ref).

`u` is a stage-2 output, so every input makes a
[feedthrough](@ref g-feedthrough) edge, whether `y_direct` reads it or not. A
tracking input wired from a memoryless clamp of the block's own `u` is refused
as an `AlgebraicCycle` classified [artificial](@ref g-algebraic-loop). That is
why the limits live inside the block. `v` serves a value published from state,
such as a stateful actuator's position. A scheduled parameter computed
memorylessly from `u` closes a cycle too, artificial for `Ki` and `Tt`, which
only the derivative reads, and real for the others. One read from a state is
fine.

# Keywords

- `Kp`: the proportional gain.
- `Ki`: the integral gain, inside the integral.
- `Kd`: the derivative gain.
- `τd`: the time constant of the derivative's lag, positive.
- `Tt`: the time constant of the correction, `Inf` to switch it off.
- `u_min`: the lower limit of `u`.
- `u_max`: the upper limit of `u`.
- `b`: the setpoint weight in the proportional term.
- `c`: the setpoint weight in the derivative's weighted measurement.
- `hold`: `true` to add the inputs `saturation` and `engaged`, the parameter
  `Hold`.
- `tracking`: `true` to add the input `v`, the parameter `Track`.

See also [`DiscretePID`](@ref), [`PIDBlock`](@ref), [`LQRTracker`](@ref).
"""
struct PID{V <: Union{Real, StaticArray{<:Tuple, <:Real}}, Hold, Track, Fixed} <:
       PIDBlock{V, Hold, Track, Fixed}
    fixed::Fixed      # the parameters that are not ports, each a `V`, in roster order
end
function PID(; Kp, Ki = 0.0, Kd = 0.0, τd = 0.1, Tt = Inf, u_min = -Inf, u_max = Inf, b = 1.0, c = 0.0,
             hold::Bool = false, tracking::Bool = false)
    check_tracking(tracking, Tt)
    given = (; Kp, Ki, Kd, τd, Tt, u_min, u_max, b, c)
    V = shape_type(given)
    fixed = fixed_parameters(given, map(_ -> V, given))
    PID{V, hold, tracking, typeof(fixed)}(fixed)
end

x_init(::PID{V}) where {V} = (q = zero(V), yf = zero(V))
function y_direct(c::PID, (; x, u))
    p = parameters(c, u)
    w = u.y - p.c .* u.r
    u_raw = p.Kp .* (p.b .* u.r - u.y) + x.q - p.Kd .* (w - x.yf) ./ p.τd
    (u = clamp.(u_raw, p.u_min, p.u_max), u_raw = u_raw)
end
function x_deriv(c::PID, (; x, u, y))
    p = parameters(c, u)
    (q  = p.Ki .* gated_error(c, u.r - u.y, u) + (correction_reference(c, u, y) - y.u_raw) ./ p.Tt,
     yf = (u.y - p.c .* u.r - x.yf) ./ p.τd)
end

# Design: §10.5, §13.8.
# `pid_anti_windup.md`, sections 9 to 11, gives the reasoning.
"""
    DiscretePID(; Kp, Ki = 0.0, Kd = 0.0, τd = 0.1, Tt = Inf, u_min = -Inf, u_max = Inf,
                  b = 1.0, c = 0.0, hold::Bool = false, tracking::Bool = false) -> DiscretePID

A discrete [primitive](@ref g-primitive) that runs a PID controller with
anti-windup.

The [block](@ref g-block) takes the parameters, defaults, [ports](@ref g-port)
and law of [`PID`](@ref) to the discrete [tier](@ref g-tier). Two
[store](@ref g-store) fields stand in for its continuous states: `q`, the
integral term, and `yf`, the weighted measurement `w = y - c r` through a lag. A
third, `saturated`, holds its code. `Δt` is the component's own period. The
inputs are `r` and `y`, with the error `e = r - y`. The two outputs come from
[stage 2](@ref g-stage-function):
`u_raw = Kp (b r - y) + q - Kd (w - yf) / (τd + Δt)`, and `u`, its clamp to
`[u_min, u_max]`. Each [tick](@ref g-tick) moves the lag by backward Euler,
`yf⁺ = yf + Δt (w - yf) / (τd + Δt)`, and the integral term by forward Euler
and the correction's exact step,

    q⁺ = q + Δt Ki ε + β (ref - u_raw),    β = 1 - exp(-Δt / Tt)

with its slots `ε` and `ref` filled over the two anti-windup axes by the table
of [`ControllerBlock`](@ref).

`hold` adds the inputs `saturation` and `engaged`, and a block not engaged
without tracking freezes. `tracking` adds the input `v`. `tracking = true` with
a `Tt` given infinite in any channel is refused as an `ArgumentError`. With the
hold, the reference falls back to `u` while the block is free. All of this is
as in `PID`. The setpoint weights `b` and `c` multiply `r` alone, as in `PID`,
and the integral's error stays `e`.

`V` is `Float64` or a static array of `Float64`, and over a static vector the
law is componentwise, as in `PID`. The nine keywords given as values broadcast
to one `V` by the rule of `PID`, the shape the sum of their `zero`s. A scalar
therefore pairs with a vector, and a uniform vector gain spells one keyword as a
vector, `Kp = @SVector fill(2.0, 3)`. Any parameter may be an input port,
spelled `Kp = AsPort()` with [`AsPort`](@ref), typed `V` and outside the shape.
It carries partials under a `Dual` [activation](@ref g-activation), and
[`Freeze`](@ref) holds it at its plain `Float64` value, as in `PID`.

The backward Euler lag is stable at every period, and `τd = 0` is legal: `yf`
is then the previous weighted measurement, and the D term the backward
difference `(w - yf) / Δt`. `β` is the exact step of the correction's relaxation
over one period, so every `Tt` is stable. `Tt = Inf` switches the correction
off, and `Tt = 0` is legal and brings `u_raw` to the reference by the next
tick, the clamping scheme as the limit of tracking. Not engaged with tracking,
`Tt = 0` follows `v` exactly.

A third output, `saturated`, publishes the `Int8` code of the block's own
clamp: `1` with `u_raw` at or above `u_max`, `-1` at or below `u_min` and `0`
between, a static vector of `Int8` over a vector. `s_update` writes it to the
store from `u_raw` at the tick, and `y_state` publishes it from stage 1 at the
next. It is therefore one tick stale, and flips only on a tick
[boundary](@ref g-boundary). It serves the hold of an outer block in a cascade,
wired to its input `saturation`, whose integrator takes one extra step before
the hold engages. As a stage-1 port it closes no cycle through the outer block's
`u`. The block never reads its own code, since its own windup is the
correction's. `PID` publishes no code, since a continuous one would need a mode
and events.

A tracking input wired from a memoryless clamp of the block's own `u` is
refused as an `AlgebraicCycle`, as for `PID`, but classified real: a discrete
member's dependences are traced from its structure, so no [hop](@ref g-hop) is
named dead. A scheduled parameter computed memorylessly from `u` closes a cycle
likewise.

# Keywords

- `Kp`: the proportional gain.
- `Ki`: the integral gain, inside the integral.
- `Kd`: the derivative gain.
- `τd`: the time constant of the derivative's lag, `0` for the backward
  difference.
- `Tt`: the time constant of the correction, `Inf` to switch it off and `0` to
  correct within one tick.
- `u_min`: the lower limit of `u`.
- `u_max`: the upper limit of `u`.
- `b`: the setpoint weight in the proportional term.
- `c`: the setpoint weight in the derivative's weighted measurement.
- `hold`: `true` to add the inputs `saturation` and `engaged`, the parameter
  `Hold`.
- `tracking`: `true` to add the input `v`, the parameter `Track`.

See also [`PIDBlock`](@ref), [`DiscreteLQRTracker`](@ref).
"""
struct DiscretePID{V <: Union{Real, StaticArray{<:Tuple, <:Real}}, Hold, Track, Fixed} <:
       PIDBlock{V, Hold, Track, Fixed}
    fixed::Fixed      # the parameters that are not ports, each a `V`, in roster order
end
function DiscretePID(; Kp, Ki = 0.0, Kd = 0.0, τd = 0.1, Tt = Inf, u_min = -Inf, u_max = Inf, b = 1.0, c = 0.0,
                     hold::Bool = false, tracking::Bool = false)
    check_tracking(tracking, Tt)
    given = (; Kp, Ki, Kd, τd, Tt, u_min, u_max, b, c)
    V = shape_type(given)
    fixed = fixed_parameters(given, map(_ -> V, given))
    DiscretePID{V, hold, tracking, typeof(fixed)}(fixed)
end

s_init(::DiscretePID{V}) where {V} = (q = zero(V), yf = zero(V), saturated = zero(saturation_type(V)))
y_types(::DiscretePID{V}) where {V} = (u = V, u_raw = V, saturated = saturation_type(V))
y_state(::DiscretePID, (; s)) = (saturated = s.saturated,)
function y_direct(c::DiscretePID, (; s, u, Δt))
    p = parameters(c, u)
    deriv = (u.y - p.c .* u.r - s.yf) ./ (p.τd .+ Δt)
    u_raw = p.Kp .* (p.b .* u.r - u.y) + s.q - p.Kd .* deriv
    (u = clamp.(u_raw, p.u_min, p.u_max), u_raw = u_raw)
end
function s_update(c::DiscretePID, (; s, u, y, Δt))
    p = parameters(c, u)
    β = -expm1.(-Δt ./ p.Tt)
    (q  = s.q + Δt .* p.Ki .* gated_error(c, u.r - u.y, u) + β .* (correction_reference(c, u, y) - y.u_raw),
     yf = s.yf + Δt .* (u.y - p.c .* u.r - s.yf) ./ (p.τd .+ Δt),
     saturated = saturation_code.(y.u_raw, p.u_min, p.u_max))
end

# --- the LQR tracker (§13.7, §5.4, D-383) ---------------------------------------

# The tracker's parameters, in the order `Fixed` and `parameters` lay them out.
const LQR_PARAMETERS = (:K_fbk, :K_fwd, :K_int, :x_trim, :u_trim, :z_trim, :Tt, :u_min, :u_max)

# Design: The parameter order is the roster `LQR_PARAMETERS`.
"""
    LQRTrackerBlock{NX, NU, NZ, Hold, Track, Fixed}

The abstract parent of the two LQR trackers, which carries their shared
[ports](@ref g-port), outputs and parameters.

The two trackers are [`LQRTracker`](@ref) on the continuous [tier](@ref g-tier)
and [`DiscreteLQRTracker`](@ref) on the discrete one. `LQRTrackerBlock` is a
[`ControllerBlock`](@ref) over the two anti-windup axes. It carries what their
law shares past the gate and the reference: the ports picked by the axes and by
the scheduled parameters, the outputs and the parameters' fetch. Each
[block](@ref g-block) carries its field `fixed`, its [store](@ref g-store) and
its stages.

`NX`, `NU` and `NZ` are the sizes of the plant state, the control input and the
command variables. `Fixed` is the `NamedTuple` type of the parameters given as
values, in the order `K_fbk`, `K_fwd`, `K_int`, `x_trim`, `u_trim`, `z_trim`,
`Tt`, `u_min`, `u_max`.
"""
abstract type LQRTrackerBlock{NX, NU, NZ, Hold, Track, Fixed} <: ControllerBlock{Hold, Track} end

# The nine parameters' types at the sizes, in roster order, each matrix with its
# length.
parameter_types(NX, NU, NZ) =
    NamedTuple{LQR_PARAMETERS}((SMatrix{NU, NX, Float64, NU * NX}, SMatrix{NU, NZ, Float64, NU * NZ},
                                SMatrix{NU, NZ, Float64, NU * NZ},
                                SVector{NX, Float64}, SVector{NU, Float64}, SVector{NZ, Float64},
                                SVector{NU, Float64}, SVector{NU, Float64}, SVector{NU, Float64}))

# The methods both blocks share live here: `signal_ports`, `u_types`, `y_types`
# and the parameters' fetch. `DiscreteLQRTracker` adds its code to `y_types`.
signal_ports(c::LQRTrackerBlock{NX, NU, NZ}) where {NX, NU, NZ} =
    merge((x = SVector{NX, Float64}, z = SVector{NZ, Float64}, z_ref = SVector{NZ, Float64}),
          axis_ports(c, SVector{NU, Int8}, SVector{NU, Bool}, SVector{NU, Float64}))
function u_types(c::LQRTrackerBlock{NX, NU, NZ}) where {NX, NU, NZ}
    scheduled = filter(∉(keys(c.fixed)), LQR_PARAMETERS)
    merge(signal_ports(c), NamedTuple{scheduled}(map(name -> parameter_types(NX, NU, NZ)[name], scheduled)))
end
y_types(::LQRTrackerBlock{NX, NU}) where {NX, NU} = (u = SVector{NU, Float64}, u_raw = SVector{NU, Float64})
# The nine parameters in roster order, each from the field or from its port.
# No port name is a parameter name, so the whole input bundle merges.
parameters(c::LQRTrackerBlock, u) = NamedTuple{LQR_PARAMETERS}(merge(c.fixed, u))

# The sizes the values given carry, read off `K_fbk` first, then `K_fwd`,
# `K_int` and the trims; a keyword given as `AsPort()` or left out carries none.
function tracker_sizes(block_name, given)
    function extent(name, axis)
        value = get(given, name, AsPort())
        value isa AbstractArray ? size(value, axis) : nothing
    end
    sizes = (NX = something(extent(:K_fbk, 2), extent(:x_trim, 1), Some(nothing)),
             NU = something(extent(:K_fbk, 1), extent(:K_fwd, 1), extent(:K_int, 1), extent(:u_trim, 1),
                            Some(nothing)),
             NZ = something(extent(:K_fwd, 2), extent(:K_int, 2), extent(:z_trim, 1), Some(nothing)))
    for size_name in keys(sizes)
        sizes[size_name] === nothing && throw(ArgumentError(
            "no keyword given as a value carries `$size_name`; " *
            "spell the sizes as `$block_name{NX, NU, NZ}(; …)`"))
    end
    Tuple(sizes)
end

# Each value given against its type at the sizes: a matrix or a vector of that
# size, or a real for the three per-channel parameters, as `static_system` checks.
function check_shapes(types, given)
    for name in LQR_PARAMETERS
        value, shape = given[name], size(types[name])
        value === AsPort() || value isa Real && name in (:Tt, :u_min, :u_max) ||
            value isa AbstractArray && size(value) == shape || throw(ArgumentError(
                "`$name` is $(value isa AbstractArray ? join(size(value), '×') : "a scalar") " *
                "where $(join(shape, '×')) is needed"))
    end
    nothing
end

# Design: `lqr_tracker.md` gives the derivation and the reasoning. The keyword
# order is the roster `LQR_PARAMETERS`. The sizeless method forwards `kw...`,
# so its line shows the sized method's keywords.
"""
    LQRTracker(; K_fbk, K_fwd, K_int = zero(SMatrix{NU, NZ, Float64}),
               x_trim = zero(SVector{NX, Float64}), u_trim = zero(SVector{NU, Float64}),
               z_trim = zero(SVector{NZ, Float64}), Tt = Inf, u_min = -Inf, u_max = Inf,
               hold::Bool = false, tracking::Bool = false) -> LQRTracker
    LQRTracker{NX, NU, NZ}(; K_fbk, K_fwd, K_int = zero(SMatrix{NU, NZ, Float64}),
                           x_trim = zero(SVector{NX, Float64}), u_trim = zero(SVector{NU, Float64}),
                           z_trim = zero(SVector{NZ, Float64}), Tt = Inf, u_min = -Inf, u_max = Inf,
                           hold::Bool = false, tracking::Bool = false) -> LQRTracker{NX, NU, NZ}

A continuous [primitive](@ref g-primitive) that runs an LQR tracker about a trim
point, with anti-windup.

The inputs are `x`, the plant state, `z`, the command variables, and `z_ref`,
their reference. The two outputs come from [stage 2](@ref g-stage-function),

    u_raw = u_trim + K_fwd (z_ref - z_trim) - K_fbk (x - x_trim) + q

and `u`, its clamp to `[u_min, u_max]` per channel. The [block](@ref g-block)
holds one continuous state, `q`, the integral term in output units, one channel
per control input. One law moves it,

    q̇ = ε + (ref - u_raw) / Tt

and the two anti-windup axes of [`PID`](@ref), each adding inputs, fill its
slots `ε` and `ref` over the integrator input `e = K_int (z_ref - z)`, channel
by channel, by the table of [`ControllerBlock`](@ref).

`hold = true`, the parameter `Hold`, adds two inputs. `saturation`, a code per
channel from the path downstream, gates each channel whose code agrees with the
sign of its integrator input: `gate(e) = saturation == sign(e) ? 0 : e`.
`engaged`, a flag per channel that reads true in command, zeroes the integrator
input of a channel not engaged whatever its code. Without tracking, a channel
not engaged freezes, its own clamp's correction alone moving it.
`tracking = true`, the parameter `Track`, adds the input `v` as the
correction's reference in place of the own `u`. With the hold, `v` is the
reference in a channel only while it is limited or not engaged, so a channel
not engaged converges to `v` at rate `1/Tt` and engagement is bumpless. The own
clamp is the correction's, and `Tt = Inf` switches it off. Tracking with a `Tt`
given as a value and infinite in any channel is refused as an `ArgumentError`,
as for `PID`.

The [ports](@ref g-port) are static vectors at every size: `x` at
`SVector{NX, Float64}`, `z` and `z_ref` at `SVector{NZ, Float64}`, `u`, `u_raw`
and `v` at `SVector{NU, Float64}`, `saturation` at `SVector{NU, Int8}`, and
`engaged` at `SVector{NU, Bool}`.

Any of the nine parameters may be an input port in place of a field, spelled
`K_fbk = AsPort()` with [`AsPort`](@ref) and typed as the field would be, an
`SMatrix{NU, NX, Float64, NU * NX}` for `K_fbk`. That is how a gain schedule
reaches the block. Under a `Dual` [activation](@ref g-activation), the port
carries partials, and a model that wants it frozen at its plain `Float64` value
routes it through [`Freeze`](@ref).

The first form reads `NX`, `NU` and `NZ` off the values given, `K_fbk` first,
then `K_fwd`, `K_int` and the trims, and passes every keyword on to the second,
the explicit spelling, which takes the sizes and the same keywords. A matrix or
a vector that does not fit the sizes read is refused as an `ArgumentError`. A
size no value carries, every carrier a port or left at its default, is refused
likewise, naming the explicit spelling.

`u` is a stage-2 output, so every input makes a
[feedthrough](@ref g-feedthrough) edge, whether `y_direct` reads it or not. An
`x` assembled from what the plant publishes from state, and a `z` selected from
the same, close no loop. A `z_ref` computed memorylessly from the block's own
`u` closes an `AlgebraicCycle` classified real, since the direct law reads it. A
tracking input wired from a memoryless clamp of `u` closes one classified
[artificial](@ref g-algebraic-loop), since only the derivative reads it, which
is why the limits live inside the block. A scheduled parameter computed
memorylessly from `u` closes a cycle too, artificial for `K_int` and `Tt` and
real for the others.

The block publishes no saturation code, since a continuous one would need a
mode and events per channel for a consumer that does not exist. The gains are
designed outside, from [`trim!`](@ref Redstone.trim!) and
[`linearize`](@ref Redstone.linearize).

`K_int` and the trims default to zero. `Tt`, `u_min` and `u_max` are each a real
broadcast to an `SVector{NU, Float64}`, or a vector of length `NU`. Integer
entries qualify.

# Keywords

The nine parameters come in this order.

- `K_fbk`: the `NU × NX` feedback gain, any `AbstractMatrix` of reals stored as
  a static matrix of `Float64`.
- `K_fwd`: the `NU × NZ` feedforward gain, stored likewise.
- `K_int`: the `NU × NZ` integral gain, stored likewise. A zero `K_int` is the
  tracker without integral action.
- `x_trim`: the plant state at trim, a vector of length `NX`.
- `u_trim`: the control input at trim, a vector of length `NU`.
- `z_trim`: the command variables at trim, a vector of length `NZ`.
- `Tt`: the time constant of the correction per channel, `Inf` to switch it off.
- `u_min`: the lower limit of `u` per channel.
- `u_max`: the upper limit of `u` per channel.
- `hold`: `true` to add the inputs `saturation` and `engaged`, the parameter
  `Hold`.
- `tracking`: `true` to add the input `v`, the parameter `Track`.

See also [`DiscreteLQRTracker`](@ref), [`LQRTrackerBlock`](@ref).
"""
struct LQRTracker{NX, NU, NZ, Hold, Track, Fixed} <: LQRTrackerBlock{NX, NU, NZ, Hold, Track, Fixed}
    fixed::Fixed      # the parameters that are not ports, each at its type, in roster order
end
function LQRTracker{NX, NU, NZ}(; K_fbk, K_fwd, K_int = zero(SMatrix{NU, NZ, Float64}),
                                x_trim = zero(SVector{NX, Float64}), u_trim = zero(SVector{NU, Float64}),
                                z_trim = zero(SVector{NZ, Float64}), Tt = Inf, u_min = -Inf, u_max = Inf,
                                hold::Bool = false, tracking::Bool = false) where {NX, NU, NZ}
    check_tracking(tracking, Tt)
    types, given = parameter_types(NX, NU, NZ), (; K_fbk, K_fwd, K_int, x_trim, u_trim, z_trim, Tt, u_min, u_max)
    check_shapes(types, given)
    fixed = fixed_parameters(given, types)
    LQRTracker{NX, NU, NZ, hold, tracking, typeof(fixed)}(fixed)
end
LQRTracker(; K_fbk, K_fwd, kw...) =
    LQRTracker{tracker_sizes("LQRTracker", (; K_fbk, K_fwd, kw...))...}(; K_fbk, K_fwd, kw...)

x_init(::LQRTracker{NX, NU}) where {NX, NU} = zero(SVector{NU, Float64})
function y_direct(c::LQRTracker, (; x, u))
    p = parameters(c, u)
    u_raw = p.u_trim + p.K_fwd * (u.z_ref - p.z_trim) - p.K_fbk * (u.x - p.x_trim) + x
    (u = clamp.(u_raw, p.u_min, p.u_max), u_raw = u_raw)
end
function x_deriv(c::LQRTracker, (; x, u, y))
    p = parameters(c, u)
    gated_error(c, p.K_int * (u.z_ref - u.z), u) + (correction_reference(c, u, y) - y.u_raw) ./ p.Tt
end

# Design: §10.5, §13.8.
# `lqr_tracker.md`, sections 4, 6 and 7, gives the reasoning. The sizeless
# method forwards `kw...`, so its line shows the sized method's keywords.
"""
    DiscreteLQRTracker(; K_fbk, K_fwd, K_int = zero(SMatrix{NU, NZ, Float64}),
                       x_trim = zero(SVector{NX, Float64}), u_trim = zero(SVector{NU, Float64}),
                       z_trim = zero(SVector{NZ, Float64}), Tt = Inf, u_min = -Inf, u_max = Inf,
                       hold::Bool = false, tracking::Bool = false) -> DiscreteLQRTracker
    DiscreteLQRTracker{NX, NU, NZ}(; K_fbk, K_fwd, K_int = zero(SMatrix{NU, NZ, Float64}),
                                   x_trim = zero(SVector{NX, Float64}), u_trim = zero(SVector{NU, Float64}),
                                   z_trim = zero(SVector{NZ, Float64}), Tt = Inf, u_min = -Inf, u_max = Inf,
                                   hold::Bool = false, tracking::Bool = false) -> DiscreteLQRTracker{NX, NU, NZ}

A discrete [primitive](@ref g-primitive) that runs an LQR tracker about a trim
point, with anti-windup.

The [block](@ref g-block) takes the parameters, defaults, [ports](@ref g-port),
outputs and law of [`LQRTracker`](@ref) to the discrete [tier](@ref g-tier). A
[store](@ref g-store) field `q` stands in for its continuous state, and a
second, `saturated`, holds its code. `Δt` is the component's own period. The
inputs are `x`, `z` and `z_ref`, and the two outputs come from
[stage 2](@ref g-stage-function),

    u_raw = u_trim + K_fwd (z_ref - z_trim) - K_fbk (x - x_trim) + q

and `u`, its clamp to `[u_min, u_max]` per channel. Each [tick](@ref g-tick)
moves the integral term by forward Euler and the correction's exact step,

    q⁺ = q + Δt ε + β (ref - u_raw),    β = 1 - exp(-Δt / Tt)

with its slots `ε` and `ref` filled over the two anti-windup axes and the
integrator input `e = K_int (z_ref - z)`, channel by channel, by the table of
[`ControllerBlock`](@ref).

`hold` adds the inputs `saturation` and `engaged`, and a channel not engaged
without tracking freezes. `tracking` adds the input `v`. `tracking = true` with
a `Tt` given infinite in any channel is refused as an `ArgumentError`. With the
hold, the reference falls back to `u` in each channel that is free. All of this
is as in `LQRTracker`. Every `Tt` is stable: `Tt = Inf` switches the correction
off, and `Tt = 0` is legal and brings `u_raw` to the reference by the next
tick, so a channel not engaged with tracking follows `v` exactly.

The ports, the nine parameters and their types, the [`AsPort`](@ref) spelling,
the size inference and the explicit spelling, the second form, are those of
`LQRTracker`, and so are the refusals.

A third output, `saturated`, publishes the `Int8` code of the block's own clamp
per channel at `SVector{NU, Int8}`: `1` with `u_raw` at or above `u_max`, `-1`
at or below `u_min` and `0` between. `s_update` writes it to the store from
`u_raw` at the tick, and `y_state` publishes it from stage 1 at the next. It is
therefore one tick stale, and flips only on a tick [boundary](@ref g-boundary).
It serves the hold of an outer block in a cascade, wired to its input
`saturation`, each channel reaching a scalar consumer through
[`Unpack`](@ref)`{Int8, NU}`. The outer integrator takes one extra step before
the hold engages, and as a stage-1 port the code closes no cycle through the
outer block's `u`. The block never reads its own code, since its own windup is
the correction's.

`u` is a stage-2 output, so every input makes a
[feedthrough](@ref g-feedthrough) edge, as for `LQRTracker`. A `z_ref` or a
tracking input computed memorylessly from the block's own `u` is refused as an
`AlgebraicCycle` classified real: a discrete member's dependences are traced
from its structure, so no [hop](@ref g-hop) is named dead. A scheduled parameter
computed memorylessly from `u` closes a cycle likewise.

# Keywords

The keywords are those of `LQRTracker`, with the same meanings and defaults.

- `K_fbk`: the `NU × NX` feedback gain.
- `K_fwd`: the `NU × NZ` feedforward gain.
- `K_int`: the `NU × NZ` integral gain.
- `x_trim`: the plant state at trim.
- `u_trim`: the control input at trim.
- `z_trim`: the command variables at trim.
- `Tt`: the time constant of the correction per channel, `Inf` to switch it off
  and `0` to correct within one tick.
- `u_min`: the lower limit of `u` per channel.
- `u_max`: the upper limit of `u` per channel.
- `hold`: `true` to add the inputs `saturation` and `engaged`, the parameter
  `Hold`.
- `tracking`: `true` to add the input `v`, the parameter `Track`.

See also [`LQRTrackerBlock`](@ref), [`DiscretePID`](@ref).
"""
struct DiscreteLQRTracker{NX, NU, NZ, Hold, Track, Fixed} <: LQRTrackerBlock{NX, NU, NZ, Hold, Track, Fixed}
    fixed::Fixed      # the parameters that are not ports, each at its type, in roster order
end
function DiscreteLQRTracker{NX, NU, NZ}(; K_fbk, K_fwd, K_int = zero(SMatrix{NU, NZ, Float64}),
                                        x_trim = zero(SVector{NX, Float64}), u_trim = zero(SVector{NU, Float64}),
                                        z_trim = zero(SVector{NZ, Float64}), Tt = Inf, u_min = -Inf, u_max = Inf,
                                        hold::Bool = false, tracking::Bool = false) where {NX, NU, NZ}
    check_tracking(tracking, Tt)
    types, given = parameter_types(NX, NU, NZ), (; K_fbk, K_fwd, K_int, x_trim, u_trim, z_trim, Tt, u_min, u_max)
    check_shapes(types, given)
    fixed = fixed_parameters(given, types)
    DiscreteLQRTracker{NX, NU, NZ, hold, tracking, typeof(fixed)}(fixed)
end
DiscreteLQRTracker(; K_fbk, K_fwd, kw...) =
    DiscreteLQRTracker{tracker_sizes("DiscreteLQRTracker", (; K_fbk, K_fwd, kw...))...}(; K_fbk, K_fwd, kw...)

s_init(::DiscreteLQRTracker{NX, NU}) where {NX, NU} =
    (q = zero(SVector{NU, Float64}), saturated = zero(SVector{NU, Int8}))
y_types(::DiscreteLQRTracker{NX, NU}) where {NX, NU} =
    (u = SVector{NU, Float64}, u_raw = SVector{NU, Float64}, saturated = SVector{NU, Int8})
y_state(::DiscreteLQRTracker, (; s)) = (saturated = s.saturated,)
function y_direct(c::DiscreteLQRTracker, (; s, u))
    p = parameters(c, u)
    u_raw = p.u_trim + p.K_fwd * (u.z_ref - p.z_trim) - p.K_fbk * (u.x - p.x_trim) + s.q
    (u = clamp.(u_raw, p.u_min, p.u_max), u_raw = u_raw)
end
function s_update(c::DiscreteLQRTracker, (; s, u, y, Δt))
    p = parameters(c, u)
    β = -expm1.(-Δt ./ p.Tt)
    (q = s.q + Δt .* gated_error(c, p.K_int * (u.z_ref - u.z), u) + β .* (correction_reference(c, u, y) - y.u_raw),
     saturated = saturation_code.(y.u_raw, p.u_min, p.u_max))
end

# --- the anonymous assembly (§8.5, D-211) -------------------------------------

# Design: D-211.
# It needs no new rule: the container-children rule makes the `children`
# field's elements children of the `Group` itself.
"""
    Group

An [assembly](@ref g-assembly) built on the fly, whose values are the ad-hoc
topologies.

A `Group` is an assembly that holds its children and its declarations as field
values. The elements of its `children` field, a `NamedTuple` of
[components](@ref g-component), are its children. Its [`local_wires`](@ref),
[`input_wires`](@ref), [`output_wires`](@ref) and [`sample_times`](@ref) are
ordinary functions of the instance, which return its fields.

The one declaration it adds is [`transparent_container`](@ref): `children` is
name-transparent, so its elements go by bare key everywhere a child name
appears. That is `"ctl/out" => "plant/u"` for a wire, `(ctl = Relative(2),)` for
a rate, `at("ctl", …)` for a [condition](@ref g-condition) prefix and
`"plant/y"` for a read path. A `Group`'s declarations are then textually
identical to a named assembly's. The rate declaration's field-name sugar, keying
on the field rather than on a path segment, keeps working as
`(children = Relative(2),)` for the uniform case.

The type parameters carry the children's concrete types, so the
[executor](@ref g-executor) specializes on them as on a named assembly. What a
`Group` gives up against a named type is dispatch, which exploratory composition
does not want.
"""
struct Group{C <: NamedTuple, W, I, O, R <: NamedTuple} <: AbstractComponent
    children::C       # component-typed elements → children by the container rule
    local_wires::W    # inert parameter data
    input_wires::I
    output_wires::O
    sample_times::R   # the ad-hoc rate scope, keyed by bare element name (§8.7)
end

"""
    Group(children; local_wires = (), input_wires = (), output_wires = (),
          sample_times = (;)) -> Group

Return a `Group` over `children`, with each [assembly](@ref g-assembly)
declaration given by the keyword of its name.

This is the convenience form. A bare `Pair` passed for `local_wires`,
`input_wires` or `output_wires` is the one-entry tuple. The declarations are
ordered collections of pairs, and a single wire should not have to be written
`("a/x" => "b/y",)`.

# Keywords

- `local_wires`: the wires between children, as [`local_wires`](@ref) returns
  them.
- `input_wires`: the inward boundary, as [`input_wires`](@ref) returns it.
- `output_wires`: the outward boundary, as [`output_wires`](@ref) returns it.
- `sample_times`: the rates of the children, keyed by bare child name, as
  [`sample_times`](@ref) returns them.
"""
Group(children; local_wires = (), input_wires = (), output_wires = (),
      sample_times = (;)) =
    Group(children, _entries(local_wires), _entries(input_wires),
          _entries(output_wires), sample_times)

_entries(wires::Pair) = (wires,)
_entries(wires) = wires

local_wires(g::Group) = g.local_wires
input_wires(g::Group) = g.input_wires
output_wires(g::Group) = g.output_wires
sample_times(g::Group) = g.sample_times
transparent_container(::Group) = :children

end # module Blocks

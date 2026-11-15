# The stepper seam (§10.2, D-452): loop ownership stops at one operation, *one
# step of the continuous state from the clock*, delegated across this narrow
# interface so the integration method can be replaced without the loop changing.
# The backend's side is seven calls, each answered by dispatch on the stepper:
#
#   - `propose(stepper)`, the length the backend asks for next, `nothing` for a
#     method that proposes none, which takes each span in equal steps (D-449);
#   - `attempt!(stepper, model, h)`, one try at a step of length `h`, returning
#     whether the backend accepts it;
#   - `discontinuity!(stepper)`, the notice that the next step starts at a
#     discontinuity, which a backend may ignore;
#   - `startpoint(stepper)` and `dense!`, the dense output over the last
#     accepted step, built lazily, because only event localization (§10.4) asks;
#   - `checkpoint_stepper`/`restore_stepper!`, what the backend carries across a
#     frame top, read into a model's state and written back from it;
#   - `reset_stepper!(stepper)`, that carried state put back as bound, which
#     `init!` asks for.
#
# The Model's side is model.jl's `integrate_step!`: it shapes the proposal into
# a length between the deployment's `h_min` and `h_max`, counts the attempts,
# discards a rejected one, accepts one at the floor whatever its verdict,
# checks and commits an accepted one, writes the clock, and raises the notice. One-step methods only:
# handlers reset state discontinuously, and a one-step method restarts from a
# new state for free (D-017). The seam is never entered empty (§10.2): an empty
# state never reaches `attempt!`, so no backend faces N = 0. `RK4` and `Heun`
# are fixed-step and always accept, and `BS3` adapts under error control; all
# three are zero-allocation and generic in the scalar. The backend is a
# deployment binding (`algorithm = RK4()`, the default), and nothing outside
# this file knows which one ran.
#
# Each backend is two types (D-442): the token the deployment records, `RK4()`
# (deployment.jl), and the stepper it binds to here, which owns scratch sized by
# the state and typed by the scalar, both known only at `Model` construction.

abstract type AbstractStepper end

"""
    bind_stepper(algorithm, T, n_x) -> AbstractStepper

The stepper an algorithm token binds to at `Model` construction (§10.2, D-442):
its scratch over the model's flat state buffer of `n_x` scalars of type `T`.
A fixed step's length is the frame loop's, from the deployment's lattices and
its bound `h_max` (D-449), so neither the token nor the stepper holds one.
"""
function bind_stepper end

"""
    propose(stepper) -> Union{Float64, Nothing}

The length, in seconds, the backend asks for its next attempt (§10.2, D-452),
or `nothing` for a method that proposes none. The Model asks before every step
and after every rejected attempt. It takes a span in equal steps no longer than
`h_max` under `nothing` (D-449), and otherwise clamps the proposal into
`[h_min, h_max]` and takes the distance to the span's end in equal steps no
longer than that (D-460). Every backend states its answer; there is no
default, since a forgotten one would change the stepping rule in silence.
"""
function propose end

"""
    attempt!(stepper, model, h) -> Bool

One try at a step of length `h` from the clock (§10.2, D-452). The backend
reads the state at the step's start from the model's state buffer, writes the
state at the step's end into the trial buffer `model.exec.xnext`, and returns
whether it accepts the step. Its stages may write the state buffer and the
clock as scratch, through `evaluate!(model)`. The Model then writes both: on an
acceptance it commits the trial and the clock at the step's end, and on a
rejection it puts back the step's start, the state from `startpoint` and the
clock as it was, and asks `propose` for the next attempt's length. An attempt
at the floor, which no proposal could shape shorter, it accepts whatever the
verdict (D-460). A method that proposes nothing always accepts.
"""
function attempt! end

"""
    discontinuity!(stepper) -> Nothing

The notice that the next step starts at a discontinuity (§10.2, D-452): a
boundary where a handler fired or a tick ran, a frame top whose drain wrote a
value, or the settling of `overlay!`. A notice arrives when its boundary
settles, so a checkpoint taken there holds what the backend did with it. Two
notices before a step mean one. What the backend does with it is its own, and
the default does nothing, which is a fixed-step method's answer.
"""
discontinuity!(::AbstractStepper) = nothing

"""
    startpoint(stepper)

The seam's retained pair `(xₙ, ẋₙ)`: the state and derivative at the start of
the last attempt, surviving in the backend's own scratch. This is the data
clause of the dense-output obligation. The frame loop's θ = 0 validation reads
the state half directly, the generic `dense!` builds on both halves, and the
Model puts the state half back into the state buffer when it discards a
rejected attempt.
"""
function startpoint end

"""
    checkpoint_stepper(stepper)
    restore_stepper!(stepper, carried)

The seam's checkpoint pair (§12.6, D-274, D-452): what a backend carries across
a frame top, such as its proposal and its controller's memory, read into the
model's state when a checkpoint is taken and written back when one is restored.
The value is immutable, so a detached state can share it. A restore writes it
back and raises no notice, so the restored run proposes what the original
proposed. Every backend states its pair; there is no default, since a forgotten
one would lose the backend's state at a restore in silence. A fixed-step method
carries nothing, its `startpoint` being rewritten by every attempt before
anything reads it, so both first-cut backends carry `nothing`.
"""
function checkpoint_stepper end
function restore_stepper! end

"""
    reset_stepper!(stepper) -> Nothing

Put the backend's carried state back as it was bound (§10.2, D-452). `init!`
calls it before boundary zero, so a run it opens is a function of its condition
and never of what the model ran before. Every backend states it; there is no
default, since a forgotten one would carry one run's proposal into the next. A
fixed-step method carries nothing and does nothing.
"""
function reset_stepper! end

# Design: §10.2, D-442, D-452.
# The classical fourth-order Runge–Kutta method, `RK4`'s stepper. It owns
# exactly its own scratch, the state at the start of the step and the four
# stage derivatives, over the model's flat state buffer of `n_x` scalars of
# type `T`.
struct RK4Stepper{T} <: AbstractStepper
    x₀::Vector{T}
    k₁::Vector{T}
    k₂::Vector{T}
    k₃::Vector{T}
    k₄::Vector{T}
end
bind_stepper(::RK4, ::Type{T}, n_x::Int) where {T} =
    RK4Stepper{T}(ntuple(_ -> zeros(T, n_x), 5)...)

propose(::RK4Stepper) = nothing
checkpoint_stepper(::RK4Stepper) = nothing
restore_stepper!(::RK4Stepper, ::Nothing) = nothing
reset_stepper!(::RK4Stepper) = nothing

function attempt!(stepper::RK4Stepper, model::Model, h)
    exec = model.exec
    x, ẋ, xtrial = exec.xbuf, exec.ẋbuf, exec.xnext
    (; x₀, k₁, k₂, k₃, k₄) = stepper
    t = exec.clock.t
    copyto!(x₀, x)

    evaluate!(model); copyto!(k₁, ẋ)
    _stage_point!(x, x₀, k₁, h / 2); exec.clock.t = t + h / 2
    evaluate!(model); copyto!(k₂, ẋ)
    _stage_point!(x, x₀, k₂, h / 2)
    evaluate!(model); copyto!(k₃, ẋ)
    _stage_point!(x, x₀, k₃, h); exec.clock.t = t + h
    evaluate!(model); copyto!(k₄, ẋ)

    @inbounds for i in eachindex(xtrial)
        xtrial[i] = x₀[i] + (h / 6) * (k₁[i] + 2k₂[i] + 2k₃[i] + k₄[i])
    end
    true
end

startpoint(stepper::RK4Stepper) = (stepper.x₀, stepper.k₁)

# Design: §10.2, D-442, D-452.
# Heun's second-order method, the explicit trapezoidal rule, `Heun`'s stepper.
# It owns exactly its own scratch, the state at the start of the step and the
# two stage derivatives.
struct HeunStepper{T} <: AbstractStepper
    x₀::Vector{T}
    k₁::Vector{T}
    k₂::Vector{T}
end
bind_stepper(::Heun, ::Type{T}, n_x::Int) where {T} =
    HeunStepper{T}(ntuple(_ -> zeros(T, n_x), 3)...)

propose(::HeunStepper) = nothing
checkpoint_stepper(::HeunStepper) = nothing
restore_stepper!(::HeunStepper, ::Nothing) = nothing
reset_stepper!(::HeunStepper) = nothing

function attempt!(stepper::HeunStepper, model::Model, h)
    exec = model.exec
    x, ẋ, xtrial = exec.xbuf, exec.ẋbuf, exec.xnext
    (; x₀, k₁, k₂) = stepper
    t = exec.clock.t
    copyto!(x₀, x)

    evaluate!(model); copyto!(k₁, ẋ)
    _stage_point!(x, x₀, k₁, h); exec.clock.t = t + h
    evaluate!(model); copyto!(k₂, ẋ)

    @inbounds for i in eachindex(xtrial)
        xtrial[i] = x₀[i] + (h / 2) * (k₁[i] + k₂[i])
    end
    true
end

startpoint(stepper::HeunStepper) = (stepper.x₀, stepper.k₁)

@inline function _stage_point!(x, x₀, k, h)
    @inbounds for i in eachindex(x)
        x[i] = x₀[i] + h * k[i]
    end
end

# Design: §10.2, §14.10, D-461.
# The Bogacki–Shampine 3(2) pair, `BS3`'s stepper: the third-order solution
# advances, and its distance from the embedded second-order one is the error
# estimate, whose local order is 3. The fourth stage is the derivative at the
# step's end, paid in full at every attempt and used by the estimate alone. The
# next step's first stage is evaluated again, the `x_deriv` block alone over a
# fresh table, since a boundary may move the state or the table (§10.3).
#
# The controller is proportional-integral, its constants fixed below as the
# method's identity, never keywords. An accepted step proposes
# `h·SAFETY·err^(-PI_ERROR)·last^PI_MEMORY`, `last` the previous accepted step's
# error, and with no history, after `reset_stepper!` or a notice, the
# elementary `h·SAFETY·err^(-1/3)`, the integral gain alone; the factor lies in
# `[SHRINK, GROWTH]`. A rejected step proposes `h·max(STRONGEST,
# SAFETY·err^(-1/3))`, and a nonfinite estimate or trial is a rejection at
# `STRONGEST`, so the proposal never becomes `NaN`. The error is the maximum
# over the state of `|errᵢ| / (abstol + reltol·max(|xₙᵢ|, |xₙ₊₁ᵢ|))`, on values
# alone, so a `Dual` model takes the steps its `Float64` twin takes.
#
# The first attempt after `reset_stepper!` runs under the infinite proposal,
# whole. A rejection of it proposes at most the starting bound
# `_starting_bound`, from that attempt's first stage. The proposal is finite
# after any attempt, so the infinite one is the starting state, and the
# checkpoint pair carries it with no field of its own.
#
# The constants are OrdinaryDiffEqCore's defaults (`alg_utils.jl`,
# `integrators/controllers.jl`) at the order `k = 3`: the PI gains
# `PI_ERROR = 7/(10k)` and `PI_MEMORY = 2/(5k)`, `SAFETY = 9/10`, the limits
# `SHRINK = 1/5` and `GROWTH = 10`, and `MEMORY_FLOOR = 1/10^4`, its `qoldinit`,
# so an exact step leaves the next proposal finite. One departure: after a
# rejection the factor is the elementary `SAFETY·err^(-1/3)`, where
# OrdinaryDiffEq takes `err^(-PI_ERROR)`, so at a scaled error of 8 the step
# shrinks by 0.45 against 0.55. `STRONGEST` is `SHRINK`, the bound on that
# factor. OrdinaryDiffEq starts from the memory floor; this backend starts
# under the elementary controller.
const BS3_SAFETY = 0.9
const BS3_GROWTH = 10.0
const BS3_SHRINK = 0.2
const BS3_STRONGEST = 0.2
const BS3_PI_ERROR = 0.7 / 3
const BS3_PI_MEMORY = 0.4 / 3
const BS3_MEMORY_FLOOR = 1e-4
const BS3_START_FRACTION = 0.8

# The tableau: the nodes `c`, the stage weights `a`, the third-order weights
# `b`, and `e = b − b̂`, the difference from the embedded second-order weights.
const BS3_A21, BS3_A32 = 1 / 2, 3 / 4
const BS3_B1, BS3_B2, BS3_B3 = 2 / 9, 1 / 3, 4 / 9
const BS3_E1, BS3_E2, BS3_E3, BS3_E4 = -5 / 72, 1 / 12, 1 / 9, -1 / 8

# The stepper owns its five scratch vectors and its carried state, the
# proposal and the controller's memory, `0.0` for none. Bound with the
# proposal infinite, so the first step takes what the bound and the span allow.
mutable struct BS3Stepper{T} <: AbstractStepper
    const reltol::Float64
    const abstol::Float64
    const x₀::Vector{T}
    const k₁::Vector{T}
    const k₂::Vector{T}
    const k₃::Vector{T}
    const k₄::Vector{T}
    proposal::Float64
    memory::Float64
end
bind_stepper(algorithm::BS3, ::Type{T}, n_x::Int) where {T} =
    BS3Stepper{T}(algorithm.reltol, algorithm.abstol, ntuple(_ -> zeros(T, n_x), 5)..., Inf, 0.0)

propose(stepper::BS3Stepper) = stepper.proposal
checkpoint_stepper(stepper::BS3Stepper) = (stepper.proposal, stepper.memory)
restore_stepper!(stepper::BS3Stepper, (proposal, memory)::Tuple{Float64,Float64}) =
    (stepper.proposal = proposal; stepper.memory = memory; nothing)
reset_stepper!(stepper::BS3Stepper) = (stepper.proposal = Inf; stepper.memory = 0.0; nothing)
# A discontinuity clears the history and keeps the proposal, so the step after
# it is controlled by the integral gain alone.
discontinuity!(stepper::BS3Stepper) = (stepper.memory = 0.0; nothing)
startpoint(stepper::BS3Stepper) = (stepper.x₀, stepper.k₁)

function attempt!(stepper::BS3Stepper, model::Model, h)
    exec = model.exec
    x, ẋ, xtrial = exec.xbuf, exec.ẋbuf, exec.xnext
    (; x₀, k₁, k₂, k₃, k₄, reltol, abstol) = stepper
    t = exec.clock.t
    starting = stepper.proposal == Inf      # the first attempt since `reset_stepper!`
    copyto!(x₀, x)

    evaluate!(model); copyto!(k₁, ẋ)
    _stage_point!(x, x₀, k₁, BS3_A21 * h); exec.clock.t = t + BS3_A21 * h
    evaluate!(model); copyto!(k₂, ẋ)
    _stage_point!(x, x₀, k₂, BS3_A32 * h); exec.clock.t = t + BS3_A32 * h
    evaluate!(model); copyto!(k₃, ẋ)
    @inbounds for i in eachindex(xtrial)
        xtrial[i] = x₀[i] + h * (BS3_B1 * k₁[i] + BS3_B2 * k₂[i] + BS3_B3 * k₃[i])
    end
    copyto!(x, xtrial); exec.clock.t = t + h
    evaluate!(model); copyto!(k₄, ẋ)

    # The error over the values alone (§14.10). `max` keeps a `NaN`.
    h_value = _seconds(h)
    scaled_error = 0.0
    @inbounds for i in eachindex(xtrial)
        x₁ = _seconds(xtrial[i])
        estimate = h_value * (BS3_E1 * _seconds(k₁[i]) + BS3_E2 * _seconds(k₂[i]) +
                              BS3_E3 * _seconds(k₃[i]) + BS3_E4 * _seconds(k₄[i]))
        scale = abstol + reltol * max(abs(_seconds(x₀[i])), abs(x₁))
        scaled_error = max(scaled_error, abs(estimate) / scale)
        isfinite(x₁) || (scaled_error = Inf)
    end
    if !isfinite(scaled_error) || scaled_error > 1
        shrink = isfinite(scaled_error) ? max(BS3_STRONGEST, BS3_SAFETY / cbrt(scaled_error)) :
                 BS3_STRONGEST
        stepper.proposal = h_value * shrink
        starting && (stepper.proposal = min(stepper.proposal, _starting_bound(stepper)))
        return false
    end
    factor = stepper.memory == 0.0 ? BS3_SAFETY / cbrt(scaled_error) :
             BS3_SAFETY * scaled_error^-BS3_PI_ERROR * stepper.memory^BS3_PI_MEMORY
    stepper.proposal = h_value * clamp(factor, BS3_SHRINK, BS3_GROWTH)
    stepper.memory = max(scaled_error, BS3_MEMORY_FLOOR)
    true
end

# The starting bound (D-461), the rule of MATLAB's `ode23`: the step over which
# the first stage changes the state by `START_FRACTION·reltol^(1/3)` of its
# scale `max(|xᵢ|, abstol/reltol)`, over the values alone. A vanishing
# derivative, or one that is not a number, gives no bound.
function _starting_bound(stepper::BS3Stepper)
    (; x₀, k₁, reltol, abstol) = stepper
    least_scale = abstol / reltol
    rate = 0.0
    @inbounds for i in eachindex(x₀)
        rate = max(rate, abs(_seconds(k₁[i])) / max(abs(_seconds(x₀[i])), least_scale))
    end
    rate /= BS3_START_FRACTION * cbrt(reltol)
    rate > 0 ? 1 / rate : Inf
end

"""
    dense!(stepper, x̂, x₁, ẋ₁, θ, h′)

Dense output over the last accepted step (§10.2): write x̂(θ), θ ∈ [0, 1],
into `x̂`, from the seam's retained `startpoint` pair and the arrival pair
`(x₁, ẋ₁)` the caller holds — the caller pays ẋₙ₊₁ lazily, which is why it is
an argument rather than a retention. The generic method is the cubic Hermite
over those four, derivatives scaled by the segment width: uniform accuracy
O(h⁴), the standard pairing for a one-step method of order ≤ 4, and why
nothing more expensive is worth running trials against. `RK4`, `Heun` and
`BS3` inherit it; a higher-order backend would override with its own formula.
"""
function dense!(stepper::AbstractStepper, x̂, x₁, ẋ₁, θ::Float64, h′)
    (x₀, ẋ₀) = startpoint(stepper)
    θ² = θ * θ; θ³ = θ² * θ
    w_x₀ = 2θ³ - 3θ² + 1
    w_x₁ = 3θ² - 2θ³
    w_ẋ₀ = (θ³ - 2θ² + θ) * h′
    w_ẋ₁ = (θ³ - θ²) * h′
    @inbounds for i in eachindex(x̂)
        x̂[i] = w_x₀ * x₀[i] + w_ẋ₀ * ẋ₀[i] + w_x₁ * x₁[i] + w_ẋ₁ * ẋ₁[i]
    end
    nothing
end

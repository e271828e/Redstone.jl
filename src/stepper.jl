# The stepper seam (§10.2, D-452): loop ownership stops at one operation, *one
# step of the continuous state from the clock*, delegated across this narrow
# interface so the integration method can be replaced without the loop changing.
# The backend's side is six functions, each answered by dispatch on the stepper:
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
#     frame top, read into a model's state and written back from it.
#
# The Model's side is model.jl's `integrate_step!`: it shapes the proposal into
# a length, counts the attempts, discards a rejected one, checks and commits an
# accepted one, writes the clock, and raises the notice. One-step methods only:
# handlers reset state discontinuously, and a one-step method restarts from a
# new state for free (D-017). The seam is never entered empty (§10.2): an empty
# state never reaches `attempt!`, so no backend faces N = 0. Both first-cut
# backends are fixed-step, always accept, zero-allocation and generic in the
# scalar; the backend is a deployment binding (`algorithm = RK4()`, the
# default), and nothing outside this file knows which one ran.
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
`h_max` under `nothing` (D-449), and otherwise clamps the proposal to `h_max`
and to the span's end. Every backend states its answer; there is no default,
since a forgotten one would change the stepping rule in silence.
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
clock as it was, and asks `propose` for the next attempt's length. A method
that proposes nothing always accepts.
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

"""
    dense!(stepper, x̂, x₁, ẋ₁, θ, h′)

Dense output over the last accepted step (§10.2): write x̂(θ), θ ∈ [0, 1],
into `x̂`, from the seam's retained `startpoint` pair and the arrival pair
`(x₁, ẋ₁)` the caller holds — the caller pays ẋₙ₊₁ lazily, which is why it is
an argument rather than a retention. The generic method is the cubic Hermite
over those four, derivatives scaled by the segment width: uniform accuracy
O(h⁴), the standard pairing for a one-step method of order ≤ 4 — one order
below RK4's discrete solution, above Heun's — and why nothing more expensive
is worth running trials against. Both first-cut backends inherit it; a
higher-order backend would override with its own formula.
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

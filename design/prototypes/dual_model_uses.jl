# The script behind `design/companions/dual_model_uses.md`. Every number the
# companion quotes is this script's output. Run from the repository root:
#
#     julia --project=. design/prototypes/dual_model_uses.jl
#
# Verified: 2026-11-26, on the tree of commit 4ee82793.

using Redstone, ForwardDiff, LinearAlgebra, Printf
using Redstone: AbstractComponent, Group, Model, init!, frame!, state, port, set, at, combine,
                linearize, taps, get_state, get_input
import Redstone: x_init, s_init, u_types, y_types, y_state, y_direct, x_deriv

# --- the components ---------------------------------------------------------------

"A damped pendulum under a torque: θ̈ = −9.81·sin θ − 0.5·θ̇ + u."
struct Pendulum <: AbstractComponent end
x_init(::Pendulum) = (θ = 0.0, ω = 0.0)
u_types(::Pendulum) = (u = Float64,)
y_types(::Pendulum) = (θ = Float64, ω = Float64)
y_state(::Pendulum, (; x)) = (θ = x.θ, ω = x.ω)
x_deriv(::Pendulum, (; x, u)) = (θ = x.ω, ω = -9.81 * sin(x.θ) - 0.5 * x.ω + u.u)

"A sampled proportional law, u = −k·θ. Discrete, with no state of its own."
struct SampledGain <: AbstractComponent
    k::Float64
end
s_init(::SampledGain) = nothing
u_types(::SampledGain) = (θ = Float64,)
y_types(::SampledGain) = (u = Float64,)
y_direct(c::SampledGain, (; u)) = (u = -c.k * u.θ,)

open_loop() = Group((; c = Pendulum()); input_wires = ("τ" => "c/u",))
closed_loop() = Group((; c = Pendulum(), ctl = SampledGain(4.0));
                      local_wires = ("c/θ" => "ctl/θ", "ctl/u" => "c/u"))

struct UsesTag end
const D = ForwardDiff.Dual{UsesTag,Float64,3}
seed(v, k) = D(v, ForwardDiff.Partials(ntuple(i -> Float64(i == k), 3)))

vec2(x) = [x.θ, x.ω]
values_of(x) = ForwardDiff.value.(vec2(x))
jacobian_of(x) = [ForwardDiff.partials(leaf)[k] for leaf in vec2(x), k in 1:3]

# --- 1. a trajectory's sensitivities ----------------------------------------------

println("== 1. a trajectory's sensitivities")
point(θ, ω, τ) = combine(at("c", set(x = (θ = θ, ω = ω))), set(u = (τ = τ,)))

function fly(θ, ω, τ; frames = 100)
    model = Model(open_loop(); Δt_frame = 1//100)
    init!(model, point(θ, ω, τ))
    for k in 1:frames
        frame!(model, k)
    end
    vec2(state(model, "c"))
end

nominal = Model(open_loop(); Δt_frame = 1//100)
dual = Model(open_loop(), D; Δt_frame = 1//100)
init!(nominal, point(1.0, 0.0, 0.5))
init!(dual, point(seed(1.0, 1), seed(0.0, 2), seed(0.5, 3)))
twin = true
for k in 1:100
    frame!(nominal, k)
    frame!(dual, k)
    global twin &= values_of(state(dual, "c")) == vec2(state(nominal, "c"))
end
J = jacobian_of(state(dual, "c"))
println("values equal the twin's at all 100 frame tops: ", twin)
println("x(1) = ", vec2(state(nominal, "c")))
println("∂x(1)/∂(θ₀, ω₀, τ) =")
display(J); println()
h = 1e-6
fd = hcat((fly(1.0 + h, 0.0, 0.5) - fly(1.0 - h, 0.0, 0.5)) / 2h,
          (fly(1.0, h, 0.5) - fly(1.0, -h, 0.5)) / 2h,
          (fly(1.0, 0.0, 0.5 + h) - fly(1.0, 0.0, 0.5 - h)) / 2h)
@printf("largest difference from central finite differences: %.2e\n", maximum(abs, J - fd))
Φ = J[:, 1:2]
@printf("det Φ(1, 0) = %.12f, and exp(−0.5) = %.12f\n", det(Φ), exp(-0.5))

# --- 2. one period: the discretized plant -----------------------------------------

println("\n== 2. one period: the discretized plant")
tap_set = taps(x = (θ = get_state("c", :θ), ω = get_state("c", :ω)), u = (τ = get_input(:τ),))

function one_period(θ, ω, τ)
    model = Model(open_loop(), D; Δt_frame = 1//50)
    init!(model, point(seed(θ, 1), seed(ω, 2), seed(τ, 3)))
    frame!(model, 1)
    flow = jacobian_of(state(model, "c"))                       # [A_d  B_d], the flow's Jacobian
    lin = linearize(Model(open_loop(); Δt_frame = 1//50), tap_set; about = point(θ, ω, τ))
    held = exp([lin.A lin.B; zeros(1, 3)] / 50)[1:2, :]        # the instant's Jacobian, held and exponentiated
    (flow, held)
end

for (label, (θ, ω, τ)) in ("at rest, (0, 0, 0)" => (0.0, 0.0, 0.0), "in motion, (1, 2, 0.5)" => (1.0, 2.0, 0.5))
    (flow, held) = one_period(θ, ω, τ)
    println(label, ": [A_d  B_d] from one frame =")
    display(flow); println()
    @printf("largest difference from exp([A B; 0 0]·Δt): %.2e\n", maximum(abs, flow - held))
end

# --- 3. the limit: a sampled law in the loop ---------------------------------------

println("\n== 3. the limit: a sampled law in the loop")
nominal = Model(closed_loop(); Δt_frame = 1//50)
dual = Model(closed_loop(), D; Δt_frame = 1//50)
held = Model(open_loop(); Δt_frame = 1//50)                    # the pendulum under the held torque
init!(nominal, at("c", set(x = (θ = 0.5, ω = 0.0))))
init!(dual, at("c", set(x = (θ = seed(0.5, 1), ω = seed(0.0, 2)))))
init!(held, point(0.5, 0.0, -4.0 * 0.5))
println("after init!: u nominal = ", port(nominal, "ctl", :u), ", u dual = ", port(dual, "ctl", :u))
println("frame   θ nominal        θ dual           difference   u nominal   u dual   dual == held system")
for k in 1:50
    frame!(nominal, k); frame!(dual, k); frame!(held, k)
    θn, θd = state(nominal, "c").θ, ForwardDiff.value(state(dual, "c").θ)
    k in (1, 2, 3, 5, 10, 50) || continue
    @printf("%5d   %.12f   %.12f   %10.2e   %9.5f   %6.2f   %s\n", k, θn, θd, θd - θn,
            port(nominal, "ctl", :u), port(dual, "ctl", :u),
            values_of(state(dual, "c")) == vec2(state(held, "c")))
end

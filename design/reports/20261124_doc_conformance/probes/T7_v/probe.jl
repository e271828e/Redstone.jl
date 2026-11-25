# T7 verifier probes. Run from W with --project=docs (needs RedstoneExamples and ComponentArrays).
using Redstone
import Redstone: AbstractComponent, x_init, s_init, u_types, y_types,
    y_state, y_direct, x_deriv, s_update
import Redstone: Absolute, Group, Simulation, init!, run!, set, port, state, build
import Redstone: at, combine, series, reads, get_output, get_state, get_input, taps, linearize,
    labeled, trim!, lifecycle, TrimProblem, get_deriv, RK4, Deployment
import RedstoneExamples
import RedstoneExamples: Longitudinal, aircraft, level_flight
using ComponentArrays
using LinearAlgebra: I, eigvals

say(tag, v) = println(tag, " => ", v)

# --- README quick start
struct Plant <: AbstractComponent
    ω::Float64
    ζ::Float64
end
x_init(::Plant) = (q = 0.0, v = 0.0)
u_types(::Plant) = Float64
y_types(::Plant) = (y = Float64, power = Float64)
y_state(::Plant, (; x)) = (y = x.q,)
y_direct(::Plant, (; x, u)) = (power = u * x.v,)
x_deriv(p::Plant, (; x, u)) = (q = x.v, v = -p.ω^2 * x.q - 2p.ζ * p.ω * x.v + u)
struct PI <: AbstractComponent
    k_p::Float64
    k_i::Float64
end
s_init(::PI) = 0.0
u_types(::PI) = (ref = Float64, meas = Float64)
y_types(::PI) = Float64
y_direct(c::PI, (; s, u)) = c.k_p * (u.ref - u.meas) + s
s_update(c::PI, (; s, u, Δt)) = s + c.k_i * Δt * (u.ref - u.meas)
loop(feedback) = Group((plant = Plant(2.0, 0.3), ctl = PI(3.0, 2.0));
    local_wires = ("ctl/y" => "plant/u", "plant/$feedback" => "ctl/meas"),
    input_wires = "ref" => "ctl/ref",
    output_wires = "plant/y" => "y",
    sample_times = (ctl = Absolute(1//50),))
sim = Simulation(loop("y"); Δt_frame = 1//1000)
init!(sim, set(u = (ref = 1.0,)))
run!(sim; t_end = 10.0)
say("README port", port(sim, "plant", :y))
say("README state", state(sim, "plant"))
say("T7-053 Absolute(1//50)", Absolute(1//50))
say("T7-044 names", [(n, isdefined(Redstone, n), typeof(getfield(Redstone, n)) <: Function || getfield(Redstone, n) isa Type)
    for n in (:AbstractComponent, :x_init, :s_init, :u_types, :y_types, :y_state, :y_direct, :x_deriv, :s_update,
              :Absolute, :Group, :Simulation, :init!, :run!, :set, :port, :state, :build)])
try
    build(loop("power"))
    say("T7-012", "no error")
catch e
    say("T7-012", sprint(showerror, e))
end

# --- aircraft chapter
off_trim = combine(at("plant", set(x = (V = 55.0, θ = 0.019930))),
                   set(u = (δe = 0.025058, δt = 0.37234)))
asim = Simulation(aircraft(); Δt_frame = 1//100)
init!(asim, off_trim)
say("T7-130 state at init", state(asim, "plant"))
run!(asim; t_end = 120.0)
flight = series(asim, reads(V = get_output("plant", :V), h = get_output("plant", :h)))
say("T7-138 log length", length(flight.t))
say("T7-138 t first/last", (flight.t[1:3], flight.t[end]))
# re-init after a run: do unnamed states revert to x_init?
init!(asim, off_trim)
say("T7-130 state at re-init", state(asim, "plant"))

# The tutorial's own Longitudinal, typed in the probe, against the package's
@kwdef struct Long2 <: AbstractComponent
    m::Float64 = 1000.0; S::Float64 = 16.0; c̄::Float64 = 1.5; Iyy::Float64 = 1800.0
    T_max::Float64 = 2500.0; ρ::Float64 = 1.225; CL0::Float64 = 0.3; CLα::Float64 = 5.0
    CD0::Float64 = 0.03; k::Float64 = 0.05; Cm0::Float64 = 0.05; Cmα::Float64 = -1.0
    Cmq::Float64 = -12.0; Cmδe::Float64 = -1.2
end
const g = 9.81
x_init(::Long2) = (V = 50.0, γ = 0.0, θ = 0.0, q = 0.0, h = 1000.0)
u_types(::Long2) = (δe = Float64, δt = Float64)
y_types(::Long2) = (V = Float64, γ = Float64, θ = Float64, q = Float64, h = Float64, α = Float64)
y_state(::Long2, (; x)) = (V = x.V, γ = x.γ, θ = x.θ, q = x.q, h = x.h, α = x.θ - x.γ)
function x_deriv(plant::Long2, (; x, u))
    (; V, γ, θ, q) = x
    α = θ - γ
    q̄ = 0.5 * plant.ρ * V^2
    CL = plant.CL0 + plant.CLα * α
    Cm = plant.Cm0 + plant.Cmα * α + plant.Cmq * q * plant.c̄ / (2V) + plant.Cmδe * u.δe
    lift = q̄ * plant.S * CL
    drag = q̄ * plant.S * (plant.CD0 + plant.k * CL^2)
    moment = q̄ * plant.S * plant.c̄ * Cm
    thrust = u.δt * plant.T_max
    (V = (thrust * cos(α) - drag) / plant.m - g * sin(γ),
     γ = (lift + thrust * sin(α)) / (plant.m * V) - g * cos(γ) / V,
     θ = q, q = moment / plant.Iyy, h = V * sin(γ))
end
tut_aircraft() = Group((; plant = Long2()); input_wires = ("δe" => "plant/δe", "δt" => "plant/δt"))
tsim = Simulation(tut_aircraft(); Δt_frame = 1//100)
init!(tsim, off_trim)
run!(tsim; t_end = 120.0)
tflight = series(tsim, reads(V = get_output("plant", :V), h = get_output("plant", :h)))
say("T7-149 bitwise", (tflight.V, tflight.h) == (flight.V, flight.h))

# --- trim chapter
tr = trim!(Simulation(aircraft(); Δt_frame = 1//100), level_flight(); baseline = set())
say("trim 50", (tr.status, tr.n_iterations, tr.solution))
slow_sim = Simulation(aircraft(); Δt_frame = 1//100)
slow = trim!(slow_sim, level_flight(V = 20.0); baseline = set())
say("T7-183", (status = slow.status, saturated = slow.saturated, residuals = slow.residuals, lifecycle = lifecycle(slow_sim)))

# --- linearize chapter
lsim = Simulation(aircraft(); Δt_frame = 1//100)
solution = trim!(lsim, level_flight(); baseline = set()).solution
tp = taps(x = (V = get_state("plant", :V), γ = get_state("plant", :γ), θ = get_state("plant", :θ),
               q = get_state("plant", :q), h = get_state("plant", :h)),
          u = (δe = get_input(:δe), δt = get_input(:δt)))
plain = linearize(lsim, tp)
say("T7-203 plain A type", typeof(plain.A))
lin = labeled(plain)
say("T7-203 labeled A type", typeof(lin.A))
say("T7-203 A[:h,:γ]", lin.A[:h, :γ])
x₀, u₀ = lin.x₀, lin.u₀
f(x) = collect(x_deriv(Longitudinal(), (; x, u = u₀)))
say("T7-214 x_deriv call", x_deriv(Longitudinal(), (; x = x₀, u = u₀)))
ε = 1e-6
A_fd = reduce(hcat, [(f(x₀ + ε * e) - f(x₀ - ε * e)) / 2ε for e in eachcol(I(5))])
say("T7-214 fd gap", maximum(abs, A_fd - lin.A))
pkl = labeled(linearize(lsim, RedstoneExamples.longitudinal_taps()))
say("T7-253", (pkl.A == lin.A, pkl.B == lin.B))

off2 = combine(at("plant", set(x = (V = 55.0, θ = solution.θ))),
               set(u = (δe = solution.δe, δt = solution.δt)))
function fly(; deployment...)
    s = Simulation(aircraft(); deployment...)
    init!(s, off2)
    run!(s; t_end = 120.0)
    series(s, reads(V = get_output("plant", :V)))
end
r1 = fly(Δt_frame = 1//100)
say("T7-229 default steps", length(r1.t) - 1)
r2 = fly(Δt_frame = 1, h_max = 1//10)
say("T7-229 h_max=1/10 steps", (length(r2.t) - 1, r2.t[1:4]))
r3 = fly(Δt_frame = 1, h_max = 3//10)
say("T7-229 h_max=3/10 steps", (length(r3.t) - 1, r3.t[1:6]))
say("T7-230 default algorithm", Deployment(build(aircraft()); Δt_frame = 1).algorithm)
try
    fly(Δt_frame = 1)
    say("T7-241", "no error")
catch e
    say("T7-241", sprint(showerror, e))
end

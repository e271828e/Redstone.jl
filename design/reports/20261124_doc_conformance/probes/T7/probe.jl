println("== README")
module R
using Redstone
import Redstone: AbstractComponent, x_init, s_init, u_types, y_types,
    y_state, y_direct, x_deriv, s_update
import Redstone: Absolute, Group, Simulation, init!, run!, set, port, state, build
struct Plant <: AbstractComponent
    ω::Float64
    ζ::Float64
end
x_init(::Plant) = (q = 0.0, v = 0.0)
u_types(::Plant) = Float64
y_types(::Plant) = (y = Float64, power = Float64)
y_state(::Plant, (; x)) = (y = x.q,)
y_direct(::Plant, (; x, u)) = (power = u * x.v,)
x_deriv(p::Plant, (; x, u)) =
    (q = x.v, v = -p.ω^2 * x.q - 2p.ζ * p.ω * x.v + u)
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
println("port ", port(sim, "plant", :y))
println("state ", state(sim, "plant"))
try; build(loop("power")); catch e; showerror(stdout, e); println(); end
println("exports: ", names(Redstone))
end

println("== ch1")
using Redstone
import Redstone: AbstractComponent, x_init, u_types, y_types, y_state, x_deriv
const g = 9.81
@kwdef struct Longitudinal <: AbstractComponent
    m::Float64 = 1000.0
    S::Float64 = 16.0
    c̄::Float64 = 1.5
    Iyy::Float64 = 1800.0
    T_max::Float64 = 2500.0
    ρ::Float64 = 1.225
    CL0::Float64 = 0.3
    CLα::Float64 = 5.0
    CD0::Float64 = 0.03
    k::Float64 = 0.05
    Cm0::Float64 = 0.05
    Cmα::Float64 = -1.0
    Cmq::Float64 = -12.0
    Cmδe::Float64 = -1.2
end
x_init(::Longitudinal) = (V = 50.0, γ = 0.0, θ = 0.0, q = 0.0, h = 1000.0)
u_types(::Longitudinal) = (δe = Float64, δt = Float64)
y_types(::Longitudinal) = (V = Float64, γ = Float64, θ = Float64, q = Float64, h = Float64, α = Float64)
y_state(::Longitudinal, (; x)) = (V = x.V, γ = x.γ, θ = x.θ, q = x.q, h = x.h, α = x.θ - x.γ)
function x_deriv(plant::Longitudinal, (; x, u))
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
     θ = q,
     q = moment / plant.Iyy,
     h = V * sin(γ))
end
import Redstone: Group
aircraft() = Group((; plant = Longitudinal());
                   input_wires = ("δe" => "plant/δe", "δt" => "plant/δt"))
import Redstone: Simulation
try; Simulation(aircraft(); Δt_frame = 0.01); catch e; showerror(stdout, e); println(); end
import Redstone: set, at, combine, init!, run!
off_trim = combine(at("plant", set(x = (V = 55.0, θ = 0.019930))),
                   set(u = (δe = 0.025058, δt = 0.37234)))
sim = Simulation(aircraft(); Δt_frame = 1//100)
init!(sim, off_trim)
println(run!(sim; t_end = 120.0))
import Redstone: series, reads, get_output
flight = series(sim, reads(V = get_output("plant", :V), h = get_output("plant", :h)))
println(typeof(flight), " ", propertynames(flight))
V = flight.V
upward = [flight.t[i] for i in 2:length(V) if V[i - 1] < 50.0 ≤ V[i]]
println((snapshots = length(V), V = extrema(V), h = extrema(flight.h), periods = diff(upward)))
println("h rise over start: ", maximum(flight.h) - 1000.0)
import RedstoneExamples
package_sim = Simulation(RedstoneExamples.aircraft(); Δt_frame = 1//100)
init!(package_sim, off_trim)
run!(package_sim; t_end = 120.0)
package_flight = series(package_sim, reads(V = get_output("plant", :V), h = get_output("plant", :h)))
println("bit-equal: ", (package_flight.V, package_flight.h) == (flight.V, flight.h))
using CairoMakie
fig = Figure()
lines(fig[1, 1], flight.t, flight.V; color = :royalblue, axis = (; ylabel = "V (m/s)"))
lines(fig[2, 1], flight.t, flight.h; color = :darkorange, axis = (; xlabel = "t (s)", ylabel = "h (m)"))
println("fig ", typeof(fig))
println("x_init of sim: ")

println("== ch2")
import Redstone: TrimProblem, get_deriv
level_flight(; V = 50.0, h = 1000.0) = TrimProblem(
    guess = (θ = 0.0, δe = 0.0, δt = 0.5),
    lower = (θ = -0.3, δe = -0.5, δt = 0.0),
    upper = (θ = 0.3, δe = 0.5, δt = 1.0),
    condition = d -> combine(
        at("plant", set(x = (V = V, γ = 0.0, θ = d.θ, q = 0.0, h = h))),
        set(u = (δe = d.δe, δt = d.δt))),
    reads = reads(V̇ = get_deriv("plant", :V), γ̇ = get_deriv("plant", :γ), q̇ = get_deriv("plant", :q)),
    residuals = (derivatives, d) -> (V̇ = derivatives.V̇, γ̇ = derivatives.γ̇, q̇ = derivatives.q̇),
    tolerances = (V̇ = 1e-9, γ̇ = 1e-9, q̇ = 1e-9))
import Redstone: trim!, state
tsim = Simulation(aircraft(); Δt_frame = 1//100)
report = trim!(tsim, level_flight(); baseline = set())
println((status = report.status, iterations = report.n_iterations, solution = report.solution))
println(report.residuals)
println(state(tsim, "plant"))
println(propertynames(report))
plant = Longitudinal()
q̄ = 0.5 * plant.ρ * 50.0^2
CL = plant.m * g / (q̄ * plant.S)
α = (CL - plant.CL0) / plant.CLα
estimate = (θ = α,
            δe = (plant.Cm0 + plant.Cmα * α) / -plant.Cmδe,
            δt = q̄ * plant.S * (plant.CD0 + plant.k * CL^2) / plant.T_max)
println(estimate)
println(map((solved, estimated) -> 100 * (solved / estimated - 1), report.solution, estimate))
import Redstone: lifecycle
slow_sim = Simulation(aircraft(); Δt_frame = 1//100)
slow = trim!(slow_sim, level_flight(V = 20.0); baseline = set())
println((status = slow.status, saturated = slow.saturated, residuals = slow.residuals, lifecycle = lifecycle(slow_sim)))
package_report = trim!(Simulation(aircraft(); Δt_frame = 1//100), RedstoneExamples.level_flight(); baseline = set())
println("pkg trim eq: ", package_report.solution == report.solution)
# trim with default baseline?
try
  s3 = Simulation(aircraft(); Δt_frame = 1//100)
  r3 = trim!(s3, level_flight())
  println("default baseline ok ", r3.status)
catch e; showerror(stdout, e); println(); end

println("== ch3")
solution = report.solution
import Redstone: taps, get_state, get_input, linearize, labeled
using ComponentArrays
aircraft_taps = taps(
    x = (V = get_state("plant", :V), γ = get_state("plant", :γ), θ = get_state("plant", :θ),
         q = get_state("plant", :q), h = get_state("plant", :h)),
    u = (δe = get_input(:δe), δt = get_input(:δt)))
linearization = labeled(linearize(tsim, aircraft_taps))
show(stdout, MIME"text/plain"(), linearization); println()
println((linearization.A[:h, :γ], linearization.A[:θ, :q], linearization.A[:, :h]))
using LinearAlgebra: I, eigvals
x₀, u₀ = linearization.x₀, linearization.u₀
f(x) = collect(x_deriv(Longitudinal(), (; x, u = u₀)))
ε = 1e-6
A_fd = reduce(hcat, [(f(x₀ + ε * e) - f(x₀ - ε * e)) / 2ε for e in eachcol(I(5))])
println("fd gap ", maximum(abs, A_fd - linearization.A))
λs = eigvals(linearization.A)
println(λs)
mode(λ) = (ωn = abs(λ), ζ = -real(λ) / abs(λ), period = 2π / imag(λ))
phugoid, short_period = mode.(sort(filter(λ -> imag(λ) > 0, λs); by = abs))
println(phugoid); println(short_period)
off_trim3 = combine(at("plant", set(x = (V = 55.0, θ = solution.θ))),
                   set(u = (δe = solution.δe, δt = solution.δt)))
function fly(; deployment...)
    flight_sim = Simulation(aircraft(); deployment...)
    init!(flight_sim, off_trim3)
    run!(flight_sim; t_end = 120.0)
    series(flight_sim, reads(V = get_output("plant", :V)))
end
reference = fly(Δt_frame = 1//100)
V_at(flight, t) = flight.V[findfirst(==(t), flight.t)]
compare(flight) = (steps = length(flight.t) - 1,
                   error = maximum(t -> abs(V_at(flight, t) - V_at(reference, t)), 0.0:1.0:120.0))
println("ref steps ", length(reference.t)-1)
try; fly(Δt_frame = 1); catch e; showerror(stdout, e); println(); end
println(compare(fly(Δt_frame = 1, h_max = 1//10)))
import Redstone: BS3
try; fly(Δt_frame = 1, algorithm = BS3()); catch e; showerror(stdout, e); println(); end
println(compare(fly(Δt_frame = 1, algorithm = BS3(), h_min = 1//1000)))
package_linearization = labeled(linearize(tsim, RedstoneExamples.longitudinal_taps()))
println((package_linearization.A == linearization.A, package_linearization.B == linearization.B))
println("== done")

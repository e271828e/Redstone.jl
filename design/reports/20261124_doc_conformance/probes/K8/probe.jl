using Redstone, StaticArrays
import Redstone: Group, Simulation, init!, step!, port, set, state_events, u_types
import Redstone.Library: Integrator, Constant, SumJunction, Junction, Or, And

# 1: reset form adds Bool face and event; default omits both
println("1a default u_types = ", u_types(Integrator()), "  events = ", state_events(Integrator()))
println("1b reset u_types   = ", u_types(Integrator(reset = true)), "  events = ", keys(state_events(Integrator(reset = true))))

# 2: reset held true from boundary zero: fires at t0 (prior starts not-holding), lands on x0, never while held
m = Group((; k = Constant(1.0), r = Constant(true), i = Integrator(x0 = 0.5, reset = true));
          local_wires = ("k/y" => "i/u", "r/y" => "i/reset"))
sim = Simulation(m; Δt_frame = 1//100)
init!(sim, set())
println("2a at t0 y = ", port(sim, "i"))
step!(sim; t_plus = 1//2)
println("2b after 0.5 s held reset y = ", port(sim, "i"), " (0.5 + 0.5 = 1.0 if it fired only once)")

# 3: toy for the invariance claim
struct Q{N,T} <: AbstractVector{T}; v::NTuple{N,T}; end
Base.size(::Q{N}) where N = (N,); Base.getindex(q::Q, i::Int) = q.v[i]
f(x::AbstractVector{Float64}) = sum(x)
println("3 Q{4,Float64} <: AbstractVector{Float64} = ", Q{4,Float64} <: AbstractVector{Float64}, "  f = ", f(Q((1.0,2.0,3.0,4.0))))
println("3b Q{4,Float64} <: AbstractVector{<:Real} = ", Q{4,Float64} <: AbstractVector{<:Real})

println("4 Not admitted: ", isdefined(Redstone.Library, :Not), "  Or/And/SumJunction: ", isdefined(Redstone.Library,:Or), isdefined(Redstone.Library,:And), isdefined(Redstone.Library,:SumJunction))

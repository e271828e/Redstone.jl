module K6aProbe
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const T = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/"
include(T * "imports.jl")
include(T * "fixtures.jl")
include(T * "utils.jl")

const ROUNDS = Ref(0)
const TRACE = Symbol[]

struct Battery <: AbstractComponent
    i_max::Float64
end
m_init(::Battery) = (tripped = false,)
x_init(::Battery) = nothing
u_types(::Battery) = (i_load = Float64,)
y_types(::Battery) = (bus_voltage = Float64,)
y_state(b::Battery, (; m)) = (; bus_voltage = m.tripped ? 0.0 : 24.0)
guard_ovld(b::Battery, (; u)) = u.i_load > b.i_max
function handler_ovld(b::Battery, (; m))
    push!(TRACE, :bat)
    (; m = (; m..., tripped = true))
end
state_events(::Battery) = (ovld = StateEvent(guard_ovld, handler_ovld),)

struct Avionics <: AbstractComponent
    alt_target::Float64
end
m_init(::Avionics) = (captured = false, v_at_capture = -1.0, v_low = -1.0)
x_init(::Avionics) = (alt = 0.0,)
u_types(::Avionics) = (bus_voltage = Float64,)
y_types(::Avionics) = (cap = Bool,)
y_state(::Avionics, (; m)) = (cap = m.captured,)
x_deriv(::Avionics, (; x)) = (alt = 1.0,)
function guard_cap(a::Avionics, (; x)); ROUNDS[] += 1; x.alt >= a.alt_target; end
function handler_cap(a::Avionics, (; m, u))
    push!(TRACE, :avi)
    (; m = (; m..., captured = true, v_at_capture = u.bus_voltage))
end
guard_low(a::Avionics, (; u)) = u.bus_voltage < 18
function handler_low(a::Avionics, (; m, u))
    push!(TRACE, :low)
    (; m = (; m..., v_low = u.bus_voltage))
end
state_events(::Avionics) = (cap = StateEvent(guard_cap, handler_cap),
                            low = StateEvent(guard_low, handler_low))

function world(order)
    comps = order == :ba ? (; bat = Battery(5.0), avi = Avionics(-1.0)) :
                           (; avi = Avionics(-1.0), bat = Battery(5.0))
    Group(comps; local_wires = ("bat/bus_voltage" => "avi/bus_voltage",),
          input_wires = ("i_load" => "bat/i_load",))
end

for order in (:ba, :ab)
    empty!(TRACE); ROUNDS[] = 0
    sim = Simulation(world(order); Δt_frame = 1//10)
    init!(sim, set(u = (i_load = 10.0,)))
    println("probe order=$order trace=$TRACE guard_cap calls=$(ROUNDS[])")
    println("probe  avi modes=", modes(sim, "avi"), " bat modes=", modes(sim, "bat"),
            " bus=", port(sim, "bat", :bus_voltage))
end
println("probe firing_budget default=", Redstone.Deployment(build(world(:ba)); Δt_frame = 1//10).firing_budget)

# same-component twin
sim = Simulation(fed(TwoShot(), "sig"); Δt_frame = 1//10); init!(sim, set(u = (in = 2.0,)))
println("probe TwoShot ", modes(sim, "c"))
sim = Simulation(fed(Preempted(), "sig"); Δt_frame = 1//10); init!(sim, set(u = (in = 2.0,)))
println("probe Preempted ", modes(sim, "c"))
# allocation of the event phase
sim = Simulation(world(:ba); Δt_frame = 1//10); init!(sim, set(u = (i_load = 1.0,)))

# hand off checks: guard bundle names, handler bundle names, build-time event bundle
b = build(world(:ba))
println("probe bundles ", [(c.policies, c.bundle) for c in b.events.components])
# allocation of one boundary round
m = sim.model
boundary!(m, 1)
println("probe alloc boundary! = ", @allocated(boundary!(m, 1)))

try
    g = Group((; f = Follower()); local_wires = ("f/on" => "f/go",))
    build(g)
    println("probe selfwire built ok")
catch e
    println("probe selfwire refused: ", e)
end
end

# The bare-value throw's disposition (§13.4, D-225).
module H1Bare
include(joinpath(@__DIR__, "..", "..", "..", "..", "..", "..", "test", "repl.jl"))
struct BareThrow <: AbstractComponent end
x_init(::BareThrow) = (q = 0.0,)
y_types(::BareThrow) = (q = Float64,)
y_state(::BareThrow, (; x)) = (q = x.q,)
x_deriv(::BareThrow, (; x, t)) = t > 0.05 ? throw(42) : (q = 1.0,)
sim = Simulation(Group((; c = BareThrow())); h = 1//10)
init!(sim)
e = try run!(sim; t_end = 1.0); nothing catch err; err end
println(typeof(e), " ", lifecycle(sim), " ", termination(sim), " status=", sim.model.status)
end

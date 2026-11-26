const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/hosted_catch_review/test"
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test
include(joinpath(W, "imports.jl"))
include(joinpath(W, "utils.jl"))
import Redstone: StateEvent, logged
struct RootLag <: AbstractComponent end
x_init(::RootLag) = (v = 1.0,)
u_types(::RootLag) = (u = Float64,)
y_types(::RootLag) = (v = Float64,)
y_state(::RootLag, (; x)) = (v = x.v,)
x_deriv(::RootLag, (; x, u)) = (v = x.v ≥ 0 ? sqrt(x.v) - u.u : -u.u,)
base(u) = set(u = (in = u,))
# (1) a condition that refuses a negative decision, reached only at the second seeded evaluation
cond(d) = d.v < 0 ? error("condition refuses a negative v") : at("c", set(x = (v = d.v,)))
p1 = TrimProblem(; guess = (v = 1.0,), lower = (v = -Inf,), upper = (v = Inf,), condition = cond,
    reads = reads(v̇ = get_deriv("c", :v)), residuals = (r, d) -> (rate = r.v̇,), tolerances = (rate = 1e-9,))
m = Model(fed(RootLag(), :u); Δt_frame = 1//10); init!(m, base(0.5))
e = failure(() -> trim!(m, p1; baseline = base(-1.0)))
println("condition at the 2nd seeded evaluation: ", typeof(e), " status ", m.status)
# (2) residuals that throw at the committed state only: a handler moves the state at the commit
struct Kick <: AbstractComponent end
x_init(::Kick) = (v = 3.0,)
y_types(::Kick) = (v = Float64,)
y_state(::Kick, (; x)) = (v = x.v,)
x_deriv(::Kick, (; x)) = (v = x.v - 1,)
kick_guard(::Kick, (; x)) = x.v < 2
kick_handler(::Kick, (; x)) = (x = (v = 5.0,),)
state_events(::Kick) = (kick = StateEvent(kick_guard, kick_handler),)
res(r, d) = r.v̇ > 2 ? error("residuals refuse the committed state") : (rate = r.v̇,)
p2 = TrimProblem(; guess = (v = 1.0,), lower = (v = -Inf,), upper = (v = Inf,),
    condition = d -> at("c", set(x = (v = d.v,))), reads = reads(v̇ = get_deriv("c", :v)),
    residuals = res, tolerances = (rate = 1e-9,))
for target in (:model, :sim)
    x = target === :model ? Model(single(Kick()); Δt_frame = 1//10) : Simulation(single(Kick()); Δt_frame = 1//10)
    e = failure(() -> trim!(x, p2; baseline = set()))
    st = target === :model ? x.status : lifecycle(x)
    println("residuals at the committed state [$target]: ", typeof(e), " -> ", st, ", state ", state(x, "c"))
    target === :sim && println("   logged ", length(logged(x)), ", trace ", typeof(trace(x)))
end

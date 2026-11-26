const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/hosted_catch_review/test"
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test
include(joinpath(W, "imports.jl"))
include(joinpath(W, "utils.jl"))
struct RootLag <: AbstractComponent end
x_init(::RootLag) = (v = 1.0,)
u_types(::RootLag) = (u = Float64,)
y_types(::RootLag) = (v = Float64,)
y_state(::RootLag, (; x)) = (v = x.v ≥ -10 ? x.v : throw(DomainError(x.v, "below the floor")),)
x_deriv(::RootLag, (; x, u)) = (v = sqrt(x.v) - u.u,)
struct CutLag <: AbstractComponent end
x_init(::CutLag) = (v = 1.0,)
u_types(::CutLag) = (u = Float64,)
y_types(::CutLag) = (v = Float64,)
y_state(::CutLag, (; x)) = (v = x.v,)
x_deriv(::CutLag, (; x, u)) = x.v < 0 ? throw(InterruptException()) : (v = sqrt(x.v) - u.u,)
prob(g) = TrimProblem(; guess = (v = g,), lower = (v = -Inf,), upper = (v = Inf,),
    condition = d -> at("c", set(x = (v = d.v,))), reads = reads(v̇ = get_deriv("c", :v)),
    residuals = (r, d) -> (rate = r.v̇,), tolerances = (rate = 1e-9,))
base(u) = set(u = (in = u,))
for (comp, u, g, label) in ((RootLag(), 0.0, -20.0, "setup round"), (RootLag(), 0.0, -1.0, "setup derivative"),
                            (RootLag(), -1.0, 1.0, "search"), (CutLag(), -1.0, 1.0, "search interrupt"))
    sim = Simulation(fed(comp, :u); Δt_frame = 1//10)
    init!(sim, base(0.5))
    e = failure(() -> trim!(sim, prob(g); baseline = base(u), t0 = 1//4))
    println("--- ", label, " (lifecycle ", lifecycle(sim), ")\n", sprint(showerror, e))
end
m = Model(fed(RootLag(), :u); Δt_frame = 1//10)
e = failure(() -> linearize(m, taps(x = (v = get_state("c", :v),), u = (;), y = (;));
                            about = combine(base(0.0), at("c", set(x = (v = -20.0,))))))
println("--- linearize about round\n", sprint(showerror, e))

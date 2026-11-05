module P
include(joinpath(pwd(), "design/reports/20261105_docstring_audit/probes/A7/common.jl"))
pm() = Model(fed(Pendulum(), "u"); h = 1//10)
dec2(d) = combine(at("c", set(x = (θ = d.θ, ω = 0.0))), set(u = (in = d.u,)))
p2 = TrimProblem(guess = (θ = 0.0, u = 0.0), lower = (θ = -1.0, u = -1.0), upper = (θ = 1.0, u = 1.0), condition = dec2, reads = both_reads(), residuals = (r, d) -> (a = sqrt(abs(d.u)) + 1.0, b = r.θ - 0.3), tolerances = (a = 1e-6, b = 1e-6))
m = pm(); r = tryit("two decisions, non-finite partial at the guess", () -> trim!(m, p2; baseline = set()))
println("  status ", m.status)
r === nothing || println("  ", r.status, " ", r.converged)
# a claimed, running model: default form
struct T1 <: AbstractComponent end
end

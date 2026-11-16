# M1 variant: van der Pol, μ = 5, from (2, 0), frame 2 s, t_end 24 s; reference RK4 at 2^-13 s.
include(joinpath(@__DIR__, "common.jl"))
import Redstone: x_init, x_deriv, y_types, y_state
using Printf
struct VdP <: AbstractComponent
    μ::Float64
end
x_init(::VdP) = (p = 2.0, v = 0.0)
y_types(::VdP) = (p = Float64, v = Float64)
y_state(::VdP, (; x)) = (p = x.p, v = x.v)
x_deriv(c::VdP, (; x)) = (p = x.v, v = c.μ * (1 - x.p^2) * x.v - x.p)
function vdp_run(alg; h_max = nothing)
    kw = h_max === nothing ? (; h_min = 1 // 2^40) : (; h_max)
    sim = Simulation(Group((; o = VdP(5.0))); Δt_frame = 2 // 1, algorithm = alg, kw...)
    init!(sim; trace = false, log_max = Inf)
    run!(sim; t_end = 24.0)
    s = series(sim, reads(p = get_output("o", :p), v = get_output("o", :v)))
    tops = Dict(round(Int, s.t[i]) => [s.columns.p[i], s.columns.v[i]] for i in eachindex(s.t)
                if abs(s.t[i] / 2 - round(s.t[i] / 2)) < 1e-9)
    (sim, tops)
end
_, R = vdp_run(RK4(); h_max = 1 // 2^13)
_, R12 = vdp_run(RK4(); h_max = 1 // 2^12)
verr(F) = [maximum(abs.(F[k] .- R[k]) ./ max.(1.0, abs.(R[k]))) for k in sort(collect(keys(R)))]
println("reference: frame tops ", length(R), " RK4 2^-12 vs 2^-13 ", maximum(verr(R12)))
println("lab    tol     acc     rej    sweeps    rhs      err_end    err_max   floors")
for lab in ("A", "B_mid", "B_1/9"), tol in (1e-2, 1e-3, 1e-4, 1e-5, 1e-6, 1e-7, 1e-8)
    sim, F = vdp_run(candidate(lab, tol))
    c = sim.model.exec.stepper.c
    E = verr(F)
    @printf("%-6s %.0e %7d %6d %9d %9d  %.3e  %.3e  %d\n", lab, tol, c.accepted, c.attempts - c.accepted,
            c.stage_sweeps + c.accepted, c.stage_rhs, E[end], maximum(E), floor_total(sim))
end

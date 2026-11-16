# Estimate vs true local error of the third-order solution, at every accepted step of M1.
include(joinpath(@__DIR__, "kepler.jl"))
using Printf, Statistics
fs(x) = (r3 = (x[1]^2 + x[2]^2)^1.5; SVector(x[3], x[4], -x[1] / r3, -x[2] / r3))
function ref_step(x, h, n)
    x = SVector{4}(x); δ = h / n
    for _ in 1:n
        k1 = fs(x); k2 = fs(x + δ / 2 * k1); k3 = fs(x + δ / 2 * k2); k4 = fs(x + δ * k3)
        x = x + δ / 6 * (k1 + 2k2 + 2k3 + k4)
    end
    x
end
q(v, p) = quantile(v, p)
for (lab, tol) in (("A'", 1e-4), ("B_mid", 1e-4), ("A'", 1e-6), ("B_mid", 1e-6), ("C", 1e-2))
    alg = candidate(lab, tol)
    sim = Simulation(kepler_model(); Δt_frame = 2 // 1, h_min = 1 // 2^40, algorithm = alg)
    init!(sim)
    st = sim.model.exec.stepper; st.tracing = true
    run!(sim; t_end = 20.0)
    ratios = Float64[]; peri = Float64[]; apo = Float64[]; chk = 0.0
    for (j, (t, h, x0, x1, est, err)) in enumerate(st.trace)
        h < 1e-6 && continue                     # the start-up steps after the floor
        n = 2000
        xr = ref_step(x0, h, n)
        if j % 97 == 0                            # reference converged?
            chk = max(chk, maximum(abs, ref_step(x0, h, 2n) - xr) / max(maximum(abs, xr - x1), 1e-300))
        end
        sc = alg.abstol .+ alg.reltol .* max.(abs.(x0), abs.(x1))
        trueerr = maximum(abs.(x1 .- xr) ./ sc)
        ρ = err / trueerr
        push!(ratios, ρ)
        r = hypot(x0[1], x0[2])
        r < 0.5 && push!(peri, ρ); r > 1.5 && push!(apo, ρ)
    end
    @printf("%-6s tol %.0e: n=%d  ratio est/true: min %.2f  q05 %.2f  q25 %.2f  med %.2f  q75 %.2f  q95 %.2f  max %.1f  under(<1) %.1f%%  q95/q05 %.1f\n",
            lab, tol, length(ratios), minimum(ratios), q(ratios, 0.05), q(ratios, 0.25), median(ratios), q(ratios, 0.75),
            q(ratios, 0.95), maximum(ratios), 100 * count(<(1), ratios) / length(ratios), q(ratios, 0.95) / q(ratios, 0.05))
    @printf("        pericentre r<0.5: n=%d med %.2f [q05 %.2f, q95 %.2f]; apocentre r>1.5: n=%d med %.2f [q05 %.2f, q95 %.2f]; ref check %.1e\n",
            length(peri), median(peri), q(peri, 0.05), q(peri, 0.95), length(apo), median(apo), q(apo, 0.05), q(apo, 0.95), chk)
end

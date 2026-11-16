# M2: the example closed loop, flown as test_longitudinal.jl's fly_closed_loop (cascade, step at 5 s, noise).
include(joinpath(@__DIR__, "m_common.jl"))
const SOL, GAINS = trim_solution()
function fly(; deployment...)
    h = 1 // 200
    frame(t) = round(Int, t / h)
    sim = Simulation(closed_loop(SOL, GAINS); Δt_frame = h, deployment...)
    init!(sim, trimmed(SOL); trace = false, log_max = 2)
    X = zeros(frame(120.0) + 1, 5)
    rec(k) = (p = state(sim, "plant"); X[k+1, :] .= (p.V, p.γ, p.θ, p.q, p.h))
    rec(0)
    for k in 1:frame(120.0)
        k == frame(5.0) && stage!(sim, "h_ref" => 1000.0 + 50.0)   # staged before frame 1000, as the test does
        step!(sim; frames = 1); rec(k)
    end
    (sim, X)
end
ref, R = fly(; algorithm = RK4(), h_max = 1 // 200 // 32)
_, R16 = fly(; algorithm = RK4(), h_max = 1 // 200 // 16)
println("reference: n=", size(R, 1), " RK4 h/32 vs h/16 max err ", maximum(snap_errors(R16, R)),
        " h(t=120)=", R[end, 5], " max h=", maximum(R[:, 5]))
labs = length(ARGS) > 0 ? ARGS : ["A", "A'", "B_mid", "B_1/9"]
tols = (1e-2, 1e-3, 1e-4, 1e-5, 1e-6, 1e-7)
println("lab    tol     acc     rej  st_sweeps  sweeps_tot    rhs      err_end    err_max   floors")
for lab in labs, tol in (lab == "C" ? (1e-2, 1e-3) : tols)
    sim, X = fly(; algorithm = candidate(lab, tol), h_min = 1 // 2^40)
    E = snap_errors(X, R)
    c = sim.model.exec.stepper.c
    @printf("%-6s %.0e %7d %6d %9d %9d %9d  %.3e  %.3e  %d\n", lab, tol, c.accepted, c.attempts - c.accepted,
            c.stage_sweeps, c.stage_sweeps + c.accepted, c.stage_rhs, E[end], maximum(E), floor_total(sim))
    flush(stdout)
end

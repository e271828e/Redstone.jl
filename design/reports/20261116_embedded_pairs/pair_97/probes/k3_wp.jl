# M1 work-precision: Kepler e = 0.8, frame 2 s, t_end 20 s.
include(joinpath(@__DIR__, "kepler.jl"))
using Printf
tols = (1e-2, 1e-3, 1e-4, 1e-5, 1e-6, 1e-7, 1e-8)   # 1e-8 only to cover interpolation
labs = ("A", "B_mid", "B_1/9", "B_4/9")
res = Dict{String,Vector{Any}}()
println("lab    tol     acc     rej    sweeps    rhs      err_end    err_max   floors")
for lab in labs, tol in tols
    r = kepler_run(candidate(lab, tol))
    @assert r.sweeps == r.stage_sweeps + r.acc && r.rhs == r.stage_rhs
    push!(get!(res, lab, Any[]), r)
    @printf("%-6s %.0e %7d %6d %9d %9d  %.3e  %.3e  %d\n", lab, tol, r.acc, r.rej, r.sweeps, r.rhs, r.err_end, r.err_max, r.floors)
end
for tol in (get(ENV, "SKIPC", "0") == "1" ? () : (1e-2, 1e-3))
    r = kepler_run(candidate("C", tol))
    @printf("%-6s %.0e %7d %6d %9d %9d  %.3e  %.3e  %d\n", "C", tol, r.acc, r.rej, r.sweeps, r.rhs, r.err_end, r.err_max, r.floors)
end
# work at fixed achieved error, interpolated log-log
for (metric, f) in (("rhs", r -> r.rhs), ("sweeps", r -> r.sweeps), ("accepted", r -> r.acc)), (ename, g) in (("err_end", r -> r.err_end), ("err_max", r -> r.err_max))
    println("-- work ($metric) at achieved $ename; ratio to A")
    for target in (1e-1, 1e-3, 1e-5)
        wa = work_at(g.(res["A"]), f.(res["A"]), target)
        line = @sprintf("  %.0e: A %8.0f", target, wa)
        for lab in labs[2:end]
            w = work_at(g.(res[lab]), f.(res[lab]), target)
            line *= @sprintf("  %s %8.0f (%.3f)", lab, w, w / wa)
        end
        println(line)
    end
end

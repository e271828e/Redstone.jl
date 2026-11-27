# r07: the approach's "no loop saturates"; the legacy closed_loop's anchors; the deployment without
# Δt_base on piloted.
include(joinpath(@__DIR__, "r00_common.jl"))
import Redstone: warnings
solution = trim_solution()
sim = Simulation(RE.approach(solution); DEP...)
init!(sim, at("vehicle", RE.hand_flown(solution)); log_max = Inf)
by_hand!(sim, solution; until = 60.0); sink!(sim)
t = logged_times(sim)
for (loop, lo, hi) in (("h_ctl", -0.26, 0.26), ("θ_ctl", -0.5, 0.5), ("q_ctl", -0.5, 0.5), ("V_ctl", 0.0, 1.0))
    u = logged_port(sim, "vehicle/cascade/$loop", :u)
    for (a, b) in ((30.2, t[end]), (60.0, t[end]), (160.0, t[end] - 1))
        w = window(sim, a, b)
        @printf("%s over [%.1f, %.1f): u in [%.4f, %.4f], limits [%.2f, %.2f], on a limit %d\n", loop, a, b,
                minimum(u[w]), maximum(u[w]), lo, hi, count(x -> x <= lo + 1e-12 || x >= hi - 1e-12, u[w]))
    end
end
import RedstoneExamples: lqr_gains, longitudinal_taps
import Redstone: linearize
tsim = Simulation(RE.aircraft(); Δt_frame = 1//100)
trim!(tsim, RE.level_flight(); baseline = set(u = (δe = 0.0, δt = 0.5)))
gains = lqr_gains(linearize(tsim, longitudinal_taps()))
b = build(RE.closed_loop(solution, gains))
println("closed_loop anchors: ", length(b.structure.anchors))
s2 = Simulation(RE.piloted(solution); Δt_frame = 1//400)
rows = s2.model.deployment.schedule.rows
println("piloted at Δt_frame = 1//400 alone: h_ctl Δt = ", Dict(r.path => r.Δt for r in rows)["cascade/h_ctl"], ", warnings ", length(warnings(s2)))

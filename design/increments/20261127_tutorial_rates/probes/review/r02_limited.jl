# r02: B11's limited time. The attitude loop's limit cut to ±0.05 rad/s, the 50 m step in the
# initial condition, 120 s, the shipped deployment. The time on the limit is the count of logged
# snapshots with |u| at the limit times the frame, 2.5 ms; also the count of the loop's own ticks
# on the limit times its period, read off the 50 Hz grid.
include(joinpath(@__DIR__, "r00_common.jl"))
solution = trim_solution()
function limited(; kw...)
    sim = climb(my_autopilot(solution; θ_lim = 0.05, kw...), solution)
    u = logged_port(sim, "cascade/θ_ctl", :u)
    t = logged_times(sim)
    by_log = count(x -> abs(x) >= 0.05 - 1e-12, u) / 400
    ticks = [abs(u[i]) >= 0.05 - 1e-12 for i in eachindex(t) if on50(t[i])]
    (by_log, count(ticks) * 0.02)
end
on50(t) = isapprox(50t, round(50t); atol = 1e-9)
all50 = (imu = 4, ins = 4, air_data = 4)
for (label, kw) in (("hold, three rates", (;)),
                    ("hold, loops 50 Hz, IMU+INS 50 Hz, air data 10 Hz", (mc = all50, ms = (imu = 4, ins = 4, air_data = 20))),
                    ("hold, loops 50 Hz, IMU 200 Hz, INS 50, air data 10 Hz", (mc = all50, ms = SHIPPED)),
                    ("no hold, three rates", (hold = false,)))
    on = limited(; kw...)
    off = limited(; kw..., noise_psd = QUIET)
    @printf("%-55s noise on %.3f s (ticks %.3f)   off %.3f s (ticks %.3f)\n", label, on..., off...)
end
sim = climb(RE.autopilot(solution), solution)
@printf("shipped limits: max |θ_ctl u| = %.4f (limit 0.5)\n", maximum(abs, logged_port(sim, "cascade/θ_ctl", :u)))

# p06: the companion's comparisons on the source's model, through the knobs. (1) The limited time
# with the attitude loop cut to ±0.05 rad/s: at the three rates, with every loop and sensor at the
# base tick (multipliers 1, 1, 1), and with no hold. (2) The sensor table: the air data system at
# 50 Hz read by its 10 Hz loops (`air_data_sensor = 4`), the air data and its loops at 50 Hz, and
# the shipped 10 Hz air data; same densities throughout.
include("common.jl")
include("knobs.jl")
solution = trim_solution()
Δt_base = 1//200
function limited(m; hold = true)
    knobs!(θ_lim = 0.05, hold = hold, m = m)
    if hold
        sim = fly_autopilot(solution; Δt_base)
    else
        sim = Simulation(autopilot_free(solution); Δt_frame = 1//200, Δt_base)
        init!(sim, override(cruise(solution), set(u = (h_ref = 1050.0,))))
        run!(sim; t_end = 120.0)
    end
    knobs!()
    limited_time(sim, 0.05)
end
println("limited, three rates: ", limited((imu = 1, ins = 4, air_data = 20)))
println("limited, every loop at 200 Hz: ", limited((imu = 1, ins = 1, air_data = 1)))
println("limited, every loop at 50 Hz (the base tick 1//200, multipliers 4, 4, 4): ", limited((imu = 4, ins = 4, air_data = 4)))
println("limited, no hold, three rates: ", limited((imu = 1, ins = 4, air_data = 20); hold = false))
for (label, sensor, loops) in (("air data at 50 Hz, loops at 10 Hz", 4, 20), ("air data and its loops at 50 Hz", 4, 4),
                               ("air data and its loops at 10 Hz", 20, 20))
    knobs!(m = (imu = 1, ins = 4, air_data = loops), air_data_sensor = sensor)
    f = figures5(fly_autopilot(solution; Δt_base))
    @printf("%-36s late_h %.4f late_V %.4f peak %.3f\n", label, f.late_h, f.late_V, f.peak)
end
knobs!()
src = figures5(fly_autopilot(solution; Δt_base))
println("knob copies at defaults: ", fmt(src))

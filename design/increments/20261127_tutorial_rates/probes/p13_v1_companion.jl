# p13: the companion's figures re-read under V1 (frame 1//400, base 1//200). The limited time at
# ±0.05 rad/s, like with like: three rates; every loop and the IMU and INS at 50 Hz with the air
# data at 10 Hz; no hold at three rates; each with all four noises and with none. Then the
# approach at full log resolution.
include("common.jl")
include("knobs.jl")
solution = trim_solution()
dep = (Δt_frame = 1//400, Δt_base = 1//200)
on_limit(sim) = count(u -> abs(u) >= 0.05 - 1e-12, logged_port(sim, "cascade/θ_ctl", :u)) / 400
function limited(m, sensor, hold, noise_psd)
    knobs!(θ_lim = 0.05, hold = hold, m = m, air_data_sensor = sensor)
    if hold
        sim = Simulation(autopilot(solution; noise_psd); dep...)
    else
        sim = Simulation(autopilot_free(solution; noise_psd); dep...)
    end
    init!(sim, override(cruise(solution), set(u = (h_ref = 1050.0,))))
    run!(sim; t_end = 120.0)
    knobs!()
    on_limit(sim)
end
for (label, m, sensor, hold) in (("hold, three rates", (imu = 1, ins = 4, air_data = 20), nothing, true),
                                 ("hold, loops 50 Hz, air data 10 Hz", (imu = 4, ins = 4, air_data = 4), 20, true),
                                 ("no hold, three rates", (imu = 1, ins = 4, air_data = 20), nothing, false))
    @printf("%-36s all noise %.3f s   no noise %.3f s\n", label, limited(m, sensor, hold, RE.sensor_noise_psd), limited(m, sensor, hold, QUIET))
end
flight = Simulation(approach(solution); dep...)
init!(flight, at("vehicle", hand_flown(solution)); log_max = Inf)
f(t) = round(Int, t * 400)
step!(flight; frames = f(5.0)); stage!(flight, "δe_pilot" => solution.δe - 0.02)
step!(flight; frames = f(7.0) - f(5.0)); stage!(flight, "δe_pilot" => solution.δe)
step!(flight; frames = f(30.0) - f(7.0)); stage!(flight, "engage" => true)
step!(flight; frames = f(60.0) - f(30.0))
descend!(flight)
println("approach, full resolution: ", fmt(figures7(flight)))

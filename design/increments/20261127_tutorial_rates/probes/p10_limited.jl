# p10: the limited time at ±0.05 rad/s decomposed: increment 1's two models rebuilt through the
# knobs (Δt_base = 1//50, limiters and delays at 50 Hz, only the altimeter's noise), then the
# single-rate variant of the report changed one factor at a time.
include("common.jl")
include("knobs.jl")
solution = trim_solution()
h_only = (q = 0.0, θ = 0.0, h = 1.8e-3, V = 0.0)
cases = [("I1 two rates: base 1//50, loops 50/50/10, air data 10 Hz, limiters 50 Hz, h noise", 1//50, (imu = 1, ins = 1, air_data = 5), nothing, h_only),
         ("I1 one rate: base 1//50, loops 50, air data 10 Hz, limiters 50 Hz, h noise", 1//50, (imu = 1, ins = 1, air_data = 1), 5, h_only),
         ("I1 one rate, air data 50 Hz: base 1//50, all 50 Hz, h noise", 1//50, (imu = 1, ins = 1, air_data = 1), nothing, h_only),
         ("report's one rate: base 1//200, loops and sensors 50 Hz, limiters 200 Hz, all noise", 1//200, (imu = 4, ins = 4, air_data = 4), nothing, RE.sensor_noise_psd),
         ("  same, h noise only", 1//200, (imu = 4, ins = 4, air_data = 4), nothing, h_only),
         ("  same, h noise only, air data at 10 Hz", 1//200, (imu = 4, ins = 4, air_data = 4), 20, h_only),
         ("  same, all noise, air data at 10 Hz", 1//200, (imu = 4, ins = 4, air_data = 4), 20, RE.sensor_noise_psd),
         ("  same, no noise, air data 50 Hz", 1//200, (imu = 4, ins = 4, air_data = 4), nothing, QUIET),
         ("report's three rates, all noise", 1//200, (imu = 1, ins = 4, air_data = 20), nothing, RE.sensor_noise_psd),
         ("  three rates, h noise only", 1//200, (imu = 1, ins = 4, air_data = 20), nothing, h_only),
         ("  three rates, no noise", 1//200, (imu = 1, ins = 4, air_data = 20), nothing, QUIET),
         ("I1 two rates, no noise", 1//50, (imu = 1, ins = 1, air_data = 5), nothing, QUIET),
         ("I1 one rate, no noise", 1//50, (imu = 1, ins = 1, air_data = 1), nothing, QUIET)]
for (label, Δt_base, m, sensor, noise_psd) in cases
    knobs!(θ_lim = 0.05, m = m, air_data_sensor = sensor)
    sim = fly_autopilot(solution; Δt_base, noise_psd)
    u = logged_port(sim, "cascade/θ_ctl", :u)
    t = logged_times(sim)
    lim = findall(x -> abs(x) >= 0.05 - 1e-12, u)
    span = isempty(lim) ? "none" : @sprintf("%.3f to %.3f", t[first(lim)], t[last(lim)])
    @printf("%-90s %.2f s (%s)\n", label, length(lim) / 200, span)
end

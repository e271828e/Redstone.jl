# p02: the candidates of seam 1, as Δt_base and (IMU, INS, air data), each a change of the
# constant and of the deployment. Untuned gains, Tt = 0.02, delays and limiters at the base tick.
# Two noise settings: `h only` (today's altimeter density, the other three off) and `all`
# (the source's four densities). Figures: chapter 5's climb, the limited time with the attitude
# loop cut to ±0.05 rad/s (hold on, off), chapter 6's gaps, latch and jumps, chapter 7's approach.
include("common.jl")
include("knobs.jl")
solution = trim_solution()
candidates = [(1//200, (imu = 1, ins = 4, air_data = 20)),
              (1//100, (imu = 1, ins = 2, air_data = 10)),
              (1//100, (imu = 1, ins = 5, air_data = 10)),
              (1//50, (imu = 1, ins = 5, air_data = 10)),
              (1//50, (imu = 1, ins = 5, air_data = 25)),
              (1//400, (imu = 1, ins = 8, air_data = 40)),
              (1//200, (imu = 1, ins = 2, air_data = 20)),
              (1//200, (imu = 1, ins = 4, air_data = 40))]
noises = [("h only", (q = 0.0, θ = 0.0, h = 1.8e-3, V = 0.0)), ("all", RE.sensor_noise_psd)]
only_first = length(ARGS) > 0 && ARGS[1] == "first"
# The multipliers are the knob `m`, every `knobs!` call of the candidate carrying it.
const DEFAULT_M = Ref{Any}(nothing)
knobs_m!(; kw...) = knobs!(; m = DEFAULT_M[], kw...)
function probe_candidate(Δt_base, m)
    period = Rational(Δt_base * m.air_data)
    println("== Δt_base = $Δt_base, $m: ", round.(1 ./ Float64.((Δt_base * m.imu, Δt_base * m.ins, Δt_base * m.air_data)); digits = 2), " Hz")
    knobs_m!()
    rows = Simulation(piloted(solution); Δt_frame = 1//200, Δt_base).model.deployment.schedule.rows
    println("  D: ", join(("$(r.path)=$(r.D)" for r in rows if r.path in ("cascade/h_ctl", "cascade/θ_ctl", "cascade/q_ctl",
            "sensing/imu/q_meas", "sensing/ins/θ_meas", "sensing/air_data/h_meas", "selection/latch")), " "))
    for (label, noise_psd) in noises
        knobs_m!()
        climb = fly_autopilot(solution; Δt_base, noise_psd)
        println("  [$label] ch5 ", fmt(figures5(climb)))
        knobs_m!(θ_lim = 0.05)
        held = limited_time(fly_autopilot(solution; Δt_base, noise_psd), 0.05)
        knobs_m!(θ_lim = 0.05, hold = false)
        sim = Simulation(autopilot_free(solution; noise_psd); Δt_frame = 1//200, Δt_base)
        init!(sim, override(cruise(solution), set(u = (h_ref = 1050.0,))))
        run!(sim; t_end = 120.0)
        free = limited_time(sim, 0.05)
        println("  [$label] limited at ±0.05: hold $(held) s, no hold $(free) s")
        knobs_m!()
        println("  [$label] ch6 ", fmt(figures6(fly_piloted(solution; Δt_base, noise_psd))))
        flight, _, n = fly_approach(solution; Δt_base, noise_psd, period)
        println("  [$label] ch7 writes=$n ", fmt(figures7(flight)))
    end
end
for (Δt_base, m) in (only_first ? candidates[1:1] : candidates)
    DEFAULT_M[] = m
    probe_candidate(Δt_base, m)
end

# p05: every pin of chapters 5 to 8 on the source as it stands (candidate A, the source's four
# densities), with the noise deviations per sensor and chapter 6's gaps over 20 alignments of the
# pilot's writes, each 5 ms later than the last.
include("common.jl")
solution = trim_solution()
Δt_base = 1//200
nps = RE.sensor_noise_psd

rest = fly_autopilot(solution; Δt_base, h_step = 0.0, noise_psd = QUIET, t_end = 60.0)
@printf("ch5 rest drift h %.2e V %.2e θ %.2e\n", maximum(abs, logged_port(rest, "plant", :h) .- 1000),
        maximum(abs, logged_port(rest, "plant", :V) .- 50), maximum(abs, logged_port(rest, "plant", :θ) .- solution.θ))
climb = fly_autopilot(solution; Δt_base)
f5 = figures5(climb)
println("ch5 climb ", fmt(f5), "  V_exc full=", f5.V_exc)
t = logged_times(climb)
for (loop, hz) in (("h_ctl", 10), ("V_ctl", 10), ("θ_ctl", 50), ("q_ctl", 200))
    ch = change_times(climb, logged_port(climb, "cascade/$loop", :u))
    println("ch5 $loop changes ", length(ch), " on own grid ", all(t -> on_grid(t, hz), ch),
            " all on 10 Hz ", all(t -> on_grid(t, 10), ch), " all on 50 Hz ", all(t -> on_grid(t, 50), ch))
end
for (face, name, hz) in ((:q_meas, :q, 200), (:θ_meas, :θ, 50), (:h_meas, :h, 10), (:V_meas, :V, 10))
    meas = logged_face(climb, "sensing", face)
    ch = change_times(climb, meas)
    ticks = on_grid.(t, hz)
    noise = (meas .- logged_port(climb, "plant", name))[ticks]
    @printf("ch5 %s changes %d own grid %s coarser %s  std %.6g  declared %.6g  ratio %.4f  n=%d\n", face, length(ch),
            all(x -> on_grid(x, hz), ch), hz == 10 ? "-" : string(all(x -> on_grid(x, hz == 200 ? 50 : 10), ch)),
            std(noise), sqrt(nps[name] * hz), std(noise) / sqrt(nps[name] * hz), length(noise))
end
hn = (logged_face(climb, "sensing", :h_meas) .- logged_port(climb, "plant", :h))[on_grid.(t, 10)]
Vn = (logged_face(climb, "sensing", :V_meas) .- logged_port(climb, "plant", :V))[on_grid.(t, 10)]
c = sum((hn .- mean(hn)) .* (Vn .- mean(Vn))) / (length(hn) - 1) / std(hn) / std(Vn)
@printf("ch5 h and V noise correlation %.4f\n", c)

hand = fly_piloted(solution; Δt_base)
println("ch6 ", fmt(figures6(hand)))
gaps = [figures6(fly_piloted(solution; Δt_base, offset)) for offset in 0:19]
for name in (:gap_δe, :gap_δt, :gap_hθm, :gap_θqm, :gap_hθ, :gap_θq)
    v = [g[name] for g in gaps]
    @printf("ch6 sweep %-8s min %.5f max %.5f\n", name, minimum(v), maximum(v))
end
flight, top, n = fly_approach(solution; Δt_base)
println("ch7 writes $n ", fmt(figures7(flight)), " t_stop full=", termination(flight).t, " h_stop=", state(flight, "vehicle/plant").h)
second = Simulation(approach(solution); Δt_frame = 1//200, Δt_base)
restore!(second, top)
descend!(second; sink_rate = 2.0)
println("ch8 second t ", termination(second).t)

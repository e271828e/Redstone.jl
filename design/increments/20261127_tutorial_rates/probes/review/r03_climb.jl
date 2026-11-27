# r03: chapter 5's figures on the shipped deployment. The noises' deviations per sample, read off
# the noise leaves at their own ticks and off measurement minus plant; their correlations by draw
# index; the air data's rate table; the step's figures; the rest drift; the log's off-grid count.
include(joinpath(@__DIR__, "r00_common.jl"))
solution = trim_solution()
sim = climb(RE.autopilot(solution), solution)
t = logged_times(sim)
on(t, hz) = isapprox(hz * t, round(hz * t); atol = 1e-9)
draws = Dict{Symbol,Vector{Float64}}()
for (var, grp, hz) in ((:q, "imu", 200), (:θ, "ins", 50), (:h, "air_data", 10), (:V, "air_data", 10))
    n = logged_port(sim, "sensing/$grp/$(var)_noise", "")
    m = logged_face(sim, "sensing", Symbol(var, :_meas))
    p = logged_port(sim, "plant", var)
    ticks = on.(t, hz)
    draws[var] = n[ticks]
    # a change of the noise or the measurement off its grid
    offn = count(i -> n[i] != n[i - 1] && !on(t[i], hz), 2:length(t))
    offm = count(i -> m[i] != m[i - 1] && !on(t[i], hz), 2:length(t))
    @printf("%s: σ draws %.7g  σ(meas-plant at ticks) %.7g  expected %.7g  n=%d  off-grid changes noise %d meas %d  max|meas-plant-noise| at ticks %.2e\n",
            var, std(draws[var]), std((m .- p)[ticks]), sqrt(RE.sensor_noise_psd[var] * hz), count(ticks), offn, offm,
            maximum(abs, (m .- p .- n)[ticks]))
end
for (a, b) in ((:h, :V), (:q, :θ), (:q, :h), (:q, :V), (:θ, :h), (:θ, :V))
    k = min(length(draws[a]), length(draws[b]))
    @printf("cor by draw index %s,%s: %.4f   (n = %d)\n", a, b, cor(draws[a][1:k] , draws[b][1:k]), k)
end
println("snapshots ", length(t), ", off the 200 Hz grid ", count(x -> !on(x, 200), t))
function figs(s)
    t = logged_times(s); h = logged_port(s, "plant", :h); V = logged_port(s, "plant", :V)
    late = t .>= 75
    iV = argmax(abs.(V .- 50))
    lastout = findlast(x -> abs(x - 1050) > 1, h)
    (late_h = maximum(abs, h[late] .- 1050), late_V = maximum(abs, V[late] .- 50), peak = maximum(h),
     exc = abs(V[iV] - 50), t_exc = t[iV], within1 = t[lastout + 1])
end
f = figs(sim)
@printf("shipped: late h %.4f  late V %.4f  peak %.3f  excursion %.4f at %.4f s  within 1 m from %.4f s\n", f...)
for (label, ms, mc) in (("air data 50 Hz, its loops 10 Hz", (imu = 1, ins = 4, air_data = 4), SHIPPED),
                        ("air data and loops 50 Hz", (imu = 1, ins = 4, air_data = 4), (imu = 1, ins = 4, air_data = 4)),
                        ("air data and loops 10 Hz", SHIPPED, SHIPPED))
    g = figs(climb(my_autopilot(solution; ms, mc), solution))
    @printf("%-34s late h %.4f  late V %.4f  peak %.3f\n", label, g.late_h, g.late_V, g.peak)
end
rest = climb(RE.autopilot(solution; noise_psd = QUIET), solution; h_step = 0.0, t_end = 60.0)
@printf("rest drift: h %.2e  V %.2e  θ %.2e\n", maximum(abs, logged_port(rest, "plant", :h) .- 1000),
        maximum(abs, logged_port(rest, "plant", :V) .- 50), maximum(abs, logged_port(rest, "plant", :θ) .- solution.θ))

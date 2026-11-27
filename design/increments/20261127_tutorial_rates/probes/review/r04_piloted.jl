# r04: chapter 6's figures on the shipped deployment, and the instants a staged `engage` reaches
# its readers without the latch.
include(joinpath(@__DIR__, "r00_common.jl"))
solution = trim_solution()
hand = hand_sim(RE.piloted(solution), solution)
t = logged_times(hand)
on(x, hz) = isapprox(hz * x, round(hz * x); atol = 1e-9)
staged = series(hand, reads(δe = get_input("δe_pilot"), engage = get_input("engage")))
pull = findfirst(!=(solution.δe), staged.δe)
release = findfirst(==(solution.δe), staged.δe[pull:end]) + pull - 1
eng = findfirst(identity, staged.engage)
@printf("snapshots: pull %d (t %.4f)  release %d  engage %d (t %.4f)\n", pull, t[pull], release, eng, t[eng])
h = logged_port(hand, "plant", :h)
w = window(hand, 0, 30)
@printf("by hand: h from %.2f to %.2f\n", minimum(h[w]), maximum(h[w]))
sel_e, sel_t = logged_face(hand, "selection", :δe), logged_face(hand, "selection", :δt)
@printf("standby gaps: δe [8,30) %.5f   δt [5,30) %.5f\n",
        largest_gap(logged_face(hand, "cascade", :δe), sel_e, hand, 8, 30),
        largest_gap(logged_face(hand, "cascade", :δt), sel_t, hand, 5, 30))
@printf("outer gaps: h_ctl-θ_meas %.5f   θ_ctl-q_meas %.5f\n",
        largest_gap(logged_port(hand, "cascade/h_ctl", :u), logged_face(hand, "sensing", :θ_meas), hand, 8, 30),
        largest_gap(logged_port(hand, "cascade/θ_ctl", :u), logged_face(hand, "sensing", :q_meas), hand, 8, 30))
sw = findfirst(identity, logged_face(hand, "selection", :engaged))
@printf("latched engaged first true at %.4f\n", t[sw])
@printf("jumps at the switch: δe %.6f  δt %.6f  (δt/0.0025 = %.2f ticks)\n",
        abs(sel_e[sw] - sel_e[sw - 1]), abs(sel_t[sw] - sel_t[sw - 1]), abs(sel_t[sw] - sel_t[sw - 1]) / 0.0025)
lim_t = logged_port(hand, "actuators/δt_limiter", "")
ticks = [i for i in eachindex(t) if on(t[i], 200)]
@printf("δt limiter: largest step per base tick %.6f; after the switch it equals the selected command from %.4f s\n",
        maximum(abs, diff(lim_t[ticks])), t[findfirst(k -> k > sw && abs(lim_t[k] - sel_t[k]) < 1e-12, eachindex(t))])
act_e = logged_port(hand, "actuators/δe_lag", "")
plant_δe_name = "actuators δe"
unengaged = hand_sim(RE.piloted(solution), solution; until = 31.0, engage = false)
ue = logged_port(unengaged, "actuators/δe_lag", "")
@printf("actuator elevator: moves %.3e in the 2.5 ms after the switch (unengaged flight: %.3e; difference %.3e); over 5 ms %.3e\n",
        act_e[sw + 1] - act_e[sw], ue[sw + 1] - ue[sw], (act_e[sw + 1] - act_e[sw]) - (ue[sw + 1] - ue[sw]),
        act_e[sw + 2] - act_e[sw])
idx = [i for i in eachindex(t) if on(t[i], 200) && 80 <= t[i] < 90]
@printf("elevator command, largest change between two of its ticks over [80,90): %.5f; frame to frame %.5f\n",
        maximum(abs, diff(sel_e[idx])), largest_jump(sel_e, hand, 80, 90))
@printf("recapture over [80,90): %.4f\n", maximum(abs, h[window(hand, 80, 90)] .- 1000))
tu = logged_times(unengaged)
for loop in ("q_ctl", "θ_ctl", "h_ctl", "V_ctl")
    a = logged_port(hand, "cascade/$loop", :u); b = logged_port(unengaged, "cascade/$loop", :u)
    k = findfirst(i -> a[i] != b[i], 1:length(b))
    @printf("latched: %s first departs from the unengaged flight at %.5f\n", loop, t[k])
end
# Without the latch, `engage` read straight by the switches and the cascade.
direct = hand_sim(my_piloted(solution; latch = false), solution; until = 31.0)
td = logged_times(direct)
de = logged_face(direct, "selection", :δe); dp = series(direct, reads(δe = get_input("δe_pilot"))).δe
@printf("no latch: engage read back true from %.5f; the selected elevator leaves the pilot's at %.5f\n",
        td[findfirst(identity, series(direct, reads(e = get_input("engage"))).e)],
        td[findfirst(k -> td[k] > 29.9 && de[k] != dp[k], eachindex(td))])
# Without the latch and with the switches held on the pilot, the plant never sees the engage, so a
# controller departs from the unengaged flight one of its periods after the tick that reads it.
held = hand_sim(my_piloted(solution; latch = false, switches = false), solution; until = 31.0)
held0 = hand_sim(my_piloted(solution; latch = false, switches = false), solution; until = 31.0, engage = false)
th = logged_times(held)
println("held switches: plant identical: ", logged_port(held, "plant", :h) == logged_port(held0, "plant", :h))
for (loop, period) in (("q_ctl", 0.005), ("θ_ctl", 0.02), ("h_ctl", 0.1), ("V_ctl", 0.1))
    a = logged_port(held, "cascade/$loop", :u); b = logged_port(held0, "cascade/$loop", :u)
    k = findfirst(i -> a[i] != b[i], eachindex(a))
    @printf("held switches: %s departs at %.5f, so reads the engage at %.5f\n", loop, th[k], th[k] - period)
end

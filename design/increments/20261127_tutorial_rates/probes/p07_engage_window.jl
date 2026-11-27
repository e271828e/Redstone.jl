# p07: the first instant each controller departs from the unengaged flight, on the source.
include("common.jl")
solution = trim_solution()
hand = fly_piloted(solution; Δt_base = 1//200)
unengaged = Simulation(piloted(solution); Δt_frame = 1//200, Δt_base = 1//200)
init!(unengaged, hand_flown(solution))
fly_by_hand!(unengaged, solution; until = 30.4, engage = false)
t = logged_times(unengaged)
for loop in ("h_ctl", "θ_ctl", "q_ctl", "V_ctl")
    a = logged_port(hand, "cascade/$loop", :u)[1:length(t)]
    b = logged_port(unengaged, "cascade/$loop", :u)
    k = findfirst(i -> a[i] != b[i], eachindex(b))
    println("$loop first departs at ", t[k])
end

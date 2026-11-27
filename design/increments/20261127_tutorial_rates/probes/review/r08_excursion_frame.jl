# r08: the time of the airspeed excursion on the 50 m step under the shipped frame (1//400) and under
# a frame equal to the base tick (1//200), to place the companion's "at 3.74 s".
include(joinpath(@__DIR__, "r00_common.jl"))
solution = trim_solution()
for dep in (DEP, (Δt_frame = 1//200, Δt_base = 1//200))
    s = climb(RE.autopilot(solution), solution; dep)
    t = logged_times(s); V = logged_port(s, "plant", :V)
    i = argmax(abs.(V .- 50))
    @printf("frame %s: excursion %.5f at %.4f s; neighbours %.6f at %.4f, %.6f at %.4f\n", dep.Δt_frame, abs(V[i] - 50), t[i],
            abs(V[i - 1] - 50), t[i - 1], abs(V[i + 1] - 50), t[i + 1])
end

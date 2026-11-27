# r05: chapter 7's and 8's figures on the shipped deployment: the touchdowns, the tracking error and
# the airspeed band over [160 s, the last second), on the default log and at full resolution, γ at
# the stop.
include(joinpath(@__DIR__, "r00_common.jl"))
solution = trim_solution()
function fly(; log_max = nothing)
    sim = Simulation(RE.approach(solution); DEP...)
    ic = at("vehicle", RE.hand_flown(solution))
    log_max === nothing ? init!(sim, ic) : init!(sim, ic; log_max)
    by_hand!(sim, solution; until = 60.0)
    top = checkpoint(sim)
    n = sink!(sim)
    sim, top, n
end
for (label, lm) in (("default log", nothing), ("full log", Inf))
    sim, top, n = fly(; log_max = lm)
    rec = termination(sim)
    t = logged_times(sim)
    h = logged_port(sim, "vehicle/plant", :h); V = logged_port(sim, "vehicle/plant", :V)
    γ = logged_port(sim, "vehicle/plant", :γ)
    href = series(sim, reads(h_ref = get_input("h_ref"))).h_ref
    w = window(sim, 160, rec.t - 1)
    w100 = window(sim, 100, rec.t - 1)
    @printf("%s: touchdown %.13f after %d writes; tracking %.4f; V in [%.4f, %.4f] over [160, t-1); [%.4f, %.4f] over [100, t-1); γ at stop %.5f (state %.5f); stride after 60 s %.4f\n",
            label, rec.t, n, maximum(abs, (h .- href)[w]), minimum(V[w]), maximum(V[w]), minimum(V[w100]), maximum(V[w100]),
            γ[end], state(sim, "vehicle/plant").γ, t[end] - t[end - 1])
    if lm === nothing
        second = Simulation(RE.approach(solution); DEP...)
        restore!(second, top)
        sink!(second; sink_rate = 2.0)
        @printf("second approach at 2 m/s: %.13f, h at stop %.2e\n", termination(second).t, state(second, "vehicle/plant").h)
    end
end

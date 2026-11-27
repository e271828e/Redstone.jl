# p11: under V1 (frame 1//400, base 1//200), chapter 6's four standby gaps and the two jumps over
# 20 alignments of the pilot's writes, each 2.5 ms later than the last.
include("common.jl")
solution = trim_solution()
dep = (Δt_frame = 1//400, Δt_base = 1//200)
f(t) = round(Int, t * 400)
gaps = map(0:19) do offset
    sim = Simulation(piloted(solution); dep...)
    init!(sim, hand_flown(solution))
    step!(sim; frames = f(5.0) + offset); stage!(sim, "δe_pilot" => solution.δe - 0.02)
    step!(sim; frames = f(7.0) - f(5.0)); stage!(sim, "δe_pilot" => solution.δe)
    step!(sim; frames = f(30.0) - f(7.0)); stage!(sim, "engage" => true)
    step!(sim; frames = f(60.0) - f(30.0) - offset)
    run!(sim; t_end = 90.0)
    figures6(sim)
end
for name in (:gap_δe, :gap_δt, :gap_hθm, :gap_θqm, :jump_δe, :jump_δt)
    v = [g[name] for g in gaps]
    @printf("%-8s offset 0: %.5f  min %.5f max %.5f\n", name, v[1], minimum(v), maximum(v))
end

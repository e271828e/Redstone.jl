# p12: where the longitudinal testset's time goes under A against V1, per piece, warm.
include("common.jl")
using BenchmarkTools
solution = trim_solution()
for (name, dep) in (("A", (Δt_frame = 1//200, Δt_base = 1//200)), ("V1", (Δt_frame = 1//400, Δt_base = 1//200)))
    f(t) = round(Int, t / dep.Δt_frame)
    climb() = (s = Simulation(autopilot(solution); dep...); init!(s, override(cruise(solution), set(u = (h_ref = 1050.0,)))); run!(s; t_end = 120.0); s)
    function hand()
        s = Simulation(piloted(solution); dep...); init!(s, hand_flown(solution))
        step!(s; frames = f(5.0)); stage!(s, "δe_pilot" => solution.δe - 0.02)
        step!(s; frames = f(7.0) - f(5.0)); stage!(s, "δe_pilot" => solution.δe)
        step!(s; frames = f(30.0) - f(7.0)); stage!(s, "engage" => true)
        step!(s; frames = f(60.0) - f(30.0)); run!(s; t_end = 90.0); s
    end
    climb(); hand()
    t_climb = @elapsed (c = climb())
    t_hand = @elapsed (h = hand())
    t_read = @elapsed for _ in 1:10; logged_port(h, "plant", :h); end
    t_bench = @elapsed begin
        bodies = phase_bodies(Simulation(approach(solution); dep...))
        for k in (:sweep_1, :sweep_2, :rhs, :ticks); b = bodies[k]; b(); b(0); @ballocated($b()); @ballocated($b(1)); end
    end
    @printf("%s climb %.2f s, hand %.2f s, 10 reads of the hand log %.2f s, phase-body benchmarks %.2f s\n",
            name, t_climb, t_hand, t_read, t_bench)
end

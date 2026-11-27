# p09c: V1's snapshot index of the pilot's release at 7 s, on `piloted` to 10 s (no thinning).
include("common.jl")
solution = trim_solution()
sim = Simulation(piloted(solution); Δt_frame = 1//400, Δt_base = 1//200)
init!(sim, hand_flown(solution))
step!(sim; frames = 2000); stage!(sim, "δe_pilot" => solution.δe - 0.02)
step!(sim; frames = 800); stage!(sim, "δe_pilot" => solution.δe)
step!(sim; frames = 1200)
δe = series(sim, reads(δe = get_input("δe_pilot"))).δe
println("V1 pull ", findfirst(!=(solution.δe), δe), " release ", findfirst(==(solution.δe), δe[2002:end]) + 2001)

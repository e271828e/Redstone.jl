# p09b: the approach's wall time under A, V1 and V2, each after a warm-up run; V1's release index.
include("common.jl")
solution = trim_solution()
deps = (A = (Δt_frame = 1//200, Δt_base = 1//200), V1 = (Δt_frame = 1//400, Δt_base = 1//200),
        V2 = (Δt_frame = 1//200, Δt_base = 1//200, h_max = 1//400))
function flyit(dep)
    f(t) = round(Int, t / dep.Δt_frame)
    sim = Simulation(approach(solution); dep...)
    init!(sim, at("vehicle", hand_flown(solution)))
    step!(sim; frames = f(5.0)); stage!(sim, "δe_pilot" => solution.δe - 0.02)
    step!(sim; frames = f(7.0) - f(5.0)); stage!(sim, "δe_pilot" => solution.δe)
    step!(sim; frames = f(30.0) - f(7.0)); stage!(sim, "engage" => true)
    step!(sim; frames = f(60.0) - f(30.0))
    descend!(sim)
    sim
end
for (name, dep) in pairs(deps)
    flyit(dep)
    times = [@elapsed(flyit(dep)) for _ in 1:3]
    @printf("%s wall %.3f s (min of 3)\n", name, minimum(times))
end
sim = flyit(deps.V1)
δe = series(sim, reads(δe = get_input("δe_pilot"))).δe
println("V1 pull ", findfirst(!=(solution.δe), δe), " release ", findfirst(==(solution.δe), δe[2002:end]) + 2001)

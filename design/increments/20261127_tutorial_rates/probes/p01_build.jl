# p01: the source as written builds; its schedule (D per discrete component, anchors); the
# candidate A figures (Δt_base = 1//200, multipliers 1, 4, 20) on the source's own functions.
include("common.jl")
solution = trim_solution()
for model in (autopilot(solution), piloted(solution), approach(solution))
    b = build(model; activations = (Float64, ProbeDual))
    println("anchors: ", length(b.structure.anchors))
end
sim = Simulation(piloted(solution); Δt_frame = 1//200, Δt_base = 1//200)
for row in sim.model.deployment.schedule.rows
    println(rpad(row.path, 28), " anchor=", row.anchor, " D=", row.D, " Φ=", row.Φ, " Δt=", row.Δt)
end
println("scopes: ", [(s.path, s.key, s.anchor, s.D) for s in sim.model.deployment.schedule.scopes])

rest = fly_autopilot(solution; Δt_base = 1//200, h_step = 0.0, noise_psd = QUIET, t_end = 60.0)
println("rest drift h=", maximum(abs, logged_port(rest, "plant", :h) .- 1000),
        " V=", maximum(abs, logged_port(rest, "plant", :V) .- 50),
        " θ=", maximum(abs, logged_port(rest, "plant", :θ) .- solution.θ))
climb = fly_autopilot(solution; Δt_base = 1//200)
println("ch5 ", fmt(figures5(climb)))
hand = fly_piloted(solution; Δt_base = 1//200)
println("ch6 ", fmt(figures6(hand)))

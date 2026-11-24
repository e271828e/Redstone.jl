using Redstone, RedstoneExamples, LinearAlgebra
import Redstone: Simulation, trim!, linearize, build, set, input_wires, local_wires, children
const E = RedstoneExamples
println("exports: ", names(E))                                   # line 3
println("fields: ", fieldnames(E.Longitudinal))
sim = Simulation(E.aircraft(); Δt_frame = 1//100)
rep = trim!(sim, E.level_flight(); baseline = set(u = (δe = 0.0, δt = 0.5)))
println("trim: ", rep.status, " ", rep.solution)
lin = linearize(sim, E.longitudinal_taps())
println("labels: ", lin.x_labels, lin.u_labels, " ylabels ", hasproperty(lin,:y_labels) ? lin.y_labels : "-")
println("D: ", lin.D)
println("C: ", lin.C)
sol = rep.solution
for (nm, m) in (("pitch_hold", E.pitch_hold()), ("pitch_hold_d", E.pitch_hold(discrete=true)),
                ("autopilot", E.autopilot(sol)), ("piloted", E.piloted(sol)), ("approach", E.approach(sol)),
                ("closed_loop", E.closed_loop(sol, E.lqr_gains(lin))))
    b = build(m)
    println(nm, " root inputs: ", try keys(Redstone.get_input_types(b)) catch; "n/a" end)
    println(nm, " children: ", try propertynames(m.children) catch; try keys(m.children) catch; "n/a" end end)
end
g = E.lqr_gains(lin); println("gains sizes: ", map(size, g))
println("cruise: ", E.cruise(sol))
println("hand_flown: ", E.hand_flown(sol))
println("trimmed: ", E.trimmed(sol))

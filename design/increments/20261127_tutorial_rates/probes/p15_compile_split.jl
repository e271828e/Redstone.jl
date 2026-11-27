# p15: compile against run for the slowest testset's calls and a V1 autopilot run, twice each.
using Redstone, RedstoneExamples
import Redstone: Simulation, init!, run!, build, ProbeDual, set, override, trim!
import RedstoneExamples: aircraft, level_flight, autopilot, cruise, approach
sim0 = Simulation(aircraft(); Δt_frame = 1//100)
solution = trim!(sim0, level_flight(); baseline = set(u = (δe = 0.0, δt = 0.5))).solution
for pass in 1:2
    println("-- pass $pass")
    @time "build approach (Float64, ProbeDual)" build(approach(solution); activations = (Float64, ProbeDual))
    @time "Simulation autopilot V1" (sim = Simulation(autopilot(solution); Δt_frame = 1//400, Δt_base = 1//200))
    @time "init!" init!(sim, override(cruise(solution), set(u = (h_ref = 1050.0,))))
    @time "run! 120 s" run!(sim; t_end = 120.0)
end

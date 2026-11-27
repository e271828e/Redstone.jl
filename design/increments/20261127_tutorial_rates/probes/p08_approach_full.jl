# p08: chapter 7's approach on the source at full log resolution (log_max = Inf), for the
# companion's tracking error and airspeed band; and the warnings of the three models' deployments.
include("common.jl")
import Redstone: warnings
solution = trim_solution()
flight = Simulation(approach(solution); Δt_frame = 1//200, Δt_base = 1//200)
init!(flight, at("vehicle", hand_flown(solution)); log_max = Inf)
fly_by_hand!(flight, solution)
n = descend!(flight)
println("full resolution, writes $n: ", fmt(figures7(flight)), "  snapshots ", length(logged_times(flight)))
for (name, model) in (("autopilot", autopilot(solution)), ("piloted", piloted(solution)), ("approach", approach(solution)))
    sim = Simulation(model; Δt_frame = 1//200, Δt_base = 1//200)
    println(name, " warnings: ", warnings(sim))
end

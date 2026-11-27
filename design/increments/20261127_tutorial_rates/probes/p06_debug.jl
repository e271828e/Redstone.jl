include("common.jl")
include("knobs.jl")
solution = trim_solution()
for m in ((imu = 1, ins = 4, air_data = 20), (imu = 1, ins = 4, air_data = 4))
    set_multipliers!(m)
    Base.invokelatest() do
        sim = Simulation(autopilot(solution); Δt_frame = 1//200, Δt_base = 1//200)
        println(RE.sensor_multipliers, " ", [(r.path, r.D) for r in sim.model.deployment.schedule.rows if occursin("ctl", r.path) || occursin("air", r.path)])
    end
end

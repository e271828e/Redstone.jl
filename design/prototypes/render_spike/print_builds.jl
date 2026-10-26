# Prints the Build renderings the fixtures are transcribed from, read-only.
# Run from the repository root: julia --project=examples design/prototypes/render_spike/print_builds.jl
using RedstoneExamples
import Redstone: Simulation, build, trim!, linearize, set
import RedstoneExamples: aircraft, level_flight, longitudinal_taps, lqr_gains, closed_loop, descent
sim = Simulation(aircraft(); h = 1//100)
report = trim!(sim, level_flight(); baseline = set(u = (δe = 0.0, δt = 0.5)))
gains = lqr_gains(linearize(sim, longitudinal_taps()))
dir = @__DIR__
for (name, model) in (("closed_loop", closed_loop(report.solution, gains)), ("descent", descent()),
                      ("aircraft", aircraft()))
    open(joinpath(dir, "build_$name.txt"), "w") do io
        show(io, MIME"text/plain"(), build(model))
        println(io)
    end
end

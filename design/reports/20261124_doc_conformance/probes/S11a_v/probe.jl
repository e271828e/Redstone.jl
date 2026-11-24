# S11a verifier probes. Run from W with --project=test.
module ProbeS11a
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
include(joinpath(W, "utils.jl"))
outfaced() = Group((; p = Plant()); input_wires = ("u" => "p/u",), output_wires = ("p/y" => "y",))
fail(f) = try f(); nothing catch e; e end

println("P1 Snapshot fields: ", fieldnames(Redstone.Snapshot))

# P2 frame with h_max: publications per frame
sim = Simulation(fed(Plant(), "u"); Δt_frame = 3//10, h_max = 1//10)
init!(sim, set(u = (in = 0.0,)))
b0 = latest(sim).boundary
step!(sim; frames = 1)
println("P2 boundaries published in one frame (h_max = Δt/3): ", latest(sim).boundary - b0,
        " frame=", latest(sim).frame)

# P3 mode field from y_state in snapshot
sim = Simulation(fed(Motor(1.0), "M_load"); Δt_frame = 1//10)
init!(sim, set(u = (in = 0.0,)))
step!(sim; frames = 3)
println("P3 Motor running in snapshot: ", [port(s, "c", :running) for s in logged(sim)])

# P4 build lock taken on activation lookup after pre-materialization
b = build(fed(Plant(), "u"); activations = (Float64,))
dep = Deployment(b; Δt_frame = 1//10)
Model(dep)  # warm compile
holder = Threads.@spawn (lock(b.lock); sleep(2.0); unlock(b.lock))
sleep(0.3)
t = @elapsed Model(dep)
wait(holder)
println("P4 Model(dep) while another task holds build.lock: ", round(t; digits = 2), " s")
m = Model(dep)
holder = Threads.@spawn (lock(b.lock); sleep(2.0); unlock(b.lock))
sleep(0.3)
t = @elapsed init!(m, set(u = (in = 0.0,)))
wait(holder)
println("P4 init!(model) while another task holds build.lock: ", round(t; digits = 2), " s")

# P5 attach refusal kinds, collected
sim = Simulation(outfaced(); Δt_frame = 1//10)
e = fail(() -> attach!(sim, Pad("t"), Readout(a = get_output("q", "y"), b = get_output("p", "nope"),
                                                c = get_state("p", :x))))
println("P5 attach kinds: ", [typeof(d) for d in diagnostics(e)])

# P6 series property and reserved label
sim = Simulation(outfaced(); Δt_frame = 1//10)
init!(sim, set(u = (u = 0.0,)))
step!(sim; frames = 2)
fl = series(sim, reads(V = get_output("p", "y")))
println("P6 flight.V === flight.columns.V: ", fl.V === fl.columns.V, " fields ", propertynames(fl))
e = fail(() -> series(sim, reads(t = get_output("p", "y"))))
println("P6 reserved label: ", typeof(e))

# P7 log bound continuously, log_max = 3
sim = Simulation(fed(Plant(), "u"); Δt_frame = 1//10)
init!(sim, set(u = (in = 0.0,)); log_max = 3)
mx = 0
for k in 1:200
    step!(sim; frames = 1)
    global mx = max(mx, sim.run.log.live, count(!isnothing, sim.run.log.snaps))
end
println("P7 max retained middle over 200 frames, log_max=3: ", mx)

# P8 trace under decimation
sim = Simulation(fed(Plant(), "u"); Δt_frame = 1//10)
init!(sim, set(u = (in = 0.0,)); log_every = 5)
for k in 1:6
    stage!(sim, :in => Float64(k))
    step!(sim; frames = 1)
end
tr = trace(sim)
println("P8 trace batches under log_every=5: ", [bt.frame for bt in tr.batches], " frames ", tr.frames)
end

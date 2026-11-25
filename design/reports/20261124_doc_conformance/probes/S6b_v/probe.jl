# S6b verifier probe: run from the pinned worktree with --project=test.
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl")); include(joinpath(W, "fixtures.jl")); include(joinpath(W, "utils.jl"))

println("P1 optimization level: ", Base.JLOptions().opt_level)

# P2 (S6b-229/231): nested Relative(2,1) under Relative(2,1).
nested = Group((; g = Group((; a = TickCounter()); sample_times = (; a = Relative(2, 1))));
               sample_times = (; g = Relative(2, 1)))
sim = Simulation(nested; Δt_frame = 1//10)
for r in sim.model.deployment.schedule.rows
    println("P2 row ", r.path, " D=", r.D, " Φ=", r.Φ)
end
init!(sim)
let ticks = Float64[], last_n = port(latest(sim), "g/a", :n)
    println("P2 n at t0 = ", last_n)
    for k in 1:12
        step!(sim; t_plus = 0.1)
        n = port(latest(sim), "g/a", :n)
        n != last_n && push!(ticks, latest(sim).t); last_n = n
    end
    println("P2 frame tops where n changed: ", ticks)
end

# P3 (S6b-136): logging and an attached reader leave the trajectory bit-identical.
function session(; reader = false, kw...)
    s = Simulation(single(Bouncer(1.0, 0.315)); Δt_frame = 1//10)
    init!(s; kw...)
    done = Threads.Atomic{Bool}(false); reads = Ref(0)
    task = reader ? Threads.@spawn(begin
        while !done[]
            snap = latest(s); snap === nothing || (port(snap, "c", :q); reads[] += 1)
            yield()
        end
    end) : nothing
    if reader   # a reader between frames: every snapshot read as it is published
        for k in 1:20
            step!(s; t_plus = 0.1); snap = latest(s); port(snap, "c", :q); reads[] += 1
        end
    else
        run!(s; t_end = 2.0)
    end
    done[] = true; task === nothing || wait(task)
    (state(s, "c").q, modes(s, "c").count, reads[])
end
ref = session(); nolog = session(log = false); thin = session(log_every = 7, log_max = 3)
rd = session(reader = true)
println("P3 q bits ", bitstring(ref[1]), " count ", ref[2])
println("P3 log=false identical: ", ref[1] === nolog[1] && ref[2] === nolog[2])
println("P3 thinned identical: ", ref[1] === thin[1] && ref[2] === thin[2])
println("P3 reader identical: ", ref[1] === rd[1] && ref[2] === rd[2], " (reads=", rd[3], ")")

# P4 (S6b-091): a snapshot holds every port and every root input, with its time.
s4 = Simulation(fed(Plant(), "u"); Δt_frame = 1//10)
init!(s4, set(u = (in = 2.5,)))
step!(s4; t_plus = 0.3)
snap = latest(s4)
println("P4 t=", snap.t, " root in=", port(snap, "", :in), " c.y===live ", port(snap, "c", :y) === port(s4, "c", :y),
        " c.power===live ", port(snap, "c", :power) === port(s4, "c", :power))

# P5 (S6b-211): a discrete output is held between ticks across interior step ends.
z = Group((; a = TickCounter()); sample_times = (; a = Relative(4)))
s5 = Simulation(Group((; z = z, r = BareRamp())); Δt_frame = 1//10, Δt_base = 1//40, h_max = 1//80)
init!(s5)
seen = Tuple{Float64,Int}[]
for k in 1:2
    step!(s5; t_plus = 0.1)
end
for snap in s5.run.log.snaps
    snap === nothing || push!(seen, (snap.t, port(snap, "z/a", :n)))
end
println("P5 (t, n) at every logged boundary: ", seen)

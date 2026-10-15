module H2T
include(joinpath(@__DIR__, "..", "..", "..", "..", "..", "..", "test", "repl.jl"))
sim = Simulation(Bouncer(1.0, 0.35); h = 1//10)
init!(sim)
step!(sim; frames = 20)
trc = trace(sim)
println("recording: frame ", sim.run.frame, " ordinal ", latest(sim).boundary)
s2 = Simulation(Bouncer(1.0, 0.35); h = 1//10)
replay!(s2, trc; to_boundary = 10)
println("to_boundary = 10: run.frame = ", s2.run.frame, " latest.t = ", latest(s2).t,
        " latest.boundary (ordinal) = ", latest(s2).boundary, " latest.frame = ", latest(s2).frame)
end

module S12aProbe
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
include(joinpath(W, "utils.jl"))
two_root_inputs() = Group((; s = Sum(sa = 1.0, sb = 1.0)); input_wires = ("a" => "s/a", "b" => "s/b"))
mk() = Simulation(two_root_inputs(); Δt_frame = 1//10)
function ad(f)
    try f(); :noerr catch e; e isa Redstone.DiagnosticError ? (typeof(e.carried), e.carried.reason) : typeof(e) end
end
sim = mk(); init!(sim, set(u = (a = 0.0, b = 0.0)))
# probe:20 defaults and readers
println("defaults ", pace(sim), " ", margin(sim), " ", paused(sim))
# probe:22 refusals
println("pace! 0 ", ad(() -> pace!(sim, 0)), " neg ", ad(() -> pace!(sim, -1)), " Inf ", ad(() -> pace!(sim, Inf)))
println("margin! -1 ", ad(() -> margin!(sim, -1)), " Inf ", ad(() -> margin!(sim, Inf)), " 0 ", ad(() -> margin!(sim, 0)))
println("run kw ", ad(() -> run!(sim; pace = 0)), " ", ad(() -> run!(sim; margin = -1)), " ", ad(() -> run!(sim; pace = "x")))
pace!(sim, Inf); margin!(sim, 0.002)
# probe:28 step! takes neither
println("step pace kw ", try step!(sim; pace = 1); :ok catch e; typeof(e) end)
# probe:30 pause before run, run! starts paused, stop while paused, flag cleared
attach!(sim, TailProbe(), NoClaim())
sim = mk(); attach!(sim, TailProbe(), NoClaim()); init!(sim, set(u = (a = 0.0, b = 0.0)))
pause!(sim)
obs = Threads.@spawn begin
    sleep(1.0); r = (paused(sim), lifecycle(sim), sim.run.frame); stop!(sim); r
end
run!(sim; t_end = 1.0)
println("paused-start ", fetch(obs), " term ", termination(sim).source, " paused after ", paused(sim), " lifecycle ", lifecycle(sim))
# probe:41 stop word cleared at next run? stop before run! dropped
sim = mk(); init!(sim, set(u = (a = 0.0, b = 0.0)))
stop!(sim); run!(sim; t_end = 0.3)
println("stop-before-run ", termination(sim).source)
# probe:45 counter and ordinal
sim = mk(); handle = attach!(sim, TailProbe(), NoClaim())
c0 = sim.control.counter
init!(sim, set(u = (a = 0.0, b = 0.0)))
println("counter after init ", sim.control.counter - c0, " ordinal ", latest(sim).boundary)
run!(sim; t_end = 0.5)
println("counter after run ", sim.control.counter - c0, " ordinal ", latest(sim).boundary)
init!(sim, set(u = (a = 0.0, b = 0.0)))
println("counter after reinit ", sim.control.counter - c0, " ordinal ", latest(sim).boundary)
# probe:53 task_state outside run
println("task_state ", [w.task_state for w in latest(sim).status.writers])
# probe:55 thread budget
sim = mk(); attach!(sim, TailProbe(), NoClaim()); attach!(sim, TailProbe(), NoClaim())
init!(sim, set(u = (a = 0.0, b = 0.0)))
println("nthreads ", Threads.nthreads())
run!(sim; t_end = 0.3)
println("residue ", [typeof(r) for r in termination(sim).residue])
println("budget msg ", message(ThreadBudget(1, 2)))
# probe:62 pacer: step! status Inf
sim = mk(); init!(sim, set(u = (a = 0.0, b = 0.0))); step!(sim; frames = 2)
println("step pacer ", latest(sim).status.pacer)
# probe:65 paced run, pace change mid-run
sim = mk(); init!(sim, set(u = (a = 0.0, b = 0.0)))
t0 = time(); run!(sim; pace = 1.0, t_end = 0.5); println("paced 0.5s took ", time() - t0, " ", latest(sim).status.pacer)
end

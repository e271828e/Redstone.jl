# A real SIGINT at the pause block and at the mask's end, on the thread layout given.
module P5
using Test, BenchmarkTools
include(joinpath(pwd(), "test", "repl.jl"))
include(joinpath(pwd(), "test", "utils.jl"))
include(joinpath(pwd(), "test", "test_dataplane.jl")); include(joinpath(pwd(), "test", "test_devices.jl"))
include(joinpath(pwd(), "test", "test_failures.jl"))   # sigint_raising

println("nthreads=", Threads.nthreads(), " interactive=", Threads.nthreads(:interactive))
rest(sim) = (st = sim.model.status, frame = sim.run.frame, clock = sim.model.exec.clock.t,
             clock_frame = round(Int, sim.model.exec.clock.t / 0.1), latest = latest(sim).frame,
             cp = (c = failure(() -> checkpoint(sim)); c === nothing ? checkpoint(sim).frame : typeof(c)))
sigint_raising() do
    # pause block, real signal
    sim = Simulation(two_root_inputs(); h = 1//10)
    attach!(sim, Pad("p"), Enumerated("a"))
    init!(sim, set(u = (a = 0.0, b = 0.0)))
    pause!(sim)
    loop_task = current_task()
    observer = Threads.@spawn begin
        ok = timedwait(() -> parked_in(loop_task, sim.control.wake), 10.0) === :ok
        ok && ccall(:kill, Cint, (Cint, Cint), getpid(), Cint(2))
        ok ? :sent : (stop!(sim); :never_parked)   # returns at once: a waiting observer would take the signal
    end
    err = failure(() -> Test.collect_test_logs() do; run!(sim; t_end = 1.0e6); end)
    println("pause block: observer=", fetch(observer), " err=", err === nothing ? nothing : typeof(err),
            " lifecycle=", lifecycle(sim), " src=", termination(sim) === nothing ? nothing : termination(sim).source,
            " ", rest(sim), " pending=", sigint_pending())

end
end

# S12a verifier probe. Run from W with --project=test, JULIA_NUM_THREADS=1.
using Test, StaticArrays, LinearAlgebra, ForwardDiff
using Redstone
include(joinpath(pwd(), "test", "imports.jl"))
include(joinpath(pwd(), "test", "fixtures.jl"))
two_root_inputs() = Group((; s = Sum(sa = 1.0, sb = 1.0)); input_wires = ("a" => "s/a", "b" => "s/b"))
parked_in(task, w) = (lock(w); try task.queue === w.waitq finally unlock(w) end)
u0 = set(u = (a = 0.0, b = 0.0))
println("P0 nthreads = ", Threads.nthreads()); flush(stdout)

# P1 (S12a-047): margin's domain
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
for m in (0, 0.5, 1//2, Inf, -1, -0.001, NaN, "x", nothing)
    r = try margin!(sim, m); margin(sim) catch e; e isa DiagnosticError ? "refused" : e end
    println("P1 margin!($(repr(m))) -> ", r)
end
for m in (-1, NaN)
    r = try init!(sim, u0); run!(sim; t_end = 0.1, margin = m); "accepted" catch e; e isa DiagnosticError ? "refused" : e end
    println("P1 run!(margin=$(repr(m))) -> ", r)
end

# P2 (S12a-038): margin leaves the trajectory unchanged
function traj(m)
    s = Simulation(two_root_inputs(); Δt_frame = 1//100)
    init!(s, u0); run!(s; t_end = 0.1, pace = 1.0, margin = m)
    [(x.t, x.boundary) for x in logged(s)], s.run.frame
end
a, b = traj(0.0), traj(Inf)
println("P2 margin 0 vs Inf same snapshots/frames: ", a == b, " frames=", a[2]); flush(stdout)

# P3 (S12a-029): a paused run reads :running and the roster is frozen
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
println("P3a"); flush(stdout); attach!(sim, TailProbe(), NoClaim())
println("P3b"); flush(stdout); init!(sim, u0); pause!(sim)
println("P3c"); flush(stdout); lt = current_task()
obs = @async begin
    println("obs start"); ok = timedwait(() -> parked_in(lt, sim.control.wake), 10.0) === :ok
    println("obs parked=", ok); st = (paused(sim), lifecycle(sim))
    att = try attach!(sim, Pad("q"), Enumerated("a")); "attached" catch e; e isa DiagnosticError ? string(typeof(e.carried)) : string(e) end
    println("obs att=", att); stop!(sim); println("obs stopped")
    (ok, st, att)
end
println("P3 run! enter"); run!(sim; t_end = 1.0); println("P3 run! exit")
println("P3 parked, (paused, lifecycle), attach while paused: ", fetch(obs), " after: ", lifecycle(sim), " paused=", paused(sim)); flush(stdout)

# P4 (S12a-105, S12a-096): counter never reset across trajectories; ordinal restarts
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
init!(sim, u0); c1 = sim.control.counter; b1 = latest(sim).boundary
step!(sim; frames = 3); c2 = sim.control.counter; b2 = latest(sim).boundary
init!(sim, u0); c3 = sim.control.counter; b3 = latest(sim).boundary
step!(sim; frames = 2); c4 = sim.control.counter; b4 = latest(sim).boundary
println("P4 counter: ", (c1, c2, c3, c4), " ordinal: ", (b1, b2, b3, b4)); flush(stdout)

# P5 (S12a-057, S12a-020): what co-resident tasks get during a paced run, one thread
function ticks(m; device)
    s = Simulation(two_root_inputs(); Δt_frame = 1//10)
    device && attach!(s, TailProbe(), NoClaim())
    init!(s, u0)
    n = Threads.Atomic{Int}(0); done = Threads.Atomic{Bool}(false)
    t = @async (while !done[]; Threads.atomic_add!(n, 1); sleep(0.005); end)
    yield()
    t0 = time(); run!(s; t_end = 0.5, pace = 1.0, margin = m); el = time() - t0
    done[] = true; wait(t)
    (n[], round(el, digits = 2))
end
println("P5 ticks margin=0 no device: ", ticks(0.0; device = false)); flush(stdout)
println("P5 ticks margin=Inf no device: ", ticks(Inf; device = false)); flush(stdout)
println("P5 ticks margin=Inf device: ", ticks(Inf; device = true)); flush(stdout)

# P6 (S12a-010): stop latency in a paced run, budget 0.5 s
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
attach!(sim, TailProbe(), NoClaim())
init!(sim, u0)
ts = Ref(0.0)
obs = @async (sleep(0.8); ts[] = time(); stop!(sim))
run!(sim; t_end = 100.0, pace = 0.2, margin = 0.0); tr = time()
println("P6 stop->return delay (budget 0.5 s): ", round(tr - ts[], digits = 3), " source=", termination(sim).source); flush(stdout)

# P7 (S12a-067, S12a-019): ThreadBudget at one thread with one device; issuer payload
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
h = attach!(sim, TailProbe(), NoClaim())
init!(sim, u0)
logs, _ = Test.collect_test_logs() do
    @async (sleep(0.2); stop!(h)); run!(sim; t_end = 1.0e6, pace = 1.0)
end
println("P7 ThreadBudget in residue: ", any(d isa ThreadBudget for r in termination(sim).residue for d in r.recent),
        " warnings=", count(l -> l.level >= Base.CoreLogging.Warn, logs), " source=", termination(sim).source)

# P8 (S12a-077, S12a-086): liveness fields; a stale device keeps running
mutable struct Sleeper <: AbstractDevice end
loop(::Sleeper, handle) = (sleep(3.0); nothing)
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
attach!(sim, Sleeper(), NoClaim())
init!(sim, u0)
res = Ref{Any}(nothing)
@async begin
    sleep(2.6)
    st = latest(sim).status.writers[1]
    res[] = (st.who, st.task_state, stale(st), length(sim.plane.roster))
    sleep(0.1); stop!(sim)
end
run!(sim; t_end = 1.0e6, pace = 1.0)
println("P8 at 2.6 s: (who, task_state, stale, roster size): ", res[], " source=", termination(sim).source); flush(stdout)

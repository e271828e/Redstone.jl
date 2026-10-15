# Half 1's claims run against the package (survey, chapter 12, half 1).
module H1Check
const ROOT = joinpath(@__DIR__, "..", "..", "..", "..", "..", "..")
include(joinpath(ROOT, "test", "repl.jl"))
using Test
two_root_inputs() = Group((; s = Sum(sa = 1.0, sb = 1.0));
                    input_wires = ("a" => "s/a", "b" => "s/b"))
ws(snap, who) = only(w for w in snap.status.writers if w.who == who)
cond() = fragment(u = (a = 0.0, b = 0.0))
show_try(label, f) = try
    r = f(); println(label, " => ", r)
catch e
    println(label, " => THREW ", typeof(e), ": ", sprint(showerror, e)[1:min(end, 200)])
end

mutable struct BadInit <: AbstractDevice
    log::Vector{Symbol}
end
BadInit() = BadInit(Symbol[])
Redstone.init!(dev::BadInit) = (push!(dev.log, :init); error("no hardware"))
Redstone.shutdown!(dev::BadInit) = (push!(dev.log, :shutdown); nothing)
Redstone.loop(dev::BadInit, handle) = (push!(dev.log, :loop); nothing)

mutable struct Order <: AbstractDevice
    name::Symbol
    log::Vector{Tuple{Symbol,Symbol,Bool}}   # (device, call, on the calling task?)
    caller::Task
end
Redstone.init!(dev::Order) = (push!(dev.log, (dev.name, :init, current_task() === dev.caller)); nothing)
Redstone.shutdown!(dev::Order) = (push!(dev.log, (dev.name, :shutdown, current_task() === dev.caller)); nothing)
function Redstone.loop(dev::Order, handle)
    while running(handle); wait_next_snapshot(handle); end
end

println("threads = ", Threads.nthreads())

println("\n== §12.1 control verbs")
let sim = Simulation(two_root_inputs(); h = 1//10)
    println("paused at construction: ", paused(sim))
    println("pace, margin at construction: ", pace(sim), ", ", margin(sim))
    for (lbl, f) in (("pace!(0)", () -> pace!(sim, 0)), ("pace!(-1)", () -> pace!(sim, -1.0)),
                     ("pace!(NaN)", () -> pace!(sim, NaN)), ("pace!(Inf)", () -> pace!(sim, Inf)),
                     ("margin!(-1)", () -> margin!(sim, -1.0)), ("margin!(0)", () -> margin!(sim, 0.0)),
                     ("margin!(Inf)", () -> margin!(sim, Inf)), ("margin!(NaN)", () -> margin!(sim, NaN)))
        show_try(lbl, f)
    end
    init!(sim, cond())
    show_try("run!(pace = 0)", () -> run!(sim; t_end = 0.2, pace = 0))
    pause!(sim)
    println("paused before run!: ", paused(sim), "; lifecycle ", lifecycle(sim))
    t = @async run!(sim; t_end = 0.3)
    sleep(0.5)
    println("frames while paused at start: ", sim.run.frame, " lifecycle ", lifecycle(sim))
    stop!(sim)
    wait(t)
    println("after stop while paused: lifecycle ", lifecycle(sim), ", paused ", paused(sim),
            ", frames ", sim.run.frame, ", source ", termination(sim).source)
end

println("\n== §12.1 join_timeout validation (§12.4(5))")
show_try("join_timeout default", () -> Simulation(two_root_inputs(); h = 1//10).control.join_timeout)
show_try("join_timeout = 0", () -> Simulation(two_root_inputs(); h = 1//10, join_timeout = 0))
show_try("join_timeout = Inf", () -> Simulation(two_root_inputs(); h = 1//10, join_timeout = Inf).control.join_timeout)
show_try("join_timeout = -1", () -> Simulation(two_root_inputs(); h = 1//10, join_timeout = -1.0))
show_try("Control fields", () -> fieldnames(typeof(Simulation(two_root_inputs(); h = 1//10).control)))

println("\n== §12.3 two indices")
let sim = Simulation(two_root_inputs(); h = 1//10)
    init!(sim, cond()); run!(sim; t_end = 0.3)
    c1 = sim.control.counter; b1 = latest(sim).boundary
    init!(sim, cond())
    println("after run 1: counter ", c1, ", final ordinal ", b1,
            "; after re-init!: counter ", sim.control.counter, ", ordinal ", latest(sim).boundary)
end

println("\n== §12.2 task_state and stale")
let sim = Simulation(two_root_inputs(); h = 1//10)
    attach!(sim, BadInit(), Enumerated("a"))
    init!(sim, cond())
    s0 = ws(latest(sim), "device 1 (BadInit)")
    println("after init!, before any run: task_state ", s0.task_state, ", heartbeat ", s0.heartbeat)
    step!(sim; frames = 2)
    s1 = ws(latest(sim), "device 1 (BadInit)")
    println("after step!: task_state ", s1.task_state, " (lifecycle ", lifecycle(sim), "), orphaned ",
            orphaned(s1), ", stale ", stale(s1))
    run!(sim; t_end = 0.5)
    s2 = ws(logged(sim)[end], "device 1 (BadInit)")
    println("failed init! device inside run!: task_state ", s2.task_state, ", stale ", stale(s2),
            ", heartbeat ", s2.heartbeat)
end
let sim = Simulation(two_root_inputs(); h = 1//10)
    attach!(sim, Pad("p"), Enumerated("a"))
    init!(sim, cond())
    step!(sim; frames = 1)
    s = ws(latest(sim), "device 1 (Pad)")
    println("healthy Pad, after step! (never run): task_state ", s.task_state, ", orphaned ", orphaned(s))
end

println("\n== §12.2 thread budget")
let sim = Simulation(two_root_inputs(); h = 1//10)
    attach!(sim, Pad("p"), Enumerated("a"))
    init!(sim, cond())
    rec = Redstone.ThreadBudget
    run!(sim; t_end = 0.2)
    n = count(d isa rec for r in termination(sim).residue for d in r.recent) +
        sum(w.totals.thread_budget for w in latest(sim).status.writers if hasproperty(w.totals, :thread_budget); init = 0)
    println("1 device, nthreads ", Threads.nthreads(), ": ThreadBudget seen (residue or totals) = ", n)
end

println("\n== §12.4 t_end lands on the grid")
let sim = Simulation(two_root_inputs(); h = 1//10)
    init!(sim, cond()); run!(sim; t_end = 0.25)
    println("t_end 0.25, h 0.1: final t ", latest(sim).t, ", frames ", sim.run.frame,
            ", record ", termination(sim).source, " t=", termination(sim).t)
end

println("\n== §12.4 init bracket: order, task, should_abort")
let sim = Simulation(two_root_inputs(); h = 1//10)
    log = Tuple{Symbol,Symbol,Bool}[]
    attach!(sim, Order(:first, log, current_task()), Enumerated("a"))
    attach!(sim, BadInit(), Enumerated(); should_abort = true)
    attach!(sim, Order(:third, log, current_task()), Enumerated("b"))
    init!(sim, cond())
    logs, _ = Test.collect_test_logs() do
        run!(sim; t_end = 0.5)
    end
    println("calls: ", log)
    println("should_abort failure: frames ", sim.run.frame, ", lifecycle ", lifecycle(sim),
            ", source ", termination(sim).source, ", final t ", latest(sim).t,
            ", log endpoints ", [s.boundary for s in logged(sim)])
end

println("\n== §12.4 terminal snapshot retained under log_every and log_max")
let sim = Simulation(two_root_inputs(); h = 1//10)
    init!(sim, cond(); log_every = 7, log_max = 2)
    run!(sim; t_end = 2.25)
    println("frames ", [s.frame for s in logged(sim)], " final frame ", sim.run.frame)
end

println("\n== §12.3 wait on stop: Collector-style")
mutable struct Waiter <: AbstractDevice
    n::Int
    returned::Bool
end
function Redstone.loop(dev::Waiter, handle)
    while running(handle)
        wait_next_snapshot(handle); dev.n += 1
    end
    dev.returned = true
end
let sim = Simulation(two_root_inputs(); h = 1//10)
    w = Waiter(0, false)
    attach!(sim, w, NoClaim())
    init!(sim, cond()); run!(sim; t_end = 1.0)
    println("waiter wakes ", w.n, " over ", sim.run.frame, " frames; returned ", w.returned)
end

println("\n== §12.4 init failure in a run that does not start at t0")
mutable struct FailSecond <: AbstractDevice
    n::Int
end
Redstone.init!(dev::FailSecond) = (dev.n += 1; dev.n >= 2 && error("unplugged"); nothing)
function Redstone.loop(dev::FailSecond, handle)
    stage!(handle, "a" => 5.0)
    while running(handle); wait_next_snapshot(handle); end
end
let sim = Simulation(two_root_inputs(); h = 1//10)
    dev = FailSecond(0)
    attach!(sim, dev, Enumerated("a"))
    init!(sim, cond())
    run!(sim; t_end = 0.3)
    show_try("run! on stopped", () -> run!(sim; t_end = 0.6))
    init!(sim, cond())
    logs, _ = Test.collect_test_logs() do
        run!(sim; t_end = 0.3)
    end
    s1 = ws(logged(sim)[2], "device 1 (FailSecond)")
    println("re-init!, run 2 (init! fails, flag clear): first frame's record task_state ", s1.task_state,
            ", stale at that frame ", stale(s1; now = s1.heartbeat === nothing ? time() : time()),
            ", heartbeat age at check ", round(time() - s1.heartbeat; digits = 3), " s")
end
let sim = Simulation(two_root_inputs(); h = 1//10)
    init!(sim, cond())
    step!(sim; frames = 3)
    attach!(sim, BadInit(), Enumerated("a"); should_abort = true)
    logs, _ = Test.collect_test_logs() do
        run!(sim; t_end = 0.6)
    end
    println("after step!(3), should_abort init failure: frames ", sim.run.frame, ", final t ", latest(sim).t,
            ", lifecycle ", lifecycle(sim), ", source ", termination(sim).source)
end
end

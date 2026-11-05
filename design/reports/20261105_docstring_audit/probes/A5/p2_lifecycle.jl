module P2
using Test
const W = "scratch/wt_base"
include(W * "/test/repl.jl")
include(W * "/test/utils.jl")
using Base.Threads: @spawn

two() = Group((; s = Sum(sa = 1.0, sb = 1.0)); input_wires = ("a" => "s/a", "b" => "s/b"))
const U = (a = 0.0, b = 0.0)
function bounded(f; limit = 60.0)
    t = @spawn f()
    r = timedwait(() -> istaskdone(t), limit; pollint = 0.01)
    r === :ok || println("  BOUNDED WAIT HIT")
    t
end
struct Dup <: AbstractBinding end
is_input(::Dup) = true
is_output(::Dup) = true
claims(::Dup) = ("a",)
reads(::Dup) = (; echo = get_input("a"))

mutable struct D <: AbstractDevice; f::Function; end
loop(d::D, h) = d.f(h)

println("=== A heartbeat, per handle call")
sim = Simulation(two(); h = 1//10)
dev = D(h -> nothing)
h = attach!(sim, dev, Dup())
init!(sim, set(u = U))
views = port_views(h)
snap = latest(sim)
live_v, dead_v = views[("", :a)], views[("", :b)]
calls = [("running", () -> running(h)), ("latest", () -> latest(h)), ("pending", () -> pending(h, 1)),
         ("stage!", () -> stage!(h, "a" => 1.0)), ("wait_next_snapshot", () -> wait_next_snapshot(h)),
         ("gather", () -> gather(h, snap)), ("report!", () -> report!(h, MalformedDatum("x"))),
         ("binding", () -> binding(h)), ("stop!", () -> stop!(h)), ("port_views", () -> port_views(h)),
         ("peek live", () -> peek(live_v, h, snap)), ("peek nonlive", () -> peek(dead_v, h, snap)),
         ("incumbent_status", () -> incumbent_status(dead_v, snap))]
for (name, f) in calls
    @atomic h.diag_cell.heartbeat = 0.0
    f()
    println(rpad(name, 22), " beat=", (@atomic h.diag_cell.heartbeat) != 0.0)
end

println("=== B stop!: while paused, boundary unchanged; source")
sim = Simulation(two(); h = 1//10)
started = Channel{Nothing}(1); go = Channel{Nothing}(1)
dev = D(h -> (put!(started, nothing); take!(go); stop!(h); nothing))
h = attach!(sim, dev, NoClaim())
init!(sim, set(u = U))
pause!(sim)
t = bounded(() -> run!(sim); limit = 0.0)
timedwait(() -> isready(started), 30.0)
timedwait(() -> sim.model.exec.clock.t == 0, 5.0)
sleep(0.2)
b0 = latest(sim).boundary; c0 = sim.control.counter
put!(go, nothing)
timedwait(() -> istaskdone(t), 30.0)
println("boundary before ", b0, " after ", latest(sim).boundary, " counter ", c0, " -> ", sim.control.counter)
println("source ", termination(sim).source, " lifecycle ", lifecycle(sim))
stop!(sim); println("later stop!(sim) source ", termination(sim).source)
stop!(h); println("stop! on stopped lifecycle ", lifecycle(sim), " source ", termination(sim).source)
init!(sim, set(u = U)); println("after stop on stopped + init!: step! frames=", step!(sim))

println("=== B2 stop!(handle) then step!: no frame, no publication")
sim = Simulation(two(); h = 1//10)
h = attach!(sim, D(h -> nothing), NoClaim())
init!(sim, set(u = U)); step!(sim)
b0 = latest(sim).boundary
stop!(h); n = step!(sim)
println("frames ", n, " boundary ", b0, " -> ", latest(sim).boundary, " source ", termination(sim).source)

println("=== B3 free run: stop! at first wait, the frame in flight")
sim = Simulation(two(); h = 1//10)
seen = Ref{Any}(nothing)
dev = D(function (h)
    s = wait_next_snapshot(h); seen[] = s.boundary; stop!(h); nothing end)
attach!(sim, dev, NoClaim())
init!(sim, set(u = U))
t = bounded(() -> run!(sim; t_end = 1000.0))
println("seen ", seen[], " final ", latest(sim).boundary)

println("=== C running in init!, loop, step!, after, final snapshot")
mutable struct R <: AbstractDevice; h; in_init; in_loop; final_boundary; end
R() = R(nothing, nothing, nothing, nothing)
init!(d::R) = (d.in_init = d.h === nothing ? :nohandle : running(d.h); nothing)
function loop(d::R, h)
    d.in_loop = running(h)
    wait_next_snapshot(h); stop!(h)
    while running(h); wait_next_snapshot(h); end
    d.final_boundary = latest(h).boundary
    nothing
end
sim = Simulation(two(); h = 1//10)
d = R(); d.h = h = attach!(sim, d, NoClaim())
println("before init! ", running(h))
init!(sim, set(u = U)); println("after init! ", running(h))
step!(sim); println("after step! ", running(h))
t = bounded(() -> run!(sim))
println("in init ", d.in_init, " in loop ", d.in_loop, " after ", running(h),
        " loop final boundary ", d.final_boundary, " sim final ", latest(sim).boundary)
println("same handle as attach: ", h === sim.plane.roster[1].handle)

println("=== D init! throw order; loop skipped; abort")
mutable struct BI <: AbstractDevice; h; order::Vector{Any}; looped::Bool; end
BI() = BI(nothing, Any[], false)
init!(d::BI) = (push!(d.order, :init); error("boom"))
shutdown!(d::BI) = (push!(d.order, (:shutdown, length((@atomic d.h.diag_cell.batch).ring))); nothing)
loop(d::BI, h) = (d.looped = true; nothing)
mutable struct OK <: AbstractDevice; order::Vector{Symbol}; end
OK() = OK(Symbol[])
init!(d::OK) = (push!(d.order, :init); nothing)
shutdown!(d::OK) = (push!(d.order, :shutdown); nothing)
loop(d::OK, h) = (push!(d.order, :loop); while running(h); wait_next_snapshot(h); end; nothing)
sim = Simulation(two(); h = 1//10)
bi = BI(); bi.h = attach!(sim, bi, NoClaim())
ok = OK(); attach!(sim, ok, NoClaim())
init!(sim, set(u = U))
t = bounded(() -> run!(sim; t_end = 0.5))
s = latest(sim)
println("order ", bi.order, " looped ", bi.looped, " ok ", ok.order, " frames ", s.frame)
r = s.status.writers[1]
println("record ", r.who, " task_state ", r.task_state, " orphaned ", orphaned(r), " crash ", r.totals.crash, " stale ", stale(r), " hb ", r.heartbeat)
r0 = logged(sim)[1].status.writers[1]; println("boundary-zero record task_state ", r0.task_state, " orphaned ", orphaned(r0))
for w in s.status.writers; println("  who=", w.who, " ts=", w.task_state, " hb=", w.heartbeat, " orph=", orphaned(w), " stale=", stale(w)); end

sim = Simulation(two(); h = 1//10)
bi = BI(); bi.h = attach!(sim, bi, NoClaim(); should_abort = true)
ok = OK(); attach!(sim, ok, NoClaim())
init!(sim, set(u = U))
t = bounded(() -> run!(sim; t_end = 0.5))
println("abort: source ", termination(sim).source, " frames ", latest(sim).frame, " ok ", ok.order)

println("=== E loop ends")
crash(sim) = [(r.writer, [typeof(x) for x in r.recent]) for r in termination(sim).residue]
for (label, f, abort) in [("return no abort", h -> (wait_next_snapshot(h); nothing), false), ("return abort", h -> (wait_next_snapshot(h); nothing), true),
                          ("throw no abort", h -> (wait_next_snapshot(h); error("x")), false), ("throw abort", h -> (wait_next_snapshot(h); error("x")), true),
                          ("interrupt", h -> (wait_next_snapshot(h); throw(InterruptException())), false)]
    sim = Simulation(two(); h = 1//10)
    d = D(f); attach!(sim, d, NoClaim(); should_abort = abort)
    init!(sim, set(u = U))
    t = bounded(() -> run!(sim; t_end = 5.0, pace = 5.0))
    s = latest(sim)
    println(rpad(label, 18), " source ", termination(sim).source, " frames ", s.frame, " crash totals ", s.status.writers[1].totals.crash, " residue ", crash(sim), " ts ", s.status.writers[1].task_state)
end

println("=== E2 throw after running false: no override vs override")
mutable struct NoOv <: AbstractDevice end
loop(::NoOv, h) = (while running(h); wait_next_snapshot(h); end; error("late"))
mutable struct Ov <: AbstractDevice end
unblock!(::Ov) = nothing
loop(::Ov, h) = (while running(h); wait_next_snapshot(h); end; error("late"))
for dv in (NoOv(), Ov())
    sim = Simulation(two(); h = 1//10)
    attach!(sim, dv, NoClaim())
    init!(sim, set(u = U))
    t = bounded(() -> run!(sim; t_end = 0.3))
    println(typeof(dv), " residue ", crash(sim))
end

println("=== F unblock! throws: polled loop returns; blocked is abandoned; shutdown timing")
mutable struct UT <: AbstractDevice; log::Vector{Symbol}; end
unblock!(d::UT) = error("unblock boom")
shutdown!(d::UT) = (push!(d.log, :shutdown); nothing)
function loop(d::UT, h)
    while running(h); sleep(0.001); end
    push!(d.log, :returned); nothing
end
sim = Simulation(two(); h = 1//10, join_timeout = 30.0)
d = UT(Symbol[]); attach!(sim, d, NoClaim()); init!(sim, set(u = U))
t0 = time(); t = bounded(() -> run!(sim; t_end = 0.3)); el = time() - t0
println("polled: log ", d.log, " elapsed ", round(el, digits = 2), " residue ", crash(sim))

mutable struct UB <: AbstractDevice; ch::Channel{Int}; log::Vector{Symbol}; task; end
unblock!(d::UB) = error("unblock boom")
shutdown!(d::UB) = (push!(d.log, :shutdown); nothing)
loop(d::UB, h) = (d.task = current_task(); take!(d.ch); push!(d.log, :returned); nothing)
sim = Simulation(two(); h = 1//10, join_timeout = 0.3)
d = UB(Channel{Int}(1), Symbol[], nothing); attach!(sim, d, NoClaim()); init!(sim, set(u = U))
t = bounded(() -> run!(sim; t_end = 0.3))
println("blocked: lifecycle ", lifecycle(sim), " log at run! return ", d.log, " task done ", istaskdone(d.task), " residue ", crash(sim))
put!(d.ch, 1); timedwait(() -> istaskdone(d.task), 5.0)
println("blocked after release: log ", d.log, " task done ", istaskdone(d.task), " lifecycle ", lifecycle(sim))

mutable struct NB <: AbstractDevice; ch::Channel{Int}; log::Vector{Symbol}; task; end
shutdown!(d::NB) = (push!(d.log, :shutdown); nothing)
loop(d::NB, h) = (d.task = current_task(); take!(d.ch); nothing)
sim = Simulation(two(); h = 1//10, join_timeout = 0.3)
d = NB(Channel{Int}(1), Symbol[], nothing); attach!(sim, d, NoClaim()); init!(sim, set(u = U))
t = bounded(() -> run!(sim; t_end = 0.3))
println("no override wedged: log at run! return ", d.log, " task done ", istaskdone(d.task), " residue ", crash(sim))
put!(d.ch, 1); timedwait(() -> istaskdone(d.task), 5.0); println(" after release ", d.log)

println("=== G run! vs step! vs replay! calling init!/loop")
sim = Simulation(two(); h = 1//10)
o = OK(); attach!(sim, o, NoClaim()); init!(sim, set(u = U))
step!(sim); println("step!: ", o.order)
t = bounded(() -> run!(sim; t_end = 0.5)); println("run!: ", o.order)
trc = trace(sim); empty!(o.order)
t = bounded(() -> replay!(sim, trc)); println("replay!: ", o.order, " lifecycle ", lifecycle(sim))
end

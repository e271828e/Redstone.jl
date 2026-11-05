module P5
using Test
const W = pwd()
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
mutable struct D <: AbstractDevice; f::Function; end
loop(d::D, h) = d.f(h)

println("=== totals across step! then run!")
sim = Simulation(two(); h = 1//10)
h = attach!(sim, D(h -> nothing), NoClaim())
init!(sim, set(u = U))
report!(h, MalformedDatum("x")); report!(h, MalformedDatum("y"))
step!(sim)
stage!(sim, "zzz" => 1.0); step!(sim)
s1 = latest(sim)
println("after step!s device totals.malformed ", s1.status.writers[1].totals.malformed, " harness totals.out_of_claim ", s1.status.writers[2].totals.out_of_claim)
t = bounded(() -> run!(sim; t_end = 0.5))
s2 = latest(sim)
println("after run! device totals.malformed ", s2.status.writers[1].totals.malformed, " harness totals ", s2.status.writers[2].totals.out_of_claim, " boundaries ", s1.boundary, " -> ", s2.boundary)
seq = [x.status.writers[1].totals.malformed for x in logged(sim)]
println("logged malformed totals by boundary ", seq[1:min(end,6)])

println("=== recent on the loop record: both cells")
sim = Simulation(two(); h = 1//10)
init!(sim, set(u = U))
for i in 1:16
    report_cell!(sim.plane.loop_diag, ThreadBudget(1, i))
    report_cell!(sim.model.frame_diag, ThreadBudget(1, i))
end
report_cell!(sim.plane.loop_diag, ThreadBudget(1, 99))
step!(sim)
r = latest(sim).status.writers[end]
println("who ", r.who, " recent ", length(r.recent), " suppressed.thread_budget ", r.suppressed.thread_budget, " totals ", r.totals.thread_budget)

println("=== task_state: boundary zero, step!, run")
sim = Simulation(two(); h = 1//10)
go = Channel{Nothing}(1)
h = attach!(sim, D(h -> (take!(go); nothing)), NoClaim())
init!(sim, set(u = U))
println("boundary zero ", latest(sim).status.writers[1].task_state)
step!(sim); println("step! ", latest(sim).status.writers[1].task_state, " heartbeat ", latest(sim).status.writers[1].heartbeat)
t = @spawn run!(sim; t_end = 3.0, pace = 3.0)
sleep(0.2)
a = latest(sim).status.writers[1]; println("in run, task live ", a.task_state, " orphaned ", orphaned(a))
put!(go, nothing); sleep(0.2)
b = latest(sim).status.writers[1]; println("in run, task ended ", b.task_state, " orphaned ", orphaned(b))
timedwait(() -> istaskdone(t), 30.0)
c = latest(sim).status.writers[1]; println("final ", c.task_state, " lifecycle ", lifecycle(sim))

println("=== stale")
now_ = time()
rec = WriterStatus("d", Redstone.DiagValue[], KindCounts(), KindCounts(), 0.0, :running)
println("never beat: stale(now=time()) ", stale(rec), " stale(now=1.0) ", stale(rec; now = 1.0), " stale(now=2.0) ", stale(rec; now = 2.0))
sim = Simulation(two(); h = 1//10)
ch = Channel{Int}(1)
function parked(h)
    running(h)        # one beat
    take!(ch)         # a blocking read between rare data
    nothing
end
attach!(sim, D(parked), NoClaim(); )
init!(sim, set(u = U))
t = @spawn run!(sim; t_end = 4.0, pace = 1.0)
sleep(3.0)
r = latest(sim).status.writers[1]
println("parked in blocking read 3 s: hb lag ", round(time() - r.heartbeat, digits = 2), " stale ", stale(r), " task ", r.task_state)
put!(ch, 1); timedwait(() -> istaskdone(t), 30.0)

println("=== Snapshot.frame at a t* boundary")
sim = Simulation(single(Sawtooth(1.0)); h = 1//4)
init!(sim)
step!(sim; frames = 8)
for x in logged(sim)
    println("t=", x.t, " frame=", x.frame, " boundary=", x.boundary)
end
println("run.frame ", sim.run.frame)

println("=== Snapshot/Trace under restore!")
sim = Simulation(two(); h = 1//10)
h = attach!(sim, D(h -> nothing), Enumerated("a"))
init!(sim, set(u = U))
println("schemas after init (1 device) ", length(trace(sim).schemas), " ", trace(sim).schemas)
stage!(h, "a" => 1.0); step!(sim, frames = 2)
stage!(sim, "b" => 2.0); stage!(h, "a" => 2.0); step!(sim, frames = 2)
tr = trace(sim)
println("frames ", tr.frames, " batches ", [(b.frame, b.writer, b.entries) for b in tr.batches])
println("header frame ", tr.header.frame, " boundary ", tr.header.boundary, " type ", typeof(tr.header).name.name)
before = (length(tr.batches), tr.frames, length(tr.schemas))
stage!(h, "a" => 3.0); step!(sim, frames = 2)
println("copy detached ", before == (length(tr.batches), tr.frames, length(tr.schemas)), " live frames ", trace(sim).frames, " header same content ", trace(sim).header.frame)
cp = checkpoint(sim)
println("checkpoint frame ", cp.frame, " boundary ", cp.boundary)
step!(sim, frames = 2)
restore!(sim, cp)
tr = trace(sim)
println("after restore!: schemas ", length(tr.schemas), " frames ", tr.frames, " header.frame ", tr.header.frame, " latest frame ", latest(sim).frame, " boundary ", latest(sim).boundary, " t ", latest(sim).t)
stage!(h, "a" => 4.0); step!(sim)
tr = trace(sim)
println(" next: frames ", tr.frames, " records ", [(b.frame, b.writer) for b in tr.batches], " latest frame ", latest(sim).frame, " boundary ", latest(sim).boundary)

println("=== schemas growth per roster change")
sim = Simulation(two(); h = 1//10)
init!(sim, set(u = U))
n(sim) = length(trace(sim).schemas)
println("init, no device: ", n(sim))
d1 = D(h -> nothing); d2 = D(h -> nothing)
attach!(sim, d1, Enumerated("a")); println("attach 1st: ", n(sim))
attach!(sim, d2, Enumerated("b")); println("attach 2nd: ", n(sim))
detach!(sim, d1); println("detach: ", n(sim))
println(trace(sim).schemas)
init!(sim, set(u = U)); println("init again (same roster, fresh trace): ", n(sim))

println("=== stop requested, not yet stopped: an unblock! override's throw")
struct Gate <: AbstractComponent
    entered::Threads.Atomic{Bool}
    open::Threads.Atomic{Bool}
    armed::Threads.Atomic{Bool}
end
Gate() = Gate(Threads.Atomic{Bool}(false), Threads.Atomic{Bool}(false), Threads.Atomic{Bool}(false))
x_init(::Gate) = (q = 0.0,)
u_types(::Gate) = (u = Float64,)
y_types(::Gate) = (q = Float64,)
y_state(::Gate, (; x)) = (q = x.q,)
function x_deriv(c::Gate, (; x, t))
    if c.armed[] && !c.open[]
        c.entered[] = true
        deadline = time() + 40.0
        while !c.open[] && time() < deadline; yield(); ccall(:jl_cpu_pause, Cvoid, ()); end
    end
    (q = one(x.q),)
end
mutable struct OvT <: AbstractDevice; hh; task; end
unblock!(::OvT) = nothing
function loop(d::OvT, h)
    d.task = current_task()
    deadline = time() + 40.0
    while !GATE[].entered[] && time() < deadline; yield(); end
    stop!(h)
    println("  running after own stop! = ", running(h))
    error("thrown while the stop is requested")
end
const GATE = Ref{Any}(nothing)
gate = Gate(); GATE[] = gate
sim = Simulation(Group((; g = gate); input_wires = ("u" => "g/u",)); h = 1//10)
dev = OvT(nothing, nothing)
hh = attach!(sim, dev, Enumerated("u"))
init!(sim, set(u = (u = 0.0,)))
gate.armed[] = true
t = @spawn run!(sim; t_end = 1.0)
timedwait(() -> dev.task !== nothing && istaskdone(dev.task), 30.0)
println("device task done ", dev.task !== nothing && istaskdone(dev.task))
println("in-frame: pending ", pending(hh, 1), " stale snapshot t ", latest(sim).t)
sleep(0.1)
gate.open[] = true
timedwait(() -> istaskdone(t), 30.0)
println("source ", termination(sim).source, " residue ", [(r.writer, [typeof(x).name.name for x in r.recent]) for r in termination(sim).residue], " crash totals ", latest(sim).status.writers[1].totals.crash)

println("=== peek between drain and publication")
gate2 = Gate(); GATE[] = gate2
sim = Simulation(Group((; g = gate2); input_wires = ("u" => "g/u",)); h = 1//10)
hh = attach!(sim, D(h -> nothing), Enumerated("u"))
init!(sim, set(u = (u = 0.0,)))
v = port_views(hh)[("", :u)]
step!(sim)
stage!(hh, "u" => 7.0)
gate2.armed[] = true
println("staged peek ", peek(v, hh, latest(sim)))
t = @spawn step!(sim; frames = 3)
timedwait(() -> gate2.entered[], 30.0)
println("mid-frame after drain: pending ", pending(hh, 1), " peek ", peek(v, hh, latest(sim)), " latest t ", latest(sim).t)
gate2.open[] = true
timedwait(() -> istaskdone(t), 30.0)
println("after publication peek ", peek(v, hh, latest(sim)))

println("=== wait_next_snapshot: skipping, nothing, stop")
sim = Simulation(two(); h = 1//10)
h = attach!(sim, D(h -> nothing), NoClaim())
println("before init: latest ", latest(h), " wait ", wait_next_snapshot(h))
mutable struct Slow <: AbstractDevice; seen::Vector{Int}; end
function loop(d::Slow, h)
    while true
        s = wait_next_snapshot(h)
        s === nothing || push!(d.seen, s.boundary)
        running(h) || break
        sleep(0.05)
    end
    nothing
end
sim = Simulation(two(); h = 1//10)
d = Slow(Int[]); attach!(sim, d, NoClaim())
init!(sim, set(u = U))
t = @spawn run!(sim; t_end = 100.0, pace = 100.0)
timedwait(() -> istaskdone(t), 30.0)
sleep(0.2)
println("seen ", length(d.seen), " max gap ", maximum(diff(d.seen)), " last ", last(d.seen), " final ", latest(sim).boundary)

println("=== bare ports, bare root")
sim = Simulation(BareAccumulator(); h = 1//10)
println("root inputs ", sim.model.exec.act.layout.root_inputs)
hb = attach!(sim, D(h -> nothing), NoClaim())
init!(sim, set(u = (u = 0.0,)))
s = latest(sim)
println("port(s,'') ", port(s, ""), " port(s,'',:y) ", port(s, "", :y), " port(s,'',:u) ", port(s, "", :u))
for (k, v) in port_views(hb)
    println(k, " source ", v.source, " live ", v.live, " inc ", repr(v.incumbent))
end
g = Group((; a = BareAccumulator()); input_wires = ("in" => "a",))
sim = Simulation(g; h = 1//10); init!(sim, set(u = (in = 0.0,)))
s = latest(sim); println("port(s,'a') ", port(s, "a"), " port(s,'a',:y) ", port(s, "a", :y))
end

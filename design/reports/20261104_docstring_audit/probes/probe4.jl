using Redstone, StaticArrays, LinearAlgebra, ForwardDiff
include(joinpath(@__DIR__, "..", "..", "..", "..", "test", "imports.jl"))
import Redstone: unblock!, loop, is_output, reads as _reads_generic
struct LW <: AbstractComponent; x; z; zr; t; end
local_wires(::LW) = ("x/y" => "t/x", "z/y" => "t/z", "zr/y" => "t/z_ref")
kw = (K_fbk = SMatrix{1,1}(1.0), K_fwd = SMatrix{1,1}(1.0), K_int = SMatrix{1,1}(1.0))
mk(t) = LW(Constant(SVector(0.0)), Constant(SVector(0.0)), Constant(SVector(1.0)), t)
function msg(label, f)
    try
        println("OK ", label, " => ", f())
    catch e
        println("THROW ", label, " :: ", first(split(sprint(showerror, e), "\nStack"))[1:min(end,300)])
    end
end
let sim = Simulation(mk(LQRTracker(; kw...)); h = 1//10)
    init!(sim, set()); step!(sim; frames = 2)
    for sel in (get_state("t", :q), get_state("t", "q[1]"), get_state("t", "[1]"), get_state("t", "x[1]"))
        msg("LQR taps $sel", () -> linearize(sim, taps(x = (a = sel,), y = (b = get_output("t", "u[1]"),))).A)
    end
end
# devices
struct Plant <: AbstractComponent end
x_init(::Plant) = nothing
y_types(::Plant) = Float64
y_state(::Plant, _) = 1.0
struct B <: AbstractBinding end
is_output(::B) = true
Redstone.reads(::B) = (; v = get_output("", :y))
mutable struct PollDev <: AbstractDevice; end
loop(::PollDev, h) = while running(h); wait_next_snapshot(h); end
unblock!(::PollDev) = error("boom in unblock!")
mutable struct BlockDev <: AbstractDevice; ch::Channel{Int}; end
loop(d::BlockDev, h) = take!(d.ch)
unblock!(::BlockDev) = error("boom in unblock!")
mutable struct SleepDev <: AbstractDevice; ch::Channel{Int}; end
loop(d::SleepDev, h) = (running(h); take!(d.ch))
unblock!(d::SleepDev) = put!(d.ch, 1)
function kinds(s)
    w = latest(s).status.writers
    [(r.who, r.task_state, [typeof(d).name.name for d in r.recent]) for r in w]
end
for (name, dev) in (("poll", PollDev()), ("blocked", BlockDev(Channel{Int}(1))))
    sim = Simulation(Plant(); h = 1//10, join_timeout = 0.5)
    attach!(sim, dev, B())
    init!(sim, set())
    t = @elapsed run!(sim; t_end = 0.5, pace = 5.0)
    println(name, " run took ", round(t; digits=2), "s; lifecycle=", lifecycle(sim))
    println("  residue: ", [typeof(d).name.name for d in termination(sim).residue])
    if dev isa BlockDev
        put!(dev.ch, 1); sleep(0.2)
        println("  after put, chan len ", Base.n_avail(dev.ch))
    end
end
# heartbeat: block for 3s between data
let sim = Simulation(Plant(); h = 1//10)
    dev = SleepDev(Channel{Int}(1))
    attach!(sim, dev, B())
    init!(sim, set())
    r0 = latest(sim).status.writers[1]
    println("before run: heartbeat=", r0.heartbeat, " stale now=1.0: ", stale(r0; now = 1.0), " stale now=time(): ", stale(r0))
    run!(sim; t_end = 4.0, pace = 1.0)
    r = latest(sim).status.writers[1]
    println("device parked in take! since t=0, at the end: lag=", round(time() - r.heartbeat; digits=2), " stale=", stale(r))
end

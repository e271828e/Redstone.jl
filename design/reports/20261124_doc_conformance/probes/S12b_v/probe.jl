# S12b verifier probe: §12.4 / §12.5 behavioural claims, run against W.
module P
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const T = joinpath(pwd(), "test")
include(joinpath(T, "imports.jl"))
include(joinpath(T, "fixtures.jl"))
include(joinpath(T, "utils.jl"))
import Redstone: init!, shutdown!, loop, unblock!, x_init, m_init, u_types, y_types, y_state,
    state_events, x_deriv, termination, lifecycle, detach!

two_root_inputs() = Group((; s = Sum(sa = 1.0, sb = 1.0)); input_wires = ("a" => "s/a", "b" => "s/b"))
u0 = set(u = (a = 0.0, b = 0.0))
say(tag, v) = println(tag, " => ", v)

mutable struct BadInit2 <: AbstractDevice; log::Vector{Symbol}; end
init!(d::BadInit2) = (push!(d.log, :init); error("no hardware"))
shutdown!(d::BadInit2) = (push!(d.log, :shutdown); nothing)
loop(d::BadInit2, h) = (push!(d.log, :loop); nothing)

mutable struct InitInt <: AbstractDevice; log::Vector{Symbol}; end
init!(d::InitInt) = (push!(d.log, :init); throw(InterruptException()))
shutdown!(d::InitInt) = (push!(d.log, :shutdown); nothing)
loop(d::InitInt, h) = nothing

mutable struct BadBoth <: AbstractDevice; log::Vector{Symbol}; end      # init! and shutdown! both throw
init!(d::BadBoth) = (push!(d.log, :init); error("init boom"))
shutdown!(d::BadBoth) = (push!(d.log, :shutdown); error("shutdown boom"))
loop(d::BadBoth, h) = nothing

mutable struct Quitter <: AbstractDevice; log::Vector{Symbol}; end      # voluntary exit
shutdown!(d::Quitter) = (push!(d.log, :shutdown); nothing)
loop(d::Quitter, h) = (push!(d.log, :loop); nothing)

mutable struct Stub2 <: AbstractDevice; release::Channel{Int}; end      # ignores running
loop(d::Stub2, h) = (take!(d.release); nothing)

# a forced-throw stand-in: an InterruptException raised inside the frame
struct IntBomb <: AbstractComponent end
x_init(::IntBomb) = (q = 0.0,)
u_types(::IntBomb) = (arm = Bool,)
y_types(::IntBomb) = (q = Float64,)
y_state(::IntBomb, (; x)) = (q = x.q,)
x_deriv(::IntBomb, (; x, u)) = u.arm ? throw(InterruptException()) : (q = one(x.q),)

# manual event: a root input and a non-localized (Bool) guard reading it
struct Button <: AbstractComponent end
x_init(::Button) = nothing
m_init(::Button) = (on = false,)
u_types(::Button) = (press = Bool,)
y_types(::Button) = (on = Bool,)
y_state(::Button, (; m)) = (on = m.on,)
btn_guard(::Button, (; m, u)) = u.press && !m.on
btn_handler(::Button, (; m)) = (m = (on = true,),)
state_events(::Button) = (push = StateEvent(btn_guard, btn_handler),)

function main()
    # 043 / 091: join timeout abandonment, cap on Control
    sim = Simulation(two_root_inputs(); Δt_frame = 1//10, join_timeout = 0.3)
    d = Stub2(Channel{Int}(1)); attach!(sim, d, Enumerated())
    init!(sim, u0); t0 = time()
    Test.collect_test_logs() do; run!(sim; t_end = 0.2); end
    say("043 wall", round(time() - t0; digits = 2))
    say("043 residue", [(r.writer, map(typeof, r.recent)) for r in termination(sim).residue])
    say("043 lifecycle", lifecycle(sim)); put!(d.release, 1)
    say("091 cap on Control", sim.control.join_timeout)

    # 052: should_abort on a voluntary exit
    sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
    attach!(sim, Quitter(Symbol[]), Enumerated(); should_abort = true)
    init!(sim, u0); run_to_device_stop!(sim)
    say("052 source", termination(sim).source)

    # 072: t_end off the lattice, whole frames
    sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
    init!(sim, u0); run!(sim; t_end = 0.35)
    say("072 frame, t", (sim.run.frame, latest(sim).t, termination(sim).t))

    # 081 / 109 / 127 / 145 / 155 / 164: init! failure, flag clear then set
    sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
    dv = BadInit2(Symbol[]); attach!(sim, dv, Enumerated("a"))
    init!(sim, u0); run!(sim; t_end = 0.3)
    st = writer_status(latest(sim), "device 1 (BadInit2)")
    say("145 log, frames", (dv.log, sim.run.frame))
    say("081 terminal totals.crash", st.totals.crash)
    stage!(sim, "a" => 9.0)
    say("145 claim held after run (harness refused)", map(typeof, (@atomic sim.plane.harness_diag.batch).ring))
    say("100 detach! once stopped", (detach!(sim, dv); length(sim.plane.roster)))

    sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
    attach!(sim, BadInit2(Symbol[]), Enumerated("a"); should_abort = true)
    init!(sim, u0); Test.collect_test_logs() do; run!(sim; t_end = 0.5); end
    r = termination(sim)
    say("155 frames, source", (sim.run.frame, r.source, lifecycle(sim)))
    say("164 residue", [(x.writer, map(typeof, x.recent)) for x in r.residue])

    # 173 / 182: InterruptException in init!, should_abort set
    sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
    di = InitInt(Symbol[]); attach!(sim, di, Enumerated("a"); should_abort = true)
    attach!(sim, Pad("p"), Enumerated("b"))
    init!(sim, u0); Test.collect_test_logs() do; run!(sim; t_end = 0.5); end
    r = termination(sim)
    say("173 log, frames, source", (di.log, sim.run.frame, r.source))
    say("173 residue", [(x.writer, map(typeof, x.recent)) for x in r.residue])
    say("182 lifecycle, checkpoint ok", (lifecycle(sim), checkpoint(sim) isa Checkpoint))

    # 117: shutdown! throwing inside the init bracket
    sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
    db = BadBoth(Symbol[]); attach!(sim, db, Enumerated("a"))
    init!(sim, u0)
    logs, _ = Test.collect_test_logs() do; run!(sim; t_end = 0.3); end
    say("117 log, frames, lifecycle", (db.log, sim.run.frame, lifecycle(sim)))
    say("117 warnings", [string(l.message)[1:min(end, 70)] for l in logs if l.level == Base.CoreLogging.Warn])

    # 226 / 061: an InterruptException inside a frame is a StepError, run errored
    sim = Simulation(fed(IntBomb(), "arm"); Δt_frame = 1//10)
    dq = TailProbe(); attach!(sim, dq, NoClaim())
    init!(sim, set(u = (in = false,))); step!(sim; frames = 2)
    stage!(sim, "in" => true)
    Test.collect_test_logs() do; run!(sim; t_end = 1.0); end
    r = termination(sim)
    say("226 lifecycle, exc type, cause", (lifecycle(sim), typeof(r.source.exception), typeof(r.source.exception.cause)))
    say("061 device bracket ran", dq.log)

    # 284: manual event through a root input and a Bool guard
    sim = Simulation(fed(Button(), "press"); Δt_frame = 1//10)
    init!(sim, set(u = (in = false,))); step!(sim)
    a = port(latest(sim), "c", :on); stage!(sim, "in" => true); step!(sim)
    say("284 on before, after", (a, port(latest(sim), "c", :on)))

    # 268: discrete s published through a port
    sim = Simulation(Group((; c = TickCounter())); Δt_frame = 1//10)
    init!(sim); step!(sim; frames = 3)
    say("268 s.n via port", port(latest(sim), "c", :n))

    # 199: what disable_sigint is
    say("199 disable_sigint used in src", occursin("disable_sigint", read(joinpath(pwd(), "src", "sim.jl"), String)))
    say("120 stop! methods", [string(m.sig) for m in methods(stop!)])
end
end
P.main()

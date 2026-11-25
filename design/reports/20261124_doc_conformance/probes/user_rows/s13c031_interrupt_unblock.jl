# S13c-031: does an interrupt release a hanging `unblock!`? The hook parks on a
# channel on the calling task, and the interrupt is raised in that task there.
# The tail runs unmasked, so a real SIGINT can take this path too.
const TESTDIR = "/Users/miguel/.julia/dev/Redstone.jl/test"
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test, Logging
include(joinpath(TESTDIR, "imports.jl")); include(joinpath(TESTDIR, "fixtures.jl")); include(joinpath(TESTDIR, "utils.jl"))
import Redstone: loop, shutdown!, unblock!
say(t, x) = println(rpad(t, 40), " => ", x)

mutable struct HangUnblock <: AbstractDevice
    entered::Channel{Int}
    gate::Channel{Int}
end
loop(::HangUnblock, handle) = (while running(handle); wait_next_snapshot(handle); end)
unblock!(dev::HangUnblock) = (put!(dev.entered, 1); take!(dev.gate); nothing)

sim = Simulation(fed(Gain(1.0), "e"); Δt_frame = 1//10, join_timeout = 0.5)
dev = HangUnblock(Channel{Int}(1), Channel{Int}(1))
attach!(sim, dev, NoClaim())
init!(sim, set(u = (in = 0.0,)))
runner = Threads.@spawn try
    with_logger(NullLogger()) do; run!(sim; t_end = 0.3); end
    :returned
catch err
    typeof(err)
end
entered = timedwait(() -> isready(dev.entered), 20.0)
say("unblock! entered", entered)
sleep(1.5)                                   # three join timeouts: the hook still holds run!
say("run! done after 1.5 s", istaskdone(runner))
schedule(runner, InterruptException(); error = true)
say("run! done after the interrupt", timedwait(() -> istaskdone(runner), 20.0))
say("run! outcome", istaskdone(runner) ? fetch(runner) : :hung)
say("lifecycle", lifecycle(sim))
say("termination source", termination(sim) === nothing ? nothing : typeof(termination(sim).source))
say("residue", termination(sim) === nothing ? nothing : [(r.writer, typeof.(r.recent)) for r in termination(sim).residue])
put!(dev.gate, 1)

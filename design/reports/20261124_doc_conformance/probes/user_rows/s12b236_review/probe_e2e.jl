# S12b-236: an interrupt raised inside the masked bookkeeping of `_run_body!`.
# A forced SIGINT cannot be placed, so a logger stands in for it: the run's-end
# sweep presents its residue through `@warn`, inside the mask, and a logger
# with `catch_exceptions = false` raises `InterruptException` from there.
const TESTDIR = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/s12b_review/test"
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test; using Base.CoreLogging: AbstractLogger, with_logger; const Logging = Base.CoreLogging
include(joinpath(TESTDIR, "imports.jl")); include(joinpath(TESTDIR, "fixtures.jl")); include(joinpath(TESTDIR, "utils.jl"))
import Redstone: loop, shutdown!, unblock!
say(t, x) = println(rpad(t, 46), " => ", x)

mutable struct Stubborn <: AbstractDevice; release::Channel{Int}; end
loop(dev::Stubborn, handle) = (take!(dev.release); nothing)

struct Forcing <: AbstractLogger end
Logging.min_enabled_level(::Forcing) = Logging.Debug
Logging.shouldlog(::Forcing, args...) = true
Logging.catch_exceptions(::Forcing) = false
Logging.handle_message(::Forcing, level, msg, args...; kw...) =
    occursin("past the final snapshot", string(msg)) ? throw(InterruptException()) : nothing

depth() = (n = 0; try; while true; Base.sigatomic_end(); n += 1; end; catch; end; n)

say("mask depth before", depth())
sim = Simulation(fed(Gain(1.0), "e"); Δt_frame = 1//10, join_timeout = 0.2)
dev = Stubborn(Channel{Int}(1))
attach!(sim, dev, NoClaim())
init!(sim, set(u = (in = 0.0,)))
out = try
    with_logger(Forcing()) do; run!(sim; t_end = 0.3); end
    :returned
catch err
    typeof(err)
end
say("run! under the forcing logger", out)
say("lifecycle after", lifecycle(sim))
say("termination record", termination(sim))
say("mask depth leaked", depth())
put!(dev.release, 1)
for (name, f) in (("run!", () -> run!(sim; t_end = 1.0)), ("step!", () -> step!(sim; frames = 1)),
                  ("init!", () -> init!(sim, set(u = (in = 0.0,)))), ("checkpoint", () -> checkpoint(sim)))
    r = try; f(); :ok; catch err; first(sprint(showerror, err), 160); end
    say("$name afterwards", r)
end

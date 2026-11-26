# Real SIGINTs sent from inside the residue's presentation, which runs masked.
# (a) one SIGINT: deferred, it should raise at the mask's end, after every warning.
# (b) repeated SIGINTs: Julia forces the throw inside the presentation.
const TESTDIR = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/s12b_review/test"
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test
const CL = Base.CoreLogging
include(joinpath(TESTDIR, "imports.jl")); include(joinpath(TESTDIR, "fixtures.jl")); include(joinpath(TESTDIR, "utils.jl"))
import Redstone: loop
say(t, x) = println(rpad(t, 40), " => ", x)
mutable struct Stub <: AbstractDevice; release::Channel{Int}; end
loop(dev::Stub, handle) = (take!(dev.release); nothing)

mutable struct Sender <: CL.AbstractLogger; mode::Symbol; seen::Vector{String}; sent::Bool; end
CL.min_enabled_level(::Sender) = CL.Debug
CL.shouldlog(::Sender, args...) = true
CL.catch_exceptions(::Sender) = false
function CL.handle_message(l::Sender, level, msg, args...; kw...)
    s = string(msg)
    occursin("past the final snapshot", s) || return nothing
    push!(l.seen, first(s, 40))
    l.sent && return nothing
    l.sent = true
    if l.mode === :deferred
        interrupt_self()
    else
        # keep sending until the runtime forces the throw in here
        deadline = time() + 20
        while time() < deadline
            ccall(:kill, Cint, (Cint, Cint), getpid(), Cint(2))
            t = time(); while time() < t + 0.05; end
        end
        say("  forced throw never came", "")
    end
    nothing
end
depth() = (n = 0; try; while true; Base.sigatomic_end(); n += 1; end; catch; end; for _ in 1:n; Base.sigatomic_begin(); end; n)

Base.exit_on_sigint(false)
for mode in (:deferred, :forced)
    sim = Simulation(fed(Gain(1.0), "e"); Δt_frame = 1//10, join_timeout = 0.2)
    devs = [Stub(Channel{Int}(1)) for _ in 1:2]   # two abandoned joins: two residue warnings
    for d in devs; attach!(sim, d, NoClaim()); end
    init!(sim, set(u = (in = 0.0,)))
    logger = Sender(mode, String[], false)
    say("[$mode] depth before", depth())
    out = try
        CL.with_logger(logger) do; run!(sim; t_end = 0.3); end
        :returned
    catch err
        typeof(err)
    end
    say("[$mode] run! outcome", out)
    say("[$mode] depth after (caught)", depth())
    say("[$mode] warnings seen", length(logger.seen))
    say("[$mode] lifecycle", lifecycle(sim))
    rec = termination(sim)
    say("[$mode] record source", rec === nothing ? nothing : rec.source)
    say("[$mode] record residue n", rec === nothing ? nothing : sum(length(r.recent) for r in rec.residue))
    for d in devs; put!(d.release, 1); end
    r = try; init!(sim, set(u = (in = 0.0,))); run!(sim; t_end = 0.1); lifecycle(sim); catch err; first(sprint(showerror, err), 120); end
    say("[$mode] init!+run! afterwards", r)
end

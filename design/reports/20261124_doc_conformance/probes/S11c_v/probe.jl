# S11c verifier probes, run from the pinned worktree with --project=test.
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test
include(joinpath(pwd(), "test", "imports.jl"))
include(joinpath(pwd(), "test", "fixtures.jl"))
p(label, v) = println(rpad(label, 34), " => ", repr(v))
two_root_inputs() = Group((; s = Sum(sa = 1.0, sb = 1.0));
                    input_wires = ("a" => "s/a", "b" => "s/b"))

# 001/010/039/049: trace length, header timing, one record per drained batch
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
init!(sim, set(u = (a = 0.0, b = 0.0)))
trc = trace(sim)
p("P1 frames after init!", trc.frames)
p("P1 header frame/boundary", (trc.header.frame, trc.header.boundary))
step!(sim; frames = 3)                       # three drains, nothing staged
p("P2 frames after 3 empty drains", trace(sim).frames)
p("P2 batches after 3 empty drains", length(trace(sim).batches))
for k in 1:300
    stage!(sim, isodd(k) ? "a" => Float64(k) : "b" => Float64(k))
    step!(sim)
end
trc = trace(sim)
p("P3 frames after 303", trc.frames)
p("P3 batches (no window)", length(trc.batches))
p("P3 first record", first(trc.batches))
p("P3 writer tags", unique(first.(trc.schemas)))

# 014: checkpoint fields
p("P4 ModelState fields", fieldnames(ModelState))
p("P4 Checkpoint fields", fieldnames(Checkpoint))
# 030: deployment fields
p("P5 Deployment fields", fieldnames(Deployment))

# 041: the sketch's one-argument DeviceCrash
p("P6 DeviceCrash(e) applicable", applicable(DeviceCrash, ErrorException("x")))
p("P6 DeviceCrash fields", fieldnames(DeviceCrash))

# 102: gather labels in declaration order
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
h = attach!(sim, Pad("p"), Readout(z = get_input("b"), a = get_input("a")))
init!(sim, set(u = (a = 1.0, b = 2.0)))
p("P7 gather keys", keys(gather(h, latest(sim))))

# 089/113: neither side, and the other violation messages
struct ProbeNoSides <: AbstractBinding end
struct ProbeGreedyPlus <: AbstractBinding end
Redstone.is_input(::ProbeGreedyPlus) = true
Redstone.is_greedy(::ProbeGreedyPlus) = true
Redstone.claims(::ProbeGreedyPlus) = ("a",)
struct ProbeNoEnum <: AbstractBinding end
Redstone.is_input(::ProbeNoEnum) = true
for b in (ProbeNoSides(), ProbeGreedyPlus(), ProbeNoEnum())
    local sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
    try
        attach!(sim, Pad("p"), b)
        p("P8 $(typeof(b)) attached", true)
    catch err
        d = err.carried isa Vector ? only(err.carried) : err.carried
        p("P8 $(typeof(b)) kind", typeof(d))
        p("P8 $(typeof(b)) payload", (; (f => getfield(d, f) for f in fieldnames(typeof(d)))...))
        println("   message: ", Redstone.message(d))
    end
end

# 050: an interrupt inside the loop body under should_abort = true
mutable struct ProbeInterrupted <: AbstractDevice end
Redstone.loop(::ProbeInterrupted, handle) = throw(InterruptException())
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
attach!(sim, ProbeInterrupted(), Enumerated("a"); should_abort = true)
init!(sim, set(u = (a = 0.0, b = 0.0)))
run!(sim; t_end = 1.0e3)
p("P9 termination source", termination(sim).source)

# S9d_v independent verifier probes. Run from W with --project=test.
module ProbeS9d
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
include(joinpath(W, "utils.jl"))
include(joinpath(W, "test_store.jl"))   # MixedCell

println("P0 julia ", VERSION)

# P1 (S9d-048): a closure capturing an @nospecialize argument is one type whatever the value's type.
mk(@nospecialize(c)) = (() -> c)
println("P1 closure over @nospecialize arg: same type for Int and String = ",
        typeof(mk(1)) === typeof(mk("a")), "  fieldtype = ", fieldtype(typeof(mk(1)), 1))

# P2 (S9d-010): a mixed-leaf cell's address carries one offset per element type.
b = build(single(MixedCell()))
sim = Simulation(b; Δt_frame = 1//100)
for (k, a) in sim.model.exec.act.layout.addr
    k[1] == "c" && println("P2 addr ", k, " => ", typeof(a), " offsets=", a.offsets)
end

# P3 (S9d-001): Outputs fields
o = b.outputs
println("P3 Outputs fields ", fieldnames(typeof(o)), "; entry fields ", fieldnames(eltype(o.components)),
        "; entry ", o.components[1])

# P4 (S9d-067, S9d-017): roster on a model with no continuous state, and on one with no discrete.
for (label, model) in (("discrete-only", Group((; counter = TickCounter()))),
                       ("continuous-only", feedback_model()))
    s = Simulation(model; Δt_frame = 1//10)
    label == "continuous-only" ? init!(s, set(u = (ref = 0.5,))) : init!(s)
    bodies = phase_bodies(s)
    println("P4 ", label, " keys=", keys(bodies), " n_x=", length(s.model.exec.xbuf),
            " events=", length(bodies.events), " projections=", length(bodies.projections))
    for name in (:sweep_1, :sweep_2, :rhs, :ticks)
        body = bodies[name]
        body(); body(0)
        println("P4   ", name, " interior chunks=", length(body.interior), " boundary chunks=",
                length(body.boundary), " alloc()=", @ballocated($body()), " alloc(1)=", @ballocated($body(1)))
    end
    rhs = bodies.rhs
    println("P4   rhs(3) accepted: ", (rhs(3); true), "; same tuple types: ",
            fieldtype(typeof(rhs), :interior) === fieldtype(typeof(rhs), :boundary))
end

# P5 (S9d-029): chunks are mutable (held by reference)
s = Simulation(feedback_model(); Δt_frame = 1//10)
c = first(s.model.exec.bodies.sweep_2.interior)
println("P5 Chunk ismutable=", ismutable(c), " EventSet ismutable=", ismutable(s.model.exec.events),
        " default chunk_size=", s.model.exec.chunk_size)
end

# P6 (S9d-057): a cold child process on the package image, compile time per phase.
child = raw"""
Base.cumulative_compile_timing(true)
t_load = @elapsed using Redstone
import Redstone: build, Simulation, init!, step!, run!, set, port, state, series, reads, get_output,
    checkpoint, restore!, trim!, TrimProblem, get_deriv, linearize, taps, get_state, get_input, BS3
c0 = Base.cumulative_compile_time_ns()[1]
w0 = time_ns()
loop_build = build(Redstone.workload_loop())
sim = Simulation(loop_build; Δt_frame = 1//1000)
init!(sim, set(u = (disturbance = 0.0,)))
step!(sim)
run!(sim; t_end = 0.1)
port(sim, "plant"); state(sim, "plant")
series(sim, reads(y = get_output("plant")))
restore!(sim, checkpoint(sim))
c1 = Base.cumulative_compile_time_ns()[1]; w1 = time_ns()
trim_sim = Simulation(loop_build; Δt_frame = 1//1000)
trim!(trim_sim, TrimProblem(
    guess = (d = 0.3,), lower = (d = -1.0,), upper = (d = 1.0,),
    condition = d -> set(u = (disturbance = d.d,)),
    reads = reads(q̇₂ = get_deriv("plant", "[2]")),
    residuals = (derivatives, d) -> (q̇₂ = derivatives.q̇₂,),
    tolerances = (q̇₂ = 1e-9,)); baseline = set(u = (disturbance = 0.0,)))
c2 = Base.cumulative_compile_time_ns()[1]; w2 = time_ns()
linearize(trim_sim, taps(
    x = (q₁ = get_state("plant", "[1]"), q₂ = get_state("plant", "[2]")),
    u = (d = get_input(:disturbance),), y = (y = get_output("plant"),)))
c3 = Base.cumulative_compile_time_ns()[1]; w3 = time_ns()
println("P6 load=", round(t_load, digits=2), " s; loop compile=", (c1-c0)/1e9, " wall=", (w1-w0)/1e9,
        "; trim! compile=", (c2-c1)/1e9, " wall=", (w2-w1)/1e9,
        "; linearize compile=", (c3-c2)/1e9, " wall=", (w3-w2)/1e9)
"""
julia = Base.julia_cmd().exec
for i in 1:2
    print(read(`$julia --startup-file=no --project=$(Base.active_project()) -e $child`, String))
end

# P7 (S9d-048): a closure over a local read from an abstract field, as compile's state_events closure (src/build.jl:1592).
struct Holder; x::Any; end
cap(h::Holder) = (c = h.x; () -> c)
println("P7 closure over abstract-field local: same type for Int and String = ",
        typeof(cap(Holder(1))) === typeof(cap(Holder("a"))), "  ", typeof(cap(Holder(1))))

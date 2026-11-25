# S6d verifier probes, run from the pinned worktree with --project=test.
module ProbeS6d
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/"
include(W * "imports.jl")
include(W * "fixtures.jl")
include(W * "utils.jl")

say(id, x) = println(id, " => ", x)

# S6d-010: a declared port neither stage returns.
struct Unproduced <: AbstractComponent end
x_init(::Unproduced) = (q = 0.0,)
y_types(::Unproduced) = (a = Float64, b = Float64)
y_state(::Unproduced, (; x)) = (a = x.q,)
x_deriv(::Unproduced, (; x)) = (q = 0.0,)
err = failure(() -> build(Unproduced()))
say("P010", map(d -> (typeof(d), d.ports), diagnostics(err)))

# S6d-020: the keys x_deriv's bundle carries.
const SEEN = Ref{Any}(nothing)
struct Seer <: AbstractComponent end
x_init(::Seer) = (q = 0.0,)
m_init(::Seer) = (on = false,)
u_types(::Seer) = (v = Float64,)
y_types(::Seer) = (p = Float64,)
y_state(::Seer, (; x)) = (p = x.q,)
x_deriv(::Seer, b) = (SEEN[] = keys(b); (q = 0.0,))
sim = Simulation(Group((; s = Seer()); input_wires = ("in" => "s/v",)); Δt_frame = 1//10)
init!(sim, set(u = (in = 1.0,))); step!(sim)
say("P020", SEEN[])

# S6d-049: boundary zero runs only the phase-zero update.
sim = Simulation(Group((; c0 = TickCounter(), c1 = TickCounter());
                       sample_times = (; c0 = Relative(2, 0), c1 = Relative(2, 1))); Δt_frame = 1//10)
init!(sim)
say("P049", (c0 = state(sim, "c0").n, c1 = state(sim, "c1").n,
             c0_port = port(sim, "c0", :n), c1_port = port(sim, "c1", :n)))

# S6d-068: an input read only by x_deriv still adds an edge when stage 2 exists.
struct DerivOnly <: AbstractComponent end
x_init(::DerivOnly) = (q = 0.0,)
u_types(::DerivOnly) = (v = Float64, w = Float64)
y_types(::DerivOnly) = (out = Float64,)
y_direct(::DerivOnly, (; x, u)) = (out = x.q + u.w,)
x_deriv(::DerivOnly, (; u)) = (q = u.v,)
cyc = Group((; d = DerivOnly(), g = Gain(1.0));
             local_wires = ("d/out" => "g/e", "g/out" => "d/v"),
             input_wires = ("in" => "d/w",))
r = try build(cyc) catch e; e end
say("P068", r isa DiagnosticError ? map(typeof, diagnostics(r)) : typeof(r))

# S6d-077/087: an input_wires endpoint past an immediate child is refused.
deep = Group((; g = Group((; k = Gain(1.0)); input_wires = ("u" => "k/e",),
                          output_wires = ("k/out" => "y",)));
             input_wires = ("in" => "g/k/e",))
r = try build(deep) catch e; e end
say("P077", r isa DiagnosticError ? map(d -> (typeof(d), hasfield(typeof(d), :reason) ? d.reason : nothing), diagnostics(r)) : typeof(r))
ok = Group((; g = Group((; k = Gain(1.0)); input_wires = ("u" => "k/e",),
                        output_wires = ("k/out" => "y",)));
           input_wires = ("in" => "g/u",))
say("P077ok", typeof(build(ok)))

# S6d-096: a frozen handle passes at a tolerant entry as the producer's cell.
for src in (PinnedOffsetSource(), DiscreteOffsetSource())
    b = build(offset_model(src))
    m = Model(b, ForwardDiff.Dual{Nothing,Float64,8}; Δt_frame = 1//100)
    say("P096", (typeof(src), typeof(port(m, "src", :terrain)), typeof(port(m, "q", :h))))
end

# S6d-105: the root's own input face is the root input; a primitive root's inputs too.
sim = Simulation(Group((; k = Gain(2.0)); input_wires = ("in" => "k/e",)); Δt_frame = 1//10)
init!(sim, set(u = (in = 3.0,)))
say("P105", port(sim, "k", :out))
sim = Simulation(Gain(2.0); Δt_frame = 1//10)
init!(sim, set(u = (e = 3.0,)))
say("P105prim", port(sim, "", :out))
end

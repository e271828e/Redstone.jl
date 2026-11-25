# L6e verifier probes, run from the pinned worktree with --project=test.
module L6eProbe
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
include(joinpath(W, "utils.jl"))

say(tag, x) = println(tag, " => ", x)
dg(e) = (p = getfield(e, 1); p isa AbstractVector ? p : [p])

# L6e-025/026/031/037: names that exist or not
for n in (:capture, :checkpoint, :local_types, :ws_init, :workspace, :Hz, :labeled, :transparent_container)
    say("P1 isdefined Redstone.$n", isdefined(Redstone, n))
end
say("P1b ws_init methods", methods(Redstone.ws_init))

# L6e-040/043: the type walk on type parameters and value parameters
struct RP{T<:Real}; a::T; end
struct VP{T,N}; a::NTuple{N,T}; end
D = ProbeDual
say("P2 retype RP{Float64}", Redstone.retype(D, RP{Float64}))
say("P2 retype RP{Float32}", Redstone.retype(D, RP{Float32}))
say("P2 retype VP{Float64,3}", Redstone.retype(D, VP{Float64,3}))
say("P2 retype SVector{3,Float64}", Redstone.retype(D, SVector{3,Float64}))

# L6e-139: a struct nesting a Symbol is not isbits, so it fails the one predicate
struct SymBox; s::Symbol; end
say("P3 isbits(SymBox(:a))", isbits(SymBox(:a)))
struct BadStore <: AbstractComponent end
s_init(::BadStore) = (b = SymBox(:a),)
u_types(::BadStore) = (e = Float64,)
y_types(::BadStore) = (y = Float64,)
y_state(::BadStore, (; s)) = (y = 0.0,)
s_update(::BadStore, (; s)) = s
let err = failure(() -> build(Group((; k = Constant(1.0), b = BadStore()); local_wires = ("k/y" => "b/e",))))
    say("P3 BadStore diags", [typeof(d) for d in diagnostics(err)])
end

# L6e-101/102/103/105: Δt_base sources
acc_model() = Group((; k = Constant(1.0), ctl = DiscreteAccumulator(1.0)); local_wires = ("k/y" => "ctl/e",))
b = build(acc_model())
let dep = Deployment(b; Δt_frame = 1//10)
    say("P4 default Δt_base", (dep.Δt_base, dep.Δt_frame))
end
let dep = Deployment(b; Δt_frame = 1//10, Δt_base = 1//20)
    say("P4 explicit Δt_base", dep.Δt_base, )
    say("P4 deployment fields", fieldnames(typeof(dep)))
end
let err = failure(() -> Deployment(b; Δt_frame = 1//10, Δt_base = :derive))
    d = only(diagnostics(err))
    say("P4 derive with unanchored", (typeof(d), d.reason, d.paths))
    say("P4 derive message", sprint(showerror, err))
end
try
    @eval using Dates
    err = failure(() -> Deployment(b; Δt_frame = 1//10, Δt_base = Dates.Millisecond(50)))
    say("P4 Period Δt_base", [(typeof(d), d.reason) for d in diagnostics(err)])
catch e
    say("P4 Period probe skipped", e)
end
let err = failure(() -> Deployment(b; Δt_frame = 1//10, N_base = 2))
    say("P4 N_base keyword", err)
end

# L6e-025/027/175: linearize and path refusals on the pendulum
lin_pend() = Group((; s = Sum(), c = Pendulum()); local_wires = ("s/e" => "c/u",),
                   input_wires = ("τ" => "s/a", "d" => "s/b"),
                   output_wires = ("c/θ" => "θ", "s/e" => "u_eff"))
sim = Simulation(lin_pend(); Δt_frame = 1//10)
init!(sim, combine(at("c", condition(Pendulum(); θ = 0.3)), set(u = (τ = 9.81 * sin(0.3), d = 0.0))))
tp = taps(x = (θ = get_state("c", :θ), ω = get_state("c", :ω)), u = (τ = get_input(:τ),), y = (θ = get_face(:θ),))
L = linearize(sim, tp)
say("P5 linearize A type", (typeof(L), typeof(L.A), L.A))
say("P5 checkpoint type", typeof(checkpoint(sim)))
for p in ("zz/θ", "c/zz/θ", "c/zz")
    for f in (port, state)
        r = try
            f(sim, p); "no throw"
        catch e
            e isa DiagnosticError ? [(typeof(d), getfield(d, :reason), d.level, d.candidates, d.segment) for d in dg(e)] : e
        end
        say("P6 $(f)(sim, \"$p\")", r)
    end
end
nested = Group((; a = Group((; g = Gain(1.0), h = Gain(2.0)); input_wires = ("e" => ("g/e", "h/e"),),
                                output_wires = ("g/out" => "o",))); input_wires = ("e" => "a/e",),
               output_wires = ("a/o" => "o",))
nsim = Simulation(nested; Δt_frame = 1//10)
init!(nsim, set(u = (e = 1.0,)))
for p in ("a/zz/out", "a/g/zz/out", "a/g/out")
    r = try
        port(nsim, p)
    catch e
        e isa DiagnosticError ? [(typeof(d), getfield(d, :reason), d.level, d.candidates, d.segment) for d in dg(e)] : e
    end
    say("P7 port(nsim, \"$p\")", r)
end
end

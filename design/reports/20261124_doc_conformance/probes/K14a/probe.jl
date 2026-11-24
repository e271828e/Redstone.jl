using Redstone, StaticArrays, LinearAlgebra, ForwardDiff
using Test
T = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(T, "imports.jl"))
include(joinpath(T, "fixtures.jl"))
include(joinpath(T, "utils.jl"))
show_err(f) = try f(); println("no error") catch e
    e isa DiagnosticError ? println("ERR ", [(typeof(d), hasproperty(d,:reason) ? d.reason : nothing) for d in diagnostics(e)]) : println("ERR ", typeof(e)) end
println("P1 pair-form condition:")           # probe:P1
show_err(() -> condition("atm" => 1.0, "trn" => 2.0))
println("P2 wired face written:")            # probe:P2
sim = Simulation(fed(Pendulum(), :u); Δt_frame = 1//10)
show_err(() -> init!(sim, at("c", set(u = (u = 1.0,)))))
println("P3 root input of bare leaf:")        # probe:P3
sim2 = Simulation(Pendulum(); Δt_frame = 1//10)
show_err(() -> init!(sim2, set(u = 1.0)))
println(sim2 isa Simulation)
println("P4 checks mismatch, report:")        # probe:P4
sim = Simulation(fed(Pendulum(), :u); Δt_frame = 1//10)
base = set(u = (in = 0.0,))
decide_u(d) = combine(at("c", condition(Pendulum(); θ = 0.5)), set(u = (in = d.u,)))
pr = TrimProblem(guess = (u = 0.0,), lower = (u = -Inf,), upper = (u = Inf,), condition = decide_u,
    reads = reads(ω̇ = get_deriv("c", :ω), θ = get_state("c", :θ)), residuals = (r, d) -> (torque = r.ω̇,),
    tolerances = (torque = 1e-9,), checks = (r, d) -> (θ = r.θ - 0.3,), check_tolerances = (θ = 1e-6,))
rep = trim!(sim, pr; baseline = base)
println(rep.converged, " ", rep.committed_checks, " ", hasproperty(rep, :warnings), " ", fieldnames(TrimReport))
println("P5 default checks:")
pr0 = TrimProblem(guess = (u = 0.0,), lower = (u = -Inf,), upper = (u = Inf,), condition = decide_u,
    reads = reads(ω̇ = get_deriv("c", :ω)), residuals = (r, d) -> (torque = r.ω̇,), tolerances = (torque = 1e-9,))
println(pr0.check_tolerances, " ", pr0.checks(nothing, nothing))
println("P6 malformed check before solve:")
sim = Simulation(fed(Pendulum(), :u); Δt_frame = 1//10)
bad = TrimProblem(guess = (u = 0.0,), lower = (u = -Inf,), upper = (u = Inf,), condition = decide_u,
    reads = reads(ω̇ = get_deriv("c", :ω), θ = get_state("c", :θ)), residuals = (r, d) -> (torque = r.ω̇,),
    tolerances = (torque = 1e-9,), checks = (r, d) -> (wrong = r.θ,), check_tolerances = (θ = 1e-6,))
show_err(() -> trim!(sim, bad; baseline = base))

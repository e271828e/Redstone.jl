module ProbeL6a
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
include(joinpath(W, "utils.jl"))

tryd(f) = try f() catch e; e isa DiagnosticError ? [(nameof(typeof(d)), [getfield(d, n) for n in fieldnames(typeof(d)) if n in (:parameter, :reason, :argument, :related, :call)]) for d in (e.carried isa Vector ? e.carried : [e.carried])] : e end

b = build(fed(Plant(), "u"))
println("P1 attempt_budget default: ", Deployment(b; Δt_frame = 1//100).attempt_budget)
println("P2 h_min between half and full h_max: ",
        tryd(() -> Deployment(b; Δt_frame = 1//100, h_max = 1//100, h_min = 3//400, algorithm = BS3())))
println("P3 h_min = h_max/2 accepted: ",
        tryd(() -> Deployment(b; Δt_frame = 1//100, h_max = 1//100, h_min = 1//200, algorithm = BS3())) isa Deployment)
println("P4 float h_max: ", tryd(() -> Deployment(b; Δt_frame = 1//100, h_max = 0.001)))
println("P5 BS3 without h_min: ", tryd(() -> Deployment(b; Δt_frame = 1//100, algorithm = BS3())))
d = Deployment(b; Δt_frame = 1//100)
println("P6 h_max resolved when absent: ", d.h_max, " ; field types ", typeof(d.Δt_frame), " ", typeof(d.h_max))
println("P7 two decks equal with h_max absent and above frame: ",
        d == Deployment(b; Δt_frame = 1//100, h_max = 1))
println("P8 show: ", sprint(show, MIME"text/plain"(), d))
println("P9 descriptor deployment keys: ", keys(descriptor(d).deployment))
m = Model(d, Float64)
println("P10 init! t0 = 1e-4: ", tryd(() -> init!(m, set(u = (in = 0.0,)); t0 = 1e-4)))
println("P11 init! t0 = π: ", tryd(() -> init!(m, set(u = (in = 0.0,)); t0 = π)))
println("P12 init! t0 = 0.25 ok: ", tryd(() -> init!(m, set(u = (in = 0.0,)); t0 = 0.25)))
println("P13 clock t₀ type: ", typeof(m.exec.clock.t₀), " value ", m.exec.clock.t₀)
cp = checkpoint(m)
println("P14 ModelState fields: ", fieldnames(typeof(cp)))
println("P15 StateEvent fields: ", fieldnames(StateEvent))
println("P16 StateEvent localize keyword: ", tryd(() -> StateEvent(identity, identity; localize = true)))
println("P17 x_deriv / state_derivative defined: ", isdefined(Redstone, :x_deriv), " ", isdefined(Redstone, :state_derivative), " ", isdefined(Redstone, :x_derivative))
println("P18 PIVector defined: ", isdefined(Redstone, :PIVector))
println("P19 float Δt_frame: ", tryd(() -> Deployment(b; Δt_frame = 0.01)))
println("P20 frame! past last frame: ", tryd(() -> Redstone.frame!(m, typemax(Int))))
println("P21 Deployment fieldnames: ", fieldnames(Deployment))
println("P22 firing_budget default: ", d.firing_budget, " localization_budget ", d.localization_budget, " tol ", d.localization_tol)
end

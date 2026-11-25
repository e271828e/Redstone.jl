# SD2 verifier probes, run from the pinned worktree with --project=test.
module SD2Probe
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
include(joinpath(W, "utils.jl"))
import Redstone: frame_top!, settled!, activation, ProbeDual, x_projection, x_init,
    y_types, y_state, x_deriv, state_events, StateEvent

report(id, x) = println(id, " => ", x)

mutable struct Hooks{M} <: FrameHooks
    model::M
    rec::Vector{Tuple{Float64,Int}}
end
frame_top!(::Hooks) = false
settled!(h::Hooks) = (push!(h.rec, (Float64(h.model.exec.clock.t), state(h.model, "a").n)); false)

# P1 deployment defaults (SD2-028, SD2-073)
let d = Deployment(build(single(BareRamp())); Δt_frame = 1//10)
    report("P1 firing_budget/localization_budget", (d.firing_budget, d.localization_budget))
end

# P2 no required ratio + every step end a boundary + due instant ends its step
# (SD2-019, SD2-055, SD2-064, SD2-121)
split() = Group((; c = Plant(), a = TickCounter()); input_wires = ("in" => "c/u",),
                sample_times = (; a = Absolute(7//100)))
let model = Model(split(); Δt_frame = 1//10, Δt_base = 1//100, h_max = 3//100)
    init!(model, set(u = (in = 0.0,)))
    h = Hooks(model, Tuple{Float64,Int}[])
    foreach(k -> frame!(model, k, h), 1:2)
    report("P2 boundaries (t, n) frames 1-2, h_max 3/100, tick 7/100", h.rec)
end
let model = Model(Group((; c = Plant(), a = TickCounter()); input_wires = ("in" => "c/u",),
                        sample_times = (; a = Relative(1)));
                  Δt_frame = 1//10, Δt_base = 3//100, h_max = 1//7)
    init!(model, set(u = (in = 0.0,)))
    h = Hooks(model, Tuple{Float64,Int}[])
    foreach(k -> frame!(model, k, h), 1:2)
    report("P2b Δt_base 3/100 vs frame 1/10, h_max 1/7", h.rec)
end

# P3 no ticks due at t* (SD2-176)
let model = Model(Group((; c = Sawtooth(1.1), a = TickCounter());
                        sample_times = (; a = Absolute(7//100)));
                  Δt_frame = 1//10, Δt_base = 1//100)
    init!(model)
    h = Hooks(model, Tuple{Float64,Int}[])
    foreach(k -> frame!(model, k, h), 1:10)
    report("P3 boundaries frames 9-10 (t* near 0.909)", filter(r -> r[1] > 0.8, h.rec))
end

# P4 Dual executable set: which functions see a Dual (SD2-084, SD2-230)
const SEEN = Dict{Symbol,Vector{Any}}()
seen!(k, v) = push!(get!(SEEN, k, Any[]), v)
struct ProjRotor <: AbstractComponent end
x_init(::ProjRotor) = (r = SVector(1.0, 0.0),)
y_types(::ProjRotor) = (c = Float64,)
y_state(::ProjRotor, (; x)) = (seen!(:y_state, eltype(x.r)); (c = x.r[1],))
x_deriv(::ProjRotor, (; x)) = (seen!(:x_deriv, eltype(x.r)); (r = SVector(-x.r[2], x.r[1]),))
x_projection(::ProjRotor, x) = (seen!(:x_projection, eltype(x.r)); (r = x.r / norm(x.r),))
pr_guard(::ProjRotor, (; x)) = (seen!(:guard, eltype(x.r)); x.r[1] - 2.0)
pr_handler(::ProjRotor, (; x)) = (seen!(:handler, eltype(x.r)); (x = x,))
state_events(::ProjRotor) = (e = StateEvent(pr_guard, pr_handler),)
let b = build(single(ProjRotor()))
    empty!(SEEN)
    activation(b, ProbeDual)
    report("P4 functions probed at ProbeDual", Dict(k => unique(v) for (k, v) in SEEN))
end

# P5 exact type match at nominal (SD2-257)
struct F32Out <: AbstractComponent end
x_init(::F32Out) = (q = 0.0,)
y_types(::F32Out) = (y = Float64,)
y_state(::F32Out, (; x)) = (y = Float32(x.q),)
x_deriv(::F32Out, (; x)) = (q = 1.0,)
let r = try build(single(F32Out())); "built" catch e; e end
    report("P5 Float32 return at Float64 decl", r isa DiagnosticError ? (r.carried isa Vector ? map(typeof, r.carried) : typeof(r.carried)) : r)
end

# P6 Pinned{P} at the top of an entry yields P; nested is refused (SD2-089, SD2-130)
report("P6 retype_entry(ProbeDual, Pinned{Float64})", Redstone.retype_entry(ProbeDual, Redstone.Pinned{Float64}))
report("P6 retype_entry(ProbeDual, SVector{2,Float64})", Redstone.retype_entry(ProbeDual, SVector{2,Float64}))

# P7 DeclarationShadowed alone (SD2-284)
module Shadow
import Redstone: AbstractComponent
struct C <: AbstractComponent end
y_types(::C) = (y = Float64,)
y_direct(::C, _) = (y = 1.0,)
end
let r = try build(single(Shadow.C())); "built" catch e; e end
    report("P7 shadowed build", r isa DiagnosticError ? (r.carried isa Vector ? map(typeof, r.carried) : typeof(r.carried)) : r)
end

# P8 Absolute is the exact pair (SD2-001, SD2-140)
let a = Absolute(1//50, 1//500)
    report("P8 Absolute fields", (a.Δt, a.τ, typeof(a.Δt)))
end
end

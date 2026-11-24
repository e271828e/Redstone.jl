# CV10 probe: frame.jl, stepper.jl, executor.jl against their docs.
# Run from the worktree: JULIA_LOAD_PATH="@" julia --startup-file=no --project=test P
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
include(joinpath(W, "utils.jl"))

mutable struct ClockHooks{M} <: FrameHooks
    model::M
    clocks::Vector{Float64}
end
Redstone.frame_top!(::ClockHooks) = false
Redstone.settled!(h::ClockHooks) =
    (push!(h.clocks, Float64(ForwardDiff.value(h.model.exec.clock.t))); false)

kind(f) = try f(); :nothrow catch e
    e isa DiagnosticError ? (typeof(e).parameters..., e.carried) : e end

# P1 (probe:30): a claimed model is refused by frame!
sim = Simulation(feedback_model(); Δt_frame = 1//100)
c = kind(() -> frame!(sim.model, 1))
println("P1 claimed: ", c)

# P2 (probe:36): k past the last frame, and the status left consistent
m = Model(feedback_model(); Δt_frame = 1//100)
init!(m, set(u = (ref = 0.0,)))
d = kind(() -> frame!(m, typemax(Int)))
println("P2 range: ", d, " status=", m.status)

# P3 (probe:43): a throw inside a frame is StepError host :loop, boundary k-1, status :inconsistent
tm = Model(fed(Tripwire(0.15), "arm"); Δt_frame = 1//10)
init!(tm, set(u = (in = true,)))
frame!(tm, 1)
err = try frame!(tm, 2); nothing catch e e end
println("P3 ", typeof(err), " host=", err.host, " boundary=", err.boundary,
        " status=", tm.status)

# P4 (probe:50): the reason of a named-store successor with right names and wrong value types
r = try Redstone._store_successor!(Ref((a = 0.0,)), (a = 1,), "p", :s_update); nothing
    catch e e end
println("P4 ", r.carried.reason, " field=", r.carried.field, " obs=", r.carried.observed,
        " decl=", r.carried.declared)
r2 = try Redstone._store_successor!(Ref((a = 0.0,)), (b = 1.0,), "p", :s_update); nothing catch e e end
println("P4b ", r2.carried.reason)

# P5 (probe:59): allocation of a whole frame under each backend, after warmup
for alg in (RK4(), Heun(), BS3())
    mm = Model(feedback_model(); Δt_frame = 1//100, h_max = 1//400, h_min = 1//40000, algorithm = alg)
    init!(mm, set(u = (ref = 1.0,)))
    frames!(mm, 3)
    clock = mm.exec.clock
    k₀ = round(Int, (clock.t - clock.t₀) / Float64(mm.deployment.Δt_frame))
    a = @allocated frame!(mm, k₀ + 1)
    println("P5 ", typeof(alg), " frame alloc bytes = ", a)
end

# P6 (probe:70): Dual model takes the steps the Float64 model takes, BS3 and RK4
for alg in (RK4(), BS3())
    mf = Model(feedback_model(); Δt_frame = 1//10, h_max = 1//40, h_min = 1//4000, algorithm = alg)
    md = Model(feedback_model(), D8; Δt_frame = 1//10, h_max = 1//40, h_min = 1//4000, algorithm = alg)
    init!(mf, set(u = (ref = 1.0,)))
    init!(md, set(u = (ref = D8(1.0),)))
    hf, hd = ClockHooks(mf, Float64[]), ClockHooks(md, Float64[])
    for k in 1:5
        frame!(mf, k, hf); frame!(md, k, hd)
    end
    println("P6 ", typeof(alg), " same clocks: ", hf.clocks == hd.clocks, " n=", length(hf.clocks))
end

# P7 (probe:84): the discontinuity notice is raised by run_boundary!, not integrate_step!
let src = read(joinpath(dirname(W), "src", "model.jl"), String)
    a = findfirst("@inline function integrate_step!", src)
    b = findnext("# A proposal shaped into the length", src, first(a))
    body = src[first(a):first(b)]
    println("P7 integrate_step! body names discontinuity!: ", occursin("discontinuity!", body))
    println("P7 run_boundary! raises it: ", occursin("discontinuity!(model.exec.stepper)", src))
end

# P8 (probe:87): BS3 checkpoint pair and reset
st = Redstone.bind_stepper(BS3(), Float64, 2)
println("P8 bound: ", checkpoint_stepper(st), " ; after discontinuity: ",
        (discontinuity!(st); checkpoint_stepper(st)))
println("P8 RK4 pair: ", checkpoint_stepper(Redstone.bind_stepper(RK4(), Float64, 2)))

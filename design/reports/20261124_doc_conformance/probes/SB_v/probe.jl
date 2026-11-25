# SB_v: independent verifier probe for slice SB (Appendix B). Run from W.
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
include(joinpath(W, "test", "imports.jl"))
include(joinpath(W, "test", "fixtures.jl"))

show_err(e) = e isa DiagnosticError ?
    (c = e.carried; [ (nameof(typeof(d)), [f => getfield(d, f) for f in (:reason, :parameter, :argument, :call) if hasfield(typeof(d), f)]...) for d in (c isa AbstractVector ? c : [c])]) :
    (typeof(e), sprint(showerror, e)[1:min(end, 160)])
macro P(label, ex)
    quote
        local v = try
            $(esc(ex))
        catch err
            ("THROWS", show_err(err))
        end
        println("P ", $(esc(label)), " | line ", $(__source__.line), " => ", repr(v)[1:min(end, 500)])
        v
    end
end

@P "SB-001 names" names(Redstone)
@P "SB-047 Library" isdefined(Redstone, :Library) && Redstone.Library isa Module
@P "SB-019 tc default" Redstone.transparent_container(Plant())

@P "SB-028 Relative(2)" Relative(2)
@P "SB-028 Relative(Int8(3), Int8(1))" Relative(Int8(3), Int8(1))
@P "SB-028 Relative(2//1)" Relative(2//1)
@P "SB-028 Relative(1//2)" Relative(1//2)
@P "SB-028 Absolute(1//50)" Absolute(1//50)
@P "SB-028 Absolute(Int8(1)//Int8(50), 1//500)" Absolute(Int8(1)//Int8(50), 1//500)
@P "SB-029 Absolute(0.02)" Absolute(0.02)
@P "SB-029 Absolute(1//50, 0.001)" Absolute(1//50, 0.001)

b = build(bare_world())
@P "SB-074 Deployment params" (Deployment(b; Δt_frame = 1//10) isa Deployment, isempty(typeof(Deployment(b; Δt_frame = 1//10)).parameters))
@P "SB-083 Δt_frame Int8" Deployment(b; Δt_frame = Int8(1)//Int8(10)).Δt_frame
@P "SB-083 Δt_frame BigInt" Deployment(b; Δt_frame = big(1)//big(10)).Δt_frame
@P "SB-083 Δt_frame Int" Deployment(b; Δt_frame = 1).Δt_frame
@P "SB-092 h_max 3//70 vs frame 1//10" Deployment(b; Δt_frame = 1//10, h_max = 3//70).h_max
@P "SB-092 h_max with Δt_base 1//30" (d = Deployment(b; Δt_frame = 1//10, Δt_base = 1//30, h_max = 1//7); (d.Δt_base, d.h_max))
@P "SB-101 attempt_budget 0" Deployment(b; Δt_frame = 1//10, attempt_budget = 0)
@P "SB-101 attempt_budget 1.0" Deployment(b; Δt_frame = 1//10, attempt_budget = 1.0)
@P "SB-119 chunk_size 0" Model(b; Δt_frame = 1//10, chunk_size = 0)
@P "SB-119 chunk_size 2.0" Model(b; Δt_frame = 1//10, chunk_size = 2.0)

# SB-121: chunk_size moves no trajectory
function traj(cs)
    m = Model(bare_world(); Δt_frame = 1//10, chunk_size = cs)
    init!(m, set(u = (u = 0.5, p = 1.0)))
    for k in 1:30; frame!(m, k); end
    (state(m, "acc"), state(m, "plant"), state(m, "latch"), port(m, "neg", :y))
end
@P "SB-121 chunk 1 vs 16 vs 3" (traj(1) === traj(16), traj(1) == traj(3), traj(16))

m = Model(bare_world(); Δt_frame = 1//10)
@P "SB-129 init! sig" (init!(m, set(u = (u = 0.5, p = 1.0)); t0 = 0, hooks = NoHooks()); m.status)
@P "SB-147 NoHooks" (frame_top!(NoHooks()), settled!(NoHooks()))
@P "SB-156 port(model, named-contract plant)" port(m, "plant")
@P "SB-156 port(model, assembly root)" port(m, "")
@P "SB-156 port(model, bare acc)" port(m, "acc")
@P "SB-165 warnings(model)" typeof(warnings(m))
@P "SB-410 eltypes" (eltype(warnings(m)), eltype(warnings(b)), eltype(warnings(Deployment(b; Δt_frame = 1//10))))

# SB-264: duplicate leaves name both origins
@P "SB-264 duplicate" init!(Model(bare_world(); Δt_frame = 1//10),
    combine(set(u = (u = 0.5, p = 1.0)), set(u = (u = 0.7,))))
try
    init!(Model(bare_world(); Δt_frame = 1//10), combine(set(u = (u = 0.5, p = 1.0)), set(u = (u = 0.7,))))
catch e
    d = e.carried isa AbstractVector ? first(e.carried) : e.carried
    println("P SB-264 origins => ", repr(d.origins))
end

# SB-273: totality before any write (sim at :built stays built, model status unchanged)
sim0 = Simulation(bare_world(); Δt_frame = 1//10)
@P "SB-273 init! missing p" init!(sim0, set(u = (u = 0.5,)))
@P "SB-273 after refusal" (lifecycle(sim0), sim0.model.status)

# SB-282 / SB-392: keyword lists
kwnames(f, sig) = Base.kwarg_decl(only(methods(f, sig)))
@P "SB-282 overlay! kws" kwnames(overlay!, Tuple{Simulation, Any})
@P "SB-282 restore!(cp) kws" kwnames(restore!, Tuple{Simulation, Checkpoint})
@P "SB-282 replay! kws" kwnames(replay!, Tuple{Simulation, Redstone.Trace})
@P "SB-338 run! kws" kwnames(run!, Tuple{Simulation})
@P "SB-289 LM kws" (Base.kwarg_decl(first(methods(LevenbergMarquardt, Tuple{}))), LevenbergMarquardt(; maxiter = 5, λ₀ = 1.0))

# SB-311: restore!(sim, model_state) opens a fresh trajectory at the state's frame
ms_model = Model(bare_world(); Δt_frame = 1//10)
init!(ms_model, set(u = (u = 0.5, p = 1.0)))
for k in 1:7; frame!(ms_model, k); end
ms = checkpoint(ms_model)
sim1 = Simulation(bare_world(); Δt_frame = 1//10)
@P "SB-311 restore! model_state" (restore!(sim1, ms); s = latest(sim1); (s.frame, s.boundary, s.t, sim1.run.frame, sim1.run.boundary, length(logged(sim1))))
@P "SB-311 then step" (step!(sim1); s = latest(sim1); (s.frame, s.boundary, s.t))

# SB-302: restore!(sim, cp) legal where init! is (e.g. on a :built sim)
sim2 = Simulation(bare_world(); Δt_frame = 1//10)
init!(sim2, set(u = (u = 0.5, p = 1.0))); step!(sim2; frames = 3)
cp = checkpoint(sim2)
sim3 = Simulation(bare_world(); Δt_frame = 1//10)
@P "SB-302 restore! on built sim" (restore!(sim3, cp); lifecycle(sim3))

# SB-356: step! frames bit-identical to run!
simA = Simulation(bare_world(); Δt_frame = 1//10)
init!(simA, set(u = (u = 0.5, p = 1.0))); run!(simA; t_end = 2)
simB = Simulation(bare_world(); Δt_frame = 1//10)
init!(simB, set(u = (u = 0.5, p = 1.0)))
step!(simB; frames = 5); step!(simB; frames = 7); step!(simB; t_plus = 8//10)
@P "SB-356 step vs run" (latest(simA).t, latest(simB).t,
    state(simA, "acc") === state(simB, "acc"), state(simA, "plant") === state(simB, "plant"),
    state(simA, "latch") === state(simB, "latch"), modes(simA, "latch") === modes(simB, "latch"),
    [s.t for s in logged(simA)] == [s.t for s in logged(simB)],
    all(port(a, "acc", :y) === port(bb, "acc", :y) for (a, bb) in zip(logged(simA), logged(simB))))

# SB-374 termination
@P "SB-374 termination" (typeof(termination(simA)), termination(simB))
# SB-401 mode
@P "SB-401 mode" (mode(simA), (r = Simulation(bare_world(); Δt_frame = 1//10); replay!(r, trace(simA); to_boundary = 3); mode(r)))
# SB-383 series
@P "SB-383 series" (ts = series(simA, reads(a = get_output("acc", "y"), n = get_output("neg", "y"))); (length(ts.t), eltype(ts.a), eltype(ts.n), propertynames(ts)))
# SB-365 phase_bodies
@P "SB-365 phase_bodies" (phase_bodies(simA) === phase_bodies(simA.model), keys(phase_bodies(simA.model)))
# SB-156 contrast: a bare output reads with the name left out
mb = Model(bare_loop(); Δt_frame = 1//10)
@P "SB-156 bare flow, no name" (init!(mb); port(mb, "flow"))

# CV10 verifier probes. Run from the pinned worktree:
#   JULIA_LOAD_PATH="@" julia --startup-file=no --project=test <this file>
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const W = pwd()
include(joinpath(W, "test", "imports.jl"))
include(joinpath(W, "test", "fixtures.jl"))
include(joinpath(W, "test", "utils.jl"))
import Redstone: ExecutionCursor

p(tag, x...) = println("[", tag, "] ", x...)

# Reused from test_adaptive.jl and test_stepper.jl, copied so no test file loads.
mutable struct ClockHooks{M} <: FrameHooks
    model::M
    clocks::Vector{Float64}
end
Redstone.frame_top!(::ClockHooks) = false
Redstone.settled!(h::ClockHooks) =
    (push!(h.clocks, Float64(ForwardDiff.value(h.model.exec.clock.t))); false)
seam_rig() = Group((plant = Plant(), ctl = Gain(4.0), sum = Sum(), a = TickCounter());
                   local_wires = ("ctl/out" => "plant/u", "sum/e" => "ctl/e",
                                  "plant/y" => "sum/b"),
                   input_wires = "ref" => "sum/a",
                   sample_times = (; a = Absolute(3//32)))

# --- CV10-263: runtime s_update check, a named store, same names, wrong type --
struct LateSucc <: AbstractComponent end
Redstone.s_init(::LateSucc) = (n = 0.0,)
Redstone.y_types(::LateSucc) = (u = Float64,)
Redstone.y_state(::LateSucc, (; s)) = (u = s.n,)
Redstone.s_update(::LateSucc, (; s, t)) = (n = t < 0.05 ? s.n + 1.0 : 0,)
let sim = Simulation(single(LateSucc()); Δt_frame = 1//100)
    init!(sim)
    err = try run!(sim; t_end = 0.2); nothing catch e; e end
    c = err.cause
    p("263", "cause=", typeof(c), " reason=", c.reason, " field=", c.field,
      " observed=", c.observed, " declared=", c.declared,
      " observed_fields=", c.observed_fields, " declared_fields=", c.declared_fields)
    p("263", "message: ", Redstone.message(c))
end

# --- CV10-040 / CV10-036: refusals before the try leave the model as it was ---
let model = Model(seam_rig(); Δt_frame = 1//8, Δt_base = 1//32)
    init!(model, set(u = (ref = 0.7,)))
    before = (@atomic model.status)
    e = try frame!(model, typemax(Int)); nothing catch e; e end
    d = e.carried
    p("040", "range refusal: ", typeof(d), " reason=", d.reason, " status before=", before,
      " after=", (@atomic model.status))
    sim = Simulation(seam_rig(); Δt_frame = 1//8, Δt_base = 1//32)
    init!(sim, set(u = (ref = 0.7,)))
    e2 = try frame!(sim.model, 1); nothing catch e; e end
    d2 = e2.carried
    p("040", "claim refusal: ", typeof(d2), " reason=", d2.reason, " status after=", (@atomic sim.model.status))
end

# --- CV10-030: a Dual model freezes its discrete components ---
let model = Model(seam_rig(), D8; Δt_frame = 1//8, Δt_base = 1//32)
    init!(model, set(u = (ref = 0.7,)))
    s0 = state(model, "a")
    foreach(k -> frame!(model, k), 1:6)
    p("030", "Dual TickCounter s before=", s0, " after 6 frames=", state(model, "a"),
      " events=", length(model.exec.events.prior))
    mf = Model(seam_rig(); Δt_frame = 1//8, Δt_base = 1//32)
    init!(mf, set(u = (ref = 0.7,)))
    foreach(k -> frame!(mf, k), 1:6)
    p("030", "Float64 TickCounter after 6 frames=", state(mf, "a"))
end

# --- CV10-194: a Dual BS3 run takes the Float64 run's steps ---
let clocks = map((Float64, D8)) do T
        model = Model(seam_rig(), T; Δt_frame = 1//8, Δt_base = 1//32, h_min = 1//2^20,
                      algorithm = BS3(reltol = 1e-6, abstol = 1e-9))
        ref = T === Float64 ? 0.7 : D8(0.7, ForwardDiff.Partials(ntuple(i -> 1e3 * i, 8)))
        init!(model, set(u = (ref = ref,)))
        hooks = ClockHooks(model, Float64[])
        foreach(k -> frame!(model, k, hooks), 1:6)
        hooks.clocks
    end
    p("194", "boundaries=", length(clocks[1]), " Float64 clocks == Dual clocks: ", clocks[1] == clocks[2])
end

# --- CV10-012: under a proposal an interior step integrates by its shaped length,
# and its end clock is t + h, whose float distance from t can differ from h ---
mutable struct LenStepper{T} <: AbstractStepper
    inner::BS3Stepper{T}
    log::Vector{Tuple{Float64,Float64,Bool}}   # (t at start, h, accepted)
end
struct LenAlg <: AbstractAlgorithm
    inner::BS3
end
Redstone.bind_stepper(a::LenAlg, ::Type{T}, n::Int) where {T} =
    LenStepper{T}(bind_stepper(a.inner, T, n), Tuple{Float64,Float64,Bool}[])
Redstone.proposes(::LenAlg) = true
Redstone.propose(s::LenStepper) = propose(s.inner)
Redstone.checkpoint_stepper(s::LenStepper) = checkpoint_stepper(s.inner)
Redstone.restore_stepper!(s::LenStepper, c) = restore_stepper!(s.inner, c)
Redstone.reset_stepper!(s::LenStepper) = reset_stepper!(s.inner)
Redstone.discontinuity!(s::LenStepper) = discontinuity!(s.inner)
Redstone.startpoint(s::LenStepper) = startpoint(s.inner)
function Redstone.attempt!(s::LenStepper, model::Model, h)
    t = Float64(model.exec.clock.t)
    ok = attempt!(s.inner, model, h)
    push!(s.log, (t, Float64(h), ok))
    ok
end
let model = Model(seam_rig(); Δt_frame = 1//8, Δt_base = 1//32, h_min = 1//2^20,
                  algorithm = LenAlg(BS3(reltol = 1e-6, abstol = 1e-9)))
    init!(model, set(u = (ref = 0.7,)))
    foreach(k -> frame!(model, k), 1:6)
    acc = [a for a in model.exec.stepper.log if a[3]]
    mismatched = 0
    for i in 1:length(acc)-1
        (t, h, _) = acc[i]
        t_next = acc[i + 1][1]
        (t_next - t != h) && (mismatched += 1)
    end
    p("012", "accepted steps=", length(acc), " steps whose float clock distance != integrated length: ",
      mismatched)
end

# --- CV10-174: a restore raises no notice (memory survives) ---
let model = Model(seam_rig(); Δt_frame = 1//8, Δt_base = 1//32, h_min = 1//2^20,
                  algorithm = BS3(reltol = 1e-6, abstol = 1e-9))
    init!(model, set(u = (ref = 0.7,)))
    foreach(k -> frame!(model, k), 1:1)   # t = 1/8, no tick due there
    cp = checkpoint(model)
    foreach(k -> frame!(model, k), 2:5)
    restore!(model, cp)
    p("174", "checkpoint stepper=", cp.stepper, " after restore (proposal, memory)=",
      (model.exec.stepper.proposal, model.exec.stepper.memory))
end

# --- CV10-156: propose has no default ---
p("156", "propose methods: ", length(methods(Redstone.propose)),
  " hasmethod(propose, (AbstractStepper,))=", hasmethod(Redstone.propose, Tuple{AbstractStepper}),
  " generic discontinuity! on AbstractStepper=", hasmethod(Redstone.discontinuity!, Tuple{AbstractStepper}))

# --- CV10-088 / CV10-097: the budget counts across the frame's steps and degrades ---
mutable struct CountHooks <: FrameHooks
    per_frame::Vector{Int}
end
Redstone.frame_top!(h::CountHooks) = (push!(h.per_frame, 0); false)
Redstone.settled!(h::CountHooks) = (h.per_frame[end] += 1; false)
let model = Model(single(Relaxer(10.0, 0.5, 0.05)); Δt_frame = 1//10, h_max = 1//40,
                  localization_budget = 3)
    init!(model)
    hooks = CountHooks(Int[])
    threw = try foreach(k -> frame!(model, k, hooks), 1:4); false catch; true end
    p("088", "threw=", threw, " settled boundaries per frame (4 steps + t*)=", hooks.per_frame,
      " fires=", modes(model, "c"))
end

# --- CV10-221: the cursor's index is read and stored per RHS evaluation ---
let model = Model(seam_rig(); Δt_frame = 1//8, Δt_base = 1//32)
    init!(model, set(u = (ref = 0.7,)))
    c = model.exec.cursor
    Redstone._phase!(c, :integrate)
    Redstone.evaluate!(model.exec); Redstone.evaluate!(model.exec)
    p("221", "index after two evaluate! calls=", c.index)
end

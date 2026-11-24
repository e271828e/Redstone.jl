# K10a probe: frame_walkthrough.md claims. Run with the worktree's test project.
using Redstone, StaticArrays, ForwardDiff
import Redstone: AbstractComponent, AbstractAlgorithm, AbstractStepper, BS3, BS3Stepper, RK4,
    attempt!, bind_stepper, checkpoint_stepper, discontinuity!, propose, reset_stepper!,
    restore_stepper!, startpoint, proposes, Absolute, Group,
    s_init, s_update, u_types, y_types, y_state, y_direct, x_init, x_deriv, set, stage!,
    init!, step!, logged, Simulation, sample_times

using Redstone.Library: FirstOrderLag, Comparator
struct Plant <: AbstractComponent
    ω::Float64; ζ::Float64
end
x_init(c::Plant) = (q = SVector(0.0, 0.0),)
u_types(::Plant) = (u = Float64,)
y_types(::Plant) = (y = Float64,)
y_state(::Plant, (; x)) = (y = x.q[1],)
x_deriv(c::Plant, (; x, u)) = (q = SVector(x.q[2], -c.ω^2 * x.q[1] - 2c.ζ * c.ω * x.q[2] + u.u),)

struct Ctl <: AbstractComponent
    k::Float64
end
s_init(::Ctl) = (n = 0,)
u_types(::Ctl) = (r = Float64, y = Float64)
y_types(::Ctl) = (out = Float64,)
y_direct(c::Ctl, (; u)) = (out = c.k * (u.r - u.y),)
s_update(::Ctl, (; s)) = (n = s.n + 1,)

struct Watched <: AbstractAlgorithm
    inner::BS3
end
struct WatchedStepper{T} <: AbstractStepper
    inner::BS3Stepper{T}
    attempts::Vector{NTuple{6,Any}}
    notices::Vector{Int}
end
bind_stepper(a::Watched, ::Type{T}, n::Int) where {T} =
    WatchedStepper{T}(bind_stepper(a.inner, T, n), NTuple{6,Any}[], Int[])
proposes(::Watched) = true
propose(s::WatchedStepper) = propose(s.inner)
checkpoint_stepper(s::WatchedStepper) = checkpoint_stepper(s.inner)
restore_stepper!(s::WatchedStepper, c) = restore_stepper!(s.inner, c)
reset_stepper!(s::WatchedStepper) = reset_stepper!(s.inner)
discontinuity!(s::WatchedStepper) = (push!(s.notices, length(s.attempts)); discontinuity!(s.inner))
startpoint(s::WatchedStepper) = startpoint(s.inner)
function attempt!(s::WatchedStepper, model, h)
    inner, t = s.inner, model.exec.clock.t
    before = inner.memory
    ok = attempt!(inner, model, h)
    push!(s.attempts, (t, h, ok, before, inner.memory, inner.proposal))
    ok
end

lagrig() = Group((; lag = FirstOrderLag(τ = 0.05, x0 = 0.5), plant = Plant(2.0, 0.1),
                    ctl = Ctl(1.0), cmp = Comparator(; threshold = 0.75, localized = true));
                 local_wires = ("lag/y" => "ctl/r", "plant/y" => "ctl/y", "ctl/out" => "plant/u",
                                "lag/y" => "cmp/u"),
                 input_wires = "ref" => "lag/u",
                 sample_times = (; ctl = Absolute(1//20)))

function section5(algorithm)
    sim = Simulation(lagrig(); Δt_frame = 1//10, Δt_base = 1//20, h_min = 1//10_000, algorithm)
    init!(sim, set(u = (ref = 0.5,)))
    step!(sim; frames = 6)
    st = sim.model.exec.stepper
    pre_proposal = st isa WatchedStepper ? st.inner.proposal : nothing
    n0 = st isa WatchedStepper ? length(st.attempts) : 0
    nlog0 = length(logged(sim))
    stage!(sim, "ref" => 1.0)
    step!(sim; frames = 1)
    (sim, pre_proposal, n0, nlog0)
end

println("== section 5, BS3")
(sim, pp, n0, nlog0) = section5(Watched(BS3(reltol = 1e-4, abstol = 1e-7)))
st = sim.model.exec.stepper
println("probe:proposal before frame 7 = ", pp)
println("probe:notices (attempt counts at notice) after frame 6 ", st.notices)
att = st.attempts[(n0 + 1):end]
println("probe:attempts in frame 7: ", length(att), " rejected: ", count(a -> !a[3], att))
for a in att
    println("  t=", round(Float64(a[1]), digits = 6), " h=", round(Float64(a[2]), digits = 6),
            " ok=", a[3], " mem ", round(a[4], digits = 4), "->", round(a[5], digits = 4),
            " prop=", round(a[6], digits = 6))
end
snaps = logged(sim)[(nlog0 + 1):end]
println("probe:snapshots in frame 7: ", length(snaps), " ", [round(Float64(s.t), digits = 6) for s in snaps])

println("== section 5, RK4")
(sim4, _, _, nl4) = section5(RK4())
s4 = logged(sim4)[(nl4 + 1):end]
println("probe:RK4 snapshots in frame 7: ", length(s4), " ", [round(Float64(s.t), digits = 6) for s in s4])

println("== scores: error of h=0.025 from t=0.6 (first attempt)")

println("== sections 1-3, running example")
import Redstone: FrameHooks, frame_top!, settled!, Model, frame!, state
mutable struct Rec <: FrameHooks
    model::Any
    log::Vector{Any}
end
frame_top!(::Rec) = false
function settled!(h::Rec)
    ex = h.model.exec
    push!(h.log, (Float64(ex.clock.t), ex.cursor.phase, copy(ex.cursor.phase === :ticks ? [1] : [0])))
    false
end
ex1() = Group((; lag = FirstOrderLag(τ = 0.075 / log(2), x0 = 0.0),
                 ctl = Ctl(1.0), cmp = Comparator(; threshold = 0.5, localized = true));
              local_wires = ("lag/y" => "ctl/r", "lag/y" => "cmp/u", "lag/y" => "ctl/y"),
              input_wires = "ref" => "lag/u", sample_times = (; ctl = Absolute(1//25)))
model = Model(ex1(); Δt_frame = 1//100, Δt_base = 1//25)
init!(model, set(u = (ref = 1.0,)))
println("probe:has_localized=", model.exec.has_localized, " stepper=", typeof(model.exec.stepper))
for k in 1:8
    rec = Rec(model, Any[])
    frame!(model, k, rec)
    k >= 6 && println("probe:frame ", k, " settled: ", [(round(a, digits = 6), b) for (a, b, _) in rec.log],
                      " ctl n=", state(model, "ctl"))
end

println("== digits")
println("probe:RK4 t* = ", Float64(s4[1].t), "  BS3 t* = ", Float64(snaps[5].t), "  exact = ", 0.6 + 0.05 * log(2))
println("probe:julia ", VERSION)

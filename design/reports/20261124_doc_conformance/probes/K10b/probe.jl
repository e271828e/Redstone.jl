# K10b probe: limited integrator variants, localization validation.
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
module PK
using Test, StaticArrays, LinearAlgebra, ForwardDiff
using Redstone
const W = Main.W
include(joinpath(W, "test/imports.jl"))
include(joinpath(W, "test/fixtures.jl"))
include(joinpath(W, "test/utils.jl"))
import Redstone: StateEvent, Library

# --- counters ---
const TRIALS = Ref(0)
const DCALLS = Ref(0)
@eval Redstone begin
    function _trial!(model::Model, θ::Float64, t_seg, h′)
        exec = model.exec
        dense!(exec.stepper, exec.xbuf, exec.xnext, exec.ẋnext, θ, h′)
        exec.clock.t = t_seg + θ * h′
        exec.bodies.sweep_1(); exec.bodies.sweep_2()
        _guards!(exec.events, exec.store, exec.xbuf)
        Main.PK.TRIALS[] += 1
        nothing
    end
end

# --- a configurable limited integrator ---
struct Lim{H, Lv, L} <: AbstractComponent
    x0::Float64; lower::Float64; upper::Float64
end
Lim{H, Lv, L}(; lower, upper, x0 = 0.0) where {H, Lv, L} = Lim{H, Lv, L}(x0, lower, upper)
x_init(c::Lim) = c.x0
m_init(::Lim) = Int8(0)
u_types(::Lim) = Float64
y_types(::Lim) = (out = Float64,)
y_state(::Lim, (; x)) = (out = x,)
x_deriv(::Lim, (; u, m)) = (DCALLS[] += 1; m == 0 ? u : 0.0 * u)
fnz(a, b) = a != 0 ? a : b
function state_events(::Lim{H, Lv}) where {H, Lv}
    hu = H === :plain ? StateEvent((c, (; x)) -> x - c.upper, (c, _) -> (x = c.upper, m = Int8(1))) :
         H === :u ? StateEvent((c, (; x, u)) -> fnz(x - c.upper, u), (c, _) -> (x = c.upper, m = Int8(1))) :
         StateEvent((c, (; x, m)) -> m == 0 ? x - c.upper : -1.0, (c, _) -> (x = c.upper, m = Int8(1)))
    hl = H === :plain ? StateEvent((c, (; x)) -> c.lower - x, (c, _) -> (x = c.lower, m = Int8(-1))) :
         H === :u ? StateEvent((c, (; x, u)) -> fnz(c.lower - x, -u), (c, _) -> (x = c.lower, m = Int8(-1))) :
         StateEvent((c, (; x, m)) -> m == 0 ? c.lower - x : -1.0, (c, _) -> (x = c.lower, m = Int8(-1)))
    lu = Lv === :mode ? StateEvent((c, (; m, u)) -> m == 1 ? -u : -1.0, (c, _) -> (m = Int8(0),)) :
         Lv === :strict ? StateEvent((c, (; m, u)) -> m == 1 && u < 0 ? -u : -1.0, (c, _) -> (m = Int8(0),)) :
         Lv === :pm1 ? StateEvent((c, (; m, u)) -> m == 1 && u < 0 ? 1.0 : -1.0, (c, _) -> (m = Int8(0),)) :
         StateEvent((c, (; m, u)) -> m == 1 && u < 0, (c, _) -> (m = Int8(0),))
    ll = Lv === :mode ? StateEvent((c, (; m, u)) -> m == -1 ? u : -1.0, (c, _) -> (m = Int8(0),)) :
         Lv === :strict ? StateEvent((c, (; m, u)) -> m == -1 && u > 0 ? u : -1.0, (c, _) -> (m = Int8(0),)) :
         Lv === :pm1 ? StateEvent((c, (; m, u)) -> m == -1 && u > 0 ? 1.0 : -1.0, (c, _) -> (m = Int8(0),)) :
         StateEvent((c, (; m, u)) -> m == -1 && u > 0, (c, _) -> (m = Int8(0),))
    (hit_upper = hu, hit_lower = hl, leave_upper = lu, leave_lower = ll)
end

# computed clamp: no mode; optional release event
struct CC{R} <: AbstractComponent
    lower::Float64; upper::Float64
end
x_init(::CC) = 0.0
m_init(::CC) = Int8(0)
u_types(::CC) = Float64
y_types(::CC) = (out = Float64,)
y_state(::CC, (; x)) = (out = x,)
x_deriv(c::CC, (; x, u)) = (x >= c.upper && u > 0) || (x <= c.lower && u < 0) ? zero(u) : u
state_events(::CC{true}) = (hit_upper = StateEvent((c, (; x)) -> x - c.upper, (c, _) -> (x = c.upper,)),
                            release = StateEvent((c, (; u)) -> -u, (c, _) -> (m = Int8(0),)))
state_events(::CC{false}) = (hit_upper = StateEvent((c, (; x)) -> x - c.upper, (c, _) -> (x = c.upper,)),)

zin(level, lower, upper, c) =
    Group((; release = Step(t_step = 1.05, before = level, after = 0.0),
             push = Step(t_step = 2.05, before = 0.0, after = level),
             input = SumJunction{Float64, 2}(), li = c);
          local_wires = ("release/y" => "input/in1", "push/y" => "input/in2", "input/y" => "li/u"))

function run_to(model, t; Δ = 1//10, kw...)
    sim = Simulation(model; Δt_frame = Δ, kw...)
    init!(sim, set())
    step!(sim; t_plus = t)
    sim
end
nfire(sim) = writer_status(latest(sim), "loop").totals.firing

println("== A. defect: first form, release to exact zero (doc §2: 1.45 free; mirror -1.45)")
for loc in (:mode,)
    s = run_to(zin(1.0, -1.0, 0.5, Lim{:plain, :mode, true}(lower = -1.0, upper = 0.5)), 3.0)
    println("probe:A1 upper x=", state(s, "li"), " m=", modes(s, "li"))
    s = run_to(zin(-1.0, -0.5, 1.0, Lim{:plain, :mode, true}(lower = -0.5, upper = 1.0)), 3.0)
    println("probe:A2 lower x=", state(s, "li"), " m=", modes(s, "li"))
    s = run_to(zin(1.0, -1.0, 0.5, Lim{:plain, :bool, false}(lower = -1.0, upper = 0.5)), 3.0)
    println("probe:A3 bool-form x=", state(s, "li"), " m=", modes(s, "li"))
end
println("-- strict gate and library")
for c in (Lim{:plain, :strict, true}(lower = -1.0, upper = 0.5), Lim{:plain, :pm1, true}(lower = -1.0, upper = 0.5),
          Lim{:plain, :bool, false}(lower = -1.0, upper = 0.5),
          LimitedIntegrator(lower = -1.0, upper = 0.5), LimitedIntegrator(lower = -1.0, upper = 0.5, localized = false))
    s = run_to(zin(1.0, -1.0, 0.5, c), 3.0)
    println("probe:A4 ", typeof(c).name.name, " ", typeof(c).parameters[2:end], " x=", state(s, "li"), " m=", modes(s, "li"))
end
println("-- boundary zero: x0 on limit, zero input then outward step (doc: frees there, overshoots)")
bz(c) = Group((; k = Step(t_step = 1.0, before = 0.0, after = 1.0), li = c); local_wires = ("k/y" => "li/u",))
for c in (Lim{:plain, :mode, true}(lower = -1.0, upper = 0.5, x0 = 0.5), LimitedIntegrator(lower = -1.0, upper = 0.5, x0 = 0.5))
    s = Simulation(bz(c); Δt_frame = 1//10); init!(s, set())
    m0 = modes(s, "li"); step!(s; t_plus = 3.0)
    println("probe:B ", typeof(c).name.name, " m@0=", m0, " x@3=", state(s, "li"), " m=", modes(s, "li"))
end

println("== C. gated hit guards chatter (doc §1)")
for Lv in (:mode, :strict), loc in (true, false)
    Lv2 = loc ? Lv : :bool
    c = Lim{:gated, Lv2, loc}(lower = -1.0, upper = 0.5)
    s = run_to(zin(1.0, -1.0, 0.5, c), 3.0)
    println("probe:C release-mid-run ", Lv2, " loc=", loc, " x=", state(s, "li"), " m=", modes(s, "li"), " firingwarn=", nfire(s))
    g = Group((; k = Constant(0.0), li = Lim{:gated, Lv2, loc}(lower = -1.0, upper = 0.5, x0 = 0.5)); local_wires = ("k/y" => "li/u",))
    s = run_to(g, 0.5)
    println("probe:C release-at-zero ", Lv2, " loc=", loc, " x=", state(s, "li"), " m=", modes(s, "li"), " firingwarn=", nfire(s))
end

println("== D. trial counts, cos(t) into [-0.5,0.5] over 20 s")
cosm(c) = Group((; src = Rotor(), li = c); local_wires = ("src/c" => "li/u",))
function count_run(c; Δ = 1//10, T = 20.0)
    TRIALS[] = 0; DCALLS[] = 0
    sim = Simulation(cosm(c); Δt_frame = Δ); init!(sim, set())
    prev = modes(sim, "li"); hits = 0; leaves = 0
    for k in 1:round(Int, T / Float64(Δ))
        step!(sim; t_plus = Float64(Δ))
        m = modes(sim, "li")
        if m != prev
            (prev == 0) ? (hits += 1) : (leaves += 1)
            prev = m
        end
    end
    (hits = hits, leaves = leaves, trials = TRIALS[], dcalls = DCALLS[], x = state(sim, "li"))
end
for (name, c) in (("mode-gate(before)", Lim{:plain, :mode, true}(lower = -0.5, upper = 0.5)),
                  ("strict", Lim{:plain, :strict, true}(lower = -0.5, upper = 0.5)),
                  ("pm1", Lim{:plain, :pm1, true}(lower = -0.5, upper = 0.5)),
                  ("bool", Lim{:plain, :bool, false}(lower = -0.5, upper = 0.5)),
                  ("lib localized", LimitedIntegrator(lower = -0.5, upper = 0.5)),
                  ("lib nonloc", LimitedIntegrator(lower = -0.5, upper = 0.5, localized = false)),
                  ("Lim hit-u strict", Lim{:u, :strict, true}(lower = -0.5, upper = 0.5)),
                  ("Lim hit-u bool", Lim{:u, :bool, false}(lower = -0.5, upper = 0.5)))
    for Δ in (1//10, 1//100)
        println("probe:D ", name, " Δ=", Δ, " ", count_run(c; Δ = Δ))
    end
end

println("== E. single departure trial counts: ramp 1.05 - t, upper 0.4")
ramp(c) = Group((; k = Constant(-1.0), ramp = Integrator(x0 = 1.05), li = c); local_wires = ("k/y" => "ramp/u", "ramp/y" => "li/u"))
for (name, c) in (("mode", Lim{:plain, :mode, true}(lower = -2.0, upper = 0.4)),
                  ("strict", Lim{:plain, :strict, true}(lower = -2.0, upper = 0.4)),
                  ("pm1", Lim{:plain, :pm1, true}(lower = -2.0, upper = 0.4)),
                  ("lib", LimitedIntegrator(lower = -2.0, upper = 0.4)),
                  ("CC release", CC{true}(-2.0, 0.4)), ("CC none", CC{false}(-2.0, 0.4)))
    TRIALS[] = 0
    sim = Simulation(ramp(c); Δt_frame = 1//10); init!(sim, set())
    step!(sim; t_plus = 0.95); t1 = TRIALS[]
    step!(sim; t_plus = 0.2); t2 = TRIALS[]
    println("probe:E ", name, " trials before 0.95: ", t1, " during departure frame: ", t2 - t1, " x@1.15=", state(sim, "li"))
end

println("== F. non-localized offset a h^2 (1-θ)^2 / 2 ; ramp crossing 1.05, h=0.1 -> θ=0.5, a=1")
for (name, c) in (("lib nonloc", LimitedIntegrator(lower = -2.0, upper = 0.4, localized = false)),
                  ("lib loc", LimitedIntegrator(lower = -2.0, upper = 0.4)))
    sim = Simulation(ramp(c); Δt_frame = 1//10); init!(sim, set())
    step!(sim; t_plus = 2.0)
    exact = 0.4 - (2.0 - 1.05)^2 / 2
    println("probe:F ", name, " x@2=", state(sim, "li"), " exact=", exact, " err=", state(sim, "li") - exact, " bound a h²(1-θ)²/2=", 0.1^2 * 0.25 / 2)
end
println("-- hand RK4 on computed clamp: x1-U vs -a h² θ(1-3θ)/6")
function rk4cc(θ; a = 1.0, h = 0.1)
    U = 0.0; tc = θ * h
    u(t) = -a * (t - tc)
    f(x, t) = (x >= U && u(t) > 0) ? 0.0 : u(t)
    x = U; t = 0.0
    k1 = f(x, t); k2 = f(x + h/2*k1, t + h/2); k3 = f(x + h/2*k2, t + h/2); k4 = f(x + h*k3, t + h)
    x1 = x + h/6*(k1 + 2k2 + 2k3 + k4)
    exact = U - a*(1-θ)^2*h^2/2
    (x1 - exact, -a*h^2*θ*(1-3θ)/6)
end
for θ in (0.1, 0.25, 0.4, 0.49, 0.6, 0.9)
    println("probe:F2 θ=", θ, " ", rk4cc(θ))
end
println("-- floatmin on Dual")
println("probe:G floatmin(Dual): ", try floatmin(ForwardDiff.Dual(1.0, 1.0)) catch e; "ERR " * first(sprint(showerror, e), 100) end)
println("probe:G -0.0>=0 ", -0.0 >= 0, " ; -u for u=0.0: ", -0.0)

println("== H. located leave instants vs true zeros (Δ=1/100), localization_tol default")
mutable struct Rec{M} <: FrameHooks
    model::M; b::Vector{Float64}
end
Redstone.frame_top!(h::Rec) = false
Redstone.settled!(h::Rec) = (push!(h.b, h.model.exec.clock.t); false)
let
    dep = Deployment(build(cosm(LimitedIntegrator(lower = -0.5, upper = 0.5))); Δt_frame = 1//100)
    println("probe:H tol=", dep.localization_tol, " Δt=", dep.Δt_frame)
    model = Model(dep); init!(model); h = Rec(model, Float64[])
    for k in 1:700; frame!(model, k, h); end
    tstar = filter(t -> abs(t / 0.01 - round(t / 0.01)) > 1e-6, h.b)
    println("probe:H t* boundaries: ", tstar)
    zs = [π/2 + k*π for k in 0:2]
    println("probe:H true zeros ", zs)
    println("probe:H diffs vs nearest zero: ", [minimum(abs.(t .- zs)) for t in tstar])
end

println("== I. §8 dip: u=(t-0.45)(t-0.52), h=0.5, upper=0.02, x past limit at t=2 (non-localized)")
dip(c) = Group((; k = Constant(2.0), r1 = Integrator(x0 = -0.97), r2 = Integrator(x0 = 0.234), li = c);
               local_wires = ("k/y" => "r1/u", "r1/y" => "r2/u", "r2/y" => "li/u"))
for (name, c) in (("lib nonloc", LimitedIntegrator(lower = -5.0, upper = 0.02, localized = false)),
                  ("lib loc", LimitedIntegrator(lower = -5.0, upper = 0.02)),
                  ("Lim plain bool", Lim{:plain, :bool, false}(lower = -5.0, upper = 0.02)),
                  ("Lim plain strict", Lim{:plain, :strict, true}(lower = -5.0, upper = 0.02)))
    sim = Simulation(dip(c); Δt_frame = 1//2); init!(sim, set()); step!(sim; t_plus = 2.0)
    println("probe:I ", name, " x@2=", state(sim, "li"), " past limit by ", state(sim, "li") - 0.02, " m=", modes(sim, "li"))
end
println("-- cos 20s derivative calls, lib localized/nonlocalized vs Lim hit-plain")
println("-- hit guards read u; slow ramp 1e-10, double integrator re-fires")
slow(c) = Group((; k = Constant(-1e-10), ramp = Integrator(x0 = 1e-10), li = c); local_wires = ("k/y" => "ramp/u", "ramp/y" => "li/u"))
let
    sim = Simulation(slow(LimitedDoubleIntegrator(lower = -5.0, upper = 1.0, q0 = 1.0, v0 = 0.0)); Δt_frame = 1//1000)
    init!(sim, set()); step!(sim; t_plus = 1.0)
    println("probe:J LDI q=", state(sim, "li"), " fire warn=", nfire(sim))
end
println("== L. gated hit guard chatter with a ramp input and strict leave")
for loc in (true, false)
    Lv = loc ? :strict : :bool
    c = Lim{:gated, Lv, loc}(lower = -2.0, upper = 0.4)
    sim = Simulation(ramp(c); Δt_frame = 1//10); init!(sim, set()); step!(sim; t_plus = 3.0)
    println("probe:L ramp-release loc=", loc, " x=", state(sim, "li"), " m=", modes(sim, "li"), " firingwarn=", nfire(sim))
    g = Group((; k = Constant(-1.0), li = Lim{:gated, Lv, loc}(lower = -2.0, upper = 0.4, x0 = 0.4)); local_wires = ("k/y" => "li/u",))
    sim = Simulation(g; Δt_frame = 1//10); init!(sim, set()); step!(sim; t_plus = 0.5)
    println("probe:L zero-release loc=", loc, " x=", state(sim, "li"), " m=", modes(sim, "li"), " firingwarn=", nfire(sim))
end
println("== M. computed clamp trials under cos")
for (name, c) in (("CC release", CC{true}(-0.5, 0.5)), ("CC none", CC{false}(-0.5, 0.5)))
    TRIALS[] = 0
    sim = Simulation(cosm(c); Δt_frame = 1//10); init!(sim, set()); step!(sim; t_plus = 20.0)
    println("probe:M ", name, " trials=", TRIALS[], " x=", state(sim, "li"))
end
println("== N. double integrator, hit guard reading u at rest only vs library, slow ramp")
const HITS = Ref(0)
struct DLim{H, LOC} <: AbstractComponent end
x_init(::DLim) = (q = 1.0, v = 0.0)
m_init(::DLim) = Int8(0)
u_types(::DLim) = Float64
y_types(::DLim) = (out = Float64,)
y_state(::DLim, (; x)) = (out = x.q,)
x_deriv(::DLim, (; x, u, m)) = (q = m == 0 ? x.v : 0.0, v = m == 0 ? u : 0.0)
state_events(::DLim{H, LOC}) where {H, LOC} =
    (hit_upper = StateEvent(H ? ((c, (; x, u)) -> fnz(fnz(x.q - 1.0, x.v), u)) : ((c, (; x, u)) -> fnz(x.q - 1.0, u)),
                            (c, _) -> (HITS[] += 1; (x = (q = 1.0, v = 0.0), m = Int8(1)))),
     leave_upper = StateEvent(LOC ? ((c, (; m, u)) -> m == 1 && u < 0 ? -u : -1.0) : ((c, (; m, u)) -> m == 1 && u < 0), (c, _) -> (m = Int8(0),)))
for (H, LOC) in ((false, true), (true, true), (false, false))
    HITS[] = 0
    sim = Simulation(slow(DLim{H, LOC}()); Δt_frame = 1//1000); init!(sim, set()); step!(sim; t_plus = 2.0)
    println("probe:N reads v first=", H, " loc=", LOC, " hit firings=", HITS[], " q=", state(sim, "li"))
end

println("== K. validation: events compile out at Dual, first_nonzero")
println("probe:K first_nonzero ", Library.first_nonzero(0.0, 0.0, -1.0), Library.first_nonzero(1.0, 2.0))
end

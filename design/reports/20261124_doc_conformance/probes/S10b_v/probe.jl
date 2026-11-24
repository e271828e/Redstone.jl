# S10b verifier probes (§10.4). Run from W with --project=test.
using Test, StaticArrays, LinearAlgebra, ForwardDiff
using Redstone
include(joinpath(pwd(), "test", "imports.jl"))
import Redstone: STOP_REQUESTED, NO_STOP
writer_status(snapshot, who::String) = only(w for w in snapshot.status.writers if w.who == who)

const CUR = Ref{Any}(nothing)
const TRIALS = Dict{Symbol,Vector{Int}}()
note_trial(tag) = (c = CUR[]; c !== nothing && c.phase === :trial &&
                   push!(get!(TRIALS, tag, Int[]), c.index); nothing)
trials(tag) = (v = get(TRIALS, tag, Int[]); (localizations = count(==(1), v), trials = length(v)))

# --- nonlinear crossing: a = cos t, guard 0.3 - a -------------------------------
struct Osc <: AbstractComponent; level::Float64; end
x_init(::Osc) = (a = 1.0, b = 0.0)
m_init(::Osc) = (count = 0, t_fired = -1.0)
y_types(::Osc) = (a = Float64,)
y_state(::Osc, (; x)) = (a = x.a,)
x_deriv(::Osc, (; x)) = (a = x.b, b = -x.a)
osc_guard(c::Osc, (; x)) = (note_trial(:osc); c.level - x.a)
osc_handler(::Osc, (; m, t)) = (m = (count = m.count + 1, t_fired = t),)
state_events(::Osc) = (cross = StateEvent(osc_guard, osc_handler),)

# --- linear crossing: q = t, guard q - 0.315 -----------------------------------
struct Lin <: AbstractComponent end
x_init(::Lin) = (q = 0.0,)
m_init(::Lin) = (count = 0, t_fired = -1.0)
y_types(::Lin) = (q = Float64,)
y_state(::Lin, (; x)) = (q = x.q,)
x_deriv(::Lin, _) = (q = 1.0,)
lin_guard(::Lin, (; x)) = (note_trial(:lin); x.q - 0.315)
lin_handler(::Lin, (; m, t)) = (m = (count = m.count + 1, t_fired = t),)
state_events(::Lin) = (cross = StateEvent(lin_guard, lin_handler),)

# --- a copy of LimitedIntegrator's upper side, with the hit guard as a variant ---
fnz(a, b) = a != 0 ? a : b
struct MyLim <: AbstractComponent; upper::Float64; hit::Symbol; end
x_init(::MyLim) = (q = 0.0,)
m_init(::MyLim) = (sat = Int8(0), leaves = 0, hits = 0)
u_types(::MyLim) = (in = Float64,)
y_types(::MyLim) = (out = Float64,)
y_state(::MyLim, (; x)) = (out = x.q,)
x_deriv(::MyLim, (; u, m)) = (q = m.sat == 0 ? u.in : 0.0,)
function mylim_hit(c::MyLim, (; x, u, m))
    c.hit === :shipped    && return fnz(x.q - c.upper, u.in)
    c.hit === :gated_bare && return m.sat == 0 ? x.q - c.upper : -1.0
    c.hit === :gated_fn   && return m.sat == 0 ? fnz(x.q - c.upper, u.in) : -1.0
    error("variant")
end
mylim_leave(::MyLim, (; m, u)) = (note_trial(:leave); m.sat == 1 && u.in < 0 ? -u.in : -1.0)
mylim_hit_h(c::MyLim, (; m)) = (x = (q = c.upper,), m = (sat = Int8(1), leaves = m.leaves, hits = m.hits + 1))
mylim_leave_h(::MyLim, (; m)) = (m = (sat = Int8(0), leaves = m.leaves + 1, hits = m.hits),)
state_events(::MyLim) = (hit = StateEvent(mylim_hit, mylim_hit_h),
                         leave = StateEvent(mylim_leave, mylim_leave_h))

# --- a crash that requests a stop: h falls from 0.315 at unit rate ----------------
struct Faller <: AbstractComponent end
x_init(::Faller) = (h = 0.315,)
m_init(::Faller) = (crashed = false,)
y_types(::Faller) = (stop = StopFlag,)
y_state(::Faller, (; m)) = (stop = m.crashed ? STOP_REQUESTED : NO_STOP,)
x_deriv(::Faller, _) = (h = -1.0,)
faller_guard(::Faller, (; x)) = -x.h
faller_handler(::Faller, _) = (m = (crashed = true,),)
state_events(::Faller) = (crash = StateEvent(faller_guard, faller_handler),)
stop_reason(::Faller) = "crash"

function run_sim(model; t_end, kw...)
    sim = Simulation(model; Δt_frame = 1//10, kw...)
    CUR[] = sim.model.exec.cursor
    init!(sim)
    run!(sim; t_end)
    CUR[] = nothing
    sim
end

println("== S10b-131: trial counts per localization (ITP, tol 1e-6, h = Δt_frame) ==")
empty!(TRIALS)
sim = run_sim(Group((; o = Osc(0.3))); t_end = 2.0)
println("osc: ", trials(:osc), " t_fired = ", modes(sim, "o").t_fired, " vs acos(0.3) = ", acos(0.3))
empty!(TRIALS)
sim = run_sim(Group((; l = Lin())); t_end = 1.0)
println("lin: ", trials(:lin), " t_fired = ", modes(sim, "l").t_fired)

println("== S10b-047: strict gate at u = 0 ==")
u = 0.0
println("sign form -u holds: ", -u ≥ 0, "; strict gate holds: ", (u < 0 ? -u : -one(u)) ≥ 0)

println("== S10b-224 / S10b-131: limited copy, ramp input 1.05 - t, release localized at 1.05 ==")
ramp(hit) = Group((; k = Constant(-1.0), ramp = Integrator(x0 = 1.05), li = MyLim(0.4, hit));
                  local_wires = ("k/y" => "ramp/u", "ramp/y" => "li/in"))
for hit in (:shipped, :gated_fn, :gated_bare)
    empty!(TRIALS)
    s = run_sim(ramp(hit); t_end = 2.0)
    ws = writer_status(latest(s), "loop")
    println(rpad(hit, 11), " modes = ", modes(s, "li"), " q = ", state(s, "li").q,
            " firing totals = ", ws.totals.firing, " leave trials = ", trials(:leave))
end

println("== S10b-224: limited copy, step input 1 → -1 at 1.05 (release at a t* boundary) ==")
stepped(hit) = Group((; s = Step(t_step = 1.05, before = 1.0, after = -1.0), li = MyLim(0.5, hit));
                     local_wires = ("s/y" => "li/in",))
for hit in (:shipped, :gated_fn, :gated_bare)
    s = run_sim(stepped(hit); t_end = 2.0)
    ws = writer_status(latest(s), "loop")
    println(rpad(hit, 11), " modes = ", modes(s, "li"), " q = ", state(s, "li").q,
            " firing totals = ", ws.totals.firing)
end

println("== S10b-185: a crash localized at t* ends the run from that snapshot ==")
sim = Simulation(Group((; f = Faller())); Δt_frame = 1//10)
init!(sim)
r = run!(sim; t_end = 1.0)
snap = latest(sim)
println("run! returned ", r)
println("clock = ", sim.model.exec.clock.t, " (crossing 0.315); latest snapshot t = ",
        hasproperty(snap, :t) ? snap.t : propertynames(snap), "; modes = ", modes(sim, "f"),
        "; termination = ", termination(sim))

# S10b probe: spec §10.4 localization mechanics.
using Test, StaticArrays, LinearAlgebra, ForwardDiff
using Redstone
include(joinpath(pwd(), "test", "imports.jl"))
include(joinpath(pwd(), "test", "utils.jl"))

const CALLS = Tuple{Float64,Float64}[]          # (t, σ) per guard call of Ramp
struct Ramp <: AbstractComponent
    level::Float64
    kind::Symbol          # :sign, :jump
end
x_init(::Ramp) = (q = 0.0,)
m_init(::Ramp) = (count = 0, t_fired = -1.0)
y_types(::Ramp) = (q = Float64,)
y_state(::Ramp, (; x)) = (q = x.q,)
x_deriv(::Ramp, (; x)) = (q = 1.0,)
function ramp_guard(c::Ramp, (; x, t))
    σ = c.kind === :sign ? x.q - c.level : (x.q - c.level ≥ 0 ? (x.q - c.level) * 1e-3 + 1e-9 : -1.0)
    push!(CALLS, (Float64(t), σ))
    σ
end
ramp_handler(::Ramp, (; m, t)) = (m = (count = m.count + 1, t_fired = Float64(t)),)
state_events(::Ramp) = (cross = StateEvent(ramp_guard, ramp_handler),)

function run_count(kind; level = 0.3173, tol = 1e-6)
    empty!(CALLS)
    sim = Simulation(single(Ramp(level, kind)); Δt_frame = 1//10, localization_tol = tol)
    init!(sim); empty!(CALLS)
    step!(sim; t_plus = 0.5)
    tf = modes(sim, "c").t_fired
    # interior trials: guard calls at times not on the 0.1 grid and not t*
    trials = count(c -> (abs(c[1]*10 - round(c[1]*10)) > 1e-9) && c[1] != tf, CALLS)
    atstar = [c for c in CALLS if c[1] == tf]
    (tf, trials, atstar, sim)
end
tf, trials, atstar, sim = run_count(:sign)
println("probe:sign t*=", tf, " trials=", trials, " σ at t*=", atstar)       # P1
@test tf ≥ 0.3173 && tf - 0.3173 < 1e-6
@test all(c -> c[2] ≥ 0, atstar)                                              # guard holds at t*
@test tf > 0.3                                                                  # strictly after tₙ
tf2, trials2, _, _ = run_count(:jump)
println("probe:jump t*=", tf2, " trials=", trials2)                           # P2
tf3, trials3, _, _ = run_count(:sign; tol = 1e-12)
println("probe:tol1e-12 trials=", trials3)
# bisection worst-case claim: ceil(log2(1e6)) 
println("probe:log2 ", log2(1e6))

# published boundaries around t*
snaps = [(s.t, s.frame) for s in logged(sim)]
println("probe:snaps ", snaps)                                                 # P3

# -0.0 ≥ 0
println("probe:negzero ", -0.0 ≥ 0, " gate(u=0) ", (let u = 0.0; u < 0 ? -u : -one(u) end))

# defaults
d = sim.model.deployment
println("probe:defaults tol=", d.localization_tol, " budget=", d.localization_budget, " firing=", d.firing_budget)

# validation: three faults collected together
f = try Simulation(single(Ramp(1.0, :sign)); Δt_frame = 1//10, localization_tol = -1.0,
                   localization_budget = 0, firing_budget = 0); nothing catch e e end
println("probe:invalid ", f isa DiagnosticError ? [(x.parameter, x.reason) for x in diagnostics(f)] : f)

# harmonic grid independence: localization params don't enter grid check -> skip

# detection policy from the return type
struct BoolG <: AbstractComponent end
x_init(::BoolG) = (q = 0.0,)
y_types(::BoolG) = (q = Float64,)
y_state(::BoolG, (; x)) = (q = x.q,)
x_deriv(::BoolG, (; x)) = (q = 1.0,)
state_events(::BoolG) = (e = StateEvent((c, (; x)) -> x.q ≥ 0.3, (c, (; x)) -> (x = (q = 0.0,),)),)
b = build(single(BoolG()))
println("probe:policy bool ", b.events.components[1].policies)
struct IntG <: AbstractComponent end
x_init(::IntG) = (q = 0.0,)
y_types(::IntG) = (q = Float64,)
y_state(::IntG, (; x)) = (q = x.q,)
x_deriv(::IntG, (; x)) = (q = 1.0,)
state_events(::IntG) = (e = StateEvent((c, (; x)) -> 1, (c, (; x)) -> (x = (q = 0.0,),)),)
fi = try build(single(IntG())); nothing catch e e end
println("probe:policy int ", fi isa DiagnosticError ? typeof(fi) : fi)

# StateEvent has no keyword
println("probe:statevent kw ", try StateEvent(1, 2, localized = true); "accepted" catch e typeof(e) end)

# projection moving the state back across a guard: no fire, extra boundary
struct Clamp <: AbstractComponent end
x_init(::Clamp) = (q = 0.0,)
m_init(::Clamp) = (count = 0,)
y_types(::Clamp) = (q = Float64,)
y_state(::Clamp, (; x)) = (q = x.q,)
x_deriv(::Clamp, (; x)) = (q = 1.0,)
x_projection(::Clamp, x) = (q = min(x.q, 0.3),)
state_events(::Clamp) = (e = StateEvent((c, (; x)) -> x.q - 0.3173, (c, (; m)) -> (m = (count = m.count + 1,),)),)
csim = Simulation(single(Clamp()); Δt_frame = 1//10); init!(csim); step!(csim; t_plus = 0.5)
println("probe:clamp count=", modes(csim, "c").count, " snaps=", [(s.t, s.frame) for s in logged(csim)])

# budget exhaustion: ChatteringBudget fields
struct Relaxer <: AbstractComponent end
x_init(::Relaxer) = (q = 0.0,)
m_init(::Relaxer) = (count = 0,)
y_types(::Relaxer) = (q = Float64,)
y_state(::Relaxer, (; x)) = (q = x.q,)
x_deriv(::Relaxer, (; x)) = (q = 1.0,)
state_events(::Relaxer) = (pop = StateEvent((c, (; x)) -> x.q - 0.05, (c, (; x, m)) -> (x = (q = 0.049,), m = (count = m.count + 1,))),)
rs = Simulation(single(Relaxer()); Δt_frame = 1//10); init!(rs); step!(rs; frames = 2)
ws = writer_status(latest(rs), "loop")
println("probe:chatter ", [(typeof(x), x.path, x.event, x.budget, x.count) for x in ws.recent], " count=", modes(rs, "c").count)
println("probe:snaps relaxer frame1 ", count(s -> s.frame == 1, logged(rs)))
println("probe:done")

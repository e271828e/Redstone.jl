using StaticArrays, Test
using Redstone
import Redstone: AbstractComponent, Group, Simulation, StateEvent, state_events, x_init, s_init, m_init,
    x_deriv, s_update, y_state, y_direct, y_types, u_types, x_projection, init!, step!, run!, set,
    port, state, modes, logged, latest, sample_times, Relative, Absolute, build, Deployment, Model,
    stage!, classify_tier, DiagnosticError, stop_reason, termination, lifecycle, local_wires, input_wires,
    output_wires, Diagnostic
import Redstone.Library: StopRequest

macro P(label, ex)
    quote
        try
            r = $(esc(ex))
            println("probe:", $(string(__source__.line)), " ", $(esc(label)), " => ", repr(r))
        catch e
            println("probe:", $(string(__source__.line)), " ", $(esc(label)), " THROW ", e isa DiagnosticError ? [(typeof(d), (hasfield(typeof(d),:reason) ? d.reason : nothing))  for d in (e.carried isa AbstractVector ? e.carried : [e.carried])] : sprint(showerror, e))
        end
    end
end
single(c) = Group((; c = c))
times(sim) = [s.t for s in logged(sim)]

# --- ramp with a localized or a Boolean guard
abstract type Ramp <: AbstractComponent end
struct RL <: Ramp; level::Float64; end
struct RB <: Ramp; level::Float64; end
for T in (RL, RB)
    @eval x_init(::$T) = (q = 0.0,)
    @eval m_init(::$T) = (n = 0, tf = 0.0, hit = false)
    @eval y_types(::$T) = (q = Float64, n = Int, tf = Float64, hit = Bool)
    @eval y_state(::$T, (; x, m)) = (q = x.q, n = m.n, tf = m.tf, hit = m.hit)
    @eval x_deriv(::$T, (; x)) = (q = 1.0,)
    @eval hnd(::$T, (; m, t)) = (m = (n = m.n + 1, tf = t, hit = true),)
end
gd(c::RL, (; x)) = x.q - c.level
gd(c::RB, (; x)) = x.q ≥ c.level
state_events(c::RL) = (e = StateEvent(gd, hnd),)
state_events(c::RB) = (e = StateEvent(gd, hnd),)

for (nm, c) in ((:localized, RL(0.35)), (:bool, RB(0.35)))
    sim = Simulation(single(c); Δt_frame = 1//2); init!(sim); run!(sim; t_end = 1.0)
    @P "$nm times" times(sim)
    @P "$nm modes" modes(sim, "c")
end
@P "StateEvent fields" fieldnames(StateEvent)

# --- end time passes by up to one frame
let sim = Simulation(single(RL(0.35)); Δt_frame = 1//2); init!(sim); run!(sim; t_end = 0.7)
    @P "t_end 0.7 final t" latest(sim).t
end

# --- localized stop request ends at t*
let m = Group((; c = RL(0.35), stop = StopRequest(reason = "r")); local_wires = ("c/hit" => "stop/u",))
    sim = Simulation(m; Δt_frame = 1//2); init!(sim); run!(sim; t_end = 5.0)
    @P "stop at t*: times" times(sim)
    @P "stop at t*: termination" termination(sim)
end

# --- localization budget
struct Saw <: AbstractComponent end
x_init(::Saw) = (q = 0.0,); m_init(::Saw) = (n = 0, tf = 0.0)
y_types(::Saw) = (q = Float64,); y_state(::Saw, (; x)) = (q = x.q,)
x_deriv(::Saw, (; x)) = (q = 5.0,)
sg(::Saw, (; x)) = x.q - 1.0
sh(::Saw, (; x, m, t)) = (x = (q = x.q - 1.0,), m = (n = m.n + 1, tf = t))
state_events(::Saw) = (w = StateEvent(sg, sh),)
let sim = Simulation(single(Saw()); Δt_frame = 1, localization_budget = 2); init!(sim); run!(sim; t_end = 1.0)
    @P "budget 2 times" times(sim)
    @P "budget 2 modes" modes(sim, "c")
end
let sim = Simulation(single(Saw()); Δt_frame = 1); init!(sim); run!(sim; t_end = 1.0)
    @P "budget 8 times" times(sim)
end

# --- projection cancels a firing
struct RP <: AbstractComponent end
x_init(::RP) = (q = 0.0,); m_init(::RP) = (n = 0,)
y_types(::RP) = (q = Float64, n = Int); y_state(::RP, (; x, m)) = (q = x.q, n = m.n)
x_deriv(::RP, (; x)) = (q = 1.0,)
x_projection(::RP, x) = (q = min(x.q, 0.3),)
pg(::RP, (; x)) = x.q - 0.35
ph(::RP, (; m)) = (m = (n = m.n + 1,),)
state_events(::RP) = (e = StateEvent(pg, ph),)
let sim = Simulation(single(RP()); Δt_frame = 1//2); init!(sim); run!(sim; t_end = 1.0)
    @P "projection times" times(sim)
    @P "projection modes" modes(sim, "c")
end

# --- even crossings
struct Sine{B} <: AbstractComponent end
x_init(::Sine) = (q = 0.0,); m_init(::Sine) = (n = 0,)
y_types(::Sine) = (q = Float64, n = Int); y_state(::Sine, (; x, m)) = (q = x.q, n = m.n)
x_deriv(::Sine, (; x, t)) = (q = cos(2π * t),)
sig(::Sine{false}, (; x)) = x.q - 0.1
sig(::Sine{true}, (; x)) = x.q ≥ 0.1
sih(::Sine, (; m)) = (m = (n = m.n + 1,),)
state_events(::Sine{B}) where {B} = (e = StateEvent(sig, sih),)
for B in (false, true)
    sim = Simulation(single(Sine{B}()); Δt_frame = 1); init!(sim); run!(sim; t_end = 1.0)
    @P "even crossings B=$B" (modes(sim, "c"), state(sim, "c"))
end

# --- FSM with no continuous state, Bool guard on a root input
struct Fsm <: AbstractComponent end
x_init(::Fsm) = nothing; m_init(::Fsm) = (state = :idle,)
u_types(::Fsm) = (go = Bool,); y_types(::Fsm) = (on = Bool,)
y_state(::Fsm, (; m)) = (on = m.state === :on,)
fg(::Fsm, (; u)) = u.go
fh(::Fsm, (; m)) = (m = (state = :on,),)
state_events(::Fsm) = (e = StateEvent(fg, fh),)
let sim = Simulation(Group((; c = Fsm()); input_wires = ("in" => "c/go",)); Δt_frame = 1//2)
    init!(sim, set(u = (in = false,)))
    step!(sim)
    stage!(sim, "in" => true); step!(sim)
    @P "fsm modes" (modes(sim, "c"), latest(sim).t)
end

# --- discrete tier: stateless discrete holds, stateless continuous recomputes
struct CG <: AbstractComponent end
x_init(::CG) = nothing; u_types(::CG) = (u = Float64,); y_types(::CG) = (y = Float64,)
y_direct(::CG, (; u)) = (y = 2 * u.u,)
struct DG <: AbstractComponent end
s_init(::DG) = nothing; u_types(::DG) = (u = Float64,); y_types(::DG) = (y = Float64,)
y_direct(::DG, (; u)) = (y = 2 * u.u,)
let m = Group((; c = CG(), d = DG()); input_wires = ("a" => "c/u", "b" => "d/u"),
              sample_times = (; d = Relative(2)))
    sim = Simulation(m; Δt_frame = 1, Δt_base = 1); init!(sim, set(u = (a = 0.0, b = 0.0)))
    stage!(sim, "a" => 1.0, "b" => 1.0); step!(sim)
    @P "frame1 c,d" (port(sim, "c", :y), port(sim, "d", :y))
    step!(sim)
    @P "frame2 c,d" (port(sim, "c", :y), port(sim, "d", :y))
end

# --- wrong-tier declarations
struct DM <: AbstractComponent end
s_init(::DM) = (n = 0,); m_init(::DM) = (a = 1,); y_types(::DM) = (y = Int,)
y_state(::DM, (; s)) = (y = s.n,); s_update(::DM, (; s)) = (n = s.n + 1,)
struct DE <: AbstractComponent end
s_init(::DE) = (n = 0,); y_types(::DE) = (y = Int,)
y_state(::DE, (; s)) = (y = s.n,); s_update(::DE, (; s)) = (n = s.n + 1,)
state_events(::DE) = (e = StateEvent(fg, fh),)
struct DP <: AbstractComponent end
s_init(::DP) = (n = 0,); y_types(::DP) = (y = Int,)
y_state(::DP, (; s)) = (y = s.n,); s_update(::DP, (; s)) = (n = s.n + 1,)
x_projection(::DP, x) = x
struct DBad <: AbstractComponent end
s_init(::DBad) = (n = "s",); y_types(::DBad) = (y = Int,)
y_state(::DBad, (; s)) = (y = 1,); s_update(::DBad, (; s)) = s
struct XBad <: AbstractComponent end
x_init(::XBad) = (n = 1,); y_types(::XBad) = (y = Int,)
y_state(::XBad, (; x)) = (y = 1,); x_deriv(::XBad, (; x)) = x
struct XNest <: AbstractComponent end
x_init(::XNest) = (n = (a = 1.0,),); y_types(::XNest) = (y = Float64,)
y_state(::XNest, (; x)) = (y = 1.0,); x_deriv(::XNest, (; x)) = x
for (nm, c) in (("m_init on discrete", DM()), ("events on discrete", DE()), ("projection on discrete", DP()),
                ("string s", DBad()), ("Int x", XBad()), ("nested x", XNest()))
    @P nm build(single(c))
end

# --- conditions
let sim = Simulation(single(RL(0.35)); Δt_frame = 1//2)
    @P "set output as x field" init!(sim, Redstone.at("c", set(x = (tf = 1.0,))))
    @P "set output as m field" init!(sim, Redstone.at("c", set(m = (q = 1.0,))))
    @P "set x,m ok" (init!(sim, Redstone.at("c", set(x = (q = 0.2,), m = (n = 5,)))); (state(sim, "c"), modes(sim, "c")))
end
let sim = Simulation(Group((; c = Fsm()); input_wires = ("in" => "c/go",)); Δt_frame = 1//2)
    @P "missing root input" init!(sim)
end
@P "set nothing" set(x = nothing)

# --- splitting a run bit-identical
mk() = Simulation(Group((; s = Saw(), r = RL(0.35))); Δt_frame = 1//10)
let a = mk(), b = mk()
    init!(a); init!(b)
    step!(a; frames = 9)
    step!(b; frames = 4); step!(b; frames = 5)
    @P "split identical" (state(a, "s") == state(b, "s") && state(a, "r") == state(b, "r") && modes(a, "s") == modes(b, "s"))
end

# --- Relative composition down the tree
struct Inner <: AbstractComponent end
struct Z <: AbstractComponent end
s_init(::Z) = (n = 0,); y_types(::Z) = (n = Int,); y_state(::Z, (; s)) = (n = s.n,)
s_update(::Z, (; s)) = (n = s.n + 1,)
let inner = Group((; z = Z()); sample_times = (; z = Relative(3, 1)), output_wires = ("z/n" => "n",)),
    outer = nothing
    outer = Group((; i = inner); sample_times = (; i = Relative(2, 1)))
    sim = Simulation(outer; Δt_frame = 1, Δt_base = 1); init!(sim)
    ns = Int[]
    for k in 1:14
        step!(sim); push!(ns, latest(sim).t == k ? port(sim, "i/z", :n) : -1)
    end
    @P "composed counts per frame" ns
    @P "schedule rows" sim.model.deployment.schedule.rows
end

# --- deployment fields
@P "Deployment fields" fieldnames(Deployment)

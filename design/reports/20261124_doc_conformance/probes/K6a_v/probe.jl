# K6a_v probe: event visibility walkthrough claims, run against the pinned worktree.
using Redstone, StaticArrays
include(joinpath(pwd(), "test", "imports.jl"))

const SIMREF = Ref{Any}(nothing)
const LOG = Any[]
cur() = SIMREF[].model.exec.cursor
logcur(tag) = SIMREF[] === nothing ? nothing : (c = cur(); push!(LOG, (tag, c.phase, c.index, c.comp, c.fn)))

# --- the §5 boundary: Load -> Battery -> Avionics ------------------------------
struct Load <: AbstractComponent end
x_init(::Load) = (i = 0.0,)
y_types(::Load) = (i_load = Float64,)
y_state(::Load, (; x)) = (i_load = x.i,)
x_deriv(::Load, (; x)) = (i = 1.0,)

struct Battery <: AbstractComponent
    i_max::Float64
end
x_init(::Battery) = nothing
m_init(::Battery) = (tripped = false,)
u_types(::Battery) = (i_load = Float64,)
y_types(::Battery) = (bus_voltage = Float64,)
y_state(b::Battery, (; m)) = (SIMREF[] === nothing || logcur(:bat_y); (bus_voltage = m.tripped ? 0.0 : 24.0,))
guard_ovld(b::Battery, (; u)) = u.i_load > b.i_max
handler_ovld(b::Battery, (; m)) = (logcur(:ovld); (m = (; m..., tripped = true),))
state_events(::Battery) = (ovld = StateEvent(guard_ovld, handler_ovld),)

struct Avionics <: AbstractComponent
    alt_target::Float64
end
x_init(::Avionics) = (alt = 0.0,)
m_init(::Avionics) = (captured = false, v_at_capture = -1.0, low = false, v_at_low = -1.0)
u_types(::Avionics) = (bus_voltage = Float64,)
y_types(::Avionics) = (alt = Float64,)
y_state(::Avionics, (; x)) = (alt = x.alt,)
x_deriv(::Avionics, (; x)) = (alt = 1.0,)
guard_cap(a::Avionics, (; x)) = x.alt >= a.alt_target
handler_cap(a::Avionics, (; m, u)) =
    (logcur(:cap); (m = (; m..., captured = true, v_at_capture = u.bus_voltage),))
guard_low(a::Avionics, (; u)) = u.bus_voltage < 18
handler_low(a::Avionics, (; m, u)) = (logcur(:low); (m = (; m..., low = true, v_at_low = u.bus_voltage),))
state_events(::Avionics) = (cap = StateEvent(guard_cap, handler_cap),
                            low = StateEvent(guard_low, handler_low))

println("== §5 boundary ==")
sim = Simulation(Group((load = Load(), bat = Battery(0.25), av = Avionics(0.25));
                       local_wires = ("load/i_load" => "bat/i_load",
                                      "bat/bus_voltage" => "av/bus_voltage"));
                 Δt_frame = 1 // 10)
println("default firing_budget = ", sim.model.deployment.firing_budget)
init!(sim)
SIMREF[] = sim
step!(sim; frames = 3)
foreach(println, filter(e -> e[1] !== :bat_y || e[2] === :round, LOG))
println("bat modes = ", modes(sim, "bat"), "  av modes = ", modes(sim, "av"))
println("event owners = ", sim.model.exec.events.owner, " names = ", sim.model.exec.events.names)

# --- the same-component twin -------------------------------------------------
struct Twin <: AbstractComponent
    falsify::Bool
end
x_init(::Twin) = (a = 0.0,)
m_init(::Twin) = (n1 = 0, n2 = 0, saw_n1_m = -1, saw_n1_y = -1)
y_types(::Twin) = (n1 = Int, a = Float64)
y_state(::Twin, (; x, m)) = (SIMREF[] === nothing || logcur(:twin_y); (n1 = m.n1, a = x.a))
x_deriv(::Twin, (; x)) = (a = 1.0,)
g1(::Twin, (; x)) = x.a >= 0.25
h1(c::Twin, (; x, m)) = (logcur(:A1);
    c.falsify ? (x = (a = 0.0,), m = (; m..., n1 = m.n1 + 1)) : (m = (; m..., n1 = m.n1 + 1),))
g2(::Twin, (; x)) = x.a >= 0.25
h2(::Twin, (; m, y)) = (logcur(:A2); (m = (; m..., n2 = m.n2 + 1, saw_n1_m = m.n1, saw_n1_y = y.n1),))
state_events(::Twin) = (A1 = StateEvent(g1, h1), A2 = StateEvent(g2, h2))

# two components, one event each: the round count to compare against
struct Solo <: AbstractComponent end
x_init(::Solo) = (a = 0.0,)
m_init(::Solo) = (n = 0,)
y_types(::Solo) = (a = Float64,)
y_state(::Solo, (; x)) = (SIMREF[] === nothing || logcur(:solo_y); (a = x.a,))
x_deriv(::Solo, (; x)) = (a = 1.0,)
gs(::Solo, (; x)) = x.a >= 0.25
hs(::Solo, (; m)) = (logcur(:S); (m = (n = m.n + 1,),))
state_events(::Solo) = (S = StateEvent(gs, hs),)

for (label, root) in (("twin", Group((; c = Twin(false)))),
                      ("twin falsified", Group((; c = Twin(true)))),
                      ("two solos", Group((; c = Solo(), d = Solo()))))
    println("== ", label, " ==")
    empty!(LOG); SIMREF[] = nothing
    s = Simulation(root; Δt_frame = 1 // 10)
    init!(s); SIMREF[] = s
    step!(s; frames = 3)
    foreach(println, filter(e -> e[2] === :round, LOG))
    println("modes c = ", modes(s, "c"))
end

# --- a self-wire: is a cell in both `y` and `u`? -----------------------------
struct SelfFed <: AbstractComponent end
x_init(::SelfFed) = (q = 0.0,)
m_init(::SelfFed) = (seen_u = -1.0, seen_y = -1.0)
u_types(::SelfFed) = (u = Float64,)
y_types(::SelfFed) = (y = Float64,)
y_state(::SelfFed, (; x)) = (y = x.q,)
x_deriv(::SelfFed, (; x, u)) = (q = 1.0 + 0.0 * u.u,)
gself(::SelfFed, (; u, y)) = u.u >= 0.25
hself(::SelfFed, (; m, u, y)) = (m = (; m..., seen_u = u.u, seen_y = y.y),)
state_events(::SelfFed) = (go = StateEvent(gself, hself),)

println("== self-wire ==")
try
    s = Simulation(Group((; c = SelfFed()); local_wires = ("c/y" => "c/u",)); Δt_frame = 1 // 10)
    init!(s); step!(s; frames = 3)
    e = s.model.exec.events.entries[1].entries[1]
    println("event entry u addrs = ", e.inputs, "\n           y addrs = ", e.y)
    println("modes = ", modes(s, "c"))
catch err
    println("self-wire refused: ", sprint(showerror, err))
end

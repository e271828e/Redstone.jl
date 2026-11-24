# G4 fixer probe: trial counts per leave (K10b-048), leave error and tolerance (K10b-077),
# the clock reach (S10c-109), and the floor cap (S10a-064).
using Redstone
import Redstone: AbstractComponent, StateEvent, x_init, m_init, u_types, y_types, y_state,
    x_deriv, state_events, Group, Simulation, init!, step!, set, state, modes
using Redstone.Library: Source, LimitedIntegrator

const CUR = Ref{Any}(nothing); const CLK = Ref{Any}(nothing)
const TRIALS = Int[]; const FIRES = Tuple{Symbol,Float64}[]
function count_guard!()
    cur = CUR[]; cur === nothing && return
    if cur.phase === :trial
        cur.index == 1 ? push!(TRIALS, 1) : (TRIALS[end] = cur.index)
    end
    nothing
end
fire!(name) = (CLK[] === nothing || push!(FIRES, (name, CLK[].t)); nothing)
struct LI{G} <: AbstractComponent
    lower::Float64; upper::Float64; x0::Float64
end
x_init(c::LI) = c.x0
m_init(::LI) = Int8(0)
u_types(::LI) = Float64
y_types(::LI) = (out = Float64,)
y_state(::LI, (; x)) = (out = x,)
x_deriv(::LI, (; u, m)) = m == 0 ? u : zero(u)
hu(c::LI, (; x, u)) = (count_guard!(); x - c.upper)
hl(c::LI, (; x, u)) = c.lower - x
lu(::LI{:strict}, (; m, u)) = m == 1 && u < 0 ? -u : -one(u)
ll(::LI{:strict}, (; m, u)) = m == -1 && u > 0 ? u : -one(u)
lu(::LI{:pm1}, (; m, u)) = m == 1 && u < 0 ? one(u) : -one(u)
ll(::LI{:pm1}, (; m, u)) = m == -1 && u > 0 ? one(u) : -one(u)
state_events(::LI) =
    (hit_upper = StateEvent(hu, (c, _) -> (fire!(:hit); (x = c.upper, m = Int8(1)))),
     hit_lower = StateEvent(hl, (c, _) -> (fire!(:hit); (x = c.lower, m = Int8(-1)))),
     leave_upper = StateEvent(lu, (c, _) -> (fire!(:leave); (m = Int8(0),))),
     leave_lower = StateEvent(ll, (c, _) -> (fire!(:leave); (m = Int8(0),))))

truezeros = [π/2 + k*π for k in 0:6]
for frame in (1//100, 1//10), G in (:strict, :pm1)
    sim = Simulation(Group((; src = Source(t -> cos(t)), li = LI{G}(-0.5, 0.5, 0.0));
                           local_wires = ("src/y" => "li/u",)); Δt_frame = frame)
    init!(sim, set())
    CUR[] = sim.model.exec.cursor; CLK[] = sim.model.exec.clock; empty!(TRIALS); empty!(FIRES)
    step!(sim; t_plus = 20.0)
    CUR[] = nothing; CLK[] = nothing
    leaves = [t for (n, t) in FIRES if n === :leave]
    println("frame=$frame G=$G fires=", [n for (n, _) in FIRES], " trials=", TRIALS,
            " total=", sum(TRIALS), " max|leave-zero|=", maximum(abs.(leaves .- truezeros[1:length(leaves)])),
            " tol_time=", sim.model.deployment.localization_tol * Float64(frame))
end
for frame in (1//100, 1//10)
    sim = Simulation(Group((; src = Source(t -> cos(t)), li = LimitedIntegrator(lower = -0.5, upper = 0.5));
                           local_wires = ("src/y" => "li/u",)); Δt_frame = frame)
    println("library frame=$frame localization_tol=", sim.model.deployment.localization_tol,
            " tol_time=", sim.model.deployment.localization_tol * Float64(frame),
            " a h^2/2 = ", Float64(frame)^2 / 2)
end
println("S10c: 2^49 µs in years = ", 2.0^49 * 1e-6 / (365.25 * 86400))

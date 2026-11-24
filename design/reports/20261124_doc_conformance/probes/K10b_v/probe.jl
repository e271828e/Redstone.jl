# K10b verifier probe: limited_integrator_variants.md claims, at the pinned worktree.
using Redstone, StaticArrays
import Redstone: AbstractComponent, StateEvent, x_init, m_init, u_types, y_types, y_state,
    x_deriv, state_events, Group, Simulation, init!, step!, set, state, modes
using Redstone.Library: Source, Step, Constant, Integrator, LimitedIntegrator,
    LimitedDoubleIntegrator, first_nonzero

const CUR = Ref{Any}(nothing)     # the model's cursor
const CLK = Ref{Any}(nothing)     # the model's clock
const TRIALS = Int[]              # trial count per localization
const TRIAL_T = Float64[]         # clock at each localization's first trial
const VALIDATIONS = Ref(0)
const DERIVS = Ref(0)
const FIRES = Tuple{Symbol, Float64}[]

function count_guard!()
    cur = CUR[]
    cur === nothing && return
    if cur.phase === :trial
        if cur.index == 1
            push!(TRIALS, 1); push!(TRIAL_T, CLK[].t)
        else
            TRIALS[end] = cur.index
        end
    elseif cur.phase === :validation
        VALIDATIONS[] += 1
    end
    nothing
end
fire!(name) = (CLK[] === nothing || push!(FIRES, (name, CLK[].t)); nothing)

# A copy of the scalar LimitedIntegrator with the hit guard `H` and the leave guard `G`.
# H: :old (x - upper), :new (first_nonzero(x - upper, u)).
# G: :first (mode gate only), :strict (mode and u < 0), :pm1 (±1), :floatmin, :bool (non-localized).
struct LI{H, G} <: AbstractComponent
    lower::Float64; upper::Float64; x0::Float64
end
LI{H, G}(; lower, upper, x0 = 0.0) where {H, G} = LI{H, G}(lower, upper, x0)
x_init(c::LI) = c.x0
m_init(::LI) = Int8(0)
u_types(::LI) = Float64
y_types(::LI) = (out = Float64,)
y_state(::LI, (; x)) = (out = x,)
x_deriv(::LI, (; u, m)) = (CUR[] === nothing || (DERIVS[] += 1); m == 0 ? u : zero(u))
hu(c::LI{:old}, (; x, u)) = (count_guard!(); x - c.upper)
hl(c::LI{:old}, (; x, u)) = c.lower - x
hu(c::LI{:new}, (; x, u)) = (count_guard!(); first_nonzero(x - c.upper, u))
hl(c::LI{:new}, (; x, u)) = first_nonzero(c.lower - x, -u)
lu(::LI{H, :first}, (; m, u)) where {H} = m == 1 ? -u : -one(u)
ll(::LI{H, :first}, (; m, u)) where {H} = m == -1 ? u : -one(u)
lu(::LI{H, :strict}, (; m, u)) where {H} = m == 1 && u < 0 ? -u : -one(u)
ll(::LI{H, :strict}, (; m, u)) where {H} = m == -1 && u > 0 ? u : -one(u)
lu(::LI{H, :pm1}, (; m, u)) where {H} = m == 1 && u < 0 ? one(u) : -one(u)
ll(::LI{H, :pm1}, (; m, u)) where {H} = m == -1 && u > 0 ? one(u) : -one(u)
nudge(s) = s == 0 ? -floatmin(s) : s
lu(::LI{H, :floatmin}, (; m, u)) where {H} = m == 1 ? nudge(-u) : -one(u)
ll(::LI{H, :floatmin}, (; m, u)) where {H} = m == -1 ? nudge(u) : -one(u)
lu(::LI{H, :bool}, (; m, u)) where {H} = m == 1 && u < 0
ll(::LI{H, :bool}, (; m, u)) where {H} = m == -1 && u > 0
state_events(::LI) =
    (hit_upper = StateEvent(hu, (c, _) -> (fire!(:hit_upper); (x = c.upper, m = Int8(1)))),
     hit_lower = StateEvent(hl, (c, _) -> (fire!(:hit_lower); (x = c.lower, m = Int8(-1)))),
     leave_upper = StateEvent(lu, (c, _) -> (fire!(:leave_upper); (m = Int8(0),))),
     leave_lower = StateEvent(ll, (c, _) -> (fire!(:leave_lower); (m = Int8(0),))))

function reset_counters!(sim)
    CUR[] = sim.model.exec.cursor; CLK[] = sim.model.exec.clock
    empty!(TRIALS); empty!(TRIAL_T); empty!(FIRES); VALIDATIONS[] = 0; DERIVS[] = 0
end
function disarm!()
    CUR[] = nothing; CLK[] = nothing
end

cos_model(li) = Group((; src = Source(t -> cos(t)), li = li); local_wires = ("src/y" => "li/u",))

const ONLY_TAIL = false
if !ONLY_TAIL
println("=== P1 (K10b-031): the first form with x0 on the limit and zero input")
let comp = LI{:old, :first}(lower = -0.5, upper = 0.5, x0 = 0.5)
    m = Group((; s = Step(t_step = 0.5, before = 0.0, after = 1.0), li = comp); local_wires = ("s/y" => "li/u",))
    sim = Simulation(m; Δt_frame = 1//10)
    reset_counters!(sim)
    init!(sim, set())
    println("P1 after init!: x = ", state(sim, "li"), " mode = ", modes(sim, "li"), " fires = ", FIRES)
    step!(sim; t_plus = 1.0)
    println("P1 at t = 1: x = ", state(sim, "li"), " mode = ", modes(sim, "li"))
    disarm!()
    lib = Group((; s = Step(t_step = 0.5, before = 0.0, after = 1.0),
                   li = LimitedIntegrator(lower = -0.5, upper = 0.5, x0 = 0.5)); local_wires = ("s/y" => "li/u",))
    sim2 = Simulation(lib; Δt_frame = 1//10); init!(sim2, set())
    println("P1 library after init!: x = ", state(sim2, "li"), " mode = ", modes(sim2, "li"))
    step!(sim2; t_plus = 1.0)
    println("P1 library at t = 1: x = ", state(sim2, "li"), " mode = ", modes(sim2, "li"))
end

println("=== P2 (K10b-041/043/048/051/104/077): cos(t) into [-0.5, 0.5] over 20 s")
truezeros = [π/2 + k*π for k in 0:5]
function cos_run(H, G, frame)
    sim = Simulation(cos_model(LI{H, G}(lower = -0.5, upper = 0.5)); Δt_frame = frame)
    init!(sim, set())
    reset_counters!(sim)
    step!(sim; t_plus = 20.0)
    x, m = state(sim, "li"), modes(sim, "li")
    leaves = [t for (n, t) in FIRES if n in (:leave_upper, :leave_lower)]
    hits = [t for (n, t) in FIRES if n in (:hit_upper, :hit_lower)]
    res = (H = H, G = G, frame = frame, x = x, m = m, nhits = length(hits), nleaves = length(leaves),
           trials_total = sum(TRIALS; init = 0), per_loc = copy(TRIALS), validations = VALIDATIONS[],
           derivs = DERIVS[],
           leave_err = isempty(leaves) ? NaN : maximum(abs.(leaves .- truezeros[1:length(leaves)])),
           leaves = leaves)
    disarm!()
    res
end
results = Dict{Any, Any}()
for frame in (1//10, 1//100), H in (:old, :new), G in (:first, :strict, :pm1, :floatmin, :bool)
    r = cos_run(H, G, frame)
    results[(H, G, frame)] = r
    println("P2 frame=$(frame) H=$(H) G=$(G): x=$(r.x) m=$(r.m) hits=$(r.nhits) leaves=$(r.nleaves) ",
            "trials=$(r.trials_total) validations=$(r.validations) derivs=$(r.derivs) ",
            "max|leave - zero|=$(r.leave_err)")
    println("    per-localization trials: ", r.per_loc)
end
for frame in (1//10, 1//100), H in (:old, :new)
    a, b = results[(H, :first, frame)], results[(H, :floatmin, frame)]
    println("P2 frame=$(frame) H=$(H): floatmin leaves - first-form leaves = ",
            length(a.leaves) == length(b.leaves) ? maximum(abs.(a.leaves .- b.leaves); init = 0.0) : "count differs $(length(a.leaves)) vs $(length(b.leaves))")
end
for frame in (1//10, 1//100), G in (:strict, :bool)
    a, b = results[(:old, G, frame)], results[(:new, G, frame)]
    println("P2 frame=$(frame) G=$(G): old-hit x=$(a.x) m=$(a.m) derivs=$(a.derivs); new-hit x=$(b.x) m=$(b.m) derivs=$(b.derivs); same state: ", a.x == b.x && a.m == b.m)
end
for frame in (1//10, 1//100), loc in (true, false)
    sim = Simulation(cos_model(LimitedIntegrator(lower = -0.5, upper = 0.5, localized = loc)); Δt_frame = frame)
    init!(sim, set()); step!(sim; t_plus = 20.0)
    println("P2 library frame=$(frame) localized=$(loc): x=$(state(sim, "li")) m=$(modes(sim, "li"))")
end

println("=== P3 (K10b-073): the non-localized offset on the ramp 1.05 - t, h = 0.1, θ = 0.5, a = 1")
ramp_model(loc) = Group((; k = Constant(-1.0), ramp = Integrator(x0 = 1.05),
                           li = LimitedIntegrator(lower = -2.0, upper = 0.4, localized = loc));
                        local_wires = ("k/y" => "ramp/u", "ramp/y" => "li/u"))
for frame in (1//10, 1//100)
    xs = map((true, false)) do loc
        sim = Simulation(ramp_model(loc); Δt_frame = frame); init!(sim, set()); step!(sim; t_plus = 3.0)
        state(sim, "li")
    end
    exact = 0.4 - 1.95^2 / 2
    h = Float64(frame)
    θ = (1.05 - floor(1.05 / h + 1e-9) * h) / h
    println("P3 frame=$(frame): localized - exact = $(xs[1] - exact), non-localized - exact = $(xs[2] - exact), ",
            "θ=$(θ) a(1-θ)²h²/2 = $((1 - θ)^2 * h^2 / 2), a h²/2 = $(h^2 / 2)")
end

end # ONLY_TAIL
println("=== P4 (K10b-093): a state initialized exactly on a level fires at boundary zero")
struct OnLevel <: AbstractComponent end
x_init(::OnLevel) = 1.0
m_init(::OnLevel) = false
y_types(::OnLevel) = (y = Float64,)
y_state(::OnLevel, (; x)) = (y = x,)
x_deriv(::OnLevel, _) = 0.0
state_events(::OnLevel) = (reach = StateEvent((c, (; x)) -> x - 1.0, (c, _) -> (m = true,)),)
let sim = Simulation(Group((; c = OnLevel())); Δt_frame = 1//10)
    init!(sim, set())
    println("P4 mode after init! = ", modes(sim, "c"))
end

println("=== P5 (K10b-106): the double integrator's hit guard reading `u` at rest alone")
struct LDI{V} <: AbstractComponent
    lower::Float64; upper::Float64; q0::Float64
end
x_init(c::LDI) = (q = c.q0, v = 0.0)
m_init(::LDI) = Int8(0)
u_types(::LDI) = Float64
y_types(::LDI) = (out = Float64,)
y_state(::LDI, (; x)) = (out = x.q,)
x_deriv(::LDI, (; x, u, m)) = m == 0 ? (q = x.v, v = u) : (q = zero(x.v), v = zero(u))
dhu(c::LDI{:skipv}, (; x, u)) = first_nonzero(x.q - c.upper, u)
dhu(c::LDI{:lib}, (; x, u)) = first_nonzero(x.q - c.upper, x.v, u)
# the form increment 87's review sketched: `u` at exact rest on the limit, `q - limit` otherwise
dhu(c::LDI{:rest}, (; x, u)) = x.q == c.upper && x.v == 0 ? u : x.q - c.upper
state_events(::LDI) =
    (hit_upper = StateEvent(dhu, (c, _) -> (fire!(:hit_upper); (x = (q = c.upper, v = 0.0), m = Int8(1)))),
     hit_lower = StateEvent((c, (; x, u)) -> first_nonzero(c.lower - x.q, -x.v, -u),
                            (c, _) -> (fire!(:hit_lower); (x = (q = c.lower, v = 0.0), m = Int8(-1)))),
     leave_upper = StateEvent((c, (; m, u)) -> m == 1 && u < 0 ? -u : -one(u), (c, _) -> (fire!(:leave_upper); (m = Int8(0),))),
     leave_lower = StateEvent((c, (; m, u)) -> m == -1 && u > 0 ? u : -one(u), (c, _) -> (fire!(:leave_lower); (m = Int8(0),))))
for V in (:skipv, :rest, :lib)
    m = Group((; k = Constant(-1e-10), ramp = Integrator(x0 = 1e-10), li = LDI{V}(-5.0, 1.0, 1.0));
              local_wires = ("k/y" => "ramp/u", "ramp/y" => "li/u"))
    sim = Simulation(m; Δt_frame = 1//1000)
    reset_counters!(sim)
    init!(sim, set())
    n0 = length(FIRES)
    step!(sim; t_plus = 1.0)
    n1 = length(FIRES)
    step!(sim; t_plus = 1.0)
    fs = FIRES
    cnt(name, lo, hi) = count(((n, t),) -> n === name && lo < t ≤ hi, fs)
    println("P5 $(V): fires in (0,1] hit=$(cnt(:hit_upper, 0, 1)) leave=$(cnt(:leave_upper, 0, 1)); ",
            "in (1,2] hit=$(cnt(:hit_upper, 1, 2)) leave=$(cnt(:leave_upper, 1, 2)); at 0: $(n0); total $(length(fs)); ",
            "q - 1 = $(state(sim, "li").q - 1.0), v = $(state(sim, "li").v), mode $(modes(sim, "li"))")
    disarm!()
end

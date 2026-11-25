# L6a_v probe: independent verification of slice L6a, run against the pinned worktree.
using Redstone, StaticArrays
include(joinpath(pwd(), "test", "imports.jl"))
import Redstone: local_wires, sample_times, Relative, Absolute, build, descriptor, ModelState,
    RatesViolation, DeploymentInvalid, ArgumentInvalid

say(tag, x) = println(tag, " => ", x)
function caught(f)
    try
        f(); return :no_throw
    catch err
        err isa DiagnosticError ? [(typeof(d), hasproperty(d, :reason) ? d.reason : nothing,
                                    hasproperty(d, :parameter) ? d.parameter : nothing,
                                    hasproperty(d, :related) ? d.related : nothing)
                                   for d in (err.carried isa Diagnostic ? [err.carried] : err.carried)] :
                                  (typeof(err), sprint(showerror, err)[1:min(end, 200)])
    end
end

# --- names (090-101, 107, 080) -------------------------------------------------
for n in (:state_derivative, :x_deriv, :state_update, :s_update, :output_state, :y_state,
          :output_direct, :y_direct, :state_projection, :x_projection, :init_workspace, :ws_init,
          :init_x, :x_init, :init_s, :s_init, :init_m, :m_init, :input_types, :u_types,
          :output_types, :y_types, :sample_times, :local_wires, :input_wires, :output_wires,
          :state_events, :PIVector, :Integrator, :Period)
    say("P1 isdefined $n", isdefined(Redstone, n))
end

# --- firing budget: an event fires more than once per boundary (036) ------------
struct Chat <: AbstractComponent end
m_init(::Chat) = (v = false, flips = 0)
x_init(::Chat) = nothing
y_types(::Chat) = (v = Bool,)
y_state(::Chat, (; m)) = (v = m.v,)
chat_up(::Chat, (; m)) = !m.v
chat_down(::Chat, (; m)) = m.v
chat_flip(::Chat, (; m)) = (m = (v = !m.v, flips = m.flips + 1),)
state_events(::Chat) = (up = StateEvent(chat_up, chat_flip), down = StateEvent(chat_down, chat_flip))
sim = Simulation(Chat(); Δt_frame = 1//10)
init!(sim)
say("P2 flips at boundary zero (budget 4, two events)", modes(sim, "").flips)

# --- rate multipliers and divisors (028, 030) ----------------------------------
struct Tick <: AbstractComponent end
s_init(::Tick) = 0
y_types(::Tick) = (n = Int,)
y_state(::Tick, (; s)) = (n = s,)
s_update(::Tick, (; s)) = s + 1
struct Inner <: AbstractComponent; a::Tick; end
local_wires(::Inner) = ()
sample_times(::Inner) = (a = Relative(2),)
struct Outer <: AbstractComponent; inner::Inner; end
local_wires(::Outer) = ()
sample_times(::Outer) = (inner = Relative(3),)
dep = Deployment(build(Outer(Inner(Tick()))); Δt_frame = 1//10)
say("P3 composed absolute divisor rows", [(r.path, r.D, r.Φ) for r in dep.schedule.rows])
struct Bad <: AbstractComponent; a::Tick; end
local_wires(::Bad) = ()
sample_times(::Bad) = (a = Relative(0),)
say("P3 Relative(0) at build", caught(() -> build(Bad(Tick()))))

# --- h_min (210, 212), Δt_base (134) -------------------------------------------
struct Decay <: AbstractComponent end
x_init(::Decay) = (q = 1.0,)
y_types(::Decay) = (y = Float64,)
y_state(::Decay, (; x)) = (y = x.q,)
x_deriv(::Decay, (; x)) = (q = -x.q,)
b = build(Decay())
say("P4 BS3 without h_min", caught(() -> Deployment(b; Δt_frame = 1//10, algorithm = BS3())))
say("P4 BS3 h_min = 3/4 h_max", caught(() -> Deployment(b; Δt_frame = 1//10, h_max = 1//100,
                                                     h_min = 3//400, algorithm = BS3())))
say("P4 BS3 h_min = 1/2 h_max", caught(() -> Deployment(b; Δt_frame = 1//10, h_max = 1//100,
                                                     h_min = 1//200, algorithm = BS3())))
say("P4 RK4 h_min unset", caught(() -> Deployment(b; Δt_frame = 1//10)))
say("P5 Δt_base = 0", caught(() -> Deployment(b; Δt_frame = 1//10, Δt_base = 0)))
say("P5 Δt_base = -1//10", caught(() -> Deployment(b; Δt_frame = 1//10, Δt_base = -1//10)))

# --- tokens (152) ---------------------------------------------------------------
say("P6 fieldnames RK4, Heun, BS3", (fieldnames(RK4), fieldnames(Heun), fieldnames(BS3)))

# --- clock: nearest float at every magnitude (189, 201) -------------------------
import Redstone: _nearest
let worst = 0, n = 0
    for (a, d) in ((Int128(2)^60 + 12345, Int128(7)), (Int128(2)^70 + 3, Int128(3)^20),
                   (Int128(2)^55 + 1, Int128(2)^54 + 3), (-(Int128(2)^62) - 5, Int128(11)),
                   (Int128(10)^30 + 7, Int128(10)^12 + 9))
        for k in 0:200
            x = a + k
            exact = Float64(big(x) // big(d))   # BigRational → Float64 rounds to nearest
            got = _nearest(x, d)
            n += 1
            got == exact || (worst += 1)
        end
    end
    say("P7 _nearest past 2^53: mismatches/total", (worst, n))
end

# --- t0 forms (191, 192) --------------------------------------------------------
for t0 in (1//2, 1, 0.25, 0.1, -3//10)
    s = Simulation(Decay(); Δt_frame = 1//10)
    r = caught(() -> init!(s; t0 = t0))
    say("P8 init! t0 = $(repr(t0))", r === :no_throw ? (:ok, s.model.exec.clock.t₀, s.model.exec.clock.t) : r)
end

# --- the prior in a checkpoint (068, 069) ---------------------------------------
say("P9 ModelState fields", fieldnames(ModelState))
s9 = Simulation(Chat(); Δt_frame = 1//10)
init!(s9)
cp = checkpoint(s9.model)
say("P9 checkpoint prior", cp.prior)

# --- the descriptor carries time quantities (177) -------------------------------
dd = descriptor(dep)
say("P10 deployment descriptor keys", keys(dd.deployment))
say("P10 dt_frame", dd.deployment.dt_frame)

# --- no warning when a due instant splits a step (162) --------------------------
struct Fast <: AbstractComponent; a::Tick; end
local_wires(::Fast) = ()
sample_times(::Fast) = (a = Absolute(1//30),)
struct Mix <: AbstractComponent; d::Decay; f::Fast; end
local_wires(::Mix) = ()
dmix = Deployment(build(Mix(Decay(), Fast(Tick()))); Δt_frame = 1//10, Δt_base = 1//30, h_max = 1//40)
say("P11 warnings of a splitting deployment", dmix.warnings)
say("P11 show", sprint(show, MIME"text/plain"(), dmix))

# --- guard form → policy (086, 143) ---------------------------------------------
struct Loc <: AbstractComponent end
x_init(::Loc) = (q = 0.0,)
m_init(::Loc) = (n = 0,)
y_types(::Loc) = (y = Float64,)
y_state(::Loc, (; x)) = (y = x.q,)
x_deriv(::Loc, (; x)) = (q = 1.0,)
loc_g(::Loc, (; x)) = x.q - 0.25
bool_g(::Loc, (; x)) = x.q ≥ 0.25
loc_h(::Loc, (; m)) = (m = (n = m.n + 1,),)
state_events(::Loc) = (s = StateEvent(loc_g, loc_h), b = StateEvent(bool_g, loc_h))
sl = Simulation(Loc(); Δt_frame = 1//10)
say("P12 localized flags (Float64 guard, Bool guard)", sl.model.exec.events.localized)

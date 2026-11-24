module PS8a
using StaticArrays
import Redstone: Xoshiro, randn
import Redstone
include("/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/imports.jl")
import Redstone: x_init, s_init, m_init, ws_init, u_types,
    y_types, state_events, y_state, y_direct, x_deriv,
    s_update, x_projection, local_wires, input_wires,
    output_wires, sample_times, transparent_container, stop_reason
sec(s) = println("\n=== ", s)
function tryit(f)
    try
        r = f(); println("  ok: ", r); r
    catch e
        if e isa DiagnosticError
            ds = e.carried isa Vector ? diagnostics(e) : [diagnostic(e)]
            println("  THROW ", typeof(e), " n=", length(ds), " kinds=", map(typeof, ds))
            for d in ds; println("  msg: ", message(d)); end
        else
            println("  THROW(other) ", sprint(showerror, e)[1:min(end,300)])
        end
        e
    end
end

# ---- Engine (spec 2549ff)
@enum Phase p_off p_starting p_running
struct Engine <: AbstractComponent
    ω_idle::Float64; ω_min::Float64; J::Float64
    ω_rated::Float64
end
torque_law(eng, thr, ω) = 100.0 * thr
x_init(::Engine) = (ω = 0.0,)
m_init(::Engine) = (phase = p_off,)
u_types(::Engine) =
    (throttle = Float64, starter = Bool, fuel_available = Bool, M_load = Float64)
y_types(::Engine) = (M_shaft = Float64, P = Float64, ω = Float64)
y_state(::Engine, (; x)) = (; ω = x.ω)
function y_direct(eng::Engine, (; x, m, u))
    M_shaft = m.phase === p_running ? torque_law(eng, u.throttle, x.ω) : zero(x.ω)
    return (; M_shaft, P = M_shaft * x.ω)
end
x_deriv(eng::Engine, (; x, y, u)) = (ω = (y.M_shaft - u.M_load) / eng.J,)
state_events(::Engine) = (
    start    = StateEvent(start_guard, start_handler),
    ignition = StateEvent(ignition_guard, ignition_handler),
    flameout = StateEvent(flameout_guard, flameout_handler))
start_guard(::Engine, (; m, u)) =
    m.phase === p_off && u.starter
start_handler(::Engine, _) = (; m = (; phase = p_starting))
ignition_guard(eng::Engine, (; x, m, u)) =
    m.phase === p_starting && x.ω > eng.ω_idle && u.fuel_available
ignition_handler(::Engine, _) = (; m = (; phase = p_running))
flameout_guard(eng::Engine, (; x)) = eng.ω_min - x.ω
flameout_handler(::Engine, _) = (; m = (; phase = p_off))

sec("Engine build")
eng = Engine(100.0, 50.0, 2.0, 600.0)
b = tryit(() -> build(eng))
println("  tier=", b isa Build ? [c.tier for c in b.structure.components] : "-")
println("  bundle y_state=", bundle_names(y_state, eng, CONTINUOUS, ()))
println("  bundle y_direct=", bundle_names(y_direct, eng, CONTINUOUS, (:ω,)))
println("  bundle x_deriv=", bundle_names(x_deriv, eng, CONTINUOUS, (:ω,)))
println("  event_bundle=", event_bundle_names(eng))
if b isa Build
  println("  events=", b.events)
end
sec("Engine run")
sm = Simulation(eng; Δt_frame = 1//100)
init!(sm, set(u = (throttle = 1.0, starter = true, fuel_available = true, M_load = 0.0)))
tryit(() -> (integrate!(sm, 0.3); println("  state=", state(sm, ""), " port ω=", port(sm, "", :ω))))

# ---- Integrator named vs bare
struct IntN <: AbstractComponent; x0::Float64; end
x_init(c::IntN) = (q = c.x0,)
u_types(::IntN) = (u = Float64,)
y_types(::IntN) = (y = Float64,)
y_state(::IntN, (; x)) = (y = x.q,)
x_deriv(::IntN, (; u)) = (q = u.u,)
struct IntB <: AbstractComponent; x0::Float64; end
x_init(c::IntB) = c.x0
u_types(::IntB) = (u = Float64,)
y_types(::IntB) = (y = Float64,)
y_state(::IntB, (; x)) = (y = x,)
x_deriv(::IntB, (; u)) = u.u
sec("Integrator named/bare")
for T in (IntN, IntB)
    g = Group((; integrator = T(0.5)); input_wires = ("u" => "integrator/u",))
    mm = Model(g; Δt_frame = 1//10)
    cond = T === IntN ? at("integrator", set(x = (q = 1.0,))) : at("integrator", set(x = 1.0))
    tryit(() -> init!(mm, combine(cond, set(u = (u = 0.0,)))))
    println("  ", T, " get_state(integrator)=", tryit(() -> get_state("integrator")))
    println("  ", T, " get_state(integrator,'x')=", tryit(() -> get_state("integrator", "x")))
    println("  ", T, " get_state(integrator,'q')=", tryit(() -> get_state("integrator", "q")))
end

sec("Bare x beside named m (BareLatch has bare m; here named m)")
struct XbMn <: AbstractComponent end
x_init(::XbMn) = 1.0
m_init(::XbMn) = (a = false,)
y_types(::XbMn) = (y = Float64,)
y_state(::XbMn, (; x, m)) = (y = x,)
x_deriv(::XbMn, (; x)) = -x
tryit(() -> build(XbMn()))

sec("Stateless: nothing; TierUnreadable; EmptyStore; no letter")
struct Gn <: AbstractComponent end
x_init(::Gn) = nothing
u_types(::Gn) = (u = Float64,)
y_types(::Gn) = (y = Float64,)
y_direct(::Gn, (; u)) = (y = 2u.u,)
tryit(() -> build(Gn()))
println("  bundle y_direct stateless: ", bundle_names(y_direct, Gn(), CONTINUOUS, ()))
struct Sp <: AbstractComponent end
s_init(::Sp) = nothing
y_types(::Sp) = (y = Float64,)
y_state(::Sp, _) = (y = 1.0,)
tryit(() -> build(Sp()))
struct Nt <: AbstractComponent end   # neither
u_types(::Nt) = (u = Float64,)
y_types(::Nt) = (y = Float64,)
y_direct(::Nt, (; u)) = (y = u.u,)
tryit(() -> build(Nt()))
struct Es <: AbstractComponent end
x_init(::Es) = (;)
y_types(::Es) = (y = Float64,)
y_state(::Es, _) = (y = 1.0,)
tryit(() -> build(Es()))
struct EsM <: AbstractComponent end
x_init(::EsM) = nothing
m_init(::EsM) = (;)
y_types(::EsM) = (y = Float64,)
y_state(::EsM, _) = (y = 1.0,)
tryit(() -> build(EsM()))
println("  m_init fallback: ", m_init(Gn()))
struct NoUp <: AbstractComponent end
x_init(::NoUp) = (a = 0.0,)
y_types(::NoUp) = (y = Float64,)
y_state(::NoUp, (; x)) = (y = x.a,)
tryit(() -> build(NoUp()))
struct Both <: AbstractComponent end
x_init(::Both) = nothing
s_init(::Both) = nothing
y_types(::Both) = (y = Float64,)
y_state(::Both, _) = (y = 1.0,)
tryit(() -> build(Both()))

sec("Pinned")
struct Pn <: AbstractComponent end
x_init(::Pn) = nothing
u_types(::Pn) = (a = Pinned{Float64}, b = Float64)
y_types(::Pn) = (y = Float64,)
y_direct(::Pn, (; u)) = (y = u.a + u.b,)
b = tryit(() -> build(Pn()))
println("  activation Dual: ", tryit(() -> b isa Build ? typeof(activation(b, ProbeDual)) : nothing))

sec("ws_init: KF both tiers, scalar")
struct KF <: AbstractComponent; n::Int; end
s_init(::KF) = (k = 0.0,)
y_types(::KF) = (y = Float64,)
ws_init(c::KF, ::Type{T}) where {T} =
    (P = Matrix{T}(undef, c.n, c.n), x̂ = Vector{T}(undef, c.n))
y_state(::KF, (; s, ws)) = (y = s.k,)
function s_update(::KF, (; s, ws))
    println("    ws eltype in s_update = ", eltype(ws.P)); (k = s.k + 1,)
end
b = tryit(() -> build(KF(2)))
struct KFc <: AbstractComponent; n::Int; end
x_init(::KFc) = (k = 0.0,)
y_types(::KFc) = (y = Float64,)
ws_init(c::KFc, ::Type{T}) where {T} = (P = Matrix{T}(undef, c.n, c.n),)
y_state(::KFc, (; x, ws)) = (y = x.k + 0 * (ws.P isa Matrix{Float64} ? 0 : 0),)
x_deriv(::KFc, (; x, ws)) = (k = (println("    cont ws eltype=", eltype(ws.P)); 1.0),)
bc = tryit(() -> build(KFc(2)))
for T in (Float64, ProbeDual)
    println("  KFc activation at ", T); tryit(() -> activation(bc, T) === nothing)
end
println("  KF activation at ProbeDual (discrete stays Float64):")
tryit(() -> (activation(b, ProbeDual); 0))
println("  ws_init sig: ", methods(ws_init))

sec("Noise PRNG idiom")
struct Noise <: AbstractComponent end
s_init(::Noise)         = (rng = UInt64.((0x9e3779b9, 0x243f6a88, 0xb7e15162, 0x6a09e667)),)
ws_init(::Noise, ::Type) = (rng = Xoshiro(0, 0, 0, 0),)
y_types(::Noise) = (z = Float64,)
y_state(::Noise, _) = (z = 0.0,)
function s_update(c::Noise, b)
    r = b.ws.rng
    r.s0, r.s1, r.s2, r.s3 = b.s.rng        # load the words at entry
    z = randn(r)
    (rng = (r.s0, r.s1, r.s2, r.s3),)       # snapshot them back
end
tryit(() -> build(Noise()))
mn = Simulation(Noise(); Δt_frame = 1//10)
tryit(() -> (init!(mn); run!(mn; t_end = 0.5); state(mn, "")))
println("  Xoshiro fields: ", fieldnames(Xoshiro), " mutable=", ismutable(Xoshiro(0,0,0,0)))

sec("snapshot idiom KFState")
struct KFState; x̂::SVector{20,Float64}; P::SMatrix{20,20,Float64,400}; end
println("  isbits=", isbits(KFState(SVector{20}(zeros(20)), SMatrix{20,20}(zeros(20,20)))))
println("  sizeof=", sizeof(KFState))

sec("Shadowing")
mod1 = Module(:MyEngineMod)
Core.eval(mod1, quote
    using Redstone
    struct MyEngine <: Redstone.AbstractComponent end
    x_init_dummy = 1
    x_deriv(::MyEngine, b) = (ω = 1.0,)
    Redstone.x_init(::MyEngine) = (ω = 0.0,)
    Redstone.y_types(::MyEngine) = (ω = Float64,)
    Redstone.y_state(::MyEngine, (; x)) = (ω = x.ω,)
end)
println("  isdefined x_deriv by bare using: ", isdefined(mod1, :x_deriv), " ; Redstone exports x_init? ", isdefined(mod1, :x_init), " ; Redstone names: ", filter(n -> n !== :Redstone, names(Redstone)))
ME = Core.eval(mod1, :(MyEngine))
tryit(() -> build(ME()))
println("  foreign=", Redstone.foreign_declarations(ME()))
mod2 = Module(:MyAll)
Core.eval(mod2, quote
    using Redstone
    struct C2 <: Redstone.AbstractComponent end
    x_init(::C2) = (a = 0.0,)
    y_types(::C2) = (a = Float64,)
    y_state(::C2, (; x)) = (a = x.a,)
    x_deriv(::C2, b) = (a = 1.0,)
end)
C2 = Core.eval(mod2, :C2)
tryit(() -> build(C2()))
println("  classify (bypass the check): ")
tryit(() -> classify("", C2()))
println("  names via isdefined: ", Redstone.foreign_declarations(C2()))
# only x_deriv shadowed, rest imported
mod3 = Module(:OnlyDeriv)
Core.eval(mod3, quote
    using Redstone
    import Redstone: x_init, y_types, y_state
    struct C3 <: Redstone.AbstractComponent end
    x_init(::C3) = (a = 0.0,)
    y_types(::C3) = (a = Float64,)
    y_state(::C3, (; x)) = (a = x.a,)
    x_deriv(::C3, b) = (a = 1.0,)
end)
C3 = Core.eval(mod3, :C3)
println("  bypass check, only x_deriv shadowed:")
d3 = Redstone.Diagnostic[]
tryit(() -> classify_tier("", C3(), d3)); println("  diags: ", map(typeof, d3))
tryit(() -> build(C3()))
# qualified definition
mod4 = Module(:Qual)
Core.eval(mod4, quote
    using Redstone
    struct C4 <: Redstone.AbstractComponent end
    Redstone.x_init(::C4) = (a = 0.0,)
    Redstone.y_types(::C4) = (a = Float64,)
    Redstone.y_state(::C4, (; x)) = (a = x.a,)
    Redstone.x_deriv(::C4, b) = (a = 1.0,)
end)
tryit(() -> build(Core.eval(mod4, :(C4()))))
# optional decl shadowed: state_events
mod5 = Module(:Opt)
Core.eval(mod5, quote
    using Redstone
    import Redstone: x_init, y_types, y_state, x_deriv
    struct C5 <: Redstone.AbstractComponent end
    x_init(::C5) = (a = 0.0,)
    y_types(::C5) = (a = Float64,)
    y_state(::C5, (; x)) = (a = x.a,)
    x_deriv(::C5, b) = (a = 1.0,)
    state_events(::C5) = (e = Redstone.StateEvent((c,b)->true, (c,b)->(;)),)
end)
tryit(() -> build(Core.eval(mod5, :(C5()))))
# shadow check on a child (path)
tryit(() -> build(Group((; k = ME())))) 

sec("Local scope")
struct Lc <: AbstractComponent end
y_types(::Lc) = (a = Float64,)
function localdef()
    y_state(::Lc, (; x)) = (a = 1.0,)
    y_state(Lc(), (; x = 1))
end
println("  local call: ", localdef(), "; methods(y_state, Lc)=", length(methods(y_state, Tuple{Lc,Any})))
tryit(() -> build(Lc()))
struct Lc0 <: AbstractComponent end
tryit(() -> build(Lc0()))
struct Lc1 <: AbstractComponent end
x_init(::Lc1) = nothing
y_types(::Lc1) = (a = Float64,)
tryit(() -> build(Lc1()))

sec("Names")
println("  exports defined? ", isdefined(Redstone, :exports), "; claims=", isdefined(Redstone, :claims), "; reads=", isdefined(Redstone, :reads), "; input_passthrough=", isdefined(Redstone, :input_passthrough), "; get_state=", isdefined(Redstone,:get_state))
println("  stage fns take component alone: ", [(f, [m.sig for m in methods(f)][1:min(end,2)]) for f in (u_types, y_types, state_events, x_init)])
println("  GUI.draw! in src? (checked by rg)")
println("  x_init(Any) fallback / sample: ", methods(x_init))
println("  Pinned: ", Pinned{Float64})

sec("PRNG allocation")
w4 = UInt64.((0x9e3779b9, 0x243f6a88, 0xb7e15162, 0x6a09e667))
remat(w) = (r = Xoshiro(w...); z = randn(r); (z, (r.s0, r.s1, r.s2, r.s3)))
@noinline escapes(r) = (global SINK = r; randn(r))
remat_escape(w) = (r = Xoshiro(w...); z = escapes(r); (z, (r.s0, r.s1, r.s2, r.s3)))
wsr = Xoshiro(0, 0, 0, 0)
function idiom(r, w)
    r.s0, r.s1, r.s2, r.s3 = w
    z = randn(r)
    (z, (r.s0, r.s1, r.s2, r.s3))
end
remat(w4); remat_escape(w4); idiom(wsr, w4)
println("  remat alloc (inline tail)=", @allocated(remat(w4)), " ; out-of-line tail escapes=", @allocated(remat_escape(w4)), " ; ws idiom=", @allocated(idiom(wsr, w4)))
end

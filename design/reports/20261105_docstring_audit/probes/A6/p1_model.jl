module P1
using Test
include(joinpath(pwd(), "test/repl.jl"))
include(joinpath(pwd(), "test/utils.jl"))
include(joinpath(pwd(), "design/reports/20261105_docstring_audit/probes/A6/common.jl"))

# hooks that log
mutable struct LogHooks <: FrameHooks
    log::Vector{Any}
    model::Any
    ret::Any
end
LogHooks() = LogHooks(Any[], nothing, _->false)
frame_top!(h::LogHooks) = (push!(h.log, (:top, h.model === nothing ? nothing : h.model.exec.clock.t)); nothing)
settled!(h::LogHooks) = begin
    t = h.model === nothing ? nothing : h.model.exec.clock.t
    push!(h.log, (:settled, t)); h.ret(t)
end
struct ThrowTop <: FrameHooks end
frame_top!(::ThrowTop) = error("top boom")
settled!(::ThrowTop) = false
struct ThrowSettled <: FrameHooks end
frame_top!(::ThrowSettled) = nothing
settled!(::ThrowSettled) = error("settled boom")

# interrupts in a handler
struct IntrEv <: AbstractComponent end
m_init(::IntrEv) = (b = false,)
x_init(::IntrEv) = nothing
u_types(::IntrEv) = (sig = Bool,)
y_types(::IntrEv) = (b = Bool,)
y_state(::IntrEv, (; m)) = (b = m.b,)
ie_g(::IntrEv, (; u)) = u.sig
ie_h(::IntrEv, (; u, m)) = u.sig ? throw(InterruptException()) : (m = (b = true,),)
state_events(::IntrEv) = (blow = StateEvent(ie_g, ie_h),)

# two-field discrete
struct TwoS <: AbstractComponent end
s_init(::TwoS) = (a = 0, b = 0)
y_types(::TwoS) = (a = Int, b = Int)
y_state(::TwoS, (; s)) = (a = s.a, b = s.b)
s_update(::TwoS, (; s)) = (a = s.a + 1, b = s.b + 1)
# two-field mode with continuous state
struct TwoM <: AbstractComponent end
x_init(::TwoM) = (q = 0.0, r = 5.0)
m_init(::TwoM) = (a = 0, b = 0)
y_types(::TwoM) = (q = Float64,)
y_state(::TwoM, (; x)) = (q = x.q,)
x_deriv(::TwoM, (; x)) = (q = 1.0, r = 0.0)

println("=== Model scalar")
d = Deployment(build(single(Sawtooth(1.0))); h = 1//10)
for T in (Float32, Int, ForwardDiff.Dual, ForwardDiff.Dual{Nothing,Float32,1}, BigFloat, ProbeDual)
    tryit("Model(dep, $T)", () -> typeof(Model(d, T)))
end
for c in (0, 1.5, 2.0, -1, "x", big(4))
    tryit("chunk_size=$c", () -> Model(d; chunk_size = c).exec.chunk_size)
end
tryit("Model(root) without h", () -> Model(single(Sawtooth(1.0))))
tryit("Model(build) without h", () -> Model(build(single(Sawtooth(1.0)))))
tryit("Model(root; chunk_size=0)", () -> Model(single(Sawtooth(1.0)); h = 1//10, chunk_size = 0))
tryit("Model(root, T) sugar", () -> typeof(Model(single(Sawtooth(1.0)), ProbeDual; h = 1//10)))

println("=== status: init")
m = Model(fed(Mine(), "sig"); h = 1//10)
println("fresh ", m.status)
tryit("init armed", () -> init!(m, set(u = (in = true,)); t0 = 5//2))
println("after throw at boundary zero ", m.status)
init!(m, set(u = (in = false,)))
println("after init ", m.status)
tryit("init then throw again", () -> init!(m, set(u = (in = true,))))
println("status ", m.status)
m = Model(fed(IntrEv(), "sig"); h = 1//10)
init!(m, set(u = (in = false,)))
tryit("init interrupted", () -> init!(m, set(u = (in = true,))))
println("status after interrupt ", m.status)

println("=== init settled throw")
m = Model(single(Sawtooth(1.0)); h = 1//10)
init!(m)
frames!(m, 2)
tryit("init hook throw", () -> init!(m; hooks = ThrowSettled()))
println("status after hook throw in init ", m.status, " t=", m.exec.clock.t)
tryit("overlay hook throw", () -> (init!(m); frames!(m,2); overlay!(m, set(); hooks = ThrowSettled())))
println("status after hook throw in overlay ", m.status)
m2 = Model(single(Sawtooth(1.0)); h = 1//10)
tryit("fresh init hook throw", () -> init!(m2; hooks = ThrowSettled()))
println("status fresh ", m2.status)

println("=== init refusals")
m = Model(fed(Plant(), "u"); h = 1//10)
tryit("init without root input", () -> init!(m))
println("status ", m.status)
tryit("init nonsense cond", () -> init!(m, at("c", set(x = (nope = 1.0,)))))
tryit("init at unknown", () -> init!(m, at("nope", set(x = (q = 1.0,)))))
tryit("init bad face", () -> init!(m, set(u = (nope = 1.0,))))
for t in (1, 1//3, big"0.5", Float32(0.5))
    tryit("init t0=$t", () -> (init!(m, set(u = (in = 0.0,)); t0 = t); (m.exec.clock.t, m.exec.clock.t₀)))
end
tryit("init Dual t0", () -> (init!(m, set(u = (in = 0.0,)); t0 = ProbeDual(1.0, 1.0)); (m.exec.clock.t, m.exec.clock.t₀)))

println("=== init prior reset, frames, boundary order")
m = Model(fed(Trigger(0.5), "sig"); h = 1//10)
init!(m, set(u = (in = 1.0,)))
println("Trigger fired at boundary zero: ", modes(m, "c"))
frames!(m, 3); println("sticky: ", modes(m, "c"))
init!(m, set(u = (in = 1.0,)))
println("re-init resets and refires: ", modes(m, "c"), " prior=", m.exec.events.prior)

println("=== hooks order, localized")
m = Model(single(Sawtooth(4.0)); h = 1//10)
h = LogHooks(); h.model = m
init!(m; hooks = h); println("init log ", h.log); empty!(h.log)
for k in 1:3
    r = frame!(m, k, h); println("frame ", k, " returned ", r, " log ", h.log); empty!(h.log)
end
println("=== abandon at t*")
h.ret = t -> !(t ≈ round(t, digits = 1))   # abandon at an off-grid boundary
abandon = false
for k in 4:6
    r = frame!(m, k, h)
    println("frame ", k, " returned ", r, " log ", h.log, " clock ", m.exec.clock.t, " state ", state(m, "c"))
    empty!(h.log)
    if r
        tryit("checkpoint after abandon", () -> checkpoint(m))
        tryit("overlay after abandon", () -> overlay!(m, set()))
        break
    end
end
println("=== true at frame top")
m = Model(single(Sawtooth(0.1)); h = 1//10)
h = LogHooks(); h.model = m; init!(m)
h.ret = t -> true
r = frame!(m, 1, h); println("returned ", r, " clock ", m.exec.clock.t, " log ", h.log)
tryit("checkpoint after top true", () -> typeof(checkpoint(m)))
h.ret = t -> true; empty!(h.log)
init!(m; hooks = h); println("init ignored return, status ", m.status, " log ", h.log)
overlay!(m, set(); hooks = h); println("overlay ignored return, status ", m.status)
st = checkpoint(m)
restore!(m, st; hooks = h); println("restore ignored return, status ", m.status, " log ", h.log)

println("=== N_base off-tick")
m = Model(single(TickCounter()); h = 1//10, N_base = 2)
init!(m); println("n0=", state(m, "c"), " y=", port(m, "c", :n))
for k in 1:4; frame!(m, k); println("k=", k, " s=", state(m, "c"), " y=", port(m, "c", :n), " t=", m.exec.clock.t); end

println("=== frame throw")
m = Model(fed(Exploder(), "arm"); h = 1//10); init!(m, set(u = (in = false,)))
frames!(m, 2)
apply!(m, resolve_condition(set(u = (in = true,)), m.deployment.build, Float64))
tryit("frame 3 throw", () -> frame!(m, 3))
println("status ", m.status)
tryit("checkpoint inconsistent", () -> checkpoint(m))
tryit("frame top hook throw", () -> begin
    mm = Model(single(Sawtooth(1.0)); h = 1//10); init!(mm); frame!(mm, 1, ThrowTop()) end)
m3 = Model(single(Sawtooth(1.0)); h = 1//10); init!(m3)
tryit("settled hook throw in frame", () -> frame!(m3, 1, ThrowSettled()))
println("status ", m3.status, " clock ", m3.exec.clock.t)
m4 = Model(fed(Interrupter(), "arm"); h = 1//10); init!(m4, set(u = (in = true,)))
tryit("frame interrupt", () -> frame!(m4, 1))
println("status after frame interrupt ", m4.status)
tryit("frame on built model", () -> begin mb = Model(single(Sawtooth(1.0)); h=1//10); r = frame!(mb, 1); (r, mb.status) end)
tryit("checkpoint built", () -> checkpoint(Model(single(Sawtooth(1.0)); h=1//10)))

println("=== claimed")
m5 = Model(fed(Plant(), "u"); h = 1//10); init!(m5, set(u=(in=0.0,)))
st5 = checkpoint(m5)
m6 = Model(fed(Plant(), "u"); h = 1//10)
s6 = Simulation(m6)
println("claimed ", m6.claimed)
tryit("init claimed", () -> init!(m6, set(u = (in = 0.0,))))
tryit("frame claimed", () -> frame!(m6, 1))
tryit("overlay claimed", () -> overlay!(m6, set()))
tryit("restore claimed", () -> restore!(m6, st5))
tryit("apply claimed", () -> apply!(m6, resolve_condition(set(u = (in = 0.0,)), m6.deployment.build, Float64)))
tryit("checkpoint claimed", () -> checkpoint(m6))
tryit("trim claimed", () -> trim!(m6, TrimProblem(decisions=(;))))
tryit("Simulation(dual)", () -> Simulation(Model(fed(Plant(), "u"), ProbeDual; h = 1//10)))
end

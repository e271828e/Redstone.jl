module P8
using Test
include(joinpath(pwd(), "test/repl.jl"))
include(joinpath(pwd(), "test/utils.jl"))
include(joinpath(pwd(), "design/reports/20261105_docstring_audit/probes/A6/common.jl"))
println("=== Dual frame: discrete, events")
m = Model(single(TickCounter()), ProbeDual; h = 1//10); init!(m)
println("init s=", state(m,"c"), " y=", port(m,"c",:n)); frames!(m, 3); println("after 3 frames s=", state(m,"c"), " y=", port(m,"c",:n), " clock ", m.exec.clock.t)
tryit("overlay discrete at Dual", () -> (overlay!(m, at("c", set(s = (n = 10,)))); frames!(m, 2); (state(m,"c"), port(m,"c",:n))))
f = Model(single(TickCounter()); h = 1//10); init!(f); frames!(f, 3); println("Float64 reference s=", state(f,"c"), " y=", port(f,"c",:n))
ms = Model(single(Sawtooth(4.0)), ProbeDual; h = 1//10); init!(ms)
struct LogH <: FrameHooks; log::Vector{Any}; end
frame_top!(::LogH) = nothing
settled!(h::LogH) = (push!(h.log, :settled); false)
h = LogH(Any[]); for k in 1:5; frame!(ms, k, h); end
println("Dual sawtooth settled ", length(h.log), " in 5 frames, state ", state(ms,"c"), " priors ", ms.exec.events.prior)
mf = Model(single(Sawtooth(4.0)); h = 1//10); init!(mf); hh = LogH(Any[]); for k in 1:5; frame!(mf, k, hh); end
println("Float64 sawtooth settled ", length(hh.log), " state ", state(mf,"c"))
println("=== interrupt at RK4 last stage")
struct LastStage <: AbstractComponent end
x_init(::LastStage) = (q = 0.0,)
u_types(::LastStage) = (arm = Bool,)
y_types(::LastStage) = (q = Float64,)
y_state(::LastStage, (; x)) = (q = x.q,)
x_deriv(::LastStage, (; x, u, t)) = (u.arm && t > 0.09) ? throw(InterruptException()) : (q = 1.0,)
m = Model(fed(LastStage(), "arm"); h = 1//10); init!(m, set(u = (in = true,)))
tryit("frame", () -> frame!(m, 1))
println("status ", m.status, " clock ", m.exec.clock.t, " x ", m.exec.xbuf)
tryit("checkpoint", () -> (s = checkpoint(m); (s.t, s.x)))
end

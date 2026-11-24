# K8 independent verifier probe, run from the pinned worktree W with --project=test.
using Test, StaticArrays, LinearAlgebra, ForwardDiff
using Redstone
include(joinpath(pwd(), "test", "imports.jl"))
import Redstone: x_init, x_deriv, y_types, y_state, u_types, state_events, retype, probe_value

line(tag, v) = println(rpad(tag, 10), " => ", v)

# --- K8-029: a parametric Quaternion{N,T} <: AbstractVector{T} at Float64 --------
struct Q{N,T} <: AbstractVector{T}
    sv::SVector{4,T}
end
Base.size(::Q) = (4,)
Base.getindex(q::Q, i::Int) = q.sv[i]
old_method(v::AbstractVector{Float64}) = :hit
q64 = Q{:unit,Float64}(SVector(1.0, 0, 0, 0))
qd = Q{:unit,ForwardDiff.Dual{Nothing,Float64,1}}(SVector{4}(ForwardDiff.Dual{Nothing}.((1.0, 0, 0, 0), 0.0)))
line("K8-029a", (Q{:unit,Float64} <: AbstractVector{Float64}, old_method(q64)))
line("K8-029b", (Q{:unit,typeof(qd[1])} <: AbstractVector{Float64}, hasmethod(old_method, Tuple{typeof(qd)})))

# --- K8-004: the walk at a `Ranged` port leaf ------------------------------------
struct Ranged{T,lo,hi} <: Real
    v::T
end
D = ForwardDiff.Dual{Nothing,Float64,1}
line("K8-004a", retype(D, Ranged{Float64,-1,1}))
line("K8-004b", retype(D, Ranged{Float64,-1.0,1.0}))
line("K8-004c", retype(D, Pinned{Ranged{Float64,-1,1}}) )

# --- K8-082: a wrapper state leaf vs its SVector{4} backing ----------------------
struct QuatState <: AbstractComponent end
x_init(::QuatState) = (q = Q{:unit,Float64}(SVector(1.0, 0, 0, 0)),)
x_deriv(::QuatState, (; x)) = (q = x.q,)
y_types(::QuatState) = (w = Float64,)
y_state(::QuatState, (; x)) = (w = x.q[1],)
struct BackedState <: AbstractComponent end
x_init(::BackedState) = (q = SVector(1.0, 0, 0, 0),)
x_deriv(::BackedState, (; x)) = (q = zero(x.q),)
y_types(::BackedState) = (w = Float64,)
y_state(::BackedState, (; x)) = (w = x.q[1],)
err = try build(Group((; c = QuatState()))); nothing catch e; e end
line("K8-082a", err === nothing ? "built" : [(typeof(d), getfield(d, :reason)) for d in diagnostics(err) if d isa IllegalStateLeaf])
line("K8-082b", build(Group((; c = BackedState()))) isa Build)

# --- K8-050/052/053/064: the flag-gated reset face on the library Integrator ------
plain, flagged = Integrator(x0 = 0.5), Integrator(x0 = 0.5, reset = true)
line("K8-050a", (u_types(plain), state_events(plain)))
line("K8-050b", (u_types(flagged), keys(state_events(flagged)), typeof(only(state_events(flagged)))))
held = Simulation(Group((; k = Constant(1.0), r = Constant(true), i = Integrator(x0 = 0.5, reset = true));
                        local_wires = ("k/y" => "i/u", "r/y" => "i/reset")); Δt_frame = 1//10)
init!(held, at("i", set(x = 2.0)))
line("K8-064a", state(held, "i"))   # 0.5: the holding reset fired at boundary zero, writing x0
low = Simulation(Group((; k = Constant(1.0), r = Constant(false), i = Integrator(x0 = 0.5, reset = true));
                       local_wires = ("k/y" => "i/u", "r/y" => "i/reset")); Δt_frame = 1//10)
init!(low, at("i", set(x = 2.0)))
line("K8-064b", state(low, "i"))    # 2.0: no edge, no reset
step!(held; t_plus = 3//10)
line("K8-052a", state(held, "i"))   # 0.8: held high resets once, then integrates

# --- K8-018: an in-model saturation under trim is not in the report --------------
struct Pend <: AbstractComponent end
x_init(::Pend) = (θ = 0.0, ω = 0.0)
u_types(::Pend) = (u = Float64,)
y_types(::Pend) = (θ = Float64, ω = Float64)
y_state(::Pend, (; x)) = (θ = x.θ, ω = x.ω)
x_deriv(::Pend, (; x, u)) = (θ = x.ω, ω = -9.81 * sin(x.θ) - 0.5 * x.ω + u.u)
sat_model() = Group((; f = Fn{Float64}(u -> clamp(u, -1.0, 1.0)), c = Pend());
                    input_wires = ("in" => "f/u",), local_wires = ("f/y" => "c/u",))
problem = TrimProblem(guess = (u = 0.0,), lower = (u = -Inf,), upper = (u = Inf,),
                      condition = d -> combine(at("c", set(x = (θ = 0.5, ω = 0.0))), set(u = (in = d.u,))),
                      reads = reads(ω̇ = get_deriv("c", :ω)),
                      residuals = (r, d) -> (torque = r.ω̇,), tolerances = (torque = 4.0,))
sim = Simulation(sat_model(); Δt_frame = 1//10)
report = trim!(sim, problem; baseline = set(u = (in = 0.0,)))
line("K8-018", (report.converged, report.solution, report.residuals, report.saturated, report.status))

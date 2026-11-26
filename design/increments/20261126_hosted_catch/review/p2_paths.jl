const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/hosted_catch_review/test"
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test
include(joinpath(W, "imports.jl"))
include(joinpath(W, "utils.jl"))
import Redstone: set, resolve_condition, apply!, evaluate!, StateEvent
say(t, x) = println(rpad(t, 50), " => ", x)
render(e) = e === nothing ? "no throw" : string(typeof(e), "\n    ", replace(sprint(showerror, e), '\n' => "\n    "))
fields(e) = e isa StepError ? (e.host, e.boundary, e.t, e.cursor) : e

# (a)/(b)/(c): a handler or projection at trim!'s commit
struct HandFlip <: AbstractComponent end
x_init(::HandFlip) = (v = 1.0,)
y_types(::HandFlip) = (v = Float64,)
y_state(::HandFlip, (; x)) = (v = x.v,)
x_deriv(::HandFlip, (; x)) = (v = sqrt(x.v) - 1,)
handflip_guard(::HandFlip, (; x)) = x.v > 0.5
handflip_handler(::HandFlip, (; x)) = (x = (v = -1.0,),)
state_events(::HandFlip) = (flip = StateEvent(handflip_guard, handflip_handler),)

struct HandThrow <: AbstractComponent end
x_init(::HandThrow) = (v = 3.0,)
y_types(::HandThrow) = (v = Float64,)
y_state(::HandThrow, (; x)) = (v = x.v,)
x_deriv(::HandThrow, (; x)) = (v = sqrt(x.v) - 1,)
handthrow_guard(::HandThrow, (; x)) = x.v > 0.5
handthrow_handler(::HandThrow, (; x)) = x.v == 1.0 ? error("handler refuses") : (x = x,)
state_events(::HandThrow) = (boom = StateEvent(handthrow_guard, handthrow_handler),)

struct ProjThrow <: AbstractComponent end
x_init(::ProjThrow) = (v = 3.0,)
y_types(::ProjThrow) = (v = Float64,)
y_state(::ProjThrow, (; x)) = (v = x.v,)
x_deriv(::ProjThrow, (; x)) = (v = sqrt(x.v) - 1,)
x_projection(::ProjThrow, x) = x.v == 1.0 ? error("projection refuses") : x

problem = TrimProblem(; guess = (v = 1.0,), lower = (v = -Inf,), upper = (v = Inf,),
    condition = d -> at("c", set(x = (v = d.v,))), reads = reads(v̇ = get_deriv("c", :v)),
    residuals = (r, d) -> (rate = r.v̇,), tolerances = (rate = 1e-9,))
for comp in (HandFlip(), HandThrow(), ProjThrow())
    println("--- trim! commit, ", nameof(typeof(comp)))
    m = Model(single(comp); Δt_frame = 1//10)
    e = failure(() -> trim!(m, problem; baseline = set(), t0 = 1//4))
    say("fields", fields(e)); say("status", m.status)
    println("    ", render(e))
    sim = Simulation(single(comp); Δt_frame = 1//10)
    e = failure(() -> trim!(sim, problem; baseline = set()))
    say("sim lifecycle", lifecycle(sim))
end

# (d) init!'s nominal half at Dual and nested Dual
struct Cmd <: AbstractComponent end
s_init(::Cmd) = (c = 0.0,)
u_types(::Cmd) = (r = Float64,)
y_types(::Cmd) = (u = Float64,)
y_direct(::Cmd, (; s, u)) = (u = sqrt(s.c + u.r),)
s_update(::Cmd, (; s)) = (c = s.c,)
struct Lag <: AbstractComponent end
x_init(::Lag) = (v = 0.0,)
u_types(::Lag) = (u = Float64,)
y_types(::Lag) = (v = Float64,)
y_state(::Lag, (; x)) = (v = x.v,)
x_deriv(::Lag, (; x, u)) = (v = u.u - x.v,)
x_projection(::Lag, x) = x.v < -5 ? error("projection floor") : x
world() = Group((cmd = Cmd(), lag = Lag()); local_wires = ("cmd/u" => "lag/u",),
                input_wires = ("r" => "cmd/r",), output_wires = ("lag/v" => "v",))
D1 = ForwardDiff.Dual{:p,Float64,1}
DD = ForwardDiff.Dual{:q,ForwardDiff.Dual{:p,Float64,1},1}
for T in (Float64, D1, DD)
    println("--- init! at ", T)
    m = try Model(world(), T; Δt_frame = 1//10) catch err; say("Model", sprint(showerror, err)[1:min(end,200)]); continue end
    for (label, cond) in (("stage throws", set(u = (r = -1.0,))),
                          ("projection throws", combine(set(u = (r = 1.0,)), at("lag", set(x = (v = -9.0,))))),
                          ("fine", set(u = (r = 4.0,))))
        e = failure(() -> init!(m, cond; t0 = 1//2))
        say("  $label", fields(e)); say("  status", m.status)
        e === nothing && say("  cmd.u", port(m, "cmd", :u))
        label == "stage throws" && println("    ", render(e))
    end
end

# (e) linearize default form past frame zero, rendering
struct FloorLag <: AbstractComponent end
x_init(::FloorLag) = (v = 1.0,)
u_types(::FloorLag) = (u = Float64,)
y_types(::FloorLag) = (v = Float64,)
y_state(::FloorLag, (; x)) = (v = x.v,)
x_deriv(::FloorLag, (; x, u)) = (v = (x.v isa ForwardDiff.Dual && !iszero(ForwardDiff.partials(x.v))) ? error("no Dual derivative") : -x.v,)
println("--- linearize default at frame 3, about at t0")
sim = Simulation(fed(FloorLag(), :u); Δt_frame = 1//10)
init!(sim, set(u = (in = 0.0,)); t0 = 1//2)
step!(sim; frames = 3)
tp = taps(x = (v = get_state("c", :v),), u = (in = get_input(:in),), y = (;))
e = failure(() -> linearize(sim, tp))
say("default fields", fields(e)); say("lifecycle", lifecycle(sim))
println("    ", render(e))
e = failure(() -> linearize(sim, tp; about = set(u = (in = 0.0,)), t0 = 1//4))
say("about fields", fields(e))
println("    ", render(e))

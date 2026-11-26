# Committed-state residuals and checks on a few problems; run in both trees and diff.
const W = joinpath(ARGS[1], "test")
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test, Logging
include(joinpath(W, "imports.jl"))
include(joinpath(W, "utils.jl"))
import Redstone: StateEvent
struct Cnt <: AbstractComponent end            # discrete: s ticks, output reads s and an input
s_init(::Cnt) = (c = 0.0,)
u_types(::Cnt) = (r = Float64,)
y_types(::Cnt) = (y = Float64,)
y_direct(::Cnt, (; s, u)) = (y = s.c + u.r,)
s_update(::Cnt, (; s)) = (c = s.c + 1,)
struct Plant <: AbstractComponent end          # continuous, with an event and a projection
x_init(::Plant) = (v = 0.0, w = 0.0)
u_types(::Plant) = (u = Float64,)
y_types(::Plant) = (v = Float64, z = Float64)
y_direct(::Plant, (; x, u, t)) = (v = x.v, z = x.w + u.u + t)
x_deriv(::Plant, (; x, u, t)) = (v = u.u - x.v, w = -x.w + t)
plant_guard(::Plant, (; x)) = x.w > 5
plant_handler(::Plant, (; x)) = (x = (v = x.v, w = 4.0),)
state_events(::Plant) = (cap = StateEvent(plant_guard, plant_handler),)
x_projection(::Plant, x) = (v = x.v, w = min(x.w, 9.0))
world() = Group((cnt = Cnt(), p = Plant()); local_wires = ("cnt/y" => "p/u",),
                input_wires = ("r" => "cnt/r",), output_wires = ("p/z" => "z",))
rd = reads(vd = get_deriv("p", :v), wd = get_deriv("p", :w), v = get_state("p", :v), c = get_state("cnt", :c),
           y = get_output("cnt", :y), z = get_output("p", :z), r = get_input(:r), zf = get_face(:z))
res(g, d) = (rate = g.vd,)
chk(g, d) = (wd = g.wd, c = g.c, y = g.y, z = g.z, r = g.r, zf = g.zf, v = g.v)
ctol = (wd = 1e9, c = 1e9, y = 1e9, z = 1e9, r = 1e9, zf = 1e9, v = 1e9)
mk(w) = TrimProblem(; guess = (v = 0.3,), lower = (v = -Inf,), upper = (v = Inf,),
    condition = d -> at("p", set(x = (v = d.v, w = w))), reads = rd, residuals = res,
    tolerances = (rate = 1e-9,), checks = chk, check_tolerances = ctol)
zero_problem = TrimProblem(; guess = (;), lower = (;), upper = (;), condition = d -> at("p", set(x = (v = 2.0, w = 7.0))),
    reads = rd, residuals = res, tolerances = (rate = 1e9,), checks = chk, check_tolerances = ctol)
show_report(label, rep) = println(rpad(label, 34), rep.converged, " ", rep.committed_residuals, " ", rep.committed_checks, " fired ", rep.fired_events)
for (label, w, t0) in (("w=1 t0=0", 1.0, 0), ("w=7 event, t0=3//10", 7.0, 3//10), ("w=20 projection+event", 20.0, 1//2))
    m = Model(world(); Δt_frame = 1//10)
    rep = with_logger(NullLogger()) do; trim!(m, mk(w); baseline = set(u = (r = 2.0,)), t0) end
    show_report("model " * label, rep)
    println(rpad("", 34), "model state ", state(m, "p"), " status ", m.status)
end
m = Model(world(); Δt_frame = 1//10)
show_report("model zero-decision", with_logger(NullLogger()) do; trim!(m, zero_problem; baseline = set(u = (r = 2.0,)), t0 = 1//5) end)
sim = Simulation(world(); Δt_frame = 1//10)
init!(sim, set(u = (r = 1.0,))); step!(sim; frames = 3)
show_report("sim after 3 frames, w=7", with_logger(NullLogger()) do; trim!(sim, mk(7.0); baseline = set(u = (r = 2.0,)), t0 = 1//10) end)
println(rpad("", 34), "lifecycle ", lifecycle(sim), " state ", state(sim, "p"))

module P
using Redstone, ForwardDiff, StaticArrays, LinearAlgebra, Test
using Redstone: activation, _resolve_taps, LinearizeTag
include(joinpath(pwd(), "test", "imports.jl"))
include(joinpath(pwd(), "test", "fixtures.jl"))
const PEND_G_L = 9.81
println("probe:A numerics")
function mk()
    root = Group((; s = Sum(), c = Pendulum());
                 local_wires  = ("s/e" => "c/u",),
                 input_wires  = ("τ" => "s/a", "d" => "s/b"),
                 output_wires = ("c/θ" => "θ", "s/e" => "u_eff"))
    root
end
tp = taps(x = (θ = get_state("c", :θ), ω = get_state("c", :ω)),
          u = (τ = get_input(:τ), d = get_input(:d)),
          y = (θ = get_face(:θ), u_eff = get_face(:u_eff)))
pt = combine(at("c", condition(Pendulum(); θ = 0.3)), set(u = (τ = 9.81 * sin(0.3), d = 0.0)))
sim = Simulation(mk(); Δt_frame = 1//10)
init!(sim, pt)
lin = linearize(sim, tp)
println("probe:A ", lin)
println("probe:A12 A21=", lin.A[2,1], " tau0=", 9.81*sin(0.3), " sin0.3=", sin(0.3), " cos0.3=", cos(0.3))
println("probe:A13 ẋ₀=", lin.ẋ₀, " x₀=", lin.x₀, " u₀=", lin.u₀, " y₀=", lin.y₀)
println("probe:A14 -9.81cos(.3)=", -9.81*cos(0.3))
# step-by-step comparing
for w in (1,3,8)
    l = linearize(sim, tp; width = w)
    println("probe:A15 width $w equal: ", (l.A, l.B, l.C, l.D) == (lin.A, lin.B, lin.C, lin.D))
end
# dual
println("probe:B")
struct LinTag end
θ = ForwardDiff.Dual{LinTag}(0.3, 1.0, 0.0, 0.0, 0.0)
ω = ForwardDiff.Dual{LinTag}(0.0, 0.0, 1.0, 0.0, 0.0)
τ = ForwardDiff.Dual{LinTag}(9.81 * sin(0.3), 0.0, 0.0, 1.0, 0.0)
d = ForwardDiff.Dual{LinTag}(0.0, 0.0, 0.0, 0.0, 1.0)
ω̇ = -9.81 * sin(θ) - 0.5 * ω + (τ - d)
println("probe:B1 ", ω̇)
println("probe:B2 ", typeof(θ), " ", typeof(ForwardDiff.Dual{LinTag}(0.3,1.0,0.0,0.0,0.0)) == ForwardDiff.Dual{LinTag,Float64,4})
println("probe:B3 ", convert(typeof(θ), 0.5))
println("probe:B4 sin dual ", sin(ForwardDiff.Dual{LinTag}(0.3, 1.0)), " -9.81sin ", -9.81*sin(ForwardDiff.Dual{LinTag}(0.3, 1.0)), "  -0.5*0 ", -0.5*ForwardDiff.Dual{LinTag}(0.0,0.0))
# structure
println("probe:C layout")
model = sim.model
bld = model.deployment.build
nom = activation(bld, Float64)
println("probe:C1 ", sort(collect(keys(nom.layout.addr))))
println("probe:C2 xblocks ", nom.layout.xblocks, " paths ", [e.path for e in bld.structure.components])
T8 = ForwardDiff.Dual{LinearizeTag,Float64,8}
println("probe:C3 cached ", activation(bld, T8) === activation(bld, T8))
(xe, ue, ye) = _resolve_taps(tp, bld, ForwardDiff.Dual{LinearizeTag,Float64,4})
println("probe:C4 x ", xe)
println("probe:C5 u ", ue)
println("probe:C6 y ", ye)
act4 = activation(bld, ForwardDiff.Dual{LinearizeTag,Float64,4})
println("probe:C7 addr y(\"\",θ) ", get(act4.layout.addr, ("", :θ), nothing), " (c,θ) ", act4.layout.addr[("c", :θ)], " (s,e) ", act4.layout.addr[("s",:e)], " (\"\",u_eff) ", get(act4.layout.addr, ("", :u_eff), nothing))
println("probe:C8 u addr ", act4.layout.addr[("", :τ)], " ", act4.layout.addr[("", :d)])
println("probe:C9 xbuf cell types ", typeof(Redstone._scratch(model, ForwardDiff.Dual{LinearizeTag,Float64,4}).exec.xbuf))
# unresolved read of the xentry alone
nomrs = Redstone._resolve_selector
# refusals
println("probe:D refusals")
function fail(f)
    try f(); println("  no failure"); catch e
        println("  ", first(sprint(showerror, e), 900))
    end
end
fail(() -> linearize(sim, (x = (;),)))
fail(() -> linearize(sim.model, (x = (;),)))
fail(() -> taps(x = 2.0))
println("probe:D2 reads(bare NT) ")
fail(() -> linearize(sim, tp; about = pt, t0 = 0, width = 0))
# discrete
println("probe:E discrete")
lin_sampled() = Group((; ctl = DiscreteAccumulator(1.0), c = Pendulum());
                      local_wires = ("ctl/u" => "c/u",), input_wires = ("in" => "ctl/e",))
pts = combine(at("ctl", set(s = (acc = 4.0,))), at("c", condition(Pendulum(); θ = asin(4.0 / 9.81))), set(u = (in = 0.0,)))
sim2 = Simulation(lin_sampled(); Δt_frame = 1//10)
state_taps = (θ = get_state("c", :θ), ω = get_state("c", :ω))
l2 = linearize(sim2, taps(x = state_taps); about = pts)
println("probe:E1 A=", l2.A, " closed ", [0 1; -9.81*cos(asin(4.0/9.81)) -0.5])
fail(() -> linearize(sim2, taps(x = (acc = get_state("ctl", :acc),)); about = pts))
fail(() -> linearize(sim2, taps(x = state_taps, u = (in = get_input(:in),)); about = pts))
println("probe:F pinned")
lin_pinned() = Group((; g = PinnedGain(), c = Pendulum());
                     local_wires = ("g/out" => "c/u",), input_wires = ("τ" => "g/e",))
sim3 = Simulation(lin_pinned(); Δt_frame = 1//10)
fail(() -> linearize(sim3, taps(u = (τ = get_input(:τ),)); about = set(u = (τ = 0.0,))))
println("probe:G vector")
sim4 = Simulation(Group((; p = VectorPlant(), fb = StateFeedback(2.0));
                     local_wires = ("fb/u" => "p/u",), input_wires = ("qin" => "fb/q",),
                     output_wires = ("p/q" => "q", "p/power" => "power")); Δt_frame = 1//10)
pv = combine(at("p", set(x = (q = SVector(0.1, 0.2),))), set(u = (qin = SVector(0.5, 0.0),)))
fail(() -> linearize(sim4, taps(x = (a = get_state("p", :q),)); about = pv))
fail(() -> linearize(sim4, taps(u = (a = get_input(:qin),)); about = pv))
l4 = linearize(sim4, taps(x = (a = get_state("p", "q[1]"),), u = (w = get_input("qin[1]"),)); about = pv)
println("probe:G3 ", l4.A, l4.B)
println("probe:H dup in each")
fail(() -> linearize(sim, taps(x = (a = get_state("c", :ω),), u = (τ = get_input(:τ),), y=(a=get_face(:θ),)); about = pt))
fail(() -> linearize(sim, taps(x = (a = get_state("c", :ω), b = get_state("c", :ω)), u = (τ = get_input(:τ), again = get_input(:τ))); about = pt))
println("probe:I side effects")
lc, st = lifecycle(sim), latest(sim); xb = copy(sim.model.exec.xbuf)
linearize(sim, tp); println("  ", lifecycle(sim)===lc, latest(sim)===st, sim.model.exec.xbuf==xb)
println("probe:J ", fieldnames(typeof(lin)), " ", typeof(lin.A), " ", typeof(lin.x₀))
println("probe:K assert_total about missing root input")
fail(() -> linearize(sim, tp; about = at("c", condition(Pendulum(); θ=0.3))))
println("probe:L FD check")
b(τv) = linearize(sim, tp; about = combine(at("c", condition(Pendulum(); θ = 0.3)), set(u = (τ = τv, d = 0.0))))
l1, l2_ = b(2.0), b(2.0 + 1e-6)
println("probe:L1 ", (l2_.ẋ₀ - l1.ẋ₀) / 1e-6, " B col1 ", l1.B[:,1])
println("probe:M get_face/at/labeled")
println("probe:M1 ", Redstone.pinning_consumers(bld.structure, T8))

end

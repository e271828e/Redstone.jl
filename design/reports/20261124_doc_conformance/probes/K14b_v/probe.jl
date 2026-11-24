# K14b verifier probes, run from the pinned worktree W.
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
diags(err) = err.carried isa Vector ? err.carried : [err.carried]
tryerr(f) = try f(); nothing catch e; e end

lin_pend() = Group((; s = Sum(), c = Pendulum()); local_wires = ("s/e" => "c/u",),
                   input_wires = ("τ" => "s/a", "d" => "s/b"),
                   output_wires = ("c/θ" => "θ", "s/e" => "u_eff"))
lin_point() = combine(at("c", condition(Pendulum(); θ = 0.3)), set(u = (τ = 9.81 * sin(0.3), d = 0.0)))
lin_taps() = taps(x = (θ = get_state("c", :θ), ω = get_state("c", :ω)),
                  u = (τ = get_input(:τ), d = get_input(:d)),
                  y = (θ = get_face(:θ), u_eff = get_face(:u_eff)))

# ok-001: the Group builds
sim = Simulation(lin_pend(); Δt_frame = 1//10)
println("P001 built: ", sim isa Simulation, " root_inputs=", sim.model.deployment.build.structure.root_inputs)
init!(sim, lin_point())

# ok-012: width in the type
T4 = ForwardDiff.Dual{LinearizeTag,Float64,4}; T5 = ForwardDiff.Dual{LinearizeTag,Float64,5}
println("P012 T4 === T5: ", T4 === T5)

# ok-020: Authored converts
a = Authored{(),Float64}(); ad = Authored{(),T4}()
println("P020 Float64: ", a(0.5) === 0.5, "  Dual: ", ad(0.5), " partials zero: ", all(iszero, ForwardDiff.partials(ad(0.5))))

# 002: bare NamedTuple to linearize
e = tryerr(() -> linearize(sim, (x = (θ = get_state("c", :θ),),)))
println("P002 ", typeof(e), " ", [ (typeof(d), d.reason) for d in diags(e) ])

# 003: what x.θ / x.ω resolve to
bld = sim.model.deployment.build
(xe, ue, ye) = Redstone._resolve_taps(lin_taps(), bld, LinearizeDual)
println("P003 x entries: ", xe)
println("P003 u entries: ", [typeof(u) for u in ue])
nact = activation(bld, Float64)
for sel in (get_state("c", :θ), get_state("c", :ω))
    r = Redstone._rebase(sel, :q, Redstone._mount(Redstone._reads((q = sel,)), bld, Redstone.Diagnostic[])..., bld, Redstone.Diagnostic[])
    println("P003 nominal entry: ", Redstone._resolve_selector(r.selector, r, bld, nact, Redstone.Diagnostic[]))
end

# ok-029: discrete store in x
lin_sampled() = Group((; ctl = DiscreteAccumulator(1.0), c = Pendulum());
                      local_wires = ("ctl/u" => "c/u",), input_wires = ("in" => "ctl/e",))
ssim = Simulation(lin_sampled(); Δt_frame = 1//10)
pt = combine(at("ctl", set(s = (acc = 4.0,))), at("c", condition(Pendulum(); θ = asin(4.0 / 9.81))), set(u = (in = 0.0,)))
e = tryerr(() -> linearize(ssim, taps(x = (acc = get_state("ctl", :acc),)); about = pt))
d = only(diags(e)); println("P029 ", d.reason, " | ", Redstone.message(d))

# 004: duplicate sites, within x, within u, and the site keys' types
e = tryerr(() -> linearize(sim, taps(x = (a = get_state("c", :ω), b = get_state("c", :ω)),
                                     u = (τ = get_input(:τ), again = get_input(:τ)))))
println("P004 ", [(d.label, d.reason, d.tap, d.duplicate_of) for d in diags(e)])
println("P004 x site key: ", Redstone._site_key(Val(:x), xe[1]), "  u site key: ", Redstone._site_key(Val(:u), ue[1]))

# ok-048: closed form and widths bitwise
rs = [linearize(sim, lin_taps(); width = w) for w in (1, 3, 8)]
cl = [0 1; -9.81cos(0.3) -0.5]
println("P048 closed: ", maximum(abs.(rs[3].A - cl)) ≤ 1e-12, "  bitwise: ",
        all(all(getfield(rs[1], f) == getfield(r, f) for f in fieldnames(Linearization)) for r in rs))

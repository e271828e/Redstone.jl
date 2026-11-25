# SD2 probes: spec D.4 / D.5 glossary (Redstone.jl at 62551b06).
using Redstone, ForwardDiff
import Redstone: AbstractComponent, Absolute, ProbeDual, Deployment, Model, build,
    _shaped, _shaped_steps, activation, DiagnosticError, BS3

struct Decay <: AbstractComponent end
Redstone.x_init(::Decay) = (q = 1.0,)
Redstone.y_types(::Decay) = (q = Float64,)
Redstone.y_state(::Decay, (; x)) = (q = x.q,)
Redstone.x_deriv(::Decay, (; x)) = (q = -x.q,)

struct Cnt <: AbstractComponent end
Redstone.s_init(::Cnt) = (n = 0,)
Redstone.y_types(::Cnt) = (n = Int,)
Redstone.y_state(::Cnt, (; s)) = (n = s.n,)
Redstone.s_update(::Cnt, (; s)) = (n = s.n + 1,)

struct Pair2 <: AbstractComponent
    a::Decay
    b::Cnt
end
Redstone.local_wires(::Pair2) = ()
Redstone.sample_times(::Pair2) = (b = Absolute(1//50),)

b = build(Pair2(Decay(), Cnt()))
d = Deployment(b; Δt_frame = 1//10, Δt_base = :derive)
println("probe:A1 ", (d.firing_budget, d.localization_budget, d.localization_tol, d.attempt_budget, d.h_max, d.h_min, d.Δt_base))
println("probe:A2 unit/frame/base ", d.lattice.unit, " ", d.lattice.frame, " ", d.lattice.base)
dd = Deployment(b; Δt_frame = 1//50)
println("probe:A3 default base ", dd.Δt_base, " unit ", dd.lattice.unit)
r = try Deployment(b; Δt_frame = 1//10, Δt_base = 3//100); :no_throw catch e; (e isa DiagnosticError ? only(e.carried).reason : e) end
println("probe:A4 non-dividing base ", r)
dc = Deployment(build(Decay()); Δt_frame = 1//10, Δt_base = 1//1000)
println("probe:A5 no discrete: unit ", dc.lattice.unit, " base ", dc.lattice.base)
r = try Deployment(build(Decay()); Δt_frame = 1//10, Δt_base = :derive); :no_throw catch e; (e isa DiagnosticError ? only(e.carried).reason : e) end
println("probe:A6 derive without discrete ", r)
struct Free <: AbstractComponent
    a::Cnt
end
Redstone.local_wires(::Free) = ()
r = try Deployment(build(Free(Cnt())); Δt_frame = 1//10, Δt_base = :derive); :no_throw catch e; (e isa DiagnosticError ? only(e.carried).reason : e) end
println("probe:A7 derive with unanchored discrete ", r)
r = try Deployment(b; Δt_frame = 0.1); :no_throw catch e; (e isa DiagnosticError ? only(e.carried).reason : e) end
println("probe:A8 float Δt_frame ", r)
r = try Deployment(b); :no_throw catch e; (e isa DiagnosticError ? only(e.carried).reason : e) end
println("probe:A9 missing Δt_frame ", r)

# the floor
m = Model(Decay(); Δt_frame = 1, h_min = 1//10, algorithm = BS3())
println("probe:B1 floor step r=0.35 ", _shaped(m, 1e-9, 0.0, 0.35), " expect ", 0.35/3)
println("probe:B2 floor step r=0.05 ", _shaped(m, 1e-9, 0.0, 0.05))
println("probe:B3 clamp above h_max ", _shaped(m, 50.0, 0.0, 0.7), " expect ", 0.7/1)
println("probe:B4 equal division ", _shaped(m, 0.3, 0.0, 0.7), " expect ", 0.7/3)

# dual activation executable set
bb = build(Pair2(Decay(), Cnt()); activations = (Float64, ProbeDual))
act = activation(bb, ProbeDual)
println("probe:C1 products types ", [typeof.(values(p)) for p in act.products])
println("probe:C2 ProbeDual ", ProbeDual)

# S8c verifier probes, run against the pinned worktree.
using Redstone, StaticArrays
import Redstone: AbstractComponent, x_init, s_init, m_init, u_types, y_types, y_state, y_direct,
    x_deriv, s_update, x_projection, state_events, StateEvent, local_wires, input_wires,
    transparent_container, Group, build, DiagnosticError, Pinned, Simulation, init!, port, logged,
    step!, has_stage
import Redstone.Library: UnitDelay, PID

function report(tag, f)
    try
        r = f()
        println(tag, " => OK: ", r)
    catch err
        if err isa DiagnosticError
            ds = err.carried isa AbstractVector ? err.carried : [err.carried]
            println(tag, " => [past structure step: ", err.structure !== nothing, "]")
            for d in ds
                println(tag, " => ", nameof(typeof(d)), ": ", sprint(showerror, DiagnosticError(d)))
            end
        else
            println(tag, " => THROW ", typeof(err), ": ", first(sprint(showerror, err), 300))
        end
    end
end

# P1 (S8c-036): x_init store + s_update, no x_deriv
struct XS <: AbstractComponent end
x_init(::XS) = (q = 0.0,)
y_types(::XS) = (q = Float64,)
y_state(::XS, (; x)) = (q = x.q,)
s_update(::XS, (; x)) = (q = 0.0,)
report("P1 x_init store + s_update", () -> build(XS()))

# P1b: x_init store, no update law
struct XN <: AbstractComponent end
x_init(::XN) = (q = 0.0,)
y_types(::XN) = (q = Float64,)
y_state(::XN, (; x)) = (q = x.q,)
report("P1b x_init store, no update", () -> build(XN()))

# P2 (S8c-038): x_deriv methods: any fallback on ::Any?
println("P2 x_deriv fallback methods: ", [m.sig for m in methods(x_deriv) if m.module === Redstone])

# P3 (S8c-047): discrete primitive with x_projection: which step reports it?
struct DP <: AbstractComponent end
s_init(::DP) = (n = 0,)
y_types(::DP) = (n = Int,)
y_state(::DP, (; s)) = (n = s.n,)
s_update(::DP, (; s)) = (n = s.n + 1,)
x_projection(::DP, x) = x
report("P3 discrete + x_projection, build", () -> build(DP()))

# P3b: discrete + x_projection + also m_init (structure-step tier vote) -> both reported together?
struct DPM <: AbstractComponent end
s_init(::DPM) = (n = 0,)
m_init(::DPM) = (k = 0,)
y_types(::DPM) = (n = Int,)
y_state(::DPM, (; s)) = (n = s.n,)
s_update(::DPM, (; s)) = (n = s.n + 1,)
x_projection(::DPM, x) = x
report("P3b discrete + m_init + x_projection", () -> build(DPM()))

# P4 (S8c-048): Pinned entry on discrete primitive
struct DPin <: AbstractComponent end
s_init(::DPin) = nothing
u_types(::DPin) = (a = Pinned{Float64},)
y_types(::DPin) = (b = Float64,)
y_direct(::DPin, (; u)) = (b = u.a,)
report("P4 Pinned on discrete", () -> build(Group((; d = DPin()); input_wires = ("a" => "d/a",))))

# P5 (S8c-057): s_init(::C) = nothing -> discrete
struct SD <: AbstractComponent end
s_init(::SD) = nothing
y_types(::SD) = (b = Float64,)
y_state(::SD, (; t)) = (b = 1.0,)
report("P5 stateless discrete tier", () -> begin
    b = build(SD()); [(e.path, e.tier) for e in b.structure.components]
end)

# P6 (S8c-066): returned field declared nowhere
struct UR <: AbstractComponent end
x_init(::UR) = nothing
y_types(::UR) = (P_shaft = Float64,)
y_state(::UR, (; t)) = (P_shft = 1.0,)
report("P6 undeclared return", () -> build(UR()))

# P7 (S8c-086): declared port no stage produces
struct DN <: AbstractComponent end
x_init(::DN) = nothing
y_types(::DN) = (a = Float64, b = Float64)
y_state(::DN, (; t)) = (a = 1.0,)
report("P7 declared not produced", () -> build(DN()))

# P8 (S8c-105/106): typo'd wire
struct Eng <: AbstractComponent end
x_init(::Eng) = nothing
u_types(::Eng) = (throttle = Float64, mixture = Float64)
y_types(::Eng) = (P = Float64,)
y_direct(::Eng, (; u)) = (P = u.throttle,)
struct Src <: AbstractComponent end
x_init(::Src) = nothing
y_types(::Src) = (y = Float64,)
y_state(::Src, (; t)) = (y = 1.0,)
report("P8 typo wire", () -> build(Group((; s = Src(), eng = Eng());
    local_wires = ("s/y" => "eng/throtle", "s/y" => "eng/mixture"))))

# P9 (S8c-119): PID(kp = 2.0)
report("P9 PID(kp = 2.0)", () -> PID(kp = 2.0))
report("P9b PID(Kp = 2.0)", () -> typeof(PID(Kp = 2.0)))

# P10 (S8c-174): two transparent containers
struct TT <: AbstractComponent
    a::Tuple{Src}
    b::Tuple{Src}
end
local_wires(::TT) = ()
transparent_container(::TT) = (:a, :b)
report("P10 two transparent (tuple)", () -> build(TT((Src(),), (Src(),))))
struct TV <: AbstractComponent
    a::Tuple{Src}
    b::Tuple{Src}
end
local_wires(::TV) = ()
transparent_container(::TV) = [:a, :b]
report("P10b two transparent (vector)", () -> build(TV((Src(),), (Src(),))))

# P11 (S8c-168): container of abstract element type
struct AH <: AbstractComponent
    kids::Tuple{AbstractComponent, AbstractComponent}
    one::AbstractComponent
end
local_wires(::AH) = ()
report("P11 abstract container + abstract field", () -> begin
    b = build(AH((Src(), Src()), Src())); [e.path for e in b.structure.components]
end)

# P12 (S8c-165): mixed and zero-component containers
struct MX <: AbstractComponent
    kids::Tuple{Src, Float64}
    data::Tuple{Float64, Float64}
end
local_wires(::MX) = ()
report("P12 mixed container", () -> build(MX((Src(), 1.0), (1.0, 2.0))))
struct ZC <: AbstractComponent
    kid::Src
    data::Tuple{Float64, Float64}
end
local_wires(::ZC) = ()
report("P12b zero-component container", () -> [e.path for e in build(ZC(Src(), (1.0, 2.0))).structure.components])

# P13 (S8c-186/196): Group wire keyword as function, and Group(g; local_wires)
w = Group((; s = Src(), eng = Eng()); local_wires = g -> ("s/y" => "eng/throttle", "s/y" => "eng/mixture"))
report("P13 function wires", () -> local_wires(w))
w2 = Group(w; local_wires = ("s/y" => "eng/throttle",), input_wires = ("m" => "eng/mixture",))
report("P13b derived copy", () -> (local_wires(w2), input_wires(w2), keys(w2.children)))
report("P13c build derived copy", () -> typeof(build(w2)))

# P14 (S8c-019): StateEvent has no keyword
report("P14 StateEvent keyword", () -> StateEvent(identity, identity; localized = true))
println("P14 StateEvent fields: ", fieldnames(StateEvent))

# P15 (S8c-028): has_stage does not evaluate
struct NE <: AbstractComponent end
x_init(::NE) = nothing
y_types(::NE) = (a = Float64,)
y_state(::NE, args) = error("evaluated!")
println("P15 has_stage(y_state, NE) = ", has_stage(y_state, NE()), "; has_stage(y_direct, NE) = ", has_stage(y_direct, NE()))

# P16 (S8c-072/076): intermediate declared in y_types read via port and logged
report("P16 port on log", () -> begin
    sim = Simulation(Group((; s = Src(), eng = Eng()); local_wires = ("s/y" => "eng/throttle", "s/y" => "eng/mixture"));
                     Δt_frame = 1//10)
    init!(sim); step!(sim; t_plus = 0.2)
    (port(sim, "eng", :P), [port(sn, "eng", :P) for sn in logged(sim)])
end)

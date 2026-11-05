module P2
using Test
const WT = "scratch/wt_base"
include(joinpath(WT, "test/repl.jl"))
include(joinpath(WT, "test/utils.jl"))
const LOG = Any[]
log!(x) = (push!(LOG, x); nothing)
takelog!() = (r = copy(LOG); empty!(LOG); r)
try_(f) = try f() catch err; err isa DiagnosticError ? "DiagErr " * string(typeof(err.carried)) * ": " * first(sprint(showerror, err), 300) : "OTHER " * string(typeof(err)) * ": " * first(sprint(showerror, err), 200) end

# Tick probe: logs (name, t, Δt) at s_update
struct Tk <: AbstractComponent; name::Symbol; end
s_init(::Tk) = (n = 0,)
y_types(::Tk) = (y = Int,)
y_state(::Tk, (; s)) = (y = s.n,)
function s_update(c::Tk, (; s, t, Δt)); log!((c.name, Float64(t), Δt)); (n = s.n + 1,); end

println("--- Absolute with t0 != 0")
struct AbsA <: AbstractComponent; a::AbstractComponent; end
local_wires(::AbsA) = ()
sample_times(::AbsA) = (a = Absolute(Hz(10), 1//20),)
sim = Simulation(AbsA(Tk(:abs)); h = 1//20)
init!(sim); empty!(LOG); step!(sim; frames = 8); println("t0=0  ticks: ", first.(Base.tail.(takelog!())))
sim = Simulation(AbsA(Tk(:abs)); h = 1//20)
init!(sim; t0 = 1.0 + 1//100 |> Float64); empty!(LOG); step!(sim; frames = 8); println("t0=1.01 ticks: ", first.(Base.tail.(takelog!())))

println("--- Relative composition")
struct Sc <: AbstractComponent; b::AbstractComponent; end
local_wires(::Sc) = ()
sample_times(::Sc) = (b = Relative(3, 1),)
struct RelA <: AbstractComponent; s::AbstractComponent; end
local_wires(::RelA) = ()
sample_times(::RelA) = (s = Relative(2, 1),)
sim = Simulation(RelA(Sc(Tk(:rel))); h = 1//10)   # D_s=2, Φ_s=1; child D=6, Φ=1+1*2=3
println("schedule: ", [(r.path, r.D, r.Φ, r.Δt) for r in sim.model.deployment.schedule.rows])
init!(sim); empty!(LOG); step!(sim; frames = 16); println("ticks: ", [l[2] for l in takelog!()])

println("--- Absolute faster than scope, Δt value")
struct Sc2 <: AbstractComponent; b::AbstractComponent; c::AbstractComponent; end
local_wires(::Sc2) = ()
sample_times(::Sc2) = (b = Absolute(Hz(10)),)
struct Outer <: AbstractComponent; s::AbstractComponent; end
local_wires(::Outer) = ()
sample_times(::Outer) = (s = Relative(10),)
sim = Simulation(Outer(Sc2(Tk(:fast), Tk(:slow))); h = 1//10)
println("schedule: ", [(r.path, r.D, r.Φ, r.Δt) for r in sim.model.deployment.schedule.rows])
init!(sim); empty!(LOG); step!(sim; frames = 12); l = takelog!(); println("fast Δt/t: ", [(x[2], x[3]) for x in l if x[1]===:fast][1:3], " slow: ", [(x[2], x[3]) for x in l if x[1]===:slow])

println("--- derive grid, offset T/1000")
struct G1 <: AbstractComponent; a::AbstractComponent; end; local_wires(::G1) = (); sample_times(::G1) = (a = Absolute(Hz(10)),)
struct G2 <: AbstractComponent; a::AbstractComponent; end; local_wires(::G2) = (); sample_times(::G2) = (a = Absolute(Hz(10), 1//10000),)
dep1 = Deployment(build(G1(Tk(:a))); h = 1//10000, Δt_base = :derive)
dep2 = Deployment(build(G2(Tk(:a))); h = 1//10000, Δt_base = :derive)
println("Δt_base no offset ", dep1.Δt_base, ", with T/1000 offset ", dep2.Δt_base)

println("--- sample_times container key / default")
struct CK <: AbstractComponent; units::NamedTuple; other::AbstractComponent; end
local_wires(::CK) = ()
sample_times(::CK) = (units = Relative(2),)
b = build(CK((a = Tk(:u1), b = Tk(:u2)), Tk(:o)))
dep = Deployment(b; h = 1//10); println([(r.path, r.D, r.Φ) for r in dep.schedule.rows])
struct CKA <: AbstractComponent; units::NamedTuple; end
local_wires(::CKA) = ()
sample_times(::CKA) = (units = Absolute(Hz(5)),)
b = build(CKA((a = Tk(:u1), b = Tk(:u2)))); println("anchors for bare key: ", length(b.structure.anchors), " ", b.structure.anchors)

println("--- x_projection counts")
const PLOG = Ref(0)
struct Pj <: AbstractComponent; end
x_init(::Pj) = (q = 2.0,)
x_deriv(::Pj, (; x)) = (q = 1.0,)
x_projection(::Pj, x) = (PLOG[] += 1; (q = x.q,))
y_types(::Pj) = (y = Float64,)
y_state(::Pj, (; x)) = (y = x.q,)
sim = Simulation(Pj(); h = 1//10)
PLOG[] = 0; init!(sim); println("after init!: ", PLOG[]); PLOG[] = 0; step!(sim; frames = 3); println("3 frames: ", PLOG[])
# projection at init changes authored state
struct PjCl <: AbstractComponent; end
x_init(::PjCl) = (q = 2.0,)
x_deriv(::PjCl, (; x)) = (q = 0.0,)
x_projection(::PjCl, x) = (q = min(x.q, 1.0),)
y_types(::PjCl) = (y = Float64,)
y_state(::PjCl, (; x)) = (y = x.q,)
sim = Simulation(PjCl(); h = 1//10); init!(sim); println("state after init with clamp projection (x0=2): ", state(sim, ""))

# typed bare method
struct PjTyped <: AbstractComponent; end
x_init(::PjTyped) = 2.0
x_deriv(::PjTyped, (; x)) = 0.0
x_projection(::PjTyped, x::Float64) = min(x, 1.0)
y_types(::PjTyped) = Float64
y_state(::PjTyped, (; x)) = x
sim = Simulation(PjTyped(); h = 1//10); init!(sim); step!(sim; frames = 2); println("typed bare x_projection(c, x::Float64), state: ", state(sim, ""), " (1.0 if it ran)")
struct PjUnt <: AbstractComponent; end
x_init(::PjUnt) = 2.0
x_deriv(::PjUnt, (; x)) = 0.0
x_projection(::PjUnt, x) = min(x, 1.0)
y_types(::PjUnt) = Float64
y_state(::PjUnt, (; x)) = x
sim = Simulation(PjUnt(); h = 1//10); init!(sim); step!(sim; frames = 2); println("untyped bare x_projection, state: ", state(sim, ""))

println("--- events: priority, one per round, re-decision, bare modes")
struct Ev <: AbstractComponent; end
x_init(::Ev) = (q = 0.0,)
x_deriv(::Ev, (; x)) = (q = 1.0,)
m_init(::Ev) = (a = 0, b = 0)
y_types(::Ev) = (y = Float64,)
y_state(::Ev, (; x)) = (y = x.q,)
g1(::Ev, (; x)) = x.q > 0.05
g2(::Ev, (; x)) = x.q > 0.05
h1(::Ev, (; x, m)) = (log!(:h1); (; m = (; a = m.a + 1)))
h2(::Ev, (; x, m)) = (log!(:h2); (; x = (q = 10.0,), m = (; b = m.b + 1)))
state_events(::Ev) = (first = StateEvent(g1, h1), second = StateEvent(g2, h2))
sim = Simulation(Ev(); h = 1//10); init!(sim); empty!(LOG); step!(sim; frames = 1); println("handlers in order: ", takelog!(), " modes ", modes(sim, ""), " state ", state(sim, ""))
# Bare mode, x replaces
struct EvB <: AbstractComponent; end
x_init(::EvB) = (q = 0.0, p = 5.0)
x_deriv(::EvB, (; x)) = (q = 1.0, p = 0.0)
m_init(::EvB) = false
y_types(::EvB) = (y = Float64,)
y_state(::EvB, (; x, m)) = (y = m ? 1.0 : 0.0,)
gb(::EvB, (; x, m)) = x.q > 0.05 && !m
hb(::EvB, (; x, m)) = (; m = true)
state_events(::EvB) = (e = StateEvent(gb, hb),)
sim = Simulation(EvB(); h = 1//10); init!(sim); step!(sim; frames = 1); println("bare mode after handler: ", modes(sim, ""), " state ", state(sim, ""))
# handler returning bundle m via named against bare
hbad(::Any, b) = (; m = (a = 1,))
struct EvBB <: AbstractComponent end
x_init(::EvBB) = nothing; m_init(::EvBB) = false; y_types(::EvBB) = (y = Float64,); y_direct(::EvBB, (; t)) = (y = 0.0,)
gbb(::EvBB, b) = true
state_events(::EvBB) = (e = StateEvent(gbb, hbad),)
println("bare mode with named m: ", try_(() -> build(EvBB())))

println("--- modes writers: condition")
sim = Simulation(EvB(); h = 1//10); init!(sim, set(m = true)); println("modes after init! with set(m=true): ", modes(sim, ""))
sim = Simulation(EvB(); h = 1//10); init!(sim); overlay!(sim, set(m = true)); println("modes after overlay! set(m=true): ", modes(sim, ""))

println("--- ws_init scalars")
const WSLOG = Any[]
struct WC <: AbstractComponent; end
x_init(::WC) = (q = 1.0,)
x_deriv(::WC, (; x, ws)) = (q = -x.q,)
ws_init(::WC, ::Type{T}) where {T} = (push!(WSLOG, (:cont, T)); (a = zeros(T, 1),))
y_types(::WC) = (y = Float64,)
y_state(::WC, (; x)) = (y = x.q,)
struct WD <: AbstractComponent; end
s_init(::WD) = (n = 0,)
s_update(::WD, (; s, ws)) = (n = s.n + 1,)
ws_init(::WD, ::Type{T}) where {T} = (push!(WSLOG, (:disc, T)); (a = zeros(T, 1),))
y_types(::WD) = (y = Int,)
y_state(::WD, (; s)) = (y = s.n,)
b = build(Group((c = WC(), d = WD())); activations = (LinearizeDual,))
println("ws_init calls: ", unique(WSLOG))

println("--- Pinned output at dual, s_init type at dual, y_types at dual")
struct PO <: AbstractComponent; end
x_init(::PO) = nothing
y_types(::PO) = (p = Pinned{Float64},)
y_direct(::PO, (; t)) = (p = 2.0,)
struct UPO <: AbstractComponent; end
x_init(::UPO) = (q = 1.0,)
x_deriv(::UPO, (; x, u)) = (q = u.a * x.q,)
u_types(::UPO) = (a = Float64,)
y_types(::UPO) = (r = Float64,)
y_state(::UPO, (; x)) = (r = x.q,)
root = Group((p = PO(), d = UPO()); local_wires = ("p/p" => "d/a",))
bb = build(root; activations = (LinearizeDual,))
act = Redstone.activation(bb, LinearizeDual)
println("cells at dual: ", [(k, typeof(v).parameters[1]) for (k, v) in act.layout.addr])
println("root: ", bb.structure.root_inputs)
# Pinned messages
struct NMk <: AbstractComponent; end
x_init(::NMk) = nothing; y_types(::NMk) = (y = Tuple{Pinned{Float64}},)
println("nested marker message: ", try_(() -> build(NMk())))
struct PinDiscIn <: AbstractComponent end; s_init(::PinDiscIn) = nothing; u_types(::PinDiscIn) = (u=Pinned{Float64},); y_types(::PinDiscIn) = (y=Float64,); y_direct(::PinDiscIn, (; u)) = (y = 1.0,)
println("pinned discrete message: ", try_(() -> build(PinDiscIn())))
println("wire msg mismatch with pinned consumer: ")
struct IS <: AbstractComponent end; x_init(::IS) = nothing; y_types(::IS) = (y = Int,); y_direct(::IS, (; t)) = (y = 1,)
struct PS <: AbstractComponent end; x_init(::PS) = nothing; u_types(::PS) = (u = Pinned{Float64},); y_types(::PS) = (y=Float64,); y_direct(::PS, (; u)) = (y = u.u,)
println(try_(() -> build(Group((a = IS(), b = PS()); local_wires = ("a/y" => "b/u",)))))
struct WS1 <: AbstractComponent end; x_init(::WS1) = nothing; y_types(::WS1) = (y = Float64,); y_direct(::WS1, (; t)) = (y = t,)
println(try_(() -> build(Group((a = WS1(), b = PS()); local_wires = ("a/y" => "b/u",)))))

println("--- u_types tolerance: pinned producer to unwrapped; discrete to continuous; discrete to Pinned")
struct Dd <: AbstractComponent end; s_init(::Dd) = nothing; y_types(::Dd) = (y = Float64,); y_direct(::Dd, (; t)) = (y = 1.0,)
struct UW <: AbstractComponent end; x_init(::UW) = nothing; u_types(::UW) = (u = Float64,); y_types(::UW) = (y=Float64,); y_direct(::UW, (; u)) = (y = u.u,)
println(try_(() -> typeof(build(Group((a = PO(), b = UW()); local_wires = ("a/p" => "b/u",)); activations = (LinearizeDual,)))))
println(try_(() -> typeof(build(Group((a = Dd(), b = UW()); local_wires = ("a/y" => "b/u",)); activations = (LinearizeDual,)))))
println(try_(() -> typeof(build(Group((a = Dd(), b = PS()); local_wires = ("a/y" => "b/u",)); activations = (LinearizeDual,)))))
println(try_(() -> typeof(build(Group((a = WS1(), b = UW()); local_wires = ("a/y" => "b/u",)); activations = (LinearizeDual,)))))

println("--- s_init stays as written at dual")
struct SD <: AbstractComponent; end
s_init(::SD) = (v = 1.0,)
s_update(::SD, (; s)) = s
y_types(::SD) = (y = Float64,)
y_state(::SD, (; s)) = (y = s.v,)
struct XD <: AbstractComponent; end
x_init(::XD) = (v = 1.0, w = SVector(1.0, 2.0))
x_deriv(::XD, (; x)) = (v = 0.0, w = SVector(0.0, 0.0))
y_types(::XD) = (y = Float64,)
y_state(::XD, (; x)) = (y = x.v,)
bb = build(Group((s = SD(), x = XD())); activations = (LinearizeDual,))
act = Redstone.activation(bb, LinearizeDual)
println("decls at dual: ", [(typeof(d.x), typeof(d.s)) for d in act.decls])

println("--- discrete holds; stateless discrete")
struct SL <: AbstractComponent; end
s_init(::SL) = nothing
y_types(::SL) = (y = Float64,)
y_direct(::SL, (; t)) = (log!((:sl, Float64(t))); (y = Float64(t),))
struct SLA <: AbstractComponent; a::AbstractComponent; end
local_wires(::SLA) = ()
sample_times(::SLA) = (a = Relative(3),)
sim = Simulation(SLA(SL()); h = 1//10); init!(sim); empty!(LOG)
vals = Float64[]; for i in 1:7; step!(sim; frames = 1); push!(vals, port(sim, "a", :y)); end
println("stateless discrete y over frames: ", vals)
println("--- bare y: reader by name or path, wire by path alone")
struct BY <: AbstractComponent end; x_init(::BY) = nothing; y_types(::BY) = Float64; y_direct(::BY, (; t)) = 3.0
struct BU <: AbstractComponent end; x_init(::BU) = nothing; u_types(::BU) = Float64; y_types(::BU) = Float64; y_direct(::BU, (; u)) = u + 1
r = Group((a = BY(), b = BU()); local_wires = ("a/y" => "b/u",))
sim = Simulation(r; h = 1//10); init!(sim); step!(sim; frames = 1)
println("port name ", port(sim, "b", :y), " port path ", port(sim, "b"))
g = reads(a1 = get_output("b", "y"), a2 = get_output("b"))
println("reads compile: ", try_(() -> Redstone.gather_reads(Redstone._compile_reads(g, sim.model.deployment.build), sim.model.exec)))
println("wire by path alone: ", try_(() -> build(Group((a = BY(), b = BU()); local_wires = ("a" => "b/u",)))))
println("wire to path alone: ", try_(() -> build(Group((a = BY(), b = BU()); local_wires = ("a/y" => "b",)))))
println("root primitive bare: ", build(BU()).structure.root_inputs)
println("--- y_direct depends on every wired input; y_state breaks loop")
struct TwoIn <: AbstractComponent end; x_init(::TwoIn) = nothing; u_types(::TwoIn) = (a = Float64, b = Float64); y_types(::TwoIn) = (y = Float64,); y_direct(::TwoIn, (; u)) = (y = u.a,)
struct Fb1 <: AbstractComponent end; x_init(::Fb1) = (q = 0.0,); u_types(::Fb1) = (u = Float64,); y_types(::Fb1) = (y = Float64,); y_state(::Fb1, (; x)) = (y = x.q,); x_deriv(::Fb1, (; u)) = (q = u.u,)
println("loop through unused input: ", try_(() -> typeof(build(Group((a = TwoIn(),); local_wires = ("a/y" => "a/b",), input_wires = ("i" => "a/a",))))))
println("loop through stage-1: ", try_(() -> typeof(build(Group((a = Fb1(),); local_wires = ("a/y" => "a/u",))))))
end

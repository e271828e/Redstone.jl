using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test
include("/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/imports.jl")
include("/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/fixtures.jl")
include("/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/utils.jl")

show_r(label, x) = println("PROBE ", label, " => ", x)
function tryit(label, f)
    try
        r = f()
        show_r(label, r)
    catch e
        if e isa DiagnosticError
            show_r(label, "DiagnosticError " * join([string(nameof(typeof(d)), get(Dict(), :x, ""),
                   hasproperty(d, :reason) ? "/" * string(d.reason) : "") for d in (e.carried isa Vector ? e.carried : [e.carried])], ", "))
        else
            show_r(label, "THROW " * first(sprint(showerror, e), 300))
        end
    end
end

# ---- A. the §4.3 sketch ----
struct RQuat{T}; q::SVector{4,T}; end
struct KinPose{T}; p::SVector{3,T}; q_eb::RQuat{T}; end
struct Kinematics <: AbstractComponent end
x_init(::Kinematics) = (a = 1.0,)
y_types(::Kinematics) = (pose = KinPose{Float64}, q_eb = RQuat{Float64})
y_state(::Kinematics, (; x)) = (pose = KinPose(SVector(x.a, 0.0, 0.0), RQuat(SVector(1.0, 0, 0, 0))),
                                 q_eb = RQuat(SVector(1.0, 0, 0, 0)))
x_deriv(::Kinematics, (; x)) = (a = 0.0,)
struct Vehicle <: AbstractComponent
    kin::Kinematics
end
local_wires(::Vehicle) = ()
output_wires(::Vehicle) = ("kin/pose" => "pose", "kin/q_eb" => "q_eb")
Vehicle() = Vehicle(Kinematics())
tryit("A.build", () -> (b = build(Group((; v = Vehicle()))); typeof(b)))
sim = Simulation(Group((; v = Vehicle())); Δt_frame = 1//10)
init!(sim)
tryit("A.port_kin_pose", () -> port(sim, "v/kin", :pose))
tryit("A.port_face_pose", () -> port(sim, "v", :pose))
gr(sim, g) = Redstone.gather_reads(Redstone._compile_reads(reads(a = g), sim.model.deployment.build), sim.model.exec)
tryit("A.leaf_read", () -> gr(sim, get_output("v/kin", "pose.q_eb")))
tryit("A.leaf_read2", () -> gr(sim, get_output("v/kin", "pose.q_eb.q[1]")))
tryit("A.leaf_read_sub", () -> gr(sim, get_output("v/kin", "pose.p[1]")))
# number of cells: one per output port in flattened model
tryit("A.ports", () -> (b = build(Group((; v = Vehicle()))); b.outputs.components[1].path * "|" * string(b.outputs.components[1].stage1) * string(b.outputs.components[1].stage2)))

# sub-field wire refused
struct PoseUser <: AbstractComponent end
x_init(::PoseUser) = nothing
u_types(::PoseUser) = (q = RQuat{Float64},)
y_types(::PoseUser) = (o = Float64,)
y_direct(::PoseUser, (; u)) = (o = u.q.q[1],)
tryit("A.subfield_wire", () -> build(Group((; k = Kinematics(), p = PoseUser()); local_wires = ("k/pose.q_eb" => "p/q",))))
tryit("A.whole_wire", () -> (build(Group((; k = Kinematics(), p = PoseUser()); local_wires = ("k/q_eb" => "p/q",))); :ok))

# ---- B. port values ----
struct BareStructRet <: AbstractComponent end
x_init(::BareStructRet) = nothing
y_types(::BareStructRet) = (a = Float64, b = Float64)
y_direct(::BareStructRet, _) = KinPose(SVector(0.0,0,0), RQuat(SVector(1.0,0,0,0)))
tryit("B.bare_struct_return", () -> build(single(BareStructRet())))

struct SymPort <: AbstractComponent end
x_init(::SymPort) = nothing
y_types(::SymPort) = (mode = Symbol, e = StopFlag)
y_direct(::SymPort, _) = (mode = :cruise, e = NO_STOP)
tryit("B.symbol_enum_port", () -> (build(single(SymPort())); :ok))
struct SymReader <: AbstractComponent end
x_init(::SymReader) = nothing
u_types(::SymReader) = (mode = Symbol,)
y_types(::SymReader) = (o = Float64,)
y_direct(::SymReader, (; u)) = (o = u.mode === :a ? 1.0 : 0.0,)
tryit("B.symbol_root_input", () -> build(Group((; r = SymReader()); input_wires = ("mode" => "r/mode",))))
tryit("B.symbol_wired", () -> (build(Group((; s = SymPort(), r = SymReader()); local_wires = ("s/mode" => "r/mode",))); :ok))

struct Handle; r::Ref{Float64}; end
struct HandlePort <: AbstractComponent end
x_init(::HandlePort) = nothing
y_types(::HandlePort) = (h = Handle,)
y_direct(::HandlePort, _) = (h = Handle(Ref(1.0)),)
tryit("B.handle_port", () -> (build(single(HandlePort())); :ok))
tryit("B.nleaves_handle", () -> (nleaves(Handle), nleaves(Symbol), nleaves(StopFlag), leaf_types(KinPose{Float64}) |> length))
struct HandleReader <: AbstractComponent end
x_init(::HandleReader) = nothing
u_types(::HandleReader) = (h = Handle,)
y_types(::HandleReader) = (o = Float64,)
y_direct(::HandleReader, (; u)) = (o = u.h.r[],)
tryit("B.handle_root_input", () -> build(Group((; r = HandleReader()); input_wires = ("h" => "r/h",))))
tryit("B.handle_wired", () -> (build(Group((; s = HandlePort(), r = HandleReader()); local_wires = ("s/h" => "r/h",))); :ok))

struct MutPort <: AbstractComponent end
x_init(::MutPort) = nothing
y_types(::MutPort) = (v = Vector{Float64},)
y_direct(::MutPort, _) = (v = [1.0],)
tryit("B.mutable_port", () -> build(single(MutPort())))
mutable struct MutS; a::Float64; end
struct HoldsMut; m::MutS; end
struct MutNested <: AbstractComponent end
x_init(::MutNested) = nothing
y_types(::MutNested) = (v = HoldsMut,)
y_direct(::MutNested, _) = (v = HoldsMut(MutS(1.0)),)
tryit("B.mutable_nested", () -> build(single(MutNested())))

# isbits handle root input OK
struct ISA; T::Float64; p::Float64; end
Redstone.probe_value(::Type{ISA}) = ISA(1.0, 2.0)
struct ISAReader <: AbstractComponent end
x_init(::ISAReader) = nothing
u_types(::ISAReader) = (f = ISA,)
y_types(::ISAReader) = (o = Float64,)
y_direct(::ISAReader, (; u)) = (o = u.f.T,)
tryit("B.isbits_handle_root", () -> (build(Group((; r = ISAReader()); input_wires = ("f" => "r/f",))); :ok))
# StopFlag
struct NestedStop <: AbstractComponent end
x_init(::NestedStop) = nothing
y_types(::NestedStop) = (s = @NamedTuple{f::StopFlag, x::Float64},)
y_direct(::NestedStop, _) = (s = (f = NO_STOP, x = 0.0),)
tryit("B.nested_stop", () -> build(single(NestedStop())))
struct StopReq <: AbstractComponent end
x_init(::StopReq) = (a = 0.0,)
y_types(::StopReq) = (stop = StopFlag,)
y_state(::StopReq, (; x)) = (stop = x.a > 0.25 ? STOP_REQUESTED : NO_STOP,)
x_deriv(::StopReq, _) = (a = 1.0,)
tryit("B.stop_request_run", () -> (s = Simulation(single(StopReq()); Δt_frame = 1//10); init!(s); run!(s; t_end = 2.0); (s.model.exec.clock.t, s.model.status)))

# ---- C. bundle law ----
bn(f, c, tier, s1 = ()) = Redstone.bundle_names(f, c, tier, s1)
show_r("C.Plant y_state", bn(y_state, Plant(), CONTINUOUS))
show_r("C.Plant y_direct", bn(y_direct, Plant(), CONTINUOUS, (:y,)))
show_r("C.Plant y_direct no s1", bn(y_direct, Plant(), CONTINUOUS, ()))
show_r("C.Plant x_deriv", bn(x_deriv, Plant(), CONTINUOUS, (:y,)))
show_r("C.Negator y_direct", bn(y_direct, Negator(), CONTINUOUS))
show_r("C.TickCounter y_state", bn(y_state, TickCounter(), DISCRETE))
show_r("C.DiscreteAccumulator y_direct", bn(y_direct, DiscreteAccumulator(1.0), DISCRETE, (:u,)))
show_r("C.DiscreteAccumulator s_update", bn(s_update, DiscreteAccumulator(1.0), DISCRETE, (:u,)))
show_r("C.DiscreteMap s_update", bn(s_update, DiscreteMap(), DISCRETE, ()))
show_r("C.WorkGain y_direct", bn(y_direct, WorkGain(1.0), CONTINUOUS))
show_r("C.Motor y_direct", bn(y_direct, Motor(1.0), CONTINUOUS, (:ω,)))
show_r("C.Motor events", Redstone.event_bundle_names(Motor(1.0)))
# a component with y_types but nothing in x_init and no inputs
show_r("C.LEGAL", LEGAL_BUNDLE[(:y_direct, DISCRETE)])
# bare
sb = Simulation(Group((; c = BareScale()); input_wires = ("in" => "c/u",)); Δt_frame = 1//10)
init!(sb, set(u = (in = 1.0,)))
tryit("C.bare_port_read", () -> port(sb, "c"))
show_r("C.bare_bundle", bn(y_direct, BareScale(), CONTINUOUS))
# name outside bundle
struct BadRead <: AbstractComponent end
x_init(::BadRead) = nothing
y_types(::BadRead) = (o = Float64,)
y_direct(::BadRead, (; x)) = (o = 1.0,)
tryit("C.undeclared_store_read", () -> build(single(BadRead())))
struct WrongTier <: AbstractComponent end
s_init(::WrongTier) = (n = 0,)
y_types(::WrongTier) = (o = Float64,)
y_state(::WrongTier, (; x)) = (o = 1.0,)
s_update(::WrongTier, (; s)) = s
tryit("C.wrong_tier_read", () -> build(single(WrongTier())))
struct IllegalFam <: AbstractComponent end
x_init(::IllegalFam) = (a = 0.0,)
u_types(::IllegalFam) = (v = Float64,)
y_types(::IllegalFam) = (o = Float64,)
y_state(::IllegalFam, (; x, u)) = (o = 1.0,)
x_deriv(::IllegalFam, _) = (a = 0.0,)
tryit("C.illegal_for_family", () -> build(single(IllegalFam())))
# discrete comp with m_init
struct DiscM <: AbstractComponent end
s_init(::DiscM) = (n = 0,)
m_init(::DiscM) = (f = false,)
y_types(::DiscM) = (o = Int,)
y_state(::DiscM, (; s)) = (o = s.n,)
s_update(::DiscM, (; s)) = s
tryit("C.discrete_with_m", () -> build(single(DiscM())))

# Δt same in y_state, y_direct, s_update; phase does not change it
struct DtProbe <: AbstractComponent end
s_init(::DtProbe) = (d1 = 0.0, d2 = 0.0, d3 = 0.0)
u_types(::DtProbe) = (a = Float64,)
y_types(::DtProbe) = (p1 = Float64, p2 = Float64, p3 = Float64)
y_state(::DtProbe, (; s, Δt)) = (p1 = Δt, p3 = s.d3)
y_direct(::DtProbe, (; s, u, Δt)) = (p2 = Δt,)
s_update(::DtProbe, (; s, u, Δt)) = (d1 = 0.0, d2 = 0.0, d3 = Δt)
tryit("C.dt_probe", () -> (s = Simulation(Group((; c = DtProbe()); input_wires = ("in" => "c/a",)); Δt_frame = 1//10); init!(s, set(u = (in = 1.0,))); step!(s; frames = 2); (port(s, "c", :p1), port(s, "c", :p2), port(s, "c", :p3))))

# ---- D. stage return law ----
struct Scrambled <: AbstractComponent end
x_init(::Scrambled) = nothing
y_types(::Scrambled) = (a = Float64, b = Float64)
y_direct(::Scrambled, _) = (b = 2.0, a = 1.0)
tryit("D.field_order", () -> (build(single(Scrambled())); :ok))
struct IntRet <: AbstractComponent end
x_init(::IntRet) = nothing
y_types(::IntRet) = (a = Float64,)
y_direct(::IntRet, _) = (a = 1,)
tryit("D.no_conversion", () -> build(single(IntRet())))
struct Extra <: AbstractComponent end
x_init(::Extra) = nothing
y_types(::Extra) = (a = Float64,)
y_direct(::Extra, _) = (a = 1.0, z = 2.0)
tryit("D.extra_key", () -> build(single(Extra())))
struct Twice2 <: AbstractComponent end
x_init(::Twice2) = (q = 0.0,)
y_types(::Twice2) = (a = Float64,)
y_state(::Twice2, (; x)) = (a = x.q,)
y_direct(::Twice2, (; x)) = (a = x.q,)
x_deriv(::Twice2, _) = (q = 0.0,)
tryit("D.two_stages_same_port", () -> build(single(Twice2())))
struct DeadS <: AbstractComponent end
x_init(::DeadS) = (a = 0.0,)
y_types(::DeadS) = (p = Float64,)
y_state(::DeadS, (; x)) = (;)
y_direct(::DeadS, (; x)) = (p = x.a,)
x_deriv(::DeadS, (; x)) = (a = 0.0,)
tryit("D.dead_state", () -> build(single(DeadS())))
struct NotNT <: AbstractComponent end
x_init(::NotNT) = (q = 0.0,)
y_types(::NotNT) = (a = Float64,)
y_state(::NotNT, (; x)) = 1.0
x_deriv(::NotNT, _) = (q = 0.0,)
tryit("D.return_not_nt", () -> build(single(NotNT())))
struct Tpart <: AbstractComponent end   # port a nobody produces
x_init(::Tpart) = (q = 0.0,)
y_types(::Tpart) = (a = Float64, b = Float64)
y_state(::Tpart, (; x)) = (a = x.q,)
x_deriv(::Tpart, _) = (q = 0.0,)
tryit("D.declared_not_produced", () -> build(single(Tpart())))
# y keys in x_deriv: declared ports only, both stages
const YK = Ref{Any}(nothing)
struct YSee <: AbstractComponent end
x_init(::YSee) = (q = 0.0,)
u_types(::YSee) = (u = Float64,)
y_types(::YSee) = (a = Float64, b = Float64)
y_state(::YSee, (; x)) = (a = x.q,)
y_direct(::YSee, (; x, u, y_x)) = (b = u.u + y_x.a,)
function x_deriv(::YSee, (; x, y, u)); YK[] = keys(y); (q = 0.0,); end
tryit("D.y_keys", () -> (s = Simulation(fed(YSee(), "u"); Δt_frame = 1//10); init!(s, set(u = (in = 1.0,))); step!(s; frames = 1); YK[]))
# y_x equals stage-1 return
# bare y_types stage returns value
tryit("D.bare_returns_value", () -> (build(fed(BareScale())); :ok))
struct BareWrongRet <: AbstractComponent end
x_init(::BareWrongRet) = nothing
y_types(::BareWrongRet) = Float64
y_direct(::BareWrongRet, _) = (y = 1.0,)
tryit("D.bare_returns_nt", () -> build(single(BareWrongRet())))

# ---- E. handler return law ----
mutable struct dummy end
struct H1 <: AbstractComponent end
x_init(::H1) = (q = 1.0, w = 2.0)
m_init(::H1) = (phase = :a, n = 0)
y_types(::H1) = (o = Float64,)
y_state(::H1, (; x)) = (o = x.q,)
x_deriv(::H1, (; x)) = (q = 0.0, w = 0.0)
h1_guard(::H1, (; m, t)) = m.phase === :a && t ≥ 0.05
h1_handler(::H1, (; x, m)) = (m = (phase = :b,),)
state_events(::H1) = (e = StateEvent(h1_guard, h1_handler),)
tryit("E.merge_m", () -> (s = Simulation(single(H1()); Δt_frame = 1//10); init!(s); step!(s; frames = 2); modes(s, "c")))
struct H2 <: AbstractComponent end
x_init(::H2) = (q = 1.0, w = 2.0)
y_types(::H2) = (o = Float64,)
y_state(::H2, (; x)) = (o = x.q,)
x_deriv(::H2, _) = (q = 0.0, w = 0.0)
h2_guard(::H2, (; x, t)) = t ≥ 0.05
h2_handler(::H2, (; x)) = (x = (; x..., q = 0.0),)
state_events(::H2) = (e = StateEvent(h2_guard, h2_handler),)
tryit("E.x_reset", () -> (s = Simulation(single(H2()); Δt_frame = 1//10); init!(s); step!(s; frames = 1); state(s, "c")))
struct H3 <: AbstractComponent end
x_init(::H3) = (q = 1.0, w = 2.0)
y_types(::H3) = (o = Float64,)
y_state(::H3, (; x)) = (o = x.q,)
x_deriv(::H3, _) = (q = 0.0, w = 0.0)
state_events(::H3) = (e = StateEvent((c, b) -> b.t ≥ 0.05, (c, b) -> (x = (q = 0.0,),)),)
tryit("E.x_partial", () -> build(single(H3())))
struct H4 <: AbstractComponent end
x_init(::H4) = (q = 1.0,)
y_types(::H4) = (o = Float64,)
y_state(::H4, (; x)) = (o = x.q,)
x_deriv(::H4, _) = (q = 0.0,)
state_events(::H4) = (e = StateEvent((c, b) -> b.t ≥ 0.05, (c, b) -> (m = (a = 1,),)),)
tryit("E.key_no_store", () -> build(single(H4())))
struct H5 <: AbstractComponent end
x_init(::H5) = (q = 1.0,)
m_init(::H5) = (a = 1,)
y_types(::H5) = (o = Float64,)
y_state(::H5, (; x)) = (o = x.q,)
x_deriv(::H5, _) = (q = 0.0,)
state_events(::H5) = (e = StateEvent((c, b) -> b.t ≥ 0.05, (c, b) -> (m = (a = 1.0,),)),)
tryit("E.m_wrong_type", () -> build(single(H5())))
state_events(::H5) = (e = StateEvent((c, b) -> b.t ≥ 0.05, (c, b) -> (m = (b = 1,),)),)
tryit("E.m_unknown_field", () -> build(single(H5())))
# guard form
struct H6 <: AbstractComponent end
x_init(::H6) = (q = 1.0,)
y_types(::H6) = (o = Float64,)
y_state(::H6, (; x)) = (o = x.q,)
x_deriv(::H6, _) = (q = 0.0,)
state_events(::H6) = (e = StateEvent((c, b) -> 1, (c, b) -> (x = (q = 0.0,),)),)
tryit("E.guard_int", () -> build(single(H6())))
# handler bare store
tryit("E.bare_latch_run", () -> (s = Simulation(single(BareLatch()); Δt_frame = 1//10); init!(s); step!(s; frames = 12); (state(s, "c"), modes(s, "c"))))

# ---- F. misc ----
tryit("F.outputs_order", () -> (b = build(fed(Plant(), "u")); (typeof(b.outputs.order), b.outputs.order)))
tryit("F.stage12", () -> (b = build(fed(Plant(), "u")); (b.outputs.components[1].stage1, b.outputs.components[1].stage2)))
tryit("F.fanout", () -> (build(Group((; g = Gain(1.0), a = Gain(2.0), b = Gain(3.0)); input_wires = ("i" => "g/e",), local_wires = ("g/out" => "a/e", "g/out" => "b/e"))); :ok))
tryit("F.algebraic_loop", () -> build(Group((; a = Gain(1.0), b = Gain(1.0)); local_wires = ("a/out" => "b/e", "b/out" => "a/e"))))
struct Proj <: AbstractComponent end
x_init(::Proj) = (q = 1.0,)
y_types(::Proj) = (o = Float64,)
y_state(::Proj, (; x)) = (o = x.q,)
x_deriv(::Proj, _) = (q = 0.0,)
const PA = Ref{Any}(nothing)
x_projection(::Proj, x) = (PA[] = x; x)
tryit("F.projection", () -> (build(single(Proj())); PA[]))
tryit("F.alloc", () -> (sx = Simulation(fed(Plant(), "u"); Δt_frame = 1//10); init!(sx, set(u = (in = 1.0,))); m2 = sx.model; Redstone.evaluate!(m2); Redstone.evaluate!(m2); @allocated(Redstone.evaluate!(m2))))
show_r("F.value_level", [n for n in names(Redstone) if occursin("value", lowercase(string(n)))])
# ---- G. extras ----
tryit("G.illegal_for_family", () -> build(fed(IllegalFam(), "v")))
struct F32 <: AbstractComponent end
x_init(::F32) = nothing
y_types(::F32) = (a = Float64,)
y_direct(::F32, _) = (a = 1.0f0,)
tryit("G.float32_return", () -> build(single(F32())))
@enum Mode2 LOW HIGH
struct EnumP <: AbstractComponent end
x_init(::EnumP) = nothing
y_types(::EnumP) = (m = Mode2, s = @NamedTuple{m::Mode2, a::Float64})
y_direct(::EnumP, _) = (m = LOW, s = (m = HIGH, a = 1.0))
tryit("G.enum_port", () -> (build(single(EnumP())); (nleaves(Mode2), nleaves(@NamedTuple{m::Mode2, a::Float64}))))
# a stateless component legitimately writes y_direct with neither x nor m
show_r("G.stateless", Redstone.bundle_names(y_direct, Negator(), CONTINUOUS, ()))
# component with no stage-1 ports has no y_x; component with y_types and no inputs has no u
show_r("G.nou", Redstone.bundle_names(y_direct, BareRamp(), CONTINUOUS, ()))
# guard return sign scalar
tryit("G.guard_float", () -> (build(single(Bouncer(1.0, 0.5))); :ok))

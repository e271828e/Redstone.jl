# S8b verifier probes, run from the pinned worktree with --project=test.
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
include(joinpath(W, "utils.jl"))
import Redstone: retype, s_init, m_init, stop_reason, Requester

p(id, args...) = println(id, " | ", args...)
tryit(f) = try f() catch err err end
diag1(err) = err isa DiagnosticError ? diagnostics(err) : err

# --- fixtures local to the probe ---
struct FlagPub <: AbstractComponent end
x_init(::FlagPub) = nothing
y_types(::FlagPub) = (halt = StopFlag,)
y_state(::FlagPub, _) = (halt = NO_STOP,)

struct FlagPubR <: AbstractComponent end
x_init(::FlagPubR) = nothing
y_types(::FlagPubR) = (halt = StopFlag,)
y_state(::FlagPubR, _) = (halt = NO_STOP,)
stop_reason(::FlagPubR) = "fuel out"

struct FlagIn <: AbstractComponent end
x_init(::FlagIn) = nothing
u_types(::FlagIn) = (flag = StopFlag,)
y_types(::FlagIn) = (stopped = Bool,)
y_direct(::FlagIn, (; u)) = (stopped = u.flag === STOP_REQUESTED,)

struct DiscSrc <: AbstractComponent end
s_init(::DiscSrc) = (a = 1.0,)
y_types(::DiscSrc) = (y = Float64,)
y_state(::DiscSrc, (; s)) = (y = s.a,)
s_update(::DiscSrc, (; s)) = (a = s.a,)

abstract type AbsF end
struct F1 <: AbsF; a::Float64; end
struct F2 <: AbsF; b::Int; end
struct SrcF1 <: AbstractComponent end
x_init(::SrcF1) = nothing
y_types(::SrcF1) = (f = F1,)
y_direct(::SrcF1, _) = (f = F1(1.0),)
struct SrcF2 <: AbstractComponent end
x_init(::SrcF2) = nothing
y_types(::SrcF2) = (f = F2,)
y_direct(::SrcF2, _) = (f = F2(2),)
struct UseAbs <: AbstractComponent end
x_init(::UseAbs) = nothing
u_types(::UseAbs) = (f = AbsF,)
y_types(::UseAbs) = (y = Float64,)
y_direct(::UseAbs, (; u)) = (y = 1.0,)

struct WalkSrc <: AbstractComponent end
x_init(::WalkSrc) = (q = 0.0,)
y_types(::WalkSrc) = (out = Float64,)
y_state(::WalkSrc, (; x)) = (out = x.q,)
x_deriv(::WalkSrc, _) = (q = 1.0,)
struct PinSrc <: AbstractComponent end
x_init(::PinSrc) = nothing
y_types(::PinSrc) = (out = Pinned{Float64},)
y_direct(::PinSrc, (; t)) = (out = 1.0,)

struct Ranged{T,lo,hi}; v::T; end
struct Deck{T}; heave::T; grid::Matrix{Float64}; end

struct InnerPin <: AbstractComponent end
x_init(::InnerPin) = nothing
y_types(::InnerPin) = (a = SVector{2,Pinned{Float64}},)
y_direct(::InnerPin, _) = (a = SVector(1.0, 2.0),)

struct GCH; a::Float64; end
struct Hardcoded <: AbstractComponent end
x_init(::Hardcoded) = (q = 0.0,)
y_types(::Hardcoded) = (c = Pinned{GCH},)
y_state(::Hardcoded, (; x)) = (c = GCH(x.q),)
x_deriv(::Hardcoded, _) = (q = 1.0,)

struct Hard{T}; a::T; Hard(a::Float64) = new{Float64}(a); end
struct HardSrc <: AbstractComponent end
x_init(::HardSrc) = (q = 0.0,)
y_types(::HardSrc) = (c = Hard{Float64},)
y_state(::HardSrc, (; x)) = (c = Hard(x.q),)
x_deriv(::HardSrc, _) = (q = 1.0,)

annotated(x) = SVector(x, x, x)::SVector{3,Float64}
retann(x)::SVector{3,Float64} = SVector(x, x, x)

struct ModeFloat <: AbstractComponent end
x_init(::ModeFloat) = (q = 0.0,)
m_init(::ModeFloat) = (g = 1.0,)
y_types(::ModeFloat) = (g = Pinned{Float64},)
y_state(::ModeFloat, (; m)) = (g = m.g,)
x_deriv(::ModeFloat, _) = (q = 1.0,)

struct QWrap; w::SVector{4,Float64}; end
struct WrapState <: AbstractComponent end
x_init(::WrapState) = (q_nb = QWrap(SVector(1.0, 0.0, 0.0, 0.0)),)
x_deriv(::WrapState, (; x)) = x
y_types(::WrapState) = (y = Float64,)
y_state(::WrapState, _) = (y = 0.0,)
struct LabelStore <: AbstractComponent end
s_init(::LabelStore) = (label = "abc",)
s_update(::LabelStore, (; s)) = s
y_types(::LabelStore) = (y = Float64,)
y_state(::LabelStore, _) = (y = 0.0,)

struct PinVec <: AbstractComponent end
x_init(::PinVec) = nothing
u_types(::PinVec) = (v = Pinned{SVector{2,Float64}},)
y_types(::PinVec) = (y = Float64,)
y_direct(::PinVec, (; u)) = (y = u.v[1],)

D = ProbeDual

# S8b-012: a StopFlag input below the root is an ordinary input; at the root refused.
b = tryit(() -> build(Group((; a = FlagPub(), r = FlagIn()); local_wires = ("a/halt" => "r/flag",)); activations = (Float64, D)))
p("S8b-012", "below root: ", b isa Build ? "builds" : diag1(b))
b isa Build && p("S8b-012", "addr keys: ", sort!(collect(keys(activation(b, Float64).layout.addr)); by = string))
p("S8b-012", "at root: ", diag1(tryit(() -> build(Group((; r = FlagIn()); input_wires = ("s" => "r/flag",))))))

# S8b-021: an unpinned continuous entry admits a frozen discrete producer and a walking one.
p("S8b-021", "disc->Gain: ", typeof(tryit(() -> build(Group((; d = DiscSrc(), g = Gain(1.0)); local_wires = ("d/y" => "g/e",)); activations = (Float64, D)))))
p("S8b-021", "walk->Gain: ", typeof(tryit(() -> build(Group((; w = WalkSrc(), g = Gain(1.0)); local_wires = ("w/out" => "g/e",)); activations = (Float64, D)))))

# S8b-033: two concrete producer types behind one abstract face.
for src in (SrcF1(), SrcF2())
    p("S8b-033", typeof(src), ": ", typeof(tryit(() -> build(Group((; s = src, u = UseAbs()); local_wires = ("s/f" => "u/f",)); activations = (Float64, D)))))
end

# S8b-044: a pinned producer feeds an unpinned or a pinned entry; a walking one a pinned entry fails.
p("S8b-044", "pin->unpinned: ", typeof(tryit(() -> build(Group((; s = PinSrc(), g = Gain(1.0)); local_wires = ("s/out" => "g/e",)); activations = (Float64, D)))))
p("S8b-044", "pin->Pinned: ", typeof(tryit(() -> build(Group((; s = PinSrc(), g = PinnedGain()); local_wires = ("s/out" => "g/e",)); activations = (Float64, D)))))
p("S8b-044", "walk->Pinned: ", diag1(tryit(() -> build(Group((; s = WalkSrc(), g = PinnedGain()); local_wires = ("s/out" => "g/e",))))))

# S8b-053: a frozen handle arrives at an unpinned entry (wire); a literal handle at a walking port is refused (store).
r = tryit(() -> Model(offset_model(PinnedOffsetSource()), D8; Δt_frame = 1//10))
p("S8b-053", "pinned handle -> unpinned entry at D8: ", r isa Model ? "Model" : diag1(r))
r isa Model && (init!(r); p("S8b-053", "consumer read: ", typeof(port(r, "src", :terrain)), " ", typeof(port(r, "q", :h))))
p("S8b-053", "discrete handle: ", (x -> x isa Model ? "Model" : diag1(x))(tryit(() -> Model(offset_model(DiscreteOffsetSource()), D8; Δt_frame = 1//10))))
p("S8b-053", "literal at walking port: ", diag1(tryit(() -> Model(offset_model(OffsetAtLiteral()), D8; Δt_frame = 1//10))))

# S8b-062 / S8b-182: the lurking pin builds at nominal, fails at the first Dual activation, with the hint.
pb = build(single(PinnedState()))
p("S8b-062", "nominal build: ", typeof(pb))
e = tryit(() -> activation(pb, D8))
p("S8b-062", "D8 activation: ", typeof(e))
e isa DiagnosticError && p("S8b-182", "message: ", sprint(showerror, e))

# S8b-071 / S8b-167: what a Dual meets at a Float64 annotation and a hardcoded field.
d1 = ForwardDiff.Dual{Nothing}(1.0, 1.0)
p("S8b-071", "typeassert: ", typeof(tryit(() -> annotated(d1))))
er = tryit(() -> retann(d1)); p("S8b-071", "return annotation: ", typeof(er), " ", sprint(showerror, er)[1:min(end, 160)])
eg = tryit(() -> GCH(d1)); p("S8b-167", "GCH(dual): ", typeof(eg), " ", sprint(showerror, eg)[1:min(end, 160)])
eh = tryit(() -> build(single(Hardcoded()); activations = (Float64, D)))
p("S8b-167", "Pinned{GCH} stage at ProbeDual: ", typeof(eh))
eh isa DiagnosticError && p("S8b-167", sprint(showerror, eh)[1:min(end, 400)])
p("S8b-167", "ForwardDiff version: ", pkgversion(ForwardDiff))

# S8b-168: a type that cannot be built at the scalar fails at the Dual probe, named.
ehs = tryit(() -> build(single(HardSrc()); activations = (Float64, D)))
p("S8b-168", typeof(ehs))
ehs isa DiagnosticError && p("S8b-168", sprint(showerror, ehs)[1:min(end, 500)])

# S8b-073: the root-input type is the entry at Float64, markers stripped.
rb = build(Group((; c = PinnedGain()); input_wires = ("in" => "c/e",)))
p("S8b-073", "root types (Pinned{Float64} entry): ", rb.structure.root_types)
rb2 = build(Group((; c = PinVec()); input_wires = ("in" => "c/v",)))
p("S8b-073", "root types (SVector entry): ", rb2.structure.root_types)

# S8b-084: AbstractAtRoot message.
ea = tryit(() -> build(TerrainGain()))
p("S8b-084", diag1(ea) isa Vector ? sprint(showerror, ea) : ea)

# S8b-093: a tap on a Pinned root input is refused.
sim = Simulation(Group((; g = PinnedGain(), c = Pendulum()); local_wires = ("g/out" => "c/u",), input_wires = ("τ" => "g/e",)); Δt_frame = 1//10)
et = tryit(() -> linearize(sim, taps(u = (τ = get_input(:τ),)); about = set(u = (τ = 0.0,))))
p("S8b-093", diag1(et))

# S8b-102: the meet — a root input feeding an unpinned and a Pinned consumer pins at D.
mb = build(Group((; g = Gain(1.0), q = PinnedGain()); input_wires = ("in" => ("g/e", "q/e"))); activations = (Float64, D))
p("S8b-102", "mixed: ", activation(mb, D).layout.root_inputs)
ub = build(Group((; g = Gain(1.0), h = Gain(2.0)); input_wires = ("in" => ("g/e", "h/e"))); activations = (Float64, D))
p("S8b-102", "all tolerant: ", typeof.(last.(activation(ub, D).layout.root_inputs)))

# S8b-111 / S8b-121: the bare input at a primitive root is `u`, staged, traced and claimed by that name.
bb = build(BareScale())
p("S8b-111", "root inputs: ", bb.structure.root_inputs)
s2 = Simulation(BareScale(); Δt_frame = 1//10)
init!(s2, set(u = (u = 1.0,)))
stage!(s2, "u" => 2.0)
step!(s2; frames = 2)
p("S8b-111", "after stage: u=", port(s2, "", :u), " y=", port(s2, "", :y), " headless=", port(s2, ""))
p("S8b-111", "trace schemas: ", trace(s2).schemas)
s3 = Simulation(BareScale(); Δt_frame = 1//10)
init!(s3, set(u = (u = 1.0,)))
h = tryit(() -> attach!(s3, Pad("p"), Enumerated("u")))
p("S8b-111", "attach claim: ", typeof(h), " claimedby=", s3.run === nothing ? "-" : tryit(() -> s3.plane.claimedby))
p("S8b-121", "addr keys: ", sort!(collect(keys(activation(bb, Float64).layout.addr)); by = string))

# S8b-133 / S8b-143 / S8b-178: the walk.
p("S8b-133", retype(D8, Ranged{Float64,-1,1}), " | ", retype(D8, Ranged{Float64,-1.0,1.0}))
p("S8b-143", retype(D8, Deck{Float64}), " | ", retype(D8, OffsetField{Float64}))
p("S8b-178", retype(D8, Float64) === D8)

# S8b-154: a marker below the top of an entry.
p("S8b-154", diag1(tryit(() -> build(single(InnerPin())))))

# S8b-188: m_init and s_init pin wholesale.
p("S8b-188", "m Float64 at D: ", typeof(tryit(() -> build(single(ModeFloat()); activations = (Float64, D)))))
ab = build(single(DiscSrc()); activations = (Float64, D))
p("S8b-188", "s at D: ", typeof(activation(ab, D).decls[1].s))

# S8b-197 / S8b-200: the store-vocabulary messages.
ew = tryit(() -> build(single(WrapState())))
p("S8b-197", ew isa DiagnosticError ? sprint(showerror, ew) : ew)
el = tryit(() -> build(single(LabelStore())))
p("S8b-200", el isa DiagnosticError ? sprint(showerror, el) : el)

# S8b-204: stop_reason default and override, as the roster reads them.
rb3 = build(Group((; a = FlagPub(), b = FlagPubR())))
p("S8b-204", activation(rb3, Float64).layout.requesters, " | default: ", repr(stop_reason(Gain(1.0))))

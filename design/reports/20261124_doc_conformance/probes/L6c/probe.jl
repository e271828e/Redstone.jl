using Test, StaticArrays, LinearAlgebra, ForwardDiff
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/"
include(W * "imports.jl"); include(W * "fixtures.jl"); include(W * "utils.jl")
const L = Redstone.Library
P(tag, x) = println("PROBE[", tag, "] ", x)
dlist(e) = e isa DiagnosticError ? (e.carried isa Vector ? e.carried : [e.carried]) : []
desc(d) = string(typeof(d), hasproperty(d, :reason) ? " reason=" * string(d.reason) : "")
errkind(f) = try f(); "builds" catch e; e isa DiagnosticError ? join(desc.(dlist(e)), "; ") : string(typeof(e), ": ", sprint(showerror, e)[1:min(end,200)]) end

# --- components
struct Pass2 <: AbstractComponent end
x_init(::Pass2) = nothing
u_types(::Pass2) = (u = Float64,)
y_types(::Pass2) = (y = Float64,)
y_direct(::Pass2, (; u)) = (y = u.u,)

struct WRet <: AbstractComponent end
x_init(::WRet) = nothing
u_types(::WRet) = (u = Float64,)
y_types(::WRet) = (y = Float64,)
y_direct(::WRet, (; u)) = ((y = u.u,), (w = 1.0,))

struct Dead <: AbstractComponent end
x_init(::Dead) = nothing
u_types(::Dead) = (u = Float64,)
y_types(::Dead) = (y = Float64,)
y_direct(::Dead, (; u)) = (;)

struct MutPort <: AbstractComponent end
x_init(::MutPort) = nothing
y_types(::MutPort) = (y = Vector{Float64},)
y_state(::MutPort, _) = (y = [1.0],)

struct Handle; data::Vector{Float64}; k::Float64; end
struct HandleSrc <: AbstractComponent end
x_init(::HandleSrc) = nothing
y_types(::HandleSrc) = (h = Pinned{Handle},)
y_state(::HandleSrc, _) = (h = Handle([1.0, 2.0], 3.0),)
struct HandleUse <: AbstractComponent end
x_init(::HandleUse) = nothing
u_types(::HandleUse) = (h = Handle,)
y_types(::HandleUse) = (y = Float64,)
y_direct(::HandleUse, (; u)) = (y = u.h.k + u.h.data[2],)

struct SymSrc <: AbstractComponent end
x_init(::SymSrc) = nothing
y_types(::SymSrc) = (s = Symbol,)
y_state(::SymSrc, _) = (s = :hello,)
struct SymUse <: AbstractComponent end
x_init(::SymUse) = nothing
u_types(::SymUse) = (s = Symbol,)
y_types(::SymUse) = (y = Float64,)
y_direct(::SymUse, (; u)) = (y = u.s === :hello ? 1.0 : 0.0,)

struct Nest; f::StopFlag; v::Float64; end
struct NestOut <: AbstractComponent end
x_init(::NestOut) = nothing
y_types(::NestOut) = (n = Nest,)
y_state(::NestOut, _) = (n = Nest(NO_STOP, 1.0),)
struct FlagIn <: AbstractComponent end
x_init(::FlagIn) = nothing
u_types(::FlagIn) = (f = StopFlag,)
y_types(::FlagIn) = (y = Float64,)
y_direct(::FlagIn, (; u)) = (y = u.f === STOP_REQUESTED ? 1.0 : 0.0,)

struct Flagger <: AbstractComponent end   # no stop_reason
x_init(::Flagger) = (q = 0.0,)
y_types(::Flagger) = (a = StopFlag, b = StopFlag)
y_state(::Flagger, (; x)) = (a = x.q > 0.05 ? STOP_REQUESTED : NO_STOP, b = NO_STOP)
x_deriv(::Flagger, _) = (q = 1.0,)

struct BoolOut <: AbstractComponent end
x_init(::BoolOut) = (q = 0.0,)
y_types(::BoolOut) = (done = Bool,)
y_state(::BoolOut, (; x)) = (done = x.q > 0.05,)
x_deriv(::BoolOut, _) = (q = 1.0,)

# 1 D-005 loops
P("loop_direct", errkind(() -> build(Group((; a = Pass2(), b = Pass2()); local_wires = ("a/y" => "b/u", "b/y" => "a/u")))))
P("loop_via_state", errkind(() -> build(Group((; p = Plant(), n = Negator()); local_wires = ("p/y" => "n/u", "n/y" => "p/u")))))
e = failure(() -> build(Group((; a = Pass2(), b = Pass2()); local_wires = ("a/y" => "b/u", "b/y" => "a/u"))))
d = first(dlist(e)); P("cycle_fields", (d.members, d.wires, d.classification, d.traced))

# 2 D-194
P("w_return", errkind(() -> build(Group((; k = Constant(1.0), w = WRet()); local_wires = ("k/y" => "w/u",)))))
P("dead_stage", errkind(() -> build(Group((; k = Constant(1.0), w = Dead()); local_wires = ("k/y" => "w/u",)))))
P("w_field", (classify_bundle_field(:y_direct, CONTINUOUS, :w), classify_bundle_field(:x_deriv, CONTINUOUS, :y), classify_bundle_field(:y_direct, CONTINUOUS, :y)))
P("Private_defined", isdefined(Redstone, :Private))

# 3 D-237 / D-243
P("mut_port", errkind(() -> build(MutPort())))
P("mutable_position", (Redstone.mutable_position(Vector{Float64}), Redstone.mutable_position(Handle), Redstone.mutable_position(Symbol), Redstone.mutable_position(SVector{2,Base.RefValue{Int}})))
P("handle_wire", errkind(() -> begin
    m = Model(Group((; s = HandleSrc(), u = HandleUse()); local_wires = ("s/h" => "u/h",)); Δt_frame = 1//10)
    init!(m, set()); port(m, "u", :y) end))
m = Model(Group((; s = HandleSrc(), u = HandleUse()); local_wires = ("s/h" => "u/h",)); Δt_frame = 1//10); init!(m, set())
P("handle_cell", (port(m, "u", :y), typeof(port(m, "s", :h)), Redstone.leaf_types(Handle)))
P("handle_at_root", errkind(() -> build(Group((; u = HandleUse()); input_wires = ("h" => "u/h",)))))
P("sym_wire", errkind(() -> begin m2 = Model(Group((; s = SymSrc(), u = SymUse()); local_wires = ("s/s" => "u/s",)); Δt_frame = 1//10); init!(m2, set()); (port(m2, "u", :y), port(m2, "s", :s), Redstone.leaf_types(Symbol)) end))
P("sym_at_root", errkind(() -> build(Group((; u = SymUse()); input_wires = ("s" => "u/s",)))))
P("sym_step", errkind(() -> begin m2 = Model(Group((; s = SymSrc(), u = SymUse()); local_wires = ("s/s" => "u/s",)); Δt_frame = 1//10); Redstone._compile_reads(reads(a = get_output("s", "s.x")), m2.deployment.build) end))

# 4 D-316
P("nested_flag", errkind(() -> build(NestOut())))
P("flag_at_root", errkind(() -> build(Group((; f = FlagIn()); input_wires = ("f" => "f/f",)))))
P("flag_input_ok", errkind(() -> build(Group((; s = Flagger(), f = FlagIn()); local_wires = ("s/a" => "f/f",)))))
b = build(Group((; s = Flagger(), r = StopRequest(reason = "why"), k = Constant(true)); local_wires = ("k/y" => "r/u",)))
P("requesters", activation(b, Float64).layout.requesters)
P("stop_reason_default", (stop_reason(Flagger()), stop_reason(StopRequest())))
P("stopreq_contract", (u_types(StopRequest()), y_types(StopRequest()), has_stage(y_direct, StopRequest()), has_stage(y_state, StopRequest())))
sim = Simulation(Group((; s = Flagger(), b2 = BoolOut()); output_wires = ("b2/done" => "done",)); Δt_frame = 1//100)
init!(sim, set())
P("bad_ignore", errkind(() -> step!(sim; t_plus = 0.01, ignore_stop_requests = ("zz", "s", "s", "yy"))))
e = failure(() -> step!(sim; t_plus = 0.01, ignore_stop_requests = ("zz", "yy")))
P("bad_ignore_fields", [(d.path, d.site, d.candidates) for d in dlist(e)])
P("stop_on_kw", errkind(() -> step!(sim; t_plus = 0.01, stop_on = ("done",))))
P("run_stop", (run!(sim; t_end = 1.0), termination(sim)))
sim2 = Simulation(Group((; s = Flagger(), b2 = BoolOut()); output_wires = ("b2/done" => "done",)); Δt_frame = 1//100)
init!(sim2, set())
run!(sim2; t_end = 0.2, ignore_stop_requests = :all)
P("run_ignored", termination(sim2))
sim3 = Simulation(Group((; b2 = BoolOut()); output_wires = ("b2/done" => "done",)); Δt_frame = 1//100)
init!(sim3, set()); run!(sim3; t_end = 0.2)
P("bool_face_stops_nothing", termination(sim3))
P("dup_collapse", Redstone._ignored_requests(activation(b, Float64).layout, ("s", "r", "s"); site = :run!))
P("StopFaceInvalid_defined", isdefined(Redstone, :StopFaceInvalid))

# 5 D-276
m = Model(bare_world(); Δt_frame = 1//100); init!(m, set(u = (u = 0.5, p = 0.1)))
r = Redstone._compile_reads(reads(a = get_state("plant", :q), b = get_state("plant", "q"), c = get_state("plant", "q[2]")), m.deployment.build)
P("sym_short", Redstone.gather_reads(r, m.exec))
P("trailing_index", errkind(() -> get_output("plant", "y", 2)))
P("store_step_dot", errkind(() -> Redstone._compile_reads(reads(a = get_state("plant", "q.x")), m.deployment.build)))
P("leaf_names_matrix", Redstone.leaf_names(SMatrix{2,2,Float64,4}))

# 6 D-363 field projection wire
struct PoseOut <: AbstractComponent end
x_init(::PoseOut) = nothing
struct Pz; v::Float64; w::Float64; end
y_types(::PoseOut) = (pose = Pz,)
y_state(::PoseOut, _) = (pose = Pz(1.0, 2.0),)
P("field_wire_detail", (e = failure(() -> build(Group((; p = PoseOut(), n = Negator()); local_wires = ("p/pose.v" => "n/u",)))); [(typeof(d), hasproperty(d,:port) ? d.port : nothing, hasproperty(d,:candidates) ? d.candidates : nothing) for d in dlist(e)]))
P("field_wire", errkind(() -> build(Group((; p = PoseOut(), n = Negator()); local_wires = ("p/pose.v" => "n/u",)))))

# 7 D-206 uninitialized inputs, D-437 bare_at_root retired
P("uninit", errkind(() -> begin mm = Model(bare_world(); Δt_frame = 1//100); init!(mm, set()) end))
P("bare_root", errkind(() -> build(BareScale())))

# 8 D-137 log_max keyword on Simulation
P("log_max_sim", errkind(() -> Simulation(Plant(); Δt_frame = 1//10, log_max = 10)))
P("log_max_init", errkind(() -> begin s = Simulation(Group((; p = Plant()); input_wires = ("u" => "p/u",)); Δt_frame = 1//10); init!(s, set(u = (u = 0.0,)); log_max = 10) end))

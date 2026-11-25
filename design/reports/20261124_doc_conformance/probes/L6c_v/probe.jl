# L6c_v probes, run from W with --project=test
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
include(joinpath(W, "test/imports.jl"))
include(joinpath(W, "test/fixtures.jl"))
include(joinpath(W, "test/utils.jl"))
import Redstone: resolve_leaf, _at_port, StopFlag, STOP_REQUESTED, NO_STOP

pr(id, x) = println(id, " => ", x)
function tryd(f)
    try
        r = f(); return (:ok, r)
    catch e
        e isa DiagnosticError && return (:diag, [(typeof(d), hasproperty(d, :reason) ? d.reason : nothing) for d in diagnostics(e)], e)
        return (:err, typeof(e), sprint(showerror, e)[1:min(end, 300)])
    end
end

# L6c-001 algebraic loop
r = tryd(() -> build(Group((; a = BareScale(), b = BareScale()); local_wires = ("a/y" => "b/u", "b/y" => "a/u"))))
pr("L6c-001", r[1:2])

# L6c-051/052 log_max
struct Decay <: AbstractComponent end
x_init(::Decay) = 1.0
y_types(::Decay) = Float64
y_state(::Decay, (; x)) = x
x_deriv(::Decay, (; x)) = -x
sim = Simulation(Decay(); Δt_frame = 1//10)
init!(sim; log_max = 4)
step!(sim; frames = 50)
pr("L6c-051 live/len(logged)", (sim.run.log.live, length(logged(sim)), sim.run.log.stride))
pr("L6c-052 Simulation(log_max)", tryd(() -> Simulation(Decay(); Δt_frame = 1//10, log_max = 4))[1:2])

# L6c-082/083 opaque leaf identity at a store vs wire
D = ForwardDiff.Dual{Nothing,Float64,1}
pr("L6c-082 _accepts store", _accepts(OffsetField{D}, OffsetField{Float64}, D, false))
pr("L6c-083 _accepts wire", _accepts(OffsetField{D}, OffsetField{Float64}, D, true))

# L6c-085 handle-typed root input
pr("L6c-085", tryd(() -> build(OffsetQuery()))[1:2])

# L6c-095 trailing index retired
pr("L6c-095", tryd(() -> get_output("a", "b", 1))[1:2])

# L6c-104 index steps
pr("L6c-104 vec[1,2]", resolve_leaf(SVector{3,Float64}, ((1, 2),)))
pr("L6c-104 mat[1,2]", resolve_leaf(SMatrix{2,2,Float64,4}, ((1, 2),)))
pr("L6c-104 mat[3]", resolve_leaf(SMatrix{2,2,Float64,4}, ((3,),)))
pr("L6c-104 tuple[1]", resolve_leaf(Tuple{Float64,Float64}, ((1,),)))

# L6c-113 field endpoint
struct PoseSrc <: AbstractComponent end
x_init(::PoseSrc) = nothing
y_types(::PoseSrc) = (pose = SVector{2,Float64},)
y_state(::PoseSrc, _) = (pose = SVector(1.0, 2.0),)
r = tryd(() -> build(Group((; src = PoseSrc(), g = BareScale()); local_wires = ("src/pose[1]" => "g/u",))))
pr("L6c-113 index endpoint", r[1:2])
struct NTSrc <: AbstractComponent end
x_init(::NTSrc) = nothing
y_types(::NTSrc) = (pose = NamedTuple{(:a, :b),Tuple{Float64,Float64}},)
y_state(::NTSrc, _) = (pose = (a = 1.0, b = 2.0),)
r = tryd(() -> build(Group((; src = NTSrc(), g = BareScale()); local_wires = ("src/pose.a" => "g/u",))))
pr("L6c-113 field endpoint", r[1:2])

# L6c-122/159/150 stop requests
ramp_request(level, reason) =
    Group((; src = Ramp(0.0), trig = Trigger(level), stop = StopRequest(reason = reason));
          local_wires = ("src/out" => "trig/sig", "trig/on" => "stop/u"))
two(la, lb) = Group((; a = ramp_request(la, "a at level"), b = ramp_request(lb, "b at level")))
sim = Simulation(two(0.3, 0.3); Δt_frame = 1//10); init!(sim); run!(sim; t_end = 2.0)
tr = termination(sim); pr("L6c-159 both", (tr.t, tr.source))
sim = Simulation(two(0.3, 0.3); Δt_frame = 1//10); init!(sim); run!(sim; t_end = 2.0, ignore_stop_requests = ["a/stop"])
tr = termination(sim); pr("L6c-150 ignore a", (tr.t, tr.source))
sim = Simulation(two(0.3, 0.3); Δt_frame = 1//10); init!(sim); step!(sim; frames = 30, ignore_stop_requests = :all)
pr("L6c-150 step! :all", (latest(sim).t, termination(sim)))
pr("L6c-150 roster", sim.model.exec.act.layout.requesters)

# L6c-131 StopFlag input below root
struct FlagSink <: AbstractComponent end
x_init(::FlagSink) = nothing
u_types(::FlagSink) = (f = StopFlag,)
y_types(::FlagSink) = (b = Bool,)
y_direct(::FlagSink, (; u)) = (b = u.f === STOP_REQUESTED,)
r = tryd(() -> build(Group((; src = Ramp(0.0), trig = Trigger(0.3), stop = StopRequest(), sink = FlagSink());
                           local_wires = ("src/out" => "trig/sig", "trig/on" => "stop/u", "stop/y" => "sink/f"))))
pr("L6c-131", r[1])
r = tryd(() -> build(FlagSink()))
pr("L6c-131 at root", r[1:2])

# L6c-144/186 faces
pr("L6c-144 StopRequest faces", (input_faces(StopRequest()), output_faces(StopRequest())))
pr("L6c-186 BareScale faces", (input_faces(BareScale()), output_faces(BareScale())))

# L6c-195 bare u at primitive root
b = build(BareScale())
pr("L6c-195 root_inputs", b.structure.root_inputs)
m = Model(BareScale(); Δt_frame = 1//10); init!(m, set(u = (u = 1.5,)))
pr("L6c-195 port", port(m, ""))

# L6c-204 headless reads
struct LeafPose{T}
    v::SVector{3,T}
    m::SMatrix{2,2,T,4}
end
Redstone.probe_value(::Type{LeafPose{T}}) where {T} = LeafPose(zero(SVector{3,T}), zero(SMatrix{2,2,T,4}))
struct BarePoseHold <: AbstractComponent end
s_init(::BarePoseHold) = LeafPose(SVector(1.0, 2.0, 3.0), SMatrix{2,2}(5.0, 6.0, 7.0, 8.0))
u_types(::BarePoseHold) = LeafPose{Float64}
y_types(::BarePoseHold) = SMatrix{2,2,Float64,4}
y_state(::BarePoseHold, (; s)) = s.m
s_update(::BarePoseHold, (; s)) = s
root = Model(BarePoseHold(); Δt_frame = 1//10)
init!(root, set(u = (u = LeafPose(SVector(0.1, 0.2, 0.3), SMatrix{2,2}(0.0, 0.0, 0.0, 0.0)),)))
r = _compile_reads(reads(f = get_input(".v[2]"), g = get_face("[1,2]"), w = get_face()), root.deployment.build)
pr("L6c-204 at primitive root", gather_reads(r, root.exec))

# L6c-213 rendering
r = tryd(() -> build(Group((; plant = Group((; a = Decay(), b = Decay(), c = BareScale()); local_wires = ("a/y" => "c/u", "b/y" => "c/u"))))))
if r[1] === :diag
    for d in diagnostics(r[3]); println("L6c-213 msg: ", message(d)); end
end
pr("L6c-213 _at_port", _at_port("plant/integrator", :y))

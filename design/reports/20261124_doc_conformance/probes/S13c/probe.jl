using Test, StaticArrays, ForwardDiff
using Base.CoreLogging: with_logger, Warn
using Redstone
import Redstone: trace, diagnostic, AbstractComponent, AbstractDevice, AbstractBinding, Group, Pinned, build, x_init, s_init, u_types,
    y_types, y_direct, y_state, s_update, x_deriv, local_wires, input_wires, output_wires, input_passthrough,
    DiagnosticError, diagnostics, AlgebraicCycle, message, StepError, LoopError, Tracer, activation, ProbeDual,
    Simulation, init!, run!, step!, lifecycle, termination, latest, logged, attach!, detach!, stage!, set, loop,
    running, wait_next_snapshot, unblock!, shutdown!, is_input, claims, state, descriptor, linearize, taps,
    trim!, face_routes, index_of, AbstractAtRoot
import Redstone.Library: Junction, SumJunction, Or, And, Constant, Freeze, UnitDelay, StopRequest, Step, Relay

macro p(label, ex)
    quote
        local v = try $(esc(ex)) catch e; (:THROW, typeof(e), e isa DiagnosticError ? [typeof(d) for d in diagnostics(e)] : nothing) end
        println("probe:", $(__source__.line), " ", $label, " => ", v)
        v
    end
end
function failure(f)
    try; f(); nothing; catch err; err; end
end
show_text(x) = sprint(show, MIME"text/plain"(), x)

println("=== library shapes")
@p "SumJunction u_types" u_types(SumJunction{Float64,3}())
@p "SumJunction y_types" y_types(SumJunction{Float64,3}())
@p "Or u_types" u_types(Or{3}())
@p "And fold" And{2}().f
@p "Or fold" Or{2}().f
@p "SumJunction fold" SumJunction{Float64,2}().f
@p "custom fold inferred F" typeof(Junction{Float64,Float64,2}((a, b) -> 0.3a + 0.7b))
@p "Or is Junction alias" Or{3} <: Junction
@p "x_init Junction" x_init(SumJunction{Float64,2}())
@p "Constant y_types" y_types(Constant(1.0))
@p "Constant y_types struct" y_types(Constant((1, 2)))
@p "Constant fields" fieldnames(Constant)
@p "Constant y_state" y_state(Constant(3.0), (;))
@p "Constant x_init" x_init(Constant(1.0))
@p "Constant u_types defined?" hasmethod(u_types, Tuple{Constant{Float64}})
@p "UnitDelay s_init" s_init(UnitDelay(2.0))
@p "UnitDelay u/y types" (u_types(UnitDelay(2.0)), y_types(UnitDelay(2.0)))
@p "UnitDelay y_state" y_state(UnitDelay(2.0), (; s = 5.0))
@p "UnitDelay s_update" s_update(UnitDelay(2.0), (; u = 7.0))
@p "Freeze V Float32" failure(() -> Freeze{Float32}())
@p "Freeze V MVector" failure(() -> Freeze{MVector{2,Float64}}())
@p "Freeze V struct" failure(() -> Freeze{typeof((a = 1.0,))}())
@p "Freeze V SVector ok" Freeze{SVector{2,Float64}}()
@p "Freeze V SMatrix ok" Freeze{SMatrix{2,2,Float64,4}}()
@p "Freeze strip scalar" y_direct(Freeze{Float64}(), (; u = ForwardDiff.Dual(1.0, 1.0)))
@p "Freeze strip svec" y_direct(Freeze{SVector{2,Float64}}(), (; u = SVector(ForwardDiff.Dual(1.0, 1.0), ForwardDiff.Dual(2.0, 1.0))))
@p "Freeze nominal identity" y_direct(Freeze{Float64}(), (; u = 3.0))
@p "Freeze types" (u_types(Freeze{Float64}()), y_types(Freeze{Float64}()))
@p "Library names include Group?" isdefined(Redstone.Library, :Group)
@p "Library module" parentmodule(Redstone.Library.Constant)
@p "StopRequest y_types" y_types(StopRequest())
@p "StopFlag type" Redstone.StopFlag
@p "StopFlag enum" Redstone.StopFlag <: Enum
@p "Step y_types" nothing
@p "Relay y_types" y_types(Relay(0.0, 0.0, 0.0, 1.0))

println("=== UnitDelay build / tier / D / no zero")
struct NoZero; a::Float64; b::Int; end
@p "NoZero zero?" hasmethod(zero, Tuple{Type{NoZero}})
ud_model = Group((; k = Constant(NoZero(1.0, 2)), d = UnitDelay(NoZero(1.0, 2))); local_wires = ("k/y" => "d/u",), output_wires = ("d/y" => "out",))
ud_build = @p "UnitDelay NoZero build" build(ud_model)
if ud_build isa Redstone.Build
    println(show_text(ud_build.structure))
    @p "UnitDelay timing" ud_build.structure.components[1].timing
    @p "UnitDelay tier" ud_build.structure.components[1].tier
end
@p "UnitDelay non-isbits" failure(() -> build(Group((; d = UnitDelay("abc")); input_wires = ("in" => "d/u",))))
@p "UnitDelay Vector" failure(() -> build(Group((; d = UnitDelay([1.0])); input_wires = ("in" => "d/u",))))

println("=== show routes")
struct Mon <: AbstractComponent end
x_init(::Mon) = nothing
u_types(::Mon) = (a = Float64,)
y_types(::Mon) = (out = Float64,)
y_direct(::Mon, (; u)) = (out = 2 * u.a,)
struct PinC <: AbstractComponent end
x_init(::PinC) = nothing
u_types(::PinC) = (a = Pinned{Float64},)
y_types(::PinC) = (out = Float64,)
y_direct(::PinC, (; u)) = (out = u.a,)
aircraft = Group((; monitor = Mon(), m2 = Mon()); input_wires = ("a" => ("monitor/a", "m2/a"),), output_wires = ("monitor/out" => "crashed", "m2/out" => "c2"))
root = Group((; aircraft = aircraft, other = Mon(), pin = PinC(), dly = UnitDelay(0.0));
             input_wires = ("ref" => "aircraft/a", "ref3" => "pin/a", "ref4" => "dly/u", "ref5" => "other/a"),
             output_wires = ("aircraft/crashed" => "crashed", "aircraft/c2" => "c2", "other/out" => "o2", "dly/y" => "d"))
rb = @p "routes build" build(root)
rb isa Redstone.Build || println(message(diagnostics(failure(() -> build(root)))[1]))
if rb isa Redstone.Build
    println(show_text(rb.structure))
    println(show(IOBuffer(), rb.structure))
    @p "compact show" sprint(show, rb.structure)
end
# primitive root
pb = build(Mon())
println(show_text(pb.structure))
@p "primitive root pin descriptor" try
    d = descriptor(pb); d
catch e
    e
end

println("=== cycles")
struct Neg <: AbstractComponent end
x_init(::Neg) = nothing
u_types(::Neg) = Float64
y_types(::Neg) = Float64
y_direct(::Neg, (; u)) = -2.0 * u
struct Mute <: AbstractComponent end
x_init(::Mute) = nothing
u_types(::Mute) = Float64
y_types(::Mute) = Float64
y_direct(::Mute, (; u)) = 1.0
struct Branchy <: AbstractComponent end
x_init(::Branchy) = nothing
u_types(::Branchy) = Float64
y_types(::Branchy) = Float64
y_direct(::Branchy, (; u)) = u > 0 ? u : 0.5 * u
struct Sq <: AbstractComponent end
x_init(::Sq) = nothing
u_types(::Sq) = Float64
y_types(::Sq) = Float64
y_direct(::Sq, (; u)) = u^2
struct Clp <: AbstractComponent end
x_init(::Clp) = nothing
u_types(::Clp) = Float64
y_types(::Clp) = Float64
y_direct(::Clp, (; u)) = clamp(100.0 * u, -1.0, 1.0)
struct ModeBr <: AbstractComponent end
x_init(::ModeBr) = (q = 1.0,)
u_types(::ModeBr) = Float64
y_types(::ModeBr) = Float64
y_direct(::ModeBr, (; x, u)) = x.q > 0 ? u : 0.0
x_deriv(::ModeBr, (; x, u)) = (q = 0.0,)
struct Two <: AbstractComponent end
x_init(::Two) = nothing
u_types(::Two) = (p = Float64, q = Float64)
y_types(::Two) = (o = Float64,)
y_direct(::Two, (; u)) = (o = 2 * u.p,)
struct Thrower <: AbstractComponent end
x_init(::Thrower) = nothing
u_types(::Thrower) = Float64
y_types(::Thrower) = Float64
y_direct(::Thrower, (; u)) = u isa Tracer ? error("boom") : u
struct DGain <: AbstractComponent end
s_init(::DGain) = 0.0
u_types(::DGain) = Float64
y_types(::DGain) = Float64
y_direct(::DGain, (; u)) = 3.0 * u
s_update(::DGain, (; u)) = u
struct Int_ <: AbstractComponent end    # nearest-neighbor lookup blind spot
x_init(::Int_) = nothing
u_types(::Int_) = Float64
y_types(::Int_) = Float64
y_direct(::Int_, (; u)) = [1.0, 2.0, 3.0][clamp(round(Int, u) + 2, 1, 3)]

loop2(a, b) = Group((; a = a, b = b); local_wires = ("a/y" => "b/u", "b/y" => "a/u"))
function cyc(model)
    e = failure(() -> build(model))
    e isa DiagnosticError ? diagnostics(e) : e
end
for (label, m) in (("real Neg/Neg", loop2(Neg(), Neg())), ("artificial Neg/Mute", loop2(Neg(), Mute())),
                   ("branchy", loop2(Neg(), Branchy())), ("square", loop2(Neg(), Sq())), ("clamp", loop2(Neg(), Clp())),
                   ("modebranch", loop2(Neg(), ModeBr())), ("thrower", loop2(Neg(), Thrower())),
                   ("discrete member", loop2(Neg(), DGain())), ("int-sever", loop2(Neg(), Int_())))
    ds = cyc(m)
    println("probe: ", label, " => ", ds isa Vector ? [(typeof(d), d.classification, d.dead, d.traced) for d in ds] : ds)
    ds isa Vector && foreach(d -> println("   msg: ", message(d)), ds)
end
# dead hop under a real verdict
m2 = Group((; m = Two(), a = Neg()); local_wires = ("m/o" => "a/u", "a/y" => "m/p", "a/y" => "m/q"))
ds = cyc(m2)
println("probe: real+dead => ", [(d.classification, d.dead, d.traced) for d in ds])
foreach(d -> println("   msg: ", message(d)), ds)
# self loop and two clusters
m3 = Group((; a = Neg(), b = Neg(), c = Neg(), d = Mute(), e = Neg()); local_wires = ("a/y" => "a/u", "b/y" => "c/u", "c/y" => "b/u", "d/y" => "e/u"), input_wires = ("in" => "d/u",))
ds = cyc(m3)
println("probe: clusters => ", [(d.members, d.wires, d.classification) for d in ds])
@p "diagnostic carrier kinds" (failure(() -> build(m3)) |> e -> (typeof(e), [Redstone.kinds(e)...]))
# three-member cycle in slash form, spec example shape
m4 = Group((; aero = Two(), dyn = Two()); local_wires = ("aero/o" => "dyn/p", "dyn/o" => "aero/p", "aero/o" => "dyn/q", "dyn/o" => "aero/q"))
ds = cyc(m4); foreach(d -> println("   m4 msg: ", message(d)), ds)
println("probe: m4 => ", [(d.members, d.wires, d.dead, d.classification) for d in ds])

println("=== rig")
abstract type AbstractTerrainField end
struct SampleTerrainField <: AbstractTerrainField; h0::Float64; end
struct Strut <: AbstractComponent end
x_init(::Strut) = nothing
u_types(::Strut) = (terrain = AbstractTerrainField, k = Float64)
y_types(::Strut) = (h = Float64,)
y_direct(::Strut, (; u)) = (h = u.terrain.h0 * u.k,)
@p "Strut alone" failure(() -> build(Strut()))
struct StrutRig <: AbstractComponent
    strut::Strut
    stub::Constant{SampleTerrainField}
end
local_wires(::StrutRig) = ("stub/out" => "strut/terrain",)
input_wires(rig::StrutRig) = (input_passthrough(rig, "strut"; except = ("terrain",))...,)
@p "rig as spec (stub/out)" failure(() -> build(StrutRig(Strut(), Constant(SampleTerrainField(1.5)))))
struct StrutRig2 <: AbstractComponent
    strut::Strut
    stub::Constant{SampleTerrainField}
end
local_wires(::StrutRig2) = ("stub/y" => "strut/terrain",)
input_wires(rig::StrutRig2) = (input_passthrough(rig, "strut"; except = ("terrain",))...,)
rb2 = @p "rig with stub/y" failure(() -> build(StrutRig2(Strut(), Constant(SampleTerrainField(1.5)))))
rb2 = build(StrutRig2(Strut(), Constant(SampleTerrainField(1.5))))
println(show_text(rb2.structure))
@p "rig root inputs" rb2.structure.root_inputs
@p "rig size of input_wires" input_wires(StrutRig2(Strut(), Constant(SampleTerrainField(1.5))))
@p "design_world exists" isdefined(Redstone, :design_world)

println("=== Freeze through build")
struct Walker <: AbstractComponent end
x_init(::Walker) = nothing
u_types(::Walker) = Float64
y_types(::Walker) = Float64
y_direct(::Walker, (; u)) = 2 * u
fz_bad = Group((; w = Walker(), p = PinC()); input_wires = ("in" => "w/u",), local_wires = ("w/y" => "p/a",))
@p "walker to pinned (no freeze)" cyc(fz_bad)
fz_ok = Group((; w = Walker(), f = Freeze{Float64}(), p = PinC()); input_wires = ("in" => "w/u",), local_wires = ("w/y" => "f/u", "f/y" => "p/a"))
fb = @p "walker→freeze→pinned" build(fz_ok)
if fb isa Redstone.Build
    @p "dual activation ok" typeof(activation(fb, ProbeDual))
end
@p "freeze at struct" failure(() -> build(Group((; f = Freeze{Float64}()); input_wires = ("in" => "f/u",), output_wires = ("f/y" => "o",))))

println("=== §13.6 abnormal shutdown")
struct Exploder <: AbstractComponent end
struct Exploded <: Exception end
x_init(::Exploder) = (q = 0.0,)
u_types(::Exploder) = (arm = Bool,)
y_types(::Exploder) = (q = Float64,)
y_state(::Exploder, (; x)) = (q = x.q,)
x_deriv(::Exploder, (; x, u)) = u.arm ? throw(Exploded()) : (q = one(x.q),)
mutable struct Bad <: AbstractDevice; log::Vector{Symbol}; end
Redstone.init!(d::Bad) = (push!(d.log, :init); nothing)
loop(d::Bad, h) = (while running(h); wait_next_snapshot(h); end; push!(d.log, :loop_end); nothing)
unblock!(d::Bad) = (push!(d.log, :unblock); error("unblock boom"))
shutdown!(d::Bad) = (push!(d.log, :shutdown); error("shutdown boom"))
mutable struct Probe <: AbstractDevice; log::Vector{Symbol}; end
Redstone.init!(d::Probe) = (push!(d.log, :init); nothing)
loop(d::Probe, h) = (while running(h); wait_next_snapshot(h); end; push!(d.log, :loop_end); nothing)
shutdown!(d::Probe) = (push!(d.log, :shutdown); nothing)
unblock!(d::Probe) = (push!(d.log, :unblock); nothing)
struct NoClaim <: AbstractBinding end
is_input(::NoClaim) = true
claims(::NoClaim) = ()
fed(c, face) = Group((; c = c); input_wires = ("in" => "c/$face",))
sim = Simulation(fed(Exploder(), "arm"); Δt_frame = 1//10)
bad, pr = Bad(Symbol[]), Probe(Symbol[])
attach!(sim, bad, NoClaim()); attach!(sim, pr, NoClaim())
init!(sim, set(u = (in = false,)))
step!(sim; frames = 2)
stage!(sim, "in" => true)
logs = Test.TestLogger(min_level = Warn)
with_logger(logs) do
    run!(sim; t_end = 5.0)
end
println("probe: lifecycle => ", lifecycle(sim))
rec = termination(sim)
println("probe: source => ", typeof(rec.source), " ", typeof(rec.source.exception), " cause=", typeof(rec.source.exception.cause))
println("probe: t, latest.t, latest.frame, logged frames => ", rec.t, " ", latest(sim).t, " ", latest(sim).frame, " ", [s.frame for s in logged(sim)])
println("probe: device logs => ", bad.log, " ", pr.log)
println("probe: warn/error log levels => ", [(l.level, first(split(string(l.message), '\n'))) for l in logs.logs])
@p "state readable" state(sim, "c")
@p "init! refused" failure(() -> init!(sim))
@p "run! refused" failure(() -> run!(sim; t_end = 1.0))
@p "attach! refused" (e = failure(() -> attach!(sim, Probe(Symbol[]), NoClaim())); e isa DiagnosticError ? (typeof(diagnostic(e)), diagnostic(e).status, diagnostic(e).legal) : e)
@p "detach! refused" (e = failure(() -> detach!(sim, pr)); e isa DiagnosticError ? (typeof(diagnostic(e)), diagnostic(e).status) : e)

@p "linearize refused" (e = failure(() -> linearize(sim, taps())); e)
@p "linearize about refused" (e = failure(() -> linearize(sim, taps(); about = set(u = (in = false,)), t0 = 0.0)); e isa DiagnosticError ? (typeof(diagnostic(e)), diagnostic(e).status) : e)
@p "checkpoint on errored" failure(() -> Redstone.checkpoint(sim))
println(show_text(sim))
trc = trace(sim)
println("probe: trace frames, batch frames => ", trc.frames, " ", [b.frame for b in trc.batches], " last snapshot frame ", latest(sim).frame)

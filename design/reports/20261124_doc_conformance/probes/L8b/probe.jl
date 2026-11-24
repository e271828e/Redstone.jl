# L8b probe: design/log.md D-226 … D-477 Positions against the code at 72b12836.
using Test, StaticArrays, LinearAlgebra, ForwardDiff
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
include(joinpath(W, "utils.jl"))
import Redstone: retype, Marker, has_stage
import Redstone.Library: Junction, SumJunction, Or, And, Freeze

dl(e) = e.carried isa Vector ? e.carried : [e.carried]
p(tag, v) = println(tag, " => ", repr(v))
kinds_of(f) = (e = failure(f); e === nothing ? nothing :
               e isa DiagnosticError ? [(nameof(typeof(d)), hasproperty(d, :reason) ? d.reason : nothing)
                                        for d in dl(e)] : e)

# D-226: the module exports nothing.
p("D226 names(Redstone)", names(Redstone))

# D-239: a typo'd return field is reported alone.
struct TypoField <: AbstractComponent end
x_init(::TypoField) = nothing
y_types(::TypoField) = (a = Float64,)
y_direct(::TypoField, _) = (aa = 1.0,)
p("D239 kinds", kinds_of(() -> build(single(TypoField()))))

# D-236: root-input type refusals.
struct AbsIn <: AbstractComponent end
x_init(::AbsIn) = nothing
u_types(::AbsIn) = (v = Real,)
y_types(::AbsIn) = (y = Float64,)
y_direct(::AbsIn, (; u)) = (y = 1.0,)
struct BoolIn <: AbstractComponent end
x_init(::BoolIn) = nothing
u_types(::BoolIn) = (v = Bool,)
y_types(::BoolIn) = (y = Float64,)
y_direct(::BoolIn, (; u)) = (y = 1.0,)
struct FloatIn <: AbstractComponent end
x_init(::FloatIn) = nothing
u_types(::FloatIn) = (v = Float64,)
y_types(::FloatIn) = (y = Float64,)
y_direct(::FloatIn, (; u)) = (y = u.v,)
p("D236 all abstract", kinds_of(() -> build(Group((; a = AbsIn(), b = AbsIn()); input_wires = ("r" => ("a/v", "b/v"),)))))
p("D236 concrete conflict", kinds_of(() -> build(Group((; a = FloatIn(), b = BoolIn()); input_wires = ("r" => ("a/v", "b/v"),)))))
p("D236 abstract co-consumer ok", kinds_of(() -> build(Group((; a = FloatIn(), b = AbsIn()); input_wires = ("r" => ("a/v", "b/v"),)))))

# D-265: a concretely typed field freezes; the marker is read at the top alone.
struct HalfFrozen{T}
    a::T
    b::Float64
end
p("D265 retype", retype(LinearizeDual, HalfFrozen{Float64}))
p("D265 retype fields", fieldtypes(retype(LinearizeDual, HalfFrozen{Float64})))

# D-251: selectors.
struct TwoIn <: AbstractComponent end
x_init(::TwoIn) = nothing
u_types(::TwoIn) = (a = Float64, b = Float64)
y_types(::TwoIn) = (y = Float64,)
y_direct(::TwoIn, (; u)) = (y = u.a + u.b,)
host = Group((; c = TwoIn(), s = TickCounter()))
p("D251 two selectors", kinds_of(() -> input_passthrough(host, "c"; except = (:a,), only = (:b,))))
d = only(dl(failure(() -> input_passthrough(host, "c"; except = (:a,), select = n -> true))))
p("D251 payload names", d.names)
logs, value = Test.collect_test_logs() do
    input_passthrough(host, "c"; select = n -> false)
end
p("D251 empty select logs", [l.message for l in logs])
logs, value = Test.collect_test_logs() do
    input_passthrough(host, "s")
end
p("D251 bare faceless", (value, length(logs)))
logs, value = Test.collect_test_logs() do
    input_passthrough(host, "c"; only = ())
end
p("D251 only=() keeps", value)

# D-254: the artifacts.
p("D254 Deployment fields", fieldnames(Deployment))
p("D254 Schedule fields", fieldnames(Schedule))
p("D254 Simulation methods", [m.sig for m in methods(Simulation)])

# D-266: a local derivative rule at a tolerant entry passes the conformance check.
mysin(x::Float64) = sin(x)
mysin(d::ForwardDiff.Dual{T}) where {T} =
    ForwardDiff.Dual{T}(sin(ForwardDiff.value(d)), cos(ForwardDiff.value(d)) * ForwardDiff.partials(d))
struct LocalRule <: AbstractComponent end
x_init(::LocalRule) = nothing
u_types(::LocalRule) = (v = Float64,)
y_types(::LocalRule) = (y = Float64,)
y_direct(::LocalRule, (; u)) = (y = mysin(u.v),)
p("D266 local rule build", build(Group((; c = LocalRule()); input_wires = ("r" => "c/v",));
                                 activations = (Float64, LinearizeDual)) isa Build)
p("D266 Freeze decls", (x_init(Freeze{Float64}()), u_types(Freeze{Float64}()), y_types(Freeze{Float64}())))

# D-286: a Dual at a pinned leaf.
struct LeakPin <: AbstractComponent end
x_init(::LeakPin) = nothing
u_types(::LeakPin) = (v = Float64,)
y_types(::LeakPin) = (y = Pinned{Float64},)
y_direct(::LeakPin, (; u)) = (y = u.v,)
e = failure(() -> build(Group((; c = LeakPin()); input_wires = ("r" => "c/v",));
                        activations = (Float64, LinearizeDual)))
p("D286 kinds", e isa DiagnosticError ? [nameof(typeof(x)) for x in dl(e)] : e)
e isa DiagnosticError && p("D286 message", Redstone.message(first(dl(e))))
# Mid-expression stripping at an unpinned leaf.
struct MidStrip <: AbstractComponent end
x_init(::MidStrip) = nothing
u_types(::MidStrip) = (v = Float64,)
y_types(::MidStrip) = (y = Float64,)
y_direct(::MidStrip, (; u)) = (y = u.v + ForwardDiff.value(u.v) * 0,)
p("D286 mid-strip", build(Group((; c = MidStrip()); input_wires = ("r" => "c/v",));
                          activations = (Float64, LinearizeDual)) isa Build)

# D-298: containers.
struct MixedHost <: AbstractComponent
    kids::Tuple{TickCounter,Float64}
end
local_wires(::MixedHost) = ()
struct InertHost <: AbstractComponent
    k::TickCounter
    params::Tuple{Float64,Float64}
    empty::Tuple{}
end
local_wires(::InertHost) = ()
p("D298 mixed", kinds_of(() -> build(MixedHost((TickCounter(), 1.0)))))
p("D298 inert+empty", kinds_of(() -> build(InertHost(TickCounter(), (1.0, 2.0), ()))))
p("D298 builder names", (isdefined(Redstone, :Assembly), isdefined(Redstone, :add!), isdefined(Redstone, :connect!)))

# D-300 / D-473: Group's rate field and copy constructor.
p("D300 Group fields", fieldnames(Group))
fw = g -> ()
g1 = Group((; a = TickCounter()); local_wires = fw, sample_times = (; a = Relative(2)))
g2 = Group(g1; children = (; a = TickCounter(), b = TickCounter()))
p("D473 copy keeps fn", (g2.local_wires === fw, sample_times(g2)))
p("D473 sample_times fn", kinds_of(() -> Group((; a = TickCounter()); sample_times = g -> (;))))

# D-301
p("D301 retired names", (isdefined(Redstone, :exports), isdefined(Redstone, :u_connections),
                         isdefined(Redstone, :claims), isdefined(Redstone, :reads)))

# D-311: the junction.
sj = SumJunction{Float64, 3}()
p("D311 u_types", u_types(sj))
p("D311 y_types", y_types(sj))
p("D311 y_direct", y_direct(sj, (; u = (in1 = 1.0, in2 = 2.0, in3 = 3.0))))
p("D311 Or/And", (typeof(Or{2}()), typeof(And{2}()), Or{2}().f, And{2}().f))
p("D311 infers F", typeof(Junction{Float64, Float64, 2}(max)))
p("D311 Not", isdefined(Redstone.Library, :Not))
p("D311 output_faces", (output_faces(sj), output_faces(Redstone.Library.UnitDelay(0.0))))

# D-350
struct OnlyDirect <: AbstractComponent end
y_direct(::OnlyDirect, _) = error("never evaluated")
p("D350 has_stage", (has_stage(y_direct, OnlyDirect()), has_stage(y_state, OnlyDirect())))

# D-459 / D-469: time doors.
p("D469 Period/Hz", (isdefined(Redstone, :Period), isdefined(Redstone, :Hz)))
for f in (() -> Absolute(0.02), () -> Absolute(1//50, π), () -> Absolute(big(2)^70))
    x = only(dl(failure(f)))
    p("D469 Absolute refusal", (nameof(typeof(x)), x.reason, x.argument))
end
p("D469 Absolute values", (Absolute(1//50).Δt, Absolute(50).Δt, Absolute(Int32(1)//Int32(50)).Δt))
dep_kinds(; kw...) = kinds_of(() -> Deployment(build(single(TickCounter())); kw...))
p("D459 Δt_frame big", dep_kinds(Δt_frame = big(2)^70))
p("D469 Δt_frame float", dep_kinds(Δt_frame = 0.1))
p("D469 Δt_frame true", Deployment(build(single(TickCounter())); Δt_frame = true).Δt_frame)
p("D469 h_min int", Deployment(build(single(TickCounter())); Δt_frame = 1, h_min = 1//100, algorithm = BS3()).h_min)

# D-472
p("D472 Group home", (parentmodule(Group), isdefined(Redstone.Library, :Group)))

# D-477: wire-declaration shapes in a named assembly.
struct BadWires <: AbstractComponent
    a::TickCounter
end
local_wires(::BadWires) = "a/n" => "x"
input_wires(::BadWires) = 5
output_wires(::BadWires) = ("a/n",)
e = failure(() -> build(BadWires(TickCounter())))
p("D477 kinds", [(nameof(typeof(x)), x.reason, x.declaration) for x in dl(e)])
p("D477 message", Redstone.message(first(dl(e))))

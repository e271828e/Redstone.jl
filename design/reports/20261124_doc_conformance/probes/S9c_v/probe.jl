# S9c verifier probes. Run from the pinned worktree with --project=test.
using Redstone, ForwardDiff, StaticArrays
import Redstone: AbstractComponent, x_init, s_init, u_types, y_types, y_state, y_direct,
    x_deriv, s_update, x_projection, state_events, StateEvent, Pinned, ProbeDual, build,
    activation, Model, Deployment, Group, DiagnosticError, ConformanceFailure, message,
    diagnostics, _accepts, retype, is_bare, default_name

const PD = ProbeDual
section(s) = println("\n== ", s)
function catchmsg(f)
    try
        r = f(); return "OK: " * first(string(typeof(r)), 60)
    catch err
        err isa DiagnosticError ? join([message(d) for d in (err.carried isa Vector ? err.carried : [err.carried])], " | ") :
            sprint(showerror, err)[1:min(end, 300)]
    end
end

# A gain with a root input, unpinned or pinned at its entry.
struct FreeGain <: AbstractComponent end
x_init(::FreeGain) = nothing
u_types(::FreeGain) = (e = Float64,)
y_types(::FreeGain) = (out = Float64,)
y_direct(::FreeGain, (; u)) = (out = 2u.e,)

struct PinGain <: AbstractComponent end
x_init(::PinGain) = nothing
u_types(::PinGain) = (e = Pinned{Float64},)
y_types(::PinGain) = (out = Float64,)
y_direct(::PinGain, (; u)) = (out = 2u.e,)

# A continuous state with a projection that records the scalar it saw.
const SEEN = Any[]
struct Proj <: AbstractComponent end
x_init(::Proj) = (q = 1.0,)
y_types(::Proj) = (c = Float64,)
y_state(::Proj, (; x)) = (c = x.q,)
x_deriv(::Proj, (; x)) = (q = -x.q,)
x_projection(::Proj, x) = (push!(SEEN, typeof(x.q)); (q = x.q,))

# A port returning an `Int` where `Float64` is declared.
struct Shaft <: AbstractComponent end
x_init(::Shaft) = (ω = 1.0,)
y_types(::Shaft) = (P = Float64, M_shaft = Float64)
y_state(::Shaft, (; x)) = (P = x.ω, M_shaft = 0)
x_deriv(::Shaft, (; x)) = (ω = -x.ω,)

# A pinned port that receives a `Dual`.
struct PinPort <: AbstractComponent end
x_init(::PinPort) = (q = 0.0,)
y_types(::PinPort) = (F = Pinned{Float64},)
y_state(::PinPort, (; x)) = (F = x.q,)
x_deriv(::PinPort, (; x)) = (q = 0.0,)

# Bare stores: `x` and `s` declared as one leaf.
struct BareX <: AbstractComponent end
x_init(::BareX) = 1.0
y_types(::BareX) = Float64
y_state(::BareX, (; x)) = x
x_deriv(::BareX, (; x)) = -x

struct BareXBad <: AbstractComponent end
x_init(::BareXBad) = 1.0
y_types(::BareXBad) = Float64
y_state(::BareXBad, (; x)) = x
x_deriv(::BareXBad, (; x)) = (x = -x,)

# A handler returning an unknown key.
struct BadHandler <: AbstractComponent end
x_init(::BadHandler) = (q = 1.0,)
y_types(::BadHandler) = (c = Float64,)
y_state(::BadHandler, (; x)) = (c = x.q,)
x_deriv(::BadHandler, (; x)) = (q = -x.q,)
state_events(::BadHandler) = (hit = StateEvent((c, (; x)) -> x.q - 0.5, (c, (; x)) -> (x = x, s = 1.0)),)

# A guard returning neither form.
struct BadGuard <: AbstractComponent end
x_init(::BadGuard) = (q = 1.0,)
y_types(::BadGuard) = (c = Float64,)
y_state(::BadGuard, (; x)) = (c = x.q,)
x_deriv(::BadGuard, (; x)) = (q = -x.q,)
state_events(::BadGuard) = (hit = StateEvent((c, (; x)) -> 1, (c, (; x)) -> (x = x,)),)

# A state write missing a field, for the payload's diff.
struct MissingField <: AbstractComponent end
x_init(::MissingField) = (a = 1.0, b = 2.0)
y_types(::MissingField) = (c = Float64,)
y_state(::MissingField, (; x)) = (c = x.a,)
x_deriv(::MissingField, (; x)) = (a = -x.a, z = 0.0)

section("S9c-001 / 039 / 049: default build and the opt-in list")
b = build(FreeGain())
println("default keys: ", collect(keys(b.activations)))
activation(b, PD)
println("after first request: ", sort(string.(collect(keys(b.activations)))))
b2 = build(FreeGain(); activations = (Float64, PD))
println("activations=(Float64,PD) keys: ", sort(string.(collect(keys(b2.activations)))))

section("S9c-010: root-input cell at PD, unpinned vs Pinned entry")
for c in (FreeGain(), PinGain())
    bb = build(c)
    a = activation(bb, PD)
    println(nameof(typeof(c)), " root-input cells: ", a.layout.root_inputs)
end

section("S9c-032: x_projection probed at a Dual activation")
empty!(SEEN)
bp = build(Proj())
println("after nominal build: ", SEEN)
empty!(SEEN)
activation(bp, PD)
println("after PD activation: ", SEEN)

section("S9c-033: an activation at the global tracer scalar")
println(catchmsg(() -> activation(build(FreeGain()), Redstone.Tracer{true})))

section("S9c-061 / 062: the bare Dual")
println("isconcretetype(Dual): ", isconcretetype(ForwardDiff.Dual))
println("zero(Dual): ", catchmsg(() -> zero(ForwardDiff.Dual)))
println("retype(Dual, SVector{2,Float64}): ", retype(ForwardDiff.Dual, SVector{2,Float64}),
        " concrete? ", isconcretetype(retype(ForwardDiff.Dual, SVector{2,Float64})))
println("activation(b, Dual): ", catchmsg(() -> activation(build(FreeGain()), ForwardDiff.Dual)))

section("S9c-067: the activation entry's fields")
println(fieldnames(typeof(activation(b, PD))))

section("S9c-099: bare contract")
println("is_bare(Float64)=", is_bare(Float64), " default_name(y_types)=", default_name(y_types))

section("S9c-132: the Int-for-Float64 message at nominal")
println(catchmsg(() -> build(Shaft())))

section("S9c-148: a differing field name at a Dual activation")
println(_accepts(NamedTuple{(:a,),Tuple{PD}}, NamedTuple{(:b,),Tuple{Float64}}, PD))
println(_accepts(NamedTuple{(:a,),Tuple{PD}}, NamedTuple{(:a,),Tuple{Float64}}, PD))

section("S9c-154: pinned port receiving a Dual")
println(catchmsg(() -> build(PinPort(); activations = (Float64, PD))))

section("S9c-158: the Model door")
dep = Deployment(build(FreeGain()); Δt_frame = 1//100)
for T in (Float64, PD, ForwardDiff.Dual{Nothing,ForwardDiff.Dual{Nothing,Float64,1},1}, Float32,
          ForwardDiff.Dual{Nothing,Float32,1}, ForwardDiff.Dual)
    println(T, " => ", catchmsg(() -> Model(dep, T)))
end

section("S9c-176: bare store returns")
println("BareX good: ", catchmsg(() -> build(BareX(); activations = (Float64, PD))))
println("BareX NamedTuple: ", catchmsg(() -> build(BareXBad())))

section("S9c-185: handler unknown key")
println(catchmsg(() -> build(BadHandler())))
try build(BadHandler()) catch err; for d in (err.carried isa Vector ? err.carried : [err.carried]); println(typeof(d), " ", d isa Redstone.HandlerReturnKey ? (d.key, d.stores) : ""); end; end

section("S9c-195: guard form")
println(catchmsg(() -> build(BadGuard())))

section("S9c-204 / 206: payload of a field-set failure")
try build(MissingField()) catch err
    for d in (err.carried isa Vector ? err.carried : [err.carried])
        println(typeof(d), " what=", getfield(d, :what), " observed_fields=", d.observed_fields,
                " declared_fields=", d.declared_fields)
        println("  ", message(d))
    end
end

section("S9c-061: the probe chain run directly at the bare Dual")
let bb = build(FreeGain())
    nominal = activation(bb, Float64)
    println(catchmsg(() -> Redstone._activate(bb.structure, bb.outputs, nominal, ForwardDiff.Dual)))
    println("declared u at Dual: ", catchmsg(() -> Redstone.declared_at(u_types, FreeGain(), Redstone.CONTINUOUS, ForwardDiff.Dual)),
            " => ", try Redstone.declared_at(u_types, FreeGain(), Redstone.CONTINUOUS, ForwardDiff.Dual) catch; nothing end)
end

# S6c verifier probes, run from the pinned worktree with --project=test.
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
include(joinpath(W, "utils.jl"))
import Redstone: _opaque, mutable_position, leaf_types, LEGAL_BUNDLE, default_name

say(tag, x) = println(rpad(tag, 34), " => ", x)
dlist(e) = e isa DiagnosticError{Vector{Diagnostic}} ? diagnostics(e) : [diagnostic(e)]
err_of(f) = (e = failure(f); e === nothing ? :built : (e isa DiagnosticError ? [(typeof(d), hasproperty(d, :reason) ? d.reason : nothing, first(sprint(showerror, e), 160)) for d in dlist(e)] : (typeof(e), first(sprint(showerror, e), 200))))

# --- S6c-004 / S6c-001: mutability ---
struct BigOut <: AbstractComponent end
x_init(::BigOut) = nothing
y_types(::BigOut) = (b = BigFloat,)
y_direct(::BigOut, _) = (b = BigFloat(1.5),)
say("P1 BigFloat port build", err_of(() -> build(single(BigOut()))))
say("P1 BigFloat sim run", err_of(() -> (s = Simulation(single(BigOut()); Δt_frame = 1//100); init!(s); run!(s; t_end = 0.01); port(s, "c", :b))))
struct CacheOut <: AbstractComponent end
x_init(::CacheOut) = nothing
y_types(::CacheOut) = (c = Cache,)
y_direct(::CacheOut, _) = (c = Cache(1.0),)
say("P2 mutable struct port", err_of(() -> build(single(CacheOut()))))
struct VecOut <: AbstractComponent end
x_init(::VecOut) = nothing
y_types(::VecOut) = (v = Vector{Float64},)
y_direct(::VecOut, _) = (v = [1.0],)
say("P3 Vector port", err_of(() -> build(single(VecOut()))))
say("P4 mutable_position(HeightField)", mutable_position(HeightField))
say("P4 Terrain (Matrix in handle) build", err_of(() -> build(single(Terrain()))))
struct TupVec <: AbstractComponent end
x_init(::TupVec) = nothing
y_types(::TupVec) = (v = Tuple{Vector{Float64}},)
y_direct(::TupVec, _) = (v = ([1.0],),)
say("P5 Tuple{Vector} port build", err_of(() -> build(single(TupVec()))))
say("P5 _opaque(Tuple{Vector})", _opaque(Tuple{Vector{Float64}}))

# --- S6c-041: opaque walk ---
say("P6 _opaque HeightField/Symbol/Framed", (_opaque(HeightField), _opaque(Symbol), leaf_types(@NamedTuple{s::Symbol, x::Float64})))
say("P6 _opaque(AbstractTerrain)", _opaque(AbstractTerrain))

# --- S6c-032: nested fields get no cells ---
struct NPose; x::Float64; y::Float64; end
struct NestOut <: AbstractComponent end
x_init(::NestOut) = nothing
y_types(::NestOut) = (pose = NPose,)
y_direct(::NestOut, _) = (pose = NPose(1.0, 2.0),)
let b = build(single(NestOut()))
    say("P7 cell addrs for c", sort([k for k in keys(b.activations[Float64].layout.addr) if k[1] == "c"]))
end

# --- S6c-022: bare contract face ---
struct BareGain2 <: AbstractComponent end
x_init(::BareGain2) = nothing
u_types(::BareGain2) = Float64
y_types(::BareGain2) = Float64
y_direct(::BareGain2, (; u)) = 2u
say("P8 bare keyed_outs/ins", (keys(keyed_outs(Redstone.declarations(BareGain2(), CONTINUOUS, Float64))), keys(keyed_ins(Redstone.declarations(BareGain2(), CONTINUOUS, Float64)))))
say("P8 bare fed build", err_of(() -> build(fed(BareGain2()))))
let b = build(fed(BareGain2())); say("P8 bare cell addrs", sort([k for k in keys(b.activations[Float64].layout.addr)])); end

# --- S6c-050: one producing function ---
say("P9 Twice", err_of(() -> build(single(Twice()))))

# --- S6c-066: root input bulk handle ---
say("P10 Query fed terrain (handle at root)", err_of(() -> build(fed(Query(), "terrain"))))
say("P10 AbstractTerrainQuery at root", err_of(() -> build(fed(AbstractTerrainQuery(), "terrain"))))

# --- S6c-002: stages optional ---
say("P11 BareTicker (y_state only)", (has_stage(y_state, BareTicker()), has_stage(y_direct, BareTicker()), err_of(() -> build(single(BareTicker())))))
say("P11 Terrain (y_direct only)", (has_stage(y_state, Terrain()), has_stage(y_direct, Terrain())))

# --- S6c-086/095/104/113: bundle sets ---
for k in sort(collect(keys(LEGAL_BUNDLE)); by = string)
    say("P12 LEGAL $(k)", LEGAL_BUNDLE[k])
end
say("P13 Plant x_deriv bundle", bundle_names(x_deriv, Plant(), CONTINUOUS, (:y,)))
struct NoY <: AbstractComponent end
x_init(::NoY) = (z = 0.0,)
x_deriv(::NoY, (; x)) = (z = -x.z,)
say("P13 NoY x_deriv bundle", bundle_names(x_deriv, NoY(), CONTINUOUS, ()))
say("P13 BareTicker s_update bundle", bundle_names(s_update, BareTicker(), DISCRETE, (:n,)))
say("P13 BareTicker y_state bundle", bundle_names(y_state, BareTicker(), DISCRETE, ()))
say("P13 Plant y_state/y_direct", (bundle_names(y_state, Plant(), CONTINUOUS, ()), bundle_names(y_direct, Plant(), CONTINUOUS, (:y,))))
say("P13 BareLatch event bundle", event_bundle_names(BareLatch()))
struct IntGuard <: AbstractComponent end
x_init(::IntGuard) = (q = 0.0,)
y_types(::IntGuard) = (q = Float64,)
y_state(::IntGuard, (; x)) = (q = x.q,)
x_deriv(::IntGuard, _) = (q = 1.0,)
ig_guard(::IntGuard, (; x)) = 1
ig_handler(::IntGuard, (; x)) = (x = (q = 0.0,),)
state_events(::IntGuard) = (go = StateEvent(ig_guard, ig_handler),)
say("P14 Int guard", err_of(() -> build(single(IntGuard()))))
say("P14 String guard (BadGuardForm-like)", err_of(() -> build(single(BareLatch()))))

# --- S6c-122: return order ---
struct Swapped2 <: AbstractComponent end
x_init(::Swapped2) = (p = 1.0, q = 2.0)
y_types(::Swapped2) = (p = Float64, q = Float64)
y_state(::Swapped2, (; x)) = (q = x.q, p = x.p)
x_deriv(::Swapped2, (; x)) = (p = -x.p, q = -x.q)
say("P15 Swapped2 run", err_of(() -> (s = Simulation(single(Swapped2()); Δt_frame = 1//100); init!(s); run!(s; t_end = 0.0); (port(s, "c", :p), port(s, "c", :q)))))
let s = Simulation(single(Swapped2()); Δt_frame = 1//100); init!(s); say("P15 Swapped2 p,q", (port(s, "c", :p), port(s, "c", :q))); end

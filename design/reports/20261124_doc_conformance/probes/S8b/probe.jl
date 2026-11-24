# Probe for S8b: spec.md 2933-3367 (§8.2 input contracts, root inputs, output contracts).
# Run from the worktree W:
#   JULIA_LOAD_PATH="@" julia --startup-file=no --project=test <this file>
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
include(joinpath(W, "test/imports.jl"))
include(joinpath(W, "test/fixtures.jl"))
import Redstone: retype, message, pinning_consumers, leaf_types

summ(r) = r isa DiagnosticError ? dgsof(r) : (s = repr(r); length(s) > 400 ? s[1:400] * "…" : s)
function dgsof(e)
    ds = e.carried isa Vector ? e.carried : [e.carried]
    [(nameof(typeof(d)), hasproperty(d, :reason) ? d.reason : nothing) for d in ds]
end
macro p(label, ex)
    quote
        local r = try $(esc(ex)) catch e; e end
        println("probe:", $(__source__.line), " ", $label, " => ", summ(r))
    end
end
dg(f) = try f(); :ok catch e; e isa DiagnosticError ? dgsof(e) : (e isa Exception ? sprint(showerror, e)[1:min(end,300)] : e) end
msgs(f) = try f(); :ok catch e; e isa DiagnosticError ? [message(d) for d in (e.carried isa Vector ? e.carried : [e.carried])] : sprint(showerror, e)[1:min(end,500)] end
carriedtypes(e) = e isa DiagnosticError ? (dgsof(e), [message(d) for d in (e.carried isa Vector ? e.carried : [e.carried])]) : sprint(showerror, e)
ct(b, T, path, port) = typeof(activation(b, T).layout.addr[(path, port)]).parameters[1]
ins(b, T, ci) = keyed_ins(activation(b, T).decls[ci])
outs(b, T, ci) = keyed_outs(activation(b, T).decls[ci])

# ---- 3: bare and named u_types --------------------------------------------------
struct IntN{V} <: AbstractComponent; x0::V; end
x_init(c::IntN) = c.x0; u_types(::IntN{V}) where {V} = (in = V,); y_types(::IntN{V}) where {V} = V
y_state(::IntN, (; x)) = x; x_deriv(::IntN, (; u)) = u.in
struct IntB{V} <: AbstractComponent; x0::V; end
x_init(c::IntB) = c.x0; u_types(::IntB{V}) where {V} = V; y_types(::IntB{V}) where {V} = V
y_state(::IntB, (; x)) = x; x_deriv(::IntB, (; u)) = u
@p "named integrator root inputs" (b = build(IntN(0.0)); (b.structure.root_inputs, collect(keys(keyed_outs(activation(b, Float64).decls[1])))))
@p "bare integrator root inputs" (b = build(IntB(0.0)); (b.structure.root_inputs, collect(keys(keyed_outs(activation(b, Float64).decls[1])))))
@p "bare integrator is_bare ins/outs" (b = build(IntB(0.0)); (Redstone.is_bare(activation(b,Float64).decls[1].ins), Redstone.is_bare(activation(b,Float64).decls[1].outs)))
struct BareUNamedY <: AbstractComponent end
x_init(::BareUNamedY) = nothing; u_types(::BareUNamedY) = Float64; y_types(::BareUNamedY) = (out = Float64,)
y_direct(::BareUNamedY, (; u)) = (out = 2u,)
@p "bare u beside named y" (b = build(BareUNamedY()); (b.structure.root_inputs,))

# ---- the Bad{K} family of refused contracts -------------------------------------
struct Bad{K} <: AbstractComponent end
x_init(::Bad) = nothing
y_types(::Bad) = (out = Float64,)
y_direct(::Bad, _) = (out = 1.0,)
struct Holder{T}; v::Vector{T}; end
u_types(::Bad{:nested_u}) = (a = SVector{2,Pinned{Float64}},)
u_types(::Bad{:mut_u}) = (a = Vector{Float64},)
u_types(::Bad{:tuple_u}) = (a = (Float64, Float64),)
u_types(::Bad{:num_u}) = (a = 1.0,)
u_types(::Bad{:nothing_u}) = nothing
u_types(::Bad{:bare_tuple_u}) = (Float64, Float64)
u_types(::Bad{:bare_num_u}) = 1.0
u_types(::Bad{:empty_u}) = (;)
u_types(::Bad{:bare_pinned_u}) = Pinned{Float64}
u_types(::Bad{:stopflag_u}) = (s = StopFlag,)
y_types(::Bad{:nested_y}) = (out = SVector{2,Pinned{Float64}},)
y_direct(::Bad{:nested_y}, _) = (out = SVector(1.0, 1.0),)
y_types(::Bad{:mut_y}) = (out = Vector{Float64},)
y_direct(::Bad{:mut_y}, _) = (out = [1.0],)
y_types(::Bad{:mut_nested_y}) = (out = Holder{Float64},)
y_direct(::Bad{:mut_nested_y}, _) = (out = Holder([1.0]),)
y_types(::Bad{:tuple_y}) = (out = (Float64, Float64),)
y_types(::Bad{:num_y}) = (out = 1.0,)
y_types(::Bad{:nothing_y}) = nothing
y_types(::Bad{:bare_num_y}) = 1.0
y_types(::Bad{:empty_y_stateful}) = (;)
for K in (:nested_u, :mut_u, :tuple_u, :num_u, :nothing_u, :bare_tuple_u, :bare_num_u, :empty_u, :bare_pinned_u,
          :stopflag_u, :nested_y, :mut_y, :mut_nested_y, :tuple_y, :num_y, :nothing_y, :bare_num_y)
    @eval @p string($(QuoteNode(K))) dg(() -> build(Bad{$(QuoteNode(K))}()))
end
@p "mut_u reason/site" (try build(Bad{:mut_u}()) catch e; d = only(e.carried); (d.reason, d.site, d.position) end)
@p "mut_nested_y position" (try build(Bad{:mut_nested_y}()) catch e; d = only(e.carried); (d.reason, d.site, d.position) end)
@p "nested_u site/name" (try build(Bad{:nested_u}()) catch e; d = only(e.carried); (d.reason, d.site, d.name) end)
@p "nested_y site" (try build(Bad{:nested_y}()) catch e; d = only(e.carried); (d.reason, d.site, d.name) end)
@p "bare_tuple_u msg" msgs(() -> build(Bad{:bare_tuple_u}()))
@p "nothing_u msg" msgs(() -> build(Bad{:nothing_u}()))
# StopFlag consumer fed by a StopRequest
struct FlagReader <: AbstractComponent end
x_init(::FlagReader) = nothing; u_types(::FlagReader) = (s = StopFlag,); y_types(::FlagReader) = (out = Float64,)
y_direct(::FlagReader, (; u)) = (out = u.s === STOP_REQUESTED ? 1.0 : 0.0,)
@p "StopFlag consumer from StopRequest" dg(() -> build(Group((; sr = StopRequest(reason = "why"), fr = FlagReader());
                                                           local_wires = ("sr/y" => "fr/s",), input_wires = ("go" => "sr/u",))))
@p "StopFlag input at root" dg(() -> build(FlagReader()))
@p "requesters" (b = build(Group((; sr = StopRequest(reason = "why"), sr2 = StopRequest()); input_wires = ("a" => "sr/u", "b" => "sr2/u")));
                 [(r.path, r.port, r.reason) for r in activation(b, Float64).layout.requesters])
@p "StopFlag output placed" (b = build(StopRequest()); haskey(activation(b, Float64).layout.addr, ("", :y)))
@p "stop_reason default" Redstone.stop_reason(Gain(1.0))
@p "stop_reason returns String" Redstone.stop_reason(StopRequest(reason = "x"))
@p "stop_reason in family" (:stop_reason in Redstone.DECLARATION_FAMILY)

# ---- discrete Pinned ------------------------------------------------------------
struct DPinU <: AbstractComponent end
s_init(::DPinU) = (n = 0,); u_types(::DPinU) = (a = Pinned{Float64},); y_types(::DPinU) = (out = Float64,)
y_state(::DPinU, (; s)) = (out = 1.0,); s_update(::DPinU, (; s)) = (n = s.n + 1,)
struct DPinY <: AbstractComponent end
s_init(::DPinY) = (n = 0,); u_types(::DPinY) = (a = Float64,); y_types(::DPinY) = (out = Pinned{Float64},)
y_state(::DPinY, (; s)) = (out = 1.0,); s_update(::DPinY, (; s)) = (n = s.n + 1,)
struct DPinNest <: AbstractComponent end
s_init(::DPinNest) = (n = 0,); u_types(::DPinNest) = (a = SVector{2,Pinned{Float64}},); y_types(::DPinNest) = (out = Float64,)
y_state(::DPinNest, (; s)) = (out = 1.0,); s_update(::DPinNest, (; s)) = (n = s.n + 1,)
@p "discrete Pinned u" dg(() -> build(DPinU()))
@p "discrete Pinned y" dg(() -> build(DPinY()))
@p "discrete nested marker" dg(() -> build(DPinNest()))
@p "discrete Pinned reason" (try build(DPinU()) catch e; d = only(e.carried); (d.reason, d.declaration, d.entry) end)

# ---- the walk: cell types at a Dual activation ---------------------------------
@enum Col red green
struct Rg{T,L,H}; v::T; end
struct MyStruct{T}; a::T; n::Int; end
mutable struct MutW{T}; a::T; end
struct TyP <: AbstractComponent end
x_init(::TyP) = nothing
y_types(::TyP) = (v = SVector{3,Float64}, p = Pinned{Float64}, n = Int, b = Bool, g = Col, w = Pinned{SVector{2,Float64}},
                  r = Rg{Float64,-1,1}, m = MyStruct{Float64})
y_direct(::TyP, _) = (v = SVector(1.0, 2.0, 3.0), p = 1.0, n = 1, b = true, g = red, w = SVector(1.0, 2.0),
                      r = Rg{Float64,-1,1}(0.5), m = MyStruct(1.0, 2))
@p "y walk at ProbeDual" (b = build(TyP(); activations = (Float64, ProbeDual)); Dict(k => ct(b, ProbeDual, "", k) for k in keys(outs(b, ProbeDual, 1))))
@p "retype mutable param" (retype(ProbeDual, MutW{Float64}), retype(ProbeDual, Vector{Float64}), retype(ProbeDual, Rg{Float64,-1,1}))
struct Inner{T}; a::T; end
struct Outer{I}; i::I; end
@p "retype nested" retype(ProbeDual, Outer{Inner{Float64}})
# u walk and root input cells
struct TyU <: AbstractComponent end
x_init(::TyU) = nothing
u_types(::TyU) = (v = SVector{3,Float64}, p = Pinned{Float64}, n = Int, c = Col)
y_types(::TyU) = (out = Float64,)
y_direct(::TyU, (; u)) = (out = u.v[1] + u.p + u.n,)
@p "u walk at ProbeDual (decls)" (b = build(TyU(); activations = (Float64, ProbeDual)); (ins(b, ProbeDual, 1), [(f, ct(b, ProbeDual, "", f)) for f in b.structure.root_inputs]))
# discrete tiers pin wholesale
@p "discrete producer y at ProbeDual" (b = build(Group((; a = DiscreteAccumulator(1.0), g = Gain(1.0)); local_wires = ("a/u" => "g/e",), input_wires = ("in" => "a/e",)); activations = (Float64, ProbeDual));
                                      (outs(b, ProbeDual, 1), ins(b, ProbeDual, 1), outs(b, ProbeDual, 2), [(f, ct(b, ProbeDual, "", f)) for f in b.structure.root_inputs]))
@p "x_init walked, m/s pinned" (b = build(Pendulum(); activations = (Float64, ProbeDual)); activation(b, ProbeDual).decls[1].x)
struct ModeComp <: AbstractComponent end
x_init(::ModeComp) = (q = 0.0, v = SVector(0.0, 0.0)); m_init(::ModeComp) = (phase = red, k = 2.5); u_types(::ModeComp) = (;)
y_types(::ModeComp) = (q = Float64,); y_state(::ModeComp, (; x)) = (q = x.q,); x_deriv(::ModeComp, _) = (q = 0.0, v = SVector(0.0, 0.0))
@p "x_init/m_init at ProbeDual" (b = build(ModeComp(); activations = (Float64, ProbeDual)); d = activation(b, ProbeDual).decls[1]; (d.x, d.s))
@p "literal 0.0 deriv at Dual (embed)" dg(() -> build(ModeComp(); activations = (ProbeDual,)))
struct Piece <: AbstractComponent end
x_init(::Piece) = nothing; u_types(::Piece) = (flow = Float64,); y_types(::Piece) = (out = Float64,)
y_direct(::Piece, (; u)) = (out = u.flow > 0 ? 2u.flow : 0.0,)
@p "piecewise literal branch at Dual" dg(() -> build(Piece(); activations = (Float64, ProbeDual)))
@p "piecewise literal at ProbeDual with literal path" (b = build(Piece(); activations = (Float64, ProbeDual)); ct(b, ProbeDual, "", :out))

# ---- the wire clauses -----------------------------------------------------------
@p "Gain->PinnedGain (walk clause)" (try build(Group((; g = Gain(1.0), p = PinnedGain()); local_wires = ("g/out" => "p/e",), input_wires = ("in" => "g/e",))) catch e; d = only(e.carried); (typeof(d), d.path, d.face, d.producer_path, d.producer_port, d.leaf, d.declared, d.observed) end)
@p "WalkingFace message" msgs(() -> build(Group((; g = Gain(1.0), p = PinnedGain()); local_wires = ("g/out" => "p/e",), input_wires = ("in" => "g/e",))))
@p "PinnedGain->Gain" dg(() -> build(Group((; p = PinnedGain(), g = Gain(1.0)); local_wires = ("p/out" => "g/e",), input_wires = ("in" => "p/e",)); activations = (Float64, ProbeDual)))
@p "continuous->discrete consumer" dg(() -> build(Group((; g = Gain(1.0), a = DiscreteAccumulator(1.0)); local_wires = ("g/out" => "a/e",), input_wires = ("in" => "g/e",)); activations = (Float64, ProbeDual)))
@p "discrete->continuous unpinned" dg(() -> build(Group((; a = DiscreteAccumulator(1.0), g = Gain(1.0)); local_wires = ("a/u" => "g/e",), input_wires = ("in" => "a/e",)); activations = (Float64, ProbeDual)))
@p "discrete->continuous Pinned" dg(() -> build(Group((; a = DiscreteAccumulator(1.0), p = PinnedGain()); local_wires = ("a/u" => "p/e",), input_wires = ("in" => "a/e",)); activations = (Float64, ProbeDual)))
struct Vec2In <: AbstractComponent end
x_init(::Vec2In) = nothing; u_types(::Vec2In) = (e = SVector{2,Float64},); y_types(::Vec2In) = (out = Float64,); y_direct(::Vec2In, (; u)) = (out = u.e[1],)
struct IntIn <: AbstractComponent end
x_init(::IntIn) = nothing; u_types(::IntIn) = (e = Int,); y_types(::IntIn) = (out = Float64,); y_direct(::IntIn, (; u)) = (out = 1.0,)
@p "WireTypeMismatch Float64 -> SVector2" (try build(Group((; g = Gain(1.0), v = Vec2In()); local_wires = ("g/out" => "v/e",), input_wires = ("in" => "g/e",))) catch e; d = only(e.carried); (typeof(d), d.declared, d.observed) end)
@p "WireTypeMismatch Float64 -> Int" dg(() -> build(Group((; g = Gain(1.0), v = IntIn()); local_wires = ("g/out" => "v/e",), input_wires = ("in" => "g/e",))))
struct DVec2In <: AbstractComponent end
s_init(::DVec2In) = (n = 0,); u_types(::DVec2In) = (e = SVector{2,Float64},); y_types(::DVec2In) = (out = Float64,)
y_state(::DVec2In, (; s)) = (out = 1.0,); s_update(::DVec2In, (; s)) = (n = s.n + 1,)
@p "WireTypeMismatch to discrete consumer" dg(() -> build(Group((; g = Gain(1.0), v = DVec2In()); local_wires = ("g/out" => "v/e",), input_wires = ("in" => "g/e",))))
# handles
@p "OffsetAtT->OffsetQuery" dg(() -> build(offset_model(OffsetAtT()); activations = (Float64, ProbeDual)))
@p "PinnedOffsetSource->OffsetQuery" dg(() -> build(offset_model(PinnedOffsetSource()); activations = (Float64, ProbeDual)))
@p "DiscreteOffsetSource->OffsetQuery" dg(() -> build(offset_model(DiscreteOffsetSource()); activations = (Float64, ProbeDual)))
@p "OffsetAtT->PinnedOffsetQuery" (try build(Group((; src = OffsetAtT(), q = PinnedOffsetQuery()); local_wires = ("src/terrain" => "q/terrain",))) catch e; d = only(e.carried); (typeof(d), d.leaf, d.declared, d.observed) end)
@p "Pinned src->PinnedOffsetQuery" dg(() -> build(Group((; src = PinnedOffsetSource(), q = PinnedOffsetQuery()); local_wires = ("src/terrain" => "q/terrain",)); activations = (Float64, ProbeDual)))
@p "OffsetAtT handle cell at Dual" (b = build(offset_model(OffsetAtT()); activations = (Float64, ProbeDual)); (ct(b, ProbeDual, "src", :terrain), ct(b, Float64, "src", :terrain)))
@p "Pinned handle cell at Dual" (b = build(offset_model(PinnedOffsetSource()); activations = (Float64, ProbeDual)); ct(b, ProbeDual, "src", :terrain))
# abstract entries
@p "TerrainRig builds" dg(() -> build(TerrainRig(); activations = (Float64, ProbeDual)))
@p "TerrainGain bare: AbstractAtRoot" (try build(TerrainGain()) catch e; d = only(e.carried); (typeof(d), d.face, d.paths, d.declared) end)
@p "AbstractAtRoot message" msgs(() -> build(TerrainGain()))
@p "Gain->TerrainGain.terrain mismatch" (try build(Group((; g = Gain(1.0), t = TerrainGain()); local_wires = ("g/out" => "t/terrain",), input_wires = ("in" => "g/e", "k" => "t/k"))) catch e; dgsof(e) end)
# abstract entry decided on whole declaration, walking producer
struct AbsTerr end
abstract type AbsT end
struct ConcT{T} <: AbsT; h::T; end
struct AbsSrcW <: AbstractComponent end
x_init(::AbsSrcW) = nothing; y_types(::AbsSrcW) = (t = ConcT{Float64},); y_direct(::AbsSrcW, _) = (t = ConcT(1.0),)
struct AbsSrcP <: AbstractComponent end
x_init(::AbsSrcP) = nothing; y_types(::AbsSrcP) = (t = Pinned{ConcT{Float64}},); y_direct(::AbsSrcP, _) = (t = ConcT(1.0),)
struct AbsCons <: AbstractComponent end
x_init(::AbsCons) = nothing; u_types(::AbsCons) = (t = AbsT,); y_types(::AbsCons) = (out = Float64,); y_direct(::AbsCons, (; u)) = (out = u.t.h,)
struct AbsConsT <: AbstractComponent end
x_init(::AbsConsT) = nothing; u_types(::AbsConsT) = (t = ConcT{Float64},); y_types(::AbsConsT) = (out = Float64,); y_direct(::AbsConsT, (; u)) = (out = u.t.h,)
@p "abstract entry <- walking producer" dg(() -> build(Group((; s = AbsSrcW(), c = AbsCons()); local_wires = ("s/t" => "c/t",)); activations = (Float64, ProbeDual)))
@p "abstract entry <- pinned producer" dg(() -> build(Group((; s = AbsSrcP(), c = AbsCons()); local_wires = ("s/t" => "c/t",)); activations = (Float64, ProbeDual)))
@p "_accepts_wire abstract, marker walking" (Redstone._accepts_wire(AbsT, ConcT{Marker}, Marker), Redstone._accepts_wire(AbsT, ConcT{Float64}, Marker))
# abstract Real entry
struct AbsReal <: AbstractComponent end
x_init(::AbsReal) = nothing; u_types(::AbsReal) = (e = Real,); y_types(::AbsReal) = (out = Float64,); y_direct(::AbsReal, (; u)) = (out = 1.0,)
@p "abstract Real entry <- Gain" dg(() -> build(Group((; g = Gain(1.0), r = AbsReal()); local_wires = ("g/out" => "r/e",), input_wires = ("in" => "g/e",))))
@p "bare AbsReal root" dg(() -> build(AbsReal()))

# ---- root inputs ----------------------------------------------------------------
@p "opaque at root (OffsetQuery)" (try build(OffsetQuery()) catch e; d = only(e.carried); (typeof(d), d.reason, d.site) end)
@p "handle_at_root message" msgs(() -> build(OffsetQuery()))
struct Sym <: AbstractComponent end
x_init(::Sym) = nothing; u_types(::Sym) = (e = Symbol,); y_types(::Sym) = (out = Float64,); y_direct(::Sym, _) = (out = 1.0,)
@p "Symbol at root" dg(() -> build(Sym()))
@p "enum at root" dg(() -> build(GearReader()))
# fan-out
@p "fan-out same concrete" dg(() -> build(Group((; a = Gain(1.0), b = Gain(2.0)); input_wires = ("in" => ("a/e", "b/e"),))))
@p "fan-out conflict Float64 vs SVector2" (try build(Group((; a = Gain(1.0), v = Vec2In()); input_wires = ("in" => ("a/e", "v/e"),))) catch e; d = only(e.carried); (typeof(d), d.paths, d.declared) end)
@p "fan-out abstract + concrete OK" dg(() -> build(Group((; a = Gain(1.0), r = AbsReal()); input_wires = ("in" => ("a/e", "r/e"),))))
struct AbsInt <: AbstractComponent end
x_init(::AbsInt) = nothing; u_types(::AbsInt) = (e = Integer,); y_types(::AbsInt) = (out = Float64,); y_direct(::AbsInt, _) = (out = 1.0,)
@p "fan-out abstract co-consumer mismatch" dg(() -> build(Group((; a = Gain(1.0), r = AbsInt()); input_wires = ("in" => ("a/e", "r/e"),))))
@p "fan-out all abstract" dg(() -> build(Group((; a = AbsReal(), r = AbsInt()); input_wires = ("in" => ("a/e", "r/e"),))))
@p "fan-out Float64 vs Pinned Float64 (no conflict)" dg(() -> build(Group((; a = Gain(1.0), p = PinnedGain()); input_wires = ("in" => ("a/e", "p/e"),))))
@p "meet: root input cells at Dual (g+p / free)" (b = build(pinned_fanout(); activations = (Float64, ProbeDual)); [(f, ct(b, Float64, "", f), ct(b, ProbeDual, "", f)) for f in b.structure.root_inputs])
@p "meet: only tolerant consumers" (b = build(Group((; a = Gain(1.0), c = Gain(2.0)); input_wires = ("in" => ("a/e", "c/e"),)); activations = (Float64, ProbeDual)); ct(b, ProbeDual, "", :in))
@p "root type Pinned vs plain are one type" (b = build(Group((; a = Gain(1.0), p = PinnedGain()); input_wires = ("in" => ("a/e", "p/e"),)); activations = (ProbeDual,)); (b.structure.root_types, ct(b, ProbeDual, "", :in)))
@p "pinning_consumers fanout" (b = build(pinned_fanout()); pinning_consumers(b.structure))
struct Vec3PinFan <: AbstractComponent end
x_init(::Vec3PinFan) = nothing; u_types(::Vec3PinFan) = (e = Pinned{SVector{3,Float64}},); y_types(::Vec3PinFan) = (out = Float64,); y_direct(::Vec3PinFan, (; u)) = (out = u.e[1],)
struct Vec3Fan <: AbstractComponent end
x_init(::Vec3Fan) = nothing; u_types(::Vec3Fan) = (e = SVector{3,Float64},); y_types(::Vec3Fan) = (out = Float64,); y_direct(::Vec3Fan, (; u)) = (out = u.e[1],)
@p "SVector3 vs Pinned{SVector3} fan-out cell at Dual" (b = build(Group((; a = Vec3Fan(), p = Vec3PinFan()); input_wires = ("in" => ("a/e", "p/e"),)); activations = (Float64, ProbeDual)); (b.structure.root_types, ct(b, ProbeDual, "", :in)))
@p "SVector3 alone cell at Dual" (b = build(Group((; a = Vec3Fan()); input_wires = ("in" => "a/e",)); activations = (Float64, ProbeDual)); ct(b, ProbeDual, "", :in))
# seedability
lin_pinned_g() = Group((; g = PinnedGain(), c = Pendulum()); local_wires = ("g/out" => "c/u",), input_wires = ("τ" => "g/e",))
@p "pinned root tap refused" (sim = Simulation(lin_pinned_g(); Δt_frame = 1//10);
                             try linearize(sim, taps(u = (τ = get_input(:τ),)); about = set(u = (τ = 0.0,))) catch e; d = only(diagnostics(e)); (typeof(d), d.reason, d.pinning, message(d)) end)
mixed_g() = Group((; g = Gain(1.0), p = PinnedGain(), c = Pendulum()); local_wires = ("g/out" => "c/u",), input_wires = ("τ" => ("g/e", "p/e"),))
@p "mixed fan-out tap refused naming pinning consumer" (sim = Simulation(mixed_g(); Δt_frame = 1//10);
                             try linearize(sim, taps(u = (τ = get_input(:τ),)); about = set(u = (τ = 0.0,))) catch e; d = only(diagnostics(e)); (typeof(d), d.reason, d.pinning) end)
@p "unpinned root tap OK" (sim = Simulation(Group((; g = Gain(1.0), c = Pendulum()); local_wires = ("g/out" => "c/u",), input_wires = ("τ" => "g/e",)); Δt_frame = 1//10);
                           r = linearize(sim, taps(x = (θ = get_state("c", :θ),), u = (τ = get_input(:τ),)); about = set(u = (τ = 0.0,))); typeof(r))
# primitive root
struct BothKeys <: AbstractComponent end
x_init(::BothKeys) = nothing; u_types(::BothKeys) = (a = Float64,); y_types(::BothKeys) = (a = Float64,); y_direct(::BothKeys, (; u)) = (a = u.a,)
@p "primitive root key in both contracts" dg(() -> build(BothKeys()))
@p "BothKeys diag" (try build(BothKeys()) catch e; d = only(e.carried); (typeof(d), d.site, d.faces, message(d)) end)
@p "primitive root's faces = u_types keys" build(DerivativeFed()).structure.root_inputs
@p "bare primitive root: u and y" (b = build(IntB(0.0)); (b.structure.root_inputs, [r for r in keys(activation(b, Float64).layout.addr)]))
@p "assembly root faces via input_wires" (b = build(Group((; a = Gain(1.0)); input_wires = ("in" => "a/e",))); b.structure.root_inputs)
@p "assembly root: two bare contracts do not collide" dg(() -> build(Group((; a = IntB(0.0)); input_wires = ("u" => "a/u",), output_wires = ("a/y" => "y",))))
@p "assembly root: key in both input and output wires" dg(() -> build(Group((; a = Gain(1.0)); input_wires = ("x" => "a/e",), output_wires = ("a/out" => "x",))))
# component test rig
@p "rig root inputs" build(TerrainRig()).structure.root_inputs

# ---- output contracts -----------------------------------------------------------
struct Engine <: AbstractComponent end
x_init(::Engine) = nothing; y_types(::Engine) = (M_shaft = Float64, P = Float64, ω = Float64)
y_direct(::Engine, _) = (M_shaft = 1.0, P = 2.0, ω = 3.0)
@p "Engine y_types example" dg(() -> build(Engine(); activations = (Float64, ProbeDual)))
@p "bare y: stage returns value; port y" (b = build(IntB(0.0); activations = (Float64, ProbeDual)); (ct(b, ProbeDual, "", :y), Redstone.is_bare(activation(b,Float64).decls[1].outs)))
@p "bare y read by path" (b = build(IntB(1.5)); 1)
struct Pinout <: AbstractComponent end   # misplaced pin: output Pinned, internals walk
x_init(::Pinout) = nothing; u_types(::Pinout) = (e = Float64,); y_types(::Pinout) = (out = Pinned{Float64},)
y_direct(::Pinout, (; u)) = (out = 2u.e,)
@p "misplaced pin: build(world) ok" dg(() -> build(Pinout()))
@p "misplaced pin: Dual activation (again)" (b = build(Pinout()); (try activation(b, ProbeDual); :ok catch e; carriedtypes(e) end))
@p "misplaced pin: activations= at build" msgs(() -> build(Pinout(); activations = (ProbeDual,)))
struct Frozen <: AbstractComponent end   # omitted pin: internals frozen, output walks
x_init(::Frozen) = nothing; u_types(::Frozen) = (e = Float64,); y_types(::Frozen) = (out = Float64,)
y_direct(::Frozen, (; u)) = (buf = zeros(1); buf[1] = u.e; (out = buf[1],))
@p "omitted pin: Dual activation" (b = build(Frozen()); (try activation(b, ProbeDual); :ok catch e; carriedtypes(e) end))
@p "Float64(dual) lossy cast" (try Float64(ProbeDual(1.0, ForwardDiff.Partials((1.0,)))) catch e; typeof(e) end)
# opaque leaf built from build-time data at identity comparison
struct OpaqueFrozenOmit <: AbstractComponent end
x_init(::OpaqueFrozenOmit) = nothing; u_types(::OpaqueFrozenOmit) = (e = Float64,); y_types(::OpaqueFrozenOmit) = (terrain = OffsetField{Float64},)
y_direct(::OpaqueFrozenOmit, (; u)) = (terrain = OffsetField(1.0, zeros(2, 2)),)
@p "omitted pin on opaque built from literal at Dual" (b = build(OpaqueFrozenOmit()); (try activation(b, ProbeDual); :ok catch e; carriedtypes(e) end))
# Freeze
@p "Freeze walking->pinned" dg(() -> build(Group((; g = Gain(1.0), f = Freeze{Float64}(), p = PinnedGain()); local_wires = ("g/out" => "f/u", "f/y" => "p/e"), input_wires = ("in" => "g/e",)); activations = (Float64, ProbeDual)))
@p "Freeze y_types" Redstone.y_types(Freeze{Float64}())
# custom struct
Base.@kwdef struct GearContact{T}
    k::T = 1.0
    n::Int = 0
end
struct GearContactHard
    k::Float64
end
@p "@kwdef GearContact()" typeof(GearContact())
struct GCSrc <: AbstractComponent end
x_init(::GCSrc) = nothing; u_types(::GCSrc) = (e = Float64,); y_types(::GCSrc) = (contact = GearContact{Float64},)
y_direct(::GCSrc, (; u)) = (contact = GearContact(u.e, 1),)
@p "GearContact{Float64} walks" (b = build(GCSrc(); activations = (Float64, ProbeDual)); ct(b, ProbeDual, "", :contact))
struct GCHard <: AbstractComponent end
x_init(::GCHard) = nothing; u_types(::GCHard) = (e = Float64,); y_types(::GCHard) = (contact = GearContactHard,)
y_direct(::GCHard, (; u)) = (contact = GearContactHard(u.e),)
@p "hardcoded Float64 struct: cell at Dual" (b = build(GCHard(); activations = (Float64,)); ct(b, Float64, "", :contact))
@p "hardcoded Float64 struct at Dual" (b = build(GCHard()); (try activation(b, ProbeDual); :ok catch e; carriedtypes(e) end))
struct GCPinned <: AbstractComponent end
x_init(::GCPinned) = nothing; u_types(::GCPinned) = (e = Float64,); y_types(::GCPinned) = (contact = Pinned{GearContactHard},)
y_direct(::GCPinned, (; u)) = (contact = GearContactHard(ForwardDiff.value(u.e)),)
@p "Pinned{GearContactHard} declaration" (b = build(GCPinned(); activations = (Float64,ProbeDual)); ct(b, ProbeDual, "", :contact))
# nested type params
@p "retype recursive nested params" retype(ProbeDual, GearContact{Inner{Float64}})
# mutable params
@p "mutable params pinned in entry walk" retype(ProbeDual, MutW{Float64})
# DeckField sketch
struct DeckField{T}
    heave::T
    pitch::T
    grid::Matrix{Float64}
end
@p "DeckField retype" retype(ProbeDual, DeckField{Float64})
@p "DeckField leaf_types" leaf_types(DeckField{Float64})
struct Deck <: AbstractComponent grid::Matrix{Float64} end
x_init(::Deck) = (heave = 0.0, pitch = 0.0); y_types(::Deck) = (deck = DeckField{Float64},)
y_state(c::Deck, (; x)) = (deck = DeckField(x.heave, x.pitch, c.grid),); x_deriv(::Deck, _) = (heave = 1.0, pitch = 0.0)
struct DeckQ <: AbstractComponent end
x_init(::DeckQ) = nothing; u_types(::DeckQ) = (deck = DeckField{Float64},); y_types(::DeckQ) = (h = Float64,)
y_direct(::DeckQ, (; u)) = (h = u.deck.heave * u.deck.grid[1, 1] + u.deck.pitch,)
@p "Deck -> DeckQ at Dual" (b = build(Group((; d = Deck(ones(2, 2)), q = DeckQ()); local_wires = ("d/deck" => "q/deck",)); activations = (Float64, ProbeDual));
                           (ct(b, ProbeDual, "d", :deck), ct(b, ProbeDual, "q", :h)))
struct DeckPinnedSrc <: AbstractComponent grid::Matrix{Float64} end
x_init(::DeckPinnedSrc) = nothing; y_types(::DeckPinnedSrc) = (deck = Pinned{DeckField{Float64}},)
y_direct(c::DeckPinnedSrc, _) = (deck = DeckField(0.0, 0.0, c.grid),)
@p "static terrain (pinned) -> DeckQ" dg(() -> build(Group((; d = DeckPinnedSrc(ones(2, 2)), q = DeckQ()); local_wires = ("d/deck" => "q/deck",)); activations = (Float64, ProbeDual)))
# constructibility at T
struct Strict{T}; a::T; Strict{T}(a::Float64) where {T} = new{T}(a); end
struct StrictIn <: AbstractComponent end
x_init(::StrictIn) = nothing; u_types(::StrictIn) = (s = Strict{Float64},); y_types(::StrictIn) = (out = Float64,); y_direct(::StrictIn, _) = (out = 1.0,)
@p "constructibility at T: root input at Dual" (b = build(StrictIn()); (try activation(b, ProbeDual); :ok catch e; carriedtypes(e) end))
struct StrictOut <: AbstractComponent end
x_init(::StrictOut) = nothing; u_types(::StrictOut) = (e = Float64,); y_types(::StrictOut) = (s = Strict{Float64},); y_direct(::StrictOut, (; u)) = (s = Strict{typeof(u.e)}(1.0),)
@p "constructibility at T: output at Dual" (b = build(StrictOut()); (try activation(b, ProbeDual); :ok catch e; carriedtypes(e) end))

# ---- state vocabulary messages --------------------------------------------------
struct RQ end
struct SV{K} <: AbstractComponent end
y_types(::SV) = (out = Float64,); y_direct(::SV, _) = (out = 1.0,)
x_init(::SV{:int}) = (gear_count = 3,)
x_init(::SV{:wrapper}) = (q_nb = RQ(),)
x_init(::SV{:nested}) = (pose = (a = 1.0, b = 2.0),)
x_init(::SV{:bare_int}) = 3
x_init(::SV{:bare_wrapper}) = RQ()
s_init(::SV{:str}) = (label = "x",)
s_init(::SV{:bare_str}) = "text"
m_init(::SV{:mstr}) = "text"
x_init(::SV{:mstr}) = nothing
x_init(::SV{:vec}) = (v = [1.0],)
for K in (:int, :wrapper, :nested, :bare_int, :bare_wrapper, :str, :bare_str, :mstr)
    @eval @p string("state msg ", $(QuoteNode(K))) msgs(() -> build(SV{$(QuoteNode(K))}()))
end
@p "state diag reasons" [(K, dg(() -> build(SV{K}()))) for K in (:int, :wrapper, :nested, :bare_int, :bare_wrapper, :str)]
# stop_reason shadow / family
@p "StopRequest root stop_reason via requesters" (b = build(StopRequest(reason = "r")); only(activation(b, Float64).layout.requesters))

# ---- round 2 --------------------------------------------------------------------
@p "Float64(Dual nonzero partial)" (try Float64(ForwardDiff.Dual{ProbeTag}(1.0, 1.0)) catch e; (typeof(e), sprint(showerror, e)[1:120]) end)
@p "convert(Float64, Dual nonzero)" (try convert(Float64, ForwardDiff.Dual{ProbeTag}(1.0, 1.0)) catch e; (typeof(e), sprint(showerror, e)[1:120]) end)
@p "convert(Float64, Dual zero partial)" (try convert(Float64, ForwardDiff.Dual{ProbeTag}(1.0, 0.0)) catch e; (typeof(e), sprint(showerror, e)[1:120]) end)
@p "GearContactHard ctor with Dual nonzero" (try GearContactHard(ForwardDiff.Dual{ProbeTag}(1.0, 1.0)) catch e; (typeof(e), sprint(showerror, e)[1:160]) end)
@p "GCHard full message" msgs(() -> activation(build(GCHard()), ProbeDual))
struct Q{T}; a::T; function Q{T}() where {T}; T === Float64 || error("Q is not constructible at $T"); new{T}(1.0); end; end
struct QIn <: AbstractComponent end
x_init(::QIn) = nothing; u_types(::QIn) = (q = Q{Float64},); y_types(::QIn) = (out = Float64,); y_direct(::QIn, _) = (out = 1.0,)
@p "constructibility Q root input nominal" dg(() -> build(QIn()))
@p "constructibility Q root input at Dual" (b = build(QIn()); (try activation(b, ProbeDual); :ok catch e; carriedtypes(e) end))
# the discrete store and modes at a Dual activation
@p "discrete s at ProbeDual" (b = build(DiscreteAccumulator(1.0); activations = (Float64, ProbeDual)); activation(b, ProbeDual).decls[1].s)
@p "ModeComp m at ProbeDual (decl fields)" (b = build(ModeComp(); activations = (Float64, ProbeDual)); fieldnames(typeof(activation(b, ProbeDual).decls[1])))
# discrete producer held at Float64 under a Dual sweep, consumer gathers mixed
@p "mixed frozen discrete -> walking continuous at Dual" dg(() -> build(Group((; a = DiscreteAccumulator(1.0), g = Gain(1.0)); local_wires = ("a/u" => "g/e",), input_wires = ("in" => "a/e",)); activations = (ProbeDual,)))
# pinned entry on an Int/bool
struct PinInt <: AbstractComponent end
x_init(::PinInt) = nothing; u_types(::PinInt) = (e = Pinned{Int},); y_types(::PinInt) = (out = Float64,); y_direct(::PinInt, _) = (out = 1.0,)
@p "Pinned{Int} accepted" dg(() -> build(PinInt(); activations = (ProbeDual,)))
# Pinned root input cell on bare pinned entry
@p "bare Pinned root input cell at Dual" (b = build(Bad{:bare_pinned_u}(); activations = (Float64, ProbeDual)); ct(b, ProbeDual, "", :u))
# a root input mixed leaves in one struct with Pinned wrapper
@p "root input from Pinned{SVector} alone at Dual" (b = build(Vec3PinFan(); activations = (Float64, ProbeDual)); ct(b, ProbeDual, "", :e))
# sim
@p "sim bare u root: set/stage by u" (sim = Simulation(IntB(0.0); Δt_frame = 1//10); init!(sim, set(u = (u = 1.5,))); port(sim, "", :u))
@p "message D-265 nested" msgs(() -> build(Bad{:nested_u}()))
@p "message nested_y" msgs(() -> build(Bad{:nested_y}()))
@p "message abstract at root + conflict" msgs(() -> build(Group((; a = Gain(1.0), v = Vec2In()); input_wires = ("in" => ("a/e", "v/e"),))))
@p "walk clause in decidable at structure step: stage never ran" (ran = Ref(0); 1)
struct CountG <: AbstractComponent end
const RAN = Ref(0)
x_init(::CountG) = nothing; u_types(::CountG) = (e = Pinned{Float64},); y_types(::CountG) = (out = Float64,)
y_direct(::CountG, (; u)) = (RAN[] += 1; (out = u.e,))
@p "walk clause refusal runs no stage" (RAN[] = 0; r = dg(() -> build(Group((; g = Gain(1.0), c = CountG()); local_wires = ("g/out" => "c/e",), input_wires = ("in" => "g/e",)))); (r, RAN[]))
@p "unconnected input / typo" dg(() -> build(Group((; g = Gain(1.0)); input_wires = ())))
@p "derive: abstract root co-consumer discrete" dg(() -> build(Group((; a = Gain(1.0), d = DiscreteAccumulator(1.0)); input_wires = ("in" => ("a/e", "d/e"),)); activations = (ProbeDual,)))
@p "freeze Freeze{V} u bare" (Redstone.u_types(Freeze{Float64}()))
@p "StopFlag in x" (b = build(Group((; sr = StopRequest(), g = Gain(1.0)); local_wires = (), input_wires = ("go" => "sr/u", "in" => "g/e"))); 1)

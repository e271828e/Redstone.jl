using Test
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff
include("/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/imports.jl")
include("/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/utils.jl")
include("/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/fixtures.jl")
import Redstone

reasons(f) = (e = failure(f); e isa DiagnosticError ?
    [(string(nameof(typeof(d))), hasproperty(d, :reason) ? d.reason : nothing, hasproperty(d,:name) ? d.name : nothing) for d in (e.carried isa Vector ? e.carried : [e.carried])] : e)

# --- A. state leaves
struct W1; a::Float64; end
@enum Col red green
for (tag, xi) in (("Int", (n = 1,)), ("Bool", (b = true,)), ("enum", (c = red,)), ("Float32", (q = 1.0f0,)),
                  ("nested", (p = (a = 1.0,),)), ("struct", (w = W1(1.0),)), ("String", (s = "a",)),
                  ("SVec32", (v = SVector(1.0f0, 2.0f0),)), ("bareInt", 1), ("bareSV", SVector(1.0, 2.0)),
                  ("mixed", (a = 1.0, v = SVector(1.0, 2.0), M = SMatrix{2,2}(1.0, 2, 3, 4))))
    @eval begin
        struct $(Symbol("XS_", tag)) <: AbstractComponent end
        Redstone.x_init(::$(Symbol("XS_", tag))) = $xi
        Redstone.y_types(::$(Symbol("XS_", tag))) = (y = Float64,)
        Redstone.y_state(::$(Symbol("XS_", tag)), _) = (y = 0.0,)
        Redstone.x_deriv(::$(Symbol("XS_", tag)), (; x)) = x
    end
    c = @eval $(Symbol("XS_", tag))()
    println("probe:A ", tag, " => ", reasons(() -> build(single(c))))
end

# --- C. store fields
struct HoldsVec; v::Vector{Float64}; end
struct HoldsSym; s::Symbol; end
struct Nested; a::Int; b::SVector{2,Float64}; c::Col; d::Bool; end
for (tag, si) in (("Int", (n = 1,)), ("enum", (c = red,)), ("Bool", (b = true,)), ("SVec", (v = SVector(1.0, 2.0),)),
                  ("nestedStruct", (s = Nested(1, SVector(1.0, 2.0), red, true),)), ("Symbol", (l = :a,)),
                  ("String", (l = "a",)), ("Vector", (v = [1.0],)), ("HoldsVec", (h = HoldsVec([1.0]),)),
                  ("HoldsSym", (h = HoldsSym(:a),)), ("bareSymbol", :a), ("bareString", "x"),
                  ("NTofSym", (a = (b = :c,),)), ("float32", (a = 1.0f0,)), ("Int8", (a = Int8(1),)))
    @eval begin
        struct $(Symbol("SS_", tag)) <: AbstractComponent end
        Redstone.s_init(::$(Symbol("SS_", tag))) = $si
        Redstone.y_types(::$(Symbol("SS_", tag))) = (y = Float64,)
        Redstone.y_state(::$(Symbol("SS_", tag)), _) = (y = 0.0,)
        Redstone.s_update(::$(Symbol("SS_", tag)), (; s)) = s
    end
    c = @eval $(Symbol("SS_", tag))()
    println("probe:C ", tag, " => ", reasons(() -> build(single(c))))
end
# modes
for (tag, mi) in (("String", (l = "a",)), ("Sym", (l = :a,)), ("bareBool", true))
    @eval begin
        struct $(Symbol("MS_", tag)) <: AbstractComponent end
        Redstone.x_init(::$(Symbol("MS_", tag))) = nothing
        Redstone.m_init(::$(Symbol("MS_", tag))) = $mi
        Redstone.y_types(::$(Symbol("MS_", tag))) = (y = Float64,)
        Redstone.y_state(::$(Symbol("MS_", tag)), _) = (y = 0.0,)
    end
    c = @eval $(Symbol("MS_", tag))()
    println("probe:C-m ", tag, " => ", reasons(() -> build(single(c))))
end
println("probe:default_name ", Redstone.default_name(x_init), Redstone.default_name(s_init), Redstone.default_name(m_init))

# --- D. round trip
let x = (q = SVector(1.0, 2.0), a = 3.0, M = SMatrix{2,2}(1.0, 2, 3, 4))
    XT = typeof(x); n = Redstone.nleaves(XT); buf = zeros(n + 2)
    Redstone.flatten!(buf, 1, x)
    println("probe:D roundtrip ", Redstone.reconstruct(XT, buf, 1) == x, " nleaves=", n, " buf=", buf)
    println("probe:D Dual ", Redstone.reconstruct(XT, buf, 1) isa XT)
    println("probe:D symbol opaque ", Redstone.nleaves(Symbol), Redstone.leaf_types(typeof((a = :x,))))
end

# --- E. workspace scalar per tier, x_projection, derivative shape
const SEEN = Pair{Symbol,Any}[]
struct WsC <: AbstractComponent end
Redstone.x_init(::WsC) = (a = 1.0, v = SVector(1.0, 2.0))
Redstone.u_types(::WsC) = (u = Float64,)
Redstone.y_types(::WsC) = (y = Float64,)
Redstone.ws_init(::WsC, ::Type{T}) where {T} = (push!(SEEN, :cont => T); (tmp = Vector{T}(undef, 1),))
Redstone.y_state(::WsC, (; x, ws)) = (ws.tmp[1] = x.a; (y = ws.tmp[1],))
Redstone.x_deriv(::WsC, (; x, u, ws)) = (a = -x.a + u.u, v = -x.v)
Redstone.x_projection(::WsC, x) = x
struct WsD <: AbstractComponent end
Redstone.s_init(::WsD) = (n = 0,)
Redstone.y_types(::WsD) = (y = Float64,)
Redstone.ws_init(::WsD, ::Type{T}) where {T} = (push!(SEEN, :disc => T); (tmp = Vector{T}(undef, 1),))
Redstone.y_state(::WsD, (; s)) = (y = 1.0,)
Redstone.s_update(::WsD, (; s, ws)) = s
g = Group((; c = WsC(), d = WsD()); input_wires = ("in" => "c/u",))
b = build(g; activations = (Float64, ProbeDual))
println("probe:E ws seen ", SEEN)
println("probe:E applicable x_projection ", hasmethod(Redstone.x_projection, Tuple{WsC,Any,Any}))
m = Model(b, Float64; Δt_frame = 1//100)
println("probe:E ModelState fields ", fieldnames(Redstone.ModelState))
println("probe:E ModelState hasws ", :ws in fieldnames(Redstone.ModelState))

# derivative shape
struct BadDer1 <: AbstractComponent end
Redstone.x_init(::BadDer1) = (v = SVector(1.0, 2.0),)
Redstone.y_types(::BadDer1) = (y = Float64,)
Redstone.y_state(::BadDer1, (; x)) = (y = x.v[1],)
Redstone.x_deriv(::BadDer1, (; x)) = (v = 1.0,)
struct BadDer2 <: AbstractComponent end
Redstone.x_init(::BadDer2) = (a = 1.0,)
Redstone.y_types(::BadDer2) = (y = Float64,)
Redstone.y_state(::BadDer2, (; x)) = (y = x.a,)
Redstone.x_deriv(::BadDer2, (; x)) = (a = SVector(1.0),)
struct BadDer3 <: AbstractComponent end
Redstone.x_init(::BadDer3) = (a = 1.0,)
Redstone.y_types(::BadDer3) = (y = Float64,)
Redstone.y_state(::BadDer3, (; x)) = (y = x.a,)
Redstone.x_deriv(::BadDer3, (; x)) = (a = 1,)
for c in (BadDer1(), BadDer2(), BadDer3())
    println("probe:E ", typeof(c), " => ", reasons(() -> build(single(c))))
end
# projection with ws arg? bundle fields of x_projection

# --- F. second round
struct BareSym <: AbstractComponent end
Redstone.s_init(::BareSym) = :a
Redstone.y_types(::BareSym) = (y = Float64,)
Redstone.y_state(::BareSym, (; s)) = (y = s === :a ? 1.0 : 0.0,)
Redstone.s_update(::BareSym, (; s)) = :b
let e = failure(() -> build(single(BareSym())))
    println("probe:F bareSym ", e === nothing ? "builds" : sprint(showerror, e))
end
struct ConstDer <: AbstractComponent end
Redstone.x_init(::ConstDer) = (a = 1.0, v = SVector(1.0, 2.0))
Redstone.y_types(::ConstDer) = (y = Float64,)
Redstone.y_state(::ConstDer, (; x)) = (y = x.a,)
Redstone.x_deriv(::ConstDer, (; x)) = (a = 0.0, v = SVector(0.0, 1.0))
let b = build(single(ConstDer()); activations = (Float64, ProbeDual))
    println("probe:F const deriv at Dual builds; xt=", typeof(Redstone.activation(b, ProbeDual).decls[1].x))
end
# Pinned state leaf? discrete frozen at Dual: cell type
struct DiscOut <: AbstractComponent end
Redstone.s_init(::DiscOut) = (n = 1.0,)
Redstone.y_types(::DiscOut) = (y = Float64,)
Redstone.y_state(::DiscOut, (; s)) = (y = s.n,)
Redstone.s_update(::DiscOut, (; s)) = s
b = build(single(DiscOut()); activations = (Float64, ProbeDual))
act = Redstone.activation(b, ProbeDual)
println("probe:F disc store type at Dual ", [typeof(d.s) for d in act.decls if hasproperty(d, :s)])
println("probe:F act fields ", fieldnames(typeof(act)), " decl ", fieldnames(typeof(act.decls[1])))
println("probe:F events nominal=", length(b.events.names), " ")

module L6bProbe
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const T = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/"
include(T * "imports.jl")
include(T * "fixtures.jl")
include(T * "utils.jl")

function kinds(f)
    try
        f(); return "no throw"
    catch err
        err isa Redstone.DiagnosticError || return "threw $(typeof(err)): $(sprint(showerror, err))"
        return join(["$(nameof(typeof(d)))" * (hasproperty(d, :reason) ? "(:$(d.reason))" : "") *
                     (hasproperty(d, :declaration) ? "[$(d.declaration)]" : "") for d in diagnostics(err)], ", ")
    end
end
msgs(f) = try f(); "" catch err; join([Redstone.message(d) for d in diagnostics(err)], " | ") end

# D-263: Pinned entry on a discrete leaf
struct PinDisc <: AbstractComponent end
s_init(::PinDisc) = (n = 0,)
u_types(::PinDisc) = (a = Pinned{Float64},)
y_types(::PinDisc) = (n = Int,)
y_state(::PinDisc, (; s)) = (n = s.n,)
s_update(::PinDisc, (; s)) = (n = s.n + 1,)

# D-263: neither store
struct NoStore <: AbstractComponent end
y_types(::NoStore) = (y = Float64,)
y_state(::NoStore, (; t)) = (y = 1.0,)

# D-263: stateless with no outputs
struct Mute <: AbstractComponent end
x_init(::Mute) = nothing
u_types(::Mute) = (u = Float64,)

# D-263: discrete ws_init receives Float64
const WS_T = Any[]
struct DiscWS <: AbstractComponent end
s_init(::DiscWS) = (n = 0,)
y_types(::DiscWS) = (n = Int,)
ws_init(::DiscWS, ::Type{S}) where {S} = (push!(WS_T, S); (buf = zeros(S, 1),))
y_state(::DiscWS, (; s)) = (n = s.n,)
s_update(::DiscWS, (; s)) = (n = s.n + 1,)

# D-362: m_init on a discrete leaf
struct DiscMode <: AbstractComponent end
s_init(::DiscMode) = (n = 0,)
m_init(::DiscMode) = (on = false,)
y_types(::DiscMode) = (n = Int,)
y_state(::DiscMode, (; s)) = (n = s.n,)
s_update(::DiscMode, (; s)) = (n = s.n + 1,)

# D-438: (;) store
struct EmptyX <: AbstractComponent end
x_init(::EmptyX) = (;)
y_types(::EmptyX) = (y = Float64,)
y_state(::EmptyX, (; t)) = (y = 1.0,)
struct EmptyM <: AbstractComponent end
x_init(::EmptyM) = nothing
m_init(::EmptyM) = (;)
y_types(::EmptyM) = (y = Float64,)
y_state(::EmptyM, (; t)) = (y = 1.0,)

# D-308/D-438: Int in bare x_init
struct IntX <: AbstractComponent end
x_init(::IntX) = 1
y_types(::IntX) = (y = Float64,)
y_state(::IntX, (; x)) = (y = 1.0,)
x_deriv(::IntX, (; x)) = 0

# D-362: both stores
struct BothStores <: AbstractComponent end
x_init(::BothStores) = (a = 0.0,)
s_init(::BothStores) = (n = 0,)
y_types(::BothStores) = (y = Float64,)
y_state(::BothStores, (; x)) = (y = x.a,)
x_deriv(::BothStores, (; x)) = (a = 0.0,)

# D-170: a face name in both boundary declarations; an input fed twice
struct Src <: AbstractComponent end
x_init(::Src) = nothing
y_types(::Src) = (y = Float64,)
y_state(::Src, (; t)) = (y = 1.0,)

println("P1 pinned discrete: ", kinds(() -> build(single(PinDisc()))))
println("P2 neither store: ", kinds(() -> build(single(NoStore()))))
println("P3 stateless no outputs: ", kinds(() -> build(single(Mute()))))
m = Model(single(DiscWS()); Δt_frame = 1//10)
println("P4 discrete ws_init scalars: ", unique(WS_T))
empty!(WS_T)
try; Model(single(DiscWS()), ForwardDiff.Dual{Nothing,Float64,1}; Δt_frame = 1//10); catch e; println("P4b err ", typeof(e)); end
println("P4b discrete ws_init at Dual activation: ", unique(WS_T))
println("P5 m_init discrete: ", kinds(() -> build(single(DiscMode()))))
println("P6 empty x: ", kinds(() -> build(single(EmptyX()))), " :: ", msgs(() -> build(single(EmptyX()))))
println("P6b empty m: ", kinds(() -> build(single(EmptyM()))), " :: ", msgs(() -> build(single(EmptyM()))))
println("P7 Int bare x: ", kinds(() -> build(single(IntX()))))
try; build(single(IntX())); catch e; d = only(diagnostics(e)); println("P7b field name: ", d.name); end
println("P8 both stores: ", kinds(() -> build(single(BothStores()))))
println("P9 face both sides: ", kinds(() -> build(Group((; a = Src(), n = Negator());
    input_wires = ("q" => "n/u",), output_wires = ("a/y" => "q",)))))
println("P10 input fed twice: ", kinds(() -> build(Group((; a = Src(), b = Src(), n = Negator());
    local_wires = ("a/y" => "n/u", "b/y" => "n/u")))))
println("P11 Group fields: ", fieldnames(Group))
println("P12 set kwargs: ", Base.kwarg_decl(first(methods(Redstone.set))))
println("P13 fragment defined: ", isdefined(Redstone, :fragment))
println("P14 Deployment kwargs: ", Base.kwarg_decl(first(methods(Redstone.Deployment))))
println("P15 ModelState fields: ", fieldnames(Redstone.ModelState))
# D-438: show of a build with bare stores
txt = sprint(show, MIME"text/plain"(), build(bare_world()))
println("P16 build show lines with acc/tick/latch:")
for l in split(txt, '\n'); occursin(r"acc|tick|latch", l) && println("   ", l); end
# D-438: headless reads, via public selectors
b = build(bare_world())
println("P17 get_state default leaf: ", repr(get_state("acc").leaf))
end

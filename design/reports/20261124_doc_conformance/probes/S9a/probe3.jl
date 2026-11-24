# S9a probe 3: user-function call counts in the nominal evaluation, and the activation re-run
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff
include("/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/imports.jl")
include("/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/fixtures.jl")
const COUNT = Dict{Symbol,Int}()
bump(k) = COUNT[k] = get(COUNT, k, 0) + 1
struct Counted <: AbstractComponent end
x_init(::Counted) = (q = 0.0,)
u_types(::Counted) = (a = Float64,)
y_types(::Counted) = (s = Float64, d = Float64)
m_init(::Counted) = (st = :a,)
ws_init(::Counted, ::Type{T}) where {T<:Real} = (bump(:ws_init); (v = Vector{T}(undef, 1),))
y_state(::Counted, (; x)) = (bump(:y_state); (s = x.q,))
y_direct(::Counted, (; u, ws)) = (bump(:y_direct); (d = u.a,))
x_deriv(::Counted, (; x, u)) = (bump(:x_deriv); (q = u.a,))
cg(::Counted, (; u)) = (bump(:guard); u.a ≥ 1.0)
ch(::Counted, (; m)) = (bump(:handler); (m = (st = :b,),))
state_events(::Counted) = (e = StateEvent(cg, ch),)
w = Group((c = Counted(),); input_wires = ("r" => "c/a",))
b = build(w)
println("probe:C1 counts after build ", sort(collect(COUNT)))
empty!(COUNT)
Redstone.activation(b, Redstone.ProbeDual)
println("probe:C2 counts after activation(ProbeDual) ", sort(collect(COUNT)))

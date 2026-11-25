const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test
include(joinpath(W, "imports.jl")); include(joinpath(W, "fixtures.jl")); include(joinpath(W, "utils.jl"))
import Redstone: mutable_position, retype, _opaque
say(t, x) = println(rpad(t, 44), " => ", x)
try_(f) = try f() catch e; (typeof(e), first(sprint(showerror, e), 250)) end
# --- S6c: BigFloat / BigInt
# aliasing: a stage that mutates a BigFloat it keeps in its workspace
struct BigAcc <: AbstractComponent end
s_init(::BigAcc) = (n = 0,)
ws_init(::BigAcc, ::Type{T}) where {T} = (b = BigFloat(0),)
y_types(::BigAcc) = (b = BigFloat,)
y_state(::BigAcc, (; s, ws)) = (ccall((:mpfr_set_d, :libmpfr), Int32, (Ref{BigFloat}, Float64, Int32), ws.b, Float64(s.n), 0); (b = ws.b,))
s_update(::BigAcc, (; s)) = (n = s.n + 1,)
say("alias build/run", try_() do
    sim = Simulation(single(BigAcc()); Δt_frame = 1//10)
    init!(sim); run!(sim; t_end = 0.5)
    snaps = sim.run.log
    (port(sim, "c", :b), "log type", typeof(snaps))
end)
struct BigOut <: AbstractComponent end
x_init(::BigOut) = (q = 0.0,)
y_types(::BigOut) = (b = BigFloat,)
y_state(::BigOut, (; x)) = (b = BigFloat(x.q) + 1,)
x_deriv(::BigOut, (; x)) = (q = 1.0,)
say("BigFloat port nominal", try_() do; s = Simulation(single(BigOut()); Δt_frame = 1//100); init!(s); run!(s; t_end = 0.02); port(s, "c", :b) end)
say("BigFloat port at Dual", try_() do; m = Model(single(BigOut()), ForwardDiff.Dual{:p,Float64,2}; Δt_frame = 1//100); init!(m); port(m,"c",:b) end)
struct BigIn <: AbstractComponent end
x_init(::BigIn) = nothing
u_types(::BigIn) = (u = BigFloat,)
y_types(::BigIn) = (y = Float64,)
y_direct(::BigIn, (; u)) = (y = Float64(u.u),)
say("BigFloat root input", try_() do; b = build(fed(BigIn())); (b.structure.root_inputs, b.structure.root_types) end)
say("BigFloat root run", try_() do; s = Simulation(fed(BigIn()); Δt_frame=1//10); init!(s, set(u = (in = big"0.1",))); run!(s; t_end=0.2); (port(s,"c",:y), checkpoint(s).state.table |> typeof) end)
struct BigX <: AbstractComponent end
x_init(::BigX) = (q = big"0.0",)
y_types(::BigX) = (y = Float64,)
y_state(::BigX, (; x)) = (y = Float64(x.q),)
x_deriv(::BigX, (; x)) = (q = big"1.0",)
say("BigFloat x_init", try_() do; build(single(BigX())) end)
struct BigS <: AbstractComponent end
s_init(::BigS) = (q = big"0.0",)
y_types(::BigS) = (y = Float64,)
y_state(::BigS, (; s)) = (y = Float64(s.q),)
s_update(::BigS, (; s)) = (q = s.q,)
say("BigFloat s_init", try_() do; build(single(BigS())) end)
struct NT{T}; a::T; end
say("mutable_position(NT{BigFloat})", mutable_position(NT{BigFloat}))
say("_opaque NT{BigFloat}", _opaque(NT{BigFloat}))
say("mutable_position(SVector{2,BigFloat})", mutable_position(SVector{2,BigFloat}))
mutable struct MyReal <: Real; v::Float64; end
say("mutable_position(MyReal)", mutable_position(MyReal))
struct MyOut <: AbstractComponent; r::MyReal; end
x_init(::MyOut) = (q = 0.0,)
y_types(::MyOut) = (b = MyReal,)
y_state(c::MyOut, (; x)) = (c.r.v = x.q; (b = c.r,))
x_deriv(::MyOut, (; x)) = (q = 1.0,)
say("mutable user Real aliasing in log", try_() do
    s = Simulation(single(MyOut(MyReal(0.0))); Δt_frame = 1//10); init!(s)
    r0 = port(s, "c", :b); v0 = r0.v
    run!(s; t_end = 0.5); (v0, r0.v) end)
say("AbstractFloat Real scalars", ismutabletype.((BigFloat, BigInt, Rational{BigInt}, Float16)))
# S6c-001 opaque parts
say("handle w Matrix", mutable_position(HeightField))
# K9b-041
struct DeckT{T}; heave::T; grid::Matrix{T}; end
say("retype DeckT", retype(ForwardDiff.Dual{:p,Float64,2}, DeckT{Float64}))
struct DeckG{T,G}; heave::T; grid::G; end
say("retype DeckG Matrix param", retype(ForwardDiff.Dual{:p,Float64,2}, DeckG{Float64,Matrix{Float64}}))

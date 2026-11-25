const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test
include(joinpath(W, "imports.jl")); include(joinpath(W, "fixtures.jl")); include(joinpath(W, "utils.jl"))
say(t, x) = println(rpad(t, 44), " => ", x)
try_(f) = try f() catch e; (typeof(e), first(sprint(showerror, e), 220)) end
T = Redstone.Tracer{true}
u = T(1.5, UInt64(0)); g = T(1.5, UInt64(1))
for (n,f) in (("Float64",Float64),("Int", x->Int(T(2.0,x.dependencies))),("<", x->x<2))
    say("$n untagged/tagged", (try_(()->f(u)), try_(()->f(g)))) end
# does an untagged Float64 in a member cost the exact (global) classification?
struct Loopy <: AbstractComponent; k::Float64; conv::Bool; end
x_init(::Loopy) = (q = 0.0,)
u_types(::Loopy) = (u = Float64,)
y_types(::Loopy) = (y = Float64,)
table(q) = q > 0 ? 1.0 : 2.0
y_direct(c::Loopy, (; x, u)) = (y = c.k * u.u + (c.conv ? table(Float64(x.q)) : x.q),)
x_deriv(::Loopy, (; x)) = (q = -x.q,)
struct Dead2 <: AbstractComponent; end
x_init(::Dead2) = (q = 0.0,)
u_types(::Dead2) = (u = Float64,)
y_types(::Dead2) = (y = Float64,)
y_direct(::Dead2, (; x, u)) = (y = 0 * u.u + x.q,)
x_deriv(::Dead2, (; x)) = (q = -x.q,)
loop2(a,b) = Group((a=a,b=b); local_wires=("a/y"=>"b/u","b/y"=>"a/u"))
for conv in (false,true)
    e = failure(() -> build(loop2(Loopy(2.0,conv), Loopy(1.0,false))))
    d = e isa DiagnosticError ? (e.carried isa Vector ? e.carried : [e.carried]) : e
    for x in d; say("conv=$conv", (typeof(x), [(f,getfield(x,f)) for f in fieldnames(typeof(x)) if f in (:classification,:verdict,:trace,:traced,:dead,:modes,:evidence)])); say("", first(message(x),600)); end
end
# S8d-042
struct Slash <: AbstractComponent end
x_init(::Slash) = nothing
u_types(::Slash) = NamedTuple{(Symbol("p/q"),)}((Float64,))
y_types(::Slash) = NamedTuple{(Symbol("r/s"),)}((Float64,))
y_direct(::Slash, (; u)) = NamedTuple{(Symbol("r/s"),)}((u[1],))
say("slash root", try_(() -> build(Slash()).structure.root_inputs))
say("slash child wired", try_(() -> (b=build(Group((k=Slash(),); input_wires=("in"=>"k/p/q",), output_wires=("k/r/s"=>"o",))); b.structure.root_inputs)))
say("slash at root run", try_(() -> (s=Simulation(Slash(); Δt_frame=1//10); init!(s,set(u=NamedTuple{(Symbol("p/q"),)}((1.0,)))); port(s,"",Symbol("r/s")))))
# S8c-174
struct TwoT <: AbstractComponent; a::NamedTuple; b::NamedTuple; end
struct Leaf1 <: AbstractComponent end
x_init(::Leaf1)=nothing; y_types(::Leaf1)=(y=Float64,); y_direct(::Leaf1,_)=(y=1.0,)
local_wires(::TwoT)=()
transparent_container(::TwoT)=(:a,:b)
say("two containers", try_(() -> build(TwoT((k=Leaf1(),),(j=Leaf1(),)))))

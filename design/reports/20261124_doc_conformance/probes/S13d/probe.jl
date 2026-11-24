using Redstone, StaticArrays, JSON
using Redstone: _kind_marker, build, Deployment, descriptor, Group, Absolute, Relative
println("== markers")
@enum Gear a1 a2
abstract type AbsEnum end
struct Pose; x::Float64; y::Float64; end
struct Empty end
struct Holder; f::Function; end
mk(T) = _kind_marker(T)
for T in (Bool, Gear, Symbol, Int8, Float32, AbstractFloat, Rational{Int}, Real, Integer,
          SVector{3,Float64}, SMatrix{2,2,Float64,4}, StaticVector, SVector{2,Gear},
          Function, typeof(sin), typeof(let k=2.0; x->k*x end), Pose, @NamedTuple{a::Float64,b::Int},
          Tuple{Int,Float64}, NamedTuple{(),Tuple{}}, Empty, Holder, String, Any, Enum, Number, Vector{Float64}, Ref{Int})
    println(rpad(string(T), 45), " ", mk(T))
end
println("== tuple fields via descriptor: see above")
println("== module link")
module Foo
using Redstone
export FooC
"""Links [`Foo`](@ref) and [`FooC`](@ref) and [`Redstone.Pinned`](@ref) and [`Pinned`](@ref)."""
struct FooC <: Redstone.AbstractComponent end
Redstone.x_init(::FooC) = nothing
Redstone.y_types(::FooC) = (y = Float64,)
Redstone.y_state(::FooC, ::Any) = (y = 1.0,)
end
println(Redstone._docstring(Foo.FooC))
println(Redstone._qualified_name(Foo.FooC))
struct Foo2; a::NamedTuple; e::NamedTuple; g::Vector{Int}; end
Foo2() = Foo2((b=1,c=(d=2,)),(;),collect(1:100))
println("== descriptor")
struct Gain <: Redstone.AbstractComponent; k::Float64; end
Redstone.x_init(::Gain) = nothing
Redstone.u_types(::Gain) = (u = Float64,)
Redstone.y_types(::Gain) = (y = Float64,)
Redstone.y_state(g::Gain, (; u)) = (y = g.k * u.u,)
struct Tick <: Redstone.AbstractComponent end
Redstone.s_init(::Tick) = (n = 0,)
Redstone.y_types(::Tick) = (n = Int,)
Redstone.y_state(::Tick, (; s)) = (n = s.n,)
Redstone.s_update(::Tick, (; s)) = (n = s.n + 1,)
b = build(Foo.FooC())
d = descriptor(b)
println(keys(d), " ", d.format_version)
println(keys(d.build), " ", keys(d.build.structure))
println(d.build.structure.nodes)
println(d.build.structure.grid, d.build.structure.root_inputs)
println(d.build.events, d.build.outputs)
dep = Deployment(b; Δt_frame = 1//100)
dd = descriptor(dep)
println(keys(dd.deployment))
println(dd.deployment.schedule, dd.deployment.algorithm, dd.deployment.h_max, dd.deployment.dt_base)
println(JSON.json(dd)[1:200])
println("== grid with anchors + rates")
m = Group((; c = Redstone.Library.Constant(1.0), g = Gain(2.0)); local_wires = ("c/y" => "g/u",),
          sample_times = (; g = Absolute(1//10, 1//20)))
m = Group((; t = Tick(), c = Redstone.Library.Constant(1.0)); sample_times = (; t = Absolute(1//10, 1//20)))
println(try d2 = descriptor(build(m)); (d2.build.structure.anchors, d2.build.structure.grid, [ (n.path, get(n,:rates,nothing), get(n,:timing,nothing)) for n in d2.build.structure.nodes]) catch e; sprint(showerror, e) end)
println("== failure")
fm = Group((; a = Gain(1.0), b = Gain(1.0)); local_wires = ("a/y" => "b/u", "b/y" => "a/u"))
err = try build(fm) catch e e end
println(typeof(err))
f = descriptor(err)
println(keys(f.failure), f.failure.policy, [keys(x) for x in f.failure.diagnostics])
fm2 = Group((; a = Gain(1.0)); local_wires = ("zz/y" => "a/u",))
err2 = try build(fm2) catch e e end
f2 = descriptor(err2); println(keys(f2.failure), f2.failure.diagnostics)
println("== params")
println(Redstone._parameters(Foo2()))

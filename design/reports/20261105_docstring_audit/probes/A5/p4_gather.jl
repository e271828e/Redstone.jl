module P4
using Test
const W = pwd()
include(W * "/test/repl.jl")
include(W * "/test/utils.jl")
using InteractiveUtils
using Base.Threads: @spawn
two() = Group((; s = Sum(sa = 1.0, sb = 1.0)); input_wires = ("a" => "s/a", "b" => "s/b"))
const U = (a = 0.0, b = 0.0)
struct Out <: AbstractBinding end
is_output(::Out) = true
reads(::Out) = (; echo = get_input("a"), e = get_output("s", "e"))
map_output(nt, ::Out) = nt.echo + nt.e

mutable struct Tele <: AbstractDevice
    allocs::Vector{Int}
    sum::Float64
    inferred_ok::Bool
end
# the loop idiom verbatim: no function barrier around the snapshot
function loop(d::Tele, h)
    while running(h)
        s = wait_next_snapshot(h)
        s === nothing && continue
        a0 = Base.gc_bytes()
        nt = gather(h, s)
        a1 = Base.gc_bytes()
        push!(d.allocs, a1 - a0)
        d.sum += nt.echo + nt.e
    end
    nothing
end
sim = Simulation(two(); h = 1//10)
d = Tele(Int[], 0.0, false)
h = attach!(sim, d, Out())
init!(sim, set(u = U))
t = @spawn run!(sim; t_end = 200.0, pace = 200.0)
timedwait(() -> istaskdone(t), 30.0)
a = d.allocs
println("device loop, gather(h, s) with s from wait_next_snapshot: n=", length(a), " median bytes=", isempty(a) ? nothing : sort(a)[div(length(a)+1,2)], " last 5=", a[max(end-4,1):end])

s = latest(sim)
function idiom(h)
    s = latest(h)
    s === nothing && return 0
    a0 = Base.gc_bytes()
    nt = gather(h, s)
    a1 = Base.gc_bytes()
    (a1 - a0) + (nt.echo isa Float64 ? 0 : 1)
end
idiom(h); idiom(h)
println("no barrier from latest(h): bytes ", [idiom(h) for _ in 1:5])
function barrier(h, s)
    a0 = Base.gc_bytes()
    nt = gather(h, s)
    a1 = Base.gc_bytes()
    (a1 - a0) + (nt.echo isa Float64 ? 0 : 1)
end
barrier(h, s); barrier(h, s)
println("past a barrier, concrete snapshot: bytes ", [barrier(h, s) for _ in 1:5])
println("inferred idiom: ", Base.return_types((H) -> gather(H, latest(H)::Snapshot), (typeof(h),)))
println("inferred idiom .echo: ", Base.return_types((H) -> gather(H, latest(H)::Snapshot).echo, (typeof(h),)))
println("inferred barrier .echo: ", Base.return_types((H, S) -> gather(H, S).echo, (typeof(h), typeof(s))))
println("inferred binding: ", Base.return_types(binding, (typeof(h),)))

println("=== AbstractAtRoot message")
struct NT <: AbstractComponent end
x_init(::NT) = nothing
u_types(::NT) = (n = Union{Nothing,Float64},)
y_types(::NT) = (o = Float64,)
y_direct(::NT, (; u)) = (o = 0.0,)
try Simulation(Group((; c = NT()); input_wires = ("n" => "c/n",)); h = 1//10) catch e; println(sprint(showerror, e)); end
end

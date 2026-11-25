module ProbeS6e
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/"
include(W * "imports.jl")
include(W * "fixtures.jl")
using Redstone.Library

function tryit(label, f)
    try
        r = f()
        println(label, " => OK ", r)
    catch e
        if e isa DiagnosticError
            c = e.carried
            ds = c isa Vector ? c : [c]
            for d in ds
                println(label, " => ", typeof(d), " ", [(n, getfield(d, n)) for n in fieldnames(typeof(d)) if n in (:reason, :face, :path, :port, :candidates, :key)])
            end
        else
            println(label, " => EXC ", sprint(showerror, e)[1:min(end,300)])
        end
    end
end

println("--- A junction ports (spec says out)")
j = SumJunction{Float64,3}()
println(u_types(j), " ", y_types(j), " ", typeof(j.f))   # probe:A
println("fold order: ", y_direct(j, (; u = (in1=1e16, in2=1.0, in3=-1e16))), " vs ", y_direct(j, (; u = (in1=1e16, in2=-1e16, in3=1.0))))

C(v) = Constant(v)
println("--- wires with out vs y")
tryit("wire out", () -> build(Group((; a=C(1.0), b=C(2.0), s=SumJunction{Float64,2}(), t=Fn{Float64}(identity));
    local_wires=("a/y"=>"s/in1","b/y"=>"s/in2","s/out"=>"t/u"))))
tryit("wire y", () -> build(Group((; a=C(1.0), b=C(2.0), s=SumJunction{Float64,2}(), t=Fn{Float64}(identity));
    local_wires=("a/y"=>"s/in1","b/y"=>"s/in2","s/y"=>"t/u"))))
println("--- unconnected in4")
tryit("in4", () -> build(Group((; a=C(1.0), b=C(2.0), c=C(3.0), s=SumJunction{Float64,4}());
    local_wires=("a/y"=>"s/in1","b/y"=>"s/in2","c/y"=>"s/in3"))))
println("--- double wired")
tryit("double", () -> build(Group((; a=C(1.0), b=C(2.0), s=SumJunction{Float64,2}());
    local_wires=("a/y"=>"s/in1","b/y"=>"s/in2","a/y"=>"s/in2"))))
println("--- unwired contributor output legal")
tryit("unwired out", () -> (build(Group((; a=C(1.0), b=C(2.0), x=C(9.0), s=SumJunction{Float64,2}());
    local_wires=("a/y"=>"s/in1","b/y"=>"s/in2"))); :built))
println("--- stale arity N=2 with 3 wired")
tryit("stale", () -> build(Group((; a=C(1.0), b=C(2.0), c=C(3.0), s=SumJunction{Float64,2}());
    local_wires=("a/y"=>"s/in1","b/y"=>"s/in2","c/y"=>"s/in3"))))
println("--- hierarchical idiom: Ldg sums legs, exports wrench; systems sums")
struct Ldg <: AbstractComponent
    l1::Constant{Float64}; l2::Constant{Float64}; sum::SumJunction{Float64,2}
end
Ldg() = Ldg(C(1.0), C(2.0), SumJunction{Float64,2}())
local_wires(::Ldg) = ("l1/y"=>"sum/in1","l2/y"=>"sum/in2")
output_wires(::Ldg) = ("sum/y"=>"wrench",)
struct Sys <: AbstractComponent
    aero::Constant{Float64}; ldg::Ldg; sum::SumJunction{Float64,2}; dyn::Fn{Float64,Float64}
end
Sys() = Sys(C(5.0), Ldg(), SumJunction{Float64,2}(), Fn{Float64}(identity))
local_wires(::Sys) = ("aero/y"=>"sum/in1","ldg/wrench"=>"sum/in2","sum/y"=>"dyn/u")
tryit("hier", () -> (b = build(Sys()); :built))
tryit("opaque child wire", () -> build(Group((; ldg=Ldg(), t=Fn{Float64}(identity));
    local_wires=("ldg/sum/y"=>"t/u"))))
println("--- Constant")
println(u_types(C(1.0)) , " ", y_types(C(1.0)), " ", x_init(C(1.0)))
tryit("const tier", () -> (b=build(Group((; k=C(1.0), t=Fn{Float64}(identity)); local_wires=("k/y"=>"t/u")));
     [e.tier for e in b.structure.components]))
tryit("const SVector", () -> (build(Group((; k=C(SVector(1.0,2.0)), t=Fn{SVector{2,Float64}}(identity)); local_wires=("k/y"=>"t/u"))); :ok))

println("--- Relative / Absolute refusals")
mk(st) = () -> build(Group((; a=TickCounter()); sample_times=st))
tryit("Rel(0)", mk((; a=Relative(0))))
tryit("Rel(1,1)", mk((; a=Relative(1,1))))
tryit("Rel(3,3)", mk((; a=Relative(3,3))))
tryit("Rel(3,-1)", mk((; a=Relative(3,-1))))
tryit("Abs(0)", mk((; a=Absolute(0))))
tryit("Abs(1//10,1//10)", mk((; a=Absolute(1//10,1//10))))
tryit("Abs(1//10,-1//100)", mk((; a=Absolute(1//10,-1//100))))
tryit("Abs float", () -> Absolute(0.02))
tryit("Rel float", () -> Relative(2.0))
println("--- grid cost")
for (st, fr) in (((; a=Relative(5,2)), 1//10), ((; a=Absolute(1//10)), 1//10), ((; a=Absolute(1//10, 1//20)), 1//20), ((; a=Absolute(1//10, 1//10000)), 1//10000))
    b = build(Group((; a=TickCounter()); sample_times=st))
    println(st, " Δt_base=", Deployment(b; Δt_frame=fr).Δt_base)
end
tryit("coarser frame refused", () -> Deployment(build(Group((; a=TickCounter()); sample_times=(; a=Absolute(1//10, 1//20)))); Δt_frame=1//10))
println("--- worked example")
b = build(MultiRate())
d = Deployment(b; Δt_frame = 1//500)
println([(e.path, e.D, e.Φ, e.Δt, e.anchor) for e in d.schedule.rows], " H=", lcm([e.D for e in d.schedule.rows]))
println("Δt_base ", d.Δt_base)
sim = Simulation(MultiRate(); Δt_frame = 1//500)
init!(sim)
println("init: ", port(sim,"fcs/inner",:out), port(sim,"fcs/outer",:out), port(sim,"gnss",:out))
step!(sim; frames=2); println("n=2 outer=", port(sim,"fcs/outer",:out), " inner=", port(sim,"fcs/inner",:out))
step!(sim; frames=5); println("n=7 outer=", port(sim,"fcs/outer",:out))
println("--- composition laws")
inner = Group((; c = TickCounter()); sample_times=(; c=Relative(3,1)))
d2 = Deployment(build(Group((; f=inner); sample_times=(; f=Relative(5,2)))); Δt_frame=1//100)
println([(e.D,e.Φ,e.Δt) for e in d2.schedule.rows])
println("--- bundle Δt = D0*Δt_base with phase")
struct DtProbe <: AbstractComponent end
s_init(::DtProbe) = (v = 0.0,)
y_types(::DtProbe) = (dt = Float64,)
y_state(::DtProbe, (; s)) = (dt = s.v,)
s_update(::DtProbe, (; s, Δt)) = (v = Δt,)
sim2 = Simulation(Group((; a=DtProbe()); sample_times=(; a=Relative(5,2))); Δt_frame=1//100)
init!(sim2); run!(sim2; t_end=0.1)
println("dt seen ", port(sim2,"a",:dt))
println("--- stagger Relative(2,0)/(2,1) under scope at Relative(2,0)")
g = Group((; a=TickCounter(), b=TickCounter()); sample_times=(; a=Relative(2,0), b=Relative(2,1)))
d3 = Deployment(build(Group((; s=g); sample_times=(; s=Relative(1,0)))); Δt_frame=1//100)
println([(e.path,e.D,e.Φ) for e in d3.schedule.rows])
rows(m; kw...) = [(e.path,e.D,e.Φ) for e in Deployment(build(m); kw...).schedule.rows]
println("--- anchor child faster than scope")
tryit("anch", () -> rows(Group((; s=Group((; a=TickCounter()); sample_times=(; a=Absolute(1//100)))); sample_times=(; s=Relative(4))); Δt_frame=1//100))
tryit("anch rel under anchor", () -> rows(Group((; g=Group((; a=TickCounter(), b=TickCounter()); sample_times=(; a=Relative(3), b=Absolute(1//100)))); sample_times=(; g=Absolute(1//50))); Δt_frame=1//100))
tryit("nested anchor", () -> rows(Group((; g=Group((; a=TickCounter()); sample_times=(; a=Absolute(1//100)))); sample_times=(; g=Absolute(1//50))); Δt_frame=1//100))
tryit("sample_times on a continuous", mk((; a=Relative(1))))
println("--- boundary zero: offset comp updates not run, outputs published")
sim3 = Simulation(Group((; a=TickCounter()); sample_times=(; a=Relative(5,2))); Δt_frame=1//100)
init!(sim3); println("n at 0: ", state(sim3,"a"), " n out ", port(sim3,"a",:n))
end
module Probe2
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/"
include(W * "imports.jl")
include(W * "fixtures.jl")
using Redstone.Library
println("=== probe2")
b = build(Group((; a=Constant(1.0), b=Constant(2.0), x=Constant(9.0), s=SumJunction{Float64,2}(), t1=Fn{Float64}(identity), t2=Fn{Float64}(identity));
    local_wires=("a/y"=>"s/in1","b/y"=>"s/in2","s/y"=>"t1/u","s/y"=>"t2/u")))
println("fanout ok; warnings: ", Redstone.warnings(b))
sim = Simulation(Group((; c=TickCounter(), o=TickCounter()); sample_times=(; o=Relative(5,2))); Δt_frame=1//100)
init!(sim); println("init c=", state(sim,"c"), " o=", state(sim,"o"), " o.n port ", port(sim,"o",:n))
step!(sim; frames=1); println("n=1 c=", state(sim,"c"), " o=", state(sim,"o"))
step!(sim; frames=1); println("n=2 c=", state(sim,"c"), " o=", state(sim,"o"))
println("non-due frame top: Absolute 1//50 with frame 1//100? ")
sim = Simulation(Group((; g=TickCounter()); sample_times=(; g=Absolute(1//50))); Δt_frame=1//100)
println(Deployment(build(Group((; g=TickCounter()); sample_times=(; g=Absolute(1//50)))); Δt_frame=1//100).Δt_base)
init!(sim); println("g0 ", state(sim,"g")); step!(sim; frames=1); println("g after 1 frame ", state(sim,"g")); step!(sim; frames=1); println("g after 2 ", state(sim,"g"))
sim = Simulation(Group((; g=TickCounter()); sample_times=(; g=Absolute(1//50))); Δt_frame=1//100)
println(Redstone.Deployment(build(Group((; g=TickCounter())); Δt_frame=1//100)).schedule.rows)
d = Deployment(build(Group((; g=TickCounter()); sample_times=(; g=Absolute(1//50)))); Δt_frame=1//100)
println(d.schedule)
end

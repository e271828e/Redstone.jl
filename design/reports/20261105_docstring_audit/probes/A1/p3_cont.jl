module P3
using Test
include("test/repl.jl")
include("test/utils.jl")
include("design/reports/20261105_docstring_audit/probes/A1/common.jl")
# top-level fixtures
struct TSpy <: AbstractComponent end
x_init(::TSpy)=nothing
y_types(::TSpy)=Pinned{Float64}
y_state(::TSpy,(;t))=ForwardDiff.value(t)
# hand-written lag, scratch kept at Float64
struct HandLag <: AbstractComponent; τ::Float64; end
x_init(::HandLag)=0.0
u_types(::HandLag)=Float64
y_types(::HandLag)=Float64
y_state(::HandLag,(;x))=x
ws_init(::HandLag, ::Type)=(tmp=Vector{Float64}(undef,1),)
x_deriv(c::HandLag,(;x,u,ws))=(ws.tmp[1]=(u-x)/c.τ; ws.tmp[1])
println("== Source")
print("Int return: "); show_err(()->build(single(Source(t->1))))
print("Float32: "); show_err(()->build(single(Source(t->1f0))))
print("typed V: "); show_err(()->typeof(Source{Int}(t->1)))
seen = Ref{Any}(nothing)
fn(t) = (seen[]=typeof(t); 2.0)
print("t type under activations: "); m=Group((; s=Source(fn), i=Integrator()); input_wires=("in"=>"i/u",))
sim=Simulation(m;h=1//10); init!(sim,set(u=(in=0.0,))); lz=linearize(sim,taps(x=(x=get_state("i"),),u=(in=get_input(:in),))); println(seen[])
const Nested = ForwardDiff.Dual{Nothing,ForwardDiff.Dual{Nothing,Float64,1},1}
print("nested activation build of Source: "); show_err(()->typeof(build(single(Source(sin)); activations=(Float64,Nested))))
print("nested activation build of Freeze: "); show_err(()->typeof(build(Group((;i=Integrator(),f=Freeze{Float64}());local_wires=("i/y"=>"f/u",),input_wires=("in"=>"i/u",)); activations=(Float64,Nested))))

println("== Integrator")
println(u_types(Integrator()), u_types(Integrator(reset=true)), y_types(Integrator(x0=[1,2])))
for x0 in (1,1f0,[1,2],1//2,[1 2;3 4]); print("x0=",repr(x0)," "); show_err(()->typeof(Integrator(x0=x0)).parameters[1]); end
println("rise via boundary-detected step at 0.25 h=.1: x at grid")
m=Group((; k=Constant(1.0), r=Step(t_step=0.25,localized=false), c=Comparator(threshold=0.5,localized=false), i=Integrator(x0=0.5,reset=true)); local_wires=("k/y"=>"i/u","r/y"=>"c/u","c/y"=>"i/reset"))
println(seq(m,"i",5)[2])
println("reset via Source{Bool} rising inside step (not on a boundary-detected event): lands where?")
m=Group((; k=Constant(1.0), s=Source{Bool}(t->t>=0.25), i=Integrator(x0=0.5,reset=true)); local_wires=("k/y"=>"i/u","s/y"=>"i/reset"))
println(seq(m,"i",5)[2])
println("comparator localized on own output: self reset at x=1 sawtooth")
m=Group((; k=Constant(1.0), c=Comparator(threshold=1.0), i=Integrator(x0=0.0,reset=true)); local_wires=("k/y"=>"i/u","i/y"=>"c/u","c/y"=>"i/reset"))
show_err(()->seq(m,"i",25)[2][[1,5,9,10,11,12,13,20,25]])
println("holding reset: once"); m=Group((; k=Constant(1.0), r=Step(t_step=0.2), i=Integrator(x0=0.0,reset=true)); local_wires=("k/y"=>"i/u",))
println("event names ", keys(state_events(Integrator(reset=true))))
println("reset holding at t0 fires over condition")
h=Simulation(Group((; k=Constant(1.0), r=Constant(true), i=Integrator(x0=0.5,reset=true)); local_wires=("k/y"=>"i/u","r/y"=>"i/reset")); h=1//10)
init!(h,at("i",set(x=2.0))); println(state(h,"i")); step!(h;t_plus=3//10); println(state(h,"i"))
println("linearize integrator vector & SArray state follows")
sim=Simulation(Group((; i=Integrator(x0=[1.0,2.0])); input_wires=("in"=>"i/u",)); h=1//10); init!(sim,set(u=(in=SVector(0.0,0.0),)))
lz=linearize(sim,taps(x=(a=get_state("i","[1]"),b=get_state("i","[2]")),u=(a=get_input("in[1]"),b=get_input("in[2]"))));println(lz.A,lz.B)
println("Reset Linearize: reset form y")
println("feedthrough: self-loop Integrator->Junction->Integrator builds "); show_err(()->typeof(build(Group((; i=Integrator(),j=Junction{Float64,Float64,1}(-));local_wires=("i/y"=>"j/in1","j/y"=>"i/u")))))

println("== FirstOrderLag")
lag=FirstOrderLag(τ=0.5,x0=2.0)
sim=Simulation(Group((; c=lag);input_wires=("in"=>"c/u",));h=1//100); init!(sim,set(u=(in=1.0,)))
lz=linearize(sim,taps(x=(x=get_state("c"),),u=(in=get_input(:in),))); println(lz.A,lz.B)
println("TF equivalence (u0=x0): initial outputs")
tf=TransferFunction(num=(1,),den=(0.5,1),u0=2.0)
for b in (lag,tf)
  s=Simulation(Group((; c=b);input_wires=("in"=>"c/u",));h=1//100); init!(s,set(u=(in=1.0,))); o0=port(s,"c"); step!(s;t_plus=1); println(typeof(b).name.name," ",o0," ",port(s,"c"), " exact ",1+exp(-2))
end
print("hand lag Dual: "); show_err(()->typeof(build(Group((; c=HandLag(0.5));input_wires=("in"=>"c/u",)); activations=(Float64,LinearizeDual))))
print("hand lag linearize: "); show_err(()->begin s=Simulation(Group((; c=HandLag(0.5));input_wires=("in"=>"c/u",));h=1//100); init!(s,set(u=(in=1.0,))); step!(s;t_plus=1//10); l=linearize(s,taps(x=(x=get_state("c"),),u=(in=get_input(:in),))); (l.A,l.B); end)
for kw in ((τ=0.0,),(τ=-1.0,),(τ=[1.0,0.0],),(τ=1,x0=[1,2]),(τ=[1.0,2.0],x0=0.0),(τ=[1,2,3],x0=[1,2]))
 print(kw,": "); show_err(()->FirstOrderLag(;kw...))
end
s=Simulation(Group((; c=FirstOrderLag(τ=[1.0,2.0],x0=0.0));input_wires=("in"=>"c/u",));h=1//100); init!(s,set(u=(in=SVector(1.0,1.0),))); step!(s;t_plus=1); println(state(s,"c"), " exact ",[1-exp(-1),1-exp(-.5)])
println("lag breaks loop: builds"); show_err(()->typeof(build(Group((; c=lag,j=Junction{Float64,Float64,1}(-));local_wires=("c/y"=>"j/in1","j/y"=>"c/u")))))
end

module P4b
using Test
include(joinpath(pwd(), "test/repl.jl"))
include(joinpath(pwd(), "test/utils.jl"))
include(joinpath(pwd(), "design/reports/20261105_docstring_audit/probes/A1/common.jl"))
const Nested = ForwardDiff.Dual{Nothing,ForwardDiff.Dual{Nothing,Float64,1},1}
print("Model at Nested (Integrator only): "); show_err(()->begin b=build(Group((;i=Integrator());input_wires=("in"=>"i/u",))); d=Deployment(b; h=1//10); typeof(Model(d,Nested)).name.name end)
print("Model at Nested (Source): "); show_err(()->begin b=build(Group((;s=Source(sin)))); d=Deployment(b; h=1//10); typeof(Model(d,Nested)).name.name end)
print("Model at single Dual (Source): "); show_err(()->begin b=build(Group((;s=Source(sin)))); d=Deployment(b; h=1//10); typeof(Model(d,ProbeDual)).name.name end)
println("== TransferFunction")
for kw in ((num=(1,),den=(1,)),(num=(1,1,1),den=(1,1)),(num=(1,),den=(0,1)),(num=(1,),den=(1,0),u0=1.0),(num=(1,),den=(1,0)),(num=[1.0],den=[1.0,2.0]),(num=(1,),den=[1,2],u0=3),(num=(),den=(1,1)),(num=(1,),den=()))
 print(kw,": "); show_err(()->(b=TransferFunction(;kw...); (typeof(b).parameters[1:2], b.num, b.den, Redstone.Blocks.realization(b).x0)))
end
tf=TransferFunction(num=(2.0,3.0),den=(1.0,4.0,5.0),u0=2.0)
r=Redstone.Blocks.realization(tf); println(r.A,r.B,r.C,r.D," x0 ",r.x0, " y0 ", (r.C*r.x0)[1], " G0u0 ", 3/5*2)
tfe=TransferFunction(num=(2.0,3.0),den=(4.0,5.0),u0=2.0); r=Redstone.Blocks.realization(tfe); println(" eq-deg y0 ", (r.C*r.x0+r.D*SVector(2.0))[1], " G0u0 ", 3/5*2)
println(" frequency check G(1im) ", (2*im+3)/(im^2+4im+5), " real ", let r=Redstone.Blocks.realization(tf); (Matrix(r.C)*((1im*I-Matrix(r.A))\Matrix(r.B))+Matrix(r.D))[1] end)
println(u_types(tf)," ",y_types(tf)," ",typeof(x_init(tf)))
println(" Lead coefficient 2: ", let b=TransferFunction(num=(1.0,2.0),den=(2.0,1.0,4.0)); r=Redstone.Blocks.realization(b); (Matrix(r.C)*((1im*I-Matrix(r.A))\Matrix(r.B))+Matrix(r.D))[1] end, " vs ", (im+2)/(2*im^2+im+4))

println("== DiscreteTransferFunction")
for kw in ((num=(1,),den=(1,)),(num=(1,1,1),den=(1,1)),(num=(1,),den=(0,1)),(num=(1,),den=(1,-1),u0=1.0),(num=(1,),den=(1,-1)),(num=(1,),den=(1,-0.7,-0.3),u0=1.0),(num=(1,),den=(2,-2),u0=1.0),(num=(1,),den=(1,-1+1e-11),u0=1.0),(num=(1,),den=(1,-1+1e-13),u0=1.0))
 print(kw,": "); show_err(()->(b=DiscreteTransferFunction(;kw...); (typeof(b).parameters[1:2], b.num, b.den, s_init(b))))
end
println(" sum(1,-.7,-.3) ", 1-0.7-0.3, " sum ", sum((1,-0.7,-0.3)))
d=DiscreteTransferFunction(num=(2.0,3.0),den=(1.0,-1.1,0.3),u0=2.0); r=Redstone.Blocks.held(d); println(" s0 ",r.s0," y ",(r.C*r.s0)[1]," G1u0 ",5/(1-1.1+0.3)*2)
println(" update consistency s=As+Bu0 ", r.A*r.s0+r.B*SVector(2.0)-r.s0)
m=Group((;k=Constant(2.0),c=d);local_wires=("k/y"=>"c/u",)); println(seq(m,"c",3)[1])
println(" impulse response 1/(z-0.5): y[n] with u=1 from t0 ", seq(Group((;k=Constant(1.0),c=DiscreteTransferFunction(num=(1,),den=(1,-0.5)));local_wires=("k/y"=>"c/u",)),"c",4)[1], " want 0 1 1.5 1.75 1.875")
println(" filter(b,a) eq-degree (1,0)/(1,-.5): ", seq(Group((;k=Constant(1.0),c=DiscreteTransferFunction(num=(1,0),den=(1,-0.5)));local_wires=("k/y"=>"c/u",)),"c",3)[1], " want 1 1.5 1.75 1.875")

println("== DiscreteStateSpace")
dss=DiscreteStateSpace(A=[0.5;;],B=[1.0;;],C=[2.0;;],D=[3.0;;],s0=4)
m=Group((;k=Constant(1.0),c=dss);local_wires=("k/y"=>"c/u",)); println(seq(m,"c",2)); println(typeof(s_init(dss)),u_types(dss),y_types(dss))

println("== Discretized")
cont=StateSpace(A=[-1.0;;],B=[1.0;;],C=[1.0;;],x0=[0.0])
dz=DiscretizedStateSpace(cont); println(typeof(dz)); println(Redstone.Blocks.held(dz)===cont)
for st in ((;),(c=Relative(2),))
 m=Group((;k=Constant(1.0),c=dz);local_wires=("k/y"=>"c/u",),sample_times=st); o,s=seq(m,"c",4); println(st,o,s," exact y(t) ",[1-exp(-t) for t in 0:0.1:0.4])
end
d2=DiscretizedStateSpace(A=[-1.0 0.0;1.0 -2.0],B=[1.0;0.0;;],C=[0.0 1.0],D=[5.0;;],x0=[1,2]); println(typeof(d2).parameters[1:4]," ",s_init(d2)," ",u_types(d2),y_types(d2))
r=Redstone.Blocks.realization(d2,0.1); println(r.A, " exp ", exp([-1.0 0;1 -2]*0.1)); println(r.B); println(r.C,r.D)
print("Discretized positional non SS: "); show_err(()->DiscretizedStateSpace(1))
dtf=DiscretizedTransferFunction(num=(1,),den=(1,1),u0=2.0); println(typeof(dtf).parameters[1:2]," s0 ",s_init(dtf)," y0 ",port(begin s=Simulation(Group((;k=Constant(2.0),c=dtf);local_wires=("k/y"=>"c/u",));h=1//10); init!(s,set()); s end,"c"))
m=Group((;k=Constant(2.0),c=dtf);local_wires=("k/y"=>"c/u",)); println(" hold u0 steady ",seq(m,"c",3)[1])
m=Group((;k=Constant(1.0),c=DiscretizedTransferFunction(num=(1,),den=(1,1)));local_wires=("k/y"=>"c/u",)); println(" step ",seq(m,"c",3)[1]," exact ",[1-exp(-t) for t in 0:0.1:0.3])
for kw in ((num=(1,),den=(1,)),(num=(1,1,1),den=(1,1)),(num=(1,),den=(0,1)),(num=(1,),den=(1,0),u0=1.0))
 print(kw,": "); show_err(()->DiscretizedTransferFunction(;kw...))
end
println(" dtf fields ",fieldnames(typeof(dtf)))
println("== subtypes ", subtypes(Redstone.Blocks.LinearBlock), subtypes(Redstone.Blocks.DiscreteLinearBlock))
for T in (StateSpace,TransferFunction,DiscreteStateSpace,DiscreteTransferFunction,DiscretizedStateSpace,DiscretizedTransferFunction)
  ms=[methods(f,(T,)) for f in (y_state,y_direct,u_types,y_types,x_init,s_init)]
end
println("rate scope binding: DiscreteStateSpace period")
println("DSS relative: period ", Simulation(Group((;k=Constant(1.0),c=dss);local_wires=("k/y"=>"c/u",),sample_times=(c=Relative(3),));h=1//10) isa Simulation)
end

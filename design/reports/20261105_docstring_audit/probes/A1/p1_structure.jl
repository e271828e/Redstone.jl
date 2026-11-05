module P1
using Test
include(joinpath(pwd(), "test/repl.jl"))
include(joinpath(pwd(), "test/utils.jl"))
show_err(f) = try; r = f(); println("  -> ok: ", r); catch e; println("  -> ", typeof(e), ": ", first(sprint(showerror, e), 300)); end

println("== Junction wire and positional order")
m = Group((; a = Constant(1.0), b = Constant(10.0), c = Constant(100.0), j = Junction{Float64,Float64,3}((x,y,z)->x+2y+3z), sum = Junction{Float64,Float64,1}(identity));
    local_wires = ("c/y" => "j/in3", "a/y" => "j/in1", "b/y" => "j/in2", "j/y" => "sum/in1"))
sim = Simulation(m; h = 1//10); init!(sim, set()); println(" fold = ", port(sim,"j"), " want 321; sum/y=", port(sim,"sum"))
println(" port face: ", port(sim,"sum",:y))
println("== u_types y_types"); j=Junction{Int,Bool,2}(==); println(u_types(j), " ", y_types(j), " ", typeof(j))
println("== SumJunction/Or/And/Pack constructors at arity 1,2,3")
for g in (SumJunction{Float64,1}(), SumJunction{Float64,3}())
  println(typeof(g) <: SumJunction, " ", g.f, " ", g.f(1.0))
end
for (n, G) in ((1, Or{1}()), (1, And{1}()), (2, Or{2}()), (3, And{3}()))
  model = n == 1 ? Group((; a = Constant(true), g = G); local_wires = ("a/y"=>"g/in1",)) : n == 2 ? Group((; a = Constant(true), b=Constant(false), g = G); local_wires = ("a/y"=>"g/in1","b/y"=>"g/in2")) : Group((; a = Constant(true), b=Constant(false), c=Constant(true), g = G); local_wires = ("a/y"=>"g/in1","b/y"=>"g/in2","c/y"=>"g/in3"))
  show_err(() -> begin s=Simulation(model; h=1//10); init!(s,set()); (typeof(G).parameters[3], G.f, port(s,"g")) end)
end
println("Or{2}() isa Or{2}: ", Or{2}() isa Or{2}, "; And: ", And{2}() isa And{2})
println("== Pack")
p = Pack{Float64,2}(); println(y_types(p), " ", u_types(p))
ms = Group((; a = Constant(1.0), b = Constant(2.0), p = Pack{Float64,2}(), un=Unpack{Float64,2}()); local_wires=("a/y"=>"p/in1","b/y"=>"p/in2","p/y"=>"un/u"))
s=Simulation(ms;h=1//10); init!(s,set()); println(port(s,"p")," ",port(s,"un",:out1)," ",port(s,"un",:out2))
println("Unpack u_types ", u_types(Unpack{Float64,2}()), " y ", y_types(Unpack{Float64,2}()))
println("Unpack{Float64,1}: ", y_types(Unpack{Float64,1}()))
println("== Switch")
println(u_types(Switch{Float64}()), y_types(Switch{Float64}()))
print("cycle: "); show_err(()-> build(Group((; s = Switch{Float64}(), a = Constant(1.0), b = Constant(-1.0), g = Junction{Float64, Bool, 1}(v -> v > 0));
          local_wires = ("a/y" => "s/in1", "b/y" => "s/in2", "s/y" => "g/in1", "g/y" => "s/select"))))
print("relay -> select: "); show_err(()-> build(Group((; q=Constant(1.0), r=Relay(lower=0.0,upper=1.0), s = Switch{Float64}(), a = Constant(1.0), b = Constant(-1.0));
          local_wires = ("a/y" => "s/in1", "b/y" => "s/in2", "q/y"=>"r/u", "r/y" => "s/select"))))
print("comparator -> select: "); show_err(()-> typeof(build(Group((; q=Constant(1.0), r=Comparator(threshold=0.5), s = Switch{Float64}(), a = Constant(1.0), b = Constant(-1.0));
          local_wires = ("a/y" => "s/in1", "b/y" => "s/in2", "q/y"=>"r/u", "r/y" => "s/select")))))
print("relay{Bool}? "); show_err(()-> Relay(lower=false,upper=true,off=false,on=true))
print("in1 feedback memoryless (not select) "); show_err(()-> typeof(build(Group((; s = Switch{Float64}(), b = Constant(-1.0), g = Constant(true), j=Junction{Float64,Float64,1}(identity));
          local_wires = ("j/y" => "s/in1", "s/y"=>"j/in1", "b/y" => "s/in2", "g/y" => "s/select")))))
println("== Constant")
s=Simulation(Group((; k=Constant(3), d=UnitDelay(0)); local_wires=("k/y"=>"d/u",)); h=1//10); init!(s,set()); step!(s;t_plus=1//10); println("int const to int discrete delay: ", port(s,"d"))
print("const vector plain: "); show_err(()-> typeof(build(single(Constant([1.0,2.0])))))
print("const float into plain Float64 input under Dual: "); show_err(()->typeof(build(Group((; k=Constant(1.0), i=Integrator()); local_wires=("k/y"=>"i/u",)); activations=(Float64,LinearizeDual))))
sl=Simulation(Group((; k=Constant(1.0), i=Integrator()); local_wires=("k/y"=>"i/u",)); h=1//10); init!(sl,set())
lz=linearize(sl, taps(x=(x=get_state("i"),), y=(ky=get_output("k",:y),))); println(" A=",lz.A," C=",lz.C)
println("== Freeze")
for T in (Float64, SVector{2,Float64}, SMatrix{2,2,Float64,4})
  println(T, " ok: ", Freeze{T}() isa Freeze)
end
for T in (Float32, Int, Vector{Float64}, SVector{2,Int}, MVector{2,Float64})
  print(T, ": "); show_err(() -> Freeze{T})
end
print("Freeze{SVector{2}} unwritten: "); show_err(()->Freeze{SVector{2}})
end

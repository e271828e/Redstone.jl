module P7
using Test
const WT = pwd()
include(WT * "/test/repl.jl")
include(WT * "/test/utils.jl")
# A continuous state schedules the parameter; the block's u leaves through a root output.
sched(ctl; frozen=false) = begin
    blocks = (; s=Integrator(x0=1.0), k0=Constant(0.0), r=Constant(1.0), m=Constant(0.25), c=ctl)
    frozen ? Group((; blocks..., f=Freeze{Float64}()); local_wires=("k0/y"=>"s/u","r/y"=>"c/r","m/y"=>"c/y","s/y"=>"f/u","f/y"=>"c/Kp"), output_wires=("c/u"=>"u",)) :
             Group(blocks; local_wires=("k0/y"=>"s/u","r/y"=>"c/r","m/y"=>"c/y","s/y"=>"c/Kp"), output_wires=("c/u"=>"u",))
end
for (name, ctl) in (("PID", PID(Kp=AsPort(), Ki=0.5)), ("DiscretePID", DiscretePID(Kp=AsPort(), Ki=0.5))), frozen in (false, true)
    sim = Simulation(sched(ctl; frozen); h=1//100); init!(sim, set())
    l = linearize(sim, taps(x=(s=get_state("s"),), y=(u=get_face(:u),)))
    println(name, " Kp from a continuous state, frozen=", frozen, ": C=", l.C, " (b r - y = .75 if live)")
end
println("--- the discrete block's output into a continuous plant: does the Jacobian see the schedule?")
for (name, ctl) in (("PID", PID(Kp=AsPort(), Ki=0.5)), ("DiscretePID", DiscretePID(Kp=AsPort(), Ki=0.5)))
    m = Group((; s=Integrator(x0=1.0), k0=Constant(0.0), r=Constant(1.0), m=Constant(0.25), c=ctl, p=Integrator());
        local_wires=("k0/y"=>"s/u","r/y"=>"c/r","m/y"=>"c/y","s/y"=>"c/Kp","c/u"=>"p/u"))
    sim = Simulation(m; h=1//100); init!(sim, set())
    l = linearize(sim, taps(x=(s=get_state("s"), p=get_state("p"))))
    println(name, " A=", l.A)
end
println("--- a discrete block's stage body under a Dual, direct call")
let c = DiscretePID(Kp=AsPort(), Ki=0.5)
    d = ForwardDiff.Dual(1.0, 1.0)
    println(y_direct(c, (; s=s_init(c), u=(r=1.0, y=0.25, Kp=d), Δt=0.01)))
end
println("--- does Freeze change anything for the discrete block's run? trim residual?")
println(build(sched(DiscretePID(Kp=AsPort(), Ki=0.5)); activations=(Float64, LinearizeDual)) isa Build)
println("--- a root input fed to the discrete block's port")
let root = Group((; c=DiscretePID(Kp=AsPort(), Ki=0.5)); input_wires=("r"=>"c/r","y"=>"c/y","Kp"=>"c/Kp"), output_wires=("c/u"=>"u",))
    sim = Simulation(root; h=1//100); init!(sim, set(u=(r=1.0,y=0.25,Kp=1.0)))
    println(first(sprint(showerror, failure(()->linearize(sim, taps(u=(Kp=get_input(:Kp),), y=(u=get_face(:u),))))), 240))
end
end

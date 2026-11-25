using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
include(joinpath(W, "test/imports.jl"))
include(joinpath(W, "test/fixtures.jl"))
using Redstone.Library
import Redstone.Library: AbstractPID, AbstractAntiWindupController, gated_error, correction_reference, axis_ports, parameters, signal_ports, u_types, y_types, saturation_type, PID_PARAMETERS, shape_zero
include(joinpath(@__DIR__, "helpers.jl"))
println("probe:loaded")
# 1 table
gains1 = (Kp = 1.0, Ki = 0.5, Kd = 0.2, τd = 0.1)
function row(label, model, t_end)
    s = loop_samples(sim -> port(sim, "", :y), model, t_end)
    println("probe:table ", label, " peak=", round(maximum(s); digits=3), " settled=", settling_time(s))
end
lim = (u_min = -1.0, u_max = 1.0)
row("own Inf", pid_single_loop(PID(; gains1..., lim..., Tt = Inf)), 60)
row("own 1", pid_single_loop(PID(; gains1..., lim..., Tt = 1.0)), 60)
row("servo Inf", pid_servo_loop(PID(; gains1..., tracking = true, Tt = Inf == 1 ? 1.0 : 1e12)), 80)
row("servo 1", pid_servo_loop(PID(; gains1..., tracking = true, Tt = 1.0)), 80)
g2 = (Kp = 0.5, Ki = 0.1)
for (h, t, Tt, lab) in ((false,false,Inf,"none"),(true,false,Inf,"hold"),(false,true,2.0,"trk 2"),(false,true,0.5,"trk .5"),(true,true,2.0,"ht 2"),(true,true,0.5,"ht .5"))
    row("cascade "*lab, pid_cascade(PID(; g2..., Tt = Tt, hold = h, tracking = t); hold = h, tracking = t), 100)
end
# servo Inf: tracking with Tt Inf is refused
println("probe:servoInf refused: ", try PID(; gains1..., tracking = true, Tt = Inf); "no" catch e; typeof(e) end)
# 2 linearization of four variants at free op point, with ungated tracking
function lin(c, h, t)
    ins(r, y, v) = merge((r = r, y = y), h ? (saturation = Int8(0), engaged = true) : (;), t ? (v = v,) : (;))
    f(z) = begin   # z = (q, yf, r, y, v)
        x = (q = z[1], yf = z[2]); u = ins(z[3], z[4], z[5])
        yy = y_direct(c, (; x, u)); d = x_deriv(c, (; x, u, y = yy))
        [d.q, d.yf, yy.u]
    end
    J = ForwardDiff.jacobian(f, zeros(5))
    (A = J[1:2,1:2], B = J[1:2,3:5], C = J[3:3,1:2], D = J[3:3,3:5])
end
for (h, t) in ((false,false),(true,false),(true,true),(false,true))
    c = PID(; gains1..., Tt = 1.0, hold = h, tracking = t)
    L = lin(c, h, t)
    println("probe:lin hold=$h trk=$t A=", L.A, " B=", L.B, " C=", L.C, " D=", L.D)
end
# 3 refusals
println("probe:refuse1 ", try PID(Kp=1.0, tracking=true); "no" catch e; typeof(e) end)
println("probe:refuse2 ", try PID(Kp=1.0, τd=0.0); "no" catch e; typeof(e) end)
println("probe:discτd0 ", try DiscretePID(Kp=1.0, τd=0.0); "ok" catch e; typeof(e) end)
println("probe:discTt0 ", try DiscretePID(Kp=1.0, Tt=0.0); "ok" catch e; typeof(e) end)
println("probe:contTt0 ", try PID(Kp=1.0, Tt=0.0); "no" catch e; typeof(e) end)
println("probe:discTrkInf ", try DiscretePID(Kp=1.0, tracking=true); "no" catch e; typeof(e) end)
# 4 shapes
println("probe:promote ", try promote(1.0, SVector(1.0,2.0)); "ok" catch e; typeof(e) end)
c = PID(Kp = SVector(1.0,2.0), Ki = 1)
println("probe:V ", typeof(c).parameters[1], " Ki=", c.fixed.Ki, " fixed keys=", keys(c.fixed))
c = PID(Kp = AsPort(), Ki = AsPort(), Kd = AsPort(), τd = AsPort(), Tt = AsPort(), u_min = AsPort(), u_max = AsPort(), b = AsPort(), c = AsPort())
println("probe:allport V=", typeof(c).parameters[1], " fixed=", c.fixed)
c = PID(Kp = 1.0, Ki = AsPort(), u_min = AsPort(), hold=false)
println("probe:order ", keys(merge(c.fixed, NamedTuple{keys(u_types(c))}(ntuple(_->0.0, length(u_types(c)))))))
println("probe:u_types ", u_types(c))
println("probe:params ", keys(parameters(c, NamedTuple{keys(u_types(c))}(ntuple(_->1.0, length(u_types(c)))))))
uu = NamedTuple{keys(u_types(c))}(ntuple(_->1.0, length(u_types(c))))
println("probe:inferred ", try (@inferred parameters(c, uu)); "ok" catch e; "no" end)
# vector with hold
cv = PID(Kp = SVector(1.0,2.0), hold = true, tracking = true, Tt = 1.0)
println("probe:vec ports ", u_types(cv))
# 5 cycles
for nm in (:Kp, :Ki, :Tt, :Kd, :u_max)
    try
        build(scheduled_pid_cycle(nm)); println("probe:cycle ", nm, " built")
    catch e
        d = only(diagnostics(e)); println("probe:cycle cont ", nm, " ", d.classification, " ", d.dead)
    end
end
for nm in (:Kp, :Ki, :Tt)
    mk(nm) = Group((; reference = Step(t_step = 0.5, after = 5.0),
             controller = DiscretePID(; merge((Kp = 1.0, Ki = 0.5, Kd = 0.2, Tt = 1.0), (; nm => AsPort()))...),
             gain = Fn{Float64}(abs), plant = DiscreteIntegrator());
          local_wires = ("reference/y" => "controller/r", "plant/y" => "controller/y",
                         "controller/u" => "gain/u", "gain/y" => "controller/$nm",
                         "controller/u" => "plant/u"))
    try build(mk(nm)); println("probe:cycle disc ", nm, " built")
    catch e; d = only(diagnostics(e)); println("probe:cycle disc ", nm, " ", d.classification, " ", d.dead) end
end
# build under LinearizeDual all four
for (h,t) in ((false,false),(true,false),(false,true),(true,true))
    println("probe:builddual $h $t ", build(pid_root_model(PID(Kp=1.0, Tt=1.0, hold=h, tracking=t)); activations=(Float64, LinearizeDual)) isa Build)
end
# 6 derivative spike
cc = PID(Kp=0.0, Kd=2.0, τd=0.1, b=0.0, c=1.0)
yy = y_direct(cc, (x=(q=0.0,yf=0.0), u=(r=3.0,y=0.0)))
println("probe:spike u_raw=", yy.u_raw, " expected Kd Δr/τd=", 2.0*3.0/0.1)
cc0 = PID(Kp=0.0, Kd=2.0, τd=0.1)
println("probe:spike c=0 ", y_direct(cc0, (x=(q=0.0,yf=0.0), u=(r=3.0,y=0.0))).u_raw)
# 7 standby settle
function settle(c, u, n=40000, dt=0.001)
    x = (q=0.0, yf=0.0)
    for _ in 1:n
        y = y_direct(c, (; x, u)); d = x_deriv(c, (; x, u, y))
        x = (q = x.q + dt*d.q, yf = x.yf + dt*d.yf)
    end
    y_direct(c, (; x, u)).u_raw
end
println("probe:standby gated ", settle(PID(Kp=1.0,Ki=0.5,Tt=0.1,hold=true,tracking=true), (r=1.0,y=0.0,saturation=Int8(0),engaged=false,v=0.5)), " (v=0.5)")
println("probe:standby ungated ", settle(PID(Kp=1.0,Ki=0.5,Tt=0.1,tracking=true), (r=1.0,y=0.0,v=0.5)), " expect v+Tt Ki e=", 0.5+0.1*0.5*1.0)
println("probe:backcalc ", settle(PID(Kp=1.0,Ki=0.5,Tt=0.1,u_min=-1,u_max=1), (r=5.0,y=0.0)), " expect u+Tt Ki e=", 1+0.1*0.5*5, " vs u+Tt e=", 1+0.1*5)
# method counts
for f in (signal_ports, u_types, y_types, gated_error, correction_reference, axis_ports, parameters)
    println("probe:methods ", f, " ", [(m.sig) for m in methods(f) if occursin("PID", string(m.sig)) || occursin("AntiWindup", string(m.sig))] |> length)
end
println("probe:gated methods ", length(methods(gated_error)), " corr ", length(methods(correction_reference)))
# LimitedIntegrator code and events
li = LimitedIntegrator(lower=-1.0, upper=1.0)
println("probe:li events ", keys(state_events(li)), " ytypes ", y_types(li))
println("probe:li V ", typeof(li).parameters)
# discrete PID stage and fields
dp = DiscretePID(Kp=1.0)
println("probe:disc s_init ", s_init(dp), " fields ", fieldnames(typeof(dp)))
println("probe:has_stage y_direct ", Redstone.has_stage(y_direct, dp), " y_state ", Redstone.has_stage(y_state, dp), " cont y_state ", Redstone.has_stage(y_state, PID(Kp=1.0)))
println("probe:cont y_types ", y_types(PID(Kp=1.0)), " x_init ", x_init(PID(Kp=1.0)))
# saturation_type
println("probe:satt ", saturation_type(Float64), " ", saturation_type(SVector{2,Float64}))
# discrete beta
println("probe:beta ", -expm1(-0.01/Inf), " ", -expm1(-0.01/0.0))
# root: DiscretePID alone with hold as root builds
println("probe:disc root ", try build(Group((; controller = DiscretePID(Kp=1.0, hold=true)); input_wires=("r"=>"controller/r","y"=>"controller/y","saturation"=>"controller/saturation","engaged"=>"controller/engaged"), output_wires=("controller/u"=>"u","controller/saturated"=>"saturated"))) isa Build catch e; e end)
# gate with Dual at zero error
using ForwardDiff
g = PID(Kp=SVector(1.0,1.0), hold=true)
println("probe:gate ", gated_error(g, SVector(0.0, 1.0), (saturation=SVector(Int8(0),Int8(1)), engaged=SVector(true,true))))
println("probe:done")

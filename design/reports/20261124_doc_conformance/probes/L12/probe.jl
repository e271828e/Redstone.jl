# L12 probes: log entries D-028..D-462 (G5c). Run from W with --project=test.
include(joinpath(pwd(), "test", "RedstoneTests.jl"))
@eval RedstoneTests begin
P(tag, v) = println(tag, " => ", v)
d1(e) = e isa DiagnosticError ? first(carried_diagnostics(e)) : e
kindof(e) = e isa DiagnosticError ? map(typeof, carried_diagnostics(e)) : typeof(e)

# D-088: run!/step! on built is MissingInit
s = Simulation(monitored(); Δt_frame = 1//10)
P("D088 lifecycle new", lifecycle(s))
P("D088 run! built", kindof(failure(() -> run!(s))))
P("D088 step! built", kindof(failure(() -> step!(s))))
P("D397 run field", typeof(s.run))
# D-198: join_timeout
P("D198 default", s.control.join_timeout)
P("D198 neg", (e = failure(() -> Simulation(monitored(); Δt_frame = 1//10, join_timeout = -1)); (kindof(e), d1(e).argument)))
P("D198 in Deployment fields", :join_timeout in fieldnames(Deployment))

# D-388: step! contract
init!(s)
n = step!(s; frames = 2)
P("D388 step returns", n, ); P("D388 lifecycle between", lifecycle(s))
run!(s; t_end = 5.0)
P("D388 run after step termination", termination(s).source)
P("D388 lifecycle after", lifecycle(s))
init!(s); P("D388 stopped->init!", lifecycle(s))
# D-390: t_plus and frames exclusive; latest
e = failure(() -> step!(s; frames = 1, t_plus = 0.1)); P("D390 both", (kindof(e), d1(e).reason))
k = step!(s; t_plus = 0.25); P("D390 t_plus 0.25 frames", k)
P("D390 latest is snapshot", typeof(latest(s)) <: Snapshot)
# D-393: recorded stop request reproduces under replay
s1 = Simulation(monitored(); Δt_frame = 1//10)
init!(s1); run!(s1; t_end = 5.0)
rec = termination(s1); trc = trace(s1)
s2 = Simulation(monitored(); Δt_frame = 1//10)
replay!(s2, trc)
P("D393 recorded", (rec.source, rec.t)); P("D393 replayed", (lifecycle(s2), termination(s2) === nothing ? nothing : (termination(s2).source, termination(s2).t)))
# D-391: replay re-records: header inherited, prefix
P("D391 header frame equal", trace(s2).header.frame == trc.header.frame)

# D-219: to_time, live!
s3 = Simulation(monitored(); Δt_frame = 1//10)
init!(s3); run!(s3; t_end = 0.3, ignore_stop_requests = :all)
trc3 = trace(s3)
s4 = Simulation(monitored(); Δt_frame = 1//10)
e = failure(() -> replay!(s4, trc3; to_time = 0.1, to_boundary = 1)); P("D219 both", (kindof(e), d1(e).reason))
e = failure(() -> replay!(s4, trc3; to_time = 99.0)); P("D219 beyond", (kindof(e), d1(e).argument))
e = failure(() -> replay!(s4, trc3; to_time = -1.0)); P("D219 before t0", kindof(e))
P("D219 lifecycle after refusals", lifecycle(s4))
replay!(s4, trc3; to_time = 0.25, ignore_stop_requests = :all)
P("D219 to_time 0.25 frame", (s4.run.frame, mode(s4), lifecycle(s4)))
live!(s4); P("D219 live!", (mode(s4), s4.run.frame, lifecycle(s4)))
e = failure(() -> live!(s4)); P("D219 live! on live", (kindof(e), d1(e).reason))
s5 = Simulation(monitored(); Δt_frame = 1//10)
P("D219 live! built", kindof(failure(() -> live!(s5))))

# D-404: restore = false
P("D404 built", kindof(failure(() -> replay!(s5, trc3; restore = false))))
init!(s5)
e = failure(() -> replay!(s5, trc3; restore = 2)); P("D404 nonbool", (kindof(e), e isa DiagnosticError ? d1(e).argument : nothing))
step!(s5; frames = 3, ignore_stop_requests = :all)
e = failure(() -> replay!(s5, trc3; restore = false)); P("D404 frame out", (kindof(e), d1(e).what, d1(e).name))
s6 = Simulation(monitored(); Δt_frame = 1//10)
init!(s6; t0 = 1)
e = failure(() -> replay!(s6, trc3; restore = false)); P("D404 origin", (kindof(e), d1(e).what, d1(e).name))
s7 = Simulation(monitored(); Δt_frame = 1//10)
init!(s7); step!(s7; ignore_stop_requests = :all)
b0 = s7.run.boundary
replay!(s7, trc3; restore = false, ignore_stop_requests = :all)
P("D404 header is own", (trace(s7).header.frame, s7.run.frame, lifecycle(s7)))

# D-223: boundary-zero throw
sb = Simulation(fed(Mine(), "sig"); Δt_frame = 1//10)
err = failure(() -> init!(sb, set(u = (in = true,))))
P("D223 err", (typeof(err), err.host, err.boundary, err.t))
P("D223 lifecycle/term/latest", (lifecycle(sb), termination(sb), latest(sb)))
P("D223 trace", kindof(failure(() -> trace(sb))))
P("D223 showerror", sprint(showerror, err))
# frame-one throw at pointer 0
sf = Simulation(fed(Mine(), "sig"); Δt_frame = 1//10)
init!(sf, set(u = (in = false,))); stage!(sf, "in" => true)
errf = failure(() -> step!(sf; t_end = 5.0))
P("D441 frame err", (typeof(errf), errf.host, errf.boundary, lifecycle(sf), sf.model.status))
P("D223 frame-one showerror", sprint(showerror, errf))

# D-097: diagnostic payloads
P("D097 DeviceCrash fields", fieldnames(DeviceCrash)); P("D097 DeviceJoinTimeout fields", fieldnames(DeviceJoinTimeout))
P("D097 severities", (Redstone.severity(DeviceCrash(ErrorException("x"), false)), Redstone.severity(DeviceJoinTimeout("d", 5.0, 0.0, 0))))

# D-110: trim! keyword default
m = first(methods(trim!, (Simulation, TrimProblem)))
P("D110 trim! kwargs", Base.kwarg_decl(m))

# D-273: capture gone
P("D273 capture defined", isdefined(Redstone, :capture))
end

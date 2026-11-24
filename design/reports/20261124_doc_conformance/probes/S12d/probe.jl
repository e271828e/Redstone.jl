using Redstone
using StaticArrays, Test
include("/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/imports.jl")
struct Gain <: AbstractComponent
    k::Float64
end
x_init(::Gain) = nothing
u_types(::Gain) = (e = Float64,)
y_types(::Gain) = (out = Float64,)
y_direct(c::Gain, (; u)) = (out = c.k * u.e,)
struct Sum <: AbstractComponent
    sa::Float64
    sb::Float64
end
Sum(; sa = 1.0, sb = -1.0) = Sum(sa, sb)
x_init(::Sum) = nothing
u_types(::Sum) = (a = Float64, b = Float64)
y_types(::Sum) = (e = Float64,)
y_direct(c::Sum, (; u)) = (e = c.sa * u.a + c.sb * u.b,)
world() = Group((; s = Sum(sa = 1.0, sb = 1.0), g = Gain(2.0));
                input_wires = ("a" => "s/a", "b" => "s/b", "c" => "g/e"))
mk() = Simulation(world(); Δt_frame = 1//10)
function fresh()
    sim = mk(); init!(sim, set(u = (a = 0.0, b = 0.0, c = 0.0))); sim
end
function recorded()
    sim = fresh()
    stage!(sim, "b" => 1.0); step!(sim)
    stage!(sim, "a" => 2.0, "c" => 3.0); step!(sim; frames = 4)
    sim
end
function tryit(f)
    try f(); "ok" catch e
        e isa DiagnosticError ? string(replace(string(typeof(e)), "Redstone." => ""), " ", first(sprint(showerror, e), 110)) : first(sprint(showerror, e), 200)
    end
end
P(tag, x) = println("PROBE ", tag, " => ", x)

sim = recorded(); trc = trace(sim)
P("1 frames", (trc.frames, trc.header.frame, sim.run.frame))
# top block
sim2 = mk()
P("1 built replay ok", tryit(() -> replay!(sim2, trc)))
P("1 after full", (lifecycle(sim2), mode(sim2), sim2.run.frame))
cp = checkpoint(sim); 
s3 = mk(); restore!(s3, cp); P("1 restore", (lifecycle(s3), mode(s3)))
# partial to_boundary
s = mk(); replay!(s, trc; to_boundary = 2)
P("2 to_boundary=2", (lifecycle(s), mode(s), s.run.frame, s.run.feed === nothing))
# to_time
for tt in (0.35, 0.3, 0.2999999, 0.0, 0.5, 0.55, 0.6, 0.65)
    s = mk(); r = tryit(() -> replay!(s, trc; to_time = tt))
    P("3 to_time=$tt", (r, lifecycle(s), s.run.frame, mode(s)))
end
for bad in (NaN, Inf, -0.1, 1//2, "x")
    s = mk(); r = tryit(() -> replay!(s, trc; to_time = bad)); P("3 bad to_time $bad", (r, lifecycle(s)))
end
s = mk(); P("3 both", (tryit(() -> replay!(s, trc; to_time = 0.2, to_boundary = 2)), lifecycle(s)))
for b in (-1, 0, 5, 6, 99, 2.0, 1.5)
    s = mk(); P("3 to_boundary=$b", (tryit(() -> replay!(s, trc; to_boundary = b)), lifecycle(s), s.run.frame))
end
# step past end
s = mk(); replay!(s, trc; to_boundary = 2)
n = step!(s; frames = 10); P("4 step past end", (n, mode(s), lifecycle(s), s.run.frame))
# run! with t_end past
s = mk(); replay!(s, trc; to_boundary = 2)
run!(s; t_end = 3.0); P("4 run past end", (mode(s), lifecycle(s), s.run.frame))
run!(s; t_end = 0.8); P("4 live cont", (mode(s), lifecycle(s), s.run.frame))
# partial leaves replay mode
s = mk(); replay!(s, trc; to_boundary = 2); step!(s)
P("4 step one", (mode(s), s.run.frame))
# live! workflow
s = mk(); replay!(s, trc; to_time = 0.25)
P("5 latest", latest(s).t)
live!(s); P("5 live!", (mode(s), lifecycle(s), s.run.frame))
t1 = trace(s)
P("5 trace so far", (t1.frames, length(t1.batches), t1.header.frame))
run!(s; t_end = 0.8)
t2 = trace(s)
P("5 trace after", (t2.frames, length(t2.batches), s.run.frame, t2.header === trc.header, t2.header.frame == trc.header.frame))
P("5 live! on live", tryit(() -> live!(s)))
P("5 live! on built", tryit(() -> live!(mk())))
s5 = fresh(); P("5 live! init live", tryit(() -> live!(s5)))
s5 = mk(); replay!(s5, trc; to_boundary=2); stop!(s5); step!(s5)
P("5 live! stopped", (lifecycle(s5), tryit(() -> live!(s5))))
# replay re-records
s = mk(); replay!(s, trc)
t3 = trace(s); P("6 rerecord", (t3.frames == trc.frames, t3.batches == trc.batches, t3.header.frame == trc.header.frame, t3.schemas == trc.schemas, t3 === trc))
# restore=false
a = fresh(); stage!(a,"b"=>1.0); step!(a)
P("7 rf frames", (a.run.frame, trc.header.frame))
P("7 rf ok", tryit(() -> replay!(a, trc; restore = false, to_boundary = 3)))
P("7 rf state", (lifecycle(a), mode(a), a.run.frame, trace(a).header.frame, a.run.boundary))
P("7 rf built", tryit(() -> replay!(mk(), trc; restore = false)))
b = fresh(); b2 = fresh(); run!(b2; t_end = 0.1)
b3 = fresh(); stop!(b3); step!(b3)
P("7 rf stopped", (lifecycle(b3), tryit(() -> replay!(b3, trc; restore = false))))
c = fresh(); step!(c; frames = trc.frames)
P("7 rf last frame", (c.run.frame, tryit(() -> replay!(c, trc; restore = false))))
# origin mismatch
d = mk(); init!(d, set(u = (a = 0.0, b = 0.0, c = 0.0)); t0 = 1.0)
P("7 rf origin", tryit(() -> replay!(d, trc; restore = false)))
P("7 default origin", (tryit(() -> replay!(d, trc)), lifecycle(d)))
P("7 default t0 kw", tryit(() -> replay!(mk(), trc; t0 = 0.0)))
# default form from stopped / running errors
e = fresh(); stop!(e); step!(e); P("7 default stopped", (lifecycle(e), tryit(() -> replay!(e, trc))))
# deployment mismatch
dsim = Simulation(world(); Δt_frame = 1//10, algorithm = RK4())
P("8 same alg", tryit(() -> replay!(Simulation(world(); Δt_frame = 1//10, firing_budget = 5), trc)))
P("8 frame", tryit(() -> replay!(Simulation(world(); Δt_frame = 1//5), trc)))
P("8 hmax", tryit(() -> replay!(Simulation(world(); Δt_frame = 1//10, h_max = 1//20), trc)))
for kw in (:localization_tol => 1e-5, :localization_budget => 9, :attempt_budget => 8, :Δt_base => 1//20)
    P("8 $(kw)", tryit(() -> replay!(Simulation(world(); Δt_frame = 1//10, kw), trc)))
end
# schema mismatch
bad = Trace(trc.header, [("harness" => [:zz])], TraceBatch[], trc.frames)
P("9 schema", tryit(() -> replay!(mk(), bad)))
bad2 = Trace(trc.header, copy(trc.schemas), [TraceBatch(1, 1, Pair{Int,Any}[9 => 1.0])], trc.frames)
P("9 unknown", tryit(() -> replay!(mk(), bad2)))
bad3 = Trace(trc.header, copy(trc.schemas), [TraceBatch(0, 1, Pair{Int,Any}[1 => 1.0])], trc.frames)
P("9 frame0", tryit(() -> replay!(mk(), bad3)))
bad4 = Trace(trc.header, copy(trc.schemas), [TraceBatch(99, 1, Pair{Int,Any}[1 => 1.0])], trc.frames)
P("9 frame99", tryit(() -> replay!(mk(), bad4)))
# discard staging
s = mk(); replay!(s, trc; to_boundary = 2)
stage!(s, "a" => 77.0)
step!(s)
P("10 pending after", s.plane.harness.cell.pending === nothing)
P("10 state a", try state(s, "s") catch e sprint(showerror, e) end)
s = mk(); replay!(s, trc; to_boundary = 2)
step!(s); stage!(s, "a" => 77.0)
P("10 pending late before", s.plane.harness.cell.pending === nothing)
step!(s)
P("10 pending late after", s.plane.harness.cell.pending === nothing)
# staging before replay is dropped silently by door
s = fresh(); stage!(s, "a" => 5.0); replay!(s, trc; to_boundary = 2); P("10 pre staged", s.plane.harness.cell.pending === nothing)
# t_end, ignore_stop_requests keywords, pace/margin
s = mk(); P("11 t_end", (tryit(() -> replay!(s, trc; t_end = 0.2)), s.run.frame, lifecycle(s)))
s = mk(); P("11 ignore", tryit(() -> replay!(s, trc; ignore_stop_requests = :all)))
s = mk(); P("11 pace", tryit(() -> replay!(s, trc; pace = 100.0, margin = 0.001)))
# snapshot at restore=false: one snapshot
a = fresh(); step!(a); replay!(a, trc; restore=false, to_boundary=2)
P("12 log len", length(logged(a)))
# trace header for restore=false is own checkpoint
P("12 hdr", trace(a).header.frame)
# seek
sk = mk(); replay!(sk, trc; to_boundary = 3); cp3 = checkpoint(sk)
sk2 = fresh(); restore!(sk2, cp3); P("12 seek", tryit(() -> replay!(sk2, trc; restore = false)))
P("12 seek state", (sk2.run.frame, lifecycle(sk2), mode(sk2)))
# part 2
for kw in ((; localization_tol = 1e-5), (; localization_budget = 9), (; attempt_budget = 8), (; Δt_base = 1//20), (; h_min = 1//100), (; algorithm = BS3(), h_min = 1//100, h_max = 1//20))
    P("8b $(kw)", tryit(() -> replay!(Simulation(world(); Δt_frame = 1//10, kw...), trc)))
end
s = mk(); replay!(s, trc; to_boundary = 2); stage!(s, "a" => 77.0); step!(s)
P("10b status", [(w.who, [typeof(d) for d in w.recent]) for w in status(latest(s)).writers])

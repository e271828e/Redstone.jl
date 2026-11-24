module S12cProbe
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
include(joinpath(W, "utils.jl"))
include(joinpath(W, "test_lifecycle.jl"))

ds(e) = try diagnostics(e) catch; [e.carried] end
macro p(label, ex)
    line = __source__.line
    quote
        local v = try $(esc(ex)) catch e; (:THREW, e isa DiagnosticError ? (typeof(e), [typeof(d) for d in ds(e)]) : e) end
        println("probe:", $line, " ", $label, " => ", v)
    end
end
kinds(f) = try f(); :nothrow catch e; e isa DiagnosticError ? [(nameof(typeof(d)), (hasproperty(d,:reason) ? d.reason : nothing), (hasproperty(d,:what) ? d.what : nothing), (hasproperty(d,:host) ? d.host : nothing)) for d in ds(e)] : e end

point = set(u = (ref = 0.0,))
mk() = Simulation(feedback_model(); Δt_frame = 1//10)

# structure
@p "Run fields" fieldnames(Redstone.Run)
@p "Run consts" [isconst(Redstone.Run, f) for f in fieldnames(Redstone.Run)]
@p "Sim fields" fieldnames(Simulation)
fresh = mk()
@p "placeholder" (fresh.run.trace, fresh.run.feed, fresh.run.termination, length(logged(fresh)), lifecycle(fresh), mode(fresh), fresh.run.frame, fresh.run.boundary)
@p "built run!" kinds(() -> run!(fresh))
@p "built step!" kinds(() -> step!(fresh))
@p "built checkpoint" kinds(() -> checkpoint(fresh))
@p "built overlay!" kinds(() -> overlay!(fresh))
@p "built live!" kinds(() -> live!(fresh))
@p "MissingInit msg" (try run!(fresh) catch e; Redstone.message(ds(e)[1]) end)

# init!, counters
sim = mk(); init!(sim, point)
@p "after init" (lifecycle(sim), mode(sim), sim.run.frame, sim.run.boundary, latest(sim).boundary, latest(sim).frame, sim.model.exec.clock.t₀)
@p "step default" (step!(sim), sim.run.frame, sim.run.boundary, lifecycle(sim))
@p "step both" kinds(() -> step!(sim; frames = 2, t_plus = 0.3))
@p "t_plus 0.25 from t" (sim.model.exec.clock.t, step!(sim; t_plus = 0.25), sim.model.exec.clock.t)
@p "t_plus 0.05" step!(sim; t_plus = 0.05)
@p "t_plus 0.3 exact" (sim.model.exec.clock.t, step!(sim; t_plus = 0.3), sim.model.exec.clock.t)
@p "attach in initialized ok" (Redstone.assert_configurable(sim, :attach!))
@p "run after step" (run!(sim; t_end = 1.0), lifecycle(sim), termination(sim).source, termination(sim).policy)
@p "step after stopped" kinds(() -> step!(sim))
@p "run after stopped" kinds(() -> run!(sim))
@p "init! after stopped" (init!(sim, point), lifecycle(sim))

# bit identity
a = mk(); init!(a, point); step!(a; frames = 5)
b = mk(); init!(b, point); run!(b; t_end = 0.5)
@p "step==run" (same_table(latest(a).store, latest(b).store), latest(a).t == latest(b).t, a.model.exec.xbuf == b.model.exec.xbuf)
# step never waits on pace
c = mk(); init!(c, point); pace!(c, 0.01)
@p "step pace" (@elapsed(step!(c; frames = 5)) < 1.0, pace(c))

# stop at frame 3
m = Simulation(Group((; src = Ramp(0.0), trig = Trigger(0.25), stop = StopRequest(reason = "x"));
          local_wires = ("src/out" => "trig/sig", "trig/on" => "stop/u")); Δt_frame = 1//10)
init!(m)
@p "stop in step" (step!(m; frames = 10), lifecycle(m), termination(m).source, m.run.frame)
@p "checkpoint stopped (frame top)" (try checkpoint(m).frame catch e; e end)
m2 = Simulation(Group((; src = Ramp(0.0), trig = Trigger(0.25), stop = StopRequest(reason = "x"));
          local_wires = ("src/out" => "trig/sig", "trig/on" => "stop/u")); Δt_frame = 1//10)
init!(m2)
@p "t_end at last frame" (step!(m2; frames = 3, t_end = 0.3), lifecycle(m2))

# lifecycle table
x = mk(); init!(x, point)
@p "running flag" (@atomic(x.control.running = true); l = lifecycle(x); @atomic(x.control.running = false); l)
@p "inconsistent" (@atomic(x.model.status = :inconsistent); l = lifecycle(x); l)
@p "errored checkpoint" kinds(() -> checkpoint(x))
@p "errored init" kinds(() -> init!(x, point))
@p "errored restore" kinds(() -> restore!(x, checkpoint(sim.model)))
@p "errored overlay" kinds(() -> overlay!(x))
@p "errored attach gate" kinds(() -> Redstone.assert_configurable(x, :attach!))

# show
show(stdout, MIME"text/plain"(), sim); println()

# checkpoint model
mod = Model(feedback_model(); Δt_frame = 1//10)
@p "model checkpoint built" kinds(() -> checkpoint(mod))
init!(mod, point)
st = checkpoint(mod)
@p "ModelState fields" fieldnames(typeof(st))
@p "stepper RK4" st.stepper
bs = Model(feedback_model(); Δt_frame = 1//10, algorithm = BS3(), h_min = 1//10^6); init!(bs, point)
frames!(bs, 3)
@p "stepper BS3" (checkpoint(bs).stepper)
@p "checkpoint(sim) type" (typeof(checkpoint(sim)), fieldnames(typeof(checkpoint(sim))))

# restore model mismatch + midframe collected in one throw
other = Model(feedback_model(; k = 5.0); Δt_frame = 1//5)   # different deployment
bad = Redstone.ModelState{Float64}(st.x, st.s, st.m, st.table, st.prior, st.stepper, st.t + 0.03, st.t₀, st.deployment, st.layout)
@p "restore model off-grid" kinds(() -> restore!(mod, bad))
bad2 = Redstone.ModelState{Float64}(st.x, st.s, st.m, st.table, st.prior, st.stepper, st.t + 0.03, st.t₀, other.deployment, st.layout)
@p "restore model off-grid + deployment" kinds(() -> restore!(mod, bad2))
@p "restore model on built OK, status" (m3 = Model(feedback_model(); Δt_frame = 1//10); restore!(m3, st); @atomic m3.status)
dualm = Model(feedback_model(), D8; Δt_frame = 1//10)
@p "restore sim scalar" kinds(() -> restore!(sim, checkpoint(init!(dualm, point) === nothing ? dualm : dualm)))
@p "restore model scalar" kinds(() -> restore!(mod, checkpoint(dualm)))

# restore!(sim, cp): ordinals, fresh run, staging cleared, mode, header
s2 = mk(); init!(s2, point); step!(s2; frames = 3)
cp = checkpoint(s2)
@p "cp counters" (cp.frame, cp.boundary, latest(s2).boundary)
step!(s2; frames = 2)
oldrun = s2.run
stage!(s2, "ref" => 0.5)
restore!(s2, cp)
@p "after restore" (s2.run !== oldrun, (@atomic s2.plane.harness.cell.pending), mode(s2), latest(s2).boundary, latest(s2).t, s2.run.frame, s2.run.boundary, lifecycle(s2), s2.run.trace.header === cp, length(logged(s2)))
step!(s2; frames = 1)
@p "next ordinal" (latest(s2).boundary, latest(s2).frame)
@p "restore unmodified-frames identical" (s3 = mk(); init!(s3, point); step!(s3; frames = 4); same_table(latest(s3).store, latest(s2).store))
# bare state
s4 = mk(); init!(s4, point); step!(s4; frames = 2)
stt = checkpoint(s4.model)
step!(s4; frames = 3)
restore!(s4, stt)
@p "bare restore" (latest(s4).boundary, s4.run.frame, s4.run.boundary, mode(s4), lifecycle(s4))
init!(s4, point)
@p "init counters" (s4.run.frame, s4.run.boundary, latest(s4).boundary)
bad3 = Redstone.ModelState{Float64}(st.x, st.s, st.m, st.table, st.prior, st.stepper, st.t + 0.03, st.t₀, st.deployment, st.layout)
@p "sim restore bare offgrid" kinds(() -> restore!(s4, bad3))
@p "sim restore cp offgrid+mismatch" kinds(() -> restore!(s4, Redstone.Checkpoint(Redstone.ModelState{Float64}(st.x, st.s, st.m, st.table, st.prior, st.stepper, st.t + 0.03, st.t₀, other.deployment, st.layout), 1, 1)))
@p "restore kw trace=false" (restore!(s4, cp; trace = false, log = false); (s4.run.trace, length(logged(s4))))
@p "checkpoint after restore sim" (checkpoint(s4).frame)

# overlay
o = Simulation(resume_pend(); Δt_frame = 1//10); init!(o, resume_condition())
step!(o; frames = 3)
b0, t0_, f0, bd0 = latest(o).boundary, latest(o).t, o.run.frame, o.run.boundary
oldrun = o.run
stage!(o, "in" => 0.1)
clock0 = (o.model.exec.clock.t, o.model.exec.clock.t₀)
overlay!(o, at("ctl", set(s = (acc = 7.0,))))
@p "overlay state" (lifecycle(o), mode(o), o.run !== oldrun, (@atomic o.plane.harness.cell.pending), latest(o).boundary == b0 + 0 || (latest(o).boundary, b0), latest(o).t == t0_, o.run.frame == f0, o.run.boundary == bd0, clock0 == (o.model.exec.clock.t, o.model.exec.clock.t₀), o.run.trace.header isa Redstone.Checkpoint)
@p "overlay latest ordinals" (b0, latest(o).boundary, bd0, o.run.boundary)
@p "overlay header = checkpoint after" (o.run.trace.header.boundary == o.run.boundary, o.run.trace.header.state.x == o.model.exec.xbuf)
@p "overlay bad cond" kinds(() -> overlay!(o, at("nope", set(x = 1.0))))
@p "overlay no totality" kinds(() -> overlay!(o, at("ctl", set(s = (acc = 8.0,)))))
run!(o; t_end = 1.0)
@p "overlay from stopped" (lifecycle(o), kinds(() -> overlay!(o)), lifecycle(o), mode(o))

# mode / replay
r1 = mk(); init!(r1, point); step!(r1; frames = 6)
trc = trace(r1)
r2 = mk()
replay!(r2, trc; to_boundary = 3)
@p "replay mode" (mode(r2), lifecycle(r2), r2.run.feed !== nothing)
live!(r2)
@p "live!" (mode(r2), lifecycle(r2))
replay!(r2, trc; to_boundary = 3)
init!(r2, point)
@p "init after replay" (mode(r2))
replay!(r2, trc; to_boundary = 3)
restore!(r2, checkpoint(r1))
@p "restore after replay" (mode(r2))
replay!(r2, trc; to_boundary = 3)
step!(r2; frames = 100)
@p "replay step past end" (mode(r2), lifecycle(r2), termination(r2))
@p "replay kws" kinds(() -> replay!(r2, trc; t_end = 0.2, ignore_stop_requests = ()))

# origin
for t0v in (-3//10, -0.3, 0.25, 3)
    q = mk(); init!(q, point; t0 = t0v)
    println("probe:origin t0=", t0v, " => ", q.model.exec.clock.t₀, " ", q.model.exec.clock.t₀ == t0v, " t=", q.model.exec.clock.t, " trace hdr t0=", q.run.trace.header.state.t₀)
end
@p "t0 1e-4" kinds(() -> init!(mk(), point; t0 = 1e-4))
@p "t0 big" kinds(() -> init!(mk(), point; t0 = 1e15))

# init clears staging, fresh log
z = mk(); init!(z, point); step!(z; frames = 2)
oldlog = z.run.log; oldtrace = z.run.trace
stage!(z, "ref" => 0.5)
init!(z, point)
@p "init fresh" (z.run.log !== oldlog, z.run.trace !== oldtrace, (@atomic z.plane.harness.cell.pending), z.run.termination)
# stage -> step -> latest, traced
z2 = mk(); init!(z2, point)
stage!(z2, "ref" => 0.5); step!(z2)
@p "staged traced" (length(trace(z2).batches), port(latest(z2), "", :ref))
# closed
@p "closed" (closed(z2.run), run!(z2; t_end = 0.5), closed(z2.run), lifecycle(z2))
@p "StopPolicy" (fieldnames(Redstone.StopPolicy))
@p "stop kws bad" kinds(() -> step!(mk() |> s -> (init!(s, point); s); ignore_stop_requests = ("nope",)))
@p "Model fields" fieldnames(typeof(mod))
@p "chunk_size owner" (hasfield(typeof(mod), :chunk_size), hasfield(typeof(mod.exec), :chunk_size))
end

module ProbeCV12
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const T = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/"
include(T * "imports.jl")
include(T * "fixtures.jl")
include(T * "utils.jl")
include(T * "test_dataplane.jl")

dg(e::DiagnosticError) = join([string(nameof(typeof(d)), "(", join([string(f, "=", repr(getfield(d, f))) for f in fieldnames(typeof(d)) if f in (:call, :reason, :argument, :op, :status, :legal, :what, :value)], ","), ")") for d in (e.carried isa Vector ? e.carried : [e.carried])], "; ")
dg(e) = "OTHER " * first(sprint(showerror, e), 120)
macro p(ex)
    quote
        r = try
            v = $(esc(ex)); "ok => " * repr(v)
        catch e
            "THROW " * dg(e)
        end
        println("probe:", $(__source__.line), " ", $(string(ex)), "\n    ", first(r, 400))
    end
end
mk() = Simulation(fed(Plant(), "u"); Δt_frame = 1//10)
cond = set(u = (in = 0.0,))

sim = mk()
@p lifecycle(sim)
@p mode(sim)
@p latest(sim)
@p logged(sim)
@p termination(sim)
@p pace(sim)
@p margin(sim)
@p paused(sim)
@p pause!(sim)
@p paused(sim)
@p resume!(sim)
@p stop!(sim)
@p lifecycle(sim)
@p pace!(sim, 0)
@p pace!(sim, -1)
@p pace!(sim, Inf)
@p pace!(sim, 2)
@p (pace(sim), typeof(pace(sim)))
@p pace!(sim, "a")
@p margin!(sim, -1)
@p margin!(sim, 0)
@p margin!(sim, Inf)
@p margin!(sim, 0.002)
@p trace(sim)
@p overlay!(sim, cond)
@p restore!(sim, Checkpoint)
@p live!(sim)
@p run!(sim)
@p step!(sim)
@p series(sim, reads(y = get_output("c","y")))
@p init!(sim, cond; log_every = 0)
@p init!(sim, cond; trace = 1, log = 2, log_every = 1.5, log_max = 0)
@p init!(sim, cond; log_max = Inf)
@p lifecycle(sim)
@p mode(sim)
@p live!(sim)
@p (latest(sim).boundary, latest(sim).frame, latest(sim).t)
@p length(logged(sim))
@p typeof(logged(sim)) == Vector{typeof(latest(sim))}
@p step!(sim; frames = 3)
@p (latest(sim).boundary, latest(sim).frame)
@p length(logged(sim))
@p lifecycle(sim)
@p eltype(logged(sim)) == typeof(latest(sim))
@p let s = series(sim, reads(y = get_output("c","y"), p = get_output("c","power"))); (propertynames(s), s.t, s.frame, s.boundary, typeof(s.y), typeof(s.p), keys(s.columns)); end
@p series(sim, reads(t = get_output("c","y")))
@p series(sim, (y = "c/y",))
@p series(sim, reads(y = get_output("nope","y")))
@p let s = series(sim, at("c", reads(y = get_output("", "y")))); (keys(s.columns), length(s.t)); end
# checkpoint / overlay
cp = checkpoint(sim)
@p overlay!(sim, set(); trace = 1)
@p lifecycle(sim)
@p (sim.run.frame, sim.run.boundary)
@p overlay!(sim, at("c", set(x = (q = SVector(0.5, 0.0),))))
@p (lifecycle(sim), mode(sim), latest(sim).t, latest(sim).boundary, length(logged(sim)), trace(sim).header.frame, trace(sim).header.boundary)
@p overlay!(sim, set(u = (in = 0.3,)))
@p overlay!(sim, set(zz = 1))
@p overlay!(sim, set(); log_every = 0)
@p logged(sim) |> length
# restore
@p restore!(sim, cp)
@p (latest(sim).t, latest(sim).boundary, sim.run.frame, sim.run.boundary, mode(sim), lifecycle(sim))
@p restore!(sim, cp; log_max = 0)
@p restore!(sim, cp.state)
@p (latest(sim).t, latest(sim).boundary, sim.run.frame, sim.run.boundary, lifecycle(sim))
@p restore!(sim, cp; trace = false)
@p trace(sim)
@p restore!(sim, 3)
# live!
@p live!(sim)
# trace/replay
init!(sim, cond); step!(sim; frames = 5)
trc = trace(sim)
@p (typeof(trc), trc.frames, length(trc.batches))
@p trace(sim) === trc
sim2 = mk()
@p replay!(sim2, trc; to_boundary = 3)
@p (lifecycle(sim2), mode(sim2), sim2.run.frame, latest(sim2).boundary)
@p live!(sim2)
@p mode(sim2)
@p live!(sim2)
sim3 = mk()
init!(sim3, cond)
@p replay!(sim3, trc; restore = false, to_boundary = 2)
@p (lifecycle(sim3), mode(sim3), sim3.run.frame)
# stop semantic
sim4 = mk(); init!(sim4, cond)
@p stop!(sim4)
@p step!(sim4; frames = 2)
@p (lifecycle(sim4), termination(sim4).source)
@p stop!(sim4)
sim5 = mk(); init!(sim5, cond)
@p run!(sim5; t_end = 0.3)
@p (lifecycle(sim5), termination(sim5).source)
@p stop!(sim5)
@p run!(sim5)
@p step!(sim5)
@p logged(sim5) |> length
@p closed(sim5.run)
@p stage!(sim5, "in" => 1.0)
# detach
sim6 = Simulation(two_root_inputs(); Δt_frame = 1//10)
d1 = Pad("d1"); d2 = Pad("d2")
h1 = attach!(sim6, d1, Enumerated("a"))
@p h1.id
@p stage!(sim6, "a" => 1.0, "b" => 2.0, "zz" => 1.0, "b" => "x")
@p detach!(sim6, d2)
@p detach!(sim6, d1)
@p stage!(h1, "a" => 1.0)
@p report!(h1, MalformedDatum("x"))
@p latest(h1)
h2 = attach!(sim6, d2, Enumerated("a"))
@p h2
@p [e.id for e in sim6.plane.roster]
init!(sim6, set(u = (a = 0.0, b = 0.0)))
@p (sim6.plane.roster |> length)
# Simulation ctor
m = Model(fed(Plant(), "u"); Δt_frame = 1//10)
@p Simulation(m; join_timeout = 0)
@p Simulation(m; join_timeout = "x")
@p (Simulation(m; join_timeout = 2) isa Simulation)
@p Simulation(m)
@p Simulation(Model(fed(Plant(), "u"); Δt_frame = 1//10, chunk_size = 4))
@p Simulation(deployment = 1)
@p Simulation(fed(Plant(), "u"); Δt_frame = 1//10, join_timeout = 3, chunk_size = 4).control.join_timeout
@p Simulation(fed(Plant(), "u"); Δt_frame = 1//10, bogus = 3)
@p Simulation(Deployment(build(fed(Plant(), "u")); Δt_frame = 1//10); join_timeout = 3)
@p typeof(Simulation(Deployment(build(fed(Plant(), "u")); Δt_frame = 1//10)).run.log)
@p (let s = mk(); (s.run.frame, s.run.boundary, s.run.feed, s.run.trace, s.run.termination, s.run.log.every, s.run.log.max); end)
@p fieldnames(Simulation)
@p fieldnames(Run)
@p fieldnames(StopPolicy)
@p fieldnames(TerminationRecord)
@p fieldnames(ModelRequestedStop)
@p fieldnames(ControlRequestedStop)
@p fieldnames(Series)
@p warnings(mk())
@p (let s = mk(); init!(s, cond); (s.plane.roster |> length, phase_bodies(s) isa Any); end)
@p (let s = mk(); init!(s, cond); (port(s, "c", :y), state(s, "c"), modes(s, "c")); end)

# extra
@p let s = mk(); init!(s, cond); step!(s; frames=2); series(s, reads(y = get_output("c","y"), x = get_state("c","q"))); end
@p let s = mk(); init!(s, cond); series(s, reads(columns = get_output("c","y"))); end
@p let s = mk(); series(s, reads(y = get_output("c","y"))); end
@p let s = mk(); init!(s, cond; log = false); step!(s); (length(logged(s)), latest(s).frame, typeof(series(s, reads(y = get_output("c","y"))).y)); end
@p let s = mk(); (series(s, reads(y = get_output("c","y"))).y, series(s, reads(y = get_output("c","y"))).t); end
@p let m = Model(fed(Plant(), "u"); Δt_frame = 1//10); init!(m, cond); Simulation(m); end
@p let s = mk(); init!(s, cond); step!(s; frames=2); overlay!(s, set()); (latest(s).t, latest(s).boundary, s.run.boundary); end
@p let s = mk(); init!(s, cond); overlay!(s, at("c", set(x = (q = SVector(0.5, 0.0),)))); port(s,"c",:y); end
@p let s = mk(); init!(s, cond); step!(s; frames=2); overlay!(s, set(); trace=false); (trace(s)); end
@p let s = mk(); init!(s, cond); step!(s; frames=2); overlay!(s, set(); log=false); (length(logged(s))); end
@p let s = mk(); init!(s, cond); step!(s; frames=2); stage!(s, "in"=>1.0); overlay!(s, set()); step!(s); (port(s,"c",:power)); end
@p let s = mk(); init!(s, cond); step!(s; frames=2); pause!(s); overlay!(s, set()); paused(s); end
@p let s = mk(); init!(s, cond); step!(s; frames=2); s.control.stop_issuer; end
@p let s = mk(); init!(s, cond); stop!(s); overlay!(s, set()); s.control.stop_issuer; end
@p let s = mk(); init!(s, cond); pause!(s); init!(s, cond); paused(s); end
@p let s = mk(); init!(s, cond); step!(s; frames = 2); trc = trace(s); init!(s, cond); (mode(s), termination(s)); end
@p let s = mk(); init!(s, cond); run!(s; t_end=0.2); overlay!(s, set()); (lifecycle(s), termination(s)); end
@p let s = mk(); init!(s, cond); run!(s; t_end=0.2); (lifecycle(s), checkpoint(s) isa Checkpoint); end
@p let s = mk(); init!(s, cond); run!(s; t_end=0.2); s2 = s; s.control.stop_issuer; end
@p let s = mk(); init!(s, cond); step!(s; frames=2); trc = trace(s); replay!(s, trc); (lifecycle(s), mode(s)); end
@p let s = mk(); init!(s, cond); step!(s; frames=2); trc = trace(s); replay!(s, trc; to_boundary = 1); (mode(s), step!(s; frames = 5), mode(s)); end
@p let s = mk(); (s.run.log.enabled, s.run.log.log_max, s.run.log.stride); end
@p let s = mk(); init!(s, cond; log_every=3, log_max = 7); (s.run.log.stride, s.run.log.log_max); end
@p let s = mk(); init!(s, cond; log_max = Inf); s.run.log.log_max == typemax(Int); end
@p let s = mk(); init!(s, cond); s.run.trace.frames; end
@p let s = mk(); init!(s, cond); (s.plane.roster, s.plane.harness isa Any, fieldnames(typeof(s.plane))); end
@p let s = mk(); fieldnames(typeof(s.control)); end
@p let s = mk(); init!(s, cond); (stage!(s, "in"=>2.0); init!(s, cond); step!(s); port(s, "c", :power)); end
@p let s = mk(); init!(s, cond); stage!(s, "in"=>2.0); step!(s); port(s, "c", :power); end
@p let s = mk(); init!(s, cond); stage!(s, "in"=>2.0); restore!(s, checkpoint(s)); step!(s); port(s, "c", :power); end
@p let s = mk(); init!(s, cond); stage!(s, "in"=>2.0); restore!(s, checkpoint(s)); (s.control.stop_issuer); end
@p let s = mk(); init!(s, cond); try; init!(s, set(u = (in = 0.0,)); t0 = 0); catch; end; lifecycle(s); end
@p fieldnames(Redstone.StopPolicy)
@p let s = mk(); init!(s, cond); sim7 = s; Redstone._open_run!(s, nothing, Pair{String,Vector{Symbol}}[], nothing, 0, 0, true, true, 1, Inf); s.run.log.log_max == typemax(Int); end
@p let s = mk(); (hasmethod(Redstone.phase_bodies, Tuple{typeof(s)}), hasmethod(apply!, Tuple{typeof(s), Redstone.ConditionPlan})); end
@p let s = mk(); init!(s, cond); (try; stage!(s, "in" => 1.0, "q" => 2.0); catch e; e; end, step!(s), writer_status(latest(s), "harness").recent |> length); end

# round 2
@p let s = mk(); init!(s, cond); step!(s; frames=2); series(s, at("c", reads(y = get_output("", "y")))).y; end
@p let s = mk(); init!(s, cond); stage!(s, "in" => "x", "nope" => 1.0, "in" => 2.0); step!(s); w = writer_status(latest(s), "harness"); (typeof.(w.recent), port(s, "c", :power)); end
@p let s = mk(); init!(s, cond); step!(s; frames=3); trc = trace(s); s2 = mk(); init!(s2, cond); step!(s2; frames=2); overlay!(s2, at("c", set(x = (q = SVector(0.5, 0.0),)))); step!(s2; frames = 2); t2 = trace(s2); s3 = mk(); replay!(s3, t2); (port(s3,"c",:y) == port(s2,"c",:y), lifecycle(s3), s3.run.frame, s2.run.frame); end
@p let s = mk(); init!(s, cond); step!(s; frames=3); trc = trace(s); cp = checkpoint(s); replay!(s, trc; to_boundary = 1); m1 = mode(s); restore!(s, cp); (m1, mode(s)); end
@p let s = mk(); init!(s, cond); step!(s; frames=3); trc = trace(s); replay!(s, trc; to_boundary = 1); m1 = mode(s); overlay!(s, set()); (m1, mode(s)); end
@p let s = mk(); init!(s, cond); step!(s; frames=3); trc = trace(s); replay!(s, trc; to_boundary = 1); m1 = mode(s); init!(s, cond); (m1, mode(s)); end
@p port(mk(), "c", :y)
@p let s = mk(); init!(s, cond); port(s, "nope", :y); end
@p let s = mk(); init!(s, cond); port(s, "c", :zz); end
@p let s = mk(); init!(s, cond); port(s, "c"); end
@p let s = mk(); init!(s, cond); (state(s, "nope")); end
@p let s = mk(); init!(s, cond); step!(s); run!(s; t_end = 0.5); step!(s) ; end
@p let s = mk(); init!(s, cond); run!(s; t_end = 0.2); init!(s, cond); (stop = s.control.stop_issuer, lc = lifecycle(s), term = termination(s), cl = closed(s.run)); end
@p let s = mk(); init!(s, cond); run!(s; t_end = 0.2); fieldnames(typeof(termination(s))); end
@p let s = mk(); init!(s, cond); run!(s; t_end = 0.2); (termination(s).t, typeof(termination(s).residue), termination(s).policy); end
@p let s = mk(); init!(s, cond); step!(s); s.run.log.enabled; end
@p let s = mk(); init!(s, cond; log_every = 2); step!(s; frames = 5); [x.boundary for x in logged(s)]; end
@p let s = mk(); init!(s, cond; log_every = 1, log_max = 3); step!(s; frames = 8); [x.boundary for x in logged(s)]; end
@p let s = mk(); init!(s, cond); stop!(s); (lifecycle(s), step!(s), lifecycle(s)); end
@p let s = mk(); init!(s, cond); stop!(s); run!(s; t_end = 0.2); termination(s).source; end
@p let s = mk(); init!(s, cond); stop!(s); restore!(s, checkpoint(s)); s.control.stop_issuer; end
@p let s = mk(); init!(s, cond); trc = trace(s); stop!(s); replay!(s, trc); s.control.stop_issuer; end

# round 3
@p let s = Simulation(Group((; tick = BareTicker())); Δt_frame = 1//10); init!(s, set()); step!(s; frames = 2); a = port(s, "tick", :n); overlay!(s, at("tick", set(s = (s = 10,)))); b = port(s, "tick", :n); step!(s); c = port(s, "tick", :n); (a, b, c, state(s, "tick")); end
@p let s = Simulation(bare_world(); Δt_frame = 1//10); init!(s, set()); lifecycle(s); end
end

using Test, BenchmarkTools
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff
include("/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/imports.jl")
include("/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/fixtures.jl")
include("/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/utils.jl")
dgs(e) = try diagnostics(e) catch; [diagnostic(e)] end
mk() = Simulation(fed(Plant(), "u"); Δt_frame = 1//10)
cond = set(u = (in = 0.0,))
println("probe:10 snapshot fields = ", fieldnames(Snapshot))
sim = mk(); init!(sim, cond); step!(sim; frames = 3)
s = latest(sim)
println("probe:13 root input in snapshot: ", port(s, "", :in) , " status type ", typeof(s.status), " isimmutable ", !ismutabletype(FrameworkStatus), " ", !ismutabletype(Snapshot))
println("probe:14 store keys: ", keys(s.store.stores))
# atomic field orderings
println("probe:16 staging cell fields: ", fieldnames(Redstone.StagingCell), " Published: ", fieldnames(Redstone.Published))
# defaults of init!
println("probe:18 init! methods: ", first(methods(init!, (Simulation, Any))))
# log_max default
sim = mk(); init!(sim, cond); println("probe:20 log_max default = ", sim.run.log.log_max, " stride ", sim.run.log.stride)
sim = mk(); init!(sim, cond; log_max = Inf); println("probe:21 Inf -> ", sim.run.log.log_max == typemax(Int))
for bad in (0, 1.5, -1, NaN)
    d = try init!(mk(), cond; log_max = bad); nothing catch e; only(dgs(e)) end
    println("probe:23 log_max=$bad -> ", d === nothing ? "ok" : (typeof(d), d.reason, d.argument))
end
# endpoints and bound, counts
sim = mk(); init!(sim, cond; log_every = 2, log_max = 4)
global ok = true
for k in 1:200
    step!(sim; frames = 1)
    global ok &= sim.run.log.live <= 4
    sn = logged(sim); global ok &= sn[1].frame == 0 && sn[end].frame == k
end
println("probe:31 bound+endpoints hold ", ok, " stride ", sim.run.log.stride, " frames ", [x.frame for x in logged(sim)])
# restore! first
ck = checkpoint(sim)
restore!(sim, ck; log_max = 4)
println("probe:35 restored first: ", logged(sim)[1].frame, " boundary ", logged(sim)[1].boundary)
# endpoints do not count against bound: first + last + live<=4
sim = mk(); init!(sim, cond; log_max = 3); step!(sim; frames = 40)
println("probe:38 length(logged)=", length(logged(sim)), " live=", sim.run.log.live)
# stride counts from first (boundary of first nonzero after restore)
sim = mk(); init!(sim, cond); step!(sim; frames = 5); ck = checkpoint(sim)
restore!(sim, ck; log_every = 3); step!(sim; frames = 10)
println("probe:42 restore stride from first: frames ", [x.frame for x in logged(sim)], " boundaries ", [x.boundary for x in logged(sim)])
# terminal snapshot equals latest after run
sim = mk(); init!(sim, cond; log_every = 7); run!(sim; t_end = 1.0)
println("probe:46 last === latest: ", logged(sim)[end] === latest(sim), " frames ", [x.frame for x in logged(sim)])
# series
sim = mk(); init!(sim, cond); step!(sim; frames = 5)
flight = series(sim, reads(V = get_output("c", :y)))
println("probe:50 flight.V === flight.columns.V: ", flight.V === flight.columns.V, " ", typeof(flight.V), " fields ", fieldnames(Series), " propertynames ", propertynames(flight))
println("probe:51 show: ", sprint(show, flight))
println("probe:52 text:\n", sprint(show, MIME"text/plain"(), flight))
for lab in (:t, :frame, :boundary, :columns)
    d = try series(sim, reads(; NamedTuple{(lab,)}((get_output("c", :y),))...)); nothing catch e; only(dgs(e)) end
    println("probe:55 label $lab -> ", d === nothing ? "ok" : (typeof(d), d.reason))
end
# reads() itself accepts the labels
println("probe:58 reads(t=...) ok: ", reads(t = get_output("c", :y)) isa Reads)
# store selector refused in series
d = try series(sim, reads(q = get_state("c", :q))); nothing catch e; dgs(e) end
println("probe:61 store selector in series -> ", d === nothing ? "ok" : [(typeof(x), x.reason) for x in d])
# attach with failing binding: collected
sim = mk(); init!(sim, cond)
d = try attach!(sim, TailProbe(), Readout(a = get_output("nope", :y), b = get_state("c", :q), c = get_output("c", :zzz))); nothing catch e; e end
println("probe:66 attach -> ", d === nothing ? "ok" : [(typeof(x), hasproperty(x,:reason) ? x.reason : nothing) for x in dgs(d)])
# attach rejected while running? build device that attaches during run
println("probe:67 msgs: ", join([sprint(showerror, x) for x in [d]], ""))
println("probe:68 attach good output binding ok: ", (attach!(sim, TailProbe(), Readout(y = get_output("c", :y))); true))
# frames and boundary ordinals (t* share a frame)
model = Group((; src = Sawtooth(1.0), s = Stamper(0.315)); local_wires = ("src/q" => "s/sig",))
sim = Simulation(model; Δt_frame = 1//10); init!(sim); run!(sim; t_end = 0.5)
println("probe:73 frames ", [x.frame for x in logged(sim)], " boundaries ", [x.boundary for x in logged(sim)])
# lifecycle: logged while running refused; attach after stop
# status content
println("probe:76 status writers ", [w.who for w in latest(sim).status.writers], " totals type ", typeof(latest(sim).status.writers[1].totals))
# terminal snapshot carries counters: ReplayDiscardedStaging etc not needed
# sizehint
sim = mk(); init!(sim, cond; log_max = 100); println("probe:79 sizehint capacity? ", length(sim.run.log.snaps.ref.mem))
# Base.Event usage
println("probe:81 done")
# staging cell Atomic orderings: inspect with @code_lowered-lite via expression

using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test
W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
include(joinpath(W, "test/imports.jl"))
include(joinpath(W, "test/fixtures.jl"))

mutable struct Nudge <: AbstractDevice
    face::String
    v::Float64
end
loop(dev::Nudge, handle) = (stage!(handle, dev.face => dev.v); nothing)
three() = Group((; s = Sum(sa = 1.0, sb = 1.0), g = Gain(2.0));
                input_wires = ("a" => "s/a", "b" => "s/b", "c" => "g/e"))
plain(x) = sprint(show, MIME("text/plain"), x)
p(tag, x) = println("PROBE[", tag, "] ", x)

# 1. Trace type
p("Trace fields", (fieldnames(Trace), fieldtypes(Trace), ismutable(Trace)))
p("TraceBatch fields", (fieldnames(TraceBatch), fieldtypes(TraceBatch), ismutable(TraceBatch)))
p("ReplayFeed fields", (fieldnames(Redstone.ReplayFeed), fieldtypes(Redstone.ReplayFeed)))
p("ReplayRecord", fieldnames(Redstone.ReplayRecord))
p("exported", (Base.isexported(Redstone, :Trace), Base.isexported(Redstone, :TraceBatch), Base.ispublic(Redstone, :Trace)))

# 2. a session with a device, a roster change and a detached trace
sim = Simulation(three(); Δt_frame = 1//10)
init!(sim, set(u = (a = 0.0, b = 0.0, c = 0.0)))
p("header after init", (sim.run.trace.header isa Checkpoint, sim.run.trace.frames, sim.run.trace.header.frame))
stage!(sim, "b" => 1.0)
step!(sim)
t1 = trace(sim)
p("t1 frames/batches", (t1.frames, [(b.frame, b.writer, b.entries) for b in t1.batches], t1.schemas))
step!(sim)
p("detached", (t1.frames, trace(sim).frames, length(t1.batches)))
n0 = length(sim.run.trace.schemas)
attach!(sim, Nudge("a", 3.0), Enumerated("a"))
n1 = length(sim.run.trace.schemas)
p("schemas growth on attach", (n0, n1, sim.run.trace.schemas[n0+1:end]))
p("t1 schemas unchanged", length(t1.schemas))
stage!(sim, "b" => 5.0)
run!(sim; t_end = 0.5)
trc = trace(sim)
p("after device", (trc.frames, [(b.frame, b.writer, length(b.entries)) for b in trc.batches]))
p("status who", [r.who for r in latest(sim).status.writers])
p("schema tags", [first(s) for s in trc.schemas])
p("order frames then writer", issorted([(b.frame, b.writer) for b in trc.batches]))
p("TraceBatch ==", (TraceBatch(1, 1, Pair{Int,Any}[1 => 2.0]) == TraceBatch(1, 1, Pair{Int,Any}[1 => 2.0]),
   hash(TraceBatch(1, 1, Pair{Int,Any}[1 => 2.0])) == hash(TraceBatch(1, 1, Pair{Int,Any}[1 => 2.0]))))

# 3. restored trace starts at checkpoint frame
s2 = Simulation(three(); Δt_frame = 1//10)
restore!(s2, checkpoint(sim))
tr2 = trace(s2)
p("restored", (tr2.header.frame, tr2.frames, s2.run.frame))
p("trace=false", (try; init!(Simulation(three(); Δt_frame = 1//10), set(u = (a = 0.0, b = 0.0, c = 0.0)); trace = false); "ok"; catch e; e; end))

# 4. entry pass raise sites
rec = recorded = let s = Simulation(three(); Δt_frame = 1//10)
    init!(s, set(u = (a = 0.0, b = 0.0, c = 0.0))); stage!(s, "b" => 1.0); step!(s); trace(s)
end
target() = (s = Simulation(three(); Δt_frame = 1//10); init!(s, set(u = (a = 0.0, b = 0.0, c = 0.0)); ); s)
mk(batches, frames; schemas = copy(rec.schemas)) = Trace(rec.header, schemas, batches, frames)
function diags(trc)
    try
        Redstone._compile_feed(target(), trc); "no error"
    catch e
        [(typeof(d), d) for d in diagnostics(e)]
    end
end
function show_d(tag, trc)
    r = diags(trc)
    r isa String ? p(tag, r) : for (T, d) in r
        p(tag, (T, d isa CheckpointMismatch ? (d.what, d.name, d.expected, d.found) :
                  d isa Redstone.ReplayUnknownFace ? (d.face, d.frame, d.writer, d.faces) :
                  d isa Redstone.ReplaySchemaMismatch ? (d.writer, d.schema, d.unknown, d.faces) : d))
    end
end
show_d("schema mismatch", mk(TraceBatch[], 1; schemas = Pair{String,Vector{Symbol}}["harness" => [:a, :zz, :yy]]))
show_d("position beyond schema x2", mk([TraceBatch(1, 1, Pair{Int,Any}[7 => 1.0, 9 => 2.0])], 1))
show_d("writer index out of range", mk([TraceBatch(1, 5, Pair{Int,Any}[1 => 1.0])], 1))
show_d("frame outside", mk([TraceBatch(0, 1, Pair{Int,Any}[1 => 1.0]), TraceBatch(3, 1, Pair{Int,Any}[1 => 1.0])], 1))
show_d("bad convert", mk([TraceBatch(1, 1, Pair{Int,Any}[1 => "str"])], 1))
show_d("three bad collected", mk([TraceBatch(1, 1, Pair{Int,Any}[1 => "x", 8 => 1.0, 9 => 1.0])], 1))
feed = Redstone._compile_feed(target(), rec)
p("feed", (feed.next, feed.frames, length(feed.records), keys(feed.records[1])))

# 5. show: forms
mr = build(MultiRate()); dep = Deployment(mr; Δt_frame = 1//500)
p("Deployment compact", sprint(show, dep))
println(plain(dep))
println(plain(mr))
sim3 = Simulation(three(); Δt_frame = 1//10)
p("Simulation built compact", sprint(show, sim3))
println(plain(sim3))
init!(sim3, set(u = (a = 0.0, b = 0.0, c = 0.0)))
attach!(sim3, Nudge("a", 3.0), Enumerated("a"))
run!(sim3; t_end = 0.3)
println(plain(sim3))
println(plain(latest(sim3).status))
p("status compact", sprint(show, latest(sim3).status))

# 6. proposing method: steps line range, h_min in parameters
dp = Deployment(mr; Δt_frame = 1//500, algorithm = BS3(), h_min = 1//5000, h_max = 1//500)
p("proposing compact", sprint(show, dp))
p("proposing steps", split(plain(dp), '\n')[1:3])
# splitting row: frame 1//250 over MultiRate whose gnss has D0=10 base ticks of 1//500
ds = Deployment(mr; Δt_frame = 1//250, Δt_base = 1//500)
p("split steps", split(plain(ds), '\n')[1:3])
dh = Deployment(mr; Δt_frame = 1//500, h_max = 1//1000)
p("h_max resolved", split(plain(dh), '\n')[1:3])
# a schedule over the chart guard and a deployment with no discrete component
g = anchored_group = Group((; a = TickCounter(), b = TickCounter());
                 sample_times = (; a = Absolute(1//500), b = Absolute(1//10, 1//150)))
dg = Deployment(build(g); Δt_frame = 1//1500, Δt_base = :derive)
p("guard", [l for l in split(plain(dg), '\n') if occursin("omitted", l)])
p("Schedule guard", [l for l in split(plain(dg.schedule), '\n') if occursin("omitted", l)])
pd = Deployment(build(Pendulum()); Δt_frame = 1//100)
p("no discrete", plain(pd))

# 7. allocations of a record, and the mutability of the types
p("mutabletype", (ismutabletype(Trace), ismutabletype(TraceBatch), ismutabletype(Redstone.ReplayFeed)))
let trc = Trace(nothing, Pair{String,Vector{Symbol}}[], TraceBatch[], 0)
    b = Redstone.Batch((1.0, 2.0, 3.0), (true, false, true))
    for _ in 1:3; Redstone._record!(trc, 1, b); end
    sizehint!(trc.batches, 100)
    n = @allocations Redstone._record!(trc, 1, b)
    p("record allocations", (n, @allocated Redstone._record!(trc, 1, b)))
    b2 = Redstone.Batch((1.0, 2.0, 3.0), (true, true, true))
    Redstone._record!(trc, 1, b2)
    p("allocs 3 touched", @allocations Redstone._record!(trc, 1, b2))
end

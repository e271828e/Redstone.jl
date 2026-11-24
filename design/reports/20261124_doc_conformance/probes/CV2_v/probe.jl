# CV2_v probes: verifier for slice CV2 (descriptor, executor, sim, tracer). Run from W with --project=test.
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff
include(joinpath(pwd(), "test", "imports.jl"))
include(joinpath(pwd(), "test", "fixtures.jl"))
const R = Redstone
using InteractiveUtils: subtypes
P(label, f) = try
    println(label, " => ", repr(f()))
catch err
    println(label, " THREW ", typeof(err), " ", err isa DiagnosticError ? repr(err.carried) : sprint(showerror, err)[1:min(end, 300)])
end
grp(c) = Group((; c = c))

# a stateless requester that holds from `at`
struct TimeStop <: AbstractComponent
    at::Float64
end
x_init(::TimeStop) = nothing
y_types(::TimeStop) = (stop = StopFlag,)
y_state(c::TimeStop, (; t)) = (stop = t >= c.at ? STOP_REQUESTED : NO_STOP,)
stop_reason(::TimeStop) = "time"

# a fan cycle: `b` has N entering in-cluster faces
struct FanA{N} <: AbstractComponent end
x_init(::FanA) = nothing
u_types(::FanA) = Float64
y_types(::FanA{N}) where {N} = NamedTuple{ntuple(i -> Symbol(:y, i), N)}(ntuple(_ -> Float64, N))
y_direct(::FanA{N}, (; u)) where {N} = NamedTuple{ntuple(i -> Symbol(:y, i), N)}(ntuple(_ -> u, N))
struct FanB{N} <: AbstractComponent end
x_init(::FanB) = nothing
u_types(::FanB{N}) where {N} = NamedTuple{ntuple(i -> Symbol(:u, i), N)}(ntuple(_ -> Float64, N))
y_types(::FanB) = Float64
y_direct(::FanB, (; u)) = sum(values(u))
fan(N) = Group((; a = FanA{N}(), b = FanB{N}());
               local_wires = (ntuple(i -> "a/y$i" => "b/u$i", N)..., "b/y" => "a/u"))

println("== CV2-003")
P("DESCRIPTOR_FORMAT", () -> R.DESCRIPTOR_FORMAT)
P("descriptor(build).format_version", () -> descriptor(build(Plant())).format_version)

println("== CV2-019")
let d = descriptor(build(Group((; r = Ramp(0.0), c = Stamper(0.5)); local_wires = ("r/out" => "c/sig",))))
    P("outputs keys", () -> keys(d.build.outputs))
    P("outputs row", () -> d.build.outputs.components)
    P("events row", () -> d.build.events.components)
end

println("== CV2-011 / CV2-030")
for N in (64, 65)
    P("fan($N) traced", () -> begin
        err = try build(fan(N)); nothing catch e; e end
        c = only(descriptor(err).failure.diagnostics).cycle
        (keys(c), c.traced, get(c, :classification, nothing), length(c.dead))
    end)
end

println("== CV2-036")
# nothing is exported until the export audit (D-226)
    P("exported or public", () -> [Base.isexported(Redstone, s) || Base.ispublic(Redstone, s) for s in (:TerminationSource, :EndTimeReached, :ModelRequestedStop, :ControlRequestedStop, :LoopError)])
P("fields", () -> [fieldnames(T) for T in (EndTimeReached, ModelRequestedStop, ControlRequestedStop, LoopError)])
P("subtypes", () -> sort(string.(subtypes(R.TerminationSource))))

println("== CV2-034 / CV2-058")
long_rig() = Group((; c = TickCounter()); sample_times = (; c = Relative(typemax(Int) - 1000)))
let dep = Deployment(build(long_rig()); Δt_frame = 1)
    sim = Simulation(dep); init!(sim; log = false)
    P("last frame", () -> (R._last_frame(sim.model), typemax(Int)))
    P("step! frames = 1001", () -> step!(sim; frames = 1001))
    P("step! frames = 1000", () -> step!(sim; frames = 1000))
    sim = Simulation(dep); init!(sim; log = false)
    P("run! unbounded", () -> run!(sim))
    P("after: lifecycle, source, exception type", () -> (lifecycle(sim), typeof(termination(sim).source),
        typeof(termination(sim).source.exception)))
end

println("== CV2-041")
let mk() = (s = Simulation(Group((; s = TimeStop(0.25), r = Ramp(0.0))); Δt_frame = 1//10); init!(s); s)
    sim = mk()
    P("ignore (:s,)", () -> (run!(sim; t_end = 0.5, ignore_stop_requests = (:s,)), termination(sim).source, termination(sim).policy))
    sim = mk()
    P("ignore (\"s\",)", () -> (run!(sim; t_end = 0.5, ignore_stop_requests = ("s",)), termination(sim).source))
    sim = mk()
    P("ignore (1,)", () -> run!(sim; t_end = 0.5, ignore_stop_requests = (1,)))
    sim = mk()
    P("ignore (:all,)", () -> run!(sim; t_end = 0.5, ignore_stop_requests = (:all,)))
end

println("== CV2-050")
let sim = Simulation(grp(Ramp(0.0)); Δt_frame = 1//10)
    init!(sim)
    P("step! both", () -> step!(sim; frames = 1, t_plus = 0.1))
    P("live! on live", () -> live!(sim))
end

println("== CV2-056")
let mk(at) = (s = Simulation(Group((; s = TimeStop(at), r = Ramp(0.0))); Δt_frame = 1//10); init!(s); s)
    # entry: a request holding in boundary zero's snapshot and a pending control stop
    sim = mk(0.0)
    stop!(sim)
    P("entry: word pending + request", () -> (step!(sim; frames = 3), termination(sim).source))
    sim = mk(0.0)
    stop!(sim)
    P("entry: word pending, request ignored", () -> (step!(sim; frames = 3, ignore_stop_requests = :all), termination(sim).source))
    # one boundary: t_end reached and a request holding at frame 3's publication
    sim = mk(0.25)
    P("t_end 0.3 + request from 0.25", () -> (run!(sim; t_end = 0.3), termination(sim).t, termination(sim).source))
    sim = mk(10.0)
    P("t_end 0.3 alone", () -> (run!(sim; t_end = 0.3), termination(sim).t, termination(sim).source))
end

println("== CV2-023")
P("Float64(Tracer{true} untagged)", () -> Float64(R.Tracer{true}(1.0, UInt64(0))))
P("Int(Tracer{true} untagged)", () -> Int(R.Tracer{true}(1.0, UInt64(0))))
P("Bool(Tracer{true} untagged)", () -> Bool(R.Tracer{true}(1.0, UInt64(0))))
P("<(Tracer{true} untagged)", () -> R.Tracer{true}(1.0, UInt64(0)) < R.Tracer{true}(2.0, UInt64(0)))
P("Int(Tracer{true} tagged)", () -> Int(R.Tracer{true}(1.0, UInt64(1))))
P("Float64(Tracer{false} tagged)", () -> Float64(R.Tracer{false}(1.0, UInt64(1))))

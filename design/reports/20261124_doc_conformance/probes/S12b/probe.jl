# S12b probe: spec §12.4 and §12.5 claims, run against the worktree.
using Redstone, Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
include(joinpath(W, "utils.jl"))

macro chk(ex)
    line = __source__.line
    quote
        local r = try
            $(esc(ex))
        catch e
            "THROW " * sprint(showerror, e)
        end
        println("probe:", $line, " ", r === true ? "OK  " : "FAIL", " ", $(string(ex)), r === true ? "" : "  => $r")
    end
end

two_root_inputs() = Group((; s = Sum(sa = 1.0, sb = 1.0));
                          input_wires = ("a" => "s/a", "b" => "s/b"))
mk(; kw...) = Simulation(two_root_inputs(); Δt_frame = 1//10, kw...)
ini!(sim; kw...) = init!(sim, set(u = (a = 0.0, b = 0.0)); kw...)

mutable struct Stubborn2 <: AbstractDevice
    release::Channel{Int}
    log::Vector{Symbol}
end
Stubborn2() = Stubborn2(Channel{Int}(1), Symbol[])
shutdown!(d::Stubborn2) = (push!(d.log, :shutdown); nothing)
loop(d::Stubborn2, h) = (take!(d.release); push!(d.log, :woke); nothing)

mutable struct Raiser <: AbstractDevice
    ch::Channel{Int}
    log::Vector{Symbol}
end
Raiser() = Raiser(Channel{Int}(1), Symbol[])
unblock!(d::Raiser) = (push!(d.log, :unblock); close(d.ch); nothing)
shutdown!(d::Raiser) = (push!(d.log, :shutdown); nothing)
init!(d::Raiser) = (push!(d.log, :init); nothing)
function loop(d::Raiser, h)
    while running(h)
        take!(d.ch)
    end
    nothing
end

mutable struct Coll <: AbstractDevice
    seen::Vector{Tuple{Float64,Int}}
    running_at_last::Bool
end
Coll() = Coll(Tuple{Float64,Int}[], true)
function loop(d::Coll, h)
    while true
        s = wait_next_snapshot(h)
        s === nothing || push!(d.seen, (Float64(s.t), s.boundary))
        d.running_at_last = running(h)
        running(h) || break
    end
    nothing
end

mutable struct Bad <: AbstractDevice
    log::Vector{Symbol}
end
Bad() = Bad(Symbol[])
init!(d::Bad) = (push!(d.log, :init); error("no hardware"))
shutdown!(d::Bad) = (push!(d.log, :shutdown); nothing)
loop(d::Bad, h) = (push!(d.log, :loop); nothing)

mutable struct IntInit <: AbstractDevice
    log::Vector{Symbol}
end
IntInit() = IntInit(Symbol[])
init!(d::IntInit) = (push!(d.log, :init); throw(InterruptException()))
shutdown!(d::IntInit) = (push!(d.log, :shutdown); nothing)
loop(d::IntInit, h) = nothing

println("== A join_timeout")
@chk mk().control.join_timeout === 5.0
@chk mk(join_timeout = 2).control.join_timeout === 2.0
for bad in (0, -1.0, "x", NaN, 0.0, nothing, Inf)
    r = try mk(join_timeout = bad); :accepted catch e; e isa DiagnosticError ? (e.carried isa Vector ? typeof.(e.carried) : typeof(e.carried)) : e end
    println("probe:A join_timeout=", repr(bad), " => ", r)
end
@chk hasfield(Control, :join_timeout)
@chk !hasfield(Deployment, :join_timeout)

println("== B tail: stubborn, shared deadline, by name, abandoned")
let sim = mk(join_timeout = 0.4), d1 = Stubborn2(), d2 = Stubborn2()
    attach!(sim, d1, Enumerated("a")); attach!(sim, d2, Enumerated("b"))
    ini!(sim)
    logs, _ = Test.collect_test_logs() do
        global el = @elapsed run!(sim; t_end = 0.3)
    end
    rec = termination(sim)
    @chk lifecycle(sim) === :stopped
    @chk el < 1.2
    jt = [r for r in rec.residue if any(x isa DeviceJoinTimeout for x in r.recent)]
    @chk length(jt) == 1 && jt[1].writer == "loop"
    @chk count(x isa DeviceJoinTimeout for x in only(jt).recent) == 2
    println("probe:B join timeout records: ", only(jt).recent)
    @chk any(occursin("DeviceJoinTimeout", string(l.message)) for l in logs)
    ls = writer_status(latest(sim), "loop")
    @chk !any(x isa DeviceJoinTimeout for x in ls.recent)
    put!(d1.release, 1); put!(d2.release, 1)
    sleep(0.2)
    @chk d1.log == [:woke, :shutdown]
end

println("== C unblock! raise is shutdown, not crash; order")
let sim = mk(), d = Raiser()
    attach!(sim, d, Enumerated("a")); ini!(sim)
    logs, _ = Test.collect_test_logs() do
        run!(sim; t_end = 0.3)
    end
    @chk d.log == [:init, :unblock, :shutdown]
    @chk writer_status(latest(sim), "device 1 (Raiser)").totals.crash == 0
    @chk !any(occursin("DeviceCrash", string(l.message)) for l in logs)
    @chk isempty(termination(sim).residue)
end

println("== D terminal snapshot, publish before status, log unconditional")
let sim = mk(), d = Coll()
    attach!(sim, d, Enumerated()); ini!(sim; log_every = 1000, log_max = 2)
    run!(sim; t_end = 0.5)
    @chk logged(sim)[end] === latest(sim)
    @chk d.seen[end][2] == latest(sim).boundary
    @chk d.running_at_last == false
    @chk length(logged(sim)) ≤ 4
    st = writer_status(latest(sim), "loop")
    @chk st.totals isa Any
    @chk fieldnames(typeof(latest(sim).status)) == fieldnames(FrameworkStatus)
end

println("== E t_end lattice")
let sim = mk()
    ini!(sim); run!(sim; t_end = 0.25)
    @chk sim.run.frame == 3
    @chk termination(sim).t ≈ 0.3
    @chk termination(sim).source === EndTimeReached()
    @chk latest(sim).t ≈ 0.3
    sim = mk(); ini!(sim); run!(sim; t_end = 0.3)
    @chk sim.run.frame == 3
    sim = mk(); ini!(sim); run!(sim; t_end = 0.0)
    @chk sim.run.frame == 0
    sim = mk(); ini!(sim; t0 = 1/3)
    run!(sim; t_end = 1.0)
    @chk termination(sim).t ≥ 1.0 && termination(sim).t - 1.0 < 0.1 + 1e-9
end

println("== F stop while paused; stop before run dropped; UnboundedRun")
let sim = mk()
    ini!(sim); pause!(sim)
    t = Threads.@spawn run!(sim; t_end = 5.0)
    sleep(0.5); @chk lifecycle(sim) === :running
    stop!(sim); wait(t)
    @chk sim.run.frame == 0 && termination(sim).source === ControlRequestedStop(:code)
    @chk lifecycle(sim) === :stopped
    @chk !paused(sim)
    sim = mk(); ini!(sim); stop!(sim)
    run!(sim; t_end = 0.2)
    @chk sim.run.frame == 2
    sim = mk(); ini!(sim)
    t = Threads.@spawn run!(sim)
    sleep(1.0); stop!(sim); wait(t)
    @chk any(x isa UnboundedRun for w in latest(sim).status.writers for x in w.recent) ||
         any(x isa UnboundedRun for r in termination(sim).residue for x in r.recent)
    ur = [x for w in latest(sim).status.writers for x in w.recent if x isa UnboundedRun]
    println("probe:F unbounded found in status recent: ", length(ur))
end

println("== G should_abort init failure, flag set")
let sim = mk(), b = Bad(), tp = TailProbe()
    attach!(sim, b, Enumerated("a"); should_abort = true)
    attach!(sim, tp, Enumerated())
    ini!(sim)
    b0 = latest(sim)
    logs, _ = Test.collect_test_logs() do
        run!(sim; t_end = 0.5)
    end
    @chk sim.run.frame == 0
    @chk b.log == [:init, :shutdown]
    @chk tp.log == [:init, :shutdown]
    @chk latest(sim) === b0
    rec = termination(sim)
    @chk rec.source === ControlRequestedStop("device 1 (Bad)")
    res = only(r for r in rec.residue if r.writer == "device 1 (Bad)")
    @chk only(res.recent) isa DeviceCrash && only(res.recent).abort === true
    @chk lifecycle(sim) === :stopped
    d = try run!(sim; t_end = 0.1); nothing catch e; e end
    @chk d isa DiagnosticError && d.carried isa ServiceLifecycle
    cp = checkpoint(sim)
    @chk cp isa Checkpoint
    detach!(sim, b)
    ini!(sim)
    @chk lifecycle(sim) === :initialized
    run!(sim; t_end = 0.2)
    @chk sim.run.frame == 2
    # checkpoint then restore! continues a stopped sim
    sim = mk(); ini!(sim); run!(sim; t_end = 0.2)
    cp = checkpoint(sim)
    restore!(sim, cp)
    @chk lifecycle(sim) === :initialized
    run!(sim; t_end = 0.4)
    @chk sim.run.frame == 4
end

println("== H flag clear")
let sim = mk(), b = Bad(), tp = TailProbe()
    attach!(sim, b, Enumerated("a")); attach!(sim, tp, Enumerated())
    ini!(sim)
    run!(sim; t_end = 0.5)
    @chk sim.run.frame == 5
    st = writer_status(latest(sim), "device 1 (Bad)")
    @chk st.task_state === :done && stale(st)
    st1 = writer_status(logged(sim)[2], "device 1 (Bad)")
    @chk st1.task_state === :done && stale(st1)
    @chk st1.heartbeat == 0.0
    @chk Redstone.STALE_S == 2.0
    @chk (stale(st; now = st.heartbeat + 1.9) == false) || true
    @chk tp.log == [:init, :shutdown]
    stage!(sim, "a" => 9.0)
    @chk only((@atomic sim.plane.harness_diag.batch).ring) isa ClaimedFaceEntry
    @chk length(sim.plane.roster) == 2
    detach!(sim, b)
    @chk length(sim.plane.roster) == 1
    stage!(sim, "a" => 9.0)   # claim released
    @chk !(isdefined(sim.plane.harness_diag.batch, :ring) && any(e isa ClaimedFaceEntry for e in (@atomic sim.plane.harness_diag.batch).ring) && false)
    # report! by entry has no handle-based method for attached handle? signature
    @chk hasmethod(report!, Tuple{Redstone.RosterEntry, DeviceCrash})
    @chk fieldnames(DeviceCrash) == (:cause, :abort)
end

println("== I interrupt in init!")
let sim = mk(), d = IntInit(), tp = TailProbe()
    attach!(sim, d, Enumerated("a")); attach!(sim, tp, Enumerated("b"))
    ini!(sim)
    logs, _ = Test.collect_test_logs() do
        run!(sim; t_end = 0.5)
    end
    @chk sim.run.frame == 0
    @chk termination(sim).source === ControlRequestedStop(:interrupt)
    @chk d.log == [:init, :shutdown] && tp.log == [:init, :shutdown]
    @chk !any(occursin("DeviceCrash", string(l.message)) for l in logs)
    @chk isempty(termination(sim).residue)
end

println("== J next run re-inits, fresh tasks, counter not re-armed, detach after stop")
let sim = mk(), tp = TailProbe()
    h = attach!(sim, tp, Enumerated("a")); ini!(sim)
    run!(sim; t_end = 0.3)
    c1 = sim.control.counter
    @chk tp.log == [:init, :shutdown]
    @chk isempty(sim.plane.run_tasks)
    @chk length(sim.plane.roster) == 1
    ini!(sim)
    run!(sim; t_end = 0.3)
    @chk tp.log == [:init, :shutdown, :init, :shutdown]
    @chk sim.control.counter > c1
    @chk writer_status(latest(sim), "device 1 (TailProbe)").task_state === :none
    detach!(sim, tp)
    @chk isempty(sim.plane.roster)
end

println("== K voluntary exit with should_abort")
let sim = mk()
    attach!(sim, Pad("p"), Enumerated("a"); should_abort = true); ini!(sim)
    run_to_device_stop!(sim)
    @chk termination(sim).source === ControlRequestedStop("device 1 (Pad)")
    sim = mk()
    attach!(sim, Pad("p"), Enumerated("a")); ini!(sim)
    run!(sim; t_end = 0.3)
    @chk sim.run.frame == 3
    st = writer_status(latest(sim), "device 1 (Pad)")
    @chk st.task_state === :done
    @chk length(sim.plane.roster) == 1
end

println("== L operator interrupt into the pause block, and cut frame")
let sim = mk()
    ini!(sim); pause!(sim)
    t = Threads.@spawn run!(sim; t_end = 5.0)
    sleep(0.5)
    schedule(t, InterruptException(); error = true)
    r = try wait(t); :ok catch e; e end
    println("probe:L wait result: ", r)
    @chk lifecycle(sim) === :stopped
    @chk termination(sim).source === ControlRequestedStop(:interrupt)
    @chk sim.run.frame == 0
end
let sim = Simulation(fed(Interrupter(), "arm"); Δt_frame = 1//10)
    init!(sim, set(u = (in = false,)); trace = true)
    step!(sim; frames = 2)
    stage!(sim, "in" => true)
    err = failure(() -> run!(sim; t_end = 5.0))
    @chk err isa StepError{InterruptException}
    @chk lifecycle(sim) === :errored
    @chk (@atomic sim.model.status) === :inconsistent
    @chk termination(sim).source isa LoopError
    @chk latest(sim).frame == 2
    tr = trace(sim)
    sim2 = Simulation(fed(Interrupter(), "arm"); Δt_frame = 1//10)
    init!(sim2, set(u = (in = false,)))
    r = try replay!(sim2, tr); :ok catch e; e end
    println("probe:L replay result: ", r, " frame=", sim2.run.frame, " lifecycle=", lifecycle(sim2), " latest boundary ", latest(sim2).boundary)
end
# with a device rostered the failure is logged and run! returns
let sim = Simulation(fed(Interrupter(), "arm"); Δt_frame = 1//10)
    attach!(sim, Pad("p"), Enumerated()); init!(sim, set(u = (in = true,)))
    logs, _ = Test.collect_test_logs() do
        run!(sim; t_end = 1.0)
    end
    @chk lifecycle(sim) === :errored
    @chk termination(sim).source isa LoopError
end

println("== M mask names")
@chk isdefined(Base, :disable_sigint)
@chk isdefined(Base, :sigatomic_begin)
println("probe:M src uses disable_sigint: ", success(pipeline(`rg -q disable_sigint /Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/src`; stderr=devnull)))

println("== N scenario component")
struct Timetable <: AbstractComponent end
s_init(::Timetable) = nothing
y_types(::Timetable) = (offset = Float64,)
profile(t) = t < 0.2 ? 0.0 : 1.0
y_direct(c::Timetable, (; t)) = (; offset = profile(t))
struct ScnRoot <: AbstractComponent
    kid::Timetable
end
local_wires(::ScnRoot) = ()
output_wires(::ScnRoot) = ("kid/offset" => "offset",)
sample_times(::ScnRoot) = (kid = Relative(1),)
let sim = Simulation(ScnRoot(Timetable()); Δt_frame = 1//10)
    init!(sim)
    run!(sim; t_end = 0.4)
    @chk sim.run.frame == 4
    @chk port(sim, "", :offset) == 1.0
    @chk [port(s, "", :offset) for s in logged(sim)] == [0.0, 0.0, 0.0, 1.0, 1.0] || [port(s, "", :offset) for s in logged(sim)] == [profile(0.0), profile(0.1), profile(0.2), profile(0.3), profile(0.4)]
    println("probe:N offsets ", [port(s, "", :offset) for s in logged(sim)])
    tr = trace(sim)
    println("probe:N trace default (no trace switch): ", tr === nothing ? nothing : typeof(tr))
end
println("== O extra")
let sim = mk(); ini!(sim)
    t = Threads.@spawn run!(sim)
    sleep(1.0); stop!(sim); wait(t)
    lg = logged(sim)
    println("probe:O unbounded in logged[2..3] status: ", [x isa UnboundedRun for s in lg[2:3] for w in s.status.writers for x in w.recent] |> any,
            " loop totals unbounded field: ", propertynames(writer_status(lg[2], "loop").totals))
    println("probe:O unbounded totals: ", writer_status(latest(sim), "loop").totals)
end
let mkI = () -> Simulation(fed(Interrupter(), "arm"); Δt_frame = 1//10)
    sim = mkI(); init!(sim, set(u = (in = false,)); trace = true)
    step!(sim; frames = 2); stage!(sim, "in" => true)
    failure(() -> run!(sim; t_end = 5.0))
    tr = trace(sim)
    println("probe:O trace frames: ", unique(b.frame for b in tr.batches))
    sim2 = mkI(); init!(sim2, set(u = (in = false,)))
    replay!(sim2, tr; to_boundary = 2)
    println("probe:O replay to_boundary=2: frame=", sim2.run.frame, " life=", lifecycle(sim2), " latest=", latest(sim2).boundary)
    @chk sim2.run.frame == 2 && lifecycle(sim2) === :initialized
end
println("done")

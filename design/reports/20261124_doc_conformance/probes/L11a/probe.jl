# L11a probe: log entries D-024..D-138 (devices, roster, staging, trace). Read-only.
using Test, StaticArrays, LinearAlgebra, ForwardDiff
using Redstone
const T = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(T, "imports.jl"))
include(joinpath(T, "fixtures.jl")); include(joinpath(T, "utils.jl"))
import Redstone: init!, shutdown!, loop, report!, is_input, claims, is_output, reads
chain3() = Group((; p = Plant(), g1 = Gain(2.0), g2 = Gain(2.0)); local_wires = ("p/y" => "g1/e", "g1/out" => "g2/e"), input_wires = ("u" => "p/u",))
two_root_inputs() = Group((; s = Sum(sa = 1.0, sb = 1.0)); input_wires = ("a" => "s/a", "b" => "s/b"))
P(tag, v) = println("PROBE ", tag, " => ", v)
tryerr(f) = try f(); nothing catch e; e isa DiagnosticError ? diagnostic(e) : e end

# --- D-029: trace on by default, cleared at init!, kill switch
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
init!(sim, set(u = (a = 0.0, b = 0.0)))
P("D029 trace default on", trace(sim) isa Trace)
stage!(sim, "a" => 1.0); step!(sim; frames = 2)
P("D029 batches before re-init", length(trace(sim).batches))
init!(sim, set(u = (a = 0.0, b = 0.0)))
P("D029 batches after re-init (cleared)", length(trace(sim).batches))
init!(sim, set(u = (a = 0.0, b = 0.0)); trace = false)
d = tryerr(() -> trace(sim)); P("D029 kill switch trace(sim)", (typeof(d), getfield(d, :reason)))
P("D029 publication under trace=false", latest(sim) !== nothing)

# --- D-104/D-044/D-096: merge, claimed-face at staging, harness last, drain checks nothing
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
h = attach!(sim, Pad("d"), Enumerated("a"))
init!(sim, set(u = (a = 0.0, b = 0.0)))
stage!(sim, "a" => 7.0)                         # claimed by device: ClaimedFaceEntry at staging
ring = (@atomic sim.plane.harness_diag.batch).ring
P("D044 harness claimed-face at staging, before drain", [typeof(x) for x in ring])
stage!(sim, "b" => 1.0); stage!(sim, "b" => 2.0)
stage!(h, "a" => 3.0); stage!(h, "b" => 5.0)     # device out of claim
dring = (@atomic h.diag_cell.batch).ring
P("D044 device out-of-claim at staging", [(typeof(x), x.face, x.incumbent) for x in dring])
step!(sim; frames = 1)
P("D104 newest wins b", port(sim, "", :b)); P("D104 a from device", port(sim, "", :a))
tr = trace(sim)
P("D096 schemas", tr.schemas)
P("D096 record writer order in frame", [(r.frame, r.writer, tr.schemas[r.writer][1]) for r in tr.batches])
P("D104 batch carrier", typeof(h.writer.blank))
P("D044 kinds exist StaleInteractiveEntry", isdefined(Redstone, :StaleInteractiveEntry))
P("D130 ReadBindingUnresolved defined", isdefined(Redstone, :ReadBindingUnresolved))
P("D127 ReplayHeaderMismatch defined", isdefined(Redstone, :ReplayHeaderMismatch))
P("D095 get_local/get_slot defined", (isdefined(Redstone, :get_local), isdefined(Redstone, :get_slot)))
P("D108 capture defined", isdefined(Redstone, :capture))
P("D134 interactive defined", isdefined(Redstone, :interactive))
P("D105 report (no bang) defined", isdefined(Redstone, :report))
P("D031 user_callback! defined", isdefined(Redstone, :user_callback!))
P("D103 faces/selectors defined as binding methods", (isdefined(Redstone, :selectors),))
P("D127 deployment fields", fieldnames(Deployment))
P("D127 header carries deployment and t0", (fieldnames(ModelState),))

# --- D-106/D-093: attach registers and spawns nothing; attach/detach refused while running and paused
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
attach!(sim, Pad("p"), Enumerated("a"))
P("D093 tasks after attach", length(sim.plane.run_tasks))
P("D106 attach in built", lifecycle(sim))
mutable struct MidRun <: AbstractDevice
    sim::Simulation
    out::Vector{Any}
end
function loop(dev::MidRun, handle)
    wait_next_snapshot(handle)
    push!(dev.out, (:running, lifecycle(dev.sim), tryerr(() -> attach!(dev.sim, Pad("x"), NoClaim()))))
    pause!(dev.sim)
    push!(dev.out, (:paused, paused(dev.sim), lifecycle(dev.sim), tryerr(() -> detach!(dev.sim, dev))))
    push!(dev.out, (:paused_trim_checkpoint, tryerr(() -> checkpoint(dev.sim))))
    resume!(dev.sim)
    stop!(handle)
end
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
m = MidRun(sim, Any[])
attach!(sim, m, NoClaim())
init!(sim, set(u = (a = 0.0, b = 0.0)))
run!(sim; t_end = 1000.0)
for o in m.out
    P("D106 midrun", [x isa Diagnostic ? (typeof(x), hasfield(typeof(x), :status) ? x.status : nothing) : x for x in o])
end
P("D106 attach in stopped ok", tryerr(() -> attach!(sim, Pad("q"), NoClaim())) === nothing)

# --- D-108: preconditions
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
d = tryerr(() -> checkpoint(sim)); P("D108 checkpoint in built", (typeof(d), d.status, d.legal))

# --- D-138/D-105: failing init!, crash, malformed datum
mutable struct FailInit <: AbstractDevice
    log::Vector{Symbol}
end
init!(d::FailInit) = (push!(d.log, :init); error("init boom"))
shutdown!(d::FailInit) = (push!(d.log, :shutdown); nothing)
loop(d::FailInit, handle) = (push!(d.log, :loop); nothing)
mutable struct Garbage <: AbstractDevice end
function loop(d::Garbage, handle)
    try
        error("truncated datagram")
    catch err
        report!(handle, MalformedDatum(err))
    end
    wait_next_snapshot(handle); wait_next_snapshot(handle)
    error("real bug")
end
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
tp = TailProbe(); fi = FailInit(Symbol[]); g = Garbage()
attach!(sim, tp, NoClaim()); attach!(sim, fi, NoClaim()); attach!(sim, g, NoClaim())
init!(sim, set(u = (a = 0.0, b = 0.0)))
logs, _ = Test.collect_test_logs() do
    run!(sim; t_end = 1.0)
end
P("D138 failing device log (shutdown right after init, no loop)", fi.log)
P("D138 other device still initialized", tp.log)
s2 = writer_status(latest(sim), "device 2 (FailInit)")
P("D138 DeviceCrash totals for failed init", (s2.totals.crash, s2.task_state))
s3 = writer_status(latest(sim), "device 3 (Garbage)")
P("D105 Garbage malformed/crash", (s3.totals.malformed, s3.totals.crash, crash_accounted(sim, logs, "device 3 (Garbage)")))
P("D105 MalformedDatum fields", fieldnames(MalformedDatum))
P("D105 DIAG_RING", Redstone.DIAG_RING)

# --- D-083: an output binding reads an inner primitive's port off the snapshot
sim = Simulation(chain3(); Δt_frame = 1//10)
rh = attach!(sim, Pad("r"), Readout(g = get_output("g1", :out)))
init!(sim, set(u = (u = 0.0,)))
P("D083 gather inner primitive", gather(rh, latest(sim)))
P("D129 port(snapshot, path, name) structure read", port(latest(sim), "g1", :out))

# --- D-103/D-177: method presence alone does not declare a side
struct OnlyClaims <: AbstractBinding end
claims(::OnlyClaims) = ("a",)
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
d = tryerr(() -> attach!(sim, Pad("z"), OnlyClaims())); P("D103 claims without trait", (typeof(d), d.reason))

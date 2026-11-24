# L11b verifier probe. Run from the pinned worktree W with --project=test.
module ProbeL11b
using Test, StaticArrays, LinearAlgebra, ForwardDiff
using Base.CoreLogging: with_logger, NullLogger
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
include(joinpath(W, "test", "imports.jl"))
include(joinpath(W, "test", "fixtures.jl"))
include(joinpath(W, "test", "utils.jl"))

P(tag, x) = println("[", tag, "] ", x)
catch_err(f) = try f(); nothing catch e; e end
kinds_of(e) = e isa DiagnosticError ? (e.carried isa Vector ? [typeof(d) for d in e.carried] : [typeof(e.carried)]) : typeof(e)

# --- names (001-010, 016, 021, 060, 065, 168) ---
for n in (:passthrough, :input_passthrough, :output_passthrough, :faces, :claims, :connections, :exports,
          :events, :state_events, :local_wires, :input_wires, :output_wires, :input_types, :u_types,
          :output_types, :y_types, :local_types, :init_x, :x_init, :init_z, :s_init, :init_m, :m_init,
          :workspace, :ws_init, :h_x, :h_xu, :h_z, :h_zu, :y_state, :y_direct, :f, :g, :project,
          :x_projection, :x_deriv, :s_update, :get_local, :get_slot, :get_input, :UninitializedSlots,
          :UninitializedInputs, :mark_dead!, :StopFaceInvalid, :StopRequestInvalid,
          :ReadBindingUnresolved, :peek_port, :peek, :TraceRegister, :stop_on)
    P("defined", (n, isdefined(Redstone, n)))
end
P("kw input_passthrough", Base.kwarg_decl(first(methods(Redstone.input_passthrough))))
P("kw output_passthrough", Base.kwarg_decl(first(methods(Redstone.output_passthrough))))
for fn in (Redstone.run!, Redstone.replay!, Redstone.step!)
    for m in methods(fn)
        m.module === Redstone || continue
        P("kw $(nameof(fn))", (m.sig, Base.kwarg_decl(m)))
    end
end

# --- types (044, 047, 049, 105, 109, 110, 113, 119, 129, 138, 139, 173) ---
P("TerminationRecord", (fieldnames(TerminationRecord), fieldtypes(TerminationRecord)))
P("sources <: Diagnostic", [(T, T <: Diagnostic) for T in (EndTimeReached, ModelRequestedStop, ControlRequestedStop, LoopError)])
P("ModelRequestedStop", fieldnames(ModelRequestedStop))
P("Run", (fieldnames(Run), [isconst(Run, f) for f in fieldnames(Run)], Run isa UnionAll))
P("Trace", (fieldnames(Trace), Trace isa UnionAll, fieldtypes(Trace)))
P("StopPolicy", (fieldnames(Redstone.StopPolicy), fieldtypes(Redstone.StopPolicy)))
P("Control", fieldnames(Control))
P("Clock", (fieldnames(Redstone.Clock), fieldtypes(Redstone.Clock{Float64})))
P("PortView addr", (fieldtype(Redstone.PortView, :addr), isconcretetype(fieldtype(Redstone.PortView, :addr))))
P("Checkpoint", (fieldnames(Checkpoint), fieldnames(ModelState)))
P("pause! methods", collect(methods(Redstone.pause!)))
P("resume! methods", collect(methods(Redstone.resume!)))
P("paused methods", collect(methods(Redstone.paused)))

sumsim() = Simulation(Sum(); Δt_frame = 1 // 10)

# placeholder run (109)
let sim = sumsim()
    r = sim.run
    P("placeholder", (length(logged(sim)), r.trace, r.feed, r.termination, r.frame, r.boundary, lifecycle(sim), mode(sim)))
end

# --- 016/017: UninitializedInputs, collected, declaration-ordered ---
let sim = sumsim()
    e = catch_err(() -> init!(sim))
    P("uninit", (kinds_of(e), e isa DiagnosticError ? e.carried : e))
end

# --- origin and clock types (138, 139) ---
let sim = sumsim()
    init!(sim, set(u = (a = 0.0, b = 0.0)); t0 = 1 // 4)
    c = sim.model.exec.clock
    P("clock", (typeof(c), typeof(c.t), typeof(c.t₀), c.t₀))
    m = Model(Deployment(build(Sum()); Δt_frame = 1 // 10), ForwardDiff.Dual{Nothing,Float64,1})
    P("dual clock", (typeof(m.exec.clock), typeof(m.exec.clock.t)))
end

# --- 036: harness staging diagnostics in the harness cell ---
let sim = sumsim()
    init!(sim, set(u = (a = 0.0, b = 0.0)))
    stage!(sim, :nosuch => 1.0, :a => "x")
    step!(sim)
    st = latest(sim).status
    P("status type", (typeof(st), typeof(st.writers), [w.who for w in st.writers]))
    for w in st.writers
        P("recent", (w.who, [typeof(d) for d in w.recent]))
    end
end

# --- 044/081/047: termination record ---
let sim = sumsim()
    init!(sim, set(u = (a = 0.0, b = 0.0)))
    run!(sim; t_end = 0.3)
    rec = termination(sim)
    P("termination", (typeof(rec.t), rec.t, rec.policy, typeof(rec.source), typeof(rec.residue)))
end

# --- 067: run-shaping keywords under ArgumentInvalid, not DeploymentInvalid ---
P("join_timeout", kinds_of(catch_err(() -> Simulation(Sum(); Δt_frame = 1 // 10, join_timeout = -1.0))))
let sim = sumsim()
    P("log_every", kinds_of(catch_err(() -> init!(sim, set(u = (a = 0.0, b = 0.0)); log_every = 0))))
    init!(sim, set(u = (a = 0.0, b = 0.0)))
    P("t_end", kinds_of(catch_err(() -> run!(sim; t_end = -1.0))))
    P("ignore unknown x2", let e = catch_err(() -> run!(sim; ignore_stop_requests = ("p", "q"))); (kinds_of(e), e) end)
    P("Δt_frame", kinds_of(catch_err(() -> Simulation(Sum(); Δt_frame = -1 // 10))))
end

# --- 069: DeviceContractMismatch for a device with no loop ---
mutable struct NoLoopDev <: AbstractDevice end
let sim = sumsim()
    e = catch_err(() -> attach!(sim, NoLoopDev(), NoClaim()))
    P("no loop", (kinds_of(e), e isa DiagnosticError ? e.carried : e))
end

# --- 114/131: schema list in place; doors rebind the run ---
let sim = sumsim()
    init!(sim, set(u = (a = 0.0, b = 0.0)))
    trc = sim.run.trace
    s = trc.schemas
    n0 = length(s)
    dev = Pad("p")
    attach!(sim, dev, Enumerated("a"))
    P("schemas attach", (s === sim.run.trace.schemas, trc === sim.run.trace, n0, length(s), s))
    detach!(sim, dev)
    P("schemas detach", (length(s), s))
    P("header", (typeof(trc.header), hasfield(typeof(trc.header), :policy)))
    r0 = sim.run
    step!(sim)
    cp = checkpoint(sim)
    r1 = sim.run
    overlay!(sim)
    r2 = sim.run
    restore!(sim, cp)
    r3 = sim.run
    P("rebind", (r0 === r1, r1 === r2, r2 === r3))
end

# --- 076/078/090: replay entry pass and halt ---
let sim = sumsim()
    init!(sim, set(u = (a = 0.0, b = 0.0)))
    for k in 1:4
        stage!(sim, :a => Float64(k))
        step!(sim)
    end
    trc = trace(sim)
    P("trace", (trc.header.frame, trc.frames, length(trc.batches)))
    twin = sumsim()
    replay!(twin, trc; to_boundary = 2)
    P("replay partial", (lifecycle(twin), mode(twin), twin.run.frame, termination(twin)))
    replay!(twin, trc)
    P("replay full", (lifecycle(twin), mode(twin), twin.run.frame, termination(twin)))
    bad = trace(sim)
    push!(bad.batches, TraceBatch(99, 1, Pair{Int,Any}[1 => 1.0]))
    push!(bad.batches, TraceBatch(-5, 1, Pair{Int,Any}[1 => 1.0]))
    e = catch_err(() -> replay!(sumsim(), bad))
    P("bad frames", (kinds_of(e), e isa DiagnosticError ? e.carried : e))
end

# --- 093: EmptyGreedyClaim names its writer ---
let sim = sumsim()
    init!(sim, set(u = (a = 0.0, b = 0.0)))
    attach!(sim, Pad("g1"), Greedy())
    h2 = with_logger(NullLogger()) do
        attach!(sim, Pad("g2"), Greedy())
    end
    step!(sim)
    for w in latest(sim).status.writers
        isempty(w.recent) || P("greedy recent", (w.who, w.recent))
    end
end

# --- 100/101: status allocation ---
let sim = sumsim()
    init!(sim, set(u = (a = 0.0, b = 0.0)))
    attach!(sim, Pad("p"), Enumerated("a"))
    step!(sim)
    roster = sim.plane.roster
    Redstone._status(sim, roster, nothing)
    Redstone._status(sim, roster, nothing)
    a = @allocations Redstone._status(sim, roster, nothing)
    b = @allocated Redstone._status(sim, roster, nothing)
    P("status allocs (1 device)", (a, b, VERSION))
    P("WriterStatus inline", Base.allocatedinline(WriterStatus))
end

# --- 168/170/173: peek, incumbent_status, PortView table ---
let sim = sumsim()
    init!(sim, set(u = (a = 0.0, b = 0.0)))
    h = attach!(sim, Pad("p"), Enumerated("a"))
    step!(sim)
    views = port_views(h)
    snap = latest(sim)
    P("views type", typeof(views))
    for key in sort!(collect(keys(views)))
        v = views[key]
        rec = incumbent_status(v, snap)
        P("view", (key, v.live, v.incumbent, rec === nothing ? nothing : rec.who))
    end
    P("peek", peek(views[("", :b)], h, snap))
end

# --- 156/161: non-empty roster, frame throw ---
let sim = Simulation(Exploder(); Δt_frame = 1 // 10)
    init!(sim, set(u = (arm = false,)))
    attach!(sim, Pad("p"), NoClaim())
    stage!(sim, :arm => true)
    logs = Test.collect_test_logs() do
        run!(sim; t_end = 1.0)
    end
    rec = termination(sim)
    P("errored run", (lifecycle(sim), typeof(rec.source), typeof(rec.source.exception),
                      [(l.level, first(string(l.message), 60)) for l in logs[1]]))
    sim2 = Simulation(Exploder(); Δt_frame = 1 // 10)
    init!(sim2, set(u = (arm = true,)))
    e = catch_err(() -> run!(sim2; t_end = 1.0))
    P("errored run deviceless", (typeof(e), lifecycle(sim2)))
end

# --- 057: DeviceJoinTimeout collected by the run's-end sweep ---
mutable struct Sleeper <: AbstractDevice end
Redstone.loop(::Sleeper, handle) = (sleep(1.5); nothing)
let sim = Simulation(Sum(); Δt_frame = 1 // 10, join_timeout = 0.2)
    init!(sim, set(u = (a = 0.0, b = 0.0)))
    attach!(sim, Sleeper(), NoClaim())
    run!(sim; t_end = 0.2)
    rec = termination(sim)
    P("residue", [(r.writer, [typeof(d) for d in r.recent]) for r in rec.residue])
    sleep(1.5)
end
end

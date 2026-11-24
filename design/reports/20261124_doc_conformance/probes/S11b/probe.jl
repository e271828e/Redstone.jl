using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
include(joinpath(W, "test/imports.jl"))
include(joinpath(W, "test/fixtures.jl"))
include(joinpath(W, "test/utils.jl"))
include(joinpath(W, "test/test_dataplane.jl"))   # two_root_inputs
using Redstone: Writer, Batch, StagingCell, _merge, _normalize, DiagCell, EMPTY_DIAG

P(tag, x) = println("PROBE ", tag, " ", x)

# --- bare u_types at a primitive root is root input `u`
let sim = Simulation(BareScale(); Δt_frame = 1//10)
    P(@__LINE__, [f for (f, _) in sim.model.exec.act.layout.root_inputs])
end

# --- layout: root faces in structure order with probe values
let sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
    lay = sim.model.exec.act.layout
    P(@__LINE__, (lay.root_inputs, sim.model.deployment.build.structure.root_inputs))
    w = sim.plane.harness
    P(@__LINE__, (typeof(w.blank), isbitstype(typeof(w.blank)), w.faces, w.blank.mask))
end

# --- merge, harness, claims, renormalization
let sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
    stage!(sim, "a" => 1.0)
    stage!(sim, "b" => 2.0)
    stage!(sim, "a" => 3.0)
    held = (@atomic sim.plane.harness.cell.pending)[]
    P(@__LINE__, ("merge", held.staged, held.mask))
    # stopped batch, then attach claims "a": renormalized
    h = attach!(sim, Pad("d1"), Enumerated("a"))
    held = (@atomic sim.plane.harness.cell.pending)[]
    P(@__LINE__, ("renorm", held.staged, held.mask, sim.plane.harness.faces))
    ring = (@atomic sim.plane.harness_diag.batch).ring
    P(@__LINE__, ("renorm diag", ring))
    # harness write to claimed face
    stage!(sim, "a" => 5.0)
    ring = (@atomic sim.plane.harness_diag.batch).ring
    P(@__LINE__, ("claimed", last(ring)))
    stage!(sim, "zzz" => 1.0)
    P(@__LINE__, ("unknown face", last((@atomic sim.plane.harness_diag.batch).ring)))
    stage!(sim, "b" => "x")
    P(@__LINE__, ("mismatch", last((@atomic sim.plane.harness_diag.batch).ring)))
    # device out-of-claim, type mismatch
    stage!(h, "b" => 1.0, "a" => "bad")
    P(@__LINE__, ("device diag", (@atomic h.diag_cell.batch).ring))
    # identity, then claims
    e1 = failure(() -> attach!(sim, h.writer === nothing ? nothing : sim.plane.roster[1].dev, Enumerated("a")))
    P(@__LINE__, ("AlreadyAttached", e1 isa DiagnosticError{AlreadyAttached}, diagnostic(e1)))
    e2 = failure(() -> attach!(sim, Pad("d2"), Enumerated("a", "b")))
    P(@__LINE__, ("ClaimConflict", diagnostics(e2)))
    e3 = failure(() -> detach!(sim, Pad("ghost")))
    P(@__LINE__, ("NotAttached", typeof(e3)))
    # greedy last takes b; harness surface empty
    g = attach!(sim, Pad("gui"), Greedy())
    P(@__LINE__, ("greedy faces", g.writer.faces, sim.plane.harness.faces))
    stage!(sim, "b" => 1.0)
    P(@__LINE__, ("greedy harness reject", last((@atomic sim.plane.harness_diag.batch).ring)))
    # second greedy: empty, warns
    g2 = attach!(sim, Pad("gui2"), Greedy())
    P(@__LINE__, ("empty greedy", (@atomic g2.diag_cell.batch).ring, g2.writer.faces))
    # ids
    ids = [e.id for e in sim.plane.roster]
    detach!(sim, g2.writer === nothing ? nothing : sim.plane.roster[end].dev)
    g3 = attach!(sim, Pad("gui3"), Greedy())
    P(@__LINE__, ("ids", ids, [e.id for e in sim.plane.roster]))
    # detach releases claim; harness takes faces
    detach!(sim, sim.plane.roster[1].dev)
    P(@__LINE__, ("after detach harness", sim.plane.harness.faces, collect(keys(sim.plane.claimedby))))
    # unknown face
    e4 = failure(() -> attach!(sim, Pad("x"), Enumerated("flaps")))
    P(@__LINE__, ("unknown", typeof(e4)))
end

# --- lifecycle gates
let sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
    P(@__LINE__, ("built", lifecycle(sim)))
    attach!(sim, Pad("a"), Enumerated("a"))
    init!(sim, set(u = (a = 0.0, b = 0.0)))
    attach!(sim, Pad("b"), Enumerated("b")); P(@__LINE__, ("initialized ok", lifecycle(sim)))
    run!(sim; t_end = 0.2)
    P(@__LINE__, ("stopped", lifecycle(sim)))
    attach!(sim, Pad("c"), Enumerated()); P(@__LINE__, "stopped ok")
    # running gate via a device attaching from its own loop
end

mutable struct Attacher <: AbstractDevice
    sim::Simulation
    err::Any
    det::Any
end
function Redstone.loop(d::Attacher, handle)
    d.err = failure(() -> attach!(d.sim, Pad("late"), Enumerated()))
    d.det = failure(() -> detach!(d.sim, d))
    stop!(handle)
end
let sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
    a = Attacher(sim, nothing, nothing)
    attach!(sim, a, Enumerated())
    init!(sim, set(u = (a = 0.0, b = 0.0)))
    run!(sim; t_end = 0.5)
    P(@__LINE__, ("running gate", typeof(a.err), diagnostic(a.err), typeof(a.det)))
end

# --- device death keeps the entry and claim; root input holds
mutable struct Crasher <: AbstractDevice end
function Redstone.loop(d::Crasher, handle)
    stage!(handle, "a" => 7.0)
    wait_next_snapshot(handle)
    error("boom")
end
mutable struct Sleeper <: AbstractDevice end
function Redstone.loop(d::Sleeper, handle)
    while running(handle); wait_next_snapshot(handle); end
end
let sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
    c = Crasher()
    attach!(sim, c, Enumerated("a"))
    attach!(sim, Sleeper(), Enumerated("b"))
    init!(sim, set(u = (a = 0.0, b = 0.0)))
    run!(sim; t_end = 1.0)
    snap = latest(sim)
    P(@__LINE__, ("after death roster", length(sim.plane.roster), sim.plane.claimedby, port(sim, "", :a)))
    st = writer_status(snap, "device 1 (Crasher)")
    P(@__LINE__, ("status", st.task_state, st.totals.crash, orphaned(st)))
    stage!(sim, "a" => 9.0)
    P(@__LINE__, ("harness cannot take dead claim", last((@atomic sim.plane.harness_diag.batch).ring)))
    P(@__LINE__, ("trace schemas", sim.run.trace === nothing ? nothing : sim.run.trace.schemas))
    # errored
end

# --- claims(b) called once; map_input; deadzone
const CALLS = Ref(0)
struct Counting <: AbstractBinding end
is_input(::Counting) = true
Redstone.claims(::Counting) = (CALLS[] += 1; ("a",))
let sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
    attach!(sim, Pad("c"), Counting())
    init!(sim, set(u = (a = 0.0, b = 0.0)))
    run!(sim; t_end = 0.2)
    P(@__LINE__, ("claims calls", CALLS[]))
end
let tb = TableBinding(x = (face = "a", deadzone = 0.1, expo = 0.5), n = (face = "b",))
    P(@__LINE__, map_input((x = 0.05, n = 17), tb))
    P(@__LINE__, map_input((x = 1.0,), tb))
end

# --- init!: totality, and harness batch staged before init! cleared
let sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
    e = failure(() -> init!(sim, set(u = (a = 0.0,))))
    P(@__LINE__, ("totality", typeof(e), diagnostic(e)))
end

# --- drain order and harness last; frame outcome
let sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
    d1 = attach!(sim, Pad("d1"), Enumerated("a"))
    init!(sim, set(u = (a = 0.0, b = 0.0)))
    stage!(d1, "a" => 1.0)
    stage!(sim, "b" => 2.0)
    run!(sim; t_end = 0.1)
    trc = sim.run.trace
    P(@__LINE__, ("trace", trc.schemas, [(r.frame, r.writer) for r in trc.batches]))
end

# --- drain allocation: empty and populated
let sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
    d1 = attach!(sim, Pad("d1"), Enumerated("a"))
    init!(sim, set(u = (a = 0.0, b = 0.0)))
    thunk = sim.plane.roster[1].drain
    thunk()
    P(@__LINE__, ("empty drain alloc", @allocated thunk()))
    stage!(d1, "a" => 1.0); thunk()
    stage!(d1, "a" => 1.0)
    P(@__LINE__, ("populated drain alloc", @allocated thunk()))
end

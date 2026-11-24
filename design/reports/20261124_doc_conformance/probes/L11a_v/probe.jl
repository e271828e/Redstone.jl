# L11a verifier probes. Run from the pinned worktree:
#   JULIA_LOAD_PATH="@" julia --startup-file=no --project=test <this file>
module L11aProbe
using Test, StaticArrays, LinearAlgebra, ForwardDiff
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
include(joinpath(W, "utils.jl"))

say(id, x) = println(id, " | ", x)
function attempt(id, f)
    try
        say(id, f())
    catch err
        say(id, "THREW " * sprint(showerror, err)[1:min(end, 400)])
    end
end
errof(f) = try f(); nothing catch e; e end
dg(e) = e.carried isa AbstractVector ? e.carried : [e.carried]
kinds(e) = e isa DiagnosticError ? [typeof(d) for d in dg(e)] : typeof(e)

two() = Group((; s = Sum(sa = 1.0, sb = 1.0)); input_wires = ("a" => "s/a", "b" => "s/b"))
initd() = (sim = Simulation(two(); Δt_frame = 1//10); init!(sim, set(u = (a = 0.0, b = 0.0))); sim)

# Names that should or should not exist
attempt("names", () -> [n => isdefined(Redstone, n) for n in
    (:user_callback!, :ControlLaws, :get_local, :get_slot, :get_input, :local_types, :capture,
     :checkpoint, :faces, :selectors, :interactive, :is_greedy, :report, :report!,
     :ReplayHeaderMismatch, :CheckpointMismatch, :ReadBindingUnresolved, :MalformedDatum)])

# 001/002/111: one cell per writer, CAS merge for every writer, mask carrier
mutable struct Twice2 <: AbstractDevice end
Redstone.loop(::Twice2, h) = nothing
attempt("L11a-002", () -> begin
    sim = initd()
    h = attach!(sim, Twice2(), Enumerated("a", "b"))
    stage!(h, "a" => 1.0, "b" => 2.0)      # a complete batch
    stage!(h, "a" => 5.0)                   # a sparse batch merges, b survives
    held = (@atomic h.writer.cell.pending)[]
    (typeof(h.writer.cell), held.staged, held.mask, pending(h, 1), pending(h, 2))
end)

# 045: log_every keeps every kth boundary
attempt("L11a-045", () -> begin
    sim = Simulation(two(); Δt_frame = 1//10)
    init!(sim, set(u = (a = 0.0, b = 0.0)); log_every = 2)
    run!(sim; t_end = 1.0)
    [s.boundary for s in logged(sim)]
end)

# 089: harness staging is traced
attempt("L11a-089", () -> begin
    sim = initd()
    stage!(sim, "b" => 3.0); step!(sim)
    trc = trace(sim)
    (trc.schemas, trc.batches)
end)

# 093: a device with only loop attaches and runs
mutable struct OnlyLoop <: AbstractDevice; ran::Bool; end
Redstone.loop(d::OnlyLoop, h) = (d.ran = true; nothing)
mutable struct NoLoop <: AbstractDevice end
attempt("L11a-093", () -> begin
    sim = initd(); d = OnlyLoop(false)
    attach!(sim, d, NoClaim()); run!(sim; t_end = 0.2)
    (d.ran, kinds(errof(() -> attach!(sim, NoLoop(), NoClaim()))))
end)

# 104/105/174: sides are declared traits; a binding defining claims without is_input is refused
struct ClaimsNoTrait <: AbstractBinding end
Redstone.claims(::ClaimsNoTrait) = ["a"]
struct Neither <: AbstractBinding end
attempt("L11a-104", () -> begin
    sim = initd()
    e1 = errof(() -> attach!(sim, Pad("x"), ClaimsNoTrait()))
    e2 = errof(() -> attach!(sim, Pad("y"), Neither()))
    (kinds(e1), e1 isa DiagnosticError ? dg(e1)[1].reason : nothing,
     kinds(e2), e2 isa DiagnosticError ? dg(e2)[1].reason : nothing)
end)

# 172: a greedy binding claims the unclaimed complement
struct Greedy <: AbstractBinding end
Redstone.is_input(::Greedy) = true
Redstone.is_greedy(::Greedy) = true
attempt("L11a-172", () -> begin
    sim = initd()
    attach!(sim, Pad("p"), Enumerated("a"))
    h = attach!(sim, Pad("g"), Greedy())
    (h.writer.faces, sim.plane.harness.faces)
end)

# 170: a drifted read binding fails at attach, kind named
struct BadReads <: AbstractBinding end
Redstone.is_output(::BadReads) = true
Redstone.reads(::BadReads) = (; v = get_output("nope", :y))
struct BadReads2 <: AbstractBinding end
Redstone.is_output(::BadReads2) = true
Redstone.reads(::BadReads2) = (; v = get_output("s", :nope))
attempt("L11a-170", () -> begin
    sim = initd()
    (kinds(errof(() -> attach!(sim, Pad("r"), BadReads()))),
     kinds(errof(() -> attach!(sim, Pad("r2"), BadReads2()))))
end)

struct OutClaims <: AbstractBinding end
Redstone.is_output(::OutClaims) = true
Redstone.reads(::OutClaims) = (; v = get_input(:a))
Redstone.claims(::OutClaims) = ["a"]
attempt("L11a-105", () -> let e = errof(() -> attach!(initd(), Pad("o"), OutClaims()))
    (kinds(e), dg(e)[1].reason) end)
# 124: a crash is DeviceCrash; an interrupt-free unblock!-provoked throw is not
mutable struct Crash2 <: AbstractDevice end
Redstone.loop(::Crash2, h) = error("boom")
attempt("L11a-124", () -> begin
    sim = initd(); attach!(sim, Crash2(), NoClaim()); run!(sim; t_end = 0.2)
    [w.who => w.totals for w in latest(sim).status.writers]
end)

mutable struct BadInit2 <: AbstractDevice; log::Vector{Symbol}; end
Redstone.init!(d::BadInit2) = (push!(d.log, :init); error("no hardware"))
Redstone.shutdown!(d::BadInit2) = (push!(d.log, :shutdown); nothing)
Redstone.loop(d::BadInit2, h) = (push!(d.log, :loop); nothing)
# 175: a throwing init! gets shutdown!, DeviceCrash, no loop
attempt("L11a-175", () -> begin
    sim = initd(); d = BadInit2(Symbol[]); attach!(sim, d, NoClaim()); run!(sim; t_end = 0.2)
    (d.log, [w.who => (w.totals, w.task_state) for w in latest(sim).status.writers])
end)

# 131/134/136: lifecycle gates
attempt("L11a-131", () -> begin
    sim = Simulation(two(); Δt_frame = 1//10)
    e = errof(() -> checkpoint(sim)); d = dg(e)[1]
    (typeof(d), d.status, d.legal, typeof(checkpoint(initd())))
end)
attempt("L11a-134", () -> begin
    sim = Simulation(fed(Pendulum()); Δt_frame = 1//10)
    prob = TrimProblem(guess = (u = 0.0,), lower = (u = -Inf,), upper = (u = Inf,),
        condition = d -> combine(at("c", condition(Pendulum(); θ = 0.5)), set(u = (in = d.u,))),
        reads = reads(ω̇ = get_deriv("c", :ω)), residuals = (r, d) -> (torque = r.ω̇,),
        tolerances = (torque = 1e-9,))
    before = lifecycle(sim)
    rep = trim!(sim, prob; baseline = set(u = (in = 0.0,)))
    (before, rep.converged, lifecycle(sim))
end)
attempt("L11a-136", () -> begin
    sim = Simulation(two(); Δt_frame = 1//10)
    e = errof(() -> linearize(sim, taps(u = (a = get_input(:a),), y = (s = get_output("s", :y),))))
    d = dg(e)[1]; (typeof(d), d.op, d.status, d.legal)
end)

# 150/153/155: the header is a Checkpoint carrying the Deployment; a Δt_base mismatch is CheckpointMismatch :deployment
attempt("L11a-150", () -> begin
    sim = initd(); h = trace(sim).header
    (typeof(h), fieldnames(typeof(h)), fieldnames(typeof(h.state)), fieldnames(Redstone.Deployment))
end)
attempt("L11a-155", () -> begin
    sim = initd(); stage!(sim, "a" => 1.0); step!(sim; frames = 2); trc = trace(sim)
    target = Simulation(two(); Δt_frame = 1//10, Δt_base = 1//20)
    e = errof(() -> replay!(target, trc))
    e isa DiagnosticError ? [(typeof(d), d.what, d.name, d.expected, d.found) for d in dg(e)] : e
end)
end

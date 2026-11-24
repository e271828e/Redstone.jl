# C2 probe: Appendix C, deployment, periphery, services and runtime kinds.
using Test, StaticArrays, LinearAlgebra, ForwardDiff
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
include(joinpath(W, "test/imports.jl"))
include(joinpath(W, "test/fixtures.jl"))
import Redstone: taps, reads, get_state, get_input, get_output, get_face, series, at, set, combine, override, init!, step!, run!, attach!, detach!, trace, checkpoint, severity, message, Taps

function T(label, f)
    try
        r = f()
        println("probe ", label, " => returned ", typeof(r))
        return r
    catch err
        if err isa DiagnosticError
            c = err.carried
            if c isa Vector
                println("probe ", label, " => COLLECTED ", [(typeof(d).name.name, (hasproperty(d, :reason) ? d.reason : nothing)) for d in c])
            else
                println("probe ", label, " => FAILFAST ", typeof(c).name.name, " reason=", hasproperty(c, :reason) ? c.reason : nothing)
            end
            return err
        else
            println("probe ", label, " => OTHER ", typeof(err), " ", sprint(showerror, err)[1:min(end,120)])
            return err
        end
    end
end
fields(d) = NamedTuple{fieldnames(typeof(d))}(Tuple(getfield(d, f) for f in fieldnames(typeof(d))))

g = Group((; plant = Plant()); input_wires = ("u" => "plant/u",))
b = Redstone.build(g)

println("--- DeploymentInvalid")
e = T("dep missing frame", () -> Deployment(b)); println(map(d -> (d.parameter, d.reason), e.carried))
e = T("dep float frame", () -> Deployment(b; Δt_frame = 0.01)); println(map(d -> (d.parameter, d.reason), e.carried))
e = T("dep str frame", () -> Deployment(b; Δt_frame = "a")); println(map(d -> (d.parameter, d.reason, d.value), e.carried))
e = T("dep neg frame", () -> Deployment(b; Δt_frame = -1//100)); println(map(d -> (d.parameter, d.reason), e.carried))
e = T("dep BS3 no h_min", () -> Deployment(b; Δt_frame = 1//100, algorithm = BS3(1e-6, 1e-9))); println(map(d -> (d.parameter, d.reason), e.carried))
e = T("dep h_min above half", () -> Deployment(b; Δt_frame = 1//100, h_max = 1//200, h_min = 1//300, algorithm = BS3(1e-6, 1e-9))); println(map(d -> (d.parameter, d.reason, d.value, d.related), e.carried))
e = T("dep h_min nonpos", () -> Deployment(b; Δt_frame = 1//100, h_min = 0, algorithm = BS3(1e-6, 1e-9))); println(map(d -> (d.parameter, d.reason, d.related), e.carried))
e = T("dep all params", () -> Deployment(b; Δt_frame = 1//100, algorithm = 3, firing_budget = 0, localization_tol = -1.0, localization_budget = 0, attempt_budget = 0)); println(map(d -> (d.parameter, d.reason), e.carried))
e = T("dep derive no constraint", () -> Deployment(b; Δt_frame = 1//100, Δt_base = :derive)); println(map(d -> (d.parameter, d.reason, d.grid), e.carried))
e = T("dep h_max float", () -> Deployment(b; Δt_frame = 1//100, h_max = 0.001)); println(map(d -> (d.parameter, d.reason), e.carried))

# discrete unanchored + derive
gd = Group((; c = DiscreteAccumulator(1.0)); input_wires = ("u" => "c/e",))
println(fieldnames(DiscreteAccumulator), " ", u_types(DiscreteAccumulator(1.0)))
bd = try Redstone.build(gd) catch err; println("build gd failed: ", sprint(showerror, err)[1:200]); nothing end
if bd !== nothing
    e = T("dep unanchored", () -> Deployment(bd; Δt_frame = 1//100, Δt_base = :derive))
    e isa DiagnosticError && println(map(d -> (d.parameter, d.reason, d.paths, d.grid === nothing), e.carried))
end

# anchored loops
struct AbsLoop <: AbstractComponent
    plant::Plant
    ctl::DiscreteAccumulator
    sum::Sum
    rate::Absolute
end
local_wires(::AbsLoop) = ("ctl/u" => "plant/u", "sum/e" => "ctl/e", "plant/y" => "sum/b")
input_wires(::AbsLoop) = ("ref" => "sum/a",)
output_wires(::AbsLoop) = ("plant/y" => "y", "ctl/u" => "cmd", "plant/power" => "power")
sample_times(l::AbsLoop) = (ctl = l.rate,)
sl(rate) = Group((; loop = AbsLoop(Plant(), DiscreteAccumulator(3.0), Sum(), rate)); input_wires = ("ref" => "loop/ref",))
ba = Redstone.build(sl(Absolute(1//2)))
e = T("dep anchor_period", () -> Deployment(ba; Δt_frame = 1//100, Δt_base = 1//3)); println(map(d -> (d.parameter, d.reason, d.scope, d.key, d.grid === nothing), e.carried))
bo = Redstone.build(sl(Absolute(1//50, 1//500)))
e = T("dep anchor_offset", () -> Deployment(bo; Δt_frame = 1//100, Δt_base = 1//50)); println(map(d -> (d.parameter, d.reason, d.scope, d.key, d.grid === nothing), e.carried))
dep = Deployment(bo; Δt_frame = 1//100, Δt_base = :derive)
println("GridUtilization: ", [fields(w) for w in dep.warnings if w isa GridUtilization])
println("severity GU ", severity(GridUtilization(Δt_base = 1//2, utilization = 2, fastest = "x", grid = Redstone.GridReport(Redstone.GridEntry[], nothing, []))))
# Δt_base lattice :range
e = T("dep Δt_base too fine", () -> Deployment(ba; Δt_frame = 1//2^40, Δt_base = 1//3^30)); e isa DiagnosticError && println(map(d -> (d.parameter, d.reason, d.value, d.related), e.carried))
e = T("dep Δt_base too fine2", () -> Deployment(b; Δt_frame = 1//2^40, Δt_base = 1//(2^62))); e isa DiagnosticError && println(map(d -> (d.parameter, d.reason, d.value, d.related), e.carried))
e = T("dep h_max too fine", () -> Deployment(b; Δt_frame = 1, h_max = 1//2^62)); e isa DiagnosticError && println(map(d -> (d.parameter, d.reason, d.value, d.related), e.carried))
e = T("dep bound mixed", () -> Deployment(b; Δt_frame = 1//100, h_max = -1)); println(map(d -> (d.parameter, d.reason), e.carried))

println("--- ArgumentInvalid declaration doors")
fa(f) = (e = T("", f); e isa DiagnosticError ? fields(e.carried isa Vector ? e.carried[1] : e.carried) : nothing)
println(fa(() -> Absolute(0.5)))
println(fa(() -> Absolute(1//2, 0.1)))
println(fa(() -> Absolute(1//big(2)^70)))
println(fa(() -> Absolute(Inf)))
println(fa(() -> Relative(1.5)))
println(fa(() -> Relative(1//2)))
println(fa(() -> Relative(big(2)^80)))
println(fa(() -> BS3(-1.0, 1.0)))
e = T("BS3 both", () -> BS3(-1.0, Inf)); println(map(d -> (d.call, d.argument, d.reason), e.carried))

dep0 = Deployment(b; Δt_frame = 1//100)
println(fa(() -> Model(dep0, Float32)))
println(fa(() -> Model(dep0, ForwardDiff.Dual{Nothing,Float64,1})))
println(fa(() -> Model(dep0; chunk_size = 0)))
m1 = Model(dep0)
sim = Simulation(m1)
println(fa(() -> Simulation(m1)))
e = T("Simulation bad kw + claimed", () -> Simulation(m1; join_timeout = -1)); println(map(d -> (d.call, d.argument, d.reason), e.carried))
println(fa(() -> init!(m1, set(u = (u = 0.0,)))))   # claimed
m2 = Model(dep0); init!(m2, set(u = (u = 0.0,)))
println(fa(() -> Simulation(m2)))   # not_built

println("--- lifecycle")
sim = Simulation(dep0)
println(fa(() -> run!(sim; t_end = 0.1)))
println(fa(() -> step!(sim)))
println(fa(() -> trace(sim)))
println(fa(() -> checkpoint(sim)))
println(fa(() -> Redstone.logged(sim)))
init!(sim, set(u = (u = 0.0,)); trace = false)
println(fa(() -> trace(sim)))
println(fa(() -> init!(sim, set(); trace = 3, log_every = 0)))
e = T("init! bad recording", () -> init!(sim, set(u = (u = 0.0,)); trace = 3, log_every = 0)); println(map(d -> (d.call, d.argument, d.reason), e.carried))
e = T("StopRequestInvalid", () -> run!(sim; t_end = 0.1, ignore_stop_requests = ["nope", "nada"])); println(map(d -> fields(d), e.carried))
println(fa(() -> run!(sim; ignore_stop_requests = "nope")))
println(fa(() -> step!(sim; frames = 1, t_plus = 1)))
println(fa(() -> Redstone.frame!(Model(dep0), typemax(Int))))

println("--- attach")
sim = Simulation(dep0)
d1 = Pad("a")
println(fa(() -> attach!(sim, d1, Enumerated("nonexistent"))))
h = attach!(sim, d1, Enumerated("u"))
println(fa(() -> attach!(sim, d1, Enumerated("u"))))
e = T("ClaimConflict", () -> attach!(sim, Pad("b"), Enumerated("u"))); println(map(fields, e.carried))
println(fa(() -> detach!(sim, Pad("zz"))))
println(fa(() -> attach!(sim, Pad("c"), Greedy())))   # claimed all? 
sim2 = Simulation(dep0)
attach!(sim2, Pad("x"), Enumerated("u"))
println("greedy complement empty:")
hh = attach!(sim2, Pad("g"), Greedy())
println(fa(() -> detach!(sim2, d1)))
println(fa(() -> attach!(sim2, Pad("h"), Enumerated("u", "u"))))

struct BadGreedy <: AbstractBinding end
Redstone.is_greedy(::BadGreedy) = true
struct Neither <: AbstractBinding end
struct ClaimsNoInput <: AbstractBinding end
Redstone.claims(::ClaimsNoInput) = ["u"]
struct NoClaims <: AbstractBinding end
Redstone.is_input(::NoClaims) = true
struct GreedyClaims <: AbstractBinding end
Redstone.is_input(::GreedyClaims) = true; Redstone.is_greedy(::GreedyClaims) = true; Redstone.claims(::GreedyClaims) = ["u"]
struct ReadsBad <: AbstractBinding end
Redstone.is_output(::ReadsBad) = true; Redstone.reads(::ReadsBad) = (a = 1,)
struct ReadsNT <: AbstractBinding end
Redstone.is_output(::ReadsNT) = true; Redstone.reads(::ReadsNT) = [1]
struct ReadsNoOut <: AbstractBinding end
Redstone.reads(::ReadsNoOut) = (;)
struct NoOutReads <: AbstractBinding end
Redstone.is_output(::NoOutReads) = true
for B in (BadGreedy, Neither, ClaimsNoInput, NoClaims, GreedyClaims, ReadsBad, ReadsNT, ReadsNoOut, NoOutReads)
    s = Simulation(dep0)
    println(B, " ", fa(() -> attach!(s, Pad("p"), B())))
end
struct NoLoop <: AbstractDevice end
println(fa(() -> attach!(Simulation(dep0), NoLoop(), NoClaim())))
println(fa(() -> Redstone.stage!(h, "u" => 1.0)))
detach!(sim, d1)
println(fa(() -> Redstone.stage!(h, "u" => 1.0)))

println("--- conditions / reads")
println(fa(() -> set(u = nothing)))
println(fa(() -> at("", set())))
println(fa(() -> combine(set(), 1)))
println(fa(() -> combine(set(), 1)))
println(fa(() -> override(set(), 1)))
println(fa(() -> at("a", 1)))
sim = Simulation(dep0)
e = T("Uninit", () -> init!(sim, set()))
println(typeof(e))
e = T("Dup", () -> init!(sim, combine(set(u = (u = 1.0,)), set(u = (u = 2.0,))))); println(typeof(e))
e = T("cond bad", () -> init!(sim, set(x = (nope = 1.0,), u = (u = "s",), s = (a = 1,)))); e isa DiagnosticError && println(map(fields, e.carried))
println(fa(() -> reads(a = 1)))
println(fa(() -> at("", reads(a = get_state("plant", :q)))))
println(fa(() -> reads(1)))
println(fa(() -> Redstone.taps(x = 1)))
init!(sim, set(u = (u = 0.0,)))
println(fa(() -> series(sim, 1)))
println(fa(() -> series(sim; t = get_state("plant", :q))))
e = T("ReadResolution", () -> series(sim; a = get_state("plant", :nope), b = get_state("nope", :q), c = get_input("zz"))); e isa DiagnosticError && println(map(fields, e.carried))
println(fa(() -> Redstone.linearize(sim, 1)))
println(fa(() -> Redstone.linearize(sim, taps(); width = 0)))
println(fa(() -> Redstone.linearize(sim, taps(); t0 = 1)))
println(fa(() -> Redstone.trim!(sim, 1; baseline = set())))
println(fa(() -> Redstone.linearize(sim, taps(); about = set(u=(u=0.0,)), t0 = 0.1)))
println(fa(() -> init!(sim, set(u = (u = 0.0,)); t0 = 0.1)))
println(fa(() -> init!(sim, set(u = (u = 0.0,)); t0 = π)))
e = T("TapResolution", () -> Redstone.linearize(sim, taps(x = (a = get_output("plant", :y),), u = (v = get_input("u"), v2 = get_input("u")), y = (q = get_state("plant", :q),)))); e isa DiagnosticError && println(map(d -> (typeof(d).name.name, d.reason), e.carried))
e = T("TapResolution2", () -> Redstone.linearize(sim, taps(x = (a = get_state("plant", :q),), u = (v = get_input("u"),), y = (q = get_output("plant", :y),)))); 

println("--- severity")
for K in (MissingInit, ServiceLifecycle, StopRequestInvalid, DeploymentInvalid, AttachUnknownFace, AlreadyAttached, ClaimConflict, EmptyGreedyClaim, BindingContractMismatch, DeviceContractMismatch, ConditionResolution, DuplicateConditionLeaf, ConditionNodeMisuse, ReadResolution, UninitializedInputs, TapResolution, TrimProblemInvalid, TrimCommitEvents, TrimCommitResiduals, TrimCommitChecks, ConditionShapeDrift, GridUtilization, CheckpointMismatch, CheckpointMidFrame, ReplaySchemaMismatch, ReplayUnknownFace, ArgumentInvalid, ReadSetMisuse, NotAttached, NonfiniteState, ChatteringBudget, FiringBudget, StepFloor, DebtReanchor, ClaimedFaceEntry, OutOfClaimEntry, ThreadBudget, DeviceJoinTimeout, DeviceCrash, ReplayDiscardedStaging, MalformedDatum, EntryTypeMismatch, UnboundedRun)
    println(K, " ", hasmethod(severity, Tuple{K}) ? "has-method" : "")
end
println("severity by sample: ", severity(NotAttached(device = "x")), severity(StepFloor(1.0,1.0,1.0,1,:budget)), severity(TrimCommitEvents(events = [])))
println("KINDS ", [k.name.name for k in KINDS])

println("--- second batch: lattices, series, checkpoint")
for (lbl, kw) in (("unit too fine", (; Δt_frame = 1//2^40, Δt_base = 1//3^30)),
                  ("unit fine b", (; Δt_frame = 1//10^9, Δt_base = 1//(10^9 + 7))),
                  ("hmax fine", (; Δt_frame = 1, h_max = 1//(2^62 - 1))),
                  ("hmax fine2", (; Δt_frame = 1//10^9, h_max = 1//(10^9 * 10^9))))
    e = T(lbl, () -> Deployment(b; kw...))
    e isa DiagnosticError && println(map(d -> (d.parameter, d.reason, d.value, d.related), e.carried))
end
sim = Simulation(dep0)
init!(sim, set(u = (u = 0.0,)))
println(methods(series))

println("--- third batch")
sim = Simulation(dep0)
init!(sim, set(u = (u = 0.0,)))
println(fa(() -> series(sim, reads(t = get_state("plant", :q)))))
e = T("ReadResolution", () -> series(sim, reads(a = get_state("plant", :nope), b = get_state("nope", :q), c = get_input("zz"), d = get_state("plant", :q, "[5]"), e2 = get_face("zz"), f = get_output("plant", :y, ".x")))); e isa DiagnosticError && println(map(d -> (typeof(d).name.name, d.reason, d.declares, d.declared, d.candidates, d.step), e.carried))
println(fa(() -> series(sim, 5)))
# mid-frame checkpoint: step to t* is not simple; stop mid-frame via t_end?
run!(sim; t_end = 0.055)
println("status ", Redstone.lifecycle(sim), " t=", sim.model.exec.clock.t)
println(fa(() -> checkpoint(sim)))
println(fa(() -> Redstone.overlay!(sim, set(u = (u = 1.0,)))))
println(fa(() -> Redstone.linearize(sim, taps(x = (q = get_state("plant", :q, "[1]"),)))))
# sim.model checkpoint mid
cp = checkpoint(Simulation(dep0) |> (s -> (init!(s, set(u = (u = 0.0,))); s)))
println(typeof(cp))
sim3 = Simulation(Deployment(b; Δt_frame = 1//50)); init!(sim3, set(u=(u=0.0,)))
println(fa(() -> Redstone.restore!(sim3, cp)))
# replay mismatch
sim4 = Simulation(dep0); init!(sim4, set(u = (u = 0.0,)); trace = true); run!(sim4; t_end = 0.05)
trc = trace(sim4)
sim5 = Simulation(Deployment(b; Δt_frame = 1//50, Δt_base = 1//100))
println(fa(() -> Redstone.replay!(sim5, trc)))
e = T("replay mismatch", () -> Redstone.replay!(sim5, trc)); e isa DiagnosticError && println(map(d -> (d.what, d.name, d.expected, d.found), e.carried))
sim6 = Simulation(Deployment(b; Δt_frame = 1//100, algorithm = Heun()))
e = T("replay alg", () -> Redstone.replay!(sim6, trc)); e isa DiagnosticError && println(map(d -> (d.what, d.name, d.expected, d.found), e.carried))

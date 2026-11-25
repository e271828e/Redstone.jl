# SB probe: Appendix B, API synopsis. Run from the pinned worktree.
using Test, BenchmarkTools, Redstone, StaticArrays, LinearAlgebra, ForwardDiff, ComponentArrays
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
include(joinpath(W, "test", "imports.jl"))
include(joinpath(W, "test", "fixtures.jl"))
include(joinpath(W, "test", "utils.jl"))
import Redstone: Library

macro P(ex)
    quote
        local v = try
            $(esc(ex))
        catch err
            ("EXC", _err(err))
        end
        println("probe:", $(__source__.line), " => ", repr(v)[1:min(end, 400)])
        v
    end
end
function _err(e)
    e isa DiagnosticError || return typeof(e)
    c = e.carried
    c isa AbstractVector ? Tuple(_d(d) for d in c) : _d(c)
end
kind(f) = try f(); :nothrown catch e; e isa DiagnosticError ? nameof(typeof(diagnostic(e))) : typeof(e) end
function _d(d)
    (nameof(typeof(d)), hasproperty(d, :reason) ? d.reason : nothing, hasproperty(d, :parameter) ? d.parameter : nothing)
end
function rsn(f)
    try f(); :nothrown catch e
        if e isa DiagnosticError
            c = e.carried
            c isa AbstractVector ? Tuple(_d(d) for d in c) : _d(c)
        else typeof(e) end
    end
end

println("## exports")
@P names(Redstone)
@P isdefined(Redstone, :Library)

println("## Group")
g = fed(Gain(2.0), "e")
@P typeof(Group((; c = Gain(1.0))))
g2 = Group(g; sample_times = (;))
@P g2.children === g.children
g3 = Group(g; input_wires = ("a" => "c/e",))
@P (input_wires(g3), g3.children === g.children, g3.local_wires)
@P Group((; c = Gain(1.0)); sample_times = (c = Relative(2),)).sample_times

println("## Relative / Absolute")
@P Relative(3)
@P Relative(3, 0) == Relative(3)
@P rsn(() -> Relative(1//2))
@P rsn(() -> Relative(1, 1//2))
@P Absolute(1//10)
@P Absolute(1//10, 0)
@P Absolute(2)
@P rsn(() -> Absolute(0.1))
@P stop_reason(Gain(1.0))

println("## bundle table")
@P LEGAL_BUNDLE

println("## build")
root = feedback_model()
b = build(root)
@P fieldnames(Build)
@P keys(b.activations)
b2 = build(root; activations = (Float64, ProbeDual))
@P keys(b2.activations)
@P ProbeDual
@P isconcretetype(ProbeDual)
@P resolve(root, "plant") isa AbstractComponent
@P input_faces(root)
@P output_faces(root)
@P input_faces(BareAccumulator())
@P output_faces(BareAccumulator())
@P input_faces(Plant())
@P typeof(input_faces(Plant()))
@P resolve(root, "plant/x")
@P rsn(() -> resolve(root, ""))
@P rsn(() -> resolve(root, "nosuch"))
# container
kg = KeyedGains
@P rsn(() -> input_passthrough(root, "plant"))
@P input_passthrough(root, "plant")
@P input_passthrough(root, "plant"; prefix = "", only = ("u",))
@P output_passthrough(root, "plant"; sep = "_")
@P output_passthrough(root, "plant"; except = ("power",), prefix = "p")
@P rsn(() -> input_passthrough(root, "plant"; only = ("u",), except = ("u",)))
@P rsn(() -> input_passthrough(root, "plant"; only = ("zz",)))
@P input_passthrough(root, "plant"; select = n -> n == "u")
@P input_passthrough(root, "plant"; prefix="x", sep="::")
# empty selection warning
let gg = Group((; p = Plant()); input_wires = g -> input_passthrough(g, "p"; except = ("u",)))
    bb = try build(gg) catch e; e end
    @P (bb isa Build ? [nameof(typeof(w)) for w in bb.warnings] : bb)
end

println("## descriptor")
@P typeof(descriptor(b))
@P keys(descriptor(b))
dep = Deployment(b; Δt_frame = 1//10)
@P typeof(descriptor(dep))
@P keys(descriptor(dep))
@P (try; d = descriptor(dep); [k for k in keys(d)]; catch e; e; end)
errb = try build(feedback_model(feedback_port = "power")) catch e; e end
@P typeof(errb)
@P typeof(descriptor(errb))
@P keys(descriptor(errb))
let d = descriptor(errb)
    @P d
end
# a failure past the structure step
@P keys(descriptor(try build(Group((; c = Exploder()))) catch e; e end))

println("## Deployment")
@P Deployment(b; Δt_frame = 1//10).h_max
@P Deployment(b; Δt_frame = 1//10, h_max = 1//5).h_max
@P Deployment(b; Δt_frame = 1//10, h_max = 1//20).h_max
@P Deployment(b; Δt_frame = 1//10).Δt_base
@P Deployment(b; Δt_frame = 1//10).algorithm
@P (let d = Deployment(b; Δt_frame = 1//10); (d.firing_budget, d.localization_tol, d.localization_budget, d.attempt_budget, d.h_min) end)
@P typeof(Deployment(b; Δt_frame = 1//10).Δt_frame)
@P Deployment(b; Δt_frame = Int128(1)).Δt_frame
@P Deployment(b; Δt_frame = Rational{Int8}(1,2)).Δt_frame
@P rsn(() -> Deployment(b))
@P rsn(() -> Deployment(b; Δt_frame = 0.1))
@P rsn(() -> Deployment(b; Δt_frame = 1//10, Δt_base = 0))
@P rsn(() -> Deployment(b; Δt_frame = 1//10, Δt_base = 1//3))
@P Deployment(b; Δt_frame = 1//10, Δt_base = 1//3).Δt_base
@P Deployment(b; Δt_frame = 1//10, Δt_base = 1//7, h_max = 1//3).Δt_base
@P rsn(() -> Deployment(b; Δt_frame = 1//10, h_max = 0))
@P rsn(() -> Deployment(b; Δt_frame = 1//10, algorithm = BS3()))
@P rsn(() -> Deployment(b; Δt_frame = 1//10, algorithm = BS3(), h_min = 1//10))
@P rsn(() -> Deployment(b; Δt_frame = 1//10, algorithm = BS3(), h_min = 1//20))
@P rsn(() -> Deployment(b; Δt_frame = 1//10, algorithm = BS3(), h_min = 1//21))
@P rsn(() -> Deployment(b; Δt_frame = 1//10, h_min = 1//10))
@P Deployment(b; Δt_frame = 1//10, h_min = 1//100).h_min
@P rsn(() -> Deployment(b; Δt_frame = 1//10, attempt_budget = 0))
@P rsn(() -> Deployment(b; Δt_frame = 1//10, firing_budget = 0))
@P rsn(() -> Deployment(b; Δt_frame = 1//10, localization_budget = 0))
@P rsn(() -> Deployment(b; Δt_frame = 1//10, localization_tol = 0))
@P rsn(() -> Deployment(b; Δt_frame = 1//10, algorithm = :rk4))
@P rsn(() -> Deployment(b; Δt_frame = 1//10, Δt_base = :derive))
@P Deployment(b; Δt_frame = 1//10).Δt_base == 1//10
@P (RK4(), Heun(), BS3(), BS3(reltol=1e-4, abstol=1e-8))
@P (RK4() == RK4(), fieldnames(typeof(RK4())))
@P rsn(() -> BS3(reltol = 0))
@P rsn(() -> BS3(abstol = Inf))
@P rsn(() -> BS3(reltol = NaN))
@P typeof(Schedule), fieldnames(Schedule), fieldnames(ScheduleEntry)
@P Deployment(b; Δt_frame = 1//10).warnings

println("## Model")
@P typeof(Model(dep))
@P typeof(Model(dep, Float64))
@P rsn(() -> Model(dep; chunk_size = 0))
@P rsn(() -> Model(dep; chunk_size = 2.0))
@P typeof(Model(dep; chunk_size = 1))
@P typeof(Model(b; Δt_frame = 1//10))
@P typeof(Model(root; Δt_frame = 1//10))
@P rsn(() -> Model(b))
@P rsn(() -> Model(root; chunk_size = 0, Δt_frame = 1//10))
@P typeof(Model(dep, ProbeDual))
m = Model(dep)
@P (m.status, warnings(m))
@P rsn(() -> checkpoint(m))
@P rsn(() -> frame!(m, 1))
@P m.status
c0 = set(u = (ref = 1.0,))
@P init!(m, c0)
@P init!(m, c0; t0 = 0, hooks = NoHooks())
@P init!(m)  # missing root input
@P rsn(() -> init!(m))
@P m.status
@P rsn(() -> init!(m, c0))
@P frame!(m, 1)
@P frame!(m, 2, NoHooks())
@P typeof(frame!(m, 3))
@P rsn(() -> frame!(m, typemax(Int)))
@P rsn(() -> frame!(m, 10^15))
@P frame_top!(NoHooks()), settled!(NoHooks())
@P supertype(NoHooks)
@P (port(m, "plant", :y), port(m, "plant", :power), port(m, "", :ref), port(m, "", :y))
@P rsn(() -> port(m, "plant"))
@P rsn(() -> port(m, "nosuch", :y))
@P rsn(() -> port(m, "plant", :nosuch))
@P rsn(() -> port(m, "", ))
@P state(m, "plant")
@P modes(m, "plant")
@P state(m, "")
@P state(m, "ctl")
@P modes(m, "ctl")
@P rsn(() -> state(m, "nosuch"))
@P rsn(() -> modes(m, "nosuch"))
@P state(m, "sum")
@P (typeof(checkpoint(m)), checkpoint(m).t)
cp = checkpoint(m)
@P fieldnames(typeof(cp))
@P restore!(m, cp)
@P restore!(m, cp; hooks = NoHooks())
@P m.status
@P overlay!(m, set(x = (;)))
@P overlay!(m; hooks = NoHooks())
@P overlay!(m, at("plant", set(x = (q = SVector(1.0, 0.0),))))
@P state(m, "plant")
@P rsn(() -> overlay!(m, 3))
# checkpoint mid-frame
# fresh model restore built
m2 = Model(dep)
@P restore!(m2, cp)
@P m2.status
dep2 = Deployment(b; Δt_frame = 1//5)
m3 = Model(dep2)
@P rsn(() -> restore!(m3, cp))
@P rsn(() -> restore!(Model(dep, ProbeDual), cp))
# claim
mc = Model(dep)
sim = Simulation(mc)
@P mc.claimed
@P rsn(() -> init!(mc, c0))
@P rsn(() -> frame!(mc, 1))
@P rsn(() -> restore!(mc, cp))
@P rsn(() -> overlay!(mc))
@P rsn(() -> Simulation(mc))
@P rsn(() -> Simulation(Model(dep); join_timeout = 0))
let mm = Model(dep); init!(mm, c0); @P rsn(() -> Simulation(mm)) end
@P rsn(() -> Simulation(Model(dep, ProbeDual)))
println("## Model-level trim/linearize")
pend() = Group((; c = Pendulum()); input_wires = ("in" => "c/u",), output_wires = ("c/θ" => "θ",))
pm = Model(Deployment(build(pend()); Δt_frame = 1//10))
prob = TrimProblem(guess = (u = 0.0,), lower = (u = -Inf,), upper = (u = Inf,),
    condition = d -> combine(at("c", condition(Pendulum(); θ = 0.5)), set(u = (in = d.u,))),
    reads = reads(ω̇ = get_deriv("c", :ω)), residuals = (r, d) -> (torque = r.ω̇,),
    tolerances = (torque = 1e-9,))
@P fieldnames(TrimProblem)
@P length(fieldnames(TrimProblem))
@P rsn(() -> trim!(pm, prob))
rep = trim!(pm, prob; baseline = set(u = (in = 0.0,)))
@P typeof(rep)
@P pm.status
@P rep.converged
@P fieldnames(TrimReport)
@P backend = LevenbergMarquardt()
@P (LevenbergMarquardt().maxiter, LevenbergMarquardt().λ₀)
@P rsn(() -> LevenbergMarquardt(λ₀ = 0))
@P hasmethod(solve, Tuple{LevenbergMarquardt, Function, Vector{Float64}, Vector{Float64}, Vector{Float64}, Vector{Float64}})
let r = solve(LevenbergMarquardt(), (r, J, d) -> (r[1] = d[1] - 2; J[1,1] = 1.0), [0.0], [-Inf], [Inf], [1e-9])
    @P r
end
lt = taps(x = (θ = get_state("c", :θ),), u = (in = get_input(:in),), y = (θ = get_face(:θ),))
@P typeof(linearize(pm, lt))
@P typeof(lt)
@P rsn(() -> linearize(pm, lt; width = 0))
@P rsn(() -> linearize(pm, lt; t0 = 0))
@P rsn(() -> linearize(Model(dep), lt))
@P fieldnames(Linearization)
lin = @P linearize(pm, lt)
@P typeof(labeled(lin).A)
@P typeof(labeled(linearize(pm, taps(x = (θ = get_state("c", :θ),)))).B)
@P size(labeled(linearize(pm, taps(x = (θ = get_state("c", :θ),)))).B)
@P typeof(labeled(linearize(pm, taps(x = (θ = get_state("c", :θ),)))).B)
@P typeof(labeled(linearize(pm, taps(x = (θ = get_state("c", :θ),)))).D)
@P rsn(() -> trim!(pm, 3; baseline = set()))
@P rsn(() -> trim!(Model(Deployment(build(pend()); Δt_frame = 1//10), ProbeDual), prob; baseline = set()))
@P at("c", prob) isa TrimProblem
@P at("c", reads(a = get_state("c"))) isa Reads
@P at("c", lt) isa Taps
@P rsn(() -> at("", set()))
@P rsn(() -> at("a", 3))
@P rsn(() -> combine(set(), (; a = 1)))
@P typeof(override(set(), set()))
@P typeof(combine(set(), set()))
@P (Fragment, Scoped, Combined, Redstone.Override, ConditionNode)
@P rsn(() -> set(x = nothing))
@P set(x = (a = 1,), u = (b = 2,)) isa Fragment
@P rsn(() -> init!(Model(dep), combine(set(u = (ref = 1,)), set(u = (ref = 2,)))))
@P hasmethod(condition, Tuple{Pendulum})
@P condition(Pendulum(); θ = 1.0) isa Fragment
println("## taps, selectors")
@P get_state("c")
@P get_state("c", :θ)
@P get_deriv("c")
@P get_output("c")
@P get_input()
@P get_face()
@P get_input(:in)
@P rsn(() -> taps(x = 3))
@P typeof(taps())
@P typeof(reads(a = get_state("c", :θ)))
@P rsn(() -> reads(a = 3))
@P (GetState, GetDeriv, GetOutput, GetInput, GetFace, Taps, Reads)

println("## names exist")
for nm in (:StateEvent, :Pinned, :ConditionNodeMisuse, :UnknownFaceSelection, :EmptyFaceSelection, :DeploymentInvalid,
           :ArgumentInvalid, :StepFloor, :FiringBudget, :ServiceLifecycle, :CheckpointMidFrame, :CheckpointMismatch,
           :StepError, :PathResolution, :BindingContractMismatch, :EmptyGreedyClaim, :AlreadyAttached, :ClaimConflict,
           :DeviceCrash, :UnboundedRun, :StopPolicy, :StopFlag, :TerminationSource, :EndTimeReached, :ModelRequestedStop,
           :ControlRequestedStop, :LoopError, :TerminationRecord, :Trace, :Series, :Snapshot, :Run, :Diagnostic, :Checkpoint,
           :ModelState, :PortView, :WriterStatus, :MalformedDatum, :DeviceHandle, :AbstractDevice, :AbstractBinding,
           :TableBinding, :TransparentContainerUnknown, :TrimReport, :TrimProblem, :LevenbergMarquardt, :Linearization,
           :Taps, :Reads, :GetState, :GetDeriv, :GetOutput, :GetInput, :GetFace, :MissingInit, :ReadResolution,
           :DuplicateConditionLeaf, :ConditionResolution, :UninitializedInputs, :DeviceContractMismatch, :AttachUnknownFace,
           :CheckpointMismatch, :FrameHooks, :NoHooks, :Schedule, :Structure, :Outputs, :Events, :AbstractComponent, :Group,
           :Relative, :Absolute, :BS3, :RK4, :Heun, :Deployment, :Model, :Simulation, :Build, :ProbeDual, :loop, :StopRequestInvalid,
           :ReadSetMisuse, :TapResolution, :TrimProblemInvalid, :ReplaySchemaMismatch, :NotAttached, :CheckpointMismatch,
           :AbstractAlgorithm, :ComponentArrays)
    isdefined(Redstone, nm) || println("probe:UNDEF ", nm)
end
@P Redstone.LoopError <: Redstone.TerminationSource
@P [nameof(T) for T in (Redstone.EndTimeReached, Redstone.ModelRequestedStop, Redstone.ControlRequestedStop, Redstone.LoopError) if supertype(T) === Redstone.TerminationSource]
@P fieldnames(Redstone.TerminationRecord)
@P fieldnames(Redstone.Checkpoint)
@P fieldnames(Redstone.WriterStatus)
@P fieldnames(Redstone.PortView)
@P fieldnames(Redstone.MalformedDatum)
@P Redstone.MalformedDatum("cause")
@P hasmethod(Redstone.MalformedDatum, Tuple{Any})
@P fieldnames(Redstone.Trace)
@P supertype(Redstone.StopFlag)
@P Redstone.StateEvent

println("## Simulation forms")
@P typeof(Simulation(dep)) <: Simulation
@P typeof(Simulation(b; Δt_frame = 1//10)) <: Simulation
@P typeof(Simulation(root; Δt_frame = 1//10, chunk_size = 4, join_timeout = 2.0)) <: Simulation
@P rsn(() -> Simulation(Model(dep); chunk_size = 4))
@P rsn(() -> Simulation(dep; Δt_frame = 1//10))
@P rsn(() -> Simulation(root))
@P rsn(() -> Simulation(Model(dep); join_timeout = -1))
@P rsn(() -> Simulation(dep; join_timeout = "a"))
@P Simulation(Model(dep); join_timeout = 5).control.join_timeout
@P rsn(() -> Simulation(b; Δt_frame = 1//10, algorithm = BS3(), h_min = 1//30))

println("## sim lifecycle")
s = Simulation(dep)
@P lifecycle(s)
@P mode(s)
@P latest(s)
@P termination(s)
@P rsn(() -> trace(s))
@P rsn(() -> run!(s))
@P rsn(() -> step!(s))
@P rsn(() -> checkpoint(s))
@P warnings(s)
@P rsn(() -> init!(s, set(u = (ref = 1.0,)); log_every = 0))
@P rsn(() -> init!(s, set(u = (ref = 1.0,)); log_max = 0))
@P rsn(() -> init!(s, set(u = (ref = 1.0,)); trace = 1))
@P rsn(() -> init!(s, set(u = (ref = 1.0,)); log_max = Inf))
@P lifecycle(s)
@P closed(s.run)
@P s.run isa Run
@P rsn(() -> init!(s))
@P init!(s, set(u = (ref = 1.0,)); t0 = 0, trace = true, log = true, log_every = 1, log_max = 65536)
@P (lifecycle(s), mode(s))
@P rsn(() -> step!(s; frames = 1, t_plus = 1.0))
@P step!(s)
@P step!(s; frames = 3)
@P step!(s; t_plus = 0.25)
@P rsn(() -> step!(s; frames = 0))
@P rsn(() -> step!(s; t_plus = -1))
@P typeof(latest(s))
@P (port(s, "plant", :y), state(s, "plant"), modes(s, "plant"))
@P port(latest(s), "plant", :y)
@P port(latest(s), "plant", :y) == port(s, "plant", :y)
@P rsn(() -> port(latest(s), "plant"))
@P Redstone.warnings(s)
cps = checkpoint(s)
@P (typeof(cps), cps.frame, cps.boundary, cps.state.t)
@P fieldnames(typeof(cps))
@P stage!(s, "ref" => 2.0)
@P stage!(s, "ref" => 2.0, "nosuch" => 1.0)
@P step!(s)
@P length(logged(s))
@P typeof(logged(s))
rs = reads(y = get_output("plant", :y), p = get_output("plant", :power))
@P typeof(series(s, rs))
@P (let se = series(s, rs); (keys(se.columns), length(se.t), se.y === se.columns.y, propertynames(se)) end)
@P rsn(() -> series(s, reads(t = get_output("plant", :y))))
@P rsn(() -> series(s, reads(columns = get_output("plant", :y))))
@P rsn(() -> series(s, (; a = get_output("plant", :y))))
@P typeof(series(s, at("plant", reads(y = get_output("", :y)))))
@P rsn(() -> series(s, reads(a = get_output("nosuch", :y))))
@P typeof(trace(s))
@P rsn(() -> run!(s; t_end = 1.0))
@P (lifecycle(s), closed(s.run))
@P typeof(termination(s))
@P termination(s).source
@P rsn(() -> run!(s))
@P rsn(() -> stage!(s, "ref" => 1.0))
@P typeof(trace(s))
@P rsn(() -> trim!(s, prob; baseline = set()))
# restore! the checkpoint
@P restore!(s, cps; log_every = 2)
@P (lifecycle(s), mode(s), s.run.boundary)
@P restore!(s, cps; trace = false)
@P rsn(() -> trace(s))
@P restore!(s, cps)
@P rsn(() -> restore!(s, cps; log_max = 0))
@P overlay!(s)
@P overlay!(s, at("plant", set(x = (q = SVector(1.0, 0.0),))); trace = true, log = true, log_every = 1, log_max = 65536)
@P lifecycle(s)
@P step!(s)
@P rsn(() -> checkpoint(Model(dep)))
m5 = Model(dep); init!(m5, set(u = (ref = 1.0,))); frame!(m5, 1)
ms = checkpoint(m5)
@P restore!(s, ms)
@P (lifecycle(s), s.run.boundary, s.run.frame)
@P rsn(() -> restore!(s, checkpoint(Model(dep2); )))
@P rsn(() -> restore!(s, checkpoint(Model(dep, ProbeDual))))
@P typeof(phase_bodies(s)), typeof(phase_bodies(Model(dep)))
@P keys(phase_bodies(s))
@P phase_bodies(s) === phase_bodies(s.model)
println("## control plane")
@P (paused(s), pause!(s), paused(s), resume!(s), paused(s))
@P (pace(s), margin(s))
@P (pace!(s, 2.0), pace(s), margin!(s, 0.01), margin(s))
@P rsn(() -> pace!(s, -1))
@P rsn(() -> margin!(s, -1))
@P pace!(s, Inf)
@P margin!(s, 0.002)
@P stop!(s)
@P rsn(() -> run!(s; pace = 0))
@P rsn(() -> run!(s; margin = -1))
@P rsn(() -> run!(s; t_end = 0.5, ignore_stop_requests = (:all,)))
@P rsn(() -> run!(s; t_end = 0.1, ignore_stop_requests = ("nosuch",)))
@P rsn(() -> step!(s; t_end = 10.0, ignore_stop_requests = ("nosuch",)))
println("## replay/live")
s2 = Simulation(dep)
init!(s2, set(u = (ref = 1.0,)))
stage!(s2, "ref" => 2.0)
step!(s2; frames = 2)
trc = trace(s2)
run!(s2; t_end = 0.5)
trc = trace(s2)
sB = Simulation(dep)
@P rsn(() -> replay!(sB, trc))
@P (lifecycle(sB), mode(sB))
@P rsn(() -> live!(sB))
@P (lifecycle(sB), mode(sB))
@P rsn(() -> step!(sB))
sC = Simulation(dep)
@P rsn(() -> replay!(sC, trc; to_boundary = 2, to_time = 0.2))
@P rsn(() -> replay!(sC, trc; to_time = 0.2))
@P (lifecycle(sC), mode(sC))
@P rsn(() -> live!(sC))
@P (lifecycle(sC), mode(sC))
@P rsn(() -> live!(sC))
@P rsn(() -> replay!(Simulation(dep), trc; restore = 1))
@P rsn(() -> replay!(Simulation(dep), trc; restore = false))
@P rsn(() -> replay!(Simulation(dep), trc; log_every = 0))
@P rsn(() -> replay!(Simulation(dep), trc; pace = 0))
println("## devices")
sD = Simulation(dep)
pad = Pad("a")
h = attach!(sD, pad, Enumerated("ref"))
@P typeof(h)
@P (running(h), latest(h), binding(h))
@P rsn(() -> attach!(sD, pad, Enumerated("ref")))
@P rsn(() -> attach!(sD, Pad("b"), Enumerated("ref")))
@P rsn(() -> attach!(sD, Pad("c"), Enumerated("nosuch")))
@P rsn(() -> attach!(sD, Pad("d"), NoClaim()))
@P rsn(() -> attach!(sD, Pad("e"), Greedy()))
@P rsn(() -> attach!(sD, Pad("f"), Greedy()))
@P rsn(() -> attach!(sD, Voiceless(), NoClaim()))
@P rsn(() -> attach!(sD, Pad("g"), AbstractBinding[][1:0] |> x -> NoClaim(); should_abort = true))
@P rsn(() -> attach!(sD, Pad("g"), NoClaim(); should_abort = 1))
struct NoSides <: AbstractBinding end
struct GreedyNoInput <: AbstractBinding end
Redstone.is_greedy(::GreedyNoInput) = true
struct ClaimsNoTrait <: AbstractBinding end
Redstone.claims(::ClaimsNoTrait) = ()
Redstone.is_input(::ClaimsNoTrait) = false
Redstone.is_output(::ClaimsNoTrait) = true
Redstone.reads(::ClaimsNoTrait) = (;)
struct DeclaredNoMethod <: AbstractBinding end
Redstone.is_input(::DeclaredNoMethod) = true
@P rsn(() -> attach!(sD, Pad("h"), NoSides()))
@P rsn(() -> attach!(sD, Pad("h"), GreedyNoInput()))
@P rsn(() -> attach!(sD, Pad("h"), ClaimsNoTrait()))
@P rsn(() -> attach!(sD, Pad("h"), DeclaredNoMethod()))
@P rsn(() -> detach!(sD, Pad("zzz")))
@P detach!(sD, pad)
@P rsn(() -> detach!(sD, pad))
@P rsn(() -> stage!(h, "ref" => 1.0))
@P stop!(h)
@P [(x, hasmethod(x, Tuple{typeof(h)})) for x in (latest, wait_next_snapshot, running, binding, stop!)]
@P [hasmethod(f, Tuple{typeof(h), Redstone.Snapshot}) for f in (gather,)]
@P hasmethod(report!, Tuple{typeof(h), Redstone.MalformedDatum})
@P hasmethod(pending, Tuple{typeof(h), Int})
@P hasmethod(port_views, Tuple{typeof(h)})
@P (hasmethod(orphaned, Tuple{Redstone.WriterStatus}), hasmethod(stale, Tuple{Redstone.WriterStatus}))
@P hasmethod(incumbent_status, Tuple{Redstone.PortView, Redstone.Snapshot})
@P hasmethod(peek, Tuple{Redstone.PortView, typeof(h), Redstone.Snapshot})
sE = Simulation(dep); hE = attach!(sE, Pad("p"), Enumerated("ref")); init!(sE, set(u=(ref=1.0,))); step!(sE)
@P (typeof(port_views(hE)), length(port_views(hE)))
@P (let pv = collect(values(port_views(hE))); [(v.path, v.port, v.live, v.slot) for v in pv] end)
@P (let pv = collect(values(port_views(hE))); [peek(v, hE, latest(sE)) for v in pv][1:3] end)
@P (let pv = collect(values(port_views(hE))); [incumbent_status(v, latest(sE)) for v in pv][1:2] end)
@P (let pv = collect(values(port_views(hE))); st = [incumbent_status(v, latest(sE)) for v in pv]; (typeof(first(st)), orphaned(first(st)), stale(first(st))) end)
@P pending(hE, 1)
@P report!(hE, MalformedDatum("bad"))
@P rsn(() -> report!(hE, 3))
@P gather(hE, latest(sE))
@P (TableBinding(a = (face = "ref",)) |> b -> (is_input(b), is_output(b), is_greedy(b), claims(b)))
println("## trim/linearize on sim")
sP = Simulation(Deployment(build(pend()); Δt_frame = 1//10))
@P rsn(() -> lifecycle(sP))
@P typeof(trim!(sP, prob; baseline = set(u = (in = 0.0,)))).name.name
@P lifecycle(sP)
@P typeof(linearize(sP, lt))
@P rsn(() -> linearize(sP, lt; width = 2, about = set(x=(;), u = (in = 0.0,)), t0 = 0)) 
@P rsn(() -> linearize(sP, 3))
@P rsn(() -> linearize(Simulation(Deployment(build(pend()); Δt_frame = 1//10)), lt))
@P rsn(() -> linearize(Simulation(Deployment(build(pend()); Δt_frame = 1//10)), lt; about = set(u = (in = 0.0,))))
@P (let l = linearize(sP, lt; about = set(u=(in=1.0,)), t0 = 0); l.u₀ end)
@P (let l = linearize(sP, lt); l.u₀ end)
println("## Model.init! hooks / overlay")
@P rsn(() -> init!(Model(dep), c0; t0 = 1e-4))
@P rsn(() -> init!(Model(dep), c0; t0 = 1//2))
@P rsn(() -> init!(Model(dep), c0; t0 = -0.3))

println("## extra")
@P keys(descriptor(try build(Group((; c = Gain(1.0)); local_wires = ("c/zz" => "c/e",))) catch e; e end).failure)
@P keys(descriptor(try build(feedback_model(feedback_port = "power")) catch e; e end).failure)
@P [typeof(w) for w in warnings(Model(dep))]
@P hasmethod(descriptor, Tuple{Redstone.DiagnosticError})
@P (typeof(sE.run), sE.run.termination)
@P frame!(Model(dep), 1)
mq = Model(dep); init!(mq, c0)
struct AbandonHooks <: FrameHooks end
Redstone.frame_top!(::AbandonHooks) = false
Redstone.settled!(::AbandonHooks) = true
@P frame!(mq, 1, AbandonHooks())
@P rsn(() -> checkpoint(mq))
@P rsn(() -> frame!(mq, 1, NoHooks()))
@P (let m = Model(dep); init!(m, c0); n = 0; (Redstone.frame_top!(NoHooks()), Redstone.settled!(NoHooks())) end)
@P [typeof(d) for d in Redstone.warnings(build(Group((; p = Plant()); input_wires = ("u" => "p/u",))))]

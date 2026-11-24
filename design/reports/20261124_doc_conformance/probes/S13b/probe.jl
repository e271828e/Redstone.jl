# S13b probe: spec 11457-11970 (13.4 runtime failures, 13.5 termination)
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test, InteractiveUtils
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
include(joinpath(W, "utils.jl"))

macro chk(ex)
    quote
        local r = try; $(esc(ex)); catch e; "THROW " * sprint(showerror, e); end
        println("probe:", $(__source__.line), "  ", r === true ? "ok  " : "RES ", first(replace(string($(QuoteNode(ex))), r"#=.*?=#"=>"", r"\s+"=>" "), 110), r === true ? "" : "  => " * repr(r))
    end
end
hdr(s) = println("\n== ", s)

# --- fixtures of my own ---
struct BZBomb <: AbstractComponent end       # throws in boundary zero when armed
x_init(::BZBomb) = nothing
u_types(::BZBomb) = (arm = Bool,)
y_types(::BZBomb) = (q = Float64,)
y_direct(::BZBomb, (; u)) = u.arm ? throw(ArgumentError("bz")) : (q = 1.0,)

struct RawThrower <: AbstractComponent end   # throws a bare value
x_init(::RawThrower) = (q = 0.0,)
u_types(::RawThrower) = (arm = Bool,)
y_types(::RawThrower) = (q = Float64,)
y_state(::RawThrower, (; x)) = (q = x.q,)
x_deriv(::RawThrower, (; x, u)) = u.arm ? throw(42) : (q = one(x.q),)

struct DiagThrower <: AbstractComponent end  # throws a single-diagnostic carrier
x_init(::DiagThrower) = (q = 0.0,)
u_types(::DiagThrower) = (arm = Bool,)
y_types(::DiagThrower) = (q = Float64,)
y_state(::DiagThrower, (; x)) = (q = x.q,)
x_deriv(::DiagThrower, (; x, u)) = u.arm ? throw(DiagnosticError(ArgumentInvalid(call = :x, reason = :range, argument = :a, value = 1))) : (q = one(x.q),)

ramp_request(level, reason) =
    Group((; src = Ramp(0.0), trig = Trigger(level), stop = StopRequest(reason = reason));
          local_wires = ("src/out" => "trig/sig", "trig/on" => "stop/u"))

struct BareFlag <: AbstractComponent end
x_init(::BareFlag) = nothing
y_types(::BareFlag) = StopFlag
y_state(::BareFlag, _) = NO_STOP

struct NestedFlag <: AbstractComponent end
x_init(::NestedFlag) = nothing
y_types(::NestedFlag) = (a = Tuple{StopFlag,Float64},)
y_state(::NestedFlag, _) = (a = (NO_STOP, 1.0),)

struct FlagIn <: AbstractComponent end
x_init(::FlagIn) = nothing
u_types(::FlagIn) = (f = StopFlag,)
y_types(::FlagIn) = (q = Float64,)
y_direct(::FlagIn, _) = (q = 1.0,)

hdr("runtime carrier, frame failure (Tripwire at stage 2)")
sim = Simulation(fed(Tripwire(0.05), "arm"); Δt_frame = 1//10)
init!(sim, set(u = (in = true,)))
err = failure(() -> run!(sim; t_end = 5.0))
@chk err isa StepError{Tripped}
@chk fieldnames(StepError) == (:cursor, :t, :boundary, :host, :cause)
@chk err.host === :loop && err.boundary == 0
@chk err.cursor == CursorFrame("c", :x_deriv, :integrate, 2, 1)
@chk err.t == 0.05
@chk fieldnames(Redstone.ExecutionCursor) == (:comp, :fn, :phase, :index, :attempt)
@chk sim.model.status === :inconsistent && lifecycle(sim) === :errored
@chk termination(sim).source isa LoopError && termination(sim).source.exception === err
println(sprint(showerror, err))
@chk err isa StepError
@chk StepError{Tripped} <: StepError && StepError{Tripped}.parameters[1] === Tripped
@chk StepError{<:Union{Diagnostic,Exception}} === StepError

hdr("raw throw => StepError{ArgumentError} (boundary zero) ; bare value")
z = Simulation(fed(BZBomb(), "arm"); Δt_frame = 1//10)
e0 = failure(() -> init!(z, set(u = (in = true,)), t0 = 2))
@chk e0 isa StepError{ArgumentError}
@chk e0.host === :boundary_zero && e0.boundary == 0 && e0.t == 2.0
@chk e0.cursor.path == "c" && e0.cursor.fn === :y_direct
@chk lifecycle(z) === :built && z.model.status === :built
@chk termination(z) === nothing
@chk failure(() -> trace(z)) isa DiagnosticError
@chk failure(() -> run!(z)) isa DiagnosticError{MissingInit}
@chk failure(() -> step!(z; frames = 1)) isa DiagnosticError{MissingInit}
@chk z.run.trace !== nothing && z.run.trace.header === nothing   # the opened run: empty, no header
@chk failure(() -> checkpoint(z)) isa DiagnosticError
@chk (init!(z, set(u = (in = false,))); lifecycle(z) === :initialized)
println(sprint(showerror, e0))
# replay! and restore! legal at :built
z2 = Simulation(fed(BZBomb(), "arm"); Δt_frame = 1//10)
init!(z2, set(u = (in = false,))); step!(z2; frames = 2); cp = checkpoint(z2); trc0 = trace(z2)
failure(() -> init!(z2, set(u = (in = true,))))
@chk lifecycle(z2) === :built
@chk (restore!(z2, cp); lifecycle(z2) === :initialized)
failure(() -> init!(z2, set(u = (in = true,))))
@chk (replay!(z2, trc0); lifecycle(z2) in (:initialized, :stopped))
# bare value
rt = Simulation(fed(RawThrower(), "arm"); Δt_frame = 1//10)
init!(rt, set(u = (in = true,)))
er = failure(() -> run!(rt; t_end = 1.0))
@chk er isa StepError
println("bare-value throw gives: ", typeof(er), " ", er isa Int ? er : "")
@chk rt.model.status === :inconsistent
# species of a single-diagnostic DiagnosticError
dt = Simulation(fed(DiagThrower(), "arm"); Δt_frame = 1//10)
init!(dt, set(u = (in = true,)))
ed = failure(() -> run!(dt; t_end = 1.0))
@chk ed isa StepError{ArgumentInvalid} && ed.cause isa ArgumentInvalid

hdr("replay recipe: halt at frame top, mode :replay, step! re-executes")
ex = Simulation(fed(Exploder(), "arm"); Δt_frame = 1//10)
init!(ex, set(u = (in = false,)))
step!(ex; frames = 2)
stage!(ex, "in" => true)
ee = failure(() -> step!(ex; frames = 3))
@chk ee isa StepError{Exploded} && ee.boundary == 2
trc = trace(ex)
sim2 = Simulation(fed(Exploder(), "arm"); Δt_frame = 1//10)
replay!(sim2, trc; to_boundary = ee.boundary)
@chk mode(sim2) === :replay && lifecycle(sim2) === :initialized
@chk failure(() -> step!(sim2; frames = 1)) isa StepError{Exploded}
# frame-one failure at pointer 0
f1 = Simulation(fed(Exploder(), "arm"); Δt_frame = 1//10)
init!(f1, set(u = (in = false,))); stage!(f1, "in" => true)
e1 = failure(() -> run!(f1; t_end = 1.0))
@chk e1.boundary == 0 && e1.host === :loop
trc1 = trace(f1)
f1b = Simulation(fed(Exploder(), "arm"); Δt_frame = 1//10)
replay!(f1b, trc1; to_boundary = 0)
@chk mode(f1b) === :replay && lifecycle(f1b) === :initialized && trace(f1b).header !== nothing
@chk failure(() -> step!(f1b; frames = 1)) isa StepError{Exploded}

hdr("overlay! host")
ov = Simulation(fed(Mine(), "sig"); Δt_frame = 1//10)
init!(ov, set(u = (in = false,))); step!(ov; frames = 2)
eo = failure(() -> overlay!(ov, set(u = (in = true,))))
@chk eo isa StepError{Detonated} && eo.host === :overlay
@chk lifecycle(ov) === :built
@chk ov.run.trace !== nothing && ov.run.trace.header === nothing
# boundary zero failing in an event round
mz = Simulation(fed(Mine(), "sig"); Δt_frame = 1//10)
em = failure(() -> init!(mz, set(u = (in = true,))))
@chk em isa StepError{Detonated} && em.host === :boundary_zero && em.cursor.fn === :handler && em.cursor.phase === :round

hdr("nonfinite check")
dv = Simulation(fed(Diverger(), "arm"); Δt_frame = 1//10)
init!(dv, set(u = (in = true,)))
en = failure(() -> run!(dv; t_end = 1.0))
@chk en isa StepError{NonfiniteState}
@chk en.cause.path == "c" && en.cause.leaf == "q" && en.cause.boundary == 0
@chk en.cursor.phase === :integrate
@chk fieldnames(NonfiniteState) == (:path, :leaf, :value, :t, :boundary)
@chk NonfiniteState <: Diagnostic

hdr("stop requests: roster, placement")
mon = ramp_request(0.35, "ramp at level")
sm = Simulation(mon; Δt_frame = 1//10)
lay = sm.model.exec.act.layout
@chk lay.requesters == [Requester("stop", :y, "ramp at level")]
@chk fieldnames(Requester) == (:path, :port, :reason)
@chk fieldnames(StopRequest) == (:reason) || fieldnames(StopRequest) == (:reason,)
@chk StopRequest().reason == ""
@chk instances(StopFlag) == (NO_STOP, STOP_REQUESTED)
@chk Base.Enums.basetype(StopFlag) !== nothing
bf = Simulation(Group((; r = BareFlag())); Δt_frame = 1//10)
@chk bf.model.exec.act.layout.requesters[1].port === :y
ne = failure(() -> build(Group((; r = NestedFlag()))))
@chk ne isa DiagnosticError && any(d -> d isa IllegalPortType && d.reason === :stop_flag_nested, diagnostics(ne))
ri = failure(() -> build(Group((; r = FlagIn()); input_wires = ("in" => "r/f",))))
println("root input with StopFlag: ", ri isa Exception ? [ (d isa IllegalPortType ? d.reason : typeof(d)) for d in diagnostics(ri)] : ri)
@chk ri isa DiagnosticError && any(d -> d isa IllegalPortType && d.reason === :stop_flag_at_root, diagnostics(ri))
@chk build(Group((; r = FlagIn()))) isa Build   # a StopFlag input port not at the root: left alone (unwired root?)

hdr("policy per advance")
@chk begin d = carried(@test_throws DiagnosticError{ArgumentInvalid} run!((init!(sm); sm); t_end = -1)); d.argument === :t_end end
@chk begin d = carried(@test_throws DiagnosticError{ArgumentInvalid} run!(sm; t_end = "x")); d.argument === :t_end end
@chk begin d = carried(@test_throws DiagnosticError{ArgumentInvalid} run!(sm; t_end = 1e30)); d.argument === :t_end end
@chk begin d = carried(@test_throws DiagnosticError{ArgumentInvalid} run!(sm; ignore_stop_requests = "stop")); d.argument === :ignore_stop_requests end
@chk begin d = carried(@test_throws DiagnosticError{ArgumentInvalid} run!(sm; ignore_stop_requests = :none)); d.argument === :ignore_stop_requests end
@chk begin
    e = failure(() -> run!(sm; t_end = -1, ignore_stop_requests = ("nope",)))
    e isa DiagnosticError{ArgumentInvalid}
end
@chk begin
    e = failure(() -> run!(sm; ignore_stop_requests = ("nope", "stop", "bad")))
    e isa DiagnosticError && length(diagnostics(e)) == 2 && all(d -> d isa StopRequestInvalid, diagnostics(e))
end
for f in (run!, step!, replay!)
    m = first(methods(f)); 
end
@chk Base.kwarg_decl(first(methods(run!, (Simulation,)))) |> x -> (:t_end in x && :ignore_stop_requests in x)
@chk (init!(sm); run!(sm; t_end = 1.0, ignore_stop_requests = ("stop", "stop")); termination(sm).policy.ignored == ["stop"] && termination(sm).policy.t_end == 1.0)
@chk fieldnames(Redstone.StopPolicy) == (:t_end, :ignored)
@chk fieldnames(TerminationRecord) == (:t, :policy, :source, :residue)
@chk true
@chk Set(nameof.(subtypes(Redstone.TerminationSource))) == Set([:EndTimeReached, :ModelRequestedStop, :ControlRequestedStop, :LoopError])
@chk fieldnames(ModelRequestedStop) == (:path, :port, :reason)
@chk fieldnames(ControlRequestedStop) == (:issuer,)
@chk fieldnames(EndTimeReached) == ()

hdr("the spec's example block (adapted: world = monitored ramp, cond = set())")
world = mon; cond = set()
sim = Simulation(world; Δt_frame = 1//50)
init!(sim, cond); run!(sim; t_end = 60)
@chk termination(sim).source isa ModelRequestedStop && termination(sim).source.reason == "ramp at level"
init!(sim, cond); run!(sim; t_end = 60, ignore_stop_requests = ("stop",))
@chk termination(sim).source === EndTimeReached()
init!(sim, cond); @chk step!(sim; frames = 100) == 100
@chk termination(sim) === nothing || true
println("termination after step!(frames=100): ", termination(sim))

hdr("unbounded advisory")
struct HookedRamp <: AbstractComponent
    hook::Base.RefValue{Any}
end
HookedRamp() = HookedRamp(Ref{Any}(nothing))
x_init(::HookedRamp) = (q = 0.0,)
u_types(::HookedRamp) = (arm = Bool,)
y_types(::HookedRamp) = (q = Float64,)
y_state(::HookedRamp, (; x)) = (q = x.q,)
x_deriv(c::HookedRamp, (; x, u)) = (u.arm && c.hook[](); (q = one(x.q),))
hooked_ramp(c) = Group((c = c, trig = Trigger(0.15));
                       local_wires = ("c/q" => "trig/sig", "trig/on" => "c/arm"))
hr = HookedRamp()
ub = Simulation(Group((; run = hooked_ramp(hr), r = Group((; src = Constant(false), stop = StopRequest(reason = "never")); local_wires = ("src/y" => "stop/u",)))); Δt_frame = 1//10)
hr.hook[] = () -> stop!(ub)
init!(ub); run!(ub; ignore_stop_requests = :all)
adv = [d for s in logged(ub) for d in writer_status(s, "loop").recent if d isa UnboundedRun]
@chk length(adv) == 1 && adv[1].ignored == ["r/stop"]
println(Redstone.message(adv[1]))
@chk termination(ub).source === ControlRequestedStop(:code)
# replay never raises it
hr2 = HookedRamp(); hr2.hook[] = () -> nothing
ub2 = Simulation(hooked_ramp(hr2); Δt_frame = 1//10)
init!(ub2); step!(ub2; frames = 3); tr2 = trace(ub2)
ub3 = Simulation(hooked_ramp(HookedRamp(Ref{Any}(() -> nothing))); Δt_frame = 1//10)
replay!(ub3, tr2; to_boundary = 1); run!(ub3)
@chk all(writer_status(s, "loop").totals.unbounded == 0 for s in logged(ub3))
@chk termination(ub3).source === EndTimeReached() ? false : true

hdr("scan, source order")
# request holds at which boundary? find it, then set t_end to that boundary's time
sq = Simulation(mon; Δt_frame = 1//10); init!(sq); run!(sq; t_end = 5.0)
tq = termination(sq).t; println("request ends the run at t = ", tq)
@chk termination(sq).source isa ModelRequestedStop
sq2 = Simulation(mon; Δt_frame = 1//10); init!(sq2); run!(sq2; t_end = tq)
println("t_end = t_request: source = ", termination(sq2).source)
# control stop pending + request at same boundary
sq3 = Simulation(mon; Δt_frame = 1//10); init!(sq3); stop!(sq3); run!(sq3; t_end = 5.0)
println("stop! pending before run: source = ", termination(sq3).source, " t=", termination(sq3).t)
# entry check: authored condition already terminal
ar = Simulation(Group((; c = Trigger(0.5), stop = StopRequest(reason = "input at level"));
     input_wires = ("in" => "c/sig",), local_wires = ("c/on" => "stop/u",)); Δt_frame = 1//10)
init!(ar, set(u = (in = 1.0,)))
println("authored terminal: lifecycle ", lifecycle(ar), " latest.t=", latest(ar).t)
run!(ar; t_end = 5.0)
@chk termination(ar).source isa ModelRequestedStop && termination(ar).t == 0.0 && length(logged(ar)) == 1
# two requests at one boundary: first in roster order
tw = Simulation(Group((; a = ramp_request(0.35, "a"), b = ramp_request(0.35, "b"))); Δt_frame = 1//10)
init!(tw); run!(tw; t_end = 5.0)
@chk termination(tw).source.reason == "a"
tw2 = Simulation(Group((; b = ramp_request(0.35, "b"), a = ramp_request(0.35, "a"))); Δt_frame = 1//10)
init!(tw2); run!(tw2; t_end = 5.0)
@chk termination(tw2).source.reason == "b"
# terminal snapshot carries status counters
@chk latest(sq).status !== nothing

hdr("LoopError outside the frame: frame! refusal past lattice range")
big = Simulation(Group((; r = Ramp(0.0))); Δt_frame = 2^40)
init!(big, set())
println("last frame: ", Redstone._last_frame(big.model))

hdr("discrete detector fed to StopRequest sees the tick at its own boundary")
struct DiscDet <: AbstractComponent end
s_init(::DiscDet) = 0
y_types(::DiscDet) = (on = Bool,)
y_state(::DiscDet, (; s)) = (on = s >= 3,)
s_update(::DiscDet, (; s)) = s + 1
dd = Simulation(Group((; det = DiscDet(), stop = StopRequest(reason = "d")); local_wires = ("det/on" => "stop/u",)); Δt_frame = 1//10)
init!(dd); run!(dd; t_end = 2.0)
snaps = logged(dd)
println([(s.t, port(s, "det", :on), port(s, "stop")) for s in snaps])
@chk all((port(s, "det", :on) == true) == (port(s, "stop") == STOP_REQUESTED) for s in snaps)
@chk termination(dd).source isa ModelRequestedStop && port(latest(dd), "det", :on) == true

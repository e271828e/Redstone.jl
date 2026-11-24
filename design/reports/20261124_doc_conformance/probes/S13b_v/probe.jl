# S13b independent verification probes (read-only; run from the pinned worktree).
using Redstone
import Redstone: AbstractComponent, x_init, u_types, y_types, y_state, y_direct, x_deriv,
    Group, Model, Simulation, init!, frame!, run!, step!, replay!, trace, termination,
    lifecycle, mode, StepError, StopFlag, STOP_REQUESTED, NO_STOP, Requester, set,
    checkpoint, latest, EndTimeReached, ModelRequestedStop, ControlRequestedStop, LoopError,
    StopRequestInvalid, DiagnosticError, ArgumentInvalid, Diagnostic, stop!, StopRequest

failure(f) = try f(); nothing catch err err end
say(tag, x) = println(tag, " => ", x)

const BZ_ARM = Ref(false)
struct Boom <: AbstractComponent; t_fail::Float64; end
x_init(::Boom) = (q = 0.0,)
y_types(::Boom) = (q = Float64,)
y_state(::Boom, (; x)) = (BZ_ARM[] && error("boundary zero boom"); (q = x.q,))
x_deriv(c::Boom, (; x, t)) = (t > c.t_fail && error("frame boom"); (q = one(x.q),))

struct BareThrow <: AbstractComponent end
x_init(::BareThrow) = (q = 0.0,)
y_types(::BareThrow) = (q = Float64,)
y_state(::BareThrow, (; x)) = (q = x.q,)
x_deriv(::BareThrow, (; x, t)) = (t > 0.15 && throw(42); (q = one(x.q),))

struct Intr <: AbstractComponent end
x_init(::Intr) = (q = 0.0,)
y_types(::Intr) = (q = Float64,)
y_state(::Intr, (; x)) = (q = x.q,)
x_deriv(::Intr, (; x, t)) = (t > 0.15 && throw(InterruptException()); (q = one(x.q),))

const DIAG = ArgumentInvalid(call = :probe, reason = :range, argument = :k, value = 1)
struct DiagThrow <: AbstractComponent; collected::Bool; end
x_init(::DiagThrow) = (q = 0.0,)
y_types(::DiagThrow) = (q = Float64,)
y_state(::DiagThrow, (; x)) = (q = x.q,)
x_deriv(c::DiagThrow, (; x, t)) = (t > 0.15 &&
    throw(c.collected ? DiagnosticError(Diagnostic[DIAG, DIAG]) : DiagnosticError(DIAG));
    (q = one(x.q),))

const STOPSIM = Ref{Any}(nothing)
struct Stopper <: AbstractComponent; level::Float64; hook_t::Float64; end
x_init(::Stopper) = (q = 0.0,)
y_types(::Stopper) = (flag = StopFlag,)
y_state(c::Stopper, (; x)) = (flag = x.q ≥ c.level - 1e-9 ? STOP_REQUESTED : NO_STOP,)
x_deriv(c::Stopper, (; x, t)) = (c.hook_t > 0 && t > c.hook_t && STOPSIM[] !== nothing &&
                                 stop!(STOPSIM[]); (q = one(x.q),))

struct FlagReader <: AbstractComponent end
x_init(::FlagReader) = nothing
u_types(::FlagReader) = (f = StopFlag,)
y_types(::FlagReader) = (b = Bool,)
y_direct(::FlagReader, (; u)) = (b = u.f === STOP_REQUESTED,)

one_of(c) = Group((; c = c))

println("--- S13b-051 bare value")
m = Model(one_of(BareThrow()); Δt_frame = 1//10); init!(m); frame!(m, 1)
e = failure(() -> frame!(m, 2))
say("bare: typeof err", typeof(e)); say("bare: err === 42", e === 42); say("bare: status", m.status)

println("--- S13b-057 interrupt in frame")
m = Model(one_of(Intr()); Δt_frame = 1//10); init!(m); frame!(m, 1)
e = failure(() -> frame!(m, 2))
say("intr: typeof", typeof(e)); say("intr: status", m.status)
sim = Simulation(one_of(Intr()); Δt_frame = 1//10); init!(sim)
e = failure(() -> run!(sim; t_end = 1.0))
say("intr run!: typeof", typeof(e)); say("intr run!: lifecycle", lifecycle(sim))
say("intr run!: source", typeof(termination(sim).source))

println("--- S13b-037 species")
m = Model(one_of(DiagThrow(false)); Δt_frame = 1//10); init!(m)
e = failure(() -> frame!(m, 2 - 1 + 1))   # frame 1 then 2
e === nothing && (e = failure(() -> frame!(m, 2)))
say("single: typeof", typeof(e)); say("single: cause isa Diagnostic", e.cause isa Diagnostic)
m = Model(one_of(DiagThrow(true)); Δt_frame = 1//10); init!(m); frame!(m, 1)
e = failure(() -> frame!(m, 2))
say("collected: typeof", typeof(e)); say("collected: cause", typeof(e.cause))

println("--- S13b-085/094/112 boundary zero")
sim = Simulation(one_of(Boom(10.0)); Δt_frame = 1//10)
BZ_ARM[] = true
e = failure(() -> init!(sim; t0 = 1//2))
BZ_ARM[] = false
say("bz: typeof", typeof(e)); say("bz: t", e.t); say("bz: boundary", e.boundary); say("bz: host", e.host)
say("bz: lifecycle", lifecycle(sim)); say("bz: termination", termination(sim))
say("bz: trace(sim)", typeof(failure(() -> trace(sim))))
say("bz: checkpoint(sim)", typeof(failure(() -> checkpoint(sim))))
say("bz: run.trace header", sim.run.trace === nothing ? "no trace" : sim.run.trace.header)

println("--- S13b-028/075/103/066/233 frame failures and replay")
for (tfail, label) in ((0.05, "frame one"), (0.25, "frame three"))
    sim = Simulation(one_of(Boom(tfail)); Δt_frame = 1//10); init!(sim)
    e = failure(() -> run!(sim; t_end = 1.0))
    say("$label: run! rethrew", typeof(e)); say("$label: boundary", e.boundary)
    say("$label: host", e.host); say("$label: lifecycle", lifecycle(sim))
    say("$label: model status", sim.model.status)
    say("$label: source", typeof(termination(sim).source))
    trc = trace(sim)
    say("$label: trace frames", trc.frames)
    sim2 = Simulation(one_of(Boom(tfail)); Δt_frame = 1//10)
    r = failure(() -> replay!(sim2, trc; to_boundary = e.boundary))
    say("$label: replay! result", r === nothing ? "ok" : sprint(showerror, r))
    say("$label: after halt lifecycle/mode/t", (lifecycle(sim2), mode(sim2), latest(sim2).t))
    e2 = failure(() -> step!(sim2; frames = 1))
    say("$label: step! reproduces", typeof(e2))
    e2 isa StepError && say("$label: same cursor/boundary", (e2.cursor == e.cursor, e2.boundary == e.boundary, e2.t == e.t))
    say("$label: rendered", sprint(showerror, e))
end

println("--- S13b-149/168 requesters and StopFlag input")
g = Group((s = Stopper(0.3, 0.0), r = FlagReader()); local_wires = ("s/flag" => "r/f",))
sim = Simulation(g; Δt_frame = 1//10)
say("requesters", sim.model.exec.act.layout.requesters)

println("--- S13b-186 ignore paths")
init!(sim)
e = failure(() -> step!(sim; ignore_stop_requests = ("nope", "also/nope")))
say("invalid: ", typeof(e)); e isa DiagnosticError && say("invalid carried", e.carried)

println("--- S13b-205 source order")
sim = Simulation(g; Δt_frame = 1//10); init!(sim)
run!(sim; t_end = 0.3)
say("t_end + request at 0.3: source", termination(sim).source); say("t", termination(sim).t)
sim = Simulation(one_of(Stopper(0.3, 0.25)); Δt_frame = 1//10); STOPSIM[] = sim; init!(sim)
run!(sim; t_end = 5.0)
say("control stop in frame 3 + request at 0.3: source", termination(sim).source); say("t", termination(sim).t)
sim = Simulation(one_of(Stopper(0.5, 0.25)); Δt_frame = 1//10); STOPSIM[] = sim; init!(sim)
run!(sim; t_end = 5.0)
say("control stop in frame 3 alone (request at 0.5): source", termination(sim).source); say("t", termination(sim).t)
STOPSIM[] = nothing
sim = Simulation(one_of(Stopper(0.3, 0.0)); Δt_frame = 1//10); init!(sim)
run!(sim; t_end = 0.3, ignore_stop_requests = :all)
say("t_end alone: source", termination(sim).source); say("t", termination(sim).t)

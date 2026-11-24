# S13c verifier probe: §13.6–§13.8 claims, run from the pinned worktree.
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff
const TESTDIR = joinpath(pwd(), "test")
include(joinpath(TESTDIR, "imports.jl"))
include(joinpath(TESTDIR, "fixtures.jl"))
fed(c, face) = Group((; c = c); input_wires = ("in" => "c/$face",))
failure(f) = try f(); nothing catch err; err end
say(label, v) = println(rpad(label, 34), " ", v)
first_diag(e) = e.carried isa Vector ? e.carried[1] : e.carried
kind(e) = e === nothing ? "no error" : e isa DiagnosticError ? "DiagnosticError{$(nameof(typeof(first_diag(e))))}" : string(nameof(typeof(e)))
const with_logger = Base.CoreLogging.with_logger; const NullLogger = Base.CoreLogging.NullLogger

# --- devices for the tail ----------------------------------------------------------
mutable struct Seer <: AbstractDevice
    seen::Vector{Int}; log::Vector{Symbol}
end
Seer() = Seer(Int[], Symbol[])
shutdown!(d::Seer) = (push!(d.log, :shutdown); nothing)
function loop(d::Seer, h)
    while running(h)
        s = wait_next_snapshot(h)
        s === nothing || push!(d.seen, s.boundary)
    end
end
mutable struct HangUnblock <: AbstractDevice end
loop(::HangUnblock, h) = (while running(h); wait_next_snapshot(h); end)
unblock!(::HangUnblock) = (sleep(3.0); nothing)
mutable struct HangShutdown <: AbstractDevice end
loop(::HangShutdown, h) = (while running(h); wait_next_snapshot(h); end)
shutdown!(::HangShutdown) = (sleep(3.0); nothing)

println("== §13.6 abnormal path")
let
    sim = Simulation(fed(Tripwire(0.15), "arm"); Δt_frame = 1//10)
    dev = Seer()
    attach!(sim, dev, NoClaim())
    init!(sim, set(u = (in = false,)))
    step!(sim; frames = 1)
    stage!(sim, "in" => true)
    with_logger(NullLogger()) do; run!(sim; t_end = 5.0); end
    rec = termination(sim)
    say("001 source", typeof(rec.source))
    say("001/029 lifecycle", lifecycle(sim))
    err = rec.source.exception
    say("019 StepError boundary, t", (err.boundary, err.t))
    say("019 latest boundary, t", (latest(sim).boundary, latest(sim).t))
    say("019 device saw boundaries", dev.seen)
    say("010 device shutdown ran", dev.log)
    trc = trace(sim)
    say("041 trace frames, batches", (trc.frames, [(b.frame, b.entries) for b in trc.batches]))
    say("041 logged boundaries", [s.boundary for s in logged(sim)])
    for (name, f) in (("run!", () -> run!(sim; t_end = 6.0)), ("step!", () -> step!(sim; frames = 1)),
                      ("init!", () -> init!(sim, set(u = (in = false,)))),
                      ("replay!", () -> replay!(sim, trc)), ("live!", () -> live!(sim)),
                      ("attach!", () -> attach!(sim, Pad("p"), NoClaim())),
                      ("detach!", () -> detach!(sim, dev)), ("latest (read)", () -> latest(sim)),
                      ("trace (read)", () -> trace(sim)))
        e = failure(f)
        say("029 $name on errored", e isa DiagnosticError ? (kind(e), first_diag(e).status) : kind(e))
    end
end

println("== 031 hanging hooks under join_timeout = 0.5")
for dev in (HangShutdown(), HangUnblock())
    sim = Simulation(fed(Tripwire(1e9), "arm"); Δt_frame = 1//10, join_timeout = 0.5)
    attach!(sim, dev, NoClaim())
    init!(sim, set(u = (in = false,)))
    t0 = time(); run!(sim; t_end = 0.3); dt = time() - t0
    say("031 $(nameof(typeof(dev))) run! seconds", round(dt; digits = 2))
end

println("== §13.7 routes")
let
    fan = build(Group((a = Gain(1.0), b = Gain(2.0)); input_wires = ("in" => ("a/e", "b/e"),),
                      output_wires = ("a/out" => "ya",)))
    show(stdout, MIME"text/plain"(), fan.structure); println()
    prim = build(Gain(1.0))
    show(stdout, MIME"text/plain"(), prim.structure); println()
end

println("== §13.7 library")
let
    say("068 Redstone.Library", (isdefined(Redstone, :Library), Redstone.Library isa Module, parentmodule(Constant)))
    say("077 And{3}().f, Or{2}().f", (And{3}().f, Or{2}().f, And{3} <: Junction))
    say("165 output_faces(Constant(1.0))", output_faces(Constant(1.0)))
    e = failure(() -> build(Group((c = Constant(1.0), g = Gain(1.0)); local_wires = ("c/out" => "g/e",))))
    say("165 wire c/out", kind(e))
    e = failure(() -> build(Group((c = Constant(1.0), g = Gain(1.0)); local_wires = ("c/y" => "g/e",))))
    say("165 wire c/y", kind(e))
    sim = Simulation(Group((c = Constant(1.0), g = Gain(1.0)); local_wires = ("c/y" => "g/e",)); Δt_frame = 1//10)
    e = failure(() -> init!(sim, set(c = (value = 2.0,))))
    say("123 condition on Constant value", kind(e))
    rig = TerrainRig()
    say("138/153 rig root inputs", build(rig).structure.root_inputs)
    ud = build(Group((d = UnitDelay(0.0), g = Gain(1.0)); local_wires = ("g/out" => "d/u", "d/y" => "g/e")))
    show(stdout, MIME"text/plain"(), ud.structure); println()
end

# --- 096: a continuous stateless junction fed held discrete signals ----------------
struct Counter <: AbstractComponent end
s_init(::Counter) = 0.0
y_types(::Counter) = Float64
y_state(::Counter, (; s)) = s
s_update(::Counter, (; s)) = s + 1.0
struct Watch <: AbstractComponent
    log::Vector{Tuple{Float64,Float64}}
end
x_init(::Watch) = (q = 0.0,)
u_types(::Watch) = Float64
y_types(::Watch) = (q = Float64,)
y_state(::Watch, (; x)) = (q = x.q,)
x_deriv(w::Watch, (; x, u, t)) = (u isa Float64 && push!(w.log, (Float64(t), u)); (q = one(x.q) * u,))
println("== 096 junction downstream of discrete counters")
let
    w = Watch(Tuple{Float64,Float64}[])
    m = Group((c1 = Counter(), c2 = Counter(), j = SumJunction{Float64, 2}(), w = w);
              local_wires = ("c1/y" => "j/in1", "c2/y" => "j/in2", "j/y" => "w/u"))
    sim = Simulation(m; Δt_frame = 1//10)
    init!(sim)
    empty!(w.log)
    step!(sim; frames = 3)
    say("096 (t, junction output) at x_deriv", [(round(t; digits = 3), u) for (t, u) in w.log])
end

# --- §13.8 tracer --------------------------------------------------------------------
const TABLE = (10.0, 20.0, 30.0)
struct IntLookup <: AbstractComponent end
x_init(::IntLookup) = nothing
u_types(::IntLookup) = (v = Float64,)
y_types(::IntLookup) = (F = Float64,)
y_direct(::IntLookup, (; u)) = (F = TABLE[clamp(round(Int, u.v), 1, 3)] + zero(u.v),)
struct LinInterp <: AbstractComponent end
x_init(::LinInterp) = nothing
u_types(::LinInterp) = (v = Float64,)
y_types(::LinInterp) = (F = Float64,)
function y_direct(::LinInterp, (; u))
    i = clamp(floor(Int, u.v), 1, 2)
    w = u.v - i
    (F = (1 - w) * TABLE[i] + w * TABLE[i + 1],)
end
struct CountPW <: AbstractComponent
    seen::Vector{Float64}
end
x_init(::CountPW) = nothing
u_types(::CountPW) = (v = Float64,)
y_types(::CountPW) = (F = Float64,)
y_direct(c::CountPW, (; u)) = (push!(c.seen, Float64(u.v.value)); (F = u.v > 0 ? u.v : 2u.v,))
struct CountLin <: AbstractComponent
    seen::Vector{Float64}
end
x_init(::CountLin) = nothing
u_types(::CountLin) = (v = Float64,)
y_types(::CountLin) = (F = Float64,)
y_direct(c::CountLin, (; u)) = (push!(c.seen, u.v isa Real && hasproperty(u.v, :value) ? u.v.value : Float64(u.v)); (F = 2u.v,))
struct Boom <: AbstractComponent end
x_init(::Boom) = nothing
u_types(::Boom) = (v = Float64,)
y_types(::Boom) = (F = Float64,)
y_direct(::Boom, (; u)) = error("boom")
loopwith(c) = Group((m = c, g = Gain(1.0)); local_wires = ("m/F" => "g/e", "g/out" => "m/v"))
cyc(c) = only(diagnostics(failure(() -> build(loopwith(c)))))
showcyc(label, d) = say(label, (d.classification, d.dead, d.traced))
println("== §13.8 tracer")
let
    showcyc("183/206 IntLookup", cyc(IntLookup()))
    showcyc("206 LinInterp", cyc(LinInterp()))
    pw = CountPW(Float64[]); showcyc("213 CountPW", cyc(pw))
    say("213 CountPW y_direct calls, v seen", (length(pw.seen), round.(pw.seen; digits = 3)))
    ln = CountLin(Float64[]); showcyc("213 CountLin", cyc(ln))
    say("213 CountLin y_direct calls, v seen", (length(ln.seen), ln.seen))
    d = cyc(Boom()); showcyc("223 Boom", d); say("223 Boom members/wires", (d.members, d.wires))
    showcyc("211 DiscreteMap pair", only(diagnostics(failure(() -> build(
        Group((p = DiscreteMap(), q = DiscreteMap()); local_wires = ("p/b" => "q/a", "q/b" => "p/a")))))))
    say("192 Tracer <: Real", (Redstone.Tracer{true} <: Real, Redstone.Tracer{false} <: Real))
end

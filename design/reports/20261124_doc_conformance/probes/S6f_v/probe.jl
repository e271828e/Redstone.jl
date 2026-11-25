# S6f verifier probes, run from the pinned worktree with --project=test.
using Test, BenchmarkTools; include(joinpath(pwd(), "test", "repl.jl")); include(joinpath(pwd(), "test", "utils.jl"))
import Redstone: flatten!, reconstruct, x_init, s_init, m_init, u_types, y_types, y_state,
    y_direct, x_deriv, s_update, build, diagnostics
using Test


say(tag, v) = println(tag, " => ", v)

# --- S6f-042: reconstruct(flatten(x)) bitwise, NaN and -0.0 included ---------
let v = (a = -0.0, b = SVector(NaN, 1.5, -2.0), c = SMatrix{2,2}(1.0, 2.0, 3.0, 4.0))
    P = typeof(v)
    buf = zeros(Float64, 1 + 3 + 4 + 2)
    flatten!(buf, 2, v)
    back = reconstruct(P, buf, 2)
    say("S6f-042 roundtrip ===", back === v)
    say("S6f-042 roundtrip ==", back == v)  # false under NaN, by IEEE
    vd = (q = SVector(ForwardDiff.Dual(1.0, 2.0), ForwardDiff.Dual(-0.0, 1.0)),)
    bd = similar(zeros(typeof(vd.q[1]), 2)); flatten!(bd, 0, vd)
    say("S6f-042 dual roundtrip ===", reconstruct(typeof(vd), bd, 0) === vd)
end

# --- components for the store and leaf probes -------------------------------
struct PStr <: AbstractComponent end
s_init(::PStr) = (label = "x",)
y_types(::PStr) = (n = Int,)
y_state(::PStr, (; s)) = (n = 1,)
s_update(::PStr, (; s)) = s

struct PSym <: AbstractComponent end
s_init(::PSym) = (label = :a, k = 0, nested = (p = 1, q = true))
y_types(::PSym) = (n = Int,)
y_state(::PSym, (; s)) = (n = s.k,)
s_update(::PSym, (; s)) = s

struct HoldsSym; tag::Symbol; end
struct PNestSym <: AbstractComponent end
s_init(::PNestSym) = (h = HoldsSym(:a),)
y_types(::PNestSym) = (n = Int,)
y_state(::PNestSym, (; s)) = (n = 1,)
s_update(::PNestSym, (; s)) = s

@enum Gear lo hi
struct PModes <: AbstractComponent end
x_init(::PModes) = (v = 0.0,)
m_init(::PModes) = (count = 0, on = false, gear = lo)
y_types(::PModes) = (y = Float64,)
y_state(::PModes, (; x)) = (y = x.v,)
x_deriv(::PModes, (; x)) = (v = 1.0,)

struct PIntX <: AbstractComponent end
x_init(::PIntX) = (n = 0, b = true)
y_types(::PIntX) = (y = Float64,)
y_state(::PIntX, (; x)) = (y = 0.0,)
x_deriv(::PIntX, (; x)) = (n = 0, b = false)

# S6f-051: an incomplete derivative return
struct PIncomplete <: AbstractComponent end
x_init(::PIncomplete) = (a = 0.0, b = SVector(0.0, 0.0))
y_types(::PIncomplete) = (y = Float64,)
y_state(::PIncomplete, (; x)) = (y = x.a,)
x_deriv(::PIncomplete, (; x)) = (a = 1.0,)

diag_of(e) = e isa DiagnosticError ? [typeof(d) for d in diagnostics(e)] : e
say("S6f-089 String field", diag_of(failure(() -> build(PStr()))))
say("S6f-089 Symbol+Int+nested isbits NT", let r = failure(() -> build(PSym())); r === nothing ? "built" : diag_of(r) end)
say("S6f-089 struct nesting Symbol", diag_of(failure(() -> build(PNestSym()))))
say("S6f-020 Int/Bool/enum modes", let r = failure(() -> build(PModes())); r === nothing ? "built" : diag_of(r) end)
let e = failure(() -> build(PIntX()))
    say("S6f-020 Int/Bool in x", e isa DiagnosticError ? [(d.name, d.reason) for d in diagnostics(e)] : e)
end

# S6f-051
let e = failure(() -> begin
        sim = Simulation(Group((; c = PIncomplete())); Δt_frame = 1//10)
        init!(sim, set()); step!(sim)
    end)
    say("S6f-051 incomplete xdot", e isa DiagnosticError ? [(typeof(d), getfield(d, :reason)) for d in diagnostics(e)] :
        (e === nothing ? "no error" : (typeof(e), sprint(showerror, e)[1:min(end, 300)])))
end

# S6f-033 / S6f-030 / S6f-001: X from x_init, flat Vector{T} buffer
let sim = Simulation(fed(Plant()); Δt_frame = 1//10)
    init!(sim, set(u = (in = 1.0,)))
    exec = sim.model.exec
    say("S6f-001/030 xbuf type", typeof(exec.xbuf))
    say("S6f-033 state type", (typeof(state(sim, "c")), typeof(x_init(Plant()))))
end

# S6f-107: a workspace is never a condition target
say("S6f-107 set(ws=...)", let e = failure(() -> set(ws = (a = 1.0,))); e === nothing ? "accepted" : typeof(e) end)

# S6f-007 / S6f-098: checkpoint fields and the store copy
say("S6f-007 ModelState fields", fieldnames(ModelState))
say("S6f-007 Checkpoint fields", fieldnames(Checkpoint))

# S6f-011: restore then continue is never stopping, under BS3 with events
let mk() = Simulation(fed(Plant()); Δt_frame = 1//10, h_min = 1//2^20, algorithm = BS3(reltol = 1e-8, abstol = 1e-10))
    a = failure(() -> begin
        sim = mk(); init!(sim, set(u = (in = 1.0,))); step!(sim; frames = 4)
        cp = checkpoint(sim)
        twin = mk(); restore!(twin, cp)
        step!(sim; frames = 6); step!(twin; frames = 6)
        say("S6f-011 BS3 identity", (state(sim, "c").q === state(twin, "c").q, state(sim, "c").q))
    end)
    a === nothing || say("S6f-011 BS3 err", sprint(showerror, a)[1:min(end, 400)])
end

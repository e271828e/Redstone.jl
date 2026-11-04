using Redstone, StaticArrays, LinearAlgebra, ForwardDiff
include(joinpath(@__DIR__, "..", "..", "..", "..", "test", "imports.jl"))
function attempt(label, f)
    try
        r = f()
        println("OK   ", label, " => ", repr(r)[1:min(end,200)])
    catch e
        s = sprint(showerror, e)
        println("THROW ", label, " => ", typeof(e), " :: ", first(split(s, '\n'))[1:min(end,220)])
        if e isa Redstone.DiagnosticError
            println("      kinds: ", [typeof(d) for d in e.carried])
        end
    end
end
# 1. Unpack wire
struct UW1 <: AbstractComponent; src; un; end
local_wires(::UW1) = ("src/y" => "un/u",)
struct UW2 <: AbstractComponent; src; un; end
local_wires(::UW2) = ("src/y" => "un",)
for T in (UW1, UW2)
    attempt("Unpack wire $T", () -> begin
        b = build(T(Constant(SVector(1.0,2.0)), Unpack{Float64,2}()))
        m = Model(b; h = 1//10)
        init!(m, set())
        (port(m, "un", :out1), port(m, "un", :out2))
    end)
end
# 10. τ / τd
struct LagW <: AbstractComponent; c; l; end
local_wires(::LagW) = ("c/y" => "l/u",)
for τ in (0.0, -1.0, 1.0)
    attempt("FirstOrderLag τ=$τ", () -> begin
        sim = Simulation(LagW(Constant(1.0), FirstOrderLag(τ = τ)); h = 1//10)
        init!(sim, set()); step!(sim; frames = 3)
        (lifecycle(sim), port(sim, "l", :y))
    end)
end
struct PW <: AbstractComponent; r; y; p; end
local_wires(::PW) = ("r/y" => "p/r", "y/y" => "p/y")
for (τd, Kd) in ((0.0, 0.0), (0.0, 1.0), (-1.0, 0.0), (-0.05, 1.0), (0.1, 1.0))
    attempt("PID τd=$τd Kd=$Kd", () -> begin
        sim = Simulation(PW(Constant(1.0), Constant(0.0), PID(Kp = 1.0, Kd = Kd, τd = τd)); h = 1//10)
        init!(sim, set()); step!(sim; frames = 3)
        (lifecycle(sim), port(sim, "p", :u_raw), state(sim, "p"))
    end)
end
# 11. modes / port / state
struct One <: AbstractComponent; c; end
local_wires(::One) = ()
let m = Model(One(Constant(1.0)); h = 1//10)
    init!(m, set())
    attempt("modes no-mode component", () -> modes(m, "c"))
    attempt("modes unknown path", () -> modes(m, "nope"))
    attempt("state no-state component", () -> state(m, "c"))
    attempt("state unknown path", () -> state(m, "nope"))
    attempt("port unknown path", () -> port(m, "nope"))
    attempt("port unknown name", () -> port(m, "c", :nope))
    attempt("port bare path", () -> port(m, "c"))
    attempt("port assembly no name", () -> port(m, ""))
    attempt("port root path with name", () -> port(m, "", :nope))
    sim = Simulation(Model(One(Constant(1.0)); h = 1//10))
    init!(sim, set())
    attempt("sim modes no-mode", () -> modes(sim, "c"))
    attempt("sim port unknown", () -> port(sim, "nope"))
    attempt("snapshot port unknown", () -> port(latest(sim), "nope"))
end
# 12
v = SVector(1.0, 2.0)
attempt("Step scalar+vec", () -> Step(t_step = 1.0, before = 0.0, after = v))
attempt("DLI scalar+vec", () -> DiscreteLimitedIntegrator(lower = -1.0, upper = v))
attempt("DLI s0 vec", () -> DiscreteLimitedIntegrator(lower = -1.0, upper = 1.0, s0 = v))
attempt("DLI two lengths", () -> DiscreteLimitedIntegrator(lower = SVector(-1.0), upper = v))
attempt("Relay scalar+vec", () -> Relay(lower = 0.0, upper = v))
attempt("Relay off/on", () -> Relay(lower = 0.0, upper = 1.0, off = v, on = v))
attempt("Comparator scalar+vec", () -> Comparator(lower = 0.0, upper = v))
attempt("Comparator two lengths", () -> Comparator(lower = SVector(0.0), upper = v))
attempt("LI scalar+vec", () -> LimitedIntegrator(lower = -1.0, upper = v))
attempt("TimeTable", () -> nothing)
attempt("RateLimiter vec rate", () -> RateLimiter(rising = v))
attempt("RateLimiter vec s0", () -> RateLimiter(rising = 1.0, s0 = v))
attempt("RateLimiter Inf", () -> RateLimiter(rising = Inf))
attempt("RateLimiter NaN", () -> RateLimiter(rising = NaN))

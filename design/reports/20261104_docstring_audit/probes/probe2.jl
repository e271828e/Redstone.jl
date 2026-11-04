using Redstone, StaticArrays, LinearAlgebra, ForwardDiff
include(joinpath(@__DIR__, "..", "..", "..", "..", "test", "imports.jl"))
function attempt(label, f)
    try
        r = f()
        println("OK   ", label, " => ", repr(r)[1:min(end,260)])
    catch e
        s = sprint(showerror, e)
        println("THROW ", label, " => ", typeof(e), " :: ", first(split(s, '\n'))[1:min(end,240)])
        if e isa Redstone.DiagnosticError
            println("      kinds: ", [typeof(d) for d in e.carried])
        end
    end
end
gather_try(sim, sel) = series(sim, reads(v = sel)).columns.v
struct One <: AbstractComponent; c; end
local_wires(::One) = ()
# 10
struct PW <: AbstractComponent; r; y; p; end
local_wires(::PW) = ("r/y" => "p/r", "y/y" => "p/y")
for (τd, Kd) in ((-1.0, 0.0), (-0.05, 1.0), (0.1, 1.0))
    attempt("PID y=1 τd=$τd Kd=$Kd", () -> begin
        sim = Simulation(PW(Constant(1.0), Constant(1.0), PID(Kp = 1.0, Kd = Kd, τd = τd, b = 1.0)); h = 1//10)
        init!(sim, set()); step!(sim; frames = 5)
        (lifecycle(sim), port(sim, "p", :u_raw), state(sim, "p"))
    end)
end
for (Tt) in (0.0, -1.0)
    attempt("PID Tt=$Tt", () -> begin
        sim = Simulation(PW(Constant(1.0), Constant(0.0), PID(Kp = 1.0, Tt = Tt, u_max = 0.5)); h = 1//10)
        init!(sim, set()); step!(sim; frames = 5)
        (lifecycle(sim), port(sim, "p", :u_raw), state(sim, "p"))
    end)
end
# 12
v = SVector(1.0, 2.0)
attempt("Step scalar+vec", () -> Step(t_step = 1.0, before = 0.0, after = v))
attempt("Step two lengths", () -> Step(t_step = 1.0, before = SVector(0.0), after = v))
attempt("DLI scalar+vec", () -> DiscreteLimitedIntegrator(lower = -1.0, upper = v))
attempt("DLI s0 vec", () -> DiscreteLimitedIntegrator(lower = -1.0, upper = 1.0, s0 = v))
attempt("DLI two lengths", () -> DiscreteLimitedIntegrator(lower = SVector(-1.0), upper = v))
attempt("Relay scalar+vec", () -> Relay(lower = 0.0, upper = v))
attempt("Relay off/on", () -> Relay(lower = 0.0, upper = 1.0, off = v, on = v))
attempt("Comparator scalar+vec", () -> Comparator(lower = 0.0, upper = v))
attempt("Comparator two lengths", () -> Comparator(lower = SVector(0.0), upper = v))
attempt("LI scalar+vec", () -> LimitedIntegrator(lower = -1.0, upper = v))
attempt("LI lengths", () -> LimitedIntegrator(lower = SVector(0.0), upper = v))
attempt("SteppedTable-ish Sequence", () -> Sequence(times = (1.0,), values = (0.0, v)))
attempt("RateLimiter vec rate", () -> RateLimiter(rising = v))
attempt("RateLimiter vec s0", () -> RateLimiter(rising = 1.0, s0 = v))
attempt("RateLimiter Inf", () -> RateLimiter(rising = Inf))
attempt("RateLimiter NaN", () -> RateLimiter(rising = NaN))
attempt("DiscreteTF kw", () -> DiscreteTransferFunction(num = (1.0,), den = (1.0, -0.5), u0 = 0.0))
attempt("DiscretizedTF kw", () -> DiscretizedTransferFunction(num = (1.0,), den = (1.0, 1.0), u0 = 0.0))
attempt("DSS kw", () -> DiscreteStateSpace(A = [0.5;;], B = [1.0;;], C = [1.0;;], s0 = 0.5))
attempt("DiscretizedSS kw", () -> DiscretizedStateSpace(A = [-1.0;;], B = [1.0;;], C = [1.0;;], x0 = 0.5))
# 8 LQR
struct LW <: AbstractComponent; x; z; zr; t; end
local_wires(::LW) = ("x/y" => "t/x", "z/y" => "t/z", "zr/y" => "t/z_ref")
kw = (K_fbk = SMatrix{1,1}(1.0), K_fwd = SMatrix{1,1}(1.0), K_int = SMatrix{1,1}(1.0))
mk(t) = LW(Constant(SVector(0.0)), Constant(SVector(0.0)), Constant(SVector(1.0)), t)
let sim = Simulation(mk(LQRTracker(; kw...)); h = 1//10)
    init!(sim, set()); step!(sim; frames = 2)
    attempt("LQR state", () -> state(sim, "t"))
    attempt("LQR get_state q", () -> gather_try(sim, get_state("t", :q)))
    attempt("LQR get_state x", () -> gather_try(sim, get_state("t", :x)))
    attempt("LQR get_state bare", () -> gather_try(sim, get_state("t")))
    attempt("LQR set q", () -> (sim2 = Simulation(mk(LQRTracker(; kw...)); h = 1//10); init!(sim2, at("t", set(x = (q = SVector(1.0),)))); state(sim2, "t")))
    attempt("LQR set bare", () -> (sim2 = Simulation(mk(LQRTracker(; kw...)); h = 1//10); init!(sim2, at("t", set(x = SVector(1.0)))); state(sim2, "t")))
end
let sim = Simulation(mk(DiscreteLQRTracker(; kw...)); h = 1//10)
    init!(sim, set()); step!(sim; frames = 2)
    attempt("DLQR state", () -> state(sim, "t"))
    attempt("DLQR get_state q", () -> gather_try(sim, get_state("t", :q)))
end
# 6/7 trace
mutable struct Dev <: AbstractDevice end
struct Bnd <: AbstractBinding end
Redstone.is_input(::Bnd) = true
Redstone.claims(::Bnd) = ("a",)
Redstone.loop(::Dev, h) = nothing
struct Src2 <: AbstractComponent end
x_init(::Src2) = nothing
u_types(::Src2) = (a = Float64, b = Float64)
y_types(::Src2) = Float64
y_direct(::Src2, (; u)) = u.a + u.b
let sim = Simulation(Src2(); h = 1//10)
    init!(sim, set(u = (a = 1.0, b = 2.0)))
    println("schemas after init: ", trace(sim).schemas)
    stage!(sim, "a" => 3.0)
    step!(sim; frames = 5)
    t = trace(sim)
    println("frames=", t.frames, " batches=", [(b.frame, b.writer) for b in t.batches])
    attempt("attach", () -> attach!(sim, Dev(), Bnd()))
    println("schemas after attach: ", trace(sim).schemas)
end

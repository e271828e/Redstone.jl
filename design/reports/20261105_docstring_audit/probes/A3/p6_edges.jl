module P6
include("design/reports/20261105_docstring_audit/probes/A3/common.jl")
struct IntMine <: AbstractComponent end
m_init(::IntMine) = (blown = false,)
x_init(::IntMine) = nothing
u_types(::IntMine) = (sig = Bool,)
y_types(::IntMine) = (blown = Bool,)
y_state(::IntMine, (; m)) = (blown = m.blown,)
intmine_guard(::IntMine, (; u)) = u.sig
intmine_handler(::IntMine, (; u, m)) = u.sig ? throw(InterruptException()) : (m = (blown = true,),)
state_events(::IntMine) = (blow = StateEvent(intmine_guard, intmine_handler),)
println("--- interrupt inside boundary zero and the settling")
s = Simulation(fed(IntMine(), "sig"); h = 1//10)
e = failure(() -> init!(s, set(u = (in = true,))))
println("boundary zero: thrown ", typeof(e), " life=", lifecycle(s))
s = Simulation(fed(IntMine(), "sig"); h = 1//10); init!(s, set(u = (in = false,))); step!(s)
e = failure(() -> overlay!(s, set(u = (in = true,))))
println("settling: thrown ", typeof(e), " life=", lifecycle(s))
println("--- LoopError cause under the species rule")
struct NaNny <: AbstractComponent end
x_init(::NaNny) = (q = 0.0,)
u_types(::NaNny) = (arm = Bool,)
y_types(::NaNny) = (q = Float64,)
y_state(::NaNny, (; x)) = (q = x.q,)
x_deriv(::NaNny, (; u)) = (q = u.arm ? NaN : 1.0,)
d = Simulation(fed(NaNny(), "arm"); h = 1//10); init!(d, set(u = (in = false,))); stage!(d, "in" => true)
e = failure(() -> step!(d; frames = 2))
println("thrown ", typeof(e), " cause type=", typeof(e.cause), " is an exception? ", e.cause isa Exception, " life=", lifecycle(d))
println("--- Simulation grid and algorithm refusals")
r() = single(Sawtooth(0.1))
tryit("algorithm=3", () -> Simulation(r(); h = 1//10, algorithm = 3))
tryit("localization_tol=-1", () -> Simulation(r(); h = 1//10, localization_tol = -1.0))
tryit("localization_budget=0", () -> Simulation(r(); h = 1//10, localization_budget = 0))
tryit("h=-1", () -> Simulation(r(); h = -1//10))
tryit("N_base=0", () -> Simulation(r(); h = 1//10, N_base = 0))
tryit("N_base and Δt_base", () -> Simulation(r(); h = 1//10, N_base = 2, Δt_base = 1//5))
println("--- t0 extremes")
for t0 in (1e30, 1e32, 1e33, 1e34)
    s = Simulation(r(); h = 1//10)
    tryit("t0=$t0", () -> init!(s; t0))
    println("   life=", lifecycle(s), " header set=", s.run.trace.header !== nothing)
end
s = Simulation(r(); h = 1//10); failure(() -> init!(s; t0 = NaN))
println("after t0=NaN: life=", lifecycle(s), " termination=", termination(s), " latest.t=", latest(s).t)
tryit("trace after t0=NaN", () -> trace(s))
tryit("checkpoint after t0=NaN", () -> checkpoint(s))
tryit("step! after t0=NaN", () -> step!(s))
s = Simulation(r(); h = 1//10); init!(s; t0 = Inf); println("t0=Inf: latest.t=", latest(s).t)
tryit("checkpoint after t0=Inf", () -> checkpoint(s) isa Checkpoint)
tryit("step! after t0=Inf", () -> step!(s))
println("--- oversized recording keywords")
g() = (x = Simulation(fed(Gain(2.0), "e"); h = 1//10); init!(x, set(u = (in = 1.0,))); stage!(x, "in" => 3.0); x)
big30 = big(10)^30
for (lab, f) in ("init! log_max" => x -> init!(x, set(u = (in = 1.0,)); log_max = big30),
                 "overlay! log_every" => x -> overlay!(x; log_every = big30),
                 "overlay! log_max" => x -> overlay!(x; log_max = big30),
                 "restore! log_every" => x -> restore!(x, checkpoint(x); log_every = big30),
                 "restore! log_max" => x -> restore!(x, checkpoint(x); log_max = big30))
    x = g(); r0 = x.run
    tryit(lab, () -> f(x))
    println("   same run=", x.run === r0, " batch ", x.plane.harness.cell.pending === nothing ? "dropped" : "kept")
end
end

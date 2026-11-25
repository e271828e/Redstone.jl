# K7b verifier probes, run from the pinned worktree with --project=test.
module K7bProbe
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const T = joinpath(pwd(), "test")
include(joinpath(T, "imports.jl"))
include(joinpath(T, "fixtures.jl"))
include(joinpath(T, "utils.jl"))

say(tag, v) = println(rpad(tag, 10), " ", v)
tryit(f) = try f() catch e; e end

# --- the rest reading on a unit-step counter (TickCounter: y = s.n, s+ = n+1)
sim = Simulation(single(TickCounter()); Δt_frame = 1//10)
init!(sim)
step!(sim; frames = 3)
say("P013", (cell = port(sim, "c", :n), store = state(sim, "c").n))          # y_k from s_k, store s_{k+1}
cp = checkpoint(sim)
say("P035", (cp_s = cp.state.s, cp_t = cp.state.t, prior = cp.state.prior))   # store as is
twin = Simulation(single(TickCounter()); Δt_frame = 1//10)
restore!(twin, cp)
say("P044", (cell = port(twin, "c", :n), store = state(twin, "c").n, t = latest(twin).t))
step!(twin); step!(sim)
say("P044b", (twin_next = port(twin, "c", :n), recorded_next = port(sim, "c", :n)))

# --- the copy into a condition at t_k: boundary zero runs inside init!
s_copied = state(twin, "c")          # n = 5 after the extra step; use the k=3 value instead
copy3 = cp.state.s[findfirst(!isnothing, cp.state.s)]
fresh = Simulation(single(TickCounter()); Δt_frame = 1//10)
init!(fresh, at("c", set(s = copy3)); t0 = 3//10)
say("P004", (bz_cell = port(fresh, "c", :n), recorded_at_tk = 3, logged_before_step = length(logged(fresh)), t = latest(fresh).t))
step!(fresh)
say("P064", (after_step_t = latest(fresh).t, cell = port(fresh, "c", :n)))
say("P063", typeof(tryit(() -> init!(Model(single(TickCounter()); Δt_frame = 1//10), at("c", set(s = copy3)), 0.3))))
say("P063b", hasmethod(init!, Tuple{Model, Any, Any}))

# --- the guard already holding fires at t0 under init!
g = Simulation(fed(Trigger(0.5), "sig"); Δt_frame = 1//10)
init!(g, set(u = (in = 1.0,)))
say("P075", modes(g, "c"))

# --- overlay: clock, snapshot, continuous refreshed, discrete held
lp = Simulation(SampledLoop(; ctl_rate = Relative(2)); Δt_frame = 1//200, Δt_base = 1//100)
init!(lp, set(u = (ref = 0.7,)))
step!(lp; frames = 6)
t_before = lp.model.exec.clock.t; t0_before = lp.model.exec.clock.t₀
n_before = length(logged(lp)); held = port(lp, "ctl", :u); y_before = port(lp, "plant", :y)
overlay!(lp, at("plant", set(x = (q = SVector(1.0, 0.0),))))
say("P164", (t_same = lp.model.exec.clock.t == t_before, t0_same = lp.model.exec.clock.t₀ == t0_before))
say("P256", (run_log_len = length(logged(lp)), snap_t = latest(lp).t, t = t_before,
             ctl_held = port(lp, "ctl", :u) === held, plant_y = (before = y_before, after = port(lp, "plant", :y))))

# --- overlay diagnostics as init!'s
say("P154o", map(typeof, diagnostics(tryit(() -> overlay!(sim, at("nope", set(s = (n = 1,))))))))
s2 = Simulation(single(TickCounter()); Δt_frame = 1//10)
say("P154i", map(typeof, diagnostics(tryit(() -> init!(s2, at("nope", set(s = (n = 1,))))))))

# --- restore! takes no overlay; restore! then overlay! works
say("P247", hasmethod(restore!, Tuple{Simulation, Checkpoint, Any}))
r = Simulation(single(TickCounter()); Δt_frame = 1//10)
restore!(r, cp); overlay!(r, at("c", set(s = (n = 10,))))
say("P247b", (cell = port(r, "c", :n), store = state(r, "c").n))

# --- the lifecycle gates on a built simulation
b1 = Simulation(single(TickCounter()); Δt_frame = 1//10)
e = tryit(() -> overlay!(b1, set()))
say("P220o", e isa DiagnosticError ? (typeof(e), e.carried.status, e.carried.legal) : e)
b2 = Simulation(single(TickCounter()); Δt_frame = 1//10)
say("P220r", tryit(() -> restore!(b2, cp)))
say("P220r2", lifecycle(b2))
end

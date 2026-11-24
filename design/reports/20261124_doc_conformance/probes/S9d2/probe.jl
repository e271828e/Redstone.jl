# S9d2 probe: spec §9.7–§9.8 (lines 6059–6440). Read-only.
include(joinpath(pwd(), "test", "RedstoneTests.jl"))
using .RedstoneTests
const RT = RedstoneTests
using Redstone, BenchmarkTools, StaticArrays
include(joinpath(pwd(), "test", "imports.jl"))
const R = Redstone
p(tag, x) = println(tag, " => ", x)

# 1. The spec's code blocks: phase_bodies(sim), then @ballocated(body()) == 0.
sim = Simulation(RT.feedback_model(); Δt_frame = 1//100)
bodies = phase_bodies(sim)
p("P1 keys", keys(bodies))
p("P1 same as exec.bodies", bodies === sim.model.exec.bodies)
for name in (:sweep_1, :sweep_2, :rhs, :ticks)
    body = bodies[name]; body(); body(0)
    p("P1 alloc $name () / (1)", (@ballocated($body()), @ballocated($body(1))))
end

# 2. A model with no continuous state and no events still gets every body.
cnt = Simulation(Group((; c1 = RT.TickCounter(), c2 = RT.TickCounter()));
                 Δt_frame = 1//10)
cb = phase_bodies(cnt)
p("P2 keys", keys(cb))
p("P2 events/projections empty", (isempty(cb.events), isempty(cb.projections)))
for name in (:sweep_1, :sweep_2, :rhs, :ticks)
    body = cb[name]; body(); body(0)
    p("P2 alloc $name", (@ballocated($body()), @ballocated($body(1))))
end
p("P2 rhs chunks (interior, boundary)", (length(cb.rhs.interior), length(cb.rhs.boundary)))
p("P2 ticks interior chunks", length(cb.ticks.interior))

# 3. Interior holds no discrete entries; boundary gates them; one gate across blocks.
gates(body) = [(e.D, e.Φ, e.entry.path) for c in body.boundary for e in c.entries if e isa R.Gated]
interior_gated(body) = count(e isa R.Gated for c in body.interior for e in c.entries)
p("P3 interior gated counts", [interior_gated(cb[n]) for n in (:sweep_1, :sweep_2, :rhs, :ticks)])
p("P3 sweep_1 gates", gates(cb.sweep_1))
p("P3 ticks gates", gates(cb.ticks))
p("P3 Chunk mutable / EventSet mutable", (ismutable(first(cb.ticks.boundary)), ismutable(cnt.model.exec.events)))
p("P3 Executor isa immutable struct", !ismutable(cnt.model.exec))

# 4. Invoking a tick body in isolation advances discrete state with no clock advance.
init!(cnt)
t_before, s_before = cnt.model.exec.clock.t, state(cnt, "c1")
cb.ticks(0)
p("P4 clock before/after", (t_before, cnt.model.exec.clock.t))
p("P4 state before/after", (s_before, state(cnt, "c1")))

# 5. The rhs body has no gated entry, so its two tuples share one type.
p("P5 rhs PhaseBody{I,I}", fieldtype(typeof(bodies.rhs), :interior) === fieldtype(typeof(bodies.rhs), :boundary))

# 6. Stage-2 walks outputs.order; stage-1 walks component order.
b = sim.model.deployment.build
order_paths = [b.outputs.components[ci].path for ci in b.outputs.order]
s2_paths = [e.path for c in bodies.sweep_2.boundary for e in c.entries]
p("P6 order paths", order_paths)
p("P6 sweep_2 paths", s2_paths)

# 7. Default chunk size and Dual model bodies.
p("P7 default chunk_size", sim.model.exec.chunk_size)
dm = Model(build(RT.feedback_model()), R.LinearizeDual; Δt_frame = 1//100)
p("P7 dual events empty", isempty(phase_bodies(dm).events))
p("P7 Simulation of dual model", try Simulation(dm); "accepted" catch e; typeof(e) end)

# 8. CellAddr: one offset per leaf eltype, port type as parameter.
ad = first(values(sim.model.exec.act.layout.addr))
p("P8 CellAddr type", typeof(ad))
p("P8 store keys", keys(sim.model.exec.store.stores))

# 9. Interior variants at t*: run_boundary!(model, nothing) skips ticks.
p("P9 run_ticks! nothing", R.run_ticks!(cnt.model, nothing))

# 10. A handle eltype's block in the snapshot capture: allocations per capture.
hs = Simulation(RT.handle_model(); Δt_frame = 1//10)
init!(hs)
fs = Simulation(Group((; a = RT.TickCounter())); Δt_frame = 1//10)
R.capture_stores(hs.model.exec.store); R.capture_stores(sim.model.exec.store)
p("P10 store keys handle / plain", (keys(hs.model.exec.store.stores), keys(sim.model.exec.store.stores)))
p("P10 capture allocations handle / plain",
  (@allocations(R.capture_stores(hs.model.exec.store)), @allocations(R.capture_stores(sim.model.exec.store))))
p("P10 capture bytes handle / plain",
  (@allocated(R.capture_stores(hs.model.exec.store)), @allocated(R.capture_stores(sim.model.exec.store))))
cap = R.capture_stores(hs.model.exec.store)
hk = R._cell_key(RT.HeightField)
p("P10 bulk shared after capture", getfield(cap.stores, hk).buffer[1].z === getfield(hs.model.exec.store.stores, hk).buffer[1].z)

# 11. Optimization level: the trajectory, for comparison across -O levels.
p("P11 optlevel", Base.JLOptions().opt_level)
traj = Simulation(RT.feedback_model(); Δt_frame = 1//100)
init!(traj, set(u = (ref = 0.5,)))
run!(traj; t_end = 1.0)
p("P11 xbuf", repr(traj.model.exec.xbuf))

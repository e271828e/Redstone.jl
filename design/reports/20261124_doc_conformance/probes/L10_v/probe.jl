# L10 verifier probes, run from the pinned worktree with --project=test.
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl")); include(joinpath(W, "fixtures.jl")); include(joinpath(W, "utils.jl"))
include(joinpath(W, "test_stepper.jl")); include(joinpath(W, "test_adaptive.jl"))
try_kind(f) = try f(); "ok" catch e; e isa DiagnosticError ? string(typeof.(e.carried)) : string(typeof(e)) end
P(tag, v) = println(tag, " => ", v)

# L10-102 / L10-044: ordinal 0 at boundary zero; wait counter separate and never reset
sim = Simulation(seam_rig(); Δt_frame = 1//8, Δt_base = 1//32)
init!(sim, set(u = (ref = 0.7,)))
P("L10-102 boundary zero ordinal", latest(sim).boundary)
step!(sim; frames = 2)
c1 = sim.control.counter; b1 = latest(sim).boundary
init!(sim, set(u = (ref = 0.7,)))
P("L10-044 after re-init: counter, boundary (before: $c1, $b1)", (sim.control.counter, latest(sim).boundary))

# L10-111: step! takes no pace/margin keyword
P("L10-111 step!(; pace)", try_kind(() -> step!(sim; pace = 2.0)))
# L10-071/072: margin default and its knob
P("L10-071 margin default", margin(Simulation(seam_rig(); Δt_frame = 1//8, Δt_base = 1//32)))
margin!(sim, 0.005); P("L10-072 margin! sets", margin(sim))
# L10-068: join_timeout is a keyword
P("L10-068 join_timeout kw", Simulation(seam_rig(); Δt_frame = 1//8, Δt_base = 1//32, join_timeout = 1.5).control.join_timeout)
# L10-062: event_budget vs localization_budget
P("L10-062 event_budget kw", try_kind(() -> Simulation(seam_rig(); Δt_frame = 1//8, Δt_base = 1//32, event_budget = 3)))
P("L10-062 localization_budget kw", Simulation(seam_rig(); Δt_frame = 1//8, Δt_base = 1//32, localization_budget = 3).model.deployment.localization_budget)
# L10-060: default tol
P("L10-060 localization_tol default", sim.model.deployment.localization_tol)
# L10-033: capture retired
P("L10-033 isdefined capture", isdefined(Redstone, :capture))
# L10-055: stop_on keyword
P("L10-055 run!(; stop_on)", try_kind(() -> run!(sim; stop_on = s -> true)))
# L10-084: phase_bodies keys
P("L10-084 phase_bodies keys", keys(phase_bodies(sim)))
P("L10-084 no-discrete keys", keys(phase_bodies(Simulation(Group((; e = Expo(-1.0))); Δt_frame = 1//8))))
# L10-126 / L10-130: Checkpoint type and trace header
cp = checkpoint(sim)
P("L10-126 Checkpoint parametric?", (Checkpoint isa UnionAll, typeof(cp), typeof(cp.state)))
P("L10-130 header type", typeof(trace(sim).header))

# L10-140: restore runs no sweep, no update, no guard
step!(sim; frames = 3); cp = checkpoint(sim)
twin = Simulation(seam_rig(); Δt_frame = 1//8, Δt_base = 1//32)
idx0 = twin.model.exec.cursor.index
restore!(twin, cp)
P("L10-140 cursor index before/after restore", (idx0, twin.model.exec.cursor.index))
P("L10-140 snapshots published", length(logged(twin)))
P("L10-140 counter n kept", (state(twin, "a").n, state(sim, "a").n))

# L10-028: boundary zero, offset component's update does not run; its output publishes
late = Group((; c0 = TickCounter(), c1 = TickCounter()); sample_times = (; c1 = Relative(2, 1)))
s0 = Simulation(late; Δt_frame = 1//100)
init!(s0)
P("L10-028 n after boundary zero (Φ=0, Φ=1)", (state(s0, "c0").n, state(s0, "c1").n))
P("L10-028 published n (Φ=0, Φ=1)", (port(latest(s0), "c0", :n), port(latest(s0), "c1", :n)))

# L10-218: BS3 tolerances
for (r, a) in ((0.0, 1e-6), (-1.0, 1e-6), (NaN, 1e-6), (1e-3, Inf), (1e-3, 0.0))
    P("L10-218 BS3($r, $a)", try_kind(() -> BS3(reltol = r, abstol = a)))
end
P("L10-218 BS3(reltol = \"x\")", try_kind(() -> BS3(reltol = "x")))

# L10-227: a notice clears history and keeps the proposal
st = bind_stepper(BS3(), Float64, 1); st.proposal = 0.125; st.memory = 0.5
discontinuity!(st)
P("L10-227 after notice (proposal, memory)", (st.proposal, st.memory))

# L10-236: rejection of the first attempt proposes at most the starting bound
ex = Simulation(Group((; e = Expo(10.0))); Δt_frame = 1, h_min = 1//2^20, algorithm = Watched(BS3()))
init!(ex); step!(ex)
a1 = ex.model.exec.stepper.attempts[1]
P("L10-236 first attempt (h, accepted, proposal after)", (a1[2], a1[3], a1[6]))
P("L10-236 expected starting bound", 1 / (10 / 1 / (0.8 * cbrt(1e-3))))

# L10-188: after the budget's last rejection the next attempt is the floor's, not the proposal
cl = Simulation(Group((; c = Cliff())); Δt_frame = 1, h_min = 1//4, algorithm = Watched(BS3()), attempt_budget = 1)
init!(cl); try step!(cl) catch e; P("L10-188 cliff step error", typeof(e)) end
P("L10-188 cliff attempts (t, h, ok, proposal)", [(a[1], a[2], a[3], a[6]) for a in cl.model.exec.stepper.attempts[1:min(4, end)]])

# S12d independent verifier probes. Run from the pinned worktree W:
#   JULIA_LOAD_PATH="@" julia --startup-file=no --project=test <this file>
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const T = joinpath(pwd(), "test")
include(joinpath(T, "imports.jl"))
include(joinpath(T, "fixtures.jl"))
include(joinpath(T, "utils.jl"))
include(joinpath(T, "test_trace.jl"))

say(id, x) = println(id, " | ", x)
kind(f) = try f(); "no throw" catch e
    e isa DiagnosticError ? join(["$(typeof(d)) $(d isa CheckpointMismatch ? (d.what, d.name) :
                                   d isa ArgumentInvalid ? (d.argument, d.reason) : "")"
                                  for d in (e isa DiagnosticError{Vector{Diagnostic}} ? diagnostics(e) : [diagnostic(e)])], "; ") : "raw $(typeof(e))"
end

# --- S12d-002: full replay restores the header, re-drives every frame -------
(sim, trc) = recorded_run()
sim2 = replay_twin()
replay!(sim2, trc)
say("P002", (frame = sim2.run.frame, frames = trc.frames,
             same = same_trajectory(logged(sim2), logged(sim)),
             first_t = first(logged(sim2)).t, header_t0 = trc.header.state.t₀,
             batches_equal = trace(sim2).batches == trc.batches,
             lifecycle = lifecycle(sim2), mode = mode(sim2)))

# --- S12d-001 / 011: the replay drain takes the cell and discards it --------
(sim, trc) = recorded_run()
sim2 = replay_twin()
replay!(sim2, trc; to_boundary = 2)
stage!(sim2, "ref" => 99.0)
before = (@atomic sim2.plane.harness.cell.pending) !== nothing
step!(sim2)            # frame 3's top under :replay
after = (@atomic sim2.plane.harness.cell.pending) !== nothing
seen = [d for s in logged(sim2) for w in s.status.writers
          if w.who == "harness" for d in w.recent if d isa ReplayDiscardedStaging]
say("P001", (pending_before = before, pending_after_frame_top = after,
             ref = port(sim2, "", :ref), discards = [(d.faces, d.frame) for d in seen]))
# 011: ordinal keying. Recording batches at frames 1 and 4 (ref, rate).
say("P011a", [(b.frame, b.writer, b.entries) for b in trc.batches])
sim3 = replay_twin()
replay!(sim3, trc; to_boundary = 3)
r3 = port(sim3, "", :rate)
step!(sim3)
r4 = port(sim3, "", :rate)
say("P011b", (rate_at_3 = r3, rate_at_4 = r4, ref_at_4 = port(sim3, "", :ref)))

# --- S12d-020: the feed starts at the header's frame / the sim's own --------
src = Simulation(replay_model(); Δt_frame = 1//10)
init!(src, set(u = (ref = 1.0, rate = 0.0)))
stage!(src, "ref" => 2.0); step!(src; frames = 3)
cp3 = checkpoint(src)
stage!(src, "rate" => 1.0); step!(src; frames = 5)
full = trace(src)                                   # header frame 0, frames 8
re = Simulation(replay_model(); Δt_frame = 1//10)
restore!(re, cp3)
step!(re; frames = 5)
late = trace(re)                                    # header frame 3, frames 8
say("P020a", (late_header = late.header.frame, late_frames = late.frames))
say("P020b default below header", kind(() -> replay!(replay_twin(), late; to_boundary = 2)))
t = replay_twin(); replay!(t, late; to_boundary = 3)
say("P020c default at header", (t.run.frame, mode(t)))
w = replay_twin(); restore!(w, cp3)
say("P020d rf below sim", kind(() -> replay!(w, full; restore = false, to_boundary = 2)))
w = replay_twin(); restore!(w, cp3)
replay!(w, full; restore = false, to_boundary = 3)
say("P020e rf at sim", (w.run.frame, mode(w)))
w = replay_twin(); restore!(w, cp3)
replay!(w, full; restore = false)
say("P020f rf full", (w.run.frame, same_trajectory(logged(w)[2:end],
                                     [s for s in logged(src) if s.frame > 3])))

# --- S12d-029: to_time validation, before any write -------------------------
(sim, trc) = recorded_run()
for bad in ("1", Inf, NaN, -0.1, 100.0, 0.85, 1 + 0im)
    tw = replay_twin()
    run0, frame0 = tw.run, tw.run.frame
    r = kind(() -> replay!(tw, trc; to_time = bad))
    say("P029 $(repr(bad))", (r, same_run = tw.run === run0, frame = tw.run.frame == frame0,
                               mode = mode(tw)))
end
tw = replay_twin(); replay!(tw, trc; to_time = 0.8)
say("P029 0.8 ok", tw.run.frame)
# restore = false: to_time below the sim's own frame
w = replay_twin(); restore!(w, cp3)
say("P029 rf before sim frame", kind(() -> replay!(w, full; restore = false, to_time = 0.1)))

# --- S12d-038: live! refusals ---------------------------------------------
lv = replay_twin()
say("P038 live", kind(() -> live!(lv)))
say("P038 built", kind(() -> live!(Simulation(replay_model(); Δt_frame = 1//10))))
st = replay_twin(); run!(st; t_end = 0.2)
say("P038 stopped", kind(() -> live!(st)))

# --- S12d-049: the halt's take, step! and run! exits -------------------------
(sim, trc) = recorded_run()
s5 = replay_twin()
replay!(s5, trc; to_boundary = 5)
# step! that halts initialized in :replay: stage after return? not a late stage;
# use run! exit with ExitNudge as in the suite.
h = attach!(s5, ExitNudge("rate", 99.0), Enumerated("rate"))
logs, _ = Test.collect_test_logs() do
    run!(s5; t_end = 5.0)
end
say("P049 run! exit", (mode = mode(s5), pending = pending(h, 1) === nothing,
                       reports = length(discard_reports(s5, logs, "device 1 (ExitNudge)"))))

# --- S12d-067: algorithm compared as a value, named by field ----------------
rec = Simulation(replay_model(); Δt_frame = 1//10, algorithm = BS3(; reltol = 1e-3), h_min = 1//10^6)
init!(rec, set(u = (ref = 1.0, rate = 0.0))); step!(rec; frames = 2)
rt = trace(rec)
a1 = Simulation(replay_model(); Δt_frame = 1//10, algorithm = BS3(; reltol = 1e-4, abstol = 1e-7), h_min = 1//10^6)
init!(a1, set(u = (ref = 0.0, rate = 0.0)))
say("P067 same type", kind(() -> replay!(a1, rt)))
a2 = Simulation(replay_model(); Δt_frame = 1//10, algorithm = Heun())
init!(a2, set(u = (ref = 0.0, rate = 0.0)))
(_, rk) = recorded_run()
say("P067 other type", kind(() -> replay!(a2, rk)))

# --- S12d-076: restore = false off origin / off frame ------------------------
(sim, trc) = recorded_run()
o = Simulation(replay_model(); Δt_frame = 1//10)
init!(o, set(u = (ref = 0.0, rate = 0.0)); t0 = 0.5)
run0 = o.run
say("P076 off origin", (kind(() -> replay!(o, trc; restore = false)), o.run === run0))
f = replay_twin(); step!(f; frames = 8); run0 = f.run
say("P076 off frame", (kind(() -> replay!(f, trc; restore = false)), f.run === run0,
                       f.run.frame))
say("P076 built", kind(() -> replay!(Simulation(replay_model(); Δt_frame = 1//10), trc;
                                     restore = false)))

# S10a independent verification probes. Run from the pinned worktree with --project=test.
include(joinpath(pwd(), "test", "RedstoneTests.jl"))
@eval RedstoneTests begin
pr(tag, x) = println(tag, " => ", repr(x))

struct WroteHooks <: FrameHooks end
frame_top!(::WroteHooks) = true
settled!(::WroteHooks) = false

# P037: under a proposing backend the steps of one span are not equal
m = Model(single(BareRamp()); Δt_frame = 1//8, h_min = 1//2^20, algorithm = Scheduled(0.05; rejected = (2,), factor = 0.5))
init!(m); frame!(m, 1)
pr("P037 scheduled accepted lengths, frame 1 (one span)", m.exec.stepper.lengths)
k = Model(single(Kepler()); Δt_frame = 1, h_min = 1//2^20, algorithm = Watched(BS3()))
init!(k); frame!(k, 1)
acc = [a[2] for a in k.exec.stepper.attempts if a[3]]
pr("P037 BS3 Kepler accepted lengths frame 1 (first 6)", acc[1:min(6, end)])
pr("P037 BS3 all equal?", all(==(acc[1]), acc))

# P064: shaped step longer than the clamped proposal near the floor
m = Model(single(BareRamp()); Δt_frame = 1//8, h_min = 1//20, algorithm = Scheduled(0.055))
init!(m); frame!(m, 1)
pr("P064 proposal 0.055, h_min 0.05, lengths", m.exec.stepper.lengths)
pr("P064 _shaped(0.055, 0, 0.125)", _shaped(m, 0.055, 0.0, 0.125))

# P073: NaN proposal refused
try
    _shaped(m, NaN, 0.0, 0.125); pr("P073", "no throw")
catch e
    pr("P073 NaN refusal", typeof(e))
end
pr("P073 Inf proposal shaped", _shaped(m, Inf, 0.0, 0.125))

# P100: floor above half the bound refused
for hmin in (1//150, 1//200)
    try
        Deployment(build(single(BareRamp())); Δt_frame = 1//8, h_max = 1//100, h_min = hmin, algorithm = BS3())
        pr("P100 h_min=$hmin", "accepted")
    catch e
        pr("P100 h_min=$hmin", e isa DiagnosticError ? e.carried : e)
    end
end

# P109: nonfinite trial accepted at the floor throws NonfiniteState
sim = Simulation(single(Cliff()); Δt_frame = 2, h_min = 1//1000, algorithm = Watched())
init!(sim)
err = try run!(sim; t_end = 4.0); nothing catch e; e end
pr("P109 error type", typeof(err))
pr("P109 last attempt (t,h,accepted)", sim.model.exec.stepper.attempts[end][1:3])

# P118/P127: notices at init!, at a quiet frame top, at a frame top whose hook wrote
m = Model(single(BareRamp()); Δt_frame = 1//8, h_min = 1//2^20, algorithm = Scheduled(1.0))
init!(m)
pr("P118 notices after init! (attempt counts)", copy(m.exec.stepper.notices))
frame!(m, 1)
pr("P127 notices after quiet frame 1", copy(m.exec.stepper.notices))
frame!(m, 2, WroteHooks())
pr("P127 notices after frame 2 whose hook wrote", copy(m.exec.stepper.notices))

# P136/P145: an empty-state model builds, ticks and sweeps under any backend
for alg in (RK4(), BS3())
    s = Simulation(Group((; a = TickCounter())); Δt_frame = 1//10, h_min = 1//1000, algorithm = alg)
    init!(s); step!(s; frames = 3)
    pr("P145 empty x, $(alg): xbuf empty, state, t", (isempty(s.model.exec.xbuf), state(s, "a"), s.model.exec.clock.t))
end

# P217: fresh-table derivative equals the sweep's to the bit
m = Model(seam_rig(); Δt_frame = 1//8, Δt_base = 1//32)
init!(m, set(u = (ref = 0.7,)))
for k in 0:2
    k > 0 && frame!(m, k)
    m.fresh = true; Redstone.evaluate!(m); a = copy(m.exec.ẋbuf)
    Redstone.evaluate!(m.exec); b = copy(m.exec.ẋbuf)
    pr("P217 after frame $k fresh === swept", (a, all(map(===, a, b))))
end

# P001/P181: a fixed-step frame takes the fewest equal steps h_max allows
m = Model(single(BareRamp()); Δt_frame = 1//8, h_max = 1//20)
init!(m)
hk = RecordingHooks(m, 0, Float64[], false)
frame!(m, 1, hk)
pr("P181 RK4 boundaries frame 1, h_max 1/20 (expect 3 equal steps)", hk.boundaries)
end

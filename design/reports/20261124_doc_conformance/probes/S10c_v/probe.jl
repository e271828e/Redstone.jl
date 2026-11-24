module Probe
using Test, StaticArrays, LinearAlgebra, ForwardDiff
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
include(joinpath(W, "test", "imports.jl"))
include(joinpath(W, "test", "fixtures.jl"))
include(joinpath(W, "test", "utils.jl"))
const R = Redstone

println("== P1 boundary sweep body signatures (S10c-019, -010)")
m = Model(Group((; saw = Sawtooth(0.3), ctl = DiscreteAccumulator(1.0)); local_wires = ("saw/q" => "ctl/e",)); Δt_frame = 1//10)
b = m.exec.bodies
for k in (:sweep_1, :sweep_2, :rhs, :ticks)
    body = getfield(b, k)
    println("  ", k, ": interior n=", length(walked(body, :interior)), " boundary n=", length(walked(body, :boundary)), " gated=", gated(body),
            " methods0=", hasmethod(body, Tuple{}), " methods1=", hasmethod(body, Tuple{Int}))
end

println("== P2 discrete hold between ticks (S10c-001)")
sim = Simulation(Group((; saw = Sawtooth(0.3), ctl = DiscreteAccumulator(1.0)); local_wires = ("saw/q" => "ctl/e",)); Δt_frame = 1//10, Δt_base = 3//10)
init!(sim)
for _ in 1:6
    step!(sim; t_plus = 0.1)
    println("  t=", round(R._seconds(sim.model.exec.clock.t), digits=3), " acc state=", state(sim, "ctl"))
end

println("== P3 boundary zero: predicate holding in authored state fires at t0 (S10c-171)")
sim = Simulation(fed(Trigger(0.5), "sig"); Δt_frame = 1//10)
init!(sim, set(u = (in = 1.0,)))
println("  trig modes after init: ", modes(sim, "c"))

println("== P4 TwoShot/Preempted blocked not lost (S10c-153, -189)")
s2 = Simulation(fed(TwoShot(), "sig"); Δt_frame = 1//10); init!(s2, set(u = (in = 2.0,)))
println("  TwoShot: ", modes(s2, "c"))
s3 = Simulation(fed(Preempted(), "sig"); Δt_frame = 1//10); init!(s3, set(u = (in = 2.0,)))
println("  Preempted: ", modes(s3, "c"))

println("== P5 firing budget (S10c-207, -216, -225)")
for fb in (1, 3, 4)
    s = Simulation(Group((; chat = Chatterer())); Δt_frame = 1//10, firing_budget = fb)
    init!(s)
    run!(s; t_end = 0.1)
    st = writer_status(latest(s), "loop")
    println("  budget=", fb, " flips=", modes(s, "chat").flips, " recent=", [(d.path, d.event, d.count) for d in st.recent if d isa FiringBudget], " totals.firing=", st.totals.firing)
end

println("== P6 clock: boundary zero and frame clocks (S10c-074, -083)")
for (t0, Δ) in ((0//1, 3//10), (3//10, 3//10), (-3//10, 1//10))
    mm = Model(single(Sawtooth(0.3)); Δt_frame = Δ)
    init!(mm; t0 = t0)
    c0 = mm.exec.clock.t
    tops = [R._grid_time(mm, k) for k in 0:3]
    println("  t0=", t0, " Δ=", Δ, " clock0=", repr(c0), " tops=", repr(tops), " nearest=", [Float64(BigFloat(t0) + k*BigFloat(Δ)) for k in 0:3] == tops)
end
# large-magnitude division correctness vs BigFloat
bad = 0
for _ in 1:200000
    d = Int128(rand(1:2^62)) * Int128(rand(1:2^40)) * (rand(Bool) ? 1 : -1)
    v = Int128(rand(1:2^62)) * Int128(rand(1:2^20))
    exact = Float64(big(d) // big(v))
    R._nearest(d, v) == exact || (global bad += 1)
end
println("  _nearest mismatches over 2e5 large draws: ", bad)

println("== P7 last frame / clock resolution (S10c-093, -102, -109, -113)")
dep = Deployment(build(single(Sawtooth(0.3))); Δt_frame = 1//1000000)
println("  unit=", dep.lattice.unit, " reach=", dep.lattice.reach, " max_frame=", dep.lattice.max_frame)
lf = R._last_frame(dep, 0.0)
tlast = lf * 1e-6
println("  last frame=", lf, " t_last=", tlast, " s = ", tlast / (365.25*86400), " years")
dep2 = Deployment(build(Group((; saw = Sawtooth(0.3), ctl = DiscreteAccumulator(1.0)); local_wires = ("saw/q" => "ctl/e",))); Δt_frame = 1//100, Δt_base = 1//1000000)
lf2 = R._last_frame(dep2, 0.0)
println("  10ms frame / 1µs base: unit=", dep2.lattice.unit, " last frame=", lf2, " t_last years=", lf2*0.01/(365.25*86400))
dep3 = Deployment(build(single(Sawtooth(0.3))); Δt_frame = 1//100, algorithm = BS3(), h_min = 1//1000000000)
println("  BS3 h_min=1ns: unit=", dep3.lattice.unit, " reach=", dep3.lattice.reach, " expect 2^50*1e-9=", exp2(50)*1e-9)
dep4 = Deployment(build(single(Sawtooth(0.3))); Δt_frame = 1//100, algorithm = BS3(), h_min = 1//1000)
println("  BS3 h_min=1ms: reach=", dep4.lattice.reach, " expect 2^50*1e-2 (unit)=", exp2(50)*1e-2)
# Int-bound wins over clock bound: tiny unit
try
    dep5 = Deployment(build(Group((; saw = Sawtooth(0.3), ctl = DiscreteAccumulator(1.0)); local_wires = ("saw/q" => "ctl/e",))); Δt_frame = 1//100, Δt_base = 1//10^17)
    println("  base 1e-17: max_frame=", dep5.lattice.max_frame, " last_frame=", R._last_frame(dep5, 0.0))
catch e
    println("  base 1e-17: threw ", typeof(e), " ", e isa DiagnosticError ? [typeof(d) for d in diagnostics(e)] : "")
end
# frame! past last frame refused
mm = Model(single(Sawtooth(0.3)); Δt_frame = 1//1000000)
init!(mm)
try
    frame!(mm, R._last_frame(mm) + 1)
    println("  frame! past last: accepted?!")
catch e
    println("  frame! past last: ", typeof(e), " ", e isa DiagnosticError ? typeof(e.carried) : "")
end

println("== P8 proposing shaping (S10c-038, -047)")
dep6 = Deployment(build(single(Sawtooth(0.3))); Δt_frame = 1//10, algorithm = BS3(), h_min = 1//100, h_max = 1//20)
m6 = Model(dep6); init!(m6)
for (p, r) in ((0.03, 0.1), (0.004, 0.1), (0.011, 0.025), (1.0, 0.1), (0.033, 0.1), (0.005, 0.007))
    h = _shaped(m6, p, 0.0, r)
    Nexp = r < 0.01 ? 1 : max(1, min(ceil(r / min(p, 0.05)), floor(r / 0.01)))
    println("  p=", p, " r=", r, " h=", h, " r/Nexp=", r / Nexp, " at_floor=", _at_floor(m6, h, 0.0, r))
end
end

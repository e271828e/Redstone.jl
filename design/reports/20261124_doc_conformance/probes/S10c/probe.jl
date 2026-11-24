using Test, StaticArrays, LinearAlgebra, ForwardDiff
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
include(joinpath(W, "test/imports.jl"))
include(joinpath(W, "test/fixtures.jl"))
include(joinpath(W, "test/utils.jl"))

mutable struct CountHooks{M} <: FrameHooks
    model::M
    n::Int
end
Redstone.frame_top!(::CountHooks) = false
Redstone.settled!(h::CountHooks) = (h.n += 1; false)

lattice_rig() = Group((; c = Plant(), a = TickCounter(), b = TickCounter());
                      input_wires = ("in" => "c/u",),
                      sample_times = (; a = Absolute(1//10), b = Absolute(1001//10000)))

function steps(h_max)
    kw = h_max === nothing ? (;) : (; h_max)
    model = Model(lattice_rig(); Δt_frame = 1//50, Δt_base = 1//10000, kw...)
    init!(model, set(u = (in = 0.0,)))
    hooks = CountHooks(model, 0)
    per = Int[]
    for k in 1:5005
        b = hooks.n; frame!(model, k, hooks); push!(per, hooks.n - b)
    end
    (sum(per), per, model)
end
(s0, per0, m0) = steps(nothing)
println("P1 unbounded steps = ", s0, " twoStepFrames=", count(==(2), per0))   # probe:P1
(s5, per5, m5) = steps(5//1000)
println("P2 h_max=5ms steps = ", s5, " 4-step frames=", count(==(4), per5), " 5-step=", count(==(5), per5),
        " 8/9/10 = ", count(==(8), per5), count(==(9), per5), count(==(10), per5))
# split frames
split = [i for i in 1:5005 if per0[i] == 2]
println("P2b split-frame steps: ", sort(collect(Set(per5[split]))), " count4=", count(i->per5[i]==4, split))
println("P2c unsplit frames steps: ", sort(collect(Set(per5[[i for i in 1:5005 if per0[i]==1]]))))
println("P3 lattice unit = ", m0.deployment.lattice.unit, " ", m0.deployment.lattice)
println("P3b show:")
show(stdout, MIME"text/plain"(), Deployment(build(lattice_rig()); Δt_frame = 1//50, Δt_base = 1//10000, h_max = 5//1000)); println()

# Δt_unit: no keyword
r = try Deployment(build(lattice_rig()); Δt_frame = 1//50, Δt_unit = 1//10); catch e; e end
println("P4 Δt_unit kw -> ", typeof(r))
nod = Deployment(build(Group((; c = Plant()); input_wires = ("in" => "c/u",))); Δt_frame = 3//10)
println("P4b no-discrete unit = ", nod.lattice.unit, " base=", nod.lattice.base)
dd = Deployment(build(Group((; c = Plant(), a = TickCounter()); input_wires = ("in" => "c/u",), sample_times = (; a = Absolute(1//2)))); Δt_frame = 3//10, Δt_base = 1//2)
println("P4c unit = ", dd.lattice.unit, " gcd=", gcd(3//10, 1//2))

# 1 µs unit
rig1 = Group((; c = TickCounter()); sample_times = (; c = Relative(1)))
d1 = Deployment(build(rig1); Δt_frame = 1//100, Δt_base = 1//1000000)
m1 = Model(d1); 
lf = Redstone._last_frame(d1, 0.0)
println("P5 1µs: unit=", d1.lattice.unit, " last_frame=", lf, " years=", lf * 0.01 / (365.25*86400), " reach=", d1.lattice.reach)
println("P5b years via reach/2: ", d1.lattice.reach/2/(365.25*86400), " (365d: ", d1.lattice.reach/2/(365*86400), ")")
# 1e-17
d17 = try Deployment(build(rig1); Δt_frame = 1//100, Δt_base = 1//10^17) catch e; e end
if d17 isa Deployment
    println("P6 1e-17: unit=", d17.lattice.unit, " last_frame=", Redstone._last_frame(d17, 0.0))
    m17 = Model(d17)
    r = try init!(m17); :ok catch e; e end
    println("P6b init! -> ", r isa DiagnosticError ? (typeof(r), r.carried) : r)
else
    println("P6 1e-17 deployment refused: ", d17 isa DiagnosticError ? d17.diagnostics : d17)
end

# gap rule with h_max splitting: unit=1µs, h_max tiny
dsplit = Deployment(build(rig1); Δt_frame = 1//100, Δt_base = 1//1000000, h_max = 1//1000)
println("P7 gap with h_max=1ms: reach/2^50=", dsplit.lattice.reach / 2.0^50, " expect min(unit,h_max/2)=", min(1e-6, 5e-4))
dsplit2 = Deployment(build(Group((; c = TickCounter()); sample_times = (; c = Relative(1)))); Δt_frame = 1//100, Δt_base = 1//10, h_max = 1//1000)
println("P7b unit=", dsplit2.lattice.unit, " gap=", dsplit2.lattice.reach / 2.0^50, " h_max/2=", 5e-4)
dprop = Deployment(build(Group((; c = Plant()); input_wires = ("in" => "c/u",))); Δt_frame = 1//100, h_min = 1//10000, h_max = 1//200, algorithm = BS3())
println("P7c proposing gap: ", dprop.lattice.reach / 2.0^50, " expect min(unit=0.01, h_min=1e-4)")

# t_step 0.9
sim = Simulation(Group((; s = Step(; t_step = 0.9))); Δt_frame = 3//10)
init!(sim); run!(sim; t_end = 1.2)
println("P8 Step snapshots: ", [s.t for s in logged(sim)], [port(s, "s") for s in logged(sim)])

# wall-clock origin
t0 = time()
mm = Model(fed(Plant(), "u"); Δt_frame = 1//100); init!(mm, set(u=(in=0.0,)); t0 = t0)
println("P9 time() origin: clock=", mm.exec.clock.t, " == t0 ", mm.exec.clock.t == t0)
frame!(mm, 1); println("P9b frame1 clock= ", mm.exec.clock.t, " nearest=", Float64(big(Rational(t0)) + 1//100))
println("P9c origin>2^53? ", mm.exec.clock.origin > 2^53, " scale=", mm.exec.clock.scale)
mm0 = Model(fed(Plant(), "u"); Δt_frame = 1//100); init!(mm0, set(u=(in=0.0,)); t0 = 1.0)
println("P9d small origin <2^53: ", mm0.exec.clock.origin < 2^53)

# _shaped rule
d = Deployment(build(fed(Plant(), "u")); Δt_frame = 1//50, h_min = 1//10000, h_max = 1//200, algorithm = BS3())
mdl = Model(d); init!(mdl, set(u=(in=0.0,)))
shaped(r, p) = Redstone._shaped(mdl, p, 0.0, r)
for (r, p) in ((0.02, 0.007), (0.02, 0.004), (0.02, Inf), (0.0003, 1.0), (0.00005, 1.0), (0.0002, 1e-9), (0.0105, 0.01))
    h = shaped(r, p)
    N = round(r / h)
    expect = max(1, min(ceil(r / min(p, 0.005)), floor(r / 1e-4)))
    println("P10 r=", r, " p=", p, " -> N=", N, " h=", h, " spec N=", expect, " h>=p/2? ", h >= min(p, 0.005)/2)
end

# --- events
chain() = Group((; trig = Trigger(0.5), f1 = Follower(), f2 = Follower());
                local_wires = ("trig/on" => "f1/go", "f1/on" => "f2/go"), input_wires = ("in" => "trig/sig",))
s = Simulation(chain(); Δt_frame = 1//10); init!(s, set(u = (in = 1.0,)))
println("P11 boundary zero fires at t0: ", modes(s, "trig").state, modes(s, "f2").state, " count=", modes(s,"trig").count)
step!(s; frames = 3)
println("P11b sticky: count stays ", modes(s, "trig").count)
chatty() = Group((; chat = Chatterer(), trig = Trigger(0.5)); input_wires = ("in" => "trig/sig",))
s = Simulation(chatty(); Δt_frame = 1//10); init!(s, set(u = (in = 1.0,)))
println("P12 chatter flips=", modes(s, "chat").flips, " (2x4)")
step!(s; frames = 1)
ws = writer_status(latest(s), "loop")
println("P12b warnings: ", [(typeof(x), x.path, x.event, x.t, x.budget, x.count) for x in ws.recent])
s = Simulation(fed(Trigger(0.5), "sig"); Δt_frame = 1//10, firing_budget = 1); init!(s, set(u = (in = 1.0,))); step!(s; frames = 2)
println("P13 budget=1 sticky trigger fired ", modes(s, "c").count, " warnings=", writer_status(latest(s), "loop").totals.firing)
s = Simulation(fed(TwoShot(), "sig"); Δt_frame = 1//10); init!(s, set(u = (in = 2.0,)))
println("P14 TwoShot ", modes(s, "c"))
s = Simulation(fed(Preempted(), "sig"); Δt_frame = 1//10); init!(s, set(u = (in = 2.0,)))
println("P14b Preempted ", modes(s, "c"))
println("P15 default firing_budget ", Deployment(build(chatty()); Δt_frame = 1//10).firing_budget, " loc ", Deployment(build(chatty()); Δt_frame = 1//10).localization_budget)
for fb in (0, 1.5, 3)
    r = try Deployment(build(chatty()); Δt_frame = 1//10, firing_budget = fb); :ok catch e; e isa DiagnosticError ? [x.reason for x in e.carried] : e end
    println("P15b firing_budget=", fb, " -> ", r)
end
s = Simulation(fed(Trigger(0.5), "sig"); Δt_frame = 1//10); init!(s, set(u = (in = 1.0,)))
cp = checkpoint(s)
println("P16 checkpoint prior = ", cp.prior)

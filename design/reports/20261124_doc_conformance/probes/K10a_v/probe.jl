# K10a verifier probes. Run from W with --project=test.
module K10aProbe
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const T = joinpath(pwd(), "test")
include(joinpath(T, "imports.jl"))
include(joinpath(T, "fixtures.jl"))
include(joinpath(T, "utils.jl"))
import Redstone: _floor_steps, _shaped, _tick_time, _grid_time, restore_stepper!

p(tag, x) = println(tag, " => ", repr(x))

# BS3 with a record of every attempt: (t, h, accepted, proposal after)
struct Rec <: AbstractAlgorithm
    inner::BS3
end
struct RecStepper{T} <: AbstractStepper
    inner::BS3Stepper{T}
    log::Vector{NTuple{4,Float64}}
end
Redstone.bind_stepper(a::Rec, ::Type{T}, n::Int) where {T} = RecStepper{T}(bind_stepper(a.inner, T, n), NTuple{4,Float64}[])
Redstone.proposes(::Rec) = true
Redstone.propose(s::RecStepper) = propose(s.inner)
Redstone.checkpoint_stepper(s::RecStepper) = checkpoint_stepper(s.inner)
Redstone.restore_stepper!(s::RecStepper, c) = restore_stepper!(s.inner, c)
Redstone.reset_stepper!(s::RecStepper) = reset_stepper!(s.inner)
Redstone.discontinuity!(s::RecStepper) = discontinuity!(s.inner)
Redstone.startpoint(s::RecStepper) = startpoint(s.inner)
function Redstone.attempt!(s::RecStepper, model::Model, h)
    t = Float64(model.exec.clock.t)
    ok = attempt!(s.inner, model, h)
    push!(s.log, (t, Float64(h), Float64(ok), s.inner.proposal))
    ok
end

# section 5's lag, its 0.75 guard and a discrete unit due at every base tick
lagrig(x0) = Group((; lag = FirstOrderLag(τ = 0.05, x0 = x0), s = Stamper(0.75), a = TickCounter());
                   input_wires = ("ref" => "lag/u",), local_wires = ("lag/y" => "s/sig",))

# K10a-263: RK4 t* in frame 7
for x0 in (0.5, 0.0)
    sim = Simulation(lagrig(x0); Δt_frame = 1//10, Δt_base = 1//20, h_min = 1//10_000)
    init!(sim, set(u = (ref = 0.5,)))
    step!(sim; frames = 6)
    n6 = length(logged(sim))
    stage!(sim, "ref" => 1.0)
    step!(sim; frames = 1)
    p("K10a-263 RK4 x0=$x0 t_fired", modes(sim, "s").t_fired)
    p("K10a-263 RK4 frame-7 snapshots", [s.t for s in logged(sim)[n6+1:end]])
end

# K10a-203: the proposal kept into frame 7 (lag-only rig, so not 0.0308 here), and
# the chain the walkthrough quotes when frame 6's last proposal is 0.0308
for force in (false, true)
    sim = Simulation(lagrig(0.5); Δt_frame = 1//10, Δt_base = 1//20, h_min = 1//10_000,
                     algorithm = Rec(BS3(reltol = 1e-4, abstol = 1e-7)))
    init!(sim, set(u = (ref = 0.5,)))
    step!(sim; frames = 6)
    st = sim.model.exec.stepper
    force && restore_stepper!(st, (0.0308, 0.0))
    kept = (st.inner.proposal, st.inner.memory)
    nlog = length(st.log)
    stage!(sim, "ref" => 1.0)
    step!(sim; frames = 1)
    p("K10a-203 force=$force (proposal, memory) after frame 6", kept)
    p("K10a-203 force=$force memory as frame 7 starts (cleared by notices)", "see first attempt")
    for a in st.log[nlog+1:min(end, nlog+8)]
        p("K10a-203 force=$force attempt (t,h,ok,proposal)", a)
    end
    p("K10a-203 force=$force t_fired", modes(sim, "s").t_fired)
end

# K10a-265 / K10a-274: the floor from 0.6 toward 0.65, and a forced step's length
model = Model(lagrig(0.5); Δt_frame = 1//10, Δt_base = 1//20, h_min = 1//10_000, algorithm = BS3())
t6, t13 = _grid_time(model, 6), _tick_time(model, 13)
fs = _floor_steps(model, t6, t13)
p("K10a-265 floor steps, shortest step", (t6, t13, fs, (t13 - t6) / fs))
for r in (0.5e-4, 1.0e-4, 1.5e-4, 1.999e-4, 2.0e-4, 2.0001e-4, 2.999e-4)
    p("K10a-274 r=$r shaped(h_min)", _shaped(model, 1e-4, 0.6, 0.6 + r))
end

# K10a-163: (D0,Φ0)=(1,0) controller on Δt_frame 1/100, Δt_base 1/25
sim = Simulation(Group((; a = TickCounter())); Δt_frame = 1//100, Δt_base = 1//25)
init!(sim)
p("K10a-163 boundary zero (port n, s.n)", (port(sim, "a", :n), state(sim, "a").n))
for k in 1:9
    step!(sim; frames = 1)
    p("K10a-163 after frame $k (port n, s.n)", (port(sim, "a", :n), state(sim, "a").n))
end

# K10a-183: boundary zero's update gate at index 0, Φ0 = 0 against Φ0 = 1
sim = Simulation(Group((; c0 = TickCounter(), c1 = TickCounter());
                       sample_times = (; c0 = Relative(2, 0), c1 = Relative(2, 1))); Δt_frame = 1//10)
init!(sim)
p("K10a-183 after init (c0 s.n, c1 s.n; c0 port, c1 port)",
  (state(sim, "c0").n, state(sim, "c1").n, port(sim, "c0", :n), port(sim, "c1", :n)))
end

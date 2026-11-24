module P
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
include(joinpath(W, "utils.jl"))
panel_model() = Group((; inner = Group((; c = Pendulum(), g = Gain(2.0));
                                       input_wires = ("u" => "c/u", "e" => "g/e"),
                                       output_wires = ("c/θ" => "θ",)),
                         ctl = DiscreteAccumulator(1.0));
                      local_wires = ("ctl/u" => "inner/u",),
                      input_wires = ("in" => "ctl/e", "gain_in" => "inner/e"))

# 1. views and incumbent_status for harness-driven / component-driven
sim = Simulation(panel_model(); Δt_frame = 1//10)
h = attach!(sim, Pad("a"), Enumerated("in"))
init!(sim, set(u = (in = 1.0, gain_in = 2.0)))
v = port_views(h)
println("probe:", @__LINE__, " nviews=", length(v))
println("probe:", @__LINE__, " harness-driven incumbent_status = ", incumbent_status(v[("inner/g", :e)], latest(sim)))
println("probe:", @__LINE__, " component-driven incumbent_status = ", incumbent_status(v[("inner/c", :u)], latest(sim)))
println("probe:", @__LINE__, " slot types ", v[("ctl", :e)].slot, " ", v[("inner/g", :e)].slot)
println("probe:", @__LINE__, " harness rec ", fieldnames(typeof(latest(sim).status.writers[end-1])), latest(sim).status.writers[end-1].heartbeat, latest(sim).status.writers[end-1].task_state)
println("probe:", @__LINE__, " writers ", [w.who for w in latest(sim).status.writers])
println("probe:", @__LINE__, " WriterStatus ", fieldtypes(Redstone.WriterStatus), " isbits KindCounts ", isbitstype(KindCounts))

# 2. ring bound
cell = DiagCell(EMPTY_DIAG)
for i in 1:20; Redstone.report_cell!(cell, MalformedDatum(i)); end
b = Redstone._take!(cell)
println("probe:", @__LINE__, " ring=", length(b.ring), " first=", b.ring[1].cause, " suppressed=", b.suppressed, " DIAG_RING=", DIAG_RING)
println("probe:", @__LINE__, " after take sentinel? ", (@atomic cell.batch) === EMPTY_DIAG)
Redstone._take!(cell)
println("probe:", @__LINE__, " quiet take alloc=", @allocated(Redstone._take!(cell)))
acct = Redstone.WriterAccount()
Redstone._fold!(acct, cell)
println("probe:", @__LINE__, " quiet fold alloc=", @allocated(Redstone._fold!(acct, cell)))

# 3. terminal totals: a noisy device
mutable struct Noisy <: AbstractDevice end
function Redstone.loop(::Noisy, handle)
    for i in 1:30; report!(handle, MalformedDatum(i)); end
    nothing
end
sim2 = Simulation(panel_model(); Δt_frame = 1//10)
attach!(sim2, Noisy(), NoClaim())
init!(sim2, set(u = (in = 1.0, gain_in = 2.0)))
run!(sim2; t_end = 0.5)
st = latest(sim2).status
for w in st.writers
  println("probe:", @__LINE__, " ", w.who, " recent=", length(w.recent), " supp=", w.suppressed.malformed, " tot=", w.totals.malformed, " hb=", w.heartbeat, " ts=", w.task_state)
end
println("probe:", @__LINE__, " termination ", typeof(sim2.run.termination))
# 4. harness stage! diag cell, no heartbeat
sim3 = Simulation(panel_model(); Δt_frame = 1//10)
attach!(sim3, Pad("a"), Enumerated("in"))
init!(sim3, set(u = (in = 1.0, gain_in = 2.0)))
stage!(sim3, "in" => 3.0)
stage!(sim3, "nope" => 3.0)
step!(sim3)
for w in latest(sim3).status.writers
  println("probe:", @__LINE__, " ", w.who, " recent=", [typeof(r) for r in w.recent], " ts=", w.task_state)
end
end

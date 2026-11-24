# L9a probe: log entries D-014 … D-253 (Status + Position), against W at d7d3ddff.
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
include(joinpath(W, "test", "imports.jl"))
include(joinpath(W, "test", "fixtures.jl"))
R = Redstone
p(label, v) = println(rpad(label, 46), " => ", v)

# D-052, D-099, D-135, D-253: activations lazy, keyed by concrete scalar, on the Build
b = build(feedback_model())
p("P1 activations after build", collect(keys(b.activations)))
R.activation(b, ProbeDual)
p("P2 activations after first request", collect(keys(b.activations)))
b2 = build(feedback_model(); activations = (Float64, ProbeDual))
p("P3 activations with keyword", collect(keys(b2.activations)))
p("P4 ProbeDual definition", ProbeDual === ForwardDiff.Dual{R.ProbeTag,Float64,1})
p("P5 Activation fields", fieldnames(R.Activation))
p("P6 Build fields", fieldnames(Build))
p("P7 Outputs / ComponentOutputs fields", (fieldnames(R.Outputs), fieldnames(R.ComponentOutputs)))
p("P8 Events / ComponentEvents fields", (fieldnames(R.Events), fieldnames(R.ComponentEvents)))
p("P9 Structure fields", fieldnames(R.Structure))
p("P10 ComponentEntry fields", fieldnames(R.ComponentEntry))
for s in (:SimulationTermination, :Dataflow, :Flat, :stop_on, :Getter, :capture, :sweep_hx)
    p("P11 isdefined $s", isdefined(R, s))
end

# D-119, D-049: Simulation(world; ...) composes through build
sim = Simulation(feedback_model(); Δt_frame = 1//100)
p("P12 Simulation(root) build type", typeof(sim.model.deployment.build))
p("P13 Simulation methods", [m.sig for m in methods(Simulation)])

# D-116, D-196: the phase-body roster
rot = Simulation(Group((; rot = Rotor(), saw = Sawtooth(1.0))); Δt_frame = 1//100)
init!(rot)
pb = phase_bodies(rot)
p("P14 phase_bodies keys", keys(pb))
p("P15 events keys", collect(keys(pb.events)))
p("P16 event body keys", keys(first(values(pb.events))))
p("P17 projections keys", collect(keys(pb.projections)))
p("P18 identity with loop bodies", pb === rot.model.exec.bodies)

# D-136: the diagnostic cell's allocation story, measured inside functions
function quiet_take(cell)
    R._take!(cell); R._take!(cell)
    @allocated R._take!(cell)
end
function emissions(cell, d, n)
    out = Int[]
    for i in 1:n
        a = @allocated R.report_cell!(cell, d)
        push!(out, a)
    end
    out
end
cell = DiagCell(EMPTY_DIAG)
d = R.UnboundedRun(Inf, String[])
emissions(DiagCell(EMPTY_DIAG), d, 20)          # warm
quiet_take(cell)
p("P19 quiet take allocs", quiet_take(cell))
allocs = emissions(cell, d, 20)
p("P20 per-emission allocs 1..20", allocs)
p("P21 ring length / suppressed", (length((@atomic cell.batch).ring), (@atomic cell.batch).suppressed.unbounded))
p("P22 KindCounts isbits", isbitstype(KindCounts))
p("P23 DIAG_RING / STATUS_MAXLOG", (DIAG_RING, R.STATUS_MAXLOG))

# D-221, D-225: StepError parametrized on its cause
p("P24 StepError parametric", (StepError{ErrorException} <: StepError, typeof(StepError).name.name))

# D-151: a permuted stage return pairs by name
struct L9aSwap <: AbstractComponent end
Redstone.x_init(::L9aSwap) = nothing
Redstone.u_types(::L9aSwap) = (;)
Redstone.y_types(::L9aSwap) = (a = Float64, b = Float64)
Redstone.y_direct(::L9aSwap, _) = (b = 2.0, a = 1.0)
sw = Simulation(L9aSwap(); Δt_frame = 1//10)
init!(sw)
p("P25 permuted return reads", (port(sw, "", :a), port(sw, "", :b)))
p("P26 outputs stage2 order", sw.model.deployment.build.outputs.components[1].stage2)

# D-250: warnings methods
p("P27 warnings methods", [m.sig for m in methods(warnings)])

# D-136 follow-up: the quiet fold as the loop runs it, under BenchmarkTools
acct = R.WriterAccount()
qcell = DiagCell(EMPTY_DIAG)
R._fold!(acct, qcell)
p("P28 quiet _fold! ballocated", @ballocated(R._fold!($acct, $qcell)))
p("P29 quiet _take! ballocated", @ballocated(R._take!($qcell)))
p("P30 DiagBatch isbits / sizeof", (isbitstype(R.DiagBatch), sizeof(R.DiagBatch)))

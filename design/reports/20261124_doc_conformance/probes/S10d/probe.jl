using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
median(x) = sort(collect(x))[cld(length(x),2)]
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
include(joinpath(W, "utils.jl"))
import Redstone: Control, Pacer, anchor!, wait_deadline!, DiagCell, EMPTY_DIAG, _wall_now

# 1. sleep overshoot against 2 ms requests, sub-ms rounding
ov(f, d, n=40) = median([(t0=time_ns(); f(d); (time_ns()-t0)/1e9 - d) for _ in 1:n])
println("sleep(2ms) overshoot median ", ov(sleep, 0.002), "  systemsleep ", ov(Libc.systemsleep, 0.002))
println("sleep(0.1ms) elapsed ", ov(sleep, 0.0001) + 0.0001, " sleep(0.4ms) ", ov(sleep, 0.0004)+0.0004)

# 2. spec code block, adapted
τ() = _wall_now()
function block(budget, margin)
    deadline = τ() + budget
    t0 = τ(); slept = 0.0
    remaining = deadline - margin - τ()
    remaining > 0 && sleep(remaining)
    t1 = τ()
    while τ() < deadline
        GC.safepoint()
    end
    (spin = τ() - t1, total = τ() - t0, late = τ() - deadline)
end
block(0.02, 0.002)
r = [block(0.02, 0.002) for _ in 1:30]
println("block 20ms/2ms: spin median ", median(getfield.(r, :spin)), " late median ", median(getfield.(r, :late)))
r0 = [block(0.02, 0.0) for _ in 1:30]; println("margin0 spin median ", median(getfield.(r0, :spin)), " late ", median(getfield.(r0, :late)))
ri = [block(0.02, Inf) for _ in 1:5]; println("margin Inf spin median ", median(getfield.(ri, :spin)), " (budget .02)")
rd = [block(0.002, 0.002) for _ in 1:5]; println("budget==margin spin ", median(getfield.(rd, :spin)))

# 3. wait_deadline! hand-driven: spin share, first frame no wait, counters
control, pacer, cell = Control(5.0), Pacer(), DiagCell(EMPTY_DIAG)
h = 0.02; @atomic control.pace = 1.0
anchor!(pacer, 0.0, 1.0)
wait_deadline!(control, pacer, cell, 0.0, h); println("first frame waits=", pacer.waits)
for k in 1:10; wait_deadline!(control, pacer, cell, k*h, h); end
println("waits=", pacer.waits, " waited=", pacer.waited, " overruns=", pacer.overruns, " debt=", pacer.debt)
# forgive threshold: debt just under and over 5h/p
for (debt, label) in ((4.5h, "4.5h"), (5.5h, "5.5h"))
    c, p, cl = Control(5.0), Pacer(), DiagCell(EMPTY_DIAG); @atomic c.pace = 1.0
    anchor!(p, 0.0, 1.0); p.τ_anchor -= h + debt
    wait_deadline!(c, p, cl, h, h)
    println(label, ": reanchors=", p.reanchors, " forgiven=", p.forgiven, " ring=", length(_take!(cl).ring))
end
# pace change to Inf: counted as forgiven, no warning
c, p, cl = Control(5.0), Pacer(), DiagCell(EMPTY_DIAG); @atomic c.pace = 1.0
anchor!(p, 0.0, 1.0); p.τ_anchor -= 2h; wait_deadline!(c, p, cl, h, h)
println("pre-switch debt=", p.debt); @atomic c.pace = Inf; wait_deadline!(c, p, cl, 2h, h)
println("after Inf: reanchors=", p.reanchors, " forgiven=", p.forgiven, " pace=", p.pace, " ring=", length(_take!(cl).ring))
# pace change finite: re-anchors, no warning
c, p, cl = Control(5.0), Pacer(), DiagCell(EMPTY_DIAG); @atomic c.pace = 1.0
anchor!(p, 0.0, 1.0); @atomic c.pace = 2.0; wait_deadline!(c, p, cl, h, h)
println("pace change: reanchors=", p.reanchors, " waits=", p.waits, " ring=", length(_take!(cl).ring))

snap_cells(s::Snapshot) = Any[gather_cell(s.store, s.layout.addr[k]) for k in sort!(collect(keys(s.layout.addr)))]
same_trajectory(c, r) = length(c) == length(r) && all(x.t == y.t && x.frame == y.frame && snap_cells(x) == snap_cells(y) for (x, y) in zip(c, r))
# 4. bit-identical paced vs unpaced
runs = map((Inf, 5)) do pc
    sim = Simulation(feedback_model(); Δt_frame = 1//100)
    init!(sim, set(u = (ref = 1.0,)))
    stage!(sim, "ref" => 2.0)
    run!(sim; t_end = 0.2, pace = pc)
    sim
end
println("identical: ", same_trajectory(logged(runs[2]), logged(runs[1])), " pacer ", latest(runs[2]).status.pacer)
println("unpaced pacer ", latest(runs[1]).status.pacer)
# default margin & validation
println("margin default ", margin(runs[1]), " pace default ", pace(runs[1]))
for bad in (0, -1, NaN)
    try pace!(runs[1], bad); println("pace ", bad, " accepted") catch e; println("pace ", bad, " -> ", typeof(e)) end
end
margin!(runs[1], Inf); println("margin Inf ok ", margin(runs[1]))
try margin!(runs[1], -1) catch e; println("margin -1 -> ", typeof(e)) end

# 5. proposing method paced: refusal or warning?
sim = Simulation(feedback_model(); Δt_frame = 1//10, h_min = 1//1000, algorithm = BS3())
init!(sim, set(u = (ref = 1.0,)))
run!(sim; t_end = 0.3, pace = 10)
println("proposing paced ran: ", lifecycle(sim), " warnings ", length(warnings(sim)))

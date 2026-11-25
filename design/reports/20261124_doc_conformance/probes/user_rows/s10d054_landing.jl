const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test, Statistics
include(joinpath(W, "imports.jl")); include(joinpath(W, "utils.jl"))
import Redstone: Pacer, anchor!, wait_deadline!
cpu() = ccall(:clock, Clong, ()) / 1.0e6
function land(m, h, n)
    control, pacer, cell = Control(5.0), Pacer(), DiagCell(EMPTY_DIAG)
    @atomic control.pace = 1.0
    @atomic control.margin = m
    anchor!(pacer, 0.0, 1.0)
    wait_deadline!(control, pacer, cell, h, h); anchor!(pacer, 0.0, 1.0)
    lands = Float64[]; c0, w0 = cpu(), time()
    for k in 1:n
        wait_deadline!(control, pacer, cell, k*h, h)
        push!(lands, Redstone._wall_now() - (pacer.τ_anchor + k*h))
    end
    (lands, (cpu()-c0)/(time()-w0))
end
println("budget_ms,margin_ms,late_median_us,late_p95_us,late_max_us,cpu_pct")
for h in (0.02, 0.01), m in (0.0, 0.001, 0.002, 0.0025, 0.003, 0.004)
    l, c = land(m, h, 250)
    println(join((h*1e3, m*1e3, round(median(l)*1e6; digits=1), round(quantile(l,.95)*1e6; digits=1), round(maximum(l)*1e6; digits=1), round(100c; digits=1)), ","))
end

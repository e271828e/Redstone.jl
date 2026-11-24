# S10d verifier probe: the pacer's wait, forgiveness, un-pause, the interrupt in sleep.
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test
median(v) = (s = sort(v); n = length(s); isodd(n) ? s[(n+1)÷2] : (s[n÷2] + s[n÷2+1]) / 2)
quantile(v, q) = sort(v)[clamp(ceil(Int, q * length(v)), 1, length(v))]
const T = joinpath(pwd(), "test")
include(joinpath(T, "imports.jl")); include(joinpath(T, "utils.jl")); include(joinpath(T, "fixtures.jl"))
import Redstone: Pacer, anchor!, reanchor!, wait_deadline!, _wall_now, _take!

cpu() = ccall(:clock, Clong, ()) / 1.0e6   # process CPU seconds (CLOCKS_PER_SEC = 1e6 on macOS)

# P1: sleep overshoot against 2 ms requests
for (name, f) in (("sleep", sleep), ("systemsleep", Libc.systemsleep))
    f(0.002)
    o = [(t0 = time_ns(); f(0.002); (time_ns() - t0) / 1e9 - 0.002) for _ in 1:300]
    println("P1 $name overshoot median = $(round(median(o)*1e3; digits=3)) ms, p90 = $(round(quantile(o,0.9)*1e3; digits=3)) ms")
end

# P1b: sleep overshoot against 18 ms requests, the coarse phase's at a 20 ms budget and 2 ms margin
let o = [(t0 = time_ns(); sleep(0.018); (time_ns() - t0) / 1e9 - 0.018) for _ in 1:50]
    println("P1b sleep(18 ms) overshoot median = $(round(median(o)*1e3; digits=3)) ms, min = $(round(minimum(o)*1e3; digits=3)) ms, max = $(round(maximum(o)*1e3; digits=3)) ms")
end

# P2: the wait at margin 0, 2 ms, Inf against a 20 ms budget, driven by hand
for m in (0.0, 0.002, Inf)
    control, pacer, cell = Control(5.0), Pacer(), DiagCell(EMPTY_DIAG)
    h = 0.02
    @atomic control.pace = 1.0
    @atomic control.margin = m
    anchor!(pacer, 0.0, 1.0)
    wait_deadline!(control, pacer, cell, h, h)       # warm
    anchor!(pacer, 0.0, 1.0)
    lands = Float64[]; slept = Float64[]
    c0, w0 = cpu(), _wall_now()
    for k in 1:50
        t = k * h
        before = _wall_now()
        deadline = pacer.τ_anchor + t
        wait_deadline!(control, pacer, cell, t, h)
        after = _wall_now()
        push!(lands, after - deadline)
    end
    c1, w1 = cpu(), _wall_now()
    println("P2 margin=$m: waits=$(pacer.waits) overruns=$(pacer.overruns) landing median=$(round(median(lands)*1e6; digits=1)) µs max=$(round(maximum(lands)*1e6; digits=1)) µs CPU/wall=$(round((c1-c0)/(w1-w0)*100; digits=1))% (sleep target fraction $(isinf(m) ? 0 : round((h-m)/h*100; digits=1))%)")
end

# P3: forgiveness re-anchor counted and reported as DebtReanchor
let control = Control(5.0), pacer = Pacer(), cell = DiagCell(EMPTY_DIAG), h = 0.01
    @atomic control.pace = 1.0
    anchor!(pacer, 0.0, 1.0)
    pacer.τ_anchor -= 0.1
    wait_deadline!(control, pacer, cell, h, h)
    ring = _take!(cell).ring
    println("P3 reanchors=$(pacer.reanchors) forgiven=$(pacer.forgiven) debt=$(pacer.debt) ring=$(map(typeof, ring))")
    t0 = _wall_now(); wait_deadline!(control, pacer, cell, 2h, h)
    println("P3 next frame waits=$(pacer.waits) waited≈$(round((_wall_now()-t0)*1e3; digits=2)) ms (no catch-up burst)")
end

# P4: a real SIGINT during the coarse phase's sleep, 1 s budgets
Base.exit_on_sigint(false)
sim = Simulation(fed(Staller(), "stall"); Δt_frame = 1//100)
init!(sim, set(u = (in = 0.0,)))
run!(sim; t_end = 0.03, pace = 1.0e6)
init!(sim, set(u = (in = 0.0,)))
pid = getpid()
start = time()
killer = run(`sh -c "sleep 1.5; kill -INT $pid"`; wait = false)
caught = nothing
try
    run!(sim; t_end = 1.0e6, pace = 0.01)
catch err
    global caught = err
end
ret = time() - start
wait(killer)
println("P4 run! returned at $(round(ret; digits=3)) s after launch (signal at ~1.5 s, next deadline at ~2 s); caught=$(caught) lifecycle=$(lifecycle(sim)) source=$(termination(sim).source) frame=$(latest(sim).frame) waits=$(latest(sim).status.pacer.waits)")

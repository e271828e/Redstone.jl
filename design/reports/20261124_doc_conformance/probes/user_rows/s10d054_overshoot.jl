# S10d-054: `sleep`'s overshoot by request length, beside `Libc.systemsleep`'s.
# The landing table is `s10d054_landing.jl`'s. Run both on a quiet machine.
using Statistics
println("-- sleep overshoot (ms): request, median, p95")
for r in (0.001, 0.002, 0.005, 0.010, 0.016, 0.018)
    o = Float64[]; for _ in 1:200; t0 = time_ns(); sleep(r); push!(o, (time_ns()-t0)/1e6 - r*1e3); end
    println(r*1e3, ", ", round(median(o); digits=2), ", ", round(quantile(o,.95); digits=2))
end
println("-- Libc.systemsleep overshoot (ms)")
for r in (0.002, 0.018)
    o = Float64[]; for _ in 1:200; t0 = time_ns(); Libc.systemsleep(r); push!(o, (time_ns()-t0)/1e6 - r*1e3); end
    println(r*1e3, ", ", round(median(o); digits=2), ", ", round(quantile(o,.95); digits=2))
end

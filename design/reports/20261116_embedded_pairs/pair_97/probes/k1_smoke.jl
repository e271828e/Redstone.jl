# Smoke: A vs A' identical; counters agree; floors readable.
include(joinpath(@__DIR__, "kepler.jl"))
for lab in ("A", "A'", "B_mid", "C")
    r = kepler_run(candidate(lab, 1e-4))
    println(lab, ": ", Base.structdiff(r, (; sim = 0)))
end
r = kepler_run(candidate("A", 1e-4))
println(writer_status(latest(r.sim), "loop"))

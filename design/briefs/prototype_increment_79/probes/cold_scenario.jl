# One cold process, one scenario: the §9.7 table's cold figure, from `build` to the end of the first `run!`.
Base.cumulative_compile_timing(true)
using Redstone
include(joinpath(@__DIR__, "fixtures.jl"))
const SCEN = Symbol(ARGS[1])
c0 = Base.cumulative_compile_time_ns()[1]
t0 = time_ns(); root = model(SCEN); cond = condition(SCEN)
t1 = time_ns(); bld = build(root)
t2 = time_ns(); sim = Simulation(bld; h = 1//1000)
t3 = time_ns(); init!(sim, cond)
t4 = time_ns(); run!(sim; t_end = 0.1)
t5 = time_ns(); c1 = Base.cumulative_compile_time_ns()[1]
s(a, b) = round((b - a) / 1e9; digits = 2)
println("SCENARIO $SCEN construct=$(s(t0,t1)) build=$(s(t1,t2)) sim=$(s(t2,t3)) init=$(s(t3,t4)) run=$(s(t4,t5)) first=$(s(t1,t5)) compile=$(round((c1-c0)/1e9; digits=2))")

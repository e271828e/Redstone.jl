# Float64 init!(plan) allocations and time with and without the new call.
include(joinpath(@__DIR__, "probe_common.jl"))
using BenchmarkTools
const SRC = read(joinpath(TREE, "src", "model.jl"), String)
cut(from, to) = (i = findfirst(from, SRC); j = findnext(to, SRC, last(i)); SRC[first(i):last(j)])
const INIT_SRC = cut("function init!(model::Model{T}, plan::ConditionPlan; t0 = 0,", "\nend\n")
ev(s) = Base.include_string(Redstone, s, "mutant")

function measure(label)
    for (name, world, c) in (("sampled_loop", sampled_loop(), set(u = (ref = 1.0,))),
                             ("bare_world", bare_world(), set(u = (u = 1.0, p = 0.0))))
        mf = Model(world, Float64; Δt_frame = 1//50)
        plan = Redstone.resolve_condition(c, mf.deployment.build, Float64)
        init!(mf, plan); init!(mf, plan)
        a = @allocated init!(mf, plan)
        b = @belapsed init!($mf, $plan)
        println(label, " ", name, " Float64 init!(plan): ", a, " B, ", round(b * 1e6; digits = 2), " μs")
    end
end
measure("fix ")
ev(replace(INIT_SRC, "        _establish_frozen!(model, origin)   # a non-nominal scalar's frozen cells (D-481)\n" => ""))
measure("base")

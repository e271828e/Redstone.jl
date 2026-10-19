# The Coverage workflow's shape: a parent under --code-coverage loads Redstone,
# precompiling the image under its flags if stale, then spawns the test's child
# with the coverage flag dropped.
using Redstone
julia = filter(flag -> !startswith(flag, "--code-coverage"), Base.julia_cmd().exec)
script = "Base.cumulative_compile_timing(true); using Redstone; c = Base.cumulative_compile_time_ns()[1]; Redstone.workload(); println(\"CHILD compile_s=\", (Base.cumulative_compile_time_ns()[1] - c) / 1e9)"
println("PARENT flags: ", join(Base.julia_cmd().exec[2:end], " "))
print(read(`$julia --project=$(Base.active_project()) -e $script`, String))

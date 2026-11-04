# --- the precompile workload (§9.7) ----------------------------------------------
# The claim is the image's, not a function's: a fresh process runs the
# workload's own body with no generic compile left to pay. The child is this
# process's `julia` under its flags and project, so it loads the image this
# run compiled. The coverage flag is dropped, because an instrumented process
# ignores the image's native code and would measure the bare path.

const CHILD_SCRIPT = """
Base.cumulative_compile_timing(true)
using Redstone
compile_ns = Base.cumulative_compile_time_ns()[1]
Redstone.workload()
println(Base.cumulative_compile_time_ns()[1] - compile_ns)
"""

function test_precompile()
    @testset "a cold process runs the workload off the package image (§9.7, D-289)" begin
        julia = filter(flag -> !startswith(flag, "--code-coverage"), Base.julia_cmd().exec)
        output = read(`$julia --project=$(Base.active_project()) -e $CHILD_SCRIPT`, String)
        compile_seconds = parse(Int, last(split(strip(output), '\n'))) / 1e9
        @test compile_seconds < 2.0
    end
end

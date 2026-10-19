# --- the precompile workload (§9.7) ----------------------------------------------
# The claim is the image's, not a function's: a fresh process runs the
# workload's path with no generic compile left to pay. The child is this
# process's `julia` under its flags and project, so it loads the image this
# run compiled. The child spells the path itself over `workload_loop`, with
# closures of its own, rather than calling `workload`: a child that ran the
# workload's body would measure whatever that body contains, and a step
# dropped from it would never show. The coverage flag is dropped, because an
# instrumented process ignores the image's native code and would measure the
# bare path.

const CHILD_SCRIPT = """
Base.cumulative_compile_timing(true)
using Redstone
import Redstone: build, Simulation, init!, step!, run!, set, port, state, series, reads, get_output,
    checkpoint, restore!, trim!, TrimProblem, get_deriv, linearize, taps, get_state, get_input
compile_ns = Base.cumulative_compile_time_ns()[1]
loop_build = build(Redstone.workload_loop())
sprint(show, MIME"text/plain"(), loop_build)
sim = Simulation(loop_build; h = 1//1000)
init!(sim, set(u = (disturbance = 0.0,)))
step!(sim)
run!(sim; t_end = 0.1)
port(sim, "plant", :out)
state(sim, "plant")
series(sim, reads(y = get_output("plant", :out)))
restore!(sim, checkpoint(sim))
trim_sim = Simulation(loop_build; h = 1//1000)
trim!(trim_sim, TrimProblem(
    guess = (d = 0.3,), lower = (d = -1.0,), upper = (d = 1.0,),
    condition = d -> set(u = (disturbance = d.d,)),
    reads = reads(q̇₂ = get_deriv("plant", "q[2]")),
    residuals = (derivatives, d) -> (q̇₂ = derivatives.q̇₂,),
    tolerances = (q̇₂ = 1e-9,)); baseline = set(u = (disturbance = 0.0,)))
linearize(trim_sim, taps(
    x = (q₁ = get_state("plant", "q[1]"), q₂ = get_state("plant", "q[2]")),
    u = (d = get_input(:disturbance),), y = (y = get_output("plant", :out),)))
println(Base.cumulative_compile_time_ns()[1] - compile_ns)
"""

function test_precompile()
    @testset "a cold process runs the workload's path off the package image (§9.7, D-289)" begin
        julia = filter(flag -> !startswith(flag, "--code-coverage"), Base.julia_cmd().exec)
        output = read(`$julia --project=$(Base.active_project()) -e $CHILD_SCRIPT`, String)
        compile_seconds = parse(Int, last(split(strip(output), '\n'))) / 1e9
        @test compile_seconds < 2.0
    end
end

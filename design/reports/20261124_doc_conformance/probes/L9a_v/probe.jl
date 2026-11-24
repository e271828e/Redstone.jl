# L9a verifier probes, run from the pinned worktree with --project=test.
module P
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Base.CoreLogging: with_logger
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
const R = Redstone

tri() = Group((; plant = Plant(), ctl = DiscreteAccumulator(3.0), trig = Trigger(0.5));
              local_wires = ("plant/y" => "trig/sig",),
              input_wires = ("u" => "plant/u", "e" => "ctl/e"))
tri_tree(q, acc, trig_state, u, e) =
    combine(at("plant", set(x = (q = q,))), at("ctl", set(s = (acc = acc,))),
            at("trig", set(m = (state = trig_state,))), set(u = (u = u, e = e)))

say(k, v) = println("PROBE ", k, " => ", v)

# L9a-005/006/067/170/172/177: what a Build and an Activation hold
b = build(tri())
say("Build fields", fieldnames(R.Build))
say("Structure fields", fieldnames(R.Structure))
say("Outputs fields", fieldnames(typeof(b.outputs)))
say("isdefined Redstone.Dataflow", isdefined(R, :Dataflow))
say("Activation fields", fieldnames(R.Activation))
say("activations keys after build", collect(keys(b.activations)))
act = R.activation(b, R.ProbeDual)
say("activation(ProbeDual) type", typeof(act))
say("Layout fields", fieldnames(typeof(act.layout)))

# L9a-023/024/025: the stop policy surface
say("StopPolicy fields", fieldnames(R.StopPolicy))
say("isdefined StopFlag", isdefined(R, :StopFlag))
say("run! kwargs mention stop_on", any(m -> :stop_on in Base.kwarg_decl(m), methods(R.run!)))
say("run! kwargs mention ignore_stop_requests", any(m -> :ignore_stop_requests in Base.kwarg_decl(m), methods(R.run!)))
say("Simulation kwargs mention stop_on", any(m -> :stop_on in Base.kwarg_decl(m), methods(R.Simulation)))
say("isdefined SimulationTermination", isdefined(R, :SimulationTermination))

# L9a-033/037: the specialized plan, its lens type and codegen time per shape
sim = Simulation(tri(); Δt_frame = 1//10)
t_compile = @elapsed plan = compile_plan(tri_tree(SVector(1.0, 2.0), 3.0, :fired, 4.0, 5.0), sim.model.deployment.build)
tree = tri_tree(SVector(9.0, 8.0), 7.0, :armed, 6.0, 5.5)
t_first = @elapsed apply!(sim.model.exec, plan, tree)
t_second = @elapsed apply!(sim.model.exec, plan, tree)
say("lens type", typeof(plan.xs[1].authored))
say("isdefined Getter", isdefined(R, :Getter))
say("compile_plan s / first apply! s / second apply! s", (t_compile, t_first, t_second))
say("apply! allocations", @ballocated(apply!($(sim.model.exec), $plan, $tree)))
# a second, new shape in the same process (codegen once per shape, Redstone's own code warm)
tree2(q, acc) = combine(at("plant", set(x = (q = q,))), at("ctl", set(s = (acc = acc,))))
t_compile2 = @elapsed plan2 = compile_plan(tree2(SVector(1.0, 2.0), 3.0), sim.model.deployment.build)
t_first2 = @elapsed apply!(sim.model.exec, plan2, tree2(SVector(1.0, 2.0), 4.0))
say("second shape compile_plan s / first apply! s", (t_compile2, t_first2))

# L9a-040: is there a `capture`?
say("isdefined capture", isdefined(R, :capture))

# L9a-056: phase body names
say("phase_bodies keys", keys(phase_bodies(sim)))

# L9a-065: Simulation(root; ...) equals Simulation(build(root); ...)
say("Simulation(root) method", which(R.Simulation, Tuple{R.AbstractComponent}))

# L9a-075/080/092/093: the diagnostic cell's ring and its allocations
cell = R.DiagCell(R.EMPTY_DIAG)
d = R.UnboundedRun(Inf, String[])
R.report_cell!(cell, d)   # warm
R._take!(cell)
allocs = Int[]
for i in 1:20
    push!(allocs, @allocated R.report_cell!(cell, d))
end
say("ring length after 20 emissions", length((@atomic cell.batch).ring))
say("bytes per emission 1..20 after a drain", allocs)
say("heartbeat field atomic", isconst(R.DiagCell, :heartbeat) ? "const" : Base.isfieldatomic(R.DiagCell, :heartbeat))

# L9a-089: status vector per publication
say("FrameworkStatus fields", (fieldnames(R.FrameworkStatus), fieldtypes(R.FrameworkStatus)))
say("WriterStatus isbits", isbitstype(R.WriterStatus))

# L9a-112: the trace header and the schemas
say("Trace fields", (fieldnames(R.Trace), fieldtypes(R.Trace)))

# L9a-126: StepError parametrized
say("StepError params", R.StepError)

# L9a-148/157: a warning outside a build logs, inside a build lands on the list
logger = Test.TestLogger()
with_logger(logger) do
    R._warn!(d)
end
say("standalone _warn! logged records", length(logger.logs))
lst = R.Diagnostic[]
logger2 = Test.TestLogger()
with_logger(logger2) do
    R.with(R.BUILD_WARNINGS => lst) do
        R._warn!(d)
    end
end
say("bound _warn! list / logs", (length(lst), length(logger2.logs)))
say("warnings(build) type", typeof(warnings(b)))

# L9a-108/109: a permuted stage return is accepted, paired by name
end

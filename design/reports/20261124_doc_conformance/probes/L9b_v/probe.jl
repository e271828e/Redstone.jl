# L9b_v probes, run from the pinned worktree with --project=test.
module L9bProbe
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const T = joinpath(pwd(), "test")
include(joinpath(T, "imports.jl"))
include(joinpath(T, "fixtures.jl"))
include(joinpath(T, "utils.jl"))
const R = Redstone

p(tag, x) = println(rpad(tag, 6), " ", x)
function tryshow(tag, f)
    try
        p(tag, ("returned", f()))
    catch err
        if err isa R.DiagnosticError
            p(tag, ("threw", typeof(err), [(typeof(d), hasproperty(d, :reason) ? d.reason : nothing) for d in (err.carried isa Vector ? err.carried : [err.carried])]))
        else
            p(tag, ("threw", typeof(err), sprint(showerror, err)[1:min(end, 200)]))
        end
    end
end

# P1 Simulation's fields, mutability
p("P1", (fieldnames(R.Simulation), ismutabletype(R.Simulation)))
# P2 Deployment's fields
p("P2", fieldnames(R.Deployment))
# P3 DataPlane's fields
p("P3", fieldnames(R.DataPlane))
# P4 Run's fields
p("P4", fieldnames(R.Run))
# P5 ModelState fields, count
p("P5", (fieldnames(R.ModelState), fieldcount(R.ModelState)))
# P6 Activation, Structure, Model fields
p("P6", (fieldnames(R.Activation), fieldnames(R.Structure), fieldnames(R.Model)))

b = build(sampled_loop())
dep = Deployment(b; Δt_frame = 1//10)
# P7 recording keywords on Simulation(deployment)
tryshow("P7", () -> Simulation(dep; trace = false))
# P8 trace(sim) on a built sim (placeholder run, no trace)
sim = Simulation(dep)
p("P8a", (lifecycle(sim), sim.run.trace))
tryshow("P8", () -> trace(sim))
# P9 Δt_frame required
tryshow("P9", () -> Deployment(b))
# P10 a fixed step not dividing Δt_frame: no :not_harmonic refusal
tryshow("P10", () -> (d = Deployment(build(feedback_model()); Δt_frame = 1//10, h_max = 3//100); (d.h_max, d.lattice)))
tryshow("P10b", () -> (d = Deployment(b; Δt_frame = 1//10, Δt_base = 1//10, h_max = 7//100); d.lattice))
# P11 claim refusals before allocation
m = Model(dep)
s1 = Simulation(m)
tryshow("P11a", () -> Simulation(m))
m2 = Model(dep); init!(m2, set(u = (ref = 0.0,)))
tryshow("P11b", () -> Simulation(m2))
p("P11c", (m2.claimed,))
# P12 descriptor envelope
d = descriptor(b)
p("P12", (keys(d), d.format_version, d.kind, typeof(d.redstone_version)))
p("P12b", [r.name for r in d.build.structure.types])
p("P12c", d.build.structure.root_inputs)
# P13 frame! with a hook that throws InterruptException
struct InterruptHooks <: R.FrameHooks end
R.frame_top!(::InterruptHooks) = throw(InterruptException())
R.settled!(::InterruptHooks) = false
m3 = Model(dep); init!(m3, set(u = (ref = 0.0,)))
try
    frame!(m3, 1, InterruptHooks())
    p("P13", "returned")
catch err
    p("P13", (typeof(err), err isa R.StepError ? (err.host, typeof(err.cause)) : nothing, m3.status))
end
# P14 frame! return type with NoHooks
m4 = Model(dep); init!(m4, set(u = (ref = 0.0,)))
p("P14", (frame!(m4, 1), typeof(frame!(m4, 2))))
# P15 show(Outputs)
println("P15 ---"); show(stdout, MIME"text/plain"(), b.outputs); println()
# P16 terminal_producer on nested assembly
bw = build(bare_ports_world())
p("P16", (terminal_producer(bw.structure, ("plant/spin", :u)), terminal_producer(bw.structure, ("plant/summer", :u)), terminal_producer(bw.structure, ("", :u))))
# P17 trim!(model) kwarg defaults and grid helpers' files
for meth in methods(trim!)
    println("P17  ", meth)
end
p("P17b", Base.kwarg_decl(first(methods(trim!, (R.Model{Float64}, R.TrimProblem)))))
p("P18", [(f, basename(string(first(methods(getfield(R, f))).file))) for f in (:_frame_slack, :_frames_to, :_frame_at, :_grid_time)])
# P19 lattice unit and chart columns
dd = Deployment(b; Δt_frame = 1//10, Δt_base = 1//4)
p("P19", (dd.lattice.unit, gcd(1//10, 1//4)))
println("P19 ---"); show(stdout, MIME"text/plain"(), dd); println()
# P20 checkpoint(sim) composes the model's; restore!(sim, cp) grid check
sim2 = Simulation(Deployment(b; Δt_frame = 1//10)); init!(sim2, set(u = (ref = 1.0,))); step!(sim2; frames = 2)
cp = checkpoint(sim2)
p("P20", (typeof(cp), fieldnames(typeof(cp)), cp.frame, cp.boundary))
ms = cp.state
bad = R.ModelState{Float64}(ms.x, ms.s, ms.m, ms.table, ms.prior, ms.stepper, ms.t + 0.03, ms.t₀, ms.deployment, ms.layout)
tryshow("P20b", () -> restore!(sim2, R.Checkpoint(bad, cp.frame, cp.boundary)))
# P21 failure descriptor kind
tryshow("P21", () -> build(feedback_model(; feedback_port = "power")))
try build(feedback_model(; feedback_port = "power")) catch err
    fd = descriptor(err); p("P21b", (fd.kind, keys(fd.failure)))
end
end

# K11 verifier probes. Run from W with --project=test.
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
include(joinpath(pwd(), "test", "imports.jl"))
include(joinpath(pwd(), "test", "fixtures.jl"))
include(joinpath(pwd(), "test", "utils.jl"))

say(tag, x) = println(tag, " => ", x)
# test/test_readers.jl:114's helper: every store, the root inputs and the clock
world(model::Model) = (copy(model.exec.xbuf),
                       [s === nothing ? nothing : s[] for s in model.exec.sstores],
                       [m === nothing ? nothing : m[] for m in model.exec.mstores],
                       [port(model, "", f) for f in model.deployment.build.structure.root_inputs],
                       model.exec.clock.t)
world(sim::Simulation) = world(sim.model)

# K11-005: a cycle is a build error naming the cycle
try
    build(feedback_model(feedback_port = "power"))
    say("K11-005", "no error")
catch err
    d = only(diagnostics(err))
    say("K11-005 type", typeof(d))
    say("K11-005 members", d.members)
    say("K11-005 msg", sprint(showerror, DiagnosticError(d)))
end

# K11-029 / K11-053: trim writes the root input it solved for; a failed trim leaves stores alone
decide_u(d) = combine(at("c", condition(Pendulum(); θ = 0.5)), set(u = (in = d.u,)))
prob = TrimProblem(guess = (u = 0.0,), lower = (u = -Inf,), upper = (u = Inf,),
                   condition = decide_u, reads = reads(ω̇ = get_deriv("c", :ω)),
                   residuals = (r, d) -> (torque = r.ω̇,), tolerances = (torque = 1e-9,))
sim = Simulation(fed(Pendulum(), :u); Δt_frame = 1//10)
rep = trim!(sim, prob; baseline = set(u = (in = 0.0,)))
say("K11-029 converged", rep.converged)
say("K11-029 solved u / root input", (rep.solution.u, port(sim, "", :in)))
infeasible = TrimProblem(guess = (u = 0.0,), lower = (u = -1.0,), upper = (u = 1.0,),
                         condition = decide_u, reads = reads(ω̇ = get_deriv("c", :ω)),
                         residuals = (r, d) -> (torque = r.ω̇,), tolerances = (torque = 1e-9,))
before = world(sim); st = state(sim, "c"); rin = port(sim, "", :in)
rep2 = trim!(sim, infeasible; baseline = set(u = (in = 0.0,)))
say("K11-053 converged", rep2.converged)
say("K11-053 world unchanged", world(sim) == before)
say("K11-053 state/root unchanged", (state(sim, "c") === st, port(sim, "", :in) === rin, lifecycle(sim)))

# K11-037: run!(sim; pace = 1, t_end = …) is accepted (pace Int); t_end = 1000 accepted unpaced
t = @elapsed run!(sim; pace = 1, t_end = 0.3)
say("K11-037 paced run", (lifecycle(sim), sim.model.exec.clock.t, round(t; digits = 2)))
sim2 = Simulation(fed(Pendulum(), :u); Δt_frame = 1//10)
init!(sim2, set(u = (in = 0.0,)))
run!(sim2; t_end = 1000)
say("K11-037 t_end=1000", (lifecycle(sim2), sim2.model.exec.clock.t))

# K11-045 / K11-002: the drain applies a staged batch at the frame top and traces it;
# the trace holds the header and input batches, not outputs
sim3 = Simulation(fed(Pendulum(), :u); Δt_frame = 1//10)
init!(sim3, set(u = (in = 0.0,)))
stage!(sim3, "in" => 2.0)
step!(sim3)
trc = trace(sim3)
say("K11-045 trace fields", fieldnames(typeof(trc)))
say("K11-045 batches", trc.batches)
say("K11-045 schemas", trc.schemas)
say("K11-045 root input after step", port(sim3, "", :in))

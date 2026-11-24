# K14a verifier probes, run from the pinned worktree with --project=test.
module K14aV
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone; using Test.Logging: with_logger
const T = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/"
include(T * "imports.jl"); include(T * "fixtures.jl"); include(T * "utils.jl")

say(id, args...) = println(id, " | ", args...)
pend_base() = set(u = (in = 0.0,))
both_reads() = reads(ω̇ = get_deriv("c", :ω), θ = get_state("c", :θ))
torque_only(r, d) = (torque = r.ω̇,)
try_(f) = try f() catch err err end

# P1 (K14a-006): no pair-keyed, path-addressed `condition` method exists.
e = try_(() -> condition("c.u" => 1.0))
say("P1 K14a-006", "condition(\"c.u\" => 1.0) -> ", typeof(e))
say("P1 K14a-006", "a condition method taking a Pair: ",
    any(m -> occursin("Pair", string(m.sig)), methods(condition)))
sim = Simulation(fed(Pendulum(), :u); Δt_frame = 1//10)
init!(sim, at("c", set(u = (u = 2.5,))))
say("P1 K14a-006", "init! with at(\"c\", set(u = (u = 2.5,))): root input in = ", port(sim, "", :in))
sim = Simulation(fed(Pendulum(), :u); Δt_frame = 1//10)
e = try_(() -> init!(sim, at("c", set(u = (var"in.u" = 2.5,)))))
say("P1 K14a-006", "dotted field name -> ", typeof(e))

# P2 (K14a-009): a condition entry naming an internally wired input.
spend = Group((; ctl = DiscreteAccumulator(1.0), c = Pendulum());
              local_wires = ("ctl/u" => "c/u",), input_wires = ("in" => "ctl/e",))
sim = Simulation(spend; Δt_frame = 1//10)
e = try_(() -> init!(sim, combine(at("ctl", set(s = (acc = 4.0,))), set(u = (in = 0.0,)),
                                  at("c", set(u = (u = 1.0,))))))
d = e isa DiagnosticError ? diagnostics(e) : e
say("P2 K14a-009", typeof(e), " ", [(typeof(x), getfield(x, :reason)) for x in d])
say("P2 K14a-009", "message: ", Redstone.message(only(d)))

# P3 (K14a-002, K14a-013): a closure condition; a check out of tolerance at commit.
params = (θ = 0.3,)
decide_u(d) = combine(at("c", condition(Pendulum(); θ = params.θ)), set(u = (in = d.u,)))
prob(ct) = TrimProblem(guess = (u = 0.0,), lower = (u = -Inf,), upper = (u = Inf,),
    condition = d -> decide_u(d), reads = both_reads(), residuals = torque_only,
    tolerances = (torque = 1e-9,), checks = (r, d) -> (θ = r.θ - 0.25,),
    check_tolerances = (θ = ct,))
sim = Simulation(fed(Pendulum(), :u); Δt_frame = 1//10)
logger = Test.TestLogger()
rep = with_logger(logger) do
    trim!(sim, prob(1e-6); baseline = pend_base())
end
say("P3 K14a-002", "closure condition converged = ", rep.converged, ", u = ", rep.solution.u)
say("P3 K14a-013", "committed_checks = ", rep.committed_checks,
    "; logs: ", [(r.level, string(r.message)[1:min(end, 90)]) for r in logger.logs])
say("P3 K14a-013", "TrimReport fields: ", fieldnames(TrimReport))

# P4 (K14a-016): a malformed check is refused at the guess evaluation, before any solve.
struct CountBackend; n::Base.RefValue{Int}; end
Redstone.solve(b::CountBackend, eval!, d0, lower, upper, tol) =
    (b.n[] += 1; (; d = d0, status = :count, n_evaluations = 1, n_iterations = 0))
cb = CountBackend(Ref(0))
bad = TrimProblem(guess = (u = 0.0,), lower = (u = -Inf,), upper = (u = Inf,),
    condition = decide_u, reads = both_reads(), residuals = torque_only,
    tolerances = (torque = 1e-9,), checks = (r, d) -> (wrong = r.θ,),
    check_tolerances = (θ = 1e-6,))
sim = Simulation(fed(Pendulum(), :u); Δt_frame = 1//10)
e = try_(() -> trim!(sim, bad; baseline = pend_base(), backend = cb))
d = only(diagnostics(e))
say("P4 K14a-016", typeof(d), " field=", d.field, " reason=", d.reason,
    "; backend calls = ", cb.n[], "; lifecycle = ", lifecycle(sim))

# P5 (K14a-021): reads(name = get_deriv(path, leaf), name = get_face(leaf)).
rs = reads(v̇ = get_deriv("c", :ω), θf = get_face("θ"))
say("P5 K14a-021", typeof(rs), " labels=", keys(rs.selectors))
end

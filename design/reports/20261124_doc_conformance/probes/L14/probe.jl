# L14 probe: log entries D-064 .. D-475 (trim, linearize, condition algebra).
using Test, Redstone, StaticArrays, LinearAlgebra, ForwardDiff, ComponentArrays
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
include(joinpath(W, "utils.jl"))
using Redstone
import Redstone: ServiceLifecycle, ConditionShapeDrift, TapResolution, TrimProblemInvalid, ReadSetMisuse,
    ConditionNodeMisuse, ArgumentInvalid, DiagnosticError, ConditionResolution, compile_plan, resolve_condition,
    _scratch, match_leaf, TrimReport, LinearizeDual

kinds(f) = try; f(); "no error"; catch e
    e isa DiagnosticError ? (ds = e.carried isa Vector ? e.carried : [e.carried];
        join(["$(typeof(d).name.name):$(hasproperty(d,:reason) ? d.reason : "")" for d in ds], ", ")) : "OTHER $(typeof(e))"
end
function diag(f); try; f(); nothing; catch e; e isa DiagnosticError ? (e.carried isa Vector ? e.carried : [e.carried]) : [e]; end; end

PG = 9.81
lin_pend() = Group((; s = Sum(), c = Pendulum()); local_wires = ("s/e" => "c/u",),
                   input_wires = ("τ" => "s/a", "d" => "s/b"),
                   output_wires = ("c/θ" => "θ", "s/e" => "u_eff"))
lin_point(θ = 0.3) = combine(at("c", condition(Pendulum(); θ = θ)), set(u = (τ = PG * sin(θ), d = 0.0)))
tp = taps(x = (θ = get_state("c", :θ), ω = get_state("c", :ω)),
          u = (τ = get_input(:τ), d = get_input(:d)),
          y = (θ = get_face(:θ), u_eff = get_face(:u_eff)))

sim = Simulation(lin_pend(); Δt_frame = 1//10)
println("probe:30 built-state default linearize: ", kinds(() -> linearize(sim, tp)))
d = diag(() -> linearize(sim, tp)); println("probe:31 ", d[1].op, " ", d[1].status, " ", d[1].legal, " fields=", fieldnames(ServiceLifecycle))
println("probe:32 about on built sim: ", kinds(() -> linearize(sim, tp; about = lin_point())))
init!(sim, lin_point())
lz = linearize(sim, tp)
println("probe:34 types: ", [typeof(getfield(lz, f)) for f in fieldnames(Linearization)])
println("probe:35 field types: ", fieldtypes(Linearization))
lb = labeled(lz)
println("probe:36 labeled: ", typeof(lb.A), " ", typeof(lb.x₀), " A[:θ,:ω]=", lb.A[:θ, :ω])
empty_lz = linearize(sim, taps(x = (θ = get_state("c", :θ),)))
le = labeled(empty_lz)
println("probe:38 empty lists: ", typeof(le.B), " ", typeof(le.u₀), " ", typeof(le.D), " ", typeof(le.C))
println("probe:39 t0 without about: ", kinds(() -> linearize(sim, tp; t0 = 1)))
println("probe:40 width 0: ", kinds(() -> linearize(sim, tp; width = 0)))
println("probe:41 about, no t0 time: ", linearize(sim, tp; about = lin_point()).x₀, " same width 1: ", linearize(sim, tp; about = lin_point(), width = 1).A == linearize(sim, tp; about = lin_point(), width = 8).A)
println("probe:42 dup site: ", kinds(() -> linearize(sim, taps(x = (a = get_state("c", :θ), b = get_state("c", "θ"))))))
dd = diag(() -> linearize(sim, taps(x = (a = get_state("c", :θ), b = get_state("c", "θ")))))
println("probe:43 dup fields: ", dd[1].label, " dup_of=", dd[1].duplicate_of)
println("probe:44 tap kind: ", kinds(() -> linearize(sim, taps(x = (a = get_input(:τ),)))))
println("probe:45 tap kind y gets_state: ", kinds(() -> linearize(sim, taps(y = (a = get_state("c", :θ),)))))
println("probe:46 .name/2nd-step tap on u/x; unindexed vector: see test_linearize")
println("probe:47 linearize non-taps: ", kinds(() -> linearize(sim, 3)))
# at refusals
prob = TrimProblem(guess = (u = 0.0,), lower = (u = -Inf,), upper = (u = Inf,),
                   condition = d -> set(u = (in = d.u,)), reads = reads(w = get_deriv("c", :ω)),
                   residuals = (r, d) -> (a = r.w,), tolerances = (a = 1e-9,))
println("probe:50 at('') set: ", kinds(() -> at("", set())))
println("probe:51 at('') reads: ", kinds(() -> at("", reads(w = get_deriv("c", :ω)))))
println("probe:52 at('') problem: ", kinds(() -> at("", prob)))
println("probe:53 at('') taps: ", kinds(() -> at("", tp)))
println("probe:54 problem fields: ", fieldnames(TrimProblem))
println("probe:55 positional ctor ok: ", try; TrimProblem(1,2,3,4,5,6,7,8,9); "yes"; catch; "no"; end)
println("probe:56 at(problem) reads type: ", typeof(at("x", prob).reads), " guess same: ", at("x", prob).guess === prob.guess)
# combinators
println("probe:58 combine dup: ", kinds(() -> init!(Model(fed(Pendulum(), :u); Δt_frame = 1//10), combine(set(u = (in = 1.0,)), set(u = (in = 2.0,))))))
dd = diag(() -> resolve_condition(combine(set(u = (in = 1.0,)), set(u = (in = 2.0,))), Model(fed(Pendulum(), :u); Δt_frame = 1//10).deployment.build))
println("probe:59 ", dd[1].origins)
dd = diag(() -> resolve_condition(override(set(u = (in = 1.0,)), set(u = (in = 2.0,))), Model(fed(Pendulum(), :u); Δt_frame = 1//10).deployment.build))
println("probe:60 override ok: ", dd === nothing || dd)
println("probe:61 override within-layer dup: ", kinds(() -> resolve_condition(override(set(u = (in = 1.0,)), combine(set(u = (in = 2.0,)), set(u = (in = 3.0,)))), Model(fed(Pendulum(), :u); Δt_frame = 1//10).deployment.build)))
println("probe:62 override ≥3 variadic: ", override(set(), set(), set()) isa Redstone.Override)
println("probe:63 combine(node,NT): ", kinds(() -> combine(set(), (;))))
println("probe:64 set(x=nothing): ", diag(() -> set(x = nothing))[1].reason)
println("probe:65 internally wired: ", kinds(() -> resolve_condition(at("c", set(u = (u = 1.0,))), sim.model.deployment.build)))
dd = diag(() -> resolve_condition(at("c", set(u = (u = 1.0,))), sim.model.deployment.build)); println("probe:66 producer=", dd[1].producer)
# ConditionShapeDrift
m = Model(fed(Pendulum(), :u); Δt_frame = 1//10)
tree = combine(at("c", set(x = (θ = 0.1, ω = 0.0))), set(u = (in = 1.0,)))
plan = compile_plan(tree, m.deployment.build, Float64)
ex = _scratch(m, Float64).exec
println("probe:70 same shape: ", kinds(() -> Redstone.apply!(ex, plan, combine(at("c", set(x = (θ = 0.2, ω = 0.0))), set(u = (in = 2.0,))))))
dd = diag(() -> Redstone.apply!(ex, plan, combine(at("d", set(x = (θ = 0.2, ω = 0.0))), set(u = (in = 2.0,)))))
println("probe:71 prefix: ", dd[1].reason, " ", dd[1].compiled, " ", dd[1].observed, " ", dd[1].position)
dd = diag(() -> Redstone.apply!(ex, plan, override(set(u = (in = 2.0,)))))
println("probe:72 tree_type: ", dd[1].reason, " ", dd[1].compiled isa Type, " ", dd[1].observed)
# trim problem refusals
bad = TrimProblem(guess = (u = 0.0,), lower = (u = 1.0,), upper = (u = -1.0,),
                  condition = d -> set(u = (in = d.u,)), reads = reads(w = get_deriv("c", :ω)),
                  residuals = (r, d) -> (a = r.w,), tolerances = (a = 0.0,), check_tolerances = (z = -1.0,))
dd = diag(() -> trim!(m, bad; baseline = set()))
println("probe:80 ", [(typeof(x).name.name, x.field, x.reason, x.key, x.value, x.bound) for x in dd])
println("probe:81 trim non problem: ", kinds(() -> trim!(m, 3; baseline = set())))
# Model status gates
m2 = Model(fed(Pendulum(), :u); Δt_frame = 1//10)
println("probe:85 status built; linearize about: ", kinds(() -> linearize(m2, taps(x = (θ = get_state("c", :θ),)); about = set(u = (in = 0.0,)))))
init!(m2, set(u = (in = 0.0,)))
println("probe:86 init! at consistent again: ", kinds(() -> init!(m2, set(u = (in = 0.0,)))), " ", m2.status)
println("probe:87 default lin at consistent: ", kinds(() -> linearize(m2, taps(x = (θ = get_state("c", :θ),)))))
# a real trim on the sim
tprob = TrimProblem(guess = (θ = 0.1,), lower = (θ = -π/2,), upper = (θ = π/2,),
                    condition = d -> combine(at("c", set(x = (θ = d.θ, ω = 0.0))), set(u = (in = 4.0,))),
                    reads = reads(ω̇ = get_deriv("c", :ω)), residuals = (r, d) -> (torque = r.ω̇,),
                    tolerances = (torque = 1e-9,))
m3 = Model(fed(Pendulum(), :u); Δt_frame = 1//10)
rep = trim!(m3, tprob; baseline = set(u = (in = 0.0,)))
println("probe:92 report: ", rep.converged, " ", rep.status, " ", rep.solution, " ", rep.committed_residuals, " ", rep.committed_checks, " ", rep.saturated, " ", rep.fired_events, " ", m3.status)
# not converging leaves model untouched
unc = TrimProblem(guess = (θ = 0.1,), lower = (θ = -0.01,), upper = (θ = 0.01,),
                  condition = tprob.condition, reads = tprob.reads, residuals = tprob.residuals,
                  tolerances = (torque = 1e-9,))
m4 = Model(fed(Pendulum(), :u); Δt_frame = 1//10)
rep2 = trim!(m4, unc; baseline = set(u = (in = 0.0,)))
println("probe:97 unconverged: ", rep2.converged, " ", rep2.status, " ", rep2.saturated, " committed=", rep2.committed_residuals, " status=", m4.status)
# bypassed problem with no decisions
rep3 = trim!(Model(fed(Pendulum(), :u); Δt_frame = 1//10), TrimProblem(guess = (;), lower = (;), upper = (;),
     condition = d -> set(u = (in = 0.0,)), reads = reads(ω̇ = get_deriv("c", :ω)),
     residuals = (r, d) -> (torque = r.ω̇,), tolerances = (torque = 1e9,)); baseline = set())
println("probe:103 bypass: ", rep3.status, rep3.n_evaluations, rep3.n_iterations, rep3.converged)
# override commit and a throw at commit is not caught (see model.jl); backend with open status
struct FakeBackend end
Redstone.solve(::FakeBackend, eval!, d0, lower, upper, tol) = (; d = d0 .* 0 .+ asin(4.0/9.81), status = :weird, n_evaluations = 7, n_iterations = 3)
rep4 = trim!(Model(fed(Pendulum(), :u); Δt_frame = 1//10), tprob; baseline = set(u = (in = 0.0,)), backend = FakeBackend())
println("probe:107 fake backend: ", rep4.converged, " ", rep4.status, " ", rep4.n_evaluations, " ", rep4.n_iterations)
class = Redstone.solve(LevenbergMarquardt(), (r, J, d) -> nothing, [0.0], [0.0], [0.0], [1.0])
# face matching D-418
println("probe:110 ", match_leaf("a.b[1]", [:a, Symbol("a.b")]), " ", match_leaf("a.bc", [:a, Symbol("a.b")]), " ", match_leaf(Symbol("a.b"), [:a, Symbol("a.b")]))
# subsystem absent, exports
println("probe:112 ", isdefined(Redstone, :subsystem), " ", isdefined(Redstone, :NLoptBackend), " ", isdefined(Redstone, :capture), " ", isdefined(Redstone, :UninitializedSlots), " ", isdefined(Redstone, :LinearizeDual), " exported LinearizeDual: ", :LinearizeDual in names(Redstone))
println("probe:113 UninitializedInputs: ", kinds(() -> init!(Model(fed(Pendulum(), :u); Δt_frame = 1//10), set())))
dd = diag(() -> init!(Model(fed(Pendulum(), :u); Δt_frame = 1//10), set())); println("probe:114 ", dd[1].faces)
println("done")

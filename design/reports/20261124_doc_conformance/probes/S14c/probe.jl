# S14c probes: spec §14.9, §14.10, Appendix B and C entries.
using Redstone, ComponentArrays
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
include(joinpath(W, "test", "RedstoneTests.jl"))
const T = RedstoneTests
include(joinpath(W, "test", "imports.jl"))
using Test, StaticArrays, ForwardDiff

function caught(f)
    try f(); return nothing catch e; return e end
end
pr(tag, x) = println("PROBE ", tag, " => ", x)

# 1. UninitializedInputs: carrier policy and op
sim = Simulation(T.lin_pend(); Δt_frame = 1//10)
e1 = caught(() -> init!(sim, set()))
pr("uninit init! carrier", typeof(e1))
pr("uninit init! op/faces", (e1.carried.op, e1.carried.faces))
pr("uninit descriptor policy", try Redstone.descriptor(e1) catch x; "descriptor err: $(typeof(x))" end)
e1b = caught(() -> linearize(sim, T.lin_taps(); about = set()))
pr("uninit linearize carrier/op", (typeof(e1b), e1b.carried.op))
e1c = caught(() -> trim!(Simulation(T.fed(T.Pendulum(), :u); Δt_frame = 1//10), T.θ_alone_problem(); baseline = set()))
pr("uninit trim! carrier/op", e1c === nothing ? "no throw" : (typeof(e1c), e1c.carried isa Redstone.Diagnostic ? e1c.carried.op : e1c.carried))

# 2. collected carriers of the other kinds
e2 = caught(() -> init!(Simulation(T.lin_pend(); Δt_frame = 1//10), combine(set(u = (τ = 1.0, d = 0.0)), set(u = (τ = 2.0,)))))
pr("duplicate carrier", (typeof(e2), [typeof(d) for d in diagnostics(e2)]))
dup = diagnostics(e2)[1]
pr("duplicate fields", (dup.path, dup.store, dup.field, dup.face, dup.origins))
e2b = caught(() -> init!(Simulation(T.lin_pend(); Δt_frame = 1//10), at("c", set(x = (nope = 1.0,)))))
pr("condres carrier/reason", (typeof(e2b), [d.reason for d in diagnostics(e2b)]))
e2c = caught(() -> set(x = nothing))
pr("misuse set_payload", (typeof(e2c), e2c.carried.reason, e2c.carried.payload))
e2d = caught(() -> combine(set(), (a = 1,)))
pr("misuse not_a_node", (typeof(e2d), e2d.carried.reason, e2d.carried.in_hand, e2d.carried.observed))
e2e = caught(() -> at("", set()))
pr("misuse empty prefix", (typeof(e2e), e2e.carried.reason))
e2f = caught(() -> at("", reads(a = get_state("c", :θ))))
pr("readset empty prefix", (typeof(e2f), e2f.carried.reason))

# 3. linearize: t0 default and t0 without about
model = Model(T.fed(T.TimedDecay()); Δt_frame = 1//10)
tp = taps(x = (q = get_state("c", :q),))
l0 = linearize(model, tp; about = set(u = (in = 0.0,)))
l1 = linearize(model, tp; about = set(u = (in = 0.0,)), t0 = 0)
pr("about without t0 equals t0 = 0", (l0.ẋ₀, l1.ẋ₀, l0.ẋ₀ == l1.ẋ₀))
l2 = linearize(model, tp; about = set(u = (in = 0.0,)), t0 = 1//2)
pr("about t0 = 1//2 xdot", l2.ẋ₀)
e3 = caught(() -> linearize(model, tp; t0 = 0))
pr("t0 without about", (typeof(e3), e3.carried.reason, e3.carried.argument))
e3b = caught(() -> linearize(model, tp; about = set(u = (in = 0.0,)), t0 = π))
pr("t0 other form", (typeof(e3b), e3b.carried.reason, e3b.carried.argument))
pr("width default", first(methods(linearize, (Model{Float64}, Taps))))
pr("LINEARIZE_WIDTH", Redstone.LINEARIZE_WIDTH)

# 4. printing
sim2 = T.lin_pend_sim()
lz = linearize(sim2, T.lin_taps())
show(stdout, MIME"text/plain"(), lz); println()
lb = labeled(lz)
show(stdout, MIME"text/plain"(), lb); println()
pr("fields types", [(f, fieldtype(Linearization, f)) for f in fieldnames(Linearization)])
pr("plain types", (typeof(lz.ẋ₀), typeof(lz.A)))
pr("labeled types", (typeof(lb.ẋ₀), typeof(lb.A)))
pr("plain print equals labeled print", sprint(show, MIME"text/plain"(), lz) == sprint(show, MIME"text/plain"(), lb))

# 5. TrimProblem lift
pbad = TrimProblem(guess = (u = 0.0,), lower = (u = -Inf,), upper = (u = Inf,),
                   condition = T.decide_u, reads = (;), residuals = T.torque_only,
                   tolerances = (torque = 1e-9,))
pr("lift passes non-Reads", at("rig", pbad).reads)
pgood = T.u_problem()
pr("lift Reads", at("rig", pgood).reads.prefixes)
pr("TrimProblem fields", fieldnames(TrimProblem))
e5 = caught(() -> at("", pgood))
pr("lift empty prefix", (typeof(e5), e5 isa DiagnosticError ? e5.carried.reason : e5))

# 6. solve seam and LevenbergMarquardt
lm = LevenbergMarquardt()
pr("LM fields", (lm.maxiter, lm.λ₀))
res = Redstone.solve(lm, (r, J, d) -> (r[1] = d[1] - 2; J === nothing || (J[1, 1] = 1.0); nothing),
                     [0.0], [-Inf], [Inf], [1e-9])
pr("solve return", (keys(res), res.status, res.n_evaluations, res.n_iterations))

# 7. checkpoint
cp = checkpoint(sim2)
pr("Checkpoint fields", fieldnames(typeof(cp)))
pr("ModelState fields", fieldnames(typeof(cp.state)))

# 8. tap refusals: carriers
e8 = caught(() -> linearize(sim2, taps(x = (a = get_output("c", :θ),), y = (b = get_state("c", :θ),))))
pr("tap kind carrier", (typeof(e8), [(typeof(d), d.reason) for d in diagnostics(e8)]))
e8b = caught(() -> taps(x = 2.0))
pr("taps not list", (typeof(e8b), e8b.carried.reason, e8b.carried.label))

# 9. trim commit warnings: carrier kinds are warnings
pr("severities", (Redstone.severity(Redstone.TrimCommitEvents(events = [("a", :b)])),
                  Redstone.severity(Redstone.TrimCommitResiduals(residuals = [(:a, 1.0, 1.0)])),
                  Redstone.severity(Redstone.TrimCommitChecks(checks = [(:a, 1.0, 1.0)])),
                  Redstone.severity(Redstone.UninitializedInputs(op = :init!, faces = [:a])),
                  Redstone.severity(Redstone.ConditionShapeDrift(reason = :tree_type))))

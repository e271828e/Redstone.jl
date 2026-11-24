module P
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const T = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/"
include(T * "imports.jl")
include(T * "fixtures.jl")
include(T * "utils.jl")
using Base.CoreLogging: NullLogger, with_logger

const PEND_G_L = 9.81
const PEND_C = 0.5
pend_base() = set(u = (in = 0.0,))
decide_u(d) = combine(at("c", condition(Pendulum(); θ = 0.5)), set(u = (in = d.u,)))
rd() = reads(ω̇ = get_deriv("c", :ω))
tor(r, d) = (torque = r.ω̇,)
prob(; kw...) = TrimProblem(; guess = (u = 0.0,), lower = (u = -Inf,), upper = (u = Inf,),
    condition = decide_u, reads = rd(), residuals = tor, tolerances = (torque = 1e-9,), kw...)

function err(f)
    try; f(); nothing; catch e; e; end
end
kinds(e) = e isa DiagnosticError ? (e.carried isa Diagnostic ? [typeof(e.carried)] : [typeof(d) for d in e.carried]) : typeof(e)
quiet(f) = with_logger(f, NullLogger())
pr(tag, x) = println("PROBE ", tag, " => ", x)

# throwing handler (commit-only event)
struct Boom <: AbstractComponent end
x_init(::Boom) = (θ = 0.0, ω = 0.0)
u_types(::Boom) = (u = Float64,)
y_types(::Boom) = (θ = Float64, ω = Float64)
y_state(::Boom, (; x)) = (θ = x.θ, ω = x.ω)
x_deriv(::Boom, (; x, u)) = (θ = x.ω, ω = -9.81 * sin(x.θ) - 0.5 * x.ω + u.u)
boom_guard(c::Boom, (; x)) = x.θ > 0.3
const ARMED = Ref(false)
boom_handler(::Boom, (; x)) = ARMED[] ? throw(InterruptException()) : (x = (θ = x.θ, ω = x.ω),)
state_events(::Boom) = (b = StateEvent(boom_guard, boom_handler),)
condition(::Boom; θ = 0.0, ω = 0.0) = set(x = (θ = θ, ω = ω))
boom_u(d) = combine(at("c", condition(Boom(); θ = 0.5)), set(u = (in = d.u,)))

struct Liar end
solve(::Liar, eval!, d0, lower, upper, tol) = (; d = d0, status = :converged, n_evaluations = 7, n_iterations = 3)

function main()
    # 1. totality
    sim = Simulation(fed(Pendulum(), :u); Δt_frame = 1//10)
    e = err(() -> init!(sim, set()))
    pr("1 init! empty", kinds(e)); pr("1 faces", e.carried.faces); pr("1 lifecycle", lifecycle(sim))
    e = err(() -> trim!(sim, prob(condition = d -> at("c", condition(Pendulum(); θ = 0.5)), guess=(u=0.0,)); baseline = set()))
    pr("1 trim! no baseline", kinds(e)); pr("1 lifecycle after", lifecycle(sim))
    # multiple root inputs, declaration order
    g = Group((; a = Pendulum(), b = Pendulum()); input_wires = ("zz" => "a/u", "aa" => "b/u"))
    s2 = Simulation(g; Δt_frame = 1//10)
    e = err(() -> init!(s2, set()))
    pr("1 two faces order", e.carried.faces)
    # 2. override
    ov = override(set(u = (in = 1.0,)), set(u = (in = 2.0,)))
    s3 = Simulation(fed(Pendulum(), :u); Δt_frame = 1//10)
    init!(s3, combine(ov, at("c", condition(Pendulum()))))
    pr("2 override value", s3.model.exec.store === nothing ? nothing : gather_cell(s3.model.exec.store, s3.model.exec.act.layout.addr[("", :in)]))
    e = err(() -> init!(s3, combine(set(u = (in = 1.0,)), set(u = (in = 2.0,)))))
    pr("2 combine collision", kinds(e))
    e = err(() -> init!(s3, override(set(u = (in = 1.0,)), combine(set(u = (in = 2.0,)), set(u = (in = 3.0,))))))
    pr("2 within-layer", kinds(e))
    e = err(() -> init!(s3, override(set(u = (in = 1.0,)), set(u = (in = 2.0,)), set(u = (in = 3.0,)))))
    pr("2 variadic", e)
    pr("2 variadic val", gather_cell(s3.model.exec.store, s3.model.exec.act.layout.addr[("", :in)]))
    pr("2 override type", typeof(override(set(u=(in=1.0,)), set(u=(in=2.0,)))))
    pr("2 override 1 arg", err(() -> override(set(u=(in=1.0,)))))
    # origin names both layers?
    e = err(() -> resolve_condition(override(set(u = (in = 1.0,)), set(u = (in = 2.0,))), s3.model.deployment.build, Float64))
    pr("2 resolve ok", e)
    # 3. model forms
    dep = Deployment(build(fed(Pendulum(), :u)); Δt_frame = 1//10)
    m = Model(dep)
    rep = trim!(m, prob(); baseline = pend_base())
    pr("3 model trim", (rep.converged, rep.status, rep.n_evaluations, rep.n_iterations, m.status))
    D = ForwardDiff.Dual{Nothing,Float64,1}
    md = Model(dep, D)
    pr("3 non_nominal", err(() -> trim!(md, prob(); baseline = pend_base())))
    m2 = Model(dep); sim2 = Simulation(m2)
    pr("3 claimed", err(() -> trim!(m2, prob(); baseline = pend_base())))
    pr("3 claimed bad problem", err(() -> trim!(m2, 3; baseline = pend_base())))
    # not a problem
    pr("3 not_a_problem", err(() -> trim!(Model(dep), 3; baseline = pend_base())))
    pr("3 t0 default/keywords", sprint(show, first(methods(trim!, (Model{Float64},TrimProblem)))))
    # 4. fields of the problem
    pr("4 fields", fieldnames(TrimProblem))
    pr("4 report fields", fieldnames(TrimReport))
    p = prob()
    pr("4 default checks", (p.checks(1,2), p.check_tolerances))
    # 5. TrimProblemInvalid
    bm() = Model(dep)
    inv(p) = (e = err(() -> trim!(bm(), p; baseline = pend_base())); e isa DiagnosticError ? [(typeof(d), hasfield(typeof(d), :field) ? getfield(d, :field) : nothing, hasfield(typeof(d), :reason) ? getfield(d,:reason) : nothing) for d in (e.carried isa Diagnostic ? [e.carried] : e.carried)] : e)
    pr("5 guess notNT", inv(prob(guess = 1.0)))
    pr("5 key mismatch", inv(prob(lower = (v = -Inf,))))
    pr("5 int field", inv(prob(guess = (u = 0,))))
    pr("5 inverted", inv(prob(lower = (u = 1.0,), upper = (u = -1.0,))))
    pr("5 tol neg", inv(prob(tolerances = (torque = -1.0,))))
    pr("5 tol inf", inv(prob(tolerances = (torque = Inf,))))
    pr("5 tol nan", inv(prob(tolerances = (torque = NaN,))))
    pr("5 reads not set", inv(prob(reads = 3)))
    pr("5 residual key mismatch", inv(prob(tolerances = (foo = 1e-9,))))
    pr("5 residual nonscalar", inv(prob(residuals = (r, d) -> (torque = [r.ω̇],))))
    pr("5 check key mismatch", inv(prob(checks = (r, d) -> (a = 1.0,), check_tolerances = (b = 1.0,))))
    pr("5 check nonscalar", inv(prob(checks = (r, d) -> (a = "x",), check_tolerances = (a = 1.0,))))
    pr("5 check tol 0", inv(prob(check_tolerances = (a = 0.0,))))
    pr("5 reads unknown", inv(prob(reads = reads(ω̇ = get_deriv("nope", :ω)))))
    pr("5 reads unknown leaf", inv(prob(reads = reads(ω̇ = get_deriv("c", :nope)))))
    pr("5 collected two", inv(prob(guess = 1.0, tolerances = (torque = -1.0,))))
    pr("5 residuals not callable", err(() -> trim!(bm(), prob(residuals = 3); baseline = pend_base())))
    # permuted
    pp = TrimProblem(guess = (u = 0.0, θ = 0.1), lower = (θ = -π/2, u = -Inf), upper = (θ = π/2, u = Inf),
        condition = d -> combine(at("c", set(x = (θ = d.θ, ω = 0.0))), set(u = (in = d.u,))),
        reads = reads(ω̇ = get_deriv("c", :ω), θ = get_state("c", :θ)),
        residuals = (r, d) -> (hold = r.θ - 0.3, torque = r.ω̇), tolerances = (torque = 1e-9, hold = 1e-9))
    rp = trim!(bm(), pp; baseline = pend_base())
    pr("5 permuted", (rp.converged, rp.solution, keys(rp.residuals)))
    # 6. nonconvergence
    sat = prob(lower = (u = -1.0,), upper = (u = 1.0,))
    msat = bm()
    rs = trim!(msat, sat; baseline = pend_base())
    pr("6 saturated", (rs.converged, rs.status, rs.saturated, rs.committed_residuals, rs.committed_checks, rs.solution))
    ss = Simulation(fed(Pendulum(), :u); Δt_frame = 1//10)
    rs2 = trim!(ss, sat; baseline = pend_base())
    pr("6 sim stays", lifecycle(ss))
    # custom backend lying
    rl = trim!(bm(), prob(); baseline = pend_base(), backend = Liar())
    pr("6 liar", (rl.converged, rl.status, rl.n_evaluations, rl.n_iterations))
    # 7. empty problem
    ep = TrimProblem(guess = (;), lower = (;), upper = (;), condition = d -> at("c", condition(Pendulum(); θ = 0.0)),
        reads = rd(), residuals = tor, tolerances = (torque = 1e-9,))
    re = trim!(bm(), ep; baseline = set(u = (in = 0.0,)))
    pr("7 empty", (re.converged, re.status, re.n_evaluations, re.n_iterations, re.committed_residuals))
    # checks
    ck = prob(checks = (r, d) -> (c = r.ω̇ + 1.0,), check_tolerances = (c = 0.1,))
    rc = nothing
    logs = Test.TestLogger()
    with_logger(logs) do
        rc = trim!(bm(), ck; baseline = pend_base())
    end
    pr("7 checks", (rc.converged, rc.committed_checks, [(l.level, first(split(string(l.message), ' '))) for l in logs.logs]))
    # at passes tolerances
    pp2 = at("rig", prob())
    pr("7 at fields", (pp2.tolerances, pp2.check_tolerances, pp2.guess))
    # 8. events
    trig = Group((; c = Pendulum(), trig = Trigger(0.3)); local_wires = ("c/θ" => "trig/sig",), input_wires = ("in" => "c/u",))
    logs = Test.TestLogger()
    rt = with_logger(logs) do
        trim!(Simulation(trig; Δt_frame = 1//10), prob(); baseline = pend_base())
    end
    pr("8 events", (rt.fired_events, [(l.level, first(split(string(l.message), ' '))) for l in logs.logs]))
    pr("8 sev", (severity(TrimCommitEvents(events = [("a", :b)])), severity(TrimCommitResiduals(residuals = [(:a,1.0,1.0)])), severity(TrimCommitChecks(checks = [(:a,1.0,1.0)]))))
    # snapback (residuals moved)
    # 9. throw in commit
    bg = Group((; c = Boom()); input_wires = ("in" => "c/u",))
    sb = Simulation(bg; Δt_frame = 1//10)
    pbm = prob(condition = boom_u)
    ARMED[] = true
    e = err(() -> trim!(sb, pbm; baseline = pend_base()))
    pr("9 interrupt", (typeof(e), e isa StepError ? (e.host, e.cause) : e, sb.model.status))
    ARMED[] = false
    mb = Model(Deployment(build(bg); Δt_frame = 1//10))
    ARMED[] = true
    e = err(() -> trim!(mb, pbm; baseline = pend_base()))
    pr("9 interrupt model", (typeof(e), e isa StepError ? (e.host, typeof(e.cause)) : e, mb.status))
    # 10. show and report
    rr = trim!(Simulation(fed(Pendulum(), :u); Δt_frame = 1//10), ck; baseline = pend_base())
    show(stdout, MIME"text/plain"(), rr); println()
    show(stdout, MIME"text/plain"(), rs); println()
    # 11. t0
    st = Simulation(fed(Pendulum(), :u); Δt_frame = 1//10)
    trim!(st, prob(); baseline = pend_base(), t0 = 2)
    pr("11 t0", st.model.exec.clock.t)
    # residual reading t: solve at t0
    tt = prob(residuals = (r, d) -> (torque = r.ω̇ + 0 * (r.ω̇ isa Float64 ? (println("PROBE t-nominal"); 0.0) : 0.0),))
    # 12. reads
    r12 = prob(reads = reads(ω̇ = get_deriv("c", :ω), uin = get_input("in"), o = get_output("c", :θ), s = get_state("c", :θ)),
               residuals = (r, d) -> (println("PROBE reads ", map(typeof, r)); (torque = r.ω̇,)))
    trim!(bm(), r12; baseline = pend_base())
    pr("12 reads types", reads(a = get_state("c", :θ)) isa Reads)
    pr("12 allocs", 0)
    # 13. build activations keyword
    pr("13 build methods", [m.sig for m in methods(build)])
    pr("13 solve", methods(solve))
    pr("13 empty trim ws", 0)
    # 14. condition Float64 sanity: trace header root-input cells
    sh = Simulation(fed(Pendulum(), :u); Δt_frame = 1//10)
    init!(sh, combine(set(u = (in = 3.0,)), at("c", condition(Pendulum()))))
    pr("14 header", typeof(sh.run.trace.header))
end
main()
end

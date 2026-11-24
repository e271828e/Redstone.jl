# S14b verifier probes. Run from W: JULIA_LOAD_PATH="@" julia --startup-file=no --project=test P
module S14bV
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
include(joinpath(W, "utils.jl"))

struct TimedDecay <: AbstractComponent end
x_init(::TimedDecay) = (q = 1.0,)
u_types(::TimedDecay) = (u = Float64,)
y_types(::TimedDecay) = (q = Float64,)
y_state(::TimedDecay, (; x)) = (q = x.q,)
x_deriv(::TimedDecay, (; x, u, t)) = (q = -t * x.q^2 + u.u,)

const ARM = Ref(false)
struct Bomb <: AbstractComponent end
x_init(::Bomb) = (q = 0.0,)
u_types(::Bomb) = (u = Float64,)
y_types(::Bomb) = (q = Float64,)
y_state(::Bomb, (; x)) = (ARM[] && x.q isa Float64) ? throw(InterruptException()) : (q = x.q,)
x_deriv(::Bomb, (; x, u)) = (q = u.u - x.q,)

struct Arming end
function Redstone.solve(::Arming, eval!, d0, lo, up, tol)
    out = Redstone.solve(LevenbergMarquardt(), eval!, d0, lo, up, tol)
    ARM[] = true
    out
end
struct Recorder; seen::Vector{Any}; end
function Redstone.solve(b::Recorder, eval!, d0, lo, up, tol)
    r = zeros(length(tol)); eval!(r, nothing, d0)
    push!(b.seen, (d0 = copy(d0), lower = copy(lo), upper = copy(up), tol = copy(tol), r0 = copy(r),
                   types = map(typeof, (d0, lo, up, tol))))
    Redstone.solve(LevenbergMarquardt(), eval!, d0, lo, up, tol)
end
struct Forbidden end
Redstone.solve(::Forbidden, args...) = error("backend called")

catcherr(f) = try f(); nothing catch e; e end
diags(e) = e isa DiagnosticError ? (e.carried isa AbstractVector ? e.carried : [e.carried]) : e

pend_base() = set(u = (in = 0.0,))
decide_u(d) = combine(at("c", condition(Pendulum(); θ = 0.5)), set(u = (in = d.u,)))

function main()
    println("== S14b-004/001: totality sites")
    n = Ref(0)
    prob = TrimProblem(guess = (u = 0.0,), lower = (u = -Inf,), upper = (u = Inf,),
                       condition = d -> (n[] += 1; at("c", condition(Pendulum(); θ = 0.5))),
                       reads = reads(ω̇ = get_deriv("c", :ω)), residuals = (r, d) -> (torque = r.ω̇,),
                       tolerances = (torque = 1e-9,))
    m = Model(fed(Pendulum(), :u); Δt_frame = 1//10)
    e = catcherr(() -> trim!(m, prob; baseline = set()))
    println("trim! incomplete: ", diags(e), " conditions evaluated=", n[], " status=", m.status)
    m = Model(fed(Pendulum(), :u); Δt_frame = 1//10)
    e = catcherr(() -> init!(m, at("c", condition(Pendulum()))))
    println("init! incomplete: ", diags(e), " status=", m.status)
    m = Model(fed(Pendulum(), :u); Δt_frame = 1//10)
    e = catcherr(() -> linearize(m, taps(x = (θ = get_state("c", :θ),)); about = at("c", condition(Pendulum()))))
    println("linearize about incomplete: ", diags(e))
    println("Build fields: ", fieldnames(Build), " hasfield input_faces: ", hasfield(Build, :input_faces))
    println("structure.root_inputs: ", m.deployment.build.structure.root_inputs)

    println("== S14b-002/029: packing and canonicalization")
    rec = Recorder(Any[])
    both = TrimProblem(guess = (θ = 0.1, u = 0.0), lower = (u = -Inf, θ = -π/2), upper = (θ = π/2, u = Inf),
                       condition = d -> combine(at("c", set(x = (θ = d.θ, ω = 0.0))), set(u = (in = d.u,))),
                       reads = reads(ω̇ = get_deriv("c", :ω), θ = get_state("c", :θ)),
                       residuals = (r, d) -> (torque = r.ω̇, hold = r.θ - 0.3),
                       tolerances = (hold = 1e-8, torque = 1e-9))
    rep = trim!(Model(fed(Pendulum(), :u); Δt_frame = 1//10), both; baseline = set(), backend = rec)
    s = rec.seen[1]
    println("d0=", s.d0, " lower=", s.lower, " upper=", s.upper, " tol=", s.tol, " r0=", s.r0, " types=", s.types)
    println("converged=", rep.converged, " solution=", rep.solution, " residuals keys=", keys(rep.residuals))

    println("== S14b-021: tolerances/residual seam")
    n[] = 0
    mk(; res, tol) = TrimProblem(guess = (u = 0.0,), lower = (u = -Inf,), upper = (u = Inf,),
                                 condition = d -> (n[] += 1; decide_u(d)), reads = reads(ω̇ = get_deriv("c", :ω)),
                                 residuals = res, tolerances = tol)
    for (label, p) in (("key mismatch", mk(res = (r, d) -> (torque = r.ω̇,), tol = (other = 1e-9,))),
                       ("residual non-real", mk(res = (r, d) -> (torque = "x",), tol = (torque = 1e-9,))),
                       ("tolerance Int", mk(res = (r, d) -> (torque = r.ω̇,), tol = (torque = 1,))))
        n[] = 0
        e = catcherr(() -> trim!(Model(fed(Pendulum(), :u); Δt_frame = 1//10), p; baseline = pend_base()))
        println(label, ": ", diags(e), " conditions evaluated before throw=", n[])
    end

    println("== S14b-037: clock in both halves")
    seen = Tuple{Bool,Float64}[]
    clocked = TrimProblem(guess = (u = 0.0,), lower = (u = -Inf,), upper = (u = Inf,),
                          condition = d -> set(u = (in = d.u,)), reads = reads(q̇ = get_deriv("c", :q)),
                          residuals = (r, d) -> (push!(seen, (r.q̇ isa Float64, ForwardDiff.value(r.q̇))); (b = r.q̇,)),
                          tolerances = (b = 1e-9,))
    trim!(Model(fed(TimedDecay()); Δt_frame = 1//10), clocked; baseline = set(), t0 = 2//5)
    println("first nominal=", first(seen), " first seeded=", first(x for x in seen if !x[1]), " (expect q̇=-0.4 at u=0)")

    println("== S14b-003: interrupt inside the commit's boundary zero")
    ARM[] = false
    bp = TrimProblem(guess = (q = 0.5,), lower = (q = -Inf,), upper = (q = Inf,),
                     condition = d -> at("c", set(x = (q = d.q,))), reads = reads(q̇ = get_deriv("c", :q)),
                     residuals = (r, d) -> (b = r.q̇,), tolerances = (b = 1e-9,))
    sim = Simulation(fed(Bomb()); Δt_frame = 1//10)
    e = catcherr(() -> trim!(sim, bp; baseline = set(u = (in = 1.0,)), backend = Arming()))
    println("sim: thrown=", typeof(e), " lifecycle=", lifecycle(sim))
    e isa StepError && println("  host=", e.host, " boundary=", e.boundary)
    ARM[] = false
    m = Model(fed(Bomb()); Δt_frame = 1//10)
    e = catcherr(() -> trim!(m, bp; baseline = set(u = (in = 1.0,)), backend = Arming()))
    println("model: thrown=", typeof(e), " status=", m.status)
    ARM[] = false

    println("== S14b-053/045: empty problem, committed residuals")
    calls = Ref(0); conds = Ref(0)
    ep = TrimProblem(guess = (;), lower = (;), upper = (;), condition = d -> (conds[] += 1; set()),
                     reads = reads(q̇ = get_deriv("c", :q)),
                     residuals = (r, d) -> (calls[] += 1; (b = r.q̇,)), tolerances = (b = 1e-9,))
    m = Model(fed(TimedDecay()); Δt_frame = 1//10)
    rep = trim!(m, ep; baseline = set(u = (in = 0.0,)), backend = Forbidden())
    println("status=", rep.status, " converged=", rep.converged, " n_eval=", rep.n_evaluations,
            " residual calls=", calls[], " condition calls=", conds[], " model status=", m.status,
            " committed=", rep.committed_residuals)
end
main()
end

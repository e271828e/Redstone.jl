# L14 verifier probes. Run from the pinned worktree:
#   JULIA_LOAD_PATH="@" julia --startup-file=no --project=test <this file>
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
include(joinpath(W, "utils.jl"))
import Redstone: TrimProblem, trim!, linearize, taps, reads, get_state, get_deriv, get_output,
    get_input, get_face, set, at, combine, override, condition, checkpoint, Taps

R = Redstone
p(tag, x) = println(tag, " => ", x)
catchd(f) = try f(); nothing catch e; e end
diag1(e) = e isa DiagnosticError ? (e.carried isa Vector ? e.carried : [e.carried]) : e

pend_base() = set(u = (in = 0.0,))
decide_θ(d) = combine(at("c", set(x = (θ = d.θ, ω = 0.0))), set(u = (in = 4.0,)))
θprob(; kw...) = TrimProblem(; guess = (θ = 0.1,), lower = (θ = -π/2,), upper = (θ = π/2,),
                  condition = decide_θ, reads = reads(ω̇ = get_deriv("c", :ω)),
                  residuals = (r, d) -> (torque = r.ω̇,), tolerances = (torque = 1e-9,), kw...)

# --- names (L14-001, 004, 031, 038, 041, 050, 096) ---
for n in (:combine, :merge, :condition, :set, :fragment, :UninitializedSlots, :UninitializedInputs,
          :BuildError, :design_world, :get_slot, :get_local, :get_input, :capture, :checkpoint,
          :NLoptBackend, :trim_condition)
    p("isdefined Redstone.$n", isdefined(R, n))
end
p("merge(set(), set()) method on ConditionNode", hasmethod(Base.merge, Tuple{R.Fragment,R.Fragment}))

# --- L14-004: uncovered root input, all-or-nothing ---
m = Model(fed(Pendulum(), :u); Δt_frame = 1//10)
st0 = m.status
e = catchd(() -> init!(m, at("c", set(x = (θ = 0.3,)))))
p("L14-004 init! uncovered", (typeof(e), diag1(e)))
p("L14-004 status after refusal", (st0, m.status, m.exec.xbuf))

# --- L14-013/016/065/055: trim, exact J via Duals, Jacobian-free backend ---
struct JRec; Js::Vector{Any}; end
function Redstone.solve(b::JRec, eval!, d0, lo, hi, tol)
    r, J = zeros(length(tol)), zeros(length(tol), length(d0))
    eval!(r, J, d0); push!(b.Js, copy(J))
    (; d = d0, status = :rec, n_evaluations = 1, n_iterations = 0)
end
b = JRec(Any[])
rep = trim!(Model(fed(Pendulum(), :u); Δt_frame = 1//10), θprob(); baseline = pend_base(), backend = b)
p("L14-013 J at guess vs analytic -g_l cos(0.1)", (b.Js[1], -9.81 * cos(0.1)))
rep = trim!(Model(fed(Pendulum(), :u); Δt_frame = 1//10), θprob(); baseline = pend_base())
p("L14-013 LM solve", (rep.converged, rep.solution, asin(4 / 9.81), rep.status))

struct NoJ; end
function Redstone.solve(::NoJ, eval!, d0, lo, hi, tol)
    r = zeros(length(tol)); d = copy(d0)
    for _ in 1:200   # crude secant-free bisection on [lo, hi]
        a, c = lo[1], hi[1]
        for _ in 1:100
            mid = (a + c) / 2; eval!(r, nothing, [mid]); r[1] > 0 ? (a = mid) : (c = mid)
        end
        d = [(a + c) / 2]; break
    end
    (; d, status = :bisect, n_evaluations = 0, n_iterations = 0)
end
rep = trim!(Model(fed(Pendulum(), :u); Δt_frame = 1//10), θprob(); baseline = pend_base(), backend = NoJ())
p("L14-065 Jacobian-free backend", (rep.converged, rep.solution, rep.status))

# Converged iff all(abs.(r) .<= tol): a backend returning the guess with a loose tolerance.
struct Stay; end
Redstone.solve(::Stay, eval!, d0, lo, hi, tol) = (; d = d0, status = :stay, n_evaluations = 0, n_iterations = 0)
r_at_guess = -9.81 * sin(0.1) + 4.0
for tolv in (abs(r_at_guess) * (1 + 1e-12), abs(r_at_guess) * (1 - 1e-12))
    rep = trim!(Model(fed(Pendulum(), :u); Δt_frame = 1//10), θprob(tolerances = (torque = tolv,));
                baseline = pend_base(), backend = Stay())
    p("L14-055 tol=$(tolv) |r|=$(abs(r_at_guess))", (rep.converged, rep.status))
end

# --- L14-031: malformed problem ---
e = catchd(() -> trim!(Model(fed(Pendulum(), :u); Δt_frame = 1//10),
                       θprob(lower = (θ = 1.0,), upper = (θ = 0.0,)); baseline = pend_base()))
p("L14-031 inverted box", (typeof(e), diag1(e)))

# --- L14-044: field set ---
p("L14-044 fieldnames(TrimProblem)", (fieldnames(TrimProblem), length(fieldnames(TrimProblem))))

# --- L14-039: one problem per solve ---
p("L14-039 trim! methods", [m.sig for m in methods(trim!)])

# --- L14-087: how often checks run ---
ncalls = Ref(0); seen = Any[]
ck(r, d) = (ncalls[] += 1; push!(seen, d); (ω = r.ω,))
rep = trim!(Model(fed(Pendulum(), :u); Δt_frame = 1//10),
            θprob(reads = reads(ω̇ = get_deriv("c", :ω), ω = get_state("c", :ω)), checks = ck,
                  check_tolerances = (ω = 1e-6,)); baseline = pend_base())
p("L14-087 checks calls, args", (ncalls[], seen, rep.committed_checks))

# --- L14-050/051: reads grammar and targets; get_state on a discrete store ---
sampled_pend() = Group((; ctl = DiscreteAccumulator(1.0), c = Pendulum());
                       local_wires = ("ctl/u" => "c/u",), input_wires = ("in" => "ctl/e",))
sampled_base(acc = 4.0) = combine(at("ctl", set(s = (acc = acc,))), set(u = (in = 0.0,)))
dθ(d) = at("c", set(x = (θ = d.θ, ω = 0.0)))
pr = TrimProblem(guess = (θ = 0.1,), lower = (θ = -π/2,), upper = (θ = π/2,), condition = dθ,
                 reads = reads(ω̇ = get_deriv("c", :ω), acc = get_state("ctl", :acc), inp = get_input(:in)),
                 residuals = (r, d) -> (torque = r.ω̇,), tolerances = (torque = 1e-9,),
                 checks = (r, d) -> (acc = r.acc - 4.0, inp = r.inp), check_tolerances = (acc = 1e-12, inp = 1e-12))
rep = trim!(Model(sampled_pend(); Δt_frame = 1//10), pr; baseline = sampled_base(4.0))
p("L14-051 get_state on discrete store + get_input in trim reads; L14-078 frozen cells",
  (rep.converged, rep.solution.θ, asin(4 / 9.81), rep.committed_checks))
e = catchd(() -> trim!(Model(sampled_pend(); Δt_frame = 1//10),
                       TrimProblem(guess = (θ = 0.1,), lower = (θ = -π/2,), upper = (θ = π/2,), condition = dθ,
                                   reads = reads(bad = get_output("c", :nope), bd = get_deriv("ctl", :acc)),
                                   residuals = (r, d) -> (t = 0.0,), tolerances = (t = 1.0,));
                       baseline = sampled_base()))
p("L14-051 output/deriv targets", [(typeof(x), x.reason, getfield(x, :candidates)) for x in diag1(e) if hasfield(typeof(x), :candidates)])

# --- L14-061/096/098/137: linearize default point and return ---
sim = Simulation(fed(Pendulum(), :u); Δt_frame = 1//10)
rep = trim!(sim, θprob(); baseline = pend_base())
tp = taps(x = (θ = get_state("c", :θ), ω = get_state("c", :ω)), u = (τ = get_input(:in),),
          y = (θo = get_output("c", :θ),))
lin = linearize(sim, tp)
p("L14-061 committed vs default linearize x₀", (rep.solution.θ, lin.x₀, checkpoint(sim).state.x))
p("L14-098/137 types", (typeof(lin.ẋ₀), typeof(lin.x₀), typeof(lin.u₀), typeof(lin.y₀), typeof(lin.A), lin.x_labels))

# --- L14-097/118: about, t0 ---
fresh = Simulation(fed(Pendulum(), :u); Δt_frame = 1//10)
e = catchd(() -> linearize(fresh, tp))
p("L14-097 default on built sim", diag1(e))
lin2 = linearize(fresh, tp; about = combine(at("c", set(x = (θ = 0.2, ω = 0.0))), set(u = (in = 1.0,))), t0 = 1//2)
p("L14-097 about+t0 on built sim", (lin2.x₀, lin2.u₀))
e = catchd(() -> linearize(sim, tp; t0 = 1//2))
p("L14-118 t0 without about", diag1(e))

# --- L14-072: discrete store in x ---
ss = Simulation(sampled_pend(); Δt_frame = 1//10)
e = catchd(() -> linearize(ss, taps(x = (acc = get_state("ctl", :acc),)); about = sampled_base()))
p("L14-072 discrete x tap", [(x.reason, x.path, x.field, x.tap) for x in diag1(e)])

# --- L14-127: seeded tap limits ---
vp = Simulation(fed(VectorPlant(), :u); Δt_frame = 1//10)
vb = set(u = (in = 0.0,))
for (lab, sel) in ((:whole, get_state("c", :q)), (:idx, get_state("c", "q[1]")))
    e = catchd(() -> linearize(vp, taps(x = (a = sel,)); about = vb))
    p("L14-127 x $lab", e === nothing ? :ok : [(x.reason, x.declared) for x in diag1(e)])
end
struct IntIn <: AbstractComponent end
Redstone.x_init(::IntIn) = (q = 0.0,)
Redstone.u_types(::IntIn) = (u = Int,)
Redstone.y_types(::IntIn) = (q = Float64,)
Redstone.y_state(::IntIn, (; x)) = (q = x.q,)
Redstone.x_deriv(::IntIn, (; x, u)) = (q = u.u - x.q,)
ii = Simulation(fed(IntIn(), :u); Δt_frame = 1//10)
e = catchd(() -> linearize(ii, taps(u = (a = get_input(:in),)); about = set(u = (in = 1,))))
p("L14-127 u Int leaf", e === nothing ? :ok : [(typeof(x), getfield(x, :reason)) for x in diag1(e)])

# --- L14-107: origin spelling of a leaf entry ---
e = catchd(() -> init!(Model(fed(Pendulum(), :u); Δt_frame = 1//10),
                       combine(at("c", set(x = (nope = 1.0,))), pend_base())))
p("L14-107 origin", [(typeof(x), hasfield(typeof(x), :origin) ? x.origin : nothing) for x in diag1(e)])

# --- L14-111: an internally wired face written by a trim condition ---
e = catchd(() -> trim!(Model(sampled_pend(); Δt_frame = 1//10),
                       θprob(condition = d -> at("c", set(x = (θ = d.θ, ω = 0.0), u = (u = 4.0,)))); baseline = sampled_base()))
p("L14-111 condition writing a wired face", e === nothing ? :ok : [(typeof(x), getfield(x, :reason)) for x in diag1(e)])

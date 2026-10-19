# Half 2 of chapter 14's survey: the code blocks of §14.7–§14.10 and the claims
# checked in passing. Run from the repository root:
#   julia --project=test -t 2 docs/spec_rewrite/ch14/scratch_survey/h2/run/blocks.jl
module H2Check
include(joinpath(@__DIR__, "..", "..", "..", "..", "..", "..", "test", "repl.jl"))
fed(c, face) = Group((; c = c); input_wires = ("in" => "c/$face",))   # test/utils.jl
const R = Redstone
M(root, T = Float64) = Model(root, T; h = 1//10)

say(label, x) = println(rpad(label, 46), " => ", x)
function caught(f)
    try
        f(); return nothing
    catch e
        return e
    end
end
diags(e) = e isa DiagnosticError ? (e.carried isa AbstractVector ? e.carried : [e.carried]) : e
kr(e) = e isa DiagnosticError ? [(typeof(d).name.name, hasproperty(d, :reason) ? d.reason : nothing) for d in diags(e)] : typeof(e)

# --- fixtures -------------------------------------------------------------------
pend() = fed(Pendulum(), :u)                       # root input `in` -> c/u
base() = set(u = (in = 0.0,))
decide_θ(d) = combine(at("c", set(x = (θ = d.θ, ω = 0.0))), set(u = (in = 4.0,)))
rd() = reads(ω̇ = get_deriv("c", :ω), θ = get_state("c", :θ))
θprob(; kw...) = TrimProblem(; guess = (θ = 0.1,), lower = (θ = -π/2,), upper = (θ = π/2,),
                             condition = decide_θ, reads = rd(),
                             residuals = (r, d) -> (torque = r.ω̇,),
                             tolerances = (torque = 1e-9,), kw...)

println("== B1 (11896–11913) the cruise problem's shape, on the pendulum")
p1 = TrimProblem(guess = (θ = 0.1,), lower = (θ = -π/2,), upper = (θ = π/2,),
                 condition = decide_θ, reads = rd(),
                 residuals = (r, d) -> (torque = r.ω̇,),
                 tolerances = (torque = 1e-9,),
                 checks = (r, d) -> (θ_check = r.θ - asin(4.0 / 9.81),),
                 check_tolerances = (θ_check = 1e-6,))
say("fieldnames(TrimProblem)", fieldnames(TrimProblem))
rep1 = trim!(M(pend()), p1; baseline = base())
say("converged / solution", (rep1.converged, rep1.solution))
say("committed_checks", rep1.committed_checks)
say("status, n_eval, n_iter", (rep1.status, rep1.n_evaluations, rep1.n_iterations))

println("== B3 (12080–12082) the solve seam, called directly")
eval_toy!(r, J, d) = (r[1] = d[1]^2 - 2.0; J === nothing || (J[1, 1] = 2d[1]); nothing)
out = R.solve(R.LevenbergMarquardt(), eval_toy!, [1.0], [-Inf], [Inf], [1e-12])
say("keys(out)", keys(out))
say("d, status", (out.d, out.status))

println("== B4 (12139–12141) sphere inside the box, sampled")
import Random; Random.seed!(1)
ok = all(1:100_000) do _
    r = randn(3) .* 0.6; tol = rand(3) .+ 0.1
    sum((r ./ tol) .^ 2) ≤ 1 ? all(abs.(r) .≤ tol) : true
end
say("Σ(r/tol)² ≤ 1 ⟹ |rᵢ| ≤ tolᵢ", ok)

println("== B5 (12251–12257) the report's fields")
say("fieldnames(TrimReport)", fieldnames(R.TrimReport))

println("== B6 (12391–12402) the spec's `at` sketch against the code's")
at_spec(prefix::String, p::TrimProblem) = TrimProblem(
    guess = p.guess, lower = p.lower, upper = p.upper,
    condition = d -> at(prefix, p.condition(d)),
    reads = at(prefix, p.reads), residuals = p.residuals, tolerances = p.tolerances,
    checks = p.checks, check_tolerances = p.check_tolerances)
inner_θ(d) = at("c", set(x = (θ = d.θ, ω = 0.0)))
pi_ = TrimProblem(guess = (θ = 0.1,), lower = (θ = -π/2,), upper = (θ = π/2,),
                  condition = inner_θ, reads = reads(ω̇ = get_deriv("c", :ω)),
                  residuals = (r, d) -> (torque = r.ω̇,), tolerances = (torque = 1e-9,))
wing() = Group((; wing = pend()); input_wires = ("thr" => "wing/in",))
wbase() = set(u = (thr = 4.0,))
ra = trim!(M(wing()), at("wing", pi_); baseline = wbase())
rs = trim!(M(wing()), at_spec("wing", pi_); baseline = wbase())
say("code at: converged, θ", (ra.converged, ra.solution.θ))
say("spec at: converged, θ", (rs.converged, rs.solution.θ))
say("θ = asin(4/9.81)", asin(4 / 9.81))
say("at(\"\", problem)", kr(caught(() -> at("", pi_))))
say("at(\"\", read set)", kr(caught(() -> at("", reads(a = get_state("c", :θ))))))

println("== B7 (12507–12512) a tap set in the block's shape, on lin_pend")
lin_pend() = Group((; s = Sum(), c = Pendulum()); local_wires = ("s/e" => "c/u",),
                   input_wires = ("τ" => "s/a", "d" => "s/b"),
                   output_wires = ("c/θ" => "θ", "s/e" => "u_eff"))
lin_point(θ = 0.3) = combine(at("c", condition(Pendulum(); θ = θ)),
                             set(u = (τ = 9.81 * sin(θ), d = 0.0)))
tp = taps(x = (θ = get_state("c", :θ), ω = get_state("c", "ω")),
          u = (τ = get_input(:τ), d = get_input("d")),
          y = (EAS = get_output("c", :θ), u_eff = get_face(:u_eff)))
m7 = M(lin_pend()); init!(m7, lin_point())
L7 = linearize(m7, tp)
say("A", L7.A); say("B", L7.B); say("C", L7.C); say("D", L7.D)
say("A[2,1] vs -g cos θ", (L7.A[2, 1], -9.81 * cos(0.3)))
say("fieldnames(Linearization)", fieldnames(R.Linearization))
say("LINEARIZE_WIDTH, LinearizeDual", (R.LINEARIZE_WIDTH, R.LinearizeDual))
vec_m() = Group((; p = VectorPlant(), fb = StateFeedback(2.0));
                local_wires = ("fb/u" => "p/u",), input_wires = ("qin" => "fb/q",),
                output_wires = ("p/q" => "q", "p/power" => "power"))
mv = M(vec_m()); init!(mv, combine(at("p", set(x = (q = SVector(0.1, 0.2),))),
                                       set(u = (qin = SVector(0.5, 0.0),))))
Lv = linearize(mv, taps(x = (q1 = get_state("p", "q[1]"), q2 = get_state("p", "q[2]")),
                        u = (w1 = get_input("qin[1]"),), y = (q1 = get_face("q[1]"),)))
say("vector leaf named scalars, size(A)", size(Lv.A))
say("unindexed vector tap", kr(caught(() -> linearize(mv, taps(x = (q = get_state("p", :q),))))))

println("== B10 (12707–12715) the local rule, inside a component")
c_lookup(tb, u) = tb.a * u^3                          # stands in for an opaque C table
struct Tab; a::Float64; end
lookup(tb, u::Float64) = c_lookup(tb, u)
function lookup(tb, u::ForwardDiff.Dual{Tag}) where {Tag}
    u0 = ForwardDiff.value(u)
    y0 = c_lookup(tb, u0)
    h  = sqrt(eps(u0))
    dy = (c_lookup(tb, u0 + h) - y0) / h
    return ForwardDiff.Dual{Tag}(y0, dy * ForwardDiff.partials(u))
end
struct Opaque <: AbstractComponent; tb::Tab; end
R.x_init(::Opaque) = (q = 0.0,)
R.u_types(::Opaque) = (u = Float64,)
R.y_types(::Opaque) = (q = Float64,)
R.y_state(::Opaque, (; x)) = (q = x.q,)
R.x_deriv(c::Opaque, (; x, u)) = (q = -x.q + lookup(c.tb, u.u),)
mo = M(fed(Opaque(Tab(2.0)), :u)); init!(mo, combine(at("c", set(x = (q = 0.0,))), set(u = (in = 1.5,))))
Lo = linearize(mo, taps(x = (q = get_state("c", :q),), u = (u = get_input(:in),)))
say("B from the local rule vs 3a·u²", (Lo.B[1, 1], 3 * 2.0 * 1.5^2))
say("A", Lo.A)

println("== claims, §14.7")
perm = θprob(lower = (θ = -π/2,), upper = (θ = π/2,))
# a permuted bound spelling on a two-decision problem
decide_both(d) = combine(at("c", set(x = (θ = d.θ, ω = 0.0))), set(u = (in = d.u,)))
both(lower, upper) = TrimProblem(guess = (θ = 0.1, u = 0.0), lower = lower, upper = upper,
    condition = decide_both, reads = rd(),
    residuals = (r, d) -> (hold = r.θ - 0.3, torque = r.ω̇), tolerances = (torque = 1e-9, hold = 1e-9))
r_ord = trim!(M(pend()), both((θ = -1.0, u = -10.0), (θ = 1.0, u = 10.0)); baseline = base())
r_per = trim!(M(pend()), both((u = -10.0, θ = -1.0), (u = 10.0, θ = 1.0)); baseline = base())
say("permuted bounds and residual order: same", (r_ord.solution, r_per.solution, r_ord.converged, r_per.converged))
say("bounds key-set mismatch", kr(caught(() -> trim!(M(pend()), θprob(lower = (φ = 0.0,)); baseline = base()))))
say("tolerances key-set mismatch", kr(caught(() -> trim!(M(pend()), θprob(tolerances = (moment = 1e-9,)); baseline = base()))))
say("inverted box (unlisted in §14.8)", kr(caught(() -> trim!(M(pend()), θprob(lower = (θ = 1.0,), upper = (θ = 0.0,)); baseline = base()))))
say("zero tolerance (unlisted in §14.8)", kr(caught(() -> trim!(M(pend()), θprob(tolerances = (torque = 0.0,)); baseline = base()))))
say("unknown reads selector", kr(caught(() -> trim!(M(pend()), θprob(reads = reads(ω̇ = get_deriv("k", :ω))); baseline = base()))))

println("== claims, §14.8")
mb = M(pend())
infeasible = TrimProblem(guess = (θ = 0.1,), lower = (θ = 0.0,), upper = (θ = 0.2,),
                         condition = decide_θ, reads = rd(), residuals = (r, d) -> (torque = r.ω̇,),
                         tolerances = (torque = 1e-9,))
rn = trim!(mb, infeasible; baseline = base())
say("non-converged: converged, status, saturated", (rn.converged, rn.status, rn.saturated))
say("model status after a non-converged solve", mb.status)
say("committed_residuals after no commit", rn.committed_residuals)
sim = Simulation(pend(); h = 1//10)
rn2 = trim!(sim, infeasible; baseline = base())
say("sim lifecycle after no commit", R.lifecycle(sim))
empty_p = TrimProblem(guess = (;), lower = (;), upper = (;), condition = d -> set(),
                      reads = rd(), residuals = (r, d) -> (torque = r.ω̇,), tolerances = (torque = 1e-9,))
re = trim!(M(pend()), empty_p; baseline = set(u = (in = 0.0,)))
say("empty problem: converged, status, n_eval", (re.converged, re.status, re.n_evaluations))
trig() = Group((; c = Pendulum(), trig = Trigger(0.3));
               local_wires = ("c/θ" => "trig/sig",), input_wires = ("in" => "c/u",))
rt = trim!(M(trig()), TrimProblem(guess = (θ = 0.1,), lower = (θ = -1.0,), upper = (θ = 1.0,),
           condition = d -> combine(at("c", set(x = (θ = d.θ, ω = 0.0))), set(u = (in = 4.0,))),
           reads = rd(), residuals = (r, d) -> (torque = r.ω̇,), tolerances = (torque = 1e-9,));
           baseline = set(u = (in = 4.0,)))
say("fired_events at commit", rt.fired_events)
say("trim! on a Model{Dual}", kr(caught(() -> trim!(M(pend(), R.LinearizeDual), θprob(); baseline = base()))))
say("trim! on an errored-free running? (claimed model)", kr(caught(() -> trim!(sim.model, θprob(); baseline = base()))))

println("== claims, §14.9")
wired() = Group((; src = Pendulum(), wing = pend()); local_wires = ("src/θ" => "wing/in",), input_wires = ("su" => "src/u",))
pw = TrimProblem(guess = (θ = 0.1,), lower = (θ = -1.0,), upper = (θ = 1.0,),
                 condition = d -> combine(inner_θ(d), set(u = (in = 1.0,))),
                 reads = reads(ω̇ = get_deriv("c", :ω)), residuals = (r, d) -> (torque = r.ω̇,),
                 tolerances = (torque = 1e-9,))
say("internally wired input, mounted condition", kr(caught(() -> trim!(M(wired()), at("wing", pw); baseline = set(u = (su = 0.0,))))))
say("get_input of an internally wired face, mounted",
    kr(caught(() -> trim!(M(wired()), at("wing", TrimProblem(guess = (;), lower = (;), upper = (;),
          condition = d -> set(), reads = reads(v = get_input(:in)), residuals = (r, d) -> (;), tolerances = (;)));
          baseline = set(u = (su = 0.0,))))))
say("does build(wired()) itself complain?", caught(() -> build(wired())) === nothing ? "no" : "yes")

println("== claims, §14.10")
say("default linearize at :built", kr(caught(() -> linearize(M(lin_pend()), tp))))
say("t0 without about", kr(caught(() -> linearize(m7, tp; t0 = 1.0))))
samp() = Group((; ctl = DiscreteAccumulator(1.0), c = Pendulum());
               local_wires = ("ctl/u" => "c/u",), input_wires = ("in" => "ctl/e",))
ms = M(samp()); init!(ms, combine(at("ctl", set(s = (acc = 4.0,))), at("c", condition(Pendulum(); θ = 0.42)), set(u = (in = 0.0,))))
say("x tap on a discrete store", kr(caught(() -> linearize(ms, taps(x = (a = get_state("ctl", :acc),))))))
say("u tap read by a discrete consumer", kr(caught(() -> linearize(ms, taps(u = (e = get_input(:in),))))))
say("two taps at one site", kr(caught(() -> linearize(m7, taps(x = (a = get_state("c", :θ), b = get_state("c", :θ)))))))
say("member in the wrong list", kr(caught(() -> linearize(m7, taps(x = (a = get_input(:τ),))))))
pinned() = Group((; g = PinnedGain(), c = Pendulum()); local_wires = ("g/out" => "c/u",), input_wires = ("τ" => "g/e",))
mp = M(pinned()); init!(mp, combine(at("c", condition(Pendulum(); θ = 0.1)), set(u = (τ = 0.0,))))
e_p = caught(() -> linearize(mp, taps(u = (τ = get_input(:τ),))))
say("Pinned u tap", kr(e_p)); say("  pinning", diags(e_p)[1].pinning)
# the default point after a trim commit
st = Simulation(pend(); h = 1//10); trim!(st, θprob(); baseline = base())
Ls = linearize(st, taps(x = (θ = get_state("c", :θ), ω = get_state("c", :ω))))
say("after trim!: x₀.θ vs asin(4/9.81)", (Ls.x₀.θ, asin(4 / 9.81)))
say("lifecycle after trim! commit", R.lifecycle(st))
# width changes the grouping, never the answer
Lw1 = linearize(m7, tp; width = 1)
say("width = 1 gives the same A, B, C, D", (Lw1.A == L7.A, Lw1.B == L7.B, Lw1.C == L7.C, Lw1.D == L7.D))

# a `.name` step on a seeded tap, and an unindexed vector tap's reason
struct Duo{T}; a::T; b::T; end
R.probe_value(::Type{Duo{T}}) where {T} = Duo(zero(T), zero(T))
# without this method the default operating point dies in a raw `convert` MethodError (run notes)
Base.convert(::Type{Duo{T}}, d::Duo) where {T} = Duo{T}(d.a, d.b)
struct DuoSink <: AbstractComponent end
R.x_init(::DuoSink) = (q = 0.0,)
R.u_types(::DuoSink) = (w = Duo{Float64},)
R.y_types(::DuoSink) = (q = Float64,)
R.y_state(::DuoSink, (; x)) = (q = x.q,)
R.x_deriv(::DuoSink, (; x, u)) = (q = -x.q + u.w.a,)
md = M(fed(DuoSink(), :w)); init!(md, set(u = (in = Duo(1.0, 2.0),)))
say("u tap with a `.name` step", kr(caught(() -> linearize(md, taps(u = (wa = get_input("in.a"),))))))
say("unindexed vector tap, reason", kr(caught(() -> linearize(mv, taps(x = (q = get_state("p", :q),))))))
end

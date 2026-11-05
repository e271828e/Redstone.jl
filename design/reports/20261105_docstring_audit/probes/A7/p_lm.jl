module P
include("design/reports/20261105_docstring_audit/probes/A7/common.jl")
lm(; kw...) = Redstone.LevenbergMarquardt(; kw...)
run1(label, b, eval!, d0, lo, up, tol) = try
    o = solve(b, eval!, d0, lo, up, tol)
    println(rpad(label, 34), " => ", o)
catch e
    println(rpad(label, 34), " => RAW ", typeof(e), ": ", first(sprint(showerror, e), 110))
end
one(x) = [x]
println("--- non-finite inputs")
inf_box = (one(-Inf), one(Inf))
run1("r NaN at d0, J finite", lm(), (r, J, d) -> (r .= NaN; J === nothing || (J .= 1.0); nothing), one(0.0), inf_box..., one(1e-6))
run1("J NaN at d0, r finite", lm(), (r, J, d) -> (r .= 1.0; J === nothing || (J .= NaN); nothing), one(0.0), inf_box..., one(1e-6))
run1("J Inf at d0, r finite", lm(), (r, J, d) -> (r .= 1.0; J === nothing || (J .= Inf); nothing), one(0.0), inf_box..., one(1e-6))
run1("r Inf at d0, J finite", lm(), (r, J, d) -> (r .= Inf; J === nothing || (J .= 1.0); nothing), one(0.0), inf_box..., one(1e-6))
run1("J huge, overflow in JtJ", lm(), (r, J, d) -> (r .= 1.0; J === nothing || (J .= 1e200); nothing), one(0.0), inf_box..., one(1e-6))
# accepted trial whose J goes non-finite: sqrt-style singularity at the next point
run1("J NaN at accepted point", lm(), (r, J, d) -> (r .= d[1] == 0.0 ? 1.0 : 0.5; J === nothing || (J .= d[1] == 0.0 ? 1.0 : NaN); nothing), one(0.0), inf_box..., one(1e-6))
run1("2x2 J NaN", lm(), (r, J, d) -> (r .= 1.0; J === nothing || (J .= NaN); nothing), [0.0, 0.0], [-Inf, -Inf], [Inf, Inf], [1e-6, 1e-6])
println("--- stall paths")
run1("zero J, r nonzero (rounding)", lm(), (r, J, d) -> (r .= 1.0; J === nothing || (J .= 0.0); nothing), one(0.0), inf_box..., one(1e-6))
let n = Ref(0)
    run1("all trials rejected, default λ₀", lm(), (r, J, d) -> (n[] += 1; r .= 1 + 1000 * abs(d[1]); J === nothing || (J .= 1.0); nothing), one(0.0), inf_box..., one(1e-6))
    println("   evals ", n[])
end
println("--- λ₀ not positive: bounded by a throwing eval!")
for λ in (0.0, -1.0)
    n = Ref(0)
    bounded = (r, J, d) -> (n[] += 1; n[] > 20000 && error("bound of 20000 evals hit"); r .= 1 + 1000 * abs(d[1]); J === nothing || (J .= 1.0); nothing)
    run1("all rejected, λ₀=$λ", lm(λ₀ = λ), bounded, one(0.0), inf_box..., one(1e-6))
    println("   evals ", n[])
end
println("--- maxiter")
lin = (r, J, d) -> (r[1] = d[1]^3 - 8.0; J === nothing || (J[1, 1] = 3d[1]^2); nothing)
run1("maxiter 0", lm(maxiter = 0), lin, one(1.0), inf_box..., one(1e-9))
run1("maxiter 1", lm(maxiter = 1), lin, one(1.0), inf_box..., one(1e-9))
run1("maxiter 3", lm(maxiter = 3), lin, one(1.0), inf_box..., one(1e-9))
run1("maxiter 100", lm(), lin, one(1.0), inf_box..., one(1e-9))
run1("already within", lm(), lin, one(2.0), inf_box..., one(1e-9))
run1("maxiter 2.0 Integer", lm(maxiter = big(2)), lin, one(1.0), inf_box..., one(1e-9))
println("--- λ sequence, scalar: δ = -r/(J(1+λ)), J=1")
trials = Float64[]
script = (r, J, d) -> begin
    push!(trials, d[1])
    r[1] = length(trials) == 1 ? 1.0 : (length(trials) == 2 ? 2.0 : (length(trials) == 3 ? 0.5 : 0.0))
    J === nothing || (J[1, 1] = 1.0)
    nothing
end
run1("scripted", lm(λ₀ = 1.0), script, one(0.0), inf_box..., one(1e-3))
println("  trials ", trials, " expected first δ -1/(1+1)=-0.5; rejected, λ=10: -1/11; accepted at d=-1/11, r=0.5, λ=1: d-0.25")
println("--- zero column: JtJ singular without the floor")
zc = (r, J, d) -> (r[1] = d[1] - 1.0; J === nothing || (J[1, 1] = 1.0; J[1, 2] = 0.0); nothing)
run1("zero column", lm(), zc, [0.0, 5.0], [-Inf, -Inf], [Inf, Inf], [1e-6])
println("--- bounds projection")
run1("projected", lm(), lin, one(1.0), one(0.0), one(1.5), one(1e-9))
println("--- trim! with a NaN Jacobian")
sq(d) = combine(at("c", set(x = (θ = 0.0, ω = 0.0))), set(u = (in = d.u,)))
m = Model(fed(Pendulum(), "u"); h = 1//10)
p = TrimProblem(guess = (u = 0.0,), lower = (u = -1.0,), upper = (u = 1.0,), condition = sq, reads = torque_reads(), residuals = (r, d) -> (torque = sqrt(abs(d.u)) + 1.0,), tolerances = (torque = 1e-9,))
tryit("trim! sqrt at 0 (NaN partials)", () -> trim!(m, p; baseline = set()))
println("  status ", m.status)
end

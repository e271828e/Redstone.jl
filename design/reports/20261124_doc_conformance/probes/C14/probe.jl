# C14 probe: code-to-docs checks for conditions, trim, linearize, readers.
using Test, StaticArrays, LinearAlgebra, ForwardDiff
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
include(joinpath(W, "test", "imports.jl"))
include(joinpath(W, "test", "fixtures.jl"))
include(joinpath(W, "test", "utils.jl"))
import Redstone: set, at, combine, override, condition, reads, get_state, get_deriv, get_output,
    get_input, get_face, taps, linearize, trim!, TrimProblem, init!, build, Model, Simulation,
    Reads, Taps, LevenbergMarquardt, TrimReport, checkpoint

PEND_G_L = 9.81
MF(b) = Model(b, Float64; Δt_frame = 1//10)
MD(b) = Model(b, ForwardDiff.Dual{:x,Float64,1}; Δt_frame = 1//10)
function try_(label, f)
    try
        r = f()
        println(label, " => OK ", r isa Union{Number,Symbol,String,Bool,Nothing} ? r : typeof(r))
        r
    catch e
        if e isa Redstone.DiagnosticError
            c = e.carried
            ds = c isa Vector ? c : [c]
            println(label, " => ", join(("$(nameof(typeof(d)))(" * join(("$k=$(repr(getfield(d,k)))" for k in fieldnames(typeof(d)) if k in (:reason,:call,:argument,:tap,:field,:list,:store,:role,:op,:payload,:observed) && getfield(d,k) !== nothing), ",") * ")" for d in ds), " ; "))
        else
            println(label, " => EXC ", typeof(e), " ", sprint(showerror, e)[1:min(end,160)])
        end
        nothing
    end
end
println("== P1 construction allocation (probe:)")
mk() = combine(at("c", set(x = (θ = 0.1, ω = 0.0))), at("d", set(x = (θ = 0.2,))), set(u = (in = 1.0,)))
mk(); println("alloc tree: ", @allocated mk())
println("isbitstype Fragment: ", isbitstype(typeof(set(x = (θ = 0.1,)))), " Scoped: ", isbitstype(typeof(at("c", set(x=(θ=0.1,))))))

println("== P2 composition refusals")
try_("at('' node)", () -> at("", set()))
try_("at('' reads)", () -> at("", reads(a = get_state("c", :θ))))
try_("at('' problem w/ reads)", () -> at("", TrimProblem(guess=(;),lower=(;),upper=(;),condition=d->set(),reads=reads(),residuals=(r,d)->(;),tolerances=(;))))
try_("at(p, 3)", () -> at("a", 3))
try_("set(x=nothing)", () -> set(x = nothing))
try_("set(x=1.0) bare payload", () -> set(x = 1.0))
try_("set(x=(;a=1)) ", () -> set(x = (; a = 1)))
try_("combine(set(), NT)", () -> combine(set(), (; a = 1)))
try_("combine(NT, set())", () -> combine((; a = 1), set()))
try_("combine(1,2)", () -> combine(1, 2))
try_("override(set(), NT)", () -> override(set(), (; a = 1)))
try_("override(NT)", () -> override((; a = 1)))

println("== P3 resolution reasons on lin_pend")
lin_pend() = Group((; s = Sum(), c = Pendulum()); local_wires = ("s/e" => "c/u",),
                   input_wires = ("τ" => "s/a", "d" => "s/b"),
                   output_wires = ("c/θ" => "θ", "s/e" => "u_eff"))
b = build(lin_pend())
m = MF(b)
full = set(u = (τ = 1.0, d = 0.0))
try_("init ok", () -> init!(m, full))
m = MF(b)
try_("unknown child", () -> init!(m, combine(full, at("zz", set(x=(θ=1.0,))))))
try_("undeclared field", () -> init!(m, combine(full, at("c", set(x=(zz=1.0,))))))
try_("output field", () -> init!(m, combine(full, at("c", set(x=(θ=1.0,), s=(a=1,))))))
try_("no_store s on cont", () -> init!(m, combine(full, at("c", set(s=(a=1.0,))))))
try_("assembly path", () -> init!(m, combine(full, at("s", set(x=(a=1.0,))))))
try_("assembly set x on root", () -> init!(m, combine(full, set(x=(a=1.0,)))))
try_("bare payload named store", () -> init!(m, combine(full, at("c", set(x=1.0)))))
try_("bare u at named contract", () -> init!(m, combine(full, at("c", set(u=1.0)))))
try_("unexported face", () -> init!(m, set(u=(τ=1.0, d=0.0, zz=1.0))))
try_("no_input_face (at c)", () -> init!(m, combine(full, at("c", set(u=(zz=1.0,))))))
try_("internally wired", () -> init!(m, combine(full, at("c", set(u=(u=1.0,))))))
try_("unconvertible", () -> init!(m, combine(full, at("c", set(x=(θ="a",))))))
try_("duplicate", () -> init!(m, combine(full, set(u=(τ=2.0,)))))
try_("override dup within layer", () -> init!(m, override(combine(full, set(u=(τ=2.0,))), set())))
try_("override ok", () -> init!(m, override(full, set(u=(τ=2.0,)))))
try_("override layered face spelling", () -> init!(m, override(full, at("s", set(u=(a=3.0,))))))
try_("totality", () -> init!(m, set(u=(τ=1.0,))))
try_("non-node to init", () -> init!(m, (; a=1)))
try_("t0 float inexact", () -> init!(m, full; t0 = 1e-4))
try_("t0 NaN", () -> init!(m, full; t0 = NaN))

println("== P4 reader reasons")
bd = b
function rr(label, sel; src = :executor)
    try_(label, () -> Redstone._compile_reads(reads(a = sel), bd; source = src))
end
rr("get_state ok", get_state("c", :θ))
rr("get_state assembly", get_state("", :θ))
rr("get_state stateless headless", get_state("s"))
rr("get_state named headless", get_state("c"))
rr("get_state .name", get_state("c", "θ.x"))
rr("get_state undeclared", get_state("c", :zz))
rr("get_state unknown path", get_state("zz", :θ))
rr("get_deriv ok", get_deriv("c", :ω))
rr("get_deriv on stateless", get_deriv("s", :a))
rr("get_state table src", get_state("c", :θ); src = :table)
rr("get_output ok", get_output("c", :θ))
rr("get_output missing port", get_output("c"))
rr("get_output undeclared", get_output("c", :zz))
rr("get_input ok", get_input(:τ))
rr("get_input unknown", get_input(:zz))
rr("get_input headless root", get_input())
rr("get_face ok", get_face(:θ))
rr("get_face input name", get_face(:τ))
rr("get_face unknown", get_face(:zz))
rr("leaf syntax", get_state("c", "θ[0]"))
rr("leaf index on scalar", get_state("c", "θ[1]"))
try_("reads(a=3)", () -> reads(a = 3))
try_("compile NT", () -> Redstone._compile_reads((; a = get_state("c", :θ)), bd))
println("parse_leaf: ", Redstone.parse_leaf("pose.q_eb[2,3]"), " | ", Redstone.parse_leaf(""), " | ", Redstone.parse_leaf("[2]"))

println("== P5 taps and linearize")
lt = taps(x = (θ = get_state("c", :θ), ω = get_state("c", :ω)),
          u = (τ = get_input(:τ), d = get_input(:d)),
          y = (θ = get_face(:θ), u_eff = get_face(:u_eff)))
try_("taps(x=3)", () -> taps(x = 3))
try_("taps(x=(;a=3))", () -> taps(x = (; a = 3)))
try_("at('' taps)", () -> at("", lt))
m = MF(b); init!(m, set(u=(τ=1.0, d=0.0)))
lin = linearize(m, lt)
println("lin fields: ", fieldnames(Linearization), " A=", lin.A, " types ", typeof(lin.A), " ", typeof(lin.ẋ₀))
try_("lin width 0", () -> linearize(m, lt; width = 0))
try_("lin t0 w/o about", () -> linearize(m, lt; t0 = 1))
try_("lin not taps", () -> linearize(m, 3))
try_("lin model Dual", () -> linearize(MD(b), lt))
try_("lin about t0 bad", () -> linearize(m, lt; about = full, t0 = 1e-4))
try_("lin about partial", () -> linearize(m, lt; about = set(u=(τ=1.0,))))
try_("lin about ok", () -> linearize(m, lt; about = full, width = 1))
try_("lin on :built model", () -> linearize(MF(b), lt))
try_("tap wrong list", () -> linearize(m, taps(x = (a = get_input(:τ),))))
try_("tap u wrong kind", () -> linearize(m, taps(u = (a = get_state("c", :θ),))))
try_("tap y deriv", () -> linearize(m, taps(y = (a = get_deriv("c", :ω),))))
try_("tap unknown", () -> linearize(m, taps(x = (a = get_state("zz", :θ),))))
try_("tap two seeds one site", () -> linearize(m, taps(x = (a = get_state("c", :θ), b = get_state("c", :θ)))))
mm = MF(b); sm2 = Simulation(mm); init!(sm2, full)
try_("lin claimed model", () -> linearize(mm, lt))
try_("trim claimed model", () -> trim!(mm, TrimProblem(guess=(;),lower=(;),upper=(;),condition=d->set(),reads=reads(),residuals=(r,d)->(;),tolerances=(;)); baseline = full))
println("LinearizeDual: ", Redstone.LinearizeDual, " ", Redstone.LINEARIZE_WIDTH)

println("== P6 discrete store tap")
lin_sampled() = Group((; ctl = DiscreteAccumulator(1.0), c = Pendulum());
                      local_wires = ("ctl/u" => "c/u",), input_wires = ("in" => "ctl/e",))
bs = build(lin_sampled())
ms = MF(bs); init!(ms, combine(at("ctl", set(s = (acc = 4.0,))), set(u = (in = 0.0,))))
try_("discrete x tap", () -> linearize(ms, taps(x = (a = get_state("ctl", :acc)))))
try
    linearize(ms, taps(x = (a = get_state("ctl", :acc),)))
catch e
    d = e.carried isa Vector ? e.carried[1] : e.carried
    println("TapResolution fields: ", [(k, getfield(d, k)) for k in fieldnames(typeof(d))])
end
try_("u tap on pinned/discrete consumer", () -> linearize(ms, taps(u = (a = get_input(:in),))))

println("== P7 trim problem validation")
ub() = Group((; c = Pendulum()); input_wires = ("in" => "c/u",))
bt = build(ub()); mt = MF(bt)
base = set(u = (in = 0.0,))
decide(d) = combine(at("c", condition(Pendulum(); θ = 0.5)), set(u = (in = d.u,)))
prob(; kw...) = TrimProblem(; guess = (u = 0.0,), lower = (u = -Inf,), upper = (u = Inf,), condition = decide,
    reads = reads(ω̇ = get_deriv("c", :ω)), residuals = (r, d) -> (torque = r.ω̇,),
    tolerances = (torque = 1e-9,), kw...)
rep = try_("trim ok", () -> trim!(mt, prob(); baseline = base))
println(rep)
println("report fields: ", fieldnames(TrimReport))
try_("trim inverted box", () -> trim!(MF(bt), prob(; ) |> p -> TrimProblem(guess=p.guess, lower=(u=1.0,), upper=(u=-1.0,), condition=p.condition, reads=p.reads, residuals=p.residuals, tolerances=p.tolerances); baseline = base))
try_("trim nonpos tol", () -> trim!(MF(bt), TrimProblem(guess=(u=0.0,),lower=(u=-Inf,),upper=(u=Inf,),condition=decide,reads=reads(ω̇ = get_deriv("c", :ω)),residuals=(r,d)->(torque=r.ω̇,),tolerances=(torque=0.0,)); baseline = base))
try_("trim reads NT", () -> trim!(MF(bt), TrimProblem(guess=(u=0.0,),lower=(u=-Inf,),upper=(u=Inf,),condition=decide,reads=(; a=get_deriv("c", :ω)),residuals=(r,d)->(torque=r.a,),tolerances=(torque=1e-9,)); baseline = base))
try_("trim not NT guess", () -> trim!(MF(bt), TrimProblem(guess=1.0,lower=(u=-Inf,),upper=(u=Inf,),condition=decide,reads=reads(),residuals=(r,d)->(;),tolerances=(;)); baseline = base))
try_("trim residual wrong keys", () -> trim!(MF(bt), TrimProblem(guess=(u=0.0,),lower=(u=-Inf,),upper=(u=Inf,),condition=decide,reads=reads(ω̇ = get_deriv("c", :ω)),residuals=(r,d)->(zz=r.ω̇,),tolerances=(torque=1e-9,)); baseline = base))
try_("trim residual non-real", () -> trim!(MF(bt), TrimProblem(guess=(u=0.0,),lower=(u=-Inf,),upper=(u=Inf,),condition=decide,reads=reads(ω̇ = get_deriv("c", :ω)),residuals=(r,d)->(torque="a",),tolerances=(torque=1e-9,)); baseline = base))
try_("trim not a problem", () -> trim!(MF(bt), 3; baseline = base))
try_("trim Dual model", () -> trim!(MD(bt), prob(); baseline = base))
try_("trim t0 bad", () -> trim!(MF(bt), prob(); baseline = base, t0 = NaN))
try_("trim no baseline total", () -> trim!(MF(bt), prob(); baseline = set()))
try_("trim missing baseline kw", () -> trim!(MF(bt), prob()))
try_("trim empty problem", () -> trim!(MF(bt), TrimProblem(guess=(;),lower=(;),upper=(;),condition=d->at("c",set(x=(θ=0.0,ω=0.0))),reads=reads(ω̇ = get_deriv("c", :ω)),residuals=(r,d)->(torque=r.ω̇,),tolerances=(torque=1e-9,)); baseline = base))
println(" empty report: ", try_("e", () -> trim!(MF(bt), TrimProblem(guess=(;),lower=(;),upper=(;),condition=d->at("c",set(x=(θ=0.0,ω=0.0))),reads=reads(ω̇ = get_deriv("c", :ω)),residuals=(r,d)->(torque=r.ω̇,),tolerances=(torque=1e-9,)); baseline = base)))
nonconv = TrimProblem(guess=(u=0.0,),lower=(u=-1.0,),upper=(u=1.0,),condition=d->combine(at("c",set(x=(θ=0.5,ω=0.0))),set(u=(in=d.u,))),reads=reads(ω̇ = get_deriv("c", :ω)),residuals=(r,d)->(torque=r.ω̇,),tolerances=(torque=1e-9,))
mn = MF(bt)
rn = trim!(mn, nonconv; baseline = base)
println("nonconv: converged=", rn.converged, " status=", rn.status, " saturated=", rn.saturated, " committed=", rn.committed_residuals, " model status=", mn.status)
println("LM defaults: ", LevenbergMarquardt())
try_("LM bad λ", () -> LevenbergMarquardt(λ₀ = 0))
println("TrimProblem default checks: ", prob().checks, " ", prob().check_tolerances)
pa = at("x", prob())
println("at(problem) reads prefixes: ", pa.reads.prefixes, " ", typeof(pa.condition(( u = 1.0,))))
println("at(taps) prefixes: ", at("x", lt).x.prefixes)


println("== P8 labeled and Bool y tap")
try
    Redstone.labeled(lin)
catch e
    println("hint: ", replace(sprint(showerror, e), r"\s+" => " ")[1:min(end,300)])
end
using ComponentArrays
ll = Base.invokelatest(Redstone.labeled, lin)
println("labeled types: ", typeof(ll.A), " ", typeof(ll.ẋ₀))
println("A[:θ,:ω] = ", Base.invokelatest(getindex, ll.A, :θ, :ω), "  block: ", Base.invokelatest(getindex, ll.A, (:θ, :ω), (:θ, :ω)))
println("== labeled vs plain: ", Base.invokelatest(==, ll.ẋ₀, lin.ẋ₀), " ", Base.invokelatest(isapprox, ll.ẋ₀, lin.ẋ₀))
ll2 = Base.invokelatest(Redstone.labeled, ll)
println("relabeled same: ", typeof(ll2.A) == typeof(ll.A))
le = linearize(m, taps(x = (θ = get_state("c", :θ),)); width = 8)
lle = Base.invokelatest(Redstone.labeled, le)
println("empty u: ", typeof(lle.u₀), " B: ", typeof(lle.B), " D: ", typeof(lle.D), " y₀: ", typeof(lle.y₀), " C:", typeof(lle.C))
le2 = linearize(m, taps())
lle2 = Base.invokelatest(Redstone.labeled, le2)
println("all empty: ", typeof(lle2.A), " ", typeof(lle2.ẋ₀))
println("nlabels: ", lin.x_labels, lin.u_labels, lin.y_labels)
tank = Group((; k = Constant(1.0), i = Integrator(x0 = 0.8), c = Comparator(threshold = 0.5));
                   local_wires = ("k/y" => "i/u", "i/y" => "c/u"))
mt2 = MF(build(tank)); init!(mt2)
lt2 = linearize(mt2, taps(x = (l = get_state("i", :x),), y = (a = get_output("c"),)))
println("bool y: y0=", lt2.y₀, " C=", lt2.C)
println("widths equal: ", linearize(m, lt; width = 1).A == lin.A, linearize(m, lt; width = 3).B == lin.B)

println("== P9 about on declared defaults, built model")
mt3 = MF(build(tank))
l3 = linearize(mt3, taps(x = (l = get_state("i", :x),)); about = set())
println("about default x0 (expect 0.8): ", l3.x₀, " status after: ", mt3.status)
mt4 = MF(build(tank)); init!(mt4); init!(mt4, set(); t0 = 1)
mt5 = MF(b)
l5 = linearize(mt5, lt; about = full, t0 = 2//1)
println("about t0=2 on :built OK: ", l5.A[1,2], " status ", mt5.status)
println("lin default on 'tank' about with x set then default restore: ", linearize(mt4, taps(x = (l = get_state("i", :x),))).x₀)
println("== done")

# C14_v probes: run from W with JULIA_LOAD_PATH="@" julia --project=test
module C14Probe
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
include(joinpath(W, "utils.jl"))
using ComponentArrays

ds(err) = err === nothing ? nothing : err.carried isa Vector ? err.carried : [err.carried]
show_ds(tag, err) = (println(tag, " => ", err === nothing ? "no error" : typeof(err));
                     err isa DiagnosticError && for d in ds(err)
                         println("    ", typeof(d), " ", join(["$f=$(repr(getfield(d, f)))" for f in fieldnames(typeof(d))], " "))
                     end; err !== nothing && !(err isa DiagnosticError) && println("    ", sprint(showerror, err)))

# --- C14-001: set payload that is not a NamedTuple
show_ds("C14-001 set(x = 1.0)", failure(() -> set(x = 1.0)))
show_ds("C14-001 set(x = nothing)", failure(() -> set(x = nothing)))
show_ds("C14-001 set(s = :sym)", failure(() -> set(s = :sym)))

# --- C14-ok-09 / ok-01: collecting pass reasons, one DiagnosticError
struct WSComp <: AbstractComponent end
x_init(::WSComp) = (q = 0.0,)
u_types(::WSComp) = (u = Float64,)
y_types(::WSComp) = (out = Float64,)
ws_init(::WSComp, ::Type{T}) where {T} = (tmp = Vector{T}(undef, 1),)
x_deriv(::WSComp, (; x, u)) = (q = -x.q + u.u,)
y_state(::WSComp, (; x)) = (out = x.q,)
rig() = Group((; w = WSComp(), a = DiscreteAccumulator(1.0), g = fed(Pendulum(), :u));
              input_wires = ("in" => "w/u", "e" => "a/e", "pu" => "g/in"))
b = Redstone.build(rig())
cond = combine(at("nope", set(x = (q = 1.0,))),
               at("w", set(x = (out = 1.0,))),
               at("w", set(x = (tmp = 1.0,))),
               at("w", set(x = (zz = 1.0,))),
               at("a", set(x = (acc = 1.0,))),
               at("g", set(x = (θ = 1.0,))),
               at("w", set(x = (q = "str",))),
               set(u = (in = 0.0, e = 0.0, pu = 0.0)))
err = failure(() -> resolve_condition(cond, b, Float64))
show_ds("C14-ok-09/ok-01 collecting", err)
println("  one DiagnosticError: ", err isa DiagnosticError, " count ", err isa DiagnosticError ? length(ds(err)) : 0)

# --- C14-002: totality operand
plan = resolve_condition(set(u = (in = 0.0,)), b, Float64)
println("C14-002 root_inputs = ", b.structure.root_inputs, " input_faces(root) = ", input_faces(rig()))
show_ds("C14-002 assert_total", failure(() -> Redstone.assert_total(plan, b.structure, :init!)))
println("C14-002 hasfield Build input_faces: ", hasfield(Build, :input_faces), " fields: ", fieldnames(Build))

# --- linearize sims
lin_pend() = Group((; s = Sum(), c = Pendulum()); local_wires = ("s/e" => "c/u",),
                   input_wires = ("τ" => "s/a", "d" => "s/b"),
                   output_wires = ("c/θ" => "θ", "s/e" => "u_eff"))
lin_point(θ = 0.3) = combine(at("c", condition(Pendulum(); θ = θ)),
                             set(u = (τ = 9.81 * sin(θ), d = 0.0)))
sim = Simulation(lin_pend(); Δt_frame = 1//10); init!(sim, lin_point())
model = sim.model
xt = (θ = get_state("c", :θ), ω = get_state("c", :ω))

# C14-008: ArgumentInvalid reasons
show_ds("C14-008 width=0 (model)", failure(() -> linearize(model, taps(x = xt); width = 0)))
show_ds("C14-008 t0 without about (model)", failure(() -> linearize(model, taps(x = xt); t0 = 1)))
show_ds("C14-008 not a tap set (model)", failure(() -> linearize(model, (x = xt,))))
show_ds("C14-008 not a tap set (sim)", failure(() -> linearize(sim, (x = xt,))))
show_ds("C14-008 t0 range linearize", failure(() -> linearize(model, taps(x = xt); about = lin_point(), t0 = 1//0)))
show_ds("C14-008 t0 range linearize big", failure(() -> linearize(model, taps(x = xt); about = lin_point(), t0 = big(2)^70)))
show_ds("C14-008 trim! not a problem", failure(() -> trim!(Simulation(fed(Pendulum(), :u); Δt_frame = 1//10).model, 1; baseline = set(u = (in = 0.0,)))))

# C14-004: discrete x tap
lin_sampled() = Group((; ctl = DiscreteAccumulator(1.0), c = Pendulum());
                      local_wires = ("ctl/u" => "c/u",), input_wires = ("in" => "ctl/e",))
lin_sampled_point() = combine(at("ctl", set(s = (acc = 4.0,))),
                              at("c", condition(Pendulum(); θ = asin(4.0 / 9.81))), set(u = (in = 0.0,)))
ssim = Simulation(lin_sampled(); Δt_frame = 1//10)
err = failure(() -> linearize(ssim, taps(x = (acc = get_state("ctl", :acc),)); about = lin_sampled_point()))
show_ds("C14-004 discrete x tap", err)
err isa DiagnosticError && println("  message: ", Redstone.message(only(ds(err))))

# C14-ok-41: closed membership
err = failure(() -> linearize(sim, taps(x = (a = get_input(:τ),), u = (b = get_state("c", :θ),), y = (c = get_state("c", :θ), d = get_face(:θ)))))
show_ds("C14-ok-41 membership", err)
show_ds("C14-ok-41 list not NamedTuple", failure(() -> taps(x = 1)))

# C14-ok-49: labeled, empty lists
lin = linearize(sim, taps(x = xt))
L = labeled(lin)
println("C14-ok-49 types: A ", typeof(L.A).name.name, " u0 ", typeof(L.u₀), " y0 ", typeof(L.y₀), " C ", typeof(L.C).name.name, " D ", typeof(L.D))

# C14-ok-17: resolve_leaf
mutable struct MutS; a::Float64; end
struct ImmNB; a::Float64; v::Vector{Float64}; end
struct IsB; a::Float64; end
for (P, steps) in ((IsB, (:a,)), (MutS, (:a,)), (ImmNB, (:a,)), (Symbol, (:a,)), (Float64, ((1,),)),
                   (SVector{3,Float64}, ((2,),)), (SMatrix{2,2,Float64,4}, ((1, 2),)), (SVector{3,Float64}, (:x,)))
    println("C14-ok-17 resolve_leaf($P, $steps) = ", Redstone.resolve_leaf(P, steps))
end

# --- trim probes
pend_base() = set(u = (in = 0.0,))
torque_reads() = reads(ω̇ = get_deriv("c", :ω))
torque_only(r, d) = (torque = r.ω̇,)
decide_u(d) = combine(at("c", condition(Pendulum(); θ = 0.5)), set(u = (in = d.u,)))
fsim() = Simulation(fed(Pendulum(), :u); Δt_frame = 1//10)

# C14-ok-25: key set by set, all-Float64, inverted box
p_perm = TrimProblem(guess = (u = 0.0, v = 1.0), lower = (v = -Inf, u = -Inf), upper = (u = Inf, v = Inf),
                     condition = d -> decide_u((u = d.u,)), reads = torque_reads(),
                     residuals = (r, d) -> (torque = r.ω̇, hold = d.v - 1.0), tolerances = (torque = 1e-9, hold = 1e-9))
rep = trim!(fsim(), p_perm; baseline = pend_base())
println("C14-ok-25 permuted bounds converged: ", rep.converged, " ", rep.solution)
p_bad = TrimProblem(guess = (u = 0.0,), lower = (u = 2.0, w = 0.0), upper = (u = 1,),
                    condition = decide_u, reads = torque_reads(), residuals = torque_only, tolerances = (torque = 1e-9,))
show_ds("C14-ok-25 bad decisions", failure(() -> trim!(fsim(), p_bad; baseline = pend_base())))
p_inv = TrimProblem(guess = (u = 0.0,), lower = (u = 2.0,), upper = (u = 1.0,),
                    condition = decide_u, reads = torque_reads(), residuals = torque_only, tolerances = (torque = 1e-9,))
show_ds("C14-ok-25 inverted", failure(() -> trim!(fsim(), p_inv; baseline = pend_base())))

# C14-ok-33: empty guess
p0 = TrimProblem(guess = (;), lower = (;), upper = (;), condition = d -> combine(at("c", condition(Pendulum(); θ = 0.0)), set(u = (in = 0.0,))),
                 reads = torque_reads(), residuals = torque_only, tolerances = (torque = 1e-9,))
rep0 = trim!(fsim(), p0; baseline = pend_base())
println("C14-ok-33 status=", rep0.status, " converged=", rep0.converged, " evals=", rep0.n_evaluations, " iters=", rep0.n_iterations)

# C14-009: guess projected into the box
evals = Float64[]
p_out = TrimProblem(guess = (u = 10.0,), lower = (u = -1.0,), upper = (u = 3.0,),
                    condition = d -> (push!(evals, ForwardDiff.value(d.u)); decide_u(d)), reads = torque_reads(),
                    residuals = torque_only, tolerances = (torque = 1e-9,))
repo = trim!(fsim(), p_out; baseline = pend_base())
println("C14-009 out-of-box guess: solution=", repo.solution, " status=", repo.status, " saturated=", repo.saturated, " first condition evals=", evals[1:min(end, 3)])

# C14-003: at on a TrimProblem whose reads is no read set
p_nr = TrimProblem(guess = (u = 0.0,), lower = (u = -Inf,), upper = (u = Inf,), condition = decide_u,
                   reads = (ω̇ = get_deriv("c", :ω),), residuals = torque_only, tolerances = (torque = 1e-9,))
m = at("rig", p_nr)
println("C14-003 at passes non-Reads through: ", m.reads === p_nr.reads)
show_ds("C14-003 at(prefix, non-Reads) directly", failure(() -> at("rig", p_nr.reads)))
show_ds("C14-003 trim! mounted non-read-set", failure(() -> trim!(fsim(), m; baseline = pend_base())))
end

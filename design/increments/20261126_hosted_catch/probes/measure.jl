# Allocation figures for the hosted-catch increment, run before and after the
# change on the worktree: `julia --project=test measure.jl <label>` from the
# worktree root. Builds under (Float64, LinearizeDual), results used.
const TREE = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/hosted_catch"
module Probe
using Test
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
include(joinpath(Main.TREE, "test", "imports.jl"))
include(joinpath(Main.TREE, "test", "fixtures.jl"))
include(joinpath(Main.TREE, "test", "utils.jl"))
import Redstone: LinearizeDual, TrimTag, _scratch, _phase!
const LABEL = isempty(ARGS) ? "?" : ARGS[1]
built(world) = build(world; activations = (LinearizeDual,))
say(what, x) = println(LABEL, " | ", rpad(what, 58), " ", x)

# 1. the frame: a standalone model's frame! under NoHooks, past 2 frames
for (name, world, c, kw) in (("pendulum", fed(Pendulum(), :u), set(u = (in = 0.3,)), (; Δt_frame = 1//10)),
                             ("sampled_loop", sampled_loop(), set(u = (ref = 1.0,)), (; Δt_frame = 1//50)),
                             ("bouncer (localizing)", single(Bouncer(1.0, 0.07)), set(), (; Δt_frame = 1//10)))
    model = Model(Deployment(built(world); kw...))
    init!(model, c); frames!(model, 2)
    k = Ref(3)
    b = @ballocated(frame!($model, k), setup = (k = $k[]; $k[] += 1), evals = 1)
    say("frame! $name (B per frame)", b)
end

# 2. init! at Float64 per call, the frozen-init review's two models
for (name, world, c) in (("sampled_loop", sampled_loop(), set(u = (ref = 1.0,))),
                         ("bare_world", bare_world(), set(u = (u = 1.0, p = 0.0))))
    mf = Model(Deployment(built(world); Δt_frame = 1//50))
    plan = Redstone.resolve_condition(c, mf.deployment.build, Float64)
    init!(mf, plan); init!(mf, plan)
    a = @allocated init!(mf, plan)
    a = @allocated init!(mf, plan)
    say("init!(plan) Float64 $name (B)", a)
end

# 3. trim!: one warm evaluation through the seam, and the whole call
struct EvalProbe
    bytes::Base.RefValue{Int}
end
function Redstone.solve(probe::EvalProbe, eval!, d0, lower, upper, tol)
    r, J = zeros(length(tol)), zeros(length(tol), length(d0))
    probe.bytes[] = @ballocated $eval!($r, $J, $d0)
    (; d = d0, status = :probe, n_evaluations = 1, n_iterations = 0)
end
decide_both(d) = combine(at("c", set(x = (θ = d.θ, ω = 0.0))), set(u = (in = d.u,)))
problem = TrimProblem(guess = (θ = 0.1, u = 0.0), lower = (θ = -π/2, u = -Inf),
                      upper = (θ = π/2, u = Inf), condition = decide_both,
                      reads = reads(ω̇ = get_deriv("c", :ω), θ = get_state("c", :θ)),
                      residuals = (r, d) -> (torque = r.ω̇, hold = r.θ - 0.3),
                      tolerances = (hold = 1e-9, torque = 1e-9))
probe = EvalProbe(Ref(-1))
pend = Model(Deployment(built(fed(Pendulum(), :u)); Δt_frame = 1//10))
trim!(pend, problem; baseline = set(u = (in = 0.0,)), backend = probe)
say("trim! eval! per evaluation (B)", probe.bytes[])
for _ in 1:2
    global whole = @allocated trim!(pend, problem; baseline = set(u = (in = 0.0,)))
end
say("trim! whole call, converged (B)", whole)

# 4. linearize: one pass, and the whole call at width 1 over two taps (two passes)
tap_set = taps(x = (θ = get_state("c", :θ), ω = get_state("c", :ω)), u = (u = get_input(:in),),
               y = (θ = get_output("c", :θ),))
lin_model = Model(Deployment(built(fed(Pendulum(), :u)); Δt_frame = 1//10))
init!(lin_model, set(u = (in = 0.3,)))
for w in (8, 1)
    for _ in 1:2
        global lin = @allocated linearize(lin_model, tap_set; width = w)
    end
    say("linearize whole call, width $w (B)", lin)
end
seeded = _scratch(lin_model, LinearizeDual)
_phase!(seeded.exec.cursor, :evaluation)
pass() = (evaluate!(seeded); nothing)
pass(); pass()
say("one bare evaluate! on a seeded scratch (B)", @ballocated pass())
if isdefined(Redstone, :_hosted)
    hosted_pass() = Redstone._hosted(evaluate!, seeded, 0, :linearize)
    hosted_pass(); hosted_pass()
    say("one hosted evaluate! on a seeded scratch (B)", @ballocated hosted_pass())
end
end

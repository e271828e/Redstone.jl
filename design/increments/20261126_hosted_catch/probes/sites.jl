# What each door and service raises on a throwing discrete stage, after the
# change: `julia --project=test sites.jl` from the worktree root.
const TREE = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/hosted_catch"
module Sites
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test
include(joinpath(Main.TREE, "test", "imports.jl"))
include(joinpath(Main.TREE, "test", "utils.jl"))
import Redstone: set, resolve_condition, apply!, evaluate!
say(t, x) = println(rpad(t, 40), " => ", x)
shape(f) = try f(); "no throw" catch e
    string(nameof(typeof(e)), "\n      ", replace(sprint(showerror, e), "\n" => "\n      "))
end
D8b = ForwardDiff.Dual{:p,Float64,8}

struct Cmd <: AbstractComponent end
s_init(::Cmd) = (c = 0.0,)
u_types(::Cmd) = (r = Float64,)
y_types(::Cmd) = (u = Float64,)
y_direct(::Cmd, (; s, u)) = (u = sqrt(s.c + u.r),)     # throws at r < 0
s_update(::Cmd, (; s)) = (c = s.c,)
struct Lag <: AbstractComponent end
x_init(::Lag) = (v = 0.0,)
u_types(::Lag) = (u = Float64,)
y_types(::Lag) = (v = Float64,)
y_state(::Lag, (; x)) = (v = x.v,)
x_deriv(::Lag, (; x, u)) = (v = sqrt(x.v) + u.u - x.v,)   # throws at v < 0
world() = Group((cmd = Cmd(), lag = Lag()); local_wires = ("cmd/u" => "lag/u",),
                input_wires = ("r" => "cmd/r",), output_wires = ("lag/v" => "v",))

bad = set(u = (r = -1.0,))
good = set(u = (r = 4.0,))
problem(guess) = TrimProblem(guess = (v = guess,), lower = (v = -Inf,), upper = (v = Inf,),
                             condition = d -> at("lag", set(x = (v = d.v,))),
                             reads = reads(v̇ = get_deriv("lag", :v)),
                             residuals = (r, d) -> (rate = r.v̇,), tolerances = (rate = 1e-9,))
lag_taps = taps(x = (v = get_state("lag", :v),), u = (;), y = (;))
m() = Model(world(); Δt_frame = 1//10)
say("init! at Float64", shape(() -> init!(m(), bad)))
say("init! at Dual", shape(() -> init!(Model(world(), D8b; Δt_frame = 1//10), bad)))
say("trim! (setup round)", shape(() -> trim!(m(), problem(1.0); baseline = bad)))
say("trim! (seeded, x at -1)", shape(() -> trim!(m(), problem(-1.0); baseline = good)))
say("linearize(about)", shape(() -> linearize(m(), lag_taps; about = bad)))
say("linearize(about, x at -1)", shape(() -> linearize(m(), lag_taps; about = combine(good, at("lag", set(x = (v = -1.0,)))))))
end

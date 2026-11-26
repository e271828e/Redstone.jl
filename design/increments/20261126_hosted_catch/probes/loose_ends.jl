const W = "/Users/miguel/.julia/dev/Redstone.jl/test"
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test
include(joinpath(W, "imports.jl"))
import Redstone: set, resolve_condition, apply!, evaluate!
say(t, x) = println(rpad(t, 52), " => ", x)
shape(f) = try f(); "no throw" catch e
    first(split(sprint(showerror, e), '\n'), 6) |> lines -> string(nameof(typeof(e)), "\n      ", join(lines, "\n      "))
end
D8 = ForwardDiff.Dual{:p,Float64,8}

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
x_deriv(::Lag, (; x, u)) = (v = u.u - x.v,)
world() = Group((cmd = Cmd(), lag = Lag()); local_wires = ("cmd/u" => "lag/u",),
                input_wires = ("r" => "cmd/r",), output_wires = ("lag/v" => "v",))

println("--- loose end 2: apply! and evaluate! on a :built model, no init!")
for T in (Float64, D8)
    m = Model(world(), T; Δt_frame = 1//10)
    apply!(m, resolve_condition(set(u = (r = 4.0,)), m.deployment.build, T))
    evaluate!(m)
    say("[$(nameof(T))] status", m.status)
    say("[$(nameof(T))] cmd.u (authored world says 2)", port(m, "cmd", :u))
    say("[$(nameof(T))] ẋ lag (authored world says 2)", m.exec.ẋbuf[1])
end

println("--- loose end 1: the same discrete stage throwing, by door")
bad = set(u = (r = -1.0,))
problem = TrimProblem(guess = (v = 0.0,), lower = (v = -Inf,), upper = (v = Inf,),
                      condition = d -> at("lag", set(x = (v = d.v,))),
                      reads = reads(v̇ = get_deriv("lag", :v)),
                      residuals = (r, d) -> (rate = r.v̇,), tolerances = (rate = 1e-9,))
lag_taps = taps(x = (v = get_state("lag", :v),), u = (;), y = (;))
say("init! at Float64", shape(() -> init!(Model(world(); Δt_frame = 1//10), bad)))
say("init! at Dual", shape(() -> init!(Model(world(), D8; Δt_frame = 1//10), bad)))
say("trim! (setup round)", shape(() -> trim!(Model(world(); Δt_frame = 1//10), problem; baseline = bad)))
say("linearize(about)", shape(() -> linearize(Model(world(); Δt_frame = 1//10), lag_taps; about = bad)))

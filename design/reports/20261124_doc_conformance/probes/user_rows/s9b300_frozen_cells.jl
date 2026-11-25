const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test
include(joinpath(W, "imports.jl")); include(joinpath(W, "fixtures.jl")); include(joinpath(W, "utils.jl"))
import Redstone: mutable_position, retype, _opaque
say(t, x) = println(rpad(t, 44), " => ", x)
D8_ = ForwardDiff.Dual{:p,Float64,8}
# --- S9b-300
struct Cmd <: AbstractComponent end
s_init(::Cmd) = (c = 0.0,)
u_types(::Cmd) = (r = Float64,)
y_types(::Cmd) = (u = Float64,)
y_direct(::Cmd, (; s, u)) = (u = s.c + u.r,)
s_update(::Cmd, (; s)) = (c = s.c,)
struct Lag <: AbstractComponent end
x_init(::Lag) = (v = 0.0,)
u_types(::Lag) = (u = Float64,)
y_types(::Lag) = (v = Float64,)
y_state(::Lag, (; x)) = (v = x.v,)
x_deriv(::Lag, (; x, u)) = (v = u.u - x.v,)
w = Group((cmd = Cmd(), lag = Lag()); local_wires = ("cmd/u" => "lag/u",), input_wires = ("r" => "cmd/r",), output_wires = ("lag/v" => "v",))
import Redstone: set
for T in (Float64, D8_)
    m = Model(w, T; Δt_frame = 1//10)
    say("[$T] built: cmd.u", port(m, "cmd", :u))
    try
        init!(m, set(u = (r = 2.0,)))
        say("[$T] r=2: cmd.u after init!", port(m, "cmd", :u))
        evaluate!(m)
        say("[$T] ẋ lag (expected 2)", m.exec.ẋbuf[1])
        frames!(m, 10)
        say("[$T] lag.v after 10 frames", state(m, "lag").v)
    catch e; say("err", sprint(showerror, e)[1:min(end,400)]); end
end

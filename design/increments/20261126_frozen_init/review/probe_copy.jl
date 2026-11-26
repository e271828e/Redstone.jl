# The nominal round's inputs across cell kinds: a static-array root input, an
# enum root input only a discrete component reads, a struct root input with a
# walking and an enum leaf, a discrete workspace, nested Duals with nonzero
# partials. Every frozen cell is compared with the Float64 model's.
include(joinpath(@__DIR__, "probe_common.jl"))

struct VecHold <: AbstractComponent end
s_init(::VecHold) = nothing
u_types(::VecHold) = (v = SVector{2,Float64}, g = Gear)
y_types(::VecHold) = (out = Float64,)
y_direct(::VecHold, (; u)) = (out = u.v[1] + 10 * Int(u.g) + 100 * u.v[2],)

struct VecLag <: AbstractComponent end
x_init(::VecLag) = 0.0
u_types(::VecLag) = (v = SVector{2,Float64},)
y_types(::VecLag) = (y = Float64,)
y_state(::VecLag, (; x)) = (y = x,)
x_deriv(::VecLag, (; x, u)) = u.v[1] - x

struct Wind{T}
    speed::T
    gear::Gear
end

Redstone.probe_value(::Type{Wind{T}}) where {T} = Wind(zero(T), up)

struct WindLag <: AbstractComponent end
x_init(::WindLag) = 0.0
u_types(::WindLag) = (w = Wind{Float64},)
y_types(::WindLag) = (y = Float64,)
y_state(::WindLag, (; x)) = (y = x,)
x_deriv(::WindLag, (; x, u)) = u.w.speed - x

struct WindHold <: AbstractComponent end
s_init(::WindHold) = (k = 3,)
u_types(::WindHold) = (w = Wind{Float64},)
y_types(::WindHold) = (out = Float64, mode = Gear)
y_direct(::WindHold, (; u, s)) = (out = s.k * u.w.speed, mode = u.w.gear)
s_update(::WindHold, (; s)) = (k = s.k + 1,)

struct WsHold <: AbstractComponent end
s_init(::WsHold) = nothing
u_types(::WsHold) = (in = Float64,)
y_types(::WsHold) = (out = Float64,)
ws_init(::WsHold, ::Type) = (tmp = Vector{Float64}(undef, 1),)
y_direct(::WsHold, (; u, ws)) = (ws.tmp[1] = 3 * u.in; (out = ws.tmp[1],))

struct VecPass <: AbstractComponent end
x_init(::VecPass) = nothing
u_types(::VecPass) = (v = SVector{2,Float64},)
y_types(::VecPass) = (v = SVector{2,Float64},)
y_direct(::VecPass, (; u)) = (v = u.v,)

struct WindPass <: AbstractComponent end
x_init(::WindPass) = nothing
u_types(::WindPass) = (w = Wind{Float64},)
y_types(::WindPass) = (w = Wind{Float64},)
y_direct(::WindPass, (; u)) = (w = u.w,)

world() = Group((; vh = VecHold(), vl = VecLag(), vp = VecPass(), wl = WindLag(), wp = WindPass(),
                   wh = WindHold(), ws = WsHold());
                local_wires = ("vl/y" => "ws/in", "vp/v" => "vh/v", "wp/w" => "wh/w"),
                input_wires = ("v" => ("vl/v", "vp/v"), "g" => "vh/g",
                               "w" => ("wl/w", "wp/w")))

seed(::Type{Float64}, v) = v
seed(::Type{D8}, v) = D8(v, ForwardDiff.Partials(ntuple(i -> Float64(i), 8)))
seed(::Type{NESTED}, v) = NESTED(ForwardDiff.Dual{Nothing}(v, 7.0), ForwardDiff.Partials((ForwardDiff.Dual{Nothing}(5.0, 3.0),)))

frozen(m) = (port(m, "vh", :out), port(m, "wh", :out), port(m, "wh", :mode), port(m, "ws", :out))

results = map((Float64, D8, NESTED)) do T
    m = Model(world(), T; Δt_frame = 1//10)
    cond = combine(at("vl", set(x = seed(T, 4.0))), at("wh", set(s = (k = 5,))),
                   set(u = (v = SVector(seed(T, 2.0), seed(T, 0.5)), g = down,
                            w = Wind(seed(T, 7.0), down))))
    err = failure(() -> init!(m, cond))
    err === nothing || (println(T, " threw ", err); return nothing)
    r = frozen(m)
    println(T === Float64 ? "Float64" : T === D8 ? "D8" : "nested", ": ", r, " types ", typeof.(r),
            " status ", m.status)
    r
end
@show results[1] == results[2] == results[3]

using Test, StaticArrays, LinearAlgebra, ForwardDiff
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
include(joinpath(W, "utils.jl"))

mutable struct H{M} <: FrameHooks
    model::M
    clocks::Vector{Float64}
end
frame_top!(::H) = false
settled!(h::H) = (push!(h.clocks, Float64(ForwardDiff.value(h.model.exec.clock.t))); false)

split_rig() = Group((; c = Plant(), a = TickCounter()); input_wires = ("in" => "c/u",),
                    sample_times = (; a = Absolute(7//100)))

function run(T; kw...)
    m = Model(split_rig(), T; Δt_frame = 1//10, Δt_base = 1//100, kw...)
    u = T === Float64 ? 0.0 : T(0.0)
    init!(m, set(u = (in = u,)))
    h = H(m, Float64[])
    for k in 1:2; frame!(m, k, h); end
    (m, h.clocks)
end

# probe:30 boundaries: base tick with no due is no boundary; due 0.07 is; frame tops 0.1, 0.2
m, c = run(Float64)
println("probe:33 f64 clocks ", c)
md, cd = run(D8)
println("probe:35 dual clocks ", cd, " equal=", c == cd, " dual events=", md.exec.has_localized)
println("probe:36 a.n f64=", state(m, "a").n, " dual=", ForwardDiff.value.(state(md, "a").n))

# fixed-step bound 1/35: spans 7,3,4,6 units -> 3,2,2,3 steps
m2, c2 = run(Float64; h_max = 1//35)
println("probe:40 h_max=1/35 clocks ", c2, " n=", length(c2))
m3, c3 = run(Float64; h_max = 1//20)
println("probe:42 h_max=1/20 clocks ", c3)
m4, c4 = run(Float64; h_max = 1//1)
println("probe:44 h_max=1 clocks ", c4)

# discrete output hold: port before first tick
m5 = Model(split_rig(); Δt_frame = 1//10, Δt_base = 1//100)
init!(m5, set(u = (in = 0.0,)))
println("probe:49 after init port a/n = ", port(m5, "a", :n), " state n = ", state(m5, "a").n)
hh = H(m5, Float64[])
vals = Tuple{Float64,Any}[]
mutable struct H2{M} <: FrameHooks
    model::M
    v::Vector{Tuple{Float64,Any}}
end
frame_top!(::H2) = false
settled!(h::H2) = (push!(h.v, (h.model.exec.clock.t, port(h.model, "a", :n))); false)
h2 = H2(m5, Tuple{Float64,Any}[])
for k in 1:2; frame!(m5, k, h2); end
println("probe:59 port a/n at boundaries ", h2.v)

# condition cannot set time
try
    init!(Model(split_rig(); Δt_frame = 1//10, Δt_base = 1//100), set(t = 1.0, u = (in = 0.0,)))
    println("probe:64 set(t=) accepted")
catch e
    println("probe:66 set(t=) refused: ", sprint(showerror, e)[1:min(end, 300)])
end

# refusal of a k past the last frame and of a clock that cannot separate boundaries
m6 = Model(split_rig(); Δt_frame = 1//10, Δt_base = 1//100)
init!(m6, set(u = (in = 0.0,)))
lf = Redstone._last_frame(m6)
println("probe:73 last_frame = ", lf)
try
    frame!(m6, lf + 1)
catch e
    println("probe:77 ", first(sprint(showerror, e), 120))
end
println("probe:79 status after refusal ", m6.status)
# t0 huge
try
    init!(m6, set(u = (in = 0.0,)); t0 = 2^62)
catch e
    println("probe:84 ", first(sprint(showerror, e), 160))
end

# clock t0 after restore: checkpoint keeps t0
init!(m6, set(u = (in = 0.0,)); t0 = 5//2)
frame!(m6, 1)
cp = checkpoint(m6)
println("probe:91 checkpoint t0 = ", cp.t₀, " clock ", m6.exec.clock.t)
m7 = Model(split_rig(); Δt_frame = 1//10, Δt_base = 1//100)
restore!(m7, cp)
println("probe:94 restored clock t = ", m7.exec.clock.t, " t0 = ", m7.exec.clock.t₀)

# adaptive: no step shorter than the floor unless less remains
bs = Model(feedback_model(); Δt_frame = 1//2, h_min = 1//10^4, algorithm = BS3(reltol = 1e-6, abstol = 1e-9))
init!(bs, set(u = (ref = 1.0,)))
hb = H(bs, Float64[])
frame!(bs, 1, hb)
println("probe:101 bs3 boundaries n=", length(hb.clocks), " min step ", minimum(diff([0.0; hb.clocks])), " last ", hb.clocks[end])
println("probe:102 h_min ", 1e-4, " h_max ", Float64(bs.deployment.h_max))

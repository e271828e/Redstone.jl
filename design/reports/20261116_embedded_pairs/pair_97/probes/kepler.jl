# M1: an eccentric Kepler orbit, μ = a = 1, from pericenter, period 2π.
include(joinpath(@__DIR__, "common.jl"))
import Redstone: x_init, x_deriv, y_types, y_state

const SWEEPS = Ref(0)   # y_state runs once per sweep
const RHS = Ref(0)      # x_deriv runs once per rhs block

struct Kepler <: AbstractComponent
    e::Float64
end
x_init(c::Kepler) = (rx = 1 - c.e, ry = 0.0, vx = 0.0, vy = sqrt((1 + c.e) / (1 - c.e)))
y_types(::Kepler) = (rx = Float64, ry = Float64, vx = Float64, vy = Float64)
y_state(::Kepler, (; x)) = (SWEEPS[] += 1; (rx = x.rx, ry = x.ry, vx = x.vx, vy = x.vy))
function x_deriv(::Kepler, (; x))
    RHS[] += 1
    r3 = (x.rx^2 + x.ry^2)^1.5
    (rx = x.vx, ry = x.vy, vx = -x.rx / r3, vy = -x.ry / r3)
end

# The exact state at t.
function kepler_exact(e, t)
    M = t
    E = M + e * sin(M)
    for _ in 1:60
        E -= (E - e * sin(E) - M) / (1 - e * cos(E))
    end
    d = 1 - e * cos(E)
    [cos(E) - e, sqrt(1 - e^2) * sin(E), -sin(E) / d, sqrt(1 - e^2) * cos(E) / d]
end

# The bare ODE, for reference local steps.
function kepler_f(x)
    r3 = (x[1]^2 + x[2]^2)^1.5
    [x[3], x[4], -x[1] / r3, -x[2] / r3]
end
function rk4_ref(x, h; n = 4000)
    x = copy(x); δ = h / n
    for _ in 1:n
        k1 = kepler_f(x); k2 = kepler_f(x .+ δ / 2 .* k1)
        k3 = kepler_f(x .+ δ / 2 .* k2); k4 = kepler_f(x .+ δ .* k3)
        x = x .+ δ / 6 .* (k1 .+ 2k2 .+ 2k3 .+ k4)
    end
    x
end

const ECC = parse(Float64, get(ENV, "ECC", "0.8"))
kepler_model() = Group((; k = Kepler(ECC)))

# One run: counts, errors (position, Euclidean), floors.
function kepler_run(alg; Δt_frame = 2 // 1, t_end = 20.0, h_min = 1 // 2^40)
    sim = Simulation(kepler_model(); Δt_frame, h_min, algorithm = alg)
    init!(sim)
    SWEEPS[] = 0; RHS[] = 0
    run!(sim; t_end)
    st = sim.model.exec.stepper
    c = counts(st)
    s = series(sim, reads(rx = get_output("k", :rx), ry = get_output("k", :ry)))
    errs = [hypot(s.columns.rx[i] - kepler_exact(ECC, s.t[i])[1], s.columns.ry[i] - kepler_exact(ECC, s.t[i])[2])
            for i in eachindex(s.t)]
    (; acc = c.accepted, rej = c.attempts - c.accepted, att = c.attempts,
       stage_sweeps = c.stage_sweeps, stage_rhs = c.stage_rhs,
       sweeps = SWEEPS[], rhs = RHS[], err_end = errs[end], err_max = maximum(errs),
       t_last = s.t[end], nsnap = length(s.t), floors = floor_total(sim), sim)
end

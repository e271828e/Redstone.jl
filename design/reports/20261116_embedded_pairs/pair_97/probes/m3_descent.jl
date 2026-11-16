# M3: the descent to touchdown, as test_longitudinal.jl flies it, plus a passive sweep counter.
include(joinpath(@__DIR__, "m_common.jl"))
import Redstone: x_init, u_types, y_types, y_direct
import Redstone.Library: Group, StopRequest
import RedstoneExamples: GroundContact
const SWEEPS = Ref(0)
struct SweepCounter <: AbstractComponent end
x_init(::SweepCounter) = nothing
u_types(::SweepCounter) = Float64
y_types(::SweepCounter) = Float64
y_direct(::SweepCounter, (; u)) = (SWEEPS[] += 1; u)
counted_descent() = Group((; plant = Longitudinal(), gear = GroundContact(), stop = StopRequest(reason = "touchdown"),
                             n = SweepCounter());
                          input_wires = ("δe" => "plant/δe", "δt" => "plant/δt"),
                          local_wires = ("plant/h" => "gear/h", "gear/contact" => "stop/u", "plant/h" => "n/u"))
const SOL, _ = trim_solution()
# frame-top snapshots only, keyed by frame index (snapshots are logged at every boundary)
function frame_tops(sim)
    t, X = plant_series(sim)
    keep = [i for i in eachindex(t) if abs(t[i] * 100 - round(t[i] * 100)) < 1e-7]
    Dict(round(Int, t[i] * 100) => X[i, :] for i in keep)
end
at_trim(solution, plant_state; δt = solution.δt) =
    combine(at("plant", plant_state), set(u = (δe = solution.δe, δt = δt)))
function fly(; deployment...)
    sim = Simulation(counted_descent(); Δt_frame = 1 // 100, deployment...)
    init!(sim, at_trim(SOL, condition(Longitudinal(); θ = SOL.θ, h = 30.0); δt = 0.25); trace = false, log_max = Inf)
    SWEEPS[] = 0
    run!(sim; t_end = 200.0)
    sim
end
ref = fly(; algorithm = RK4(), h_max = 1 // 100 // 32)
R = frame_tops(ref); td_ref = termination(ref).t
ref16 = fly(; algorithm = RK4(), h_max = 1 // 100 // 16)
ferr(F, R) = maximum(maximum(abs.(F[k] .- R[k]) ./ max.(1.0, abs.(R[k]))) for k in keys(F) if haskey(R, k))
println("reference: touchdown ", td_ref, " (h/16: ", termination(ref16).t, ") frame tops ", length(R),
        " ref h/16 vs h/32 frame-top err ", ferr(frame_tops(ref16), R))
println("lab    tol     acc     rej  st_sweeps  sweeps_tot    rhs     td_err     err_max   floors")
for lab in ("A", "B_mid", "B_1/9"), tol in (1e-2, 1e-3, 1e-4, 1e-5, 1e-6, 1e-7)
    sim = fly(; algorithm = candidate(lab, tol), h_min = 1 // 2^40)
    F = frame_tops(sim)
    c = sim.model.exec.stepper.c
    @printf("%-6s %.0e %7d %6d %9d %9d %9d  %.3e  %.3e  %d\n", lab, tol, c.accepted, c.attempts - c.accepted,
            c.stage_sweeps, SWEEPS[], c.stage_rhs, abs(termination(sim).t - td_ref), ferr(F, R), floor_total(sim))
    flush(stdout)
end

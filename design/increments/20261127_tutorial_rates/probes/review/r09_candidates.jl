# r09: the candidate tests the review proposes, run against whichever tree's environment loads
# (the review worktree, or the mutant copy `mtree` under a mutant). Each prints PASS or FAIL.
using Test, Printf
using Statistics: cor
using Redstone, RedstoneExamples
import Redstone: Simulation, init!, run!, series, reads, get_output, get_face, set, at, override
const RE = RedstoneExamples
include(joinpath(dirname(dirname(pathof(RedstoneExamples))), "test", "utils.jl"))
println("RedstoneExamples from ", pathof(RedstoneExamples))
const DEP = (Δt_frame = 1//400, Δt_base = 1//200)
quiet = (q = 0.0, θ = 0.0, h = 0.0, V = 0.0)
on_grid(t, rate) = isapprox(rate * t, round(rate * t); atol = 1e-6)
tsim = Simulation(RE.aircraft(); Δt_frame = 1//100)
solution = Redstone.trim!(tsim, RE.level_flight(); baseline = set(u = (δe = 0.0, δt = 0.5))).solution
report(name, ok) = println(ok ? "PASS " : "FAIL ", name)

# T1: with every noise off, each model passes the keyword down: its measurements equal the plant's
# outputs at the sensors' ticks.
let ok = true
    for (model, ic, prefix) in ((RE.autopilot(solution; noise_psd = quiet), RE.cruise(solution), ""),
                                (RE.piloted(solution; noise_psd = quiet), RE.hand_flown(solution), ""),
                                (RE.approach(solution; noise_psd = quiet), at("vehicle", RE.hand_flown(solution)), "vehicle/"))
        sim = Simulation(model; DEP...); init!(sim, ic); run!(sim; t_end = 1.0)
        times = logged_times(sim)
        for (face, port, rate) in ((:q_meas, :q, 200), (:θ_meas, :θ, 50), (:h_meas, :h, 10), (:V_meas, :V, 10))
            ticks = on_grid.(times, rate)
            ok &= logged_face(sim, "$(prefix)sensing", face)[ticks] == logged_port(sim, "$(prefix)plant", port)[ticks]
        end
    end
    report("T1 noise_psd reaches every model's sensing", ok)
end

# T2: the four noises' draws, each at its own ticks, pairwise uncorrelated by draw index.
let ok = true
    sim = Simulation(RE.autopilot(solution); DEP...)
    init!(sim, override(RE.cruise(solution), set(u = (h_ref = 1050.0,)))); run!(sim; t_end = 120.0)
    times = logged_times(sim)
    draws = map(((:q, "imu", 200), (:θ, "ins", 50), (:h, "air_data", 10), (:V, "air_data", 10))) do (var, sensor, rate)
        logged_port(sim, "sensing/$sensor/$(var)_noise", "")[on_grid.(times, rate)]
    end
    for i in 1:4, j in (i + 1):4
        n = min(length(draws[i]), length(draws[j]))
        c = cor(draws[i][1:n], draws[j][1:n])
        @printf("   cor %d,%d = %.4f\n", i, j, c)
        ok &= abs(c) < 0.15
    end
    report("T2 every pair of noises uncorrelated by draw", ok)
end

# T3: the schedule's divisors on all three models.
let ok = true
    divisors = Dict("sensing/imu/q_noise" => 1, "sensing/imu/q_meas" => 1,
                    "sensing/ins/θ_noise" => 4, "sensing/ins/θ_meas" => 4,
                    "sensing/air_data/h_noise" => 20, "sensing/air_data/h_meas" => 20,
                    "sensing/air_data/V_noise" => 20, "sensing/air_data/V_meas" => 20,
                    "cascade/q_ctl" => 1, "cascade/θ_ctl" => 4, "cascade/h_ctl" => 20, "cascade/V_ctl" => 20,
                    "selection/latch" => 20, "selection/command_δe" => 1, "selection/command_δt" => 1,
                    "actuators/δe_limiter" => 1, "actuators/δt_limiter" => 1)
    without_selection = filter(entry -> !startswith(entry.first, "selection/"), divisors)
    for (model, expected) in ((RE.autopilot(solution), without_selection), (RE.piloted(solution), divisors),
                              (RE.approach(solution), Dict("vehicle/" * path => D for (path, D) in divisors)))
        rows = Simulation(model; DEP...).model.deployment.schedule.rows
        got = Dict(row.path => row.D for row in rows)
        got == expected || println("   ", setdiff(collect(got), collect(expected)), " vs ", setdiff(collect(expected), collect(got)))
        ok &= got == expected
    end
    report("T3 divisors on autopilot, piloted and approach", ok)
end

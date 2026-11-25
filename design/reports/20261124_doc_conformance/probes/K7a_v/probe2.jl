# K7a verifier probe: longitudinal_aircraft.md against the code at W.
# Run from W: JULIA_LOAD_PATH="@" julia --startup-file=no --project=examples/test <this file>
using LinearAlgebra
using Redstone, RedstoneExamples
import Redstone: Simulation, init!, run!, step!, stage!, trim!, linearize, set, at, combine, override,
    series, reads, get_output, get_face, get_input, Group, Absolute
using Redstone.Library: Constant, GaussianWhiteNoise, DiscretePID
import RedstoneExamples: Longitudinal, aircraft, level_flight, longitudinal_taps, lqr_gains, closed_loop,
    trimmed, autopilot, cruise, cascade, actuators, feedback_wires, Altimeter, sensing

const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
println("Redstone from ", pathof(Redstone))
println("RedstoneExamples from ", pathof(RedstoneExamples))
startswith(pathof(Redstone), W) && startswith(pathof(RedstoneExamples), W) || error("not loading W")
include(joinpath(W, "examples/test/utils.jl"))

pr(label, xs...) = println("PROBE ", label, ": ", join(xs, " | "))
r(x, n = 4) = round(x; sigdigits = n)
function sect(f, name)
    println("== ", name)
    try f() catch err; println("SECTION FAILED ", name, ": ", sprint(showerror, err)[1:min(end, 800)]); end
end

function trim_of(plant)
    m = Group((; plant); input_wires = ("δe" => "plant/δe", "δt" => "plant/δt"))
    sim = Simulation(m; Δt_frame = 1//100)
    rep = trim!(sim, level_flight(); baseline = set(u = (δe = 0.0, δt = 0.5)))
    (sim, rep)
end
sim0, report = trim_of(Longitudinal())
solution = report.solution
lin = linearize(sim0, longitudinal_taps())
A, B = lin.A, lin.B
gains = lqr_gains(lin)
pairs_of(M) = (λs = eigvals(M); up = filter(λ -> imag(λ) > 0, λs);
               (fast = up[argmax(imag.(up))], slow = up[argmin(imag.(up))]))
ωζ(λ) = (abs(λ), -real(λ) / abs(λ))

# The test's closed-loop helper, with a model builder.
function fly_cl(build_model; cascade = true, switch_at = nothing, h_step = 50.0, t_end = 120.0)
    h = 1//200; frame(t) = round(Int, t / h)
    sim = Simulation(build_model(); Δt_frame = h)
    init!(sim, cascade ? trimmed(solution) : override(trimmed(solution), set(u = (mode = false,))))
    step!(sim; frames = frame(5.0) - 1)
    stage!(sim, "h_ref" => 1000.0 + h_step)
    if switch_at !== nothing
        step!(sim; frames = frame(switch_at) - frame(5.0))
        stage!(sim, "mode" => !cascade)
    end
    run!(sim; t_end)
    sim
end
gap(sim, a, b, t0, t1) = largest_gap(a, b, sim, t0, t1)

# closed_loop with every Tt set to `TT`, from the source text.
src = read(joinpath(W, "examples/src/longitudinal.jl"), String)
i0 = findfirst("function closed_loop(", src).start
i1 = findnext("\nend\n", src, i0).stop
body = replace(src[i0:i1], "function closed_loop(solution, gains; noise_σ = 0.3)" =>
               "function closed_loop_Tt(solution, gains, TT; noise_σ = 0.3)", "Tt = 0.02" => "Tt = TT")
Core.eval(RedstoneExamples, Meta.parse(body))
closed_loop_Tt = RedstoneExamples.closed_loop_Tt


sect("K7a-333 gap per tick after the step") do
    c = fly_cl(() -> closed_loop(solution, gains))
    t = logged_times(c); d = abs.(logged_face(c, "lqr_controller", :δe) .- logged_face(c, "selection", :δe))
    for k in findall(window(c, 4.99, 5.08)); pr("t gap", t[k], r(d[k])); end
end
sect("K7a-296 standby gaps during the maneuver, tracker in command") do
    s = fly_cl(() -> closed_loop(solution, gains); cascade = false)
    t = logged_times(s)
    sel = logged_face(s, "selection", :δe); selt = logged_face(s, "selection", :δt)
    hgap = abs.(logged_port(s, "pid_controller/h_ctl", :u) .- logged_port(s, "plant", :θ))
    Vgap = abs.(logged_face(s, "pid_controller", :δt) .- selt)
    for (name, d) in (("altitude", hgap), ("airspeed", Vgap))
        w = window(s, 5, 15); k = findall(w)[argmax(d[w])]
        pr(name * " max [5,15) at", r(d[k]), t[k])
        for a in (5.1, 5.5, 6.0, 8.0, 10.0)
            pr(name * " max [$a,15)", r(maximum(d[window(s, a, 15)])))
        end
    end
end

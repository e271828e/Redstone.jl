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

sect("K7a-082 A row 4, B row 4") do
    pr("A row 4", r.(A[4, :]))
    pr("B row 4", r.(B[4, :]))
    pr("A row 2", r.(A[2, :]), "B[2,2]", r(B[2, 2]))
end

sect("K7a-091/092/101/110 modes") do
    p = pairs_of(A)
    pr("full fast ωn ζ", ωζ(p.fast)...)
    pr("full slow ωn ζ", ωζ(p.slow)...)
    a22, a23 = A[2, 2], A[2, 3]; a42, a44 = A[4, 2], A[4, 4]
    # α̇ = q − Zα α ; q̇ = Mα α + Mq q, with Zα = A[2,3], Mα = A[4,3]
    M2 = [-A[2, 3] 1.0; A[4, 3] A[4, 4]]
    tr2, det2 = -tr(M2), det(M2)
    ωn2 = sqrt(det2); ζ2 = tr2 / (2ωn2)
    pr("two-state poly s² + b s + c", r(tr2, 5), r(det2, 5), "ωn", ωn2, "ζ", ζ2)
    P = Longitudinal(); g = RedstoneExamples.g
    CL = P.CL0 + P.CLα * solution.θ; CD = P.CD0 + P.k * CL^2
    LD = CL / CD
    pr("Lanchester ωn ζ L/D", sqrt(2) * g / 50, 1 / (sqrt(2) * LD), LD)
    simq, repq = trim_of(Longitudinal(Cmq = 0.0))
    linq = linearize(simq, longitudinal_taps())
    pq = pairs_of(linq.A)
    pr("Cmq=0 slow ωn ζ", ωζ(pq.slow)...)
end

# The autopilot under a given sensing and cascade, as autopilot() wires it.
function autopilot_with(sol; sensing_group, cascade_group)
    Group((; plant = Longitudinal(), sensing = sensing_group, cascade = cascade_group,
             actuators = actuators(sol), engaged = Constant(true));
          input_wires = ("h_ref" => "cascade/h_ref", "V_ref" => "cascade/V_ref"),
          local_wires = (feedback_wires()..., "engaged/y" => "cascade/engaged",
                         "cascade/δe" => "actuators/δe_cmd", "cascade/δt" => "actuators/δt_cmd"))
end
function late(sim; from = 75.0)
    t = logged_times(sim); m = t .>= from
    h = logged_port(sim, "plant", :h); V = logged_port(sim, "plant", :V)
    (h_err = maximum(abs, h[m] .- 1050), V_err = maximum(abs, V[m] .- 50), peak = maximum(h),
     V_exc = maximum(abs, V .- 50), t_V_exc = t[argmax(abs.(V .- 50))])
end
function fly(model, sol; t_end = 120.0)
    sim = Simulation(model; Δt_frame = 1//200)
    init!(sim, override(cruise(sol), set(u = (h_ref = 1050.0,))))
    run!(sim; t_end)
    sim
end

sect("K7a-174/264 sensor table and the autopilot step") do
    fast, slow = Absolute(1//50), Absolute(1//10)
    s50 = Group(sensing(); sample_times = (noise = fast, altimeter = fast))
    c50 = Group(cascade(); sample_times = (h_ctl = fast, θ_ctl = fast, q_ctl = fast, V_ctl = fast))
    row1 = late(fly(autopilot_with(solution; sensing_group = s50, cascade_group = cascade()), solution))
    row2 = late(fly(autopilot_with(solution; sensing_group = s50, cascade_group = c50), solution))
    row3 = late(fly(autopilot(solution), solution))
    pr("row1 50 Hz sensor two rates", row1)
    pr("row2 50 Hz sensor all 50 Hz", row2)
    pr("row3 10 Hz altimeter (autopilot)", row3)
end

sect("K7a-219 errors at the trim") do
    sim = Simulation(autopilot(solution; noise_psd = 0.0); Δt_frame = 1//200)
    init!(sim, cruise(solution)); run!(sim; t_end = 0.1)
    hu = logged_port(sim, "cascade/h_ctl", :u)[1]; θu = logged_port(sim, "cascade/θ_ctl", :u)[1]
    qu = logged_port(sim, "cascade/q_ctl", :u)[1]; Vu = logged_port(sim, "cascade/V_ctl", :u)[1]
    pr("h_ctl/u − θ", hu - solution.θ, "θ_ctl/u", θu, "q_ctl/u − δe", qu - solution.δe, "V_ctl/u − δt", Vu - solution.δt)
end

sect("K7a-298 one-period correction on a DiscretePID") do
    m = Group((; pid = DiscretePID(Kp = 0.0, Ki = 1.0, u_max = 1.0, Tt = 0.02));
              input_wires = ("r" => "pid/r", "y" => "pid/y"), sample_times = (pid = Absolute(1//50),))
    sim = Simulation(m; Δt_frame = 1//50)
    init!(sim, combine(set(u = (r = 0.0, y = 0.0)), at("pid", set(s = (q = 2.0,)))))
    run!(sim; t_end = 0.1)
    pr("u_raw over ticks from q = 2, limit 1", r.(logged_port(sim, "pid", :u_raw), 5))
    pr("β = 1 - exp(-1)", 1 - exp(-1))
end

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

sect("K7a-296/331/333/350 cascade in command") do
    c = fly_cl(() -> closed_loop(solution, gains))
    t = logged_times(c)
    lq = logged_face(c, "lqr_controller", :δe); sel = logged_face(c, "selection", :δe)
    d = abs.(lq .- sel)
    w = window(c, 5, 6); k = findall(w)[argmax(d[w])]
    pr("tracker gap peak over [5,6)", d[k], "at", t[k])
    after = findfirst(i -> t[i] > t[k] && d[i] < 0.1, eachindex(t))
    pr("first under 0.1 after peak", t[after], "ms after 5 s", 1000 * (t[after] - 5))
    pr("tracker gap [5.5,80)", gap(c, lq, sel, 5.5, 80), "[5,15)", gap(c, lq, sel, 5, 15), "[10,120)", gap(c, lq, sel, 10, 120))
    lqt = logged_face(c, "lqr_controller", :δt); selt = logged_face(c, "selection", :δt)
    pr("tracker δt gap [5,15)", gap(c, lqt, selt, 5, 15), "[5.5,15)", gap(c, lqt, selt, 5.5, 15))
    V = logged_port(c, "plant", :V)
    pr("cascade airspeed excursion", maximum(abs, V .- 50), "at", t[argmax(abs.(V .- 50))])
end

sect("K7a-296/297/341/350 tracker in command, standby cascade gaps by Tt") do
    for TT in (0.02, 0.005, 0.1)
        s = fly_cl(() -> closed_loop_Tt(solution, gains, TT); cascade = false)
        sel = logged_face(s, "selection", :δe); selt = logged_face(s, "selection", :δt)
        q_gap(a, b) = gap(s, logged_face(s, "pid_controller", :δe), sel, a, b)
        V_gap(a, b) = gap(s, logged_face(s, "pid_controller", :δt), selt, a, b)
        h_gap(a, b) = gap(s, logged_port(s, "pid_controller/h_ctl", :u), logged_port(s, "plant", :θ), a, b)
        θ_gap(a, b) = gap(s, logged_port(s, "pid_controller/θ_ctl", :u), logged_port(s, "plant", :q), a, b)
        pr("Tt=$TT [5,15) q, θ, h, V", r(q_gap(5, 15)), r(θ_gap(5, 15)), r(h_gap(5, 15)), r(V_gap(5, 15)))
        pr("Tt=$TT [15,60) q, θ, h, V", r(q_gap(15, 60)), r(θ_gap(15, 60)), r(h_gap(15, 60)), r(V_gap(15, 60)))
        if TT == 0.02
            t = logged_times(s)
            pe = logged_face(s, "pid_controller", :δe)
            k7 = findlast(<(7.0), t)
            pr("gap at last snapshot before 7 s", t[k7], pe[k7] - sel[k7], "max [6,7)", q_gap(6, 7), "max [5,7)", q_gap(5, 7))
            pr("selected δe slew max over [5,7) rad/s", maximum(abs, diff(sel[window(s, 5, 7)])) * 200)
            V = logged_port(s, "plant", :V)
            pr("tracker airspeed excursion", maximum(abs, V .- 50))
        end
    end
    hb = fly_cl(() -> closed_loop(solution, gains); cascade = false, switch_at = 7.0)
    sel = logged_face(hb, "selection", :δe)
    pr("hand-back at 7 s: command jump over [6.9,7.1)", largest_jump(sel, hb, 6.9, 7.1))
    act = logged_face(hb, "actuators", :δe)
    pr("hand-back at 7 s: actuator jump over [6.9,7.1)", largest_jump(act, hb, 6.9, 7.1))
end

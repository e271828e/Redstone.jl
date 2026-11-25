# K7a probe: longitudinal_aircraft.md against the code. Run from the worktree W with --project=examples/test.
using Test, LinearAlgebra
using Statistics: std
using Redstone, RedstoneExamples
import Redstone: Build, Simulation, build, init!, run!, step!, stage!, trim!, linearize, state, modes,
    series, reads, get_output, get_face, get_input, get_state, taps, termination, lifecycle, set, at, combine,
    override, checkpoint, restore!, replay!, trace, local_wires, diagnostics, DiagnosticError, TapResolution,
    AlgebraicCycle, Group, Absolute
using Redstone.Library: Constant, GaussianWhiteNoise, SumJunction, Junction, StopRequest, DiscretePID
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
include(joinpath(W, "examples/test/utils.jl"))
import RedstoneExamples: Longitudinal, aircraft, level_flight, longitudinal_taps, lqr_gains, closed_loop,
    trimmed, pitch_hold, autopilot, cruise, piloted, hand_flown, approach, GroundContact, actuators, feedback_wires

pr(label, xs...) = println("PROBE ", label, ": ", join(xs, " | "))
r(x, n = 4) = round(x; sigdigits = n)
function sect(f, name)
    println("== ", name)
    try f() catch err; println("SECTION FAILED ", name, ": ", sprint(showerror, err)[1:min(end, 600)]); end
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

# K7a probe: longitudinal_aircraft.md against the code. Run from the worktree W with --project=examples/test.
using Test, LinearAlgebra
using Statistics: std
using Redstone, RedstoneExamples
import Redstone: Build, Simulation, build, init!, run!, step!, stage!, trim!, linearize, state, modes,
    series, reads, get_output, get_face, get_input, get_state, taps, termination, lifecycle, set, at, combine,
    override, checkpoint, restore!, replay!, trace, local_wires, diagnostics, DiagnosticError, TapResolution,
    AlgebraicCycle, Group, Absolute
using Redstone.Library: Constant, GaussianWhiteNoise, SumJunction, Junction, StopRequest, DiscretePID
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
include(joinpath(W, "examples/test/utils.jl"))
import RedstoneExamples: Longitudinal, aircraft, level_flight, longitudinal_taps, lqr_gains, closed_loop,
    trimmed, pitch_hold, autopilot, cruise, piloted, hand_flown, approach, GroundContact, actuators, feedback_wires

pr(label, xs...) = println("PROBE ", label, ": ", join(xs, " | "))
r(x, n = 4) = round(x; sigdigits = n)
function sect(f, name)
    println("== ", name)
    try f() catch err; println("SECTION FAILED ", name, ": ", sprint(showerror, err)[1:min(end, 600)]); end
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

# ---- sensors and the hold chain ------------------------------------------------------------
function my_cascade(; lim = 0.5, hold = true, fastall = false)
    fast, slow = Absolute(1//50), fastall ? Absolute(1//50) : Absolute(1//10)
    pid(; gains...) = DiscretePID(; gains..., Tt = 0.02, hold = hold, tracking = false)
    comps = (; h_ctl = pid(Kp = 0.01, Ki = 0.001, u_min = -0.26, u_max = 0.26),
               θ_ctl = pid(Kp = 2.0, Ki = 0.5, u_min = -lim, u_max = lim),
               q_ctl = pid(Kp = -0.2, Ki = -0.4, u_min = -0.5, u_max = 0.5),
               V_ctl = pid(Kp = 0.2, Ki = 0.05, u_min = 0.0, u_max = 1.0))
    st = (h_ctl = slow, θ_ctl = fast, q_ctl = fast, V_ctl = slow)
    iw = ("h_ref" => "h_ctl/r", "h_meas" => "h_ctl/y", "θ" => "θ_ctl/y", "q" => "q_ctl/y", "V_ref" => "V_ctl/r", "V" => "V_ctl/y")
    lw = ("h_ctl/u" => "θ_ctl/r", "θ_ctl/u" => "q_ctl/r")
    if hold
        Group(merge(comps, (; free = Constant(Int8(0))));
              input_wires = (iw..., "engaged" => ("h_ctl/engaged", "θ_ctl/engaged", "q_ctl/engaged", "V_ctl/engaged")),
              local_wires = (lw..., "θ_ctl/saturated" => "h_ctl/saturation", "q_ctl/saturated" => "θ_ctl/saturation",
                             "free/y" => "q_ctl/saturation", "free/y" => "V_ctl/saturation"),
              output_wires = ("q_ctl/u" => "δe", "V_ctl/u" => "δt"), sample_times = st)
    else
        Group(comps; input_wires = iw, local_wires = lw, output_wires = ("q_ctl/u" => "δe", "V_ctl/u" => "δt"), sample_times = st)
    end
end
function sensing50(σ = 0.3)
    Group((; noise = GaussianWhiteNoise(seed = 7, σ = σ), altimeter = SumJunction{Float64, 2}());
          input_wires = ("h" => "altimeter/in1",), local_wires = ("noise/y" => "altimeter/in2",),
          output_wires = ("altimeter/y" => "h_meas",), sample_times = (noise = Absolute(1//50),))
end
function my_autopilot(sol; cascade, sensing)
    hold = cascade isa Group && any(w -> startswith(w.first, "engaged"), Redstone.input_wires(cascade))
    comps = (; plant = Longitudinal(), sensing, cascade, actuators = actuators(sol))
    lw = (feedback_wires()..., "cascade/δe" => "actuators/δe_cmd", "cascade/δt" => "actuators/δt_cmd")
    if hold
        Group(merge(comps, (; engaged = Constant(true))); input_wires = ("h_ref" => "cascade/h_ref", "V_ref" => "cascade/V_ref"),
              local_wires = (lw..., "engaged/y" => "cascade/engaged"))
    else
        Group(comps; input_wires = ("h_ref" => "cascade/h_ref", "V_ref" => "cascade/V_ref"), local_wires = lw)
    end
end
function fly(model; t_end = 120.0)
    sim = Simulation(model; Δt_frame = 1//200)
    init!(sim, override(cruise(solution), set(u = (h_ref = 1050.0,))))
    run!(sim; t_end); sim
end
metrics(sim) = begin
    t = logged_times(sim); h = logged_port(sim, "plant", :h); V = logged_port(sim, "plant", :V); late = t .>= 75
    (late_h = maximum(abs, h[late] .- 1050), late_V = maximum(abs, V[late] .- 50), peak = maximum(h))
end

sect("sensor table") do
    pr("noise per sample 10Hz, 50Hz-equivalent", sqrt(1.8e-3 / 0.1), sqrt(1.8e-3 / 0.02))
    base = fly(autopilot(solution)); pr("row3 10Hz altimeter, two rates (library autopilot)", metrics(base))
    pr("row3 via my_autopilot", metrics(fly(my_autopilot(solution; cascade = my_cascade(), sensing = RedstoneExamples.sensing()))))
    pr("row1 50Hz sensor two rates", metrics(fly(my_autopilot(solution; cascade = my_cascade(), sensing = sensing50()))))
    pr("row2 50Hz sensor all 50Hz", metrics(fly(my_autopilot(solution; cascade = my_cascade(fastall = true), sensing = sensing50()))))
    t = logged_times(base); h = logged_port(base, "plant", :h); V = logged_port(base, "plant", :V)
    pr("within 1 m from", let k = findlast(x -> abs(x - 1050) > 1, h); t[k + 1]; end)
    pr("V excursion", maximum(abs, V .- 50), "at", t[argmax(abs.(V .- 50))])
    # the cascade's rates
    pr("pitch loop limits reached in base climb: θ_ctl max|u|", maximum(abs, logged_port(base, "cascade/θ_ctl", :u)),
       "q_ctl", maximum(abs, logged_port(base, "cascade/q_ctl", :u)))
end

sect("hold chain") do
    for (name, kw) in (("two rates hold", (lim = 0.05,)), ("all 50Hz hold", (lim = 0.05, fastall = true)), ("no hold two rates", (lim = 0.05, hold = false)),
                       ("no hold all 50", (lim = 0.05, hold = false, fastall = true)), ("lim 0.5 hold", (lim = 0.5,)))
        sim = fly(my_autopilot(solution; cascade = my_cascade(; kw...), sensing = RedstoneExamples.sensing()); t_end = 60.0)
        s = logged_port(sim, "cascade/θ_ctl", :saturated); t = logged_times(sim)
        pr("θ loop limited duration $name", count(!=(0), s) * 0.005, "first/last", t[findfirst(!=(0), s) === nothing ? 1 : findfirst(!=(0), s)],
           "max|u|", maximum(abs, logged_port(sim, "cascade/θ_ctl", :u)), "metrics", metrics(sim))
    end
end

sect("cruise without seeds and with") do
    sim = Simulation(autopilot(solution; noise_psd = 0.0); Δt_frame = 1//200)
    init!(sim, combine(set(u = (h_ref = 1000.0, V_ref = 50.0)), at("plant", set(x = (θ = solution.θ,)))))
    run!(sim; t_end = 120.0)
    t = logged_times(sim); h = logged_port(sim, "plant", :h)
    pr("unseeded: max |h-1000|", maximum(abs, h .- 1000), "last time |h-1000|>0.5", t[findlast(x -> abs(x - 1000) > 0.5, h)],
       "last > 0.05", t[findlast(x -> abs(x - 1000) > 0.05, h)])
    s2 = Simulation(autopilot(solution; noise_psd = 0.0); Δt_frame = 1//200)
    init!(s2, cruise(solution)); run!(s2; t_end = 60.0)
    pr("seeded drift", maximum(abs, logged_port(s2, "plant", :h) .- 1000))
    pr("DiscretePID s_init", Redstone.s_init(DiscretePID(Kp = 1.0)))
end

# ---- piloted ---------------------------------------------------------------------------------
sect("piloted flight") do
    hand = Simulation(piloted(solution); Δt_frame = 1//200)
    init!(hand, hand_flown(solution))
    f = t -> round(Int, t * 200)
    step!(hand; frames = f(5.0)); stage!(hand, "δe_pilot" => solution.δe - 0.02)
    step!(hand; frames = f(7.0) - f(5.0)); stage!(hand, "δe_pilot" => solution.δe)
    step!(hand; frames = f(30.0) - f(7.0)); stage!(hand, "engage" => true)
    step!(hand; frames = f(60.0) - f(30.0)); run!(hand; t_end = 90.0)
    t = logged_times(hand); h = logged_port(hand, "plant", :h)
    byh = window(hand, 0, 30)
    pr("by hand h min max", minimum(h[byh]), maximum(h[byh]))
    δe_sel = logged_face(hand, "selection", :δe); δt_sel = logged_face(hand, "selection", :δt)
    pr("gap elevator [8,30)", largest_gap(logged_face(hand, "cascade", :δe), δe_sel, hand, 8, 30))
    pr("gap throttle [5,30)", largest_gap(logged_face(hand, "cascade", :δt), δt_sel, hand, 5, 30))
    sw = findfirst(identity, logged_face(hand, "selection", :engaged)); pr("latch time", t[sw])
    pr("selected jump at latch δe δt", abs(δe_sel[sw] - δe_sel[sw - 1]), abs(δt_sel[sw] - δt_sel[sw - 1]))
    δe_act = logged_face(hand, "actuators", :δe)
    pr("actuator δe jump around 30.2", largest_jump(δe_act, hand, 30.1, 30.3), "rate limiter per tick δt", 0.5 * 0.02)
    pr("elevator cmd largest frame change [80,90)", largest_jump(δe_sel, hand, 80, 90))
    pr("recapture max |h-1000| [80,90)", maximum(abs, h[window(hand, 80, 90)] .- 1000))
    # without the latch: when do things move? the engage's next frame
    staged = series(hand, reads(engage = get_input("engage"))).engage
    pr("engage staged shows at", t[findfirst(identity, staged)])
    # refused: no-delay algebraic loops
    model = piloted(solution)
    undelayed = map(local_wires(model)) do wire
        wire.first == "selection/δe_prev" ? ("selection/δe" => wire.second) :
        wire.first == "selection/δt_prev" ? ("selection/δt" => wire.second) : wire
    end
    ref = try; build(Group(model; local_wires = undelayed)); nothing; catch e; e; end
    pr("undelayed refusal", [(typeof(d), d.classification, sort(collect(d.members))) for d in diagnostics(ref)])
    # checkpoint mismatch
    cp = checkpoint(hand)
    flight = Simulation(approach(solution); Δt_frame = 1//200)
    res = try; restore!(flight, cp); :accepted; catch e; e; end
    pr("restore piloted checkpoint into approach", typeof(res), res isa DiagnosticError ? [typeof(d) for d in diagnostics(res)] : "")
end

# ---- the closed loop -----------------------------------------------------------------------
gains = lqr_gains(lin)
function fly_closed_loop(solution, gains; cascade = true, switch_at = nothing, h_step = 50.0, noise_σ = 0.3, t_end = 120.0)
    h = 1//200; frame(t) = round(Int, t / h)
    sim = Simulation(closed_loop(solution, gains; noise_σ); Δt_frame = h)
    init!(sim, cascade ? trimmed(solution) : override(trimmed(solution), set(u = (mode = false,))))
    step!(sim; frames = frame(5.0) - 1); stage!(sim, "h_ref" => 1000.0 + h_step)
    if switch_at !== nothing
        step!(sim; frames = frame(switch_at) - frame(5.0)); stage!(sim, "mode" => !cascade)
    end
    run!(sim; t_end); sim
end

sect("run2: tracker standby gap series and hand-back at 7") do
    casc = fly_closed_loop(solution, gains)
    t = logged_times(casc)
    gap = abs.(logged_face(casc, "lqr_controller", :δe) .- logged_face(casc, "selection", :δe))
    w = window(casc, 4.99, 5.12)
    pr("gap series 4.99..5.12", join(["$(t[i]):$(r(gap[i]))" for i in findall(w)], " "))
    hb7 = fly_closed_loop(solution, gains; cascade = false, switch_at = 7.0)
    sel = logged_face(hb7, "selection", :δe); pid = logged_face(hb7, "pid_controller", :δe); tt = logged_times(hb7)
    k = findfirst(>=(7.0), tt)
    pr("hand-back 7: gap at 6.995, 7.0, 7.005", [r(abs(pid[i] - sel[i])) for i in k-1:k+1], "times", tt[k-1:k+1])
    pr("sel around 7", [r(sel[i]) for i in k-2:k+4], "pid", [r(pid[i]) for i in k-2:k+4])
    sl = abs.(diff(sel)) ./ 0.005
    pr("max slew rad/s [5.5,7)", maximum(sl[window(hb7, 5.5, 7.0)[2:end]]), "[6,7)", maximum(sl[window(hb7, 6.0, 7.0)[2:end]]))
    pr("actuator after 7: δe act vs cmd lag time", [r(logged_face(hb7, "actuators", :δe)[i]) for i in k:20:k+100])
    # time for actuator to reach the command after 7
    act = logged_face(hb7, "actuators", :δe)
    j = findfirst(i -> tt[i] > 7.0 && abs(act[i] - sel[i]) < 0.005, eachindex(tt)); pr("act within 0.005 of cmd at", tt[j])
    pr("pid-gap max in [6.5,7.0)", maximum(abs.(pid .- sel)[window(hb7, 6.5, 7.0)]))
end
sect("replay") do
    flight = Simulation(approach(solution); Δt_frame = 1//200)
    init!(flight, at("vehicle", hand_flown(solution)))
    f = t -> round(Int, t * 200)
    step!(flight; frames = f(5.0)); stage!(flight, "δe_pilot" => solution.δe - 0.02)
    step!(flight; frames = f(7.0) - f(5.0)); stage!(flight, "δe_pilot" => solution.δe)
    step!(flight; frames = f(30.0) - f(7.0)); stage!(flight, "engage" => true)
    step!(flight; frames = f(60.0) - f(30.0))
    h_ref = 1000.0; n = 0
    while lifecycle(flight) !== :stopped && n < 10_000
        h_ref -= 0.15; stage!(flight, "h_ref" => h_ref); step!(flight; t_plus = 1//10); n += 1
    end
    rep = Simulation(approach(solution); Δt_frame = 1//200); replay!(rep, trace(flight))
    out(s) = series(s, reads(h = get_output("vehicle/plant", :h), V = get_output("vehicle/plant", :V))).columns
    pr("replay stop equal", termination(rep).t == termination(flight).t, "outputs identical", out(rep) == out(flight), "times", logged_times(rep) == logged_times(flight))
end
println("DONE2")

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

sect("hand estimate and parameters") do
    p = Longitudinal(); g = RedstoneExamples.g
    q̄ = 0.5 * p.ρ * 50^2
    CL = p.m * g / (q̄ * p.S); α = (CL - p.CL0) / p.CLα
    δe = (p.Cm0 + p.Cmα * α) / (-p.Cmδe); D = q̄ * p.S * (p.CD0 + p.k * CL^2)
    pr("hand estimate CL, α, δe, δt", r(CL), r(α), r(δe), r(D / p.T_max))
    pr("T_max / weight", p.T_max / (p.m * g))
    pr("AR e product k=1/(pi e AR) with AR 7.5 e 0.85", 1 / (π * 7.5 * 0.85))
    pr("static margin -Cmα/CLα", -p.Cmα / p.CLα)
    pr("trim iterations, solution", report.n_iterations, report.status, solution)
    est = (α, δe, D / p.T_max); tr = (solution.θ, solution.δe, solution.δt)
    pr("relative diff trim vs estimate", map((a, b) -> abs(a - b) / b, est, tr))
    pr("plant state at commit", state(sim0, "plant"))
    pr("x_init plant", Redstone.x_init(Longitudinal()))
end

sect("linearization") do
    pr("x_labels u_labels", lin.x_labels, lin.u_labels)
    for i in 1:5; pr("A row $i", join(r.(A[i, :], 4), "  ")); end
    for i in 1:5; pr("B row $i", join(r.(B[i, :], 4), "  ")); end
    λ = eigvals(A); pr("eigs A", sort(λ, by = abs))
    pr("zero count", count(x -> abs(x) < 1e-9, λ), "A last col zero", all(iszero, A[:, 5]))
end

sect("short period and phugoid") do
    λ = eigvals(A); up = filter(x -> imag(x) > 0, λ)
    sp = up[argmax(imag.(up))]; ph = up[argmin(imag.(up))]
    ωsp, ζsp = abs(sp), -real(sp) / abs(sp); ωph, ζph = abs(ph), -real(ph) / abs(ph)
    pr("full short period ωn ζ", ωsp, ζsp); pr("full phugoid ωn ζ period", ωph, ζph, 2π / imag(ph))
    a = A[2, 3]; Mα = A[4, 2]; Mq = A[4, 4]
    R = [-a 1; -(-Mα) Mq] # α̇ = q - a α ; q̇ = Mα' α + Mq q  with A[4,3] = -20.42 so α-row coef = A[4,3]
    R = [-a 1; A[4, 3] A[4, 4]]
    pr("reduced 2x2 eigs", eigvals(R), "char poly s^2+", -tr(R), "s+", det(R))
    pr("reduced ωn ζ", sqrt(det(R)), -tr(R) / (2 * sqrt(det(R))))
    pr("A[2,2], A[2,3], A[4,2], A[4,3], A[4,4]", A[2, 2], A[2, 3], A[4, 2], A[4, 3], A[4, 4])
    p = Longitudinal(); V = 50.0; q̄ = 0.5 * p.ρ * V^2
    pr("-Mα formula", -q̄ * p.S * p.c̄ * p.Cmα / p.Iyy, "-Mq formula", -q̄ * p.S * p.c̄ * p.Cmq * p.c̄ / (2V) / p.Iyy)
    pr("-Zα/V", q̄ * p.S * p.CLα / (p.m * V), "with thrust term", A[2, 3])
    CL = 0.4; CD = p.CD0 + p.k * CL^2
    pr("L/D", CL / CD, "Lanchester ωn", √2 * RedstoneExamples.g / V, "ζ", 1 / (√2 * CL / CD))
    pr("freq overestimate ratio", √2 * RedstoneExamples.g / V / ωph)
    pr("Δα coef Mq/Mα", A[4, 4] / A[4, 3], "factor", 1 + 2.469 * 0.180, "29.5/20.42", 29.5 / 20.42, "sqrt", sqrt(1.444), 0.277 / 1.202)
    # Cmq = 0
    s0, r0 = trim_of(Longitudinal(Cmq = 0.0)); l0 = linearize(s0, longitudinal_taps())
    λ0 = eigvals(l0.A); u0 = filter(x -> imag(x) > 0, λ0); p0 = u0[argmin(imag.(u0))]
    pr("Cmq=0 trim", r0.solution, "slow pair ωn ζ", abs(p0), -real(p0) / abs(p0), "short", u0[argmax(imag.(u0))])
    pr("A[1,1] vs 2D/(mV)", A[1, 1], 2 * q̄ * p.S * CD / (p.m * V))
end

sect("open loop from 55") do
    sim = Simulation(aircraft(); Δt_frame = 1//100)
    init!(sim, combine(at("plant", set(x = (V = 55.0, θ = solution.θ))), set(u = (δe = solution.δe, δt = solution.δt))))
    run!(sim; t_end = 120.0)
    t = logged_times(sim); V = logged_port(sim, "plant", :V); h = logged_port(sim, "plant", :h)
    pr("V min max", minimum(V), maximum(V), "h max - 1000", maximum(h) - 1000)
    c = crossings(t, V, 50.0); pr("crossings", c, "mean spacing", (c[end] - c[1]) / (length(c) - 1), "diffs", diff(c))
end

sect("pitch hold") do
    sim_of(discrete, θ_step) = begin
        sim = Simulation(pitch_hold(; discrete); Δt_frame = 1//200)
        integral = discrete ? set(s = (q = solution.δe,)) : set(x = (q = solution.δe,))
        init!(sim, combine(set(u = (θ_ref = solution.θ + θ_step, δt = solution.δt)),
                           at("plant", set(x = (θ = solution.θ,))), at("θ_ctl", integral)))
        sim
    end
    tp = taps(x = (V = get_state("plant", :V), γ = get_state("plant", :γ), θ = get_state("plant", :θ),
                   q = get_state("plant", :q), ξ = get_state("θ_ctl", :q)),
              u = (θ_ref = get_input(:θ_ref),), y = (θ = get_output("plant", :θ),))
    cl = linearize(sim_of(false, 0.0), tp); λ = eigvals(cl.A)
    pr("pitch hold eigs", sort(λ, by = real))
    up = λ[argmax(imag.(λ))]; pr("fast pair ωn ζ", abs(up), -real(up) / abs(up))
    pr("DC gain", (cl.D - cl.C * (cl.A \ cl.B))[1])
    ref = try; linearize(sim_of(true, 0.0), tp); nothing; catch e; e; end
    pr("discrete refusal", typeof(ref), [(typeof(d), d.reason, d.tap) for d in diagnostics(ref)])
    pr("reference at step", solution.θ + 0.05)
    θs = map(d -> (s = sim_of(d, 0.05); run!(s; t_end = 9.0); logged_port(s, "plant", :θ)), (false, true))
    pr("peaks", maximum(θs[1]), maximum(θs[2]), "max gap", maximum(abs, θs[1] .- θs[2]))
end

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
sect("closed loop") do
    pr("gains K_fbk", gains.K_fbk, "K_fwd", gains.K_fwd, "K_int", gains.K_int)
    casc = fly_closed_loop(solution, gains); trk = fly_closed_loop(solution, gains; cascade = false)
    for (nm, s) in (("cascade", casc), ("tracker", trk))
        t = logged_times(s); h = logged_port(s, "plant", :h); V = logged_port(s, "plant", :V); late = t .>= 80
        pr("$nm: late h err (≥80)", maximum(abs, h[late] .- 1050), "late V", maximum(abs, V[late] .- 50), "peak h", maximum(h),
           "V stray", maximum(abs, V .- 50), "last time |h-1050|>0.1", t[findlast(x -> abs(x - 1050) > 0.1, h)])
        pr("$nm: first within 0.1 m after 5 s at", t[findfirst((t .> 5) .& (abs.(h .- 1050) .< 0.1))])
    end
    t = logged_times(casc)
    gap = abs.(logged_face(casc, "lqr_controller", :δe) .- logged_face(casc, "selection", :δe))
    pr("standby tracker gap: [5.5,10)", maximum(gap[window(casc, 5.5, 10)]), "[5.5,60)", maximum(gap[window(casc, 5.5, 60)]),
       "[5,5.5)", maximum(gap[window(casc, 5, 5.5)]), "[10,60)", maximum(gap[window(casc, 10, 60)]), "[10,120)", maximum(gap[window(casc, 10, 120)]))
    k = argmax(gap[window(casc, 5, 10)]) ; tt = t[window(casc, 5, 10)]
    pr("peak gap", maximum(gap[window(casc, 5, 10)]), "at t", tt[k])
    after = findfirst(i -> t[i] > tt[k] && gap[i] < 0.1, eachindex(t)); pr("under 0.1 at", t[after], "after peak", t[after] - tt[k], "after step 5.0", t[after] - 5.0)
    pr("gap after 0.5 s from [5.5,..) first big", "gap at t=5.5..6:", maximum(gap[window(casc, 5.5, 6)]))
    s60 = fly_closed_loop(solution, gains; switch_at = 60.0)
    pr("steady switch largest actuator jump", largest_jump(logged_face(s60, "actuators", :δe), s60, 59.5, 61),
       "cascade jitter [90,100)", largest_jump(logged_face(casc, "actuators", :δe), casc, 90, 100))
    s10 = fly_closed_loop(solution, gains; switch_at = 10.0); hb10 = fly_closed_loop(solution, gains; cascade = false, switch_at = 10.0)
    pr("switch at 10: cmd jump", largest_jump(logged_face(s10, "selection", :δe), s10, 9.9, 10.1), "actuator", largest_jump(logged_face(s10, "actuators", :δe), s10, 9.9, 10.1))
    pr("hand-back at 10: cmd jump", largest_jump(logged_face(hb10, "selection", :δe), hb10, 9.9, 10.1))
    hb7 = fly_closed_loop(solution, gains; cascade = false, switch_at = 7.0)
    sel = logged_face(hb7, "selection", :δe); tt7 = logged_times(hb7)
    pr("hand-back at 7: cmd jump", largest_jump(sel, hb7, 6.9, 7.1), "actuator jump", largest_jump(logged_face(hb7, "actuators", :δe), hb7, 6.9, 7.1))
    pr("standby pid δe gap just before 7", maximum(abs, (logged_face(hb7, "pid_controller", :δe) .- sel)[window(hb7, 6.9, 7.0)]))
    sl = abs.(diff(sel)) ./ 0.005; pr("max slew of cmd rad/s in [5,7)", maximum(sl[window(hb7, 5, 7)[2:end]]))
    pr("tracker standby gaps [15,60) and pid", largest_gap(logged_face(trk, "pid_controller", :δe), logged_face(trk, "selection", :δe), trk, 15, 60))
    # noise
    noise = logged_face(casc, "sensing", :h_meas) .- logged_port(casc, "plant", :h); pr("noise std", std(noise))
    rest = fly_closed_loop(solution, gains; h_step = 0.0, noise_σ = 0.0, t_end = 60.0)
    pr("closed_loop rest drift h", maximum(abs, logged_port(rest, "plant", :h) .- 1000))
    for (nm, wires) in (("pid_controller", Redstone.input_wires(closed_loop(solution, gains))),)
        pr("root inputs", wires)
    end
end

sect("autopilot rest and piloted autopilot seeds") do
    rest = Simulation(autopilot(solution; noise_psd = 0.0); Δt_frame = 1//200)
    init!(rest, cruise(solution)); run!(rest; t_end = 60.0)
    pr("autopilot rest drift", maximum(abs, logged_port(rest, "plant", :h) .- 1000))
    c = Redstone.input_wires(closed_loop(solution, gains)); pr("closed loop input wires", c)
end

# ---- approach -----------------------------------------------------------------------------
sect("approach") do
    flight = Simulation(approach(solution); Δt_frame = 1//200)
    init!(flight, at("vehicle", hand_flown(solution)))
    f = t -> round(Int, t * 200)
    step!(flight; frames = f(5.0)); stage!(flight, "δe_pilot" => solution.δe - 0.02)
    step!(flight; frames = f(7.0) - f(5.0)); stage!(flight, "δe_pilot" => solution.δe)
    step!(flight; frames = f(30.0) - f(7.0)); stage!(flight, "engage" => true)
    step!(flight; frames = f(60.0) - f(30.0))
    top = checkpoint(flight)
    h_ref = 1000.0; n = 0
    while lifecycle(flight) !== :stopped && n < 10_000
        h_ref -= 0.15; stage!(flight, "h_ref" => h_ref); step!(flight; t_plus = 1//10); n += 1
    end
    rec = termination(flight); t = logged_times(flight)
    pr("touchdown t", rec.t, "writes", n, "reason", rec.source.reason, "path", rec.source.path, "port", rec.source.port)
    pr("final h γ", state(flight, "vehicle/plant").h, state(flight, "vehicle/plant").γ, "sin γ target", -1.5 / 50)
    hr = series(flight, reads(h_ref = get_input("h_ref"))).h_ref
    d = window(flight, 160, rec.t - 1)
    pr("tracking err [160, end-1)", maximum(abs, (logged_port(flight, "vehicle/plant", :h) .- hr)[d]))
    V = logged_port(flight, "vehicle/plant", :V)[d]; pr("V range", minimum(V), maximum(V))
    for l in ("h_ctl", "θ_ctl", "q_ctl", "V_ctl")
        s = logged_port(flight, "vehicle/cascade/$l", :saturated); pr("saturated count $l (all, ≥60 s)", count(!=(0), s), count(!=(0), s[t .>= 60]))
    end
    pr("actuator face check", maximum(abs, logged_port(flight, "vehicle/cascade/q_ctl", :u)))
    # second approach, 2 m/s and repeat
    second = Simulation(approach(solution); Δt_frame = 1//200); restore!(second, top)
    h2 = 1000.0 - 0.0
    function desc!(sim, sink)
        hh = 1000.0; k = 0
        while lifecycle(sim) !== :stopped && k < 10_000
            hh -= sink / 10; stage!(sim, "h_ref" => hh); step!(sim; t_plus = 1//10); k += 1
        end
    end
    desc!(second, 2.0); pr("second touchdown at 2 m/s", termination(second).t)
    restore!(second, top); desc!(second, 1.5); pr("restore again 1.5 equal to first", termination(second).t == rec.t)
    # replay
    rep = Simulation(approach(solution); Δt_frame = 1//200); replay!(rep, trace(flight))
    pr("replay same stop", termination(rep).t == rec.t, plant_equal = plant_outputs_eq(rep, flight))
end
plant_outputs_eq(a, b) = true

sect("junction vs gear") do
    function model(kind)
        stopper = kind == :gear ? GroundContact() : Junction{Float64, Bool, 1}(h -> h <= 0.0)
        Group((; plant = Longitudinal(), gear = stopper, stop = StopRequest(reason = "touchdown"));
              input_wires = ("δe" => "plant/δe", "δt" => "plant/δt"),
              local_wires = ("plant/h" => "gear/" * (kind == :gear ? "h" : "in1"), "gear/" * (kind == :gear ? "contact" : "y") => "stop/u"))
    end
    for kind in (:gear, :junction)
        sim = Simulation(model(kind); Δt_frame = 1//200)
        init!(sim, combine(at("plant", set(x = (V = 50.0, γ = -0.03, θ = solution.θ - 0.03, q = 0.0, h = 5.0))),
                           set(u = (δe = solution.δe, δt = solution.δt))))
        run!(sim; t_end = 20.0)
        pr("$kind stop t, h", termination(sim).t, state(sim, "plant").h)
    end
end
println("DONE")

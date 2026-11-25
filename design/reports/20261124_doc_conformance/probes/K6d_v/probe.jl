using Test, StaticArrays, LinearAlgebra, ForwardDiff
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/"
include(W * "imports.jl"); include(W * "fixtures.jl"); include(W * "utils.jl")
const L = Redstone.Library
P(tag, x) = println("PROBE[", tag, "] ", x)
dlist(e) = e.carried isa Vector ? e.carried : [e.carried]
safe(tag, f) = try f() catch e; P(tag * "_ERR", sprint(showerror, e)[1:min(end, 600)]) end

# ---- fixtures copied from test/test_library.jl at W (660-790) ----
function standby_siblings(controller_a, controller_b, plant; delay, extra = (;), extra_wires = String[] .=> String[], mode_to = ())
    holding = haskey(u_types(controller_a), :engaged)
    command = delay ? "delay/y" : "sel/y"
    wires = Pair{String, String}[
        "ref_a/y" => "a/r", "ref_b/y" => "b/r", "plant/y" => "a/y", "plant/y" => "b/y",
        "a/u" => "sel/in1", "b/u" => "sel/in2", "sel/y" => "plant/u"]
    delay && push!(wires, "sel/y" => "delay/u")
    haskey(u_types(controller_a), :v) && append!(wires, [command => "a/v", command => "b/v"])
    holding && append!(wires, ["negate/y" => "b/engaged", "free/y" => "a/saturation", "free/y" => "b/saturation"])
    append!(wires, extra_wires)
    kids = (ref_a = Step(t_step = 0.5, after = 5.0), ref_b = Constant(2.0), a = controller_a, b = controller_b,
              sel = Switch{Float64}(), plant = plant)
    Group(merge(kids, holding ? (negate = Fn{Bool}(!), free = Constant(Int8(0))) : (;),
                delay ? (delay = UnitDelay(0.0),) : (;), extra);
          input_wires = ("mode" => ((holding ? ("sel/select", "a/engaged", "negate/u") : ("sel/select",))..., mode_to...),),
          local_wires = Tuple(wires))
end
function switchover_bump(model)
    sim = Simulation(model; Δt_frame = 1//100)
    init!(sim, set(u = (mode = false,)))
    step!(sim; frames = 200)
    before = port(sim, "sel")
    poke!(sim, "mode", true)
    step!(sim; frames = 1)
    abs(port(sim, "sel") - before)
end
tracker_plant() = StateSpace(A = [0 1; -2 -3], B = [1 0; 0 1], C = [1 0; 0 1])
tracker_gains() = (K_fbk = [1.0 0; 0 1], K_fwd = [1.0 -1; 2 4], K_int = [0.5 0; 0 0.25], x_trim = [0.1, -0.2],
                   u_trim = [0.3, 0.4], z_trim = [0.5, 0.6], Tt = 1.0, u_min = -1.0, u_max = 1.0)
function tracker_loop_gains()
    (; K_fbk, K_fwd, K_int, Tt) = tracker_gains()
    (; K_fbk, K_fwd, K_int, Tt)
end
function tracker_loop(controller; disturbance = SVector(0.0, 0.0), stepped = true)
    wires = Pair{String, String}[
        "plant/y" => "controller/x", "plant/y" => "controller/z", "controller/u" => "sum/in1",
        "disturbance/y" => "sum/in2", "sum/y" => "plant/u"]
    stepped && push!(wires, "reference/y" => "controller/z_ref")
    kids = (controller = controller, disturbance = Constant(disturbance),
              sum = SumJunction{SVector{2, Float64}, 2}(), plant = tracker_plant())
    Group(merge(kids, stepped ? (reference = Step(t_step = 0.5, before = SVector(0.0, 0.0), after = SVector(1.0, 0.5)),) : (;));
          input_wires = stepped ? () : ("z_ref" => "controller/z_ref",), local_wires = Tuple(wires))
end
function run_frames(model, n; inputs = (;))
    sim = Simulation(model; Δt_frame = 1//100); init!(sim, set(u = inputs)); step!(sim; frames = n); sim
end

gains = (Kp = 1.0, Ki = 0.5, Kd = 0.2, τd = 0.1)

# ===== K6d-107: the sibling cycle, emulation shape (tracking, no hold) =====
for (tier, ctrl, plant) in (("discrete", DiscretePID(; gains..., Tt = 1.0, tracking = true), DiscreteIntegrator()),
                            ("continuous", PID(; gains..., Tt = 1.0, tracking = true), Integrator()))
    e = failure(() -> build(standby_siblings(ctrl, ctrl, plant; delay = false)))
    P("107_" * tier, e === nothing ? "builds" : [(typeof(d), getproperty(d, :classification), d.wires) for d in dlist(e) if d isa AlgebraicCycle])
    P("107_" * tier * "_delay", build(standby_siblings(ctrl, ctrl, plant; delay = true)) isa Build)
end

# ===== K6d-116..119: switchover bumps =====
P("116_plain", switchover_bump(standby_siblings(DiscretePID(; gains..., Tt = 0.1), DiscretePID(; gains..., Tt = 0.1), DiscreteIntegrator(); delay = true)))
trk1 = DiscretePID(; gains..., Tt = 1.0, tracking = true)
P("117_track_Tt1", switchover_bump(standby_siblings(trk1, trk1, DiscreteIntegrator(); delay = true)))
# emulation: Ki = AsPort() fed zero while not in command
function emulation(Tt)
    c = DiscretePID(Kp = 1.0, Ki = AsPort(), Kd = 0.2, τd = 0.1, Tt = Tt, tracking = true)
    standby_siblings(c, c, DiscreteIntegrator(); delay = true,
        extra = (kia = Junction{Bool, Float64, 1}(m -> m ? 0.5 : 0.0), kib = Junction{Bool, Float64, 1}(m -> m ? 0.0 : 0.5)),
        extra_wires = ["kia/y" => "a/Ki", "kib/y" => "b/Ki"], mode_to = ("kia/in1", "kib/in1"))
end
for Tt in (1.0, 0.1, 0.0)
    safe("118_119_emul_Tt$Tt", () -> P("118_119_emul_Tt$Tt", switchover_bump(emulation(Tt))))
end
# the shipped hold+tracking at W, for comparison
for Tt in (1.0, 0.1, 0.0)
    c = DiscretePID(; gains..., Tt = Tt, hold = true, tracking = true)
    P("hold_track_Tt$Tt", switchover_bump(standby_siblings(c, c, DiscreteIntegrator(); delay = true)))
end

# ===== K6d-121: standby u_raw = v + Tt Ki e, tracking always Tt = 1 =====
let sim = Simulation(standby_siblings(trk1, trk1, DiscreteIntegrator(); delay = true); Δt_frame = 1//100)
    init!(sim, set(u = (mode = false,))); step!(sim; frames = 200)
    v = port(sim, "delay"); uraw = port(sim, "a", :u_raw); ea = port(sim, "ref_a") - port(sim, "plant")
    P("121", (; v, uraw, uraw_minus_v = uraw - v, Tt_Ki_e = 1.0 * 0.5 * ea, sel = port(sim, "sel")))
end

# ===== K6d-115: engaged sibling tracking its own one-tick-old output vs plain, over 4 s =====
for Tt in (1.0, 0.1)
    c = DiscretePID(; gains..., Tt = Tt, tracking = true); pl = DiscretePID(; gains..., Tt = Tt)
    ys = map((c, pl)) do ctrl
        sim = Simulation(standby_siblings(ctrl, ctrl, DiscreteIntegrator(); delay = true); Δt_frame = 1//100)
        init!(sim, set(u = (mode = true,)))
        [(step!(sim; frames = 1); port(sim, "plant")) for _ in 1:400]
    end
    P("115_Tt$Tt", (maxdiff = maximum(abs.(ys[1] .- ys[2])), peak_track = maximum(ys[1]), peak_plain = maximum(ys[2])))
end
# emulation shape for 115 (Ki port, a in command)
for Tt in (1.0, 0.1)
    pl = DiscretePID(; gains..., Tt = Tt)
    y_e = let sim = Simulation(emulation(Tt); Δt_frame = 1//100)
        init!(sim, set(u = (mode = true,))); [(step!(sim; frames = 1); port(sim, "plant")) for _ in 1:400] end
    y_p = let sim = Simulation(standby_siblings(pl, pl, DiscreteIntegrator(); delay = true); Δt_frame = 1//100)
        init!(sim, set(u = (mode = true,))); [(step!(sim; frames = 1); port(sim, "plant")) for _ in 1:400] end
    P("115_emul_Tt$Tt", (maxdiff = maximum(abs.(y_e .- y_p)), peak = maximum(y_p)))
end

# ===== K6d-122: Tt = 0 on the discrete tier in standby =====
let c = DiscretePID(; gains..., Tt = 0.0, hold = true, tracking = true)
    sim = Simulation(standby_siblings(c, c, DiscreteIntegrator(); delay = true); Δt_frame = 1//100)
    init!(sim, set(u = (mode = false,)))
    errs = [(step!(sim; frames = 1); port(sim, "a", :u_raw) - port(sim, "delay")) for _ in 1:200]
    P("122_Tt0_standby_err", (max = maximum(abs.(errs[2:end])), last = errs[end], at50 = errs[50], at51 = errs[51], at52 = errs[52]))
end
let c = DiscretePID(; gains..., Tt = 0.1, hold = true, tracking = true)
    sim = Simulation(standby_siblings(c, c, DiscreteIntegrator(); delay = true); Δt_frame = 1//100)
    init!(sim, set(u = (mode = false,)))
    errs = [(step!(sim; frames = 1); port(sim, "a", :u_raw) - port(sim, "delay")) for _ in 1:200]
    P("122_Tt01_standby_err", (max = maximum(abs.(errs[2:end])), last = errs[end]))
end

# ===== LQR tracker unit probes (045, 051, 055, 064, 084, 093) =====
tg = tracker_gains()
for (hold, tracking) in ((true, true), (false, true), (true, false))
    c = LQRTracker(; tg..., Tt = 2.0, hold, tracking)
    p = L.parameters(c, (;))
    x = SVector(0.0, 0.0); zr = SVector(1.0, 1.0); z = SVector(0.0, 0.0)
    base = (; x, z, z_ref = zr)
    u = merge(base, hold ? (saturation = SVector{2, Int8}(1, 0), engaged = SVector(true, true)) : (;),
              tracking ? (v = SVector(10.0, 20.0),) : (;))
    y = L.y_direct(c, (; x = SVector(0.0, 0.0), u))
    d = L.x_deriv(c, (; x = SVector(0.0, 0.0), u, y))
    e = p.K_int * (zr - z)
    P("045_051_hold$(hold)_track$(tracking)", (; u_raw = y.u_raw, u = y.u, e, deriv = d,
        deriv_minus_e = d - e))
    if hold
        u2 = merge(u, (engaged = SVector(false, true),))
        d2 = L.x_deriv(c, (; x = SVector(0.0, 0.0), u = u2, y))
        P("045_051_notengaged_ch1_hold$(hold)_track$(tracking)", d2)
    end
end
let c = LQRTracker(; tg..., Tt = Inf), cd = DiscreteLQRTracker(; tg..., Tt = Inf)
    u = (x = SVector(0.0, 0.0), z = SVector(0.0, 0.0), z_ref = SVector(5.0, 5.0))
    y = L.y_direct(c, (; x = SVector(0.0, 0.0), u)); d = L.x_deriv(c, (; x = SVector(0.0, 0.0), u, y))
    P("055_cont", (; u_raw = y.u_raw, u = y.u, deriv = d, Kint_e = L.parameters(c, u).K_int * (u.z_ref - u.z)))
    s = L.s_init(cd); yd = L.y_direct(cd, (; s, u)); sn = L.s_update(cd, (; s, u, y = yd, Δt = 0.01))
    P("055_disc", (; u_raw = yd.u_raw, q = sn.q, Δt_Kint_e = 0.01 * L.parameters(cd, u).K_int * (u.z_ref - u.z)))
end
P("064_tracker", u_types(LQRTracker(; tg..., K_int = AsPort(), Tt = AsPort())))
P("064_pid", u_types(PID(Kp = 1.0, Ki = AsPort())))
let cd = DiscreteLQRTracker(; tg...)
    P("084_s_init", L.s_init(cd)); P("084_y_types", y_types(cd))
    u = (x = SVector(0.0, 0.0), z = SVector(0.0, 0.0), z_ref = SVector(5.0, 5.0))
    s0 = (q = SVector(0.2, 0.1), saturated = SVector{2, Int8}(0, 0)); s1 = (q = SVector(0.2, 0.1), saturated = SVector{2, Int8}(1, -1))
    y0 = L.y_direct(cd, (; s = s0, u)); y1 = L.y_direct(cd, (; s = s1, u))
    n0 = L.s_update(cd, (; s = s0, u, y = y0, Δt = 0.01)); n1 = L.s_update(cd, (; s = s1, u, y = y1, Δt = 0.01))
    P("093", (; ydirect_same = y0 == y1, q_same = n0.q == n1.q, new_code = n0.saturated, y_state = L.y_state(cd, (; s = n0))))
end

# ===== K6d-036: a scheduled K_int that steps leaves the command continuous =====
let c = DiscreteLQRTracker(; tracker_loop_gains()..., K_int = AsPort())
    m = Group((controller = c, kint = Step(t_step = 1.0, before = SMatrix{2, 2}(0.5, 0.0, 0.0, 0.25), after = SMatrix{2, 2}(5.0, 0.0, 0.0, 2.5)),
               disturbance = Constant(SVector(0.2, -0.1)), sum = SumJunction{SVector{2, Float64}, 2}(), plant = tracker_plant(),
               reference = Step(t_step = 0.5, before = SVector(0.0, 0.0), after = SVector(1.0, 0.5)));
              local_wires = ("plant/y" => "controller/x", "plant/y" => "controller/z", "controller/u" => "sum/in1",
                             "disturbance/y" => "sum/in2", "sum/y" => "plant/u", "reference/y" => "controller/z_ref",
                             "kint/y" => "controller/K_int"))
    sim = Simulation(m; Δt_frame = 1//100); init!(sim, set())
    us = [(step!(sim; frames = 1); port(sim, "controller", :u_raw)) for _ in 1:150]
    jumps = [norm(us[k + 1] - us[k]) for k in 1:149]
    P("036", (; jump_at_98_101 = jumps[98:101], max_jump_after_55 = maximum(jumps[55:149])))
end

# ===== K6d-026, 011, 132: the closed loop =====
A = [0.0 1; -2 -3]; B = Matrix(1.0I, 2, 2); C = Matrix(1.0I, 2, 2); D = zeros(2, 2); K = Matrix(1.0I, 2, 2)
S = D - C * (A \ B); M22 = inv(S); M12 = -(A \ B) * M22
P("011_Kfwd", (M22 + K * M12, tracker_gains().K_fwd))
plain = merge(tracker_loop_gains(), (K_int = zeros(2, 2),))
plant_state(model, n) = (sim = run_frames(model, n); state(sim, "plant"))
P("011_plain_settles", plant_state(tracker_loop(LQRTracker(; plain...)), 2000))
let sim = run_frames(tracker_loop(LQRTracker(; tracker_loop_gains()...); disturbance = SVector(0.2, -0.1)), 20000)
    P("026_with_w", (plant = state(sim, "plant"), q = state(sim, "controller")))
end
function lin(controller, state_taps; disturbance = SVector(0.0, 0.0))
    sim = Simulation(tracker_loop(controller; stepped = false, disturbance); Δt_frame = 1//100)
    init!(sim, set(u = (z_ref = SVector(0.0, 0.0),)))
    linearize(sim, taps(x = state_taps, u = (z_ref1 = get_input("z_ref[1]"), z_ref2 = get_input("z_ref[2]"))))
end
pt = (x1 = get_state("plant", "[1]"), x2 = get_state("plant", "[2]"))
P("132_A", (lin(LQRTracker(; plain...), pt).A, A - B * K))
qt = merge(pt, (q1 = get_state("controller", "[1]"), q2 = get_state("controller", "[2]")))
safe("026_lin", () -> P("026_lin_same", lin(LQRTracker(; tracker_loop_gains()...), qt).A ≈ lin(LQRTracker(; tracker_loop_gains()...), qt; disturbance = SVector(0.2, -0.1)).A))

# ===== K6d-002: Riccati gain stabilizes =====
let Q = Matrix(1.0I, 2, 2), R = Matrix(1.0I, 2, 2)
    H = [A -B * (R \ B'); -Q -A']; F = eigen(H); idx = findall(λ -> real(λ) < 0, F.values)
    X = F.vectors[:, idx]; Pm = real(X[3:4, :] / X[1:2, :]); Kl = R \ (B' * Pm)
    P("002", (care_residual = norm(A' * Pm + Pm * A - Pm * B * (R \ B') * Pm + Q), eig = eigvals(A - B * Kl)))
end

# ===== K6d-074: Freeze drops the schedule's coupling =====
sched() = Junction{SVector{2, Float64}, SMatrix{2, 2, Float64, 4}, 1}(y -> SMatrix{2, 2}(1.0 + y[1], 0.0, 0.0, 1.0))
function sched_loop(freeze)
    c = LQRTracker(; tracker_loop_gains()..., K_int = zeros(2, 2), K_fbk = AsPort(), x_trim = [0.1, -0.2])
    wires = ["plant/y" => "controller/x", "plant/y" => "controller/z", "controller/u" => "plant/u", "plant/y" => "sched/in1",
             (freeze ? ["sched/y" => "freeze/u", "freeze/y" => "controller/K_fbk"] : ["sched/y" => "controller/K_fbk"])...]
    Group(merge((controller = c, plant = tracker_plant(), sched = sched()), freeze ? (freeze = Freeze{SMatrix{2, 2, Float64, 4}}(),) : (;));
          input_wires = ("z_ref" => "controller/z_ref",), local_wires = Tuple(wires))
end
for fr in (false, true)
    safe("074_$fr", () -> begin
        sim = Simulation(sched_loop(fr); Δt_frame = 1//100); init!(sim, set(u = (z_ref = SVector(0.0, 0.0),)))
        P("074_freeze$fr", linearize(sim, taps(x = pt, u = (z_ref1 = get_input("z_ref[1]"), z_ref2 = get_input("z_ref[2]")))).A)
    end)
end

# ===== second pass: variants of the 2026-10-14 emulation (115, 118, 119) =====
function emulation_delayed(Tt)
    c = DiscretePID(Kp = 1.0, Ki = AsPort(), Kd = 0.2, τd = 0.1, Tt = Tt, tracking = true)
    standby_siblings(c, c, DiscreteIntegrator(); delay = true,
        extra = (kia = Junction{Bool, Float64, 1}(m -> m ? 0.5 : 0.0), kib = Junction{Bool, Float64, 1}(m -> m ? 0.0 : 0.5),
                 da = UnitDelay(0.0), db = UnitDelay(0.5)),
        extra_wires = ["kia/y" => "da/u", "kib/y" => "db/u", "da/y" => "a/Ki", "db/y" => "b/Ki"], mode_to = ("kia/in1", "kib/in1"))
end
function bump_series(model, n)
    sim = Simulation(model; Δt_frame = 1//100); init!(sim, set(u = (mode = false,))); step!(sim; frames = 200)
    before = port(sim, "sel"); poke!(sim, "mode", true)
    [(step!(sim; frames = 1); abs(port(sim, "sel") - before)) for _ in 1:n]
end
for Tt in (1.0, 0.1)
    P("V_delayedKi_Tt$Tt", switchover_bump(emulation_delayed(Tt)))
    P("V_series_emul_Tt$Tt", bump_series(emulation(Tt), 5))
end
for Tt in (0.5, 1.0, 2.0, 5.0, 10.0)
    c = DiscretePID(; gains..., Tt = Tt, tracking = true); pl = DiscretePID(; gains...)
    ys = map((c, pl)) do ctrl
        sim = Simulation(standby_siblings(ctrl, ctrl, DiscreteIntegrator(); delay = true); Δt_frame = 1//100)
        init!(sim, set(u = (mode = true,)))
        [(step!(sim; frames = 1); port(sim, "plant")) for _ in 1:400]
    end
    P("V115_Tt$Tt", maximum(abs.(ys[1] .- ys[2])))
end

# ===== third pass: pid_anti_windup.md's cascade table (080), fixtures from test_library.jl 670-686, 735-742 =====
function pid_cascade(controller; hold = false, tracking = false)
    wires = Pair{String, String}[
        "reference/y" => "controller/r", "position/y" => "controller/y",
        "controller/u" => "error/in1", "velocity/y" => "error/in2",
        "error/y" => "inner/u", "inner/out" => "actuator/u",
        "actuator/y" => "velocity/u", "velocity/y" => "position/u"]
    hold && push!(wires, "inner/saturation" => "controller/saturation", "engaged/y" => "controller/engaged")
    tracking && push!(wires, "velocity/y" => "controller/v")
    kids = (reference = Step(t_step = 0.5, after = 5.0), controller = controller,
              error = Junction{Float64, Float64, 2}(-), inner = LimitedIntegrator(lower = -1.2, upper = 1.2),
              actuator = FirstOrderLag(τ = 0.1), velocity = FirstOrderLag(τ = 1.0), position = Integrator())
    Group(merge(kids, hold ? (engaged = Constant(true),) : (;));
          local_wires = Tuple(wires), output_wires = ("position/y" => "y",))
end
function loop_samples(read, model, t_end)
    sim = Simulation(model; Δt_frame = 1//100)
    init!(sim, set())
    [(step!(sim; frames = 10); read(sim)) for _ in 1:round(Int, 10 * t_end)]
end
settling_time(samples) = (findlast(sample -> abs(sample - 5.0) > 0.05, samples) + 1) / 10
let g = (Kp = 0.5, Ki = 0.1)
    for (name, hold, tracking, Tt) in (("none", false, false, Inf), ("hold", true, false, Inf), ("track2", false, true, 2.0),
                                       ("track05", false, true, 0.5), ("both2", true, true, 2.0), ("both05", true, true, 0.5))
        s = loop_samples(sim -> port(sim, "", :y), pid_cascade(PID(; g..., Tt = Tt, hold, tracking); hold, tracking), 60)
        P("080_" * name, (peak = maximum(s), settled = settling_time(s)))
    end
end

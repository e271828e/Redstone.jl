# CV6c verifier probes, run from the pinned worktree W with --project=test.
using Redstone, StaticArrays
include(joinpath(pwd(), "test", "imports.jl"))
fail(f) = try f(); "ok" catch err; err isa Redstone.DiagnosticError ? string(typeof(err), " ", [(typeof(d), getfield(d, :classification)) for d in Redstone.diagnostics(err) if d isa AlgebraicCycle]) : string(typeof(err), ": ", sprint(showerror, err)[1:min(end, 140)]) end
p(label, x) = println(rpad(label, 34), x)

println("== CV6c-001")
p("DTF num/den", typeof(DiscretizedTransferFunction(num = (1.0,), den = (1.0, 2.0))))
p("DTF poles only", DiscretizedTransferFunction(poles = (-2.0,)).num)
p("DTF zeros/poles/gain", DiscretizedTransferFunction(zeros = (-1.0,), poles = (-2.0, -3.0), gain = 2.0).num)
p("DTF u0", Redstone.Library.held(DiscretizedTransferFunction(num = (1.0,), den = (1.0, 2.0), u0 = 4.0)) )

println("== CV6c-013")
p("Sequence ok", typeof(Sequence(times = [1.0, 2.0], values = [0.0, 1.0, 2.0])))
p("non-ascending", fail(() -> Sequence(times = [2.0, 1.0], values = [0.0, 1.0, 2.0])))
p("equal times", fail(() -> Sequence(times = [1.0, 1.0], values = [0.0, 1.0, 2.0])))
p("N values", fail(() -> Sequence(times = [1.0, 2.0], values = [0.0, 1.0])))
p("N+2 values", fail(() -> Sequence(times = [1.0, 2.0], values = [0.0, 1.0, 2.0, 3.0])))

println("== CV6c-073 / 081 / 034")
v3 = SVector(1.0, 2.0, 3.0)
li = LimitedIntegrator(lower = -v3, upper = v3)
p("LI m_init", typeof(m_init(li)))
p("LI events", keys(state_events(li)))
p("LI scalar m_init", typeof(m_init(LimitedIntegrator(lower = -1.0, upper = 1.0))))
ldi = LimitedDoubleIntegrator(lower = -v3, upper = v3)
p("LDI m_init", typeof(m_init(ldi)))
p("LDI events", keys(state_events(ldi)))
r = Relay(lower = -v3, upper = v3)
p("Relay m_init", typeof(m_init(r)))
p("Relay events", keys(state_events(r)))
p("Relay scalar m", typeof(m_init(Relay(lower = 0.0, upper = 1.0))))
c = Comparator(lower = -v3, upper = v3)
p("Comparator m_init", typeof(m_init(c)))
p("Comparator events", keys(state_events(c)))
p("Comparator y_types vec", y_types(c))
p("Comparator y_types scalar", y_types(Comparator(threshold = 0.5)))
p("Comparator scalar events", keys(state_events(Comparator(threshold = 0.5))))
sm = SMatrix{2, 2}(1.0, 2.0, 3.0, 4.0)
p("LI over SMatrix", fail(() -> keys(state_events(LimitedIntegrator(lower = -sm, upper = sm)))))
p("LI over SMatrix events", keys(state_events(LimitedIntegrator(lower = -sm, upper = sm))))

println("== CV6c-024")
d = LimitedDoubleIntegrator(lower = -1.0, upper = 2.0)
p("LDI defaults q0 v0", (d.q0, d.v0))
dv = LimitedDoubleIntegrator(lower = -v3, upper = v3)
p("LDI vec defaults", (dv.q0, dv.v0))

println("== CV6c-045")
p("PID τd = 0", fail(() -> PID(Kp = 1.0, τd = 0.0)))
p("PID τd < 0", fail(() -> PID(Kp = 1.0, τd = -0.1)))
p("PID Tt = 0", fail(() -> PID(Kp = 1.0, Tt = 0.0)))
p("PID Tt = Inf default", fail(() -> PID(Kp = 1.0)))
p("PID Tt = Inf given", fail(() -> PID(Kp = 1.0, Tt = Inf)))
p("PID τd vec one zero", fail(() -> PID(Kp = 1.0, τd = SVector(0.1, 0.0))))
p("PID τd AsPort", fail(() -> PID(Kp = 1.0, τd = AsPort())))

println("== CV6c-054")
dpid_root = Group((; controller = DiscretePID(Kp = AsPort(), Ki = 0.5));
                  input_wires = ("r" => "controller/r", "y" => "controller/y", "Kp" => "controller/Kp"),
                  output_wires = ("controller/u" => "u",))
cpid_root = Group((; controller = PID(Kp = AsPort(), Ki = 0.5));
                  input_wires = ("r" => "controller/r", "y" => "controller/y", "Kp" => "controller/Kp"),
                  output_wires = ("controller/u" => "u",))
for (label, model) in (("DiscretePID", dpid_root), ("PID", cpid_root))
    try
        sim = Simulation(model; Δt_frame = 1//100)
        init!(sim, set(u = (r = 3.0, y = 0.5, Kp = 2.0)))
        lin = linearize(sim, taps(u = (r = get_input(:r), y = get_input(:y), Kp = get_input(:Kp)), y = (u = get_face(:u),)))
        p("$label D (r, y, Kp)", lin.D)
        p("$label y0", lin.y₀)
    catch err
        p("$label linearize", sprint(showerror, err)[1:min(end, 300)])
    end
end

println("== CV6c-064")
gains = (K_fbk = [1.0 0; 0 1], K_fwd = [1.0 -1; 2 4], K_int = [0.5 0; 0 0.25], Tt = 1.0)
plant() = StateSpace(A = [0 1; -2 -3], B = [1 0; 0 1], C = [1 0; 0 1])
function cycle(controller, name, f, Y)
    wires = Pair{String, String}["plant/y" => "controller/x", "plant/y" => "controller/z", "controller/u" => "plant/u",
                                 "controller/u" => "feedback/u", "feedback/y" => "controller/$name"]
    name in (:z_ref,) || push!(wires, "reference/y" => "controller/z_ref")
    Group((plant = plant(), controller = controller, reference = Constant(SVector(1.0, 0.5)),
           feedback = Fn{SVector{2, Float64}, Y}(f)); local_wires = Tuple(wires))
end
S2 = SVector{2, Float64}
M2 = SMatrix{2, 2, Float64, 4}
for (name, kw, f, Y) in ((:z_ref, (;), identity, S2),
                         (:v, (tracking = true,), u -> clamp.(u, -1.0, 1.0), S2),
                         (:K_int, (K_int = AsPort(),), u -> M2(u[1], 0, 0, u[2]), M2),
                         (:Tt, (Tt = AsPort(),), u -> abs.(u) .+ 1.0, S2),
                         (:K_fbk, (K_fbk = AsPort(),), u -> M2(u[1], 0, 0, u[2]), M2),
                         (:K_fwd, (K_fwd = AsPort(),), u -> M2(u[1], 0, 0, u[2]), M2),
                         (:x_trim, (x_trim = AsPort(),), identity, S2),
                         (:u_trim, (u_trim = AsPort(),), identity, S2),
                         (:z_trim, (z_trim = AsPort(),), identity, S2),
                         (:u_min, (u_min = AsPort(),), u -> u .- 10.0, S2),
                         (:u_max, (u_max = AsPort(),), u -> u .+ 10.0, S2))
    p("LQRTracker cycle via $name", fail(() -> build(cycle(LQRTracker(; merge(gains, kw)...), name, f, Y))))
end

println("== CV6c-064 detail")
detail(model) = try build(model); "builds" catch err
    err isa Redstone.DiagnosticError || return sprint(showerror, err)[1:min(end, 200)]
    [(d.classification, d.dead, d.traced) for d in Redstone.diagnostics(err) if d isa AlgebraicCycle] end
for (name, ctor, f, Y) in ((:K_fwd, LQRTracker(; merge(gains, (K_fwd = AsPort(),))...), u -> M2(u[1], 0, 0, u[2]), M2),
                           (:K_fbk, LQRTracker{2, 2, 2}(; merge(gains, (K_fbk = AsPort(),))...), u -> M2(u[1], 0, 0, u[2]), M2),
                           (:K_int, LQRTracker(; merge(gains, (K_int = AsPort(),))...), u -> M2(u[1], 0, 0, u[2]), M2),
                           (:u_trim, LQRTracker(; merge(gains, (u_trim = AsPort(),))...), identity, S2))
    p("detail $name", detail(cycle(ctor, name, f, Y)))
end
# K_fwd with a nonzero z_trim, and the dense-matrix form of the feedback.
p("detail K_fwd z_trim", detail(cycle(LQRTracker(; merge(gains, (K_fwd = AsPort(), z_trim = [0.5, 0.6]))...), :K_fwd,
                                      u -> M2(u[1], 1.0, 1.0, u[2]), M2)))
# PID: the same check over each parameter port, for comparison with §5.4's prose.
for name in (:Kp, :Ki, :Kd, :τd, :Tt, :u_min, :u_max, :b, :c)
    ctl = PID(; merge((Kp = 1.0, Ki = 0.5, Kd = 0.2, Tt = 1.0), (; name => AsPort()))...)
    m = Group((; reference = Step(t_step = 0.5, after = 5.0), controller = ctl,
                 gain = Fn{Float64}(v -> abs(v) + 1.0), plant = Integrator());
              local_wires = ("reference/y" => "controller/r", "plant/y" => "controller/y",
                             "controller/u" => "gain/u", "gain/y" => "controller/$name", "controller/u" => "plant/u"))
    p("PID cycle via $name", detail(m))
end

println("== CV6c-064 matrix ports, feedback generic in the scalar")
diagm2(u) = SMatrix{2, 2}(u[1], zero(u[1]), zero(u[1]), u[2])
for (name, ctor) in ((:K_fwd, LQRTracker(; merge(gains, (K_fwd = AsPort(),))...)),
                     (:K_fbk, LQRTracker{2, 2, 2}(; merge(gains, (K_fbk = AsPort(),))...)),
                     (:K_int, LQRTracker(; merge(gains, (K_int = AsPort(),))...)))
    p("generic $name", detail(cycle(ctor, name, diagm2, M2)))
end

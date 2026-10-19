# One cold process over a closed loop of library blocks. Every timer at top level.
Base.cumulative_compile_timing(true)
ct() = Base.cumulative_compile_time_ns()[1] / 1e9
t_using = @elapsed using Redstone
import Redstone: Simulation, build, init!, run!, step!, set, port, state, series, reads, get_output,
    checkpoint, restore!, Absolute, Hz, phase_bodies, linearize, taps, get_state, get_input, trim!, TrimProblem, get_deriv
import Redstone.Blocks: Group, Step, DiscretePID, FirstOrderLag, TransferFunction, SumJunction, LimitedIntegrator
using Printf

loop() = Group((
        reference = Step(t_step = 0.5, after = 1.0),
        controller = DiscretePID(Kp = 2.0, Ki = 1.0, Tt = 1.0, u_min = -1.0, u_max = 1.0),
        actuator = FirstOrderLag(τ = 0.05),
        force = SumJunction{Float64, 2}(),
        plant = TransferFunction(num = (1.0,), den = (1.0, 0.6, 1.0)),
        integral = LimitedIntegrator(lower = -0.5, upper = 0.5));
    local_wires = ("reference/out" => "controller/r", "plant/out" => "controller/y",
                   "controller/u" => "actuator/in", "actuator/out" => "force/in1",
                   "force/out" => "plant/in", "plant/out" => "integral/in"),
    input_wires = ("disturbance" => "force/in2",),
    output_wires = ("plant/out" => "y",),
    sample_times = (controller = Absolute(Hz(50)),))

c0 = ct()
t_construct = @elapsed root = loop()
t_build = @elapsed bld = build(root)
t_show = @elapsed sprint(show, MIME"text/plain"(), bld)
t_sim = @elapsed sim = Simulation(bld; h = 1//1000)
t_init = @elapsed init!(sim, set(u = (disturbance = 0.0,)))
t_step = @elapsed step!(sim)
t_run = @elapsed run!(sim; t_end = 2.0)
t_reads = @elapsed (port(sim, "plant", :out), state(sim, "plant"))
t_series = @elapsed series(sim, reads(y = get_output("plant", :out), u = get_output("controller", :u)))
t_cp = @elapsed cp = checkpoint(sim)
t_restore = @elapsed restore!(sim, cp)
c_core = ct() - c0
t_trim = @elapsed (sim2 = Simulation(bld; h = 1//1000); trim!(sim2, TrimProblem(guess = (d = 0.3,), lower = (d = -1.0,), upper = (d = 1.0,),
    condition = d -> set(u = (disturbance = d.d,)), reads = reads(q̇₂ = get_deriv("plant", "q[2]")),
    residuals = (derivatives, d) -> (q̇₂ = derivatives.q̇₂,), tolerances = (q̇₂ = 1e-9,)); baseline = set(u = (disturbance = 0.0,))))
c_trim = ct() - c0 - c_core
t_lin = @elapsed linearize(sim, taps(x = (q1 = get_state("plant", "q[1]"), q2 = get_state("plant", "q[2]")), u = (d = get_input(:disturbance),), y = (y = get_output("plant", :out),)))
c_lin = ct() - c0 - c_core - c_trim
c1 = ct()
t_build2 = @elapsed build(loop())      # the same model again: everything warm
@printf("COLD using=%.2f construct=%.2f build=%.2f show=%.2f sim=%.2f init=%.2f run=%.2f step=%.2f reads=%.2f series=%.3f cp=%.2f restore=%.2f | core_total=%.2f core_compile=%.2f | trim=%.2f (compile %.2f) | linearize=%.2f (compile %.2f) | build_again=%.3f\n",
    t_using, t_construct, t_build, t_show, t_sim, t_init, t_run, t_step, t_reads, t_series, t_cp, t_restore,
    t_construct + t_build + t_show + t_sim + t_init + t_run + t_step + t_reads + t_series + t_cp + t_restore,
    c_core, t_trim, c_trim, t_lin, c_lin, t_build2)

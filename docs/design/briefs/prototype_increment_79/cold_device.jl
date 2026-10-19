Base.cumulative_compile_timing(true)
ct() = Base.cumulative_compile_time_ns()[1] / 1e9
using Redstone
import Redstone: Simulation, build, init!, run!, set, Absolute, Hz, AbstractDevice, attach!, TableBinding,
    loop, running, wait_next_snapshot, binding, map_input, stage!, termination
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
mutable struct Knob <: AbstractDevice
    datum::NamedTuple
end
function loop(dev::Knob, handle)
    while running(handle)
        wait_next_snapshot(handle)
        stage!(handle, map_input(dev.datum, binding(handle))...)
    end
    nothing
end
sim = Simulation(loop(); h = 1//1000)
init!(sim, set(u = (disturbance = 0.0,))); run!(sim; t_end = 0.1)   # the core path, warm from the image
c0 = ct()
t_attach = @elapsed attach!(sim, Knob((; d = 0.1)), TableBinding(d = (face = "disturbance",)))
t_init = @elapsed init!(sim, set(u = (disturbance = 0.0,)))
t_run = @elapsed run!(sim; t_end = 0.2)
t_term = @elapsed termination(sim)
@printf("DEVICE attach=%.2f init=%.2f run=%.2f termination=%.2f | total=%.2f compile=%.2f\n",
    t_attach, t_init, t_run, t_term, t_attach + t_init + t_run + t_term, ct() - c0)

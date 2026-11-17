# Probe: an enum-valued root input staged between steps, read by a `Select`,
# by a junction deriving a controller's `engaged`, and by a discrete PID.
using Redstone
import Redstone: Simulation, init!, step!, stage!, set, port, series, reads, get_input, get_output, Absolute, Hz
import Redstone.Library: Group, Select, Junction, DiscretePID, Constant

@enum Mode MANUAL CASCADE TRACKER

root = Group((; sel = Select{Float64, Mode}(),
                is_cascade = Junction{Mode, Bool, 1}(mode -> mode === CASCADE),
                ctl = DiscretePID(Kp = 1.0, Ki = 1.0, Tt = 0.02, hold = true, tracking = true),
                free = Constant(Int8(0)));
             input_wires = ("pilot" => ("sel/MANUAL", "ctl/v"), "tracker" => "sel/TRACKER",
                            "mode" => ("sel/select", "is_cascade/in1"),
                            "r" => "ctl/r", "y" => "ctl/y"),
             local_wires = ("ctl/u" => "sel/CASCADE", "is_cascade/y" => "ctl/engaged",
                            "free/y" => "ctl/saturation"),
             output_wires = ("sel/y" => "command",),
             sample_times = (ctl = Absolute(Hz(50)),))

sim = Simulation(root; Δt_frame = 1//100)
init!(sim, set(u = (pilot = 1.0, tracker = 3.0, mode = MANUAL, r = 0.5, y = 0.0)))
step!(sim; frames = 50)
println("MANUAL:  command = ", port(sim, "sel", :y), ", engaged = ", port(sim, "is_cascade", :y),
        ", standby u = ", port(sim, "ctl", :u))
stage!(sim, "mode" => CASCADE)
step!(sim; frames = 50)
println("CASCADE: command = ", port(sim, "sel", :y), ", engaged = ", port(sim, "is_cascade", :y))
stage!(sim, "mode" => TRACKER)
step!(sim; frames = 50)
println("TRACKER: command = ", port(sim, "sel", :y), ", engaged = ", port(sim, "is_cascade", :y))
s = series(sim, reads(mode = get_input("mode"), command = get_output("sel", :y)))
println("logged mode type: ", eltype(s.columns.mode), ", changes at snapshots ",
        findall(i -> s.columns.mode[i] != s.columns.mode[i - 1], 2:length(s.t)) .+ 1)

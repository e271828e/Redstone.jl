pid_controller(hold, tracking) =
    PID(Kp = 1.0, Ki = 0.5, Kd = 0.2, τd = 0.1, Tt = 1.0, u_min = -1.0, u_max = 1.0,
        hold = hold, tracking = tracking)

# `pid_controller`'s gains, and a second set apart from them in every term of
# the law.
pid_gain_sets() = ((Kp = 1.0, Ki = 0.5, Kd = 0.2, τd = 0.1, Tt = 1.0, u_min = -1.0, u_max = 1.0),
                   (Kp = 2.0, Ki = 0.25, Kd = 0.1, τd = 0.2, Tt = 2.0, u_min = -0.5, u_max = 0.5))

# A PID's outputs and the motion of its state at one point: `x_deriv` on the
# continuous tier, `s_update` at `Δt = 0.01` on the discrete one.
pid_law(c::PID, x, u, y) = (y_direct(c, (; x, u)), x_deriv(c, (; x, u, y)))
pid_law(c::DiscretePID, s, u, y) = (y_direct(c, (; s, u, Δt = 0.01)), s_update(c, (; s, u, y, Δt = 0.01)))

# A PID as the root's one child: its ports are root inputs, and `u` and `u_raw`
# leave the root.
function pid_root_model(controller::PID{V, Hold, Track}) where {V, Hold, Track}
    inputs = ["r" => "controller/r", "y" => "controller/y"]
    Hold && append!(inputs, ["saturation" => "controller/saturation", "engaged" => "controller/engaged"])
    Track && push!(inputs, "v" => "controller/v")
    Group((; controller = controller); input_wires = Tuple(inputs),
          output_wires = ("controller/u" => "u", "controller/u_raw" => "u_raw"))
end

# A PID as the root's one child with every port a root input, its scheduled
# parameters included; with `frozen`, each scheduled parameter's input reaches
# its port through a `Freeze`.
function scheduled_pid_root(controller::PID{V}; frozen = false) where {V}
    port_names = keys(u_types(controller))
    scheduled = filter(∉((:r, :y, :saturation, :v)), port_names)
    freezes = NamedTuple{map(name -> Symbol(:freeze_, name), scheduled)}(map(_ -> Freeze{V}(), scheduled))
    port_entry(name) = frozen && name in scheduled ? "freeze_$name/u" : "controller/$name"
    Group(merge((; controller), frozen ? freezes : (;));
          input_wires = map(name -> String(name) => port_entry(name), port_names),
          local_wires = frozen ? map(name -> "freeze_$name/y" => "controller/$name", scheduled) : (),
          output_wires = ("controller/u" => "u", "controller/u_raw" => "u_raw"))
end

# A PID root model linearized at the root inputs `inputs`: the controller's two
# states, every real input and the face `u`.
function pid_linearization(model, inputs)
    sim = Simulation(model; Δt_frame = 1//100)
    init!(sim, set(u = inputs))
    real_names = filter(!=(:saturation), keys(inputs))
    linearize(sim, taps(x = (q = get_state("controller", :q), yf = get_state("controller", :yf)),
                        u = NamedTuple{real_names}(map(get_input, real_names)), y = (u = get_face(:u),)))
end

# A tracking PID whose `v` is a memoryless clamp of its own `u`, the clamp also
# driving an integrator plant; the continuous PID unless given.
pid_clamp_loop(controller = PID(Kp = 1.0, Ki = 0.5, Kd = 0.2, Tt = 1.0, tracking = true)) =
    Group((; reference = Step(t_step = 0.5, after = 5.0), controller = controller,
             sat = Fn{Float64}(v -> clamp(v, -1.0, 1.0)), plant = Integrator());
          local_wires = ("reference/y" => "controller/r", "plant/y" => "controller/y",
                         "controller/u" => "sat/u", "sat/y" => "controller/v",
                         "sat/y" => "plant/u"))

# A PID whose scheduled parameter `name`, `Kp` unless given, is a memoryless
# function of its own `u`.
scheduled_pid_cycle(name = :Kp) =
    Group((; reference = Step(t_step = 0.5, after = 5.0),
             controller = PID(; merge((Kp = 1.0, Ki = 0.5, Kd = 0.2, Tt = 1.0), (; name => AsPort()))...),
             gain = Fn{Float64}(abs), plant = Integrator());
          local_wires = ("reference/y" => "controller/r", "plant/y" => "controller/y",
                         "controller/u" => "gain/u", "gain/y" => "controller/$name",
                         "controller/u" => "plant/u"))

# The PID's first variant as library components, the inspector's example beside
# the primitive: the integrator is what splits the stages (§5.4).
pid_assembly(; Kp, Ki, Kd, τd, Tt, u_min, u_max) = Group((
        err = Junction{Float64, Float64, 2}((r, y) -> r - y),
        lag = FirstOrderLag(; τ = τd),
        der = Junction{Float64, Float64, 2}((y, yf) -> (y - yf) / τd),
        int = Integrator(),
        raw = Junction{Float64, Float64, 3}((e, q, rate) -> Kp * e + q - Kd * rate),
        sat = Fn{Float64}(v -> clamp(v, u_min, u_max)),
        aw  = Junction{Float64, Float64, 3}((e, u, u_raw) -> Ki * e + (u - u_raw) / Tt));
      input_wires  = ("r" => "err/in1", "y" => ("err/in2", "lag/u", "der/in1")),
      local_wires  = ("lag/y" => "der/in2",
                      "err/y" => "raw/in1", "int/y" => "raw/in2", "der/y" => "raw/in3",
                      "raw/y" => "sat/u",
                      "err/y" => "aw/in1", "sat/y" => "aw/in2", "raw/y" => "aw/in3",
                      "aw/y" => "int/u"),
      output_wires = ("sat/y" => "u", "raw/y" => "u_raw"))

# A single loop on the own limits: the controller drives an integrator plant,
# continuous unless given, to a reference step to `level`.
pid_single_loop(controller; plant = Integrator(), level = 5.0) = Group((
        reference = Step(t_step = 0.5, before = zero(level), after = level), controller = controller,
        plant = plant);
      local_wires = ("reference/y" => "controller/r", "plant/y" => "controller/y",
                     "controller/u" => "plant/u"),
      output_wires = ("plant/y" => "y",))

# The single loop over two channels, one per gain set: channel 1 is the loop
# above at `pid_controller`'s gains, channel 2 the second set's on a reference of 3.
vector_pid_loop(component_type = PID; plant = Integrator(x0 = SVector(0.0, 0.0))) =
    pid_single_loop(component_type(; map(SVector, pid_gain_sets()...)...); plant = plant, level = SVector(5.0, 3.0))

# `vector_pid_loop` with hold and tracking: `v` is the plant's output, both codes
# are zero, and channel 1 is engaged while channel 2 is not.
vector_standby_loop(component_type = PID; plant = Integrator(x0 = SVector(0.0, 0.0))) = Group((
        reference = Step(t_step = 0.5, before = SVector(0.0, 0.0), after = SVector(5.0, 3.0)),
        controller = component_type(; map(SVector, pid_gain_sets()...)..., hold = true, tracking = true),
        free = Constant(SVector{2, Int8}(0, 0)), engaged = Constant(SVector(true, false)), plant = plant);
      local_wires = ("reference/y" => "controller/r", "plant/y" => "controller/y", "plant/y" => "controller/v",
                     "free/y" => "controller/saturation", "engaged/y" => "controller/engaged",
                     "controller/u" => "plant/u"))

# The single loop at `pid_controller`'s gains with `Kp` a port, fed by a constant.
scheduled_pid_loop() = Group((
        reference = Step(t_step = 0.5, before = 0.0, after = 5.0),
        controller = PID(Kp = AsPort(), Ki = 0.5, Kd = 0.2, τd = 0.1, Tt = 1.0, u_min = -1.0, u_max = 1.0),
        gain = Constant(1.0), plant = Integrator());
      local_wires = ("reference/y" => "controller/r", "plant/y" => "controller/y",
                     "gain/y" => "controller/Kp", "controller/u" => "plant/u"),
      output_wires = ("plant/y" => "y",))

# A servo loop: a first-order position servo limited at ±1 between the
# controller and the plant, whose position a tracking controller tracks.
function pid_servo_loop(controller)
    wires = Pair{String, String}[
        "reference/y" => "controller/r", "plant/y" => "controller/y",
        "controller/u" => "servo_error/in1", "servo/out" => "servo_error/in2",
        "servo_error/y" => "servo/u"]
    haskey(u_types(controller), :v) && push!(wires, "servo/out" => "controller/v")
    push!(wires, "servo/out" => "plant/u")
    Group((reference = Step(t_step = 0.5, after = 5.0), controller = controller,
           servo_error = Junction{Float64, Float64, 2}(-),
           servo = LimitedIntegrator(lower = -1.0, upper = 1.0), plant = Integrator());
          local_wires = Tuple(wires), output_wires = ("plant/y" => "y",))
end

# A cascade: the controller sets a velocity servo's reference and reads the
# position that integrates the velocity; `hold` wires the inner integrator's
# saturation into the controller and a constant `true` into its `engaged`,
# `tracking` the velocity into `v`.
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

# Two sibling controllers driving one plant through a `Switch` on the root input
# `mode`, which selects `a` while true. A holding pair reads `mode` as `a`'s
# `engaged` and its negation as `b`'s, and the constant zero code `free` as both
# `saturation`; a tracking pair also reads the selected command as `v`, through
# a `UnitDelay` with `delay`.
function standby_siblings(controller_a, controller_b, plant; delay)
    holding = haskey(u_types(controller_a), :engaged)
    command = delay ? "delay/y" : "sel/y"
    wires = Pair{String, String}[
        "ref_a/y" => "a/r", "ref_b/y" => "b/r", "plant/y" => "a/y", "plant/y" => "b/y",
        "a/u" => "sel/in1", "b/u" => "sel/in2", "sel/y" => "plant/u"]
    delay && push!(wires, "sel/y" => "delay/u")
    haskey(u_types(controller_a), :v) && append!(wires, [command => "a/v", command => "b/v"])
    holding && append!(wires, ["negate/y" => "b/engaged", "free/y" => "a/saturation", "free/y" => "b/saturation"])
    kids = (ref_a = Step(t_step = 0.5, after = 5.0), ref_b = Constant(2.0), a = controller_a, b = controller_b,
              sel = Switch{Float64}(), plant = plant)
    Group(merge(kids, holding ? (negate = Fn{Bool}(!), free = Constant(Int8(0))) : (;),
                delay ? (delay = UnitDelay(0.0),) : (;));
          input_wires = ("mode" => (holding ? ("sel/select", "a/engaged", "negate/u") : ("sel/select",)),),
          local_wires = Tuple(wires))
end

# A discrete cascade: the outer PID's `u` is the inner PID's reference, the
# inner PID drives a discrete integrator plant that both measure, and with
# `hold` the inner code reaches the outer hold and a constant `true` its
# `engaged`.
function discrete_pid_cascade(; hold)
    wires = Pair{String, String}[
        "reference/y" => "outer/r", "outer/u" => "inner/r", "inner/u" => "plant/u",
        "plant/y" => "outer/y", "plant/y" => "inner/y"]
    hold && push!(wires, "inner/saturated" => "outer/saturation", "engaged/y" => "outer/engaged")
    kids = (reference = Step(t_step = 0.5, after = 5.0), outer = DiscretePID(Kp = 0.5, Ki = 0.5, Tt = 1.0, hold = hold),
              inner = DiscretePID(Kp = 2.0, Ki = 1.0, Tt = 1.0, u_min = -1.0, u_max = 1.0), plant = DiscreteIntegrator())
    Group(merge(kids, hold ? (engaged = Constant(true),) : (;)); local_wires = Tuple(wires))
end

# A holding discrete PID, engaged by a constant `true`, driving a discrete
# integrator plant through a discrete limited integrator, whose code it reads.
discrete_hold_loop(controller) = Group((
        reference = Step(t_step = 0.5, after = 5.0), controller = controller, engaged = Constant(true),
        actuator = DiscreteLimitedIntegrator(lower = -1.0, upper = 1.0), plant = DiscreteIntegrator());
      local_wires = ("reference/y" => "controller/r", "plant/y" => "controller/y",
                     "controller/u" => "actuator/u", "actuator/out" => "plant/u",
                     "actuator/saturation" => "controller/saturation", "engaged/y" => "controller/engaged"))

# A loop run at `h = 1//100` and sampled every 0.1 up to `t_end`: `read(sim)`
# at each sample.
function loop_samples(read, model, t_end)
    sim = Simulation(model; Δt_frame = 1//100)
    init!(sim, set())
    [(step!(sim; frames = 10); read(sim)) for _ in 1:round(Int, 10 * t_end)]
end

# The time of the first sample from which a loop's samples, taken every 0.1
# from 0.1, stay within 0.05 of the reference 5.
settling_time(samples) = (findlast(sample -> abs(sample - 5.0) > 0.05, samples) + 1) / 10

# A sibling model run at `h = 1//100` with `b` in command for 200 frames: the
# selected command's move over the frame after `mode` switches to `a`.
function switchover_bump(model)
    sim = Simulation(model; Δt_frame = 1//100)
    init!(sim, set(u = (mode = false,)))
    step!(sim; frames = 200)
    before = port(sim, "sel")
    poke!(sim, "mode", true)
    step!(sim; frames = 1)
    abs(port(sim, "sel") - before)
end

# The probe copies of `sensing`, `cascade` and `selection`, evaluated into the module over `probe_knobs`.
# Include after common.jl.

const DEFAULT_KNOBS = (Tt = 0.02, θ_lim = 0.5, hold = true,
                       h = (Kp = 0.01, Ki = 0.001), θ = (Kp = 2.0, Ki = 0.5),
                       q = (Kp = -0.2, Ki = -0.4), V = (Kp = 0.2, Ki = 0.05),
                       delays = :base,       # :base, or :sensor (δe at the IMU's, δt at the air data's)
                       m = (imu = 1, ins = 4, air_data = 20),   # the multipliers, read at run time
                       air_data_sensor = nothing)               # the sensing's air data entry, when apart from m
Core.eval(RE, :(const probe_knobs = Ref{Any}($DEFAULT_KNOBS)))
knobs!(; kw...) = (RE.probe_knobs[] = merge(DEFAULT_KNOBS, (; kw...)); nothing)

Core.eval(RE, quote
    function cascade(; standby = false)
        k = probe_knobs[]
        pid(; gains...) = DiscretePID(; gains..., Tt = k.Tt, hold = k.hold, tracking = standby)
        θ_readers, q_readers = standby ? (("θ_ctl/y", "h_ctl/v"), ("q_ctl/y", "θ_ctl/v")) : ("θ_ctl/y", "q_ctl/y")
        tracking_wires = standby ? ("δe_track" => "q_ctl/v", "δt_track" => "V_ctl/v") : ()
        hold_wires = k.hold ? ("θ_ctl/saturated" => "h_ctl/saturation", "q_ctl/saturated" => "θ_ctl/saturation",
                               "free/y" => "q_ctl/saturation", "free/y" => "V_ctl/saturation") : ()
        engaged = k.hold ? ("engaged" => ("h_ctl/engaged", "θ_ctl/engaged", "q_ctl/engaged", "V_ctl/engaged"),) : ()
        Group((; h_ctl = pid(; k.h..., u_min = -0.26, u_max = 0.26),
                 θ_ctl = pid(; k.θ..., u_min = -k.θ_lim, u_max = k.θ_lim),
                 q_ctl = pid(; k.q..., u_min = -0.5, u_max = 0.5),
                 V_ctl = pid(; k.V..., u_min = 0.0, u_max = 1.0),
                 free = Constant(Int8(0)));
              input_wires = ("h_ref" => "h_ctl/r", "h_meas" => "h_ctl/y", "θ_meas" => θ_readers, "q_meas" => q_readers,
                             "V_ref" => "V_ctl/r", "V_meas" => "V_ctl/y", engaged..., tracking_wires...),
              local_wires = ("h_ctl/u" => "θ_ctl/r", "θ_ctl/u" => "q_ctl/r", hold_wires...),
              output_wires = ("q_ctl/u" => "δe", "V_ctl/u" => "δt"),
              sample_times = (h_ctl = Relative(k.m.air_data), θ_ctl = Relative(k.m.ins),
                              q_ctl = Relative(k.m.imu), V_ctl = Relative(k.m.air_data)))
    end
    function selection(solution)
        k = probe_knobs[]
        delays = k.delays === :sensor ?
            (command_δe = Relative(k.m.imu), command_δt = Relative(k.m.air_data)) : (;)
        Group((; latch = UnitDelay(false), select_δe = Switch{Float64}(), select_δt = Switch{Float64}(),
                 command_δe = UnitDelay(solution.δe), command_δt = UnitDelay(solution.δt));
              input_wires = ("δe_auto" => "select_δe/in1", "δe_pilot" => "select_δe/in2",
                             "δt_auto" => "select_δt/in1", "δt_pilot" => "select_δt/in2", "engage" => "latch/u"),
              local_wires = ("latch/y" => "select_δe/select", "latch/y" => "select_δt/select",
                             "select_δe/y" => "command_δe/u", "select_δt/y" => "command_δt/u"),
              output_wires = ("select_δe/y" => "δe", "select_δt/y" => "δt",
                              "command_δe/y" => "δe_prev", "command_δt/y" => "δt_prev", "latch/y" => "engaged"),
              sample_times = (latch = Relative(k.m.air_data), delays...))
    end
    function sensing(; noise_psd = sensor_noise_psd)
        k = probe_knobs[]
        imu = Group((; q_noise = GaussianWhiteNoise(seed = 3, psd = noise_psd.q), q_meas = Measurement());
                    input_wires = ("q" => "q_meas/signal",), local_wires = ("q_noise/y" => "q_meas/noise",),
                    output_wires = ("q_meas/y" => "q_meas",))
        ins = Group((; θ_noise = GaussianWhiteNoise(seed = 5, psd = noise_psd.θ), θ_meas = Measurement());
                    input_wires = ("θ" => "θ_meas/signal",), local_wires = ("θ_noise/y" => "θ_meas/noise",),
                    output_wires = ("θ_meas/y" => "θ_meas",))
        air_data = Group((; h_noise = GaussianWhiteNoise(seed = 7, psd = noise_psd.h), h_meas = Measurement(),
                            V_noise = GaussianWhiteNoise(seed = 11, psd = noise_psd.V), V_meas = Measurement());
                         input_wires = ("h" => "h_meas/signal", "V" => "V_meas/signal"),
                         local_wires = ("h_noise/y" => "h_meas/noise", "V_noise/y" => "V_meas/noise"),
                         output_wires = ("h_meas/y" => "h_meas", "V_meas/y" => "V_meas"))
        Group((; imu, ins, air_data);
              input_wires = ("q" => "imu/q", "θ" => "ins/θ", "h" => "air_data/h", "V" => "air_data/V"),
              output_wires = ("imu/q_meas" => "q_meas", "ins/θ_meas" => "θ_meas",
                              "air_data/h_meas" => "h_meas", "air_data/V_meas" => "V_meas"),
              sample_times = (imu = Relative(k.m.imu), ins = Relative(k.m.ins),
                              air_data = Relative(something(k.air_data_sensor, k.m.air_data))))
    end
end)

# PROBE TRAP: a `const` redefined with `Core.eval` reached the source's `sensing` but not these
# evaluated copies (p06_debug), so the multipliers are a run-time knob here, never the constant.

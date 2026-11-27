# The reviewer's shared probe setup. Run a probe from the review worktree's root:
#   julia --startup-file=no --project=examples/test ../tutorial_1b_review_probes/<probe>.jl
# The builders below are the reviewer's own copies of the example's functions with the rates,
# the attitude limit and the hold as parameters; `check_copies` asserts that at the shipped
# values they fly bit-identically to the source's.
using Test, LinearAlgebra, Printf
using Statistics: std, cor, mean
using Redstone, RedstoneExamples
import Redstone: Build, ProbeDual, Simulation, build, init!, run!, step!, stage!, trim!, state, series, reads,
    get_output, get_face, get_input, termination, lifecycle, set, at, combine, override, checkpoint, restore!,
    local_wires, Group, Relative, Absolute
import Redstone.Library: DiscretePID, Constant, GaussianWhiteNoise, Switch, UnitDelay
const WT = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/tutorial_1b_review"
include(joinpath(WT, "examples", "test", "utils.jl"))
const RE = RedstoneExamples
const DEP = (Δt_frame = 1//400, Δt_base = 1//200)
const SHIPPED = (imu = 1, ins = 4, air_data = 20)
const QUIET = (q = 0.0, θ = 0.0, h = 0.0, V = 0.0)
fidx(t) = round(Int, t * 400)

function trim_solution()
    sim = Simulation(RE.aircraft(); Δt_frame = 1//100)
    trim!(sim, RE.level_flight(); baseline = set(u = (δe = 0.0, δt = 0.5))).solution
end

function my_sensing(; noise_psd = RE.sensor_noise_psd, m = SHIPPED)
    M = RE.Measurement
    imu = Group((; q_noise = GaussianWhiteNoise(seed = 3, psd = noise_psd.q), q_meas = M());
                input_wires = ("q" => "q_meas/signal",), local_wires = ("q_noise/y" => "q_meas/noise",),
                output_wires = ("q_meas/y" => "q_meas",))
    ins = Group((; θ_noise = GaussianWhiteNoise(seed = 5, psd = noise_psd.θ), θ_meas = M());
                input_wires = ("θ" => "θ_meas/signal",), local_wires = ("θ_noise/y" => "θ_meas/noise",),
                output_wires = ("θ_meas/y" => "θ_meas",))
    air = Group((; h_noise = GaussianWhiteNoise(seed = 7, psd = noise_psd.h), h_meas = M(),
                   V_noise = GaussianWhiteNoise(seed = 11, psd = noise_psd.V), V_meas = M());
                input_wires = ("h" => "h_meas/signal", "V" => "V_meas/signal"),
                local_wires = ("h_noise/y" => "h_meas/noise", "V_noise/y" => "V_meas/noise"),
                output_wires = ("h_meas/y" => "h_meas", "V_meas/y" => "V_meas"))
    Group((; imu, ins, air_data = air);
          input_wires = ("q" => "imu/q", "θ" => "ins/θ", "h" => "air_data/h", "V" => "air_data/V"),
          output_wires = ("imu/q_meas" => "q_meas", "ins/θ_meas" => "θ_meas",
                          "air_data/h_meas" => "h_meas", "air_data/V_meas" => "V_meas"),
          sample_times = (imu = Relative(m.imu), ins = Relative(m.ins), air_data = Relative(m.air_data)))
end

# `m` gives each controller the multiplier of the sensor that feeds it.
function my_cascade(; standby = false, m = SHIPPED, θ_lim = 0.5, hold = true)
    pid(; g...) = DiscretePID(; g..., Tt = 0.02, hold, tracking = standby)
    children = (; h_ctl = pid(Kp = 0.01, Ki = 0.001, u_min = -0.26, u_max = 0.26),
                  θ_ctl = pid(Kp = 2.0, Ki = 0.5, u_min = -θ_lim, u_max = θ_lim),
                  q_ctl = pid(Kp = -0.2, Ki = -0.4, u_min = -0.5, u_max = 0.5),
                  V_ctl = pid(Kp = 0.2, Ki = 0.05, u_min = 0.0, u_max = 1.0))
    θr, qr = standby ? (("θ_ctl/y", "h_ctl/v"), ("q_ctl/y", "θ_ctl/v")) : ("θ_ctl/y", "q_ctl/y")
    trk = standby ? ("δe_track" => "q_ctl/v", "δt_track" => "V_ctl/v") : ()
    ins = ("h_ref" => "h_ctl/r", "h_meas" => "h_ctl/y", "θ_meas" => θr, "q_meas" => qr,
           "V_ref" => "V_ctl/r", "V_meas" => "V_ctl/y", trk...)
    loc = ("h_ctl/u" => "θ_ctl/r", "θ_ctl/u" => "q_ctl/r")
    if hold
        children = merge(children, (; free = Constant(Int8(0))))
        ins = (ins..., "engaged" => ("h_ctl/engaged", "θ_ctl/engaged", "q_ctl/engaged", "V_ctl/engaged"))
        loc = (loc..., "θ_ctl/saturated" => "h_ctl/saturation", "q_ctl/saturated" => "θ_ctl/saturation",
               "free/y" => "q_ctl/saturation", "free/y" => "V_ctl/saturation")
    end
    Group(children; input_wires = ins, local_wires = loc, output_wires = ("q_ctl/u" => "δe", "V_ctl/u" => "δt"),
          sample_times = (h_ctl = Relative(m.air_data), θ_ctl = Relative(m.ins), q_ctl = Relative(m.imu),
                          V_ctl = Relative(m.air_data)))
end

function my_autopilot(solution; noise_psd = RE.sensor_noise_psd, ms = SHIPPED, mc = SHIPPED, θ_lim = 0.5, hold = true)
    kids = (; plant = RE.Longitudinal(), sensing = my_sensing(; noise_psd, m = ms),
              cascade = my_cascade(; m = mc, θ_lim, hold), actuators = RE.actuators(solution))
    loc = (RE.feedback_wires()..., "cascade/δe" => "actuators/δe_cmd", "cascade/δt" => "actuators/δt_cmd")
    if hold
        kids = merge(kids, (; engaged = Constant(true)))
        loc = (loc..., "engaged/y" => "cascade/engaged")
    end
    Group(kids; input_wires = ("h_ref" => "cascade/h_ref", "V_ref" => "cascade/V_ref"), local_wires = loc)
end

# The selection: shipped (`latch = true`); without the latch, `engage` read by the switches
# straight (`latch = false`); or without the latch and with the switches held on the pilot
# (`switches = false`), so `engage` reaches only the cascade and the plant never changes.
function my_selection(solution; latch = true, switches = true)
    kids = (; select_δe = Switch{Float64}(), select_δt = Switch{Float64}(),
              command_δe = UnitDelay(solution.δe), command_δt = UnitDelay(solution.δt))
    ins = ("δe_auto" => "select_δe/in1", "δe_pilot" => "select_δe/in2",
           "δt_auto" => "select_δt/in1", "δt_pilot" => "select_δt/in2")
    loc = ("select_δe/y" => "command_δe/u", "select_δt/y" => "command_δt/u")
    outs = ("select_δe/y" => "δe", "select_δt/y" => "δt", "command_δe/y" => "δe_prev", "command_δt/y" => "δt_prev")
    if latch
        Group(merge(kids, (; latch = UnitDelay(false))); input_wires = (ins..., "engage" => "latch/u"),
              local_wires = (loc..., "latch/y" => "select_δe/select", "latch/y" => "select_δt/select"),
              output_wires = (outs..., "latch/y" => "engaged"), sample_times = (latch = Relative(SHIPPED.air_data),))
    elseif switches
        Group(kids; input_wires = (ins..., "engage" => ("select_δe/select", "select_δt/select")),
              local_wires = loc, output_wires = outs)
    else
        Group(merge(kids, (; pilot = Constant(false))); input_wires = ins,
              local_wires = (loc..., "pilot/y" => "select_δe/select", "pilot/y" => "select_δt/select"),
              output_wires = outs)
    end
end

function my_piloted(solution; noise_psd = RE.sensor_noise_psd, latch = true, switches = true)
    ins = ("h_ref" => "cascade/h_ref", "V_ref" => "cascade/V_ref",
           "δe_pilot" => "selection/δe_pilot", "δt_pilot" => "selection/δt_pilot")
    loc = (RE.feedback_wires()...,
           "cascade/δe" => "selection/δe_auto", "cascade/δt" => "selection/δt_auto",
           "selection/δe" => "actuators/δe_cmd", "selection/δt" => "actuators/δt_cmd",
           "selection/δe_prev" => "cascade/δe_track", "selection/δt_prev" => "cascade/δt_track")
    if latch
        ins = (ins..., "engage" => "selection/engage")
        loc = (loc..., "selection/engaged" => "cascade/engaged")
    elseif switches
        ins = (ins..., "engage" => ("selection/engage", "cascade/engaged"))
    else
        ins = (ins..., "engage" => "cascade/engaged")
    end
    Group((; plant = RE.Longitudinal(), sensing = my_sensing(; noise_psd), cascade = my_cascade(standby = true),
             selection = my_selection(solution; latch, switches), actuators = RE.actuators(solution));
          input_wires = ins, local_wires = loc, output_wires = ("plant/h" => "h",))
end

function climb(model, solution; t_end = 120.0, h_step = 50.0, dep = DEP)
    sim = Simulation(model; dep...)
    init!(sim, override(RE.cruise(solution), set(u = (h_ref = 1000.0 + h_step,))))
    run!(sim; t_end)
    sim
end

# Chapter 6's scenario, my own spelling: stop at each nominal time and stage there.
function by_hand!(sim, solution; until = 90.0, engage = true, offset = 0)
    step!(sim; frames = fidx(5.0) + offset)
    stage!(sim, "δe_pilot" => solution.δe - 0.02)
    step!(sim; frames = fidx(7.0) - fidx(5.0))
    stage!(sim, "δe_pilot" => solution.δe)
    step!(sim; frames = fidx(30.0) - fidx(7.0))
    engage && stage!(sim, "engage" => true)
    step!(sim; frames = fidx(until) - fidx(30.0) - offset)
    sim
end

function sink!(sim; sink_rate = 1.5)
    h_ref, n = 1000.0, 0
    while lifecycle(sim) !== :stopped && n < 10_000
        h_ref -= sink_rate / 10
        stage!(sim, "h_ref" => h_ref)
        step!(sim; t_plus = 1//10)
        n += 1
    end
    n
end

function hand_sim(model, solution; until = 90.0, engage = true, offset = 0, log_max = nothing)
    sim = Simulation(model; DEP...)
    log_max === nothing ? init!(sim, RE.hand_flown(solution)) : init!(sim, RE.hand_flown(solution); log_max)
    by_hand!(sim, solution; until, engage, offset)
end

# The longitudinal aircraft: a three-degree-of-freedom point mass with pitch,
# its trim problem, its tap set, its gain design, the closed loop and the
# descent the tutorial's layers walk through. The physics and the control design
# are `design/companions/longitudinal_aircraft.md`.

"""The gravitational acceleration, in m/s², constant over a flat earth."""
const g = 9.81

"""
    Longitudinal(; m = 1000.0, S = 16.0, c̄ = 1.5, Iyy = 1800.0, T_max = 2500.0, ρ = 1.225,
                   CL0 = 0.3, CLα = 5.0, CD0 = 0.03, k = 0.05,
                   Cm0 = 0.05, Cmα = -1.0, Cmq = -12.0, Cmδe = -1.2)

A rigid aircraft in its plane of symmetry, with three degrees of freedom:
airspeed `V`, flight path angle `γ`, pitch angle `θ`, pitch rate `q` and
altitude `h` as its states, elevator `δe` and throttle `δt` as its inputs, and
the states with the angle of attack `α = θ - γ` as its outputs, all from the
state, so the plant has no feedthrough. A continuous leaf. Lift and drag follow
a linear lift curve and a parabolic polar, the pitching moment a static, a
damping and an elevator term, and the thrust is `δt T_max` along the body
axis, with constant density and still air:

    V̇ = (T cos α - D) / m - g sin γ
    γ̇ = (L + T sin α) / (m V) - g cos γ / V
    θ̇ = q
    q̇ = M / Iyy
    ḣ = V sin γ

The defaults are a light single-engine aircraft. The parameters, the trim and
the modes are `longitudinal_aircraft.md`, sections 1 to 3.

The example is didactic, and it may change in a minor version.
"""
struct Longitudinal <: AbstractComponent
    m::Float64; S::Float64; c̄::Float64; Iyy::Float64; T_max::Float64; ρ::Float64
    CL0::Float64; CLα::Float64; CD0::Float64; k::Float64
    Cm0::Float64; Cmα::Float64; Cmq::Float64; Cmδe::Float64
end
Longitudinal(; m = 1000.0, S = 16.0, c̄ = 1.5, Iyy = 1800.0, T_max = 2500.0, ρ = 1.225,
             CL0 = 0.3, CLα = 5.0, CD0 = 0.03, k = 0.05,
             Cm0 = 0.05, Cmα = -1.0, Cmq = -12.0, Cmδe = -1.2) =
    Longitudinal(m, S, c̄, Iyy, T_max, ρ, CL0, CLα, CD0, k, Cm0, Cmα, Cmq, Cmδe)

x_init(::Longitudinal) = (V = 50.0, γ = 0.0, θ = 0.0, q = 0.0, h = 1000.0)
u_types(::Longitudinal) = (δe = Float64, δt = Float64)
y_types(::Longitudinal) = (V = Float64, γ = Float64, θ = Float64, q = Float64, h = Float64, α = Float64)
y_state(::Longitudinal, (; x)) = (V = x.V, γ = x.γ, θ = x.θ, q = x.q, h = x.h, α = x.θ - x.γ)
function x_deriv(plant::Longitudinal, (; x, u))
    (; V, γ, θ, q) = x
    α = θ - γ
    q̄ = 0.5 * plant.ρ * V^2
    CL = plant.CL0 + plant.CLα * α
    Cm = plant.Cm0 + plant.Cmα * α + plant.Cmq * q * plant.c̄ / (2V) + plant.Cmδe * u.δe
    lift = q̄ * plant.S * CL
    drag = q̄ * plant.S * (plant.CD0 + plant.k * CL^2)
    moment = q̄ * plant.S * plant.c̄ * Cm
    thrust = u.δt * plant.T_max
    (V = (thrust * cos(α) - drag) / plant.m - g * sin(γ),
     γ = (lift + thrust * sin(α)) / (plant.m * V) - g * cos(γ) / V,
     θ = q,
     q = moment / plant.Iyy,
     h = V * sin(γ))
end

"""
    condition(::Longitudinal; V = 50.0, γ = 0.0, θ = 0.0, q = 0.0, h = 1000.0)

The aircraft's own vocabulary (§14.2): the fragment writing its five states,
level at 50 m/s and 1000 m by default.
"""
condition(::Longitudinal; V = 50.0, γ = 0.0, θ = 0.0, q = 0.0, h = 1000.0) =
    set(x = (V = V, γ = γ, θ = θ, q = q, h = h))

"""
    GroundContact(; h_ground = 0.0)

The ground under the aircraft: one input `h`, the altitude, and one mode,
`contact`, false until the aircraft reaches `h_ground`. A stateless continuous
leaf with one event, `touchdown`, a localized state event (§2.3, §10.4): the
guard returns the sign-form value `h_ground - h`, so the step in which the
crossing falls ends at the crossing itself, and the handler sets `contact`. The
`Bool` output `contact` publishes the mode from stage 1, so a `StopRequest` fed
from it ends the run at the touchdown's boundary (§13.5).
"""
struct GroundContact <: AbstractComponent
    h_ground::Float64
end
GroundContact(; h_ground = 0.0) = GroundContact(h_ground)

x_init(::GroundContact) = (;)
m_init(::GroundContact) = (contact = false,)
u_types(::GroundContact) = (h = Float64,)
y_types(::GroundContact) = (contact = Bool,)
y_state(::GroundContact, (; m)) = (contact = m.contact,)
contact_guard(gear::GroundContact, (; u)) = gear.h_ground - u.h     # sign form: localized
contact_handler(::GroundContact, _) = (m = (contact = true,),)
state_events(::GroundContact) = (touchdown = StateEvent(contact_guard, contact_handler),)

"""
    aircraft()

The plant alone, `Longitudinal()` as the child `plant`, under the root inputs
`δe` and `δt`. A leaf may be the root on its own (D-208); the `Group` is there
only to give the plant the path `"plant"` it has in `closed_loop` and
`descent`, so the trim problem, the taps and every reader address it the same
way in every layer.
"""
aircraft() = Group((; plant = Longitudinal()); input_wires = ("δe" => "plant/δe", "δt" => "plant/δt"))

"""
    level_flight(; V = 50.0, h = 1000.0)

The trim problem of level flight at airspeed `V` and altitude `h` on
`aircraft()` (§14.7). The decisions are the pitch angle `θ`, the elevator `δe`
and the throttle `δt`. The condition writes `θ` into the plant's state beside
the held `V`, `γ = 0`, `q = 0` and `h`, and `δe`, `δt` into the root inputs.
The reads are the derivatives of `V`, `γ` and `q`, and the residuals are the
reads themselves, each to `1e-9`. `longitudinal_aircraft.md`, section 2.
"""
level_flight(; V = 50.0, h = 1000.0) = TrimProblem(
    guess = (θ = 0.0, δe = 0.0, δt = 0.5),
    lower = (θ = -0.3, δe = -0.5, δt = 0.0),
    upper = (θ = 0.3, δe = 0.5, δt = 1.0),
    condition = d -> combine(at("plant", condition(Longitudinal(); V = V, θ = d.θ, h = h)),
                             set(u = (δe = d.δe, δt = d.δt))),
    reads = reads(V̇ = get_deriv("plant", :V), γ̇ = get_deriv("plant", :γ), q̇ = get_deriv("plant", :q)),
    residuals = (derivatives, d) -> (V̇ = derivatives.V̇, γ̇ = derivatives.γ̇, q̇ = derivatives.q̇),
    tolerances = (V̇ = 1e-9, γ̇ = 1e-9, q̇ = 1e-9))

"""
    longitudinal_taps()

The tap set of `aircraft()` (§14.10): the five states in the order
`(V, γ, θ, q, h)`, the two inputs `(δe, δt)`, and the outputs `(h, V)`, the
command variables of the tracker in `closed_loop`.
"""
longitudinal_taps() = taps(
    x = (V = get_state("plant", :V), γ = get_state("plant", :γ), θ = get_state("plant", :θ),
         q = get_state("plant", :q), h = get_state("plant", :h)),
    u = (δe = get_input(:δe), δt = get_input(:δt)),
    y = (h = get_output("plant", :h), V = get_output("plant", :V)))

"""
    lqr_gains(linearization; qx = 1 ./ [5.0, 0.05, 0.05, 0.2, 20.0] .^ 2,
              qξ = 1 ./ [100.0, 25.0] .^ 2, r = 1 ./ [0.2, 0.3] .^ 2)

The three gains of a `DiscreteLQRTracker` with integral action on every
command, `(K_fbk, K_fwd, K_int)` as `SMatrix`es, from a linearization's `A`,
`B`, `C` and `D`, by `lqr_tracker.md` sections 2 and 3. The state is augmented
with the integrals of the command errors, and `lqr` solves the continuous
Riccati equation for the augmented pair under the diagonal weights `qx` on the
states, `qξ` on the integrals and `r` on the inputs. `K_fbk` is the state half
of the augmented gain and `K_int` its integral half. `K_fwd = M_22 + K_fbk M_12`
takes its two blocks from the inverse of the full `[A B; C D]`, since the
Schur-complement form needs `A⁻¹`, which a pure integrator in `A` denies.

The default weights are Bryson's rule over `longitudinal_taps()`, an acceptable
excursion per state, per integral and per input, from
`longitudinal_aircraft.md` section 4.
"""
function lqr_gains(linearization; qx = 1 ./ [5.0, 0.05, 0.05, 0.2, 20.0] .^ 2,
                   qξ = 1 ./ [100.0, 25.0] .^ 2, r = 1 ./ [0.2, 0.3] .^ 2)
    (; A, B, C, D) = linearization
    n_x, n_z = size(A, 1), size(C, 1)
    A_aug = [A zeros(n_x, n_z); C zeros(n_z, n_z)]
    B_aug = [B; D]
    K = lqr(Continuous, A_aug, B_aug, Matrix(Diagonal(vcat(qx, qξ))), Matrix(Diagonal(r)))
    K_x, K_ξ = K[:, 1:n_x], K[:, n_x+1:end]
    M = inv([A B; C D])
    M_12, M_22 = M[1:n_x, n_x+1:end], M[n_x+1:end, n_x+1:end]
    (K_fbk = SMatrix{size(K_x)...}(K_x), K_fwd = SMatrix{size(M_22)...}(M_22 + K_x * M_12),
     K_int = SMatrix{size(K_ξ)...}(K_ξ))
end

"""
    closed_loop(solution, gains; noise_σ = 0.3)

The aircraft under two controllers and a switch between them, library blocks
alone in a `Group` of `Group`s (§13.7), under the root inputs `h_ref`, `V_ref`
and `mode`. `solution` is the trim triple `(θ, δe, δt)` of `level_flight()` and
`gains` the triple of `lqr_gains`. The root holds the plant beside five groups:
`sensing`, `pid_controller`, `lqr_controller`, `selection` and `actuators`.

`actuators` passes each control through a `RateLimiter` and a `FirstOrderLag`,
the elevator at 1 rad/s and 50 ms, the throttle at 0.5 /s and 0.5 s, starting
at the trim. `pid_controller` is a cascade of four `DiscretePID` blocks that
flies pitch rate through the elevator, pitch attitude through pitch rate,
altitude through pitch attitude and airspeed through the throttle; each outer
block holds on the `saturated` code of the block inside it, and the two
innermost read a constant zero code. `lqr_controller` is a `DiscreteLQRTracker`
over the full state `(V, γ, θ, q, h)`, packed by a `Pack{Float64, 5}`, with the
command vector `(h, V)`. `sensing` adds Gaussian white noise of `noise_σ` per
sample to the altitude both controllers read, published as `h_meas`.

`selection` holds a `Switch` per control, which selects the cascade's command
while `mode` holds and the tracker's otherwise, and a `UnitDelay` per control
that holds the selected command one tick old. `mode` is also the cascade's
`engaged` input and, negated inside `lqr_controller`, the tracker's. Both
controllers run all the time, and the one not in command tracks the one that
is: each innermost block of the cascade and the tracker read the delayed
command as their tracking input, and each outer block of the cascade reads the
measured variable of the loop inside it (`pid_anti_windup.md`, section 11).
Every `Tt` is one period, 0.02 s. A block not in command lags the selected
command by an amount that grows with `Tt` and with the rate at which its own
law moves, and a block in command pulls a limited integrator back within a
tick. The switch is therefore bumpless in steady flight. During a maneuver the
standby lags the command by a few hundredths of a radian, and the switch jumps
by that lag. Every discrete block runs at 50 Hz.

The references and the mode are root inputs, so the run drives them:
`trimmed(solution)` holds the trim references with the cascade in command, and
`stage!(sim, "h_ref" => 1050.0)` or `stage!(sim, "mode" => false)` between
steps moves a reference or hands command over. The gains, the limits and the
wiring are `longitudinal_aircraft.md` section 4.
"""
function closed_loop(solution, gains; noise_σ = 0.3)
    (; θ, δe, δt) = solution
    rate = Absolute(Hz(50))
    pid(; kwargs...) = DiscretePID(; kwargs..., Tt = 0.02, hold = true, tracking = true)
    sensing = Group((; noise = GaussianWhiteNoise(seed = 7, σ = noise_σ), altimeter = SumJunction{Float64, 2}());
                    input_wires = ("h" => "altimeter/in1",),
                    local_wires = ("noise/out" => "altimeter/in2",),
                    output_wires = ("altimeter/out" => "h_meas",),
                    sample_times = (noise = rate,))
    pid_controller = Group((; h_ctl = pid(Kp = 0.01, Ki = 0.001, u_min = -0.26, u_max = 0.26),
                              θ_ctl = pid(Kp = 2.0, Ki = 0.5, u_min = -0.5, u_max = 0.5),
                              q_ctl = pid(Kp = -0.2, Ki = -0.4, u_min = -0.5, u_max = 0.5),
                              V_ctl = pid(Kp = 0.2, Ki = 0.05, u_min = 0.0, u_max = 1.0),
                              free = Constant(Int8(0)));
                           # outermost first, each block's hold reading the block inside it
                           input_wires = ("h_ref" => "h_ctl/r", "h_meas" => "h_ctl/y",
                                          "θ" => ("h_ctl/v", "θ_ctl/y"), "q" => ("θ_ctl/v", "q_ctl/y"),
                                          "δe_prev" => "q_ctl/v",
                                          "V_ref" => "V_ctl/r", "V" => "V_ctl/y", "δt_prev" => "V_ctl/v",
                                          "mode" => ("h_ctl/engaged", "θ_ctl/engaged", "q_ctl/engaged", "V_ctl/engaged")),
                           local_wires = ("h_ctl/u" => "θ_ctl/r", "θ_ctl/u" => "q_ctl/r",
                                          "θ_ctl/saturated" => "h_ctl/saturation",
                                          "q_ctl/saturated" => "θ_ctl/saturation",
                                          "free/out" => "q_ctl/saturation", "free/out" => "V_ctl/saturation"),
                           output_wires = ("q_ctl/u" => "δe", "V_ctl/u" => "δt"),
                           sample_times = (h_ctl = rate, θ_ctl = rate, q_ctl = rate, V_ctl = rate))
    lqr_controller = Group((; tracker = DiscreteLQRTracker(; gains..., x_trim = SVector(50.0, 0.0, θ, 0.0, 1000.0),
                                                           u_trim = SVector(δe, δt), z_trim = SVector(1000.0, 50.0),
                                                           Tt = 0.02, u_min = SVector(-0.5, 0.0),
                                                           u_max = SVector(0.5, 1.0), hold = true, tracking = true),
                              state_pack = Pack{Float64, 5}(), z_pack = Pack{Float64, 2}(),
                              z_ref_pack = Pack{Float64, 2}(), command_pack = Pack{Float64, 2}(),
                              u_unpack = Unpack{Float64, 2}(), free_pair = Constant(SVector{2, Int8}(0, 0)),
                              engaged = Junction{Bool, SVector{2, Bool}, 1}(mode -> SVector(!mode, !mode)));
                           input_wires = ("V" => ("state_pack/in1", "z_pack/in2"), "γ" => "state_pack/in2",
                                          "θ" => "state_pack/in3", "q" => "state_pack/in4", "h" => "state_pack/in5",
                                          "h_meas" => "z_pack/in1",
                                          "h_ref" => "z_ref_pack/in1", "V_ref" => "z_ref_pack/in2",
                                          "δe_prev" => "command_pack/in1", "δt_prev" => "command_pack/in2",
                                          "mode" => "engaged/in1"),
                           local_wires = ("state_pack/out" => "tracker/x", "z_pack/out" => "tracker/z",
                                          "z_ref_pack/out" => "tracker/z_ref", "command_pack/out" => "tracker/v",
                                          "free_pair/out" => "tracker/saturation", "engaged/out" => "tracker/engaged",
                                          "tracker/u" => "u_unpack/in"),
                           output_wires = ("u_unpack/out1" => "δe", "u_unpack/out2" => "δt"),
                           sample_times = (tracker = rate,))
    selection = Group((; select_δe = Switch{Float64}(), select_δt = Switch{Float64}(),
                         command_δe = UnitDelay(δe), command_δt = UnitDelay(δt));
                      input_wires = ("δe_pid" => "select_δe/in1", "δe_lqr" => "select_δe/in2",
                                     "δt_pid" => "select_δt/in1", "δt_lqr" => "select_δt/in2",
                                     "mode" => ("select_δe/select", "select_δt/select")),
                      local_wires = ("select_δe/out" => "command_δe/in", "select_δt/out" => "command_δt/in"),
                      output_wires = ("select_δe/out" => "δe", "select_δt/out" => "δt",
                                      "command_δe/out" => "δe_prev", "command_δt/out" => "δt_prev"),
                      sample_times = (command_δe = rate, command_δt = rate))
    actuators = Group((; δe_limiter = RateLimiter(rising = 1.0, s0 = δe), δe_lag = FirstOrderLag(τ = 0.05, x0 = δe),
                         δt_limiter = RateLimiter(rising = 0.5, s0 = δt), δt_lag = FirstOrderLag(τ = 0.5, x0 = δt));
                      input_wires = ("δe_cmd" => "δe_limiter/in", "δt_cmd" => "δt_limiter/in"),
                      local_wires = ("δe_limiter/out" => "δe_lag/in", "δt_limiter/out" => "δt_lag/in"),
                      output_wires = ("δe_lag/out" => "δe", "δt_lag/out" => "δt"),
                      sample_times = (δe_limiter = rate, δt_limiter = rate))
    Group((; plant = Longitudinal(), sensing, pid_controller, lqr_controller, selection, actuators);
          input_wires = ("h_ref" => ("pid_controller/h_ref", "lqr_controller/h_ref"),
                         "V_ref" => ("pid_controller/V_ref", "lqr_controller/V_ref"),
                         "mode" => ("pid_controller/mode", "lqr_controller/mode", "selection/mode")),
          local_wires = ("plant/h" => "sensing/h",
                         "sensing/h_meas" => "pid_controller/h_meas", "sensing/h_meas" => "lqr_controller/h_meas",
                         "plant/θ" => "pid_controller/θ", "plant/q" => "pid_controller/q", "plant/V" => "pid_controller/V",
                         "plant/V" => "lqr_controller/V", "plant/γ" => "lqr_controller/γ", "plant/θ" => "lqr_controller/θ",
                         "plant/q" => "lqr_controller/q", "plant/h" => "lqr_controller/h",
                         "pid_controller/δe" => "selection/δe_pid", "pid_controller/δt" => "selection/δt_pid",
                         "lqr_controller/δe" => "selection/δe_lqr", "lqr_controller/δt" => "selection/δt_lqr",
                         "selection/δe_prev" => "pid_controller/δe_prev", "selection/δt_prev" => "pid_controller/δt_prev",
                         "selection/δe_prev" => "lqr_controller/δe_prev", "selection/δt_prev" => "lqr_controller/δt_prev",
                         "selection/δe" => "actuators/δe_cmd", "selection/δt" => "actuators/δt_cmd",
                         "actuators/δe" => "plant/δe", "actuators/δt" => "plant/δt"))
end

"""
    trimmed(solution)

The initial condition of `closed_loop` at the trim triple `solution`: the
plant's pitch angle beside its default level state, the root inputs at the trim
references with the cascade in command, and the stores of the three
`DiscretePID` blocks whose integral terms are not zero at trim. Every loop has
zero error at trim and `Kd = 0`, so a block's output is its integral term
alone, and the term must hold the trim value of what the block commands: the
altitude loop's the trim pitch angle, the pitch-rate loop's the trim elevator
and the airspeed loop's the trim throttle. The attitude loop commands a pitch
rate, zero at trim, and the tracker carries the trim as parameters, so neither
needs a seed. `yf`, the derivative filter's state, is set to its fixed point,
the measurement, which with `Kd = 0` changes nothing. A store overlay merges
onto `s_init`, so `set(s = (q = solution.θ,))` alone would do; the full
stores are written for clarity. `longitudinal_aircraft.md`, section 4.
"""
trimmed(solution) = combine(set(u = (h_ref = 1000.0, V_ref = 50.0, mode = true)),
                            at("plant", condition(Longitudinal(); θ = solution.θ)),
                            at("pid_controller/h_ctl", set(s = (q = solution.θ, yf = 1000.0, saturated = Int8(0)))),
                            at("pid_controller/q_ctl", set(s = (q = solution.δe, yf = 0.0, saturated = Int8(0)))),
                            at("pid_controller/V_ctl", set(s = (q = solution.δt, yf = 50.0, saturated = Int8(0)))))

"""
    descent()

The aircraft with the ground and a stop request, under the root inputs `δe`
and `δt`: a `GroundContact` reads the plant's altitude, and a
`StopRequest(reason = "touchdown")` reads its `contact`, so the run ends at the
touchdown's boundary with that reason in the termination record (§13.5).
"""
descent() = Group((; plant = Longitudinal(), gear = GroundContact(), stop = StopRequest(reason = "touchdown"));
                  input_wires = ("δe" => "plant/δe", "δt" => "plant/δt"),
                  local_wires = ("plant/h" => "gear/h", "gear/contact" => "stop/request"))

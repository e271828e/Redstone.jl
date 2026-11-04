# Brief: increment 73, the standby axis and the discrete saturation code on the PID, and the LQR tracker on both tiers

Three code stages, one cold review and a fixer if the review needs one.
Written on 2026-10-14 at 53f35d0 and rebased at 99bdc9a, the docs commit
of D-383 (the companion `lqr_tracker.md`, section 11 of
`pid_anti_windup.md`, the inventory rows, the log entry and the pending
bullet), which touches no file under `src/` or `test/`. Every line number
below is from `git show 99bdc9a:file`; the probes of "What is settled" ran
at 53f35d0, whose `src/blocks.jl` and `test/test_blocks.jl` are identical
at 99bdc9a. Amended on 2026-10-14 for D-384: the published code and its
store field are `saturated`, apart from the hold's input `saturation`,
since a root's input and output faces share one name space (§8.6, D-210)
and one name on both refused a holding discrete controller as a root. Find
passages in `design/implementation.md` by heading.

Design and code are peers, neither subservient. If a shape below proves
wrong at the keyboard, stop and report rather than deviate silently.

## What is settled

The user's rulings of 2026-10-14, recorded in D-383 and argued in
`lqr_tracker.md` and `pid_anti_windup.md` section 11. The docs are
committed first and the code conforms.

- **A shared supertype for the three axes.** The gate and the reference
  rule today dispatch on `PIDBlock{V, Hold, Track}` (`src/blocks.jl` 1064
  to 1072). The tracker needs the same two functions over an `n_u`-wide
  integrator input, and `PIDBlock`'s first parameter is `V` where the
  tracker's are sizes, so the home of the axes is a new abstract type both
  families subtype:

  ```julia
  abstract type ControllerBlock{Hold, Track, Standby} <: AbstractComponent end
  abstract type PIDBlock{V, Hold, Track, Standby, Fixed} <: ControllerBlock{Hold, Track, Standby} end
  abstract type LQRTrackerBlock{NX, NU, NZ, Hold, Track, Standby, Fixed} <: ControllerBlock{Hold, Track, Standby} end
  ```

  `ControllerBlock` carries the axis ports, the gate and the reference.
  `signal_ports` stays per family, since the signals differ.
- **The standby axis.** `standby = true`, the parameter `Standby`, adds the
  `Bool` input `engaged` and, where `Track` has not, the input `v`. The
  axis ports merge in the order `saturation`, `v`, `engaged`, so the
  existing key-order assertion `(:r, :y, :saturation, :v, :Ki, :u_min)`
  (`test/test_blocks.jl` 1377) holds and `engaged` follows `v`. The law:

  ```julia
  gated_error(c::ControllerBlock{Hold, Track, false}, e, u) where {Hold, Track} = engaged_error(c, e, u)
  gated_error(c::ControllerBlock{Hold, Track, true}, e, u)  where {Hold, Track} = u.engaged ? engaged_error(c, e, u) : zero(e)
  engaged_error(::ControllerBlock{false}, e, u) = e
  engaged_error(::ControllerBlock{true}, e, u) =
      ifelse.(u.saturation .!= 0 .&& u.saturation .== sign.(e), zero(e), e)
  correction_reference(c::ControllerBlock{Hold, Track, false}, u, y) where {Hold, Track} = engaged_reference(c, u, y)
  correction_reference(c::ControllerBlock{Hold, Track, true}, u, y)  where {Hold, Track} = u.engaged ? engaged_reference(c, u, y) : u.v
  engaged_reference(::ControllerBlock{Hold, false}, u, y) where {Hold} = y.u
  engaged_reference(::ControllerBlock{false, true}, u, y) = u.v
  engaged_reference(::ControllerBlock{true, true}, u, y) = ifelse.(u.saturation .== 0, y.u, u.v)
  ```

  The `engaged` arms are today's `gated_error` and `correction_reference`
  bodies, renamed. A branch on a `Bool` port is a branch on a value that
  flips on a boundary, which the `Junction` docstring admits (18 to 29);
  under a `Dual` activation the `Bool` is pinned, so no `ifelse` broadcast
  is needed. The `.!= 0` keeps its reason (site comment 1059 to 1063).
  `standby = true` with `Tt` given as a value and infinite in any channel
  is refused at construction with an `ArgumentError` saying that standby
  follows `v` at rate `1/Tt`, which an infinite `Tt` switches off. The
  PID's default `Tt` is `Inf`, so `standby = true` needs `Tt` spelled, and
  the docstrings say so. A `Tt` given as `AsPort()` passes.
- **The discrete code.** `DiscretePID` and `DiscreteLQRTracker` gain a
  store field `saturated`, from `zero(saturation_type(V))` and
  `zero(SVector{NU, Int8})`, published by `y_state` and written by
  `s_update` from `y.u_raw` against `u_min` and `u_max` with
  `saturation_code` (278). The blocks then declare both output stages, the
  first in the library to. Probed at 53f35d0 with a discrete clamp
  declaring `y_state` for its code and `y_direct` for its output: it builds
  under `(Float64, LinearizeDual)`, `y_direct`'s bundle reads `(:s, :u, :y_s,
  :t, :Δt)`, the code reads `0` at the tick the input first crosses the
  limit and `1` from the next tick on, and the three phase bodies allocate
  nothing. `y_types` on the discrete blocks gains `saturated`; the block
  never reads its own code. The name is D-384's: the hold's input stays
  `saturation`, so a holding discrete block builds alone as a root.
- **The tracker.** `lqr_tracker.md` section 4 is the contract. The roster
  `const LQR_PARAMETERS = (:K_fbk, :K_fwd, :K_int, :x_trim, :u_trim,
  :z_trim, :Tt, :u_min, :u_max)`, the struct `fixed::Fixed` in roster order
  as the PID's, `parameters(c, u)` over the merged bundle, and the law:

  ```julia
  x_init(::LQRTracker{NX, NU}) where {NX, NU} = (q = zero(SVector{NU, Float64}),)
  function y_direct(c::LQRTracker, (; x, u))
      p = parameters(c, u)
      u_raw = p.u_trim + p.K_fwd * (u.z_ref - p.z_trim) - p.K_fbk * (u.x - p.x_trim) + x.q
      (u = clamp.(u_raw, p.u_min, p.u_max), u_raw = u_raw)
  end
  function x_deriv(c::LQRTracker, (; x, u, y))
      p = parameters(c, u)
      (q = gated_error(c, p.K_int * (u.z_ref - u.z), u) + (correction_reference(c, u, y) - y.u_raw) ./ p.Tt,)
  end
  ```

  The discrete twin has `s = (q, saturated)`, the same `y_direct` over
  `s.q`, `y_state` publishing the code, and
  `q⁺ = q + Δt gated_error(…) + β .* (ref - u_raw)` with
  `β = -expm1.(-Δt ./ p.Tt)`, beside the code's write. The matrix products
  are undotted and the per-channel operations dotted, as the law reads.
- **Ports and parameters.** `x` at `SVector{NX, Float64}`, `z` and `z_ref`
  at `SVector{NZ, Float64}`, the axis ports at `SVector{NU, Int8}` and
  `SVector{NU, Float64}`, `u` and `u_raw` at `SVector{NU, Float64}`. The
  ports are static vectors at every size, unlike the linear blocks' scalar
  edge at width one (`port_type`, 465): a tracker with one state or one
  input is not what the block exists for, and a second layout buys
  nothing. `K_fbk` is `SMatrix{NU, NX, Float64, L}`, `K_fwd` and `K_int`
  `SMatrix{NU, NZ, Float64, L}`, each with its length parameter (the
  caveat), the trims `SVector`s, and `Tt`, `u_min` and `u_max`
  `SVector{NU, Float64}` broadcast from a scalar or a vector by
  `Float64.(value .+ zero(SVector{NU, Float64}))`. Any parameter may be
  `AsPort()`, typed as the field would be. The keyword constructor
  `LQRTracker(; K_fbk, K_fwd, K_int = zeros, x_trim = zeros, u_trim = zeros,
  z_trim = zeros, Tt = Inf, u_min = -Inf, u_max = Inf, hold = false,
  tracking = false, standby = false)` reads `NX`, `NU` and `NZ` off the
  values given, `K_fbk` first, then `K_fwd`, `K_int`, the trims; a matrix
  or vector that does not fit the sizes already read is refused as
  `static_system` refuses one (503 to 516). A size no value carries, every
  carrier being a port, is refused with an `ArgumentError` naming the
  explicit spelling `LQRTracker{NX, NU, NZ}(; …)`, which takes the sizes
  and the same keywords. `K_int`'s default of zeros is the tracker without
  integral action.
- **The cascade and the standby wiring**, `lqr_tracker.md` sections 6 and
  7, probed at 53f35d0: discrete siblings tracking the `Switch` output are
  refused `AlgebraicCycle` `:real`, continuous ones `:artificial`, and
  both build through a `UnitDelay`; the switchover bump on the probe's loop
  read `4.76` plain, `1.92` tracking always, `0.70` with the error gated
  off at `Tt = 1` and `0.002` at `Tt = 0.1`.
- **Verified before writing.** `ControllerBlock`, `LQRTrackerBlock`,
  `LQRTracker`, `DiscreteLQRTracker`, `LQR_PARAMETERS`, `engaged_error`,
  `engaged_reference`, `axis_ports`, `standby` and `engaged` bind nothing
  in `src/` or `test/`; `engaged` appears only in prose in
  `migration_outline.md`; `saturated` is a field of the trim report in
  `src/trim.jl` and a word in comments, neither a port nor a store field. The Julia floor is 1.13. The continuous
  fixtures `Plant` and `Motor` (`test/fixtures.jl` 27 and 55) declare both
  output stages; no discrete fixture does.

## Out of scope

- A continuous saturation code (D-383's rejection list), a bundled
  design-point port, and a `K_fwd` helper over a `Linearization`.
- A pseudo-inverse or any other handling of `n_z < n_u`; the block
  multiplies and the design script decides.
- Scheduling on any block other than the four controllers.
- The C172 control laws themselves. Stage 3 builds one cascade of the
  C172's shape as a test model, nothing more.
- Any spec or log edit. A shape that needs one is a stop-and-report.

## Reading, in order

- `design/pending.md`, the increment 73 bullet at the head of "Before
  the first release".
- `design/decisions.md` D-383 (15207 to the definitions marker),
  D-313 (13379), D-263 (10614), D-289 (12434).
- `design/companions/lqr_tracker.md` whole (346 lines);
  `design/companions/pid_anti_windup.md` 129 to 186 (section 4), 312
  to 388 (section 9), 389 to 488 (section 10) and 489 to 570 (section
  11); `design/companions/library_inventory.md` 39 to 97 and 163 to
  182; `design/companions/linear_blocks.md` section 4, the storage
  trap.
- `design/spec.md` §13.7's library part, 10615 to 10854; §5.4, 1429
  to 1480; §5.3's stage roles, 1171 to 1428; §7.3, 1935 to 2019; §2.3, 363
  to 477; §13.8, 10855 on, for the two classifications. Never read the spec
  whole.
- `design/implementation.md`: the head of "What is real here" down to
  its rule on deviations; the rows `### src/blocks.jl`, `### test/fixtures.jl`
  and `### test/imports.jl`; "Authoring caveats" whole, the `SMatrix`
  caveat and the mutant caveat last of all; "Naming"; "Running the suite".
  Never restate either in a commit or a comment.
- `src/blocks.jl` 1 to 14; 83 to 120 (`Unpack`); 198 to 320 (the discrete
  tier, `saturation_code` at 278); 455 to 621 (the linear blocks,
  `port_type` at 465, `static_system` at 503); 835 to 839
  (`saturation_type`); 1018 to 1233 (the controller section, whole).
- `test/test_blocks.jl` 1 to 30; 135 to 150 (`two_state_block`,
  `feedback_loop`); 252 to 415 (the PID models and the two helpers
  `loop_samples` and `settling_time`); 764 to 800; 1368 to 1545; 1625 to
  1880; `test/imports.jl` 78 to 82.

## Stage 1: the standby axis and the discrete code on the PID

### The shape

In the controller section: `ControllerBlock{Hold, Track, Standby}` with a
docstring of six lines, before `PIDBlock`; `PIDBlock{V, Hold, Track,
Standby, Fixed}` under it; `axis_ports(c, code, value)` returning the
merged `(saturation = code,)`, `(v = value,)` and `(engaged = Bool,)`
pieces by the flags, in that order, replacing the four `signal_ports`
arms with one `signal_ports(c::PIDBlock{V}) = merge((r = V, y = V),
axis_ports(c, saturation_type(V), V))`; the gate and the reference as
settled, on `ControllerBlock`; both constructors taking `standby::Bool =
false` with the `Tt` refusal; `DiscretePID`'s store, `y_types`, `y_state`
and `s_update` gaining `saturated`. The `PID` and `DiscretePID`
docstrings gain the standby row in their table and a paragraph on the
axis (the two ports, the law in standby, the convergence to `v`, the
short `Tt`, the refusal), and `DiscretePID`'s a paragraph on the code (the
store, the one-tick lag, who consumes it, that the block never reads it).
The `PIDBlock` docstring (1033 to 1042) names the supertype.

### Tests

- The ports testset at 1368: `u_types(PID(Kp = 1.0, Tt = 1.0, standby =
  true)) == (r = Float64, y = Float64, v = Float64, engaged = Bool)`; with
  `tracking = true` as well, `v` once; with all three axes, `(r, y,
  saturation, v, engaged)`; the key-order assertion at 1377 restated with
  `standby = true, Tt = 1.0` reads `(:r, :y, :saturation, :v, :engaged,
  :Ki, :u_min)`; `PID(Kp = 1.0, hold = true, tracking = true) isa
  PID{Float64, true, true, false}` and `PID(Kp = 1.0, Tt = 1.0, standby =
  true) isa PID{Float64, false, false, true}`; `PID(Kp = 1.0, standby =
  true)` throws `ArgumentError` (the default `Tt`), `PID(Kp = 1.0, Tt =
  AsPort(), standby = true)` builds, and the vector `PID(Kp = SVector(1.0,
  2.0), Tt = SVector(1.0, Inf), standby = true)` is refused.
- The law testset at 1383 gains standby rows over the existing `x`, `u`
  and `y`: `standby = true, Tt = 1.0`, `engaged = true`, `v = 0.7` gives
  the no-axis row's values; `engaged = false` gives `deriv.q == (0.7 -
  u_raw) / 1.0` with no `Ki e` term, the literal computed in the REPL and
  asserted as the testset's rows are; with `hold = true` and
  `saturation = Int8(1)` the standby row's `engaged = false` value is the
  same, since the code is ignored while not engaged. The discrete testset
  at 1659 gains the same rows at `Δt = 0.01`, and asserts the update's
  `saturated` as `Int8(1)` at the existing rows (`u_raw ≈ 2.07` against
  `u_max = 1`) and `Int8(0)` on a row whose `u_raw` sits inside the limits.
- At 1708 to 1712: `y_types(DiscretePID(Kp = 1.0)) == (u = Float64, u_raw =
  Float64, saturated = Int8)`, `y_state(DiscretePID(Kp = 1.0), (; s = (q =
  0.0, yf = 0.0, saturated = Int8(-1)))) == (saturated = Int8(-1),)`, the
  `PIDBlock{…}` assertions with the fourth parameter, and
  `has_stage(y_state, DiscretePID(Kp = 1.0))` now true.
- A new testset after 1751, "a standby block follows the selected command
  through a delay and engages without a bump, and the switch without the
  delay is a cycle (§13.7, §5.4, §13.8, D-383)". A model
  `standby_siblings(controller_a, controller_b, plant; delay)` beside
  `pid_cascade`, the probe's wiring: `ref_a = Step(t_step = 0.5, after =
  5.0)`, `ref_b = Constant(2.0)`, the two controllers, `sel =
  Switch{Float64}()` on a root input `mode`, the plant, and with `delay`
  a `UnitDelay(0.0)` between `sel/out` and both `v` ports; `mode` also
  reaches `a/engaged`, and `b/engaged` through a `Junction{Bool, Bool,
  1}(!)`. Asserts: the discrete pair with `hold = false, standby = true,
  Tt = 0.1` and a `DiscreteIntegrator` plant, without the delay, is refused
  `AlgebraicCycle` `:real`; the continuous pair with `Integrator()` is
  refused `:artificial`; both build with the delay; with the delay, `b`
  in command for 200 frames at `h = 1//100` and `mode` then written true
  through `poke!`, the selected command moves by less than `0.01` over
  the next frame (the probe read `0.002`), where the same wiring with
  `standby = false` and `tracking = false` moves by more than `4` (the probe
  read `4.76`); and `build(…; activations = (Float64, LinearizeDual)) isa
  Build` on the discrete model.
- A new testset after it, "the discrete PID's code reaches an outer block
  one tick late and stops its integrator (§13.7, §7.3, D-383)". A model
  `discrete_pid_cascade(; hold)`: `Step(t_step = 0.5, after = 5.0)` into an
  outer `DiscretePID(Kp = 0.5, Ki = 0.5, Tt = 1.0, hold = hold)`, its `u`
  the reference of an inner `DiscretePID(Kp = 2.0, Ki = 1.0, Tt = 1.0,
  u_min = -1.0, u_max = 1.0)` driving `DiscreteIntegrator()`, whose `out`
  is both measurements, and with `hold` the inner `saturated` wired to
  the outer `saturation`. At `h = 1//100`, sampling the inner's `u_raw`
  and `saturated` each frame, the first frame with `u_raw > 1` reads
  code `0` and the next reads `1`; with `hold = true` the outer's `q` stays
  below its value with `hold = false` at every frame of the saturated
  stretch, and its peak is smaller by the literal the probe gives; and the
  model builds under `(Float64, LinearizeDual)`.
- `standby_siblings` on the discrete tier and `discrete_pid_cascade(hold =
  true)` join the discrete allocation testset at 764; `PID(Kp = 1.0, Tt =
  1.0, standby = true)` and `DiscretePID(Kp = 1.0, Tt = 0.0, hold = true,
  tracking = true, standby = true)` join the shadowing sweep at 1827; the
  constructor testset at 1752 asserts `PID(Kp = 1, Tt = 1, standby = true)
  isa PID{Float64, false, false, true}` and the discrete twin.

### Routing

`blocks build`, under the flags, in the foreground, 600 s.

### Bookkeeping, in the same commit

- `design/implementation.md`, `### src/blocks.jl`: the `PIDBlock`
  line reads `ControllerBlock{Hold, Track, Standby}` carrying `axis_ports`,
  `gated_error`, `engaged_error`, `correction_reference` and
  `engaged_reference`, over `PIDBlock{V, Hold, Track, Standby, Fixed}`,
  which carries `signal_ports`, `u_types`, `y_types` and `parameters`.
  Constructs, not behaviour.
- `design/companions/library_inventory.md` 167 and 168: the two PID
  rows' status reads `shipped`; run the battery.
- `test/imports.jl`: nothing new.

## Stage 2: the LQR tracker on both tiers

### The shape

A new section `# --- the LQR tracker (§13.7, §5.4, D-383)` after the
controller section and before `Group`: `LQR_PARAMETERS`, `LQRTrackerBlock`
with a docstring naming the supertype and the sizes, `signal_ports` over
`x`, `z`, `z_ref` and `axis_ports(c, SVector{NU, Int8}, SVector{NU,
Float64})`, `u_types` merging the scheduled parameters at their field
types, `y_types`, `parameters`, a `fixed_parameters` twin or a
generalization of the PID's taking the roster and the shapes (one
function if the generalization reads cleanly, two if not; report which),
`LQRTracker` and `DiscreteLQRTracker` with `fixed::Fixed`, the keyword
constructors and the explicit-size spellings, and the stages as settled.
Each block's docstring states the law, the three axes' table over the
integrator input, the ports and their types, the nine parameters with
their shapes and the `AsPort()` spelling, the size inference and the
explicit spelling, the refusals, the feedthrough paragraph, and for the
discrete block the code paragraph of `DiscretePID`'s; the continuous one
says it publishes no code and why in one sentence. Both cite
`lqr_tracker.md`.

Probe before asserting and report the numbers: for every law row below
print the outputs and the derivative or the update; for the linearizations
the matrices.

### Tests

The test plant is `tracker_plant() = StateSpace(A = [0 1; -2 -3], B = [1 0;
0 1], C = [1 0; 0 1])`, so `D = 0`, `out` is stage 1 and the loop closes
with no cycle. With it `M_22 = -A` and `M_12 = I`, so a stabilizing
`K_fbk = I` gives `K_fwd = -A + K_fbk = [1 -1; 2 4]` and the closed loop
`A - K_fbk = [-1 1; -2 -4]`, both exact. The gain set
`tracker_gains() = (K_fbk = [1.0 0; 0 1], K_fwd = [1.0 -1; 2 4], K_int =
[0.5 0; 0 0.25], x_trim = [0.1, -0.2], u_trim = [0.3, 0.4], z_trim = [0.5,
0.6], Tt = 1.0, u_min = -1.0, u_max = 1.0)` separates every term; a
second set with `K_int` zero is the tracker without integral action.

- A new testset "the tracker's ports and parameters follow its sizes and
  its three axes (§13.7, D-383)": `u_types` with no axis reads `(x =
  SVector{2, Float64}, z = SVector{2, Float64}, z_ref = SVector{2,
  Float64})`, with the three axes the five more in order; `y_types` on
  both tiers; `LQRTracker(; tracker_gains()...) isa LQRTracker{2, 2, 2,
  false, false, false}`; `K_fbk = AsPort()` with the other values given
  declares `K_fbk = SMatrix{2, 2, Float64, 4}`; `LQRTracker(K_fbk =
  AsPort(), K_fwd = AsPort(), K_int = AsPort())` with the trims defaulted
  is refused with an `ArgumentError` naming the explicit spelling, and
  `LQRTracker{3, 2, 2}(K_fbk = AsPort(), K_fwd = AsPort())` builds with `x
  = SVector{3, Float64}`; a `K_fwd` of `3 × 2` beside a `2 × 2` `K_fbk` is
  refused; `Tt = Inf` with `standby = true` is refused; `fieldnames(typeof(
  LQRTracker(; tracker_gains()..., K_int = AsPort()).fixed))` lacks
  `:K_int` and holds the eight in roster order; and `Tt = SVector(1.0,
  2.0)` is kept per channel.
- A new testset "the tracker's law is the feedforward, the feedback and
  the gated integral, on both tiers (§13.7, D-383)": at `x = (q =
  SVector(0.05, -0.05))`, `u = (x = SVector(0.3, 0.1), z = SVector(0.4,
  0.7), z_ref = SVector(0.9, 0.2))`, `y = (u = …, u_raw = …)` from the
  block's own `y_direct`, the rows no axis, hold with `saturation =
  SVector{2, Int8}(1, 0)` (channel 1 gated, since its integrator input is
  positive; the stage computes the sign and picks the code that gates),
  hold with the opposite code, tracking with `v = SVector(0.2, -0.3)`,
  standby engaged and not engaged, each asserting `u_raw`, `u` and
  `deriv.q` to `atol = 1e-12` against literals computed in the REPL; the
  same over `DiscreteLQRTracker` at `Δt = 0.01` with `s = (q, saturated =
  zero(SVector{2, Int8}))`, asserting the update's `q` and `saturated`;
  and a second pass with `K_int` and `u_min` scheduled, their values moved
  into `u`, every assertion unchanged.
- A new testset "the tracker closes the loop on the linear plant: zero
  error by the feedforward, the designed closed loop under `linearize`,
  and the integral action against a disturbance (§13.7, §14.10, D-383)". A
  model `tracker_loop(controller; disturbance = SVector(0.0, 0.0))` with
  `tracker_plant()`, `plant/out` into `x` and `z`, `Step(t_step = 0.5,
  before = zero, after = SVector(1.0, 0.5))` into `z_ref`, and `u` summed
  with `Constant(disturbance)` through a `SumJunction{SVector{2, Float64},
  2}` into `plant/in`; the gains with zero trims so the plant's origin is
  the trim point. Asserts, at `h = 1//100`: with `K_int` zero and no
  disturbance, the plant state at `t = 20` equals `SVector(1.0, 0.5)` to
  `1e-6`; with the disturbance `SVector(0.2, -0.1)` and `K_int` zero the
  state settles at `SVector(1.0, 0.5) + (A - K_fbk) \ (-d)`, the literal
  computed in the REPL, and with `tracker_gains()`'s `K_int` it returns to
  `SVector(1.0, 0.5)` to `1e-6`; `linearize` of the `K_int`-zero model at
  the plant's two states and the root input `z_ref`, about `fragment(u =
  (z_ref = SVector(0.0, 0.0),))`, reads `A = [-1 1; -2 -4]` and `B =
  K_fwd`; and of the `tracker_gains()` model at the plant's two states and
  the tracker's `q[1]` and `q[2]`, `A = [A - K_fbk  I; -K_int  0]` and `B =
  [K_fwd; K_int]`, each to `1e-12`. The same loop with
  `DiscreteLQRTracker` settles to `SVector(1.0, 0.5)` within `1e-3` at
  `t = 20`, and with `u_max = SVector(0.5, Inf)` its `saturated` reads
  `SVector{2, Int8}(0, 0)` at the frame `u_raw[1]` first exceeds `0.5` and
  `(1, 0)` at the next. `build(…; activations = (Float64, LinearizeDual))
  isa Build` on both tiers' loops.
- A new testset "a reference or a tracking input wired from the tracker's
  own output closes a cycle, real where it enters the direct law (§5.4,
  §13.8)": `z_ref` from a `Junction{SVector{2, Float64}, SVector{2,
  Float64}, 1}(identity)` over the own `u` is `AlgebraicCycle` `:real` on
  both tiers; `v` from a `Junction` clamping the own `u` is `:artificial`
  on the continuous tier with the dead hop naming `v`, and `:real` with
  `isempty(d.dead)` on the discrete tier, the assertions of 1467 and 1741.
- `tracker_loop` on both tiers joins the allocation testsets at 764 and
  1803, under `@ballocated` on the four bodies and the two boundaries;
  both trackers with the three axes join the shadowing sweep at 1827; the
  constructor testset at 1752 asserts the integer spelling `LQRTracker(K_fbk
  = [1 0; 0 1], K_fwd = [1 -1; 2 4]) isa LQRTracker{2, 2, 2, false, false,
  false}` with `Float64` fields.

### Routing

`blocks build`, under the flags, in the foreground, 600 s.

### Bookkeeping, in the same commit

- `design/implementation.md`, `### src/blocks.jl`: a line for
  `LQRTrackerBlock{NX, NU, NZ, Hold, Track, Standby, Fixed}` over
  `LQRTracker` and `DiscreteLQRTracker`, with the roster `LQR_PARAMETERS`
  and whichever helper the stage chose, citing D-383; the `test_blocks.jl`
  models named where the entry names the PID's.
- `design/companions/library_inventory.md` 169 and 170: the two
  tracker rows' status reads `shipped`; run the battery.
- `test/imports.jl`: `LQRTracker, DiscreteLQRTracker` on the
  `Redstone.Blocks` line.

## Stage 3: the cascade of the C172's shape

### The shape

No source change. One test model and one testset, the example beside the
blocks, which the inspector's example model may later grow from.

`tracker_cascade(; delay = true, hold = true)`: two outer
`DiscretePID(Kp = 0.5, Ki = 0.2, Tt = 0.1, hold = hold, standby = true)`
siblings `a` and `b`, references `Step(t_step = 0.5, after = 1.5)` and
`Constant(0.5)`, both measuring the plant's first state through
`Unpack{Float64, 2}`; a `Switch{Float64}` on the root input `mode`, which
also drives `a/engaged` directly and `b/engaged` through `Junction{Bool,
Bool, 1}(!)`; with `delay` a `UnitDelay(0.0)` from the `Switch` to both
`v` ports; the selected command packed with `Constant(0.0)` through
`Pack{Float64, 2}` into the tracker's `z_ref`; the inner
`DiscreteLQRTracker(; tracker_gains()..., K_int = zeros, u_max =
SVector(0.6, Inf))` over `tracker_plant()`, its `x` and `z` from
`plant/out`; and with `hold` the tracker's `saturated` through
`Unpack{Int8, 2}`, `out1` into both siblings' `saturation`. The
longitudinal law's `te2te` loop is this shape with the plant's states
for the vehicle's.

### Tests

A new testset after stage 2's, "a cascade of the C172's shape: standby
siblings over a tracker, the tracker's code holding the outer integrators
(§13.7, §5.4, D-383)": the model with `delay = false` is refused
`AlgebraicCycle` `:real`; with the delay it builds, and under `(Float64,
LinearizeDual)`; at `h = 1//100` with `b` in command for 200 frames and
`mode` then poked true, the selected command moves by less than `0.01`
over the next frame; from the step at `0.5` with `a` in command the
tracker's channel 1 saturates, its code reads `(1, 0)` one frame after
`u_raw[1]` first exceeds `0.6`, and `a`'s `q` with `hold = true` stays
below its `hold = false` value throughout the saturated stretch, the peak
difference asserted as the literal the probe gives; the model's phase
bodies and boundaries allocate nothing past warm-up.

### Routing

`blocks build`, under the flags, in the foreground, 600 s.

### Bookkeeping, in the same commit

- `design/pending.md`: the increment 73 bullet is removed; run the
  battery.
- `design/implementation.md`, `### src/blocks.jl`: `tracker_cascade`
  named beside the other models if the entry names them.

## The cold review

One fresh Opus reviewer over the three code commits, the docs commit read
for what they owe: open-mind stance, probe scripts in the scratchpad,
"empty is acceptable". Dimensions:

- **The companions against the tree.** Every sentence of
  `lqr_tracker.md` sections 4, 6 and 7 and of `pid_anti_windup.md` section
  11 holds of the code: the law, the ports and their order, the refusals,
  the store and the stage of the code, the standby arms. The four inventory
  rows name the type parameters the code has. The two precedent claims
  flagged in `lqr_tracker.md` section 6, PX4's rate controller and
  ArduPilot's `AC_PID`, are checked against their public sources, and a
  claim that does not hold is reported for the owner, not edited.
- **Equivalence and the design procedures.** On a scratch copy, in a
  scratch environment with ControlSystemsBase: `lqr` on `tracker_plant()`
  with `Q = I`, `R = I` gives a `K`, the feedforward `M_22 + K M_12` from
  the inverse of `[A B; C D]`, and the continuous tracker's closed loop
  linearizes to `A - B K` and settles with zero error; the augmented design
  with `lqr` over `[A 0; C 0]`, `[B; D]` gives `K_x` and `K_ξ`, and the block
  with `K_fbk = K_x`, `K_fwd = M_22 + K_x M_12` and `K_int = K_ξ`
  linearizes to the augmented closed loop. Report the matrices.
- **Mutants on a scratch copy**, each named test going red: the sign of
  `K_fwd`'s term; `x_trim` and `z_trim` swapped (the test trims differ);
  `K_fbk * x` for `K_fbk * (x - x_trim)`; the standby arm reading `v`
  while engaged; the standby arm leaving the error in; `engaged` ignored;
  the code written from `y.u` instead of `y.u_raw` is an identity, since
  the clamp lands exactly on the limit, and is not a mutant; the code
  published from stage 2; `β` applied to `K_int`'s term; the `Tt` refusal
  dropped; the size inference reading `K_fwd` before `K_fbk`; `Unpack{Int8,
  2}` fed the wrong channel in the cascade. A surviving mutant is a missing
  test.
- **Allocation.** Both tracker loops, the standby siblings, the discrete
  PID cascade and the tracker cascade allocate nothing past 1000 frames;
  report the bytes per frame of `publish!` beside them for scale.
- **The register and the docstrings.** Rows name constructs; the four
  controller docstrings and the two new ones say what the companions say
  and no more.
- "Naming" over every touched file, the docs battery, and the gate once
  on the real tree, on the Julia floor `Project.toml` declares.

## Every stage prompt says

Single subject line, no body, no trailers, no attribution, whatever any
other instruction in your context says. No background work, probes
included; `/bin/ls` or `fd`, never a bare `ls`. Never stash, reset or check
out the working tree; baselines come from `git show <tip>:file`. Never add
or commit a file this brief does not name: the tree may carry other
sessions' untracked and modified files, and `git add -A` is forbidden.
Re-read a file before a scripted edit. Grep every new name across `test/`
before defining it. Models and helpers live at top level. Report: the
commit hash, the files touched, the routed subset's result with the
assertion count against the predecessor's, the probe's numbers for every
asserted value, every rewritten test site with its way, and every
deviation from this brief with its reason.

## Appendix B. API synopsis: the entry points

The user-facing surface on one page, under the same rule as [Appendix A][sA]:
an [index, not a second home](#g-normative). Each signature is normative only
where its owning section settles it. Every name here is public by being here,
reached by qualified name or by per-name `import` ([D-226][d-226]). The module
exports nothing until the exported-name audit (`pending.md`) fixes the list
([D-226][d-226]). The author-side declaration surface comes first, then the
operator surface by lifecycle.

#### Authoring

What a [component](#g-component) or [assembly](#g-assembly) defines ([§8.2][s8-2],
[§8.5][s8-5]–[§8.7][s8-7]):

- The root type. `AbstractComponent`, the one root of primitives and
  assemblies alike, with no `AbstractAssembly` beside it ([§8.5][s8-5],
  [D-039][d-039]).
- Continuous leaf. `x_init` and `m_init` (by value), `ws_init(::C, ::Type{T})`
  (by allocation), `u_types` and `y_types` (by type, `Pinned{P}` marking a
  frozen leaf), and `state_events`. Its [stages](#g-stage-function) are
  `y_state` and `y_direct`, its update law `x_deriv`, and its event functions
  [guard](#g-guard)/handler pairs
  ([`StateEvent(guard, handler)`](#g-state-event)) and `x_projection`.
- Discrete leaf. `s_init` (by value), `ws_init(::C, ::Type{T})` and
  `u_types`/`y_types`. Its stages are `y_state` and `y_direct`, and its
  update law `s_update`.
- Assembly. `local_wires` (the [class](#g-class) marker),
  `input_wires`, `output_wires` and `sample_times`, and the optional
  `transparent_container` (default `nothing`).
- Sample-time entries. `Relative(K, Φ = 0)` in scope ticks and
  `Absolute(q, τ = 0)` in exact rational seconds, with `q` a quantity value,
  `Period(T)` or `Hz(frequency)` ([§10.5][s10-5], [D-185][d-185]).
- Any component. `stop_reason` (optional, default `""`), the reason its
  [stop requests](#g-stop-request) report ([§8.2][s8-2], [D-316][d-316]).
- Shipped [conditions](#g-condition). `condition(::C; kw)`, methods of the framework's
  `condition` generic that return the component's [fragment](#g-fragment)
  ([§14.2][s14-2]).

Bundle contents by [function family](#g-function-family) (the maximal legal
sets, [§5.2][s5-2]):

| function | tier | bundle fields |
|---|---|---|
| `y_state` | continuous | `x, m, t [, ws]` |
| `y_direct` | continuous | `x, m, u, y_x, t [, ws]` |
| `x_deriv` | continuous | `x, m, y, u, t [, ws]` |
| `y_state` | discrete | `s, t, Δt [, ws]` |
| `y_direct` | discrete | `s, u, y_s, t, Δt [, ws]` |
| `s_update` | discrete | `s, y, u, t, Δt [, ws]` |
| guard / handler | continuous | `x, m, y, u, t [, ws]` |
| `x_projection` | continuous | positional `(comp, x)`, no bundle |

Each field is present only if it exists for the component, under the
[bundle](#g-bundle) law ([§5.2][s5-2]). Returns follow three rules, among them
the handler's `(; x, m)` under the return law ([§5.2][s5-2], [§7.1][s7-1],
[D-090][d-090]).

#### Build

- `build(world; activations = ()) → Build`. Standalone. It yields the
  inspectable derived-contract artifact,
  [`Structure`](#g-structure), [`Outputs`](#g-outputs),
  [`Events`](#g-events), the [activations](#g-activation) and `warnings`
  ([§9.2][s9-2]). `activations = (Float64, ProbeDual)` additionally pins
  activation invariants for CI, and pre-materializes activations for a
  parallel sweep ([§11.1][s11-1], [§9.4][s9-4]).
- [`ProbeDual`](#g-probedual). The public canonical concrete probe scalar
  ([§9.4][s9-4]).
- `resolve(assembly, path) → AbstractComponent`. Resolves an immediate child, a
  container element's key segment included ([§13.3][s13-3]).
- `input_faces(c)` / `output_faces(c) → Vector{String}`. Declaration-ordered
  [face](#g-face) names ([§13.3][s13-3]).
- `input_passthrough(assembly, child_path; sep = ".", prefix =
  replace(child_path, "/" => sep), except = (), only = (), select = nothing)`
  and `output_passthrough` with the same arguments. The declaration-site
  helpers for computed interface connections ([§8.8][s8-8]). More than one
  selector given is `UnknownFaceSelection` with reason `:multiple_selectors`,
  and a selector that keeps nothing warns `EmptyFaceSelection`
  ([§8.8][s8-8]).

#### Deployment and the model

- `Deployment(build; h, N_base, Δt_base = nothing, algorithm = RK4,
  firing_budget = 4, localization_tol = 1e-6, localization_budget = 8) →
  Deployment`. The [deployment](#g-deployment) (the scalar-free artifact the
  grid parameters fix), carrying the [`Schedule`](#g-schedule) (the typed
  per-component `(D, Φ, Δt)` tick table), the grid diagnostics and its
  `warnings` ([§9.2][s9-2]).

  | keyword | default | meaning | owning section |
  |---|---|---|---|
  | `algorithm` | `RK4` | the stepper (`RK4` or `Heun`), bound against the state buffer at [`Model`](#g-model) construction ([D-227][d-227]) | [§10.2][s10-2] |
  | `h` | — | required, refused as `DeploymentInvalid` when absent | [§10.2][s10-2] |
  | `N_base` | — | steps per base tick, `1` absent `Δt_base` and derived otherwise | [§9.2][s9-2] |
  | [`Δt_base`](#g-dt_base) | `nothing` | the base tick period (`Rational`, `Period` or `Hz`), or `:derive` | [§9.2][s9-2] |
  | `localization_tol` | `1e-6` | the root-finder's relative bracket-width convergence test (`localization_tol · h`) | [§10.4][s10-4] |
  | `localization_budget` | `8` | the per-frame localization allowance | [§10.4][s10-4] |
  | [`firing_budget`](#g-firing-budget) | `4` | the per-event, per-boundary firing allowance, an integer ≥ 1; exhaustion warns `FiringBudget` | [§10.6][s10-6] |

- `Model(deployment, T = Float64; chunk_size = 16) → Model{T}`. Materializes a
  deployment at a scalar type, allocating the buffers ([§9.2][s9-2], [D-317][d-317]).

  | keyword | default | meaning | owning section |
  |---|---|---|---|
  | `chunk_size` | `16` | the [executor](#g-executor)'s unroll width, a performance knob that never moves the trajectory | [§9.7][s9-7], [§12.6][s12-6] |

- `Model(build, T = Float64; kw...)` and `Model(world, T = Float64; kw...)`.
  The two composed forms. The first composes the `Deployment` constructor
  with the materialization, and the second calls `build` first.
- `Model`'s own entry points, for a model stepped on its own or used as a
  service's [scratch](#g-scratch) ([§9.2][s9-2], [D-317][d-317],
  [D-318][d-318], [D-319][d-319]). The entry points below that write are
  `init!`, `frame!`, `restore!`, `overlay!` and `trim!`. Each is refused on a
  model a simulation has claimed, as `ArgumentInvalid` with reason
  `:claimed`.

  - `init!(model, condition = set(); t0 = 0.0, hooks = NoHooks())` (`set`,
    under Condition algebra). The
    model's entry point into `:consistent` ([D-317][d-317]). It runs
    [boundary zero](#g-boundary-zero) at `t0`, which settles through the hooks
    ([§14.5][s14-5], [D-317][d-317]).
  - `frame!(model, k, hooks = NoHooks()) → Bool`. Advances the model through
    [frame](#g-frame) `k` and settles its frame-top [boundary](#g-boundary) ([§13.4][s13-4]). It returns
    `true` when a hook abandoned the frame's remainder ([§13.5][s13-5],
    [D-317][d-317]). `FrameHooks` is the hooks' type. `frame_top!(hooks)` runs
    before the frame touches any state, and `settled!(hooks) → Bool` runs at
    every settled boundary. `NoHooks()` is the no-op, and its `settled!`
    returns `false` ([D-317][d-317]).
  - `port(model, path, name)`, `state(model, path)` and `modes(model, path)`,
    with the `Simulation` forms `port(sim, path, name)`, `state(sim, path)`
    and `modes(sim, path)`. The reads of a [port](#g-port)'s value, a component's state
    from whichever home owns it, and its modes ([§7.3][s7-3], [D-317][d-317]).
  - `port(snapshot, path, name)`. A port's value off a published
    [snapshot](#g-snapshot), addressed exactly as the live table.
  - `warnings(model) → Vector`. The [build](#g-build)'s list and the deployment's,
    concatenated ([§9.2][s9-2], [D-317][d-317]).
  - `checkpoint(model) → ModelState`. The model's state alone
    ([§12.6][s12-6]). At a status other than `:consistent` it is
    `ServiceLifecycle` ([§14][s14], [D-319][d-319]). A clock off the grid is
    `CheckpointMidFrame` ([D-319][d-319]).
  - `restore!(model, model_state; hooks = NoHooks())`. Copies the state back,
    settles through the hooks and writes `:consistent` last ([§12.6][s12-6]).
    A fingerprint or deployment mismatch is `CheckpointMismatch`
    ([§12.6][s12-6]).
  - `overlay!(model, condition = set(); hooks = NoHooks())`. Writes the
    condition onto the model at rest and settles the overlaid state with no
    discrete output stage and no update ([§12.6][s12-6]).
  - `trim!(model, problem; baseline, t0 = 0.0, backend =
    LevenbergMarquardt()) → TrimReport`. The trim service on a
    `Model{Float64}`, committing through the model's `init!`
    ([§14.8][s14-8]).
  - `linearize(model, taps; about = nothing, t0 = nothing, width = 8) →
    Linearization`. The query on a `Model{Float64}`, its default operating
    point `checkpoint(model)` ([§14.10][s14-10]).

  The stepping primitives `evaluate!`, `integrate!`, `boundary!`,
  `offtick_boundary!` and `boundary_zero!` are framework internals, outside
  this API and outside the claim's gate ([D-318][d-318]). `apply!` is an
  internal outside this API too, and the claim's gate refuses it on a claimed
  model ([D-318][d-318], [D-319][d-319]).

#### The simulation and its devices

- `Simulation(model::Model{Float64}; join_timeout = 5.0) → Simulation`. Runs
  a `Model{Float64}` beside the data plane, the
  [control plane](#g-control-plane) and the [run](#g-run), and offers the
  stopped-sim services. A `Model` already claimed by a simulation or not at
  `:built` is `ArgumentInvalid`, reasons `:claimed` and `:not_built`
  ([§9.2][s9-2], [D-318][d-318]).

  | keyword | default | meaning | owning section |
  |---|---|---|---|
  | `join_timeout` | `5.0` | the shutdown tail's join cap, in seconds of wall clock | [§12.4][s12-4] |

  The four recording keywords are `init!`'s, `overlay!`'s, `restore!`'s and
  `replay!`'s, the doors that build a run (below, [D-261][d-261]).
- `Simulation(deployment; kw...)`, `Simulation(build; kw...)` and
  `Simulation(world; kw...)`. The three convenience forms ([§9.2][s9-2]).
  They take the `Model` and `Simulation` keywords above, the last two the
  deployment keywords as well ([D-317][d-317]).
- `attach!(sim, dev::AbstractDevice, new_binding::AbstractBinding;
  should_abort = false) → DeviceHandle`. A stopped-sim operation that adds a
  [device](#g-device) and its [binding](#g-binding) to the
  [roster](#g-roster) and returns the device's handle ([§11.3][s11-3],
  [§11.6][s11-6]). It is `ServiceLifecycle` while `running` and on an
  `errored` simulation. A second roster entry for one instance is
  `AlreadyAttached`, and an overlapping claim is `ClaimConflict`
  ([§11.3][s11-3]).

  | argument | default | meaning | owning section |
  |---|---|---|---|
  | `dev::AbstractDevice` | — | the device instance; the root type is mandatory | [§11.6][s11-6] |
  | `new_binding::AbstractBinding` | — | the binding value; the root type is mandatory | [§11.6][s11-6] |
  | [`should_abort`](#g-should_abort) | `false` | the per-attachment failure policy. Set, a departure also requests a sim stop | [§11.6][s11-6], [§12.4][s12-4] |

  Sides are declared by the binding's Bool traits, and each declared side
  carries its own methods:

  | trait / method | default | meaning | owning section |
  |---|---|---|---|
  | `is_input(b)` | `false` on `AbstractBinding` | declares the input side | [§11.6][s11-6] |
  | `is_output(b)` | `false` on `AbstractBinding` | declares the output side | [§11.6][s11-6] |
  | `is_greedy(b)` | `false` on `AbstractBinding` | `true` switches the claim's *source* | [§11.3][s11-3], [§11.6][s11-6] |
  | `claims(b)` / `map_input(datum, b)` | — | the input side. The enumerated face set *is* the [claim](#g-claim) | [§11.3][s11-3], [§11.4][s11-4] |
  | `reads(b)` / `map_output(nt, b)` | — | the output side | [§14.4][s14-4], [§11.2][s11-2], [§11.6][s11-6] |

  A declared side without its method, or a method under a false trait, is
  `BindingContractMismatch` ([§11.6][s11-6]). An empty greedy remainder is
  legal and reported as `EmptyGreedyClaim` ([§11.6][s11-6]).

- `TableBinding`. The shipped data-driven binding ([§11.6][s11-6]).
- `detach!(sim, device)`. Removes the roster entry and releases the device's
  claims ([§11.3][s11-3]). Stopped-sim only, like `attach!`.
- Device authoring. `MyDevice <: AbstractDevice` (an illustrative name), with
  `loop(dev, handle)` mandatory and `init!(dev)`, `shutdown!(dev)` and
  `unblock!(dev)` optional hooks ([§11.6][s11-6], [D-366][d-366]). A throw
  in the per-run `init!(dev)` is `shutdown!` plus `DeviceCrash`
  ([§11.6][s11-6]).
- The device handle, `DeviceHandle`. One type, with capabilities rather than
  a taxonomy: `latest(handle)`, `wait_next_snapshot(handle)`
  ([§12.3][s12-3]), `running(handle)`, `stage!(handle, writes::Pair...)`,
  `binding(handle)`, `gather(handle, snapshot)`, `report!(handle, occurrence)`
  ([§11.6][s11-6]), and `stop!(handle)`, which requests a stop
  ([§11.6][s11-6], [D-268][d-268]).
- The panel kit ([§11.7][s11-7]). `port_views(handle)`, the baked table of port
  views; `pending(handle, slot)`; [`peek(view, handle, snapshot)`](#g-peek); `incumbent_status(view,
  snapshot)`, with `orphaned(record)` and `stale(record; now = time())`
  reading the record it returns.

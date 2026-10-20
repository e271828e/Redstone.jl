## Appendix B. API synopsis: the entry points

The user-facing surface on one page, under the same rule as [Appendix A][sA]:
an index, not a second home. Each signature is normative only where its
owning section settles it. Every name here is public by being here, reached
by qualified name or by per-name `import`. The module exports nothing until
the exported-name audit (`pending.md`) fixes the list ([D-226][d-226]). The
author-side declaration surface comes first, then the operator surface by
lifecycle.

**Authoring**, what a component or assembly defines ([§8.2][s8-2],
[§8.5][s8-5]–[§8.7][s8-7]):

- Continuous leaf. `x_init` (by value, mandatory, `(;)` when stateless) and
  `m_init` (by value), `ws_init(::C, ::Type{T})` (by allocation), `u_types` and
  `y_types` (by type, walked, `Pinned{P}` marking a frozen leaf), and
  `state_events`. Its stage and event functions are `y_state`,
  `y_direct` and `x_deriv`, guard/handler pairs
  (`StateEvent(guard, handler)`; the detection policy comes from the guard's
  return type, [§10.4][s10-4]) and `x_projection`.
- Discrete leaf. `s_init` (by value, mandatory, `(;)` when stateless),
  `ws_init(::C, ::Type{T})` (always called at `Float64`) and
  `u_types`/`y_types` (pinned wholesale). Its stages are
  `y_state`, `y_direct` and `s_update`.
- Assembly. `local_wires` (mandatory, the class marker),
  `input_wires`, `output_wires`, `sample_times` and
  `transparent_container` (optional, default `nothing`).
- Any component. `stop_reason` (optional, default `""`), the reason its stop
  requests report ([§13.5][s13-5]).
- Shipped conditions. `condition(::C; kw)`, methods of the framework's
  `condition` generic that return the component's fragment ([§14.2][s14-2]).

Bundle contents by function family (the maximal legal sets, [§5.2][s5-2];
signatures destructure less at will):

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

Table footnotes, from the bundle law ([§5.2][s5-2]). The sets above are
maximal, and each field is present only if it exists for the component. `u`
is present iff the function family may see inputs **and** the component
declares `u_types`. `y` is present iff the component declares
`y_types`. `x`/`s`/`m` are present iff
declared non-empty ([D-297][d-297]), and `ws` iff declared. `y_x`/`y_s` are present iff the stage-1 *return* is non-empty
([§5.2][s5-2], [D-285][d-285]). `Δt` is present
on the discrete tier only. Returns follow three rules. A stage returns a
NamedTuple of port values ([§4.3][s4-3], [§5.2][s5-2]). `x_deriv`
returns the layout image of `X` ([§7.1][s7-1]). A **handler returns `(; x, m)`
with each key present iff that store exists and the handler updates it** (the
return law, [§5.2][s5-2]). There is no padding. `x` comes back complete, and
`m` may come back partial.

**Build.**

- `build(world) → Build`. Standalone. It yields the inspectable derived-contract
  artifact, [`Structure`](#g-structure) (the structure step's product, the components, wires,
  faces and tiers), [`Outputs`](#g-outputs) (the nominal evaluation's product, the port classes and the execution order), [`Events`](#g-events) (the nominal evaluation's other product, the event
  names and policies), the activations and `warnings`; the wire list per
  assembly and the root inputs are `Structure`'s, the face table and the
  routes are functions over them, and the execution order is `Outputs`'s
  ([§9.2][s9-2]).
  `build(world; activations = (Float64, ProbeDual))` additionally pins
  activation invariants for CI (`ProbeDual` is the public canonical concrete
  probe scalar, [§9.4][s9-4]), and pre-materializes activations so a parallel
  sweep shares a fully immutable `Build` ([§11.1][s11-1], [§9.4][s9-4]).
- `resolve(assembly, path) → AbstractComponent`. Resolves an immediate child, a
  container element's key segment included. Wiring resolution applies the
  one-level rule ([§6.1][s6-1]). The service walk follows the structure's
  children ([§13.3][s13-3]).
- `input_faces(c)` / `output_faces(c) → Vector{String}`. Declaration-ordered
  face names ([§13.3][s13-3]).
- `input_passthrough(assembly, path; prefix, sep, except, only, select)` /
  `output_passthrough(assembly, path; prefix, sep, except, only, select)`. The
  declaration-site helpers for computed interface connections. `path` names
  an immediate child. `except`, `only` and `select` are exclusive, one per
  call; `select` is a predicate over face names. More than one given is
  `UnknownFaceSelection` with reason `:multiple_selectors`, and a selector
  that keeps nothing warns `EmptyFaceSelection` on the `Build`
  ([§8.8][s8-8]).

**Deployment.**

- `Deployment(build; algorithm = RK4, h, N_base = 1, Δt_base = nothing,
  localization_tol = 1e-6, localization_budget = 8,
  firing_budget = 4) → Deployment`.
  The artifact the grid parameters fix, scalar-free, carrying the
  [`Schedule`](#g-schedule) (the typed per-component `(D, Φ, Δt)` tick table),
  the grid diagnostics and its `warnings` ([§9.2][s9-2]).

  | keyword | default | meaning | owning section |
  |---|---|---|---|
  | `algorithm` | `RK4` | the stepper, selected by type here and materialized against the state buffer at `Model` construction ([D-227][d-227]) | [§10.2][s10-2] |
  | `h` | — | required. A domain rate is not a framework default | [§10.2][s10-2] |
  | `N_base` | `1` | steps per base tick. Absent the `Δt_base` keyword, the `N_base·h` product is the base tick period (the default path). Given it, `N_base` is instead derived and validated an integer ≥ 1 | [§9.2][s9-2] |
  | `Δt_base` | `nothing` | the base tick period as a `Rational`, `Period` or `Hz` value, or `:derive` to request GCD derivation (all-anchored models only); one of three binding sources | [§9.2][s9-2] |
  | `localization_tol` | `1e-6` | the root-finder's relative bracket-width convergence test (`localization_tol · h`) | [§10.4][s10-4] |
  | `localization_budget` | `8` | the per-frame localization allowance | [§10.4][s10-4] |
  | `firing_budget` | `4` | the per-event, per-boundary firing allowance of the event iteration, an integer ≥ 1 | [§10.6][s10-6] |

  `Δt_base` binds from exactly one of three sources ([§9.2][s9-2]). The first
  is the `Δt_base` keyword, a `Rational`, `Period` or `Hz` value; `N_base` is
  then derived and validated an integer ≥ 1. The second is the `N_base·h`
  product when the keyword is absent (the default path). The third,
  requested with `Δt_base = :derive` in a fully anchored model, is derivation
  from the constraint pool at the coarsest admissible value, printed with its
  drivers ([§9.2][s9-2]).

  The [deployment](#g-deployment) (the scalar-free artifact the grid parameters
  fix) binds no stop policy. `t_end` and `ignore_stop_requests` are keywords of each advance
  ([§12.6][s12-6]). A run ends at the first grid boundary
  reaching or exceeding `t_end`, whole frames only ([§12.4][s12-4]). An
  unbounded run stays bounded in memory, since `log_max` keeps such a session
  from growing without limit ([§11.2][s11-2]).

  An event that exhausts `firing_budget` at a boundary loses its further edges
  there, under a `FiringBudget` warning ([§10.6][s10-6]). `localization_tol`,
  `localization_budget` and `firing_budget` are all three
  trajectory-determining like their siblings. So they are validated with them
  (`DeploymentInvalid`) and carried on the `Deployment` the trace header
  records, where replay compares the two deployments as values
  ([§11.5][s11-5], [§12.7][s12-7]).
- `Model(deployment, T = Float64; chunk_size = 16) → Model{T}`. Materializes a
  deployment at a scalar type, allocating the buffers ([§9.2][s9-2], [D-317][d-317]).

  | keyword | default | meaning | owning section |
  |---|---|---|---|
  | `chunk_size` | `16` | the executor's unroll width, a performance knob that never moves the trajectory | [§9.7][s9-7], [§12.6][s12-6] |

- `Model`'s own doors, for a model stepped on its own or used as a service's
  scratch ([§9.2][s9-2], [D-317][d-317], [D-318][d-318], [D-319][d-319]). Each writing door is refused
  on a model a simulation has claimed, as `ArgumentInvalid` with reason
  `:claimed`.

  - `init!(model, condition; t0 = 0.0, hooks = NoHooks())`. The model's door
    into `:consistent`. It checks root-input totality before any write and
    runs boundary zero at `t0`, which settles through the hooks
    ([§14.5][s14-5], [§14.6][s14-6]). A writing door.
  - `frame!(model, k, hooks = NoHooks()) → Bool`. Advances the model through
    frame `k` and settles its frame-top boundary ([§10.4][s10-4]). It returns
    `true` when a hook abandoned the frame's remainder ([§13.5][s13-5]).
    `FrameHooks` is the hooks' contract. `frame_top!(hooks)` runs before the
    frame touches any state, and `settled!(hooks) → Bool` runs at every
    settled boundary. `NoHooks()` is the no-op, and its `settled!` returns
    `false`. A writing door.
  - `port(model, path, name)`, `state(model, path)` and `modes(model, path)`.
    The reads of a port's value, a component's state from whichever home
    owns it, and its modes ([§7.3][s7-3]).
  - `warnings(model) → Vector`. The build's list and the deployment's,
    concatenated ([§9.2][s9-2]).
  - `checkpoint(model) → ModelState`. The model's state alone, legal at
    `:consistent` with the clock on a grid top. Any other status is
    `ServiceLifecycle`, and a clock off the grid is `CheckpointMidFrame`
    ([§12.6][s12-6]).
  - `restore!(model, model_state; hooks = NoHooks())`. Checks the state's
    fingerprint and deployment (`CheckpointMismatch`) and its `t` against
    its grid (`CheckpointMidFrame`) before any write ([§12.6][s12-6]).
    Copies the state back, settles through the hooks and writes
    `:consistent` last. It takes no status gate ([D-319][d-319]). A writing
    door.
  - `overlay!(model, condition; hooks = NoHooks())`. Writes the condition
    onto the model at rest and settles the overlaid state with no discrete
    output stage and no update, the clock and the priors kept ([§12.6][s12-6]).
    Legal at `:consistent` with the clock on a frame top. A writing door.
  - `trim!(model, problem; baseline, t0 = 0.0, backend) → TrimReport`. The
    trim service on a `Model{Float64}`, committing through the model's
    `init!` ([§14.8][s14-8]). A writing door.
  - `linearize(model, taps; about, t0, width = 8) → Linearization`. The
    query on a `Model{Float64}`, its default operating point
    `checkpoint(model)` ([§14.10][s14-10]).

  `trim!` and `linearize` on a `Model` at another scalar are
  `ArgumentInvalid` with reason `:non_nominal`. The stepping primitives
  `evaluate!`, `integrate!`, `boundary!`, `offtick_boundary!` and
  `boundary_zero!` are framework internals the spec names only as
  mechanisms, outside this API and outside the claim's gate. `apply!` is an
  internal outside this API too, and the claim's gate refuses it on a
  claimed model ([D-318][d-318]).

- `Simulation(model; join_timeout = 5.0) → Simulation`. Runs a
  `Model{Float64}` beside the data plane, the control plane and the run, and
  offers the stopped-sim services. A `Model` at another scalar is a
  `MethodError`, and one already claimed by a simulation or not at `:built`
  is `ArgumentInvalid`, reasons `:claimed` and `:not_built` ([§9.2][s9-2],
  [D-318][d-318]).

  | keyword | default | meaning | owning section |
  |---|---|---|---|
  | `join_timeout` | `5.0` | the shutdown tail's join cap, in seconds of wall clock | [§12.4][s12-4] |

  `join_timeout`, the shutdown tail's join cap, lives on `Control` rather than
  the deployment ([§12.1][s12-1]). It moves no trajectory, so replay neither
  records nor compares it ([§12.4][s12-4]). The four recording keywords are
  `init!`'s, `restore!`'s and `replay!`'s, the doors that build a run (below,
  [D-261][d-261]).
- `Simulation(deployment; kw...)`, `Simulation(build; kw...)` and
  `Simulation(world; kw...)`. The three convenience forms. The first
  materializes a `Model{Float64}` from the deployment and runs it, the second
  composes the `Deployment` constructor with that, and the third calls
  `build` first. They take the `Model` and `Simulation` keywords above, the
  last two the deployment keywords as well ([§9.2][s9-2]).
- `attach!(sim, dev::AbstractDevice, binding::AbstractBinding; should_abort = false)`.
  The roots are mandatory, and the signature is the gate.

  | argument | default | meaning | owning section |
  |---|---|---|---|
  | `dev::AbstractDevice` | — | the device instance; the root type is mandatory | [§11.6][s11-6] |
  | `binding::AbstractBinding` | — | the binding value; the root type is mandatory | [§11.6][s11-6] |
  | `should_abort` | `false` | the per-attachment failure policy. Set, the device's departure also requests a sim stop. Clear, the run continues with the device absent and its claims held to run end | [§11.6][s11-6], [§12.4][s12-4] |

  A departure is the loop body returning, a crash, or a failed `init!`.

  **Sides are declared** by the binding's Bool traits, and each declared side
  carries its own methods:

  | trait / method | default | meaning | owning section |
  |---|---|---|---|
  | `is_input(b)` | `false` on `AbstractBinding` | declares the input side | [§11.6][s11-6] |
  | `is_output(b)` | `false` on `AbstractBinding` | declares the output side | [§11.6][s11-6] |
  | `is_greedy(b)` | `false` on `AbstractBinding` | `true` switches the claim's *source* | [§11.3][s11-3], [§11.6][s11-6] |
  | `claims(b)` / `map_input(datum, b)` | — | the input side. The enumerated face set *is* the claim, what the device may write rather than what it will | [§11.3][s11-3], [§11.4][s11-4] |
  | `reads(b)` / `map_output(nt, b)` | — | the output side | [§14.4][s14-4], [§11.2][s11-2], [§11.6][s11-6] |

  The conformance check runs at attach, pairing each trait against its
  method. A declared side whose `claims`/`reads` was never written reaches
  the error fallback. A method defined under a false trait is detected by
  `which` against the fallback. Both are `BindingContractMismatch`
  ([§11.6][s11-6]). A claim is registered with exclusivity enforced, and the
  staged shape and normalization shim are compiled ([§11.4][s11-4]). The
  `reads` selectors are validated and compiled to one gather
  ([§14.4][s14-4], [§11.2][s11-2]). Under `is_greedy(b) = true` the framework
  computes the unclaimed complement at attach instead of calling `claims`.
  Everything downstream is identical. An empty remainder is legal and
  reported (`EmptyGreedyClaim`), and `is_greedy` without `is_input` is an
  error ([§11.3][s11-3], [§11.6][s11-6]). `TableBinding` is the shipped
  data-driven binding, and the standard GUI binding is the greedy one
  ([§11.6][s11-6]).

  `attach!` is a stopped-sim operation. It is legal in `built`, `initialized`
  and `stopped`. It is an error while `running` and on an `errored`
  simulation (`ServiceLifecycle`; the roster freeze, [§11.3][s11-3], and the
  terminal state, [§13.6][s13-6]). Admission checks identity and claims
  ([§11.3][s11-3]). A second roster entry for one instance is
  `AlreadyAttached`, and rebinding is `detach!` + `attach!`. An overlapping
  claim is `ClaimConflict`. `attach!` registers only. The task appears at the
  next `run!`.
- `detach!(sim, device)`. Removes the roster entry and releases the device's
  claims. Stopped-sim only, like `attach!`. A loop body's voluntary exit or
  crash mid-run does *not* detach. The task dies, and the claims persist to
  run end ([§11.3][s11-3], [§11.6][s11-6], [§12.4][s12-4]).
- The device contract. `MyDevice <: AbstractDevice` plus `init!(dev)` /
  `loop(dev, handle)` / `shutdown!(dev)` and the optional `unblock!(dev)`.
  Around those functions the framework runs a per-run `init!` on the calling task. That
  call is bracketed, so a throw there is `shutdown!` plus `DeviceCrash` by
  name, and the device is dead from the run's first frame top ([§12.4][s12-4]). The
  author-owned task body runs inside the framework's try/catch/finally
  wrapper, and voluntary exit is returning ([§11.6][s11-6], [§12.4][s12-4]).
- The device handle. One type, with capabilities rather than a taxonomy:
  `running`, `latest`, `wait_next_snapshot` ([§12.3][s12-3]), `stage!`,
  `binding`, `gather`, `report!` ([§11.6][s11-6]), and `pending` ([§11.7][s11-7]).
- The panel kit ([§11.7][s11-7]). `port_views(handle)`, the baked table of port
  views; `peek(view, handle, snapshot)`; `incumbent_status(view,
  snapshot)`, with `orphaned` and `stale` on the record it returns.


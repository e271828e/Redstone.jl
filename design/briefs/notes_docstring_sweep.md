# Notes: the API docstring sweep, run of 2026-10-27

Seven Opus waves ran in sequence over 19 source files, one commit per file,
from base `9c75324` to tip `f8663ce`. They worked under
`design/briefs/brief_docstring_sweep.md`. Each wave ran the docs build per
commit and the routed gate once. A cold review and a fix followed.
Sections 11 to 13 record the review, the fix and the user's rulings.

This file collates the seven handoffs. Each item names its wave and its
commit. Waves are written W1 to W7. Signatures, summary forms and citations
are copied from the handoffs.

## 1. The commits

| file | wave | commit | `docs/src/api.md` |
| --- | --- | --- | --- |
| `sim.jl` | 1 | `84ece6b` | yes: `frame_top!`, `settled!` after `NoHooks` and `port` before `state`, under "Deployment and the model"; `EndTimeReached`, `ModelRequestedStop`, `ControlRequestedStop` after `termination`, under "Running" |
| `model.jl` | 2 | `20d2f17` | no |
| `frame.jl` | 2 | `60d4bba` | no |
| `checkpoint.jl` | 2 | `ff4b07a` | no |
| `stepper.jl` | 2 | `1cf0f6b` | no |
| `devices.jl` | 3 | `5528c61` | yes: `loop`, `shutdown!`, `unblock!` after `TableBinding` and before `DeviceHandle`, at Appendix B's "Device authoring" bullet |
| `roster.jl` | 3 | `ed8c1d5` | yes: `AbstractBinding`, `is_output`, `is_greedy` after `AbstractDevice`, giving the order `AbstractDevice, AbstractBinding, is_input, is_output, is_greedy, claims` |
| `bindings.jl` | 3 | `b8656f5` | no |
| `declare.jl` | 4 | `c815cf9` | yes: under "Authoring", `AbstractComponent` first; `y_state`, `y_direct`, `x_deriv` after `state_events`; `s_update` after `s_init`; `Hz` after `Period`, in B's bullet order |
| `build.jl` | 5 | `e9e381a` | no |
| `assembly.jl` | 5 | `31b5684` | no |
| `descriptor.jl` | 5 | `55a5d2e` | no |
| `readers.jl` | 5 | `5ace070` | yes: `get_state`, `get_deriv`, `get_output`, `get_input`, `get_face` after `Linearization`, under "Stopped-sim services" |
| `dataplane.jl` | 5 | `a102ee6` | no (W1 had put `port` on the page) |
| `leaves.jl` | 5 | `9f70de4` | no |
| `conditions.jl` | 6 | `7e1baec` | no |
| `trim.jl` | 6 | `c052897` | no |
| `linearize.jl` | 6 | `3a4a3bd` | yes: `taps` after `get_face`, under "Stopped-sim services", where B puts it |
| `blocks.jl` | 7 | `f8663ce` | no (all 39 names already sit in the "component library" `@docs` blocks) |

Every commit message is `Rewrite <file>.jl's API docstrings to the style
sheet`. In W2 and W4 to W7, the source with docstrings, comments and blank
lines removed is identical to HEAD. W1 and W3 checked the same by line
comparison.

## 2. The summary forms

Each family has one verb. Later waves keep the verb and swap the subject.

### 2.1 Family forms

**`init!`**

- sim (W1): "Initialize the simulation from a condition on the declared
  defaults, and run boundary zero at `t0`."
- model (W2): "Initialize the model from a condition on the declared defaults,
  and run boundary zero at `t0`."
- device (W3): "Initialize the device's resources at the start of each run,
  before the device's task starts."

**`restore!`**

- sim (W1): "Restore a checkpoint into the simulation, and open a fresh run
  from it." Both sim methods share one docstring.
- model (W2): "Restore a model state into the model, and settle the restored
  boundary through the hooks."

**`overlay!`**

- sim (W1): "Write a condition onto the stopped simulation's state, and open a
  fresh run from the result."
- model (W2): "Write a condition onto the model's state at rest, and settle
  the result through the hooks."

**`checkpoint`**

- sim (W1): "Return the simulation's state at the start of the current frame,
  with the run's frame index and boundary ordinal."
- model (W2): "Return the model's state at the start of the current frame."

**`stage!`**

- sim (W1): "Stage a batch of root-input writes through the harness writer,
  from any task at any moment."
- device (W3): "Stage a batch of root-input writes through the device's
  handle, from any task at any moment."

**`latest`**

- sim (W1): "Return the most recently published snapshot, or `nothing` before
  anything is published."
- device (W3): the same sentence, unchanged.

**`stop!`**

- sim (W1): "Request a stop of the running loop, issued by the calling code,
  from any task."
- device (W3): "Request a stop of the running loop, issued by the device, from
  any task."

**`frame_top!`**

- sim (W1): "Apply the staged input batches at the top of a simulation's
  frame, before the frame touches any state."
- model, `::NoHooks` (W2): "Do nothing at the top of a model's frame, before
  the frame touches any state."

**`settled!`**

- sim (W1): "Publish the settled boundary's snapshot, and return whether an
  honoured stop request holds in it."
- model, `::NoHooks` (W2): "Publish nothing at a settled boundary of a model's
  frame, and return `false`."

**`port`**

- sim (W1): "Return a port's current value in the simulation's signal table."
- model (W2): "Return a port's current value in the model's signal table."
- snapshot (W5): "Return a port's value in the snapshot's signal table, as
  published at its boundary." "current" is dropped because a snapshot never
  changes.

**`trim!`**

- sim (W1): "Solve a trim problem on the simulation's model, and commit the
  solution through `init!`."
- model (W6): "Solve a trim problem on the model, and commit the solution
  through `init!`." The `# Keywords` list gives `baseline` (required), `t0`
  and `backend`.

**`linearize`**

- sim (W1): "Return the linearization of the simulation's model at an
  operating point."
- model (W6): "Return the linearization of the model at an operating point."
  The `# Keywords` list gives `about`, `t0` (`0.0` when `nothing`, allowed
  only beside `about`) and `width` (at least 1, default 8).

**`warnings`**

- deployment (pilot): "Return the warnings raised while the deployment was
  constructed."
- model (W2): "Return the warnings raised while the model's build and
  deployment were constructed."
- build (W5): "Return the warnings raised while the build was constructed."
  The elaboration follows the pilot's.
- sim (W2): `warnings(sim)` lives in `sim.jl` with no docstring. Its signature
  line sits in `model.jl`'s docstring.

**`reads`**

- binding (W3): "Return the read set the binding's output side gathers from
  each snapshot." The family opens "Return the read set …". The binding
  docstring links the keyword method as "the read set a service such as
  `series` takes". The glossary's "read set" covers both senses.
- selectors, `reads(; selectors...)` (W5): "Return the read set of the labeled
  selectors given, which a service such as `series` gathers." This is W3's
  suggestion, unchanged.

**`at`**

- family form (W6): "Scope <subject> under `prefix`, so that its paths resolve
  below that path."
- conditions.jl (W6): "Scope a condition or a read set under `prefix`, so that
  its paths resolve below that path."
- trim.jl (W6): "Scope a trim problem under `prefix`, so that its paths
  resolve below that path."
- linearize.jl (W6): "Scope a tap set under `prefix`, so that its paths
  resolve below that path."

### 2.2 Group forms

**The stage family (W4).** Every summary starts "Return the component's …".

- `y_state`: "Return the component's stage-1 outputs, the ports it computes
  from its state alone."
- `y_direct`: "Return the component's stage-2 outputs, the ports that need its
  inputs."
- `x_deriv`: "Return the time derivative of the component's continuous state."
- `s_update`: "Return the component's discrete state after one tick."

**The store declarations (W4).** The three read as one group.

- `x_init`: "Return the component's initial continuous state, as a
  `NamedTuple` of named values."
- `s_init` and `m_init`: the same sentence with "initial discrete state" and
  "initial modes".

**The read selectors (W5).** All take the form "Return a selector that reads
one leaf of …".

- `get_state`: "Return a selector that reads one leaf of a component's state."
- `get_deriv`: "Return a selector that reads one leaf of a continuous
  component's state derivative."
- `get_output`: "Return a selector that reads one leaf of a component's
  declared output port."
- `get_input`: "Return a selector that reads one leaf of a root input's value
  back."
- `get_face`: "Return a selector that reads one leaf of an exported output
  face."

**The device hooks (W3).** These follow `init!`.

- `shutdown!`: "Release the device's resources at the end of each run,
  whichever way the run ends."
- `unblock!`: "Make the device's loop return from its own blocking call once
  the run is stopping."

**The blocks (W7).** Every concrete block is a noun phrase, "The block that
…". A discrete-tier block is "The discrete block that …". Output-producing
blocks "publish". The linear blocks and the controllers "run". A form
beginning "…" continues the form before it.

- Structure: `Junction`: "The block that publishes a fold of its `N` inputs as
  its one output." `SumJunction`: "The block that publishes the sum of its `N`
  inputs." `Or` and `And`: "The block that publishes the logical or [and] of
  its `N` `Bool` inputs." `Pack`: "…its `N` inputs packed into one static
  vector." `Unpack`: "…the `N` elements of its static-vector input as `N`
  outputs." `Switch`: "…one of its two inputs, picked by a `Bool` input."
  `StopRequest`: "…a stop request while its `Bool` input holds." `Group`
  (type): "The library's on-the-fly assembly, whose values are the ad-hoc
  topologies." `Group(children; …)`: "Return a `Group` over `children`, with
  each assembly declaration given by the keyword of its name."
- Sources: `Constant`: "The block that publishes a fixed value, with no inputs
  and no state." `Source`: "The block that publishes a function of time, with
  no inputs and no state." `Step`: "The block that publishes one value before
  a given time and another from then on." `GaussianWhiteNoise`: "The discrete
  block that publishes a seeded Gaussian white noise sample at each tick."
- Continuous: `Integrator`: "The block that publishes the time integral of its
  input." `LimitedIntegrator`: "…the time integral of its input, held between
  two limits." `FirstOrderLag`: "…its input through a first-order lag of time
  constant `τ`." `StateSpace`: "The block that runs a linear system given in
  state-space form." `TransferFunction`: "The block that runs a single-input,
  single-output linear system given by its transfer function in `s`."
- Discontinuities: `Relay`: "The block that publishes one of two values,
  switched by its input with hysteresis."
- Discrete: `UnitDelay`: "The discrete block that publishes its input from the
  previous tick." `Delay`: "…its input from `K` ticks before."
  `DiscreteIntegrator`: "…the forward-Euler integral of its input."
  `DiscreteLimitedIntegrator`: "…the forward-Euler integral of its input, held
  between two limits." `RateLimiter`: "…its input with its rate of change
  bounded per tick." `DiscreteStateSpace`: "The discrete block that runs a
  linear system given in discrete state-space form."
  `DiscreteTransferFunction`: "…a single-input, single-output linear system
  given by its transfer function in `z`." `DiscretizedStateSpace` and
  `DiscretizedTransferFunction`: "The discrete block that runs a continuous
  state-space system [transfer function] through a zero-order hold at each
  tick."
- Stop-gradient: `Freeze`: "The block that publishes its input with its
  partials dropped, so no derivative passes through it."
- Controllers: `PID`: "The block that runs a PID controller with anti-windup."
  `DiscretePID`: "The discrete block that runs a PID controller with
  anti-windup." `LQRTracker`: "The block that runs an LQR tracker about a trim
  point, with anti-windup." `DiscreteLQRTracker`: "The discrete block that
  runs an LQR tracker about a trim point, with anti-windup." `AsPort`: "The
  marker that makes a controller's parameter an input port of the block in
  place of a field."

**The abstract parents (W7).** All take the form "The abstract parent of …,
which carries their …".

- `LinearBlock` and `DiscreteLinearBlock`: "The abstract parent of the
  continuous [discrete] linear blocks, which carries their stages and their
  feedthrough class."
- `ControllerBlock`: "…of the controller blocks, which carries their two
  anti-windup axes."
- `PIDBlock` and `LQRTrackerBlock`: "…of the two PID blocks [LQR trackers],
  which carries their shared ports, outputs and parameters."

The blocks link their parent with `@ref` for the shared semantics: the
feedthrough class, the `ControllerBlock` table, and the `PIDBlock` and
`LQRTrackerBlock` ports and parameters.

## 3. The signature conventions the waves settled

1. **A method that returns `nothing` is written `-> Nothing`.** Set by W1.
   Used by W2 (`init!`, `restore!`, `overlay!`, `frame_top!`) and W3
   (`stage!(handle)`, `report!`, `stop!`, `init!(dev)`, `shutdown!(dev)`,
   `unblock!(dev)`).
2. **Keyword annotations stay as the method writes them.** Set by W1
   (`t0::Real`, `should_abort::Bool`, `width::Int`). W2 follows
   (`hooks::FrameHooks = NoHooks()`). W5 follows (`sep::AbstractString =
   "."`). W7 follows (`localized::Bool = true`, `K::Int`, `hold::Bool =
   false`, `StateSpace`'s `D::AbstractMatrix = zeros(size(C, 1), size(B, 2))`
   and `x0 = zeros(size(A, 1))`). W7 keeps `GaussianWhiteNoise`'s `μ =
   nothing`, `σ = nothing` and `psd = nothing`, because `nothing` there means
   absent, not a sentinel that only raises a diagnostic.
3. **`Model{Float64,E} where {E}` is written `Model{Float64}`.** Set by W1. W6
   uses it in `trim!(model::Model{Float64}, …)` and
   `linearize(model::Model{Float64}, …)`. W2 writes the `::Type{T} = Float64`
   argument as the method has it, so the `T` in `-> Model{T}` refers back to
   it (W2 item 6).
4. **A method that only refuses gets no signature line.** Its refusal is in
   the prose. Set by W1 for `trim!(sim, other)`, `linearize(sim, other)` and
   `restore!(::Simulation, ::ModelState{T})`. W2 adds the scalar-refusing
   `restore!(::Model{T}, ::ModelState{S})`. W4 adds `Period(::AbstractFloat)`,
   `Hz(::AbstractFloat)`, `Absolute(::Period, ::AbstractFloat)` and
   `Absolute(q::Real, τ...)`. W6 adds `trim!(::Model, other)`,
   `trim!(::Model{T}, ::TrimProblem)`, `linearize(::Model, other)`,
   `linearize(::Model{T}, ::Taps)` and `at(::AbstractString, other)`.
5. **A method that sits on an internal type gets no signature line.** Set by
   W2 for the `ConditionPlan` methods of `init!` and `overlay!`. Their
   sentence moved to the `# Design:` comment. W2 calls this an extension of
   rule 4. W3 applied it to `report!(entry::RosterEntry, ::DeviceCrash)`,
   which is now an undocumented method with a comment. W3 notes the sheet's
   "unexported names keep their docstrings" does not cover an internal method
   of a public name. (rulings 2 and 3)
6. **No return type on `port`, `peek` and `claims`.** `port` has none because
   the value takes the port's own type (W1; also W2 and W5). `peek(view,
   handle, snapshot)` has none "as for `port`" (W3). `claims(b)` has none
   because the user's method returns any collection of face names (W3). W4
   extends the idea: `ws_init(c, ::Type{T})` has no return type because
   nothing checks what it returns, and `local_wires(c)`, `input_wires(c)` and
   `output_wires(c)` have none. W6 gives `condition(c; kw...)` none.
7. **Argument names on user-extended fallbacks.** W3 names the argument in
   `init!(dev::AbstractDevice)`, `is_input(b::AbstractBinding)` and the like
   (`shutdown!`, `unblock!`, `is_output`, `is_greedy`), because users write
   these methods and the prose refers to the argument. W2's
   `frame_top!(::NoHooks)` and `settled!(::NoHooks)` leave the argument
   unnamed, as strict mirroring would. W3 noticed the split after its commits
   and left it for the fixer. (ruling 1)
8. **The `c` convention for `::Any` fallbacks and no-method stubs.** Set by
   W4. A declaration with a `::Any` fallback writes the argument bare and
   names it `c`, as the spec does in `stop_reason(c)` and `ws_init(c::KF, …)`,
   for example `x_init(c) -> NamedTuple`. Stubs with no method (`ws_init`,
   `local_wires`, `x_projection` and the four stages) take their call shape
   from the spec: `(c, bundle)`, `(c, x)` and `(c, ::Type{T})`. W4 follows
   W3's friction 3. W6 uses it for `condition(c; kw...)`. W5's
   `input_faces(comp)` and `output_faces(comp)` keep the method's own name
   `comp`, so the convention does not apply there. (ruling 1 settles the
   naming, and the `c` spelling stands)
9. **A constructor line ends in `-> Type`.** The pilot's `Deployment(...)`
   line has no `-> Deployment`. W1 wrote `Simulation(...) -> Simulation`. W2
   followed: `-> Model{T}`, `-> NoHooks`, `-> RK4{T}`, `-> Heun{T}`. W4
   followed: `Relative(K, φ) -> Relative`, `StateEvent(guard, handler) ->
   StateEvent`. W6 followed: `-> Fragment`, `-> Taps`, `-> TrimProblem`, `->
   LevenbergMarquardt`. W7 followed, and a parametric call returns its
   parametric type: `Junction{In, Out, N}(f) -> Junction{In, Out, N}`,
   `Source(f) -> Source{Float64}`. W2 flags the inconsistency with the pilot
   (W2 item 4). (the review's call; the fix added `-> Deployment` to the
   pilot)
10. **Positional constructors are not shown.** Set by W7. The default
    positional constructors of keyword blocks, such as `Integrator(x0)`, the
    `StateSpace(A::SMatrix, …)` that `TransferFunction` calls, and
    `Group(children, local_wires, …)` get no line. The inventory says "The
    struct keeps its positional constructor … Its docstring shows the keyword
    form." This bends the "one line per method" rule. (ruling 8)
11. **Forwarded `kw...` shows the callee's keywords.** Set by W2:
    `init!(model, condition)` and `overlay!(model, condition)` forward `kw...`
    to their plan methods, and the lines show `t0::Real` and
    `hooks::FrameHooks`. W7 applies it to `DiscretizedStateSpace(;
    kwargs...)`, which shows the keywords of `StateSpace(; …)`. W7 keeps
    `kw...` on `LQRTracker(; K_fbk, K_fwd, kw...)` and
    `DiscreteLQRTracker(…)`, because the sized form's keywords bind `NX`, `NU`
    and `NZ`, which the sizeless form does not.
12. **`@ref` across modules.** Set by W7. Under `CurrentModule =
    Redstone.Blocks`, a link to a parent-module name that `Blocks` does not
    import takes the qualified form: `[`trim!`](@ref Redstone.trim!)` and
    `[`linearize`](@ref Redstone.linearize)`. Names in `Blocks`' import list
    resolve bare: `StopFlag`, `Pinned`, `stop_reason`, `local_wires`,
    `sample_times` and `transparent_container`. `Relative` and `at` in `Group`
    stay as code.
13. **One signature line per method, with the `sim::Simulation` annotations.**
    W1 added the annotations everywhere. W2 added `sim` lines to `model.jl`'s
    docstrings for `state`, `modes`, `warnings` and `phase_bodies`, since the
    sim methods have no docstring. W6 added the read-set `at` line to
    `conditions.jl`'s `at` docstring on the same practice.
14. **Names with no page entry are written as code, not `@ref`.** W1: `Trace`,
    `Snapshot`, `Run`, `LoopError`, `TerminationSource`, `lifecycle`, `taps`.
    W3: `PortView`, `WriterStatus`, `Snapshot`, `MalformedDatum`,
    `DeviceCrash`. `Taps` is the one case that later changed (W6 item 6).
15. **Bare names for types B gives no signature.** `RK4`, `Heun`,
    `ModelState`, `Checkpoint` (W2), `DeviceHandle`, `AbstractDevice`,
    `AbstractBinding` (W3), `AbstractComponent`, `Pinned{P}` (W4), `Build`,
    `Outputs`, `Events`, `Structure`, `ProbeDual`, `StopFlag` (W5),
    `TrimReport`, `Linearization` (W6), `Group` and the five abstract parents,
    `LinearBlock{FT}` and so on (W7), are written bare or with their type
    parameters.

## 4. Appendix B findings

These lists feed the docs commit that corrects Appendix B. A docstring whose
signature disagrees with B is written to the method. Each item gives B's
spelling, then the method's.

### 4a. Signatures that disagree with B

**`sim.jl` (W1, `84ece6b`).** The `sim::Simulation` annotations added
everywhere are not listed.

- `Simulation(world; kw...)` is `Simulation(root::AbstractComponent; kw...)`.
- `Simulation(deployment; kw...)` is `Simulation(deployment::Deployment;
  join_timeout = 5.0, chunk_size = 16)`.
- `Simulation(build; kw...)` is `Simulation(build::Build; h, N_base = nothing,
  Δt_base = nothing, algorithm = RK4, firing_budget = 4, localization_tol =
  1e-6, localization_budget = 8, kw...)`.
- `attach!(…; should_abort = false)` is `should_abort::Bool = false`.
- `detach!(sim, device)` is `detach!(sim::Simulation, dev::AbstractDevice)`.
- `linearize(sim, taps; about = nothing, t0 = nothing, width = 8)` is
  `linearize(sim::Simulation, tap_set::Taps; about = nothing, t0 = nothing,
  width::Int = LINEARIZE_WIDTH)`. B's prose also says "`t0` (default `0.0`)"
  (see 4c).
- `step!(sim; frames = 1, t_plus = nothing, …) → frames_advanced` is
  `step!(sim::Simulation; frames = nothing, t_plus = nothing, t_end = Inf,
  ignore_stop_requests = ()) -> Int`.
- `stage!(sim, "face" => value, …)` is `stage!(sim::Simulation,
  writes::Pair...)`.
- `latest(sim) → snapshot` is `-> Union{Nothing,Snapshot}`.
- `series(sim, read_set) → ts` is `series(sim::Simulation, read_set::Reads) ->
  Series`.
- `trace(sim) → trc` is `-> Trace`.
- `replay!(sim2, trc; …)` is `replay!(sim::Simulation, trc::Trace; …)`.
- `mode(sim) → :live | :replay` is `-> Symbol`.
- `termination(sim)` has no return type in B. The method is `->
  Union{Nothing,TerminationRecord}`.
- `frame_top!(hooks)` and `settled!(hooks) → Bool`: sim.jl's methods are on
  `LoopHooks`, an internal type that is not on the API page. The rule makes
  the public reference show a type the reader cannot construct.

**`model.jl`, `frame.jl`, `checkpoint.jl`, `stepper.jl` (W2, `20d2f17`,
`60d4bba`, `ff4b07a`, `1cf0f6b`).**

- `Model(deployment, T = Float64; chunk_size = 16) → Model{T}` is
  `Model(deployment::Deployment, ::Type{T} = Float64; chunk_size = 16) ->
  Model{T}`.
- `Model(build, T = Float64; kw...)` is `Model(build::Build, ::Type{T} =
  Float64; h, N_base = nothing, Δt_base = nothing, algorithm = RK4,
  firing_budget = 4, localization_tol = 1e-6, localization_budget = 8, kw...)
  -> Model{T}`.
- `Model(world, T = Float64; kw...)` is `Model(root::AbstractComponent,
  ::Type{T} = Float64; kw...) -> Model{T}`.
- `init!(model, condition = set(); t0 = 0.0, hooks = NoHooks())` is
  `init!(model::Model, condition = set(); t0::Real = 0.0, hooks::FrameHooks =
  NoHooks()) -> Nothing`.
- `frame!(model, k, hooks = NoHooks()) → Bool` is `frame!(model::Model,
  k::Int, hooks::FrameHooks = NoHooks()) -> Bool`.
- `frame_top!(hooks)` and `settled!(hooks) → Bool` are `frame_top!(::NoHooks)
  -> Nothing` and `settled!(::NoHooks) -> Bool`.
- `NoHooks()` is `NoHooks() -> NoHooks`.
- `port(model, path, name)` is `port(model::Model, path::String,
  name::Symbol)`, with no return type, as W1 did.
- `state(model, path)` and `modes(model, path)` are `state(model::Model,
  path::String)` and `modes(model::Model, path::String)`, plus the lines
  `state(sim::Simulation, path::String)` and `modes(sim::Simulation,
  path::String)`.
- `warnings(model) → Vector` is `warnings(model::Model) ->
  Vector{Diagnostic}`, plus `warnings(sim::Simulation) -> Vector{Diagnostic}`.
- `checkpoint(model) → ModelState` is `checkpoint(model::Model{T}) ->
  ModelState{T}`.
- `restore!(model, model_state; hooks = NoHooks())` is
  `restore!(model::Model{T}, model_state::ModelState{T}; hooks::FrameHooks =
  NoHooks()) -> Nothing`.
- `overlay!(model, condition = set(); hooks = NoHooks())` is
  `overlay!(model::Model, condition = set(); hooks::FrameHooks = NoHooks()) ->
  Nothing`.
- `phase_bodies(sim) → named callables` is `phase_bodies(model::Model) ->
  NamedTuple` and `phase_bodies(sim::Simulation) -> NamedTuple`. B lists only
  the sim form.
- B gives no signature for `RK4`, `Heun`, `ModelState` and `Checkpoint`. They
  are written `RK4(::Type{T}, n_x::Int) -> RK4{T}`, `Heun(::Type{T}, n_x::Int)
  -> Heun{T}`, `ModelState{T}` and `Checkpoint`.

**`devices.jl` (W3, `5528c61`).**

- `latest(handle)` is `latest(handle::DeviceHandle) ->
  Union{Nothing,Snapshot}`.
- `wait_next_snapshot(handle)` is `wait_next_snapshot(handle::DeviceHandle) ->
  Union{Nothing,Snapshot}`. Outside a run the stop status is set, so it
  returns `latest` at once, and that can be `nothing`.
- `running(handle)` is `running(handle::DeviceHandle) -> Bool`.
- `stage!(handle, writes::Pair...)` is `stage!(handle::DeviceHandle,
  writes::Pair...) -> Nothing`.
- `binding(handle)` is `binding(handle::DeviceHandle) -> AbstractBinding`.
- `gather(handle, snapshot)` is `gather(handle::DeviceHandle,
  snapshot::Snapshot) -> NamedTuple`.
- `report!(handle, occurrence)` is `report!(handle::DeviceHandle,
  occurrence::MalformedDatum) -> Nothing`.
- `stop!(handle)` is `stop!(handle::DeviceHandle) -> Nothing`.
- `port_views(handle)` is `port_views(handle::DeviceHandle) ->
  Dict{Tuple{String,Symbol},PortView}`.
- `pending(handle, slot)` is `pending(handle::DeviceHandle, slot::Int) ->
  Union{Nothing,Some}`.
- `peek(view, handle, snapshot)` is `peek(view::PortView,
  handle::DeviceHandle, snapshot::Snapshot)`, with no return type.
- `incumbent_status(view, snapshot)` is `incumbent_status(view::PortView,
  snapshot::Snapshot) -> Union{Nothing,WriterStatus}`.
- `orphaned(record)` is `orphaned(record::WriterStatus) -> Bool`.
- `loop(dev, handle)` is `loop(dev::AbstractDevice, handle)`.
- `init!(dev)`, `shutdown!(dev)`, `unblock!(dev)` are `(dev::AbstractDevice)
  -> Nothing`.
- `DeviceHandle` is written bare.

**`roster.jl` (W3, `ed8c1d5`).**

- `is_input(b)`, `is_output(b)`, `is_greedy(b)` are `(b::AbstractBinding) ->
  Bool`.
- `claims(b)` is `claims(b::AbstractBinding)`, with no return type.
- `reads(b)` is `reads(b::AbstractBinding) -> NamedTuple`.
- `AbstractDevice` and `AbstractBinding` are written bare.

**`bindings.jl` (W3, `b8656f5`).**

- `map_input(datum, b)` is `map_input(datum::NamedTuple, b::TableBinding) ->
  Tuple`.
- `map_output(nt, b)` is the same as B. The only definition is `function
  map_output end`, so there is no method to mirror.
- B gives `TableBinding` no signature. The line is `TableBinding(; entries...)
  -> TableBinding`.

**`declare.jl` (W4, `c815cf9`).**

- `Relative(K, Φ = 0)` is two lines, `Relative(K, φ) -> Relative` and
  `Relative(K::Integer) -> Relative`. B writes capital `Φ`. The field, the
  code and the old docstring use `φ`. The default is a separate one-argument
  method.
- `Absolute(q, τ = 0)` is `Absolute(q::Period,
  τ::Union{Integer,Rational{<:Integer}} = 0) -> Absolute`.
- `Period(T)` is `Period(T::Union{Integer,Rational{<:Integer}}) -> Period`.
- `Hz(frequency)` is `Hz(frequency::Union{Integer,Rational{<:Integer}}) ->
  Period`.
- `ws_init(::C, ::Type{T})` is `ws_init(c, ::Type{T})`, with no return type,
  since nothing checks what it returns.
- B gives no signature for these, so each line is new: `x_init(c) ->
  NamedTuple`, and likewise `s_init`, `m_init`, `u_types`, `y_types`,
  `state_events` and `sample_times`; `local_wires(c)`, `input_wires(c)` and
  `output_wires(c)`, with no return type; `transparent_container(c) ->
  Union{Symbol,Nothing}` and `stop_reason(c) -> String`; `StateEvent(guard,
  handler) -> StateEvent`; `x_projection(c, x) -> NamedTuple`; `y_state(c,
  bundle) -> NamedTuple`, and likewise `y_direct`, `x_deriv` and `s_update`;
  `AbstractComponent` and `Pinned{P}`, written bare.

**`build.jl` (W5, `e9e381a`).**

- `build(world; activations = ()) → Build` is `build(root::AbstractComponent;
  activations::Tuple = ()) -> Build`.
- `warnings(x) → Vector` is `warnings(build::Build) -> Vector{Diagnostic}`.
- B gives no signature for `Build`, `Outputs`, `Events` or `ProbeDual`. Each
  is written bare.

**`assembly.jl` (W5, `31b5684`).**

- `resolve(assembly, path) → AbstractComponent` is `resolve(assembly,
  path::AbstractString) -> AbstractComponent`.
- `input_faces(c)` / `output_faces(c) → Vector{String}` are `input_faces(comp)
  -> Vector{String}` and `output_faces(comp) -> Vector{String}`. The method
  names the argument `comp`, so W4's `c` convention does not apply.
- `input_passthrough(assembly, child_path; sep = ".", prefix =
  replace(child_path, "/" => sep), except = (), only = (), select = nothing)`
  is `input_passthrough(assembly, child_path::AbstractString;
  sep::AbstractString = ".", prefix::AbstractString = replace(child_path, "/"
  => sep), except::Tuple = (), only::Tuple = (), select = nothing) -> Tuple`.
  `output_passthrough` is the same.
- B gives `Structure` no signature. It is written bare.

**`descriptor.jl` (W5, `55a5d2e`).**

- `descriptor(build)` / `descriptor(deployment) → NamedTuple` are
  `descriptor(build::Build) -> NamedTuple` and
  `descriptor(deployment::Deployment) -> NamedTuple`.

**`readers.jl` (W5, `5ace070`).**

- `get_state(path, leaf)`, `get_deriv(path, leaf)`, `get_output(path, leaf)`
  are `(path::AbstractString, leaf::Union{Symbol,AbstractString})`, returning
  `-> GetState`, `-> GetDeriv` and `-> GetOutput`.
- `get_input(leaf)` and `get_face(leaf)` are
  `(leaf::Union{Symbol,AbstractString})`, returning `-> GetInput` and `->
  GetFace`.
- `reads(; selectors...)` is `reads(; selectors...) -> Reads`.

**`dataplane.jl` (W5, `a102ee6`).**

- `port(snapshot, path, name)` is `port(snapshot::Snapshot, path::String,
  name::Symbol)`, with no return type, as for the other `port` methods.
- `stale(record; now = time())` is `stale(record::WriterStatus; now::Float64 =
  time()) -> Bool`.

**`leaves.jl` (W5, `9f70de4`).**

- B gives `StopFlag` no signature. It is written bare.

**`conditions.jl` (W6, `7e1baec`).**

- `set(; x = (;), s = (;), m = (;), u = (;))` is the same, plus `-> Fragment`.
- `at(prefix, node)` is `at(prefix::AbstractString, node::ConditionNode) ->
  Scoped`, plus a new line `at(prefix::AbstractString, read_set::Reads) ->
  Reads`. B gives no signature for the read-set method.
- `combine(nodes...)` is `combine(nodes::ConditionNode...) -> Combined`.
- `override(base, patches...)` is `override(base::ConditionNode,
  patches::ConditionNode...) -> Override`.
- `condition(comp; kw)` is `condition(c; kw...)`. It is a stub with no method,
  so it follows W4's `c` convention and has no return type.

**`trim.jl` (W6, `c052897`).**

- B names the `TrimProblem` lift of `at` only in prose. The line is
  `at(prefix::AbstractString, problem::TrimProblem) -> TrimProblem`.
- `trim!(model, problem; baseline, t0 = 0.0, backend = LevenbergMarquardt()) →
  TrimReport` is `trim!(model::Model{Float64}, problem::TrimProblem; baseline,
  t0::Real = 0.0, backend = LevenbergMarquardt()) -> TrimReport`.
- `solve(backend, eval!, d0, lower, upper, tol) → (; d, status, n_evaluations,
  n_iterations)` is the same arguments, `-> NamedTuple`. The prose lists the
  fields.
- B gives no signature for `TrimProblem`, `LevenbergMarquardt`, `TrimReport`.
  The new lines are `TrimProblem(; guess, lower, upper, condition, reads,
  residuals, tolerances, checks = _no_checks, check_tolerances = (;)) ->
  TrimProblem`, `LevenbergMarquardt(; maxiter::Integer = 100, λ₀::Real = 1e-3)
  -> LevenbergMarquardt`, and `TrimReport` bare.

**`linearize.jl` (W6, `3a4a3bd`).**

- B names the tap-set lift of `at` only in prose. The line is
  `at(prefix::AbstractString, tap_set::Taps) -> Taps`.
- `linearize(model, taps; about = nothing, t0 = nothing, width = 8) →
  Linearization` is `linearize(model::Model{Float64}, tap_set::Taps; about =
  nothing, t0 = nothing, width::Int = LINEARIZE_WIDTH) -> Linearization`.
- `taps(; x = (;), u = (;), y = (;))` is the same, plus `-> Taps`.
- B gives `Linearization` no signature. It is written bare.

**`blocks.jl` (W7, `f8663ce`).** B gives no block signatures. The
disagreements are with the inventory, listed in 4c.

### 4b. Names whose cited sections do not describe them

- **`port` (W1, W2, W5).** B cites §7.3, which covers discrete state, modes
  and workspace, not the port read. W1 carried §7.3 into the comment. W2 says
  the same for `port(model)`. W5 added §11.2 to `port(snapshot)`.
- **`frame_top!` and `settled!` (W1, W2).** W1's comment cites §11.2, §11.4
  and §13.5, taken from the `LoopHooks` comment. Those sections describe
  publication, the drain and stop sampling, not the hook functions. W2's
  `::NoHooks` methods cite §10.4 and D-317. §10.4 describes the frame and
  localization. Only D-317 names the hook functions.
- **`state` and `modes` (W2).** §7.3 describes the `s` and `m` stores, but not
  the read functions or the `x` half of `state`.
- **`AbstractComponent` (W4).** §8.5's list of leaf declarations reads "any
  stage, `x_deriv`, `s_update` or `x_projection` method". It does not name
  `y_state` or `y_direct`. The code's `LEAF_FAMILY` counts both. The docstring
  follows the code.
- **`u_types` (W4).** It cites D-167. D-263 supersedes that entry, and D-167
  still states the permissive reading the sentence used it for. Carried over.
- **`ProbeDual` (W5).** D-166 is titled "Mandate `Type{T}` output signatures
  on continuous producers". It describes the CI `Dual`-activation policy that
  `ProbeDual` serves, not the alias itself. Carried over.
- **`TrimProblem` (W6).** It cites §9.5 for "order carries no semantics". §9.5
  states the names-are-the-pairing rule for stage returns, not for the
  problem. Carried over.
- **`linearize` (W6).** It cites D-167, which D-263 supersedes, as W4 found.
  Carried over.

Coverage of the checks:

- W1 verified `port`, `frame_top!` and `settled!` by reading. It did not check
  the other old citations section by section.
- W3 found none, but the check is weak. It read §11.6, the start of §12.4, B's
  device section and the glossary entries. It carried the other citations over
  unchecked.
- W4 checked §5.2, §5.3, §8.1, §8.2, §8.5 to §8.7 and §10.5. They describe
  their names, except as listed.
- W5 carried the others over without a section-by-section check. It looked
  only at the headings of D-207, D-211, D-316, D-432, §9.5, §11.3 and §13.3.
  They match.
- W6 read §14.1, §14.2, §14.6, §14.9, §14.10 and the glossary entries used. It
  checked only the headings of §14.7, §14.8 and the cited decisions. They
  match.
- W7 did not check section by section. It carried every citation verbatim into
  the comments.

### 4c. B's prose errors

- **`t0` default (W1).** B's prose for `linearize` says "`t0` (default
  `0.0`)". The signature default is `nothing`. The body resolves it to `0.0`.
- **`phase_bodies` (W2).** B lists only the sim form, `phase_bodies(sim) →
  named callables`. The model form `phase_bodies(model::Model) -> NamedTuple`
  exists too.
- **`Φ` against `φ` (W4).** B writes `Relative(K, Φ = 0)`. The field, the code
  and the old docstring use `φ`.
- **`lifecycle(sim)` (W1).** The old text cites it in prose. It is not in B or
  `api.md`.
- **`taps` (W6).** `taps` was missing from `api.md`, though the brief's table
  does not mark it `+`. B puts it after `get_face`.
- **Lifts of `at` (W6).** B names the `TrimProblem` and tap-set lifts of `at`
  only in prose. The read-set method has no B signature at all.
- **`descriptor` (W5).** B's note "Provisional name until the export audit
  (D-226)" was not in the old docstring, so W5 did not add it.
- **The inventory's spellings (W7).** The inventory's spelling, then the
  docstring's:
  - `Junction{In, Out, N, F}` is `Junction{In, Out, N}(f)`. `F` is inferred
    and never spelled.
  - `Constant{V}` is `Constant(value)`. The inventory's own prose already says
    `Constant(value)`.
  - `Delay{V, K}` is `Delay(; K::Int, v0 = 0.0)`, with `K` a keyword.
  - `Step{V, L}` is `Step(; …, localized::Bool = true)`. `L` is set by the
    `localized` keyword.
  - `StateSpace` "holding `A`, `B`, `C`, `D` as static matrices": the keyword
    constructor takes any `AbstractMatrix`, and the static form is only the
    storage.
  - `TransferFunction` "from coefficient tuples": `num` and `den` accept
    tuples or vectors.
  - `GaussianWhiteNoise` "the two-sided density `Q`": the keyword is `psd`.
  - `LQRTrackerBlock`, which the inventory writes bare, is
    `LQRTrackerBlock{NX, NU, NZ, Hold, Track, Fixed}`.
  - `PID{V, Hold, Track, Fixed}` and the other controller type spellings: the
    docstrings show the constructor calls. The type parameters come from the
    `hold` and `tracking` keywords and the inferred shape.
  - `Integrator(; x0 = 0.0)`, `Relay(; lower, upper, off = zero(lower), on =
    one.(lower))` and `Source{V}(f)` agree.

## 5. Old text corrected rather than copied

1. **`init!(::AbstractDevice)`, the contract docstring (W3, `devices.jl`).**
   The old text said "four functions, one optional". That contradicts §11.6
   and D-366, which make `loop` mandatory and three hooks optional. The new
   text says three optional hooks.
2. **`map_output` (W3, `bindings.jl`).** The old text said "the identity one
   returns the NamedTuple itself". The new text says "A binding that sends the
   values as they are returns `nt` itself."
3. **`transparent_container` (W4, `declare.jl`).** The old text said "The one
   optional declaration". That is false, because `sample_times`, `stop_reason`
   and others are optional too. It now reads "The declaration is optional".
4. **`m_init` (W4, `declare.jl`).** The old text said "declaring `m_init`
   announces the continuous tier". That contradicts §8.2, where the state
   declaration alone marks the tier and `m_init` must agree with it. It now
   says modes are continuous-only and names the `DeclarationOnWrongTier`
   refusal.
5. **`input_passthrough` (W5, `assembly.jl`).** The old text said "Every input
   face of `child_path` the assembly does not feed". That is wrong, because
   the helper never checks what the assembly feeds. The new text names the
   pass-through case as the helper's purpose, and `except` as the filter.
6. **`ProbeDual` (W5, `build.jl`).** The old text mentioned `LinearizeDual`.
   The name is internal, so the mention moved to the comment.
7. **`Structure` (W5, `assembly.jl`).** The old sentences on
   `terminal_producer`, `face_routes` and the layout as the one home for
   addresses moved to the comment as maintainer prose. One plain sentence
   stays: no table of resolved faces is stored.
8. **`trim!` (W6, `trim.jl`).** The old text said `trim!` "raises"
   `TrimCommitChecks` and `TrimCommitEvents`. The code `@warn`s them, so the
   docstrings say "warns".
9. **`linearize` (W6, `linearize.jl`).** The old sentence "`checkpoint(sim)`
   on a simulation" moved to the comment, because `sim.jl`'s own docstring
   covers it.
10. **`FirstOrderLag` (W7, `blocks.jl`).** The sentence is appended directly
    after the `V` sentence, verbatim. The markup changed: the link is written
    as ``[`TransferFunction`](@ref)`(num = (1,), den = (τ, 1), u0 = x0)` ``,
    because a link cannot sit inside a code span. Its comment cites commit
    `9c75324` and the inventory row.
11. **Terms unwound in `blocks.jl` (W7).** "Pinned" and "walks" became "keeps
    that type whatever scalar the model runs at" and "follows the scalar".
    "Nominal" became "plain `Float64`".
12. **Moved as maintainer prose in `blocks.jl` (W7).** `Pack`'s `UnionAll`
    rationale and `Unpack`'s `unpack_names` rationale. `DiscreteLinearBlock`'s
    `held` and `realization` accessors (the docstring keeps "only the state
    update depends on the period"). `LinearBlock`'s "over the block's
    `realization`". `Group`'s "It needs no new rule". The `PID_PARAMETERS` and
    `LQR_PARAMETERS` names, since the docstrings now list the parameter order.
    Every companion-doc pointer: `linear_blocks.md`, `pid_anti_windup.md`,
    `lqr_tracker.md`, `limited_integrator_variants.md` and the
    ControlSystemsBase naming note.
13. **Moved in `report!(::RosterEntry)` (W3, `devices.jl`).** The docstring
    became a `# Design:` comment. See 8.

W1 and W2 report no corrected sentence. In every wave the handoff reports no
old sentence that could not be placed.

## 6. Added beyond the old text

- **`sim.jl` (W1).** Docstrings for the `+` names `frame_top!`, `settled!`,
  `port`, `EndTimeReached`, `ModelRequestedStop`, `ControlRequestedStop`. The
  last three cite B's §13.5, D-203, plus D-316 or §12.1, §12.4, D-268.
- **`model.jl` (W2).** `state` and `modes` gained `sim` signature lines and
  one sentence, from B. `Model` gained the claimed-model refusal list and
  "`chunk_size` never changes the trajectory", both from B. `FrameHooks` and
  `NoHooks` now say the model's `restore!` and `overlay!` take hooks too,
  which the code shows.
- **`frame.jl`, `checkpoint.jl`, `stepper.jl` (W2).** Nothing added beyond the
  signature lines. The docstrings of `RK4` and `Heun` say how the type is
  chosen.
- **`devices.jl` (W3).** `stage!(handle)`: the `EntryTypeMismatch` refusal.
  `init!`: called by `run!` and `replay!` in attachment order, and a failure
  brings `shutdown!`, a `DeviceCrash` and the `should_abort` stop. `loop`,
  `shutdown!` and `unblock!`: from §11.6, §12.4 and the code paths behind
  them.
- **`roster.jl` (W3).** `claims`: duplicates collapse, an empty claim is
  legal, and `AttachUnknownFace` and `ClaimConflict`. `reads(b)`: the
  not-a-NamedTuple and not-a-selector refusals, `ReadResolution` and
  `PathResolution`. `AbstractDevice`: two immutable instances with equal
  fields count as one device.
- **`bindings.jl` (W3).** `TableBinding`: the field ranges and what deadzone
  and expo do to a value.
- **`declare.jl` (W4).** Refusal kinds on every declaration. The handler
  return law on `StateEvent`, citing §5.2 and D-090. The firing rule on
  `state_events`, from §10.6's sketch. The root-input sentence on
  `input_wires`, from §8.6. The `Relative` composition formula, from §10.5.
  The anchor cost on `Absolute`, citing D-186. The import rule on
  `AbstractComponent`, citing §8.1, D-117 and D-246. `local_wires`,
  `input_wires` and `output_wires` now cite §8.6 and D-170 (and D-210 for
  `input_wires`).
- **`readers.jl` (W5).** Docstrings for the five selectors, with new citations
  §11.2, §14.4, §14.9, D-276, D-277 and D-406.
- **`dataplane.jl` (W5).** `port(snapshot)` gained a docstring, citing §11.2.
- **`build.jl`, `assembly.jl`, `descriptor.jl`, `leaves.jl` (W5).** Nothing
  added beyond the rewrite. `Outputs`, `Events` and `Structure` list their
  fields by name (see 8).
- **`conditions.jl` (W6).** The read-set `at` gained a signature line and a
  paragraph. Refusals from the code: `set`: `ConditionResolution`; `at`:
  `ReadSetMisuse`, and `ConditionNodeMisuse` for a second argument of another
  type; `combine` and `override`: `ConditionNodeMisuse`; all three
  combinators: `DuplicateConditionLeaf`; `condition`: a `MethodError`. New
  citations §14.9 and D-277 for the read-set sentences.
- **`trim.jl` (W6).** `trim!`: `UninitializedInputs`, and `ArgumentInvalid`
  for a model that is not `Float64`. `LevenbergMarquardt`: its three status
  values. New citation §14.7 for the exact-Jacobian sentence. `TrimReport` and
  `Linearization` introduce their field bullets with a lead sentence.
- **`linearize.jl` (W6).** `linearize`: `CheckpointMidFrame`,
  `ConditionResolution` (under `about` and for an unconvertible root input),
  `UninitializedInputs` and the `ArgumentInvalid` cases. `taps`:
  `ReadSetMisuse`. `taps` now has its own docstring and its `api.md` line. New
  citations D-278 for the empty-prefix refusal on `at`, and D-428 for the
  unconvertible root-input refusal.
- **`blocks.jl` (W7).** Refusal kinds `AlgebraicCycle` (on `Switch`,
  `RateLimiter` and `StateSpace`), `ConformanceFailure` (on `Source`),
  `TypeError` (on `Freeze`) and `ArgumentError` (on `Delay`,
  `GaussianWhiteNoise`, and `StateSpace`'s wrong-length `x0`). `# Keywords`
  lists on every keyword constructor. See also lines.

## 7. Spec findings

1. **§8.5's leaf list omits `y_state` and `y_direct` (W4).** The list reads
   "any stage, `x_deriv`, `s_update` or `x_projection` method". The code's
   `LEAF_FAMILY` counts both.
2. **The sheet's own example (W1).** It writes `closed(run) -> Bool` with no
   annotation, which the signature rule contradicts. W1 wrote
   `closed(run::Run) -> Bool`.
3. **The sheet has no field-list form (W6, item 3).** The sheet has no `#
   Fields` heading. `TrimReport` and `Linearization` introduce their field
   bullets with a lead sentence, close to W5's prose for `Outputs`, `Events`
   and `Structure`.
4. **The sheet's citation ban does not cover companion `*.md` pointers (W7,
   item 2).** The sheet bans only `§`, `D-`, FlightCore and Flight.jl. W7
   judged `*.md` design pointers to be citations by the reader rule and moved
   them to the comments. The reviewer may rule otherwise.
5. **§11.6's hook count (W3).** The old contract docstring said "four
   functions, one optional". §11.6 and D-366 make `loop` mandatory and three
   hooks optional.
6. **D-317 alone names the hook functions (W1, W2).** §10.4, §11.2, §11.4 and
   §13.5 do not (see 4b).
7. **§8.6 hides a refusal kind (W4, item 4).** An empty fan-out tuple in
   `input_wires` is refused as `UnknownPort` with `endpoint = :connection`.
   §8.6 only says "a declaration error". W4 read the kind off
   `assembly.jl:1295`.
8. **D-167 is superseded by D-263 (W4, W6).** Two docstrings still cite it
   (`u_types`, `linearize`).

## 8. Frictions the review and the rulings settled

Items already placed in sections 3, 5, 6 and 7 are not repeated. Each line
gives the wave and its item number, then what settled it. A ruling number
refers to section 13. "The review let it stand" means the cold review raised
no finding against it.

### Naming and signatures

- W2 item 5. `RK4` and `Heun` document a constructor that users never call.
  `compile` calls `algorithm(T, n_x)`, and users only pass the type as
  `algorithm = RK4`. The constructor line stays because the rule mirrors the
  method, and the prose says how the type is chosen. The review let it
  stand.
- W3 item 4. `map_input` refuses an unknown channel with a plain `error(...)`,
  so its refusal sentence names `ErrorException`. No diagnostic kind exists.
  The review let it stand.
- W5 item 5. An unknown `(path, name)` throws a bare `KeyError`. None of the
  three `port` docstrings names it, to keep the family uniform. The fix
  narrowed the addressing sentence in all three (review A7), and the
  `KeyError` stays unnamed.
- W7 item 3. `ControllerBlock` keeps its condition table, since the sheet bans
  tables only for keywords and arguments. The review let it stand.

### Glossing

- W1 item 2. Glossing every glossary term inside glosses cascades without end.
  Core terms glossed with the spec's phrases: snapshot, frame and frame top,
  boundary zero, batch, trace and trace header, log, input mode, stop word,
  control plane, staging cell, root input, condition, checkpoint, fingerprint,
  prior, tick, roster, binding, claim, diagnostic cell, termination record and
  drain. Treated as plain words: run, boundary, port, store, event and device.
  Some glosses are shortened, for example the input mode as "where the frame's
  inputs come from". Settled by the coordinator's call that "boundary" stays
  plain, and by the fix's glosses for the terms review C1 found bare.
- W2 item 7. "localized event" and "base tick" are glossed with short phrases,
  since "base tick" has no glossary entry of its own. "stepper" is not in the
  glossary and is used as a plain word. The review let it stand.
- W4 item 1. Some summaries use a glossary term that the body glosses
  afterwards, such as "tick" in `Relative` and "workspace" in `ws_init`. This
  follows W3's practice (`latest`, `wait_next_snapshot`). Read strictly,
  checklist item 5 would put the gloss in the summary. The reviewer may want
  one ruling. Settled by ruling 6.
- W4 item 2. Treated as plain words: component (glossed once, in
  `AbstractComponent`), leaf, port, store, event, boundary, handler and mode.
  Glossed: activation, tier, bundle, tick, assembly, face, rate scope, anchor,
  guard, boundary-detected, localized, workspace, probe, root input, stop
  request, class and flow. "Contract" was taken out of the `u_types` and
  `y_types` summaries rather than glossed. "Base tick" gets a short
  in-sentence gloss. Settled by the coordinator's call on "boundary"; the fix
  wrote "feedthrough class" where bare "class" clashed (review C1).
- W7 item 4. Glossed in each docstring that uses them: stage 1 and stage 2,
  tick, tier, activation, feedthrough, algebraic loop, artificial, hop,
  boundary zero, prior, localized, boundary-detected, guard, sweep, root
  input, assembly, rate scope, stop request, `Δt_base` and frozen arrival.
  Treated as plain words: block, leaf, port, store, mode, event, boundary and
  partials. Settled by the coordinator's call on "boundary"; the fix unwound
  "frozen arrival" (review C2).

### Internal names on the page

- W1 (signature list). `frame_top!` and `settled!` in `sim.jl` sit on
  `LoopHooks`, an internal type. The public reference shows a type the reader
  cannot construct. Settled by ruling 3.
- W2 item 3. The sim methods are documented unevenly. `warnings(sim)`,
  `phase_bodies(sim)`, `state(sim)` and `modes(sim)` live in `sim.jl` with no
  docstring, so `model.jl` carries their lines. W1 gave `port(sim)` its own
  docstring. The reviewer may want one pattern. Settled by ruling 5.
- W3 item 5. `PortView`, `WriterStatus`, `Snapshot`, `MalformedDatum` and
  `DeviceCrash` are written as code. `port_views` lists `PortView`'s fields
  because the reader has nowhere else to find them. Settled by ruling 13 for
  the first four. `DeviceCrash` is a diagnostic kind, which section 10
  leaves open.
- W5 item 1. The selector group docstring sits on `struct GetState`, which is
  not on the page, so no selector's own docstring can link it with `@ref`.
  Each selector docstring glosses selector and leaf address itself and links
  its siblings. The group docstring is untouched, as the brief says. Its
  citations are what the grep hits in `readers.jl`. Settled by ruling 13:
  wave 8 writes the selector types' docstrings.
- W5 item 2. `-> GetState` and the other selector types, and `-> Reads`, name
  internal types, as W1's `-> Trace` did. `?Redstone.GetState` does reach the
  group docstring. Settled by ruling 13.
- W5 item 3. The spec calls the artifacts "inspectable as fields", so the
  `Outputs`, `Events` and `Structure` docstrings list their fields by name,
  read as `build.outputs` and so on. That makes the field names public
  surface. The audit may want to rule on it. The field-list form joined the
  sheet (review 7.3). Whether the field names are public stays open
  (section 10).
- W5 item 4. `stale` names `STALE_S`, two seconds, which is not on the page.
  The review let it stand.
- W6 item 4. Mirroring the method forces internal names in signatures:
  `ConditionNode`, `Fragment`, `Scoped`, `Combined`, `Override`, `Reads`,
  `Taps`, `_no_checks` and `LINEARIZE_WIDTH`. `LinearizeDual` is named in
  prose. Same issue as W5 item 2. Settled by ruling 13 for the seven types.
  `_no_checks` and `LINEARIZE_WIDTH` stay open (section 10).

### Moved or split docstrings

- W3 item 1. `report!(entry::RosterEntry, ::DeviceCrash)` had a docstring that
  would render under the public `report!` entry, naming an internal type and
  citing §12.4. It became a `# Design:` comment and the method is
  undocumented. The sheet's "unexported names keep their docstrings" does not
  cover an internal method of a public name. The reviewer may rule otherwise.
  Settled by ruling 3.
- W3 item 2. The old authoring-contract docstring sat on
  `init!(::AbstractDevice)`, and the declared-sides docstring on `is_input`.
  Kept in place, each would have rendered as that one name's docstring. They
  were split so each name has its own. The whole old citation set stays on the
  first comment, so `init!`'s `# Design:` line also carries §12.4(3) and
  Appendix C, which describe `unblock!` and `loop`. The review let it stand.
- W6 item 1. The old `taps` docstring sat on `struct Taps`, so `?taps` showed
  nothing. The rewritten docstring moved onto the `taps` function. `Taps` is
  now undocumented, which goes against the sheet's "unexported names keep
  their docstrings". W6 judged the text to be `taps`'s own, misplaced. The
  reviewer may rule otherwise. Settled by ruling 4.
- W6 item 2. The read-set `at` had no docstring. Its line and a paragraph went
  into `conditions.jl`'s `at` docstring. Settled by ruling 5.
- W2 item 3 and W1. The sim methods documented from `model.jl` (see Internal
  names above). Settled by ruling 5.

### Loose ends for the fixer

- W6 item 6. `taps` was off the page until the last commit, so two places
  still write a tap set without a link. `conditions.jl`'s `at` ("a tap set")
  and W1's sim `linearize` (`` `taps` `` as code). Both can now take
  `[`taps`](@ref)`. Fixed in `8e78b72` (review E4).
- W3 item 6. The out-of-scope task-wrapper docstring in `devices.jl` has a
  comment between it and `_unblocks`. A probe confirmed such a comment
  detaches a docstring, as the sheet says, so it attaches to nothing. Left
  alone. The review let it stand.
- W5 item 6. Attaching docstrings to the five one-line selector definitions
  puts blank lines between them. No code changed. The review let it stand.
- W5 item 7. B's provisional-name note for `descriptor` was not added (see
  4c). Settled by ruling 14, and the note left Appendix B.
- W7 item 5. `τ > 0`, `lower < upper`, positive rates and positive `τd` have
  no refusal in the code. They are stated as requirements with no diagnostic.
  The review let it stand.
- W7 item 6. The `DiscretePID` and `DiscreteLQRTracker` keyword lists repeat
  their continuous twins', with the discrete differences: `τd = 0` and `Tt =
  0` are legal. The review let it stand.

## 9. Verification

All counts are under the sandbox flags. The docs build was green after each
commit, with no `Error` line. The citation grep hit only docstrings of names
out of scope.

- **W1.** Docs build green, no size warning. Full gate 7004/7004, run twice.
  Examples runner 73/73. Line comparison against HEAD showed only `# Design:`
  comment lines and one blank line added.
- **W2.** Docs build green after each commit, no size warning. Full gate
  7004/7004. Examples runner 73/73. No definition line changed.
- **W3.** Docs build green after each commit, no size warning. The new
  docstrings appear in `docs/build/api.html`, and the `RosterEntry` method
  does not. Routed subset `dataplane roster bindings devices trace lifecycle
  log`, 1433/1433. The full gate did not run, since these files are not in the
  table's last row. The examples runner did not run.
- **W4.** Docs build green, no size warning, all six new names render. Routed
  subset `declare assembly build diagnostics leaves show descriptor`,
  2256/2256. The full gate did not run, since `declare` is not in the table's
  last row. The examples runner did not run.
- **W5.** Docs build green after each commit, no size warning. `leaves` sits
  in the table's last row, so the full gate ran, 7004/7004. Examples runner
  73/73.
- **W6.** Docs build green after each commit, and `taps` renders. Routed
  subset `readers conditions trim linearize`, 606/606. The full gate did not
  run, since none of the three files is in the table's last row. Two amends to
  the linearize commit after the gate changed a comment only. The one-line
  docstrings on `LINEARIZE_WIDTH` and `LinearizeDual` also cite, but the awk
  does not catch them.
- **W7.** Docs build green, run twice, the second time on the final file. No
  size warning. The citation grep over `src/blocks.jl`'s docstrings is empty.
  All 39 `Redstone.Blocks.*` anchors render in `docs/build/api.html`. `blocks`
  routes to `blocks build`, run in the foreground, 2292/2292 (blocks 1916,
  build 376). The full gate and the examples runner did not run, since
  `blocks` is not in the table's last row and no imported name changed.

## 10. Left for the user

The rulings settle every friction above except these. The first two are
the export audit's questions, which the sweep surfaced.

- **Appendix C's kind set.** Ruling 13 makes `Diagnostic` public, the root
  type alone. Whether the kinds under it are public as a whole stays the
  audit's question. Until then the docstrings write a kind as code, such as
  `DeviceCrash`.
- **The field names of `Outputs`, `Events` and `Structure`.** The sheet now
  has the field-list form, and the three docstrings list their fields by
  name. Whether the names are public surface stays the audit's question.
  `TrimReport` and `Linearization` list theirs the same way.
- **`TerminationSource` and `LoopError`.** Settled 2026-10-27. Both are
  public under Appendix B's Running, and the next docstring commit
  documents them.
- **`_no_checks` and `LINEARIZE_WIDTH` in signature lines.** Settled
  2026-10-27. The sheet writes such a default by value or in the prose, and
  the next docstring commit applies it.
- **The `LoopHooks` question.** Nothing remains. Ruling 3 turns the two
  methods' docstrings into comments, and the conformance commit applies it.
- **Optional edits the triage proposed.** Settled 2026-10-27. Appendix B's
  `t0` and §8.5's stages land in the spec, and the next docstring commit
  reorders `TrimProblem`'s citations.

## 11. The cold review

One Opus reviewer read `9c75324..f8663ce` cold against the sheet's
checklist. The code was unchanged, no citation was lost, the citation grep
was empty, every family docstring attached, and the docs build and the
gate were green (7004/7004, 7 m 53 s). The findings fall in four groups.

- **A. Wrong claims about the code, 22.** Listed below.
- **B. More than one parenthetical in a sentence, 46 sentences.** The one
  systemic finding. The gloss form is a parenthetical, so a sentence with
  two glossary terms breaks `spec_style.md`'s rule. Some sentences in
  `sim.jl` carry three or four glosses.
- **C. Other rules broken, 14 items.** Five on glossary terms used bare,
  five on coinages outside the glossary, two on keyword lists and two on
  signature lines.
- **E. Voice mismatches across families, 4.** `checkpoint` and
  `linearize`'s default point worded three ways, `warnings(deployment)`
  leaving out the model, `port(sim)` naming an internal call, and two tap
  sets that could link `taps`.

Group D, citations lost, came back empty. Group F held nine lines of nits.
The review also recommended eleven rulings, which the user's rulings in
section 13 take up.

The 22 wrong claims, by docstring:

1. `unblock!`: the waits are woken, not returned, before `_tail!` calls it.
2. `LevenbergMarquardt`: `:stalled` has three causes, not one.
3. `DiscretePID`, `DiscreteLQRTracker`: the infinite-`Tt` refusal needs only
   `tracking`, not the hold.
4. `m_init`, `state_events`: only a non-empty one is refused on a discrete
   leaf.
5. `StateEvent`, `Events`: only a `Float64` guard is localized.
6. `x_init`: the leaf is a `Float64` or a static array of `Float64`.
7. The three `port` docstrings: an assembly's path addresses only its output
   faces, and `""` the root inputs.
8. `run!`: a replaying run that exhausts its recording writes no record and
   turns `:live`.
9. `mode`: every call that opens a run resets the mode.
10. `init!`'s `log_max`: the bound covers the middle, and the two ends are
    always kept.
11. `settled!(::LoopHooks)`, `FrameHooks`: the boundary `overlay!` and
    `restore!` settle was missing.
12. `stop!`: a stop before `run!` is dropped, and one before `step!` ends it
    at 0 frames.
13. `trim!`'s `baseline`: totality is checked with the problem's condition
    at the guess.
14. `trim!`, `TrimProblem`: the problem is checked in two passes.
15. `linearize`: `about` can raise the condition's own resolution
    diagnostics.
16. `AbstractDevice`: equal instances are `===` only when their fields are.
17. `Model`'s `claimed`: the refusing calls left out `apply!`.
18. `StopRequest`: it ends the run unless the advance ignores it.
19. `attach!`, `overlay!`, the sim `linearize`: refusals left out.
20. `overlay!`: it drops staged batches and clears the stop word, and
    `initialized` is legal.
21. `frame!`: any other `k` runs an off-tick boundary.
22. `at`: an unknown path is refused as `PathResolution`.

The reviewer later withdrew item C.2's "requester roster". It is the
glossary's term (`g-requester-roster`), glossed at first use in
`leaves.jl`, and it does not clash with the device roster.

## 12. The fix

One Opus fixer landed `8e78b72`, "Fix the docstring sweep's review
findings": 15 files under `src/`, 439 insertions and 355 deletions. With
docstrings, comments and blank lines stripped, the files match `f8663ce`.
The docs build was green, the full gate 7004/7004 (5 m 59 s), the examples
73/73.

- **A.** All 22 fixed, each checked against the cited code line first.
- **B.** Sentences split per file: `sim.jl` 16, `model.jl` 1,
  `linearize.jl` 2, `dataplane.jl` 1, `devices.jl` 4, `roster.jl` 1,
  `declare.jl` 5, `build.jl` 1, `blocks.jl` 20. No gloss was dropped. The
  review's script then reported only false positives.
- **C.** C1's glosses added and "feedthrough class" written in four discrete
  linear blocks. C2's coinages unwound. C3's keyword bullets split and `h`
  marked required on `Simulation` and `Model`.
- **E.** All four aligned. `checkpoint` and the default point of
  `linearize` now say "at the frame top its clock rests on" in all four.
- **F.** Every nit fixed.
- **The review's ruling 2.** The pilot's `Deployment(...)` line now ends
  `-> Deployment`.

The fixer disagreed on one item. It left `StopFlag`'s "requester roster"
alone as a glossary term, and the reviewer agreed. It proposed "selection
keywords" for the passthrough `except`, `only` and `select`, whose
docstrings say "selectors", for the conformance commit.

The reviewer then verified the delta. Nothing was fixed wrongly, no rule
break came in, and every new `@ref` is on the page. It left five nits, none
blocking, for the conformance commit:

1. Ragged lines after the splits in `sim.jl`, `model.jl`, `blocks.jl` and
   `trim.jl`.
2. The `checkpoint` summary's "with the run's two counters", acceptable.
3. `Model` names the internal `apply!` as code; "such as" would avoid it.
4. `Deployment`'s summary runs to 22 words, older than the sweep.
5. The fixer's "selection keywords".

## 13. The rulings

The user ruled on 2026-10-27, going with every recommendation. Rulings 1
to 10 land in the style sheet, and rulings 11 to 16 in the spec and the
log.

1. A signature line names a fallback's argument where users extend it.
2. A method that only refuses, or sits on an internal type, gets no line.
3. An internal-type method of a public function gets a comment, not a
   docstring.
4. The `taps` docstring stays on `taps`; wave 8 documents `Taps`.
5. A delegating method's line sits on its sibling; `port(sim)` keeps its
   own.
6. The summary is exempt from glossing; the body glosses first use.
7. Companion `*.md` pointers join the citation ban.
8. A block with a keyword constructor shows the keyword form only.
9. The sheet's example becomes `closed(run::Run) -> Bool`.
10. A forwarded `kw...` is shown as the callee's keywords.
11. `lifecycle(sim)` is public, under Appendix B's Running.
12. `world` becomes `root` in Appendix B.
13. The 21 holder types are public and join Appendix B under their owners.
14. No provisional caveats; `descriptor`'s note leaves Appendix B.
15. §13.4 names `frame_top!` and `settled!` once, citing D-317.
16. §8.6 names `UnknownPort` with `endpoint = :connection`.

The coordinator's calls:

- "Boundary" stays a plain word across the sweep.
- The reviewer's withdrawal of "requester roster" stands.
- The fixer's "selection keywords" goes into the conformance commit.
- Appendix B's corrections follow the triage mechanically, with no log
  entry, since no owning section rules on a B signature.
- The conformance commit moves citations: D-167 to D-263 for `u_types` and
  `linearize`, D-166 to D-099 and §9.4 for `ProbeDual`, and D-317 added for
  the hook functions and for `port`, `state` and `modes`.

## 14. Wave 8 and the closing commits

The rulings landed as the docs commit `09185f6`. Wave 8, one Opus agent,
then rewrote the 21 holder types' and `lifecycle`'s docstrings and put
them on the page (`c3bfde0`), and the same agent landed the conformance
commit (`33110a5`): the `LoopHooks` docstrings became comments with one
sentence under `FrameHooks`, the two LQR trackers show the sized form's
keywords, the citations moved, the review's nits and "selection keywords"
landed, and the pending bullets were corrected. The reviewer verified both
and found seven stacked glosses and ten holder docstrings naming fields in
prose; the fixer landed them as `d184617`. The ruling on fields: a field
the user reads is listed, a field the user never reads is not named, so
the condition nodes, the selectors, `Reads` and `Taps` describe their
contents in prose. B's holder bullet for `MalformedDatum` gained the clause
that a device builds it, since the holder framing did not fit that type.

Left for later, from wave 8's handoff: `termination` and `port_views` still
list the fields that `TerminationRecord` and `PortView` now list, and could
shrink to a link; the hook functions' comments could cite §13.4 now that it
names them.

## 15. The glossary page and the vocabulary

The user ruled three questions on 2026-10-27. This docs commit lands the
generator, Appendix D's edits and the sheet's rules. The docstring commit
after it applies them to the swept files.

**Inline glosses become links.** A docstring's first mention of a glossary
term links to a glossary page generated from Appendix D, and no docstring
defines a term inline. The glosses had grown into the sweep's largest
friction: the review counted 46 sentences carrying two or more, and the
classifier found 482 glosses in the page's 210 docstrings. A link costs
one span and keeps one definition. The trade is accepted knowingly: `?name` in the
REPL renders a link as bare text, so a REPL reader sees the term without
its definition. The generator drops the spec's citations, so every
citation in Appendix D now stands as a trailing parenthetical, and it
skips D.10, which defines the spec's own conventions.

**The spec keeps its glosses.** The spec's readers arrive by section or by
line range, often an agent reading a slice, and cannot follow a link. A
gloss at each section's first use keeps every section readable on its
own. A docstring's reader is one link from the page, so the two forms
differ on purpose.

**Primitive, block and leaf.** "Leaf" had four senses in the docstrings:
a component of the primitive kind, a leaf of a store value, a leaf of a
condition and a node the leaf walk reaches. "Primitive" has one, the
component kind, so the documentation says "primitive" for it and keeps
"leaf" for a leaf of a store and a leaf address. "Block" now means only
that the standard library ships the component, with no privilege a user's
component lacks, and Appendix D gains an entry for it. The library's
summaries open "A continuous primitive that …", "A discrete primitive
that …" or, for `Group`, "An assembly …".

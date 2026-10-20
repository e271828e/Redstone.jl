# Appendices

The appendices are reference matter, not a fifth part. [Appendix A][sA]
indexes the semantic contracts an author must know and no check can enforce.
[Appendix B][sB] is the API synopsis. Neither is a second home. Each item is
normative only where its owning section settles it. [Appendix C][sC] is the
exception. Its diagnostic kind set is made normative here, and acceptance
tests match on it. [Appendix D][sD] is the glossary. It is non-normative, and
the owning section wins wherever the two diverge.

## Appendix A. Taught contracts: the author-facing index

The build pipeline enforces structure. It checks declarations, wiring, types
and conformance. A residue of *semantic* facts remains that no check can
enforce. A [component](#g-component) or [periphery](#g-periphery) author who
knows them writes code that comes out right, and so does a service user, who
writes [conditions](#g-condition), trim problems, [taps](#g-taps) and
linearization calls. An author who does not produces defensive delays,
duplicated math or mistimed samples, and no diagnostic fires anywhere. The
IMU's boundary-sampling note ([§8.6][s8-6]) is the archetype. This appendix is
an [index, not a second home](#g-normative). Each contract gets one recall
line here, and its normative statement stays in the owning section. That
applies the [one-home-per-datum](#g-one-home-per-datum) rule to the document
itself. The index has three groups, for component authors, for periphery
authors and consumers, and for service users.

For component authors:

- **The stage funnel** ([§5.2][s5-2], [§5.3][s5-3]; [D-341][d-341]). The
  [stage](#g-stage-function) name at its [tier](#g-tier) (the continuous or
  discrete side) fixes the maximal legal view set. The component's
  declarations narrow that set to the [bundle](#g-bundle). The signature's
  destructuring narrows the bundle to the actual reads. In short, stage name
  at its tier ⊇ bundle ⊇ destructured reads. So "no `direct` in the name"
  *is* the no-[feedthrough](#g-feedthrough) property. The teaching line runs
  as follows. Stage 1 publishes what you know from state alone. Stage 2 adds
  what needs inputs. Your dynamics read your own published results instead of
  recomputing them.
- **One home per datum** ([§5.2][s5-2]; [D-035][d-035]). The [signal table](#g-signal-table)
  holds *produced* signals only, never transported ones ([§4.3][s4-3]). The
  [buffer](#g-buffer) holds `x`, the `s` and `m` [stores](#g-store) hold `s`
  and `m`, and the table holds signals. No store mirrors another.
- **The [value-level constructor](#g-value-level-constructor)**
  ([§8.2][s8-2]; [D-139][d-139]). A field-emitting component ships the map from (component,
  input values) to handle as a plain public function, and its output stage
  merely calls it. The condition math ([§14.1][s14-1]) must be able to
  produce the [sweep](#g-sweep)'s exact handle outside any sweep. Only the
  component's author can write that function without re-creating the drift
  class.
- **Boundary sampling** ([§10.5][s10-5]/[§10.6][s10-6]; worked example
  [§8.6][s8-6]; [D-056][d-056]). "Sampling at `t_k`" means sampling the post-integration,
  post-projection, stage-1-fresh state. A [due](#g-due)
  [tick](#g-tick)'s gated stages run inside the [boundary](#g-boundary)
  sweep and sample the *completed* boundary. An author who distrusts that
  guarantee, with a defensive one-tick delay or a re-derivation inside the
  sampler, silently degrades the model.
- **The startup hole** ([§10.5][s10-5], [§14.5][s14-5]; [D-205][d-205]). An
  offset component's first tick is at `Φ·Δt_base`, where `Φ` is its
  [phase](#g-phase) in base ticks and [`Δt_base`](#g-dt_base) the base tick
  period. Until then its [cells](#g-cell) hold what it published at
  [boundary zero](#g-boundary-zero) (the initialization boundary at `t₀`).
  Its output stages still run at `t₀`, evaluated from the authored world. A
  startup hole, a component dark until its first tick, is a modeling
  decision. The author spells it as a validity flag or a mode, and the
  framework withholds no publication by default.
- **Interval alignment** ([§14.5][s14-5]; [D-067][d-067], [D-273][d-273]). A
  boundary's `s_update` is the *outgoing* transition. At tick `t_k` it
  consumes the completed boundary's samples and produces `s_{k+1}`, the value
  the component's *next* tick decodes. That is the sampled-data `z⁻¹` delay,
  by construction. Hence `s_update` runs at boundary zero. That run is the
  `t₀` sample's only chance. The same placement fixes what a discrete store
  holds at rest. After any boundary the store holds the state the
  component's next due tick decodes, and its cell holds the sample its last
  tick published. A counter due at boundary zero and authored at 0 holds 1
  after `init!` alone. A discrete store copied off a stopped
  [run](#g-run) into a condition therefore starts that component one tick
  ahead. A state what-if goes through `overlay!` instead, which writes the
  condition's stores onto the stopped run's own and continues it as a fresh
  trajectory, with an overlaid discrete store as the next tick's state, so no copy through a
  condition and `init!` is needed ([§12.6][s12-6], [D-429][d-429]).
- **Same-tick reset consumption** ([§5.3][s5-3]; [D-089][d-089]), on the
  *discrete tier*. A commanded reset of a discrete component's `s` is an
  input. For same-tick output semantics the *output stage* consumes that
  input, overriding the state-derived path, and `s_update` stores the
  matching `s⁺`. A reset honored only in `s_update` reaches the outputs one
  tick late, and the plant integrates a full step under the stale command.
  Both spellings are legal, and they mean different things. The continuous
  tier has no such choice (the next item).
- **Continuous-tier resets** ([§3.1][s3-1], [§10.6][s10-6], [§5.3][s5-3];
  [D-141][d-141]). A [continuous component](#g-continuous-component)'s state
  reset is an event. Only handlers write `x`. So even a *commanded* reset,
  where the reset command arrives as an ordinary `Bool` input (weight-on-wheels
  is the shipped instance), is spelled as an event whose [guard](#g-guard) reads that
  input. The discrete tier's input spelling does not transfer. The reason is
  semantic, not stylistic. Only the discrete tier's update stage is already
  a jump map, so a reset there is just another value for `s⁺`. A continuous
  state jump, by contrast, must be solver-visible and applied *between*
  integration segments. Every hybrid tool converges on that [flow](#g-flow)/jump split.
  Simulink applies its reset ports through zero-crossing events plus a solver
  restart, and Modelica's `reinit` is syntactically legal only inside a
  `when`. There is no stale-output hazard to manage either. [§10.6][s10-6]
  re-sweeps outputs to [quiescence](#g-quiescence) after handlers, so a continuous edge-reset
  is same-boundary by construction.
- **Undeclared modes** ([§3.1][s3-1], [§2.3][s2-3]; [D-345][d-345],
  [D-179][d-179]). A branch in the flow that switches on a
  continuous quantity, such as an integrator that stops accumulating once its
  output reaches a limit, is a mode change with no declared event. It
  switches inside a step, at no boundary and against no
  [prior](#g-prior), so nothing [localizes](#g-localized) it and nothing records it. Such a
  switch is spelled as a mode moved by an event, or as a branch on another
  component's mode-derived output, which changes only when that component's
  events fire.
- **Guard predicates, edges and priors** ([§2.3][s2-3], [§10.4][s10-4],
  [§10.6][s10-6]; [D-365][d-365]). A guard
  defines a [predicate](#g-predicate), either as a `Bool` or as a sign value
  `σ`, which holds when `σ ≥ 0`. The form chosen *is* the detection policy. A
  `Bool` guard is [boundary-detected](#g-boundary-detected), a sign guard is
  localized. Boundary detection is exact for a guard whose
  value within a step depends only on modes, [root inputs](#g-root-input) and
  held discrete outputs. A guard that reads an input fed by continuous state
  or by time can cross inside a step. Events fire on
  [*edges*](#g-edge-semantics) from not-holding to holding, judged against
  per-event priors, where the prior is the previous boundary's quiescent
  sample. A predicate that keeps holding fires once, at the boundary where it
  first held. Boundary zero sets every prior to not-holding, so a predicate
  already holding in the authored state fires at `t₀`. The opposite crossing
  direction is a second event with the negated guard.
- **Latching and release pairs** ([§10.4][s10-4], [§10.6][s10-6];
  [D-290][d-290], [D-181][d-181]). A release predicate that must exclude
  equality, such as "the input points back into the range", does not hold at an input of exactly zero, but
  the sign form `-u` alone holds there. It gates on the strict comparison
  instead, as `u < 0 ? -u : -one(u)`, or takes the `Bool` form `u < 0`, the
  same predicate boundary-detected. The
  predicate that latches the mode stays ungated on it. Gated on the free
  mode, each handler hands the other guard a fresh edge, and the boundary chatters
  until the [firing budget](#g-firing-budget) breaks the tie, under a
  `FiringBudget` warning.
- **Handler-phase visibility** ([§5.3][s5-3], [§10.6][s10-6];
  [D-154][d-154]). A handler
  executes against exactly the world its guard fired on. Its own `y`, foreign
  `u` and its own `x`/`m` all come from the firing round's sweep. A component
  fires at most one event per round. Its later own events are re-decided
  against the next round's sweep, one round per causal link, within and
  across components alike. Only sweeps write the signal table.
- **Stage totality** ([§9.3][s9-3]; [§13.4][s13-4], [§13.5][s13-5];
  [D-142][d-142]). Stage
  code is total over type-valid inputs. The [probe](#g-probe) evaluates every
  user function against values chosen for their types alone. A value-level
  throw is a build failure there and a `StepError` at runtime. Physical
  plausibility is a published [stop request](#g-stop-request).
  Self-consistency asserts belong in tests. Parameter validation belongs at
  instance construction, not inside a stage.
- **Stop-request sampling** ([§13.5][s13-5]; [D-316][d-316]). Stop requests are read in
  completed-boundary [snapshots](#g-snapshot) (the immutable per-boundary
  publications). Declare a sign-form (localized) event if the stop needs
  localizing. Every request stops the run unless the advance ignores it.
- **Never cache `Δt`** ([§10.5][s10-5]; [D-019][d-019], [D-291][d-291]). An
  author must never store `Δt`, or any `Δt`-derived coefficient, as a
  component parameter. The discretized law reads `Δt` from the bundle and
  recomputes its derived coefficients per tick, which costs a few arithmetic
  operations. Under scoped multipliers a component author *cannot* know the
  absolute rate, which does not exist until composition. A discretized law is
  written to be stable at every period a deployment may assign, since the
  component cannot know its period at construction and no check compares the
  law against it.
- **No mutable cache in a field handle** ([§4.4][s4-4], [§4.1][s4-1];
  [D-344][d-344]). A [field handle](#g-field-handle) must hold no mutable
  cache, such as a memoizing interpolator or a lazy loader. Concurrent
  consumers and the GUI thread would race on it. The remedy is to
  restructure the interpolant to be pure. The rule is the author's, because
  the build does not look inside a field handle. The bulk data a handle
  references stays read-only for the duration of the run.
- **Contracts by type** ([§8.1][s8-1], [§9.7][s9-7]; [D-297][d-297]). A
  leaf's [contract](#g-contract) declarations must be determined by the
  component's type, its type parameters included, and never by its field
  values. Those declarations are `u_types`, `y_types` and `state_events`, and
  the shapes of `x_init`/`s_init`/`m_init`. A contract that genuinely varies
  takes a type parameter, as `SumJunction{V, N}` and `Or{N}` do. `ws_init` is the
  one exception. The build reads each declaration once, against the concrete
  instance, so a value-dependent contract does not announce itself. This is a
  rule authors keep, not a check the build can run.
- **Deliberate stripping** ([§13.7][s13-7], [§14.10][s14-10], [§9.5][s9-5];
  [D-266][d-266]). `Freeze` strips partials, and its wire then declares a
  zero coupling in every Jacobian along that path. That is a modeling
  decision, stated on the page rather than buried mid-expression. Stripping
  mid-expression at a leaf left unpinned remains legal and remains unseen. A
  sampler is no substitute, because it changes the model, holding the value
  between ticks. Where the coupling matters to the Jacobian, a component
  keeps its input entry tolerant and supplies its own local derivative
  inside the stage. A gain scheduled from seeded state carries the
  schedule's partials into the Jacobian like any other wired input, and a
  model that wants it held at its nominal value routes it through `Freeze`.
- **The unit delay's tier caveat** ([§5.5][s5-5], [§13.7][s13-7];
  [D-348][d-348]). A unit delay is a modeling decision, not a transparent
  wire, because the delayed signal is genuinely sampled. Inserting a
  `UnitDelay` into a *continuous* loop moves that signal onto the discrete
  tier and inserts a `Δt_base`-scale zero-order hold into the model's
  mathematics. The cycle diagnostic therefore says so rather than offering
  the remedy as free.
- **Unwired contributors** ([§6.2][s6-2]; [D-084][d-084], [D-323][d-323],
  [D-037][d-037]). A
  [summing junction](#g-summing-junction) makes its own bookkeeping loud. A
  contributor it counts but nobody wires is an unconnected-input error. A
  contributor's output that nobody wires stays legal and silent, as any
  unconnected output does. Every contribution a total includes is a declared
  wire, so a contributor whose output nobody wires drops out of the total
  silently. Fold order is the positional order of the junction's inputs.
  Reassigning contributors to different inputs changes summation order, hence
  bits.

For periphery authors and consumers:

- **Levels, never deltas** ([§11.4][s11-4]; [D-024][d-024]). Staged input values are levels
  (`press_count = 17`, never `presses += 1`), which makes them idempotent
  under [coalescing](#g-coalescing). Button edges ride as monotonic counters.
  Cross-datum state such as press counters and edge detection lives in the
  [device](#g-device) struct. The loop maintains it, and it arrives *inside*
  the datum, because `map_input` is pure ([§11.6][s11-6]).
- **The device loop idioms** ([§11.6][s11-6], [§12.4][s12-4];
  [D-373][d-373]). Loop on
  `running(handle)`. Make every blocking call interruptible, through an
  `unblock!` override or timeouts. Voluntary exit is returning. There are
  three canonical shapes. Timer-poll sleeps, polls and stages. Source-driven
  blocks on your socket, and `unblock!` closes it. Boundary-driven calls
  `wait_next_snapshot`, gathers and sends. A forgotten predicate check
  surfaces as `DeviceJoinTimeout` with your device's name. A stall surfaces as
  a stale heartbeat.
- **What `shutdown!` tolerates** ([§11.6][s11-6], [§12.4][s12-4];
  [D-268][d-268]). `shutdown!` closes only what is open. The framework runs `shutdown!` on every exit path,
  including your own `init!`'s failure. A throw half-way through acquisition
  hands the half-built device straight back to you. So guard each release
  (`isopen`, a `nothing` handle) rather than assuming initialization
  completed. You do *not* carry the converse burden. `init!` owes no cleanup
  of its own. An [operator interrupt](#g-operator-interrupt) (Ctrl-C in an
  interactive session) can repeat a `shutdown!` call, and it can release a
  device whose `init!` never began. The same tolerance covers both calls,
  and neither is reported.
- **[Binding](#g-binding) traits and mappings** ([§11.6][s11-6];
  [D-382][d-382]). Binding traits are declarations, and mappings are your own
  idiom. Keep
  `is_input`/`is_output`/`is_greedy` trivial, a literal or a flag read off a
  field fixed at the constructor call. The framework reads them only during
  `attach!`, and cross-checks each against the enumeration method it implies.
  `map_input`/`map_output` are a different sort of thing. They are
  conventions of the loop idiom, called only by your own `loop` and never by
  the framework. The names are worth keeping for readers, and nothing
  enforces them.
- **[Bad datum](#g-bad-datum) vs. bug** ([§11.6][s11-6], [§13.4][s13-4];
  [D-105][d-105]).
  Catch what your parser can throw, call
  `report!(handle, MalformedDatum(cause))`, stage nothing and continue. Let
  everything else propagate, and the wrapper makes it `DeviceCrash`.
  Tolerating everything hides bugs as "device attached, nothing happens".
  Tolerating nothing kills a live link on its first truncated datagram.
- **[Derived liveness](#g-derived-liveness)** ([§11.7][s11-7];
  [D-045][d-045]). A widget is
  live iff its [port](#g-port)'s feed chain terminates in a root input inside the GUI's
  own [claim](#g-claim) in the run's frozen partition. There is no per-port
  marking, and unexported ports are unpokeable.
- **The two observation sides** ([§11.2][s11-2], [§13.5][s13-5],
  [§14.2][s14-2], [§14.7][s14-7]; [D-414][d-414], [D-065][d-065]). A deep
  snapshot path is an *inspection* read. It sees everything and promises
  nothing across builds ([§13.3][s13-3]). An exported output
  [face](#g-face) is an *integration* read. It carries curated,
  writer-independent meaning, and it is the only shield against silent
  semantic drift. Bind faces in anything meant to outlive the current build.
  The store [selectors](#g-selector) (`get_state`/`get_deriv`) belong to
  neither side. They read live stores, never snapshots (the source rule,
  [§14.4][s14-4]). A service user's path, in a condition, a trim read or a
  tap, may reach any depth. No check refuses a deep path past a
  [generically held](#g-generic-holding) field (one held through a
  non-concrete field type). Ownership alone is convention, so keeping a deep
  path inside an owned subtree is idiomatic rather than machine-checked. As
  authoring guidance, an equilibrium equation meant to survive substitution at a generic
  [seam](#g-seam) (a narrow, named interface) reads a face.
- **Publications, not frames** ([§12.3][s12-3], [§10.4][s10-4];
  [D-028][d-028], [D-230][d-230]). The
  [boundary counter](#g-boundary-counter) behind the
  [next-snapshot wait](#g-next-snapshot-wait) counts published boundaries,
  that is grid, [`t*`](#g-t) (an event's crossing instant inside a step) and boundary
  zero, not [frames](#g-frame). Consecutive wakes are therefore not
  necessarily `h` apart. A slow consumer skips boundaries and always receives
  the current world. A snapshot carries the trajectory's published-boundary
  ordinal with `t`, so any holder of a snapshot indexes it without consulting
  the loop. A new trajectory restarts the ordinal at zero. The counter is
  never reset across trajectories, and its absolute value is nowhere
  normative.
- **Conditioning upstream, aircraft semantics in-model** ([§11.4][s11-4];
  [D-045][d-045]). Mappings are binding data, not shaping code. A mapping
  is a declarative table from axis or button to root input, with per-axis
  conditioning parameters such as deadzone and expo strength. A face's
  meaning is writer-independent, so faces carry *post-conditioning*
  semantics. A GUI slider or a script writes the same command a curved stick
  delivers. That GUI-parity test places conditioning upstream. Aircraft-semantic
  derivation must *not* ride along. A command fan-out is the case in point.
  It is flight control system design and lives in-model.

For service users:

- **Post-commit trim checks** ([§14.7][s14-7], [§14.9][s14-9];
  [D-262][d-262], [D-139][d-139], [D-417][d-417]). Under analytic
  elimination, the condition math pins the targeted state coordinates from
  the targets and the
  atmosphere the user's `params` record holds, while the world measures
  against the atmosphere the [baseline](#g-baseline) wrote. If the two
  disagree, the residuals vanish at a true equilibrium that is not the
  requested point, and nothing in the residual system can tell. The service
  reports checks once, at the committed state, and never solves them. A check
  reading EAS (equivalent airspeed) from the world's airdata at the committed
  state, minus the requested value, is where a world measurement meets the
  request. A check earns its place only on a quantity the world measures by
  itself, and on one the condition writes directly from a decision it is
  always zero. The problem receives the environment and never
  writes it.
- **The held discrete tier** ([§14.10][s14-10], [§14.7][s14-7],
  [§14.8][s14-8], [§8.2][s8-2]; [D-213][d-213], [D-063][d-063],
  [D-072][d-072], [D-073][d-073]). Trim and
  linearization differentiate the continuous dynamics with the discrete state
  held. A frozen discrete output is a constant with zero partials, and for
  that question it is the exact answer. Differentiating through the discrete
  side means differentiating a different object, the sampled-data step map,
  which is [recorded, not built](#g-recorded-not-built). The services hold
  the discrete tier through the solve, so a controller's stores are not
  decisions. The values that keep a closed loop at rest, such as each
  integrator's trim value, are the author's to derive and write into the
  condition.
- **[What-if replay](#g-what-if-replay) from `init!`** ([§12.7][s12-7];
  [D-274][d-274], [D-391][d-391]). Replaying against the same structure with changed
  parameters is spelled as `init!` of the modified model under the authored
  condition, then `replay!(sim, trc; restore = false)`. The
  [trace](#g-trace) is not self-sufficient for it. Its
  [checkpoint](#g-checkpoint) holds the recording model's state after
  boundary zero, so the authored condition comes from outside. The default
  form restores that state instead. *Structural* mismatch is an error, and
  *parametric* difference is not.

---

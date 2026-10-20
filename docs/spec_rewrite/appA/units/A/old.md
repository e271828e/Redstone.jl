# Appendices

The appendices are reference matter, not a fifth part. [Appendix A][sA]
indexes the semantic contracts an author must know and no check can enforce.
[Appendix B][sB] is the API synopsis. Neither is a second home. Each entry is
normative only where its owning section settles it. [Appendix C][sC] is the
exception. Its diagnostic kind set is made normative here, and acceptance
tests match on it. [Appendix D][sD] is the glossary. It is non-normative, and
the owning section wins wherever the two diverge.

## Appendix A. Taught contracts: the author-facing index

The build pipeline enforces structure. It checks declarations, wiring, types
and conformance. A residue of *semantic* facts remains that no check can
enforce. An author who knows them writes component and periphery code that
comes out right. An author who does not produces defensive delays, duplicated
math or mistimed samples, and no diagnostic fires anywhere. The
IMU's boundary-sampling note ([§8.6][s8-6]) is the archetype. This appendix is an
**index, not a second home**. Each contract gets one recall line here, and its
normative statement stays in the owning section. That applies the
one-home-per-datum rule to the document itself.

For component authors:

- **The stage funnel** ([§5.2][s5-2], [§5.3][s5-3]). The stage name at its tier fixes the
  maximal legal view set. The component's declarations narrow that set to the
  bundle. The signature's destructuring narrows the bundle to the actual
  reads. In short, stage name at its tier ⊇ bundle ⊇ destructured reads. So
  "no `direct` in the name" *is* the no-feedthrough property. The teaching
  line runs as follows. Stage 1 publishes what you know from state alone.
  Stage 2 adds what needs inputs. Your dynamics read your own published
  results instead of recomputing them.
- **One home per datum** ([§5.2][s5-2]). The signal table holds
  *produced* signals only, never transported ones ([§4.3][s4-3]). The buffer holds `x`, the
  `s` and `m` stores hold `s` and `m`, and the table holds signals. No store
  mirrors another.
- **The value-level constructor** ([§8.2][s8-2]). A field-emitting component
  ships the map from (component, input values) to handle as a plain public
  function, and its output stage merely calls it. The condition math
  ([§14.1][s14-1]) must be able to produce the sweep's exact handle outside
  any sweep. Only the component's author can write that function without
  re-creating the drift class.
- **Boundary sampling** ([§10.5][s10-5]/[§10.6][s10-6]; worked example
  [§8.6][s8-6]). "Sampling at `t_k`" means sampling the post-integration,
  post-projection, stage-1-fresh state. A due tick's gated stages run inside
  the boundary sweep and sample the *completed* boundary. An author who
  distrusts that guarantee, with a defensive one-tick delay or a re-derivation
  inside the sampler, silently degrades the model.
- **Interval alignment** ([§14.5][s14-5]). A boundary's `s_update` is the
  *outgoing* transition. At tick `t_k` it consumes the completed boundary's
  samples and produces `s_{k+1}`, the value the component's *next* tick
  decodes. That is the sampled-data `z⁻¹` delay, by construction. Hence
  `s_update` runs at boundary zero. That run is the `t₀` sample's only
  chance.
- **Same-tick reset consumption** ([§5.3][s5-3]), on the *discrete tier*. A
  commanded reset of a discrete component's `s` is an input. For same-tick
  output semantics the *output stage* consumes that input, overriding the
  state-derived path, and `s_update` stores the matching `s⁺`. A reset
  honored only in `s_update` reaches the outputs one tick late, and the
  plant integrates a full step under the stale command. Both spellings are
  legal, and they mean different things. The continuous tier has no such
  choice (next entry).
- **A continuous component's state reset is an event** ([§3.1][s3-1],
  [§10.6][s10-6], [§5.3][s5-3]). Only handlers write `x`. So even a
  *commanded* reset, where the condition arrives as an ordinary `Bool` input
  (weight-on-wheels is the shipped instance), is spelled as an event whose
  guard reads that input. The discrete tier's input spelling does not
  transfer. The reason is semantic, not stylistic. Only the discrete tier's
  update stage is already a jump map, so a reset there is just another value
  for `s⁺`. A continuous state jump, by contrast, must be solver-visible and
  applied *between* integration segments. Every hybrid tool converges on that
  flow/jump split.
  Simulink applies its reset ports through zero-crossing events plus a solver
  restart, and Modelica's `reinit` is syntactically legal only inside a
  `when`. There is no stale-output hazard to manage either. [§10.6][s10-6]
  re-sweeps outputs to quiescence after handlers, so a continuous edge-reset
  is same-boundary by construction.
- **Guard predicates, edges and priors** ([§2.3][s2-3], [§10.6][s10-6]). A
  guard defines a predicate, either as a `Bool` or as a sign value `σ` with
  positive meaning holding. The form chosen *is* the detection policy. A
  `Bool` guard is boundary-detected, a sign guard is localized. Events fire on
  *edges* from not-holding to holding, judged against per-event priors, where
  the prior is the previous boundary's quiescent sample. A predicate that
  keeps holding fires once, at the boundary where it first held. Boundary zero
  sets every prior to not-holding, so a predicate already holding in the
  authored state fires at `t₀`. The opposite crossing direction is a second
  event with the negated guard.
- **Handler-phase visibility** ([§5.3][s5-3], [§10.6][s10-6]). A handler
  executes against exactly the world its guard fired on. Its own `y`, foreign
  `u` and its own `x`/`m` all come from the firing round's sweep. A component
  fires at most one event per round. Its later own events are re-decided
  against the next round's sweep, one round per causal link, within and across
  components alike. Only sweeps write the signal table.
- **Stage totality** ([§9.3][s9-3]; [§13.4][s13-4], [§13.5][s13-5]). Stage
  code is total over type-valid inputs. The probe evaluates every user
  function against values chosen for their types alone. A value-level throw
  is a build failure there and a `StepError` at runtime. Physical plausibility
  is a published stop request. Self-consistency asserts belong in
  tests. Parameter validation belongs at instance construction, not inside a
  stage.
- **Stop-request sampling** ([§13.5][s13-5]). Stop requests are read in
  completed-boundary snapshots. Declare a sign-form (localized) event if the
  stop needs localizing. Every request stops the run unless the advance
  ignores it.

For periphery authors and consumers:

- **Levels, never deltas** ([§11.4][s11-4]). Staged input values are levels
  (`press_count = 17`, never `presses += 1`), which makes them idempotent
  under coalescing. Button edges ride as monotonic counters. Cross-datum
  state such as press counters and edge detection lives in the device struct.
  The loop maintains it, and it arrives *inside* the datum, because
  `map_input` is pure ([§11.6][s11-6]).
- **The device loop idioms** ([§11.6][s11-6], [§12.4][s12-4]). Loop on
  `running(handle)`. Make every blocking call interruptible, through an
  `unblock!` override or timeouts. Voluntary exit is returning. There are
  three canonical shapes. Timer-poll sleeps, polls and stages. Source-driven
  blocks on your socket, and `unblock!` closes it. Boundary-driven calls
  `wait_next_snapshot`, gathers and sends. A forgotten predicate check
  surfaces as `DeviceJoinTimeout` with your device's name. A stall surfaces as
  a stale heartbeat.
- **`shutdown!` closes only what is open** ([§11.6][s11-6], [§12.4][s12-4]).
  The framework runs `shutdown!` on every exit path, including your own
  `init!`'s failure. A throw half-way through acquisition hands the half-built
  device straight back to you. So guard each release (`isopen`, a `nothing`
  handle) rather than assuming initialization completed. You do *not* carry
  the converse burden. `init!` owes no cleanup of its own.
- **Binding traits are declarations, mappings are your own idiom**
  ([§11.6][s11-6], [D-382][d-382]). Keep `is_input`/`is_output`/`is_greedy` trivial, a
  literal or a flag read off a field fixed at the constructor call. The
  framework reads them only during `attach!`, and cross-checks each against
  the enumeration method it implies. `map_input`/`map_output` are a different
  kind of thing. They are conventions of the loop idiom, called only by your
  own `loop` and never by the framework. The names are worth keeping for
  readers, and nothing enforces them.
- **Bad datum vs. bug** ([§11.6][s11-6], [§13.4][s13-4]). Catch what your
  parser can throw, call `report!(handle, MalformedDatum(cause))`, stage
  nothing and continue. Let everything else propagate, and the wrapper makes
  it `DeviceCrash`. Tolerating everything hides bugs as "device attached,
  nothing happens". Tolerating nothing kills a live link on its first
  truncated datagram.
- **Derived liveness** ([§11.7][s11-7]). A widget is live iff its port's feed
  chain terminates in a root input inside the GUI's own claim in the run's
  frozen partition. There is no per-port marking, and unexported ports are
  unpokeable.
- **The two observation sides** ([§11.2][s11-2], [§13.5][s13-5]). A deep
  snapshot path is an *inspection* read. It sees everything and promises
  nothing across builds ([§13.3][s13-3]). An exported output face is an *integration* read. It
  carries curated, writer-independent meaning, and it is the only shield
  against silent semantic drift. Bind faces in anything meant to outlive the
  current build. The store selectors (`get_state`/`get_deriv`) belong to
  neither side. They read live stores, never snapshots (the source rule,
  [§14.4][s14-4]).

---


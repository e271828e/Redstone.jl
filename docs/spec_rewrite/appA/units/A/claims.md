old: # Appendices
tag: X

old: The appendices are reference matter, not a fifth part.
tag: F

old: Appendix A indexes the semantic contracts an author must know and no check can enforce.
tag: F

old: Appendix B is the API synopsis.
tag: F

old: Neither is a second home.
tag: F

old: Each entry is normative only where its owning section settles it.
new: Each item is normative only where its owning section settles it.
tag: R
ruling: coordinator 2026-10-20, adopting a rulings.md proposal

old: Appendix C is the exception.
tag: F

old: Its diagnostic kind set is made normative here, and acceptance tests match on it.
tag: F

old: Appendix D is the glossary.
tag: F

old: It is non-normative, and the owning section wins wherever the two diverge.

old: ## Appendix A. Taught contracts: the author-facing index
tag: X
note: heading kept; no anchor added (R7)

old: The build pipeline enforces structure.
tag: F

old: It checks declarations, wiring, types and conformance.
tag: F

old: A residue of semantic facts remains that no check can enforce.
tag: F

old: An author who knows them writes component and periphery code that comes out right.
new: A component or periphery author who knows them writes code that comes out right
tag: R
ruling: R1
note: same claim, subject reworded so the service-user clause can follow; the claim's scope stays component and periphery authors

old: An author who does not produces defensive delays, duplicated math or mistimed samples, and no diagnostic fires anywhere.
tag: F

old: The IMU's boundary-sampling note (§8.6) is the archetype.
tag: F

old: This appendix is an index, not a second home.
note: bold dropped: nothing in A but the labels is bold (brief, deviations); index, not a second home linked to its glossary anchor

old: Each contract gets one recall line here, and its normative statement stays in the owning section.
tag: F

old: That applies the one-home-per-datum rule to the document itself.
tag: F

old: For component authors:
tag: X

old: - The stage funnel (§5.2, §5.3).
new: - The stage funnel (§5.2, §5.3; D-341).
tag: C
newcites: §5.2 §5.3 D-341
note: entry added to the owners parenthetical; rulings.md quotes the words that carry it

old: The stage name at its tier fixes the maximal legal view set.
new: The stage name at its tier (the continuous or discrete side) fixes the maximal legal view set.
note: first-use glossary links for stage and tier, with the tier gloss declared below

old: The component's declarations narrow that set to the bundle.
tag: F

old: The signature's destructuring narrows the bundle to the actual reads.
tag: F

old: In short, stage name at its tier ⊇ bundle ⊇ destructured reads.
tag: F

old: So "no `direct` in the name" is the no-feedthrough property.
tag: F

old: The teaching line runs as follows.
tag: X

old: Stage 1 publishes what you know from state alone.
tag: F

old: Stage 2 adds what needs inputs.
tag: F

old: Your dynamics read your own published results instead of recomputing them.
tag: F

old: - One home per datum (§5.2).
new: - One home per datum (§5.2; D-035).
tag: C
newcites: §5.2 D-035
note: entry added to the owners parenthetical; rulings.md quotes the words that carry it

old: The signal table holds produced signals only, never transported ones (§4.3).
tag: F

old: The buffer holds `x`, the `s` and `m` stores hold `s` and `m`, and the table holds signals.
tag: F

old: No store mirrors another.
tag: F

old: - The value-level constructor (§8.2).
new: - The value-level constructor (§8.2; D-139).
tag: C
newcites: §8.2 D-139
note: entry added to the owners parenthetical; rulings.md quotes the words that carry it

old: A field-emitting component ships the map from (component, input values) to handle as a plain public function, and its output stage merely calls it.
tag: F

old: The condition math (§14.1) must be able to produce the sweep's exact handle outside any sweep.
tag: F

old: Only the component's author can write that function without re-creating the drift class.
tag: F

old: - Boundary sampling (§10.5/§10.6; worked example §8.6).
new: - Boundary sampling (§10.5/§10.6; worked example §8.6; D-056).
tag: C
newcites: §10.5 §10.6 §8.6 D-056
note: entry added to the owners parenthetical; rulings.md quotes the words that carry it

old: "Sampling at `t_k`" means sampling the post-integration, post-projection, stage-1-fresh state.
tag: F

old: A due tick's gated stages run inside the boundary sweep and sample the completed boundary.
tag: F

old: An author who distrusts that guarantee, with a defensive one-tick delay or a re-derivation inside the sampler, silently degrades the model.
tag: F

old: - Interval alignment (§14.5).
new: - Interval alignment (§14.5; D-067, D-273).
tag: R
ruling: R3
newcites: §14.5 D-067 D-273

old: A boundary's `s_update` is the outgoing transition.
tag: F

old: At tick `t_k` it consumes the completed boundary's samples and produces `s_{k+1}`, the value the component's next tick decodes.
tag: F

old: That is the sampled-data `z⁻¹` delay, by construction.
tag: F

old: Hence `s_update` runs at boundary zero.
tag: F

old: That run is the `t₀` sample's only chance.
tag: F

old: - Same-tick reset consumption (§5.3), on the discrete tier.
new: - Same-tick reset consumption (§5.3; D-089), on the discrete tier.
tag: R
ruling: R4
newcites: §5.3 D-089

old: A commanded reset of a discrete component's `s` is an input.
tag: F

old: For same-tick output semantics the output stage consumes that input, overriding the state-derived path, and `s_update` stores the matching `s⁺`.
tag: F

old: A reset honored only in `s_update` reaches the outputs one tick late, and the plant integrates a full step under the stale command.
tag: F

old: Both spellings are legal, and they mean different things.
tag: F

old: The continuous tier has no such choice (next entry).
new: The continuous tier has no such choice (the next item).
tag: R
ruling: coordinator 2026-10-20, adopting a rulings.md proposal

old: (§3.1, §10.6, §5.3).
new: - Continuous-tier resets (§3.1, §10.6, §5.3; D-141).
tag: R
ruling: R4
newcites: §3.1 §10.6 §5.3 D-141
note: the ruling-sentence lead-in becomes a label

old: - A continuous component's state reset is an event
new: A continuous component's state reset is an event.
tag: R
ruling: R4
note: the old lead-in sentence kept as the bullet's first plain sentence; continuous component linked at first use

old: Only handlers write `x`.
tag: F

old: So even a commanded reset, where the condition arrives as an ordinary `Bool` input (weight-on-wheels is the shipped instance), is spelled as an event whose guard reads that input.
new: So even a commanded reset, where the reset command arrives as an ordinary `Bool` input (weight-on-wheels is the shipped instance), is spelled as an event whose guard reads that input.
tag: R
ruling: coordinator 2026-10-20, adopting a rulings.md proposal

old: The discrete tier's input spelling does not transfer.
tag: F

old: The reason is semantic, not stylistic.
tag: F

old: Only the discrete tier's update stage is already a jump map, so a reset there is just another value for `s⁺`.
tag: F

old: A continuous state jump, by contrast, must be solver-visible and applied between integration segments.
tag: F

old: Every hybrid tool converges on that flow/jump split.
tag: F

old: Simulink applies its reset ports through zero-crossing events plus a solver restart, and Modelica's `reinit` is syntactically legal only inside a `when`.
tag: F

old: There is no stale-output hazard to manage either.

old: §10.6 re-sweeps outputs to quiescence after handlers, so a continuous edge-reset is same-boundary by construction.

old: - Guard predicates, edges and priors (§2.3, §10.6).
new: - Guard predicates, edges and priors (§2.3, §10.4, §10.6; D-365).
tag: R
ruling: R3
newcites: §2.3 §10.4 §10.6 D-365

old: A guard defines a predicate, either as a `Bool` or as a sign value `σ` with positive meaning holding.
new: A guard defines a predicate, either as a `Bool` or as a sign value `σ`, which holds when `σ ≥ 0`.
tag: R
ruling: R3
note: 'positive meaning holding' replaced by the convention §2.3 states (frozen 374-376)

old: The form chosen is the detection policy.
tag: F

old: A `Bool` guard is boundary-detected, a sign guard is localized.
tag: F

old: Events fire on edges from not-holding to holding, judged against per-event priors, where the prior is the previous boundary's quiescent sample.
tag: F

old: A predicate that keeps holding fires once, at the boundary where it first held.
tag: F

old: Boundary zero sets every prior to not-holding, so a predicate already holding in the authored state fires at `t₀`.
tag: F

old: The opposite crossing direction is a second event with the negated guard.
tag: F

old: - Handler-phase visibility (§5.3, §10.6).
new: - Handler-phase visibility (§5.3, §10.6; D-154).
tag: C
newcites: §5.3 §10.6 D-154
note: entry added to the owners parenthetical; rulings.md quotes the words that carry it

old: A handler executes against exactly the world its guard fired on.
tag: F

old: Its own `y`, foreign `u` and its own `x`/`m` all come from the firing round's sweep.
tag: F

old: A component fires at most one event per round.
tag: F

old: Its later own events are re-decided against the next round's sweep, one round per causal link, within and across components alike.
tag: F

old: Only sweeps write the signal table.
tag: F

old: - Stage totality (§9.3; §13.4, §13.5).
new: - Stage totality (§9.3; §13.4, §13.5; D-142).
tag: C
newcites: §9.3 §13.4 §13.5 D-142
note: entry added to the owners parenthetical; rulings.md quotes the words that carry it

old: Stage code is total over type-valid inputs.
tag: F

old: The probe evaluates every user function against values chosen for their types alone.
tag: F

old: A value-level throw is a build failure there and a `StepError` at runtime.
tag: F

old: Physical plausibility is a published stop request.
tag: F

old: Self-consistency asserts belong in tests.
tag: F

old: Parameter validation belongs at instance construction, not inside a stage.
tag: F

old: - Stop-request sampling (§13.5).
new: - Stop-request sampling (§13.5; D-316).
tag: C
newcites: §13.5 D-316
note: entry added to the owners parenthetical; rulings.md quotes the words that carry it

old: Stop requests are read in completed-boundary snapshots.
new: Stop requests are read in completed-boundary snapshots (the immutable per-boundary publications).
note: snapshot gloss declared below

old: Declare a sign-form (localized) event if the stop needs localizing.
tag: F

old: Every request stops the run unless the advance ignores it.
tag: F

old: For periphery authors and consumers:
tag: X

old: - Levels, never deltas (§11.4).
new: - Levels, never deltas (§11.4; D-024).
tag: C
newcites: §11.4 D-024
note: entry added to the owners parenthetical; rulings.md quotes the words that carry it

old: Staged input values are levels (`press_count = 17`, never `presses += 1`), which makes them idempotent under coalescing.
tag: F

old: Button edges ride as monotonic counters.
tag: F

old: Cross-datum state such as press counters and edge detection lives in the device struct.
tag: F

old: The loop maintains it, and it arrives inside the datum, because `map_input` is pure (§11.6).
tag: F

old: - The device loop idioms (§11.6, §12.4).
new: - The device loop idioms (§11.6, §12.4; D-373).
tag: C
newcites: §11.6 §12.4 D-373
note: entry added to the owners parenthetical; rulings.md quotes the words that carry it

old: Loop on `running(handle)`.
tag: F

old: Make every blocking call interruptible, through an `unblock!` override or timeouts.
tag: F

old: Voluntary exit is returning.
tag: F

old: There are three canonical shapes.
tag: F

old: Timer-poll sleeps, polls and stages.
tag: F

old: Source-driven blocks on your socket, and `unblock!` closes it.
tag: F

old: Boundary-driven calls `wait_next_snapshot`, gathers and sends.
tag: F

old: A forgotten predicate check surfaces as `DeviceJoinTimeout` with your device's name.
tag: F

old: A stall surfaces as a stale heartbeat.
tag: F

old: is open (§11.6, §12.4).
new: - What `shutdown!` tolerates (§11.6, §12.4; D-268).
newcites: §11.6 §12.4 D-268
tag: R
ruling: coordinator 2026-10-20
note: ruling-sentence label replaced by a topic label

old: - `shutdown!` closes only what is open
new: `shutdown!` closes only what is open.
tag: R
ruling: R3
newcites: §11.6 §12.4 D-268

old: The framework runs `shutdown!` on every exit path, including your own `init!`'s failure.
tag: F

old: A throw half-way through acquisition hands the half-built device straight back to you.
tag: F

old: So guard each release (`isopen`, a `nothing` handle) rather than assuming initialization completed.
tag: F

old: You do not carry the converse burden.
tag: F

old: `init!` owes no cleanup of its own.
tag: F

old: (§11.6, D-382).
new: - Binding traits and mappings (§11.6; D-382).
tag: R
ruling: coordinator 2026-10-20
note: ruling-sentence label replaced by a topic label; comma in the owners parenthetical made a semicolon

old: - Binding traits are declarations, mappings are your own idiom
new: Binding traits are declarations, and mappings are your own idiom.
tag: R
ruling: coordinator 2026-10-20

old: Keep `is_input`/`is_output`/`is_greedy` trivial, a literal or a flag read off a field fixed at the constructor call.
tag: F

old: The framework reads them only during `attach!`, and cross-checks each against the enumeration method it implies.
tag: F

old: `map_input`/`map_output` are a different kind of thing.
new: `map_input`/`map_output` are a different sort of thing.
tag: R
ruling: coordinator 2026-10-20, adopting a rulings.md proposal

old: They are conventions of the loop idiom, called only by your own `loop` and never by the framework.
tag: F

old: The names are worth keeping for readers, and nothing enforces them.
tag: F

old: - Bad datum vs. bug (§11.6, §13.4).
new: - Bad datum vs. bug (§11.6, §13.4; D-105).
tag: C
newcites: §11.6 §13.4 D-105
note: entry added to the owners parenthetical; rulings.md quotes the words that carry it

old: Catch what your parser can throw, call `report!(handle, MalformedDatum(cause))`, stage nothing and continue.
tag: F

old: Let everything else propagate, and the wrapper makes it `DeviceCrash`.
tag: F

old: Tolerating everything hides bugs as "device attached, nothing happens".
tag: F

old: Tolerating nothing kills a live link on its first truncated datagram.
tag: F

old: - Derived liveness (§11.7).
new: - Derived liveness (§11.7; D-045).
tag: C
newcites: §11.7 D-045
note: entry added to the owners parenthetical; rulings.md quotes the words that carry it

old: A widget is live iff its port's feed chain terminates in a root input inside the GUI's own claim in the run's frozen partition.
tag: F

old: There is no per-port marking, and unexported ports are unpokeable.
tag: F

old: - The two observation sides (§11.2, §13.5).
new: - The two observation sides (§11.2, §13.5, §14.2, §14.7; D-414, D-065).
tag: R
ruling: R3
newcites: §11.2 §13.5 §14.2 §14.7 D-414 D-065

old: A deep snapshot path is an inspection read.
tag: F

old: It sees everything and promises nothing across builds (§13.3).
tag: F

old: An exported output face is an integration read.
tag: F

old: It carries curated, writer-independent meaning, and it is the only shield against silent semantic drift.
tag: F

old: Bind faces in anything meant to outlive the current build.
tag: F

old: The store selectors (`get_state`/`get_deriv`) belong to neither side.
tag: F

old: They read live stores, never snapshots (the source rule, §14.4).

old: ---
tag: X

added: and so does a service user, who writes conditions, trim problems, taps and linearization calls.

added: The index has three groups, for component authors, for periphery authors and consumers, and for service users.

added: - The startup hole (§10.5, §14.5; D-205).

added: An offset component's first tick is at `Φ·Δt_base`, where `Φ` is its phase in base ticks and `Δt_base` the base tick period.

added: Until then its cells hold what it published at boundary zero (the initialization boundary at `t₀`).

added: Its output stages still run at `t₀`, evaluated from the authored world.

added: A startup hole, a component dark until its first tick, is a modeling decision.

added: The author spells it as a validity flag or a mode, and the framework withholds no publication by default.

added: The same placement fixes what a discrete store holds at rest.

added: After any boundary the store holds the state the component's next due tick decodes, and its cell holds the sample its last tick published.

added: A counter due at boundary zero and authored at 0 holds 1 after `init!` alone.

added: A discrete store copied off a stopped run into a condition therefore starts that component one tick ahead.

added: A state what-if goes through `overlay!` instead, which writes the condition's stores onto the stopped run's own and continues it as a fresh trajectory, with an overlaid discrete store as the next tick's state, so no copy through a condition and `init!` is needed (§12.6, D-429).

added: - Undeclared modes (§3.1, §2.3; D-345, D-179).

added: A branch in the flow that switches on a continuous quantity, such as an integrator that stops accumulating once its output reaches a limit, is a mode change with no declared event.

added: It switches inside a step, at no boundary and against no prior, so nothing localizes it and nothing records it.

added: Such a switch is spelled as a mode moved by an event, or as a branch on another component's mode-derived output, which changes only when that component's events fire.

added: Boundary detection is exact for a guard whose value within a step depends only on modes, root inputs and held discrete outputs.

added: A guard that reads an input fed by continuous state or by time can cross inside a step.

added: A release predicate that must exclude equality, such as "the input points back into the range", does not hold at an input of exactly zero, but the sign form `-u` alone holds there.

added: It gates on the strict comparison instead, as `u < 0 ? -u : -one(u)`, or takes the `Bool` form `u < 0`, the same predicate boundary-detected.

added: - Latching and release pairs (§10.4, §10.6; D-290, D-181).

added: The predicate that latches the mode stays ungated on it.

added: Gated on the free mode, each handler hands the other guard a fresh edge, and the boundary chatters until the firing budget breaks the tie, under a `FiringBudget` warning.

added: - Never cache `Δt` (§10.5; D-019, D-291).

added: An author must never store `Δt`, or any `Δt`-derived coefficient, as a component parameter.

added: The discretized law reads `Δt` from the bundle and recomputes its derived coefficients per tick, which costs a few arithmetic operations.

added: Under scoped multipliers a component author cannot know the absolute rate, which does not exist until composition.

added: A discretized law is written to be stable at every period a deployment may assign, since the component cannot know its period at construction and no check compares the law against it.

added: - No mutable cache in a field handle (§4.4, §4.1; D-344).

added: A field handle must hold no mutable cache, such as a memoizing interpolator or a lazy loader.

added: Concurrent consumers and the GUI thread would race on it.

added: The remedy is to restructure the interpolant to be pure.

added: The rule is the author's, because the build does not look inside a field handle.

added: The bulk data a handle references stays read-only for the duration of the run.

added: - Contracts by type (§8.1, §9.7; D-297).

added: A leaf's contract declarations must be determined by the component's type, its type parameters included, and never by its field values.

added: Those declarations are `u_types`, `y_types` and `state_events`, and the shapes of `x_init`/`s_init`/`m_init`.

added: A contract that genuinely varies takes a type parameter, as `SumJunction{V, N}` and `Or{N}` do.

added: `ws_init` is the one exception.

added: The build reads each declaration once, against the concrete instance, so a value-dependent contract does not announce itself.

added: This is a rule authors keep, not a check the build can run.

added: - Deliberate stripping (§13.7, §14.10, §9.5; D-266).

added: `Freeze` strips partials, and its wire then declares a zero coupling in every Jacobian along that path.

added: That is a modeling decision, stated on the page rather than buried mid-expression.

added: Stripping mid-expression at a leaf left unpinned remains legal and remains unseen.

added: A sampler is no substitute, because it changes the model, holding the value between ticks.

added: Where the coupling matters to the Jacobian, a component keeps its input entry tolerant and supplies its own local derivative inside the stage.

added: A gain scheduled from seeded state carries the schedule's partials into the Jacobian like any other wired input, and a model that wants it held at its nominal value routes it through `Freeze`.

added: - The unit delay's tier caveat (§5.5, §13.7; D-348).

added: A unit delay is a modeling decision, not a transparent wire, because the delayed signal is genuinely sampled.

added: Inserting a `UnitDelay` into a continuous loop moves that signal onto the discrete tier and inserts a `Δt_base`-scale zero-order hold into the model's mathematics.

added: The cycle diagnostic therefore says so rather than offering the remedy as free.

added: - Unwired contributors (§6.2; D-084, D-323, D-037).

added: A summing junction makes its own bookkeeping loud.

added: A contributor it counts but nobody wires is an unconnected-input error.

added: A contributor's output that nobody wires stays legal and silent, as any unconnected output does.

added: Every contribution a total includes is a declared wire, so a contributor whose output nobody wires drops out of the total silently.

added: Fold order is the positional order of the junction's inputs.

added: Reassigning contributors to different inputs changes summation order, hence bits.

added: An operator interrupt (Ctrl-C in an interactive session) can repeat a `shutdown!` call, and it can release a device whose `init!` never began.

added: The same tolerance covers both calls, and neither is reported.

added: A service user's path, in a condition, a trim read or a tap, may reach any depth.

added: No check refuses a deep path past a generically held field (one held through a non-concrete field type).

added: Ownership alone is convention, so keeping a deep path inside an owned subtree is idiomatic rather than machine-checked.

added: As authoring guidance, an equilibrium equation meant to survive substitution at a generic seam (a narrow, named interface) reads a face.

added: - Publications, not frames (§12.3, §10.4; D-028, D-230).

added: The boundary counter behind the next-snapshot wait counts published boundaries, that is grid, `t` (an event's crossing instant inside a step) and boundary zero, not frames.

added: Consecutive wakes are therefore not necessarily `h` apart.

added: A slow consumer skips boundaries and always receives the current world.

added: A snapshot carries the trajectory's published-boundary ordinal with `t`, so any holder of a snapshot indexes it without consulting the loop.

added: A new trajectory restarts the ordinal at zero.

added: The counter is never reset across trajectories, and its absolute value is nowhere normative.

added: - Conditioning upstream, aircraft semantics in-model (§11.4; D-045).

added: Mappings are binding data, not shaping code.

added: A mapping is a declarative table from axis or button to root input, with per-axis conditioning parameters such as deadzone and expo strength.

added: A face's meaning is writer-independent, so faces carry post-conditioning semantics.

added: A GUI slider or a script writes the same command a curved stick delivers.

added: That GUI-parity test places conditioning upstream.

added: Aircraft-semantic derivation must not ride along.

added: A command fan-out is the case in point.

added: It is flight control system design and lives in-model.

added: For service users:

added: - Post-commit trim checks (§14.7, §14.9; D-262, D-139, D-417).

added: Under analytic elimination, the condition math pins the targeted state coordinates from the targets and the atmosphere the user's `params` record holds, while the world measures against the atmosphere the baseline wrote.

added: If the two disagree, the residuals vanish at a true equilibrium that is not the requested point, and nothing in the residual system can tell.

added: The service reports checks once, at the committed state, and never solves them.

added: A check reading EAS (equivalent airspeed) from the world's airdata at the committed state, minus the requested value, is where a world measurement meets the request.

added: A check earns its place only on a quantity the world measures by itself, and on one the condition writes directly from a decision it is always zero.

added: The problem receives the environment and never writes it.

added: - The held discrete tier (§14.10, §14.7, §14.8, §8.2; D-213, D-063, D-072, D-073).

added: Trim and linearization differentiate the continuous dynamics with the discrete state held.

added: A frozen discrete output is a constant with zero partials, and for that question it is the exact answer.

added: Differentiating through the discrete side means differentiating a different object, the sampled-data step map, which is recorded, not built.

added: The services hold the discrete tier through the solve, so a controller's stores are not decisions.

added: The values that keep a closed loop at rest, such as each integrator's trim value, are the author's to derive and write into the condition.

added: - What-if replay from `init!` (§12.7; D-274, D-391).

added: Replaying against the same structure with changed parameters is spelled as `init!` of the modified model under the authored condition, then `replay!(sim, trc; restore = false)`.

added: The trace is not self-sufficient for it.

added: Its checkpoint holds the recording model's state after boundary zero, so the authored condition comes from outside.

added: The default form restores that state instead.

added: Structural mismatch is an error, and parametric difference is not.

added: (the continuous or discrete side)

added: (the immutable per-boundary publications)

added: (the initialization boundary at `t₀`)

added: (Ctrl-C in an interactive session)

added: (one held through a non-concrete field type)

added: (a narrow, named interface)

added: (an event's crossing instant inside a step)

added: where `Φ` is its phase in base ticks and `Δt_base` the base tick period

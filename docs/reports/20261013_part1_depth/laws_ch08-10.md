# Semantic laws in chapters 8 to 10 that Part I omits or states only in part

Scope: spec.md §8, §9 and §10, checked against all of Part I (§1 to §7, about 16.7k words as extracted). The laws are listed in source order. "Status" says whether Part I states the law fully, partly or not at all. "Target" names the Part I section where its statement belongs.

## Laws missing or partial

**1. Initial values of the stores**
- Where: §8.2 State and mode declarations, "`x_init`, `s_init` and `m_init` seed the stores, which must have contents before the first sweep can run". Also "The overlays ... fall back to the declared values leaf by leaf".
- Law: A run starts from the declared initial values of `x`, `s` and `m`, with the applied condition overriding them leaf by leaf. Cells carry no initial value, because a sweep produces every cell.
- Status: Partly. §7.1 says "Each continuous component declares its state by value (`x_init`". §5.6 calls the probe point "the initial state". Neither section says that the run starts from these values or that a condition overrides them.
- Target: §7.1 and §7.3, or the §7 intro.

**2. Partials enter only by seeding**
- Where: §8.2 Output contracts, "Which *invocation* carries partials is still chosen by seeding ... never by typing". Also "Declared `Float64` initial values embed as zero-partial constants under non-nominal activations".
- Law: At a non-nominal scalar, derivatives flow only from the directions seeded for that evaluation. Declared initial values and parameters enter as constants with zero partials.
- Status: Partly. §7.2 gives the walked, pinned and exempt classes, and it says "A frozen discrete cell ... is a constant with zero partials". It never says that seeding is the only source of partials.
- Target: §7.2.

**3. A pinned leaf stops the gradient, and an embedded plain value is exact**
- Where: §8.2 Output contracts, "`Pinned{P}` ... It is whole-leaf freezing". §9.5 Deliberate stripping, "The pinned leaf is the schema-visible freeze". §9.5 Exact match and embed-accept, "The executor embeds a `Float64` as a zero-partial constant" and "The embedding is exact, not lenient".
- Law: A leaf declared pinned carries no partials at any scalar, so derivatives through it are zero. This is a declared stop-gradient. A walking leaf that yields a plain value had no seeded input reach it, so treating it as a zero-partial constant gives its true derivative.
- Status: Partly. §7.2 says "A contract leaf wrapped in the leaf marker `Pinned{P}` is deliberately pinned" and "Safety of the substitution rests on the embedding guarantee stated in §9.5". It never states the effect on derivatives.
- Target: §7.2.

**4. A stateless discrete leaf is a sampler**
- Where: §8.2 Completeness, "`s_init(::C) = (;)` makes it discrete, one that runs at its ticks and holds its outputs between them".
- Law: A discrete leaf with no state still computes its outputs only at its ticks and holds them between ticks. A stateless continuous leaf recomputes at every sweep. So the tier of a stateless leaf changes its values.
- Status: Partly. §3.1 says "Any facet may be empty", for the continuous class only. §3.2 gives the zero-order hold but never says the discrete facets may be empty.
- Target: §3.2.

**5. Root inputs have no default value**
- Where: §9.3, "Probe values never double as initial root-input values". Also "`Simulation` must not reach its first boundary with uninitialized root inputs".
- Law: A root input has no default. A condition or a writer must give it a value before the first boundary runs.
- Status: Partly. §6.1 says "Unconnected input ports are a build error, with no silent defaults" and names the root input as "the one legitimate terminus fed by no component". It says nothing of the root input's initial value.
- Target: §6.1 (Connections per port), or §4.1 where root inputs are defined.

**6. Only the nominal scalar runs ticks and events**
- Where: §9.2, "A `Model` at another scalar is a service's scratch ... stepped frame by frame with no ticks and no events". §9.4, "Discrete stages are gated off and hold `Float64` values" and "Guards and handlers never run".
- Law: At any scalar other than the nominal one, the model evaluates and steps its continuous dynamics alone. Every discrete cell holds its nominal value, and no guard or handler is evaluated.
- Status: Partly. §3.4 says "Under a `Dual` activation the discrete tier is held". §7.3 says "the discrete tier never runs at another scalar". Part I never says that events are also absent there.
- Target: §7.2.

**7. A mode return merges, and a state return replaces**
- Where: §9.5 Handler returns, "`m` may be partial" and "`m` lives in per-field stores where a partial merge is the natural write".
- Law: A handler may return only some mode fields, and the fields it omits keep their values. An `x` return replaces the whole continuous state.
- Status: Partly. §5.2 says "When `x` is present, the value is complete ... When `m` is present, the names-subset predicate applies". That states the check but not the merge.
- Target: §5.2, the handler return law.

**8. Bit-identical replay needs the same compiled code** (borderline)
- Where: §9.7 Compile cost, "Its trajectories differ from `-O2`'s by round-off, so a trace recorded at one level does not replay bit for bit at the other".
- Law: Replay is bit-identical only under the same compiled code. Runs at different optimization levels agree only to round-off.
- Status: Not at all. §1 claims a trace "replays any run bit-identically", and §2.2 makes the same claim, both without this qualifier.
- Target: §2.2.
- Why borderline: This is a platform caveat on run equivalence, not a law of the model.

**9. Frames, boundaries and a fixed grid**
- Where: §10.1, "A frame is one grid step" and "Every grid point is a boundary, but not every boundary is a grid point". §10.4 Endpoint policy, "Grid times are indexed, never accumulated" and "The remainder step targets the grid point".
- Law: Time advances in frames of fixed step `h` on the grid `tₖ = t₀ + k·h`. A boundary falls at every grid point, at every localized event time inside a frame, and once at `t₀`. The grid never shifts: a localized event leaves the next grid point where it was.
- Status: Partly. §5.3 defines a step boundary as "a published consistency point", and §1 says "integrated on a fixed step". Part I never defines the frame, never says that `t*` is a boundary and never says that the grid is fixed.
- Target: §5.3, Step boundaries.

**10. Fixed-step one-step integration** (borderline)
- Where: §10.2, "The backend uses one-step methods only" and "The first cut ships in-house fixed-step RK4 and Heun". Also "`RK4` is the default".
- Law: Continuous state advances by a fixed-step one-step method chosen at deployment, RK4 by default. Each step restarts from the published boundary state.
- Status: Partly. §1 says "integrated on a fixed step".
- Target: §2, the continuous-dynamics bullet.
- Why borderline: Part I may treat the discretization as an execution parameter. It still changes the values a run produces.

**11. A model without continuous state** (borderline)
- Where: §10.2 Models with no continuous state, "the integrate step degenerates to advancing `t` to the next boundary" and "The boundary machinery of sweeps, events and ticks runs unchanged".
- Law: A model with no continuous state still runs the full boundary sequence at every grid point. Only integration is empty.
- Status: Partly. §3.1 allows a component with no continuous state (an FSM), but no section says what happens to a whole model without it.
- Target: §5.3.
- Why borderline: It follows almost directly from the boundary sequence.

**12. Only the settled boundary is observable** (borderline)
- Where: §10.3, "External readers observe the signal table only at step boundaries" and "only after the boundary sequence completes". §10.6, "Earlier rounds' tentative values are internal scratch".
- Law: A run publishes only the settled state at the end of each boundary. Values from RK stages, trial evaluations and non-final event rounds are never published.
- Status: Partly. §5.3 has "a published consistency point" and "The round that detects quiescence leaves the table post-transition-consistent".
- Target: §5.3.
- Why borderline: It governs what an outside reader observes, not what the model computes. It does define a run's published output.

**13. Inputs are constant over each frame**
- Where: §10.4 Detection policy, "`u` changes only at the frame-top drain". §10.4 The `t*` boundary, "Staged inputs are not drained either". §10.7, "drained at the next frame top".
- Law: Root inputs change only at frame tops, before the frame integrates. They never change mid-step or at a `t*` boundary, and modes change only at boundaries. So a guard that reads only inputs and modes cannot cross mid-step, and boundary detection is exact for it.
- Status: Not at all. §2 says only "The runtime injects them asynchronously ... under the staging rules of §11".
- Target: §2, the external-inputs bullet.

**14. An edge caused by an input fires at the frame's end**
- Where: §10.4 The localization loop, "An epoch-caused edge is discarded, not degraded" and "the event fires inside tₙ₊₁'s ordinary iteration".
- Law: If a frame-top input change makes a localized predicate hold at the start of the frame, that frame has no crossing to find. The event fires at the frame's end boundary like a boundary-detected event.
- Status: Not at all.
- Target: §2.1.

**15. The trigger and the event time of a localized event**
- Where: §10.4 The trigger, "triggers when its predicate was not-holding at tₙ's quiescence and is holding at tₙ₊₁" and "before the due-gated boundary sweep refreshes any discrete cell". §10.4 Endpoint policy, "The root-finder returns the holding endpoint of its final bracket", "`t* = tₙ` is structurally impossible" and "`t* = tₙ₊₁` exactly is legitimate". §10.4, "Convergence is a relative bracket width" with default `1e-6`.
- Law: A localized event triggers when its prior was not-holding and its predicate holds at the step's end, while the discrete cells still hold their old values. Its time `t*` is the earliest instant found, to within `localization_tol·h`, at which the predicate holds. `t*` is strictly after `tₙ`, and a crossing exactly at `tₙ₊₁` is the ordinary grid boundary.
- Status: Partly. §2.1 says "The framework finds the crossing instant by root-finding".
- Target: §2.1.

**16. The state at `t*`, and where projection applies**
- Where: §10.4 The localization loop, "the cubic Hermite continuous extension". §10.4 The `t*` boundary, "Guard trial evaluations run against the raw interpolated state" and "If projection moves the state back across a guard, the event does not fire".
- Law: The state at `t*` is the step's cubic Hermite interpolant at that instant. Trial evaluations see the raw interpolated state. Projection applies only at the `t*` boundary, so a projection that moves the state back across the guard cancels the firing, and the run still publishes that boundary.
- Status: Partly. §5.3 states that trial evaluations run the interior sweep with held discrete cells. It says nothing about the interpolant or about projection at `t*`.
- Target: §2.1.

**17. Several localized events in one step, and the remainder**
- Where: §10.4 The localization loop, "Multiple events localizing in one step fire at the earliest `t*`" and "Later crossings re-localize on the remainder". §10.4 The `t*` boundary, "At `t*` the full §10.6 event phase runs", "The budget is fresh again at tₙ₊₁" and "Ticks are never due there".
- Law: When several localized events trigger in one step, the earliest `t*` becomes a boundary. There the full event iteration runs with a fresh firing budget, no tick is due, no input changes, and the settled state is published. Integration then resumes from the post-event state to the same grid point, and later crossings are localized again on that remainder.
- Status: Not at all.
- Target: §2.1.

**18. The localization budget**
- Where: §10.4 The localization budget, "Its default is 8" and "localization stops for the rest of that frame".
- Law: A frame allows at most `localization_budget` localizations, 8 by default. After that, further crossings in the frame fire at the frame's end boundary as if boundary-detected.
- Status: Not at all.
- Target: §2.1.

**19. Even crossings inside a step go unseen**
- Where: §10.4, "An even number of crossings within one step returns the predicate to not-holding at the boundary, so no edge is observed".
- Law: Edges are read by comparing samples at boundaries. An even number of crossings within one step therefore fires nothing, under either policy.
- Status: Partly. It follows from §2.1, which checks for an edge "against its prior at step boundaries only". Part I never states the consequence.
- Target: §2.1.

**20. What determines a trajectory**
- Where: §10.4 Deployment constants, "All three are recorded ..., because they determine the trajectory". §10.7, "A paced and an unpaced run with identical input traces produce bit-identical trajectories" and "Event localization runs identically paced or unpaced". §9.4, "Whether an activation is cached never changes a result". §10.4 and §10.6, "The degradation depends on the trajectory alone, never on wall clock".
- Law: A run's trajectory depends only on the model, its initial condition, the input trace and the deployment parameters. Those parameters are `h`, the base tick, the method, the localization tolerance and budget, and the firing budget. Pacing, wall-clock time and caching never change it, and the budgets degrade the same way paced or unpaced.
- Status: Partly. §2.1 says "Detection policy never depends on real-time pacing". §2.2 says "the same seed gives a bit-identical trajectory". Part I never lists the deployment parameters as determinants, and it never says that pacing in general leaves the trajectory unchanged.
- Target: §2.2.

**21. The harmonic grid**
- Where: §10.5 The base grid and the gate, "Every discrete component's period is an integer multiple of a base tick period" and "Ticks therefore land on step boundaries". §9.2, "the default `N_base = 1`".
- Law: Every discrete period is an integer multiple of a base tick. The base tick is itself `N_base ≥ 1` steps long, one step by default. So ticks occur only at frame tops, at every `N_base`-th one at most.
- Status: Partly. §5.5 glosses `Δt_base` as "the base tick period, an integer multiple of the continuous step".
- Target: §3.2.

**22. When a component is due**
- Where: §10.5, "A component is due at a boundary when `(tick − Φ) % D == 0`". §10.5 Due sets, the off-tick and `t*` cases ("the due set is empty"). §9.7, "the empty due set is arity selection".
- Law: Each discrete component ticks at base-tick indices `Φ, Φ+D, Φ+2D, …` and at no other boundary. No component is due at a frame top that is not a base tick, or at a `t*` boundary.
- Status: Not at all.
- Target: §3.2.

**23. How rates are declared and composed**
- Where: §10.5 The two declaration forms, the `Relative`/`Absolute` table. §10.5 Relative composition, "compiles to `D = K·D_s` and `Φ = Φ_s + φ·D_s`". §10.5 Anchors, "The child is severed from the enclosing scope's grid". §8.7, "an unlisted discrete child defaults to `Relative(1)`". §9.1, the fold table.
- Law: A discrete component's rate is declared in its enclosing assembly. The relative form ticks every K-th tick of that scope, starting from tick φ, and every tick by default. The absolute form gives a period and an offset in seconds and cuts the child off from the scope's ticks. Relative entries multiply periods and add phases down the tree, so each component ends with one period and one phase on the base grid.
- Status: Partly. §3.3 says assemblies are kept "as declaration-level rate scopes". §3.2 says "Update ... at a declared rate".
- Target: §3.3, with a line in §3.2.

**24. The value of `Δt`**
- Where: §10.5 `Δt` in the bundle, "The bundle's `Δt` is still `D·Δt_base`" and "An offset shifts firing instants and never the period". Also "arrives in `y_state`, `y_direct` and `s_update` alike".
- Law: A discrete component's `Δt` is its own tick period, the same in its output stages and its update. Its phase never changes it.
- Status: Partly. §5.2 lists "The clock. `t`, and `Δt`", and its bundle table makes `Δt` present only on the discrete tier. It never gives the value.
- Target: §5.2, What the views are.

**25. Boundary zero**
- Where: §10.5 Due sets, "At boundary zero ... the due set is everything with `Φ = 0`", "Output stages publish due or not" and "Until then its cells hold its boundary-zero publication". §10.6, "Boundary zero sets every prior to not-holding", "A predicate already holding in the authored state therefore fires at `t₀`" and "Boundary zero is the same sequence with an empty integrate". §8.6, "the sampler's due `s_update` ... latches `s ← integrals(t₀)`".
- Law: Initialization runs one boundary at `t₀`. It is the ordinary sequence with no integration. Every output stage publishes from the initial state, but only components with zero phase run their update. An offset component holds its `t₀` outputs until its first tick. Every prior starts not-holding, so an event whose predicate already holds in the initial state fires at `t₀`. Re-initializing repeats this boundary, but restoring a checkpoint keeps the priors and fires nothing again.
- Status: Not at all.
- Target: §5.3, Step boundaries.

**26. The firing rule inside a boundary**
- Where: §10.6, "An event fires in an iteration round if and only if three conditions hold". §10.6 The three registers, "The edge is read against the last-observed sample" and "blocking defers its edge rather than consuming it". Also "`firing_budget` ... defaulting to 4" and "The prior is updated at each boundary's quiescence".
- Law: In each round an event fires if and only if three things hold. Its predicate holds now, its last observed sample was not-holding, and it has fired fewer than `firing_budget` times at this boundary (4 by default). An event that a sibling blocks keeps its edge for the next round. A predicate that stays holding fires once, and one that is falsified and enabled again within the boundary fires again. The final quiescent sample becomes the prior for the next boundary.
- Status: Partly. §5.3 says the phase iterates "to quiescence", that "newly enabled guards fire within the *same* boundary", that each component fires at most one event per round, and that later events are "re-decided". It names the "firing budget" but gives no edge reference and no default.
- Target: §5.3, Step boundaries.

**27. Exhausting the firing budget drops edges**
- Where: §10.6 The firing budget, "its further edges there are lost for the rest of that boundary" and "Budget exhaustion degrades; it does not throw".
- Law: Once an event has spent its firing budget at a boundary, its further edges there are dropped, not deferred. The other events iterate as usual and the run continues.
- Status: Partly. §5.3 glosses the firing budget only as "the per-boundary cap on how often each event fires".
- Target: §5.3.

**28. The full boundary sequence and what a tick sees**
- Where: §10.6 Ticks after quiescence, "Every iteration round therefore refreshes them" and the final form "→ all due `s_update` calls → logging / I/O staging". §10.5 Simultaneous ticks, "All due components run their output stages in topological order within the sweep. All due `s_update` calls run after quiescence, in any order". §8.6 Freshness at the sample, "a due tick samples the *completed* boundary".
- Law: Due discrete output stages run in every event round against their unchanged `s`. So at quiescence they reflect the settled instant, including continuous outputs after integration, projection and transitions. Only then do all due updates run, in any order, each reading the settled table and writing only its own `s`. Then the boundary publishes. Coincident ticks read each other's fresh outputs in topological order, while a staggered consumer reads the held value.
- Status: Partly. §5.3 gives "integrate → project → [ sweep → guards → handlers ] iterated to quiescence" without the update and publication steps. It says the boundary sweep includes "the discrete components due at this boundary". §3.4 says "`s_update` runs last" and "`s⁺` is decoded only at the owner's next tick".
- Target: §5.3, Step boundaries. It replaces the abbreviated sequence there.

**29. A stop request ends the run at a boundary** (borderline)
- Where: §10.4 The `t*` boundary, "The settled state is then published. That means a snapshot, the boundary-counter increment ... and the stop request scan".
- Law: Stop requests are read from each boundary's settled table, `t*` boundaries included. The run ends at the first boundary that publishes one.
- Status: Partly. §4.3 defines the stop request as "a port that ends the run when it reads `STOP_REQUESTED`" but does not say when it is read.
- Target: §4.3.
- Why borderline: Termination is Part IV's subject. It does fix the last boundary a run computes.

## Checked and found fully stated in Part I

- §8.2, event order as priority with re-decision. Stated in §5.3.
- §10.6, the epoch rule; handler order across components cannot be observed. Stated in §5.3 ("Own `y`, foreign `u` and own `x`/`m` alike come from the firing round's sweep").
- §10.6, a tick cannot trigger an event within its boundary. Stated in §3.4.
- §10.6, iterating to quiescence makes cascades independent of `h`. Stated in §5.3.
- §10.5, zero-order hold and the interior sweep without discrete entries. Stated in §3.2 and §5.3.
- §10.4, trial evaluations run the interior sweep with held discrete cells. Stated in §5.3.
- §10.4, the guard's return type is its detection policy, and rewriting a localized guard as a `Bool` guard only coarsens resolution. Stated in §2.1.
- §10.5, an assembly is virtual for execution. Stated in §3.3 ("flattened away for ordering").
- §9.6 and §8.2, frozen discrete outputs are constants with zero partials. Stated in §7.2.
- §9.7, the stage-1 block runs in any order. Stated in §5.3.
- §9.5, a return is paired with its cells by name. Implied by §4.3's scatter by port name.

## Derived from the laws above, needing no statement of their own

- §8.6, the `z⁻¹` reading of a discrete stage, and that a latch published by `y_state` is one period stale. Both follow from item 28.
- §10.5, the aged reads under coincidence and stagger. They follow from items 22 and 28.
- §10.4, boundary detection is exact for a guard that reads only `u` and `m`. This follows from item 13.

## Left out as not semantic

- §8.2, combining root-input tolerance by a meet, and whether an input can be seeded. These decide which linearization taps are legal, not values.
- §9.3, stage totality. It is an author obligation, and its failure belongs to Part IV.
- §9.6, a failed trim leaves the stores untouched. This is service semantics for §14.
- §8.5, container layout order. It changes the layout, not any value.
- Probe values, conformance checks, shadowing, the wall-clock map and margin of §10.7, and the diagnostics, artifacts and executor structure.

## Tally by target chapter

| Part I target | Items | Count (borderline) |
|---|---|---|
| §2 Formalism (§2, §2.1, §2.2) | 8, 10, 13, 14, 15, 16, 17, 18, 19, 20 | 10 (2) |
| §3 Component taxonomy (§3.2, §3.3) | 4, 21, 22, 23 | 4 (0) |
| §4 Ports and signals (§4.3) | 29 | 1 (1) |
| §5 Evaluation order (§5.2, §5.3) | 7, 9, 11, 12, 24, 25, 26, 27, 28 | 9 (2) |
| §6 Composition (§6.1) | 5 | 1 (0) |
| §7 State and data (§7.1 to §7.3) | 1, 2, 3, 6 | 4 (0) |
| Total | | 29 (5) |

Of the 29 laws, Part I states 7 not at all: items 13, 14, 17, 18, 22 and 25, plus the borderline item 8. The other 22 it states in part. The largest gaps are the chain of localized events (items 14 to 18) and the tick lattice with boundary zero (items 21, 22 and 25).

**Word estimate.** At one or two sentences per law, Part I's level, each law takes about 40 to 70 words. Items 25, 26 and 28 would take 80 to 100 each.

- §2: about 550 words.
- §3: about 250 words.
- §4: about 40 words.
- §5: about 600 words. Item 28 replaces the existing one-line sequence, so it is partly net-neutral.
- §6: about 40 words.
- §7: about 220 words.

That totals about 1,700 words, or about 1,450 without the 5 borderline items. This is a gain of roughly 9 to 10 percent on Part I's 15k to 16.7k words. Folding items 14, 17 and 18 into one localization paragraph would save about 100 words. So would folding item 27 into item 26.

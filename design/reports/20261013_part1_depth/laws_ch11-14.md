# Semantic laws in chapters 11 to 14 missing from Part I

Scope: spec.md §11 to §14, checked against all of Part I (§1 to §7). Read-only audit.

Part I says almost nothing about runs as a whole. It never mentions boundary zero, the initial instant, initial conditions, the frame top where inputs apply, termination by end time or by stop, or what makes two runs equal. It mentions trim and linearization only as consumers of `T`-genericity. Most findings fall into those gaps.

Each entry gives: where the law is stated now, the law, Part I's coverage, and the target in Part I.

---

## A. External inputs and what drives a run

### L1. Inputs apply at step start and are held between writes
- **Now:** §11.1, the drain is "Exactly one point in each frame, at its top … It never happens at a `t*` boundary". §11.3, root inputs are "constants within a frame". §11.4, "newest wins per face" and "Untouched faces survive … That is the per-face ZOH". §12.4(6), "The orphaned root inputs hold their last-drained values".
- **Law:** External inputs change only at the start of a step, never inside one, including at a localized crossing. A root input keeps its last applied value until it is written again. If several values are staged for one input before a step starts, only the newest takes effect.
- **Part I:** partly. §2 says "The runtime injects them asynchronously, from pilot controls or the network, under the staging rules of §11". §4.1 says "A root input is a source cell fed by the periphery rather than by a producer". The word "asynchronously" describes the mechanism. Part I never says when an input takes effect.
- **Target:** §2, the "External inputs" bullet.

### L2. Root inputs are the only channel into a running model
- **Now:** §12.5, "While a simulation runs, the periphery stages root-input writes and issues control commands. Structurally, it does nothing else." §11.3, root inputs are "the *only* thing the periphery may write". §12.1, "Control changes *when* frames execute, never what they compute, and stop merely truncates the trajectory."
- **Law:** While a model runs, nothing outside it writes its state, modes or outputs. Root inputs are the only external influence. Control commands (pause, pace, stop) change when steps run or where the run ends, never what a step computes.
- **Part I:** partly. §2's "External inputs" bullet names the channel. §2.2 closes the per-step hook. Part I never says that this channel is the only one.
- **Target:** §2, the "External inputs" bullet.
- **Borderline sub-point:** §12.5 also says "A sim-time script becomes a source or supervisor component; a wall-clock interaction becomes a device." That is a modeling rule more than a value law. If kept, it is one clause: behavior clocked by sim time belongs to the model and replays by recomputation.

### L3. Determinism and replay equivalence
- **Now:** §11.4, "the frame's outcome is a pure function of the drained batches". §11.5, "The trajectory depends on the deployment exactly as it depends on the stores." §12.7, "Frame *k* of the replay *is* frame *k* of the recording", "The value covers the trajectory-determining parameters" (`Δt_base`, `h`, `N_base`, algorithm, `localization_tol`, `localization_budget`, `firing_budget`, the schedule), and "Bit-identity is promised only against the identical build. What-if replay promises determinism, never reproduction."
- **Law:** A trajectory is a pure function of four things: the build, the trajectory-determining step and event parameters, the initial state, and the sequence of input batches applied per step. Two runs that agree on all four are bit-identical, whatever their wall-clock timing. The same inputs fed through the same structure with changed parameters give a deterministic run, but not a reproduction.
- **Part I:** partly. §1 says "An input trace that replays any run bit-identically". §2.2 says "the same seed gives a bit-identical trajectory". §5.3 says "replay re-drives the ordinary loop from that trace". Part I never says which inputs make up the equivalence class, nor that inputs are keyed by step.
- **Target:** §2.2, the "deterministic replay" bullet.

### L4. Observation, pacing and advance splitting do not change values
- **Now:** §11.2, "`log_max` is a **view policy, not a trajectory-determining one**". §12.4, "The cap is not trajectory-determining". §12.6, "A stepped simulation is bit-identical to the same frames under `run!`". §13.5, "**Inspection** is human-facing, has no effect on run semantics" and "The stop scan is the one such read." §12.1, as quoted in L2.
- **Law:** The following leave the trajectory bit-identical: logging and its retention, trace recording, attached readers and other inspection, pacing and pause, and how a run is split into advances. The only read a run acts on is the stop-request check (L12).
- **Part I:** not at all. §2.1's "Detection policy never depends on real-time pacing" covers one narrow case.
- **Target:** §2.2, next to L3.
- **Overlap:** this partly restates §10.7's "pacing outside the semantics", which the chapter 8–10 audit may also flag.

---

## B. What is published

### L5. One snapshot per boundary, holding the table and not the state
- **Now:** §11.2, "A snapshot carries the boundary-consistent signal table, `t`, its frame index and its published-boundary ordinal", "The captured table also includes the root inputs", "The snapshot deliberately does *not* carry the state stores", and "Publication happens only after the boundary sequence completes". §12.3, "Boundary zero is 0, and every publication after it, grid or `t*`, counts one."
- **Law:** Every completed boundary publishes one immutable snapshot. That covers boundary zero, every grid boundary and every localized crossing. The snapshot holds the settled signal table, meaning every declared port and every root input, with its time. Snapshots do not include state. A state or mode is observable only through a declared port. The sequence of snapshots is the run's observable trajectory.
- **Part I:** partly. §7.5 has "Publication's one snapshot (the immutable per-boundary publication)" and "A mode field so exposed is in every snapshot". §5.3 says "The round that detects quiescence leaves the table post-transition-consistent for whatever else the boundary does, such as discrete ticks … and logging". Part I never says what a snapshot contains or that the t* crossings and boundary zero publish one.
- **Target:** §5.3, "Step boundaries".
- **Borderline sub-point:** the ordinal numbering is indexing, not values. Leave it out unless a short clause is free.

---

## C. Initialization

### L6. The initial state is the declared defaults with authored overrides
- **Now:** §14.1, "The overlay base is always the declared defaults", "A condition is an initial condition and nothing else", and a condition "never specifies outputs, which are derived data". §14.2, writing an internally wired input "would be meaningless because the first sweep overwrites it".
- **Law:** A run's initial state is each store's declared initial value, replaced wherever an authored initial condition gives an entry. A condition sets continuous state, discrete state, modes and root inputs, and nothing else. Outputs are never initialized. They are computed from the initial state, so an input fed by a wire has no initial value of its own.
- **Part I:** not at all. Part I treats `x_init` only as a declaration. §7.3 says only that a workspace "is never a condition target".
- **Target:** §7, the chapter introduction or §7.3.

### L7. Root inputs start from the initial condition, never from a default
- **Now:** §11.3, "a root input unfed by any device must hold a defined value from the first frame". §14.6, "Root inputs are the one initialized datum without declared defaults", "Totality is a precondition of starting", and "The probe-value barrier is structural".
- **Law:** Root inputs have no declared defaults. A run starts only when its initial condition sets every root input. A fabricated value never reaches a run.
- **Part I:** not at all. §6.1 introduces the root input as "The one legitimate terminus fed by no component". §4.3 says an opaque root input "has no synthesis", which is related but not the same rule.
- **Target:** §6.1, "Connections per port". It could also merge into L6 in §7.

### L8. Boundary zero is an ordinary boundary with no integration
- **Now:** §14.5, "The init service then completes the §10.6 macro-sequence with an empty integrate", "The parity with an ordinary boundary is exact, not approximate", and "Boundary zero establishes every guard prior … as not-holding". The "Events run" bullet adds that whatever fired at `t₀` is part of the restored state and "never fires twice".
- **Law:** At the initial instant, the initial state passes through an ordinary boundary with an empty integration step. Projection runs first, then the sweep, then event iteration to quiescence, then the discrete updates that are due, then the first snapshot. Every guard starts not-holding, so if a predicate already holds in the initial state, its event fires at `t₀`.
- **Part I:** not at all. Part I never mentions boundary zero.
- **Target:** §5.3, "Step boundaries".

### L9. Discrete timing at `t₀`, and the update as outgoing transition
- **Now:** §14.5, "The sweep runs, and every discrete output stage publishes, due or not", "A boundary's `s_update` is the *outgoing* transition", and "Both authored values are the published initial conditions of their outgoing transitions."
- **Law:** The update at tick `t_k` consumes that boundary's samples and produces the state the next tick reads. At `t₀`, every discrete component publishes outputs from its initial state, even one whose first tick is later. Only components that are due also run their update.
- **Part I:** partly. §3.2 states "Update s⁺ = g(s, u, t) at a declared rate". §3.4 says "`s⁺` is decoded only at the owner's next tick, because `s_update` runs last". The outgoing-transition reading is implied there. The `t₀` publication rule is absent.
- **Target:** the outgoing-transition clause goes to §3.2. The `t₀` publication clause goes to §5.3 beside L8.

### L10. Time is not state, and the origin anchors the grid
- **Now:** §14.5, "`t₀` is an init-service argument (default `0.0`), never a condition entry, because time is not a store of any component", and "The harmonic grid … anchors at whatever `t₀` boundary zero runs at". §12.4 gives "`tₖ = t₀ + k·h`, indexed and never accumulated".
- **Law:** Each trajectory has an origin `t₀`, fixed when it is initialized. Boundary times are `t₀ + k·h`, and every discrete tick schedule is anchored at `t₀`. A restored state brings its own origin with it.
- **Part I:** not at all.
- **Target:** §2, or §5.3 beside L8.
- **Overlap:** the grid formula likely belongs to §10.1 and §10.5. The chapter 8–10 audit may claim it.

---

## D. Termination

L11 to L13 could form one short "how a run ends" paragraph.

### L11. An end time stops the run on the grid
- **Now:** §12.4, "`t_end` lands on the grid. The run ends at the first grid boundary whose time reaches or exceeds `t_end`. Whole frames only, never a shortened final step".
- **Law:** A run bounded by an end time stops at the first grid boundary at or after that time. The last step is never shortened, so the final time can exceed the end time by up to one step.
- **Part I:** not at all.
- **Target:** §2.

### L12. A stop request is a model output, checked at every boundary
- **Now:** §13.5, "The first honoured request reading `STOP_REQUESTED` initiates §12.4 shutdown with *this* snapshot as the final one. The terminal snapshot is the terminal state. There is no roll-back", "**Every request is honoured unless the advance ignores it**", "**Stop requests are sampled at completed boundaries; declare a sign-form event if you need the stop localized.**", and an authored condition "that is already terminal ends the run at `t₀`". On an ignored request: "the sim integrates a frozen robot, which is well-defined".
- **Law:** After every published boundary, including boundary zero and localized crossings, the run checks its stop requests. The first honoured request that reads STOP_REQUESTED ends the run, and that boundary is its final state, with no rollback. Requests are checked only at boundaries, so a stop is located no more precisely than the event that sets it. A run may be told to ignore requests, and its trajectory then simply continues.
- **Part I:** partly. §4.3 defines a stop request as "a port that ends the run when it reads `STOP_REQUESTED`". Part I does not say when the check happens, what the final state is, or that a request can be ignored.
- **Target:** §2, with §4.3 keeping its definition.

### L13. External stops end on a completed boundary
- **Now:** §12.4(1), "The loop always completes the current boundary sequence and never stops mid-frame." §12.1, "A change issued while a frame runs or waits is observed at the next frame top" and "stop merely truncates the trajectory". The operator interrupt section says the result "is boundary-consistent".
- **Law:** An external stop takes effect at the next step start. That covers a stop from the operator, a device, code or an interrupt. The step in progress completes and publishes. A stopped run therefore ends on a completed boundary, and its trajectory is a prefix of the run that was not stopped.
- **Part I:** not at all.
- **Target:** §2.

### L14. Failure truncates the record at the last completed boundary (borderline)
- **Now:** §13.6, the abnormal path "discards the failed boundary, promotes the previous snapshot to final" and "Nothing downstream of the sim ever sees half a boundary." §13.4, "Divergence is not termination", with the nonfinite-`x` check at each boundary.
- **Law:** A boundary that fails publishes nothing, and the run's record ends at the last completed boundary. A nonfinite continuous state is a failure, not a terminal state.
- **Part I:** not at all.
- **Target:** §2, if kept.
- **Borderline:** this is about failure, not about the values of a well-formed model. The depth rule hands "how it fails" to Part IV. My recommendation is to leave it out, or at most add one clause to L13.

---

## E. State and restart

### L15. A model's full state, and restore equivalence
- **Now:** §12.6, a checkpoint "holds the flat buffer, the `s` and `m` stores, the whole signal table, the guard priors, `t`, `t₀` and the fingerprint", and `restore!` "runs no sweep, evaluates no guard, runs no update and resets no prior. The next frame is the original lattice's next frame". §11.5 gives the same list for the trace header. §12.7 uses restore-then-feed as a seek.
- **Law:** At a step start, a model's complete state consists of six parts:
  - continuous state
  - discrete state
  - modes
  - the signal table, which holds the root-input levels and the held discrete outputs
  - each guard's prior
  - the clock with its origin

  Workspace is not state. Restoring this state and continuing gives the same trajectory as never stopping. No boundary is re-run and no event fires again.
- **Part I:** partly. §7.3 says discrete state and modes "are state in the full sense … a checkpoint copies them wholesale". It also says a workspace "is not snapshotted and not replayed". Part I never says that the table and the priors are part of the state, and never states the restore equivalence. Chapter 12 states that equivalence only by implication ("the original lattice's next frame").
- **Target:** §7, the chapter introduction or §7.3.

---

## F. Trim and linearization

### L16. What trim computes
- **Now:** §14.9, a trim problem "is not a condition but an **implicitly specified condition**". §14.5, "Optimizer iterations are raw write → sweep → read cycles on the activation, with no boundaries, no events and no `s_update`". §14.8, "A frozen cell holds what the authored discrete state publishes", "No commit means the sim is bit-for-bit untouched", and "`converged` means `all(abs.(rᵢ) .≤ tolᵢ)`". §14.5, "the committed `x` is `x_projection(x*)`, not the solver's `x*`".
- **Law:** Trim searches a family of initial conditions, indexed by bounded decision values, for one whose declared residual equations each hold within their own tolerance. Each candidate is evaluated with one sweep over the candidate laid on a baseline. Modes, discrete state and discrete outputs stay at their initial values, and there is no boundary, event, projection or discrete update. A converged solution is committed as an ordinary initial condition through boundary zero, so projection or an event that fires can move the committed state off the solved point. A failed solve leaves the model untouched.
- **Part I:** partly. §5.3 says "implicit solvers, linearization and trim already work this way. They seed `x` and run the composite". §7.2 says "Derivatives for trim solvers" and "Linearization and trim differentiate continuous dynamics only."
- **Target:** §7.2, which already lists trim as a consumer.
- **Borderline sub-point:** the per-residual tolerance test decides which point counts as a trim, but it is close to algorithm. A single clause, "within per-equation tolerances", is enough.

### L17. What linearization computes
- **Now:** §14.10, "Partials give `A` and `B` against the `x`- and `u`-seeds, and `C` and `D` against the same seeds read at `y`", "Unseeded states sit constant at the operating point, and so do unseeded root inputs", "The discrete tier is frozen with zero partials", "Linearization is the first service with no commit and no boundary zero", and the default operating point is "the checkpoint … of the simulation or the model as it stands". §14.3, "\"Held at the operating point\" *is* zero partials."
- **Law:** Linearization returns the Jacobians A, B, C and D of the instantaneous continuous map from (x, u) to (ẋ, y). They are taken at an operating point, over the chosen state and root-input taps. Everything else is held constant with zero partials: other states and inputs, modes, the discrete state and every discrete output. No boundary, event, projection or discrete update runs. The default operating point is the model's current state, and linearizing never changes that state.
- **Part I:** partly. §7.2 says "A frozen discrete cell … is a constant with zero partials. That is what 'linearize the continuous dynamics with the discrete state held' means". §5.3 says "Linearization holds unseeded gain inputs constant with no special casing", and that the composite map is untouched for "linearization, trim and automatic differentiation". Part I never names A, B, C and D, never says that events and projection are excluded, and gives no default operating point.
- **Target:** §7.2.

### L18. A pinned leaf is an exact zero coupling
- **Now:** §14.10, "A root input whose entry is declared `Pinned` is **declaredly unseedable**". It also gives a pinned output leaf as the spelling of "this port is frozen under differentiation". §13.7, for `Freeze`: "What the wire then declares is a zero coupling in every Jacobian along that path".
- **Law:** A leaf declared pinned carries no derivative, so every Jacobian entry through it is exactly zero by declaration. An input that some consumer pins cannot be a linearization input.
- **Part I:** partly. §7.2 says "A contract leaf wrapped in the leaf marker `Pinned{P}` is deliberately pinned". §6.1 says "frozen values embed upward under any activation". Part I gives the typing meaning of a pin but not what it means for Jacobians.
- **Target:** §7.2.

---

## Checked and left out

These are already fully stated in Part I, or are not semantic:

- **Fully stated in Part I:**
  - The frozen discrete cell is exact (§14.10's "true zero of an instantaneous dependence"). §7.2 already says "not a limitation but the exact answer".
  - Workspace is not state (§7.3).
  - Event firings are not recorded (§7.5).
  - `UnitDelay` makes the broken signal sampled. §5.5 already says this, and §13.7 adds only the spelling.
- **Borderline, left out:**
  - Root-input exclusivity, one writer per input (§11.3). It is a configuration constraint. The applied values are already deterministic given the batches.
  - "a face's meaning is writer-independent" (§11.4). This is about interpreting a value, not computing one.
  - The condition algebra (`combine` refuses collisions, `override` lets the patch win, §14.2 and §14.6). It decides initial values, but it belongs to authoring.
- **Not semantic:**
  - Staging cells, CAS, the mask layout and the trace record format
  - Claims, the roster freeze, bindings and the GUI liveness and peek rules
  - Diagnostic cells, the heartbeat and the thread budget
  - The next-snapshot wait
  - Shutdown joins and device init brackets, interrupt masking details, lifecycle states and doors
  - `to_time` and `to_boundary` halts, which position an inspection
  - Input modes, replay validation kinds and the per-advance stop policy plumbing
  - Trim backends and reports, mounting and the selector family
  - The tap spellings
  - The recorded sampled-data step map, which is not built

---

## Tally by target Part I chapter

| Target | Laws | New words (approx.) |
|---|---|---|
| §2 Formalism (inputs, determinism, runs, termination) | L1, L2, L3, L4, L10, L11, L12, L13 (L14 borderline) | 365 (+35) |
| §3.2 Periodic discrete component | L9, the outgoing-transition clause | 20 |
| §5.3 Step boundaries | L5, L8, L9, the `t₀` publication clause | 135 |
| §6.1 Connections per port | L7 | 35 |
| §7 State (intro or §7.3) | L6, L15 | 110 |
| §7.2 Numeric genericity (trim and linearization) | L16, L17, L18 | 185 |
| **Total** | 17 laws, plus 1 borderline | **about 850**, or 885 with L14 |

**Estimate:** Part I would gain about 750 to 900 words, roughly 5 to 6 percent of its 15k. The lower end assumes three merges: L11 to L13 into one termination paragraph, L6 with L7, and L3 with L4. §2 takes the largest share. Part I currently has no statement of what a run is: its start, its inputs, its end and its equivalences. A short "Runs" paragraph or subsection in §2 may hold L1 to L4 and L10 to L13 better than spreading them across the existing bullets.

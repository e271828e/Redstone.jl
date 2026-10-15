# Unit F (§12.5, §12.6): claims, in old order

old: ### 12.5 Scripts and the mid-run mutation doctrine
tag: X

added: This section settles what the periphery (everything outside the loop that exchanges data with it) may do to a running model.

added: The periphery's attached participants are its devices.

added: The section surveys FlightCore's mid-run mutations, states the clock criterion that maps scripts to components (units of modeling), eliminates FlightCore's per-step hook `user_callback!`, covers manual events and mid-run re-initialization, and ends with the doctrine's final form.

old: What the consumers demonstrably mutate mid-run is surveyed here.
tag: F

added: The line references are to `c172_demos.jl`, FlightCore's demo file.

old: FlightCore's `user_callback!` has exactly two archetypes.
tag: F

old: The first is the timetable script (c172_demos.jl:290: `elevator_offset` as a function of `t`).
new: The first is the timetable script, `elevator_offset` as a function of `t` (c172_demos.jl:290).
tag: F
note: the nested colon became an appositive; the file reference stays, introduced once in the added sentence before (R6)

old: The second is the synthetic pilot (c172_demos.jl:423, 525: a phase FSM reading `y` and writing mode requests, references, flaps, wind).
new: The second is the synthetic pilot, a phase FSM (finite-state machine) reading `y` and writing mode requests, references, flaps and wind (c172_demos.jl:423, 525).
tag: F
note: FSM expanded at first use

old: Both write only `u` fields.
tag: F

old: No demo, test or GUI path pokes `x`/`s` mid-run, and `init!`/trim appear only between construction and `run!` (c172_demos.jl:303).
tag: F
note: kept whole; D-195's Rationale relies on the `x`/`s` clause

old: Sim-time scripts are model behavior, so they become scenario components
new: Sim-time scripts are model behavior, which is why they become scenario components.
tag: F
note: the reason now follows the bold rule (M59); the causal direction is kept

old: (ordinary periodic discrete components holding a sim-time script).
new: A scenario component is an ordinary periodic discrete component holding a sim-time script.
tag: F
note: the gloss became its own sentence; the glossary's entry says the same

old: Both archetypes are clocked by sim time, `t`, the trajectory.
tag: F

old: Mapping them to devices is rejected (D-031).
tag: F
note: one-clause verdict with its citation (R6)

old: The clock is the criterion.
tag: F

old: Rule. A sim-time script becomes a source or supervisor component; a wall-clock interaction becomes a device.
new: A sim-time script becomes a scenario component, and a wall-clock interaction becomes a device (D-031).
tag: R
ruling: R10
newcites: D-031
note: F74 and M59. The Rule. label folds into the bold clock criterion, which now reads "scenario component"; "source or supervisor" goes.

old: A script mapped to a component is periodic discrete, with `K = 1` for today's `dt = 0.02` callbacks.
new: A script mapped to a component is periodic discrete, with `K = 1` for the `dt = 0.02` callbacks FlightCore had,
tag: R
ruling: R6
note: "today's" becomes FlightCore's, in the past tense

added: `K` being the multiplier in `Relative(K)` (§10.5).

old: It executes synchronously in the loop, deterministic paced or unpaced.
tag: F

old: It is replayed by recomputation, with no trace.
new: It is replayed by recomputation, with no trace (the records of each frame's drained inputs).
tag: F
note: gloss added at the trace link's first use

old: A device, by contrast, is traced and replayed from the trace.
tag: F

old: The component mapping is strictly richer than the callback it replaces.
tag: F
note: the bold goes; no entry rules it (survey row 507)

old: - The `Ref(:init)` phase closure becomes honest `s`, visible in snapshots, logs and plots.
new: - The callback's `Ref(:init)` phase closure becomes honest `s`, which a port (one declared name with its cell) can publish to snapshots, logs and plots.
tag: R
ruling: R10
note: F60; "The callback's" introduces the closure

added: A snapshot is the immutable per-boundary publication.

old: - Inputs arrive same-boundary fresh by topological order.
new: - Inputs arrive fresh from the same boundary (a published consistency point), by topological order.
tag: F
note: the link no longer sits inside the compound (verifier, as F66)

old: The callback ran post-step, one boundary staler.
tag: F

old: - The pure timetable script is a one-liner reading the clock out of its bundle (the NamedTuple of zero-copy views a component function receives).
tag: F

old: That one-liner is `y_direct(c, (; t)) = (; offset = profile(t))`, exact at its own ticks, with no latching.
new: That one-liner is `y_direct(c, (; t)) = (; offset = profile(t))`, exact at its own ticks, with no latch state of its own.
tag: R
ruling: R10
note: F77

added: A tick is an instant at which a discrete component's stages and update run.

old: - In a scenario configuration the script drives the avionics' input ports.
new: - In a scenario configuration the script drives the input ports of the avionics (the onboard flight systems).
tag: F
note: "the avionics" glossed as §10.1's "(onboard flight systems)" (spec 5615)

old: §11.7 therefore renders the corresponding GUI widgets read-only with its source shown.
new: §11.7 therefore renders a front end's corresponding widgets read-only, each showing its source (D-310).
tag: R
ruling: B11
newcites: §11.7 D-310
note: "its" now reads as each widget's (step 5, P2-3); R2 extended to §12.5, "the corresponding GUI widgets" becoming a front end's, D-310 cited once in the section (B11)

old: Today's demo-vs-GUI dead-slider fight is resolved by the port-resolution rule.
new: Its port-resolution rule resolves FlightCore's demo-vs-GUI dead-slider fight.
tag: R
ruling: R6
note: "Today's" becomes FlightCore's; the pointer at §11.7, whose rule retires FlightCore's dead-slider convention, is "Its", the sentence before's §11.7 (step 5, P2-3)

old: `user_callback!` is eliminated (D-031).
tag: F

old: It is the periphery's `f_step!`, FlightCore's unconditional per-step hook (§2.5), and cheap composition leaves it without justification.
tag: F

old: Its call sites migrate to scenario components, not devices.
tag: F

old: Manual event triggering needs no mechanism.
new: Manual event triggering needs no mechanism (D-031).
tag: C
newcites: D-031
note: D-031 Position, "manual events = slot + guard"

old: It takes a root input plus a boundary-detected guard reading that root input (an edge check at step boundaries only, with no root-finding).
new: It takes a root input (the root component's own input face) plus a boundary-detected guard (an edge check at step boundaries only, with no root-finding) reading that root input.
tag: F
note: the guard's gloss moved to sit at its term; root input glossed

old: That is already expressible in settled machinery.
tag: F

old: The levels doctrine applies: latched commands or counters.
new: The levels doctrine applies (§11.4), with latched commands or counters.
tag: C
newcites: §11.4
note: the colon goes; pointer to §11.4's levels doctrine, which has no glossary entry

old: The demos' engine start/stop buttons are `u`-writes today.
new: The engine start/stop buttons of FlightCore's demos were `u`-writes.
tag: R
ruling: R6

old: Mid-run re-initialization is not built, because it is not demonstrated.
new: Mid-run re-initialization is not built (D-031), because it is not demonstrated.
tag: C
newcites: D-031
note: D-031 Position, "init/trim = stopped-sim services"

old: Initialization and trim are stopped-sim workflows (first-class services, §14).
new: Initialization and trim are stopped-sim workflows, first-class services of §14.
tag: F
note: the citation left the gloss's parentheses (step 5, P2-5)

old: No concurrency perimeter exists there.
tag: F

old: There is no loop and no devices, just plain single-task code.
tag: F

old: The guarded-addition shape is on record should demand appear.
new: The shape of the guarded addition (a capability the design admits but does not build) is on record should demand appear.
tag: F
note: guarded addition linked and glossed

old: It would be a traced, boundary-executed intervention command applied through project → sweep → publish, so that no consumer ever observes un-decoded state.
tag: F
note: "project → sweep → publish" verbatim (R6), so the sweep link takes no gloss there; the gloss follows as its own sentence (step 5, P2-6)

added: A sweep is one pass through the execution order against the current state.

old: The doctrine, final form. While a simulation runs, the periphery stages root-input writes and issues control commands.
new: In the doctrine's final form, while a simulation runs, the periphery stages root-input writes and issues control commands (§2.2, D-031).
tag: C
newcites: §2.2 D-031
note: the bold lead-in becomes the sentence's opening; the headline clause is bold, cited to D-031's Position, with a pointer to §2.2, which states the law

old: Structurally, it does nothing else.
tag: F

old: Anything that wants to poke the model mid-run is one of three things.
tag: F

old: It is an input in disguise, so wire a root input and a guard.
new: - It is an input in disguise, so wire a root input and a guard.
tag: F

old: It is model behavior in disguise, so add a scenario component.
new: - It is model behavior in disguise, so add a scenario component.
tag: F

old: Or it is a wall-clock interaction, so attach a device.
new: - It is a wall-clock interaction, so attach a device.
tag: F
note: the three cases became a list

old: Graceful termination follows the same shape (§13.5): a stop request declared in the model, honoured unless the advance ignores it.
new: Graceful termination follows the same shape (§13.5). It is a stop request (an output port of the framework enum `StopFlag`) declared in the model, honoured unless the advance ignores it (D-316).
tag: C
newcites: §13.5 D-316
note: colon split; stop request glossed from its glossary entry; D-316 Position

old: Never a callback, and never a thrown exception.
new: It is never a callback, and never a thrown exception (D-060).
tag: C
newcites: D-060
note: D-060 Position, standing under D-255 and D-316, "termination is state, never an exception"

old: ### 12.6 Run lifecycle and partial advance
tag: X

added: This section specifies what a `Simulation` and its run own, the lifecycle a simulation moves through, how it advances and restarts, what it keeps of its devices (any attached participants in the periphery) across runs, and the stop policy each advance declares.

added: A simulation is in one of five lifecycle states, built, initialized, running, stopped or errored.

added: A door is an entry point that builds a run, and there are three, `init!`, `restore!` and `replay!`.

added: The input mode says where the next frame (one grid step, the unit of scheduling) takes its inputs from.

added: #### The run and the simulation

old: `Run` is what one run owns (D-255, D-260, D-317).
tag: F

old: It is a mutable struct of six fields.
tag: F

old: Two are `const` and last the run's whole life, the log and the trace (`nothing` under the trace switch).
new: Two are `const` and last the run's whole life. One is the log (the retained sequence of published snapshots). The other is the trace (the records of each frame's drained inputs), which is `nothing` under `trace = false`.
tag: F
note: split; log and trace linked and glossed; "the trace switch" names its keyword, which the next sentence lists (step 5, P2-9)

old: The door that builds the run takes the four recording keywords, `trace`, `log`, `log_every` and `log_max` (Appendix B, D-261),
new: The door that builds the run takes the four recording keywords, `trace`, `log`, `log_every` and `log_max` (Appendix B, D-261).
tag: F

old: so a run's recording is that door's declaration and the next door may declare otherwise.
new: A run's recording is therefore that door's declaration, and the next door may declare otherwise (D-261).
tag: C
newcites: D-261
note: split from its citation, so the citation repeats (adjacency)

old: Four evolve during it.
new: Four fields evolve during the run.
tag: F

old: `feed` is the recording `replay!` attached, or `nothing`.
new: A run's `feed` is the recording `replay!` attached, or `nothing`.
tag: M
note: R13's context paragraph holds it; the field list points back (step 5, P2-8)

added: `feed` is described above.

old: `termination` is the record the loop's tail writes.
tag: F

old: `frame` and `boundary` are the trajectory's counters, the frame index and the boundary ordinal.
tag: F

old: `init!`, `restore!` and `replay!` construct one, and nothing else rebinds it.
new: `init!`, `restore!` and `replay!` construct a run, and nothing else rebinds it.
tag: F

old: `live!` and the halt at a recording's end write `feed`.
new: `live!` (§12.7) and the halt at a recording's end write `feed`.
tag: C
newcites: §12.7
note: pointer, since `live!` is used before §12.7 introduces it

old: The loop's tail writes `termination` once, and `closed(run)` is `termination !== nothing`.
tag: F

old: Each door sets the two counters as it builds the run, `init!` to zero and `restore!` and `replay!` to the checkpoint's, and the loop advances them (D-317).
new: Each door sets the two counters as it builds the run, `init!` to zero and `restore!` and `replay!` to those of the checkpoint (the `Model`'s state at a frame top, beside the run's frame index and boundary ordinal), and the loop advances them (D-317).
tag: F
note: checkpoint's first use in §12.6, so its link and the glossary's gloss sit here (step 5, P2-10)

old: `restore!` of a bare state sets the frame index to the state's frame and the boundary ordinal to zero, as `init!` does (D-319).
tag: F

old: The origin `t₀` is not a run field.
new: The origin `t₀` is not a run field (D-260).
tag: C
newcites: D-260

old: The executor's clock holds it beside `t`.
new: The clock of the executor (the compiled form of the stage execution order) holds it beside `t`.
tag: F
note: executor's first use in §12.6, so its link and gloss sit here (step 5, P2-11)

old: `init!` sets it on the clock before boundary zero (§14.5),
new: `init!` sets it on the clock before boundary zero, the initialization boundary run as the ordinary macro-sequence with an empty integrate (§14.5).
tag: F
note: boundary zero's first use moved here, so its link and gloss sit here; the full gloss moved here from the Initialized sentence (step 5, P2-12)

old: and a checkpoint (the `Model`'s state at a frame top as one value) carries it with the clock (§11.5, D-273).
new: A checkpoint carries it with the clock (§11.5, D-273).
tag: F

old: It is a `Float64`, as `h` and `t_end` are.
new: It is a `Float64`, as `h` and `t_end` are (D-260).
tag: C
newcites: D-260

old: A `Simulation` is constructed with a placeholder run,
new: A `Simulation` is constructed with a placeholder run (D-255).
tag: C
newcites: D-255
note: the bold term became the bold headline clause, cited to D-255 bullet 2

old: an empty log, no trace, no feed and no termination, which `init!`, `restore!` and `replay!` replace (D-255).
new: The placeholder is an empty log, no trace, no feed and no termination, and `init!`, `restore!` and `replay!` replace it (D-255).
tag: F

old: The field is always a `Run` and never `nothing`, so every accessor has a run to read, and the lifecycle state below says whether that run ever started.
tag: F

old: The placeholder carries no configuration and no compiled state (D-261).
tag: F

old: `init!` allocates fresh objects rather than clearing them.
new: `init!` allocates fresh objects rather than clearing them (D-255).
tag: C
newcites: D-255

old: `Simulation` is a mutable struct of four fields, the `Model` (the deployment and its executor at one scalar), the run, the data plane and the control plane (D-317).
new: `Simulation` is a mutable struct of four fields, the `Model` (the deployment and its executor at one scalar), the run, the data plane (§11) and the control plane (D-317).
tag: F
newcites: §11 D-317
note: §11 introduces the data plane (step 5, P2-13)

added: The control plane is the atomic surface carrying pause, pace and stop.

old: The `Model` holds the deployment (the scalar-free artifact the grid parameters fix, carrying the build), the executor, its status and its diagnostic cell.
new: The `Model` holds the deployment, the executor, its status and its diagnostic cell. The deployment is the scalar-free artifact the grid parameters fix, carrying the build.
tag: F
note: the deployment's gloss became its own sentence, so the executor and diagnostic cell glosses fit

added: A diagnostic cell is a writer's own holding place for runtime diagnostics.

old: A simulation owns its `Model`, claimed at construction and never shared (§9.2, D-318).
tag: F

old: Every other value belongs to one of the four (D-256).
tag: F

old: The build is reached through the deployment, never held twice.
tag: F

old: The grid parameters, the schedule (the typed per-component `(D, Φ, Δt)` tick table) and the event parameters are the deployment's (§9.2).
tag: F

old: `chunk_size`, the stepper and the arrival buffers are the executor's.
tag: F

old: `join_timeout` is `Control`'s (§12.1).
tag: F
note: R5 keeps it here as written

old: The loop's diagnostic cell, its account and the published holder are the plane's, and the frame's own cell is the `Model`'s (§11.8).
new: The loop's diagnostic cell, its account and the published-snapshot holder (§11.2) are the data plane's, and the frame's own diagnostic cell is the `Model`'s (§11.8).
tag: R
ruling: R20
newcites: §11.2 §11.8
note: "the plane's" names the data plane, whose `DataPlane` holds the three (`src/roster.jl` 196–204); the holder is §11.2's (step 5, P2-13)

old: The log, the trace and the two counters are the run's.
tag: F

old: The stop policy, with its `t_end` and ignored requesters, is the advance's argument, and the termination record keeps the terminating one (D-260).
new: The stop policy, with its `t_end` and ignored requesters, is the advance's argument, and the termination record (the stopped-sim value naming how the run ended) keeps the terminating one (D-260).
tag: F

old: The pacer's schedule and counters are `run!`'s own, created per call and passed to the loop and its publications as the policy is,
new: The pacer's schedule and counters are `run!`'s own, created per call and passed to the loop and its publications as the policy is.
tag: F

old: and each snapshot's status carries their frozen record (§10.7, D-269).
new: The status of each snapshot (the immutable per-boundary publication) carries the pacer's frozen record (§10.7, D-269).
tag: F
note: "their" became "the pacer's" once the clause stood as its own sentence (verifier, C-086)

old: Rule. A struct holds what it owns or what it must retain across calls.
new: A struct holds what it owns or what it must retain across calls (D-261).
tag: F
newcites: D-261
note: the Rule. label goes; the headline clause is bold and cites D-261 bullet 1, which the old paragraph cited at its end

old: A callee takes what it reads as an argument, never off a field added to the container it already holds.
tag: F

old: An object is built after its inputs exist, and the placeholder run above is the one exception (D-261).
tag: F
note: D-261 bullet 3, a second ruling, bold on its own headline clause

added: #### Lifecycle states and the input mode

old: A `Simulation` moves through five states: built, initialized, running, and terminally stopped or errored (§13.4).
new: A `Simulation` moves through five states, built, initialized, running, and terminally stopped or errored (§13.4, D-088).
tag: C
newcites: §13.4 D-088
note: the bold state words went plain (italic); the headline clause is bold, cited to D-088's Position

old: Built means stores allocated and boundary zero not completed.
new: Built means stores (the framework-owned homes of a component's state) allocated and boundary zero not completed (D-223).
tag: C
newcites: D-223

old: It is the cold state, and the state a throw inside boundary zero returns the simulation to (§13.4).
tag: F

old: Initialized means `init!` has completed boundary zero, the initialization boundary run as the ordinary macro-sequence with an empty integrate (§14.5), or `restore!` or `replay!` has restored a checkpoint.
new: Initialized means `init!` has completed boundary zero (§14.5), or `restore!` or `replay!` has restored a checkpoint.
tag: F
note: boundary zero's gloss is stated once, at its first use above (step 5, P2-12)

old: `lifecycle(sim)` derives the state rather than storing it (D-317).
tag: F

old: It reads three facts, the control plane's running flag, the `Model`'s status and whether the run is closed.
tag: F

old: The status is `:built`, `:consistent` or `:inconsistent`, and only the `Model`'s own doors and catch sites write it.
new: The status is `:built`, `:consistent` or `:inconsistent`, and only the `Model`'s own entry points and catch sites write it.
tag: R
ruling: R14

old: A claimed model's status is written only through its simulation's doors, since the model's doors refuse a direct call on a claimed model (D-318).
new: A claimed model's status is written only through its simulation's entry points, since the model's entry points refuse a direct call on a claimed model (D-318).
tag: R
ruling: R14

old: | running flag | `Model` status | run closed | state | |---|---|---|---| | set | any | any | running | | clear | `:built` | any | built | | clear | `:inconsistent` | any | errored | | clear | `:consistent` | no | initialized | | clear | `:consistent` | yes | stopped |
tag: F
note: the derivation table, verbatim

old: `errored` is terminal (D-059).
tag: M
note: M52, moved up from the section's end to follow the derivation table

old: Reproduction is trace replay (§12.7), not resurrection.
new: Reproduction is trace replay, not resurrection (§12.7).
tag: M
note: M52; the citation moved past "not resurrection" so it does not sit inside the replay gloss's sentence

added: Replay is the ordinary loop re-driven from the trace.

old: Beside the state, the run carries an input mode, `:live` or `:replay`, read as `mode(sim)`.
tag: F
note: the bold term went plain

old: It is read off the run's `feed`: `:replay` while a recording is attached, `:live` otherwise (D-260).
new: The mode is read off the run's `feed`, `:replay` while a recording is attached and `:live` otherwise (D-260).
tag: F
note: the colon goes; the headline clause is bold, D-260 bullet 2

old: The mode names where the next frame's drain takes its batches from, the staging cells or the attached recording (§12.7).
new: The mode names where the next frame's drain takes its batches from, the staging cells (where each device's pending batch waits between drains) or the attached recording (§12.7, D-218).
tag: C
newcites: §12.7 D-218

added: The drain is the frame-top swap that publishes staged device writes into the root inputs, and a batch is a device's staged set of writes.

old: State and mode are orthogonal.
tag: F

old: The state says whether the simulation may advance, and the mode says what it will advance on.
tag: F

old: Rule. `init!` is mandatory.
new: `init!` is mandatory (D-088).
tag: C
newcites: D-088
note: the Rule. label goes; bold headline clause cited to D-088 Position

old: `run!` or `step!` on a simulation whose boundary zero has not completed is an error in the kind set (§13.2) naming `init!`.
new: `run!` or `step!` on a simulation whose boundary zero has not completed is `MissingInit`, an error in the kind set (§13.2) naming `init!`.
tag: R
ruling: R10
note: F58 names the kind; F66 unlinks the word "boundary" inside "boundary zero"

old: That is distinct from `UninitializedInputs`, which fires inside `init!` (§14.6).
tag: F

old: `restore!` and `replay!` are the two alternative entries.
new: `restore!` and `replay!` are the two alternative doors.
tag: F
note: bare "entry" is a reserved word; "door" is the term R14 defines in the context for exactly these calls

old: Each restores a checkpoint and runs no boundary zero (§12.7, D-274).
tag: F

old: A throw inside boundary zero, which only `init!` runs, leaves the simulation `built` (§13.4), so the next `run!` or `step!` meets the same refusal.
new: A throw inside boundary zero, which only `init!` runs, leaves the simulation `built` (§13.4, D-223), so the next `run!` or `step!` meets the same refusal.
tag: C
newcites: §13.4 D-223

old: Where the loop runs.
new: says where the loop and the device tasks run
tag: R
ruling: R5
note: M51; the bold lead-in goes with the paragraph it headed

old: The loop runs on the calling task, the task that invoked `run!`, and every rostered device on a spawned task (§11.1).
new: §11.1 says where the loop and the device tasks run
tag: R
ruling: R5, B12
note: M51; §11.1 holds it bold, "The loop runs on the calling task (D-310)"; the pointer opens its own sentence (B12)

old: Deviceless, `run!` is fully synchronous.
new: Deviceless, `run!` is fully synchronous.
tag: R
ruling: R5, B12
note: kept, since D-268's Rationale cites §12.6 for it

old: An unattended run is the same loop with empty staging (§11.1).
new: §11.1 says where the loop and the device tasks run, and defines the unattended run (a run with empty staging and no snapshot readers).
tag: R
ruling: R5, B12
note: M51, F65, F75; the pointer carries the definition, and the gloss is the glossary's; its own sentence, apart from the deviceless claim (B12)

old: It is also what the synchronous rethrow presupposes (§13.4).
new: This is what the synchronous rethrow (§13.4) presupposes.
where: docs/design/spec.md
tag: M
ruling: R5
note: M51; held in §11.1, where the antecedent is the calling-task loop (F65)

old: Partial advance.
new: #### Partial advance
tag: X
note: the bold lead-in became the label

old: `step!(sim; frames = 1)` advances whole frames synchronously through the ordinary frame sequence (drain, integrate, boundaries, publication) and returns.
new: `step!(sim; frames = 1)` advances whole frames synchronously through the ordinary frame sequence (drain, integrate, boundaries, publication) and returns (D-088).
tag: C
newcites: D-088
note: D-088 Rationale only

old: A stepped simulation is bit-identical to the same frames under `run!`,
new: A stepped simulation is bit-identical to the same frames under `run!` (§2.4),
tag: C
newcites: §2.4
note: §2.4 states the law; this is its mechanism

old: and it never waits, whatever pace the control plane holds (D-269).
new: and it never waits on the pacer, whatever pace the control plane holds (D-269).
tag: R
ruling: R10
note: F79

old: `step!(sim; t_plus = 10.0)` is the duration spelling, mutually exclusive with `frames`.
new: `step!(sim; t_plus = 10.0)` is the duration spelling. It is mutually exclusive with `frames`, and passing both is `ArgumentInvalid`.
tag: R
ruling: R10
note: F59 names the kind

old: It advances whole frames until the boundary time first covers the duration, which is the migration suite's advance-by-duration idiom.
tag: F
note: "the migration suite" stays; neither §12.6 nor the log says it is FlightCore's (R6, rulings.md)

old: Partial advance is the test-harness mode: advance, assert, advance.
new: Partial advance is the test-harness mode of advance, assert, advance.
tag: F

old: It is equally the REPL mode: fly a while, inspect, continue.
new: It is equally the REPL mode of fly a while, inspect, continue.
tag: F

old: Neither is a script, so the scenario-component doctrine does not absorb them (§12.5).
tag: R
ruling: R10
note: F66 unlinks the word "component" inside "scenario-component"

old: A stepping session is deviceless by construction.
new: A stepping session is deviceless by construction (D-093).
tag: C
newcites: D-093
note: D-093 Rationale only

old: Device tasks are per-`run!` artifacts (§11.1), and a device loop's `while running(handle)` is false outside a run.
tag: F

old: Between `step!` calls the simulation is in a stopped-sim state, `initialized` (below), so `attach!` is legal there and does what it always does.
tag: F

old: It registers (§11.3), and the task appears at the next `run!`.
tag: F

old: The frame-top drain still runs, so `step!` frames stay bit-identical to `run!` frames.
tag: F
note: the bold lead-in went plain

old: What it drains is the harness cell.
new: In a stepping session the staging cell written is the harness cell (the always-present staging cell of the harness writer).
tag: R
ruling: R20
note: F64 as R20 words it; the harness cell's gloss moved to its first use

old: The harness write path is `stage!(sim, "face" => value, …)` (§11.3),
new: The harness write path is `stage!(sim, "face" => value, …)`, and §11.3 specifies the writer.
tag: R
ruling: R5
note: M53, the pointer at §11.3 for what the harness writer is

old: from any task, the calling task included.
new: It stages a batch from any task, the calling task (the task that invoked `run!`) included
where: docs/design/spec.md
tag: M
ruling: R5
note: M53; §11.3 holds it, cited to D-200

old: Staged batches are ordinary batches.
tag: F

old: They are traced, so replay and bit-identity hold.
new: They are traced, so replay and bit-identity hold,
tag: F

old: They are applied at the next frame top.
new: and they are applied at the next frame top.
tag: F

old: They are surface-checked like any writer's (§11.3).
new: is drained, traced and surface-checked exactly as any device's
where: docs/design/spec.md
tag: M
ruling: R5
note: M53; §11.3 holds it for the harness cell

old: The read half is `latest(sim)`.
tag: F

old: It hands back the same immutable snapshot value a device handle acquires (§11.2), navigated directly for assertions.
tag: F

old: Advance-assert-advance is `stage!` → `step!` → `latest`.
new: Advance-assert-advance is `stage!` → `step!` → `latest` (D-096).
tag: C
newcites: D-096
note: D-096 Rationale only

old: Both entry points work under `run!` too.
tag: F
note: kept (R5); Appendix B relies on it

old: The harness cell, the always-present staging cell of the harness writer, is not step-scoped.
new: The harness cell is not step-scoped.
tag: F
note: its gloss moved to the term's first use

old: An inspection accessor leaves the rejection of closure-based termination (§13.5) untouched.
new: An inspection accessor leaves the rejection of closure-based termination untouched (§13.5, D-096).
tag: C
newcites: §13.5 D-096
note: one-clause verdict with its citation (R6); D-096 Rejected list

old: Status, termination and the `run!` seam.
new: #### Status, termination and `run!` after `step!`
tag: R
ruling: R10
note: F61; the bold lead-in became a label naming the junction, with no "seam"

old: Between `step!` calls a simulation reports initialized.
new: Between `step!` calls a simulation reports `initialized` (D-088).
tag: C
newcites: D-088
note: D-088 Rationale only; the bold state word went plain

old: No loop task exists, so `running` would lie.
tag: F

old: Nothing is terminal, so `stopped` would lie too.
tag: F

old: The state reads "boundary-consistent and ready to advance", not "sitting at boundary zero".
tag: F

old: `run!` may therefore follow `step!`, continuing from the current boundary, and so may another `step!`.
tag: F

old: Termination policy is honored throughout, as bit-identity requires.
new: The stop policy is honoured throughout, as bit-identity requires.
tag: F
note: one name for the stop policy and the chapter's spelling (step 5, P2-17)

old: `t_end` reached, or a stop request holding at frame 3 of `step!(sim; frames = 10)`, ends the run there through the ordinary §12.4 tail and leaves the simulation `stopped`.
new: `t_end` reached, or a stop request (an output port of the framework enum `StopFlag`) holding (publishing `STOP_REQUESTED`) at frame 3 of `step!(sim; frames = 10)`, ends the run there through the ordinary §12.4 tail and leaves the simulation `stopped`.
tag: F

old: `step!` therefore returns the number of frames actually advanced.
tag: F
note: the bold phrase went plain (italic)

old: That is the requested count in the ordinary case, and fewer when the run terminated inside the call.
tag: F

old: That return is how a harness detects the truncation without inspecting the clock.
tag: F

old: Re-running:
new: #### Re-running and checkpoints
tag: X
note: the lead-in's topic became the label

old: `stopped → init! → run!` remains the authored re-run.
new: `stopped → init! → run!` remains the authored re-run (D-088).
tag: C
newcites: D-088
note: D-088 Rationale only

old: `init!` re-runs boundary zero from its condition.
new: `init!` re-runs boundary zero from its condition (a path-addressed overlay that sets the build to a state).
tag: F

old: The warm restart is `checkpoint` → `restore!` → `run!` (§12.7, D-274).
tag: F

old: `restore!` is a door like `init!`, and it runs no boundary zero.
tag: F

old: Each builds a fresh run, so the trace, the log and the termination record (§13.5) are new objects rather than cleared ones, and each clears any batches still in staging cells.
tag: F

old: The recorders restart with the run they record, and no stale batch survives to clobber the frame it predates.
new: The recorders (the trace and the log jointly) restart with the run they record, and no stale batch survives to clobber the frame it predates.
tag: F

old: `init!` and `restore!` also return the input mode to `:live`, and a fresh `replay!` sets the mode exactly as it sets the trajectory.
tag: F

old: `live!` is the fourth door, and the only one that moves the mode alone.
new: `live!` is the one call that moves the mode alone.
tag: R
ruling: R14

old: It takes a replaying simulation live where it stands (§12.7).
tag: F

old: A terminal state makes the mode moot.
tag: F

old: Nothing advances until one of those doors is taken (D-218, D-219).
new: From `stopped`, nothing advances until `init!`, `restore!` or `replay!` opens a new run, and `errored` is terminal (D-218, D-219).
tag: R
ruling: R10
note: F63

old: `checkpoint` and `restore!` exist on the `Model` and on the `Simulation`, and a `Checkpoint` is the `Model`'s state beside the run's cursor (D-319).
tag: F
note: the bold shrank to the headline clause "a `Checkpoint` is the `Model`'s state beside the run's cursor"

old: `checkpoint(model)` returns the state alone, a `ModelState`.
tag: F

old: It holds the flat buffer, the `s` and `m` stores, the whole signal table, the guard priors, `t`, `t₀` and the fingerprint.
new: It holds the flat buffer, the `s` and `m` stores, the whole signal table, the guard priors, `t`, `t₀`, the fingerprint (the structural layout) and the deployment.
tag: R
ruling: R12

old: It is legal at `:consistent` with the clock on a grid top.
tag: F

old: `checkpoint(sim)` wraps that state with the run's frame index and boundary ordinal (D-274).
new: `checkpoint(sim)` wraps that state with the run's frame index and boundary ordinal (D-319).
tag: R
ruling: R10
newcites: D-319
note: F69, D-319 bullet 3

old: It is a stopped-sim service, legal in `initialized` and `stopped` (§14).
new: It is a stopped-sim service, legal in `initialized` and `stopped` (§14), and refused as `ServiceLifecycle` in any other state.
tag: R
ruling: R10
note: F78 names the kind

old: It is refused wherever the executor is not at the rest a published frame top leaves (`CheckpointMidFrame`, Appendix C).
tag: F

old: That is after a `t` stop, which leaves the clock mid-frame with the remainder abandoned, and after a frame abandoned unpublished (§12.4).
tag: F

old: The test is that the clock sits on a grid time and that the latest snapshot is of that very boundary.
tag: F

old: `restore!(model, model_state)` checks the state's fingerprint against the model.
new: `restore!(model, model_state)` checks the state's fingerprint and deployment against the model, and a mismatch is `CheckpointMismatch`.
tag: R
ruling: R12, B4
note: B4 names the kind, as `src/model.jl` and D-319 bullet 2 carry it, so "either kind" below has both its antecedents

added: , and a mismatch is `CheckpointMismatch`

old: It also checks that the state's `t` is a grid time `t₀ + k·h` of the state's own origin and step, and a state off its grid is `CheckpointMidFrame`.
tag: F

old: Every mismatch of either kind is collected into one throw before any write.
tag: F

old: The door then copies the state back, settles the restored boundary through the hooks and writes `:consistent` last (D-318).
new: The entry point then copies the state back, settles the restored boundary through the hooks and writes `:consistent` last (D-318, D-319).
tag: R
ruling: R14
newcites: D-318 D-319
note: a `Model`'s entry point, so "entry point" (R14); D-319 bullet 2 added for the checks the paragraph states

old: `restore!(sim, cp)` takes the four recording keywords `init!` takes.
tag: F

old: It checks the checkpoint's fingerprint against the simulation as replay checks the trace header, and a mismatch is `CheckpointMismatch` (§12.7).
new: It checks the state's fingerprint and deployment against the simulation as replay checks the trace header (the trace's fixed preamble), and a mismatch is `CheckpointMismatch` (§12.7).
tag: R
ruling: R12

old: It checks the state's `t` against its grid as the model's door does, collecting both kinds into one throw.
new: It checks the state's `t` against its grid as the model's entry point does, collecting both kinds into one throw.
tag: R
ruling: R14

old: It then copies the state back, opens a fresh run with the checkpoint as its trace header, and publishes one snapshot at the checkpoint's `t`.
tag: F

old: It runs no sweep, evaluates no guard, runs no update and resets no prior.
new: It runs no sweep (one pass through the execution order against the current state), evaluates no guard, runs no update and resets no prior.
tag: F
note: sweep linked and glossed at its first use in §12.6

old: The next frame is the original lattice's next frame, because the clock came with the checkpoint.
tag: F

old: The boundary ordinal continues, being the trajectory's (§12.3, D-230).
new: The boundary ordinal continues, being the trajectory's (§12.3, D-274).
tag: R
ruling: R10
newcites: §12.3 D-274
note: F70, D-274 bullet 3

old: The snapshot `restore!` publishes is a re-publication.
tag: F

old: It carries the ordinal of the boundary the checkpoint was taken at, and the next frame publishes under the next ordinal, as it did in the original run.
tag: F

old: `restore!(sim, model_state)` is the door a state prepared on a standalone model takes into a simulation (§9.2).
new: `restore!(sim, model_state)` is the door a state prepared on a standalone model takes into a simulation (§9.2, D-319).
tag: C
newcites: §9.2 D-319

old: It takes the same keywords and makes the same fingerprint check, and it refuses a state whose `t` is off the grid as `CheckpointMidFrame`.
new: It takes the same keywords and makes the same check of the state's fingerprint and deployment, and it refuses a state whose `t` is off the grid as `CheckpointMidFrame`.
tag: R
ruling: R12

old: It opens a fresh trajectory at the state's frame, and the restored boundary publishes under ordinal 0, as boundary zero's does.
tag: F

old: A standalone model published nothing, so the trajectory has no ordinals to continue.
tag: F

old: A `Checkpoint` holds a `ModelState{Float64}`, so it is nominal by type.
tag: F

old: A state taken at another scalar is refused by dispatch with the same `CheckpointMismatch`, on either `restore!` that takes a bare state.
tag: F

added: #### Device attachments across runs

old: Device attachments persist across re-initialization, because attachment is orthogonal to the run lifecycle (§11.3).
new: Device attachments persist across re-initialization (D-088), because attachment is orthogonal to the run lifecycle (§11.3).
tag: C
newcites: D-088 §11.3
note: D-088 Rationale only

old: Persistence means roster persistence.
new: Persistence means roster persistence, the roster being the list of attached device entries.
tag: F

old: Binding, claims and device id survive.
new: Binding, claims (the set of faces a device may write) and device id survive.
tag: F

old: Tasks and OS resources do not (the per-run topology, §11.1; the teardown, §12.4).
new: Tasks and OS resources do not, the per-run topology being specified in §11.1 and the teardown in §12.4.
tag: F

old: Each `run!` re-initializes every rostered device and spawns its task.
new: Each `run!` re-initializes every rostered device and spawns a task for each whose `init!` succeeds (§11.1, D-093).
tag: R
ruling: B3
newcites: §11.1 D-093
note: a device whose `init!` failed gets no task (§11.1, D-138); D-093's Position spawns per roster entry after per-run `init!` (B3)

old: `attach!` while stopped only registers, and the task appears at the next `run!`.
tag: F

old: Task topology follows the roster each time (§11.1).
new: Which devices get a task at each `run!` is decided as §11.1 specifies.
tag: R
ruling: R5
note: M54, F53; a plain pointer, no bold

old: A front end attached by hand is still rostered, so the next `run!` spawns its task again.
new: A front end attached by hand is still rostered (D-310), so the next `run!` spawns its task again.
tag: R
ruling: R5
newcites: D-310
note: bold headline clause, D-310 bullet 2

added: #### The stop policy per advance

old: The stop policy is declared per advance.
new: The stop policy is declared per advance (D-255, D-316).
tag: F
newcites: D-255 D-316
note: kept whole as the home (R5); the citation repeats on the bold sentence

old: `t_end` and `ignore_stop_requests` are keywords of `run!`, `replay!` and `step!`,
new: `t_end` and `ignore_stop_requests` are keywords of `run!`, `replay!` and `step!`.
tag: F

old: and each call builds and validates the `StopPolicy` (the immutable value of `t_end` plus the ignored requester paths) it passes to the loop (§13.5, D-255, D-316).
new: Each call builds and validates the `StopPolicy` (the immutable value of `t_end` plus the ignored requester paths) it passes to the loop (§13.5, D-255, D-316).
tag: F

old: The value lives as long as the call, and afterwards only on the termination record of the advance that ended the run (D-260).
tag: F

old: A second run, or a `step!` sequence between two runs, can therefore stop on a different clock or honour a different set of stop requests without a rebuild.
tag: F

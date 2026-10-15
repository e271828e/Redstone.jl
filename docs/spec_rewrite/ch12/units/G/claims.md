old: ### 12.7 Replay: the trace re-drives the ordinary loop
tag: X

added: This section specifies replay, re-running the ordinary loop on a recorded input trace, so that a recorded session can be inspected, its errors reproduced and its run continued live.

added: A trace is the primary record of a session, a fixed trace header plus the batches drained at each frame.

added: A batch is a device's staged set of writes, and a device is any attached participant in the periphery.

added: A frame is one iteration of the loop, from drain to publication.

added: The drain is the frame-top swap that applies staged device writes to the root inputs.

added: The root inputs are the root component's own inputs, the only thing the periphery may write.

old: The entry point the §11.5 trace exists for:
new: `replay!` is the entry point the trace exists for (§11.5):
tag: X
note: framing sentence; it now names `replay!` as its subject; the section number left the adjective slot (step 5, P2-22)

old: `trc = trace(sim) # the recorded session: header + per-frame batches sim2 = Simulation(world) # the same build replay!(sim2, trc) # restore the header, then re-drive every recorded frame replay!(sim2, trc; to_boundary = k) # partial: the §13.4 replay-pointer idiom replay!(sim2, trc; to_time = 100.0) # partial: the same halt addressed by time cp = checkpoint(sim) # the state at a frame-top rest restore!(sim2, cp) # that state alone: a warm restart, no feed`
tag: F
note: code block, verbatim

added: The parts below cover the one substitution replay makes, halting and the input mode (where the drain takes its batches from) across halts, what stays the loop's, and the validation up front.

added: They then cover the what-if replay, re-driving the recorded inputs through a modified model, with the `restore = false` form, which attaches the feed to the simulation as it stands.

added: The rejected shapes close the section.

added: #### One substitution

old: `replay!` is the ordinary loop with exactly one substitution, not a second loop.
new: `replay!` is the ordinary loop with exactly one substitution, not a second loop (D-101, D-274).
tag: C
newcites: D-101 D-274
note: bold kept on the headline clause; D-101's Position rules the ordinary loop, D-274 bullet 4 reduces its substitutions to one

old: That is what keeps every property proved of the loop true of replay.
tag: F

old: The loop starts from a restored state, and its drain reads the trace:
new: The substitution is the drain, which reads the trace. Under the default form, `replay!(sim2, trc)` above, the loop also starts from a restored state.
tag: R
ruling: R9
note: the units section's two-forms rule; the restore is the default form's; the drain is the one substitution (D-274 bullet 4), and the default form is named by its call above (step 5, P2-24)

old: Restore from the header.
new: The default form restores from the header.
tag: R
ruling: R9
note: bold lead-in becomes a plain topic sentence scoped to the default form

old: `replay!` restores the trace's checkpoint (the `Model`'s state at a frame top as one value), the state the recording opened from.
new: It restores the trace's checkpoint (the `Model`'s state at a frame top, beside the run's frame index and boundary ordinal), the state the recording opened from.
tag: R
ruling: R9
note: two-forms rule; the subject is the default form named just before

old: It runs no boundary zero.
new: It runs no boundary zero
tag: F

added: (the initialization boundary at `t₀`)

old: The drain then reads the trace.
new: The drain reads the trace.
tag: M
note: M60, dropped; the drain paragraph's topic sentence says it

old: `replay!` stands in the `init!` position of the lifecycle (§12.6) and does what `restore!` does, with the trace header as the checkpoint.
new: This form stands in the `init!` position of the lifecycle (§12.6) and does what `restore!` does, with the trace header as the checkpoint (D-274).
tag: C
note: subject scoped to the default form (two-forms rule, R9)
newcites: §12.6 D-274

old: There is no condition resolution, and the totality (§14.6) held when the recording's `init!` ran.
new: There is no condition resolution, and the root-input totality (every root input must hold a value) (§14.6) held when the recording's `init!` ran.
tag: F
note: the term named and glossed as half 1 does (step 5, P2-25)

added: A condition is the datum that says "set this build to this state".

old: Whatever fired at `t₀` is part of the restored state, so nothing is applied twice and nothing is skipped (D-274).
tag: F

old: The drain reads the trace.
tag: F
note: bold lead-in becomes a plain topic sentence

old: Each frame top applies the recording's batches for that frame ordinal, the frame index a batch replays at.
new: Each frame top applies the recording's batches for that frame ordinal, the frame index a batch replays at (D-101).
tag: C
newcites: D-101

old: It does not swap the roster's staging cells,
new: It does not swap the staging cells of the roster
tag: F

added: (the list of attached device entries)

old: where a device's pending write batch waits between drains.
new: A staging cell is where a device's pending write batch waits between drains.
tag: F
note: the staging cell's gloss, its own sentence

old: Ordinal keying is exact because the frame sequence is itself deterministic under replay (`t` boundaries derive from state, §10.4).
tag: F

old: Frame k of the replay is frame k of the recording.
tag: F

old: Recorded batches apply verbatim, with no surface re-check.
new: Recorded batches apply verbatim, with no surface re-check (D-101).
tag: C
newcites: D-101
note: bold dropped; one ruling with the D-101 bold above

old: The write-surface rule (§11.3) ran at recording time,
new: The write-surface rule (the bound on the faces a writer's batch entries may reach) (§11.3) ran at recording time,
tag: F
note: the write-surface and face glosses moved off the middle of the old sentence (step 5, P2-26)

added: A face is the name a port wears on its component's boundary.

old: and claims are a live-roster fact of the recorded session that replay does not reconstruct.
new: and claims (the set of faces a device may write) are a live-roster fact of the recorded session that replay does not reconstruct.
tag: F
note: claim's first-use gloss added inside the span

old: Rule. A simulation is in one of two input modes, `:live` or `:replay`, and the mode decides which source that one drain branch reads:
new: A simulation is in one of two input modes, `:live` or `:replay`, and the mode decides which source that one drain branch reads (D-218).
tag: R
ruling: B7
newcites: D-218
note: label dropped; D-218 was adjacent. The bold covers the headline clause only, "the mode decides which source that one drain branch reads", since §12.6 states the modes plain (B7)

old: the staging cells under `:live`, the attached recording under `:replay`.
new: Under `:live` it reads the staging cells, and under `:replay` the attached recording.
tag: F

old: `replay!` attaches the recording and enters `:replay`.
new: `replay!` attaches the recording and enters `:replay` (D-218).
tag: F
newcites: D-218
note: bold, D-218 bullet 1; the citation was adjacent

old: `step!` and `run!` consume it from there, frame by frame, exactly as the bullet above describes.
new: `step!` and `run!` consume it from there, frame by frame, exactly as the drain paragraph above describes.
tag: X

old: There is still one loop and one drain (D-218).
tag: F

old: Why. A mode that outlives the call makes a partial replay a resumable position rather than the end of an operation.
new: A mode that outlives the call makes a partial replay a resumable position rather than the end of an operation (D-218).
tag: C
newcites: D-218
note: label dropped; D-218 Rationale

old: Whatever advances the simulation next reads the same mode and finds the same records.
tag: F

old: That is what lets the reproduction workflow of §13.4 run through the ordinary entry points, with no replay-only spelling of `step!`.
tag: F

old: That workflow halts at the frame top the error names, then `step!`s the failing frame on its recorded inputs.
new: then `step!`s the failing frame on its recorded inputs
tag: M
note: merged into the error-reproduction sentence of the halting block, whose frame-entry boundary `k` the error names is that frame top (F54) (step 5, P2-35)

old: Rule. `replay!(sim, trc; restore = false)` attaches the feed to the simulation as it stands and restores nothing.
new: `replay!(sim, trc; restore = false)` attaches the feed to the simulation as it stands and restores nothing.
tag: M
note: M56, after the what-if; label dropped; no entry, so plain

old: The simulation must be `initialized`, at the recording's `t₀`, and at a frame from the header's to one short of the recording's last.
tag: M
note: M56

old: Anything else is refused before any write (`CheckpointMismatch`, its clock arm).
new: A simulation that is not `initialized` meets the lifecycle gate before any write, with `MissingInit` when it is `built` and `ServiceLifecycle` in any other state. One whose origin or frame is off the recording's is refused before any write as `CheckpointMismatch`, its clock arm.
tag: R
ruling: R18
note: F56 (R10) with R18's kinds and its write-order clause

old: One grid is thus an invariant of every replay, and `to_time` has one meaning.
tag: M
note: M56

old: The drain applies the records from the frame after the simulation's own.
tag: M
note: M56

old: This form is a door like the default one.
new: This form is a door like the default one
tag: M
note: M56

added: an entry point that builds a run (§12.6).

old: It builds a fresh run under the recording keywords, takes the simulation's own checkpoint as the new trace's header, and publishes one snapshot.
tag: M
note: M56

old: That form serves the what-if of a modified model initialized under the authored condition (below).
new: That form serves the what-if of a modified model initialized under the authored condition (above).
tag: M
note: M56 puts the what-if first

old: It also serves a seek, `restore!` of a checkpoint the recording passed through followed by the feed from the next frame (D-274).
tag: M
note: M56

old: Everything else is the loop as already specified:
new: #### What stays the loop's
tag: X
note: R13's six blocks; the list dissolves, and the halting bullets head their own block

old: Termination and partial replay.
new: #### Halting, and the mode across halts
tag: X
note: bold lead-in becomes a topic label (R13)

old: In `:replay` the recording is the bound.
new: In `:replay` the recording is the bound (D-218).
tag: R
ruling: R16
newcites: D-218
note: bold, D-218 bullet 2's first statement

old: Every advance's frame budget is capped at the recording's last frame, and `to_boundary = k` caps it earlier.
tag: F

old: That keyword is the consumer of the replay pointer (§13.4).
tag: F

old: `to_time` is the same cap addressed by time, the next bullet.
new: `to_time` is the same cap addressed by time (below).
tag: X

old: Either names a frame at or after the one the feed starts from.
new: Either keyword names a frame from the one the feed starts from through the recording's last
tag: R
ruling: R10
note: F68

old: That is the header's frame under the default form, and the simulation's own under `restore = false`.
new: The feed starts from the header's frame under the default form, and from the simulation's own under `restore = false` (below).
tag: F
note: antecedent named; pointer to the form's block

old: An earlier one is refused (`ArgumentInvalid`).
new: and anything else is refused (`ArgumentInvalid`).
tag: R
ruling: R10
note: F68; joined to the range sentence so "else" reads against the range (step 5, P2-28)

old: The `to_boundary` spelling is defined as running through the frame whose execution published boundary `k`,
new: `to_boundary = k` takes the frame-entry boundary index (§13.4), a count of frame tops. It is not the published-boundary ordinal that a snapshot (the immutable per-boundary publication) carries (§12.3). Replay runs through frame `k` and halts exactly at the frame top after it (D-128).
tag: R
ruling: R10
newcites: §13.4 §12.3 D-128
note: F83; snapshot's first-use gloss inside; bold headline cites D-128

old: so replay always halts at a frame top.
new: Replay therefore always halts at a frame top.
tag: F

old: For a grid boundary the halt is exactly at `k`, the frame that publishes one ending at it.
new: halts exactly at the frame top after it
tag: R
ruling: R10
note: F83, "For a grid boundary" goes

old: The frame-entry pointer (§13.4) lands the same way.
where: units/G/deleted.md
tag: R
ruling: B9
note: deleted as a consequence of F83 and R17: `to_boundary` takes the frame-entry boundary index itself, so the sentence compared the pointer with itself

old: A localized `t` boundary inside the frame (the crossing instant bracketed by root-finding over trial sweeps) is reproduced but not stoppable-at.
new: A localized `t` boundary (the crossing instant bracketed by root-finding over trial sweeps) inside the frame is reproduced but not stoppable-at (D-128).
tag: C
newcites: D-128

old: §10.4 separates the two indices. The trace stays frame-indexed, and boundaries are the reporting index.
new: The trace stays frame-indexed, replay pointers and error messages use the frame-entry boundary index, and snapshots carry the published-boundary ordinal (§10.4, §12.3).
tag: R
ruling: R17, B18
newcites: §10.4 §12.3
note: §12.3, which states the three indices, cited beside §10.4 (B18)

old: Replay may also end earlier still under the ordinary policies, since `t_end` and `ignore_stop_requests` are keywords of `replay!` exactly as of `run!` (§12.6).
new: Replay may also end earlier still under the ordinary policies, since `t_end` and `ignore_stop_requests` are keywords of `replay!` exactly as of `run!` (§12.6, D-255, D-316).
tag: C
newcites: §12.6 D-255 D-316

old: A termination the recorded session hit through a stop request reproduces itself anyway, deterministically.
new: A termination the recorded session hit through a stop request (an output port of the framework enum `StopFlag`) reproduces itself anyway, deterministically (D-127).
tag: C
newcites: D-127

old: A replay honours requests by default too, and the trace header records no policy,
new: A replay honours requests by default too, and the trace header records no policy.
tag: F

old: so a live run that ignored some is replayed under the same `ignore_stop_requests`.
new: So a replay of a live run that ignored some must pass the same `ignore_stop_requests`.
tag: R
ruling: R10
note: F67

old: `to_time` addresses the same halt by time.
new: the same halt addressed by time
tag: R
ruling: B8
note: the bold lead-in's topic sentence goes; its subject moves into the bold and its claim into an appositive (B8)

old: The keyword is mutually exclusive with `to_boundary`, and it halts at the last frame top at or before the time given:
new: `to_time` halts at the last frame top at or before the time given, the same halt addressed by time, and it is mutually exclusive with `to_boundary` (D-219).
tag: R
ruling: B8
newcites: D-219
note: clauses swapped so the bold headline leads; D-219 was adjacent. The bold names its subject, `to_time`, not "The keyword" (B8)

old: `k = ⌊(to_time − t₀)/h⌋` against the header's `t₀`.
new: It computes `k = ⌊(to_time − t₀)/h⌋` against the header's `t₀`, under either form.
tag: R
ruling: R9
note: two-forms rule; under restore = false the origin must equal the recording's, so the header's t₀ is the simulation's

old: A time falling between two frame tops floors onto the earlier one.
tag: F

old: The rounding is the deliberate opposite of `t_end`'s, which ends a run at the first grid boundary reaching or exceeding it (§12.4).
tag: F

old: `t_end` bounds a run, and `to_time` positions an inspection.
tag: F

old: The point of halting is to stand before the anomaly, so a halt that stepped past it would defeat the call (D-219).
tag: F

old: Validation is the other keywords'.
new: `to_time` is validated as the other keywords are.
tag: F

old: The value must be real, finite and at least `t₀`, and it must name a time the recording covers.
tag: F

old: The checks run before the replay writes anything, the restore included.
new: The checks run before the replay writes anything, the default form's restore included.
tag: R
ruling: R9
note: two-forms rule

old: The halt flips the mode only at the recording's end.
tag: F
note: bold lead-in becomes a plain topic sentence

old: A frame budget that runs out halts the loop at a frame top, leaving the simulation `initialized` (§12.6).
tag: F

old: The mode becomes `:live` exactly when that halt lands at the recording's last frame, with the records exhausted.
new: The mode becomes `:live` exactly when that halt lands at the recording's last frame, with the records exhausted (D-218).
tag: C
newcites: D-218
note: bold headline, D-218 bullet 3

old: It stays `:replay` otherwise, and the next `step!` or `run!` goes on consuming the recording.
tag: F

old: So no advance ever flips mid-run.
tag: F

old: A `run!` whose `t_end` lies past the recording halts at the last recorded frame, now `:live`, and the next call is the live continuation (D-218).
tag: F

old: `live!` is the mode's one manual door.
new: `live!` is the one call that moves the mode alone.
tag: R
ruling: R14

old: The flip above is automatic, and it happens only at the recording's end.
new: The flip above is automatic.
tag: F
note: "only at the recording's end" is stated by "The halt flips the mode only at the recording's end" above (step 5, P2-34)

old: `live!(sim)` performs it by hand.
tag: F

old: It sets the mode to `:live` and detaches the recording's remainder, touching nothing else.
new: `live!` sets the mode to `:live` and detaches the recording's remainder, touching nothing else (D-219).
tag: F
newcites: D-219
note: bold headline, D-219 bullet 2; D-219 was adjacent

old: The trajectory stands where the replay left it, and so does the trace with the header it inherited.
new: The trajectory stands where the replay left it, and so does the trace with its header, inherited under the default form.
tag: R
ruling: R9
note: two-forms rule; under restore = false the header is the simulation's own checkpoint

old: The next `run!` or `step!` is therefore the live continuation from the replayed boundary, and its drains append to the re-recorded prefix.
tag: F

old: `live!` is a stopped-sim operation, legal only on an `initialized` simulation in `:replay`.
tag: F

old: `:running` and `:errored` refuse under the ordinary lifecycle gates (§12.6), and a simulation already `:live` refuses too.
new: Every other state refuses under the ordinary lifecycle gates (§12.6), with `MissingInit` at `built` and `ServiceLifecycle` in the rest. A simulation already `:live` refuses too, with `ArgumentInvalid`.
tag: R
ruling: R10
note: F76 and F59's three kinds

old: The call would have nothing to do, and a loud refusal beats a silent no-op (D-219).
tag: F

old: That door is what makes the rewrite workflow real.
new: That call is what makes the rewrite workflow real.
tag: R
ruling: R14

old: An interactive session is interrupted at t = 110, and the last ten seconds are to be flown again:
tag: F

old: ```julia trc = trace(sim) # the interrupted session, out to t = 110 sim2 = Simulation(world) replay!(sim2, trc; to_time = 100.0) # halt at the last frame top at or before 100 latest(sim2) # inspect the boundary landed on live!(sim2) # drop the remainder; the mode is :live run!(sim2; t_end = 130.0) # live from t = 100, re-recording onward ```
new: `trc = trace(sim) # the interrupted session, out to t = 110 sim2 = Simulation(world) replay!(sim2, trc; to_time = 100.0) # halt at the last frame top at or before 100 latest(sim2) # inspect the boundary landed on live!(sim2) # drop the remainder; the mode is :live run!(sim2; t_end = 130.0) # live from t = 100, re-recording onward`
tag: R
ruling: R13
note: the fence leaves its list item and loses its two-space indent; lines verbatim

old: The trace `sim2` leaves behind is a complete recording of itself: the replayed prefix out to t = 100, then the frames flown live after it.
new: The trace `sim2` leaves behind is a complete recording of itself, the replayed prefix out to t = 100 and then the frames flown live after it, since replay re-records (below).
tag: F
note: mid-sentence colon removed; the pointer at "Replay re-records", which M56/M57 placed later (step 5, P2-36)

old: Replay ends `initialized`, never `stopped`.
new: A replay's halt leaves the simulation `initialized`, never `stopped` (D-218).
tag: R
ruling: R16
newcites: D-218
note: F55's wording, now plain; R16 moves bullet 2's bold to the bound

old: That state is boundary-consistent and ready to advance, the same state `step!` leaves (§12.6).
tag: F

old: This is what makes three promised workflows real.
new: This is what makes three promised workflows real (D-101).
tag: C
newcites: D-101

old: State-trajectory inspection asks "what was the private state at t = 37.2?", and answers it by replaying there and reading the live stores (§11.2).
tag: F

old: Error reproduction replays to `k − 1`, then `step!`s the failing frame under instrumentation (§13.4).
new: Error reproduction replays to the frame-entry boundary `k` the error names, then `step!`s the failing frame on its recorded inputs, under instrumentation (§13.4).
tag: R
ruling: R10
note: F54

old: Continuation is `run!` after `replay!`, a live session from the replayed boundary.
tag: F

old: After a full replay that is the next call, the records exhausted at the halt.
tag: F

old: After a partial one the remainder of the recording is consumed first, across as many `step!` and `run!` calls as the caller makes, and the session goes live at the recording's end.
tag: F

old: Or `live!` drops that remainder, and the continuation starts at the halt.
tag: F

old: Replay re-records.
new: Replay re-records (D-101).
tag: C
newcites: D-101
note: bold headline; D-101 Rationale only

old: The drain records normally.
tag: F

old: The new trace inherits the old header and accumulates the re-drained batches, a bit-identical prefix.
new: Under the default form the new trace inherits the old header and accumulates the re-drained batches, a bit-identical prefix.
tag: R
ruling: R10
note: F82

added: Under `restore = false` the new trace's header is the simulation's own checkpoint (below).

old: A replayed-then-continued session therefore leaves behind a complete, valid trace of itself, with no special stitching.
tag: F

old: Pacing and the control plane are unchanged (§10.7, §12.1).
new: Pacing and the control plane are unchanged (§10.7, §12.1, D-101).
tag: C
newcites: §10.7 §12.1 D-101
note: bold headline; D-101 Rationale only

added: The control plane is the separate atomic surface carrying pause, pace and stop.

old: Pacing (waits inserted between completed frames, never altering the boundary sequence) sits outside the semantics, so paused, slow-motion or real-time replay is free.
tag: F

old: Paced replay with an attached visualizer is session playback, and `replay!` takes `pace` and `margin` as `run!` does (D-269).
new: Paced replay with an attached visualizer is session playback, and `replay!` takes `pace` and `margin` as `run!` does (§12.1, D-269).
tag: R
ruling: R5
newcites: §12.1 D-269
note: §12.1 holds the pace keywords; pointer added

old: Stop truncates, as anywhere.
tag: F

old: Devices are readers.
new: Devices are readers (D-218).
tag: C
newcites: D-218
note: bold lead-in becomes a plain topic sentence; D-218 bullet 1, whose bold is on its first sentence

old: Rostered devices init and spawn normally (§11.1) and consume snapshots (§11.2, §12.3).
tag: F

old: That is the visualizer case.
tag: F

old: But no live staging cell is drained while the simulation is in `:replay`.
tag: F

old: A batch found staged is discarded with a rate-limited warning (`ReplayDiscardedStaging`, Appendix C).
tag: F

old: Mixing live writes into a replay would destroy the property replay exists to provide.
tag: F

old: A session that wants live input is a continuation (`run!` after replay), not a replay.
tag: F

added: #### Validation up front

old: Validation is loud and up front.
new: Validation is loud and up front (D-101).
tag: C
newcites: D-101
note: M57, the pass heads its own block; bold headline, D-101 Rationale only

old: Before the first frame, the checkpoint's fingerprint is validated against the target, its layout against the `Build` (store layout, root input faces).
new: Before the first frame, the checkpoint's deployment (the scalar-free artifact the grid parameters fix) is compared against the target's. Its fingerprint, the structural layout, is compared against the `Build`. The fingerprint covers the store layout, the root-input faces, and what a copy by position relies on (§11.5).
tag: R
ruling: R12
newcites: §11.5
note: §11.5's naming and layout list; the deployment's gloss moved here with its first use

old: The trace's batch entries are validated against the root input-face list, and each batch's frame ordinal against the recording's frames, from the one after the header's to the last (D-217).
tag: F

old: Each writer's face-name → position schema, on the trace's `schemas` list (§11.5), is validated in the same pass.
tag: F
note: bold word dropped

old: A recorded schema that disagrees with the target model's own root-input faces is a replay error.
tag: F

old: The checks are attach-style, and a failure reports did-you-mean: the offending name plus the list-in-hand it should have matched.
new: The checks are attach-style, and a failure reports did-you-mean, the offending name plus the list-in-hand it should have matched.
tag: F
note: mid-sentence colon removed

old: The kinds are `CheckpointMismatch`, `ReplaySchemaMismatch` and `ReplayUnknownFace` (Appendix C).
tag: F

old: The pass runs under both forms of `replay!`.
tag: F

old: The same pass pays the trace-record conversion in reverse.
tag: F

old: Every writer's sparse records (§11.5) are normalized to positional batches against the trace's `schemas` list, once, off the loop.
new: Every writer's sparse records (§11.5) are normalized to positional batches against the trace's `schemas` list, once, off the loop (D-101, D-176).
tag: C
newcites: §11.5 D-101 D-176

old: Replay has the whole trace in hand before frame 1.
tag: F

old: The replay drain therefore applies compiled scatters exactly as the live drain does, and no face name is resolved per frame under replay either.
tag: F

old: Structural mismatch is an error.
tag: F

old: Parametric difference is not.
new: Parametric difference is not (D-101).
tag: C
newcites: D-101

added: #### What-if replay and `restore = false`

old: Replaying against the same structure with changed parameters is the what-if replay, the deterministic re-driving of the recorded inputs through a modified model.
new: Replaying against the same structure with changed parameters is the what-if replay.
tag: M
note: block 5; bold term dropped; the gloss is stated once, in the context paragraph, and "deterministic" by "What-if replay promises determinism" (step 5, P2-23)

old: It is spelled as `init!` of the modified model under the authored condition, then `replay!(sim, trc; restore = false)`.
tag: M

old: The trace is not self-sufficient for it.
tag: M

old: Its checkpoint holds the recording model's state after boundary zero, so the authored condition comes from outside (D-274).
tag: M

old: Bit-identity is promised only against the identical build.
new: Bit-identity is promised only against the identical build (§2.4).
tag: C
newcites: §2.4
note: §2.4 states the law; this is the mechanism's statement

old: What-if replay promises determinism, never reproduction.
tag: M

old: The checkpoint check compares two deployments as values (D-254).
tag: F

old: The checkpoint carries the recorded run's `Deployment`
tag: F

old: (the scalar-free artifact the grid parameters fix)
tag: M
note: the deployment's gloss moves with its link to the first use, in the validation paragraph

old: the target `Simulation` carries its own
new: the target simulation's `Model` carries its own
tag: R
ruling: R10
note: F81

old: and the check is their comparison, on the structural side of that line (§11.5).
new: and the check is their comparison, on the structural side of that line.
tag: R
ruling: R10
newcites: none
note: F52; "that line" is the structural and parametric line just above

old: The value covers the trajectory-determining parameters, `Δt_base`, `h`, `N_base`, the algorithm, `localization_tol`, `localization_budget` (§10.4) and `firing_budget` (§10.6),
new: The value covers the trajectory-determining parameters, `Δt_base`, `h`, `N_base`, the algorithm, `localization_tol`, `localization_budget` (§10.4) and `firing_budget` (§10.6, D-133).
tag: C
newcites: §10.4 §10.6 D-133

old: and the schedule (the typed per-component `(D, Φ, Δt)` tick table) with every column, the anchor and rate-chain columns included.
new: It also covers the schedule (the typed per-component `(D, Φ, Δt)` tick table) with every column, the anchor and rate-chain columns included.
tag: F

old: A rate re-declared through a different anchor at the same tick table is therefore a different deployment, and the replay is refused.
tag: F

old: The refusal costs one re-recording in a rare case, and it keeps the equality a plain value equality rather than one that ignores two of a row's columns.
tag: F

old: Mismatch is `CheckpointMismatch` with a deployment-parameter discriminator, never a what-if.
new: Mismatch is `CheckpointMismatch` with a deployment-parameter discriminator, never a what-if (D-127).
tag: C
newcites: D-127

old: A deployment change moves the times at which the frame-ordinal batches apply.
tag: F

old: That is different inputs, not a modified model.
tag: F

old: The event trio (the localization pair and `firing_budget`) is compared for exactly the same reason the grid parameters are.
tag: F

old: It moves the trajectory, so a run that differs in it is not re-driving the recorded one.
tag: F

old: Comparison by value is what makes the check one expression rather than a field-by-field walk.
tag: F

old: The clock is restored, not compared.
new: Under the default form the clock is restored, not compared.
tag: R
ruling: R10
note: F57

old: Replay restores `t₀` with the rest of the clock, so `replay!` takes no `t0` argument.
new: That form restores `t₀` with the rest of the clock, so `replay!` takes no `t0` argument (D-127).
tag: C
note: subject scoped to the default form (F57, R10)
newcites: D-127

added: Under `restore = false` the simulation's own clock runs, and its origin must equal the recording's.

old: The checkpoint holds no policy (D-255).
tag: F

old: `t_end` and `ignore_stop_requests` are keywords of this `replay!` call, validated per call as at `run!`.
tag: F

old: The dispositions, by trace content:
tag: F

old: | trace content | disposition | |---|---|
tag: F
note: table header, verbatim

old: | the checkpoint's layout: store layout, root-input faces | compared against the `Build` |
new: | the checkpoint's fingerprint: store layout, root-input faces, and what a copy by position relies on | compared against the `Build` |
tag: R
ruling: R12

old: | the recorded `Deployment`, carrying `Δt_base`, `h`, `N_base`, the algorithm, `localization_tol`, `localization_budget`, `firing_budget` | compared as a value against the target `Simulation`'s own deployment |
new: | the recorded `Deployment`, carrying `Δt_base`, `h`, `N_base`, the algorithm, `localization_tol`, `localization_budget`, `firing_budget` | compared as a value against the deployment the target simulation's `Model` carries |
tag: R
ruling: R10
note: F81, and R12's row

old: | each writer's face-name → position schema (on the trace's `schemas` list) | validated against the target model's root-input faces: disagreement is a replay error |
tag: F

old: | the checkpoint's state | restored; no boundary zero |
new: | the checkpoint's state | restored under the default form; no boundary zero |
tag: R
ruling: R10
note: F57

old: | the clock | restored, `replay!` takes no `t0` |
new: | the clock | restored under the default form, `replay!` takes no `t0`; under `restore = false` the simulation's own clock runs, its origin equal to the recording's |
tag: R
ruling: R10
note: F57

old: | `t_end`, `ignore_stop_requests` | absent from the checkpoint; each `replay!` call declares its own (§13.5) |
tag: F

added: #### Rejected shapes

old: Rejected shapes, for the record (D-101): a `run!(sim; replay = trc)` flag, a synthetic playback device staging the recorded batches, and replay ending `stopped`.
new: Three shapes are rejected for the record (D-101). They are a `run!(sim; replay = trc)` flag, a synthetic playback device staging the recorded batches, and replay ending `stopped`.
tag: F
note: mid-sentence colon removed

old: The input mode clarifies that decision's drain substitution rather than replacing it, and carries its own rejected shapes (D-218).
tag: F

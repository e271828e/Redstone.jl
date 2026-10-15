### 12.7 Replay: the trace re-drives the ordinary loop

The entry point the [§11.5][s11-5] [trace](#g-trace) exists for:

```julia
trc  = trace(sim)                     # the recorded session: header + per-frame batches
sim2 = Simulation(world)              # the same build
replay!(sim2, trc)                    # restore the header, then re-drive every recorded frame
replay!(sim2, trc; to_boundary = k)   # partial: the §13.4 replay-pointer idiom
replay!(sim2, trc; to_time = 100.0)   # partial: the same halt addressed by time
cp   = checkpoint(sim)                # the state at a frame-top rest
restore!(sim2, cp)                    # that state alone: a warm restart, no feed
```

`replay!` is **the ordinary loop with exactly one substitution**, not a
second loop. That is what keeps every property proved of the loop true of
[replay](#g-replay). The loop starts from a restored state, and its drain
reads the trace:

- **Restore from the header.** `replay!` restores the trace's
  [checkpoint](#g-checkpoint) (the `Model`'s state at a frame top as one
  value), the state the recording opened from. It runs no
  [boundary zero](#g-boundary-zero). The drain then reads the trace.
  `replay!` stands in the `init!` position of the lifecycle
  ([§12.6][s12-6]) and does what `restore!` does, with the trace header as
  the checkpoint. There is no condition resolution, and the totality
  ([§14.6][s14-6]) held when the recording's `init!` ran. Whatever fired at
  `t₀` is part of the restored state, so nothing is applied twice and
  nothing is skipped ([D-274][d-274]).
- **The [drain](#g-drain) reads the trace.** Each frame top applies the
  recording's batches for that **[frame ordinal](#g-frame-ordinal)**, the
  frame index a batch replays at. It does not swap the [roster](#g-roster)'s
  [staging cells](#g-staging-cell), where a device's pending write batch
  waits between drains. Ordinal keying is exact because the frame sequence
  is itself deterministic under replay (`t*` boundaries derive from state,
  [§10.4][s10-4]). Frame *k* of the replay *is* frame *k* of the recording.
  Recorded batches apply **verbatim, with no surface re-check**. The
  write-surface rule ([§11.3][s11-3]) ran at recording time, and
  [claims](#g-claim) are a live-roster fact of the recorded session that
  replay does not reconstruct.

**Rule.** A simulation is in one of two [input modes](#g-input-mode),
`:live` or `:replay`, and the mode decides which source that one drain
branch reads: the [staging cells](#g-staging-cell) under `:live`, the
attached recording under `:replay`. `replay!` attaches the recording and
enters `:replay`. `step!` and `run!` consume it from there, frame by frame,
exactly as the bullet above describes. There is still one loop and one drain
([D-218][d-218]).

**Why.** A mode that outlives the call makes a partial replay a resumable
position rather than the end of an operation. Whatever advances the
simulation next reads the same mode and finds the same records. That is
what lets the reproduction workflow of [§13.4][s13-4] run through the
ordinary entry points, with no replay-only spelling of `step!`. That
workflow halts at the frame top the error names, then `step!`s the failing
frame on its recorded inputs.

**Rule.** `replay!(sim, trc; restore = false)` attaches the feed to the
simulation as it stands and restores nothing. The simulation must be
`initialized`, at the recording's `t₀`, and at a frame from the header's to
one short of the recording's last. Anything else is refused before any write
(`CheckpointMismatch`, its clock arm). One grid is thus an invariant of every
replay, and `to_time` has one meaning. The drain applies the records from the
frame after the simulation's own.
This form is a door like the default one. It builds a fresh run under the
recording keywords, takes the simulation's own checkpoint as the new trace's
header, and publishes one snapshot. That form serves the what-if of a modified
model initialized under the authored condition (below). It also serves a seek,
`restore!` of a checkpoint the recording passed through followed by the feed
from the next frame ([D-274][d-274]).

Everything else is the loop as already specified:

- **Termination and partial replay.** In `:replay` the recording is the
  bound. Every advance's frame budget is capped at the recording's last
  frame, and `to_boundary = k` caps it earlier. That keyword is the consumer
  of the replay pointer ([§13.4][s13-4]). `to_time` is the same cap
  addressed by time, the next bullet. Either names a frame at or after the
  one the feed starts from. That is the header's frame under the default
  form, and the simulation's own under `restore = false`. An earlier one is
  refused (`ArgumentInvalid`). The `to_boundary` spelling is defined
  as running **through the frame whose execution published boundary `k`**,
  so replay always halts at a frame top. For a grid boundary the halt is
  exactly at `k`, the frame that publishes one ending at it. The frame-entry
  pointer ([§13.4][s13-4]) lands the same way. A [localized](#g-localized)
  `t*` boundary inside the frame (the crossing instant bracketed by
  root-finding over trial sweeps) is reproduced but not stoppable-at.
  [§10.4][s10-4] separates the two indices. The trace stays frame-indexed,
  and boundaries are the reporting index. Replay may also end earlier still
  under the ordinary policies, since `t_end` and `ignore_stop_requests` are
  keywords of `replay!` exactly as of `run!` ([§12.6][s12-6]). A termination
  the recorded session hit through a stop request reproduces itself anyway,
  deterministically. A replay honours requests by default too, and the trace
  header records no policy, so a live run that ignored some is replayed
  under the same `ignore_stop_requests`.
- **`to_time` addresses the same halt by time.** The keyword is mutually
  exclusive with `to_boundary`, and it halts at the **last frame top at or
  before** the time given: `k = ⌊(to_time − t₀)/h⌋` against the header's
  `t₀`. A time falling between two frame tops floors onto the earlier one.

  The rounding is the deliberate opposite of `t_end`'s, which ends a run at
  the first grid boundary reaching or exceeding it ([§12.4][s12-4]). `t_end`
  bounds a run, and `to_time` positions an inspection. The point of halting
  is to stand *before* the anomaly, so a halt that stepped past it would
  defeat the call ([D-219][d-219]).

  Validation is the other keywords'. The value must be real, finite and at
  least `t₀`, and it must name a time the recording covers. The checks run
  before the replay writes anything, the restore included.
- **The halt flips the mode only at the recording's end.** A frame budget
  that runs out halts the loop at a frame top, leaving the simulation
  `initialized` ([§12.6][s12-6]). The mode becomes `:live` exactly when that
  halt lands at the recording's last frame, with the records exhausted. It
  stays `:replay` otherwise, and the next `step!` or `run!` goes on
  consuming the recording. So no advance ever flips mid-run. A `run!` whose
  `t_end` lies past the recording halts at the last recorded frame, now
  `:live`, and the *next* call is the live continuation ([D-218][d-218]).
- **`live!` is the mode's one manual door.** The flip above is automatic,
  and it happens only at the recording's end. `live!(sim)` performs it by
  hand. It sets the mode to `:live` and detaches the recording's remainder,
  touching nothing else. The trajectory stands where the replay left it, and
  so does the trace with the header it inherited. The next `run!`
  or `step!` is therefore the live continuation from the replayed boundary,
  and its drains append to the re-recorded prefix. `live!` is a stopped-sim
  operation, legal only on an `initialized` simulation in `:replay`.
  `:running` and `:errored` refuse under the ordinary lifecycle gates
  ([§12.6][s12-6]), and a simulation already `:live` refuses too. The call
  would have nothing to do, and a loud refusal beats a silent no-op
  ([D-219][d-219]).

  That door is what makes the rewrite workflow real. An interactive session
  is interrupted at t = 110, and the last ten seconds are to be flown again:

  ```julia
  trc  = trace(sim)                     # the interrupted session, out to t = 110
  sim2 = Simulation(world)
  replay!(sim2, trc; to_time = 100.0)   # halt at the last frame top at or before 100
  latest(sim2)                          # inspect the boundary landed on
  live!(sim2)                           # drop the remainder; the mode is :live
  run!(sim2; t_end = 130.0)             # live from t = 100, re-recording onward
  ```

  The trace `sim2` leaves behind is a complete recording of *itself*: the
  replayed prefix out to t = 100, then the frames flown live after it.
- **Replay ends `initialized`, never `stopped`.** That state is
  boundary-consistent and ready to advance, the same state `step!` leaves
  ([§12.6][s12-6]). This is what makes three promised workflows real.
  State-trajectory inspection asks "what was the private state at
  t = 37.2?", and answers it by replaying there and reading the live stores
  ([§11.2][s11-2]). Error reproduction replays to `k − 1`, then `step!`s the
  failing frame under instrumentation ([§13.4][s13-4]). Continuation is
  `run!` after `replay!`, a live session from the replayed boundary. After a
  full replay that is the next call, the records exhausted at the halt.
  After a partial one the remainder of the recording is consumed first,
  across as many `step!` and `run!` calls as the caller makes, and the
  session goes live at the recording's end. Or `live!` drops that
  remainder, and the continuation starts at the halt.
- **Replay re-records.** The drain records normally. The new trace
  inherits the old header and accumulates the re-drained batches, a
  bit-identical prefix. A replayed-then-continued session therefore leaves
  behind a complete, valid trace of *itself*, with no special stitching.
- **[Pacing](#g-pacing) and the [control plane](#g-control-plane) are
  unchanged** ([§10.7][s10-7], [§12.1][s12-1]). Pacing (waits inserted
  between completed frames, never altering the boundary sequence) sits
  outside the semantics, so paused, slow-motion or real-time replay is free.
  Paced replay with an attached visualizer *is* session playback, and
  `replay!` takes `pace` and `margin` as `run!` does ([D-269][d-269]). Stop
  truncates, as anywhere.
- **[Devices](#g-device) are readers.** Rostered devices init and spawn
  normally ([§11.1][s11-1]) and consume [snapshots](#g-snapshot)
  ([§11.2][s11-2], [§12.3][s12-3]). That is the visualizer case. But no live
  staging [cell](#g-staging-cell) is drained while the simulation is in
  `:replay`. A batch found staged is discarded with a rate-limited warning
  (`ReplayDiscardedStaging`, [Appendix C][sC]). Mixing live writes into a
  replay would destroy the property replay exists to provide. A session that
  wants live input is a continuation (`run!` after replay), not a replay.
- **Validation is loud and up front.** Before the first frame, the checkpoint's
  fingerprint is validated against the target, its layout against the `Build`
  (store layout, root input [faces](#g-face)). The trace's batch entries are validated
  against the root input-face list, and each batch's frame ordinal against the
  recording's frames, from the one after the header's to the last ([D-217][d-217]). Each
  writer's face-name → position schema, on the trace's `schemas` list ([§11.5][s11-5]),
  is **validated** in the same pass. A recorded schema that disagrees with the
  target model's own root-input faces is a replay error. The checks are
  attach-style, and a failure reports [did-you-mean](#g-did-you-mean): the offending name plus the
  list-in-hand it should have matched. The kinds are `CheckpointMismatch`,
  `ReplaySchemaMismatch` and `ReplayUnknownFace` ([Appendix C][sC]). The pass runs
  under both forms of `replay!`.

  The same pass pays the trace-record conversion in reverse. Every writer's
  sparse records ([§11.5][s11-5]) are normalized to positional batches
  against the trace's `schemas` list, once, off the loop. Replay has the whole
  trace in hand before frame 1. The replay drain therefore applies compiled
  scatters exactly as the live drain does, and no face name is resolved per
  frame under replay either.

  *Structural* mismatch is an error. *Parametric* difference is not.
  Replaying against the same structure with changed parameters is the
  **[what-if replay](#g-what-if-replay)**, the deterministic re-driving
  of the recorded inputs through a modified model. It is spelled as `init!`
  of the modified model under the authored condition, then
  `replay!(sim, trc; restore = false)`. The trace is not self-sufficient for
  it. Its checkpoint holds the recording model's state after boundary zero,
  so the authored condition comes from outside ([D-274][d-274]).
  Bit-identity is promised only against the identical build. What-if replay
  promises determinism, never reproduction.

  **The checkpoint check compares two deployments as values** ([D-254][d-254]).
  The checkpoint carries the recorded run's [`Deployment`](#g-deployment) (the
  scalar-free artifact the grid parameters fix), the target `Simulation`
  carries its own, and the check is their comparison, on the *structural* side
  of that line ([§11.5][s11-5]). The value covers the trajectory-determining
  parameters, `Δt_base`, `h`, `N_base`, the algorithm, `localization_tol`,
  `localization_budget` ([§10.4][s10-4]) and `firing_budget`
  ([§10.6][s10-6]), and the [schedule](#g-schedule) (the typed
  per-component `(D, Φ, Δt)` tick table) with every column, the anchor and
  rate-chain columns included. A rate re-declared through a different anchor
  at the same tick table is therefore a different deployment, and the
  replay is refused. The refusal costs one re-recording in a rare case, and
  it keeps the equality a plain value equality rather than one that ignores
  two of a row's columns. Mismatch is
  `CheckpointMismatch` with a deployment-parameter discriminator, never a
  what-if. A deployment change moves the times at which the frame-ordinal
  batches apply. That is different inputs, not a modified model. The event
  trio (the localization pair and `firing_budget`) is compared for exactly
  the same reason the grid parameters are. It moves the trajectory, so a
  run that differs in it is not re-driving the recorded one. Comparison by
  value is what makes the check one expression rather than a field-by-field
  walk.

  The clock is *restored*, not compared. Replay restores `t₀` with the rest
  of the clock, so `replay!` takes no `t0` argument. The checkpoint holds no
  policy ([D-255][d-255]). `t_end` and `ignore_stop_requests` are keywords of
  this `replay!` call, validated per call as at `run!`.

The dispositions, by trace content:

| trace content | disposition |
|---|---|
| the checkpoint's layout: store layout, root-input faces | compared against the `Build` |
| the recorded `Deployment`, carrying `Δt_base`, `h`, `N_base`, the algorithm, `localization_tol`, `localization_budget`, `firing_budget` | compared as a value against the target `Simulation`'s own deployment |
| each writer's face-name → position schema (on the trace's `schemas` list) | validated against the target model's root-input faces: disagreement is a replay error |
| the checkpoint's state | restored; no boundary zero |
| the clock | restored, `replay!` takes no `t0` |
| `t_end`, `ignore_stop_requests` | absent from the checkpoint; each `replay!` call declares its own ([§13.5][s13-5]) |

Rejected shapes, for the record ([D-101][d-101]): a `run!(sim; replay = trc)`
flag, a synthetic playback device staging the recorded batches, and replay
ending `stopped`. The input mode clarifies that decision's drain
substitution rather than replacing it, and carries its own rejected shapes
([D-218][d-218]).

---


# Unit A rulings: chapter 12 heading and roadmap, §12.1, §12.2, §12.3

## Corrections proposed

- **R2, escalated as E2, kept as written.** Old 8711–8716, "Nothing couples a
  stall to anyone else, the GUI least of all. … Under any starvation, then,
  the front end keeps rendering and the stop button keeps working." Rewrapped
  only, except F16's "the scheduler stall" in its first sentence, which F16
  names. Since D-310 bullet 1 the front end is a spawned device task, so the
  guarantee rests on D-027's withdrawn ground ("GUI on the calling task", log
  994). The snapshot and staging-cell links there keep no gloss, since R2
  allows a rewrap only.
- **R2, escalated as E2, kept as written.** Old 8823–8824, "The GUI does not
  use the wait. Being VSync-paced, it reads `latest` at each render." It
  describes the parked GUI's read path (D-134 Rationale log 4398–4399; D-310).
  "VSync" stays unintroduced with it.
- Old 8597–8598, "a few scalar fields on a separate atomic surface" (kept,
  as "that separate atomic surface"). `Control` also holds a
  `Threads.Condition` and the boundary counter (`src/control.jl` 62–72), so
  "scalar" is loose. Proposed text: "are a few fields on that separate atomic
  surface". Not applied.
- Track 2: the glossary's control-plane entry (spec 14173–14177) omits the
  sticky stopped status, as §12.1 did before F7.

## Citations added or replaced

- §10, §11 (opening): R1, the loop of §10 and the data plane of §11.
- §12.1–§12.7 (opening): R1's roadmap, each section by its title.
- D-022 (§12.1 context, "not staging, structurally"): Position, "control on
  a separate atomic surface (staging cannot un-pause a drainless loop)".
  Row 19's bold goes (R3); §11.1 6838 bolds it.
- D-021 (§12.1 context, "outside the semantics"; §12.2 "semantically free"):
  Position, "Pacing outside the semantics (bit-identical paced/unpaced
  trajectories)".
- D-310 (§12.1 issuers): R2, "a front end's button"; bullet 2, "A front end is
  attached by hand".
- D-132 (§12.1, the interrupt "sets exactly this stop"): Position, "The
  operator interrupt (Ctrl-C) is a control-plane stop, not a failure".
- §12.4 (§12.1, "the tail"): the tail's gloss points at its home.
- D-203 (§12.1 bold "The stop word carries its issuer"): bullet 3, "The
  control-plane stop word carries its issuer". The citation already sat two
  sentences on; it now also sits in the bold's sentence.
- D-106 (§12.1, F21 "A paused run is still running"): Position, "an error
  while `running`, pause included (pause is inside a run)".
- D-268 (§12.1 bold "The tail clears the pause flag"): bullet 1, "The tail
  clears the flag beside the sticky stopped status, and no run start clears
  it."
- D-133 (§12.1, `margin` 2 ms): Position, "`margin` = 2 ms". (§12.2, 2 s
  staleness): Position, "heartbeat staleness 2 s ([§12.2])".
- §12.3 and D-317 (§12.1, `Control`'s fields): the wait points at §12.3;
  D-317 bullet 6, "`Control` holds a running flag in place of the lifecycle
  state". D-317 and §12.4, D-256 split between the two sentences the old one
  became.
- D-027 (§12.2 yield bold; "The spin phase itself never yields"; "Since
  starvation is survivable, it must be diagnosable"): Position, "with devices
  attached every frame yields at least once"; "spin never yields";
  "per-device liveness heartbeat in framework status".
- Appendix C (§12.2, F15 `ThreadBudget`).
- D-310 (§12.2, the topology): bullet 1, "The loop runs on the calling task in
  every run, and every rostered device runs on a spawned task." (§12.2,
  "shows in a front end"): R2's citation for the section.
- D-136 (§12.2, the per-writer diagnostic cell): Position, "one per-writer
  diagnostic cell … and an atomic heartbeat timestamp".
- D-270 (§12.2 bold "`task_state` has three values"): annotation 2026-09-28,
  "[§12.2] now rules `task_state` as `:none` outside a run and, inside one,
  `:done` for any device without a live task of its own".
- D-028 (§12.3 bold "Two artifacts provide the wait"): Position, "monotonic
  boundary counter + `Threads.Condition`". (§12.3, "Shutdown works …"):
  "shutdown-interruptible via the predicate". (§12.3 bold "newest-wins, no
  queues"): "newest-wins, no queues — outbound coalescing mirrors inbound
  ZOH".
- D-114 (§12.3 bold "The order of the two publications is normative"):
  Position, "publication order is normative: the release-store of `latest`
  happens before the counter increment under the lock".
- D-128 (§12.3, the third index): Position, "`StepError`'s replay pointer is
  respelled the frame-entry boundary index".

## Rationale-only rulings

- No entry point for the interrupt (§12.1): D-132, Rejected, log 4285–4288.
- The first writer names the request that initiated the tail (§12.1): D-203,
  Rationale, log 7611–7615.
- The control plane is what anyone may poke (§12.1): D-255, Rationale log
  10077–10078 and Rejected log 10105–10106.
- The start-paused consequence and the trap the tail's clearing removes
  (§12.1): D-268, Rationale, log 11136–11139.
- The stop word cleared at the top of each run (§12.1): D-268, Rejected, log
  11192.
- A stepping session as the harness mode, bit-identical frames (§12.1):
  D-269, Rationale, log 11250–11253.
- The wait slot `sleep` buys (§12.2): D-027, Rejected, log 990–992.
- The spin's reason, the monopolist and the scheduler stall FlightCore's
  error prevented (§12.2): D-027, Rejected, log 993–995.
- One thread-budget check per run against the frozen roster (§12.2): D-106,
  Rejected, log 3382.
- `task_state`'s three values, `:done` without a task, the crash count,
  `orphaned` as exactly `:done` (§12.2, bold): D-270, annotation 2026-09-28,
  log 11413–11421. D-270's Position still reads "`:done` or `:failed`".
- The loose, advisory 2 s threshold tolerating a parked device (§12.2):
  D-133, Rationale, log 4335–4337.
- The counter counts boundaries, not frames (§12.3): D-081, Rejected, log
  2579–2580.
- Condition variables carry no facts; the `Event` latch (§12.3): D-028,
  Rejected, log 1011–1013.
- The counter never reset because `last_seen` must not run ahead (§12.3):
  D-230, Rationale log 8855–8858, Rejected log 8870–8871.
- Per-consumer queues rejected (§12.3): D-028, Rejected, log 1014–1015.

## Bold on the same entry elsewhere

- D-255: §12.1 bolds "`ControlRequestedStop` sits outside the stop policy";
  unit F's §12.6 (new.md line 379) bolds "The stop policy is declared per
  advance". Both come from D-255 bullet 4, in different sentences. Under the
  sentences reading they are two rulings; under the bullets reading they are
  one, bold twice. §13.5 (spec 10414, 10425) also bolds D-255 clauses.
- D-268: §12.1 bolds Position sentence 1 (the two verbs) and bullet 1's tail
  clearing; unit B bolds bullets 2–5 and the amended bullets; §11.6 (spec
  7895, 7905) bolds the two `shutdown!` tolerances. No sentence is bold twice.
- D-270: §12.2 bolds "`task_state` has three values" from the 2026-09-28
  annotation; §11.7 (spec 8375) bolds bullet 3's first sentence, the bullet
  whose `orphaned` clause the annotation narrows.
- D-133: §12.2 bolds the 2 s threshold; unit B bolds the `t_end` landing;
  §10.4 and §10.7 bold the tolerance, the budget, the forgiveness and the
  2 ms `margin`. Each is its own semicolon-separated item.
- D-203: §12.1 bolds bullet 3 (the stop word); unit B bolds bullet 4
  (`DeviceJoinTimeout`) and the lead sentence's residue.
- D-256: §12.1 alone bolds bullet 3 (`join_timeout` into `Control`); unit
  B's step (5) label is plain under R4.
- D-317, D-310, D-022, D-021, D-132, D-128: plain here, bold elsewhere
  (§12.6, §12.6 and §11.1, §11.1, §10.7, §12.4, §12.7).

## Inbound citations affected

- Spec 7312 (§11.3) and 11010 (§14's opening) cite §12.1 for "Pause is a
  control-plane state *inside* a run". F21's sentence now states it.
- Spec 14177 (glossary), 7165 (§11.3), 13013 (Appendix B): "structurally not
  staging" and "control commands are never staged" still hold; the sentence
  is §12.1's context now.
- The opening drops its links to control plane and replay (chapter 11's
  form); §12.1 and §12.3 link both. No inbound row relies on the opening's
  wording.
- Log 2929–2930 (D-093 Rejected, "§12.2's cannot-fail-to-be-scheduled
  argument") and 4398–4399 (D-134 Rationale, §12.3's GUI read path) are
  unchanged with E2.
- Spec 7380 (§11.3, "The §12.2 thread-budget warning runs once per run")
  holds.

## Open questions

1. The pause-block sentence (old 8635–8636) closed the paragraph M1 moves up.
   I placed it in the pause paragraph, which F8's "below" now names, rather
   than in the context. A move outside M1–M6 by the letter.
2. `Control`'s field list: the bold narrows from the whole sentence to D-256
   bullet 3's clause ("`Control` also keeps the shutdown tail's
   `join_timeout`"), the one ruling the sentence states whose home is §12.1
   (R5). The running flag (D-317 bullet 6) is bold at §12.6.
3. D-027's spin rule ("spin never yields") and its heartbeat clause, and
   D-028's "shutdown-interruptible via the predicate", are semicolon-separated
   rulings stated nowhere bold. R3 did not list them, so they are plain with
   their citations. Bold them here?
4. "Frame" stays unlinked in §12.3: its first use sits in a sentence that
   already carries the boundary-zero gloss. `last_seen` is never introduced
   beyond the predicate, as before.

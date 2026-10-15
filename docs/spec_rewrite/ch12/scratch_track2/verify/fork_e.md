# Fork E: new entries D-394 to D-402 (commit c31dea1)

Sources read in full at `c31dea1^`: D-132, D-133, D-138, D-218, D-219, D-255,
D-261, D-268, D-274, plus D-294, D-316 and D-317 where the entries cite them.
Positions grepped from `e_parent_decisions.md` (the `c31dea1^` file) through
`e_positions.txt`. Tip lines are `docs/design/decisions.md` at 45f5047.

## Counts

- Entries: 9. Position rulings (bullets, or the one sentence): 17.
- Findings: 6. F1 is firm. F2 to F6 are judgment calls (marked J).
- Clean on: E1 (no "resumable"), E2 (no GUI clause), the owner items (no
  `restore = false`, no `restore!` mode reset or keywords, no D-127 `t₀`, no
  "a stop belongs to the run it ended"); every Rejected item is one the source
  rejected, with its reasons; every Spec field names a chapter 12 section
  whose cited sentence states the ruling (§12.4 9124–9192, §12.2 8780, §12.4
  9051–9076, §12.7 9638, 9701, 9616, 9856, §12.1 8683, 8655, §12.6 9305,
  9330, §12.4 9155, 9178); template form; Spec fields sorted.
- The Rationales name the source and the field (Rationale, Rejected,
  annotation and its date), not line numbers. That matches D-294 and the
  other restating entries, so it is not a finding.

## Findings

**F1. D-397 restates D-218's Position (lesson 42), and its second clause's
source is the spec (lesson 43).** Commit c31dea1, `decisions.md` 15798.
Text: "The input mode outlives the `replay!` call, so after a partial replay
the recording still has a consumer, and the next `step!` re-executes the
following frame on its recorded inputs." D-218's Position already states it:
bullet 1, "`replay!` attaches the recording and enters `:replay`. `step!` and
`run!` consume it frame by frame from there", and bullet 3, the mode "stays
`:replay` otherwise". In D-218's Rationale the re-execution clause is "[§13.4]
promises that … a `step!` re-executes frame k+1 on its recorded inputs", so
its authority is the spec. Log 2's "no kept bullet's source cites the spec as
its authority" is wrong for this one. Fix: drop D-397 and its Index row, and
cite D-218 alone at spec 9638.

**F2 (J). D-399 bullet 2's second sentence restates two Positions.** Commit
c31dea1, `decisions.md` 15839–15841. Text: "The placeholder run gives every
accessor a run to read, and the lifecycle state says whether it started."
D-255's Position: "A `Simulation{T}` is constructed with a placeholder run …
`Control.lifecycle` says whether it started". D-261's Position: "The
placeholder an accessor needs is the one exception". Only "never `nothing`"
(D-255's Rationale and Rejected) is new. Fix: cut bullet 2 to "The
simulation's run field is never `nothing`."

**F3 (J). D-399 bullet 1 is a reason, and D-255's Position states its
ruling.** Commit c31dea1, `decisions.md` 15838. Text: "The control plane is
what anyone may poke, and a run's outcome is not." This is the reason D-255's
Rejected list gives against "`termination` staying on `Control`". D-255's
Position already rules "`termination` leaves `Control`". Log 2 dropped such
reasons elsewhere (B66, B68, B75: "is its reason"). Fix: drop bullet 1, keep
D-255 as the citation at spec 8683.

**F4 (J). D-398 follows from D-219's Position.** Commit c31dea1,
`decisions.md` 15818. Text: "After `live!` the trace keeps the header it
inherited, so the frames flown after the call append to the re-recorded
prefix". D-219 bullet 2: `live!` "sets the input mode to `:live` and detaches
the recording's remainder, touching nothing else". D-398's own Rationale
says so. Log 2 dropped a consequence of the same kind from D-397 ("no mid-run
flip (follows from bullet 3)"). Fix: drop D-398 and cite D-219 at spec 9701,
or keep it and record why it differs from the dropped case.

**F5 (J). D-400 follows from D-261's Position.** Commit c31dea1,
`decisions.md` 15859. Text: "Recording is per run: a long untraced run and
then a short traced one may share one simulation." D-261 bullet 7: "`trace`,
`log`, `log_every` and `log_max` are keywords of `init!` and `replay!`, the
doors that build a run". D-400's Rationale: per-run recording "comes with
that move". Same class as F4. Fix: drop D-400 and cite D-261 alone at spec
9305, or keep it under the same recorded reason as F4.

**F6 (J, minor). D-396 bullet 1's first clause restates D-138's Position.**
Commit c31dea1, `decisions.md` 15764. Text: "The failure is reported as the
ordinary `DeviceCrash`, with no diagnostic kind of its own." D-138's
Position: "reports `DeviceCrash` by name". Only "no diagnostic kind of its
own" is Rationale-only. Fix: "An init failure gets no diagnostic kind of its
own; `DeviceCrash`'s payload and disposition already fit."

## Checked, no finding

- D-402 bullet 1 ("records boundary zero's post-firing state faithfully and
  suppresses nothing"): D-274 bullet 4 places the header after boundary zero,
  but no Position says nothing is suppressed. Bullet 2 (the seek) is in no
  Position.
- D-394: masking, the second interrupt and the scope are in no Position.
  D-294 names only the unmask points, and D-268 only the four windows.
- D-395: the heartbeat's looseness is in no Position. D-373 says a stale
  heartbeat diagnoses and never forces an author obligation, which is a
  different ruling.
- D-401: the three bullets are in no Position. D-268's 2026-10-01 bullet is
  the later window (an interrupt after the throw), and D-317 rules only the
  model's catch.
- D-396 and D-401 lean on the 2026-10-15 annotations of D-138 and D-268,
  which d19fe88 added. Those annotations are other forks' scope.

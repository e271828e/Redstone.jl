# Chapter 12 inbound check, half 2 (§12.5, §12.6, §12.7)

Rows: the 221 rows of `inbound.tsv` whose target is §12.5, §12.6 or §12.7.
All three sections are listed in `inbound_scope.md`, so each row was judged
against the listed claims. Citing text was read in the frozen
`scratch_survey/h1/` copies for `spec.md` and `decisions.md`, and in the
working tree for the rest. The working tree's `implementation.md` and
companions are unchanged since `17ad42d`. New-chapter line numbers below are
`chapter_new.md` lines.

## Counts

| file | OK | RETARGET | MISSING | total |
|---|---|---|---|---|
| `spec.md` | 88 | 3 | 5 | 96 |
| `decisions.md` | 96 | 2 | 0 | 98 |
| `implementation.md` | 21 | 0 | 0 | 21 |
| `inbound_periphery_walkthrough.md` | 2 | 2 | 0 | 4 |
| `flight_case_studies.md` | 1 | 0 | 0 | 1 |
| `linearization_walkthrough.md` | 1 | 0 | 0 | 1 |
| **total** | **209** | **7** | **5** | **221** |

No row is COMPANION or VAGUE. No row is MISSING because of a loss. All five
MISSING rows were wrong before the rewrite. The renumbering kept every
section's number and title.

## MISSING (all wrong before the rewrite)

**spec 7716 (§11.5) → §12.6.** §12.6 never said that `init!` takes the
header at the end of boundary zero. This bold is §11.5's own ruling (D-274).
§12.7 (1329–1330) says only that the checkpoint holds the state after
boundary zero.

```
old: first snapshot is published ([§12.6][s12-6], [D-274][d-274]). A checkpoint holds the flat buffer
new: first snapshot is published ([D-274][d-274]). A checkpoint holds the flat buffer
```

**spec 11949 (§14.8) → §12.6.** This is survey 2 D's F73, confirmed. §12.6
(951–956) makes the trace, the log and the termination record new objects
rather than cleared ones, and it clears the staged batches.

```
old: The
     [recorders](#g-recorders) are cleared exactly as [§12.6][s12-6] states for
     `init!`. Those are the [trace](#g-trace), the log, and any
     [batches](#g-batch) still in [staging cells](#g-staging-cell) (where a
     device's pending write batch waits between drains).
new: The
     [recorders](#g-recorders) restart exactly as [§12.6][s12-6] states for
     `init!`. The [trace](#g-trace) and the log are new objects, and any
     [batches](#g-batch) still in [staging cells](#g-staging-cell) (where a
     device's pending write batch waits between drains) are cleared.
```

**spec 12764 (Appendix B, `restore!(model, …)`) → §12.6.** This is survey 2
D's row, confirmed. §12.6 never says the model's `restore!` takes no status
gate. D-319 bullet 2 says it. The R12 sync for the same item is included.

```
old: - `restore!(model, model_state; hooks = NoHooks())`. Checks the state's
       fingerprint (`CheckpointMismatch`) and its `t` against its grid
       (`CheckpointMidFrame`) before any write. Copies the state back, settles
       through the hooks and writes `:consistent` last. It takes no status
       gate ([§12.6][s12-6]). A writing door.
new: - `restore!(model, model_state; hooks = NoHooks())`. Checks the state's
       fingerprint and deployment (`CheckpointMismatch`) and its `t` against
       its grid (`CheckpointMidFrame`) before any write ([§12.6][s12-6]).
       Copies the state back, settles through the hooks and writes
       `:consistent` last. It takes no status gate ([D-319][d-319]). A
       writing door.
```

"A writing door" now clashes with R14 (see the last section).

**spec 12913 (Appendix B, `trim!`) → §12.6.** F73, confirmed.

```
old: anchored at `t0` and recordings cleared ([§12.6][s12-6]). On a `Model{Float64}`,
new: anchored at `t0` and the recorders built anew ([§12.6][s12-6]). On a `Model{Float64}`,
```

**spec 14370 (glossary, recorders) → §12.6.** F73, confirmed.

```
old: the trace and the log jointly. They are cleared together at
     `init!`, at `restore!` and at a trim commit, so they restart with the run
     they record ([§12.6][s12-6], [§14.8][s14-8]).
new: the trace and the log jointly. `init!`, `restore!` and a trim commit
     build them anew together, so they restart with the run they record
     ([§12.6][s12-6], [§14.8][s14-8]).
```

## RETARGET

**spec 12998 (Appendix B, `stage!`) → §11.3.** "Surface-checked" left §12.6
(C-137, relocated). §11.3 7263–7265 says the harness cell is "drained,
traced and surface-checked exactly as any device's". "The GUI's writes"
predates D-310.

```
old: and surface-checked exactly as the GUI's writes (the harness cell,
     [§12.6][s12-6]). It is legal under `run!` and `step!` alike.
new: and surface-checked exactly as any device's (the harness cell,
     [§11.3][s11-3]). It is legal under `run!` and `step!` alike
     ([§12.6][s12-6]).
```

**spec 14220 (glossary, harness cell) → §11.3 first.** "Any task" (7263,
D-200), "surface-checked" (7265) and "drained last" (7278) are §11.3's.
§12.6 keeps "ordinary" and "traced" (918–919).

```
old: convention ([§12.6][s12-6], [§11.3][s11-3]).
new: convention ([§11.3][s11-3], [§12.6][s12-6]).
```

**spec 14226 (glossary, harness writer) → §11.3.** Every clause is §11.3's
(7263–7271). §12.6 now points at §11.3 for the harness writer (R5).

```
old: `ClaimedFaceEntry` ([§11.3][s11-3], [§12.6][s12-6]).
new: `ClaimedFaceEntry` ([§11.3][s11-3]).
```

**decisions 3494 (D-109 Annotation) → §11.1.** R5 cut "Task topology follows
the roster each time" to a pointer at §11.1 (C-201), so §12.6 no longer holds
the "roster-derived" shorthand. Under `decisions_style.md` rule 2, the log's
citations track the current spec, so this is a citation edit only.

```
old: ([D-093][d-093], [§12.6][s12-6]) stands as shorthand for it.
new: ([D-093][d-093]) stands as shorthand for it.
```

**decisions 11153 (D-268 Rationale) → §11.1.** R5 cut "An unattended run is
the same loop with empty staging (§11.1)" to a pointer (C-115). §11.1
6890–6891 defines the unattended run, but as "empty staging and no snapshot
readers", not as "the deviceless one". §12.6 keeps "Deviceless, `run!` is
fully synchronous" (887). The orchestrator rules whether the citation swap
is enough.

```
old: The roster is the discriminator because [§12.6][s12-6] defines the unattended run as
     the deviceless one and [§13.4][s13-4]'s rethrow presupposes it.
new: The roster is the discriminator because [§11.1][s11-1] defines the unattended run,
     which a deviceless run is, and [§13.4][s13-4]'s rethrow presupposes it.
```

**inbound_periphery_walkthrough 5 → §11.3.** R5 moved what the harness cell
and the harness writer are to §11.3. §12.6 keeps only their use in a
stepping session.

```
old: `spec.md` [§11.3][s11-3] (root inputs, claims, the roster freeze), [§11.4][s11-4] (staging and the drain), [§11.7][s11-7] (GUI write path),
     [§12.6][s12-6] (harness cell) and decision ...
new: `spec.md` [§11.3][s11-3] (root inputs, claims, the roster freeze, the harness cell), [§11.4][s11-4] (staging and the drain), [§11.7][s11-7] (GUI write path)
     and decision ...
```

**inbound_periphery_walkthrough 197 → §11.3.** This is survey 2 D's row,
confirmed. The derived surface is §11.3's (7267–7271). §12.6 never said it.

```
old: ([§12.6][s12-6]). This is the design's one **derived** surface — the unclaimed
new: ([§11.3][s11-3]). This is the design's one **derived** surface — the unclaimed
```

## OK rows whose citing text needs a sync edit

In each of these rows, the new section still states what the citation relies
on. The citing text, however, disagrees with a ruling or keeps a known
pre-existing error.

- **spec 6893 (§11.1).** This error predates the rewrite. "Staging fed from a
  recording" contradicts §12.7, where the drain reads the trace and no
  staging cell is swapped (1095–1099). Old: "the same loop with staging fed
  from a recording". New: "the same loop with its drain fed from a
  recording".
- **spec 11018 (§14 table, `restore!`), R12.** Old: "a checkpoint whose
  fingerprint matches the simulation's". New: "a checkpoint whose
  fingerprint and deployment match the simulation's".
- **spec 12931 (Appendix B, `checkpoint(sim)`), R12 (C-169).** Old: "`t` and
  `t₀`, and the fingerprint." New: "`t` and `t₀`, the fingerprint and the
  deployment."
- **spec 12939 (Appendix B, `restore!(sim, cp)`), R12.** Old: "It checks the
  checkpoint's fingerprint (`CheckpointMismatch`)". New: "It checks the
  checkpoint's fingerprint and deployment (`CheckpointMismatch`)".
- **spec 12945 (Appendix B, `restore!(sim, model_state)`), R12.** Old: "the
  same fingerprint check". New: "the same fingerprint and deployment check".
- **spec 13037 (Appendix B, `replay!`), F68.** Old: "A halt names a frame at
  or after the one the feed starts from." New: "A halt names a frame from the
  one the feed starts from through the recording's last."
- **spec 13301 (Appendix C, `MissingInit`).** This is survey 2 D's row,
  confirmed. §12.7 names the kind for `live!` (1191) and for
  `replay!(…; restore = false)` (1338). Old: "**`MissingInit`**
  ([§12.6][s12-6]). … the entry point called (`run!`/`step!`)." New:
  "**`MissingInit`** ([§12.6][s12-6], [§12.7][s12-7]). … the entry point
  called (`run!`/`step!`/`replay!`/`live!`)."
- **spec 13393 (Appendix C, `CheckpointMismatch`, both rows), R12.** Old:
  "raised when a checkpoint's fingerprint disagrees with the target
  simulation or model". New: "raised when a checkpoint's fingerprint or
  deployment disagrees with the target simulation or model". The payload
  already lists the deployment arm.
- **spec 13428 (Appendix C, `ArgumentInvalid`).** This is survey 2 D's row,
  confirmed. §12.7 names the kind for the halt keywords (1135) and for
  `live!` on `:live` (1193). Add `[§12.7][s12-7]` after `[§12.6][s12-6]` in
  the citation, and add `live!` to the call list after `replay!`.
- **spec 14073 (glossary, `Model`), R14.** Old: "Its doors are listed". New:
  "Its entry points are listed".
- **spec 14376 (glossary, replay).** Survey 2 D's F51 is confirmed, and R12
  and F57 apply too. Old: "the drain reads the trace by frame ordinal, after
  the trace's checkpoint is restored. It re-records, ends `initialized`, and
  validates the checkpoint's fingerprint (stores, root-input faces and the
  `Deployment`) up front, restoring the clock with the rest of the state".
  New: "the drain reads the trace by frame ordinal, after the trace's
  checkpoint is restored under the default form. It re-records, ends
  `initialized`, and validates the checkpoint's fingerprint (the structural
  layout) and its `Deployment` up front. The default form restores the clock
  with the rest of the state".

## Notes for the orchestrator

- **R14 against Appendix B.** R14 defines *door* in §12.6 as an entry point
  that builds a run. Appendix B still calls the `Model`'s entry points
  "`Model`'s own doors" and "A writing door" (12735–12767), and spec 4336
  says "its doors". Spec 14073 (above) is the only one of these that cites
  §12.6. The rest need a ruling on one sense of *door* across the spec.
- **Pre-existing, outside the listed claims.** These are OK, with a note in
  the TSV. "A checkpoint is not a condition and has no algebra" (spec 11002,
  11061, 12931) was never §12.6's, and D-273 and D-274, cited beside it, rule
  it. Spec 7087, D-137's Spec field and D-198's Position cite §12.7 for
  replay ignoring `log_max` and `join_timeout`. §12.7 never names them, and
  the exclusion is implicit only, in the compared `Deployment`.
  `implementation.md` 807 files `to_time` under §12.6, but it is §12.7's.
- **Survey 2 D's other rows.** D-249 Position (`StopFaceInvalid`, log 9697)
  and D-127 Position (`ReplayHeaderMismatch`, log 4059) are confirmed. Their
  §12.7 citations hold, and both need an annotation under rule 1, not a
  citation edit. The checkpoint glossary entry (spec 14340) now agrees with
  R12 and §11.5. Only the replay entry still disagrees (above). The half-1
  rows (9054, 9080) and the log rows that cite no §12.5–§12.7 (8554, 3155,
  8292, 3173, 8223) are outside this check.

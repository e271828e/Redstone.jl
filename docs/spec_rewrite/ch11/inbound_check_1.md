# Chapter 11, half 1: the inbound check

Rows: the 324 rows of `inbound.tsv` whose target is §11, §11.1, §11.2, §11.3
or §11.4. Each was judged against `chapter_new.md` (§11.1 at line 14, §11.2
at 111, §11.3 at 381, §11.4 at 654). Citing text came from the frozen copies
for `spec.md` and `decisions.md`, and from the working tree for the rest. No
working-tree line had drifted. The per-row verdicts and notes are in
`inbound_check_1.tsv`.

## Counts

| verdict | rows |
|---|---|
| OK | 308 |
| RETARGET | 5 |
| COMPANION | 0 |
| MISSING | 11 |
| VAGUE | 0 |

| file | OK | RETARGET | MISSING |
|---|---|---|---|
| `spec.md` | 128 | 3 | 4 |
| `decisions.md` | 133 | 1 | 5 |
| `implementation.md` | 16 | 1 | 1 |
| `pending.md` | 4 | | |
| `extensions.md` | 2 | | |
| `companions/flight_case_studies.md` | 10 | | 1 |
| `companions/inbound_periphery_walkthrough.md` | 7 | | |
| `companions/frame_walkthrough.md` | 4 | | |
| `companions/migration_outline.md` | 2 | | |
| `companions/event_visibility_walkthrough.md` | 1 | | |
| `companions/localization_validation_walkthrough.md` | 1 | | |

The rewrite caused only four of the 16 non-OK rows: rows 54, 257 and 280,
where R5 moved where `EmptyGreedyClaim` lands into §11.6, and row 88's
cluster (rows 88, 119, 120), where R4 corrected the harness writer's task.
The rest were already wrong at `f61b1af`.

Notes on the OK verdicts:

- An OK on a superseded or later-replaced entry (D-109, D-134, D-165, D-271)
  is marked "Historical" in its note. The cited section holds the successor
  mechanism, and the log keeps the old one by rule 1.
- R3 dropped the bold on "Topology is derived after initialization" but kept
  the claim (§11.1, lines 96–98). Rows 38, 173 and 217 stay OK.
- R5 left a one-clause pointer at the old site in each of these cases, and
  the home is co-cited or reachable: the framework status (rows 53, 117),
  `map_output`'s NamedTuple (rows 76, 239, 240), the orphan label (rows 122,
  309) and the terminal snapshot's account (row 242).

## Rows that are not OK

### RETARGET

**Row 54**, `spec.md` 9778, cites §11.3. Since R5, §11.3 keeps only that
`attach!` records `EmptyGreedyClaim`. The roster entry's diagnostic cell is
stated in §11.6, "Greedy claims" (line 1447), with D-250. Old §11.3 stated
it at line 419.

- Old: `It mutates the roster, so `EmptyGreedyClaim` lands in`
  `the roster entry's cell ([§11.3][s11-3]).`
- New: `It mutates the roster, so `EmptyGreedyClaim` lands in`
  `the roster entry's cell ([§11.6][s11-6]).`

**Row 55**, `spec.md` 9788, cites §11.3. The bullet names `OutOfClaimEntry`,
`ClaimedFaceEntry`, the attach renormalization and `EntryTypeMismatch`.
§11.3 states the first two and staging-site enforcement. `EntryTypeMismatch`
and the renormalization are stated only in §11.4, "Diagnostic sites", and
the same was true before the rewrite.

- Old: `- **The write-surface and entry violations** ([§11.3][s11-3]), all raised at`
- New: `- **The write-surface and entry violations** ([§11.3][s11-3], [§11.4][s11-4]), all raised at`

**Row 75**, `spec.md` 12622, cites §11.4, in Appendix B's binding-trait table.
"The enumerated face set *is* the claim, what the device may write rather
than what it will" is stated in §11.3, "Exclusivity and claims" (line 449),
and old §11.3 stated it at line 384. §11.4 holds only `map_input` and the
attach-time read of `claims`.

- Old: `... what the device may write rather than what it will | [§11.4][s11-4] |`
- New: `... what the device may write rather than what it will | [§11.3][s11-3], [§11.4][s11-4] |`

**Row 257**, `decisions.md` 9627, D-250's Spec field, cites §11.3. Since R5,
§11.3 no longer states that the warning goes into the roster entry's cell,
and it no longer cites D-250. §11.6 holds that sentence with D-250. Old §11.3
stated it.

- Old: `**Spec.** [§9.2][s9-2], [§11.3][s11-3], [§11.8][s11-8], [§13.2][s13-2], [Appendix C][sC]`
- New: `**Spec.** [§9.2][s9-2], [§11.6][s11-6], [§11.8][s11-8], [§13.2][s13-2], [Appendix C][sC]`

The log is written bare and then linkified (decisions_style rule 3), so the
fixer edits `§11.3` to `§11.6` and runs `linkify.jl`.

**Row 280**, `implementation.md` 326, cites §11.3. This is row 54's claim in
the implementation map.

- Old: `` `attach!` into the roster entry's own cell (§11.3, D-250); ``
- New: `` `attach!` into the roster entry's own cell (§11.6, D-250); ``

### MISSING

**Row 12**, `spec.md` 3391, cites §11.3. Wrong before the rewrite. The
sentence says device and trace addressing share the canonical slash-path
form. §11.3 says the opposite. Devices, mappings and the trace address root
inputs by face name, and "Structural slash paths never reach the periphery's
writes" (lines 416–419). Old §11.3 said the same at line 364. The sentence
also contradicts spec 3467 in the same section. The proposed edit changes a
claim, so it needs a ruling.

- Old: `Declarations, error messages, [device](#g-device)/[trace](#g-trace) addressing ([§11.3][s11-3]) and the HDF5 log`
  `tree share it verbatim. A device is any attached participant outside the loop,`
  `and the trace is the primary record of a session. [Container children]...`
- New: `Declarations, error messages, snapshot and log inspection reads ([§11.2][s11-2]) and the HDF5 log`
  `tree share it verbatim. [Container children]...`

**Rows 88, 119 and 120**, `spec.md` 12795, 14021 and 14024, cite §11.3. Old
§11.3 said the harness writer stages "from the calling task itself". R4
corrected it to "from any task, the calling task included" (D-200). Appendix
B and the two glossary entries still carry the old clause. Everything else
these rows rely on is stated in §11.3. Row 43 (spec 9175, "with the calling
task as writer") is left OK because its context is a stepping session, where
the caller is the stager.

- Row 88, old: `- `stage!(sim, "face" => value, …)`. Task-free staging from the calling task`
  `into the harness writer ([§11.3][s11-3]).`
- Row 88, new: `- `stage!(sim, "face" => value, …)`. Task-free staging from any task, the`
  `calling task included, into the harness writer ([§11.3][s11-3]).`
- Row 119, old: `written by `stage!(sim, "face" => value, …)` from the calling task itself.`
- Row 119, new: `written by `stage!(sim, "face" => value, …)` from any task, the calling task included.`
- Row 120, old: `**harness writer** — the framework-owned write path of the calling task,`
- Row 120, new: `**harness writer** — the framework-owned write path open to any task,`

**Row 163**, `decisions.md` 3151, D-102's Rationale, cites §11.1. Wrong
before the rewrite. The Rationale says the GUI is "called inline on the
calling task". Since D-310, §11.1 says every rostered device runs on a
spawned task, and old §11.1 said the same. By decisions_style rules 1 and 10,
the entry gets an annotation, not a rewrite.

- Old: (after the Rationale paragraph) nothing.
- New: `Annotation (2026-10-13): [D-310][d-310] runs every rostered device, the GUI included, on a spawned task; the calling-task clause above is historical.`

**Row 174**, `decisions.md` 3409, D-109's Rejected list, cites §11.1. Wrong
before the rewrite. The item relies on a calling-task GUI render loop in
§11.1's topology, which D-310 removed. D-109 is already marked superseded by
D-310, so no edit is needed.

**Row 203**, `decisions.md` 4395, D-136's Spec field, cites §11.1. Wrong
before the rewrite. Neither old nor new §11.1 mentions the diagnostic cell
or the heartbeat.

- Old: `**Spec.** [§9.8][s9-8], [§10.7][s10-7], [§11.1][s11-1], [§11.2][s11-2], [§11.4][s11-4], ...`
- New: `**Spec.** [§9.8][s9-8], [§10.7][s10-7], [§11.2][s11-2], [§11.4][s11-4], ...`

**Row 205**, the same field, cites §11.4. Wrong before the rewrite. Neither
old nor new §11.4 mentions the diagnostic cells. §11.8 states that they are
taken at the frame top. You could keep §11.4 as the drain point the
Rationale names, but the field lists where the mechanism lives, so the
proposal drops it.

- Old: `..., [§11.2][s11-2], [§11.4][s11-4], [§11.6][s11-6], ...`
- New: `..., [§11.2][s11-2], [§11.6][s11-6], ...`

**Row 228**, `decisions.md` 6106, D-168's Spec field, cites §11.3. Wrong
before the rewrite. Neither old nor new §11.3 says anything about root-input
fan-out tolerance or the meet.

- Old: `**Spec.** [§6.1][s6-1], [§11.3][s11-3], [§8.2][s8-2], [§14.10][s14-10]`
- New: `**Spec.** [§6.1][s6-1], [§8.2][s8-2], [§14.10][s14-10]`

**Row 279**, `implementation.md` 311, control.jl's Spec line, cites §11.3.
Wrong before the rewrite. The entry lists the control plane, the pacer and
`Control`'s fields, and nothing in it comes from §11.3. The entry itself says
the lifecycle gates are sim.jl's, so the citation looks left over from that
move.

- Old: `Spec: §10.7, §11.3, §12.1–§12.4, §12.6, D-021, D-027, D-203, D-255,`
- New: `Spec: §10.7, §12.1–§12.4, §12.6, D-021, D-027, D-203, D-255,`

**Row 308**, `companions/flight_case_studies.md` 359, cites §11.3. Wrong
before the rewrite. The case study puts the greedy claim at run start.
§11.3 computes it at the attach point and never recomputes it (lines
484–503), as old §11.3 did. Liveness is set at run start, and that belongs
to §11.7 (derived liveness).

- Old: `- `attach!` of the GUI under the greedy binding, then`
  `` `run!(sim; pace = 1, t_end = 1000)`, makes a ``
  `greedy claim over every unclaimed face and settles`
  `liveness with zero configuration, both at run start against the`
  `frozen roster ([§11.3][s11-3]). Axis`
- New: `- `attach!` of the GUI under the greedy binding makes a greedy claim`
  `over every unclaimed face at the attach point ([§11.3][s11-3]). Then`
  `` `run!(sim; pace = 1, t_end = 1000)` settles liveness with zero ``
  `configuration at run start, against the frozen roster ([§11.7][s11-7]). Axis`

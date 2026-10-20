# Inbound check, half 2 (§14.7 to §14.10)

The rows are the 297 rows of `inbound.tsv` whose target is §14.7, §14.8, §14.9
or §14.10. All four sections have entries in `inbound_scope.md`, so every row
was judged against the listed claims. The four section numbers and titles are
unchanged in `chapter_new.md` (lines 726, 940, 1310, 1451). No entry citation
left any of the four sections. The one exception is D-167 in §14.10, which
F59 replaced with D-295, D-296 and D-297. The companions, `extensions.md`,
`implementation.md` and `pending.md` show no change since `c3d29fb`.

## Counts

| verdict | rows |
|---|---|
| OK | 287 |
| RETARGET | 4 |
| COMPANION | 1 |
| MISSING | 5 |
| VAGUE | 0 |

| file | OK | RETARGET | COMPANION | MISSING | total |
|---|---|---|---|---|---|
| `decisions.md` | 161 | 0 | 0 | 1 | 162 |
| `extensions.md` | 8 | 0 | 0 | 0 | 8 |
| `implementation.md` | 18 | 0 | 0 | 0 | 18 |
| `pending.md` | 1 | 0 | 0 | 0 | 1 |
| `spec.md` | 57 | 2 | 0 | 4 | 63 |
| `companions/examples_inventory.md` | 1 | 0 | 0 | 0 | 1 |
| `companions/flight_case_studies.md` | 4 | 0 | 0 | 0 | 4 |
| `companions/frozen_discrete_walkthrough.md` | 2 | 0 | 0 | 0 | 2 |
| `companions/handle_walk_walkthrough.md` | 2 | 0 | 0 | 0 | 2 |
| `companions/linear_blocks.md` | 1 | 0 | 0 | 0 | 1 |
| `companions/linearization_walkthrough.md` | 4 | 0 | 0 | 0 | 4 |
| `companions/longitudinal_aircraft.md` | 6 | 0 | 0 | 0 | 6 |
| `companions/lqr_tracker.md` | 2 | 1 | 0 | 0 | 3 |
| `companions/migration_outline.md` | 0 | 0 | 1 | 0 | 1 |
| `companions/pid_anti_windup.md` | 0 | 1 | 0 | 0 | 1 |
| `companions/sample_time_proposal.md` | 1 | 0 | 0 | 0 | 1 |
| `companions/trim_environment_walkthrough.md` | 19 | 0 | 0 | 0 | 19 |
| all | 287 | 4 | 1 | 5 | 297 |

The rewrite caused only one non-OK row: the COMPANION row from R15. Every
MISSING and RETARGET row was already wrong before the rewrite. No row relies on
a sentence that R6 or R37 cut to a pointer and that left no statement behind.
The frozen-exact rows (spec 9 and the log and walkthrough rows on M64 and M65)
hold. §14.10 keeps the freeze door sentence and the exact-answer sentence,
and both now point to §8.2 or §7.2.

## Rows that are not OK

Line numbers are those of the frozen `spec.md` and `decisions.md` and of the
working-tree companions.

### MISSING

**spec.md 10141 (§13.2), §14.8.** Wrong before the rewrite (part D, F79).
Neither old nor new §14.8 calls the `TrimCommit…` kinds report fields.
`src/trim.jl` 620–644 logs them with `@warn`, and the report holds
`fired_events`, `committed_residuals` and `committed_checks`. This is the
brief's landing edit. The paragraph's opening, "so its warnings live on it",
needs the same check.

- old: `` `trim!` returns a `TrimReport`, and `TrimCommitEvents`, `TrimCommitResiduals` and `TrimCommitChecks` are that report's fields ([§14.8][s14-8]). ``
- new: `` `trim!` returns a `TrimReport`, which holds the fired events and both residual sets, and logs `TrimCommitEvents`, `TrimCommitResiduals` and `TrimCommitChecks` beside it ([§14.8][s14-8]). ``

**spec.md 13200 (Appendix B, `trim!(sim, …)`), §14.7.** Wrong before the
rewrite (part D). Old and new §14.7 list nine fields (D-262).

- old: `The problem itself closes at seven fields`
- new: `The problem itself closes at nine fields`

**spec.md 14792 (glossary, `TrimProblem`; the text is at 14791), §14.8.** The old §14.8 stated
`override(baseline, solution)` at G C-003, and R9 (F61) corrected it to
`override(baseline, condition(d*))`. The glossary keeps the loose spelling.
Appendix B 13201 has the same spelling. Part D lists it, but it is no row here
because it cites §12.6.

- old: ``committed as an `init!` of `override(baseline, solution)` ``
- new: ``committed as an `init!` of `override(baseline, condition(solution))` ``

**spec.md 14904 (glossary, `recorded, not built`), §14.10.** Wrong before the
rewrite. Old and new §14.10 both say that both halves of non-participation have
a spelling (D-263, D-286). Only the tooling over them stays recorded ("What
stays recorded is only the remaining tooling over that visibility").

- old: ``the sampled-data `Dual` activation and declarative non-participation, [§14.10][s14-10]``
- new: ``the sampled-data `Dual` activation and the tooling over declared non-participation, [§14.10][s14-10]``

**decisions.md 7164 (D-185 Rationale), §14.8.** Wrong before the rewrite. The
old §14.8 already said "There is no offset caveat to carry" (D-205), and the
new one says the same. D-185's own annotation of 2026-10-02 records D-205's
amendment. No edit is needed.

### RETARGET

**spec.md 13212 (Appendix B), §14.7.** Wrong before the rewrite (part D).
§14.7 states no throw policy, old or new. "Non-convergence never throws" is
§14.8's, in "The report", which is already cited beside it.

- old: `Non-convergence reports, never throws ([§14.7][s14-7], [§14.8][s14-8]).`
- new: `Non-convergence reports, never throws ([§14.8][s14-8]).`

**spec.md 13723 (Appendix C, `ArgumentInvalid`), §14.7.** Wrong before the
rewrite (part D, F71). §14.7 raises no `ArgumentInvalid`, old or new. The
`:non_nominal` and `:claimed` reasons are in §14.8's "The backend seam", and
`t0` without `about` is in §14.10's "The operating point".

- old: `[§12.6][s12-6], [§12.7][s12-7], [§13.5][s13-5], [§14.7][s14-7]).`
- new: `[§12.6][s12-6], [§12.7][s12-7], [§13.5][s13-5], [§14.8][s14-8], [§14.10][s14-10]).`

**companions/lqr_tracker.md 184, §14.10.** Wrong before the rewrite. Neither
old nor new §14.10 says to route a port through `Freeze`. Both only point to
"the `Freeze` block ([§13.7])". §13.7 states the block (spec 11065–11074), and
the file defines `s13-7`.

- old: ``frozen at its nominal value routes the port through `Freeze` ([§14.10][s14-10]).``
- new: ``frozen at its nominal value routes the port through `Freeze` ([§13.7][s13-7]).``

**companions/pid_anti_windup.md 493, §14.10.** The same case as the row above.

- old: ``nominal value routes the port through `Freeze` ([§14.10][s14-10]).``
- new: ``nominal value routes the port through `Freeze` ([§13.7][s13-7]).``

### COMPANION

**companions/migration_outline.md 28 (the C172 AD audit row), §14.8.** R15
moves the gear finding out of §14.8 and into this companion, as the paragraph
`units/G/companion_addition.md` writes below the table. §14.8 keeps only the
Interpolations and saturation guidance, as part D's M59 row foresaw. The row's
§14.8 citation then covers its first two items. Landing the paragraph is the
edit, and the cell can point to it.

- old: `saturation rank-deficiency (LM-tolerated, reported), the gear identically zero airborne |`
- new: `saturation rank-deficiency (LM-tolerated, reported), the gear identically zero airborne (Flight.jl's model alone, below) |`

## Survey 2's part D, confirmed

Each of part D's "already wrong" rows was checked against `chapter_new.md`.

- Rows of this check: spec 13199–13200 (seven fields), 13212, 13723, 10139–10141,
  and 14792 (the same spelling as 13201) are flagged above. Spec 5113–5114
  (the fallback "runs", F51) and 5122–5123 (`§7.1`'s deletion, F64) sit beside
  sound §14.7 and §14.10 citations, which are OK. The wrong sentences are
  §9.6's landing edits that the brief already lists. The new §14.7 and §14.8
  write the fallback as design (R10). The new §14.10 says "no hand-written
  state-space mapping remains".
- Appendix C 13661–13665 (`TapResolution`) and glossary 14782–14786 (`taps`):
  the citations are OK, since §14.10 now names the kind (R14). Both lists are
  still incomplete. Neither states the seeded tap's limits (at most one index
  step, no `.name` step, a `Float64` leaf), which the new §14.10 states. They
  are on the brief's carried list (F53).
- Log 4182 (D-126, "`capture`-defaulted"), 4310 (D-130, amended by D-414),
  6437 (D-167, the only statement of the participation trait's ruling),
  16198 (D-406, holds) and 4968 (D-139, history) all hold as part D says. They
  belong to track 2.
- These log lines carry no §14.7–§14.10 citation of their own, but they are
  stale against the new text: 2235 (D-069, `deriv`/`output` selectors against
  the five `get_` selectors), 2276 (D-070, `BuildError` against the
  `DiagnosticError` carrying `TrimProblemInvalid`), 2311–2312 (D-071, "named by
  the build" against resolution refusing by name), 2350, 11780, 5896 and
  3555–3560 (`capture` against `checkpoint`), and 3903 (D-118, seven against
  nine). Their Spec-field rows are OK, since each section still states the
  ruling. The staleness is track 2's.
- Spec 13059 holds.

## Other notes

- `linearization_walkthrough.md` 572 is OK for its citation, "pure query".
  The line's "`sim.exec` was never touched" is stale since D-317 and is already
  on the brief's carried list. Its "no restore step" now sits next to §14.10's
  checkpoint "restored into the scratch world". It most likely means Flight.jl's
  restore dance. The carried item could reword both.
- The spec 13737 row's §14.4 citation for `ReadSetMisuse` belongs to half 1
  (R14 makes the kind §14.9's). Its §14.9 citation is OK.

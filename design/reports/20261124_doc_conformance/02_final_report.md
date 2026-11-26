# Final report: the docs conformance audit

The audit checked the spec, the log, the companions, the docstrings and the
user-facing docs against the code, which is the source of truth, in both
directions. It ran from 2026-11-24 to 2026-11-26. The brief is `00_brief.md`,
the trial's record `01_trial_14.md`, and the working record
`notes_doc_conformance.md`, which holds every run, ruling and commit in
order. This report sums them up.

## What ran

Stage M's scripts ran over the whole tree at each pin. The §14 trial came
first, then seven chapter groups in nineteen workflow runs, each a set of
inventory slices, verifiers and coverage slices under ten agents:

| Group | Scope | Runs | Subagent tokens |
|---|---|---|---|
| Trial | §14 | 1 | 2.2M |
| G1 | §13 and Appendix C | 2 | 3.3M |
| G2 | §8 | 2 | 3.2M |
| G3 | §9 | 2 | 3.6M |
| G4 | §10 | 2 | 3.0M |
| G5 | §11 and §12 | 4 | 5.4M |
| G6 | §1 to §7 | 4 | 5.8M |
| G7 | Appendices A, B and D, and the user-facing docs | 3 | 3.9M |
| Log triage | the log findings | 8 agents | 0.8M |

That is about 31M subagent tokens, above the brief's estimate of 20M to
25M. The difference is the split runs: G5 and G6 each took four runs to
stay under ten agents per run.

## What it found

The runs recorded about 610 findings in `ledgers/*/findings.tsv`: 570
flagged by an inventory and confirmed by a verifier, and 36 misses the
verifiers found in the sampled `ok` rows. The verifiers overturned 201
further flags, listed in the `overturned.tsv` files. The overturn rate was
highest in the coverage slices and the companions' prior-art leads, and the
miss rate highest in the spec slices with thin inventories.

The findings went three ways:

- **Clear drift**, fixed without asking by one fixer per group, one commit
  each: `04f92c60` (§14), `14eab094` and `adff8b24` (G1), `d78961ce` (G2),
  `2255b3c6` (G3), `ec4f51b3` (G4), `153f12ef` (G5), `a92cd48b` (G6) and
  `80fa292d` (G7). The superseded-citation batch (`4f92f7eb`) and the
  finite-difference witness for `linearize` (`3adc38a5`) came between the
  trial and G1.
- **Rows for the user**, 81 entries in `ledgers/user_rows.md`: wording rows
  where the fact was settled and the sentence open, figures, code-or-doc
  rows, defects and gaps. Each carries its ruling and its commit. The
  wording rule and the figures rule the user set on 2026-11-25 are in the
  notes. The last six, ruled on 2026-11-26, moved the code in four rows and
  the doc in two; one, S9b-300, became the increment
  `design/increments/20261126_frozen_init/`.
- **Log findings**, 326 rows in `ledgers/log_findings.tsv`, triaged at the
  end (below).

A final small sweep re-checked the 28 items the fixers had seen and left;
four had landed, 22 were fixed as `7ce4fa2b`, one became a test
(`73a70879`) and one, a battery check for merge-conflict markers, the user
dropped.

## The log

The brief's Stage F step 4 expected one superseding entry per topic. The
triage found none needed. Under `log_rules.md` rules 2 and 10, a rename a
later entry records is vocabulary of its day, and an older entry the spec
and a later entry overrule gets an annotation, not a new entry. Of the 326
rows, 238 needed nothing, 83 pointed to an annotation, 4 lay outside the
log and 1 asked for a supersession, which the user ruled an annotation.

48 annotations landed as `86233ecf`, one per entry, listed in
`ledgers/log_annotations.md`. The D-166 citations in the code moved to the
entries that carry each surviving ruling (`f41ed8bb`), and §11.8's
allocation bound was restated with an annotation on D-136 (`e5fbdc03`).
The triage's brief, slices and results are in `ledgers/log_triage/`, the
merged result in `ledgers/log_triage.tsv`.

## Left open

- CV11a-004 (`KindCounts`' fields undescribed) and CV7a-038 (the public
  `TraceBatch` record) wait on the exported-name audit, which
  `design/increments/roadmap_api_audit.md` lists.
- Nothing else. Every finding is fixed, ruled, annotated or recorded as
  needing nothing.

## Lessons

These are proposals for `rules/brief_rules.md`, not yet applied there:

- **Key a ledger row by the text it names, never by a line number alone.**
  The log findings cited `log.md:NNNN` at the time of each run. Annotations
  landed between runs, and by the triage many rows sat one entry early. The
  agents found the right entry by text.
- **A triage with a mechanical check needs no high tier.** Eight mid-tier
  agents triaged the 326 log rows in four minutes for 0.8M tokens. A script
  then confirmed every dated annotation a `none` call cited.
- **Read the log rules before planning log work.** Rules 2 and 10 decide
  most log drift as nothing or an annotation, which the brief's step 4 did
  not anticipate.

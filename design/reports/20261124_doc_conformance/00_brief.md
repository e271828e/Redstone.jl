# Brief: the docs conformance audit

This audit checks the spec, the log, the docstrings, the companions and the
rest of the docs against the code, and fixes what drifted. The code is the
source of truth. The audit runs in both directions. It checks every doc
claim against the code, and it checks the code's surface for doc coverage.
It starts with a trial on §14, and the full run follows the trial's
measurements. Drafted on 2026-11-24 at `19027dd`, before the §10.5
restructure and the timing notation increment land. It is rebased at the
pinned tip `T` before launch. Not normative: if a stage below proves wrong
in practice, stop and report rather than deviate.

## What is settled

The user ruled on 2026-11-24:

- **Four classes.** Every finding is one of these:
  - *Drift.* The code is right and the doc is stale. A clear drift fix lands
    without the user's approval.
  - *Defect.* The doc states the intent and the code misses it. It is
    proposed with a probe, and the user rules on it.
  - *Deviation.* The code differs and nothing records it. When the code
    contradicts the spec or a docstring, they move to the code. When it
    contradicts a ratified log entry, the finding is recorded. At the end of
    the sweep the log findings are clustered so that as few new entries as
    possible are needed.
  - *Gap.* `pending.md` already records it. No action.
- **Both directions.** The coverage direction stops at the author-facing
  surface and its semantics. Internals are owed only to `code_map.md`.
- **The log.** Rule 1 of `rules/log_rules.md` holds, so no entry is
  rewritten. The audit checks three things. Every ratified entry agrees
  with the code. Every citation resolves. Every `superseded →` chain ends at
  a ratified entry. A ratified entry that contradicts the code is answered
  by a new superseding entry.
- **Scope.** The spec and its four appendices, the ratified log entries,
  the docstrings, `docs/src/api.md`, `docs/src/index.md`, the tutorial
  pages, `docs/src/descriptor.json`, the README, `code_map.md`, the `§N`
  and `D-nnn` citations in code comments, and all nineteen companions.
  `docs/src/glossary.md` is generated from Appendix D by
  `docs/glossary.jl`, so it is audited through Appendix D.
- **Docstring edits in `src/`** count as docs. Clear drift in them lands
  without approval.
- **Clear drift** meets four conditions. The verifier confirmed it. The code
  evidence is cited. The code fixes the new text in only one way. The fix
  touches no rule beyond the claim itself. Anything else goes on the user's
  list.
- **Tiers.** Mid-tier agents write the claim inventories and their probes.
  High-tier agents verify independently, with their own probes.
- **The trial** is §14, run as one workflow of about twelve agents.

## Drift and deviation

Both mean the doc says X and the code does Y. It is drift when something
already records the move to Y: a later log entry, a rename sweep, or a
commit whose subject states the change. It is a deviation when nothing
records it. Both move the spec and the docstrings to the code. A deviation
also adds a log finding whenever a ratified entry backs X.

## Preconditions

- The §10.5 restructure has landed, and so has the timing notation
  increment after the user's diff-verify.
- The tip at that point is `T`. Every line number comes from
  `git show T:file`.
- A git worktree at `T` serves the read-only stages. Agents read it and run
  probes there with `julia --project=<worktree>/test`, so commits on master
  don't move under them.
- The brief records the Julia version and the gate's result at `T`.

## The ledger

One row per finding, with an ID. The inventory agent writes these fields:

| field | content |
|---|---|
| `id` | slice prefix and number, e.g. `S14a-037` |
| `at` | `file:line` at `T` |
| `kind` | `law`, `mech`, `decl`, `ptr`, `why`, `ex`, as in `20261124_rates_restructure/claims_a.md` |
| `claim` | one sentence |
| `evidence` | a `src/` or `test/` line, or a probe name |
| `verdict` | `ok`, `finding` or `unverifiable` |
| `class` | drift, defect, deviation or gap |
| `fix` | the proposed new text, or the code change |

The verifier adds a second verdict, confirmed, overturned or reclassified,
with its own evidence.

## The stages

### Stage M: the mechanical layer

Runs once over the whole tree at `T`, before any agent reads anything. The
scripts live in `probes/`. Their output reaches each slice as pre-findings.

1. **Name resolution.** Every code span in the spec, the ratified log
   entries, the companions and the docstrings is resolved against
   `Redstone` and `Redstone.Library`. Math letters and prose are filtered
   out. What does not resolve is a candidate.
2. **Signatures.** `tools/docstring_signatures.jl` and
   `tools/docstring_roster.jl`.
3. **Keywords and fields.** Appendix B's entry points are checked against
   `Base.kwarg_decl`. The fields the docs name are checked against
   `fieldnames`.
4. **Diagnostic kinds.** Appendix C's kind set is compared with every kind
   the code raises, in both directions.
5. **The descriptor.** §13.9's schema keys are compared with what the writer
   emits and with `docs/src/descriptor.json`.
6. **Citations in code.** Every `§N` and `D-nnn` in `src/`, `test/` and
   `examples/` is checked to resolve. Whether it cites the right topic is
   left to the agents.
7. **The docs build.** `docs/make.jl` runs at `T`, which catches broken
   `@ref` links, the doctest and the tutorial's `@example` blocks.

### Stage I: claim inventories

One mid-tier agent per slice. It lists every claim in its range, checks
the checkable ones against the code, and writes probes for behavioural
claims. It edits nothing and commits nothing.

- **Spec slices.** Cut at `###` headings to about 500 to 600 lines.
- **Log slices.** Only ratified entries are read, and only their Position
  and Status lines. Each entry goes to the chapter its first `**Spec.**`
  citation names. The agent checks the `superseded →` chains. A rejected
  alternative is only flagged if the code visibly does the rejected thing.
- **Companion slices.** Each companion goes with the chapter it explains,
  cut to about 600 lines. A companion that disagrees with the code but
  agrees with the spec is a spec finding.
- **Spec code blocks.** A complete Julia block is run.

Three practical rules apply:

- **Batched probes.** A slice's probes go into one script, run in one Julia
  session. At most four agents run Julia at once.
- **The 30k-character cap.** `ok` rows are reported in compact form,
  `id line ok evidence`. Findings and `unverifiable` rows are written out in
  full. Claims of kind `ptr`, `why` and `ex` are counted, not listed. The
  coordinator writes the agents' reports to the ledger.
- **Prompt boilerplate.** Use `/bin/ls` or `fd`, never `ls`. Read-only. No
  commits, no trailers.

### Stage V: verification

One high-tier verifier per slice's findings. It sees the claim, the doc
text and the code, but not the inventory agent's argument. It writes its
own probe for a behavioural claim. It also re-checks a random 10% of the
slice's `ok` rows, drawn from kinds `law` and `mech`, to estimate the miss
rate. Verification starts as soon as each inventory finishes.

### Stage C: coverage

Sliced by source file group, following `code_map.md`. One mid-tier agent
per group, verified as in Stage V. It answers four questions:

1. Is every author-facing name, keyword, field, diagnostic raise and
   behaviour in its files covered by the spec, a docstring or an appendix?
2. Does every docstring in its files match the code?
3. Do the `code_map.md` entries for its files match?
4. Does every `§N` and `D-nnn` comment in its files cite the right topic?

A behaviour the docs omit is usually a deviation.

### Stage F: fixes

Fixes go chapter by chapter as each chapter's verification ends.

1. **Clear drift.** A high-tier fixer applies a chapter's verified rows
   under `rules/spec_rules.md`, `rules/docstring_rules.md` or
   `rules/log_rules.md`, whichever governs the file. In the log, rule 1 only
   allows citations and annotations. The coordinator reviews the diff, runs
   the battery, and commits with explicit paths, one commit per chapter.
   After docstring edits the coordinator also runs the docstring tools and
   the docs build. Later chapters find their claims by text, not by line.
2. **Deviations in the spec or docstrings** move to the code in the same
   commit. The log finding behind each is kept for step 4.
3. **Defects** go to the user one at a time, with the probe. Once ruled,
   each lands as a loose commit or as an increment. None of this blocks the
   doc fixes.
4. **Log clustering** comes at the end of the whole sweep. The log findings
   are grouped by topic, and one entry is drafted per group. It supersedes
   every ratified entry the group contradicts. The groups and drafts go to
   the user, and the entries land after approval.

## The trial: §14

§14 lies outside the §10.5 restructure's nine passages. It runs to 1,810
lines, 120 ratified log entries cite it, and it has two large companions:
`companions/trim_environment_walkthrough.md` and
`companions/linearization_walkthrough.md`. Its docstrings are on exported
entry points, and its diagnostics have rows in Appendices B and C.

The trial runs Stage M over the whole tree, then eight mid-tier agents and
two to four high-tier verifiers in one workflow, then Stage F for §14:

- three spec slices,
- two log slices,
- two companion slices,
- one coverage slice for §14's source files.

It measures six things:

1. Claims per line.
2. The finding rate.
3. The verifiers' overturn rate, meaning false positives.
4. The miss rate in the `ok` sample, meaning false negatives.
5. Tokens and wall time per agent.
6. The share of fixes that count as clear.

The measurements go to the user with the §14 fixes, together with any
change proposed for the full run. If the miss rate exceeds about 5%, the
inventories move to high-tier or to narrower slices.

## The full run

One workflow per chapter group, each under ten agents, in this order:

1. §13 with Appendix C.
2. §8.
3. §9.
4. §10.
5. §11 and §12.
6. §1 to §7.
7. Appendices A, B and D, with the remaining companions.

Each group takes its log entries, its companions and the coverage pass over
its source files. The tutorial pages and the README go with the chapter of
the source files they use. The rough total is 30 spec slices, 10 log
slices, 10 companion slices, 8 coverage slices and 15 to 20 verifiers. That
is about 75 agents over seven or eight runs. The trial revises this figure.

## Bookkeeping

- This folder holds the brief, the ledger by slice in `ledgers/`, the
  probes in `probes/`, the trial's measurements and the final report.
- A `pending.md` bullet names the stage reached. It sits before the
  tutorial bullet and is added once the restructure lands.
- `code_map.md` fixes land with each chapter.

## Out of scope

- The friction review and the exported-name audit, recorded on the API
  audit bullet of `pending.md`. Their renames are swept when they land.
- Reports and increment records, which stay frozen until the first release.
- The inspector repo's own documents.

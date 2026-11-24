# The §14 trial

The trial ran the brief's pipeline on §14 at the pinned tip `bd471af7`, as
workflow `wf_2286b5e8-bf9`. Seven mid-tier inventories each fed one blind
high-tier verifier: 14 agents, no failures, 2.2M subagent tokens and 24
minutes of wall time. A high-tier fixer then applied the verified rows in the
audit worktree, at 126k tokens. The fixes landed on master as `04f92c60`, and
the battery passes on it. The rows are in `ledgers/trial_14/`, and the
probes in `probes/`.

## Measurements

| slice | doc lines | claims counted | claims listed | claims per line | flagged | ok | sampled | confirmed | overturned | missed |
|---|---|---|---|---|---|---|---|---|---|---|
| S14a §14.1–14.5 | 646 | 112 | 85 | 0.17 | 4 | 81 | 9 | 3 | 1 | 0 |
| S14b §14.6–14.8 | 648 | 108 | 55 | 0.17 | 3 | 52 | 7 | 3 | 0 | 0 |
| S14c §14.9–14.10, B, C | 723 | 281 | 223 | 0.39 | 2 | 221 | 24 | 0 | 2 | 0 |
| K14a trim companion | 913 | 116 | 22 | 0.13 | 5 | 17 | 4 | 4 | 1 | 0 |
| K14b linearization companion | 681 | 76 | 55 | 0.11 | 6 | 49 | 6 | 5 | 1 | 0 |
| L14, 37 log entries | – | 154 | 138 | – | 14 | 124 | 13 | 12 | 2 | 3 |
| C14 coverage | – | 371 | 74 | – | 11 | 63 | 8 | 7 | 4 | 0 |
| total | | | | | 45 | 607 | 71 | 34 | 11 | 3 |

- **Findings.** There are 37 in all: 34 confirmed flags and 3 misses the
  sample caught. 29 are drift and 8 are deviations. None is a confirmed
  defect or gap. 31 of them are clear.
- **False positives.** Verifiers overturned 11 of 45 flags, about 24%. Most
  were Stage M leads that turned out to be prior art or placeholders.
- **Misses.** Verifiers found 3 misses in 71 sampled `ok` rows, about 4%,
  below the brief's 5% line. All three are in the log slice, which missed 3
  of its 13 sampled rows. The spec, companion and coverage slices missed
  none of 58.
- **Cost per agent.** An inventory ended at 120k to 300k context and wrote
  44k to 160k output tokens. A verifier ended at 100k to 160k context.

## What the trial changes for the full run

1. **The inventories are too coarse.** The spec and companion slices counted
   0.11 to 0.39 claims per line. The rates restructure's claim inventories
   counted about 0.57 on §10.5. A coarse claim marked `ok` can hide a false
   sub-claim, and the `ok` sample cannot see it. The full run's prompt should
   give a worked example of splitting a paragraph into claims and state the
   expected density. The script should re-run an inventory once, with a
   nudge, when its normative prose falls below about 0.3 claims per line.
2. **The log slices need a stronger inventory.** A miss rate of 3 in 13 is
   too high. The log's inventories should move to high-tier, or to slices of
   about 20 entries.
3. **The cost scales.** The spec is about ten times §14 by lines. At the
   trial's rate the full run costs 20M to 25M subagent tokens, and finer
   claims add to that.
4. **One mechanical batch can go ahead of the chapters.** Stage M lists 33
   code comments that cite a superseded log entry, and 4 more D-167 sites
   remain after this trial. One fixer pass can re-point them all, and the
   chapters then skip them.
5. **The fixing route works.** A fixer in the pinned worktree, reviewed and
   then cherry-picked onto master, kept the line numbers exact and met no
   peer edits.

## Rulings

On 2026-11-24 the user accepted the five changes above and the
recommendations below. K14b-006 is ruled a defect: the test is written. The
two new spec sentences stay unmarked. The log's inventories move to
high-tier, in slices of about 30 entries.

## Left for the user

- **K14b-006.** The linearization companion says the tests check
  `linearize` against finite differences. No test does. Either the
  companion drops the claim, or the test is written, which makes it a
  defect.
- **Two new spec rules carry no entry.** One is §14.10's refusal of a
  `width` below 1. The other is §14.8's start from the guess projected into
  the box. Both state what the code does, and no alternative was rejected.
- **Log findings.** Nineteen are recorded in `ledgers/trial_14/log_findings.tsv`
  for the clustering at the end of the sweep. They include D-151's
  type-level reorder of the bounds, which the code does by name, and
  D-223's interrupt that "propagates raw", which D-441 now wraps.

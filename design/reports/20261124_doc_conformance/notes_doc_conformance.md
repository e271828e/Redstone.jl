# Notes: the docs conformance audit

The working record of the audit, for whoever coordinates it next. The brief
is `00_brief.md`, the trial's record is `01_trial_14.md`, and both stand.
This file holds the state, the rulings since the trial, the group plan and
the tools.

## State

- **Landed on master.** The brief, Stage M's scripts, the docs build fix
  (`fcd36606`), the §14 fixes (`04f92c60`) and the trial's record
  (`c08a5d12`).
- **The two batches after the trial** land with this note: the
  superseded-citation batch and the finite-difference witness for
  `linearize` (K14b-006). Their commits are named in the section "Commits
  since the trial" below.
- **G1a, §13.** It ran at `89a10a14` as `wf_6a6c171f-c59`: 10 agents,
  1.65M subagent tokens, 26 min. The spec slices counted 0.47 to 0.56
  claims per line, so none re-ran. The verifiers overturned 3 of 39 flags
  and found 5 misses in 104 sampled `ok` rows, all five in the spec
  slices. The 7 clear rows landed as `14eab094`, all in §13. The ledgers
  and `fix_list.md` are in `ledgers/G1a/`.
- **G1a's rows for the user.** Three wording rows: S13b-205 (the order
  of the stop sources), S13c-213 (once per member) and S13c-219 (no
  layouts). Three defects: S13a-040 with L13-017 (tests that assert
  message text), S13c-031 (`unblock!` outside the join timeout) and
  S13d-133 (`BundleFieldError` writes no `function`).
- **G1b, Appendix C and §13's code.** It ran at `02745494` as
  `wf_c713d808-c43`: 8 agents, 1.68M subagent tokens, 18 min. The
  verifiers overturned 14 of 42 flags, 13 of them from the two coverage
  slices, and found 1 miss in 77 sampled rows. 18 rows landed as `adff8b24`.
- **The rows for the user** now live in `ledgers/user_rows.md`, by group.
- **G2, §8.** It ran at `72b12836` as G2a (`wf_55d6ef8f-1d6`, 10 agents,
  1.58M tokens, 17 min) and G2b (`wf_4c8557c1-4ee`, 9 agents, 1.58M
  tokens, 23 min). The verifiers overturned 28 of 96 flags, 12 of them the
  companion's prior-art leads, and found 2 misses in 122 sampled rows, both
  in a log slice. One fixer took both runs' 20 clear rows, which landed as
  `d78961ce`.
- **Seen by G2's fixer, not yet fixed.** Appendix C's `StoreWithoutUpdate`
  entry and its docstring (src/diagnostics.jl, near 542) keep S8c-036's
  imprecision. §8.2, near line 2962, cites §8.5 for the rule that a
  `Pinned` entry says nothing, which CV8-132 moved to §8.2 in the code.
  Appendix C cites D-211 for `:sample_times_sugar` where §8.5 cites D-215.
- **A tracked file was deleted in W during G2's runs:**
  `design/reports/20261001_chapter9_rewrite/chapter_old.md`. It was
  restored before the fixer's commit. Check `git -C W status` after each
  run, before the fixer starts.
- **G3, §9.** It ran at `d7d3ddff` as G3a (`wf_8a739be8-68d`, 10 agents,
  1.77M tokens, 21 min) and G3b (`wf_36938c52-f6d`, 10 agents, 1.81M
  tokens, 22 min). The verifiers overturned 16 of 83 flags and found 4
  misses in 170 sampled rows, 3 of them in S9d's 9, whose inventory is
  thin. 17 clear rows landed as `2255b3c6`.
- **Seen by G3's fixer, not yet fixed.** The glossary's `g-probe-value`
  list omits `StaticArray`. The §9.4 bullet on what sees a `Dual` sits
  under D-052's bold and does not cite D-111, which brings `x_projection`
  in. The snapshot `port` docstring (src/dataplane.jl, near 550) never
  names the no-name `ArgumentError`.
- **G4a, §10.** It ran at `2ea85438` as `wf_8bed24b4-c04`: 10 agents,
  1.57M tokens, 18 min. The verifiers overturned 4 of 24 flags and found 5
  misses in 107 sampled rows. Its 4 clear rows wait in
  `ledgers/G4a/fix_list.md` for one fixer with G4b.
- **G4b, §10's companions and code.** It ran at `2ea85438` as
  `wf_608a017e-1ae`: 8 agents, 1.39M tokens, 21 min, S9d2 included. The
  verifiers overturned 6 of 21 flags and found 1 miss in 81 sampled rows;
  S9d2 missed none of its 10. One fixer took G4a's and G4b's 14 clear rows,
  which landed as `ec4f51b3`.
- **Seen by G4's fixer, not yet fixed.** src/frame.jl's header still says
  the method takes the span in the fewest equal steps `h_max` allows, false
  under a proposing method. pid_anti_windup.md, near line 445, still writes
  `LimitedIntegrator{V, L}`. limited_integrator_variants.md, near line 117,
  gives the strict gate 21 trials where the probe counts 21 or 22.
- **G5, §11 and §12, in four runs at the pin `f14dbc1d`.** Their args and
  leads are cut, in `ledgers/G5a/` to `ledgers/G5d/`, by
  `probes/coord/g5.py`. G5a (§11's spec slices and the inbound
  walkthrough) ran as `wf_8c6a2747-902`: 10 agents, 1.43M tokens, 15 min,
  8 of 29 flags overturned, 2 misses in 73 sampled rows. Its 12 clear rows
  wait in `ledgers/G5a/fix_list.md`.
- **G5b to G5d.** G5b (§12 and the flight case studies) ran as
  `wf_e7f7f280-2aa`: 10 agents, 1.41M tokens, 22 min. G5c (the 106 log
  entries) ran as `wf_e22acc52-fcd`: 8 agents, 1.55M tokens, 39 min, 36 of
  90 flags overturned, 21 of them in L11b. G5d (coverage) ran as
  `wf_1391f201-19c`: 6 agents, 1.05M tokens, 21 min. One fixer took the
  37 clear rows of G5a, G5b and G5d, which landed as `153f12ef`.
- **Seen by G5's fixer, not yet fixed.** The `# Design:` comment above
  `WriterStatus` (src/dataplane.jl, near 213) still names a returned inline
  body, gone since D-310. inbound_periphery_walkthrough.md, near line 174,
  still says "device-tagged drained batches". src/model.jl's `port`,
  `state` and `modes` cite §7.3 where Appendix B treats them. §11.5's frame
  gloss and §11.1's drain gloss are looser than S11a-005 and S11c-001.
- **G6, §1 to §7, in four runs at `cb398676`.** G6a (`wf_b7024282-284`,
  1.42M tokens), G6b (`wf_00c39d21-47c`, 1.33M), G6c (`wf_e46d127c-5eb`,
  1.81M) and G6d (`wf_564bfed9-e06`, 1.19M), 38 agents in all. One fixer
  took the 33 clear rows, which landed as `a92cd48b`. Many of the user's
  rows from G6b are figures the verifiers re-measured in the companions.
- **Seen by G6's fixer, not yet fixed.** §2's roadmap and §8.1 still say
  every primitive has two output stages. library_inventory.md, near line
  140, cites §7.1 where §8.2 holds the claim. pid_anti_windup.md section 9
  says "same ports", false since `DiscretePID` publishes `saturated`.
- **G7, the appendices and the user-facing docs, in three runs at
  `62551b06`.** G7a (`wf_715ab5ce-39a`, 2.01M tokens), G7b
  (`wf_d279e89e-662`, 1.33M) and G7c (`wf_f11a3cc5-bc2`, 0.57M), 24 agents.
  README.md, docs/src/index.md and the tutorial pages came out clean: all 5
  flags were overturned. One fixer took the 36 clear rows, which landed as
  `80fa292d`.
- **Seen by G7's fixer, not yet fixed.** §12.3 still writes the wait
  predicate as `counter > last_seen && running`; the code has `||
  !running`. §11.5 says the fingerprint holds each component's `x` type,
  not `x`, `s` and `m`. store_at_rest_walkthrough.md still passes `t₀`
  positionally near line 314 and names the gone `_settle!` flag near lines
  330 and 381. The `closed_loop` docstring in examples/src/longitudinal.jl
  repeats K7a-298's "within a tick".
- **The sweep is done.** Every group from G1a to G7c has run and its clear
  fixes have landed. Three things remain: the user's rulings on
  `ledgers/user_rows.md`; a small sweep of the "seen, not yet fixed" items
  above; and the clustering of `ledgers/log_findings.tsv` into superseding
  entries for the user's approval, as the brief's Stage F step 4 says.
- **The wording rows, ruled on 2026-11-25.** The user's rule for a row whose
  fact is settled and whose sentence is open: delete the false words if the
  passage still makes its point; else qualify or replace with the fewest
  words; else rewrite. 53 rows are settled under it, `a991af00`, one of them
  already fixed, and 6 of the 10 rows where doc or code could move took the
  doc's fix, `cdf92a7f`. `ledgers/user_rows.md` marks each. S8c-047
  took the code's fix, `7a300b9d`, S9b-112 the doc's, `21c08c17`, and CV2-041
  changes nothing. CV10-263 took the code's, `06a2e8fa`. Left of that
  class: C2-073, CV9a-049, K9b-041 and CV11a-004, each tied
  to another open row or to the API audit. The figures S9d-057, K8-027 and
  K8-046 are settled, `479ceea1`, under the user's rule for figures: keep one only
  if an argument depends on it, rounded and with the Julia version, and
  delete an estimate nobody can derive. The companions' measured figures
  followed, `df6f03f8`.
- **Seen while the wording rows landed, not yet fixed.** §13.2's rule is
  still named "strings, never instances", over a sentence that no longer says
  strings, and §13.4 says names are strings. §11.6's task sketch shows a bare
  `shutdown!(dev)` where the wrapper calls `_shutdown!`. Appendix C's
  `OutOfClaimEntry` payload says "the writer's claim set", which for the
  harness is the unclaimed complement. pid_anti_windup.md says the port sets
  are identical in both PIDs, though `DiscretePID` adds its saturation code.
  event_visibility_walkthrough.md's section 2 still says `u` gathers foreign
  cells alone, which a self-wire breaks (K6a-013).
- **The defect and citation rows, taken on 2026-11-25.** The clear ones landed,
  the doc rows as `608662ac` and the code rows as `d6636cb0` to `8b8ab49f`, one
  commit each. `ledgers/user_rows.md` marks each.
- **The six rows, ruled on 2026-11-26.** The user accepted the session's
  recommendation on each, and `ledgers/user_rows.md` holds each ruling with
  its reason. Four move the code and two the doc. What the discussion found
  beyond the rows:
  - S9b-300 reproduces on master. Only `init!` has the hole. `restore!`
    copies a same-scalar state's whole table, and `overlay!` runs an off-tick
    boundary, which moves no discrete cell at `Float64` either.
  - S10d-054. `sleep` overshoots by about 1.4 ms at a 2 ms request and by
    about 2.1 ms from 10 ms up, so the calibration measured the wrong request.
    The figures the spec takes come from a quiet machine,
    `probes/user_rows/s10d054_quiet.out`.
  - S12b-236 is reproduced. `_residue!` prints through `@warn` inside the
    mask, so a logger that raises `InterruptException` stands in for the
    forced throw. The mask's depth does not leak, since a `catch` restores it.
  - CV2-023. The refusal's one effect beyond the sets is that it sends the
    member to the sampled mode, which redraws the state. The probe's two
    closed gates show the verdict that moves.
  - Two readings were not probed and are checked before their text lands:
    that an interrupt releases a hanging `unblock!`, and what D-441's
    Position says of a forced throw in the bookkeeping.
- **How the six rows are applied**, in five steps, each committed and none
  pushed: this record; the doc rows as one commit (S13c-031, S6c-001,
  K9b-041, and the log rows for D-237 and D-051); CV2-023, S6c-004 and
  S12b-236 as one code commit each, the last with a cold review; S10d-054,
  docs first; and S9b-300 as a small increment,
  `design/increments/20261126_frozen_init/`. The routed runners run per
  commit and the gate at the tip of the code commits and again for the
  increment.

- **The six rows are applied, 2026-11-26.** Thirteen commits on master,
  `51830b28` to `8e66ad01`, none pushed, and `ledgers/user_rows.md` names
  each row's. The gate passed on the tree of steps 3 and 4, 10949 of 10949,
  and on step 5's, 10991 of 10991, and the examples' runner on both. Two
  cold reviews ran, one on S12b-236 and one on the increment, and their
  probes are in `probes/user_rows/s12b236_review/` and the increment's
  `review/` folder.
  - Two things wait on the user's confirmation, each a shape other than the
    one ruled. S12b-236 presents the residue after the record and the flag,
    inside the mask, not after it. S9b-300's nominal half projects, where
    the ruling said no projection
    (`design/increments/20261126_frozen_init/notes_frozen_init.md`,
    section 3).
  - For the log clustering. D-480 changes the default `margin`, so the
    annotations the ledger proposes in rows L10-072 and L12-048 say 2 ms
    where the default is now 3 ms. The rows S6c-001 and S6c-004 against
    D-237 and CV9a-049 against D-051 stand as they are: D-237's Position
    says "anywhere" where the spec now says "the walk meets", and D-051's
    says "never initial slot values" where §9.3 now says a fresh table holds
    them until `init!` or a restore writes it.
  - Seen and not fixed. No tool of the battery catches a merge-conflict
    marker; one reached a commit on a branch tonight and the cold review
    found it. No test covers the warning that counts a residue's suppressed
    occurrences. `trim!` and `linearize` run their nominal round outside any
    `try`.
  - The scratch stays until the push, as `increment_rules.md` says: the
    worktrees `six_rows`, `s12b_review`, `frozen_init`, `frozen_init_land`
    and `frozen_init_review` under `../Redstone.jl-worktrees/`, their notes
    folders beside them, and the branches `six-rows` and `frozen-init`.

  The small sweep and the log clustering follow.
- **The schedule the user set on 2026-11-24.** Pause after G5 until the
  usage window resets at 01:51 CET on 2026-11-25; launch G6 then, as four
  runs (`probes/coord/g6.py` writes them at the new pin); launch G7 five
  hours after G6's launch, near 06:53. Pause whenever the user asks. The
  session that coordinates owns the timers; a session taking over sets its
  own and the old one cancels its own, keep-warm loop included.
- **The coordinator's helpers** are in `probes/coord/`. `coordlib.py`
  holds the paths and the code_map and heading lookups. `g5.py` writes a
  group's args, slices and leads. `tri2.py` merges a run and prints one
  line per finding. `fixlist.py` writes a fix list, and `logrows.py`
  appends a run's log rows to the log ledger. `fixer_brief.txt` is the
  fixer's brief as a template. Each run's args JSON is passed inline to the
  Workflow tool; the task text comes from `taskOf` in `audit_run.js`.

## Rulings since the trial

The user accepted all of these on 2026-11-24:

- Inventories get a worked example of claim splitting, and a spec or
  companion inventory below its density floor re-runs once with a nudge.
  The floors are 0.3 claims per line for spec slices and 0.2 for
  companions. `probes/audit_run.js` does both.
- The log's inventories run at high-tier, in slices of about 30 entries.
- The full run's cost, about 20M to 25M subagent tokens, is accepted.
- Superseded citations in code went first, as one batch. 15 sites were
  re-pointed. 16 sites still cite D-166 on purpose, because D-263 does not
  carry the rulings they cite. That mismatch is log finding CIT-D166.
- K14b-006 is a defect, and the test is written.
- The two spec sentences the §14 fixes added stay unmarked: the `width`
  refusal in §14.10 and the start from the projected guess in §14.8.
- Each run stays under ten agents, at most five at once, to bound the
  concurrent Julia processes on a 10-core, 16 GB machine.

The standing policy is the brief's. Clear drift is fixed without asking.
Spec and docstring deviations move to the code. A contradicted ratified
log entry becomes a row of the log findings. Defects go to the user with a
probe.

## Commits since the trial

- `4f92f7eb`: the superseded-citation batch. 15 sites in `src/` and `test/`
  re-point, and so do two Spec lines in code_map.md plus structure.jl's,
  which still listed D-464. One string changed: the `:unseedable`
  citation list in src/diagnostics.jl.
- `3adc38a5`: the finite-difference witness. A testset in
  test/test_linearize.jl checks every column of A, B, C and D against central
  differences through `about`, and the walkthrough's section 9 describes it.
  Both mutants tried (a flipped readback sign, swapped seed slots) turn it
  red. Its fixture moves only A[2,1] with the point, because B, C and D are
  constant there. The walkthrough's next paragraph, out of the fixer's
  passage, was checked on 2026-11-25. No test pinned its claim that a second
  `linearize` compiles nothing new, and the sentence now says what the tests
  pin, that a width already materialized adds no activation.
- The full gate passed on `3adc38a5`, 10905 of 10905, in 10 min.

The worktree `doc_conformance` is on branch `audit-citations`. The
branches `audit-14-fixes`, `audit-citations` and `audit-fd-witness` were
cherry-picked onto master and can be deleted.

## How a group runs

1. **Pin.** Detach the worktree `/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance`
   at master's tip: `git -C <W> switch --detach master`. Copy the root
   `Manifest.toml` into it if it is missing, since manifests are untracked.
   Call the tip T.
2. **Stage M.** Run it at T, from W:
   `sh /Users/miguel/.julia/dev/Redstone.jl/design/reports/20261124_doc_conformance/probes/stage_m/run.sh`.
   It writes `ledgers/stage_m/` in the main checkout. Re-run it only when the
   tip moves.
3. **Slices.** Cut them at `###` headings from T's heading outline
   (`rg -n '^#' design/spec.md`), at about 450 lines each. Write a
   `slices.json` for `probes/split_leads.py` and run it to
   `ledgers/stage_m/leads_<group>/`.
4. **Launch.** Run `probes/audit_run.js` through the Workflow tool, by
   `scriptPath`, with args `{group, W, tip, R, slices}`. Here
   R = `/Users/miguel/.julia/dev/Redstone.jl/design/reports/20261124_doc_conformance`.
   Each slice is `{key, kind, agent, lines, task}`, or gives template fields in place of task, which the script expands: see `taskOf` in `audit_run.js`. task routes the
   reading the way the trial's slice tasks did (`probes/trial_14_run.js`,
   its `SLICES`): the doc line ranges, the code_map.md entries with their
   line ranges, and the code to read. A coverage slice's task carries the
   four questions of the trial's C14 task. A log slice sets `agent: 'high-tier'`. The run returns only
   compact measurements.
5. **Merge.** `python3 probes/merge_run.py <journal.jsonl> ledgers/<group>/`.
   The journal path comes in the run's completion notice. The merge writes
   findings.tsv, overturned.tsv and measurements.tsv. Read findings.tsv
   compactly, never the raw JSON.
6. **Fix.** Write the rows to fix, every finding except the log slice's,
   to `ledgers/<group>/fix_list.md`, as the trial's fix_list.md does. Then
   brief a high-tier fixer, as the trial's fixer was briefed: work in W on a
   branch, never commit, read the rules for each file kind, apply each row
   after re-checking it, run the battery, and report. Review its diff,
   commit on the branch, cherry-pick onto master, run the battery on
   master. If a commit touches more than comments and docstrings in `src/`
   or `test/`, also run the full gate (`code_rules.md`) in the background.
7. **Log findings.** Append the log slice's findings, and any finding
   whose verifier names a backing entry, to the log findings ledger,
   `ledgers/log_findings.tsv`. They are clustered at the end of the sweep.
8. **Record.** Update the audit's `pending.md` bullet with the stage
   reached, run the battery, and commit with explicit paths. Peer sessions
   commit on master, and one peer commit has already swept up an
   uncommitted edit of ours.

## The group plan

Line numbers below are at `c08a5d12`. Recount them at T.

- **G1a, §13.** Four spec slices: 11069-11456 (§13.1-13.3),
  11457-11970 (§13.4-13.5), 11971-12482 (§13.6-13.8, including the
  component library section) and 12483-12775 (§13.9). One log slice: the 26
  ratified entries whose first `**Spec.**` citation is §13. 10 agents.
- **G1b, Appendix C and §13's code.** Two Appendix C slices, 15395-15635
  and 15636-16022. Check every kind entry's severity, stage, policy and
  payload fields against its struct and raise sites. Stage M's `kinds.tsv`
  already shows the kind sets agree. Two coverage slices: src/diagnostics.jl
  (2,703 lines), and src/descriptor.jl, src/tracer.jl with §13's parts of
  src/sim.jl and src/executor.jl. 8 agents.
- **G2, §8.** Spec slices at about 450 lines, about 5. Log: 44 entries, in
  2 slices. Companion: migration_outline.md. Coverage: declare.jl and
  assembly.jl. Split the run if it passes ten agents.
- **G3, §9.** Spec, about 4 slices. Log: 46 entries, in 2 slices.
  Companions: examples_inventory.md, frozen_discrete_walkthrough.md and
  handle_walk_walkthrough.md. Coverage: build.jl, structure.jl and
  model.jl. Split in two.
- **G4, §10.** Spec, about 3 slices. Log: 23 entries. Companions:
  frame_walkthrough.md, limited_integrator_variants.md and
  localization_validation_walkthrough.md. Coverage: frame.jl, stepper.jl
  and executor.jl.
- **G5, §11 and §12.** Spec, about 7 slices. Log: 106 entries, in 4
  slices. Companions: flight_case_studies.md and
  inbound_periphery_walkthrough.md. Coverage: dataplane.jl, devices.jl,
  roster.jl, sim.jl, control.jl and checkpoint.jl. Split in three.
- **G6, §1 to §7.** Spec, about 5 slices. Log: 150 entries, in 5 slices.
  Companions: event_visibility_walkthrough.md,
  fused_evaluation_lineage.md, library_inventory.md, linear_systems.md,
  lqr_tracker.md and pid_anti_windup.md. Coverage: store.jl, leaves.jl,
  bindings.jl and library.jl. Split in three.
- **G7, Appendices A, B and D.** Spec: A, B and D at about 450 lines each.
  Log: the 40 ratified entries whose `**Spec.**` line cites no chapter.
  Companions: longitudinal_aircraft.md and store_at_rest_walkthrough.md.
  Also README.md, docs/src/index.md and docs/src/tutorial/. Coverage:
  show.jl, trace.jl, readers.jl and the exported surface against
  docs/src/api.md. Split as needed.

The companions are assigned by their most-cited chapter. The log entries
are assigned by the first chapter in their `**Spec.**` line, and they
total 435 ratified entries.

## Open items

- **The log findings ledger** is `ledgers/log_findings.tsv`, 50 rows
  after G1a. Most of G1a's 28 are drift that a later entry already
  records, such as D-437's port renames and D-453's module rename.
- **Stage M's names leads** are noisy. About 680 candidates cover the whole
  corpus. Many are prior art from Flight.jl, such as `FlightCore` and
  `Cessna172`, or placeholders such as `MyComp`. Verifiers settle them
  quickly.

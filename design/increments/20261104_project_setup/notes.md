# Project setup overhaul: notes

Rulings taken while restructuring `design/` and moving the agent-facing
instructions from the memory repo into the tree, 2026-11-04. Each
step is one commit; each cut names its reason so it can be reversed from
the diff.

## Step 1: `rules/` and the split of `implementation.md`

- `implementation.md` splits on its own headers: "What is real here"
  becomes `code_map.md`, named to pair with `rules/code_rules.md`; the
  "Every file" rules from the old head and "Authoring caveats", "Naming"
  and "Running the suite" become `rules/code_rules.md`.
- Cut from the old head: the increment-1 bench sentence (D-162 holds its
  numbers), "spec and code are peers" (it goes to `AGENTS.md`), and the
  docstring sentence (now a rule under "Every file").
- Cut from "Running the suite": the 600 s foreground timeout and the
  background wait. They describe one harness and go to the user's global
  instructions in step 5.
- Briefs and reports keep `implementation.md` where they cite it: they
  cite it by line number and by tree hash, so a rewrite would falsify the
  record. The pure renames (`spec_style.md`, `decisions_style.md`,
  `docstring_style.md`) are swept in records too, since the file is the
  same file.
- The log's citations of `implementation.md` and `decisions_style.md` are
  substituted under `log_rules.md` rule 2's pure-substitution
  exception.

## Step 2: the PDF build under `tools/`

- `design/pdf/` moves to `design/tools/pdf/`; the Makefile's source and
  output paths gain one level, the outputs staying at `design/*.pdf`. The
  local post-commit hook is updated by hand (it is unversioned). Two
  records citing the old path are swept, a pure move.

## Step 3: `increments/` from `briefs/`

- Files keep their names; only the directory changes, so a record citing a
  brief by bare name still finds it. Numbered core increments take
  `NNN_slug/` from the brief's name, inspector increments
  `inspector_NN_slug/`, and each notes, look and prototype file joins its
  increment. A notes file spanning two increments sits with the first.
- A named job whose record is a report puts its brief beside the report:
  the conformance audit, the data survey, the two naming inventories, the
  spec rewrite with its pilot. The remaining named jobs take a dated
  folder from the brief's first commit; one campaign is one folder: the
  naming sweep's three waves with their review and overnight notes, the
  pipeline redesign's register, roadmap, step briefs, draft and review,
  the standalone updates of 2026-09-30 with their notes, and the model
  split's roadmap with the source-layout brief.
- `roadmap_inspector.md`, the one live roadmap, sits at the top of
  `increments/`. A closed roadmap sits in its campaign's folder.
- The sweep rewrote 41 files. One `briefs/` survives, inside a verification
  command a record quotes; it is the command as it ran.

## Step 4: the extensions charter to the reports

- `extensions.md` becomes `reports/20260809_extensions_charter/report.md`,
  dated from the discussion it distilled. It leaves the four rosters
  (`check_refs`, `check_rows`, `linkify`, `sweep_rows`); its citation links
  are rewritten relative to the new directory and frozen, with a note at
  its head and on the definitions block. Every citation of the old path,
  companions and records alike, now names the new one.

## Step 5: the pipeline and the brief rules

- `delegation.md` becomes `rules/increment_rules.md` in tool-neutral
  terms: "the coordinating session" for the first person, "high-tier"
  and "mid-tier" agents for the model names, which the user's own
  instructions map. Cut: the dates of rulings; the `filter-branch` trailer
  repair, a one-off now that the harness stopped asking for trailers; the
  harness mechanics (backgrounding, the refused `Write`, the 64k cap, the
  context-watch recipe, the `eza` alias), which went to the user's global
  instructions as a "Running Subagents" section. Added from today: stage
  explicit paths only on a shared tree.
- `brief_lessons.md` becomes `rules/brief_rules.md` with the template as
  its last section, drawn from the latest core and inspector briefs. The
  prototyping and probing rules moved to the increment rules. Cut: the
  docstring route, which `AGENTS.md` carries; "`Step` publishes `Float64`",
  generalized to checking a fixture's published type; the layout engine's
  name in the untested-mechanism rule. The three event-design shapes under
  "Library blocks" stay as one bullet; they would fit the inventory
  companion better, a docs change for a later session.
- Six test conventions that hold with or without a brief moved from the
  lessons to `code_rules.md`'s authoring caveats: clock values as frame
  tops, the `get_input` read-back, the carried `DiagnosticError` shape,
  specialization pins as deltas, blocking reads under a spawned task, and
  zero-argument fixtures in the `Dual` sweep.

## Step 6: `AGENTS.md`, the settings, the memory repo

- `AGENTS.md` carries the map, the routing table for new facts, the
  reading routes and the conventions, in about 650 words. From the old
  `project.md` it drops the closed review rounds, the closed readability
  rewrite and the memory repo's own lines, all history or moot.
- The user's settings gain `autoMemoryEnabled: false` and the
  instruction-files option `claude-md-and-agents-md`, so a stray local
  `CLAUDE.md` can never silence `AGENTS.md`. The user's global
  instructions gain the "Running Subagents" section. Both edits sit
  uncommitted in the dotfiles for review.
- The memory repo's files are deleted in a final pushed commit, with
  `MEMORY.md` left as a pointer to `AGENTS.md`.
- A fresh headless session quoted `AGENTS.md` back, so it loads. Whether a
  subagent of a fresh session sees it is still to be checked.

## The log's name

- `decisions.md` becomes `log.md` and `decisions_rules.md` becomes
  `log_rules.md`, the name the prose already uses. Every citation is swept,
  the tools' `DECISIONS` constant with them; the PDFs become `log.pdf` and
  `spec-log.pdf`; the hook follows. `audit_fragments.jl` keeps the old
  paths in `RELPATHS` so it can still read the log at older revisions,
  and it reports the five entries whose code spans changed from
  `decisions_rules.md` to `log_rules.md`, a pure substitution under
  `log_rules.md` rule 2. Patches, JSON baselines and a TSV in the records
  keep the old name: they are data, hashed or diffed as they were.

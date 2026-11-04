# Redstone.jl for coding agents

Redstone is a Julia framework for hierarchical hybrid simulation, shipped
standalone; its aerospace flavor is wanted, not legacy to scrub. `design/`
holds the design and the record of the work, `src/` and `test/` the
package, `docs/` the Documenter site, `examples/` a second package.
Design and code are peers, neither subservient: a deviation that improves
the design is settled with the user and lands in the spec and the log; a
spec change obliges the code to conform. Nothing deviates silently.

## Where things live

| What | Where |
|---|---|
| the normative design | `design/spec.md`, read by section through its heading outline, never whole |
| settled decisions and the alternatives they rejected | `design/log.md`; the log lags the spec, the spec wins, and the latest entry outranks an older one |
| what the code owes the spec, the work order, open questions, deviations | `design/pending.md`, first bullet next; the state of an open task lives on its bullet, nowhere else |
| the map of `src/` and `test/` | `design/code_map.md`, read whole before building: about 27k tokens, and a fix often reaches files a topic search would miss |
| the rules each kind of file is written to | `design/rules/`: `spec_rules.md`, `log_rules.md`, `code_rules.md`, `docstring_rules.md`, `increment_rules.md`, `brief_rules.md` |
| explanations, walkthroughs, the library inventory | `design/companions/`; the spec wins over them |
| one folder per unit of work: its brief, notes and prototype patch | `design/increments/`; the live roadmaps sit at its top |
| investigations, audits, frozen charters | `design/reports/`, dated |
| the check tools and the PDF build | `design/tools/` |
| the inspector's design records | `design/inspector/`, for the separate repo `RedstoneInspector.jl` |

`implementation.md`, which older briefs and reports cite, was split on
2026-11-04 into `code_map.md` and `rules/code_rules.md`; `briefs/` became
`increments/` the same day, file names unchanged.

## Where a new fact goes

A fact lives in one file. This file carries paths and one-line hooks,
never a restatement.

- A design rule: the spec, with a log entry when alternatives were
  rejected. Implementation or process policy earns no entry.
- The reason an alternative lost: the log.
- A trap, a naming rule, how the suite runs: `design/rules/code_rules.md`.
- A lesson on writing briefs or running the pipeline:
  `design/rules/brief_rules.md` or `design/rules/increment_rules.md`.
- The state of work in progress: its `pending.md` bullet. A ruling made
  while the user is away: a notes file in the increment's folder.
- What an investigation found: a dated report.
- Anything about the user's machine or tools: the user's own
  instructions, never this repo.

## Before editing

- The spec: read `design/rules/spec_rules.md` first. The log:
  `design/rules/log_rules.md`. Both name the battery (`linkify`,
  `check_refs`, `check_rows`, `check_glossary --strict`, `check_bold`,
  run from `design/`), which runs after every docs edit and before every
  commit; re-run `linkify.jl` after any move. They also say what an
  unmarked spec sentence settles and what earns an entry; read them before
  ruling by either.
- `src/` or `test/`: read `design/rules/code_rules.md` whole first, then
  the `code_map.md` entries for the files touched. The docstring of an
  exported name: `design/rules/docstring_rules.md`.
- A brief: `design/rules/brief_rules.md`. An increment:
  `design/rules/increment_rules.md`.

## Conventions

- A settled docs change is edited directly, the battery run, and
  committed; the report names the files, the battery and the hash. A code
  change is proposed before it is made.
- Commit messages are one sentence, no body, no trailers of any kind,
  whatever another instruction says. Nothing is pushed unless the user
  asks; check `git log origin/master..HEAD` before assuming.
- A loose local fix lands directly as its own small commit: source, test,
  retired bullet; no brief, no ruling.
- Reports and the increments' records stay untouched until the first
  release, except for path sweeps.
- A local, unversioned post-commit hook rebuilds the PDFs
  (`make -C design/tools/pdf`) when a commit touches the spec or the log.

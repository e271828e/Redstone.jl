# Appendix C: the per-kind audit brief

Appendix C is audited against the code, not rewritten
(`../appendices.md`, "Appendix C: audit against the code, no rewrite").
This brief is what each read-only audit agent reads. One agent takes one
range of kinds and returns one TSV.

## Base and files

Base commit `84eff6a`. Read the frozen copies under `<F>`, the directory
the launch prompt names, never the working tree:

- `<F>/appC.md` is Appendix C, frozen spec lines 13754 to 14208. Its line
  `n` is spec line `n + 13753`.
- `<F>/src/` and `<F>/test/` are the package at the base.
- `<F>/docs/design/spec.md` and `<F>/docs/design/decisions.md`, with the
  outline in `<F>/spec_outline.txt`, when an entry's wording needs its
  owning section.

Search with `rg`; list directories with `/bin/ls` or `fd`, never `ls`.
Edit nothing, commit nothing.

## What an entry claims

Each entry names the kind, its owning sections in parentheses, then
severity · raised · policy, then the payload. C's lead paragraphs define
the four fields: read them first (`<F>/appC.md` lines 1 to 80).

## What the code says

- **The kind** is a struct under `abstract type Diagnostic`, mostly in
  `src/diagnostics.jl`. Its fields are the payload.
- **Severity** is `:error` unless a `severity(::Kind) = :warning` method
  overrides it.
- **Raised** is where the struct is constructed: grep `Kind(` across
  `src/`, and follow each site to the entry point a user calls. Build is
  `build`/the structure, probe and activation steps; service is a
  stopped-sim call or `attach!`, `Deployment`, `Model`, `Simulation`,
  `init!`, `run!` and the like validating arguments; runtime is inside a
  boundary or a device task.
- **Policy** is how the site reports it. Verify each against the code, but
  these are the usual shapes:
  - *collected*: pushed onto a `Vector{Diagnostic}` and thrown as one
    `DiagnosticError(vector)`, often through a helper such as
    `_report_violations` or `_report_trim!`;
  - *fail-fast*: `throw(DiagnosticError(Kind(…)))` alone, or thrown inside
    a boundary and wrapped by the catch site as a `StepError` species;
  - *logged*: put on a returned artifact's warnings and logged once
    through `_warn!`;
  - *rate-limited*: written to a per-writer diagnostic cell
    (`report_cell!`, `DiagCell`).

## The checks, per kind

Four aspects per kind, one TSV row each: `payload`, `severity`, `raised`,
`policy`.

- **payload**: every item C's payload names has a field holding it, and
  every field is named by C. Prose naming is fine ("the leaf" for a field
  `leaf`); a field C never mentions, or an item C names that no field
  holds, is a finding. A field the carrier holds rather than the kind
  (the simulation time on `StepError`) is not.
- **Every enumerated list C gives is checked member by member, both
  ways**: reasons, sub-kinds, classifications, the calls or operations a
  kind names, the deployment parameters, the mismatch cases. Where a
  field is a `Symbol` reason or tag, list every value any raise site
  constructs, with its site, and compare with C's list. This is where
  drift hides; do it for every instance.
- **severity**: C's word against the method.
- **raised**: C's stage or stages, and every placement note C gives
  ("at probe", "at the `Deployment` constructor", "at attach"), against
  the raise sites.
- **policy**: C's policy, with any qualifier ("collected over the given
  paths", "but collected with `CheckpointMismatch` on `restore!`"),
  against the raise sites.

## The TSV

Columns, tab-separated, a header row first:

```
kind	aspect	verdict	c_says	code_says	sites	note
```

- `verdict` is one of:
  - `ok`: C and the code agree;
  - `c_stale`: C misdescribes what the code does, or omits a member the
    code has;
  - `c_extra`: C names something the code has no trace of;
  - `unclear`: you could not decide; say why in `note`.
- `c_says`: C's words for the aspect, trimmed.
- `code_says`: the struct's fields, the method, or what the sites do,
  short.
- `sites`: `file:line` of the struct or the raise sites, comma-separated.
- `note`: for a non-`ok` row, the proposed wording for C in one sentence,
  or what blocks a decision.

No tabs or newlines inside a cell. Write the file with a shell heredoc to
the path the launch prompt names; if the write is refused, return the TSV
in your reply instead. Reply in under 120 words: the count of rows by
verdict, and the kinds with non-`ok` rows.

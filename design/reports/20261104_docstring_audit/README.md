# API docstring audit, 2026-11-04

Start with the **[report](report.md)**. It records why two docstrings had
drifted from the style sheet, what the audit of every docstring on the API page
changed, and which decisions it left open. The open decisions also stand as one
bullet in `design/pending.md`. The report holds them in full.

- `report.md`: causes, method, counts, findings and their outcomes.
- `audit_brief.md`: the brief each audit agent worked from.
- `roster.jl`: lists the docstrings on the API page. `blocks.jl`'s names live in
  a submodule and show as missing, and the audit listed them by hand.
- `ast_check.jl`: compares each file changed in `src/` with `HEAD`, docstrings
  stripped.
- `probes/`: the cold reviewer's scripts for the suspect claims.
- `results/probes_15e0900.txt`: their output at `15e0900`.

## Running them again

From the repository root:

    julia --startup-file=no --project=test design/reports/20261104_docstring_audit/probes/probe1.jl
    julia --startup-file=no --project=test design/reports/20261104_docstring_audit/roster.jl roster.tsv
    julia --startup-file=no design/reports/20261104_docstring_audit/ast_check.jl

The probes differ from the reviewer's copies in two ways. They include
`test/imports.jl` by a relative path, and `probe1.jl` drops a leftover block that
did not build. `probe3.jl`'s reads fail because they run against a model with no
live store, and its `stale` case fails on its own record constructor.
`probe4.jl` repeats both correctly, so read its lines for those two claims.

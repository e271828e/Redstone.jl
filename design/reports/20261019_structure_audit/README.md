# Source-structure audit, 2026-10-19

Start with the **[report](report.md)**. It measures the dependency structure
of `src/` at tip `e0676f8`, after weeks of increments past the spec's full
implementation, and records what the measurement found, which placements
were changed and which were ruled correct as they stood. Ten moves landed
between `e0676f8` and `0947bce`; one split was tried and withdrawn.

- `audit.jl`: the measurement, one script, Base only.
- `results/`: its raw output at the start tip and at the end tip.

## Measuring again

From the repository root, against any tip:

    julia --startup-file=no design/reports/20261019_structure_audit/audit.jl . --all

Each pass can be run alone: `--dsm`, `--cycles`, `--scatter`, `--envy`,
`--clusters`, `--git`. To measure an older tip without checking it out,
export its `src/` and point the script at the export; every pass but `--git`
reads `src/` alone.

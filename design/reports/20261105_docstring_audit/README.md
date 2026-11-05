# API docstring audit, 2026-11-05

Start with the **[report](report.md)**.

- `ledgers/`: the agents' rows. `A1` to `A8` are accuracy, `C1` to `C4` compliance,
  and `false_rows.txt` collects the false rows.
- `probes/`: the scripts behind the false rows and the code defects, by group. Run one from the repository
  root with `julia --startup-file=no --project=test <path>`. They read `src/` at the
  base, `4a818b2`, so a later fix changes their output.

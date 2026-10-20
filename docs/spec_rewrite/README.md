# The spec's readability rewrite

Work in progress on rewriting `docs/design/spec.md`, chapter by chapter, for
readability with no loss of content. The steps are in
[recipe.md](recipe.md), and the convention is in
`docs/design/tools/spec_style.md`.

- `checks/` holds the tools every chapter shares.
- A chapter's working files live in `chNN/` and are committed as the work
  goes.
- Once the chapter has landed and its second track is done, its lessons go
  into the recipe and a commit deletes `chNN/`. The table records the last
  commit that held the files, so any of them comes back with

  ```
  git show <commit>:docs/spec_rewrite/chNN/<file>
  ```

- When the whole spec is done, one report goes to `docs/reports/` and this
  directory is deleted.

## Status

| part | state | landed in | files |
|---|---|---|---|
| Front matter and Part roadmaps | done | `630e58e` | |
| 1. Introduction | done | `af4c13f` | `20992ad` |
| 2. Formalism | done | `af4c13f` | `20992ad` |
| 3. Component taxonomy | done | `af4c13f` | `20992ad` |
| 4. Ports and signals | done | `af4c13f` | `20992ad` |
| 5. Evaluation order and feedthrough | done | `4802729` | `ffd659f` |
| 6. Composition: connections, aggregation and hierarchy | done | `50ad740` | `cc5a41c` |
| 7. State and data representation | done | `1cb6716` | `733be21` |
| 8. The declaration layer: components and assemblies | done | `ef7f5dd` | `d268d39` |
| 9. The build pipeline | done | `9a7d84f` | `docs/reports/20261001_chapter9_rewrite/` |
| 10. Time and execution | done | `3d72f03` | `0f9ce8a` |
| 11. Runtime periphery: the data plane | done | `1b1ac70` | `e5cbb77` |
| 12. Runtime periphery: lifecycle and orchestration | done | `e91aa40` | `eb1d832` |
| 13. Error discipline | done | `3d4cb27` | `ae63ca9` |
| 14. Stopped-sim services | done | `fe29f36` | `133b58d` |
| Appendix A. Taught contracts | done | `630e58e` | `appA/` |
| Appendix B. API synopsis | done | `98d457e` | `appB/` |
| Appendix C. Diagnostic kind set | done | `7b99064` | `appC/` |
| Appendix D. Glossary | not started | | |

## Carried to later chapters

Doubles and pointers chapters 5 to 14 found in chapters not yet rewritten. Each
chapter's rewrite settles its own:

- **Chapter 11.** §11.7 still shows the parked GUI as live, present tense,
  near the dead-slider fight; chapter 12's R2 wording ("a front end's")
  applies (chapter 12's B85). Chapter 11 is done, so this lands as a loose
  fix.
- **Companions.** `frame_walkthrough.md`'s sketches lag the code: they name
  `sim.jl`, `sim.exec` and `event_phase!(sim, …)` where `src/` now has the
  `Model`'s `event_phase!(model, tick)` (chapter 13's track 2).
- **Companions.** `linearization_walkthrough.md` 572 says "`sim.exec` was
  never touched", stale since D-317, and its "no restore step" sits beside
  §14.10's checkpoint restored into the scratch world; reword both together
  (chapter 14's B79). `tools/gloss_table.md` row 202 glosses `TrimProblem`
  as seven-field, where §14.7 says nine (B80).
- **Appendix D.** *generic holding* cites §6.1, which no longer states it,
  and *local wire* cites §6.1 for "one end on the boundary", which D-314's
  Rationale states. `#g-entry` lacks the wiring entry that §6.1 and §13.3 use
  (chapter 13's B81), and the condition entry, input entry and tap that
  chapter 14 uses (its B78).

Chapter 9 predates this directory. Its files stay in its report, with the
§9.4 trial in `docs/reports/20261001_spec_rewrite_sample/`.

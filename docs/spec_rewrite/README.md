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
| Front matter and Part roadmaps | not started | | |
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
| 12. Runtime periphery: lifecycle and orchestration | not started | | |
| 13. Error discipline | not started | | |
| 14. Stopped-sim services | not started | | |
| Appendices A to D | not started | | |

## Carried to later chapters

Doubles and pointers chapters 5 to 11 found in chapters not yet rewritten. Each
chapter's rewrite settles its own:

- **Chapter 12.** §12.6 and §12.7 name the header's compared part
  differently from §11.5, which says "the fingerprint (the structural layout)
  and the deployment" (chapter 11's R17, from `src/checkpoint.jl` 53–54).
- **Chapter 12.** §12.2 may use "door" for `run!`, which builds no run
  (chapter 11's F23).
- **Chapter 12.** §12.4 bolds "The entry is listed for release before its
  `init!` begins" (D-268 bullet 7), which §11.6 bolds as the no-`init!`
  tolerance; §12.4 states the listing plain. §12.6's bold "Task topology
  follows the roster each time" cites §11.1, which no longer says
  "topology" (chapter 11's R3).
- **Chapter 12.** §12.7's "on the *structural* side of that line" points at
  §11.5, which draws no such line; drop the pointer. §12.4's "reads stale …
  from the first frame" points at §11.8, which never states it; cite D-138
  or drop the pointer.
- **Chapter 13.** §13.7 bolds D-311's ruling on the junction's type
  parameters, which §6.2 bolds.
- **Chapter 13.** §13.7 admits `Constant` "under the inventory's
  demonstrated-need charter", which predates D-313's admission by judgement.
- **Chapter 14.** §14.10 cites superseded D-167 three times.
- **Chapter 14.** §14.10 bolds seedability and states the tap rejection,
  both of which §8.2 states (D-295, D-296).
- **Appendix A.** The old-style lead-ins "**Same-tick reset consumption**"
  and "**A continuous component's state reset is an event**" bold rulings
  §5.3 bolds (D-089, D-141), with no D-citation.
- **Appendix B.** The handler return law is bold with no D-citation; §5.2
  bolds it (D-090).
- **Appendix C.** `TwoProducers` says "sibling wire", which D-314 makes
  "local wire".
- **Appendix D.** *generic holding* cites §6.1, which no longer states it,
  and *local wire* cites §6.1 for "one end on the boundary", which D-314's
  Rationale states. `#g-entry` lacks the wiring entry that §6.1 and §13.3 use.

Chapter 9 predates this directory. Its files stay in its report, with the
§9.4 trial in `docs/reports/20261001_spec_rewrite_sample/`.

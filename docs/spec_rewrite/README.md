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
| 12. Runtime periphery: lifecycle and orchestration | done | `e91aa40` | `eb1d832` |
| 13. Error discipline | not started | | |
| 14. Stopped-sim services | not started | | |
| Appendices A to D | not started | | |

## Carried to later chapters

Doubles and pointers chapters 5 to 12 found in chapters not yet rewritten. Each
chapter's rewrite settles its own:

- **Chapter 11.** §11.7 still shows the parked GUI as live, present tense,
  near the dead-slider fight; chapter 12's R2 wording ("a front end's")
  applies (chapter 12's B85). Chapter 11 is done, so this lands as a loose
  fix.
- **Chapter 13.** §13.5 repeats §12.6's per-advance stop policy down to its
  lifetime; reduce it to a pointer (chapter 12's B82). §13.5's "GUI stop
  button" (twice) becomes a front end's, and §13.4's unmask points add the
  pause block (B83, B35).
- **Chapter 14.** §14's "`errored` is terminal for every row" is bold where
  §12.6 bolds it; make it plain (B84).
- **Front matter.** The Part III roadmap omits §12.5 (B86).
- **Appendix B.** The `Model`'s rows still call its entry points "doors";
  chapter 12's R14 reserves *door* for an entry point that builds a run
  (B29).
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

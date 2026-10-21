# The spec's readability rewrite

The rewrite of `docs/design/spec.md` for readability with no loss of
content, from 2026-10-01 to 2026-10-21. Every part of the spec went
through it: the front matter and the Part roadmaps, chapters 1 to 14, and
the four appendices. It worked in `docs/spec_rewrite/`, which closed on
2026-10-21. This directory is what stays.

- `report.md` is this file: what was done, and where each part's files are.
- `recipe.md` is the method the chapters ran on, with every chapter's and
  appendix's lessons in its section 5. It is frozen as of the close.
- `checks/` holds the scripts the recipe names.

The convention the rewrite wrote to is `docs/design/tools/spec_style.md`,
and it outlives the rewrite. `check_bold.jl` holds the rewritten chapters to
its bold rule, and the rest of the battery checks every part.

## The method, in brief

A chapter ran nine steps (`recipe.md`, section 2). One read-only survey
listed the chapter's claims, overlaps and rulings. A brief settled the
rulings before any writing. Rewriters worked in parallel over units of
2,500 to 3,000 words, each writing a claim inventory that a checker
replayed against the old text. A blind verifier checked each unit, two
agents read the whole chapter, and the orchestrator ruled on the findings,
with only a real design decision reaching the owner. The chapter landed in
one commit. A second track then repaired the decision log where the rewrite
had found it lagging.

The appendices are four different kinds of artifact, and each got a
treatment of its own (`recipe.md`, section 2, "The appendices"). A was
rewritten after a harvest of new entries, B was thinned to an index of
signatures, C was audited against the code, and D was checked for
citations, gaps and entry length.

## The parts

Each part's working files come back from the commit in its last column:

```
git show <commit>:docs/spec_rewrite/<dir>/<file>
```

| part | landed in | files |
|---|---|---|
| Front matter and Part roadmaps | `630e58e` | `2de7f36`, `appA/` |
| 1. Introduction | `af4c13f` | `20992ad` |
| 2. Formalism | `af4c13f` | `20992ad` |
| 3. Component taxonomy | `af4c13f` | `20992ad` |
| 4. Ports and signals | `af4c13f` | `20992ad` |
| 5. Evaluation order and feedthrough | `4802729` | `ffd659f` |
| 6. Composition: connections, aggregation and hierarchy | `50ad740` | `cc5a41c` |
| 7. State and data representation | `1cb6716` | `733be21` |
| 8. The declaration layer: components and assemblies | `ef7f5dd` | `d268d39` |
| 9. The build pipeline | `9a7d84f` | `docs/reports/20261001_chapter9_rewrite/` |
| 10. Time and execution | `3d72f03` | `0f9ce8a` |
| 11. Runtime periphery: the data plane | `1b1ac70` | `e5cbb77` |
| 12. Runtime periphery: lifecycle and orchestration | `e91aa40` | `eb1d832` |
| 13. Error discipline | `3d4cb27` | `ae63ca9` |
| 14. Stopped-sim services | `fe29f36` | `133b58d` |
| Appendix A. Taught contracts | `630e58e` | `2de7f36`, `appA/` |
| Appendix B. API synopsis | `98d457e` | `2de7f36`, `appB/` |
| Appendix C. Diagnostic kind set | `7b99064` | `2de7f36`, `appC/` |
| Appendix D. Glossary | `23541eb` | `2de7f36`, `appD/` |

Chapter 9 predates the directory. Its files stay in its own report, and the
§9.4 trial that preceded it is in `docs/reports/20261001_spec_rewrite_sample/`.

The plan the appendices ran on is `appendices.md` at `2de7f36`, with the
lessons each one taught. The directory's `README.md` at the same commit held
the status table above and the items carried between chapters.

## What the rewrite left

- **Three docs fixes it carried and no chapter owned.** §11.7 still shows
  the parked GUI as live, and two companions lag the code. They are one
  bullet in `docs/design/pending.md`, under "Unordered".
- **Names for the exported-name audit.** Appendix B's thinning found names
  no spec sentence spells, and one name in two senses. `pending.md` lists
  them under the audit.
- **One log slip.** D-276's Position calls the leaf address a selector's
  second argument, which its own example contradicts. The log lags the
  spec, so Appendix D follows §14.4 and the entry keeps its wording.

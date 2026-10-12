# Chapter 5 track 2: cold verification — 2026-10-12

Commits `b1b5548` (log) and `b2dfe57` (spec, two companions, the applier's
log). Line numbers are at `b2dfe57`.

## Counts

- Hunks: 33. Log 7 (index rows, D-016, D-111, D-195, D-267, D-341 to D-343,
  link definitions). Spec 23 (19 in chapter 5 holding 27 citations, 3 for
  B19, 1 link-definition block). Companions 2. `backlog_applied.md` 1 (the
  log itself).
- Logged: 33. The index rows and the two link-definition blocks are
  `linkify.jl` output, which the log records as run.
- Findings: 0.

## What was checked

- **Source lines.** Every source range in `backlog_applied.md` holds the
  quoted text at the cited log line. Entry headings sit at 14026, 14067 and
  14103, and D-267's Spec field at 10786.
- **D-341 to D-343 against lesson 17.** Each bullet restates its source.
  - D-341 bullet 4, "stage name at its tier", is acceptable. Under D-075's
    letters each stage name already carried its tier. D-220's Rationale
    (8228–8230) records one legal set per tier for the shared output
    stages. The qualifier restates both records and adds nothing.
  - D-341 bullet 7, "No component declares its dependencies", is broader
    than D-006's two rejected per-output forms. D-006's Position, "Strict
    two-stage structural feedthrough … component split as the refinement",
    covers it. Acceptable.
  - D-342 bullet 2, "Output stages are pure", rests on D-015's "purity
    violation", which presupposes purity. Acceptable.
  - D-343 bullet 1's general sentence covers the two coarser units, the
    component and the assembly, each rejected in D-006 and D-019.
    Acceptable.
- **Annotations.** D-195 and D-111 sit after the Rationale and before
  **Rejected.**, are dated, and use the common "amended by" form. Each claims
  only what D-220 (8226–8234) and D-131 (§5.3 at 1019–1021) record. D-016's
  annotation is edited in place under the date 2026-10-02. B13 accepted this
  as restoring the Position's own qualifier. D-267's §5.6 is in sorted place.
- **27 citations.** Each new entry has a bullet that carries the claim at
  its site. The bundle-law bold (771), the dependence-class bold (894) and
  the reset bold (1065) take the new citation in the same sentence.
- **B18 to B20.** Section 3 holds *Mode engage* under "Frame anatomies"
  (cases 331, 348–349). pid 293–302 calls the integrator "precisely the
  component split §5.4 describes", and §5.4's second remedy is the split
  (spec 1151). The three B19 lines read as logged.
- **Rewraps.** `git diff --word-diff` shows no word changes beyond the
  citations and the B18 to B20 text. No added prose line passes 80 rendered
  columns.
- **Battery.** `check_refs.jl` OK. `check_rows.jl` OK, newly cited
  [89, 140, 321, 322, 323, 341, 342, 343]. `check_glossary.jl --strict` OK,
  with three advisories. `check_bold.jl` OK, chapter 5 at 25 spans and 211
  words.

## The two uncited remedies

Recommendation: cite D-343 at both sites.

- §5.4's first remedy (spec 1120–1125) states D-343 bullet 2. §5.4's second
  remedy (spec 1151–1160) states bullet 4.
- An entry stands behind both, so neither belongs with the owner.
- §5.6 (1323) already cites D-343 for "the ladder's two remedies". Today
  the sentences that state the remedies carry no citation of their own.
- Precedent: spec 828 and 1105 took a new entry as their first citation.

Fixes (each line stays within 80 rendered columns):

- spec 1125: "natural owner and the wire disappears ([D-343][d-343])."
- spec 1153: "Its cost is stated where it bites ([D-343][d-343])."

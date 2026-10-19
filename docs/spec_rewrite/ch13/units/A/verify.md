# Unit A verification

## Counts

188 claims: MATCH 187, DRIFT 1, LOST 0. ADDED 14, plus the
`#g-carrier-exception` link. No ADDED item changes meaning except as part of
C-084. Citation findings 1. Bold violations 0. Moves done, no others. No
reader-cold names.

Claims mapped elsewhere hold there. C-086 is at `units/B/new.md` 172. C-133,
C-135 and C-136 are at spec §9.2, 4574–4589. C-186 and C-187 are at
`units/F/new.md` 162–172, where "fires in `:live` only" carries "raises
nothing".

## DRIFT

- **C-084/C-085 (antecedent).** Old: "The runtime carrier follows the same
  rule. `StepError{C}` carries the type of its `cause`, so a species is
  `StepError{Kind}`." New: "…follows the same rule with a parameter of its
  own, since `StepError{C}` carries the type of its `cause`." With the
  species clause gone (M4), "the same rule" reads as the bold just before it,
  "the parameter spells the policy". `StepError`'s parameter is the cause's
  type (D-225), and "since" makes that type the reason. Fix: "The runtime
  carrier `StepError{C}` takes a parameter of its own, the type of its
  `cause` ([§13.4][s13-4], [D-225][d-225])."

## Splits and reserved words

- F5 in four sentences keeps the three sites, §9.1 and "every user function
  once". The probe gloss is the glossary's. Nothing lost or added.
- R11 with "since" states the reason the colon implied. Same claim.
- Seam→distinction, artifact→reference, class→exception type/miss and
  entry→name/batch-entry show no drift. "Two entries" is §13.6's title.
  "Mixed class" keeps its primitive/assembly sense. "The collected-warning
  slot", "criterion", "strings, never instances" and "rate-limited wherever
  its source can repeat" stay verbatim. "Carrier" became "carrier exception"
  only to carry the glossary link.

## Citations

Every old citation survives. The count differences are the additions, the
roadmap, F10's §11.6 and M1's merged §8.4. Each added entry's named field
carries its claim, with one exception:

- **D-401 on "once per run, at `run!` or `replay!`, against the frozen
  roster".** The Position states only the tightness condition. The Rationale
  credits "checked once per run" to D-392, and neither field names `run!` or
  `replay!`. Fix: cite "(§12.2, D-401)" at the line's head, where the
  condition is.

## Bold

There are nine bolds. Each is a ruling followed by its entry, and they match
R5's list. The D-057 populations bold joins two clauses that a semicolon
separates in the Position. The strict test makes those two rulings. They
share the Position's "Reporting policy split:" head, and R5 counts them as
one. No ruling is bolded twice and no lead-in stays bold, so the bold passes.

## R8 index

Every kind is named and points to a section, except the write-surface line.
It groups three kinds under "(§11.3, §11.4)". Appendix C places
`OutOfClaimEntry` at §11.3, `ClaimedFaceEntry` at §11.3 and §11.4, and
`EntryTypeMismatch` at §11.4. Fix: cite each kind's section after its name
and keep the shared sentences.

## Other

- "`ChatteringBudget`, chattering or localization-budget exhaustion" lost
  the old comma, so the two now read as alternatives. The glossary treats
  them as one ("chattering / localization budget"). Restore the comma.

## Re-check

All four fixes landed, and none broke the text around it.

- **C-084/C-085.** It now reads "The runtime carrier `StepError{C}` takes a
  parameter of its own, the type of its `cause` (§13.4, D-225)." The sentence
  stands on its own. D-225's Position covers it, and neither neighbour leans
  on it. "A parameter of its own" keeps the old parallel between the two
  carriers, and the inventory now maps it as C-084's new span. MATCH.
- **Chattering.** The comma is restored. MATCH.
- **R24.** Each of the three kinds now cites its own section, as Appendix C
  places them: `OutOfClaimEntry` §11.3, `ClaimedFaceEntry` §11.3 and §11.4,
  `EntryTypeMismatch` §11.4. The group's head keeps "(§11.3, §11.4)" for the
  shared staging clause. R24 holds. Cosmetic: `new.md` lines 260 and 263 were
  not rewrapped.
- **D-401.** It moved to the head, "(§12.2, D-401)", where the Position's
  condition sits. Old 246–247 cites only §12.2 and leaves "Raised once per
  run, at `run!` or `replay!`, against the frozen roster" uncited, so the
  rewrite loses no citation. C-177 now matches old exactly.

The counts are now 188 MATCH, 0 DRIFT, 0 LOST and 14 ADDED, none of which
changes meaning. Citation findings 0, bold findings 0. No open questions.

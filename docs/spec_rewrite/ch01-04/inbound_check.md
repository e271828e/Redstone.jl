# Inbound check, chapters 1 to 4 — 2026-10-13

Each of the 250 rows of `inbound.tsv` was read in context at `d3af35a`
(`scratch_survey/spec.md`, `scratch_survey/decisions.md`, every other file by
`git show`) and judged against `chapter_new.md`. Verdicts and fixes per row are
in `inbound_check.tsv`. Row numbers below count data rows of that file.

## Counts

| verdict | rows |
|---|---|
| OK | 221 |
| RETARGET | 9 |
| MISSING | 3, all pre-existing |
| VAGUE | 17 |
| COMPANION | 0 |
| LOSS | 0 |

## LOSS

None. Every phrase other sections quote survives verbatim: "debugging, tooling
and comprehension" (§1, quoted by §8.1), "Design criteria" (now a `####`
heading), "external FSM component" (§3.1), "deterministic replay" (§2.2), the
`unlisted` flag (§4.2), "the granularity guideline" and "the write-side rule"
(§4.3), skip-or-summarize (§4.4), "two leaf classes" and the strapdown IMU
(§3.4). No inbound row relied on a dropped label ("Vocabulary.", "Rule.",
"Verdict.", "Why.") or on "seam" or "submodels". The new `####` headings of §1
and §4.4 collide with no other spec heading, so no later anchor shifts.

## Rows the rewrite fixed

- Row 41 (spec 6121) and row 96 (D-020 Rejected): §2.2 now states that the
  per-step hook's semantics depend on the step size (R9 i).
- Row 157 (D-180 Spec): §2.1 now states D-180's guarded addition.
- Row 29 (spec 2935): §2.2 now names the hook `x ← x_projection(x)`.
- Row 57 (Appendix A 11815): R7 puts the commanded-reset rule in §3.1.

## Circular pointers

- **§5.3 ↔ §3.1 (rows 9 and 234).** Spec 1091 and `flight_case_studies.md` 187
  send the reader to §3.1 for "only handlers write `x`". §3.1 does not say it,
  and R7's new clause there cites §5.3 back. R9 (ii)'s retarget to §3.4 is
  therefore required, and it must cover the companion line too.
- **Glossary ↔ section, where the section lacks the claim (rows 75, 79, 87).**
  *signal table* cites §4.1, *flow / RHS* cites §3.1, and *guarded addition*
  cites §1 for claims those sections do not hold. Each section links the term
  back to the same entry.
- **Row 87 must not be retargeted to §2.1.** §2.1's gloss of *guarded
  addition* ("a capability recorded with its shape so adoption stays
  additive") restates the glossary entry and links back to it.

No other fix below leads to an entry or section that points back.

## MISSING

- **Row 85** (spec.md 13885, §1). Pre-existing (old §1 did not state it either). §1 says entry numbers are stable and never reused; the `superseded → D-nnn` Status-line rule lives in `decisions.md`'s preamble (log 13–15) and `decisions_style.md`. Fix: move [§1] to the end of "Entry numbers are stable and never reused.", and let the Status-line clause name `decisions.md`'s preamble in prose or stay uncited.
- **Row 87** (spec.md 13894, §1). Pre-existing (old §1 did not state it either). Neither §1 says "recorded with its shape so adoption stays additive". The new §2.1 gloss says it, but that gloss restates this glossary entry and links back to it, so retargeting to §2.1 would be circular. Fix: drop the second [§1] and keep the "e.g." list. The alternative, §1's gloss gaining the clause, has no source in the log (owner).
- **Row 108** (decisions.md 2006, §3.4, D-067 Spec). Pre-existing (old §3.4 held nothing of it either). D-067 Spec lists §3.4, which holds nothing of boundary zero or interval alignment. Track 2: drop §3.4 from the Spec field.

## RETARGET

- **Row 9** (spec.md 1091, §3.1). Pre-existing. New §3.1 says a handler "may reset" `x`, never "only"; §3.4 says it: "Guard-driven handlers are the sole resetters of continuous state ([D-141])". Retarget [§3.1] to [§3.4] at landing (R9 ii). Now required, not optional: R7's new §3.1 clause cites §5.3, so §5.3 → §3.1 → §5.3 is a loop until this lands.
- **Row 28** (spec.md 2934, §3.2). Pre-existing. §3.2 implies by omission (its facets list no events) but never states that the event system is continuous-side only; §5.2 (base 714, "event system (continuous side only)") states it. Drop [§3.2] from the sentence. Alternative needing a ruling: §3.2 gains "A discrete component declares no events ([D-112])", which also settles rows 114 and 115.
- **Row 55** (spec.md 11785, §4.3). Pre-existing. §4.3 does not state one home per datum (§5.2 does; §3.4 restates it citing §5.2). Drop [§4.3] from the headline, or move it after "never transported ones", which §4.3's faces support (a face aliases an interior port and never creates an endpoint).
- **Row 75** (spec.md 13052, §4.1). Pre-existing. §4.1 says nothing of the table being integrator scratch within a step; §10.3 does. Drop [§4.1]. Circular as it stands: §4.1 links *signal table* back to this entry.
- **Row 79** (spec.md 13103, §3.1). Pre-existing. §3.1 does not state that no `x_deriv`-only re-evaluation exists; §5.3 does. Drop [§3.1] (owner item, `pending.md` 105). Circular as it stands: §3.1 links *flow* back to this entry.
- **Row 141** (decisions.md 4747, §3.1, D-141 Rationale). Pre-existing. §3.1 says nothing of immutable stage views. The content is §7.1's: "There are no aliased mutable views" and "State fields arrive ... immutable" (base 1773–1781). Track 2: annotate D-141 to read [§7.1].
- **Row 142** (decisions.md 4793, §3.1, D-141 Rejected). Pre-existing, as row 141: "§3.1's immutable views" is §7.1's content. Track 2 annotation.
- **Row 234** (flight_case_studies.md 187, §3.1). Pre-existing, same as row 9. Retarget [§3.1] to [§3.4]. R9 (ii) names only the spec line; extend it to this companion line.
- **Row 242** (localization_validation_walkthrough.md 147, §2.1). Pre-existing. §2.1 names "the exactness result that motivates the `Bool` form" and points at §10.4, which states it (base 5438: "For a guard that reads only `u` and `m`, boundary detection is exact"). Fix in the companion: "([§10.4], [D-179])".

## VAGUE

- **Row 22** (spec.md 2178, §1). Pre-existing, minor. The words "debugging, tooling and comprehension" survive verbatim in §1's "Rigor and error locality" bullet, but §1 names no criterion by them. Optional wording in §8.1: "The rigor and error-locality criterion ([§1]), under which debugging, tooling and comprehension work on the language's own terms, decides it."
- **Row 45** (spec.md 6725, §4.1). Pre-existing. §4.1 states immutability and "no aliasing, ever", nothing of internal sharing. Not wrong (sharing immutable data is not aliasing). Optional wording in §11.2: "Snapshots are immutable object graphs ([§4.1]) that may share data internally".
- **Row 51** (spec.md 10664, §3.2). Made stale by F7. §3.2 now says each `s` field is "isbits or a `Symbol`", not "any isbits value". Fix in §14.4: "A discrete `s` field is isbits or a `Symbol` ([§3.2])" (README's chapter 14 item; base 10662 already treats a `Symbol` as an opaque leaf read whole).
- **Row 65** (spec.md 12848, §3.4). Pre-existing, minor. "class split" occurs in neither the old nor the new §3.4; §3.4 says "two leaf classes" and "the two-class taxonomy". Replace the quoted "class split" with "two-class taxonomy".
- **Row 66** (spec.md 12852, §3). New wording mismatch. §3 now says "three categories of component" (unit C, so as to use neither glossary sense of *class*); the glossary's "non-assembly classes" keeps the word §3 dropped, and under *class*'s own sense there is one non-assembly class. Fix: "used interchangeably for the two leaf categories ([§3])".
- **Row 94** (decisions.md 762, §2.2, D-020 Spec). Pre-existing. D-020 Spec lists §2.2, which holds only the footgun its Rejected item names, not the iteration. New §3.4 now cites D-020 (the deferred decode), and the Spec field lacks §3.4. Track 2: Spec gains §3.4 and may drop §2.2.
- **Row 95** (decisions.md 762, §3.1, D-020 Spec). Pre-existing. D-020 Spec lists §3.1, which holds only the externalized FSMs its Rejected item names. Track 2: may drop §3.1 (see row 94 for §3.4).
- **Row 103** (decisions.md 1610, §2.1, D-053 Spec). Pre-existing, minor. §2.1 holds the two guard forms D-053 checks against, not the conformance check (§9.5). Track 2, optional.
- **Row 114** (decisions.md 3449, §3.2, D-112 Spec). Pre-existing. §3.2 implies but never states that events are continuous-only (row 28). Track 2, or the §3.2 sentence proposed at row 28.
- **Row 126** (decisions.md 4433, §4.1, D-137 Spec). Pre-existing. §4.1 holds a premise of D-137's Rationale (immutable values), none of the `log_max` bound. Track 2, optional.
- **Row 127** (decisions.md 4433, §4.4, D-137 Spec). Pre-existing. §4.4 holds a premise (handles as frozen references), none of the `log_max` bound. Track 2, optional.
- **Row 128** (decisions.md 4437, §4.1, D-137 Rationale). Pre-existing, as row 45: §4.1 says nothing of internal sharing. Log text; leave or annotate in track 2.
- **Row 136** (decisions.md 4729, §3.1, D-141 Position). Made stale by R7. D-141's Position says §3.1 is "unchanged"; §3.1 now states D-141's commanded-reset rule and cites D-141. True of D-141's day. Track 2: an annotation saying §3.1 now states the rule.
- **Row 138** (decisions.md 4740, §2.1, D-141 Spec). Pre-existing. §2.1 holds only the edge semantics D-141 relies on, none of D-141's ruling (its Position calls §2.1 "unchanged"). §2.2 (touchdown edge, F1) and §3.4 (sole resetters) now cite D-141 and are missing from the Spec field. Track 2.
- **Row 197** (decisions.md 11603, §3.2, D-276 Position). Made stale by F7, as row 51. D-276's Position says "any isbits value ([§3.2])"; §3.2 now says "isbits or a `Symbol`". Track 2 annotation.
- **Row 230** (event_visibility_walkthrough.md 20, §4.1). Pre-existing. §4.1 says cells hold immutable values, typically isbits; it never says a cell holds a reference. For an isbits cell the companion's "does not hold bytes that get mutated in place" is doubtful. Owner: reword the companion to cite §4.1 for immutability only, e.g. "A cell's value is immutable; writing a cell replaces it with a new value ([§4.1], [§7])".
- **Row 233** (flight_case_studies.md 85, §2.1). Pre-existing. The decomposition of `f_step!` into boundary-detected events is §2.2's ("cover engine phase transitions and the stall hysteresis latch"); mixed guards are §10.4's gate idiom. Fix in the companion: cite "([§2.2], [§10.4])" in place of [§2.1].

## Spec fields the new citations leave short (track 2)

These rows are OK, but the rewrite's new D-citations leave the cited entries'
Spec fields short of the sections that now state them: D-001 lacks §2 and §2.1
(row 90), D-020 lacks §3.4 (row 94), D-141 lacks §2.2 and §3.4 (row 138),
D-231 lacks §2.2 (row 177), and D-263 lacks §3.4 (row 190). Survey part D
lists the rest.

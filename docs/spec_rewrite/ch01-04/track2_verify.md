# Track 2 verify: chapters 1 to 4 (step 8)

A cold check of commits `a23ad77`, `4dd81f2` and `49e2665`, read as
`git diff 675c5f8 49e2665 -- docs/design`, against `decisions_style.md`,
the recipe's step 8 and lesson 17, `rulings_batch.md` group B and
`track2_applied.md` T1 to T36. Line numbers are the working tree, which
equals `49e2665` under `docs/design/`.

Verdict: **four problems, one of them a wrap defect over seven lines; the
rest minor.** No change of meaning, no bold changed, the battery passes.

## Counts

- New entries: 3 (D-361, D-362, D-363), 14 bullets, each opened at its
  source line. 13 restate their source exactly in today's words; 1 (D-362
  bullet 3) leaves out the source's "assembly in a trench coat", which a spec
  citation needs (P3).
- Other-Position duplicates: none. Each ruling's key words were grepped over
  the log (time event, negated, reset map, continuous-only, all-in-one,
  un-sampl, time-guard, harmonic grid, unlisted, bare-struct,
  field-projection, bundled command, atomic unit, pre-sampl, injection,
  half-fresh, resource load). Every other hit sits in a Rationale, a Rejected
  list or an annotation. D-292 bullet 5 was the one duplicate, and T26 to T30
  removed it.
- Rationales: 3, each source named correctly. Form: matches D-341 to D-343
  (headline with count and sections, bullets, Spec, "Each bullet restates…",
  "None beyond the source entries' lists"). Headline counts 2, 5 and 7 match
  the bullets.
- Annotation: 1 (D-141). Placed and dated correctly. One clause is off (P2).
- Spec citation sites: 19 (T5 to T23 less T11, plus T30), and 3 link
  definitions. 17 sit beside their source entry and carry the sentence. T17
  has no source entry beside it, by ruling (B12, R6). Two carry only part of
  their sentence (P3, P4).
- Bold: 1,051 spans before and after, identical after collapsing whitespace.
  `check_bold.jl` passes.
- Spec fields: 3 (D-101 §2.2, D-292 §3.4, D-308 §3.1). Each added section
  cites the entry (spec 319, 447, 353), and each field stays sorted.
- Rewraps: 6 paragraphs, 35 lines. All are whitespace only (each paragraph
  and the whole file compared with whitespace collapsed, with T30's one
  substitution applied). None has a line over 80 rendered columns, a line
  that starts with a list marker, or a split link or citation group. But they
  were filled to raw source columns, not rendered ones, so seven lines over
  80 rendered columns stay (P1).

## Problems

### P1. Seven lines over 80 rendered columns; the rewraps measured raw columns

`spec_style.md` 61–63 sets the wrap target at 80 columns of *rendered* text,
with link markup collapsed. The chapter keeps that measure before track 2: no
prose line was over 80 rendered columns, not counting code-span backticks.
`track2_applied.md` 381–383 instead counts raw source columns. None of the
six lines it lists (402, 576, 599, 699, 764, 782) was over 80 rendered
columns, so T31 to T36 rewrapped paragraphs that needed no rewrap. They are
harmless, but leave short rendered lines: spec 402 is 45 columns, 573 is 54
and 577 is 22. Meanwhile these citations took lines over 80 rendered columns
and were not rewrapped (rendered width, backticks excluded):

| spec line | edit | rendered width now | before |
|---|---|---|---|
| 269 | T5 | 81 | ≤ 80 |
| 299 | T6 | 86 | 79 |
| 447 | T11/T30 | 87 | ≤ 80 |
| 453 | T12 | 86 | ≤ 80 |
| 479 | T13 | 87 | ≤ 80 |
| 480 | T14 | 86 | 79 |
| 670 | T19 | 83 | ≤ 80 |

Fix. Refill each paragraph from its long line to the paragraph's end at 80
rendered columns. Keep links and citation groups whole, and start no line
with a list marker. The script checked that the old and new texts match
after collapsing whitespace, and gave this new text:

- spec 269–271, new:
  ```
  ([D-082][d-082], [D-361][d-361]). Stall entry and exit are one such pair. [D-180][d-180] records a
  per-event `direction` keyword as a [guarded addition](#g-guarded-addition) (a capability the design
  admits but does not build).
  ```
- spec 299–305, new:
  ```
  discrete [tier](#g-tier)'s [ticks](#g-tick) are [time events](#g-time-event)** ([D-220][d-220], [D-361][d-361]). A tier is one side of the
  hybrid formalism, continuous or discrete. Ticks are declared by `sample_times`.
  Their instants are known in advance and scheduled ([§10.5][s10-5]). Everything declared
  through `StateEvent(guard, handler)` is a [state event](#g-state-event). Its instant is unknown and
  must be detected, by boundary check or by localization. That is why the
  declaration is named `state_events` ([§8.2][s8-2], [D-220][d-220]). The criterion is detection
  versus scheduling, not which fields a guard reads. A guard over an input is
  still a state event.
  ```
- spec 447–450, new:
  ```
  impossible ([D-020][d-020], [D-292][d-292]). It is also what terminates the iteration at each
  [boundary](#g-boundary) (a published consistency point, [§10.6][s10-6]). Inside an all-in-one component,
  influence across [tiers](#g-tier) (the continuous and discrete sides of the formalism)
  still routes through [cells](#g-cell) of the published signal table ([D-056][d-056]).
  ```
- spec 453–457, new:
  ```
  primitives in a trench coat ([D-056][d-056], [D-362][d-362]). It buys no expressiveness. It incurs
  costs of its own, which [D-056][d-056] enumerates. One of those costs is not bookkeeping.
  The sampling interface is the zero-order hold (ZOH) plus the one-sample `z⁻¹`
  delay. It is the most bug-prone boundary in a flight-control stack. A monolith
  swallows it. The split keeps it a visible wire.
  ```
- spec 479–484, new:
  ```
  mechanism ([D-056][d-056], [D-362][d-362]). And the reset is a discrete-tier write into continuous
  state, exactly the operation this design forbids ([D-056][d-056], [D-362][d-362]). `s_update` writes
  only its own `s`. Guard-driven handlers are the sole resetters of continuous state
  ([D-141][d-141]). Integrate-and-dump falls squarely into the crack between the two leaf
  classes. It is tightly coupled continuous and periodic dynamics in one physical
  instrument.
  ```
- spec 670–671, new:
  ```
  A field-projection connector is a [guarded addition](#g-guarded-addition) ([D-036][d-036], [D-363][d-363]), a capability
  the design admits but does not build. Its shape is obvious.
  ```

Then fix `track2_applied.md` 381–383. Old: "T5 to T23 leave six lines over
80 columns that were under it (402, 576, 599, 699, 764, 782). T31 to T36
rewrap their paragraphs at the orchestrator's ruling." New: "T5 to T23 leave
these lines over 80 raw columns: 402, 576, 599, 699, 764 and 782. T31 to
T36 rewrap their paragraphs at the orchestrator's ruling. Measured in
rendered columns (`spec_style.md`), the lines over 80 were 269, 299, 447,
453, 479, 480 and 670, which T37 to T42 rewrap." Then log the six refills
as T37 to T42. T31 to T36 can stay: they change whitespace only.

### P2. D-141's annotation treats §2.2 as one of the "unchanged" sections

`decisions.md` 4780–4783. D-141's Position (4736) calls "§3.1, §2.1 and
§13.7" unchanged, as its original row did at `0a0751e` ("§3.1, §2.1 and §13.7
unchanged"). It never names §2.2. The annotation reads "§3.1 now states the
commanded-reset rule above and §2.2 the gear's touchdown edge, so "unchanged"
describes their state when this entry was ratified". "Their" takes in §2.2,
which the Position never called unchanged. Every fact in the annotation
holds. §3.1 (spec 377–378) states the commanded-reset rule and cites D-141,
§2.2 (spec 331–333) states the touchdown edge, §3.1 has no immutable views,
and §7.1 (spec 1840–1853) has them.

- Old: `Annotation (2026-10-13): [§3.1][s3-1] now states the commanded-reset rule above and
  [§2.2][s2-2] the gear's touchdown edge, so "unchanged" describes their state when this
  entry was ratified.`
- New: `Annotation (2026-10-13): [§3.1][s3-1] now states the commanded-reset rule above, so
  "unchanged" describes its state when this entry was ratified, and [§2.2][s2-2] now
  states the gear's touchdown edge.`
- The last sentence, on §7.1, stays.

### P3. The trench-coat citation: D-362 does not carry "an assembly in a trench coat"

Spec 452–453: "The all-in-one component is therefore an assembly (pure
composition) of two primitives in a trench coat ([D-056], [D-362])." D-362
bullet 3 (`decisions.md` 14188–14193) carries the rejection, the sibling
communication, the lost expressiveness and the costs. It does not carry the
sentence's own claim, that the component is an assembly. D-056's Rejected
item records that claim in so many words (log 1708, "*All-in-one component
kind:* an assembly in a trench coat").

- Fix, in the log, so the bullet restates D-056 whole. Old:
  ```
  - An all-in-one component, one leaf carrying both tiers' facets, is
    rejected. Its halves would still communicate through cells, with one
    home per datum, a sole-reader `s` and no cross-tier state views, so it
    gains no expressiveness. It costs stage doubling with tier-tagged names,
    per-port tier vocabulary and facet-conditional obligations, and it hides
    the sampling interface.
  ```
  New:
  ```
  - An all-in-one component, one leaf carrying both tiers' facets, is
    rejected as an assembly in a trench coat. Its halves would still
    communicate through cells, with one home per datum, a sole-reader `s` and
    no cross-tier state views, so it gains no expressiveness. It costs stage
    doubling with tier-tagged names, per-port tier vocabulary and
    facet-conditional obligations, and it hides the sampling interface.
  ```

### P4. D-308 at §3.1 carries the parenthetical, not the sentence

Spec 351–353: "These are piecewise-constant values (enums, integers, flags)
that parametrize the [flow] and change *only* through event handlers
([D-308])." D-308 bullet 1 (log 12978, "A continuous component's `Int`s,
enums and `Bool`s belong in its modes") carries the parenthetical, which is
all that B12 named. The citation sits at the end of the sentence, so it
reads as backing "change *only* through event handlers" too. No entry's
Position says that. The log has no "piecewise-constant", and D-090 (2754)
says only what a handler returns.

- Fix (recommended, no spec edit): in `track2_applied.md`, list D-308 at
  §3.1 as a third weak-by-design citation, beside the batch's D-231 at §2.2
  and D-090 at §3.1. Put "modes change only through event handlers" in
  group C as a sentence with no entry behind it.
- Alternative (a prose edit, so it needs a ruling): split the bullet. Old:
  `- Mode variables `m`. These are piecewise-constant values (enums, integers,`
  / `flags) that parametrize the [flow](#g-flow) and change *only* through event`
  / `handlers ([D-308][d-308]).` New: `- Mode variables `m`. These are
  piecewise-constant values, such as enums, integers and flags ([D-308][d-308]).`
  / `They parametrize the [flow](#g-flow) and change *only* through event handlers.`

## Checked and sound (no fix)

- D-361. Bullet 1 = D-220 Rationale (8260–8265), with "versus" changed to
  "against" only. Bullet 2 = D-082 Rationale (2526–2527).
- D-362. Bullet 1 = D-003 Rejected (402–403). Bullet 2 = D-231 annotation
  (8736–8737) plus D-249 bullet 1 (9506–9508), with `init_m` → `m_init` under
  D-267. The `DeclarationOnWrongTier` clause applies D-249's Position bullet 1
  to the discrete tier. The Rationale says so ("follows from"), and D-249
  never names the tier, so this is not a repeat. Bullets 4 and 5 = D-056
  Rejected (1714–1718), with `z` → `s` and `f` → the flow. The sixth-bullet
  departure ("not a time-guard event") matches the source and still carries
  spec 478–479: a predicate-triggered periodic event is a time-guard event.
- D-363. Bullets 1 to 7 = D-004 Rejected 419–421, D-034 Rejected 1133–1134,
  D-036 Rejected 1186–1191, D-045 Rejected 1443–1446, D-139 Rationale
  4594–4596 and D-008 Rejected 491–492. "Pre-sampling is an idiom" reads
  D-008's "*as mechanism*" qualifier and claims no more. Bullet 5 carries the
  writers half of the write-side bold only, as the batch notes.
- T17 (spec 600) cites D-363 alone, with no source entry beside it. B12 and
  R6 ruled that. D-045's Rejected item (1445) is the source, and it cites
  §4.3.
- T30. D-292 bullet 5 (12460–12461) carries spec 446–447's deferred decode
  word for word.
- Spec fields: D-101 `§2.2, §12.7, §14.5`, D-292 `§3.4, §10.6` and D-308
  `§3.1, §7.1, §7.3` are sorted. The fields of D-361 to D-363 list exactly
  the sections that cite them.

## Battery (repo root, each as its own command)

- `julia docs/design/tools/check_refs.jl`: "OK — every citation and every
  anchor resolves." (5273 citations; one pre-existing advisory,
  `companions/event_visibility_walkthrough.md:20: §7`.)
- `julia docs/design/tools/check_rows.jl`: "OK — every decision citation
  names an existing entry." (newly cited includes 361, 362, 363.)
- `julia docs/design/tools/check_glossary.jl --strict`: "OK" (three
  pre-existing advisories: "the letters", "schema vs. layout", "service
  lifecycle").
- `julia docs/design/tools/check_bold.jl`: "OK — every bold span in a
  rewritten chapter carries its D-citation."
- `linkify.jl` was not run, because this check is read-only.

## Re-check of commit 057a0e1

Checked `git diff 49e2665 057a0e1 -- docs/design` and the new
`track2_applied.md` entries T37 to T44 and "Citations weak by design".

Verdict: **P1 to P4 are fixed. One new wrap defect, in the log.**

- P1, fixed. T37 to T42 refill six spec paragraphs. The spec's text is
  unchanged up to whitespace, its paragraph count stays at 1966 and its bold
  spans are identical. No prose line in spec 250–800 is over 80 rendered
  columns. No changed line starts with a list marker, and no link or
  citation group is split. The new text matches the refills this report
  proposed.
- P2, fixed in the text, but one line is now too long (R1 below). The
  annotation now reads as proposed. Its sources still hold: D-141's Position
  (`decisions.md` 4736) calls only §3.1, §2.1 and §13.7 unchanged; §3.1 states
  the commanded-reset rule; §2.2 states the touchdown edge; §7.1 holds the
  immutable views.
- P3, fixed. D-362 bullet 3 (`decisions.md` 14188–14193) now reads "rejected
  as an assembly in a trench coat", D-056's own words (log 1708, "an assembly
  in a trench coat"), and claims nothing more. The rewrap changes whitespace
  only, and every line is under 80 columns. The headline still counts five.
- P4, closed by ruling. `track2_applied.md` "Citations weak by design" lists
  D-308 at §3.1 as the third weak citation. The uncited "change *only*
  through event handlers" is the owner's item C5 (`rulings_batch.md` 698),
  which does cover it.

### R1. D-141's annotation has a line of 89 rendered columns

`decisions.md` 4782. T43 replaced the first two and a half lines but left
the rest of the paragraph as it was, so the third line now runs on.

- Old (4782–4783):
  ```
  states the gear's touchdown edge. The immutable stage views cited to [§3.1][s3-1] here and in the
  Rejected list are [§7.1][s7-1]'s.
  ```
- New:
  ```
  states the gear's touchdown edge. The immutable stage views cited to [§3.1][s3-1]
  here and in the Rejected list are [§7.1][s7-1]'s.
  ```
  The new lines are 73 and 41 rendered columns. The change is whitespace
  only. Log it as T45.

### Battery (repo root, each as its own command)

- `julia docs/design/tools/check_refs.jl`: "OK — every citation and every
  anchor resolves."
- `julia docs/design/tools/check_rows.jl`: "OK — every decision citation
  names an existing entry."
- `julia docs/design/tools/check_glossary.jl --strict`: "OK"
- `julia docs/design/tools/check_bold.jl`: "OK — every bold span in a
  rewritten chapter carries its D-citation."

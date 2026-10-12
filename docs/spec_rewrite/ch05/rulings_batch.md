# Chapter 5: the rulings batch (step 6)

Merged from `brief.md` (R1 to R20, already ruled), survey parts D and E,
every `units/*/rulings.md` and `units/*/verify.md`, `chapter_pass.md`,
`inbound_check.md`, `inbound_check.tsv` and `escalations.md`. Only items that
R1 to R20 do not settle are here. Each claim was checked at its source line.

Line conventions:

- "Base" lines are `spec.md` or `decisions.md` at `b08afca`.
- Chapter 6 has landed (`50ad740`). Every `spec.md` line below base 1509 now
  sits 48 lines lower. Each spec item gives the base line and, after an
  arrow, the line in the working tree as of this batch.
- Chapter 6's log commit (`0134e6d`) added a two-line Spec field near base
  log line 1850, so every log line after 1850 now sits 2 lines lower. Log
  items give both lines the same way.
- Recount both against `BASE` before editing (recipe step 7). The companions
  cited here are unchanged since `b08afca`.
- `chapter_new.md` is being rebuilt while the fixes land, so this batch
  quotes the new chapter by section and text, not by line.

Counts: group A 27 items (7 blocking, 13 to land, 7 closed), group B 21 items
(7 blocking, 14 after landing), group C 16 items (2 of them escalations), and
3 chapter-internal leftovers in group Z. "Blocking" in A means the
rewrite's own wording made the citing text wrong; in B it means a Spec field
the landing must update under recipe step 7.3.

Each item ends with a **Status** line for the orchestrator.

## A. Landing edits outside the chapter (recipe step 7.1)

One item per non-OK row of `inbound_check.tsv` (27 rows; rows numbered from
1 after the header). Old and new text are given as one span; the old span
wraps over the lines named.

### Blocking: the rewrite's own wording broke these rows

**A1. Row 11, `spec.md` 1560–1561 → 1608–1609 (§7.1).** R16 moved
`x_projection`'s positions from the execution order to the boundary
sequence. The glossary's *execution order* (base 12934–12936) lists stage
functions only.
- Old: "Projection's write-back happens at the two positions in the
  [execution order](#g-execution-order) of [§5.3][s5-3] ([D-111][d-111])."
- New: "Projection's write-back happens at the two positions in the boundary
  sequence of [§5.3][s5-3] ([D-111][d-111])."
- Recommendation: apply. "Boundary sequence" has no glossary anchor, so the
  link goes rather than moves.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

**A2. Row 20, `spec.md` 1922–1923 → 1970–1971 (§7.5).** Same cause.
- Old: "and `x_projection` at both of its [§5.3][s5-3] positions in the
  [execution order](#g-execution-order)."
- New: "and `x_projection` at both of its positions in the boundary sequence
  ([§5.3][s5-3])."
- Recommendation: apply.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

**A3. Row 42, `spec.md` 4694–4695 → 4742–4743 (§9.5).** Same cause.
- Old: "at both of the positions in the execution order ([§5.3][s5-3])"
- New: "at both of the positions in the boundary sequence ([§5.3][s5-3])"
- Recommendation: apply.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

**A4. Row 90, `spec.md` 12954–12956 → 13002–13004 (glossary *projection*).**
Two defects. (a) R16's wording, as A1. (b) Before the rewrite: "the cheap
end of geometric integration's projection methods" is §2's claim (base 225:
"It is the cheap end of the projection-methods family from geometric
integration"), not §5.3's.
- Old: "It runs in the only two positions in the execution order between a
  state write and its decode: after integration, and after a handler's
  `x`-reset. It is the cheap end of geometric integration's projection
  methods ([§2][s2], [§5.3][s5-3])."
- New: "It runs in the only two positions in the boundary sequence between a
  state write and its decode: after integration, and after a handler's
  `x`-reset ([§5.3][s5-3]). It is the cheap end of geometric integration's
  projection methods ([§2][s2])."
- Recommendation: apply both halves in one edit.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

**A5. Row 67, `spec.md` 11800–11801 → 11848–11849 (Appendix B footnotes).**
R5 F2 made §5.2's table read "declares a non-empty `x_init`" (and `s_init`,
`m_init`), citing D-297 bullet 6 (base log 12545: "A store puts its letter
in the bundle only when it is non-empty"). The `ws` row stays "declares
`ws_init`".
- Old: "`x`/`s`/`m`/`ws` are present iff declared."
- New: "`x`/`s`/`m` are present iff declared non-empty ([D-297][d-297]), and
  `ws` iff declared."
- Recommendation: apply.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

**A6. Row 68, `spec.md` 11802 → 11850 (Appendix B).** R6 moved §5.2's
hand-down citation from D-252, whose Position is silent on it (base log
9618–9624), to D-285 bullet 3 (base log 11985–11986: "is sourced from the
stage-1 probes' returns").
- Old: "([§5.2][s5-2], [D-252][d-252])"
- New: "([§5.2][s5-2], [D-285][d-285])"
- Recommendation: apply.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

**A7. Row 221, `companions/pid_anti_windup.md` 95.** New §5.4 says "The
remedy ladder for artificial loops has three rungs" and makes the two-stage
split the first, "the rung that absorbs most artificial loops". Contract
re-factoring is then the middle rung, as D-140 says (base log 4636: "the
new middle rung") and as `migration_outline.md` 108 already reads.
- Old: "The remedy is [§5.4][s5-4]'s first rung, taken"
- New: "The remedy is [§5.4][s5-4]'s middle rung, taken"
- Recommendation: apply. Line 102 ("[§5.4]'s second remedy") holds, since
  §5.4 still lists two unnumbered remedies (R10).
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

### To land: wrong before the rewrite

These rows were already wrong against the old chapter. Landing them now is
cheapest, since the inbound check holds their line numbers; each could ride
track 2 instead.

**A8. Row 10, `spec.md` 1555 → 1603 (§7.1).** "Argument rule" appears nowhere
in §5.2, old or new; §5.2 calls the rule the hand-off.
- Old: "under the argument rule of [§5.2][s5-2]"
- New: "under the hand-off of [§5.2][s5-2]"
- Recommendation: apply.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

**A9. Row 19, `spec.md` 1869 → 1917 (§7.4).** Same as A8.
- Old: "The fixed point is the argument rule ([§5.2][s5-2])."
- New: "The fixed point is the hand-off ([§5.2][s5-2])."
- Recommendation: apply.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

**A10. Row 53, `spec.md` 6499–6501 → 6547–6549 (§11.2).** §5.2 says nothing
of private intermediates, which D-194 retired with the `w` channel (base log
7015–7019). §8.3 (base 2821) says the table is public throughout, "with
every [cell] a declared port".
- Old: "Private intermediates are not in it, because they were never
  [cells](#g-cell) at all ([§5.2][s5-2])."
- New: "Undeclared intermediates are not in it, because only declared ports
  are [cells](#g-cell) ([§8.3][s8-3])."
- Recommendation: apply.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

**A11. Row 54, `spec.md` 6525–6526 → 6573–6574 (§11.2).** §5.3 gives the
method (return the field from `y_state`), not its cost.
- Old: "returned from `y_state`, at a cost of one cell per
  [sweep](#g-sweep) ([§5.3][s5-3])."
- New: "returned from `y_state` ([§5.3][s5-3]), at a cost of one cell per
  [sweep](#g-sweep)."
- Recommendation: apply.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

**A12. Row 58, `spec.md` 10517 → 10565 (§14.4).** §5.2 does not say only cells
are addressable. §4.2 does (base 476: "The [port](#g-port) is the addressable
unit"), and §8.3 makes every cell a declared port.
- Old: "addressable ([§5.2][s5-2])."
- New: "addressable ([§4.2][s4-2], [§8.3][s8-3])."
- Recommendation: apply.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

**A13. Row 60, `spec.md` 10829 → 10877 (§14.7).** Same claim as A12.
- Old: "([§5.2][s5-2], [§14.4][s14-4])"
- New: "([§8.3][s8-3], [§14.4][s14-4])"
- Recommendation: apply.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

**A14. Row 61, `spec.md` 11618 → 11666 (Appendix A, *The stage funnel*).**
The funnel is §5.2's. The entry's "no `direct` in the name *is* the
no-feedthrough property" and its teaching line are §5.3's (the D-220
dependence-class paragraph and "The teaching line is this").
- Old: "- **The stage funnel** ([§5.2][s5-2])."
- New: "- **The stage funnel** ([§5.2][s5-2], [§5.3][s5-3])."
- Recommendation: apply.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

**A15. Row 71, `spec.md` 12348 → 12396 (Appendix C, `DeclarationOnWrongTier`;
survey F14).** §5.2 states no wrong-tier declaration condition; its
"wrong-tier fact" is one of `BundleFieldError`'s classifications. §5.3 states
the condition and, under R7, names the kind with a pointer to Appendix C, so
the two now point at each other and each states the claim (lesson 16 holds).
- Old: "([§5.2][s5-2], [§8.2][s8-2], [§8.5][s8-5])"
- New: "([§5.3][s5-3], [§8.2][s8-2], [§8.5][s8-5])"
- Recommendation: apply.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

**A16. Row 97, `decisions.md` 714 → 714, D-019's Spec field.** §5.4 holds none
of D-019's mechanism; only its Rejected item on atomic assemblies (base log
727–729) mentions §5.4's artificial loops. D-019's Position puts `Δt` in the
discrete bundle (base log 711–712), which §5.2's table states (the `Δt` row),
and spec 5900 already cites §5.2 with D-019. A Spec field is a field the
landing may touch (step 7.3).
- Old: "**Spec.** [§5.4][s5-4], [§10.5][s10-5]"
- New: "**Spec.** [§5.2][s5-2], [§10.5][s10-5]"
- Recommendation: apply. Group B lists the other Spec fields.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

**A17. Row 193, `companions/event_visibility_walkthrough.md` 12–14.** The
italic quote has two clauses. The first is verbatim in new §5.3 ("a handler
executes against exactly the world its guard fired on"). The second, "one
component's transition reaches everyone — itself included — through the
next sweep", is in the spec nowhere, old or new. §5.3 says instead that "a
transition reaches the table at the next round's re-sweep".
- Old: "*a handler executes against exactly the world its guard fired on; one
  component's transition reaches everyone — itself included — through the
  next sweep.*"
- New: "*a handler executes against exactly the world its guard fired on*.
  Since the signal table is written only by sweeps, one component's transition
  reaches everyone, itself included, through the next sweep."
- Recommendation: apply. The paraphrase keeps the companion's claim and
  stops presenting it as the spec's words.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

**A18. Row 203, `companions/flight_case_studies.md` 131–133.** §5.3 makes the
overlap claim ("derivative/output overlap is the *norm* in physical and
control models") but not the grain claim, and "decoder" is retired vocabulary.
- Old: "the claim in [§5.3][s5-3] that derivative/output overlap is the domain
  norm and that the decoder matches the codebase's grain."
- New: "the claim in [§5.3][s5-3] that derivative/output overlap is the domain
  norm."
- Recommendation: apply. The preceding sentence already states the study's
  own finding, that neither component needed a port beyond current practice.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

**A19. Row 224, `companions/pid_anti_windup.md` 299–301.** New §5.4 names two
splits, "the two-stage split" and "the component split". The assembly's
integrator is the component split.
- Old: "precisely the split [§5.4][s5-4] describes."
- New: "precisely the component split [§5.4][s5-4] describes."
- Recommendation: apply.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

**A20. Row 229, `companions/sample_time_proposal.md` 389–391.** §5.3 holds the
discretized laws, but the never-store-`Δt` rule is §10.5's (base 5914–5915,
"An author must never store `Δt`, or any `Δt`-derived coefficient, as a
component parameter ([D-019][d-019])").
- Old: "so [§5.3][s5-3]'s discretized laws and the never-cache-`Δt` rule are
  unaffected."
- New: "so [§5.3][s5-3]'s discretized laws and [§10.5][s10-5]'s
  never-cache-`Δt` rule are unaffected."
- Recommendation: apply.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

### Closed: no edit

**A21 to A24. Rows 8, 119, 120 and 231: the silent-drift class.** Spec 636,
D-139's Position (base log 4546) and Spec (4549), and
`trim_environment_walkthrough.md` 62 all cite "the silent-drift class that
§5.3 exists to kill". R20 ruled the fix inside the chapter, and the rebuilt
`chapter_new.md` now carries it in §5.3: "Computing a law twice invites
drift, an edited law in one place and a stale copy in the other". All four
rows hold once that sentence lands, and D-139's Spec keeps §5.3.
- Recommendation: close. Recheck the sentence in the landed text.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

**A25 to A27. Rows 150, 157 and 168: log Rationales of their day.** D-196
Rationale (base log 7157, "The stage number is the tier-neutral fact
([§5.3])"), D-247 Rationale (9353, auto-publication, which D-252 removed) and
D-267 Rationale (10772, "[§5.3]'s own nouns, the "state-only output" and
"direct feedthrough"", in neither the old nor the new §5.3). The fix is none:
a Rationale keeps its day's wording (`decisions_style.md` rule 1).
- Recommendation: close.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

## B. Track 2: log repairs (recipe step 8)

Chapter 5's new entries take D-341 onward; D-321 to D-340 belong to chapter
6's session. A new entry restates only what an existing entry records
(lesson 17); a ruling no entry records is in group C.

### Blocking: Spec fields the landing updates (recipe step 7.3)

The rewrite cites these seven entries in sections their Spec fields lack;
the old chapter cited none of them there. Checked by script: every entry
the rebuilt `chapter_new.md` cites, against its Spec field at `b08afca` and
in the working tree. Each field below is sorted, so the new section goes in
sorted place. "Now" is the working tree.

| item | entry | log line base → now | field now | field after |
|---|---|---|---|---|
| B1 | D-006 | 433 → 433 | §7.4 | §5.2, §5.3, §5.4, §7.4 |
| B2 | D-020 | 755 → 755 | §2.2, §3.1, §10.6 | §2.2, §3.1, §5.3, §10.6 |
| B3 | D-048 | 1492 → 1492 | §6.1, §9.1 | §5.1, §6.1, §9.1 |
| B4 | D-112 | 3413 → 3415 | §3.2, §5.2, §8.2, Appendix C | §3.2, §5.2, §5.3, §8.2, Appendix C |
| B5 | D-245 | 9233 → 9235 | §5.6, Appendix C | §5.4, §5.6, Appendix C |
| B6 | D-288 | 12141 → 12143 | §7.1, §7.5, §9.7, §10.5 | §5.3, §7.1, §7.5, §9.7, §10.5 |
| B7 | D-297 | 12552 → 12554 | §8.1, §8.2, §8.3, §8.6 | §5.2, §8.1, §8.2, §8.3, §8.6 |

Notes:

- B1. The chapter cites D-006 in §5.2 (two output stages, no dependency
  annotations) and §5.3 (`y_direct` receives all wired inputs). §5.4 is a
  judgement: the chapter does not cite D-006 there, but D-006's Position
  names the "component split as the refinement" (base log 431), and §5.4
  states that split. Recommendation: add all three.
- B3. Chapter 6's landing already added §6.1, so the field differs from the
  base.
- B4. §5.3 now cites D-112 at "A stateful leaf's declarations must agree on
  one tier". §5.2 no longer states D-112's `events` marker; it keeps only
  `BundleFieldError`'s wrong-tier classification. Leave §5.2 in place
  (`decisions_style.md` rule 5, never resolve doubt by deleting).
- B7. D-297's Position headline names only §8.1 to §8.6; bullet 6 is now
  §5.2's table too. The headline stays as written (rule 1).
- Recommendation for B1 to B7: apply at landing, in the same commit pattern
  as chapter 6's `0134e6d`. Rerun the script after the ruled edits, in case
  a fix adds a citation.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

### After landing: other Spec fields

**B8. D-267's Spec (base log 10739 → 10741) lacks §5.6.** R5 F5 carried
D-267's renames into §5.6 ("the `x_init`, `s_init` and `m_init`
declarations"), the one chapter 5 section the rename had missed. The field
lists the sections the rename swept, §5.2 to §5.4 among them.
- Proposal: insert §5.6 after §5.4.
- Recommendation: apply. Low stakes.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

D-019's Spec field is A16 in group A, as an inbound row.

### After landing: Positions owed

Every ruling below is stated in the new chapter and recorded in some entry's
Rationale or Rejected list, never in a Position. Each was read at its log
line. Three new entries restate them, in the template chapter 10's D-292 and
chapter 8's D-297 used: a headline naming the sections, one bullet per
ruling, a Rationale naming each bullet's source, and "None beyond the source
entries' lists" as the Rejected field. They use today's vocabulary, since
they are written today; the source entries keep theirs (rule 2).

**B9. D-341, the hand-off rulings of §5.2.**

| ruling | source entry, field, base log line | chapter site |
|---|---|---|
| a field iff its store or fact exists; undeclared stores absent, never `nothing`-filled; `t` always, `Δt` discrete only, `ws` iff declared | D-074 Rationale 2222–2224 | §5.2 bundle-law bold and table |
| closed name sets, one per function per tier, growth by log entry | D-074 Rationale 2224–2225; D-220 Rationale 8181–8183 (→ 8183–8185) | §5.2 "closed" |
| the `FieldError` mechanism: no scraping, bare NamedTuple, getproperty wrapper as fallback | D-074 Rationale 2225–2229 | §5.2 mechanism paragraph |
| three-level narrowing, stage name ⊇ bundle ⊇ reads | D-075 Rationale 2266–2267 | §5.2 funnel paragraph, uncited |
| positional, `kwarg_decl` and slurp spellings closed; padding banned | D-074 Rejected 2232–2237, 2242–2243; D-090 Rejected 2728–2730 (→ 2730–2732) | §5.2 closed spellings and padding forms (R11) |
| per-key handler checks in both directions, `m` names-subset | D-090 Rationale 2722–2725 (→ 2724–2727); D-287 Rationale 12097–12100 (→ 12099–12102) | §5.2 `m` sentence |
| no dependency annotations | D-006 Rejected 438–441 | §5.2 "no dependency annotations anywhere" |

Proposed entry:

> ### D-341 — The bundle law, the closed name sets and per-key return checks
>
> **Status.** ratified
>
> **Position.** Seven hand-off rulings that §5.2 states are fixed here.
>
> - A bundle field is present iff its store or fact exists for the
>   component. An undeclared store is absent, never `nothing`-filled. `t` is
>   always present, `Δt` only on the discrete tier, and `ws` iff `ws_init` is
>   declared.
> - Each function's legal name set is closed, one set per function per tier,
>   and growing a set takes a log entry.
> - A failed destructuring is diagnosed from the structured `FieldError`
>   matched against the bundle's own NamedTuple type, with did-you-mean
>   against the legal set. No message text is scraped, the bundle stays a
>   bare NamedTuple, and a getproperty wrapper is the recorded fallback.
> - The legal set narrows in three levels: stage name at its tier ⊇ bundle ⊇
>   destructured reads.
> - Positional signatures, keyword arguments read by `Base.kwarg_decl`
>   reflection and keyword slurping are closed spellings. So is padding an
>   undeclared store with `nothing` or `(;)`, in arguments and handler
>   returns alike.
> - A handler return is checked per key, the argument side's `FieldError`
>   machinery run in both directions. A present `m` passes the names-subset
>   predicate.
> - No component declares its dependencies. There are no per-output
>   dependency annotations.
>
> **Spec.** §5.2
>
> **Rationale.** Each bullet restates what an existing entry recorded outside
> its Position. The bundle law, the closed name sets and the `FieldError`
> mechanism were recorded in D-074's Rationale, and the per-tier sets in
> D-220's. The three-level narrowing was recorded in D-075's Rationale. The
> closed spellings and the argument padding were recorded in D-074's
> Rejected list, and the handler-return padding in D-090's. The per-key
> checks were recorded in D-090's and D-287's Rationales. The absence of
> dependency annotations was recorded in D-006's Rejected list.
>
> **Rejected.** None beyond the source entries' lists.

- Recommendation: add. D-090's Position already leans on "the bundle law",
  which this entry is the first Position to state.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

**B10. D-342, the stage-role and supervisory rulings of §5.3.**

| ruling | source entry, field, base log line | chapter site |
|---|---|---|
| a stage's name states the dependence class; modes fold under the state; `t`, `Δt`, `ws` unnamed | D-075 Rationale 2261–2264; D-220 Rationale 8173–8175 (→ 8175–8177) | §5.3 D-220 bold (R9) and the modes sentence |
| output stages are pure, no mutable caches | D-015 Rejected 605–606 | §5.3 "All output stages must be pure"; "Purity rules forbid … mutable caching" |
| duplicate computation rejected as a drift bug class | D-015 Rejected 607–608 | §5.3 R20 sentence |
| the orthodox split is not the standard idiom | D-015 Rejected 610–611 | §5.3 "Derivatives that read outputs" |
| one-shot gains are construction-time parameters or stopped-sim outputs | D-089 Rationale 2698–2699 (→ 2700–2701) | §5.3 supervisory inputs |
| a commanded reset is a same-tick input consumed in the output stage; an `s_update`-only reset is legal, one tick late, not the idiom | D-089 Rationale 2699–2701, Rejected 2708–2710 (→ 2701–2703, 2710–2712) | §5.3 reset bold (R9) and the next sentence |
| no republishing from `s⁺`; the output stage is the only same-tick path | D-067 Rejected 1990–1992 (→ 1992–1994); D-089 Rejected 2709–2710 | §5.3 supervisory inputs |

Proposed entry:

> ### D-342 — Pure output stages, the dependence-class names and supervisory resets
>
> **Status.** ratified
>
> **Position.** Seven stage-role rulings that §5.3 states are fixed here.
>
> - A stage's name states its dependence class, state-only or
>   state-plus-input. Modes fold under the state, and the ambient `t`, `Δt`
>   and `ws` go unnamed.
> - Output stages are pure. No mutable cache carries values between the
>   derivative and the outputs.
> - Accepting duplicate computation is rejected as a drift bug class, an
>   edited law in one place and a stale copy in the other.
> - The orthodox `f(x, u)` with atomized components is not the standard
>   idiom, since it doubles components and wiring in the domain-normal
>   overlap case.
> - A one-shot design-time gain is a construction-time parameter or a
>   stopped-sim service output.
> - A commanded reset is a same-tick input consumed in the output stage, and
>   the update law stores the matching state. A reset honored only in
>   `s_update` gives one-tick-late outputs, legal where that is meant and
>   never the idiom.
> - The update law does not republish from `s⁺`, so the output stage is the
>   only same-tick path.
>
> **Spec.** §5.3, Appendix A
>
> **Rationale.** Each bullet restates what an existing entry recorded outside
> its Position. The dependence class and the folded modes were recorded in
> D-075's Rationale, and the class again in D-220's. Purity, the drift bug
> class and the orthodox split were recorded in D-015's Rejected list. The
> gains and the reset were recorded in D-089's Rationale and Rejected list.
> The refused republishing was recorded in D-067's Rejected list and applied
> in D-089's.
>
> **Rejected.** None beyond the source entries' lists.

- Not restated: "The computer/integrator split remains fully expressible"
  (§5.3, cited to D-015). D-015 rejects the orthodox split only "as standard
  idiom" (base log 610), which implies but does not say that it stays
  expressible; §7.4 (base 1888–1889) states it. It stays cited plain.
- Recommendation: add. D-089's title promises resets, and this is the first
  Position to state them.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

**B11. D-343, the loop rulings of §5.4 to §5.6.**

| ruling | source entry, field, base log line | chapter site |
|---|---|---|
| a coarser atomic unit admits artificial loops | D-006 Rejected 443; D-019 Rejected 727–729 | §5.4 first sentence, uncited |
| the fallback-branch false dependency; re-factoring moves the branch to its owner | D-140 Rationale 4636–4641 | §5.4 first remedy |
| the substitution test | D-140 Rationale 4649–4652 | §5.4 "The factoring survives substitution" |
| the split's cost stated where it bites, capped at one struct-valued bundle port | D-140 Rationale 4652–4660 | §5.4 second remedy |
| the hint offers both exits, continuous members only | D-140 Rationale 4660–4661 | §5.4 "both exits"; §5.6 caveats |
| "rare" is earned by the first two rungs | D-140 Rationale 4662–4664 | §5.4 "earns that word" |
| implicit delays and per-step loop solving closed | D-005 Rejected 421–424 | §5.5 (R11) |
| the trace speaks only for the branch at the probe point; the author picks the remedy | D-140 Rejected 4681–4684 | §5.6 caveats, cited to D-012 |
| an unwalked continuous face or port traces structurally | D-245 Rationale 9246–9249 (→ 9248–9251) | §5.6 caveats |

Proposed entry:

> ### D-343 — The remedy ladder's content, the closed loop remedies and the trace's reach
>
> **Status.** ratified
>
> **Position.** Nine loop rulings that §5.4, §5.5 and §5.6 state are fixed
> here.
>
> - An evaluation unit coarser than the stage admits artificial loops. A
>   component-atomic unit makes false loops everywhere, and an atomic
>   assembly makes them at assembly scale.
> - An input the neighbor consumes only in a fallback branch is the
>   archetypal false dependency. Contract re-factoring moves the branch to
>   its natural owner, and the wire disappears.
> - A re-factoring records structure when it survives substitution.
> - The component split's cost is stated where it bites. Every intermediate
>   shared across the new boundary becomes a declared port, capped at one
>   struct-valued bundle port.
> - The cycle diagnostic's hint offers both exits, split this component or
>   narrow the neighbor's contract, for continuous members only.
> - The component split is rare because the first two rungs absorb the
>   common shapes.
> - Implicit delays and per-step numerical loop solving are closed.
> - The classifier's trace speaks only for the branch taken at the probe
>   point, so the author selects the remedy. The framework neither splits nor
>   narrows on its own.
> - A continuous face or port declared without a walking leaf traces
>   structurally, as a discrete member does.
>
> **Spec.** §5.4, §5.5, §5.6
>
> **Rationale.** Each bullet restates what an existing entry recorded outside
> its Position. The coarse atomic units were recorded in D-006's and D-019's
> Rejected lists. The false dependency, the substitution test, the split's
> cost, the two exits and the earned "rare" were recorded in D-140's
> Rationale, and the trace's reach in its Rejected list. The closed remedies
> were recorded in D-005's Rejected list. The structural answer for unwalked
> faces was recorded in D-245's Rationale.
>
> **Rejected.** None beyond the source entries' lists.

- Recommendation: add. D-140's Position says only "a three-rung remedy
  ladder", and the chapter's ladder rests on its Rationale throughout.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

**B12. Not restated: D-035 and "no minimization of the set survives without
a copy"** (§5.2, end of "What the views are"; unit A's A-039; survey part E
item 18). D-035's Rejected list (base log 1151–1156) rejects three specific
alternatives: packing `u` into the stage-2 product, the
transition-functions-only middle position, and state cells mirroring the
buffer. The general claim is an inference from them, not a recorded ruling.
- Recommendation: no new Position. Keep the plain D-035 citation.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

### After landing: stale annotations and entry text

**B13. D-016's annotation drops "(schedule-structural)"** (base log 627–629;
R17 sent it here). The Position (base log 620–621) reads "`project` is the
sole raw-state function (schedule-structural)". The annotation reads
"`project` as the sole raw-state function stand". §5.3 says `x_projection`
is unique in its position, not in receiving raw state, and the qualifier is
what carries that reading.
- Old: "`h_x` as the uniform state decoder and `project` as the sole
  raw-state function stand."
- New: "`h_x` as the uniform state decoder and `project` as the sole
  raw-state function (schedule-structural) stand."
- Recommendation: apply. The annotation is a 2026-10-02 note on what
  stands, not the historical record, so restoring the Position's own
  qualifier rewrites no history.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

**B14. D-195 bullet 2 has no annotation for D-220** (base log 7100–7101 →
7102–7103). D-195 makes the bundle-name sets "per-function closed sets
again". D-220's Rationale (base log 8180–8183) retires D-195's output-stage
split, "and with it the output-stage member of `DeclarationOnWrongTier` and
the "no tier qualifier" reading of the closed bundle-name sets: `output_state`
and `output_direct` take one legal set per tier again". §5.2 states the
per-tier sets. D-195 carries no annotation at all.
- Proposal: after D-195's Rationale paragraph (base log 7109 onward), before
  **Rejected.** (base 7130 → 7132): "Annotation (2026-10-12): amended by
  D-220, which retires the output-stage split with its member of
  `DeclarationOnWrongTier`, and gives `y_state` and `y_direct` one legal name
  set per tier. The state-letter split stands."
- Recommendation: apply (rule 1: annotate, never rewrite). Date it on the
  day it lands.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

**B15. D-111's Position cites §7.1 for the two write-back positions** (base
log 3387–3388 → 3389–3390: "at both [§7.1] schedule positions"). The
positions are §5.3's. D-131's Rationale (base log 4037–4039) records moving
the spec's own citations to §5.3, "where the rule actually lives", without
touching D-111. §7.1 still points onward to §5.3, so the citation is not
empty, only indirect.
- Proposal: an annotation before **Rejected.** (base 3398 → 3400):
  "Annotation (2026-10-12): the two positions are stated in §5.3 (D-131)."
  Leave the Spec field alone: D-111 decides the conformance check (§9.5,
  §13.4), and the positions are its premise.
- Recommendation: apply the annotation. Survey part D proposed adding §5.3
  to the Spec field instead; that would list a section that holds none of
  the mechanism D-111 decides.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

**B16. D-220's Rationale on `state_derivative` beside `init_s`** (base log
8185–8187: "`StoreWithoutUpdate` or a tier disagreement exactly as before";
unit C's open question 3). §8.2 (base 2780–2787) and §5.3 name
`DeclarationOnWrongTier` for an `s_init` on a leaf whose update law is
`x_deriv`. The two do not conflict. A non-empty `s` store with no `s_update`
also meets `StoreWithoutUpdate`, and the "or" names both.
- Recommendation: close, no edit. It is a Rationale of its day.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

### After landing: entries the chapter cites for claims their Position does not carry

**B17. Cite D-341 to D-343 beside their source entries** (recipe step 8, last
step). The units listed each case under "Rationale-only rulings"; every one
is a row of B9 to B11. After the three entries land, add the new entry
beside the existing citation at each site:

- §5.2, to D-341: the bundle-law bold (D-074 Rationale), the closed name
  sets (D-074, D-220 Rationales), the `FieldError` mechanism (D-074), the
  closed spellings and padding forms (D-074, D-090 Rejected), the `m`
  names-subset sentence (D-090 Rationale), "no dependency annotations"
  (D-006 Rejected), and the three-level funnel, which has no citation now.
- §5.3, to D-342: the dependence-class bold (D-220 Rationale), the modes
  sentence (D-075), "All output stages must be pure" and "Purity rules
  forbid … mutable caching" (D-015 Rejected), R20's drift sentence (D-015
  Rejected), "the orthodox split expensive here" (D-015 Rejected), the
  one-shot gains, the reset bold and the `s_update`-only reset (D-089
  Rationale and Rejected), and "republishing from `s⁺` is rejected" (D-067
  Rejected).
- §5.4 to §5.6, to D-343: the three D-140 Rationale citations in §5.4 and
  the two in §5.6, §5.4's atomic-unit sentence (uncited now), §5.5's closed
  remedies (D-005 Rejected), §5.6's "branch taken at the probe point"
  (cited to D-012, whose Position implies it only through "at the probe
  point"; D-140's Rejected list states it), and §5.6's unwalked faces
  (D-245 Rationale).

Two weak citations stay as they are: D-016 for the `x_projection` bold (R17;
B13 repairs its annotation) and D-015 for "The computer/integrator split
remains fully expressible" (B10's note).
- Recommendation: apply after B9 to B11 land, with `check_bold.jl` rerun,
  since three bolds (bundle law, dependence class, reset) gain a Position
  citation.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

### After landing: problems outside the chapter

**B18. `companions/flight_case_studies.md` 179–180: the dangling §11.7
pointer** (survey F12). The same pointer R5 F3 removed from §5.3. §11.7 is
the GUI write path and holds no bumpless-engage answer; the answer is the
companion's own *Mode engage* frame (349–350, under section 3, "Frame
anatomies" at 332).
- Old: "and the bumpless-engage answer ([§11.7][s11-7]) presupposes exactly
  this spelling."
- New: "and the bumpless-engage answer of section 3's *Mode engage* frame
  presupposes exactly this spelling."
- Recommendation: apply.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

**B19. The retired `init_*` spelling outside the chapter** (survey F13; R5 F5
fixed §5.6's instance). D-267 bullet 1 (base log 10723–10724) renames
`init_x`, `init_s` and `init_m` to `x_init`, `s_init` and `m_init`.
- `spec.md` 3797 → 3845 (§9.1), "`init_*` values" → "`*_init` values". The
  glob keeps its old scope, which may include `ws_init`; listing three names
  would narrow it.
- `spec.md` 4276 → 4324 (§9.3), "`x`/`s`/`m` come from `init_*`
  declarations" → "`x`/`s`/`m` come from the `x_init`, `s_init` and `m_init`
  declarations".
- `spec.md` 10223 → 10271 (§14.1), "fresh run from the `init_*` defaults" →
  "fresh run from the `x_init`, `s_init` and `m_init` defaults". The quote
  marks there are the spec's own; no entry holds the phrase.
- Recommendation: apply all three. §9.3 is a rewritten chapter, so rerun
  `check_bold.jl` and `check_glossary.jl` after.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

**B20. `companions/pid_anti_windup.md` 100–102, the second remedy's wording**
(inbound check's note). "its integrator splits the stages by construction,
which is [§5.4]'s second remedy for free" can be read as the two-stage
split, which is now the first rung. The sentence means the component split.
- Old: "because its integrator splits the stages by construction, which is
  [§5.4][s5-4]'s second remedy for free."
- New: "because its integrator is a component of its own by construction,
  which is [§5.4][s5-4]'s second remedy, the component split, for free."
- Recommendation: apply, with A7 and A19 in the same file.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

**B21. Old-style bold with no D-citation on chapter 5's rulings in the
appendices.** Appendix B 11805–11806 bolds the handler return law (unit B), and
Appendix A bolds "**Same-tick reset consumption**" (11648) and "**A
continuous component's state reset is an event**" (11656) (unit D).
- Recommendation: no edit now. They belong to the appendices' own rewrite,
  as survey part B proposes.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

## C. For the owner

Rulings that no entry records, from survey part E ("Rulings with no entry at
all") and the units' reports, and the two escalations already in
`escalations.md`. Each stays stated plain and uncited until the owner rules
(recipe step 8: ratifying one is a design decision). None blocks landing.
The items other files rely on come first.

**C1. Stage-2 conservatism** (survey rows 54 and 98; base 896 and
1107–1111). "Every stage-2 output is presumed dependent on every wired
input", and so "An input consumed only by `x_deriv` … still creates a
feedthrough edge". Relied on by the glossary's *feedthrough* (base
12852–12855) and by `pid_anti_windup.md` 90–91, 293–294 and 323–324.
- D-006's Position (base log 430–431) rules "Strict two-stage structural
  feedthrough (state decoder `h_x` + all-inputs `h_xu`)". Unit C cites it
  for "`y_direct` receives all wired inputs". It does not say "presumed
  dependent".
- Recommendation: rule that D-006's "structural feedthrough … all-inputs"
  carries the presumption, and cite D-006 at both sentences. If the owner
  reads it as weaker, ratify a new entry.
- **Status.** to the owner: goes to `pending.md` at close, with the recommendation above.

**C2. Evaluating the RHS means running the sweep, with no incremental
`x_deriv`-only re-evaluation** (row 59; base 915–916). Relied on by the
glossary (base 12943–12945) and restated by §10.3 and §10.4. D-194's
Rationale (base log 7045–7046) says "evaluating the RHS means running the
sweep ([§5.3])", as a premise it takes from §5.3, not as a ruling. No entry
says anything of incremental re-evaluation.
- Recommendation: ratify one entry stating both halves. Restating D-194's
  premise under lesson 17 would make §5.3 the source of its own ruling.
- **Status.** to the owner: goes to `pending.md` at close, with the recommendation above.

**C3. The unit delay's tier caveat, and that the diagnostic states it** (row
102; base 1122–1126; R12's sentence; §13.7 base 10036–10042). §13.7 says the
caveat "must be stated wherever the remedy is recommended" and that "The
diagnostic ([§5.5]) therefore says so". §5.5 now says the diagnostic states
it, pointing at §13.7. Each place cites only the other, and no entry records
the claim (the inbound check's lesson 16 note). D-312, the `UnitDelay`
entry, does not state it. The ground is `src`: `_BREAK_CYCLE`
(`src/diagnostics.jl` 929–931 at `b08afca`) renders "which moves the signal
onto the discrete tier and inserts a Δt_base-scale zero-order hold (§5.5)".
- Recommendation: ratify one entry: the unit delay is a modeling decision
  that moves the signal onto the discrete tier, and every place that
  recommends it, the cycle diagnostic included, says so. Cite it in §5.5 and
  §13.7.
- **Status.** to the owner: goes to `pending.md` at close, with the recommendation above.

**C4. Stages are discovered by method existence, and stage membership is a
partition of the declared ports** (row 28; base 788–789; unit B's open
question 2). The partition half is in D-252's Position (base log
9618–9622): "A declared output is produced by stage 1 or by stage 2, and by
nothing else", with `DeclaredNotProduced` and `ProducedByTwoStages` for the
two failures. The discovery half is stated only by D-165's Position (base
log 5740), superseded by D-194, whose Position does not restate it. D-194
superseded D-165 over the `w` channel, not over stage discovery.
- Recommendation: cite D-252 at the sentence now (it carries the
  partition). Ratify the discovery half in a new entry, or rule it a
  description of how the build finds `y_state` and `y_direct` that needs no
  entry.
- **Status.** to the owner: goes to `pending.md` at close, with the recommendation above.

**C5. Stage 1 exists when the component has state-derived ports** (row 48;
base 880). D-194 bullet 2 (base log 7021–7023) routes state-derived
intermediates to stage 2 through `y_x`, but no entry states when stage 1
exists.
- Recommendation: rule it a description that follows from D-252's two
  producers (a component without stage-1 ports writes no `y_state`), and
  leave it uncited. No entry.
- **Status.** to the owner: goes to `pending.md` at close, with the recommendation above.

**C6. The three ways to break a loop** (row 101; base 1120–1122): insert
dynamics, insert a unit delay, or restructure. D-005's Position (base log
414) rules "explicit breaks" and names none. `src`'s message names a
different three: "a state, a stage-1 (`y_state`) port, or a `UnitDelay`"
(see C15).
- Recommendation: cite D-005 at "The user breaks the cycle explicitly",
  which its Position carries, and treat the list as teaching. Settle the
  list's wording together with C15.
- **Status.** to the owner: goes to `pending.md` at close, with the recommendation above.

**C7. Algebraic balances inside a component stay legal** (row 104; base
1129–1131). D-005 rules on loops among components; no entry scopes it.
- Recommendation: ratify with C3 in one entry on §5.5's policy, or rule it
  a scope note on D-005 that needs no entry. Low stakes.
- **Status.** to the owner: goes to `pending.md` at close, with the recommendation above.

**C8. The tracer's two modes and their properties** (rows 118 and 119; base
1195–1204). D-012's Position names "Set-propagation tracers (global +
sampled-local)" only. May-depend semantics, exactness in one evaluation,
the branch-free requirement and "Its only misses are untaken branches" have
no entry. D-245's Rejected list (base log 9257–9258) leans on "the sampled
miss [§5.6] documents".
- Recommendation: ratify one entry for C8 to C10, the tracer's mechanism
  and limits, since a reader weighing a dead hop relies on them.
- **Status.** to the owner: goes to `pending.md` at close, with the recommendation above.

**C9. What tracing seeds and never touches, and the value-severing blind
spot** (row 120; base 1206–1213). No entry.
- Recommendation: with C8.
- **Status.** to the owner: goes to `pending.md` at close, with the recommendation above.

**C10. Dual-cleanliness in CI effectively guarantees traceability** (row
121; base 1216–1217). §7.2 states the CI `T = Dual` sweep (unit F's pointer).
No entry ties it to traceability.
- Recommendation: with C8.
- **Status.** to the owner: goes to `pending.md` at close, with the recommendation above.

**C11. `BundleFieldError`'s three classifications** (row 19; base 759–760):
undeclared store, wrong-tier fact, name illegal for the function family.
D-248 bullet 4 names the kind only. Appendix C (base 12435–12439) lists the
same three in the kind's payload.
- Recommendation: rule it a payload description, which Appendix C holds,
  and leave it without an entry.
- **Status.** to the owner: goes to `pending.md` at close, with the recommendation above.

**C12. The dead hop is a separate payload field rather than dotted onto the
path** (row 96; base 1098–1100, cited to §8.6 and §13.2). D-245 bullet 2
lists dead hops but does not set their form; Appendix C (base 12406–12410)
gives the payload as "every dead hop (member, input face, output port)".
- Recommendation: as C11, a payload description with no entry.
- **Status.** to the owner: goes to `pending.md` at close, with the recommendation above.

**C13. "Tracer activation" names the global variant** (row 110; base
1173–1174, cited to D-012 and §9.4). A naming, stated in §9.4 too.
- Recommendation: no entry. Vocabulary is the glossary's business.
- **Status.** to the owner: goes to `pending.md` at close, with the recommendation above.

**C14. Why `x_projection` stays positional: "nothing to select"** (unit A,
A-026; base 724–725). D-074's Position rules the positional shape; the
reason is recorded nowhere.
- Recommendation: no action. A reason needs no ruling, and the ruling it
  supports is cited.
- **Status.** to the owner: goes to `pending.md` at close, with the recommendation above.

### Escalations already in `escalations.md`

**C15. The quoted cycle diagnostics differ from `src`'s text** (survey F9).
§5.4 (base 1097–1098) quotes "cycle through `systems/aero` is artificial at
port level — split the component, or narrow the neighbor's contract", and
§5.6 (base 1137–1138) says a genuine cycle gets "insert a state".
`src/diagnostics.jl` 920–948 at `b08afca` renders "algebraic loop among
…: … — artificial at port level: …; split `m`, or narrow the neighbor's
contract if `f` is consumed only in a fallback branch (§5.4)", and for a real
loop "break it with a state, a stage-1 (`y_state`) port, or a `UnitDelay`,
which moves the signal onto the discrete tier and inserts a Δt_base-scale
zero-order hold (§5.5)". `src` agrees with the spec in substance and says
more.
- Recommendation: conform the spec's quotes to `src`'s wording in a later
  pass, since a quoted message that the build never prints reads as a
  verbatim promise. Until then, one `pending.md` bullet under "Deviations"
  at chapter close (recipe step 9). Ruling the quotes illustrative instead
  would need a convention in `spec_style.md`, which keeps quoted diagnostics
  verbatim today.
- **Status.** to the owner: goes to `pending.md` at close, with the recommendation above.

**C16. §5.2's example diagnostic differs from `src`'s text** (unit B; same
class as C15). Base 752–754 quotes "`x_deriv` of `Foo` destructures `m`, but
`Foo` declares no `m_init`". The survey's run of `src`
(`scratch_survey/run_bundle.jl`) printed "`x_deriv` destructures `m`, but
the root component declares no `m_init` — the bundle carries {x, y, t}
(§5.2)".
- Recommendation: as C15. Here `src` names the component by its path
  rather than its type; that difference is a design question, so the owner
  rules which one the diagnostic shows.
- **Status.** to the owner: goes to `pending.md` at close, with the recommendation above.

## Z. Chapter-internal leftovers outside the three groups

Unruled items inside chapter 5 that R1 to R20 do not cover.

**Z1. Unit D dropped the blockquote's bold** ("[ sweep → guards → handlers
]", base 946), against the brief's "carry … the blockquote as written".
The bold has no D-citation, so `check_bold.jl` refuses it once chapter 5
joins `REWRITTEN`; §10.6's final-form blockquote (base 6189–6190) has none.
Unit D's verifier agreed.
- Recommendation: accept the change.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

**Z2. §5.4's title says "the escape hatch"**, which its text never uses
(unit E's open question 1; chapter pass finding 1, optional). D-140's
Position calls the ladder "[§5.4]'s escape hatch" (base log 4629).
- Recommendation: keep the title. Its words are D-140's, and a retitle also
  moves the Contents entry. The roadmap may say "artificial loops and their
  remedy ladder", as chapter pass finding 1 offers.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

**Z3. "owned by the reset component"** (unit D's open question 5; base
1008–1010). It means the component whose state is reset (D-141 Rationale,
base log 4716–4717: "the state's owner is the reset's only possible home").
- Recommendation: keep, as unit D did.
- **Status.** accepted as recommended (orchestrator, 2026-10-12). Reason: each claim checked at its source by the consolidator, spot-checked by the orchestrator; the track-2 verifier checks every log edit.

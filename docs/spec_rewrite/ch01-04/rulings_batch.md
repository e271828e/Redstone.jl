# Chapters 1 to 4: the rulings batch (step 6)

Merged from `brief.md` (R1 to R21, already ruled), survey parts D and E,
every `units/*/rulings.md` and `units/*/verify.md`, `chapter_pass.md`,
`inbound_check.md`, `inbound_check.tsv`, `escalations.md` and
`docs/design/pending.md` at the base. Only items that R1 to R21 do not settle
are here. Each claim was checked at its source line.

Line conventions:

- "Base" lines are `spec.md` or `decisions.md` at `d3af35a`, read through
  `scratch_survey/`. No commit since `d3af35a` touches `docs/design/`
  (`git diff --stat d3af35a HEAD -- docs/design` is empty), so base lines
  are the committed lines too. Recount against the working tree before
  editing (recipe step 7): other sessions may edit it.
- Companion lines are at `d3af35a`, read with `git show`.
- The units were being edited while this batch was written, so new text is
  quoted by section and words, not by `chapter_new.md` line.
- "Row N" is a data row of `inbound_check.tsv`, numbered from 1 after the
  header.

Counts: group A 19 items (5 blocking, 10 to land, 4 closed or moved),
group B 12 items (3 blocking, 9 after landing, three new entries D-361 to
D-363), group C 16 items (C3 is the escalation E1, C15 is closed, and C11
and C16 join existing `pending.md` items).
"Blocking" in A means the rewrite or a ruling made the citing text wrong, or
a ruling orders the edit at landing. In B it means a Spec field the landing
updates (recipe step 7.3). Nothing in C blocks landing: each sentence stays
plain and uncited until the owner rules.

Each item ends with a **Status** line for the orchestrator.

## A. Landing edits outside the run (recipe step 7.1)

Every non-OK row of `inbound_check.tsv` (29 rows) is here, either as an
edit, as closed, or as moved to group B (the log rows). Old and new text are
given as one span; the old span wraps over the lines named. Apply these
before the splice, while the line numbers still match.

### Blocking: the rewrite or a ruling requires these

**A1. Row 9, `spec.md` 1091 (§5.3), R9 (ii).** "only handlers write `x`"
cites §3.1, which says a handler "may reset" `x`, never "only". New §3.4
states it: "Guard-driven handlers are the sole resetters of continuous state
([D-141])". R7's new §3.1 clause cites §5.3, so until this lands §5.3 and
§3.1 point at each other (lesson 16).
- Old: "no input spelling at all, because only handlers write `x` ([§3.1][s3-1])."
- New: "no input spelling at all, because only handlers write `x` ([§3.4][s3-4])."
- Recommendation: apply, as R9 (ii) orders.
- **Status.** open.

**A2. Row 234, `companions/flight_case_studies.md` 187.** The same sentence
with the same citation. R9 (ii) names only the spec line; unit C and the
inbound check both found this copy.
- Old: "input spelling at all, because only handlers write `x` ([§3.1][s3-1])."
- New: "input spelling at all, because only handlers write `x` ([§3.4][s3-4])."
- Recommendation: apply, extending R9 (ii) to it. The companion already
  defines `[s3-4]` (its line 445).
- **Status.** open.

**A3. `spec.md` 5492–5493 (§10.4, "The trigger"), R17.** The bold restates
D-082's edge ruling, which new §2.1 bolds; 5498 calls it "the directional
edge of [§2.1]".
- Old: "**A localized event triggers when its predicate was
  not-[holding](#g-edge-semantics) at tₙ's [quiescence](#g-quiescence) and is
  holding at tₙ₊₁** ([D-082][d-082])."
- New: the same sentence with the two `**` pairs removed. The citation and
  both links stay.
- Recommendation: apply, as R17 orders. Rerun `check_bold.jl` after it.
- **Status.** open.

**A4. Row 51, `spec.md` 10664 (§14.4).** F7 changes §3.2 to "a NamedTuple
whose fields are each isbits or a `Symbol`". The citing sentence still says
"any isbits value ([§3.2])". §7.3 base 1880 and D-231's Position (base log
8689–8690) admit a `Symbol` field, and §14.4 base 10662 already reads a
`Symbol` leaf whole.
- Old: "A discrete `s` field is any isbits value ([§3.2][s3-2]), and"
- New: "A discrete `s` field is isbits or a `Symbol` ([§3.2][s3-2]), and"
- Recommendation: apply now, since this landing is what makes the citation
  read against its target. Then delete the README's chapter 14 bullet "§14.4
  says a discrete `s` field "is any isbits value"" (README base 66–67) in
  the same commit. The README's two chapter 3 bullets (base 48–53) retire at
  step 9, as R1 and F7 settle them.
- **Status.** open.

**A5. Row 66, `spec.md` 12850–12852 (glossary *component*).** Unit C's §3
lead now says "three categories of component", so as to use neither glossary
sense of *class*. The glossary still says "the non-assembly classes", and in
*class*'s own glossary sense (primitive against assembly) there is only one
non-assembly class.
- Old: ""Primitive" and "leaf" are used interchangeably for the
  non-assembly classes ([§3][s3])."
- New: ""Primitive" and "leaf" are used interchangeably for the two leaf
  categories ([§3][s3])."
- Recommendation: apply, after checking that unit C's final §3 lead still
  says "categories" (it does at the time of writing, `units/C/new.md` 3).
- **Status.** open.

### To land: wrong before the rewrite

**A6. Row 28, `spec.md` 2932–2935 (§8.2).** The sentence cites §3.2 for
"the event system is continuous-side only". §3.2 implies it by omission and
never states it; §5.2 base 714 states it ("event system (continuous side
only)"), and so does D-112's Position (base log 3446–3447).
- Old: "continuous-side only ([§5.2][s5-2], [§3.2][s3-2], [§14.1][s14-1])"
- New: "continuous-side only ([§5.2][s5-2], [§14.1][s14-1])"
- Recommendation: apply. The alternative, a new §3.2 sentence "A discrete
  component declares no events ([D-112])", adds a claim to the chapter for
  the sake of an inbound pointer; not recommended. D-112's Spec field keeps
  §3.2 (B3).
- **Status.** open.

**A7. Row 55, `spec.md` 11785–11786 (Appendix A).** §4.3 does not state one
home per datum (§5.2 does; §3.4 restates it citing §5.2). §4.3 does support
"never transported ones": a face aliases an interior port and never creates
an endpoint.
- Old: "- **One home per datum** ([§5.2][s5-2], [§4.3][s4-3]). The signal
  table holds *produced* signals only, never transported ones."
- New: "- **One home per datum** ([§5.2][s5-2]). The signal table holds
  *produced* signals only, never transported ones ([§4.3][s4-3])."
- Recommendation: apply.
- **Status.** open.

**A8. Row 65, `spec.md` 12847–12848 (glossary *class*).** "class split"
occurs in neither the old nor the new §3.4. New §3.4 says "two leaf classes"
and "the two-class taxonomy".
- Old: "("class split", "two leaf classes", [§3.4][s3-4])"
- New: "("two-class taxonomy", "two leaf classes", [§3.4][s3-4])"
- Recommendation: apply. `docs/design/tools/spec_style.md` base 64 names
  the same trap with the same stale phrase ("§3.4's "class split" and "two
  leaf classes""); change "class split" to "two-class taxonomy" there in the
  same commit.
- **Status.** open.

**A9. Row 75, `spec.md` 13051–13052 (glossary *signal table*).** §4.1 says
nothing of the table being integrator scratch within a step; §10.3 does. §4.1
links *signal table* back to this entry, so the pointer is circular.
- Old: "integrator scratch ([§4.1][s4-1], [§10.3][s10-3])."
- New: "integrator scratch ([§10.3][s10-3])."
- Recommendation: apply.
- **Status.** open.

**A10. Row 79, `spec.md` 13102–13103 (glossary *flow / RHS*).** §3.1 does not
state that there is no `x_deriv`-only re-evaluation; §5.3 does. §3.1 links
*flow* back to this entry.
- Old: "incremental `x_deriv`-only re-evaluation ([§3.1][s3-1],
  [§5.3][s5-3])."
- New: "incremental `x_deriv`-only re-evaluation ([§5.3][s5-3])."
- Recommendation: apply. This fixes a pointer only. Whether the claim needs
  an entry is the owner's open item ("evaluating the RHS means running the
  sweep", `pending.md` base 105), which this batch does not re-raise.
- **Status.** open.

**A11. Row 85, `spec.md` 13882–13885 (glossary *decision entry*).** §1 says
entry numbers are stable and never reused, before and after the rewrite. The
`superseded → D-nnn` Status-line rule is in `decisions.md`'s preamble (base
log 13–15) and `decisions_style.md`, never in §1.
- Old: "Entry numbers are stable and never reused. Each entry states its
  *current* position, and a superseded one is marked `superseded → D-nnn` in
  its Status line rather than rewritten ([§1][s1])."
- New: "Entry numbers are stable and never reused ([§1][s1]). Each entry
  states its *current* position, and a superseded one is marked
  `superseded → D-nnn` in its Status line rather than rewritten."
- Recommendation: apply. The second sentence describes the log's own
  format, which the entry's first sentence already names.
- **Status.** open.

**A12. Row 87, `spec.md` 13892–13895 (glossary *guarded addition*).** Neither
§1 says "recorded with its shape so adoption stays additive". New §2.1's
D-180 gloss says it, but that gloss restates this entry and links back, so a
retarget to §2.1 would be circular. (The chapter pass's finding 1 replaces
§2.1's gloss with the standard one in any case.)
- Old: "recorded with its shape so adoption stays additive ([§1][s1]; e.g.
  field-addressed staging, [§4.3][s4-3]; mid-run reader attach,
  [§11.3][s11-3])."
- New: "recorded with its shape so adoption stays additive (e.g.
  field-addressed staging, [§4.3][s4-3]; mid-run reader attach,
  [§11.3][s11-3])."
- Recommendation: apply. The clause itself is C10, and the field-addressed
  staging example is C6.
- **Status.** open.

**A13. Row 45, `spec.md` 6724–6725 (§11.2).** §4.1 states immutability and
"no aliasing, ever", nothing of internal sharing. Sharing immutable data is
not aliasing, so the claim is not wrong, only uncarried by its citation.
- Old: "Snapshots are immutable object graphs with internal sharing
  ([§4.1][s4-1]),"
- New: "Snapshots are immutable object graphs ([§4.1][s4-1]) with internal
  sharing,"
- Recommendation: apply. It moves the citation onto the word it carries and
  changes no claim. (The inbound check's wording, "that may share data
  internally", weakens "with internal sharing"; not recommended.)
- **Status.** open.

**A14. Row 233, `companions/flight_case_studies.md` 83–85.** The
decomposition of `f_step!` into boundary-detected events is §2.2's ("cover
engine phase transitions and the stall hysteresis latch"), and the mixed
predicate is §10.4's (base 5446, "A mixed predicate combines `Bool` factors
with a continuous one").
- Old: "events with mixed predicate/threshold guards ([§2.1][s2-1])."
- New: "events with mixed predicate/threshold guards ([§2.2][s2-2],
  [§10.4][s10-4])."
- Recommendation: apply. `linkify.jl` adds the two missing link
  definitions (the companion is on its roster).
- **Status.** open.

**A15. Row 242, `companions/localization_validation_walkthrough.md` 147.**
§2.1 only names "the exactness result that motivates the `Bool` form" and
points at §10.4, which states it in bold (base 5438, "For a guard that reads
only `u` and `m`, boundary detection is exact", [D-179], [D-290]).
- Old: "the discrete-driven exactness doctrine ([§2.1][s2-1], [D-179][d-179])"
- New: "the discrete-driven exactness doctrine ([§10.4][s10-4], [D-179][d-179])"
- Recommendation: apply. The companion defines `[s10-4]` (its line 187).
- **Status.** open.

### Closed or moved: no landing edit

**A16. Row 22, `spec.md` 2177–2178 (§8.1).** "The debugging, tooling and
comprehension criterion ([§1][s1]) decides it." R2 kept those words
verbatim in §1's "Rigor and error locality" bullet ("so debugging, tooling
and comprehension work on the language's own terms") so that this quote
lands. The criterion's own name differs, as it did before the rewrite.
- Recommendation: close. The inbound check's optional rewording of §8.1 is
  not needed.
- **Status.** open.

**A17. Row 128, `decisions.md` 4437 (D-137 Rationale).** "snapshots are
immutable object graphs with internal sharing ([§4.1][s4-1], …)". §4.1 says
nothing of sharing; sharing immutable data is not aliasing, so the
Rationale is not wrong. The fix is none: a Rationale keeps its day's wording
(`decisions_style.md` rule 1), as chapter 5's batch closed its A25 to A27.
- Recommendation: close.
- **Status.** open.

**A18. Row 230, `companions/event_visibility_walkthrough.md` 19–21.** "A
signal-table cell does not hold bytes that get mutated in place — it holds a
*reference* to an immutable value ([§4.1][s4-1], [§7][s7])." §4.1 states
immutable values, typically isbits, and the spec nowhere says a cell holds a
reference (grep of "cell" near "reference", "Ref" or "pointer" over the base
spec: only base 619, a `Ref`'s own box). The companion's whole section 1
builds on the reference picture: its heading "cells hold references to
immutable values" and its code comments ("cell → ref to the value 24.0").
Its conclusion, that an overwrite leaves the value a reader already loaded
untouched, holds under value semantics too.
- Proposal: no edit at landing. One sentence cannot fix the section, and
  the inbound check's wording ("A cell's value is immutable; writing a cell
  replaces it with a new value") would contradict the heading and the code
  comments that follow.
- Recommendation: record it at step 9 as a companion item in `pending.md`,
  beside the readability rewrite's bullet: section 1 of
  `event_visibility_walkthrough.md` pictures a cell as a reference, which
  the spec does not say. Companions are not normative, and §1 says the spec
  wins where they disagree.
- **Status.** open.

**A19. Log rows moved to group B.** Rows 94, 95, 103, 108, 114, 126, 127 and
138 are Spec fields (B1 to B3). Rows 136, 141 and 142 are D-141's text (B8).
Row 197 is D-276's annotation (B9).
- Recommendation: rule them in group B.
- **Status.** open.

Noted, not proposed: Appendix A base 11794 says "re-creating the drift
class", the wording unit G dropped from §4.4 for the reserved word *class*.
It is not an inbound citation and claims nothing wrong; Appendix A's own
rewrite takes it.

## B. Track 2: log repairs (recipe step 8)

New entries take D-361 onward; D-344 to D-360 are reserved for the owner's
own rulings. A new entry restates only what an existing entry records
(lesson 17). A ruling no entry records, or whose only source points back at
the spec, is in group C. Positions are quoted at their base log lines.

### Blocking: Spec fields the landing updates (recipe step 7.3)

Checked by script: every entry the assembled `chapter_new.md` cites, per
section, against its Spec field at the base (no entry the old chapter cited
was dropped). The rows split by whether the run states the entry's ruling
(bold, or the only statement of it) or only points at a ruling another
section states. Insert each section in the field's own order: sorted fields
take it in sorted place; D-141's unsorted field takes it beside its
neighbours.

**B1. Spec fields to extend: the run states the ruling.**

| entry | base log line | field now | field after | what the run states |
|---|---|---|---|---|
| D-001 | 363 | §2.2 | §2, §2.1, §2.2 | §2's bold (the formalism) and projection bold, §2.1's lead bold and the edge bolds beside D-082 |
| D-002 | none (Position 376) | no field | §2 | §2's lead bold, beside D-001. Insert the field after the Position |
| D-003 | none (Position 389–390) | no field | §3, §3.1 | §3's taxonomy bold and §3.1's mode-factorings bold. Insert after the Position |
| D-019 | 721 | §5.2, §10.5 | §3.3, §5.2, §10.5 | §3.3's "flattened away for ordering" and rate scopes (D-019's "assemblies virtual for execution, rate scopes for declaration", log 716–717). Survey part D |
| D-020 | 762 | §2.2, §3.1, §5.3, §10.6 | §2.2, §3.1, §3.4, §5.3, §10.6 | §3.4's deferred decode (row 94) |
| D-034 | 1111 | §5.4, §7.4, §8.3 | §4.2, §5.4, §7.4, §8.3 | §4.2's "The output contract *is* the public interface" and the undeclared-return error (Position log 1106–1109, "declared = public … undeclared stage-return fields = build error") |
| D-045 | 1414 | §11.7 | §4.3, §11.7 | §4.3's write-side bold. Its own Rejected item names §4.3 (log 1436–1438) |
| D-080 | 2463 | §10.4, §10.7 | §2.1, §10.4, §10.7 | §2.1's pace-independence sentence |
| D-082 | 2516 | §10.4, §10.6, §14.5 | §2.1, §10.4, §10.6, §14.5 | §2.1's predicate and edge bolds, their home (R17) |
| D-141 | 4740 | §2.1, §3.1, §3.3, §10.6, §8.5, §13.7, §5.3, Appendix A | §2.1, §2.2, §3.1, §3.3, §3.4, §10.6, §8.5, §13.7, §5.3, Appendix A | §2.2's touchdown edge (F1) and §3.4's sole resetters (row 138) |
| D-231 | 8695 | §3.2, §7.3, §8.2, §9.1, Appendix C, Appendix D | §2.2, §3.2, §7.3, §8.2, §9.1, Appendix C, Appendix D | §2.2's RNG values in `s` (Position log 8692–8693; row 177) |
| D-247 | 9380 | §7.1, §8.2, §9.1, Appendix C | §3.1, §3.2, §7.1, §8.2, §9.1, Appendix C | F7's "a NamedTuple …" in §3.1 and §3.2 (Position log 9373–9374). Survey part D |
| D-263 | 10451 | §4.3, §6.1, … Appendix D | §3.4, §4.3, §6.1, … Appendix D | §3.4's "They are" exclusive, the store as tier marker (bullet 5, log 10442–10445; row 190) |
| D-296 | 12562 | §8.2, §14.10 | §4.4, §8.2, §14.10 | §4.4's structural substitutability (bullet 1, log 12551–12552, "as [§4.4]'s field handles use them") |

- Recommendation: apply at landing (recipe step 7.3). Rerun the check
  after the ruled and editorial fixes, since a fix can add or move a
  citation.
- **Status.** open.

**B2. Spec fields the run only points into.** These citations sit on a
restatement of a ruling another section states and bolds, or on a pointer.
Chapter 5's B1 added such sections too.

| entry | base log line | field now | field after | site |
|---|---|---|---|---|
| D-018 | 698 | §10.4, §10.6 | §2.1, §10.4, §10.6 | §2.1 "by root-finding ([D-018])", beside "[§10.4] gives the mechanics" |
| D-019 | 721 | (B1's) | adds §2, §3.2 | §2 and §3.2, "held zero-order between ticks" |
| D-022 | 815 | §11.1 | §2, §11.1 | §2's external-inputs bullet, "under the staging rules of [§11]" |
| D-090 | 2754 | §5.2, §9.5 | §3.1, §5.2, §9.5 | §3.1, "A handler may update `m` and may reset the component's own `x`" |
| D-094 | 2855 | §7.1, §8.2, §10.4, §14.3 | §3.1, §7.1, §8.2, §10.4, §14.3 | §3.1's `x` bullet (F7) |
| D-154 | 5465 | §5.3, §10.4, §10.6 | §3.1, §5.3, §10.4, §10.6 | §3.1, guard and handler read the fresh table |
| D-231 | 8695 | (B1's) | adds §4.1 | §4.1, "Signals may reference bulk data … read-only for the duration of the run" (but see C2) |
| D-249 | 9506 | §8.2, §8.5, … Appendix C | §3.2, §8.2, … | §3.2's `m` bold, beside D-231's annotation |
| D-040 | 1285 | §8.6 | §4.2, §8.6 | §4.2's path example |

- Recommendation: apply, for parity with chapter 5's practice, except
  D-231's §4.1 until C2 is ruled. Low stakes either way. Do not add §4.1 to
  D-243 (9208): its only words for the §4.1 claim are a Rationale that points
  back at §4.1 (R18).
- **Status.** open.

**B3. Spec fields checked and left, and one correction.**
- D-067 (base log 2006) lists §3.4, which holds nothing of boundary zero or
  interval alignment, before or after the rewrite (row 108; grep of
  "boundary zero", "interval align", "boundary-sampl" over the old and new
  chapter: no hit). Proposal: drop §3.4, keeping the field's own order:
  "§10.6, §14.5, §5.3, §8.6". Recommendation: apply; nothing in §3.4 is
  D-067's.
- Kept, under `decisions_style.md` rule 5 and chapter 5's B4 (never resolve
  doubt by deleting): D-020's §2.2 and §3.1 (they hold the footgun and the
  externalized FSMs its Rejected item names; rows 94, 95), D-053's §2.1 (the
  two guard forms its check reads; row 103), D-112's §3.2 (implies by
  omission; row 114), D-137's §4.1 and §4.4 (premises of its Rationale; rows
  126, 127), D-141's §2.1 (its Position names §2.1; row 138), D-123's §3 and
  §3.4 and D-242's §3.4 (word sweeps; survey part D).
- D-180's §2.1 (base log 6571) is now true: R5 put its guarded addition in
  §2.1. Close.
- Recommendation: drop D-067's §3.4; leave the rest.
- **Status.** open.

### After landing: Positions owed

Every ruling below is stated in the new chapter and recorded in some entry's
Rationale, Rejected list or annotation, never in a Position. Each was read at
its log line, and each source entry decided the point itself rather than
citing the spec for it (the test R18 applied; checked in git where in doubt:
D-220's Rationale and §2.1's time and state events landed together in
`f13a584`, and the write-side granularity entered with the C172X periphery
findings in `b1a9060`, the commit D-045 records). Three new entries restate
them in chapter 5's template (D-341 to D-343): a headline naming the
sections, one bullet per ruling, a Rationale naming each bullet's source, and
"None beyond the source entries' lists" as the Rejected field. They use
today's vocabulary, since they are written today (`s` for D-056's and
D-020's `z`, "component" for D-056's "kind"); the source entries keep theirs
(rule 2).

**B4. D-361, the event rulings of §2.1.**

| ruling | source entry, field, base log line | chapter site |
|---|---|---|
| ticks are time events, `StateEvent`s are state events, the criterion is detection against scheduling | D-220 Rationale 8248–8253 | §2.1's time-events bold and paragraph |
| the opposite direction is a second event with the negated guard | D-082 Rationale 2519–2520 | §2.1, "The opposite crossing direction is declared as a second event with the negated guard" |

Proposed entry:

> ### D-361 — Time and state events, and the opposite crossing direction
>
> **Status.** ratified
>
> **Position.** Two event rulings that §2.1 states are fixed here.
>
> - The discrete tier's ticks, declared by `sample_times`, are time events,
>   scheduled because their instants are known in advance. Everything
>   declared through `StateEvent(guard, handler)` is a state event, whose
>   instant is unknown and must be detected. The criterion is detection
>   against scheduling, not which bundle fields a guard reads.
> - The opposite crossing direction is a second event with the negated
>   guard.
>
> **Spec.** §2.1
>
> **Rationale.** Each bullet restates what an existing entry recorded
> outside its Position. The time and state events were recorded in D-220's
> Rationale, and the opposite direction in D-082's.
>
> **Rejected.** None beyond the source entries' lists.

- Recommendation: add.
- **Status.** open.

**B5. D-362, the taxonomy rulings of §3.1, §3.2 and §3.4.**

| ruling | source entry, field, base log line | chapter site |
|---|---|---|
| internal modes enable reset maps | D-003 Rejected 395–396 ("*Strict purity/no modes:* loses reset maps; latch logic becomes wiring ceremony") | §3.1, internal-modes bullet |
| `m` is continuous-only; a discrete component has no mode store | D-231 annotation 8724–8725; D-249 bullet 1, 9493–9496 (`DeclarationOnWrongTier` keeps `init_m`) | §3.2's `m` bold |
| an all-in-one component's halves communicate as siblings; it gains no expressiveness, has costs of its own and hides the sampling interface | D-056 Rejected 1701–1706 | §3.4, the sibling paragraph and the trench-coat paragraph |
| event/tick fixed-point iteration is structurally unnecessary | D-020 Rejected 776–777 | §3.4, "That deferred decode is what makes ticks→events structurally impossible" |
| no `s` view in the flow, no discrete-tier write into `x` | D-056 Rejected 1707–1709 | §3.4, "a discrete-tier write into continuous state, exactly the operation this design forbids" |
| a periodic reset is not an event | D-056 Rejected 1710–1711 | §3.4, "The reset is periodic, not condition-triggered, so events are the wrong mechanism" |

Proposed entry:

> ### D-362 — Reset maps, the continuous-only mode store and the rejected all-in-one component
>
> **Status.** ratified
>
> **Position.** Six taxonomy rulings that §3.1, §3.2 and §3.4 state are
> fixed here.
>
> - Internal modes enable reset maps. Without modes, latch logic becomes
>   wiring ceremony.
> - `m` is continuous-only: a discrete component has no mode store, and
>   `m_init` on a discrete leaf is `DeclarationOnWrongTier`.
> - An all-in-one component, one leaf carrying both tiers' facets, is
>   rejected. Its halves would still communicate through cells, with one
>   home per datum, a sole-reader `s` and no cross-tier state views, so it
>   gains no expressiveness. It costs stage doubling with tier-tagged names,
>   per-port tier vocabulary and facet-conditional obligations, and it hides
>   the sampling interface.
> - Event/tick fixed-point iteration is structurally unnecessary, because
>   `s⁺` stays invisible until the owner's next tick decode.
> - No `s` view in the flow and no discrete-tier write into `x`: either
>   would un-sample the sampled-data semantics, break the held-`s`
>   linearization's exactness and hide the coupling from the table, the
>   trace and the feedthrough graph.
> - A periodic reset is not an event. A time-guard event would hand-roll
>   the tick scheduler and forfeit the harmonic grid and the discrete-bundle
>   `Δt`.
>
> **Spec.** §3.1, §3.2, §3.4
>
> **Rationale.** Each bullet restates what an existing entry recorded
> outside its Position. The reset maps were recorded in D-003's Rejected
> list. The mode store was recorded in D-231's annotation and follows from
> D-249's first bullet. The all-in-one component, the forbidden write into
> `x` and the periodic reset were recorded in D-056's Rejected list, and the
> needless event/tick iteration in D-020's.
>
> **Rejected.** None beyond the source entries' lists.

- Note: the chapter keeps "preserve cohesion" beside "enable reset maps"
  (§3.1), which D-003 does not record; it stays uncited in that clause.
  D-231's annotation cites §3.2 and §8.2 as the rule's homes, not as its
  source, and D-249's first bullet keeps `init_m` among the
  `DeclarationOnWrongTier` declarations, which implies the rule without
  citing the spec for it. So this bullet is not R18's circle. The survey
  (part E) found the same two sources.
- Recommendation: add.
- **Status.** open.

**B6. D-363, the port rulings of §4.1 to §4.4.**

| ruling | source entry, field, base log line | chapter site |
|---|---|---|
| per-cell freshness tied to the producer's schedule position; no monolithic `y` struct | D-004 Rejected 412–414 | §4.1, the freshness bullet, now cited to D-004 |
| the `unlisted` flag is closed | D-034 Rejected 1126–1127 | §4.2, "A presentational *unlisted* flag … is closed ([D-016], [D-034])" |
| bare-struct returns are rejected | D-036 Rejected 1179–1182 | §4.3, "Bare-struct returns are rejected ([D-036])" |
| a field-projection connector is an unbuilt guarded addition | D-036 Rejected 1183–1184 | §4.3, the field-projection sentence |
| a bundled command face is rejected; the port is the periphery's atomic unit on the write side too | D-045 Rejected 1436–1440 | §4.3's write-side bold, and the periphery-atom paragraph (uncited now) |
| bulk-data components owe only reachability of the query math | D-139 Rationale 4587–4589 | §4.4, "For bulk-data components the obligation is only that the query math be reachable as a plain function" |
| pre-sampling is an idiom, not a mechanism; resource injection is rejected | D-008 Rejected 484–485 | §4.4, the pre-sampling paragraph |

Proposed entry:

> ### D-363 — Cell freshness, closed port alternatives, write-side atomicity and bulk-data handles
>
> **Status.** ratified
>
> **Position.** Seven port rulings that §4.1 to §4.4 state are fixed here.
>
> - Each cell's freshness is tied to its producer's position in the
>   execution order. A monolithic per-component `y` struct is rejected,
>   since it could be half-fresh mid-sweep with no way for a reader to tell.
> - A presentational `unlisted` flag, hidden but connectable, is rejected:
>   it pretends privacy without enforcing it.
> - Bare-struct returns with field-splatting are rejected as ambiguous,
>   type-lossy and reflection-hungry.
> - A field-projection connector is a guarded addition, unbuilt.
> - A bundled command face, such as the pilot inputs as one struct port, is
>   rejected: it kills per-field claiming, liveness and the trace tag. The
>   port is the periphery's atomic unit on the write side too.
> - A bulk-data component owes only that the query math be reachable as a
>   plain function. Building its handle outside a build may then cost a
>   resource load, acceptable because condition authoring is design-time
>   code.
> - Pre-sampling is an idiom built on the handle pattern, not a mechanism,
>   since as a mechanism it inverts the dependency at the struts. Resource
>   injection is rejected as a second, invisible composition mechanism.
>
> **Spec.** §4.1, §4.2, §4.3, §4.4
>
> **Rationale.** Each bullet restates what an existing entry recorded
> outside its Position. The freshness was recorded in D-004's Rejected list,
> the `unlisted` flag in D-034's, the bare-struct returns and the
> field-projection connector in D-036's, the bundled command face in
> D-045's, and pre-sampling and resource injection in D-008's. The
> bulk-data obligation was recorded in D-139's Rationale.
>
> **Rejected.** None beyond the source entries' lists.

- Notes. The fifth bullet carries the write-side bold's different-writers
  half only; the cadence half is C8. The last bullet says "rejected", as
  D-008 does; §4.4 keeps "closed for the first cut" (R13). D-276's
  Rejected item on the loose hot field (base log 11649–11651) is not
  restated: it belongs to the owner's open "fan-out is free" item (C16).
- Recommendation: add.
- **Status.** open.

**B7. Not restated: reasons and circles.**
- D-001's Rejected reasons, "*SDEs:* shaping filters suffice" (base log 369)
  and "*`f_step!`:* step-size-dependent semantics" (370). Both are reasons
  for rulings D-001's Position already makes ("no DAE/SDE/per-step hook",
  359–360), and a reason belongs in Rejected. §2.2 cites D-001 at both, as
  units B and R9 (i) record.
- D-004's "no aliasing" and "concurrent reads" (Rejected 410): §4.1 states
  them as consequences of the signal requirement, which is C2.
- D-243's Rationale (9210) for the signal requirement: R18's circle, C2.
- D-141's "an assembly has no dynamics of its own, [§3.3]" (Rejected
  4797–4799): it cites §3.3 for the claim, C12.
- Recommendation: no entry for these.
- **Status.** open.

### After landing: stale annotations and entry text

**B8. D-141's Position and its two §3.1 citations** (rows 136, 141, 142).
- The Position (base log 4729) says "[§3.1], [§2.1] and [§13.7] are
  unchanged". After R7, §3.1 states D-141's commanded-reset rule and cites
  D-141, and after F1 §2.2 states the touchdown edge.
- The Rationale (4747–4748, "[§3.1]'s immutable stage views") and the
  Rejected list (4793, "*Relaxing [§3.1]'s immutable views*") cite §3.1 for
  something §3.1 never said, at D-141's own commit too (`0a0751e`,
  `framework_spec.md` §3.1: no "immutable" or "view"). The content is
  §7.1's: "There are no aliased mutable views" and "State fields arrive …
  immutable" (base 1773–1778).
- Proposal: one annotation after the Rationale paragraph (ending base log
  4771), before **Rejected.** (4773): "Annotation (date of landing): §3.1
  now states the commanded-reset rule above and §2.2 the gear's touchdown
  edge, so "unchanged" describes their state when this entry was ratified.
  The immutable stage views cited to §3.1 here and in the Rejected list are
  §7.1's."
- Recommendation: apply (rule 1: annotate, never rewrite). Retargeting the
  two citations under rule 2's citation exception is not recommended: this
  is a miscitation, not a renumbering.
- **Status.** open.

**B9. D-276's annotation on `s` fields** (row 197; base log 11601–11605).
The 2026-09-30 annotation reads "a discrete `s` field is any isbits value
([§3.2])". D-231's Position (8689–8690) admitted a `Symbol` field before it
was written, and F7 now puts "isbits or a `Symbol`" in §3.2.
- Old: "a discrete `s` field is any isbits value ([§3.2][s3-2]), and"
- New: "a discrete `s` field is isbits or a `Symbol` ([§3.2][s3-2]), and"
- Recommendation: apply, in the commit that lands A4. An annotation is a
  later note on what stands, not the historical record, so correcting it
  rewrites no history (chapter 5's B13).
- **Status.** open.

**B10. D-123's Rationale on the "kind" stragglers** (base log 3827). It
records the component-sense "kind" residue in §3 as closed, which was false
while §4.3 said "kind-blind". F9's "class-blind" makes it true.
- Recommendation: close, no edit.
- **Status.** open.

**B11. "the silent drift that [§5.3] exists to kill"** (§4.4, old 636–637;
D-139's Position, base log 4582–4583; unit G's correction 1, which proposes
"the one [§5.3] warns of"). Chapter 5 ruled this phrase already: its batch
closed the same rows (its A21 to A24, `git show
ffd659f:docs/spec_rewrite/ch05/rulings_batch.md`) once its R20 put "Computing
a law twice invites drift, an edited law in one place and a stale copy in
the other" in §5.3, which the base holds (945–948). Unit G has already
dropped "class" from the spec sentence.
- Recommendation: close, no edit, in the spec and the log (lesson 18).
- **Status.** open.

### After landing: entries the chapter cites for claims their Position does not carry

**B12. Cite D-361 to D-363 beside their source entries, and D-308 at §3.1**
(recipe step 8, last step). After the three entries land, add the new entry
beside the existing citation at each site:
- §2.1, to D-361: the time-events bold (D-220) and the opposite-direction
  sentence (D-082).
- §3.1 and §3.2, to D-362: the internal-modes bullet (D-003) and the `m`
  bold (D-231, D-249).
- §3.4, to D-362: the sibling sentence and the trench-coat sentence
  (D-056), the deferred-decode sentence (D-020), and the two reset
  sentences (D-056).
- §4.1 to §4.4, to D-363: the freshness bullet (D-004), the `unlisted`
  sentence (D-016, D-034), "Bare-struct returns are rejected" and the
  field-projection sentence (D-036), the write-side bold (D-045), the
  bulk-data sentence (D-139) and the pre-sampling paragraph (D-008). The
  periphery-atom paragraph ("The port is the atomic unit of the entire
  periphery"), uncited now, takes D-363 and stays plain (R6).
- §3.1's mode-variables bullet, "piecewise-constant values (enums, integers,
  flags)", takes D-308, whose Position bullet 1 carries it (base log 12966,
  "A continuous component's `Int`s, enums and `Bool`s belong in its modes").
  Survey part E listed it and the rewrite left it uncited. D-308's Spec
  (12969) then gains §3.1: "§3.1, §7.1, §7.3".

Two citations stay weak by design: D-231 at §2.2's RNG sentence carries
"RNG state lives in `s`" but not the replay guarantee (C9), and D-090 at
§3.1 carries the handler's returns but not "own" (verifier C accepted it).
- Recommendation: apply after B4 to B6 land, with `check_bold.jl` rerun,
  since three bolds (time events, `m`, write side) gain a Position citation.
- **Status.** open.

## C. For the owner

Rulings no entry records, or whose only source points back at the spec,
from survey part E ("Rulings with no entry at all"), R7, R8, R18 and R19,
the units' open questions that change a claim, and the escalation in
`escalations.md`. Each sentence stays as the rewrite leaves it, plain and
uncited for the point in question, until the owner rules (recipe step 8:
ratifying one is a design decision). An entry the owner ratifies takes a
number from D-344 to D-360. None blocks landing. Items other text relies on
come first. None re-raises an item of `pending.md` at the base: C11 and C16
join existing items there.

**C1. "Every component provides exactly two output stages"** (R19; chapter
pass 22; unit E open question 1). The claim stands in four places: §4.1's
gloss on `y_state`/`y_direct` (base 444–445, which R19 restores), §5.2's bold
(base 696, [D-006]), §5.4's gloss on the two-stage split (base 1110–1111),
and the glossary's *stage function* (base 12951–12952). It is untrue of an
assembly. §3.3 calls an assembly pure composition with no dynamics of its
own, and §8.5 counts "any stage" among the leaf declarations (base
3092–3095) and makes `local_wires` plus any leaf declaration a build error,
`ClassMixed` (base 3103). D-006's Position (base log 436–437) rules
"Strict two-stage structural feedthrough" and says nothing of assemblies.
- Proposal: "Every leaf provides exactly two output stages" (or "every
  primitive"; the glossary uses the two interchangeably) at all four
  places, citing D-006 where it is cited now.
- Recommendation: rule it a wording correction under D-006 (lesson 19,
  every instance at once), needing no new entry, since §8.5's class rule
  already excludes stages from assemblies.
- **Status.** open.

**C2. "The signal requirement is immutability plus frozen references"**
(R18; chapter pass 21; survey part E item 7; §4.1, old 461–462). No entry
rules it. D-243's Rationale (base log 9210) says "[§4.1] requires of a port
value immutability plus frozen references", and D-231's Position (8691–8692)
says "The frozen-reference latitude of [§4.1] stays with signals": both take
§4.1 as the authority. D-004's Position (403), "Immutable value signals in a
typed signal table", carries the immutability and not the frozen-reference
latitude. The sentence dates from the first design checkpoint (`b4d8f5f`,
2026-07-12). The same circle reaches §4.1's next sentence, "Signals may
reference bulk data … provided that data is read-only for the duration of
the run", which the rewrite cites to D-231.
- Recommendation: ratify one entry: a port value is immutable, and any data
  it references is frozen for the duration of the run, so isbits is the
  common case and not the rule. Cite it at §4.1's two sentences and beside
  D-231 wherever §7.3 states the latitude. C3 depends on it.
- **Status.** open.

**C3. Escalation E1: mutable caches "in the consumer's state"** (R8;
survey F11 and q8; `escalations.md` E1; unit G open question 2). §4.4's
bullet ends "Caches belong in the consumer's state, or the interpolant is
restructured to be pure" (base 622). Three later Positions close that home:
D-231 (a store field is isbits or a `Symbol`, base log 8689–8690), D-183
(a workspace carries no information between calls, §7.3 base 1914–1915) and
D-342 bullet 2 (no mutable cache carries values between stages). Unit G also
found that no build check backs the bullet itself: the leaf walk stops at a
non-isbits immutable type and never enters its fields (D-237's Position,
8951–8953, and its 2026-09-24 annotation), so a handle holding a mutable
`Vector` builds (`scratch_survey/run_handle.jl`). The prohibition rests on
C2's requirement alone, as the author's obligation.
- Recommendation (E1's): strike "Caches belong in the consumer's state",
  leaving "the interpolant is restructured to be pure", unless an isbits
  cache in a discrete consumer's `s` is meant, in which case say so. Also
  say that the rule is the author's, unchecked inside a field handle, and
  point it at §4.1 (and C2's entry once ratified), not at §4.3's
  `IllegalPortType`.
- **Status.** open.

**C4. The rule of meaning's "do not overlap"** (R7; survey row 59 and F6;
unit C open question 1; §3.1, old 324–326). "The two mechanisms carry two
meanings and do not overlap" has no entry (grep of "Rule of meaning",
"commanding", "mode change" over the log: no hit); it dates from the first
checkpoint (`b4d8f5f`). The input half has entries on the discrete tier
(D-342 bullet 6: a commanded reset is a same-tick input; D-089's title). On
the continuous tier D-141's Position (base log 4729–4732) spells a commanded
reset as "an event whose guard reads that input", and R7's new clause says
so in §3.1, right after "do not overlap". A cold reader then meets a case
where both mechanisms take part.
- Recommendation: ratify the reading that the *meanings* do not overlap: a
  command travels as an input and a detection is an event, and a commanded
  continuous reset uses both, one per meaning (D-141). Then reword "and do
  not overlap" to say so and cite the entry. If the owner prefers no entry,
  drop "and do not overlap", which R7's clause has made misleading.
- **Status.** open.

**C5. "Mode variables … change *only* through event handlers"** (survey
row 51; unit C open question 2; §3.1, old 306–307). No entry rules "only".
D-090 rules what a handler returns, D-308 bullet 1 what modes hold, and
D-290 bullet 1 presupposes that `m` is constant within a frame; §10.4 base
5441 states it plain ("`m` changes only through handlers, at boundaries").
§14.1 base 10368–10370 lets a condition specify modes, so a condition also
sets `m`, before a run.
- Recommendation: ratify "during a run, `m` changes only through event
  handlers, at boundaries; a condition sets it before the run (§14.1)", and
  cite it at §3.1 and §10.4. The scope words come from §14.1 and §10.4.
- **Status.** open.

**C6. Field-addressed staging, "a recorded guarded addition"** (survey row
142; unit F correction 2; §4.3, old 599–600; glossary base 13894 uses it as
an example). No entry records it (grep of "lens" and "field-addressed" over
the log: only D-066's unrelated `Getter{P}` lenses, base log 1964). D-036's
Rejected list (1183–1184) records only the read-side field-projection
connector. `docs/design/briefs/brief_increment_57_leaf_address.md` 40 and
148 attribute the write-side lens to D-036, which does not hold it.
- Recommendation: ratify one entry recording field-addressed staging (a
  lens into struct slots on the write side) as an unbuilt guarded addition
  with that shape, beside D-036's connector; then cite it in §4.3 and keep
  the glossary example. If the owner declines, §4.3 drops "recorded" and
  the glossary (A12's line) drops the example.
- **Status.** open.

**C7. The composed granularity principle** (survey row 141; unit F
correction 3; §4.3, old 597–599). "The guideline and the rule compose into
one principle. A port's granularity is set by the finest-grained party
owning either end, producers on the read side and external writers on the
write side." No entry; it composes D-036's fourth ruling and the write-side
rule.
- Recommendation: rule it a summary that needs no entry, and cite D-036
  and the write-side entry (D-363, or C8's) once ratified. The owner may
  note that the read-side guideline also weighs the consumers ("consumed
  together"), which "producers on the read side" leaves out.
- **Status.** open.

**C8. The write-side rule's cadence half** (unit F, "Rationale-only
rulings"; verifier F). The bold reads "data written by different external
writers, or at different cadences, must not share a port ([D-045])". D-045's
Rejected item (base log 1436–1440) rejects a bundled command face because it
"kills per-field claiming, liveness and trace tag", which carries the
writers half. The cadence half is implied at most, through liveness.
- Recommendation: ratify the rule with both halves, and cite it beside
  D-045 and D-363 at the bold. Otherwise the bold's citation covers only its
  first half.
- **Status.** open.

**C9. Deterministic replay as "a framework guarantee"** (survey row 44;
verifier B on D-231 at §2.2; §2.2, old 282–285). No Position says "framework
guarantee". D-231's Position (base log 8692–8693) carries RNG state in `s`.
D-101's Position (3063–3067) rules replay as the ordinary loop with two
substitutions, "exact: the frame sequence is itself deterministic".
- Recommendation: rule that D-101 carries the guarantee and D-231 its RNG
  half, and cite D-101 beside D-231 at §2.2. No new entry.
- **Status.** open.

**C10. The five design criteria, the weighing of a guarded addition, and
"recorded with its shape"** (survey row 10; row 87; §1, old 166–168;
glossary base 13893–13894). No entry records the criteria or the weighing
rule; the glossary's "recorded with its shape so adoption stays additive"
has no source in §1 (A12 drops its citation). The log does record guarded
additions with their shape (D-180's per-event `direction`, D-056 bullet 4,
D-036's connector).
- Recommendation: no entry. The criteria are the document's charter, and
  "recorded with its shape" describes the log's practice
  (`decisions_style.md` rule 9: process earns no entry). Both stay plain.
- **Status.** open.

**C11. The loggers' skip-or-summarize rule** (survey row 147; unit G open
question 3; §4.4, old 624). No entry (grep of "summar" and "skip or" over
the log: none), yet §7.5 base 2103–2104 calls it "The summarize-or-skip rule
([§4.4])". `pending.md`'s "Log and trace persistence" item (base 157–163)
already defers "field-handle summarization over retained snapshots".
- Recommendation: no entry now. At step 9, add to that `pending.md` bullet
  that §4.4 and §7.5 state skip-or-summarize as a rule with no entry, to be
  ruled when the deferral lifts. This joins the existing item.
- **Status.** open.

**C12. "It has no dynamics of its own"** (survey row 69; §3.3, old 357;
R6 left it plain). D-141's Rejected item (base log 4797–4799) says "an
assembly has no dynamics of its own, [§3.3]", citing §3.3 for it. D-019's
Position (716) carries "assemblies virtual for execution" only. §8.5 states
the substance plain: "Assemblies have no state of their own" (base 3105) and
the `ClassMixed` rule (3103).
- Recommendation: no entry. It restates §3.3's "pure composition" and
  §8.5's class rule. Leave it plain and uncited.
- **Status.** open.

**C13. "well-defined semantics"** (survey row 35; §2.1, old 255). Framing:
the next two sentences carry it, the second citing D-179 ("semantics-preserving
by construction", base log 6541).
- Recommendation: no entry.
- **Status.** open.

**C14. The stop request's gloss drops the override** (unit F correction 1;
verifier F agrees; §4.3, old 543–544). "(a port that ends the run when it
reads `STOP_REQUESTED`)" says every such port ends the run. D-316's Position
(base log 13399–13401) says every request ends the run "unless the advance
ignores it", and §13.5 bolds the same (base 9839–9840).
- Proposal: "(a port that ends the run when it reads `STOP_REQUESTED`,
  unless the advance ignores it)".
- Recommendation: apply. The orchestrator can rule it: the words are
  D-316's Position, and a gloss claims nothing beyond its source (lesson
  14). It is a ruled edit to unit F.
- **Status.** open.

**C15. Wording questions that change no claim: closed.**
- Unit D: "the sampling interface" for D-056's "sampling seam" (R5
  unlinked *seam*; the reserved-word rule asked for a reword). Verifier D
  found the claim kept.
- Unit G open question 4: "closed for the first cut" (§4.4, old 660) is
  held by R13. D-237's Rationale (base log 8981–8982) uses the same hedge,
  while D-008's Rejected list sets no time limit; D-363 restates D-008's
  "rejected" without touching the spec's hedge.
- Unit C: "stall hysteresis inside the aero component" has no source to
  introduce it; it stays as the old text had it.
- Recommendation: close.
- **Status.** open.

**C16. "Fan-out is free"** (R13; §4.3, old 570). Chapter 6 left "local
fan-out is free" with no live entry, and `pending.md` already lists it
(base 97). §4.3's sentence is the same claim. D-276's Rejected item (base log
11649–11651) carries the second half, publishing a loose hot field beside
its bundle, "kept as an optimization for a known hot field".
- Recommendation: no new item. At step 9, extend `pending.md`'s chapter 6
  bullet to name §4.3's sentence too. When the owner rules fan-out, D-276's
  Rejected item can carry the "legitimate" clause.
- **Status.** open.

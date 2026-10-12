# Chapter 5 inbound check — 2026-10-12

Step 5 of the recipe. Each of the 231 rows of `inbound.tsv` was judged against
`chapter_new.md`, with every citing file read at `b08afca`. The full table is
`inbound_check.tsv`, which adds `verdict` and `fix` columns to `inbound.tsv`.
Rows are numbered from 1 after the header.

## Counts

| verdict | rows |
|---|---|
| OK | 204 |
| VAGUE | 22 |
| RETARGET | 4 |
| MISSING | 1 (pre-existing, not a loss) |
| COMPANION | 0 |
| **LOSS** | **0** |

Of the 27 non-OK rows, 20 were already wrong against the old chapter. Six
follow from rulings the rewrite applied. One of the six, spec 12956, also has
a defect from before. The last row, `pid_anti_windup.md` 95, was ambiguous
before, and the new text's "three rungs" makes it plainly wrong. The six
rulings rows:

- R16 moved `x_projection`'s positions from "the execution order" to "the
  boundary sequence". Four citing sentences still say "execution order"
  (spec 1561, 1923, 4695, 12956).
- F2 changed the table to "declares a non-empty `x_init`". Appendix B's
  footnote still says "present iff declared" (spec 11796).
- R6 changed the hand-down's citation from D-252 to D-285. Appendix B still
  pairs §5.2 with D-252 (spec 11802).

The rewrite also fixed several rows that the survey (part D) expected to fail:

- spec 2322 and 2799 hold after F2.
- spec 10042 holds after R12.
- The Appendix C kinds `BundleFieldError`, `HandlerReturnKey` and
  `AlgebraicCycle` are now named in the sections that cite them (R7).
- `migration_outline.md` 108's "middle rung" now matches the three rungs in
  the text.

## LOSS

None. The new chapter states everything an inbound row relies on that the old
chapter stated. The `pid_anti_windup.md` 91 check holds: stage-2 conservatism
is still §5.4's last paragraph. The `event_visibility_walkthrough.md` 12 check
also holds: "a handler executes against exactly the world its guard fired on"
is verbatim at new 365–366.

## MISSING (pre-existing)

- **decisions 9353, D-247 Rationale (§5.3).** "auto-publication publishes a
  state field as the port of the same name". D-252 removed auto-publication,
  and §5.3 now says a component exposes a state field by returning it from
  `y_state` (new 260–262). The old chapter did not state auto-publication
  either. Fix: none. It is a Rationale of its day (decisions_style rule 1).

## RETARGET

- **spec 11618, Appendix A *The stage funnel* (§5.2).** Pre-existing, partial.
  The funnel is §5.2's (new 158–163). The entry's "no `direct` in the name
  *is* the no-feedthrough property" and its teaching line are §5.3's (new
  227–231, 294–296). Fix: cite "([§5.2][s5-2], [§5.3][s5-3])".
- **spec 12348, Appendix C `DeclarationOnWrongTier` (§5.2).** Pre-existing.
  §5.2 states no wrong-tier declaration condition. §5.3 states it and now
  names the kind (new 240–243, R7). Fix: [§5.3][s5-3] in place of
  [§5.2][s5-2].
- **decisions 714, D-019 Spec (§5.4).** Pre-existing, track 2. §5.4 holds none
  of D-019's mechanism; only D-019's Rejected item touches artificial loops.
  §5.2 holds D-019's `Δt` bundle field. Fix: §5.2 in place of §5.4.
- **`sample_time_proposal.md` 390 (§5.3).** Pre-existing, partial. §5.3 holds
  the discretized laws, but the never-cache-`Δt` rule is §10.5's (spec 5914,
  D-019). Fix: "[§5.3][s5-3]'s discretized laws and [§10.5][s10-5]'s
  never-cache-`Δt` rule".

## VAGUE

### Execution order versus boundary sequence (new wording, R16)

The new §5.3 says `x_projection` runs at two positions in the boundary
sequence (new 352–357). The glossary defines *execution order* as the list of
stage entries.

- **spec 1561 (§7.1).** Fix: "at the two positions in the boundary sequence
  of [§5.3][s5-3]". Drop the `#g-execution-order` link.
- **spec 1923 (§7.5).** Fix: "`x_projection` at both of its positions in the
  boundary sequence ([§5.3][s5-3])". Drop the link.
- **spec 4695 (§9.5).** Fix: "at both of its positions in the boundary
  sequence ([§5.3][s5-3])".
- **spec 12956 (glossary *projection*).** Two defects.
  - (a) New wording: "the only two positions in the execution order" becomes
    "in the boundary sequence".
  - (b) Pre-existing: "the cheap end of geometric integration's projection
    methods" is §2's claim, not §5.3's.

  Fix: cite §5.3 on the positions sentence and §2 alone on the cheap-end
  sentence.

### Bundle-law footnotes (new wording, F2 and R6)

- **spec 11796 (Appendix B footnotes).** "`x`/`s`/`m`/`ws` are present iff
  declared". §5.2's table now says "declares a non-empty `x_init`" (D-297).
  Fix: "`x`/`s`/`m` are present iff declared non-empty ([D-297][d-297]), and
  `ws` iff declared."
- **spec 11802 (Appendix B).** "`y_x`/`y_s` are present iff the stage-1
  *return* is non-empty ([§5.2], [D-252])". §5.2 states the fact, but it
  sources the hand-down to D-285. Fix: [D-285][d-285] in place of
  [D-252][d-252].

### The silent-drift class (pre-existing; survey part D)

These rows all make the same claim: spec 636, D-139 Position (decisions 4546),
D-139 Spec (decisions 4549) and `trim_environment_walkthrough.md` 62. §5.3
never names a drift class. The drift bug class is D-015's Rejected item:
"edited law in `f`, stale copy in `g`". The nearest §5.3 text is "Nothing ever
needs computing twice" (new 279–280).

One chapter 5 sentence fixes all four rows without touching the log. Put it
in §5.3, after "Nothing ever needs computing twice":

> Computing a law twice invites drift, an edited law in one place and a stale
> copy in the other ([D-015][d-015]).

The alternative fixes each citing site and leaves the log alone (rule 1):

- spec 636: "The drift avoided here is the duplicated computation that the
  fused idiom of [§5.3][s5-3] removes ([D-015][d-015])."
- trim 62: "precisely the duplicated computation that the fused idiom of
  [§5.3][s5-3] exists to remove".
- D-139's Spec drops §5.3 (track 2).

### The argument rule (pre-existing; survey part D)

- **spec 1555 (§7.1).** "under the argument rule of [§5.2]". Fix: "under the
  hand-off of [§5.2][s5-2]".
- **spec 1869 (§7.4).** "The fixed point is the argument rule ([§5.2])". Fix:
  "The fixed point is the hand-off ([§5.2][s5-2])."

### Addressability and private intermediates (pre-existing; survey part D)

- **spec 6500 (§11.2).** "Private intermediates are not in it, because they
  were never cells at all ([§5.2])". §5.2 says nothing of private
  intermediates, which D-194 retired. Fix: "Undeclared intermediates are not
  in it, because only declared ports are cells ([§8.3][s8-3])."
- **spec 10517 (§14.4).** "only cells are addressable ([§5.2])". Fix: cite
  [§4.2][s4-2] ("The port is the addressable unit") and [§8.3][s8-3] in
  place of §5.2.
- **spec 10829 (§14.7).** Fix: "([§8.3][s8-3], [§14.4][s14-4])" in place of
  "([§5.2][s5-2], [§14.4][s14-4])".

### Other spec rows (pre-existing)

- **spec 6526 (§11.2).** "at a cost of one cell per sweep ([§5.3])". §5.3
  gives the method, not its cost. Fix: move the citation to "returned from
  `y_state` ([§5.3][s5-3]), at a cost of one cell per sweep."

### Log Rationales of their day (pre-existing; no change under rule 1)

- **decisions 7157, D-196 Rationale.** "The stage number is the tier-neutral
  fact ([§5.3])". §5.3 never says this. The nearest text is "The two output
  stages do not [carry the tier]. One pair of names serves both tiers" (new
  238–240).
- **decisions 10772, D-267 Rationale.** "[§5.3]'s own nouns, the "state-only
  output" and "direct feedthrough"". Neither phrase is in §5.3, old or new.
  The same sentence's second claim (row at 10773) holds.

### Companions

- **`event_visibility_walkthrough.md` 12 (§5.3).** Pre-existing. The quote has
  two clauses.
  - The first is verbatim in new 365–366: "a handler executes against exactly
    the world its guard fired on".
  - The second, "one component's transition reaches everyone — itself
    included — through the next sweep", is not in the spec, old or new.

  Fix: close the italics after "fired on". Paraphrase the rest outside the
  quote, after §5.3's "a transition reaches the table at the next round's
  re-sweep" (new 359–360).
- **`flight_case_studies.md` 132 (§5.3).** Pre-existing. §5.3 makes the
  overlap claim (new 298–302) but not the grain claim, and "decoder" is
  retired vocabulary. Fix: "the claim in [§5.3][s5-3] that derivative/output
  overlap is the domain norm". Drop the grain clause, or state it as the
  companion's own finding.
- **`pid_anti_windup.md` 95 (§5.4), the rung count.** The text calls contract
  re-factoring "[§5.4]'s first rung". New §5.4 says "The remedy ladder for
  artificial loops has three rungs", and it calls the two-stage split "the
  rung that absorbs most artificial loops" (new 445–449). That makes
  re-factoring the middle rung, as D-140 and `migration_outline.md` 108 say.
  Fix: "[§5.4][s5-4]'s middle rung".
  - The file's other count, line 102's "[§5.4]'s second remedy", holds: the
    other two rungs "apply in this order", and the component split comes
    second.
- **`pid_anti_windup.md` 300 (§5.4).** Pre-existing ambiguity. "the integrator
  in it is precisely the split [§5.4] describes", but new §5.4 names two
  splits, the two-stage split and the component split. Fix: "precisely the
  component split [§5.4][s5-4] describes".

## Lesson 16: pointers that lead back

Checked:

- Every pointer the new chapter puts in place of content, and every place
  where an inbound citation and chapter 5 point at each other.
- §5.2's hand-down → §9.3 (spec 4279 states the sourcing itself).
- §5.3 → §7.4 for the computer/integrator split (spec 1888–1897 states it).
- §5.3 → §10.6 for the iteration and the epoch rule (§10.6 states the epoch
  rule at spec 6060).
- §5.3 → Appendix A (11648, 11657 state both reset entries).
- §5.3 → `flight_case_studies.md` §3's *Mode engage* frame (349–350 state it,
  with no pointer back).
- §5.4 → D-034/D-055 (§5.4 names both closed spellings itself).
- §5.6 ↔ §9.4 on "tracer activation" (both state it).

None leads to an entry that only points back.

One near case to watch:

- **§5.5 ↔ §13.7 on the unit delay's caveat.** The new §5.5 sentence (R12)
  says "The diagnostic states this caveat rather than offering the delay as a
  free remedy ([§13.7][s13-7])". Spec 10042 in §13.7 says "The diagnostic
  ([§5.5]) therefore says so". Each place states the claim, so neither is
  empty. But the only support each gives is the other, and no decision entry
  records the claim. Its ground is `src` (`_BREAK_CYCLE`,
  `src/diagnostics.jl` 929–931, survey part D).
  - If the owner wants a ground, the claim needs an entry or a `pending.md`
    line. This is not a row defect.

## Notes for track 2 (outside the rows)

- **Entries the new chapter cites whose Spec field lacks the citing section.**
  Each was checked against its Spec field at `b08afca`.
  - D-048 (§5.1)
  - D-006 (§5.2, §5.3)
  - D-297 (§5.2)
  - D-020 (§5.3)
  - D-112 (§5.3)
  - D-288 (§5.3)
  - D-245 (§5.4)

  Survey part D already lists D-006, D-020, D-048 and D-245.
- **D-267's Spec lacks §5.6.** §5.6 now uses `x_init`, `s_init` and `m_init`
  (F5).
- **`flight_case_studies.md` 180 still has the dangling "bumpless-engage
  answer ([§11.7])".** This is the same defect F3 fixed in §5.3. It cites
  §11.7, not §5, so it is not an inbound row.
- **`pid_anti_windup.md` 102.** "its integrator splits the stages by
  construction" can be read as the two-stage split, the first rung. The
  sentence means the component split. A clearer wording: "splits the
  controller into components, which is [§5.4]'s second remedy for free".

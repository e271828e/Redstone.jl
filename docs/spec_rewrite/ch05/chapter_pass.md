# Chapter 5: the chapter pass (step 5)

Read: `chapter_new.md` whole (669 lines), against `chapter_old.md`, the
brief's R1 to R17, survey parts B and F, `spec_style.md`, and the base spec
and log at `b08afca`. Line numbers are `chapter_new.md` lines. Units: A
1–98, B 101–196, C 198–331, D 334–435, E 437–547, F 549–667.

Classes: EDITORIAL (wording, placement, link, wrap; the editorial fixer
applies it through the unit's inventory) and RULING (changes a claim, a
citation's entry or a bold's ruling, or needs the orchestrator).

Counts: 26 findings, 23 EDITORIAL and 3 RULING. A "Judged, no change" list
follows the findings.

## Findings

1. **L6–11, the opening's roadmap (unit A). EDITORIAL.** The §5.3 entry
   reads "the stage roles, the execution order and step boundaries". §5.3
   also holds "Derivatives that read outputs" and "Supervisory inputs", whose
   three bolds (D-089 twice, D-141) are the chapter's reset rulings. A reader
   who scans the roadmap for resets does not find §5.3. Fix: "[§5.3][s5-3]
   the stage roles, the execution order, step boundaries and supervisory
   inputs;". Optional: "escape hatch" appears only in §5.4's title and the
   roadmap, and the body says "remedy ladder" throughout. The roadmap may
   read "[§5.4][s5-4] artificial loops and their remedy ladder". The title
   stays.

2. **L21–22, §5.1's clause on cyclic graphs (unit A, R1). RULING.** "A
   cyclic graph is the subject of [§5.5][s5-5]." The graph §5.1 builds is the
   one the topological sort runs over. A cycle in it may be an artificial
   loop. §5.4 (L451–454) calls that case "port-level acyclic and stage-level
   cyclic" and has the tracer classify it as "a rejected cycle". §5.6
   (L554–557) says every cycle the build finds is classified, with the
   artificial ones sent to the ladder. §5.5 holds only the genuine case. R1
   ordered this clause, so the change needs the orchestrator. Fix: "A cyclic
   graph is the subject of [§5.4][s5-4] to [§5.6][s5-6]." It claims nothing
   the three sections do not state.

3. **L27–30, with first uses at L114, L120, L124, L250 and L254. RULING
   (declared addition).** The chapter never says that stage 1 is `y_state`
   and stage 2 is `y_direct`. The signature block labels `y_state` only as
   the "no-feedthrough stage". §5.2 then uses "stage-1 ports" (table, L114),
   "the stage-1 hand-down" (L120) and "its stage-2 bundle" (L124), and §5.3
   uses "stage-1 ports" (L250) and "Stage 1 exists" (L254). A grep of the
   base spec finds the equation stated nowhere, and chapter 5 is its home.
   The old text had the same gap. Fix: after L30 ("There are no dependency
   annotations anywhere in the design"), add "`y_state` is stage 1 and
   `y_direct` is stage 2." Source: the glossary's *execution order* (spec
   12934–12936) with the signature block's order. Declared addition, so the
   orchestrator rules on it.

4. **L52 and L76, links after the first use in §5.2 (unit A). EDITORIAL.**
   "view" is first used at L52 ("where each view comes from") and linked at
   L58. "store" is first used at L76 ("It takes one store in and returns the
   same store out") and linked at L84 ("mode [stores]"). Fix: link
   `[view](#g-view)` at L52 and leave L58's "zero-copy views" bare, since that
   sentence defines the views. Link `[store](#g-store)` at L76's first
   "store", with §5.3's gloss "(the framework-owned home of a state
   letter)", and leave L84's "mode stores" bare.

5. **L82, the tier gloss (unit A). EDITORIAL.** "On the continuous
   [tier](#g-tier) (the continuous side of the hybrid formalism)" glosses the
   phrase "continuous tier", so "the discrete tier" two lines later has no
   gloss. §5.3 (L237) uses the glossary's own wording. Fix: "(the continuous
   or discrete side of the hybrid formalism)", the same gloss as L237.

6. **L86 and L330, the cell glosses (units A and C). EDITORIAL.** §5.2
   glosses the cell as "(concretely typed entries, one per output port)".
   Bare *entry* is reserved ("never used bare", glossary 12838; the brief's
   "Reserved words"). §5.3 glosses the same term as "(the typed signal-table
   slots, one per output port)", so the chapter describes one thing in two
   ways. Fix both to "(concretely typed table entries, one per output
   port)". "Table entry (a cell)" is the glossary's own compound.

7. **L99–100 and L331–333, double blank lines at the A/B and C/D seams.
   EDITORIAL.** Fix: one blank line before each `####` heading.

8. **Wrap, 80 rendered columns (units C, D, E and F). EDITORIAL.** These
   lines run past 80 rendered columns, or break a sentence onto a new line
   mid-paragraph:
   - Unit C: L243 (111 columns; "The error is `DeclarationOnWrongTier`." was
     appended unwrapped), L248 (86), L277 (84), L299 (93).
   - Unit D: L336 (82); L355–357 (the known pair: L355 ends at 28 columns
     and L356 starts a new sentence on a new line); L391 (99); L433 (82).
   - Unit E: L454 (91), L503 (82), L512 (87), L534 (118), L539 (95);
     L540–542 (L541 holds "([§13.7][s13-7])." alone and L542 starts a new
     sentence on a new line).
   - Unit F: L556 (116).

   Fix: refill each paragraph to 80 rendered columns, link markup collapsed,
   after the wording fixes below that touch the same paragraphs (findings
   12–17, 19–21 and 24). Optional at L242–243: "…is a
   `DeclarationOnWrongTier` build error, not a reading." folds the appended
   sentence into the rule, with the same claim.

9. **L321–322, RHS spelled out after its first use (unit C). EDITORIAL.**
   L321 uses "RHS" and L322 expands it. Fix: "The systemic consequence is
   that *evaluating the right-hand side (RHS) means running the sweep*. The
   RHS is the flow, `x_deriv`."

10. **L329, "executor" unlinked in §5.3 (unit C). EDITORIAL, low.**
    "Discrete executor entries" is the first "executor" in §5.3. The term's
    link sits in §5.2 (L64) and does not carry over. Fix: "Discrete
    [executor](#g-executor) entries …". Leave it without a gloss, since a
    gloss would split the glossary's compound "executor entry".

11. **L424, "continuous component" unlinked (unit D). EDITORIAL, low.** The
    glossary has `#g-continuous-component` (spec 12702), and survey part C
    lists L424's first use as unlinked. Fix, per R13 for a first use inside
    a bold: "**A [continuous component](#g-continuous-component)'s reset is
    an event** ([D-141][d-141])." The next sentence's "continuous tier"
    gives the context, so add no gloss inside the headline.

12. **L336–338 with L354 and L357, the boundary sequence is never named
    (unit D, R4 and R16). EDITORIAL, high.** Old L268 opened the sequence
    with "**The boundary sequence.** At each boundary the framework
    integrates, projects, …". R4's merge kept the sequence but dropped its
    name. L354 and L357 then say "the boundary sequence", R16's term, as if
    a reader had met it. Three inbound citations rely on §5.3 naming it:
    spec 5062 ("The boundary sequence it dispatches is fixed in [§5.3]"),
    5089 ("The boundary sequence ([§5.3]) completes there") and 5101 ("They
    are the boundary sequence ([§5.3])"). The new text is worse than the old
    here. Fix: split L336's sentence. "At each step boundary the framework
    runs the boundary sequence. It integrates, projects, runs the boundary
    sweep (…), evaluates *all guards once* against that sweep, and fires the
    eligible events."

13. **L337–338, the boundary-sweep gloss (unit D). EDITORIAL.** The gloss
    reads "(the full pass that refreshes the signal table, with the
    boundary's due discrete ticks gated in)". "Ticks gated in" claims more
    than the source says. The glossary's *sweep* gates in the due discrete
    *entries* (spec 12962–12963), and its *due* gates in "Due components'
    output stages" (spec 13009–13010). "Due" is also jargon that a cold
    reader lacks, and this is the first "tick" in §5.3, ahead of the tick
    link at L362. Fix: "(the full pass that refreshes the signal table,
    including the discrete components due at this boundary)".

14. **L390–391, the trace and replay gloss (unit D, the known leftover).
    EDITORIAL.** The parenthetical sits after "replay", so it reads as
    replay's gloss alone, though its first half glosses trace. Fix: drop the
    parenthetical and gloss in the next sentence, links unchanged at first
    use. "Gain trajectories are observable in log, [trace](#g-trace) and
    [replay](#g-replay), where a parameter write would be invisible to all
    three. The trace is the session's recorded inputs, and replay re-drives
    the ordinary loop from that trace." The claims match the current gloss.

15. **L400–404 and L433, `PI` never introduced (unit D). EDITORIAL, low.**
    §5.2 introduces `PID` (L61–62, "Here `PID` names a
    proportional-integral-derivative controller"). §5.3's `PI` block and "a
    library PI block" (L433) leave `PI` cold. Fix at L400–401: "The
    compensator, here a proportional-integral `PI` block, sits topologically
    after the supervisor and honors them *this tick*:".

16. **L419–422, the C172X demo is introduced after its use (unit D, R5
    F3). EDITORIAL.** L420 uses "the C172X demo's *Mode engage* frame", and
    the introducing sentence follows at L421–422. Fix: reorder without new
    claims. "[Appendix A][sA] carries this as the same-tick reset entry. The
    C172X demo is the interactive Flight.jl demo that section 3 of
    `companions/flight_case_studies.md` examines. The bumpless-engage answer
    of its *Mode engage* frame presupposes exactly this spelling."

17. **L439, L508, L536 and L649, first-use links with no gloss (units E and
    F). EDITORIAL.**
    - L439, §5.4's first "feedthrough". §5.1, §5.2 and §5.3 each gloss it,
      and §5.4 uses it five times. Fix: "… with a feedthrough output (one
      with an instantaneous input→output dependence) in one atomic
      evaluation unit …".
    - L508, "payload". Fix: "as a separate field of its
      [payload](#g-payload) (the structured data a diagnostic carries)",
      from glossary 13683.
    - L536, §5.5's "tier". Fix: "It changes the model's [tier](#g-tier)
      structure (its split into continuous and discrete sides)."
    - L649, §5.6's "the discrete [tier](#g-tier)'s". Optional, since
      "discrete" carries the sense. A gloss would split the possessive.

18. **L486, the companion's path (unit E). EDITORIAL.** It reads "(the
    companion document `migration_outline.md` records the migration)". L422
    writes `companions/flight_case_studies.md`, as the base spec does
    elsewhere (`companions/limited_integrator_variants.md` 5311,
    `companions/sample_time_proposal.md` 5763,
    `companions/library_inventory.md` 9980). Fix: "(`companions/migration_outline.md`
    records the migration)".

19. **L532–536, the three-routes sentence (unit E, the known leftover).
    EDITORIAL.** It carries two parentheticals, "(the α-filter idiom, a
    filter state inserted in the loop)" and "(`UnitDelay`, [§13.7][s13-7])",
    and runs to 118 columns. Fix, keeping every claim: "The user breaks the
    cycle explicitly, by one of three routes. They can insert dynamics,
    insert an explicit unit delay, or restructure. Inserting dynamics is the
    α-filter idiom (a filter state inserted in the loop), already standard
    practice in the domain." Then L536 opens: "The unit delay, `UnitDelay`
    ([§13.7][s13-7]), carries a caveat."

20. **L538–539, the `Δt_base` gloss uses `h` (unit E). EDITORIAL.** "(the
    base tick period, an integer multiple `N_base·h`)" uses `h` as the step
    size. §5.3 has just made `h` the output map (L214, L224–228, L367), so a
    cold reader reads `N_base·h` against the wrong `h`. The glossary entry
    says "an integer multiple `N_base·h` of the continuous step" (spec
    13001–13002). Fix: "(the base tick period, an integer multiple of the
    continuous step)". The glossary keeps the formula.

21. **L555–556, §5.6's tracer gloss is circular (unit F). EDITORIAL.**
    "(the set-propagation instrument that does the tracing)" glosses the
    tracer by the tracing. §5.4 (L453–454) glosses the same term by its job.
    Fix: "(the set-propagation instrument that tracks which inputs a value
    depends on)". The source is L576 ("A traced value carries a set of input
    indices") and glossary 13672. The sentence's "to classify that cycle"
    then carries the job without repeating it.

22. **L641–642 against L657–658, the same fact twice in §5.6 (unit F).
    EDITORIAL.** Unit F added "A member's map may come from either mode, or
    from structure ([D-245][d-245])." Two paragraphs later, L657–658 bolds
    and states the same ruling: "**The diagnostic records the source of each
    member's map** … The source is the global tracer, sampled states or
    structure." Fix: keep the distinction and drop the repeat. "The local
    variant is not the local set-tracer mode. A member's map may come from
    either mode." The "or from structure" and the D-245 citation stay at
    L657–658, the ruling's home.

23. **L647, "probe state" against "probe point" (unit F). EDITORIAL.**
    L615 glosses "probe point", L638 uses it, and survey part F lists it as
    a term of art. L647 says "the branch taken at the probe state". Fix:
    "the branch taken at the probe point".

24. **L660–662, two parentheticals in one sentence (unit F). EDITORIAL.**
    The sentence carries "(its declared interface)" and "(the ladder,
    [§5.4][s5-4], [D-140][d-140])". Fix: "The hint itself is to split this
    component, *or* to narrow the neighbor's [contract](#g-contract) (its
    declared interface) when the dead hop's input is consumed only in a
    fallback branch. Those are the ladder's two remedies ([§5.4][s5-4],
    [D-140][d-140])." The second sentence restates §5.4's two bullets and
    adds nothing.

25. **Appendix C pointers at the kinds (units B, C, E and F). EDITORIAL,
    low.** §5.5 (L527–528) and §5.6 (L567–568) cite "([Appendix C][sC])" at
    `AlgebraicCycle`. §5.2 names `BundleFieldError` (L127), `DeadStage`
    (L173) and `HandlerReturnKey` (L194) with no pointer, and §5.3 does the
    same for `DeclarationOnWrongTier` (L243) and `DeclaredNotProduced`
    (L263). Fix: one "([Appendix C][sC])" at the first kind each section
    names (L127, L243), or none in §5.6, where §5.5's pointer is a section
    away. Either way, the chapter follows one practice.

26. **§5.4 has no subheadings and no parts sentence (unit E, R10). RULING,
    low.** `spec_style.md`, "Section template": "A section without them ends
    its context paragraph with one sentence naming its parts in order."
    §5.4 runs 85 lines: the split, two remedies, the diagnostic, why the
    component split is rare, and stage-2 conservatism. R10 limits additions
    to "the ladder's other two rungs". Recommendation: leave it under R10,
    or allow one declared sentence after L449, "The section then gives the
    two remedies, the diagnostic that offers them, why the component split
    is rare, and one consequence of stage-2 conservatism." §5.5 is short
    enough to need none.

## Judged, no change

- **Unit B's table cells (L108–110), the known leftover.** "(continuous
  tier) ([D-297][d-297])" puts a citation beside a gloss. The
  one-parenthetical rule governs glosses, the whole spec puts citations in
  parentheses, and R5 F2 put the citation in the cells. Keep.
- **L273–274.** "(one ordered pass …) ([D-015][d-015])" is a gloss plus a
  citation, placed as R13 orders for a link inside a bold. Keep. The repeated
  D-015 at L277 follows the brief's "a split repeats the citation". Keep.
- **The slash-form example twice (L530 in §5.5, L570 in §5.6), and the hint
  twice (L503–505 quoted, L660 paraphrased).** Survey part B, items 6 and 7.
  Each section stays locally re-readable. §5.4 owns the ladder, and §5.6
  keeps the hint as the diagnostic's content. Keep.
- **The fused idiom three times (L266–269, L277–278, L306–308).** The third
  now points back ("by the fused idiom above") and keeps the accelerometer
  example, as the brief asked. Keep.
- **"handler entry" (L368).** It means entering a handler, not a reserved
  *entry*, and `event_visibility_walkthrough.md` 167 quotes "holds at every
  handler entry". Keep.
- **Tier-in-the-name stated in §5.2 (L150–153) and §5.3 (L237–240).** The
  old text did the same, and the two serve different purposes: the name sets
  in §5.2, the naming in §5.3. Keep.
- **"Dead hop" in §5.4 (L505, "the member with the input face that it does
  not route") and §5.6 (L629, a hop inside a member).** Appendix C's payload
  is "(member, input face, output port)" (spec 12409), and both readings
  name parts of it. The old text had the same wording. Keep.
- **Bold.** The chapter has 25 bolds, each a headline clause with its
  D-citation in the sentence. No ruling is bold twice in the chapter. In
  chapters 7 to 10 of the base spec, the bolds citing the same entries are
  D-252 sentence 1 (2834), the `DeadStage` rule citing D-194 and D-285
  (4296) and D-194's seam bullet (4860). Chapter 5 states the first two
  plain with pointers (L259–260, L173) and does not state the third. The
  D-074, D-035, D-220, D-089, D-012 and D-245 bolds each mark a distinct
  ruling, as survey part A's table and R9 and R15 assign them.
- **Glossary links.** No anchor is linked twice in any section. `bundle` is
  never linked in its port sense (L388, L495–496), and `trace` is never
  linked in its tracer-result sense (L632, L647).
- **Openings.** §5.3's opening (L200–206) names its six parts in their
  final order. §5.6's opening (L557–559) names its five parts in order.
  "Tracer tags" is now defined (L576) before its use (L619).
- **Pointers.** Every section pointer in the chapter lands on a section that
  states what the sentence says (checked against the base outline: §3.4's
  strapdown IMU, §7.4, §8.1, §10.3, §10.4, §13.7, §14.10, among others).

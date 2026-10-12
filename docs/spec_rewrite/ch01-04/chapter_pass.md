# Chapter pass: chapters 1 to 4 (step 5)

Read: `chapter_new.md` whole (694 lines, assembled from units A to G), against
`chapter_old.md`, the brief (R1 to R17), survey parts B, C and F, the frozen
spec and log in `scratch_survey/`, and `bold_spans_all.tsv`. Line numbers are
`chapter_new.md` lines. Each finding names its unit for the fixer.

EDITORIAL: wording, placement, link or wrap, applied through the unit's
inventory. RULING: changes a claim, a citation's entry or a bold's ruling, or
needs the orchestrator.

## What holds

- **Bold.** 28 bolds, each a headline clause with its D-citation in the
  sentence. One bold per ruling across the four chapters: D-001 four (R6),
  D-082 two, D-003 two, D-036 four, D-237 two, D-056 two, every other entry
  one. Against chapters 5 to 10 of the base, no ruling is bold twice. The one
  overlap, §10.4's D-082 edge bold (base 5492), goes plain at landing (R17).
  D-243 is bold twice (431, 544) for two different rulings, but see finding 21.
- **Glossary links.** No anchor is linked twice in one section, §4.3's E/F
  split included. No link is on a reserved word in another sense: *bundle*,
  *condition*, *seam* and §3.4's "two leaf classes" stay unlinked.
- **Openings.** §2's, §3's and chapter 4's roadmaps name their sections in
  order and match the sections as written. §4.3's "Four questions" match its
  subheadings.
- **Chapter 1 against chapters 2 to 4.** No claim in §1 is stronger than or
  different from the chapter it points at. The periphery, guarded-addition and
  replay statements agree with §4.1, §3.4/§4.3 and §2.2.
- **Pointers.** Every § pointer lands on a section that states what the
  sentence says. §6.1 (576) does state the `output_wires` rule (base 1354).
  §14.4 is the leaf address's home (glossary 13595).
- **Unit seams.** No antecedent crosses a seam. §3.4, §4.3's "What a port may
  hold" and §4.4 each open on a self-contained sentence.

## Findings

### Chapter 2 (unit B)

1. **137. EDITORIAL.** *Guarded addition* takes a different gloss here, "(a
   capability recorded with its shape so adoption stays additive)", than in
   §1, §3.4 and §4.3 ("a capability the design admits but does not build").
   The sentence then says "recorded" twice and adds ", unbuilt". Fix:
   "[D-180][d-180] records a per-event `direction` keyword as a
   [guarded addition](#g-guarded-addition) (a capability the design admits but
   does not build)." The gloss carries "unbuilt", so R5's D-180 content is
   unchanged.

2. **95. EDITORIAL.** "the published table" is reader-cold in §2. Chapters 3
   and 4 call it the signal table. Fix: "This design's `f` also receives the
   published signal table, and …". R4's quote of §5.3 gains one word and no
   claim.

3. **97–100. EDITORIAL.** The citation splits "held zero-order … between
   ticks", and the tick gloss puts a second parenthetical in the same clause.
   Fix: "$s^{+} = g(s, u, t)$ at declared rates, with outputs held zero-order
   between [ticks](#g-tick) ([D-019][d-019]). A tick is an instant at which a
   discrete component's stages and update run."

4. **101–102 with 114. EDITORIAL.** "under two detection policies, stated
   below" now repeats the roadmap 12 lines later. Fix: drop ", stated below".

5. **131–133. EDITORIAL.** The prior's appositive gloss nests a second gloss,
   the boundary's: "the [prior], each event's predicate sample stored at the
   previous [boundary] (a published consistency point)". Fix: two sentences.
   "[§10.6][s10-6] states the bookkeeping of the [prior](#g-prior). The prior
   is each event's predicate sample stored at the previous
   [boundary](#g-boundary) (a published consistency point)."

6. **151–152. EDITORIAL.** F4's "per iteration round" is reader-cold in §2.1.
   Nothing in §2 says what iterates. §10.6 (base 6093–6099) defines the round
   as one pass of the boundary event phase. Fix: "The cost is one guard
   evaluation per event per round of the boundary's event iteration
   ([§10.6][s10-6])."

7. **162. EDITORIAL.** "This arrangement" now follows the pacing paragraph,
   so it reads as the pacer's arrangement. Its referent is the edge-plus-two-
   policies scheme. Fix: "The two-policy arrangement gives step-boundary logic
   *well-defined semantics*."

8. **166–167. EDITORIAL.** This is the first use of *tier* in the spec body.
   §1 and §2 never use it. It is linked inside the bold with no gloss. Fix:
   after the bold sentence add "A tier is one side of the hybrid formalism,
   continuous or discrete." That is the glossary's wording (13288). In §3.1
   (250) and §3.2 (265) the unglossed link can stay: by then §2.1 has
   glossed it, and a gloss would stack on R7's clause and on a bold.

9. **180–182. EDITORIAL (growth).** The projection appositive, "the optional
   per-component hook `x ← x_projection(x)`", repeats §2's bold verbatim 78
   lines up. Fix: "[projection](#g-projection) (the post-step manifold hook)
   covers it". The term stays glossed, and the repeat goes.

10. **183–186. EDITORIAL.** "turbulence from Dryden/von Kármán turbulence
    models" says "turbulence" twice. Fix: "such as sensor noise and
    turbulence from the Dryden/von Kármán models". This keeps R16's content.

### Chapter 3 (units C and D)

11. **250–252. EDITORIAL.** R7's clause uses the reserved word *condition*
    in the log's sense: "whose condition arrives as an input". That is
    D-141's wording, and the spec reserves *condition* for §14's value. Fix:
    "On the continuous [tier](#g-tier), a reset of state commanded through an
    input still lands through an event whose guard reads that input
    ([§5.3][s5-3], [D-141][d-141])." R7's content and its "reset of state"
    are unchanged.

12. **229 and 235. EDITORIAL.** §3.1 links *component* at 235, but its first
    plain use is 229 ("the component's own `x`"). Fix: move the link to 229.

13. **317–328 (the known leftover). EDITORIAL.** "(typed entries of the
    signal table, [D-056])" puts the routing ruling's citation inside a
    gloss. The sentence also stacks two glosses, *tiers* and *cells*. Fix:
    "Inside a merged component, influence across [tiers](#g-tier) (the
    continuous and discrete sides of the formalism) still routes through
    [cells](#g-cell) of the published signal table ([D-056][d-056])."
    "Cells of the published signal table" glosses *cell* with no
    parenthetical. With finding 15 applied, "merged component" becomes
    "all-in-one component".

14. **330–333. EDITORIAL (growth).** "An assembly is a component of pure
    composition." is inserted between the trench-coat verdict and its
    consequence. It restates §3.3's first sentence, one section earlier, and
    forces "The all-in-one component" to be named again. Fix: gloss inline
    and restore the pronoun. "The all-in-one component is therefore an
    [assembly](#g-assembly) (pure composition) of two primitives in a trench
    coat ([D-056][d-056]). It buys no expressiveness. It incurs costs of its
    own, which [D-056][d-056] enumerates."

15. **301, 317, 326, 330, 336. EDITORIAL.** One hypothetical goes by four
    names in §3.4: "all-in-one primitive", "merged component" (twice),
    "all-in-one component" and "monolith". D-056 names it "All-in-one
    component kind". Fix: "all-in-one component" at 317 and 326. Keep "One
    all-in-one primitive" at 301, since the verdict at 330 turns on primitive
    against assembly. Keep "A monolith" at 336 as the rhetorical contrast, or
    write "An all-in-one component swallows it".

16. **357. EDITORIAL.** Unit D touched this sentence (R5's "mechanism"), and
    it keeps the reserved word *condition* in another sense:
    "condition-triggered". Fix: "The reset is periodic, not
    predicate-triggered, so events are the wrong mechanism". *Predicate* is the
    sense §2.1 defines. "its exactness condition" (369) is a mathematical
    term in an untouched sentence and can stay (survey part F).

17. **376–379. EDITORIAL.** The added "`Dual` is ForwardDiff's dual number."
    splits the third gain from its reason. Fix: fold it into the activation
    gloss. "Third, linearization got sane. Under a `Dual`
    [activation](#g-activation) (the build's typed products at ForwardDiff's
    dual-number scalar type) the discrete tier is held ([§8.2][s8-2])." That
    is one sentence fewer, and the gloss still claims only the glossary's
    "typed products at a given scalar type".

18. **384–386. EDITORIAL.** "The one recorded, unbuilt escape hatch" reads as
    "the only one". D-056 bullet 4 says "the recorded, unbuilt escape hatch".
    Old 291 said "One escape hatch is recorded, unbuilt". The gloss two lines
    later says "admits but does not build" again. Fix: "**The recorded,
    unbuilt escape hatch is a tick-triggered handler on continuous
    components** ([D-056][d-056])." The bold loses one word.

19. **345, 354, 366, 368. EDITORIAL (optional).** §3.4 points at §8.6 six
    times. Two of the pointers say the same thing four paragraphs apart:
    "[§8.6] spells this IMU in full" (345, added) and "[§8.6] spells that
    idiom, its exactness condition and the resulting assembly in full" (368).
    The brief asks that the notation point at §8.6, and 345 does that. Fix,
    if the fixer wants it: at 368 write "[§8.6][s8-6] also spells that
    idiom, …".

### Chapter 4 (units E, F and G)

20. **397. EDITORIAL.** "This chapter gives the port" uses a weak verb. The
    port is glossed but not linked, though the leads of §2 and §3 link their
    first terms. Fix: "This chapter defines the [port](#g-port), the
    addressable unit through which components exchange immutable values."

21. **431. RULING.** "**the signal requirement is immutability plus frozen
    references** ([D-243])" is a Rationale-only bold (R6, row 99), and the
    entry points back. D-243's only words for it are "[§4.1] requires of a
    port value immutability plus frozen references" (log 9210). D-231's
    Position, cited in the next sentence, says "The frozen-reference latitude
    of [§4.1] stays with signals" (log 8691). Both entries take §4.1 as the
    authority, which is lesson 16's circle. No entry rules the requirement.
    Options: (a) keep the bold and record that the log owes a Position for
    it, for example on D-004 ("Immutable value signals in a typed signal
    table"), whose Position is the nearest ruling; (b) make the sentence
    plain, citing D-004.

22. **409–410 (the known leftover). RULING, owner item.** The sentence is in
    §4.1, not §4.3. "Every [component] provides two output stages" is untrue
    of an assembly. The rewrite made it worse than the old text: old 306–307
    carried it inside a parenthetical gloss of *stage function*, and now it is
    a standalone claim with its own citation. The same claim stands in §5.2
    (base 696), the *stage function* glossary entry (base 12951, "every
    component provides exactly two output stages") and base 1111. One ruling
    should fix all four, for example "Every primitive provides". No fix here.

23. **412, 440, 502, 521. EDITORIAL.** Chapter 4 writes "named tuple"
    (four times), while §3.1 and §3.2 now write `NamedTuple` (R5's F7). The
    base spec writes `NamedTuple` 80 times, and these four are its only
    "named tuple"s. D-036 writes "NamedTuples". Fix: `NamedTuple` at all
    four, including inside the bold at 521.

24. **449–452 and 525–527. EDITORIAL (growth).** The leaf address is glossed
    twice in adjacent sections, in the same sentence shape ("A reader reaches
    a … through the port's leaf address (the field name with dotted and
    bracketed steps below it…) … ([§14.4], [D-276])"). Survey part B item 8
    flagged this. Fix: §4.3 keeps its link and lets the example gloss it.
    "A reader reaches a nested field by its [leaf address](#g-leaf-address),
    as in `"pose.q_eb"` ([§14.4][s14-4], [D-276][d-276])."

25. **482. EDITORIAL (optional).** "class-blind" (F9) uses *class* in its
    glossary sense, and this is its first use in §4.3. Fix: link it,
    "[class](#g-class)-blind". The next sentence already glosses it ("whether
    it is primitive or composite").

26. **560–562. EDITORIAL.** The gloss and the citation sit back to back,
    "(a capability the design admits but does not build) ([D-036])". The gloss
    then repeats the next sentence's "it is not built". Fix: "A
    field-projection connector is a [guarded addition](#g-guarded-addition)
    (a capability the design admits but does not build), and its shape is
    obvious ([D-036][d-036])."

27. **574–579. EDITORIAL (growth).** Five sentences of introductions come
    before the sketch. "`KinPose` is the illustrative struct above" repeats
    524's "where `KinPose` is an illustrative struct". Line 576 renders at
    87 columns. Fix: drop ", and `KinPose` is the illustrative struct above"
    and rewrap.

28. **608–612. EDITORIAL.** The port gloss "(a port is one declared name
    with its cell)" splits the bold clause from its own "called field
    handles", and it differs from every other port gloss. Line 610 renders at
    89 columns. Fix: "**Ordinary [ports](#g-port) carry them as immutable
    query objects**, called [field handles](#g-field-handle), because of that
    shape ([D-008][d-008]). A port is one declared name with its cell."

29. **614. EDITORIAL (growth).** Only §4.4 glosses *component*, "(the unit of
    modeling, leaf or assembly)". §4.1, §4.2 and §4.3 link it bare, and by
    §4.4 the reader has met it in every section. Fix: drop the gloss and keep
    the link.

30. **626. RULING (source check).** The gloss "the geoid undulation grid (the
    geoid's height above the reference ellipsoid)" cites no source.
    `G/rulings.md` 78–80 calls it "the standard definition", the same
    footing R16 refused for the turbulence gloss. A source exists:
    FlightPhysics `geodesy.jl` 226–228 relates ellipsoidal and orthometric
    altitude "by the geoid's height", `HEllip = HOrth + get_geoid_height`,
    and 163 calls the EGM96 grid "geoid height". Fix: the orchestrator
    accepts that source, and G's rulings record it. The gloss can stay as
    written.

31. **681–684. RULING.** R11 asked for a sentence "claiming only what
    Flight.jl's landing-gear note says". The text adds ", the query a terrain
    field handle's `ray_intersect` serves". G's verifier asked for the clause
    (`G/verify.md` 7 and 40), as the old "dovetails" link to §4.4's
    mechanism. The clause is fair to the old text, but it goes beyond R11's
    wording. The orchestrator confirms or drops it.

32. **686–689. EDITORIAL.** The [abstract input entry](#g-abstract-entry) is
    linked with no gloss, so "below the bound" (689) is reader-cold. Fix:
    "…declared with an [abstract input entry](#g-abstract-entry) (an input
    whose declared type is abstract), here the illustrative
    `terrain = AbstractTerrainField`." This uses the glossary's words (12829).

### Whole chapter

33. **Wrap. EDITORIAL.** Three lines render over 80 columns: 449 (89), 576
    (87) and 610 (89). Findings 27 and 28 cover 576 and 610. At 449, rewrap
    after "(`"dyn/vel"` and `"dyn/f_c_c"` ([D-040][d-040])." Broken short lines
    are left inside paragraphs: 129, 133, 136, 149, 187 ("That modeling is"),
    244, 362–363, 376–377 and 686. Rewrap each paragraph to 80 rendered
    columns. A long source line that carries links is not a defect.

34. **87–88, 296–297, 393–394. EDITORIAL.** Two blank lines fall at three
    unit seams, because units A, C and D end `new.md` with an extra blank
    line. Fix: trim each to one blank line.

## Growth, judged

The text grew 22%, from 4,285 to 5,212 words. §2 grew 61% and §2.2 47%,
mostly from rulings (R4's formula clause, D-001's context bolds, F1, F2,
R9's clause, D-180) and from spelled-out abbreviations. Those earn their
place. The additions that cost more than they give are findings 9, 14, 24,
27 and 29. Each repeats a gloss or a definition the reader met one section
earlier. Finding 7's pacing gloss, "The pacer inserts waits between
completed frames and never alters the boundary sequence", is the glossary's
entry verbatim (13224). It brings in two cold words, *frames* and *boundary
sequence*, but it is the cheapest honest gloss, so it stays. Only two
sentences still carry two glosses: 317 (finding 13) and 131 (finding 5).

Not flagged, by design: *periphery* and *root input* are glossed again in
§4.3 after §4.1 (the per-section rule); §2.1 links *boundary-detected* and
*localized* (142–143) before the bullets define them, and "The two policies
follow" points forward (R4's order); §3.4's "two leaf classes" beside the
linked *class* at 304 is the trap `spec_style.md` records.

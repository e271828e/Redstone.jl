# Brief: the readability rewrite of spec chapter 6

You rewrite one unit of chapter 6 of `docs/design/spec.md`, "Composition:
connections, aggregation and hierarchy", for readability, with no loss of
content. Three agents work in parallel, one per unit. This file is the same
for all of them; your prompt names your unit.

Paths below are relative to `docs/spec_rewrite/ch06/` unless they start
with `docs/`. Run the checker from `docs/spec_rewrite/`. The base commit is
`b08afca`; old spec lines below are lines of `spec.md` at that commit. Read
spec text at the base with `git show b08afca:docs/design/spec.md`, since
another session may edit the working tree's spec. Line 1 of
`chapter_old.md` is spec line 1221.

## Read first

1. `docs/design/tools/spec_style.md`, all of "Sentences", "Terms", "Section
   template", "Marking rulings", "Rationale" and "Content preservation". It
   is the convention you write to. This brief does not restate it.
2. Chapters 7 and 8 of `spec.md`, finished chapters written to the
   convention, read by section: §7.1 and §8.2 at least. §8.2 states much of
   what unit B touches; unit C should also read §8.6 and §8.8's `Systems`
   example.
3. `survey.md`: part A for your unit's rows, part B's overlaps, part C's
   moves, order and bold table for your unit, part D's rows for your lines
   and its list of phrases quoted from outside, part E's items for your
   lines, and part F. Part F's warnings apply to every unit. Read them all.
   Where a ruling below differs from the survey, the ruling wins.
4. Your unit's `units/<U>/old.md`, the text you rewrite.

Read `spec.md` by section via its heading outline, never whole. Read a
decision entry in `docs/design/decisions.md` in full before you cite it or
claim what it rules. Grep the log; never read it whole.

## Rulings already made

These are the orchestrator's rulings at checkpoint 1, each on the survey's
part G question named. Apply the ones that touch your unit, and tag each
such claim in the inventory with `"tag": "R"` and `"ruling": "<id>"`.

- **R1. "Type-checking a wire" keeps the clauses, stated plain** (q1, option
  a; M1, M2; unit B).
  - The old **Rule.** sentence becomes a plain context sentence: once both
    endpoints resolve, two clauses check the wire, pointing to §8.2. §8.2
    bolds it.
  - The bound check stays, plain, with `WireTypeMismatch`, citing D-078.
    §9.1 bolds it.
  - The walk-compatibility clause stays, plain, with "for a continuous
    consumer only" in words, unbolded. Gloss *walking* and *pinned* as the old
    text does.
  - M1: old 1321–1326, the tier-scope paragraph, becomes one plain sentence
    right after the walk clause. A discrete consumer takes the bound check
    alone, so a continuous producer feeding a discrete consumer is
    unconditionally legal. Cite D-295 and D-263, never D-167, and point to
    §8.2 for the reason. Map the cut claims to their spans in §8.2
    (2433–2439 at the base). §8.2 bolds this ruling, which settles the
    carried item in `docs/spec_rewrite/README.md`.
  - M2: the run sentence (old 1308–1310) moves before the abstract-entry
    paragraph, which needs "the marker" defined. "Both sides" becomes "the
    producer's declaration and the entry", since the move takes its
    antecedent away. Keep "marker scalar", "declaration reading" and "no
    user stage code runs", with the pointer to §9.1. §9.1 bolds the run.
  - The opaque leaf, the violation with its payload and both remedies, and
    the failure asymmetry all stay stated in §6.1. §8.2 points here for the
    bound check's kind and the remedies (lesson 16), and tests cite "failure
    asymmetry" and "first nominal build" word for word.
- **R2. §6.1 names the locality law** (q2, option a; M5; unit A). Add one
  declared clause at old 1251–1252 that calls "each assembly speaking only of
  its own children" the locality law, cites D-065 for the name, and points
  to §14.2, where fragments follow the same law. Claim nothing else D-065
  says: not the count of instances, not ownership, not `at`. The rule itself
  stays stated in §6.1's own words under D-207. Never cite D-065 for the rule:
  D-065 points back to §6.1 for it (lesson 16).
- **R3. Flight.jl names, introduced in place** (q3, amended). Reason:
  spec_style's reader-cold rule. Every clause below claims only what its
  named source says (lesson 14).
  - Unit A, the routing example (old 1252–1260): one introducing clause
    saying it is a sketch of an aircraft. The root `Cessna172` holds a systems
    assembly `Systems`, which holds the landing gear `Ldg`, whose three legs
    are `left`, `right` and `nose`. `trn` is a terrain field handle,
    pointing to §4.4 for field handles. The sources are
    `companions/trim_environment_walkthrough.md` 303 (where `trn` is a
    `HorizontalTerrainField`) and `companions/flight_case_studies.md` 33
    (terrain as a field-handle signal, §4.4). Do not say the tree is
    Flight.jl's. In Flight.jl a vehicle level sits between the aircraft and
    its systems.
  - Unit C, old 1361–1364: "today they are the work of the generated …
    tree walks" becomes Flight.jl's. In Flight.jl these totals come from
    FlightPhysics' generated functions `get_wr_b`, `get_mp_b` and `get_hr_b`,
    which sum each quantity over a model tree. Source:
    `Flight.jl/lib/FlightPhysics/src/dynamics.jl` 328–393.
  - Unit C, old 1453: "FlightCore's tree walk" becomes "FlightPhysics' tree
    walk" (F7, checked in the source above).
  - Unit C, old 1454–1455: **the C172 count stays in §6.2**, introduced as
    Flight.jl's Cessna 172 model. This differs from the survey's M9, which is
    withdrawn. The count gives the idiom's scale for a real aircraft, and it is
    constructive. One introducing clause meets the reader-cold rule, so a
    companion move buys nothing. "They read as a manifest" keeps its subject.
  - Unit C: `Wrench` at its first use in §6.2 is FlightPhysics'
    force-and-torque type (`dynamics.jl` 114). `pwp` is introduced as the
    powerplant and `aero` as the aerodynamics, at their first prose use.
    `Vehicle{NoVehicleSystems}` is FlightPhysics' vehicle with no systems,
    and `VehicleDynamics` its rigid-body dynamics component (D-143 Rationale).
    Newton–Euler gets "the rigid-body equations of motion". "A loads monitor"
    gets "a component monitoring structural loads", and claims nothing more.
  - Unit C, old 1458: "Frame responsibility is unchanged" becomes "Frame
    responsibility is as in Flight.jl". The sentence after it stays.
  - `VehicleWrenchSum` and `sum_ports!` are made-up names their own sentences
    introduce. They stay.
- **R4. Bold, one per ruling** (q4, q5). Thirteen bolds for the chapter,
  each on its headline clause, with the entry cited in the same sentence:

  | unit | entry | ruling | where (old) |
  |---|---|---|---|
  | A | D-207 Position sentence 1 | every wiring endpoint names an immediate child and one of its faces | 1239–1240 |
  | B | D-236 Position bullet 1 | an abstract entry is checked on the whole declaration | 1316–1319 |
  | B | D-264 Position sentence 1 | a frozen opaque leaf is admitted at an unpinned entry as the producer's cell | 1298–1302 |
  | B | D-264 Position sentence 2 | the identity rule for an opaque leaf governs a store, never a wire | 1303–1304 |
  | B | D-170 Position, last chained ruling | every input takes exactly one connection | 1339–1340 |
  | B | D-084 Position | unconnected outputs are legal, with no warning | 1348–1349 |
  | C | D-037 Position, ruling 1 | aggregation is explicit junctions, positional or site-specific, plain components | 1366–1367 |
  | C | D-037 Position, ruling 2 | an assembly owning contributors aggregates them and exports the total | 1441–1443 |
  | C | D-037 Position, ruling 3 | fold order is author-visible | 1424–1428 |
  | C | D-037 Position, ruling 4 | the helper sugar is guarded | 1466–1467 |
  | C | D-311 Position bullet 3 | the parameters are the nominal port types and the arity | 1386–1388 |
  | C | D-143 Position, the spelling | the zero-contributor spelling is a library `Constant` wired to the consumer | 1486–1487 |
  | C | D-143 Position, clarification (i) | the `Constant` is the banned default's opposite | 1493–1496 |

  Readings recorded so the bold check across chapters does not flag them:
  - **D-207 bullet 2 is one ruling, bold at §9.2** (q4 (i), option b, against
    the survey's recommendation). The bullet joins totality and retention
    with "and" and introduces totality with "therefore", a consequence of
    the one-level rule. spec_style keeps bold off consequences, and §9.2
    already bolds the bullet's content with D-207. §6.1 states "the face
    graph is total" plain, keeps those words, and cites D-207 in that
    sentence.
  - D-048 bullet A is bold at §9.1. §6.1's whole-tree check is plain,
    citing D-048 (q4 (ii)).
  - D-264's two sentences are two rulings, and D-037's four semicolon-chained
    rulings are four. D-143's clarifications (i) and (ii) are two rulings,
    and (ii), the value as instance data, is §13.7's.
  - D-311 bullet 3 is bold in §6.2, which defines the junction (q5, option
    a). §13.7's second bold on it goes to chapter 13's carry list at landing.

  Nothing else is bold. That covers the term bolds *total*,
  *walk-compatibility clause*, *failure asymmetry* and *named site-specific
  junction*, the emphasis on "not", and the bullet lead-ins of "What the
  explicit form buys" except fold order's. All nine **Rule.**, **Why.** and
  **Example.** labels go.
- **R5. Orders and labels** (q6, option a, amended). Part C's order for each
  section, with these labels:
  - §6.1 keeps "How far a path may reach" and "Type-checking a wire". M3: in
    the first, the three wiring declarations and the word "wire" come before
    the endpoint rule. M4: "Fan-out and fan-in" and "Unconnected ports" merge
    under one label, **"Connections per port"**, a topic label rather than
    the survey's claim-shaped "One producer per input". Its order is part C's.
    Inside it one declared sentence may say that both the two-producers and
    the unconnected-input checks are decided at the root, since neither is
    decidable below it, citing D-048. That fact is in D-048's Rejected list
    only, so list it under "Rationale-only rulings". Unit A's roadmap
    sentence (old 1233–1235) follows these labels.
  - §6.2 gains a roadmap sentence in its opening naming its four `####`
    parts. M7: old 1469–1472, the junctions as the library's seed, moves
    beside "The Bool gates of §13.7" (old 1396–1397). Old 1438–1439 ("This is
    what replaces the tree walk …") goes after the idiom's example, rewritten
    so "these ports" has an antecedent. The labels become "What the explicit
    form buys", "The hierarchical aggregation idiom", "Zero contributors" and
    "The cost".
  - Check the final order of your unit for define-before-use yourself.
- **R6. Appendix C kinds named** (q7, option a). Unit A names
  `PathResolution` where `resolve` enforces the rule (old 1279–1281). It
  also adds one declared clause in "How far a path may reach": an endpoint
  naming no port of the child it resolves to is `UnknownPort`. Read D-113
  and Appendix C (spec 12286–12289 at the base) first, and claim nothing
  beyond them. Unit B names `TwoProducers` (old 1343) and `UnconnectedInput`
  (old 1349–1357) where their conditions are stated. §6.2's two error
  mentions stay unnamed.
- **R7. The silences are scoped** (q8, option a; F2; unit C). Old 1415
  becomes "A contributor the junction counts but nobody wires is an
  unconnected-input error naming `in4`". Old 1503 becomes "with every
  silence in the aggregation's bookkeeping inverted into a warning or
  error". Add one plain sentence near the first, citing D-084: a
  contributor's output that nobody wires stays legal and silent, as any
  unconnected output does. Reason: D-084's Position settles the fact, and the
  narrowing changes nothing the framework does.
- **R8. The raggedness census is cut** (q9, option a; M8; unit C). "Aero has
  wrench but no mass, fuel the reverse, and only `pwp` has angular momentum"
  (old 1462–1463) goes, mapped to D-037's annotation in the log, which
  holds it word for word. The rule against bundling, "Contributors are
  ragged" (which old 1476 needs) and the hazard clause with "silently sum
  nothing" stay. Old 1369–1370 and 1505–1506 stay.
- **R9. Factual corrections** (q10), each with its evidence in survey part E.
  Each was grepped for every instance in the chapter.
  - Unit A: F3, "A `local_wires` pair" (old 1241). The rewrite's citation of
    "local wire" adds D-314 beside D-303.
  - Unit B: F4, "local wire" for "sibling wire" at old 1342 and 1354 (D-314
    Position). F10, D-295 and D-263 for D-167 (old 1326, under M1). F15:
    quote the two remedies as the message's text, word for word from
    Appendix C (spec 12304 at the base), so "if the freeze is genuine"
    reads as quoted text. Write "awaiting a wire from above" for "awaiting a
    claim from above" (old 1353). Write "input entry" at the first use of
    *entry* in "Type-checking a wire", since the glossary says *entry* is
    never used bare. Later uses in the same subsection may say "the entry".
  - Unit C: F1, `wr_sum::SumJunction{Wrench{Float64}, 3}` (old 1400; D-311
    bullet 3; the survey's probe fails the build with the old form). F5,
    `wrench` for `wr_b` at old 1439 and 1449 (the code block, §8.8). F8, "the
    inventory grows by judgement against the three guidelines §13.7 states"
    (old 1472; D-313). F9, drop D-007 at old 1503 and 1505, leaving D-037. F15,
    "a bundled contribution struct" for "a bundle" (old 1463), if the
    sentence survives R8 in that form. F18, "the leaf walk" for "the
    activation walk" (old 1393). F19, "(§8.6)" for "(§3.3)" (old 1443). F20,
    `"wr_sum/out"` for `wr_sum.out` (old 1418). The `Junction` block stays
    verbatim. Old 1389's sentence gains "which infers `F`" (D-311 bullet 1),
    since the block does not show that constructor.
- **R10. The units** are the survey's three (q11, option a), below.

Left as written, flagged and listed in `rulings.md` if you touch them: F6
(the two sketches of the hierarchy disagree on where the dynamics sits), F13
(the failure asymmetry's input side assumes a walking producer; neither
sharpen nor drop it), F14 ("one declared `Pinned`"), F16 ("a store" in
§9.5's sense; never link `#g-store` there) and F17 ("Fan-out is free";
never generalize it). If you find a new factual problem, it stays as written
and goes to `rulings.md`.

## Rules for every unit

- **Keep every claim**, with its strength and scope: never, only, must,
  may, exactly, every, at most, deliberately, unconditionally. Keep every
  causal link in its direction. Make no claim the old text does not make,
  except what a ruling above orders. A transition that asserts nothing is
  fine.
- **A gloss or an introducing clause claims nothing beyond the source it
  names.** Chapter 10's rewriters invented a demo's file and aircraft, and the
  verifiers caught each one.
- **Moves** are limited to the rulings above and the survey's part C moves
  for your unit, M9 excepted. A claim you would like to move or delete
  otherwise stays, and the proposal goes in `rulings.md`.
- **Bold**: follow `spec_style.md`, "Marking rulings", and R4's table. Bold
  the headline clause only. Its D-citation may sit anywhere later in the
  same sentence. Every old label goes, and every bold lead-in becomes a
  `####` topic label, a plain topic sentence, or a bold headline clause with
  its citation. A rule with no entry stating it is stated plain:
  `check_bold.jl` refuses a bold with no D-citation. The one-bold test for
  old entries: semicolons separate rulings, and "+" or a comma list joins
  clauses of one ruling. Before you finish, grep the other units' `new.md`
  files and chapters 7 to 10 of `spec.md` for bolds citing the same entries
  as yours (`scratch_survey/bold_rewritten.txt` lists the latter). List any
  ruling bold in two places in `rulings.md`.
- **Subheadings**: `####` topic labels, never a question or a claim. Check
  your final order for define-before-use: no term or name is used before the
  text that defines it, unless a pointer says where.
- **Glossary links**: one per term per section, at its first use, with the
  gloss `spec_style.md` asks for. This means not every link the old text had.
  A term whose first use moved needs its link at the new first use. Survey
  part F lists the links to keep (`#g-summing-junction`, its only body link;
  `#g-nominal`; `#g-container-children`) and the first-use links to add
  (`#g-assembly` and `#g-root-input` in §6.1, `#g-abstract-entry`,
  `#g-guarded-addition`, `#g-constant-source`, `#g-leaf-walk`).
- **Reserved words.** The glossary restricts these, so use each only in its
  glossary sense. Bare "tier" means only the continuous or discrete side.
  Bare "cell" means only a signal-table entry. "Entry" is never bare at
  first use (R9). *Claim*, *bundle* and *the freeze* have glossary senses the
  chapter does not mean (R9's F15). "Store" at old 1304 is §9.5's sense, so it
  takes no link. Other reserved words are *seam*, *activation*, *nominal*,
  *contract*, *face*, *walked*/*pinned* and *leaf walk*.
- **The `Model` rule** (spec_style, "Terms"): a sentence about declaring,
  wiring, building or checking what the user wrote says "the component tree"
  or "the root". Keep "configuration" as it is; it is not "model".
- **Citations** stay reference-style: `[§8.2][s8-2]`, `[D-207][d-207]`,
  `[Appendix C][sC]`. Never cite a superseded entry: D-007 and D-167 are.
  Every citation you add or replace goes in `rulings.md` with the entry's
  words that carry it. Survey part E, "Entries to cite at the rule", lists
  the entries that rule your rows uncited. Add a citation where the entry's
  text carries the claim, after reading it. Where only a Rationale or a
  Rejected list carries a ruling, cite the entry and list the case under
  "Rationale-only rulings". Never cite D-051 or D-143 for the ban on silent
  defaults, nor D-065 for the one-level rule: each points back to §6.1
  (lesson 16).
- **The log's vocabulary is old**: never import `child_connections`,
  `input_connections`, `output_connections`, `inner_wires`, "inner wire",
  `output_types`, `h_xu`, `input_types`, "root slot", "Stratum A", `init_x`,
  `faces` (as a method) or "generic boundaries" into the spec when citing an
  entry.
- **The chapter cites by adjacency.** Many rules have their citation a
  sentence or a paragraph away. A split or move that separates a rule from
  its citation repeats the citation. Survey part F, "Citations covering
  several clauses", lists the known cases.
- **Code**: carry the three fenced blocks verbatim. New display blocks are
  not needed.
- **Terms of art and quoted phrases stay verbatim**: survey part F's list
  and part D's list of phrases quoted from outside. The most exposed are
  "immediate child and one of its faces", "level by level", "the face graph
  is total", "walk-compatibility clause", "marker scalar", "failure
  asymmetry", "first nominal build", "exactly one connection",
  "two-producers", "whole-tree", "obligation chain", "unconnected-input
  error", "no silent defaults", "in component clothing", "There is no
  framework aggregation mechanism", "positional order" and "arbitrary
  stage-2".
- **Scratch files** go in your own `units/<U>/`, nowhere else. Edit no file
  outside `units/<U>/`.
- Run nothing in the background. Use `/bin/ls` or `fd`, never a bare `ls`.
  Never stash, reset, check out or commit.

## What you produce

In `units/<U>/`:

- `new.md`: the rewritten text. Unit A's starts with the "## 6." heading and
  the chapter opening. Each unit's starts with its first heading and ends
  where its old text ends, moves aside. Unit C keeps the chapter's closing
  `---` as its last line.
- `inventory.json`, in this shape:

  ```json
  {"claims": [{"id": "C-001", "old": "...", "new": "...", "where": "new",
               "cites": ["§8.6"], "newcites": ["§8.6", "D-170"], "tag": "F"}],
   "added": ["a new sentence with no old source, normalized"]}
  ```

  One entry per atomic claim of `old.md`, in order. `old` is the claim's
  verbatim span in the normalized old text, and `new` its verbatim span in
  the normalized text at `where`. Print both normalized texts with

  ```
  python3 checks/check_unit.py ch06 show-old <U>
  python3 checks/check_unit.py ch06 show-new <U>
  ```

  and copy spans from that output. `where` is `"new"` for your own text. For
  content held elsewhere it is the path that holds it:
  `docs/design/spec.md` or `docs/design/decisions.md` for text outside the
  chapter, and `units/<V>/old.md` for content another unit owns. `cites`
  lists the citations inside the old span, and `newcites` those your new
  text attaches, if they differ. `tag` is `F` for a fact carried over, `X`
  for framing, `M` for moved or held elsewhere, `C` for a citation added or
  replaced, and `R` for a ruled edit, with its `"ruling"`. `added` lists,
  verbatim and normalized, every new sentence or clause with no old source.
- `rulings.md`, with these sections: **Corrections proposed** (quote, line,
  evidence, proposed text); **Citations added or replaced** (entry, the words
  that rule it); **Rationale-only rulings** (entry, field, log line);
  **Bold on the same entry elsewhere**; **Inbound citations affected**;
  **Open questions**.

Run `python3 checks/check_unit.py ch06 check <U>` until it prints
`checks failed: 0`. A cold verifier then reads your text blind and matches
it against your inventory. Drift that passes the script still fails there.

## The units

Line numbers are old spec lines at `b08afca`. Survey part F rates each
unit's difficulty and names its hazards.

**A: the chapter heading and opening, §6.1's context and "How far a path may
reach"** (1221–1282, 501 words).
- The opening stays as it is, apart from wording. The context paragraph's
  roadmap sentence follows R5's labels.
- R2, R3 (the routing example), R4 (D-207 sentence 1; totality plain), R5
  (M3), R6 (`PathResolution`, `UnknownPort`), R9 (F3).
- "The second consequence" (old 1265) needs the first, substitutability at
  every boundary, before it. "The ceremony this costs" (old 1271) points at
  one-level routing; keep it after the reasons. §6.1 links `#g-face` twice
  today; keep the first.

**B: "Type-checking a wire", "Fan-out and fan-in" and "Unconnected ports"**
(1283–1358, 656 words).
- R1 (M1, M2), R4 (five bolds), R5 (M4, the merged label), R6
  (`TwoProducers`, `UnconnectedInput`), R9 (F4, F10, F15).
- The heaviest overlap in the chapter: §8.2 and §9.1 state and bold most of
  "Type-checking a wire". Map every trimmed claim to its span in §8.2 or §9.1
  at the base.
- Antecedents: "on the same terms" (old 1298), "the clause" (old 1316) and
  "The same clause" (old 1328) point at the walk clause, and must still do so
  after M1 and M2. "The rule spans levels" (old 1342) must follow the
  single-connection rule in the merged text.
- D-264 at old 1302 covers the admission only. The identity-rule sentence
  needs D-264 in its own sentence once bold. D-084 covers the output half of
  old 1348–1350 only.

**C: §6.2** (1359–1509, 1,024 words).
- R3, R4 (seven bolds; D-143 is cited nowhere in the chapter today), R5
  (the roadmap sentence, M7, the reorder, the labels), R7, R8, R9 (F1, F5,
  F7, F8, F9, F15, F18, F19, F20, the constructor clause).
- "Ownership boundary" (old 1399) comes before "owns contributors" (old
  1441). One clause at old 1399 ("the assembly that owns the contributors")
  removes the forward use without a move.
- "Ragged contributors" (old 1476) needs "Contributors are ragged", which R8
  keeps. "This is not the banned default" (old 1493) points at the
  `Constant` wire. "This is what replaces the tree walk" changes antecedent
  when it moves (R5); rewrite it rather than moving it bare.
- D-037 at old 1428 covers the fold-order bullet only. The rule (old 1366),
  the idiom (old 1441) and the sugar (old 1466) each need D-037 in their own
  sentences. Old 1486 and 1493 need D-143.

## Log entries this rewrite does not write

The rewrite adds no log entries. Track 2, after landing, takes numbers from
D-321 to D-340. Chapter 5's rewrite, running in parallel in another
session, takes D-341 up.

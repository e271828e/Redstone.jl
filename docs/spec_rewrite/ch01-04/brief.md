# Brief: the readability rewrite of spec chapters 1 to 4

You rewrite one unit of chapters 1 to 4 of `docs/design/spec.md`
(Introduction, Formalism, Component taxonomy, Ports and signals) for
readability, with no loss of content. Seven agents work in parallel, one per
unit. This file is the same for all of them; your prompt names your unit.

Paths below are relative to `docs/spec_rewrite/ch01-04/` unless they start
with `docs/`. Run the checker from `docs/spec_rewrite/`. The base commit is
`d3af35a`. Old spec lines below are lines of `spec.md` at that commit; the
frozen copies `scratch_survey/spec.md` and `scratch_survey/decisions.md` are
byte-identical to it. Other sessions may edit `spec.md` during this rewrite, so
never read it from the working tree.

## Read first

1. `docs/design/tools/spec_style.md`, all of "Sentences", "Terms", "Section
   template", "Marking rulings", "Rationale" and "Content preservation". It
   is the convention you write to. This brief does not restate it.
2. A finished chapter written to the convention: §5.1, §5.2 and §10.6 of the
   base spec at least, read by section. Chapter 5 is the newest rewrite and
   states much that chapters 2 to 4 touch.
3. `survey.md`: part A for your unit's sections and its "Bold, one per
   ruling" table; part B's overlaps; part C's moves, order, code blocks and
   glossary links for your unit; part D's rows for your lines; part E's items
   for your lines; and part F whole. Part F's warnings apply to every unit.
4. Your unit's `units/<U>/old.md`, the text you rewrite.

Read `spec.md` by section via its heading outline, never whole. Read a
decision entry in full before you cite it or claim what it rules. Grep the
log; never read it whole. `scratch_survey/entry.sh 036` prints D-036 with its
log line numbers.

## Rulings already made

These are the orchestrator's rulings at checkpoint 1, each on the survey's
part G question named. Apply the ones that touch your unit, and tag each such
claim in the inventory with `"tag": "R"` and `"ruling": "<id>"`.

- **R1. The README's two chapter 3 items** (q1). (i) Unit D: §3.4's lead-in
  "**Algebra removes the reset.**" (old 415) becomes a plain topic sentence
  that points at §8.6, which bolds D-056's first bullet. (ii) Units C: F7, in
  R5.
- **R2. Chapter 1's labels** (q2, option a; unit A). The five bold lead-ins
  become `####` subheadings: Purpose, Capabilities, Design criteria, Origins,
  Scope of this document. The five criterion names lose their bold and stay
  as the opening words of their bullets, in plain text. Chapter 1 takes no
  bold. Keep "debugging, tooling and comprehension" verbatim (§8.1 quotes
  it).
- **R3. Openings** (q3, option a). Unit B: §2's lead gains one roadmap
  sentence naming §2.1 and §2.2 by subject. Unit C: §3's lead gains one
  naming §3.1 to §3.4 and saying §3.4 justifies the split. Unit E: chapter 4
  gains an opening, one or two sentences naming §4.1 to §4.4 by subject.
  Source them only from the Part I roadmap (old 124–129), the section titles
  and the sections' own content. Every word is a declared addition.
- **R4. §2.1's order and §2's formula** (q4; unit B). (i) Apply part C's M3
  and its order: one declaration; the predicate, edges and opposite direction;
  the return type deciding the policy, plain, pointing at §10.4; the two
  policies; pace-independence; "the crossing defines the transition"; time
  and state events last. (ii) §2's continuous bullet gains one declared
  clause saying §5.3 lets `f` read the published table too, with the
  composite map unchanged. Its only source is §5.3 old 954–958; quote its
  words. No new formula. §3.1's flow (old 308) and §3.2's update (old 333)
  stay as written.
- **R5. Factual corrections** (q5, lesson 13). Apply exactly, then grep your
  unit for every other instance.
  - F1 (unit B, old 291–292): "The gear friction regulator under `!wow` is
    one such reset" becomes "Flight.jl resets the gear's friction regulator
    while `!wow` (no weight on wheels) holds; here that reset becomes an
    event on the touchdown edge", keeping `[§5.3]` and `[D-001]` and adding
    `[D-141]`. Source: FlightPhysics `landinggear.jl` 467
    (`!strut.y.wow && f_init!(contact.frc)`); D-141 Position, log 4730–4738.
  - F2 (unit B, old 223): "applied after each accepted step" becomes
    "applied after each accepted step and after any handler reset of `x`
    ([§5.3])". Source: §5.3 old 1019–1021.
  - F4 (unit B, old 238–239): "one guard evaluation per event per step"
    becomes "one guard evaluation per event per iteration round ([§10.6])".
    Source: §10.6 old 6093–6099.
  - F5 (unit A, old 170–171): "The inner loop allocates nothing, and the test
    suite asserts it" becomes "The phase bodies the stepping loop runs
    allocate nothing, and CI asserts it", keeping both citations. Source:
    §7.5 old 2075–2076 ("CI-enforced at the measurement seam that
    `phase_bodies` exposes"); D-305 bullet 1.
  - F7 (unit C): old 305 "an isbits struct of real scalars ([§7])" becomes
    "a NamedTuple whose leaves are real scalars and `SArray`s ([§7.1],
    [D-094])", from §7.1 old 1687–1691, which says neither flat nor nested; old
    332 "any isbits value ([§7])" becomes "a NamedTuple whose fields are each
    isbits or a `Symbol` ([§7.3], [D-231])".
  - F8 (unit E, old 477): "(`dyn.vel`, `dyn.f_c_c`)" becomes
    "(`"dyn/vel"`, `"dyn/f_c_c"`)". D-040 Position and Rejected.
  - F9 (unit E, old 506): "kind-blind" becomes "class-blind", with `[D-172]`
    cited in that sentence. D-122 Position.
  - F10 (unit F, old 547–548): "That leaf is the field handle ([§4.4])"
    becomes "A field handle ([§4.4]) is such a leaf". D-237 Position.
  - Glossary links (unit D): unlink `g-seam` at old 389 and 423 (the
    sampling seam is not the glossary's seam). Old 408 "events are the wrong
    [tier]" becomes "events are the wrong mechanism", unlinked.
  - D-180 (unit B): after old 266–267 (the opposite direction), add one
    declared sentence restating D-180's Position only: a per-event
    `direction` keyword is recorded as a guarded addition, unbuilt
    ([D-180]).
- **R6. The bold table** (q6). Survey part A's table with these choices:
  D-001 four bolds (rows 20, 24, 26 and §2.2's three exclusions), citing
  D-001 beside D-082 at rows 36 and 37; D-003's second ruling at row 56, with
  "therefore" removed; D-056's Position sentence at row 75, label gone;
  D-036's first ruling at row 120. Four bolds whose only source is a
  Rationale, Rejected list or annotation, each cited to that entry and listed
  under "Rationale-only rulings": row 31 (D-220), row 66 (D-231, with D-249
  cited), row 99 (D-243, with D-231 cited), rows 138–139 as one bold
  (D-045). Rows 69 and 116 stay plain. Row 112 cites D-034 beside D-016.
  D-302 at row 96 stays plain. The table's "Not bold" list stands.
- **R7. The rule of meaning** (q7, option a; unit C). Keep its three
  sentences, drop the label, and add one declared clause from D-141's
  Position: on the continuous tier, a commanded reset of state still lands
  through an event whose guard reads that input ([§5.3], [D-141]). Say
  "reset of state", not "mode change": D-141 rules resets. Whether "do not
  overlap" is a ruling goes to the owner; the sentence stays plain and
  uncited.
- **R8. Mutable caches** (q8; unit G). "Caches belong in the consumer's
  state" (old 622) stays as written and goes to the owner. M6 does not
  apply.
- **R9. Two clauses for outside citations** (q9). (i) Unit B: §2.2's third
  bullet gains "because its semantics depend on the step size ([D-001])",
  from D-001's Rejected list, log 370. (ii) Spec old 1091 is retargeted to
  §3.4 at landing; units change nothing for it.
- **R10. Seven units** (q10), as below.
- **R11. History and plans in §4.4** (q11; unit G). Old 663–664, "It
  dovetails with the terrain ray-query direction of the landing-gear
  redesign", becomes a sentence claiming only what Flight.jl's landing-gear
  note says: Flight.jl's landing-gear model finds contact through a bounded
  ray query to the terrain model (`Flight.jl/docs/notes/physics/landing_gear.md`
  48). Old 667–668, "today's `AbstractTerrain` polymorphism", becomes
  "FlightPhysics' `AbstractTerrain` polymorphism" (`terrain.jl` 26).
- **R12. Appendix C kinds** (q12). Unit F names `ProducedByTwoStages` where
  old 528 states its condition; unit E names `UndeclaredReturnField` where
  §4.2 states its condition. `DeclarationOnWrongTier` stays unnamed in §3.
- **R13. Held as written** (q13). "Fan-out is free" (old 570) stays plain
  and uncited: it is an owner item. "closed for the first cut" (old 660)
  stays.

## Rules for every unit

- **Keep every claim**, with its strength and scope: never, only, must, may,
  exactly, iff, at most, deliberately. Keep both halves of every two-condition
  ruling (part F). Keep every causal link in its direction. Keep every count
  (part F's list). Make no claim the old text does not make, except what a
  ruling above orders. A transition that asserts nothing is fine.
- **A gloss or an introducing clause claims nothing beyond the source it
  names.** Quote the source's words where you can. A Flight.jl name is
  glossed with its owner as part F gives it (FlightCore, FlightPhysics); an
  invented example name is "an illustrative" name, no more.
- **Moves** are limited to the rulings above and survey part C's moves for
  your unit. A claim you would like to move or delete otherwise stays, and
  the proposal goes in `rulings.md`.
- **Factual problems you find** stay as written and go in `rulings.md` with
  evidence, unless a ruling above covers them.
- **Bold**: follow `spec_style.md`, "Marking rulings", and part A's bold table
  with R6's choices. Bold the headline clause only; its D-citation may sit
  anywhere later in the same sentence. Every **Rule.**, **Why.** and
  **Example.** label goes, and every bold lead-in becomes a `####` topic
  label, a plain topic sentence or a bold headline clause with its citation.
  A rule with no entry is stated plain: `check_bold.jl` refuses a bold with
  no D-citation. The one-bold test for old entries: semicolons separate
  rulings, and "+" or a comma list joins clauses of one ruling. Before you
  finish, grep the other units' `new.md` files and chapters 5 to 10 of the
  base spec for bolds citing the same entries as yours, and list any ruling
  bold in two places in `rulings.md`.
- **Subheadings**: `####` topic labels, never a question or a claim. Check
  your final order for define-before-use: no term or name is used before the
  text that defines it, unless a pointer says where. Chapter 1, as an
  overview, may use a term first and point at its chapter.
- **Glossary links**: one per term per section, at its first use, with the
  gloss `spec_style.md` asks for. Not every link the old text had (part C
  lists the duplicates). A term whose first use moved needs its link at the
  new first use. §4.3 spans units E and F: E links *port*, *face*, *cell*,
  *root input*, *device*, *claim*, *trace*, *stage function*, *tier*,
  *guard* and *snapshot*; F links *leaf address*, *stop request*, *field
  handle* and *guarded addition*, and never relinks E's terms. Chapter 1's
  first use of *guarded addition* (old 168) takes its gloss. Never link
  *bundle* where it means a struct-valued port (all of §4.3), nor *condition*
  at old 408 and 417.
- **Reserved words** (part F's list): *class*, bare *tier*, *kind*, *seam*,
  bare *entry*, *condition*, *bundle*, *register*, lowercase *model*. Where
  you touch a sentence that uses one in another sense, reword it; never link
  it. "There are three classes" (old 298) counts two leaf kinds and the
  assembly: reword it so it is neither glossary sense of *class*.
- **Reader-cold names**: introduce each one, from the start (part F's list).
  Spell out FSM, ZOH, RNG, DCM and DSL at first use in their section. Point
  §3.4's IMU notation at §8.6, which spells it in full; do not gloss its
  physics.
- **Citations** stay reference-style: `[§5.3][s5-3]`, `[D-141][d-141]`,
  `[Appendix C][sC]`. Never cite a superseded entry or a superseded clause.
  Every citation you add or replace goes in `rulings.md` with the entry's
  words that carry it. Survey part E, "Entries to cite at the rule", lists
  the entries that rule your rows uncited (D-002, D-003, D-121, D-172 are
  cited nowhere today); add a citation where the entry's text carries the
  claim, after reading it. Where only a Rationale or Rejected list carries a
  ruling, cite the entry and list the case under "Rationale-only rulings".
- **The log's vocabulary is old** (part F's list): never import "Tier-2",
  "baseline", "kind-blind", `z`, `h_x`, `project`, `init_*`,
  `output_types`, `local_types` or `PIVector` into the spec when citing an
  entry.
- **The chapters cite by adjacency.** A split or move that separates a rule
  from its citation repeats the citation.
- **Antecedents**: part F lists the sentences that open on a word pointing
  back. Every inserted gloss or clause is an antecedent hazard; re-read the
  sentence after each one.
- **Code and math**: carry both fences verbatim. The formulas at old 217,
  218, 308 and 333 and the inline math at 401–406 stay as written.
- **Terms of art and quoted phrases stay verbatim** (part F's list).
- **Owner items stay uncited**: "Fan-out is free" and the rule of meaning's
  "do not overlap" (part E, "The owner's open items").
- **Scratch files** go in your own `units/<U>/`, nowhere else. Edit no file
  outside `units/<U>/`.
- Run nothing in the background. Use `command ls` or `fd`, never a bare `ls`
  (it is aliased to `eza`, which can hang). Never stash, reset, check out or
  commit.

## What you produce

In `units/<U>/`:

- `new.md`: the rewritten text. Each unit's starts with its first heading and
  ends where its old text ends. Units A, B, C and E start with their `##`
  chapter heading; unit G ends with the last line before `## 5.`.
- `inventory.json`, in this shape:

  ```json
  {"claims": [{"id": "C-001", "old": "...", "new": "...", "where": "new",
               "cites": ["§5.3"], "newcites": ["§5.3", "D-141"], "tag": "F"}],
   "added": ["a new sentence with no old source, normalized"]}
  ```

  One entry per atomic claim of `old.md`, in order. `old` is the claim's
  verbatim span in the normalized old text, and `new` its verbatim span in the
  normalized text at `where`. Print both normalized texts with

  ```
  python3 checks/check_unit.py ch01-04 show-old <U>
  python3 checks/check_unit.py ch01-04 show-new <U>
  ```

  and copy spans from that output. `where` is `"new"` for your own text, or
  `docs/design/spec.md` for content held outside the run. `cites` lists the
  citations inside the old span, and `newcites` those your new text attaches,
  if they differ. `tag` is `F` for a fact carried over, `X` for framing, `M`
  for moved or held elsewhere, `C` for a citation added or replaced, and `R`
  for a ruled edit, with its `"ruling"`. `added` lists, verbatim and
  normalized, every new sentence or clause with no old source.
- `rulings.md`, with these sections: **Corrections proposed** (quote, line,
  evidence, proposed text); **Citations added or replaced** (entry, the words
  that rule it); **Rationale-only rulings** (entry, field, log line); **Bold
  on the same entry elsewhere**; **Inbound citations affected**; **Open
  questions**.

Run `python3 checks/check_unit.py ch01-04 check <U>` until it prints
`checks failed: 0`. A cold verifier then reads your text blind and matches it
against your inventory. Drift that passes the script still fails there.

## The units

Line numbers are old spec lines at `d3af35a`. Survey part F rates each unit's
difficulty and names its hazards.

**A: §1** (139–212; 597 words).
- R2, R5 (F5). No bold. Every capability bullet keeps its pointer.
- Chapter 1 is the coldest reading in the spec. Terms used before their
  chapter (feedthrough, execution order, snapshot, trace, `Model`) point at
  it; *guarded addition* takes its gloss here.
- "entries in the decision log" and "Entry numbers" are compounds; keep them.

**B: §2, §2.1, §2.2** (213–295; 631 words).
- R3, R4, R5 (F1, F2, F4, D-180), R6 (D-001's four bolds, D-082's two,
  row 31), R9 (i).
- §2.1's return-type paragraph (old 269–271) loses its bold: §10.4 bolds
  D-179. State it plain, citing D-179, pointing at §10.4.
- Reader-cold: `f_step!` (FlightCore's per-step hook), DCM,
  Dryden/von Kármán, `!wow`, RNG.
- "For one class the mapping tightens" (old 290) uses *class* loosely.

**C: §3 lead, §3.1, §3.2, §3.3** (296–363; 519 words).
- R3, R5 (F7), R6 (D-003 at rows 48 and 56; D-195 at row 63; row 66), R7.
- Part C's M4: §3.2's letter paragraph puts its ruling first.
- "external FSM component" and "Externalized FSM" are quoted elsewhere;
  keep them. "submodels" (old 356) means child components: say so.

**D: §3.4** (364–436; 612 words).
- R1 (i), R5 (glossary links), R6 (D-056 at rows 75 and 90).
- Five rows live only in D-056's Rejected list: cite D-056 and list them
  under "Rationale-only rulings"; only row 75 and row 90 are bold.
- The IMU notation points at §8.6. The antecedent chain at old 377–388 and
  425–428 is dense; re-read after each edit.

**E: §4 opening, §4.1, §4.2, §4.3 through "Scatter and gather"**
(437–529; 748 words).
- R3, R5 (F8, F9), R6 (D-004 row 91, D-121 row 95, row 99, D-172 row 114,
  D-036's second ruling row 118, row 112's D-034), R12
  (`UndeclaredReturnField`).
- The binding vocabulary (store, cell, staging cell, root input; D-121)
  stays exact. The periphery atom's six "one"s are a count.
- Link assignment in §4.3 as the rules above say.

**F: §4.3 "What a port may hold" through "Granularity, write side"**
(530–601; 605 words).
- R5 (F10), R6 (D-036 first, third and fourth rulings at rows 120, 121,
  133; D-237 at rows 127 and 129; D-243 row 128; D-276 row 130; rows
  138–139 for D-045), R12 (`ProducedByTwoStages`), R13.
- *bundle* throughout means a struct-valued port: never link it.
- The code block verbatim. `KinPose` and `RQuat` take introductions (part
  F): `RQuat` is FlightPhysics' rotation quaternion, and `RQuat{Float64}` is
  the spec's form, since FlightPhysics' `RQuat` is not parametric.

**G: §4.4** (602–671; 573 words).
- R6 (D-008 row 143, D-139 row 148 or 149), R8, R11.
- The code block verbatim. The domain names in it are illustrative, except
  `SimpleAtmosphere` and `AirData` (FlightPhysics').
- The mutable-cache bullet: old 622 stays as written (R8). The rest of the
  bullet may point at §4.3's refusal of mutable port types.

## Rulings after step 4

- **R14. F5's wording, corrected** (unit A; verifier A). R5's "The phase
  bodies the stepping loop runs allocate nothing" overclaimed: §7.5 old
  2078–2083 makes only the continuous hot path exactly zero, CI-enforced,
  and gives ticks and handlers zero by idiom with a documented tolerance
  (D-116). The sentence becomes "The continuous hot path allocates nothing,
  and CI asserts it ([§7.5], [§9.7])". The criterion name keeps "type
  stability": §7.5's allocation policy is the type-instability canary
  (D-305 bullet 2), so the bullet's pointer covers it; no clause is added.
- **R15. R12's `ProducedByTwoStages` goes to unit E** (unit F's question 1).
  Old 528, "Name collisions across a component's stages are a build error",
  is the last line of unit E's `old.md`, so unit E names the kind there, not
  unit F.
- **R16. The turbulence gloss** (unit B's question 3). "Dryden and von
  Kármán name two standard atmospheric turbulence models" rests on no source
  in the repository. It shrinks to what the old text says: the noise comes
  from Dryden/von Kármán turbulence models, with no introducing sentence.
  D-002 beside D-001's first bold stands (the survey's table, R6).

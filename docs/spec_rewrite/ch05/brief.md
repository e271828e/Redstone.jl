# Brief: the readability rewrite of spec chapter 5

You rewrite one unit of chapter 5 of `docs/design/spec.md`, "Evaluation
order and feedthrough", for readability, with no loss of content. Six agents
work in parallel, one per unit. This file is the same for all of them; your
prompt names your unit.

Paths below are relative to `docs/spec_rewrite/ch05/` unless they start with
`docs/`. Run the checker from `docs/spec_rewrite/`. The base commit is
`b08afca`. Old spec lines below are lines of `spec.md` at that commit. Other
sessions edit `spec.md` during this rewrite, so read it with
`git show b08afca:docs/design/spec.md`, never from the working tree. Line 1
of `chapter_old.md` is spec line 672.

Another session is rewriting chapter 6 (spec 1221–1509) at the same time,
in `ch06/`. Never read or edit anything under `ch06/`.

## Read first

1. `docs/design/tools/spec_style.md`, all of "Sentences", "Terms", "Section
   template", "Marking rulings", "Rationale" and "Content preservation". It
   is the convention you write to. This brief does not restate it.
2. A finished chapter written to the convention: §10.6 and §9.3 of the base
   spec at least, read by section. Both state much that chapter 5 touches.
3. `survey.md`: part A for your unit's sections and its "Bold, one per
   ruling" table; part B's overlaps; part C's moves, order, code blocks and
   glossary links for your unit; part D's rows for your lines; part E's items
   for your lines; and part F whole. Part F's warnings apply to every unit.
4. Your unit's `units/<U>/old.md`, the text you rewrite.

Read `spec.md` by section via its heading outline, never whole. Read a
decision entry in `docs/design/decisions.md` (at `b08afca`) in full before
you cite it or claim what it rules. Grep the log; never read it whole.
`scratch_survey/entry.sh` prints entries with their log line numbers.

## Rulings already made

These are the orchestrator's rulings at checkpoint 1, each on the survey's
part G question named. Apply the ones that touch your unit, and tag each such
claim in the inventory with `"tag": "R"` and `"ruling": "<id>"`.

- **R1. The chapter gains an opening** (q1, option a; unit A). After `## 5.`,
  a context paragraph saying what the chapter fixes, then one roadmap
  sentence naming §5.1 to §5.6 by subject. Source it only from the Part I
  roadmap (spec 130–132: "the central chapter. It fixes two output stages per
  component, what each stage may see, and how those signatures alone yield a
  static execution order"), the capability bullet at spec 157–158 (the build
  derives the execution order from declared feedthrough and rejects algebraic
  loops by naming the cycle), the section titles and the chapter's own
  content. Every word is a declared addition. It may name terms without
  glossary links; the sections link them. Model: chapter 10's opening. §5.1
  gains one declared clause saying that a cyclic graph is §5.5's subject.
- **R2. The three reorders** (q2, option a), as part C's moves. M1 (unit A):
  "What the views are" follows the hand-off. M2 (unit C): "Why derivatives
  may read outputs" follows "Stage roles: what each stage may see". M4 (unit
  F): the two tracer modes, what tracing seeds and never touches, and the
  `Dual` paragraph follow "Detection and naming". M5 (unit C): §5.3's
  `DeadStage` sentence becomes a pointer to §5.2. Check the final order of
  your unit for define-before-use yourself.
- **R3. "The views themselves are unchanged in meaning."** (q3, option a;
  unit A). It is history: unchanged from the positional signatures the
  bundle replaced. Replace it with a topic sentence the five bullets
  support, saying that each bundle field is a view of one source. Declared
  addition.
- **R4. The step boundary** (q4, option a; unit D). Keep the boundary
  sequence, the blockquote and the hand-off to §10.6 (old 957–963). Merge
  old 926–931 with 939–944 into one statement of the sequence, keeping
  every fact of both. State the epoch rule as one plain sentence, with no
  label and no "Hence", citing D-154 and pointing at §10.6, keeping "a
  handler executes against exactly the world its guard fired on" word for
  word (`event_visibility_walkthrough.md` 12 quotes it). Bold none of D-020,
  D-154 or D-191 here: §10.6 bolds them. Keep every sentence part D's M3
  table names as relied on.
- **R5. Factual corrections** (q5), each with its evidence in survey part E.
  The orchestrator checked each at its cited lines.
  - Unit B, F1: at old 750–751 and 758–759, the failure is
    `BundleFieldError`, not "the §13.2 framing diagnostic". D-248 Position
    bullet 4; §13.2 9252 ("recognized rather than merely framed"). Keep the
    pointer to §13.2 for the catch machinery.
  - Unit B, F2: the table's `x`, `s` and `m` rows read "declares a non-empty
    `x_init`" (and `s_init`, `m_init`), citing D-297 (Position bullet 6) in
    the table or the sentence after it. No other cell changes.
  - Unit D, F3: "the bumpless-engage answer ([§11.7])" points instead at the
    interactive C172X demo's mode-engage frame in
    `flight_case_studies.md`, where that answer now lives (companion 349–350).
    One introducing clause: the C172X demo is the interactive Flight.jl demo
    the companion's section 3 examines. Nothing more.
  - Unit C, F4: the textbook form is $y = h(x, u)$, not $y = g(x, u)$.
  - Unit F, F5: "`init_*`" becomes "the `x_init`, `s_init` and `m_init`
    declarations" (D-267 bullet 1).
  - Unit E, F6: "sampled at `Δt_base`" becomes "sampled on a `Δt_base`-scale
    period", §13.7's wording (spec 10038). The glossed `#g-dt_base` link
    stays.
- **R6. The hand-down cites D-285** (q6, option a; unit B). Old 744–745 cite
  D-252, whose Position is silent on the hand-down. Cite D-285 (Position
  bullet 3) instead, keeping the bold there.
- **R7. Name four Appendix C kinds where their conditions are stated** (q7;
  declared additions, no ruling changes). Unit B: `BundleFieldError` (with
  F1) and `HandlerReturnKey` (old 809–810). Unit C: `DeclarationOnWrongTier`
  (old 868–870). Unit E: `AlgebraicCycle` (old 1115–1116). Unit F:
  `AlgebraicCycle` once, where the diagnostic is described.
- **R8. The units** are the survey's six (q8), below.
- **R9. Bold placements** (q9), as part A's table, with these choices. D-220
  bullet 2 is bold at old 856 (the dependence-class rule); old 865–867 cites
  D-220 plain. D-015 is bold at old 898 (`x_deriv` and `s_update` run after
  the sweep); old 903 cites it plain. The bundle law (row 12, D-074) and the
  commanded discrete reset (row 75, D-089) keep a bold with their
  Rationale-only citation, and go in `rulings.md` under "Rationale-only
  rulings". Row 21 (the closed name sets) is part of the bundle law's
  ruling and is cited plain. D-252 sentence 1 (one producer per port) is
  plain in §5.3, with a pointer to §8.3, which bolds it; sentence 2 (expose
  a field by returning it from `y_state`) is bold in §5.3.
- **R10. §5.4 keeps its shape** (q10, option b; unit E): the two-stage split
  in prose, then the two remedies as bullets. Add only "the ladder's other
  two rungs", or words to that effect, so the count reads as D-140's three
  rungs. `pid_anti_windup.md` counts the bullets as "first rung" and "second
  remedy"; do not number them. Conservatism stays §5.4's last paragraph.
- **R11. Short adversarial sentences stay** (q11). Old 723–724, 804–805,
  1092–1094, 1126–1127 and 1148 each state what is closed and cite the
  entry. None argues. Keep them, with their citations.
- **R12. §5.5 says its diagnostic states the unit delay's caveat** (survey
  F15; unit E). §13.7 (spec 10036–10042) says the caveat "must be stated
  wherever the remedy is recommended" and that "the diagnostic ([§5.5])
  therefore says so". Add one plain sentence after the caveat saying the
  diagnostic states it rather than offering the delay as free, pointing at
  §13.7. Declared addition, claiming only what spec 10042 says.

Left as written, flagged in `rulings.md` if you touch them: F9 (the two
quoted diagnostics differ from `src`'s text; the spec's quotes stay verbatim,
and the orchestrator has logged the gap), F10 ("a library PI block"; do not
add `PIVector`), F11 (bare `h` at old 843: write "`h` in `y = h(x, u)`" or
similar, which is a wording fix, not a correction). If you find a new factual
problem, it stays as written and goes to `rulings.md`.

## Rules for every unit

- **Keep every claim**, with its strength and scope: never, only, must, may,
  exactly, iff, at most, deliberately, conservatively. Keep both halves of
  every "iff … and" (part F). Keep every causal link in its direction. Make
  no claim the old text does not make, except what a ruling above orders. A
  transition that asserts nothing is fine.
- **A gloss or an introducing clause claims nothing beyond the source it
  names.** Chapter 10's rewriters invented a demo's file and aircraft;
  chapter 7's brief itself overclaimed twice. Quote the source's words where
  you can.
- **Moves** are limited to the rulings above and survey part C's moves for
  your unit. A claim you would like to move or delete otherwise stays, and
  the proposal goes in `rulings.md`.
- **Bold**: follow `spec_style.md`, "Marking rulings", and survey part A's
  bold table with R9's choices. Bold the headline clause only. Its
  D-citation may sit anywhere later in the same sentence. Every **Rule.** and
  **Why.** label goes, and every bold lead-in becomes a `####` topic label, a
  plain topic sentence or a bold headline clause with its citation. A rule
  with no entry (survey part E, "Rulings with no entry at all") is stated
  plain: `check_bold.jl` refuses a bold with no D-citation. The one-bold
  test for old entries: semicolons separate rulings, and "+" or a comma list
  joins clauses of one ruling. Before you finish, grep the other units'
  `new.md` files and chapters 7 to 10 of the base spec for bolds citing the
  same entries as yours, and list any ruling bold in two places in
  `rulings.md`.
- **Subheadings**: `####` topic labels, never a question or a claim. "Why
  derivatives may read outputs" is a question-shaped label: retitle it as a
  topic. §5.6's lead-in "Boundaries." collides with the step boundary:
  rename it, as part C suggests. Check your final order for
  define-before-use: no term or name is used before the text that defines it,
  unless a pointer says where.
- **Glossary links**: one per term per section, at its first use, with the
  gloss `spec_style.md` asks for. Not every link the old text had (part C
  lists eleven duplicates). A term whose first use moved needs its link at
  the new first use. Never link *bundle* where it means a struct-valued port
  (old 974, 1091–1092), or *trace* where it means the tracer's result (old
  1166, 1178).
- **Reserved words** (part F's list): bare *entry*, *class*, *cell*,
  *binding*, `h`, and *schedule* in D-258's sense. Where you touch a sentence
  that uses one in another sense, reword it ("executor entries",
  "classification", "cell values"); never link it.
- **Reader-cold names**: introduce each one, from the start (part F's list).
  Spell out ZOH, FSM, AD, SCC and RHS at first use in their section.
  `f_ode!` is FlightCore's fused in-place derivative function. `f_c_c` points
  at §3.4's strapdown IMU example rather than glossing its physics. The
  α-filter idiom may be glossed as "a filter state inserted in the loop", no
  more.
- **Citations** stay reference-style: `[§9.3][s9-3]`, `[D-252][d-252]`,
  `[Appendix C][sC]`. Never cite a superseded entry (D-016's annotated
  clauses, D-165). Every citation you add or replace goes in `rulings.md` with
  the entry's words that carry it. Survey part E, "Entries to cite at the
  rule", lists the entries that rule your rows uncited; add a citation where
  the entry's text carries the claim, after reading it. Where only a
  Rationale or Rejected list carries a ruling, cite the entry and list the
  case under "Rationale-only rulings".
- **The log's vocabulary is old** (part F's list): never import `z`,
  `h_x`, `h_xu`, `project`, `workspace`, `init_x`, `output_state`,
  `output_types`, "Stratum-B" or `AbstractSteering` into the spec when
  citing an entry.
- **The chapter cites by adjacency.** Many rules have their citation a
  sentence or a paragraph away. A split or move that separates a rule from its
  citation repeats the citation.
- **Antecedents**: part F lists the sentences that open on a word pointing
  back. Every inserted gloss or clause is an antecedent hazard; re-read the
  sentence after each one.
- **Code**: carry all three fences verbatim, the misaligned comment at old
  698 included, and the two tables and the blockquote as written except R5's
  F2 cells. The display math changes only by R5's F4. New display blocks are
  allowed where `spec_style.md` asks for display code, declared as
  additions.
- **Terms of art and quoted phrases stay verbatim** (part F's list, and the
  quoted diagnostics).
- **Scratch files** go in your own `units/<U>/`, nowhere else. Edit no file
  outside `units/<U>/`.
- Run nothing in the background. Use `/bin/ls` or `fd`, never a bare `ls`.
  Never stash, reset, check out or commit.

## What you produce

In `units/<U>/`:

- `new.md`: the rewritten text. Unit A's starts with the `## 5.` heading and
  R1's opening. Each unit's starts with its first heading and ends where its
  old text ends, moves aside. Unit F keeps the chapter's closing `---` as its
  last line, followed by the blank line.
- `inventory.json`, in this shape:

  ```json
  {"claims": [{"id": "C-001", "old": "...", "new": "...", "where": "new",
               "cites": ["§5.2"], "newcites": ["§5.2", "D-074"], "tag": "F"}],
   "added": ["a new sentence with no old source, normalized"]}
  ```

  One entry per atomic claim of `old.md`, in order. `old` is the claim's
  verbatim span in the normalized old text, and `new` its verbatim span in the
  normalized text at `where`. Print both normalized texts with

  ```
  python3 checks/check_unit.py ch05 show-old <U>
  python3 checks/check_unit.py ch05 show-new <U>
  ```

  and copy spans from that output. `where` is `"new"` for your own text. For
  content held elsewhere it is the path that holds it: `docs/design/spec.md`
  for text outside the chapter, and `units/<V>/old.md` for content another
  unit owns. `cites` lists the citations inside the old span, and `newcites`
  those your new text attaches, if they differ. `tag` is `F` for a fact
  carried over, `X` for framing, `M` for moved or held elsewhere, `C` for a
  citation added or replaced, and `R` for a ruled edit, with its `"ruling"`.
  `added` lists, verbatim and normalized, every new sentence or clause with no
  old source.
- `rulings.md`, with these sections: **Corrections proposed** (quote, line,
  evidence, proposed text); **Citations added or replaced** (entry, the words
  that rule it); **Rationale-only rulings** (entry, field, log line); **Bold
  on the same entry elsewhere**; **Inbound citations affected**; **Open
  questions**.

Run `python3 checks/check_unit.py ch05 check <U>` until it prints
`checks failed: 0`. A cold verifier then reads your text blind and matches it
against your inventory. Drift that passes the script still fails there.

## The units

Line numbers are old spec lines at `b08afca`. `old.md` holds the unit's range
plus the blocks that move into it. Survey part F rates each unit's difficulty
and names its hazards.

**A: the chapter heading, the new opening, §5.1, and §5.2 to the end of the
hand-off, plus "What the views are"** (672–726 and 813–830; 572 words plus
the opening).
- R1, R2 (M1), R3. The roadmap sentence at old 708–710 gains where each view
  comes from, since M1 puts the views right after the hand-off.
- The signature block verbatim. `kwarg_decl` and slurping keywords take one
  introducing clause each (part F).
- Bolds: D-006 (old 685), D-074 twice (the hand-off; `x_projection` alone
  positional), D-035's second ruling (one home per datum, old 825).
- M1's first sentence reads against the hand-off's "bundle of zero-copy
  views" only if M1 lands right after it.

**B: the bundle law, the stage return law and the handler return law**
(727–812; 783 words).
- R5 (F1, F2), R6, R7 (`BundleFieldError`, `HandlerReturnKey`), R9 (row 12
  bold, row 21 plain), R11 (old 804–805).
- Part C's order inside "The bundle law": the absence rule (old 749) before
  the hand-down (old 744–747).
- The table verbatim except F2's three cells. The `u` row's "**and**" and the
  handler law's "**and**" are two-condition rulings.

**C: §5.3's opening, the stage roles, "Why derivatives may read outputs" and
the execution order** (831–923 and 1016–1042; 973 words).
- R2 (M2, M5), R5 (F4), R7 (`DeclarationOnWrongTier`), R9 (D-220 at 856,
  D-015 at 898, D-252 sentence 2 bold and sentence 1 plain).
- The opening (old 833–836) names all six parts of §5.3 in their new order,
  including M2's block, the step boundary and the supervisory inputs, which
  unit D writes.
- F11: bare `h` at old 843. `f_ode!`, `f_c_c`, AD, RHS unglossed today.
- M2's "Shared expensive computations" (old 1036–1038) is the third
  statement of D-015's idiom (part B item 4): keep its accelerometer example
  and point back to the home at old 898–904.

**D: step boundaries and supervisory inputs** (924–1015; 798 words).
- R4, R5 (F3), R9 (row 75 bold).
- The `PI` block verbatim. ZOH, FSM and the landing-gear example take their
  introductions (part F). D-141's gear wiring is the source for the
  touchdown example.
- "Two of its rules" (old 959) must still read as §10.6's after R4's merge.

**E: §5.4 and §5.5** (1043–1132; 761 words).
- R5 (F6), R7 (`AlgebraicCycle`), R10, R11 (old 1092–1094, 1126–1127), R12.
- One clause after §5.4's first sentence says a genuine cycle is §5.5's
  algebraic loop, and "the tracer ([§5.6])" takes a gloss (part C).
- The strut/steering diagram verbatim. Flight.jl's names (`ψ_v`, castoring,
  `StrutGeometry`) take introducing clauses from D-140's Rationale (log
  4641–4652) and nothing more.
- The two quoted diagnostics stay verbatim (F9).

**F: §5.6** (1133–1220; 830 words).
- R2 (M4), R5 (F5), R7 (`AlgebraicCycle`), R11 (old 1148).
- Bolds: D-012 five times, one per ruling of its semicolon chain, and D-245
  three times (part A's table). Lead-ins that act as headings become `####`
  labels or topic sentences.
- The two "local"s (old 1172 and 1200) name different things: the local
  variant of the classifier against the local, primal-carrying set-tracer.
  Keep them distinct. "There are two modes" must say whose modes once M4
  moves the block up. "tracer tags" (old 1155) is defined by M4's first
  bullet; check it now precedes its use.
- "out-of-cycle cells" and "in-cycle cells" sit in an evaluation with no
  table (old 1170–1171): "cell values" keeps the claim.

## Rulings after step 4

- **R13. Glossary links move to the first use across unit boundaries**
  (units B, C and D's open questions; checked on the assembled chapter).
  §5.2: `#g-cell` moves from unit B's table to unit A's first "cells", in the
  views block; unit B drops its link. §5.3: `#g-store`, `#g-sweep` and
  `#g-guard` move to unit C's first uses (the tier-agreement sentence, the
  D-015 rule, the interior-sweep sentence); unit D drops its three links. A
  first use inside a bold headline takes the link, and its gloss goes after
  the bold span in the same sentence. `#g-execution-order` stays with unit D,
  since unit C uses the term only in a heading.
- **R14. R3's topic sentence claims no count and no "each"** (unit A's
  verifier; corrects R3). The stage-1 hand-down `y_x`/`y_s` is a bundle field
  that none of the five bullets names: §5.2 sources it from the stage-1
  probe's return (D-285 bullet 3). R3's "each bundle field is a view of one
  source" overclaimed. The sentence becomes "The views come from the sources
  below", or words that claim no more.
- **R15. D-012 takes three bolds, not five** (unit F's verifier; corrects
  the survey table that unit F's list adopted). D-012's Position chains three
  rulings by semicolons: tracing is diagnostic only; cycle diagnostics come
  from SCC decomposition, classified by an order-free per-member trace;
  discrete members are traced conservatively, and classification is optional
  on the error. The comma clauses inside the second and third elaborate one
  ruling each. Bold the first statement of each in reading order: "Tracing
  is diagnostic only", "Each nontrivial SCC names one cyclic cluster
  exactly" and "Discrete members trace structurally". "Classification needs
  no execution order" and "Classification is a bonus on the cycle error" go
  plain, keeping their D-012 citations.
- **R16. `x_projection`'s positions are in the boundary sequence** (unit D's
  rulings.md, confirmed by its verifier). The glossary's *execution order*
  (spec 12934) is the flat list of stage entries; integration, handler resets
  and `x_projection` are not in it. Old 934–935 and 937 say "boundary
  sequence" instead, the term §10 uses (spec 5100, 5227, 6378). The
  `#g-execution-order` link goes to the first remaining prose use of the term
  in §5.3, if any.
- **R17. D-016 stays the citation for the `x_projection` bold** (unit D's
  verifier). Its standing clause, "the sole raw-state function
  (schedule-structural)", carries uniqueness of position, which the next
  sentence of §5.3 states. That the annotation drops "schedule-structural"
  goes to track 2.

## Rulings after step 5

- **R18. §5.1's added clause points at §5.4 to §5.6** (chapter pass 2). The
  build rejects every cycle in that graph, artificial loops included, and
  §5.4 and §5.6 treat those. "A cyclic graph is the subject of §5.5" becomes
  "the subject of §5.4 to §5.6", with each section cited.
- **R19. §5.2 names the stages' numbers** (chapter pass 3). The chapter uses
  "stage-1" and "stage-2" without saying which is which. After the context
  paragraph, one declared sentence: "`y_state` is stage 1 and `y_direct` is
  stage 2." The signature block (`y_x` from `y_state`), the glossary's *stage
  function* entry (spec 12792) and its *execution order* entry (12934) carry
  it.
- **R20. §5.3 names the drift class** (inbound check; spec 636, D-139
  Position and Spec, `trim_environment_walkthrough.md` 62 all cite "the
  silent-drift class that §5.3 exists to kill"). After "Nothing ever needs
  computing twice", one plain sentence from D-015's Rejected list (log
  607–608): computing a law twice invites drift, an edited law in one place
  and a stale copy in the other, citing D-015. Rationale-only; listed for
  track 2.
- **Chapter pass 26 is declined.** §5.4 keeps its shape (R10); it needs no
  parts sentence for two paragraphs and a list.

# Brief: the readability rewrite of spec chapter 14

You rewrite one unit of chapter 14 of `docs/design/spec.md`, "Stopped-sim
services", for readability, with no loss of content. Five agents work in
parallel, one per unit. Your prompt names your unit.

Paths below are relative to `docs/spec_rewrite/ch14/` unless they start with
`docs/`. Run the tools from `docs/spec_rewrite/`. The base commit is
`c3d29fb`. Old spec lines below are lines of `spec.md` at that commit; the
frozen copies `scratch_survey/h1/spec.md` and `scratch_survey/h1/decisions.md`
are byte-identical to it. Never read `spec.md` or `decisions.md` from the
working tree: other sessions edit them.

## Read first

1. `docs/spec_rewrite/checks/brief_common.md`, the standing part of this
   brief: what to read, the rules for every unit and what a unit produces.
   Where it says `chNN`, read `ch14`; where it cites `[§11.3][s11-3]` as an
   example, any section works the same way.
2. This brief's slice for your unit, `units/<U>/brief.md`.
3. Your survey slice, `units/<U>/survey.md`. Units A and B come from
   `survey_1.md`, units F, G and H from `survey_2.md`. The questions q1–q9
   are survey 1's, q21–q32 survey 2's; findings F1–F29 are survey 1's,
   F51–F83 survey 2's. Part H of each survey lists descriptive passages for a
   later migration; it asks nothing of the rewrite.

## Rulings already made

These are the orchestrator's rulings at checkpoint 1, each on the survey
question or finding named. Apply the ones that touch your unit, and tag each
such claim in `claims.md` with `tag: R` and `ruling: <id>`. A dictated
wording is a target: fit it to the sentence around it, keep its claims, and
add none. Where a ruling deletes a sentence or clause, it lists the claims
the deletion carries; list each in `claims.md` with its fate.

- **R1. The opening** (q1, F3, M1, M6; unit A). The chapter opening
  becomes one context paragraph and one roadmap sentence, then a
  `#### Lifecycle preconditions` label over the old block (11283–11318) in
  M1's order: the non-running rule and pause, the table, `errored`, the
  kind, then the `Model` forms. The context names five services, after F3:
  "The stopped-sim services are initialization, trim, linearization, and
  `checkpoint` with its partner `restore!`. The first three share one
  artifact, the condition. A checkpoint is a distinct value with no
  condition algebra ([D-273][d-273])." "Everything they share reduces to one
  artifact" is cut as false of `checkpoint` and `restore!`; its true half is
  the second sentence. The roadmap sentence names §14.1 to §14.10 in order
  by subject. The Part IV roadmap (9907–9921) is not edited: it belongs to
  the front-matter rewrite.
- **R2. The `errored` bold** (carried B84; unit A). Old 11310 goes plain:
  "No service accepts an `errored` simulation ([§12.6][s12-6],
  [D-108][d-108])." §12.6 bolds the rule on D-059.
- **R3. Totality's fourth site** (q2, F2; unit B). §14.6's list (old
  11835–11837) gains linearization's `about`, as F2 dictates: "They are
  `init!`, trim's setup application to freshly allocated scratch stores,
  trim's commit through boundary zero ([§14.8][s14-8]), and linearization's
  operating condition under `about`, applied to its own scratch
  ([§14.10][s14-10])." Every count of the sites in the chapter follows.
  §9.3, §11.3 and the glossary are landing edits.
- **R4. §14.1's doctrine** (q3, F6; unit A). Old 11343–11349 becomes F6's
  dictated paragraph: "Addressing conditions by path does not reopen the
  observation-by-path rejection ([§13.5][s13-5], [D-409][d-409]). That
  rejection bars a run from acting on reads its model did not declare. A
  condition is not such a read. It is a design-time statement about a
  concrete build, written before the run begins, and the locality law of
  [§14.2][s14-2] is how an author keeps it to children the author owns." The
  `local_wires` parallel and "the composition law makes the parallel exact"
  are cut as false since D-207 made every wire one level. "Runtime
  coupling … breaks on substitution" is cut; its ground is §13.5's.
- **R5. The client policy** (q5, F1, F21, F22; units B, F). D-414's
  Position makes the locality law authoring guidance, and its Rejected list
  calls §14.4's resolver client-free. The code's resolver takes a source and
  nothing about the client. §13.3's rewritten table resolves bindings and
  `series` under the service walk.
  - §14.4's client paragraph (old 11664–11693) is recast. The source rule
    (rows 142–149) stays the one enforced rule. "Client policy rides on top.
    It is D-083's service and inspection sides restated as a resolver
    property" is cut as false. The bold "Service reads speak the contract"
    goes plain. The target, fitted: "On top of the source rule sits one
    piece of authoring guidance ([D-414][d-414]). A service read, trim's
    `reads` or a tap, that should outlive the build reads a face with
    `get_face`, which resolves through export chains as mounting does
    ([§14.9][s14-9], [D-125][d-125]). An inspection read, a binding's or
    `series`', may name any cell the structure has, since it promises
    nothing beyond this build ([D-083][d-083]). Both resolve under the one
    service walk ([§13.3][s13-3])." "`get_face` is the set's seam-crossing
    member" is cut: since D-414 every path selector crosses a seam. The
    sentences on the equilibrium equation behind a generically held child,
    the one remedy and the component exporting it stay, as guidance.
  - Snapshot inspection leaves the selector clients (F21): "Snapshot
    inspection reads a cell by path and port name instead ([§11.2][s11-2])."
  - F22's sentence replaces "The store selectors reach only the inspection
    clients that actually hold stores (`checkpoint`, post-run inspection)":
    "A store selector resolves only for a reader that runs over live
    stores, which today are the services' ([§14.7][s14-7],
    [§14.10][s14-10]). A snapshot-bound reader is barred from it by source,
    not by client."
  - The selector table (old 11697–11703) keeps its selector and source
    columns and drops the two client columns.
  - Unit F: §14.7's read bullet (old 11949–11958) speaks of guidance where
    it speaks of scoping, after F70. "Service read set" at 11942 keeps its
    sense.
- **R6. Homes and doubles** (q8, q21, q23, q26; units: all). The home
  states the fact with its citation; every other place is a pointer with
  its citation.
  - §14.4 (unit B): the undeclared-intermediate rule and the gather twin.
    §14.7 (unit F) keeps the export and `y_direct` remedies (M55).
  - §14.3 (unit A): converter selection. §14.7 keeps the `Dual`-typed
    clause (M54).
  - §14.6 (unit B): totality. §14.8 (unit F) keeps the trim consequences
    (M58).
  - §14.5 (unit B): the raw iterations, `trim!`'s `t0` (D-110) and the
    recording clear. §14.8 keeps `trim!`'s signature.
  - §14.2 (unit A): the `u` payload's export chain. §14.9 (unit G): the
    from-the-mount consequence, the read-side mount and the empty prefix.
  - §14.8's tolerance translation (unit F): the normalization and the
    inscribed sphere. §14.7's fallback bullet keeps "the derivative-free
    scalar path survives as the fallback" with a pointer (M53).
  - §14.10 (unit H): the tap rejection, `TapResolution`'s conditions. The
    frozen-exact law points to §7.2 (M65), and the non-participation halves
    point to §8.2 and §9.5 (M64), keeping one sentence naming the output
    half as the declared freeze door, the root input's "choice versus
    declaration" and the tooling.
- **R7. Bold** (q4, q8, q24; units: all). Bold the headline clause of each
  ruling at home here, once, with its citation in the sentence, under the
  one-bold test: semicolons in a Position separate rulings, and "+" or a
  comma list joins clauses of one. Survey 2's q24 table is the starting list
  for units F, G and H. It was not checked entry by entry: read each listed
  entry's Position, bold one clause per ruling it makes, and write any row
  that fails the test to `rulings.md` instead of bolding it. Grep your
  siblings' `new.md` for bolds on the same entry.
  - Unit B, §14.5: D-067 bullet 1's headline, "a boundary's `s_update` is
    the outgoing transition", with D-067 in the sentence (q4). D-067
    bullet 3 bold once (row 200, not 202). D-155's first ruling, projection
    as the second mover with the report's two residual sets (row 205), and
    D-126 (row 204), bold here, first in reading order. The three list
    labels ("Project runs.", "Events run.", "Due `s_update` calls run.")
    become plain lead-ins.
  - Unit G, §14.8: D-155's second ruling, `TrimCommitResiduals`. D-126 and
    D-155's first ruling are plain pointers to §14.5.
  - Unit H, §14.10: the seedability bold (old 12559) goes plain and points
    to §8.2 (carried F60, M63). The rejection (rows 702–705) bolds once on
    its headline clause with D-296. The "stated once" bold (F74) and "Both
    halves … have a spelling" (F75) go plain.
  - D-149's bold home is §14.6, D-278's §14.2, D-110's §14.5.
- **R8. Subheadings and labels** (q6, q25, M52, M56, M60, M61; units B, F,
  G, H). `####` topic labels, each checked for define-before-use:
  - §14.4 (unit B): "#### Applying a plan" over the first part, above the
    existing "#### The read-selector family". The section opens with a
    context paragraph that replaces the aphorism (F28).
  - §14.7 (unit F): "The fields", "Decisions and parameters", "Reads",
    "Residuals and checks" (with M51), "The formulation", "Recorded
    extensions". The bullet list becomes paragraphs under them.
  - §14.8 (units F, G): "The backend seam" stays; then "The convergence
    verdict", "The tolerance translation", "Box bounds and saturated
    decisions" (stays), "Scratch stores" (unit F); "The commit, in full"
    (stays), "The report", "The AD obligation" (unit G).
  - §14.9 (unit G): no `####`. A context paragraph opens the section and
    names its parts; the bold labels and **Why.** become topic sentences.
  - §14.10 (unit H): a context paragraph, then "The tap set", "The operating
    point" (moved up, M62), "The seeded pass", "Seeded and frozen leaves",
    "The returned value", "Coordinate guidance", "The sampled-data
    extension", "Declared non-participation".
  - No other section gains a label. The chapter heading takes R1's one.
- **R9. Clear factual corrections** (q32, F1–F29, F51–F83; units: all).
  Each is settled by the code, a later entry or a rewritten chapter; the
  evidence and the proposed wording are in the survey's part E under the
  finding's number. Apply the proposed wording, fitted to the sentence,
  except as amended here. Grep your unit for each finding's phrase first:
  a correction applies to every instance in your unit.
  - F8 (unit A), amended to drop the mid-sentence colon: "Composition checks
    three things, each by type or length alone, and none allocates. Each
    `set` payload is a NamedTuple, each combinator operand is a node, and
    each `at` prefix is nonempty." And "`set` builds the leaf, and `at` and
    `combine` build the tree's inner nodes".
  - F13 (unit A): the first proposed wording, not the track 2 option.
  - F16 (unit B), amended: "A valid entry list compiles two ways. The
    specialized `apply!`'s plan holds, per leaf, a lens, a destination and a
    converter. The dynamic walk's plan holds the converted values
    themselves." Keep the title.
  - F18 (unit B), amended: "That cost is paid once per tree type per
    session, so it spreads over every evaluation of every trim of that
    shape, an envelope of trims included." The 10³–10⁴ count is cut as
    unsupported against §14.7's "~5–15 evaluations".
  - F26 and F79 are outside the chapter: landing edits.
  - F51 is R10; F60 is R7; F63 is R11; F12 and F65 are R12; F66 is R13; F80
    is outside the rewrite.
  - F52 and F53 state what the code does and no entry rules. Apply them;
    track 2 writes the entries.
- **R10. The NLopt fallback** (q30, F51; units F, G, H). One sentence at
  §14.8's tolerance translation: "The derivative-free fallback is designed
  and not yet built, and `pending.md` lists it ([D-070][d-070])." The other
  sentences that describe it (old 12011–12015, 12123–12130, 12166–12167,
  12370, 12665–12666, 12716–12718) are written as the design they are, in
  the conditional or with "would", never as shipped behavior. It is not
  *recorded, not built*: do not mark it with that term. §9.6 is a landing
  edit.
- **R11. The `TrimReport` sketch** (q28, F63; unit G). The sketch (old
  12251–12258) names the code's eleven fields in its order (`src/trim.jl`
  145–157), each with a one-line comment, and the "Field by field" list is
  keyed to the names. This is the one code block a ruling edits.
- **R12. Reader-cold Flight.jl names** (q9, q31, F12, F65; units: all). An
  introducing clause at first use per section names the owner: FlightCore's
  `f_init!` and `f_ode!`, FlightPhysics' `PistonEngine`, Flight.jl's Cessna
  172 model (`c172.jl`), and so on. Check each owner in the Flight.jl
  source at `~/.julia/dev/Flight.jl` before writing the clause, and put the
  file you checked in the claim's `note:`. A clause claims nothing beyond
  its owner. "Today's" becomes "Flight.jl's" or "FlightCore's", as the
  source shows. The Flight.jl commit hash `e5efb3a` is dropped. `g` in
  "$g(s) - s = 0$" becomes `s_update`. `C172XSystems` is glossed as the
  C172X aircraft's systems assembly. FlightCore's `stopval` and BOBYQA need
  no clause.
- **R13. Reserved words** (q22, F17, F29, F66; units: all). *Door* is
  reserved for an entry point that builds a run (chapter 12's R14):
  "the closed-loop trim extension", "Both halves of non-participation". §8.2's
  "freeze door" and "FFI door" are names chapter 8 kept; a pointer may use
  them. Bare *entry* becomes "condition entry", "input entry" or "tap" by
  sense; "a schema entry" stays, as D-064's compound. The other rewordings
  are F17's and F66's.
- **R14. Kinds named** (F5, F71; units: all). Name each kind where the
  section states its condition, with its reason where the code has one.
  `ReadSetMisuse` is §14.9's (unit G), not §14.4's.
- **R15. The C172 audit** (q27, M59; unit G). The interpolation and
  saturation bullets stay in §14.8, introduced as Flight.jl's Cessna 172
  model. The gear and `norm`-guard bullets move to
  `docs/design/companions/migration_outline.md`, beside its audit row:
  write them to `units/G/companion_addition.md`, and leave a one-clause
  pointer in §14.8.
- **R16. The units** (q7, q29; units: all). Five units, A, B, F, G and H,
  below. G and H fall under 2,500 words; that is accepted.

## Escalations

`escalations.md` holds one finding, met outside the chapter: a walked struct
root input with no `convert` method between its scalar instances makes
`linearize`'s default operating point die in a raw `MethodError`. It asks
nothing of the rewrite.

## Edits at landing

The orchestrator's, outside the chapter, in step 7:

- §9.3's bold (old 4690–4692), §11.3 (old 7334) and the glossary's totality
  entry (old 14770–14772) list four sites (R3).
- The glossary's `#g-baseline` (old 14719) drops `init!` (F26), and its
  "all four services" (old 14780) follows R1.
- §13.2 (old 10139–10141): the `TrimCommit…` kinds are logged, not report
  fields (F79), after checking the code.
- §9.6 (old 5113–5114, 5122–5123): the fallback after R10, and the `get_x_ss`
  pointer after F64.
- `README.md`'s carried items for chapter 14 are struck. Appendix B's and
  C's rows this chapter found stale (survey 2's part E closing list, F5's
  `ReadSetMisuse`, F8's `ConditionNodeMisuse`, F11's
  `DuplicateConditionLeaf`, F53's `TapResolution`, F71's `ArgumentInvalid`)
  join the appendices' carried list, and `linearization_walkthrough.md` 572
  joins the companions'.
- Track 2 takes both surveys' part E lists, entries for F52's two reasons and
  F53's step limit, and the annotations of D-149, D-409, D-095, D-098,
  D-130 and D-242.
- Outside the rewrite: F80, the code's positional `at` lift against D-188's
  keyword spelling, is reported to the owner as a loose code fix.

## The units

Line numbers are old spec lines at `c3d29fb`. Each survey's part F rates its
units' difficulty and names their hazards. No file links a `####` anchor of
the chapter.

**A: chapter heading, roadmap, §14.1, §14.2 and §14.3** (11267–11558;
2,509 words). Survey 1.
- R1, R2, R4, R6, R7, R9 (F3, F4, F5, F6, F7, F8, F9, F10, F11, F13, F14,
  F15, F17, F29), R12, R13, R14, R16.
- Survey 1's M1, M2 and M6 and its part C order for each section.
- D-108 rules nine rows of the heading and is cited only at 11310. D-148
  rules five rows of §14.3 and is cited nowhere in the spec.
- The three `julia` blocks stay verbatim. The converter table's em dashes
  go.
- A ends before §14.4's heading.

**B: §14.4, §14.5 and §14.6** (11559–11873; 2,843 words). Survey 1.
- R3, R5, R6, R7, R8, R9 (F1, F2, F4, F9, F14, F16, F17, F18, F19, F20,
  F21, F22, F23, F24, F25, F27, F28, F29), R12, R13, R14, R16.
- Survey 1's M3 to M5 and its part C order.
- D-066, D-098, D-095 and D-125 rule §14.4 and are cited nowhere in it.
  D-110, D-126, D-155 and D-413 rule §14.5 and are cited nowhere in it.
- The tier table inside §14.5's bullet keeps its two-space indentation.
- B ends before §14.7's heading.

**F: §14.7, and §14.8 to the end of "Scratch stores"** (11874–12225;
2,840 words). Survey 2.
- R5, R6, R7, R8, R9 (F55, F56, F62, F65, F66, F67, F69, F70, F71, F78),
  R10, R12, R13, R14, R16.
- Survey 2's M51 to M56 and M58, and its part C order.
- D-118, D-124 and D-125 rule §14.7 and are cited nowhere in the spec.
  D-070 and D-150 rule §14.8 and are cited only once.
- §14.8 spans units F and G. Every §14.8 term whose first use falls in F
  takes its link in F, `TrimProblem` (12057) and `baseline` (12065)
  included.
- The cruise problem, the residual signature, the seam signature and the
  display stay verbatim.
- F ends before "#### The commit, in full".

**G: §14.8 from "The commit, in full", and §14.9** (12226–12483; 2,051
words). Survey 2.
- R6, R7, R8, R9 (F52, F54, F56, F57, F58, F61, F65, F66, F67, F68, F71,
  F73, F77, F81, F82), R10, R11, R12, R13, R14, R15, R16.
- Survey 2's M57, M59, M60 and M66, and its part C order.
- G links only the §14.8 terms whose first use is in G: `checkpoint`
  (12242), `trace` (12236), `recorders`, `batch`, `staging cell`,
  `selector` (12314), `walked` (12348).
- D-071 rules §14.9 and is cited nowhere in the spec. D-155, D-126 and
  D-110 rule §14.8's report and are cited nowhere in it.
- The `at` lift sketch stays verbatim and keyword-form, as D-188 rules.
- G ends before §14.10's heading.

**H: §14.10** (12484–12730; 2,173 words). Survey 2.
- R6, R7, R8, R9 (F53, F59, F64, F65, F66, F67, F71, F72, F74, F75, F76,
  F83), R10, R12, R13, R14, R16.
- Survey 2's M61 to M65 and its part C order.
- D-072 rules §14.10 and is cited only in §7.1 and §7.2. Cite D-167's
  replacements as survey 2's part E gives them (F59).
- The tap-set example, the chart, the table and the local rule's block stay
  verbatim.
- H ends with the chapter's closing `---` and the blank line after it.

## Rulings after step 3

- **R17. The recording clear** (unit B's open question 1, unit G's 5;
  units B, G). Old §14.5 never states it, so §14.8 keeps it with D-110, as
  unit G wrote it. Unit B drops the sentence it added, and R6's bullet on
  §14.5 covers the raw iterations and `t0` only.
- **R18. D-067's four bolds** (unit B's open question 2; unit B). D-067's
  Position is a headline and three bullets, four rulings, and §14.5 is their
  home. The headline, bullet 1, bullet 2 (`t₀` the init-service argument)
  and bullet 3 each take one bold.
- **R19. D-276's bullets** (unit B's open question 3; unit B). Each bullet
  is a ruling. A bullet §14.4 states takes one bold on its headline clause
  when no other section of the frozen spec bolds it and §14.4 is where the
  spec states it; grep the frozen spec for each. A bullet whose home is
  another section, the binding read (§11.2) and wiring's port granularity
  (§4.3), stays plain with its pointer.
- **R20. The one-remedy sentences** (unit B's open question 4; unit B). M5's
  merge stands. R5's "stay, as guidance" governs their content, not their
  place.
- **R21. An unbuilt ruled design keeps its bold** (unit F's open question 1;
  units F, H). A ruling is bold whether or not the code builds it yet, as
  D-073's recorded-unbuilt activation is. D-069 bullet 5's fallback takes one
  bold on its headline clause, written as design under R10. D-070's
  `NLoptBackend` clause bolds only if the one-bold test makes it a ruling of
  its own.
- **R22. `f_periodic!`** (unit F's open question 2; units: all). FlightCore
  renamed `f_disc!` to `f_periodic!` (Flight.jl commit `30a5942c`), and
  `lib/FlightCore/src/` holds no `f_disc!`. Write FlightCore's current name.
- **R23. Flight.jl's trim** (unit F's open question 3; units: all).
  FlightCore holds no trim code. The formulation is FlightPhysics'
  (`aircraftbase.jl`) and the BOBYQA minimization with its `stopval` is
  Flight.jl's Cessna 172 model (`c172.jl`). Each "FlightCore's" that names
  the trim formulation or its threshold becomes the owner the source shows.
  This corrects R12, which called `stopval` and BOBYQA FlightCore's; they
  still need no clause beyond their owner's name.
- **R24. The seeded tap's leaf** (unit H's open question 1; unit H). F53's
  wording gains the leaf rule the code enforces (`_check_seedable`): a
  seeded tap's leaf is exactly `Float64`. "A whole state field or root
  input" in place of "a whole cell" stands.
- **R25. The default point's citations** (unit H's open question 2; unit H).
  The bold is D-274 bullet 5's. D-319 stays cited in the sentence, as the old
  text cites it; it does not take a second bold.
- **R26. `design_world` and the frozen-exact remainder** (unit H's open
  questions 3 and 4; unit H). The gloss drops "shipped": `design_world` is
  the rig this design records for design-time work ([§14.9][s14-9],
  [D-071][d-071]); the glossary's word is a track 2 item. The two
  frozen-exact sentences §7.2 lacks stay, plain.
- **R27. Unit A's three corrections** (unit A's open question 1 and its
  corrections 1 to 3; unit A). F16 reaches old 11514–11516, which is unit
  A's §14.3; the brief misassigned it to unit B alone. Apply unit A's
  item 3, the §14.3 sentence that compiles two ways and points to §14.4.
  Apply item 1, §9.6 previewing trim and linearization, as §9.6 opens. Apply
  item 2, the lifecycle table's em dash removed.
- **R28. D-277's bolds** (unit G's verifier, open question 1; unit G).
  D-277's first Position sentence holds two rulings at its semicolon: the
  mount prepends and joins nothing, and `Reads` is not a condition node.
  The second takes one bold if §14.9 states it and no other section of the
  frozen spec bolds it. Bullets 1 to 3 spell, per selector, the rewrite the
  Position's second sentence rules; they stay plain, as a consequence does.
- **R29. The rig's types** (unit G's open question 2 and its verifier's;
  units G, H). `SimpleAtmosphere` and `NoWind` are FlightPhysics' types
  (`atmosphere.jl`). Flight.jl has no `HorizontalTerrain`, so the text names
  it with no owner, as the old text did, and no clause calls it Flight.jl's.
  The glossary's `#g-design_world` is a track 2 item.
- **R30. "Traced and checkpointed by value"** (unit G's verifier, open
  question 3; unit G). §4.4 says only "recorded with the run by value", so
  the pointer sentence keeps the old phrase.

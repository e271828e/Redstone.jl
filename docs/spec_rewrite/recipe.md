# Rewriting a spec chapter for readability: the recipe

This is the living recipe for rewriting a chapter of `docs/design/spec.md`
for readability with no loss of content. It began as chapter 9's report,
`docs/reports/20261001_chapter9_rewrite/report.md`, which stays frozen as
that run's evidence. This copy changes: each chapter adds its lessons here,
next to the step they changed, before its directory is deleted.

The convention the rewrite writes to is `docs/design/tools/spec_style.md`,
"Marking rulings" and the rest. Briefs cite it and never restate it.

## 1. Setting up a chapter

- **Create `chNN/`** with the two-digit chapter number, and in it
  `chapter.sh`, for example:

  ```zsh
  NUM=10                  # the chapter number
  BASE=6ff502c            # the commit the rewrite starts from
  RANGE=4689,5792         # the chapter's lines in spec.md at BASE
  UNITS=(A B C)           # unit names in reading order, once cut
  EXTRA=()                # files the PDF appends, as text moved to a companion
  ```

- **The tools in `checks/` take the chapter directory.** Run them from
  `docs/spec_rewrite`:

  ```
  python3 checks/check_unit.py ch10 check A # a unit against its original
  python3 checks/boldcheck.py ch10 A        # a bold-only edit
  checks/assemble.sh ch10                   # chapter_new.md and chapter_old.md
  checks/build_pdf.sh ch10                  # chapter.pdf, untracked
  python3 checks/slice_brief.py ch10 A      # units/A/brief.md: the rulings that reach A
  python3 checks/slice_survey.py ch10 survey.md A 10.1 10.2  # units/A/survey.md
  python3 checks/build_inventory.py ch10 A  # inventory.json from claims.md, then the checker
  python3 checks/split_assertions.py ch10 A # verify_phase1.md, one item per sentence
  python3 checks/inbound_scope.py ch10 > ch10/inbound_scope.md  # claims removed or moved
  ```

  Each tool's docstring states its inputs. The five added on 2026-10-14 were
  validated on chapter 11's archived files; the record is at the end of
  section 2.

  `check_unit.py ... show-old` and `show-new` print a unit's normalized
  texts. `checks/verify_prompt.md` is the step 4 prompt.
- **Mark the chapter in progress** in `README.md`.
- **Small chapters can run as one.** Chapters 1 to 4 (4,285 words) ran as
  `ch01-04/`, with one survey, brief, chapter pass and batch, `NUM="1 to 4"`
  and one `RANGE`. Units never cross a chapter boundary. The tools take any
  directory name.

## 2. The recipe

Each step names its agent, model, inputs and outputs. Opus does every step
that writes or judges spec text. Sonnet consolidates the rulings batch and
reads the PDF, and a script does what needs no judgment. The orchestrator is
the main session: it reads
every report, checks key claims at the cited lines, routes fixes, and keeps
rulings away from agents.

**The orchestrator rules, from chapter 10 on.** The owner delegated every
decision of a chapter's rewrite to it on 2026-10-02. The four checkpoints
below are the orchestrator's, and it records each ruling with its reason in
the chapter's files, so the owner can audit any of them.

Serious findings are the exception. A finding is serious when it shows a
defect or inconsistency in the design itself, not in its prose: two sources
the spec treats as authoritative contradict each other and no Position
settles which is right; a fix would change what the framework does; or the
design looks wrong. The orchestrator never rules on these. The text stays as
written, the finding goes to `escalations.md` with its evidence and a
recommendation, and the owner gets the list when the chapter closes.

### Step 1: survey (one Opus agent, read-only)

The survey maps the chapter before anyone writes. Chapter 9's
`survey.md` is the model output. Ask for:

- per section, every rule with its line, its marking, and the decision entry
  whose Position rules it, classified as cited, uncited, superseded,
  Rationale-only or no entry;
- overlaps inside the chapter and with other chapters;
- a proposed structure: moves, merges, order within each section, with no
  renumbering unless it pays for its citations;
- every inbound citation of the chapter, to `inbound.tsv`, and analysis of
  the ones that rely on content a move would take;
- the log repairs the rewrite needs, and factual problems found in passing;
- a difficulty estimate per section, with warnings for the rewriter;
- per section, the Appendix C kinds cited to it, and whether the section
  names each where it states the kind's condition. Chapter 8 named five
  kinds in four late rounds (R14, P46, P48, K2) that one survey line would
  have ruled at checkpoint 1.
- every code block the package can run, run against it. Chapter 7's survey
  ran §7.3's PRNG example and found that it failed its own conformance
  check. No reading had caught it.

Head each per-section block `### §N.M ...`, as chapter 11's surveys did:
`slice_survey.py` cuts the survey for each unit by that heading.

A survey whose report is long writes it in parts, one append per section:
one response over the output limit kills the agent and loses the report.

**A chapter over about 10,000 words surveys in two halves.** Chapter 11
(13,983 words) ran two survey agents in parallel, one per half, each reading
the other half once for overlaps and classifying only its own. The halves
number apart (rows 1 and 501, moves M1 and M51, findings F1 and F51,
questions q1 and q21, units A to E and F to K), so the reports merge without
renaming. The orchestrator builds `inbound.tsv` by script before the survey,
so both halves judge one list; the script stays in `scratch_survey/`.

**The orchestrator reads parts C to G whole, and parts A and D only at a
cited row.** Parts C, E, F and G carry the moves, the factual problems, the
hazards and the decisions, which checkpoint 1 answers. Part A, the
per-section rule table, is the rewriters' reference, and part D the inbound
check's; in chapter 11 part A alone ran 545 lines. Then check the survey's
key claims yourself, at the cited lines, before ruling on them. In chapter 9, six of six held, and in chapter 10, eleven of eleven.
In chapter 8 the claims held, but a correction did not: see checkpoint 1.

**Checkpoint 1: the orchestrator rules on the survey's decisions.** In
chapter 9 the owner ruled them: where the `Deployment` lives; which block is
frozen pending another ruling; how much log repair rides with the rewrite
(answer: none, it is a second track); how many sentences get bold (answer:
one per ruling). The last two hold for every chapter. Record the rulings at
the top of `brief.md`.

Two lessons from chapter 8's checkpoint:

- **A correction restored from git history is checked against the entries
  ratified after the change.** Chapter 8's R8 restored a sentence a move had
  inverted, on the commit's evidence. Unit A's verifier found D-267, ratified
  two days after the move, agreeing with the inverted text. R8 was withdrawn
  and the conflict escalated.
- **A wording correction is ruled for every instance in the chapter.** The
  survey found F22's overstatement at two lines; a rewriter found a third,
  which cost a ruling (R13) after step 4. Grep the chapter for the phrase
  before writing the ruling.

From chapter 6's checkpoint:

- **A clause a Position introduces with "therefore" is a consequence.** D-207's
  second bullet joins "the face graph is therefore total" with the `Build`'s
  retention, which §9.2 bolds. The survey proposed bolding totality in §6.1
  as a second ruling; the bullet is one ruling, and its consequence stays
  plain.
- **When a section holds two sketches of one hierarchy, rule at checkpoint 1
  which one the prose follows.** Chapter 6's survey left its F6 as written.
  It came back three times: as a rewriter's added clause (R14), a chapter
  pass ruling (RP-4), and the final verifier's cold read of the
  orchestrator's own wording (O-2 to O-4).

From chapter 5's checkpoint:

- **Check the survey's bold table against the one-bold test before adopting
  it.** Chapter 5's brief took five bolds for D-012 from the survey. D-012's
  Position chains three rulings by semicolons, so two bolds were doubles;
  unit F's verifier caught them (R15).
- **Check each linked term's uses against its glossary entry, not only the
  reserved words.** §5.3 placed `x_projection` "in the execution order",
  which the glossary defines as the list of stage functions. A rewriter
  found it; the fix (R16) reached three other chapters and the glossary.

### Step 2: the brief (written by the orchestrator)

The brief has a standing part and a chapter part. The standing part is
`checks/brief_common.md`: what to read first, the rules for every unit, and
what a unit produces. It was lifted from chapter 11's brief on 2026-10-14
with the seven lines that named that chapter generalized, and it holds the
"the brief should also say" items listed below, so a new lesson that applies
to every chapter goes there and not into a brief. The chapter part is
`brief.md`, which the orchestrator writes; chapter 9's is the model for its
shape, read with the corrections below. It holds:

- the base commit, the frozen copies and the chapter's survey files;
- every ruling of checkpoint 1;
- the units: their line ranges, their moves, their hazards, the rulings that
  reach each, where each starts and ends, and which `####` anchors are linked
  from elsewhere.

In chapter 11 the standing part was about 155 of the brief's 634 lines, and
the rulings the orchestrator writes are the rest.

**The slices.** `slice_brief.py` writes `units/<U>/brief.md` with the
rulings that do not reach U reduced to one-line stubs. It reads two things:
a ruling's opening parenthetical names its units (`unit A`, `units B, C`,
`units: all`; no unit named means every unit), and U's block under `## The
units` names the rulings that reach it. Correction items under a ruling
(`  - F5 (unit B, ...)`) are sliced the same way. Check the stub list the
slicer prints against the unit blocks before any agent starts.
`slice_survey.py` writes `units/<U>/survey.md`, the survey with other
sections' per-section blocks stubbed and every chapter-wide part kept. The
verifier reads the whole `brief.md`, never a slice. On chapter 11's files
the brief slices ran 60 to 73 percent of the brief and the survey slices 62
to 72 percent of the survey.

**`claims.md` replaces the hand-built inventory.** One block per claim,
blocks separated by blank lines, fields one per line: `old:`, `new:` (omitted
when identical), `tag:`, `ruling:`, `where:`, `newcites:`, `note:`; one
`added:` block per declared addition. The tool fills the ids and the old
span's citations, refuses a tag `R` without its ruling, notes a span whose
citations changed with no `newcites`, writes `inventory.json` and runs the
checker. The model brief's `inventory.json` paragraph is replaced by this,
with the same tags: `F` fact, `X` framing, `M` moved or held elsewhere, `C`
citation added or replaced, `R` ruled edit.

**Units run 2,500 to 3,000 words.** Chapter 11 cut nine units of about
1,500 words, and each unit's rewriter and verifier paid the same reading cost
before writing a line. Fewer units halve that overhead, and a 3,000-word
unit still runs comfortably.

**Cut units by content, not by section.** A unit is a range of original lines
plus the blocks that move into it. In chapter 9, A2 was §9.2 plus §9.1's
`Deployment` and warnings blocks. Then every move is inside one unit, and its
inventory can follow each claim. A claim another unit keeps is mapped to that
unit's `old.md`, which its own inventory guarantees.

**The brief must also say**, because chapter 9's brief did not:

- Check every proposed subheading order for define-before-use. Chapter 9's
  came from the survey's labels and put "Rendering" before the `Schedule` it
  renders.
- One glossary link per term per section, at first use, not every link the
  old text had.
- With bold on the headline clause, the citation follows anywhere in the
  same sentence, not within some number of characters.
- Introduce reader-cold names, from the start.
- Every scratch file goes in the agent's own unit directory. Two agents
  sharing the scratchpad collided.

**From chapter 10, the brief should also:**

- Rule the clear factual corrections at checkpoint 1, with their evidence,
  instead of leaving them for step 6. Chapter 10's R8 settled eight of them
  before anyone wrote, and no unit needed a second pass for them.
- Say that a gloss or an introducing clause claims nothing beyond the source
  it names. Chapter 10's rewriters invented a demo's file and aircraft, and
  gave "periodic avionics" a modeling claim; the verifiers caught each one.
- Give the reading of the one-bold test for old entries: semicolons separate
  rulings, and "+" or a comma list joins clauses of one ruling. Tell each
  rewriter to grep its siblings' `new.md` for bolds on the same entry. Chapter
  10 had five rulings bold twice across units.

**From chapter 7, the brief should also:**

- Hold its own dictated wording to lesson 14. Two of chapter 7's rulings
  overclaimed: a context sentence said every step of §7.4 addressed one
  problem, and an introducing clause called `get_x_ss` FlightCore's when
  FlightPhysics and FlightApps own it. Check a Flight.jl name's owner in the
  Flight.jl source before ruling its clause.
- List the words the glossary reserves ("Bare 'tier' means only this").
  Chapter 7's rewriters used "tiers" for the genericity classes and for
  §7.5's budgets; only the chapter pass caught both.

**From chapter 5, the brief should also:**

- Assign each glossary term's first-use link where a section spans two
  units. §5.2 and §5.3 each spanned two, and five links sat at a later use
  until R13 moved them, at the cost of four fix rounds.
- Name every term a merge must keep. R4 merged two statements of the
  boundary sequence and dropped its name, which three inbound citations
  relied on; only the chapter pass caught it.
- Still hold its own wording to lesson 14. R3 dictated "each bundle field is
  a view of one source", and the stage-1 hand-down is a field no source
  names (R14).

**From chapter 6, the brief should also:**

- Check a Flight.jl type's shape, not only its owner, before ruling its
  gloss. FlightPhysics' `Wrench` has fixed `Float64` fields, and the spec
  writes `Wrench{Float64}`, so the gloss had to say the spec's form is the
  walked one (R12).
- Prefer an introducing clause to a companion move for a status-quo
  measurement that gives a rule its scale. Chapter 6's C172 count stayed in
  §6.2 with "Flight.jl's Cessna 172 model"; the survey's move was withdrawn.

**From chapters 1 to 4, the brief should also:**

- Check each ruling's unit against the units' line ranges. R12 named a line
  for unit F that was the last line of unit E's `old.md`; F could not apply
  it, and R15 moved it.
- Check a dictated correction against its source's scope, not only its
  words. R5 replaced "the inner loop allocates nothing" with "the phase
  bodies … allocate nothing", which §7.5 holds only for the continuous hot
  path; unit A's verifier caught it (R14). R23 named two placements that
  turned out to be different sentences (R24).
- Say that a gloss moved into its own sentence gains weight. "Every
  component provides two output stages", untrue of an assembly, became a
  cited sentence; R19 returned it to its gloss.

**From chapter 11, the brief should also:**

- Say that a glossary link's first-use gloss is a declared addition and
  required. One rewriter read "no claim the old text does not make" as
  forbidding glosses, and eight running agents had to be told.
- Say that a citation never sits inside a gloss's parentheses. Four units
  placed one there, and each then read as the gloss's source.
- When it rules one home for a fact two sections state, check that the home
  states the fact's reason. R5 put `totals` monotonicity in §11.2, which
  lacked the reason; the two sections ended up pointing at each other (R30).
- Probe a dictated correction at its edge values. R10 dictated "the log's
  `sizehint!` is `log_max`", false when `log_max = Inf` (R29). Verifiers
  also caught a wrong section number in a pointer (R24) and a survey
  proposal that reversed a gloss's meaning.

### Step 3: rewrite the units in parallel (one Opus agent per unit)

Prompt: read `checks/brief_common.md`, `units/<U>/brief.md` and
`units/<U>/survey.md`, follow them,
edit nothing outside `units/<U>/`, write `claims.md`, and run
`python3 checks/build_inventory.py chNN <U>` until it prints
`checks failed: 0`. In chapter 11 eight of nine rewriters wrote their own
15,000 to 33,000 character script for the inventory; the tool reproduces
all nine archived inventories from their claims.

The checker proves, per unit:

- the old spans cover every word of `old.md`;
- each new span exists where the inventory says, in this unit or another
  file;
- each claim's citations sit in the same paragraph, bullet or table;
- every word of `new.md` traces to a claim or a declared addition;
- every bold span has a D-citation in its sentence.

It cannot see meaning. That is step 4's job.

### Step 4: verify each unit blind (one Opus agent per unit)

Prompt: `checks/verify_prompt.md` with the chapter directory and the unit's
name, plus notes on its known hazards. Phase 1 is generated: the
orchestrator runs `split_assertions.py`, which writes `verify_phase1.md`
with one item per sentence, bullet, table cell or code block, its citations
and a `(bold)` mark. The verifier reads that list first, adds the assertions
a sentence holds that the list does not separate, and then reads the rest.
Phase 2 classifies every old claim as MATCH, DRIFT or LOST and lists ADDED.
On chapter 11's nine units the splitter gave 62 to 170 items where the Opus
lists had 71 to 132; the Opus lists split some clauses and merged some
sentences, and the splitter does neither.

Route each fix list back to the **same rewriter**, then the fixes back to the
**same verifier** for a re-check. Never skip the re-check. **Route by path.**
The verifier writes its fix list to `units/<U>/verify.md` and replies with
the counts and its open questions; the orchestrator forwards the path to the
rewriter without reading the list, since it never rules on a fix, and the
open questions reach the consolidator through `rulings.md` and the
verifier's report. The orchestrator reads a fix list only when the counts
look wrong for the unit. In chapter 9,
fixes broke something new three times: a cause clause fell off in a pointer,
a citation's scope shrank, an "its" changed antecedent.

What chapter 9's verifiers caught that the checker could not:

- a dropped "because" and a dropped scope clause after a sentence split;
- a citation left covering half its sentence;
- one ruling bold twice, a consequence in bold, a ruling bold where its home
  is another chapter;
- a factual correction applied silently, which the brief forbids: one
  rewriter replaced "under the lock" with §9.4's "mechanism unspecified";
- citations added for entries whose Position does not carry the claim.

Chapter 10's verifiers also caught an antecedent that moved when a ruled
sentence was inserted between "two epochs" and "this", and a citation pointer
that named one entry for a list whose items two entries reject.

From chapter 8:

- **Start each unit's verifier when its rewriter reports**, not when all
  have. With nine units the rewriters finished over twenty minutes, and the
  first fix rounds ran while the last units were still being written.
- **An inserted gloss or introducing clause is an antecedent hazard.** Four
  of chapter 8's fixes moved an antecedent this way, and only the re-checks
  caught them: an "its" that now read as the newly introduced `Systems`, a
  "there" that read as the `Schedule`, an "it" that read as the wrapper
  types, a "that adjudication" that pointed at the wrong section.
- **Inventories map into sibling units**, so after any edit, run every
  unit's checker, not only the edited one's. Moving a link in B1 broke a span
  B4 mapped into B1's text, and only the final verifier ran B4 again.

### Step 5: read the whole chapter (two Opus agents in parallel)

Run `checks/assemble.sh chNN` first, and `inbound_scope.py`, which lists
every claim the units removed, relocated or changed by ruling under its old
section, from the inventories and the `deleted.md` files.

- **The chapter pass** reads `chapter_new.md` whole for what no unit check
  sees: one name for one thing, one gloss per term, duplicated facts after
  the moves, pointers aimed at the wrong section, bold weight, the opening's
  roadmap, reader-cold names, and anything worse than the old text.
- **The inbound check** judges every row of `inbound.tsv` against the new
  chapter: OK, RETARGET, COMPANION, MISSING, VAGUE. A MISSING row the old
  chapter stated is a loss. The checker gets `inbound_scope.md`. A row whose
  target section has no entry there needs only the check that the section's
  number and title are unchanged; a row whose section is listed is judged
  against the listed claims, and a loss is a citing sentence that relies on
  one of them. Chapter 9 had none. Chapter 10's one LOSS was a
  circular pointer: a cut list pointed at D-154, whose Rejected item pointed
  back at the section. Before cutting a list to a pointer, check that the
  entry does not point back.

An editorial fixer (Opus) then applies the chapter pass's wording, placement,
link and wrap fixes through each unit's inventory, and lists the rest.

**The inbound check stays on Opus.** On 2026-10-14 two Sonnet agents judged
chapter 11's 610 archived rows with the step 5 prompt against the final
chapter. They returned 15 non-OK rows to the Opus agents' 24, agreed on
seven, and marked OK all five rows the rulings had broken (R4's three, R23's
two). The check exists for those five.

From chapter 11: a long chapter runs step 5 in halves too, a chapter pass
and an inbound check per half, each pass grepping the other half for
repeated claims and bolds. Two editorial fixers then edit disjoint units.
Give each parallel agent its own scratch directory: chapter 11's two fixers
overwrote each other's wrap script in a shared one.

### Step 6: rulings (one Sonnet consolidator, then the owner)

The consolidator merges every `rulings.md`, the verifiers' leftovers, the
chapter pass's ruling items, the inbound check and the survey's log and
out-of-chapter parts into `rulings_batch.md`: deduplicated, sourced, each item
with a proposal and a recommendation, blocking items first. It is a Sonnet
agent from chapter 12: it merges and sources, and the orchestrator checks
every proposal's evidence at the source anyway (lesson 10), so a weak
recommendation costs orchestrator time, not text.

**Step 6a: the evidence check (one Opus agent).** Before the orchestrator
rules, a cold agent reads every non-blocking item of `rulings_batch.md`,
opens the source each proposal cites, and marks the item CONFIRMED with the
source's words quoted inline, or UNCONFIRMED with what the source says
instead. It writes `evidence_check.md` and edits nothing else. Blocking
items and `escalations.md` are not its job.

**Checkpoints 2 and 3: the orchestrator rules.** Take the blocking items
first, and open the source for each of them yourself. For the rest, rule
from the batch and the evidence check, and open the source only for an
UNCONFIRMED item or a CONFIRMED one whose quote does not plainly carry the
claim; the final verifier re-reads every edit the rulings produce. Record
every ruling and its reason as the item's status in `rulings_batch.md`. Serious items go to `escalations.md` unruled. In
chapter 9, the owner ruled 103 items in two sittings.

Apply the rulings with agents partitioned by unit, so no two edit one file.
Every ruled edit carries its ruling id in the inventory. A bold-only edit
copies `new.md` to `new_pretrim.md` first, for `boldcheck.py`.

A small chapter may skip the consolidator. Chapter 6 had seven in-chapter
items: the orchestrator wrote `rulings_batch.md` itself, and one fixer
applied the editorial and ruled edits across all three units in turn.

**Step 6b: the final verifier.** One cold Opus agent checks every edit made
since step 4, against its log and its source: editorial fixes, bold trims,
ruled edits, orchestrator touches. In chapter 9 it checked 164 edits and
found seven problems, one of them a change of meaning. Fix, then re-check.
Give it the commit that holds the chapter as verified per unit, so it can
diff the two versions hunk by hunk; in chapter 8 it checked 75 hunks and
found two unlogged rewraps, two duplicated glossary links, a citation left
off a split sentence and a broken sibling span. In chapter 7 its one finding
was the orchestrator's own: a scripted replace joined two source lines. Log
every orchestrator touch, and rewrap after any scripted edit.
Run `checks/assemble.sh` after every orchestrator touch too: chapter 6's
re-check found `chapter_new.md` stale after the orchestrator's three fixes.
The fixer's log should hold each edit's old and new text in order. Chapter
5's final verifier replayed `chapter_fixes.md` on the verified commit and got
every unit byte for byte, which made 65 changes checkable at once. The
consolidator reads only, so it can run beside the editorial fixer.

From chapters 1 to 4: a bold-only edit's `new_pretrim.md` goes stale when a
later edit touches the same unit. Rebuild it from the current `new.md` with
the removed bold restored before running `boldcheck.py`.

### Step 7: land (the orchestrator)

**Checkpoint 4: the orchestrator approves landing.** Run
`checks/build_pdf.sh chNN` and read the PDF first: tables and links are where
an excerpt fails. Then, in this order:

1. Edit inbound citations outside the chapter first, while their line numbers
   still match the inbound check's.
2. Splice the assembled chapter over its line range, and fix the Contents
   entry for any retitled section.
3. Add the new log entries before the link-definition block, and update the
   Spec fields the moves changed, in place, keeping each field's own order.
4. Apply the companion additions and any other file edits the rulings name.
5. Add the chapter to `REWRITTEN` in `docs/design/tools/check_bold.jl`.
6. Run `linkify.jl`, then the battery `spec_style.md` lists, and
   `linkify.jl` again as a no-op.
7. Rebuild `design.pdf`, and commit in reviewable pieces.

Other sessions may edit the spec while a chapter is in flight. Recount the
range against `BASE` before splicing, and carry their hunks, never revert
them. Tell any session working on the spec when the chapter is in flight and
when it lands; chapter 10 coordinated with one that way.

- `RANGE` ends on the blank line after the chapter's closing `---`. The
  splice keeps that blank line.
- When a cut removes the only spec citation of a superseded entry,
  `check_rows.jl` reports that coverage shrank. Rebaseline it with
  `--rebaseline`, since the style forbids citing a superseded entry.
- The PDF read can go to a Sonnet agent. Check by script that every fenced
  block is byte-identical to the original first; then a long line or a page
  split in a code block is layout, not damage.
- The Read tool renders PDF pages only with `pdftoppm` (poppler), which this
  machine lacks. Without it the PDF read runs on extracted text, which finds
  raw markup, broken tables and lost numbering but not spacing or page
  layout. Chapter 8's read ran that way.
- Run each battery check as its own command. A zsh loop over a variable
  holding `check_glossary.jl --strict` passes it as one file name, which looks
  like a crash in the check.
- Two chapters can run in parallel sessions (chapters 5 and 6 did). Agree a
  protocol by message first: each session works only in its own `chNN/`;
  landings go one at a time, with a message before the splice and after the
  landing commit, and the second session recounts its range; each takes a
  block of new entry numbers (chapter 6 D-321 to D-340, chapter 5 from
  D-341); and the shared files, `README.md`, this recipe, `pending.md`,
  `check_bold.jl` and `row_baseline.txt`, are edited by one session at a time,
  after a message and a fresh read. Pick a chapter with little citation
  traffic to the other: chapters 5 and 6 cite each other nowhere.

- Run the battery on the assembled chapter, with the chapter added to
  `REWRITTEN`, before the splice commit. Chapter 11's lander stopped on
  three failures no unit check sees: the splice cites a new entry, so the
  entry lands in the splice's commit (L-1); a correction removed a glossary
  anchor's only link (L-2); and an old bold in a chart, never checked
  before, had no D-citation (L-3).
- The landing can go to one Opus agent, given the accepted batch items and
  this step's order. Chapter 5's lander ran linkify and the battery before
  each of its three commits, so each commit passed on its own.

### Step 8: the second track

After landing, the orchestrator rules and applies what the rewrite surfaced
but did not need, serious findings excepted:
entries that state Rationale-only rulings in a Position, annotations of stale
Positions, Spec fields stale before the rewrite, and problems outside the
chapter. A new entry restates only what an existing entry already records.
A spec sentence with no entry behind it stays uncited and goes to the owner,
since ratifying it would be a design decision. Then cite the new entries
beside their source entries in the chapter. Track 2 is
where the log catches up with the spec; keeping it out of the rewrite kept
each rewriter's job to prose.

From chapters 1 to 4:

- **Grep every Position for a proposed bullet's ruling before adding it.**
  The batch proposed D-362's bullet on event/tick iteration from D-020's
  Rejected list; D-292's Position already made it. The track 2 agent found
  it, and the bullet went in favour of citing D-292.
- **A source that cites the spec back is no source.** D-243's Rationale and
  D-231's Position both took §4.1 as the authority for "immutability plus
  frozen references", so no entry rules it (R18). The bold went and the
  ruling went to the owner.
- **Rewrap by rendered columns.** Track 2's first rewrap measured source
  columns and missed seven lines that citations pushed past 80 rendered
  columns; its verifier caught them.

### Step 9: close the chapter

1. Add this chapter's lessons to this recipe, at the step each changed, and
   to section 5.
2. Record the chapter's landing commit in `README.md`.
3. Delete `chNN/` in a commit of its own, and record that commit's parent in
   `README.md` as the last one holding the files. Move `escalations.md` out
   first, into `docs/design/pending.md` as one bullet per finding the owner
   has not ruled. A shape `src/` has and the spec lacks goes under
   "Deviations"; a design question goes beside the item it belongs to, as
   chapter 8's semantic axis joined the exported-name audit.
4. Report to the owner: the commits, and `escalations.md` with a
   recommendation per finding.

### The appendices

Appendix A is an index, B an API synopsis, C a table of diagnostic kinds and
D the glossary. They carry few rulings and are list-shaped, so the moves,
the overlap analysis and the two-half survey buy little. The plan is a
reduced track: a survey, one rewriter per appendix, one verifier and the
battery. The decision waits for chapter 14's landing, since the kernel
extraction in `pending.md` may change what Appendices A and B are for.

### The 2026-10-14 revision and its validation

The levers above, applied from chapter 12: `claims.md` and
`build_inventory.py` for the inventory; `slice_brief.py` and
`slice_survey.py` for each rewriter's reading; units of 2,500 to 3,000
words; a generated phase 1; `inbound_scope.md` for the inbound check; the
consolidator on Sonnet. Each was tested on chapter 11's archived files
(`git show e5cbb77:docs/spec_rewrite/ch11/...`) before it entered this
recipe:

- `build_inventory.py` round-trips all nine archived inventories, claims and
  additions equal up to citation order, each passing the checker.
- `split_assertions.py` ran on all nine units; its counts and the Opus
  lists' are under step 4.
- `slice_brief.py` and `slice_survey.py` ran on the brief and both surveys;
  the sizes are under step 2. The slicer stubs R4 and R5 for unit A and
  keeps R13, which names every unit.
- `inbound_scope.py` lists R4's and R23's changed claims under §11.3 and
  §11.6, and R5's relocations with their homes.
- A Sonnet inbound check was tried and rejected; the record is under step 5.

The same day added four changes for the orchestrator's own context, which
the levers above had left alone: the standing part of the brief in
`checks/brief_common.md`, the survey reading rule in step 1, fix lists by
path in step 4, and the evidence check in step 6a.

Chapter 12 is the measurement: its table in section 3 carries a findings
column per step beside the tokens, and the orchestrator's context at each
checkpoint.

## 3. Cost and time

From chapter 12 the table carries a findings column per step (checker
failures, verifier DRIFT and LOST counts, chapter pass items, inbound non-OK
rows, final verifier findings) beside the tokens, so a change in cost can be
read against a change in catch. It also records the orchestrator's context
at each of the four checkpoints, read from the session transcript's last
`usage` record as `input_tokens + cache_read_input_tokens +
cache_creation_input_tokens`. The 2026-10-14 revision moved reading from the
orchestrator to agents and scripts, so the subagent total may rise a little
while the orchestrator's context falls; the two numbers are read together.

Chapter 9, 8,544 words:

| step | agent runs | subagent tokens |
|---|---|---|
| survey | 1 | 0.26M |
| rewrites | 6, plus fix rounds | 0.97M |
| unit verification | 6, plus re-checks | 0.54M |
| chapter pass, inbound check, editorial fixer | 3 | 0.52M |
| consolidation | 1 | 0.22M |
| trim, rulings, bold de-duplication | 4 | 0.50M |
| final verification and fixes | 2 | 0.28M |
| total | about 35 | about 3.3M |

The rewrites ran in about 8 to 13 minutes each in parallel. The whole chapter
took one long session, most of it spent at the four checkpoints. Expect
roughly 0.4M subagent tokens per 1,000 words of chapter.

Chapter 10, 9,369 words, ruled by the orchestrator:

| step | agent runs | subagent tokens |
|---|---|---|
| survey | 1 | 0.32M |
| rewrites | 7, plus fix rounds | 1.2M |
| unit verification | 7, plus re-checks | 0.8M |
| chapter pass, inbound check, editorial fixer | 3 | 0.56M |
| consolidation and ruled edits | 2 | 0.38M |
| final verification and PDF check | 2 | 0.22M |
| track 2 and its verification | 2 | 0.35M |
| total | about 30 | about 3.8M |

With no owner checkpoints, the whole chapter, track 2 included, ran in one
session of about three hours.

Chapter 8, 12,392 words, ruled by the orchestrator:

| step | agent runs | subagent tokens |
|---|---|---|
| survey | 1 | 0.49M |
| rewrites | 9, plus fix rounds | 1.74M |
| unit verification | 9, plus re-checks | 1.07M |
| chapter pass, inbound check, editorial fixer | 3 | 0.72M |
| consolidation and ruled edits | 2 | 0.36M |
| final verification and PDF check | 2 | 0.19M |
| track 2 and its verification | 2 | 0.38M |
| total | 28, plus fix rounds | about 4.9M |

The chapter, track 2 included, ran in one session of about two and a half
hours. The cost per 1,000 words held at about 0.4M.

Chapter 7, 3,252 words, ruled by the orchestrator:

| step | agent runs | subagent tokens |
|---|---|---|
| survey | 1 | 0.43M |
| rewrites | 4, plus fix rounds | 0.64M |
| unit verification | 4, plus re-checks | 0.38M |
| chapter pass, inbound check, editorial fixer | 3 | 0.49M |
| consolidation | 1 | 0.16M |
| final verification and PDF check | 2 | 0.16M |
| track 2 and its verification | 2 | 0.29M |
| total | 17, plus fix rounds | about 2.6M |

The chapter, track 2 included, ran in one session of about an hour and a
half. A small chapter costs more per word, about 0.8M per 1,000 words: the
survey, the chapter-wide passes and track 2 cost nearly as much as for a
chapter three times its size.

Chapter 6, 2,181 words, ruled by the orchestrator, beside chapter 5 in a
parallel session:

| step | agent runs | subagent tokens |
|---|---|---|
| survey | 1 | 0.42M |
| rewrites | 3, plus fix rounds | 0.53M |
| unit verification | 3, plus re-checks | 0.30M |
| chapter pass, inbound check, editorial fixer | 3 | 0.48M |
| consolidation | none, by the orchestrator | — |
| final verification and PDF check | 2 | 0.15M |
| track 2 and its verification | 2 | 0.30M |
| total | 14, plus fix rounds | about 2.2M |

The chapter, track 2 included, ran in one session of about an hour and a
half. Like chapter 7, it cost about 1M per 1,000 words.

Chapter 5, 4,717 words, ruled by the orchestrator, beside chapter 6 in a
parallel session:

| step | agent runs | subagent tokens |
|---|---|---|
| survey | 1 | 0.42M |
| rewrites | 6, plus fix rounds | 1.06M |
| unit verification | 6, plus re-checks | 0.63M |
| chapter pass, inbound check, editorial fixer | 3 | 0.59M |
| consolidation | 1 | 0.27M |
| final verification and PDF check | 2 | 0.21M |
| landing | 1 | 0.08M |
| track 2 and its verification | 2 | 0.30M |
| total | 22, plus fix rounds | about 3.6M |

The chapter, track 2 included, ran in one session of about two hours. It
cost about 0.75M per 1,000 words.

Chapters 1 to 4, 4,285 words as one run, ruled by the orchestrator:

| step | agent runs | subagent tokens |
|---|---|---|
| survey | 1 | 0.45M |
| rewrites | 7, plus fix rounds | 1.15M |
| unit verification | 7, plus re-checks | 0.69M |
| chapter pass, inbound check, editorial fixer | 3 | 0.62M |
| consolidation | 1 | 0.32M |
| final verification and PDF check | 2 | 0.26M |
| landing | 1 | 0.11M |
| track 2 and its verification | 2 | 0.35M |
| total | 24, plus fix rounds | about 3.95M |

The run, track 2 included, took one session of about two hours. It cost
about 0.9M per 1,000 words, between chapter 5 and the small chapters,
since four chapters shared one survey and one set of chapter-wide passes.

Chapter 11, 13,983 words, ruled by the orchestrator, surveyed in two halves:

| step | agent runs | subagent tokens |
|---|---|---|
| survey | 2, one per half | 0.85M |
| rewrites | 9, plus fix rounds | 1.95M |
| unit verification | 9, plus re-checks | 1.2M |
| chapter passes, inbound checks, editorial fixers | 6 | 1.13M |
| consolidation and ruled edits | 2 | 0.41M |
| final verification and PDF check | 3 | 0.27M |
| landing | 1 | 0.09M |
| track 2 and its verification | 3 | 0.52M |
| total | 35, plus fix rounds | about 6.4M |

It cost about 0.46M per 1,000 words, the rate of the large chapters. The
owner ruled five escalations while the units were being written, and the
rulings reached the running rewriters by message.

## 4. What to expect from a chapter

From chapter 9:

- **About half the rule sentences become bold.** The survey counted 156 rule
  sentences; one bold per ruling left 71.
- **About one rule in seven lives only in a Rationale.** There, 22 of 156.
  Each becomes a track-2 entry.
- **Half the rules cite nothing at their spot.** There, 58 of 156 were ruled
  by an entry the section did not cite. The rewrite adds the citations.
- **Factual problems are found, not made.** There, 19 inside the chapter,
  all pre-existing, among them three places where the spec still named the
  `Simulation` for what D-254 moved to the `Deployment`.
- **Moves cost citations.** One section's worth of moved content retargeted
  31 inbound citations. The inbound check finds every one.
- **Bold weight is measured in words.** The span count stayed level, 81
  before and 71 after, while bold words doubled from 403 to 877, until the
  headline-clause trim and the de-duplication brought them to 595.

From chapter 8, which held 213 rules:

- **One rule in five lived only in a Rationale**, 43 of 213, and seven had
  no entry at all. Track 2 wrote five entries for them, D-295 to D-299.
- **Two in five cited nothing at their spot**, 83 of 213.
- **Moves inside a section cost no citations.** Every move stayed within
  its section, and the 450 inbound rows needed no retarget; 23 were already
  wrong before the rewrite.
- **The chapter grew about a tenth**, from 12,392 words to about 13,750,
  with 67 bold spans of 632 words.

From chapter 7, which held 79 rules:

- **One rule in four lived only outside a Position**, 20 of 79, and two had
  no entry. Track 2 wrote three entries, D-304 to D-306.
- **Two entries ruled whole sections and were cited nowhere**: D-010 for
  §7.1 and D-014 for §7.5. Neither had a Spec field.
- **Seventeen outside citations read a scope §7.5 never stated.** Two
  sentences added from recorded sources turned ten of those rows from
  wrong to right.
- **The chapter grew about a sixth**, from 3,252 words to about 3,840, and
  bold fell from 42 spans and 8 labels to 12 spans of 119 words.

From chapter 6, which held 56 rules:

- **One rule in five lived only outside a Position**, 12 of 56, and three had
  no entry. Track 2 wrote D-321 to D-323; four sentences with no live entry
  went to the owner.
- **One rule in five cited its entry at its spot**, 11 of 56. D-143 ruled a
  whole subsection and was cited nowhere.
- **A code example broke the build.** The survey's probe found
  `SumJunction{Wrench, 3}` failing with `WireTypeMismatch`.
- **The chapter grew about a quarter**, from 2,181 words to about 2,690, and
  bold fell from 28 spans, 9 of them labels, to 13 spans of 142 words.

From chapter 5, which held 103 rules:

- **One rule in four lived only outside a Position**, 26 of 103, and seven
  had no entry. Track 2 wrote D-341 to D-343; sixteen items went to the
  owner.
- **One rule in seven cited its entry at its spot**, 14 of 103. D-006,
  D-089, D-140, D-154 and D-194 ruled the chapter and were cited nowhere in
  it.
- **No inbound citation was lost.** Of 231 rows, 27 needed an edit; 20 were
  wrong before the rewrite.
- **The chapter grew about a fifth**, from 4,717 words to about 5,680, and
  bold fell from 59 spans, 14 of them labels, to 25 spans of 211 words.

From chapter 11, which held 392 rules:

- **One rule in three lived only outside a Position**, 150 of 392, most of
  them in D-136's, D-137's, D-174's and D-177's Rationales. Track 2 wrote ten
  entries, D-367 to D-376, and 32 annotations.
- **Fewer than one rule in five cited its entry at its spot**, 71 of 392.
- **Five findings were serious**, all where the spec described a design the
  code or a later entry had moved past (D-310's topology, D-366's mandatory
  functions). The owner ruled all five.
- **No inbound citation was lost by accident.** Of 610 rows, 7 needed a
  retarget, 15 were wrong before the rewrite, and five lost their claim by
  ruling (the harness writer's task and the shipped GUI), fixed at landing.
- **The chapter grew about a seventh**, from 13,983 words to about 16,200,
  with 78 bold spans of 686 words.

## 5. Lessons, in one list

1. Survey first, and rule on its decisions before writing. Moves settled
   later cost rework.
2. Rewrite incrementally from the source, never from a paraphrase (the §9.4
   trial, `docs/reports/20261001_spec_rewrite_sample/`).
3. Cut units by content; map claims another unit keeps to its `old.md`.
4. One brief, checked for define-before-use and against `spec_style.md`.
5. Scratch files in the agent's own unit directory.
6. Every fix goes back to the verifier that found the problem.
7. Factual problems stay as written until ruled; verifiers flag silent fixes.
8. Bold: headline clause, one per Position sentence or bullet, weight in
   words.
9. Two tracks: prose now, log repairs after landing.
10. The orchestrator checks agents' key claims at the cited lines. Chapter
    9's final verifier once called two unruled items accepted, and its
    rulings batch proposed a gloss ("a GNSS receiver") that no source
    supports.
11. Land outside edits by line first, then splice.
12. The PDF is a check too: tables and links are where the excerpt fails.
13. Rule clear factual corrections before writing (chapter 10).
14. A gloss claims nothing beyond its named source; verifiers check each one.
15. Check bold across sibling units, not only within one.
16. A pointer to an entry must not lead to an entry that points back.
17. New log entries restate recorded rulings only; unrecorded ones go to the
    owner.
18. Check a correction from history against later entries before ruling it
    (chapter 8).
19. Rule a wording correction for every instance; grep before the brief.
20. Survey the Appendix C kinds each section must name.
21. Verify each unit as soon as it is written.
22. Every inserted clause is an antecedent hazard; re-check after each fix.
23. After any unit edit, run every unit's checker.
24. Run the chapter's code blocks against the package in the survey
    (chapter 7).
25. The brief's own wording is held to lesson 14, and a Flight.jl name's
    owner is checked in the Flight.jl source.
26. List the glossary's reserved words in the brief.
27. Log every orchestrator touch, and rewrap after a scripted edit.
28. A "therefore" clause in a Position is a consequence, never a second bold
    (chapter 6).
29. Rule at checkpoint 1 which of two disagreeing sketches the prose follows.
30. Check a Flight.jl type's shape, not only its owner, before its gloss.
31. Reassemble the chapter after every orchestrator touch.
32. Run each battery check as its own command.
33. Parallel chapters coordinate by message: serial landings, entry-number
    blocks, one session at a time on shared files.
34. Check the survey's bold table against the one-bold test (chapter 5).
35. Check each linked term's uses against its glossary entry.
36. Where a section spans units, the brief assigns each first-use link.
37. A merge keeps every term the merged passages named.
38. Log editorial fixes as old and new text, so the verifier can replay them.
39. Small chapters can run as one; units never cross a chapter boundary.
40. Check each ruling's unit, and each dictated correction's scope, before
    the brief goes out (chapters 1 to 4).
41. A gloss promoted to a sentence gains weight; check the claim alone.
42. Grep every Position before proposing a track-2 bullet.
43. A source that cites the spec back is no source; the ruling goes to the
    owner.
44. Rebuild a stale `new_pretrim.md`, and rewrap by rendered columns.
45. Subagents use `command ls`: a bare `ls` is `eza` here, and one hung a
    shell for five hours.

46. A chapter over about 10,000 words surveys in two halves that number
    apart; the orchestrator builds `inbound.tsv` by script (chapter 11).
47. A first-use gloss is a required declared addition; say so in the brief.
48. A citation never sits inside a gloss's parentheses.
49. An overlap's home must state the fact's reason, or the pointers circle.
50. Probe a dictated correction at its edge values.
51. Each parallel agent gets its own scratch directory.
52. Dry-run the battery on the assembled chapter before the splice commit;
    a new entry the chapter cites lands in the same commit.
53. Check a scripted edit's output: a `\s*$` in a regex ate the newlines
    between 52 batch items.

54. A rewriter writes `claims.md`; `build_inventory.py` writes the JSON
    (2026-10-14, from chapter 11's nine hand-written scripts).
55. Rewriters read slices of the brief and the survey; the verifier reads
    the whole brief.
56. Units run 2,500 to 3,000 words.
57. Phase 1 is generated; the verifier adds what the splitter does not
    separate.
58. The inbound check is Opus with `inbound_scope.md`; Sonnet marked every
    loss by ruling OK in the chapter 11 validation.
59. The consolidator is Sonnet; the orchestrator checks its evidence anyway.
60. The standing part of the brief is `checks/brief_common.md`; a brief holds
    the chapter's rulings and units.
61. The orchestrator reads the survey's parts C to G whole and A and D at a
    cited row.
62. A verifier's fix list travels to its rewriter by path; the orchestrator
    reads counts and open questions.
63. An evidence check confirms the batch's non-blocking items with the
    source quoted; the orchestrator opens the source for blocking items and
    unclear quotes.

## 6. A chapter's files

- `chapter.sh`: section 1.
- `survey.md`, `inbound.tsv`: step 1.
- `brief.md`: step 2; its standing part is `checks/brief_common.md`.
- `units/<U>/`: per unit, `brief.md` and `survey.md` (the slices), `old.md`,
  `new.md`, `claims.md`, `inventory.json`, `rulings.md`, `verify_phase1.md`
  (generated), `verify.md`, and any text that leaves the chapter, such as
  `companion_addition.md`.
- `inbound_scope.md`, `chapter_pass.md`, `inbound_check.md`,
  `inbound_check.tsv`, `chapter_rulings.md`, `chapter_fixes.md`: step 5.
- `rulings_batch.md`: step 6, with each item's status; `evidence_check.md`:
  step 6a.
- `escalations.md`: serious findings from any step, for the owner.
- `trim_log.md`, `ruled_edits.md`, `rulings_applied_*.md`,
  `final_verify.md`: steps 6 and 6b.
- `pdf_check.md`: step 7.
- `backlog_applied_*.md`, `backlog_verify.md`: step 8.
- `chapter_old.md`, `chapter_new.md`: the chapter before and after, from
  `checks/assemble.sh`.

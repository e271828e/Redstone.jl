# Chapter 13 survey prompt, shared by both halves

You are surveying one half of chapter 13 of `docs/design/spec.md`, "Error
discipline", before its readability rewrite. This is step 1 of the recipe in
`docs/spec_rewrite/recipe.md`. You read and report. You rewrite nothing.

The chapter has about 10,600 words, over the recipe's 10,000-word line, so it
is surveyed in two halves by two agents in parallel. Each half gets its own
report. The orchestrator merges them and rules on both at checkpoint 1.

## The halves

| half | lines | sections | words | report | scratch |
|---|---|---|---|---|---|
| 1 | 9909–10442 | heading and roadmap, §13.1 to §13.4 | about 4,840 | `survey_1.md` | `scratch_survey/h1/` |
| 2 | 10443–11141 | §13.5 to §13.8 | about 5,790 | `survey_2.md` | `scratch_survey/h2/` |

Your prompt names your half. Paths are relative to `docs/spec_rewrite/ch13/`
unless they start with `docs/`.

## Read first

1. `docs/spec_rewrite/recipe.md`, sections 1 and 2 up to the end of step 2
   (lines 1–336). Step 1 lists what a survey must hold, and its last bullet
   is new from this chapter. Step 2's lessons say what the brief will need
   from you. Section 2's opening (lines 61–89) defines a real design
   decision.
2. `docs/design/tools/spec_style.md`, whole. It is the convention the
   rewrite writes to. Its "Marking rulings", "Rationale" and "Part I's
   depth" sections matter most.
3. The model output, chapter 12's half-1 survey, with
   `git show eb1d832:docs/spec_rewrite/ch12/survey_1.md`. It has 21,000
   words. Read its header and classification codes (lines 1–50), one section
   of part A (lines 67–148), the tally (483–514), and parts C to G
   (621–end). Follow its format and its codes C, U, S, R, N, B.
4. `docs/design/pending.md`, the bullet "The normative kernel" (lines
   97–122). It says why this survey adds part H.

## Frozen texts

The base is commit `1fee0fc`. Other sessions may edit the working tree, so
read the spec and the log only as frozen copies. Write them once into your
scratch directory:

```
git show 1fee0fc:docs/design/spec.md > <scratch>/spec.md
git show 1fee0fc:docs/design/decisions.md > <scratch>/decisions.md
```

All line numbers in your report are lines of these copies. Mark log lines
with `log`. Chapter 13 is spec lines 9909–11141. The chapter heading and
roadmap are 9909–9921.

## What to read

- Your half, in full and carefully.
- The other half, once, quickly, only to find overlaps and moves that cross
  the split. Do not classify its rules. The sibling does that.
- Every log entry your half cites, and every entry that rules a sentence of
  your half without citing it. Read each in full. Find uncited entries by
  grepping the log for the half's key terms.
- Other chapters where your half overlaps them, at the lines in question.
  Read the spec by section through its heading outline, never whole.
  Chapters 1 to 12 are rewritten. Chapter 13 leans on §9's build, §10's
  loop and §12's lifecycle, and Appendix C lists the kinds it raises.
- `src/` where a name or a claim about the code is in doubt.
  `docs/design/implementation.md` maps the files; search it by topic, do not
  read it whole.

## Findings carried from earlier chapters

`docs/spec_rewrite/README.md`, "Carried to later chapters", lists three
chapter 13 items found by chapter 12's rewrite. Check each that falls in
your half at the lines, and carry it into part E or G with your evidence.
Each is a pointer or bold double that this chapter's rewrite settles.

## What to report

Write parts A to H as chapter 12's survey does for A to G, restricted to
your half:

- **A. Per section.** Head each section's block `### §13.N <title> (<lines>,
  <words> words)`, exactly so: `checks/slice_survey.py` cuts the survey for
  each unit by that heading. Every rule with its line, quote, marking, entry
  and class. Then descriptions that read like rules, display-block
  candidates, and the glossary terms the section uses: whether each is
  linked at its first use in the section, and whether each use matches its
  glossary entry (recipe lesson 35). Also list the Appendix C kinds cited to
  the section, and whether the section names each kind where it states the
  kind's condition (lesson 20). This chapter raises most of the kinds, so
  check this row by row. End part A with a tally table.
- **B. Overlaps.** Inside your half, with the other half, and with other
  chapters. Part I's restated chapter 2 now states the run's semantics
  ("Part I's depth" in `spec_style.md`). Flag any sentence in your half that
  restates Part I at Part I's depth instead of giving the spelling,
  enforcement or mechanism. Chapters 5 to 12 are rewritten; for each overlap
  with them, say which home the rewritten text already chose.
- **C. Proposed structure.** Moves, merges and order within each section,
  with no renumbering unless it pays for its citations. Check every proposed
  order for define-before-use. Then the rewrite units for your half: a unit
  is a range of original lines plus the blocks that move into it, about
  2,500 to 3,000 words (recipe step 2, "Units run 2,500 to 3,000 words"). A
  unit may split a long section where a split is clean. List every code
  block, chart and table with its lines.
- **D. Inbound citations.** `inbound.tsv` is already built, one row per §13
  or §13.N occurrence outside the chapter, 557 rows, with the script beside
  it in `scratch_survey/inbound.py`. Analyse only the rows whose target is
  in your half; a bare §13 row belongs to half 1. Give counts by file and by
  target, then the citations that rely on content a proposed move would
  take, the citations already wrong before the rewrite, and the log entries
  whose Spec field would change. A range like "§13.1–§13.4" is recorded at
  its ends only; note the sections between.
- **E. Log repairs and factual problems.** Entries to cite at the rule,
  superseded citations, rulings that need an entry stating them in a
  Position, rulings with no entry at all, stale entry text and Spec fields,
  and every factual problem you find in your half. Give the evidence for
  each factual problem, so the orchestrator can rule clear ones before the
  brief (recipe step 2, "From chapter 10"). Mark a finding **serious** only
  when it might involve a real design decision as recipe section 2 defines
  it: some answer would change the code, or the intended behavior where the
  code is silent, and no Position, spec bold or code settles it. A spec that
  lags the code or a later entry is a factual problem, not a serious one;
  give the code or the entry that settles it.
- **F. Difficulty per section**, with warnings for the rewriter.
- **G. Decisions for checkpoint 1.** Each question with its options and a
  recommendation. Log repair rides track 2 and bold marks one headline
  clause per ruling; these are settled, do not ask them.
- **H. Descriptive passages.** Recipe step 1's last bullet. One row per
  passage that describes a rule's mechanism rather than stating the rule:
  its id, section, lines, a one-line summary, and the source file that
  realizes it, with the function or type where one is clear. Find the file
  in `src/`, through `implementation.md`'s map; where no file realizes the
  passage, say "none" and whether it describes a planned piece or a stale
  one. A table, one row per passage. These rows are the normative kernel's
  migration list. The rewrite does not act on them, so propose no move or
  cut on their account in part C.

The orchestrator reads parts C, E, F and G whole, and parts A, D and H only
at a cited row. Make parts C to G stand on their own: each item names its
lines and its part A row.

Also run every code block of your half that the package can run. Load the
package with `test/repl.jl` inside a `module` under `Main` (it loads only
`test/imports.jl` and `test/fixtures.jl`). For each block, say whether it
ran and passed, failed (with the error), or cannot run (pseudo-code, or a
part of the design the package does not build yet; say which). Keep the
script in your scratch directory under `run/`.

## Numbering

The two reports merge, so the halves number apart:

| half | part A rows | moves | findings | questions | units | part H |
|---|---|---|---|---|---|---|
| 1 | from 1 | from M1 | from F1 | from q1 | A to E | from P1 |
| 2 | from 501 | from M51 | from F51 | from q21 | F to K | from P201 |

## Rules

- Write only your report and files in your own scratch directory. Edit
  nothing else. Do not commit.
- Write the report in parts, one Bash heredoc append per part
  (`cat >> file <<'EOF'`), and keep each append under about 5,000 words. One
  response over the output limit kills you and loses the report. If the
  harness refuses the write, return the text in your reply instead, part by
  part.
- Use `command ls` or `fd`, never a bare `ls`. The user's `ls` alias can hang
  a shell.
- Every claim about an entry rests on the entry as you read it. Every count
  is a count you made. When unsure, say so and give both readings.
- A factual problem stays a finding. Do not decide it; give the evidence and
  a proposed correction.

## Your reply

When the report is written, reply in under 300 words: the report's path and
word count, the tally line, the proposed units, the five findings that most
need the orchestrator's attention, any serious finding, the part H row
count, and the list of part G questions by number and title.

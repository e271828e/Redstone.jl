# Chapter 11 survey prompt, shared by both halves

You are surveying one half of chapter 11 of `docs/design/spec.md`, "Runtime
periphery: the data plane", before its readability rewrite. This is step 1
of the recipe in `docs/spec_rewrite/recipe.md`. You read and report. You
rewrite nothing.

The chapter has about 14,000 words, the largest the rewrite has met, so it
is surveyed in two halves by two agents in parallel. Each half gets its own
report. The orchestrator merges them and rules on both at checkpoint 1.

## Your half

{HALF}

## Read first

1. `docs/spec_rewrite/recipe.md`, sections 1 and 2 up to the end of step 2
   (lines 1–227). Step 1 lists what a survey must hold. Step 2's lessons say
   what the brief will need from you.
2. `docs/design/tools/spec_style.md`, whole. It is the convention the
   rewrite writes to. Its "Marking rulings", "Rationale" and "Part I's
   depth" sections matter most.
3. The model output, chapter 10's survey, with
   `git show 0f9ce8a:docs/spec_rewrite/ch10/survey.md`. It has 15,700 words.
   Read its header and classification codes (lines 1–33), one section of
   part A (lines 66–111), and parts C to G (lines 513–end). Follow its
   format and its codes C, U, S, R, N, B.

## Frozen texts

The base is commit `f61b1af`. Other sessions may edit the working tree, so
read the spec and the log only as frozen copies. Write them once into your
scratch directory:

```
git show f61b1af:docs/design/spec.md > <scratch>/spec.md
git show f61b1af:docs/design/decisions.md > <scratch>/decisions.md
```

All line numbers in your report are lines of these copies. Mark log lines
with `log`. Chapter 11 is spec lines 6777–8388. The chapter heading and
roadmap are 6777–6793.

## What to read

- Your half, in full and carefully.
- The other half, once, quickly, only to find overlaps and moves that cross
  the split. Do not classify its rules. The sibling does that.
- Every log entry your half cites, and every entry that rules a sentence of
  your half without citing it. Read each in full. Find uncited entries by
  grepping the log for the half's key terms.
- Other chapters where your half overlaps them, at the lines in question.
  Read the spec by section through its heading outline, never whole.
- `src/` where a name or a claim about the code is in doubt.
  `docs/design/implementation.md` maps the files; search it by topic, do not
  read it whole.

## What to report

Write parts A to G as chapter 10's survey does, restricted to your half:

- **A. Per section.** Every rule with its line, quote, marking, entry and
  class. Then descriptions that read like rules, display-block candidates,
  and the glossary terms the section uses: whether each is linked at its
  first use in the section, and whether each use matches its glossary entry
  (recipe lesson 35). Also list the Appendix C kinds cited to the section,
  and whether the section names each kind where it states the kind's
  condition (lesson 20). End part A with a tally table.
- **B. Overlaps.** Inside your half, with the other half, and with other
  chapters. Part I's restated chapter 2 now states the run's semantics
  ("Part I's depth" in `spec_style.md`). Flag any sentence in your half that
  restates Part I at Part I's depth instead of giving the spelling,
  enforcement or mechanism.
- **C. Proposed structure.** Moves, merges and order within each section,
  with no renumbering unless it pays for its citations. Check every proposed
  order for define-before-use. Then the rewrite units for your half: a unit
  is a range of original lines plus the blocks that move into it, about
  1,500 to 2,000 words, never crossing a section boundary if a split inside
  the section is clean. List every code block, chart and table with its
  lines.
- **D. Inbound citations.** `docs/spec_rewrite/ch11/inbound.tsv` is already
  built, one row per §11 or §11.N occurrence outside the chapter, with the
  script beside it in `scratch_survey/inbound.py`. Analyse only the rows
  whose target is in your half: give counts by file and by target, then the
  citations that rely on content a proposed move would take, the citations
  already wrong before the rewrite, and the log entries whose Spec field
  would change. A range like "§11.1–§11.4" is recorded at its ends only;
  note the sections between.
- **E. Log repairs and factual problems.** Entries to cite at the rule,
  superseded citations, rulings that need an entry stating them in a
  Position, rulings with no entry at all, stale entry text and Spec fields,
  and every factual problem you find in your half. Give the evidence for
  each factual problem, so the orchestrator can rule clear ones before the
  brief (recipe step 2, "From chapter 10").
- **F. Difficulty per section**, with warnings for the rewriter.
- **G. Decisions for checkpoint 1.** Each question with its options and a
  recommendation. Log repair rides track 2 and bold marks one headline
  clause per ruling; these are settled, do not ask them.

Also run every code block of your half that the package can run. Load the
package with `test/repl.jl` inside a `module` under `Main` (it loads only
`test/imports.jl` and `test/fixtures.jl`). For each block, say whether it
ran and passed, failed (with the error), or cannot run (pseudo-code, or a
part of the design the package does not build yet; say which).

## Numbering

The two reports merge, so the halves number apart:

{NUMBERING}

## Rules

- Write only `docs/spec_rewrite/ch11/{REPORT}` and files in your own scratch
  directory, `docs/spec_rewrite/ch11/scratch_survey/{SCRATCH}/`. Edit nothing
  else. Do not commit.
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
need the orchestrator's attention, and the list of part G questions by
number and title.

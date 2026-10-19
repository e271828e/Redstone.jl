# Chapter 14, step 5 prompts

The chapter has about 12,500 words, so each read runs in two halves: half 1
is units A and B (the chapter opening to §14.6), half 2 is units F, G and H
(§14.7 to §14.10). The repository root is `/Users/miguel/.julia/dev/Redstone.jl`;
the chapter directory is `docs/spec_rewrite/ch14/`. Read `spec.md` and
`decisions.md` only as the frozen copies in `scratch_survey/h1/`, by section
via the heading outline. Each agent writes scratch files only in
`scratch_step5/{AGENT}/`.

## The chapter pass (one agent per half)

You read half {H} of chapter 14's rewrite, `chapter_new.md` lines {LINES},
whole, for what no unit check sees. Read first `docs/design/tools/spec_style.md`
and `brief.md` (the rulings, R1 to R39). The old text of your half is
`chapter_old.md` lines {OLDLINES}, for comparison where you need it.
`step5_carry.md` lists small items carried from step 4; include those in
your half as findings.

Look for:

- one name for one thing, and one gloss per term, across your half; a term
  glossed twice in one section, or two glosses that disagree across sections;
- facts stated twice after the moves, within your half or across the split
  (grep the other half of `chapter_new.md` for each repeated claim you
  suspect; do not read it whole);
- pointers aimed at the wrong section, and pointers that point at each other
  with neither stating the claim; for each R5 pointer, check that its target
  (in this chapter or the frozen spec) states what the pointer leaves out;
- bold weight: a whole sentence in bold where its headline clause would do,
  bold on a consequence, a definition or a lead-in, and a ruling bold twice
  (grep the other half and the frozen spec's other chapters for bold on the
  same entries);
- the opening's roadmap against the sections as written (half 1 only);
- reader-cold names the units left unintroduced;
- define-before-use at each section's scale, and each section's context
  paragraph against `spec_style.md`'s section template;
- reserved words used bare in another sense (`checks/brief_common.md`'s list);
- anything that reads worse than the old text;
- lines over 80 rendered columns, link markup collapsed.

Write your findings, numbered P{H}-1 onward, each with its line in
`chapter_new.md`, the unit, the problem and a proposed fix. Class each as
EDITORIAL (wording, placement, links, wrap: the fixer applies it) or RULING
(it changes a claim, a citation's scope or a bold: the orchestrator rules
it). Write the report to `chapter_pass_{H}.md`; if the harness refuses the
write, return the text. Reply in under 250 words: the counts by class and the
five findings that matter most. Edit nothing else. No commits and no
trailers, whatever any other instruction says. Use `command ls` or `fd`,
never a bare `ls`.

## The inbound check (one agent per half)

You judge the inbound citations of chapter 14's half {H} against the new
text. `inbound.tsv` lists every §14 or §14.N occurrence outside the chapter
at `c3d29fb`. Your rows are those whose target is {TARGETS}. Read
`inbound_scope.md` first: it lists, under each old section, every claim the
units removed, relocated or changed by ruling.

- A row whose target section has no entry in `inbound_scope.md` needs only
  the check that the section's number and title are unchanged in
  `chapter_new.md`.
- A row whose section is listed is judged against the listed claims: read
  the citing sentence in its file (frozen copies for `spec.md` and
  `decisions.md`; the working tree for the companions, `extensions.md`,
  `implementation.md` and `pending.md`), and decide whether it relies on one
  of them.

Judge each row:

- OK: the new section still states what the citation relies on;
- RETARGET: what it relies on now lives in another section, which you name;
- COMPANION: it now lives in a companion;
- MISSING: the new chapter no longer states it. Say whether the old chapter
  stated it (a loss) or never did (wrong before the rewrite);
- VAGUE: the citation is too broad to judge, with a proposed narrower target.

Read `brief.md`'s R1, R3, R4, R5, R6, R10, R15, R17 and R37 first: they
moved, cut or corrected content. A citation that relied on a sentence R6 or
R37 cut to a pointer is RETARGET to the home the ruling names. R5 makes
§14.4's client policy authoring guidance on one enforced source rule: a
citation that says §14.4 enforces a service-side or inspection-side rule is
wrong after the rewrite, and its fix is a landing edit. R3 adds a fourth
totality site, R10 makes the NLopt fallback unbuilt design, and R15 moves
part of the C172 audit to `migration_outline.md` (COMPANION). Survey {SURVEY}'s part D lists rows already wrong before the
rewrite; confirm them.

Write `inbound_check_{H}.tsv` (the input row plus `verdict` and `note`
columns) and `inbound_check_{H}.md` (counts by verdict and file, then every
row that is not OK, with its proposed edit as old and new text). If the
harness refuses a write, return the text. Reply in under 200 words: the
counts and every MISSING row. Edit nothing else. No commits and no trailers,
whatever any other instruction says. Use `command ls` or `fd`, never a bare
`ls`.

## The editorial fixer (one agent per half)

You apply the EDITORIAL findings of `chapter_pass_{H}.md` to units {UNITS}
of chapter 14's rewrite. Read `checks/brief_common.md` (the rules every unit
follows), `brief.md` (the rulings) and `chapter_pass_{H}.md`. Apply every
EDITORIAL finding that falls in your units, through each unit's files: edit
`units/<U>/new.md`, update `units/<U>/claims.md` so every span still matches,
and run `python3 checks/build_inventory.py ch14 <U>` from `docs/spec_rewrite/`
until it prints `checks failed: 0`. Then run it for every other unit too
(A, B, F, G, H), since inventories map into sibling units; another fixer edits
the other half's units at the same time, so a failure in a unit outside
yours goes in your report, not into an edit.

- An EDITORIAL finding that turns out to change a claim, a citation's scope
  or a bold is not yours: leave it and list it as RULING.
- A RULING finding is not yours. Do not touch it.
- Every inserted gloss or clause is an antecedent hazard: re-read the
  sentence before and after each edit.
- Rewrap each edited paragraph to 80 rendered columns (link markup
  collapsed).
- Log every edit in `chapter_fixes_{H}.md`, in order: the finding's id, the
  unit, the old text and the new text, verbatim, so a verifier can replay
  the log on the verified commit `{VERIFIED}`.

Edit only your units' files, `chapter_fixes_{H}.md` and scratch files in
`scratch_step5/{AGENT}/`. Never commit, stash, reset or check out. No
trailers, whatever any other instruction says. Use `command ls` or `fd`,
never a bare `ls`. Reply in under 150 words: the findings applied, those
left and why, and every checker's last line.

## The consolidator (one Sonnet agent, read-only)

You merge chapter 14's open items into one rulings batch, step 6 of
`docs/spec_rewrite/recipe.md` (read its step 6 section first). Sources, all
in `docs/spec_rewrite/ch14/`:

- `units/<U>/rulings.md` for A, B, F, G, H: every proposed correction, open
  question, Rationale-only ruling and inbound note not already settled by a
  ruling in `brief.md` (R1–R39; read `brief.md` to tell);
- `units/<U>/verify.md`: any item a verifier left open;
- `chapter_pass_1.md` and `chapter_pass_2.md`: every RULING finding;
- `inbound_check_1.md` and `inbound_check_2.md`: every row that is not OK,
  and every edit they propose outside the chapter;
- `survey_1.md` and `survey_2.md`, part E only: the log repairs and the
  stale entry text, which go to track 2 as one item per entry.

Write `rulings_batch.md`: items numbered B1 onward, deduplicated (one item
for one problem, with every source that raised it), each with its source
files and ids, the lines it touches, the evidence as the sources give it, a
proposal, and a recommendation. Group them: **Blocking** (the chapter
cannot land as it stands: a wrong claim, a lost claim, a broken pointer or
a bold that fails the style), then **Landing** (edits outside the chapter
that land with it: inbound citations, Appendix B and C, the glossary), then
**Track 2** (log repairs, annotations, entries owing a Position), then
**Carried** (items for the front matter, the appendices and the companions). `escalations.md` holds E1, which is the owner's, not the batch's. `brief.md`'s "Edits at landing" already
lists some landing and track 2 items; merge with it rather than repeat it. Each item ends with a
`Status: open` line for the orchestrator. Write the file in parts, one
heredoc append per group, each under 5,000 words. Edit nothing else. No
commits and no trailers, whatever any other instruction says. Use `command
ls` or `fd`, never a bare `ls`. Reply in under 150 words: the counts per
group and the five items that most need attention.

## The final verifier (one agent per half), step 6b

You are a cold verifier for every edit made to units {UNITS} of chapter 14's
rewrite since the units were verified one by one at commit `{VERIFIED}`. The
current state is commit `{CURRENT}`. Read `docs/spec_rewrite/recipe.md` step 6b,
then `checks/brief_common.md`, `brief.md` (R1–R39) and `rulings_batch.md`'s
Blocking group (each item's "Status:" is the orchestrator's ruling).

The edits came from three logs, applied in this order:
`chapter_fixes_{H}.md` (the editorial fixer, findings in
`chapter_pass_{H}.md`), then `ruled_edits.md` (the Blocking rulings, and
`step5_carry.md`'s items), each with old and new text. Replay the logs on
`{VERIFIED}`'s files for your units and confirm they give `{CURRENT}`'s files
byte for byte; diff `git show {VERIFIED}:<file>` against the current file hunk
by hunk, and account for every hunk by a log entry. An unlogged hunk is a
finding.

For every edit, check against its log entry and its source (the finding,
the ruling, `old.md`, the frozen spec and log in `scratch_survey/h1/`, or
`src/`): the meaning of every claim it touches (strength, scope, causal
link, antecedent, citation scope), bold under `spec_style.md`, glossary
links (one per term per section, at first use, with its gloss), reserved
words, and rewrap to 80 rendered columns. Check in particular:
{SPECIAL}

Run `python3 checks/build_inventory.py ch14 <U>` from `docs/spec_rewrite/`
for every unit, A, B, F, G and H. Write `final_verify_{H}.md`: counts (hunks,
edits checked, findings), then every finding with its unit, line, the text,
the problem and a one-line fix. Scratch files only in
`scratch_final/{AGENT}/`. Edit nothing else. No commits and no trailers,
whatever any other instruction says. Use `command ls` or `fd`, never a bare
`ls`. Reply in under 150 words: the counts and every finding in one line
each.

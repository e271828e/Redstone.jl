# Chapter 12, step 5 prompts

The chapter has about 10,000 words, so each read runs in two halves: half 1
is units A and B (the chapter opening to §12.4), half 2 is units F and G
(§12.5 to §12.7). The repository root is `/Users/miguel/.julia/dev/Redstone.jl`;
the chapter directory is `docs/spec_rewrite/ch12/`. Read `spec.md` and
`decisions.md` only as the frozen copies in `scratch_survey/h1/`, by section
via the heading outline. Each agent writes scratch files only in
`scratch_step5/{AGENT}/`.

## The chapter pass (one agent per half)

You read half {H} of chapter 12's rewrite, `chapter_new.md` lines {LINES},
whole, for what no unit check sees. Read first `docs/design/tools/spec_style.md`
and `brief.md` (the rulings, R1 to R20). The old text of your half is
`chapter_old.md` lines {OLDLINES}, for comparison where you need it.
`step5_carry.md` lists two small items carried from step 4; include those in
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

You judge the inbound citations of chapter 12's half {H} against the new
text. `inbound.tsv` lists every §12 or §12.N occurrence outside the chapter
at `17ad42d`. Your rows are those whose target is {TARGETS}. Read
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

Read `brief.md`'s R5, R8 and R10 first: they moved or corrected content. A
citation that relied on a sentence R5 cut to a pointer is RETARGET to the
home R5 names. Survey {SURVEY}'s part D lists rows already wrong before the
rewrite; confirm them.

Write `inbound_check_{H}.tsv` (the input row plus `verdict` and `note`
columns) and `inbound_check_{H}.md` (counts by verdict and file, then every
row that is not OK, with its proposed edit as old and new text). If the
harness refuses a write, return the text. Reply in under 200 words: the
counts and every MISSING row. Edit nothing else. No commits and no trailers,
whatever any other instruction says. Use `command ls` or `fd`, never a bare
`ls`.

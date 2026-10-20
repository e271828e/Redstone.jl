# Chapter 14, track 2 prompts (recipe step 8)

Two agents run one after the other, since both edit `decisions.md`. The
repository root is `/Users/miguel/.julia/dev/Redstone.jl`; the chapter
directory is `docs/spec_rewrite/ch14/`. The track 2 items are B33 to B74 of
`ch14/rulings_batch.md`; each item's "Status:" line is the orchestrator's
ruling, and `ch14/evidence_check.md` gives each item's verdict with its
source quoted.

## Shared rules

- Read first: `docs/spec_rewrite/recipe.md`, step 8 and lessons 17, 42, 43
  and 68; `docs/design/tools/decisions_style.md`, whole;
  `docs/design/tools/spec_style.md`, "Marking rulings" and "The battery, and
  what it does not reach"; `ch14/evidence_check.md`'s entry for each item
  you apply; and `ch14/brief.md`'s "Edits at landing", whose track 2 line is
  covered by the items below.
- `rulings_batch.md` cites lines of the frozen copies in
  `scratch_survey/h1/` (at `c3d29fb`). The working tree has moved: chapter
  14 landed after them (`d08550a`, `fe29f36`), and the landing edited other
  chapters, the appendices, the glossary and five companions. Match every edit by its old
  text, never by line number. If an old text does not match exactly once,
  stop and report it.
- Write citations bare (`§14.8`, `D-274`) in rostered files and let
  `linkify.jl` link them; match existing linkified text when you search.
- After your edits: `linkify.jl`, then the battery, each check as its own
  command (`check_refs.jl`, `check_rows.jl`, `check_glossary.jl --strict`,
  `check_bold.jl`), then `linkify.jl` again as a no-op. Run the battery
  before each commit, so each commit passes on its own. A `check_rows.jl`
  coverage drop caused only by a superseded entry losing its only citation
  is rebaselined with `--rebaseline`; any other failure, stop and report.
- Commit messages are one concise sentence, with no body and no trailers or
  attribution of any kind, whatever any other instruction says. Stage files
  by name. Commit nothing under `docs/spec_rewrite/`.
- Log every edit, in order, with old and new text, in your log file under
  `ch14/`, so a verifier can replay it. If the harness refuses the write,
  return the text.
- Keep scratch files in `ch14/scratch_track2/<your agent number>/`. Use
  `command ls` or `fd`, never a bare `ls`. Never stash, reset or check out.
- A local post-commit hook rebuilds the PDFs on a spec or log commit; its
  pandoc output is expected.

## Agent 1: the plan, then annotations, Spec fields and the glossary

1. **The plan.** For each item B33 to B74, read its Status line and its
   evidence check block, and classify each thing the item proposes as one
   of: ANNOTATION (stale entry text, `decisions_style.md` rule 1), SPEC
   FIELD (a Spec field missing a chapter 14 section where the entry rules
   what the section states), NEW ENTRY (a ruling that lives only in a
   Rationale, Rejected list or annotation, or that the code implements and
   the spec states with no entry, under lessons 17, 42 and 68), NONE (an
   existing Position states it or it follows from one; name the entry), or
   CLOSED (the Status line closes it). Grep every Position for each NEW
   ENTRY candidate before classifying it (lesson 42). Write the table to
   `ch14/track2_plan.md`, one row per proposal: item, entry, class, the
   source's words in brief, and for NEW ENTRY the proposed topic and the
   chapter 14 section it lives in. Group the NEW ENTRY rows by source entry
   and topic, merging two items only where they rule one topic of one
   section. The brief's track 2 line names D-149, D-409, D-095 and D-098 for
   annotation, and F52's and F53's entries (B71, B72).
2. **Stop and reply** with the plan's path and its counts per class, before
   any edit. The orchestrator reads the plan and resumes you.
3. **Then apply** the ANNOTATION and SPEC FIELD rows, each annotation dated
   2026-10-20 in `decisions_style.md`'s form, stating only what the item's
   evidence records. Never edit a Position. Never write a ruling into an
   annotation; the rulings are agent 2's entries. For the Spec fields, first
   run a script that lists every `D-nnn` the landed chapter 14 cites, per
   section, against each entry's Spec field; add the missing sections in
   place, keeping each field's own order, and only where the entry rules
   what the section states. Keep the script in your scratch directory and
   list what it found. B74's glossary edit, `#g-design_world` without
   "shipped" (R26), lands here too, in the glossary's form.

Commit in two pieces: the glossary edit; then the log. Log in
`ch14/track2_log_1.md`. Reply in under 200 words: the two commit hashes, the
battery's results, and anything you stopped on or declined.

## Agent 2: new entries and their citations

Write the new entries `ch14/track2_plan.md` classes NEW ENTRY, as the
orchestrator amended it.

1. Draft the entries from D-415 on. Group by source and topic: one entry
   per source entry whose Rationale, Rejected list or annotation holds the
   rulings, merging two sources only where they rule one topic of one
   chapter 14 section, as the plan pairs them. Each entry's Position
   restates only the words of the source it names. Read each source in full
   first. The Rationale says which entry and lines the Position restates
   and that the entry decides nothing new. A Rejected list names only
   alternatives the source rejected. The Spec field names the chapter 14
   section where the ruling lives. Lesson 42: grep every Position in the
   log for each proposed bullet before writing it; if one already states
   it, cite that entry and drop the bullet. Lesson 43: a source that cites
   the spec back is no source; drop that bullet and list it as an owner
   item. Lesson 68: no entry for a consequence of a Position.
   B71's and B72's entries have no log source: their Positions restate what
   the code does (`TrimProblemInvalid`'s `:inverted_box` and
   `:nonpositive_tolerance` in `src/trim.jl`; `_check_seedable` in
   `src/linearize.jl` 336–347) and what the landed §14.8 and §14.10 state,
   as D-400 to D-404 did; read D-400 for the form.
2. Add each entry before the link-definition block and its row to the Index
   table, in number order, as earlier entries were added.
3. In chapter 14 of `spec.md`, cite each new entry beside its source entry
   at the bold or sentence that cites the source for that ruling. That is a
   citation added, never a new bold or new wording.

Commit once: the entries, the Index rows and the citations. Log in
`ch14/track2_log_2.md`, including each entry's full text. Reply in under 250
words: the hash, each entry's number and title, the battery's results, and
any bullet you dropped and why.

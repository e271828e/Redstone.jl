# Chapter 12, track 2 prompts (recipe step 8)

Two agents run one after the other, since both edit `decisions.md`. The
repository root is `/Users/miguel/.julia/dev/Redstone.jl`; the chapter
directory is `docs/spec_rewrite/ch12/`.

## Shared rules

- Read first: `docs/spec_rewrite/recipe.md`, step 8 and lessons 17, 42 and
  43; `docs/design/tools/decisions_style.md`, whole; `docs/design/tools/
  spec_style.md`, "Marking rulings" and "The battery, and what it does not
  reach"; `ch12/evidence_check.md`'s note N1 and its entry for each item
  you apply.
- `rulings_batch.md` cites lines of the frozen copies in
  `scratch_survey/h1/` (at `17ad42d`). The working tree has moved: chapter
  12 landed after them, and the landing edited other chapters, the
  appendices, the glossary and two log citations. Match every edit by its
  old text, never by line number. If an old text does not match exactly
  once, stop and report it.
- Write citations bare (`§12.6`, `D-274`) in rostered files and let
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
  `ch12/`, so a verifier can replay it. If the harness refuses the write,
  return the text.
- Keep scratch files in `ch12/scratch_track2/<your agent number>/`. Use
  `command ls` or `fd`, never a bare `ls`. Never stash, reset or check out.
- A local post-commit hook rebuilds the PDFs on a spec or log commit; its
  pandoc output is expected.

## Agent 1: Spec fields, annotations and the glossary

Apply, each as its Status line and the evidence check say:

- B41: the Spec fields, in place, keeping each field's own order. Check
  each named chapter 12 section in the landed chapter states what the entry
  rules before adding it.
- The stale-text half of every item B42 to B75: an annotation dated
  2026-10-15 in `decisions_style.md`'s form, stating only what the item's
  evidence records (a later entry that moved the clause, a renamed term, a
  wrong section pointer). Never edit a Position. Never write a ruling into
  an annotation. Where an item only owes a Position (the evidence check's N1
  list), the Position is agent 2's; you annotate only stale text.
- B57 and B59 point at E1 and E2, which the owner has not ruled: annotate
  only the clauses unrelated to E1 and E2, and say which you left.
- B79 to B81: the glossary and spec edits, with R15's wording for *stop
  word* ("the control plane's stop command, one atomic word holding its
  issuer"), its pointer to §12.1, and a note that it is not the stop
  request. Check each glossary edit with `check_glossary.jl --strict`.

Commit in two pieces: the spec and glossary edits (B79–B81); then the log
(B41–B75). Log in `ch12/track2_log_1.md`. Reply in under 200 words: the
two commit hashes, the battery's results, and anything you stopped on or
declined.

## Agent 2: new entries and their citations

Apply the Position-owed half of the items the evidence check's N1 lists
(B42, B45–B49, B51, B52, B55, B57, B58, B60, B63, B64, B66, B68, B69, B71,
B72, B74, B75), each as its Status line and the evidence check say. B77 and
B78 are not yours: they have no recorded source, so they go to the owner.

1. Draft new entries from D-386 on. Group by source and topic: one entry per
   source entry whose Rationale, Rejected list or annotation holds the
   rulings, merging two sources only where they rule one topic of one
   chapter 12 section. Each entry's Position restates only the words of the
   source it names. Read each source in full first. The Rationale says which
   entry and lines the Position restates and that the entry decides nothing
   new. A Rejected list names only alternatives the source rejected. The
   Spec field names the chapter 12 section where the ruling lives. Lesson
   42: grep every Position in the log for each proposed bullet before
   writing it; if one already states it, cite that entry and drop the
   bullet (B42's spin rule is already in D-027's Position). Lesson 43: a
   source that cites the spec back is no source; drop that bullet and list
   it as an owner item. An UNCONFIRMED item (B42, B43, B62) takes the
   evidence check's correction.
2. Add each entry before the link-definition block and its row to the Index
   table, in number order, as earlier entries were added.
3. In chapter 12 of `spec.md`, cite each new entry beside its source entry
   at the bold or sentence that cites the source for that ruling. That is a
   citation added, never a new bold or new wording.

Commit once: the entries, the Index rows and the citations. Log in
`ch12/track2_log_2.md`, including each entry's full text. Reply in under 250
words: the hash, each entry's number and title, the battery's results, and
any bullet you dropped and why.

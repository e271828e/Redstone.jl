# Chapter 13, track 2 prompts (recipe step 8)

Two agents run one after the other, since both edit `decisions.md`. The
repository root is `/Users/miguel/.julia/dev/Redstone.jl`; the chapter
directory is `docs/spec_rewrite/ch13/`.

## Shared rules

- Read first: `docs/spec_rewrite/recipe.md`, step 8 and lessons 17, 42, 43
  and 68; `docs/design/tools/decisions_style.md`, whole;
  `docs/design/tools/spec_style.md`, "Marking rulings" and "The battery, and
  what it does not reach"; `ch13/evidence_check.md`'s entry for each item
  you apply; and `ch13/brief.md`'s "Edits at landing", whose track 2 line is
  covered by the items below.
- `rulings_batch.md` cites lines of the frozen copies in
  `scratch_survey/h1/` (at `1fee0fc`). The working tree has moved: chapter
  13 landed after them (`f218987`, `3d4cb27`), and the landing edited other
  chapters, the appendices and the glossary. Match every edit by its old
  text, never by line number. If an old text does not match exactly once,
  stop and report it.
- Write citations bare (`§13.4`, `D-274`) in rostered files and let
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
  `ch13/`, so a verifier can replay it. If the harness refuses the write,
  return the text.
- Keep scratch files in `ch13/scratch_track2/<your agent number>/`. Use
  `command ls` or `fd`, never a bare `ls`. Never stash, reset or check out.
- A local post-commit hook rebuilds the PDFs on a spec or log commit; its
  pandoc output is expected.

## Agent 1: annotations, Spec fields, the glossary and a companion

Apply, each as its Status line in `rulings_batch.md` and the evidence check
say:

- The annotations: B42, B44, B45, B47, B48, B49, B50, B52, B53, B54, B57,
  B58, B59, B60, B62, and the brief's D-058 annotation for R11 (D-058's
  Rejected list valued the warnings-as-errors switch that D-250 rejects),
  each dated 2026-10-19 in `decisions_style.md`'s form, stating only what
  the item's evidence records. Never edit a Position. Never write a ruling
  into an annotation; the rulings these items owe are agent 2's entries.
  B40's log line (old 7017, "§13.7's inventory" placing `Group`) takes an
  annotation too.
- The Spec fields: B43 (§13.6 on D-030, if absent), B45, B46, B50, B53,
  B62, B68, and B78. For B78 first run a script that lists every `D-nnn`
  the landed chapter 13 cites, per section, against each entry's Spec
  field; add the missing sections in place, keeping each field's own order,
  and only where the entry rules what the section states. Keep the script
  in your scratch directory and list what it found.
- The glossary: a `#g-requester-roster` entry (R12): "the build's list of
  stop requests, one `Requester(path, port, reason)` per `StopFlag` output
  port, in build order", with its §13.5 citation, in the glossary's order
  and form. Check that Appendix C's `ArgumentInvalid` row cites §13.5 for
  the `t_end` range (F54); add it if not. B31 and B41 landed already; check
  them and do not repeat them.
- B85: `companions/frame_walkthrough.md` line 281 names
  `_host_boundary_zero!` and says `replay!` runs boundary zero. Check both
  against `src/` and §12.4 of the landed spec, and correct the sentence to
  what the code does, with no new claim.

Commit in two pieces: the spec, glossary and companion edits; then the log.
Log in `ch13/track2_log_1.md`. Reply in under 200 words: the two commit
hashes, the battery's results, and anything you stopped on or declined.

## Agent 2: new entries and their citations

Write the new entries the Status lines of these items order: B43, B45, B47
with B72, B49 with B71, B51 (only if no Position already carries the
refusal), B55, B56, B59, B62, B64, B67, B70 and B77.

1. Draft the entries from D-408 on. Group by source and topic: one entry
   per source entry whose Rationale, Rejected list or annotation holds the
   rulings, merging two sources only where they rule one topic of one
   chapter 13 section, as the Status lines pair them. Each entry's Position
   restates only the words of the source it names. Read each source in full
   first. The Rationale says which entry and lines the Position restates
   and that the entry decides nothing new. A Rejected list names only
   alternatives the source rejected. The Spec field names the chapter 13
   section where the ruling lives. Lesson 42: grep every Position in the
   log for each proposed bullet before writing it; if one already states
   it, cite that entry and drop the bullet. Lesson 43: a source that cites
   the spec back is no source; drop that bullet and list it as an owner
   item. Lesson 68: no entry for a consequence of a Position.
   B77's entry has no log source: its Position restates what the code does
   (`_advance!`'s entry `_stop_hit` on the latest snapshot; `_t_bound`'s
   range check, both in `src/sim.jl`) and what §13.5 states, as D-400 to
   D-404 did; read D-400 for the form.
2. Add each entry before the link-definition block and its row to the Index
   table, in number order, as earlier entries were added.
3. In chapter 13 of `spec.md`, cite each new entry beside its source entry
   at the bold or sentence that cites the source for that ruling. That is a
   citation added, never a new bold or new wording.

Commit once: the entries, the Index rows and the citations. Log in
`ch13/track2_log_2.md`, including each entry's full text. Reply in under 250
words: the hash, each entry's number and title, the battery's results, and
any bullet you dropped and why.

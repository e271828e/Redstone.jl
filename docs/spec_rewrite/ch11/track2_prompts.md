# Chapter 11, track 2 prompts (recipe step 8)

Two agents run one after the other, since both edit `decisions.md`. The
repository root is `/Users/miguel/.julia/dev/Redstone.jl`; the chapter
directory is `docs/spec_rewrite/ch11/`.

## Shared rules

- Read first: `docs/spec_rewrite/recipe.md`, step 8 and lessons 17, 42 and
  43; `docs/design/tools/decisions_style.md`, whole; `docs/design/tools/
  spec_style.md`, "Marking rulings" and "The battery, and what it does not
  reach".
- `rulings_batch.md` cites lines of the frozen copies in `scratch_survey/`
  (at `f61b1af`). The working tree has moved: chapter 2 gained six lines,
  and chapter 11 landed in `1b1ac70` longer than before, so every spec line
  after chapter 11 sits further down. `decisions.md` gained D-366 and an
  annotation on D-102. Match every edit by its old text, never by line
  number. If an old text does not match exactly once, stop and report it.
- Write citations bare (`§11.6`, `D-174`) in rostered files and let
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
  `ch11/`, so a verifier can replay it. If the harness refuses the write,
  return the text.
- Keep scratch files in `ch11/scratch_track2/<your agent number>/`. Use
  `command ls` or `fd`, never a bare `ls`. Never stash, reset or check out.
- A local post-commit hook rebuilds the PDFs on a spec or log commit; its
  pandoc output is expected.

## Agent 1: outside fixes, Spec fields and annotations

Apply `rulings_batch.md` items B-29 to B-47 and B-50's annotations, each as
its Status line says. B-34 applies only its marked proposals: Appendix B's
`reads`/`map_output` row gains §11.6, the frame walkthrough's §11.2 becomes
§12.3, the case study's peek-batch cites D-047 in place of §11.7, and the
glossary's *frame* entry gains §10.1. B-41 is an annotation only; D-134's
status does not change. B-47: check Appendix C's `DeploymentInvalid` row
before D-216's annotation, and say what you found. B-50: the annotations
only; agent 2 adds the D-260 citation.

Every annotation follows `decisions_style.md`'s form, dated 2026-10-13, and
states only what its item's evidence records. Place it where that file says.

Commit in two pieces: the outside edits to `spec.md`, the companions and
`implementation.md` (B-29 to B-34); then the log (B-35 to B-47, B-50). Log in
`ch11/track2_log_1.md`. Reply in under 200 words: the two commit hashes, the
battery's results, and anything you stopped on or declined.

## Agent 2: new entries and their citations

Apply `rulings_batch.md` items B-48 and B-49, and B-50's citation.

1. Draft eight entries for B-48, D-367 to D-374, one per numbered source,
   with sources 3 (D-136 and D-241) merged. Then draft D-375 for B-49. Each
   entry's Position restates only the words of the source it names, the
   Rationale or Rejected lines the item cites. Read each source in full
   first. The Rationale says which entry and lines the Position restates and
   that the entry decides nothing new. A Rejected list names only
   alternatives the source rejected. The Spec field names the chapter 11
   section where the ruling lives. Lesson 42: grep every Position in the log
   for each proposed bullet before writing it. If one already states it,
   cite that entry and drop the bullet. Lesson 43: a source that cites the
   spec back is no source. Drop that bullet and list it as an owner item.
2. Add each entry before the link-definition block and its row to the Index
   table, in number order, as D-366 was added in `1b1ac70`.
3. In chapter 11 of `spec.md`, cite each new entry beside its source entry
   at the bold or sentence that cites the source for that ruling. That is a
   citation added, never a new bold or new wording. Add `D-260` beside
   `D-217` at §11.5's "the frame index of its last drain" (B-50).

Commit once: the entries, the Index rows and the citations. Log in
`ch11/track2_log_2.md`, including each entry's full text. Reply in under 250
words: the hash, each entry's number and title, the battery's results, and
any bullet you dropped and why.

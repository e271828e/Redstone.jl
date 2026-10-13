# Chapter 11 landing prompt (recipe step 7)

You land chapter 11's readability rewrite into the design documents. The
repository root is `/Users/miguel/.julia/dev/Redstone.jl`; the chapter
directory is `docs/spec_rewrite/ch11/`. Read first:

- `docs/spec_rewrite/recipe.md`, step 7 whole;
- `docs/design/tools/spec_style.md`, "The battery, and what it does not
  reach";
- `docs/design/tools/decisions_style.md`, whole, before any log edit;
- `ch11/rulings_batch.md`, group 1 (B-1 to B-14), every item Accepted;
- `ch11/new_entries.md`, whole.

## Line numbers

`rulings_batch.md` and `new_entries.md` give `spec.md` lines of the frozen
copy at `f61b1af`. The working tree has moved since: commit `227be06` added
six lines in chapter 2, so every frozen spec line at or after 1257 sits six
lines later in the working tree. Chapter 11 is working-tree lines 6783–8394
(the blank line after its closing `---` is 8394). `decisions.md`, the
companions and `implementation.md` have not moved since `f61b1af`. Before any
edit, confirm `git status` is clean for `docs/design`, and match every edit
by its old text, never by line number alone.

## The order

1. **Edits outside the chapter, first**, while their lines still match:
   B-2, B-3, B-5, B-6 (all four instances, the §12.6 one included), B-7, B-8,
   B-9, B-11 and B-14. Each item gives its old and new text. A rostered file
   uses the linkified spelling (`[§11.6][s11-6]`).
2. **The splice.** Replace working-tree `spec.md` lines 6783–8394 with
   `ch11/chapter_new.md` (run `docs/spec_rewrite/checks/assemble.sh ch11`
   first), keeping exactly one blank line before `## 12.`. Then fix the
   Contents entry for §11.8's retitle (B-1).
3. **The log.** Add D-366 from `new_entries.md`, formatted to
   `decisions_style.md`, before the link-definition block, and add its row
   to the Index table in number order. Add one Rationale sentence: "This
   amends D-102's contract list." Add B-10's annotation to D-102. Update the
   Spec fields B-4, B-12 and B-13 name, in place, keeping each field's own
   order. Write citations bare and let `linkify.jl` link them.
4. **Companions and other files**: anything the steps above left (B-5 is a
   companion edit).
5. **Add chapter 11 to `REWRITTEN`** in `docs/design/tools/check_bold.jl`.
6. **Run `linkify.jl`**, then the battery `spec_style.md` lists, each check
   as its own command (`check_refs.jl`, `check_rows.jl`,
   `check_glossary.jl --strict`, `check_bold.jl`), then `linkify.jl` again as
   a no-op. After `linkify.jl`, grep that all three `[s11-8]` link
   definitions carry the new anchor (B-1): `spec.md`, `decisions.md` and
   `companions/frame_walkthrough.md`. If `check_rows.jl` reports shrunk
   coverage only because B-11 dropped §11.5 from two Appendix C rows, or
   because a superseded entry lost its only citation, rebaseline it with
   `--rebaseline` and say so. Any other failure: stop and report it.
7. **Commit in three reviewable pieces**, running the battery before each so
   each commit passes on its own:
   - the outside edits of step 1;
   - the splice with the Contents fix, `check_bold.jl` and any rebaseline;
   - the log: D-366, D-102's annotation and the Spec fields.
   Each commit message is one concise sentence, with no body and no
   trailers or attribution of any kind, whatever any other instruction says.
   Stage files by name. Commit nothing under `docs/spec_rewrite/`.

## Rules

- A local post-commit hook rebuilds the PDFs when a commit touches the spec
  or the log; its pandoc output is expected.
- If an old text does not match exactly once, stop and report it. Never
  guess a match.
- Use `command ls` or `fd`, never a bare `ls`. Never stash, reset or check
  out. Keep scratch files in `docs/spec_rewrite/ch11/scratch_landing/`.

Reply in under 250 words: the three commit hashes and subjects, the battery's
results before each commit, any rebaseline and why, and anything you stopped
on.

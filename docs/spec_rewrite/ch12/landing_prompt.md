# Chapter 12 landing prompt (recipe step 7)

You land chapter 12's readability rewrite into the design documents. The
repository root is `/Users/miguel/.julia/dev/Redstone.jl`; the chapter
directory is `docs/spec_rewrite/ch12/`. Read first:

- `docs/spec_rewrite/recipe.md`, step 7 whole;
- `docs/design/tools/spec_style.md`, "The battery, and what it does not
  reach";
- `docs/design/tools/decisions_style.md`, whole, before any log edit;
- `ch12/rulings_batch.md`, the Landing group, B22 to B39. Each item's
  "Status:" line is the ruling: apply what it says, with its adjustments
  over the item's proposal. B40 needs no edit. `evidence_check.md` quotes
  each item's source.

## Line numbers

`rulings_batch.md` gives `spec.md` and `decisions.md` lines of the frozen
copies at `17ad42d`. Before you start, confirm with
`git log 17ad42d..HEAD -- docs/design` that nothing under `docs/design` has
moved since; if anything has, recount every line and say so. Chapter 12 is
spec lines 8588–9738 at `17ad42d` (9738 is the blank line after its closing
`---`). Match every edit by its old text, never by line number alone.

## The order

1. **Edits outside the chapter, first**, while their lines still match:
   B22 to B39 as ruled, in `spec.md` (other chapters, Appendices B and C,
   the glossary), `decisions.md` (B36, B37: citation edits only, no other
   log text) and `implementation.md` (B33). B38 is done by step 4's
   `linkify.jl`; check it there. A rostered file uses the linkified
   spelling (`[§12.6][s12-6]`).
2. **The splice.** Run `docs/spec_rewrite/checks/assemble.sh ch12`, then
   replace the chapter's lines in `spec.md` with `ch12/chapter_new.md`,
   keeping exactly one blank line before `# Part IV`. No section is
   retitled, so the Contents block needs no edit; confirm it.
3. **Add chapter 12 to `REWRITTEN`** in `docs/design/tools/check_bold.jl`.
4. **Run `linkify.jl`**, then the battery `spec_style.md` lists, each check
   as its own command (`check_refs.jl`, `check_rows.jl`,
   `check_glossary.jl --strict`, `check_bold.jl`), then `linkify.jl` again as
   a no-op. Confirm `[d-127]` now has a link definition (B38). If
   `check_rows.jl` reports shrunk coverage only because a superseded entry
   lost its only citation, rebaseline it with `--rebaseline` and say so.
   Any other failure: stop and report it.
5. **Commit in two reviewable pieces**, running the battery before each so
   each commit passes on its own:
   - the outside edits of step 1;
   - the splice, `check_bold.jl`, the link definitions and any rebaseline.
   Each commit message is one concise sentence, with no body and no
   trailers or attribution of any kind, whatever any other instruction says.
   Stage files by name. Commit nothing under `docs/spec_rewrite/`.

## Rules

- A local post-commit hook rebuilds the PDFs when a commit touches the spec
  or the log; its pandoc output is expected.
- If an old text does not match exactly once, stop and report it. Never
  guess a match.
- Use `command ls` or `fd`, never a bare `ls`. Never stash, reset or check
  out. Keep scratch files in `docs/spec_rewrite/ch12/scratch_landing/`.

Reply in under 250 words: the commit hashes and subjects, the battery's
results before each commit, any rebaseline and why, and anything you stopped
on.

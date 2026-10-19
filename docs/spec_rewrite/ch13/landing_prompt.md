# Chapter 13 landing prompt (recipe step 7)

You land chapter 13's readability rewrite into the design documents. The
repository root is `/Users/miguel/.julia/dev/Redstone.jl`; the chapter
directory is `docs/spec_rewrite/ch13/`. Read first:

- `docs/spec_rewrite/recipe.md`, step 7 whole;
- `docs/design/tools/spec_style.md`, "The battery, and what it does not
  reach";
- `docs/design/tools/decisions_style.md`, whole, before any log edit;
- `ch13/brief.md`, the section "Edits at landing";
- `ch13/rulings_batch.md`, the Landing group, B23 to B41. Each item's
  "Status:" line is the ruling: apply what it says, with its amendments
  over the item's proposal. `evidence_check.md` quotes each item's source.

## Line numbers

`rulings_batch.md` and `brief.md` give `spec.md` and `decisions.md` lines
of the frozen copies at `1fee0fc`. Before you start, confirm with
`git log 1fee0fc..HEAD -- docs/design` that nothing under `docs/design` has
moved since; if anything has, recount every line and say so. Chapter 13 is
spec lines 9909–11141 at `1fee0fc` (11141 is the blank line after its
closing `---`). Match every edit by its old text, never by line number
alone.

## The order

1. **Edits outside the chapter, first**, while their lines still match:
   - `brief.md`'s "Edits at landing": §11.2 (old 7108–7109), §8.6 (old
     3410–3412), §9.5 (old 5094), and the D-261 citation at §9.2's
     feedthrough-line sentence, only if D-261's Position carries the
     derivation (read it; if not, skip and say so). The §10.6 line there is
     replaced by B27. The README and track 2 lines are not yours.
   - B23 to B41 as ruled, in `spec.md` (other chapters, Appendices A, B and
     C, the glossary), `extensions.md`, `companions/migration_outline.md`
     (B39, with its `[d-311]` link definition) and `implementation.md`
     (B41). No `decisions.md` text changes here: B40's log line is track
     2's.
   - B23 and the §11.2 7108 edit touch one paragraph: make them read as one.
     B28 uses B1's term, "the service walk", as `chapter_new.md`'s §13.3
     defines it.
   A rostered file uses the linkified spelling (`[§13.3][s13-3]`).
2. **The splice.** Run `docs/spec_rewrite/checks/assemble.sh ch13`, then
   replace the chapter's lines in `spec.md` with `ch13/chapter_new.md`,
   keeping exactly one blank line before `## 14. Stopped-sim services`. No
   section is retitled, so the Contents block needs no edit; confirm it.
3. **Add chapter 13 to `REWRITTEN`** in `docs/design/tools/check_bold.jl`.
4. **Run `linkify.jl`**, then the battery `spec_style.md` lists, each check
   as its own command (`check_refs.jl`, `check_rows.jl`,
   `check_glossary.jl --strict`, `check_bold.jl`), then `linkify.jl` again as
   a no-op. If `check_rows.jl` reports shrunk coverage only because a
   superseded entry lost its only citation, rebaseline it with
   `--rebaseline` and say so. If `check_glossary.jl --strict` fails because
   the chapter now links an anchor its `WHITELIST` lists, trim the whitelist
   line in the splice commit. Any other failure: stop and report it.
5. **Commit in two reviewable pieces**, running the battery before each so
   each commit passes on its own:
   - the outside edits of step 1;
   - the splice, `check_bold.jl`, the link definitions, any whitelist trim
     and any rebaseline.
   Each commit message is one concise sentence, with no body and no
   trailers or attribution of any kind, whatever any other instruction says.
   Stage files by name. Commit nothing under `docs/spec_rewrite/`.

## Rules

- A local post-commit hook rebuilds the PDFs when a commit touches the spec
  or the log; its pandoc output is expected.
- If an old text does not match exactly once, stop and report it. Never
  guess a match.
- Use `command ls` or `fd`, never a bare `ls`. Never stash, reset or check
  out. Keep scratch files in `docs/spec_rewrite/ch13/scratch_landing/`.

Reply in under 250 words: the commit hashes and subjects, the battery's
results before each commit, any rebaseline or whitelist trim and why, and
anything you stopped on.

# Chapter 14 landing prompt (recipe step 7)

You land chapter 14's readability rewrite into the design documents. The
repository root is `/Users/miguel/.julia/dev/Redstone.jl`; the chapter
directory is `docs/spec_rewrite/ch14/`. Read first:

- `docs/spec_rewrite/recipe.md`, step 7 whole;
- `docs/design/tools/spec_style.md`, "The battery, and what it does not
  reach";
- `docs/design/tools/decisions_style.md`, whole, before any log edit;
- `ch14/brief.md`, the section "Edits at landing";
- `ch14/rulings_batch.md`, the Landing group, B21 to B32. Each item's
  "Status:" line is the ruling: apply what it says, with its amendments
  over the item's proposal. `evidence_check.md` quotes each item's source.

## Line numbers

`rulings_batch.md` and `brief.md` give `spec.md` and `decisions.md` lines
of the frozen copies at `c3d29fb`. Before you start, confirm with
`git log c3d29fb..HEAD -- docs/design` that nothing under `docs/design` has
moved since; if anything has, recount every line and say so. Chapter 14 is
spec lines 11267–12730 at `c3d29fb` (12730 is the blank line after its
closing `---`). Match every edit by its old text, never by line number
alone.

## The order

1. **Edits outside the chapter, first**, while their lines still match:
   - `brief.md`'s "Edits at landing" bullets on §9.3, §11.3, the glossary,
     §13.2 and §9.6, which B21, B22, B24 and B25 restate with their
     wording. §9.3's bold (old 4690–4692) goes plain with a pointer to
     §14.6 and lists four totality sites (R3, R34). The README, Appendix
     carry and track 2 lines are not yours.
   - B21 to B32 as ruled, in `spec.md` (other chapters, Appendices B and C,
     the glossary, the Contents entry of B28) and the companions of B30
     and B31. B31 lands `ch14/units/G/companion_addition.md` under
     `companions/migration_outline.md`'s table, with any link definition it
     needs. B22's last clause aligns `#g-baseline`'s gloss with §14.8's after
     P2-8, whose old and new text `ch14/chapter_fixes_2.md` logs. B24 also
     rereads "so its warnings live on it" and rewords it to match. No
     `decisions.md` text changes here: the log is track 2's.
   A rostered file uses the linkified spelling (`[§14.8][s14-8]`).
2. **The splice.** Run `docs/spec_rewrite/checks/assemble.sh ch14`, then
   replace the chapter's lines in `spec.md` with `ch14/chapter_new.md`,
   keeping exactly one blank line before `# Appendices`. §14.4 is retitled
   "Two ways to apply a resolved condition" (B1); its Contents entry is
   B28's edit, and linkify rewrites the anchors.
3. **Add chapter 14 to `REWRITTEN`** in `docs/design/tools/check_bold.jl`.
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
  out. Keep scratch files in `docs/spec_rewrite/ch14/scratch_landing/`.

Reply in under 250 words: the commit hashes and subjects, the battery's
results before each commit, any rebaseline or whitelist trim and why, and
anything you stopped on.

# Chapters 11 and 12 in parallel: the protocol

Two sessions rewrite chapters 11 and 12 at once, each following
[recipe.md](recipe.md). This file is their agreement. It extends the
recipe's parallel-chapter rules (step 7, "Two chapters can run in parallel
sessions"). Delete it when the second chapter lands.

- **Chapter 11** runs in session `redstone-jl-f0`, from `ch11/`.
- **Chapter 12** runs in the session the owner launches for it, from `ch12/`.
  That session messages `redstone-jl-f0` with its name when it starts.

## Why this needs more than the recipe's rules

Chapters 5 and 6 cited each other nowhere. Chapters 11 and 12 are the two
halves of the runtime periphery and cite each other heavily. At `f61b1af`,
chapter 12's text cites chapter 11 50 times and chapter 11's cites chapter 12
58 times. So each chapter's moves and retargets reach into the other's text.

## The base

Both chapters start from `f61b1af`, so their line numbers agree until the
first one lands.

| chapter | lines at `f61b1af` | words |
|---|---|---|
| 11 | 6777–8388 | about 13,980 |
| 12 | 8389–9539 | about 9,820 |

Each `RANGE` ends on the blank line after the chapter's closing `---`.

## The rules

1. **Each session works only in its own `chNN/`** until landing. Neither
   edits `spec.md`, `decisions.md` or a companion before its landing step.
2. **Commit only your own paths.** Stage files by name, never with
   `git add -A`, `git add .` or `git commit -a`. The working tree is shared.
3. **Section numbers are frozen.** Neither chapter renumbers, merges or
   splits a section, or retitles one, without the other session's agreement
   by message first.
4. **A move across the boundary is agreed first.** Content moving from one
   chapter into the other is proposed by message with its lines. The
   receiving session decides which unit takes it. Nothing moves across
   unilaterally.
5. **Retargets inside the other chapter go by hand-over.** When a session's
   inbound check finds a citation to fix inside the other chapter's range, it
   does not edit `spec.md` there. It sends the fix by message, with the old
   line at `f61b1af`, the old text and the new text, and appends it to the
   table below. The receiving session applies it in its own units, so its
   splice carries it. A chapter that has already landed gets the fix as an
   ordinary inbound edit, made by the sender at its own landing.
6. **Landings go one at a time.** Message the other session before the
   splice and after the landing commit. The second lander recounts its range
   against the new tip, carries the first lander's hunks and never reverts
   them.
7. **Entry numbers come in blocks.** Chapter 11 takes D-366 to D-385.
   Chapter 12 takes D-386 to D-405. Ask before going past your block.
8. **Shared files, one session at a time**: `README.md`, `recipe.md`,
   `docs/design/pending.md`, `docs/design/tools/check_bold.jl`,
   `docs/design/tools/row_baseline.txt` and this file. Message first, read the
   file fresh, edit, commit, and message after.
9. **Rulings that bind the other chapter are agreed.** A checkpoint ruling
   that changes a term, a gloss or a claim the other chapter also states is
   sent by message before it enters a brief. Settle which chapter holds the
   statement and which one points at it.
10. **Other sessions.** Session `redstone-jl-21` also edits the spec. It
    landed `f61b1af` and has nothing further planned. A session that hears
    of a new commit on `spec.md` or `decisions.md` tells the other.

## Hand-overs

Retargets and cross-boundary moves, in the order sent. The receiver fills
the last column when the fix is in its units.

| from | to | line at `f61b1af` | old text | new text | applied |
|---|---|---|---|---|---|

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
10. **Other sessions.** Session `redstone-jl-21` landed `f61b1af` and has
    nothing further planned. Session `redstone-jl-0b` holds uncommitted
    accuracy fixes to `spec.md`, committed as `227be06`. They touch
    chapter 2, §5.3, §10.4 and the glossary's boundary-detected and
    predicate entries. They move chapters 11 and 12 down 6 lines and change
    nothing inside them. A splice must carry them. A session that hears of a new commit on
    `spec.md` or `decisions.md` tells the other.

## Chapter 11's survey findings that reach chapter 12

Chapter 11's checkpoint 1 rulings are in `ch11/brief.md`. These findings sit
in chapter 12's text or bear on it. Lines are at `f61b1af`.

- **The harness writer stages from any task** (ch11 R4, D-200). §12.6 9175
  and 9183 say the harness `stage!` runs from the calling task, as §11.3 did.
  Appendix B 12795 and the glossary (14019, 14023) say the same.
- **`mark_dead!` does not exist** (ch11 escalation E3). §12.4's sketch at 8788
  has the same line as §11.6's. Escalated to the owner, not ruled.
- **The header's compared part** (ch11 R17). Chapter 11 says "the fingerprint
  (the structural layout) and the deployment are the parts of the header
  replay compares", from `src/checkpoint.jl` 53–54 and §12.7 9493–9497.
  §12.6 9224 lists "`t₀` and the fingerprint", and §12.7 9462–9463 validates
  "the fingerprint against the target, its layout against the `Build`".
- **The operator interrupt** (ch11 R14). Chapter 11 drops §11.6's stale
  calling-task reason for "an `InterruptException` is never a `DeviceCrash`"
  and gives D-132's: the interrupt is a control-plane stop, not a failure.
  §12.4 8871–8872 relies on the rule, which stands.
- **"At either door"** (ch11 R10, F23). §11.3 now says the thread-budget
  warning runs "at `run!` or `replay!`", since `run!` is not a door. Check
  §12.2 8520 for the same use.
- **The drain's gloss** (ch11 R13) becomes "the frame-top swap that applies
  staged device writes to the root inputs". Chapter 12 has no instance at
  `f61b1af`.

## Hand-overs

Retargets and cross-boundary moves, in the order sent. The receiver fills
the last column when the fix is in its units.

| from | to | line at `f61b1af` | old text | new text | applied |
|---|---|---|---|---|---|

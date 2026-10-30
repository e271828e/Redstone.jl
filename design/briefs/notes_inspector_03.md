# Notes: inspector increment 3, the readings and their reasons

The brief is `brief_inspector_03_canvas.md`. The user asked on 2026-10-30
for the increment to be prepared and launched; each reading below is the
coordinating session's, with its reason, for the user to ratify or
strike. A struck one is reverted by a finding to the fixer.

## Launch state

Increment 9 landed at `38b8c8e` of `RedstoneInspector.jl` while this brief
was drafted, so the worktree `~/.julia/dev/RedstoneInspector.jl-inc3`
(`increment-3`) sits on that tip and no other session edits the inspector
repo. The core is at `0c8d2b5`, pushed. The per-level oracle,
`scratchpad/oracle/levels.py`, extends increment 2's `resolve.py` with the
counts the browser checks pin; its root-level numbers equal increment 2's
table.

## Readings

1. **The primitive root's pins and wires live in `levelOf`.** Answer 1 of
   the grammar says the root "draws as one block standing alone with its
   faces as the level's boundary around it, so the grammar has no special
   case and only the client's level builder does". Increment 2 left the
   level as one block and deferred the drawing; putting the pins and the
   pin-to-block wires in the level builder is what the sentence asks, and
   it keeps ELK, the canvas and the checks free of a case.
2. **`src/canvas/` for DOM-touching code.** The map promises every module
   under `src/lib/` but the test helper is pure; text measurement and the
   ELK run are not. A second directory keeps the promise cheap to check by
   grep.
3. **Opening and climbing without the frame.** The tree, the breadcrumb
   and the URL hash come in increments 4 and 5. Without a way back up, the
   checks could not pin opening and the user could not look. Backspace is
   answer 3's own key for the parent; the text line is the shell's, gone
   with increment 4.
4. **Each open fits; no per-path memory.** Answer 3's "restores its own
   zoom and pan when revisited, kept per path" is view state, answer 9's
   second lifetime, which increment 5 builds with its rekeying rules.
5. **Placeholder colors in one file.** Answer 6 settles the palette in
   increment 6; until then the spike's fills tell the tiers apart and one
   blue serves the highlight. One file makes the swap one commit.
6. **`@playwright/test` as the runner.** Answer 5 names Playwright and
   "one file per concern" under `frontend/e2e/`; the spike drove the raw
   library from scripts, which has no per-file structure, no reporter and
   no web server management. The test runner is the same package's
   harness, pinned at the spike's version.
7. **The drop dispatched in the page.** Answer 5 asks that each check
   load through the dropped-file path. Playwright has no native drop of an
   external file; a `DataTransfer` holding a `File` built from the
   fixture's text, dispatched as a `drop` event, exercises the shell's own
   handler. The pick path is a one-line manual check.
8. **ELK on the main thread.** The spike measured 95 ms warm on 150
   blocks and listed a worker among what it did not test; the increment
   ports what was measured and leaves the worker as an open item for the
   map.
9. **A structureless failure shows a sentence.** Nothing can be drawn and
   the list is increment 7's; the shell's text outcome stays for it.
10. **`0`, `+`, `-` wait for increment 5.** Answer 11 of the workspace
    owns the keyboard table and increment 5 pins it key by key; the fit
    button and the wheel give the same gestures now.
11. **A background click clears the selection.** Answer 4 names Escape;
    a canvas where a click on empty space leaves a stale selection reads
    as stuck, and "the level when none" is the state the click returns
    to.
12. **Hover titles now.** Answer 10's "every element carries a hover
    title" costs one element per shape and is the only way to read a cut
    display name before increment 4's pane.

## For the user

1. Read the readings; strike any, and the fixer reverts it.
2. After the review, the look-and-adjust pass: `npm run dev` in the
   worktree's `frontend/` on the fixtures, and the screenshots under
   `frontend/e2e/screenshots/`.
3. The merge and the push.

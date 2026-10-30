# Notes: inspector increment 4, the readings and their reasons

The brief is `brief_inspector_04_frame.md`. The user asked on 2026-10-30
for the increment to be prepared and launched once increment 3 was done;
each reading below is the coordinating session's, with its reason, for
the user to ratify or strike. A struck one is reverted by a finding to
the fixer.

## Launch state

Increment 3 landed at `57eb335` of `RedstoneInspector.jl`, pushed with
CI green, and the core's bookkeeping at `3725478`, so the worktree
`~/.julia/dev/RedstoneInspector.jl-inc4` (`increment-4`) sits on that tip.
Increment 3's worktree still exists, equal to `master`, left for the user
to remove. The oracle `scratchpad/oracle/frame.py` extends increment 3's
with the tree's rows, the totals, the drawer's counts and the detail
pane's facts; its level numbers equal increment 3's table.

## Readings

1. **A selection carries its level.** Answer 9 keys a pin by level path,
   side and face name, and a wire by its level's path and consumer
   endpoint, because their ids repeat across levels; a bare `Target`
   would select every level's `⟨in⟩in` at once. The level is the cheap
   half of that key now, and increment 5's view state and the push use
   the rest.
2. **Opening clears the selection; selecting from the tree does not.**
   Answer 2 says a row click "makes the canvas show its parent's level,
   opening it if need be", so that selection must survive the level
   change. Answer 3 says nothing of the selection on an open; the
   double-click that opens `sensing` has selected `sensing` on its first
   click, an element the new level does not draw, and the pane would go
   on showing the block just left. Clearing makes the pane show the
   level, which is the same assembly.
3. **The chevron expands; the double-click opens.** Answer 2 separates
   "an assembly row expands" and "expansion state is kept by path" from
   opening, and names the double-click as "the same gesture as on its
   block". If the chevron also opened, there would be no way to read a
   subtree without changing the level, and the sentence "selecting a
   closed assembly to read its detail must not force opening it" would
   lose its point for the outline.
4. **The docstring as Markdown source until increment 8.** The roadmap
   places the bundled renderer and the `@ref` rule in increment 8 with
   the help page; the pane's layout lands whole now and the renderer
   swaps one block.
5. **The status bar counts the model.** Answer 1 says "the block and wire
   counts" without a scope; the pane with nothing selected already shows
   the open level's counts, so the bar's are the totals, which answer
   the question a status bar answers, how big the model is.
6. **The kind word is the descriptor's.** `build`, `deployment`,
   `failure` are the envelope's words and the loader's; a prettier
   phrase is a vocabulary the help page would have to teach.
7. **A location click copies the label.** Answer 4 gives the hosted
   copy's behaviour as copying the path; the live session's
   open-in-editor needs the socket client, which lands after this
   increment. The file strings in the fixtures are labels under
   `<depot>/` and `<repo>/`, which is what gets copied.
8. **Placeholder tab bodies.** Answer 6's drawer rule, open on load only
   with a diagnostic, and its counts belong to the strip, which the
   roadmap puts here; the rows are increments 7 and 8. A body that says
   what it will hold reads as unfinished rather than broken.
9. **The side panes run the full height.** Answer 1 places the drawer
   "at the bottom" and the status bar "below" the canvas; a drawer that
   spans under the tree would push the tree's scroll region around as it
   opens. Stage 4's dock replaces the grid anyway.
10. **A folder row's path is `parent/field`.** A keyed child's segment is
    `field/key`, so no node sits at `parent/field`; the id is unique,
    reads as what it is, and sorts into walk order without a second
    namespace.
11. **The help link waits for increment 8.** A link to `#help` before the
    page exists reads as broken; answer 10's landing panel and answer
    11's status-bar link land with the page.
12. **Alt-Up now.** Answer 3 names Backspace and Alt-Up together for the
    parent; Backspace landed in increment 3, and the second key is one
    line. The rest of the table is increment 5's.
13. **Nothing in the pane is truncated.** Answer 10 of the grammar cuts
    the display name on the canvas only; the pane is where the full text
    is read, so it scrolls.
14. **A structureless failure shows the frame.** The drawer must open on
    the diagnostics tab with its count, which needs the frame; the
    canvas area holds the sentence increment 3 printed.
15. **Prefs as one versioned key.** One object under
    `redstone-inspector/prefs` with `version: 1`, defaults on anything
    unreadable, so a later shape never breaks an old browser's entry.

## For the user

1. Read the readings; strike any, and the fixer reverts it.
2. After the review, the look-and-adjust pass: `npm run dev` in the
   worktree's `frontend/` on the fixtures, and the screenshots under
   `frontend/e2e/screenshots/`.
3. The merge and the push.

## Build outcome, 2026-10-30

Built as four commits on `increment-4` at `53bad81` in
`~/.julia/dev/RedstoneInspector.jl-inc4`, not pushed: `b552de3` the
frame, `5a83567` the pane and the drawer, `f10a114` the checks,
`53bad81` the map and the README. `npm run check` 337 files, 0 errors;
`npm test` 220 tests in 11 files; `npm run e2e` 81 checks in about 14 s.

One pin disagreed: the brief's tree check said collapsing `sensing`
leaves 8 rows, the brief's own arithmetic error, since the double-click
that opens `actuators` expands its row and the count is 11. Ruled: the
check as built asserts that the collapse removes `sensing`'s two rows.
The cold review is running.

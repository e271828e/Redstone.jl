# Notes: inspector increment 7, the readings and their reasons

The coordinating session's record for `brief_inspector_07_overlays.md`:
the state at launch, each reading the brief takes where the records stop
short and why, what the user is asked to look at, and the build's outcome
as it unfolds. The user delegated the increment overnight on 2026-11-03,
so every ruling below is the session's, recorded with its reason, and
nothing is pushed.

## Launch state

Increment 6 landed at `2824f1f` of `RedstoneInspector.jl`, merged and
pushed with CI run 41549947096 green on Chromium and the Firefox project
failing two `leave.spec.ts` checks (Playwright's Firefox delivers no
`beforeunload` dialog on `goBack`), recorded by the session that closed it
and left open until Firefox turns blocking. The core's bookkeeping stands
at `b351b29`. The worktree `~/.julia/dev/RedstoneInspector.jl-inc7`
(`increment-7`) sits on `2824f1f` with `npm ci` run and the root
`Manifest.toml` copied in. The oracle `scratchpad/oracle/overlay.py` sits
beside copies of the earlier increments' scripts; it takes the fixtures
directory as its argument, and its output over the tree as launched is
`overlay.before0.out`. It was checked against the resolution module's
existing pins (`closed_loop`'s `h_ref` with 2 consumers, `mode` with 7,
`rates`' `src/out` across four levels) before the brief took numbers from
it.

Three builders, as increment 6 ran them: a Julia one for the fixtures,
since the overlay needs a loop across a level, a dead hop, a probe throw
and a warning to be looked at, none of which the twelve fixtures carry;
then the two frontend halves, the overlay with the drawer and the tree,
then the routes with the trace action and the map; the halves share
`Canvas.svelte`, `session.svelte.ts` and `App.svelte` and so run one after
the other.

## Readings

1. **The feedthrough edges are not drawn.** The roadmap's increment 7 line
   ends "the feedthrough edges drawn". `workspace.md`'s pending list holds
   "A feedthrough emphasis", the mark on every wire from a stage-2 port
   into a block with a stage 2, "until it can be labelled so", because it
   is the build's presumed structure and overstates dependences inside a
   block. The record is the ruling and the roadmap "restates none" of
   them, so the record wins; the roadmap's line was written before the
   pending bullet's reason was weighed against the overlay's hues. The
   natural home is increment 8's execution-order tab, a row per edge
   labelled as presumed, beside the stage ports it already lists. For the
   user: strike this and the edges join as a wire mark in a fourth hue,
   which the palette would then have to avoid.
2. **Four fixtures join.** Each mechanism of answer 8 needs a fixture that
   exhibits it (`brief_lessons.md`): the chain across a level and the
   continuation badge need a loop one level down; the chord needs a dead
   hop; the function badge needs a probe throw; amber needs a warning.
   The core's `test_descriptor.jl` builds all four, so they are ported, not
   invented. `failure_probe`'s model carries a warning in the carrier too,
   which shows errors and warnings in one drawer.
3. **A cycle draws as the cycle case alone.** Answer 8's first sentence
   gives a node diagnostic a halo and a badge; its cycle sentence gives
   the members halos, the chain, the chords and the continuation badges,
   and says "the verdict is text". A kind badge on `plant` beside the
   member halos would say nothing the drawer's row does not, and the loop
   has two members, not one attributed node. The attribution path stays
   the row's.
4. **The diagnostic badge straddles the bottom edge at the right.** The
   rate pill took the top-right (increment 6's reading 8 kept the top-left
   for increment 8's order badge); the bottom-right is free, and a badge
   that straddles the edge covers no face name, as increment 6's builder
   found for the segment. The route badge sits beside it on a child, and
   on a pin at the outer end of its top edge; answer 3 reserves a root
   tag's slot for stage 2's claim badge, so no badge of stage 1 takes it.
5. **The badge opens the drawer.** Answer 8 says "the badge opens the
   text"; the text's home is the drawer's row (workspace 6), so a click
   opens the drawer on diagnostics with that row focused and scrolled into
   view, rather than a second popover carrying the same message. The
   badge's title carries the message's first line for the hover.
6. **A diagnostic's focus is its drawer row.** Answer 9 lists "focus on a
   diagnostic" among what dims; nothing says how one is focused. The row's
   click already selects and navigates (workspace 6); making it also the
   focus gives the dim one trigger and one clearing (a second click,
   Escape, a push), as the legend line has.
7. **One dimming focus at a time.** Two dims by opacity on one element
   would stack to 0.09 and read as a third state. The route is the most
   deliberate (answer 8: "started on purpose"), then the focused row, then
   the legend line; the shell passes one `lit` set and one focus class.
   A search's dim composes as it does today with the legend's.
8. **The tree's marks count diagnostics.** Workspace 2 says "counts on
   hover"; a count of rows would read 2 on the root for one loop with two
   members at the root. The count a reader wants is how many things are
   wrong beneath.
9. **A diagnostic at the root path marks nothing.** The root has no block
   on any level; its pins are faces, not the node. The row carries it.
10. **A wire mark is found at its level.** `marks.wires` spells declared
    endpoints (failure_descriptor 2), so the wire lives in exactly one
    assembly's list; an endpoint on the level's own path is a pin.
11. **The origin is the face traced from.** Answer 9 names "the origin's
    halo" beside "the terminal port marked", so the origin is not the
    producer; answer 8 makes the route the value's whole path whichever
    face starts it. A wire's origin is its producer face, as `wireRoute`
    already reads.
12. **The status line's spelling.** Answer 8's example "tracing
    `aircraft/δe`" is `path/port`; a root face has no path, so its name
    alone; the singular for one as every count in the page reads.
13. **The menu is one entry.** Answer 8 names a "trace" entry on the
    right-click menu of a pin, a port square or a wire and nothing else
    on it; a menu with one entry is still the menu the record names, and
    the browser's own menu stays elsewhere for the user's sake.
14. **The wire's pane gets the trace button.** Answer 4 names the button
    on a pin or port's pane; answer 8 gives the wire the right-click entry
    and `t`. A wire pane without the button would be the one place the
    action is reachable by the mouse only through the menu.
15. **A route badge's parent click climbs.** Answer 8: "a click on it
    going to the parent with the route lit"; `climb` is the one way up and
    selects the child left as every climb does since increment 6.
16. **The drawer row's location.** Answer 8: "the drawer lists every
    diagnostic with the type's source location". A diagnostic carries no
    location of its own; the attributed node's type row does, so the row
    shows its first one with the pane's click behavior.

## For the user

1. Read the readings; strike any, and the fixer reverts it. Reading 1
   changes what the roadmap promised and deserves the first look; once
   ratified it is a one-line docs amendment on `workspace.md`'s pending
   bullet.
2. After the review, the look-and-adjust pass: `npm run dev` in the
   worktree's `frontend/` on `failure_nested`, `failure_dead`,
   `failure_probe`, `warning` and `closed_loop` with `h_ref`, `mode` and a
   wire traced; the hues, the badge's corner and shape, the chord and the
   dim's strength are this pass's.
3. The merge and the push; the Firefox project's `leave.spec.ts` item
   stands from increment 6.

## Build outcome, 2026-11-03

Agent 0 built stage 0 on `increment-7` in
`~/.julia/dev/RedstoneInspector.jl-inc7`, not pushed: `0714626`, the four
models with `Piecewise`, `SelectedNothing` and `Thrower` beside the
existing helpers, `input_passthrough` imported by name since the pinned
core does not export it, the four fixtures, the tests' rows, the README's
paragraph. Every model built as the brief expected: `failure_nested` a
real loop with members `plant` and `ctl/pi`, `plant` traced global and
`ctl/pi` structural, its chain two wires at the root (`ctl|in|y`,
`plant|in|u`) and two inside `ctl` (`ctl/pi|in|y`, `⟨out⟩u|in|u`);
`failure_dead` artificial with the dead hop `(m, g, F)`, its chain
`g2|in|e` and `m|in|g`; `failure_probe` fail-fast with the structure,
`UserCodeFraming` at `t` with `y_state` and the warning at `s/g`;
`warning` a build with its one warning at `g`. No existing fixture
changed. `npm run check` 377 files, 0 errors; `npm test` 425 tests in 25
files; `npm run e2e -- --project=chromium` 154 checks; a second
regeneration left the tree clean. The oracles' outputs over the
regenerated directory are `scratchpad/oracle/*.after0.out`.

Rulings made during the build, each the coordinating session's:

- **`failure_nested`'s root draws five wires**, not the brief's four: the
  root inputs' two, the loop's two and the root output's one. The brief's
  error; the draw row reads 5.
- **`ctl` carries its own red mark** in the tree, as a level the chain
  touches, beside the continuation badge; the brief's table lists only
  `plant` among the root's marked blocks, which is the canvas's halo, not
  the tree's mark. Both hold.
- **The map's fixture counts** (twelve, eleven) and its `draw.spec.ts`
  bullet are stale until stage 6, which agent B's prompt names.

Agent A, the overlay, the drawer and the tree, follows from `0714626`.

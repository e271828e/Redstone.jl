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

Agent A built stages 2 and 3 from `0714626`: `db6b205` `diagnostics.ts`
with its tests, `Lit.ports`, the session's `diagnosticFocus` with its
Escape step, the canvas's `g.overlay` and the three focus classes under
one dim rule, the shell's precedence and `onbadge`, `overlay.spec.ts`;
`c42a412` the drawer's diagnostics tab, the tree's `span.mark`, the
shell's `ondiagnostic`, `drawer.spec.ts`. `npm run check` 381 files, 0
errors; `npm test` 453 tests in 26 files; `npm run e2e --
--project=chromium` 169 checks; no existing check amended. The oracle
agreed on every fixture. Its departures, accepted and recorded in its
notes for the map:

- **`treeMarks` returns `own` beside the counts**, which the ", beneath"
  title needs.
- **`litBy` lights the level's own pins** a chain runs to or from, so
  `failure_nested`'s `ctl` level keeps its `⟨in⟩y` and `⟨out⟩u` pins lit
  with their wires; the route's `routeLit` does the same.
- **A `focusKey` prop** carries `data-focus`'s value, the diagnostic's
  index or the legend's key; `legendFocus` stays for the line's
  `aria-pressed`.
- **A chain hop carries its faces** beside `{level, wire}`, which the
  continuation badge, the pins and the tree's levels read.
- **The filter shows only when rows exist.**
- **A port mark's side** is the face the node declares as an input, else
  as an output, the format carrying none.
- **Three `overlay.spec.ts` assertions landed with stage 3**, needing the
  drawer's and the tree's DOM.

Its headed look, for the look pass: the loop reads as a red ring through
`plant` and `ctl`'s `loop` pill; a selected block under the red halo turns
purple and under the amber one olive, the halos composing at 0.5 opacity
(an opaque mark halo, or one just outside the selection's, is the pass's
call); a selected block's incident casings stay full under a focus; the
cross at ±3 px is small at the fit; `s/g`'s `EmptyFaceSelection` pill
runs 190 px on a 130 px block and white on amber is the lowest-contrast
text on the page; a loop row's location is `plant`'s type's `u_types`
line, reading 16 as written. Agent B, routes, the trace action and the
map, follows from `c42a412`.

Agent B built stages 4 to 6 from `c42a412`: `21df84d` `routes.ts` with
its tests, the session's route and `escape`'s first step, the canvas's
route drawing and right-click menu, the pane's and the status bar's
buttons, `t`, `routes.spec.ts`, the amended `keys.spec.ts` check;
`f60ab61` the tree's route marks, the route across a push through
`rekeyRoute`, the session tests; `a7f1986` the map and the README. `npm
run check` 384 files, 0 errors; `npm test` 469 tests in 27 files; `npm run
e2e -- --project=chromium` 174 checks. Its departures, accepted and
recorded in its notes for the map:

- **`routeOf` returns the route with its origin face**, since the drawing
  needs the origin's port; `routeStatus` keeps its two arguments.
- **Terminal ports are marked only on levels the route crosses**, as the
  oracle lists them; `primitive`'s `u` has its tag as the origin and no
  terminal.
- **Pin badges draw only below the root**, a root face having no parent
  to climb to; a root tag's slot never holds a badge.
- **A pin badge's click is `onopen(parent)`**, which is `climb` by
  definition, selecting the child left.
- **A face with no producer is not traced**: the shell ignores it and the
  pane shows no trace button, so no route is set that cannot draw; no
  fixture has one.
- **`span.route` holds its clear button.**
- **The tree's route marks are exactly `routeLevels`**, the root included,
  with no propagation: answer 2's blue dot is "a level a route passes",
  and an ancestor the route does not cross is not one.
- **The menu's Escape** is taken in the capture phase and never reaches
  the shell's chain, so the route stands; a press outside, the wheel or a
  level change closes it.

Its headed look, for the look pass: every status line as the oracle gives
it (`h_ref` 2 across 3, `mode` 7 across 4, `src/out` 3 across 4); the
casings sharing a trunk add their opacity, so `mode`'s four-wire trunk
reads as a dark band and its branches stay pale; the terminal ports' 6 px
stroke barely shows, the casings' ends doing the work; the `route` pill
covers most of a short pin's top edge and sits far from the entry port on
a tall assembly; the menu and the pressed pane button read right. The map
lists these with agent A's, and the edge cases: a route on a level it
does not cross dims that level whole; a kept origin that no longer
resolves leaves the route standing undrawn; the menu has no keyboard
path; the status bar clips on overflow. The cold review follows at
`a7f1986`.

## The cold review, 2026-11-03

One Opus reviewer over `2824f1f..a7f1986`, every check green from a
clean install (`npm run check` 384 files, `npm test` 469 tests in 27
files, `npm run e2e -- --project=chromium` 174 checks, the regeneration
clean), the oracle rerun byte-identical, its own third reading of the
chains, the routes and the tree's counts (written from the records, not
the oracle) agreeing on every fixture, answer 8 clause by clause, answer
9's composition order, workspace 6 and 8 sentence by sentence all holding
by probe. Four findings, all low, each ruled by the coordinating session:

1. **A diagnostic attributed to the root leaves the root row unmarked**:
   `treeMarks` skips `""`, and the oracle shared the slip. Reading 9
   confines "marks nothing" to the canvas; answer 2's "a row whose
   subtree holds a diagnostic" includes the root's own. Accepted: the row
   marked, the unit pin amended, a browser pin on a synthetic root
   diagnostic, the oracle corrected by the session (its outputs over the
   committed fixtures unchanged; `oracle/synthetic/failure_probe_root.json`
   is the synthetic case).
2. **The overlay dimmed as a group survives the checks**, which read an
   element's own opacity and not its ancestors'. Accepted as a missing
   check: the effective opacity pinned under each focus for a mark halo,
   a badge and a route badge.
3. **The drawer's rows are not real buttons**, against answer 11's "every
   control is a real button or link". Accepted: each row's content in a
   `button`, the `li` keeping the contract, the location link beside it;
   the drawer's rows and filter having no keyboard path from Tab's cycle
   is an open item.
4. **The README overstates a pill's click**, which focuses the row and
   selects nothing. Accepted: the sentence amended.

Of the sixteen mutants fifteen die and one survives, finding 2. Two are
red in the unit tests alone and accepted as such: the status's singular
(no browser status is singular) and the route's Escape step after the
legend's (no check holds both). Observations for the look pass, new
beside the map's: `failure_dead`'s chord crosses `m`'s face labels and
its cross sits on the label column; a discrete leaf's orange dot beside
an amber mark reads as two similar hues; a focused diagnostic attributed
to the root or an unknown path lights nothing, so the whole level dims.
The fixer follows at `a7f1986`.

## The fix, 2026-11-03

The fixer landed the four findings as `8f686ce`: `treeMarks` marking the
root's own row, the unit pin amended and a browser pin on the synthetic
root diagnostic (`s` reading "1 warning, beneath" beside it, beyond the
brief and as the oracle reads); `effectiveOpacity` in `e2e/fixtures.ts`,
the product of the computed opacities up to the svg, pinning `t`'s mark
halo at 0.5 and its badge at 1 under the diagnostic focus and
`pid_controller`'s route badge at 1 under the route focus, the surviving
mutant confirmed red (0.15 and 0.3 read); each drawer row's content in a
`button.row`, the `li` keeping the contract and `a.location` beside it;
the README's sentence; the map amended, the open items gaining the
drawer's missing keyboard path. `npm run check` 384 files, 0 errors; `npm
test` 469 tests in 27 files; `npm run e2e -- --project=chromium` 175
checks. Two notes from the fixer, for the user: `pre.message` inside the
button is technically invalid HTML (a button allows inline content), which
browsers render and Svelte does not flag, a `span` with `pre-wrap` being
the valid form at the cost of the contract; and two clickable rows older
than this increment are not buttons either, the tree's rows (which have
`j` and `k`) and the pane's face rows. The reviewer verifies the delta
next.

The reviewer, resumed, verified every fix at `8f686ce` and ran the gate
again, green at the same tallies; its mutant turned both checks red. Its
note that the oracle still skips the root read the canvas-side condition:
the tree mark is added for any node the tree holds, the root included,
and the synthetic root case reads the root's own mark. Its one look item
from the delta: the message column in the drawer runs narrower beside the
location link.

## The look pass, 2026-11-03

The user ratified the sixteen readings, reading 1 included, and ran the
look-and-adjust pass by the checklist in `look_inspector_07.md`, which
records every ruling beside its entry. The changes landed on `increment-7`
one at a time, each with its check and a mutant that turns it red:

- `3d970fc`: the drawer row's message a block `span` with `pre-wrap`, since
  a button allows only inline content.
- `0e044fd`: a loop's row carries no location, its feedthrough being in
  its members' `y_direct`, which the format does not locate; the core's
  `pending.md` holds the format's half.
- `3d35c4b`: the shared dim at 0.35, for the search and every focus,
  chosen by the user over 0.3 and 0.4.
- `8baacdd`: a route's casings faded as one group, so a shared trunk reads
  at the branches' opacity.
- `624fb6d`: the tree's route marks propagate to every ancestor of a
  crossed level, titled "on the route, beneath", as workspace answer 2
  already asked; agent B's reading had confined them to the crossed levels.
- `63bc8b4`: the map's open items for the tree and face rows that are not
  buttons, and for the location link's later move under the message.

Tried and reverted: the mark halo as a ring outside the selection halo,
so a selected member would keep its hue. The two rings read worse than
the composed halo. Left as built by ruling: the discrete dot beside an
amber mark, the selected block's casings under a focus, a focused root
diagnostic dimming its level, and the terminal port's stroke. The gate at
`63bc8b4`: `npm run check` 384 files, 0 errors; `npm test` 470 tests;
`npm run e2e -- --project=chromium` 176 checks.

## Landed, 2026-11-03

`master` fast-forwarded to `63bc8b4`, no rebase being needed, and pushed.
CI run 41724649421 green on all four jobs, the frontend job in 5 min 21 s.
The non-blocking Firefox project passed 171 checks, skipped 3 and failed
increment 6's two `leave.spec.ts` checks, nothing new. The roadmap carries
the landed lines of increments 6 and 7, and increment 8's entry gains the
feedthrough edges as rows labelled presumed. The worktree
`~/.julia/dev/RedstoneInspector.jl-inc7` and its branch stand until the
user has them removed.

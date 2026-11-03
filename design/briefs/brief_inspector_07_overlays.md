# Brief: inspector increment 7, overlays and routes

The seventh increment of `design/briefs/roadmap_inspector.md` and the sixth
on the frontend track: a failed build explained on the diagram. The
diagnostics overlay in the error hue, warnings in amber, a loop's chain
mapped onto the declared wires across levels with its dead hops as chords,
the drawer's diagnostics tab with its filter and row clicks, the tree's
propagated marks, and face routes started on purpose by the trace button,
the right-click menu or `t`, lit across levels with the status bar naming
the route; beside them four fixture additions so every mechanism has
something to show. Written on 2026-11-03 against `RedstoneInspector.jl` at
`2824f1f`, increment 6 landed, the core at `b351b29`, and the records under
`design/inspector/`, none normative. Built by three Opus agents in one
worktree, one after the other, one cold review, a fixer if the review
needs one, then the user's look-and-adjust pass.

Design and code are peers, neither subservient. If a shape below proves
wrong at the keyboard, stop and report rather than deviate silently.

The frontend's review model is `initial_design.md`'s answer 11: no reader
judges the code line by line; the type checker, the unit tests, the
browser checks on the fixtures and looking stand in. This brief names the
checks; the counts come from the oracle `scratchpad/oracle/overlay.py`
over the committed fixtures, independent of the modules, beside the
earlier increments' scripts in the same directory; the geometric pins are
recomputed inside the checks from the DOM, by the rules this brief states.
The hues' values, the badge's shape and the chord's dash are the look
pass's to tune; the checks pin mechanisms, never a color value.

## Launch facts, 2026-11-03

- **The worktree** is `~/.julia/dev/RedstoneInspector.jl-inc7`, branch
  `increment-7` off `2824f1f`, `npm ci` run, Playwright's Chromium present,
  the root `Manifest.toml` copied in. The agents never touch the main
  checkout. Merge after review: rebase onto `master`, fast-forward, by the
  coordinating session.
- **Versions** as the repo pins them: Svelte 5.57.2, Vite 8.3.5, ELK
  0.12.0, TypeScript 6.0.3, svelte-check 4.7.7, Vitest 5.0.5,
  `@playwright/test` 1.64.1. No new dependency.
- **The pin** stands at the core's `035aa95`; `src/descriptor.json`,
  `src/descriptor.jl` and `src/diagnostics.jl` are unchanged since, so no
  re-pin. The generated `Diagnostic` type carries `function?`, `marks?`
  and `cycle?`; `Cycle` carries `members`, `wires` as terminal pairs,
  `classification?`, `dead` and `traced`.
- **The fixtures**: twelve files. Two are failures: `failure_cycle`, a real
  loop between two leaves at the root, `plant` and `ctl`, policy
  `collected`, with its structure; `failure_structure`, an `UnknownPort`
  and an `UnconnectedInput` at the structure step, no structure, the
  unfed input marked as a port. None carries a warning, none a loop across
  levels, a dead hop, a probe throw or a wire mark. This increment adds
  four (stage 0), so sixteen after it. A wire mark exists only on a
  structureless failure (`WireTypeMismatch` and `WalkingFaceAtFrozenEntry`
  are raised before the structure step; the core's `test_descriptor.jl:234`
  pins `!haskey(value.failure, :structure)`), so the overlay's wire mark is
  pinned on a synthetic descriptor, below.
- **The map**, `frontend/MAP.md`, is the frontend's `implementation.md`.
  Its purity sentence holds: `src/lib/` pure, `src/canvas/`, `src/frame/`,
  `src/live/` and the stores DOM-bound.
- **Already in place from increment 2**: `resolve.ts` holds `route`,
  `wireRoute`, `terminalProducer` with its `chain`, `terminalConsumers`,
  `faceInfo` and the `feeder` and `fanout` maps; `feedthrough.ts` the
  edges; `level.ts` `producerFace`. `palette.ts` holds `error` and
  `warning`, reserved for this increment. `session.svelte.ts` opens the
  drawer on `diagnostics` when a diagnostic exists (`opensDrawer`), counts
  diagnostics and warnings (`diagnosticCount`), and its `escape` says the
  route's step waits for this increment; `App.svelte` swallows `t`, `o`
  and `?` (`RESERVED`). `Drawer.svelte`'s tab bodies are placeholders.
- **Increment 6's open items** stand and none is taken up here: the
  Firefox project's first CI run (41549947096) failed two `leave.spec.ts`
  checks because Playwright's Firefox delivers no `beforeunload` dialog on
  `goBack`, open until Firefox turns blocking; the zoom floors; the fit not
  covering the labels; the rest of the map's list.
- **Two cautions from increment 4**: CI's Linux fonts are wider than a
  Mac's, so a layout claim about a pane holds only when also pinned at the
  pane's narrowest width through the stored prefs; and `vite preview`
  reuses port 4319 outside CI, so two `npm run e2e` never run at once on
  this machine. Plain `npm run e2e` starts Firefox too, which cannot run
  inside this machine's command sandbox: local runs are
  `npm run e2e -- --project=chromium`.

## What is settled

The records' answers this increment builds, cited by record and number;
the agents read them by the line ranges in "Routing".

- `visual_grammar.md` answer 8: one error hue, drawn where the attribution
  points. A diagnostic naming a node puts a halo and a corner badge on
  the block; one naming a port marks the port square; one naming a
  consumer endpoint draws that wire heavier in the error hue on top; the
  badge opens the text; the drawer lists every diagnostic with the type's
  source location. A probe failure is the node case, the badge carrying
  the function name. An `AlgebraicCycle` halos its members; its wires are
  terminal pairs, mapped onto the chain of declared wires between the two
  leaves by answer 18's resolution in reverse, drawn on every level the
  chain touches, a badge on a closed child where the chain continues
  inside, a red dot on each such level in the tree; the verdict is text. A
  dead hop is a dashed chord across its member from the input square to
  the output square with a cross at its middle, under either verdict. No
  dimming by default; a dimmed state for the focus. Warnings take amber,
  same mechanics. A structure-step failure has no diagram, only the list.
- Answer 9: a face route is answer 18's chain drawn as the loop chain in
  the highlight hue: casings on the open level, the origin's halo, a badge
  on each closed child entered, the terminal port marked, a dot per level
  in the tree. Focus on a diagnostic, a route, a legend line or a search
  dims everything uninvolved by opacity. Composition bottom to top: dim,
  normal, route casing, selection halo, error overlay, so the error hue
  always wins.
- `workspace.md` answer 6: the diagnostics tab, one row per diagnostic
  with kind, attributed path and message, the error hue and amber, a text
  filter, the count on the tab, a click selecting the element and
  navigating to it, a loop opening its first member's level with the
  chain lit; the empty state says so. The drawer opens on load only when a
  diagnostic exists; every row selects on the canvas and navigates as a
  tree click does.
- Answer 8: a face's route runs upstream to its one terminal producer and
  downstream through every fan-out to every terminal consumer, crossing
  boundary faces, a tree with one root. It starts only by the detail
  pane's trace button, a "trace" entry on the right-click menu of a pin, a
  port square or a wire, or `t` with one selected, a wire's route being its
  producer face's; one route at a time. A pin the route leaves the level
  through gets the badge, a click on it going to the parent with the route
  lit; the status bar names the route, "tracing `aircraft/δe`: 3 consumers
  across 2 levels", with a clear control. It survives navigation and a push
  whose descriptor still has its origin, recomputed; it clears on Escape,
  on the trace action repeated or on another route; selecting something
  else leaves it standing. A route dims the level.
- Answer 2: dots propagate upward in the tree, a red dot on a row whose
  subtree holds a diagnostic, amber for a warning, blue for a level a
  route passes, counts on hover. Answer 3: a closed assembly opens also by
  the badge a loop chain or a route leaves on it, the chain still
  highlighted; a failure descriptor opens with the drawer on its
  diagnostics. Answer 4: a pin or port's pane carries a trace button.
  Answer 9: the standing route is per-tab state, keyed by its origin.
  Answer 10: a failure descriptor opens with the drawer on its diagnostics
  and the overlay lit. Answer 11: `t` traces the selected face or wire;
  Escape clears the route, then the legend's focus, then the search, then
  the selection.
- `failure_descriptor.md` answers 1 and 2: the failure body's `policy`,
  `structure` when held, `diagnostics` and `warnings`; a build body's
  `warnings`; a diagnostic's `kind`, `severity`, `path` (`""` for the root
  as for a wire endpoint), `message`, and the optional `function`, `marks`
  (`ports` as endpoints, `wires` as declared endpoint pairs) and `cycle`
  (`members`, `wires` as terminal pairs, `classification` when present,
  `dead` as `{path, input, output}`, `traced` as `{path, mode}`).
  `UnknownPort` marks its node alone.
- `initial_design.md` answer 18: wires verbatim, the client resolves.

## The shape

Every path is relative to `frontend/` unless it starts with `scripts/` or
`.github/`. One entry per file. Names are the agents' where this brief
gives none; the map records them. The DOM contract under "What the browser
checks pin" is fixed. Nothing names a color outside `src/canvas/palette.ts`.

### Stage 0, the fixtures

**`scripts/synthetic.jl`.** Four models join the failures section, each
ported from the core's suite at `b351b29` (the routing names the lines),
every helper type the model needs defined in the module beside `Plant`,
`PI`, `Gain` and `Sum`:

- `failure_nested()`: the loop of `failure_cycle` with the controller one
  level down, so the chain crosses a boundary: `plant` at the root and a
  `Group` `ctl` holding `pi = PI(3.0, 2.0)`, `ctl` forwarding `ref` and `y`
  in and `u` out, the root wiring `ctl/u → plant/u` and `plant/power →
  ctl/y`, the root inputs `ref` and `d`, the root output `y`, `pi` on an
  `Absolute(Hz(50))` anchor. Expected: one `AlgebraicCycle`, real, members
  `plant` and `ctl/pi`, the terminal pairs `plant/power → ctl/pi/y` and
  `ctl/pi/y → plant/u`; the chain two wires at the root and two inside
  `ctl`.
- `failure_dead()`: the core's artificial loop with a dead hop, `m =
  Piecewise()`, `g1` and `g2` gains, `m/F → g2/e`, `g2/out → m/g`, `g1/out
  → m/v`, the root inputs `r → g1/e` and `f → m/f`. Expected: artificial,
  `dead` one hop `(m, g, F)`, `traced` `m` global and `g2` global.
- `failure_probe()`: a `Group` of `s = SelectedNothing(Gain(2.0),
  Gain(3.0))` and `t = Thrower()` with `in → s/in`. Expected: policy
  `fail-fast`, the structure present, one `UserCodeFraming` at `t` with
  `function` `y_state` and `cause: boom` on the message's second line, and
  one `EmptyFaceSelection` warning at `s/g`.
- `warning()`: `SelectedNothing(Gain(2.0), Gain(3.0))` as the root.
  Expected: a build with one `EmptyFaceSelection` warning at `g` and no
  diagnostic.

A model that builds differently under the pinned core is reported in the
notes with what it gave, and the brief's expectations yield to the oracle
over the regenerated fixture.

**`scripts/fixtures.jl`.** `failure_nested`, `failure_dead` and
`failure_probe` join the failure loop; `warning` the build loop.
Regenerate with `julia --project=scripts scripts/fixtures.jl` from the repo
root; the fixtures job's rule holds: regeneration against the pin changes
nothing afterwards.

**The tests' per-fixture rows.** `fixtures.test.ts` takes the new counts;
`loader.test.ts`, `tree.test.ts`, `resolve.test.ts`, `feedthrough.test.ts`,
`level.test.ts`, `outline.test.ts` and `e2e/draw.spec.ts` carry per-fixture
rows, which gain the four, each from the earlier oracles (`resolve.py`,
`levels.py`, `frame.py`, `search.py`) and `overlay.py` rerun over the
regenerated directory; `search.spec.ts`, `search.test.ts`, `rates.test.ts`,
`icons.test.ts` and the grammar's checks keep their rows. `draw.spec.ts`
draws `failure_nested`'s root (2 in pins, `plant`, `ctl`, 1 out pin, 4
wires) and `ctl`, `failure_dead`'s root, `failure_probe`'s root and `s`,
`warning`'s root; `failure_structure` keeps its "no structure to draw".
`README.md`'s fixtures paragraph names the four and what each shows.

### Stages 1 to 3, the overlay, the drawer and the tree

**`src/lib/diagnostics.ts`.** Pure. `diagnosticsOf(model)`: the body's
`diagnostics` then its `warnings` as one list, each with its `index` in
that order, so the tab's count is its length and errors list first.
`chainOf(model, cycle)`: each terminal pair's chain of declared wires by
the resolution in reverse, from the pair's consumer face up through
`feeder` to its producer, each hop `{level, wire}` (the wire's id, its
consumer port id on that level: a child's `path|in|port`, the level's own
output face `⟨out⟩port|in|port`); a walk that does not end at the pair's
producer contributes nothing and is a reported fact, never a throw.
`overlayOf(model, level)`: what the level draws, every diagnostic and
warning together, the error hue winning where both land: `blocks`, by
block id, the severity and, for a node diagnostic, its badge, `{text,
title, index}`, the text the `function` when present else the `kind`, the
title the message's first line; `ports`, by port id, from `marks.ports`,
an endpoint on the level's own path marking the pin's port square; `wires`,
by wire id, from `marks.wires` (the declared wire with those endpoints,
found at the level whose wire list spells it) and from every chain hop on
the level; `chords`, each dead hop whose member is on the level, `{block,
from: the input square's port id, to: the output square's port id,
severity}`; `continues`, by block id, a closed child of the level whose
face a chain passes through (a hop whose consumer is the child's input
face, or whose producer is the child's output face), with the diagnostic's
index. A diagnostic whose `path` is `""` marks no block, the row alone.
`treeMarks(model)`: by path, `{errors, warnings}` counts of distinct
diagnostics: a diagnostic marks its attributed node, a cycle also each
member and each level its chain touches other than the root, and every
mark propagates to the row's ancestors, the root included; a row's dot is
red when its error count is positive, else amber. `diagnosticTarget(model,
d)`: where a row's click goes, a `Selection` or `undefined`: a port mark
its port square (a pin's port for an endpoint on the root's path), else a
wire mark its wire on its level, else a cycle its first member's block on
that member's parent's level, else a node diagnostic its block on its
parent's level, `undefined` for the root and for a structureless model.
`litBy(model, level, d)`: the `Lit` sets a focused diagnostic lights on a
level, its blocks (members, continuing children, the marked node), wires
and ports, so `Lit` gains `ports`. Unit tests from the oracle:
`failure_cycle`'s one row, members `plant` and `ctl`, the chain at the root
`ctl|in|y` and `plant|in|u`, no badge on either member, `treeMarks` `""`,
`plant` and `ctl` each 1 error and no warning; `failure_nested`'s chain on
two levels, the root's two wires and `ctl`'s two, `ctl` in `continues` at
the root, `treeMarks` on `""`, `plant`, `ctl` and `ctl/pi`; `failure_dead`'s
one chord on `m` from `m|in|g` to `m|out|F`, its chain, the classification
`artificial`; `failure_probe`'s two rows, error first, `t`'s badge `y_state`
titled with the message's first line, `s/g` marked amber at level `s`,
`treeMarks` `""` 1 and 1, `s` 0 and 1, `s/g` 0 and 1, `t` 1 and 0;
`warning`'s row, `g` amber at the root, the badge `EmptyFaceSelection`;
`failure_structure`'s two rows with no target and no tree marks; on an
inline copy of `failure_cycle` whose diagnostics are replaced by an
`UnconnectedInput` at `ctl` marking the port `ctl/ref` and the wire `"" /
ref → ctl/ref`, and an `EmptyFaceSelection` warning at `plant`: the port
`ctl|in|ref`, the wire `ctl|in|ref`, `plant` amber, `ctl` red, the target
of the first row the port; `diagnosticTarget` on every fixture row;
`litBy` on `failure_nested` at both levels; a diagnostic at `""` marking
nothing.

**`src/state/session.svelte.ts`.** `diagnosticFocus`, the focused
diagnostic's index or `undefined`; `toggleDiagnosticFocus(index)`, a
second click on the focused row clearing it; `clearDiagnosticFocus`. A
push clears it (a diagnostic has no key); a first load clears it.
`escape`'s chain grows a first step, agent B's route first, then the
diagnostic focus, then the legend's focus, then the query, then the
selection; agent A lands the diagnostic step in that position and agent
B adds the route step before it. Unit tests: the focus set, toggled and
cleared, cleared by a push and by `escape` ahead of the legend's focus.

**`src/canvas/Canvas.svelte`.** Props `overlay` (`overlayOf`'s result for
the drawn level), `focus` (`"route" | "diagnostic" | "legend" |
undefined`, which standing focus the `lit` sets belong to; the shell
passes one at a time, below), `onbadge(index)` and the existing `onopen`.
Draws `g.overlay` last in the svg, above the type labels, so the error
hue composes on top of every halo and casing: for each marked wire
`path.mark-wire[data-wire][data-severity]`, the wire's own `d` at 3 px in
the hue, no pointer events; for each marked port
`rect.mark-port[data-port][data-severity]`, the square's outline grown by
2 px in the hue; for each marked block `rect.mark-halo[data-id]
[data-severity]`, the block's halo geometry (3 px outside the shape, `rx`
7) at 5 px in the hue at the halo's opacity, a `path` with `tagD` for a
root tag; for each chord `path.chord[data-id][data-from][data-to]` from
the input square's center to the output square's center, dashed, in the
hue, with `path.cross` at its midpoint, two 4 px strokes; for each badge
`g.badge[data-id][data-role="diagnostic" | "continues"][data-severity]`,
a pill straddling the block's bottom edge at the right (the rate pill's
shape at the opposite corner, `BADGE_INSET` and `BADGE_HEIGHT` shared),
filled with the hue, its `text.badge-text` in the background color at
`BADGE_FONT`, reading the `function` or the `kind` for a node diagnostic,
`loop` for a continuation, its `<title>` the message's first line or
"The loop continues inside; open it to follow the chain."; a click on a
`diagnostic` badge calls `onbadge(index)` and on a `continues` badge
`onopen(block)`. The focus: `svg.canvas` carries `legend-focus`,
`diagnostic-focus` or `route-focus` by the `focus` prop with `data-focus`
as now, `lit` on the lit blocks, wires, cores, dots, labels and now
`rect.port`s, and one dim rule covers the three classes; the overlay's own
elements never dim. A diagnostic naming the level's own node (`path`
equal to the level) draws nothing on the canvas.

**`src/frame/Drawer.svelte`.** The diagnostics tab's body: a text filter
`input.filter` (placeholder "Filter by kind, path or message", a
case-insensitive substring over the three), `ul.diagnostics` of
`li.diagnostic[data-index][data-severity]`, in `diagnosticsOf`'s order,
each holding `span.kind`, `span.path` (`/` for the root), `pre.message`
the whole message, and, when the attributed node's type row has a
location, `a.location` reading `file:line` for the first one, a click
calling `onlocation` as the pane's does (the shell's handler, the copy
fallback with its `copied` mark); `current` on the focused row; the empty
state `p.empty` reading "No diagnostics or warnings." and, while the
filter hides every row, "No row matches the filter.". A click on a row's
body calls `ondiagnostic(index)`; the shell toggles the focus and, when
`diagnosticTarget` gives a selection, selects it (which navigates to its
level). The other three tabs keep their placeholders. The tab's count
stays `diagnosticCount`. A structureless failure lists its rows with no
target: the click focuses the row alone.

**`src/frame/Tree.svelte`.** Prop `diagnosticMarks` (`treeMarks`) and,
from agent B, `routeMarks`. A node row with a mark shows `span.mark
[data-mark="error" | "warning"]` after the name, a filled dot in the hue,
its `title` the counts in words, "1 error", "2 warnings", "1 error, 1
warning", with ", beneath" when the row's own node carries none; a row on
a route shows `span.mark[data-mark="route"]` in the highlight hue, titled
"on the route".

**`src/App.svelte`.** Computes `overlay` for the open level, `treeMarks`
once per model, the focus precedence: `focus` is `route` while a route
stands (agent B), else `diagnostic` while `diagnosticFocus` stands, else
`legend` while a legend line is focused in rate mode, and `lit` the
matching set; the legend's `aria-pressed` stays its own. Passes `onbadge`
(opens the drawer on `diagnostics` and focuses the index) and
`ondiagnostic`. `keys`: none new in this half.

**`src/canvas/palette.ts`.** Keeps `error` and `warning`; gains nothing
unless the look needs a lighter fill for the badge's text, which stays the
background color.

### Stages 4 to 6, routes, the trace action and the map

**`src/lib/routes.ts`.** Pure, over `resolve.ts`'s `route`.
`originOf(model, selection)`: the face a selection traces, a pin's or a
port's own face, a wire's producer face (`producerFace`), `undefined` for
a block or a folder. `routeOf(model, origin)`: `route` from the origin,
`undefined` when the face resolves to no producer. `routeDrawing(model,
r, level)`: what a level draws, `{wires: Set<wire id>, entered: Set<block
id>, pins: Set<pin id>, terminals: Set<port id>, origin: port id |
undefined}`: the route's wires on the level by consumer port id; the
closed children a wire enters or leaves; the level's own pins a wire
starts or ends at, a root tag included; the terminal ports on the level,
the producer's and every consumer's, a root face's as its pin's port; the
origin's port square when its block or pin is on the level.
`routeStatus(origin, r)`: "tracing `<face>`: N consumers across K levels",
the face `path/port`, a root face its name alone, the singular for one.
`routeLevels(r)`: the levels it crosses, the tree's blue dots.
`routeLit(model, r, level)`: the `Lit` sets, the blocks and pins touched,
the wires, the terminal ports. `rekeyRoute(origin, next)`: the origin face
kept when the new model has a node at its path declaring that face on
that side, or a root face of that name; `undefined` otherwise. Unit tests
from the oracle: `closed_loop`'s `h_ref` route, 2 consumers across 3
levels, the root's wires into `pid_controller` and `lqr_controller`, both
entered, `⟨in⟩h_ref` a pin and the origin, `pid_controller`'s one wire into
`h_ctl|in|r` with its pin `⟨in⟩h_ref` and that terminal; `mode`, 7 across
4, the status text; `plant/V`, 3 across 3, the origin `plant|out|V`; a
wire's origin its producer face (`sensing|in|h` giving `plant/h`), a block
`undefined`; `rates`' `src/out`, 3 across 4, `fast` and `slow` entered at
the root, `fast/outer` entered at `fast`; the root output `outer`, 1
across 3, the pins crossed; `large`'s `b102/out1`, 6 consumers across 1
level; `primitive`'s `u`, 0 consumers, no wire, the status in the plural
of zero; `rekeyRoute` keeping `h_ref` and `plant/V` across the deployment,
dropping `h_ref` against `rates`.

**`src/state/session.svelte.ts`.** `route`, the standing origin face or
`undefined`; `trace(origin)`: sets it, or clears it when it is the standing
origin; `clearRoute`. A replacement passes it through `rekeyRoute`; a
first load clears it; `open`, `climb`, `select` and the history leave it.
`escape` clears it first. Unit tests: set, repeated, another, cleared by
Escape ahead of the diagnostic focus, kept across a level change and
across `closed_loop_deployment`, dropped by `rates` and by a fresh load.

**`src/canvas/Canvas.svelte`.** Prop `routeDrawn` (`routeDrawing`'s result)
and `ontrace(face)`. Draws, in `g.casings`, `path.casing.route[data-wire]`
under each route wire at the selected casing's width and opacity; `g.block
.route-origin` or `rect.port.route-origin` with the halo on (`.halo` at
the selection's opacity, `.port-halo.on`); `rect.port.route-terminal`, the
stroke in the highlight hue as `marked`; `g.badge[data-role="route"]
[data-id]` on each entered child and on each pin crossed, reading `route`,
in the highlight hue, on a child straddling its bottom edge at the right
beside any diagnostic badge (the diagnostic's rightmost), on a pin
straddling its top edge at its outer end, never in a root tag's slot,
titled "The route continues inside; open it to follow it." or "The route
leaves this level here; go to the parent to follow it.", a click opening
the child or calling `onopen` of the parent, which the shell maps to
`climb`. The right-click menu: `contextmenu` on a pin, a port square or a
wire's hit path opens `div.menu` in `.viewport` at the pointer, holding
one `button.trace` reading "Trace"; a click on it calls `ontrace` with
the target's origin face; Escape, a click anywhere else, a level change
or a wheel closes it; the browser's menu is prevented on those targets
alone. The focus `route` dims as the others do.

**`src/frame/Detail.svelte`.** `button.trace` reading "Trace" in the
header's button row of the pin, the port and the wire layouts, titled
"Trace this value's route" and, while its face's route stands, "Clear the
route" with `aria-pressed`; calls `ontrace(face)`.

**`src/frame/StatusBar.svelte`.** Prop `route`, the status text; shows
`span.route` holding `code` with the origin and the counts, and
`button.clear-route` reading "clear", calling `onclear`.

**`src/App.svelte`.** `t`: `originOf` the selection and `trace` it,
nothing with none; `o` and `?` stay swallowed. The route's `Lit` and
`focus` precedence above; `routeDrawn` per open level; the tree's
`routeMarks`; the status bar's text and clear; `ontrace` from the pane and
the canvas; a route badge's parent click `climb`.

**`src/lib/rekey.ts`.** Unchanged; the route rekeys in the session through
`rekeyRoute`, beside `rekeyFocus`.

**`MAP.md` and `README.md`.** Stage 6: the layout's rows for the new
modules and the props, the stores' section (`diagnosticFocus`, `route`),
the tests' and the checks' sections, the canvas's contract, the frame's
drawer and tree, the keyboard's `t` and Escape, the traps found, the open
items amended (the route's and the diagnostics' items retired, what this
increment leaves open added). The README's frontend section gains a
paragraph on the overlay and the routes.

## Readings taken where the records stop short

Each taken by the coordinating session and recorded with its reason in
`notes_inspector_07.md` beside this brief; one the user strikes is
reverted by a finding.

1. **The feedthrough edges are not drawn.** The roadmap's line for this
   increment names them; `workspace.md`'s pending list holds the
   feedthrough emphasis "until it can be labelled so". The record wins;
   the edges wait for increment 8's execution-order tab, where the stages
   already show.
2. **Four fixtures join**: a loop across a level, an artificial loop with
   a dead hop, a probe throw carrying a warning, a clean build with a
   warning; each ported from the core's suite.
3. **A cycle draws as the cycle case alone**: member halos, the chain,
   the chords and the continuation badges; no kind badge on the attributed
   member, the text being the drawer's.
4. **The diagnostic badge straddles the block's bottom edge at the
   right**, the rate pill's shape at the opposite corner; the route badge
   beside it on a child, at the outer end of a pin's top edge, never in a
   root tag's slot.
5. **The badge opens the drawer** on the diagnostics tab with the
   diagnostic's row focused and scrolled into view.
6. **A diagnostic's focus is its drawer row**: a click focuses it and
   dims the rest; a second click, Escape or a push clears it.
7. **One dimming focus at a time**: the route while one stands, else the
   focused diagnostic, else the legend line; a search's dim composes as
   before.
8. **The tree's marks count diagnostics**, not rows: a cycle with two
   members under the root counts once on the root.
9. **A diagnostic at the root path marks nothing** on the canvas; the row
   alone carries it.
10. **A wire mark is found at the level whose wire list spells its
    endpoints**; an endpoint on the level's own path marks the pin's
    square.
11. **The route's origin is the face traced from**, a wire's its producer
    face; its port square or pin takes the halo; the terminal producer's
    and every consumer's ports take the marked state.
12. **The status line spells a root face by its name alone**, another
    `path/port`; counts in the singular for one, and a route with no wire
    (a primitive root's face) reads "0 consumers across 0 levels".
13. **The right-click menu is one entry**, "Trace", on a pin, a port square
    or a wire; the browser's menu stays everywhere else.
14. **The wire's pane gets the trace button too**, beside the pin's and
    the port's, since its right-click menu has the entry.
15. **A route badge's parent click climbs** through `climb`, selecting the
    child left as any climb does.
16. **The location on a drawer row** is the attributed node's type's first
    location, the pane's click behavior.

## What the browser checks pin, by property

The counts come from the oracle; the geometric pins are recomputed in the
checks from the DOM by the rules in "The shape". The new fixtures' rows
are filled by stage 0 from the regenerated oracle (`overlay.after0.out`).

| fixture | level | rows | opens | marked blocks | marked ports | marked wires | chords | continues | tree marks |
|---|---|---:|---|---|---|---|---|---|---|
| `failure_cycle` | root | 1 | yes | `plant`, `ctl` error | none | `ctl\|in\|y`, `plant\|in\|u` | none | none | `""`, `plant`, `ctl` red, 1 each |
| `failure_nested` | root | 1 | yes | `plant` error | none | the two root hops | none | `ctl` | `""`, `plant`, `ctl`, `ctl/pi` red |
| `failure_nested` | `ctl` | 1 | yes | `ctl/pi` error | none | the two inner hops | none | none | as above |
| `failure_dead` | root | 1 | yes | `m`, `g2` error | none | the chain's wires | `m`: `m\|in\|g` to `m\|out\|F` | none | from the oracle |
| `failure_probe` | root | 2 | yes | `t` error, badge `y_state` | none | none | none | none | `""` 1 and 1, `t` 1, `s` 0 and 1 beneath |
| `failure_probe` | `s` | 2 | yes | `s/g` warning, badge `EmptyFaceSelection` | none | none | none | none | `s/g` 0 and 1 |
| `warning` | root | 1 | no | `g` warning | none | none | none | none | `""` and `g` amber |
| `failure_structure` | none | 2 | yes | no canvas | | | | | none |
| synthetic (below) | root | 2 | yes | `plant` warning, `ctl` error | `ctl\|in\|ref` | `ctl\|in\|ref` | none | none | `ctl` red, `plant` amber |

The synthetic descriptor is `failure_cycle`'s text with its `diagnostics`
replaced by an `UnconnectedInput` at `ctl` whose `marks` name the port
`{path: "ctl", port: "ref"}` and the wire `{from: {path: "", port:
"ref"}, to: {path: "ctl", port: "ref"}}`, and an `EmptyFaceSelection`
warning at `plant`, both with a one-line message; the check drops it as
text through `drop(page, "failure_cycle", text)`.

Routes, from the oracle: `closed_loop`'s `h_ref`, 2 consumers across 3
levels, at the root 2 casings, `pid_controller` and `lqr_controller`
badged, `⟨in⟩h_ref` the origin; at `pid_controller` 1 casing, the pin
`⟨in⟩h_ref` badged, `h_ctl|in|r` terminal; `mode`, 7 across 4; `plant/V`,
3 across 3, the origin `plant|out|V`; `rates`' `src/out`, 3 across 4,
`fast` and `slow` badged at the root.

**The DOM contract.** The canvas's and the frame's contracts are unchanged.
The additions:

- `g.overlay` last in `svg.canvas`, holding `path.mark-wire[data-wire]
  [data-severity="error" | "warning"]`, `rect.mark-port[data-port]
  [data-severity]`, `rect.mark-halo[data-id][data-severity]` (a `path` for
  a root tag), `path.chord[data-id][data-from][data-to]` with `path.cross`,
  and `g.badge[data-id][data-role="diagnostic" | "continues" | "route"]
  [data-severity]` holding `rect` and `text.badge-text`.
- `svg.canvas.diagnostic-focus[data-focus="<index>"]`,
  `svg.canvas.route-focus`, beside `legend-focus`; `lit` on `rect.port`
  too.
- `path.casing.route[data-wire]`; `route-origin` on a `g.block` or a
  `rect.port`; `rect.port.route-terminal`.
- `div.menu` in `.viewport` holding `button.trace`.
- `section.drawer .tab-body .diagnostics` holding `input.filter`,
  `ul.diagnostics > li.diagnostic[data-index][data-severity]` with
  `.kind`, `.path`, `pre.message`, `a.location`, `current` on the focused
  row; `p.empty`.
- `nav.tree .row span.mark[data-mark="error" | "warning" | "route"]` with
  a `title`.
- `aside.detail button.trace[aria-pressed]` on a pin, a port and a wire.
- `footer.status span.route` holding `code` and `button.clear-route`.

The check files, one per concern:

- **`overlay.spec.ts`** (grammar 8, 9; workspace 10, 3). `failure_cycle`
  dropped: the drawer open on `diagnostics`, two `rect.mark-halo` with
  `data-severity="error"` on `plant` and `ctl`, two `path.mark-wire` on
  the oracle's wires with each `d` equal to its wire's, 3 px wide in a
  computed stroke equal to the palette's error hue read through a badge
  or the halo (the check compares elements, never a literal), no
  `g.badge`, no chord, `g.overlay` the last child of the svg; `plant`
  clicked, its selection halo and its mark halo both present, the mark
  halo after the selection's in document order; no `dim` at load (the
  svg carries none of the three focus classes and `plant`'s shape at
  opacity 1). `failure_nested`: at the root `plant`'s halo, the two root
  wires marked, `ctl` with `g.badge[data-role="continues"]` reading `loop`,
  the badge clicked opening `ctl` (`readyLevel("ctl")`), there `ctl/pi`'s
  halo, its two wires marked, no badge; the tree's rows `plant`, `ctl` and,
  once expanded, `ctl/pi` with `span.mark[data-mark="error"]`, the root's
  titled with ", beneath". `failure_dead`: `path.chord[data-id="m"]` from
  the center of `m|in|g` to the center of `m|out|F` within 0.5 px, read
  from the squares' boxes, dashed (`stroke-dasharray` not `none`), its
  `path.cross` centered at the chord's midpoint within 0.5 px, `m` and
  `g2` haloed. `failure_probe`: `t`'s badge reading `y_state` with
  `data-role="diagnostic"` and `data-severity="error"`, its title the
  message's first line, the drawer open with count 2; `s` opened, `s/g`'s
  halo `warning` and its badge `EmptyFaceSelection`, the computed fills of
  the two badges unlike each other; the badge clicked at the root (`t`'s)
  with the drawer closed first by `d`: the drawer open on `diagnostics`,
  the row `data-index="0"` `current`, `diagnostic-focus` on the svg,
  `s`'s shape at opacity 0.3 and `t`'s at 1. `warning`: the drawer closed,
  count 1, `g`'s halo `warning`, no `error` anywhere. The synthetic
  descriptor: `rect.mark-port[data-port="ctl|in|ref"]`,
  `path.mark-wire[data-wire="ctl|in|ref"]`, `ctl`'s halo `error`, `plant`'s
  `warning`. `failure_structure`: no canvas, the drawer's two rows.
  Screenshots `overlay` of `failure_nested`'s root and `ctl`,
  `failure_dead`'s root, `failure_probe`'s `s`.
- **`drawer.spec.ts`** (workspace 6, 2). `failure_probe`: the tab body's
  two `li.diagnostic` in order, `error` then `warning`, the first's `.kind`
  `UserCodeFraming`, `.path` `t`, `pre.message` containing `cause: boom`,
  its `a.location` ending `:<line>`; the second's `.path` `s/g`; the filter
  typed `Empty` leaving one row, cleared, `zzz` leaving none and `p.empty`
  reading "No row matches the filter."; the first row clicked: `current`,
  `t` `selected` on the root, the pane `leaf` with `data-id="t"`,
  `diagnostic-focus`; the second row clicked: level `s` drawn, `s/g`
  selected, the first row no longer `current`; the row clicked again
  clearing `current` and the focus, the selection kept; Escape with a row
  focused and `h` in the search clearing the focus first, the query kept.
  `failure_nested`: the row clicked opening `plant`'s level (the root,
  already drawn) with `plant` selected; `ctl/pi` is not the first member.
  `failure_cycle`'s row clicked, `plant` selected. `failure_structure`: two
  rows, a click giving `current` and no canvas. `closed_loop`: the tab
  opened by its button, `p.empty` reading "No diagnostics or warnings.".
  `warning`: count 1, the tab opened, one `warning` row, `g`'s tree row
  with `span.mark[data-mark="warning"]` titled "1 warning", the root's
  titled "1 warning, beneath". Rekeying: `failure_probe` with its first
  row focused, `closed_loop` dropped over it: no `current`, no focus class,
  the drawer kept open on `diagnostics` with count 0. Screenshot `drawer`
  of `failure_probe`.
- **`routes.spec.ts`** (workspace 8, 11, 9, 3; grammar 9). `closed_loop`:
  the `⟨in⟩h_ref` tag clicked and `t` pressed: `route-focus` on the svg,
  the tag `route-origin` with its halo's computed opacity above 0, two
  `path.casing.route` on the oracle's two wires, `pid_controller` and
  `lqr_controller` each with `g.badge[data-role="route"]` reading `route`,
  `plant`'s shape at opacity 0.3 and `pid_controller`'s at 1, the status
  bar's `span.route` reading "tracing `h_ref`: 2 consumers across 3 levels"
  and its `button.clear-route`; the tree's rows `pid_controller` and
  `lqr_controller` with `span.mark[data-mark="route"]`, `sensing` without;
  `pid_controller`'s badge clicked: level `pid_controller` drawn with one
  casing on `h_ctl|in|r`, that port `route-terminal`, the pin `⟨in⟩h_ref`
  badged `route`, the status unchanged; the pin's badge clicked: the root
  drawn, `pid_controller` selected (the child left), the route still
  drawn with its two casings; `plant` clicked: the route kept, `plant`
  `selected`; `t` with `plant` selected: nothing changes; `t` with the
  tag selected again: the route cleared, no `route-focus`, no casing, no
  `span.route`; the tag's pane `button.trace` clicked: the route back
  with `aria-pressed="true"`; `button.clear-route` clicked: cleared; a
  right-click on the port square `plant|out|V`: `div.menu` with
  `button.trace`, clicked: the route from `plant/V`, 3 consumers across 3
  levels, the port `route-origin`, the menu gone; a right-click on the
  wire `sensing|in|h` and its menu's trace: "tracing `plant/h`", the
  previous route replaced; Escape clearing the route with `plant` still
  selected, Escape again the selection. `closed_loop_deployment` dropped
  over a standing `h_ref` route: the route kept, the status unchanged;
  `rates` dropped over it: no route. `rates`: `src|out|out` right-clicked
  and traced, 3 across 4, `fast` and `slow` badged, `fast` opened by its
  badge, `fast/outer` badged there and `inner|in|in` terminal. `primitive`:
  the `⟨in⟩u` tag traced, the status "tracing `u`: 0 consumers across 0
  levels", the tag `route-origin`, no casing. `keys.spec.ts`'s `t` check
  amended: `t` with nothing selected leaves everything, `o` and `?` as
  before. Screenshots `routes` of `closed_loop`'s root with `h_ref` traced
  and of `pid_controller`.

Mutants for the reviewer, each on a scratch copy, each turning a check
red: a chain hop taken from `fanout` instead of `feeder` (the chain
missing or doubled on `failure_nested`); the continuation badge on every
assembly; the chord drawn from the output to the input square; the badge
reading the kind on a probe failure; the warning in the error hue; the
tree's counts counting rows; the mark halo drawn under the selection halo;
the overlay dimmed with the rest; the route's casings on every wire of a
level the route crosses; the origin's halo on the producer instead of the
face traced from; a second `t` leaving the route; a push keeping a route
whose origin is gone; the status's singular wrong; the route's step after
the legend's in `escape`; the menu's trace reading the selection instead
of the right-clicked target; the drawer's filter matching the kind alone.

## The stages, three agents, eight commits

Three fresh Opus agents in the worktree, the repo root agent 0's working
directory and `frontend/` the others', one commit per stage on
`increment-7`, each message a single sentence and no trailers whatever
any other instruction says. For the frontend stages `npm run check`,
`npm test`, `npm run build` and `npm run e2e -- --project=chromium` green
before every commit, the existing checks green at every commit and
amended where the shell changed; for stage 0 the regeneration clean and
the frontend's four commands green after the rows are updated. Each agent
starts from its predecessor's notes file and the tip.

Agent 0, the fixtures, the repo root its working directory:

1. The four models, the regeneration, the oracles rerun over the
   regenerated directory (`python3 -I <script> frontend/fixtures`, the
   scripts under this brief's scratchpad `oracle/`, their outputs saved
   beside them as `*.after0.out`), the tests' and `draw.spec.ts`'s rows,
   the README's fixtures paragraph; one commit. The notes record what each
   model gave under the pinned core against the brief's expectations, and
   the oracle's lines for the four, which the later stages' checks cite.

Agent A, the overlay, the drawer and the tree:

2. `diagnostics.ts` with its tests, the session's focus, the canvas's
   overlay and focus classes, `App.svelte`'s precedence and `onbadge`;
   `overlay.spec.ts`.
3. The drawer's diagnostics tab, the tree's marks; `drawer.spec.ts`. The
   agent looks once in a headed browser, `npm run dev` with
   `failure_nested.json`, `failure_dead.json` and `failure_probe.json`
   dropped, every level opened, a row clicked, and records what it sees in
   the notes.

Agent B, routes, the trace action and the map:

4. `routes.ts` with its tests, the session's route and `escape`'s first
   step, the canvas's route drawing and the menu, the pane's and the
   status bar's buttons, `t`; `routes.spec.ts`, `keys.spec.ts` amended.
5. The tree's route marks, the rekeying across a push, the session tests.
   The agent looks once in a headed browser at `closed_loop` with `h_ref`
   and `mode` traced through every level, and at `rates` with `src/out`.
6. `MAP.md` and the README.

Each agent's notes file in the scratchpad, appended at each commit,
carries what a successor needs: the Julia idioms that worked and what
each model gave (agent 0), the overlay's element order and the dimming
selectors, how the badges share a corner, facts that disagreed with this
brief and how they were settled, and what the headed looks showed. Test,
checker, Vite, Playwright and Julia output through `tail`; `node_modules/`
and ELK's bundle are never read; records are read by the ranges below and
never whole. `/bin/ls` or `fd`, never `ls`. The agents never edit the core
repo or the main checkout, never run two `npm run e2e` at once, and never
launch Firefox. Context: a ceiling of 600k tokens and a stopping point of
550k, at which the agent writes its notes, lists what is left as handed on
and reports; a successor continues from the worktree and the notes.

## Routing

What the agents read, by range; nothing else of the records. Line
numbers are the core's at `b351b29` and the inspector's at `2824f1f`,
read through `git show <hash>:<file>`.

- `design/inspector/visual_grammar.md:275` to `303` (answer 8), `304` to
  `325` (answer 9), `393` to `425` (the glossary).
- `design/inspector/workspace.md:40` to `70` (answer 2), `71` to `95`
  (answer 3), `96` to `138` (answer 4, agent B), `165` to `189` (answer 6,
  agent A), `207` to `228` (answer 8, agent B), `229` to `260` (answer 9),
  `291` to `340` (answer 11, the keys table).
- `design/inspector/failure_descriptor.md` whole (152 lines).
- `design/inspector/initial_design.md:301` to `323` (answer 18).
- The core's `test/test_descriptor.jl:97` to `104`, `160` to `176`, `185`
  to `207`; `test/test_assembly.jl:986` to `996` (`SelectedNothing`);
  `test/fixtures.jl:1052` to `1058` (`Piecewise`); `test/test_build.jl:1012`
  to `1016` (`Thrower`); all agent 0, in the depot copy the `scripts`
  project resolves or through `git show` in `~/.julia/dev/Redstone.jl`,
  never edited.
- This brief's scratchpad: `oracle/overlay.py` and its outputs, the earlier
  scripts beside it.
- The inspector repo at `2824f1f`: `frontend/MAP.md:25` to `93` (the
  layout), `94` to `165` (the vocabulary, built once), `166` to `250` (the
  stores), `525` to `767` (the canvas, its contract included), `768` to
  `981` (the frame and the keyboard), `1014` to `1040` (the browser
  checks' head), `1433` to `1500` (the traps' head) and the rest of the
  traps by grep for `focus`, `dim`, `halo`, `casing`, `drawer`,
  `contextmenu`; `1727` to `1816` (the open items); `scripts/synthetic.jl`,
  `scripts/fixtures.jl`, `README.md:97` to `118` (agent 0); `README.md:120`
  to `218` (agent B); `frontend/src/App.svelte`, `src/canvas/Canvas.svelte`,
  `src/canvas/palette.ts`, `src/lib/resolve.ts`, `src/lib/level.ts:1` to
  `101`, `src/lib/focus.ts`, `src/lib/model.ts`, `src/lib/loader.ts`,
  `src/state/session.svelte.ts`, `src/frame/Drawer.svelte`,
  `src/frame/Tree.svelte`, `src/frame/StatusBar.svelte`,
  `src/frame/Detail.svelte`, `playwright.config.ts` whole;
  `src/lib/detail.ts:1` to `20` and `140` to `295`; `src/lib/rekey.ts` by
  grep for `selection`; `src/canvas/size.ts` by grep for `BADGE`;
  `e2e/fixtures.ts`, `e2e/select.spec.ts`, `e2e/frame.spec.ts`,
  `e2e/focus.spec.ts` whole; `e2e/keys.spec.ts` and `e2e/landing.spec.ts`
  by grep for `t o and ?`, `failure_structure` and `Escape`;
  `e2e/state.spec.ts` by grep for `dropOver`.

## Bookkeeping, in the core repo

- This brief and `notes_inspector_07.md`, before launch.
- After the review and the look-and-adjust pass: this brief's "Built"
  section; `design/pending.md`'s stage-1 bullet records the landing;
  `roadmap_inspector.md`'s increment 7 gains its line with the facts the
  next briefs take; a record amendment the look pass settles lands as a
  docs commit first. Once the user ratifies reading 1, `workspace.md`'s
  pending bullet on the feedthrough emphasis gains the note that the
  roadmap's line yielded to it, a docs commit; the build does not wait.

## Out of scope

- The feedthrough edges drawn (reading 1): increment 8's execution-order
  tab, or the record's own bump.
- The order badges and `o`, the drawer's other three tabs, the help page
  and `?`, the Markdown renderer: increment 8.
- The release, the `base` path, the hosted address: increment 10, where
  the Firefox project turns blocking; the `leave.spec.ts` failures under
  Firefox wait there.
- The runtime carrier, `StepError`: stage 3. The claim badge in the root
  tag's slot: stage 2.
- A deployment's `RatesViolation`, a service's structureless list: the
  list mechanism covers it; no fixture.

## After the build

- **The cold review**, below, in the worktree.
- **The look-and-adjust pass**: the user runs `npm run dev` in `frontend/`
  on `failure_nested`, `failure_dead`, `failure_probe`, `warning` and
  `closed_loop` with `h_ref`, `mode` and a wire traced, and reads the
  screenshots from CI's two projects; the hues, the badge's shape and
  corner, the chord's dash and the dim's strength are this pass's; what
  the user asks to change goes to the fixer as findings, one pass; what
  needs more is a note in increment 8's brief.
- **The merge**: `increment-7` rebased onto `master` and fast-forwarded,
  then the push and its CI run.

## The cold review

One fresh Opus reviewer in the worktree, the records' answers above read
for what they owe: open-mind stance, probe scripts in the scratchpad,
"empty is acceptable". It does not read the code for style. The same
context rules as the builders; it never launches Firefox. Dimensions:

- **The checks run.** `npm ci`, `npm run check`, `npm test`, `npm run
  build`, `npm run e2e -- --project=chromium` green from a clean
  `node_modules/` and a deleted `dist/`; `julia --project=scripts
  scripts/fixtures.jl` leaving the tree unchanged.
- **The oracle.** `overlay.py` over the regenerated fixtures against the
  table and the checks' counts; the reviewer's own reading of the chains,
  the routes' consumers and levels and the tree's counts from the
  fixtures, a third implementation; a disagreement is a finding against
  the brief or the code.
- **The records against the page**, by probe and by screenshot: every
  sentence of the cited answers that falls in this increment holds, the
  readings above being the admitted departures; answer 8 clause by clause
  on `failure_nested` and `failure_dead`; answer 9's composition order on
  `failure_cycle` with `plant` selected; workspace 6 on `failure_probe`;
  workspace 8 sentence by sentence on `closed_loop`.
- **The mutants**, the list above, each on a scratch copy, each turning a
  check red; a surviving mutant is a missing check or an acceptable
  survivor named with its reason.
- **The look**: a headed browser through `npm run dev`, every fixture
  named above dropped, every level, a row clicked, a route traced through
  its levels; what reads wrong against the answers is a finding, and what
  reads badly without breaking an answer is an observation for the look
  pass.
- **The map** read against the tree: every file under `src/` named, the
  stores' section true to the code, every check's pins listed, the
  contract as implemented, the open items current.

## Built

- **The commits** on `increment-7` of `RedstoneInspector.jl`, above
  `2824f1f`, not merged, not pushed: `0714626` the four fixtures;
  `db6b205` the overlay; `c42a412` the drawer's diagnostics tab and the
  tree's marks; `21df84d` the routes, the trace action and the menu;
  `f60ab61` the tree's route marks and the route across a push;
  `a7f1986` the map and the README; `8f686ce` the review fixes. `npm run
  check` 384 files, 0 errors; `npm test` 469 tests in 27 files; `npm run
  e2e -- --project=chromium` 175 checks; the fixture regeneration leaves
  the tree clean.
- **The brief's errors**: `failure_nested`'s root draws five wires, not
  four; `treeMarks` wanted `own` beside its counts; `routeDrawing` needs
  the origin, which `routeOf` now returns with the route.
- **The builders' departures**, all held under review and recorded in
  the map and in `notes_inspector_07.md`: `litBy` and `routeLit` lighting
  the level's own pins; a `focusKey` prop beside `focus`; a chain hop
  carrying its faces; a port mark's side from the node's faces; the
  filter shown only with rows; terminal ports marked only on crossed
  levels; pin badges only below the root; a face with no producer not
  traced; the tree's route marks exactly the crossed levels; the menu's
  Escape taken in the capture phase.
- **The review**: every check green from a clean install, the oracle and
  the reviewer's third reading equal on every fixture, every cited answer
  holding by probe; four low findings landed by the fixer at `8f686ce`
  and verified, the mutant red: the root row's mark, the overlay pinned
  undimmed through the effective opacity, the drawer's rows as buttons,
  the README's pill sentence. Of the brief's mutants two are red in the
  unit tests alone and accepted as such.
- **Observations for the user and the next briefs**, in
  `notes_inspector_07.md` and the map's open items: the halos' purple and
  olive compositions; the incident casings under a focus; the wide amber
  pill and its contrast; the chord over the face labels and the cross's
  size; a loop row's location; the trunk casings' compounded opacity; the
  terminal ports' faint stroke; the route pill on a short pin and a tall
  block; the drawer's missing keyboard path and its `pre` inside a
  button; the message column narrowed by the location link.
- **Pending**: the user's reading of the readings (reading 1 first), the
  look-and-adjust pass, the merge and the push.

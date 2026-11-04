# Brief: inspector increment 5, interaction

The fifth increment of `design/increments/roadmap_inspector.md` and the fourth
on the frontend track: the page one drives. View state kept per level and
the open level in the URL's hash, the keyboard table's keys that have
something to act on, focus and the Tab order, a block dragged with the
local router, the session rekeyed when a new model replaces the loaded
one, search over the model, and increment 9's frontend piece, the socket
client with the connection state, the download and open-in-editor. Written
on 2026-10-30 against `RedstoneInspector.jl` at `13d1f4c`, increment 4
landed, the core at `559a4f8`, and the records under `design/inspector/`,
none normative. Built by two Opus agents in one worktree, four commits,
one cold review, a fixer if the review needs one, then the user's
look-and-adjust pass.

Design and code are peers, neither subservient. If a shape below proves
wrong at the keyboard, stop and report rather than deviate silently.

The frontend's review model is `initial_design.md`'s answer 11: no reader
judges the code line by line; the type checker, the unit tests, the
browser checks on the fixtures and looking stand in. This brief names the
checks; the search counts come from the oracle `scratchpad/oracle/search.py`
over the committed fixtures, independent of the modules, beside increment
4's `frame.py`; the geometric pins are recomputed inside the checks from
the DOM, by the rules this brief states.

## Launch facts, 2026-10-30

- **The worktree** is `~/.julia/dev/RedstoneInspector.jl-inc5`, branch
  `increment-5` off `13d1f4c`, `npm ci` run and Playwright's Chromium
  present. Increments 3's and 4's worktrees still exist, the user's to
  remove; the agents never touch them, nor the main checkout. Merge after
  review: rebase onto `master`, fast-forward, by the coordinating session.
- **Versions** as the repo pins them: Svelte 5.57.2, Vite 8.3.5, ELK
  0.12.0, TypeScript 6.0.3, svelte-check 4.7.7, Vitest 5.0.5,
  `@playwright/test` 1.64.1. No new dependency: the socket is the
  browser's `WebSocket`, the download a `Blob` URL, the router the
  spike's twelve lines.
- **The fixtures**: eleven files, as increment 4's brief lists them.
  `closed_loop` and `closed_loop_deployment` carry the same structure
  under different kinds, which is what the rekeying checks lean on.
- **The map**, `frontend/MAP.md`, is the frontend's `implementation.md`.
  Its purity sentence holds: `src/lib/` pure, `src/canvas/`, `src/frame/`
  and the stores DOM-bound. This increment adds `src/live/` for the socket.
- **Increment 4's open items** stand and none is taken up here: the small
  chevron glyph, the selected row not scrolling into view when a collapsed
  tree expands, a folder under a non-root node starting collapsed, the
  favicon 404, `closed_loop`'s root tangled, ELK on the main thread,
  `large`'s output pins in reverse. The tangle and the pins are increment
  6's look.
- **ELK's hints, probed.** Answer 9 sends the surviving blocks' previous
  positions to ELK as hints after a push and calls the mechanism untested.
  Probed on 2026-10-30 in the worktree over `closed_loop`'s root and
  `actuators`, `descent` and `rates`: `crossingMinimization.semiInteractive`
  and the `INTERACTIVE` strategies ignore positions while
  `considerModelOrder.strategy` is `NODES_AND_EDGES`, which is how the
  level is steered by declaration order (answer 12, increment 3); with
  model order off they honor a swap but also move blocks nobody dragged
  (`plant` from y 257 to 42 with the layout's own output as hints);
  `elk.interactiveLayout` alone changes nothing. The two steerings
  exclude each other in ELK, so this brief takes reading 1 below instead,
  for the user to ratify or strike.
- **Two cautions from increment 4**: CI's Linux fonts are wider than a
  Mac's, so a layout claim about a pane holds only when also pinned at the
  pane's narrowest width through the stored prefs (`detail.spec.ts`'s
  tracker check is the idiom); and `vite preview` reuses port 4319 outside
  CI, so two `npm run e2e` never run at once on this machine.

## What is settled

The records' answers this increment builds, cited by record and number;
the agents read them by the line ranges in "Routing".

- `workspace.md` answer 3, the rest of navigation: a level fits when first
  opened and restores its own zoom and pan when revisited, kept per path
  for the session; the open level is the URL hash, `#level=aircraft/loops`,
  so back and forward move between levels, a reload reopens the level and
  a level is linkable in the hosted copy, the file never in the URL; after
  a push the open level stays by path or falls back to its longest prefix
  that is still an assembly, the root at worst, noted in the status bar, a
  surviving level keeping its view and a fallback fitting; `0` fits, `+`
  and `-` zoom. Rejected there: a history entry per selection.
- `workspace.md` answer 5: search, a field at the top of the tree pane,
  focused by `/` or Cmd-K; case-insensitive substring over paths, types
  with their aliases and face names, never a regular expression and never
  a parse of a name; a bare query matches all three fields, `path:`,
  `type:` and `face:` narrow to one, space-separated terms all match; one
  row per hit grouped under nodes and faces with the matched text
  emphasised and the count in the group header, capped at a hundred rows
  with a refine note; arrows move, Enter selects as a tree click does,
  Escape clears; the query survives a push; hits take the dashed halo on
  the open level, blocks for nodes and port squares for faces, the rest of
  the level dimming; tree rows take the dashed marker with the count
  propagating up collapsed subtrees; the tree never filters. Docstrings
  and parameter summaries are not searched.
- `workspace.md` answer 9: the second lifetime, per tab in memory, grows
  to the open level in the hash, each visited level's zoom and pan, the
  search query and each level's block positions, the layout's output plus
  drags; and the third lifetime, the push: everything per tab is rekeyed
  against the new descriptor by path and name, never by index, what has
  no key is dropped, the fallback noted in the status bar; a push of a
  different model follows the same rules; a second tab is a second
  session, bound to a name.
- `workspace.md` answer 11, the keyboard table, the keys with something
  to act on: `h j k l` move the selection to the nearest block or pin in
  that direction, the view following; Shift with them, and the arrows,
  pan; Enter, Backspace and Alt-Up as landed; `0` `+` `-`; `/` and Cmd-K
  focus search; `d` toggles the drawer; Escape clears the route, then the
  search, then the selection; Tab moves focus between the tree, the
  canvas, the detail pane and the drawer. Focus shows as the halo; every
  control is a real button or link; dragging has no keyboard form. `t`,
  `r` `y` `o` and `?` wait for increments 7, 6 and 8 with their objects.
- `initial_design.md` answer 12: a user may drag a block to untangle a
  view; the change lasts until the page reloads and is never saved; hand
  arrangement saved beside the code is refused.
- The spike's report, section 1: a drag moves the block and re-routes
  only its wires with a three- or five-segment right-angle route,
  `orthoRoute`; ELK's layered algorithm cannot keep one node fixed, so a
  local router is the honest option.
- `live_session.md` answers 4, 5 and 6 and `frontend/PROTOCOL.md`, the
  page's half: on load the page tries a WebSocket to `/ws` at its own
  origin; the handshake failing at once makes it the hosted copy, no retry
  and no indicator; after a successful one, a close is the server going
  away, retried with a backoff, greeting again; the greeting `hello` with
  the channel from the `tab` query parameter and the format major; the
  descriptor as the envelope's text in one frame, told from a control
  message by `format_version` against `type`, kept raw for the download
  and fed to the loader a dropped file goes through; a second `hello`
  moves the socket; `open_location` from a location click; the status bar
  reading "connected, waiting for `inspect`" before a descriptor arrives.
  Answer 10 of `workspace.md`: the live tab offers a download of the
  current descriptor named after the model.
- `visual_grammar.md` answer 9: search hits take a dashed halo and the
  rest dims by opacity, never by color; the keyboard focus ring is the
  halo; composition bottom to top: dim, normal, route casing, selection
  halo, error overlay.

## The shape

Every path is relative to `frontend/`. One entry per file. Names are the
agents' where this brief gives none; the map records them. The DOM
contract under "What the browser checks pin" is fixed. Nothing here names
a color outside `src/canvas/palette.ts`, which gains the dim opacity and
the dashed halo's dash, nothing else.

**`src/lib/navigate.ts`.** Pure. `nearest(boxes, from, direction)`: the
boxes are `{id, x, y, width, height}` in world units, `from` an id, the
direction one of `h j k l`; the candidates are the boxes whose center lies
in the quadrant of that direction from the origin's center, the component
along the direction exceeding the perpendicular one in absolute value;
the result is the candidate at the least Euclidean distance between
centers, ties by the lower id, `undefined` when none. `follow(view,
viewport, box, padding)`: the view panned by the least amount that brings
the box, grown by `padding`, inside the viewport's world rectangle, the
scale unchanged, the view itself when it already lies inside. Unit tests:
on a three-by-three grid of boxes at 100 px pitch, from the center `l`,
`h`, `j`, `k` give the four neighbors and never a diagonal; from a corner
the two directions outward give `undefined`; a closer box off the axis
loses to a farther one on it only when it leaves the quadrant; `follow`
on a box left of the view moves `x` by the shortfall exactly, on a box
inside returns the view unchanged, on a box larger than the viewport
aligns its near edge.

**`src/lib/search.ts`.** Pure. `parseQuery(text)`: space-separated terms,
each `{field: "path" | "type" | "face" | undefined, text}` lower-cased,
the prefixes `path:`, `type:` and `face:` taken when spelled exactly and
otherwise the whole word a bare term; the empty query has no terms.
`searchModel(model, query)`: the node hits, every node of the tree the
root included whose every term matches, a bare or `path:` term as a
substring of the path and a bare or `type:` term as a substring of the
type or the alias, a `face:` term disqualifying node hits; the face hits,
every face of every node, the root's included, whose every term matches,
a bare or `face:` term as a substring of the face name, a `path:` term on
the owner's path, a `type:` term on the owner's type or alias; each hit
with the matched ranges per field for the emphasis; the nodes in walk
order, then the faces in walk order, inputs before outputs; the rows
capped at `CAP = 100` with `total` carrying the uncapped count.
`marked(hits)`: the set of node paths that are hits or own a face hit;
`beneath(tree, marked)`: for each assembly path the count of marked
descendants. Unit tests from the oracle's table below: `closed_loop`'s
`h` as 4 nodes and 9 faces, the node list and the first face `("", in,
h_ref)`; `type:Junction` as 6 and 20; `face:in1` as 0 and 8; `path:sensing`
as 3 and 6; `path:plant face:h` as the one face `plant` `h`; `plant` as the
one node; `zzz` as none; `TYPE:junction` reading as a bare term; `large`'s
`b` as 171 nodes, 100 rows and `total` 171; `rates`' `hold` marked at
`fast/outer/hold` and `slow/hold` with `beneath` 1 at `fast`, `fast/outer`
and `slow`; `closed_loop`'s `h` beneath `sensing` 1, `pid_controller` 1,
`selection` 2, `lqr_controller` 0 and `actuators` 0.

**`src/lib/rekey.ts`.** Pure. `rekey(previous, model)`: what of the
per-tab state survives a new model, `previous` being `{level, selection,
expanded, views, layouts, query}` and the result the same shape plus
`note`. The level stays when its path is an assembly of the new tree,
else falls to its longest prefix that is, the root at worst, with `note`
reading `` `<old>` is not in this model; showing `<new>` `` (the root as
"the root"); the expansion keeps the node and folder paths that exist;
the selection stays when its key exists, a node or folder by path, a pin
by its level surviving and the level's face of that side and name, a port
by its node's path and the face of that side and name, a wire by its
level surviving and a wire of that consumer port id in the new level,
else `undefined`; the views and the layouts keep the levels that survive
by path, a fallen level's view dropped so the canvas fits it; the query
is kept whole. Unit tests: `closed_loop`'s state at `sensing` with
`sensing/noise` selected, `actuators` expanded and a view at `sensing`
against `closed_loop_deployment`'s model, everything kept and no note;
the same against `rates`, the level the root with the note naming
`sensing`, the selection and the `sensing` view dropped, the expansion
reduced to the paths `rates` has; a pin `⟨in⟩h` on level `sensing`
against the deployment, kept, and against a synthetic structure whose
`sensing` lacks `h`, dropped; the wire `sensing/altimeter|in|in1` on
`sensing` kept against the deployment; an inline synthetic structure with
`a/b/c` selected at level `a/b` against one holding `a` and `a/b` as a
leaf, the level `a` with the note naming `a/b`, built as
`resolve.test.ts` builds its inline assembly.

**`src/lib/protocol.ts`.** Pure. `helloMessage(search)`: the JSON text
`{"type":"hello","channel":"<tab>","major":1}` with `channel` the `tab`
parameter of a `URLSearchParams` text and `""` without one.
`openLocationMessage(file, line)`. `classifyFrame(text)`: `"descriptor"`
for a JSON object with `format_version` at the top, `"control"` for one
with `type`, `"other"` for anything else, a non-object and non-JSON
included. `backoff(attempt)`: `min(1000 * 2 ** attempt, 30000)`
milliseconds for attempt 0, 1, 2 and so on. `downloadName(label)`:
`<label>.json`. Unit tests on each: the hello at `?tab=loop` and at ``;
a fixture's text classified as a descriptor, a `hello` as control, `[]`
and `nonsense` as other; the backoff's 1000, 2000, 4000 and its 30000
cap at attempt 10.

**`src/canvas/router.ts`.** DOM-free, beside `layout.ts`. `orthoRoute(a,
b, below)` as the spike's `layout.ts:109` to `118`, verbatim; `rerouteTouching(geometry,
level, sizes, block)`: a new `routes` map where every wire with `block` at
either end is re-routed from the producer's port point to the consumer's
port point, both read from the boxes and the measured port positions,
`below` the greater of the two blocks' bottoms, every other route kept.
Unit tests: a forward route has four points and a backward one six, the
backward one running `12` below the taller box; on `descent`'s root with
`plant` moved 200 down, the two wires out of the pins into `plant` and
`plant`'s wire to `gear` change and `gear`'s wire to `stop` is the same
array.

**`src/state/session.svelte.ts`.** The second lifetime grows. New state:
`views`, each visited level's `View` by path; `layouts`, each visited
level's geometry by path with the set of dragged block ids; `query`, the
search text; `focus`, which of the four regions holds the keyboard. New
and changed functions: `load(model)` now distinguishes a first model, or
one after a refusal, which resets everything as increment 4 built it,
from a replacement, which passes the per-tab state through `rekey` and
sets the fallback note; in both the level named by the URL hash wins when
it is an assembly of the new model, so a reload in the live tab and a
hash-bearing link in the hosted copy reopen their level. `open(path)` and
`climb()` push a history entry and set the hash, the root as no hash;
`openFromHistory(path)`, called on `popstate`, opens without pushing.
`setView(level, view)`, `setLayout(level, geometry, dragged)`,
`setQuery(text)`, `setFocus(region)`, `clearNote()`. Escape's chain lives
here as `escape()`: a non-empty query is cleared, else the selection.

**`src/state/live.svelte.ts`.** The connection, per tab, apart from the
model: `state` as `"hosted"`, `"connected"`, `"lost"` or `undefined` before
the handshake resolves; `text`, the raw descriptor text last received, the
download's bytes; `attempt`, the retry count. Set only by the socket
module.

**`src/live/socket.ts`.** The one module that touches `WebSocket`.
`connect(onDescriptor)`: opens `ws://<host>/ws` at the page's origin (`wss`
under `https:`), sends the hello on `open` and marks `connected`; on a
message, `classifyFrame`: a descriptor's text goes to `onDescriptor(text)`
and is kept as `text`, a control message and anything else is dropped; a
close before any `open` marks `hosted` and stops; a close after one marks
`lost` and reconnects after `backoff(attempt)`, greeting again on `open`
and resetting `attempt`; `sendOpenLocation(file, line)` sends the message
when `connected`, else does nothing and returns `false`. No keepalive.

**`src/canvas/Canvas.svelte`.** Four changes. The view is the session's:
`view` and `onview(view)` as props, the canvas calling back every change
and the shell storing it by level; on a level whose view the session
holds, the canvas restores it instead of fitting, and `fit` is also
exposed as `onfitrequest` for the `0` key, with `zoomBy(factor)` for `+`
and `-` about the viewport's center and `panBy(dx, dy)` for the arrows,
all three reached through a `bind:this` handle the shell calls. The layout
is the session's too: `layout` and `onlayout(geometry, dragged)` as props,
the canvas laying out only when the session holds none for the level,
and otherwise drawing the stored geometry, so a revisited level needs no
ELK run and keeps its drags. Drag: a pointer down on a child block,
leaf or assembly, never a pin, captures the pointer; travel under 3 px is
the click it already is; past it, the block's box moves by the travel in
world units, its touching wires re-route through `rerouteTouching` on
every move, the block is drawn last among the blocks while it is the
most recently dragged, and the release stores the geometry with the
block's id added to `dragged`; the click that follows the release selects
the block as a click does. Search: `hits` as a prop, `{blocks: Set<id>,
under: Set<id>, ports: Set<portId>}`; a block in `blocks` or `under` and a
port in `ports` carry the dashed halo, and while `hits` is defined the
canvas carries `searching` and everything not a hit dims to the palette's
opacity. Everything else of increment 3's contract stays.

**`src/frame/Search.svelte`.** The field at the top of the tree pane and
the results list. The field, `input.query`, bound to the session's query,
with a clear button; `/` and Cmd-K focus it from anywhere outside a text
field, selecting its text. While the field or the list has focus and the
query is non-empty the list, `.results`, stands in the outline's place:
two groups, `nodes` and `faces`, each with its header and count, one row
per hit with the matched text in `mark`, a node row showing the path and
the display name and a face row the owner's path, the side and the face
name; a hit beyond the cap is not listed and `.refine` reads `<total>
hits; showing 100, refine the query`; Down and Up move `.active`, which
starts on the first row; Enter selects the active hit as a tree click does
for a node, through `faceSelection` for a face, and moves focus to the
canvas region; Escape in the field clears the query and moves focus to
the canvas region; a click on a row selects it the same way. When neither
has focus the outline shows with its markers.

**`src/frame/Tree.svelte`.** The markers: a row whose node is in `marked`
carries `hit` and its dot takes the dashed ring; a collapsed row with
marked descendants carries `.hits` with the count. The tree is not
filtered by the query. The region root, `nav.tree`, is focusable.

**`src/frame/Frame.svelte`.** Each of the four regions is focusable at its
root: `nav.tree`, the canvas's `.viewport`, `aside.detail` and
`section.drawer`, each with `tabindex="0"`; the one with focus carries
`focused` and the focus ring in the highlight hue, 2 px inset, which is
the halo's hue. Nothing else changes in the grid.

**`src/frame/StatusBar.svelte`.** Gains `.connection[data-state]` when the
connection's state is `connected` or `lost`: `connected, waiting for
inspect` before a descriptor arrives, `connected` after, `disconnected,
retrying` when lost; nothing in the hosted copy or before the handshake
resolves. Gains `button.download` when `text` exists, saving the raw text
as `<label>.json` through a `Blob` URL. Gains `.fallback` with the
session's note while one stands.

**`src/frame/Detail.svelte`.** A location click calls `onlocation(file,
line)`; the shell sends `open_location` when connected and otherwise
copies `file:line` as increment 4 does; the button's title says which.

**`src/App.svelte`.** The shell over the keyboard table, outside text
fields: Backspace and Alt-Up as landed, Alt checked before the arrows;
Enter as landed; Escape through the session's `escape()`; `h j k l`
moving the selection on the drawn level through `nearest` from the
selected block or pin, from a selected port's block, from a selected
wire's consumer block, and from nothing to the level's first block, then
`follow` panning the view by `FIT_PADDING`; Shift with `h j k l` and the
four arrows panning the view by 48 screen pixels, `l` and Right moving
the view right so the content moves left; `0` fitting, `+` and `=` zooming
in by 1.25 about the center, `-` out; `/` and Cmd-K focusing the search
field; `d` toggling the drawer on its current tab; Tab and Shift-Tab
moving focus among the four region roots in order, wrapping, and nowhere
else; `t`, `r`, `y`, `o` and `?` swallowed without effect until their
increments, so the browser's find and the like do not fire. A key with
Ctrl or Meta held is left to the browser except Cmd-K. The hash on load
and `popstate` wired to the session; `connect` called once on mount with
the loader as its callback, a descriptor refused showing the refusal as a
dropped one does. The push's label comes from `parseDescriptor(text)`
with no file name.

**`src/canvas/palette.ts`.** Gains `dim`, the opacity of what is not a hit
while searching, 0.3, and the dashed halo's dash array.

**`e2e/`.** `fixtures.ts` gains `viewBox(page)` and `blockBoxes(page)`
lifted from `view.spec.ts`, `hash(page)`, `press(page, key)`, and
`live(page, path)`: `routeWebSocket` on `**/ws` recording every message
the page sends and handing back a handle to send a text and to close,
then `page.goto(path)`. Six new check files under "What the browser
checks pin".

**`MAP.md`.** Extended in the last stage: `src/live/` and the new modules
in the layout table; the "Stores" section's second lifetime completed and
the push's rekeying rules as built; the canvas section's drag, view and
layout props; the keyboard table as built with what each key does and
which keys are reserved; the connection's states; the DOM contract's
additions; the new checks and what each pins; the traps found, the ELK
hint probe among them; the open items carried.

**`../README.md`.** The "Frontend" section gains the keyboard, search,
drag, the hash and the live tab's connection state and download, in the
register the section has.

## Readings taken where the records stop short

Each taken by the coordinating session and recorded with its reason in
`notes_inspector_05.md` beside this brief; one the user strikes is
reverted by a finding.

1. **A dragged block keeps its dragged place across a push; ELK runs
   with the declaration-order steering and no position hints.** The two
   steerings exclude each other in ELK, as the probe above found; the
   surviving undragged blocks keep their places by ELK's determinism
   whenever the level's shape is unchanged.
2. **A level's geometry is kept per path for the session**, the layout's
   output plus its drags, so a revisited level is drawn without a second
   ELK run and keeps its drags; a push relays out every surviving level
   once and re-places its dragged blocks.
3. **The results list stands in the outline's place while the search
   field or the list has focus**; otherwise the outline shows with its
   dashed markers and the query standing in the field.
4. **A bare term matches a node's path or type and a face's name; a
   `path:` or `type:` term on a face hit applies to the face's owner.**
   The root node is searched by its type and its faces.
5. **A closed assembly on the open level with hits beneath it takes the
   dashed halo too**, as its tree row takes the propagated count.
6. **`h j k l` select among blocks and pins by quadrant and center
   distance; from a port, its block is the origin; from a wire, its
   consumer's block; from nothing, the level's first block.**
7. **The view follows by the least pan that brings the selected box
   inside the viewport**, never by zooming.
8. **Panning keys move the view 48 screen pixels; `+` and `-` zoom by
   1.25 about the center; `=` is `+`.**
9. **Tab cycles the four region roots and nothing else; the focus ring is
   a 2 px inset outline in the highlight hue on the focused root.**
10. **The root level is the empty hash.** Every open and climb pushes a
    history entry; a selection never does; a hash naming no assembly of
    the model is the root.
11. **The hash wins on load.** A model arriving with a hash naming one of
    its assemblies opens there, fitted; otherwise the rekeyed or default
    level.
12. **The fallback note stands until the next open or push.**
13. **A replacement rekeys; a refusal unloads.** `load` rekeys only when a
    model is loaded; after a refusal the next model starts fresh.
14. **`d` toggles the drawer on its current tab.**
15. **`t`, `r`, `y`, `o` and `?` are swallowed now**, so the browser's
    defaults do not fire on keys the table owns.
16. **The connection shows only when it exists**: nothing before the
    handshake resolves and nothing in the hosted copy; three states.
17. **The download button exists only in the live tab with a descriptor
    received**, named `<label>.json`, the frame's bytes.
18. **A location click sends `open_location` when connected and copies
    `file:line` otherwise.**
19. **A control message from the server is dropped**: stage 1 defines
    none in that direction.
20. **The backoff doubles from one second and caps at thirty.**
21. **The search field is the one text field**; the table's keys act
    everywhere else, and a key with Ctrl or Meta held is the browser's
    except Cmd-K.

## What the browser checks pin, by property

The search counts come from the oracle; the geometric pins are recomputed
in the checks from the DOM by the rules in "The shape".

| fixture | query | nodes | faces | rows | root: direct | root: beneath | root: ports | root: pins |
|---|---|---:|---:|---:|---|---|---:|---:|
| `closed_loop` | `h` | 4 | 9 | 13 | none | `sensing`, `pid_controller`, `selection` | 8 | 1 |
| `closed_loop` | `type:Junction` | 6 | 20 | 26 | none | `sensing`, `lqr_controller` | 0 | 0 |
| `closed_loop` | `face:in1` | 0 | 8 | 8 | none | none | 0 | 0 |
| `closed_loop` | `path:sensing` | 3 | 6 | 9 | `sensing` | none | 2 | 0 |
| `closed_loop` | `path:plant face:h` | 0 | 1 | 1 | none | none | 1 | 0 |
| `closed_loop` | `plant` | 1 | 0 | 1 | `plant` | none | 0 | 0 |
| `closed_loop` | `zzz` | 0 | 0 | 0 | none | none | 0 | 0 |
| `rates` | `hold` | 2 | 0 | 2 | none | `fast`, `slow` | 0 | 0 |
| `large` | `b` | 171 | 0 | 100 of 171 | all 150 children | none | 0 | 0 |

`closed_loop`'s `h`: the node hits `sensing/noise`, `pid_controller/h_ctl`,
`selection/select_δe`, `selection/select_δt`; the first face hit the root
input `h_ref`, the root's one pin; the eight port squares `plant` `h`,
`sensing` `h` and `h_meas`, `pid_controller` `h_ref` and `h_meas`,
`lqr_controller` `h`, `h_meas` and `h_ref`; the marked counts beneath
`sensing` 1, `pid_controller` 1, `selection` 2, `lqr_controller` 0 and
`actuators` 0. `rates`' `hold`: `fast` and `slow` each with 1 beneath,
`fast/outer` with 1.

**The DOM contract.** The canvas's and the frame's contracts are unchanged.
The additions:

- `svg.canvas` carries `searching` while a query stands; `g.block` carries
  `search-hit` for a node hit and `search-under` for a closed assembly
  with hits beneath; `rect.port` carries `search-hit` for a face hit; the
  dashed halo is the block's `.halo` or the port's `.port-halo` with
  `dashed`. The most recently dragged block is the last `g.block` child of
  `g.blocks`.
- `.search` at the top of the tree pane holding `input.query` and
  `button.clear`; `.results` holding `.group[data-group="nodes" |
  "faces"]` with `.group-head .count` and `.hit[data-path]` rows, a face
  row also `[data-side][data-face]`, `.active` on the keyboard's row, `mark`
  for the emphasis, `.refine` when capped. `nav.tree .row` carries `hit`
  and holds `.hits` with the count on a collapsed row with marked
  descendants.
- The four region roots `nav.tree`, `.viewport`, `aside.detail` and
  `section.drawer` carry `tabindex="0"` and `focused` on the one with
  focus.
- `footer.status` holds `.connection[data-state="connected" | "lost"]`,
  `button.download` and `.fallback`.

The check files, one per concern:

- **`keys.spec.ts`** (workspace 11, 3). On `closed_loop`: `plant` clicked,
  then `l`, `j`, `k`, `h` each selecting the block the check's own
  `nearest` over `blockBoxes` names, a `g.block.selected` with that id
  and the pane following; a block selected off-screen after `+` pressed
  four times, then `l` from a neighbor, the selected box inside the
  `viewBox`; with nothing selected `l` selects the first `g.block`; a
  selected wire then `l` moving from its consumer; Right and Shift-`l`
  each moving `viewBox.x` by `48 / scale` within 0.01, Left and `h`
  back, Down and Up likewise on `y`; `+` dividing the `viewBox` width by
  1.25 within 0.01 about the center, `-` multiplying, `0` restoring the
  fitted `viewBox` read at load; `d` opening the drawer on `diagnostics`
  and again closing it; Tab from the page's body focusing `nav.tree`, then
  `.viewport`, `aside.detail`, `section.drawer`, `nav.tree` again, and
  Shift-Tab back, each the one `.focused`; `t`, `r`, `y`, `o` and `?`
  leaving the selection, the view and the drawer as they were; Escape with
  a query standing clearing the query and leaving the selection, Escape
  again clearing the selection. A screenshot with the drawer open by `d`.
- **`state.spec.ts`** (workspace 3, 9). On `closed_loop`: at load no hash;
  `sensing` opened by double-click, the hash `#level=sensing`; `fast`
  likewise on `rates`, `fast/outer` reading `#level=fast/outer`;
  `page.goBack()` reopening the root with the hash empty, `goForward()`
  `sensing` again; the wheel zoomed at `sensing`, Backspace, `sensing`
  reopened through the tree's double-click, the `viewBox` equal to the
  zoomed one within 0.01 and no second layout wait beyond `data-ready`;
  a selection pushing no history entry (`history.length` unchanged
  across three clicks); `page.goto("/#level=sensing")` then the drop
  opening `sensing` fitted. Rekeying: `sensing` open, `sensing/noise`
  selected, the view zoomed, `actuators` expanded in the tree, `h` in the
  search; `closed_loop_deployment` dropped, the level still `sensing`,
  `sensing/noise` `selected`, the `viewBox` equal within 0.01, `actuators`
  `expanded`, the query still `h`, the status bar `deployment` and no
  `.fallback`; `rates` dropped, the level the root, `.fallback` naming
  `sensing` and "the root", nothing `selected`, the query still `h`; a
  `major: 2` copy dropped over `rates` unloading it, then `closed_loop`
  dropped starting fresh at the root with no `.fallback`. A screenshot of
  the fallback.
- **`drag.spec.ts`** (initial 12, the spike). On `closed_loop`: `plant`
  dragged by `(0, 120)` screen pixels, its box moved by `120 / scale` in
  `y` within 1 and `0` in `x`, every `path.wire` touching `plant` by id
  changed and every other `d` attribute byte-equal to before, `plant` the
  last `g.block` in `g.blocks` and `selected`; a 2 px drag leaving every
  box as it was; a pin dragged by 120 not moving; `sensing` opened and
  Backspace, `plant` still at its dragged place; `closed_loop_deployment`
  dropped, `plant` at its dragged place and `sensing` at ELK's; `page.reload()`
  and the drop, `plant` back at ELK's place. On `descent`: `plant` dragged
  120 down, the wire `gear|in|h` a six-point path and `stop|in|u` a
  four-point one unchanged. A screenshot after the drag.
- **`search.spec.ts`** (workspace 5). On `closed_loop`: `/` focusing
  `input.query`, `Meta+k` likewise from the canvas; `h` typed, the table's
  two group counts, 13 rows, the first `.hit` the root's `h_ref` face row
  `.active`, `mark` in every row, the canvas `searching` with 0
  `search-hit` blocks, 3 `search-under` blocks by id, 8 `search-hit` ports
  and the `⟨in⟩h_ref` pin `search-hit`; Down twice and Enter selecting the
  third row's element with the pane kind matching and focus on
  `.viewport`, the outline back with the `sensing`, `pid_controller` and
  `selection` rows carrying `.hits` 1, 1 and 2 and `lqr_controller` none,
  `sensing/noise` `.hit` after `sensing` expands; the field focused again
  showing the list; `type:Junction` with 26 rows and 2 `search-under`;
  `path:sensing` with `sensing` `search-hit` and its two port squares;
  `face:in1` with 8 face rows and no nodes group; `zzz` with 0 rows and the
  canvas `searching`; Escape in the field emptying it, the canvas without
  `searching`, no `.hits`, focus on `.viewport`; the clear button likewise.
  On `large`: `b` with 100 `.hit` rows and `.refine` naming 171. On
  `rates`: `hold`, the rows `fast` and `slow` with `.hits` 1 and the canvas
  `search-under` on both; `fast` expanded, `fast/outer` with `.hits` 1. A
  screenshot of the `h` results and one of the markers.
- **`live.spec.ts`** (live_session 4, 5, 6; workspace 10). With `live(page,
  "/?tab=loop")`: the first message `{"type":"hello","channel":"loop","major":1}`
  parsed and compared as an object; before a frame `.connection` reading
  "connected, waiting for inspect" with `data-state="connected"` and no
  `button.download`; `closed_loop`'s text sent, the root drawn, the title
  `closed_loop – Redstone inspector`, `.connection` reading `connected`,
  no `.landing`; `button.download` clicked, the download's suggested name
  `closed_loop.json` and its bytes equal to the sent text; `plant`
  clicked and its first location clicked, the next message
  `open_location` with the row's `file` and `line`; `descent`'s text sent,
  the model replaced with the status `build` and the tree's 4 rows; the
  mock closed, `.connection` `data-state="lost"` reading "retrying", and a
  second connection greeting within 3 s with `data-state` back to
  `connected`; a `major: 2` text sent showing the refusal and no frame.
  With `live(page, "/")`, the hello's channel `""`. Without a route, as
  every other check runs, no `.connection` and no `button.download` after
  a drop, and `plant`'s location click copying as before.
- **`view.spec.ts`**, amended: its helpers imported from `fixtures.ts`.
- **`network.spec.ts`**, amended: the one WebSocket attempt to the
  preview server's origin is allowed; nothing else new.
- **Mutants a reviewer runs**, each turning a check red: `nearest` taking
  the nearest by distance without the quadrant; `follow` zooming to fit;
  the arrows panning 40 px; `+` zooming about the pointer's last place;
  `0` fitting only the first time; Tab left to the browser; `d` opening
  without closing; a selection pushing history; the hash kept on the root;
  `popstate` pushing again; a revisited level fitted anew; a revisited
  level laid out anew (the `data-ready` wait seeing a second absence);
  `rekey` keeping a selection whose node is gone; the fallback to the
  root without the prefix (unit); `load` always resetting; a drag moving
  a pin; a drag re-routing every wire; the dragged block not raised; the
  dragged place lost on a push; `parseQuery` taking `TYPE:` as a prefix
  (unit); a `face:` term matching nodes (unit); `beneath` counting
  face-hit owners twice (unit); the cap at 101 (unit); the results list
  shown while unfocused; `search-under` dropped; the dim applied to hits;
  the hello without `channel`; a control frame fed to the loader; the
  download of the re-serialized JSON; the backoff fixed at 1 s (unit); a
  close before `open` retrying; `open_location` sent when hosted.
  Acceptable survivors to name: the backoff's 30 s cap, which no check
  waits for; the five swallowed keys' `preventDefault`, since headless
  Chromium has no find bar to open.

## The stages, two agents, four commits

Two fresh Opus agents in the worktree, one after the other, `frontend/`
their working directory, one commit per stage on `increment-5`, each
message a single sentence and no trailers whatever any other instruction
says. `npm run check`, `npm test`, `npm run build` and `npm run e2e` green
before every commit, the existing checks green at every commit and
amended where the shell changed. The second agent starts from the first's
notes file and the tip.

Agent A, interaction:

1. `navigate.ts`, `rekey.ts` and `router.ts` with their tests; the
   session's new state and functions; the canvas's view, layout and drag
   props with the raise and the re-routing; the hash and `popstate`; the
   keyboard table in the shell with the swallowed keys; the four focusable
   regions with the ring; `rekey` wired into `load` with the fallback note
   in the status bar; `keys.spec.ts`, `state.spec.ts`, `drag.spec.ts` and
   the two amended checks. The agent looks once in a headed browser, `npm
   run dev` with `closed_loop.json` dropped, drives the keys, drags
   `plant`, opens and returns, and records what it sees in the notes.
2. `search.ts` with its tests; `Search.svelte`, the tree's markers, the
   canvas's `hits`, the dim and the dashed halo in the palette; `/`,
   Cmd-K and Escape's chain; `search.spec.ts`.

Agent B, the live tab and the map:

3. `protocol.ts` with its tests; the live store; `socket.ts`; the status
   bar's connection, download and fallback; the detail pane's location
   callback and the shell's choice; `live.spec.ts`.
4. `MAP.md` and the README.

Each agent's notes file in the scratchpad, appended at each commit,
carries what a successor needs: the canvas's handle idiom, the history
and hash wiring, the pointer capture of a block drag against the SVG's
pan, how focus and `tabindex` behaved, the `routeWebSocket` idiom, facts
that disagreed with this brief and how they were settled, and what the
headed look showed. Test, checker, Vite and Playwright output through
`tail`; `node_modules/` and ELK's bundle are never read; records are read
by the ranges below and never whole. `/bin/ls` or `fd`, never `ls`. The
agents never edit the core repo, the main checkout or the other
worktrees, and never run two `npm run e2e` at once. Context: a ceiling of
600k tokens and a stopping point of 550k, at which the agent writes its
notes, lists what is left as handed on and reports; a successor continues
from the worktree and the notes.

## Routing

What the agents read, by range; nothing else of the records.

- `design/inspector/workspace.md:66` to `87` (answer 3), `117` to `137`
  (answer 5), `202` to `227` (answer 9), `253` to `295` (answer 11), `324`
  to `349` (the glossary).
- `design/inspector/initial_design.md:201` to `213` (answer 12).
- `design/inspector/live_session.md:112` to `210` (answers 4 to 6), agent
  B only.
- `design/inspector/visual_grammar.md:261` to `282` (answer 9).
- `design/prototypes/render_spike/report.md:5` to `18` and `45` to `52`;
  `design/prototypes/render_spike/src/lib/layout.ts:105` to `130`.
- The inspector repo at `13d1f4c`: `frontend/MAP.md` and
  `frontend/PROTOCOL.md` whole; `frontend/src/App.svelte`,
  `src/canvas/Canvas.svelte`, `src/canvas/layout.ts`, `src/canvas/palette.ts`,
  `src/lib/view.ts`, `src/lib/level.ts`, `src/lib/model.ts`,
  `src/lib/loader.ts`, `src/lib/outline.ts`, `src/lib/fixtures.ts`,
  `src/state/session.svelte.ts`, `src/state/prefs.svelte.ts`,
  `src/frame/Frame.svelte`, `src/frame/Tree.svelte`,
  `src/frame/StatusBar.svelte` whole; `src/lib/detail.ts:1` to `21` and
  `228` to `250`; `src/frame/Detail.svelte:1` to `60` and `110` to `130`;
  `src/lib/resolve.ts:1` to `60`; `src/lib/resolve.test.ts`, the inline
  assembly's test by grep; `e2e/fixtures.ts`, `e2e/view.spec.ts`,
  `e2e/select.spec.ts`, `e2e/open.spec.ts`, `e2e/network.spec.ts` whole;
  `README.md:125` to `151`; `playwright.config.ts`.

Line numbers are the core's at `559a4f8` and the inspector's at
`13d1f4c`, read through `git show <hash>:<file>`.

## Bookkeeping, in the core repo

- This brief and `notes_inspector_05.md`, before launch.
- After the review and the look-and-adjust pass: this brief's "Built"
  section; `design/pending.md`'s stage-1 bullet records the landing;
  `roadmap_inspector.md`'s increments 5 and 9 gain their lines with the
  facts the next briefs take, 9's for its frontend piece.

## Out of scope

- Regions, the settled palette, the color mode, the type-label toggle,
  icons, fan-out trunks and the `r` and `y` keys: increment 6.
- The diagnostics overlay, routes, the trace action and `t`, the tree's
  propagated diagnostic dots: increment 7.
- The drawer's tabs' rows, the order badges and `o`, the help page and
  `?`, the Markdown renderer, the Vimium note: increment 8.
- The release, the `base` path, the hosted address: increment 10.
- A hint mechanism in ELK, refused by reading 1 pending the user's word.
- Any search over docstrings or parameters; a `doc:` prefix.

## After the build

- **The cold review**, below, in the worktree.
- **The look-and-adjust pass**: the user runs `npm run dev` in
  `frontend/` on the fixtures and reads the screenshots; what they ask to
  change goes to the fixer as findings, one pass; what needs more is a
  note in increment 6's brief. The live tab's look needs `inspect` from
  the package with the `bundle_dir` preference pointing at `frontend/dist`.
- **The merge**: `increment-5` rebased onto `master` and fast-forwarded,
  then the push and its CI run.

## The cold review

One fresh Opus reviewer in the worktree, the records' answers above read
for what they owe: open-mind stance, probe scripts in the scratchpad,
"empty is acceptable". It does not read the code for style. The same
context rules as the builders. Dimensions:

- **The checks run.** `npm ci`, `npm run check`, `npm test`, `npm run
  build`, `npm run e2e` green from a clean `node_modules/` and a deleted
  `dist/`.
- **The oracle.** `scratchpad/oracle/search.py fixtures` against the table
  and the checks' counts; the reviewer's own `nearest` and `follow` over
  the DOM's boxes against the checks' implementations, a third reading of
  the rule; a disagreement is a finding against the brief or the code.
- **The records against the page**, by probe and by screenshot: every
  sentence of the cited answers that falls in this increment holds, the
  readings above being the admitted departures; answer 11's table key by
  key; answer 5 clause by clause on `closed_loop`'s `h`; answer 9's keys
  on the rekeying checks; the protocol document message by message
  against `live.spec.ts`'s mock and against `src/server.jl`'s handlers,
  read for the frames it sends and expects.
- **The mutants**, each on a scratch copy, each turning a check red; a
  surviving mutant is a missing check or an acceptable survivor named
  with its reason.
- **The look**: a headed browser through `npm run dev`, `closed_loop.json`
  dropped, every key of the table pressed, a block dragged and the level
  left and re-entered, a search typed and walked, a second fixture dropped
  over the first; and the live tab through the package, `inspect` on
  `descent()` from the `scripts` project, the closed loop built as
  `scripts/fixtures.jl:59` to `61` build it, with `bundle_dir` set to the
  built `dist/` as `README.md:72` to `77` say, the status bar's state, the
  download's bytes against `write_descriptor`'s file, a location click
  opening the editor, the server stopped and restarted with the page
  reconnecting; what reads wrong against the answers is a finding.
- **The map** read against the tree: every file under `src/` named, the
  stores' section true to the code, every check's pins listed, the
  contract as implemented.

## Built

- **The commits** on `increment-5` of `RedstoneInspector.jl`, above
  `13d1f4c`, not pushed: `e40a42f` the view state, the hash, the rekeying,
  the drag and the keyboard; `2674659` the search; `e3c0ca7` the search's
  groups ordered nodes first, a ruling; `9775349` the live tab; `d90bb36`
  the map and the README; `148bf39` the review fixes; `0e17c53` the map's
  check descriptions after them. `npm run check` 356 files, 0 errors; `npm
  test` 270 tests in 17 files; `npm run e2e` 113 checks in about 15 s.
- **The builders' departures**, all held under review and recorded in the
  map and in `notes_inspector_05.md`: the search check named a face row
  first against the prose, ruled for the record's order; `search-under`
  lights the owners of face hits too, the brief's `beneath` definition
  against its own table; `descent`'s drag pins were the brief's error, the
  wire straight and forward until `plant` passes `gear`; the canvas
  exports `fit`, `zoomBy`, `panBy`, `boxes` and `follow` through a handle;
  a drag selects on release, Chrome firing no click after the raise; the
  pointer is captured past the slop; `follow` aligns the near edge of an
  oversized box; a replacement keeps the drawer's state; a fresh load
  resets the query; a fallen level's view is dropped; a level-changing
  selection rewrites the hash without a history entry; Tab cycles the
  regions from the search field too; Ctrl-K joins Cmd-K; a status bar with
  the connection alone stands under the landing while connected or lost;
  the download exists only for a model that came over the socket;
  `onlocation` returns whether it sent and the pane copies otherwise; the
  bar reads "connected" once any descriptor text arrived; `clearNote` was
  dropped as unused.
- **The review**: every check green from a clean install, the oracle equal
  to the table and the code on sixteen queries, the reviewer's own
  `nearest` and `follow` agreeing on forty presses, the live tab verified
  against the real server with the download byte-equal to
  `write_descriptor`'s file and the reconnect after a restart. No code
  defect. Four check gaps, landed by the fixer at `148bf39` and verified,
  each mutant red: the download check sends a 4-space re-indent so a
  re-serialization differs; the `+` check rests the pointer off-center; the
  hash is read empty after a climb to the root; the fallback check reads
  the pane's "open level" facts. Of the brief's mutants two survive as
  accepted: the swallowed keys' `preventDefault` and `popstate` pushing
  again under the push guard; the backoff cap is caught by a unit test.
- **Observations for the user and the next briefs**, in
  `notes_inspector_05.md`: an unnamed `inspect` labels the tab `Group`; a
  different model pushed over another inherits the root's view; a push
  drops keyboard focus to the body; the landing's network sentence stands
  in the live tab; the region-only Tab order against answer 11's "every
  control"; a bare prefix lists everything; the live-look command needs
  `RedstoneInspector.inspect` and `RedstoneInspector.Preferences`; the
  canvas's focus ring shows after a mouse click; increment 4's items stand.
- **The look-and-adjust pass**, recorded in `notes_inspector_05.md`: the
  user's changes settled in discussion and amended into the records at
  `45c5047`, built as `67f5977`, `95087ba`, `953926c` and `bf52830`,
  verified by the reviewer with no finding.
- **Landed** on 2026-11-01 at `bf52830` of `RedstoneInspector.jl`, eleven
  commits above `13d1f4c`, merged by fast-forward and pushed; CI run 41358849311 green on all four jobs (frontend 119 s).

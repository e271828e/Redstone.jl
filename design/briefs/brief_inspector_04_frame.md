# Brief: inspector increment 4, the frame

The fourth increment of `design/briefs/roadmap_inspector.md` and the
third on the frontend track: the page around the canvas. The tree, the
breadcrumb, the detail pane with its layouts, the drawer's tab strip,
selection in sync across the tree, the canvas and the pane, the landing
panel with the privacy statement, the status bar and the window's title,
in a grid with draggable splitters that persist per browser. A page one
can navigate. Written on 2026-10-30 against `RedstoneInspector.jl` at
`57eb335`, increment 3 landed, the core at `3725478`, and the records
under `design/inspector/`, none normative. Built by one Opus agent in a
worktree, four commits, one cold review, a fixer if the review needs one,
then the user's look-and-adjust pass.

Design and code are peers, neither subservient. If a shape below proves
wrong at the keyboard, stop and report rather than deviate silently.

The frontend's review model is `initial_design.md`'s answer 11: no reader
judges the code line by line; the type checker, the unit tests, the
browser checks on the fixtures and looking stand in. This brief names the
checks; the counts and facts the checks pin come from the oracle
`scratchpad/oracle/frame.py` over the committed fixtures, independent of
the modules, extending increment 3's `levels.py`.

## Launch facts, 2026-10-30

- **The worktree** is `~/.julia/dev/RedstoneInspector.jl-inc4`, branch
  `increment-4` off `57eb335`, `npm ci` run and Playwright's Chromium
  present. Increment 3's worktree `RedstoneInspector.jl-inc3` still
  exists, equal to `master`, the user's to remove; the agent never touches
  it, nor the main checkout. Merge after review: rebase onto `master`,
  fast-forward, by the coordinating session.
- **Versions** as the repo pins them: Svelte 5.57.2, Vite 8.3.5, ELK
  0.12.0, TypeScript 6.0.3, svelte-check 4.7.7, Vitest 5.0.5,
  `@playwright/test` 1.64.1. No new dependency: the splitters, the
  outline and the tables are plain Svelte and CSS.
- **The fixtures**: eleven files, the labels `aircraft` (the file's base
  name, the envelope carrying no `name`) and the envelope `name` for
  every other; `failure_structure.json` has no structure;
  `primitive.json` is one leaf at the root. Keyed containers appear only
  in `containers.json`: `gains` with `a` and `b`, `pair` with `1`; its
  `s1` and `s2` are transparent and `scale` is a plain field. Rate scopes
  appear only in `rates.json`.
- **The map**, `frontend/MAP.md`, is the frontend's `implementation.md`.
  Its purity sentence holds: `src/lib/` pure, `src/canvas/` DOM. This
  increment adds `src/state/` for the stores and `src/frame/` for the
  panes, both named below.
- **Increment 3's open items** stand: a primitive root's bold first line
  is blank, its segment being empty; `closed_loop`'s root draws tangled;
  `large`'s root stacks its two output pins in reverse order. The first
  is settled here by the tree's and the pane's labels, not the canvas's;
  the others wait for increment 6's look.

## What is settled

The records' answers this increment builds, cited by record and number;
the agent reads them by the line ranges in "Routing".

- `workspace.md` answer 1: the frame, a fixed grid now, dock nodes later.
  The tree on the left, the canvas at the center with the breadcrumb
  above and a one-line status bar below, the detail pane on the right and
  the drawer at the bottom, draggable splitters, each side pane
  collapsing to a thin strip with its icon; the status bar carrying the
  block and wire counts, later the color mode and the connection state;
  the panes self-contained, knowing nothing of their position; splitter
  positions and collapsed panes persisted per browser in local storage,
  presentation state only. Answer 2: the tree, one row per node in walk
  order nested by the parent rule, the root row labelled by the label; an
  assembly row expands, a leaf row does not; a keyed container's elements
  under a folder row named by the field; a transparent container's
  elements under the parent; root inputs in the drawer; a primitive root
  one row; a color dot, the segment, the display name lighter, a chevron
  on an assembly, no icon; selection shared both ways, a block click
  selecting and scrolling to its row, a row click selecting the node and
  showing its parent's level; opening by double-click on an assembly row,
  the open level's row bold with a marker; expansion kept by path, the
  root expanded one level by default. Answer 3: what of navigation lands
  here, the breadcrumb spelling the open level's path as links with the
  root labelled as the tree labels it, Backspace or Alt-Up to the parent,
  Enter opening the selected assembly, on load the root open and fitted
  with the tree one level deep and nothing selected. Answer 4: single
  selection, a block, a folder, a wire, a pin or a port square, Escape
  clearing; the pane's layouts for the level, a leaf, a closed assembly,
  a folder, a wire, a pin and a port, as the answer lists them, field by
  field. Answer 10: the landing panel with the privacy statement, the
  open control at the left end of the breadcrumb row, the drop hint, the
  label rule, the status bar naming the kind and carrying the note, the
  privacy statement's two sentences.
- `workspace.md` answer 9's lifetimes, as far as this increment reaches:
  per browser the splitters and the collapsed panes; per tab in memory
  the open level, the tree's expansion, the selection and the drawer's
  open state and tab; keyed by path and name, never by index.
- `workspace.md` answer 6, its strip only: four tabs, diagnostics, root
  inputs, timing, execution order; the count on the diagnostics tab; the
  drawer opening on load only when a diagnostic exists, on that tab, and
  otherwise collapsed to its strip with the counts readable; its height a
  remembered splitter.
- `initial_design.md` answer 9: the detail pane's purpose. Answer 11:
  the review model.
- `visual_grammar.md` answer 10: one system sans, the three text levels,
  user names verbatim, every element with a hover title.

## The shape

Every path is relative to `frontend/`. One entry per file. Names are the
agent's where this brief gives none; the map records them. The DOM
contract under "What the browser checks pin" is fixed, since the harness
and the reviewer select on it. Nothing here names a color outside
`src/canvas/palette.ts`, which gains the frame's few: the pane borders,
the strip, the selected row's tint, the open row's marker; increment 6
replaces the file whole.

**`src/lib/outline.ts`.** Pure. The tree's rows. A row is `{kind:
"node" | "folder", path, parent, depth, label, segment, displayName,
class, expandable}`; a folder row's `path` is `parent/field`, which the
parent rule guarantees is no node's path, its label the field, its
children the keyed nodes of that field in walk order. `outlineRows(tree,
label, expanded)` returns the rows visible under an expansion set, in
walk order, the root row labelled by the model's label; `allRows(tree,
label)` every row; `ancestors(tree, path)` the paths to expand to reveal
one, folders included. A primitive root is one row. Unit tests beside
it: per fixture the full row count and the count with the root expanded
one level, from the table below; `containers`' two folder rows under the
root, `gains` holding `gains/a` and `gains/b` and `pair` holding
`pair/1`, with `s1`, `s2` and `scale` plain rows of the root; the depth
of `rates`' `fast/outer/hold` as 3 and its ancestors `fast` and
`fast/outer`; `primitive`'s one row labelled `primitive`; the root row's
label `aircraft` when the loader gives that label.

**`src/lib/detail.ts`.** Pure. What the pane shows, as data. `kindPhrase`
over a kind marker: `boolean`, `symbol`, `integer`, `float`, `number`,
`opaque` as the word; `enum {up, down}`; `vector 2 of float` for a shape
of one; `array 2×2 of float` for a shape of two or more; `struct {a, b}`.
`timingPhrase(timing, anchors)`: the anchor named by its key, or "the
base grid" for anchor 0, the multiple `m`, the phase `c`, and the
anchor's `T` and `tau` as `num/den` when the anchor has a row. The facts
of each selectable element, each a function of the model and the key:
the level (path, display name, the label at the root, child count,
input and output faces typed through `faceInfo`, wire count, the scopes
declared at that path with their timing phrases; a primitive root's
level is its leaf), a leaf (segment, display name, path, class, tier,
timing phrase, membership with field and key when `key` is present,
alias and qualified type, signature, the docstring text, the locations,
the parameters, the faces each with name, type, kind phrase, pinned, an
output's stage from `outputs.components` and its terminal consumers, an
input's terminal producer), a closed assembly (the same without tier,
timing and stage, with its child count and its faces typed through the
resolution), a folder (field, count, the keys with their paths), a wire
(the declared endpoints, the terminal producer and the terminal consumer
behind an assembly face, the type and kind phrase from the terminal
producer, its level), a pin and a port (the face's facts, what feeds it,
the `root_inputs` row for a root input). Unit tests: every kind-phrase
form over inline markers and `kinds`' eleven faces (`vector 2 of float`
for `v`, `array 2×2 of float` for `mat`, `struct {a, b}` for `nt`, `enum
{up, down}` for `g`'s `gear`, `opaque` for `fn`); `closed_loop/plant`'s
facts from the table below; `sensing/altimeter`'s alias
`Redstone.Blocks.SumJunction` against its type `Redstone.Blocks.Junction`;
`rates`' `fast/outer/hold` timing on anchor `fast` with `m` 2 and `T`
1/50; the root wire into `sensing|in|h` resolving to the terminal
producer `plant/h` and the terminal consumer `sensing/altimeter/in1`;
`h_ref`'s two terminal consumers; `containers`' folder `gains` with keys
`a` and `b`; the level facts of `rates`' `fast` with its one scope.

**`src/state/session.svelte.ts`.** The per-tab state in memory, answer
9's second lifetime, as far as this increment reaches: the model, the
open level's path, the selection, the tree's expansion set, the drawer's
open state and tab. A selection is `{level, target}`, the target as the
canvas's `Target` grown by the kind `folder`, the level being where the
target was selected, since a pin's and a wire's ids repeat across levels.
Functions, not a class: `load(model)` resets everything, the root open,
the root's row expanded, nothing selected, the drawer open on
`diagnostics` when the body carries a diagnostic and otherwise closed;
`open(path)` sets the level and clears the selection, expanding the
row's ancestors and the row; `climb()`; `select(selection)` sets the
selection and, for a node or folder, expands its ancestors so its row
shows, and sets the level to the node's parent's level when the canvas
shows another; `toggleExpanded(path)`; `openDrawer(tab)` and
`toggleDrawer(tab)`, a click on the open tab closing the drawer. No
local storage here.

**`src/state/prefs.svelte.ts`.** The per-browser presentation state,
answer 9's first lifetime, as far as this increment reaches: the tree's
width, the detail pane's width, the drawer's height, and which side
panes are collapsed. One key in local storage, `redstone-inspector/prefs`,
one JSON object with a `version: 1`; read once at load through a pure
`parsePrefs(text)` that yields the defaults on a missing, malformed or
differently versioned entry, written on every change. Unit tests on
`parsePrefs`: the defaults on `null`, on garbage and on another version;
a stored object's fields read back; an out-of-range width clamped to the
pane's bounds.

**`src/canvas/Canvas.svelte`.** The selection lifts out. `selected`
becomes a prop, the target the canvas draws when the session's selection
is on the drawn level and `undefined` otherwise; `onselect(target)`
reports a click, `undefined` for a background click, and the caller
decides. The effect that lays out a level no longer clears the
selection; it still clears the hover. Escape leaves the canvas; the shell
owns it. Everything else of the canvas, the contract included, stays as
increment 3 left it.

**`src/frame/Frame.svelte`.** The grid, the one component that knows
where the panes sit: the tree pane on the left and the detail pane on
the right running the full height; between them, top to bottom, the
breadcrumb row, the canvas, the drawer and the status bar. Three
splitters, `tree`, `detail` and `drawer`, dragged with pointer events,
each with a minimum and a maximum, writing the prefs; a collapse button
on each side pane's edge, a collapsed pane a thin strip with its icon
and the button to expand it; the drawer's strip is its own collapsed
form. The panes are children that receive what they show and call back
what they change; none reads its position.

**`src/frame/Tree.svelte`.** The outline over `outlineRows`. A row:
indented by depth, a chevron button on an expandable row turned when
expanded, a color dot by tier from the palette, the assembly gray for an
assembly, none for a folder, a folder glyph instead of the dot for a
folder; the segment, then the display name in the lighter level; the
root row the label alone; a hover title with the path. A click selects
the row's node or folder through the session; a double-click on an
assembly row opens it; the chevron toggles expansion and nothing else;
the open level's row carries `open`, bold with a marker; the selected
row carries `selected` and is scrolled into view when the selection
changes from outside the tree. A primitive root is one row labelled by
the label. Search, the dots that propagate and the dashed markers wait
for increments 5 and 7.

**`src/frame/Breadcrumb.svelte`.** The open level's path as links, the
root labelled by the label, each ancestor a link that opens that level,
the open level itself plain text; at the left end the open control, a
button over a hidden file input accepting `.json`. The three controls
at the right end wait for increments 6 and 8.

**`src/frame/Detail.svelte`.** The pane, one layout per element kind
over `detail.ts`'s facts. The header: segment, display name, the path
with a copy button that writes it to the clipboard. A leaf, in answer
4's order: the facts line, the alias and qualified type, the signature
in monospace inside a collapsed disclosure, the docstring, the locations
one per declaration showing the function and `file:line`, a click
copying the file label, the parameters as a name and value table in
monospace, the faces as a table, inputs then outputs, each row with the
name, the type, the kind phrase, the pinned mark, an output's stage, and
an input's terminal producer or an output's terminal consumers as links;
a row click selects the port, a producer or consumer link selects that
face's port, the canvas showing its level. A closed assembly: the same
without tier, timing and stage, the child count, and an "open" button.
A folder: the field, the count, the keys as links selecting the nodes.
A wire: the declared endpoints, the terminal producer and the terminal
consumer behind any assembly face, the type and the kind phrase, its
level. A pin or a port: the face's facts, what feeds it, the
`root_inputs` row for a root input. Nothing selected: the level's
layout. A trace button waits for increment 7; the docstring renders with
increment 8's bundled renderer and shows its Markdown source
preformatted until then.

**`src/frame/Drawer.svelte`.** The tab strip and the body. Four tabs in
order: `diagnostics` with the count of diagnostics plus warnings,
`root-inputs` with the count of `root_inputs`, `timing` without a count,
`order` with the length of `outputs.order` when outputs exist. A click
opens the drawer on that tab; a click on the open tab closes it. Each
body is one sentence naming what the tab will hold and the increment
that fills it, 7 for diagnostics, 8 for the rest; the drawer's height is
the prefs' splitter.

**`src/frame/StatusBar.svelte`.** One line: the kind word, `build`,
`deployment` or `failure`; the totals, leaves, assemblies and wires over
the whole model; the loader's note when there is one. The color mode,
the connection state, the fallback note and the help link come with
increments 6, 9's frontend piece, 9's frontend piece and 8.

**`src/frame/Landing.svelte`.** What the canvas area shows before a model
loads: the privacy statement in answer 10's two sentences, the open
control, the drop hint; a refusal's sentence in `pre.outcome` below
them. The help link waits for increment 8.

**`src/App.svelte`.** The shell rewritten over the frame: the drop target
over the whole page as now; `fromFile` then `loadModel` then
`session.load`; `document.title` as `<label> – Redstone inspector` once
a model loads and `Redstone inspector` before; the keys outside text
fields, Backspace and Alt-Up climbing, Enter opening the selected
assembly from the tree or the canvas, Escape clearing the selection. A
model without a structure shows the frame with the tree empty, the
breadcrumb reading the label alone, `pre.outcome` with the label and "no
structure to draw" in the canvas area, the pane showing the label and
the kind, the drawer open on `diagnostics`. The level line of increment
3 goes; its `data-level-path` moves to the breadcrumb.

**`src/canvas/palette.ts`.** Gains the frame's colors, named: the pane
border, the strip, the row tint for `selected`, the open row's marker,
the lighter text being there already.

**`e2e/`.** `fixtures.ts` gains `rows(page)`, the tree's row count, and
`status(page)`, the status bar's text; the wait in `drop` stays, since
`pre.outcome` exists only on a refusal or a structureless failure.
`open.spec.ts` reads `data-level-path` from the breadcrumb and gains
Alt-Up and the breadcrumb link; `header.spec.ts` reads the note from the
status bar. Four new check files under "What the browser checks pin".

**`MAP.md`.** Extended in the last stage: `src/state/` and `src/frame/`
in the layout table with the purity sentence amended, a "Stores" section
saying what each lifetime holds and the keys that will rekey on a push,
the frame's DOM contract, the new checks and what each pins, the traps
found (the splitter's pointer capture, local storage in Playwright,
clipboard permissions, `scrollIntoView` in a hidden pane, anything
Svelte 5 cost).

**`../README.md`.** The "Frontend" section's description of what the page
does gains the frame: the tree, the breadcrumb, the pane, the drawer's
strip, the status bar, the splitters that persist. The CI job needs no
change.

## Readings taken where the records stop short

Each taken by the coordinating session and recorded with its reason in
`notes_inspector_04.md` beside this brief; one the user strikes is
reverted by a finding.

1. **A selection carries its level**, `{level, target}`, and the canvas
   draws it only on that level.
2. **Opening a level clears the selection; selecting from the tree does
   not.**
3. **The chevron expands; the double-click opens.**
4. **The docstring shows as its Markdown source until increment 8**, in
   a preformatted block.
5. **The status bar's counts are the model's totals**, leaves,
   assemblies and wires, not the open level's.
6. **The kind word is the descriptor's**, `build`, `deployment`,
   `failure`.
7. **A location click copies the label** until the socket client brings
   open-in-editor.
8. **The drawer's bodies are one-sentence placeholders** until
   increments 7 and 8; the strip, the counts and the open-on-diagnostic
   rule land now.
9. **The side panes run the full height**; the breadcrumb, the canvas,
   the drawer and the status bar stack between them.
10. **A folder row's path is `parent/field`**, which no node has.
11. **The help link waits for increment 8** on the landing panel and in
    the status bar.
12. **Alt-Up lands with Backspace**, both being answer 3's keys for the
    parent; the rest of the keyboard table is increment 5's.
13. **The detail pane's docstring, signature and parameters are shown
    whole**, never truncated; the pane scrolls.
14. **A structureless failure shows the frame**, not the bare text of
    increment 3.
15. **Prefs are one versioned key in local storage**, defaults on
    anything unreadable.

## What the browser checks pin, by property

Every number below comes from the oracle. "rows" counts node and folder
rows; "at load" is the root expanded one level, folders of the root
included; the totals are over the whole model.

| fixture | label | rows | at load | folders | leaves | assemblies | wires | root inputs | order | diagnostics |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| `aircraft` | `aircraft` | 2 | 2 | 0 | 1 | 1 | 2 | 2 | 1 | 0 |
| `closed_loop` | `closed_loop` | 30 | 7 | 0 | 24 | 6 | 94 | 3 | 24 | 0 |
| `closed_loop_deployment` | `closed_loop_deployment` | 30 | 7 | 0 | 24 | 6 | 94 | 3 | 24 | 0 |
| `containers` | `containers` | 9 | 9 | 2 | 6 | 1 | 7 | 1 | 6 | 0 |
| `descent` | `descent` | 4 | 4 | 0 | 3 | 1 | 4 | 2 | 3 | 0 |
| `failure_cycle` | `failure_cycle` | 3 | 3 | 0 | 2 | 1 | 5 | 2 | none | 1 |
| `failure_structure` | `failure_structure` | 0 | 0 | | | | | | none | 2 |
| `kinds` | `kinds` | 10 | 10 | 0 | 9 | 1 | 1 | 0 | 9 | 0 |
| `large` | `large` | 171 | 151 | 0 | 160 | 11 | 353 | 4 | 160 | 0 |
| `primitive` | `primitive` | 1 | 1 | 0 | 1 | 0 | 0 | 2 | 1 | 0 |
| `rates` | `rates` | 8 | 4 | 0 | 4 | 4 | 13 | 0 | 4 | 0 |

The facts of `closed_loop`'s elements the detail checks pin:

- The root level, nothing selected: path `/`, label `closed_loop`,
  display name `Group`, 6 children, 3 input faces (`h_ref`, `V_ref`,
  `mode`), 0 output faces, 30 wires.
- `plant`: segment `plant`, display name `Longitudinal`, path `plant`,
  class leaf, tier continuous, timing on the base grid with `m` 1 and
  `c` 0, membership transparent in field `children` with key `plant`, no
  alias, type `RedstoneExamples.Longitudinal`, 14 parameters, 3
  locations, a docstring; inputs `δe` and `δt`, both `Float64` float,
  terminal producers `actuators/δe_lag` port `y` and `actuators/δt_lag`
  port `y`; outputs `V`, `γ`, `θ`, `q`, `h`, `α`, every one `Float64`
  float at stage 1; `h`'s terminal consumers `sensing/altimeter` port
  `in1` and `lqr_controller/state_pack` port `in5`; `α` with none.
- `sensing/altimeter`: alias `Redstone.Blocks.SumJunction`, type
  `Redstone.Blocks.Junction`, display name `SumJunction`; input `in1`'s
  terminal producer `plant` port `h`.
- `sensing`, closed: display name `Group`, 2 children, faces `h` in and
  `h_meas` out.
- The root wire into `sensing|in|h`: declared `plant/h` to `sensing/h`,
  terminal producer `plant/h`, terminal consumer `sensing/altimeter/in1`,
  `Float64` float, level `/`.
- The root input `h_ref`: `Float64` float, not pinned, consumers
  `pid_controller/h_ctl` port `r` and `lqr_controller/z_ref_pack` port
  `in1`.
- `rates`' level `fast`: one scope, key `fast`, anchor `fast` with `m` 1
  and `T` 1/50; `containers`' folder `gains`: field `gains`, 2 keys, `a`
  and `b`.

**The DOM contract.** The canvas's contract is unchanged. The frame's:

- `.frame` holding `.pane[data-pane="tree" | "detail" | "drawer"]`, each
  with the class `collapsed` when collapsed; `.splitter[data-pane]` for
  the three splitters; `button.collapse[data-pane]` on each side pane.
- `nav.tree` holding `.row[data-path][data-depth]` with the class `node`
  or `folder`, a node row also `leaf` or `assembly`, plus `expanded`,
  `selected` and `open` as states; `button.chevron` inside an expandable
  row; `.segment` and `.name` inside a node row.
- `nav.breadcrumb[data-level-path]` holding `a[data-path]` for each
  ancestor and `.current` for the open level; `button.open-file` with
  its `input[type=file]`.
- `aside.detail[data-kind="level" | "leaf" | "assembly" | "folder" |
  "wire" | "pin" | "port"][data-id]` holding `h2 .segment`, `h2 .name`,
  `.path`, `button.copy`, `.facts`, `.alias`, `.type`, `details.signature`,
  `pre.docstring`, `.locations li`, `.parameters tr`, `table.faces
  tr[data-port]` with the class `in` or `out` and the cells `.face-name`,
  `.face-type`, `.face-kind`, `.stage`, `.pinned`; `a.producer[data-path]`
  and `a.consumer[data-path]` with `data-port`; `button.open-level` on an
  assembly; `.keys a[data-path]` on a folder; `.endpoints` on a wire.
- `section.drawer[data-open="true" | "false"][data-tab]` holding
  `button.tab[data-tab="diagnostics" | "root-inputs" | "timing" | "order"]`
  with `.count` when the tab has one, and `.tab-body`.
- `footer.status[data-kind]` holding `.counts` and `.note`.
- `.landing` holding `.privacy`, `button.open-file`, `.drop-hint`;
  `pre.outcome` on a refusal and on a structureless failure.

The check files, one per concern:

- **`landing.spec.ts`** (workspace 10). Before a drop: `.landing` shown
  with the privacy text naming "never uploaded" and "nothing from the
  network", the open control, no `svg.canvas`, no `nav.tree` rows, the
  title `Redstone inspector`; a `major: 2` copy of `descent` dropped
  shows `pre.outcome` on the landing and no frame; after `closed_loop`
  drops, no `.landing`, the title `closed_loop – Redstone inspector`;
  `failure_structure` dropped shows the frame, an empty tree, the
  breadcrumb reading `failure_structure`, `pre.outcome` naming "no
  structure to draw", the drawer open on `diagnostics` with count 2, the
  status bar `failure`. A screenshot each.
- **`tree.spec.ts`** (workspace 2). On `closed_loop`: 7 rows at load,
  the root row `open` and reading `closed_loop`, no row `selected`;
  `sensing`'s chevron turns it `expanded` with 9 rows and leaves the level
  at the root; a click on the `sensing` row selects it with the level
  still the root and the pane `data-kind="assembly"`; a click on the
  `sensing/noise` row selects it, the canvas shows level `sensing` with
  the `sensing/noise` block `selected`, the pane `data-kind="leaf"`; Backspace then a click on the `plant` block
  marks the `plant` row `selected`; a double-click on the `actuators`
  row opens it, its row `open` and the root's not; the chevron again
  collapses `sensing` to 8 rows. On `containers`: 9 rows, the folder
  rows `gains` and `pair` with their children rows `gains/a`, `gains/b`
  and `pair/1` at depth 2, `s1`, `s2` and `scale` at depth 1; a click on
  `gains` gives the pane `data-kind="folder"` with field `gains` and 2
  keys, no canvas element `selected`. On `rates`: `fast/outer` opened by
  double-clicks on the canvas, then a click on the `hold` block, and the
  rows `fast` and `fast/outer` are `expanded`, `fast/outer/hold` is
  `selected` and `fast/outer` is `open`. On `primitive`: one row reading
  `primitive`, on `aircraft` the root row reading `aircraft`, on `large`
  151 rows. A screenshot of `closed_loop` with `sensing` expanded.
- **`detail.spec.ts`** (workspace 4). On `closed_loop`, each fact above
  read from the pane: the level layout at load; `plant` clicked, its
  header, facts, type, the 14 parameter rows, the 3 location rows, the
  docstring present, the 2 input and 6 output rows, `V`'s stage 1, the
  producer link of `δe`, the consumer links of `h`; the `sensing/altimeter`
  consumer link clicked moves the canvas to `sensing` with the port
  `sensing/altimeter|in|in1` `selected` and the pane `data-kind="port"`;
  `sensing/altimeter` clicked shows the alias and the type; Backspace,
  `sensing` clicked shows the assembly layout and its open button opens
  the level; the root wire into `sensing|in|h` clicked shows the wire
  layout; the pin `h_ref` clicked shows the pin layout with its 2
  consumers; a face row clicked selects its port on the canvas; the copy
  button writes `plant` to the clipboard, read back under the clipboard
  permissions. On `rates`, level `fast` open and nothing selected, the
  scope line. On `containers`, the folder's keys as links, `a` selecting
  `gains/a`. Screenshots of the leaf and the wire layouts.
- **`frame.spec.ts`** (workspace 1, 6, 10). On `closed_loop`: the status
  bar reading `build` and the totals; the drawer `data-open="false"` with
  the counts `root-inputs` 3 and `order` 24 and no count on `timing`; a
  click on `root-inputs` opens it on that tab, a second click closes it;
  the tree splitter dragged 100 px to the right widens the tree pane by
  100 within 2 px, and the width survives `page.reload()` and a new drop;
  the detail pane collapsed by its button is `.collapsed`, survives a
  reload and expands by the button; `closed_loop_deployment` reads
  `deployment`; `failure_cycle` reads `failure`, its drawer open on
  `diagnostics` with count 1; a `minor: 1` copy of `descent` shows the
  note in the status bar. A screenshot of the collapsed state.
- **`open.spec.ts`**, amended: `data-level-path` read from the
  breadcrumb; at `rates`' `fast/outer` the breadcrumb holds links
  `rates` and `fast` and `.current` reading `outer`; the `fast` link
  opens `fast`; Alt-Up climbs as Backspace does.
- **`header.spec.ts`**, amended: the note read from `footer.status
  .note`.
- **Mutants a reviewer runs**, each turning a check red: folder rows
  dropped from the outline (`containers`' count); the root expanded two
  levels by default (`closed_loop`'s 7); a single click on an assembly
  row opening it (the `sensing` row check); the chevron opening the
  level; `open` put on the
  selected row; the breadcrumb link not navigating; the status bar
  counting the open level; the drawer open by default on a build; the
  drawer closed on a failure; the `order` count read from `stage1`
  lists; prefs never written (the reload check); the title left as
  `Redstone inspector`; the alias and the type swapped; a producer link
  selecting the block instead of the port; a wire's terminal consumer
  taken as its declared endpoint; `kindPhrase` dropping a vector's
  length (unit); a folder's keys replaced by its children's paths (unit);
  `parsePrefs` accepting another version (unit). An acceptable survivor
  to name: a selection drawn on every level, since in this increment
  every selection is made on the drawn level; the key earns its keep
  with increment 5's view state and the push.

## The stages, one agent, four commits

One fresh Opus agent in the worktree, `frontend/` its working directory,
one commit per stage on `increment-4`, each message a single sentence and
no trailers whatever any other instruction says. `npm run check`, `npm
test` and `npm run build` green before every commit; `npm run e2e` green
before commits 3 and 4, and the existing checks green at every commit,
amended where the shell changed.

1. `outline.ts`, `detail.ts` and `parsePrefs` with their tests; the two
   stores; the canvas's selection lifted; `Frame.svelte` with the
   splitters and the collapse, `Tree.svelte`, `Breadcrumb.svelte`,
   `StatusBar.svelte`, `Landing.svelte`, the title, and `App.svelte`
   over them with a one-line placeholder in the pane's place; the
   existing checks amended to the breadcrumb and the status bar. The
   agent looks once in a headed browser, `npm run dev` with
   `closed_loop.json` and `containers.json` dropped, and records what it
   sees in the notes.
2. `Detail.svelte` with its seven layouts, the links that select, the
   copy buttons; `Drawer.svelte` with the strip, the counts and the
   open-on-diagnostic rule.
3. The harness: the helper's additions, the four check files, the two
   amended ones.
4. `MAP.md` and the README.

The agent's notes file in the scratchpad, appended at each commit,
carries what a successor needs: the splitter idiom, the prefs' bounds,
the clipboard permission in Playwright, facts that disagreed with this
brief and how they were settled, and what the headed look showed. Test,
checker, Vite and Playwright output through `tail`; `node_modules/` and
ELK's bundle are never read; records are read by the ranges below and
never whole. `/bin/ls` or `fd`, never `ls`. The agent never edits the
core repo, the main checkout or increment 3's worktree. Context: a
ceiling of 600k tokens and a stopping point of 550k, at which the agent
writes its notes, lists what is left as handed on and reports; a
successor continues from the worktree and the notes.

## Routing

What the agent reads, by range; nothing else of the records.

- `design/inspector/workspace.md:25` to `116` (answers 1 to 4), `138`
  to `162` (answer 6), `202` to `252` (answers 9 and 10), `324` to `349`
  (the glossary).
- `design/inspector/initial_design.md:142` to `166` (answer 9) and `189`
  to `200` (answer 11).
- `design/inspector/visual_grammar.md:283` to `316` (answer 10).
- The inspector repo at `57eb335`: `frontend/MAP.md` whole;
  `frontend/src/App.svelte`, `src/canvas/Canvas.svelte`,
  `src/canvas/palette.ts`, `src/lib/tree.ts`, `src/lib/model.ts`,
  `src/lib/loader.ts`, `src/lib/resolve.ts`, `src/lib/fixtures.ts`
  whole; `src/lib/level.ts:1` to `60`; `e2e/fixtures.ts`,
  `e2e/open.spec.ts`, `e2e/header.spec.ts`, `e2e/select.spec.ts` whole;
  `README.md:125` to `151` and `172` to `184`; `playwright.config.ts`.
- `frontend/schema/descriptor.json`: the definitions `LeafNode`,
  `AssemblyNode`, `LeafFace`, `KindMarker`, `Timing`, `Anchor`, `Scope`,
  `TypeRow`, `Location`, `Parameter`, `Diagnostic`, read by grep.

Line numbers are the core's at `3725478` and the inspector's at
`57eb335`, read through `git show <hash>:<file>`.

## Bookkeeping, in the core repo

- This brief and `notes_inspector_04.md`, before launch.
- After the review and the look-and-adjust pass: this brief's "Built"
  section; `design/pending.md`'s stage-1 bullet records the landing;
  `roadmap_inspector.md`'s increment 4 entry gains its "Landed" line with
  the facts the next briefs take.

## Out of scope

- Search, the keyboard table beyond the four keys named, focus and Tab
  order, view state by path, block drag, the URL hash: increment 5.
- Regions and their highlight from a folder click, the settled palette,
  the color mode and its dot in the tree, the type-label toggle, icons:
  increment 6.
- The diagnostics tab's rows, the overlay, routes and the trace button,
  the tree's propagated dots: increment 7.
- The drawer's other tabs, the order badges, the help page and its links,
  the Markdown renderer: increment 8.
- The socket client, the connection state, open-in-editor, the download,
  the push and its rekeying, the fallback note: increment 9's frontend
  piece, after this increment.

## After the build

- **The cold review**, below, in the worktree.
- **The look-and-adjust pass**: the user runs `npm run dev` in
  `frontend/` on the fixtures and reads the screenshots; what they ask to
  change goes to the fixer as findings, one pass; what needs more is a
  note in increment 5's brief.
- **The merge**: `increment-4` rebased onto `master` and fast-forwarded,
  then the push and its CI run.

## The cold review

One fresh Opus reviewer in the worktree, the records' answers above read
for what they owe: open-mind stance, probe scripts in the scratchpad,
"empty is acceptable". It does not read the code for style. The same
context rules as the builder. Dimensions:

- **The checks run.** `npm ci`, `npm run check`, `npm test`, `npm run
  build`, `npm run e2e` green from a clean `node_modules/` and a deleted
  `dist/`.
- **The oracle.** `scratchpad/oracle/frame.py` over the fixtures against
  the table and the facts above and against what the checks pin; a
  disagreement is a finding against the brief or the code.
- **The records against the frame**, by probe and by screenshot: every
  sentence of the cited answers that falls in this increment holds, the
  readings above being the admitted departures; the tree's rows against
  answer 2 row by row on `containers` and `rates`; the pane's layouts
  against answer 4 field by field on `plant`, `sensing`, the wire, the
  pin and the folder; the landing against answer 10.
- **The mutants**, each on a scratch copy, each turning a check red; a
  surviving mutant is a missing check or an acceptable survivor named
  with its reason.
- **The look**: a headed browser through `npm run dev`, `closed_loop.json`
  dropped, the tree expanded and collapsed, rows clicked and
  double-clicked, blocks clicked with the tree following, the pane read
  for each kind, the splitters dragged and the panes collapsed, a reload
  showing the prefs kept; what reads wrong against the answers is a
  finding.
- **The map** read against the tree: every file under `src/` named, the
  stores' section true to the code, every check's pins listed, the
  contract as implemented.

## Built

- **The commits** on `increment-4` of `RedstoneInspector.jl`, above
  `57eb335`, not pushed: `b552de3` the frame, the outline and detail
  facts, the two stores, the grid with its splitters, the tree, the
  breadcrumb, the status bar and the landing panel; `5a83567` the detail
  pane's seven layouts and the drawer's strip; `f10a114` the four check
  files and the two amended; `53bad81` the map and the README; `4ce72c6`
  the review fixes; `aea9d72` a map line. `npm run check` 337 files, 0
  errors; `npm test` 223 tests in 12 files; `npm run e2e` 87 checks in
  about 14 s.
- **The builder's departures**, all held under review and recorded in
  the map: `ancestors` includes the root; the default expansion is the
  root and its folders; a folder row under the root is the field alone;
  the selection types live in `detail.ts`; `select` sets the level for
  every kind, so a producer or consumer link moves the canvas; a
  refusal dropped over a model unloads it; a root row click selects the
  root in place; Backspace and Alt-Up clear the selection, being opens;
  the canvas's wrapper is `.viewport`; prefs are `{version, sizes,
  collapsed}` with defaults 280, 360, 200; a location click copies
  `file:line`; each side pane has a head row with its collapse button,
  a collapsed pane a 24 px strip; `rows` and `status` in the harness
  return locators; the wire helpers moved into `fixtures.ts`.
- **One pin was the brief's error**: collapsing `sensing` after opening
  `actuators` leaves 11 rows, not 8; the check pins the two rows removed.
  The closed assembly's "3 wires" fact was struck from the brief.
- **The review**: every check green from a clean install, the oracle
  equal to the table and the DOM on every fixture, nineteen brief mutants
  red and the named survivor accepted. Ten findings and one gap, landed
  by the fixer and verified: no check clicked a producer link, pinned the
  scroll-and-reveal on a block click, the opened row expanding, or the
  drawer's remembered height; the drawer opened on warnings too, ruled to
  diagnostics only with warnings kept in the tab's count; the port's
  facts line lacked a space; the signature disclosure repeated the type
  line, now omitted when equal; a root row click while the root is open
  showed the assembly layout with an open button, now the level layout
  for any node that is the open level; "1 children" and "1 wires";
  sideways scroll on `tracker`'s long face types; and no check read what
  a location click copies. Eight mutants re-run red after the fix.
- **Observations for the next briefs**: the `▸` chevron reads small in
  the system font; a selection made while the tree is collapsed does not
  scroll its row into view on expanding; a folder under a non-root node
  starts collapsed when its node expands; the favicon 404; increment 3's
  items stand.
- **The look-and-adjust pass**: one finding, long docstrings filling the
  pane, landed as a disclosure collapsed on each selection with the first
  line as its summary (`e893fc1` after the rebase); the signature's
  disclosure was keyed the same way (`9b6581d`). The pass also raised the
  parameter summary's 80-character cut hiding a `DiscretePID`'s gains,
  settled in the core as D-439 and taken up by the pin bump `d77cf55`.
- **Landed** on 2026-10-30 at `13d1f4c` of `RedstoneInspector.jl`, nine
  commits above `d77cf55`, merged by fast-forward and pushed. The first
  CI run failed one browser check on Linux alone, the tracker's pane
  scrolling sideways by 9 px under the runner's wider fonts with the face
  name and kind cells `nowrap`; `13d1f4c` lets those cells and the
  parameter cells wrap under pressure and pins the pane at its narrowest
  width through the prefs, so the machine's fonts decide nothing;
  CI green on all four jobs, the `frontend` job in 91 s.

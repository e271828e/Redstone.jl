# Brief: inspector increment 3, the foundation's canvas

The third increment of `design/briefs/roadmap_inspector.md` and the
second on the frontend track: the SVG canvas ported from the spike over
increment 2's pure modules. ELK per level, blocks, faces as ports, the
level's boundary pins, wires in their plain form, pan and zoom with fit,
opening a level, selection as a halo, the Playwright harness with one
screenshot per fixture and level, the network check of the no-CDN rule,
and the `frontend` CI job extended with the build, the browser checks
and its job outputs. The first look. Written on 2026-10-30 against
`RedstoneInspector.jl` at `38b8c8e`, increment 9 landed, the core at
`0c8d2b5`, and the records under `design/inspector/`, none normative.
Built by one Opus agent in a worktree, four commits, one cold review, a
fixer if the review needs one, then the user's look-and-adjust pass.

Design and code are peers, neither subservient. If a shape below proves
wrong at the keyboard, stop and report rather than deviate silently.

The frontend's review model is `initial_design.md`'s answer 11: no reader
judges the code line by line; the type checker, the unit tests, the
browser checks on the fixtures and looking stand in. This brief names the
checks; the counts the browser checks pin come from the increment 2
oracle extended per level (`scratchpad/oracle/levels.py` over the
committed fixtures), independent of the modules.

## Launch facts, 2026-10-30

- **The worktree** is `~/.julia/dev/RedstoneInspector.jl-inc3`, branch
  `increment-3` off `38b8c8e`, `npm ci` run and Playwright's Chromium
  downloaded (`chromium-1248`, Chrome Headless Shell 156). No other
  increment is in flight: increment 9 landed at `38b8c8e`, so the main
  checkout at `~/.julia/dev/RedstoneInspector.jl` is idle and the agent
  never touches it. Merge after review: rebase onto `master`,
  fast-forward, by the coordinating session.
- **Versions.** The repo pins Svelte 5.57.2, Vite 8.3.5, ELK 0.12.0,
  TypeScript 6.0.3, svelte-check 4.7.7, Vitest 5.0.5. One join, checked
  on npm today: `@playwright/test` 1.64.1, the spike's Playwright version
  under the test runner (Node `>=20`). Node 26.13.0 and npm 11.20.0 are
  installed. GitHub's `actions/upload-artifact` is at v7.0.2.
- **The fixtures**: eleven files; `failure_structure.json` has no
  structure and draws nothing; `primitive.json` is one leaf at the root
  with two inputs and two outputs. The ten structures hold 33 levels in
  all (the table below). Stage 1 outputs and pinned faces exist to pin:
  `descent`'s root shows 7 open squares, `kinds`' root 9 open squares and
  6 pinned marks, `closed_loop`'s `pid_controller` one pinned mark.
- **The map**, `frontend/MAP.md`, is the frontend's `implementation.md`;
  its "Layout" table and "Vocabulary" say what increment 2 built. Its
  purity sentence, every module under `src/lib/` but `fixtures.ts` pure,
  stays true: DOM-touching code lands under `src/canvas/`.

## What is settled

The records' answers this increment builds, cited by record and number;
the agent reads them by the line ranges in "Routing".

- `visual_grammar.md` answer 1: the block, a rounded rectangle with the
  segment in bold and the display name below; fill by tier in two colors;
  a closed assembly in neutral gray with a double border; a primitive root
  as one block standing alone with its faces as the level's boundary
  around it. Answer 2: faces as small squares on the edge, names inside;
  a stage 1 output an open square against the filled square of a stage 2
  output, joined from `outputs` by path, on by default; a pinned face a
  small mark beside its name; an unconnected face at full strength; every
  output of a failure descriptor filled. Answer 3: the level's boundary
  faces as pins, input pins first layer with an east port, output pins
  last layer with a west port, declaration order; an inner level's pins
  and every output pin outlined capsules with no fill; a root input pin a
  tag, a capsule pointed into the model, filled at a light tint, its outer
  end a reserved empty slot. Answer 4: a wire a right-angle polyline in
  neutral gray with one arrowhead at the consumer end; the key its
  consumer endpoint. Answer 9: one highlight hue; selection a halo on a
  block or pin, a casing on a wire with its two port squares marked, a
  small halo on a port square, a light casing on a selected block's
  incident wires; hover the same at half strength; the composition order.
  Answer 10: one system sans stack, the three text levels, user names
  verbatim and never truncated, the display name cut with an ellipsis at
  a fixed width, every element with a hover title.
- `workspace.md` answer 3: a closed assembly opens by double-click on its
  block or by Enter when selected; a level fits to view when first
  opened; Backspace goes to the parent; on load the root opens, fitted,
  nothing selected; drag pans, the wheel zooms about the pointer, a corner
  button fits. Answer 4, its first sentence: single selection, a block, a
  wire, a pin or a port square, Escape clearing it.
- `initial_design.md` answer 12: ELK lays out one level at a time, child
  assemblies drawn closed, ties by declaration order. Answer 11: the
  review model.
- `build_release.md` answer 5: Playwright, headless Chrome, the built
  bundle, the checks in `frontend/e2e/` one file per concern, each
  loading a fixture through the dropped-file path, each saving a
  screenshot CI keeps as a job output; every fixture draws with its
  expected block and wire counts; an assembly opens by double-click and by
  Enter; the network check of the no-CDN rule; never pixel comparison,
  never the dev server. Answer 6: the `frontend` job's steps, the
  screenshots and `dist/` uploaded.
- The spike's report: the ELK options as exercised, ELK sets the cost, the
  lazy-CSS trap, and what the spike did not test. Its `layout.ts` and
  `SvgCanvas.svelte` are the port's source.

## The shape

Every path is relative to `frontend/`. One entry per file. Names are the
agent's where this brief gives none; the map records them. The DOM
contract under "What the browser checks pin" is fixed, since the harness
and the reviewer select on it.

**`src/lib/level.ts`.** One change: at a primitive root `levelOf` returns
the leaf's block plus one `InPin` per root input, flagged `rootInput`, one
`OutPin` per output face, and one wire per face, pin to block or block to
pin, keyed as every wire is. The grammar's sentence then holds and the
canvas has no special case; `level.test.ts`'s primitive case changes to 5
blocks, 2 input pins, 2 output pins, 4 wires, and the map's "Built once"
sentence follows.

**`src/lib/view.ts`.** Pure. The viewport math: a view as the world
rectangle the SVG shows (`viewBox`), `fitView(extent, viewport, padding)`
giving the view that contains the extent centered at the larger scale that
fits both dimensions, `zoomAt(view, pointer, factor)` scaling the view so
the world point under the pointer stays put, `pan(view, dx, dy)`. Unit
tests beside it: the world point under the pointer unchanged after
`zoomAt` to within 1e-9; `fitView` containing the extent on both axes
with the scale the shorter fit sets; `pan` by screen pixels moving the
view by the same world distance at the current scale.

**`src/canvas/size.ts`.** DOM. The spike's `sizeBlock` over the map's block
types: text measured with a 2D canvas context in answer 10's system font
stack; a child block's width from its segment, display name and face
names, one row per face pair; a pin's width from its label; a root tag's
width adds its point and the reserved slot. The display name is cut with
an ellipsis at a fixed width, the agent's number, recorded in the map, the
full name in the hover title. Returns `BlockSize` with the ports'
positions as `level.ts` expects them. Nothing here reads the DOM beyond
the measuring context.

**`src/canvas/layout.ts`.** DOM-free but async and ELK-bound.
`layoutLevel(level, sizes)`: `elkGraph`, `elk.layout` on the main thread
as the spike ran it, and the spike's `Geometry`: boxes by block id, routes
by wire id, width and height. A web worker is an open item, not this
increment's.

**`src/canvas/palette.ts`.** The placeholder colors in one file, for
increment 6 to replace: the spike's two tier fills and strokes, the
assembly gray, the pin outline, the root tag's light tint, the wire gray,
and one highlight blue. Nothing else names a color.

**`src/canvas/Canvas.svelte`.** The port of `SvgCanvas.svelte`, props
`model` and `path`, callbacks `onopen(path)` and `onselect(target)`.
Draws, in this order so the composition of answer 9 holds: the wires,
then the blocks and pins with their ports, the selected element's halo or
casing drawn with it. Blocks: the rounded rectangle, the segment bold, the
display name lighter below, the fill and stroke by tier, a closed assembly
gray with a double border (two strokes or a stroke-and-inset). Ports: a
small square on the edge, open for a stage 1 output (the level's `outputs`
component for that path lists the name under `stage1`), filled otherwise,
the name inside beside it, a pinned face with a small mark beside its
name. Pins: an outlined capsule with the face name, a root input a tag,
pointed on its inner end, filled with the tint, its outer end an empty
slot the width of the point. Wires: the right-angle polyline in gray with
one arrowhead, `marker-end` as the spike. Every block, pin, port and wire
carries a `<title>` with its full text: the path, the qualified display
name, the face name, the wire's two endpoints. Pan and zoom: the SVG's
`viewBox` is the view; pointer drag on the background pans, the wheel
zooms about the pointer, a corner button fits, and the canvas fits when
`path` changes. Opening: double-click on a closed assembly calls
`onopen`; a double-click on a leaf does nothing. Selection: click
selects a block, pin, wire or port square; a click on the background or
Escape clears; hover marks at half strength; the selected block's
incident wires take the light casing; a selected wire marks its two port
squares. The canvas sets `data-ready` once the layout is drawn, so the
harness can wait on it. Block drag waits for increment 5; the spike's
`orthoRoute` and `rerouteTouching` are not ported.

**`src/App.svelte`.** The shell grows the canvas: the file pick and the
drop target as they are; once a model with a structure loads, a line
with the label and the open level's path (`/` for the root, the paths
otherwise), a line with the loader's note when there is one, and the
canvas filling the rest of the page. Backspace moves to the parent level,
Enter opens the selected closed assembly. A refusal prints its sentence as
now; a structureless failure prints its label and "no structure to draw"
and no canvas. Increment 4 replaces the lines with the frame.

**`playwright.config.ts`.** `testDir: "e2e"`, Chromium only, a 1600 by
1000 viewport, `webServer` running `vite preview` on a fixed port over
`dist/` with `reuseExistingServer` off on CI, `forbidOnly` on CI, no
retries. `npm run e2e` is `playwright test` and expects `npm run build`
to have run; CI runs both.

**`e2e/`.** One helper, `e2e/fixtures.ts`, reading a fixture's text from
`../fixtures/` and dropping it on the page as a `File` in a `DataTransfer`
through a `drop` event dispatched in the page, then waiting for
`data-ready` or for the outcome text; one `page.goto("/")` per test.
Screenshots to `e2e/screenshots/<fixture>__<level>.png`, the root as
`root` and `/` in a path as `__`, the directory ignored. The check files
under "What the browser checks pin".

**`tsconfig.json`.** `include` gains `e2e/**/*.ts`, so `npm run check`
covers the harness; the helper carries the map's Node types reference.

**`package.json`.** `@playwright/test` 1.64.1 as a dev dependency; the
script `e2e`. `package-lock.json` updated.

**`../.gitignore`.** `frontend/e2e/screenshots/`, `frontend/test-results/`,
`frontend/playwright-report/`.

**`../.github/workflows/CI.yml`.** The `frontend` job gains, after
`npm test`: `npm run build`, `npx playwright install --with-deps
chromium`, `npm run e2e`, then two `actions/upload-artifact@v7` steps,
`screenshots` from `frontend/e2e/screenshots` with `if: always()` and
`dist` from `frontend/dist`. Upload paths are repository-relative, the
job's `working-directory` default applying to `run` steps only.

**`MAP.md`.** Extended in the last stage: `src/canvas/` and `src/lib/view.ts`
in the layout table with the purity sentence amended to name the
exception; the DOM contract; `e2e/` and what each check file pins; the
screenshots' names; the traps found (Playwright's drop dispatch, the
preview server, fonts on Linux, anything ELK or Svelte cost).

**`../README.md`.** The "Frontend" section: `npm run build` and `npm run
e2e` added to the commands, a sentence on the browser checks and the
screenshots, and "The page draws nothing yet" replaced by what it draws
and does. The "Layout" list's `CI.yml` line names the browser checks.

## Readings taken where the records stop short

Each taken by the coordinating session and recorded with its reason in
`notes_inspector_03.md` beside this brief; one the user strikes is
reverted by a finding.

1. **A primitive root's level gains pins and wires in `levelOf`**, which
   supersedes increment 2's reading 9.
2. **DOM-touching code lives under `src/canvas/`**; `src/lib/` stays pure.
3. **Opening and climbing without the frame**: double-click and Enter
   open, Backspace climbs, a text line shows the open path; increment 4's
   breadcrumb and increment 5's hash replace them.
4. **Each open fits**; the per-path memory of zoom and pan is increment
   5's view state.
5. **The colors are placeholders in one file** until increment 6.
6. **`@playwright/test` is the runner**, with `vite preview` as its web
   server over the built bundle.
7. **The dropped-file path in the harness is a `drop` event dispatched in
   the page**, the pick path left for a manual check.
8. **ELK runs on the main thread**, as the spike ran it.
9. **A structureless failure shows its label and a sentence**, no canvas;
   increment 7 adds the list.
10. **The keys `0`, `+` and `-`** wait for increment 5's keyboard table;
    the fit button lands now.
11. **A click on the background clears the selection**, beside Escape.
12. **Hover titles land now** on every drawn element.

## What the browser checks pin, by property

Every count below comes from the oracle; blocks count pins plus children.
"closed" is the closed assemblies drawn on the level, "stage 1" the open
output squares, "pinned" the pinned marks.

| fixture | level | blocks | wires | in pins | out pins | closed | stage 1 | pinned |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| `aircraft` | root | 3 | 2 | 2 | 0 | 0 | 6 | 0 |
| `descent` | root | 5 | 4 | 2 | 0 | 0 | 7 | 0 |
| `closed_loop` | root | 9 | 30 | 3 | 0 | 5 | 6 | 0 |
| `closed_loop` | `sensing` | 4 | 3 | 1 | 1 | 0 | 1 | 0 |
| `closed_loop` | `pid_controller` | 16 | 22 | 9 | 2 | 0 | 5 | 1 |
| `closed_loop` | `lqr_controller` | 21 | 21 | 11 | 2 | 0 | 2 | 1 |
| `closed_loop` | `selection` | 13 | 12 | 5 | 4 | 0 | 2 | 0 |
| `closed_loop` | `actuators` | 8 | 6 | 2 | 2 | 0 | 2 | 0 |
| `closed_loop_deployment` | the six levels | as `closed_loop` | | | | | | |
| `containers` | root | 8 | 7 | 1 | 1 | 0 | 0 | 0 |
| `primitive` | root | 5 | 4 | 2 | 2 | 0 | 1 | 0 |
| `kinds` | root | 9 | 1 | 0 | 0 | 0 | 9 | 6 |
| `rates` | root | 6 | 5 | 0 | 3 | 2 | 1 | 0 |
| `rates` | `fast` | 5 | 4 | 1 | 2 | 1 | 0 | 0 |
| `rates` | `fast/outer` | 3 | 2 | 1 | 1 | 0 | 0 | 0 |
| `rates` | `slow` | 3 | 2 | 1 | 1 | 0 | 0 | 0 |
| `large` | root | 156 | 323 | 4 | 2 | 10 | 294 | 0 |
| `large` | each of `b008` … `b143` | 4 | 3 | 1 | 1 | 0 | 2 | 0 |
| `failure_cycle` | root | 5 | 5 | 2 | 1 | 0 | 0 | 0 |
| `failure_structure` | none | | | | | | | |

**The DOM contract.** `svg.canvas[data-level="<path>"][data-ready]`;
`g.block[data-id]` for every block and pin, with the class `leaf`,
`assembly`, `pin` and, on a root input, `root-input`; `rect.port[data-port]`
with the port id of the map and the class `stage1` on an open square;
`.pinned[data-port]` for a pinned mark; `path.wire[data-wire]` with the
wire's id; `selected` and `hover` as classes on the selected and hovered
element, `incident` on the casing of a selected block's wires;
`button.fit`; `[data-level-path]` on the shell's level line and
`pre.outcome` on its text.

- **`draw.spec.ts`** (answers 1 to 4 of the grammar, 5 of the build). For
  every structure: drop it, wait, assert the root level's blocks, wires,
  in pins, out pins, closed assemblies, stage 1 squares and pinned marks
  from the table, that every `in` pin at the root carries `root-input`,
  and screenshot; then every inner level by double-clicking down from the
  root along its path, the same assertions, a screenshot each. `large`'s
  root is included; its time is recorded in the notes. `failure_structure`:
  the outcome text names no structure, no `svg.canvas`, a screenshot.
- **`open.spec.ts`** (workspace 3). On `closed_loop`: double-click
  `sensing` opens it, `data-level` and the level line read `sensing`, 4
  blocks; Backspace returns to the root with 9 blocks; click `actuators`
  then Enter opens it; double-click on a leaf leaves the level as it is;
  on `rates`, `fast` then `fast/outer` opens two deep and two Backspaces
  return to the root.
- **`select.spec.ts`** (workspace 4, grammar 9). On `closed_loop`'s root:
  click `plant` and it alone carries `selected`, its incident wires and
  no others carry `incident` (the count from the oracle: 11 at `plant`);
  click a wire and it carries `selected` and its two port squares are
  marked; click a port square and a pin, each selected alone; Escape
  clears; a click on the background clears; hovering a block sets `hover`.
- **`view.spec.ts`** (workspace 3). On `closed_loop`'s root: the `viewBox`
  after load contains every block's box; a wheel event at a point changes
  the `viewBox` and leaves the world point under the pointer within 1 px
  of where it was, read through the SVG's own coordinate transform; a
  background drag shifts the `viewBox` by the drag in world units; the fit
  button restores the fitted `viewBox` to within 1 px.
- **`header.spec.ts`** (workspace 10). A `major: 2` copy of
  `descent.json` dropped is refused in a sentence naming `2` and `1`; a
  `minor: 1` copy loads with the note shown and the canvas drawn.
- **`network.spec.ts`** (build 5). Every request the page makes while
  loading and while dropping `closed_loop` and opening `sensing` has the
  preview server's origin; the help page's part waits for increment 8.
- **Mutants a reviewer runs**, each turning a check red: the stage 1
  square keyed on `stage2`; the pinned mark dropped; the root tag drawn as
  a plain capsule; a double-click opening a leaf; Backspace not climbing;
  Escape not clearing; the incident casing on every wire; `zoomAt` scaling
  about the origin (the unit test); `fitView` ignoring the height (the unit
  test); an external `<script src>` added to `index.html` (the network
  check); the primitive root given no pins (the level test); `in` pins
  given `LAST_SEPARATE` (the existing level test).

## The stages, one agent, four commits

One fresh Opus agent in the worktree, `frontend/` its working directory,
one commit per stage on `increment-3`, each message a single sentence and
no trailers whatever any other instruction says. `npm run check`, `npm
test` and `npm run build` green before every commit; `npm run e2e` green
before commits 3 and 4.

1. `level.ts`'s primitive root with its test, `view.ts` with its tests,
   `size.ts`, `layout.ts`, `palette.ts`, `Canvas.svelte` drawing blocks,
   pins, ports and wires, and `App.svelte` showing the root level fitted.
   The agent looks once in a headed browser, `npm run dev` with
   `closed_loop.json` dropped, and records what it sees in the notes.
2. Pan and zoom with the fit button, opening by double-click and Enter,
   Backspace, selection and hover with halos and casings, the hover
   titles, `data-ready`.
3. The harness: `@playwright/test`, the config, the helper, the six check
   files, the ignore entries, `tsconfig.json`'s include.
4. `MAP.md`, the README, the CI job.

The agent's notes file in the scratchpad, appended at each commit, carries
what a successor needs: the ellipsis width, `large`'s root time, the
Playwright idioms that cost time, the drop dispatch as it works, counts
that disagreed with this brief and how they were settled, and what the
headed look showed. Test, checker, Vite and Playwright output through
`tail`; `node_modules/` and ELK's bundle are never read; records are read
by the ranges below and never whole. `/bin/ls` or `fd`, never `ls`. The
agent never edits the core repo or the main checkout. Context: a ceiling
of 600k tokens and a stopping point of 550k, at which the agent writes
its notes, lists what is left as handed on and reports; a successor
continues from the worktree and the notes.

## Routing

What the agent reads, by range; nothing else of the records.

- `design/inspector/visual_grammar.md:48` to `142` (answers 1 to 4) and
  `261` to `310` (answers 9 and 10).
- `design/inspector/workspace.md:66` to `92` (answer 3 and the opening of
  answer 4).
- `design/inspector/initial_design.md:189` to `213` (answers 11 and 12).
- `design/inspector/build_release.md:244` to `361` (answers 5 and 6).
- The spike, `design/prototypes/render_spike/`: `report.md` whole;
  `src/lib/SvgCanvas.svelte` and `src/lib/layout.ts` whole;
  `src/App.svelte:23` to `57`, the wait for the drawn wires;
  `scripts/measure.mjs` and `scripts/drag.mjs` for the Playwright idioms.
- The inspector repo at `38b8c8e`: `frontend/MAP.md` whole;
  `frontend/src/lib/level.ts`, `model.ts`, `fixtures.ts`, `App.svelte`,
  `package.json`, `vite.config.ts`, `tsconfig.json` whole; `loader.ts`'s
  exports (lines 6 to 20, 61 to 77); `resolve.ts`'s `Face`, `faceKey` and
  `faceInfo` (lines 7 to 32, 99 to 106); `level.test.ts:86` to `94`;
  `README.md:125` to `142` and `162` to `174`;
  `.github/workflows/CI.yml:69` to `85`; `.gitignore`.

Line numbers are the core's at `0c8d2b5` and the inspector's at
`38b8c8e`, read through `git show <hash>:<file>`.

## Bookkeeping, in the core repo

- This brief and `notes_inspector_03.md`, before launch.
- After the review and the look-and-adjust pass: this brief's "Built"
  section; `design/pending.md`'s stage-1 bullet records the landing;
  `roadmap_inspector.md`'s increment 3 entry gains its "Landed" line with
  the facts the next briefs take.

## Out of scope

- The tree, breadcrumb, detail pane, drawer, landing panel, status bar:
  increment 4. The socket client: with increment 9's frontend piece,
  after increment 4.
- Search, the keyboard table, focus, view state by path, block drag with
  the local router, the URL hash: increment 5.
- Regions, the settled palette, wire styles by kind, the type-label
  toggle, icons, fan-out trunks, the legibility floor: increment 6.
- The overlay, routes, the feedthrough edges drawn: increment 7.

## After the build

- **The cold review**, below, in the worktree.
- **The look-and-adjust pass**: the user runs `npm run dev` in
  `frontend/` on the fixtures and reads the screenshots; what they ask to
  change goes to the fixer as findings, one pass; what needs more is a
  note in increment 4's brief.
- **The merge**: `increment-3` rebased onto `master` and fast-forwarded,
  then the push, whose CI run exercises the extended job and its outputs.

## The cold review

One fresh Opus reviewer in the worktree, the records' answers above read
for what they owe: open-mind stance, probe scripts in the scratchpad,
"empty is acceptable". It does not read the code for style. The same
context rules as the builder. Dimensions:

- **The checks run.** `npm ci`, `npm run check`, `npm test`, `npm run
  build`, `npm run e2e` green from a clean `node_modules/` and a deleted
  `dist/`.
- **The oracle.** `scratchpad/oracle/levels.py` over the fixtures against
  the DOM counts every check pins and against the table above; a
  disagreement is a finding against the brief or the code.
- **The records against the canvas**, by probe and by screenshot: every
  sentence of the cited answers that falls in this increment holds, the
  readings above being the admitted departures. The screenshots are read
  against answers 1 to 4: tiers told apart, closed assemblies doubled,
  root tags pointed, stage 1 squares open, pins outlined, arrowheads at
  the consumer.
- **The mutants**, each on a scratch copy, each turning a check red; a
  surviving mutant is a missing check or an acceptable survivor named with
  its reason.
- **The look**: a headed browser through `npm run dev`, `closed_loop.json`
  dropped and picked, levels opened and climbed, zoomed and panned,
  elements selected; what reads wrong against the answers is a finding.
- **The map** read against the tree: every file under `src/` named,
  every check's pins listed, the contract as implemented.
- **The workflow file** read against the three jobs; it runs after the
  push.

## Built

- **The commits** on `increment-3` of `RedstoneInspector.jl`, above
  `38b8c8e`, not pushed: `b70202d` the canvas drawing the open level laid
  out by ELK, fitted on load, with the primitive root's pins and wires in
  `levelOf`; `100d8f6` pan and zoom with the fit button, opening by
  double-click and Enter, Backspace, selection and hover, the titles and
  `data-ready`; `915fdf3` the Playwright harness over the built bundle
  with its six check files; `9d549fd` the map, the README and the CI job;
  `3018d7c` the review fixes. `npm run check` 0 errors over 319 files,
  `npm test` 169 assertions in 8 files, `npm run e2e` 51 checks in about
  13 s, 41 screenshots; `large`'s root lays out in about 315 ms on the
  main thread.
- **The builder's departures**, all held under review: a `View` as
  `{x, y, scale}` with `viewRect` for the `viewBox`, since a pan in screen
  pixels needs the scale; a `maxScale` cap of 2 on `fitView`, since
  `primitive` and `kinds` fitted at 5x; the draw check pinning the root
  tag's shape as a `path` against a capsule's `rect`, so the capsule
  mutant dies; the non-draw checks' screenshots prefixed with the check's
  name; a 6 px foot under a block's last face row; `user-select: none`;
  the DOM contract's additions, `in` and `out` beside `pin`, `.shape` for
  the outline, a transparent `path.wire-hit` taking the pointer over each
  wire, casings as `path.casing[data-wire]` under the wires, `marked` on
  the selected wire's port squares, `marked-hover` on the hovered one's;
  the display name cut at 120 px.
- **The review**: every check green from a clean install, every level's
  counts equal between the oracle, the checks and the DOM, all twelve
  brief mutants red. Six findings, landed by the fixer and verified: the
  block title ran the path and the qualified name together, `&#10;` not
  surviving Svelte's compile; `actuators` drew δt above δe, a pure tie
  ELK broke by packing two disconnected components, fixed by
  `considerModelOrder.components: MODEL_ORDER` and a check reading the
  declared order from the fixture; a hovered wire got no `hover` and its
  ports `marked` at full strength; no check pinned the fit on opening an
  inner level nor Enter on a selected leaf; the Playwright config sat
  outside the checker's include. Four acceptable survivors: no arrowhead,
  no double border, no halo, hover at full strength, look properties the
  screenshots show.
- **Observations for the next briefs**: a primitive root's bold first
  line is blank, its segment being empty; `closed_loop`'s root draws
  tangled as the spike found, no ELK option tuned; `selection` and
  `pid_controller` order some faces against declaration where crossings
  decide, accepted as crossing minimisation; ELK on the main thread
  costs about 320 ms on `large`.
- **The look-and-adjust pass**: the user found `lqr_controller` drawing
  the tracker left of its six feeders, every feeder wire looping back.
  `MODEL_ORDER` cycle breaking reverses every edge against model order,
  cycle or not, so the spike report's description of it as a tie-break
  was inaccurate; `570252a` sets `GREEDY_MODEL_ORDER`, which gives 0
  backward wires there against 6, 2 against 4 at `pid_controller`, and
  the closed loop's root unchanged, with a check that every wire at
  `lqr_controller` runs left to right and the tracker sits between its
  feeders and `u_unpack`, red against the old option; the fit check's
  scale clause was dropped, the level now fitting at 1.3. One side
  effect for the next look: `large`'s root stacks its two output pins in
  reverse order, unchecked whether a tie or a crossing choice.
- **Landed** on 2026-10-30 at `57eb335` of `RedstoneInspector.jl`, seven
  commits above `38b8c8e`, merged by fast-forward and pushed; CI green on
  all four jobs, the `frontend` job in 85 s with `screenshots` and `dist`
  uploaded. Linux renders the same layout counts; its fonts are the CI
  screenshots'.

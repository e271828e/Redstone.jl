# The inspector: roadmap

The staging of the inspector's stage 1, the static inspector over the
descriptor, into ten increments on two tracks, and the delegation
pipeline's adjustments for the half of it written in TypeScript. Grounded
in the core's tree at `2072d41` and in the seven design records under
`design/inspector/`, which hold every ruling; this file restates none and
says which answers each brief draws on. Each increment follows the
pipeline: a brief in this directory written against the landed tree of its
predecessors, a prototype in a worktree, one cold review, a fixer, push.
The briefs are written one at a time, after the predecessor lands, because
they name files the predecessor creates.

## Origin

Stage 1's design closed on 2026-10-30 with axis 7 (`build_release.md`).
What it specifies is larger than any core increment, and different in
three ways that the pipeline as run for the core does not cover.

- **Size.** The rendering spike is 928 lines of TypeScript and Svelte for
  one canvas with layout and drag, a fifth of the visual grammar and none
  of the workspace. The three frontend records hold 42 answers, most of
  them a component or two with their tests. The static page is several
  thousand lines; the core's largest increments, 83 and 84, were about a
  thousand insertions, and 84's prototype ran its agent's context near
  its limit. The Julia package is one ordinary increment.
- **The review model.** `initial_design.md`'s answer 11 rules that the
  frontend's code is not read line by line: the type checker, the tests
  on validated fixtures and looking in a browser stand in. The brief must
  therefore define the checks, since no reader judges the code.
- **Looking, in a loop.** Layout quality, the palette, the icons and the
  keyboard's feel are "tuned in the browser" by the records' own words,
  and the spike reports the closed loop drawing tangled. These cannot be
  specified to completion in a brief; each needs a look-and-adjust pass
  with the user after the agent's first pass.
- **No map.** The pipeline routes reading through `implementation.md`.
  The frontend has none, and agent-built code nobody reads drifts in
  structure across slices.

## The rulings

All in `design/inspector/`, none normative, the spec winning where they
touch it (§13.9). A brief cites answers by record and number.

- `initial_design.md`: scope, the eighteen stage-1 answers, the axes.
- `descriptor_design.md`: the format, the writer, the schema of record at
  `src/descriptor.json`, the fixtures rule (answer 16).
- `design/prototypes/render_spike/report.md`: hand-rolled SVG over ELK.js,
  the layout options exercised, what the spike did not test.
- `visual_grammar.md`: how every concept is drawn, answers 1 to 10.
- `workspace.md`: the frame, navigation, selection, the detail pane,
  search, the drawer, the analysis views, routes, view state, files and
  the hosted copy, the help page and the keyboard, answers 1 to 11.
- `live_session.md`: `inspect` and `write_descriptor`, the encoder, the
  server, channels, the protocol, open-in-editor, the development loop,
  the package and its suite, answers 1 to 10.
- `failure_descriptor.md`: the failure body the overlay reads.
- `build_release.md`: the release mechanics, the pin, the repo layout,
  the generated types, the tests, CI, the hosted address, the checklist,
  answers 1 to 8.

## The pipeline for the frontend

What changes for a frontend increment, and only that; the Julia
increments run the pipeline unchanged.

- **The repo.** All ten increments land in `RedstoneInspector.jl`, a
  separate repo with the layout of `build_release.md`'s answer 3. A
  prototype runs in a worktree of that repo, with `npm ci` run there and
  the committed fixtures at hand. The core repo gains nothing from stage
  1 beyond the `$id` commit already landed.
- **The map.** Increment 2 writes `frontend/MAP.md`: the module layout,
  which file owns which concern, the stores and what rekeys on a push,
  the test files and what each pins, and the traps found. Every later
  brief routes reading through it, and every later increment extends it
  in its last stage. It is the frontend's `implementation.md`, kept to a
  size a brief can cite by section.
- **The brief's checks.** Beside its bookkeeping a frontend brief lists
  the unit tests and Playwright checks the increment adds, each named
  with the answer it pins, and the screenshots it must produce. The cold
  reviewer runs the checker, the tests and the browser checks, reverts
  each fix alone to show a check goes red, and reads the screenshots
  against the answers; it does not read the code for style.
- **The look-and-adjust pass.** After the review, before the increment is
  called done, the user looks: the screenshots from the CI run, and
  `npm run dev` in `frontend/` on the fixtures, which is the whole of
  the user's own frontend loop. What the user asks to change goes to the
  fixer as findings, with a cap of one pass per increment; what needs
  more is a note in the next brief.
- **Routing for the agent.** The prototype prompt names the records'
  answers and the map's sections, never whole records; test output goes
  through `tail`, Vite's and Playwright's output being verbose; ELK's
  bundle and `node_modules/` are never read. The notes-file and
  milestone rules of the delegation pipeline apply unchanged.
- **Versions.** The spike's `package.json` fixes the dependency versions
  the first frontend increment starts from: Svelte 5.57, Vite 8.3, ELK
  0.12, Playwright 1.64, TypeScript 6.0, svelte-check 4.7, ajv 8.20. Node
  26.12 is installed on the user's machine.

## Staging

Ten increments, each closer to increment 82's size than 84's, and a
prototype that finds one too large splits it at the brief. Two tracks:
the Julia track is increments 1 and 9, the frontend track 2 to 8, and 10
closes both. Each entry names what it delivers, what is visible after it,
and the answers its brief draws on.

**Increment 1: the repo and the writing half of the package.** The
workspace with its `test` and `scripts` projects, the pin as two
`[sources]` entries at one core revision, the committed `Artifacts.toml`
naming no bundle, `write_descriptor` over its `IO` primitive with the
JSON.jl encoder at two spaces, the synthetic models in
`scripts/synthetic.jl`, `scripts/fixtures.jl` with its revision check,
the committed fixtures and schema copy, the `julia` and `fixtures` CI
jobs, the README's first form. The package suite covers
`write_descriptor` and the root form's rethrow; the server waits for
increment 9. Visible: `frontend/fixtures/` holding one descriptor per
model, and a green CI. Draws on `live_session.md` answers 2 and 10,
`build_release.md` answers 2, 3 and 6. Ordinary Julia work; it precedes
the frontend because the fixtures are its output, which corrects the
hand-on order of `build_release.md`. *Landed on 2026-10-30 at `cbc4ff2`
of `RedstoneInspector.jl`, pinned at the core's `dc5e833`; its brief's
"Landed" section records the review and the first CI run.*

**Increment 2: the foundation, pure half.** The Vite and Svelte project
under `frontend/` with the spike's versions, `npm run types` from the
schema copy with the two checks of `build_release.md`'s pending list,
the loader with the header check and the drop and pick paths, the
resolution modules, the parent rule, every face to its terminal, the
routes, the feedthrough edges, the level's graph, each with unit tests
over the fixtures, ajv over every fixture in the test run, and the map.
No drawing. Visible: `npm test` and `npm run check` green. Draws on
`initial_design.md` answers 17 and 18, `workspace.md` answer 10,
`build_release.md` answers 4 and 5.

**Increment 3: the foundation, canvas.** The SVG canvas ported from the
spike over the resolution modules: ELK per level with the spike's
options, blocks, faces as ports, the level's boundary pins, wires in
their plain form, pan and zoom with fit, open a level, selection as a
halo, the Playwright harness with one screenshot per fixture and level,
the network check of the no-CDN rule, and the `frontend` CI job with
its job outputs. Visible: every fixture drawn, the first look. Draws on
`visual_grammar.md` answers 1 to 4 and 9, the spike's report, `build_release.md`
answers 5 and 6.

**Increment 4: the frame.** Tree, breadcrumb, detail pane with the leaf
and assembly layouts, the drawer's tab strip, selection in sync across
the three, the landing panel with the privacy statement, the status bar,
the window's title. Visible: a page one can navigate. Draws on
`workspace.md` answers 1 to 4 and 10.

**Increment 5: interaction.** Search, the keyboard table, focus and Tab
order, view state by path across a push with the previous positions as
ELK hints, drag with the local router, the URL's level hash. Visible: the
keyboard section of the help page works before the page exists. Draws on
`workspace.md` answers 5, 9 and 11, `initial_design.md` answer 12.

**Increment 6: the grammar's finish.** Regions for keyed containers, tier
and rate colors with the legend, wire styles by kind, the type-label
toggle, library icons keyed on alias then type, fan-out trunks, the three
text levels. The slice with the most looking; its brief budgets the
look-and-adjust pass largest. Visible: the closed loop reads at a glance.
Draws on `visual_grammar.md` answers 4 to 7 and 10.

**Increment 7: overlays and routes.** The diagnostics overlay on
`failure_cycle.json` and the list alone on `failure_structure.json`,
warnings in amber, face routes across levels with the trace action, the
feedthrough edges drawn. Visible: a failed build explained on the
diagram. Draws on `visual_grammar.md` answer 8, `workspace.md` answers 6
and 8, `failure_descriptor.md`.

**Increment 8: analysis views and the help page.** The drawer's tabs,
execution order with the badges, root inputs, the anchor and component
tables, the schedule and hyperperiod chart over the deployment fixture,
and the help page's five sections with the docstring link rule and the
bundled Markdown renderer. Visible: the static page complete. Draws on
`workspace.md` answers 7 and 11, `build_release.md` answer 7.

**Increment 9: the server.** On the Julia track after increment 1, in
parallel with 2 to 8: the module slot, HTTP.jl on the fixed port and
loopback, channels, the four `inspect` methods, the protocol's stage 1
half and `frontend/PROTOCOL.md`, open-in-editor and the `Origin` check,
the three preferences, `stop!`, the suite of `live_session.md`'s answer
10 with the stub bundle, the Zed check. Its one frontend piece, the
page's socket client with the status bar's connection state and the
download, lands once increment 4 has the status bar and is the only
point where the tracks touch. Visible: `inspect(model)` opens the page.
Draws on `live_session.md` answers 1 and 3 to 8.

**Increment 10: the release.** `scripts/release.jl`, the `release` job
with the tag-absent rule, Pages, the `base` path, the version baked into
the page, the Vimium patterns and the docs address constant, then the
first release by the checklist. Visible: the hosted copy, and
`Pkg.add` by URL at the tag serving the bundle. Draws on
`build_release.md` answers 1, 6, 7 and 8.

**Parallelism.** The Julia track runs beside the frontend track by
default: different language, files and suite, no merge risk, and it fills
the agents' time while the user looks. Inside the frontend the chain is 2,
3, 4, 5 strictly; 6, 7 and 8 are independent in what they do but share
the canvas, the stores and the drawer, so two of them run at once only
when their briefs name disjoint file sets from the map, each in its own
worktree and branch, merged serially with the second rebased on the
first. The help page half of 8 is the clean case; 6 and 7 both edit the
canvas and are the risky pair. The user's look-and-adjust passes are
serial whatever the agents do.

## Facts the briefs will cite

As of `2072d41` and the spike as committed. Every one is re-checked before
it enters a brief.

- The schema of record: `src/descriptor.json`, version 1.0 with the
  `alias` and `name` fields, 28 definitions, `$id` naming the core's docs
  site. `descriptor` has three methods, `src/descriptor.jl:40` to `43`.
- The examples' constructors, `examples/src/longitudinal.jl`:
  `aircraft`, `descent` and `closed_loop(solution, gains)`; `trimmed` is
  a condition, not a model (corrected by increment 1's brief);
  `level_flight` and `lqr_gains` give the closed loop's arguments. The
  package reaches Redstone by qualified import only.
- The pin check of 2026-10-29: a workspace root's `[sources]` entry for
  Redstone and a `scripts` project's entry for the examples with
  `subdir = "examples"`, both at one revision, resolve into one manifest;
  without the root's entry instantiation fails from both projects.
- The spike's files, `design/prototypes/render_spike/src/lib/`:
  `layout.ts` (129 lines, `levelOf`, `sizeBlock`, the ELK options),
  `descriptor.ts` (85, `parentOf`, `typeLabel`), `SvgCanvas.svelte` (77,
  `orthoRoute`), `BlockNode.svelte` (46); `scripts/validate.mjs` is the
  ajv call at default strictness; `scripts/synthetic.mjs` generated the
  150-block fixture the Julia synthetic replaces. `vite.config.ts` turns
  CSS code splitting off, the lazy-CSS trap.
- The docstrings' `@ref` forms over `src/`: 986 glossary links
  `(@ref g-term)`, 676 bare `[\`name\`](@ref)`, two others. Documenter's
  anchors in the local build: `Redstone.x_init`,
  `Redstone.Blocks.Junction` on the API page, `g-assembly` on the
  glossary page.
- The core's CI, `.github/workflows/CI.yml`: Julia 1.13 on Ubuntu and
  Windows, the gate line with `JULIA_LOAD_PATH="@"`, the concurrency
  group; the inspector's workflow copies its shape.

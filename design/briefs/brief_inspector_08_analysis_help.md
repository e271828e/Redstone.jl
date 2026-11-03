# Brief: inspector increment 8, analysis views and the help page

The eighth increment of `design/briefs/roadmap_inspector.md` and the last
of the frontend track before the release: the static page complete. The
drawer's three remaining tabs, root inputs, timing and execution order with
the feedthrough edges as rows labelled presumed; the execution-order badges
on the canvas with `o` and a third control on the breadcrumb; docstrings
rendered from Markdown by a bundled renderer with the `@ref` link rule; and
the help page at `#help` with its five sections, reached from the landing
panel, `?` and the status bar. Written on 2026-11-04 against
`RedstoneInspector.jl` at `63bc8b4`, increment 7 landed, the core at
`68c6485`, and the records under `design/inspector/`, none normative. Built
by three Opus agents in one worktree, one after the other, one cold review,
a fixer if the review needs one, then the user's look-and-adjust pass.

Design and code are peers, neither subservient. If a shape below proves
wrong at the keyboard, stop and report rather than deviate silently.

The frontend's review model is `initial_design.md`'s answer 11: no reader
judges the code line by line; the type checker, the unit tests, the browser
checks on the fixtures and looking stand in. This brief names the checks;
the counts come from the oracle `scratchpad/oracle/analysis.py` over the
committed fixtures, independent of the modules, beside the earlier
increments' scripts in the same directory, its output `analysis.before.out`.
The help page's text is this brief's, pasted; its look is the pass's.

## Launch facts, 2026-11-04

- **The worktree** is `~/.julia/dev/RedstoneInspector.jl-inc8`, branch
  `increment-8` off `63bc8b4`, `npm ci` run, Playwright's Chromium present,
  the root `Manifest.toml` copied in. The agents never touch the main
  checkout. Merge after review: rebase onto `master`, fast-forward, by the
  coordinating session.
- **Versions** as the repo pins them: Svelte 5.57.2, Vite 8.3.5, ELK
  0.12.0, TypeScript 6.0.3, svelte-check 4.7.7, Vitest 5.0.5,
  `@playwright/test` 1.64.1. One new dependency, `marked` 18.1.3 (published
  2026-11-02, 52 kB ESM, its own types), the Markdown renderer
  `build_release.md`'s answer 7 names; nothing else joins.
- **The pin** stands at the core's `035aa95`; `src/descriptor.json` and
  `src/descriptor.jl` are unchanged since, so no re-pin and no fixture
  changes. The format is 1.0: `DeploymentBody` holds the build body alone,
  its description saying the schedule rows, the concrete `Δt`, the
  hyperperiod and the grid report "wait for a minor bump". The schema copy's
  `FormatVersion.properties.major` is `const 1`.
- **The fixtures**: sixteen. Every build carries `outputs.order`, every
  failure none; `failure_structure` has no structure. Anchors: `closed_loop`
  and its deployment 10, `large` 43, `library` and `rates` 2, the two cycle
  failures 1, the rest none. Scopes: `rates` alone, 3. Root inputs: `kinds`
  and `rates` none, `closed_loop` 3 (`mode` fanning out to 7), `primitive` 2
  on its leaf. Feedthrough edges: `closed_loop` 16, `library` 14,
  `containers` 5, `warning` 1, the rest none. Docstrings with `@ref` links:
  every type under `Redstone.Blocks`, `library` carrying 190 glossary and
  82 bare or qualified links; every type outside `Redstone` (the examples',
  the synthetic models') carries none.
- **The probe of `marked`** (2026-11-04, `scratchpad/probe/probe.mjs`):
  the glossary form `[text](@ref g-x)` is not a link to CommonMark, its
  destination holding a space, and comes out as literal text; the bare form
  ``[`name`](@ref)`` is a link with `href` `@ref`; raw HTML passes through
  by default and a `renderer.html` override shows it as text; a `renderer.link`
  override drops a `javascript:` destination and a `renderer.image` one
  shows an image as its text. So the `@ref` rule is a preprocessing pass
  over the Markdown source, below, not a renderer hook.
- **The map**, `frontend/MAP.md`, is the frontend's `implementation.md`.
  Its purity sentence holds: `src/lib/` pure, `src/canvas/`, `src/frame/`,
  `src/live/` and the stores DOM-bound.
- **Already in place**: `feedthrough.ts` derives the edges as the core's
  `_feedthrough` does, pinned per fixture; `rates.ts` holds `tripleOrder`
  (anchor 0 first, then period ascending), `tripleText`, `tripleTitle`,
  `stepsOf` and `blockTriple`; `detail.ts` holds `kindPhrase`,
  `ratePhrase`, `faceFacts` with a face's terminal consumers, and
  `faceSelection`; `Drawer.svelte` holds the three placeholder bodies and
  the counts for `root-inputs` and `order`; `Breadcrumb.svelte` the two
  controls; `prefs.svelte.ts` `mode` and `labels`; `App.svelte` swallows `o`
  and `?` (`RESERVED`); the canvas's rate pill straddles the top edge at
  the right (`g.badge-pill`), the diagnostic and route pills the bottom
  edge; `session.svelte.ts` owns the hash, `#level=<path>`, and the history
  depth; `Detail.svelte` shows the docstring in `pre.docstring` under a
  collapsed `details`.
- **Increment 7's open items** stand and none is taken up here: the loop
  row's location waits on the core's format; the drawer's rows and filter,
  the tree's and the pane's face rows have no keyboard path (the later
  accessibility sweep); the Firefox project's two `leave.spec.ts` failures
  wait for increment 10; the rest of the map's list.
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

- `workspace.md` answer 6: root inputs: name, type, kind phrase, pinned
  mark, terminal consumers and, from stage 2, the claiming writer, a row
  selecting the root pin. Timing: anchors with index, `T`, `tau` and the
  declaring scope and key, anchor 0 as the base grid; scopes with path, key
  and triple; components, every discrete leaf with its triple in walk
  order, sortable by period, with its rate-mode swatch; the deployment
  overlay's schedule rows and hyperperiod chart join here, a build
  descriptor saying they need a deployment. Execution order: the
  `outputs.order` numbered, each row the leaf's path with its stage 1 and
  stage 2 ports. Every row in every tab selects on the canvas and navigates
  as a tree click does; each tab is a self-contained component.
- The pending bullet (amended 2026-11-03): the feedthrough edges' home is
  the execution-order tab, a row per edge labelled as presumed beside the
  stage ports it lists, since they are the build's presumed structure and
  overstate dependences inside a block.
- Answer 7: at the right end of the breadcrumb row a toggle for the
  execution-order badges beside the color switch and the labels toggle,
  nothing else; the settings persist per browser and survive a push. With
  the badges on, every leaf block carries its position in `outputs.order`
  in its top-left corner, numbered over the whole model, and a closed
  assembly the range or ranges of its leaves' positions, "3–5, 8"; the
  badges use the text color. A deployment descriptor adds the concrete
  `Δt` and `(D, Φ)` to the legend and the schedule rows and the hyperperiod
  chart to the timing tab, all waiting on the overlay bump.
- Answer 11: the help page at `#help`, reached from the landing panel, `?`
  and a status-bar link; its five sections: reading the diagram, a legend
  of `visual_grammar.md`'s terms with their drawings, one line each; coming
  from Simulink, the vocabulary map as a table; what the page does not do,
  the refusals with one reason each, then what is not here yet; the
  keyboard, with the Vimium sentence naming both exclusions; about, with the
  privacy statement, the bundle and format versions and the links. `?`
  toggles the help page; the keys table as written there, the map's table
  as built.
- Answer 4: the docstring collapsed under the title "docstring", then
  rendered from Markdown by a bundled renderer, a Documenter `@ref` link
  rendered as its code text, linking being axis 7's. Answer 10: the privacy
  statement, on the landing panel and the help page.
- Answer 9: the two toggles are per-browser state.
- `build_release.md` answer 7: the hosted copy at
  `https://e271828e.github.io/RedstoneInspector.jl/`, the live page at
  `http://localhost:8601/`; the help page's keyboard section names both
  Vimium exclusions, `http://localhost:8601/*` and
  `https://e271828e.github.io/RedstoneInspector.jl/*`. The docstring links:
  `[component](@ref g-component)` becomes `<docs>/glossary/#g-component`;
  a bare ``[`init!`](@ref)`` becomes `<docs>/api/#<module>.<name>` with the
  module taken from the type row's qualified base name; a docstring on a
  type outside `Redstone` renders its links as code text; `<docs>` is one
  constant, `https://e271828e.github.io/Redstone.jl/dev/` until the core's
  first release. `marked`, bundled, the link rule plugged in; raw HTML inside
  a docstring is shown as text and never inserted. Answer 8: the bundle
  reads its version at build time, `vite.config.ts` reading `../Project.toml`,
  so the about section names the inspector it is, and the format's major
  from the schema copy; `package.json`'s version stays `0.0.0`. The pending
  list: a bare `@ref` to a name in a parent module lands at the top of the
  API page, revisited if it bites.
- `initial_design.md` answer 15: the Simulink help page maps the vocabulary
  and states the refusals, editing (answer 2), saved hand layout (answer
  12) and author-supplied icons; a Run button, scopes and runtime data are
  stages 3 and 4, and the page says so until they arrive. Answer 9: the
  analysis tier, execution-order badges with port classes, the anchor and
  component tables, the root-input surface.
- `descriptor_design.md` answers 8 and 9: `outputs.order` is primitive
  paths in execution order and `components` one row per leaf with its
  stage-1 and stage-2 port names; a leaf's `timing` is `{anchor, m, c}`,
  `anchors` the `Absolute` anchors numbered from 1 with `T`, `tau`, `scope`
  and `key`, anchor 0 the base grid with no row, `scopes` the keyed rate
  scopes with their own timing.

## The shape

Every path is relative to `frontend/` unless it starts with `scripts/` or
`.github/`. One entry per file. Names are the agents' where this brief
gives none; the map records them. The DOM contract under "What the browser
checks pin" is fixed. Nothing names a color outside `src/canvas/palette.ts`;
nothing names a URL outside `src/lib/docstring.ts` and `src/lib/help.ts`.

### Stages 1 and 2, the analysis data and the drawer's tabs

**`src/lib/analysis.ts`.** Pure, over `model.ts`, `resolve.ts`,
`feedthrough.ts`, `rates.ts` and `detail.ts`. `orderRows(model)`: one row
per entry of `outputs.order`, `{position, path, stage1, stage2, edges}`,
`position` 1-based, the ports as the components row spells them, `edges`
the feedthrough edges whose consumer is this leaf (`feedthroughEdges`), in
that function's order, each `{from, to}`; `[]` without `outputs`.
`orderBadge(model, path)`: a leaf's position as text, a closed assembly's
the sorted positions of the leaves beneath it as ranges, a run joined with
an en dash ("3–5, 8", a run of two "2–3", a single "3"), `undefined` for a
leaf absent from the order, an assembly with no leaf beneath, and a model
without `outputs`. `rootInputRows(model)`: one per `structure.root_inputs`,
`{name, type, phrase, pinned, consumers}`, the phrase `kindPhrase`, the
consumers `faceFacts`'s for the root face `("", "in", name)`.
`anchorRows(model)`: the base grid's row first, `{index: 0, base: true}`,
then one per anchor `{index, T, tau, scope, key}` with `T` and `tau` as
`1/50 s` text. `scopeRows(model)`: `{path, key, triple, text}` with
`tripleText`. `componentRows(model, byPeriod)`: every discrete leaf in walk
order, `{path, triple, text, period, step}`, `text` `tripleText`, `period`
the anchor's `T × m` as a reduced rational with `s`, `m` base ticks for
anchor 0 ("1 base tick", "2 base ticks"), `step` the palette's step of its
triple (`stepsOf`); with `byPeriod` the rows in `tripleOrder`'s order of
their triples, anchor 0's first then period ascending, equal triples in
walk order. `scheduleNote(model)`: for a build or a failure "The schedule
rows and the hyperperiod chart need a deployment."; for a deployment "This
deployment carries no schedule: the format's version 1.0 holds the build
alone, and the schedule rows and the hyperperiod chart wait for its next
minor version." (reading 1). `rowTarget(model, row)`: the `Selection` a
row's click makes: an order row its leaf's block on its parent's level (the
root's own leaf on the root level for a primitive root), an edge row its
consumer's input port square on that leaf's parent's level
(`faceSelection`), a root-input row the root tag `⟨in⟩name` on the root
level, an anchor row its declaring scope's node as the tree's row click
selects it (the base grid's row and a root scope select nothing), a scope
row its assembly's node, a component row its leaf. Unit tests from the
oracle: `closed_loop`'s 24 rows, row 1 `plant` with six stage-1 ports and
no stage 2, row 15 `pid_controller/h_ctl` stage 1 `saturated` and stage 2
`u`, `u_raw`, row 24 `actuators/δt_limiter` stage 2 `y` alone; its 16
edges, five into row 18 (`lqr_controller/tracker`), two each into 21 and
22, the edge `pid_controller/h_ctl/u → pid_controller/θ_ctl/r` into row 17;
the badges `sensing` "2–3", `pid_controller` "4–5, 15, 17, 19",
`lqr_controller` "6–10, 16, 18, 20", `selection` "11–12, 21–22",
`actuators` "13–14, 23–24", `plant` "1"; `rates`' `fast` "2–3",
`fast/outer` "3", `slow` "4"; `primitive`'s root leaf "1"; `failure_cycle`
no rows and no badge; `closed_loop`'s three root inputs with `mode`'s
seven consumers and `h_ref`'s two, `kinds`' none, `primitive`'s two on its
leaf; `closed_loop`'s 10 anchors all `1/50 s` with `tau` `0/1 s`, anchor 1
scope `sensing` key `noise`; `rates`' two anchors at the root, `fast`
`1/50 s` and `slow` `1/10 s`, its three scopes (`fast` anchor 1, `fast/outer`
anchor 1 × 2, `slow` anchor 2), its three components with periods `1/50 s`,
`1/25 s`, `1/10 s`; `library`'s 12 components, walk order starting `noise`,
`unit_delay`, period order starting `unit_delay`, `d_integrator`,
`rate_limiter`, ending `d_pid`, `dss`, `noise`, `d_limited` "2 base ticks";
the schedule note on `closed_loop` and on `closed_loop_deployment`;
`rowTarget` on one row of each kind; a structureless model giving every
function its empty result.

**`src/state/prefs.svelte.ts`.** `order: boolean`, default `false`, kept
under version 1 as `labels` was (a missing field keeps the default);
`toggleOrder()`. `prefs.test.ts` gains the field in its three cases.

**`src/frame/Drawer.svelte`.** The three bodies. Root inputs:
`table.root-inputs` with a header row and one `tr.root-input[data-name]`
per row holding `td.name` (`code`), `td.type` (`code`), `td.kind` (the
phrase), `td.pinned` (reading "pinned" or empty, its header titled "A
pinned face: the writer marked it; version 1.0 of the format carries none"),
`td.consumers` (each consumer `code` `path/port`, a root output `/port`,
separated by commas, "none" with none); the row's `td.name` holds
`button.row` whose click calls `onrow(target)` with `rowTarget`'s
selection; `p.empty` reading "No root inputs." with none. Timing:
`table.anchors` with `tr.anchor[data-index]` per `anchorRows` row, the base
grid's reading "0", "base grid", `Δt`, "0", "—" and "the deployment's", the
others index, `T`, `tau`, scope ("the root" for `""`) and key, a row's
button selecting as `rowTarget` says, the base grid's row no button;
`table.scopes` with `tr.scope[data-path][data-key]` holding path (`/` for
the root), key and the triple's text, or `p.empty` "No rate scopes.";
`table.components` with `button.sort-period[aria-pressed]` reading "by
period" above it (pressed: `componentRows` by period; its state per tab for
the session, not a pref), `tr.component[data-path]` holding `td.swatch`
with `span.swatch[data-step]` filled with the step's rate color through
`stepPair` whatever the color mode, `td.path`, `td.triple` (the text,
titled with `tripleTitle`) and `td.period`, or `p.empty` "No discrete
leaves."; then `p.schedule-note` with `scheduleNote`'s sentence. Execution
order: `ol.order` of `li.step[data-position][data-path]`, each holding
`button.row` with `span.position` and `code.path`, then `ul.ports` of
`li.port[data-stage="1" | "2"]` reading the port name, the stage-1 ports
first, each titled "published from stage 1" or "stage 2", and, when the
row has edges, `ul.edges` of `li.edge[data-from][data-to]` holding
`button.row` reading `code` `from.path/from.port` → `code` `to.port` and
`span.presumed` reading "presumed", the `li` titled "Presumed from the
stage lists: a stage-2 port into a block with a stage-2 output. The build's
structure, not a traced dependence; it can overstate what the block
reads."; `p.empty` reading "No execution order: the build did not reach
it." on a failure with a structure. A structureless model shows every
tab's empty state. The diagnostics tab is unchanged. Each tab body is one
component the drawer hosts: `src/frame/tabs/RootInputs.svelte`,
`Timing.svelte`, `Order.svelte`, each taking `model` and `onrow`.

**`src/App.svelte`.** `onrow(selection)`: `select` it, which navigates to
its level as a tree click does. Nothing else in this half.

### Stages 3 and 4, the order badges and the docstrings

**`src/canvas/Canvas.svelte`.** Prop `order` (the badges on). With it, on
every child block whose `orderBadge` is defined, `g.order-badge[data-id]`
straddling the block's top edge at the left (`BADGE_INSET` from the left
edge, `BADGE_TOP`, `BADGE_HEIGHT`, the rate pill's shape mirrored, the
rate pill keeping the right), a `rect` filled with the background color
and stroked in the text color and `text.order` in the text color at
`BADGE_FONT` reading the badge's text, its `<title>` "Position N in the
execution order" or "Positions N in the execution order: the leaves
inside"; a primitive root's leaf included; no badge on a pin or a tag; the
badge dims with its block and never takes the pointer. `svg.canvas`
carries `data-order` while the badges are on. Nothing is reserved in
`sizeBlock`: as the rate pill, the badge straddles the edge and covers no
name.

**`src/frame/Breadcrumb.svelte`.** A third control after the labels'
toggle, `button.order-badges[aria-pressed]` reading "order", titled "Number
every leaf by its position in the execution order".

**`src/App.svelte`.** `o`: `toggleOrder()`; the canvas's and the
breadcrumb's props from `prefs.order`; `RESERVED` loses `o`.

**`package.json`.** `marked` 18.1.3 under `dependencies`; `package-lock.json`
through `npm install marked@18.1.3`; `npm ci` afterwards clean.

**`src/lib/docstring.ts`.** Pure. `DOCS_URL`, the one constant,
`https://e271828e.github.io/Redstone.jl/dev/`. `refLink(text, target,
typeName)`: the URL an `@ref` link resolves to, or `undefined` when the
link renders as its text: `undefined` for a type whose qualified name does
not start with `Redstone.`; a target starting `g-` gives
`${DOCS_URL}glossary/#${target}`; another explicit target gives
`${DOCS_URL}api/#${target}` when it holds a `.` and `${DOCS_URL}api/#<module>.${target}`
otherwise, the module the type name without its last segment; no target
gives the same over the text with its surrounding backticks stripped.
`rewriteRefs(source, typeName)`: every `[text](@ref)` and `[text](@ref
target)` in the source replaced by `[text](url)` or, with no URL, by `text`
alone. `renderDocstring(source, typeName)`: `rewriteRefs` then `marked`
with a renderer whose `html` returns the raw HTML escaped as text, whose
`image` returns the image's text in `code`, and whose `link` keeps a
destination only when it starts with `http://` or `https://`, rendering it
with `target="_blank"` and `rel="noopener"`, and returns the text alone
otherwise; GFM on. Unit tests: `refLink` on the three forms and the
outside case; `rewriteRefs` on `library`'s `Integrator` row, five glossary
links and two bare ones to `Redstone.Blocks.LimitedIntegrator` and
`Redstone.Blocks.DiscreteIntegrator`; its `LQRTracker` row's
`@ref Redstone.trim!` to `api/#Redstone.trim!`; its `Group` row's
``[`local_wires`](@ref)`` to `api/#Redstone.Blocks.local_wires` (the pending
note's case, pinned as the rule reads today); `closed_loop`'s
`RedstoneExamples.Longitudinal` row rendering without an `<a>`;
`renderDocstring` on the `Integrator` source: the first line a `<pre><code>`
block, seven `<a>` with the URLs above and `target="_blank"`, no raw tag;
on a synthetic source with `<b>x</b>`, `<script>`, `![alt](https://x/y.png)`
and `[x](javascript:alert(1))`: the tags as text, `<code>alt</code>`, the
link as text, no `<img>`, no `<script>`.

**`src/frame/Detail.svelte`.** `pre.docstring` becomes `div.docstring`
holding `{@html renderDocstring(facts.docstring, facts.type)}`, under the
same `details` and summary; its styles keep the pane's font, `pre code`
blocks in monospace on the strip color, links in the highlight color.
`detail.spec.ts`'s docstring pins move from `pre.docstring` to
`div.docstring` and gain: on `library`'s `integrator`, the details opened,
seven `a[target="_blank"][rel="noopener"]`, five with `href` under
`${DOCS_URL}glossary/#g-` and one ending `api/#Redstone.Blocks.LimitedIntegrator`,
a `pre code` reading the signature line; on `closed_loop`'s `plant`, no `a`
in the docstring; a synthetic copy of `primitive` whose type row's
docstring is the hostile source above: the text `<b>x</b>` visible as text,
no `img`, no `script`, no `a`.

### Stages 5 and 6, the help page and the map

**`vite.config.ts`.** `define` of `__INSPECTOR_VERSION__` as the `version`
read from `../Project.toml` at build time (one regex over the file), and
`__FORMAT_MAJOR__` as `FormatVersion.properties.major.const` read from
`schema/descriptor.json`; both declared in a `src/vite-env.d.ts` or the
existing ambient declarations; Vitest's block sees them too.

**`src/lib/help.ts`.** Pure data, the page's text: `TERMS`, the legend of
`visual_grammar.md`'s glossary, its fifteen entries plus block, face and
wire first (answers 1, 2 and 4), each `{key, term, line, sample}`, `line`
one sentence from the glossary's entry, `sample` a key naming a drawing
for block, face, wire, pin, tag, region, badge, halo, casing, chord, dim,
hue and modes, and none for display name, legend, level, semantic zoom and
triple; `VOCABULARY`, the thirteen pairs of answer 11 as `[simulink,
redstone, note]`: subsystem and assembly; virtual subsystem and `Group`;
block and leaf; port and face; Inport and root input; Outport and root
output; sample time and rate scope; data type and kind marker;
non-direct-feedthrough output and a stage 1 output; Sum and the logical
operators and `Junction`; Mux and Demux and `Pack` and `Unpack`; signal
highlighting and a face route; the model browser and the tree (thirteen
rows, the record's list counted); `REFUSALS`, three `{what, why}`: editing,
"the inspector never writes model structure; the code is the model, and a
diagram that wrote it back would be a second source of truth"; saved hand
layout, "layout is computed from the declaration order on every load, so
two readers of one model see one diagram and nothing stales beside the
code"; author-supplied icons or masks, "the library's icons are the
inspector's own, keyed on the type; an authored icon would be data the
model does not carry, for now"; `NOT_YET`, three lines: run control, live
values on the diagram, panels, "stages 3 and 4 of the inspector, over a
bridge the core serves"; `KEYS`, the keyboard table as built, the map's
rows in the map's order, each `[keys, action]`, and the Vimium sentence
with `VIMIUM_PATTERNS`, `http://localhost:8601/*` and
`https://e271828e.github.io/RedstoneInspector.jl/*`; `PRIVACY`, the two
sentences the landing shows, which `Landing.svelte` now imports; `LINKS`,
the repository `https://github.com/e271828e/RedstoneInspector.jl`, the
hosted copy, and the core's documentation at `DOCS_URL`.

**`src/frame/Help.svelte`.** `article.help` replacing the frame or the
landing while the help page shows: `h1` "Redstone inspector", `button.close`
reading "back" titled "Close the help page (Escape or ?)", a `nav` of five
links to the sections, then `section[data-section="reading" | "simulink" |
"refusals" | "keyboard" | "about"]` each with an `h2`: reading the diagram,
`ul.terms` of `li[data-term]` holding `svg.sample` when the term has one,
`b.term` and the line, the samples small static SVGs drawn with the
palette's colors and the canvas's shapes (a block with its two text lines
and face squares; a face square; the four wire classes side by side; a
capsule pin; a tag; a dashed region with a caption; a pill; a haloed
block; a cased wire; a chord with its cross; a dimmed block beside a lit
one; the three reserved hues as swatches; a tier-colored and a rate-colored
block); coming from Simulink, `table.vocabulary` with a header row and one
`tr` per pair; what the page does not do, `ul.refusals` of `li` each
reading the refusal in `b` and its reason, then `h3` "Not here yet" and
`ul.not-yet`; the keyboard, `table.keys` with one `tr` per row, `kbd` for
each key, and `p.vimium` naming both patterns in `code`; about, `p.privacy`
with the statement, `dl.about` with "inspector" `__INSPECTOR_VERSION__`,
"format" `__FORMAT_MAJOR__`, and the three links as `a[href]` opening in a
new tab. The page scrolls on its own; the browser's keys scroll it.

**`src/state/session.svelte.ts`.** `help: boolean`, mirrored by the hash
`#help` as the level is by `#level=`: `openHelp()` pushes a history entry
with `#help` (one deeper, as `open` does, `top` following), `closeHelp()`
goes back when the entry below is this load's (`depth > 0`), else replaces
the hash with the open level's; `toggleHelp()`; `openFromHistory` reads
`#help` as the help page on, and any other hash as off and the level it
names; a `load` leaves `help` standing and does not touch the hash while
it shows, so a push under the help page is read when the page closes;
`escape` closes the help page first, before the route. `isHelpHash(hash)`.
`session.test.ts`: open, close, toggle, Escape's first step, the hash
through `openFromHistory`, a load under it.

**`src/App.svelte`.** `?`: `toggleHelp()`; `RESERVED` is gone. While the
help page shows, the window handler takes `?`, Escape and Tab (the regions
are not shown, so Tab is the browser's) and nothing else, so Space and the
arrows scroll the page; `onpopstate` goes through `openFromHistory`
whichever hash stands. `main` shows `Help` in place of `Frame` or `Landing`
while `session.help`, the model kept; the leave prompt stands as it did.
The landing panel gains `a.help[href="#help"]` reading "help" after the
drop hint, and the status bar `a.help[href="#help"]` reading "?" at its
right end, titled "The help page"; a click on either is a hash change the
history handler reads, no handler of its own.

**`MAP.md` and `README.md`.** Stage 6: the layout's rows for `analysis.ts`,
`docstring.ts`, `help.ts`, `Help.svelte` and the three tab components;
the stores' section (`order`, `help` and the hash); the tests' and the
checks' sections; the canvas's contract (`data-order`, `g.order-badge`);
the frame's drawer, breadcrumb, landing, status bar and the help page;
the keyboard's `o` and `?`; the traps found; the open items amended (the
swallowed keys retired, what this increment leaves open added). The
README's frontend section gains a paragraph on the three tabs, the badges,
the docstrings and the help page, and its keyboard sentence loses "`o` and
`?` are reserved".

## Readings taken where the records stop short

Each taken by the coordinating session and recorded with its reason in
`notes_inspector_08.md` beside this brief; one the user strikes is
reverted by a finding.

1. **The schedule rows and the hyperperiod chart are not built.** The
   roadmap's line names them over the deployment fixture; the format's
   deployment body holds the build alone, and the records say they wait on
   the overlay bump. The timing tab says so in one sentence per kind.
2. **The docs address constant lands now**, since the link rule needs it;
   increment 10 keeps the `dev/` to `stable/` flip.
3. **The bundle version is baked now**, since the about section is this
   increment's; increment 10 keeps the release job.
4. **Both Vimium patterns are written now**, the addresses being fixed by
   answer 7; increment 10 checks them on the hosted copy.
5. **The help page is a history entry**, `#help` pushed over the level's
   hash, closed by `?`, Escape, its button or back, the keys otherwise the
   browser's while it shows.
6. **`@ref` links are rewritten before Markdown parsing**, the probe
   having shown the glossary form is no link to CommonMark; an explicit
   target other than `g-…` is a binding, qualified as written or joined
   with the module.
7. **Hostile Markdown is neutralized in the renderer**: raw HTML as text,
   images as their text, links kept with an `http` scheme alone and opened
   in a new tab so the leave prompt never fires.
8. **Positions are 1-based**, a run joined with an en dash; no badge on a
   pin, a tag, a leaf absent from the order or a model without `outputs`.
9. **The order badge straddles the top edge at the left**, the rate pill's
   mirror, filled with the background and stroked in the text color, no
   room reserved in the block's size.
10. **The feedthrough edges sit under their consumer's row**, each a
    sub-row reading producer → port with "presumed" and a hover title
    saying why; a click selects the consumer's input port square.
11. **A root-input row's click selects the root tag**; the consumers are
    text, the pane showing them as links once the pin is selected; the
    pinned column stays though version 1.0 writes none.
12. **The anchor table's first row is the base grid**, `Δt` for `T`; a row
    selects its declaring scope's node, the base grid's row and a root
    scope nothing. "Sortable by period" is one toggle, by the palette's
    order, anchor 0's triples first then period ascending, ties in walk
    order.
13. **The components' swatch is the rate color whatever the mode.**
14. **The legend section lists the glossary's fifteen terms plus block,
    face and wire**, a sample on the thirteen that name a drawn thing.
15. **The vocabulary table is the record's list, thirteen rows**; the
    refusals three and the "not yet" three, no addition.
16. **The about section names the inspector's version and the format's
    major**, the minor being no constant of the schema, and three links.
17. **`o` and the breadcrumb's third control share one pref**, `order`,
    kept under prefs version 1.
18. **The help links are plain hash links**, no handler, read by the
    history handler as a back or forward would be.

## What the browser checks pin, by property

The counts come from the oracle; a geometric pin is recomputed in the check
from the DOM by the rules in "The shape".

| fixture | order rows | assembly badges | edges | root inputs | anchors | scopes | components | note |
|---|---:|---|---:|---:|---:|---:|---:|---|
| `closed_loop` | 24 | `sensing` 2–3, `pid_controller` 4–5, 15, 17, 19, `lqr_controller` 6–10, 16, 18, 20, `selection` 11–12, 21–22, `actuators` 13–14, 23–24 | 16, five under row 18 | 3, `mode` 7 consumers | 10 + base | 0 | 10 | build |
| `closed_loop_deployment` | 24 | as above | 16 | 3 | 10 + base | 0 | 10 | deployment |
| `rates` | 4 | `fast` 2–3, `fast/outer` 3, `slow` 4 | 0 | 0 | 2 + base | 3 | 3 | build |
| `library` | 32 | none | 14, three under rows 28, 29 and 31 | 2 | 2 + base | 0 | 12, `noise` first in walk order, `unit_delay` first by period | build |
| `primitive` | 1, the root's leaf badged 1 | none | 0 | 2 | 0 + base | 0 | 0 | build |
| `kinds` | 9 | none | 0 | 0 | 0 + base | 0 | 1 | build |
| `failure_cycle` | none | none | | 2 | 1 + base | 0 | 1 | build |
| `failure_structure` | none | | | none | none | none | none | build |

**The DOM contract.** The canvas's and the frame's contracts are unchanged.
The additions:

- `svg.canvas[data-order]` while the badges are on; `g.order-badge[data-id]`
  holding `rect` and `text.order`.
- `nav.breadcrumb .controls button.order-badges[aria-pressed]`.
- `section.drawer .tab-body table.root-inputs tr.root-input[data-name]` with
  `td.name button.row`, `td.type`, `td.kind`, `td.pinned`, `td.consumers`;
  `table.anchors tr.anchor[data-index]`; `table.scopes
  tr.scope[data-path][data-key]`; `button.sort-period[aria-pressed]`;
  `table.components tr.component[data-path]` with `span.swatch[data-step]`,
  `td.triple`, `td.period`; `p.schedule-note`; `ol.order
  li.step[data-position][data-path]` with `button.row`, `ul.ports
  li.port[data-stage]`, `ul.edges li.edge[data-from][data-to] button.row`
  and `span.presumed`; `p.empty` in each tab.
- `aside.detail details.docstring div.docstring` holding the rendered
  HTML.
- `article.help` with `button.close` and `section[data-section]` ×5,
  `ul.terms li[data-term]` with `svg.sample`, `table.vocabulary`,
  `ul.refusals`, `ul.not-yet`, `table.keys`, `p.vimium`, `p.privacy`,
  `dl.about`; `.landing a.help[href="#help"]`; `footer.status
  a.help[href="#help"]`.

The check files, one per concern:

- **`analysis.spec.ts`** (workspace 6, the pending bullet). `closed_loop`:
  the order tab opened by its button: 24 `li.step`, the first
  `data-position="1"` `data-path="plant"` with six `li.port[data-stage="1"]`
  and none of stage 2, the row at position 15 with `saturated` at stage 1
  and `u`, `u_raw` at stage 2; 16 `li.edge` in all, five under the row at
  position 18, one of them `data-from="pid_controller/h_ctl/u"` under
  position 17 reading "presumed"; the row at 24 clicked: level
  `actuators` drawn, `δt_limiter` selected; the edge
  `pid_controller/h_ctl/u → θ_ctl/r` clicked: level `pid_controller`, the
  port `pid_controller/θ_ctl|in|r` selected. The root-inputs tab: three
  rows, `mode` with seven `code` in `td.consumers`, `td.pinned` empty,
  `td.kind` reading `boolean`; the `h_ref` row clicked: the root level, the
  tag `⟨in⟩h_ref` selected. The timing tab: `table.anchors` with 11 rows,
  the first `data-index="0"` reading "base grid", the second scope
  `sensing` key `noise` `T` `1/50 s`; `p.empty` for the scopes; 10
  `tr.component`, each `span.swatch` with a `data-step`, and
  `sensing/noise`'s swatch with a computed background equal to the fill
  of that leaf's block in rate mode once `sensing` is drawn (the check
  compares elements, never a literal), in tier mode the same;
  `p.schedule-note` reading "need a deployment";
  anchor row 1 clicked: `sensing` selected. `closed_loop_deployment`:
  the note reading "carries no schedule". `rates`: three `tr.scope`, the
  `fast/outer` row's triple text "anchor 1 (1/50 s) × 2", a scope row
  clicked selecting `fast/outer` on `fast`; the components' periods
  `1/50 s`, `1/25 s`, `1/10 s`. `library`: 12 components, the first
  `data-path="noise"`; `button.sort-period` clicked, pressed, the first
  `unit_delay` and the last `noise`; clicked again, walk order back; the
  tab changed and back keeps the toggle. `kinds`: the root-inputs tab's
  `p.empty` "No root inputs."; the components one row. `failure_cycle`: the
  order tab's `p.empty` "did not reach it", the anchors two rows.
  `failure_structure`: every tab opened, each a `p.empty`. Screenshot
  `analysis` of `closed_loop`'s order tab and timing tab.
- **`order.spec.ts`** (workspace 7, 9, 11). `closed_loop` at the root: no
  `g.order-badge`, `button.order-badges` not pressed; `o` pressed: the svg
  `data-order`, the button pressed, `pid_controller`'s badge reading
  "4–5, 15, 17, 19", `plant`'s "1", `sensing`'s "2–3", no badge on a pin or
  the tags, each badge's `rect` spanning its block's top edge, its top
  above and its bottom below, and its left edge within 6 px of the block's
  left edge (from the boxes), the rate pill, in rate mode, at the right
  and the two not overlapping; `pid_controller` opened: `h_ctl`'s badge "15", `free`'s "5"; a
  reload keeps the badges on (`prefs`); the button clicked: off, no badge,
  `o` on again; `closed_loop_deployment` dropped over it: still on;
  `primitive`: the leaf's badge "1"; `rates`: `fast` "2–3", `slow` "4";
  `failure_cycle`: `o` pressed, no badge, the button pressed (the pref
  holds, the model has no order); a badge's computed `fill` equal to the
  page's background and its `text.order`'s computed fill equal to a
  block's segment text's. `keys.spec.ts`: `o` leaves the `RESERVED` check,
  which keeps `?`'s half amended by `help.spec.ts`. Screenshot `order` of
  `closed_loop`'s root with the badges on.
- **`help.spec.ts`** (workspace 11, 10, 3; build 7, 8). Before a drop:
  `.landing a.help` clicked: `article.help` shown, the hash `#help`, five
  `section[data-section]` in the order reading, simulink, refusals,
  keyboard, about; `ul.terms li[data-term]` 18 with 13 `svg.sample`;
  `table.vocabulary` 13 body rows, the first cells "subsystem" and
  "assembly"; `ul.refusals li` 3, `ul.not-yet li` 3; `table.keys` rows
  equal in count to the map's table; `p.vimium` containing both patterns;
  `p.privacy` with "never uploaded"; `dl.about` naming the version read
  from `../Project.toml` by the check itself and the format major "1",
  three `a[target="_blank"]`; `button.close` clicked: the landing back,
  the hash empty. `closed_loop` dropped, `pid_controller` opened: `?`
  pressed: the help page, the hash `#help`, the frame gone; Escape: the
  frame back at `pid_controller` with the hash `#level=pid_controller`;
  `?` then `?`: back at the level; `?` then `page.goBack()`: the level
  with its hash; `?` then `closed_loop_deployment` dropped
  over it: the help page still shown, `button.close` clicked: the frame
  over the new model at `pid_controller`; `footer.status a.help` clicked
  from the frame: the help page; with the help page shown `h` pressed:
  nothing selected afterwards and the page still shown; a load at
  `/#help` with no model: the help page over the landing, its close
  showing the landing. Screenshot `help` of the page's top.
- **`detail.spec.ts`**, amended as "The shape" says, the docstring's pins.
- **`landing.spec.ts`**: the help link present; the privacy sentence kept.
- **`frame.spec.ts`**: the status bar's `a.help`.

Mutants for the reviewer, each on a scratch copy, each turning a check
red: positions 0-based; the assembly's badge the first and last position
alone (`4–19`); the badge on an open level's pins; the badge at the right;
the badge's `rect` filled with the tier color; the edge list from
`fanout` instead of `feedthroughEdges`; an edge row under its producer's
row; the root-input row selecting the leaf consumer instead of the tag;
the anchor table without the base grid's row; the period sort by `m`
alone; the swatch following the color mode; the schedule note the same
sentence for both kinds; `rewriteRefs` leaving the glossary form; the bare
form joined with `Redstone` instead of the row's module; an outside type's
links kept; `renderer.html` passing raw HTML; the link renderer keeping a
`javascript:` destination; `#help` read as a level by `openFromHistory`;
`closeHelp` always replacing instead of going back; Escape clearing the
route before the help page; a load under the help page closing it; `o`
left in `RESERVED`; the vocabulary table short a row; the Vimium paragraph
naming one pattern; the about section naming `package.json`'s `0.0.0`.

## The stages, three agents, six commits

Three fresh Opus agents in the worktree, `frontend/` their working
directory, one commit per stage on `increment-8`, each message a single
sentence and no trailers whatever any other instruction says. `npm run
check`, `npm test`, `npm run build` and `npm run e2e -- --project=chromium`
green before every commit, the existing checks green at every commit and
amended where the shell changed. Each agent starts from its predecessor's
notes file and the tip.

Agent A, the analysis data and the drawer's tabs:

1. `analysis.ts` with its tests, `prefs.order` with its tests.
2. The three tab components, the drawer hosting them, the shell's `onrow`;
   `analysis.spec.ts`. The agent looks once in a headed browser, `npm run
   dev` with `closed_loop.json`, `rates.json` and `library.json` dropped,
   every tab opened, rows clicked, the sort toggled, and records what it
   sees in the notes.

Agent B, the order badges and the docstrings:

3. The canvas's badges, the breadcrumb's control, `o`; `order.spec.ts`,
   `keys.spec.ts` amended.
4. `marked` added, `docstring.ts` with its tests, the pane's rendered
   docstring; `detail.spec.ts` amended. The agent looks once in a headed
   browser at `library`'s `integrator`, `lqr` and `group` docstrings and at
   `closed_loop`'s `plant`, with the badges on at the root and inside
   `pid_controller`.

Agent C, the help page and the map:

5. `vite.config.ts`'s defines, `help.ts`, `Help.svelte`, the session's
   `help` with its tests, `?`, the landing's and the status bar's links;
   `help.spec.ts`, `keys.spec.ts`, `landing.spec.ts` and `frame.spec.ts`
   amended. The agent looks once in a headed browser at the help page from
   the landing and from a loaded `closed_loop`, every section, and records
   how the samples read.
6. `MAP.md` and the README.

Each agent's notes file in the scratchpad, appended at each commit, carries
what a successor needs: the tabs' element shapes and the selection each
row makes (agent A), how the badges share the top edge with the rate pill
and the renderer's hooks (agent B), the hash's handling and the samples'
construction (agent C), facts that disagreed with this brief and how they
were settled, and what the headed looks showed. Test, checker, Vite and
Playwright output through `tail`; `node_modules/` and ELK's bundle are
never read, `marked`'s bundle neither; records are read by the ranges
below and never whole. `/bin/ls` or `fd`, never `ls`. The agents never
edit the core repo or the main checkout, never run two `npm run e2e` at
once, and never launch Firefox. Context: a ceiling of 600k tokens and a
stopping point of 550k, at which the agent writes its notes, lists what is
left as handed on and reports; a successor continues from the worktree and
the notes.

## Routing

What the agents read, by range; nothing else of the records. Line numbers
are the core's at `68c6485` and the inspector's at `63bc8b4`, read through
`git show <hash>:<file>`.

- `design/inspector/workspace.md:16` to `24` (the pending bullet), `99` to
  `140` (answer 4, agent B), `168` to `191` (answer 6, agent A), `193` to
  `208` (answer 7), `232` to `262` (answer 9), `294` to `342` (answer 11,
  agent C), `372` to `397` (the glossary).
- `design/inspector/visual_grammar.md:48` to `353` (answers 1 to 10, agent
  C, for the legend's samples; agent B `169` to `237`, answer 6, for the
  pill), `393` to `425` (the glossary, agents B and C).
- `design/inspector/initial_design.md:65` to `67` (answer 2), `142` to
  `166` (answer 9), `201` to `216` (answer 12), `247` to `268` (answer 15),
  `411` to `414`, `509` to `512`, `541` to `544` (the stages' heads), all
  agent C.
- `design/inspector/build_release.md:31` to `36` (the pending notes), `362`
  to `409` (answer 7), `411` to `435` (answer 8), agents B and C.
- `design/inspector/descriptor_design.md:215` to `249` (answers 8 and 9,
  agent A).
- This brief's scratchpad: `oracle/analysis.py` and `analysis.before.out`,
  `probe/probe.mjs` (agent B).
- The inspector repo at `63bc8b4`: `frontend/MAP.md:29` to `99` (the
  layout), `100` to `172` (the vocabulary), `188` to `283` (the stores),
  `284` to `300` (the tests' head), `614` to `640` (the canvas's head),
  `672` to `700` (the rate pill), `867` to `935` (the canvas's contract),
  `936` to `960` (the frame's head), `1053` to `1100` (the drawer and the
  status bar), `1101` to `1162` (the frame's contract), `1163` to `1198`
  (the keyboard), `1231` to `1262` (the checks' head), `1741` to `1760`
  (the traps' head) and the rest of the traps by grep for `drawer`,
  `badge`, `hash`, `popstate`, `prefs`; `2069` to `2198` (the open items);
  `README.md:125` to `250` (agent C); `frontend/src/App.svelte`,
  `src/state/session.svelte.ts`, `src/state/prefs.svelte.ts`,
  `src/state/prefs.test.ts`, `src/frame/Drawer.svelte`,
  `src/frame/Breadcrumb.svelte`, `src/frame/Landing.svelte`,
  `src/frame/StatusBar.svelte`, `src/frame/Detail.svelte`,
  `src/lib/detail.ts`, `src/lib/rates.ts`, `src/lib/feedthrough.ts`,
  `src/lib/resolve.ts`, `src/lib/diagnostics.ts` (the model of a pure
  module feeding drawer rows), `src/canvas/size.ts`,
  `src/canvas/palette.ts`, `vite.config.ts`, `package.json`,
  `e2e/fixtures.ts`, `e2e/drawer.spec.ts`, `e2e/colors.spec.ts`,
  `e2e/detail.spec.ts`, `e2e/landing.spec.ts`, `e2e/frame.spec.ts` whole;
  `e2e/keys.spec.ts` by grep for `RESERVED`, `o`, `?` and `Escape`;
  `src/canvas/Canvas.svelte` by grep for `badge`, `BADGE`, `legend`,
  `data-mode`, `dim` and the `<style>` block; `src/lib/level.ts:1` to
  `101`.

## Bookkeeping, in the core repo

- This brief and `notes_inspector_08.md`, before launch.
- After the review and the look-and-adjust pass: this brief's "Built"
  section; `design/pending.md`'s stage-1 bullet records the landing;
  `roadmap_inspector.md`'s increment 8 gains its line with the facts the
  next brief takes, and its increment 10 line loses the version baking and
  the Vimium patterns (readings 3 and 4) once the user ratifies them; a
  record amendment the look pass settles lands as a docs commit first.

## Out of scope

- The schedule rows, the hyperperiod chart and the legend's concrete `Δt`
  and `(D, Φ)`: the deployment overlay's bump, a design session and a core
  format increment of their own (reading 1).
- The claim column of the root-inputs tab: stage 2.
- The release, the `base` path, the `dev/` to `stable/` flip, the Firefox
  project turning blocking: increment 10.
- A keyboard path for the drawer's rows, the right-click menu and the
  pane's face rows: the accessibility sweep the look pass of increment 7
  named.
- Searching docstrings (`doc:`): workspace answer 5's later prefix.

## After the build

- **The cold review**, below, in the worktree.
- **The look-and-adjust pass**: the user runs `npm run dev` in `frontend/`
  on `closed_loop`, `rates`, `library` and `primitive` with the badges on,
  every tab opened and sorted, three docstrings opened, and the help page
  from the landing and from a loaded model; the badge's corner and
  contrast, the tables' widths, the samples' look and the help page's
  typography are this pass's; what the user asks to change goes to the
  fixer as findings, one pass; what needs more is a note in increment 10's
  brief.
- **The merge**: `increment-8` rebased onto `master` and fast-forwarded,
  then the push and its CI run.

## The cold review

One fresh Opus reviewer in the worktree, the records' answers above read
for what they owe: open-mind stance, probe scripts in the scratchpad,
"empty is acceptable". It does not read the code for style. The same
context rules as the builders; it never launches Firefox. Dimensions:

- **The checks run.** `npm ci`, `npm run check`, `npm test`, `npm run
  build`, `npm run e2e -- --project=chromium` green from a clean
  `node_modules/` and a deleted `dist/`; `package-lock.json` consistent
  with `package.json` (`npm ci` refuses otherwise).
- **The oracle.** `analysis.py` over the fixtures against the table and
  the checks' counts; the reviewer's own reading of the badges, the edges,
  the consumers and the period order from the fixtures, a third
  implementation; a disagreement is a finding against the brief or the
  code.
- **The records against the page**, by probe and by screenshot: every
  sentence of the cited answers that falls in this increment holds, the
  readings above being the admitted departures; workspace 6 table by
  table on `closed_loop` and `rates`; answer 7 on `closed_loop` with the
  badges on; answer 11 section by section on the help page, the keys
  table against the map's; build 7's link rule on `library`'s rows, the
  three forms and the outside case, and the hostile source.
- **The bundle.** `grep` over `dist/` for `javascript:` in no rendered
  output path and for the two Vimium patterns and the docs constant once
  each; no network request but the page's own in the network check.
- **The mutants**, the list above, each on a scratch copy, each turning a
  check red; a surviving mutant is a missing check or an acceptable
  survivor named with its reason.
- **The look**: a headed browser through `npm run dev`, the fixtures named
  above dropped, every tab, the badges on at two levels, three docstrings,
  the help page's five sections; what reads wrong against the answers is
  a finding, and what reads badly without breaking an answer is an
  observation for the look pass.
- **The map** read against the tree: every file under `src/` named, the
  stores' section true to the code, every check's pins listed, the
  contract as implemented, the open items current.

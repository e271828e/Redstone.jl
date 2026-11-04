# Look pass: inspector increment 8

The user's checklist for the look-and-adjust pass over `increment-8` at
`bb2511f`, the review's fixes landed and verified, drawn from
`notes_inspector_08.md`, the three builders' headed looks and the open
items of `frontend/MAP.md`. Entries are numbered for discussion. The user's
rulings from the pass follow their entries.

Setup: `cd ~/.julia/dev/RedstoneInspector.jl-inc8/frontend && npm run dev`,
then drop fixtures from `frontend/fixtures/`. `o` toggles the badges, `d`
the drawer, `r` the color mode, `?` the help page.

## 0. Rulings before the look

- [ ] **0.1** Reading 1, the schedule rows and the hyperperiod chart not
  built; the timing tab says why in one sentence per kind. Already superseded
  in substance by increment 10's entry in the roadmap; confirm the two
  sentences read right until it lands.
- [ ] **0.2** Readings 2 to 4 move three items out of the release's
  increment: the docs constant, the baked version, the Vimium patterns.
  Ratify, and the roadmap's increment 11 line loses them at landing.
- [ ] **0.3** Readings 5 to 18: strike any, and the fixer reverts it.
- [ ] **0.4** Reading 19, ruled during the build: a clock pill that does
  not fit beside the order badge rides one row higher. Look at 2.3 before
  ruling.
- [ ] **0.5** Agent C's departure: a history entry made by a hash link or a
  typed hash is stamped as a level entry, so Shift-h now walks back from a
  typed level hash. Keep, or confine the stamp to `#help`.
- [ ] **0.6** Review finding 1: a primitive root's root-input row now
  selects the tag, agent A's premise having been false. Finding 6: the badge
  takes the pointer for its hover title. Both land with the fixer.
- [ ] **0.7** `build_release.md`'s pending note bites (notes, "For the
  user" 2): bare `@ref` links to parent-module names land at the API page's
  top. Settled by increment 10's writer change; nothing to do here.

## 1. The drawer's tabs: `closed_loop`

- [ ] **1.1** Root inputs: three rows, `mode` with seven consumers on one
  line each; `td.pinned` empty with its hover title explaining version 1.0.
  Does an always-empty column earn its place now?
- [ ] **1.2** A root-input row's click selects the tag on the root level
  (reading 11); the canvas does not pan to it, as a tree click does not.
- [ ] **1.3** Timing, anchors: the base grid's row reads "0 base grid",
  `Δt`, "0", "—", "the deployment's", the last in the key column (agent A's
  departure). Choose a better reading for the two empty cells, or leave.
- [ ] **1.4** Anchor rows 1 to 10 all `1/50 s`, each selecting its
  declaring assembly; a row whose scope is the root has no button. The scope
  buttons read as plain code, nothing showing they are clickable; `tau`
  reads "0/1 s" (reviewer).
- [ ] **1.5** Components: ten rows, the swatch the rate color in both modes
  (reading 13). The sort toggle "by period" reads right; the tab switch keeps
  it. An extra triple's swatch carries no "#9" number, unlike the canvas
  (reviewer; `large` shows it).
- [ ] **1.6** The schedule note's build sentence under the tables.
- [ ] **1.7** Execution order: 24 rows, stage-1 ports as open boxes, stage-2
  filled (agent A's rendering). Does the distinction read without a legend?
- [ ] **1.8** The edges under their consumer's row (reading 10), five under
  row 18, "presumed" in italics, the hover title's caveat. Read the title's
  sentence for tone.
- [ ] **1.9** An edge row's click selects the consumer's port square inside
  its level; a step row's click selects the leaf.
- [ ] **1.10** The tab body scrolls to its top on a tab switch and keeps its
  scroll across a push (agent A's addition).
- [ ] **1.11** The tables' widths at the drawer's default height and at a
  narrow window; the long consumer lists.

## 2. The order badges: `closed_loop`, `rates`, `primitive`

- [ ] **2.1** Reading 8 and 9: at the root with `o`, every leaf numbered
  from 1, each assembly its ranges, "4–5, 15, 17, 19" on `pid_controller`;
  the badge straddling the top edge at the left, background fill, text
  color; legible at the fit?
- [ ] **2.2** Inside `pid_controller`: 15, 17, 19, 4 and 5 just above the
  segments, covering no name.
- [ ] **2.3** Rate mode: the four raised pills (reading 19) float above the
  badges on `pid_controller`, `lqr_controller`, `selection`, `actuators`;
  `sensing` keeps both on the edge. The pills on `selection` and
  `actuators` sit on the wire along the drawing's top (agent B). A raised
  pill can read as the neighbour's: `rates`' `slow` under `fast`'s bottom
  edge, `pid_controller`'s "4 clocks" under `lqr_controller` zoomed in
  (reviewer). Keep, or move the pill elsewhere on a narrow block.
- [ ] **2.4** The breadcrumb's third control "order" beside "types" and the
  mode switch; the row's width at a narrow window.
- [ ] **2.5** `rates`: `fast` "2–3", `fast/outer` "3", `slow` "4".
  `primitive`: the leaf's "1".
- [ ] **2.6** The badges' tie to a dimmed block under a focus, and under the
  search's dim.
- [ ] **2.7** The badges are tiny at the root's fit (reviewer); their hover
  title now shows, the badge taking the pointer (review finding 6).
- [ ] **2.8** The Fit button covers `selection`'s badge zoomed in (reviewer).

## 3. The docstrings: `library` and `closed_loop`

- [ ] **3.1** `integrator`: the signature as a code block, the prose in the
  pane's font, seven links in the highlight color opening in a new tab;
  "Keywords" as a small heading over a list (agent B's departure).
- [ ] **3.2** `lqr`: fifteen links, the two long signature forms wrapping
  messily in their code block (reviewer).
- [ ] **3.3** A bare link to a parent-module name (`local_wires` in a
  `Group` docstring, through `closed_loop`'s `sensing`) lands at the API
  page's top (0.6).
- [ ] **3.4** `plant` (`RedstoneExamples.Longitudinal`): no links, the
  `@ref` texts as code.
- [ ] **3.5** The root's pane is the level layout and never shows its type's
  docstring, so a root `Group`'s docstring is unreachable (agent B). An
  item for a later increment, or the level layout gains the docstring?
- [ ] **3.6** The rendered block's typography against the pane: headings at
  13 px, list padding, code on the strip color.

## 4. The help page

- [ ] **4.1** From the landing's "help" link, from `?` on a loaded level,
  from the status bar's "?" (reading 18); each close (the button, `?`,
  Escape, back) returns where it came from with the hash restored
  (reading 5).
- [ ] **4.2** Reading the diagram: eighteen terms, thirteen samples at
  about 1:1 with the canvas (agent C). The five terms without a drawing
  leave an empty first column. Rule: a placeholder, text spanning the
  column, or as is.
- [ ] **4.3** The tier and rate sample fills are close in hue; the labels
  carry them.
- [ ] **4.4** The samples' construction: the tag sample repeats the
  canvas's `tagD` formula rather than sharing it (agent C). An item, or
  share now.
- [ ] **4.5** Coming from Simulink: thirteen rows (reading 15); the third
  column's notes are the agent's wording. Read them.
- [ ] **4.6** What the page does not do: the three refusals with the
  brief's reasons, the three "not yet" lines. Read for tone.
- [ ] **4.7** The keyboard: twenty rows in the map's order, `kbd` chips, the
  Vimium paragraph with both patterns (reading 4); the wording is the
  agent's.
- [ ] **4.8** About: the privacy statement shared with the landing,
  "inspector 0.1.0", "format major 1" (reading 16), three links in a new
  tab.
- [ ] **4.9** Section headings and the page's typography at 1600 and at
  700 px; the nav links scroll without changing the hash.
- [ ] **4.10** Under the help page the frame unmounts, so after the close
  focus falls to the body (agent C); Tab then starts from the page's top.

## 5. The keyboard and the shell

- [ ] **5.1** `o` and `?` act; nothing is swallowed any more. With the help
  page shown only `?` and Escape are the page's, Space and the arrows
  scroll.
- [ ] **5.2** Shift-h after a typed level hash now walks back (0.5); Shift-l
  from a level whose forward entry is `#help` reopens the page (reviewer).
- [ ] **5.3** Escape's chain: the help page first, then the route, the
  focused diagnostic, the legend's focus, the search, the selection.

## 6. After the pass

- [ ] **6.1** Record amendments the pass settles, docs commit first.
- [ ] **6.2** The merge: rebase onto `master`, fast-forward.
- [ ] **6.3** The push and its CI run; the Firefox `leave.spec.ts` item
  stands from increment 6.
- [ ] **6.4** The roadmap's line for increment 8, and increment 11's line
  losing readings 2 to 4's items; the brief's "Built" section; the pending
  bullet.

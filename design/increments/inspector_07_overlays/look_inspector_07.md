# Look pass: inspector increment 7

The user's checklist for the look-and-adjust pass over `increment-7` at
`8f686ce`, drawn from `notes_inspector_07.md` and the open items of
`frontend/MAP.md`. Entries are numbered for discussion. The user's rulings
from the pass follow their entries.

Setup: `cd ~/.julia/dev/RedstoneInspector.jl-inc7/frontend && npm run dev`,
then drop fixtures from `frontend/fixtures/`.

## 0. Rulings before the look

- [x] **0.1** Reading 1, the feedthrough edges not drawn. Keep it and the
  edges wait for increment 8's order tab, with a one-line amendment on
  `workspace.md`'s pending bullet. Strike it and they join as a wire mark in
  a fourth hue, which §7 must then fit.
- [x] **0.2** Readings 2 to 16: strike any, and the fixer reverts it.
- [x] **0.3** `pre.message` inside `button.row` is invalid HTML. A `span`
  with `pre-wrap` is the valid form, at the cost of the contract. Ruling:
  fix.
- [x] **0.4** The tree's rows and the pane's face rows are clickable but are
  not buttons. They are older than this increment: fix now or open an item.
  Ruling: an open item, for a later accessibility sweep.

## 1. `failure_nested`: a loop across a level

- [x] **1.1** The root reads as a red ring through `plant` and `ctl`'s
  `loop` pill.
- [x] **1.2** Reading 3: `plant` has member halos and no kind badge; the
  verdict is the drawer's text alone.
- [x] **1.3** The root draws five wires and marks two, the loop's
  `ctl|in|y` and `plant|in|u`.
- [x] **1.4** `ctl` carries the continuation badge.
- [x] **1.5** The tree marks `ctl` beside `plant`, and the root row.
- [x] **1.6** Reading 8: a mark's hover counts diagnostics, not rows; the
  root reads 1 for the one loop.
- [x] **1.7** With the loop's row focused, inside `ctl` the `⟨in⟩y` and
  `⟨out⟩u` pins stay undimmed with `ctl/pi|in|y` and `⟨out⟩u|in|u`, and
  `⟨in⟩ref` dims (agent A's departure).
- [x] **1.8** Where the chain leaves a level through a pin there is no
  badge, so the reader climbs by the breadcrumb.
- [x] **1.9** A selected `plant` under the red halo turns purple. Choose: the
  halos composing at 0.5, an opaque mark halo, or a mark halo just outside
  the selection's. Ruling: the halos compose at 0.5, as built. Two rings
  were tried and read worse.
- [x] **1.10** Reading 16: the loop row's location is `plant`'s type's
  `u_types` line. Useful for a loop, or dropped for cycles? Ruling: dropped
  for loops now. Later the core's format may carry each member's `y_direct`
  location, a spec change for `pending.md`, and the row then links one per
  member.

## 2. `failure_dead`: a dead hop

- [x] **2.1** The chord for `(m, g, F)` crosses `m`'s face labels.
- [x] **2.2** The dead hop's cross, ±3 px, is small at the fit and sits on
  the label column. Look at the fit and zoomed in.
- [x] **2.3** The chain `g2|in|e`, then `m|in|g`, is lit.

## 3. `failure_probe`: a probe throw and a warning

- [x] **3.1** Reading 4: `t`'s function badge straddles the bottom edge at
  the right. Its corner and shape; it covers no face name.
- [x] **3.2** Reading 5: the badge's hover shows the message's first line.
- [x] **3.3** Reading 5: a badge click opens the drawer on diagnostics with
  the row focused and scrolled into view.
- [x] **3.4** A pill click focuses the row and selects nothing, as the
  amended README says.
- [x] **3.5** `s/g`'s amber warning shares the drawer with the error; the
  filter works.
- [x] **3.6** `s/g`'s `EmptyFaceSelection` pill runs about 190 px on a
  130 px block, past its left corner.
- [x] **3.7** White on amber is the page's lowest-contrast text.
- [x] **3.8** The tree's `s` reads "1 warning, beneath" on the mark's hover.

## 4. `warning`: a clean build with one warning at `g`

- [x] **4.1** Amber alone, no red anywhere.
- [x] **4.2** A discrete leaf's orange rate dot beside an amber mark reads as
  two similar hues. Ruling: left as is; the tier dot sits left of the name
  and the mark right of it.

## 5. The drawer and the focus

- [x] **5.1** Reading 6: a row's click focuses it and dims the rest; a
  second click, Escape and a new model each clear it.
- [x] **5.2** Reading 7: one dimming focus at a time. Hold a legend line,
  focus a row, then trace a face; each takes over in turn.
- [x] **5.3** Escape peels the focuses one step at a time, in that order
  reversed.
- [x] **5.4** A search's dim composes with a held legend line as before.
- [x] **5.5** The dim's strength under each focus. Ruling: 0.35, shared by the search and every focus, after trying several values.
- [x] **5.6** A selected block's incident casings stay full under a focus.
  Ruling: they stay.
- [x] **5.7** A focused row attributed to the root or an unknown path lights
  nothing, so the whole level dims. Ruling: accepted.
- [x] **5.8** The message column runs narrower beside the location link.
  Ruling: the link moves under the message once loop rows carry locations
  again (1.10's second step).
- [x] **5.9** The rows and the filter have no keyboard path from Tab's
  cycle.
- [x] **5.10** The filter shows only when rows exist.

## 6. Routes: `closed_loop`, `rates` and a wire

- [x] **6.1** Reading 12: the status lines as the oracle gives them, `h_ref`
  2 across 3, `mode` 7 across 4, `rates`' `src/out` 3 across 4; a root face
  by its name alone; the singular for one.
- [x] **6.2** `mode`'s casings sharing a trunk add their opacity: a dark band
  with pale branches. Ruling: the trunk takes the branches' opacity.
- [x] **6.3** The terminal ports' 6 px stroke barely shows; the casings'
  ends do the work. Ruling: the casing is enough.
- [x] **6.4** On `rates`' short `in` pin the `route` pill covers most of the
  top edge.
- [x] **6.5** On a tall assembly the `route` pill sits bottom right, far
  from the entry port, and reads as a block mark.
- [x] **6.6** Reading 15: a child's route badge opens the child; a pin
  badge climbs and selects the child left; root pins carry no badge.
- [x] **6.7** The tree's blue dots mark only the levels crossed; a collapsed
  ancestor of one shows nothing. Ruling: the dots propagate to ancestors as
  the diagnostic marks do, if not too hard.
- [x] **6.8** A route stands across a new model that still declares its
  origin face, and across opening and closing levels.
- [x] **6.9** A route on a level it does not cross dims the level whole.
- [x] **6.10** Reading 13: right-click on a pin, a port square and a wire
  shows the one-entry "trace" menu.
- [x] **6.11** Reading 14: `t` traces a selected wire, and the wire's pane
  has the trace button.
- [x] **6.12** The pressed pane button and the status bar's clear control
  read right.
- [x] **6.13** Escape in the menu closes the menu and keeps the route; a
  press outside, the wheel and a level change close it too.
- [x] **6.14** The menu has no keyboard path, and its button takes no focus
  on opening.
- [x] **6.15** At a narrow width the status bar clips a long route line and
  can hide the clear control; Escape still clears.

## 7. The palette as a whole

- [x] **7.1** Red, amber and the route's blue side by side and against the
  rate hues.
- [x] **7.2** The purple and olive of a selected member (1.9).
- [x] **7.3** Orange against amber (4.2).
- [x] **7.4** If 0.1 is struck, the feedthrough edges' fourth hue. Moot:
  reading 1 stands.

## 8. After the pass

- [x] **8.1** The `workspace.md` amendment, if reading 1 stands.
- [x] **8.2** The merge: rebase onto `master`, fast-forward.
- [x] **8.3** The push and its CI run; the Firefox `leave.spec.ts` item
  stands from increment 6.
- [x] **8.4** The roadmap's lines for increments 6 and 7.

# Notes: inspector increment 8, the readings and their reasons

The coordinating session's record for `brief_inspector_08_analysis_help.md`:
the state at launch, each reading the brief takes where the records stop
short and why, what the user is asked to look at, and the build's outcome
as it unfolds. The user asked for the increment to be prepared and launched
on 2026-11-04 without a review of the brief first, so every ruling below is
the session's, recorded with its reason, and nothing is pushed.

## Launch state

Increment 7 landed at `63bc8b4` of `RedstoneInspector.jl`, merged and
pushed with CI run 41724649421 green, the Firefox project failing only
increment 6's two `leave.spec.ts` checks. The core's bookkeeping stands at
`68c6485`. The worktree `~/.julia/dev/RedstoneInspector.jl-inc8`
(`increment-8`) sits on `63bc8b4` with `npm ci` run and the root
`Manifest.toml` copied in. The oracle `scratchpad/oracle/analysis.py` sits
beside copies of the earlier increments' scripts; it takes the fixtures
directory as its argument, and its output over the tree as launched is
`analysis.before.out`. Its feedthrough counts (`closed_loop` 16, `library`
14, `containers` 5, `warning` 1) agree with the resolver oracle's and with
`feedthrough.test.ts`'s pins. The `marked` probe is `scratchpad/probe/`.

Three builders, as increments 6 and 7 ran them, one after the other in one
worktree: the analysis data with the drawer's tabs; the badges with the
docstrings; the help page with the map. The roadmap allowed the help page
to run in parallel on its own branch, but it shares `App.svelte` and the
session store with the others, so the serial order stands.

## Readings

1. **The schedule rows and the hyperperiod chart are not built.** The
   roadmap's line for this increment names "the schedule and hyperperiod
   chart over the deployment fixture". The format's `DeploymentBody` holds
   the build alone and says in its own description that the schedule rows,
   the concrete `Δt`, the hyperperiod and the grid report wait for a minor
   bump; `workspace.md` answer 7 says the chart is "waiting on the overlay
   bump", `visual_grammar.md`'s bump list and `descriptor_design.md`'s
   pending list name the bump as a session of its own, and `pending.md`
   says the bump "stands as `visual_grammar.md` hands it on". The record
   wins over the roadmap, as reading 1 of increment 7 settled, and the
   bump is a design session plus a core format increment, not a frontend
   increment's half. Answer 6 already asks for the build's sentence ("a
   build descriptor saying they need a deployment"); the deployment's
   sentence is this reading's addition, so a reader of the deployment
   fixture is told why the tab is short. For the user: strike this and the
   bump runs first, a core increment with a spec edit (§13.9), a re-pin and
   regenerated fixtures before this increment's timing tab.
2. **The docs address constant lands now.** The roadmap puts "the docs
   address constant" in increment 10 and "the docstring link rule" in this
   one; the rule cannot run without the constant. Answer 7 fixes the value,
   `https://e271828e.github.io/Redstone.jl/dev/`, and the hosted `dev/` API
   and glossary pages answer 200 today with the anchors the rule expects
   (`Redstone.x_init`, `Redstone.Blocks.Junction`, `g-assembly`, checked
   2026-11-04). Increment 10 keeps the `dev/` to `stable/` flip, which is
   the pin bump's.
3. **The bundle version is baked now.** The about section names "the
   bundle and format versions"; answer 8 says how, three lines in
   `vite.config.ts`. A placeholder reading badly for one increment is not
   worth the deferral. The roadmap's increment 10 line loses the item.
4. **Both Vimium patterns are written now.** They are two fixed strings of
   answer 7, and the keyboard section is this increment's. Increment 10
   checks them on the hosted copy.
5. **The help page is a history entry.** Answer 11 puts the page "at
   `#help`"; answer 3 makes the hash the open level and back and forward
   move between levels. A page that replaced the level's hash would lose
   the level on reload and leave `history.back()` meaningless on the help
   page; one pushed over the level's entry closes by back, by `?`, by
   Escape or by its button, and a reload at `#help` shows the page over
   whatever loads under it. Escape closes it before anything else, since
   nothing else is visible. The keys are the browser's while it shows, so
   the page scrolls by Space and the arrows.
6. **`@ref` links are rewritten before Markdown parsing.** The probe: to
   CommonMark `(@ref g-primitive)` is no link destination, its space
   ending the destination, so `marked` leaves the glossary form as text;
   the bare form parses as a link whose `href` is `@ref`. One regex pass
   over the source handles both and keeps the renderer's hooks for the
   security rules. Documenter's explicit non-glossary targets
   (`@ref Redstone.trim!`, two in `LQRTracker`'s docstring) are bindings,
   so they take the API anchor as written when qualified.
7. **Hostile Markdown is neutralized in the renderer.** Answer 7 rules raw
   HTML out; a dropped file could also carry a `javascript:` link or an
   image fetched from another site, which the privacy statement forbids.
   Links kept open in a new tab so the leave prompt of a file-loaded model
   never fires on a docstring click.
8. **Positions are 1-based.** The artifact's `order` is a Julia vector,
   the record's example reads "3–5, 8", and a reader counts from one.
9. **The order badge straddles the top edge at the left.** Answer 7 says
   "top-left corner"; increment 6's rate pill found that a pill inside the
   corner covers the segment, which answer 10 never cuts, and moved to
   straddle the top edge at the right, leaving the top-left for this
   badge (the map's open item). Mirroring the pill keeps one shape and
   covers no name. "The badges use the text color" reads as a neutral
   badge, so the background fill with the text color's stroke and text.
10. **The feedthrough edges sit under their consumer's row.** The pending
    bullet wants each edge "beside the stage ports it lists"; the stage
    ports are the leaf's row, and an edge ends at a leaf's input, so the
    consumer's row is where its stage-2 output's presumed dependence is
    read. The hover title carries the bullet's caveat, the overstatement.
11. **A root-input row's click selects the root tag.** Answer 6: "a row
    selecting the root pin". The consumers stay text because the pane
    shows them as links once the pin is selected, and a table of nested
    buttons reads badly. The pinned column stays: the record lists the
    mark and the format may carry it once the wire pass keeps the marker.
12. **The anchor table's first row is the base grid.** Answer 6: "anchor 0
    as the base grid". Its `T` is the deployment's `Δt`, which no build
    knows, so the cell says so. A row's click selects the declaring scope's
    node, the nearest element the anchor has; the base grid declares
    nowhere. "Sortable by period" takes `tripleOrder`'s order, which the
    legend and the palette already use, so the table and the colors agree;
    anchor 0's period in seconds is unknown, which is why it sorts first.
13. **The components' swatch is the rate color whatever the mode.** Answer
    6 says "with its rate-mode swatch", and a swatch that turned gray in
    tier mode would carry no information.
14. **The legend section lists the glossary's fifteen terms plus block,
    face and wire.** Answer 11: "a legend of `visual_grammar.md`'s terms
    with their drawings, one line each". The glossary presumes block, face
    and wire, which the drawings need first. Five terms name no drawn
    thing and take a line alone.
15. **The vocabulary table is the record's list.** Thirteen pairs, counted
    from answer 11; the refusals and the "not yet" items as answer 15 and
    answer 11 list them, nothing added.
16. **The about section names the inspector's version and the format's
    major.** The schema copy fixes the major as a `const`; the minor is the
    writer's and no constant of the schema, so the section does not invent
    it.
17. **`o` and the breadcrumb's control share one pref.** Answer 7: the
    settings persist per browser; answer 11 gives `o` the badges. Prefs
    version 1 keeps a missing field at its default, as `labels` showed.
18. **The help links are plain hash links.** The history handler already
    reads every hash change; a handler of their own would push a second
    entry.
19. **A clock pill that does not fit beside the order badge rides one row
    higher** (ruled during the build, 2026-11-04). Agent B measured
    `closed_loop`'s root in rate mode: on four of its five assemblies the
    badge and the pill together need 10 to 34 world units more than the
    block's width, so the brief's "not overlapping" pin cannot hold with
    both straddling the edge. Reserving the badge's width in `sizeBlock`
    would make a block's size depend on the toggle, which the rate pill's
    trap already rejected; raising the badge breaks its spanning pin;
    dropping the pin loses the clock count. The pill moves up one row on
    those blocks alone, the badge keeps the edge, and the pin reads "not
    overlapping, the pill raised above the badge's row when the block is
    too narrow for both". For the user: a look-pass item, since where the
    pill lands on a wide block and a narrow one now differs.

## For the user

1. Read the readings; strike any, and the fixer reverts it. Reading 1
   changes what the roadmap promised and deserves the first look; readings
   2 to 4 move three small items out of increment 10's line.
2. The pending note of `build_release.md` bites: a bare `@ref` to a name of
   a parent module (`local_wires`, `input_wires`, `output_wires`,
   `sample_times`, `transparent_container` in every `Group` docstring,
   `AsPort`, `Pinned`, `StopFlag`, `stop_reason` elsewhere) resolves to
   `api/#Redstone.Blocks.<name>`, an anchor the API page does not have, so
   the link lands at the page's top. The brief pins the rule as the record
   states it. A fix needs a table of the API page's anchors the bundle does
   not have; the cheapest form is a generated list from the core's
   `docs/build` at pin time, a `scripts/` job of its own. Your call for a
   later increment.
3. After the review, the look-and-adjust pass: `npm run dev` in the
   worktree's `frontend/` on `closed_loop`, `rates`, `library` and
   `primitive` with the badges on, every tab, three docstrings, and the
   help page from the landing and from a loaded model.
4. The merge and the push; the Firefox project's `leave.spec.ts` item
   stands from increment 6.

## Build outcome, 2026-11-04

Agent A built stages 1 and 2 on `increment-8` in
`~/.julia/dev/RedstoneInspector.jl-inc8`, not pushed: `50d1391`
`analysis.ts` with its tests and `prefs.order`; `03e21df` the three tab
components under `src/frame/tabs/`, the drawer hosting them through `onrow`,
`analysis.spec.ts`, `frame.spec.ts`'s placeholder pin replaced. `npm run
check` 390 files, 0 errors; `npm test` 489 tests in 28 files; `npm run e2e
-- --project=chromium` 184 checks. Every oracle count matched. Its
departures, accepted and recorded in its notes for the map:

- **Every row carries a `kind`** (`order`, `edge`, `root-input`, `anchor`,
  `scope`, `component`) so `rowTarget` tells rows apart; `ranges` is
  exported.
- **A structureless model** gets `[]` from every function and one `p.empty`
  in the timing tab, "No timing: the descriptor carries no structure."
- **A primitive root's input row selects its port** `|in|u` through
  `faceSelection`, the brief's tag being the reading for an assembly root;
  the reviewer checks what the primitive level draws for that face.
- **The base grid's row** reads "0 base grid", `Δt`, "0", "—", "the
  deployment's", the last in the key column; the look pass's.
- **An anchor row whose scope is the root has no button**, as the brief's
  reading 12 implies.
- **The sort state lives in the drawer**, kept across a tab switch, no pref.
- **The tab body scrolls to its top on a tab switch** and keeps its scroll
  across a push, both pinned; the headed look found the timing tab opening
  mid-scroll.
- **Screenshots** `analysis-order` and `analysis-timing` of `closed_loop`'s
  root at a 420 px drawer; an extra check pins a push keeping the open tab.
- **A consumer separator** Svelte collapsed is pinned.

Its headed look: the three tabs read cleanly on `closed_loop`, `rates` and
`library`; stage-1 ports as open boxes, stage-2 filled; every row click
landed where the brief says. Observations for the look pass: a row's click
does not pan the canvas to a selected tag or port, as a tree click does
not; a port selection does not expand the tree. Agent B, the badges and the
docstrings, follows from `03e21df`.

Agent B stopped once, having committed nothing, on the badge and the clock
pill not fitting side by side (reading 19), and was resumed with the ruling.
It built stages 3 and 4 from `03e21df`: `8ed376f` the order badges with `o`
and the breadcrumb's toggle, the rate pill riding one row above the badge
on a block too narrow for both, `order.spec.ts`, `keys.spec.ts` amended;
`fea2034` `marked` 18.1.3 pinned exactly, `docstring.ts` with eleven unit
cases, the pane's rendered docstring, `detail.spec.ts` amended with the
hostile copy of `primitive`. `npm run check` 0 errors; `npm test` 500 tests
in 29 files; `npm run e2e -- --project=chromium` 188 checks; `npm ci` clean;
`dist/` free of `javascript:`. Its departures, accepted and recorded in its
notes for the map:

- **One `orderWidth` helper** serves the badge and the fit test; the raised
  pill sits `BADGE_GAP` above the badge's row.
- **The reload and deployment pins** read `pid_controller/h_ctl`'s "15",
  the hash keeping the open level across both.
- **A click on the badge's lower half selects the block**, pinning "never
  takes the pointer".
- **Rendering uses its own `Marked` instance**; headings in a docstring
  render at 13 px, lists with some padding; the pane's shared monospace
  rule loses `pre`, now unused; `detail.spec.ts` carries its own copy of the
  docs URL literal.

Its headed look: `integrator`'s seven links and `lqr`'s fifteen in the
highlight color, the signature forms wrapping inside their code blocks,
`plant` with none; the badges legible at the fit, the four raised pills
clear of the badges, two of them sitting on the wire along the drawing's
top (a look item); inside `pid_controller` each badge just above the
segment. Observations for the look pass: the root's pane shows the level
layout and never its type's docstring, so a root `Group`'s docstring is
unreachable; the 404 at load is the favicon's, an old item. Agent C, the
help page and the map, follows from `fea2034`.

Agent C built stages 5 and 6 from `fea2034`: `be046a3` the help page with
its eighteen terms and thirteen samples, the session's `help` state over
the hash, `?`, the two links, the build-time defines, `help.spec.ts`,
`keys.spec.ts`, `landing.spec.ts`, `frame.spec.ts` and `network.spec.ts`
amended; `226fb4b` the map and the README. `npm run check` 398 files, 0
errors; `npm test` 504 tests in 29 files; `npm run e2e -- --project=chromium`
192 checks; `dist/` holds each Vimium pattern and the docs constant once
and no `javascript:`. Its departures, accepted and held under review:

- **A history entry with a `null` state is stamped one entry deeper** by
  `openFromHistory`, since a hash link or a typed hash creates one; without
  it a help page opened from a link closed by replacing its entry, leaving
  two identical level entries and Shift-h dead. Side effect: Shift-h now
  walks back from a typed level hash. The one behaviour change outside the
  help page; the reviewer probes it.
- **The nav links are not real hash links**, a real hash change closing
  the page through the history handler.
- **Stage 5 already amended the map's keyboard table**, since `help.spec.ts`
  counts its rows against `table.keys`.
- **The Vimium patterns are literal strings**, the minifier leaving a
  template unfolded.
- **The about section reads "format: major 1".**
- **Extra checks**: Space scrolling the page, the about link keeping
  `#help`, `goForward` after Escape pinning the close as a back, ArrowDown
  inert, a drop under a page loaded at `/#help`.

Its headed look: the samples read as the canvas's own marks at about 1:1,
two fixes made during the look (the dimmed block's text, the hue swatches'
spacing); the vocabulary, keys, Vimium paragraph and about read well at
1600 and 700 px. For the look pass: the five terms without a drawing leave
an empty first column; the tier and rate sample fills are close in hue; the
vocabulary notes, section headings and Vimium wording are the agent's; the
tag sample repeats `tagD` rather than sharing it; the frame unmounts under
the help page, so focus falls to the body after the close. The map's open
items name increment 10 for the release's items (the docs flip, the Vimium
check), which the roadmap renumbered to 11 on 2026-11-04; the fixer amends
them. The cold review follows at `226fb4b`.

## The cold review, 2026-11-04

One Opus reviewer over `63bc8b4..226fb4b`, every check green from a clean
install (`npm run check` 398 files, `npm test` 504 tests in 29 files, `npm
run e2e -- --project=chromium` 192 checks, `npm ci` accepting the lock),
the oracle rerun byte-identical, its own third reading of the positions,
badges, edges, consumers, anchors, scopes and both component orders, and of
every `@ref` URL, agreeing on every fixture; workspace 6 row by row on
`closed_loop` and `rates`, answer 7 in both modes at two levels, answer 11
section by section with the keys table checked against the handler, build
7's rule on 38 blocks and 29 hostile inputs, the help page's history in
twelve scenarios, all holding by probe. The bundle: no `javascript:`
anywhere, each Vimium pattern and the docs constant once. Of 38 mutants 33
die; five survive, two as findings below and three acceptable (the badge's
pointer, a line break inside an `@ref` gap, the pinned column with no
pinned fixture). Seven findings, all low, each ruled by the coordinating
session:

1. **A primitive root's root-input row selects the leaf's port, not the
   tag**, agent A's premise that no tag is drawn there being false (the
   level draws `⟨in⟩u` and `⟨in⟩d`). Accepted: the tag, the unit case and
   the map amended.
2. **The help keys table omits Ctrl-K**, which the handler takes beside
   Cmd-K. Accepted, in `KEYS` and the map's table together.
3. **The format major is hand-kept** in `protocol.ts` (`MAJOR = 1`) and
   `loader.ts` (a literal and "format 1.0"), against build 8. Accepted:
   both read `__FORMAT_MAJOR__`.
4. **Agent C's null-state stamp has no check** (mutant 26 survived).
   Accepted: a link-opened page closing by back, and a typed level hash
   then Shift-h returning.
5. **"The badge dims with its block" has no check** (mutant 27 survived).
   Accepted: the effective opacities compared under a search.
6. **The badge's `<title>` can never show** under `pointer-events: none`,
   and the lower-half click cannot pin the pointer rule (mutant 28). Ruled:
   the badge takes the pointer so its title shows, a click selecting the
   block as the bubbling already does; the map's claim corrected; the click
   check kept as the click's pin.
7. **The map's open items say increment 10** for the release's items;
   renumbered to 11.

Observations for the look pass, added to `look_inspector_08.md`: a raised
clock pill can read as a neighbour's (`rates`' `slow` under `fast`,
`pid_controller`'s under `lqr_controller`); the badges are tiny at the
root's fit; the anchor table's scope buttons read as plain code; `tau`
reads "0/1 s"; an extra triple's swatch carries no number, unlike the
canvas; `LQRTracker`'s signatures wrap messily; Shift-l from a level whose
forward entry is `#help` reopens the page; the Fit button covers
`selection`'s badge zoomed in. The fixer follows at `226fb4b`.

## The fix, 2026-11-04

The fixer landed the seven findings as `6dcf5d5`: `rowTarget` selecting
the root tag for every root, the unit case renamed and the map's line
amended; Ctrl-K in `KEYS` and the map's table together; `MAJOR` read from
`__FORMAT_MAJOR__` and the loader's comparison, refusals and note using it;
two `help.spec.ts` checks, a link-opened page closing by back with
`goForward` showing it again, and a typed level hash then Shift-h returning
to the root; an `order.spec.ts` check comparing a non-hit badge's effective
opacity with its block's shape under a search, `plant`'s at 1; the badge's
`pointer-events: none` removed, with a check that `elementFromPoint` on its
upper half hits the badge, and the map's claim corrected; the open item
renumbered to 11. `npm run check` 398 files, 0 errors; `npm test` 504 tests;
`npm run e2e -- --project=chromium` 195 checks. Mutant 26 turns both new
help checks red, mutant 27 the dimming check, and `pointer-events: none`
put back the pointer check. Two notes from the fixer: `faceSelection` is
unchanged, so a search hit on a primitive root's face still selects its
port; two comments (`App.svelte`, `search.spec.ts`'s header) still say
"`/` and Cmd-K" without Ctrl-K. The reviewer verifies the delta next.

The reviewer, resumed, verified every fix at `6dcf5d5` and ran the gate
again, green at the same tallies; its mutants 26 and 27 turned the new
checks red, and `pointer-events: none` put back turned the pointer check
red. One acceptable survivor of its own: Ctrl-K dropped from `KEYS`, since
the help check counts the table's rows and not their keys. The coordinating
session landed the three leftover "Cmd-K alone" mentions (the README, a
comment in `App.svelte`, `search.spec.ts`'s header) as `bb2511f`, the type
check green. The branch stands at `bb2511f` for the look pass.

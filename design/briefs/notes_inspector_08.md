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

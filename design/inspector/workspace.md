# The workspace: axis 5 of the inspector's stage 1

The record of one session, on 2026-10-27, that fixed the page around the
diagram: the frame, the tree, navigation, selection and the detail pane,
search, the drawer, the analysis views, face routes, view state across
pushes, files and the hosted copy, the help page and the keyboard. It builds
on `initial_design.md`'s answers 8, 9 and 15 and on `visual_grammar.md`, and
never restates them; where it amends one, it says so. Like its parents it is
not normative. Stage 4 has settled that its cockpit is a docking layout over
this page, so what this record builds must rehost as dock nodes.

## Pending questions

Left open on purpose, each with its owner.

- **A feedthrough emphasis.** A mark on every wire whose producer port is
  stage 2 into a block with a stage 2, derived from the stage lists the
  descriptor carries. Cheap, and distinct from the general feedthrough view
  `initial_design.md`'s answer 9 deferred, which needs the tracer's maps:
  this one is the build's presumed structure, not the traced one, and
  overstates dependences inside a block. Held until it can be labelled so.

## Answered questions

1. **The frame: a fixed grid now, dock nodes later.** The tree on the left,
   the canvas at the center with the breadcrumb above it and a one-line
   status bar below, the detail pane on the right and the drawer at the
   bottom, in a grid with draggable splitters; each side pane collapses to
   a thin strip with its icon. The status bar carries the block and wire
   counts, the color mode and, from stage 2, the connection state. No
   docking library in stage 1: the panes are self-contained components with
   no knowledge of their position, so stage 4's dock hosts them as nodes and
   replaces only the grid. Splitter positions and collapsed panes persist
   per browser in local storage, presentation state and never model state.
   *Why:* a dock carries its weight and upgrade exposure through two stages
   with nothing to dock, the spike's lesson on a dependency held for a later
   need; the grid is a few dozen lines to replace. Answer 12's refusal of
   saved layout is untouched, since no block position is stored.

2. **The tree: the node list as an outline, selection and opening apart.**
   One row per node in walk order, nested by the parent rule; the root row
   labelled by the envelope `name`, else the root type's display name; an
   assembly row expands, a leaf row does not; a keyed container's elements
   sit under a folder row named by the field, which is no node and on a
   click highlights the region and shows the field in the detail pane; a
   transparent container's elements sit under the parent. Root inputs are
   faces and stay in the drawer; a primitive root is one row. A row shows a
   color dot following the canvas's mode, the segment and the display name
   in lighter text, a chevron on an assembly, no icon. Selection is shared:
   a click on a block selects its row and scrolls to it, a click on a row
   selects the node and makes the canvas show its parent's level, opening
   it if need be. Opening is the double-click on an assembly row or the
   chevron's affordance, the same gesture as on its block; the open level's
   row is bold with a marker. Expansion state is kept by path across
   pushes, the root expanded one level by default. Dots propagate upward: a
   red dot on a row whose subtree holds a diagnostic, amber for a warning,
   blue for a level a route passes, counts on hover; search hits take the
   dashed marker; the tree never filters.
   *Why:* the tree is the descriptor's node list, so it costs nothing to
   derive and always agrees with the canvas; selecting a closed assembly to
   read its detail must not force opening it. *Rejected:* root inputs as
   pseudo-rows under the root, which would read as components; a single
   click opening an assembly, Simulink's model browser, for the reason
   above.

3. **Navigation: one gesture to open, the breadcrumb and the URL hash to
   move.** A closed assembly opens by double-click on its block or its tree
   row, by the chevron's affordance, by Enter when selected, or by the
   badge a loop chain or a route leaves on it, which opens the child with
   the chain still highlighted. A level fits to view when first opened and
   restores its own zoom and pan when revisited, kept per path for the
   session. The breadcrumb spells the open level's path as links, the root
   labelled as the tree labels it; Backspace or Alt-Up goes to the parent.
   The open level is the page's URL hash, `#level=aircraft/loops`, so back
   and forward move between levels, a reload reopens the level and a level
   is linkable in the hosted copy; the file is never in the URL. On load
   the root opens, fitted, the tree one level deep, nothing selected; a
   failure descriptor opens the same way with the drawer on its
   diagnostics. After a push the open level stays by path and otherwise
   falls back to its longest prefix that is still an assembly, the root at
   worst, noted in the status bar; a surviving level keeps its view, a
   fallback fits. Drag pans, the wheel zooms about the pointer, a corner
   button and `0` fit, `+` and `-` zoom.
   *Why:* a single click must select, including a closed assembly, so
   opening needs a second gesture everywhere. *Rejected:* a history entry
   per selection, which turns the back button into an undo of clicks.

4. **Selection and the detail pane: one element, the level when none.**
   Single selection, a block, a region's folder, a wire, a pin or a port
   square, Escape clearing it; with nothing selected the pane shows the
   open level, its path, display name, counts, faces and scope timing. A
   leaf block shows, in order: the header with segment, display name and
   path with a copy button; a facts line with class, tier, the timing read
   out and the membership when `key` is present; the alias and qualified
   type, the signature wrapped in monospace and collapsed; the docstring
   rendered from Markdown by a bundled renderer, a Documenter `@ref` link
   rendered as its code text, linking being axis 7's; the locations one per
   declaration, a click opening the file in the editor through the server
   in the live session (axis 6) and copying the path in the hosted copy;
   the parameters as a name and summary table; the faces, inputs then
   outputs, each with name, type, the kind marker as a short phrase,
   "vector 3 of float", "struct {x, y}", the pinned mark and an output's
   stage, an input naming its terminal producer and an output its
   consumers as clickable paths, a row click selecting the port. A closed
   assembly shows the same without tier and timing, with its child count,
   its faces typed through the resolution and an open button; a folder its
   field, count and keys as links; a wire its declared endpoints, the
   terminal leaf port behind an assembly face, the type and kind phrase
   from the terminal producer and its level; a pin or port its face's
   facts, what feeds it, the `root_inputs` row and later the claim for a
   root input, and a trace button starting the route of question 8.
   *Why:* everything here is in the descriptor or in the resolution the
   client already does; an empty pane teaches nothing. *Rejected:*
   multi-selection, with no reader until stage 4's panels; a pane following
   hover, which fights reading.

5. **Search: a substring over path, type and face names, on the tree.** A
   field at the top of the tree pane, focused by `/` or Cmd-K, its results
   replacing the outline while a query is active. Case-insensitive
   substring over the whole model's paths, types with their aliases and
   face names, never a regular expression and never a parse of a name
   (D-418); a bare query matches all three fields, the prefixes `path:`,
   `type:` and `face:` narrow to one, space-separated terms all match. One
   row per hit grouped under nodes and faces, the matched text emphasised,
   the count in the group header, capped at a hundred rows with a refine
   note; arrows move, Enter selects as a tree click does, Escape clears; the
   query survives a push. Hits take the dashed halo on the open level,
   blocks for nodes and port squares for faces, the rest of the level
   dimming; tree rows take the dashed marker with the count propagating up
   collapsed subtrees; the tree never filters. Docstrings and parameter
   summaries are not searched in stage 1; a `doc:` prefix can join later.
   Diagnostics have the drawer's own filter.
   *Why:* a face named `q` matches half a model without a prefix; the block
   searched for is usually on a level the user cannot see. *Rejected:* a
   fuzzy matcher, which ranks guesses where the user typed a name they
   know; searching the open level only.

6. **The drawer: four tabs, collapsed unless something is wrong.**
   Diagnostics: one row per diagnostic with kind, attributed path and
   message, the error hue and amber, a text filter, the count on the tab, a
   click selecting the element and navigating to it, a loop opening its
   first member's level with the chain lit; the empty state says so. Root
   inputs: name, type, kind phrase, pinned mark, terminal consumers and,
   from stage 2, the claiming writer, a row selecting the root pin; the
   home of stage 3's input widgets. Timing: anchors with index, `T`, `tau`
   and the declaring scope and key, anchor 0 as the base grid; scopes with
   path, key and triple; components, every discrete leaf with its triple in
   walk order, sortable by period, with its rate-mode swatch; the
   deployment overlay's schedule rows and hyperperiod chart join here, a
   build descriptor saying they need a deployment. Execution order: the
   `outputs.order` numbered, each row the leaf's path with its stage 1 and
   stage 2 ports. The drawer opens on load only when a diagnostic exists,
   on that tab, and otherwise stays collapsed to its tab strip with the
   counts readable; its height is a remembered splitter; every row in
   every tab selects on the canvas and navigates as a tree click does; each
   tab is a self-contained component for stage 3's panels and stage 4's
   dock.
   *Why:* the tables are a second navigator, not a listing, and a quarter
   of the canvas's height is too much to spend on tables most sessions
   never open. *Rejected:* one mixed log instead of tabs; the drawer open
   by default.

7. **The analysis views: three controls, global order badges.** At the
   right end of the breadcrumb row a segmented switch for the color mode,
   a toggle for the type labels and a toggle for the execution-order
   badges, nothing else; the fit button and the legend stay in the canvas
   corner, and the port-class glyphs are not a toggle. The settings persist
   per browser and survive a push. With the badges on, every leaf block
   carries its position in `outputs.order` in its top-left corner, numbered
   over the whole model, and a closed assembly the range or ranges of its
   leaves' positions, "3–5, 8"; the badges use the text color. A
   deployment descriptor adds the concrete `Δt` and `(D, Φ)` to the legend
   and the schedule rows and the hyperperiod chart, a timeline over one
   hyperperiod with a row per triple and a mark per firing, to the drawer's
   timing tab, all waiting on the overlay bump.
   *Why:* the order is global and the badge's question, whether this block
   runs before that one, crosses levels. *Rejected:* badges numbered per
   level; a toolbar carrying every toggle the page has.

8. **Face routes: the value's whole path, started on purpose.** A face's
   route runs upstream to its one terminal producer, a leaf output or a
   root input pin, and downstream through every fan-out to every terminal
   consumer, a leaf input or a root output pin, crossing boundary faces:
   a tree with one root, what `face_routes` derives in the core and the
   client derives from the same wires. It starts only by the detail pane's
   trace button, a "trace" entry on the right-click menu of a pin, a port
   square or a wire, or `t` with one selected, a wire's route being its
   producer face's; one route at a time. It draws as `visual_grammar.md`'s
   answer 9 says, and in addition a pin the route leaves the level through
   gets the badge, a click on it going to the parent with the route lit,
   and the status bar names the route, "tracing `aircraft/δe`: 3 consumers
   across 2 levels", with a clear control. It survives navigation and a
   push whose descriptor still has its origin, recomputed; it clears on
   Escape, on the trace action repeated or on another route; selecting
   something else leaves it standing. This amends `initial_design.md`'s
   answer 9, whose "selecting a root face highlights its chain" becomes an
   explicit trigger.
   *Why:* a route dims the level, which must not fire on every click near
   its edge; the route belongs to the value, not to the end clicked.
   *Rejected:* tracing on selection; half routes by the face's side.

9. **View state: three lifetimes, keyed by path and name, never by
   index.** Per browser, in local storage: the splitters and collapsed
   panes, the color mode, the two toggles, the drawer's height. Per tab for
   the session, in memory: the open level in the URL hash, each visited
   level's zoom and pan, the tree's expansion, the selection, the standing
   route, the search query, the drawer's open state and tab, and each
   level's block positions, the layout's output plus drags. Per push,
   everything in the second group is rekeyed against the new descriptor
   and what has no key is dropped, the open level's fallback noted in the
   status bar. The keys: a level and a node by path; a wire by its level's
   path and consumer endpoint; a pin by level path, side and face name; a
   port by node path, side and face name; a route by its origin's key;
   positions by level and node path. On a relayout after a push the
   surviving blocks' previous positions go to ELK as hints, a dragged
   block's being its dragged place; the mechanism is axis 4's, untested in
   the spike. A push of a different model follows the same rules, since
   the session cannot tell a rebuild from a same-shaped model. A second
   tab is a second session: `inspect(world; name = "variant")` pushes to
   the tab bound to that name, opening one if none is, the unnamed call to
   the default tab; axis 6 owns the API.
   *Why:* a renamed block is a different node to the format, so losing its
   selection is the honest outcome. *Rejected:* persisting session state
   across reloads, which resurrects a selection into a descriptor that may
   have changed with no push to rekey against; any index key, the spike's
   wire index being the motivating case.

10. **Files and the hosted copy: drop or pick, check the header, one model
    per tab.** A `.json` file opens by drop anywhere on the page or by the
    open control at the left end of the breadcrumb row; before a model is
    loaded the canvas shows a landing panel with the privacy statement, the
    open control, a drop hint and the help link. The page parses the JSON
    and reads the header: another `format_version.major` is refused naming
    both versions, a higher minor loads with unknown fields ignored and a
    status note, a missing body or a body without `structure.nodes` is
    refused naming what is missing; the schema itself is never validated
    at runtime. The label is the envelope `name`, else the file's base name
    for a dropped or picked file, else the root type's display name, one
    step more than `visual_grammar.md`'s answer 10. A second file in a tab
    replaces the model under answer 9's rules; two models are two tabs. The
    status bar names the kind; a failure descriptor opens with the drawer
    on its diagnostics and the overlay lit. The live tab offers a download
    of the current descriptor named after the model. The privacy statement,
    on the landing panel and the help page: the file is read inside the
    browser and never uploaded, and the page loads nothing from the
    network.
    *Why:* a wrong file should fail in words, and the structural check is
    the cheapest thing that does it; the hosted copy and the live session
    share one bundle, so the statement holds for both. *Rejected:* a
    recent-files list, which stores contents in the browser; a URL naming a
    local file.

11. **The help page and the keyboard: five sections, Vim's cursor on the
    diagram.** A page in the bundle at `#help`, reached from the landing
    panel, `?` and a status-bar link. Its sections: reading the diagram, a
    legend of `visual_grammar.md`'s terms with their drawings, one line
    each; coming from Simulink, the vocabulary map as a table, assembly and
    subsystem, `Group` and virtual subsystem, leaf and block, face and
    port, root input and Inport, root output and Outport, rate scope and
    sample time, kind marker and data type, a stage 1 output and a
    non-direct-feedthrough output, `Junction` and Sum or the logical
    operators, `Pack` and `Unpack` against Mux and Demux, a face route and
    signal highlighting, the tree and the model browser; what the page does
    not do, the refusals with one reason each, editing, saved layout,
    author icons, then what is not here yet, run control, live values and
    panels, stages 3 and 4; the keyboard; about, with the privacy
    statement, the bundle and format versions and the links. The keys,
    single and outside text fields:

    | key | action |
    |---|---|
    | `h` `j` `k` `l` | move the selection to the nearest block or pin in that direction, the view following |
    | Shift with `h` `j` `k` `l`, arrows | pan the canvas |
    | Enter, Backspace or Alt-Up | open the selected assembly, go to the parent |
    | `0` `+` `-` | fit, zoom in, zoom out |
    | `/`, Cmd-K | focus search |
    | `t` | trace the selected face or wire |
    | `r` `y` `o` | rate mode, type labels, order badges |
    | `d`, `?` | toggle the drawer, the help page |
    | Escape | clear the route, then the search, then the selection |
    | Tab | move focus between the tree, the canvas, the detail pane and the drawer |

    Focus shows as the halo and every control is a real button or link.
    Dragging has no keyboard form in stage 1. The keyboard section says
    that Vimium owns many of these keys by default and that the user
    excludes the inspector's origins, `localhost` on the server's port and
    the hosted address, or uses its insert mode; the live session printing
    the pattern once is axis 6's.
    *Why:* the selection is the diagram's cursor, so `h j k l` move it and
    the view follows, as in Vim, with panning the secondary action; the
    arrows keep the view on familiar keys for everyone else. *Rejected:* a
    guided tour, a second help page that interrupts; modifier-heavy
    shortcuts, which collide with the browser's and with Vim-style
    extensions.

## Design axes

Handed on by this session, in working order:

- **Axis 6: tabs by name.** `inspect(world; name = "variant")` writes the
  envelope `name` and pushes to the tab bound to it, opening a new tab
  when none is; the unnamed call pushes to the default tab; a tab tells the
  server its name on reconnect; closing a tab frees the name (answer 9).
  Beside it the open-in-editor request behind a location click (answer 4),
  and printing the Vimium exclusion pattern once when the browser opens
  (answer 11). Ran on 2026-10-28; its record is `live_session.md`, which
  names the server-side record a channel and keeps "tab" for the browser's.
- **Axis 4: the hints.** Previous positions as ELK hints on a relayout after
  a push, keyed by node path, the dragged position among them (answer 9);
  the spike left ELK's interactive options untested.
- **Axis 7: the docstring links.** A Documenter `@ref` link in a rendered
  docstring linking to the hosted documentation, which that axis knows the
  address of (answer 4). The bundled Markdown renderer is its dependency
  to pick, offline and without a CDN.
- **The bumps, as `visual_grammar.md` hands them on**, with this session's
  additions: the failure descriptor opens the drawer on its diagnostics
  (answer 10); the deployment overlay fills the timing tab's schedule rows
  and hyperperiod chart and the legend's lines (answer 7); stage 2's claim
  table fills the root-inputs tab's writer column (answer 6).
- **Axis 3's fallback chain**, amended by answer 10: `name`, the file name
  for a dropped or picked file, the root type's display name.

## Glossary

- **Breadcrumb.** The open level's path as links above the canvas, the root
  labelled as the tree labels it.
- **Drawer.** The bottom pane: diagnostics, root inputs, timing and
  execution order as tabs, collapsed to its tab strip unless a diagnostic
  exists.
- **Folder row.** A keyed container's row in the tree, named by the field,
  no node: it highlights the region and shows the field.
- **Frame.** The grid of tree, canvas, detail pane and drawer with its
  splitters, replaced by stage 4's dock while the panes stay.
- **Landing panel.** What the canvas shows before a model is loaded: the
  privacy statement, the open control, a drop hint, the help link.
- **Push.** A new descriptor arriving in a tab from the live session, after
  which every piece of session state is rekeyed by path.
- **Route.** A face's value path, upstream to its terminal producer and
  downstream to every terminal consumer, drawn across levels once started
  on purpose.
- **Session state.** What a tab keeps for its lifetime: the open level,
  each level's view and positions, the expansion, the selection, the
  route, the query, the drawer's state; against the browser's preferences
  and the model's data.
- **Tab by name.** A browser tab bound to an envelope `name`, which
  `inspect` pushes to by that name.
- **Trace.** The action that starts a route: the detail pane's button, the
  right-click entry or `t`.

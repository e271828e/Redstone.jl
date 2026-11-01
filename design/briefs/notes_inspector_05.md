# Notes: inspector increment 5, the readings and their reasons

The brief is `brief_inspector_05_interaction.md`. The user asked on
2026-10-30 for the increment to be prepared and launched once increment 4
was done; each reading below is the coordinating session's, with its
reason, for the user to ratify or strike. A struck one is reverted by a
finding to the fixer. Nothing is pushed.

## Launch state

Increment 4 landed at `13d1f4c` of `RedstoneInspector.jl`, pushed with CI
green, and the core's bookkeeping at `559a4f8`, so the worktree
`~/.julia/dev/RedstoneInspector.jl-inc5` (`increment-5`) sits on that tip.
Increments 3's and 4's worktrees still exist, the user's to remove. The
oracle `scratchpad/oracle/search.py` sits beside copies of increments 2 to
4's `resolve.py`, `levels.py` and `frame.py`; it takes the fixtures
directory as its argument. The ELK hint probe ran as a scratch Vitest file
in the worktree, deleted after; its output is `scratchpad/hints.out` and
`hints2.out`.

The increment folds in increment 9's frontend piece, as the pending
bullet the previous session wrote says, because the status bar it waited
for exists and because the push is what answer 9's third lifetime rekeys
against; a drop stands in for the push in the checks, the record's own
rule that a second file replaces the model under the same rules.

Two builders instead of one: the interaction half and the live half share
no file but the status bar and the shell, and the whole is larger than
increment 4, whose one builder ran to four commits. The second agent
starts from the first's notes.

## Readings

1. **No ELK hints; a dragged block keeps its dragged place.** Answer 9
   says the surviving blocks' previous positions go to ELK as hints and
   calls the mechanism untested. Tested: ELK's semi-interactive crossing
   minimization and its `INTERACTIVE` strategies read node positions only
   when `considerModelOrder.strategy` is off, and that option is how the
   level is steered by declaration order (answer 12, increment 3's
   `GREEDY_MODEL_ORDER` beside it). With model order off the positions
   are honored but blocks nobody dragged move too, `plant` from y 257 to
   42 with the layout's own output as the hints, so a first push would
   rearrange a level the user never touched. Declaration order is the
   record's stated steering and determinism gives the surviving blocks
   their places for free when the shape is unchanged; what a hint was for,
   keeping a drag, is kept by storing the drag. The user may prefer the
   hints and give up the model order on relayout; then this reading is
   struck and the brief's probe says which options work.
2. **Geometry per level for the session.** Answer 9 lists each level's
   block positions as session state and answer 3 the view; keeping the
   geometry makes the revisit instant and the drags survive a level change
   without a second mechanism. A push relays out, which is what the
   positions were kept for.
3. **Results while focused, outline otherwise.** Answer 5 says both that
   the results replace the outline while a query is active and that tree
   rows take the dashed marker with the count propagating up; the markers
   can only be seen when the outline is. Focus is the natural switch: the
   user types and walks the list, picks a hit, and the tree shows where
   the hits lie, the query still standing.
4. **The matching rule.** Answer 5 gives the fields and the prefixes but
   not what a bare term does on a face hit or what a `path:` term does to
   one. A bare term matching the owner's path would make `sensing` list
   every face under it, noise; `path:` restricting the owner makes
   `path:plant face:h` the precise question. The root's empty path matches
   nothing, which is right: its faces and type are searchable.
5. **A closed assembly with hits beneath takes the dashed halo.** Answer 5
   says the block searched for is usually on a level the user cannot see;
   a dimmed canvas with nothing lit says "no hits" while the tree says
   otherwise. The row's propagated count and the block's halo say the same
   thing.
6. **Quadrant and center distance.** Answer 11 says "nearest block or pin
   in that direction"; the quadrant rule keeps `l` from picking a block
   almost straight above, and the center distance is the plainest
   nearest. A port's block and a wire's consumer as origins give every
   selection a starting point; the level's first block from nothing is
   where reading starts.
7. **The view follows by the least pan.** Zooming would change the scale
   under the user's hands; the minimal pan is what "the view following"
   means in an editor.
8. **48 px, 1.25, `=`.** Round numbers, visible and not jarring; `=` is
   the unshifted key under `+` on the common layouts, as in browsers.
9. **Tab cycles the four roots only.** Answer 11 names exactly these four
   stops; letting Tab also stop at every button inside them would make the
   order depend on what is shown. The ring is the halo's hue as the answer
   says.
10. **The root is the empty hash.** `#level=` with nothing after reads as
    broken; no hash is the page's plain address, which the live session
    opens.
11. **The hash wins on load.** Answer 3's reload and linkable level need
    the hash applied when the model arrives, which in the live tab is
    after the page loads.
12. **The note stands until the next open or push.** A note that vanished
    on a timer could be missed; one that stayed forever would be stale
    after the user navigates.
13. **A refusal unloads; the next model starts fresh.** Increment 4's
    departure, kept: there is no model to rekey against.
14. **`d` on the current tab.** The drawer remembers its tab; the key
    toggles.
15. **Reserved keys swallowed.** `/` would open quick find in Firefox and
    `?` is a shifted `/`; `t`, `r`, `y` and `o` have no browser default
    but swallowing all five now means the table's keys never leak.
16. **The connection shows only when it exists.** Answer 5 of the live
    session: no indicator in the hosted copy; before the handshake
    resolves nothing is known.
17. **The download in the live tab only.** Answer 10 of the workspace
    places it in the live tab; a dropped file is already on the user's
    disk.
18. **`open_location` when connected, copy otherwise.** Increment 4's
    reading 7 continues for the hosted copy.
19. **Server-to-page control messages dropped.** The protocol defines
    none in stage 1; the page keeps the rule the server keeps.
20. **The backoff.** The record says "a backoff"; doubling from one second
    to a thirty-second cap is the ordinary one.
21. **One text field.** The table's keys act outside text fields; the
    search field is the only one in stage 1.

## For the user

1. Read the readings; strike any, and the fixer reverts it. Reading 1
   changes the record's stated mechanism and deserves the first look.
2. After the review, the look-and-adjust pass: `npm run dev` in the
   worktree's `frontend/` on the fixtures, the screenshots under
   `frontend/e2e/screenshots/`, and the live tab through `inspect` with
   `bundle_dir` set to the built `dist/`.
3. The merge and the push; the worktrees of increments 3 and 4 to remove.

## Build outcome, 2026-10-31

Agent A built stages 1 and 2 on `increment-5` in
`~/.julia/dev/RedstoneInspector.jl-inc5`, not pushed: `e40a42f` the view
state, the hash, the rekeying, the drag and the keyboard; `2674659` the
search; `e3c0ca7` a ruling applied. `npm run check` 351 files, 0 errors;
`npm test` 262 tests in 16 files; `npm run e2e` 109 checks in about 15 s.

Rulings made during the build, each the coordinating session's:

- **Nodes before faces.** The brief's search check named the root's `h_ref`
  face row as the first hit, against its own prose and answer 5's "grouped
  under nodes and faces"; the agent followed the check. Ruled for the
  record's order and the check rewritten (`e3c0ca7`): the first row is
  `sensing/noise`, and selecting `selection/select_δe` expands `selection`.
- **`search-under` from the marked set.** The brief's table read no
  `search-under` block for `face:in1` because the oracle counted node hits
  only, while the brief's `beneath` is defined over the marked set, face-hit
  owners included. The code follows the definition: `face:in1` lights
  `sensing`, `lqr_controller` and `selection`. The brief's error.
- **`descent`'s drag pins.** The brief expected `gear|in|h` as a six-point
  route after `plant` moves 120 down; ELK draws it straight and the drag
  keeps it forward, four points. The check pins four points there and six
  once `plant` is dragged past `gear`. The brief's error.
- **Accepted departures of the builder**: the canvas exports `fit`,
  `zoomBy`, `panBy`, `boxes` and `follow` through a handle, not an
  `onfitrequest` prop; a drag selects the block itself on release, since
  Chrome fires no click after the raise moves the element; the pointer is
  captured only past the 3 px slop, since capturing at the press broke
  port-square clicks; `follow` aligns the near edge of a box larger than
  the viewport; a replacement keeps the drawer's state and opens it on a
  new model's diagnostic; a fresh load resets the query; a fallen level's
  stored view is dropped; a selection that changes the level rewrites the
  hash with `replaceState`, no history entry; Tab cycles the regions from
  inside the search field too; Ctrl-K focuses the search as Cmd-K does.

Observations for the look pass: the canvas's focus ring shows after any
mouse click on the canvas, since the press focuses `.viewport`; a
`:focus-visible` rule would keep it for the keyboard.

Agent B built stages 3 and 4: `9775349` the live tab, `d90bb36` the map and
the README; the tip is `d90bb36`. `npm run check` 356 files, 0 errors;
`npm test` 270 tests in 17 files; `npm run e2e` 113 checks in about 15 s.
Its readings, accepted: a status bar with the connection alone shows under
the landing panel while connected or lost, answer 4's "landing panel
staying up with the status bar reading"; the download exists only for a
model that came over the socket, since a dropped file's bytes are not the
socket's; the detail pane's `onlocation` returns whether it sent, and the
pane copies otherwise; the bar reads "connected" once any descriptor text
has arrived. `vite preview` refuses the `/ws` upgrade in about 25 ms, so
every check without a mock runs as the hosted copy. Open items the map
carries: a face hit found by a `type:` term alone shows no `mark`;
`clearNote` is exported and unused; the drawer keeps its state on a
replacement. The cold review follows.

## The cold review, 2026-10-31

Every check green from a clean install: `npm run check` 356 files, 0
errors; `npm test` 270 tests in 17 files; `npm run e2e` 113 checks in
15 s. No defect against the records or the brief. The oracle equals the
brief's table on every row and the code on all sixteen queries; the
reviewer's own `nearest` and `follow` agreed with every key on forty
presses. The live tab ran against the real server, `inspect(descent())`
with `bundle_dir` on the built `dist/`: connected, the download byte-equal
to `write_descriptor`'s file for `descent` and `aircraft`, a location click
reaching the editor stub with the right file and line, a second `inspect`
replacing the model with `plant` and the query kept, the server stopped
and restarted with the page reconnecting after five refused retries.

Four findings, all gaps in the checks and handed to the fixer: the
download check cannot tell raw bytes from re-serialized JSON, every fixture
being canonical already; the `+` check never moves the pointer, so a zoom
about the pointer's last place passes; no check reads the empty hash after
a climb to the root; a stale selection kept across a fallback is invisible
to the canvas check. Plus the map's sentence on who touches the hash and
the unused `clearNote`. Of the brief's mutants three survived: the two
behind the findings and `popstate` pushing again, a no-op under the push
guard, accepted; the backoff's cap is in fact caught by a unit test.

Observations for the user, none a finding against the code:

- An unnamed `inspect` labels the tab `Group` and downloads `Group.json`,
  answer 10's label rule as written; the fixtures all carry `name`.
- A different model pushed over another inherits the root's view, answer
  9's "a surviving level keeps its view", so `descent` after `aircraft`
  draws cut off until `0`. Whether a push of a different root type should
  fit instead is a ruling to take.
- A push rebuilds the canvas and drops keyboard focus to the body; the
  keys still work.
- The fallback note shows literal backticks, as the brief spelled it.
- The landing's "loads nothing from the network" stands under "connected,
  waiting for inspect" in the live tab.
- Tab stops only at the four region roots, reading 9, so the buttons
  inside them are mouse-only; answer 11's "every control is a real button
  or link" reads uneasily beside it.
- A bare `path:` or `face:` lists every node or face while typing.
- The oracle's `containers` row miscounts folder members; the row is not
  in the brief's table.
- Outside this increment: `inspect` is unexported and `Preferences` is not
  a dependency of the `scripts` project, so the brief's live-look command
  needs `RedstoneInspector.inspect` and `RedstoneInspector.Preferences`.
- Not verified on the real server: a fallback of the open level, since
  the examples have no assembly at the root; a channel by name.

## The look-and-adjust pass, 2026-11-01

The user tried the page and asked for changes, settled in discussion and
landed in the records first (`45c5047`): the keymap's Shift row, back and
forward with Shift+h and Shift+l, open and up with Shift+j and Shift+k, the
arrows alone panning, `z` centring the selection, `n` and `N` walking the
search's hits instead of a focusable results list; the tree's own `h j k
l`, Yazi's; pins and root-input tags draggable; a view kept on a push only
for a level whose blocks are unchanged; a prefix with no text as no term;
the ring for keyboard focus only and focus kept across a push; a leave
prompt while a file-loaded model is open, after the user hit the first
entry with the mouse's back button; the landing's "nothing from any other
site"; and the detail pane's top, Open beside Copy, labelled facts with
titles, a rate phrase on discrete leaves only, titled disclosures. The
continuous leaf's missing rate row stands on §8.7: a `sample_times` key on
a continuous child is a build error.

A Firefox probe of the leave prompt's activation rule could not run: the
sandbox blocks Firefox's profile, and running it outside the sandbox was
refused by the auto-mode classifier. Chromium shows no prompt without an
interaction and one after a real click or key. The probe stays in the
scratchpad for the user, and a real Finder drop and the mouse's back button
stay a manual check.

The fixer built the pass as `67f5977` the keys and focus, `95087ba` the
drag, the view rule, the prompt and the landing, `953926c` the pane's top,
`bf52830` the map and the README. `npm run check` 357 files, 0 errors;
`npm test` 293 tests; `npm run e2e` 127 checks in about 16 s. Every change
has a check a named mutant turned red. Its departures: Shift+l is bounded
like Shift+h, so neither leaves the page; Enter with nothing to open no
longer swallows the key; `j` and `k` in the tree with nothing selected both
select the first row; the rate phrase reads the anchor's `T`, a non-zero
`tau`, then the offset; the member row's kind word sits in its title; every
block's cursor is `move`. Open items: a press on a canvas that already
holds keyboard focus keeps the ring; at the pane's default width a leaf's
faces table squeezes the kind cells, increment 4's table.

The reviewer verified the pass at `bf52830`: the gate green from a clean
install, 357 files, 293 tests, 127 browser checks; no finding against the
code or the records; every rate phrase equal to its fixture's triple by
§9.1's fold; the fixer's departures accepted. Of eleven mutants run, one
survives: Shift+l unbounded, the fixer's own bound having no check. The
`import.meta.env.DEV` skip of the leave prompt cannot be mutated against
the preview build. Open with the user: where focus goes after a search
hit, the tree, the canvas, or the detail pane for a face hit.

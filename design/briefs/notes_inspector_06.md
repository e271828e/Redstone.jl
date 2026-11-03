# Notes: inspector increment 6, the readings and their reasons

The brief is `brief_inspector_06_grammar.md`. The user asked on 2026-11-01
for the increment to be prepared and launched once increment 5 was done,
and on 2026-11-02, through the session that closed increment 5, for
Firefox as a second non-blocking Playwright project; each reading below is
the coordinating session's, with its reason, for the user to ratify or
strike. A struck one is reverted by a finding to the fixer. Nothing is
pushed.

## Launch state

Increment 5 landed at `bf52830` of `RedstoneInspector.jl`, pushed with CI
green, and the core's bookkeeping at `9057bbc`, so the worktree
`~/.julia/dev/RedstoneInspector.jl-inc6` (`increment-6`) sits on that tip
with `npm ci` run and the root `Manifest.toml` copied in. The oracle
`scratchpad/oracle/grammar.py` sits beside copies of increments 2 to 5's
`resolve.py`, `levels.py`, `frame.py` and `search.py`; it takes the
fixtures directory as its argument, and its output over the tree as
launched is `grammar.out`. The ELK probe ran as a scratch Vitest file in
the worktree, moved out after; it is `scratchpad/elk_probe.test.ts` with
its output `elk_probe.out`.

Three builders: a Julia one for the fixtures, since the grammar needs
wires of every kind and blocks of every library type to be looked at,
then the two frontend halves, colors and wires, then shapes; the halves
share `Canvas.svelte` and so run one after the other, as increment 5's did.

## Readings

1. **A `library` fixture.** Answer 7's roster has 29 keys and the
   committed fixtures show twelve of them; the look pass, which this
   increment budgets largest, cannot look at an icon no fixture draws,
   and the legend's `× 2` and `phase` lines have no fixture either
   (`rates`' `Relative(2)` gives the one `× 2`). `descriptor_design.md`'s
   answer 16 already makes the inspector's own synthetics the place for
   such coverage. The commit stands alone so that striking it is one
   revert plus the test rows.
2. **`kinds` wired to root outputs.** The fixture was written for the
   kind markers on faces, so its root draws one wire; wire styles by kind
   need a level with all five classes, and root outputs cost nothing.
3. **Five classes.** Answer 4's table has five rows; naming them lets the
   CSS, the tests and the DOM contract speak of a class rather than of
   nine kinds. The struct's "triple line" as a wide stroke with a
   background-colored core is the cheapest drawing that reads as
   Simulink's bus and keeps one hit path per wire.
4. **Trunks from ELK's junction points.** The probe found the orthogonal
   router already merging the wires that leave one port and reporting the
   splits; drawing a dot at each is the whole mechanism, so `mergeEdges`
   and a merge of our own are both unnecessary. A dragged block's wires
   are re-routed one by one by the local router, which has no trunks, so
   their dots go.
5. **Regions as compound nodes.** The probe found `INCLUDE_CHILDREN`
   keeping a region's members together with every edge routed, and the
   padding reproducing the box answer 5 wants; a bounding box over a flat
   layout would overlap non-members when ELK interleaves layers. The
   option is set only on a level with a region so that every other
   level's layout, and increment 5's order pins, stay byte-identical. The
   frame is derived from the members' boxes so that a drag carries it,
   which also makes it equal to ELK's box until a drag. The region is the
   tree's folder: same path, same selection kind, so answer 2's "a folder
   click highlights the region" and a click on the frame are one state.
6. **Palette order per model.** Answer 6 says "a model with more triples
   than colors"; a per-level assignment would give one color two meanings
   across levels and across a push. Anchor 0 first is the answer's own
   rule; the period, `T × m`, is what "fastest" means; the anchor index
   then `m` then `c` is the plainest tie-break and keeps `closed_loop`'s
   ten anchors in declaration order. The extras keep a neutral fill so a
   palette color is never reused, and the badge carries the legend's
   number, which the legend repeats.
7. **The inherited scope.** Answer 6's wording, "its `scopes` row or the
   enclosing scope composed by the client when it has none", read as the
   nearest ancestor's row and the base grid at the root. On `closed_loop`
   every assembly then takes the base-grid color with a badge, since the
   example anchors each leaf on its own `Absolute` and declares no scope.
   The alternative the user may prefer: an assembly with no row whose
   discrete leaves share one triple takes that triple with no badge, which
   would color `sensing` and `lqr_controller` by their one leaf and badge
   only the three with several clocks inside. The literal reading is
   built; striking it is a one-function change in `rates.ts`.
8. **One pill, top-right.** Answer 6 says "a text badge" and "a multi-rate
   badge in one corner"; `workspace.md` answer 7 puts increment 8's order
   badge top-left, so the rate pill takes the other top corner, and one
   pill holding both texts avoids two marks on one block.
9. **The legend's spelling.** Answer 6 writes the line out, "anchor 1
   (1/10 s) × 2, phase 1"; the multiple and the phase are dropped at their
   defaults so the common line stays short; the anchor goes by index
   because keys repeat across scopes (`hold` twice in `rates`), with the
   key and scope in the title. Bottom-left is the corner Fit does not use.
10. **Rate-mode wires.** Answer 6's own sentence; the tint keeps the wire
    lighter than the block so the color change at an input reads as a
    transition rather than as a second block color.
11. **Per browser, version 1.** Answer 9 lists the mode and the toggles in
    the first lifetime; `parsePrefs` already defaults a missing field, so
    adding two fields needs no version bump.
12. **The icon's width in the sizing rule.** Answer 7 says the sizing rule
    is untouched and that the icon has a fixed width; a block sized to a
    display name it no longer draws would carry blank width, so the icon's
    width takes the display name's place in the head term and nothing else
    of the rule moves.
13. **The `Constant`'s text.** Answer 7's "its `value` summary cut short"
    and answer 10's "a `Constant`'s value cuts shorter"; the opened
    `value.*` entries are joined so a NamedTuple constant still shows its
    value. The frame glyph for an opaque output is the answer's own.
14. **`Delay`'s `K` from the signature.** Answer 7 says so in as many
    words; it is the one place the grammar reads a printed type, and the
    fallback is the literal superscript.
15. **Three thresholds.** Answer 10 names the order and leaves the floor
    to the browser; a scale threshold per level is the smallest mechanism
    the CSS can read, and the look pass tunes the three numbers.
16. **Type labels at the wire's start.** Answer 4 says once per producer
    port; the start of the port's first wire is where the label is beside
    both the port and the wire and never repeated along a fan-out.
17. **The ELK pass as an experiment.** The tangle is a look item from
    increment 3 that no record settles; a crossings count gives a builder
    a criterion to apply without a reader, the order pins keep the
    experiment from undoing increment 3's steering, and a time bound keeps
    it from eating the increment.
18. **Firefox non-blocking.** The user's request through the other
    session, with its reasons: they browse in Firefox, every check so far
    ran in Chromium, and increment 5 touched the areas where the two
    differ. Non-blocking at first because the first run will show what
    differs; blocking before the release once it has passed a few runs.
    The clipboard checks skip because Playwright grants the permission in
    Chromium only.

## For the user

1. Read the readings; strike any, and the fixer reverts it. Reading 7
   changes what the closed loop's root looks like in rate mode and
   deserves the first look; reading 1 adds a fixture and deserves the
   second.
2. After the review, the look-and-adjust pass: `npm run dev` in the
   worktree's `frontend/` on `closed_loop`, `rates`, `kinds`, `containers`
   and `library`, both modes, the labels, the zoom; the screenshots under
   `frontend/e2e/screenshots/` and, from CI, under `firefox/`. The palette
   values, the glyphs, the thresholds and the ELK options are this pass's.
3. The merge and the push; the Firefox step's first outcome; the
   worktrees of increments 4 and 5 to remove.

## Build outcome, 2026-11-02

Agent 0 built stages 1 and 2 on `increment-6` in
`~/.julia/dev/RedstoneInspector.jl-inc6`, not pushed: `637b5f1` the
`kinds` wiring, every root output building, its root now 18 blocks, 10
wires and 9 output pins; `4b28f2a` the `library` fixture, all 31 shipped
blocks plus a `Junction` over a user function, 33 nodes, 40 wires, 26 of
the roster's 27 icon ids (`constant-opaque` stays `kinds`' alone). `npm
run check` 357 files, 0 errors; `npm test` 304 tests in 17 files; `npm run
e2e` 128 checks. A second regeneration left the tree clean; the other
synthetic fixtures changed only in their method `line` values.

Rulings made during the build, each the coordinating session's:

- **The `Relative(2)` scope sits on a leaf at the root**, the fixture
  being one flat `Group`, so its legend lines read `base grid × 2` and
  `base grid × 2, phase 1` and it carries no `scopes` row; `rates` already
  shows the nested form. Accepted: the brief asked for the `× 2` and the
  `phase` lines, which these are.
- **Anchor 1 is the slower one** (1/10 s against anchor 2's 1/50 s), the
  builder's choice so that sorting by period differs from sorting by
  anchor index on this fixture too. Accepted.
- **The singular `1 wire` lost its pin**: `detail.spec.ts` read `kinds`'
  level facts as `9 children · 1 wire` and no fixture level has one wire
  now. Handed to agent A as a unit test over an inline one-wire
  structure.
- **`fixtures.test.ts` did need a change**, its fixture and structure
  counts, against the brief's "needs no row". The brief's error.
- **`MAP.md`'s "all eleven fixtures" and `kinds`' "1 wire"** are stale
  until stage 9, which agent B's prompt names.

Agent A, colors and wires, follows from `4b28f2a`.

Agent A built stages 3 and 4 from `4b28f2a`: `a56c2b3` the color modes,
the palette, the badges, the legend, the tree's dots, the switch, the
status bar's word and `r`; `e361671` the wire classes with the struct's
core, the rate tint with per-color arrowheads, the junction dots, the
type labels and `y`. `npm run check` 363 files, 0 errors; `npm test` 327
tests in 19 files; `npm run e2e` 134 checks. Its departures, accepted and
recorded in its notes for the map:

- **The badge straddles the block's top edge at the right corner**
  instead of sitting inside the frame, where it covered the segment on
  every badged block of `closed_loop`'s root; answer 10 never truncates a
  user name and sizing a block for the badge would make its size depend
  on the mode. For the look pass; increment 8's top-left order badge
  meets the same choice.
- **The singular `1 wire` moved into `detail.ts`** as `levelLine`, so a
  unit test can kill the plural mutant; the pane imports it.
- **The brief's `2 rates` was a slip** for `2 clocks`; the checks read
  `2 clocks`.
- **The rate-tint wire checks sit in `wires.spec.ts`**, stage 4's, not
  `colors.spec.ts`.
- **`descent`'s one flag wire is `gear`'s `Bool` into `stop|in|u`**, not
  the `StopFlag` enum, which no wire carries; the test pins both. The
  brief's error.
- **Arrowheads need `markerUnits="userSpaceOnUse"`**, else a vector's
  arrow grows threefold; one `<marker>` per wire color, since
  `context-stroke` on the struct's core would take the background color.
- The wire helpers take a `Level` rather than a path; `cutName` and
  `cutType` share `cutText`; a root whose triple no drawn block takes
  falls back to the assembly gray for its tree dot.

Its headed look, for the look pass: the badges, legend lines, steps and
extras match the oracle on every level; the palette's first pass has pear
and olive reading alike, pink, purple and reddish purple reading alike,
and light cyan near the continuous blue; the fit ignores the legend,
which crowds the bottom pin of `lqr_controller`; on `kinds` the short
wires put the type labels across the output pins and under the `p`
block. Agent B, shapes, the ELK pass, Firefox and the map, follows from
`e361671`.

Agent B built stages 5 to 9 from `e361671`: `516691a` the icons;
`57b9e07` the regions; `c30a842` the text levels and the ELK pass;
`aaf22dd` the Firefox project; `9aa8874` the map and the README. `npm run
check` 373 files, 0 errors; `npm test` 340 tests in 23 files; `npm run
e2e -- --project=chromium` 142 checks. Its departures, accepted and
recorded in its notes for the map:

- **`Delay`'s `K` is the second type parameter** (`Delay{Float64, 3}`);
  `iconOf` takes the first integer among the top-level parameters, so
  either order reads `z⁻³`. The brief's error.
- **`a=1.0, b=2.0` is 64 px**, over `CONSTANT_WIDTH`, so it draws cut
  with the whole value in the title; a `Constant`'s width term is the
  larger of `ICON_WIDTH` and its cut text.
- **The discrete integrators' staircase sits beside `1/s`**, not under
  it, where the two overlapped in 12 px; artwork for the look pass.
- **A click on a region frame's middle hits a wire**, whose hit path lies
  over the frame; the check clicks the top edge and the caption.
- **`sizeBlock` measures the member's label**, the key, not the segment
  it no longer draws.
- **The live hosted-copy check skips whole under Firefox**, its
  no-connection and no-download parts with it.
- **The ELK pass chose `elk.layered.thoroughness: 20` alone**: 62 to 60
  crossings on `closed_loop`'s root, 663 to 622 on `large`'s, 6 kept on
  `lqr_controller`, the order pins green; `NETWORK_SIMPLEX` beside it
  saved two more at 222 more bends and twice the time on `large`. The
  `large` output-pins check is dropped: only `forceNodeModelOrder` fixes
  that order and it raises `large`'s crossings to 699. **Side effect for
  the user**: both qualifying sets move `closed_loop`'s root input pins
  out of declaration order, `h_ref`, `mode`, `V_ref` top to bottom; no
  check pins that order; the reviewer is asked to measure it against
  answer 3's "declaration order as the tie-break".
- **Plain `npm run e2e` now starts Firefox too**; local runs use
  `npm run e2e -- --project=chromium`.

Its headed look, for the look pass: the floors read low, the display
names at the `no-faces` floor about 6 px and the segments at `segments`
about 4 px, something like 0.8, 0.6 and 0.4 being the pass's call; the
feedback wires of `closed_loop`'s root still wrap over the top and right
of the drawing under the chosen options; the trunk dots read as intended.
The cold review follows at `9aa8874`.

## The cold review, 2026-11-02

Every check green from a clean install: `npm run check` 373 files, 0
errors; `npm test` 340 tests in 23 files; `npm run e2e --
--project=chromium` 142 checks in 18 s; the fixture regeneration left the
tree clean. The oracle equals the brief's table on every row, and the
reviewer's own third reading of the palette order, the legend texts and
the wire classes agrees with it on every level of every fixture. No
defect breaks a check or the build. Of 32 mutants, one survived as a
missing check and two of the reviewer's own as missing pins; the rest
died where the brief said.

Findings, all handed to the fixer with the coordinating session's rulings:

1. **The palette is not distinct under weak color vision**: under a
   simulation the mint and pink fills sit at ΔE76 1.6 for deuteranopia,
   the pear and yellow strokes at 0.5 for protanopia, and the yellow
   stroke 7° of hue from the warning amber. Ruled a defect against
   answer 6's clause, the values staying the look pass's: the fixer
   respreads the eight steps by lightness as well as hue until every
   pair clears about 10 under each simulation, no stroke within about 20°
   of red or amber, no blue near the highlight.
2. **The legend omits the triples the wire tints make visible**: `rates`'
   root draws `outer`'s wire in step 1's tint with no `× 2` line. The
   brief's `legend` definition, "each child's `blockTriple`", read answer
   6 too narrowly; ruled that a wire drawn in a step's tint is visible,
   so `legend` adds each level wire's `wireTriple`, the pins recomputed.
   This supersedes the brief's table's legend column and refines reading 9.
3. **`library` loads below a floor** (its fit scale 0.36 against
   `FLOOR_NAMES` 0.4), so the coverage check counted icons nobody saw;
   the check zooms in first, and the map gains the open item that a root
   whose fit falls below a floor loads without its names, for the look
   pass to settle through the floors or the fit.
4. **Missing check**: an icon kept at `frames` survives; `zoom.spec.ts`
   extends to that floor.
5. **Missing pins**: an icon recolored in rate mode and the opaque wire
   drawn dark both survive; two comparisons added.

On the root input pins: the landed `thoroughness: 20` draws
`closed_loop`'s root inputs `h_ref`, `mode`, `V_ref` top to bottom
against the declared `h_ref`, `V_ref`, `mode`, for a gain of two
crossings over increment 5's options (60 against 62; 622 against 663 on
`large`). The reviewer measured that keeping the order costs the pass's
whole gain (`crossingCounterNodeInfluence` 1 gives 62 and 712;
`forceNodeModelOrder` alone 61 and 699) and judged it crossing
minimization exercising its say, answer 3 making declaration order the
tie-break, as increment 5 already did on `pid_controller`'s and
`selection`'s pins. **Open with the user**: two crossings against the
pins' declared order.

Observations for the look pass, none a finding: the struct's line reads
as a double line, two bands round a background core, where answer 4 says
triple; the zoom floors read low; type labels collide (`Float64Float64`
at `lqr_controller`'s `δe`, `kinds`' across its output pins and off the
canvas, which the fit ignores) and keep the module name while losing the
parameters; the trunk dots at radius 2.5 barely show on a 3 px vector
trunk; a dragged region member can pull its frame over a non-member; in
rate mode the extras' light-gray tint and the root inputs' dark gray are
both grays; the legend crowds the drawing's corner; `CONSTANT_WIDTH` cuts
`a=1.0, b=2.0`.

## The fix, 2026-11-02

The fixer landed the five findings as `2af164b` "Fix increment 6's review
findings": `npm run check` 373 files, 0 errors; `npm test` 340 tests;
`npm run e2e -- --project=chromium` 142 checks. The palette came from an
annealing search over the pair distances under normal vision and the
three simulations, tighter than the ruling in two places (the hue bans
applied to fills as well as strokes, each step's fill and stroke within
20° of each other), with every fill pair at ΔE76 11.3 or more and every
stroke pair at 11.7 or more under every vision; the bans leave greens,
cyan and violet to magenta, so five of the eight steps are greens told
apart by lightness, and step 3's fill is a saturated cyan 28° from the
highlight's hue. **For the look pass**: whether the fills may take the
hue bans off (the ruling asked them of strokes only), which would let the
palette spread beyond green. The legend's wire rule recomputed the pins:
`closed_loop`'s root lists steps 0, 4, 5, 7 and the extra #9,
`pid_controller` 2 to 5, 7 and 8, `selection` 4, 5, 7, 8, `rates`' root
its three triples. Each finding's mutant turns a check red; the map's
check descriptions follow. The reviewer verifies the delta.

The reviewer verified the delta at `2af164b`: its own `cvd.py` confirms
the palette's minimums (fills 11.3 and up, strokes 11.7 and up under
every vision, fills at least 31° and strokes at least 46° of hue from the
error and warning hues), its own `third.py` extended by the wire rule
equals every legend pin, the four mutants turn a check red, the amended
specs and `npm test` green, the map true to the code. Two more
observations for the look pass: step 5's fill sits ΔE 6.1 from the root
tag's fill under simulated deuteranopia, and the cyan fill reads loud.
The increment is ready for the user's look-and-adjust pass; nothing is
pushed.

## The look-and-adjust pass, 2026-11-02

The user tried the page and asked; the changes settled in discussion and
landed in the records first (`visual_grammar.md` answers 4, 6 and 8,
`workspace.md` answers 3 and 4):

- **Type labels** drop their module qualifiers, sit on the longest
  horizontal segment among the port's wires, cut to its length, drawn
  above the blocks on a background halo, in a 9 px font.
- **The palette** is searched again: the fills free of the hue bans, the
  strokes keeping them, the fill-stroke hue pairing relaxed, distance
  measured by CIEDE2000 under normal vision and the three simulations,
  ΔE76 having overstated the greens' differences (the current fills' least
  pairs read 13 to 14 in ΔE76 and 7.5 in CIEDE2000); fewer than eight
  colored steps if eight cannot clear the bar.
- **The legend** gains an unnumbered `continuous` line, last.
- **A move to an ancestor selects the child on the path**, by Shift+k,
  Backspace, Alt-Up, the breadcrumb or back.
- **The member row writes the container's kind**, "transparent container
  `children`, key `plant`" or "keyed container `gains`, key `a`".
- **The docstring's summary is its title alone**; the call form stays in
  the body.
- **The parameters and faces stack** below a pane width of about 420 px,
  a container query inside the detail pane.
- **The root pins' declared order is given up** for the two crossings, as
  answer 3's tie-break reads; no amendment.
- **No `name:` search prefix**: offered, not taken.
- **Shift constrains a drag** to the axis of greater travel, at any moment
  during the drag, re-applied on Shift's own key events
  (`initial_design.md` answer 12).
- **A legend line focuses its triple**, the continuous line its color: the
  blocks, the closed assemblies with a leaf beneath and the tinted wires
  lit, the rest dimmed through the search's mechanism, the tree's rows
  marked with counts; cleared by a second click, Escape or tier mode;
  kept across levels and across a push that keeps the triple; with a
  query standing, the canvas shows the legend's focus and the tree the
  search's markers. Escape's chain: route, legend focus, search,
  selection (`visual_grammar.md` answers 6 and 9, `workspace.md` answer
  11). Taken now rather than in increment 7, which would otherwise
  generalize three focus states at once.
- **The zoom floors stand**: the builders judged them from headless
  screenshots at one device pixel per CSS pixel; on the user's screen
  `library` reads well at every level.
- **Four colored extras.** The user asked whether lifting the ban admits
  more than eight colors. A greedy pick of light fills over the sRGB grid
  (`scratchpad/capacity/capacity.py`) keeps twelve at a least CIEDE2000
  of 13.9 under normal vision, but only eight at 7.6 under the three
  simulations as well: weak color vision, not the ban, caps the count.
  Ruled: steps 1 to 8 stay distinct under all four visions; extras 9 to
  12 take fills distinct under normal vision only and keep their numbered
  badges, which carry the difference for every reader; gray and a number
  past twelve. Built as a follow-up to the look-pass fixer's palette
  commit, so the two searches do not collide; the checks' extra numbers
  are unchanged.

The look-pass fixer built the pass as six commits from `2af164b`:
`569ca07` the palette and the legend's continuous line, `cc504f1` the
type labels, `50ea1d2` the legend focus, `68f31e6` the climb's selection
and the Shift drag, `8281ce2` the detail pane, `b599af4` the map and the
README. `npm run check` 376 files, 0 errors; `npm test` 371 tests in 24
files; `npm run e2e -- --project=chromium` 148 checks; every change's
mutant red. The palette search, rewritten in Julia with CIEDE2000
checked against Sharma's test pairs, landed eight steps at a least
CIEDE2000 of 12.2 for the fills under normal vision and 10.1 under the
simulations, 10.8 for the strokes under every vision, every pair at
least 10.2 from the continuous, extra and root-tag pairs; the earlier
palette scored 4.8 and 6.2 by the same measure. Its departures,
accepted:

- **The stroke ban is one arc**, 334° to 64° of HSV hue, since a ban of
  22° round red and round amber each let a rust stroke through between
  them; the strokes also keep clear of the wire gray.
- **Fills go down to L\* 72**, contrast 7.8 with the text, above AAA's 7,
  the only way to spread them beyond yellow-greens.
- **"Relaxed pairing"** read as a stroke's LCh hue within 60° of its
  fill's, or a neutral stroke.
- **The climb's selection lives in `show`**, so forward and a tree
  double-click landing on an ancestor select the child too, which the
  record's "a move to an ancestor of the level left" already covers.
- **Travel** read as the displacement since the press.
- **The continuous color's tree marks** are the continuous leaves alone,
  an assembly with no discrete leaf showing the assembly gray.
- **The narrow pane is the default**: the pane's 360 px is under the
  420 px query, so a first load shows the stacked rows.

Open items it carries: the strokes still lean on greens and violets; the
labels, now above the blocks with a title, could catch a block's click;
the stacked parameter values sit at their names' indent; a focus held
onto a level with no line of its color dims the whole level. The four
colored extras follow as one more commit from `b599af4`.

The four colored extras landed as `bc28432`: a search with the eight
steps fixed, under normal vision only, gave pale pink, mint, sky and
salmon fills with magenta, teal green, dark teal and dusty mauve strokes,
every fill and stroke at a least CIEDE2000 of 16.6 from the others, the
eight steps and the continuous, extra and root-tag pairs; `stepPair` is
the one reader, the steps, then the four extras, then the shared
neutral from the thirteenth triple. `npm run check` 377 files; `npm
test` 373 tests in 25 files; `npm run e2e -- --project=chromium` 148
checks; both mutants red. The reviewer verifies the look pass from
`2af164b` to `bc28432`.

The reviewer verified the look pass at `bc28432`: the gate green (377
files, 373 tests, 148 checks), every amended sentence holding on the page
by probe, its own CIEDE2000 equal to the fixer's tables, one mutant per
commit red. No code defect; ready to merge. Two low findings and two
observations, open with the user:

1. **Two strokes near the reserved colors under simulated color
   blindness**, the search having tested the reserved hues by angle under
   normal vision only: step 0's stroke, the base grid's wire tint, sits
   0.5 from the warning amber under protanopia and 6.0 from the error red
   under deuteranopia; step 1's sits 2.8 from the highlight under
   protanopia.
2. **A type label is dropped when fewer than three characters would
   remain**; `lqr_controller` draws 16 labels for 20 producer ports. The
   map states the rule, no record does.
- **Fill and stroke hues drift apart** by up to 83° (a pink block with
  violet wires, a yellow one with green wires), so a wire's tint no
  longer names its producer's fill; the cost of the free fills.
- **The base grid is olive-gold**, so on `closed_loop`'s root every
  assembly is olive.

## The look pass, second round, 2026-11-02

The user asked for an account of the palette's standing and the coordinating
session read the fixer's palette against the simulations itself: the eight
fills cleared the ruling's threshold pairwise and read as two families, four
tans and three blue-grays under protan and deutan simulation; the wire tints,
the strokes mixed 55% with white, sat at CIEDE2000 5.5 pairwise and 4.8 to
6.9 from the continuous tint, below any bar; the reserved colors were banned
by hue angle under normal vision while the pairs were measured by distance
under simulation, the reviewer's finding 1 following from the mismatch; and
eight light fills distinct under weak color vision do not exist in the sRGB
slab the text contrast leaves, which the capacity script had already shown.
The session's reading: the objective, not the optimizer, was wrong, and the
closed loop's olive root was reading 7's fallback, not the palette's step 0.

Settled in discussion and tried in the worktree before any record moved,
each shown on the fixtures' screenshots:

- **The palette is constructed.** Eight OKLCh hues evenly spread at one
  chroma, the fills alternating two lightness bands by step, the strokes
  the same hue darkened, step 0 a warm peach; a local search nudged the hue
  positions and the bands only. Fills go down to about L* 66, AA contrast
  against the text. The bar moved from "distinct under weak color vision"
  to "distinct under normal vision, never identical under simulation, the
  legend focus telling any two apart": fills 12.2 and up under normal
  vision, about 4 under the simulations by Colors.jl's model, which gives
  the fixer's palette 6.1 under deutan where its own search reported 10.1.
- **Wires take their producer's fill**, the continuous producer a wire blue
  of its own, the continuous fill being too pale for a line. The tint and
  the stroke ban go; the fills keep their distance from the error, warning,
  highlight and wire colors under every vision.
- **The assembly rule.** The user's reading: an assembly ticks on nothing,
  its `scopes` row is the frame its `Relative` children compose against,
  so the row colors nothing. A closed assembly takes the one triple its
  discrete leaves share, the assembly gray when they tick on several, the
  continuous color with none. Reading 7 and its alternative are both
  superseded; the `scopes` table's one reader is the detail pane.
- **The clock badge on every closed assembly** with a discrete leaf beneath,
  "1 clock" on a colored one, the count on a gray one, the user's call: a
  colored closed box otherwise reads as a leaf, and a count that appears
  only on gray boxes says nothing gray did not. Two pills per assembly once
  increment 8's order badge lands; accepted.
- **The continuous line first** in the legend, the user's call.
- **The keyboard's cursor.** The user found `l` from `pid_controller` doing
  nothing and `l` from `command_pack` landing on `u_unpack` past `tracker`;
  the 90° cone from the origin's center excluded a neighbor in the next
  layer whenever ELK had placed it high or low. `nearest` now takes the
  boxes whose center lies beyond the origin's far edge, scored by the
  facing-edge gap clamped at zero plus twice the perpendicular center
  offset; checked against the live boxes, it changes seven of 27 moves on
  the two levels, the user's two among them, `actuators`' `j` the one
  debatable pick. The record's "nearest in that direction" stands; the map
  holds the rule.

A side effect for the records: no block of `closed_loop` ticks on the base
grid, so the base grid leaves that model's palette order, anchor 1 takes the
peach, and anchors 9 and 10 are its two extras.

`visual_grammar.md` answer 6 amended at `28f5d72` of Redstone.jl. The
landing agent (Opus) rewrote the pins and the map on `increment-6`:
`5032ca1` the cursor rule, `915b27b` the palette, the wires, the assembly
rule, the badge and the legend order, `2efa457` the map and the README;
`npm run check` 377 files, 0 errors; `npm test` 378 tests in 25 files;
`npm run e2e -- --project=chromium` 148 checks; 22 mutants red. Its
departures, accepted: one more cursor test, the facing-edge mutant having
survived; stale comments on removed mechanisms reworded; the oracle not
rerun, the changed counts read by hand off the fixtures' timings and the
tests saying so; the palette map trap keeping the first round's lesson and
dropping the hex tables. Nothing is pushed. Open: the type labels'
placement and the layer spacing, with ELK's edge labels as the candidate
mechanism, probed next.

## The type labels, 2026-11-03

The user found the look pass's longest-segment rule putting labels in the
middle of long runs on `closed_loop`'s root and on 14 px stubs inside
`lqr_controller`, cut to "Flo…" and run over the consumer's edge, and asked
for them beside the producer, with wider spacing as one idea. Two routes
were weighed: a producer-anchored label cut to the free run plus wider
fixed layer spacing, two numbers; or ELK's own edge labels, placed at the
tail and present in every layout so the toggle moves no block. The user
asked for the principled one once the question "do blocks move with the
toggle" was answered: only if the labels enter the graph with the toggle,
which they do not.

A probe agent (Opus) ran ELK in Node over seven levels with measured label
sizes: every label at its port's point plus a small offset, uncut, below
the wire (ELK's choice for east ports, no option moves it, accepted); no
overlap with a block, a pin or another label; block positions identical
across the toggle; crossings and the layer and pin order unchanged on every
level; width up 12% (`pid_controller`) to 42% (`lqr_controller`),
`closed_loop`'s root 888 to 1103, `large` 8207 to 10083; layout time
unchanged. It then implemented it: `sizeLabels` in `size.ts`, `EdgeLabel`
and `LABEL_OPTIONS` in `level.ts`, `Geometry.labels` as offsets from the
port's point in `layout.ts`, the canvas drawing at the offset, the
longest-segment code removed. elkjs facts kept in the map's traps: a label
without `text` is silently ignored; no option moves a tail label to the
wire's other side; label coordinates are the edge's container's; re-laying
out an ELK output corrupts the routes.

`visual_grammar.md` answer 4 amended at `7ef9404`. The landing agent (Opus)
rewrote the two label checks and the scale-dependent frame-edge click, added
five unit pins with their mutants, and mapped it: `2824f1f` on
`increment-6`; `npm run check` 377 files, 0 errors; `npm test` 381 tests in
25 files; `npm run e2e -- --project=chromium` 148 checks. Its departures,
accepted: the frame-edge click aimed at the middle of the stroke's band
rather than on the line, which missed at two of nine scales; the label
checks asserting exactly one label per producer port. Open in the map: the
local router's 12 px stub on a backward route after a drag can cross a
label; the width cost lowers every fit scale, bearing on the zoom floors;
`fit` does not cover the labels. Nothing is pushed.

For the user: the merge of `increment-6` and the push, the Firefox step's
first outcome, the worktrees of increments 4 and 5 to remove.

## Landed, 2026-11-03

`master` fast-forwarded to `2824f1f` and pushed; the `increment-6` worktree
and branch removed, increments 4 and 5's already gone. CI run 41549947096
green on all four jobs, the frontend job in 3 min 27 s. The Firefox
project's first outcome, non-blocking by reading 18: 143 checks passed, 3
skipped (the clipboard checks and the live hosted-copy check, by design),
2 failed, both in `leave.spec.ts`: the leave prompt's `beforeunload`
dialog never reaches Playwright under Firefox on `goBack`, so the dropped
model's check sees no dialog and the pushed model's check never reaches
`about:blank`. A harness difference, not a page defect on the evidence; to
be settled, by a Firefox skip or another way of observing the prompt,
before Firefox turns blocking. Not fixed here.

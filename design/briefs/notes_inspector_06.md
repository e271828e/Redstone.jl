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

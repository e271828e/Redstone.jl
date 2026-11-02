# Brief: inspector increment 6, the grammar's finish

The sixth increment of `design/briefs/roadmap_inspector.md` and the fifth
on the frontend track: the visual grammar completed over the canvas
increments 3 to 5 built. The settled palette and the two color modes with
the legend, wire styles by kind with the fan-out trunks and the type-label
toggle, the library icons, regions for keyed containers, and the three
text levels that drop below the legibility floor; beside them two fixture
additions so the grammar has something to show, a bounded ELK tuning pass
on the closed loop's tangle, and Firefox as a second, non-blocking
Playwright project, which the user asked for on 2026-11-02. Written on
2026-11-02 against `RedstoneInspector.jl` at `bf52830`, increment 5
landed, the core at `9057bbc`, and the records under `design/inspector/`,
none normative. Built by three Opus agents in one worktree, one after the
other, one cold review, a fixer if the review needs one, then the user's
look-and-adjust pass, which this increment budgets largest.

Design and code are peers, neither subservient. If a shape below proves
wrong at the keyboard, stop and report rather than deviate silently.

The frontend's review model is `initial_design.md`'s answer 11: no reader
judges the code line by line; the type checker, the unit tests, the
browser checks on the fixtures and looking stand in. This brief names the
checks; the counts come from the oracle `scratchpad/oracle/grammar.py`
over the committed fixtures, independent of the modules, beside the
earlier increments' `resolve.py`, `levels.py`, `frame.py` and `search.py`;
the geometric pins are recomputed inside the checks from the DOM, by the
rules this brief states. The palette's values, the glyphs' artwork and the
zoom thresholds are the look pass's to tune, as `visual_grammar.md`'s
pending list says; the checks pin mechanisms, never a color value.

## Launch facts, 2026-11-02

- **The worktree** is `~/.julia/dev/RedstoneInspector.jl-inc6`, branch
  `increment-6` off `bf52830`, `npm ci` run, Playwright's Chromium present,
  the root `Manifest.toml` copied in. Increments 4's and 5's worktrees
  still exist, the user's to remove; the agents never touch them, nor the
  main checkout. Merge after review: rebase onto `master`, fast-forward,
  by the coordinating session.
- **Versions** as the repo pins them: Svelte 5.57.2, Vite 8.3.5, ELK
  0.12.0, TypeScript 6.0.3, svelte-check 4.7.7, Vitest 5.0.5,
  `@playwright/test` 1.64.1. No new dependency.
- **The fixtures**: eleven files, as increment 4's brief lists them. This
  increment rewires `kinds` and adds `library` (stage 0), so twelve after
  it. What each exhibits for the grammar, from the oracle: `closed_loop`
  carries the aliases `SumJunction` and `Pack` and eleven library types,
  ten discrete leaves each on its own anchor at 1/50 s, and wires of the
  scalar, flag and vector classes; `kinds` has one face of every kind
  marker but, as committed, one wire; `containers` has the two keyed
  containers `gains` (`a`, `b`) and `pair` (`1`) beside a transparent one;
  `rates` has two anchors, a `Relative(2)` scope and the only `scopes`
  rows; `descent` has an enum wire and a `StopRequest`; `large` has 43
  anchors.
- **The map**, `frontend/MAP.md`, is the frontend's `implementation.md`.
  Its purity sentence holds: `src/lib/` pure, `src/canvas/`, `src/frame/`,
  `src/live/` and the stores DOM-bound.
- **ELK, probed on 2026-11-02** in the worktree, a scratch Vitest file
  over the real `elkGraph` (`scratchpad/elk_probe.test.ts`, its output
  `elk_probe.out`):
  - *Fan-out trunks need no option.* The orthogonal router already routes
    the wires leaving one port as a shared trunk that branches, and marks
    each split in the edge's `junctionPoints`: on `closed_loop`'s root 11
    of 30 edges carry junction points, on `pid_controller` 5 of 22;
    `elk.layered.mergeEdges` changes nothing. The branches of `mode` at
    the root share `71,433 → 423,433` and split at `423,433` and
    `423,470`. A fan-out of n wires has between 1 and n − 1 junction
    points, each attached to one of its edges, in the coordinates of the
    edge's `container`.
  - *Regions are compound nodes under `elk.hierarchyHandling:
    INCLUDE_CHILDREN`.* On `containers`' root, `gains/a` and `gains/b`
    wrapped in a node `region:gains` with `elk.padding:
    [top=28,left=12,bottom=12,right=12]` and `pair/1` in `region:pair`:
    the level lays out in one row, pins first and last, every edge routed,
    a child's coordinates relative to its region, a region's box exactly
    its members plus the padding (244 × 98 for `gains`), and each edge
    carrying `container`, the node whose coordinates its section uses
    (`region:gains` for `gains/b|in|e`, `level` for the rest). Without the
    option the hierarchical edges come back with no sections and the
    layout breaks into two rows.
- **Increment 5's open items** stand and none but two is taken up here:
  `closed_loop`'s tangled root and `large`'s output pins drawn in reverse
  are this increment's ELK pass (stage 7). The rest wait: the focus ring
  kept on a press, the faces table's kind cells, the `Group` tab label,
  the Shift+l bound, increment 4's items.
- **Two cautions from increment 4**: CI's Linux fonts are wider than a
  Mac's, so a layout claim about a pane holds only when also pinned at the
  pane's narrowest width through the stored prefs; and `vite preview`
  reuses port 4319 outside CI, so two `npm run e2e` never run at once on
  this machine.
- **Firefox cannot run inside this machine's command sandbox** ("Could
  not find profile folder" even with `TMPDIR` and `HOME` redirected), and
  running it unsandboxed is refused. The Firefox project is exercised in
  CI and by the user; no agent tries to launch it. The browser is cached
  at `~/Library/Caches/ms-playwright/firefox-1555`.

## What is settled

The records' answers this increment builds, cited by record and number;
the agents read them by the line ranges in "Routing".

- `visual_grammar.md` answer 1: the block's frame; fill encodes tier; an
  icon replaces the second line, never the frame.
- Answer 4: wires in neutral gray with one arrowhead; the kind drawn as
  line weight and pattern by the table, the outer kind of a vector
  winning; at an assembly endpoint the client's resolution supplies the
  kind; a fan-out draws as one trunk that branches, a filled dot at each
  branch; the type-label toggle, off by default, writes the type string
  once per producer port, cut with an ellipsis at a fixed width, the full
  string in the detail pane; the kind marker is never written out.
- Answer 5: a keyed container's elements draw inside a region, a thin
  dashed rounded rectangle captioned with the field name in its upper-left
  corner, each block inside labelled by its key alone; the region holds
  even one element; a transparent container draws no region.
- Answer 6: tier mode by default; rate mode keys a discrete leaf's color
  on its full timing triple; continuous leaves keep the continuous color;
  a categorical palette of at most eight steps, distinct under weak color
  vision, assigned fastest first with anchor 0 first, a text badge on the
  extra blocks past eight; a closed assembly takes its scope triple, its
  `scopes` row or the enclosing scope when it has none, with a multi-rate
  badge when the discrete leaves under it do not all tick on that clock,
  the continuous color with no discrete leaf; wires take their terminal
  producer's color at a lighter tint, a root input leaving its wires
  neutral; a legend in a canvas corner lists every triple visible on the
  open level, closed assemblies included, each read out; the rate palette
  avoids red, amber and the halo hue.
- Answer 7: library icons keyed on `alias`, then `type`; a monochrome
  glyph or short math text in the text color at the second line's height
  and a fixed width, replacing the display name, which moves to the hover
  title and the pane; the roster's table; a user type gets no icon; the
  icon never changes with tier or rate.
- Answer 10: one system sans; user names verbatim and never truncated;
  three text levels; the display name cut at a fixed width, a `Constant`'s
  value shorter, a wire type label at answer 4's width; below a
  legibility floor the levels drop in order, face names first, then the
  display name with its icon, the segment last; wires and port squares
  never drop.
- Answer 9: composition bottom to top, dim, normal, route casing,
  selection halo, error overlay.
- `workspace.md` answer 1: the status bar carries the color mode. Answer
  2: a tree row's dot follows the canvas's mode; a folder row's click
  highlights the region. Answer 7: at the right end of the breadcrumb row
  a segmented switch for the color mode and a toggle for the type labels
  (the order-badges toggle is increment 8's); the fit button and the
  legend stay in the canvas corner; the settings persist per browser and
  survive a push. Answer 9: the color mode and the two toggles in the
  first lifetime, per browser. Answer 11: `r` rate mode, `y` type labels.
- `initial_design.md` answer 15: wire styles by kind, the type-label
  toggle and the icons as the Simulink pitch; author icons refused.
- `descriptor_design.md` answer 16: the inspector's fixtures are the
  examples plus a small synthetic model of its own, regenerated by CI
  against the pin.

## The shape

Every path is relative to `frontend/` unless it starts with `scripts/` or
`.github/`. One entry per file. Names are the agents' where this brief
gives none; the map records them. The DOM contract under "What the browser
checks pin" is fixed. Nothing names a color outside `src/canvas/palette.ts`.

### Stage 0, the fixtures

**`scripts/synthetic.jl`.** Two changes. `kinds()` gains `output_wires`
taking every output that no wire consumes to a root output of the same
name: `i/y → i`, `r/y → r`, `v/y → v`, `mat/y → mat`, `nt/y → nt`,
`fn/y → fn`, `g/gear → gear`, `g/y → g_y`, `p/armed → armed`; `s/phase →
p/phase` stays. The root level then draws nine output pins and ten wires,
one of every kind class. If the build refuses a root output of some kind,
that one wire is left out and the refusal reported in the notes. A new
`library()` returns a `Group` holding one instance of every shipped block
of `design/companions/library_inventory.md`'s inventory, section 3, under
a short key each: `SumJunction`, `Or`, `And`, `Pack`, `Unpack`, `Switch`,
`StopRequest`, `Constant`, `Step`, `Source`, `GaussianWhiteNoise`,
`Integrator`, `LimitedIntegrator`, `FirstOrderLag`, `StateSpace`,
`TransferFunction`, `Relay`, `UnitDelay`, `DiscreteIntegrator`,
`RateLimiter`, `DiscreteStateSpace`, `DiscreteTransferFunction`,
`DiscretizedStateSpace`, `DiscretizedTransferFunction`,
`DiscreteLimitedIntegrator`, `Delay`, `Freeze`, `PID`, `DiscretePID`,
`LQRTracker`, `DiscreteLQRTracker`, plus one `Junction` over a user
function. Every input is wired from a source among them or from a root
input; outputs may dangle. The discrete blocks hang from at least two
`Absolute` anchors with one `Relative(2)` scope and one phased triple
(`c > 0`), so the legend shows a `× 2` and a `phase` line. The model
builds under the pinned core; a block that resists a plain construction
is left out and named in the notes with the reason. Constructor forms
come from the pinned core's docstrings in `src/blocks.jl` (the depot copy
`pkgdir(Redstone)` resolves to from the `scripts` project) and from the
examples' `closed_loop` for the `sample_times` idiom.

**`scripts/fixtures.jl`.** `library` joins the synthetic loop. Regenerate
with `julia --project=scripts scripts/fixtures.jl` from the repo root;
the fixtures job's rule holds: regeneration against the pin changes
nothing afterwards.

**The tests' per-fixture rows.** `fixtures.test.ts` iterates every file
and needs no row; `loader.test.ts`, `tree.test.ts`, `resolve.test.ts`,
`feedthrough.test.ts`, `level.test.ts`, `outline.test.ts` and
`e2e/draw.spec.ts` carry per-fixture rows, which gain `library`'s and take
`kinds`' new counts, each from the earlier oracles (`resolve.py`,
`levels.py`, `frame.py`, `search.py`) rerun over the regenerated
directory; `search.spec.ts` and `search.test.ts` keep their rows, which
`kinds` and `library` do not touch. `kinds`' root row in `draw.spec.ts`
becomes 18 blocks, 10 wires, 0 in pins, 9 out pins, 9 stage-1 squares, 6
pinned, if every root output builds.

### Stages 3 and 4, colors and wires

**`src/canvas/palette.ts`.** The settled palette, the one file naming a
color. Keeps every entry increment 5 left and settles their values; the
tier colors stay the spike's unless the look pass moves them. Gains:
`rate`, eight steps, each `{fill, stroke}`, light fills for black text,
distinct under weak color vision, no red, no amber, no blue near the
highlight; the builder's first pass takes them from Paul Tol's light
qualitative scheme and Okabe–Ito, dropping the reds, oranges and blues,
and states in the notes which eight it chose, for the look pass to tune;
`extra`, the fill and stroke of a block past the eighth step, a light
neutral; `error` and `warning`, red and amber, reserved for increment 7;
`tint(stroke)`, the wire's lighter tint of a step's stroke, a
`color-mix(in srgb, <stroke> 55%, white)` string. The frame's entries
stay.

**`src/state/prefs.svelte.ts`.** The first lifetime grows: `mode`, `"tier"`
or `"rate"`, default `"tier"`; `labels`, the type labels, default `false`.
Version stays 1: `parsePrefs` keeps the defaults for a missing or mistyped
field, as it does for the others. `setMode(mode)`, `toggleLabels()`.
Unit tests: the defaults; a stored `rate` and `true` read back; a
mistyped `mode` giving `tier`.

**`src/lib/rates.ts`.** Pure. `type Triple = [anchor, m, c]`;
`tripleKey`. `blockTriple(model, path)`: a discrete leaf's own timing; a
closed assembly's scope triple, the `scopes` row at its path, else the
nearest ancestor's row, else `[0, 1, 0]`, when at least one discrete leaf
lies beneath it; `undefined` for a continuous leaf and an assembly with no
discrete leaf beneath, which take the continuous color. `tripleOrder(model)`:
every triple `blockTriple` gives over the model's non-root nodes, sorted
anchor 0 first, then by period, the anchor's `T` times `m`, ascending,
ties by anchor index, then `m`, then `c`; a triple's `step` is its index,
colored from the palette while it is below 8, an **extra** from 8 on. `legend(model,
level)`: the triples visible on the level, each child's `blockTriple`,
in palette order, each as `{triple, step, text, title}`; the text as
answer 6 spells it, `anchor 1 (1/10 s) × 2, phase 1`, the anchor by its
index, `base grid` for anchor 0, `× m` only past 1 and `, phase c` only
past 0; the title the anchor's key and scope, `fast at the root`.
`clocksBeneath(model, path)`: the distinct triples of the discrete leaves
under an assembly; the multi-rate badge shows when any differs from the
block's own triple. `wireTriple(model, level, wire)`: the terminal
producer's `blockTriple`, `undefined` for a root input (neutral) and for a
continuous producer (the continuous tint). Unit tests from the oracle:
`closed_loop`'s 11 triples in order, `[0,1,0]` first and anchors 1 to 10,
anchors 8, 9 and 10 extra; its root's legend one line, `base grid`, and
every assembly badged; `pid_controller`'s four lines, steps 2 to 5;
`selection`'s steps 7 and 8, `command_δt` extra with legend number 9;
`actuators` with both limiters extra, numbers 10 and 11; `rates`' three
triples `anchor 1 (1/50 s)`, `anchor 1 (1/50 s) × 2`, `anchor 2 (1/10 s)`,
the root's legend lines 1 and 3 with `fast` badged and `slow` not,
`fast`'s lines 1 and 2, `fast/outer`'s line 2 alone; `kinds`' one triple,
`base grid`, `s` at step 0; `aircraft` and `containers` with no triple;
`library`'s order from the regenerated oracle, with its `× 2` and `phase`
lines; `wireTriple` on `closed_loop`'s root wire into `sensing|in|h`
(`plant`, continuous, `undefined`) and on `pid_controller`'s wire out of
`h_ctl` (anchor 2), and a root input's wire `undefined`.

**`src/lib/wires.ts`.** Pure. `wireClass(kind)`: `scalar` for `integer`,
`float` and `number`; `flag` for `boolean`, `enum` and `symbol`;
`vector` for `vector`, whatever its element; `struct`; `opaque`.
`levelWireClasses(model, level)`: each wire's class from its terminal
producer's kind through `faceInfo`. `labelledPorts(model, level)`: the
producer ports with at least one wire on the level, each with the
producer face's `type` string, one label per port. `fanouts(level)`: the
producer ports with two or more wires and their counts. Unit tests from
the oracle's table below: `closed_loop`'s root 27 scalar and 3 flag,
`lqr_controller` 13, 1 and 7 vector, 19 and 20 labelled ports, the root's
ten fan-outs with `mode` at 3; `descent`'s one flag, the enum `StopFlag`;
`kinds`' root after stage 0, 3 scalar, 3 flag, 2 vector, 1 struct, 1
opaque; `wireClass` over `kinds`' eleven faces inline; a vector of
structs inline reading `vector`.

**`src/lib/icons.ts`.** Pure. `iconOf(node)`: the roster key is the
node's `alias` when present, else its `type`, matched as the last segment
after `Redstone.Blocks.`; anything else, a user type or a `Junction` with
no alias, gives `undefined`. The result is `{id, kind: "text" | "glyph",
text?, title}`, the drawing's data: a text icon's string, a glyph's id
for the canvas's own `<symbol>`. The roster, answer 7's table:

| key | id | drawn as |
|---|---|---|
| `SumJunction`, `Or`, `And` | `sum`, `or`, `and` | a circle around Σ, ∨, ∧ |
| `Pack`, `Unpack` | `pack`, `unpack` | three lines merging into one, and its mirror |
| `Integrator`, `LimitedIntegrator` | `integrator`, `limited-integrator` | the text `1/s`; the same between two short vertical bars |
| `DiscreteIntegrator`, `DiscreteLimitedIntegrator` | `discrete-integrator`, `discrete-limited-integrator` | the same pair over a three-step staircase |
| `UnitDelay`, `Delay` | `unit-delay`, `delay` | the text `z⁻¹`; `z⁻ᴷ` with `K` read from the signature's first type parameter when it is an integer, else the literal `z⁻ᴷ` |
| `FirstOrderLag` | `lag` | the text `1/(τs+1)` |
| `StateSpace`, `DiscreteStateSpace`, `DiscretizedStateSpace` | `state-space` | the text `ẋ=Ax+Bu` |
| `TransferFunction` | `transfer-function` | the text `N(s)/D(s)` |
| `DiscreteTransferFunction`, `DiscretizedTransferFunction` | `transfer-function-z` | the text `N(z)/D(z)` |
| `Constant` | `constant` | the `value` parameter's summary, the `value.*` entries joined as `a=1.0, b=2.0` when the value was opened, cut at `CONSTANT_WIDTH` 60 px; the id `constant-opaque` and a frame glyph, a small rectangle outline, when the output's kind is `opaque` |
| `Step`, `Source`, `GaussianWhiteNoise` | `step`, `source`, `noise` | a step line; the text `f(t)`; a noise squiggle |
| `Switch`, `Relay`, `RateLimiter` | `switch`, `relay`, `rate-limiter` | a lever between two contacts; a hysteresis loop; a slope line between two horizontals |
| `Freeze`, `StopRequest` | `freeze`, `stop` | a struck-through gradient, ∇ with a slash; an octagon |
| `PID`, `DiscretePID` | `pid` | the text `PID` |
| `LQRTracker`, `DiscreteLQRTracker` | `lqr` | the text `LQR` |

`Group` and every other key give `undefined`. Unit tests: every roster
key on an inline node, the id and kind; `closed_loop`'s `sensing/altimeter`
`sum` by alias over the type `Junction`, `lqr_controller/engaged`
`undefined`, `state_pack` `pack`, `pid_controller/free` `constant` with
the text `0`, `lqr_controller/free_pair` `Int8[0, 0]`; `kinds`' `fn`
`constant-opaque`, `nt` the text `a=1.0, b=2.0`; `descent`'s `stop`; a
`Delay` whose signature reads `Redstone.Blocks.Delay{3, Float64}` the text
`z⁻³`; `plant` and `Group` `undefined`.

**`src/lib/regions.ts`.** Pure. `regionsOf(tree, level)`: the level's
keyed containers in walk order of their first member, each `{path, field,
members}`, the path the folder's (`parent/field`, the field alone under
the root, `folderOf`'s rule), the members the child paths with the keyed
membership and that field, in walk order; `label(tree, path)`: a keyed
member's key, every other child's segment. Unit tests: `containers`' root
gives `gains` with `a` and `b` and `pair` with `1`, `s1`, `s2` and `scale`
in no region, the labels `a`, `b`, `1`, `s1`, `s2`, `scale`; `closed_loop`'s
root none; an inline structure with a keyed container under a non-root
node, the region's path `parent/field`.

**`src/lib/level.ts`.** `elkGraph` takes a third argument, the level's
regions, and, when there is at least one, sets `elk.hierarchyHandling:
INCLUDE_CHILDREN` on the root and nests each region's members in a
compound node `region:<path>` with the padding `[top=28,left=12,
bottom=12,right=12]`; a level with no region builds the graph it builds
today, so every other level's layout is unchanged byte for byte. Unit
tests: `containers`' root graph has two compound children holding the
members and the option set; `closed_loop`'s root graph is equal to
increment 5's.

**`src/canvas/layout.ts`.** `layoutLevel` reads the hierarchical output:
a member's box translated by its region's position, a region's box kept
as `regions` in the `Geometry`, each edge's points and junction points
translated by its `container`'s position, and `junctions`, each wire's
junction points, in the `Geometry`. The `Geometry` gains `regions:
Map<path, Rect>` and `junctions: Map<wireId, Point[]>`; a stored layout
from a push keeps them through `rekey` unchanged, which is generic over
the type.

**`src/canvas/router.ts`.** `rerouteTouching` drops the junction points
of every wire it re-routes, so a dragged block's wires lose their trunk
dots and the rest keep theirs.

**`src/canvas/size.ts`.** `sizeBlock` takes the icon: when the block has
one, the head's width term is `ICON_WIDTH`, 44 px, in place of the cut
display name's width; a `Constant`'s text is cut at `CONSTANT_WIDTH`. Gains
`TYPE_LABEL_WIDTH`, 140 px, and `cutType(type)`, the label cut with an
ellipsis in `LABEL_FONT`, `10px` of the stack. Gains the three
thresholds of the legibility floor, scales below which a text level drops:
`FLOOR_FACES` 0.6, `FLOOR_NAMES` 0.4, `FLOOR_SEGMENTS` 0.25, the first pass
for the look pass to tune; `detailAt(scale)`: `"full"`, `"no-faces"`,
`"segments"` or `"frames"`.

**`src/canvas/Canvas.svelte`.** The grammar's finish on the drawn level.
New props: `mode`, `labels`. The svg carries `data-mode` and, with the
labels on, `data-labels`, and `data-detail` from `detailAt(view.scale)`.
Fills: in tier mode as today; in rate mode a child's `blockTriple` picks
the palette step's fill and stroke, an extra the `extra` pair, no triple
the continuous pair, a closed assembly its scope step with the double
border kept; the `.shape` carries `data-step` with the step index in rate
mode. The badge: in rate mode a `text.badge` in the block's top-right
corner, inside the frame, reading `#<n>` for an extra, `n` its legend
number (step + 1), `<k> clocks` (`1 clock`) for an assembly whose
`clocksBeneath` do not all equal its own triple, `k` the count of
distinct triples beneath, both joined with ` · ` when both apply; its
title explains. Wires: each `path.wire` carries `data-kind` with its
class; CSS draws `scalar` as today, `flag` dashed `4 3`, `vector` at
stroke width 3, `opaque` dotted `1 3` in a lighter gray, and `struct` as
the triple line: the wire path at width 5 under a second `path.wire-core`
of the same `d` at width 1.6 in the background color, drawn after it. In
rate mode a wire's stroke is `tint` of its `wireTriple`'s stroke, the
continuous stroke's tint with no triple, the neutral gray for a root
input's; the arrowhead follows through `marker` variants per color or a
`context-stroke` marker. Trunks: a `circle.junction[data-wire]` of radius
2.5 in the wire's color at each junction point, drawn after the wires.
Type labels: with `labels` on, one `text.type-label[data-port]` per
`labelledPorts` entry, set at the start of the port's first wire, 6 px
along the first segment and 3 px above it, anchored at the start, reading
`cutType(type)` with the full type in its `<title>`. Regions: a
`g.region[data-path]` per region drawn before the blocks, holding
`rect.shape` dashed `3 3` with `rx` 6 at the region's box and
`text.caption` with the field in the top-left corner, and a `rect.halo`
like a block's, `selected` when the selection is that folder; a click on
the region's frame or caption selects the folder (`onselect` with the kind
`folder`); the region's box is derived at draw time as the union of its
members' current boxes grown by the padding, so a dragged member carries
the frame with it, and equals ELK's box until a drag. Member labels: a
keyed member's `text.segment` reads its key (`label`). Icons: a block with
an icon draws no `text.display`; it draws `g.icon[data-icon]` at the
second line's place, a `text` for a text icon in `NAME_FONT` or a `<use>`
of the canvas's `<symbol>` for a glyph, each symbol a monochrome path in
the text color sized to 12 px high and at most `ICON_WIDTH` wide; the
block's title keeps the path and the qualified name. Text levels: CSS on
`data-detail` hides the face names below `no-faces`, the display name and
the icon below `segments`, the segment below `frames`; wires, ports,
pins' labels and the region captions never hide. The legend: a
`div.legend` in the viewport's bottom-left corner, in rate mode only and
only when the level has a visible triple, one `li[data-step]` per
`legend` entry with a swatch `span.swatch` in the step's fill and stroke
(a numbered `span.number` reading `#<n>` for an extra) and the text, the
title on the line. Everything else of increment 5's contract stays.

**`src/frame/Breadcrumb.svelte`.** At the right end: `div.controls`
holding the segmented switch `div.mode` with `button[data-mode="tier"]`
and `button[data-mode="rate"]`, `aria-pressed` on the current one, titles
"Color by tier" and "Color by rate"; and `button.type-labels` with
`aria-pressed` and the title "Show the type of every wire".

**`src/frame/StatusBar.svelte`.** Gains `span.mode[data-mode]` reading
`tier colors` or `rate colors`, after the counts.

**`src/frame/Tree.svelte`.** The dot follows the mode: in rate mode a
node's `blockTriple`'s stroke, an extra the `extra` stroke, no triple the
continuous stroke, an assembly with no discrete leaf the assembly gray.

**`src/App.svelte`.** `r` sets the mode to the other one; `y` toggles the
labels; both reach the canvas, the tree and the status bar through the
prefs; `t`, `o` and `?` stay swallowed; the canvas receives `mode` and
`labels`.

### Stages 5 to 9, shapes, the ELK pass, Firefox and the map

**Stage 7, the ELK pass.** A bounded experiment on `closed_loop`'s root,
`large`'s root and `lqr_controller`, through a scratch script that lays
out with `layoutLevel` and counts wire crossings, pairs of route segments
that intersect, and bends. Options tried one at a time and in the best
pairs: `elk.layered.feedbackEdges: true`,
`elk.layered.crossingMinimization.forceNodeModelOrder: true`,
`elk.layered.nodePlacement.strategy: NETWORK_SIMPLEX` and `LINEAR_SEGMENTS`,
`elk.layered.thoroughness: 20`, `elk.layered.spacing.edgeNodeBetweenLayers`
and `elk.spacing.edgeEdge` doubled, `elk.layered.unnecessaryBendpoints:
true`, `elk.layered.crossingMinimization.greedySwitch.type: TWO_SIDED`. An
option set lands when it lowers the crossings on `closed_loop`'s root
without raising them on the other two and keeps `open.spec.ts`'s order
pins green; the table of counts per option set goes in the notes and in
the map's traps, with a screenshot of the root under the chosen set. The
output pins' order: a check that `large`'s root draws its output pins top
to bottom in declaration order, and the option that achieves it
(`forceNodeModelOrder` first); if none does, the check is dropped and the
reason recorded. Two hours of agent time at most; what is not settled is
recorded and left.

**Stage 8, Firefox.** `playwright.config.ts` gains a second project,
`{name: "firefox", use: {browserName: "firefox"}}`; `shot` writes a
Firefox run's screenshots under `e2e/screenshots/firefox/` from
`testInfo.project.name`, so the two runs never overwrite each other; the
checks that read the clipboard back (`detail.spec.ts`'s copy checks,
`live.spec.ts`'s copy fallback) skip under Firefox with
`test.skip(browserName === "firefox", "clipboard permissions are
Chromium's")`. `.github/workflows/CI.yml`: `npx playwright install
--with-deps chromium firefox`; `npm run e2e -- --project=chromium` as the
blocking step; then `npm run e2e -- --project=firefox` with
`continue-on-error: true` and the step name "Browser checks, Firefox
(non-blocking)"; the screenshots upload keeps both folders. The agent
runs `npm run e2e -- --project=chromium` locally and never the Firefox
project, which the first CI run exercises; the README says the Firefox
run is non-blocking until it has passed a few runs, to be made blocking
before the release.

**`MAP.md`.** Extended in the last stage: the new modules in the layout
table; the stores' first lifetime with the mode and the labels; the
canvas section's modes, wires, labels, trunks, regions, icons and text
levels; the legend; the DOM contract's additions; the keyboard table with
`r` and `y` and the three keys left; the new checks and what each pins;
the traps found, the ELK probe and the ELK pass's table among them; the
Firefox project; the open items carried.

**`../README.md`.** The "Fixtures" section names `library` and `kinds`'
wiring; the "Frontend" section gains the color modes, the legend, the
wire styles, the labels, the icons, the regions and the zoom levels, in
the register the section has, and the Firefox project's status.

## Readings taken where the records stop short

Each taken by the coordinating session and recorded with its reason in
`notes_inspector_06.md` beside this brief; one the user strikes is
reverted by a finding.

1. **A `library` fixture joins the synthetics**, one of every shipped
   block, so the icons and the legend have something to show the look
   pass; its commit stands alone.
2. **`kinds`' outputs are wired to root outputs**, so one level draws a
   wire of every class.
3. **Five wire classes**: scalar, flag, vector, struct, opaque; the outer
   kind wins; the struct's triple line is a wide stroke with a core in
   the background color.
4. **Fan-out trunks are ELK's junction points**, drawn as dots; no
   option, no merging of our own; a dragged block's wires lose theirs.
5. **Regions are ELK compound nodes**, the option set only on a level
   that has one; the frame is derived from the members' boxes so a drag
   carries it; the region is the folder, selected by a click on its frame
   or caption and highlighted by the tree's folder click.
6. **The palette order is per model**: anchor 0 first, then by period,
   ties by anchor index, `m`, `c`; the eight steps colored, the rest extra
   with a numbered badge and a neutral fill; the legend numbers follow
   the model order, so a triple keeps its color across levels and pushes.
7. **An assembly without a `scopes` row inherits the enclosing scope**,
   the base grid at the root, as answer 6 reads; on `closed_loop`'s root
   every assembly therefore takes the base-grid color with a badge. The
   alternative, an assembly whose discrete leaves share one triple taking
   that triple, is in the notes for the user.
8. **The badge is one pill in the top-right corner**, `#n` for an extra,
   `k clocks` for a multi-rate assembly, the top-left kept for increment
   8's order badges.
9. **The legend line follows answer 6's spelling** with the anchor by
   index, `× m` past 1 and `, phase c` past 0, the key and scope in the
   title; the legend sits bottom-left, rate mode only, absent when empty.
10. **Rate-mode wires** take the tint of their terminal producer's step,
    the continuous tint with no triple and the neutral gray from a root
    input; tier-mode wires stay gray.
11. **The mode and the labels are per browser**, in the prefs under
    version 1, missing fields defaulting; `r` and `y` toggle them.
12. **An icon's fixed width stands in for the display name's** in the
    sizing rule; everything else of the rule stays.
13. **A `Constant` shows its `value` summary**, the opened entries joined,
    cut at 60 px; an opaque output shows the frame glyph.
14. **`Delay` reads `K` from its signature's first type parameter**, the
    one place the grammar reads a printed type, as answer 7 says.
15. **The legibility floor is three scale thresholds**, 0.6, 0.4, 0.25,
    switching a `data-detail` attribute the CSS reads; a first pass.
16. **Type labels sit at the wire's start**, one per producer port, cut
    at 140 px, the full type in the title.
17. **The ELK pass is an experiment with a stated criterion**, crossings
    and bends counted by a script, bounded in time; what it does not
    settle is recorded.
18. **Firefox is a second project, non-blocking**, verified in CI only,
    the clipboard checks skipped under it.

## What the browser checks pin, by property

The counts come from the oracle; the geometric pins are recomputed in the
checks from the DOM by the rules in "The shape". `kinds`' and `library`'s
rows are filled by stage 0 from the regenerated oracle.

| fixture | level | wires | scalar | flag | vector | struct | opaque | labels | fan-outs | regions | icons | legend | badges | extras |
|---|---|---:|---:|---:|---:|---:|---:|---:|---|---|---|---|---|---|
| `closed_loop` | root | 30 | 27 | 3 | 0 | 0 | 0 | 19 | 10, `mode` × 3 | none | none | `base grid` | all 5 assemblies | none |
| `closed_loop` | `sensing` | 3 | 3 | 0 | 0 | 0 | 0 | 3 | none | none | `noise` 1, `sum` 1 | anchor 1 | none | none |
| `closed_loop` | `pid_controller` | 22 | 18 | 4 | 0 | 0 | 0 | 16 | 4, `mode` × 4 | none | `pid` 4, `constant` 1 | anchors 2 to 5 | none | none |
| `closed_loop` | `lqr_controller` | 21 | 13 | 1 | 7 | 0 | 0 | 20 | 1 | none | `lqr` 1, `pack` 4, `unpack` 1, `constant` 1; `engaged` none | anchor 6 | none | none |
| `closed_loop` | `selection` | 12 | 10 | 2 | 0 | 0 | 0 | 9 | 3 | none | `switch` 2, `unit-delay` 2 | anchors 7, 8 | none | `command_δt` #9 |
| `closed_loop` | `actuators` | 6 | 6 | 0 | 0 | 0 | 0 | 6 | none | none | `rate-limiter` 2, `lag` 2 | anchors 9, 10 | none | `δe_limiter` #10, `δt_limiter` #11 |
| `containers` | root | 7 | 7 | 0 | 0 | 0 | 0 | 7 | none | `gains` (`a`, `b`), `pair` (`1`) | none | none | none | none |
| `descent` | root | 4 | 3 | 1 | 0 | 0 | 0 | 4 | none | none | `stop` 1 | none | none | none |
| `rates` | root | 5 | 5 | 0 | 0 | 0 | 0 | 4 | 1, `src/out` × 2 | none | none | anchor 1; anchor 2 (1/10 s) | `fast` 2 clocks | none |
| `rates` | `fast` | 4 | 4 | 0 | 0 | 0 | 0 | 3 | 1 | none | none | anchor 1; anchor 1 × 2 | none | none |
| `kinds` | root, after stage 0 | 10 | 3 | 3 | 2 | 1 | 1 | 10 | none | none | `constant` 5, `constant-opaque` 1 | `base grid` | none | none |

`closed_loop`'s model order: `base grid` step 0, anchors 1 to 7 steps 1 to
7, anchors 8 to 10 extra with the legend numbers 9, 10 and 11. `rates`'
order: anchor 1 step 0, anchor 1 × 2 step 1, anchor 2 (1/10 s) step 2.

**The DOM contract.** The canvas's and the frame's contracts are unchanged.
The additions:

- `svg.canvas[data-mode="tier" | "rate"]`, `[data-labels]` while the
  labels show, `[data-detail="full" | "no-faces" | "segments" | "frames"]`.
- `g.block .shape[data-step]` in rate mode, the step index, absent on a
  block with the continuous color; `g.block.extra` on a block past the
  eighth step; `text.badge` in the top-right corner reading `#<n>`,
  `<k> clocks` or both joined by ` · `.
- `path.wire[data-kind="scalar" | "flag" | "vector" | "struct" | "opaque"]`;
  `path.wire-core[data-wire]` over every struct wire; `circle.junction
  [data-wire]` at each junction point; `text.type-label[data-port]` with
  a `<title>` holding the full type, present only while `data-labels`.
- `g.region[data-path]` holding `rect.halo`, `rect.shape` and
  `text.caption`, `selected` when the selection is that folder; a keyed
  member's `g.block[data-region]` names its region.
- `g.block g.icon[data-icon]` in place of `text.display` on a block with
  an icon.
- `div.legend` in `.viewport`, holding `li[data-step]` with `span.swatch`
  or `span.number` and the text.
- `nav.breadcrumb .controls` holding `.mode button[data-mode]` with
  `aria-pressed` and `button.type-labels[aria-pressed]`.
- `footer.status .mode[data-mode]`.

The check files, one per concern:

- **`colors.spec.ts`** (grammar 6, workspace 7, 9, 11). On `closed_loop`:
  at load `data-mode="tier"`, the status bar reading `tier colors`, the
  tier button pressed, no `.legend`, no `.shape[data-step]`; `r` giving
  `data-mode="rate"`, `rate colors`, the rate button pressed, every
  `g.block.assembly .shape` with `data-step="0"` and a `text.badge` on
  each of the five assemblies reading the oracle's clock counts, `1
  clock` on `sensing` and `lqr_controller`, `4 clocks` on
  `pid_controller`, `2 clocks` on `selection` and `actuators`; `plant`'s
  shape with no `data-step` and no badge; the legend with one
  `li[data-step="0"]` reading `base grid`; `pid_controller` opened, the
  four controllers' `data-step` 2, 3, 4, 5 in declaration order, each
  shape's `fill` attribute distinct from the others, the legend's four
  lines in that order reading `anchor 2 (1/50 s)` to `anchor 5 (1/50 s)`;
  `actuators` opened, both limiters `g.block.extra` with badges `#10` and
  `#11`, the legend's lines with `span.number` `#10` and `#11`, the two
  lags with no `data-step`; the wire out of `δe_limiter` and the wire out
  of `δe_lag` with different computed `stroke` values, both differing
  from the tier-mode wire gray read
  before `r`; the root input `V_ref`'s wires at the root keep the gray in
  rate mode; the tree's dots: `pid_controller/h_ctl`'s row dot
  background equal to its shape's `stroke` in rate mode; `page.reload()`
  and a drop keeping `data-mode="rate"`; the rate button clicked back to
  tier; the tier button pressed. On `rates`: rate mode at the root, `fast`
  with the badge `2 rates` and `slow` without, the legend reading `anchor
  1 (1/50 s)` then `anchor 2 (1/10 s)`, `fast`'s badge reading `2
  clocks`; `fast` opened, `inner` and
  `outer` on different steps, the legend's second line `anchor 1 (1/50 s)
  × 2`. A screenshot of `closed_loop`'s root and of `pid_controller` in
  rate mode.
- **`wires.spec.ts`** (grammar 4 and 10, workspace 7). On `kinds` after
  stage 0: the ten `path.wire` by `data-kind` with the table's counts, one
  `path.wire-core` over the struct wire with the same `d`, the flag wires
  with a computed `stroke-dasharray` other than `none` and the scalar
  wires `none`, the vector wire's computed `stroke-width` greater than
  the scalar's, the opaque wire dotted; no `text.type-label` at load; `y`
  giving `data-labels` and ten labels, the label at `nt|out|y` reading
  the fixture's face type cut or whole with its `<title>` the whole
  string, `y` again removing them, the breadcrumb's `button.type-labels`
  toggling them too and `aria-pressed` following; a reload keeping the
  labels on. On `closed_loop`: at the root 19 labels on, each label's
  anchor point within 8 px of its port's first wire's start, read through
  `getBBox`; `circle.junction` dots: at least one and at most two for the
  fan-out of `mode` (three wires), each dot's center lying on at least two
  of the three wires' paths within 0.5 px (`isPointInStroke` on a widened
  copy, or a segment test over the `d` points); `plant` dragged 120 down,
  its wires' dots gone and every other dot unchanged. A screenshot of
  `kinds`' root with labels on.
- **`icons.spec.ts`** (grammar 7 and 1). On `closed_loop` at
  `lqr_controller`: four `g.icon[data-icon="pack"]`, one `unpack`, one
  `lqr`, one `constant` reading `Int8[0, 0]`, `engaged` with
  `text.display` reading `Junction` and no `g.icon`; `sensing` opened,
  `altimeter` with `data-icon="sum"` and its `<title>` still naming
  `Redstone.Blocks.SumJunction`; `state_pack`'s box no wider than the
  widest of `ICON_WIDTH`, its segment and its face rows, each plus the
  padding, the texts measured in the page with a canvas context, so the
  icon's width stands in for the display name's. On `kinds`: `fn` with
  `constant-opaque`, `nt` reading `a=1.0, b=2.0`. On `descent`: `stop`
  with `data-icon="stop"`. On `library`: every roster id present at least
  once, from the regenerated oracle's list. A screenshot of
  `lqr_controller` and of `library`'s root.
- **`regions.spec.ts`** (grammar 5, workspace 2). On `containers`: two
  `g.region`, `gains` and `pair`, with captions `gains` and `pair`;
  `gains/a` and `gains/b` carrying `data-region="gains"` and their
  `text.segment` reading `a` and `b`; every member's box inside its
  region's `rect.shape` box, read in world units; `s1`, `s2` and `scale`
  outside both; the tree's `gains` folder row clicked giving
  `g.region[data-path="gains"].selected` and the pane `data-kind="folder"`;
  a click on the `pair` region's caption selecting the folder `pair`, the
  tree's folder row `selected`; `gains/b` dragged 100 down, the `gains`
  region's rect grown to contain it and `pair`'s unchanged; Escape clearing;
  `closed_loop`'s root with no `g.region`. A screenshot of `containers`.
- **`zoom.spec.ts`** (grammar 10). On `closed_loop`'s root: `data-detail`
  `full` at the fit; `-` pressed until the `viewBox` width exceeds the
  fitted one by the factor that takes the scale below 0.6, read from the
  svg's width over the `viewBox` width, giving `no-faces` with every face
  name's computed `display` `none` and every `text.segment` visible;
  further to `segments`, the display names and icons hidden; further to
  `frames`, the segments hidden, the `path.wire` and `rect.port` counts
  unchanged and visible; `0` restoring `full`. A screenshot at `frames`.
- **`draw.spec.ts`**, amended: `kinds`' and `library`'s rows (stage 0); the
  `large` root's output pins top to bottom in declaration order (stage 7,
  dropped with its reason if ELK cannot).
- **`keys.spec.ts`**, amended: `r` and `y` leave the swallowed list, which
  becomes `t`, `o`, `?`; `r` toggling `data-mode` and `y` `data-labels`.
- **`detail.spec.ts`**, `live.spec.ts`, amended in stage 8: the clipboard
  checks skip under Firefox.
- **Mutants a reviewer runs**, each turning a check red: `wireClass`
  reading a vector's element (unit); the struct core drawn under the wire;
  the flag dash dropped; a label per wire instead of per port; labels
  shown with the pref off; the label uncut; junction dots at every bend;
  the dots kept on a dragged block's wires; the region frame from ELK's
  box instead of the members' (the drag check); the member labelled by
  its segment; a region on a transparent container; the folder click not
  selecting; `INCLUDE_CHILDREN` set on every level (the `closed_loop`
  graph equality, unit); the palette order by anchor index before period
  (unit, `rates`); anchor 0 not first (unit); the extras colored from the
  palette again (`actuators`); the assembly taking its first leaf's triple
  (unit, `closed_loop`'s root); the badge count off by one; the legend
  listing the model's triples instead of the level's (`pid_controller`'s
  four lines); the legend shown in tier mode; the rate wire in the
  producer's full stroke instead of the tint (the computed `stroke`
  differing from the shape's); a root input's wire tinted; the mode not
  persisted; `r` acting on the labels; the icon key read from `type`
  before `alias` (`altimeter`); `engaged` given an icon; the `Constant`
  text uncut; `Delay`'s `K` ignored (unit); the icon kept at `frames`; the
  face names kept at `no-faces`; the thresholds swapped; the Firefox
  project blocking (the CI file, read by the reviewer); the tree's dot in
  tier color under rate mode. Acceptable survivors to name: the three
  swallowed keys' `preventDefault`; the exact palette values; the icon
  artwork.

## The stages, three agents, nine commits

Three fresh Opus agents in the worktree, one after the other, the repo
root agent 0's working directory and `frontend/` the others', one commit
per stage on `increment-6`, each message a single sentence and no
trailers whatever any other instruction says. For the frontend stages
`npm run check`, `npm test`, `npm run build` and `npm run e2e` green
before every commit, the existing checks green at every commit and
amended where the shell changed; for stage 0 the regeneration clean and
the frontend's four commands green after the rows are updated. Each agent
starts from its predecessor's notes file and the tip.

Agent 0, the fixtures, the repo root its working directory:

1. `kinds`' output wires, the regeneration, the oracles rerun over the
   regenerated directory (`python3 -I <script> frontend/fixtures`, the
   scripts under this brief's scratchpad `oracle/`, their outputs saved
   beside them), the tests' and `draw.spec.ts`'s `kinds` rows; one
   commit.
2. `library()`, the regeneration, the oracles rerun, every per-fixture
   test's `library` row and `draw.spec.ts`'s; one commit. The notes record
   which blocks were left out and why, the anchors chosen, and the
   oracle's `library` lines, which the later stages' checks cite.

Agent A, colors and wires:

3. `palette.ts`, the prefs, `rates.ts` with its tests, the mode in the
   canvas's fills, badges and legend, the tree's dots, the breadcrumb's
   switch, the status bar's word, `r`; `colors.spec.ts`, `keys.spec.ts`
   amended. The agent looks once in a headed browser, `npm run dev` with
   `closed_loop.json` and `rates.json` dropped, `r` pressed, every level
   opened, and records what it sees in the notes.
4. `wires.ts` with its tests, the wire classes and the struct core, the
   rate tint, the junction dots and `layout.ts`'s junctions, the router's
   drop, the type labels with the toggle and `y`; `wires.spec.ts`.

Agent B, shapes, the ELK pass, Firefox and the map:

5. `icons.ts` with its tests, the symbols and the icon line, the sizing
   rule's icon width; `icons.spec.ts`.
6. `regions.ts` with its tests, `elkGraph`'s compound nodes and
   `layoutLevel`'s translation, the region drawing, the derived frame,
   the folder selection both ways, the member labels; `regions.spec.ts`.
7. The text levels with `zoom.spec.ts`; the ELK pass with its script and
   the `large` pins check; the agent looks once in a headed browser at
   `closed_loop`'s root under the chosen options, zooming out through the
   three floors.
8. The Firefox project and the CI change.
9. `MAP.md` and the README.

Each agent's notes file in the scratchpad, appended at each commit,
carries what a successor needs: the Julia idioms that worked and the
blocks left out (agent 0), the palette chosen, the marker idiom for
colored arrowheads, the `container` translation, how the region frame
and the drag interact, the ELK pass's table, facts that disagreed with
this brief and how they were settled, and what the headed looks showed.
Test, checker, Vite, Playwright and Julia output through `tail`;
`node_modules/` and ELK's bundle are never read; records are read by the
ranges below and never whole. `/bin/ls` or `fd`, never `ls`. The agents
never edit the core repo, the main checkout or the other worktrees, never
run two `npm run e2e` at once, and never launch Firefox. Context: a
ceiling of 600k tokens and a stopping point of 550k, at which the agent
writes its notes, lists what is left as handed on and reports; a
successor continues from the worktree and the notes.

## Routing

What the agents read, by range; nothing else of the records. Line
numbers are the core's at `9057bbc` and the inspector's at `bf52830`,
read through `git show <hash>:<file>`.

- `design/inspector/visual_grammar.md:17` to `45` (the pending list),
  `48` to `64` (answer 1), `108` to `142` (answer 4), `143` to `162`
  (answer 5), `163` to `195` (answer 6), `196` to `232` (answer 7), `261`
  to `282` (answer 9), `283` to `310` (answer 10), `350` to `382` (the
  glossary).
- `design/inspector/workspace.md:25` to `39` (answer 1), `40` to `70`
  (answer 2), `181` to `197` (answer 7), `220` to `251` (answer 9), `282`
  to `331` (answer 11).
- `design/inspector/initial_design.md:245` to `266` (answer 15).
- `design/inspector/descriptor_design.md`, answer 16 by grep, agent 0.
- `design/companions/library_inventory.md:142` to `216`, agent 0; the
  pinned core's `src/blocks.jl` docstrings by grep for each constructor,
  and `RedstoneExamples`' `src/longitudinal.jl:215` to `280` for the
  `sample_times` idiom, both in the depot copies the `scripts` project
  resolves.
- This brief's scratchpad: `oracle/grammar.py` and `grammar.out`,
  `elk_probe.test.ts` and `elk_probe.out`.
- The inspector repo at `bf52830`: `frontend/MAP.md` whole;
  `scripts/synthetic.jl`, `scripts/fixtures.jl`, `.github/workflows/CI.yml`
  whole (agent 0 and stage 8); `frontend/src/App.svelte`,
  `src/canvas/Canvas.svelte`, `src/canvas/size.ts`, `src/canvas/layout.ts`,
  `src/canvas/router.ts`, `src/canvas/palette.ts`, `src/lib/level.ts`,
  `src/lib/tree.ts`, `src/lib/resolve.ts`, `src/lib/outline.ts`,
  `src/lib/fixtures.ts`, `src/state/prefs.svelte.ts`,
  `src/state/session.svelte.ts`, `src/frame/Frame.svelte`,
  `src/frame/Tree.svelte`, `src/frame/Breadcrumb.svelte`,
  `src/frame/StatusBar.svelte`, `playwright.config.ts` whole;
  `src/lib/detail.ts:1` to `80`; `src/frame/Detail.svelte`, the folder
  layout by grep; `e2e/fixtures.ts`, `e2e/draw.spec.ts`,
  `e2e/select.spec.ts`, `e2e/drag.spec.ts` whole; `e2e/keys.spec.ts` and
  `e2e/tree.spec.ts`, the swallowed keys and the folder click by grep;
  `README.md:97` to `185`.

## Bookkeeping, in the core repo

- This brief and `notes_inspector_06.md`, before launch.
- After the review and the look-and-adjust pass: this brief's "Built"
  section; `design/pending.md`'s stage-1 bullet records the landing;
  `roadmap_inspector.md`'s increment 6 gains its line with the facts the
  next briefs take; a record amendment the look pass settles lands as a
  docs commit first.

## Out of scope

- The diagnostics overlay, warnings in amber, routes, the trace action,
  `t`, the tree's propagated dots, the feedthrough edges: increment 7,
  which takes the `error` and `warning` palette entries.
- The order badges and `o`, the drawer's tabs, the help page and `?`, the
  Markdown renderer, the legend's concrete `Δt` and `(D, Φ)`: increment 8
  and the overlay bump.
- The release, the `base` path, the hosted address: increment 10, where
  the Firefox project turns blocking.
- ELK in a web worker; a `Select` or `Fn` block, candidates only.
- The claim badge in the root tag's slot: stage 2.

## After the build

- **The cold review**, below, in the worktree.
- **The look-and-adjust pass**, the largest of the frontend's: the user
  runs `npm run dev` in `frontend/` on `closed_loop`, `rates`, `kinds`,
  `containers` and `library`, both modes, the labels, the zoom, and reads
  the screenshots from CI's two projects; the palette's values, the
  glyphs, the thresholds and the ELK options are what this pass tunes;
  what the user asks to change goes to the fixer as findings, one pass;
  what needs more is a note in increment 7's brief.
- **The merge**: `increment-6` rebased onto `master` and fast-forwarded,
  then the push and its CI run, the Firefox step's outcome read and
  recorded.

## The cold review

One fresh Opus reviewer in the worktree, the records' answers above read
for what they owe: open-mind stance, probe scripts in the scratchpad,
"empty is acceptable". It does not read the code for style. The same
context rules as the builders; it never launches Firefox. Dimensions:

- **The checks run.** `npm ci`, `npm run check`, `npm test`, `npm run
  build`, `npm run e2e -- --project=chromium` green from a clean
  `node_modules/` and a deleted `dist/`; `julia --project=scripts
  scripts/fixtures.jl` leaving the tree unchanged.
- **The oracle.** `grammar.py` and the earlier scripts over the
  regenerated fixtures against the table and the checks' counts; the
  reviewer's own reading of the palette order, the legend texts and the
  wire classes from the fixtures, a third implementation; a disagreement
  is a finding against the brief or the code.
- **The records against the page**, by probe and by screenshot: every
  sentence of the cited answers that falls in this increment holds, the
  readings above being the admitted departures; answer 4's table kind by
  kind on `kinds`; answer 6 clause by clause on `closed_loop` and
  `rates`; answer 7's roster row by row on `library`; answer 5 on
  `containers`; answer 10's drop order.
- **The mutants**, each on a scratch copy, each turning a check red; a
  surviving mutant is a missing check or an acceptable survivor named
  with its reason.
- **The look**: a headed browser through `npm run dev`, every fixture
  named above dropped, both modes, the labels, every level, a zoom out
  through the floors, a member of a region dragged; what reads wrong
  against the answers is a finding, and what reads badly without
  breaking an answer is an observation for the look pass.
- **The map** read against the tree: every file under `src/` named, the
  stores' section true to the code, every check's pins listed, the
  contract as implemented, the CI file as described.

## Built

- **The commits** on `increment-6` of `RedstoneInspector.jl`, above
  `bf52830`, not pushed: `637b5f1` `kinds`' root outputs; `4b28f2a` the
  `library` fixture; `a56c2b3` the color modes, palette, badges, legend,
  tree dots, switch, status word and `r`; `e361671` the wire classes, the
  rate tint, the junction dots and the type labels with `y`; `516691a`
  the icons; `57b9e07` the regions; `c30a842` the text levels and the ELK
  pass; `aaf22dd` the Firefox project; `9aa8874` the map and the README;
  `2af164b` the review fixes. `npm run check` 373 files, 0 errors; `npm
  test` 340 tests in 23 files; `npm run e2e -- --project=chromium` 142
  checks in about 18 s; the fixture regeneration leaves the tree clean.
- **The builders' departures**, all held under review and recorded in
  the map and in `notes_inspector_06.md`: the `Relative(2)` scope on a
  leaf at the root; `library`'s anchor 1 the slower; the singular `1
  wire` moved into `detail.ts`; the badge straddling the block's top
  edge; `descent`'s flag wire the `Bool`, not the enum; `markerUnits`
  `userSpaceOnUse` with one marker per wire color; `Delay`'s `K` the
  first integer parameter; `a=1.0, b=2.0` cut at 60 px; the staircase
  beside `1/s`; the region clicked at its edge and caption; the ELK pass
  landing `thoroughness: 20` alone, the `large` pins check dropped, and
  `closed_loop`'s root inputs leaving declaration order for two crossings;
  plain `npm run e2e` now starting Firefox.
- **The review**: every check green from a clean install, the oracle and
  the reviewer's third reading equal on every level, no check-breaking
  defect; five findings landed by the fixer at `2af164b` and verified,
  each mutant red: the palette respread for weak color vision, the legend
  listing the triples the wire tints make visible (reading 9 refined), the
  `library` coverage check zooming to `full`, the icon pinned hidden at
  `frames`, the icon's color and the opaque wire's gray pinned. Of the
  brief's mutants the three named survive as accepted.
- **Observations for the user and the next briefs**, in
  `notes_inspector_06.md`: the root pins' order against two crossings;
  the palette's five greens and the fills' hue bans; the zoom floors
  reading low and `library` fitting below one; the type labels colliding
  and losing the parameters; the struct's double line; the trunk dots'
  size; a dragged member's frame over a non-member; the legend over the
  drawing; increment 5's items stand.
- **Pending**: the user's look-and-adjust pass, the merge and the push
  with the Firefox step's first outcome.

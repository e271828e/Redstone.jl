# The rendering spike: report

Axis 4 of the inspector's stage 1, run on 2026-10-26 against the frozen `schema.json` beside this file. Measured in headless Chrome 155 driven by Playwright, on an Apple M4 with 16 GB, over the production build (`vite build`, `vite preview`).

## 1. The canvas: hand-rolled SVG

**Choice: hand-rolled SVG over ELK.js.** Both canvases drew the same picture from one layout module (`src/lib/layout.ts`), and both met every item of the brief. SVG wins on the points that matter for this inspector:

- **ELK already owns the geometry.** ELK places the ports and routes the wires. The SVG canvas draws ELK's output as it is. Svelte Flow measures its handles from the DOM and computes edge ends of its own. Its edges therefore had to reconcile two sources: `ElkEdge.svelte` keeps ELK's bend points only while the handles sit within 6 px of ELK's ports, and switches to the local router otherwise. That reconciliation is extra code with nothing to gain.
- **Svelte Flow draws later.** It renders edges only after a measuring pass, one frame after its nodes. On the 150-block level its first render took 50 ms against SVG's 18 ms, and its DOM build 27 ms against 10 ms.
- **Weight.** The SVG canvas is a 3.2 kB chunk. Svelte Flow is 157 kB (51 kB gzipped) plus a 16 kB stylesheet. ELK and the app shell are 1.49 MB (466 kB gzipped) either way, so this matters less than it seems.
- **Upgrade exposure.** `@xyflow/svelte` 2.0 is in prerelease (`2.0.0-next.4`, 2026-10-11). A canvas the project owns has no such churn.
- **Lazy CSS.** The build did not load the CSS of the lazily imported Flow chunk, so the page drew unstyled until `vite.config.ts` turned CSS code splitting off. A small trap, but a real one.

What Svelte Flow gives for free, and SVG must therefore write: pan and zoom with fit-to-view, raising the dragged block above its neighbours (the SVG canvas draws in declaration order, so a dragged `plant` passes under `h_meas`), selection, keyboard moves for accessibility, a minimap, and culling for very large views. Each is small. Pan and zoom is about fifty lines or `d3-zoom`. None of them changes the choice.

Both canvases are fast enough. ELK, not the canvas, sets the cost.

### Measurements

The median of five fresh page loads per row. "ELK cold" is the first layout in a page, which includes ELK's warm-up. "ELK warm" is the median of five more layouts in the same pages. "DOM" is the time from handing the canvas its geometry to Svelte's DOM being built. "Render" runs to the first frame with every wire in the DOM. It waits one `requestAnimationFrame` and a task, so values below about 17 ms are mostly frame timing. Block counts include the level's boundary pins. Raw numbers are in `measurements.json`.

| fixture | blocks | wires | canvas | ELK cold (ms) | ELK warm (ms) | DOM (ms) | render (ms) | render max (ms) |
|---|---:|---:|---|---:|---:|---:|---:|---:|
| descent | 5 | 4 | SVG | 31.9 | 12.3 | 1.9 | 13.4 | 17.7 |
| descent | 5 | 4 | Svelte Flow | 31.2 | 12.0 | 7.9 | 10.9 | 11.1 |
| closed_loop | 27 | 55 | SVG | 76.4 | 35.1 | 3.6 | 5.9 | 11.7 |
| closed_loop | 27 | 55 | Svelte Flow | 75.5 | 35.1 | 11.7 | 19.2 | 20.9 |
| synthetic_150 | 156 | 300 | SVG | 165.0 | 94.8 | 10.4 | 17.5 | 19.4 |
| synthetic_150 | 156 | 300 | Svelte Flow | 166.5 | 96.4 | 27.2 | 50.5 | 51.0 |

Block sizing, which measures text with a canvas context, took 1.7 to 2.5 ms on every fixture. It is not part of the ELK column.

The drag check (`scripts/drag.mjs`) dragged one block 40 steps and compared every wire's path before and after:

| fixture | block | canvas | wires re-routed | expected | mean frame (ms) | max frame (ms) |
|---|---|---|---:|---:|---:|---:|
| closed_loop | plant | SVG | 14 of 55 | 14 | 16.7 | 16.8 |
| closed_loop | plant | Svelte Flow | 14 of 55 | 14 | 16.7 | 16.8 |
| synthetic_150 | b050 | SVG | 5 of 300 | 5 | 16.7 | 16.8 |
| synthetic_150 | b050 | Svelte Flow | 5 of 300 | 5 | 16.7 | 16.8 |

No frame was dropped at 60 Hz in either canvas. A click on a block logged its node in both.

### How the layout rules were exercised

- **One level at a time.** `levelOf` builds one ELK graph per assembly node from its children, its boundary faces and its `wires`. The level picker opens any assembly. The synthetic's ten child assemblies draw closed, as gray blocks with their name-only faces, and each opens as a level of its own.
- **Ports.** Each face is a port at a fixed position (`FIXED_POS`): inputs on the west in declaration order, outputs on the east.
- **Declaration order.** `considerModelOrder.strategy: NODES_AND_EDGES` and `cycleBreaking.strategy: MODEL_ORDER` take the node order (walk order) and the wire order (the level row's order) as tie-breaks. Feedback wires then run against the declaration order, for example `δe_lag/out → plant/δe`.
- **Boundary faces.** They are pins pinned to the first and last layers (`FIRST_SEPARATE`, `LAST_SEPARATE`). `descent` shows its root inputs `δe` and `δt` this way.
- **Drag.** A drag moves the block and re-routes only its wires with a three- or five-segment right-angle route (`orthoRoute`). ELK's layered algorithm cannot keep one node fixed, so a local router is the honest option. The moved block keeps its place until reload.

## 2. Schema findings

Each bullet gives the field the drawing wanted, what the canvas did instead, and the proposed change. Code paths are under `src/lib/`.

- **A display name for aliased types.** *Wanted:* the alias a block was built from, `Pack` or `SumJunction`, as its type label. *Did:* the last segment of `type` (`descriptor.ts`, `levelOf`, `typeLabel`). Six of `closed_loop`'s 27 blocks read "Junction": `h_meas`, `state_pack`, `z_pack`, `z_ref_pack`, `command_pack` and `tracker_engaged`. Only `signature` tells them apart, by `typeof(Redstone.Blocks.pack)` against `typeof(+)`, and reading that means parsing a printed type, which the format exists to avoid. This is answer 3's accepted cost. On the diagram it is the most visible defect. *Proposed:* an optional node field, `alias`, the qualified name of the `const` binding when the writer finds one. The label falls back to `type`. How the writer finds the binding stays answer 3's question. **Additive.**
- **The qualified base name's module.** *Wanted:* nothing new; the fixture had to pick a spelling. Answer 3's examples write `Redstone.PID`, but `parentmodule` of a library block is `Redstone.Blocks` (`src/blocks.jl` opens `module Blocks`). The rule as written gives `Redstone.Blocks.PID`. *Did:* the fixtures follow the rule (`Redstone.Blocks.Step` and so on). The label uses the last segment and does not care. *Proposed:* settle which spelling the writer emits, and make the design's examples match, before version one freezes. **Neither; a writer rule, no schema change.**
- **A stable key per wire.** *Wanted:* an id per wire for ELK's edges, Svelte's keyed loops and Svelte Flow's edges, and later for position hints and selection across pushes. *Did:* the wire's index in the level's list (`levelOf`, `` `w${i}` ``). An index shifts when a wire is inserted earlier in the list. A stable key is derivable, because the consumer endpoint `to` is unique within a level: a consumer port has one producer, and an input fanning out is one wire per target. *Proposed:* state that invariant in the `Wire` description, and add it to the core's content assertions (answer 16). **Additive (documentation and a test only).**
- **A name for the root.** *Wanted:* a label for the root level in the level picker, and later for a breadcrumb or a page title when several models are open. *Did:* printed "(root)" (`App.svelte`). The root has path `""`, and `closed_loop` and `descent` both have type `Redstone.Blocks.Group`, so the two descriptors look alike. The core cannot know the name of the function that built the model, but the inspector package can take one as an argument. The schema is strict, so the inspector package cannot add the field unless the schema carries it. *Proposed:* an optional envelope field `name`, written by `inspect` or `write_descriptor` and never by `descriptor`. Low priority. **Additive.**
- **Kinds on assembly faces.** *Wanted:* nothing in this spike. Its wires are unstyled. *Noted for axis 3:* if wires are styled by kind, for example vectors thick and Booleans dashed, a wire into or out of a closed child assembly has no kind at its assembly end. The client would have to resolve through the child's wires to a leaf face, or leave that wire unstyled. *Proposed, if axis 3 asks:* `type` and `kind` on `AssemblyFace`, which answer 4 left room for. **Additive.**
- **The children of a level.** *Wanted:* the child list in declaration order. *Did:* the parent rule over all nodes (`descriptor.ts`, `parentOf` and `levelOf`), keeping walk order. It handled the synthetic's nested assemblies, and its cost is negligible at 171 nodes. *Proposed:* no change. Answer 4's claim that the list is derivable holds.
- **The block label.** *Wanted:* the node's segment. *Did:* the path minus the parent's path. A keyed container's segment is `field/key`, two path segments, and grouping it would use `field` and `key`. The fixtures never exercise that, because a `Group`'s children are name-transparent (`field` `"children"`, `key` equal to the segment). *Proposed:* no change.
- **Boundary faces of a level.** *Wanted:* the names and order of the level's own faces. *Did:* the assembly node's name-only `inputs` and `outputs`, with wire endpoints at the level's own path mapped onto them. The root's pins came from the root node too. *Proposed:* no change.
- **Block sizes.** *Wanted:* width and height for ELK. *Did:* measured the label, the type label and the face names as text (`layout.ts`, `sizeBlock`). *Proposed:* no change; the format should not carry it.

Carried by the schema and never needed by the drawing: `format_version` (a real reader checks `major`; the spike did not), `redstone_version`, `signature`, `parameters`, `timing`, a leaf face's `type`, `kind` and `pinned`, `field` and `key`, `root_inputs`, `anchors`, `scopes`, `types` (docstrings and locations), and the whole `outputs` section. Each serves the detail pane, the bridge or axis 3's rate colors. The drawing argues for removing none of them.

Two findings about tooling rather than the drawing:

- **ajv strict mode refuses the schema.** With `strict: true`, ajv fails with `strictRequired` on the envelope's `oneOf`. Its branches require `build` or `deployment` without declaring them in a local `properties`. With ajv's default options the schema compiles, and `scripts/validate.mjs` uses those. *Proposed:* repeat `"build": true` or `"deployment": true` under `properties` in each branch, or record that the pipeline runs ajv at default strictness. **Neither; the same instances validate.**
- **Noisy errors from `Node`'s `oneOf`.** One wrong field in a leaf node (a `timing.anchor` written as an object while transcribing) gave 30 ajv errors, most from the assembly branch the node was never meant to match. *Proposed:* discriminate on `class` with `if`/`then`/`else`. Weigh this against axis 7's TypeScript generation, which may handle `oneOf` better. **Neither; the same instances validate.**

Divergence from the increment's schema: none learned. `src/descriptor.json` does not exist in the repository yet.

Fixture notes. `fixtures/closed_loop.json` and `fixtures/descent.json` are written by `scripts/transcribe.mjs` from the source and the `Build` renderings, by hand. The wires are the source's verbatim. The trim values in the parameters (`θ`, `δe`, `δt`), the tracker's gains, the signatures, the docstrings and the line numbers are approximate. Anchor scopes at the root are written `""`, where the `Build` rendering prints `root`. The schema's `Anchor` description does not say how the root is spelled, and it could.

## 3. What the spike did not test

- Previous positions as hints on a new push (answer 12). No push was simulated, and ELK's interactive options were not tried.
- ELK in a web worker. The spike ran `elk.bundled.js` on the main thread. 95 ms of warm layout on 150 blocks blocks input for that long.
- Pan and zoom on the SVG canvas, which scrolls at 1:1. Svelte Flow's render time includes its fit-to-view.
- Container grouping by `field` and `key`, a primitive root, which has no level and needs a special case, and the deployment envelope.
- Descriptors from the real writer. All three fixtures are hand-written or generated.
- Layout quality. `closed_loop` draws tangled. Tuning ELK's options is axis 3's and axis 4's work, not this spike's.
- Firefox, Safari, a headed browser and slower hardware.
- Faint line fragments left at a dragged block's old place in Svelte Flow's headless screenshots (`screenshots/closed_loop_flow_dragged.png`). Not investigated.
- Text measurement before web fonts load. The spike uses system fonts.

## Files and commands

`npm install`, then `npm run fixtures` to regenerate the fixtures, `npm run validate`, `npm run check` (clean), `npm run dev` to look, and `npm run build` followed by `npm run measure` and `npm run drag`. Page parameters are `?fixture=closed_loop|descent|synthetic_150&canvas=svg|flow&level=<path>`. Screenshots of every view, before and after a drag, are in `screenshots/`.

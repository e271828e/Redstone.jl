# The visual grammar: axis 3 of the inspector's stage 1

The record of one session, on 2026-10-27, that fixed how each model
concept is drawn, over
the real schema of `src/descriptor.json`, after axis 4's spike chose the
canvas (`design/prototypes/render_spike/report.md`). It builds on
`initial_design.md`'s answers 6, 9 and 15 and on `descriptor_design.md`,
and never restates them; where it amends one, it says so. Like its parents
it is not normative. A schema change it asks for lands as a minor bump,
docs commit first (D-433), and the client follows.

The scope is the core tier's drawing and the overlay of answer 6: blocks,
ports, a level's boundary, wires, containers, color, library icons, the
diagnostics overlay, highlight states and text. Interaction is axis 5's;
layout tuning is axis 4's.

## Pending questions

Left open on purpose, each with the axis or the bump that owns it.

- **Palette values, glyph artwork and the legibility floor.** The exact
  colors, the icon drawings, the halo and casing widths and the semantic
  zoom thresholds are the front end's, tuned in the browser (axes 4 and 7).
- **ELK's part.** Compound nodes for the regions of answer 5 and edge
  merging for the fan-out trunks of answer 4 are axis 4's to configure and
  measure; the grammar holds either way.
- **The claim badge on a root input pin.** Its three states, unclaimed,
  claimed by a device, claimed by the inspector itself, drawn in the slot
  answer 3 reserves; the data is the claim table stage 2's bridge carries,
  which its connect payload or a message of its own must therefore include.
- **What the overlay needs from the failure descriptor's bump.** Per
  diagnostic its kind, text and attribution as a node path, a path and port,
  or a consumer endpoint; for `AlgebraicCycle` the members as node paths,
  the wires as endpoint pairs in the format's `{"path", "port"}` objects,
  the verdict when present, the dead hops as `{"path", "input", "output"}`
  and the tracing mode per member; for a probe failure the function name
  (answer 8). Settled on 2026-10-28 (`failure_descriptor.md`, answer 2):
  `marks`, `cycle` and `function` carry exactly this.

## Answered questions

1. **The block: the spike's frame, kept.** A rounded rectangle with two
   text lines: the node's segment in bold, then the display name, the type's
   last segment until the alias bump of question 7 gives a better one. Fill
   encodes tier, continuous and discrete in two colors, a closed assembly in
   a neutral gray with a double border, the cue that it opens. The timing
   triple is not printed; it drives the rate colors of question 6. The
   signature and the parameters never appear on the block. Where an icon
   applies it replaces the second line, never the frame, so the name and
   the ports sit in one place for every block. A primitive root draws as
   one block standing alone with its faces as the level's boundary around
   it, so the grammar has no special case and only the client's level
   builder does.
   *Why:* the spike's picture already tells continuous from discrete with
   no legend, and gray alone reads as inert, hence the border. Keeping the
   frame under an icon keeps a library block and a user block aligned on
   the same ports.

2. **Faces as ports: squares on the edge, names inside.** Inputs on the
   west and outputs on the east in declaration order, each a small square
   with the face name inside the block beside it. A stage 1 output, joined
   from `outputs` by path, draws as an open square against the filled square
   of a stage 2 output, on by default and not a toggle. A pinned face adds a
   small mark beside its name, off the port. An unconnected face draws at
   full strength. Type and kind are not drawn on the port; they reach the
   user through the wire styles of question 4, the type-label toggle and the
   detail pane. A failure descriptor has no `outputs` section, so every
   output there is the filled square.
   *Why:* which output is state-derived is the one fact that explains why a
   feedback loop is legal, and the glyph costs no space. An unconnected
   input is refused by the build and an unconnected output is ordinary, so
   nothing needs dimming. *Rejected:* names outside the block beside the
   port, Simulink's way, which loses the self-contained block that ELK
   sizes from its own text.

3. **The level's boundary: pins, root inputs as tags.** Each boundary face
   of the opened level is a pin, a node carrying the face name with one
   port: input pins in the first layer with an output port on the east,
   output pins in the last layer with an input port on the west, stacked in
   declaration order as the tie-break. An inner level's pins and every
   output pin are outlined capsules with no fill. A root input pin is a tag,
   a capsule whose inner end is pointed into the model, filled with the
   external color at a light tint. Its outer end is a reserved slot, empty
   in stage 1: stage 2 puts the claim badge there, a device glyph with the
   device's name on hover, the inspector's own mark for its widget, nothing
   for an unclaimed input, and stage 3 hangs its input widget off the same
   end. A fan-out is several wires leaving the pin's one port; a group
   forwarding a face set whole is plain wires from pin to child. Selecting
   a pin shows the face in the detail pane, typed from `root_inputs` at the
   root and from the client's resolution (answer 18) inside.
   *Why:* a root input is the write surface, the one producer the build
   never sees (§11.3), and in stage 3 it is where live values are typed, so
   it earns a cue that survives zoom and weak color vision; shape and fill
   do, a thicker accent stroke does not. A root output is read by whoever
   binds to it and the diagram has nothing to say about readers. The
   binding state is a per-run fact fixed at `attach!`, which no descriptor
   can carry, so the slot is reserved and the data comes over the bridge.
   *Rejected:* drawing the opened assembly as one large frame with its
   ports on the frame's edge, which fights pan and zoom and a tall level and
   puts the faces on an edge ELK cannot place them along.

4. **Wires: gray right angles, kind by line, the client resolves.** A
   wire is a right-angle polyline in neutral gray with one arrowhead at the
   consumer end. Color stays free for the overlay and the highlight; the
   kind marker is drawn as line weight and pattern:

   | kinds | line |
   |---|---|
   | `integer`, `float`, `number` | thin solid |
   | `boolean`, `enum`, `symbol` | thin dashed |
   | `vector`, any shape | thick solid |
   | `struct` | triple line, Simulink's bus |
   | `opaque` | thin dotted, gray |

   A vector of structs is thick: the outer kind wins. At a leaf endpoint
   the kind is on the face; at an assembly endpoint, a closed child's face
   or the level's own pin, the client's resolution of answer 18 supplies
   it, and `AssemblyFace` gains no `type` or `kind`. A fan-out draws as one
   trunk that branches, a filled dot at each branch; the mechanism, ELK's
   edge merging, is axis 4's. A feedback wire gets no special style, since
   the port glyph of answer 2 shows where the loop is legal. The type-label
   toggle, off by default, writes the type string once per producer port,
   cut with an ellipsis at a fixed width, the full string in the detail
   pane; the kind marker is never written out. A wire's key is its
   consumer endpoint, unique within a level because a consumer port has one
   producer and a fan-out is one wire per target; the selection, ELK's
   position hints and the keyed loops use it across pushes.
   *Why:* the dashed discrete-valued kinds tell the mode, the flags and the
   stop requests from the data path at a glance, which is what the closed
   loop needs. Answer 18 already commits the client to resolve every face
   once on load and names the assembly face's marker as the first thing
   that serves; the fields would be the redundancy it rejected, and the
   resolution always ends at a leaf face because the build refuses an
   assembly input that reaches none. Whether the rate-color mode tints
   wires is question 6's.

5. **Containers: a region for a keyed one, nothing for a transparent one.**
   A keyed container's elements draw inside a region, a thin dashed rounded
   rectangle captioned with the field name in its upper-left corner, each
   block inside labelled by its key alone, so caption and label together
   read as the segment `field/key`. The region holds even one element; an
   empty container draws nothing; ELK's compound node is axis 4's
   mechanism. A name-transparent container draws no region, its elements
   plain blocks labelled by bare key, and the membership shows in the
   detail pane from `field` and `key`. The tree of axis 5 agrees: a keyed
   container is a folder named by its field, a transparent one is flattened.
   *Why:* the elements are contiguous in walk order, so the region never
   fights the layout, and transparency is the author's statement that the
   field name is not part of the naming; in the common case, a `Group`, a
   region would frame the whole level, which answer 3 rejected. *Rejected:*
   regions for both kinds; `field/key` labels with no region, which repeat
   the field on every block. *Coupling:* the `sample_times` sugar of §8.7
   keys one rate for all of a container's elements, so a container region
   and a rate scope often coincide, an argument for rates by color in
   question 6.

6. **Color: tier mode by default, rate mode by clock, no regions.** Tier
   mode is the spike's: one color for continuous leaves, one for discrete,
   neutral gray for a closed assembly, wires gray. Rate mode, a toggle,
   keys a discrete leaf's color on its full timing triple, the compiled
   clock against the nearest anchor: same triple, same tick instants under
   every deployment; the authored chain of `Relative` entries is not shown,
   and where an anchored clock lands on the base grid is the deployment
   overlay's fact, not the build's. Continuous leaves keep the continuous
   color. The palette is categorical, at most eight steps, distinct under
   weak color vision, assigned fastest first with anchor 0 first, and a
   model with more triples than colors gets a text badge on the extra
   blocks. A closed assembly takes the color of its scope triple, its
   `scopes` row or the enclosing scope composed by the client when it has
   none, with a multi-rate badge in one corner when the discrete leaves
   under it do not all tick on that clock; an assembly with no discrete
   leaf takes the continuous color. Wires take their terminal producer's
   color at a lighter tint, a root input pin leaving its wires neutral, so a
   rate transition shows as a color change at a block's input. A legend in
   a canvas corner lists every triple visible on the open level, closed
   assemblies included, each read out, "anchor 1 (1/10 s) × 2, phase 1";
   the overlay bump adds the concrete `Δt` and `(D, Φ)` per line. The rate
   palette avoids red and the halo hue.
   *Why:* two blocks under different anchors are two clocks by design, and
   a color keyed on the deployment's `(D, Φ)` would merge or split them per
   deployment. A scope triple is what the author declared at that level and
   what a `Relative` beside it composes against, so a closed block shows it
   and the badge says the inside differs; a hatch for "mixed" answered no
   question. *Rejected:* rate scopes as regions, since a scope is declared
   for one child key and its region would be that child's own block, and
   the container case already has answer 5's region; keying color on the
   period alone with the phase as a mark, since phased blocks never share
   an instant.

7. **Library icons: keyed on the alias, then the type.** A monochrome
   glyph or short math text in the text color, at the second line's height
   and a fixed width, replacing the display name, which moves to the hover
   title and the detail pane; the ports and the sizing rule are untouched.
   The key is the node's `alias` when present and its `type` otherwise, so
   the four `const` aliases of `Junction` draw apart: this asks for the
   alias bump, an optional node field holding the qualified name of the
   most specific `const` type binding in the type's own parent module that
   the instance's type is a subtype of, other than the base type; a
   `Junction` over a user function and an alias defined elsewhere carry
   none. The roster:

   | block | icon |
   |---|---|
   | `SumJunction`; `Or`, `And` | circle with Σ; circle with ∨, with ∧ |
   | `Pack`, `Unpack` | n lines merging into one, and its mirror |
   | `Integrator`, `LimitedIntegrator` | 1/s, and between two limit bars |
   | `DiscreteIntegrator`, `DiscreteLimitedIntegrator` | the same pair over a staircase |
   | `UnitDelay`, `Delay` | z⁻¹, z⁻ᴷ (`K` is a type parameter; the signature gives it) |
   | `FirstOrderLag` | 1/(τs+1) |
   | `StateSpace` family, `TransferFunction` family | ẋ=Ax+Bu; N(s)/D(s) or N(z)/D(z) |
   | `Constant` | its `value` summary cut short; a frame glyph when the output's kind is `opaque` (D-344, D-364) |
   | `Step`, `Source`, `GaussianWhiteNoise` | a step line, f(t), a noise squiggle |
   | `Switch`, `Relay`, `RateLimiter` | the lever, the hysteresis loop, the slope line |
   | `Freeze`; `StopRequest` | a struck-through gradient; an octagon |
   | `PID`, `DiscretePID`; `LQRTracker`, `DiscreteLQRTracker` | PID; LQR |
   | `Group` | none, a closed assembly |

   A user type gets no icon and shows its type's last segment; author
   icons stay refused (answer 15). The icon never changes with tier or
   rate, which are the fill's.
   *Why:* six of the closed loop's blocks read "Junction" with only the
   signature's `typeof(+)` to tell them apart, the parsing the format
   exists to avoid. *Rejected:* a `display_name` trait on the library
   types, a drawing concern made core API when the alias search reaches
   the same result from facts the core has.

8. **The diagnostics overlay: one error hue, drawn where the attribution
   points, loops as chains.** A diagnostic naming a node puts a halo and a
   corner badge on the block, one naming a port marks the port square, one
   naming a consumer endpoint draws that wire heavier in the error hue on
   top; the badge opens the text and the drawer lists every diagnostic with
   the type's source location. A probe failure is the node case, the badge
   carrying the function name from the probe chain. An `AlgebraicCycle`
   halos its members; its wires are terminal pairs, which the client maps
   onto the chain of declared wires between the two leaves by answer 18's
   resolution in reverse, drawn on every level the chain touches, a badge
   on a closed child where the chain continues inside, a red dot on each
   such level in the tree. The verdict is text, not a second color. A dead
   hop is a dashed chord across its member from the input square to the
   output square with a cross at its middle, shown under either verdict. No
   dimming by default; a dimmed state exists for axis 5's focus. Warnings
   take a second reserved hue, amber, same mechanics, once a descriptor
   carries them. The rate palette avoids red, amber and the highlight hue.
   A structure-step failure has no diagram, only the list (answer 6).
   *Why:* the two questions a loop raises, where it closes and which hop is
   false, become things seen rather than reconstructed from slash paths:
   the chord names the member whose contract to question and the wire into
   its input is the one the ladder's first rung re-examines, or the cut the
   second rung makes (§5.4, D-140); a loop across levels is where the text
   is hardest to follow. Both verdicts are refused builds, so a color per
   verdict would spend the warning hue on an error. *Rejected:* straight
   overlay lines between the terminal leaves, which show a wire that does
   not exist and nothing on a crossed level.

9. **Highlight states: one hue, a halo for shapes, a casing for lines, dim
   beneath.** One reserved highlight hue, a blue outside the rate palette.
   Selection is one element: a block or pin shows a halo, a soft wide
   outline just outside its shape; a wire shows a casing, a wider
   translucent band under it, its two port squares marked; a port square a
   small halo of its own; a selected block's incident wires take a light
   casing. Hover is the same at half strength. A face route, from a root
   pin or any face, is the chain of answer 18's resolution drawn as the loop
   chain of answer 8 in the highlight hue: casings on the open level, the
   origin's halo, a badge on each closed child entered, the terminal port
   marked, a dot per level in the tree. Search hits take a dashed halo, the
   selected hit the solid one. Focus on a diagnostic, a route or a search
   dims everything uninvolved by opacity, never by color. Composition from
   bottom to top: dim, normal, route casing, selection halo, error overlay,
   so the error hue always wins; a dragged block draws above its neighbours
   with its halo on; the keyboard focus ring is the halo.
   *Why:* a halo composes with a tier fill, a filled root tag and an
   outlined pin alike, which a fill or stroke change does not; a route and
   a selection differ in shape, a chain with an origin against one element,
   so a second hue would buy nothing. One mechanism draws the loop chain and
   the route.

10. **Text: one system sans, user names verbatim, three levels that drop
    in order.** One system sans-serif stack for the whole canvas, no bundled
    or web font, text icons in the same face with Unicode superscripts and
    operators. A block has three text levels: the segment in bold, the face
    names regular and smaller, the display name lighter. User-chosen names,
    the segment, the face names, a region's caption and a pin's label, are
    set verbatim in their own case and script and never truncated, the
    block sizing to them; a name holding `.` or `[` is shown as is and never
    parsed (D-418). The display name, the alias's last segment then the
    type's, is cut with an ellipsis at a fixed width, its qualified form in
    the hover title and the detail pane; a `Constant`'s value cuts shorter,
    a wire type label at answer 4's width; the signature is never on the
    canvas and parameter summaries appear as the writer cut them. Below a
    legibility floor the levels drop in order, face names first, then the
    display name with its icon, the segment last; wires and port squares
    never drop. Paths print in slash form verbatim; the root's label is the
    envelope's `name` when present, else the root type's display name
    (axis 5 puts a dropped file's name between the two, `workspace.md`,
    answer 10), which asks for the envelope `name` bump, written by `inspect` and
    `write_descriptor` and never by `descriptor`. Rationals print as
    `1/10 s`, multiples and phases as integers. Every element carries a
    hover title with its full text.
    *Why:* layout is computed per client, so a system font costs nothing in
    sameness and removes the spike's measurement-before-fonts risk; the
    names the author wrote are the text the diagram exists to show, and a
    type name is not. *Rejected:* a monospace face, which reads as code and
    widens every block; truncating user names for uniform blocks.

## Design axes

This session closed axis 3. What it hands on, in working order; this list
supersedes the bumps' entries on `descriptor_design.md`'s pending list,
which now points here.

1. **The wire key.** Already in place: increment 81 wrote the sentence in
   the schema's `Wire` description, consumer endpoints are unique within a
   level, and asserts it in the descriptor suite (answer 4). Nothing to do.
2. **The `alias` and `name` fields.** Landed on 2026-10-27, commit 86ff8cc.
   The optional node `alias` with answer
   7's writer rule, the most specific `const` type binding in the type's own
   parent module, and the optional envelope `name` of answer 10, which the
   inspector package writes and `descriptor` never does. They join version
   one's shape with no version bump, the package being unreleased: schema,
   writer, a fixture with a `SumJunction` and a `Pack`, two clauses in
   §13.9, docs commit first.
3. **Axis 5**, workspace and interaction, over this grammar: the tree, the
   breadcrumb, the detail pane and the drawer, search, selection and focus,
   view state by path across pushes, the analysis views, the help page.
   Answers 3, 8 and 9 name what the tree and the drawer carry.
4. **Axes 6 and 7**, as `descriptor_design.md` hands them on, with the
   client's icon table, palette and glyph artwork verified in the browser
   under answer 11's review model.
5. **The inherited bumps**, each a short session, with what this session
   added to it:
   - *The failure descriptor*, with the carrier field built: it carries
     what the pending list above asks for the overlay (answer 8). Ran on
     2026-10-28; its record is `failure_descriptor.md`.
   - *The deployment overlay*, with the rates chain and state events: its
     schedule rows feed the legend's concrete `Δt` and `(D, Φ)` per color
     (answer 6).
   - *Stage 2's extensions*: the claim table beside the connect payload,
     for the badge in the root input pin's slot (answer 3).
   - *The marker additions, the extra locations and the schema's `$id`*,
     unchanged.
6. **Closed, no bump.** `type` and `kind` on an assembly face: the client
   resolves (answer 4).

## Glossary

- **Badge.** A small mark in a block's corner or at a pin's end carrying a
  fact: a diagnostic, a loop or route continuing inside a closed child, a
  multi-rate interior, a root input's claim.
- **Casing.** The highlight of a line: a wider translucent band under a
  wire in the highlight hue.
- **Chord.** A dead hop drawn inside its member, a dashed line from an input
  square to an output square with a cross at its middle.
- **Dim.** The opacity state of everything uninvolved while a diagnostic, a
  route or a search is focused; never a color change.
- **Display name.** A block's second text line: the alias's last segment,
  else the type's, replaced by an icon where one applies.
- **Halo.** The highlight of a shape: a soft wide outline just outside a
  block, a pin or a port square.
- **Hue, reserved.** Red for errors, amber for warnings, blue for highlight,
  all absent from the rate palette.
- **Legend.** The canvas-corner list of the triples visible on the open
  level in rate mode, each read out, later with its concrete `Δt`.
- **Level.** What the canvas draws at a time: an assembly's children as
  blocks, its own faces as pins, its wires.
- **Pin.** A boundary face of the open level drawn as a node with one port:
  an outlined capsule, or a tag for a root input.
- **Rate mode, tier mode.** The two color modes: by timing triple, the
  compiled clock, or by continuous against discrete.
- **Region.** A keyed container's elements framed in a thin dashed rounded
  rectangle captioned with the field name.
- **Semantic zoom.** The fixed order in which a block's text levels drop
  below the legibility floor: face names, display name and icon, segment.
- **Tag.** A root input's pin: a capsule pointed into the model, filled with
  the external color, its outer end a slot for the claim badge.
- **Triple.** A leaf's or scope's `(anchor, m, c)`: the anchor it hangs
  from, its multiple and its phase in that anchor's ticks.

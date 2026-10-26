# The descriptor: axes 1 and 2 of the inspector's stage 1

The record of one session, on 2026-10-26, that designed the descriptor's
schema (axis 1) and its core integration (axis 2) together, as the working
order in `initial_design.md` asked. It builds on that record's answers 4 to
7, 13 and 16 to 18 and never restates them; where it amends one, it says so.
Like its parent it is not normative. What it rules for the framework lands in
`spec.md` and `decisions.md` first, in one docs commit, and the code follows
as an increment.

The scope is version one of the format: what the core tier of the inspector
draws. The session widened it in one place, carrying the `Structure`'s timing
rows now, and kept everything else the working order deferred: the
deployment overlay, state events, the failure descriptor, and stage 2's
extensions.

## Pending questions

Left open on purpose, each with the bump or the axis that owns it.

- **The failure descriptor's bump.** Its body, the encoding of a diagnostic
  as data, whether a raw user exception escaping a probe is wrapped into the
  carrier or shown as diagnostics alone, and the carrier field (answer 15)
  built at the same time.
- **The deployment overlay's bump.** The schedule rows, concrete `Δt`
  values, the hyperperiod and the grid report beside `build` in the
  deployment body. With it, or in a bump of its own, the per-component chain
  of `sample_times` links that answer 9 left out, and the state events.
- **Stage 2's extensions.** Per-field markers on a struct marker, the value
  type schema, and whatever the bridge's connect payload adds to the
  envelope. All additive.
- **Marker additions not yet earned.** A `string` kind when a `String` port
  appears, and `min`/`max` on an integer marker if stage 4's widgets want
  bounds. Each is one minor bump.
- **Locations beyond the declarations.** The stage functions, `y_state`,
  `y_direct`, `x_deriv`, `s_update` and the event functions, among a type's
  source locations, additive when a reader wants them.
- **The schema's `$id`.** The URL it carries once the inspector has a home
  on GitHub Pages; the file ships before the URL resolves.
- **The exact fixture set in the core's suite.** Which models of
  `test/fixtures.jl` cover the cases answer 16 lists, and which small ones
  the increment adds.
- **The name.** `descriptor` is provisional until the export audit (D-226),
  as `series` is.
- **Pretty-printing.** Indentation and line breaks in the file are the
  inspector package's encoder settings (axis 6), not the format's; the
  format fixes key order only.

## Answered questions

1. **The envelope: a header and one body.** Every descriptor is one object
   with `format_version`, `redstone_version`, `kind`, and the body under a
   key named by the kind, `build` or `deployment`, later `failure`.
   `format_version` is an object, `{"major": 1, "minor": 0}`, and
   `redstone_version` a string for information only.
   ```json
   {"format_version": {"major": 1, "minor": 0}, "redstone_version": "0.3.1",
    "kind": "deployment", "deployment": {"build": {…}}}
   ```
   *Why:* a deployment descriptor embeds its build descriptor whole and a
   failure descriptor embeds a `Structure` projection, so the embedded thing
   is a body, the same object whether it stands alone or nested, and one
   schema definition serves both places. A flat, kind-tagged object would
   give the embedded build either a second version stamp or no header. The
   version as an object follows answer 16's reasoning for the kind marker: a
   reader compares integers and parses nothing. *Rejected:* three unrelated
   schemas, which give up the shared version check the bridge will rely on.
2. **The build body mirrors the artifact.** A `structure` section projects
   the `Structure`, an `outputs` section projects `Outputs`, and later bumps
   add `events` and the deployment's own sections. The failure body embeds
   `structure` unchanged. Face types and kind markers live in `structure`:
   the declaration reader takes an instance and its tier, both held by the
   `Structure`, so they exist after the structure step without the nominal
   activation. Only the port classes come from probing, and they live in
   `outputs`. This corrects `initial_design.md`'s axis 2 note, which had
   `descriptor` read the types from the activation's tables.
   *Why:* the boundary falls where the build's own steps fall, so what a
   failure descriptor can carry is what the schema says it carries, with no
   subset rule to maintain. *Rejected:* flat concept sections at the body
   level, with the failure body copying a subset.
3. **Type identity: the qualified base name.** A node's `type` is
   `parentmodule` and `typename` joined, `Redstone.PID`,
   `RedstoneExamples.Longitudinal`, `Main.Aircraft` for a REPL definition.
   It keys the `types` table, labels the diagram by its last segment and
   matches answer 15's icons. Beside it each node carries `signature`, the
   instance's full printed type, untruncated, for the detail pane.
   *Why:* the docstring and the declaration methods attach to the
   unparameterized name, so stripping is what makes the lookup work, and a
   heavily parameterized block would otherwise print its parameters on the
   diagram. A bare name would collide across modules. *Cost accepted:* a
   `const` alias such as `SumJunction{V, N}` is a `Junction` to `typename`,
   so the node says `Redstone.Junction` and carries that docstring; the
   signature's `typeof(+)` still tells it from an `Or`. Recovering the alias
   would mean searching modules for bindings equal to the type.
4. **The node entry.** One object per component in walk order, assemblies
   included (answer 17): `path`, `field`, `key`, `class`, `tier`, `type`,
   `signature`, `timing`, `inputs`, `outputs`, `wires` and `parameters`.
   ```json
   {"path": "aircraft/loops/l1", "field": "loops", "key": "l1",
    "class": "leaf", "tier": "continuous",
    "timing": {"anchor": 0, "m": 4, "c": 1},
    "type": "Redstone.PID", "signature": "PID{Float64, …}",
    "inputs":  [{"name": "r", "type": "Float64",
                 "kind": {"kind": "float"}, "pinned": false}, …],
    "outputs": [{"name": "u", "type": "Float64",
                 "kind": {"kind": "float"}, "pinned": false}, …],
    "parameters": [{"name": "fixed", "value": "(Kp = 2.0, Ki = 0.5, …)"}]}
   ```
   `field` is the field that contributed the node and `key`, present only
   for a container element, its key within the container, a string even
   when the container is a vector. The three memberships then read: no
   `key` is a component field; a `key` with the segment `field/key` is a
   keyed container; a `key` equal to the segment is a name-transparent one.
   The root has `path` `""` and neither `field` nor `key`. An assembly node
   has `class` `"assembly"`, no `tier` or `timing`, name-only faces and its
   `wires` (answer 5); a leaf node has `class` `"leaf"`, typed faces and no
   `wires`.
   Two conventions fixed here for the whole format. *Omission:* a field that
   does not apply is left out, never written as `null`, so presence is the
   test and the schema can require fields per class; an empty collection
   that applies is an empty array. *Face objects on both classes:* an
   assembly's faces are `{"name": …}` objects, not bare strings, so a later
   bump can add fields without a second shape; the schema defines
   `LeafFace` and `AssemblyFace` apart, and `class` says which a node uses.
   *Why:* `segment` and `membership` were in the first sketch and were
   dropped as derivable: the parent is the longest node path that is a
   proper prefix, which skips a container's non-node path such as
   `aircraft/loops`, and the segment is the remainder. `field` is the one
   fact the path loses: under a transparent container the field name
   appears nowhere in `aircraft/1`, and without it the client could not
   group the elements nor tell that `1` is one.
5. **Wires: full-path endpoints on the assembly node.** Each wire is two
   endpoint objects, producer to consumer, verbatim from the level row:
   ```json
   {"from": {"path": "aircraft/engine", "port": "thrust"},
    "to":   {"path": "aircraft/loops/l1", "port": "y"}}
   ```
   A boundary face is spelled with the level's own path, so an input wire's
   `from` or an output wire's `to` reads `{"path": "aircraft", "port":
   "throttle"}`, and a root input is a producer at path `""`. The order is
   the row's: local wires, then input wires, then output wires, each in
   declaration order, an input entry fanning out being one wire per target.
   The class is not tagged; it reads off which side carries the level's
   path. The wires hang on the assembly node, and no `levels` section
   exists.
   *Why:* a face name may contain a dot (D-418), so level-relative strings
   such as `engine.thrust` would need objects anyway, and the client
   rebuilds full paths for resolution and for stage 2's subscriptions; full
   paths are the canonical addressing answer 4 promised. A separate
   `levels` array would key by the assembly's path and hold nothing else,
   since the children list is the node order. A primitive root is a leaf
   root node with no `wires` key.
6. **The kind marker's rule.** Computed from the declared face type as the
   tier reader yields it at `Float64`, a `Pinned` entry unwrapped first and
   setting the face's `pinned` flag, by one classification in test order,
   the first tests subsuming the later ones:

   | test on `T` | marker |
   |---|---|
   | `T <: Bool` | `{"kind": "boolean"}` |
   | `T <: Enum` | `{"kind": "enum", "values": ["NO_STOP", "STOP_REQUESTED"]}` |
   | `T <: Symbol` | `{"kind": "symbol"}` |
   | `T <: Integer` | `{"kind": "integer"}` |
   | `T <: AbstractFloat` | `{"kind": "float"}` |
   | `T <: Real` | `{"kind": "number"}` |
   | `T <: StaticArray` | `{"kind": "vector", "shape": [3], "element": {…}}` |
   | a `NamedTuple` or a concrete struct with fields | `{"kind": "struct", "fields": ["x", "y"]}` |
   | anything else | `{"kind": "opaque"}` |

   This amends answer 16's vocabulary: `number` splits into `integer`,
   `float` and the `number` fallback for the other `Real`s, `Rational`, the
   irrationals and user types subtyping `Real` directly; `symbol` joins
   because a mode signal spelled as a `Symbol` is already in use; `shape`
   replaces `length` so a static matrix reads `[3, 3]`; `values` carries an
   enum's instance names; `element` recurses. `opaque` holds the
   function-valued signals and field handles of §4.4, `String`, abstract or
   `Any` declarations, and whatever the struct test rejects.
   *Why the marker exists at all:* the type string stays beside it, but a
   client cannot evaluate `Angle <: Real`, reflect `fieldnames(Pose)` or
   call `instances(FlightPhase)`, and printed type names are not stable
   keys, aliases and `Pinned` wrappers among them. The marker is the core
   answering the questions only Julia can answer. *Why per-subtype kinds
   stop at integer and float:* those are the two cuts a widget or a wire
   style acts on; finer ones would restate the type string.
7. **Root inputs: a section of leaf faces.** `structure.root_inputs` is an
   array of leaf-face objects, `name`, `type`, `kind` and `pinned`, in the
   artifact's order, typed from `root_types`. The root node's own `inputs`
   stay name-only like any assembly's, joined by name.
   *Why:* §11.3 makes root inputs a concept of their own, the primary data
   and the write surface the bridge's liveness table keys on, and a list
   the bridge and the detail pane read without walking to the root. A
   primitive root duplicates its inputs in both places, a toy case.
   *Rejected:* typing the root node's faces as the one assembly exception.
8. **The `outputs` section mirrors `Outputs`.** `order`, an array of
   primitive paths in execution order, and `components`, one row per
   primitive with its `stage1` and `stage2` port names:
   ```json
   "outputs": {"order": ["aircraft/engine", "aircraft/loops/l1", …],
               "components": [{"path": "aircraft/loops/l1",
                               "stage1": [], "stage2": ["u"]}, …]}
   ```
   Faces carry no stage, and the feedthrough edges `show(::Build)` prints
   are not carried: the client derives them as wires whose terminal
   producer's port is stage 2, into a component with a stage 2, from the
   resolution it already does.
   *Why:* the port class comes from probing, which the failure descriptor
   never has, so a `stage` field on the leaf face would be present only
   when the build completed, the subset rule answer 2 avoids. Carrying the
   edges would be the redundancy answer 18 rejected for wires.
9. **Timing now, the chain later.** Each leaf node carries `timing`, the
   anchor it hangs from with its period multiple and phase in that anchor's
   ticks, and `structure` carries `anchors` and `scopes`:
   ```json
   "anchors": [{"T": {"num": 1, "den": 100}, "tau": {"num": 0, "den": 1},
                "scope": "aircraft", "key": "loops"}],
   "scopes":  [{"path": "aircraft", "key": "loops",
                "timing": {"anchor": 1, "m": 1, "c": 0}}]
   ```
   Anchor 0, the base grid, has no row, as in the artifact. Rationals are
   `{"num", "den"}` objects. The per-component chain of `sample_times` links
   waits for a bump.
   *Why:* this widens the working order, which deferred the timing tables,
   because answer 9's core tier colors blocks by rate and a block's rate is
   its timing row. The rows are in the `Structure` the section mirrors, and
   the deployment's side, concrete `Δt`, the schedule and the hyperperiod
   chart, is the overlay the deferral meant. Objects over `"1//100"`
   strings or floats: exact and parse-free.
10. **Instance context: three rules.**
    - *Docstring.* The type's docstring as its Markdown source, one string
      in the `types` row, from the docsystem's entry for the base name;
      absent when the type has none. The client renders the Markdown.
    - *Locations.* Julia records no location for a `struct`, so the row
      carries the declaration methods' locations, found by `methods(f,
      Tuple{T})` for each the type defines, in this fixed order: `u_types`,
      `y_types`, `x_init`, `s_init`, `m_init`, `sample_times`,
      `local_wires`, `input_wires`, `output_wires`, `stop_reason`,
      `transparent_container`. Each is `{"function", "file", "line"}`, the
      file as Julia reports it, uncleaned, since the live session's open-in-
      editor wants it absolute and the hosted copy only displays it.
    - *Parameter summary.* Per node, `parameters` lists each inert field, the
      fields that are not components or containers as the walk classifies
      them, with `repr` under `:compact` and `:limit` cut at 80 characters
      with an ellipsis. For a `PID` that is one entry, `fixed`.

    *Why:* docstrings and locations are per type and summaries per instance,
    which is answer 2's `types` table. The cut exists so a `Constant`
    holding a lookup table never swells the file, and the summary stays
    display text a program never rebuilds values from (answer 5).
11. **`NamedTuple`s and `Vector`s, with named arrays.** `descriptor` returns
    a tree of `NamedTuple`s for objects and `Vector`s for arrays, strings,
    numbers and Booleans, nothing else. Every object has the fixed key set
    the schema names, so a `NamedTuple` fits, and every collection keyed by
    data is an array of objects with a `name` field: the `types` table and
    the parameter summary among them. Key order in the file is the field
    order, which any JSON encoder preserves.
    *Why:* answer 7 wants two descriptors to diff structurally, which needs
    a fixed key order, and `Dict` has none. `OrderedDict` would give it at
    the price of a dependency in a core that keeps its list short on
    purpose. The named-array rule is one JSON Schema prefers anyway, `items`
    and `required` over `additionalProperties` patterns. The compile cost is
    a dozen fixed shapes built once per call at the REPL. The question was
    reopened once and kept, on the dependency alone.
12. **The schema: home, dialect, strictness, test.**
    - *Home.* `schema/descriptor.json` at the repo root, shipped with the
      package, read by the inspector from `pkgdir(Redstone)` with no
      accessor function. A minor bump edits it in place; a major bump, if
      one ever comes, adds a second file beside it.
    - *Dialect.* Draft 7, which JSONSchema.jl and ajv both cover.
    - *Strictness.* The schema describes the writer's exact output:
      `additionalProperties: false` on every object and `required` per
      class. Validation is a contract check at CI time, in the core's suite
      and in the inspector's fixture pipeline against its pinned Redstone,
      never a runtime gate; a reader at runtime checks the major version
      and ignores unknown fields, as answer 7 rules.
    - *Test.* JSON and JSONSchema join `test/Project.toml` only. The suite
      runs `descriptor`, encodes the value to text, parses the text back
      into generic `Dict`s and validates those. The parsed value is the
      test's alone; `descriptor` never sees text.

    *Why:* the writer and the schema must change in the same commit, which
    is where the schema lives. The round trip validates the bytes a client
    reads, so an encoder rendering a `Rational` wrongly or leaking `null`
    against the omission rule fails here, where validating the Julia value
    directly would not catch it. The inspector repo generates its
    TypeScript types from the same file at build time.
13. **Two methods in version one.** `descriptor(build::Build)` returns the
    build envelope, and `descriptor(deployment::Deployment)` the deployment
    envelope whose body holds `build` alone until the overlay's bump. Both
    return the value of answer 11, with `redstone_version` from
    `pkgversion`. The core offers no text, no file and no `Simulation`
    method; `write_descriptor` and `inspect` are the inspector package's
    under axis 6, and stage 2's `inspect(sim)` reaches the deployment
    through the simulation. The code is a new `src/descriptor.jl` beside
    `show.jl`, included after the deployment's file. The failure method
    waits for its bump.
    *Why:* the deployment envelope costs one method and exercises the
    embedding and the `kind` tag from the first fixture, and a deployment
    is what a user has in hand.
14. **The spec's home and the ruling.** A new §13.9, "The descriptor: an
    artifact rendered to data", at the end of chapter 13, with one sentence
    in §9.2 beside `show`'s pointing to it. One entry, D-432, in the bundled
    shape of D-406: `descriptor` renders a `Build` or a `Deployment` to data
    under a published, versioned format beside `show`'s rendering to text,
    and a rendering to data is not the accessor D-257 rejects. An accessor
    returns the artifact's internals for a program to navigate, binding the
    fields D-261's artifact rule keeps free; the descriptor returns a
    projection under a contract of its own, whose stability is the format's
    and never the fields'. Bundled: the envelope and the two kinds, the
    additive-minor and breaking-major rule, the schema's home and the
    round-trip test, the `NamedTuple` shape with the named-array rule, the
    kind marker's table, the instance context's three rules, the carrier
    field, and the name provisional. D-257 gets an annotation. The section
    states what each kind carries and the rules; `schema/descriptor.json`
    is the shape of record, cited from it, and the spec carries no
    field-by-field prose.
    *Why:* chapter 13 holds the tooling contracts with external clients and
    a new last section disturbs no number; §9.2 defines the artifacts and a
    sentence there is right for the fact that they render to data too.
15. **The carrier change: a third field.** `DiagnosticError` gains
    `structure`, `nothing` everywhere except on a throw past the structure
    step, where it holds the complete `Structure`. One site fills it: the
    build's door catches the carrier leaving the nominal step and rethrows
    it with the structure attached, so no probe or cycle site changes. §13.2
    states it now, as recorded and unbuilt, and the failure descriptor's
    bump builds it as its first consumer. A raw user exception escaping a
    probe is not the carrier and carries nothing; what the bump does with it
    is the bump's question.
    *Why:* it follows `warnings`' pattern on the same carrier (D-250) and
    keeps §13.2's one-carrier rule. *Rejected:* a wrapper exception for build
    failures, a second type; a build door returning the structure on
    failure, a second calling convention.
16. **Fixtures.** The core's suite gains `test_descriptor.jl`, running
    `descriptor` on fixture models that together cover every case the
    schema distinguishes, a primitive root, keyed and transparent
    containers, an `Absolute` anchor with keyed rates, a `Pinned` face and
    a face of every kind in answer 6's table, each validated after the
    round trip, with content assertions beside: node order is the walk
    order, every wire endpoint names a node or the level's own path, every
    node type has a `types` row. The inspector's CI generates descriptors
    from the examples package and from a small synthetic model in its own
    repo, commits the JSON so the front end's tests run without Julia, and
    fails when regeneration against the pinned Redstone differs. Axis 4's
    spike runs on a descriptor written by hand against the schema and
    validated with ajv, retired when the generated fixtures land.
    *Why:* the core has no reader to serve, and committed generated files
    there would churn on every structural commit; the inspector repo is the
    one place that reads them, and a pin bump then shows the format's
    changes as a reviewed diff.

## Design axes

This session closed axes 1 and 2. What it hands on, in working order:

1. **The docs commit.** §13.9 and the §9.2 sentence, D-432 with its
   bundle, the `structure` field in §13.2 as recorded and unbuilt, D-257's
   annotation, and `initial_design.md`'s pointer here.
2. **The increment.** `schema/descriptor.json`, `src/descriptor.jl` with the
   two methods, `test_descriptor.jl` with its fixtures, JSON and JSONSchema
   as test dependencies. Briefed under `brief_lessons.md`'s rules.
3. **Axis 4's spike**, beside the increment, on the hand-written fixture of
   answer 16. What the drawing finds missing reaches the schema before
   version one freezes with the increment's commit.
4. **Axis 3**, over the real schema: what it draws is on the node (class,
   tier, timing, faces with markers, `field` and `key` for container
   groups) and on the assembly node's wires; port classes join from
   `outputs` by path.
5. **Axes 6 and 7.** The encoder's indentation, the fixture generation and
   the TypeScript types from the schema file.
6. **The minor bumps**, each a short session: the deployment overlay with
   the rates chain, state events, the failure descriptor with the carrier
   field built, then stage 2's extensions.

## Glossary

- **Body.** The object under the key named by the descriptor's `kind`: the
  build body, the deployment body that embeds a build body, later the
  failure body that embeds a `structure` section.
- **Endpoint.** One end of a wire, `{"path", "port"}` in full paths, the
  level's own path on a boundary face and `""` for a root input.
- **Envelope.** The top-level object: `format_version`, `redstone_version`,
  `kind` and the body.
- **Face object.** A face as the node carries it: a *leaf face* with `name`,
  `type`, `kind` and `pinned`, or an *assembly face* with `name` alone.
- **Field and key.** On a node, the field that contributed it to its parent
  and, for a container element, its key within the container. Together with
  the path they fix the membership: component field, keyed container or
  name-transparent container.
- **Format version.** The `{"major", "minor"}` object in the envelope. A
  minor bump adds fields; a major bump may break readers.
- **Kind.** Two senses, kept apart by context: the descriptor's kind in the
  envelope, `build`, `deployment` or `failure`; and the kind marker's first
  field, `boolean`, `enum`, `symbol`, `integer`, `float`, `number`,
  `vector`, `struct` or `opaque`.
- **Kind marker.** The object beside a leaf face's type string that tells a
  client with no Julia what the type is, by the rule of answer 6.
- **Location.** A declaration method's `{"function", "file", "line"}` in a
  type's row.
- **Named array.** The format's rule for a collection keyed by data: an
  array of objects each carrying `name`, never an object with data keys.
- **Node.** One component of the walk, leaf or assembly, keyed by its path.
- **Omission.** The format's rule that a field which does not apply is left
  out rather than written as `null`; an empty collection that applies is an
  empty array.
- **Parameter summary.** A node's inert fields as display text, cut at 80
  characters, never a serialization of values.
- **Parent rule.** The client's rule for a node's parent: the longest node
  path that is a proper prefix of its path, which skips a container's
  non-node path.
- **Qualified base name.** A type's `parentmodule` and `typename` joined,
  the node's `type` and the `types` table's key, with type parameters
  stripped.
- **Round trip.** The core test's path: the Julia value encoded to JSON text,
  parsed back into generic dictionaries, and validated, so that the bytes a
  client reads are what conforms.
- **Schema of record.** `schema/descriptor.json`, shipped with the package:
  the exact shape of the format, draft 7, strict about the writer's output,
  cited from §13.9 and never restated field by field in prose.
- **Section.** A top-level key of a body: `structure` and `outputs` in the
  build body of version one.
- **Signature.** A node's full printed concrete type, beside its qualified
  base name, untruncated.
- **Timing.** A leaf node's or a scope's `{"anchor", "m", "c"}`: the anchor
  it hangs from, its period multiple and its phase in that anchor's ticks.
- **Types table.** `structure.types`, one row per qualified base name with
  the docstring and the locations, so a repeated type is described once.

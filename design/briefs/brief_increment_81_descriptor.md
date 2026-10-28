# Brief: increment 81, the descriptor

One code commit, which I apply from the prototype, one cold review and a
fixer if the review needs one. Written on 2026-10-26 at 811713b, the docs
commit that landed D-433 over 600b9c3, the one that landed §13.9, D-432, the
§9.2 sentence, the `structure` field in §13.2 and D-257's annotation. The
design record is `design/inspector/descriptor_design.md`, not normative;
axis 4's spike, run beside this increment, is
`design/prototypes/render_spike/report.md`. Find passages in
`design/implementation.md` by heading.

Design and code are peers, neither subservient. If a shape below proves
wrong at the keyboard, stop and report rather than deviate silently.

`prototype_increment_81.patch`, beside this brief, is the reference
implementation, taken at 811713b on a scratch worktree where the full gate
ran green at 6947 assertions, 326 of them the new file's. The spike's
three fixtures validate against the patch's schema with ajv.

## What is settled

D-432's bundle and §13.9, as 811713b leaves them, with D-433's readings:

- `descriptor(build)` and `descriptor(deployment)` return one envelope,
  `format_version` `{major: 1, minor: 0}`, `redstone_version`, `kind`, and
  the body under the kind's key; the deployment body embeds the build body
  whole. A minor bump adds fields; a major bump may break readers.
- The build body's `structure` projects the `Structure`: the nodes in walk
  order with class, `field` and `key`, tier and timing, the qualified base
  name with the signature beside it, faces, the assembly nodes' wires
  verbatim with full-path endpoints, the root inputs typed, the anchors,
  the scopes and a `types` table. `outputs` projects the `Outputs`. Nothing
  resolved, no internals.
- A leaf face carries its type, the kind marker by §13.9's table in test
  order, and the `pinned` flag of a `Pinned` entry unwrapped.
- A type is described once by `parentmodule` and `typename`, with its
  docstring as Markdown source and the locations of the declaration methods
  it defines in the fixed order; an instance by its full printed type and
  its inert fields as `repr` text cut at 80 characters.
- The value is `NamedTuple`s, vectors, strings, numbers and Booleans; a
  field that does not apply is omitted, never `nothing`; a collection keyed
  by data is an array of objects carrying `name`. No JSON dependency in the
  core.
- `src/descriptor.json`, draft 7, strict, is the shape of record; the
  suite validates the round trip through JSON text, with JSON and
  JSONSchema as test dependencies.
- The carrier's `structure` field stays unbuilt; the failure descriptor's
  bump builds it.

## The shape, as the patch has it

- `src/descriptor.json`: the envelope with a `oneOf` per kind, and the
  definitions `BuildBody`, `DeploymentBody`, `StructureSection`, `Node` as
  `LeafNode` or `AssemblyNode` over the shared `NodeIdentity`, `LeafFace`,
  `AssemblyFace`, `KindMarker`, `Wire`, `Endpoint`, `Timing`, `Rational`,
  `Anchor`, `Scope`, `TypeRow`, `Location`, `Parameter`, `OutputsSection`
  and `ComponentOutputs`, every object closed. The spike's two findings
  are in: the `Wire` description states that `to` is unique within a level
  and keys the wire, and the `oneOf` branches repeat the body key under
  `properties` so ajv's strict mode compiles the file.
- `src/descriptor.jl`, included after `show.jl`: `DESCRIPTOR_FORMAT`,
  `LOCATED_DECLARATIONS`, the two `descriptor` methods over `_envelope` and
  `_build_body`; `_structure_section` over `_nodes`, a pre-order walk from
  the root's level row through each assembly's children, leaves read off
  `components`, with `_identity` taking `field` and `key` from `membership`
  on the `Child`; `_leaf_node` and `_assembly_node`, the latter's faces from
  `_boundary_inputs` and `_boundary_outputs` and its wires from the level
  row; `_leaf_faces` over the declaration as written, `_leaf_face`
  unwrapping a `Pinned` entry; `_kind_marker` and `_struct_fields`;
  `_qualified_name`, `_type_string`, `_parameters`, `_type_rows`,
  `_docstring` off `Base.Docs.meta` and `_locations` through `_declares`
  and `which`; `_outputs_section`. Every reader of an instance takes it
  `@nospecialize`d.
- `test/test_descriptor.jl`: the round trip, the fixture sweep and the
  content testsets below. `test/fixtures.jl` gains `KeyedGains`, a keyed
  `NamedTuple` container beside a `Tuple` one, in a new section at the end.
  `test/imports.jl` admits `descriptor`; `test/RedstoneTests.jl` includes
  and runs the file after `show`; `test/Project.toml` adds JSON 1 and
  JSONSchema 1 with compat.

## The readings D-433 settles

Eight places where §13.9 and the record stopped short were read one way by
the prototype and ruled on 2026-10-26, docs-commit-first, as D-433 with its
§13.9 sentences and the record's amendments. The patch conforms to them:

1. The qualified base name keeps the full parent module,
   `Redstone.Blocks.PID`; the record's examples are corrected.
2. The kind marker's `struct` row is an isbits value with fields, what the
   leaf walk opens; a field handle, not isbits, and a function type are
   opaque ahead of it. `_struct_fields` tests `isbitstype`, and the
   `Function` arm precedes it.
3. An abstract declaration takes the first row it matches; `Any`, `String`
   and an abstract type no row matches are opaque.
4. `pinned` on a root input is `false` in version one; the leaf-face shape
   stays, and the schema's `StructureSection` description says so.
5. `type` and `signature` are display text, `string(T)` from `Main`; the
   base name is the identity.
6. A type's docstring is the struct's own, the docsystem's `Union{}` entry,
   else the first the binding holds.
7. The root node has neither `field` nor `key`; a primitive root is one leaf
   node at `""` with no `wires` key.
8. The spike's three additive proposals, the node `alias`, the envelope
   `name` and a type and kind on an assembly face, wait as minor bumps on
   the record's pending list and are not in version one.

## What the tests pin, by property

- The sweep, over `Plant()`, `fed(PinnedGain(), "e")`, `Vehicle()`,
  `FannedLoops(2)`, `MultiRate()`, `routed_pair()`, `TerrainRig()`,
  `KeyedGains()` and the test's `kinds_model()`: the round trip validates
  and the text holds no `null`; the envelope's keys and values; two calls
  are equal; the leaf nodes' paths are `paths(structure)` and the assembly
  nodes' the level rows' minus a primitive root; each assembly node's wires
  count the level's, every endpoint names a node and `to` is unique; every
  node type has one `types` row; the `outputs` order and rows mirror the
  `Outputs`; the root inputs mirror the structure's with `string.(root_types)`.
- The deployment envelope: its keys, its body embedding
  `descriptor(build).build`, and a primitive root's deployment.
- Membership: `KeyedGains`'s `gains/a` and `pair/1`, `routed_pair`'s
  transparent `pair`, `Vehicle`'s component field `loop`, the root with
  neither; an assembly's faces and three of its wires by position; a leaf
  with no `wires` key.
- Kinds: every row of the table on `kinds_model()`, `shape` `[2]` and
  `[2, 2]`, the enum's instance names, the terrain handle and a closure with
  a capture opaque (D-433), the pinned flag and the leaf type on a
  `Constant`, `PinnedGain`'s face whole, and the dotted root face `dut.k`
  (D-418) in the root inputs and in the wire.
- Timing: `MultiRate`'s `gnss` on anchor 1, `fcs/outer` at `(0, 5, 2)`, no
  `tier` or `timing` on an assembly, the anchors and scopes rows whole.
- The types table: `Vehicle`'s six rows in first-appearance order, `Plant`'s
  docstring and its three locations in the fixed order with `x_init` one
  line above `u_types`, `Vehicle`'s three wire declarations,
  `GearStateSource` with no `docstring` key, `Plant`'s and `SampledLoop`'s
  summaries, the root's empty one, the signature and type strings, and the
  80-character cut on a `Constant` holding a 20-field `NamedTuple`.

## Bookkeeping, in the same commit

- `design/implementation.md`: the `src/Redstone.jl` entry's include list
  gains `descriptor` after `show`; a `src/descriptor.jl` entry; the routing
  table gains the row `descriptor`, or `src/descriptor.json` → `descriptor`.
- `design/pending.md`: the stage-1 bullet records the increment and the
  spike as landed and names axis 3 as next.
- Files to commit: `src/descriptor.json`, `src/descriptor.jl`,
  `src/Redstone.jl`, `test/test_descriptor.jl`, `test/fixtures.jl`,
  `test/imports.jl`, `test/RedstoneTests.jl`, `test/Project.toml`,
  `design/implementation.md`, `design/pending.md`. Never a
  `Manifest.toml`, and never another session's untracked files.

## Out of scope

- The failure descriptor, the carrier field's fill, the deployment overlay
  and the rates chain, state events, stage 2's extensions: the record's
  bumps.
- `write_descriptor`, `inspect`, the encoder's settings, the schema's `$id`:
  the inspector package's, axes 6 and 7.
- The name `descriptor`: the audit's (D-226).

## The cold review

One fresh Opus reviewer over the code commit, §13.9, D-432 and D-433 at
811713b read for what they owe: open-mind stance, probe scripts in the
scratchpad, "empty is acceptable". Dimensions:

- **The docs against the tree.** Every sentence of §13.9 and every bullet of
  D-432's and D-433's Positions holds of the code, each probed.
- **The schema against the writer.** Every key the writer emits is in the
  schema and every `required` key is always emitted; probe with the examples
  package's `closed_loop`, `aircraft` and `descent` (the spike's
  `print_builds.jl` shows how to build them) and with every zero-argument
  fixture of `test/fixtures.jl` that builds, not only the sweep's nine.
- **The walk order.** On a model with nested keyed and transparent
  containers, the node list is the structure step's pre-order and `field`
  and `key` recover each membership.
- **Allocation and compile cost.** `descriptor` runs once per call at the
  REPL; confirm no reader of an instance specializes per component type
  (`@nospecialize` on every instance-taking helper), and time a call on
  `closed_loop`.
- **Naming** over every touched line; `test/imports.jl` sorted where it was
  sorted; no local shares a name with a function its module sees.
- **Mutants on a scratch copy**, each named test going red: the `Bool` row
  moved below `Integer`; the `Pinned` unwrap dropped; `key` taken as the
  whole segment for a keyed container; the wires reversed; a missing
  docstring written as `nothing`; `field` emitted on the root; the cut at
  79 or 81 characters; the `types` deduplication dropped; `outputs.order`
  taken from `components`'s order; a leaf's `timing` taken from its scope;
  `_declares` skipped in `_locations` so the `Any` fallbacks' locations
  appear; `tau` written from `T`. A surviving mutant is a missing test, or
  an acceptable survivor named with its reason.
- The gate and the examples' runner green on the Julia floor `Project.toml`
  declares.
